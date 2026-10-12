package Classes.util
{
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import Managers.EmailManager;
   import Managers.FarmStatsManager;
   import Managers.FreezeManager;
   
   public class FarmFacebookSocialNetwork extends FacebookSocialNetwork
   {
      
      private static const NUM_QUEUED_ACTIONS_REDIRET:int = 5;
      
      private static const FB_REQUESTS_URL:String = "outbound.php?action=redirectFBRequests";
      
      private static var m_autoPublishEnabled:Boolean = false;
      
      private var m_publishFeedStoryCallback:Function;
      
      public function FarmFacebookSocialNetwork(api_key:String, secret:String)
      {
         super(api_key,secret);
      }
      
      public static function setAutoPublishEnabled(isEnabled:Boolean) : void
      {
         m_autoPublishEnabled = isEnabled;
      }
      
      public static function triggerRequestsRedirectPopup(numRequests:int) : void
      {
         var numRequestsString:String = null;
         if(numRequests <= 0)
         {
            numRequestsString = "some";
         }
         else
         {
            numRequestsString = numRequests.toString();
         }
         var popup:GenericPopup = new GenericPopup(ZLocUtils.t("Dialogs","RequestsToAccept",{"quantity":numRequestsString}),GenericPopup.TYPE_ACCEPTCANCEL,onRedirectToRequests);
         UI.displayPopup(popup,true,"requestRedirect",true);
      }
      
      private static function onRedirectToRequests(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            Global.farmSocialNetwork.redirectTop(FarmFacebookSocialNetwork.FB_REQUESTS_URL);
         }
      }
      
      override public function farmRedirect(url:String, variables:Object = null, location:String = "_parent", isRelative:Boolean = true, directToTop:Boolean = false) : void
      {
         if(GlobalEngine.getFlashVar("FEATURE_IFRAME"))
         {
            if(location == "_parent")
            {
               location = "_top";
               directToTop = true;
            }
         }
         if(isRelative)
         {
            url = this.prependUrl(url,directToTop);
         }
         if(Global.player.avatar.getStateMachine().getNumActionsPending() >= NUM_QUEUED_ACTIONS_REDIRET)
         {
            UI.displayMessage(ZLocUtils.t("FarmGame","LeaveGame_PendingActions"),GenericPopup.TYPE_ACCEPTCANCEL,function(event:GenericPopupEvent):void
            {
               if(event.button == GenericPopup.ACCEPT)
               {
                  FarmGameUtil.launchURL(url,location,variables,directToTop);
               }
            });
         }
         else
         {
            FarmGameUtil.launchURL(url,location,variables,directToTop);
         }
      }
      
      override public function redirect(url:String, variables:Object = null, location:String = "_parent", isRelative:Boolean = true) : void
      {
         if(GlobalEngine.getFlashVar("FEATURE_IFRAME"))
         {
            if(location == "_parent")
            {
               location = "_top";
            }
         }
         super.redirect(url,variables,location,isRelative);
      }
      
      private function prependUrl(url:String, directToTop:Boolean) : String
      {
         if(GlobalEngine.getFlashVar("iframeRedirect") > 0 && !directToTop)
         {
            url = Config.BASE_PATH + url;
         }
         else
         {
            url = Config.SN_APP_URL + url;
         }
         return url;
      }
      
      override public function getDefaultFeedImages() : Array
      {
         var setIndex:int = 0;
         var index:int = 0;
         var setSubIndex:int = 0;
         var images:Array = [];
         if(GlobalEngine.getFlashVar("levelUpFeed1") != null || GlobalEngine.getFlashVar("levelUpFeed2") != null)
         {
            setIndex = Math.round(Utilities.randBetween(1,8));
            switch(setIndex)
            {
               case 1:
               case 8:
                  images.push({
                     "src":Global.getAssetURL("assets/newsfeed/levelup_singleframe_01.png"),
                     "href":"{SN_APP_URL}{creative:1}index.php"
                  });
                  break;
               case 2:
                  images.push({
                     "src":Global.getAssetURL("assets/newsfeed/levelup_singleframe_02.png"),
                     "href":"{SN_APP_URL}{creative:2}index.php"
                  });
                  break;
               case 3:
                  images.push({
                     "src":Global.getAssetURL("assets/newsfeed/levelup_singleframe_03.png"),
                     "href":"{SN_APP_URL}{creative:3}index.php"
                  });
                  break;
               case 4:
                  images.push({
                     "src":Global.getAssetURL("assets/newsfeed/levelup_singleframe_04.png"),
                     "href":"{SN_APP_URL}{creative:4}index.php"
                  });
                  break;
               case 5:
                  images.push({
                     "src":Global.getAssetURL("assets/newsfeed/levelup_singleframe_05.png"),
                     "href":"{SN_APP_URL}{creative:5}index.php"
                  });
                  break;
               case 6:
                  images.push({
                     "src":Global.getAssetURL("assets/newsfeed/levelup_singleframe_06.png"),
                     "href":"{SN_APP_URL}{creative:6}index.php"
                  });
                  break;
               case 7:
                  images.push({
                     "src":Global.getAssetURL("assets/newsfeed/levelup_singleframe_07.png"),
                     "href":"{SN_APP_URL}{creative:7}index.php"
                  });
            }
         }
         else
         {
            index = Math.round(Utilities.randBetween(0,2));
            if(index <= 1)
            {
               images.push({
                  "src":Global.getAssetURL("assets/newsfeed/levelup_singleframe_01.png"),
                  "href":"{SN_APP_URL}{creative:1}index.php"
               });
            }
            else
            {
               setSubIndex = Math.round(Utilities.randBetween(0,1));
               switch(setSubIndex)
               {
                  case 0:
                     images.push({
                        "src":Global.getAssetURL("assets/newsfeed/levelup_singleframe_02.png"),
                        "href":"{SN_APP_URL}{creative:0}index.php"
                     });
                     break;
                  case 1:
                     images.push({
                        "src":Global.getAssetURL("assets/newsfeed/levelup_singleframe_03.png"),
                        "href":"{SN_APP_URL}{creative:2}index.php"
                     });
               }
            }
         }
         return images;
      }
      
      override public function onFeedClosed() : void
      {
         super.onFeedClosed();
         FreezeManager.thaw();
         if(this.m_publishFeedStoryCallback != null)
         {
            this.m_publishFeedStoryCallback();
         }
      }
      
      override public function onPermissionDialogClosed(userAccepted:Boolean) : void
      {
         super.onPermissionDialogClosed(userAccepted);
         if(userAccepted)
         {
            FarmStatsManager.count("streamPermissions","accept");
         }
         else
         {
            FarmStatsManager.count("streamPermissions","cancel");
         }
         Global.player.checkSeenExtendedPermissions(Global.player.SEEN_EXTENDED_PERMISSIONS_ANY);
      }
      
      public function onEmailPermissionDialogClosedWithSource(userAccepted:Boolean, permissionRequestSource:Number = 0) : void
      {
         super.onEmailPermissionDialogClosed(userAccepted);
         EmailManager.onEmailPermissionDialogClosed(userAccepted,permissionRequestSource);
      }
      
      override public function streamPublish(attachment:Object, actionLink:Object, targetId:String, userMessagePrompt:String = null, closeCallback:Function = null, autoPublish:Boolean = false, userMessage:String = "") : void
      {
         super.streamPublish(attachment,actionLink,targetId,userMessagePrompt,closeCallback,autoPublish,userMessage);
      }
      
      override public function publishFeedStory(action:String, bundleData:Object, targetId:Array, oneLine:Boolean, closeCallback:Function = null, feedTimeout:int = 0, askPermissions:Boolean = false, autoPublish:Boolean = false, userMessage:String = "") : void
      {
         this.m_publishFeedStoryCallback = closeCallback;
         if(!m_autoPublishEnabled)
         {
            askPermissions = false;
         }
         super.publishFeedStory(action,bundleData,targetId,oneLine,closeCallback,feedTimeout,askPermissions,autoPublish,userMessage);
      }
      
      override public function userHasStreamPermissions() : Boolean
      {
         return m_hasPublishPermissions;
      }
   }
}

