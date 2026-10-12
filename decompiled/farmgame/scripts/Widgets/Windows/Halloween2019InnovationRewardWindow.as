package Widgets.Windows
{
   import Managers.OrderBoard.Halloween2019InnovationManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class Halloween2019InnovationRewardWindow extends FarmWindowWithTutorial
   {
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private var m_featureName:String;
      
      private var m_highLighterMCArray:Array;
      
      private var m_progressLevelArray_mc:Array;
      
      private var m_progressLevelArray_tf:Array;
      
      public const ProgressLevelTextArray:Array = ["Abandoned Nisse House","Nisse Gift House","Nisse Gift Workshop","Nisse Gift Factory"];
      
      public const ProgressLevelPointArray:Array = ["1 week","2 weeks","3 weeks","4 weeks"];
      
      public const ProgressLevelSubtextArray:Array = ["Abandoned Nisse House","Nisse Gift House","Nisse Gift Workshop","Nisse Gift Factory"];
      
      private const BACK_BT:String = "okay_bt";
      
      private var m_knowMoreMC:MovieClip;
      
      private var m_knowMoreCloseBt:FarmButton;
      
      private var m_previewMCArray:Array = [];
      
      private var m_rewardMCArray:Array = [];
      
      private var m_knowMoreBt:FarmAnimatedButton;
      
      private const FINALREWARD_WELCOME_SEEN_FLAG:String = "Final_Reward_Welcome_flag";
      
      private var m_progressMc:MovieClip;
      
      private const MAX_POINT:int = 100;
      
      private const PROGRESS_BAR_FULL_WIDTH:int = 800;
      
      private var m_meter_mc:MovieClip;
      
      private var m_check_point_mc:MovieClip;
      
      private var m_meter_fill_mc:MovieClip;
      
      private var m_points_mc:MovieClip;
      
      private var m_points_tf:ZwTextField;
      
      private var m_level1_mc:MovieClip;
      
      private var m_level1reward_mc:MovieClip;
      
      private var m_level2_mc:MovieClip;
      
      private var m_level2reward_mc:MovieClip;
      
      private var m_level3_mc:MovieClip;
      
      private var m_level3reward_mc:MovieClip;
      
      private var m_level4_mc:MovieClip;
      
      private var m_level4reward_mc:MovieClip;
      
      private var m_hitareaExperMc:MovieClip;
      
      private var m_hitareaGrandMasterMc:MovieClip;
      
      private var m_hitareaMasterMc:MovieClip;
      
      private var m_hitareaNoviceMc:MovieClip;
      
      private var m_currentElement_mc:MovieClip;
      
      private var m_tutorialMc:MovieClip;
      
      private var m_arrowMc:MovieClip;
      
      private var m_npcCircleMc:MovieClip;
      
      private var m_whatIsThisBt:FarmAnimatedTextButton;
      
      private var m_tutorialButtons:Array = [];
      
      private var m_expertAniMc:MovieClip;
      
      private var m_grandMasterAniMc:MovieClip;
      
      private var m_masterAniMc:MovieClip;
      
      private var m_noviceAniMc:MovieClip;
      
      private var m_rewardHitArea0:ZwFrame;
      
      private var m_rewardHitArea1:ZwFrame;
      
      private var m_rewardHitArea2:ZwFrame;
      
      private var m_rewardHitArea3:ZwFrame;
      
      private var m_rewardHitArea4:ZwFrame;
      
      private var m_rewardHitArea5:ZwFrame;
      
      private var m_rewardHitArea6:ZwFrame;
      
      private var m_check0Mc:MovieClip;
      
      private var m_check1Mc:MovieClip;
      
      private var m_check2Mc:MovieClip;
      
      private var m_check3Mc:MovieClip;
      
      private var m_check4Mc:MovieClip;
      
      private var m_check5Mc:MovieClip;
      
      private var m_check6Mc:MovieClip;
      
      private const HALLOWEEN2019_RW_FTUE_FLAG:String = "halloween2019_rewardwindow_ftue_flag";
      
      private var NUM_TUTORIAL_SCENES:int = 3;
      
      private var TUTORIAL_BUTTON_TEXT_ARRAY:Array = ["Next","Next","Let’s go!"];
      
      private const HALLOWEEN2019_REWADWINDOW_FTUE_FLAG:String = "halloween2019_rewadwindow_ftue_flag";
      
      public function Halloween2019InnovationRewardWindow(featureName:String, assetPath:String = "")
      {
         this.m_featureName = featureName;
         super(this.m_featureName,assetPath,this.NUM_TUTORIAL_SCENES);
      }
      
      override protected function postLoadComplete() : void
      {
         var i:int = 0;
         var buttonName:String = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("howDoesThisWork_mc"))
         {
            addWidget(this.m_whatIsThisBt = new FarmAnimatedTextButton(m_window.howDoesThisWork_mc,"",this.onHowDoesThisWorkClick));
            this.m_whatIsThisBt.visible = true;
         }
         if(m_window.hasOwnProperty("knowMore_mc"))
         {
            this.m_knowMoreMC = m_window.knowMore_mc as MovieClip;
            this.m_knowMoreMC.visible = false;
            if(this.m_knowMoreMC.hasOwnProperty("close_bt"))
            {
               this.m_knowMoreCloseBt = new FarmButton(this.m_knowMoreMC["close_bt"],this.onKnowMoreMcClose);
               this.m_knowMoreBt.attachTooltip(new FarmTextTooltip("Know More"));
            }
         }
         if(m_window.hasOwnProperty("tutorial_mc"))
         {
            this.m_tutorialMc = m_window["tutorial_mc"] as MovieClip;
            if(this.m_tutorialMc)
            {
               for(i = 0; i < 3; i++)
               {
                  buttonName = "okay_" + (i + 1).toString() + "_bt";
                  if(this.m_tutorialMc.hasOwnProperty(buttonName))
                  {
                     this.m_tutorialButtons[i] = new FarmAnimatedTextButton(this.m_tutorialMc[buttonName]);
                     this.m_tutorialButtons[i].visible = false;
                  }
               }
            }
         }
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            m_window[this.TITLE_TF].visible = true;
            m_window[this.TITLE_TF].text = "Rewards";
         }
         if(m_window.hasOwnProperty("subtext_tf"))
         {
            m_window["subtext_tf"].visible = true;
            m_window["subtext_tf"].text = "Give kids the candies they are asking for and earn more points!";
         }
         if(m_window.hasOwnProperty("npc_mc"))
         {
            m_window["npc_mc"].visible = true;
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            m_window[this.BODY_TF].visible = true;
            m_window[this.BODY_TF].text = "Level up as";
         }
         if(m_window.hasOwnProperty("body2_tf"))
         {
            m_window["body2_tf"].visible = true;
            m_window["body2_tf"].text = "The more of harder tasks you do the more candies you earn leading to adition points.";
         }
         if(m_window.hasOwnProperty("all_meter_mc"))
         {
            this.m_progressMc = m_window.all_meter_mc as MovieClip;
            this.m_progressMc.visible = true;
            if(this.m_progressMc.hasOwnProperty("points_mc"))
            {
               this.m_points_mc = this.m_progressMc["points_mc"] as MovieClip;
               this.m_points_mc.visible = true;
               if(this.m_points_mc.hasOwnProperty("points_tf"))
               {
                  addWidget(this.m_points_tf = new ZwTextField(this.m_points_mc["points_tf"],this.manager.getFeaturePoints().toString()));
                  this.m_points_tf.visible = true;
               }
            }
         }
         if(this.m_progressMc.hasOwnProperty("meter_mc"))
         {
            this.m_meter_mc = this.m_progressMc["meter_mc"] as MovieClip;
            this.m_meter_mc.visible = true;
         }
         if(this.m_progressMc.hasOwnProperty("checkmark_0_mc"))
         {
            this.m_check0Mc = this.m_progressMc["checkmark_0_mc"] as MovieClip;
            this.m_check0Mc.visible = this.manager.getFeaturePoints() >= this.manager.VAL_MILESTONE_POINTS_ARRAY[0];
         }
         if(this.m_progressMc.hasOwnProperty("checkmark_1_mc"))
         {
            this.m_check1Mc = this.m_progressMc["checkmark_1_mc"] as MovieClip;
            this.m_check1Mc.visible = this.manager.getFeaturePoints() >= this.manager.VAL_MILESTONE_POINTS_ARRAY[1];
         }
         if(this.m_progressMc.hasOwnProperty("checkmark_2_mc"))
         {
            this.m_check2Mc = this.m_progressMc["checkmark_2_mc"] as MovieClip;
            this.m_check2Mc.visible = this.manager.getFeaturePoints() >= this.manager.VAL_MILESTONE_POINTS_ARRAY[2];
         }
         if(this.m_progressMc.hasOwnProperty("checkmark_3_mc"))
         {
            this.m_check3Mc = this.m_progressMc["checkmark_3_mc"] as MovieClip;
            this.m_check3Mc.visible = this.manager.getFeaturePoints() >= this.manager.VAL_MILESTONE_POINTS_ARRAY[3];
         }
         if(this.m_progressMc.hasOwnProperty("checkmark_4_mc"))
         {
            this.m_check4Mc = this.m_progressMc["checkmark_4_mc"] as MovieClip;
            this.m_check4Mc.visible = this.manager.getFeaturePoints() >= this.manager.VAL_MILESTONE_POINTS_ARRAY[4];
         }
         if(this.m_progressMc.hasOwnProperty("checkmark_5_mc"))
         {
            this.m_check5Mc = this.m_progressMc["checkmark_5_mc"] as MovieClip;
            this.m_check5Mc.visible = this.manager.getFeaturePoints() >= this.manager.VAL_MILESTONE_POINTS_ARRAY[5];
         }
         if(this.m_progressMc.hasOwnProperty("checkmark_6_mc"))
         {
            this.m_check6Mc = this.m_progressMc["checkmark_6_mc"] as MovieClip;
            this.m_check6Mc.visible = this.manager.getFeaturePoints() >= this.manager.VAL_MILESTONE_POINTS_ARRAY[6];
         }
         if(this.m_progressMc.hasOwnProperty("reward_hitarea_0_mc"))
         {
            this.m_rewardHitArea0 = new ZwFrame(this.m_progressMc["reward_hitarea_0_mc"]);
            this.m_rewardHitArea0.visible = true;
            this.m_rewardHitArea0.attachTooltip(new FarmTextTooltip("Candy Prison Horse"));
         }
         if(this.m_progressMc.hasOwnProperty("reward_hitarea_1_mc"))
         {
            this.m_rewardHitArea1 = new ZwFrame(this.m_progressMc["reward_hitarea_1_mc"]);
            this.m_rewardHitArea1.visible = true;
            this.m_rewardHitArea1.attachTooltip(new FarmTextTooltip("Pumpkin Magic Unicorn"));
         }
         if(this.m_progressMc.hasOwnProperty("reward_hitarea_2_mc"))
         {
            this.m_rewardHitArea2 = new ZwFrame(this.m_progressMc["reward_hitarea_2_mc"]);
            this.m_rewardHitArea2.visible = true;
            this.m_rewardHitArea2.attachTooltip(new FarmTextTooltip("Witch-O-Horse"));
         }
         if(this.m_progressMc.hasOwnProperty("reward_hitarea_3_mc"))
         {
            this.m_rewardHitArea3 = new ZwFrame(this.m_progressMc["reward_hitarea_3_mc"]);
            this.m_rewardHitArea3.visible = true;
            this.m_rewardHitArea3.attachTooltip(new FarmTextTooltip("Super Hero Pegasus"));
         }
         if(this.m_progressMc.hasOwnProperty("reward_hitarea_4_mc"))
         {
            this.m_rewardHitArea4 = new ZwFrame(this.m_progressMc["reward_hitarea_4_mc"]);
            this.m_rewardHitArea4.visible = true;
            this.m_rewardHitArea4.attachTooltip(new FarmTextTooltip("Pumpkin Plant Unicorn"));
         }
         if(this.m_progressMc.hasOwnProperty("reward_hitarea_5_mc"))
         {
            this.m_rewardHitArea5 = new ZwFrame(this.m_progressMc["reward_hitarea_5_mc"]);
            this.m_rewardHitArea5.visible = true;
            this.m_rewardHitArea5.attachTooltip(new FarmTextTooltip("Raggedy Unicorn"));
         }
         if(this.m_progressMc.hasOwnProperty("reward_hitarea_6_mc"))
         {
            this.m_rewardHitArea6 = new ZwFrame(this.m_progressMc["reward_hitarea_6_mc"]);
            this.m_rewardHitArea6.visible = true;
            this.m_rewardHitArea6.attachTooltip(new FarmTextTooltip("Spider Pegacorn"));
         }
         if(m_window.hasOwnProperty("consumable_expert_ani_mc"))
         {
            this.m_expertAniMc = m_window["consumable_expert_ani_mc"] as MovieClip;
            this.m_expertAniMc.visible = false;
         }
         if(m_window.hasOwnProperty("consumable_grand_master_ani_mc"))
         {
            this.m_grandMasterAniMc = m_window["consumable_grand_master_ani_mc"] as MovieClip;
            this.m_grandMasterAniMc.visible = false;
         }
         if(m_window.hasOwnProperty("consumable_master_ani_mc"))
         {
            this.m_masterAniMc = m_window["consumable_master_ani_mc"] as MovieClip;
            this.m_masterAniMc.visible = false;
         }
         if(m_window.hasOwnProperty("consumable_novice_ani_mc"))
         {
            this.m_noviceAniMc = m_window["consumable_novice_ani_mc"] as MovieClip;
            this.m_noviceAniMc.visible = false;
         }
         if(m_window.hasOwnProperty("hitarea_expert_mc"))
         {
            this.m_hitareaExperMc = m_window["hitarea_expert_mc"] as MovieClip;
            this.m_hitareaExperMc.visible = true;
            this.m_hitareaExperMc.addEventListener(MouseEvent.MOUSE_OVER,this.onHitExpertMouseRollOver);
            this.m_hitareaExperMc.addEventListener(MouseEvent.MOUSE_OUT,this.onHitExpertMouseRollOut);
         }
         if(m_window.hasOwnProperty("hitarea_grand_master_mc"))
         {
            this.m_hitareaGrandMasterMc = m_window["hitarea_grand_master_mc"] as MovieClip;
            this.m_hitareaGrandMasterMc.visible = true;
            this.m_hitareaGrandMasterMc.addEventListener(MouseEvent.MOUSE_OVER,this.onHitGrandMastertMouseRollOver);
            this.m_hitareaGrandMasterMc.addEventListener(MouseEvent.MOUSE_OUT,this.onHitGrandMastertMouseRollOut);
         }
         if(m_window.hasOwnProperty("hitarea_master_mc"))
         {
            this.m_hitareaMasterMc = m_window["hitarea_master_mc"] as MovieClip;
            this.m_hitareaMasterMc.visible = true;
            this.m_hitareaMasterMc.addEventListener(MouseEvent.MOUSE_OVER,this.onHitMastertMouseRollOver);
            this.m_hitareaMasterMc.addEventListener(MouseEvent.MOUSE_OUT,this.onHitMastertMouseRollOut);
         }
         if(m_window.hasOwnProperty("hitarea_novice_mc"))
         {
            this.m_hitareaNoviceMc = m_window["hitarea_novice_mc"] as MovieClip;
            this.m_hitareaNoviceMc.visible = true;
            this.m_hitareaNoviceMc.addEventListener(MouseEvent.MOUSE_OVER,this.onHitNoviceMouseRollOver);
            this.m_hitareaNoviceMc.addEventListener(MouseEvent.MOUSE_OUT,this.onHitNoviceMouseRollOut);
         }
         this.updateEarnedPoints();
         if(m_window.hasOwnProperty(this.BACK_BT))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.BACK_BT],"AWESOME",onClose));
         }
         if(!this.hasSeenFeatureWelcome())
         {
            Global.player.setSeenFlag(this.FINALREWARD_WELCOME_SEEN_FLAG);
         }
         for(var j:int = 0; j < this.ProgressLevelTextArray.length; j++)
         {
            if(m_window.hasOwnProperty("info" + (j + 1).toString() + "_tf"))
            {
               m_window["info" + (j + 1).toString() + "_tf"].visible = true;
               m_window["info" + (j + 1).toString() + "_tf"].text = "Get an ‘Ecstatic’ Happiness Rating for at least " + this.ProgressLevelPointArray[j] + " to get this building!";
            }
         }
         if(!Global.player.getSeenFlag(this.HALLOWEEN2019_REWADWINDOW_FTUE_FLAG))
         {
            Global.player.setSeenFlag(this.HALLOWEEN2019_REWADWINDOW_FTUE_FLAG);
            this.showTutorial1();
         }
      }
      
      public function updateEarnedPoints(onOpenWindow:Boolean = false) : void
      {
         var progressPoints:int = 0;
         var barWidth:Number = NaN;
         if(this.m_points_mc)
         {
            progressPoints = this.manager.getFeaturePoints();
            barWidth = progressPoints * 800 / 4500;
            this.m_points_mc.x = barWidth - 18.5;
            this.m_points_mc.gotoAndStop(this.manager.getBadgeIndex());
            this.m_points_mc.points_tf.text = "x" + progressPoints.toString();
            this.m_points_tf.visible = true;
            this.m_points_mc.visible;
         }
      }
      
      public function onMouseOver(slotIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            if(slotIndex == 0)
            {
               return;
            }
            m_rewardMCArray[slotIndex].visible = true;
            (m_rewardMCArray[slotIndex] as MovieClip).gotoAndPlay(2);
         };
      }
      
      public function onMouseOut(slotIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            if(slotIndex == 0)
            {
               return;
            }
            (m_rewardMCArray[slotIndex] as MovieClip).gotoAndPlay(61);
            m_rewardMCArray[slotIndex].visible = true;
         };
      }
      
      private function updateHighLighter() : void
      {
         var activeRewardIndex:int = this.manager.getMilestoneLevel() - 1;
         if(activeRewardIndex >= 0)
         {
            if(activeRewardIndex > 0)
            {
               this.m_highLighterMCArray[activeRewardIndex].visible = true;
               this.m_rewardMCArray[activeRewardIndex].visible = true;
               this.m_rewardMCArray[activeRewardIndex].play();
            }
            this.m_progressLevelArray_mc[activeRewardIndex].gotoAndStop(2);
         }
      }
      
      private function get manager() : Halloween2019InnovationManager
      {
         return Halloween2019InnovationManager.getInstance();
      }
      
      override public function close() : void
      {
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
         }
         super.close();
      }
      
      private function onKnowMoreMcClose(e:Event = null) : void
      {
         this.m_knowMoreMC.visible = false;
      }
      
      private function hasSeenFeatureWelcome() : Boolean
      {
         return Global.player.getSeenFlag(this.FINALREWARD_WELCOME_SEEN_FLAG);
      }
      
      private function onHitExpertMouseRollOver(event:MouseEvent) : void
      {
         this.m_expertAniMc.visible = true;
         this.m_expertAniMc.gotoAndStop(1);
      }
      
      private function onHitExpertMouseRollOut(event:MouseEvent) : void
      {
         this.m_expertAniMc.visible = false;
      }
      
      private function onHitGrandMastertMouseRollOver(event:MouseEvent) : void
      {
         this.m_grandMasterAniMc.visible = true;
         this.m_grandMasterAniMc.play();
      }
      
      private function onHitGrandMastertMouseRollOut(event:MouseEvent) : void
      {
         this.m_grandMasterAniMc.visible = false;
      }
      
      private function onHitMastertMouseRollOver(event:MouseEvent) : void
      {
         this.m_masterAniMc.visible = true;
         this.m_masterAniMc.play();
      }
      
      private function onHitMastertMouseRollOut(event:MouseEvent) : void
      {
         this.m_masterAniMc.visible = false;
      }
      
      private function onHitNoviceMouseRollOver(event:MouseEvent) : void
      {
         this.m_noviceAniMc.visible = true;
         this.m_noviceAniMc.play();
      }
      
      private function onHitNoviceMouseRollOut(event:MouseEvent) : void
      {
         this.m_noviceAniMc.visible = false;
      }
      
      override protected function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         if(tutorialSceneNumber < totalScenes)
         {
            preSwitchChanges(tutorialSceneNumber);
            ++tutorialSceneNumber;
            (m_tutorial.element as MovieClip).gotoAndStop(tutorialSceneNumber);
         }
         else
         {
            hideTutorial();
         }
      }
      
      override protected function showTutorial() : void
      {
         super.showTutorial();
         tutorialButtonText = this.TUTORIAL_BUTTON_TEXT_ARRAY[tutorialSceneNumber - 1];
      }
      
      private function onHowDoesThisWorkClick(event:Event) : void
      {
         this.showTutorial();
      }
      
      protected function showTutorial1() : void
      {
         if(this.m_tutorialMc)
         {
            this.m_tutorialMc.visible = true;
            m_tutorial.visible = true;
         }
         this.preSwitchChanges1(0);
      }
      
      protected function preSwitchChanges1(sceneNumber:int) : void
      {
         var button0:FarmAnimatedTextButton = null;
         var button1:FarmAnimatedTextButton = null;
         var button2:FarmAnimatedTextButton = null;
         switch(sceneNumber)
         {
            case 0:
               button0 = this.m_tutorialButtons[0] as FarmAnimatedTextButton;
               button0.text = "Ok!";
               button0.visible = true;
               button0.enabled = true;
               button0.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(0);
               (m_tutorial.element as MovieClip).gotoAndStop(1);
               break;
            case 1:
               button1 = this.m_tutorialButtons[1] as FarmAnimatedTextButton;
               button1.text = "Ok!";
               button1.visible = true;
               button1.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(1);
               (m_tutorial.element as MovieClip).gotoAndStop(2);
               break;
            case 2:
               button2 = this.m_tutorialButtons[2] as FarmAnimatedTextButton;
               button2.text = "Ok!";
               button2.visible = true;
               button2.callback = this.onTutorialOkayButtonClick1;
               this.hideOtherTutorialButtonsExpect1(2);
               (m_tutorial.element as MovieClip).gotoAndStop(3);
         }
      }
      
      private function hideOtherTutorialButtonsExpect1(buttonNo:int) : void
      {
         for(var i:int = 0; i < this.m_tutorialButtons.length; i++)
         {
            if(i != buttonNo)
            {
               this.m_tutorialButtons[i].visible = false;
            }
         }
      }
      
      protected function onTutorialOkayButtonClick1(event:MouseEvent) : void
      {
         if(tutorialSceneNumber < totalScenes)
         {
            this.preSwitchChanges1(tutorialSceneNumber);
            ++tutorialSceneNumber;
         }
         else if(!Global.player.getSeenFlag(this.HALLOWEEN2019_RW_FTUE_FLAG))
         {
            Global.player.setSeenFlag(this.HALLOWEEN2019_RW_FTUE_FLAG);
            hideTutorial();
            this.close();
         }
         else
         {
            hideTutorial();
         }
      }
   }
}

