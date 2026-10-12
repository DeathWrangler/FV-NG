package Widgets.Windows
{
   import Classes.util.MovieClipUtils;
   import Display.HUD.HUD;
   import Managers.TimedSlotGiveawaysManager;
   import Managers.WreathFestivalInnovationManager;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.WreathFestivalInnovationLeaderboardSlotFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class WreathFestivalInnovationLeaderboardWindow extends FarmWindow
   {
      
      private static const SERVICE_NAME:String = "WreathFestivalInnovationService";
      
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
      
      private var m_loader_mc:MovieClip;
      
      private var timeleft_frame:ZwFrame;
      
      private var FEATURE_NAME:String = "WreathFestivalInnovation";
      
      private var m_playerRank:Number;
      
      private const PREFIX_LEAGUE_REWARD_ICONS:String = "assets/dialogs/FV_Innovation_Wreath_Festival/";
      
      private const SUFIX_LEAGUE_REWARD_ICONS:String = "_icon_400.png";
      
      private var m_leaderboards:Vector.<WreathFestivalInnovationLeaderboardSlotFrame> = new Vector.<WreathFestivalInnovationLeaderboardSlotFrame>();
      
      private const LEADERBOARD_WELCOME_SEEN_FLAG:String = "WreathFestival_LB_Reward_Welcome_flag";
      
      private const LAST_DAY_WEEK:String = "WreathFestival_last_Day_Of_Week";
      
      private const LeaguePointsArray:Array = ["100","250","350","300"];
      
      private var m_weekTf:ZwTextField;
      
      private var m_leaguereward_icon:FarmIcon;
      
      private var m_weekCount:int = 0;
      
      private var m_weekMc:MovieClip;
      
      private var m_showGift:Boolean;
      
      private var m_showCommunity:Boolean = false;
      
      private var m_messageTf:ZwTextField;
      
      private var m_rewardmoment_tf:ZwTextField;
      
      private var m_timer_tf:ZwTextField;
      
      private var m_norank_tf:ZwTextField;
      
      private const NO_OF_WEEKS:int = 5;
      
      public var m_leagueTf:ZwTextField;
      
      private var m_overlayMc:MovieClip;
      
      private var m_lbsubtitle_tf:ZwTextField;
      
      private var m_leaderboard_frame:WreathFestivalInnovationLeaderboardSlotFrame;
      
      private var m_rewardsmoment_mc:MovieClip;
      
      private var m_leagues_mc:MovieClip;
      
      public function WreathFestivalInnovationLeaderboardWindow(assetPath:String = "", featureName:String = null, subFeatureName:String = null, callBack:Function = null, showGift:Boolean = false)
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
         var frameNum:int = 0;
         super.postLoadComplete();
         MovieClipUtils.recursivePlay(m_window);
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"WREATH LEADERBOARD"));
         }
         if(!this.hasSeenFeatureWelcome())
         {
            Global.player.setSeenFlag(this.LEADERBOARD_WELCOME_SEEN_FLAG);
         }
         if(this.m_weekMc)
         {
            this.m_weekMc.visible = false;
         }
         if(this.m_weekCount == 0 && !this.manager.hasFeatureExpired())
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
         if(this.manager.hasFeatureExpired())
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
            addWidget(this.m_norank_tf = new ZwTextField(m_window["norank_tf"],"\n\nComplete tasks to appear on this week\'s leaderboard!"));
            this.m_norank_tf.visible = false;
         }
         if(m_window.hasOwnProperty("timeremains_tf"))
         {
            addWidget(this.m_timer_tf = new ZwTextField(m_window["timeremains_tf"]));
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
         if(m_window.hasOwnProperty("leaderboard_pane"))
         {
            this.m_leaderboard_mc = m_window["leaderboard_pane"] as MovieClip;
            this.m_leaderboard_mc.visible = true;
            this.m_leaderboard_frame = new WreathFestivalInnovationLeaderboardSlotFrame(this.m_leaderboard_mc,null,this.m_featureName,this);
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
            if(this.m_leaderboard_mc.hasOwnProperty("leaderboard_tf"))
            {
               addWidget(this.m_lbsubtitle_tf = new ZwTextField(this.m_leaderboard_mc["leaderboard_tf"],"Stay in top 15 to reach next league!"));
            }
         }
         if(m_window.hasOwnProperty("upcomingleagu_reward"))
         {
            addWidget(this.m_leaguereward_icon = new FarmIcon(m_window["upcomingleagu_reward"]));
            this.m_leaguereward_icon.visible = false;
         }
         if(m_window.hasOwnProperty("League_frames"))
         {
            this.m_leagues_mc = m_window["League_frames"] as MovieClip;
            if(this.m_leagues_mc.hasOwnProperty("bronze_tab"))
            {
               addWidget(new FarmButton(this.m_leagues_mc["bronze_tab"],this.onLeagueTabClick(0)));
            }
            if(this.m_leagues_mc.hasOwnProperty("silver_tab"))
            {
               addWidget(new FarmButton(this.m_leagues_mc["silver_tab"],this.onLeagueTabClick(1)));
            }
            if(this.m_leagues_mc.hasOwnProperty("gold_tab"))
            {
               addWidget(new FarmButton(this.m_leagues_mc["gold_tab"],this.onLeagueTabClick(2)));
            }
            if(this.m_leagues_mc.hasOwnProperty("diamond_tab"))
            {
               addWidget(new FarmButton(this.m_leagues_mc["diamond_tab"],this.onLeagueTabClick(3)));
            }
            this.m_leagues_mc.visible = true;
            frameNum = this.manager.getCurrentLeague() + 1;
            this.m_leagues_mc.gotoAndStop(frameNum);
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
      
      public function onLeagueTabClick(index:int) : Function
      {
         return function(e:Event):void
         {
            var league:* = undefined;
            if(Boolean(m_leagues_mc) && Boolean(m_leaderboard_mc) && Boolean(m_norank_tf))
            {
               m_leagues_mc.gotoAndStop(index + 1);
               m_leaderboard_mc.visible = false;
               league = manager.getCurrentLeague();
               if(league != index)
               {
                  m_leaderboard_mc.visible = false;
                  setLeagueRewardIcon(league + 1,index + 1);
                  if(m_lbsubtitle_tf)
                  {
                     m_lbsubtitle_tf.visible = false;
                  }
                  switch(index)
                  {
                     case 0:
                        if(index < league)
                        {
                           m_norank_tf.text = "You have already crossed this league. Keep your rank above 40 to avoid getting demoted\n";
                        }
                        else
                        {
                           m_norank_tf.text = "";
                        }
                        break;
                     case 1:
                        if(index < league)
                        {
                           m_norank_tf.text = "You have already crossed this league. Keep your rank above 40 to avoid getting demoted\n";
                        }
                        else
                        {
                           m_norank_tf.text = "Stay in top 15 in the current week leaderboard to reach Silver league!";
                        }
                        break;
                     case 2:
                        if(index < league)
                        {
                           m_norank_tf.text = "You have already crossed this league. Keep your rank above 40 to avoid getting demoted\n";
                        }
                        else if(index - league > 1)
                        {
                           m_norank_tf.text = "To unlock the Gold  League, reach the silver league first by staying in top 15 by the end of this week";
                        }
                        else
                        {
                           m_norank_tf.text = "Stay in top 15 in the current week leaderboard to reach Gold league!";
                        }
                        break;
                     case 3:
                        if(index < league)
                        {
                           m_norank_tf.text = "You have already crossed this league. Keep your rank above 40 to avoid getting demoted\n";
                        }
                        else if(index - league > 1)
                        {
                           m_norank_tf.text = "To unlock the Diamond  League, reach the gold league first by staying in top 15 by the end of this week";
                        }
                        else
                        {
                           m_norank_tf.text = "Stay in top 15 in the current week leaderboard to reach Diamond league!";
                        }
                  }
                  m_norank_tf.visible = true;
               }
               else
               {
                  if(manager.getWeeklyLeaderboardPoints() == 0)
                  {
                     m_norank_tf.text = "\n\nComplete tasks to appear on this week\'s leaderboard!";
                  }
                  else
                  {
                     m_norank_tf.visible = false;
                  }
                  if(m_lbsubtitle_tf)
                  {
                     m_lbsubtitle_tf.visible = true;
                  }
                  m_leaderboard_mc.visible = true;
                  if(m_leaguereward_icon)
                  {
                     m_leaguereward_icon.visible = false;
                  }
               }
            }
         };
      }
      
      private function setLeagueRewardIcon(league:int = 0, tabIndex:int = 0) : void
      {
         var weekNo:int = 0;
         var iconPath:String = null;
         if(this.m_leaguereward_icon)
         {
            if(tabIndex - league == 1)
            {
               weekNo = this.manager.currentWeekIndex + 1;
               iconPath = this.PREFIX_LEAGUE_REWARD_ICONS + "Week" + weekNo.toString() + "_" + league.toString() + "_" + tabIndex.toString() + this.SUFIX_LEAGUE_REWARD_ICONS;
               this.m_leaguereward_icon.loadIcon(iconPath);
               this.m_leaguereward_icon.setIconSize(250,250);
               this.m_leaguereward_icon.visible = true;
            }
            else
            {
               this.m_leaguereward_icon.visible = false;
            }
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
            this.manager.showMainUI();
         }
         this.stopTimer();
         super.close();
      }
      
      private function get manager() : WreathFestivalInnovationManager
      {
         return WreathFestivalInnovationManager.getInstance(this.FEATURE_NAME);
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
         else if(this.m_timer_tf)
         {
            this.m_timer_tf.text = "Week Ends in: " + HUD.getformattedTimeLeft(timeLeftInWeek);
         }
         m_closeButton.visible = true;
      }
   }
}

