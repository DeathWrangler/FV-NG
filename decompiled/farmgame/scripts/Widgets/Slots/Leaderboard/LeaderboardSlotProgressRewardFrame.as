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
   
   public final class LeaderboardSlotProgressRewardFrame extends ZwFrame
   {
      
      private static const ICON_SIZE:int = 25;
      
      private var m_data:Object;
      
      private var m_icon:FarmIcon;
      
      private var m_checkWidget:ZwWidget;
      
      private var m_quantityTextField:ZwTextField;
      
      private var m_rewardTextField:ZwTextField;
      
      private var m_thresholdTextField:ZwTextField;
      
      private var m_shareButton:FarmAnimatedTextButton;
      
      public function LeaderboardSlotProgressRewardFrame(element:DisplayObject)
      {
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.rewardIcon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_icon.setSmoothing(true);
         this.m_checkWidget = addWidget(new ZwWidget(m_element.check_mc)) as ZwWidget;
         addWidget(new ZwTextField(m_element.numberTitle_mc,ZLocUtils.t("Leaderboard","ScoreNeeded")));
         this.m_rewardTextField = addWidget(new ZwTextField(m_element.reward_tf,ZLocUtils.t("Leaderboard","RewardLabel"))) as ZwTextField;
         this.m_thresholdTextField = addWidget(new ZwTextField(m_element.number_tf,"")) as ZwTextField;
         this.m_quantityTextField = addWidget(new ZwTextField(m_element.qty_tf,"")) as ZwTextField;
         this.m_shareButton = addWidget(new FarmAnimatedTextButton(m_element.share_bt,ZLocUtils.t("Leaderboard","ShareButton"),this.onShareButtonClick),false) as FarmAnimatedTextButton;
      }
      
      override public function release() : void
      {
         this.m_icon = null;
         this.m_checkWidget = null;
         this.m_quantityTextField = null;
         this.m_rewardTextField = null;
         this.m_shareButton = null;
         this.m_thresholdTextField = null;
         super.release();
      }
      
      public function populate(data:Object) : void
      {
         var leaderboard:Leaderboard = null;
         var threshold:int = 0;
         var userState:LeaderboardState = null;
         var userScore:int = 0;
         var index:int = 0;
         this.m_data = data;
         if(this.m_data)
         {
            leaderboard = LeaderboardManager.getLeaderboardForWidget(this);
            if(leaderboard)
            {
               this.m_icon.loadIcon(UserRewardUtil.getImageForReward(this.m_data));
               this.m_quantityTextField.text = String(UserRewardUtil.getValueForReward(this.m_data));
               threshold = int(this.m_data["threshold"]);
               this.m_thresholdTextField.text = String(threshold);
               userState = Global.player.getLeaderboardState(leaderboard.name);
               userScore = userState ? userState.score : 0;
               if(userScore >= threshold)
               {
                  this.m_checkWidget.visible = true;
                  index = leaderboard.getIndexForProgressReward(this.m_data);
                  this.m_shareButton.visible = !userState.hasProgressFeed(index);
                  this.m_rewardTextField.visible = false;
               }
               else
               {
                  this.m_rewardTextField.visible = true;
                  this.m_checkWidget.visible = false;
                  this.m_shareButton.visible = false;
               }
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
               FarmStatsManager.featureSample(LeaderboardManager.STAT_COUNTER,"clicks","progress_reward_leaderboard",leaderboard.name,String(index));
            }
         }
      }
   }
}

