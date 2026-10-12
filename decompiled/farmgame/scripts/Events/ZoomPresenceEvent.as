package Events
{
   import flash.events.Event;
   
   public class ZoomPresenceEvent extends Event
   {
      
      public var m_gameId:int = -1;
      
      public var m_uid:String = "-1";
      
      public var m_status:String = "";
      
      public function ZoomPresenceEvent(type:String, gameId:int, uid:String, status:String)
      {
         this.m_gameId = gameId;
         this.m_uid = uid;
         this.m_status = status;
         super(type);
      }
   }
}

