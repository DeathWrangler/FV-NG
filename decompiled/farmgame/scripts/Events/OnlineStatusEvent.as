package Events
{
   import Classes.Zoom.ZoomMessage;
   import flash.events.Event;
   
   public class OnlineStatusEvent extends Event
   {
      
      public static var STATUS_CHANGE:String = "statusChange";
      
      public static var STATUS_ONLINE:String = "online";
      
      public static var STATUS_OFFLINE:String = "offline";
      
      public static var NEW_MESSAGE:String = "newMessage";
      
      public var status:String = "";
      
      public var message:ZoomMessage = null;
      
      public function OnlineStatusEvent(status:String, zoomMessage:ZoomMessage, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         this.status = status;
         this.message = zoomMessage;
         super(OnlineStatusEvent.STATUS_CHANGE,bubbles,cancelable);
      }
      
      public function get friendUid() : String
      {
         var result:String = "-1";
         if(this.message != null)
         {
            result = this.message.sender;
         }
         return result;
      }
   }
}

