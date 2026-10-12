package Widgets.Windows
{
   import Managers.AntiqueMuseumManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Frames.AntiqueMuseumSurveyMapTilesFrame;
   import Widgets.Frames.XMASInnovationGiftFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.utils.Timer;
   
   public class AntiqueMuseumSurveyMapWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 2;
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const BODY2_TF:String = "body2_tf";
      
      private const BACK_MC:String = "back_mc";
      
      private const COUNT1_TF:String = "count1_tf";
      
      private const SLOTS_MC:String = "slots_mc";
      
      private const COLLECTION_MC:Array = ["collection0_mc","collection1_mc","collection2_mc"];
      
      private const ANTIQUE_MUSEUM_SURVEY_FTUE_SEEN:String = "antique_museum_survey_ftue_seen";
      
      private var m_tilesFrame:AntiqueMuseumSurveyMapTilesFrame;
      
      private var m_tutorial_mc:MovieClip;
      
      private var m_tutorial_frame:ZwFrame;
      
      private var m_plots:XMASInnovationGiftFrame;
      
      private var m_featureName:String = null;
      
      private var m_mainWindow:AntiqueMuseumMainWindow;
      
      private var m_timer:Timer;
      
      private var m_confDialog_mc:MovieClip;
      
      private var m_map_mc:MovieClip;
      
      private var m_deposit0_mc:MovieClip;
      
      private var m_deposit1_mc:MovieClip;
      
      private var m_deposit2_mc:MovieClip;
      
      public function AntiqueMuseumSurveyMapWindow(featureName:String, assetPath:String = "")
      {
         this.m_featureName = featureName;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(featureName,assetPath,numOfTutorialPages);
      }
      
      override protected function postLoadComplete() : void
      {
         var m_deposit0MCtooltip:FarmIcon = null;
         var m_deposit1MCtooltip:FarmIcon = null;
         var m_deposit2MCtooltip:FarmIcon = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            m_window[this.TITLE_TF].visible = true;
            m_window[this.TITLE_TF].text = "Survey Map";
         }
         if(m_window.hasOwnProperty(this.BACK_MC))
         {
            m_window[this.BACK_MC].visible = true;
         }
         if(m_window.hasOwnProperty("land_mc"))
         {
            this.m_tilesFrame = new AntiqueMuseumSurveyMapTilesFrame(m_window["land_mc"],this,this.m_featureName);
            this.m_tilesFrame.visible = true;
         }
         if(m_window.hasOwnProperty("subtittle_tf"))
         {
            m_window["subtittle_tf"].visible = true;
            m_window["subtittle_tf"].text = "Increase your chance of finding a part by owning lands with high item concentrations!";
         }
         if(m_window.hasOwnProperty("confirmation_dialog"))
         {
            this.m_confDialog_mc = m_window["confirmation_dialog"] as MovieClip;
            this.m_confDialog_mc.visible = true;
            if(this.m_confDialog_mc.hasOwnProperty("okay_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_confDialog_mc["okay_bt"],"Okay",this.onCloseConfirmationDialog));
               this.m_confDialog_mc["okay_bt"].visible = true;
            }
            if(!Global.player.getSeenFlag(this.ANTIQUE_MUSEUM_SURVEY_FTUE_SEEN))
            {
               this.m_confDialog_mc.visible = false;
               this.m_confDialog_mc["okay_bt"].visible = false;
            }
            else
            {
               this.m_confDialog_mc.visible = true;
               this.m_confDialog_mc["okay_bt"].visible = true;
            }
         }
         if(m_window.hasOwnProperty("tutorial2_mc"))
         {
            this.m_tutorial_mc = m_window["tutorial2_mc"] as MovieClip;
            this.m_tutorial_frame = addWidget(new ZwFrame(this.m_tutorial_mc),false) as ZwFrame;
            if(this.m_tutorial_mc.hasOwnProperty("okay2_bt"))
            {
               this.m_tutorial_frame.addWidget(new FarmAnimatedTextButton(this.m_tutorial_mc["okay2_bt"],"Great!",this.howDoesThisWorkFrameSwitch));
               this.m_tutorial_mc["okay2_bt"].visible = true;
            }
            this.m_tutorial_mc.visible = false;
         }
         if(m_window.hasOwnProperty("map_mc"))
         {
            this.m_map_mc = m_window["map_mc"] as MovieClip;
            this.m_map_mc.visible = true;
            if(this.m_map_mc.hasOwnProperty("light_deposit"))
            {
               this.m_deposit0_mc = this.m_map_mc["light_deposit"] as MovieClip;
               this.m_deposit0_mc.visible = true;
               m_deposit0MCtooltip = new FarmIcon(this.m_deposit0_mc);
               m_deposit0MCtooltip.attachTooltip(new FarmTextTooltip("Unlocking these tiles increase your global drop chance by a small amount"));
            }
            if(this.m_map_mc.hasOwnProperty("medium_deposit"))
            {
               this.m_deposit0_mc = this.m_map_mc["medium_deposit"] as MovieClip;
               this.m_deposit0_mc.visible = true;
               m_deposit1MCtooltip = new FarmIcon(this.m_deposit0_mc);
               m_deposit1MCtooltip.attachTooltip(new FarmTextTooltip("Unlocking these tiles increase your global drop chance by a medium amount"));
            }
            if(this.m_map_mc.hasOwnProperty("heaviest_deposit"))
            {
               this.m_deposit0_mc = this.m_map_mc["heaviest_deposit"] as MovieClip;
               this.m_deposit0_mc.visible = true;
               m_deposit2MCtooltip = new FarmIcon(this.m_deposit0_mc);
               m_deposit2MCtooltip.attachTooltip(new FarmTextTooltip("Unlocking these tiles increase your global drop chance by a large amount"));
            }
         }
         if(!this.manager.isFeatureCompleted())
         {
            if(!Global.player.getSeenFlag(this.ANTIQUE_MUSEUM_SURVEY_FTUE_SEEN))
            {
               Global.player.setSeenFlag(this.ANTIQUE_MUSEUM_SURVEY_FTUE_SEEN);
               this.howDoesThisWorkClick(null);
            }
         }
         this.manager.disSelectAllTiles();
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         if(this.m_tutorial_frame)
         {
            (this.m_tutorial_frame.element as MovieClip).gotoAndStop(1);
            this.m_tutorial_frame.visible = true;
            FarmStatsManager.count(AntiqueMuseumManager.FEATURE_NAME,"FTUE_Survey","START");
         }
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
      
      private function onCloseConfirmationDialog(e:Event) : void
      {
         this.m_confDialog_mc.visible = false;
      }
      
      private function get manager() : AntiqueMuseumManager
      {
         return AntiqueMuseumManager.getInstance(this.m_featureName);
      }
      
      override public function close() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer = null;
         }
         super.close();
      }
   }
}

