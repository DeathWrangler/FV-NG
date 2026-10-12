package Widgets.Frames.Leaderboard
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Leaderboard.MultiTaskLeaderboardTaskSlot;
   import flash.display.DisplayObject;
   
   public class MultiTaskLeaderboardTaskSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      public function MultiTaskLeaderboardTaskSlotContainerFrame(element:DisplayObject)
      {
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new MultiTaskLeaderboardTaskSlot(slotElement);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function release() : void
      {
         super.release();
      }
      
      public function get numSlots() : int
      {
         return m_slots.length;
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

