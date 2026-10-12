package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.TransactionManager;
   import Managers.BringBackWinterManager;
   import Managers.CommunityGoalsManager;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Constants.ZwToggleMode;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.BringBackEasterWindow;
   import Widgets.Windows.BringBackWinterBuyWindow;
   import by.blooddy.crypto.MD5;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   
   public class BringBackEasterCollectionSlot extends ZwFrame
   {
      
      private static const X:String = "x";
      
      private static const CRAFTSHOP_CONSUMABLE_TAB:String = "consumable";
      
      private var m_window:BringBackEasterWindow = null;
      
      private var m_sfType:String;
      
      private var m_sfItemCode:String;
      
      private var m_featureName:String;
      
      private var m_data:Object;
      
      private var rewardcount_tf:FarmTextField;
      
      private var m_postBtn:FarmAnimatedTextButton;
      
      private var m_helperBtn:FarmAnimatedTextButton;
      
      private var m_buyBtn:FarmAnimatedTextButton;
      
      private var m_crystal:ZwWidget;
      
      private var m_timeRequestedAt:String;
      
      public function BringBackEasterCollectionSlot(element:DisplayObject, featureName:String, sfType:String, window:BringBackEasterWindow)
      {
         var infoTooltip:FarmTextTooltip = null;
         super(element);
         this.m_window = window;
         this.m_sfType = sfType;
         this.m_featureName = featureName;
         var itemName:String = BringBackWinterManager.getSfTypeToItemName(this.m_sfType);
         this.m_sfItemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(itemName);
         if(element.hasOwnProperty(sfType + "_mc"))
         {
            this.m_crystal = addWidget(new ZwWidget(element[sfType + "_mc"]),true) as ZwWidget;
            infoTooltip = new FarmTextTooltip(ZLocUtils.t("Dialogs",this.m_featureName + "_" + sfType + "_ToolTip"));
            this.m_crystal.attachTooltip(infoTooltip);
         }
         if(element.hasOwnProperty("rewardcount_tf"))
         {
            addWidget(this.rewardcount_tf = new FarmTextField(element["rewardcount_tf"],X + this.getSfCollectionCount()),true) as FarmTextField;
         }
         if(!BringBackWinterManager.getInstance(this.m_featureName).isFeatureEnd())
         {
            if(element.hasOwnProperty("craftpotion_bt"))
            {
               addWidget(this.m_helperBtn = new FarmAnimatedTextButton(element["craftpotion_bt"],ZLocUtils.t("Dialogs","Craft"),this.onCraftClicked),true);
            }
            else if(element.hasOwnProperty("community_bt"))
            {
               addWidget(this.m_helperBtn = new FarmAnimatedTextButton(element["community_bt"],ZLocUtils.t("Dialogs","playCommunityGoals"),this.onViewCommunityGoals));
               this.m_helperBtn.visible = CommunityGoalsManager.getInstance().getActiveTask() ? true : false;
            }
            if(element.hasOwnProperty("post_mc"))
            {
               addWidget(this.m_postBtn = new FarmAnimatedTextButton(element["post_mc"],ZLocUtils.t("Dialogs","Ask"),this.onPostSnowFlake));
               if(BringBackWinterManager.getInstance(this.m_featureName).canPostSnowFlake(this.m_sfItemCode))
               {
                  this.m_postBtn.enabled = true;
               }
               else
               {
                  this.disableAskButton();
               }
            }
            if(element.hasOwnProperty("buy_bt"))
            {
               addWidget(this.m_buyBtn = new FarmAnimatedTextButton(element["buy_bt"],"Buy",this.onClickBuyButton));
               this.m_buyBtn.visible = true;
            }
         }
      }
      
      private function onClickBuyButton(event:Event) : void
      {
         var currencyName:String = null;
         var buyWindow:BringBackWinterBuyWindow = null;
         if(!this.m_window.isFTUEOn())
         {
            currencyName = BringBackWinterManager.getSfTypeToItemName(this.m_sfType);
            buyWindow = new BringBackWinterBuyWindow(BringBackWinterManager.getInstance(this.m_featureName).getRewardDialogPathFor("buy"),this.m_featureName,currencyName,this.m_window,this.resumeWindow);
            UI.displayPopup(buyWindow,false,"",true);
            this.m_window.tintWindow();
            this.m_window.enableInput = false;
            FarmStatsManager.count("GPF_royalrescue2018","Buy_consumable",currencyName);
         }
      }
      
      private function resumeWindow() : void
      {
         this.m_window.untintWindow();
         this.m_window.enableInput = true;
      }
      
      private function onViewCommunityGoals(event:Event) : void
      {
         if(!this.m_window.isFTUEOn())
         {
            this.m_window.close();
            CommunityGoalsManager.getInstance().displayDialog();
         }
      }
      
      private function onPostSnowFlake(event:Event) : void
      {
         if(!this.m_window.isFTUEOn())
         {
            if(!BringBackWinterManager.getInstance(this.m_featureName).isFeatureEnd() && BringBackWinterManager.getInstance(this.m_featureName).canPostSnowFlake(this.m_sfItemCode))
            {
               BringBackWinterManager.getInstance(this.m_featureName).postSf(this.m_sfItemCode,this.postFeed);
               this.m_postBtn.enabled = false;
            }
            FarmStatsManager.count("GPF_royalrescue2018","Ask","click");
         }
      }
      
      private function onCraftClicked(event:Event) : void
      {
         if(!this.m_window.isFTUEOn())
         {
            CraftingManager.getInstance().openCraftshopWindow(CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType),ZLocUtils.t("Dialogs",this.m_featureName + "_" + this.m_sfType + "_ToolTip"),this.m_window,CRAFTSHOP_CONSUMABLE_TAB);
            this.m_window.onMainWindowClose();
            FarmStatsManager.count("GPF_royalrescue2018","Craft","Click");
         }
      }
      
      private function getSfCollectionCount() : int
      {
         return BringBackWinterManager.getInstance(this.m_featureName).getSfCollectionCount(this.m_sfType);
      }
      
      public function refreshCollectionCount() : void
      {
         if(this.rewardcount_tf)
         {
            this.rewardcount_tf.text = X + this.getSfCollectionCount();
         }
      }
      
      private function disableAskButton() : void
      {
         var timeRemaining:Array = null;
         if(this.m_postBtn)
         {
            this.m_postBtn.enabled = false;
            this.m_postBtn.setToggleMode(ZwToggleMode.SINGLE_SELECT);
            this.m_postBtn.setToggleState(ZwToggleState.SELECTED);
            this.m_postBtn.applyGrayOut = true;
            this.m_postBtn.element.buttonMode = false;
            timeRemaining = BringBackWinterManager.getInstance(this.m_featureName).getTimeUntilPostFeedEnabled(this.m_sfItemCode);
            this.m_postBtn.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"asksnowflake_timeleft",{
               "hrs":timeRemaining[1],
               "min":timeRemaining[2]
            })));
         }
      }
      
      private function postFeed(result:Object) : void
      {
         var callBackName:String = null;
         var data:Object = result.data;
         var actionCountKey:String = BringBackWinterManager.getInstance(this.m_featureName).getActionCountKey(result.itemCode);
         if(Boolean(data) && Boolean(data.showFeedDialog))
         {
            if(Boolean(data.attachment) && Boolean(data.actionLink) && Boolean(data.userMessagePrompt))
            {
               this.m_timeRequestedAt = result.ts;
               callBackName = "feedPostCallback";
               try
               {
                  callBackName = "feedPostCallback_" + MD5.hash(data.actionLink[0].href);
               }
               catch(error:Error)
               {
               }
               ExternalInterface.addCallback(callBackName,this.feedPostCallback);
               GlobalEngine.socialNetwork.streamPublish(data.attachment,data.actionLink,null,data.userMessagePrompt);
            }
            else if(Config.DEBUG_MODE)
            {
               ErrorManager.addError("UserMessagePrompt, actionLink or attachment is missing for: " + actionCountKey);
            }
         }
         else if(Boolean(data) && Boolean(data.published))
         {
            BringBackWinterManager.getInstance(this.m_featureName).registerFeedPublishSuccess(this.m_sfItemCode);
            GlobalEngine.socialNetwork.feedPostConfirmation(data);
         }
      }
      
      public function feedPostCallback(result:Object) : void
      {
         var postSuccess:Boolean = false;
         if(Boolean(result.result) && Boolean(result.postId) && Boolean(result.callBackName))
         {
            if(result.result == "posted")
            {
               TransactionManager.addTransaction(new TGenericTransaction(BringBackWinterManager.SERVICE_CLASS,BringBackWinterManager.ACTION_RECORD_SNOWFLAKE_ITEM_REQUEST,null,[this.m_sfItemCode,this.m_timeRequestedAt]));
               BringBackWinterManager.getInstance(this.m_featureName).registerFeedPublishSuccess(this.m_sfItemCode);
            }
            postSuccess = true;
            ExternalInterface.addCallback(result.callBackName,null);
         }
      }
   }
}

