package Widgets.Windows.MOTD
{
   import Events.MarketEvent;
   import Managers.DecoPointsManager;
   import Widgets.Windows.DecoPoints.DecoPointsTopPhotosTab;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class TopPhotosMOTDWindow extends FarmWindow
   {
      
      private var m_topPhotosData:Array = null;
      
      private var m_topPhotosTab:DecoPointsTopPhotosTab = null;
      
      public function TopPhotosMOTDWindow(assetURL:String, topPhotosData:Array)
      {
         super(assetURL);
         this.m_topPhotosData = topPhotosData;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.m_topPhotosTab = addWidget(new DecoPointsTopPhotosTab(m_window,DecoPointsManager.instance,true),true) as DecoPointsTopPhotosTab;
         this.m_topPhotosTab.addEventListener(DecoPointsTopPhotosTab.EVENT_MINI_MARKET_BUTTON_CLICKED,this.onMiniMarketButtonClicked);
         this.m_topPhotosTab.addEventListener(MarketEvent.MARKET_BUY,this.closeWindowOnMiniMarketPurchase);
         this.m_topPhotosTab.populate(this.m_topPhotosData);
      }
      
      private function closeWindowOnMiniMarketPurchase(event:Event) : void
      {
         close();
      }
      
      private function onMiniMarketButtonClicked(event:Event) : void
      {
         dispatchEvent(new Event(DecoPointsTopPhotosTab.EVENT_MINI_MARKET_BUTTON_CLICKED));
      }
      
      override protected function release() : void
      {
         this.m_topPhotosTab.removeEventListener(MarketEvent.MARKET_BUY,this.closeWindowOnMiniMarketPurchase);
         this.m_topPhotosTab.removeEventListener(DecoPointsTopPhotosTab.EVENT_MINI_MARKET_BUTTON_CLICKED,this.onMiniMarketButtonClicked);
         super.release();
      }
   }
}

