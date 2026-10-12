package Init
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   
   public class CompleteMonitor extends EventDispatcher
   {
      
      protected var dispatcherCount:int;
      
      protected var numCompleted:int;
      
      public function CompleteMonitor()
      {
         super();
         this.dispatcherCount = this.numCompleted = 0;
      }
      
      public function addDispatcher(ev:IEventDispatcher) : void
      {
         this.dispatcherCount += 1;
         ev.addEventListener(Event.COMPLETE,this.onComplete);
      }
      
      protected function onComplete(ev:Event) : void
      {
         ev.currentTarget.removeEventListener(Event.COMPLETE,this.onComplete);
         this.numCompleted += 1;
         if(this.numCompleted == this.dispatcherCount)
         {
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      public function getDispatcherCount() : int
      {
         return this.dispatcherCount;
      }
   }
}

