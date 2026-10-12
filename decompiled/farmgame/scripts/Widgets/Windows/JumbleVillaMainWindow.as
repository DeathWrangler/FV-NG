package Widgets.Windows
{
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Managers.JumbleVillaManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.JumbleVillaPieceFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class JumbleVillaMainWindow extends FarmWindowWithTutorial
   {
      
      private static const FEATURE_NAME:String = "JumbleVilla";
      
      private static const JUMBLEVILLA_INTRO_SEEN:String = "jumblevilla_intro_seen";
      
      private static const JUMBLEVILLA_STORY_COMPLETE_SEEN:String = "jumblevilla_story_complete_seen";
      
      private static const JUMBLEVILLA_CONVERT_READY_CALLOUT:String = "jumblevilla_convert_ready_callout";
      
      private static const TOTAL_INTRO_STEPS:Number = 3;
      
      private static const TOTAL_NPC_CALLOUTS:Number = 3;
      
      private static const BUY_WINDOW_ASSET_URL:String = "assets/dialogs/Jumblevilla_2020/FV_Jumblevilla_buy_2020.swf";
      
      private static const REWARD_DIALOG_ASSET_URL:String = "assets/dialogs/Jumblevilla_2020/FV_Jumblevilla_prize_2020.swf";
      
      private static const INTRODUCTION_CTA_TEXTS:* = ["Okay!","Awesome!","Next!"];
      
      public const DEFAULT_THROTTLE_TIME:Number = 86400;
      
      private var m_title_tf:ZwTextField;
      
      private var m_subtitle_tf:ZwTextField;
      
      private var m_days_tf:ZwTextField;
      
      private var m_reward_tf:ZwTextField;
      
      private var m_count_tf:ZwTextField;
      
      private var m_dooberCount_tf:ZwTextField;
      
      private var m_level_tf:ZwTextField;
      
      private var m_converter_mc:MovieClip;
      
      private var m_anim_mc:MovieClip;
      
      private var m_anim2_mc:MovieClip;
      
      private var m_doober_mc:MovieClip;
      
      private var m_dooberIcon_mc:MovieClip;
      
      private var m_fill_mc:MovieClip;
      
      private var m_puzzle_mc:JumbleVillaPieceFrame;
      
      private var m_finder_mc:MovieClip;
      
      private var m_reward_mc:MovieClip;
      
      private var m_bonus_mc:MovieClip;
      
      private var m_size_mc:MovieClip;
      
      private var m_tutorial_size_mc:MovieClip;
      
      private var m_ftue_mc:MovieClip;
      
      private var m_intro_mc:MovieClip;
      
      private var m_panel_tutorial_mc:MovieClip;
      
      private var m_find_bt:FarmAnimatedTextButton;
      
      private var m_convert_bt:FarmAnimatedTextButton;
      
      private var m_okay_bt:FarmAnimatedTextButton;
      
      private var m_upgrade_bt:FarmAnimatedTextButton;
      
      private var m_whatisthis_bt:ZwButton;
      
      private var m_intro_okay_bt:Array = [];
      
      private var m_ftue_okay_bt:Array = [];
      
      private var m_current_tutorial_step:Number = 0;
      
      private var m_buy_window:JumbleVillaFinderUpgradeWindow;
      
      private var m_convertor_tooltip_mc:ZwFrame;
      
      private var m_reward_tooltip_mc:ZwFrame;
      
      private var m_bonus_tooltip_mc:ZwFrame;
      
      private var m_timer:Timer;
      
      private var m_end_mc:MovieClip;
      
      private var m_emotion_mc:MovieClip;
      
      private var m_end_title_tf:ZwTextField;
      
      private var m_end_body_tf:ZwTextField;
      
      private var m_accept_bt:FarmAnimatedTextButton;
      
      public function JumbleVillaMainWindow(featureName:String = "JumbleVilla", assetUrl:String = null)
      {
         super(FEATURE_NAME,assetUrl);
      }
      
      private static function onConvertButtonClick(event:MouseEvent) : void
      {
         manager.convertExtraParts();
      }
      
      private static function get manager() : JumbleVillaManager
      {
         return JumbleVillaManager.getInstance(FEATURE_NAME);
      }
      
      override protected function postLoadComplete() : void
      {
         var subtitleText:String = null;
         var featureEndsInText:String = null;
         var visiblitly:Boolean = false;
         var i:int = 0;
         if(m_window)
         {
            if(m_window.hasOwnProperty("title_tf"))
            {
               addWidget(this.m_title_tf = new ZwTextField(m_window["title_tf"],"JUMBLEVILLE!"));
               this.m_title_tf.visible = true;
            }
            if(m_window.hasOwnProperty("subtitle_tf"))
            {
               addWidget(this.m_subtitle_tf = new ZwTextField(m_window["subtitle_tf"]));
               subtitleText = "Harvest crops to find the missing pieces scattered in the farm!";
               if(!manager.isFeatureinActivePeriod())
               {
                  subtitleText = "JumbleVilla is over! You can view the pages you completed!";
               }
               if(manager.isFeatureCompleted())
               {
                  subtitleText = "The Storybook is complete! You can view all the pages!";
               }
               this.m_subtitle_tf.text = subtitleText;
               this.m_subtitle_tf.visible = true;
            }
            if(m_window.hasOwnProperty("days_tf"))
            {
               if(manager.isFeatureinActivePeriod())
               {
                  featureEndsInText = "Ends in " + manager.getFeatureEndDaysLeftText();
               }
               else
               {
                  featureEndsInText = "Ended";
               }
               addWidget(this.m_days_tf = new ZwTextField(m_window["days_tf"],featureEndsInText));
               this.m_days_tf.visible = true;
            }
            if(m_window.hasOwnProperty("converter_mc"))
            {
               this.m_converter_mc = m_window["converter_mc"] as MovieClip;
               this.m_convertor_tooltip_mc = new ZwFrame(m_window["converter_mc"]);
               if(this.m_converter_mc.hasOwnProperty("convert_bt"))
               {
                  addWidget(this.m_convert_bt = new FarmAnimatedTextButton(this.m_converter_mc["convert_bt"],"Convert",onConvertButtonClick));
                  this.m_convert_bt.text = "Convert";
                  this.m_convert_bt.attachTooltip(new FarmTextTooltip("Gives 1 unique part for 100 parts!"));
               }
               if(this.m_converter_mc.hasOwnProperty("anim_mc"))
               {
                  this.m_anim_mc = this.m_converter_mc["anim_mc"] as MovieClip;
               }
               if(this.m_converter_mc.hasOwnProperty("doober_mc"))
               {
                  this.m_doober_mc = this.m_converter_mc["doober_mc"] as MovieClip;
                  if(this.m_doober_mc.hasOwnProperty("anim2_mc"))
                  {
                     this.m_anim2_mc = this.m_doober_mc["anim2_mc"] as MovieClip;
                  }
                  if(this.m_doober_mc.hasOwnProperty("dooberIcon_mc"))
                  {
                     this.m_dooberIcon_mc = this.m_doober_mc["dooberIcon_mc"] as MovieClip;
                     if(this.m_dooberIcon_mc.hasOwnProperty("dooberCount_tf"))
                     {
                        this.m_dooberCount_tf = new ZwTextField(this.m_dooberIcon_mc["dooberCount_tf"]);
                     }
                  }
               }
               if(this.m_converter_mc.hasOwnProperty("fill_mc"))
               {
                  this.m_fill_mc = this.m_converter_mc["fill_mc"] as MovieClip;
               }
               if(this.m_converter_mc.hasOwnProperty("count_tf"))
               {
                  this.m_count_tf = new ZwTextField(this.m_converter_mc["count_tf"]);
               }
            }
            if(m_window.hasOwnProperty("puzzle_mc"))
            {
               this.m_puzzle_mc = new JumbleVillaPieceFrame(m_window["puzzle_mc"]);
            }
            if(m_window.hasOwnProperty("finder_mc"))
            {
               this.m_finder_mc = m_window["finder_mc"] as MovieClip;
               visiblitly = manager.isFeatureinActivePeriod() && !manager.isFeatureCompleted();
               this.m_finder_mc.visible = visiblitly;
               if(this.m_finder_mc.hasOwnProperty("level_tf"))
               {
                  addWidget(this.m_level_tf = new ZwTextField(this.m_finder_mc["level_tf"]));
                  this.m_level_tf.text = "Level " + String(manager.getCurrentFinderLevel() + 1);
               }
               if(this.m_finder_mc.hasOwnProperty("upgrade_bt"))
               {
                  addWidget(this.m_upgrade_bt = new FarmAnimatedTextButton(this.m_finder_mc["upgrade_bt"],"Upgrade!",this.onClickFinderUpdgrade));
                  this.m_upgrade_bt.visible = visiblitly;
               }
            }
            if(m_window.hasOwnProperty("reward_mc"))
            {
               this.m_reward_mc = m_window["reward_mc"] as MovieClip;
               this.m_reward_tooltip_mc = new ZwFrame(m_window["reward_mc"]);
               if(this.m_reward_mc.hasOwnProperty("reward_tf"))
               {
                  addWidget(this.m_reward_tf = new ZwTextField(this.m_reward_mc["reward_tf"],"REWARD"));
               }
            }
            if(m_window.hasOwnProperty("bonus_mc"))
            {
               this.m_bonus_mc = m_window["bonus_mc"] as MovieClip;
               this.m_bonus_tooltip_mc = new ZwFrame(m_window["bonus_mc"]);
               this.m_bonus_mc.visible = manager.isFeatureinActivePeriod() && !manager.isFeatureCompleted();
            }
            if(m_window.hasOwnProperty("size_mc"))
            {
               this.m_size_mc = m_window["size_mc"] as MovieClip;
               this.m_size_mc.visible = false;
            }
            if(m_window.hasOwnProperty("find_bt"))
            {
               addWidget(this.m_find_bt = new FarmAnimatedTextButton(m_window["find_bt"],"Find Parts!",this.onClickFindPartsButton));
               this.m_find_bt.visible = false;
            }
            if(m_window.hasOwnProperty("whatisthis_bt"))
            {
               addWidget(this.m_whatisthis_bt = new ZwButton(m_window["whatisthis_bt"],this.onClickTutorialButton));
               this.m_whatisthis_bt.visible = manager.isFeatureinActivePeriod() && !manager.isFeatureCompleted();
            }
            if(m_window.hasOwnProperty("panel_tutorial_mc"))
            {
               this.m_panel_tutorial_mc = m_window["panel_tutorial_mc"] as MovieClip;
               if(this.m_panel_tutorial_mc.hasOwnProperty("okay_bt"))
               {
                  addWidget(this.m_okay_bt = new FarmAnimatedTextButton(this.m_panel_tutorial_mc["okay_bt"],"Okay!",this.onClickTutorialOKButton));
               }
               if(this.m_panel_tutorial_mc.hasOwnProperty("size_mc"))
               {
                  this.m_tutorial_size_mc = this.m_panel_tutorial_mc["size_mc"] as MovieClip;
               }
            }
            if(m_window.hasOwnProperty("intro_mc"))
            {
               this.m_intro_mc = m_window["intro_mc"] as MovieClip;
               for(i = 0; i < TOTAL_INTRO_STEPS; i++)
               {
                  if(this.m_intro_mc.hasOwnProperty("okay_" + String(i) + "_bt"))
                  {
                     this.m_intro_okay_bt.push(new FarmAnimatedTextButton(this.m_intro_mc["okay_" + String(i) + "_bt"],"Next!",this.onClickIntroButton));
                     this.m_intro_okay_bt[i].text = INTRODUCTION_CTA_TEXTS[i];
                  }
               }
            }
            if(m_window.hasOwnProperty("ftue_mc"))
            {
               this.m_ftue_mc = m_window["ftue_mc"] as MovieClip;
               for(i = 0; i < TOTAL_NPC_CALLOUTS; i++)
               {
                  if(this.m_ftue_mc.hasOwnProperty("okay_" + String(i) + "_bt"))
                  {
                     this.m_ftue_okay_bt.push(new FarmAnimatedTextButton(this.m_ftue_mc["okay_" + String(i) + "_bt"],"Ok!",this.onClickFtueButton));
                  }
               }
            }
            if(m_window.hasOwnProperty("end_mc"))
            {
               this.m_end_mc = m_window["end_mc"] as MovieClip;
               if(this.m_end_mc.hasOwnProperty("accept_bt"))
               {
                  this.m_accept_bt = new FarmAnimatedTextButton(this.m_end_mc["accept_bt"],"Okay!",this.onClickFeatureEndButton);
               }
               if(this.m_end_mc.hasOwnProperty("title_tf"))
               {
                  this.m_end_title_tf = new ZwTextField(this.m_end_mc["title_tf"],"Thanks for playing!");
               }
               if(this.m_end_mc.hasOwnProperty("body_tf"))
               {
                  this.m_end_body_tf = new ZwTextField(this.m_end_mc["body_tf"]);
               }
               if(this.m_end_mc.hasOwnProperty("emotion_mc"))
               {
                  this.m_emotion_mc = this.m_end_mc["emotion_mc"] as MovieClip;
               }
            }
         }
         this.startTimer();
         if(manager.isInStoryMode())
         {
            this.showFeatureEndPopup();
         }
         if(this.shouldShowFinderUpgradeCallout())
         {
            this.showFinderUpgradedCallout();
            manager.updateFinderLevel();
            this.refreshFinderLevelText();
         }
         if(this.shouldShowJumbleVillaIntro())
         {
            Global.player.setSeenFlag(JUMBLEVILLA_INTRO_SEEN);
            this.showIntroductionFtue();
         }
         var activeTabId:int = manager.getActivePuzzleId();
         if(manager.isFeatureCompleted())
         {
            activeTabId = 0;
         }
         this.updatePuzzleProgress(activeTabId);
      }
      
      private function onClickFeatureEndButton(event:MouseEvent) : void
      {
         var pagesCompletedByUser:int = manager.getPagesCompletedByUser();
         this.closeFeatureEndPopup();
         var isActivePageCompleted:Boolean = manager.isActivePuzzleCompleted();
         if(pagesCompletedByUser == 0 && !isActivePageCompleted)
         {
            this.close();
         }
      }
      
      private function closeFeatureEndPopup() : void
      {
         if(this.m_end_mc)
         {
            if(this.m_end_title_tf)
            {
               this.m_end_title_tf.visible = false;
            }
            if(this.m_end_body_tf)
            {
               this.m_end_body_tf.visible = false;
            }
            if(this.m_accept_bt)
            {
               this.m_accept_bt.visible = false;
            }
            if(this.m_emotion_mc)
            {
               this.m_emotion_mc.visible = false;
            }
            this.m_end_mc.visible = false;
         }
      }
      
      private function showFeatureEndPopup() : void
      {
         var pagesCompletedByUser:int = 0;
         var isActivePageCompleted:Boolean = false;
         var bodyText:String = null;
         var shouldShowHappyFace:Boolean = false;
         if(this.m_end_mc)
         {
            pagesCompletedByUser = manager.getPagesCompletedByUser();
            isActivePageCompleted = manager.isActivePuzzleCompleted();
            if(this.m_end_title_tf)
            {
               this.m_end_title_tf.visible = true;
            }
            if(this.m_end_body_tf)
            {
               bodyText = "Farmer, Jumblevilla is over, you did good! Stay Tuned for more features!";
               if(pagesCompletedByUser == 0 && !isActivePageCompleted)
               {
                  bodyText = "Farmer, Jumblevilla is over. Sadly, you were not able to complete it. Stay tuned for more features!";
               }
               this.m_end_body_tf.text = bodyText;
               this.m_end_body_tf.visible = true;
            }
            if(this.m_accept_bt)
            {
               this.m_accept_bt.visible = true;
            }
            if(this.m_emotion_mc)
            {
               shouldShowHappyFace = pagesCompletedByUser > 0 || isActivePageCompleted;
               this.m_emotion_mc.gotoAndStop(shouldShowHappyFace + 1);
               this.m_emotion_mc.visible = true;
            }
            this.m_end_mc.visible = true;
         }
      }
      
      private function refreshFinderLevelText() : void
      {
         if(this.m_level_tf)
         {
            this.m_level_tf.text = "Level " + String(manager.getCurrentFinderLevel() + 1);
         }
      }
      
      private function showIntroductionFtue() : void
      {
         if(this.m_intro_mc)
         {
            this.m_current_tutorial_step = 0;
            this.refreshIntroFrame();
         }
      }
      
      private function refreshIntroFrame() : void
      {
         var i:int = 0;
         if(this.m_intro_mc)
         {
            this.m_intro_mc.visible = this.m_current_tutorial_step < TOTAL_INTRO_STEPS;
            this.m_intro_mc.gotoAndStop(this.m_current_tutorial_step + 1);
         }
         if(Boolean(this.m_intro_okay_bt) && this.m_intro_okay_bt.length == TOTAL_INTRO_STEPS)
         {
            for(i = 0; i < TOTAL_INTRO_STEPS; i++)
            {
               this.m_intro_okay_bt[i].visible = i == this.m_current_tutorial_step;
            }
         }
      }
      
      private function refreshFtueFrame(frameId:Number) : void
      {
         var i:int = 0;
         if(this.m_ftue_mc)
         {
            this.m_ftue_mc.visible = true;
            this.m_ftue_mc.gotoAndStop(frameId);
         }
         if(Boolean(this.m_ftue_okay_bt) && this.m_ftue_okay_bt.length == TOTAL_INTRO_STEPS)
         {
            for(i = 0; i < TOTAL_INTRO_STEPS; i++)
            {
               this.m_ftue_okay_bt[i].visible = i == frameId - 1;
            }
         }
      }
      
      private function onClickIntroButton(event:MouseEvent) : void
      {
         ++this.m_current_tutorial_step;
         this.refreshIntroFrame();
         if(this.m_current_tutorial_step == TOTAL_INTRO_STEPS)
         {
            manager.updateFinderLevel();
            this.showFinderGrantPopup(manager.getCurrentFinderLevel());
            this.refreshFinderLevelText();
         }
      }
      
      private function onClickFtueButton(event:MouseEvent) : void
      {
         var i:int = 0;
         if(this.m_ftue_mc)
         {
            this.m_ftue_mc.visible = 0;
         }
         if(Boolean(this.m_ftue_okay_bt) && this.m_ftue_okay_bt.length == TOTAL_INTRO_STEPS)
         {
            for(i = 0; i < TOTAL_INTRO_STEPS; i++)
            {
               this.m_ftue_okay_bt[i].visible = false;
            }
         }
      }
      
      private function showFinderGrantPopup(currentFinderLevel:Number) : void
      {
         UI.displayPopup(new JumbleVillaRewardPopup(FEATURE_NAME,REWARD_DIALOG_ASSET_URL,null,true,currentFinderLevel),false);
      }
      
      private function onClickFindPartsButton(event:MouseEvent) : void
      {
         this.close();
         manager.openCropsMiniMarket();
      }
      
      private function onClickTutorialButton(event:MouseEvent) : void
      {
         this.showPanelTutorial();
      }
      
      private function onClickFinderUpdgrade(event:MouseEvent) : void
      {
         this.m_buy_window = new JumbleVillaFinderUpgradeWindow(FEATURE_NAME,BUY_WINDOW_ASSET_URL);
         UI.displayPopup(this.m_buy_window,false);
      }
      
      private function onClickTutorialOKButton(event:MouseEvent) : void
      {
         if(this.m_panel_tutorial_mc)
         {
            this.m_panel_tutorial_mc.visible = false;
            if(this.m_okay_bt)
            {
               this.m_okay_bt.visible = false;
            }
            if(this.m_tutorial_size_mc)
            {
               this.m_tutorial_size_mc.visible = false;
            }
         }
      }
      
      private function showPanelTutorial() : void
      {
         if(this.m_panel_tutorial_mc)
         {
            this.m_panel_tutorial_mc.visible = true;
            if(this.m_okay_bt)
            {
               this.m_okay_bt.visible = true;
            }
            if(this.m_tutorial_size_mc)
            {
               this.m_tutorial_size_mc.visible = true;
            }
         }
      }
      
      public function refreshPuzzleFrame(clickedTab:int) : void
      {
         if(this.m_puzzle_mc)
         {
            this.m_puzzle_mc.refreshFrame(clickedTab);
         }
      }
      
      public function refreshNonPuzzleFrame(clickedTab:int) : void
      {
         if(this.m_puzzle_mc)
         {
            this.m_puzzle_mc.refreshNonPuzzleFrame(clickedTab);
         }
      }
      
      public function refreshConvertor(clickedTab:int) : void
      {
         var convertorProgress:Number = manager.getConvertorProgress();
         var partsInConvertor:int = manager.getPartsInConvertor();
         var partsNeededToConvert:int = manager.getMinPartsNeededToConvert();
         this.refreshConvertorVisibility(clickedTab);
         this.refreshConvertorProgress(clickedTab,partsInConvertor,partsNeededToConvert);
         if(clickedTab == manager.getActivePuzzleId() && convertorProgress > 0)
         {
            this.playConvertorProgressDoober(convertorProgress);
         }
      }
      
      public function refreshConvertorVisibility(clickedTab:int) : void
      {
         var visibilty:Boolean = !manager.isActivePuzzleCompleted() && clickedTab == manager.getActivePuzzleId();
         if(this.m_converter_mc)
         {
            this.m_converter_mc.visible = visibilty;
         }
         if(this.m_convertor_tooltip_mc)
         {
            this.m_convertor_tooltip_mc.detachTooltip();
            if(manager.isFeatureinActivePeriod() && visibilty && !manager.isConvertorReady())
            {
               this.m_convertor_tooltip_mc.attachTooltip(new FarmTextTooltip("Extra pieces won’t go waste! Convert them here for useful ones!"));
            }
            this.m_convertor_tooltip_mc.visible = visibilty;
         }
      }
      
      private function refreshConvertorProgress(clickedTab:int, partsInConvertor:Number, partsNeededToConvert:Number) : void
      {
         var frameToPlay:int = 0;
         var visibilty:Boolean = !manager.isActivePuzzleCompleted() && clickedTab == manager.getActivePuzzleId();
         if(this.m_convert_bt)
         {
            this.m_convert_bt.visible = visibilty;
            this.m_convert_bt.enabled = partsInConvertor >= partsNeededToConvert;
            if(!manager.isFeatureinActivePeriod())
            {
               this.m_convert_bt.enabled = false;
            }
         }
         if(this.m_anim_mc)
         {
            this.m_anim_mc.visible = visibilty && partsInConvertor >= partsNeededToConvert;
            this.m_anim_mc.gotoAndPlay(1);
         }
         if(this.m_fill_mc)
         {
            frameToPlay = partsInConvertor / (partsNeededToConvert / this.m_fill_mc.totalFrames) + 1;
            this.m_fill_mc.gotoAndStop(frameToPlay);
            this.m_fill_mc.visible = visibilty;
         }
         if(this.m_count_tf)
         {
            this.m_count_tf.text = String(partsInConvertor) + "/" + String(partsNeededToConvert);
            this.m_count_tf.visible = visibilty;
         }
      }
      
      private function playConvertorProgressDoober(progress:Number) : void
      {
         if(this.m_doober_mc)
         {
            this.m_doober_mc.visible = true;
            this.m_anim_mc.visible = true;
            if(this.m_anim2_mc)
            {
               this.m_anim2_mc.visible = true;
            }
            if(this.m_dooberIcon_mc)
            {
               this.m_dooberIcon_mc.visible = true;
            }
            if(this.m_dooberCount_tf)
            {
               this.m_dooberCount_tf.text = "+" + String(progress);
            }
         }
         this.m_doober_mc.gotoAndPlay(1);
         this.m_doober_mc.addEventListener(Event.ENTER_FRAME,this.onConvertorDooberPlayed);
      }
      
      private function onConvertorDooberPlayed(event:Event) : void
      {
         if(this.m_doober_mc)
         {
            if(this.m_doober_mc.currentFrame == 31)
            {
               this.m_doober_mc.gotoAndStop(1);
               this.m_doober_mc.visible = false;
               if(this.m_anim2_mc)
               {
                  this.m_anim2_mc.visible = false;
               }
               if(this.m_dooberIcon_mc)
               {
                  this.m_dooberIcon_mc.visible = false;
               }
               if(this.m_dooberCount_tf)
               {
                  this.m_dooberCount_tf.visible = false;
               }
               this.updateConvertorProgress();
               this.m_doober_mc.removeEventListener(Event.ENTER_FRAME,this.onConvertorDooberPlayed);
            }
         }
      }
      
      private function updateConvertorProgress() : void
      {
         var convertorProgress:Number = manager.getConvertorProgress();
         var partsInConvertor:Number = manager.getPartsInConvertor();
         var totalPartsInConvertor:Number = partsInConvertor + convertorProgress;
         var partsNeededToConvert:int = manager.getMinPartsNeededToConvert();
         this.refreshConvertorProgress(manager.getActivePuzzleId(),totalPartsInConvertor,partsNeededToConvert);
      }
      
      public function refreshActivePuzzleReward(clickedTab:int) : void
      {
         var visibilty:Boolean = !manager.isActivePuzzleCompleted() && clickedTab == manager.getActivePuzzleId();
         if(this.m_reward_mc)
         {
            this.m_reward_mc.visible = visibilty;
            this.m_reward_mc.gotoAndStop(clickedTab + 1);
         }
         if(this.m_reward_tf)
         {
            this.m_reward_tf.visible = visibilty;
         }
         if(this.m_reward_tooltip_mc)
         {
            this.m_reward_tooltip_mc.detachTooltip();
            if(manager.isFeatureinActivePeriod() && visibilty)
            {
               this.m_reward_tooltip_mc.attachTooltip(new FarmTextTooltip("Complete the page to win this reward!"));
            }
            this.m_reward_tooltip_mc.visible = visibilty;
         }
      }
      
      public function refreshFindPartsButton(clickedTab:int) : void
      {
         var visibilty:Boolean = manager.isFeatureinActivePeriod() && !manager.isActivePuzzleCompleted() && clickedTab == manager.getActivePuzzleId();
         if(this.m_find_bt)
         {
            this.m_find_bt.visible = visibilty;
         }
      }
      
      public function refreshFinder() : void
      {
         var visibilty:Boolean = manager.isFeatureinActivePeriod() && !manager.isFeatureCompleted();
         if(this.m_finder_mc)
         {
            this.m_finder_mc.visible = visibilty;
         }
         if(this.m_level_tf)
         {
            this.refreshFinderLevelText();
            this.m_level_tf.visible = visibilty;
         }
         if(this.m_upgrade_bt)
         {
            this.m_upgrade_bt.visible = visibilty;
         }
      }
      
      public function refreshBonusReward() : void
      {
         var visibilty:Boolean = manager.isFeatureinActivePeriod() && !manager.isFeatureCompleted();
         if(this.m_bonus_mc)
         {
            this.m_bonus_mc.visible = visibilty;
         }
         if(this.m_bonus_tooltip_mc)
         {
            this.m_bonus_tooltip_mc.detachTooltip();
            if(manager.isFeatureinActivePeriod() && visibilty)
            {
               this.m_bonus_tooltip_mc.attachTooltip(new FarmTextTooltip("Complete all the pages to win this bonus reward!"));
            }
            this.m_bonus_tooltip_mc.visible = visibilty;
         }
      }
      
      public function updatePuzzleProgress(clickedTab:int) : void
      {
         this.refreshPuzzleComponents(clickedTab);
         manager.updatePuzzleProgress();
         this.refreshNonPuzzleComponents(clickedTab);
         if(this.shouldShowConvertReadyCallout())
         {
            this.showConvertReadyCallout();
            Global.player.setFeatureLastShown(JUMBLEVILLA_CONVERT_READY_CALLOUT,FarmGameUtil.getMidnightTimestamp() / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         }
         if(this.shouldShowStoryCompleteCallout())
         {
            Global.player.setSeenFlag(JUMBLEVILLA_STORY_COMPLETE_SEEN);
            this.showStoryCompleteCallout();
         }
      }
      
      private function shouldShowJumbleVillaIntro() : Boolean
      {
         return manager.isFeatureinActivePeriod() && !manager.isFeatureCompleted() && !Global.player.getSeenFlag(JUMBLEVILLA_INTRO_SEEN);
      }
      
      private function shouldShowFinderUpgradeCallout() : Boolean
      {
         return manager.isFeatureinActivePeriod() && !manager.isFeatureCompleted() && !this.shouldShowStoryCompleteCallout() && !this.shouldShowJumbleVillaIntro() && manager.hasFinderUpgraded();
      }
      
      private function shouldShowStoryCompleteCallout() : Boolean
      {
         return manager.isFeatureinActivePeriod() && !manager.isFeatureCompleted() && this.hasLastPuzzleCompleted() && !Global.player.getSeenFlag(JUMBLEVILLA_STORY_COMPLETE_SEEN);
      }
      
      private function shouldShowConvertReadyCallout() : Boolean
      {
         return manager.isFeatureinActivePeriod() && !manager.isFeatureCompleted() && this.getTimeLeftToShowConvertCallout() <= 0 && manager.isConvertorReady() && !manager.isActivePuzzleCompleted() && !this.shouldShowStoryCompleteCallout() && !this.shouldShowFinderUpgradeCallout();
      }
      
      private function getTimeLeftToShowConvertCallout() : Number
      {
         var timeSinceLastFeed:Number = FarmGameUtil.getMidnightTimestamp() / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(JUMBLEVILLA_CONVERT_READY_CALLOUT);
         return this.DEFAULT_THROTTLE_TIME - timeSinceLastFeed;
      }
      
      private function hasLastPuzzleCompleted() : Boolean
      {
         return manager.getActivePuzzleId() == manager.getLastPuzzleId() && manager.isActivePuzzleCompleted();
      }
      
      private function showFinderUpgradedCallout() : void
      {
         if(this.m_ftue_mc)
         {
            this.refreshFtueFrame(2);
         }
      }
      
      private function showStoryCompleteCallout() : void
      {
         if(this.m_ftue_mc)
         {
            this.refreshFtueFrame(3);
         }
      }
      
      private function showConvertReadyCallout() : void
      {
         if(this.m_ftue_mc)
         {
            this.refreshFtueFrame(1);
         }
      }
      
      public function refreshPuzzleComponents(clickedTab:int) : void
      {
         this.refreshConvertor(clickedTab);
         this.refreshPuzzleFrame(clickedTab);
      }
      
      public function refreshTutorialButton() : void
      {
         if(this.m_whatisthis_bt)
         {
            this.m_whatisthis_bt.visible = manager.isFeatureinActivePeriod() && !manager.isFeatureCompleted();
         }
      }
      
      public function refreshDaysLeftText() : void
      {
         var featureEndsInText:String = null;
         if(this.m_days_tf)
         {
            if(manager.isFeatureinActivePeriod())
            {
               featureEndsInText = "Ends in " + manager.getFeatureEndDaysLeftText();
            }
            else
            {
               featureEndsInText = "Ended";
            }
            this.m_days_tf.text = featureEndsInText;
            this.m_days_tf.visible = true;
         }
      }
      
      public function refreshNonPuzzleComponents(clickedTab:int) : void
      {
         this.refreshConvertorVisibility(clickedTab);
         this.refreshActivePuzzleReward(clickedTab);
         this.refreshFindPartsButton(clickedTab);
         this.refreshNonPuzzleFrame(clickedTab);
         this.refreshFinder();
         this.refreshBonusReward();
         this.refreshTutorialButton();
      }
      
      public function hideFinderAndBonusRewards() : void
      {
         if(this.m_finder_mc)
         {
            this.m_finder_mc.visible = false;
         }
         if(this.m_bonus_mc)
         {
            this.m_bonus_mc.visible = false;
         }
         if(this.m_bonus_tooltip_mc)
         {
            this.m_bonus_tooltip_mc.visible = false;
         }
      }
      
      public function unhideFinderAndBonusRewards() : void
      {
         this.refreshFinder();
         this.refreshBonusReward();
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
      
      private function onTimer(event:TimerEvent) : void
      {
         this.refreshDaysLeftText();
      }
      
      override public function close() : void
      {
         this.stopTimer();
         manager.mainWindow = null;
         super.close();
      }
   }
}

