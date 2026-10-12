package Widgets.Frames.Leaderboard
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Leaderboard.LeaderboardSlot;
   import flash.display.DisplayObject;
   
   public class LeaderboardSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      public function LeaderboardSlotContainerFrame(element:DisplayObject)
      {
         super(element);
         m_pageBackWidget = addWidget(new ZwButton(m_element.topArrow_bt,m_pagingComponent.onPageBack)) as ZwButton;
         m_pageForwardWidget = addWidget(new ZwButton(m_element.botArrow_bt,m_pagingComponent.onPageForward)) as ZwButton;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new LeaderboardSlot(slotElement);
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

