package Widgets.Frames.Sales
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Sales.TargetedLimitedSaleSlot;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class TargetedLimitedSaleSlotFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_POSTFIX:String = "";
      
      public static const NUM_SLOTS:int = 5;
      
      private var m_saleItemsInfo:Object = null;
      
      private var m_pageNumTextField:ZwTextField;
      
      public function TargetedLimitedSaleSlotFrame(element:DisplayObject, items:Object)
      {
         this.m_saleItemsInfo = items;
         super(element);
         m_pageBackWidget = addWidget(new ZwButton(m_element.leftArrow_bt,this.onPageBack)) as ZwButton;
         m_pageForwardWidget = addWidget(new ZwButton(m_element.rightArrow_bt,this.onPageForward)) as ZwButton;
         refresh();
         this.m_pageNumTextField = addWidget(new ZwTextField(m_element.page_tf,ZLocUtils.t("Dialogs","limitedSalePageCount",{
            "current":m_pagingComponent.currentPageNumber + 1,
            "total":m_pagingComponent.maxPageNumber + 1
         }))) as ZwTextField;
      }
      
      override public function release() : void
      {
         var slot:TargetedLimitedSaleSlot = null;
         for each(slot in m_slots)
         {
            slot.removeEventListener(TargetedLimitedSaleSlot.BUY_CLICKED_EVENT,this.onSlotBuyClicked);
         }
         super.release();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         var slotNumIndex:int = slotElement.name.indexOf("_") + 1;
         var slotNum:int = parseInt(slotElement.name.charAt(slotNumIndex));
         var result:TargetedLimitedSaleSlot = new TargetedLimitedSaleSlot(slotElement,slotNum);
         result.addEventListener(TargetedLimitedSaleSlot.BUY_CLICKED_EVENT,this.onSlotBuyClicked);
         return result;
      }
      
      override protected function setupData() : void
      {
         var itemName:String = null;
         var slotFriendlyData:Object = null;
         for(itemName in this.m_saleItemsInfo)
         {
            slotFriendlyData = this.m_saleItemsInfo[itemName];
            slotFriendlyData.itemName = itemName;
            m_slotData.push(slotFriendlyData);
         }
      }
      
      private function onPageBack(event:Event) : void
      {
         m_pagingComponent.onPageBack(event);
         this.updatePageText();
      }
      
      private function onPageForward(event:Event) : void
      {
         m_pagingComponent.onPageForward(event);
         this.updatePageText();
      }
      
      private function updatePageText() : void
      {
         this.m_pageNumTextField.text = ZLocUtils.t("Dialogs","limitedSalePageCount",{
            "current":m_pagingComponent.currentPageNumber + 1,
            "total":m_pagingComponent.maxPageNumber + 1
         });
      }
      
      private function onSlotBuyClicked(event:Event) : void
      {
         dispatchEvent(event);
      }
   }
}

