package Events
{
   import flash.events.Event;
   
   public class TakePhotoEvent extends Event
   {
      
      public static const ACCEPT:String = "accept";
      
      public static const CANCEL:String = "cancel";
      
      public var data:String;
      
      public function TakePhotoEvent(type:String, msg:String, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
         this.data = msg;
      }
   }
}

