package Events
{
   import flash.events.Event;
   
   public class SocialPlumbingEvent extends Event
   {
      
      public static const FEED_ACCEPT:String = "sp_feed_accept";
      
      public static const FEED_SKIPPED:String = "sp_feed_skipped";
      
      public static const FEED_CLOSED:String = "sp_feed_closed";
      
      public var data:Object;
      
      public function SocialPlumbingEvent(type:String, data:Object = null)
      {
         super(type);
         this.data = data;
      }
   }
}

