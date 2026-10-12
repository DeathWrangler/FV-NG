package Engine.Transactions
{
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class TPublishUserAction extends Transaction
   {
      
      protected static const FEED_CALLBACK_TIMEOUT:Number = 15;
      
      protected static const AUTO_PUBLISH_DELAY:Number = 5000;
      
      protected static var m_category:String = "";
      
      protected static var m_subcategory:String = "";
      
      protected static var m_creative:String = "";
      
      protected var m_action:String;
      
      protected var m_bundleData:Object;
      
      protected var m_oneLine:Boolean;
      
      protected var m_strTargetIds:Array;
      
      protected var m_closeCallback:Function = null;
      
      protected var m_askPermissions:Boolean;
      
      protected var m_autoPublish:Boolean = false;
      
      protected var m_userMessage:String = "";
      
      protected var m_autoPublishTimer:Timer;
      
      public function TPublishUserAction(param1:String, param2:Object, param3:Array, param4:Boolean, param5:Function = null, param6:int = 0, param7:Boolean = false, param8:Boolean = false, param9:String = "")
      {
         var _loc10_:int = 0;
         this.m_strTargetIds = new Array();
         super();
         this.m_action = param1;
         this.m_bundleData = param2;
         this.m_oneLine = param4;
         this.m_closeCallback = param5;
         this.m_askPermissions = param7;
         this.m_autoPublish = param8;
         this.m_userMessage = param9;
         if(this.m_closeCallback != null)
         {
            if(param6 <= 0)
            {
               param6 = FEED_CALLBACK_TIMEOUT;
            }
            if(GlobalEngine.feedCallbackTimer == null)
            {
               GlobalEngine.feedCallbackTimer = new Timer(param6 * 1000);
               GlobalEngine.feedCallbackTimer.addEventListener(TimerEvent.TIMER,this.onCloseCallback,false,0,true);
               GlobalEngine.feedCallbackTimer.start();
            }
            GlobalEngine.onFeedCloseCallback = this.onCloseCallback;
         }
         if(param3)
         {
            _loc10_ = 0;
            while(_loc10_ < param3.length)
            {
               this.m_strTargetIds.push(param3[_loc10_].toString());
               _loc10_++;
            }
         }
      }
      
      public static function get category() : String
      {
         return m_category;
      }
      
      public static function get subcategory() : String
      {
         return m_subcategory;
      }
      
      public static function get creative() : String
      {
         return m_creative;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.publishUserAction",this.m_action,this.m_bundleData,this.m_strTargetIds,this.m_oneLine);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         if(Boolean(param1) && Boolean(param1.published))
         {
            GlobalEngine.socialNetwork.feedPostConfirmation(param1);
         }
         else if(Boolean(param1) && Boolean(param1.shareAsLink))
         {
            GlobalEngine.socialNetwork.shareAsLink(param1);
         }
         else if(Boolean(param1.showFeedDialog) && this.m_oneLine == false)
         {
            if(this.m_askPermissions && !GlobalEngine.socialNetwork.userHasStreamPermissions())
            {
               GlobalEngine.socialNetwork.showStreamPermissions(this.onFinishStreamPermissions);
            }
            else
            {
               m_category = param1.category;
               m_subcategory = param1.subcategory;
               m_creative = param1.creative;
               this.streamPublish();
            }
         }
      }
      
      protected function streamPublish() : void
      {
         var _loc1_:String = null;
         if(this.m_strTargetIds.length > 0)
         {
            _loc1_ = this.m_strTargetIds[0].toString();
         }
         GlobalEngine.socialNetwork.streamPublish(m_rawResult.data.attachment,m_rawResult.data.actionLink,_loc1_,m_rawResult.data.userMessagePrompt,null,this.m_autoPublish,this.m_userMessage);
      }
      
      protected function onFinishStreamPermissions() : void
      {
         if(GlobalEngine.socialNetwork.userHasStreamPermissions())
         {
            this.m_autoPublishTimer = new Timer(AUTO_PUBLISH_DELAY,1);
            this.m_autoPublishTimer.addEventListener(TimerEvent.TIMER,this.onPublishDelayComplete);
            this.m_autoPublishTimer.start();
         }
         else
         {
            this.streamPublish();
         }
      }
      
      protected function onPublishDelayComplete(param1:TimerEvent) : void
      {
         if(this.m_autoPublishTimer != null)
         {
            this.m_autoPublishTimer.removeEventListener(TimerEvent.TIMER,this.onPublishDelayComplete);
            this.m_autoPublishTimer = null;
         }
         this.streamPublish();
      }
      
      protected function onCloseCallback(param1:TimerEvent) : void
      {
         GlobalEngine.onFeedCloseCallback = null;
         GlobalEngine.socialNetwork.onFeedClosed();
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback();
         }
      }
   }
}

