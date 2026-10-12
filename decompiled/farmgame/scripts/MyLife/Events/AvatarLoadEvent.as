package MyLife.Events
{
   import flash.events.Event;
   
   public class AvatarLoadEvent extends Event
   {
      
      public static const CLOTHING_LOAD_COMPLETE:String = "CLOTHING_LOAD_COMPLETE";
      
      public static const CHARACTER_LOAD_COMPLETE:String = "CHARACTER_LOAD_COMPLETE";
      
      public static const NPC_LOAD_COMPLETE:String = "NPC_LOAD_COMPLETE";
      
      public static const PLAYER_LOAD_COMPLETE:String = "PLAYER_LOAD_COMPLETE";
      
      public var eventData:Object;
      
      public function AvatarLoadEvent(param1:String, param2:Object = null, param3:Boolean = true)
      {
         this.eventData = param2;
         super(param1,param3);
      }
   }
}

