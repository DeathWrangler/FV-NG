package Events
{
   import Classes.Avatar.FarmAvatar;
   import flash.events.Event;
   
   public class AvatarEvent extends Event
   {
      
      public static const MOVED:String = "moved";
      
      public static const SELECTED:String = "selected";
      
      public static const COMPLETED:String = "completed";
      
      public var avatar:FarmAvatar;
      
      public function AvatarEvent(type:String, data:FarmAvatar = null)
      {
         this.avatar = data;
         super(type);
      }
   }
}

