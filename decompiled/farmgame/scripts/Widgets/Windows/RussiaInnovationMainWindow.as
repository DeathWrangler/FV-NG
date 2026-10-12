package Widgets.Windows
{
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.FarmStatsManager;
   import Managers.RussiaInnovationManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Frames.RussiaInnovationTaskFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   
   public class RussiaInnovationMainWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 7;
      
      public static const ICON_SIZE:int = 50;
      
      private static const FEATURE_NAME:String = "RussiaInnovation";
      
      public static const FIRST_EVER_REDEEM:String = "firstTimeRedeem";
      
      private var m_featureName:String = null;
      
      private const INNOVATION_WELCOME_SEEN_FLAG:String = "RussiaInnovation_Welcome_flag";
      
      private const LEADERBOARD_PLAYING_FLAG:String = "Leaderboard_Playing_flag";
      
      private const FIRST_TILE_UNLOCK:String = "First_Tile_Unlock";
      
      private const NORMAL_FEATURE_END:String = "Normal_Feature_End";
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const TASKS_MC:String = "tasks_mc";
      
      private const FEATURE_TIMER_TF:String = "timer_tf";
      
      private const DAILY_TIMER_MC:String = "daily_clock_mc";
      
      private const FINISH_TF:String = "finish_tf";
      
      private const FINISH_BODY_TF:String = "finish_subtext_tf";
      
      private const FINISH_MC:String = "finish_mc";
      
      private const DUMPFTUE_MC:String = "dumpFTUE_mc";
      
      private const POINTS_TF:String = "points_tf";
      
      private const POINTS_ICON_MC:String = "points_icon_mc";
      
      private const TEXT_FINISH_TITLE:String = "_finish_title";
      
      private const TEXT_FINISH_BODY:String = "_finish_description";
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private var m_taskFrame:RussiaInnovationTaskFrame;
      
      private var m_descriptionTf:ZwTextField;
      
      private var m_finishTitle:ZwTextField;
      
      private var m_finishBody:ZwTextField;
      
      private var m_avg_points_info:ZwTextField;
      
      private var m_finishMc:MovieClip;
      
      private var m_tileUnlock_mc:MovieClip;
      
      private var m_unlock_tf:ZwTextField;
      
      private var m_tileUnlockDes_tf:ZwTextField;
      
      private var m_tileUnlockCount_tf:ZwTextField;
      
      private var m_overlay_tf:ZwTextField;
      
      private var m_overlayUnlock_bt:FarmAnimatedTextButton;
      
      protected var m_DumpTutorial:ZwFrame = null;
      
      private var m_DumptutorialScene:int = 0;
      
      private var m_BarInd:int = 0;
      
      private const PROGRESS_BAR_FULL_WIDTH:int = 270;
      
      private var m_consumable_mc:MovieClip;
      
      private const CONSUMABLE_MC:String = "consumable_mc";
      
      private const ASK_BT:String = "ask_bt";
      
      private const CRAFT_BT:String = "craft_bt";
      
      private const COUNT_TF:String = "count_tf";
      
      private var m_consumableCount_tf:ZwTextField;
      
      private var m_progress_record_array:Array = [];
      
      private const PROGRESS_RECORDS_COUNTER:String = "feature_progress_small_mc";
      
      private const PROGRESS_RECORDS_COUNTER_GA:String = "feature_progress_small_GA_mc";
      
      private const DAILY_PROGRESS_MC:String = "meter_mc";
      
      private var m_progress_record_mc:MovieClip;
      
      private var m_daily_progress_mc:MovieClip;
      
      private var m_barMc:MovieClip;
      
      private var m_dailyTimer_tf:ZwTextField;
      
      private var m_dailyTimerMc:MovieClip;
      
      private var m_leaderboard_mc:MovieClip;
      
      private var m_leaderboardIconMc:MovieClip;
      
      private const SINK_BT:String = "sink_bt";
      
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
      
      private var m_progressLevelArray_mc:Array;
      
      private var m_levelHoverArray_mc:Array = [];
      
      private var m_finalRewardIconArray_mc:Array = [];
      
      private var m_finalRewardTfArray_tf:Array = [];
      
      private var m_progressLevelArray_tf:Array;
      
      private const ProgressLevelTextArray:Array = ["Strong","Stronger","Strongest"];
      
      private const EARNED_POINTS_MC:String = "earned_points_mc";
      
      private const DAILY_PROGRESS_BAR_FULL_WIDTH:int = 70;
      
      private var m_lock1HoverText:ZwTextField;
      
      private var m_lock2HoverText:ZwTextField;
      
      private const REWARD_EA_WEEK:String = "reward_EA_mc";
      
      private var m_EA_week_mc:MovieClip;
      
      public var m_unlockanim1_mc:MovieClip;
      
      public var m_unlockanim2_mc:MovieClip;
      
      private const LEADERBOARD_BT:String = "leaderboard_bt";
      
      private const LEADERBOARD_MC:String = "leaderboard_mc";
      
      private var m_leaderboardButton:FarmAnimatedTextButton;
      
      private var m_playing_leaderboard:Boolean = false;
      
      private var m_earnedPt_mc:MovieClip;
      
      private var m_idleNPC:MovieClip;
      
      private var m_jumpNPC:MovieClip;
      
      private var m_stompNPC:MovieClip;
      
      private var m_ask_bt:FarmAnimatedTextButton;
      
      private var m_levels_mc:MovieClip;
      
      private var m_dailyReward_mc:MovieClip;
      
      private var m_talkMc:MovieClip;
      
      private var m_npc1Tf:ZwTextField;
      
      private var m_npc2Tf:ZwTextField;
      
      private var m_talkAutoMc:MovieClip;
      
      private var m_autoTalkMc:MovieClip;
      
      private var m_autoNpc1Tf:ZwTextField;
      
      private var m_autoNpc2Tf:ZwTextField;
      
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
      
      private const PREVIEW_MC_KEY_ARRAY:Array = ["preview1_mc","preview2_mc","preview3_mc"];
      
      private const MILESTONE_MC_KEY_ARRAY:Array = ["milestone1_mc","milestone2_mc","milestone3_mc"];
      
      private const FINAL_REWARD_CODE_ARRAY:Array = ["ar6x","kxpq","xv99"];
      
      private const REWARD_MC_KEY_ARRAY:Array = ["reward1_mc","reward2_mc","reward3_mc"];
      
      private const DATE_ARRAY:Array = ["07/09/2018","07/02/2018","06/25/2018","06/18/2018","06/11/2018"];
      
      private var m_showTutorialWithEAPage:Boolean = false;
      
      private var m_iconPreview:ObjectPreviewFrame;
      
      private var m_isIconPreviewAdded:Boolean;
      
      private var m_best_icon_mc:FarmIcon;
      
      private var m_sinkBtTooltip:FarmTextTooltip;
      
      private var m_timerWidget:ZwFrame;
      
      private var m_timerToolTip:FarmTextTooltip;
      
      private var m_progressLevelArrarZFrame:Array;
      
      private const DAILY_DUMMY_MAX_POINT:Number = 30;
      
      private var m_barrel_mc:ZwFrame;
      
      private var m_crushHelp_mc:MovieClip;
      
      private var m_firstStartSessionMC:MovieClip;
      
      private var m_tileUnlock_bt:FarmAnimatedTextButton;
      
      private var m_wineMc:MovieClip;
      
      private var m_mainBG_mc:MovieClip;
      
      private var m_checkMark_mc:MovieClip;
      
      private var m_dayChangeHasOccuredDuringOpenWindow:Boolean = false;
      
      private var m_featureEndMc:MovieClip;
      
      private var RANGE_ARRAY:Array = ["5-14","15-29","30 & above"];
      
      private var m_avgTooltip:Array = new Array();
      
      private const SERVICE_NAME:String = "RussiaInnovationService";
      
      private var m_consumablehitWidget:ZwFrame;
      
      private var m_leaderboardhitWidget:ZwFrame;
      
      private var m_dailyRewardhitWidget:ZwFrame;
      
      private var m_progressWidget:ZwFrame;
      
      private var m_taskFramehitWidget:ZwFrame;
      
      private var m_leaderboardRank_tf:ZwTextField;
      
      private var m_leaderboardPoints_tf:ZwTextField;
      
      private var m_leaderboardTimer_tf:ZwTextField;
      
      public function RussiaInnovationMainWindow(featureName:String = "RussiaInnovation", assetUrl:String = null, showEAPageTutorial:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_showTutorialWithEAPage = showEAPageTutorial;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_RUSSIA))
         {
            this.m_BarInd = 42;
         }
         else
         {
            this.m_BarInd = 35;
         }
         super(FEATURE_NAME,assetUrl,numOfTutorialPages);
      }
      
      override protected function postLoadComplete() : void
      {
         var i:int = 0;
         var index:int = 0;
         var finalRewardItem:FarmItem = null;
         super.postLoadComplete();
         if(this.manager.hasActiveDayExpired())
         {
            if(Global.player.getSeenFlag(this.LEADERBOARD_PLAYING_FLAG))
            {
               Global.player.resetSeenFlag(this.LEADERBOARD_PLAYING_FLAG);
            }
         }
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Hammer Whammer!"));
         }
         if(m_window.hasOwnProperty("subtitle_tf"))
         {
            addWidget(new ZwTextField(m_window["subtitle_tf"],""));
            if(!Global.player.getSeenFlag(this.LEADERBOARD_PLAYING_FLAG))
            {
               m_window["subtitle_tf"].text = "Finish tasks to fill the Wham Meter & win super rewards! Keep eyes on the clock!";
            }
            else
            {
               m_window["subtitle_tf"].text = "Finish tasks to climb up on the Leaderboard!";
            }
            m_window["subtitle_tf"].visible = true;
         }
         if(m_window.hasOwnProperty(this.FINISH_TF))
         {
            addWidget(this.m_finishTitle = new ZwTextField(m_window[this.FINISH_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_FINISH_TITLE)));
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
         if(m_window.hasOwnProperty(this.EARNED_POINTS_MC))
         {
            this.m_earnedPt_mc = m_window[this.EARNED_POINTS_MC] as MovieClip;
            this.m_earnedPt_mc.visible = true;
         }
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_RUSSIA) && !this.hasSeenFeatureWelcome())
         {
            Global.player.setSeenFlag(this.INNOVATION_WELCOME_SEEN_FLAG);
            this.showAutoHideNPCCallouts("Wham the Hammer!","Welcome! As an Early Access benefit, you will have a full Strong Meter in the EA week, and also get 40 Karnaval Tickets!");
         }
         else if(!this.hasSeenFeatureWelcome())
         {
            Global.player.setSeenFlag(this.INNOVATION_WELCOME_SEEN_FLAG);
            this.showAutoHideNPCCallouts("Wham the Hammer!","Welcome to the Karnaval! Want to test your strength? Pick up your hammer and let’s get started!");
         }
         if(m_window.hasOwnProperty(this.CONSUMABLE_MC))
         {
            this.m_consumable_mc = m_window[this.CONSUMABLE_MC] as MovieClip;
            this.m_consumable_mc.visible = true;
            if(this.m_consumable_mc.hasOwnProperty(this.COUNT_TF))
            {
               addWidget(this.m_consumableCount_tf = new ZwTextField(this.m_consumable_mc[this.COUNT_TF],this.manager.consumableCount.toString()));
               this.m_consumableCount_tf.visible = true;
            }
            if(this.m_consumable_mc.hasOwnProperty(this.ASK_BT))
            {
               addWidget(this.m_ask_bt = new FarmAnimatedTextButton(this.m_consumable_mc[this.ASK_BT],"Ask",this.onAskButtonClick));
            }
            if(this.m_consumable_mc.hasOwnProperty(this.CRAFT_BT))
            {
               addWidget(new FarmAnimatedTextButton(this.m_consumable_mc[this.CRAFT_BT],"Craft",this.onCraftButtonClick));
            }
            if(this.m_consumable_mc.hasOwnProperty(this.BUY_BT))
            {
               addWidget(new FarmAnimatedTextButton(this.m_consumable_mc[this.BUY_BT],"Buy",this.buyCallback));
            }
            if(this.m_consumable_mc.hasOwnProperty("barrel_mc"))
            {
               this.m_barrel_mc = new ZwFrame(this.m_consumable_mc["barrel_mc"]);
            }
            if(this.m_consumable_mc.hasOwnProperty("hit_area_mc"))
            {
               this.m_consumablehitWidget = new ZwFrame(this.m_consumable_mc["hit_area_mc"]);
               this.m_consumablehitWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("Karnaval Tickets","Collect Karnaval Tickets to move ahead in your strength training"));
               this.m_consumablehitWidget.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
            }
         }
         if(m_window.hasOwnProperty("lastDay_mc"))
         {
            this.m_featureEndMc = m_window["lastDay_mc"] as MovieClip;
            this.m_featureEndMc["title_tf"].text = "Festival Time Over!";
            this.m_featureEndMc["body_tf"].text = "The Hammer Whammer season has now come to an end. You can continue playing for the Leaderboard";
            this.m_featureEndMc["body2_tf"].text = "You can refresh your browser to get your reward!";
            this.m_featureEndMc["close_bt"].visible = false;
            new FarmAnimatedTextButton(this.m_featureEndMc["accept_bt"],"Okay",this.onFeatureEnd);
            this.m_featureEndMc.visible = this.manager.hasFeatureExpired();
         }
         var leaderBoardData:Object = this.manager.getCurrentLeaderboard();
         var weekCount:int = int(leaderBoardData.count);
         if(m_window.hasOwnProperty(this.LEADERBOARD_MC))
         {
            this.m_leaderboard_mc = m_window[this.LEADERBOARD_MC] as MovieClip;
            this.m_leaderboard_mc.visible = true;
            addWidget(this.m_leaderboardButton = new FarmAnimatedTextButton(this.m_leaderboard_mc[this.LEADERBOARD_BT],"VIEW",this.onClickLeaderboardButton));
            this.m_leaderboardButton.enabled = true;
            if(this.m_leaderboard_mc.hasOwnProperty("hit_area_mc"))
            {
               this.m_leaderboardhitWidget = new ZwFrame(this.m_leaderboard_mc["hit_area_mc"] as MovieClip);
            }
            if(this.m_leaderboard_mc.hasOwnProperty("icon_mc"))
            {
               this.m_leaderboardIconMc = this.m_leaderboard_mc.icon_mc;
               this.m_leaderboardIconMc.gotoAndStop(weekCount);
            }
            addWidget(this.m_leaderboardPoints_tf = new ZwTextField(m_window[this.LEADERBOARD_MC]["points_tf"]));
            addWidget(this.m_leaderboardRank_tf = new ZwTextField(m_window[this.LEADERBOARD_MC]["rank_tf"]));
            this.m_leaderboardTimer_tf = new ZwTextField(m_window[this.LEADERBOARD_MC]["timer_tf"],HUD.getformattedTimeLeft(this.manager.getTimeLeftInWeek()) + " Left");
            this.m_leaderboardhitWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("Compete in Leaderboard","You can see your Leaderboard rank by clicking on the View button"));
            this.m_leaderboardhitWidget.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
            this.m_leaderboardRank_tf.visible = false;
         }
         if(m_window.hasOwnProperty("firstSessionStart_mc"))
         {
            this.m_firstStartSessionMC = m_window["firstSessionStart_mc"] as MovieClip;
            this.m_firstStartSessionMC.visible = false;
         }
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_RUSSIA))
         {
            if(m_window.hasOwnProperty(this.PROGRESS_RECORDS_COUNTER))
            {
               this.m_progress_record_mc = m_window[this.PROGRESS_RECORDS_COUNTER] as MovieClip;
               this.m_progress_record_mc.visible = true;
               for(index = 0; index < 42; index++)
               {
                  this.m_progress_record_array[index] = this.m_progress_record_mc["day_" + index.toString() + "_mc"];
                  if(index >= this.manager.activeDayIndex)
                  {
                     this.m_progress_record_array[index].corck_mc.visible = false;
                  }
                  if(this.m_progress_record_array[index].hasOwnProperty("session_mc"))
                  {
                     if(this.manager.activeDayIndex == index)
                     {
                        this.m_session_mc = this.m_progress_record_array[index]["session_mc"] as MovieClip;
                        this.m_session_mc.visible = true;
                     }
                     else
                     {
                        (this.m_progress_record_array[index]["session_mc"] as MovieClip).visible = false;
                     }
                  }
                  if(this.m_progress_record_array[index].hasOwnProperty("daymarker_mc"))
                  {
                     this.m_progress_record_array[index].daymarker_mc.visible = true;
                  }
               }
               if(this.m_progress_record_mc.hasOwnProperty("hit_area_mc"))
               {
                  this.m_progressWidget = new ZwFrame(this.m_progress_record_mc["hit_area_mc"]);
                  this.m_progressWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("Progress Meters","These meters show your daily progress. The average from these will determine your Bonus Reward!"));
                  this.m_progressWidget.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
               }
            }
         }
         else if(m_window.hasOwnProperty(this.PROGRESS_RECORDS_COUNTER_GA))
         {
            this.m_progress_record_mc = m_window[this.PROGRESS_RECORDS_COUNTER_GA] as MovieClip;
            this.m_progress_record_mc.visible = true;
            for(index = 0; index < 35; index++)
            {
               this.m_progress_record_array[index] = this.m_progress_record_mc["day_" + index.toString() + "_mc"];
               if(index >= this.manager.activeDayIndex - 7)
               {
                  this.m_progress_record_array[index].corck_mc.visible = false;
               }
               if(this.m_progress_record_array[index].hasOwnProperty("session_mc"))
               {
                  if(this.manager.activeDayIndex - 7 == index)
                  {
                     this.m_session_mc = this.m_progress_record_array[index]["session_mc"] as MovieClip;
                     this.m_session_mc.visible = true;
                  }
                  else
                  {
                     (this.m_progress_record_array[index]["session_mc"] as MovieClip).visible = false;
                  }
               }
               if(this.m_progress_record_array[index].hasOwnProperty("daymarker_mc"))
               {
                  this.m_progress_record_array[index].daymarker_mc.visible = true;
               }
            }
            if(this.m_progress_record_mc.hasOwnProperty("hit_area_mc"))
            {
               this.m_progressWidget = new ZwFrame(this.m_progress_record_mc["hit_area_mc"]);
               this.m_progressWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("Progress Meters","These meters are a track of your daily progress. Average of these points will determine your Bonus Reward!"));
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
               this.m_avg_points_info = new ZwTextField(this.m_levels_mc["avg_points_tf"],"Your current average : " + this.manager.currentAverage.toString());
               this.m_avg_points_info.visible = true;
            }
         }
         if(m_window.hasOwnProperty(this.DAILY_PROGRESS_MC))
         {
            this.m_daily_progress_mc = m_window[this.DAILY_PROGRESS_MC] as MovieClip;
            this.m_daily_progress_mc.visible = true;
            this.m_barMc = this.m_daily_progress_mc["bar_fill_mc"] as MovieClip;
            this.m_barMc.visible = true;
         }
         if(m_window.hasOwnProperty(this.FINISH_BODY_TF))
         {
            addWidget(this.m_finishBody = new ZwTextField(m_window[this.FINISH_BODY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_FINISH_BODY)));
         }
         if(m_window.hasOwnProperty("feature_progress_full_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["feature_progress_full_bt"],"Bonus Rewards",this.onProgressButtonClick));
         }
         if(m_window.hasOwnProperty("message_big_mc"))
         {
            this.m_message_mc = m_window["message_big_mc"] as MovieClip;
            this.m_message_mc.visible = false;
            this.m_messageTicket_mc = this.m_message_mc["ticket_mc"] as MovieClip;
            this.m_messageTicket_mc.visible = false;
            this.m_messageTitle = new ZwTextField(this.m_message_mc[this.TITLE_TF],"");
            this.m_messageCash = new ZwTextField(this.m_message_mc["cast_tf"],"");
            this.m_messageInfo1 = new ZwTextField(this.m_message_mc["info1_tf"],"");
            this.m_messageInfo2 = new ZwTextField(this.m_message_mc["info2_tf"],"");
            this.m_messageOkay = new FarmAnimatedCashButton(this.m_message_mc["okay_bt"],"",this.manager.consumableNeededForUnlock().toString(),null);
            this.m_sinkBtTooltip = new FarmTextTooltip(this.manager.getSinkButtonToolTipMessage());
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
            addWidget(this.m_overlayUnlock_bt = new FarmAnimatedTextButton(this.m_tileUnlock_mc["overlay_bt"],"Okay",this.onCloseOverlay));
            this.m_overlay_tf = new ZwTextField(this.m_tileUnlock_mc["overlay_tf"],"");
         }
         if(m_window.hasOwnProperty(this.FEATURE_TIMER_MC))
         {
            this.m_featureTimer_mc = m_window[this.FEATURE_TIMER_MC] as MovieClip;
            this.m_featureTimer_mc.visible = true;
            if(this.m_featureTimer_mc.hasOwnProperty(this.FEATURE_TIMER_TF))
            {
               this.m_FeatureTimer = new ZwTextField(this.m_featureTimer_mc[this.FEATURE_TIMER_TF],"");
               if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_RUSSIA) == true)
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
            this.m_taskFrame = new RussiaInnovationTaskFrame(m_window[this.TASKS_MC],this,this.m_featureName);
            this.m_taskFrame.visible = true;
            if(!Global.player.getSeenFlag(FIRST_EVER_REDEEM))
            {
               if(this.m_taskFrame.hasOwnProperty("hit_area_mc"))
               {
                  this.m_taskFramehitWidget = new ZwFrame(this.m_taskFrame["hit_area_mc"]);
                  this.m_taskFramehitWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("Redeem Points","Redeem this task to add points into your Wham Meter"));
                  this.m_taskFramehitWidget.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
               }
            }
         }
         for(var previewIndex:int = 0; previewIndex < 3; previewIndex++)
         {
            if(m_window.hasOwnProperty(this.PREVIEW_MC_KEY_ARRAY[previewIndex]))
            {
               addWidget(this.m_preview_mcArray[previewIndex] = new ZwFrame(m_window[this.PREVIEW_MC_KEY_ARRAY[previewIndex]]),true);
               this.m_preview_mcArray[previewIndex].registerEventListener(MouseEvent.MOUSE_OVER,this.onOver(previewIndex));
               this.m_preview_mcArray[previewIndex].registerEventListener(MouseEvent.MOUSE_OUT,this.onOut(previewIndex));
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
            this.m_rewardIconMcArray[mileStoneRewardIndex].setIconSize(70,70);
            this.m_rewardIconMcArray[mileStoneRewardIndex].setSmoothing(true);
         }
         if(m_window.hasOwnProperty("level_lock1_hover"))
         {
            this.m_lock1Hover = m_window["level_lock1_hover"] as MovieClip;
            this.m_lock1Hover.visible = false;
            this.m_lock1HoverText = new ZwTextField(this.m_lock1Hover["info1_tf"],"To Unlock Stronger Level Exchange 5");
         }
         if(m_window.hasOwnProperty("level_lock2_hover"))
         {
            this.m_lock2Hover = m_window["level_lock2_hover"] as MovieClip;
            this.m_lock2Hover.visible = false;
            this.m_lock2HoverText = new ZwTextField(this.m_lock2Hover["info1_tf"],"To Unlock Strongest Level Exchange 10");
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
         if(m_window.hasOwnProperty("idle_ani_mc"))
         {
            this.m_idleNPC = m_window["idle_ani_mc"] as MovieClip;
         }
         if(m_window.hasOwnProperty("jump_ani_mc"))
         {
            this.m_jumpNPC = m_window["jump_ani_mc"] as MovieClip;
         }
         if(m_window.hasOwnProperty("stomp_ani_mc"))
         {
            this.m_stompNPC = m_window["stomp_ani_mc"] as MovieClip;
         }
         if(!Global.player.getSeenFlag(this.LEADERBOARD_PLAYING_FLAG))
         {
            this.m_idleNPC.visible = true;
            this.m_jumpNPC.visible = false;
            this.playIdleNPCAnimation();
         }
         else
         {
            this.m_idleNPC.visible = false;
            this.m_jumpNPC.visible = true;
            this.playJumpAnimation();
         }
         addWidget(this.m_tileUnlock_bt = new FarmAnimatedTextButton(m_window["consumable_mc"]["unlock_bt"],"View Tiles",this.openMiniMarket));
         if(this.manager.lockedTilesArray.length > 0)
         {
            this.m_unlock_tf = new ZwTextField(m_window["consumable_mc"]["unlock_tf"],"Unlock tiles to get 50 Karnaval Tickets!");
            this.m_unlock_tf.visible = true;
         }
         else
         {
            this.m_tileUnlock_bt.enabled = false;
            this.m_tileUnlock_bt.callback = null;
            this.m_tileUnlock_bt.applyGrayOut = true;
            FarmGameUtil.disableButtonAndShowTooltip(this.m_tileUnlock_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_MainWindow_UnlockTileText2"));
         }
         if(Global.player.getSeenFlag(this.manager.TILE_UNLOCK))
         {
            if(!Global.player.getSeenFlag(this.manager.FIRST_TIME_UNLOCK))
            {
               Global.player.setSeenFlag(this.manager.FIRST_TIME_UNLOCK);
               this.forcedNPCCallouts();
            }
         }
         if(this.m_ask_bt)
         {
            this.refreshAskButton();
         }
         this.updateWeeklyRewardGrantDateArray();
         var userData:Object = this.manager.getUserDataFromLeaderboard();
         var rewardPoints:int = this.manager.getWeeklyRewardPoints();
         this.updateDayBonus();
         this.refreshTaskFrame();
         this.updateProgressBar(true);
         this.startTimer();
         this.updateSmallProgressBars();
         this.manager.initializeLeaderBoardProgress(true);
         if(userData)
         {
            this.updateLeaderBoardFrame(rewardPoints,userData["rank"]);
         }
         if(this.m_showTutorialWithEAPage)
         {
            this.showTutorialWithEAPage();
         }
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
      
      public function updateLeaderBoardFrame(points:int, rank:int = 0) : void
      {
         var userData:Object = null;
         if(Boolean(this.m_leaderboardRank_tf) && Boolean(this.m_leaderboardPoints_tf))
         {
            if(points.toString() == "0")
            {
               this.m_leaderboardRank_tf.visible = false;
               this.m_leaderboardPoints_tf.visible = false;
            }
            else
            {
               if(rank == 0)
               {
                  userData = this.manager.getUserDataFromLeaderboard();
                  if(userData)
                  {
                     rank = int(userData.rank);
                  }
               }
               this.m_leaderboardPoints_tf.text = "Points:" + points.toString();
               this.m_leaderboardRank_tf.text = "Rank:" + rank.toString();
               this.m_leaderboardRank_tf.visible = false;
               this.m_leaderboardPoints_tf.visible = true;
            }
         }
      }
      
      public function CloseCrushMC(e:Event = null) : void
      {
      }
      
      public function onClickLeaderboardButton(evt:Event) : void
      {
         this.manager.showLeaderboardUI();
      }
      
      public function onCloseOverlay(evt:Event) : void
      {
         this.m_tileUnlock_mc.visible = false;
      }
      
      public function onFeatureEnd(evt:Event) : void
      {
         this.m_featureEndMc.visible = false;
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
      
      public function listenForAnimationEnd(e:Event = null) : void
      {
         if(this.m_jumpNPC.currentFrame == 66)
         {
            this.m_jumpNPC.stop();
            this.m_jumpNPC.visible = false;
            this.playStompingAnimation();
         }
      }
      
      public function playIdleNPCAnimation() : void
      {
         var child:MovieClip = null;
         var grandChildIndex:int = 0;
         var grandChild:MovieClip = null;
         this.m_idleNPC.visible = true;
         for(var childIndex:int = 1; childIndex < this.m_idleNPC.numChildren; childIndex++)
         {
            child = this.m_idleNPC.getChildAt(childIndex) as MovieClip;
            if(child)
            {
               child.play();
               for(grandChildIndex = 1; grandChildIndex < child.numChildren; grandChildIndex++)
               {
                  grandChild = child.getChildAt(grandChildIndex) as MovieClip;
                  if(grandChild)
                  {
                     grandChild.play();
                  }
               }
            }
         }
         this.m_idleNPC.play();
      }
      
      public function playJumpAnimation() : void
      {
         var child:MovieClip = null;
         var grandChildIndex:int = 0;
         var grandChild:MovieClip = null;
         this.m_stompNPC.visible = false;
         this.m_idleNPC.visible = false;
         this.m_jumpNPC.visible = true;
         for(var childIndex:int = 1; childIndex < this.m_jumpNPC.numChildren; childIndex++)
         {
            child = this.m_jumpNPC.getChildAt(childIndex) as MovieClip;
            if(child)
            {
               child.play();
               for(grandChildIndex = 1; grandChildIndex < child.numChildren; grandChildIndex++)
               {
                  grandChild = child.getChildAt(grandChildIndex) as MovieClip;
                  if(grandChild)
                  {
                     grandChild.play();
                  }
               }
            }
         }
         this.m_jumpNPC.play();
         this.m_jumpNPC.addEventListener(Event.ENTER_FRAME,this.listenForAnimationEnd,false,0,true);
      }
      
      public function playStompingAnimation() : void
      {
         var child:MovieClip = null;
         var grandChildIndex:int = 0;
         var grandChild:MovieClip = null;
         this.m_idleNPC.visible = false;
         this.m_jumpNPC.visible = false;
         this.m_stompNPC.visible = true;
         for(var childIndex:int = 1; childIndex < this.m_stompNPC.numChildren; childIndex++)
         {
            child = this.m_stompNPC.getChildAt(childIndex) as MovieClip;
            if(child)
            {
               child.play();
               for(grandChildIndex = 1; grandChildIndex < child.numChildren; grandChildIndex++)
               {
                  grandChild = child.getChildAt(grandChildIndex) as MovieClip;
                  if(grandChild)
                  {
                     grandChild.play();
                  }
               }
            }
         }
         this.m_stompNPC.play();
      }
      
      public function updateSmallProgressBars() : void
      {
         var normalizedPoints:Number = NaN;
         var dayPoints:int = 0;
         var barLength:Number = 0;
         var dayInd:int = this.manager.activeDayIndex;
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_RUSSIA) == false)
         {
            dayInd -= 7;
         }
         for(var index:int = 0; index < this.m_BarInd; index++)
         {
            if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_RUSSIA) == false)
            {
               dayPoints = this.manager.getpointsForTheDay(index + 7);
            }
            else
            {
               dayPoints = this.manager.getpointsForTheDay(index);
            }
            if(dayPoints > this.manager.VAL_THIRD_MILESTONE)
            {
               dayPoints = this.manager.VAL_THIRD_MILESTONE;
            }
            normalizedPoints = dayPoints;
            if(dayPoints > 20)
            {
               normalizedPoints = 20 + (dayPoints - 20) * 10 / 15;
            }
            barLength = normalizedPoints * this.DAILY_PROGRESS_BAR_FULL_WIDTH / this.DAILY_DUMMY_MAX_POINT;
            if(this.m_progress_record_array[index].bar_fill_mc)
            {
               if(dayPoints == 0)
               {
                  this.m_progress_record_array[index].bar_fill_mc.height = barLength;
                  this.m_progress_record_array[index].daymarker_mc.y = 70 - barLength;
               }
               else
               {
                  TweenMax.to(this.m_progress_record_array[index].bar_fill_mc,2,{"height":barLength});
                  TweenMax.to(this.m_progress_record_array[index].daymarker_mc,2,{"y":70 - barLength});
               }
            }
            this.m_progress_record_array[index] = this.m_progress_record_mc["day_" + index.toString() + "_mc"];
            if(Boolean(this.m_progress_record_array[index]) && index >= dayInd)
            {
               this.m_progress_record_array[index].corck_mc.visible = false;
            }
            else
            {
               this.m_progress_record_array[index].corck_mc.visible = true;
            }
         }
      }
      
      public function updateCurrentdaySmallProgressBars() : void
      {
         var index:int = this.manager.activeDayIndex;
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_RUSSIA) == false && Global.player.getSeenFlag(this.manager.GA_FEATURE_START) == true)
         {
            index -= 7;
         }
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
         var barLength:Number = normalizedPoints * this.DAILY_PROGRESS_BAR_FULL_WIDTH / this.DAILY_DUMMY_MAX_POINT;
         if(this.m_progress_record_array[index].bar_fill_mc)
         {
            if(dayPoints == 0)
            {
               this.m_progress_record_array[index].bar_fill_mc.height = barLength;
               this.m_progress_record_array[index].daymarker_mc.y = 70 - barLength;
            }
            else
            {
               TweenMax.to(this.m_progress_record_array[index].bar_fill_mc,2,{"height":barLength});
               TweenMax.to(this.m_progress_record_array[index].daymarker_mc,2,{"y":70 - barLength});
            }
         }
         this.m_avg_points_info.text = "Your current average : " + this.manager.currentAverage.toString();
         this.m_avg_points_info.visible = true;
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
      
      override protected function preSwitchChanges(sceneNumber:int) : void
      {
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_RUSSIA) == true)
         {
            if(sceneNumber == 6)
            {
               tutorialSceneNumber = sceneNumber + 1;
            }
         }
         else if(sceneNumber == 5)
         {
            tutorialSceneNumber = sceneNumber + 1;
         }
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
               this.manager.showLeaderboardRewardPopup();
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
            xPostTimeRemaining = this.manager.getThrottleTimeRemaining(RussiaInnovationManager.FEED_NAME);
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
      
      private function onCraftButtonClick(e:Event) : void
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
         tutorialButtonText = "Next";
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
         var normalizedPoints:Number = dayPoints;
         if(dayPoints > 20)
         {
            normalizedPoints = 20 + (dayPoints - 20) * 10 / 15;
         }
         var barLength:Number = normalizedPoints * this.PROGRESS_BAR_FULL_WIDTH / this.DAILY_DUMMY_MAX_POINT;
         if(this.m_barMc)
         {
            if(dayPoints < 0)
            {
               this.m_barMc.height = barLength;
               this.m_earnedPt_mc.y = 405 - barLength;
            }
            else if(onOpenWindow == false)
            {
               TweenMax.to(this.m_barMc,2,{"height":barLength});
               TweenMax.to(this.m_earnedPt_mc,2,{"y":405 - barLength});
            }
            else
            {
               this.m_barMc.height = barLength;
               this.m_earnedPt_mc.y = 405 - barLength;
            }
         }
         this.updateCurrentdaySmallProgressBars();
      }
      
      public function refreshTaskFrame(e:Event = null) : void
      {
         var firstTimeFeatureAccess:Boolean = false;
         var redeemPreviousDayTask:Boolean = false;
         if(this.manager.getUserState() == this.manager.NOT_INITIALIZED)
         {
            this.displayFeatureStartMessage();
            firstTimeFeatureAccess = true;
         }
         else if(this.manager.hasActiveDayExpired())
         {
            if(this.manager.rdeemableTaskCount() > 0 && this.manager.getUserState() != this.manager.DONE_FOR_THE_DAY)
            {
               if(this.manager.redeemHasStarted == false)
               {
                  redeemPreviousDayTask = true;
                  this.displayWelcomeBackMessage();
               }
            }
            else
            {
               this.displayDayStartMessage();
               firstTimeFeatureAccess = true;
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
            if(!this.manager.getDayEndMessageShown())
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
            else if(!redeemPreviousDayTask)
            {
               this.m_messageOkay.callback = null;
               this.m_messageOkay.enabled = false;
               this.m_messageOkay.element.mouseEnabled = this.m_messageOkay.element.mouseChildren = true;
            }
         }
         this.m_taskFrame.refresh();
         this.m_consumableCount_tf.text = this.manager.consumableCount.toString();
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
         FarmStatsManager.count("RockPaperShivers","Main_UI","buy_treats");
         tintWindow();
         enableInput = false;
         this.manager.openBuyWindow(this);
      }
      
      public function displayLock1Message() : void
      {
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageOkay.visible = true;
         this.m_messageCash.visible = true;
         this.m_messageTicket_mc.visible = true;
         this.m_messageOkay.text = "Exchange";
         this.m_messageOkay.callback = this.onSinkButtonClick;
         this.m_messageTitle.text = "Congratulations";
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.visible = false;
         }
         var rewardItem:FarmItem = this.manager.getActiveDayReward(this.manager.EASY);
         this.loadMessageIcon(rewardItem);
         this.m_messageInfo1.text = "You have flexed that muscle to have become Strong and won this " + rewardItem.friendlyTitle + ". Find it in your gift box!";
         this.m_messageInfo2.text = "Exchange 5 Karnaval Tickets to start training to become Stronger";
         this.m_messageCash.text = "x5";
      }
      
      public function displayLock2Message() : void
      {
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageOkay.visible = true;
         this.m_messageCash.visible = true;
         this.m_messageTicket_mc.visible = true;
         this.m_messageOkay.text = "Exchange";
         this.m_messageOkay.callback = this.onSinkButtonClick;
         this.m_messageTitle.text = "Congratulations";
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.visible = false;
         }
         var rewardItem:FarmItem = this.manager.getActiveDayReward(this.manager.MEDIUM);
         this.loadMessageIcon(rewardItem);
         this.m_messageInfo1.text = "You have flexed that muscle to have become Stronger and won this " + rewardItem.friendlyTitle + ". Find it in your gift box!";
         this.m_messageInfo2.text = "Exchange 10 Karnaval Tickets to start training to become Strongest";
         this.m_messageCash.text = "x10";
      }
      
      public function displayWelcomeBackMessage() : void
      {
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageTitle.text = "More power to you";
         this.m_messageOkay.visible = true;
         this.m_messageOkay.text = "Okay";
         this.m_messageOkay.callback = this.getOldTasksRedeemedFromUser;
         this.m_messageTicket_mc.visible = false;
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.loadIcon("assets/dialogs/russia/innovation/icon_welcome.png");
            itemBox.visible = true;
         }
         this.m_messageInfo1.text = "Looks like you have some more power points to redeem.";
         this.m_messageInfo2.text = "Redeem these tasks to start a new training session!";
      }
      
      public function getOldTasksRedeemedFromUser(e:Event = null) : void
      {
         this.m_message_mc.visible = false;
         this.m_taskFrame.visible = true;
      }
      
      public function displayDayFinishedMessage() : void
      {
         if(this.manager.activeDayIndex == 41 && Global.player.getSeenFlag(this.NORMAL_FEATURE_END) == false)
         {
            this.m_featureEndMc.visible = true;
            Global.player.setSeenFlag(this.NORMAL_FEATURE_END);
         }
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
            itemBox.loadIcon("assets/dialogs/russia/innovation/icon_welcome.png");
            itemBox.visible = true;
         }
         this.m_messageInfo1.text = "You have finished your training for the day. Play for Leaderboard to get more Power packed rewards!";
         this.m_messageInfo2.text = "Leaderboard points will not be part of your average score.";
         this.m_messageOkay.callback = this.playForLeaderBoardHelper;
      }
      
      public function playForLeaderBoardHelper(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(this.LEADERBOARD_PLAYING_FLAG))
         {
            Global.player.setSeenFlag(this.LEADERBOARD_PLAYING_FLAG);
         }
         this.playJumpAnimation();
         m_window["subtitle_tf"].text = "Finish tasks to climb up on the Leaderboard!";
         this.m_talkMc.visible = false;
         this.m_message_mc.visible = false;
         this.m_taskFrame.visible = true;
         this.m_messageOkay.visible = false;
         this.m_messageOkay.enabled = false;
         this.manager.playForLeaderBoard();
      }
      
      public function displayDayStartMessage() : void
      {
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageOkay.enabled = true;
         this.m_messageOkay.visible = true;
         this.m_messageTicket_mc.visible = false;
         this.m_messageOkay.callback = this.manager.startNewDay;
         this.m_messageOkay.text = "Start Training";
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.loadIcon("assets/dialogs/russia/innovation/icon_welcome.png");
            itemBox.visible = true;
         }
         if(this.manager.getUserState() == this.manager.DONE_FOR_THE_DAY)
         {
            this.m_messageTitle.text = "New Day, New Challenge";
            this.m_messageInfo1.text = "Are you ready to start a new day of training?";
         }
         else
         {
            this.m_messageTitle.text = "New Day, New Challenge";
            this.m_messageInfo1.text = "Are you ready to start a new day of training?";
         }
         this.m_messageInfo2.text = "Train hard, Train fast and you’ll only emerge to be the Strongest!";
      }
      
      public function displayFeatureStartMessage() : void
      {
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageOkay.visible = true;
         this.m_messageTicket_mc.visible = false;
         this.m_messageOkay.callback = this.manager.startNewDay;
         this.m_messageOkay.text = "Start Training";
         this.m_messageTitle.text = "New Day, New Challenge";
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.loadIcon("assets/dialogs/russia/innovation/icon_welcome.png");
            itemBox.visible = true;
         }
         this.m_messageInfo1.text = "Are you ready to start a new day of training?";
         this.m_messageInfo2.text = "Train hard, Train fast and you’ll only emerge to be the Strongest!";
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
               itemBox.detachTooltip();
            }
            itemBox.attachTooltip(new FarmTextTooltip(farmItem.friendlyTitle));
         }
      }
      
      override public function refreshWindow() : void
      {
         this.m_checkMark_mc.visible = false;
         this.m_consumableCount_tf.text = this.manager.consumableCount.toString();
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
            this.m_dailyRewardhitWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("Daily Bonus!","Become the Strongest to grab this exclusive reward for today!"));
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
            if(finalMileStoneItem.code != this.manager.POWER_BOOSTER_CODE)
            {
               if(finalMileStoneItem)
               {
                  addWidget(this.m_iconPreview = new ObjectPreviewFrame(m_window["best_icon_50_mc"] as MovieClip,finalMileStoneItem,null,null,[100]),true);
                  this.m_iconPreview.attachTooltip(new FarmTextTooltip(finalMileStoneItem.friendlyTitle));
                  this.m_isIconPreviewAdded = true;
               }
            }
            else
            {
               this.m_best_icon_mc = new FarmIcon(m_window["best_icon_50_mc"],finalMileStoneItem.iconUrl);
               this.m_best_icon_mc.attachTooltip(new FarmTextTooltip(finalMileStoneItem.friendlyTitle));
               this.m_best_icon_mc.visible = true;
            }
         }
         for(var mileStoneRewardIndex:int = 0; mileStoneRewardIndex < 3; mileStoneRewardIndex++)
         {
            if(this.m_rewardIconMcArray[mileStoneRewardIndex])
            {
               (this.m_rewardIconMcArray[mileStoneRewardIndex] as FarmIcon).release();
               this.m_rewardIconMcArray[mileStoneRewardIndex] = new FarmIcon(this.m_reward_mcArray[mileStoneRewardIndex]["icon_70_mc"],this.manager.getActiveDayReward(mileStoneRewardIndex).iconUrl);
               this.m_rewardIconMcArray[mileStoneRewardIndex].setIconSize(70,70);
               this.m_rewardIconMcArray[mileStoneRewardIndex].setSmoothing(true);
            }
         }
      }
      
      public function updateActiveDay() : void
      {
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_RUSSIA) == true)
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
         var dayInd:int = this.manager.activeDayIndex;
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_RUSSIA) == false)
         {
            dayInd -= 7;
         }
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
      
      private function getFeatureTimeLeft() : String
      {
         return this.manager.getFeatureEndDaysLeftText();
      }
      
      private function get manager() : RussiaInnovationManager
      {
         return RussiaInnovationManager.getInstance(FEATURE_NAME);
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
      
      public function onOver(i:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            if(i == 0 && WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_RUSSIA))
            {
               if(manager.activeDayIndex < 7)
               {
                  m_EA_week_mc.visible = true;
                  return;
               }
            }
            m_reward_mcArray[i].visible = true;
            var isMileStoneAchieved:* = manager.isMilestoneAchievedForLevel(i);
            m_rewardAfterMcArray[i].visible = isMileStoneAchieved;
            m_rewardBeforeMcArray[i].visible = !isMileStoneAchieved;
            m_rewardBeforeMcPointsTfArray[i].text = (manager.VAL_MILESTONE_POINTS_ARRAY[i] - manager.getDayPoints()).toString() + " more";
            m_rewardCountTfArray[i].text = "x1";
            m_rewardTickMcArray[i].visible = isMileStoneAchieved;
         };
      }
      
      public function onOut(i:int) : Function
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
      
      public function closeFirstSessionStartMC() : void
      {
         if(this.m_firstStartSessionMC)
         {
            this.m_firstStartSessionMC.visible = false;
         }
      }
      
      private function openMiniMarket(e:Event) : void
      {
         RussiaInnovationManager.getInstance().highlightTiles();
         FarmStatsManager.count("RussiaInnovation","UnlockTile","tile_unlock","click");
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
         FarmStatsManager.count("RussiaInnovation","Main_UI","close_window");
         super.close();
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
      
      private function hasSeenFeatureWelcome() : Boolean
      {
         return Global.player.getSeenFlag(this.INNOVATION_WELCOME_SEEN_FLAG);
      }
      
      public function showAutoHideNPCCallouts(title:String, text:String) : void
      {
         this.m_autoNpc2Tf.text = text;
         this.m_autoNpc1Tf.text = title;
         this.m_talkAutoMc.visible = true;
         this.m_talkAutoMc.gotoAndPlay(1);
      }
      
      public function forcedNPCCallouts() : void
      {
         var count:int = this.manager.tileUnlockCount;
         this.m_tileUnlockCount_tf.text = (count * 50).toString();
         this.m_overlay_tf.text = "Unlocker of Tiles";
         this.m_tileUnlockDes_tf.text = "You have gotten " + (count * 50).toString() + " Karnaval Tickets on unlocking " + count.toString() + " tiles. Enjoy!";
         this.m_tileUnlock_mc.visible = true;
         this.m_tileUnlock_mc.gotoAndStop(1);
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
   }
}

