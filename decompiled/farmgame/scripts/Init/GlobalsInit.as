package Init
{
   import Classes.FarmGameWorld;
   import Classes.Player;
   import Engine.Classes.SocialNetworkUser;
   import Engine.Init.InitializationAction;
   import Managers.FriendManager;
   import flash.events.Event;
   
   public class GlobalsInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "GlobalsInit";
      
      public function GlobalsInit()
      {
         super(INIT_ID);
         addDependency(SocialNetworkInit.INIT_ID);
      }
      
      override public function execute() : void
      {
         Global.friendManager = new FriendManager();
         Global.player = new Player(GlobalEngine.socialNetwork ? GlobalEngine.socialNetwork.getLoggedInUser() : null);
         Global.world = new FarmGameWorld();
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

