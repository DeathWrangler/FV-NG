package Widgets.Frames.Leaderboard
{
   import Managers.LeaderboardManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Leaderboard.MultiTaskLeaderboardRewardSlot;
   import flash.display.DisplayObject;
   
   public class MultiTaskLeaderboardRewardSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      private var m_type:String;
      
      public function MultiTaskLeaderboardRewardSlotContainerFrame(element:DisplayObject, type:String)
      {
         this.m_type = type;
         super(element);
         var typeText:String = this.m_type == LeaderboardManager.PROGRESS_REWARD_TYPE ? "Score Prizes" : "Rank Prizes";
         addWidget(new ZwTextField(m_element.generic_tf,typeText));
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new MultiTaskLeaderboardRewardSlot(slotElement,this.m_type);
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

