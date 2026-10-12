package Widgets.Windows
{
   import Widgets.Buttons.FarmButton;
   import flash.events.Event;
   
   public class WorldMarketSaleOverlayWindow extends FarmWindow
   {
      
      private var m_worldName:String;
      
      public function WorldMarketSaleOverlayWindow(assetPath:String, worldName:String)
      {
         super(assetPath);
         this.m_worldName = worldName;
      }
      
      private function onTravel(event:Event) : void
      {
         Global.worldManager.swapFarm(this.m_worldName,true);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.generic_bt)
         {
            addWidget(new FarmButton(m_window.generic_bt,this.onTravel));
         }
      }
   }
}

