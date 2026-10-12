package Init
{
   import Classes.FarmSocialNetwork;
   import Classes.util.ZLiveSocialNetwork;
   import Engine.Events.SocialNetworkEvent;
   import flash.events.Event;
   
   public class ZLiveInit extends SocialNetworkInit
   {
      
      protected var m_zLiveSocialNetwork:ZLiveSocialNetwork;
      
      private var m_parameters:Object = null;
      
      public function ZLiveInit(skip:Boolean, parameters:Object)
      {
         super(skip);
         this.m_parameters = parameters;
      }
      
      override public function execute() : void
      {
         if(this.m_skipSN)
         {
            super.execute();
         }
         else
         {
            this.m_zLiveSocialNetwork = new ZLiveSocialNetwork(this.m_parameters);
            GlobalEngine.socialNetwork = this.m_zLiveSocialNetwork;
            Global.farmSocialNetwork = GlobalEngine.socialNetwork as FarmSocialNetwork;
            this.m_zLiveSocialNetwork.retrieveUserInfo();
            dispatchEvent(new Event(Event.COMPLETE));
            this.m_zLiveSocialNetwork.addEventListener(SocialNetworkEvent.GET_FRIENDS_COMPLETE,this.setupOnFriendsComplete);
            this.m_zLiveSocialNetwork.getFriendList();
            postExecute();
         }
      }
      
      protected function setupOnFriendsComplete(e:SocialNetworkEvent) : void
      {
      }
   }
}

