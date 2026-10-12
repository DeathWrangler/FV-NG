package zasp.Bridge
{
   import flash.events.Event;
   
   public class BridgeLogEvent extends Event
   {
      
      public var message:String;
      
      public function BridgeLogEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}

