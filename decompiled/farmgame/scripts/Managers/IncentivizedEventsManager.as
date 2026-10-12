package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Constants.MFSConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ExternalUtil;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Widgets.Windows.MFSEventInvite;
   
   public class IncentivizedEventsManager
   {
      
      private static var s_instance:IncentivizedEventsManager;
      
      private static const FEED_ICON_ITEM_RUNTIME_FLAG:String = "INCENTIVIZED_EVENT_FEED_ICON_ITEM";
      
      private static const DIALOG_PREFIX_RUNTIME_FLAG:String = "INCENTIVIZED_EVENT_DIALOG_PREFIX";
      
      private static const EVENT_ID_RUNTIME_FLAG:String = "INCENTIVIZED_EVENT_ID";
      
      private static const FEED_ICON_ITEM_FALLBACK:String = "feed_incentivized_doubleParts";
      
      public const SHARE_VARIANT:int = 2;
      
      private const EVENT_RSVP:String = "rsvp_event";
      
      private const EVENT_STATUS_GRANTED:String = "granted";
      
      private const EVENT_INVITE:String = "create_event";
      
      private var m_eventId:String = "";
      
      private var m_dialogPrefix:String = "";
      
      private var m_permissions:Object = null;
      
      public function IncentivizedEventsManager(key:SingletonEnforcer)
      {
         var dialogPrefix:String = null;
         super();
         GlobalEngine.assert(key != null,"[IncentivizedEventsManager] :: Use GetInstance()");
         if(Global.flashHotParams.hasOwnProperty(EVENT_ID_RUNTIME_FLAG))
         {
            this.m_eventId = Global.flashHotParams[EVENT_ID_RUNTIME_FLAG];
         }
         this.m_dialogPrefix = this.m_eventId;
         if(Global.flashHotParams.hasOwnProperty(DIALOG_PREFIX_RUNTIME_FLAG))
         {
            dialogPrefix = Global.flashHotParams[DIALOG_PREFIX_RUNTIME_FLAG];
            if(dialogPrefix != "")
            {
               this.m_dialogPrefix = dialogPrefix;
            }
         }
      }
      
      public static function get instance() : IncentivizedEventsManager
      {
         if(!s_instance)
         {
            s_instance = new IncentivizedEventsManager(new SingletonEnforcer());
         }
         return s_instance;
      }
      
      public function get dialogPrefix() : String
      {
         return this.m_dialogPrefix;
      }
      
      public function get eventID() : String
      {
         return this.m_eventId;
      }
      
      public function rsvpAndShareEvent(share:Boolean) : void
      {
         var callbackId:String = ExternalUtil.instance.registerCallback(this.constructPermissionCallback(share));
         ExternalUtil.instance.call("FarmNS.FBEventManager.getPermissionsFlash",callbackId);
      }
      
      public function constructPermissionCallback(share:Boolean) : Function
      {
         return function(fbResponse:Object):void
         {
            incentivizedEventHandler(fbResponse,share);
         };
      }
      
      private function hasPermission(permission:String) : Boolean
      {
         var result:Boolean = false;
         if(this.m_permissions.hasOwnProperty(permission))
         {
            result = this.m_permissions[permission] == this.EVENT_STATUS_GRANTED;
         }
         return result;
      }
      
      public function incentivizedEventHandler(fbPermissionsResponse:Object, share:Boolean) : void
      {
         var showShareConfirm:Boolean = false;
         this.m_permissions = fbPermissionsResponse;
         if(this.hasPermission(this.EVENT_RSVP))
         {
            this.rsvpForEvent();
         }
         if(share)
         {
            this.showMFSAndSendFeed();
         }
         else
         {
            showShareConfirm = !this.inShareOptionVariant();
            this.showConfirmationDialog(showShareConfirm);
         }
      }
      
      private function showMFSAndSendFeed(showConfirmation:Boolean = true) : void
      {
         this.postFeed(this.feedCallback);
         if(Boolean(Global.flashHotParams.hasOwnProperty("FB_EVENTS_SHOW_MFS")) && Boolean(Global.flashHotParams["FB_EVENTS_SHOW_MFS"]) && this.hasPermission(this.EVENT_INVITE))
         {
            UI.displayPopup(new MFSEventInvite(this.inviteFriendsToEvent,"Manager",MFSConstants.MFS_TYPE_EVENT_INVITE,0,14));
         }
         if(showConfirmation)
         {
            this.showConfirmationDialog(false);
         }
      }
      
      private function feedCallback(response:Object) : void
      {
      }
      
      private function rsvpForEvent() : void
      {
         ExternalUtil.instance.call("FarmNS.FBEventManager.sendEventRSVPFromFlash",this.m_eventId);
      }
      
      public function inviteFriendsToEvent(uidList:Array) : void
      {
         var callbackId:String = ExternalUtil.instance.registerCallback(this.inviteFriendCallback);
         ExternalUtil.instance.call("FarmNS.FBEventManager.inviteFriendsFromFlash",this.m_eventId,uidList,callbackId);
      }
      
      private function inviteFriendCallback(response:Object) : void
      {
      }
      
      private function showConfirmationDialog(share:Boolean) : void
      {
         var confirmationMessage:String = ZLocUtils.t("Dialogs",this.m_dialogPrefix + "_confirm_text",{
            "preEventLink":"<font color=\"#0000FF\"><a href=\"http://www.facebook.com/events/" + this.m_eventId + "\" target=\"_blank\" style=\"color:red\">",
            "postEventLink":"</a></font>"
         });
         var popupType:int = GenericPopup.TYPE_OK;
         var callback:Function = null;
         if(share)
         {
            popupType = GenericPopup.TYPE_SHARE;
            if(this.inMFSVariant())
            {
               callback = this.confirmShareHandler;
            }
            else
            {
               callback = this.confirmPostFeedHandler;
            }
         }
         UI.displayMessageWithHtml(confirmationMessage,popupType,callback);
      }
      
      private function confirmPostFeedHandler(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.postFeed(this.feedCallback);
         }
      }
      
      private function confirmShareHandler(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.showMFSAndSendFeed(false);
         }
      }
      
      private function postFeed(callback:Function) : void
      {
         FarmStatsManager.count("fb_event","inGame","shareFeed","success");
         var actionLink:Array = new Array({
            "href":Config.SN_APP_URL + "fbEventSignup.php?event=" + this.m_eventId + "&frHost=" + Global.player.uid,
            "text":ZLocUtils.t("Dialogs","FbIncentivizedEvents_actionLinkText")
         });
         var feedIconItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(Global.flashHotParams[FEED_ICON_ITEM_RUNTIME_FLAG]);
         if(!feedIconItem)
         {
            feedIconItem = Global.farmGameSettingsManager.getFarmItemByName(FEED_ICON_ITEM_FALLBACK);
         }
         var attachment:Object = {
            "media":new Array({"src":feedIconItem.getImageByName("feed")}),
            "caption":ZLocUtils.t("Dialogs",this.m_dialogPrefix + "_share_text",{"user":Global.player.firstName}),
            "description":ZLocUtils.t("Dialogs",this.m_dialogPrefix + "_share_title",{"user":Global.player.firstName}),
            "name":ZLocUtils.t("Dialogs",this.m_dialogPrefix + "_share_title",{"user":Global.player.firstName})
         };
         var autoPublish:Boolean = this.m_permissions.hasOwnProperty("publish_stream") && this.m_permissions["publish_stream"] == 1;
         (GlobalEngine.socialNetwork as FacebookSocialNetwork).streamPublishAction(attachment,actionLink,null,null,callback,autoPublish);
         if(autoPublish)
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).feedPostConfirmation({"attachment":attachment});
         }
      }
      
      public function inShareOptionVariant() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_INCENTIVIZED_EVENT) == this.SHARE_VARIANT;
      }
      
      public function inMFSVariant() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_INCENTIVIZED_EVENT_MFS) == Experiments.INCENTIVIZED_EVENTS_MFS_VARIANT;
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
