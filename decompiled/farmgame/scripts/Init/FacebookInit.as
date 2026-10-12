package Init
{
   import Classes.FarmSocialNetwork;
   import Classes.util.FacebookSocialNetwork;
   import Engine.Events.SocialNetworkEvent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class FacebookInit extends SocialNetworkInit
   {
      
      protected static const FB_API_KEY:String = "";
      
      protected static const FB_SECRET:String = "";
      
      protected var m_facebookUtil:FacebookSocialNetwork;
      
      protected var m_facebookUtilClass:Class = null;
      
      public var m_isInOAuth:Boolean = false;
      
      public function FacebookInit(skip:Boolean, snClass:Class = null)
      {
         if(snClass == null)
         {
            snClass = FacebookSocialNetwork;
         }
         this.m_facebookUtilClass = snClass;
         super(skip);
      }
      
      override public function execute() : void
      {
         var timer:Timer = null;
         if(m_skipSN)
         {
            super.execute();
         }
         else
         {
            GlobalEngine.socialNetwork = this.m_facebookUtil = new this.m_facebookUtilClass(this.getApiKey(),this.getSecret());
            Global.farmSocialNetwork = GlobalEngine.socialNetwork as FarmSocialNetwork;
            Global.farmSocialNetwork.m_isInOAuth = this.m_isInOAuth;
            if(this.m_facebookUtil.needsLogin && false == this.m_isInOAuth)
            {
               this.addEventListener(MouseEvent.CLICK,this.onLoginClick);
               this.m_facebookUtil.addEventListener(SocialNetworkEvent.LOGIN_COMPLETE,this.onLoginComplete);
               timer = new Timer(4000,3);
               timer.addEventListener(TimerEvent.TIMER,this.onLoginClick);
               timer.start();
            }
            else
            {
               this.onLoginComplete(null);
            }
         }
      }
      
      private function onLoginComplete(e:Event) : void
      {
         this.m_facebookUtil.removeEventListener(SocialNetworkEvent.LOGIN_COMPLETE,this.onLoginComplete);
         dispatchEvent(new Event(Event.COMPLETE));
         postExecute();
         this.m_facebookUtil.addEventListener(SocialNetworkEvent.GET_USER_COMPLETE,this.onGetUserComplete);
         this.m_facebookUtil.getUser();
      }
      
      private function onGetUserComplete(e:SocialNetworkEvent) : void
      {
         this.m_facebookUtil.removeEventListener(SocialNetworkEvent.GET_USER_COMPLETE,this.onGetUserComplete);
         this.setupOnUserComplete();
         this.m_facebookUtil.addEventListener(SocialNetworkEvent.GET_FRIENDS_COMPLETE,this.onGetFriendsComplete);
         this.m_facebookUtil.getFriendList();
      }
      
      protected function setupOnUserComplete() : void
      {
      }
      
      private function onGetFriendsComplete(e:SocialNetworkEvent) : void
      {
         this.m_facebookUtil.removeEventListener(SocialNetworkEvent.GET_FRIENDS_COMPLETE,this.onGetFriendsComplete);
         this.m_facebookUtil.addEventListener(SocialNetworkEvent.GET_APP_FRIENDS_COMPLETE,this.onGetAppFriendsComplete);
         this.m_facebookUtil.getAppFriends();
      }
      
      private function onGetAppFriendsComplete(e:SocialNetworkEvent) : void
      {
         this.m_facebookUtil.removeEventListener(SocialNetworkEvent.GET_APP_FRIENDS_COMPLETE,this.onGetAppFriendsComplete);
         this.setupOnFriendsComplete();
      }
      
      protected function setupOnFriendsComplete() : void
      {
      }
      
      private function onLoginClick(e:Event = null) : void
      {
         this.m_facebookUtil.validateLogin();
      }
      
      protected function getApiKey() : String
      {
         return GlobalEngine.getFlashVar("fb_sig_api_key") as String;
      }
      
      protected function getSecret() : String
      {
         return GlobalEngine.getFlashVar("fb_sig_api_secret") as String;
      }
   }
}

