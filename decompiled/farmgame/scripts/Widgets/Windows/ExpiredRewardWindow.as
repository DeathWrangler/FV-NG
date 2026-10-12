package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Events.GenericPopupEvent;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Slots.ExpiredQuestRewardPurchaseSlot;
   import flash.events.MouseEvent;
   
   public class ExpiredRewardWindow extends FarmWindow
   {
      
      private var m_items:Array = null;
      
      private var m_expiredName:String = null;
      
      private var m_slotFrame:GenericSlotContainerFrame = null;
      
      private var m_buyAllButton:FarmAnimatedCashButton = null;
      
      protected var m_totalPrice:int = 0;
      
      private var m_expiredFeatureStat:String = null;
      
      private var m_zLocKey:String = "";
      
      private var m_altPurchaseServiceName:String = "";
      
      private var m_altPurchaseServiceFunctionName:String = "";
      
      private var m_altPurchaseCallbackFunction:Function = null;
      
      public function ExpiredRewardWindow(assetPath:String, expiredName:String, data:Array, expiredFeatureStat:String, zLocKey:String = "", altPurchaseOption:Object = null)
      {
         this.m_items = data;
         this.m_expiredName = expiredName;
         this.m_expiredFeatureStat = expiredFeatureStat;
         this.m_zLocKey = zLocKey;
         if(altPurchaseOption != null && altPurchaseOption.hasOwnProperty("serviceName") && altPurchaseOption.hasOwnProperty("serviceFunctionName"))
         {
            this.m_altPurchaseServiceName = altPurchaseOption.serviceName;
            this.m_altPurchaseServiceFunctionName = altPurchaseOption.serviceFunctionName;
            if(altPurchaseOption.hasOwnProperty("callbackFunction"))
            {
               this.m_altPurchaseCallbackFunction = altPurchaseOption.callbackFunction;
            }
         }
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window["title_tf"])
         {
            addWidget(new ZwTextField(m_window["title_tf"],ZLocUtils.t("Dialogs","ExpiredRewardWindow_title" + this.m_zLocKey)));
         }
         if(m_window["header_tf"])
         {
            addWidget(new ZwTextField(m_window["header_tf"],ZLocUtils.t("Dialogs","ExpiredRewardWindow_header" + this.m_zLocKey,{"expiredName":this.m_expiredName})));
         }
         if(m_window["subheader_tf"])
         {
            addWidget(new ZwTextField(m_window["subheader_tf"],ZLocUtils.t("Dialogs","ExpiredRewardWindow_subheader" + this.m_zLocKey)));
         }
         if(this.m_items != null && this.m_items.length > 1 && Boolean(m_window["buy_bt"]))
         {
            addWidget(this.m_buyAllButton = new FarmAnimatedCashButton(m_window["buy_bt"],ZLocUtils.t("Dialogs","ExpiredRewardWindow_buyall" + this.m_zLocKey),this.getTotalPrice().toString(),this.onBuyAll));
         }
         this.addSlots();
      }
      
      private function addSlots() : void
      {
         var index:int = 0;
         var slot:ExpiredQuestRewardPurchaseSlot = null;
         if(m_window["slots_mc"])
         {
            this.m_slotFrame = addWidget(new GenericSlotContainerFrame(m_window["slots_mc"],ExpiredQuestRewardPurchaseSlot,this.m_items,this)) as GenericSlotContainerFrame;
            index = 1;
            for each(slot in this.m_slotFrame.slots)
            {
               slot.slotFrameIndex = index;
               index++;
            }
         }
      }
      
      public function hasAltPurchaseOption() : Boolean
      {
         return this.m_altPurchaseServiceName is String && this.m_altPurchaseServiceName != "" && this.m_altPurchaseServiceFunctionName is String && this.m_altPurchaseServiceFunctionName != "";
      }
      
      private function getTotalPrice() : int
      {
         var item:FarmItem = null;
         var totalCost:int = 0;
         for each(item in this.m_items)
         {
            totalCost += item.cash;
         }
         return totalCost;
      }
      
      private function onBuyAll(event:MouseEvent) : void
      {
         UI.displayMessage(ZLocUtils.t("Dialogs","ExpiredRewardWindow_buy_all_confirmation",{"amount":this.getTotalPrice()}),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmBuyAll,"QuestRecaptureBuyAll",true);
      }
      
      protected function onConfirmBuyAll(event:GenericPopupEvent) : void
      {
         var numberOfItems:int = 0;
         var allPrice:int = 0;
         var slot:ExpiredQuestRewardPurchaseSlot = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            numberOfItems = 0;
            allPrice = this.getTotalPrice();
            if(Global.player.canBuyCash(allPrice))
            {
               for each(slot in this.m_slotFrame.slots)
               {
                  slot.buyItem();
                  numberOfItems++;
               }
               StatsManager.count(this.expiredFeatureStat,"rewards_recapture_buy_all",numberOfItems.toString(),allPrice.toString());
            }
         }
      }
      
      public function applyBuyButtonGrayOut(value:Boolean) : void
      {
         var slot:ExpiredQuestRewardPurchaseSlot = null;
         if(this.m_buyAllButton)
         {
            this.m_buyAllButton.applyGrayOut = value;
         }
         if(this.m_slotFrame)
         {
            for each(slot in this.m_slotFrame.slots)
            {
               slot.applyBuyButtonGrayOut(value);
            }
         }
      }
      
      public function get expiredFeatureStat() : String
      {
         return this.m_expiredFeatureStat;
      }
      
      public function get altPurchaseServiceName() : String
      {
         return this.m_altPurchaseServiceName;
      }
      
      public function get altPurchaseServiceFunctionName() : String
      {
         return this.m_altPurchaseServiceFunctionName;
      }
      
      public function get altPurchaseCallbackFunction() : Function
      {
         return this.m_altPurchaseCallbackFunction;
      }
      
      public function hasAltPurchaseCallbackFunction() : Boolean
      {
         return this.m_altPurchaseCallbackFunction != null;
      }
   }
}

