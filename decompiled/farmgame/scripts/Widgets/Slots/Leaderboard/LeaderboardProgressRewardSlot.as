package Widgets.Slots.Leaderboard
{
   import Classes.Leaderboard.Leaderboard;
   import Classes.Leaderboard.LeaderboardState;
   import Managers.LeaderboardManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import flash.display.DisplayObject;
   
   public class LeaderboardProgressRewardSlot extends ZwSlotFrame
   {
      
      private var m_data:Object;
      
      private var m_completeFrame:LeaderboardProgressRewardSlotCompleteFrame;
      
      private var m_incompleteFrame:LeaderboardProgressRewardSlotIncompleteFrame;
      
      public function LeaderboardProgressRewardSlot(element:DisplayObject)
      {
         super(element);
         this.m_completeFrame = addWidget(new LeaderboardProgressRewardSlotCompleteFrame(m_element.complete_mc)) as LeaderboardProgressRewardSlotCompleteFrame;
         this.m_incompleteFrame = addWidget(new LeaderboardProgressRewardSlotIncompleteFrame(m_element.missed_mc)) as LeaderboardProgressRewardSlotIncompleteFrame;
      }
      
      override public function populate(data:Object) : void
      {
         var leaderboard:Leaderboard = null;
         var threshold:int = 0;
         var userState:LeaderboardState = null;
         var userScore:int = 0;
         super.populate(data);
         this.m_data = data;
         if(this.m_data)
         {
            leaderboard = LeaderboardManager.getLeaderboardForWidget(this);
            if(leaderboard)
            {
               threshold = int(this.m_data["threshold"]);
               userState = Global.player.getLeaderboardState(leaderboard.name);
               userScore = userState ? userState.score : 0;
               if(userScore >= threshold)
               {
                  this.m_completeFrame.populate(data);
                  this.m_completeFrame.visible = true;
               }
               else
               {
                  this.m_incompleteFrame.populate(data);
                  this.m_incompleteFrame.visible = true;
               }
            }
         }
      }
      
      override public function release() : void
      {
         this.m_data = null;
         this.m_completeFrame = null;
         this.m_incompleteFrame = null;
         super.release();
      }
   }
}

