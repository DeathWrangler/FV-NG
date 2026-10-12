package Events
{
   import flash.events.Event;
   
   public class CloseEvent extends Event
   {
      
      public static const CLOSE:String = "close";
      
      public function CloseEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
      }
   }
}

