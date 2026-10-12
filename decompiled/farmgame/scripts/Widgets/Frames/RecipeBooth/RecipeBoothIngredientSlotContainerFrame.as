package Widgets.Frames.RecipeBooth
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.RecipeBooth.RecipeBoothIngredientSlot;
   import flash.display.DisplayObject;
   
   public class RecipeBoothIngredientSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      public function RecipeBoothIngredientSlotContainerFrame(element:DisplayObject)
      {
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new RecipeBoothIngredientSlot(slotElement);
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
      
      public function get hasEnough() : Boolean
      {
         var slot:RecipeBoothIngredientSlot = null;
         var result:Boolean = true;
         for each(slot in m_slots)
         {
            if(!slot.hasEnough)
            {
               result = false;
               break;
            }
         }
         return result;
      }
      
      public function get counts() : Object
      {
         var slot:RecipeBoothIngredientSlot = null;
         var result:Object = {};
         for each(slot in m_slots)
         {
            result[slot.itemName] = slot.count;
         }
         return result;
      }
      
      public function deductCounts() : void
      {
         var slot:RecipeBoothIngredientSlot = null;
         for each(slot in m_slots)
         {
            slot.deductCount();
         }
      }
      
      public function refreshAskButtons() : void
      {
         var slot:RecipeBoothIngredientSlot = null;
         for each(slot in m_slots)
         {
            slot.refreshAskButton();
         }
      }
   }
}

