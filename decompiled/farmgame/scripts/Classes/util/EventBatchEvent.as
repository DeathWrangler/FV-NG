package Classes.util
{
   import flash.events.Event;
   
   public class EventBatchEvent extends Event
   {
      
      public static const EVENT_BATCH:String = "eventBatch";
      
      private var m_events:Vector.<Event>;
      
      public function EventBatchEvent(type:String, events:Vector.<Event>, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         this.m_events = events;
         super(type,bubbles,cancelable);
      }
      
      public function get events() : Vector.<Event>
      {
         return this.m_events;
      }
   }
}

