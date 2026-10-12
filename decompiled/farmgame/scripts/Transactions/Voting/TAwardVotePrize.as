package Transactions.Voting
{
   import Classes.Avatar.AvatarItem;
   import Classes.FeatureComponents.VotingComponent;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.ItemLicense;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.GenericXMLDialog;
   import Display.UI;
   import Engine.Transactions.Transaction;
   import Events.GenericPopupEvent;
   import Managers.LicenseManager;
   import Managers.VotingDataManager;
   
   public class TAwardVotePrize extends Transaction
   {
      
      protected var m_featureName:String;
      
      protected var m_profileIndex:int;
      
      protected var m_awardItemIndentifier:String;
      
      protected var m_rewardItem:FarmItem = null;
      
      protected var m_avatarRewardItem:AvatarItem = null;
      
      protected var m_rewardLicense:ItemLicense = null;
      
      protected var m_rewardUrl:String = "";
      
      protected var m_profileStr:String;
      
      protected var m_friendItem:FarmItem;
      
      public function TAwardVotePrize(featureName:String)
      {
         super();
         this.m_featureName = featureName;
      }
      
      override public function perform() : void
      {
         signedCall("VotingService.onRedeemFinalPrize",this.m_featureName);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var icon:String = null;
         var friendlyName:String = null;
         var licenseCode:String = null;
         var dt:Date = null;
         var time:Number = NaN;
         var strPK:String = null;
         var PKOutcome:String = null;
         var profileStr:String = null;
         var messageText:String = null;
         var imageSize:Number = NaN;
         var centerIconUrl:String = null;
         var dialog:GenericXMLDialog = null;
         if(Boolean(result) && Boolean(result.hasOwnProperty("rewardUrl")) && Boolean(result.rewardUrl))
         {
            if(result.hasOwnProperty("profileIndex") && result.profileIndex != null && result.hasOwnProperty("rewardCode") && Boolean(result.rewardCode))
            {
               this.m_rewardUrl = result.rewardUrl;
               this.m_profileIndex = result.profileIndex;
               switch(result["rewardType"])
               {
                  case "avatar":
                     this.m_avatarRewardItem = Global.avatarConfigSettings.getItemById(result.rewardCode);
                     if(this.m_avatarRewardItem)
                     {
                        Global.player.avatarState.grantItem(this.m_avatarRewardItem.itemId);
                        icon = Global.reverseAssetURL(this.m_avatarRewardItem.iconPath,3);
                        friendlyName = this.m_avatarRewardItem.friendlyName;
                     }
                     break;
                  case "item":
                     this.m_rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(result.rewardCode);
                     if(this.m_rewardItem)
                     {
                        Global.player.addGift(this.m_rewardItem.name,"0",1);
                        icon = Global.reverseAssetURL(this.m_rewardItem.iconUrl,2);
                        friendlyName = this.m_rewardItem.friendlyName;
                     }
                     break;
                  case "license":
                     this.m_rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(result.rewardCode);
                     licenseCode = this.m_rewardItem.license;
                     this.m_rewardLicense = Global.farmGameSettingsManager.getItemLicenseByCode(licenseCode);
                     if(Boolean(this.m_rewardItem) && Boolean(this.m_rewardLicense))
                     {
                        dt = new Date();
                        time = (dt.getTime() + 10 * 365 * FarmGameUtil.NUM_MSECS_IN_DAY) / 1000;
                        LicenseManager.getInstance().addLicense(result.rewardCode,time);
                        icon = Global.reverseAssetURL(this.m_rewardItem.iconUrl,2);
                        friendlyName = this.m_rewardItem.friendlyName;
                     }
               }
               switch(result["friendRewardType"])
               {
                  case "item":
                     this.m_friendItem = Global.farmGameSettingsManager.getFarmItemByCode(result.friendRewardCode);
                     break;
                  case "avatar":
               }
               if(Boolean(this.m_rewardItem) || Boolean(this.m_avatarRewardItem))
               {
                  strPK = VotingComponent.getLocalizedKey(this.m_featureName,"ProfileShare");
                  PKOutcome = VotingComponent.getLocalizedKey(this.m_featureName,"OutcomeTitle_" + this.m_profileIndex);
                  profileStr = ZLocUtils.t_pk(PKOutcome);
                  this.m_profileStr = profileStr;
                  VotingDataManager.getInstance().getDataObject(this.m_featureName).hasRedeemedFinalPrize = true;
                  messageText = ZLocUtils.t_pk(strPK,null,{
                     "item":ZLocUtils.tk_pk(friendlyName),
                     "profile":profileStr
                  });
                  imageSize = 100;
                  centerIconUrl = icon;
                  dialog = new GenericXMLDialog(null,"",null,centerIconUrl,imageSize,imageSize,messageText,this.onCloseFeedPrompt,true,ZLocUtils.t("Dialogs","JustShare"),null,null,null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
                  UI.displayPopup(dialog,false);
               }
            }
         }
      }
      
      protected function onCloseFeedPrompt(event:GenericPopupEvent) : void
      {
         var friendlyName:String = null;
         var icon:String = null;
         var params:Object = null;
         var bundleSuffix:String = null;
         if(GenericPopup.ACCEPT == event.button)
         {
            if(this.m_friendItem)
            {
               friendlyName = this.m_friendItem.friendlyName;
               icon = this.m_friendItem.icon;
            }
            else if(this.m_rewardItem)
            {
               friendlyName = this.m_rewardItem.friendlyName;
               icon = this.m_rewardItem.icon;
            }
            else
            {
               friendlyName = this.m_avatarRewardItem.friendlyName;
               icon = this.m_avatarRewardItem.iconPath;
            }
            params = new Object();
            params.itemname = friendlyName;
            params.images = [{
               "src":icon,
               "href":"{SN_APP_URL}" + this.m_rewardUrl
            }];
            params.reward_link = this.m_rewardUrl;
            params.profile = this.m_profileStr;
            params.creative = "profile_" + this.m_profileIndex;
            bundleSuffix = "Profile";
            GlobalEngine.socialNetwork.publishFeedStory(this.m_featureName + bundleSuffix,params,[],false);
         }
      }
   }
}

