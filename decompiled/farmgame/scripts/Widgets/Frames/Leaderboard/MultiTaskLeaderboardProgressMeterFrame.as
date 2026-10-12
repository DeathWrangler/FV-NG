package Widgets.Frames.Leaderboard
{
   import Classes.util.UserRewardUtil;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class MultiTaskLeaderboardProgressMeterFrame extends ZwFrame
   {
      
      private static const REWARD_ICON_SIZE:int = 100;
      
      private static const PROFILE_ICON_SIZE:int = 50;
      
      private var m_rewardIcon:FarmIcon;
      
      private var m_rewardNameTextField:FarmTextField;
      
      private var m_rewardAmountTextField:FarmTextField;
      
      private var m_progressBar:ZwWidget;
      
      private var m_scoreTextField:FarmTextField;
      
      private var m_profileIconFrame:ZwFrame;
      
      private var m_profileIcon:FarmIcon;
      
      public function MultiTaskLeaderboardProgressMeterFrame(element:DisplayObject)
      {
         super(element);
         this.m_rewardNameTextField = addWidget(new FarmTextField(m_element.generic_tf)) as FarmTextField;
         this.m_rewardAmountTextField = addWidget(new FarmTextField(m_element.amount_tf)) as FarmTextField;
         this.m_rewardIcon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_rewardIcon.setIconSize(REWARD_ICON_SIZE,REWARD_ICON_SIZE);
         this.m_rewardIcon.setSmoothing(true);
         var stackFrame:ZwFrame = addWidget(new ZwFrame(m_element.stack_mc)) as ZwFrame;
         this.m_progressBar = stackFrame.addWidget(new ZwWidget(m_element.stack_mc.bar_mc)) as ZwWidget;
         this.m_scoreTextField = addWidget(new FarmTextField(m_element.score_tf)) as FarmTextField;
         this.m_profileIconFrame = addWidget(new ZwFrame(m_element.profile_mc)) as ZwFrame;
         this.m_profileIcon = this.m_profileIconFrame.addWidget(new FarmIcon(m_element.profile_mc.icon_mc)) as FarmIcon;
         this.m_profileIcon.setIconSize(PROFILE_ICON_SIZE,PROFILE_ICON_SIZE);
         this.m_profileIcon.setSmoothing(true);
      }
      
      override public function release() : void
      {
         this.m_rewardIcon = null;
         this.m_progressBar = null;
         this.m_rewardNameTextField = null;
         this.m_rewardAmountTextField = null;
         this.m_scoreTextField = null;
         this.m_profileIcon = null;
         super.release();
      }
      
      public function populateReward(reward:Object, userScore:int) : void
      {
         var threshold:int = 0;
         if(reward)
         {
            this.m_rewardIcon.loadIcon(UserRewardUtil.getImageForReward(reward));
            this.m_rewardIcon.visible = true;
            this.m_rewardNameTextField.text = "Next Reward";
            this.m_rewardAmountTextField.text = UserRewardUtil.getValueForReward(reward);
            threshold = int(reward["threshold"]);
            (this.m_progressBar.element as MovieClip).scaleY = userScore / threshold;
            this.m_scoreTextField.text = userScore + "/" + threshold;
         }
         this.m_profileIconFrame.visible = false;
         this.m_profileIcon.visible = false;
      }
      
      public function populatePlayer(profilePicture:String, name:String, userScore:int) : void
      {
         this.m_profileIconFrame.visible = true;
         this.m_profileIcon.loadIcon(profilePicture);
         this.m_profileIcon.visible = true;
         this.m_rewardNameTextField.text = name;
         (this.m_progressBar.element as MovieClip).scaleY = 1;
         this.m_scoreTextField.text = String(userScore);
         this.m_rewardIcon.visible = false;
      }
   }
}

