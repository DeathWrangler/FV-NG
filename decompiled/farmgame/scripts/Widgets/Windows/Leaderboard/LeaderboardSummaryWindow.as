package Widgets.Windows.Leaderboard
{
   import Classes.Leaderboard.Leaderboard;
   import Classes.Leaderboard.LeaderboardState;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.LeaderboardManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Leaderboard.LeaderboardProgressRewardSlotContainerFrame;
   import Widgets.Frames.Leaderboard.LeaderboardRankRewardSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class LeaderboardSummaryWindow extends FarmWindow
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_leaderboard:Leaderboard;
      
      private var m_closeCallback:Function;
      
      private var m_icon:FarmIcon;
      
      private var m_infoTextField:ZwTextField;
      
      private var m_rankTextField:ZwTextField;
      
      private var m_rankRewardSlotFrame:LeaderboardRankRewardSlotContainerFrame;
      
      private var m_progressRewardSlotFrame:LeaderboardProgressRewardSlotContainerFrame;
      
      public function LeaderboardSummaryWindow(leaderboard:Leaderboard, closeCallback:Function = null)
      {
         super("assets/dialogs/FV_LeaderboardSummary.swf");
         this.m_leaderboard = leaderboard;
         this.m_closeCallback = closeCallback;
      }
      
      override public function close() : void
      {
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback();
         }
         super.close();
      }
      
      override protected function onClose(event:Event) : void
      {
         if(m_closeButton.enabled)
         {
            super.onClose(event);
         }
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Leaderboard","LeaderboardSummaryWindow_Title")));
         this.m_icon = addWidget(new FarmIcon(m_window.item_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_infoTextField = addWidget(new ZwTextField(m_window.description_tf,"")) as ZwTextField;
         this.m_rankTextField = addWidget(new ZwTextField(m_window.yourRank_tf,"")) as ZwTextField;
         this.m_rankRewardSlotFrame = addWidget(new LeaderboardRankRewardSlotContainerFrame(m_window.rewards_mc)) as LeaderboardRankRewardSlotContainerFrame;
         this.m_progressRewardSlotFrame = addWidget(new LeaderboardProgressRewardSlotContainerFrame(m_window.progress_mc)) as LeaderboardProgressRewardSlotContainerFrame;
         this.refresh();
      }
      
      override protected function release() : void
      {
         this.m_closeCallback = null;
         this.m_icon = null;
         this.m_infoTextField = null;
         this.m_progressRewardSlotFrame = null;
         this.m_rankRewardSlotFrame = null;
         this.m_rankTextField = null;
         super.release();
      }
      
      private function refresh() : void
      {
         var leaderboardName:String = null;
         var rank:int = 0;
         var rankText:String = null;
         var leaderboardState:LeaderboardState = null;
         var score:int = 0;
         var rankRewards:Array = null;
         var progressRewards:Array = null;
         if(this.m_leaderboard)
         {
            leaderboardName = this.m_leaderboard.name;
            this.m_icon.loadIcon(this.m_leaderboard.iconUrl);
            this.m_infoTextField.text = ZLocUtils.t("Leaderboard","LeaderboardSummaryWindow_Info",{"leaderboardName":this.m_leaderboard.nameText});
            rank = LeaderboardManager.getRank(leaderboardName);
            rankText = rank > 0 ? LeaderboardManager.getRankOrdinalText(rank) : "?";
            leaderboardState = Global.player.getLeaderboardState(leaderboardName);
            score = leaderboardState ? leaderboardState.score : 0;
            this.m_rankTextField.text = ZLocUtils.t("Leaderboard","LeaderboardSummaryWindow_Rank",{
               "rank":rankText,
               "score":score
            });
            rankRewards = this.m_leaderboard.rankRewards;
            if(rankRewards)
            {
               this.m_rankRewardSlotFrame.items = rankRewards;
            }
            progressRewards = this.m_leaderboard.progressRewards;
            if(progressRewards)
            {
               this.m_progressRewardSlotFrame.items = progressRewards;
            }
            FarmStatsManager.featureSample(LeaderboardManager.STAT_COUNTER,"impressions","summary_dialog",this.m_leaderboard.name);
         }
      }
      
      public function get leaderboard() : Leaderboard
      {
         return this.m_leaderboard;
      }
   }
}

