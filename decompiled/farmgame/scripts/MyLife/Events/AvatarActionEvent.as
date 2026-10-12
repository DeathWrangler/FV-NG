package MyLife.Events
{
   import flash.events.Event;
   
   public class AvatarActionEvent extends Event
   {
      
      public static const ACTION_COMPLETE:String = "ACTION_COMPLETE";
      
      public static const ACTION_START:String = "ACTION_START";
      
      public static const ACTION_CANCELLED:String = "ACTION_CANCELLED";
      
      public static const SERVER_ACTION_LIST_START:String = "SERVER_ACTION_LIST_START";
      
      public static const ACTION_LIST_COMPLETE:String = "ACTION_LIST_COMPLETE";
      
      public static const ACTION_LIST_START:String = "ACTION_LIST_START";
      
      public var actionParams:Object;
      
      public var actionListID:String;
      
      public var characterId:Number;
      
      public var actionId:String;
      
      public function AvatarActionEvent(param1:String, param2:String, param3:Number, param4:Object, param5:String)
      {
         super(param1);
         this.actionId = param2;
         this.actionParams = param4;
         this.characterId = param3;
         this.actionListID = param5;
      }
   }
}

