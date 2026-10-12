package Classes.MOTD
{
   import Display.UI;
   import Managers.DecoPointsManager;
   import Widgets.Windows.DecoPoints.DecoPointsTopPhotosTab;
   import Widgets.Windows.MOTD.TopPhotosMOTDWindow;
   import flash.events.Event;
   
   public class TopPhotosMOTDHandler extends FeatureFrequencyMOTDHandler
   {
      
      private static const TOP_PHOTOS_MOTD:String = "TopPhotosMOTD";
      
      private var m_manager:DecoPointsManager = null;
      
      private var m_assetPath:String = null;
      
      private var m_hasRequestedData:Boolean = false;
      
      private var m_hasLoadedData:Boolean = false;
      
      private var m_topPhotoData:Array = null;
      
      private var m_topPhotosWindow:TopPhotosMOTDWindow = null;
      
      public function TopPhotosMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
         this.m_manager = DecoPointsManager.instance;
         if(currentMOTD.hasOwnProperty(MOTD_DIALOG) && currentMOTD[MOTD_DIALOG] != null)
         {
            this.m_assetPath = currentMOTD[MOTD_DIALOG];
         }
      }
      
      override public function execute() : void
      {
         var topPhotoData:Array = null;
         super.execute();
         if(this.m_manager.isInitialized() || this.m_hasLoadedData)
         {
            if(this.m_manager.getTopPhotos() != null && this.m_manager.getTopPhotos().length > 0 || this.m_topPhotoData != null && this.m_topPhotoData.length > 0)
            {
               topPhotoData = this.m_topPhotoData != null && this.m_topPhotoData.length > 0 ? this.m_topPhotoData : this.m_manager.getTopPhotos();
               this.m_topPhotosWindow = new TopPhotosMOTDWindow(this.m_assetPath,topPhotoData);
               this.m_topPhotosWindow.addEventListener(Event.CLOSE,this.onCloseMOTD);
               this.m_topPhotosWindow.addEventListener(DecoPointsTopPhotosTab.EVENT_MINI_MARKET_BUTTON_CLICKED,this.onClickMiniMarketButton);
               UI.displayPopup(this.m_topPhotosWindow,true,TOP_PHOTOS_MOTD,true);
            }
         }
         else if(!this.m_manager.hasStartedInit() && !this.m_hasRequestedData)
         {
            if(DecoPointsManager.requestContestDataWithCallback(this.onContestDataLoaded,false))
            {
               this.m_hasRequestedData = true;
            }
         }
         m_isFinished = true;
      }
      
      private function onContestDataLoaded(contestData:Object) : void
      {
         var parsedContestData:Object = DecoPointsManager.parsePhotoContestData(contestData);
         if(parsedContestData.hasOwnProperty("topPhotos") && parsedContestData["topPhotos"] != null)
         {
            this.m_topPhotoData = parsedContestData["topPhotos"];
         }
         this.m_hasLoadedData = true;
         this.execute();
      }
      
      private function onClickMiniMarketButton(event:Event) : void
      {
         acceptMOTD();
      }
      
      private function onCloseMOTD(event:Event) : void
      {
         this.closeMOTD();
      }
      
      override protected function closeMOTD() : void
      {
         this.m_topPhotosWindow.removeEventListener(Event.CLOSE,this.onCloseMOTD);
         this.m_topPhotosWindow.removeEventListener(DecoPointsTopPhotosTab.EVENT_MINI_MARKET_BUTTON_CLICKED,this.onClickMiniMarketButton);
         super.closeMOTD();
      }
   }
}

