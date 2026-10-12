package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.BoatRushManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class BoatRushRewardWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 4;
      
      private static const FEATURE_TRACKING:String = "boatrush";
      
      private static const FEATURE_NAME:String = "BoatRush2020";
      
      private var m_featureName:String = null;
      
      private var m_showTutorialWithEAPage:Boolean = false;
      
      private const LAND_BUNDLE_UNLOCK_FEATURE_FTUE_SEEN:String = "land_bundle_unlock_feature_ftue_seen";
      
      private var m_milestonesArray:Array = [];
      
      private var m_hitAreasArray:Array = [];
      
      private var m_daysLeftMC:MovieClip;
      
      private var m_tutorial_mc:MovieClip;
      
      private var m_tutorial_frame:ZwFrame;
      
      public function BoatRushRewardWindow(featureName:String = "BoatRush2020", assetUrl:String = null, showEAPageTutorial:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_showTutorialWithEAPage = showEAPageTutorial;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(FEATURE_NAME,assetUrl,numOfTutorialPages);
      }
      
      override protected function postLoadComplete() : void
      {
         var hitAreaName:String = null;
         var consumableName:String = null;
         this.visible = true;
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],"BONUS REWARDS"));
         }
         if(m_window.hasOwnProperty("subtext_tf"))
         {
            addWidget(new ZwTextField(m_window["subtext_tf"],"Collect more Crates to win the best reward!"));
         }
         if(m_window.hasOwnProperty("howDoesThisWork_mc"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["howDoesThisWork_mc"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"HowDoesThisWork"),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty("tutorial_mc"))
         {
            this.m_tutorial_mc = m_window["tutorial_mc"] as MovieClip;
            this.m_tutorial_frame = addWidget(new ZwFrame(this.m_tutorial_mc),false) as ZwFrame;
            if(this.m_tutorial_mc.hasOwnProperty("okay_bt"))
            {
               this.m_tutorial_frame.addWidget(new FarmAnimatedTextButton(this.m_tutorial_mc["okay_bt"],"Great!",this.howDoesThisWorkFrameSwitch));
               this.m_tutorial_mc["okay_bt"].visible = true;
            }
            this.m_tutorial_mc.visible = false;
         }
         for(var index:int = 1; index <= 4; index++)
         {
            hitAreaName = "hitArea" + index.toString() + "_mc";
            consumableName = "consumable_" + index.toString() + "_ani";
            if(m_window.hasOwnProperty(consumableName))
            {
               this.m_milestonesArray[index] = m_window[consumableName] as MovieClip;
               this.m_milestonesArray[index].visible = false;
            }
            if(m_window.hasOwnProperty(hitAreaName))
            {
               this.m_hitAreasArray[index] = m_window[hitAreaName] as MovieClip;
               this.m_hitAreasArray[index].visible = true;
               this.m_hitAreasArray[index].addEventListener(MouseEvent.MOUSE_OVER,this.onOver(index));
               this.m_hitAreasArray[index].addEventListener(MouseEvent.MOUSE_OUT,this.onOut(index));
            }
         }
      }
      
      private function get manager() : BoatRushManager
      {
         return BoatRushManager.getInstance(FEATURE_NAME);
      }
      
      private function howDoesThisWorkFrameSwitch(event:Event = null) : void
      {
         var totalFrames:int = int(this.m_tutorial_frame.element.totalFrames);
         var currentFrame:int = int(this.m_tutorial_frame.element.currentFrame);
         if(currentFrame + 1 <= totalFrames)
         {
            (this.m_tutorial_frame.element as MovieClip).gotoAndStop(currentFrame + 1);
         }
         else
         {
            this.m_tutorial_frame.visible = false;
         }
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         if(this.m_tutorial_frame)
         {
            (this.m_tutorial_frame.element as MovieClip).gotoAndStop(1);
            this.m_tutorial_frame.visible = true;
            FarmStatsManager.count(FEATURE_TRACKING,"FTUE","START");
         }
      }
      
      override protected function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         if(tutorialSceneNumber < totalScenes && Boolean(this.m_tutorial_frame))
         {
            ++tutorialSceneNumber;
            preSwitchChanges(tutorialSceneNumber);
            (this.m_tutorial_frame.element as MovieClip).gotoAndStop(tutorialSceneNumber);
         }
         else
         {
            this.m_tutorial_mc.visible = false;
         }
      }
      
      override protected function showTutorial() : void
      {
         super.showTutorial();
      }
      
      private function onOver(index:int) : Function
      {
         return function(evt:MouseEvent):*
         {
            if(m_milestonesArray.hasOwnProperty(index.toString()))
            {
               m_milestonesArray[index].visible = true;
               m_milestonesArray[index].play();
            }
         };
      }
      
      private function onOut(index:int) : Function
      {
         return function(evt:MouseEvent):*
         {
            if(m_milestonesArray.hasOwnProperty(index.toString()))
            {
               m_milestonesArray[index].visible = false;
               m_milestonesArray[index].stop();
            }
         };
      }
      
      override public function close() : void
      {
         super.close();
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.untintWindow();
         }
         FarmStatsManager.count("boatrush","Main_UI","close_window");
      }
   }
}

