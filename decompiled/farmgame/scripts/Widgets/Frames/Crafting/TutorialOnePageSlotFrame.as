package Widgets.Frames.Crafting
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Components.ZwSimplePagingComponent;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Crafting.TutorialOnePageSlot;
   import flash.display.DisplayObject;
   
   public class TutorialOnePageSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_items:Array = null;
      
      public function TutorialOnePageSlotFrame(element:DisplayObject, items:Array)
      {
         this.m_items = items;
         super(element);
         m_pagingComponent = new ZwSimplePagingComponent(0,this.refresh);
         m_pagingComponent.maxPageNumber = Math.floor(m_slotData.length / m_slots.length);
         m_pageBackWidget = new ZwButton(m_element.backArrow_bt,m_pagingComponent.onPageBack);
         m_pageForwardWidget = new ZwButton(m_element.nextArrow_bt,m_pagingComponent.onPageForward);
         addWidget(m_pageBackWidget);
         addWidget(m_pageForwardWidget);
         refresh();
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_items;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new TutorialOnePageSlot(slotElement);
      }
      
      override public function release() : void
      {
         super.release();
         this.m_items = null;
      }
   }
}

