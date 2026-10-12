package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.GypsyTrader;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.TransactionManager;
   import Managers.BringBackWinterManager;
   import Managers.Crafting.CraftingManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Constants.ZwToggleMode;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ResourcePreviewFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.GypsyTraderWindow;
   import by.blooddy.crypto.MD5;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   
   public class GypsyTraderPlantSlot extends ZwFrame
   {
      
      private static const X:String = "x";
      
      private const CRAFT_BT:String = "craft_bt";
      
      private const PLANT_BT:String = "plant_bt";
      
      private const COUNT_TF:String = "count_tf";
      
      private const BUY_BT:String = "buy_bt";
      
      private const SEND_BT:String = "send_bt";
      
      private var m_featureName:String;
      
      private var m_window:GypsyTraderWindow;
      
      private var m_plantBtn:FarmAnimatedTextButton;
      
      private var m_craftBtn:FarmAnimatedTextButton;
      
      private var m_buyBtn:FarmAnimatedTextButton;
      
      private var m_sentBtn:FarmAnimatedTextButton;
      
      protected var m_iconPreview:ResourcePreviewFrame;
      
      private var m_count:ZwTextField;
      
      private var m_cropIndex:String;
      
      private var m_timeRequestedAt:String;
      
      private const TEXT_HOVER:String = "_onHover_";
      
      public function GypsyTraderPlantSlot(element:DisplayObject, featureName:String, cropIndex:String, window:GypsyTraderWindow)
      {
         var currencyName:String = null;
         var infoTooltip:FarmTextTooltip = null;
         super(element);
         this.m_window = window;
         this.m_featureName = featureName;
         this.m_cropIndex = cropIndex;
         if(element.hasOwnProperty(this.PLANT_BT) && !this.manager.isFeatureEnd())
         {
            addWidget(this.m_plantBtn = new FarmAnimatedTextButton(element[this.PLANT_BT],"Plant",this.onClickPlant));
            this.m_plantBtn.visible = true;
         }
         if(element.hasOwnProperty(this.CRAFT_BT) && !this.manager.isFeatureEnd())
         {
            addWidget(this.m_craftBtn = new FarmAnimatedTextButton(element[this.CRAFT_BT],"Craft",this.onClickCraft));
            this.m_craftBtn.visible = true;
         }
         if(element.hasOwnProperty(this.COUNT_TF))
         {
            addWidget(this.m_count = new ZwTextField(element[this.COUNT_TF],X + this.getCollectionCount()),true);
         }
         if(element.hasOwnProperty(this.BUY_BT))
         {
            addWidget(this.m_buyBtn = new FarmAnimatedTextButton(element[this.BUY_BT],"Buy",this.onClickBuyButton));
            this.m_buyBtn.visible = true;
         }
         if(element.hasOwnProperty(this.SEND_BT) && !this.manager.isFeatureEnd())
         {
            addWidget(this.m_sentBtn = new FarmAnimatedTextButton(element[this.SEND_BT],"Ask Friends",this.onClickAskSendButton),true);
            if(this.manager.canPostSnowFlake(this.manager.getCurrencyCode(this.m_cropIndex)))
            {
               this.m_sentBtn.enabled = true;
            }
            else
            {
               this.disableAskButton();
            }
         }
         if(m_element.hasOwnProperty("icon_mc") && !this.manager.isFeatureEnd())
         {
            currencyName = Global.farmGameSettingsManager.getFarmItemNameByCode(this.manager.getCurrencyCode(this.m_cropIndex));
            infoTooltip = new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_HOVER + currencyName));
            this.m_iconPreview = new ResourcePreviewFrame(m_element.icon_mc);
            addWidget(this.m_iconPreview,true);
            this.m_iconPreview.attachTooltip(infoTooltip);
         }
      }
      
      private function onClickPlant(event:Event) : void
      {
         this.m_window.close();
         UI.displayMiniMarketDialog([GypsyTrader.getCropName(this.m_cropIndex)]);
      }
      
      private function onClickCraft(event:Event) : void
      {
         var currencyItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.manager.getCurrencyCode(this.m_cropIndex));
         CraftingManager.getInstance().openCraftshopWindow(CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType),currencyItem.friendlyTitle,this.m_window,"consumable");
      }
      
      private function onClickBuyButton(event:Event) : void
      {
         this.m_window.tintWindow();
         this.m_window.enableInput = false;
         this.manager.openBuyWindow(this.m_window,this.m_cropIndex);
      }
      
      private function onClickAskSendButton(event:Event) : void
      {
         this.manager.askForCurrency(this.m_cropIndex,this.postFeed);
         this.m_sentBtn.enabled = false;
      }
      
      private function getCollectionCount() : int
      {
         return this.manager.getSfCollectionCount(this.m_cropIndex);
      }
      
      public function refreshCollectionCount() : void
      {
         if(this.m_count)
         {
            this.m_count.text = X + this.getCollectionCount();
         }
      }
      
      private function postFeed(result:Object) : void
      {
         var callBackName:String = null;
         var data:Object = result.data;
         var actionCountKey:String = this.manager.getActionCountKey(result.itemCode);
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
            this.manager.registerFeedPublishSuccess(this.manager.getCurrencyCode(this.m_cropIndex));
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
               TransactionManager.addTransaction(new TGenericTransaction(GypsyTrader.SERVICE_CLASS,BringBackWinterManager.ACTION_RECORD_SNOWFLAKE_ITEM_REQUEST,null,[this.manager.getCurrencyCode(this.m_cropIndex),this.m_timeRequestedAt]));
               this.manager.registerFeedPublishSuccess(this.manager.getCurrencyCode(this.m_cropIndex));
               this.disableAskButton();
            }
            postSuccess = true;
            ExternalInterface.addCallback(result.callBackName,null);
         }
      }
      
      private function disableAskButton() : void
      {
         var timeRemaining:Array = null;
         if(this.m_sentBtn)
         {
            this.m_sentBtn.enabled = false;
            this.m_sentBtn.setToggleMode(ZwToggleMode.SINGLE_SELECT);
            this.m_sentBtn.setToggleState(ZwToggleState.SELECTED);
            this.m_sentBtn.applyGrayOut = true;
            this.m_sentBtn.element.buttonMode = false;
            timeRemaining = this.manager.getTimeUntilPostFeedEnabled(this.manager.getCurrencyCode(this.m_cropIndex));
            this.m_sentBtn.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"asksnowflake_timeleft",{
               "hrs":timeRemaining[1],
               "min":timeRemaining[2]
            })));
         }
      }
      
      private function get manager() : GypsyTrader
      {
         return GypsyTrader.getInstance();
      }
   }
}

