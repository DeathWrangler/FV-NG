package Init
{
   import Engine.Events.SocialNetworkEvent;
   import Events.FriendDataLoadedEvent;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class FarmZLiveInit extends ZLiveInit
   {
      
      protected static const SETUP_FRIENDS_TIMER_DELAY:int = 500;
      
      protected static const IS_DEBUG_TIMER_DELAY:Boolean = false;
      
      protected var m_friendsTimer:Timer;
      
      public function FarmZLiveInit(skip:Boolean, params:Object)
      {
         super(skip,params);
      }
      
      override protected function setupOnFriendsComplete(e:SocialNetworkEvent) : void
      {
         this.setupPlayerFriends(null);
         m_zLiveSocialNetwork.removeEventListener(SocialNetworkEvent.GET_FRIENDS_COMPLETE,this.setupOnFriendsComplete);
      }
      
      private function setupPlayerFriends(event:Event) : void
      {
         var isTimerComplete:Boolean = !IS_DEBUG_TIMER_DELAY || event != null;
         if(Global.friendManager != null && isTimerComplete)
         {
            if(this.m_friendsTimer)
            {
               this.m_friendsTimer.stop();
               this.m_friendsTimer = null;
            }
            Global.friendManager.setSNUsers(GlobalEngine.socialNetwork.getFriendUsers());
            Global.friendManager.appFriendUids = GlobalEngine.socialNetwork.getAppFriendsIds();
            dispatchEvent(new FriendDataLoadedEvent(FriendDataLoadedEvent.FRIEND_DATA_LOADED));
         }
         else if(null == this.m_friendsTimer)
         {
            this.m_friendsTimer = new Timer(SETUP_FRIENDS_TIMER_DELAY);
            this.m_friendsTimer.addEventListener(TimerEvent.TIMER,this.setupPlayerFriends);
            this.m_friendsTimer.start();
         }
      }
   }
}

