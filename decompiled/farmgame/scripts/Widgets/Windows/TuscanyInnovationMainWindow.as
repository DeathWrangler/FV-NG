package Widgets.Windows
{
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.FarmStatsManager;
   import Managers.TuscanyInnovationManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Frames.TuscanyInnovationTaskFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   
   public class TuscanyInnovationMainWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 7;
      
      public static const ICON_SIZE:int = 50;
      
      private static const FEATURE_NAME:String = "TuscanyInnovation";
      
      private var m_featureName:String = null;
      
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
      
      private var m_taskFrame:TuscanyInnovationTaskFrame;
      
      private var m_descriptionTf:ZwTextField;
      
      private var m_finishTitle:ZwTextField;
      
      private var m_finishBody:ZwTextField;
      
      private var m_finishMc:MovieClip;
      
      protected var m_DumpTutorial:ZwFrame = null;
      
      private var m_DumptutorialScene:int = 0;
      
      private const PROGRESS_BAR_FULL_WIDTH:int = 270;
      
      private var m_consumable_mc:MovieClip;
      
      private const CONSUMABLE_MC:String = "consumable_mc";
      
      private const ASK_BT:String = "ask_bt";
      
      private const CRAFT_BT:String = "craft_bt";
      
      private const COUNT_TF:String = "count_tf";
      
      private var m_consumableCount_tf:ZwTextField;
      
      private var m_progress_record_array:Array = [];
      
      private const PROGRESS_RECORDS_COUNTER:String = "feature_progress_small_mc";
      
      private const DAILY_PROGRESS_MC:String = "meter_mc";
      
      private var m_progress_record_mc:MovieClip;
      
      private var m_daily_progress_mc:MovieClip;
      
      private var m_barMc:MovieClip;
      
      private var m_dailyTimer_tf:ZwTextField;
      
      private var m_dailyTimerMc:MovieClip;
      
      private const SINK_BT:String = "sink_bt";
      
      private var m_message_mc:MovieClip;
      
      private var m_messageTitle:ZwTextField;
      
      private var m_messageInfo1:ZwTextField;
      
      private var m_messageInfo2:ZwTextField;
      
      private var m_messageOkay:FarmAnimatedTextButton;
      
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
      
      private var m_progressLevelArray_tf:Array;
      
      private const ProgressLevelTextArray:Array = ["Good","Superb","Classic"];
      
      private const EARNED_POINTS_MC:String = "earned_points_mc";
      
      private const DAILY_PROGRESS_BAR_FULL_WIDTH:int = 70;
      
      private var m_lock1HoverText:ZwTextField;
      
      private var m_lock2HoverText:ZwTextField;
      
      private const REWARD_EA_WEEK:String = "reward_EA_mc";
      
      private var m_EA_week_mc:MovieClip;
      
      private var m_earnedPt_mc:MovieClip;
      
      private var m_idleNPC:MovieClip;
      
      private var m_jumpNPC:MovieClip;
      
      private var m_stompNPC:MovieClip;
      
      private var m_ask_bt:FarmAnimatedTextButton;
      
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
      
      public function TuscanyInnovationMainWindow(featureName:String = "TuscanyInnovation", assetUrl:String = null, showEAPageTutorial:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_showTutorialWithEAPage = showEAPageTutorial;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(FEATURE_NAME,assetUrl,numOfTutorialPages);
      }
      
      override protected function postLoadComplete() : void
      {
         var index:int = 0;
         var i:int = 0;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"The Grape Escape!"));
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            this.m_descriptionTf = addWidget(new ZwTextField(m_window[this.BODY_TF],"Welcome to your beautiful Tuscan Vineyard. It’s Grape Stomping Season!")) as ZwTextField;
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
         if(m_window.hasOwnProperty(this.EARNED_POINTS_MC))
         {
            this.m_earnedPt_mc = m_window[this.EARNED_POINTS_MC] as MovieClip;
            this.m_earnedPt_mc.visible = true;
         }
         if(m_window.hasOwnProperty(this.CONSUMABLE_MC))
         {
            this.m_consumable_mc = m_window[this.CONSUMABLE_MC] as MovieClip;
            (this.m_consumable_mc["dumpBG_mc"] as MovieClip).visible = true;
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
            if(this.m_consumable_mc.hasOwnProperty(this.SINK_BT))
            {
               addWidget(this.m_sinkBt = new FarmAnimatedCashButton(this.m_consumable_mc[this.SINK_BT],"Crush",this.manager.consumableNeededForUnlock().toString(),this.onSinkButtonClick));
               this.m_sinkBtTooltip = new FarmTextTooltip(this.manager.getSinkButtonToolTipMessage());
               this.m_sinkBt.attachTooltip(this.m_sinkBtTooltip);
            }
            if(this.m_consumable_mc.hasOwnProperty(this.BUY_BT))
            {
               addWidget(new FarmAnimatedTextButton(this.m_consumable_mc[this.BUY_BT],"Buy",this.buyCallback));
            }
            if(this.m_consumable_mc.hasOwnProperty("barrel_mc"))
            {
               this.m_barrel_mc = new ZwFrame(this.m_consumable_mc["barrel_mc"]);
               this.m_barrel_mc.attachTooltip(new FarmTextTooltip("Grape Barrel"));
            }
         }
         if(m_window.hasOwnProperty("lastDay_mc"))
         {
            this.m_featureEndMc = m_window["lastDay_mc"] as MovieClip;
            this.m_featureEndMc["title_tf"].text = "Festival Time Over!";
            this.m_featureEndMc["body_tf"].text = "Amico! The stomping season has now come to an end. Thank you for your participation!";
            this.m_featureEndMc["body2_tf"].text = "You can refresh your browser to get your reward!";
            this.m_featureEndMc["close_bt"].visible = false;
            new FarmAnimatedTextButton(this.m_featureEndMc["accept_bt"],"Okay",onClose);
            this.m_featureEndMc.visible = this.manager.hasFeatureExpired();
         }
         if(m_window.hasOwnProperty("crushHelp_mc"))
         {
            this.m_crushHelp_mc = m_window["crushHelp_mc"];
            if(this.m_crushHelp_mc)
            {
               this.m_crushHelp_mc.visible = false;
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
            }
            this.m_progressLevelArray_mc = [];
            this.m_progressLevelArray_tf = [];
            this.m_progressLevelArrarZFrame = [];
            for(i = 0; i < 3; i++)
            {
               this.m_progressLevelArray_mc[i] = this.m_progress_record_mc["level" + (i + 1).toString() + "_mc"] as MovieClip;
               this.m_progressLevelArray_mc[i].visible = true;
               this.m_progressLevelArrarZFrame[i] = new ZwFrame(this.m_progressLevelArray_mc[i]);
               this.m_progressLevelArrarZFrame[i].attachTooltip(this.m_avgTooltip[i] = new FarmTextTooltip(this.overAllProgressButtonsTooltip(i)));
               this.m_progressLevelArray_tf[i] = new ZwTextField(this.m_progressLevelArray_mc[i]["level_tf"],this.ProgressLevelTextArray[i]);
               this.m_progressLevelArray_tf[i].visible = true;
            }
            if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_TUSCANY))
            {
               (this.m_progress_record_mc["GA_mc"] as MovieClip).visible = false;
            }
            else
            {
               (this.m_progress_record_mc["EA_mc"] as MovieClip).visible = false;
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
            this.m_messageTitle = new ZwTextField(this.m_message_mc[this.TITLE_TF],"");
            this.m_messageInfo1 = new ZwTextField(this.m_message_mc["info1_tf"],"");
            this.m_messageInfo2 = new ZwTextField(this.m_message_mc["info2_tf"],"");
            if(this.m_message_mc.hasOwnProperty("okay_bt"))
            {
               this.m_messageOkay = new FarmAnimatedTextButton(this.m_message_mc["okay_bt"],"",null);
            }
            if(this.m_message_mc.icon_mc != null)
            {
               addWidget(new FarmIcon(this.m_message_mc.icon_mc));
            }
         }
         if(m_window.hasOwnProperty(this.FEATURE_TIMER_MC))
         {
            this.m_featureTimer_mc = m_window[this.FEATURE_TIMER_MC] as MovieClip;
            this.m_featureTimer_mc.visible = true;
            if(this.m_featureTimer_mc.hasOwnProperty(this.FEATURE_TIMER_TF))
            {
               addWidget(this.m_FeatureTimer = new ZwTextField(this.m_featureTimer_mc[this.FEATURE_TIMER_TF],this.getFeatureTimeLeft()));
               this.m_FeatureTimer.visible = true;
            }
         }
         if(m_window.hasOwnProperty(this.DAILY_TIMER_MC))
         {
            this.m_dailyTimerMc = m_window[this.DAILY_TIMER_MC] as MovieClip;
            this.m_timerToolTip = new FarmTextTooltip(this.dayTooltip);
            this.m_dailyTimerMc.visible = true;
            addWidget(this.m_timerWidget = new ZwFrame(this.m_dailyTimerMc),true);
            this.m_timerWidget.attachTooltip(this.m_timerToolTip);
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
            this.m_taskFrame = new TuscanyInnovationTaskFrame(m_window[this.TASKS_MC],this,this.m_featureName);
            this.m_taskFrame.visible = true;
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
            this.m_lock1HoverText = new ZwTextField(this.m_lock1Hover["info1_tf"],"To Unlock Superb Level Crush 5 Barrels");
         }
         if(m_window.hasOwnProperty("level_lock2_hover"))
         {
            this.m_lock2Hover = m_window["level_lock2_hover"] as MovieClip;
            this.m_lock2Hover.visible = false;
            this.m_lock2HoverText = new ZwTextField(this.m_lock2Hover["info1_tf"],"To Unlock Classic Level Crush 10 Barrels");
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
            this.m_idleNPC.visible = false;
         }
         if(m_window.hasOwnProperty("jump_ani_mc"))
         {
            this.m_jumpNPC = m_window["jump_ani_mc"] as MovieClip;
            this.m_jumpNPC.visible = false;
         }
         if(m_window.hasOwnProperty("stomp_ani_mc"))
         {
            this.m_stompNPC = m_window["stomp_ani_mc"] as MovieClip;
            this.m_stompNPC.visible = true;
            this.playStompingAnimation();
         }
         addWidget(this.m_tileUnlock_bt = new FarmAnimatedTextButton(m_window["consumable_mc"]["unlock_bt"],"Unlock Tile",this.openMiniMarket));
         if(this.manager.lockedTilesArray.length <= 0)
         {
            this.m_tileUnlock_bt.enabled = false;
            this.m_tileUnlock_bt.callback = null;
            this.m_tileUnlock_bt.applyGrayOut = true;
            FarmGameUtil.disableButtonAndShowTooltip(this.m_tileUnlock_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_MainWindow_UnlockTileText2"));
         }
         this.updateDayBonus();
         this.refreshTaskFrame();
         this.updateProgressBar(true);
         this.startTimer();
         this.updateSmallProgressBars();
         if(this.m_showTutorialWithEAPage)
         {
            this.showTutorialWithEAPage();
         }
      }
      
      public function CloseCrushMC(e:Event = null) : void
      {
         this.m_crushHelp_mc.visible = false;
      }
      
      private function overAllProgressButtonsTooltip(index:int) : String
      {
         var tooltip:String = "";
         if(this.manager.overAllProgressLevel() == index)
         {
            tooltip = "Your average score : " + this.manager.currentAverage.toString() + "\n";
         }
         return tooltip + ("Average range of points for " + this.ProgressLevelTextArray[index] + " Winery : " + this.RANGE_ARRAY[index]);
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
         for(var index:int = 0; index < 42; index++)
         {
            dayPoints = this.manager.getpointsForTheDay(index);
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
               }
               else
               {
                  TweenMax.to(this.m_progress_record_array[index].bar_fill_mc,2,{"height":barLength});
               }
            }
            this.m_progress_record_array[index] = this.m_progress_record_mc["day_" + index.toString() + "_mc"];
            if(Boolean(this.m_progress_record_array[index]) && index >= this.manager.activeDayIndex)
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
            }
            else
            {
               TweenMax.to(this.m_progress_record_array[index].bar_fill_mc,2,{"height":barLength});
            }
         }
      }
      
      private function updateOverallProgressButtons() : void
      {
         for(var i:int = 0; i < 3; i++)
         {
            if(i == this.manager.overAllProgressLevel())
            {
               this.m_progressLevelArray_mc[i].gotoAndStop(2);
            }
            else
            {
               this.m_progressLevelArray_mc[i].gotoAndStop(1);
            }
            this.m_avgTooltip[i].setText(this.overAllProgressButtonsTooltip(i));
         }
      }
      
      override protected function preSwitchChanges(sceneNumber:int) : void
      {
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_TUSCANY) == true)
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
         this.m_dailyTimer_tf.text = HUD.getformattedTimeLeft(this.manager.getTimeLeftInDay());
         if(this.manager.hasActiveDayExpired() == false)
         {
            if(this.manager.getUserState() == this.manager.DONE_FOR_THE_DAY)
            {
               this.m_messageInfo2.text = "You can start stomping away again in " + HUD.getformattedTimeLeft(this.manager.getTimeLeftInDay());
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
            xPostTimeRemaining = this.manager.getThrottleTimeRemaining(TuscanyInnovationManager.FEED_NAME);
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
               this.m_earnedPt_mc.y = 416 - barLength;
            }
            else if(onOpenWindow == false)
            {
               TweenMax.to(this.m_barMc,2,{"height":barLength});
               TweenMax.to(this.m_earnedPt_mc,2,{"y":416 - barLength});
            }
            else
            {
               this.m_barMc.height = barLength;
               this.m_earnedPt_mc.y = 416 - barLength;
            }
         }
         this.updateCurrentdaySmallProgressBars();
      }
      
      public function refreshTaskFrame(e:Event = null) : void
      {
         if(this.manager.getUserState() == this.manager.NOT_INITIALIZED)
         {
            this.displayFeatureStartMessage();
         }
         else if(this.manager.hasActiveDayExpired())
         {
            if(this.manager.rdeemableTaskCount() > 0 && this.manager.getUserState() != this.manager.DONE_FOR_THE_DAY)
            {
               if(this.manager.redeemHasStarted == false)
               {
                  this.displayWelcomeBackMessage();
               }
            }
            else
            {
               this.displayDayStartMessage();
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
            this.displayDayFinishedMessage();
         }
         else
         {
            this.m_message_mc.visible = false;
            this.m_taskFrame.visible = true;
         }
         this.refreshLockVisiblility();
         this.m_sinkBt.setAmountText(this.manager.consumableNeededForUnlock().toString());
         var tooltip:String = this.manager.getSinkButtonToolTipMessage();
         if(this.m_sinkBtTooltip)
         {
            this.m_sinkBtTooltip.setText(tooltip);
         }
         if(this.manager.isSinkActive())
         {
            this.m_sinkBt.enabled = true;
            this.m_sinkBt.callback = this.onSinkButtonClick;
         }
         else
         {
            this.m_sinkBt.callback = null;
            this.m_sinkBt.enabled = false;
            this.m_sinkBt.element.mouseEnabled = this.m_sinkBt.element.mouseChildren = true;
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
         this.m_messageOkay.visible = false;
         this.m_messageTitle.text = "Congrats Wine Expert!";
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.visible = false;
         }
         var rewardItem:FarmItem = this.manager.getActiveDayReward(this.manager.EASY);
         this.loadMessageIcon(rewardItem);
         this.m_messageInfo1.text = "Your stomping chops has created Good Wine and won you " + rewardItem.friendlyTitle + ". Find it in your gift box!";
         this.m_messageInfo2.text = "Crush 5 Grape Barrels to start creating Superb Wine!";
         if(Global.player.getSeenFlag(this.manager.CRUSH_BARREL_TUTORIAL) == false)
         {
            this.m_crushHelp_mc.visible = true;
            if(this.manager.hasEnoughConsumableToSink())
            {
            }
            Global.player.setSeenFlag(this.manager.CRUSH_BARREL_TUTORIAL);
         }
      }
      
      public function displayLock2Message() : void
      {
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageOkay.visible = false;
         this.m_messageTitle.text = "Congrats Wine Prodigy!";
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.visible = false;
         }
         var rewardItem:FarmItem = this.manager.getActiveDayReward(this.manager.MEDIUM);
         this.loadMessageIcon(rewardItem);
         this.m_messageInfo1.text = "Your stomping chops has created Superb Wine and won you " + rewardItem.friendlyTitle + ". Find it in your gift box!";
         this.m_messageInfo2.text = "Crush 10 Grape Barrels to start creating Classic Wine!";
         if(Global.player.getSeenFlag(this.manager.CRUSH_BARREL_TUTORIAL) == false)
         {
            this.m_crushHelp_mc.visible = true;
            if(this.manager.hasEnoughConsumableToSink())
            {
            }
            Global.player.setSeenFlag(this.manager.CRUSH_BARREL_TUTORIAL);
         }
      }
      
      public function displayWelcomeBackMessage() : void
      {
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageTitle.text = "Sour Grapes!";
         this.m_messageOkay.visible = true;
         this.m_messageOkay.text = "Let’s Go";
         this.m_messageOkay.callback = this.getOldTasksRedeemedFromUser;
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.loadIcon("assets/dialogs/tuscany/innovation/icon_welcome.png");
            itemBox.visible = true;
         }
         this.m_messageInfo1.text = "Sorry Amico, the winemaking session has ended.";
         this.m_messageInfo2.text = "Go ahead and redeem points for completed tasks to start a new session";
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
         this.m_messageTitle.text = "Congrats Wine Maestro!";
         this.m_messageOkay.visible = false;
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.loadIcon("assets/dialogs/tuscany/innovation/icon_welcome.png");
            itemBox.visible = true;
         }
         this.m_messageInfo1.text = "You have completed today\'s Wine Meter.";
      }
      
      public function displayDayStartMessage() : void
      {
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageOkay.visible = true;
         this.m_messageOkay.callback = this.manager.startNewDay;
         this.m_messageOkay.text = "Start Stomping";
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.loadIcon("assets/dialogs/tuscany/innovation/icon_welcome.png");
            itemBox.visible = true;
         }
         if(this.manager.getUserState() == this.manager.DONE_FOR_THE_DAY)
         {
            this.m_messageTitle.text = "Hey Wine Maestro!!";
            this.m_messageInfo1.text = "Last winemaking session has ended.";
         }
         else
         {
            this.m_messageTitle.text = "Sour Grapes!";
            this.m_messageInfo1.text = "Sorry Amico, the winemaking session has ended.";
         }
         this.m_messageInfo2.text = "Let’s go ahead and start a new grape stomping session";
      }
      
      public function displayFeatureStartMessage() : void
      {
         this.m_message_mc.visible = true;
         this.m_taskFrame.visible = false;
         this.m_messageOkay.visible = true;
         this.m_messageOkay.callback = this.manager.startNewDay;
         this.m_messageOkay.text = "Start Stomping";
         this.m_messageTitle.text = "Evento Time!";
         var itemBox:FarmIcon = getWidget(this.m_message_mc["icon_mc"]) as FarmIcon;
         if(itemBox)
         {
            itemBox.loadIcon("assets/dialogs/tuscany/innovation/icon_welcome.png");
            itemBox.visible = true;
         }
         this.m_messageInfo1.text = "It\'s time to begin the festivities, Amico! ";
         this.m_messageInfo2.text = "Click on the button below to start on the Stomping fun!";
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
            if(finalMileStoneItem.code != this.manager.WINERY_BOOSTER_CODE)
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
      
      private function updateActiveDayIndex() : void
      {
         if(this.m_session_mc)
         {
            this.m_session_mc.visible = false;
         }
         for(var index:int = 0; index < 42; index++)
         {
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
         }
      }
      
      private function getFeatureTimeLeft() : String
      {
         return this.manager.getFeatureEndDaysLeftText();
      }
      
      private function get manager() : TuscanyInnovationManager
      {
         return TuscanyInnovationManager.getInstance(FEATURE_NAME);
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
            if(i == 0 && WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_TUSCANY))
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
         FarmStatsManager.count("WhitewinterInnovation","Unlock Tile");
         TuscanyInnovationManager.getInstance().highlightTiles();
         FarmStatsManager.count("GrapeEscape","UnlockTile","tile_unlock","click");
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
         FarmStatsManager.count("GrapeEscape","Main_UI","close_window");
         super.close();
      }
   }
}

