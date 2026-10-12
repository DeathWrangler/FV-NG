package Widgets.Slots.Leaderboard
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import flash.display.DisplayObject;
   
   public class LeaderboardSlot extends ZwSlotFrame
   {
      
      private var m_playerFrame:LeaderboardSlotPlayerFrame;
      
      private var m_progressRewardFrame:LeaderboardSlotProgressRewardFrame;
      
      public function LeaderboardSlot(element:DisplayObject)
      {
         super(element);
         this.m_playerFrame = addWidget(new LeaderboardSlotPlayerFrame(m_element.cell_mc),false) as LeaderboardSlotPlayerFrame;
         this.m_progressRewardFrame = addWidget(new LeaderboardSlotProgressRewardFrame(m_element.reward_mc),false) as LeaderboardSlotProgressRewardFrame;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         if(data is LeaderboardSlotPlayerData)
         {
            this.m_playerFrame.populate(data as LeaderboardSlotPlayerData);
            this.m_playerFrame.visible = true;
            this.m_progressRewardFrame.visible = false;
         }
         else
         {
            this.m_progressRewardFrame.populate(data);
            this.m_progressRewardFrame.visible = true;
            this.m_playerFrame.visible = false;
         }
      }
      
      override public function release() : void
      {
         this.m_playerFrame = null;
         this.m_progressRewardFrame = null;
         super.release();
      }
   }
}

