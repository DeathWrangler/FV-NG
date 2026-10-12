package Widgets.Windows
{
   import Classes.util.MovieClipUtils;
   import Display.HUD.HUD;
   import Managers.OrderBoard.FarmersMarketInnovationManager;
   import Managers.TimedSlotGiveawaysManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmersMarketInnovationLeaderboardSlotFrame;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class FarmersMarketInnovationLeaderboardWindow extends FarmWindow
   {
      
      private static const SERVICE_NAME:String = "FarmersMarketInnovationService";
      
      private static const VAL_GLOBAL_LEADERBOARD:String = "globalLeaderboardData";
      
      private static const VAL_PREVIOUS_LEADERBOARD:String = "previousLeaderboardData";
      
      private var m_featureName:String = null;
      
      private var m_timer:Timer;
      
      private var m_subFeatureName:String = null;
      
      private var m_callback:Function = null;
      
      private const TITLE_TF:String = "title_tf";
      
      private var m_timer_mc:MovieClip;
      
      private var m_rewards_mc:MovieClip;
      
      private var m_result:Object;
      
      private var m_rewardspane_mc:MovieClip;
      
      private var m_leaderboard_mc:MovieClip;
      
      protected var m_highlightbgMc:MovieClip;
      
      private var m_loader_mc:MovieClip;
      
      private var timeleft_frame:ZwFrame;
      
      private var FEATURE_NAME:String = "FarmersMarket2020Innovation";
      
      private var m_playerRank:Number;
      
      private var m_leaderboards:Vector.<FarmersMarketInnovationLeaderboardSlotFrame> = new Vector.<FarmersMarketInnovationLeaderboardSlotFrame>();
      
      private const LEADERBOARD_WELCOME_SEEN_FLAG:String = "FarmersMarket_Leaderboard_Reward_Welcome_flag";
      
      private const LAST_DAY_WEEK:String = "FarmersMarket_last_Day_Of_Week";
      
      private const LeaguePointsArray:Array = ["100","250","350","300"];
      
      private var m_weekTf:ZwTextField;
      
      private var m_weekRewardTf:ZwTextField;
      
      private var m_weekCount:int = 0;
      
      private var m_weekMc:MovieClip;
      
      private var m_showGift:Boolean;
      
      private var m_showCommunity:Boolean = false;
      
      private var m_messageTf:ZwTextField;
      
      private var m_rewardmoment_tf:ZwTextField;
      
      private var m_timer_tf:ZwTextField;
      
      private var m_norank_tf:ZwTextField;
      
      private const MAX_NO_OF_REWARDS:Number = 5;
      
      private const NO_OF_WEEKS:int = 5;
      
      public const IRELAND_INNOVATION_FIRST_LB_UI:String = "xid_innovation_lb";
      
      public var m_leagueTf:ZwTextField;
      
      private var m_overlayMc:MovieClip;
      
      private var m_league_bg_mc:MovieClip;
      
      private var m_leaderboard_frame:FarmersMarketInnovationLeaderboardSlotFrame;
      
      private var m_rewardsmoment_mc:MovieClip;
      
      public function FarmersMarketInnovationLeaderboardWindow(assetPath:String = "", featureName:String = null, subFeatureName:String = null, callBack:Function = null, showGift:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_callback = callBack;
         this.m_subFeatureName = subFeatureName;
         this.m_showGift = showGift;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var leaderBoardData:Object = null;
         var weekCount:int = 0;
         var timeLeftInWeek:Number = NaN;
         super.postLoadComplete();
         MovieClipUtils.recursivePlay(m_window);
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"MARKET LEADERBOARD"));
         }
         if(!this.hasSeenFeatureWelcome())
         {
            Global.player.setSeenFlag(this.LEADERBOARD_WELCOME_SEEN_FLAG);
         }
         if(this.m_weekMc)
         {
            this.m_weekMc.visible = false;
         }
         if(this.m_weekCount == 0 && !this.manager.hasExpiryDatePassedForFeature())
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
         if(this.manager.hasExpiryDatePassedForFeature())
         {
            this.m_weekCount = this.NO_OF_WEEKS;
         }
         if(m_window.hasOwnProperty("lbrewards_pane"))
         {
            this.m_rewardspane_mc = m_window["lbrewards_pane"] as MovieClip;
            this.m_rewardspane_mc.visible = this.m_showGift == true ? false : true;
            this.m_rewardspane_mc.gotoAndStop(this.manager.currentWeekIndex + 1);
         }
         if(m_window.hasOwnProperty("rewardmoment_pane"))
         {
            this.m_rewardsmoment_mc = m_window["rewardmoment_pane"] as MovieClip;
            this.m_rewardsmoment_mc.visible = this.m_showGift == true ? true : false;
            if(this.m_rewardsmoment_mc.hasOwnProperty("rewardmoment_tf"))
            {
               addWidget(this.m_rewardmoment_tf = new ZwTextField(this.m_rewardsmoment_mc["rewardmoment_tf"]));
               this.m_rewardmoment_tf.visible = false;
            }
         }
         if(m_window.hasOwnProperty("norank_tf"))
         {
            addWidget(this.m_norank_tf = new ZwTextField(m_window["norank_tf"],"You need to earn Market Coins to appear on this week\'s leaderboard!"));
            this.m_norank_tf.visible = false;
         }
         if(!Global.player.getSeenFlag(this.IRELAND_INNOVATION_FIRST_LB_UI))
         {
            Global.player.setSeenFlag(this.IRELAND_INNOVATION_FIRST_LB_UI);
         }
         if(m_window.hasOwnProperty("leaderboard_pane"))
         {
            this.m_leaderboard_mc = m_window["leaderboard_pane"] as MovieClip;
            this.m_leaderboard_mc.visible = true;
            this.m_leaderboard_frame = new FarmersMarketInnovationLeaderboardSlotFrame(this.m_leaderboard_mc,null,this.m_featureName,this);
            addWidget(this.m_leaderboard_frame,true);
            if(this.m_leaderboard_mc.hasOwnProperty("message_tf"))
            {
               addWidget(this.m_messageTf = new ZwTextField(this.m_leaderboard_mc["message_tf"]));
               this.m_messageTf.visible = false;
            }
            if(this.m_leaderboard_mc.hasOwnProperty("loader_mc"))
            {
               this.m_loader_mc = this.m_leaderboard_mc["loader_mc"] as MovieClip;
               this.m_loader_mc.visible = true;
            }
            if(this.m_leaderboard_mc.hasOwnProperty("timeremains_tf"))
            {
               addWidget(this.m_timer_tf = new ZwTextField(this.m_leaderboard_mc["timeremains_tf"]));
               timeLeftInWeek = this.manager.getTimeLeftInWeek();
               if(timeLeftInWeek == -1)
               {
                  this.m_timer_mc.visible = false;
               }
               else
               {
                  this.m_timer_tf.text = "Week Ends in: " + HUD.getformattedTimeLeft(timeLeftInWeek);
               }
            }
         }
         if(this.manager.getWeeklyLeaderboardPoints() > 0)
         {
            this.manager.initializeLeaderBoardProgress();
         }
         else
         {
            this.m_loader_mc.visible = false;
            if(this.m_norank_tf)
            {
               this.m_norank_tf.visible = true;
            }
         }
         if(this.manager.checkLastDayInWeek() <= 1 && Global.player.getSeenFlag(this.LAST_DAY_WEEK) == false && this.manager.getTimeLeftInWeek() != -1 && this.manager.hasFeatureExpired() == false)
         {
            Global.player.setSeenFlag(this.LAST_DAY_WEEK);
         }
         if(this.m_showGift)
         {
            if(this.m_timer_mc)
            {
               this.m_timer_mc.visible = false;
            }
         }
         this.startTimer();
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(Boolean(this.m_messageTf) && this.m_messageTf.visible == false)
         {
            m_closeButton.visible = false;
         }
      }
      
      private function isLastDayOfFeature() : Boolean
      {
         var dayIndex:int = this.manager.currentDayIndex;
         var totalDays:int = this.NO_OF_WEEKS * 7;
         return dayIndex == totalDays - 1;
      }
      
      private function getRewardCountForPlayer(playerRank:Number) : Number
      {
         var result:Number = 1;
         if(playerRank == 1)
         {
            result = 5;
         }
         else if(playerRank == 2)
         {
            result = 4;
         }
         else if(playerRank == 3)
         {
            result = 3;
         }
         else if(playerRank < 11)
         {
            result = 2;
         }
         else if(playerRank < 21)
         {
            result = 2;
         }
         else
         {
            result = 1;
         }
         return result;
      }
      
      public function populateLeaderboard(result:Object) : void
      {
         var userData:Object = null;
         var leaderboardData:Object = null;
         if(result)
         {
            this.m_result = result;
            if(this.m_showGift && Boolean(result["giftLeaderboardRank"]))
            {
               result = result.previousLeaderboardData;
            }
            if(!this.m_showGift && Boolean(result["userData"]))
            {
               userData = result["userData"];
            }
            if(this.m_leaderboard_frame)
            {
               leaderboardData = null;
               if(this.m_showGift)
               {
                  leaderboardData = this.m_result[VAL_GLOBAL_LEADERBOARD];
               }
               else
               {
                  leaderboardData = result[VAL_GLOBAL_LEADERBOARD];
               }
               this.m_leaderboard_frame.finishLoading(leaderboardData);
            }
            if(this.m_showGift)
            {
               this.showgift(this.m_result["giftLeaderboardRank"]);
            }
            if(this.m_messageTf != null)
            {
               this.m_messageTf.visible = false;
            }
         }
         if(m_closeButton)
         {
            m_closeButton.visible = true;
         }
         if(this.m_loader_mc)
         {
            this.m_loader_mc.visible = false;
         }
      }
      
      private function showgift(rank:int) : void
      {
         var rank_no:int = 0;
         if(this.m_rewardspane_mc)
         {
            this.m_rewardspane_mc.visible = false;
         }
         if(rank >= 1 && rank <= 3)
         {
            rank_no = rank;
         }
         else if(rank >= 4 && rank <= 10)
         {
            rank_no = 4;
         }
         else if(rank >= 11 && rank <= 20)
         {
            rank_no = 11;
         }
         else
         {
            rank_no = 21;
         }
         var rank_name:String = "rank" + rank_no.toString();
         if(this.m_rewardsmoment_mc)
         {
            this.m_rewardsmoment_mc.visible = true;
            if(this.m_rewardsmoment_mc.hasOwnProperty(rank_name))
            {
               this.m_rewardsmoment_mc[rank_name].visible = true;
               this.m_rewardsmoment_mc[rank_name].gotoAndStop(this.m_weekCount);
            }
            if(this.m_rewardmoment_tf)
            {
               this.m_rewardmoment_tf.text = "Your rank in previous week was " + rank.toString() + "! You have won these rewards";
               this.m_rewardmoment_tf.visible = true;
            }
         }
         if(Global.player.getSeenFlag(this.LAST_DAY_WEEK))
         {
            Global.player.resetSeenFlag(this.LAST_DAY_WEEK);
         }
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
      
      public function updateLeaderboardFrame(success:Boolean) : void
      {
         var leaderboardSlotIndex:int = 0;
         var propertyName:* = undefined;
         var leaderboardSlot:* = undefined;
         if(this.m_loader_mc != null)
         {
            this.m_loader_mc.visible = false;
         }
         if(this.m_leaderboard_mc != null)
         {
            for(leaderboardSlotIndex = 0; leaderboardSlotIndex < 6; leaderboardSlotIndex++)
            {
               propertyName = "leaderboardSlot_" + leaderboardSlotIndex + "_mc";
               if(this.m_leaderboard_mc.hasOwnProperty(propertyName))
               {
                  leaderboardSlot = this.m_leaderboard_mc[propertyName] as MovieClip;
                  leaderboardSlot.visible = true;
               }
            }
         }
      }
      
      override public function close() : void
      {
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
         }
         else if(this.m_showGift)
         {
            this.manager.showMainWindow();
         }
         this.stopTimer();
         super.close();
      }
      
      private function get manager() : FarmersMarketInnovationManager
      {
         return FarmersMarketInnovationManager.getInstance(this.FEATURE_NAME);
      }
      
      private function hasSeenFeatureWelcome() : Boolean
      {
         return Global.player.getSeenFlag(this.LEADERBOARD_WELCOME_SEEN_FLAG);
      }
      
      public function updateOverlay() : void
      {
         if(this.m_overlayMc)
         {
            this.m_overlayMc.visible = false;
         }
      }
      
      private function startTimer() : void
      {
         this.m_timer = new Timer(1000);
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
      
      public function refreshLBName() : *
      {
         var lbText:String = null;
         var weekText:String = null;
         var curWeek:Object = this.manager.getCurrentWeek();
         var count:* = curWeek.count;
         if(this.m_leagueTf)
         {
            lbText = "Week  " + count + "  Leaderboard!";
            this.m_leagueTf.text = lbText;
         }
         if(this.m_weekTf)
         {
            weekText = "Week  " + (count - 1) + "  Rewards!";
            this.m_weekTf.text = weekText;
         }
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         var timeLeftInWeek:Number = this.manager.getTimeLeftInWeek();
         if(timeLeftInWeek == -1)
         {
            this.m_timer_mc.visible = false;
         }
         else
         {
            this.m_timer_tf.text = "Week Ends in: " + HUD.getformattedTimeLeft(timeLeftInWeek);
         }
         m_closeButton.visible = true;
      }
   }
}

