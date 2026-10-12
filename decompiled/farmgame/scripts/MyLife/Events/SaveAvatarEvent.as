package MyLife.Events
{
   import flash.events.Event;
   
   public class SaveAvatarEvent extends Event
   {
      
      public static var SAVE:String = "saveAvatar";
      
      public static var CANCEL:String = "cancel";
      
      public var customizationData:Object;
      
      public var gender:int = 0;
      
      public var avatarName:String;
      
      public function SaveAvatarEvent(param1:String, param2:Object, param3:int = 0, param4:String = "", param5:Boolean = false, param6:Boolean = false)
      {
         super(param1,true,param6);
         this.customizationData = param2;
         this.gender = param3;
         this.avatarName = param4;
      }
   }
}

