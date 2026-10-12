package Widgets.Frames.Doghouse
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Doghouse.DoghouseSlot;
   import flash.display.DisplayObject;
   
   public class DoghouseSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      public function DoghouseSlotContainerFrame(element:DisplayObject)
      {
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new DoghouseSlot(slotElement);
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

