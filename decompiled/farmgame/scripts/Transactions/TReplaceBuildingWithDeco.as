package Transactions
{
   import Classes.RewardCreditsBuilding;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.GenericXMLDialog;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import flash.utils.getQualifiedClassName;
   
   public class TReplaceBuildingWithDeco extends TWorldState
   {
      
      protected var m_rewardCreditsBuilding:RewardCreditsBuilding = null;
      
      protected var m_redeemItemIdentifier:String = "";
      
      protected var m_creditCost:uint = 0;
      
      protected var m_rewardItem:Object = null;
      
      protected var m_rewardUrl:String = "";
      
      protected var m_isAvatarItem:Boolean;
      
      protected var m_completeCallback:Function = null;
      
      protected var m_altShareItemName:String;
      
      public function TReplaceBuildingWithDeco(building:RewardCreditsBuilding, completeCallBack:Function = null)
      {
         this.m_rewardCreditsBuilding = building;
         this.m_completeCallback = completeCallBack;
         super(building);
      }
      
      override public function perform() : void
      {
         var className:String = null;
         if(m_object)
         {
            className = getQualifiedClassName(m_object);
            FarmStatsManager.count("TReplaceBuildingWithDeco",className);
         }
         signedWorldAction("replaceBuildingWithDeco");
      }
      
      override protected function onComplete(result:Object) : void
      {
         var strPK:String = null;
         var messageText:String = null;
         var imageSize:Number = NaN;
         var centerIconUrl:String = null;
         var dialog:GenericXMLDialog = null;
         if(this.m_completeCallback != null)
         {
            this.m_completeCallback();
         }
         else if(Boolean(result.rewardUrl) && Boolean(result.rewardIdentifier))
         {
            this.m_redeemItemIdentifier = result.rewardIdentifier;
            this.m_rewardItem = this.m_isAvatarItem ? Global.avatarConfigSettings.getItemById(this.m_redeemItemIdentifier) : Global.farmGameSettingsManager.getFarmItemByName(this.m_redeemItemIdentifier);
            if(this.m_rewardItem)
            {
               this.m_rewardUrl = result.rewardUrl;
               this.m_altShareItemName = result.altShareItemName;
               strPK = RewardCreditsBuilding.getLocalizedKey(this.m_rewardCreditsBuilding.getCreditsFeatureName(),"RedeemOffboardMessage");
               messageText = ZLocUtils.t_pk(strPK,null,{"item":ZLocUtils.tk_pk(this.m_rewardItem.friendlyName)});
               imageSize = 100;
               if(!this.m_isAvatarItem)
               {
                  centerIconUrl = this.m_rewardItem.getImageByName("icon",false);
               }
               else
               {
                  centerIconUrl = Global.reverseAssetURL(this.m_rewardItem.iconPath,3);
               }
               dialog = new GenericXMLDialog(null,"",null,centerIconUrl,imageSize,imageSize,messageText,this.onCloseFeedPrompt,true,ZLocUtils.t("Dialogs","JustShare"),null,null,null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
               UI.displayPopup(dialog,false);
               Global.player.addGift(this.m_rewardItem.name);
            }
         }
      }
      
      protected function onCloseFeedPrompt(event:GenericPopupEvent) : void
      {
         var params:Object = null;
         var bundleSuffix:String = null;
         if(GenericPopup.ACCEPT == event.button)
         {
            params = new Object();
            params.count = this.m_creditCost;
            params.itemname = this.m_rewardItem.friendlyName;
            params.images = [{
               "src":(this.m_isAvatarItem ? this.m_rewardItem.iconPath : this.m_rewardItem.icon),
               "href":"{SN_APP_URL}" + this.m_rewardUrl
            }];
            params.reward_link = this.m_rewardUrl;
            params.basketname = RewardCreditsBuilding.getBasketFriendlyName(this.m_rewardCreditsBuilding.getCreditsFeatureName());
            params.credititemname = RewardCreditsBuilding.getCreditItemFriendlyName(this.m_rewardCreditsBuilding.getCreditsFeatureName());
            params.credititemname_single = RewardCreditsBuilding.getCreditItemFriendlyName(this.m_rewardCreditsBuilding.getCreditsFeatureName());
            bundleSuffix = "Redeem";
            if(this.m_altShareItemName)
            {
               bundleSuffix = "RedeemAlt";
               params.rewarditemname = this.m_altShareItemName;
            }
            GlobalEngine.socialNetwork.publishFeedStory(this.m_rewardCreditsBuilding.getBundlePrefix() + bundleSuffix,params,[],false);
         }
      }
   }
}

