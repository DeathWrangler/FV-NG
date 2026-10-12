package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.WinterRacingFeatureManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class WinterRacingFeatureTilesWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 4;
      
      private static const FEATURE_NAME:String = "GiftRush2019";
      
      private static const FEATURE_TRACKING:String = "giftrush";
      
      private var m_featureName:String = null;
      
      private var m_tutorial_mc:MovieClip;
      
      private var m_tutorial_frame:ZwFrame;
      
      private var m_showTutorialWithEAPage:Boolean = false;
      
      private var m_giftSlabAllMc:MovieClip;
      
      private var m_tilesSlab:Array = [];
      
      private var m_okayBt:FarmAnimatedTextButton;
      
      public function WinterRacingFeatureTilesWindow(featureName:String = "GiftRush2019", assetUrl:String = null, showEAPageTutorial:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_showTutorialWithEAPage = showEAPageTutorial;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(FEATURE_NAME,assetUrl,numOfTutorialPages);
      }
      
      private static function get manager() : WinterRacingFeatureManager
      {
         return WinterRacingFeatureManager.getInstance(FEATURE_NAME);
      }
      
      override protected function postLoadComplete() : void
      {
         var tileIndex:int = 0;
         var index:int = 0;
         this.visible = true;
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],"GIFT SPEED"));
         }
         if(m_window.hasOwnProperty("subtext_tf"))
         {
            addWidget(new ZwTextField(m_window["subtext_tf"],"More Land = More Gifts"));
         }
         if(m_window.hasOwnProperty("howDoesThisWork_mc"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["howDoesThisWork_mc"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"HowDoesThisWork"),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty("gift_slab_all_mc"))
         {
            this.m_giftSlabAllMc = m_window["gift_slab_all_mc"] as MovieClip;
            this.m_giftSlabAllMc.visible = true;
            tileIndex = manager.getTilesIndex();
            for(index = 0; index < 5; index++)
            {
               this.m_tilesSlab[index] = this.m_giftSlabAllMc["gift_slab_" + index.toString() + "_mc"] as MovieClip;
               this.m_tilesSlab[index].visible = true;
               if(tileIndex == index)
               {
                  this.m_tilesSlab[index].gotoAndStop(2);
               }
               else
               {
                  this.m_tilesSlab[index].gotoAndStop(1);
               }
            }
         }
         if(m_window.hasOwnProperty("okay_bt"))
         {
            addWidget(this.m_okayBt = new FarmAnimatedTextButton(m_window["okay_bt"],"Let\'s Go!",this.openTilesMarket));
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
      
      private function openTilesMarket(e:Event) : void
      {
         this.close();
         manager.showBoostUI();
         FarmStatsManager.count(FEATURE_TRACKING,"land_purchase","window","buy");
      }
      
      override public function close() : void
      {
         if(manager.mainWindow)
         {
            manager.mainWindow.untintWindow();
            manager.mainWindow.enableInput = true;
         }
         super.close();
      }
   }
}

