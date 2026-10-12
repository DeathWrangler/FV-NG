package Init
{
   import Events.FriendDataLoadedEvent;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class FarmFacebookInit extends FacebookInit
   {
      
      protected static const SETUP_FRIENDS_TIMER_DELAY:int = 200;
      
      protected static const IS_DEBUG_TIMER_DELAY:Boolean = false;
      
      protected var m_friendsTimer:Timer;
      
      public function FarmFacebookInit(skip:Boolean, snClass:Class = null)
      {
         super(skip,snClass);
      }
      
      override protected function setupOnUserComplete() : void
      {
         if(Global.player != null)
         {
            Global.player.updateNameFromSNUser();
         }
      }
      
      override protected function setupOnFriendsComplete() : void
      {
         this.setupPlayerFriends(null);
      }
      
      private function setupPlayerFriends(event:Event) : void
      {
         var isTimerComplete:Boolean = !IS_DEBUG_TIMER_DELAY || event != null;
         if(Boolean(Global.friendManager) && isTimerComplete)
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

