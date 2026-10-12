package Widgets.Windows
{
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.AntiqueMuseumV2Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Frames.AntiqueMuseumV2SurveyMapTilesFrame;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class AntiqueMuseumV2SurveyMapWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 2;
      
      private const TITLE_TF:String = "title_tf";
      
      private var m_tilesFrame:AntiqueMuseumV2SurveyMapTilesFrame;
      
      private var m_featureName:String = null;
      
      private var m_map_mc:MovieClip;
      
      private var m_deposit0_mc:MovieClip;
      
      private var m_giftSlabs:MovieClip;
      
      private var m_giftSlabsList:Array = [];
      
      public function AntiqueMuseumV2SurveyMapWindow(featureName:String, assetPath:String = "")
      {
         this.m_featureName = featureName;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(featureName,assetPath,numOfTutorialPages);
      }
      
      override protected function postLoadComplete() : void
      {
         var i:int = 0;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            m_window[this.TITLE_TF].visible = true;
            m_window[this.TITLE_TF].text = "How to get more part?";
         }
         if(m_window.hasOwnProperty("land_mc"))
         {
            this.m_tilesFrame = new AntiqueMuseumV2SurveyMapTilesFrame(m_window["land_mc"],this,this.m_featureName);
            this.m_tilesFrame.visible = true;
         }
         if(m_window.hasOwnProperty("subtext_tf"))
         {
            m_window["subtext_tf"].visible = true;
            m_window["subtext_tf"].text = "More Land Unlocked = Better chance of finding a part";
         }
         if(m_window.hasOwnProperty("okay_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["okay_bt"],"Okay",this.onCloseConfirmationDialog));
            m_window["okay_bt"].visible = true;
         }
         var numberOfTilesBrought:int = this.manager.getCurrentTileBrought();
         if(m_window.hasOwnProperty("gift_slab_all_mc"))
         {
            this.m_giftSlabs = m_window["gift_slab_all_mc"] as MovieClip;
            this.m_giftSlabs.visible = true;
            for(i = 0; i < 4; i++)
            {
               this.m_giftSlabsList[i] = this.m_giftSlabs["gift_slab_" + i + "_mc"] as MovieClip;
               this.m_giftSlabsList[i].visible = true;
            }
            if(numberOfTilesBrought <= 1)
            {
               this.m_giftSlabsList[0].gotoAndStop(2);
               this.m_giftSlabsList[1].gotoAndStop(1);
               this.m_giftSlabsList[2].gotoAndStop(1);
               this.m_giftSlabsList[3].gotoAndStop(1);
            }
            else if(numberOfTilesBrought <= 3)
            {
               this.m_giftSlabsList[0].gotoAndStop(1);
               this.m_giftSlabsList[1].gotoAndStop(2);
               this.m_giftSlabsList[2].gotoAndStop(1);
               this.m_giftSlabsList[3].gotoAndStop(1);
            }
            else if(numberOfTilesBrought <= 6)
            {
               this.m_giftSlabsList[0].gotoAndStop(1);
               this.m_giftSlabsList[1].gotoAndStop(1);
               this.m_giftSlabsList[2].gotoAndStop(2);
               this.m_giftSlabsList[3].gotoAndStop(1);
            }
            else if(numberOfTilesBrought >= 19)
            {
               this.m_giftSlabsList[0].gotoAndStop(1);
               this.m_giftSlabsList[1].gotoAndStop(1);
               this.m_giftSlabsList[2].gotoAndStop(1);
               this.m_giftSlabsList[3].gotoAndStop(2);
            }
            else
            {
               this.m_giftSlabsList[0].gotoAndStop(1);
               this.m_giftSlabsList[1].gotoAndStop(1);
               this.m_giftSlabsList[2].gotoAndStop(1);
               this.m_giftSlabsList[3].gotoAndStop(1);
            }
         }
      }
      
      private function onCloseConfirmationDialog(e:Event) : void
      {
         StatsManager.count(AntiqueMuseumV2Manager.FEATURE_TRACKING,"dump_map","buy","click");
         UI.displayMiniMarketDialog(this.manager.m_marketTilesItems,null,"seed",null,true,false,false,true);
         this.close();
         this.manager.closeMainWindow(e);
      }
      
      private function get manager() : AntiqueMuseumV2Manager
      {
         return AntiqueMuseumV2Manager.getInstance();
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
   }
}

