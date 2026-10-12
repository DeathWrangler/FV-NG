package Classes.util
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class EventBatcher extends EventDispatcher
   {
      
      public const DEFAULT_MIN_DELAY:int = 250;
      
      public const DEFAULT_MAX_DELAY:int = 1000;
      
      private var m_target:EventDispatcher;
      
      private var m_eventType:String;
      
      private var m_timer:Timer;
      
      private var m_startTime:int = 0;
      
      private var m_minDelay:int;
      
      private var m_maxDelay:int;
      
      private var m_events:Vector.<Event>;
      
      public function EventBatcher(target:EventDispatcher, eventType:String, minDelay:int = 250, maxDelay:int = 1000)
      {
         super();
         this.m_target = target;
         this.m_eventType = eventType;
         this.m_target.addEventListener(this.m_eventType,this.onEventDispatched);
         this.m_minDelay = minDelay;
         this.m_maxDelay = maxDelay;
         this.m_timer = new Timer(this.m_minDelay,1);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
      }
      
      private function onEventDispatched(event:Event) : void
      {
         if(!this.m_events)
         {
            this.m_events = new Vector.<Event>();
         }
         this.m_events.push(event);
         if(this.m_startTime == 0)
         {
            this.m_startTime = GlobalEngine.serverTime;
         }
         else if(GlobalEngine.serverTime - this.m_startTime < this.m_maxDelay)
         {
            this.m_timer.reset();
         }
         if(!this.m_timer.running)
         {
            this.m_timer.start();
         }
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         dispatchEvent(new EventBatchEvent(EventBatchEvent.EVENT_BATCH,this.m_events));
         this.m_events = null;
         this.m_startTime = 0;
      }
      
      public function get minDelay() : int
      {
         return this.m_minDelay;
      }
      
      public function set minDelay(value:int) : void
      {
         if(value != this.m_minDelay)
         {
            this.m_minDelay = value;
            this.m_timer.delay = value;
         }
      }
      
      public function get maxDelay() : int
      {
         return this.m_maxDelay;
      }
      
      public function set maxDelay(value:int) : void
      {
         this.m_maxDelay = value;
      }
      
      public function release() : void
      {
         this.m_target.removeEventListener(this.m_eventType,this.onEventDispatched);
         this.m_target = null;
         this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer = null;
      }
   }
}

