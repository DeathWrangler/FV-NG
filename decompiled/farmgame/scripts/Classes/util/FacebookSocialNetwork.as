package Classes.util
{
   import Classes.Constants.Experiments;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.FarmSocialNetwork;
   import Display.Dialogs.GenericDialog;
   import Engine.Classes.SocialNetworkUser;
   import Engine.Events.SocialNetworkEvent;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.ToasterManager;
   import Transactions.TCancelFriendReward;
   import Transactions.TSetFeedId;
   import Widgets.Windows.FeedPostCompleteToasterWindow;
   import by.blooddy.crypto.MD5;
   import com.facebook.Facebook;
   import com.facebook.commands.friends.GetAppUsers;
   import com.facebook.commands.friends.GetFriends;
   import com.facebook.commands.users.GetInfo;
   import com.facebook.data.friends.GetAppUserData;
   import com.facebook.data.friends.GetFriendsData;
   import com.facebook.data.users.FacebookUser;
   import com.facebook.data.users.GetInfoData;
   import com.facebook.events.FacebookEvent;
   import com.facebook.facebook_internal;
   import com.facebook.net.FacebookCall;
   import com.facebook.session.DesktopSession;
   import com.facebook.session.IFacebookSession;
   import com.facebook.session.JSSession;
   import com.facebook.session.WebSession;
   import com.troyer.widget.event.WidgetControllerEvent;
   import flash.display.StageDisplayState;
   import flash.external.ExternalInterface;
   import flash.geom.Point;
   
   public class FacebookSocialNetwork extends FarmSocialNetwork
   {
      
      public static var TWO_WEEKS_IN_SECONDS:int = 2 * 7 * 24 * 60 * 60;
      
      public static var FB_FEED_AUTOPUBLISH_CAP_ACTIONCOUNT:String = "feedAutoPublishCap_count";
      
      protected var m_facebookSession:IFacebookSession;
      
      protected var m_facebook:Facebook;
      
      protected var m_waitingForLogin:Boolean = false;
      
      protected var m_facebookUser:FacebookUser;
      
      protected var m_facebookFriends:Array;
      
      protected var m_facebookAppFriends:Array;
      
      protected var m_needsLogin:Boolean = false;
      
      protected var m_userRawInfoResponse:XML = null;
      
      protected var m_checkForPublishPermissionCallback:Function;
      
      protected var m_extendPublishPermissionsDialog:GenericDialog = null;
      
      protected var m_extendedPublishPermissionsTitle:String;
      
      protected var m_extendedPublishPermissionsKingdom:String;
      
      protected var PUBLISH_PERMISSION_DIALOG_IMAGE_URL:String = "assets/dialogs/4d_elements/experms/GiftFaster.png";
      
      private var m_attachment:Object;
      
      private var m_actionLink:Object;
      
      private var m_targetId:String;
      
      private var m_userMessagePrompt:String;
      
      private var m_closeCallback:Function;
      
      private var m_autoPublish:Boolean;
      
      private var m_userMessage:String;
      
      private var m_result:Boolean;
      
      protected var m_uid:String = null;
      
      private var m_callbackObj:Object = {};
      
      public function FacebookSocialNetwork(api_key:String, secret:String)
      {
         super();
         m_snid = FarmSocialNetwork.SNID_FACEBOOK;
         var session_key:String = null;
         var flashVars:Object = GlobalEngine.getFlashVars();
         if(flashVars.fb_sig_session_key != null)
         {
            session_key = flashVars.fb_sig_session_key;
         }
         if(flashVars.master_id)
         {
            m_masterId = flashVars.master_id;
         }
         if(Boolean(flashVars.fb_sig_ss) && Boolean(flashVars.fb_sig_api_key) && Boolean(flashVars.fb_sig_session_key) && Boolean(flashVars.fb_sig_user))
         {
            this.m_facebookSession = new WebSession(flashVars.fb_sig_api_key,flashVars.fb_sig_ss,flashVars.fb_sig_session_key);
            (this.m_facebookSession as WebSession).facebook_internal::_uid = flashVars.fb_sig_user;
            this.m_facebookUser = new FacebookUser();
            this.m_facebookUser.uid = flashVars.fb_sig_user;
         }
         else if(flashVars.as_app_name)
         {
            this.m_facebookSession = new JSSession(api_key,flashVars.as_app_name);
         }
         else
         {
            this.m_facebookSession = new DesktopSession(api_key,secret);
         }
         this.m_facebookSession.session_key = session_key;
         this.m_facebook = new Facebook();
         if(flashVars.oauth_session)
         {
            this.m_needsLogin = false;
            this.m_uid = flashVars.fb_sig_user;
            m_sigTime = flashVars.fb_sig_time;
            return;
         }
         this.m_facebook.addEventListener(FacebookEvent.WAITING_FOR_LOGIN,this.onWaitingForLogin);
         this.m_facebook.addEventListener(FacebookEvent.CONNECT,this.onConnect);
         this.m_facebook.startSession(this.m_facebookSession);
         if(flashVars.fb_sig_session_key)
         {
            this.m_facebookSession.verifySession();
            this.m_needsLogin = false;
            m_sigTime = flashVars.fb_sig_time;
         }
         else
         {
            this.m_facebook.addEventListener(FacebookEvent.WAITING_FOR_LOGIN,this.onWaitingForLogin);
            this.m_facebook.addEventListener(FacebookEvent.CONNECT,this.onConnect);
            this.m_facebook.login(true);
            this.m_needsLogin = true;
         }
      }
      
      public static function setFeedId(localFeedId:String, snFeedId:String) : void
      {
         TransactionManager.addTransaction(new TSetFeedId(localFeedId,snFeedId),true);
      }
      
      public function get needsLogin() : Boolean
      {
         return this.m_needsLogin;
      }
      
      public function get facebook() : Facebook
      {
         return this.m_facebook;
      }
      
      private function onWaitingForLogin(e:FacebookEvent) : void
      {
         this.m_waitingForLogin = true;
         this.m_facebook.removeEventListener(FacebookEvent.WAITING_FOR_LOGIN,this.onWaitingForLogin);
      }
      
      public function validateLogin() : void
      {
         if(this.m_waitingForLogin)
         {
            this.m_facebookSession.refreshSession();
         }
      }
      
      private function onConnect(e:FacebookEvent) : void
      {
         if(Boolean(e) && Boolean(e.data))
         {
            dispatchEvent(new SocialNetworkEvent(SocialNetworkEvent.LOGIN_COMPLETE));
         }
         this.m_facebook.removeEventListener(FacebookEvent.CONNECT,this.onConnect);
      }
      
      public function getUser() : void
      {
         var facebookData:Object = null;
         var key:String = null;
         var getUserCall:FacebookCall = null;
         var hasUserInfo:Boolean = false;
         try
         {
            facebookData = ExternalInterface.call("getUserInfo");
            if(facebookData != null && facebookData.hasOwnProperty("uid"))
            {
               this.m_facebookUser = new FacebookUser();
               for(key in facebookData)
               {
                  if(key != "allowed_restrictions")
                  {
                     this.m_facebookUser[key] = facebookData[key];
                  }
               }
               hasUserInfo = true;
            }
         }
         catch(err:Error)
         {
         }
         if(this.m_facebookUser != null && this.m_facebookUser.uid == "")
         {
            hasUserInfo = false;
         }
         if(!hasUserInfo || this.m_facebookUser == null)
         {
            GlobalEngine.log("Facebook","Unable to load user info from JS, using REST...");
            if(!this.m_uid && this.m_facebook.uid != null)
            {
               getUserCall = this.m_facebook.post(new GetInfo([this.m_facebook.uid],["uid","name","first_name","pic_square","sex","birthday_date"]));
               getUserCall.addEventListener(FacebookEvent.COMPLETE,this.onGetUser);
            }
            else
            {
               ErrorManager.addError("Facebook uid is null in getUser",ErrorManager.ERROR_FAILED_TO_LOAD);
            }
         }
         else
         {
            dispatchEvent(new SocialNetworkEvent(SocialNetworkEvent.GET_USER_COMPLETE));
         }
         this.getExtendedPermissions();
         this.getIsAdult();
      }
      
      public function getIsAdult() : void
      {
         var flashVars:Object = null;
         var isAdult:Boolean = false;
         try
         {
            flashVars = GlobalEngine.getFlashVars();
            isAdult = "1" == flashVars.isAdult;
         }
         catch(err:Error)
         {
         }
         this.m_userIsAdult = isAdult;
      }
      
      public function checkAdultFromUserInfo() : void
      {
         var properties:XMLList = null;
         var birthdayUnparsed:String = null;
         var i:int = 0;
         var property:XML = null;
         var birthdayParsed:Number = NaN;
         var twentyOneYearsAgo:Number = NaN;
         try
         {
            if(!this.m_userIsAdult && this.m_userRawInfoResponse != null)
            {
               properties = this.m_userRawInfoResponse.children();
               birthdayUnparsed = null;
               for(i = 0; i < properties.length(); i++)
               {
                  property = properties[i];
                  if(property.name().localName == "birthday_date")
                  {
                     birthdayUnparsed = property.text().toString();
                  }
               }
               if(birthdayUnparsed != null)
               {
                  birthdayParsed = Date.parse(birthdayUnparsed);
                  if(!isNaN(birthdayParsed))
                  {
                     twentyOneYearsAgo = new Date().getTime() - Math.floor(60 * 60 * 24 * 364.25 * 21);
                     if(birthdayParsed < twentyOneYearsAgo)
                     {
                        this.m_userIsAdult = true;
                     }
                  }
               }
            }
         }
         catch(err:Error)
         {
         }
      }
      
      protected function getExtendedPermissions() : void
      {
         var uid:String = null;
         if(this.m_uid)
         {
            uid = this.m_uid;
         }
         else if(Boolean(this.m_facebookUser) && Boolean(this.m_facebookUser.uid))
         {
            uid = this.m_facebookUser.uid;
         }
         else if(this.m_facebook.uid)
         {
            uid = this.m_facebook.uid;
         }
         this.checkForPublishPermission(Number(uid),this.onGetAppPermissionComplete);
      }
      
      private function onGetAppPermissionComplete(hasPublishPermission:Boolean, hasEmailPermission:Boolean) : void
      {
         m_hasPublishPermissions = hasPublishPermission;
         m_hasEmailPermission = hasEmailPermission;
      }
      
      private function onGetUser(e:FacebookEvent) : void
      {
         if(Boolean(e) && Boolean(e.data) && GetInfoData(e.data).userCollection.getItemAt(0) != null)
         {
            this.m_facebookUser = FacebookUser(GetInfoData(e.data).userCollection.getItemAt(0));
            this.m_userRawInfoResponse = new XML(e.data.rawResult).children()[0];
            this.checkAdultFromUserInfo();
            dispatchEvent(new SocialNetworkEvent(SocialNetworkEvent.GET_USER_COMPLETE));
         }
         this.removeEventListener(FacebookEvent.COMPLETE,this.onGetUser);
      }
      
      override public function getLoggedInUserId() : String
      {
         var result:String = null;
         if(this.m_uid)
         {
            result = this.m_uid;
         }
         else if(Boolean(this.m_facebookUser) && Boolean(this.m_facebookUser.uid))
         {
            result = this.m_facebookUser.uid;
         }
         else if(this.m_facebook.uid)
         {
            result = this.m_facebook.uid;
         }
         return result;
      }
      
      override public function getLoggedInUser() : SocialNetworkUser
      {
         var snUser:SocialNetworkUser = null;
         if(null == this.m_facebookUser)
         {
            if(this.m_uid)
            {
               snUser = new SocialNetworkUser(this.m_uid,0,this.m_uid);
            }
            else
            {
               snUser = new SocialNetworkUser(this.m_facebook.uid,0,this.m_uid);
            }
         }
         else
         {
            snUser = this.toSocialNetworkUser(this.m_facebookUser);
         }
         return snUser;
      }
      
      override public function getLoggedInMasterId() : String
      {
         var result:String = null;
         if(m_masterId)
         {
            result = m_masterId;
         }
         else
         {
            result = this.getLoggedInUserId();
         }
         return result;
      }
      
      public function getFriendList() : void
      {
         var getFriendListCall:FacebookCall = null;
         try
         {
            this.m_facebookFriends = ExternalInterface.call("getFriendData");
         }
         catch(err:Error)
         {
         }
         if(this.m_facebookFriends == null && !this.m_uid)
         {
            GlobalEngine.log("Facebook","Unable to load friend data from JS, using REST...");
            getFriendListCall = this.m_facebook.post(new GetFriends());
            getFriendListCall.addEventListener(FacebookEvent.COMPLETE,this.onGetFriendList);
         }
         else
         {
            dispatchEvent(new SocialNetworkEvent(SocialNetworkEvent.GET_FRIENDS_COMPLETE));
         }
      }
      
      private function onGetFriendList(e:FacebookEvent) : void
      {
         var x:int = 0;
         var facebookFriendList:GetFriendsData = GetFriendsData(e.data);
         var friendListUID:Array = [];
         this.removeEventListener(FacebookEvent.COMPLETE,this.onGetFriendList);
         if(facebookFriendList != null)
         {
            for(x = 0; x < facebookFriendList.friends.length; x++)
            {
               friendListUID.push(facebookFriendList.friends.getItemAt(x).uid);
            }
            this.getFriends(friendListUID);
         }
      }
      
      protected function getFriends(_uidArray:Array) : void
      {
         var getFriendsCall:FacebookCall = null;
         if(!this.m_uid)
         {
            getFriendsCall = this.m_facebook.post(new GetInfo(_uidArray,["uid","name","first_name","pic_square","sex","birthday_date"]));
            getFriendsCall.addEventListener(FacebookEvent.COMPLETE,this.onGetFriends);
         }
         else
         {
            getFriendsCall.addEventListener(FacebookEvent.COMPLETE,this.onGetFriends);
         }
      }
      
      private function onGetFriends(e:FacebookEvent) : void
      {
         var i:int = 0;
         var fbUser:FacebookUser = null;
         this.m_facebookFriends = [];
         var data:GetInfoData = GetInfoData(e.data);
         if(data != null)
         {
            for(i = 0; i < data.userCollection.length; i++)
            {
               fbUser = data.userCollection.source[i] as FacebookUser;
               this.m_facebookFriends.push(fbUser);
            }
         }
         dispatchEvent(new SocialNetworkEvent(SocialNetworkEvent.GET_FRIENDS_COMPLETE));
         this.removeEventListener(FacebookEvent.COMPLETE,this.onGetFriends);
      }
      
      public function getAppFriends() : void
      {
         var getAppUsers:FacebookCall = null;
         try
         {
            this.m_facebookAppFriends = ExternalInterface.call("getAppFriendIds");
         }
         catch(err:Error)
         {
         }
         if(this.m_facebookAppFriends == null && !this.m_uid)
         {
            GlobalEngine.log("Facebook","Unable to load appFriendIds from JS, using REST...");
            getAppUsers = this.m_facebook.post(new GetAppUsers());
            getAppUsers.addEventListener(FacebookEvent.COMPLETE,this.onGetAppFriends);
         }
         else
         {
            dispatchEvent(new SocialNetworkEvent(SocialNetworkEvent.GET_APP_FRIENDS_COMPLETE));
         }
      }
      
      private function onGetAppFriends(e:FacebookEvent) : void
      {
         var data:GetAppUserData = GetAppUserData(e.data);
         if(data != null)
         {
            this.m_facebookAppFriends = data.uids;
         }
         dispatchEvent(new SocialNetworkEvent(SocialNetworkEvent.GET_APP_FRIENDS_COMPLETE));
         this.removeEventListener(FacebookEvent.COMPLETE,this.onGetAppFriends);
      }
      
      override public function getFriendUsers() : Array
      {
         var data:Array = null;
         var i:int = 0;
         var snUser:SocialNetworkUser = null;
         var result:Array = [];
         if(this.m_facebookFriends)
         {
            data = this.m_facebookFriends;
            for(i = 0; i < data.length; i++)
            {
               snUser = this.toSocialNetworkUser(data[i]);
               result.push(snUser);
            }
         }
         return result;
      }
      
      override public function getAppFriendsIds() : Array
      {
         return this.m_facebookAppFriends;
      }
      
      override public function oneToOneFeedsSupported() : Boolean
      {
         return true;
      }
      
      override public function showFeedDialog(bundleId:String, bundleData:Object, targetIds:Array, closeCallback:Function = null) : void
      {
         try
         {
            if(ExternalInterface.available)
            {
               if(Global.stage.displayState == StageDisplayState.FULL_SCREEN)
               {
                  Global.stage.displayState = StageDisplayState.NORMAL;
               }
               ExternalInterface.call("showFeedDialog",bundleId,bundleData,targetIds,closeCallback);
            }
         }
         catch(err:Error)
         {
            ErrorManager.addError("ExternalInterface exception: " + err.message);
            if(closeCallback != null)
            {
               closeCallback();
            }
         }
      }
      
      override public function shareAsLink(data:Object) : void
      {
         var statsSampleRate:int = 100;
         statsSampleRate = parseInt(GlobalEngine.getFlashVar("FEEDS_AS_LINK_STATS_SAMPLE") as String);
         if(Boolean(data) && Boolean(data.shareLink))
         {
            ExternalInterface.call("FarmNS.Request2Manager.shareAsFbLink",data);
            FarmStatsManager.sample(statsSampleRate,"link_share","success","popup");
         }
      }
      
      override public function streamPublishV2(data:Object, feedPostCallback:Function) : void
      {
         var statsSampleRate:int = 0;
         var callBackName:String = null;
         statsSampleRate = 100;
         statsSampleRate = parseInt(GlobalEngine.getFlashVar("FEEDS_V2_STATS_SAMPLE") as String);
         if(Boolean(data) && Boolean(data.showFeedDialog))
         {
            if(Boolean(data.attachment) && Boolean(data.actionLink) && Boolean(data.userMessagePrompt))
            {
               callBackName = "feedPostCallback";
               FarmStatsManager.sample(statsSampleRate,"feeds_v2","js_call","queued");
               try
               {
                  callBackName = "feedPostCallback_" + MD5.hash(data.actionLink[0].href);
               }
               catch(error:Error)
               {
                  FarmStatsManager.sample(statsSampleRate,"feeds_v2","js_call_queued","exception_queuing_callback");
               }
               ExternalInterface.addCallback(callBackName,feedPostCallback);
               this.streamPublish(data.attachment,data.actionLink,null,data.userMessagePrompt);
            }
            else
            {
               FarmStatsManager.sample(statsSampleRate,"feeds_v2","errors","invalid_feeddata");
            }
         }
         else if(Boolean(data) && Boolean(data.published))
         {
            this.feedPostConfirmation(data);
         }
         else
         {
            FarmStatsManager.sample(statsSampleRate,"feeds_v2","errors","invalid_feeddata_or_showfeed");
         }
      }
      
      override public function streamPublish(attachment:Object, actionLink:Object, targetId:String, userMessagePrompt:String = null, closeCallback:Function = null, autoPublish:Boolean = false, userMessage:String = "") : void
      {
         var date:Number = NaN;
         var currentDate:Date = null;
         var currentTimeStamp:Number = NaN;
         var twoWeeksAgo:Number = NaN;
         var statsSampleRate:int = 100;
         if(Global.player.hasPublishPermission)
         {
            autoPublish = true;
         }
         if(GlobalEngine.getFlashVar("STREAMPUBLISH_USE_PHP_SDK") as String == "true")
         {
            autoPublish = false;
            statsSampleRate = parseInt(GlobalEngine.getFlashVar("PHP_FEED_STATS_SAMPLE") as String);
            FarmStatsManager.sample(statsSampleRate,"backend_feed_publish","php_publish_failed","defaulting_to_fb_ui");
         }
         this.m_extendedPublishPermissionsTitle = "ExtendedPublishPermissions_Title";
         this.m_extendedPublishPermissionsKingdom = "ext_perms_diag";
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_EXTENDED_PERMISSIONS);
         if(variant == Experiments.USE_EXTENDENDED_PUBLISH_PERMISSION_VARIANT)
         {
            if(Global.player.hasPublishPermission)
            {
               this.streamPublishAction(attachment,actionLink,targetId,userMessagePrompt,closeCallback,autoPublish,userMessage);
            }
            else
            {
               this.m_attachment = attachment;
               this.m_actionLink = actionLink;
               this.m_targetId = targetId;
               this.m_userMessagePrompt = userMessagePrompt;
               this.m_closeCallback = closeCallback;
               this.m_autoPublish = autoPublish;
               this.m_userMessage = userMessage;
               date = Global.player.dateOfLastPublishPermissionRequest;
               currentDate = new Date();
               currentTimeStamp = currentDate.time / 1000;
               twoWeeksAgo = currentTimeStamp - TWO_WEEKS_IN_SECONDS;
               FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,this.m_extendedPublishPermissionsKingdom,"surpressed");
               this.streamPublishAction(attachment,actionLink,targetId,userMessagePrompt,closeCallback,autoPublish,userMessage);
               this.releaseTemporaryVariables();
            }
         }
         else
         {
            this.streamPublishAction(attachment,actionLink,targetId,userMessagePrompt,closeCallback,autoPublish,userMessage);
         }
      }
      
      override public function feedPostConfirmation(feedData:Object) : void
      {
         var imageUrl:String = null;
         var imageFullUrl:String = null;
         var asset_url:String = null;
         var statsSampleRate:int = parseInt(GlobalEngine.getFlashVar("PHP_FEED_STATS_SAMPLE") as String);
         var showFlyOut:String = GlobalEngine.getFlashVar("SHOW_FEED_POSTING_CONFIRMATION_DIALOG") as String;
         FarmStatsManager.sample(statsSampleRate,"backend_feed_publish","php_publish","success",showFlyOut);
         if(showFlyOut == "true")
         {
            imageUrl = "";
            if(Boolean(feedData) && Boolean(feedData.attachment) && Boolean(feedData.attachment.media) && Boolean(feedData.attachment.media[0]) && Boolean(feedData.attachment.media[0]["src"]))
            {
               imageFullUrl = feedData.attachment.media[0]["src"];
               if(Boolean(imageFullUrl) && imageFullUrl != "")
               {
                  asset_url = GlobalEngine.getFlashVar("asset_url") as String;
                  imageUrl = imageFullUrl.replace(asset_url,"");
               }
            }
            ToasterManager.getInstance().togglePause(false);
            ToasterManager.getInstance().add(new FeedPostCompleteToasterWindow("Feed posted!",imageUrl,new Point(0,0)));
         }
      }
      
      public function publishResultsFromTransaction(feedData:Object, callback:Function = null) : void
      {
         if(feedData.showFeedDialog)
         {
            this.postFeedOnFrontend(feedData,callback);
         }
         else if(feedData.published)
         {
            GlobalEngine.socialNetwork.feedPostConfirmation(feedData);
            if(callback != null)
            {
               callback(true);
            }
         }
         else if(callback != null)
         {
            callback(false);
         }
      }
      
      private function postFeedOnFrontend(feedData:Object, callback:Function) : void
      {
         var targetId:String = null;
         var callbackName:String = null;
         var externalFailed:Boolean = false;
         if(Boolean(feedData) && Boolean(feedData.attachment) && Boolean(feedData.actionLink) && Boolean(feedData.userMessagePrompt))
         {
            try
            {
               callbackName = "feedPostCallback_" + MD5.hash(feedData.actionLink[0].href);
               ExternalInterface.addCallback(callbackName,this.streamPublishCallback);
               this.m_callbackObj[callbackName] = {
                  "feedData":feedData,
                  "callback":callback
               };
            }
            catch(e:Error)
            {
               externalFailed = true;
            }
            targetId = feedData["targetId"];
            GlobalEngine.socialNetwork.streamPublish(feedData.attachment,feedData.actionLink,targetId,feedData.userMessagePrompt);
            if(externalFailed && callback != null)
            {
               callback(true);
            }
         }
         else if(callback != null)
         {
            callback(false);
         }
      }
      
      private function streamPublishCallback(data:Object) : void
      {
         var postSuccessful:Boolean = false;
         var callback:Function = null;
         var feedData:Object = null;
         if(data)
         {
            if(data.callBackName)
            {
               ExternalInterface.addCallback(data.callBackName,null);
               if(this.m_callbackObj[data.callBackName])
               {
                  callback = this.m_callbackObj[data.callBackName]["callback"];
                  feedData = this.m_callbackObj[data.callBackName]["feedData"];
                  this.m_callbackObj[data.callbackName] = null;
               }
            }
            if(data.result)
            {
               switch(data.result)
               {
                  case "posted":
                     postSuccessful = true;
                     break;
                  case "closed":
                  case "skipped":
                  default:
                     this.cancelFriendReward(feedData);
               }
            }
         }
         if(callback != null)
         {
            callback(postSuccessful);
         }
      }
      
      private function cancelFriendReward(feedData:Object) : void
      {
         if(Boolean(feedData) && Boolean(feedData.rewardUrl))
         {
            TransactionManager.addTransaction(new TCancelFriendReward([feedData.rewardUrl]));
         }
      }
      
      private function onExtendedPublishPermissionDialogAction(result:Boolean) : void
      {
         if(this.m_extendPublishPermissionsDialog)
         {
            this.m_extendPublishPermissionsDialog.destroy();
            this.m_extendPublishPermissionsDialog = null;
         }
         if(result)
         {
            this.m_result = true;
            FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,this.m_extendedPublishPermissionsKingdom,"ok");
            FarmStatsManager.count("extended_permissions","opt-in","fb_dialog_shown");
            this.showStreamPermissions(this.showStreamPermissionCallback);
         }
      }
      
      private function onExtendedPublishPermissionDialogClose(event:WidgetControllerEvent) : void
      {
         if(this.m_result == false)
         {
            FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,this.m_extendedPublishPermissionsKingdom,"close");
            if(Global.stage.displayState == StageDisplayState.FULL_SCREEN)
            {
               Global.stage.displayState = StageDisplayState.NORMAL;
            }
            this.streamPublishAction(this.m_attachment,this.m_actionLink,this.m_targetId,this.m_userMessagePrompt,this.m_closeCallback,this.m_autoPublish,this.m_userMessage);
            this.releaseTemporaryVariables();
         }
      }
      
      private function showStreamPermissionCallback() : void
      {
         this.streamPublishAction(this.m_attachment,this.m_actionLink,this.m_targetId,this.m_userMessagePrompt,this.m_closeCallback,true,this.m_userMessage);
         this.releaseTemporaryVariables();
      }
      
      private function releaseTemporaryVariables() : void
      {
         this.m_attachment = null;
         this.m_actionLink = null;
         this.m_targetId = null;
         this.m_userMessagePrompt = null;
         this.m_closeCallback = null;
         this.m_userMessage = null;
      }
      
      public function streamPublishAction(attachment:Object, actionLink:Object, targetId:String, userMessagePrompt:String = null, closeCallback:Function = null, autoPublish:Boolean = false, userMessage:String = "") : void
      {
         var externalCallResult:String = null;
         var jsStreamPublishFunctionName:String = null;
         try
         {
            if(ExternalInterface.available)
            {
               if(Global.stage.displayState == StageDisplayState.FULL_SCREEN && userHasStreamPermissions() == false)
               {
                  Global.stage.displayState = StageDisplayState.NORMAL;
               }
               this.m_extendedPublishPermissionsKingdom = "post_feed";
               FarmStatsManager.sample(100,StatsTrackingConstants.DIALOG_FEED_SNAPI,this.m_extendedPublishPermissionsKingdom,"overallfunc_called");
               externalCallResult = "0";
               jsStreamPublishFunctionName = "streamPublish";
               externalCallResult = ExternalInterface.call(jsStreamPublishFunctionName,attachment,actionLink,targetId,userMessagePrompt,autoPublish,userMessage);
               FarmStatsManager.sample(100,StatsTrackingConstants.DIALOG_FEED_SNAPI,this.m_extendedPublishPermissionsKingdom,"oldfunction_called");
               if(externalCallResult != null)
               {
                  FarmStatsManager.count("FV_FEED_ISSUE","FacebookSocialNetwork.streamPublishAction","externalInterface.call_result",externalCallResult);
               }
               else
               {
                  FarmStatsManager.count("FV_FEED_ISSUE","FacebookSocialNetwork.streamPublishAction","externalInterface.call_result","null");
               }
            }
            else
            {
               FarmStatsManager.count("FV_FEED_ISSUE","FacebookSocialNetwork.streamPublishAction","externalInterface.available_fail");
            }
         }
         catch(err:Error)
         {
            ErrorManager.addError("ExternalInterface exception: " + err.message);
            if(closeCallback != null)
            {
               closeCallback();
            }
         }
      }
      
      override public function showStreamPermissions(callback:Function = null, perms:String = "") : void
      {
         super.showStreamPermissions(callback);
         try
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("showStreamPermissions",perms);
            }
         }
         catch(err:Error)
         {
            ErrorManager.addError("ExternalInterface exception: " + err.message);
         }
      }
      
      override public function emailSupported() : Boolean
      {
         return true;
      }
      
      public function showEmailPermissionWithSource(callback:Function = null, permissionRequestSource:Number = 0) : void
      {
         super.showEmailPermission(callback);
         try
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("showEmailPermission",permissionRequestSource);
            }
         }
         catch(err:Error)
         {
            ErrorManager.addError("ExternalInterface exception: " + err.message);
         }
      }
      
      override public function bookmarkSupported() : Boolean
      {
         return true;
      }
      
      override public function showBookmarkDialog() : void
      {
         try
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("showBookmarkDialog");
            }
         }
         catch(err:Error)
         {
            ErrorManager.addError("ExternalInterface exception: " + err.message);
         }
      }
      
      protected function toSocialNetworkUser(fbUser:Object) : SocialNetworkUser
      {
         var snUser:SocialNetworkUser = null;
         if(fbUser.hasOwnProperty("uid") == true)
         {
            snUser = new SocialNetworkUser(fbUser.uid,0,fbUser.uid);
            snUser.firstName = fbUser.first_name;
            snUser.name = fbUser.name;
            snUser.picture = fbUser.pic_square;
            snUser.gender = fbUser.sex;
         }
         else
         {
            snUser = new SocialNetworkUser("0");
         }
         return snUser;
      }
      
      public function checkForPublishPermission(uid:*, callback:Function = null) : void
      {
         this.m_checkForPublishPermissionCallback = callback;
         try
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.addCallback("onCheckForPublishPermissionComplete",this.onCheckForPublishPermissionComplete);
               ExternalInterface.call("checkForPublishPermission",uid);
            }
         }
         catch(err:Error)
         {
            ErrorManager.addError("ExternalInterface exception: " + err.message);
         }
      }
      
      public function onCheckForPublishPermissionComplete(hasPublishPermission:Boolean, hasEmailPermission:Boolean) : void
      {
         if(this.m_checkForPublishPermissionCallback != null)
         {
            m_hasPublishPermissions = hasPublishPermission;
            m_hasEmailPermission = hasEmailPermission;
            this.m_checkForPublishPermissionCallback(hasPublishPermission,hasEmailPermission);
         }
      }
   }
}

