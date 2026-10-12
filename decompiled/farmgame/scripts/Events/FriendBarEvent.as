package Events
{
   import flash.events.Event;
   
   public class FriendBarEvent extends Event
   {
      
      public static const MOVE:String = "move";
      
      public static const MOVE_END:String = "stepEnd";
      
      public static const LOADED:String = "loaded";
      
      public var delta:int;
      
      public var length:int;
      
      public var resetScroll:Boolean;
      
      public function FriendBarEvent(type:String, data:int = undefined, numFriends:int = undefined, resetScroll:Boolean = true, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         this.delta = data;
         this.length = numFriends;
         this.resetScroll = resetScroll;
         super(type,bubbles,cancelable);
      }
   }
}

