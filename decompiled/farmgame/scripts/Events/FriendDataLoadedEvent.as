package Events
{
   import flash.events.Event;
   
   public class FriendDataLoadedEvent extends Event
   {
      
      public static const FRIEND_DATA_LOADED:String = "friend_data_loaded";
      
      public function FriendDataLoadedEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
      }
   }
}

