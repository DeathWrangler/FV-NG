package Widgets.Frames.FarmRunQuests
{
   import Classes.Leaderboard.Leaderboard;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.utils.Timer;
   
   public final class FarmRunQuestsLeaderboardUpperFrame extends ZwFrame
   {
      
      private var m_leaderboardFrame:FarmRunQuestLeaderboardFrame;
      
      private var m_timer:Timer;
      
      private var m_callBack:Function;
      
      public function FarmRunQuestsLeaderboardUpperFrame(element:DisplayObject, callback:Function, leaderboard:Leaderboard = null)
      {
         super(element);
         this.m_callBack = callback;
         addWidget(new ZwTextField(m_element.title_tf,"LeaderBoard"));
         addWidget(new FarmButton(m_element.close_bt,this.closeLeaderboard));
         this.m_leaderboardFrame = addWidget(new FarmRunQuestLeaderboardFrame(m_element.current1_mc)) as FarmRunQuestLeaderboardFrame;
      }
      
      public function closeLeaderboard(event:Event) : void
      {
         FarmStatsManager.count("farmrun_closeLeaderboard","close_click");
         this.m_callBack.call();
      }
      
      override public function release() : void
      {
         this.m_leaderboardFrame = null;
         super.release();
      }
      
      public function refresh() : void
      {
         this.m_leaderboardFrame.refresh();
      }
   }
}

