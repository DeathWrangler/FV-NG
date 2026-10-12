package Widgets.Slots.Leaderboard
{
   import Classes.Leaderboard.Leaderboard;
   import Classes.Leaderboard.LeaderboardState;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.LeaderboardManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public final class LeaderboardProgressRewardSlotCompleteFrame extends ZwFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_data:Object;
      
      private var m_icon:FarmIcon;
      
      private var m_quantityTextField:ZwTextField;
      
      private var m_thresholdTextField:ZwTextField;
      
      private var m_shareButton:FarmAnimatedTextButton;
      
      public function LeaderboardProgressRewardSlotCompleteFrame(element:DisplayObject)
      {
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.rewardIcon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_icon.setSmoothing(true);
         addWidget(new ZwTextField(m_element.numberTitle_mc,ZLocUtils.t("Leaderboard","ScoreNeeded")));
         addWidget(new ZwWidget(m_element.check_mc));
         this.m_quantityTextField = addWidget(new ZwTextField(m_element.qty_tf,"")) as ZwTextField;
         this.m_thresholdTextField = addWidget(new ZwTextField(m_element.number_tf,"")) as ZwTextField;
         this.m_shareButton = addWidget(new FarmAnimatedTextButton(m_element.share_bt,ZLocUtils.t("Leaderboard","ShareButton"),this.onShareButtonClick)) as FarmAnimatedTextButton;
      }
      
      override public function release() : void
      {
         this.m_icon = null;
         this.m_quantityTextField = null;
         this.m_shareButton = null;
         this.m_thresholdTextField = null;
         super.release();
      }
      
      public function populate(data:Object) : void
      {
         var leaderboard:Leaderboard = null;
         var threshold:int = 0;
         var userState:LeaderboardState = null;
         var index:int = 0;
         this.m_data = data;
         if(this.m_data)
         {
            leaderboard = LeaderboardManager.getLeaderboardForWidget(this);
            if(leaderboard)
            {
               this.m_icon.loadIcon(UserRewardUtil.getImageForReward(this.m_data));
               this.m_quantityTextField.text = UserRewardUtil.getValueForReward(this.m_data);
               threshold = int(this.m_data["threshold"]);
               this.m_thresholdTextField.text = String(threshold);
               userState = Global.player.getLeaderboardState(leaderboard.name);
               index = leaderboard.getIndexForProgressReward(this.m_data);
               this.m_shareButton.visible = !userState.hasProgressFeed(index);
            }
         }
      }
      
      private function onShareButtonClick(event:MouseEvent) : void
      {
         var leaderboard:Leaderboard = null;
         var index:int = 0;
         if(this.m_shareButton.enabled)
         {
            this.m_shareButton.enabled = false;
            leaderboard = LeaderboardManager.getLeaderboardForWidget(this);
            if(leaderboard)
            {
               index = leaderboard.getIndexForProgressReward(this.m_data);
               LeaderboardManager.sendGetProgressRewardFeedTransaction(leaderboard.name,index);
               FarmStatsManager.featureSample(LeaderboardManager.STAT_COUNTER,"clicks","progress_reward_summary",leaderboard.name,String(index));
            }
         }
      }
   }
}

