package Classes.MOTD
{
   import Display.UI;
   import Managers.MarketFlashSaleManager;
   import Widgets.Windows.MarketFlashSaleWindow;
   import flash.events.Event;
   
   public class MarketFlashSaleMOTDHandler extends MOTDHandler
   {
      
      public function MarketFlashSaleMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override public function execute() : void
      {
         super.execute();
         if(MarketFlashSaleManager.instance.isSaleActive())
         {
            UI.displayPopup(new MarketFlashSaleWindow());
         }
         else
         {
            ztrack("failed_sale_over");
         }
         this.closeMOTD();
      }
      
      override protected function closeMOTD() : void
      {
         dispatchEvent(new Event(Event.COMPLETE));
         removeAllEventListeners();
      }
   }
}

