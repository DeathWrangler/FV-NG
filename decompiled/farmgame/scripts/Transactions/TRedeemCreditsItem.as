package Transactions
{
   import Classes.RewardCreditsBuilding;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.GenericXMLDialog;
   import Display.UI;
   import Events.GenericPopupEvent;
   
   public class TRedeemCreditsItem extends TWorldState
   {
      
      public static const SERVER_ACTION:String = "redeemItem";
      
      protected var m_rewardCreditsBuilding:RewardCreditsBuilding = null;
      
      protected var m_redeemItemIdentifier:String = "";
      
      protected var m_creditCost:uint = 0;
      
      protected var m_rewardItem:Object = null;
      
      protected var m_rewardUrl:String = "";
      
      protected var m_isAvatarItem:Boolean;
      
      protected var m_completeCallback:Function = null;
      
      protected var m_altShareItemName:String;
      
      protected var m_centerIconVerticalDisplace:int = 0;
      
      protected var m_amountRedeemedWithCash:int = 0;
      
      public function TRedeemCreditsItem(building:RewardCreditsBuilding, redeemItemIdentifier:String, creditCost:uint, isAvatarItem:Boolean = false, completeCallBack:Function = null, amountRedeemedWithCash:int = 0)
      {
         this.m_rewardCreditsBuilding = building;
         this.m_redeemItemIdentifier = redeemItemIdentifier;
         this.m_creditCost = creditCost;
         this.m_isAvatarItem = isAvatarItem;
         this.m_completeCallback = completeCallBack;
         this.m_amountRedeemedWithCash = amountRedeemedWithCash;
         super(building);
      }
      
      override public function perform() : void
      {
         signedWorldAction(SERVER_ACTION,this.m_redeemItemIdentifier,this.m_creditCost,this.m_isAvatarItem);
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
         else if(result.rewardUrl)
         {
            this.m_rewardItem = this.m_isAvatarItem ? Global.avatarConfigSettings.getItemById(this.m_redeemItemIdentifier) : Global.farmGameSettingsManager.getFarmItemByName(this.m_redeemItemIdentifier);
            if(this.m_rewardItem)
            {
               this.m_rewardUrl = result.rewardUrl;
               this.m_altShareItemName = result.altShareItemName;
               strPK = RewardCreditsBuilding.getLocalizedKey(this.m_rewardCreditsBuilding.getCreditsFeatureName(),"RedeemMessageWithQuantity");
               if("" == strPK)
               {
                  strPK = RewardCreditsBuilding.getLocalizedKey(this.m_rewardCreditsBuilding.getCreditsFeatureName(),"RedeemMessage");
               }
               if("" == strPK)
               {
                  strPK = "RewardCreditsBuilding:RedeemMessageWithQuantity";
               }
               messageText = ZLocUtils.t_pk(strPK,null,{
                  "item":ZLocUtils.tk_pk(this.m_rewardItem.friendlyName),
                  "quantity":this.m_creditCost,
                  "creditword":ZLocUtils.tk("RewardCreditsBuilding","Credit_word","",this.m_creditCost)
               });
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
               dialog.setTrackerKey("feed-" + this.m_rewardCreditsBuilding.getLocKeyPrefix() + "redeem");
               UI.displayPopup(dialog,false);
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
      
      public function setCenterIconVerticalDisplace(verticalDisplace:int) : void
      {
         this.m_centerIconVerticalDisplace = verticalDisplace;
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = TWorldState.METHOD_PERFORM_ACTION;
         result.action = SERVER_ACTION;
         result.building = this.m_rewardCreditsBuilding;
         result.item = this.m_rewardCreditsBuilding.getItem();
         result.amountRedeemedWithCash = this.m_amountRedeemedWithCash;
         result.creditCost = this.m_creditCost;
         result.currentExpansionLevel = this.m_rewardCreditsBuilding.storageLevel;
         return result;
      }
   }
}

