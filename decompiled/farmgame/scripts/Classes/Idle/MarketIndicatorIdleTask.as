package Classes.Idle
{
   import Classes.MarketIndicatorConfig;
   import Display.MOTD;
   import Widgets.Windows.Market.MarketWindow;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class MarketIndicatorIdleTask extends BaseIdleTask
   {
      
      private static var m_expireTimer:Timer = null;
      
      private const IDLE_DELAY:Number = 60000;
      
      private const EXPIRE_TIME:Number = 30000;
      
      public function MarketIndicatorIdleTask()
      {
         super();
      }
      
      private static function onTimerComplete(event:TimerEvent) : void
      {
         m_expireTimer.stop();
         m_expireTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,onTimerComplete);
         m_expireTimer = null;
         Global.ui.getActionMenu().removeMarketIndicatorArrow();
      }
      
      override public function get minActionIdleMilliseconds() : Number
      {
         return this.IDLE_DELAY;
      }
      
      override public function get requireMouseIdle() : Boolean
      {
         return false;
      }
      
      override public function fire() : void
      {
         var hasActiveArrow:Boolean = MarketIndicatorConfig.getInstance().isActive();
         var seenMotd:Boolean = Global.player.getSeenSessionFlag(MOTD.SEEN_MOTD_SESSION_FLAG);
         var hasOpenedMarket:Boolean = Global.player.getSeenSessionFlag(MarketWindow.SEEN_MARKET_SESSION_FLAG);
         if(hasActiveArrow && !seenMotd && !hasOpenedMarket && !Global.player.isNewPlayer)
         {
            Global.ui.getActionMenu().showMarketIndicatorArrow();
            m_expireTimer = new Timer(this.EXPIRE_TIME,1);
            m_expireTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimerComplete);
            m_expireTimer.start();
         }
      }
   }
}

