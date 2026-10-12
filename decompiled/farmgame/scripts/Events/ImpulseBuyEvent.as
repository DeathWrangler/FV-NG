package Events
{
   import flash.events.Event;
   
   public class ImpulseBuyEvent extends Event
   {
      
      public static const ACCEPT:String = "impulse_buy_accept";
      
      public static const CANCEL:String = "impulse_buy_cancel";
      
      public function ImpulseBuyEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
      }
   }
}

