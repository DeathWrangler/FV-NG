package Widgets.Frames.RecipeBooth
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.RecipeBooth.RecipeBoothItemSlot;
   import flash.display.DisplayObject;
   
   public class RecipeBoothItemSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      public function RecipeBoothItemSlotContainerFrame(element:DisplayObject)
      {
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new RecipeBoothItemSlot(slotElement);
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

