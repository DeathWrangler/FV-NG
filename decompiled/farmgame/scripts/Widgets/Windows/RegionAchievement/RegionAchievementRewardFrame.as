package Widgets.Windows.RegionAchievement
{
   import Classes.RegionAchievement.RegionAchievement;
   import Classes.util.ZLocUtils;
   import Events.RegionAchievementEvent;
   import Managers.RegionAchievementManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class RegionAchievementRewardFrame extends ZwFrame
   {
      
      private static const TITLE_TF:String = "title_tf";
      
      private static const TROPHY_TITLE_TF:String = "trophyTitle_tf";
      
      private static const TROPHY_DESC_TF:String = "trophyDescription_tf";
      
      private static const TIMER_TF:String = "timer_tf";
      
      private static const UNTIMED_REWARD_MC:String = "untimedRewards_mc";
      
      private static const TIMED_REWARD_MC:String = "timedRewards_mc";
      
      private static const BRONZE_STAR_MC:String = "bronze_mc_pb";
      
      private static const SILVER_STAR_MC:String = "silver_mc_pb";
      
      private static const GOLD_STAR_MC:String = "gold_mc_pb";
      
      private static const STARS_MC:String = "stars_mc";
      
      private static const TIMER_MC:String = "time_mc";
      
      private static const GLITTER_MC:String = "glitter_mc";
      
      private static const TROPHY_TICK:String = "completeIcon_mc";
      
      private static const TROPHY_COMPLETE_MC:String = "completeIcon_mc";
      
      private static const ICON_MC:String = "icon_0_mc";
      
      private static const PROGRESS_BAR_MC:String = "progressBar_mc";
      
      private static const BRONZE_REWARD_MC:String = "stagereward_0_mc";
      
      private static const SILVER_REWARD_MC:String = "stagereward_1_mc";
      
      private static const GOLD_REWARD_MC:String = "stagereward_2_mc";
      
      private static const REWARD_ANIMATION_MC:String = "animation_mc";
      
      private static const TROPHY_MC:String = "icon_mc";
      
      private static const SHARE_BT:String = "share_bt";
      
      private static const CLOSE_BT:String = "close_bt";
      
      public static const CLK_TROPHY:String = "CLK_TROPHY";
      
      public static const CLK_CLAIM_BTN:String = "CLK_CLAIM_BTN";
      
      private var m_title:ZwTextField;
      
      private var m_trophyTitle:ZwTextField;
      
      private var m_trophyDescription:ZwTextField;
      
      private var m_timerTf:ZwTextField;
      
      private var m_starsMC:ZwFrame;
      
      private var m_timerMC:ZwFrame;
      
      private var m_bronzeStarMC:MovieClip;
      
      private var m_silverStarMC:MovieClip;
      
      private var m_goldStarMC:MovieClip;
      
      private var m_glitterMC:MovieClip;
      
      private var m_trophyTick:MovieClip;
      
      private var m_untimedBronzeTick:ZwBaseWidget;
      
      private var m_untimedSilverTick:ZwBaseWidget;
      
      private var m_untimedGoldTick:ZwBaseWidget;
      
      private var m_timedGoldTick:ZwBaseWidget;
      
      private var m_untimedRewardMC:ZwFrame;
      
      private var m_timedRewardMC:ZwFrame;
      
      private var m_untimedBronzeReward:ZwFrame;
      
      private var m_untimedSilverReward:ZwFrame;
      
      private var m_untimedGoldReward:ZwFrame;
      
      private var m_timedGoldReward:ZwFrame;
      
      private var m_closeButton:FarmButton;
      
      private var m_shareButton:FarmButton;
      
      private var m_trophyIcon:FarmIcon;
      
      private var m_untimedBronzeRewardIcon:FarmIcon;
      
      private var m_untimedSilverRewardIcon:FarmIcon;
      
      private var m_untimedGoldRewardIcon:FarmIcon;
      
      private var m_timedGoldRewardIcon:FarmIcon;
      
      private var m_progressBar:ZwWidget;
      
      private var m_parentWindow:RegionAchievementWindow;
      
      private var m_featureName:String;
      
      private var m_achievement:RegionAchievement;
      
      private var m_window:RegionAchievementSmallRelicWindow;
      
      public function RegionAchievementRewardFrame(element:DisplayObject, featureName:String, window:RegionAchievementSmallRelicWindow)
      {
         this.m_window = window;
         this.m_featureName = featureName;
         super(element);
         addWidget(this.m_title = new ZwTextField(m_element[TITLE_TF],""));
         addWidget(this.m_trophyTitle = new ZwTextField(m_element[TROPHY_TITLE_TF],""));
         addWidget(this.m_trophyDescription = new ZwTextField(m_element[TROPHY_DESC_TF],""));
         if(m_element.hasOwnProperty(TIMER_MC))
         {
            this.m_timerMC = addWidget(new ZwFrame(m_element[TIMER_MC])) as ZwFrame;
            if(this.m_timerMC.element.hasOwnProperty(TIMER_TF))
            {
               this.m_timerMC.addWidget(this.m_timerTf = new ZwTextField(this.m_timerMC.element[TIMER_TF],""));
            }
         }
         this.m_trophyTick = m_element[TROPHY_TICK] as MovieClip;
         if(m_element.hasOwnProperty(STARS_MC))
         {
            this.m_starsMC = addWidget(new ZwFrame(m_element[STARS_MC])) as ZwFrame;
            this.m_bronzeStarMC = this.m_starsMC.element[BRONZE_STAR_MC] as MovieClip;
            this.m_silverStarMC = this.m_starsMC.element[SILVER_STAR_MC] as MovieClip;
            this.m_goldStarMC = this.m_starsMC.element[GOLD_STAR_MC] as MovieClip;
         }
         this.m_glitterMC = m_element[GLITTER_MC] as MovieClip;
         if(m_element.hasOwnProperty(UNTIMED_REWARD_MC))
         {
            addWidget(this.m_untimedRewardMC = new ZwFrame(m_element[UNTIMED_REWARD_MC]) as ZwFrame,false);
            if(this.m_untimedRewardMC.element.hasOwnProperty(BRONZE_REWARD_MC))
            {
               this.m_untimedRewardMC.addWidget(this.m_untimedBronzeReward = new ZwFrame(this.m_untimedRewardMC.element[BRONZE_REWARD_MC]) as ZwFrame);
               if(this.m_untimedRewardMC.element[BRONZE_REWARD_MC].hasOwnProperty(TROPHY_COMPLETE_MC))
               {
                  this.m_untimedBronzeReward.addWidget(this.m_untimedBronzeTick = new ZwBaseWidget(this.m_untimedRewardMC.element[BRONZE_REWARD_MC][TROPHY_COMPLETE_MC]) as ZwBaseWidget);
               }
               if(this.m_untimedRewardMC.element[BRONZE_REWARD_MC].hasOwnProperty(ICON_MC))
               {
                  this.m_untimedBronzeReward.addWidget(this.m_untimedBronzeRewardIcon = new FarmIcon(this.m_untimedRewardMC.element[BRONZE_REWARD_MC][ICON_MC]) as FarmIcon);
               }
            }
            if(this.m_untimedRewardMC.element.hasOwnProperty(SILVER_REWARD_MC))
            {
               this.m_untimedRewardMC.addWidget(this.m_untimedSilverReward = new ZwFrame(this.m_untimedRewardMC.element[SILVER_REWARD_MC]) as ZwFrame);
               if(this.m_untimedRewardMC.element[SILVER_REWARD_MC].hasOwnProperty(TROPHY_COMPLETE_MC))
               {
                  this.m_untimedSilverReward.addWidget(this.m_untimedSilverTick = new ZwBaseWidget(this.m_untimedRewardMC.element[SILVER_REWARD_MC][TROPHY_COMPLETE_MC]) as ZwBaseWidget);
               }
               if(this.m_untimedRewardMC.element[SILVER_REWARD_MC].hasOwnProperty(ICON_MC))
               {
                  this.m_untimedSilverReward.addWidget(this.m_untimedSilverRewardIcon = new FarmIcon(this.m_untimedRewardMC.element[SILVER_REWARD_MC][ICON_MC]) as FarmIcon);
               }
            }
            if(this.m_untimedRewardMC.element.hasOwnProperty(GOLD_REWARD_MC))
            {
               this.m_untimedRewardMC.addWidget(this.m_untimedGoldReward = new ZwFrame(this.m_untimedRewardMC.element[GOLD_REWARD_MC]) as ZwFrame);
               if(this.m_untimedRewardMC.element[GOLD_REWARD_MC].hasOwnProperty(TROPHY_COMPLETE_MC))
               {
                  this.m_untimedGoldReward.addWidget(this.m_untimedGoldTick = new ZwBaseWidget(this.m_untimedRewardMC.element[GOLD_REWARD_MC][TROPHY_COMPLETE_MC]) as ZwBaseWidget);
               }
               if(this.m_untimedRewardMC.element[GOLD_REWARD_MC].hasOwnProperty(ICON_MC))
               {
                  this.m_untimedGoldReward.addWidget(this.m_untimedGoldRewardIcon = new FarmIcon(this.m_untimedRewardMC.element[GOLD_REWARD_MC][ICON_MC]) as FarmIcon);
               }
            }
         }
         if(m_element.hasOwnProperty(TIMED_REWARD_MC))
         {
            addWidget(this.m_timedRewardMC = new ZwFrame(m_element[TIMED_REWARD_MC]) as ZwFrame,false);
            if(this.m_timedRewardMC.element.hasOwnProperty(BRONZE_REWARD_MC))
            {
               this.m_timedRewardMC.addWidget(this.m_timedGoldReward = new ZwFrame(this.m_timedRewardMC.element[BRONZE_REWARD_MC]) as ZwFrame);
               if(this.m_timedRewardMC.element[BRONZE_REWARD_MC].hasOwnProperty(TROPHY_COMPLETE_MC))
               {
                  this.m_timedGoldReward.addWidget(this.m_timedGoldTick = new ZwBaseWidget(this.m_timedRewardMC.element[BRONZE_REWARD_MC][TROPHY_COMPLETE_MC]) as ZwBaseWidget);
               }
               if(this.m_timedRewardMC.element[BRONZE_REWARD_MC].hasOwnProperty(ICON_MC))
               {
                  this.m_timedGoldReward.addWidget(this.m_timedGoldRewardIcon = new FarmIcon(this.m_timedRewardMC.element[BRONZE_REWARD_MC][ICON_MC]) as FarmIcon);
               }
            }
         }
         if(m_element.hasOwnProperty(TROPHY_MC))
         {
            if(m_element.hasOwnProperty(TROPHY_MC))
            {
               addWidget(this.m_trophyIcon = new FarmIcon(m_element[TROPHY_MC]) as FarmIcon);
            }
         }
         this.m_progressBar = addWidget(new ZwWidget(m_element[PROGRESS_BAR_MC])) as ZwWidget;
         if(Boolean(m_element) && m_element.hasOwnProperty(SHARE_BT))
         {
            this.m_shareButton = addWidget(new FarmAnimatedTextButton(m_element[SHARE_BT],ZLocUtils.t("Dialogs",this.m_featureName + "_trophy_reward_window_cta"),this.onShare)) as FarmButton;
         }
         if(Boolean(m_element) && m_element.hasOwnProperty(CLOSE_BT))
         {
            this.m_closeButton = addWidget(new FarmButton(m_element[CLOSE_BT],this.onClose)) as FarmButton;
         }
      }
      
      public function refresh(achievement:RegionAchievement) : void
      {
         this.m_achievement = achievement;
         this.resetVisibility();
         this.loadTexts();
         this.loadIcons();
         if(this.m_achievement.goldTrophyWon)
         {
            this.m_trophyTick.visible = true;
         }
         if(this.m_achievement.timed)
         {
            if(this.m_achievement.getAndResetTrophyState(RegionAchievement.GOLD,false))
            {
               this.m_timedGoldTick.visible = true;
               this.m_glitterMC.visible = true;
               this.m_glitterMC.play();
               this.playRewardAnimation(this.m_timedGoldReward);
               this.m_shareButton.visible = true;
            }
            if(this.m_achievement.isTrophyClaimed(RegionAchievement.GOLD))
            {
               this.m_timedGoldTick.visible = true;
               this.m_goldStarMC.gotoAndStop(1);
            }
            if(!this.m_achievement.dismissed && !this.m_achievement.goldTrophyWon)
            {
               this.m_timerMC.visible = true;
               this.m_timerTf.text = this.m_achievement.expiryTimer;
            }
         }
         else
         {
            if(this.m_achievement.getAndResetTrophyState(RegionAchievement.BRONZE,false))
            {
               this.m_untimedBronzeTick.visible = true;
               this.playRewardAnimation(this.m_untimedBronzeReward);
               this.m_shareButton.visible = true;
            }
            if(this.m_achievement.getAndResetTrophyState(RegionAchievement.SILVER,false))
            {
               this.m_untimedSilverTick.visible = true;
               this.playRewardAnimation(this.m_untimedSilverReward);
               this.m_shareButton.visible = true;
            }
            if(this.m_achievement.getAndResetTrophyState(RegionAchievement.GOLD,false))
            {
               this.m_untimedGoldTick.visible = true;
               this.m_glitterMC.visible = true;
               this.m_glitterMC.play();
               this.playRewardAnimation(this.m_untimedGoldReward);
               this.m_shareButton.visible = true;
            }
            if(this.m_achievement.isTrophyClaimed(RegionAchievement.BRONZE))
            {
               this.m_untimedBronzeTick.visible = true;
               this.m_bronzeStarMC.gotoAndStop(1);
            }
            if(this.m_achievement.isTrophyClaimed(RegionAchievement.SILVER))
            {
               this.m_untimedSilverTick.visible = true;
               this.m_silverStarMC.gotoAndStop(1);
            }
            if(this.m_achievement.isTrophyClaimed(RegionAchievement.GOLD))
            {
               this.m_untimedGoldTick.visible = true;
               this.m_goldStarMC.gotoAndStop(1);
            }
         }
         this.m_achievement.getAndResetTrophyState(RegionAchievement.BRONZE);
         this.m_achievement.getAndResetTrophyState(RegionAchievement.SILVER);
         this.m_achievement.getAndResetTrophyState(RegionAchievement.GOLD);
         this.setProgressBar();
      }
      
      private function resetVisibility() : void
      {
         this.m_starsMC.visible = true;
         this.m_bronzeStarMC.gotoAndStop(2);
         this.m_silverStarMC.gotoAndStop(2);
         this.m_goldStarMC.gotoAndStop(2);
         this.m_glitterMC.visible = false;
         this.m_progressBar.visible = true;
         this.stopRewardAnimation(this.m_untimedBronzeReward);
         this.stopRewardAnimation(this.m_untimedSilverReward);
         this.stopRewardAnimation(this.m_untimedGoldReward);
         this.stopRewardAnimation(this.m_timedGoldReward);
         this.m_trophyTick.visible = false;
         this.m_untimedBronzeTick.visible = false;
         this.m_untimedSilverTick.visible = false;
         this.m_untimedGoldTick.visible = false;
         this.m_timedGoldTick.visible = false;
         this.m_shareButton.visible = false;
         if(Boolean(this.m_achievement) && this.m_achievement.timed)
         {
            this.m_bronzeStarMC.visible = false;
            this.m_silverStarMC.visible = false;
            this.m_goldStarMC.visible = true;
            this.m_timedRewardMC.visible = true;
            this.m_untimedRewardMC.visible = false;
         }
         else
         {
            this.m_timerMC.visible = false;
            this.m_bronzeStarMC.visible = true;
            this.m_silverStarMC.visible = true;
            this.m_goldStarMC.visible = true;
            this.m_timedRewardMC.visible = false;
            this.m_untimedRewardMC.visible = true;
         }
      }
      
      private function loadTexts() : void
      {
         if(this.m_achievement)
         {
            this.m_title.text = this.trophyRewardWindowTitle();
            this.m_trophyTitle.text = this.m_achievement.trophyTitle;
            if(this.m_achievement.timed && this.m_achievement.expired && !this.m_achievement.completed)
            {
               this.m_trophyDescription.text = ZLocUtils.t("Dialogs",this.m_featureName + "_timed_ach_desc_expired");
            }
            else
            {
               this.m_trophyDescription.text = this.trophyDescription();
            }
         }
      }
      
      private function setProgressBar() : void
      {
         var totalFrames:int = 0;
         var progress:int = 0;
         if(Boolean(this.m_progressBar) && Boolean(this.m_progressBar.element))
         {
            totalFrames = int(this.m_progressBar.element.totalFrames);
            progress = totalFrames / this.m_achievement.numOfMilestones * this.m_achievement.numOfMileStonesCompleted;
            this.m_progressBar.element.gotoAndStop(progress);
            this.m_progressBar.attachTooltip(new FarmTextTooltip(this.m_achievement.getProgressBarToolTip()));
         }
      }
      
      private function loadIcons() : void
      {
         if(this.m_achievement)
         {
            this.m_trophyIcon.loadIcon(this.m_achievement.rewardWindowTrophyUrl);
            if(!this.m_achievement.goldTrophyWon)
            {
               this.m_trophyIcon.attachTooltip(new FarmTextTooltip(this.trophyRolloverText()));
            }
            if(this.m_achievement.timed)
            {
               this.m_timedGoldRewardIcon.loadIcon(this.m_achievement.milestoneRewardIconUrl(RegionAchievement.GOLD));
               this.m_timedGoldRewardIcon.attachTooltip(new FarmTextTooltip(this.m_achievement.milestoneRewardName(RegionAchievement.GOLD)));
            }
            else
            {
               this.m_untimedBronzeRewardIcon.loadIcon(this.m_achievement.milestoneRewardIconUrl(RegionAchievement.BRONZE));
               this.m_untimedSilverRewardIcon.loadIcon(this.m_achievement.milestoneRewardIconUrl(RegionAchievement.SILVER));
               this.m_untimedGoldRewardIcon.loadIcon(this.m_achievement.milestoneRewardIconUrl(RegionAchievement.GOLD));
               this.m_untimedBronzeRewardIcon.attachTooltip(new FarmTextTooltip(this.m_achievement.milestoneRewardName(RegionAchievement.BRONZE)));
               this.m_untimedSilverRewardIcon.attachTooltip(new FarmTextTooltip(this.m_achievement.milestoneRewardName(RegionAchievement.SILVER)));
               this.m_untimedGoldRewardIcon.attachTooltip(new FarmTextTooltip(this.m_achievement.milestoneRewardName(RegionAchievement.GOLD)));
            }
         }
      }
      
      private function playRewardAnimation(elem:ZwFrame) : void
      {
         if(elem.element.hasOwnProperty(REWARD_ANIMATION_MC))
         {
            (elem.element[REWARD_ANIMATION_MC] as MovieClip).visible = true;
            (elem.element[REWARD_ANIMATION_MC] as MovieClip).play();
         }
      }
      
      private function stopRewardAnimation(elem:ZwFrame) : void
      {
         if(elem.element.hasOwnProperty(REWARD_ANIMATION_MC))
         {
            (elem.element[REWARD_ANIMATION_MC] as MovieClip).visible = false;
            (elem.element[REWARD_ANIMATION_MC] as MovieClip).stop();
         }
      }
      
      private function onShare(event:Event = null) : void
      {
         RegionAchievementManager.getInstance(this.m_featureName).shareBragFeed(this.m_achievement.trophyReward.friendlyName);
         this.onClose();
      }
      
      private function onClose(event:Event = null) : void
      {
         this.m_timedGoldRewardIcon.detachTooltip();
         this.m_trophyIcon.detachTooltip();
         this.m_untimedBronzeRewardIcon.detachTooltip();
         this.m_untimedSilverRewardIcon.detachTooltip();
         this.m_untimedGoldRewardIcon.detachTooltip();
         this.m_progressBar.detachTooltip();
         element.visible = false;
         if(this.m_window)
         {
            this.m_window.close();
         }
         var toggleNPCEvent:RegionAchievementEvent = new RegionAchievementEvent(RegionAchievementEvent.TOGGLE_MAIN_WINDOW_NPC,{"visible":true});
         RegionAchievementManager.getInstance(this.m_featureName).dispatchRegionAchievementEvent(toggleNPCEvent);
         RegionAchievementManager.getInstance(this.m_featureName).dispatchRegionAchievementEvent(new RegionAchievementEvent(RegionAchievementEvent.EXECUTE_NEXT_ACTION));
      }
      
      private function trophyDescription() : String
      {
         var descParams:Object = null;
         var result:String = "";
         if(this.m_achievement.goldTrophyWon)
         {
            result = ZLocUtils.t("Dialogs",this.m_featureName + "_trophy_reward_window_gold_won");
         }
         else if(this.m_achievement.trophyWon >= RegionAchievementManager.BRONZE_TROPHY && (this.m_achievement.getAndResetTrophyState(RegionAchievement.BRONZE,false) || this.m_achievement.getAndResetTrophyState(RegionAchievement.SILVER,false)))
         {
            result = ZLocUtils.t("Dialogs",this.m_featureName + "_trophy_reward_window_trophy_won");
         }
         else
         {
            descParams = this.m_achievement.descriptionParams();
            if(Boolean(descParams) && descParams.hasOwnProperty("description"))
            {
               result = ZLocUtils.t("Dialogs",this.m_featureName + "_trophy_reward_window_trophy_desc_" + descParams.milestoneType,{"description":descParams.description});
            }
         }
         return result;
      }
      
      private function trophyRewardWindowTitle() : String
      {
         var isCongrats:Boolean = this.m_achievement.getAndResetTrophyState(RegionAchievement.BRONZE,false) || this.m_achievement.getAndResetTrophyState(RegionAchievement.SILVER,false) || this.m_achievement.getAndResetTrophyState(RegionAchievement.GOLD,false) || this.m_achievement.goldTrophyWon;
         if(isCongrats)
         {
            return ZLocUtils.t("Dialogs",this.m_featureName + "_congrats");
         }
         return ZLocUtils.t("Dialogs",this.m_featureName + "_trophy_reward_window_title");
      }
      
      private function trophyRolloverText() : String
      {
         return ZLocUtils.t("Dialogs",this.m_featureName + "_trophy_reward_window_trophy_rollover");
      }
      
      private function trophyTitle() : String
      {
         return ZLocUtils.t("Dialogs",this.m_featureName + "_trophy_reward_window_trophy_title",{"trophyName":this.m_achievement.trophyTitle});
      }
   }
}

