package Widgets.Windows
{
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.FarmStatsManager;
   import Managers.TwentiesInnovationManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Frames.TwentiesInnovationLeaderboardSlotFrame;
   import Widgets.Frames.TwentiesInnovationTaskFrame;
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
   
   public class TwentiesInnovationMainWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 9;
      
      public static const ICON_SIZE:int = 50;
      
      private static const FEATURE_NAME:String = "TwentiesInnovation";
      
      private var m_featureName:String = null;
      
      private const PROGRESS_BAR_FULL_ANGLE:int = 172;
      
      private const PROGRESS_BAR_START_ANGLE:int = 6;
      
      private const ROUND_METER_TOOLTIP_TEXTS:Array = ["0- 4 Points: No gifts for staying in this Range! Complete more orders to increase your current average!","5 - 14 Points: Good going! You will get {0} for staying in this Range when the week ends!","15 - 29 Points: You’re a natural! You will get a {0} + a {1} for staying in this Range when the week ends!","30 - 35 Points: You legend! You will get a {0} + a {1} + a {2} for staying this Range when the week ends!"];
      
      private const LB_HIGHEST_REWARD:Array = ["pegasus_silverflapper","unicorn_fashionista","horse_daydress","cow_jazzprincess","magicdeer_bobbedhairdeer","pegacorn_eliteist"];
      
      private const PARTY_HOUSE_TOOLTIP_TEXT:Array = ["You need to get a Legendary Rating for 1 Week to get this building upgrade!","You need to get an Legendary Rating for 2 Weeks to upgrade this building!","You need to get an Legendary Rating for 3 Weeks to upgrade this building!","You need to get an Legendary Rating for 4 Weeks to upgrade this building!","You need to get an Legendary Rating for 5 Weeks to upgrade this building!","Congratulations! You have fully upgraded this building!"];
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const TASKS_MC:String = "tasks_mc";
      
      private const FEATURE_TIMER_TF:String = "timer_tf";
      
      private const DAILY_TIMER_MC:String = "daily_clock_mc";
      
      private const FINISH_MC:String = "finish_mc";
      
      private const DUMPFTUE_MC:String = "dumpFTUE_mc";
      
      private const POINTS_TF:String = "points_tf";
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private var m_taskFrame:TwentiesInnovationTaskFrame;
      
      private var m_finishMc:MovieClip;
      
      private var m_tileUnlock_mc:MovieClip;
      
      private var m_unlock_tf:ZwTextField;
      
      private var m_tileUnlockDes_tf:ZwTextField;
      
      private var m_tileUnlockCount_tf:ZwTextField;
      
      private var m_overlay_tf:ZwTextField;
      
      private var m_overlayUnlock_bt:FarmAnimatedTextButton;
      
      private var m_dooberMc:MovieClip;
      
      private var m_dooberIconMc:MovieClip;
      
      private var m_dooberCountTf:ZwTextField;
      
      private var m_highlightLB_mc:MovieClip;
      
      private var m_glowLB_mc:MovieClip;
      
      protected var m_DumpTutorial:ZwFrame = null;
      
      private var m_DumptutorialScene:int = 0;
      
      private const PROGRESS_BAR_FULL_WIDTH:int = 311;
      
      private const SMALL_PROGRESS_BAR_FULL_WIDTH:int = 42;
      
      private var m_consumable_mc:MovieClip;
      
      private const CONSUMABLE_MC:String = "consumable_mc";
      
      private const CONSUMABLE_BT:String = "consumable_bt";
      
      private const CRAFT_BT:String = "craft_bt";
      
      private const COUNT_TF:String = "count_tf";
      
      private var m_consumableCount_tf:ZwTextField;
      
      private var m_ptsArray:Array = [];
      
      private var m_statesArray:Array = [];
      
      private var m_statesMcArray:Array = [];
      
      private var m_daysMcArray:Array = [];
      
      private var m_barMcArray:Array = [];
      
      private var m_barGlowArray:Array = [];
      
      private var m_sessionMcArray:Array = [];
      
      public var m_pointsCountTfArray:Array = [];
      
      public var m_currentWeekTfArray:Array = [];
      
      private var m_small_progress_mc:MovieClip;
      
      private const DAILY_PROGRESS_MC:String = "meter_mc";
      
      private var m_daily_progress_mc:MovieClip;
      
      private var m_barMc:MovieClip;
      
      private var m_dailyTimer_tf:ZwTextField;
      
      private var m_featureTimer_tf:ZwTextField;
      
      private var m_lb_refreshTimer_tf:ZwTextField;
      
      private var m_dailyTimerMc:MovieClip;
      
      private var m_message_mc:MovieClip;
      
      private var m_messageTicket_mc:MovieClip;
      
      private var m_messageTitle:ZwTextField;
      
      private var m_messageInfo1:ZwTextField;
      
      private var m_messageInfo2:ZwTextField;
      
      private var m_messageCash:ZwTextField;
      
      private var m_messageOkay:FarmAnimatedCashButton;
      
      private const BUY_BT:String = "buy_bt";
      
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
      
      private const PACKAGE_REWARDS_ARRAY:Array = ["lp09","dlwc","bmx0","thm5","uv52","gz1k","26mu"];
      
      private const ProgressLevelTextArray:Array = ["GROWER","EXPORTER","TYCOON"];
      
      private const EARNED_POINTS_MC:String = "earned_points_mc";
      
      private var m_lock1HoverText:ZwTextField;
      
      private var m_lock2HoverText:ZwTextField;
      
      private const REWARD_EA_WEEK:String = "reward_EA_mc";
      
      private var m_EA_week_mc:MovieClip;
      
      public var m_unlockanim1_mc:MovieClip;
      
      public var m_unlockanim2_mc:MovieClip;
      
      private const TILE_UNLOCK_CONSUMABLE_COUNT:int = 30;
      
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
      
      private const PREVIEW_MC_KEY_ARRAY:Array = ["preview1_mc","preview2_mc","preview3_mc"];
      
      private const MILESTONE_MC_KEY_ARRAY:Array = ["milestone1_mc","milestone2_mc","milestone3_mc"];
      
      private const REWARD_MC_KEY_ARRAY:Array = ["reward1_mc","reward2_mc","reward3_mc"];
      
      private const DATE_ARRAY:Array = ["05/20/2018","05/13/2018","05/06/2018","04/29/2019","04/22/2019"];
      
      private var m_showTutorialWithEAPage:Boolean = false;
      
      private var m_iconPreview:ObjectPreviewFrame;
      
      private var m_rewIconPreview:ObjectPreviewFrame;
      
      private var m_iconMc:FarmIcon;
      
      private var m_leaderboardIconMc:MovieClip;
      
      private var m_isIconPreviewAdded:Boolean;
      
      private var m_best_icon_mc:FarmIcon;
      
      private var m_sinkBtTooltip:FarmTextTooltip;
      
      private var m_timerWidget:ZwFrame;
      
      private var m_timerToolTip:FarmTextTooltip;
      
      private const DAILY_DUMMY_MAX_POINT:Number = 30;
      
      private var m_barrel_mc:ZwFrame;
      
      public var m_firstStartSessionMC:MovieClip;
      
      private var m_tileUnlock_bt:FarmAnimatedTextButton;
      
      private var m_checkMark_mc:MovieClip;
      
      private var m_dayChangeHasOccuredDuringOpenWindow:Boolean = false;
      
      private var RANGE_ARRAY:Array = ["100-200","201-280","281-350"];
      
      private var m_noOfWeek:int = 6;
      
      private var m_level_tf:ZwTextField;
      
      private var m_commPoint1_tf:ZwTextField;
      
      private var m_commPoint2_tf:ZwTextField;
      
      private var m_averageTF:ZwTextField;
      
      private var m_buildingIconMc:FarmIcon;
      
      private var m_pointerMc:MovieClip;
      
      private var m_roundMeterHoverRewardMc:MovieClip;
      
      private var m_roundMeterHoverRewardIcon:FarmIcon;
      
      private var m_meterBg:MovieClip;
      
      public var m_overlayMc:MovieClip;
      
      private var m_roundMeterCheckmark1Mc:MovieClip;
      
      private var m_roundMeterCheckmark2Mc:MovieClip;
      
      private var m_roundMeterCheckmark3Mc:MovieClip;
      
      private var m_roundMeterCheckmark4Mc:MovieClip;
      
      private var m_roundMeterCheckmark5Mc:MovieClip;
      
      private var m_roundMeterCheckmark6Mc:MovieClip;
      
      private var m_roundMeterHoverRewardIconName:ZwTextField;
      
      private var m_roundMeterHoverReward1Icon1Name:ZwTextField;
      
      private var m_roundMeterHoverReward1Icon2Name:ZwTextField;
      
      private var m_roundMeterHoverReward2Icon1Name:ZwTextField;
      
      private var m_roundMeterHoverReward2Icon2Name:ZwTextField;
      
      private var m_roundMeterHoverReward2Icon3Name:ZwTextField;
      
      private var m_roundMeterRewardName6Tf:ZwTextField;
      
      private var m_roundMeterHoverReward2Mc:MovieClip;
      
      private var m_roundMeterHoverReward1Mc:MovieClip;
      
      private var m_roundMeterHoverReward1Icon1:FarmIcon;
      
      private var m_roundMeterHoverReward1Icon2:FarmIcon;
      
      private var m_roundMeterHoverReward2Icon1:FarmIcon;
      
      private var m_roundMeterHoverReward2Icon2:FarmIcon;
      
      private var m_roundMeterHoverReward2Icon3:FarmIcon;
      
      private var m_statesActiveArray:Array = [];
      
      private var m_firstSessionBt:FarmAnimatedTextButton;
      
      private const LEADERBOARD_MC:String = "leaderboard_mc";
      
      private var m_leaderboard_mc:MovieClip;
      
      private var m_loader_mc:MovieClip;
      
      private var m_reward_mc:MovieClip;
      
      private var m_lb_timer_tf:ZwTextField;
      
      private var m_currentScore_tf:ZwTextField;
      
      private var m_weeklyHeadingTf:ZwTextField;
      
      private var m_view_rewards_bt:FarmAnimatedTextButton;
      
      private var m_refresh_lb_bt:FarmAnimatedTextButton;
      
      private var m_timeout_msg_tf:ZwTextField;
      
      private var m_leaderboard_frame:TwentiesInnovationLeaderboardSlotFrame;
      
      private var m_view_building_rewards_bt:FarmAnimatedTextButton;
      
      public function TwentiesInnovationMainWindow(featureName:String = "TwentiesInnovation", assetUrl:String = null, showEAPageTutorial:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_showTutorialWithEAPage = showEAPageTutorial;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(FEATURE_NAME,assetUrl,numOfTutorialPages);
      }
      
      override protected function postLoadComplete() : void
      {
         var leaderboardSlotIndex:int = 0;
         var propertyName:* = undefined;
         var leaderboardSlot:* = undefined;
         var hitAreaMc:ZwFrame = null;
         var stateEAIndex:int = 0;
         var weekData:Object = null;
         var weekNum:int = 0;
         var currDayIndex:int = 0;
         var stateGAIndex:int = 0;
         var gaWeekData:Object = null;
         var gaWeekNum:int = 0;
         var currDayGAIndex:int = 0;
         var index:int = 0;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Maggie’s Party Mania!"));
            m_window[this.TITLE_TF].visible = true;
         }
         if(m_window.hasOwnProperty("average_tf"))
         {
            this.m_averageTF = addWidget(new ZwTextField(m_window["average_tf"],"Current Week Average - " + this.manager.getCurrentAverage())) as ZwTextField;
         }
         if(m_window.hasOwnProperty("subtitle_tf"))
         {
            addWidget(new ZwTextField(m_window["subtitle_tf"],""));
            m_window["subtitle_tf"].text = "Help Maggie throw the best parties every week, and win amazing rewards!";
            m_window["subtitle_tf"].visible = true;
         }
         if(m_window.hasOwnProperty(this.REWARD_EA_WEEK))
         {
            this.m_EA_week_mc = m_window[this.REWARD_EA_WEEK] as MovieClip;
            this.m_EA_week_mc.visible = false;
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
            if(this.m_consumable_mc.hasOwnProperty(this.CONSUMABLE_BT))
            {
               addWidget(new FarmAnimatedTextButton(this.m_consumable_mc[this.CONSUMABLE_BT],"Get More",this.buyCallback));
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
               this.m_barrel_mc.attachTooltip(new FarmTextTooltip("Party Masques"));
            }
         }
         if(m_window.hasOwnProperty("EA_mc"))
         {
            (m_window["EA_mc"] as MovieClip).visible = false;
         }
         if(m_window.hasOwnProperty("highlightLB_mc"))
         {
            this.m_highlightLB_mc = m_window["highlightLB_mc"] as MovieClip;
            this.m_highlightLB_mc.visible = this.manager.getDayEndMessageShown();
         }
         if(m_window.hasOwnProperty("startday_ftue_mc"))
         {
            this.m_firstStartSessionMC = m_window["startday_ftue_mc"] as MovieClip;
            this.m_firstStartSessionMC.visible = false;
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
         for(var i:int = 0; i < this.m_noOfWeek; i++)
         {
            if(m_window.hasOwnProperty("avg" + (i + 1).toString() + "_tf"))
            {
               this.m_ptsArray[i] = new ZwTextField(m_window["avg" + (i + 1).toString() + "_tf"]);
               this.m_ptsArray[i].visible = true;
            }
         }
         if(m_window.hasOwnProperty("EA_tf"))
         {
            (m_window["EA_tf"] as TextField).visible = true;
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
            addWidget(this.m_overlayUnlock_bt = new FarmAnimatedTextButton(this.m_tileUnlock_mc["overlay_bt"],"Cool",this.onCloseTileOverlay));
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
         if(m_window.hasOwnProperty("loader_mc"))
         {
            this.m_loader_mc = m_window["loader_mc"] as MovieClip;
            this.m_loader_mc.visible = true;
            this.m_loader_mc.play();
         }
         if(m_window.hasOwnProperty(this.DAILY_TIMER_MC))
         {
            this.m_dailyTimerMc = m_window[this.DAILY_TIMER_MC] as MovieClip;
            this.m_timerToolTip = new FarmTextTooltip(this.dayTooltip);
            this.m_dailyTimerMc.visible = true;
            addWidget(this.m_timerWidget = new ZwFrame(this.m_dailyTimerMc),true);
            addWidget(this.m_dailyTimer_tf = new ZwTextField(this.m_dailyTimerMc["time_tf"],HUD.getformattedTimeLeft(this.manager.getTimeLeftInDay())));
            if(this.m_dailyTimerMc.hasOwnProperty("timer1_tf"))
            {
               this.m_featureTimer_tf = new ZwTextField(this.m_dailyTimerMc["timer1_tf"],this.getTimeLeft());
               this.m_featureTimer_tf.visible = true;
            }
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
            this.m_taskFrame = new TwentiesInnovationTaskFrame(m_window[this.TASKS_MC],this,this.m_featureName);
            this.m_taskFrame.visible = true;
         }
         if(m_window.hasOwnProperty(this.FINISH_MC))
         {
            this.m_finishMc = m_window[this.FINISH_MC] as MovieClip;
         }
         if(this.manager.lockedTilesArray.length > 0)
         {
         }
         if(m_window.hasOwnProperty("meter_bg_mc"))
         {
            this.m_meterBg = m_window["meter_bg_mc"] as MovieClip;
         }
         if(m_window.hasOwnProperty("overlay_mc"))
         {
            this.m_overlayMc = m_window["overlay_mc"] as MovieClip;
            this.m_overlayMc.visible = false;
         }
         if(Global.player.getSeenFlag(this.manager.TILE_UNLOCK))
         {
            this.showtileUnlockOverlay();
         }
         if(m_window.hasOwnProperty("close_bt"))
         {
         }
         if(m_window.hasOwnProperty("heading_tf"))
         {
            addWidget(this.m_weeklyHeadingTf = new ZwTextField(m_window["heading_tf"],"You will get "));
            this.m_weeklyHeadingTf.visible = false;
         }
         if(m_window.hasOwnProperty(this.LEADERBOARD_MC))
         {
            this.m_leaderboard_mc = m_window[this.LEADERBOARD_MC] as MovieClip;
            this.m_leaderboard_mc.visible = true;
            this.m_leaderboard_frame = new TwentiesInnovationLeaderboardSlotFrame(this.m_leaderboard_mc,null,this.m_featureName,this);
            addWidget(this.m_leaderboard_frame,true);
            if(this.m_leaderboard_mc.hasOwnProperty("score_tf"))
            {
               addWidget(this.m_currentScore_tf = new ZwTextField(this.m_leaderboard_mc["score_tf"],"0"));
               this.m_currentScore_tf.visible = true;
            }
            if(this.m_leaderboard_mc.hasOwnProperty("glow1_mc"))
            {
               this.m_glowLB_mc = this.m_leaderboard_mc["glow1_mc"] as MovieClip;
               this.m_glowLB_mc.visible = this.manager.getDayEndMessageShown();
            }
            if(this.m_leaderboard_mc.hasOwnProperty("view_bt"))
            {
               addWidget(this.m_view_rewards_bt = new FarmAnimatedTextButton(this.m_leaderboard_mc["view_bt"],"View Rewards",this.onLBRewardsButtonClick));
               this.m_view_rewards_bt.visible = false;
            }
            if(this.m_leaderboard_mc.hasOwnProperty("refresh_bt"))
            {
               addWidget(this.m_refresh_lb_bt = new FarmAnimatedTextButton(this.m_leaderboard_mc["refresh_bt"],"Refresh",this.onRefreshButtonClick));
               this.m_refresh_lb_bt.visible = false;
               this.m_refresh_lb_bt.enabled = false;
            }
            if(this.m_leaderboard_mc.hasOwnProperty("reward_mc"))
            {
               this.m_reward_mc = this.m_leaderboard_mc["reward_mc"] as MovieClip;
               if(this.m_reward_mc.hasOwnProperty("icon_mc"))
               {
                  this.m_leaderboardIconMc = this.m_reward_mc.icon_mc;
               }
               if(this.m_reward_mc.hasOwnProperty("timer_tf"))
               {
                  addWidget(this.m_lb_timer_tf = new ZwTextField(this.m_reward_mc["timer_tf"],""));
               }
               this.m_reward_mc.visible = false;
            }
            if(this.m_leaderboard_mc.hasOwnProperty("message_tf"))
            {
               addWidget(this.m_timeout_msg_tf = new ZwTextField(this.m_leaderboard_mc["message_tf"],"Request Timed out. Please try again."));
               this.m_timeout_msg_tf.visible = false;
            }
            if(this.m_leaderboard_mc.hasOwnProperty("time_tf"))
            {
               this.m_lb_refreshTimer_tf = new ZwTextField(this.m_leaderboard_mc["time_tf"],"x minutes since last refresh");
               this.m_lb_refreshTimer_tf.visible = false;
            }
            for(leaderboardSlotIndex = 0; leaderboardSlotIndex < 6; leaderboardSlotIndex++)
            {
               propertyName = "leaderboardSlot_" + leaderboardSlotIndex + "_mc";
               if(this.m_leaderboard_mc.hasOwnProperty(propertyName))
               {
                  leaderboardSlot = this.m_leaderboard_mc[propertyName] as MovieClip;
                  leaderboardSlot.visible = false;
               }
            }
         }
         var hitAreaIndex:int = 1;
         while(m_window.hasOwnProperty("hitarea" + hitAreaIndex + "_mc"))
         {
            hitAreaMc = new ZwFrame(m_window["hitarea" + hitAreaIndex + "_mc"] as MovieClip);
            this.attachTooltipToMeter(hitAreaMc,hitAreaIndex);
            hitAreaMc.visible = true;
            hitAreaMc.enabled = true;
            hitAreaMc.registerEventListener(MouseEvent.MOUSE_OVER,this.onRoundMeterMouseOver(hitAreaIndex));
            hitAreaMc.registerEventListener(MouseEvent.MOUSE_OUT,this.onRoundMeterMouseOut);
            hitAreaIndex++;
         }
         if(m_window.hasOwnProperty("pointer_mc"))
         {
            this.m_pointerMc = m_window["pointer_mc"] as MovieClip;
            this.m_pointerMc.visible = true;
            this.m_pointerMc.rotation = 0;
            this.updateHappinessMeter();
         }
         if(m_window.hasOwnProperty("hover_reward_mc"))
         {
            this.m_roundMeterHoverRewardMc = m_window["hover_reward_mc"] as MovieClip;
            if(this.m_roundMeterHoverRewardMc.hasOwnProperty("icon2_mc"))
            {
               this.m_roundMeterHoverRewardIcon = new FarmIcon(this.m_roundMeterHoverRewardMc["icon2_mc"]);
               this.m_roundMeterHoverRewardIcon.visible = true;
            }
            if(this.m_roundMeterHoverRewardMc.hasOwnProperty("name_tf"))
            {
               this.m_roundMeterHoverRewardIconName = new ZwTextField(this.m_roundMeterHoverRewardMc["name_tf"],"");
               this.m_roundMeterHoverRewardIconName.visible = true;
            }
            if(this.m_roundMeterHoverRewardMc.hasOwnProperty("checkmark_mc"))
            {
               this.m_roundMeterCheckmark1Mc = this.m_roundMeterHoverRewardMc["checkmark_mc"] as MovieClip;
               this.m_roundMeterCheckmark1Mc.visible = false;
            }
            this.m_roundMeterHoverRewardMc.visible = false;
         }
         if(m_window.hasOwnProperty("hover_reward1_mc"))
         {
            this.m_roundMeterHoverReward1Mc = m_window["hover_reward1_mc"] as MovieClip;
            if(this.m_roundMeterHoverReward1Mc.hasOwnProperty("checkmark1_mc"))
            {
               this.m_roundMeterCheckmark2Mc = this.m_roundMeterHoverReward1Mc["checkmark1_mc"] as MovieClip;
               this.m_roundMeterCheckmark2Mc.visible = false;
            }
            if(this.m_roundMeterHoverReward1Mc.hasOwnProperty("checkmark2_mc"))
            {
               this.m_roundMeterCheckmark3Mc = this.m_roundMeterHoverReward1Mc["checkmark2_mc"] as MovieClip;
               this.m_roundMeterCheckmark3Mc.visible = false;
            }
            if(this.m_roundMeterHoverReward1Mc.hasOwnProperty("icon3_mc"))
            {
               addWidget(this.m_roundMeterHoverReward1Icon1 = new FarmIcon(this.m_roundMeterHoverReward1Mc["icon3_mc"]));
               this.m_roundMeterHoverReward1Icon1.visible = true;
            }
            if(this.m_roundMeterHoverReward1Mc.hasOwnProperty("icon4_mc"))
            {
               addWidget(this.m_roundMeterHoverReward1Icon2 = new FarmIcon(this.m_roundMeterHoverReward1Mc["icon4_mc"]));
               this.m_roundMeterHoverReward1Icon2.visible = true;
            }
            if(this.m_roundMeterHoverReward1Mc.hasOwnProperty("name1_tf"))
            {
               this.m_roundMeterHoverReward1Icon1Name = new ZwTextField(this.m_roundMeterHoverReward1Mc["name1_tf"],"");
               this.m_roundMeterHoverReward1Icon1Name.visible = true;
            }
            if(this.m_roundMeterHoverReward1Mc.hasOwnProperty("name2_tf"))
            {
               this.m_roundMeterHoverReward1Icon2Name = new ZwTextField(this.m_roundMeterHoverReward1Mc["name2_tf"],"");
               this.m_roundMeterHoverReward1Icon2Name.visible = true;
            }
            this.m_roundMeterHoverReward1Mc.visible = false;
         }
         if(m_window.hasOwnProperty("hover_reward2_mc"))
         {
            this.m_roundMeterHoverReward2Mc = m_window["hover_reward2_mc"] as MovieClip;
            if(this.m_roundMeterHoverReward2Mc.hasOwnProperty("checkmark1_mc"))
            {
               this.m_roundMeterCheckmark4Mc = this.m_roundMeterHoverReward2Mc["checkmark1_mc"] as MovieClip;
               this.m_roundMeterCheckmark4Mc.visible = false;
            }
            if(this.m_roundMeterHoverReward2Mc.hasOwnProperty("checkmark2_mc"))
            {
               this.m_roundMeterCheckmark5Mc = this.m_roundMeterHoverReward2Mc["checkmark2_mc"] as MovieClip;
               this.m_roundMeterCheckmark5Mc.visible = false;
            }
            if(this.m_roundMeterHoverReward2Mc.hasOwnProperty("checkmark3_mc"))
            {
               this.m_roundMeterCheckmark6Mc = this.m_roundMeterHoverReward2Mc["checkmark3_mc"] as MovieClip;
               this.m_roundMeterCheckmark6Mc.visible = false;
            }
            if(this.m_roundMeterHoverReward2Mc.hasOwnProperty("icon5_mc"))
            {
               addWidget(this.m_roundMeterHoverReward2Icon1 = new FarmIcon(this.m_roundMeterHoverReward2Mc["icon5_mc"]));
               this.m_roundMeterHoverReward2Icon1.visible = true;
            }
            if(this.m_roundMeterHoverReward2Mc.hasOwnProperty("icon6_mc"))
            {
               addWidget(this.m_roundMeterHoverReward2Icon2 = new FarmIcon(this.m_roundMeterHoverReward2Mc["icon6_mc"]));
               this.m_roundMeterHoverReward2Icon2.visible = true;
            }
            if(this.m_roundMeterHoverReward2Mc.hasOwnProperty("icon7_mc"))
            {
               addWidget(this.m_roundMeterHoverReward2Icon3 = new FarmIcon(this.m_roundMeterHoverReward2Mc["icon7_mc"]));
               this.m_roundMeterHoverReward2Icon3.visible = true;
            }
            if(this.m_roundMeterHoverReward2Mc.hasOwnProperty("name1_tf"))
            {
               this.m_roundMeterHoverReward2Icon1Name = new ZwTextField(this.m_roundMeterHoverReward2Mc["name1_tf"],"");
               this.m_roundMeterHoverReward2Icon1Name.visible = true;
            }
            if(this.m_roundMeterHoverReward2Mc.hasOwnProperty("name2_tf"))
            {
               this.m_roundMeterHoverReward2Icon2Name = new ZwTextField(this.m_roundMeterHoverReward2Mc["name2_tf"],"");
               this.m_roundMeterHoverReward2Icon2Name.visible = true;
            }
            if(this.m_roundMeterHoverReward2Mc.hasOwnProperty("name3_tf"))
            {
               this.m_roundMeterHoverReward2Icon3Name = new ZwTextField(this.m_roundMeterHoverReward2Mc["name3_tf"],"");
               this.m_roundMeterHoverReward2Icon3Name.visible = true;
            }
            this.m_roundMeterHoverReward2Mc.visible = false;
         }
         if(m_window.hasOwnProperty("icon3_mc"))
         {
            this.m_buildingIconMc = new FarmIcon(m_window["icon3_mc"]);
            if(this.m_buildingIconMc)
            {
               this.m_buildingIconMc.loadIcon(this.manager.REWARD_ITEM[int(this.manager.getCurrentLevel())]);
               this.attachTooltipToGiftBox(this.m_buildingIconMc);
               this.m_buildingIconMc.visible = true;
            }
         }
         if(m_window.hasOwnProperty("level_tf"))
         {
            this.m_level_tf = new ZwTextField(m_window["level_tf"],"Level: " + this.manager.getCurrentLevel() + "/5");
            this.m_level_tf.visible = true;
         }
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_TWENTIES))
         {
            stateEAIndex = 0;
            weekData = this.manager.getCurrentWeek();
            weekNum = int(weekData.count);
            while(m_window.hasOwnProperty("states" + (stateEAIndex + 1) + "_mc"))
            {
               this.m_statesArray[stateEAIndex] = m_window["states" + (stateEAIndex + 1).toString() + "_mc"] as MovieClip;
               this.m_statesMcArray[stateEAIndex] = new ZwFrame(this.m_statesArray[stateEAIndex]);
               this.m_statesArray[stateEAIndex].visible = true;
               if(this.m_statesArray[stateEAIndex].hasOwnProperty("active_mc"))
               {
                  this.m_statesActiveArray[stateEAIndex] = this.m_statesArray[stateEAIndex]["active_mc"] as MovieClip;
                  this.m_statesActiveArray[stateEAIndex].visible = false;
               }
               if(this.m_statesArray[stateEAIndex].hasOwnProperty("count_tf"))
               {
                  this.m_pointsCountTfArray[stateEAIndex] = new ZwTextField(this.m_statesArray[stateEAIndex]["count_tf"],"");
               }
               if(this.m_statesArray[stateEAIndex].hasOwnProperty("current_tf"))
               {
                  this.m_currentWeekTfArray[stateEAIndex] = new ZwTextField(this.m_statesArray[stateEAIndex]["current_tf"],"");
                  this.m_currentWeekTfArray[stateEAIndex].visible = true;
               }
               stateEAIndex++;
            }
            this.m_currentWeekTfArray[weekNum - 1].text = "Current Week";
            this.m_pointsCountTfArray[weekNum - 1].text = this.manager.getCurrentAverage().toString();
            currDayIndex = this.manager.currentDayIndex;
            if(this.manager.hasActiveWeekExpired())
            {
               this.m_currentWeekTfArray[weekNum - 1].visible = false;
               this.m_pointsCountTfArray[weekNum - 1].visible = false;
            }
            else
            {
               if(this.m_overlayMc)
               {
                  this.m_overlayMc.visible = false;
               }
               this.m_currentWeekTfArray[weekNum - 1].visible = true;
               this.m_pointsCountTfArray[weekNum - 1].visible = true;
            }
         }
         else
         {
            stateGAIndex = 0;
            while(m_window.hasOwnProperty("states" + (stateGAIndex + 1) + "_ga_mc"))
            {
               this.m_statesArray[stateGAIndex] = m_window["states" + (stateGAIndex + 1).toString() + "_ga_mc"] as MovieClip;
               this.m_statesMcArray[stateGAIndex] = new ZwFrame(this.m_statesArray[stateGAIndex]);
               this.m_statesArray[stateGAIndex].visible = true;
               if(this.m_statesArray[stateGAIndex].hasOwnProperty("active_mc"))
               {
                  this.m_statesActiveArray[stateGAIndex] = this.m_statesArray[stateGAIndex]["active_mc"] as MovieClip;
                  this.m_statesActiveArray[stateGAIndex].visible = false;
               }
               if(this.m_statesArray[stateGAIndex].hasOwnProperty("count_tf"))
               {
                  this.m_pointsCountTfArray[stateGAIndex] = new ZwTextField(this.m_statesArray[stateGAIndex]["count_tf"],"");
               }
               if(this.m_statesArray[stateGAIndex].hasOwnProperty("current_tf"))
               {
                  this.m_currentWeekTfArray[stateGAIndex] = new ZwTextField(this.m_statesArray[stateGAIndex]["current_tf"],"");
               }
               stateGAIndex++;
            }
            gaWeekData = this.manager.getCurrentWeek();
            gaWeekNum = gaWeekData.count - 1;
            if(this.m_statesArray)
            {
               this.m_statesArray[gaWeekNum - 1].visible = true;
            }
            this.m_currentWeekTfArray[gaWeekNum - 1].text = "Current Week";
            this.m_pointsCountTfArray[gaWeekNum - 1].text = this.manager.getCurrentAverage().toString();
            currDayGAIndex = this.manager.currentDayIndex;
            if(this.manager.hasActiveWeekExpired())
            {
               this.m_currentWeekTfArray[gaWeekNum - 1].visible = false;
               this.m_pointsCountTfArray[gaWeekNum - 1].visible = false;
            }
            else
            {
               if(this.m_overlayMc)
               {
                  this.m_overlayMc.visible = false;
               }
               this.m_currentWeekTfArray[gaWeekNum - 1].visible = true;
               this.m_pointsCountTfArray[gaWeekNum - 1].visible = true;
            }
         }
         var dayCount:int = this.manager.activeDayIndex % 7;
         var weekCount:int = this.manager.getActiveWeek() as int;
         this.updateWeeklyState();
         if(m_window.hasOwnProperty("progress_small_mc"))
         {
            this.m_small_progress_mc = m_window["progress_small_mc"] as MovieClip;
            this.m_small_progress_mc.visible = true;
            index = 0;
            while(this.m_small_progress_mc.hasOwnProperty("day_" + index + "_mc"))
            {
               this.m_daysMcArray[index] = this.m_small_progress_mc["day_" + index + "_mc"] as MovieClip;
               this.m_daysMcArray[index].visible = true;
               if(this.m_daysMcArray[index].hasOwnProperty("bar_fill_mc"))
               {
                  this.m_barMcArray[index] = this.m_daysMcArray[index]["bar_fill_mc"] as MovieClip;
                  this.m_barMcArray[index].visible = true;
                  this.m_sessionMcArray[index] = this.m_daysMcArray[index]["session_mc"] as MovieClip;
                  this.m_sessionMcArray[index].visible = false;
               }
               if(this.m_daysMcArray[index].hasOwnProperty("active_day_mc"))
               {
                  this.m_barGlowArray[index] = this.m_daysMcArray[index]["active_day_mc"] as MovieClip;
                  this.m_barGlowArray[index].visible = false;
                  if(index == dayCount)
                  {
                     this.m_barGlowArray[index].visible = true;
                     this.m_sessionMcArray[index].visible = true;
                  }
                  else
                  {
                     this.m_barGlowArray[index].visible = false;
                     this.m_sessionMcArray[index].visible = false;
                  }
               }
               index++;
            }
         }
         if(m_window.hasOwnProperty("view_rewards_bt"))
         {
            addWidget(this.m_view_building_rewards_bt = new FarmAnimatedTextButton(m_window["view_rewards_bt"],"View Rewards",this.onRewardsButtonClick));
            this.m_view_building_rewards_bt.visible = true;
            this.m_view_building_rewards_bt.enabled = true;
         }
         this.updateSmallMeters(true);
         if(m_window.hasOwnProperty(this.DAILY_PROGRESS_MC))
         {
            this.m_daily_progress_mc = m_window[this.DAILY_PROGRESS_MC] as MovieClip;
            this.m_daily_progress_mc.visible = true;
            this.m_barMc = this.m_daily_progress_mc["bar_fill_mc"] as MovieClip;
            this.m_barMc.visible = true;
         }
         if(m_window.hasOwnProperty("checkmark_mc"))
         {
            this.m_checkMark_mc = m_window["checkmark_mc"] as MovieClip;
            this.m_checkMark_mc.visible = this.manager.getUserState() == this.manager.DONE_FOR_THE_DAY;
         }
         if(m_window.hasOwnProperty("level_lock1_hover"))
         {
            this.m_lock1Hover = m_window["level_lock1_hover"] as MovieClip;
            this.m_lock1Hover.visible = false;
            this.m_lock1HoverText = new ZwTextField(this.m_lock1Hover["info1_tf"],"Use 5 Party Masques to unlock Adequate Level!");
         }
         if(m_window.hasOwnProperty("level_lock2_hover"))
         {
            this.m_lock2Hover = m_window["level_lock2_hover"] as MovieClip;
            this.m_lock2Hover.visible = false;
            this.m_lock2HoverText = new ZwTextField(this.m_lock2Hover["info1_tf"],"Use 10 Party Masques to unlock Abundant Level!");
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
            this.m_rewardIconMcArray[mileStoneRewardIndex].setIconSize(70,70);
            this.m_rewardIconMcArray[mileStoneRewardIndex].setSmoothing(true);
         }
         this.updateDayBonus();
         this.refreshTaskFrame();
         this.updateProgressBar(true);
         this.updateWeeklyTable();
         this.updateConsumableCount();
         this.startTimer();
      }
      
      public function populateLeaderboard(result:Object) : void
      {
         if(result["gift"] != null)
         {
            this.manager.ShowLBRewardPopup(result["gift"],result["giftLeaderboardRank"],result["giftLeaderboardName"],result["score"]);
         }
         this.m_leaderboard_frame.finishLoading(result);
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
         if(this.m_refresh_lb_bt != null)
         {
            this.m_refresh_lb_bt.visible = true;
            this.m_refresh_lb_bt.enabled = true;
         }
         if(this.m_lb_refreshTimer_tf)
         {
            this.m_lb_refreshTimer_tf.visible = true;
            this.m_lb_refreshTimer_tf.text = "Updated : " + this.manager.getTimeSinceLastLBRefresh() + " ago.";
         }
         if(!success)
         {
            if(this.m_timeout_msg_tf != null)
            {
               this.m_timeout_msg_tf.visible = true;
               this.m_timeout_msg_tf.text = "Error while updating the leaderboard. Please try again after some time.";
            }
            return;
         }
         if(this.m_view_rewards_bt != null)
         {
            this.m_view_rewards_bt.visible = true;
            this.m_view_rewards_bt.enabled = true;
         }
         if(this.m_reward_mc != null)
         {
            this.m_reward_mc.visible = true;
            if(this.m_lb_timer_tf != null)
            {
               this.m_lb_timer_tf.text = this.manager.getTimeStringLeftInWeek();
            }
         }
         if(this.m_currentScore_tf)
         {
            this.m_currentScore_tf.text = "Weekly score: " + this.manager.getWeeklyPoints().toString();
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
      
      public function showLeaderboardLoading() : *
      {
         var leaderboardSlotIndex:int = 0;
         var propertyName:* = undefined;
         var leaderboardSlot:* = undefined;
         if(this.m_currentScore_tf)
         {
            this.m_currentScore_tf.visible = false;
         }
         if(this.m_view_rewards_bt != null)
         {
            this.m_view_rewards_bt.visible = false;
         }
         if(this.m_refresh_lb_bt != null)
         {
            this.m_refresh_lb_bt.visible = false;
            this.m_refresh_lb_bt.enabled = false;
         }
         if(this.m_reward_mc != null)
         {
            this.m_reward_mc.visible = false;
         }
         if(this.m_lb_refreshTimer_tf)
         {
            this.m_lb_refreshTimer_tf.visible = false;
         }
         if(this.m_timeout_msg_tf != null)
         {
            this.m_timeout_msg_tf.visible = false;
         }
         if(this.m_leaderboard_mc != null)
         {
            for(leaderboardSlotIndex = 0; leaderboardSlotIndex < 6; leaderboardSlotIndex++)
            {
               propertyName = "leaderboardSlot_" + leaderboardSlotIndex + "_mc";
               if(this.m_leaderboard_mc.hasOwnProperty(propertyName))
               {
                  leaderboardSlot = this.m_leaderboard_mc[propertyName] as MovieClip;
                  leaderboardSlot.visible = false;
               }
            }
         }
         if(this.m_loader_mc != null)
         {
            this.m_loader_mc.visible = true;
            this.m_loader_mc.play();
         }
      }
      
      private function attachTooltipToGiftBox(icon:FarmIcon) : void
      {
         var level:int = this.manager.getRewardLevel();
         if(level < 0 || level > 4)
         {
            return;
         }
         if(icon.tooltip)
         {
            icon.tooltip.release();
         }
         icon.detachTooltip();
         icon.attachTooltip(new FarmTextTooltip(this.PARTY_HOUSE_TOOLTIP_TEXT[level]));
      }
      
      public function attachTooltipToMeter(meter:ZwFrame, index:int = 0) : void
      {
         var text:String = "";
         var reward1:FarmItem = this.manager.getActiveWeekReward(this.manager.EASY);
         var reward2:FarmItem = this.manager.getActiveWeekReward(this.manager.MEDIUM);
         var reward3:FarmItem = this.manager.getActiveWeekReward(this.manager.HARD);
         switch(index)
         {
            case 1:
               text = this.ROUND_METER_TOOLTIP_TEXTS[0];
               break;
            case 2:
               text = StringUtil.substitute(this.ROUND_METER_TOOLTIP_TEXTS[1],reward1.friendlyTitle);
               break;
            case 3:
               text = StringUtil.substitute(this.ROUND_METER_TOOLTIP_TEXTS[2],reward1.friendlyTitle,reward2.friendlyTitle);
               break;
            case 4:
               text = StringUtil.substitute(this.ROUND_METER_TOOLTIP_TEXTS[3],reward1.friendlyTitle,reward2.friendlyTitle,reward3.friendlyTitle);
         }
         if(meter.tooltip)
         {
            meter.tooltip.release();
         }
         meter.detachTooltip();
         meter.attachTooltip(new FarmTextTooltip(text));
      }
      
      private function shouldCheckmarkBeVisible(level:int = 0) : Boolean
      {
         if(level < 2)
         {
            return this.manager.hasReceivedRewardForWeek(level) && !this.manager.hasReceivedRewardForWeek(level + 1);
         }
         return this.manager.hasReceivedRewardForWeek(level);
      }
      
      private function loadIconInRoundMeterHoverMc(iconMCs:Array, checkmarkMCs:Array, iconNames:Array, level:int = 0) : void
      {
         var reward:FarmItem = null;
         var rewardTypes:Array = [this.manager.EASY,this.manager.MEDIUM,this.manager.HARD];
         var showCheckmark:Boolean = this.shouldCheckmarkBeVisible(level);
         for(var i:int = 0; i <= level; i++)
         {
            reward = this.manager.getActiveWeekReward(rewardTypes[i]);
            if(iconMCs[i])
            {
               if(level == 2)
               {
                  if(i == level - 1)
                  {
                     iconMCs[i + 1].loadIcon(reward.iconUrl);
                     iconMCs[i + 1].setIconSize(100,100);
                     iconNames[i + 1].text = reward.friendlyTitle;
                  }
                  else if(i == level)
                  {
                     iconMCs[i - 1].loadIcon(reward.iconUrl);
                     iconNames[i - 1].text = reward.friendlyTitle;
                  }
                  else
                  {
                     iconMCs[i].loadIcon(reward.iconUrl);
                     iconMCs[i].setIconSize(100,100);
                     iconNames[i].text = reward.friendlyTitle;
                  }
               }
               else if(level == 1)
               {
                  iconMCs[i].loadIcon(reward.iconUrl);
                  if(i != level)
                  {
                     iconMCs[i].setIconSize(100,100);
                  }
                  if(i == level)
                  {
                     iconMCs[i].setIconSize(100,100);
                  }
                  iconNames[i].text = reward.friendlyTitle;
               }
               else
               {
                  iconMCs[i].loadIcon(reward.iconUrl);
                  iconNames[i].text = reward.friendlyTitle;
               }
               iconMCs[i].setSmoothing(true);
            }
            if(showCheckmark && Boolean(checkmarkMCs[i]))
            {
               checkmarkMCs[i].visible = true;
            }
         }
      }
      
      private function setUpRoundMeterHoverMc(level:int) : void
      {
         var iconMCs:Array = [this.m_roundMeterHoverRewardIcon,this.m_roundMeterHoverReward1Icon1,this.m_roundMeterHoverReward1Icon2,this.m_roundMeterHoverReward2Icon1,this.m_roundMeterHoverReward2Icon2,this.m_roundMeterHoverReward2Icon3];
         var checkmarkMCs:Array = [this.m_roundMeterCheckmark1Mc,this.m_roundMeterCheckmark2Mc,this.m_roundMeterCheckmark3Mc,this.m_roundMeterCheckmark4Mc,this.m_roundMeterCheckmark5Mc,this.m_roundMeterCheckmark6Mc];
         var iconNames:Array = [this.m_roundMeterHoverRewardIconName,this.m_roundMeterHoverReward1Icon1Name,this.m_roundMeterHoverReward1Icon2Name,this.m_roundMeterHoverReward2Icon1Name,this.m_roundMeterHoverReward2Icon2Name,this.m_roundMeterHoverReward2Icon3Name];
         switch(level)
         {
            case 0:
               this.loadIconInRoundMeterHoverMc(iconMCs.slice(0,1),checkmarkMCs.slice(0,1),iconNames.slice(0,1),level);
               if(this.m_roundMeterHoverRewardMc)
               {
                  this.m_roundMeterHoverRewardMc.visible = true;
               }
               break;
            case 1:
               this.loadIconInRoundMeterHoverMc(iconMCs.slice(1,3),checkmarkMCs.slice(1,3),iconNames.slice(1,3),level);
               if(this.m_roundMeterHoverReward1Mc)
               {
                  this.m_roundMeterHoverReward1Mc.visible = true;
               }
               break;
            case 2:
               this.loadIconInRoundMeterHoverMc(iconMCs.slice(3,7),checkmarkMCs.slice(3,7),iconNames.slice(3,7),level);
               if(this.m_roundMeterHoverReward2Mc)
               {
                  this.m_roundMeterHoverReward2Mc.visible = true;
               }
         }
      }
      
      private function onRoundMeterMouseOver(index:int) : Function
      {
         return function(event:MouseEvent):void
         {
            if(index == 1)
            {
               return;
            }
            var level:* = index - 2;
            setUpRoundMeterHoverMc(level);
            if(m_weeklyHeadingTf)
            {
               m_weeklyHeadingTf.visible = true;
            }
            if(m_meterBg)
            {
               m_meterBg.visible = true;
            }
         };
      }
      
      private function onRoundMeterMouseOut(event:MouseEvent) : void
      {
         if(this.m_meterBg)
         {
            this.m_meterBg.visible = false;
         }
         if(this.m_roundMeterCheckmark1Mc)
         {
            this.m_roundMeterCheckmark1Mc.visible = false;
         }
         if(this.m_roundMeterCheckmark2Mc)
         {
            this.m_roundMeterCheckmark2Mc.visible = false;
         }
         if(this.m_roundMeterCheckmark3Mc)
         {
            this.m_roundMeterCheckmark3Mc.visible = false;
         }
         if(this.m_roundMeterCheckmark4Mc)
         {
            this.m_roundMeterCheckmark4Mc.visible = false;
         }
         if(this.m_roundMeterCheckmark5Mc)
         {
            this.m_roundMeterCheckmark5Mc.visible = false;
         }
         if(this.m_roundMeterCheckmark6Mc)
         {
            this.m_roundMeterCheckmark6Mc.visible = false;
         }
         if(this.m_roundMeterHoverRewardMc)
         {
            this.m_roundMeterHoverRewardMc.visible = false;
         }
         if(this.m_roundMeterHoverReward1Mc)
         {
            this.m_roundMeterHoverReward1Mc.visible = false;
         }
         if(this.m_roundMeterHoverReward2Mc)
         {
            this.m_roundMeterHoverReward2Mc.visible = false;
         }
         if(this.m_weeklyHeadingTf)
         {
            this.m_weeklyHeadingTf.visible = false;
         }
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
      
      override protected function preSwitchChanges(sceneNumber:int) : void
      {
         if(this.m_loader_mc)
         {
            this.m_loader_mc.visible = false;
         }
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_TWENTIES) == true)
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
            this.DATE_ARRAY.pop();
            this.refreshWindow();
         }
         if(this.m_featureTimer_tf)
         {
            this.m_featureTimer_tf.text = this.getTimeLeft();
         }
         this.m_dailyTimer_tf.text = HUD.getformattedTimeLeft(this.manager.getTimeLeftInDay());
         this.m_lb_refreshTimer_tf.text = "Updated : " + this.manager.getTimeSinceLastLBRefresh() + " ago";
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
            this.m_ask_bt.enabled = true;
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
            xPostTimeRemaining = this.manager.getThrottleTimeRemaining(TwentiesInnovationManager.FEED_NAME);
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
      
      private function onLBRewardsButtonClick(e:Event) : void
      {
         this.manager.openLBRewardViewWindow();
      }
      
      private function onRefreshButtonClick(e:Event) : void
      {
         this.showLeaderboardLoading();
         if(this.m_currentScore_tf)
         {
            this.m_currentScore_tf.visible = true;
         }
         this.manager.refreshLeaderboard();
      }
      
      private function onRewardsButtonClick(e:Event) : void
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
      
      public function updateProgressBar(onOpenWindow:Boolean = false) : void
      {
         var dayPoints:int = this.manager.getDayPoints();
         if(this.m_currentScore_tf)
         {
            this.m_currentScore_tf.visible = false;
            this.m_currentScore_tf.text = "Weekly score: " + this.manager.getWeeklyPoints().toString();
            this.m_currentScore_tf.visible = true;
         }
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
         var barLength:Number = normalizedPoints * this.PROGRESS_BAR_FULL_WIDTH / this.DAILY_DUMMY_MAX_POINT;
         if(this.m_barMc)
         {
            TweenMax.to(this.m_barMc,2,{"height":barLength});
            if(dayPoints < 0)
            {
               this.m_barMc.height = barLength;
               this.m_earnedPt_mc.y = 445 - barLength;
            }
            else if(onOpenWindow == false)
            {
               TweenMax.to(this.m_barMc,2,{"height":barLength});
               TweenMax.to(this.m_earnedPt_mc,2,{"y":445 - barLength});
            }
            else
            {
               this.m_barMc.height = barLength;
               this.m_earnedPt_mc.y = 445 - barLength;
            }
         }
         this.updateCurrentDayMeter(onOpenWindow);
      }
      
      public function refreshLeaderboardFrame() : void
      {
         var dayPoints:int = this.manager.getDayPoints();
         if(dayPoints < this.manager.VAL_THIRD_MILESTONE)
         {
            this.m_glowLB_mc.visible = false;
            this.m_highlightLB_mc.visible = false;
         }
         if(this.m_currentScore_tf)
         {
            this.m_currentScore_tf.visible = false;
            this.m_currentScore_tf.text = "Weekly score: " + this.manager.getWeeklyPoints().toString();
            this.m_currentScore_tf.visible = true;
         }
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
                  if(this.manager.redeemMessageShown == false)
                  {
                     this.displayWelcomeBackMessage();
                     this.manager.redeemMessageShown = true;
                  }
               }
            }
            else
            {
               if(this.manager.redeemHasStarted && this.manager.hasActiveWeekExpired())
               {
                  this.manager.onRedeemStarted();
               }
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
            else if(!redeemPreviousDayTask)
            {
               this.m_messageOkay.callback = null;
               this.m_messageOkay.enabled = false;
               this.m_messageOkay.element.mouseEnabled = this.m_messageOkay.element.mouseChildren = true;
            }
         }
         this.m_taskFrame.refresh();
         this.m_consumableCount_tf.text = "x" + this.manager.consumableCount.toString();
         this.updateAverageText();
         this.updateWeeklyState();
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
      
      public function displayLock1Message() : void
      {
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageOkay.visible = true;
         this.m_messageCash.visible = true;
         this.m_messageTicket_mc.visible = true;
         this.m_messageOkay.text = "Give!";
         this.m_messageOkay.callback = this.onSinkButtonClick;
         this.m_messageTitle.text = "Good job!";
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.visible = false;
         }
         var rewardItem:FarmItem = this.manager.getActiveDayReward(this.manager.EASY);
         this.loadMessageIcon(rewardItem);
         this.m_messageInfo1.text = "Maggie now has a Sparse amount of supplies for her party. Find the rewards in your gift box.";
         this.m_messageInfo2.text = "Give Maggie some Party Masque to move on to the next milestone!";
         this.m_messageCash.text = "5";
      }
      
      public function displayLock2Message() : void
      {
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageOkay.visible = true;
         this.m_messageCash.visible = true;
         this.m_messageTicket_mc.visible = true;
         this.m_messageOkay.text = "Give!";
         this.m_messageOkay.callback = this.onSinkButtonClick;
         this.m_messageTitle.text = "Amazing Work!";
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.visible = false;
         }
         var rewardItem:FarmItem = this.manager.getActiveDayReward(this.manager.MEDIUM);
         this.loadMessageIcon(rewardItem);
         this.m_messageInfo1.text = "Maggie now has an Adequate amount of supplies for her party. Find the rewards in your gift box.";
         this.m_messageInfo2.text = "Give Maggie some Party Masque to move on to the next milestone!";
         this.m_messageCash.text = "10";
      }
      
      public function displayWelcomeBackMessage() : void
      {
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageTitle.text = "Time’s Up!";
         this.m_messageOkay.visible = true;
         this.m_messageOkay.text = "Okay";
         this.m_messageOkay.enabled = true;
         this.m_messageOkay.callback = this.getOldTasksRedeemedFromUser;
         this.m_messageTicket_mc.visible = false;
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.loadIcon("assets/dialogs/twenties/Innovation/icon_welcome.png");
            itemBox.setIconSize(100,100);
            itemBox.visible = true;
         }
         this.m_messageInfo1.text = "Sorry Farmer, the gifting session has ended.";
         this.m_messageInfo2.text = "Don’t give up! Redeem the tasks for points and start a new session!";
      }
      
      public function getOldTasksRedeemedFromUser(e:Event = null) : void
      {
         this.m_message_mc.visible = false;
         this.m_taskFrame.visible = true;
      }
      
      public function displayDayFinishedMessage() : void
      {
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageTitle.text = "Congratulations!";
         this.m_messageOkay.visible = true;
         this.m_messageOkay.enabled = true;
         this.m_messageTicket_mc.visible = false;
         this.m_messageOkay.text = "Play Leaderboard!";
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.loadIcon("assets/dialogs/twenties/Innovation/icon_welcome.png");
            itemBox.setIconSize(100,100);
            itemBox.visible = true;
            itemBox.detachTooltip();
         }
         this.m_messageInfo1.text = "You have successfully helped Maggie get supplies for her party today!";
         this.m_messageInfo2.text = "Let’s move on to the After Party and try for the top rank on the Leaderboard!";
         this.m_messageOkay.callback = this.playForLeaderboardHelper;
      }
      
      public function playForLeaderboardHelper(e:Event = null) : void
      {
         if(this.m_glowLB_mc)
         {
            this.m_glowLB_mc.visible = true;
         }
         m_window["subtitle_tf"].text = "Complete tasks on the Leaderboard orderboard and win rewards together!";
         this.m_highlightLB_mc.visible = true;
         this.m_message_mc.visible = false;
         this.m_taskFrame.visible = true;
         this.m_messageOkay.visible = false;
         this.m_messageOkay.enabled = false;
         this.manager.playForLeaderboard();
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
            itemBox.loadIcon("assets/dialogs/twenties/Innovation/icon_welcome.png");
            itemBox.visible = true;
         }
         if(this.manager.getUserState() == this.manager.DONE_FOR_THE_DAY)
         {
            this.m_messageTitle.text = "A New Day Begins!";
            this.m_messageInfo1.text = "Click the button below to start sending Maggie Party Supplies.";
         }
         else
         {
            this.m_messageTitle.text = "A New Day Begins!";
            this.m_messageInfo1.text = "Click the button below to start sending Maggie Party Supplies.";
         }
         this.m_messageInfo2.text = "";
      }
      
      public function displayFeatureStartMessage() : void
      {
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageOkay.visible = true;
         this.m_messageTicket_mc.visible = false;
         this.m_messageOkay.callback = this.manager.startNewDay;
         this.m_messageOkay.text = "Start Now";
         this.m_messageTitle.text = "A New Day Begins!";
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.loadIcon("assets/dialogs/twenties/Innovation/icon_welcome.png");
            itemBox.visible = true;
         }
         this.m_messageInfo1.text = "Click the button below to start sending Maggie Party Supplies.";
         this.m_messageInfo2.text = "";
      }
      
      public function loadMessageIcon(farmItem:FarmItem) : void
      {
         var attachedToolTip:FarmTextTooltip = null;
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.loadIcon(farmItem.icon);
            itemBox.setIconSize(100,100);
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
      
      private function updateLBWeeklyReward() : void
      {
         var weekData:Object = this.manager.getCurrentWeek();
         var weekNum:int = int(weekData.count);
         this.m_leaderboardIconMc.gotoAndStop(weekNum);
      }
      
      private function updateAverageText() : void
      {
         if(this.m_averageTF)
         {
            this.m_averageTF.text = "Current Week Average - " + this.manager.getCurrentAverage();
         }
         var weekData:Object = this.manager.getCurrentWeek();
         var weekNum:int = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_TWENTIES) == true ? int(weekData.count) : int(weekData.count - 1);
         if(this.m_pointsCountTfArray)
         {
            this.m_pointsCountTfArray[weekNum - 1].text = this.manager.getCurrentAverage().toString();
         }
         this.updateHappinessMeter();
      }
      
      private function updateHappinessMeter() : void
      {
         var curAvg:int = this.manager.getCurrentAverage();
         if(curAvg > this.manager.VAL_THIRD_MILESTONE)
         {
            curAvg = this.manager.VAL_THIRD_MILESTONE;
         }
         var barAngle:Number = this.PROGRESS_BAR_START_ANGLE + curAvg * this.PROGRESS_BAR_FULL_ANGLE / this.manager.VAL_THIRD_MILESTONE;
         if(this.m_pointerMc)
         {
            this.m_pointerMc.rotation = barAngle;
         }
      }
      
      public function updateRewardImage() : void
      {
         if(this.m_level_tf != null)
         {
            this.m_level_tf.text = "Level: " + this.manager.getCurrentLevel() + "/5";
            this.m_level_tf.visible = true;
         }
         if(m_window.hasOwnProperty("icon3_mc"))
         {
            this.m_buildingIconMc = new FarmIcon(m_window["icon3_mc"]);
            if(this.m_buildingIconMc)
            {
               this.m_buildingIconMc.loadIcon(this.manager.REWARD_ITEM[int(this.manager.getCurrentLevel())]);
               this.attachTooltipToGiftBox(this.m_buildingIconMc);
               this.m_buildingIconMc.visible = true;
            }
         }
      }
      
      public function updateWeeklyTable() : void
      {
         var j:int = 0;
         var k:int = 0;
         var curAvg:int = this.manager.getCurrentAverage();
         var activeInd:int = this.manager.activeDayIndex;
         var weekInd:int = activeInd / 7;
         if(this.m_ptsArray[weekInd])
         {
            for(j = 0; j < weekInd; j++)
            {
               this.m_ptsArray[j].text = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_TWENTIES) == true ? this.manager.getAverageForTheWeek(j).toString() : this.manager.getAverageForTheWeek(j + 1).toString();
               this.m_ptsArray[j].visible = true;
            }
            if(weekInd < this.m_noOfWeek)
            {
               this.m_ptsArray[weekInd].text = curAvg.toString();
               this.m_ptsArray[weekInd].visible = true;
            }
            for(k = weekInd + 1; k < this.m_noOfWeek; k++)
            {
               this.m_ptsArray[k].text = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_TWENTIES) == true ? this.manager.getAverageForTheWeek(k).toString() : this.manager.getAverageForTheWeek(k + 1).toString();
               this.m_ptsArray[k].visible = true;
            }
         }
      }
      
      public function updateWeeklyState() : void
      {
         var j:int = 0;
         var averageForTheWeek:int = 0;
         var toolTipText:String = null;
         var k:int = 0;
         var activeInd:int = this.manager.activeDayIndex;
         var weekInd:int = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_TWENTIES) == true ? int(activeInd / 7) : int(activeInd / 7 - 1);
         if(this.m_statesArray[weekInd])
         {
            this.m_statesArray[weekInd].visible = true;
            for(j = 0; j < weekInd; j++)
            {
               if(this.m_statesMcArray[j].tooltip)
               {
                  this.m_statesMcArray[j].tooltip.release();
               }
               this.m_statesMcArray[j].detachTooltip();
               averageForTheWeek = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_TWENTIES) == true ? this.manager.getAverageForTheWeek(j) : this.manager.getAverageForTheWeek(j + 1);
               toolTipText = "Your average was " + averageForTheWeek.toString() + " points for Week " + (j + 1).toString();
               if(averageForTheWeek >= this.manager.VAL_CLASSIC)
               {
                  this.m_statesArray[j].gotoAndStop(2);
                  this.m_statesMcArray[j].attachTooltip(new FarmTextTooltip(toolTipText));
               }
               else if(averageForTheWeek >= this.manager.VAL_SUPERB)
               {
                  this.m_statesArray[j].gotoAndStop(6);
                  this.m_statesMcArray[j].attachTooltip(new FarmTextTooltip(toolTipText));
               }
               else if(averageForTheWeek >= this.manager.VAL_GOOD)
               {
                  this.m_statesArray[j].gotoAndStop(5);
                  this.m_statesMcArray[j].attachTooltip(new FarmTextTooltip(toolTipText));
               }
               else if(averageForTheWeek > 0)
               {
                  this.m_statesMcArray[j].attachTooltip(new FarmTextTooltip(toolTipText));
                  this.m_statesArray[j].gotoAndStop(3);
               }
               else
               {
                  this.m_statesMcArray[j].attachTooltip(new FarmTextTooltip(toolTipText));
                  this.m_statesArray[j].gotoAndStop(4);
               }
               if(this.m_statesActiveArray[j])
               {
                  this.m_statesActiveArray[j].visible = false;
               }
            }
            if(weekInd < this.m_noOfWeek)
            {
               if(this.manager.activeDayIndex % 7 == 6 && this.manager.getUserState() == this.manager.DONE_FOR_THE_DAY || this.manager.hasActiveWeekExpired())
               {
                  if(this.m_statesMcArray[weekInd].tooltip)
                  {
                     this.m_statesMcArray[weekInd].tooltip.release();
                  }
                  this.m_statesMcArray[weekInd].detachTooltip();
                  averageForTheWeek = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_TWENTIES) == true ? this.manager.getAverageForTheWeek(j) : this.manager.getAverageForTheWeek(j + 1);
                  toolTipText = "Your average was " + averageForTheWeek.toString() + " points for Week " + (j + 1).toString();
                  if(averageForTheWeek >= this.manager.VAL_CLASSIC)
                  {
                     this.m_statesArray[j].gotoAndStop(2);
                     this.m_statesMcArray[j].attachTooltip(new FarmTextTooltip(toolTipText));
                  }
                  else if(averageForTheWeek >= this.manager.VAL_SUPERB)
                  {
                     this.m_statesArray[j].gotoAndStop(6);
                     this.m_statesMcArray[j].attachTooltip(new FarmTextTooltip(toolTipText));
                  }
                  else if(averageForTheWeek >= this.manager.VAL_GOOD)
                  {
                     this.m_statesArray[j].gotoAndStop(5);
                     this.m_statesMcArray[j].attachTooltip(new FarmTextTooltip(toolTipText));
                  }
                  else if(averageForTheWeek > 0)
                  {
                     this.m_statesMcArray[j].attachTooltip(new FarmTextTooltip(toolTipText));
                     this.m_statesArray[j].gotoAndStop(3);
                  }
                  else
                  {
                     this.m_statesMcArray[j].attachTooltip(new FarmTextTooltip(toolTipText));
                     this.m_statesArray[j].gotoAndStop(4);
                  }
               }
               else
               {
                  this.m_statesArray[weekInd].gotoAndStop(1);
                  if(this.m_statesMcArray[weekInd].tooltip)
                  {
                     this.m_statesMcArray[weekInd].tooltip.release();
                  }
                  this.m_statesMcArray[weekInd].detachTooltip();
                  toolTipText = "Get a Legendary Party rating this week to upgrade your " + TwentiesInnovationManager.BONUS_NAME_ARRAY[int(this.manager.getCurrentLevel())];
                  this.m_statesMcArray[weekInd].attachTooltip(new FarmTextTooltip(toolTipText));
               }
               if(this.m_statesActiveArray[weekInd])
               {
                  this.m_statesActiveArray[weekInd].visible = true;
               }
               for(k = weekInd + 1; k < this.m_noOfWeek; k++)
               {
                  if(this.m_statesArray[k])
                  {
                     this.m_statesArray[k].gotoAndStop(4);
                  }
                  if(this.m_statesActiveArray[k])
                  {
                     if(this.m_statesMcArray[k].tooltip)
                     {
                        this.m_statesMcArray[k].tooltip.release();
                     }
                     this.m_statesMcArray[k].detachTooltip();
                     this.m_statesMcArray[k].attachTooltip(new FarmTextTooltip("Wait for this week to unlock!"));
                     this.m_statesActiveArray[k].visible = false;
                  }
               }
            }
         }
      }
      
      public function updateSmallMeters(onOpenWindow:Boolean = false) : void
      {
         var curDayInd:int = 0;
         var normalizedPoints:Number = NaN;
         var barLength:Number = NaN;
         var dayPoints:int = 0;
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
            normalizedPoints = dayPoints;
            if(dayPoints > 20)
            {
               normalizedPoints = 20 + (dayPoints - 20) * 10 / 15;
            }
            barLength = normalizedPoints * this.SMALL_PROGRESS_BAR_FULL_WIDTH / this.DAILY_DUMMY_MAX_POINT;
            if(this.m_barMcArray[index])
            {
               if(onOpenWindow)
               {
                  this.m_barMcArray[index].height = barLength;
               }
               else
               {
                  TweenMax.to(this.m_barMcArray[index],2,{"height":barLength});
               }
            }
         }
      }
      
      public function updateCurrentDayMeter(onOpenWindow:Boolean = false) : void
      {
         var index:int = this.manager.activeDayIndex % 7;
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
         var barLength:Number = normalizedPoints * this.SMALL_PROGRESS_BAR_FULL_WIDTH / this.DAILY_DUMMY_MAX_POINT;
         if(this.m_barMcArray[index])
         {
            if(onOpenWindow)
            {
               this.m_barMcArray[index].height = barLength;
            }
            else
            {
               TweenMax.to(this.m_barMcArray[index],2,{"height":barLength});
            }
         }
      }
      
      override public function refreshWindow() : void
      {
         this.m_checkMark_mc.visible = false;
         if(this.m_weeklyHeadingTf)
         {
            this.m_weeklyHeadingTf.visible = false;
         }
         this.m_consumableCount_tf.text = "x" + this.manager.consumableCount.toString();
         this.refreshTaskFrame();
         this.refreshLeaderboardFrame();
         this.updateConsumableCount();
         this.updateAverageText();
         this.updateLBWeeklyReward();
         this.updateWeeklyTable();
         this.updateSmallMeters();
         this.updateProgressBar();
         this.updateActiveDayIndex();
         this.updateWeeklyState();
      }
      
      public function updateDayBonus() : void
      {
         var finalMileStoneItem:FarmItem = null;
         if(m_window.hasOwnProperty("best_icon_50_mc"))
         {
            this.m_dailyReward_mc = m_window["best_icon_50_mc"] as MovieClip;
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
               this.m_rewardIconMcArray[mileStoneRewardIndex].setIconSize(70,70);
               this.m_rewardIconMcArray[mileStoneRewardIndex].setSmoothing(true);
            }
         }
      }
      
      public function updateActiveDayIndex() : void
      {
         var dayInd:* = 0;
         while(dayInd < this.m_sessionMcArray.length)
         {
            this.m_sessionMcArray[dayInd].visible = false;
            this.m_barGlowArray[dayInd++].visible = false;
         }
         dayInd = int(this.manager.activeDayIndex % 7);
         this.m_sessionMcArray[dayInd].visible = true;
         this.m_barGlowArray[dayInd].visible = true;
      }
      
      private function getFeatureTimeLeft() : String
      {
         return this.manager.getFeatureEndDaysLeftText();
      }
      
      private function getTimeLeft() : String
      {
         var timeRemaining:Array = this.manager.getTimeRemaining();
         var timeLeft:String = "";
         if(parseInt(timeRemaining[0]) > 1)
         {
            timeLeft = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"BBWinter_TimeLeftDays",{"time":timeRemaining[0]});
         }
         else
         {
            timeLeft = "1 day remaining";
         }
         return timeLeft;
      }
      
      private function get manager() : TwentiesInnovationManager
      {
         return TwentiesInnovationManager.getInstance(FEATURE_NAME);
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
            if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_TWENTIES) && WorldSeasonsManager.getInstance().isEAWeek(WorldsConstants.WORLD_ID_TWENTIES))
            {
               if(i == 0 && Boolean(m_EA_week_mc))
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
               this.m_messageTitle.text = "Let\'s get the Party Started!";
               this.m_messageInfo1.text = "Start a session now to send Maggie Party Supplies!";
               this.m_messageOkay.text = "Let’s Do It!";
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
      
      public function openMiniMarket(e:Event) : void
      {
         this.manager.unlockLandFromBuyWindow();
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
         FarmStatsManager.count("TwentiesInnovation","Main_UI","close_window");
         super.close();
      }
      
      public function showtileUnlockOverlay() : void
      {
         var count:int = this.manager.getTileUnlockCount();
         if(count > 0)
         {
            this.m_tileUnlockCount_tf.text = (count * 30).toString();
            this.m_overlay_tf.text = "Congratulations!";
            if(count > 1)
            {
               this.m_tileUnlockDes_tf.text = "You just got " + (count * this.TILE_UNLOCK_CONSUMABLE_COUNT).toString() + " Party Masques on unlocking " + count.toString() + " tiles!";
            }
            else
            {
               this.m_tileUnlockDes_tf.text = "You just got " + (count * this.TILE_UNLOCK_CONSUMABLE_COUNT).toString() + " Party Masques on unlocking " + count.toString() + " tile!";
            }
            this.m_tileUnlock_mc.visible = true;
            this.m_tileUnlock_mc.gotoAndStop(1);
         }
      }
   }
}

