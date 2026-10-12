package Widgets.Frames.Leaderboard
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Leaderboard.LeaderboardProgressRewardSlot;
   import flash.display.DisplayObject;
   
   public class LeaderboardProgressRewardSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      public function LeaderboardProgressRewardSlotContainerFrame(element:DisplayObject)
      {
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new LeaderboardProgressRewardSlot(slotElement);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function release() : void
      {
         super.release();
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

