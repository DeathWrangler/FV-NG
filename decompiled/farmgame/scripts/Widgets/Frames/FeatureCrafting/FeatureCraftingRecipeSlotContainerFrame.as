package Widgets.Frames.FeatureCrafting
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.FeatureCrafting.FeatureCraftingRecipeSlot;
   import flash.display.DisplayObject;
   
   public class FeatureCraftingRecipeSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      public function FeatureCraftingRecipeSlotContainerFrame(element:DisplayObject)
      {
         super(element);
         if(m_element.arrowUp_bt)
         {
            m_pageBackWidget = addWidget(new ZwButton(m_element.arrowUp_bt,m_pagingComponent.onPageBack)) as ZwButton;
         }
         if(m_element.arrowDown_bt)
         {
            m_pageForwardWidget = addWidget(new ZwButton(m_element.arrowDown_bt,m_pagingComponent.onPageForward)) as ZwButton;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FeatureCraftingRecipeSlot(slotElement);
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
         refresh();
      }
      
      public function refreshDisplay() : void
      {
         var slot:FeatureCraftingRecipeSlot = null;
         for each(slot in m_slots)
         {
            slot.refresh();
         }
      }
   }
}

