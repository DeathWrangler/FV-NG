package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureBuilding;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Engine.Utilities;
   import Managers.OrderBoard.FarmRunV7Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmRunV7OrderboardFrame;
   import Widgets.Frames.FrontierInnovationCraftingSlotFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class FarmRunV7OrderBoardWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 7;
      
      public static const ICON_SIZE:int = 50;
      
      private static const FEATURE_WELCOME_SEEN_FLAG:String = "Carribean_Welcome_flag";
      
      private static const FEATURE_DAILYPLAY_SEEN_FLAG:String = "Carribean_DailyPlayWelcome_flag";
      
      private static const FEATURE_NAME:String = "FarmRunV7";
      
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
      
      private const TIMER_TF:String = "timer_tf";
      
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
      
      private const TEXT_BODY:String = "_OB_text";
      
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
      
      private const PROGRESS_BAR_FULL_WIDTH:int = 800;
      
      private const NPC_WIDTH_X:int = 250;
      
      private const MAX_POINT:int = 3000;
      
      private const MAX_DAILYPOINT:int = 50;
      
      private var m_isEA:Boolean;
      
      public var m_notifMc:MovieClip;
      
      private const TEXT_REWARD1_HOVER:String = "Earn 300 Points";
      
      private const TEXT_REWARD2_HOVER:String = "Earn 900 Points";
      
      private const TEXT_REWARD3_HOVER:String = "Earn 1800 Points";
      
      private var m_axeMc:MovieClip;
      
      private var m_tileUnlockMc:MovieClip;
      
      private var m_main_bg_Mc:MovieClip;
      
      public var m_talkMc:MovieClip;
      
      private var m_level2Mc:MovieClip;
      
      private var m_rewardsBt:FarmAnimatedTextButton;
      
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
      
      private var m_timerMc:MovieClip;
      
      public var managerObject:Object;
      
      private var m_craftsFrame:FrontierInnovationCraftingSlotFrame;
      
      private var m_axePoints:ZwTextField;
      
      private var m_FtueMc:MovieClip;
      
      private var m_whatIsThisBt:FarmAnimatedTextButton;
      
      private var m_pointsanim:MovieClip;
      
      private var m_taskFrame:FarmRunV7OrderboardFrame;
      
      private var m_loadingTf:ZwTextField;
      
      protected var m_DumptutorialScene:int = 0;
      
      protected var m_DumpTutorial:ZwFrame = null;
      
      protected const DUMPFTUE_MC:String = "dumpFTUE_mc";
      
      private var m_highlightMc:MovieClip;
      
      private var m_okayBt:FarmAnimatedTextButton;
      
      private var m_sizeMc:MovieClip;
      
      private var m_taskPointsMc:MovieClip;
      
      private var m_taskPointsTf:ZwTextField;
      
      public var m_talk_tf:ZwTextField;
      
      public function FarmRunV7OrderBoardWindow(featureBuiilding:FeatureBuilding = null)
      {
         this.managerObject = this.manager;
         var dialogURL:String = this.manager.getOrderboardUrl();
         FarmRunV7Manager.getInstance(FEATURE_NAME).parseTaskObjectsFromCOnfig(FEATURE_NAME);
         super(FEATURE_NAME,dialogURL);
      }
      
      override protected function postLoadComplete() : void
      {
         var showLoadingTf:Boolean = false;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_TITLE)));
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            addWidget(this.m_descriptionTf = new ZwTextField(m_window[this.BODY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BODY)));
         }
         if(m_window.hasOwnProperty("world1BG_mc"))
         {
            this.m_world1_mc = m_window["world1BG_mc"] as MovieClip;
            this.m_world1_mc.visible = false;
         }
         if(m_window.hasOwnProperty("world2BG_mc"))
         {
            this.m_world2_mc = m_window["world2BG_mc"] as MovieClip;
            this.m_world2_mc.visible = false;
         }
         if(m_window.hasOwnProperty("world3BG_mc"))
         {
            this.m_world3_mc = m_window["world3BG_mc"] as MovieClip;
            this.m_world3_mc.visible = false;
         }
         if(m_window.hasOwnProperty("world4BG_mc"))
         {
            this.m_world4_mc = m_window["world4BG_mc"] as MovieClip;
            this.m_world4_mc.visible = false;
         }
         var worldId:int = this.manager.getworldIndexFromName(this.manager.getFarmrunWorldFromPoints());
         var worldElement:String = "world" + (worldId + 1) + "BG_mc";
         if(m_window.hasOwnProperty(worldElement))
         {
            m_window[worldElement].visible = true;
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
         if(m_window.hasOwnProperty("highlight_mc"))
         {
            this.m_highlightMc = m_window.highlight_mc as MovieClip;
            this.m_highlightMc.visible = false;
         }
         if(m_window.hasOwnProperty("okay_bt"))
         {
            addWidget(this.m_okayBt = new FarmAnimatedTextButton(m_window["okay_bt"],"Okay",null));
            this.m_okayBt.visible = false;
         }
         if(m_window.hasOwnProperty("tasks_mc"))
         {
            this.m_taskFrame = new FarmRunV7OrderboardFrame(m_window["tasks_mc"],this,this.m_featureName,this.manager);
            this.m_taskFrame.visible = true;
            if(m_window["tasks_mc"].hasOwnProperty("points_mc"))
            {
               this.m_taskPointsMc = m_window["tasks_mc"].points_mc as MovieClip;
               if(this.m_taskPointsMc.hasOwnProperty("points_tf"))
               {
                  addWidget(this.m_taskPointsTf = new ZwTextField(this.m_taskPointsMc["points_tf"],"25"));
                  this.m_taskPointsTf.visible = true;
               }
               this.m_taskPointsMc.visible = true;
            }
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
         if(m_window.hasOwnProperty("timer_mc"))
         {
            this.m_timerMc = m_window.timer_mc as MovieClip;
            if(this.m_timerMc.hasOwnProperty(this.TIMER_TF))
            {
               addWidget(new ZwTextField(this.m_timerMc[this.TIMER_TF],this.getTimeLeft()));
            }
            this.m_timerMc.visible = true;
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
         if(m_window.hasOwnProperty("size_mc"))
         {
            this.m_sizeMc = m_window.size_mc as MovieClip;
         }
         if(m_window.hasOwnProperty("overlay"))
         {
            this.m_overlayMc = m_window["overlay"] as MovieClip;
            this.m_overlayMc.visible = true;
         }
         this.refreshWindow();
      }
      
      public function updateOntaskComplete(openQuestionaireWindow:Boolean) : void
      {
         if(this.m_highlightMc)
         {
            this.m_highlightMc.visible = true;
         }
         if(this.m_taskPointsMc)
         {
            if(this.manager.getNPCProgress() >= 1400)
            {
               this.m_taskPointsMc.visible = false;
            }
            else
            {
               this.m_taskPointsMc.visible = true;
               if(this.m_taskPointsTf)
               {
                  this.m_taskPointsTf.visible = true;
               }
            }
         }
         if(this.m_okayBt)
         {
            this.m_okayBt.visible = true;
            this.m_okayBt.enabled = true;
            if(Boolean(this.manager) && Boolean(this.manager.m_window))
            {
               this.manager.m_window.refreshWindow();
            }
            if(openQuestionaireWindow && this.manager.getNPCProgress() < 1400)
            {
               this.m_okayBt.callback = this.openquestionaireWindowCallback;
            }
            else
            {
               this.m_okayBt.callback = this.closeWindow;
            }
         }
         if(m_closeButton)
         {
            m_closeButton.visible = false;
            m_closeButton.enabled = false;
         }
         if(this.manager.getNPCProgress() >= 1400)
         {
            if(this.m_descriptionTf)
            {
               this.m_descriptionTf.text = "Congratulations! You have finished the Farm Run!";
               this.m_descriptionTf.visible = true;
            }
         }
         else if(this.m_descriptionTf)
         {
            this.m_descriptionTf.text = "Hurray! All tasks complete! You’ve been awarded 25 points!";
            this.m_descriptionTf.visible = true;
         }
      }
      
      public function closeWindow(evt:MouseEvent) : void
      {
         this.close();
      }
      
      public function openquestionaireWindowCallback(evt:MouseEvent) : void
      {
         if(this.m_overlayMc)
         {
            this.m_overlayMc.visible = false;
         }
         if(this.manager.m_window)
         {
            this.manager.m_window.untintWindow();
            this.manager.m_window.enableInput = true;
         }
         super.close();
         this.manager.openQuestionarreWindow();
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
      
      public function setForageFrameOverlay() : *
      {
      }
      
      private function getFrameNumber() : Number
      {
         return this.m_boardFrameNumber;
      }
      
      private function hasSeenFeatureWelcome() : Boolean
      {
         return Global.player.getSeenFlag(FEATURE_WELCOME_SEEN_FLAG);
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
         if(this.manager.m_window)
         {
            this.manager.m_window.untintWindow();
         }
         this.m_taskFrame.refresh();
      }
      
      public function updateNPCTextAfterQuiz() : void
      {
         var currentFarmrunWorld:String = null;
         if(this.m_talkMc)
         {
            this.m_talkMc.visible = true;
            if(this.m_talk_tf)
            {
               this.m_talk_tf.text = "Hurray!\nYou are in the Farm Trivia bonus round!\nYou can win upto 21 points!";
               currentFarmrunWorld = this.manager.getFarmrunWorldFromPoints();
               if(Global.worldManager.currentWorldType != currentFarmrunWorld)
               {
                  this.m_talk_tf.text = "Awesome! All tasks complete! You won 25 points!";
               }
               if(this.manager.getNPCProgress() >= 1400)
               {
                  this.m_talk_tf.text = "\nWhat a race to victory!";
               }
            }
         }
      }
      
      private function get manager() : FarmRunV7Manager
      {
         return FarmRunV7Manager.getInstance(FEATURE_NAME);
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
      
      public function closeWindowForTasks() : void
      {
         super.close();
         if(this.manager.m_window)
         {
            this.manager.m_window.close();
         }
      }
      
      override public function close() : void
      {
         if(this.m_overlayMc)
         {
            this.m_overlayMc.visible = false;
         }
         super.close();
         if(this.manager.m_window)
         {
            this.manager.m_window.untintWindow();
            Utilities.toggleInputAndChildren(Global.ui,false);
            Utilities.toggleInputAndChildren(this.manager.m_window,true);
            this.manager.m_window.enableInput = true;
            this.manager.m_window.closeWorldProgressBar();
         }
      }
   }
}

