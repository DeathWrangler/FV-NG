package Events
{
   import flash.events.Event;
   
   public class TileUnlockEvent extends Event
   {
      
      private var m_tileData:Object;
      
      public function TileUnlockEvent(eventType:String, tileData:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(eventType,bubbles,cancelable);
         this.m_tileData = tileData;
      }
      
      public function get tileData() : Object
      {
         return this.m_tileData;
      }
      
      override public function clone() : Event
      {
         return new TileUnlockEvent(type,this.m_tileData,bubbles,cancelable);
      }
   }
}

