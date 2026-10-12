package Classes.Idle
{
   import Display.UI;
   import Events.MarketEvent;
   import GameMode.GMMarketPlant;
   import GameMode.GMObjectMove;
   import Widgets.Windows.Market.MarketWindow;
   
   public class MarketReopenIdleTask extends BaseIdleTask
   {
      
      public function MarketReopenIdleTask()
      {
         super();
      }
      
      override public function get canFire() : Boolean
      {
         return !Global.world.isGameModeActive(GMObjectMove) && !Global.world.isGameModeActive(GMMarketPlant);
      }
      
      override public function fire() : void
      {
         var reopenedMarketWindow:MarketWindow = UI.displayMarketDialogAsLastTime();
         reopenedMarketWindow.addEventListener(MarketEvent.MARKET_SHOWN,this.moveMarketToBottom);
      }
      
      private function moveMarketToBottom(event:MarketEvent) : void
      {
         var reopenedMarketWindow:MarketWindow = event.target as MarketWindow;
         reopenedMarketWindow.removeEventListener(MarketEvent.MARKET_SHOWN,this.moveMarketToBottom);
         reopenedMarketWindow.moveToBottom();
      }
      
      override public function get requireMouseIdle() : Boolean
      {
         return false;
      }
      
      override public function get requireActionQueueIdle() : Boolean
      {
         return false;
      }
      
      override public function get requirePopupQueueEmpty() : Boolean
      {
         return false;
      }
      
      override public function get queueCoolDownMilliseconds() : Number
      {
         return DEFAULT_QUEUE_COOLDOWN_MILLISECONDS;
      }
      
      override public function get singletonClobber() : Boolean
      {
         return true;
      }
   }
}

