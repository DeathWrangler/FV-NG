package Widgets.Windows
{
   import Display.HUD.HUD;
   import Managers.RussiaInnovationManager;
   import Managers.TimedSlotGiveawaysManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.RussiaInnovationLeaderboardSlotFrame;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class RussiaInnovationLeaderboardWindow extends FarmWindow
   {
      
      private static const SERVICE_NAME:String = "RussiaInnovationService";
      
      private static const VAL_GLOBAL_LEADERBOARD:String = "globalLeaderboardData";
      
      private static const VAL_PREVIOUS_LEADERBOARD:String = "previousLeaderboardData";
      
      private var m_featureName:String = null;
      
      private var m_timer:Timer;
      
      private var m_subFeatureName:String = null;
      
      private var m_callback:Function = null;
      
      private const TITLE_TF:String = "title_tf";
      
      private var m_timer_mc:MovieClip;
      
      private var m_rewards_mc:MovieClip;
      
      private var m_Reward_mc:MovieClip;
      
      private var m_leaderboard_mc:MovieClip;
      
      protected var m_highlightbgMc:MovieClip;
      
      private var m_loader_mc:MovieClip;
      
      private var timeleft_frame:ZwFrame;
      
      private var FEATURE_NAME:String = "RussiaInnovation";
      
      private var m_playerRank:Number;
      
      private var m_leaderboards:Vector.<RussiaInnovationLeaderboardSlotFrame> = new Vector.<RussiaInnovationLeaderboardSlotFrame>();
      
      private const LEADERBOARD_WELCOME_SEEN_FLAG:String = "Leaderboard_Reward_Welcome_flag";
      
      private const LAST_DAY_WEEK:String = "Last_Day_Of_Week";
      
      private var m_talkMc:MovieClip;
      
      private var m_npc1Tf:ZwTextField;
      
      private var m_npc2Tf:ZwTextField;
      
      private var m_weekTf:ZwTextField;
      
      private var m_weekRewardTf:ZwTextField;
      
      private var m_talkAutoMc:MovieClip;
      
      private var m_autoTalkMc:MovieClip;
      
      private var m_autoNpc1Tf:ZwTextField;
      
      private var m_autoNpc2Tf:ZwTextField;
      
      private var m_weekCount:int = 0;
      
      private var m_weekMc:MovieClip;
      
      private var m_showGift:Boolean;
      
      private var m_messageTf:ZwTextField;
      
      private var m_timer_tf:ZwTextField;
      
      private const MAX_NO_OF_REWARDS:Number = 4;
      
      private const NO_OF_WEEKS:int = 6;
      
      public function RussiaInnovationLeaderboardWindow(assetPath:String = "", featureName:String = null, subFeatureName:String = null, callBack:Function = null, showGift:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_callback = callBack;
         this.m_subFeatureName = subFeatureName;
         this.m_showGift = showGift;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var timeLeftInWeek:Number = NaN;
         var leaderBoardData:Object = null;
         var weekCount:int = 0;
         var weekText:String = null;
         var leaderboard:RussiaInnovationLeaderboardSlotFrame = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Wham Leaderboard"));
         }
         if(m_window.hasOwnProperty("npc_mc"))
         {
            m_window["npc_mc"].visible = true;
         }
         if(m_window.hasOwnProperty("talk_mc"))
         {
            this.m_talkMc = m_window.talk_mc as MovieClip;
            this.m_talkMc.visible = false;
            addWidget(this.m_npc1Tf = new ZwTextField(this.m_talkMc["npc1_tf"],"npc1"));
            addWidget(this.m_npc2Tf = new ZwTextField(this.m_talkMc["npc2_tf"],"Default NPC Text"));
         }
         if(m_window.hasOwnProperty("talk_auto_mc"))
         {
            this.m_talkAutoMc = m_window.talk_auto_mc as MovieClip;
            this.m_talkAutoMc.visible = false;
            if(this.m_talkAutoMc.hasOwnProperty("talk_mc"))
            {
               this.m_autoTalkMc = this.m_talkAutoMc.talk_mc as MovieClip;
               this.m_autoTalkMc.visible = true;
               this.m_autoNpc1Tf = new ZwTextField(this.m_autoTalkMc["npc1_tf"]," Auto npc1");
               this.m_autoNpc2Tf = new ZwTextField(this.m_autoTalkMc["npc2_tf"],"Auto Default NPC Text");
            }
         }
         if(!this.hasSeenFeatureWelcome())
         {
            Global.player.setSeenFlag(this.LEADERBOARD_WELCOME_SEEN_FLAG);
            this.showAutoHideNPCCallouts("Strike the Leaderboard!","The points on your Wham meter add to your Leaderboard score. Do more tasks after reaching ‘Strongest’ to get ahead on it!");
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
         if(m_window.hasOwnProperty("subtitle_tf"))
         {
            addWidget(new ZwTextField(m_window["subtitle_tf"],"Compete in the Wham Leaderboard every week to win Powerful rewards!"));
         }
         if(this.m_weekMc)
         {
            this.m_weekMc.visible = false;
         }
         if(this.m_weekCount == 0)
         {
            leaderBoardData = this.manager.getCurrentLeaderboard();
            if(leaderBoardData)
            {
               this.m_weekCount = leaderBoardData.count;
               weekCount = this.m_weekCount;
               if(this.m_showGift)
               {
                  --this.m_weekCount;
               }
            }
            else
            {
               this.m_weekCount = this.NO_OF_WEEKS;
            }
         }
         if(m_window.hasOwnProperty("rewards_mc"))
         {
            this.m_rewards_mc = m_window["rewards_mc"] as MovieClip;
            this.m_rewards_mc.visible = true;
            if(this.m_rewards_mc.hasOwnProperty("Reward_mc"))
            {
               this.m_Reward_mc = this.m_rewards_mc.Reward_mc;
               this.m_Reward_mc.gotoAndStop(this.m_weekCount);
            }
            if(this.m_rewards_mc.hasOwnProperty("week_tf"))
            {
               weekText = "Week " + this.m_weekCount.toString() + " Wham Rewards";
               addWidget(this.m_weekTf = new ZwTextField(this.m_rewards_mc["week_tf"],weekText));
            }
         }
         if(m_window.hasOwnProperty("leaderboard_mc"))
         {
            this.m_leaderboard_mc = m_window["leaderboard_mc"] as MovieClip;
            this.m_leaderboard_mc.visible = true;
            leaderboard = new RussiaInnovationLeaderboardSlotFrame(this.m_leaderboard_mc,null,this.m_featureName,this);
            this.m_leaderboards.push(leaderboard);
            addWidget(leaderboard,true);
            if(this.m_leaderboard_mc.hasOwnProperty("message_tf"))
            {
               addWidget(this.m_messageTf = new ZwTextField(this.m_leaderboard_mc["message_tf"]));
               this.m_messageTf.visible = false;
            }
            if(this.m_leaderboard_mc.mc_highlightbg != null)
            {
               this.m_highlightbgMc = this.m_leaderboard_mc.mc_highlightbg;
               this.m_highlightbgMc.visible = false;
            }
         }
         if(this.m_leaderboard_mc.hasOwnProperty("loader_mc"))
         {
            this.m_loader_mc = this.m_leaderboard_mc["loader_mc"] as MovieClip;
            this.m_loader_mc.visible = true;
         }
         if(this.manager.getWeeklyRewardPoints() > 0 || weekCount == 1)
         {
            this.manager.initializeLeaderBoardProgress();
         }
         else
         {
            this.m_loader_mc.visible = false;
            this.m_messageTf.visible = true;
            this.m_messageTf.text = "Redeem a completed task from your orders to be a part of this Leaderboard and win exciting prizes!";
         }
         if(this.manager.checkLastDayInWeek() <= 1 && Global.player.getSeenFlag(this.LAST_DAY_WEEK) == false && this.manager.getTimeLeftInWeek() != -1)
         {
            this.showAutoHideNPCCallouts("Tick Tock...","Time is almost up! Collect points to win powerful rewards! Leaderboard refreshes in " + HUD.getformattedTimeLeft(this.manager.getTimeLeftInWeek()));
            Global.player.setSeenFlag(this.LAST_DAY_WEEK);
         }
         if(this.m_showGift)
         {
            this.m_timer_mc.visible = false;
         }
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
      
      private function showgift() : void
      {
         this.m_rewards_mc.visible = false;
         var weekMc:String = "week" + this.m_weekCount.toString() + "_mc";
         this.m_weekMc = m_window[weekMc];
         this.m_weekMc.visible = true;
         var giftFrame:Number = this.m_playerRank <= 3 ? this.m_playerRank : 4;
         this.m_weekMc.gotoAndStop(giftFrame);
         if(this.m_weekMc.hasOwnProperty("title_tf"))
         {
            this.m_weekRewardTf = new ZwTextField(this.m_weekMc["title_tf"],"You have won these rewards!");
            this.m_weekRewardTf.visible = true;
         }
         var no_of_rewards:Number = this.MAX_NO_OF_REWARDS - giftFrame + 1;
         var calloutText:String = "In Week " + this.m_weekCount.toString() + " Leaderboard, your position is " + this.m_playerRank.toString() + ". You have won " + no_of_rewards.toString() + (no_of_rewards == 1 ? " Reward" : " Rewards");
         this.showNPCCallouts("Leaderboard Results",calloutText);
         if(Global.player.getSeenFlag(this.LAST_DAY_WEEK))
         {
            Global.player.resetSeenFlag(this.LAST_DAY_WEEK);
         }
         this.m_highlightbgMc.visible = false;
      }
      
      public function populateLeaderboard(result:Object, giftLeaderboardRank:Number, giftLeaderboardName:String) : void
      {
         var finished:Boolean = false;
         var winner:Boolean = false;
         var userData:Object = null;
         var leaderboardData:Object = null;
         var week:String = null;
         if(result)
         {
            if(this.m_showGift && Boolean(giftLeaderboardRank))
            {
               result = result.previousLeaderboardData;
               this.m_playerRank = giftLeaderboardRank;
            }
            if(!this.m_showGift && Boolean(result["userData"]))
            {
               userData = result["userData"];
               this.m_playerRank = userData.rank;
            }
            if(this.m_playerRank > 4)
            {
               this.m_highlightbgMc.visible = true;
            }
            finished = TimedSlotGiveawaysManager.isDisabled(this.m_featureName);
            winner = false;
            if(finished)
            {
               winner = this.conditionallyAwardLeaderboarGift(result);
            }
            if(this.m_leaderboards)
            {
               leaderboardData = null;
               if(this.m_showGift)
               {
                  leaderboardData = result;
               }
               else
               {
                  leaderboardData = result[VAL_GLOBAL_LEADERBOARD];
               }
               this.m_leaderboards[0].finishLoading(leaderboardData,false,winner);
            }
            if(Boolean(this.m_showGift) && Boolean(giftLeaderboardRank) && Boolean(giftLeaderboardName))
            {
               week = giftLeaderboardName.charAt(giftLeaderboardName.length - 1);
               this.m_weekCount = parseInt(week,10);
               this.showgift();
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
      
      private function conditionallyAwardLeaderboarGift(leaderboardData:Object) : Boolean
      {
         var globalLeaderboardData:Object = null;
         var globalLeadersSlotData:Array = null;
         var data:Object = null;
         var winner:Boolean = false;
         if(leaderboardData[VAL_GLOBAL_LEADERBOARD])
         {
            globalLeaderboardData = leaderboardData[VAL_GLOBAL_LEADERBOARD];
            if(globalLeaderboardData.slotData is Array)
            {
               globalLeadersSlotData = globalLeaderboardData.slotData as Array;
               if(globalLeadersSlotData)
               {
                  for each(data in globalLeadersSlotData)
                  {
                     if(Boolean(data.rank) && data.uid == String(Global.player.uid))
                     {
                        TimedSlotGiveawaysManager.awardLeaderboardGift(this.m_featureName,data.rank);
                        winner = true;
                        break;
                     }
                  }
               }
            }
         }
         return winner;
      }
      
      override public function close() : void
      {
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
         }
         this.hideNPCCallout();
         this.stopTimer();
         this.manager.leaderboardCallback();
         super.close();
      }
      
      private function get manager() : RussiaInnovationManager
      {
         return RussiaInnovationManager.getInstance(this.FEATURE_NAME);
      }
      
      private function hasSeenFeatureWelcome() : Boolean
      {
         return Global.player.getSeenFlag(this.LEADERBOARD_WELCOME_SEEN_FLAG);
      }
      
      private function showAutoHideNPCCallouts(title:String, text:String) : void
      {
         this.m_autoNpc2Tf.text = text;
         this.m_autoNpc1Tf.text = title;
         this.m_talkAutoMc.visible = true;
         this.m_talkAutoMc.gotoAndPlay(1);
      }
      
      public function showNPCCallouts(title:String, text:String) : void
      {
         this.m_npc1Tf.text = title;
         this.m_npc2Tf.text = text;
         this.m_talkMc.visible = true;
      }
      
      public function hideNPCCallout() : void
      {
         this.m_talkMc.visible = false;
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

