package Widgets.Windows.Market
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmGameSettingsManager;
   import Managers.MarketStatsManager;
   import Replay.ArrayUtils;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Market.MarketSlotCashBuyFrame;
   import Widgets.Frames.Market.MarketSlotCoinBuyFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Slots.Market.MarketSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class MarketPreviewWindow extends FarmWindow
   {
      
      public static const ZOOM_LEVELS:Array = new Array(2,1.434,0.868,0.585);
      
      public static const ZOOM_WIDTHS:Array = new Array(260,300,320,330);
      
      private static const ZOOM_LEVEL_SUFFIX:String = "_zoomLevels_mc";
      
      private static var m_marketPreviewActive:Boolean = false;
      
      protected var mSpinnerMaxValue:int = 99;
      
      protected const SPINNER_MIN_VALUE:int = 1;
      
      protected var m_item:FarmItem = null;
      
      private var m_buyCashFrame:MarketSlotCashBuyFrame;
      
      private var m_buyCoinFrame:MarketSlotCoinBuyFrame;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_callbacks:Object;
      
      protected var m_isMiniSlotRequest:Boolean = false;
      
      protected var m_showExtraLEInfo:Boolean = false;
      
      protected var m_showQuantity:Boolean = false;
      
      private var m_infoBubble:ZwFrame;
      
      private var m_quantityTextField:ZwTextField;
      
      private var m_timer:Timer;
      
      private var m_timerTextField:ZwTextField;
      
      private var m_zoomElementName:String = "land_zoomLevels_mc";
      
      private var m_marketSlot:MarketSlot = null;
      
      public function MarketPreviewWindow(item:FarmItem, callbacks:Object, isMiniSlotRequest:Boolean = false, showExtraLEInfo:Boolean = false, showQuantity:Boolean = false, terrainCodes:Array = null, marketSlot:MarketSlot = null)
      {
         var itemTerrainCodes:Array = null;
         this.m_item = item;
         this.m_callbacks = callbacks;
         this.m_isMiniSlotRequest = isMiniSlotRequest;
         this.m_showExtraLEInfo = showExtraLEInfo;
         this.m_showQuantity = showQuantity;
         this.m_marketSlot = marketSlot;
         super("assets/dialogs/FV_xal_Market_previewWindow_v3.swf",true,true);
         if(terrainCodes != null && terrainCodes.length > 0)
         {
            itemTerrainCodes = this.m_item.getTerrainCodes();
            terrainCodes = ArrayUtils.intersection(terrainCodes,itemTerrainCodes);
         }
         else
         {
            terrainCodes = this.m_item.getTerrainCodes();
         }
         var terrainName:String = Global.farmGameSettingsManager.selectPrimaryTerrainNameFromGivenCodes(terrainCodes);
         if(terrainName != null && terrainName != "")
         {
            this.m_zoomElementName = terrainName + ZOOM_LEVEL_SUFFIX;
         }
      }
      
      public static function get marketPreviewActive() : Boolean
      {
         return m_marketPreviewActive;
      }
      
      public static function set marketPreviewActive(active:Boolean) : void
      {
         m_marketPreviewActive = active;
      }
      
      override protected function postLoadComplete() : void
      {
         var itemInfoText:String = null;
         marketPreviewActive = true;
         addWidget(new ObjectPreviewFrame(m_window.loader_mc,this.m_item,this.setBackground,ZOOM_LEVELS,ZOOM_WIDTHS));
         m_window.loader_mc.visible = true;
         this.m_nameTextField = addWidget(new ZwTextField(m_window.generic_tf)) as ZwTextField;
         this.m_nameTextField.text = ZLocUtils.tk_pk_asTitle(this.m_item.friendlyName);
         this.m_nameTextField.visible = true;
         this.m_buyCashFrame = addWidget(new MarketSlotCashBuyFrame(m_window.buyCash_mc,this.onCallbackButtonClick)) as MarketSlotCashBuyFrame;
         this.m_buyCoinFrame = addWidget(new MarketSlotCoinBuyFrame(m_window.buyCoin_mc,this.onCallbackButtonClick)) as MarketSlotCoinBuyFrame;
         this.m_buyCoinFrame.resetLockStates();
         if(this.m_showExtraLEInfo)
         {
            itemInfoText = "";
            this.m_infoBubble = new ZwFrame(m_window.infoBubble_mc);
            addWidget(this.m_infoBubble);
            itemInfoText = this.getItemInfoText();
            this.m_infoBubble.addWidget(new ZwTextField(m_window.infoBubble_mc.info_tf,itemInfoText,true));
            this.m_timerTextField = new ZwTextField(m_window.infoBubble_mc.timer_tf,"");
            this.m_infoBubble.addWidget(this.m_timerTextField);
            if(this.m_item.isLimitedItem())
            {
               this.refreshTimerTextField();
            }
            else
            {
               if(this.m_timer != null)
               {
                  this.m_timer.stop();
               }
               if(itemInfoText == "")
               {
                  this.m_infoBubble.visible = false;
               }
            }
         }
         if(this.m_showQuantity)
         {
            addWidget(new ZwFrame(m_window.quantity_mc));
            this.m_quantityTextField = new ZwTextField(m_window.quantity_mc.input_tf,"1");
            this.m_quantityTextField.selectable = false;
            this.m_quantityTextField.enabled = false;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               if(this.m_item.hasPropertyInDataSource("limit"))
               {
                  this.mSpinnerMaxValue = this.m_item.getIntFromDataSource("limit");
               }
            }
            else if(this.m_item.xml.hasOwnProperty("limit"))
            {
               this.mSpinnerMaxValue = this.m_item.xml.limit;
            }
            addWidget(this.m_quantityTextField);
            addWidget(new ZwButton(m_window.quantity_mc.arrowUp_bt,this.onUpArrowClick));
            addWidget(new ZwButton(m_window.quantity_mc.arrowDown_bt,this.onDownArrowClick));
         }
         this.updateCostFields();
         m_window[this.m_zoomElementName].visible = true;
         super.postLoadComplete();
      }
      
      private function conditionallyRefreshBuyButtonsBasedOnMarketSlot() : void
      {
         if(this.m_marketSlot != null)
         {
            this.m_buyCashFrame.visible = this.m_marketSlot.buyCashFrame.visible;
            this.m_buyCoinFrame.visible = this.m_marketSlot.buyCoinFrame.visible;
         }
      }
      
      private function setIsSendableQuantity(enable:Boolean) : void
      {
         this.m_buyCashFrame.setIsSendableQuantity(enable);
      }
      
      private function isSendableQuantity() : Boolean
      {
         return this.m_buyCashFrame.getIsSendableQuantity();
      }
      
      private function getItemInfoText() : String
      {
         var coinYield:Number = NaN;
         var harvestTime:Number = NaN;
         var harvestLocStr:String = null;
         var harvestLocObj:Object = null;
         var dayInSeconds:Number = NaN;
         var info:Array = new Array();
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            coinYield = this.m_item.getNumberFromDataSource("coinYield");
            harvestTime = this.m_item.getNumberFromDataSource("growTime");
         }
         else
         {
            coinYield = Number(this.m_item.xml.coinYield);
            harvestTime = Number(this.m_item.xml.growTime);
         }
         if(coinYield > 0)
         {
            info.push(ZLocUtils.t("Dialogs","Yield",{
               "coinQuantity":coinYield,
               "Coin_word":ZLocUtils.tk("Dialogs","Coin_word","",coinYield)
            }));
         }
         else if(this.m_item.sellPrice > 0)
         {
            info.push(ZLocUtils.t("Dialogs","Yield",{
               "coinQuantity":this.m_item.sellPrice,
               "Coin_word":ZLocUtils.tk("Dialogs","Coin_word","",this.m_item.sellPrice)
            }));
         }
         if(harvestTime > 0)
         {
            harvestLocStr = "";
            harvestLocObj = {};
            if(harvestTime < 1)
            {
               dayInSeconds = Global.farmGameSettingsManager.getNumber("inGameDaySeconds");
               harvestTime = dayInSeconds / 60 / 60 * harvestTime;
               harvestLocStr = "GrowthHours";
               harvestLocObj.quantity = harvestTime;
               harvestLocObj.Hour_word = ZLocUtils.tk("Dialogs","Hour_word","",harvestLocObj.quantity);
            }
            else
            {
               harvestLocStr = "GrowthDays";
               harvestLocObj.quantity = harvestTime;
               harvestLocObj.Day_word = ZLocUtils.tk("Dialogs","Day_word","",harvestLocObj.quantity);
            }
            info.push(ZLocUtils.t("Dialogs",harvestLocStr,harvestLocObj));
         }
         if(this.m_item.plantXp > 0)
         {
            info.push(ZLocUtils.t("Dialogs","XPGained",{"quantity":this.m_item.plantXp}));
         }
         else if(this.m_item.xpGained > 0)
         {
            info.push(ZLocUtils.t("Dialogs","XPGained",{"quantity":this.m_item.xpGained}));
         }
         return info.join("\n");
      }
      
      private function refreshTimerTextField() : void
      {
         var formattedTime:String = "";
         var limitedTimeLeft:Number = this.m_item.limitedTimeLeft;
         var parsedTime:Array = FarmGameUtil.parseTimeLeft(limitedTimeLeft / 1000);
         if(parsedTime[0] > 0)
         {
            formattedTime = ZLocUtils.t("FarmGame","General_FriendlyTimeDays",{"days":parsedTime[0]});
         }
         else
         {
            formattedTime = parsedTime[1] + ":" + FarmGameUtil.numberToStringPadZeros(parsedTime[2]) + ":" + FarmGameUtil.numberToStringPadZeros(parsedTime[3]);
         }
         formattedTime = ZLocUtils.t("Dialogs","TimeLeftSuffix",{"timeStr":formattedTime});
         this.m_timerTextField.text = formattedTime;
         if(limitedTimeLeft < 0)
         {
            this.m_timerTextField.visible = false;
         }
         else
         {
            this.m_timerTextField.visible = true;
         }
         if(parsedTime[0] <= 0)
         {
            if(this.m_timer == null)
            {
               this.m_timer = new Timer(1000);
               this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer,false,0,true);
            }
            if(!this.m_timer.running)
            {
               this.m_timer.start();
            }
         }
         else if(this.m_timer != null)
         {
            this.m_timer.stop();
         }
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         this.refreshTimerTextField();
      }
      
      private function onCallbackButtonClick(evt:MouseEvent) : void
      {
         var callbackName:String = null;
         var callback:Function = null;
         var callbackButton:MovieClip = evt.target as MovieClip;
         var shouldClose:Boolean = false;
         switch(callbackButton)
         {
            case this.m_buyCashFrame.buyButton.element:
               callbackName = MarketWindow.CALLBACK_BUY_CASH;
               shouldClose = true;
               if(this.m_isMiniSlotRequest)
               {
                  MarketStatsManager.countClickMarketMiniPreviewBuy();
               }
               break;
            case this.m_buyCashFrame.sendButton.element:
               if(this.isSendableQuantity())
               {
                  callbackName = MarketWindow.CALLBACK_SEND;
                  shouldClose = true;
               }
               break;
            case this.m_buyCoinFrame.buyButton.element:
               callbackName = MarketWindow.CALLBACK_BUY_COIN;
               shouldClose = true;
               if(this.m_isMiniSlotRequest)
               {
                  MarketStatsManager.countClickMarketMiniPreviewBuy();
               }
               break;
            case this.m_buyCoinFrame.actionButton.element:
               callbackName = MarketWindow.CALLBACK_UNLOCK;
         }
         if(callbackName)
         {
            callback = this.m_callbacks[callbackName] as Function;
            if(callback != null)
            {
               callback(this.m_item,this.quantityOfItemsToPurchase());
            }
         }
         if(shouldClose)
         {
            this.close();
         }
      }
      
      public function setBackground(level:int) : void
      {
         var zoomElement:MovieClip = null;
         if(Boolean(m_window) && Boolean(this.m_zoomElementName))
         {
            zoomElement = m_window[this.m_zoomElementName] as MovieClip;
            if(Boolean(zoomElement) && level < zoomElement.totalFrames)
            {
               zoomElement.gotoAndStop(level);
            }
         }
      }
      
      override protected function release() : void
      {
         if(this.m_timer != null)
         {
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
         }
         this.m_timer = null;
         this.m_quantityTextField = null;
         this.m_timerTextField = null;
         this.m_item = null;
         super.release();
      }
      
      override public function close() : void
      {
         super.close();
         marketPreviewActive = false;
         var callback:Function = this.m_callbacks[MarketWindow.CALLBACK_CLOSE] as Function;
         if(callback != null)
         {
            callback();
         }
      }
      
      private function onUpArrowClick(e:MouseEvent) : void
      {
         var currentQuantitySelected:int = this.quantityOfItemsToPurchase();
         var amount:int = currentQuantitySelected + 1 <= this.mSpinnerMaxValue ? int(currentQuantitySelected + 1) : this.mSpinnerMaxValue;
         this.m_quantityTextField.text = String(amount);
         this.updateCostFields();
      }
      
      private function onDownArrowClick(e:MouseEvent) : void
      {
         var currentQuantitySelected:int = this.quantityOfItemsToPurchase();
         var amount:int = currentQuantitySelected - 1 > this.SPINNER_MIN_VALUE ? int(currentQuantitySelected - 1) : this.SPINNER_MIN_VALUE;
         this.m_quantityTextField.text = String(amount);
         this.updateCostFields();
      }
      
      private function updateCostFields() : void
      {
         if(this.m_item.isGameToken)
         {
            this.m_buyCashFrame.visible = false;
            this.m_buyCoinFrame.visible = false;
         }
         else
         {
            if(MarketWindow.isItemRedeemable(this.m_item))
            {
               this.m_buyCashFrame.sendable = false;
               this.m_buyCashFrame.redeemable = true;
               this.m_buyCashFrame.cost = 0;
            }
            else if(this.m_item.buyableWithCash())
            {
               this.m_buyCashFrame.cost = Number(this.m_item.realCashCost) * this.quantityOfItemsToPurchase();
               this.m_buyCashFrame.visible = true;
               this.m_buyCashFrame.sendable = MarketWindow.isItemSendable(this.m_item);
               this.m_buyCashFrame.setupLockState(this.m_item,true);
            }
            else
            {
               this.m_buyCashFrame.visible = false;
            }
            if(this.m_item.buyableWithCurrency())
            {
               this.m_buyCoinFrame.currencyType = this.m_item.market;
               this.m_buyCoinFrame.cost = Number(this.m_item.cost) * this.quantityOfItemsToPurchase();
               this.m_buyCoinFrame.visible = true;
               this.m_buyCoinFrame.setupLockState(this.m_item,true);
            }
            else
            {
               this.m_buyCoinFrame.visible = false;
            }
            this.conditionallyRefreshBuyButtonsBasedOnMarketSlot();
         }
         this.setIsSendableQuantity(this.quantityOfItemsToPurchase() == 1);
      }
      
      public function quantityOfItemsToPurchase() : int
      {
         var quantity:Number = 1;
         if(this.m_quantityTextField != null)
         {
            quantity = int(this.m_quantityTextField.text);
         }
         return quantity;
      }
      
      private function displayQuantity(value:int) : void
      {
         if(this.m_quantityTextField != null)
         {
            this.m_quantityTextField.text = String(value);
         }
      }
   }
}

