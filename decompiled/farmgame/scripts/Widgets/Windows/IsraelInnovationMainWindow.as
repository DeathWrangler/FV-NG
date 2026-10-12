package Widgets.Windows
{
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.FarmStatsManager;
   import Managers.IsraelInnovationManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.IsraelInnovationTaskFrame;
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
   
   public class IsraelInnovationMainWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 7;
      
      public static const ICON_SIZE:int = 50;
      
      private static const FEATURE_NAME:String = "IsraelInnovation";
      
      public static const FIRST_EVER_REDEEM:String = "firstTimeRedeem";
      
      private var m_featureName:String = null;
      
      private const ISRAEL_INNOVATION_WELCOME_SEEN_FLAG:String = "IsraelInnovation_Welcome_flag";
      
      private const LEADERBOARD_PLAYING_FLAG:String = "Leaderboard_Playing_flag";
      
      private const FIRST_TILE_UNLOCK:String = "First_Tile_Unlock";
      
      private const NORMAL_FEATURE_END:String = "Normal_Feature_End";
      
      private const LAST_DAY_ENTERED:String = "Last_Day_entered";
      
      private const LAND_BUNDLE_OVERLAY:String = "Land_Bundle_Overlay";
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const TASKS_MC:String = "tasks_mc";
      
      private const FEATURE_TIMER_TF:String = "timer_tf";
      
      private const DAILY_TIMER_MC:String = "daily_clock_mc";
      
      private const DAILY_COLLECT_MC:String = "daily_collect_mc";
      
      private const COMMUNITY_MC:String = "community_mc";
      
      private const FINISH_TF:String = "finish_tf";
      
      private const FINISH_BODY_TF:String = "finish_subtext_tf";
      
      private const FINISH_MC:String = "finish_mc";
      
      private const DUMPFTUE_MC:String = "dumpFTUE_mc";
      
      private const POINTS_TF:String = "points_tf";
      
      private const POINTS_ICON_MC:String = "points_icon_mc";
      
      private const TEXT_FINISH_TITLE:String = "_finish_title";
      
      private const TEXT_FINISH_BODY:String = "_finish_description";
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private var m_taskFrame:IsraelInnovationTaskFrame;
      
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
      
      private var m_community_tf:ZwTextField;
      
      private var m_community_bt:FarmAnimatedTextButton;
      
      private var m_community_mc:MovieClip;
      
      private var WEEKLY_COUNTER_MC:String = "weekly_counter_mc";
      
      private var WEEKLY_COUNTER_GA_MC:String = "weekly_counter_GA_mc";
      
      public var m_week_tf:ZwTextField;
      
      private var m_weekly_counter_mc:MovieClip;
      
      private var m_weeklyReward_mc:MovieClip;
      
      private var m_weeklyCheckmark_mc:MovieClip;
      
      private var m_week_bonus_mc:ZwFrame;
      
      private var m_week_preview1_mc:ZwFrame;
      
      private var m_week_preview2_mc:ZwFrame;
      
      private var m_week_reward1_mc:MovieClip;
      
      private var m_week_reward2_mc:MovieClip;
      
      private var m_week_reward1_icon_mc:FarmIcon;
      
      private var m_week_reward2_icon_mc:FarmIcon;
      
      private var m_week_reward1_tick_mc:MovieClip;
      
      private var m_week_reward2_tick_mc:MovieClip;
      
      private var m_week_reward1Icon_mc:MovieClip;
      
      private var m_week_reward2Icon_mc:MovieClip;
      
      private var m_dooberMc:MovieClip;
      
      private var m_dooberIconMc:MovieClip;
      
      private var m_dooberCountTf:ZwTextField;
      
      private var m_daily_dooberMc:MovieClip;
      
      private var m_daily_dooberIconMc:MovieClip;
      
      private var m_daily_dooberCountTf:ZwTextField;
      
      private var m_highlight_mc:MovieClip;
      
      private var m_highlightLB_mc:MovieClip;
      
      private var m_leaderboard_dooberMc:MovieClip;
      
      private var m_leaderboard_dooberIconMc:MovieClip;
      
      private var m_leaderboard_dooberCountTf:ZwTextField;
      
      protected var m_DumpTutorial:ZwFrame = null;
      
      private var m_DumptutorialScene:int = 0;
      
      private var m_BarInd:int = 0;
      
      private const PROGRESS_BAR_FULL_WIDTH:int = 350;
      
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
      
      private const WEEKLY_PROGRESS_MC:String = "week_meter_mc";
      
      private var m_progress_record_mc:MovieClip;
      
      private var m_daily_progress_mc:MovieClip;
      
      private var m_weekly_progress_mc:MovieClip;
      
      private var m_barMc:MovieClip;
      
      private var m_fillMc:MovieClip;
      
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
      
      public var m_dailyCollect_title_tf:ZwTextField;
      
      public var m_dailyCollect_count_tf:ZwTextField;
      
      public var m_community_iconMc:FarmIcon;
      
      private var m_FeatureTimer:ZwTextField;
      
      private const FEATURE_TIMER_MC:String = "feature_timer_mc";
      
      private var m_featureTimer_mc:MovieClip;
      
      private var m_progressLevelArray_mc:Array;
      
      private var m_levelHoverArray_mc:Array = [];
      
      private var m_finalRewardIconArray_mc:Array = [];
      
      private var m_finalRewardTfArray_tf:Array = [];
      
      private var m_progressLevelArray_tf:Array;
      
      private var m_weekCountArray_tf:Array;
      
      private const ProgressLevelTextArray:Array = ["GROWER","EXPORTER","TYCOON"];
      
      private const TEXT_REWARD_HOVER:Array = ["EARN 75 POINTS","EARN 150 POINTS","EARN 350 POINTS"];
      
      private const EARNED_POINTS_MC:String = "earned_points_mc";
      
      private const DAILY_PROGRESS_BAR_FULL_WIDTH:int = 70;
      
      private const PROGRESS_BAR_FULL_ANGLE:int = 360;
      
      private var m_lock1HoverText:ZwTextField;
      
      private var m_lock2HoverText:ZwTextField;
      
      private const REWARD_EA_WEEK:String = "reward_EA_mc";
      
      private var m_EA_week_mc:MovieClip;
      
      public var m_unlockanim1_mc:MovieClip;
      
      public var m_unlockanim2_mc:MovieClip;
      
      public var m_daily_collect_mc:MovieClip;
      
      private const LEADERBOARD_BT:String = "leaderboard_bt";
      
      private const LEADERBOARD_MC:String = "leaderboard_mc";
      
      private var m_leaderboardButton:FarmAnimatedTextButton;
      
      private var m_playing_leaderboard:Boolean = false;
      
      private const TILE_UNLOCK_CONSUMABLE_COUNT:int = 30;
      
      private var m_earnedPt_mc:MovieClip;
      
      private var m_idleNPC:MovieClip;
      
      private var m_jumpNPC:MovieClip;
      
      private var m_stompNPC:MovieClip;
      
      private var m_alertNPC:MovieClip;
      
      private var m_informNPC:MovieClip;
      
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
      
      private var m_week_reward_mcArray:Array = [];
      
      private var m_rewardAfterMcArray:Array = [];
      
      private var m_rewardBeforeMcArray:Array = [];
      
      private var m_rewardIconMcArray:Array = [];
      
      private var m_weekRewardIconMcArray:Array = [];
      
      private var m_rewardCountTfArray:Array = [];
      
      private var m_rewardBeforeMcPointsTfArray:Array = [];
      
      private var m_rewardTickMcArray:Array = [];
      
      private var m_rewardWeekTickMcArray:Array = [];
      
      private var m_preview_mcArray:Array = [];
      
      private var m_week_preview_mcArray:Array = [];
      
      private var m_weekArray_mc:Array;
      
      private var m_weekArray_tf:Array;
      
      private var m_week_tfArray:Array = ["1st","2nd","3rd","4th","5th","6th","7th"];
      
      private const PREVIEW_MC_KEY_ARRAY:Array = ["preview1_mc","preview2_mc","preview3_mc"];
      
      private const WEEK_PREVIEW_MC_KEY_ARRAY:Array = ["week_preview1_mc","week_preview2_mc"];
      
      private const MILESTONE_MC_KEY_ARRAY:Array = ["milestone1_mc","milestone2_mc","milestone3_mc"];
      
      private const FINAL_REWARD_CODE_ARRAY:Array = ["3vm8","yxfz","6oxl"];
      
      private const REWARD_MC_KEY_ARRAY:Array = ["reward1_mc","reward2_mc","reward3_mc"];
      
      private const WEEK_REWARD_MC_KEY_ARRAY:Array = ["week_reward1_mc","week_reward2_mc"];
      
      private const DATE_ARRAY:Array = ["01/10/2018","09/24/2018","09/17/2018","09/10/2018"];
      
      private var m_showTutorialWithEAPage:Boolean = false;
      
      private var m_iconPreview:ObjectPreviewFrame;
      
      private var m_icon1Preview:ObjectPreviewFrame;
      
      private var m_icon2Preview:ObjectPreviewFrame;
      
      private var m_isIconPreviewAdded:Boolean;
      
      private var m_isIcon1PreviewAdded:Boolean;
      
      private var m_isIcon2PreviewAdded:Boolean;
      
      private var m_best_icon_mc:FarmIcon;
      
      private var m_sinkBtTooltip:FarmTextTooltip;
      
      private var m_timerWidget:ZwFrame;
      
      private var m_timerToolTip:FarmTextTooltip;
      
      private var m_progressLevelArrarZFrame:Array;
      
      private const DAILY_DUMMY_MAX_POINT:Number = 50;
      
      private const MAX_POINT:Number = 350;
      
      private var m_barrel_mc:ZwFrame;
      
      private var m_crushHelp_mc:MovieClip;
      
      private var m_firstStartSessionMC:MovieClip;
      
      private var m_tileUnlock_bt:FarmAnimatedTextButton;
      
      private var m_wineMc:MovieClip;
      
      private var m_mainBG_mc:MovieClip;
      
      private var m_checkMark_mc:MovieClip;
      
      private var m_dayChangeHasOccuredDuringOpenWindow:Boolean = false;
      
      private var m_featureEndMc:MovieClip;
      
      private var RANGE_ARRAY:Array = ["100-200","201-280","281-350"];
      
      private var m_avgTooltip:Array = new Array();
      
      private const SERVICE_NAME:String = "IsraelInnovationService";
      
      private var m_noOfWeek:int;
      
      private var m_consumablehitWidget:ZwFrame;
      
      private var m_farmOffChiphitWidget:ZwFrame;
      
      private var m_communityhitWidget:ZwFrame;
      
      private var m_weekBonushitWidget:ZwFrame;
      
      private var m_dailyProgresshitWidget:ZwFrame;
      
      private var m_leaderboardhitWidget:ZwFrame;
      
      private var m_dailyRewardhitWidget:ZwFrame;
      
      private var m_progressWidget:ZwFrame;
      
      private var m_taskFramehitWidget:ZwFrame;
      
      private var m_leaderboardRank_tf:ZwTextField;
      
      private var m_leaderboardPoints_tf:ZwTextField;
      
      private var m_leaderboardTimer_tf:ZwTextField;
      
      public function IsraelInnovationMainWindow(featureName:String = "IsraelInnovation", assetUrl:String = null, showEAPageTutorial:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_showTutorialWithEAPage = showEAPageTutorial;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ISRAEL))
         {
            this.m_noOfWeek = 5;
         }
         else
         {
            this.m_noOfWeek = 4;
         }
         super(FEATURE_NAME,assetUrl,numOfTutorialPages);
      }
      
      override protected function postLoadComplete() : void
      {
         var i:int = 0;
         var dayIndex:int = 0;
         var weekIndex:int = 0;
         var index:int = 0;
         var finalRewardItem:FarmItem = null;
         var isFirstWeekMileStoneAchieved:Boolean = false;
         var isSecondWeekMileStoneAchieved:Boolean = false;
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
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"The Great Farm-Off"));
         }
         if(m_window.hasOwnProperty("subtitle_tf"))
         {
            addWidget(new ZwTextField(m_window["subtitle_tf"],""));
            if(!Global.player.getSeenFlag(this.LEADERBOARD_PLAYING_FLAG))
            {
               m_window["subtitle_tf"].text = "Finish tasks to score points and improve your rank!";
            }
            else
            {
               m_window["subtitle_tf"].text = "Finish tasks to score points and move up the leaderboard!";
            }
            m_window["subtitle_tf"].visible = true;
         }
         if(m_window.hasOwnProperty("idle_ani_mc"))
         {
            this.m_idleNPC = m_window["idle_ani_mc"] as MovieClip;
         }
         if(m_window.hasOwnProperty("jump_ani_mc"))
         {
            this.m_jumpNPC = m_window["jump_ani_mc"] as MovieClip;
         }
         if(m_window.hasOwnProperty("inform_ani_mc"))
         {
            this.m_informNPC = m_window["inform_ani_mc"] as MovieClip;
         }
         if(m_window.hasOwnProperty("alert_ani_mc"))
         {
            this.m_alertNPC = m_window["alert_ani_mc"] as MovieClip;
         }
         if(m_window.hasOwnProperty("stomp_ani_mc"))
         {
            this.m_stompNPC = m_window["stomp_ani_mc"] as MovieClip;
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
         if(m_window.hasOwnProperty("highlightLB_mc"))
         {
            this.m_highlightLB_mc = m_window["highlightLB_mc"] as MovieClip;
            this.m_highlightLB_mc.visible = this.manager.getDayEndMessageShown();
         }
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ISRAEL) && !this.hasSeenFeatureWelcome())
         {
            Global.player.setSeenFlag(this.ISRAEL_INNOVATION_WELCOME_SEEN_FLAG);
            this.showAutoHideNPCCallouts("The Farm Off Beginneth!","Enjoy 40 free Bundles of Plenty and start at the ‘Grower’ rating all EA week!");
         }
         else if(!this.hasSeenFeatureWelcome())
         {
            Global.player.setSeenFlag(this.ISRAEL_INNOVATION_WELCOME_SEEN_FLAG);
            this.showAutoHideNPCCallouts("The Farm Off Beginneth!","The world’s greatest farming contest starts today. Prove your skills, help friends and beat challenges for fame and fortune!");
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
               this.m_consumablehitWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("Bundles of Plenty!","Collect Bundles of Plenty to move ahead in the competition."));
               this.m_consumablehitWidget.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
            }
         }
         if(m_window.hasOwnProperty("landbundle_mc"))
         {
            if(this.manager.isLandbundleActive() && !this.manager.isLandBundleUnlocked() && !Global.player.getSeenFlag(this.LAND_BUNDLE_OVERLAY))
            {
               m_window["landbundle_mc"].visible = true;
               Global.player.setSeenFlag(this.LAND_BUNDLE_OVERLAY);
            }
         }
         if(m_window.hasOwnProperty("lastDay_mc"))
         {
            this.m_featureEndMc = m_window["lastDay_mc"] as MovieClip;
            this.m_featureEndMc["title_tf"].text = "The Farm-Off is over!";
            this.m_featureEndMc["body_tf"].text = "Keep playing for leaderboard rewards";
            this.m_featureEndMc["body2_tf"].text = "Remember to use your Farm-Off chips before the Farm-Off ends!";
            this.m_featureEndMc["close_bt"].visible = false;
            new FarmAnimatedTextButton(this.m_featureEndMc["accept_bt"],"Okay",this.onFeatureEnd);
            this.m_featureEndMc.visible = this.manager.hasFeatureExpired();
         }
         if(m_window.hasOwnProperty(this.DAILY_COLLECT_MC))
         {
            this.m_daily_collect_mc = m_window[this.DAILY_COLLECT_MC] as MovieClip;
            this.m_daily_collect_mc.visible = true;
            if(this.m_daily_collect_mc.hasOwnProperty("daily_collect_tf"))
            {
               addWidget(this.m_dailyCollect_title_tf = new ZwTextField(this.m_daily_collect_mc["daily_collect_tf"],"Farm-Off Chips"));
               this.m_dailyCollect_title_tf.visible = true;
            }
            if(this.m_daily_collect_mc.hasOwnProperty("collect_count_tf"))
            {
               addWidget(this.m_dailyCollect_count_tf = new ZwTextField(this.m_daily_collect_mc["collect_count_tf"],"x" + this.manager.chipCount.toString()));
               this.m_dailyCollect_count_tf.visible = true;
            }
            if(this.m_daily_collect_mc.hasOwnProperty("redeem_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_daily_collect_mc["redeem_bt"],"Farm-Off Market",this.onMarketButtonClick));
            }
            if(this.m_daily_collect_mc.hasOwnProperty("bundle_bt") && this.manager.isLandbundleActive() && !this.manager.isLandBundleUnlocked())
            {
               addWidget(new FarmAnimatedTextButton(this.m_daily_collect_mc["bundle_bt"],"Get More",this.onBundleClick));
            }
            else
            {
               addWidget(new FarmAnimatedTextButton(this.m_daily_collect_mc["bundle_bt"]),false);
            }
            if(this.m_daily_collect_mc.hasOwnProperty("doober_mc"))
            {
               this.m_daily_dooberMc = this.m_daily_collect_mc["doober_mc"] as MovieClip;
               if(this.m_daily_dooberMc.hasOwnProperty("dooberIcon_mc"))
               {
                  this.m_daily_dooberIconMc = this.m_daily_dooberMc["dooberIcon_mc"];
                  if(this.m_daily_dooberIconMc.hasOwnProperty("dooberCount_tf"))
                  {
                     this.m_daily_dooberCountTf = new ZwTextField(this.m_daily_dooberIconMc["dooberCount_tf"]);
                  }
               }
            }
            if(this.m_daily_collect_mc.hasOwnProperty("hit_area_mc"))
            {
               this.m_farmOffChiphitWidget = new ZwFrame(this.m_daily_collect_mc["hit_area_mc"]);
               this.m_farmOffChiphitWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("Farm-Off Chips","Play the Great Farm-Off to earn Farm-Off Chips everyday and trade them for cool items in the Farm-Off market!"));
               this.m_farmOffChiphitWidget.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
            }
         }
         if(m_window.hasOwnProperty(this.COMMUNITY_MC))
         {
            this.m_community_mc = m_window[this.COMMUNITY_MC] as MovieClip;
            this.m_community_mc.visible = true;
            if(this.m_community_mc.hasOwnProperty("community_tf"))
            {
               addWidget(this.m_community_tf = new ZwTextField(this.m_community_mc["community_tf"],"COMMUNITY"));
               this.m_community_tf.visible = true;
            }
            if(this.m_community_mc.hasOwnProperty("community_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_community_mc["community_bt"],"OPEN",this.onCommunityButtonClick));
            }
            if(this.m_community_mc.hasOwnProperty("icon_mc"))
            {
               this.m_community_iconMc = new FarmIcon(this.m_community_mc["icon_mc"]);
               if(this.m_community_iconMc)
               {
                  this.m_community_iconMc.loadIcon("assets/dialogs/israel/innovation/icon_welcome.png");
                  this.m_community_iconMc.visible = true;
               }
            }
            if(this.m_community_mc.hasOwnProperty("hit_area_mc"))
            {
               this.m_communityhitWidget = new ZwFrame(this.m_community_mc["hit_area_mc"]);
               this.m_communityhitWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("Community challenges","See and track community challenge progress and rewards here."));
               this.m_communityhitWidget.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
            }
         }
         if(m_window.hasOwnProperty("week_bonus_mc"))
         {
            m_window["week_bonus_mc"].visible = true;
            addWidget(this.m_week_bonus_mc = new ZwFrame(m_window["week_bonus_mc"] as MovieClip),true);
            this.m_week_bonus_mc.attachTooltip(new FarmTextTooltip(this.TEXT_REWARD_HOVER[2]));
            this.m_weekBonushitWidget = new ZwFrame(m_window["week_bonus_mc"] as MovieClip);
            this.m_weekBonushitWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("Maxed out!","Finish all daily milestones this week and win 3 Farm-Off chips!"));
            this.m_weekBonushitWidget.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
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
         if(m_window.hasOwnProperty("weekly_tf"))
         {
            addWidget(new ZwTextField(m_window["weekly_tf"],"Weekly Score"));
         }
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ISRAEL))
         {
            if(m_window.hasOwnProperty(this.WEEKLY_COUNTER_MC))
            {
               this.m_weekly_counter_mc = m_window[this.WEEKLY_COUNTER_MC] as MovieClip;
               this.m_weekly_counter_mc.visible = true;
               this.m_weekArray_mc = [];
               this.m_weekArray_tf = [];
               this.m_weekCountArray_tf = [];
               for(i = 0; i < 5; i++)
               {
                  if(this.m_weekly_counter_mc.hasOwnProperty("week" + (i + 1).toString() + "_mc"))
                  {
                     this.m_weekArray_mc[i] = this.m_weekly_counter_mc["week" + (i + 1).toString() + "_mc"] as MovieClip;
                     this.m_weekArray_mc[i].visible = true;
                     if(this.m_weekArray_mc[i].hasOwnProperty("week_tf"))
                     {
                        this.m_weekArray_tf[i] = new ZwTextField(this.m_weekArray_mc[i]["week_tf"],this.m_week_tfArray[i]);
                        this.m_weekArray_tf[i].visible = true;
                     }
                  }
                  if(this.m_weekly_counter_mc.hasOwnProperty("count" + (i + 1).toString() + "_tf"))
                  {
                     addWidget(this.m_weekCountArray_tf[i] = new ZwTextField(this.m_weekly_counter_mc["count" + (i + 1).toString() + "_tf"]));
                  }
               }
            }
         }
         else if(m_window.hasOwnProperty(this.WEEKLY_COUNTER_GA_MC))
         {
            this.m_weekly_counter_mc = m_window[this.WEEKLY_COUNTER_GA_MC] as MovieClip;
            this.m_weekly_counter_mc.visible = true;
            this.m_weekArray_mc = [];
            this.m_weekArray_tf = [];
            this.m_weekCountArray_tf = [];
            for(i = 0; i < 4; i++)
            {
               if(this.m_weekly_counter_mc.hasOwnProperty("week" + (i + 1).toString() + "_mc"))
               {
                  this.m_weekArray_mc[i] = this.m_weekly_counter_mc["week" + (i + 1).toString() + "_mc"] as MovieClip;
                  this.m_weekArray_mc[i].visible = true;
                  if(this.m_weekArray_mc[i].hasOwnProperty("week_tf"))
                  {
                     this.m_weekArray_tf[i] = new ZwTextField(this.m_weekArray_mc[i]["week_tf"],this.m_week_tfArray[i]);
                     this.m_weekArray_tf[i].visible = true;
                  }
               }
               if(this.m_weekly_counter_mc.hasOwnProperty("count" + (i + 1).toString() + "_tf"))
               {
                  addWidget(this.m_weekCountArray_tf[i] = new ZwTextField(this.m_weekly_counter_mc["count" + (i + 1).toString() + "_tf"]));
               }
            }
         }
         if(m_window.hasOwnProperty("week_score_tf"))
         {
            addWidget(this.m_week_tf = new ZwTextField(m_window["week_score_tf"],"Your week\'s score is: " + this.manager.getWeekPoints().toString()));
            this.m_week_tf.visible = true;
         }
         if(m_window.hasOwnProperty(this.WEEKLY_PROGRESS_MC))
         {
            this.m_weekly_progress_mc = m_window[this.WEEKLY_PROGRESS_MC] as MovieClip;
            this.m_weekly_progress_mc.visible = true;
            this.m_barMc = this.m_weekly_progress_mc["bar_fill_mc"] as MovieClip;
            this.m_barMc.visible = true;
            this.initializeWeeklyMeter();
         }
         var leaderBoardData:Object = this.manager.getCurrentLeaderboard();
         var weekCount:int = int(leaderBoardData.count);
         if(m_window.hasOwnProperty(this.LEADERBOARD_MC))
         {
            this.m_leaderboard_mc = m_window[this.LEADERBOARD_MC] as MovieClip;
            this.m_leaderboard_mc.visible = true;
            addWidget(this.m_leaderboardButton = new FarmAnimatedTextButton(this.m_leaderboard_mc[this.LEADERBOARD_BT],"View",this.onClickLeaderboardButton));
            this.m_leaderboardButton.enabled = true;
            if(this.m_leaderboard_mc.hasOwnProperty("hit_area_mc"))
            {
               this.m_leaderboardhitWidget = new ZwFrame(this.m_leaderboard_mc["hit_area_mc"]);
               this.m_leaderboardhitWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("Compete in Leaderboard","See your Leaderboard rank by clicking on ‘View’"));
               this.m_leaderboardhitWidget.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
            }
            if(this.m_leaderboard_mc.hasOwnProperty("icon_mc"))
            {
               this.m_leaderboardIconMc = this.m_leaderboard_mc.icon_mc;
               this.m_leaderboardIconMc.gotoAndStop(weekCount);
            }
            addWidget(this.m_leaderboardPoints_tf = new ZwTextField(m_window[this.LEADERBOARD_MC]["points_tf"]));
            if(this.manager.getWeeklyRewardPoints() >= 0)
            {
               this.m_leaderboardPoints_tf.text = "Points:" + this.manager.getWeeklyRewardPoints().toString();
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
         if(m_window.hasOwnProperty("firstSessionStart_mc"))
         {
            this.m_firstStartSessionMC = m_window["firstSessionStart_mc"] as MovieClip;
            this.m_firstStartSessionMC.visible = false;
         }
         if(m_window.hasOwnProperty(this.PROGRESS_RECORDS_COUNTER))
         {
            this.m_progress_record_mc = m_window[this.PROGRESS_RECORDS_COUNTER] as MovieClip;
            this.m_progress_record_mc.visible = true;
            dayIndex = this.manager.activeDayIndex;
            weekIndex = dayIndex / 7;
            for(index = 0; index < 7; index++)
            {
               this.m_progress_record_array[index] = this.m_progress_record_mc["day_" + index.toString() + "_mc"];
               if(this.m_progress_record_array[index].hasOwnProperty("session_mc"))
               {
                  if(weekIndex * 7 + index == dayIndex)
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
            if(this.m_progress_record_mc.hasOwnProperty("EA_mc"))
            {
               if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ISRAEL) == true && this.manager.currentDayIndex < 7)
               {
                  this.m_progress_record_mc["EA_mc"].visible = true;
               }
               else
               {
                  this.m_progress_record_mc["EA_mc"].visible = false;
               }
            }
            if(this.m_progress_record_mc.hasOwnProperty("hit_area_mc"))
            {
               this.m_progressWidget = new ZwFrame(this.m_progress_record_mc["hit_area_mc"]);
               this.m_progressWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("Track your scores","Your final Farm-Off grade is calculated based on your weekly scores."));
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
               this.m_avg_points_info = new ZwTextField(this.m_levels_mc["avg_points_tf"],"Week Average : " + this.manager.currentAverage.toString());
               this.m_avg_points_info.visible = true;
            }
         }
         if(m_window.hasOwnProperty(this.DAILY_PROGRESS_MC))
         {
            this.m_daily_progress_mc = m_window[this.DAILY_PROGRESS_MC] as MovieClip;
            this.m_daily_progress_mc.visible = true;
            if(this.m_daily_progress_mc.hasOwnProperty("fill_mc"))
            {
               this.m_fillMc = this.m_daily_progress_mc["fill_mc"] as MovieClip;
            }
            if(this.m_daily_progress_mc.hasOwnProperty("highlight_mc"))
            {
               this.m_highlight_mc = this.m_daily_progress_mc["highlight_mc"] as MovieClip;
               this.m_highlight_mc.visible = this.manager.getUserState() == this.manager.DONE_FOR_THE_DAY;
            }
         }
         if(m_window.hasOwnProperty("daily_hit_area_mc"))
         {
            addWidget(this.m_dailyProgresshitWidget = new ZwFrame(m_window["daily_hit_area_mc"]),true);
            this.m_dailyProgresshitWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("Today’s Score!","This meter shows your score for the day."));
            this.m_dailyProgresshitWidget.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
         }
         if(m_window.hasOwnProperty(this.FINISH_BODY_TF))
         {
            addWidget(this.m_finishBody = new ZwTextField(m_window[this.FINISH_BODY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_FINISH_BODY)));
         }
         if(m_window.hasOwnProperty("daily_meter_tf"))
         {
            addWidget(m_window["daily_meter_tf"] = new ZwTextField(m_window["daily_meter_tf"],"FARM-OFF METER"));
            m_window["daily_meter_tf"].visible = true;
         }
         if(m_window.hasOwnProperty("feature_progress_full_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["feature_progress_full_bt"],"View Rewards",this.onProgressButtonClick));
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
            addWidget(this.m_overlayUnlock_bt = new FarmAnimatedTextButton(this.m_tileUnlock_mc["overlay_bt"],"Cool",this.onCloseOverlay));
            this.m_overlay_tf = new ZwTextField(this.m_tileUnlock_mc["overlay_tf"],"");
         }
         if(m_window.hasOwnProperty(this.FEATURE_TIMER_MC))
         {
            this.m_featureTimer_mc = m_window[this.FEATURE_TIMER_MC] as MovieClip;
            this.m_featureTimer_mc.visible = true;
            if(this.m_featureTimer_mc.hasOwnProperty(this.FEATURE_TIMER_TF))
            {
               this.m_FeatureTimer = new ZwTextField(this.m_featureTimer_mc[this.FEATURE_TIMER_TF],"");
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
            this.m_taskFrame = new IsraelInnovationTaskFrame(m_window[this.TASKS_MC],this,this.m_featureName);
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
               this.m_preview_mcArray[previewIndex].registerEventListener(MouseEvent.MOUSE_OVER,this.onOver1(previewIndex));
               this.m_preview_mcArray[previewIndex].registerEventListener(MouseEvent.MOUSE_OUT,this.onOut1(previewIndex));
            }
         }
         if(m_window.hasOwnProperty("week_preview1_mc"))
         {
            addWidget(this.m_week_preview1_mc = new ZwFrame(m_window["week_preview1_mc"]),true);
            this.m_week_preview1_mc.registerEventListener(MouseEvent.MOUSE_OVER,this.onOver2);
            this.m_week_preview1_mc.registerEventListener(MouseEvent.MOUSE_OUT,this.onOut2);
            isFirstWeekMileStoneAchieved = this.manager.isWeeklyMilestoneAchievedForLevel(0);
            if(isFirstWeekMileStoneAchieved == false)
            {
            }
         }
         if(m_window.hasOwnProperty("week_preview2_mc"))
         {
            addWidget(this.m_week_preview2_mc = new ZwFrame(m_window["week_preview2_mc"]),true);
            this.m_week_preview2_mc.registerEventListener(MouseEvent.MOUSE_OVER,this.onOver3);
            this.m_week_preview2_mc.registerEventListener(MouseEvent.MOUSE_OUT,this.onOut3);
            isSecondWeekMileStoneAchieved = this.manager.isWeeklyMilestoneAchievedForLevel(1);
            if(isSecondWeekMileStoneAchieved == false)
            {
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
            this.m_rewardIconMcArray[mileStoneRewardIndex] = new FarmIcon(this.m_reward_mcArray[mileStoneRewardIndex]["icon_70_mc"],this.manager.chipItem.iconUrl);
            this.m_rewardIconMcArray[mileStoneRewardIndex].setIconSize(70,70);
            this.m_rewardIconMcArray[mileStoneRewardIndex].setSmoothing(true);
         }
         if(m_window.hasOwnProperty("week_reward1_mc"))
         {
            this.m_week_reward1_mc = m_window["week_reward1_mc"] as MovieClip;
            this.m_week_reward1_tick_mc = this.m_week_reward1_mc[this.TICK_MC] as MovieClip;
            this.m_week_reward1_icon_mc = new FarmIcon(this.m_week_reward1_mc["icon_70_mc"]);
            this.m_week_reward1_icon_mc.loadIcon(this.manager.getActiveDayReward(0).iconUrl);
            this.m_week_reward1_icon_mc.setIconSize(70,70);
            this.m_week_reward1_icon_mc.setSmoothing(true);
         }
         if(m_window.hasOwnProperty("week_reward2_mc"))
         {
            this.m_week_reward2_mc = m_window["week_reward2_mc"] as MovieClip;
            this.m_week_reward2_tick_mc = this.m_week_reward2_mc[this.TICK_MC] as MovieClip;
            this.m_week_reward2_icon_mc = new FarmIcon(this.m_week_reward2_mc["icon_70_mc"]);
            this.m_week_reward2_icon_mc.loadIcon(this.manager.getActiveDayReward(1).iconUrl);
            this.m_week_reward2_icon_mc.setIconSize(70,70);
            this.m_week_reward2_icon_mc.setSmoothing(true);
         }
         if(m_window.hasOwnProperty("week_reward_mc"))
         {
            this.m_weeklyReward_mc = m_window["week_reward_mc"] as MovieClip;
            this.m_weeklyReward_mc.visible = true;
            if(this.m_weeklyReward_mc.hasOwnProperty("checkmark_mc"))
            {
               this.m_weeklyCheckmark_mc = this.m_weeklyReward_mc["checkmark_mc"] as MovieClip;
               this.m_weeklyCheckmark_mc.visible = this.manager.isWeeklyMilestoneAchievedForLevel(2);
            }
         }
         if(m_window.hasOwnProperty("level_lock1_hover"))
         {
            this.m_lock1Hover = m_window["level_lock1_hover"] as MovieClip;
            this.m_lock1Hover.visible = false;
            this.m_lock1HoverText = new ZwTextField(this.m_lock1Hover["info1_tf"],"To Unlock Exporter Level Exchange 5");
         }
         if(m_window.hasOwnProperty("level_lock2_hover"))
         {
            this.m_lock2Hover = m_window["level_lock2_hover"] as MovieClip;
            this.m_lock2Hover.visible = false;
            this.m_lock2HoverText = new ZwTextField(this.m_lock2Hover["info1_tf"],"To Unlock Tycoon Level Exchange 10");
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
         if(Global.player.getSeenFlag(this.manager.TILE_UNLOCK))
         {
            if(!Global.player.getSeenFlag(this.manager.FIRST_TIME_UNLOCK))
            {
               Global.player.setSeenFlag(this.manager.FIRST_TIME_UNLOCK);
               this.forcedNPCCallouts();
            }
         }
         if(this.manager.isLandBundleUnlocked() == true && this.manager.isLandBundleRewardGranted() == false)
         {
            this.manager.grantLandBundleReward();
            this.playJumpAnimation();
            this.manager.showAutoHideNPCCallouts("Oasis Row is open!","Congratulations! You’ve been awarded 20 Farm-Off Chips for your purchase of Oasis Row!");
         }
         if(this.manager.hasActiveDayExpired())
         {
            if(this.manager.isDailyResetDone())
            {
               this.manager.resetDailyChipStatus();
            }
         }
         this.updateWeeklyRewardGrantDateArray();
         var userData:Object = this.manager.getUserDataFromLeaderboard();
         var rewardPoints:int = this.manager.getWeeklyRewardPoints();
         this.updateDayBonus();
         this.refreshTaskFrame();
         this.updateProgressCircle(true);
         this.updateWeeklyTable();
         this.updateFarmOffChipCount();
         this.updateConsumableCount();
         this.updateWeeklyMeter();
         this.startTimer();
         this.updateSmallProgressCircles();
         this.updateProgressCircle(true);
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
         if(this.m_leaderboardPoints_tf)
         {
            this.m_leaderboardPoints_tf.text = "Points:" + points.toString();
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
      
      public function listenForJumpAnimationEnd(e:Event = null) : void
      {
         if(this.m_jumpNPC.currentFrame == 120)
         {
            this.m_jumpNPC.stop();
            this.m_jumpNPC.visible = false;
            this.playStompingAnimation();
         }
      }
      
      public function listenForStompAnimationEnd(e:Event = null) : void
      {
         if(this.m_stompNPC.currentFrame == 120)
         {
            this.m_stompNPC.stop();
            this.m_stompNPC.visible = false;
         }
      }
      
      public function listenForInformAnimationEnd(e:Event = null) : void
      {
         if(this.m_informNPC.currentFrame == 220)
         {
            this.m_informNPC.stop();
            this.m_informNPC.visible = false;
            this.m_idleNPC.visible = true;
         }
      }
      
      public function listenForAlertAnimationEnd(e:Event = null) : void
      {
         if(this.m_alertNPC.currentFrame == 200)
         {
            this.m_alertNPC.stop();
            this.m_alertNPC.visible = false;
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
         this.m_informNPC.visible = false;
         this.m_alertNPC.visible = false;
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
         this.m_jumpNPC.addEventListener(Event.ENTER_FRAME,this.listenForJumpAnimationEnd,false,0,true);
      }
      
      public function playStompingAnimation() : void
      {
         var child:MovieClip = null;
         var grandChildIndex:int = 0;
         var grandChild:MovieClip = null;
         this.m_idleNPC.visible = false;
         this.m_jumpNPC.visible = false;
         this.m_informNPC.visible = false;
         this.m_alertNPC.visible = false;
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
         this.m_stompNPC.gotoAndPlay(0);
         this.m_stompNPC.addEventListener(Event.ENTER_FRAME,this.listenForStompAnimationEnd,false,0,true);
      }
      
      public function playInformAnimation() : void
      {
         var child:MovieClip = null;
         var grandChildIndex:int = 0;
         var grandChild:MovieClip = null;
         this.m_idleNPC.visible = false;
         this.m_jumpNPC.visible = false;
         this.m_stompNPC.visible = false;
         this.m_alertNPC.visible = false;
         this.m_informNPC.visible = true;
         for(var childIndex:int = 1; childIndex < this.m_informNPC.numChildren; childIndex++)
         {
            child = this.m_informNPC.getChildAt(childIndex) as MovieClip;
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
         this.m_informNPC.play();
         this.m_informNPC.addEventListener(Event.ENTER_FRAME,this.listenForInformAnimationEnd,false,0,true);
      }
      
      public function playAlertAnimation() : void
      {
         var child:MovieClip = null;
         var grandChildIndex:int = 0;
         var grandChild:MovieClip = null;
         this.m_idleNPC.visible = false;
         this.m_jumpNPC.visible = false;
         this.m_stompNPC.visible = false;
         this.m_informNPC.visible = false;
         this.m_alertNPC.visible = true;
         for(var childIndex:int = 1; childIndex < this.m_alertNPC.numChildren; childIndex++)
         {
            child = this.m_alertNPC.getChildAt(childIndex) as MovieClip;
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
         this.m_alertNPC.play();
         this.m_alertNPC.addEventListener(Event.ENTER_FRAME,this.listenForAlertAnimationEnd,false,0,true);
      }
      
      public function updateSmallProgressCircles() : void
      {
         var curDayInd:int = 0;
         var dayPoints:int = 0;
         var barAngle:Number = 0;
         var dayInd:int = this.manager.activeDayIndex;
         var weekInd:int = dayInd / 7;
         for(var index:int = 0; index < 7; index++)
         {
            curDayInd = weekInd * 7 + index;
            dayPoints = this.manager.getpointsForTheDay(curDayInd);
            if(dayPoints > this.manager.VAL_THIRD_MILESTONE)
            {
               dayPoints = this.manager.VAL_THIRD_MILESTONE;
            }
            barAngle = dayPoints * this.PROGRESS_BAR_FULL_ANGLE / this.DAILY_DUMMY_MAX_POINT;
            if(this.m_progress_record_array[index].fill_mc)
            {
               this.m_progress_record_array[index].fill_mc.rotation = barAngle;
               if(dayPoints <= 0)
               {
                  this.m_progress_record_array[index].left_mc.visible = true;
                  this.m_progress_record_array[index].right_mc.visible = false;
               }
               else if(dayPoints >= 25)
               {
                  this.m_progress_record_array[index].left_mc.visible = false;
                  this.m_progress_record_array[index].right_mc.visible = true;
               }
               else if(dayPoints > 0)
               {
                  this.m_progress_record_array[index].left_mc.visible = true;
                  this.m_progress_record_array[index].right_mc.visible = false;
               }
            }
         }
      }
      
      public function updateCurrentdaySmallCircle() : void
      {
         var index:int = this.manager.activeDayIndex % 7;
         var dayPoints:int = this.manager.getDayPoints();
         if(dayPoints > this.manager.VAL_THIRD_MILESTONE)
         {
            dayPoints = this.manager.VAL_THIRD_MILESTONE;
         }
         var barAngle:Number = dayPoints * this.PROGRESS_BAR_FULL_ANGLE / this.DAILY_DUMMY_MAX_POINT;
         if(this.m_progress_record_array[index].fill_mc)
         {
            this.m_progress_record_array[index].fill_mc.rotation = barAngle;
            if(dayPoints <= 0)
            {
               this.m_progress_record_array[index].left_mc.visible = true;
               this.m_progress_record_array[index].right_mc.visible = false;
            }
            else if(dayPoints >= 25)
            {
               this.m_progress_record_array[index].left_mc.visible = false;
               this.m_progress_record_array[index].right_mc.visible = true;
            }
            else if(dayPoints > 0)
            {
               this.m_progress_record_array[index].left_mc.visible = true;
               this.m_progress_record_array[index].right_mc.visible = false;
            }
         }
         this.m_avg_points_info.text = "Week Average : " + this.manager.currentAverage.toString();
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
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ISRAEL) == true)
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
      
      public function onCraftButtonClick(e:Event) : void
      {
         this.manager.craftConsumableFromMainWindow();
      }
      
      private function collectChip(e:Event) : void
      {
         this.manager.collectFarmOffChip();
         if(this.manager.getUserState() == this.manager.NOT_INITIALIZED)
         {
            this.displayFeatureStartMessage();
         }
         else
         {
            this.displayDayStartMessage();
         }
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
      
      private function onMarketButtonClick(e:Event) : void
      {
         this.manager.openRewardMarketWindow();
      }
      
      private function onBundleClick(e:Event) : void
      {
         this.manager.openLandBundleBWindow();
      }
      
      private function onCommunityButtonClick(e:Event) : void
      {
         this.manager.openCommunityGoalsWindow();
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
      
      public function updateFarmOffChipCount() : void
      {
         if(this.m_daily_collect_mc.hasOwnProperty("collect_count_tf"))
         {
            this.m_dailyCollect_count_tf.text = "x" + this.manager.chipCount.toString();
            this.m_dailyCollect_count_tf.visible = true;
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
      
      public function updateWeeklyTable() : void
      {
         var j:int = 0;
         var k:int = 0;
         var dayPoints:int = this.manager.getDayPoints();
         var weekPoints:int = this.manager.getWeekPoints();
         var activeInd:int = this.manager.activeDayIndex;
         var activeWeekInd:int = activeInd / 7;
         var weekInd:int = activeWeekInd;
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ISRAEL) == false && this.manager.isGAPlayer() == true)
         {
            weekInd--;
         }
         if(this.m_weekArray_mc[weekInd])
         {
            this.m_weekArray_mc[weekInd].visible = true;
            for(j = 0; j < weekInd; j++)
            {
               this.m_weekCountArray_tf[j].text = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ISRAEL) == true ? this.manager.getPointsForTheWeek(j).toString() : this.manager.getPointsForTheWeek(j + 1).toString();
               this.m_weekCountArray_tf[j].visible = true;
               this.m_weekArray_mc[j].gotoAndStop(1);
            }
            if(weekInd < this.m_noOfWeek)
            {
               this.m_weekCountArray_tf[weekInd].text = weekPoints.toString();
               this.m_weekCountArray_tf[weekInd].visible = true;
               this.m_weekArray_mc[weekInd].gotoAndStop(2);
            }
            for(k = weekInd + 1; k < this.m_noOfWeek; k++)
            {
               this.m_weekCountArray_tf[k].visible = false;
               this.m_weekArray_mc[k].gotoAndStop(3);
            }
         }
         this.updateCurrentWeekTable();
      }
      
      public function updateCurrentWeekTable() : void
      {
         var weekPoints:int = this.manager.getWeekPoints();
         var activeInd:int = this.manager.activeDayIndex;
         var activeWeekInd:int = activeInd / 7;
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ISRAEL) == false && this.manager.isGAPlayer() == true)
         {
            activeWeekInd--;
         }
         if(this.m_weekArray_mc[activeWeekInd])
         {
            this.m_weekArray_mc[activeWeekInd].visible = true;
            if(this.m_weekArray_mc[activeWeekInd].hasOwnProperty("count_tf"))
            {
               if(activeWeekInd < 5)
               {
                  this.m_weekArray_mc[activeWeekInd].gotoAndStop(2);
               }
            }
         }
         if(this.m_weekCountArray_tf[activeWeekInd])
         {
            this.m_weekCountArray_tf[activeWeekInd].text = weekPoints.toString();
            this.m_weekCountArray_tf[activeWeekInd].visible = true;
         }
      }
      
      public function updateProgressCircle(onOpenWindow:Boolean = false) : void
      {
         var dayPoints:int = this.manager.getDayPoints();
         var weekPoints:int = this.manager.getWeekPoints();
         var activeInd:int = this.manager.activeDayIndex;
         var activeWeekInd:int = activeInd / 7;
         if(dayPoints > this.manager.VAL_THIRD_MILESTONE)
         {
            dayPoints = this.manager.VAL_THIRD_MILESTONE;
         }
         if(m_window[this.POINTS_TF])
         {
            (m_window[this.POINTS_TF] as TextField).text = int(dayPoints).toString();
            m_window[this.POINTS_TF].visible = true;
         }
         var barAngle:Number = dayPoints * this.PROGRESS_BAR_FULL_ANGLE / this.DAILY_DUMMY_MAX_POINT;
         if(this.m_fillMc)
         {
            this.m_fillMc.rotation = barAngle;
            if(dayPoints <= 0)
            {
               this.m_daily_progress_mc.left_mc.visible = true;
               this.m_daily_progress_mc.right_mc.visible = false;
            }
            else if(dayPoints >= 25)
            {
               this.m_daily_progress_mc.left_mc.visible = false;
               this.m_daily_progress_mc.right_mc.visible = true;
            }
            else if(dayPoints > 0)
            {
               this.m_daily_progress_mc.left_mc.visible = true;
               this.m_daily_progress_mc.right_mc.visible = false;
            }
         }
         this.updateCurrentdaySmallCircle();
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
      
      public function updateFarmOffChipDoober(quantity:int = 0) : void
      {
         if(this.m_daily_dooberMc)
         {
            this.m_daily_dooberMc.visible = true;
            if(this.m_daily_dooberCountTf)
            {
               this.m_daily_dooberCountTf.text = "+" + int(quantity).toString();
            }
            this.m_daily_dooberMc.gotoAndPlay(2);
         }
      }
      
      public function initializeWeeklyMeter() : void
      {
         var weekPoints:int = 0;
         var barWidth:Number = weekPoints * this.PROGRESS_BAR_FULL_WIDTH / this.MAX_POINT;
         if(this.m_barMc)
         {
            if(weekPoints == 0)
            {
               this.m_barMc.width = barWidth;
            }
         }
      }
      
      public function updateWeeklyMeter() : void
      {
         var weekPoints:int = this.manager.getWeekPoints();
         if(weekPoints > this.manager.VAL_WEEK_FINAL_MILESTONE)
         {
            weekPoints = this.manager.VAL_WEEK_FINAL_MILESTONE;
         }
         var barWidth:Number = weekPoints * this.PROGRESS_BAR_FULL_WIDTH / this.MAX_POINT;
         if(this.m_barMc)
         {
            if(weekPoints == 0)
            {
               this.m_barMc.width = barWidth;
            }
            else
            {
               TweenMax.to(this.m_barMc,2,{"width":barWidth});
            }
         }
         this.m_weeklyCheckmark_mc.visible = this.manager.isWeeklyMilestoneAchievedForLevel(2);
         if(m_window["week_score_tf"])
         {
            this.m_week_tf.text = "Your week\'s score is: " + int(weekPoints).toString();
            this.m_week_tf.visible = true;
         }
      }
      
      public function refreshTaskFrame(e:Event = null) : void
      {
         var firstTimeFeatureAccess:Boolean = false;
         var redeemPreviousDayTask:Boolean = false;
         if(this.manager.getUserState() == this.manager.NOT_INITIALIZED)
         {
            if(this.manager.isDailyChipGranted() == false)
            {
               this.displayCollectChipMessage();
            }
            else
            {
               this.displayFeatureStartMessage();
            }
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
               if(this.manager.isDailyChipGranted() == false)
               {
                  this.displayCollectChipMessage();
               }
               else
               {
                  this.displayDayStartMessage();
               }
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
            this.m_highlight_mc.visible = true;
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
      
      public function displayCollectChipMessage() : void
      {
         this.m_highlightLB_mc.visible = false;
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageOkay.enabled = true;
         this.m_messageOkay.visible = true;
         this.m_messageTicket_mc.visible = false;
         this.m_messageOkay.text = "Collect";
         this.m_messageOkay.callback = this.collectChip;
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.visible = false;
         }
         var rewardItem:FarmItem = this.manager.chipItem;
         this.loadMessageIcon(rewardItem);
         this.m_messageTitle.text = "You got a Farm-Off Chip!";
         this.m_messageInfo1.text = "Use you Farm-off Chips for cool rewards!";
         this.m_messageInfo2.text = "Get a free chip everyday!";
      }
      
      public function displayLock1Message() : void
      {
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageOkay.visible = true;
         this.m_messageCash.visible = true;
         this.m_messageTicket_mc.visible = true;
         this.m_messageOkay.text = "Use";
         this.m_messageOkay.callback = this.onSinkButtonClick;
         this.m_messageTitle.text = "Congratulations";
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.visible = false;
         }
         var rewardItem:FarmItem = this.manager.chipItem;
         this.loadMessageIcon(rewardItem);
         this.m_messageInfo1.text = "1st milestone hit! You win 1 Farm-Off Chip!";
         this.m_messageInfo2.text = "Use the needed  Bundles of Plenty to start the next tier";
         this.m_messageCash.text = "5";
      }
      
      public function displayLock2Message() : void
      {
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageOkay.visible = true;
         this.m_messageCash.visible = true;
         this.m_messageTicket_mc.visible = true;
         this.m_messageOkay.text = "Use";
         this.m_messageOkay.callback = this.onSinkButtonClick;
         this.m_messageTitle.text = "Congratulations";
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.visible = false;
         }
         var rewardItem:FarmItem = this.manager.chipItem;
         this.loadMessageIcon(rewardItem);
         this.m_messageInfo1.text = "2nd milestone hit! You win 1 Farm-Off Chip!";
         this.m_messageInfo2.text = "Use the needed  Bundles of Plenty to start the next tier";
         this.m_messageCash.text = "10";
      }
      
      public function displayWelcomeBackMessage() : void
      {
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageTitle.text = "Congratulations";
         this.m_messageOkay.visible = true;
         this.m_messageOkay.text = "Okay";
         this.m_messageOkay.callback = this.getOldTasksRedeemedFromUser;
         this.m_messageTicket_mc.visible = false;
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.loadIcon("assets/dialogs/israel/innovation/icon_welcome.png");
            itemBox.visible = true;
         }
         this.m_messageInfo1.text = "You’ve proven yourself worthy of a higher rank!";
         this.m_messageInfo2.text = "Use Bundles of Plenty to enroll for the next tier of the contest";
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
            this.m_featureEndMc["title_tf"].text = "The Farm-Off is over!";
            this.m_featureEndMc["body_tf"].text = "Keep playing for leaderboard rewards";
            this.m_featureEndMc["body2_tf"].text = "Remember to use your Farm-Off chips before the Farm-Off ends!";
            this.m_featureEndMc["close_bt"].visible = false;
            new FarmAnimatedTextButton(this.m_featureEndMc["accept_bt"],"Okay",this.onFeatureEnd);
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
            itemBox.visible = false;
         }
         var rewardItem:FarmItem = this.manager.chipItem;
         this.loadMessageIcon(rewardItem);
         this.m_messageInfo1.text = "All daily challenges completed. You win 1 Farm-Off Chip";
         this.m_messageInfo2.text = "Keep scoring points to rank better on the leaderboard!";
         this.m_messageOkay.callback = this.playForLeaderBoardHelper;
      }
      
      public function playForLeaderBoardHelper(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(this.LEADERBOARD_PLAYING_FLAG))
         {
            Global.player.setSeenFlag(this.LEADERBOARD_PLAYING_FLAG);
         }
         this.playJumpAnimation();
         m_window["subtitle_tf"].text = "Finish tasks to score points and move up the leaderboard!";
         this.m_highlightLB_mc.visible = true;
         this.m_talkMc.visible = false;
         this.m_message_mc.visible = false;
         this.m_taskFrame.visible = true;
         this.m_messageOkay.visible = false;
         this.m_messageOkay.enabled = false;
         this.manager.playForLeaderBoard();
      }
      
      public function displayDayStartMessage() : void
      {
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
            itemBox.loadIcon("assets/dialogs/israel/innovation/icon_welcome.png");
            itemBox.visible = true;
         }
         if(this.manager.getUserState() == this.manager.DONE_FOR_THE_DAY)
         {
            this.m_messageTitle.text = "A NEW DAY BEGINNETH";
            this.m_messageInfo1.text = "Fill the Farm-Off meter to improve your rank";
         }
         else
         {
            this.m_messageTitle.text = "A NEW DAY BEGINNETH";
            this.m_messageInfo1.text = "Fill the Farm-Off meter to improve your rank";
         }
         this.m_messageInfo2.text = "Cool rewards will be yours, good luck!";
      }
      
      public function displayFeatureStartMessage() : void
      {
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageOkay.visible = true;
         this.m_messageTicket_mc.visible = false;
         this.m_messageOkay.callback = this.manager.startNewDay;
         this.m_messageOkay.text = "Start Now";
         this.m_messageTitle.text = "A NEW DAY BEGINNETH";
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.loadIcon("assets/dialogs/israel/innovation/icon_welcome.png");
            itemBox.visible = true;
         }
         this.m_messageInfo1.text = "Fill the Farm-Off meter to improve your rank";
         this.m_messageInfo2.text = "Farm hard, good luck!";
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
      
      public function displayFarmOffOverlay() : void
      {
         if(this.m_featureEndMc)
         {
            if(this.manager.isLastDay() == true && Global.player.getSeenFlag(this.LAST_DAY_ENTERED) == false)
            {
               this.m_featureEndMc["title_tf"].text = "The Farm-Off ends soon";
               this.m_featureEndMc["body_tf"].text = "Finish tasks and earn points for the grand prize!";
               this.m_featureEndMc["body2_tf"].text = "Remember to use your Farm-Off chips before the Farm-Off ends!";
               this.m_featureEndMc["close_bt"].visible = false;
               new FarmAnimatedTextButton(this.m_featureEndMc["accept_bt"],"Okay",this.onFeatureEnd);
               this.m_featureEndMc.visible = true;
               Global.player.setSeenFlag(this.LAST_DAY_ENTERED);
            }
         }
      }
      
      override public function refreshWindow() : void
      {
         this.m_checkMark_mc.visible = false;
         this.m_highlight_mc.visible = false;
         this.m_consumableCount_tf.text = "x" + this.manager.consumableCount.toString();
         this.refreshTaskFrame();
         this.updateProgressCircle();
         this.updateWeeklyTable();
         this.updateSmallProgressCircles();
         this.updateProgressCircle();
         this.updateWeeklyMeter();
         this.updateActiveDayIndex();
         this.updateDayBonus();
         this.updateFarmOffChipCount();
         if(this.manager.hasFeatureExpired())
         {
            this.m_featureEndMc.visible = true;
         }
      }
      
      public function updateDayBonus() : void
      {
         var finalMileStoneItem:FarmItem = null;
         if(this.m_weeklyReward_mc.hasOwnProperty("icon_70_mc"))
         {
            this.m_dailyReward_mc = this.m_weeklyReward_mc["icon_70_mc"] as MovieClip;
            if(this.m_isIconPreviewAdded == true)
            {
               removeWidget(this.m_iconPreview);
               this.m_iconPreview.detachTooltip();
            }
            finalMileStoneItem = this.manager.getActiveDayReward(2);
            if(finalMileStoneItem)
            {
               addWidget(this.m_iconPreview = new ObjectPreviewFrame(this.m_weeklyReward_mc["icon_70_mc"] as MovieClip,finalMileStoneItem,null,null,[70]),true);
               this.m_iconPreview.attachTooltip(new FarmTextTooltip(finalMileStoneItem.friendlyTitle));
               this.m_isIconPreviewAdded = true;
               this.m_dailyRewardhitWidget = new ZwFrame(this.m_weeklyReward_mc["icon_70_mc"] as MovieClip);
               this.m_dailyRewardhitWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver("Weekly Bonus!","Get 300 points this week to bag this exclusive " + finalMileStoneItem.friendlyTitle + "!"));
               this.m_dailyRewardhitWidget.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
            }
         }
         if(this.m_week_reward1_icon_mc)
         {
            (this.m_week_reward1_icon_mc as FarmIcon).release();
            this.m_week_reward1_icon_mc = new FarmIcon(this.m_week_reward1_mc["icon_70_mc"]);
            this.m_week_reward1_icon_mc.loadIcon(this.manager.getActiveDayReward(0).iconUrl);
            this.m_week_reward1_icon_mc.setIconSize(70,70);
            this.m_week_reward1_icon_mc.setSmoothing(true);
         }
         if(this.m_week_reward2_icon_mc)
         {
            (this.m_week_reward2_icon_mc as FarmIcon).release();
            this.m_week_reward2_icon_mc = new FarmIcon(this.m_week_reward2_mc["icon_70_mc"]);
            this.m_week_reward2_icon_mc.loadIcon(this.manager.getActiveDayReward(1).iconUrl);
            this.m_week_reward2_icon_mc.setIconSize(70,70);
            this.m_week_reward2_icon_mc.setSmoothing(true);
         }
         for(var mileStoneRewardIndex:int = 0; mileStoneRewardIndex < 3; mileStoneRewardIndex++)
         {
            if(this.m_rewardIconMcArray[mileStoneRewardIndex])
            {
               (this.m_rewardIconMcArray[mileStoneRewardIndex] as FarmIcon).release();
               this.m_rewardIconMcArray[mileStoneRewardIndex] = new FarmIcon(this.m_reward_mcArray[mileStoneRewardIndex]["icon_70_mc"],this.manager.chipItem.iconUrl);
               this.m_rewardIconMcArray[mileStoneRewardIndex].setIconSize(70,70);
               this.m_rewardIconMcArray[mileStoneRewardIndex].setSmoothing(true);
            }
         }
      }
      
      public function updateActiveDayIndex() : void
      {
         if(this.m_session_mc)
         {
            this.m_session_mc.visible = false;
         }
         var dayInd:int = this.manager.activeDayIndex;
         var weekInd:int = dayInd / 7;
         for(var index:int = 0; index < 7; index++)
         {
            if(this.m_progress_record_array[index].hasOwnProperty("session_mc"))
            {
               if(dayInd == weekInd * 7 + index)
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
      
      private function get manager() : IsraelInnovationManager
      {
         return IsraelInnovationManager.getInstance(FEATURE_NAME);
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
            if(i == 0 && WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ISRAEL))
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
      
      public function onOver2(evt:MouseEvent) : void
      {
         this.m_week_reward1_mc.visible = true;
         this.m_week_reward1_mc.gotoAndStop(1);
         var mileStoneItem1:FarmItem = this.manager.getActiveDayReward(0);
         if(mileStoneItem1)
         {
            this.manager.showNPCCallouts("Weekly Bonus!","Get 75 points this week to bag this exclusive " + mileStoneItem1.friendlyTitle + "!");
         }
         var isWeekMileStoneAchieved:Boolean = this.manager.isWeeklyMilestoneAchievedForLevel(0);
         this.m_week_reward1_tick_mc.visible = isWeekMileStoneAchieved;
      }
      
      public function onOver3(evt:MouseEvent) : void
      {
         this.m_week_reward2_mc.visible = true;
         this.m_week_reward2_mc.gotoAndStop(1);
         var mileStoneItem2:FarmItem = this.manager.getActiveDayReward(1);
         if(mileStoneItem2)
         {
            this.manager.showNPCCallouts("Weekly Bonus!","Get 150 points this week to bag this exclusive " + mileStoneItem2.friendlyTitle + "!");
         }
         var isWeekMileStoneAchieved:Boolean = this.manager.isWeeklyMilestoneAchievedForLevel(1);
         this.m_week_reward2_tick_mc.visible = isWeekMileStoneAchieved;
      }
      
      public function onOut2(evt:MouseEvent) : void
      {
         this.m_week_reward1_mc.visible = false;
         this.manager.hideNPCCallout();
      }
      
      public function onOut3(evt:MouseEvent) : void
      {
         this.m_week_reward2_mc.visible = false;
         this.manager.hideNPCCallout();
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
      
      public function openMiniMarket(e:Event) : void
      {
         IsraelInnovationManager.getInstance().highlightTiles();
         FarmStatsManager.count("IsraelInnovation","UnlockTile","tile_unlock","click");
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
         FarmStatsManager.count("IsraelInnovation","Main_UI","close_window");
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
         return Global.player.getSeenFlag(this.ISRAEL_INNOVATION_WELCOME_SEEN_FLAG);
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
         this.m_tileUnlockCount_tf.text = (count * 30).toString();
         this.m_overlay_tf.text = "Unlocker of Tiles";
         this.m_tileUnlockDes_tf.text = "You have gotten " + (count * this.TILE_UNLOCK_CONSUMABLE_COUNT).toString() + " Bundles of Plenty on unlocking " + count.toString() + " tiles. Enjoy!";
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

