package Widgets.Frames.FeatureCrafting
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.FeatureCrafting.FeatureCraftingNPCSlot;
   import flash.display.DisplayObject;
   
   public class FeatureCraftingNPCSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      private var m_location:String = "";
      
      public function FeatureCraftingNPCSlotContainerFrame(element:DisplayObject, location:String = "")
      {
         this.m_location = location;
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
         return new FeatureCraftingNPCSlot(slotElement,this.m_location);
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

