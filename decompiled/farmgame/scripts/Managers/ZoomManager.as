package Managers
{
   import Classes.util.ExternalUtil;
   import Events.ZoomMessageEvent;
   import Events.ZoomPresenceEvent;
   import flash.events.EventDispatcher;
   import flash.external.ExternalInterface;
   
   public class ZoomManager extends EventDispatcher
   {
      
      public static var EVENTTYPE_PRESENCE_CHANGED:String = "presenceChanged";
      
      public static var ZOOM_STATUS_UNINITIALIZED:int = 0;
      
      public static var ZOOM_STATUS_READY:int = 1;
      
      public static var ZOOM_STATUS_CONNECTING:int = 2;
      
      public static var ZOOM_STATUS_CONNECTED:int = 3;
      
      public static var ZOOM_STATUS_AUTHSUCCEEDED:int = 4;
      
      public static var ZOOM_STATUS_AUTHFAILED:int = 5;
      
      public static var ZOOM_STATUS_DISCONNECTING:int = 6;
      
      public static var ZOOM_STATUS_DISCONNECTED:int = 7;
      
      public static var ZOOM_STATUS_RETRYING:int = 8;
      
      private static var m_instance:ZoomManager = null;
      
      private var m_initTimestamp:Number = 0;
      
      public function ZoomManager()
      {
         super();
         this.m_initTimestamp = GlobalEngine.serverTime;
      }
      
      public static function get instance() : ZoomManager
      {
         if(m_instance == null)
         {
            m_instance = new ZoomManager();
         }
         return m_instance;
      }
      
      public static function initConnection() : void
      {
         ExternalUtil.instance.call("initZoom",!Global.player.farmTalkPermission);
      }
      
      public static function readyForData() : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.addCallback("onZoomPresenceChanged",ZoomManager.onZoomPresenceChanged);
            ExternalInterface.addCallback("onZoomMessageReceived",ZoomManager.onZoomMessageReceived);
            ExternalUtil.instance.call("flushZoomDataToCallbacks");
         }
      }
      
      private static function stripSocialNetworkFromUid(snPlusUid:String) : String
      {
         var uid:String = null;
         var splitString:Array = snPlusUid.split(":");
         if(splitString.length == 2)
         {
            uid = splitString[1];
         }
         else
         {
            uid = snPlusUid;
         }
         return uid;
      }
      
      public static function onZoomPresenceChanged(gameId:int, uid:String, status:String) : void
      {
         var uidNumber:String = stripSocialNetworkFromUid(uid);
         instance.dispatchEvent(new ZoomPresenceEvent(ZoomManager.EVENTTYPE_PRESENCE_CHANGED,gameId,uidNumber,status));
      }
      
      public static function onZoomMessageReceived(scope:String, fromUid:String, message:String, timeStamp:Number) : void
      {
         var fromUidNumber:String = stripSocialNetworkFromUid(fromUid);
         var type:String = scope;
         var extraData:String = "";
         var splitString:Array = scope.split(":");
         if(splitString.length == 2)
         {
            type = splitString[0];
            extraData = splitString[1];
         }
         if(timeStamp > m_instance.m_initTimestamp)
         {
            if(type == ChatManager.EVENTTYPE_SELF_CHAT)
            {
               FarmStatsManager.sample(100,"chat","chatFlow","5a_receivedSelfChat_as");
            }
            else if(type == ChatManager.EVENTTYPE_CHAT)
            {
               FarmStatsManager.sample(100,"chat","chatFlow","5b_receivedChat_as");
            }
            else
            {
               FarmStatsManager.sample(100,"chat","chatFlow","5c_error_invalidScope_as");
            }
         }
         instance.dispatchEvent(new ZoomMessageEvent(type,fromUidNumber,message,timeStamp,extraData));
      }
      
      public static function isZoomOkay() : Boolean
      {
         var result:Boolean = ExternalUtil.instance.call("isZoomOkay");
         if(!result)
         {
            FarmStatsManager.sample(100,"chat","error","zoom_not_okay");
         }
         return result;
      }
      
      public static function setZoomPresenceHidden(hidePresence:Boolean) : void
      {
         ExternalUtil.instance.call("setZoomPresenceHidden",hidePresence);
      }
   }
}

