package Classes
{
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class AsyncCall
   {
      
      protected const TIMEOUT_MILLI:int = 100;
      
      protected var m_timer:Timer = null;
      
      protected var m_callback:Function = null;
      
      protected var m_param:* = null;
      
      public function AsyncCall(callback:Function, param:* = null, timeout:int = 0)
      {
         super();
         this.m_callback = callback;
         this.m_param = param;
         if(timeout == 0)
         {
            this.m_timer = new Timer(this.TIMEOUT_MILLI,1);
         }
         else
         {
            this.m_timer = new Timer(timeout,1);
         }
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimeout);
         this.m_timer.start();
      }
      
      public static function call(callback:Function, param:* = null, timeout:int = 0) : void
      {
         new AsyncCall(callback,param,timeout);
      }
      
      protected function onTimeout(event:TimerEvent) : void
      {
         this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimeout);
         this.m_timer = null;
         if(this.m_param)
         {
            this.m_callback(this.m_param);
         }
         else
         {
            this.m_callback();
         }
      }
   }
}

