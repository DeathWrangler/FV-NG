package Engine.Events
{
   import flash.events.Event;
   
   public class LoaderEvent extends Event
   {
      
      public static const LOAD_QUEUE_EMPTY:String = "loadqueueempty";
      
      public static const LOADED:String = "loaded";
      
      public static const ALL_HIGH_PRIORITY_LOADED:String = "high_priority_loaded";
      
      public static const WORLD_LOAD_STARTED:String = "world_load_started";
      
      private var m_eventData:Object = null;
      
      public function LoaderEvent(param1:String)
      {
         super(param1);
      }
      
      public function get eventData() : Object
      {
         return this.m_eventData;
      }
      
      public function set eventData(param1:Object) : void
      {
         this.m_eventData = param1;
      }
   }
}

