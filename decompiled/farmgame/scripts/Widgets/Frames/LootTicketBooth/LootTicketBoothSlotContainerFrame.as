package Widgets.Frames.LootTicketBooth
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.LootTicketBooth.LootTicketBoothSlot;
   import flash.display.DisplayObject;
   
   public class LootTicketBoothSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      public function LootTicketBoothSlotContainerFrame(element:DisplayObject)
      {
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new LootTicketBoothSlot(slotElement);
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
      
      public function setSlotState(itemsVisible:Boolean, buyButtonsVisible:Boolean, preview:Boolean) : void
      {
         var slot:LootTicketBoothSlot = null;
         for each(slot in m_slots)
         {
            slot.setState(itemsVisible,buyButtonsVisible,preview);
         }
      }
   }
}

