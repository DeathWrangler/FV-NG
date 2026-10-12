package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.FarmStatsManager;
   import Managers.OrderBoard.FarmRun2018Manager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmRun2018OrderboardFrame;
   import Widgets.Frames.FrontierInnovationCraftingSlotFrame;
   import Widgets.Frames.FrontierInnovationForageFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class FarmRun2018ScoreBoardWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 7;
      
      public static const ICON_SIZE:int = 50;
      
      private static const FEATURE_WELCOME_SEEN_FLAG:String = "Carribean_Welcome_flag";
      
      private static const FEATURE_DAILYPLAY_SEEN_FLAG:String = "Carribean_DailyPlayWelcome_flag";
      
      private static const FEATURE_NAME:String = "FarmRunV10_2020";
      
      public static const FARMRUN_QUIZ_TIMER_RAN_OUT_FLAG:String = "FarmRunV10_2020_QuizTimerRanOut";
      
      public static const FEATURE_OPTIONS_KEY:String = "FarmRunV10_2020";
      
      private var m_featureName:String = FEATURE_NAME;
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const DESCRIPTION_TF:String = "description_tf";
      
      private const OVERLAY_TF:String = "overlay_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const METER_MC:String = "meter_mc";
      
      private const DAILYMETER_MC:String = "dailymeter_mc";
      
      private const AXE_MC:String = "axe_mc";
      
      private const BARN_BT:String = "barn_bt";
      
      private const NOTIF_MC:String = "notif_mc";
      
      private const BOOST_BT:String = "boost_bt";
      
      private const FORAGE_BT:String = "forage_bt";
      
      private const MAIN_BG_MC:String = "main_bg_mc";
      
      private const CRAFTS_MC:String = "crafts_mc";
      
      private const DAILY_MC:String = "daily_mc";
      
      private const ICON_MC:String = "icon_mc";
      
      private const CHECKMARK_MC:String = "checkmark_mc";
      
      private const METER1_MC:String = "meter1_mc";
      
      private const METER2_MC:String = "meter2_mc";
      
      private const METER3_MC:String = "meter3_mc";
      
      private const METER4_MC:String = "meter4_mc";
      
      private const DAILY_TF:String = "daily_tf";
      
      private const TIMER_TF:String = "time_tf";
      
      private const FINISH_TF:String = "finish_tf";
      
      private const FLOAT_MC:String = "float_mc";
      
      private const FINISH_BODY_TF:String = "finish_subtext_tf";
      
      private const REWARDS_BT:String = "rewards_bt";
      
      private const FORAGE_MC:String = "forage_mc";
      
      private const TILEUNLOCK_MC:String = "tileUnlock_mc";
      
      private const ACHIEVEMENT_BT:String = "achieve_bt";
      
      private const FINISH_MC:String = "finish_mc";
      
      private const TILE_UNLCOK_MC:String = "tileUnlock_mc";
      
      private const NPC1:String = "npc1";
      
      private const NPC2:String = "npc2";
      
      private const NPC3:String = "npc3";
      
      private const NPC4:String = "npc4";
      
      private const PROFILE_MC:String = "profile_mc";
      
      private const PREVIEW1_MC:String = "preview1_mc";
      
      private const PREVIEW2_MC:String = "preview2_mc";
      
      private const PREVIEW3_MC:String = "preview3_mc";
      
      private const REWARD1_MC:String = "reward1_mc";
      
      private const REWARD2_MC:String = "reward2_mc";
      
      private const REWARD3_MC:String = "reward3_mc";
      
      private const ACHIEVE_REDEEM_MC:String = "achieve_redeem";
      
      private const POINTS_TF:String = "points_tf";
      
      private var m_forage_overlayMc:MovieClip;
      
      private const FORAGE_OVERLAY_MC:String = "frageoverlay_mc";
      
      private const TEXT_TITLE:String = "_title";
      
      private const TEXT_BODY:String = "_description";
      
      private const TEXT_BODY2:String = "_description_more";
      
      private const TEXT_FINISH_TITLE:String = "_finish_title";
      
      private const TEXT_FINISH_BODY:String = "_finish_description";
      
      private const TEXT_POSTFINISH_TITLE:String = "_postfinish_title";
      
      private const TEXT_POSTFINISH_BODY:String = "_postfinish_description";
      
      private const TEXT_REWARDS_BT:String = "_rewards_button";
      
      private const TEXT_BOOST_BT:String = "_boost_button";
      
      private const TEXT_BARN_BT:String = "_barn_button";
      
      private const TEXT_FORAGE_BT:String = "_forage_button";
      
      private const TEXT_ACHIEVEMENT_BT:String = "_achievement_button";
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      protected const LOADING_TF:String = "loading_tf";
      
      public var m_meter_mc:MovieClip;
      
      private var m_preview1_mc:ZwFrame;
      
      private var m_preview2_mc:ZwFrame;
      
      private var m_preview3_mc:ZwFrame;
      
      private var m_reward1_mc:MovieClip;
      
      private var m_reward2_mc:MovieClip;
      
      private var m_reward3_mc:MovieClip;
      
      private var m_descriptionTf:ZwTextField;
      
      private var m_finishTitle:ZwTextField;
      
      private var m_finishBody:ZwTextField;
      
      private var m_finishMc:MovieClip;
      
      private var m_world1_mc:MovieClip;
      
      private var m_world2_mc:MovieClip;
      
      private var m_world3_mc:MovieClip;
      
      private var m_world4_mc:MovieClip;
      
      protected var m_tileUnlock:ZwFrame = null;
      
      private const PROGRESS_BAR_FULL_WIDTH:int = 600;
      
      private const NPC_WIDTH_X:int = 250;
      
      private const MAX_POINT:int = 3000;
      
      private const MAX_DAILYPOINT:int = 50;
      
      private var m_isEA:Boolean;
      
      private var m_boostBt:FarmAnimatedButton;
      
      private var m_barnBt:FarmAnimatedButton;
      
      private var m_forageBt:FarmAnimatedButton;
      
      public var m_notifMc:MovieClip;
      
      private const TEXT_REWARD1_HOVER:String = "Earn 300 Points";
      
      private const TEXT_REWARD2_HOVER:String = "Earn 900 Points";
      
      private const TEXT_REWARD3_HOVER:String = "Earn 1800 Points";
      
      private const FULL_SCORE:String = "_QuizFullScore";
      
      private const PARTIAL_SCORE:String = "_QuizPartialScore";
      
      private const TIME_UP:String = "_QuizTimeUp";
      
      private const QUIZ_FINISHED_TIMER:String = "_QuizFinishedTimeUp";
      
      private const QUIZ_FINISHED:String = "_QuizFinished";
      
      private const TEXT_NPC1_NAME:String = "Catalina";
      
      private const TEXT_NPC2_NAME:String = "Matias";
      
      private const TEXT_NPC3_NAME:String = "Santiago";
      
      private const TEXT_PLAYER_NAME:String = "You";
      
      private const MAX_FRANCHISE_COUNT:int = 8;
      
      private var m_franchiseMc:MovieClip;
      
      private var m_boardMc:MovieClip;
      
      private var m_axeMc:MovieClip;
      
      private var m_tileUnlockMc:MovieClip;
      
      private var m_main_bg_Mc:MovieClip;
      
      private var m_crafts_Mc:MovieClip;
      
      private var m_collectConsumable:FarmAnimatedTextButton;
      
      private var m_consumableCount:ZwTextField;
      
      private var m_achievementBt:FarmAnimatedTextButton;
      
      private var m_resultMc:MovieClip;
      
      public var m_timer_Mc:MovieClip;
      
      private var m_pointsMc:MovieClip;
      
      private var m_scoreMc:MovieClip;
      
      private var m_countMc:MovieClip;
      
      private var m_npcMc:MovieClip;
      
      private var m_talkMc:MovieClip;
      
      private var m_talk_tf:ZwTextField;
      
      public var m_scoreDialog_tf:ZwTextField;
      
      private var m_npc1Tf:ZwTextField;
      
      private var m_npc2Tf:ZwTextField;
      
      private var m_talkAutoMc:MovieClip;
      
      private var m_autoTalkMc:MovieClip;
      
      private var m_autoNpc1Tf:ZwTextField;
      
      private var m_autoNpc2Tf:ZwTextField;
      
      private var m_hitWidget1:ZwFrame;
      
      private var m_level0Mc:MovieClip;
      
      private var m_level1Mc:MovieClip;
      
      private var m_level2Mc:MovieClip;
      
      private var m_okay_button:FarmAnimatedTextButton;
      
      public var m_pointerMc:MovieClip;
      
      private const BAR_INITIAL_POSTION:Number = 532;
      
      private var m_level1HitWidget:ZwFrame;
      
      private var m_level2HitWidget:ZwFrame;
      
      private var m_npcHitWidget:ZwFrame;
      
      private var m_overlayMc:MovieClip;
      
      private var m_overlay2Mc:MovieClip;
      
      private var m_overlay1Tf:ZwTextField;
      
      private var m_overlay2Tf:ZwTextField;
      
      private var m_boardFrameNumber:Number = 1;
      
      private var m_dailyoverlayBt:FarmAnimatedTextButton;
      
      public var managerObject:Object;
      
      private var m_craftsFrame:FrontierInnovationCraftingSlotFrame;
      
      private var m_forageFrame:FrontierInnovationForageFrame;
      
      private const SERVICE_NAME:String = "FrontierInnovationService";
      
      private var allSpecialRecipes:Object;
      
      private var m_axePoints:ZwTextField;
      
      private var m_FtueMc:MovieClip;
      
      private var m_whatIsThisBt:FarmAnimatedTextButton;
      
      private var m_pointsanim:MovieClip;
      
      private var m_taskFrame:FarmRun2018OrderboardFrame;
      
      private var m_loadingTf:ZwTextField;
      
      protected var m_DumptutorialScene:int = 0;
      
      protected var m_DumpTutorial:ZwFrame = null;
      
      protected const DUMPFTUE_MC:String = "dumpFTUE_mc";
      
      private var m_share_button:FarmAnimatedTextButton;
      
      private var m_continue_button:FarmAnimatedTextButton;
      
      private var m_loaderMc:MovieClip;
      
      public var m_body2Tf:ZwTextField;
      
      private var m_bodyTf:ZwTextField;
      
      public function FarmRun2018ScoreBoardWindow(featureBuiilding:FeatureBuilding = null)
      {
         this.managerObject = this.manager;
         var dialogURL:String = this.manager.getScoreBoardUrl();
         super(FEATURE_NAME,dialogURL);
      }
      
      override protected function postLoadComplete() : void
      {
         var count:int = 0;
         var slotKey:String = null;
         var questSlotId:String = null;
         var showLoadingTf:Boolean = false;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Farm Run"));
         }
         var currWorld:String = Global.worldManager.currentWorldType;
         var worldNum:int = this.manager.getworldIndexFromName(currWorld);
         var worldId:String = "world" + (worldNum + 1) + "BG_mc";
         if(m_window.hasOwnProperty(worldId))
         {
            m_window[worldId].visible = true;
            m_window[worldId].enabled = true;
         }
         if(m_window.hasOwnProperty("result_mc"))
         {
            this.m_resultMc = m_window.result_mc as MovieClip;
            this.m_resultMc.visible = true;
         }
         if(Boolean(this.m_resultMc) && this.m_resultMc.hasOwnProperty("points_tf"))
         {
            this.m_resultMc.points_tf.text = "Points scored";
         }
         if(Boolean(this.m_resultMc) && this.m_resultMc.hasOwnProperty("timer_mc"))
         {
            this.m_timer_Mc = this.m_resultMc.timer_mc as MovieClip;
            this.m_timer_Mc.visible = false;
         }
         if(this.m_resultMc.hasOwnProperty("points_mc"))
         {
            this.m_pointsMc = this.m_resultMc.points_mc as MovieClip;
            this.m_pointsMc.points_tf.text = this.manager.getCurrentScore(FEATURE_OPTIONS_KEY);
         }
         if(this.m_resultMc.hasOwnProperty("score_mc"))
         {
            this.m_scoreMc = this.m_resultMc.score_mc as MovieClip;
            this.m_scoreMc.visible = true;
            this.m_scoreMc.enabled = true;
         }
         if(m_window.hasOwnProperty("loader_mc"))
         {
            this.m_loaderMc = m_window.loader_mc as MovieClip;
            this.m_loaderMc.visible = false;
         }
         if(m_window.hasOwnProperty("talk_mc"))
         {
            this.m_talkMc = m_window.talk_mc as MovieClip;
            this.m_talkMc.visible = false;
         }
         if(Boolean(this.m_talkMc) && this.m_talkMc.hasOwnProperty("npc_tf"))
         {
            addWidget(this.m_talk_tf = new ZwTextField(this.m_talkMc["npc_tf"]));
            this.m_talk_tf.visible = true;
         }
         var isFullScore:Boolean = this.manager.getCurrentScore(FEATURE_OPTIONS_KEY) == 21;
         if(isFullScore)
         {
            this.m_talkMc.visible = true;
            this.m_talk_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.FULL_SCORE);
         }
         else if(Global.player.getSeenFlag(FARMRUN_QUIZ_TIMER_RAN_OUT_FLAG))
         {
            this.m_talkMc.visible = true;
            this.m_talk_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TIME_UP);
         }
         else
         {
            this.m_talkMc.visible = true;
            this.m_talk_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.PARTIAL_SCORE);
         }
         if(this.manager.getNPCProgress() >= 1400)
         {
            this.m_talkMc.visible = true;
            this.m_talk_tf.text = "\nWhat a race to victory!";
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            addWidget(this.m_scoreDialog_tf = new ZwTextField(m_window[this.BODY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"")));
            this.m_scoreDialog_tf.visible = false;
            if(Global.player.getSeenFlag(FARMRUN_QUIZ_TIMER_RAN_OUT_FLAG))
            {
               this.m_scoreDialog_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.QUIZ_FINISHED_TIMER);
               this.m_scoreDialog_tf.visible = true;
               if(this.m_timer_Mc)
               {
                  this.m_timer_Mc.visible = true;
               }
            }
            else
            {
               this.m_timer_Mc.visible = false;
               this.m_scoreDialog_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.QUIZ_FINISHED);
               this.m_scoreDialog_tf.visible = true;
            }
         }
         if(m_window.hasOwnProperty("body2_tf"))
         {
            addWidget(this.m_body2Tf = new ZwTextField(m_window["body2_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BODY2)));
            this.m_body2Tf.visible = true;
            if(Boolean(this.m_body2Tf) && this.manager.getNPCProgress() >= 1400)
            {
               this.m_body2Tf.text = "";
               if(this.m_scoreDialog_tf)
               {
                  this.m_scoreDialog_tf.text = "Congratulations! You have finished the Farm Run!";
               }
               if(this.m_resultMc)
               {
                  this.m_resultMc.visible = false;
               }
            }
         }
         for(var i:int = 0; i < 3; i++)
         {
            slotKey = this.manager.getKeyForQuestion(i);
            questSlotId = "count_mc_" + i;
            if(this.m_scoreMc.hasOwnProperty(questSlotId))
            {
               this.m_countMc = this.m_scoreMc[questSlotId] as MovieClip;
               this.m_countMc.visible = true;
               this.m_countMc.enabled = true;
               this.m_countMc.gotoAndStop(0);
               if(this.manager.wasAnsweredCorrectly(slotKey))
               {
                  this.m_countMc.gotoAndStop(2);
               }
               else if(this.manager.wasNotAttempted(slotKey))
               {
                  this.m_countMc.gotoAndStop(1);
               }
               else
               {
                  this.m_countMc.gotoAndStop(3);
               }
            }
         }
         if(m_window.hasOwnProperty("okay_bt"))
         {
            this.m_okay_button = new FarmAnimatedTextButton(m_window["okay_bt"],"Continue",this.onClickOkay);
            this.m_okay_button.visible = !isFullScore;
         }
         if(m_window.hasOwnProperty("share_bt"))
         {
            this.m_share_button = new FarmAnimatedTextButton(m_window["share_bt"],"Share",this.onClickShare);
            this.m_share_button.visible = isFullScore;
         }
         if(m_window.hasOwnProperty("continue_bt"))
         {
            this.m_continue_button = new FarmAnimatedTextButton(m_window["continue_bt"],"Continue",this.onClickOkay);
            this.m_continue_button.visible = isFullScore;
         }
         if(m_window.hasOwnProperty("tasks_mc"))
         {
         }
         if(m_window.hasOwnProperty(this.FINISH_TF))
         {
            addWidget(this.m_finishTitle = new ZwTextField(m_window[this.FINISH_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_FINISH_TITLE)));
         }
         if(m_window.hasOwnProperty(this.FINISH_BODY_TF))
         {
            addWidget(this.m_finishBody = new ZwTextField(m_window[this.FINISH_BODY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_FINISH_BODY)));
         }
         if(m_window.hasOwnProperty(this.TILEUNLOCK_MC))
         {
            this.m_tileUnlockMc = m_window[this.TILEUNLOCK_MC] as MovieClip;
            this.m_tileUnlockMc.visible = false;
         }
         if(m_window.hasOwnProperty(this.AXE_MC))
         {
            this.m_axeMc = m_window.axe_mc as MovieClip;
            if(this.m_axeMc.hasOwnProperty("points_tf"))
            {
               addWidget(this.m_axePoints = new ZwTextField(this.m_axeMc["points_tf"]));
               this.m_axePoints.text = "x" + this.manager.getOrderboardProgress().toString();
            }
            this.m_axeMc.visible = true;
         }
         if(m_window.hasOwnProperty(this.FINISH_MC))
         {
            this.m_finishMc = m_window[this.FINISH_MC] as MovieClip;
            this.m_finishMc.visible = false;
            if(this.m_finishMc.hasOwnProperty("fintitle_tf"))
            {
               addWidget(this.m_overlay1Tf = new ZwTextField(this.m_finishMc["fintitle_tf"],"Strike it Rich!"),false);
            }
            if(this.m_finishMc.hasOwnProperty("finish1_tf"))
            {
               addWidget(this.m_overlay1Tf = new ZwTextField(this.m_finishMc["finish1_tf"],"Great Work!"));
            }
            if(this.m_finishMc.hasOwnProperty("finish2_tf"))
            {
               addWidget(this.m_overlay1Tf = new ZwTextField(this.m_finishMc["finish2_tf"],"You’ve struck it rich at the Frontier Trail! Go harvest the Hardy Home everyday until August 27th for awesome rewards!"));
            }
         }
         if(m_window.hasOwnProperty(this.MAIN_BG_MC))
         {
            this.m_main_bg_Mc = m_window.main_bg_mc as MovieClip;
            this.m_main_bg_Mc.visible = true;
         }
         if(m_window.hasOwnProperty(this.CRAFTS_MC))
         {
            this.m_craftsFrame = new FrontierInnovationCraftingSlotFrame(m_window[this.CRAFTS_MC],this.m_featureName,this.managerObject);
            this.m_craftsFrame.setPagination();
            this.m_craftsFrame.visible = true;
         }
         if(m_window.hasOwnProperty(this.REWARD1_MC))
         {
            this.m_reward1_mc = m_window[this.REWARD1_MC] as MovieClip;
            this.m_reward1_mc.visible = false;
         }
         if(m_window.hasOwnProperty(this.REWARD2_MC))
         {
            this.m_reward2_mc = m_window[this.REWARD2_MC] as MovieClip;
            this.m_reward2_mc.visible = false;
         }
         if(m_window.hasOwnProperty(this.REWARD3_MC))
         {
            this.m_reward3_mc = m_window[this.REWARD3_MC] as MovieClip;
            this.m_reward3_mc.visible = false;
         }
         if(m_window.hasOwnProperty(this.PREVIEW1_MC))
         {
            addWidget(this.m_preview1_mc = new ZwFrame(m_window[this.PREVIEW1_MC]),true);
            this.m_preview1_mc.registerEventListener(MouseEvent.MOUSE_OVER,this.onOver1);
            this.m_preview1_mc.registerEventListener(MouseEvent.MOUSE_OUT,this.onOut1);
            if(!this.manager.isFirstMilestoneAchieved())
            {
               this.m_preview1_mc.attachTooltip(new FarmTextTooltip(this.TEXT_REWARD1_HOVER));
            }
         }
         if(m_window.hasOwnProperty(this.PREVIEW2_MC))
         {
            addWidget(this.m_preview2_mc = new ZwFrame(m_window[this.PREVIEW2_MC]),true);
            this.m_preview2_mc.registerEventListener(MouseEvent.MOUSE_OVER,this.onOver2);
            this.m_preview2_mc.registerEventListener(MouseEvent.MOUSE_OUT,this.onOut2);
            if(!this.manager.isSecondMilestoneAchieved())
            {
               this.m_preview2_mc.attachTooltip(new FarmTextTooltip(this.TEXT_REWARD2_HOVER));
            }
         }
         if(m_window.hasOwnProperty(this.PREVIEW3_MC))
         {
            addWidget(this.m_preview3_mc = new ZwFrame(m_window[this.PREVIEW3_MC]),true);
            this.m_preview3_mc.registerEventListener(MouseEvent.MOUSE_OVER,this.onOver3);
            this.m_preview3_mc.registerEventListener(MouseEvent.MOUSE_OUT,this.onOut3);
            if(!this.manager.isThirdMilestoneAchieved())
            {
               this.m_preview3_mc.attachTooltip(new FarmTextTooltip(this.TEXT_REWARD3_HOVER));
            }
         }
         var percentValue:Number = this.manager.getNPCProgress();
         if(m_window.hasOwnProperty("pointer_mc"))
         {
            this.m_pointerMc = m_window.pointer_mc;
            this.m_pointerMc.visible = true;
            if(this.m_pointerMc.hasOwnProperty("pointsanim_mc"))
            {
               this.m_pointsanim = this.m_pointerMc.pointsanim_mc as MovieClip;
               this.m_pointsanim.visible = false;
            }
            this.updatePointerPosition(percentValue,this.m_pointerMc);
         }
         if(m_window.hasOwnProperty("level2_mc"))
         {
            this.m_level2Mc = m_window.level2_mc as MovieClip;
            this.m_level2Mc.visible = true;
         }
         if(m_window.hasOwnProperty(this.METER_MC))
         {
            this.m_meter_mc = m_window[this.METER_MC];
            this.initializeMeterMC(this.m_meter_mc);
            this.updateProgressBar(this.manager.getNPCProgress(),this.m_meter_mc);
         }
         if(m_window.hasOwnProperty(this.LOADING_TF))
         {
            showLoadingTf = this.manager.getTasks().length == 0;
            this.m_loadingTf = new ZwTextField(m_window[this.LOADING_TF],"Loading task...");
            this.m_loadingTf.visible = showLoadingTf;
         }
         if(m_window.hasOwnProperty(this.DUMPFTUE_MC))
         {
            this.m_DumpTutorial = addWidget(new ZwFrame(m_window[this.DUMPFTUE_MC]),false) as ZwFrame;
            if(m_window[this.DUMPFTUE_MC].okay_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_window.dumpFTUE_mc.okay_bt,ZLocUtils.t("Dialogs","Okay"),this.onDumpTutorialOkayButtonClick));
            }
         }
         this.refreshWindow();
      }
      
      private function onOver1(evt:MouseEvent) : void
      {
         var gotoFrame:int = this.m_isEA ? 2 : 1;
         this.m_reward1_mc.visible = true;
         this.m_reward1_mc.gotoAndStop(gotoFrame);
         this.m_reward1_mc.tick_mc.visible = this.manager.isFirstMilestoneAchieved();
      }
      
      private function onOut1(evt:MouseEvent) : void
      {
         this.m_reward1_mc.visible = false;
      }
      
      private function onOver2(evt:MouseEvent) : void
      {
         var gotoFrame:int = this.m_isEA ? 2 : 1;
         this.m_reward2_mc.visible = true;
         this.m_reward2_mc.gotoAndStop(gotoFrame);
         this.m_reward2_mc.tick_mc.visible = this.manager.isSecondMilestoneAchieved();
      }
      
      private function onOut2(evt:MouseEvent) : void
      {
         this.m_reward2_mc.visible = false;
      }
      
      private function onOver3(evt:MouseEvent) : void
      {
         var gotoFrame:int = this.m_isEA ? 2 : 1;
         this.m_reward3_mc.visible = true;
         this.m_reward3_mc.gotoAndStop(gotoFrame);
         this.m_reward3_mc.tick_mc.visible = this.manager.isThirdMilestoneAchieved();
      }
      
      private function onOut3(evt:MouseEvent) : void
      {
         this.m_reward3_mc.visible = false;
      }
      
      public function updatePointerPosition(percentValue:Number, meter_mc:MovieClip) : void
      {
         var barWidth:Number = NaN;
         if(meter_mc.hasOwnProperty("points_tf"))
         {
            meter_mc.points_tf.text = percentValue;
            barWidth = percentValue * this.PROGRESS_BAR_FULL_WIDTH / this.MAX_POINT * (340 / 600);
            meter_mc.y = this.BAR_INITIAL_POSTION - barWidth;
         }
      }
      
      private function initializeMeterMC(meter_mc:MovieClip) : void
      {
         if(meter_mc)
         {
            meter_mc.visible = true;
            this.updateProgressBar(0,meter_mc);
            if(meter_mc[this.POINTS_TF])
            {
               (meter_mc[this.POINTS_TF] as TextField).visible = true;
               (meter_mc[this.POINTS_TF] as TextField).text = "000";
            }
         }
      }
      
      public function updateProgressBar(percentValue:Number, meter_mc:MovieClip) : void
      {
         if(percentValue > this.MAX_POINT)
         {
            percentValue = this.MAX_POINT;
         }
         var barWidth:Number = percentValue * this.PROGRESS_BAR_FULL_WIDTH / this.MAX_POINT;
         if(meter_mc.bar_fill_mc)
         {
            if(percentValue == 0)
            {
               (meter_mc.bar_fill_mc as MovieClip).width = barWidth;
            }
            else
            {
               TweenMax.to(meter_mc.bar_fill_mc,2,{"width":barWidth});
            }
         }
         if(meter_mc[this.POINTS_TF])
         {
            (meter_mc[this.POINTS_TF] as TextField).text = int(percentValue).toString();
         }
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
            timeLeft = HUD.getformattedTimeLeftFromArray(timeRemaining);
         }
         return timeLeft;
      }
      
      private function getQuizTimeLeft() : String
      {
         return this.manager.getQuizTimeRemaining().toString();
      }
      
      private function getFrameNumber() : Number
      {
         return this.m_boardFrameNumber;
      }
      
      private function hasSeenFeatureWelcome() : Boolean
      {
         return Global.player.getSeenFlag(FEATURE_WELCOME_SEEN_FLAG);
      }
      
      private function onClickShare(event:Event) : void
      {
         var fi:FarmItem = Global.farmGameSettingsManager.getFarmItemByName("pegacorn_crowned");
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}",
               "src":fi.icon
            }],
            "first_name":Global.player.firstName,
            "item":fi.friendlyTitle
         };
         GlobalEngine.socialNetwork.publishFeedStory("farmrun2018_quiz_share_milestoneReward",bundleData,[],false,null);
         this.onClickOkay(event);
         FarmStatsManager.count("GPF_FarmRunV10_2020","quiz_bragfeed","quiz");
      }
      
      private function onClickOkay(event:Event) : void
      {
         if(this.m_scoreDialog_tf)
         {
            this.m_scoreDialog_tf.visible = false;
         }
         if(this.manager.m_window)
         {
            this.manager.m_window.refreshWindow();
         }
         if(this.manager.getNPCProgress() < 1400)
         {
            if(this.manager.getFarmrunWorldFromPoints() == Global.worldManager.currentWorldType)
            {
               this.manager.fetchFeatureData();
               this.manager.m_window.tintWindow();
               this.manager.m_window.enableInput = false;
            }
            else
            {
               this.manager.m_window.untintWindow();
               this.manager.m_window.enableInput = true;
               close();
            }
            this.m_loaderMc.visible = true;
            this.m_loaderMc.play();
            this.m_resultMc.visible = false;
            if(this.m_okay_button)
            {
               this.m_okay_button.visible = false;
            }
            if(this.m_share_button)
            {
               this.m_share_button.visible = false;
            }
            if(this.m_continue_button)
            {
               this.m_continue_button.visible = false;
            }
            if(this.m_bodyTf)
            {
               this.m_bodyTf.visible = false;
            }
            if(!this.m_body2Tf)
            {
            }
            this.m_talkMc.visible = false;
         }
         else
         {
            this.closeWindow();
         }
      }
      
      public function closeWindow() : void
      {
         m_window = null;
         this.manager.m_window.untintWindow();
         this.manager.m_window.enableInput = true;
         super.close();
      }
      
      public function onClickTravel() : void
      {
         this.manager.openOrderBoardWindow();
      }
      
      override public function refreshWindow() : void
      {
         var progress:Number = this.manager.getNPCProgress();
         if(Boolean(0) && !this.manager.isFinalRewardGranted())
         {
            if(progress < this.MAX_POINT)
            {
               if(this.m_axePoints)
               {
                  this.m_axePoints.text = "x" + this.manager.getOrderboardProgress().toString();
               }
               this.refreshTaskFrame();
               this.manager.grantMilestoneReward();
            }
            else
            {
               this.manager.grantFinalReward();
            }
         }
         else if(this.m_finishMc)
         {
            this.m_finishMc.visible = true;
         }
      }
      
      public function refreshTaskFrame() : void
      {
         if(this.m_loadingTf)
         {
            this.m_loadingTf.visible = false;
         }
         this.m_taskFrame.refresh();
      }
      
      private function get manager() : FarmRun2018Manager
      {
         return FarmRun2018Manager.getInstance(FEATURE_NAME);
      }
      
      public function resumeWindow() : void
      {
         untintWindow();
         enableInput = true;
         this.refreshTaskFrame();
      }
      
      public function get getManager() : Object
      {
         return this.manager;
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
   }
}

