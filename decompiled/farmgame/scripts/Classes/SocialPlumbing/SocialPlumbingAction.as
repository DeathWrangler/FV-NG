package Classes.SocialPlumbing
{
   import Classes.Friend;
   import Classes.util.ZLocUtils;
   import flash.events.EventDispatcher;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class SocialPlumbingAction extends EventDispatcher
   {
      
      private static const SECTION:String = "SocialPlumbing";
      
      public static const NUM_FRIENDS_HELPED_KEY:String = "socialActionFriendsHelped";
      
      protected var m_messageText:String = null;
      
      protected var m_titleText:String = null;
      
      protected var m_acceptButtonText:String = null;
      
      protected var m_cancelButtonText:String = null;
      
      protected var m_data:Object;
      
      protected var m_friend:Friend = null;
      
      protected var m_iconUrl:String = null;
      
      protected var m_isComplete:Boolean = false;
      
      protected var m_forceClose:Boolean = false;
      
      public function SocialPlumbingAction(data:Object)
      {
         super();
         if(Boolean(data) && data.hasOwnProperty("uid"))
         {
            this.m_data = data;
            this.m_friend = Global.friendManager.getFriendData(this.m_data["uid"]);
         }
         this.m_acceptButtonText = ZLocUtils.t("Dialogs","Accept");
         this.m_cancelButtonText = ZLocUtils.t("Dialogs","Cancel");
      }
      
      public static function getActionFromServerClassName(className:String) : Class
      {
         var result:Class = null;
         if(className)
         {
            className = "Classes.SocialPlumbing::SP" + className;
            try
            {
               result = getDefinitionByName(className) as Class;
            }
            catch(e:Error)
            {
               GlobalEngine.log(SocialPlumbingAction.SECTION,className + " is not a defined social plumbing action");
            }
         }
         return result;
      }
      
      public static function getServerClassNameFromAction(action:SocialPlumbingAction) : String
      {
         var fullClassName:String = null;
         var result:String = "";
         if(action)
         {
            fullClassName = getQualifiedClassName(action);
            try
            {
               result = fullClassName.substr(fullClassName.lastIndexOf(":SP") + 3);
            }
            catch(e:Error)
            {
               GlobalEngine.log(SocialPlumbingAction.SECTION,fullClassName + " is not a defined social plumbing action");
            }
         }
         return result;
      }
      
      public function get messageText() : String
      {
         return this.m_messageText;
      }
      
      public function get isComplete() : Boolean
      {
         return this.m_isComplete;
      }
      
      public function set isComplete(value:Boolean) : void
      {
         this.m_isComplete = value;
      }
      
      public function get titleText() : String
      {
         return this.m_titleText;
      }
      
      public function get acceptButtonText() : String
      {
         return this.m_acceptButtonText;
      }
      
      public function get cancelButtonText() : String
      {
         return this.m_cancelButtonText;
      }
      
      public function get iconUrl() : String
      {
         return this.m_iconUrl;
      }
      
      public function get friendUid() : String
      {
         return this.m_data["uid"];
      }
      
      public function get friend() : Friend
      {
         return this.m_friend;
      }
      
      public function get statTrackingEventString() : String
      {
         return "";
      }
      
      public function takeAction() : void
      {
      }
      
      public function shouldForceClose() : Boolean
      {
         return this.m_forceClose;
      }
   }
}

