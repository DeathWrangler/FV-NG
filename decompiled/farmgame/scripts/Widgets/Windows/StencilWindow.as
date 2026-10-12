package Widgets.Windows
{
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Events.DynamicObjectEvent;
   import Managers.StencilManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Frames.Stencil.StencilFrame;
   import Widgets.Frames.Stencil.StencilLookbookFrame;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class StencilWindow extends FarmWindowWithTutorial
   {
      
      private var TUTORIAL_SCENES_FRAMES_COUNT:int = 5;
      
      private var m_lookbookFrame:StencilLookbookFrame;
      
      private var m_stencilsFrame:StencilFrame;
      
      private var m_AutoPopFTUE:Boolean = true;
      
      public function StencilWindow(featureName:String, assetURL:String)
      {
         super(featureName,assetURL,this.TUTORIAL_SCENES_FRAMES_COUNT,true,true);
      }
      
      protected function get manager() : StencilManager
      {
         return StencilManager.instance();
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new FarmAnimatedButton(m_window.whatisthis_mc,this.onShowTutorial));
         addWidget(new FarmTextField(m_window.title_tf,this.manager.getString("window_title")));
         addWidget(new FarmAnimatedButton(m_window.video_mc,this.manager.playTutorialVideo));
         addWidget(this.m_lookbookFrame = new StencilLookbookFrame(m_window.lookbook_mc));
         addWidget(this.m_stencilsFrame = new StencilFrame(m_window.stencils_mc));
      }
      
      override protected function release() : void
      {
         super.release();
         this.manager.mainWindow = null;
         this.m_lookbookFrame = null;
         this.m_stencilsFrame = null;
      }
      
      override protected function showTutorial() : void
      {
         var element:MovieClip = null;
         var i:int = 0;
         var child:MovieClip = null;
         tutorialSceneNumber = 1;
         if(m_tutorial != null)
         {
            element = m_tutorial.element as MovieClip;
            element.gotoAndStop(1);
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
         if(this.m_AutoPopFTUE)
         {
            StatsManager.count(this.manager.featureName,"FTUE","started","autopop");
         }
         else
         {
            StatsManager.count(this.manager.featureName,"FTUE","started","click");
         }
      }
      
      override protected function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         if(tutorialSceneNumber < totalScenes)
         {
            preSwitchChanges(tutorialSceneNumber);
            tutorialSceneNumber += 1;
            (m_tutorial.element as MovieClip).play();
         }
         else
         {
            if(this.m_AutoPopFTUE)
            {
               StatsManager.count(this.manager.featureName,"FTUE","completed","autopop");
            }
            else
            {
               StatsManager.count(this.manager.featureName,"FTUE","completed","click");
            }
            hideTutorial();
            Global.world.dispatchEvent(new DynamicObjectEvent(m_tutorialFeatureName));
            if(closeAfterTutorial)
            {
               close();
               UI.stopPopups(false);
            }
         }
      }
      
      private function onShowTutorial(e:Event) : void
      {
         this.m_AutoPopFTUE = false;
         this.showTutorial();
      }
   }
}

