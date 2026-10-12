package Widgets.Frames.RecipeBooth
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.RecipeBooth.RecipeBoothResultSlot;
   import flash.display.DisplayObject;
   
   public class RecipeBoothResultSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      public function RecipeBoothResultSlotContainerFrame(element:DisplayObject)
      {
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new RecipeBoothResultSlot(slotElement);
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

