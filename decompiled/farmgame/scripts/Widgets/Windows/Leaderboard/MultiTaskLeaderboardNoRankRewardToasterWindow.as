package Widgets.Windows.Leaderboard
{
   import Classes.Leaderboard.Leaderboard;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.LeaderboardManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.ToasterWindow;
   import flash.events.MouseEvent;
   
   public class MultiTaskLeaderboardNoRankRewardToasterWindow extends ToasterWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_FarmDerby2013_toaster.swf";
      
      private static const POPUP_NAME:String = "MultiTaskLeaderboardNoRankRewardToaster";
      
      private static const ICON_SIZE:int = 100;
      
      private var m_leaderboard:Leaderboard;
      
      public function MultiTaskLeaderboardNoRankRewardToasterWindow(leaderboard:Leaderboard)
      {
         super(ASSET_PATH);
         name = POPUP_NAME;
         this.m_leaderboard = leaderboard;
      }
      
      override protected function postLoadComplete() : void
      {
         if(this.m_leaderboard)
         {
            addWidget(new ZwTextField(m_window.generic_tf,this.m_leaderboard.nameText));
            addWidget(new ZwTextField(m_window.generic_desc_tf,ZLocUtils.t("Leaderboard","MultiTaskLeaderboardNoRankRewardToaster_Message")));
            addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Leaderboard","MultiTaskLeaderboardNoRankRewardToaster_OkayButton"),this.onOkayButtonClick));
            FarmStatsManager.featureSample(LeaderboardManager.STAT_COUNTER,"impressions","multitask_no_reward_toaster",this.m_leaderboard.name);
         }
      }
      
      override protected function release() : void
      {
         this.m_leaderboard = null;
         super.release();
      }
      
      private function onOkayButtonClick(event:MouseEvent) : void
      {
         close();
         LeaderboardManager.displayMultiTaskLeaderboardWindow();
         FarmStatsManager.featureSample(LeaderboardManager.STAT_COUNTER,"clicks","multitask_no_reward_toaster",this.m_leaderboard.name);
      }
   }
}

