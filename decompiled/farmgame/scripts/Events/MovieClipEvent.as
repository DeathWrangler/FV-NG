package Events
{
   import flash.events.Event;
   
   public class MovieClipEvent extends Event
   {
      
      public static const LOOP_COMPLETE:String = "loopComplete";
      
      public function MovieClipEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
      }
   }
}

