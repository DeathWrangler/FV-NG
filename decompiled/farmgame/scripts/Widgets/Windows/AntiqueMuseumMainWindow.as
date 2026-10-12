package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.AntiqueMuseumManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.AntiqueMuseumPiecesFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class AntiqueMuseumMainWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 4;
      
      private static const FEATURE_TRACKING:String = "landbundle";
      
      private static const FEATURE_NAME:String = "AntiqueMuseum";
      
      private static const BONUS_REWARD_NAME:String = "Pack of Farm Essentials";
      
      private static var m_tutorialButtons:Array = [];
      
      private var m_featureName:String = null;
      
      private var m_showTutorialWithEAPage:Boolean = false;
      
      private const ANTIQUE_MUSEUM_FTUE_SEEN:String = "antique_museum_ftue_seen";
      
      private const PROGRESS_BAR_MC:String = "smprogressbar_mc";
      
      private const BAR_FILL_MC:String = "bar_fill_mc";
      
      public var m_piecesFrame:AntiqueMuseumPiecesFrame;
      
      private var m_daysLeftMC:MovieClip;
      
      private var m_goHarvest_bt:FarmAnimatedTextButton;
      
      private var m_timer:Timer;
      
      private var m_tutorial_mc:MovieClip;
      
      private var m_surveyMap_mc:MovieClip;
      
      private var m_collection_mc:MovieClip;
      
      private var m_tutorial_frame:ZwFrame;
      
      private var m_barFillMc:MovieClip;
      
      private var m_progressbar_Mc:MovieClip;
      
      private var m_tutorial_next_button:FarmAnimatedTextButton;
      
      public function AntiqueMuseumMainWindow(featureName:String = "AntiqueMuseum", assetUrl:String = null, showEAPageTutorial:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_showTutorialWithEAPage = showEAPageTutorial;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(FEATURE_NAME,assetUrl,numOfTutorialPages);
      }
      
      override protected function postLoadComplete() : void
      {
         var m_surveyMctooltip:FarmIcon = null;
         this.visible = true;
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],"ANTIQUE MUSEUM!"));
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(new ZwTextField(m_window["body_tf"],"Harvest crops with grow time 4hr or more to have a chance of finding a part.\n" + "Longer crops have a better chance of finding a item!"));
         }
         if(m_window.hasOwnProperty("slots_mc"))
         {
            this.m_piecesFrame = new AntiqueMuseumPiecesFrame(m_window["slots_mc"],this,FEATURE_NAME);
            this.m_piecesFrame.setData();
            this.m_piecesFrame.visible = true;
         }
         if(m_window.hasOwnProperty("surveymap"))
         {
            this.m_surveyMap_mc = m_window["surveymap"] as MovieClip;
            this.m_surveyMap_mc.visible = true;
            if(this.m_surveyMap_mc.hasOwnProperty("surveymap_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_surveyMap_mc["surveymap_bt"],"Survey",this.showSurveyMapWindow));
               m_surveyMctooltip = new FarmIcon(this.m_surveyMap_mc);
               m_surveyMctooltip.attachTooltip(new FarmTextTooltip("The bar shows your current drop chance. Use the Survey report to know which tiles to unlock to increase your drop chance."));
               this.m_surveyMap_mc["surveymap_bt"].visible = true;
            }
            if(this.m_surveyMap_mc.hasOwnProperty(this.PROGRESS_BAR_MC))
            {
               this.m_progressbar_Mc = this.m_surveyMap_mc[this.PROGRESS_BAR_MC] as MovieClip;
               this.m_progressbar_Mc.visible = true;
               if(this.m_progressbar_Mc.hasOwnProperty(this.BAR_FILL_MC))
               {
                  this.m_barFillMc = this.m_progressbar_Mc[this.BAR_FILL_MC] as MovieClip;
                  this.m_barFillMc.visible = true;
               }
            }
         }
         if(m_window.hasOwnProperty("antiquecollection"))
         {
            this.m_collection_mc = m_window["antiquecollection"] as MovieClip;
            this.m_collection_mc.visible = true;
            if(this.m_collection_mc.hasOwnProperty("antiquecollection_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_collection_mc["antiquecollection_bt"],"View",this.manager.showCollectionUI));
               this.m_collection_mc["antiquecollection_bt"].visible = true;
            }
         }
         if(m_window.hasOwnProperty("daily_clock_mc"))
         {
            this.m_daysLeftMC = m_window["daily_clock_mc"] as MovieClip;
            this.m_daysLeftMC.visible = true;
            if(this.m_daysLeftMC.hasOwnProperty("days_tf"))
            {
               addWidget(new ZwTextField(this.m_daysLeftMC["days_tf"],""));
               this.m_daysLeftMC["days_tf"].visible = true;
            }
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
         this.updateSurveyMapProgressBar();
         this.startTimer();
         if(!Global.player.getSeenFlag(this.ANTIQUE_MUSEUM_FTUE_SEEN))
         {
            Global.player.setSeenFlag(this.ANTIQUE_MUSEUM_FTUE_SEEN);
            this.howDoesThisWorkClick(null);
         }
      }
      
      private function get manager() : AntiqueMuseumManager
      {
         return AntiqueMuseumManager.getInstance(FEATURE_NAME);
      }
      
      public function refreshPiecesFrame() : void
      {
         this.updateSurveyMapProgressBar();
         this.m_piecesFrame.refresh();
      }
      
      public function refreshPlantButtonVisibility() : *
      {
         if(this.manager.isFeatureCompleted())
         {
            if(Boolean(this.m_piecesFrame) && Boolean(this.m_piecesFrame.m_PlantBt))
            {
               this.m_piecesFrame.m_PlantBt.visible = false;
            }
         }
      }
      
      public function showCollectionWindow(e:Event) : void
      {
         UI.displayPopup(new AntiqueMuseumCollectionWindow(FEATURE_NAME,"assets/dialogs/AntiqueMuseum/FV_collections_AntiqueMuseum.swf"),false);
      }
      
      public function showSurveyMapWindow(e:Event) : void
      {
         UI.displayPopup(new AntiqueMuseumSurveyMapWindow(FEATURE_NAME,"assets/dialogs/AntiqueMuseum/FV_SurveyMap_AntiqueMuseum.swf"),false);
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
      
      public function updateSurveyMapProgressBar(onOpenWindow:Boolean = false) : void
      {
         var weight:int = this.manager.getCurrentTileWeight();
         var barLength:Number = weight * 147 / 100;
         if(this.m_barFillMc)
         {
            TweenMax.to(this.m_barFillMc,2,{"width":barLength});
         }
      }
      
      override protected function showTutorial() : void
      {
         super.showTutorial();
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
      }
      
      public function getPiecesFrame() : AntiqueMuseumPiecesFrame
      {
         return this.m_piecesFrame;
      }
      
      public function isFirstTimeTutorial() : Boolean
      {
         return m_tutorialFirstTime;
      }
      
      override public function close() : void
      {
         super.close();
         FarmStatsManager.count("AntiqueMuseum","Main_UI","close_window");
      }
   }
}

