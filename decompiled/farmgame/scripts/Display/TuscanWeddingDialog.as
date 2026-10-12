package Display
{
   import Classes.TuscanWedding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import Transactions.TTradeSubcredits;
   import fl.motion.easing.Quadratic;
   import flash.display.MovieClip;
   import flash.events.Event;
   import gs.TweenLite;
   
   public class TuscanWeddingDialog extends RewardCreditsBuildingDialog
   {
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_TuscanWedding.swf";
      
      protected static const FAVOR_BT:String = "FavorBt";
      
      protected static const TRADE_BT:String = "TradeBt";
      
      protected static const TRADE_BUTTON_ENABLED_FRAME:Number = 1;
      
      protected static const TRADE_BUTTON_DISABLED_FRAME:Number = 4;
      
      protected static const MODE_FAVOR:uint = 2;
      
      private static const NUM_FAVOR_SLOTS:Number = 4;
      
      private static const LOCKED_ITEM_ICON_URL:String = "assets/decorations/tuscanwedding_locked_icon.png";
      
      private static const METER_TWEEN_TIME:Number = 2;
      
      private static const METER_HIGHEST_LEVEL_OFFSET:Number = 14.4;
      
      private static const METER_CREDITS_AT_TOP:uint = 125;
      
      private static const TRADE_ITEM_ICON_HEIGHT:Number = 50;
      
      private static const TRADE_ITEM_ICON_WIDTH:Number = 50;
      
      private static const TRADE_ITEM_ICON_OFFSET_X:Number = 5;
      
      private static const TRADE_ITEM_ICON_OFFSET_Y:Number = -3;
      
      private var m_tradeAmountNeeded:uint = 0;
      
      private var m_tradeInValue:uint = 0;
      
      private var m_meterBarFullHeight:Number = 0;
      
      private var m_isTradePossible:Boolean = false;
      
      public function TuscanWeddingDialog(tuscanWedding:TuscanWedding, showWhatIsThisOnLoad:Boolean = false)
      {
         super(tuscanWedding,"TuscanWedding",DIALOG_ASSET,showWhatIsThisOnLoad);
         this.m_tradeAmountNeeded = Global.farmGameSettingsManager.getInt("tuscanWeddingTradeAmountNeeded",10);
         this.m_tradeInValue = Global.farmGameSettingsManager.getInt("tuscanWeddingTradeInValue",5);
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         this.setupFavorFrame();
      }
      
      override protected function getDefaultMode() : uint
      {
         return MODE_FAVOR;
      }
      
      override protected function getDialogSideIconUrl() : String
      {
         return TuscanWedding.DIALOG_SIDE_ICON;
      }
      
      override protected function getLockedItemIconUrl() : String
      {
         return LOCKED_ITEM_ICON_URL;
      }
      
      override protected function getBuildingCreditsXml() : XML
      {
         return Global.farmGameSettingsManager.getBuildingCreditsXml("tuscanWedding");
      }
      
      override protected function setupButtons() : void
      {
         super.setupButtons();
         var favorButton:GenericButton = new GenericButton(m_window.favor_bt,this.onFavorClick);
         favorButton.text = ZLocUtils.t("Dialogs",m_buildingClassName + "_Favor");
         favorButton.enableHitState(true);
         m_buttons[FAVOR_BT] = favorButton;
         var tradeButton:GenericButton = new GenericButton(m_window.favor_mc.tradeIn_bt,this.onTradeClick);
         var tradeInValue:int = Global.farmGameSettingsManager.getInt("tuscanWeddingTradeInValue",5);
         tradeButton.text = ZLocUtils.t("Dialogs",m_buildingClassName + "_Favor_TradeButton",{"quantity":tradeInValue});
         m_buttons[TRADE_BT] = tradeButton;
      }
      
      override protected function onHowDoesThisWorkClick(event:Event = null) : void
      {
         var msg:String = null;
         if(!m_howDoesThisWorkPopup)
         {
            msg = ZLocUtils.t("Dialogs","TuscanWedding_HowDoesThisWork");
            m_howDoesThisWorkPopup = new GenericPopup(msg,GenericPopup.TYPE_OK,null,GenericPopup.GENERIC_ASSET_LRG,"",true);
            UI.displayPopup(m_howDoesThisWorkPopup,false,m_buildingClassName + "_howDoesThisWorkPopup",true);
         }
      }
      
      override protected function setupCreditsText() : void
      {
         var creditMeter:MovieClip = this.getCreditMeter();
         if(creditMeter)
         {
            creditMeter.currentVal_tf.text = m_currentCredits.toString();
            creditMeter.completion_tf.text = m_totalCreditsReceived.toString();
            creditMeter.spendLabel_tf.text = ZLocUtils.t("Dialogs",m_buildingClassName + "_NumCreditsLabel");
            creditMeter.receivedLabel_tf.text = ZLocUtils.t("Dialogs",m_buildingClassName + "_TotalCreditsReceivedLabel");
         }
      }
      
      override protected function getCreditMeter() : MovieClip
      {
         return m_window.meter_mc as MovieClip;
      }
      
      override protected function adjustFrameAppearance() : void
      {
         var progressButton:GenericButton = m_buttons[PROGRESS_BT] as GenericButton;
         var comparisonButton:GenericButton = m_buttons[COMPARISON_BT] as GenericButton;
         var favorButton:GenericButton = m_buttons[FAVOR_BT] as GenericButton;
         progressButton.state = GenericButton.UPSTATE;
         comparisonButton.state = GenericButton.UPSTATE;
         favorButton.state = GenericButton.UPSTATE;
         setProgressVisibility(false);
         setComparisonVisibility(false);
         this.setFavorVisibility(false);
         this.setMeterVisibility(false);
         if(m_currentMode == MODE_PROGRESS)
         {
            setProgressVisibility(true);
            this.setMeterVisibility(true);
            progressButton.state = GenericButton.HITSTATE;
         }
         else if(m_currentMode == MODE_COMPARISON)
         {
            setComparisonVisibility(true);
            comparisonButton.state = GenericButton.HITSTATE;
            fixArrows();
         }
         else if(m_currentMode == MODE_FAVOR)
         {
            this.setFavorVisibility(true);
            this.setMeterVisibility(true);
            favorButton.state = GenericButton.HITSTATE;
         }
         this.setTradeButtonEnabled(this.m_isTradePossible);
      }
      
      override protected function setupCreditMeter() : void
      {
         var meterMc:MovieClip = this.getCreditMeter();
         var barMc:MovieClip = meterMc.bar_mc;
         this.m_meterBarFullHeight = barMc.height;
         barMc.rotation += 180;
         barMc.x += barMc.width;
         barMc.y += barMc.height;
         super.setupCreditMeter();
         refreshCreditMeter();
      }
      
      override protected function animateMeter() : void
      {
         m_window.meter_mc.bar_mc.height = 0;
         var tweenToHeight:Number = this.calcMeterHeight();
         TweenLite.to(m_window.meter_mc.bar_mc,METER_TWEEN_TIME,{
            "height":tweenToHeight,
            "ease":Quadratic.easeOut
         });
      }
      
      override protected function getNumSlots() : int
      {
         var numSlots:int = 0;
         if(m_currentMode == MODE_FAVOR)
         {
            numSlots = NUM_FAVOR_SLOTS;
         }
         else
         {
            numSlots = super.getNumSlots();
         }
         return numSlots;
      }
      
      override protected function setupTiles() : void
      {
         var index:uint = 0;
         var tile:String = null;
         m_tiles = new Array();
         if(m_currentMode == MODE_FAVOR)
         {
            for(index = 0; index < this.getNumSlots(); index++)
            {
               tile = "itemPanel" + (index + 1) + "_mc";
               if(m_window.favor_mc.hasOwnProperty(tile))
               {
                  m_tiles[index] = m_window.favor_mc.getChildByName(tile);
               }
            }
         }
         else
         {
            super.setupTiles();
         }
      }
      
      override protected function addComponent(compId:int, index:int = 0) : void
      {
         if(Boolean(m_tiles && m_tiles[compId]) && Boolean(m_data) && Boolean(m_data[index + compId]))
         {
            if(m_currentMode == MODE_FAVOR)
            {
               this.addFavorComponent(compId,index);
            }
            else
            {
               super.addComponent(compId,index);
            }
         }
      }
      
      private function addFavorComponent(compId:int, index:int) : void
      {
         var mc:MovieClip = m_tiles[compId] as MovieClip;
         var itemData:Object = m_data[index + compId];
         mc.count_tf.text = ZLocUtils.t("Dialogs",m_buildingClassName + "_Favor_ItemAmounts",{
            "quantity":itemData.currentAmount.toString(),
            "quantityTotal":itemData.amountNeeded.toString()
         });
         mc.count_tf.visible = true;
         addItemIcon(itemData.name,"icon",mc,mc.icon_mc,TRADE_ITEM_ICON_WIDTH,TRADE_ITEM_ICON_HEIGHT,TRADE_ITEM_ICON_OFFSET_X,TRADE_ITEM_ICON_OFFSET_Y);
         var toolTip:ToolTip = new ToolTip();
         toolTip.attachToolTip(mc.icon_mc);
         toolTip.toolTip = ZLocUtils.t("Dialogs",m_buildingClassName + "_" + itemData.name + "_tooltip");
         mc.itemTitle_tf.text = ZLocUtils.tk_pk_asTitle(itemData.friendlyName);
         mc.itemTitle_tf.visible = true;
         mc.visible = true;
      }
      
      override protected function pushNewData() : void
      {
         m_data = [];
         if(m_currentMode == MODE_FAVOR)
         {
            this.pushNewFavorData();
         }
         else
         {
            super.pushNewData();
         }
      }
      
      private function pushNewFavorData() : void
      {
         var subcreditsItemXML:XML = null;
         var subcreditsItemData:Object = null;
         var subcreditsItem:FarmItem = null;
         var creditsXml:XML = this.getBuildingCreditsXml();
         var subcreditsItemsXML:XMLList = new XMLList();
         if(Boolean(creditsXml) && Boolean(creditsXml.subcreditsItem))
         {
            subcreditsItemsXML = creditsXml.subcreditsItem;
         }
         this.m_isTradePossible = true;
         var index:uint = 0;
         while(index < this.getNumSlots() && index < subcreditsItemsXML.length())
         {
            subcreditsItemXML = subcreditsItemsXML[index];
            subcreditsItemData = new Object();
            subcreditsItem = Global.farmGameSettingsManager.getFarmItemByName(subcreditsItemXML.@name.toString());
            if(subcreditsItem)
            {
               subcreditsItemData.name = subcreditsItem.name;
               subcreditsItemData.friendlyName = subcreditsItem.friendlyName;
               subcreditsItemData.icon = subcreditsItem.icon;
            }
            subcreditsItemData.currentAmount = Global.player.getFeatureCredits(subcreditsItemData.name);
            subcreditsItemData.amountNeeded = this.m_tradeAmountNeeded;
            if(subcreditsItemData.currentAmount < subcreditsItemData.amountNeeded)
            {
               this.m_isTradePossible = false;
            }
            m_data.push(subcreditsItemData);
            index++;
         }
      }
      
      private function calcMeterHeight() : Number
      {
         var requiredAmount:Number = NaN;
         var topIntervalHeight:Number = NaN;
         var meterHeight:Number = 0;
         var levels:Array = m_rewardCreditsBuilding.getLevelCredits();
         var levelIntervalHeight:Number = (this.m_meterBarFullHeight - METER_HIGHEST_LEVEL_OFFSET) / levels.length;
         var prevRequiredAmount:Number = 0;
         var isGreaterThanHighestLevel:Boolean = true;
         for(var levelIndex:uint = 0; levelIndex < levels.length; levelIndex++)
         {
            requiredAmount = Number(levels[levelIndex]);
            if(m_totalCreditsReceived <= requiredAmount)
            {
               meterHeight += (m_totalCreditsReceived - prevRequiredAmount) / (requiredAmount - prevRequiredAmount) * levelIntervalHeight;
               isGreaterThanHighestLevel = false;
               break;
            }
            meterHeight += levelIntervalHeight;
            prevRequiredAmount = requiredAmount;
         }
         if(isGreaterThanHighestLevel)
         {
            topIntervalHeight = this.m_meterBarFullHeight - (this.m_meterBarFullHeight - METER_HIGHEST_LEVEL_OFFSET);
            meterHeight += (m_totalCreditsReceived - prevRequiredAmount) / (METER_CREDITS_AT_TOP - prevRequiredAmount) * topIntervalHeight;
         }
         return meterHeight;
      }
      
      private function setFavorVisibility(isVisible:Boolean) : void
      {
         m_window.favor_mc.visible = isVisible;
      }
      
      private function setMeterVisibility(isVisible:Boolean) : void
      {
         m_window.meter_mc.visible = isVisible;
      }
      
      private function onFavorClick(event:Event) : void
      {
         switchMode(MODE_FAVOR);
      }
      
      private function setupFavorFrame() : void
      {
         m_window.favor_mc.npcText_tf.text = ZLocUtils.t("Dialogs","TuscanWedding_Favor_Description");
      }
      
      private function setTradeButtonEnabled(isEnabled:Boolean) : void
      {
         var tradeButtonMc:MovieClip = m_window.favor_mc.tradeIn_bt;
         var tradeButton:GenericButton = m_buttons[TRADE_BT];
         if(isEnabled)
         {
            tradeButtonMc.gotoAndStop(TRADE_BUTTON_ENABLED_FRAME);
            Utilities.toggleInputOnlySelf(tradeButtonMc,true);
            tradeButton.turnOn();
         }
         else
         {
            tradeButtonMc.gotoAndStop(TRADE_BUTTON_DISABLED_FRAME);
            Utilities.toggleInputOnlySelf(tradeButtonMc,false);
            tradeButton.turnOff(true);
         }
      }
      
      private function onTradeClick(event:Event) : void
      {
         var message:String = ZLocUtils.t("Dialogs","TuscanWedding_TradeConfirm",{
            "quantity":this.m_tradeAmountNeeded,
            "quantityFavor":this.m_tradeInValue
         });
         UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmTrade,"",true);
      }
      
      private function onConfirmTrade(event:GenericPopupEvent) : void
      {
         var creditsXml:XML = null;
         var subcreditsItemsXML:XMLList = null;
         var index:uint = 0;
         var transaction:TTradeSubcredits = null;
         var subcreditsItemXML:XML = null;
         var subcreditsItemName:String = null;
         if(GenericPopup.ACCEPT == event.button)
         {
            creditsXml = this.getBuildingCreditsXml();
            subcreditsItemsXML = new XMLList();
            if(Boolean(creditsXml) && Boolean(creditsXml.subcreditsItem))
            {
               subcreditsItemsXML = creditsXml.subcreditsItem;
            }
            for(index = 0; index < subcreditsItemsXML.length(); index++)
            {
               subcreditsItemXML = subcreditsItemsXML[index];
               if(Boolean(subcreditsItemXML.@needForTrade) && subcreditsItemXML.@needForTrade.toString() == "true")
               {
                  subcreditsItemName = subcreditsItemXML.@name.toString();
                  Global.player.useFeatureCredits(subcreditsItemName,this.m_tradeAmountNeeded);
               }
            }
            Global.player.addFeatureCredits(m_rewardCreditsBuilding.getCreditsFeatureName(),Global.farmGameSettingsManager.getInt("tuscanWeddingTradeInValue",5));
            m_totalCreditsReceived = m_rewardCreditsBuilding.getTotalCreditsReceived();
            switchMode(m_currentMode);
            super.setupCreditMeter();
            refreshCreditMeter();
            transaction = new TTradeSubcredits(m_rewardCreditsBuilding);
            TransactionManager.addTransaction(transaction,true);
            onClose();
         }
      }
   }
}

