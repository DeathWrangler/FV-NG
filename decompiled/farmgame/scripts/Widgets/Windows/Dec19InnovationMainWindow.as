package Widgets.Windows
{
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.MovieClipUtils;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.Dec19InnovationManager;
   import Managers.FarmStatsManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Dec19InnovationTaskFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   import mx.utils.StringUtil;
   
   public class Dec19InnovationMainWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 9;
      
      public static const ICON_SIZE:int = 50;
      
      private static const FEATURE_NAME:String = "Dec19Innovation";
      
      private var m_featureName:String = null;
      
      private const LEADERBOARD_PLAYING_FLAG:String = "Dec19_Leaderboard_Playing_flag";
      
      private const INNOVATION_WELCOME_SEEN_FLAG:String = "Dec19Innovation_Welcome_flag";
      
      private const NORMAL_FEATURE_END:String = "Dec19_Normal_Feature_End";
      
      private const LAST_DAY_ENTERED:String = "Dec19_Last_Day_entered";
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const SUBTITLE_TF:String = "subtitle_tf";
      
      private const TASKS_MC:String = "tasks_mc";
      
      private const FEATURE_TIMER_TF:String = "timer_tf";
      
      private const DAILY_TIMER_MC:String = "daily_clock_mc";
      
      private const FINISH_MC:String = "finish_mc";
      
      private const DUMPFTUE_MC:String = "dumpFTUE_mc";
      
      private const POINTS_TF:String = "points_tf";
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private const LEADERBOARD_BT:String = "leaderboard_bt";
      
      private const LEADERBOARD_MC:String = "leaderboard_mc";
      
      private var m_taskFrame:Dec19InnovationTaskFrame;
      
      private var m_finishMc:MovieClip;
      
      private var m_tileUnlock_mc:MovieClip;
      
      private var m_tileUnlockDes_tf:ZwTextField;
      
      private var m_tileUnlockCount_tf:ZwTextField;
      
      private var m_overlay_tf:ZwTextField;
      
      private var m_overlayUnlock_bt:FarmAnimatedTextButton;
      
      private var m_dooberMc:MovieClip;
      
      private var m_dooberIconMc:MovieClip;
      
      private var m_dooberCountTf:ZwTextField;
      
      private var m_highlightLB_mc:MovieClip;
      
      private const DAILY_PROGRESS_BAR_FULL_WIDTH:int = 73;
      
      private const DAY_MARKER_STARTING_POS:int = 67;
      
      private const PROGRESS_BAR_FULL_WIDTH:int = 274;
      
      private const EARNED_POINTS_MC_STARTING_POSTITION:int = 414;
      
      protected var m_DumpTutorial:ZwFrame = null;
      
      private var m_DumptutorialScene:int = 0;
      
      private var m_consumable_mc:MovieClip;
      
      private const CONSUMABLE_MC:String = "consumable_mc";
      
      private const COUNT_TF:String = "count_tf";
      
      private var m_consumableCount_tf:ZwTextField;
      
      private const DAILY_PROGRESS_MC:String = "meter_mc";
      
      private var m_daily_progress_mc:MovieClip;
      
      private var m_barMc:MovieClip;
      
      private var m_dailyTimer_tf:ZwTextField;
      
      private var m_dailyTimerMc:MovieClip;
      
      private var m_message_mc:MovieClip;
      
      private var m_messageTicket_mc:MovieClip;
      
      private var m_messageTitle:ZwTextField;
      
      private var m_messageInfo1:ZwTextField;
      
      private var m_messageInfo2:ZwTextField;
      
      private var m_messageCash:ZwTextField;
      
      private var m_messageOkay:FarmAnimatedCashButton;
      
      private const BUY_BT:String = "buy_bt";
      
      private var m_session_mc:MovieClip;
      
      private var m_sinkBt:FarmAnimatedCashButton;
      
      private const AFTER_MC:String = "after_mc";
      
      private const BEFORE_MC:String = "before_mc";
      
      private const TICK_MC:String = "tick_mc";
      
      private var m_lock1preview_mc:ZwFrame;
      
      private var m_lock2preview_mc:ZwFrame;
      
      private var m_lock1Hover:MovieClip;
      
      private var m_lock2Hover:MovieClip;
      
      private var m_timer:Timer;
      
      private var m_FeatureTimer:ZwTextField;
      
      private const FEATURE_TIMER_MC:String = "feature_timer_mc";
      
      private var m_featureTimer_mc:MovieClip;
      
      private const ProgressLevelTextArray:Array = ["EXPERT","PROFESSIONAL","CHAMPION"];
      
      private const EARNED_POINTS_MC:String = "earned_points_mc";
      
      private var m_lock1HoverText:ZwTextField;
      
      private var m_lock2HoverText:ZwTextField;
      
      private const REWARD_EA_WEEK:String = "reward_EA_mc";
      
      private var m_EA_week_mc:MovieClip;
      
      public var m_unlockanim1_mc:MovieClip;
      
      public var m_unlockanim2_mc:MovieClip;
      
      private const TILE_UNLOCK_CONSUMABLE_COUNT:int = 50;
      
      private var m_earnedPt_mc:MovieClip;
      
      private var m_ask_bt:FarmAnimatedTextButton;
      
      private var m_dailyReward_mc:MovieClip;
      
      private var m_mileStoneMcArray:Array = [];
      
      private var m_mileStonePoints_tfArray:Array = [];
      
      private var m_reward_mcArray:Array = [];
      
      private var m_rewardAfterMcArray:Array = [];
      
      private var m_rewardBeforeMcArray:Array = [];
      
      private var m_rewardIconMcArray:Array = [];
      
      private var m_rewardCountTfArray:Array = [];
      
      private var m_rewardBeforeMcPointsTfArray:Array = [];
      
      private var m_rewardTickMcArray:Array = [];
      
      private var m_preview_mcArray:Array = [];
      
      private const ASSET_PATH_WELCOME_ICON:String = "assets/dialogs/Dec19_Innovation/icon_welcome.png";
      
      private const PREVIEW_MC_KEY_ARRAY:Array = ["preview1_mc","preview2_mc","preview3_mc"];
      
      private const MILESTONE_MC_KEY_ARRAY:Array = ["milestone1_mc","milestone2_mc","milestone3_mc"];
      
      private const REWARD_MC_KEY_ARRAY:Array = ["reward1_mc","reward2_mc","reward3_mc"];
      
      private const DATE_ARRAY:Array = ["01/06/2020","12/30/2019","12/23/2019","12/16/2019","12/09/2019"];
      
      private var m_showTutorialWithEAPage:Boolean = false;
      
      private var m_iconPreview:ObjectPreviewFrame;
      
      private var m_isIconPreviewAdded:Boolean;
      
      private const PROGRESS_RECORDS_COUNTER:String = "feature_progress_small_mc";
      
      private const PROGRESS_RECORDS_COUNTER_GA:String = "feature_progress_small_GA_mc";
      
      private var m_best_icon_mc:FarmIcon;
      
      private var m_sinkBtTooltip:FarmTextTooltip;
      
      private var m_timerWidget:ZwFrame;
      
      private var m_timerToolTip:FarmTextTooltip;
      
      private const DAILY_DUMMY_MAX_POINT:Number = 30;
      
      private const MAX_POINT:Number = 35;
      
      private var m_barrel_mc:ZwFrame;
      
      private var m_firstStartSessionMC:MovieClip;
      
      private var m_tileUnlock_bt:FarmAnimatedTextButton;
      
      private var m_wineMc:MovieClip;
      
      private var m_mainBG_mc:MovieClip;
      
      private var m_checkMark_mc:MovieClip;
      
      private var m_dayChangeHasOccuredDuringOpenWindow:Boolean = false;
      
      private var m_noOfWeek:int = 6;
      
      private var m_firstSessionBt:FarmAnimatedTextButton;
      
      private var m_consumablehitWidget:ZwFrame;
      
      private var m_progress_record_mc:MovieClip;
      
      private var m_progress_record_array:Array = [];
      
      private var m_progressWidget:ZwFrame;
      
      private var m_BarInd:int = 0;
      
      private var m_levelHoverArray_mc:Array = [];
      
      private var m_idleNpc_mc:Array = [];
      
      private const FINAL_REWARD_CODE_ARRAY:Array = ["ydfr","faqx","hjix"];
      
      private var m_finalRewardIconArray_mc:Array = [];
      
      private var m_finalRewardTfArray_tf:Array = [];
      
      private var m_levels_mc:MovieClip;
      
      private var m_progressLevelArray_mc:Array;
      
      private var m_progressLevelArray_tf:Array;
      
      private var m_progressLevelArrarZFrame:Array;
      
      private var m_avg_points_info:ZwTextField;
      
      private var RANGE_ARRAY:Array = ["5-14","15-24","25 & above"];
      
      private var m_leaderboard_mc:MovieClip;
      
      private var m_leaderboardButton:FarmAnimatedTextButton;
      
      private var m_leaderboardhitWidget:ZwFrame;
      
      private var m_leaderboardIconMc:MovieClip;
      
      private var m_leaderboardPoints_tf:ZwTextField;
      
      private var m_leaderboardTimer_tf:ZwTextField;
      
      private var m_leaderboard_dooberMc:MovieClip;
      
      private var m_leaderboard_dooberIconMc:MovieClip;
      
      private var m_leaderboard_dooberCountTf:ZwTextField;
      
      private var m_talkMc:MovieClip;
      
      private var m_npc1Tf:ZwTextField;
      
      private var m_npc2Tf:ZwTextField;
      
      private var m_talkAutoMc:MovieClip;
      
      private var m_autoTalkMc:MovieClip;
      
      private var m_autoNpc1Tf:ZwTextField;
      
      private var m_autoNpc2Tf:ZwTextField;
      
      private var m_dailyRewardhitWidget:ZwFrame;
      
      private var m_featureEndMc:MovieClip;
      
      private var m_active1AniMc:MovieClip;
      
      private var m_active2AniMc:MovieClip;
      
      private var m_active3AniMc:MovieClip;
      
      private var m_league_icon_mc:MovieClip;
      
      private var m_effect_mc:MovieClip;
      
      private var m_npc_change_mc:MovieClip;
      
      private var m_leaderboard_bg_mc:MovieClip;
      
      private var m_overlay_mc:MovieClip;
      
      private var m_overlay1_tf:ZwTextField;
      
      private var m_overlay2_tf:ZwTextField;
      
      private var m_overlay3_tf:ZwTextField;
      
      public var m_gift_mc:MovieClip;
      
      private var m_get_bt:FarmAnimatedButton;
      
      private var m_active4AniMc:MovieClip;
      
      private const ANIMATED_REWARD_PACKAGES:Array = ["2gv3","2gx4","2gu7","2gye","2h03","2h0n","2gwz","2gyv","2enk","2erm","2ems","2eqb","2eqg","2eul","2ex2","2euk","2eln"];
      
      private const PACKAGE_REWARDS_ARRAY:Array = ["md5m","n8mm","s907","bvsx"];
      
      private var m_soon_tf:ZwTextField;
      
      private var m_overl_mc:MovieClip;
      
      public function Dec19InnovationMainWindow(featureName:String = "Dec19Innovation", assetUrl:String = null, showEAPageTutorial:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_showTutorialWithEAPage = showEAPageTutorial;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(FEATURE_NAME,assetUrl,numOfTutorialPages);
         this.m_BarInd = this.manager.isGAPlayer() ? 35 : 42;
      }
      
      override protected function postLoadComplete() : void
      {
         var isGA:Boolean = false;
         var index:int = 0;
         var finalRewardItem:FarmItem = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("gift_mc"))
         {
            this.m_gift_mc = m_window["gift_mc"] as MovieClip;
            this.m_gift_mc.visible = false;
            if(this.m_gift_mc.hasOwnProperty("soon_tf"))
            {
               this.m_soon_tf = new ZwTextField(this.m_gift_mc["soon_tf"],"COMING SOON!");
               this.m_soon_tf.visible = false;
            }
            if(this.m_gift_mc.hasOwnProperty("get_bt"))
            {
               this.m_get_bt = new FarmAnimatedTextButton(this.m_gift_mc["get_bt"],"GetGifts!",this.onClickGetGiftsButton);
               this.m_get_bt.visible = false;
            }
            if(this.manager.christmasDayIndex < 0)
            {
               this.m_soon_tf.visible = true;
            }
            if(this.manager.isChristmasWeek())
            {
               this.m_get_bt.visible = true;
            }
            if(this.manager.christmasDayIndex < 7)
            {
               this.m_gift_mc.visible = true;
            }
         }
         if(this.manager.isChristmasWeek())
         {
            if(this.m_soon_tf)
            {
               this.m_soon_tf.visible = false;
            }
            if(this.m_get_bt)
            {
               this.m_get_bt.visible = true;
            }
         }
         if(this.manager.hasActiveDayExpired())
         {
            if(Global.player.getSeenFlag(this.LEADERBOARD_PLAYING_FLAG))
            {
               Global.player.resetSeenFlag(this.LEADERBOARD_PLAYING_FLAG);
            }
         }
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"League Of Elves!"));
            m_window[this.TITLE_TF].visible = true;
         }
         if(m_window.hasOwnProperty(this.SUBTITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.SUBTITLE_TF],""));
            if(!Global.player.getSeenFlag(this.LEADERBOARD_PLAYING_FLAG))
            {
               m_window[this.SUBTITLE_TF].text = "Finish the tasks to fill the daily meter and win awesome rewards!";
            }
            else
            {
               m_window[this.SUBTITLE_TF].text = this.getLeaderboardPlaySubtitle();
            }
            m_window[this.SUBTITLE_TF].visible = true;
         }
         if(m_window.hasOwnProperty(this.REWARD_EA_WEEK))
         {
            this.m_EA_week_mc = m_window[this.REWARD_EA_WEEK] as MovieClip;
            this.m_EA_week_mc.visible = false;
         }
         if(m_window.hasOwnProperty("wine_meter_bg_mc"))
         {
            this.m_wineMc = m_window["wine_meter_bg_mc"] as MovieClip;
            this.m_wineMc.visible = true;
         }
         if(m_window.hasOwnProperty("main_bg_mc"))
         {
            this.m_mainBG_mc = m_window["main_bg_mc"] as MovieClip;
            this.m_mainBG_mc.visible = true;
         }
         if(m_window.hasOwnProperty("unlockanim1_mc"))
         {
            this.m_unlockanim1_mc = m_window["unlockanim1_mc"] as MovieClip;
            this.m_unlockanim1_mc.visible = false;
         }
         if(m_window.hasOwnProperty("unlockanim2_mc"))
         {
            this.m_unlockanim2_mc = m_window["unlockanim2_mc"] as MovieClip;
            this.m_unlockanim2_mc.visible = false;
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
         if(m_window.hasOwnProperty("NPC_change_mc"))
         {
            this.m_npc_change_mc = m_window["NPC_change_mc"] as MovieClip;
            this.m_npc_change_mc.visible = false;
         }
         if(m_window.hasOwnProperty("active1_ani_mc"))
         {
            this.m_active1AniMc = m_window.active1_ani_mc as MovieClip;
            this.m_active1AniMc.visible = false;
         }
         if(m_window.hasOwnProperty("active2_ani_mc"))
         {
            this.m_active2AniMc = m_window.active2_ani_mc as MovieClip;
            this.m_active2AniMc.visible = false;
         }
         if(m_window.hasOwnProperty("active3_ani_mc"))
         {
            this.m_active3AniMc = m_window.active3_ani_mc as MovieClip;
            this.m_active3AniMc.visible = false;
         }
         if(m_window.hasOwnProperty("active4_ani_mc"))
         {
            this.m_active4AniMc = m_window.active4_ani_mc as MovieClip;
            this.m_active4AniMc.visible = false;
         }
         for(var i:int = 0; i < 4; i++)
         {
            if(m_window.hasOwnProperty("idle" + (i + 1).toString() + "_ani_mc"))
            {
               this.m_idleNpc_mc[i] = m_window["idle" + (i + 1).toString() + "_ani_mc"] as MovieClip;
               this.m_idleNpc_mc[i].visible = false;
            }
         }
         if(m_window.hasOwnProperty(this.EARNED_POINTS_MC))
         {
            this.m_earnedPt_mc = m_window[this.EARNED_POINTS_MC] as MovieClip;
            this.m_earnedPt_mc.y = this.EARNED_POINTS_MC_STARTING_POSTITION;
            this.m_earnedPt_mc.visible = true;
         }
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_SANTAVILLAGE) && !this.hasSeenFeatureWelcome())
         {
            Global.player.setSeenFlag(this.INNOVATION_WELCOME_SEEN_FLAG);
            this.showAutoHideNPCCallouts("League of Elves!","Welcome, With Early Access you will have a full Expert meter this week and also get 40 Gift Ribbons.");
         }
         else if(!this.hasSeenFeatureWelcome())
         {
            Global.player.setSeenFlag(this.INNOVATION_WELCOME_SEEN_FLAG);
            this.showAutoHideNPCCallouts("League of Elves!","Welcome to the Competition!");
         }
         if(m_window.hasOwnProperty(this.CONSUMABLE_MC))
         {
            this.m_consumable_mc = m_window[this.CONSUMABLE_MC] as MovieClip;
            this.m_consumable_mc.visible = true;
            if(this.m_consumable_mc.hasOwnProperty(this.COUNT_TF))
            {
               addWidget(this.m_consumableCount_tf = new ZwTextField(this.m_consumable_mc[this.COUNT_TF],"x" + this.manager.consumableCount.toString()));
               this.m_consumableCount_tf.visible = true;
            }
            if(this.m_consumable_mc.hasOwnProperty("consumable_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_consumable_mc["consumable_bt"],"Get More",this.buyCallback));
            }
            if(this.m_consumable_mc.hasOwnProperty("barrel_mc"))
            {
               this.m_barrel_mc = new ZwFrame(this.m_consumable_mc["barrel_mc"]);
            }
            if(this.m_consumable_mc.hasOwnProperty("hit_area_mc"))
            {
               this.m_consumablehitWidget = new ZwFrame(this.m_consumable_mc["hit_area_mc"]);
               this.m_consumablehitWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("Gift Ribbons!","\nCollect gift ribbons to move ahead in the competition."));
               this.m_consumablehitWidget.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
            }
         }
         if(m_window.hasOwnProperty("highlightLB_mc"))
         {
            this.m_highlightLB_mc = m_window["highlightLB_mc"] as MovieClip;
            this.m_highlightLB_mc.visible = this.manager.getDayEndMessageShown();
         }
         if(m_window.hasOwnProperty("feature_progress_full_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["feature_progress_full_bt"],"Bonus Rewards",this.onProgressButtonClick));
         }
         isGA = this.manager.isGAPlayer();
         var progressRecordsCounter:String = isGA ? this.PROGRESS_RECORDS_COUNTER_GA : this.PROGRESS_RECORDS_COUNTER;
         var dayIndex:int = this.getDayNumberForPlayer();
         if(m_window.hasOwnProperty(progressRecordsCounter))
         {
            this.m_progress_record_mc = m_window[progressRecordsCounter] as MovieClip;
            this.m_progress_record_mc.visible = true;
            for(index = 0; index < this.m_BarInd; index++)
            {
               this.m_progress_record_array[index] = this.m_progress_record_mc["day_" + index.toString() + "_mc"];
               if(index >= dayIndex)
               {
                  this.m_progress_record_array[index].corck_mc.visible = false;
               }
               if(this.m_progress_record_array[index].hasOwnProperty("session_mc"))
               {
                  this.m_session_mc = this.m_progress_record_array[index]["session_mc"] as MovieClip;
                  this.m_session_mc.visible = dayIndex == index;
               }
               if(this.m_progress_record_array[index].hasOwnProperty("daymarker_mc"))
               {
                  this.m_progress_record_array[index].daymarker_mc.y = this.DAY_MARKER_STARTING_POS;
                  this.m_progress_record_array[index].daymarker_mc.visible = true;
               }
            }
            if(this.m_progress_record_mc.hasOwnProperty("hit_area_mc"))
            {
               this.m_progressWidget = new ZwFrame(this.m_progress_record_mc["hit_area_mc"]);
               this.m_progressWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("Daily Progress","These meters show your daily progress. The average from these will determine your Bonus Reward!"));
               this.m_progressWidget.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
            }
         }
         for(i = 0; i < 3; i++)
         {
            if(m_window.hasOwnProperty("level" + (i + 1).toString() + "_hover"))
            {
               this.m_levelHoverArray_mc[i] = m_window["level" + (i + 1).toString() + "_hover"] as MovieClip;
               if(this.m_levelHoverArray_mc[i].hasOwnProperty("icon_mc"))
               {
                  finalRewardItem = Global.farmGameSettingsManager.getFarmItemByCode(this.FINAL_REWARD_CODE_ARRAY[i]);
                  this.m_finalRewardIconArray_mc[i] = new FarmIcon(this.m_levelHoverArray_mc[i]["icon_mc"]);
                  this.m_finalRewardIconArray_mc[i].loadIcon(finalRewardItem.iconUrl);
               }
               if(this.m_levelHoverArray_mc[i].hasOwnProperty("req_tf"))
               {
                  this.m_finalRewardTfArray_tf[i] = new ZwTextField(this.m_levelHoverArray_mc[i]["req_tf"],this.overAllProgressButtonsTooltip(i));
               }
            }
         }
         if(m_window.hasOwnProperty("levels_mc"))
         {
            this.m_levels_mc = m_window["levels_mc"] as MovieClip;
            this.m_levels_mc.visible = true;
            this.m_progressLevelArray_mc = [];
            this.m_progressLevelArray_tf = [];
            this.m_progressLevelArrarZFrame = [];
            for(i = 0; i < 3; i++)
            {
               this.m_progressLevelArray_mc[i] = this.m_levels_mc["level" + (i + 1).toString() + "_mc"] as MovieClip;
               this.m_progressLevelArray_mc[i].visible = true;
               this.m_progressLevelArrarZFrame[i] = new ZwFrame(this.m_progressLevelArray_mc[i]);
               this.m_progressLevelArrarZFrame[i].registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseLevelHover(i));
               this.m_progressLevelArrarZFrame[i].registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseLevelOut(i));
               this.m_progressLevelArray_tf[i] = new ZwTextField(this.m_progressLevelArray_mc[i]["level_tf"],this.ProgressLevelTextArray[i]);
               this.m_progressLevelArray_tf[i].visible = true;
            }
            if(this.m_levels_mc.hasOwnProperty("avg_points_tf"))
            {
               this.m_avg_points_info = new ZwTextField(this.m_levels_mc["avg_points_tf"],"Your Average Score : " + this.manager.currentAverage.toString());
               this.m_avg_points_info.visible = true;
            }
         }
         if(m_window.hasOwnProperty("startday_ftue_mc"))
         {
            this.m_firstStartSessionMC = m_window["startday_ftue_mc"] as MovieClip;
            this.m_firstStartSessionMC.visible = false;
            this.m_firstSessionBt = new FarmAnimatedTextButton(this.m_firstStartSessionMC["overlay_bt"],"Let’s Do It!",this.closeFirstSessionStartMC);
         }
         if(m_window.hasOwnProperty(this.DAILY_PROGRESS_MC))
         {
            this.m_daily_progress_mc = m_window[this.DAILY_PROGRESS_MC] as MovieClip;
            this.m_daily_progress_mc.visible = true;
            this.m_barMc = this.m_daily_progress_mc["bar_fill_mc"] as MovieClip;
            this.m_barMc.visible = true;
         }
         if(m_window.hasOwnProperty("doober_mc"))
         {
            this.m_dooberMc = m_window["doober_mc"] as MovieClip;
            if(this.m_dooberMc.hasOwnProperty("dooberIcon_mc"))
            {
               this.m_dooberIconMc = this.m_dooberMc["dooberIcon_mc"];
               if(this.m_dooberIconMc.hasOwnProperty("dooberCount_tf"))
               {
                  addWidget(this.m_dooberCountTf = new ZwTextField(this.m_dooberIconMc["dooberCount_tf"]));
               }
            }
         }
         if(m_window.hasOwnProperty("EA_tf"))
         {
            (m_window["EA_tf"] as TextField).visible = true;
         }
         if(m_window.hasOwnProperty("view_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["view_bt"],"View Rewards",this.onProgressButtonClick));
         }
         if(m_window.hasOwnProperty("lastDay_mc"))
         {
            this.m_featureEndMc = m_window["lastDay_mc"] as MovieClip;
            this.m_featureEndMc["title_tf"].text = "THE COMPETITION IS OVER!";
            this.m_featureEndMc["body_tf"].text = "Refresh game to check your final rewards!";
            this.m_featureEndMc["body2_tf"].text = "Keep playing Farmville for more fun features and win cool rewards!";
            this.m_featureEndMc["close_bt"].visible = false;
            new FarmAnimatedTextButton(this.m_featureEndMc["accept_bt"],"Okay",this.onFeatureExpire);
            this.m_featureEndMc.visible = this.manager.hasFeatureExpired();
         }
         if(m_window.hasOwnProperty("overl_mc"))
         {
            this.m_overl_mc = m_window["overl_mc"] as MovieClip;
         }
         if(m_window.hasOwnProperty("message_big_mc"))
         {
            this.m_message_mc = m_window["message_big_mc"] as MovieClip;
            this.m_message_mc.visible = false;
            this.m_league_icon_mc = this.m_message_mc["league_icon_mc"] as MovieClip;
            this.m_league_icon_mc.visible = false;
            this.m_effect_mc = this.m_message_mc["effect_mc"] as MovieClip;
            this.m_effect_mc.visible = false;
            this.m_messageTicket_mc = this.m_message_mc["ticket_mc"] as MovieClip;
            this.m_messageTicket_mc.visible = false;
            this.m_messageTitle = new ZwTextField(this.m_message_mc[this.TITLE_TF],"");
            this.m_messageCash = new ZwTextField(this.m_message_mc["cast_tf"],"");
            this.m_messageInfo1 = new ZwTextField(this.m_message_mc["info1_tf"],"");
            this.m_messageInfo2 = new ZwTextField(this.m_message_mc["info2_tf"],"");
            this.m_sinkBtTooltip = new FarmTextTooltip(this.manager.getSinkButtonToolTipMessage());
            this.m_messageOkay = new FarmAnimatedCashButton(this.m_message_mc["okay_bt"],"",this.manager.consumableNeededForUnlock().toString(),null);
            this.m_messageOkay.attachTooltip(this.m_sinkBtTooltip);
            if(this.m_message_mc.icon_mc != null)
            {
               addWidget(new FarmIcon(this.m_message_mc.icon_mc));
            }
            this.m_messageCash.visible = false;
         }
         if(m_window.hasOwnProperty("tileUnlock_mc"))
         {
            this.m_tileUnlock_mc = m_window["tileUnlock_mc"] as MovieClip;
            this.m_tileUnlock_mc.visible = false;
            this.m_tileUnlockCount_tf = new ZwTextField(this.m_tileUnlock_mc["count_tf"],"");
            this.m_tileUnlockDes_tf = new ZwTextField(this.m_tileUnlock_mc["description_tf"],"");
            addWidget(this.m_overlayUnlock_bt = new FarmAnimatedTextButton(this.m_tileUnlock_mc["overlay_bt"],"Great!",this.onCloseTileOverlay));
            this.m_overlay_tf = new ZwTextField(this.m_tileUnlock_mc["overlay_tf"],"");
         }
         if(m_window.hasOwnProperty(this.FEATURE_TIMER_MC))
         {
            this.m_featureTimer_mc = m_window[this.FEATURE_TIMER_MC] as MovieClip;
            this.m_featureTimer_mc.visible = true;
            if(this.m_featureTimer_mc.hasOwnProperty(this.FEATURE_TIMER_TF))
            {
               this.m_FeatureTimer = new ZwTextField(this.m_featureTimer_mc[this.FEATURE_TIMER_TF],"");
               if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_SANTAVILLAGE) == true)
               {
                  this.m_FeatureTimer.text = "Day " + (this.manager.currentDayIndex + 1).toString() + "/42";
               }
               else
               {
                  this.m_FeatureTimer.text = "Day " + (this.manager.currentDayIndex - 6).toString() + "/35";
               }
               this.m_FeatureTimer.visible = true;
            }
         }
         if(m_window.hasOwnProperty("overlay_mc"))
         {
            this.m_overlay_mc = m_window["overlay_mc"] as MovieClip;
            this.m_overlay_mc.visible = false;
            if(this.m_overlay_mc.hasOwnProperty("overlay1_tf"))
            {
               this.m_overlay1_tf = new ZwTextField(this.m_overlay_mc["overlay1_tf"],"THE LEAGUE OF ELVES!");
            }
            if(this.m_overlay_mc.hasOwnProperty("overlay2_tf"))
            {
               this.m_overlay2_tf = new ZwTextField(this.m_overlay_mc["overlay2_tf"],"Stay in top 15 ranks to get promoted to a higher league!");
            }
            if(this.m_overlay_mc.hasOwnProperty("overlay3_tf"))
            {
               this.m_overlay3_tf = new ZwTextField(this.m_overlay_mc["overlay3_tf"],"Click to know your League and leaderboard position");
            }
         }
         if(m_window.hasOwnProperty(this.DAILY_TIMER_MC))
         {
            this.m_dailyTimerMc = m_window[this.DAILY_TIMER_MC] as MovieClip;
            this.m_timerToolTip = new FarmTextTooltip(this.dayTooltip);
            this.m_dailyTimerMc.visible = true;
            addWidget(this.m_timerWidget = new ZwFrame(this.m_dailyTimerMc),true);
            addWidget(this.m_dailyTimer_tf = new ZwTextField(this.m_dailyTimerMc["time_tf"],HUD.getformattedTimeLeft(this.manager.getTimeLeftInDay())));
         }
         if(m_window.hasOwnProperty("checkmark_mc"))
         {
            this.m_checkMark_mc = m_window["checkmark_mc"] as MovieClip;
            this.m_checkMark_mc.visible = this.manager.getUserState() == this.manager.DONE_FOR_THE_DAY;
         }
         if(m_window.hasOwnProperty(this.WHATISTHIS_MC))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.WHATISTHIS_MC],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_WHATISTHIS),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty(this.DUMPFTUE_MC))
         {
            this.m_DumpTutorial = addWidget(new ZwFrame(m_window[this.DUMPFTUE_MC]),false) as ZwFrame;
            if(m_window[this.DUMPFTUE_MC].okay_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_window.dumpFTUE_mc.okay_bt,ZLocUtils.t("Dialogs","Okay"),this.onDumpTutorialOkayButtonClick));
            }
         }
         if(m_window.hasOwnProperty(this.TASKS_MC))
         {
            this.m_taskFrame = new Dec19InnovationTaskFrame(m_window[this.TASKS_MC],this,this.m_featureName);
            this.m_taskFrame.visible = true;
         }
         for(var previewIndex:int = 0; previewIndex < 3; previewIndex++)
         {
            if(m_window.hasOwnProperty(this.PREVIEW_MC_KEY_ARRAY[previewIndex]))
            {
               addWidget(this.m_preview_mcArray[previewIndex] = new ZwFrame(m_window[this.PREVIEW_MC_KEY_ARRAY[previewIndex]]),true);
               this.m_preview_mcArray[previewIndex].registerEventListener(MouseEvent.MOUSE_OVER,this.onOver1(previewIndex));
               this.m_preview_mcArray[previewIndex].registerEventListener(MouseEvent.MOUSE_OUT,this.onOut1(previewIndex));
            }
         }
         for(var mileStoneIndex:int = 0; mileStoneIndex < 3; mileStoneIndex++)
         {
            this.m_mileStoneMcArray[mileStoneIndex] = m_window[this.MILESTONE_MC_KEY_ARRAY[mileStoneIndex]] as MovieClip;
            this.m_mileStoneMcArray[mileStoneIndex].visible = true;
            this.m_mileStonePoints_tfArray[mileStoneIndex] = new ZwTextField(this.m_mileStoneMcArray[mileStoneIndex][this.POINTS_TF],this.manager.VAL_MILESTONE_POINTS_ARRAY[mileStoneIndex]);
         }
         for(var mileStoneRewardIndex:int = 0; mileStoneRewardIndex < 3; mileStoneRewardIndex++)
         {
            this.m_reward_mcArray[mileStoneRewardIndex] = m_window[this.REWARD_MC_KEY_ARRAY[mileStoneRewardIndex]] as MovieClip;
            this.m_rewardAfterMcArray[mileStoneRewardIndex] = this.m_reward_mcArray[mileStoneRewardIndex][this.AFTER_MC] as MovieClip;
            this.m_rewardBeforeMcArray[mileStoneRewardIndex] = this.m_reward_mcArray[mileStoneRewardIndex][this.BEFORE_MC] as MovieClip;
            this.m_rewardBeforeMcPointsTfArray[mileStoneRewardIndex] = new ZwTextField(this.m_rewardBeforeMcArray[mileStoneRewardIndex]["points_tf"],"0000");
            this.m_rewardTickMcArray[mileStoneRewardIndex] = this.m_reward_mcArray[mileStoneRewardIndex][this.TICK_MC] as MovieClip;
            this.m_rewardCountTfArray[mileStoneRewardIndex] = new ZwTextField(this.m_reward_mcArray[mileStoneRewardIndex][this.COUNT_TF],"");
            this.m_rewardIconMcArray[mileStoneRewardIndex] = new FarmIcon(this.m_reward_mcArray[mileStoneRewardIndex]["icon_70_mc"],this.manager.getActiveDayReward(mileStoneRewardIndex).iconUrl);
            this.m_rewardIconMcArray[mileStoneRewardIndex].setIconSize(50,50);
            this.m_rewardIconMcArray[mileStoneRewardIndex].setSmoothing(true);
         }
         if(m_window.hasOwnProperty("level_lock1_hover"))
         {
            this.m_lock1Hover = m_window["level_lock1_hover"] as MovieClip;
            this.m_lock1Hover.visible = false;
            this.m_lock1HoverText = new ZwTextField(this.m_lock1Hover["info1_tf"],"Use 5 Gift Ribbons to unlock Professional Level!");
         }
         if(m_window.hasOwnProperty("level_lock2_hover"))
         {
            this.m_lock2Hover = m_window["level_lock2_hover"] as MovieClip;
            this.m_lock2Hover.visible = false;
            this.m_lock2HoverText = new ZwTextField(this.m_lock2Hover["info1_tf"],"Use 10 Gift Ribbons to unlock Champion Level!");
         }
         if(m_window.hasOwnProperty(this.FINISH_MC))
         {
            this.m_finishMc = m_window[this.FINISH_MC] as MovieClip;
         }
         if(m_window.hasOwnProperty("level_lock1_mc"))
         {
            addWidget(this.m_lock1preview_mc = new ZwFrame(m_window["level_lock1_mc"]),true);
            this.m_lock1preview_mc.registerEventListener(MouseEvent.MOUSE_OVER,this.onLock1Over);
            this.m_lock1preview_mc.registerEventListener(MouseEvent.MOUSE_OUT,this.onLock1Out);
         }
         if(m_window.hasOwnProperty("level_lock2_mc"))
         {
            addWidget(this.m_lock2preview_mc = new ZwFrame(m_window["level_lock2_mc"]),true);
            this.m_lock2preview_mc.registerEventListener(MouseEvent.MOUSE_OVER,this.onLock2Over);
            this.m_lock2preview_mc.registerEventListener(MouseEvent.MOUSE_OUT,this.onLock2Out);
         }
         if(Global.player.getSeenFlag(this.manager.TILE_UNLOCK))
         {
            this.showtileUnlockOverlay();
         }
         var leaderBoardData:Object = this.manager.getCurrentLeaderboard();
         var weekCount:int = int(leaderBoardData.count);
         if(m_window.hasOwnProperty(this.LEADERBOARD_MC))
         {
            this.m_leaderboard_mc = m_window[this.LEADERBOARD_MC] as MovieClip;
            this.m_leaderboard_mc.visible = true;
            addWidget(this.m_leaderboardButton = new FarmAnimatedTextButton(this.m_leaderboard_mc[this.LEADERBOARD_BT],"Check Rank",this.onClickLeaderboardButton));
            this.m_leaderboardButton.enabled = true;
            if(this.m_leaderboardButton.tooltip)
            {
               this.m_leaderboardButton.tooltip.release();
            }
            this.m_leaderboardButton.detachTooltip();
            if(this.m_leaderboard_mc.hasOwnProperty("hit_area_mc"))
            {
               this.m_leaderboardhitWidget = new ZwFrame(this.m_leaderboard_mc["hit_area_mc"]);
               this.attachNpcCalloutText();
            }
            if(this.m_leaderboard_mc.hasOwnProperty("leaderboardBG_mc"))
            {
               this.m_leaderboard_bg_mc = this.m_leaderboard_mc["leaderboardBG_mc"] as MovieClip;
               this.m_leaderboard_bg_mc.visible = true;
               this.m_leaderboard_bg_mc.gotoAndStop(this.manager.getCurrentLeague() + 1);
            }
            if(this.m_leaderboard_mc.hasOwnProperty("icon_mc"))
            {
               this.m_leaderboardIconMc = this.m_leaderboard_mc.icon_mc;
               this.m_leaderboardIconMc.gotoAndStop(weekCount);
            }
            addWidget(this.m_leaderboardPoints_tf = new ZwTextField(m_window[this.LEADERBOARD_MC]["points_tf"]));
            if(this.manager.getWeeklyLeaderboardPoints() >= 0)
            {
               this.m_leaderboardPoints_tf.text = "Score: " + this.manager.getWeeklyLeaderboardPoints();
               this.m_leaderboardPoints_tf.visible = true;
            }
            else
            {
               this.m_leaderboardPoints_tf.visible = false;
            }
            this.m_leaderboardTimer_tf = new ZwTextField(m_window[this.LEADERBOARD_MC]["timer_tf"],HUD.getformattedTimeLeft(this.manager.getTimeLeftInWeek()) + " Left");
            if(this.m_leaderboard_mc.hasOwnProperty("doober_mc"))
            {
               this.m_leaderboard_dooberMc = this.m_leaderboard_mc["doober_mc"] as MovieClip;
               if(this.m_leaderboard_dooberMc.hasOwnProperty("dooberIcon_mc"))
               {
                  this.m_leaderboard_dooberIconMc = this.m_leaderboard_dooberMc["dooberIcon_mc"];
                  if(this.m_leaderboard_dooberIconMc.hasOwnProperty("dooberCount_tf"))
                  {
                     this.m_leaderboard_dooberCountTf = new ZwTextField(this.m_leaderboard_dooberIconMc["dooberCount_tf"]);
                  }
               }
            }
         }
         this.updateWeeklyRewardGrantDateArray();
         var userData:Object = this.manager.getUserDataFromLeaderboard();
         var rewardPoints:int = this.manager.getWeeklyLeaderboardPoints();
         this.updateDayBonus();
         this.refreshTaskFrame();
         this.updateProgressBar(true);
         this.updateConsumableCount();
         this.startTimer();
         this.updateSmallProgressBars();
         this.showIdleNPC();
         this.manager.initializeLeaderBoardProgress(true);
         if(userData)
         {
            this.updateLeaderBoardFrame(rewardPoints,userData["rank"]);
         }
         if(this.manager.shouldUpdateLeague() && this.manager.isLeaderboardExpired(this.manager.getCurrentLeaderboardName()))
         {
            this.manager.updateCurrentLeague(true);
         }
      }
      
      private function getLeaderboardRankToDisplay() : String
      {
         var leaderboardRank:int = this.manager.getWeeklyLeaderboardRank();
         var weeklyScore:int = this.manager.getWeeklyLeaderboardPoints();
         var displayRank:String = leaderboardRank.toString();
         if(leaderboardRank == -1 || leaderboardRank == 0 || weeklyScore == 0)
         {
            displayRank = "-";
         }
         return displayRank;
      }
      
      public function updateWeeklyRewardGrantDateArray() : void
      {
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var endTimeStamp:Number = FarmGameUtil.synchronizedDateToNumber(this.DATE_ARRAY[this.DATE_ARRAY.length - 1]) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         while(this.DATE_ARRAY.length > 0 && endTimeStamp < currentTime)
         {
            this.DATE_ARRAY.pop();
            endTimeStamp = FarmGameUtil.synchronizedDateToNumber(this.DATE_ARRAY[this.DATE_ARRAY.length - 1]) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         }
      }
      
      public function onClickLeaderboardButton(evt:Event) : void
      {
         this.manager.showLeaderboardUI();
      }
      
      public function onClickGetGiftsButton(event:Event) : void
      {
         this.manager.showChristmasSurpriseUI();
      }
      
      public function CloseCrushMC(e:Event = null) : void
      {
      }
      
      public function onCloseTileOverlay(evt:Event) : void
      {
         this.m_tileUnlock_mc.visible = false;
         this.manager.addTileUnlockCount();
      }
      
      private function overAllProgressButtonsTooltip(index:int) : String
      {
         var tooltip:String = "";
         return tooltip + ("Average range of points for " + this.ProgressLevelTextArray[index] + ":\n " + this.RANGE_ARRAY[index]);
      }
      
      private function get dayTooltip() : String
      {
         var dayTooltip:String = "";
         if(this.manager.currentDayIndex < 7)
         {
            dayTooltip = "Event Day " + (this.manager.currentDayIndex + 1).toString();
         }
         else
         {
            dayTooltip = "Day " + (this.manager.currentDayIndex - 6).toString();
         }
         return dayTooltip;
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
      
      private function attachNpcCalloutText() : void
      {
         var isDowngrade:Boolean = false;
         var buttonName:String = null;
         var title:String = "Compete in Leaderboard";
         var subtitle:String = "\nYou can see your Leaderboard rank and League Information by clicking on the Check Rank button";
         if(this.manager.hasLeagueChanged())
         {
            isDowngrade = this.manager.hasLeagueDowngraded();
            buttonName = isDowngrade ? "Okay" : "Awesome";
            title = isDowngrade ? "League Demoted" : "League Promoted";
            subtitle = "\nClick on " + buttonName + " Button to check your league update and continue!";
         }
         this.m_leaderboardhitWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver(title,subtitle));
         this.m_leaderboardhitWidget.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
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
         if(this.manager.hasActiveDayExpired() && this.m_dayChangeHasOccuredDuringOpenWindow == false)
         {
            this.m_dayChangeHasOccuredDuringOpenWindow = true;
            this.refreshWindow();
         }
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var endTimeStamp:Number = FarmGameUtil.synchronizedDateToNumber(this.DATE_ARRAY[this.DATE_ARRAY.length - 1]) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(endTimeStamp < currentTime)
         {
            if(this.manager.isShowLeaderBoardPopup())
            {
               this.manager.showLeaderboardUI(true);
            }
            this.DATE_ARRAY.pop();
            this.refreshWindow();
         }
         this.m_dailyTimer_tf.text = HUD.getformattedTimeLeft(this.manager.getTimeLeftInDay());
         this.m_leaderboardTimer_tf.text = HUD.getformattedTimeLeft(this.manager.getTimeLeftInWeek()) + " Left";
         if(this.manager.hasActiveDayExpired() == false)
         {
            if(this.manager.getUserState() == this.manager.DONE_FOR_THE_DAY)
            {
            }
         }
      }
      
      private function onAskButtonClick(event:Event) : void
      {
         if(this.m_ask_bt.enabled)
         {
            this.m_ask_bt.enabled = false;
            this.manager.askForConsumables();
            this.refreshAskButton();
         }
      }
      
      public function refreshAskButton() : void
      {
         var xPostTimeRemaining:int = 0;
         var timeRemaining:Array = null;
         if(this.m_ask_bt)
         {
            xPostTimeRemaining = this.manager.getThrottleTimeRemaining(Dec19InnovationManager.FEED_NAME);
            if(xPostTimeRemaining > 0)
            {
               timeRemaining = FarmGameUtil.parseTimeLeft(xPostTimeRemaining);
               if(timeRemaining[1] !== 0 || timeRemaining[2] !== 0)
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_ask_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"asksnowflake_timeleft",{
                     "hrs":timeRemaining[1],
                     "min":timeRemaining[2]
                  }));
               }
               else
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_ask_bt,"Ask again in " + timeRemaining[3] + " seconds");
               }
            }
            else
            {
               this.m_ask_bt.enabled = true;
               this.m_ask_bt.detachTooltip();
            }
         }
      }
      
      public function onCraftButtonClick(e:Event) : void
      {
         this.manager.craftConsumableFromMainWindow();
      }
      
      private function onSinkButtonClick(e:Event) : void
      {
         if(this.m_messageCash.visible == true)
         {
            this.m_messageCash.visible = false;
         }
         if(this.manager.getUserState() == this.manager.LOCK1)
         {
            this.m_unlockanim1_mc.visible = true;
            this.m_unlockanim1_mc.gotoAndPlay(1);
         }
         else if(this.manager.getUserState() == this.manager.LOCK2)
         {
            this.m_unlockanim2_mc.visible = true;
            this.m_unlockanim2_mc.gotoAndPlay(1);
         }
         this.manager.sinkConsumable();
      }
      
      private function onProgressButtonClick(e:Event) : void
      {
         this.manager.openRewardViewWindow();
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         this.showTutorial();
      }
      
      override protected function showTutorial() : void
      {
         super.showTutorial();
         tutorialButtonText = "Next";
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
            this.hideTutorial();
         }
      }
      
      public function updateConsumableCount() : void
      {
         if(m_window.hasOwnProperty(this.CONSUMABLE_MC))
         {
            if(this.m_consumable_mc.hasOwnProperty(this.COUNT_TF))
            {
               this.m_consumableCount_tf.text = "x" + this.manager.consumableCount.toString();
               this.m_consumableCount_tf.visible = true;
            }
         }
      }
      
      public function showActiveNPCForCurrentLeague() : void
      {
         var npcs:Array = null;
         var league:int = 0;
         npcs = [this.m_active1AniMc,this.m_active2AniMc,this.m_active3AniMc,this.m_active4AniMc];
         league = this.manager.getCurrentLeague();
         var activeNPC:MovieClip = npcs[league];
         if(Boolean(activeNPC) && Boolean(this.m_idleNpc_mc[league]))
         {
            this.m_idleNpc_mc[league].visible = false;
            activeNPC.visible = true;
            activeNPC.play();
            activeNPC.addEventListener(Event.ENTER_FRAME,this.onActiveNPCAnimation(activeNPC),false,0,true);
         }
      }
      
      private function onActiveNPCAnimation(activeNPC:MovieClip) : Function
      {
         return function(event:Event):void
         {
            if(activeNPC.currentFrame == 120)
            {
               activeNPC.stop();
               activeNPC.visible = false;
               activeNPC.removeEventListener(Event.ENTER_FRAME,onActiveNPCAnimation(activeNPC),false);
               showIdleNPC();
            }
         };
      }
      
      private function showIdleNPC() : void
      {
         var league:int = 0;
         league = this.manager.getCurrentLeague();
         var idleNPC:MovieClip = this.m_idleNpc_mc[league];
         if(idleNPC)
         {
            idleNPC.visible = !this.manager.hasLeagueChanged();
            MovieClipUtils.recursivePlay(idleNPC);
         }
      }
      
      public function updateTaskDoober(taskPt:int = 0) : void
      {
         var dayPoints:int = this.manager.getDayPoints();
         if(dayPoints > this.manager.VAL_THIRD_MILESTONE)
         {
            dayPoints = this.manager.VAL_THIRD_MILESTONE;
         }
         if(this.m_dooberMc)
         {
            this.m_dooberMc.visible = true;
            if(this.m_dooberCountTf)
            {
               this.m_dooberCountTf.text = "+" + int(taskPt).toString();
            }
            this.m_dooberMc.gotoAndPlay(2);
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
         if(this.m_earnedPt_mc[this.POINTS_TF])
         {
            (this.m_earnedPt_mc[this.POINTS_TF] as TextField).text = int(dayPoints).toString();
         }
         if(dayPoints == this.manager.VAL_THIRD_MILESTONE)
         {
            (this.m_earnedPt_mc[this.POINTS_TF] as TextField).visible = false;
         }
         else
         {
            (this.m_earnedPt_mc[this.POINTS_TF] as TextField).visible = true;
         }
         var normalizedPoints:Number = dayPoints;
         if(dayPoints > 20)
         {
            normalizedPoints = 20 + (dayPoints - 20) * 10 / 15;
         }
         var barLength:Number = dayPoints * this.PROGRESS_BAR_FULL_WIDTH / this.MAX_POINT;
         if(this.m_barMc)
         {
            if(dayPoints < 0)
            {
               this.m_barMc.height = barLength;
               this.m_earnedPt_mc.y = this.EARNED_POINTS_MC_STARTING_POSTITION - barLength;
            }
            else if(onOpenWindow == false)
            {
               TweenMax.to(this.m_barMc,2,{"height":barLength});
               TweenMax.to(this.m_earnedPt_mc,2,{"y":this.EARNED_POINTS_MC_STARTING_POSTITION - barLength});
            }
            else
            {
               this.m_barMc.height = barLength;
               this.m_earnedPt_mc.y = this.EARNED_POINTS_MC_STARTING_POSTITION - barLength;
            }
         }
         this.updateCurrentdaySmallProgressBars();
      }
      
      public function updateSmallProgressBars() : void
      {
         var normalizedPoints:Number = NaN;
         var dayPoints:int = 0;
         var barLength:Number = 0;
         var dayInd:int = this.getDayNumberForPlayer();
         for(var index:int = 0; index < this.m_BarInd; index++)
         {
            dayPoints = this.manager.getpointsForTheDay(this.manager.isGAPlayer() ? int(index + 7) : index);
            if(dayPoints > this.manager.VAL_THIRD_MILESTONE)
            {
               dayPoints = this.manager.VAL_THIRD_MILESTONE;
            }
            normalizedPoints = dayPoints;
            if(dayPoints > 20)
            {
               normalizedPoints = 20 + (dayPoints - 20) * 10 / 15;
            }
            barLength = dayPoints * this.DAILY_PROGRESS_BAR_FULL_WIDTH / this.MAX_POINT;
            if(this.m_progress_record_array[index].bar_fill_mc)
            {
               if(dayPoints == 0)
               {
                  this.m_progress_record_array[index].bar_fill_mc.height = barLength;
                  this.m_progress_record_array[index].daymarker_mc.y = this.DAY_MARKER_STARTING_POS - barLength;
               }
               else
               {
                  TweenMax.to(this.m_progress_record_array[index].bar_fill_mc,2,{"height":barLength});
                  TweenMax.to(this.m_progress_record_array[index].daymarker_mc,2,{"y":this.DAY_MARKER_STARTING_POS - barLength});
               }
            }
            this.m_progress_record_array[index] = this.m_progress_record_mc["day_" + index.toString() + "_mc"];
            if(this.m_progress_record_array[index])
            {
               this.m_progress_record_array[index].corck_mc.visible = index < dayInd;
            }
         }
      }
      
      public function updateCurrentdaySmallProgressBars() : void
      {
         var dayNumber:int = this.getDayNumberForPlayer();
         var dayPoints:int = this.manager.getDayPoints();
         if(dayPoints > this.manager.VAL_THIRD_MILESTONE)
         {
            dayPoints = this.manager.VAL_THIRD_MILESTONE;
         }
         var normalizedPoints:Number = dayPoints;
         if(dayPoints > 20)
         {
            normalizedPoints = 20 + (dayPoints - 20) * 10 / 15;
         }
         var barLength:Number = dayPoints * this.DAILY_PROGRESS_BAR_FULL_WIDTH / this.MAX_POINT;
         if(this.m_progress_record_array[dayNumber].bar_fill_mc)
         {
            if(dayPoints == 0)
            {
               this.m_progress_record_array[dayNumber].bar_fill_mc.height = barLength;
               this.m_progress_record_array[dayNumber].daymarker_mc.y = this.DAY_MARKER_STARTING_POS - barLength;
            }
            else
            {
               TweenMax.to(this.m_progress_record_array[dayNumber].bar_fill_mc,2,{"height":barLength});
               TweenMax.to(this.m_progress_record_array[dayNumber].daymarker_mc,2,{"y":this.DAY_MARKER_STARTING_POS - barLength});
            }
         }
         if(this.m_avg_points_info)
         {
            this.m_avg_points_info.text = "Your Average Score : " + this.manager.currentAverage.toString();
            this.m_avg_points_info.visible = true;
         }
      }
      
      private function onIdleNPCAnimation(upgrade:Boolean = false) : Function
      {
         return function(event:Event):void
         {
            var league:* = manager.getCurrentLeague();
            var previousLeague:* = upgrade ? league - 1 : league + 1;
            var frame:* = league + 1;
            if(m_npc_change_mc.currentFrame == 12)
            {
               if(m_leaderboard_bg_mc)
               {
                  m_leaderboard_bg_mc.gotoAndStop(frame);
               }
               if(Boolean(m_idleNpc_mc[previousLeague]) && Boolean(m_idleNpc_mc[league]))
               {
                  m_idleNpc_mc[previousLeague].visible = false;
                  m_idleNpc_mc[league].visible = true;
               }
               m_leaderboardButton.enabled = true;
               m_npc_change_mc.gotoAndStop(1);
               m_npc_change_mc.visible = false;
               m_messageOkay.enabled = true;
               m_npc_change_mc.removeEventListener(Event.ENTER_FRAME,onIdleNPCAnimation(upgrade),false);
               attachNpcCalloutText();
               refreshTaskFrame();
            }
         };
      }
      
      private function playNPCUpdateAnimation(upgrade:Boolean = false) : Function
      {
         return function():void
         {
            m_npc_change_mc.visible = true;
            m_messageOkay.enabled = false;
            m_npc_change_mc.gotoAndPlay(1);
            manager.resetLeagueChangeKey(upgrade);
            m_npc_change_mc.addEventListener(Event.ENTER_FRAME,onIdleNPCAnimation(upgrade),false,0,true);
         };
      }
      
      private function setupMessageFrame(upgrade:Boolean = false) : void
      {
         this.m_taskFrame.visible = false;
         this.m_message_mc.visible = true;
         this.m_messageOkay.enabled = true;
         this.m_messageOkay.visible = true;
         this.m_highlightLB_mc.visible = false;
         this.m_messageTicket_mc.visible = false;
         this.m_effect_mc.visible = false;
         this.m_league_icon_mc.visible = true;
         this.m_league_icon_mc.gotoAndStop(this.manager.getCurrentLeague() + 1);
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         itemBox.visible = false;
         var currentLeague:int = this.manager.getCurrentLeague();
         var leagueToShow:int = upgrade ? int(currentLeague - 1) : int(currentLeague + 1);
         if(!this.m_npc_change_mc)
         {
            return;
         }
         if(this.m_leaderboard_bg_mc)
         {
            this.m_leaderboard_bg_mc.gotoAndStop(leagueToShow + 1);
         }
         if(Boolean(this.m_idleNpc_mc[leagueToShow]) && Boolean(this.m_idleNpc_mc[currentLeague]))
         {
            this.m_idleNpc_mc[leagueToShow].visible = true;
            this.m_idleNpc_mc[currentLeague].visible = false;
         }
      }
      
      private function showUpgradeMessage() : void
      {
         this.setupMessageFrame(true);
         this.m_messageTitle.text = "Welcome to the " + this.manager.getCurrentLeagueName() + " League!";
         this.m_messageInfo1.text = "Keep up the pace and score as many points as possible!";
         this.m_messageInfo2.text = "Get amazing rewards at the end of the week!";
         this.m_messageOkay.text = "Awesome!";
         this.m_leaderboardButton.enabled = true;
         this.m_messageOkay.callback = this.playNPCUpdateAnimation(true);
      }
      
      private function showDowngradeMessage() : void
      {
         this.setupMessageFrame(false);
         this.m_messageTitle.text = "Better Luck Next Time!";
         this.m_messageInfo1.text = "You have been demoted to the " + this.manager.getCurrentLeagueName() + " League.";
         this.m_messageInfo2.text = "Try your best to score well and get promoted this week!";
         this.m_messageOkay.text = "Okay!";
         this.m_leaderboardButton.enabled = true;
         this.m_messageOkay.callback = this.playNPCUpdateAnimation(false);
      }
      
      public function refreshTaskFrame(e:Event = null) : void
      {
         var firstTimeFeatureAccess:Boolean = false;
         var redeemPreviousDayTask:Boolean = false;
         var hasLeagueUpdated:Boolean = false;
         if(this.manager.getUserState() == this.manager.NOT_INITIALIZED)
         {
            this.displayFeatureStartMessage();
            firstTimeFeatureAccess = true;
         }
         else if(this.manager.hasLeagueUpgraded())
         {
            this.showUpgradeMessage();
            hasLeagueUpdated = true;
         }
         else if(this.manager.hasLeagueDowngraded())
         {
            this.showDowngradeMessage();
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
                     this.displayWelcomeBackMessage();
                     this.manager.redeemMessageShown = true;
                  }
               }
            }
            else if(this.manager.isFeatureInActivePeriod())
            {
               this.displayDayStartMessage();
               firstTimeFeatureAccess = true;
            }
            else
            {
               this.m_featureEndMc.visible = true;
            }
         }
         else if(this.manager.getUserState() == this.manager.LOCK1)
         {
            this.displayLock1Message();
         }
         else if(this.manager.getUserState() == this.manager.LOCK2)
         {
            this.displayLock2Message();
         }
         else if(this.manager.getUserState() == this.manager.DONE_FOR_THE_DAY)
         {
            this.m_checkMark_mc.visible = true;
            if(this.manager.getDayEndMessageShown() == false)
            {
               this.displayDayFinishedMessage();
            }
         }
         else
         {
            this.m_message_mc.visible = false;
            this.m_taskFrame.visible = true;
         }
         this.refreshLockVisiblility();
         this.m_messageOkay.setAmountText(this.manager.consumableNeededForUnlock().toString());
         var tooltip:String = this.manager.getSinkButtonToolTipMessage();
         if(this.m_sinkBtTooltip)
         {
            this.m_sinkBtTooltip.setText(tooltip);
         }
         if(!firstTimeFeatureAccess && this.manager.getUserState() != this.manager.DONE_FOR_THE_DAY)
         {
            if(this.manager.isSinkActive())
            {
               this.m_messageOkay.enabled = true;
               this.m_messageOkay.callback = this.onSinkButtonClick;
            }
            else if(!redeemPreviousDayTask && !hasLeagueUpdated)
            {
               this.m_messageOkay.callback = null;
               this.m_messageOkay.enabled = false;
               this.m_messageOkay.element.mouseEnabled = this.m_messageOkay.element.mouseChildren = true;
            }
         }
         this.m_taskFrame.refresh();
         this.m_consumableCount_tf.text = "x" + this.manager.consumableCount.toString();
         this.updateOverallProgressButtons();
      }
      
      private function refreshLockVisiblility() : void
      {
         switch(this.manager.getUserState())
         {
            case this.manager.MEDIUM:
            case this.manager.LOCK2:
               this.m_lock1preview_mc.visible = false;
               this.m_lock2preview_mc.visible = true;
               break;
            case this.manager.HARD:
            case this.manager.DONE_FOR_THE_DAY:
               this.m_lock1preview_mc.visible = false;
               this.m_lock2preview_mc.visible = false;
               break;
            default:
               this.m_lock1preview_mc.visible = true;
               this.m_lock2preview_mc.visible = true;
         }
         if(this.manager.hasActiveDayExpired())
         {
            this.m_lock1preview_mc.visible = false;
            this.m_lock2preview_mc.visible = false;
         }
      }
      
      private function buyCallback(event:Event) : void
      {
         tintWindow();
         enableInput = false;
         this.manager.openBuyWindow(this);
      }
      
      public function updateLeaderBoardFrame(points:int, rank:int = 0) : void
      {
         if(this.m_leaderboardPoints_tf)
         {
            this.m_leaderboardPoints_tf.text = "Score: " + this.manager.getWeeklyLeaderboardPoints();
         }
      }
      
      public function updateLeaderboardDoober(taskPt:int = 0) : void
      {
         if(this.m_leaderboard_dooberMc)
         {
            this.m_leaderboard_dooberMc.visible = true;
            if(this.m_leaderboard_dooberCountTf)
            {
               this.m_leaderboard_dooberCountTf.text = "+" + int(taskPt).toString();
            }
            this.m_leaderboard_dooberMc.gotoAndPlay(2);
         }
      }
      
      public function displayLock1Message() : void
      {
         this.m_effect_mc.visible = true;
         this.m_league_icon_mc.visible = false;
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageOkay.visible = true;
         this.m_messageCash.visible = true;
         this.m_messageTicket_mc.visible = true;
         this.m_messageOkay.text = "Use";
         this.m_messageOkay.callback = this.onSinkButtonClick;
         this.m_messageTitle.text = "Congratulations!";
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.visible = false;
         }
         var rewardItem:FarmItem = this.manager.getActiveDayReward(this.manager.EASY);
         this.loadMessageIcon(rewardItem);
         this.m_messageInfo1.text = "You completed the Expert tier! Find your rewards in your giftbox!";
         this.m_messageInfo2.text = "Use Gift Ribbons to move to the next tier";
         this.m_messageCash.text = "5";
      }
      
      public function displayLock2Message() : void
      {
         this.m_effect_mc.visible = true;
         this.m_league_icon_mc.visible = false;
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageOkay.visible = true;
         this.m_messageCash.visible = true;
         this.m_messageTicket_mc.visible = true;
         this.m_messageOkay.text = "Use";
         this.m_messageOkay.callback = this.onSinkButtonClick;
         this.m_messageTitle.text = "Congratulations!";
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.visible = false;
         }
         var rewardItem:FarmItem = this.manager.getActiveDayReward(this.manager.MEDIUM);
         this.loadMessageIcon(rewardItem);
         this.m_messageInfo1.text = "You completed the Professional tier! Find your rewards in your giftbox!";
         this.m_messageInfo2.text = "Use Gift Ribbons to move to the next tier";
         this.m_messageCash.text = "10";
      }
      
      public function displayWelcomeBackMessage() : void
      {
         this.m_effect_mc.visible = true;
         this.m_league_icon_mc.visible = false;
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageTitle.text = "Get, Set, Start!";
         this.m_messageOkay.visible = true;
         this.m_messageOkay.text = "Okay";
         this.m_messageOkay.enabled = true;
         this.m_messageOkay.callback = this.getOldTasksRedeemedFromUser;
         this.m_messageTicket_mc.visible = false;
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.loadIcon(this.ASSET_PATH_WELCOME_ICON);
            itemBox.visible = true;
         }
         this.m_messageInfo1.text = "Looks like there are some tasks ready to redeem!";
         this.m_messageInfo2.text = "Redeem these tasks to enter today’s competition!";
      }
      
      public function getOldTasksRedeemedFromUser(e:Event = null) : void
      {
         this.m_message_mc.visible = false;
         this.m_taskFrame.visible = true;
      }
      
      public function displayDayFinishedMessage() : void
      {
         if(this.manager.isLastDay() == true && Global.player.getSeenFlag(this.NORMAL_FEATURE_END) == false)
         {
            this.m_featureEndMc["title_tf"].text = "The competition is almost over!";
            this.m_featureEndMc["body_tf"].text = "Keep playing for leaderboard rewards";
            this.m_featureEndMc["body2_tf"].text = "You can still earn a better reward by ranking up!";
            this.m_featureEndMc["close_bt"].visible = false;
            new FarmAnimatedTextButton(this.m_featureEndMc["accept_bt"],"Okay",this.onFeatureEnd);
            this.m_featureEndMc.visible = true;
            Global.player.setSeenFlag(this.NORMAL_FEATURE_END);
         }
         this.m_effect_mc.visible = true;
         this.m_league_icon_mc.visible = false;
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageTitle.text = "Congratulations";
         this.m_messageOkay.visible = true;
         this.m_messageOkay.enabled = true;
         this.m_messageTicket_mc.visible = false;
         this.m_messageOkay.text = "Play Leaderboard";
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.loadIcon(this.ASSET_PATH_WELCOME_ICON);
            itemBox.visible = true;
         }
         var attachedToolTip:FarmTextTooltip = itemBox.tooltip as FarmTextTooltip;
         if(attachedToolTip)
         {
            attachedToolTip.release();
            itemBox.detachTooltip();
         }
         var rewardItem:FarmItem = this.manager.getActiveDayReward(this.manager.HARD);
         this.m_messageInfo1.text = "You have completed all the task for today.";
         this.m_messageInfo2.text = this.getLeagueSubtileText();
         this.m_messageOkay.callback = this.playForLeaderboardHelper;
      }
      
      public function getLeagueSubtileText() : String
      {
         var league:int = this.manager.getCurrentLeague();
         var msg:String = "";
         if(league == 0)
         {
            msg = "Be among the top 15 in weekly leaderboard to get promoted to Silver League";
         }
         else if(league == 1)
         {
            msg = "Be among the top 15 in weekly leaderboard to get promoted to Gold League";
         }
         else if(league == 2)
         {
            msg = "Be among the top 15 in weekly leaderboard to get promoted to Diamond League";
         }
         else if(league == 3)
         {
            msg = "Be among the top 40 in weekly leaderboard to stay in Diamond League";
         }
         return msg;
      }
      
      public function playForLeaderboardHelper(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(this.LEADERBOARD_PLAYING_FLAG))
         {
            Global.player.setSeenFlag(this.LEADERBOARD_PLAYING_FLAG);
         }
         m_window[this.SUBTITLE_TF].text = this.getLeaderboardPlaySubtitle();
         this.m_highlightLB_mc.visible = true;
         this.m_message_mc.visible = false;
         this.m_taskFrame.visible = true;
         this.m_messageOkay.visible = false;
         this.m_messageOkay.enabled = false;
         this.manager.playForLeaderboard();
      }
      
      public function getLeaderboardPlaySubtitle() : String
      {
         var league:int = this.manager.getCurrentLeague();
         var msg:String = "Be among the top {0} in weekly leaderboard to get promoted to the {1} League when the week ends!";
         if(league == 0 || league == 1 || league == 2)
         {
            return StringUtil.substitute(msg,this.manager.LEAGUE_UPGRADE_MAP[league],this.manager.DEC19_LEAGUE_MAP[league + 1]);
         }
         if(league == 3)
         {
            msg = "Be among the top 40 in weekly leaderboard to stay in the Diamond League when the week ends!";
         }
         return msg;
      }
      
      public function displayDayStartMessage() : void
      {
         this.m_effect_mc.visible = true;
         this.m_league_icon_mc.visible = false;
         this.m_highlightLB_mc.visible = false;
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageOkay.enabled = true;
         this.m_messageOkay.visible = true;
         this.m_messageTicket_mc.visible = false;
         this.m_messageOkay.callback = this.manager.startNewDay;
         this.m_messageOkay.text = "Start Now";
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.loadIcon(this.ASSET_PATH_WELCOME_ICON);
            itemBox.visible = true;
         }
         if(this.manager.getUserState() == this.manager.DONE_FOR_THE_DAY)
         {
            this.m_messageTitle.text = "A NEW DAY BEGINS!";
            this.m_messageInfo1.text = "Complete orders on the board to reach the top!";
         }
         else
         {
            this.m_messageTitle.text = "A NEW DAY BEGINS!";
            this.m_messageInfo1.text = "Complete orders on the board to reach the top!";
         }
         this.m_messageInfo2.text = "Win amazing rewards for your effort! All the best!";
      }
      
      public function displayFeatureStartMessage() : void
      {
         this.m_effect_mc.visible = true;
         this.m_league_icon_mc.visible = false;
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageOkay.visible = true;
         this.m_messageTicket_mc.visible = false;
         this.m_messageOkay.callback = this.manager.startNewDay;
         this.m_messageOkay.text = "Start Now!";
         this.m_messageTitle.text = "A NEW DAY BEGINS!";
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.loadIcon(this.ASSET_PATH_WELCOME_ICON);
            itemBox.visible = true;
         }
         this.m_messageInfo1.text = "Complete orders on the board to reach the top!";
         this.m_messageInfo2.text = "Win amazing rewards for your effort! All the best!";
      }
      
      public function loadMessageIcon(farmItem:FarmItem) : void
      {
         var attachedToolTip:FarmTextTooltip = null;
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.loadIcon(farmItem.icon);
            itemBox.visible = true;
            attachedToolTip = itemBox.tooltip as FarmTextTooltip;
            if(attachedToolTip)
            {
               attachedToolTip.release();
               itemBox.detachTooltip();
            }
            itemBox.attachTooltip(new FarmTextTooltip(farmItem.friendlyTitle));
         }
      }
      
      public function displayLeagueOverlay() : void
      {
         if(this.m_overlay_mc)
         {
            this.m_overlay_mc.visible = true;
         }
      }
      
      override public function refreshWindow() : void
      {
         this.m_checkMark_mc.visible = false;
         this.m_consumableCount_tf.text = "x" + this.manager.consumableCount.toString();
         var rewardPoints:int = this.manager.getWeeklyLeaderboardPoints();
         this.refreshTaskFrame();
         this.updateProgressBar();
         this.updateSmallProgressBars();
         this.updateActiveDayIndex();
         this.updateDayBonus();
         if(this.manager.hasFeatureExpired())
         {
            this.m_featureEndMc.visible = true;
         }
      }
      
      public function updateDayBonus() : void
      {
         var finalMileStoneItem:FarmItem = null;
         if(m_window.hasOwnProperty("best_icon_50_mc"))
         {
            this.m_dailyReward_mc = m_window["best_icon_50_mc"] as MovieClip;
            this.m_dailyRewardhitWidget = new ZwFrame(m_window["best_icon_50_mc"] as MovieClip);
            this.m_dailyRewardhitWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("Daily Bonus!","\nBecome a Champion to grab this exclusive reward today!"));
            this.m_dailyRewardhitWidget.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
            if(this.m_isIconPreviewAdded == true)
            {
               removeWidget(this.m_iconPreview);
               this.m_iconPreview.detachTooltip();
            }
            if(this.m_best_icon_mc)
            {
               this.m_best_icon_mc.visible = false;
               (this.m_best_icon_mc as FarmIcon).release();
            }
            finalMileStoneItem = this.manager.getActiveDayReward(2);
            if(finalMileStoneItem)
            {
               if(this.PACKAGE_REWARDS_ARRAY.indexOf(finalMileStoneItem.code) == -1)
               {
                  addWidget(this.m_iconPreview = new ObjectPreviewFrame(m_window["best_icon_50_mc"] as MovieClip,finalMileStoneItem,null,null,[100]),true);
                  this.m_iconPreview.attachTooltip(new FarmTextTooltip(finalMileStoneItem.friendlyTitle));
                  this.m_isIconPreviewAdded = true;
               }
               else
               {
                  this.m_best_icon_mc = new FarmIcon(m_window["best_icon_50_mc"],finalMileStoneItem.iconUrl);
                  this.m_best_icon_mc.setIconSize(90,90);
                  this.m_best_icon_mc.attachTooltip(new FarmTextTooltip(finalMileStoneItem.friendlyTitle));
                  this.m_best_icon_mc.visible = true;
               }
            }
         }
         for(var mileStoneRewardIndex:int = 0; mileStoneRewardIndex < 3; mileStoneRewardIndex++)
         {
            if(this.m_rewardIconMcArray[mileStoneRewardIndex])
            {
               (this.m_rewardIconMcArray[mileStoneRewardIndex] as FarmIcon).release();
               this.m_rewardIconMcArray[mileStoneRewardIndex] = new FarmIcon(this.m_reward_mcArray[mileStoneRewardIndex]["icon_70_mc"],this.manager.getActiveDayReward(mileStoneRewardIndex).iconUrl);
               this.m_rewardIconMcArray[mileStoneRewardIndex].setIconSize(50,50);
               this.m_rewardIconMcArray[mileStoneRewardIndex].setSmoothing(true);
            }
         }
      }
      
      public function updateActiveDay() : void
      {
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_SANTAVILLAGE) == true)
         {
            this.m_FeatureTimer.text = "Day " + (this.manager.currentDayIndex + 1).toString() + "/42";
         }
         else
         {
            this.m_FeatureTimer.text = "Day " + (this.manager.currentDayIndex - 6).toString() + "/35";
         }
      }
      
      public function updateActiveDayIndex() : void
      {
         if(this.m_session_mc)
         {
            this.m_session_mc.visible = false;
         }
         var dayInd:int = this.getDayNumberForPlayer();
         for(var index:int = 0; index < this.m_BarInd; index++)
         {
            if(this.m_progress_record_array[index].hasOwnProperty("session_mc"))
            {
               if(dayInd == index)
               {
                  this.m_session_mc = this.m_progress_record_array[index]["session_mc"] as MovieClip;
                  this.m_session_mc.visible = true;
               }
               else
               {
                  (this.m_progress_record_array[index]["session_mc"] as MovieClip).visible = false;
               }
            }
         }
      }
      
      private function updateOverallProgressButtons() : void
      {
         var i:int = 0;
         if(this.m_progressLevelArray_mc)
         {
            for(i = 0; i < 3; i++)
            {
               if(i == this.manager.overAllProgressLevel())
               {
                  this.m_progressLevelArray_mc[i].gotoAndStop(2);
               }
               else
               {
                  this.m_progressLevelArray_mc[i].gotoAndStop(1);
               }
            }
         }
      }
      
      private function getFeatureTimeLeft() : String
      {
         return this.manager.getFeatureEndDaysLeftText();
      }
      
      private function get manager() : Dec19InnovationManager
      {
         return Dec19InnovationManager.getInstance(FEATURE_NAME);
      }
      
      public function showDumpTutorial() : void
      {
         var element:MovieClip = null;
         var i:int = 0;
         var child:MovieClip = null;
         this.m_DumptutorialScene = 1;
         if(this.m_DumpTutorial)
         {
            element = this.m_DumpTutorial.element as MovieClip;
            element.gotoAndStop(1);
            for(i = 0; i < element.numChildren; i++)
            {
               child = element.getChildAt(i) as MovieClip;
               if(Boolean(child) && child != m_window[this.DUMPFTUE_MC].okay_bt)
               {
                  child.gotoAndPlay(1);
               }
            }
            this.m_DumpTutorial.visible = true;
         }
      }
      
      private function onDumpTutorialOkayButtonClick(event:MouseEvent) : void
      {
         if(this.m_DumptutorialScene < 2)
         {
            ++this.m_DumptutorialScene;
            (this.m_DumpTutorial.element as MovieClip).gotoAndStop(this.m_DumptutorialScene);
         }
         else
         {
            this.hideDumpTutorial();
         }
      }
      
      private function hideDumpTutorial() : void
      {
         (this.m_DumpTutorial.element as MovieClip).stop();
         this.m_DumpTutorial.visible = false;
      }
      
      public function onOver1(i:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            if(i == 0 && WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_SANTAVILLAGE))
            {
               if(manager.activeDayIndex < 7)
               {
                  m_EA_week_mc.visible = true;
                  return;
               }
            }
            var isMileStoneAchieved:* = manager.isMilestoneAchievedForLevel(i);
            m_reward_mcArray[i].visible = i == 2 && Boolean(isMileStoneAchieved) ? false : true;
            m_rewardAfterMcArray[i].visible = isMileStoneAchieved;
            m_rewardBeforeMcArray[i].visible = !isMileStoneAchieved;
            m_rewardBeforeMcPointsTfArray[i].text = (manager.VAL_MILESTONE_POINTS_ARRAY[i] - manager.getDayPoints()).toString() + " more";
            m_rewardCountTfArray[i].text = "x1";
            m_rewardTickMcArray[i].visible = isMileStoneAchieved;
         };
      }
      
      public function onOut1(i:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            m_reward_mcArray[i].visible = false;
            if(m_EA_week_mc)
            {
               m_EA_week_mc.visible = false;
            }
         };
      }
      
      private function onLock1Over(evt:MouseEvent) : void
      {
         this.m_lock1Hover.visible = true;
      }
      
      private function onLock1Out(evt:MouseEvent) : void
      {
         this.m_lock1Hover.visible = false;
      }
      
      private function onLock2Over(evt:MouseEvent) : void
      {
         this.m_lock2Hover.visible = true;
      }
      
      private function onLock2Out(evt:MouseEvent) : void
      {
         this.m_lock2Hover.visible = false;
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
      
      override protected function hideTutorial() : void
      {
         super.hideTutorial();
         if(this.m_firstStartSessionMC)
         {
            if(Global.player.getSeenFlag(this.manager.FIRST_SESSION_TUTORIAL) == false)
            {
               Global.player.setSeenFlag(this.manager.FIRST_SESSION_TUTORIAL);
               this.m_firstStartSessionMC.visible = true;
            }
         }
      }
      
      public function closeFirstSessionStartMC(e:Event) : void
      {
         if(this.manager.getUserState() == this.manager.NOT_INITIALIZED)
         {
            if(this.m_firstStartSessionMC)
            {
               this.m_firstStartSessionMC.visible = false;
            }
         }
      }
      
      public function onMouseOver(title:String = "", text:String = "") : Function
      {
         return function(evt:MouseEvent):void
         {
            manager.showNPCCallouts(title,text);
         };
      }
      
      public function onMouseOut() : Function
      {
         return function(evt:MouseEvent):void
         {
            manager.hideNPCCallout();
         };
      }
      
      public function onMouseLevelHover(i:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            m_levelHoverArray_mc[i].visible = true;
            m_finalRewardIconArray_mc[i].visible = true;
            m_finalRewardTfArray_tf[i].visible = true;
         };
      }
      
      public function onMouseLevelOut(i:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            m_levelHoverArray_mc[i].visible = false;
            m_finalRewardIconArray_mc[i].visible = false;
            m_finalRewardTfArray_tf[i].visible = false;
         };
      }
      
      public function openMiniMarket(e:Event) : void
      {
         Dec19InnovationManager.getInstance().highlightTiles();
         FarmStatsManager.count("Dec19Innovation","UnlockTile","tile_unlock","click");
         this.close();
      }
      
      public function onFeatureEnd(evt:Event) : void
      {
         this.m_featureEndMc.visible = false;
      }
      
      private function onFeatureExpire(evt:Event) : void
      {
         this.close();
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
         FarmStatsManager.count("Dec19Innovation","Main_UI","close_window");
         super.close();
      }
      
      public function showAutoHideNPCCallouts(title:String, text:String) : void
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
      
      public function updateLeagueOverlay() : void
      {
         if(this.m_overlay_mc)
         {
            this.m_overlay_mc.visible = false;
         }
      }
      
      private function hasSeenFeatureWelcome() : Boolean
      {
         return Global.player.getSeenFlag(this.INNOVATION_WELCOME_SEEN_FLAG);
      }
      
      public function displayLastDayOverlay() : void
      {
         if(this.m_featureEndMc)
         {
            if(this.manager.isLastDay() == true && Global.player.getSeenFlag(this.LAST_DAY_ENTERED) == false)
            {
               this.m_featureEndMc["title_tf"].text = "The competition ends soon";
               this.m_featureEndMc["body_tf"].text = "Finish tasks and earn points for the grand prize!";
               this.m_featureEndMc["body2_tf"].text = "Keep playing! Better average gives better bonus rewards!";
               this.m_featureEndMc["close_bt"].visible = false;
               new FarmAnimatedTextButton(this.m_featureEndMc["accept_bt"],"Okay",this.onFeatureEnd);
               this.m_featureEndMc.visible = true;
               Global.player.setSeenFlag(this.LAST_DAY_ENTERED);
            }
         }
      }
      
      public function showtileUnlockOverlay() : void
      {
         var count:int = this.manager.getTileUnlockCount();
         if(count > 0)
         {
            this.m_tileUnlockCount_tf.text = (count * 50).toString();
            this.m_overlay_tf.text = "Unlocker of Tiles!";
            this.m_tileUnlockDes_tf.text = "You have gotten " + (count * this.TILE_UNLOCK_CONSUMABLE_COUNT).toString() + " consumables on unlocking " + count.toString() + " tiles. Enjoy!";
            this.m_tileUnlock_mc.visible = true;
            this.m_tileUnlock_mc.gotoAndStop(1);
         }
      }
   }
}

