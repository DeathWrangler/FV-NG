package Widgets.Frames.BushelBaby
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.BushelBaby.BushelBabyNPCSlot;
   import flash.display.DisplayObject;
   
   public class BushelBabyNPCSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      public function BushelBabyNPCSlotContainerFrame(element:DisplayObject)
      {
         super(element);
         if(m_element.leftArrow_bt)
         {
            m_pageBackWidget = addWidget(new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack)) as ZwButton;
         }
         if(m_element.rightArrow_bt)
         {
            m_pageForwardWidget = addWidget(new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward)) as ZwButton;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new BushelBabyNPCSlot(slotElement);
      }
      
      override protected function setupData() : void
      {
      }
      
      public function get items() : Array
      {
         return m_slotData;
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         m_pagingComponent.reset();
         refresh();
      }
   }
}

