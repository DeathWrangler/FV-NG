package Engine.Events
{
   import flash.events.Event;
   
   public class SocialNetworkEvent extends Event
   {
      
      public static const GET_USER_COMPLETE:String = "getUserComplete";
      
      public static const GET_FRIENDS_COMPLETE:String = "getFriendsComplete";
      
      public static const GET_APP_FRIENDS_COMPLETE:String = "getAppFriendsComplete";
      
      public static const LOGIN_COMPLETE:String = "loginComplete";
      
      public function SocialNetworkEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}

