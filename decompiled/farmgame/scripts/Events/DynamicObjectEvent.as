package Events
{
   import flash.events.Event;
   
   public class DynamicObjectEvent extends Event
   {
      
      private var m_data:Object;
      
      public function DynamicObjectEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
         this.m_data = data;
      }
      
      public function get data() : Object
      {
         return this.m_data;
      }
   }
}

