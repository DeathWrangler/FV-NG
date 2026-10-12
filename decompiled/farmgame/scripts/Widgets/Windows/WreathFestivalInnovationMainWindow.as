package Widgets.Windows
{
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.WorldSeasonsManager;
   import Managers.WreathFestivalInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.WreathFestivalInnovationTaskFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   
   public class WreathFestivalInnovationMainWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 9;
      
      private static const FEATURE_NAME:String = "WreathFestivalInnovation";
      
      private var m_featureName:String = null;
      
      private const LEADERBOARD_PLAYING_FLAG:String = "WreathFestival_Leaderboard_Playing_flag";
      
      private const INNOVATION_WELCOME_SEEN_FLAG:String = "WreathFestivalInnovation_Welcome_flag";
      
      private const NORMAL_FEATURE_END:String = "WreathFestival_Normal_Feature_End";
      
      private const LAST_DAY_ENTERED:String = "WreathFestival_Last_Day_entered";
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private const MAX_POINT:Number = 350;
      
      private const PROGRESS_BAR_FULL_WIDTH:int = 285;
      
      private const TILE_UNLOCK_CONSUMABLE_COUNT:int = 50;
      
      private const PREFIX_LEAGUE_REWARD_ICONS:String = "assets/dialogs/FV_Innovation_Wreath_Festival/";
      
      private const SUFIX_LEAGUE_REWARD_ICONS:String = "_icon_200.png";
      
      private var m_taskFrame:WreathFestivalInnovationTaskFrame;
      
      private var m_showTutorialWithEAPage:Boolean = false;
      
      private var m_players_mc:Object = new Array(3);
      
      private var m_timer:Timer;
      
      private var m_subtitle_tf:TextField;
      
      private var m_barMc:MovieClip;
      
      private var m_consumable_pane:MovieClip;
      
      private var m_consumecount_tf:ZwTextField;
      
      private var m_progress_panel:MovieClip;
      
      private var m_dailycount_tf:ZwTextField;
      
      private var m_dayinfo_mc:MovieClip;
      
      private var m_dailyinfo_icon:FarmIcon;
      
      private var m_dailyinfo1_tf:ZwTextField;
      
      private var m_dailyinfo2_tf:ZwTextField;
      
      private var m_dailyinfo_bt:FarmAnimatedTextButton;
      
      private var m_dailyreward_icon:FarmIcon;
      
      private var m_totalavg_tf:ZwTextField;
      
      private var m_milestone1_mc:MovieClip;
      
      private var m_milestone2_mc:MovieClip;
      
      private var m_lock1_mc:MovieClip;
      
      private var m_lock2_mc:MovieClip;
      
      private var m_lockHover1_mc:MovieClip;
      
      private var m_lockHover2_mc:MovieClip;
      
      private var m_unlockanim1_mc:MovieClip;
      
      private var m_unlockanim2_mc:MovieClip;
      
      private var m_average_panel:MovieClip;
      
      private var m_leaderboard_pane:MovieClip;
      
      private var m_viewlb_bt:FarmAnimatedTextButton;
      
      private var m_leaguerewards_bt:FarmAnimatedTextButton;
      
      private var m_lbsubtitle_tf:ZwTextField;
      
      private var m_norank_tf:ZwTextField;
      
      private var m_leagues_mc:MovieClip;
      
      private var m_players_frame:MovieClip;
      
      private var m_leaguereward_icon:FarmIcon;
      
      private var m_oblock_mc:MovieClip;
      
      private var m_redeemlock_mc:MovieClip;
      
      private var m_oblock_tf:ZwTextField;
      
      private var m_leaguechange_mc:MovieClip;
      
      private var m_promotion1_tf:ZwTextField;
      
      private var m_promotion2_tf:ZwTextField;
      
      private var m_leaguechange_bt:FarmAnimatedTextButton;
      
      private var m_leaguechange_icon:FarmIcon;
      
      private var m_featuretime_tf:ZwTextField;
      
      private var m_ob_doober:MovieClip;
      
      private var m_lb_doober:MovieClip;
      
      private var m_transparent_mc:MovieClip;
      
      private var m_tutorial_mc:MovieClip;
      
      private var m_welcomeEA_mc:MovieClip;
      
      private var m_welcomeGA_mc:MovieClip;
      
      private var m_title_tf:ZwTextField;
      
      public function WreathFestivalInnovationMainWindow(featureName:String = "WreathFestivalInnovation", assetUrl:String = null, showEAPageTutorial:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_showTutorialWithEAPage = showEAPageTutorial;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(FEATURE_NAME,assetUrl,numOfTutorialPages);
      }
      
      override protected function postLoadComplete() : void
      {
         var player_mc_key:String = null;
         var index:int = 0;
         var frameNum:int = 0;
         var dailyPoints:int = 0;
         var dailyItem:FarmItem = null;
         super.postLoadComplete();
         if(this.manager.hasActiveDayExpired())
         {
            if(Global.player.getSeenFlag(this.LEADERBOARD_PLAYING_FLAG))
            {
               Global.player.resetSeenFlag(this.LEADERBOARD_PLAYING_FLAG);
            }
         }
         if(m_window.hasOwnProperty("transperantMask_MC"))
         {
            this.m_transparent_mc = m_window["transperantMask_MC"] as MovieClip;
            this.m_transparent_mc.visible = false;
         }
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(this.m_title_tf = new ZwTextField(m_window["title_tf"],"Wreath Festival"));
         }
         if(m_window.hasOwnProperty("howtoplay_mc"))
         {
            this.m_tutorial_mc = m_window["howtoplay_mc"] as MovieClip;
            if(this.m_tutorial_mc.hasOwnProperty("ok_bt"))
            {
               new FarmAnimatedTextButton(this.m_tutorial_mc["ok_bt"],"Alright!",this.onTutorialClick);
            }
            this.m_tutorial_mc.visible = false;
         }
         if(m_window.hasOwnProperty("howDoesThisWork_mc"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["howDoesThisWork_mc"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_WHATISTHIS),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty("subheader_tf"))
         {
            this.m_subtitle_tf = TextField(m_window["subheader_tf"]);
            if(!Global.player.getSeenFlag(this.LEADERBOARD_PLAYING_FLAG))
            {
               this.m_subtitle_tf.text = "Finish the tasks to fill the daily meter and win awesome rewards!";
            }
            else
            {
               this.m_subtitle_tf.text = this.getLeaderboardPlaySubtitle();
            }
            this.m_subtitle_tf.visible = true;
         }
         if(m_window.hasOwnProperty("tasks_mc"))
         {
            this.m_taskFrame = new WreathFestivalInnovationTaskFrame(m_window["tasks_mc"],this,this.m_featureName);
            this.m_taskFrame.visible = true;
         }
         if(m_window.hasOwnProperty("consumablepane_mc"))
         {
            this.m_consumable_pane = m_window["consumablepane_mc"] as MovieClip;
            if(this.m_consumable_pane.hasOwnProperty("consumable_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_consumable_pane["consumable_bt"],"Get More",this.onGetConsumableCLick));
            }
            if(this.m_consumable_pane.hasOwnProperty("count_tf"))
            {
               addWidget(this.m_consumecount_tf = new ZwTextField(this.m_consumable_pane["count_tf"]," x" + this.manager.consumableCount.toString()));
            }
            this.m_consumable_pane.visible = true;
         }
         if(Global.player.getSeenFlag(this.manager.TILE_UNLOCK))
         {
            this.showtileUnlockOverlay();
         }
         if(m_window.hasOwnProperty("league_slot"))
         {
            this.m_leaderboard_pane = m_window["league_slot"] as MovieClip;
            this.m_leaderboard_pane.visible = true;
            if(this.m_leaderboard_pane.hasOwnProperty("view_bt"))
            {
               addWidget(this.m_viewlb_bt = new FarmAnimatedTextButton(this.m_leaderboard_pane["view_bt"],"View",this.onViewLeaderboardClick));
            }
            if(this.m_leaderboard_pane.hasOwnProperty("Leaguereward_tf"))
            {
               addWidget(this.m_norank_tf = new ZwTextField(this.m_leaderboard_pane["Leaguereward_tf"]));
            }
            if(this.m_leaderboard_pane.hasOwnProperty("lbsubtittle_tf"))
            {
               addWidget(this.m_lbsubtitle_tf = new ZwTextField(this.m_leaderboard_pane["lbsubtittle_tf"],"Stay in top 15 to reach next league!"));
            }
            if(this.m_leaderboard_pane.hasOwnProperty("leaguereward_bt"))
            {
               addWidget(this.m_leaguerewards_bt = new FarmAnimatedTextButton(this.m_leaderboard_pane["leaguereward_bt"],"League Rewards",this.manager.showLeaderboardRewardUI));
            }
            if(this.m_leaderboard_pane.hasOwnProperty("leaderboard_slot"))
            {
               this.m_players_frame = this.m_leaderboard_pane["leaderboard_slot"] as MovieClip;
               for(index = 0; index < 3; index++)
               {
                  player_mc_key = "player" + index.toString() + "_mc";
                  if(this.m_players_frame.hasOwnProperty(player_mc_key))
                  {
                     this.m_players_mc[index] = this.m_players_frame[player_mc_key] as MovieClip;
                     this.m_players_mc[index].visible = false;
                  }
               }
               if(this.manager.m_leaderboardpane_data)
               {
                  this.showLeaderboardPaneData();
               }
            }
            if(this.m_leaderboard_pane.hasOwnProperty("League_frames"))
            {
               this.m_leagues_mc = this.m_leaderboard_pane["League_frames"] as MovieClip;
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
               if(Boolean(this.m_norank_tf) && Boolean(this.m_lbsubtitle_tf))
               {
                  if(this.manager.getWeeklyLeaderboardPoints() == 0)
                  {
                     this.m_norank_tf.text = "\nComplete tasks to appear on this week\'s leaderboard!";
                     this.m_norank_tf.visible = true;
                     this.m_lbsubtitle_tf.visible = false;
                  }
                  else
                  {
                     this.m_norank_tf.visible = false;
                     this.m_lbsubtitle_tf.visible = true;
                  }
               }
            }
            if(this.m_leaderboard_pane.hasOwnProperty("leaguerewardicon_mc"))
            {
               addWidget(this.m_leaguereward_icon = new FarmIcon(this.m_leaderboard_pane["leaguerewardicon_mc"]));
               this.m_leaguereward_icon.visible = false;
            }
         }
         if(m_window.hasOwnProperty("progress_panel"))
         {
            m_window["progress_panel"].visible = true;
            if(m_window["progress_panel"].hasOwnProperty("daily_progressbar"))
            {
               this.m_progress_panel = m_window["progress_panel"]["daily_progressbar"] as MovieClip;
               this.m_progress_panel.visible = true;
               if(this.m_progress_panel.hasOwnProperty("progressbarfill"))
               {
                  this.m_progress_panel["progressbarfill"].visible = true;
                  if(this.m_progress_panel["progressbarfill"].hasOwnProperty("bar_fill_mc"))
                  {
                     this.m_barMc = this.m_progress_panel["progressbarfill"]["bar_fill_mc"] as MovieClip;
                     this.m_barMc.visible = true;
                  }
               }
               if(this.m_progress_panel.hasOwnProperty("dailycount_tf"))
               {
                  dailyPoints = this.manager.getDayPoints();
                  addWidget(this.m_dailycount_tf = new ZwTextField(this.m_progress_panel["dailycount_tf"]));
                  if(dailyPoints > this.manager.VAL_THIRD_MILESTONE)
                  {
                     this.m_dailycount_tf.text = this.manager.VAL_THIRD_MILESTONE.toString();
                  }
                  else
                  {
                     this.m_dailycount_tf.text = this.manager.getDayPoints().toString();
                  }
               }
               if(this.m_progress_panel.hasOwnProperty("milestonereward0_mc"))
               {
                  this.m_milestone1_mc = this.m_progress_panel["milestonereward0_mc"] as MovieClip;
               }
               if(this.m_progress_panel.hasOwnProperty("milestonereward1_mc"))
               {
                  this.m_milestone2_mc = this.m_progress_panel["milestonereward1_mc"] as MovieClip;
               }
               if(this.m_progress_panel.hasOwnProperty("progressbarlock_popup1_mc"))
               {
                  this.m_lockHover1_mc = this.m_progress_panel["progressbarlock_popup1_mc"] as MovieClip;
                  this.m_lockHover1_mc.visible = false;
               }
               if(this.m_progress_panel.hasOwnProperty("progressbarlock_popup2_mc"))
               {
                  this.m_lockHover2_mc = this.m_progress_panel["progressbarlock_popup2_mc"] as MovieClip;
                  this.m_lockHover2_mc.visible = false;
               }
               if(this.m_progress_panel.hasOwnProperty("progressbarlock0_mc"))
               {
                  this.m_lock1_mc = this.m_progress_panel["progressbarlock0_mc"] as MovieClip;
                  this.m_lock1_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onLockOver(0));
                  this.m_lock1_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onLockOut());
               }
               if(this.m_progress_panel.hasOwnProperty("progressbarlock1_mc"))
               {
                  this.m_lock2_mc = this.m_progress_panel["progressbarlock1_mc"] as MovieClip;
                  this.m_lock2_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onLockOver(1));
                  this.m_lock2_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onLockOut());
               }
               if(this.m_progress_panel.hasOwnProperty("progressbarlock0a_mc"))
               {
                  this.m_unlockanim1_mc = this.m_progress_panel["progressbarlock0a_mc"] as MovieClip;
                  this.m_unlockanim1_mc.visible = false;
               }
               if(this.m_progress_panel.hasOwnProperty("progressbarlock1a_mc"))
               {
                  this.m_unlockanim2_mc = this.m_progress_panel["progressbarlock1a_mc"] as MovieClip;
                  this.m_unlockanim2_mc.visible = false;
               }
               if(this.m_progress_panel.hasOwnProperty("dailyreward_icon"))
               {
                  this.m_dailyreward_icon = new FarmIcon(this.m_progress_panel["dailyreward_icon"]);
                  dailyItem = this.manager.getActiveDayReward(2);
                  if(dailyItem)
                  {
                     this.m_dailyreward_icon.loadIcon(dailyItem.iconUrl);
                     this.m_dailyreward_icon.setIconSize(60,60);
                     this.m_dailyreward_icon.attachTooltip(new FarmTextTooltip(dailyItem.friendlyTitle));
                  }
               }
            }
            if(m_window["progress_panel"].hasOwnProperty("avaragepanel"))
            {
               this.m_average_panel = m_window["progress_panel"]["avaragepanel"];
               this.m_average_panel.visible = true;
               if(this.m_average_panel.hasOwnProperty("average_bt"))
               {
                  addWidget(new FarmAnimatedTextButton(this.m_average_panel["average_bt"],"View",this.onOpenAverageWindow));
               }
            }
            if(m_window["progress_panel"].hasOwnProperty("averagecount_tf"))
            {
               addWidget(this.m_totalavg_tf = new ZwTextField(m_window["progress_panel"]["averagecount_tf"]));
               this.m_totalavg_tf.visible = true;
            }
            this.m_progress_panel.visible = true;
         }
         if(m_window.hasOwnProperty("newdailyreward_mc"))
         {
            this.m_dayinfo_mc = m_window["newdailyreward_mc"] as MovieClip;
            this.m_dayinfo_mc.visible = false;
            if(this.m_dayinfo_mc.hasOwnProperty("newrewardtitle_tf"))
            {
               addWidget(this.m_dailyinfo1_tf = new ZwTextField(this.m_dayinfo_mc["newrewardtitle_tf"]));
            }
            if(this.m_dayinfo_mc.hasOwnProperty("newrewardbrief_tf"))
            {
               addWidget(this.m_dailyinfo2_tf = new ZwTextField(this.m_dayinfo_mc["newrewardbrief_tf"]));
            }
            if(this.m_dayinfo_mc.hasOwnProperty("nextreward_icon"))
            {
               this.m_dailyinfo_icon = new FarmIcon(this.m_dayinfo_mc["nextreward_icon"]);
            }
            if(this.m_dayinfo_mc.hasOwnProperty("ok_bt"))
            {
               addWidget(this.m_dailyinfo_bt = new FarmAnimatedTextButton(this.m_dayinfo_mc["ok_bt"]));
            }
         }
         if(m_window.hasOwnProperty("orderboardlocked_mc"))
         {
            this.m_oblock_mc = m_window["orderboardlocked_mc"] as MovieClip;
            if(this.m_oblock_mc.hasOwnProperty("orderboardlocked_tf"))
            {
               addWidget(this.m_oblock_tf = new ZwTextField(this.m_oblock_mc["orderboardlocked_tf"]));
            }
         }
         if(m_window.hasOwnProperty("task_redeam"))
         {
            this.m_redeemlock_mc = m_window["task_redeam"] as MovieClip;
            if(this.m_redeemlock_mc.hasOwnProperty("taskredeam_tf"))
            {
               addWidget(new ZwTextField(this.m_redeemlock_mc["taskredeam_tf"],"You have some tasks to redeem. Please redeem to move forward!"));
            }
            if(this.m_redeemlock_mc.hasOwnProperty("accept_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_redeemlock_mc["accept_bt"],"Let\'s Go!",this.onOldTasksRedeemClick));
            }
            this.m_redeemlock_mc.visible = false;
         }
         if(m_window.hasOwnProperty("leaguepramotion_mc"))
         {
            this.m_leaguechange_mc = m_window["leaguepramotion_mc"] as MovieClip;
            if(this.m_leaguechange_mc.hasOwnProperty("leaguepramotionheader_tf"))
            {
               addWidget(this.m_promotion1_tf = new ZwTextField(this.m_leaguechange_mc["leaguepramotionheader_tf"]));
            }
            if(this.m_leaguechange_mc.hasOwnProperty("leaguepramotionbrief_tf"))
            {
               addWidget(this.m_promotion2_tf = new ZwTextField(this.m_leaguechange_mc["leaguepramotionbrief_tf"]));
            }
            if(this.m_leaguechange_mc.hasOwnProperty("league_bt"))
            {
               addWidget(this.m_leaguechange_bt = new FarmAnimatedTextButton(this.m_leaguechange_mc["league_bt"]));
            }
            if(this.m_leaguechange_mc.hasOwnProperty("leagueicon_mc"))
            {
               addWidget(this.m_leaguechange_icon = new FarmIcon(this.m_leaguechange_mc["leagueicon_mc"]));
            }
            this.m_leaguechange_mc.visible = false;
         }
         if(m_window.hasOwnProperty("timeremains_tf"))
         {
            addWidget(this.m_featuretime_tf = new ZwTextField(m_window["timeremains_tf"],""));
            this.m_featuretime_tf.visible = true;
         }
         if(m_window.hasOwnProperty("obdooberanimation_mc"))
         {
            this.m_ob_doober = m_window["obdooberanimation_mc"] as MovieClip;
            this.m_ob_doober.visible = false;
         }
         if(m_window.hasOwnProperty("lbdooberanimation_mc"))
         {
            this.m_lb_doober = m_window["lbdooberanimation_mc"] as MovieClip;
            this.m_lb_doober.visible = false;
         }
         if(m_window.hasOwnProperty("eacallout_mc"))
         {
            this.m_welcomeEA_mc = m_window["eacallout_mc"] as MovieClip;
            if(this.m_welcomeEA_mc.hasOwnProperty("ok_bt"))
            {
               new FarmAnimatedTextButton(this.m_welcomeEA_mc["ok_bt"],"Awesome!",this.onWelcomeClick);
            }
            if(this.m_welcomeEA_mc.hasOwnProperty("newrewardtitle_tf"))
            {
               new ZwTextField(this.m_welcomeEA_mc["newrewardtitle_tf"],"Wreath Festival");
            }
            this.m_welcomeEA_mc.visible = false;
         }
         if(m_window.hasOwnProperty("gacallout_mc"))
         {
            this.m_welcomeGA_mc = m_window["gacallout_mc"] as MovieClip;
            if(this.m_welcomeGA_mc.hasOwnProperty("ok_bt"))
            {
               new FarmAnimatedTextButton(this.m_welcomeGA_mc["ok_bt"],"Let\'s Go!",this.onWelcomeClick);
            }
            if(this.m_welcomeGA_mc.hasOwnProperty("newrewardtitle_tf"))
            {
               new ZwTextField(this.m_welcomeGA_mc["newrewardtitle_tf"],"Wreath Festival");
            }
            this.m_welcomeGA_mc.visible = false;
         }
         if(!Global.player.getSeenFlag(this.INNOVATION_WELCOME_SEEN_FLAG))
         {
            this.showTutorialWindow();
         }
         this.refreshWindow();
         this.updateProgressBar(true);
         this.startTimer();
         this.manager.initializeLeaderBoardProgress(true);
         if(this.manager.shouldUpdateLeague() && this.manager.isLeaderboardExpired(this.manager.getCurrentLeaderboardName()))
         {
            this.manager.updateCurrentLeague(true);
         }
         if(this.manager.hasFeatureExpired())
         {
            this.manager.showFeatureEndMessages(0);
         }
      }
      
      private function onGetConsumableCLick(e:Event = null) : void
      {
         tintWindow();
         enableInput = false;
         this.manager.openBuyWindow(this);
      }
      
      private function onOpenAverageWindow(e:Event = null) : void
      {
         tintWindow();
         enableInput = false;
         this.manager.openAverageWindow();
      }
      
      private function onViewLeaderboardClick(e:Event = null) : void
      {
         tintWindow();
         enableInput = false;
         this.manager.showLeaderboardUI(false);
      }
      
      public function onLockOver(index:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            if(Boolean(m_lockHover1_mc) && Boolean(m_lockHover2_mc))
            {
               if(index == 0)
               {
                  m_lockHover1_mc.visible = true;
               }
               else if(index == 1)
               {
                  m_lockHover2_mc.visible = true;
               }
            }
         };
      }
      
      public function onLockOut() : Function
      {
         return function(evt:MouseEvent):void
         {
            if(Boolean(m_lockHover1_mc) && Boolean(m_lockHover2_mc))
            {
               m_lockHover1_mc.visible = false;
               m_lockHover2_mc.visible = false;
            }
         };
      }
      
      private function updateAveragePanel() : void
      {
         if(this.m_average_panel)
         {
            this.m_average_panel.gotoAndStop(this.manager.overAllProgressLevel() + 2);
         }
         if(this.m_totalavg_tf)
         {
            this.m_totalavg_tf.text = this.manager.getCurrentAverage().toString();
         }
      }
      
      private function updateMilestoneStates() : void
      {
         var reward1:FarmItem = null;
         var milestone1_icon:FarmIcon = null;
         var reward2:FarmItem = null;
         var milestone2_icon:FarmIcon = null;
         var dailyItem:FarmItem = null;
         if(Boolean(this.m_milestone1_mc) && Boolean(this.m_milestone2_mc))
         {
            if(this.m_milestone1_mc["milestonereward_icon"])
            {
               reward1 = this.manager.getActiveDayReward(0);
               if(reward1)
               {
                  milestone1_icon = new FarmIcon(this.m_milestone1_mc["milestonereward_icon"]);
                  milestone1_icon.loadIcon(reward1.iconUrl);
                  milestone1_icon.setIconSize(35,35);
                  milestone1_icon.attachTooltip(new FarmTextTooltip(reward1.friendlyTitle));
               }
            }
            if(this.m_milestone2_mc["milestonereward_icon"])
            {
               reward2 = this.manager.getActiveDayReward(1);
               if(reward2)
               {
                  milestone2_icon = new FarmIcon(this.m_milestone2_mc["milestonereward_icon"]);
                  milestone2_icon.loadIcon(reward2.iconUrl);
                  milestone2_icon.setIconSize(35,35);
                  milestone2_icon.attachTooltip(new FarmTextTooltip(reward2.friendlyTitle));
               }
            }
            if(this.m_dailyreward_icon)
            {
               dailyItem = this.manager.getActiveDayReward(2);
               if(dailyItem)
               {
                  this.m_dailyreward_icon.loadIcon(dailyItem.iconUrl);
                  this.m_dailyreward_icon.setIconSize(60,60);
                  this.m_dailyreward_icon.detachTooltip();
                  this.m_dailyreward_icon.attachTooltip(new FarmTextTooltip(dailyItem.friendlyTitle));
                  this.m_dailyreward_icon.visible = true;
               }
            }
         }
      }
      
      public function onLeagueTabClick(index:int) : Function
      {
         return function(e:Event):void
         {
            var league:* = undefined;
            if(Boolean(m_leagues_mc) && Boolean(m_players_frame) && Boolean(m_norank_tf))
            {
               m_leagues_mc.gotoAndStop(index + 1);
               m_players_frame.visible = false;
               league = manager.getCurrentLeague();
               if(league != index)
               {
                  m_players_frame.visible = false;
                  setLeagueRewardIcon(league + 1,index + 1);
                  if(m_lbsubtitle_tf)
                  {
                     m_lbsubtitle_tf.visible = false;
                  }
                  if(Boolean(m_viewlb_bt) && Boolean(m_leaguerewards_bt))
                  {
                     m_viewlb_bt.visible = false;
                     m_leaguerewards_bt.visible = false;
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
                     m_norank_tf.visible = true;
                  }
                  else
                  {
                     m_norank_tf.visible = false;
                  }
                  if(m_lbsubtitle_tf)
                  {
                     m_lbsubtitle_tf.visible = true;
                  }
                  m_players_frame.visible = true;
                  if(m_leaguereward_icon)
                  {
                     m_leaguereward_icon.visible = false;
                  }
                  if(Boolean(m_viewlb_bt) && Boolean(m_leaguerewards_bt))
                  {
                     m_viewlb_bt.visible = true;
                     m_leaguerewards_bt.visible = true;
                  }
               }
            }
         };
      }
      
      public function getLeaderboardPlaySubtitle() : String
      {
         var subtitle:String = null;
         var league:int = this.manager.getCurrentLeague();
         if(league == 3)
         {
            subtitle = "Be among top 40 in weekly leaderboard to stay in Diamond League when the week ends!";
         }
         else
         {
            subtitle = "Be among the top 15 ranks this week to get promoted to " + this.manager.WreathFestival_LEAGUE_MAP[league + 1] + " League!";
         }
         return subtitle;
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
               this.m_leaguereward_icon.setIconSize(150,150);
               this.m_leaguereward_icon.visible = true;
            }
            else
            {
               this.m_leaguereward_icon.visible = false;
            }
         }
      }
      
      private function setPlayerNameTf(index:int, name:String) : void
      {
         if(Boolean(this.m_players_mc[index]) && Boolean(this.m_players_mc[index].hasOwnProperty("playername_tf")))
         {
            this.m_players_mc[index]["playername_tf"].text = name;
            this.m_players_mc[index].visible = true;
         }
      }
      
      private function setPlayerRankTf(index:int, rank:String) : void
      {
         if(Boolean(this.m_players_mc[index]) && Boolean(this.m_players_mc[index].hasOwnProperty("player_rank_tf")))
         {
            this.m_players_mc[index]["player_rank_tf"].text = rank;
            this.m_players_mc[index].visible = true;
         }
      }
      
      public function showLeaderboardPaneData() : void
      {
         var index:int = 0;
         var playerData:Object = null;
         if(Boolean(m_window) && Boolean(this.manager.m_leaderboardpane_data))
         {
            index = 0;
            if(this.m_norank_tf)
            {
               this.m_norank_tf.visible = false;
            }
            if(this.m_players_mc)
            {
               this.m_players_mc.visible = true;
            }
            for each(playerData in this.manager.m_leaderboardpane_data)
            {
               if(playerData)
               {
                  if(playerData["name"])
                  {
                     this.setPlayerNameTf(index,playerData["name"]);
                  }
                  else if(playerData["value"])
                  {
                     this.setPlayerNameTf(index,playerData["value"]);
                  }
                  else
                  {
                     this.setPlayerNameTf(index,"---");
                  }
                  if(playerData["rank"])
                  {
                     this.setPlayerRankTf(index,playerData["rank"]);
                  }
                  else
                  {
                     this.setPlayerRankTf(index,"-");
                  }
                  if(Boolean(this.m_players_mc) && Boolean(this.m_players_mc[index]["playe_cell_highlight"]))
                  {
                     if(Boolean(playerData["uid"]) && playerData["uid"] == Global.player.uid)
                     {
                        this.m_players_mc[index]["playe_cell_highlight"].visible = true;
                     }
                     else
                     {
                        this.m_players_mc[index]["playe_cell_highlight"].visible = false;
                     }
                  }
               }
               index++;
            }
         }
         else
         {
            if(Boolean(m_window) && Boolean(this.m_players_mc))
            {
               this.m_players_mc.visible = false;
            }
            if(Boolean(m_window) && Boolean(this.m_norank_tf))
            {
               this.m_norank_tf.visible = true;
            }
         }
      }
      
      public function showTutorialWithEAPage() : void
      {
         var element:MovieClip = null;
         var i:int = 0;
         var child:MovieClip = null;
         tutorialSceneNumber = 6;
         if(m_tutorial != null)
         {
            element = m_tutorial.element as MovieClip;
            element.gotoAndStop(5);
            for(i = 0; i < element.numChildren; i++)
            {
               child = element.getChildAt(i) as MovieClip;
               if(Boolean(child) && child != m_window.tutorial_mc.okay_bt)
               {
                  child.gotoAndPlay(1);
               }
            }
            m_tutorial.visible = true;
         }
      }
      
      override protected function preSwitchChanges(sceneNumber:int) : void
      {
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_SANTAVILLAGE) == true)
         {
            if(sceneNumber == 4)
            {
               tutorialSceneNumber = sceneNumber + 1;
            }
         }
         else if(sceneNumber == 3)
         {
            tutorialSceneNumber = sceneNumber + 1;
         }
         tutorialButtonText = tutorialSceneNumber == totalScenes - 1 ? "Great" : "Next";
      }
      
      private function startTimer() : void
      {
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         this.refreshConnectionTimerText();
      }
      
      private function refreshConnectionTimerText() : void
      {
         if(this.m_featuretime_tf)
         {
            this.m_featuretime_tf.text = this.manager.getFeatureEndDaysLeftText();
         }
      }
      
      private function howDoesThisWorkClick(e:Event = null) : void
      {
         this.showTutorialWindow();
      }
      
      private function showTutorialWindow() : void
      {
         if(this.m_tutorial_mc)
         {
            this.m_tutorial_mc.visible = true;
            if(this.m_transparent_mc)
            {
               this.m_transparent_mc.visible = true;
            }
         }
      }
      
      private function onTutorialClick(e:Event = null) : void
      {
         this.hideTransparentMask();
         if(this.m_tutorial_mc)
         {
            this.m_tutorial_mc.visible = false;
         }
      }
      
      override protected function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         this.preSwitchChanges(tutorialSceneNumber);
         if(tutorialSceneNumber < totalScenes)
         {
            ++tutorialSceneNumber;
            (m_tutorial.element as MovieClip).gotoAndStop(tutorialSceneNumber);
         }
         else
         {
            hideTutorial();
         }
      }
      
      private function getDayNumberForPlayer() : int
      {
         var index:int = this.manager.isGAPlayer() ? int(this.manager.activeDayIndex - 7) : this.manager.activeDayIndex;
         return index < 0 ? 0 : index;
      }
      
      public function updateProgressBar(onOpenWindow:Boolean = false) : void
      {
         var dayPoints:int = this.manager.getDayPoints();
         if(dayPoints > this.manager.VAL_THIRD_MILESTONE)
         {
            dayPoints = this.manager.VAL_THIRD_MILESTONE;
         }
         if(this.m_dailycount_tf)
         {
            this.m_dailycount_tf.text = dayPoints.toString();
         }
         var barLength:Number = dayPoints * this.PROGRESS_BAR_FULL_WIDTH / this.MAX_POINT;
         if(this.m_barMc)
         {
            if(dayPoints < 0)
            {
               this.m_barMc.x = barLength;
            }
            else if(onOpenWindow == false)
            {
               TweenMax.to(this.m_barMc,2,{"x":barLength});
            }
            else
            {
               this.m_barMc.x = barLength;
            }
         }
      }
      
      private function refreshLockVisiblility() : void
      {
         switch(this.manager.getUserState())
         {
            case this.manager.MEDIUM:
            case this.manager.LOCK2:
               this.m_lock1_mc.visible = false;
               this.m_lock2_mc.visible = true;
               break;
            case this.manager.HARD:
            case this.manager.DONE_FOR_THE_DAY:
               this.m_lock1_mc.visible = false;
               this.m_lock2_mc.visible = false;
               break;
            default:
               this.m_lock1_mc.visible = true;
               this.m_lock2_mc.visible = true;
         }
         if(this.manager.hasActiveDayExpired())
         {
            this.m_lock1_mc.visible = false;
            this.m_lock2_mc.visible = false;
         }
      }
      
      private function onStartNewDayClick(e:Event = null) : void
      {
         this.manager.startNewDay();
         if(this.m_dayinfo_mc)
         {
            this.m_dayinfo_mc.visible = false;
         }
      }
      
      private function onEndDayClick(e:Event = null) : void
      {
         this.hideTransparentMask();
         if(this.m_dayinfo_mc)
         {
            this.m_dayinfo_mc.visible = false;
         }
         if(!Global.player.getSeenFlag(this.LEADERBOARD_PLAYING_FLAG))
         {
            Global.player.setSeenFlag(this.LEADERBOARD_PLAYING_FLAG);
         }
         if(this.m_subtitle_tf)
         {
            if(!Global.player.getSeenFlag(this.LEADERBOARD_PLAYING_FLAG))
            {
               this.m_subtitle_tf.text = "Finish the tasks to fill the daily meter and win awesome rewards!";
            }
            else
            {
               this.m_subtitle_tf.text = this.getLeaderboardPlaySubtitle();
            }
            this.m_subtitle_tf.visible = true;
         }
         this.manager.playForLeaderboard();
      }
      
      public function showtileUnlockOverlay() : void
      {
         var count:int = this.manager.getTileUnlockCount();
         if(count > 0)
         {
            if(this)
            {
               this.enableInput = false;
               this.tintWindow();
            }
            UI.displayPopup(new WreathFestivalInnovationTileConsumablePopup(FEATURE_NAME,"assets/dialogs/FV_Innovation_Wreath_Festival/FV_NovInnovation_LandUnlockConsumable.swf"),false);
         }
      }
      
      private function onLeagueChangeClick(upgrade:Boolean = false) : Function
      {
         return function():void
         {
            hideTransparentMask();
            manager.resetLeagueChangeKey(upgrade);
            if(m_leaguechange_mc)
            {
               m_leaguechange_mc.visible = false;
            }
            refreshWindow();
         };
      }
      
      private function showLeagueChangeOverlay(upgraded:Boolean) : void
      {
         if(upgraded == true)
         {
            if(this.m_leaguechange_mc)
            {
               if(this.m_promotion1_tf)
               {
                  this.m_promotion1_tf.text = "Welcome to the " + this.manager.getCurrentLeagueName().toString() + " League!";
               }
               if(this.m_promotion2_tf)
               {
                  this.m_promotion2_tf.text = "Keep up the pace and score as many points as possible!";
               }
               if(this.m_leaguechange_icon)
               {
                  this.m_leaguechange_icon.loadIcon(this.PREFIX_LEAGUE_REWARD_ICONS + this.manager.LEAGUE_ICONS[this.manager.getCurrentLeague()]);
               }
               if(this.m_leaguechange_bt)
               {
                  this.m_leaguechange_bt.text = "Awesome!";
                  this.m_leaguechange_bt.callback = this.onLeagueChangeClick(true);
               }
               this.m_leaguechange_mc.gotoAndStop(1);
            }
         }
         else if(upgraded == false)
         {
            if(this.m_leaguechange_mc)
            {
               if(this.m_promotion1_tf)
               {
                  this.m_promotion1_tf.text = "Better luck next time!";
               }
               if(this.m_promotion2_tf)
               {
                  this.m_promotion2_tf.text = "You have been demoted to the " + this.manager.getCurrentLeagueName() + " League";
               }
               if(this.m_leaguechange_icon)
               {
                  this.m_leaguechange_icon.loadIcon(this.PREFIX_LEAGUE_REWARD_ICONS + this.manager.LEAGUE_ICONS[this.manager.getCurrentLeague()]);
               }
               if(this.m_leaguechange_bt)
               {
                  this.m_leaguechange_bt.text = "Okay!";
                  this.m_leaguechange_bt.callback = this.onLeagueChangeClick(false);
               }
               this.m_leaguechange_mc.gotoAndStop(2);
            }
         }
         this.m_leaguechange_mc.visible = true;
         if(this.m_transparent_mc)
         {
            this.m_transparent_mc.visible = true;
         }
      }
      
      private function showDayInfoOverlay(infoType:int) : void
      {
         var reward:FarmItem = null;
         if(this.m_dayinfo_mc)
         {
            if(infoType == 1)
            {
               if(this.m_dailyinfo1_tf)
               {
                  this.m_dailyinfo1_tf.text = "New Day Begins!";
               }
               if(this.m_dailyinfo2_tf)
               {
                  this.m_dailyinfo2_tf.text = "Complete orders on the board to reach the top! All the best!";
               }
               if(this.m_dailyinfo_icon)
               {
                  reward = this.manager.getNewDailyReward();
                  if(reward)
                  {
                     this.m_dailyinfo_icon.loadIcon(reward.iconUrl);
                  }
               }
               if(this.m_dailyinfo_bt)
               {
                  this.m_dailyinfo_bt.text = "Start Now!";
                  this.m_dailyinfo_bt.callback = this.onStartNewDayClick;
               }
            }
            else if(infoType == 2)
            {
               if(this.m_dailyinfo1_tf)
               {
                  this.m_dailyinfo1_tf.text = "Day has Ended!";
               }
               if(this.m_dailyinfo2_tf)
               {
                  this.m_dailyinfo2_tf.text = "You have reached the final milestone of the day! You can continue playing for the Leaderboard now.";
               }
               if(this.m_dailyinfo_icon)
               {
                  reward = this.manager.getNewDailyReward();
                  if(reward)
                  {
                     this.m_dailyinfo_icon.loadIcon(reward.iconUrl);
                  }
               }
               if(this.m_dailyinfo_bt)
               {
                  this.m_dailyinfo_bt.text = "Let\'s Go!";
                  this.m_dailyinfo_bt.callback = this.onEndDayClick;
               }
               if(this.manager.isLastDay() && !Global.player.getSeenFlag(this.NORMAL_FEATURE_END))
               {
                  this.manager.showFeatureEndMessages(1);
                  Global.player.setSeenFlag(this.NORMAL_FEATURE_END);
               }
            }
            this.m_dayinfo_mc.visible = true;
            if(this.m_transparent_mc)
            {
               this.m_transparent_mc.visible = true;
            }
         }
      }
      
      public function showLastDayOverlay() : void
      {
         if(this.manager.isLastDay() && !Global.player.getSeenFlag(this.LAST_DAY_ENTERED))
         {
            this.manager.showFeatureEndMessages(2);
            Global.player.setSeenFlag(this.LAST_DAY_ENTERED);
         }
      }
      
      public function refreshTaskFrame(e:Event = null) : void
      {
         var userStage:int = 0;
         if(this.m_consumecount_tf)
         {
            this.m_consumecount_tf.text = " x" + this.manager.consumableCount.toString();
         }
         var firstTimeFeatureAccess:Boolean = false;
         var redeemPreviousDayTask:Boolean = false;
         var hasLeagueUpdated:Boolean = false;
         if(this.manager.getUserState() == this.manager.NOT_INITIALIZED)
         {
            this.showDayInfoOverlay(1);
            firstTimeFeatureAccess = true;
         }
         else if(this.manager.hasLeagueUpgraded())
         {
            this.showLeagueChangeOverlay(true);
            hasLeagueUpdated = true;
         }
         else if(this.manager.hasLeagueDowngraded())
         {
            this.showLeagueChangeOverlay(false);
            hasLeagueUpdated = true;
         }
         else if(this.manager.hasActiveDayExpired())
         {
            if(this.manager.rdeemableTaskCount() > 0 && this.manager.getUserState() != this.manager.DONE_FOR_THE_DAY)
            {
               if(this.manager.redeemHasStarted == false)
               {
                  redeemPreviousDayTask = true;
                  if(this.manager.redeemMessageShown == false)
                  {
                     this.displayRedeemOverlay();
                     this.manager.redeemMessageShown = true;
                  }
               }
            }
            else if(this.manager.isFeatureInActivePeriod())
            {
               this.showDayInfoOverlay(1);
               firstTimeFeatureAccess = true;
            }
         }
         else
         {
            userStage = this.manager.getUserState();
            if(userStage == this.manager.LOCK1)
            {
               if(this.manager.hasEnoughConsumableToSink() && Boolean(this.m_lock1_mc))
               {
                  this.m_unlockanim1_mc.visible = true;
                  this.m_unlockanim1_mc.gotoAndPlay(1);
               }
               this.manager.sinkConsumable();
            }
            else if(userStage == this.manager.LOCK2)
            {
               if(this.manager.hasEnoughConsumableToSink() && Boolean(this.m_lock2_mc))
               {
                  this.m_unlockanim2_mc.visible = true;
                  this.m_unlockanim2_mc.gotoAndPlay(1);
               }
               this.manager.sinkConsumable();
            }
            else if(this.manager.getUserState() == this.manager.DONE_FOR_THE_DAY)
            {
               if(this.manager.getDayEndMessageShown() == false)
               {
                  this.showDayInfoOverlay(2);
               }
            }
         }
         if(!firstTimeFeatureAccess && this.manager.getUserState() != this.manager.DONE_FOR_THE_DAY)
         {
            if(Boolean(this.m_oblock_mc) && Boolean(this.m_oblock_tf))
            {
               if(this.manager.isUserLocked() && !this.manager.hasEnoughConsumableToSink())
               {
                  this.m_oblock_mc.visible = true;
                  this.m_oblock_tf.text = "You need " + this.manager.consumableNeededForUnlock().toString() + " consumables to move ahead!";
               }
               else
               {
                  this.m_oblock_mc.visible = false;
               }
            }
         }
         this.refreshLockVisiblility();
         this.updateProgressBar();
         this.updateAveragePanel();
         if(Boolean(this.m_milestone1_mc) && Boolean(this.m_milestone1_mc["checkmark_mc"]))
         {
            this.m_milestone1_mc["checkmark_mc"].visible = this.manager.getDayPoints() >= this.manager.VAL_FIRST_MILESTONE;
         }
         if(Boolean(this.m_milestone2_mc) && Boolean(this.m_milestone2_mc["checkmark_mc"]))
         {
            this.m_milestone2_mc["checkmark_mc"].visible = this.manager.getDayPoints() >= this.manager.VAL_SECOND_MILESTONE;
         }
         if(Boolean(this.m_progress_panel) && Boolean(this.m_progress_panel["checkmark_mc"]))
         {
            this.m_progress_panel["checkmark_mc"].visible = this.manager.getDayPoints() >= this.manager.VAL_THIRD_MILESTONE;
         }
         if(this.m_taskFrame)
         {
            this.m_taskFrame.refresh();
         }
      }
      
      public function hideTransparentMask() : void
      {
         if(this.m_transparent_mc)
         {
            this.m_transparent_mc.visible = false;
         }
      }
      
      override public function refreshWindow() : void
      {
         this.refreshTaskFrame();
         this.updateMilestoneStates();
      }
      
      public function showWelcomeEA() : void
      {
         if(!Global.player.getSeenFlag(this.INNOVATION_WELCOME_SEEN_FLAG))
         {
            Global.player.setSeenFlag(this.INNOVATION_WELCOME_SEEN_FLAG);
            if(this.m_welcomeEA_mc)
            {
               if(this.m_transparent_mc)
               {
                  this.m_transparent_mc.visible = true;
               }
               this.m_welcomeEA_mc.visible = true;
            }
         }
      }
      
      public function showWelcomeGA() : void
      {
         if(!Global.player.getSeenFlag(this.INNOVATION_WELCOME_SEEN_FLAG))
         {
            Global.player.setSeenFlag(this.INNOVATION_WELCOME_SEEN_FLAG);
            if(this.m_welcomeGA_mc)
            {
               if(this.m_transparent_mc)
               {
                  this.m_transparent_mc.visible = true;
               }
               this.m_welcomeGA_mc.visible = true;
            }
         }
      }
      
      private function onWelcomeClick(e:Event = null) : void
      {
         this.hideTransparentMask();
         if(this.m_welcomeEA_mc)
         {
            this.m_welcomeEA_mc.visible = false;
         }
         if(this.m_welcomeGA_mc)
         {
            this.m_welcomeGA_mc.visible = false;
         }
      }
      
      private function displayRedeemOverlay() : void
      {
         if(this.m_redeemlock_mc)
         {
            this.m_redeemlock_mc.visible = true;
            if(this.m_transparent_mc)
            {
               this.m_transparent_mc.visible = true;
            }
         }
      }
      
      private function onOldTasksRedeemClick(e:Event = null) : void
      {
         this.hideTransparentMask();
         if(this.m_redeemlock_mc)
         {
            this.m_redeemlock_mc.visible = false;
         }
      }
      
      public function playDooberAnimations() : void
      {
         if(Global.player.getSeenFlag(this.LEADERBOARD_PLAYING_FLAG))
         {
            if(this.m_lb_doober)
            {
               this.m_lb_doober.visible = true;
               this.m_lb_doober.gotoAndPlay(1);
            }
         }
         else if(this.m_ob_doober)
         {
            this.m_ob_doober.visible = true;
            this.m_ob_doober.gotoAndPlay(1);
         }
      }
      
      private function get manager() : WreathFestivalInnovationManager
      {
         return WreathFestivalInnovationManager.getInstance(FEATURE_NAME);
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
      
      public function resumeWindow() : void
      {
         untintWindow();
         enableInput = true;
         this.refreshTaskFrame();
      }
      
      override public function close() : void
      {
         this.stopTimer();
         this.manager.mainWindow = null;
         FarmStatsManager.count("WreathFestivalInnovation","Main_UI","close_window");
         super.close();
      }
   }
}

