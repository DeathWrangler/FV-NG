package Widgets.Slots.Trading
{
   import Classes.Mastery;
   import Classes.Trading.TradingGood;
   import Classes.Trading.TradingPostConstants;
   import Classes.Trading.TradingPostManager;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.HarvestableItem;
   import Classes.util.ZLocUtils;
   import Engine.Constants;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.Market.MarketSlotMasteryFrame;
   import Widgets.Frames.Trading.TradingPostGoodSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   
   public class TradingPostGoodSlot extends ZwSlotFrame
   {
      
      public var m_tradingGood:TradingGood = null;
      
      private var m_item:FarmItem = null;
      
      private var m_toolTipWidget:ZwFrame = null;
      
      private var m_toolTipWidgetBig:ZwFrame = null;
      
      private var m_costText:FarmTextField = null;
      
      private var m_itemNameText:FarmTextField = null;
      
      private var m_xpGainedText:FarmTextField = null;
      
      private var m_coinImage:ZwFrame = null;
      
      private var m_xpImage:ZwFrame = null;
      
      private var m_masteryFrame:MarketSlotMasteryFrame = null;
      
      private var m_boxFrame:ZwFrame = null;
      
      private var m_statusText:FarmTextField = null;
      
      private var m_itemIcon:FarmIcon = null;
      
      private var m_parentFrame:TradingPostGoodSlotFrame = null;
      
      private var m_canOrderResult:Object = {};
      
      private var m_canBuyResult:Object = {};
      
      private var m_defaultButton:FarmAnimatedTextButton = null;
      
      private var m_claimButton:FarmAnimatedTextButton = null;
      
      private var m_glowFilter:GlowFilter = new GlowFilter(Constants.COLOR_HIGHLIGHT,1,5,5,30);
      
      public function TradingPostGoodSlot(element:DisplayObject, parentFrame:TradingPostGoodSlotFrame)
      {
         this.m_parentFrame = parentFrame;
         super(element);
         this.m_toolTipWidgetBig = addWidget(new ZwFrame(m_element.tooltipBG_mc)) as ZwFrame;
         this.m_toolTipWidget = addWidget(new ZwFrame(m_element.tooltip_mc)) as ZwFrame;
         this.m_itemNameText = addWidget(new FarmTextField(m_element.tooltip_mc.generic1_tf)) as FarmTextField;
         this.m_defaultButton = addWidget(new FarmAnimatedTextButton(m_element.get_bt,ZLocUtils.t("Dialogs","tradingpost_slot_buy"),this.onClick)) as FarmAnimatedTextButton;
         this.m_claimButton = addWidget(new FarmAnimatedTextButton(m_element.claim_bt,ZLocUtils.t("Dialogs","tradingpost_slot_buy"),this.onClick)) as FarmAnimatedTextButton;
         this.m_statusText = this.m_toolTipWidget.addWidget(new FarmTextField(m_element.status_tf,ZLocUtils.t("Dialogs","tradingpost_slot_status"))) as FarmTextField;
         this.m_boxFrame = addWidget(new ZwFrame(m_element.box_mc)) as ZwFrame;
         this.m_xpGainedText = this.m_toolTipWidget.addWidget(new FarmTextField(m_element.tooltip_mc.generic_tf,"",true)) as FarmTextField;
         this.m_costText = this.m_toolTipWidget.addWidget(new FarmTextField(m_element.tooltip_mc.cost_tf,"",true)) as FarmTextField;
         this.m_coinImage = this.m_toolTipWidget.addWidget(new ZwFrame(m_element.tooltip_mc.coin_mc)) as ZwFrame;
         this.m_xpImage = this.m_toolTipWidget.addWidget(new ZwFrame(m_element.tooltip_mc.xp_mc)) as ZwFrame;
         this.m_masteryFrame = addWidget(new MarketSlotMasteryFrame(m_element.mastery_mc)) as MarketSlotMasteryFrame;
         this.m_itemIcon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_itemIcon.setIconSize(50,50);
         this.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         this.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
      }
      
      override public function populate(data:Object) : void
      {
         var xpGained:Number = NaN;
         var mastery:Mastery = null;
         this.m_tradingGood = data as TradingGood;
         this.m_canOrderResult = {};
         this.m_canBuyResult = {};
         if(null != this.m_tradingGood)
         {
            this.m_item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_tradingGood.itemCode);
            if(null != this.m_item)
            {
               this.m_itemIcon.loadIcon(this.m_item.icon);
               this.m_itemIcon.visible = true;
               this.m_itemIcon.alpha = 100;
               this.m_boxFrame.visible = false;
               (this.m_itemIcon.element as DisplayObject).filters = [];
               this.m_itemNameText.visible = true;
               this.m_itemNameText.text = ZLocUtils.tk_pk_asTitle(this.m_item.friendlyName);
               TradingPostManager.getInstance().updateTradingGoodState(this.m_tradingGood);
               this.m_defaultButton.detachTooltip();
               this.m_defaultButton.applyGrayOut = false;
               this.m_claimButton.detachTooltip();
               this.m_claimButton.applyGrayOut = false;
               if(this.m_tradingGood.goodStatusType == TradingGood.FOR_SALE)
               {
                  this.m_claimButton.text = ZLocUtils.t("Dialogs","tradingpost_slot_buy");
                  this.m_claimButton.visible = true;
                  this.m_defaultButton.visible = false;
                  this.m_canBuyResult = TradingPostManager.getInstance().canBuyFromUser(this.m_tradingGood.sellingUid);
                  if(!this.m_canBuyResult.canBuy)
                  {
                     this.m_claimButton.attachTooltip(new FarmTextTooltip(this.m_canBuyResult.locText));
                     this.m_claimButton.applyGrayOut = true;
                  }
               }
               else if(this.m_tradingGood.goodStatusType == TradingGood.FOR_ORDER)
               {
                  this.m_defaultButton.text = ZLocUtils.t("Dialogs","tradingpost_slot_order");
                  this.m_claimButton.visible = false;
                  this.m_defaultButton.visible = true;
                  this.m_canOrderResult = TradingPostManager.getInstance().canOrderFromUser(this.m_tradingGood.sellingUid);
                  if(!this.m_canOrderResult.canBeOrdered)
                  {
                     this.m_defaultButton.attachTooltip(new FarmTextTooltip(this.m_canOrderResult.locText));
                     this.m_defaultButton.applyGrayOut = true;
                  }
               }
               else if(this.m_tradingGood.goodStatusType == TradingGood.FOR_CLAIM)
               {
                  this.m_claimButton.text = ZLocUtils.t("Dialogs","tradingpost_slot_claim");
                  this.m_claimButton.visible = true;
                  this.m_defaultButton.visible = false;
                  this.m_boxFrame.visible = true;
                  this.m_itemIcon.visible = false;
                  this.m_canBuyResult = TradingPostManager.getInstance().canBuyFromUser(this.m_tradingGood.sellingUid);
                  if(!this.m_canBuyResult.canBuy)
                  {
                     this.m_claimButton.attachTooltip(new FarmTextTooltip(this.m_canBuyResult.locText));
                     this.m_claimButton.applyGrayOut = true;
                  }
               }
               else if(this.m_tradingGood.goodStatusType == TradingGood.ORDER_REMIND)
               {
                  this.m_defaultButton.text = ZLocUtils.t("Dialogs","tradingpost_slot_remind");
                  this.m_claimButton.visible = false;
                  this.m_defaultButton.visible = true;
               }
               if(this.m_tradingGood.goodStatusType == TradingGood.ORDER_TAKEN)
               {
                  this.m_claimButton.visible = false;
                  this.m_defaultButton.visible = false;
                  this.m_statusText.visible = true;
                  this.m_itemIcon.alpha = 0.5;
               }
               else
               {
                  this.m_statusText.visible = false;
               }
               this.m_costText.text = "<font color=\'#BB0000\'>-" + String(this.m_item.cost) + "</font>";
               xpGained = TradingPostManager.getInstance().getConfigAttr(TradingPostConstants.SETTINGS_TYPE_CROP,"buyerRewardXpMultiplier");
               xpGained *= this.m_item.plantXp;
               this.m_xpGainedText.text = "<font color=\'#009922\'>+" + String(xpGained) + "</font>";
               if(this.m_item is HarvestableItem)
               {
                  mastery = (this.m_item as HarvestableItem).mastery;
                  this.m_masteryFrame.update(mastery.currentLevel + 1,mastery.currentProgress,mastery.totalCropsNeeded);
                  this.m_masteryFrame.visible = true;
               }
            }
         }
         else
         {
            this.visible = false;
            this.m_statusText.visible = false;
         }
      }
      
      override public function release() : void
      {
         this.m_tradingGood = null;
         this.m_item = null;
         this.m_costText = null;
         this.m_xpGainedText = null;
         this.m_masteryFrame = null;
         this.m_statusText = null;
         this.m_itemIcon = null;
         this.m_claimButton = null;
         this.m_defaultButton = null;
         this.m_boxFrame = null;
         this.m_xpImage = null;
         this.m_toolTipWidgetBig = null;
         this.m_toolTipWidget = null;
         this.unregisterEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         this.unregisterEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         super.release();
      }
      
      protected function onMouseOver(event:MouseEvent) : void
      {
         if(null != this.m_tradingGood)
         {
            this.m_toolTipWidget.visible = true;
            this.m_toolTipWidgetBig.visible = true;
            this.m_itemIcon.alpha = 0.15;
            this.m_boxFrame.alpha = 0.15;
         }
      }
      
      protected function onMouseOut(event:MouseEvent) : void
      {
         this.m_toolTipWidget.visible = false;
         this.m_toolTipWidgetBig.visible = false;
         this.m_itemIcon.alpha = 1;
         this.m_boxFrame.alpha = 1;
      }
      
      private function onClick(event:MouseEvent) : void
      {
         if(this.m_tradingGood.goodStatusType == TradingGood.FOR_SALE || this.m_tradingGood.goodStatusType == TradingGood.FOR_CLAIM)
         {
            this.onBuy();
         }
         else if(this.m_tradingGood.goodStatusType == TradingGood.FOR_ORDER)
         {
            this.onOrder();
         }
         else if(this.m_tradingGood.goodStatusType == TradingGood.ORDER_REMIND)
         {
            this.onRemind();
         }
      }
      
      private function onOrder() : void
      {
         if(this.m_canOrderResult != null && Boolean(this.m_canOrderResult.canBeOrdered))
         {
            TradingPostManager.getInstance().orderGood(this.m_tradingGood);
            this.m_parentFrame.refresh();
            TradingPostManager.getInstance().postOrderGoodFeed(this.m_tradingGood,this.m_itemIcon.icon);
         }
      }
      
      private function onBuy() : void
      {
         var rewardData:Object = null;
         if(this.m_canBuyResult != null && Boolean(this.m_canBuyResult.canBuy))
         {
            rewardData = TradingPostManager.getInstance().buyGood(this.m_tradingGood);
            this.m_parentFrame.refresh();
         }
      }
      
      private function onRemind() : void
      {
         if(!TradingPostManager.getInstance().hasAutoPublishPermissions() && !Global.player.getSeenSessionFlag(TradingPostConstants.SEEN_TRADING_POST_EXT_PERMISSIONS))
         {
            TradingPostManager.getInstance().showFeatureAutoPublishDialog(this.onRemind);
         }
         else
         {
            TradingPostManager.getInstance().remindFriend(this.m_tradingGood);
            this.m_parentFrame.refresh();
         }
      }
   }
}

