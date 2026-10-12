package Widgets.Windows.MOTD
{
   import Widgets.Frames.SubscriptionVipItemsBuyFrame;
   
   public class SubscriptionVipItemsMotdWindow extends GenericSingleButtonWidgetMOTD
   {
      
      private var m_vipItemsBuyFrame:SubscriptionVipItemsBuyFrame;
      
      public function SubscriptionVipItemsMotdWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("mainWindow"))
         {
            this.m_vipItemsBuyFrame = new SubscriptionVipItemsBuyFrame(m_window.mainWindow.buyFrame_mc);
            if(this.m_vipItemsBuyFrame)
            {
               addWidget(this.m_vipItemsBuyFrame,true);
            }
         }
         this.vipItemsSet();
      }
      
      private function vipItemsSet() : void
      {
         var items:Array = Global.farmGameSettingsManager.getActiveVipItems();
         if(Boolean(items) && Boolean(this.m_vipItemsBuyFrame))
         {
            this.m_vipItemsBuyFrame.items = items;
         }
      }
   }
}

