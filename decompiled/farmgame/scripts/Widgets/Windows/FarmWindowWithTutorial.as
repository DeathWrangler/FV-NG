package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Events.DynamicObjectEvent;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class FarmWindowWithTutorial extends FarmWindow
   {
      
      protected var m_tutorialFeatureName:String = null;
      
      private var m_tutorialButton:FarmAnimatedTextButton;
      
      protected var m_tutorial:ZwFrame = null;
      
      private var m_tutorialScene:int = 0;
      
      private var m_totalNumScenes:int = 0;
      
      protected var m_tutorialFirstTime:Boolean = false;
      
      private var m_closeAfterTut:Boolean = false;
      
      private var m_bypassSeenFlag:Boolean = false;
      
      public function FarmWindowWithTutorial(featureName:String, windowAssetRelUrl:String, totalNumScenes:int = -1, modal:Boolean = true, bAddClickBlocker:Boolean = false, closeAfterTut:Boolean = false, bypassSeenFlag:Boolean = false)
      {
         this.m_tutorialFeatureName = featureName;
         this.m_totalNumScenes = totalNumScenes;
         this.m_closeAfterTut = closeAfterTut;
         this.m_bypassSeenFlag = bypassSeenFlag;
         super(windowAssetRelUrl,modal,bAddClickBlocker);
      }
      
      override protected function release() : void
      {
         this.m_tutorialButton = null;
         super.release();
      }
      
      override protected function postLoadComplete() : void
      {
         var tutorialSeenFlag:String = null;
         if(m_window.tutorial_mc)
         {
            this.m_tutorial = addWidget(new ZwFrame(m_window.tutorial_mc),false) as ZwFrame;
            if(this.m_totalNumScenes == -1)
            {
               this.m_totalNumScenes = this.m_tutorial.element.totalFrames;
            }
            if(m_window.tutorial_mc.okay_bt)
            {
               this.m_tutorial.addWidget(this.m_tutorialButton = new FarmAnimatedTextButton(m_window.tutorial_mc.okay_bt,ZLocUtils.t("Dialogs","Okay"),this.onTutorialOkayButtonClick)) as FarmAnimatedTextButton;
            }
            if(this.m_tutorialFeatureName)
            {
               tutorialSeenFlag = this.m_tutorialFeatureName + "_Tutorial";
               if(!Global.player.getSeenFlag(tutorialSeenFlag))
               {
                  Global.player.setSeenFlag(tutorialSeenFlag);
                  this.m_tutorialFirstTime = true;
                  this.showTutorial();
               }
               else if(this.m_bypassSeenFlag)
               {
                  this.showTutorial();
               }
               else
               {
                  this.hideTutorial();
               }
            }
         }
      }
      
      protected function preSwitchChanges(sceneNumber:int) : void
      {
      }
      
      protected function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         if(this.m_tutorialScene < this.m_totalNumScenes)
         {
            this.preSwitchChanges(this.m_tutorialScene);
            ++this.m_tutorialScene;
            (this.m_tutorial.element as MovieClip).play();
         }
         else
         {
            if(this.hasSeenTutorial)
            {
               FarmStatsManager.count(this.m_tutorialFeatureName,"FTUE","completed","click");
            }
            else
            {
               FarmStatsManager.count(this.m_tutorialFeatureName,"FTUE","completed","autopop");
            }
            this.hideTutorial();
            Global.world.dispatchEvent(new DynamicObjectEvent(this.m_tutorialFeatureName));
            if(this.m_closeAfterTut)
            {
               close();
               UI.stopPopups(false);
            }
         }
      }
      
      protected function showTutorial() : void
      {
         var element:MovieClip = null;
         var i:int = 0;
         var child:MovieClip = null;
         this.m_tutorialScene = 1;
         if(this.m_tutorial != null)
         {
            element = this.m_tutorial.element as MovieClip;
            element.gotoAndStop(1);
            for(i = 0; i < element.numChildren; i++)
            {
               child = element.getChildAt(i) as MovieClip;
               if(Boolean(child) && child != m_window.tutorial_mc.okay_bt)
               {
                  child.gotoAndPlay(1);
               }
            }
            this.m_tutorial.visible = true;
            if(this.hasSeenTutorial)
            {
               FarmStatsManager.count(this.m_tutorialFeatureName,"FTUE","started","click");
            }
            else
            {
               FarmStatsManager.count(this.m_tutorialFeatureName,"FTUE","started","autopop");
            }
         }
      }
      
      protected function hideTutorial() : void
      {
         (this.m_tutorial.element as MovieClip).stop();
         this.m_tutorial.visible = false;
      }
      
      protected function set tutorialButtonText(text:String) : void
      {
         if(this.m_tutorialButton != null)
         {
            this.m_tutorialButton.text = text;
         }
      }
      
      protected function get tutorialSceneNumber() : int
      {
         return this.m_tutorialScene;
      }
      
      protected function get totalScenes() : int
      {
         return this.m_totalNumScenes;
      }
      
      protected function set totalScenes(scenes:int) : void
      {
         this.m_totalNumScenes = scenes;
      }
      
      protected function set tutorialSceneNumber(value:int) : void
      {
         this.m_tutorialScene = value;
      }
      
      protected function get closeAfterTutorial() : Boolean
      {
         return this.m_closeAfterTut;
      }
      
      protected function get hasSeenTutorial() : Boolean
      {
         var tutorialSeenFlag:String = this.m_tutorialFeatureName + "_Tutorial";
         return Global.player.getSeenFlag(tutorialSeenFlag);
      }
   }
}

