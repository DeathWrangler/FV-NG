package Widgets.Frames.Leaderboard
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Leaderboard.LeaderboardRankRewardSlot;
   import flash.display.DisplayObject;
   
   public class LeaderboardRankRewardSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      public function LeaderboardRankRewardSlotContainerFrame(element:DisplayObject)
      {
         super(element);
         if(m_element.hasOwnProperty("rewardtext_tf"))
         {
            addWidget(new ZwTextField(m_element.rewardtext_tf,ZLocUtils.t("Leaderboard","WeeklyRewards")));
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new LeaderboardRankRewardSlot(slotElement);
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

