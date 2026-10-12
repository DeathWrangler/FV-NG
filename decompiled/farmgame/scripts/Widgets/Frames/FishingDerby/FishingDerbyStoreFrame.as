package Widgets.Frames.FishingDerby
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.FishingDerby.FishingDerbyStoreSlot;
   import flash.display.DisplayObject;
   
   public class FishingDerbyStoreFrame extends FarmSlotContainerFrame
   {
      
      private var m_page:ZwTextField;
      
      public function FishingDerbyStoreFrame(element:DisplayObject)
      {
         super(element);
         if(m_element.leftArrow_bt)
         {
            m_pageBackWidget = new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack);
            addWidget(m_pageBackWidget);
         }
         if(m_element.rightArrow_bt)
         {
            m_pageForwardWidget = new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward);
            addWidget(m_pageForwardWidget);
         }
         this.refresh();
      }
      
      override public function refresh() : void
      {
         m_pagingComponent.maxPageNumber = calcMaxPageNumber();
         populateSlots(m_slots.length * m_pagingComponent.currentPageNumber);
         adjustPagingWidgetVisibility();
         m_currentPageLabel.text = ZLocUtils.t("Dialogs","GiftBox_Page",{
            "current":m_pagingComponent.currentPageNumber + 1,
            "total":m_pagingComponent.maxPageNumber + 1
         });
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FishingDerbyStoreSlot(slotElement);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function release() : void
      {
         super.release();
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         this.refresh();
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
   }
}

