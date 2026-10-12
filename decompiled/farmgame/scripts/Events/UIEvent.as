package Events
{
   import flash.events.Event;
   
   public class UIEvent extends Event
   {
      
      public static const TAB_CLICK:String = "tabClick";
      
      public static const DISPLAYED_FROM_DIALOG_QUEUE:String = "displayed_from_dialog_queue";
      
      public static const GIFTBOX_UNLOCKED:String = "giftbox_unlocked";
      
      public var label:String;
      
      public function UIEvent(type:String, data:String, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         this.label = data;
         super(type,bubbles,cancelable);
      }
   }
}

