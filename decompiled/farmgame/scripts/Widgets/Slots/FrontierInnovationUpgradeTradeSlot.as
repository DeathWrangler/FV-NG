package Widgets.Slots
{
   import Classes.CraftingBasket;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.OrderBoard.FrontierInnovationManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
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
   
   public class FrontierInnovationUpgradeTradeSlot extends ZwSlotFrame
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
      
      private var m_rewardBg:ZwWidget;
      
      private var m_commonRewardBg:ZwWidget;
      
      private var infoTooltip:FarmTextTooltip;
      
      private var m_checkmark:MovieClip;
      
      private var m_iconMc:FarmIcon;
      
      private var m_countTf:ZwTextField;
      
      private var m_selectTf:ZwTextField;
      
      private var m_hoverMc:MovieClip;
      
      private var m_tradeBt:FarmAnimatedTextButton;
      
      private var m_itemHover:ZwWidget;
      
      private var m_glowMc:MovieClip;
      
      private var m_selectResourceBt:FarmAnimatedTextButton;
      
      private const GLOW_MC:String = "glow_mc";
      
      private const ICON_MC:String = "icon_mc";
      
      private const COUNT_TF:String = "count_tf";
      
      private const CHECKMARK_MC:String = "checkmark_mc";
      
      private const SELECT_TF:String = "select_tf";
      
      private const SELECT_BT:String = "select_bt";
      
      private const HOVER_GLOW:String = "hover_glow";
      
      internal var manager:FrontierInnovationManager;
      
      private var m_featureName:String;
      
      private var m_slotResource:String;
      
      private var m_frameName:String;
      
      private var m_slotNumber:int;
      
      private var m_slotResourceName:String;
      
      private var m_resourceCount:String;
      
      private var m_resourceName:String;
      
      private var m_window:FrontierInnovationBarnWindow;
      
      internal var index:*;
      
      public function FrontierInnovationUpgradeTradeSlot(featureName:String, element:DisplayObject, window:FrontierInnovationBarnWindow)
      {
         this.m_featureName = featureName;
         this.m_window = window;
         this.manager = FrontierInnovationManager.getInstance(featureName);
         super(element);
         this.m_slotResource = m_element.name;
         this.m_frameName = m_element.parent.name;
         this.m_slotNumber = this.m_window.getSlotNumber(this.m_slotResource);
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
         if(m_element.hasOwnProperty(this.CHECKMARK_MC))
         {
            this.m_checkmark = m_element[this.CHECKMARK_MC] as MovieClip;
            this.m_checkmark.visible = false;
         }
         if(m_element.hasOwnProperty(this.SELECT_TF))
         {
            addWidget(this.m_selectTf = new ZwTextField(m_element[this.SELECT_TF],""));
         }
         if(m_element.hasOwnProperty(this.GLOW_MC))
         {
            this.m_glowMc = m_element[this.GLOW_MC] as MovieClip;
            this.m_glowMc.visible = false;
         }
         if(m_element.hasOwnProperty(this.SELECT_BT))
         {
            addWidget(this.m_selectResourceBt = new FarmAnimatedTextButton(m_element[this.SELECT_BT],"Get 1",this.onSelectResourceClick));
            this.m_selectResourceBt.visible = true;
         }
      }
      
      public function loadSlot() : void
      {
         if(this.m_itemHover.element.hasOwnProperty("select_bt"))
         {
            addWidget(this.m_selectResourceBt = new FarmAnimatedTextButton(this.m_itemHover.element.select_bt,"SELECT",this.onSelectResourceClick));
         }
         if(this.m_itemHover.element.hasOwnProperty(this.HOVER_GLOW))
         {
            this.m_glowMc = this.m_itemHover.element[this.HOVER_GLOW] as MovieClip;
            this.disableGlow();
         }
      }
      
      private function disableGlow() : void
      {
         if(this.m_glowMc)
         {
            this.m_glowMc.stop();
            this.m_glowMc.visible = false;
         }
      }
      
      private function enableGlow() : void
      {
         if(this.m_glowMc)
         {
            this.m_glowMc.play();
            this.m_glowMc.visible = true;
         }
      }
      
      public function setCheckmark() : void
      {
         this.m_checkmark.visible = false;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.releaseResource();
         this.m_resourceCount = data["Count"];
         this.m_slotResourceName = data["resourceCode"].toString();
         this.m_countTf.visible = true;
         this.m_selectResourceBt.visible = true;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(data["resourceCode"]);
         this.m_iconMc.loadIcon(item.icon);
         if(this.m_slotNumber == 0)
         {
            this.m_iconMc.setIconSize(100,100);
         }
         else
         {
            this.m_iconMc.setIconSize(50,50);
         }
         this.m_iconMc.visible = true;
         this.m_countTf.text = "You have " + this.m_resourceCount + " " + item.friendlyTitle;
         this.m_resourceName = item.friendlyTitle;
      }
      
      public function releaseResource() : void
      {
         this.m_countTf.visible = false;
         this.m_countTf.text = "";
         this.m_iconMc.visible = false;
         this.m_selectResourceBt.visible = false;
         this.m_glowMc.visible = false;
         this.m_checkmark.visible = false;
         this.m_selectTf.visible = false;
         this.m_selectTf.text = "";
      }
      
      public function setGivingResource() : void
      {
         this.m_checkmark.visible = true;
         this.m_selectResourceBt.visible = false;
         this.m_selectTf.visible = true;
         this.m_selectTf.text = "You will give 1 " + this.m_resourceName;
         this.m_glowMc.visible = true;
         this.m_countTf.visible = false;
      }
      
      private function setR1Slot() : void
      {
         this.m_window.setR1SlotActive(this.m_slotNumber,this.m_slotResourceName,this.m_frameName);
         this.m_selectResourceBt.visible = false;
         this.m_checkmark.visible = true;
         this.m_countTf.visible = false;
         this.m_selectTf.visible = true;
         this.m_selectTf.text = "You will get 1 " + this.m_resourceName;
         this.m_glowMc.visible = true;
      }
      
      public function clearSlot() : void
      {
         this.m_checkmark.visible = false;
         this.m_selectTf.visible = false;
         this.m_selectTf.text = "";
         this.m_countTf.visible = true;
         this.m_selectResourceBt.visible = true;
         this.m_glowMc.visible = false;
      }
      
      public function clearSlotData() : void
      {
         this.m_checkmark.visible = false;
         this.m_selectTf.visible = false;
         this.m_selectTf.text = "";
         this.m_glowMc.visible = false;
      }
      
      public function disableSlotButton() : void
      {
         this.m_selectResourceBt.visible = false;
      }
      
      private function onSelectResourceClick(event:MouseEvent) : void
      {
         this.m_window.activeConformTrade(this.m_frameName);
         if(this.m_window.otherSlotActive(this.m_frameName))
         {
            this.m_window.makeOtherSlotInactive(this.m_frameName);
         }
         this.setR1Slot();
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

