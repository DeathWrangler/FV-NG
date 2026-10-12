package Events
{
   import flash.events.Event;
   
   public class ZoomMessageEvent extends Event
   {
      
      public var m_fromUid:String = "-1";
      
      public var m_message:String = "";
      
      public var m_extraData:String = "";
      
      public var m_timeStamp:Number;
      
      public function ZoomMessageEvent(type:String, fromUid:String, message:String, timeStamp:Number, extraData:String = "")
      {
         this.m_fromUid = fromUid;
         this.m_message = message;
         this.m_timeStamp = timeStamp;
         this.m_extraData = extraData;
         super(type);
      }
   }
}

