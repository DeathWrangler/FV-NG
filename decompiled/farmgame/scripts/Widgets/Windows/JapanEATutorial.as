package Widgets.Windows
{
   import Display.TutorialUI;
   import Display.UI;
   import Events.DynamicObjectEvent;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class JapanEATutorial extends FarmWindowWithTutorial
   {
      
      private var m_tutorialScene:int = 0;
      
      private var m_totalNumScenes:int = 0;
      
      private var m_closeAfterTut:Boolean = false;
      
      private var frameMap:Object = {
         1:"2",
         2:"121",
         3:"276",
         4:"384",
         5:"492",
         6:"553",
         7:"638",
         8:716
      };
      
      private var m_faqTf:FarmAnimatedButton;
      
      private var m_faqLink:String = "https://zyngasupport.helpshift.com/a/farmville/?s=faq-the-story-of-sakura&f=faq-story-of-sakura";
      
      private const FAQ_MC:String = "LearnMore_mc";
      
      public function JapanEATutorial(featureName:String, windowAssetRelUrl:String, totalNumScenes:int = -1, modal:Boolean = true, bAddClickBlocker:Boolean = false, closeAfterTut:Boolean = false, bypassSeenFlag:Boolean = false)
      {
         this.m_totalNumScenes = totalNumScenes;
         this.m_closeAfterTut = closeAfterTut;
         super(featureName,windowAssetRelUrl,totalNumScenes,modal,bAddClickBlocker,closeAfterTut,bypassSeenFlag);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.tutorial_mc.hasOwnProperty(this.FAQ_MC))
         {
            if(this.m_faqLink != "")
            {
               this.m_faqTf = addWidget(new FarmAnimatedButton(m_window.tutorial_mc[this.FAQ_MC],this.onFAQClick)) as FarmAnimatedButton;
               (m_window.tutorial_mc[this.FAQ_MC] as DisplayObject).visible = false;
            }
         }
      }
      
      private function onFAQClick(event:MouseEvent) : void
      {
         if(this.m_faqLink != "")
         {
            navigateToURL(new URLRequest(this.m_faqLink),"_blank");
         }
      }
      
      private function createRightBouncingArrow(xpos:int, ypos:int) : void
      {
         var mat:Matrix = new Matrix(0,1,1,0,xpos,ypos);
         TutorialUI.addBouncingArrowsForStage(mat);
      }
      
      private function createLeftBouncingArrow(xpos:int, ypos:int) : void
      {
         var mat:Matrix = new Matrix(0,-1,-1,0,xpos,ypos);
         TutorialUI.addBouncingArrowsForStage(mat);
      }
      
      override protected function preSwitchChanges(sceneNumber:int) : void
      {
         var xpos:int = 0;
         var ypos:int = 0;
         switch(sceneNumber)
         {
            case 6:
               xpos = (GlobalEngine.stage.stageWidth - UI.DEFAULT_WIDTH) / 2 - 260;
               ypos = Global.stage.stageHeight - 145;
               this.createRightBouncingArrow(xpos,ypos);
               break;
            case 8:
               xpos = (GlobalEngine.stage.stageWidth - UI.DEFAULT_WIDTH) / 2 + 1020;
               ypos = Global.stage.stageHeight - 35;
               this.createLeftBouncingArrow(xpos,ypos);
               (m_window.tutorial_mc[this.FAQ_MC] as DisplayObject).visible = true;
               (m_window.tutorial_mc[this.FAQ_MC] as DisplayObject).alpha = 90;
         }
      }
      
      override protected function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         if(this.m_tutorialScene < this.m_totalNumScenes)
         {
            TutorialUI.removeBouncingArrowsForStage();
            ++this.m_tutorialScene;
            this.preSwitchChanges(this.m_tutorialScene);
            (m_tutorial.element as MovieClip).gotoAndPlay(this.frameMap[this.m_tutorialScene]);
         }
         else
         {
            FarmStatsManager.count(m_tutorialFeatureName,"FTUE","completed");
            hideTutorial();
            Global.world.dispatchEvent(new DynamicObjectEvent(m_tutorialFeatureName));
            if(this.m_closeAfterTut)
            {
               TutorialUI.removeBouncingArrowsForStage();
               close();
            }
         }
      }
   }
}

