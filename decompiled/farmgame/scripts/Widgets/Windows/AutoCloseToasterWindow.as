package Widgets.Windows
{
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class AutoCloseToasterWindow extends ToasterWindow
   {
      
      protected static const POPUP_NAME:String = "autoCloseToaster";
      
      protected static const DEFAULT_TIME_TO_LIVE:Number = 5000;
      
      protected var m_timeToLive:Number = 5000;
      
      protected var m_timer:Timer = null;
      
      public function AutoCloseToasterWindow(windowAssetPath:String, timeToLive:Number = 0)
      {
         if(timeToLive > 0)
         {
            this.m_timeToLive = timeToLive;
         }
         super(windowAssetPath);
         this.name = POPUP_NAME;
      }
      
      override protected function release() : void
      {
         if(this.m_timer != null)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
         super.release();
      }
      
      override protected function hideTween(callback:Function) : void
      {
         if(Boolean(m_window) && Boolean(this.m_timer))
         {
            this.m_timer.stop();
         }
         super.hideTween(callback);
      }
      
      override protected function showTweenComplete() : void
      {
         if(m_window)
         {
            this.m_timer.start();
         }
         super.showTweenComplete();
      }
      
      private function startHideTimer() : void
      {
         this.m_timer = new Timer(this.m_timeToLive);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
      }
      
      override public function show() : void
      {
         this.startHideTimer();
         super.show();
      }
      
      protected function resetCloseTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.reset();
            this.m_timer.start();
         }
      }
      
      protected function onTimer(event:TimerEvent) : void
      {
         close();
      }
      
      public function set duration(time:Number) : void
      {
         if(time > 0)
         {
            this.m_timeToLive = time;
         }
      }
   }
}

