package Widgets.Slots.Sales
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Transactions.TBuyLimitedSaleItem;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.Market.MarketSlot;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.StaticWidgetTooltip;
   import Widgets.Windows.TargetedLimitedSaleWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class TargetedLimitedSaleSlot extends ZwSlotFrame
   {
      
      protected static const POPUP_ICON_WIDTH:Number = 100;
      
      protected static const POPUP_ICON_HEIGHT:Number = 100;
      
      public static const BUY_CLICKED_EVENT:String = "buyClicked";
      
      public static const BUY_SUCCESS_EVENT:String = "buySucces";
      
      private var m_slotAvailabilityIcon:ZwBaseWidget;
      
      private var m_slotFCIcon:ZwBaseWidget;
      
      private var m_slotBackground:ZwBaseWidget;
      
      private var m_slotSalePrice:FarmTextField;
      
      private var m_slotOriginalPrice:FarmTextField;
      
      private var m_slotItemQuantity:FarmTextField;
      
      private var m_toolTipTextTitle:FarmTextField;
      
      private var m_toolTipTextBody:FarmTextField;
      
      private var m_slotBuyButton:FarmAnimatedTextButton;
      
      private var m_slotIcon:FarmIcon;
      
      private var m_slotItem:FarmItem;
      
      private var m_salePrice:int;
      
      public function TargetedLimitedSaleSlot(element:DisplayObject, slotNum:int)
      {
         super(element);
         this.m_slotAvailabilityIcon = new ZwBaseWidget(m_element.tag_mc);
         addWidget(this.m_slotAvailabilityIcon);
         this.m_slotFCIcon = new ZwBaseWidget(m_element.cashSm_mc);
         addWidget(this.m_slotFCIcon);
         this.m_slotBackground = new ZwBaseWidget(m_element.slotBackground_mc);
         addWidget(this.m_slotBackground);
         this.m_slotSalePrice = new FarmTextField(m_element.price_tf,"xxx");
         addWidget(this.m_slotSalePrice);
         this.m_slotOriginalPrice = new FarmTextField(m_element.oldPrice_tf,"xxx");
         addWidget(this.m_slotOriginalPrice);
         this.m_slotItemQuantity = new FarmTextField(m_element.quantity_mc);
         addWidget(this.m_slotItemQuantity);
         this.m_slotBuyButton = new FarmAnimatedTextButton(m_element.buy_bt,ZLocUtils.t("Dialogs","Buy"),this.onBuyClick);
         addWidget(this.m_slotBuyButton);
         this.m_slotIcon = new FarmIcon(m_element.icon_mc);
         this.m_slotIcon.setIconSize(POPUP_ICON_WIDTH,POPUP_ICON_HEIGHT);
         addWidget(this.m_slotIcon);
         var tooltipFrame:ZwFrame = new ZwFrame((m_element as DisplayObject).parent["mouseover_" + slotNum + "_mc"]);
         this.m_toolTipTextTitle = tooltipFrame.addWidget(new FarmTextField(tooltipFrame.element.title_tf)) as FarmTextField;
         this.m_toolTipTextBody = tooltipFrame.addWidget(new FarmTextField(tooltipFrame.element.info_tf,"",true)) as FarmTextField;
         attachTooltip(new StaticWidgetTooltip(tooltipFrame));
      }
      
      override public function populate(saleItem:Object) : void
      {
         var packagedItemName:String = null;
         var quantity:int = 0;
         super.populate(saleItem);
         this.m_slotAvailabilityIcon.visible = true;
         this.m_slotFCIcon.visible = true;
         this.m_slotBackground.visible = true;
         this.m_slotSalePrice.visible = true;
         this.m_slotOriginalPrice.visible = true;
         this.m_slotBuyButton.visible = true;
         this.m_slotItemQuantity.visible = true;
         this.m_salePrice = parseInt(saleItem.sale_price);
         this.m_slotItem = Global.farmGameSettingsManager.getFarmItemByName(saleItem.itemName);
         if(this.m_slotItem != null)
         {
            this.m_slotIcon.loadIcon(this.m_slotItem.icon);
            this.m_slotIcon.visible = true;
         }
         this.m_slotOriginalPrice.text = this.m_slotItem.cash.toString();
         this.m_slotSalePrice.text = saleItem.sale_price;
         var quantityText:String = null;
         var itemPackageHash:Object = this.m_slotItem.getItemPackageHash();
         for(packagedItemName in itemPackageHash)
         {
            if(quantityText != null)
            {
               this.m_slotItemQuantity.visible = false;
               break;
            }
            quantity = int(itemPackageHash[packagedItemName]);
            quantityText = ZLocUtils.t("Dialogs","BuyingMultiple",{"quantity":quantity});
         }
         if(quantityText == null)
         {
            quantityText = "";
         }
         this.m_slotItemQuantity.text = quantityText;
         this.assignTooltipText();
      }
      
      private function assignTooltipText() : void
      {
         this.m_toolTipTextTitle.text = ZLocUtils.tk_pk_asTitle(this.m_slotItem.friendlyName);
         this.m_toolTipTextBody.text = MarketSlot.generateMarketCardInfoText(this.m_slotItem,true);
      }
      
      override public function release() : void
      {
         super.release();
         this.m_slotAvailabilityIcon = null;
         this.m_slotFCIcon = null;
         this.m_slotBackground = null;
         this.m_slotSalePrice = null;
         this.m_slotOriginalPrice = null;
         this.m_slotBuyButton = null;
         this.m_slotIcon = null;
      }
      
      private function onBuyClick(event:Event) : void
      {
         var message:String = null;
         if(Global.player.canBuyCash(this.m_salePrice))
         {
            message = ZLocUtils.t("Dialogs","FarmCashBuyConfirmation",{"price":this.m_salePrice});
            UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyMessageClose,"BuyTargetedLimitedSaleItemConfirmation",true);
            FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,TargetedLimitedSaleWindow.DIALOG_STATS_WINDOW,StatsTrackingConstants.DIALOG_STATS_BUTTON_CLICK_PHYLUM);
            FarmStatsManager.count(TargetedLimitedSaleWindow.SALE_ACTIVITY_COUNTER,StatsTrackingConstants.DIALOG_STATS_COUNTER,StatsTrackingConstants.DIALOG_STATS_BUTTON_CLICK_PHYLUM);
         }
      }
      
      private function onBuyMessageClose(event:GenericPopupEvent) : void
      {
         var buyTransaction:TBuyLimitedSaleItem = null;
         if(event.button == GenericPopup.OK)
         {
            Global.player.addGift(this.m_slotItem.name);
            Global.player.cash -= this.m_salePrice;
            Global.player.xp += this.m_slotItem.buyXp;
            buyTransaction = new TBuyLimitedSaleItem(this.m_slotItem.name,this.m_salePrice);
            buyTransaction.addEventListener(TransactionEvent.COMPLETED,this.itemBuySuccess);
            TransactionManager.addTransaction(buyTransaction);
            dispatchEvent(new Event(BUY_CLICKED_EVENT));
         }
      }
      
      private function itemBuySuccess(event:TransactionEvent) : void
      {
         event.transaction.removeEventListener(TransactionEvent.COMPLETED,this.itemBuySuccess);
         dispatchEvent(new Event(BUY_SUCCESS_EVENT));
      }
      
      public function setBuyButtonEnabled(enabled:Boolean) : void
      {
         this.m_slotBuyButton.enabled = enabled;
      }
   }
}

