package Engine.Classes
{
   import Engine.Managers.TransactionManager;
   import Engine.Transactions.TPublishUserAction;
   import Engine.Transactions.TSendNotification;
   import Engine.Utilities;
   import flash.events.EventDispatcher;
   
   public class SocialNetwork extends EventDispatcher
   {
      
      protected static const SHORT_STORY_TIMEOUT:Number = 2000;
      
      protected var m_sigTime:Number = 0;
      
      private var m_lastFeedTime:Number = 0;
      
      protected var m_hasPublishPermissions:Boolean = false;
      
      protected var m_hasEmailPermission:Boolean = false;
      
      protected var m_closePermissionDialogCallback:Function;
      
      protected var m_closeEmailPermissionDialogCallback:Function;
      
      public function SocialNetwork()
      {
         super();
      }
      
      public function getLoggedInUserId() : String
      {
         return null;
      }
      
      public function getLoggedInUser() : SocialNetworkUser
      {
         return null;
      }
      
      public function redirect(param1:String, param2:Object = null, param3:String = "_parent", param4:Boolean = true) : void
      {
         if(param4)
         {
            param1 = Config.SN_APP_URL + param1;
         }
         Utilities.launchURL(param1,param3,param2);
      }
      
      public function getFriendUsers() : Array
      {
         return [];
      }
      
      public function getAppFriendsIds() : Array
      {
         return [];
      }
      
      public function getSigTime() : Number
      {
         return this.m_sigTime;
      }
      
      public function sendNotification(param1:String, param2:Array, param3:Array) : void
      {
         TransactionManager.addTransaction(new TSendNotification(param1,param2,param3));
      }
      
      public function publishFeedStory(param1:String, param2:Object, param3:Array, param4:Boolean, param5:Function = null, param6:int = 0, param7:Boolean = false, param8:Boolean = false, param9:String = "") : void
      {
         TransactionManager.addTransaction(new TPublishUserAction(param1,param2,param3,param4,param5,param6,param7,param8,param9),true);
      }
      
      public function getDefaultFeedImages() : Array
      {
         return [];
      }
      
      public function showFeedDialog(param1:String, param2:Object, param3:Array, param4:Function = null) : void
      {
      }
      
      public function shareAsLink(param1:Object) : void
      {
      }
      
      public function streamPublishV2(param1:Object, param2:Function) : void
      {
      }
      
      public function streamPublish(param1:Object, param2:Object, param3:String, param4:String = null, param5:Function = null, param6:Boolean = false, param7:String = "") : void
      {
      }
      
      public function feedPostConfirmation(param1:Object) : void
      {
      }
      
      public function showBookmarkDialog() : void
      {
      }
      
      public function onFeedClosed() : void
      {
         this.m_lastFeedTime = GlobalEngine.getTimer();
         if(GlobalEngine.feedCallbackTimer)
         {
            GlobalEngine.feedCallbackTimer.stop();
            GlobalEngine.feedCallbackTimer = null;
         }
         if(GlobalEngine.onFeedCloseCallback != null)
         {
            GlobalEngine.onFeedCloseCallback(null);
            GlobalEngine.onFeedCloseCallback = null;
         }
      }
      
      public function showStreamPermissions(param1:Function = null, param2:String = "") : void
      {
         this.m_closePermissionDialogCallback = param1;
      }
      
      public function onPermissionDialogClosed(param1:Boolean) : void
      {
         this.m_hasPublishPermissions = param1;
         if(this.m_closePermissionDialogCallback != null)
         {
            this.m_closePermissionDialogCallback();
            this.m_closePermissionDialogCallback = null;
         }
      }
      
      public function userHasStreamPermissions() : Boolean
      {
         return this.m_hasPublishPermissions;
      }
      
      public function showEmailPermission(param1:Function = null) : void
      {
         this.m_closeEmailPermissionDialogCallback = param1;
      }
      
      public function onEmailPermissionDialogClosed(param1:Boolean) : void
      {
         this.m_hasEmailPermission = param1;
         if(this.m_closeEmailPermissionDialogCallback != null)
         {
            this.m_closeEmailPermissionDialogCallback(param1);
            this.m_closeEmailPermissionDialogCallback = null;
         }
      }
      
      public function set haveEmailPermission(param1:Boolean) : void
      {
         this.m_hasEmailPermission = param1;
      }
      
      public function userHasEmailPermission() : Boolean
      {
         return this.m_hasEmailPermission;
      }
   }
}

