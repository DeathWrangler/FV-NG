package Widgets.Windows
{
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.Quest.FarmTask;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.FarmStatsManager;
   import Managers.OrderBoard.IrelandInnovationManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.IrelandInnovationTaskFrame;
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
   
   public class IrelandInnovationMainWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 9;
      
      public static const ICON_SIZE:int = 50;
      
      private static const FEATURE_NAME:String = "IrelandInnovation";
      
      private static const TUTORIAL_MC:String = "tutorial_mc";
      
      private var m_featureName:String = null;
      
      private const INNOVATION_WELCOME_SEEN_FLAG:String = "IrelandInnovation_Welcome_flag";
      
      private const NORMAL_FEATURE_END:String = "Ireland_Normal_Feature_End";
      
      private const LAST_DAY_ENTERED:String = "Ireland_Last_Day_entered";
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const TASKS_MC:String = "tasks_mc";
      
      private const FEATURE_TIMER_TF:String = "timer_tf";
      
      private const DAILY_TIMER_MC:String = "daily_clock_mc";
      
      private const FINISH_MC:String = "finish_mc";
      
      private const DUMPFTUE_MC:String = "dumpFTUE_mc";
      
      private const POINTS_TF:String = "points_tf";
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private const LEADERBOARD_BT:String = "leaderboard_bt";
      
      private const LEADERBOARD_MC:String = "leaderboard_mc";
      
      private var m_taskFrame:IrelandInnovationTaskFrame;
      
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
      
      private const DAILY_PROGRESS_BAR_FULL_WIDTH:int = 70;
      
      protected var m_DumpTutorial:ZwFrame = null;
      
      private var m_DumptutorialScene:int = 0;
      
      private const PROGRESS_BAR_FULL_WIDTH:int = 340;
      
      private const PROGRESS_BAR_SCORE_FULL_WIDTH:int = 430;
      
      private var m_consumable_mc:MovieClip;
      
      private const CONSUMABLE_MC:String = "consumable_mc";
      
      private const COUNT_TF:String = "count_tf";
      
      private const LOCK_TEXT_TF:String = "text_tf";
      
      private var m_consumableCount_tf:ZwTextField;
      
      private var m_lockText_tf:ZwTextField;
      
      private const DAILY_PROGRESS_MC:String = "meter_mc";
      
      private var m_daily_progress_mc:MovieClip;
      
      private var m_barMc:MovieClip;
      
      private var m_dailyTimer_tf:ZwTextField;
      
      private var m_daysLeft_tf:ZwTextField;
      
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
      
      private var m_tutorialButtons:Array = [];
      
      private var m_FeatureTimer:ZwTextField;
      
      private const FEATURE_TIMER_MC:String = "feature_timer_mc";
      
      private var m_featureTimer_mc:MovieClip;
      
      private const ProgressLevelTextArray:Array = ["EXPERT","PROFESSIONAL","CHAMPION"];
      
      private const townLevelTextArray:Array = ["Baron","Viscount","Earl","Duke","King"];
      
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
      
      private const PREVIEW_MC_KEY_ARRAY:Array = ["preview1_mc","preview2_mc","preview3_mc","preview4_mc","preview5_mc"];
      
      private const MILESTONE_MC_KEY_ARRAY:Array = ["milestone1_mc","milestone2_mc","milestone3_mc","milestone4_mc","milestone5_mc"];
      
      private const REWARD_MC_KEY_ARRAY:Array = ["reward1_mc","reward2_mc","reward3_mc","reward4_mc","reward5_mc"];
      
      private const DATE_ARRAY:Array = ["04/01/2019","03/25/2019","03/18/2019","03/11/2019"];
      
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
      
      private const MAX_POINT:Number = 25;
      
      private var m_barrel_mc:ZwFrame;
      
      private var m_firstStartSessionMC:MovieClip;
      
      private var m_tileUnlock_bt:FarmAnimatedTextButton;
      
      private var m_wineMc:MovieClip;
      
      private var m_mainBG_mc:MovieClip;
      
      private var m_checkMark_mc:MovieClip;
      
      private var m_dayChangeHasOccuredDuringOpenWindow:Boolean = false;
      
      private var m_noOfWeek:int = 5;
      
      private var m_firstSessionBt:FarmAnimatedTextButton;
      
      private var m_consumablehitWidget:ZwFrame;
      
      private var m_progress_record_mc:MovieClip;
      
      private var m_progress_record_array:Array = [];
      
      private var m_progressWidget:ZwFrame;
      
      private var m_BarInd:int = 0;
      
      private var m_levelHoverArray_mc:Array = [];
      
      private var m_idleNpc_mc:Array = [];
      
      private const FINAL_REWARD_CODE_ARRAY:Array = ["unj4","9tbo","3k54"];
      
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
      
      private var m_npc_mc:MovieClip;
      
      private var m_leaderboard_bg_mc:MovieClip;
      
      private var m_overlay_mc:MovieClip;
      
      public var m_msg_overlayMc:MovieClip;
      
      public var m_getMore_overlayMc:MovieClip;
      
      private var m_overlay1_tf:ZwTextField;
      
      private var m_overlay2_tf:ZwTextField;
      
      private var m_overlay3_tf:ZwTextField;
      
      private var m_map_mc:MovieClip;
      
      private var m_pin_mc:MovieClip;
      
      private var m_counterTf:ZwTextField;
      
      private var m_footerTf:ZwTextField;
      
      private var m_slot_mc:MovieClip;
      
      private const PIN_MC_KEY_ARRAY:Array = ["pin0_mc","pin1_mc","pin2_mc","pin3_mc","pin4_mc","pin5_mc"];
      
      private const PIN_DOOBER_MC_KEY_ARRAY:Array = ["doober0_mc","doober1_mc","doober2_mc","doober3_mc","doober4_mc","doober5_mc"];
      
      private var m_PinsMcArray:Array = [];
      
      private var m_pinGlowMcArray:Array = [];
      
      public var m_pinsDooberMcArray:Array = [];
      
      private var m_dooberIconsMc:Array = [];
      
      public var m_dooberPointsTf:Array = [];
      
      private var m_pinsMcWidgetArray:Array = [];
      
      private var m_lockMc:MovieClip;
      
      private var m_pin0_mc:MovieClip;
      
      public var m_leaderboardWindow:IrelandInnovationLeaderboardWindow;
      
      public function IrelandInnovationMainWindow(featureName:String = "IrelandInnovation", assetUrl:String = null, showEAPageTutorial:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_showTutorialWithEAPage = showEAPageTutorial;
         var dialogURL:String = this.manager.getDialogUrl();
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(FEATURE_NAME,dialogURL,numOfTutorialPages);
         this.m_BarInd = this.manager.isGAPlayer() ? 28 : 35;
      }
      
      override protected function postLoadComplete() : void
      {
         var isGA:Boolean = false;
         var userData:Object = null;
         var pinIndex:int = 0;
         var index:int = 0;
         var finalRewardItem:FarmItem = null;
         var tutorial_mc:MovieClip = null;
         var j:int = 0;
         var buttonName1:String = null;
         var lev:* = undefined;
         var iconUrl:* = undefined;
         super.postLoadComplete();
         if(this.manager.hasActiveDayExpired())
         {
            if(Global.player.getSeenFlag(this.manager.LEADERBOARD_PLAYING_FLAG))
            {
               Global.player.resetSeenFlag(this.manager.LEADERBOARD_PLAYING_FLAG);
            }
         }
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Goodwill Shire!!"));
            m_window[this.TITLE_TF].visible = true;
         }
         if(m_window.hasOwnProperty("overlay_mc"))
         {
            this.m_msg_overlayMc = m_window.overlay_mc as MovieClip;
            this.m_msg_overlayMc.visible = false;
         }
         if(m_window.hasOwnProperty("overlay1_mc"))
         {
            this.m_getMore_overlayMc = m_window.overlay1_mc as MovieClip;
            this.m_getMore_overlayMc.visible = false;
         }
         if(m_window.hasOwnProperty("subtitle_tf"))
         {
            addWidget(new ZwTextField(m_window["subtitle_tf"],""));
            m_window["subtitle_tf"].text = "Welcome to Goodwill Shire! People need your help. \nLet’s get started!";
            if(this.manager.getDayPoints() >= 1100)
            {
               m_window["subtitle_tf"].text = "Congrats! You completed all the daily tasks for Goodwill Shire. \nKeep playing for leaderboards!";
            }
            m_window["subtitle_tf"].visible = true;
         }
         if(m_window.hasOwnProperty("map_mc"))
         {
            this.m_map_mc = m_window["map_mc"] as MovieClip;
            this.m_map_mc.visible = true;
         }
         if(m_window.hasOwnProperty("lock_mc"))
         {
            this.m_lockMc = m_window["lock_mc"] as MovieClip;
            this.m_lockMc.visible = false;
            if(this.m_lockMc.hasOwnProperty(this.LOCK_TEXT_TF))
            {
               addWidget(this.m_lockText_tf = new ZwTextField(this.m_lockMc[this.LOCK_TEXT_TF],""));
               this.m_lockText_tf.visible = false;
            }
         }
         if(m_window.hasOwnProperty("counter_tf"))
         {
            addWidget(this.m_counterTf = new ZwTextField(m_window["counter_tf"],"Tasks Completed - " + this.manager.getOrderboardTaskCount() + "/" + this.manager.getDailyOrderLimit()));
            this.m_counterTf.visible = true;
         }
         if(m_window.hasOwnProperty("footer_tf"))
         {
            addWidget(this.m_footerTf = new ZwTextField(m_window["footer_tf"],"Daily Tasks"));
            this.m_footerTf.visible = true;
         }
         if(m_window.hasOwnProperty("pins_mc"))
         {
            this.m_pin_mc = m_window["pins_mc"] as MovieClip;
            this.m_pin_mc.visible = true;
            for(pinIndex = 0; pinIndex < 6; pinIndex++)
            {
               this.m_PinsMcArray[pinIndex] = this.m_pin_mc[this.PIN_MC_KEY_ARRAY[pinIndex]] as MovieClip;
               this.m_PinsMcArray[pinIndex].visible = true;
               this.m_pinsDooberMcArray[pinIndex] = this.m_pin_mc[this.PIN_DOOBER_MC_KEY_ARRAY[pinIndex]] as MovieClip;
               this.m_dooberIconsMc[pinIndex] = this.m_pinsDooberMcArray[pinIndex]["dooberIcon_mc"];
               this.m_dooberPointsTf[pinIndex] = new ZwTextField(this.m_dooberIconsMc[pinIndex].dooberCount_tf,"");
               this.m_dooberPointsTf[pinIndex].text = "";
               this.m_pinsMcWidgetArray[pinIndex] = new ZwFrame(this.m_PinsMcArray[pinIndex]);
               this.m_pinsMcWidgetArray[pinIndex].registerEventListener(MouseEvent.MOUSE_OVER,this.onOverPin(pinIndex));
               this.m_pinsMcWidgetArray[pinIndex].registerEventListener(MouseEvent.MOUSE_OUT,this.onOutPin(pinIndex));
               this.m_PinsMcArray[pinIndex].addEventListener(MouseEvent.CLICK,this.onPinClick(pinIndex));
               if(this.manager.getSelectedPin() == pinIndex)
               {
                  this.m_pinGlowMcArray[pinIndex] = this.m_PinsMcArray[pinIndex]["glow_mc"] as MovieClip;
                  this.m_pinGlowMcArray[pinIndex].visible = true;
               }
               else
               {
                  this.m_pinGlowMcArray[pinIndex] = this.m_PinsMcArray[pinIndex]["glow_mc"] as MovieClip;
                  this.m_pinGlowMcArray[pinIndex].visible = false;
               }
            }
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
         if(m_window.hasOwnProperty("npc_mc"))
         {
            this.m_npc_mc = m_window["npc_mc"] as MovieClip;
            this.m_npc_mc.visible = true;
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
         for(var i:int = 0; i < 3; i++)
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
            this.m_earnedPt_mc.visible = true;
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
               this.m_consumablehitWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("Medieval Axes!","\nCollect Medieval Axes to upgrade."));
               this.m_consumablehitWidget.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
            }
         }
         if(m_window.hasOwnProperty("highlightLB_mc"))
         {
            this.m_highlightLB_mc = m_window["highlightLB_mc"] as MovieClip;
         }
         if(m_window.hasOwnProperty("feature_progress_full_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["feature_progress_full_bt"],"Bonus Rewards",this.onProgressButtonClick));
         }
         isGA = this.manager.isGAPlayer();
         var progressRecordsCounter:String = isGA ? this.PROGRESS_RECORDS_COUNTER_GA : this.PROGRESS_RECORDS_COUNTER;
         if(m_window.hasOwnProperty(progressRecordsCounter))
         {
            this.m_progress_record_mc = m_window[progressRecordsCounter] as MovieClip;
            this.m_progress_record_mc.visible = true;
            for(index = 0; index < this.m_BarInd; index++)
            {
               this.m_progress_record_array[index] = this.m_progress_record_mc["day_" + index.toString() + "_mc"];
               if(index >= 1)
               {
                  this.m_progress_record_array[index].corck_mc.visible = false;
               }
               if(this.m_progress_record_array[index].hasOwnProperty("session_mc"))
               {
                  this.m_session_mc = this.m_progress_record_array[index]["session_mc"] as MovieClip;
                  this.m_session_mc.visible = true;
               }
               if(this.m_progress_record_array[index].hasOwnProperty("daymarker_mc"))
               {
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
         if(m_window.hasOwnProperty(TUTORIAL_MC))
         {
            tutorial_mc = m_window[TUTORIAL_MC] as MovieClip;
            if(m_tutorial)
            {
               for(j = 0; j < 5; j++)
               {
                  buttonName1 = "okay" + j.toString() + "_bt";
                  if(tutorial_mc.hasOwnProperty(buttonName1))
                  {
                     this.m_tutorialButtons[j] = new FarmAnimatedTextButton(tutorial_mc[buttonName1]);
                     m_tutorial.addWidget(this.m_tutorialButtons[j] as FarmAnimatedTextButton);
                     this.m_tutorialButtons[j].visible = false;
                  }
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
               this.m_avg_points_info = new ZwTextField(this.m_levels_mc["avg_points_tf"],"Your Average Score : " + 20);
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
            this.m_dooberMc.visible = true;
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
         if(m_window.hasOwnProperty("message_big_mc"))
         {
            this.m_message_mc = m_window["message_big_mc"] as MovieClip;
            this.m_message_mc.visible = false;
            this.m_effect_mc = this.m_message_mc["effect_1_mc"] as MovieClip;
            this.m_effect_mc.visible = false;
            if(this.m_message_mc.hasOwnProperty("axe_mc"))
            {
               this.m_messageTicket_mc = this.m_message_mc["axe_mc"] as MovieClip;
               this.m_messageTicket_mc.visible = false;
            }
            this.m_messageTitle = new ZwTextField(this.m_message_mc[this.TITLE_TF],"");
            this.m_messageInfo1 = new ZwTextField(this.m_message_mc["info1_tf"],"");
            this.m_messageInfo2 = new ZwTextField(this.m_message_mc["info2_tf"],"");
            if(this.m_message_mc.hasOwnProperty("cons_count_tf"))
            {
               this.m_messageCash = new ZwTextField(this.m_message_mc["cons_count_tf"],"");
               this.m_messageCash.visible = false;
            }
            this.m_messageOkay = new FarmAnimatedCashButton(this.m_message_mc["okay_bt"],"","10",null);
            this.m_messageOkay.enabled = true;
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
               if(1)
               {
                  this.m_FeatureTimer.text = "Day " + (this.manager.currentDayIndex + 1).toString() + "/35";
               }
               else
               {
                  this.m_FeatureTimer.text = "Day " + (this.manager.currentDayIndex - 6).toString() + "/28";
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
               this.m_overlay1_tf = new ZwTextField(this.m_overlay_mc["overlay1_tf"],"Town Building!");
            }
            if(this.m_overlay_mc.hasOwnProperty("overlay2_tf"))
            {
               this.m_overlay2_tf = new ZwTextField(this.m_overlay_mc["overlay2_tf"],"Score required points to get promoted at the end of each week to be promoted to a higher League!");
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
         if(m_window.hasOwnProperty("days_tf"))
         {
            addWidget(this.m_daysLeft_tf = new ZwTextField(m_window["days_tf"],this.getFeatureTimeLeft()));
         }
         if(m_window.hasOwnProperty("checkmark_mc"))
         {
            this.m_checkMark_mc = m_window["checkmark_mc"] as MovieClip;
            this.m_checkMark_mc.visible = true;
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
            this.m_taskFrame = new IrelandInnovationTaskFrame(m_window[this.TASKS_MC],this,this.m_featureName);
            this.m_taskFrame.visible = true;
         }
         for(var previewIndex:int = 0; previewIndex < 5; previewIndex++)
         {
            if(m_window.hasOwnProperty(this.PREVIEW_MC_KEY_ARRAY[previewIndex]))
            {
               addWidget(this.m_preview_mcArray[previewIndex] = new ZwFrame(m_window[this.PREVIEW_MC_KEY_ARRAY[previewIndex]]),true);
               this.m_preview_mcArray[previewIndex].registerEventListener(MouseEvent.MOUSE_OVER,this.onOver1(previewIndex));
               this.m_preview_mcArray[previewIndex].registerEventListener(MouseEvent.MOUSE_OUT,this.onOut1(previewIndex));
            }
         }
         for(var mileStoneIndex:int = 0; mileStoneIndex < 5; mileStoneIndex++)
         {
            this.m_mileStoneMcArray[mileStoneIndex] = m_window[this.MILESTONE_MC_KEY_ARRAY[mileStoneIndex]] as MovieClip;
            this.m_mileStoneMcArray[mileStoneIndex].visible = true;
            this.m_mileStonePoints_tfArray[mileStoneIndex] = new ZwTextField(this.m_mileStoneMcArray[mileStoneIndex][this.POINTS_TF],this.manager.VAL_MILESTONE_POINTS_ARRAY[mileStoneIndex]);
         }
         for(var mileStoneRewardIndex:int = 0; mileStoneRewardIndex < 5; mileStoneRewardIndex++)
         {
            this.m_reward_mcArray[mileStoneRewardIndex] = m_window[this.REWARD_MC_KEY_ARRAY[mileStoneRewardIndex]] as MovieClip;
            this.m_rewardAfterMcArray[mileStoneRewardIndex] = this.m_reward_mcArray[mileStoneRewardIndex][this.AFTER_MC] as MovieClip;
            this.m_rewardBeforeMcArray[mileStoneRewardIndex] = this.m_reward_mcArray[mileStoneRewardIndex][this.BEFORE_MC] as MovieClip;
            this.m_rewardBeforeMcPointsTfArray[mileStoneRewardIndex] = new ZwTextField(this.m_rewardBeforeMcArray[mileStoneRewardIndex]["points_tf"],"0000");
            this.m_rewardTickMcArray[mileStoneRewardIndex] = this.m_reward_mcArray[mileStoneRewardIndex][this.TICK_MC] as MovieClip;
            this.m_rewardCountTfArray[mileStoneRewardIndex] = new ZwTextField(this.m_reward_mcArray[mileStoneRewardIndex][this.COUNT_TF],"");
            lev = mileStoneRewardIndex;
            iconUrl = this.getMilestoneRewatdImage(lev + 1);
            this.m_rewardIconMcArray[mileStoneRewardIndex] = new FarmIcon(this.m_reward_mcArray[mileStoneRewardIndex]["icon_70_mc"],iconUrl);
            this.m_rewardIconMcArray[mileStoneRewardIndex].setIconSize(70,70);
            this.m_rewardIconMcArray[mileStoneRewardIndex].setSmoothing(true);
         }
         if(m_window.hasOwnProperty(this.FINISH_MC))
         {
            this.m_finishMc = m_window[this.FINISH_MC] as MovieClip;
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
            addWidget(this.m_leaderboardButton = new FarmAnimatedTextButton(this.m_leaderboard_mc[this.LEADERBOARD_BT],"View",this.onClickLeaderboardButton));
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
            }
            if(this.m_leaderboard_mc.hasOwnProperty("icon_mc"))
            {
               this.m_leaderboardIconMc = this.m_leaderboard_mc.icon_mc;
               this.m_leaderboardIconMc.gotoAndStop(weekCount);
            }
            addWidget(this.m_leaderboardPoints_tf = new ZwTextField(m_window[this.LEADERBOARD_MC]["points_tf"]));
            if(this.manager.getWeeklyLeaderboardPoints() >= 0)
            {
               this.m_leaderboardPoints_tf.text = "Score:" + this.manager.getWeeklyLeaderboardPoints().toString();
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
         this.preSwitchChanges(tutorialSceneNumber);
         userData = this.manager.getUserDataFromLeaderboard();
         var rewardPoints:int = this.manager.getWeeklyLeaderboardPoints();
         this.updateDayBonus();
         this.refreshTaskFrame();
         this.refreshOrdersCompleted();
         this.updateProgressBar(true);
         this.updatePinsStates();
         this.pinGlowState(this.manager.getSelectedPin());
         this.updateLockMc(this.manager.isPlayingForLBToday());
         this.manager.initializeLeaderBoardProgress(true);
         this.startTimer();
         userData = this.manager.getUserDataFromLeaderboard();
         if(userData)
         {
            this.updateLeaderBoardFrame(rewardPoints,userData["rank"]);
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
      
      public function onClickLeaderboardButton(evt:Event) : void
      {
         this.manager.showLeaderboardUI();
      }
      
      public function updateLockMc(isLock:Boolean) : void
      {
         if(isLock)
         {
            this.m_lockMc.visible = true;
         }
         else
         {
            this.m_lockMc.visible = false;
         }
      }
      
      public function CloseCrushMC(e:Event = null) : void
      {
      }
      
      public function onCloseTileOverlay(evt:Event) : void
      {
         this.m_tileUnlock_mc.visible = false;
      }
      
      public function getMilestoneRewatdImage(milstoneLevel:int = 1) : String
      {
         var buildLevel:* = this.manager.getKeyBuildingLevel();
         if(buildLevel > 4)
         {
            buildLevel = 4;
         }
         return "assets/dialogs/ireland/Innovation/upgrade_" + (buildLevel + 1) + "_reward_" + milstoneLevel + ".png";
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
         var title:String = "Compete in Leaderboard";
         var subtitle:String = "\nYou can see your Leaderboard rank by clicking on the View button";
         this.m_leaderboardhitWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver(title,subtitle));
         this.m_leaderboardhitWidget.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
      }
      
      override protected function preSwitchChanges(sceneNumber:int) : void
      {
         var button0:FarmAnimatedTextButton = null;
         var button1:FarmAnimatedTextButton = null;
         var button2:FarmAnimatedTextButton = null;
         var button3:FarmAnimatedTextButton = null;
         var button4:FarmAnimatedTextButton = null;
         switch(sceneNumber)
         {
            case 1:
               button0 = this.m_tutorialButtons[0] as FarmAnimatedTextButton;
               button0.text = "Next";
               button0.visible = true;
               button0.callback = this.onTutorialOkayButtonClick;
               this.hideOtherTutorialButtonsExpect(0);
               break;
            case 2:
               button1 = this.m_tutorialButtons[1] as FarmAnimatedTextButton;
               button1.text = "Next";
               button1.visible = true;
               button1.callback = this.onTutorialOkayButtonClick;
               this.hideOtherTutorialButtonsExpect(1);
               break;
            case 3:
               button2 = this.m_tutorialButtons[2] as FarmAnimatedTextButton;
               button2.text = "Next";
               button2.visible = true;
               button2.callback = this.onTutorialOkayButtonClick;
               this.hideOtherTutorialButtonsExpect(2);
               break;
            case 4:
               button3 = this.m_tutorialButtons[3] as FarmAnimatedTextButton;
               button3.text = "Next";
               button3.visible = true;
               button3.callback = this.onTutorialOkayButtonClick;
               this.hideOtherTutorialButtonsExpect(3);
               break;
            case 5:
               button4 = this.m_tutorialButtons[4] as FarmAnimatedTextButton;
               button4.text = "Great";
               button4.visible = true;
               button4.callback = this.onTutorialOkayButtonClick;
               this.hideOtherTutorialButtonsExpect(4);
         }
      }
      
      private function hideOtherTutorialButtonsExpect(buttonNo:int) : void
      {
         for(var i:int = 0; i < this.m_tutorialButtons.length; i++)
         {
            if(i != buttonNo)
            {
               this.m_tutorialButtons[i].visible = false;
            }
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
         this.m_dailyTimer_tf.text = HUD.getformattedTimeLeft(this.manager.getTimeLeftInDay());
         this.m_daysLeft_tf.text = this.getFeatureTimeLeft();
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
            this.refreshAskButton();
         }
      }
      
      public function refreshAskButton() : void
      {
         var xPostTimeRemaining:int = 0;
         var timeRemaining:Array = null;
         if(this.m_ask_bt)
         {
            xPostTimeRemaining = this.manager.getThrottleTimeRemaining(IrelandInnovationManager.FEED_NAME);
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
         if(this.m_msg_overlayMc)
         {
            this.m_msg_overlayMc.visible = false;
         }
         if(this.m_getMore_overlayMc)
         {
            this.m_getMore_overlayMc.visible = false;
         }
         if(this.m_messageCash.visible == true)
         {
            this.m_messageCash.visible = false;
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
         if(tutorialSceneNumber < totalScenes)
         {
            ++tutorialSceneNumber;
            (m_tutorial.element as MovieClip).gotoAndStop(tutorialSceneNumber);
            this.preSwitchChanges(tutorialSceneNumber);
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
      
      private function onActiveNPCAnimation(activeNPC:MovieClip) : Function
      {
         return function(event:Event):void
         {
            if(activeNPC.currentFrame == 120)
            {
               activeNPC.stop();
               activeNPC.visible = false;
               activeNPC.removeEventListener(Event.ENTER_FRAME,onActiveNPCAnimation(activeNPC),false);
            }
         };
      }
      
      public function updateTaskDoober(taskPt:int = 0) : void
      {
         var dayPoints:int = this.manager.getDayPoints();
         if(taskPt > 0)
         {
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
      }
      
      private function getDayNumberForPlayer() : int
      {
         var index:int = this.manager.isGAPlayer() ? int(this.manager.activeDayIndex - 7) : this.manager.activeDayIndex;
         return index < 0 ? 0 : index;
      }
      
      public function updateProgressBar(onOpenWindow:Boolean = false) : void
      {
         var dayPoints:int = this.manager.getDayPoints();
         var level:int = this.manager.getKeyBuildingLevel();
         if(this.m_earnedPt_mc[this.POINTS_TF])
         {
            (this.m_earnedPt_mc[this.POINTS_TF] as TextField).text = int(dayPoints).toString();
         }
         var maxPoint:int = 0;
         var progressPoints:int = 0;
         if(level == 0)
         {
            maxPoint = int(this.manager.VAL_LEVEL_POINTS_ARRAY[level]);
            progressPoints = dayPoints;
         }
         else
         {
            maxPoint = this.manager.VAL_LEVEL_POINTS_ARRAY[level] - this.manager.VAL_LEVEL_POINTS_ARRAY[level - 1];
            progressPoints = dayPoints - this.manager.VAL_LEVEL_POINTS_ARRAY[level - 1];
         }
         var barLength:Number = progressPoints * this.PROGRESS_BAR_FULL_WIDTH / maxPoint;
         if(this.m_barMc)
         {
            if(dayPoints < 0)
            {
               this.m_barMc.height = barLength;
            }
            else if(onOpenWindow == false)
            {
               TweenMax.to(this.m_barMc,2,{"height":barLength});
            }
            else
            {
               this.m_barMc.height = barLength;
            }
         }
      }
      
      private function onIdleNPCAnimation(upgrade:Boolean = false) : Function
      {
         return function(event:Event):void
         {
            var league:* = 2;
            var previousLeague:* = upgrade ? league - 1 : league + 1;
            var frame:* = league + 1;
            if(m_npc_change_mc.currentFrame == 50)
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
            m_npc_change_mc.addEventListener(Event.ENTER_FRAME,onIdleNPCAnimation(upgrade),false,0,true);
         };
      }
      
      private function setupMessageFrame(upgrade:Boolean = false) : void
      {
         this.m_taskFrame.visible = false;
         this.m_message_mc.visible = true;
         this.m_messageOkay.enabled = true;
         this.m_messageOkay.visible = true;
         this.m_messageTicket_mc.visible = false;
         this.m_effect_mc.visible = false;
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         itemBox.visible = false;
      }
      
      private function showUpgradeMessage() : void
      {
         this.setupMessageFrame(true);
         this.m_messageTitle.text = "Welcome to the  League!";
         this.m_messageInfo1.text = "Keep up the pace and score as many points as possible!";
         this.m_messageInfo2.text = "Get amazing rewards at the end of the week!";
         this.m_messageOkay.text = "Awesome!";
         this.m_leaderboardButton.enabled = false;
         this.m_messageOkay.callback = this.playNPCUpdateAnimation(true);
      }
      
      private function showDowngradeMessage() : void
      {
         this.setupMessageFrame(false);
         this.m_messageTitle.text = "Better Luck Next Time!";
         this.m_messageInfo2.text = "Try your best to score well and get promoted this week!";
         this.m_messageOkay.text = "Okay!";
         this.m_leaderboardButton.enabled = false;
         this.m_messageOkay.callback = this.playNPCUpdateAnimation(false);
      }
      
      public function refreshTaskFrame(e:Event = null) : void
      {
         var firstTimeFeatureAccess:Boolean = false;
         var redeemPreviousDayTask:Boolean = false;
         var hasLeagueUpdated:Boolean = false;
         if(this.m_taskFrame)
         {
            this.m_taskFrame.visible = true;
         }
         if(this.m_message_mc)
         {
            this.m_message_mc.visible = false;
         }
         if(this.manager.getDayPoints() >= 1100)
         {
            if(Boolean(m_window) && Boolean(m_window["subtitle_tf"]))
            {
               m_window["subtitle_tf"].text = "Congrats! You completed all the daily tasks for Goodwill Shire. \nKeep playing for leaderboards!";
            }
         }
         if(this.manager.getUserState() == this.manager.BUILDING_COMPLETED && !Global.player.getSeenFlag(this.manager.PLAY_FOR_LB_ONLY_FLAG))
         {
            this.displayTownBuildingCompletedMessage();
            Global.player.setSeenFlag(this.manager.PLAY_FOR_LB_ONLY_FLAG);
         }
         else if(this.manager.getUserState() == this.manager.NOT_INITIALIZED)
         {
            this.displayFeatureStartMessage();
            firstTimeFeatureAccess = true;
         }
         else if(this.manager.shouldUpgradeLevel())
         {
            this.displaySinkConsumableMessage();
         }
         else if(this.manager.hasActiveDayExpired())
         {
            this.displayDayStartMessage();
         }
         else if(this.manager.getOrderboardTaskCount() == this.manager.getDailyOrderLimit() && this.manager.getUserState() == this.manager.DONE_FOR_THE_DAY)
         {
            this.displayOrderLimitReachedMessage();
         }
         else if(this.manager.redeemableTaskCount() > 0 && this.manager.getUserState() != this.manager.DONE_FOR_THE_DAY)
         {
            this.displayWelcomeBackMessage();
         }
         this.m_taskFrame.refresh();
         this.m_consumableCount_tf.text = "x" + this.manager.consumableCount.toString();
         this.updateOverallProgressButtons();
         this.updatePinsStates();
         this.updateConsumableCount();
         this.updateLockMc(this.manager.isPlayingForLBToday());
      }
      
      private function refreshLockVisiblility() : void
      {
         switch(this.manager.getUserState())
         {
            case this.manager.MEDIUM:
            case this.manager.LOCK2:
               if(this.m_lock1preview_mc)
               {
                  this.m_lock1preview_mc.visible = false;
               }
               if(this.m_lock2preview_mc)
               {
                  this.m_lock2preview_mc.visible = true;
               }
               break;
            case this.manager.HARD:
            case this.manager.DONE_FOR_THE_DAY:
               if(this.m_lock1preview_mc)
               {
                  this.m_lock1preview_mc.visible = false;
               }
               if(this.m_lock2preview_mc)
               {
                  this.m_lock2preview_mc.visible = false;
               }
               break;
            default:
               if(this.m_lock1preview_mc)
               {
                  this.m_lock1preview_mc.visible = true;
               }
               if(this.m_lock2preview_mc)
               {
                  this.m_lock2preview_mc.visible = true;
               }
         }
         if(this.manager.hasActiveDayExpired())
         {
            if(this.m_lock1preview_mc)
            {
               this.m_lock1preview_mc.visible = false;
            }
            if(this.m_lock2preview_mc)
            {
               this.m_lock2preview_mc.visible = false;
            }
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
            this.m_leaderboardPoints_tf.text = "Score:" + points.toString();
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
      
      public function displayWelcomeBackMessage() : void
      {
         this.m_effect_mc.visible = true;
         if(this.m_league_icon_mc)
         {
            this.m_league_icon_mc.visible = false;
         }
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageTitle.text = "Raise, Aim, Shoot!";
         this.m_messageOkay.visible = true;
         this.m_messageOkay.text = "Okay";
         this.m_messageOkay.enabled = true;
         this.m_messageOkay.callback = this.getOldTasksRedeemedFromUser;
         this.m_messageTicket_mc.visible = false;
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.loadIcon("assets/dialogs/ireland/Innovation/medieval_axe.png");
            itemBox.visible = true;
         }
         this.m_messageInfo1.text = "Keep helping town folk to earn their respect!";
         this.m_messageInfo2.text = "Redeem points to start helping your people again!";
      }
      
      public function getOldTasksRedeemedFromUser(e:Event = null) : void
      {
         this.m_message_mc.visible = false;
         this.m_taskFrame.visible = true;
      }
      
      public function displayDayFinishedMessage() : void
      {
         if(this.m_msg_overlayMc)
         {
            this.m_msg_overlayMc.visible = true;
         }
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
         if(this.m_league_icon_mc)
         {
            this.m_league_icon_mc.visible = false;
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
            itemBox.loadIcon("assets/dialogs/ireland/Innovation/medieval_axe.png");
            itemBox.visible = true;
         }
         var attachedToolTip:FarmTextTooltip = itemBox.tooltip as FarmTextTooltip;
         if(attachedToolTip)
         {
            attachedToolTip.release();
            itemBox.detachTooltip();
         }
         this.m_messageInfo1.text = "You have completed all the task for today.";
         this.m_messageInfo2.text = this.getLeagueSubtileText();
         this.m_messageOkay.callback = this.playForLeaderboardHelper;
      }
      
      public function getLeagueSubtileText() : String
      {
         var league:int = 2;
         var msg:String = "";
         if(league == 0)
         {
            msg = "Score minimum 250 points this week for Silver League";
         }
         else if(league == 1)
         {
            msg = "Score minimum 350 points this week for Gold League";
         }
         else if(league == 2)
         {
            msg = "Score minimum 300 points to stay in Gold League";
         }
         return msg;
      }
      
      public function playForLeaderboardHelper(e:Event = null) : void
      {
         if(this.m_msg_overlayMc)
         {
            this.m_msg_overlayMc.visible = false;
         }
         m_window["subtitle_tf"].text = "Keep helping people to earn their respect and their Votes!";
         this.m_message_mc.visible = false;
         this.m_taskFrame.visible = false;
         this.m_messageOkay.visible = false;
         this.m_messageOkay.enabled = false;
         this.manager.playForLeaderboard(this.refreshTaskFrame);
      }
      
      public function getLeaderboardPlaySubtitle() : String
      {
         var league:int = 2;
         return "Earn at least {0} points to be promoted to the {1} League when the week ends!";
      }
      
      public function displayDayStartMessage() : void
      {
         if(this.m_msg_overlayMc)
         {
            this.m_msg_overlayMc.visible = true;
         }
         this.m_effect_mc.visible = true;
         if(this.m_league_icon_mc)
         {
            this.m_league_icon_mc.visible = false;
         }
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
            itemBox.loadIcon("assets/dialogs/ireland/Innovation/medieval_axe.png");
            itemBox.visible = true;
         }
         if(this.manager.getUserState() == this.manager.DONE_FOR_THE_DAY)
         {
            this.m_messageTitle.text = "New Day Begin!";
            this.m_messageInfo1.text = "Your people need you, start helping!";
         }
         else
         {
            this.m_messageTitle.text = "New Day Begin!";
            this.m_messageInfo1.text = "Your people need you, start helping!";
         }
         this.m_messageInfo2.text = "Win amazing rewards for your effort! All the best!";
      }
      
      public function displayFeatureStartMessage() : void
      {
         if(this.m_msg_overlayMc)
         {
            this.m_msg_overlayMc.visible = true;
         }
         if(this.manager.isGAPlayer())
         {
            this.showNPCCallouts("Goodwill Shire!","Welcome to Goodwill Shire! People need your help. Let’s get started!");
         }
         else
         {
            this.showNPCCallouts("Goodwill Shire!","Welcome! As an Early Access benefit, you get extra time to play and 40 Medieval Axes!");
         }
         this.m_effect_mc.visible = true;
         if(this.m_league_icon_mc)
         {
            this.m_league_icon_mc.visible = false;
         }
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageOkay.visible = true;
         this.m_messageTicket_mc.visible = false;
         this.m_messageOkay.enabled = true;
         this.m_messageOkay.callback = this.manager.startNewDay;
         this.m_messageOkay.text = "Start Now!";
         this.m_messageTitle.text = "A NEW DAY BEGINS!";
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.loadIcon("assets/dialogs/ireland/Innovation/medieval_axe.png");
            itemBox.visible = true;
         }
         this.m_messageInfo1.text = "Complete orders on the board to reach the top!";
         this.m_messageInfo2.text = "Win amazing rewards for your effort! All the best!";
      }
      
      public function displaySinkConsumableMessage() : void
      {
         var itemBox:FarmIcon = null;
         if(this.m_getMore_overlayMc)
         {
            this.m_getMore_overlayMc.visible = true;
         }
         this.m_effect_mc.visible = true;
         if(this.m_league_icon_mc)
         {
            this.m_league_icon_mc.visible = false;
         }
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageOkay.visible = true;
         this.m_messageTicket_mc.visible = false;
         this.m_messageOkay.enabled = this.manager.hasEnoughConsumableToSink();
         this.m_messageOkay.callback = this.onSinkButtonClick;
         var tooltipText:String = this.manager.getSinkButtonToolTipMessage();
         this.m_messageOkay.attachTooltip(new FarmTextTooltip(tooltipText));
         itemBox = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.visible = false;
         }
         if(this.m_messageCash)
         {
            this.m_messageCash.text = "" + this.manager.CONSUMABLE_COUNT_ARRAY[this.manager.getKeyBuildingLevel()];
            this.m_messageCash.visible = true;
         }
         if(this.m_messageTicket_mc)
         {
            this.m_messageTicket_mc.visible = true;
         }
         this.m_messageOkay.text = "Sink Medieval Axes";
         this.m_messageTitle.text = "Congratulations!";
         itemBox = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.loadIcon("assets/dialogs/ireland/Innovation/medieval_axe.png");
            itemBox.visible = true;
         }
         this.m_messageInfo1.text = "You are a " + this.townLevelTextArray[this.manager.getKeyBuildingLevel()] + " now!!";
         this.m_messageInfo2.text = "Medieval Axes are needed to move ahead!";
      }
      
      public function displayOrderLimitReachedMessage() : void
      {
         if(this.m_msg_overlayMc)
         {
            this.m_msg_overlayMc.visible = true;
         }
         this.m_effect_mc.visible = true;
         if(this.m_league_icon_mc)
         {
            this.m_league_icon_mc.visible = false;
         }
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageOkay.visible = true;
         this.m_messageOkay.enabled = true;
         this.m_messageTicket_mc.visible = false;
         this.m_messageOkay.callback = this.playForLeaderboardHelper;
         this.m_messageOkay.text = "I\'m Ready!";
         this.m_messageTitle.text = "Congratulations!";
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.loadIcon("assets/dialogs/ireland/Innovation/medieval_axe.png");
            itemBox.visible = true;
         }
         this.m_messageInfo1.text = "You have completed your daily orders!";
         this.m_messageInfo2.text = "Do more orders to reach the top in Leaderboard";
      }
      
      public function displayTownBuildingCompletedMessage() : void
      {
         this.m_effect_mc.visible = true;
         if(this.m_league_icon_mc)
         {
            this.m_league_icon_mc.visible = false;
         }
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageOkay.visible = true;
         this.m_messageOkay.enabled = true;
         this.m_messageTicket_mc.visible = false;
         this.m_messageOkay.callback = this.playForLeaderboardHelper;
         this.m_messageOkay.text = "I\'m Ready!";
         this.m_messageTitle.text = "Congratulations!";
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.loadIcon("assets/dialogs/ireland/Innovation/medieval_axe.png");
            itemBox.visible = true;
         }
         this.m_messageInfo1.text = "Goodwill Shire is complete!";
         this.m_messageInfo2.text = "Do more orders to reach the top in Leaderboard";
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
         if(this.m_checkMark_mc)
         {
            this.m_checkMark_mc.visible = false;
         }
         if(this.manager.getDayPoints() >= 1100)
         {
            if(Boolean(m_window) && Boolean(m_window["subtitle_tf"]))
            {
               m_window["subtitle_tf"].text = "Congrats! You completed all the daily tasks for Goodwill Shire. \nKeep playing for leaderboards!";
            }
         }
         this.m_consumableCount_tf.text = "x" + this.manager.consumableCount.toString();
         this.refreshTaskFrame();
         this.updateProgressBar();
         this.updateDayBonus();
         if(this.manager.hasFeatureExpired())
         {
            this.m_featureEndMc.visible = true;
         }
      }
      
      public function refreshOrdersCompleted() : *
      {
         this.updateProgressBar();
         if(this.m_leaderboardPoints_tf)
         {
            this.m_leaderboardPoints_tf.text = "Score:" + this.manager.getWeeklyLeaderboardPoints().toString();
         }
         if(this.m_counterTf)
         {
            this.m_counterTf.text = "Tasks Completed - " + this.manager.getOrderboardTaskCount() + "/" + this.manager.getDailyOrderLimit();
         }
         if(this.m_footerTf)
         {
            this.m_footerTf.text = "Daily Tasks";
         }
         if(this.manager.getOrderboardTaskCount() >= this.manager.getDailyOrderLimit())
         {
            this.m_counterTf.text = "Playing for leaderboard";
            if(this.m_footerTf)
            {
               this.m_footerTf.text = "Leaderboard Tasks";
            }
         }
         if(Global.player.getSeenFlag(this.manager.PLAY_FOR_LB_ONLY_FLAG))
         {
            this.m_footerTf.text = "Leaderboard Tasks";
            this.m_counterTf.text = "Playing for leaderboard";
         }
      }
      
      public function updateDayBonus() : void
      {
         var points:int = 0;
         var level:int = 0;
         var buildingName:String = null;
         var buildingItem:FarmItem = null;
         var lev:* = undefined;
         var rewardLevel:* = undefined;
         var iconUrl:* = undefined;
         if(m_window.hasOwnProperty("best_icon_50_mc"))
         {
            this.m_dailyReward_mc = m_window["best_icon_50_mc"] as MovieClip;
            this.m_dailyRewardhitWidget = new ZwFrame(m_window["best_icon_50_mc"] as MovieClip);
            points = int(this.manager.VAL_LEVEL_POINTS_ARRAY[this.manager.getKeyBuildingLevel()]);
            this.m_dailyRewardhitWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("Rewards!","\nScore " + points + " and sink required Medieval Axes to win this exclusive reward!"));
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
            level = this.manager.getFeatureOptionsKey(this.manager.KEY_BUILDING_LEVEL) as int;
            level = level > 4 ? 4 : level;
            buildingName = this.manager.getBuildingRewardsData(level);
            buildingItem = Global.farmGameSettingsManager.getFarmItemByName(buildingName);
            this.m_best_icon_mc = new FarmIcon(m_window["best_icon_50_mc"],buildingItem.iconUrl);
            this.m_best_icon_mc.attachTooltip(new FarmTextTooltip(buildingItem.friendlyTitle));
            this.m_best_icon_mc.setIconSize(70,70);
            this.m_best_icon_mc.visible = true;
         }
         for(var mileStoneRewardIndex:int = 0; mileStoneRewardIndex < 5; mileStoneRewardIndex++)
         {
            if(this.m_rewardIconMcArray[mileStoneRewardIndex])
            {
               (this.m_rewardIconMcArray[mileStoneRewardIndex] as FarmIcon).release();
               level = this.manager.getKeyBuildingLevel();
               lev = mileStoneRewardIndex;
               rewardLevel = level * 5 + lev;
               iconUrl = this.getMilestoneRewatdImage(lev + 1);
               this.m_rewardIconMcArray[mileStoneRewardIndex] = new FarmIcon(this.m_reward_mcArray[mileStoneRewardIndex]["icon_70_mc"],iconUrl);
               this.m_rewardIconMcArray[mileStoneRewardIndex].setIconSize(70,70);
               this.m_rewardIconMcArray[mileStoneRewardIndex].setSmoothing(true);
               this.m_mileStonePoints_tfArray[mileStoneRewardIndex] = new ZwTextField(this.m_mileStoneMcArray[mileStoneRewardIndex][this.POINTS_TF],this.manager.VAL_MILESTONE_POINTS_ARRAY[rewardLevel]);
            }
         }
      }
      
      public function updateActiveDay() : void
      {
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_IRELAND) == true)
         {
            this.m_FeatureTimer.text = "Day " + (this.manager.currentDayIndex + 1).toString() + "/35";
         }
      }
      
      public function updateActiveDayIndex() : void
      {
         if(this.m_session_mc)
         {
            this.m_session_mc.visible = false;
         }
         var dayInd:int = this.getDayNumberForPlayer();
      }
      
      private function updateOverallProgressButtons() : void
      {
         var i:int = 0;
         if(this.m_progressLevelArray_mc)
         {
            for(i = 0; i < 3; i++)
            {
               if(i == 0)
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
         return this.manager.getFeatureEndDaysLeftText() + " left";
      }
      
      private function get manager() : IrelandInnovationManager
      {
         return IrelandInnovationManager.getInstance(FEATURE_NAME);
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
            var level:* = manager.getKeyBuildingLevel();
            var rewardLevel:* = level * 5 + i;
            m_reward_mcArray[i].visible = true;
            var isMileStoneAchieved:* = manager.isMilestoneAchievedForLevel(rewardLevel);
            m_rewardAfterMcArray[i].visible = isMileStoneAchieved;
            m_rewardBeforeMcArray[i].visible = !isMileStoneAchieved;
            m_rewardBeforeMcPointsTfArray[i].text = (manager.VAL_MILESTONE_POINTS_ARRAY[rewardLevel] - manager.getDayPoints()).toString() + " more";
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
      
      public function isFirstTimeTutorial() : Boolean
      {
         return m_tutorialFirstTime;
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
      
      public function CalloutTextForEachPin(pin:*) : String
      {
         var questTasks1:Vector.<FarmTask> = null;
         questTasks1 = IrelandInnovationManager.getInstance(this.m_featureName).getTasks();
         var progress:int = IrelandInnovationManager.getInstance(this.m_featureName).getTaskProgress(pin);
         var completedTask:Boolean = progress >= questTasks1[pin].total;
         var callout:String = "";
         if(completedTask)
         {
            callout = "\nTask is ready to redeem!";
         }
         else if(progress > 0 && !completedTask)
         {
            callout = "\nYour task is in progress.";
         }
         else if(this.manager.isTaskDumped(pin))
         {
            callout = "\nTask was trashed, come in some time to see the new task!";
         }
         else if(pin == this.manager.getSelectedPin())
         {
            callout = "\nComplete the task.";
         }
         else
         {
            callout = "\nClick to view task.";
         }
         return callout;
      }
      
      public function onOverPin(pinIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            var msg:* = CalloutTextForEachPin(pinIndex);
            showNPCCallouts("",msg);
         };
      }
      
      public function onOutPin(pinIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            hideNPCCallout();
         };
      }
      
      public function onPinClick(pinIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            manager.updateSelectedPin(pinIndex);
            m_taskFrame.refresh();
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
         this.manager.unlockLandFromBuyWindow();
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
         this.manager.m_mainWindow = null;
         FarmStatsManager.count("IrelandInnovation","Main_UI","close_window");
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
         var tile:String = null;
         if(this.m_msg_overlayMc)
         {
            this.m_msg_overlayMc.visible = false;
         }
         var count:int = this.manager.getTileUnlockCount();
         if(count > 0)
         {
            this.m_overlay_tf.text = "Unlocker of Tiles!";
            tile = " tiles. ";
            if(count == 1)
            {
               tile = " tile. ";
            }
            this.m_tileUnlockDes_tf.text = "You have gotten " + (count * this.TILE_UNLOCK_CONSUMABLE_COUNT).toString() + " Medieval Axes on unlocking " + count.toString() + tile + "Enjoy!";
            this.m_tileUnlock_mc.visible = true;
            this.m_tileUnlock_mc.gotoAndStop(1);
         }
      }
      
      public function pinGlowState(pinIndex:*) : void
      {
         for(var i:int = 0; i < 6; i++)
         {
            if(this.manager.getSelectedPin() == i)
            {
               this.m_pinGlowMcArray[i] = this.m_PinsMcArray[i]["glow_mc"] as MovieClip;
               this.m_pinGlowMcArray[i].visible = true;
            }
            else
            {
               this.m_pinGlowMcArray[i] = this.m_PinsMcArray[i]["glow_mc"] as MovieClip;
               this.m_pinGlowMcArray[i].visible = false;
            }
         }
      }
      
      public function updatePinsStates() : void
      {
         var questTasks1:Vector.<FarmTask> = null;
         var progress:int = 0;
         var completedTask:Boolean = false;
         for(var i:int = 0; i < 6; i++)
         {
            questTasks1 = IrelandInnovationManager.getInstance(this.m_featureName).getTasks();
            progress = IrelandInnovationManager.getInstance(this.m_featureName).getTaskProgress(i);
            completedTask = progress >= questTasks1[i].total;
            this.m_PinsMcArray[i].gotoAndStop(1);
            if(completedTask)
            {
               this.m_PinsMcArray[i].gotoAndStop(3);
            }
            if(progress > 0 && !completedTask)
            {
               this.m_PinsMcArray[i].gotoAndStop(4);
            }
            if(this.manager.isTaskDumped(i))
            {
               this.m_PinsMcArray[i].gotoAndStop(2);
            }
         }
      }
      
      public function hideMessage() : void
      {
         this.m_message_mc.visible = false;
         this.m_taskFrame.visible = true;
         this.m_messageOkay.visible = false;
         this.m_messageOkay.enabled = false;
      }
   }
}

