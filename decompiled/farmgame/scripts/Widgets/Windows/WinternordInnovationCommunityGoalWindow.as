package Widgets.Windows
{
   import Classes.WinternordInnovationCommunityGoalTask;
   import Classes.ZItem.FarmItem;
   import Display.HUD.HUD;
   import Managers.WinternordInnovationManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.WinternordInnovationLeaderboardSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import mx.utils.StringUtil;
   
   public class WinternordInnovationCommunityGoalWindow extends FarmWindow
   {
      
      private static const SUBTITLE_TF:String = "subtitle_tf";
      
      private static const POINTS2_TF:String = "points2_tf";
      
      private static const LEADERBOARD_MC:String = "leaderboard_mc";
      
      private static const MESSAGE_TF:String = "message_tf";
      
      private static const LOADER_MC:String = "loader_mc";
      
      private static const MC_HIGHLIGHTBG:String = "mc_highlightbg";
      
      private static const ICON_MC:String = "icon_mc";
      
      private static const BADGE_ICONS:Array = ["assets/newsfeed/specialsnowflakebadge_icon.png","assets/newsfeed/outstandingornamentbadge_icon.png","assets/newsfeed/wreathofwonderbadge_icon.png"];
      
      private static const SERVICE_NAME:String = "WinternordInnovationService";
      
      private static const VAL_NEIGHBOUR_LEADERBOARD:String = "neighborData";
      
      private const PROGRESS_BAR_FULL_WIDTH:int = 246;
      
      private const BADGE_NAMES:Array = ["Special Snowflake Badge","Outstanding Ornament Badge","Wreath Of Wonder Badge"];
      
      private var m_featureName:String = null;
      
      private var m_timer:Timer;
      
      private const TITLE_TF:String = "title_tf";
      
      private var m_timer_mc:MovieClip;
      
      private var m_rewards_mc:MovieClip;
      
      private var m_Reward_mc:MovieClip;
      
      private var m_leaderboard_mc:MovieClip;
      
      private var m_loader_mc:MovieClip;
      
      private var timeleft_frame:ZwFrame;
      
      private var FEATURE_NAME:String = "WinternordInnovation";
      
      public var m_communityScore:Number = 0;
      
      private var m_badgesMC:Array = [];
      
      private var m_badgesIcons:Array = [];
      
      private var m_task:WinternordInnovationCommunityGoalTask;
      
      private var m_timer_tf:ZwTextField;
      
      private var m_owner:WinternordInnovationMainWindow;
      
      private var m_showReward:Boolean;
      
      private var m_checkmarkMc:MovieClip;
      
      private var m_titleTf:ZwTextField;
      
      private var m_conTf:ZwTextField;
      
      private var m_eligibilityTf:ZwTextField;
      
      private var m_highlightMc:MovieClip;
      
      private var m_lockMc:MovieClip;
      
      private var m_progressBarMc:MovieClip;
      
      private var m_percentTf:ZwTextField;
      
      private var m_prizeMc:FarmIcon;
      
      private var m_iconMc:FarmIcon;
      
      private var m_goalTF:ZwTextField;
      
      private var m_leaderboardFrame:WinternordInnovationLeaderboardSlotFrame;
      
      private var m_result:Object;
      
      private var m_leaderboards:Vector.<WinternordInnovationLeaderboardSlotFrame> = new Vector.<WinternordInnovationLeaderboardSlotFrame>();
      
      private var m_messageTf:ZwTextField;
      
      private var m_playerRank:Number;
      
      public function WinternordInnovationCommunityGoalWindow(assetPath:String = "", featureName:String = null, ownerWindow:WinternordInnovationMainWindow = null, task:WinternordInnovationCommunityGoalTask = null, showReward:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_owner = ownerWindow;
         this.m_task = task;
         this.m_showReward = showReward;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var leaderboardMc:MovieClip = null;
         var badgeName:String = null;
         var timeLeftInWeek:Number = NaN;
         super.postLoadComplete();
         if(this.m_task)
         {
            this.manager.getCommunityProgressForTask(this.m_task.name,this.updateCommunityScore);
         }
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Yuletide Community Goals"));
            m_window[this.TITLE_TF].visible = true;
         }
         if(m_window.hasOwnProperty(SUBTITLE_TF))
         {
            addWidget(new ZwTextField(m_window[SUBTITLE_TF],"Complete tasks on the orderboard and win rewards together!"));
         }
         if(m_window.hasOwnProperty(POINTS2_TF))
         {
            addWidget(new ZwTextField(m_window[POINTS2_TF],this.manager.getLifetimeOrders().toString()));
         }
         if(m_window.hasOwnProperty("goal_tf"))
         {
            addWidget(this.m_goalTF = new ZwTextField(m_window["goal_tf"],""));
         }
         if(m_window.hasOwnProperty("check_mc"))
         {
            this.m_checkmarkMc = m_window["check_mc"] as MovieClip;
         }
         if(m_window.hasOwnProperty("points1_tf"))
         {
            this.m_conTf = new ZwTextField(m_window["points1_tf"]);
         }
         if(m_window.hasOwnProperty("eligibility_tf"))
         {
            this.m_eligibilityTf = new ZwTextField(m_window["eligibility_tf"]);
         }
         if(m_window.hasOwnProperty("highlight_mc"))
         {
            this.m_highlightMc = m_window["highlight_mc"] as MovieClip;
         }
         if(m_window.hasOwnProperty("icon_mc"))
         {
            addWidget(this.m_iconMc = new FarmIcon(m_window["icon_mc"]));
         }
         if(m_window.hasOwnProperty("lock_mc"))
         {
            this.m_lockMc = m_window["lock_mc"] as MovieClip;
            this.m_lockMc.visible = true;
         }
         if(m_window.hasOwnProperty("meter_mc"))
         {
            this.m_progressBarMc = m_window["meter_mc"] as MovieClip;
            this.updateProgressBar(0,1);
            this.m_progressBarMc.visible = true;
         }
         if(m_window.hasOwnProperty("percent_tf"))
         {
            this.m_percentTf = new ZwTextField(m_window["percent_tf"],"0%");
            this.m_percentTf.visible = true;
         }
         if(m_window.hasOwnProperty("title_tf"))
         {
            this.m_titleTf = new ZwTextField(m_window["title_tf"]);
            this.m_titleTf.visible = true;
         }
         if(m_window.hasOwnProperty("prize_mc"))
         {
            addWidget(this.m_prizeMc = new FarmIcon(m_window["prize_mc"]));
         }
         if(m_window.hasOwnProperty(LEADERBOARD_MC))
         {
            leaderboardMc = m_window[LEADERBOARD_MC];
            leaderboardMc.visible = true;
            this.m_leaderboardFrame = new WinternordInnovationLeaderboardSlotFrame(leaderboardMc,null,this.m_featureName,this);
            this.m_leaderboards.push(this.m_leaderboardFrame);
            addWidget(this.m_leaderboardFrame,true);
            if(leaderboardMc.hasOwnProperty(MESSAGE_TF))
            {
               addWidget(this.m_messageTf = new ZwTextField(leaderboardMc[MESSAGE_TF],"Message TF"),false);
               this.m_messageTf.visible = false;
            }
            if(leaderboardMc.hasOwnProperty(LOADER_MC))
            {
               this.m_loader_mc = leaderboardMc[LOADER_MC] as MovieClip;
               this.m_loader_mc.visible = true;
            }
         }
         for(var i:int = 0; i < 3; i++)
         {
            badgeName = StringUtil.substitute("badge{0}_mc",i);
            if(m_window.hasOwnProperty(badgeName))
            {
               this.m_badgesMC.push(m_window[badgeName] as MovieClip);
               if(this.m_badgesMC[i].hasOwnProperty(ICON_MC))
               {
                  this.m_badgesIcons.push(new FarmIcon(this.m_badgesMC[i][ICON_MC]));
                  this.m_badgesIcons[i].loadIcon(BADGE_ICONS[i]);
                  this.m_badgesIcons[i].setIconSize(50,50);
                  this.m_badgesIcons[i].setSmoothing(true);
                  if(this.hasReceivedBadge(i))
                  {
                     this.m_badgesIcons[i].visible = true;
                     this.attachTooltipToBadge(this.m_badgesIcons[i],this.manager.getBadgeTooltipText(true,i));
                  }
                  else
                  {
                     this.attachTooltipToBadge(this.m_badgesIcons[i],this.manager.getBadgeTooltipText(false,i));
                     this.m_badgesIcons[i].applyGrayOut = true;
                  }
               }
               this.m_badgesMC[i].visible = true;
            }
         }
         if(m_window.hasOwnProperty("timer_mc"))
         {
            this.m_timer_mc = m_window["timer_mc"] as MovieClip;
            this.m_timer_mc.visible = true;
            if(this.m_timer_mc.hasOwnProperty("timer_tf"))
            {
               addWidget(this.m_timer_tf = new ZwTextField(this.m_timer_mc["timer_tf"]));
               timeLeftInWeek = this.manager.getTimeLeftInWeek();
               if(timeLeftInWeek == -1)
               {
                  this.m_timer_mc.visible = false;
               }
               else
               {
                  this.m_timer_tf.text = HUD.getformattedTimeLeft(timeLeftInWeek) + " Left";
               }
            }
         }
         if(this.manager.getLifetimeOrders() > 0)
         {
            this.manager.initializeCommGoalLeaderboard();
         }
         else
         {
            this.m_loader_mc.visible = false;
            this.m_messageTf.visible = true;
            this.m_messageTf.text = "Redeem a completed task from your orders to be a part of this Leaderboard and win exciting prizes!";
         }
         this.populateGoalData();
         this.startTimer();
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(this.m_messageTf.visible == false)
         {
            m_closeButton.visible = false;
         }
      }
      
      public function attachTooltipToBadge(icon:FarmIcon, msg:String) : void
      {
         if(icon.tooltip)
         {
            icon.tooltip.release();
         }
         icon.detachTooltip();
         icon.attachTooltip(new FarmTextTooltip(msg));
      }
      
      private function populateGoalData() : void
      {
         var rewardItem:FarmItem = null;
         var rewardQty1:int = 0;
         var iconUrl:String = null;
         var playerProg:int = this.manager.getCommGoalPlayerCountForTask(this.m_task.name);
         var pointsRemaining:int = this.manager.getCommunityGoalTaskRemainingPoints();
         if(this.m_goalTF)
         {
            this.m_goalTF.text = "Finish " + this.m_task.communityGoal + " tasks together on the Orderboard this week!";
            this.m_goalTF.visible = true;
         }
         if(this.m_conTf)
         {
            this.m_conTf.text = "Your contribution: " + playerProg;
            this.m_conTf.visible = true;
         }
         if(this.m_eligibilityTf)
         {
            if(playerProg > 0)
            {
               this.m_eligibilityTf.text = "You need to complete " + pointsRemaining + " tasks to be eligible for the community reward!";
            }
            else
            {
               this.m_eligibilityTf.text = "You need to complete " + pointsRemaining + " tasks to be eligible for the community reward!";
            }
         }
         if(this.m_prizeMc)
         {
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_task.rewards.@name);
            rewardQty1 = int(this.m_task.rewards.@qty);
            if(rewardItem)
            {
               iconUrl = rewardItem.getImageByName(FarmItem.ICON_FEED);
               this.m_prizeMc.loadIcon(iconUrl);
               this.m_prizeMc.setIconSize(70,70);
               this.m_prizeMc.setSmoothing(true);
               this.m_prizeMc.visible = true;
               this.m_prizeMc.attachTooltip(new FarmTextTooltip(rewardQty1.toString() + "x" + rewardItem.friendlyTitle));
            }
         }
         if(this.m_iconMc)
         {
            this.m_iconMc.loadIcon(Global.getAssetURL("assets/newsfeed/gifitbox_icon.png"));
            this.m_prizeMc.setIconSize(70,70);
            this.m_prizeMc.setSmoothing(true);
            this.m_prizeMc.visible = true;
            this.m_iconMc.visible = true;
         }
         if(this.m_communityScore)
         {
            this.updateProgressBar(this.m_communityScore,this.m_task.communityGoal);
            if(this.m_percentTf)
            {
               this.m_percentTf.text = Math.floor(this.m_communityScore / this.m_task.communityGoal * 100) + "%";
            }
         }
         if(this.m_task.playerGoal > playerProg)
         {
            this.m_lockMc.visible = true;
            this.m_eligibilityTf.visible = true;
         }
         else
         {
            this.m_lockMc.visible = false;
            this.m_eligibilityTf.visible = false;
            if(!this.manager.isCommGoalRewardGranted(this.m_task.name,1))
            {
               this.checkForCommunityGoalReward();
            }
         }
         if(Boolean(this.manager.isCommGoalRewardGranted(this.m_task.name,1)) && Boolean(this.m_highlightMc) && Boolean(this.m_checkmarkMc))
         {
            this.m_highlightMc.visible = true;
            this.m_checkmarkMc.visible = true;
         }
      }
      
      private function updateProgressBar(percentValue:Number, goal:Number) : void
      {
         percentValue = Math.floor(percentValue / goal * 100);
         if(percentValue > 100)
         {
            percentValue = 100;
         }
         var barWidth:Number = percentValue * this.PROGRESS_BAR_FULL_WIDTH / 100;
         if(this.m_progressBarMc.bar_mc)
         {
            if(percentValue == 0)
            {
               (this.m_progressBarMc.bar_mc as MovieClip).width = barWidth;
            }
            else
            {
               TweenMax.to(this.m_progressBarMc.bar_mc,2,{"width":barWidth});
            }
         }
      }
      
      public function populateLeaderboard(result:Object) : void
      {
         var userData:Object = null;
         var leaderboardData:Object = null;
         if(result)
         {
            this.m_result = result;
            if(result["userData"])
            {
               userData = result["userData"];
               this.m_playerRank = userData.rank;
            }
            if(this.m_leaderboards)
            {
               leaderboardData = null;
               leaderboardData = this.m_result[VAL_NEIGHBOUR_LEADERBOARD];
               this.m_leaderboards[0].finishLoading(leaderboardData,false);
            }
            if(this.m_messageTf != null)
            {
               this.m_messageTf.visible = false;
            }
            if(this.m_timer)
            {
               this.stopTimer();
            }
         }
         m_closeButton.visible = true;
         this.m_loader_mc.visible = false;
      }
      
      public function hasReceivedBadge(index:int) : Boolean
      {
         return [this.manager.isFirstBadgeRecieved,this.manager.isSecondBadgeRecieved,this.manager.isThirdBadgeRecieved][index]();
      }
      
      public function updateCommunityScore(score:Number) : void
      {
         this.m_communityScore = score;
         this.updateCommunityProgress();
      }
      
      public function updateCommunityProgress() : void
      {
         if(this.m_communityScore)
         {
            this.updateProgressBar(this.m_communityScore,this.m_task.communityGoal);
            if(this.m_percentTf)
            {
               this.m_percentTf.text = Math.floor(this.m_communityScore / this.m_task.communityGoal * 100) + "%";
            }
         }
      }
      
      public function checkForCommunityGoalReward() : void
      {
         this.manager.initializeCommunityRewardGrant();
      }
      
      private function get manager() : WinternordInnovationManager
      {
         return WinternordInnovationManager.getInstance();
      }
      
      override public function close() : void
      {
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
         }
         this.stopTimer();
         super.close();
      }
      
      public function refreshCommGoalWindow() : void
      {
         if(Boolean(this.manager.isCommGoalRewardGranted(this.m_task.name,1)) && Boolean(this.m_highlightMc) && Boolean(this.m_checkmarkMc))
         {
            this.m_highlightMc.visible = true;
            this.m_checkmarkMc.visible = true;
         }
      }
      
      public function isEligibleForRewards() : Boolean
      {
         var result:Boolean = false;
         var playerCount:Number = this.manager.getCommGoalPlayerCountForTask(this.m_task.name);
         if(playerCount >= this.m_task.playerGoal)
         {
            result = true;
         }
         return result;
      }
      
      private function startTimer() : void
      {
         this.m_timer = new Timer(13000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
      }
      
      private function stopTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         m_closeButton.visible = true;
      }
   }
}

