package Classes
{
   import Classes.util.ExternalUtil;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TGrantExtendedPermissions;
   import Transactions.TSetSNExtendedPermissions;
   import com.adobe.serialization.json.JSON;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class ExtendedPermissionState
   {
      
      private static const API_GET_PERMS:String = "FarmNS.FlashExtendedPermissionsManager.refreshExtendedPermsFlash";
      
      public static const API_ASK_PERMS:String = "FarmNS.FlashExtendedPermissionsManager.requestExtendedPermsFlash";
      
      public static const API_HAS_FRIENDS_PERMS:String = "FarmNS.FlashExtendedPermissionsManager.checkFriendsPermissionFlash";
      
      private static const EXTENDED_PERMS_LIST:String = "publish_actions,user_games_activity,friends_games_activity";
      
      public static const EXTENDED_PERMS_LIST_CIP:String = "publish_actions,user_birthday";
      
      private static const EXTENDED_PERMS_LIST_2:String = "publish_actions,user_games_activity,friends_games_activity,read_stream";
      
      private static const EXTENDED_PERMS_LIST_FRIENDS:String = "user_friends";
      
      private static const EXTENDED_PERMS_LIST_PUBLISH:String = "publish_actions";
      
      public static const EXISTING_PERMISSION_GRANT:int = 0;
      
      public static const NEW_PERMISSION_GRANT:int = 1;
      
      public static const PREREQUISITE_NO_SN_PERMISSION:String = "no_sn_permission";
      
      public static const EXTENDED_PERMISSIONS_GIFT_GIVEN:String = "extended_permissions_gift_given";
      
      private var m_extendedPermissions:Object = {};
      
      private var checkPermTimer:Timer;
      
      public function ExtendedPermissionState(extendedPermissions:Object = null)
      {
         super();
         this.m_extendedPermissions = extendedPermissions;
      }
      
      public function refreshExtendedPermissions(cb:Function = null, tryGiftGrant:Boolean = true) : void
      {
         var callback:Function = function(response:Object):void
         {
            var key:String = null;
            var permissions:Object = response[0];
            for(key in permissions)
            {
               if(m_extendedPermissions == null || !m_extendedPermissions.hasOwnProperty(key) || m_extendedPermissions[key] != permissions[key])
               {
                  m_extendedPermissions = permissions;
                  TransactionManager.addTransaction(new TSetSNExtendedPermissions(m_extendedPermissions));
                  break;
               }
            }
            if(cb != null)
            {
               cb(response);
            }
         };
         var callId:String = ExternalUtil.instance.registerCallback(callback);
         ExternalUtil.instance.call(API_GET_PERMS,callId);
      }
      
      public function requestExtendedPermissions(cb:Function = null) : void
      {
         var callback:Function = function(response:Object):void
         {
            refreshExtendedPermissions(cb,false);
         };
         var callId:String = ExternalUtil.instance.registerCallback(callback);
         ExternalUtil.instance.call(API_ASK_PERMS,callId,EXTENDED_PERMS_LIST);
      }
      
      public function requestFriendsPermissions(cb:Function = null) : void
      {
         var callId:String = ExternalUtil.instance.registerCallback(cb);
         ExternalUtil.instance.call(API_ASK_PERMS,callId,EXTENDED_PERMS_LIST_FRIENDS);
      }
      
      public function requestPublishPermissions(cb:Function = null) : void
      {
         var callId:String = ExternalUtil.instance.registerCallback(cb);
         ExternalUtil.instance.call(API_ASK_PERMS,callId,EXTENDED_PERMS_LIST_PUBLISH);
      }
      
      public function requestPermissions(permissions:String, callback:Function) : void
      {
         var callbackId:String = ExternalUtil.instance.registerCallback(callback);
         ExternalUtil.instance.call(API_ASK_PERMS,callbackId,permissions,true);
      }
      
      public function requestExtendedPermissionsWithGift(cb:Function = null) : void
      {
         var callback:Function = function(response:Object):void
         {
            refreshExtendedPermissions(cb,false);
         };
         var callId:String = ExternalUtil.instance.registerCallback(callback);
         ExternalUtil.instance.call(API_ASK_PERMS,callId,EXTENDED_PERMS_LIST_2);
         this.checkPermTimer = new Timer(5000,5);
         this.checkPermTimer.addEventListener(TimerEvent.TIMER,this.checkExtendedPermissionsState);
         this.checkPermTimer.start();
      }
      
      public function conditionallyGrantExtendedPermissionsWithGift(motdSeenType:int = 0) : void
      {
         if(!Global.player.getSeenFlag(ExtendedPermissionState.EXTENDED_PERMISSIONS_GIFT_GIVEN))
         {
            TransactionManager.addTransaction(new TGrantExtendedPermissions(motdSeenType),true);
         }
      }
      
      private function checkExtendedPermissionsState(event:TimerEvent) : void
      {
         this.refreshExtendedPermissions(null,false);
         if(this.hasExtendedPermisssions())
         {
            this.conditionallyGrantExtendedPermissionsWithGift(ExtendedPermissionState.NEW_PERMISSION_GRANT);
            FarmStatsManager.count("open_graph_permissions_2","permissions_collected");
            this.checkPermTimer.removeEventListener(TimerEvent.TIMER,this.checkExtendedPermissionsState);
            this.checkPermTimer.stop();
         }
      }
      
      public function hasExtendedPermisssions() : Boolean
      {
         var result:Boolean = false;
         if(Global.player.extendedPermissionState.hasExtendedPermission("publish_actions") && Global.player.extendedPermissionState.hasExtendedPermission("user_games_activity") && Global.player.extendedPermissionState.hasExtendedPermission("friends_games_activity"))
         {
            result = true;
         }
         return result;
      }
      
      public function hasExtendedPermission(perm:String) : Boolean
      {
         var result:Boolean = false;
         result = Boolean(this.m_extendedPermissions) && this.m_extendedPermissions.hasOwnProperty(perm) && this.m_extendedPermissions[perm] > 0;
         return result || Global.player.acceptedFbPermissions.hasOwnProperty(perm) && Global.player.acceptedFbPermissions[perm] > 0;
      }
      
      public function test() : void
      {
         var output:String = "motdExperiment is active: yes" + "\n";
         output = output + "liveChromeExperiment is active: " + "no" + "\n";
         output = output + "app permissions: " + com.adobe.serialization.json.JSON.encode(this.m_extendedPermissions) + "\n";
         output = output + "hasExtendedPermissions publish_actions: " + (Global.player.extendedPermissionState.hasExtendedPermission("publish_actions") ? "yes" : "no") + "\n";
         output = output + "hasExtendedPermissions user_games_activity: " + (Global.player.extendedPermissionState.hasExtendedPermission("user_games_activity") ? "yes" : "no") + "\n";
         output = output + "hasExtendedPermissions friends_games_activity: " + (Global.player.extendedPermissionState.hasExtendedPermission("friends_games_activity") ? "yes" : "no") + "\n";
         output = output + "hasExtendedPermissions publish_stream: " + (Global.player.extendedPermissionState.hasExtendedPermission("publish_stream") ? "yes" : "no") + "\n";
         UI.showMessage(output,UI.BUTTON_LAYOUT_OK,"ExtendedPermissionsState.test()");
      }
   }
}

