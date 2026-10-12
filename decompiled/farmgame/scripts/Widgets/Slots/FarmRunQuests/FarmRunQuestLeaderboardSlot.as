package Widgets.Slots.FarmRunQuests
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.Leaderboard.LeaderboardSlotPlayerData;
   import flash.display.DisplayObject;
   
   public class FarmRunQuestLeaderboardSlot extends ZwSlotFrame
   {
      
      private var m_playerFrame:FarmRunQuestLeaderBoardSlotPlayerFrame;
      
      public function FarmRunQuestLeaderboardSlot(element:DisplayObject)
      {
         super(element);
         this.m_playerFrame = addWidget(new FarmRunQuestLeaderBoardSlotPlayerFrame(m_element.cell_mc),false) as FarmRunQuestLeaderBoardSlotPlayerFrame;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_playerFrame.populate(data as LeaderboardSlotPlayerData);
         this.m_playerFrame.visible = true;
      }
      
      override public function release() : void
      {
         this.m_playerFrame = null;
         super.release();
      }
   }
}

