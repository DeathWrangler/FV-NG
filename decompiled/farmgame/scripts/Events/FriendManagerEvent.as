package Events
{
   import flash.events.Event;
   
   public class FriendManagerEvent extends Event
   {
      
      public static const PARSEFRIENDS_COMPLETE:String = "parseFriends_complete";
      
      public function FriendManagerEvent(type:String)
      {
         super(type);
      }
   }
}

