package Widgets.Slots
{
   import Classes.CraftingBasket;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.OrderBoard.FrontierInnovationManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FrontierInnovationBarnWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class FrontierInnovationBasicLuxuryTaskSlot extends ZwSlotFrame
   {
      
      private static const OFFSET_OPF_Y:int = -20;
      
      private static const ICON_SIZE:int = 100;
      
      private var m_basketName:String;
      
      private var m_data:Object;
      
      private var m_shouldShowCheckMark:Boolean = false;
      
      private var m_shouldShowCommonBg:Boolean = false;
      
      private var m_callbacks:Object;
      
      private var m_countTextField:ZwTextField = null;
      
      private var m_buyButton:FarmAnimatedCashButton = null;
      
      private var m_redeemButton:FarmAnimatedTextButton = null;
      
      private var m_objectPreviewFrame:ObjectPreviewFrame = null;
      
      protected var m_iconPreview:FarmIcon;
      
      private var m_checkMark:ZwWidget;
      
      private var m_rewardBg:ZwWidget;
      
      private var m_commonRewardBg:ZwWidget;
      
      private var infoTooltip:FarmTextTooltip;
      
      private var m_checkmark:MovieClip;
      
      private var m_iconMc:FarmIcon;
      
      private var m_countTf:ZwTextField;
      
      private var m_selectTf:ZwTextField;
      
      private var m_hoverMc:ZwFrame;
      
      private var m_discardBt:FarmAnimatedTextButton;
      
      private var m_tradeBt:FarmAnimatedTextButton;
      
      private var m_overlayMc:MovieClip;
      
      private var m_sinkHoverTooltip:FarmTextTooltip;
      
      private const HOVER_MC:String = "hover_mc";
      
      private const ICON_MC:String = "icon_mc";
      
      private const COUNT_TF:String = "count_tf";
      
      private const CHECKMARK_MC:String = "checkmark_mc";
      
      private const SELECT_TF:String = "select_tf";
      
      private const OVERLAY_MC:String = "overlay_mc";
      
      private const EMPTY_SLOT:int = -1;
      
      internal var manager:FrontierInnovationManager;
      
      private var m_featureName:String;
      
      private var m_slotName:String;
      
      private var m_slotNumber:int;
      
      private var m_frameName:String;
      
      private var m_slotResourceName:String;
      
      private var m_resourceCount:int;
      
      private var m_item:FarmItem;
      
      private var m_window:FrontierInnovationBarnWindow;
      
      public function FrontierInnovationBasicLuxuryTaskSlot(featureName:String, element:DisplayObject, window:FrontierInnovationBarnWindow)
      {
         this.m_featureName = featureName;
         this.m_window = window;
         this.manager = FrontierInnovationManager.getInstance(featureName);
         super(element);
         this.m_slotName = m_element.name;
         this.m_frameName = m_element.parent.name;
         this.m_slotNumber = this.m_window.getSlotNumber(this.m_slotName);
         m_element.addEventListener(MouseEvent.MOUSE_OVER,this.onTileMouseRollOver);
         m_element.addEventListener(MouseEvent.MOUSE_OUT,this.onTileMouseRollOut);
         if(m_element.hasOwnProperty(this.ICON_MC))
         {
            addWidget(this.m_iconMc = new FarmIcon(m_element[this.ICON_MC]));
            this.m_iconMc.visible = true;
         }
         if(m_element.hasOwnProperty(this.COUNT_TF))
         {
            this.m_countTf = new ZwTextField(m_element[this.COUNT_TF]);
            this.m_countTf.visible = true;
         }
         if(m_element.hasOwnProperty(this.HOVER_MC))
         {
            this.m_hoverMc = new ZwFrame(m_element[this.HOVER_MC]) as ZwFrame;
            this.m_sinkHoverTooltip = new FarmTextTooltip(this.manager.getTradePostFullMessage());
            if(m_element.hover_mc.discard_bt)
            {
               this.m_discardBt = this.m_hoverMc.addWidget(new FarmAnimatedTextButton(m_element.hover_mc.discard_bt,"Discard!",this.onDiscardClick)) as FarmAnimatedTextButton;
            }
            if(m_element.hover_mc.trade_bt)
            {
               this.m_tradeBt = this.m_hoverMc.addWidget(new FarmAnimatedTextButton(m_element.hover_mc.trade_bt,"Trade!",this.onTradeClick)) as FarmAnimatedTextButton;
            }
         }
      }
      
      public function loadSlot() : void
      {
         if(this.m_hoverMc.hasOwnProperty("discard_bt"))
         {
            addWidget(this.m_discardBt = new FarmAnimatedTextButton(this.m_hoverMc["discard_bt"],"Discard!",this.onDiscardClick));
         }
         if(this.m_hoverMc.hasOwnProperty("trade_bt"))
         {
            addWidget(this.m_tradeBt = new FarmAnimatedTextButton(this.m_hoverMc["trade_bt"],"Trade!",this.onTradeClick));
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_countTf.text = "x" + data["Count"];
         this.m_slotResourceName = data["resourceCode"].toString();
         this.m_countTf.visible = true;
         this.m_item = Global.farmGameSettingsManager.getFarmItemByCode(data["resourceCode"]);
         this.m_iconMc.loadIcon(this.m_item.icon);
         this.m_iconMc.setIconSize(70,70);
         var itemHoverTooltip:FarmTextTooltip = new FarmTextTooltip(this.m_item.friendlyTitle);
         this.m_iconMc.attachTooltip(itemHoverTooltip);
         this.m_iconMc.visible = true;
         this.m_resourceCount = int(data["Count"]);
      }
      
      private function onTileMouseRollOver(e:MouseEvent) : void
      {
         var tradePostCount:String = this.manager.getTradePostSlotCount();
         var value:Array = tradePostCount.split("/");
         this.m_hoverMc.visible = true;
         if(this.m_resourceCount != 0 && value[0] != value[1])
         {
            this.m_discardBt.visible = true;
            this.m_discardBt.enabled = true;
            this.m_tradeBt.visible = true;
            this.m_tradeBt.enabled = true;
         }
         else if(this.m_resourceCount != 0 && value[0] == value[1])
         {
            this.m_hoverMc.attachTooltip(this.m_sinkHoverTooltip);
            this.m_discardBt.visible = true;
            this.m_discardBt.enabled = true;
            this.m_tradeBt.visible = true;
            this.m_tradeBt.enabled = false;
         }
         else if(this.m_resourceCount == 0)
         {
            this.m_discardBt.visible = true;
            this.m_tradeBt.visible = true;
            this.m_discardBt.enabled = false;
            this.m_tradeBt.enabled = false;
         }
      }
      
      private function onTileMouseRollOut(e:MouseEvent) : void
      {
         this.m_hoverMc.visible = false;
         this.m_discardBt.visible = false;
         this.m_tradeBt.visible = false;
      }
      
      private function onDiscardClick(event:Event) : void
      {
         this.m_discardBt.enabled = false;
         this.m_tradeBt.enabled = false;
         var barnCapacity:int = this.manager.getBarnInventoryCount();
         FarmStatsManager.count(this.m_featureName,"BarnHouse","DiscardResource",this.m_item.name,(this.m_resourceCount - 1).toString(),"",barnCapacity - 1);
         this.manager.discardClick(this.m_slotResourceName,this.m_slotNumber,this.m_frameName);
      }
      
      public function clearSlotData() : void
      {
         this.m_tradeBt.enabled = true;
         this.m_discardBt.enabled = true;
      }
      
      private function onTradeClick(event:Event) : void
      {
         var emptySlot:int = this.manager.getEmptySlot();
         if(emptySlot != this.EMPTY_SLOT)
         {
            FarmStatsManager.count(this.m_featureName,"BarnHouse","TradeResource",this.m_item.name);
            this.manager.triggerTradeFrame(this.m_slotNumber,this.m_slotResourceName,this.m_frameName,emptySlot);
         }
      }
      
      override public function release() : void
      {
         if(this.m_objectPreviewFrame)
         {
            this.m_objectPreviewFrame.detachTooltip();
            this.m_objectPreviewFrame = null;
         }
         if(this.m_iconPreview)
         {
            this.m_iconPreview.detachTooltip();
            this.m_iconPreview = null;
         }
         if(this.m_checkMark)
         {
            this.m_checkMark = null;
         }
         this.m_countTextField = null;
         this.m_buyButton = null;
         this.m_redeemButton = null;
         super.release();
      }
      
      private function onBuyItem(event:Event) : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.name);
         UI.displayMessage(ZLocUtils.t("Dialogs",this.m_basketName + "BuyConfirmPopup",{
            "cashQuantity":item.cash,
            "item":item.friendlyTitle
         }),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmBuyItemPopupClose,"",true);
      }
      
      private function onConfirmBuyItemPopupClose(event:GenericPopupEvent) : void
      {
         var callback:Function = null;
         if(event.button == GenericPopup.YES)
         {
            callback = this.m_callbacks[CraftingBasket.BUY_ITEM];
            callback(this.m_data.name);
         }
      }
      
      private function onRedeemItem(event:Event) : void
      {
         var callback:Function = this.m_callbacks[CraftingBasket.REDEEM_ITEM];
         callback(this.m_data.name);
      }
      
      public function toggleRedeemVisible(visible:Boolean) : void
      {
         if(visible)
         {
            this.m_redeemButton.enabled = true;
            this.m_redeemButton.applyGrayOut = false;
         }
         else
         {
            this.m_redeemButton.enabled = false;
            this.m_redeemButton.applyGrayOut = true;
         }
      }
   }
}

