package Widgets.Frames.Leaderboard
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Leaderboard.LeaderboardHistorySlot;
   import flash.display.DisplayObject;
   
   public class LeaderboardHistorySlotContainerFrame extends FarmSlotContainerFrame
   {
      
      private static const SLOT_PREFIX:String = "historyCell_";
      
      public function LeaderboardHistorySlotContainerFrame(element:DisplayObject)
      {
         super(element);
         addWidget(new ZwTextField(m_element.timer_tf,ZLocUtils.t("Leaderboard","LeaderboardWindow_HistoryInfo")));
         m_pageBackWidget = addWidget(new ZwButton(m_element.topArrow_bt,m_pagingComponent.onPageBack)) as ZwButton;
         m_pageForwardWidget = addWidget(new ZwButton(m_element.botArrow_bt,m_pagingComponent.onPageForward)) as ZwButton;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new LeaderboardHistorySlot(slotElement);
      }
      
      override protected function setupData() : void
      {
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
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

