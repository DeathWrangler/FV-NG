package Init
{
   import Engine.Init.InitializationAction;
   import Events.FriendDataLoadedEvent;
   import Managers.SocialPlumbingManager;
   import flash.events.Event;
   
   public class SocialPlumbingInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "SocialPlumbingInit";
      
      private var m_socialNetwork:SocialNetworkInit = null;
      
      public function SocialPlumbingInit(socialNetwork:SocialNetworkInit)
      {
         super(INIT_ID);
         if(socialNetwork)
         {
            this.m_socialNetwork = socialNetwork;
            this.m_socialNetwork.addEventListener(FriendDataLoadedEvent.FRIEND_DATA_LOADED,this.onFriendDataLoadedEvent);
         }
         addDependency(SocialNetworkInit.INIT_ID);
      }
      
      override public function execute() : void
      {
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function onFriendDataLoadedEvent(loadedEvent:FriendDataLoadedEvent) : void
      {
         this.m_socialNetwork.removeEventListener(FriendDataLoadedEvent.FRIEND_DATA_LOADED,this.onFriendDataLoadedEvent);
         SocialPlumbingManager.getInstance().friendDataLoaded = true;
         if(Global.experimentManager.getExperimentVariant(SocialPlumbingManager.EXPERIMENT_SP_TODO_LIST) > 0)
         {
            SocialPlumbingManager.getInstance().getTaskList();
         }
      }
   }
}

