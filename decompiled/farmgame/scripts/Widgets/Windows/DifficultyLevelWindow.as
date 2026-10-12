package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.DifficultyLevelManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class DifficultyLevelWindow extends FarmWindow
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 4;
      
      private static const FTUE_FLAG:String = "ftue";
      
      public static const STAGE_COMPLETION_KEY:String = "stageComplete";
      
      public static const FEATURE_OPTIONS_KEY:String = "mystreereskin";
      
      protected var m_featureName:String;
      
      protected var m_difficultyLevel:int;
      
      protected var m_tutorialButton:FarmAnimatedTextButton;
      
      protected var m_titleTextField:ZwTextField;
      
      protected var m_subtitleTextField:ZwTextField;
      
      protected var m_whatisthisBtn:FarmAnimatedButton;
      
      protected var m_windowName:String;
      
      protected var m_DifficultyLevelManager:DifficultyLevelManager;
      
      protected var m_selectedButtonArray:Array = new Array();
      
      protected var m_selectedDifficultyLevel:int;
      
      protected var m_count_tf:ZwTextField;
      
      protected var m_count_mc:MovieClip = new MovieClip();
      
      private var m_ftue:MovieClip = null;
      
      private var m_tutorialScene:int;
      
      private var m_size_mc:MovieClip = new MovieClip();
      
      private var m_slot_mc:MovieClip = new MovieClip();
      
      private var m_redeem_bt:FarmAnimatedButton;
      
      private var m_slotTtile:ZwTextField;
      
      private var m_slotBody:ZwTextField;
      
      private var m_slotSubTitle:ZwTextField;
      
      private var m_recommended_mc:MovieClip = new MovieClip();
      
      public function DifficultyLevelWindow(windowURL:String)
      {
         super(windowURL);
         this.m_difficultyLevel = this.m_DifficultyLevelManager.getCurrentDifficultyLevel();
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.whatisthis_mc)
         {
            addWidget(this.m_whatisthisBtn = new FarmAnimatedButton(m_window.whatisthis_mc,this.onWhatIsThisClick));
            this.m_whatisthisBtn.attachTooltip(new FarmTextTooltip("Click to know more"));
         }
         if(m_window.select_bt_0)
         {
            addWidget(new FarmAnimatedTextButton(m_window.select_bt_0,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_windowName + "_difficultylevel0_title"),this.onSelectSmallLevel));
         }
         if(m_window.select_bt_1)
         {
            addWidget(new FarmAnimatedTextButton(m_window.select_bt_1,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_windowName + "_difficultylevel1_title"),this.onSelectMediumLevel));
         }
         if(m_window.select_bt_2)
         {
            addWidget(new FarmAnimatedTextButton(m_window.select_bt_2,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_windowName + "_difficultylevel2_title"),this.onSelectBigLevel));
         }
         this.m_selectedButtonArray[0] = m_window.button_0_mc;
         this.m_selectedButtonArray[0].visible = false;
         this.m_selectedButtonArray[1] = m_window.button_1_mc;
         this.m_selectedButtonArray[1].visible = false;
         this.m_selectedButtonArray[2] = m_window.button_2_mc;
         this.m_selectedButtonArray[2].visible = false;
         if(m_window.redeem_bt)
         {
            addWidget(this.m_redeem_bt = new FarmAnimatedButton(m_window.redeem_bt,this.onSelectLevel));
         }
         if(m_window.hasOwnProperty("size_mc"))
         {
            this.m_size_mc = m_window.size_mc;
            this.m_size_mc.visible = true;
         }
         if(m_window.hasOwnProperty("slot_mc"))
         {
            this.m_slot_mc = m_window.slot_mc;
            if(this.m_slot_mc)
            {
               this.m_slot_mc.visible = true;
               this.m_slotTtile = new ZwTextField(this.m_slot_mc.title_tf,"");
               this.m_slotBody = new ZwTextField(this.m_slot_mc.body_tf,"");
               this.m_slotSubTitle = new ZwTextField(this.m_slot_mc.copy_tf,"");
               this.m_recommended_mc = this.m_slot_mc.recommend_mc;
               this.showRecommended();
            }
         }
         if(m_window.time_tf)
         {
            addWidget(new ZwTextField(m_window.time_tf,this.getExpiryDateText()));
         }
         if(m_window.copy_tf)
         {
            addWidget(new ZwTextField(m_window.copy_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_windowName + "_DifficultyWindowSubTtile")));
         }
         addWidget(this.m_titleTextField = new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_windowName + "_title")));
         var firstTimeSeenFlag:String = this.m_featureName + "difficulty" + FTUE_FLAG;
         if(!Global.player.getSeenFlag(firstTimeSeenFlag))
         {
            this.setupFTUE();
            this.showFTUE();
         }
      }
      
      private function setupFTUE() : void
      {
         this.m_ftue = m_window.tutorial_mc as MovieClip;
         if(this.m_ftue)
         {
            this.m_ftue.visible = false;
            if(this.m_tutorialButton == null && this.m_ftue.hasOwnProperty("okay_bt"))
            {
               addWidget(this.m_tutorialButton = new FarmAnimatedTextButton(this.m_ftue.okay_bt,ZLocUtils.t("Dialogs","Okay"),this.onFTUEOkBtnClick));
            }
         }
      }
      
      protected function getExpiryDateText() : String
      {
         return FarmGameUtil.getFeatureExpiryDateText(this.m_DifficultyLevelManager.getEndDate(),"Generic_ExpiryText",this.m_DifficultyLevelManager.getAdditionalDaysForRedeem());
      }
      
      private function showFTUE() : void
      {
         if(!this.m_ftue)
         {
            this.setupFTUE();
         }
         this.m_tutorialScene = 1;
         this.m_ftue.gotoAndStop(this.m_tutorialScene);
         this.m_tutorialButton.text = ZLocUtils.t("Dialogs","Okay");
         this.m_ftue.visible = true;
         FarmStatsManager.count(this.m_featureName,"FTUE_1","start",this.getTutorialPopUpType(),String(this.m_tutorialScene));
      }
      
      private function getTutorialPopUpType() : String
      {
         var firstTimeSeenFlag:String = this.m_featureName + "difficulty" + FTUE_FLAG;
         var tutorialPopUpType:String = "repop";
         if(!Global.player.getSeenFlag(firstTimeSeenFlag))
         {
            tutorialPopUpType = "autopop";
         }
         return tutorialPopUpType;
      }
      
      private function onFTUEOkBtnClick(event:Event) : void
      {
         var firstTimeSeenFlag:String = null;
         if(this.m_tutorialScene++ < NUM_TUTORIAL_SCENES)
         {
            (this.m_ftue as MovieClip).play();
            if(this.m_tutorialScene == NUM_TUTORIAL_SCENES)
            {
               this.m_tutorialButton.text = ZLocUtils.t("Dialogs","Okay");
            }
            FarmStatsManager.count(this.m_featureName,"FTUE_1","start",this.getTutorialPopUpType(),String(this.m_tutorialScene));
         }
         else
         {
            firstTimeSeenFlag = this.m_featureName + "difficulty" + FTUE_FLAG;
            FarmStatsManager.count(this.m_featureName,"FTUE_1","end",this.getTutorialPopUpType());
            Global.player.setSeenFlag(firstTimeSeenFlag);
            this.m_ftue.visible = false;
         }
      }
      
      private function onSelectLevel(event:Event) : void
      {
         var featureOptionData:Object = null;
         var stageCompletion:String = null;
         if(this.m_difficultyLevel == this.m_selectedDifficultyLevel)
         {
            this.m_DifficultyLevelManager.openConfirmationWindow(this.acceptDifficultyLevelConfirmation,this.m_selectedDifficultyLevel.toString());
         }
         else
         {
            this.m_difficultyLevel = this.m_selectedDifficultyLevel;
            featureOptionData = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName);
            stageCompletion = STAGE_COMPLETION_KEY + this.m_difficultyLevel.toString();
            if(Boolean(featureOptionData) && featureOptionData[stageCompletion] == 1)
            {
               this.m_DifficultyLevelManager.openConfirmationWindow(this.acceptDifficultyLevelConfirmation,this.m_selectedDifficultyLevel.toString());
            }
            else
            {
               this.acceptDifficultyLevelConfirmation();
            }
         }
      }
      
      private function acceptDifficultyLevelConfirmation() : void
      {
         close();
         this.m_DifficultyLevelManager.setDifficultyLevel(this.m_difficultyLevel);
      }
      
      private function onWhatIsThisClick(event:Event) : void
      {
         this.showFTUE();
      }
      
      override protected function release() : void
      {
         this.m_subtitleTextField = null;
         this.m_titleTextField = null;
         this.m_whatisthisBtn = null;
         this.m_tutorialButton = null;
         this.m_ftue = null;
         super.release();
      }
      
      private function onSelectSmallLevel(event:Event) : void
      {
         this.m_selectedDifficultyLevel = 0;
         this.resetStageButtons();
      }
      
      private function onSelectMediumLevel(event:Event) : void
      {
         this.m_selectedDifficultyLevel = 1;
         this.resetStageButtons();
      }
      
      private function onSelectBigLevel(event:Event) : void
      {
         this.m_selectedDifficultyLevel = 2;
         this.resetStageButtons();
      }
      
      public function resetStageButtons() : void
      {
         if(this.m_recommended_mc)
         {
            if(this.m_selectedDifficultyLevel != this.m_DifficultyLevelManager.recommendedDifficultyLevel)
            {
               this.m_recommended_mc.visible = false;
            }
            else
            {
               this.m_recommended_mc.visible = true;
            }
         }
         for(var i:int = 0; i < this.m_selectedButtonArray.length; i++)
         {
            this.m_selectedButtonArray[i].generic_tf.visible = false;
            this.m_selectedButtonArray[i].stageselect_mc.visible = false;
         }
         this.m_selectedButtonArray[this.m_selectedDifficultyLevel].visible = true;
         this.m_selectedButtonArray[this.m_selectedDifficultyLevel].generic_tf.visible = true;
         this.m_selectedButtonArray[this.m_selectedDifficultyLevel].generic_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_windowName + "_difficultylevel" + this.m_selectedDifficultyLevel + "_title");
         this.m_selectedButtonArray[this.m_selectedDifficultyLevel].stageselect_mc.visible = true;
         this.m_slotTtile.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_windowName + "_difficultylevel" + this.m_selectedDifficultyLevel + "_title");
         this.m_slotSubTitle.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_windowName + "_difficultylevel" + this.m_selectedDifficultyLevel + "_subtitle");
         this.m_slotBody.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_windowName + "_difficultylevel" + this.m_selectedDifficultyLevel + "_body_text");
      }
      
      public function showRecommended() : void
      {
         this.m_selectedDifficultyLevel = this.m_DifficultyLevelManager.recommendedDifficultyLevel;
         this.resetStageButtons();
      }
   }
}

