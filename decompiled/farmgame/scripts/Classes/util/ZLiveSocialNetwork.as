package Classes.util
{
   import Classes.FarmSocialNetwork;
   import Classes.Player;
   import Classes.ZLiveUser;
   import Engine.Classes.SocialNetworkUser;
   import Engine.Events.SocialNetworkEvent;
   import Engine.Utilities;
   import Managers.ToasterManager;
   import Widgets.Windows.GenericCustomAdToaster;
   import flash.external.ExternalInterface;
   
   public class ZLiveSocialNetwork extends FarmSocialNetwork
   {
      
      private static const ZLIVE_DEFAULT_PIC_PATH:String = "default.png";
      
      private static const COMING_SOON_DURATION:int = 5;
      
      private static const COMING_SOON_NAME:String = "zfeedsComingSoon";
      
      private var m_zLiveUser:ZLiveUser;
      
      private var m_zLiveFriends:Array;
      
      private var m_parameters:Object;
      
      public function ZLiveSocialNetwork(parameters:Object)
      {
         super();
         m_snid = FarmSocialNetwork.SNID_ZLIVE;
         this.m_parameters = parameters;
      }
      
      public function retrieveUserInfo() : void
      {
         var userData:Object = null;
         try
         {
            userData = ExternalInterface.call("getUserInfo");
            if(userData != null)
            {
               this.m_zLiveUser = new ZLiveUser();
               if(userData.master_id)
               {
                  this.m_zLiveUser.masterId = userData.master_id;
               }
               if(userData.snu_id)
               {
                  this.m_zLiveUser.uid = userData.snu_id;
               }
               if(userData.first_name)
               {
                  this.m_zLiveUser.firstName = userData.first_name;
               }
               if(userData.last_name)
               {
                  this.m_zLiveUser.lastName = userData.last_name;
               }
               if(userData.name)
               {
                  this.m_zLiveUser.name = userData.name;
               }
               if(userData.pic)
               {
                  this.m_zLiveUser.pic = userData.pic;
               }
               if(userData.sex)
               {
                  this.m_zLiveUser.sex = userData.sex;
               }
            }
            if(this.m_zLiveUser == null)
            {
               GlobalEngine.log("ZLive","Unable to load user info from JS...");
            }
         }
         catch(err:Error)
         {
         }
      }
      
      public function getFriendList() : void
      {
         try
         {
            this.m_zLiveFriends = ExternalInterface.call("getFriendData");
         }
         catch(err:Error)
         {
         }
         if(this.m_zLiveFriends == null)
         {
            GlobalEngine.log("ZLive","Unable to load friend data from JS, beginning to cry...");
         }
         else
         {
            dispatchEvent(new SocialNetworkEvent(SocialNetworkEvent.GET_FRIENDS_COMPLETE));
         }
      }
      
      override public function getFriendUsers() : Array
      {
         var data:Array = null;
         var i:int = 0;
         var snUser:SocialNetworkUser = null;
         var result:Array = [];
         if(this.m_zLiveFriends)
         {
            data = this.m_zLiveFriends;
            for(i = 0; i < data.length; i++)
            {
               if(data[i])
               {
                  snUser = this.toSocialNetworkUser(data[i]);
                  result.push(snUser);
               }
            }
         }
         return result;
      }
      
      override public function getLoggedInUserId() : String
      {
         var result:String = null;
         if(this.m_zLiveUser)
         {
            result = this.m_zLiveUser.uid.toString();
         }
         return result;
      }
      
      override public function getLoggedInUser() : SocialNetworkUser
      {
         return this.toSocialNetworkUser(this.m_zLiveUser);
      }
      
      override public function getLoggedInMasterId() : String
      {
         return this.m_zLiveUser.masterId;
      }
      
      protected function toSocialNetworkUser(zliveUser:Object) : SocialNetworkUser
      {
         var snUser:SocialNetworkUser = null;
         if(zliveUser)
         {
            snUser = new SocialNetworkUser(zliveUser.uid);
            if(zliveUser.hasOwnProperty("first_name"))
            {
               snUser.firstName = zliveUser.first_name;
            }
            snUser.name = zliveUser.name;
            if(null == zliveUser.pic || "" == zliveUser.pic || zliveUser.pic.indexOf(ZLIVE_DEFAULT_PIC_PATH) != -1)
            {
               snUser.picture = Global.getAssetURL(Player.NO_PROFILE_PIC_URL);
            }
            else
            {
               snUser.picture = zliveUser.pic;
            }
            snUser.gender = zliveUser.sex;
         }
         return snUser;
      }
      
      override public function sendNotification(action:String, params:Array, targetUserIds:Array) : void
      {
      }
      
      override public function streamPublish(attachment:Object, actionLink:Object, targetId:String, userMessagePrompt:String = null, closeCallback:Function = null, autoPublish:Boolean = false, userMessage:String = "") : void
      {
         var title:String = ZLocUtils.t("Dialogs","ZFeeds_title");
         var message:String = ZLocUtils.t("Dialogs","ZFeeds_body");
         ToasterManager.getInstance().add(new GenericCustomAdToaster(title,message,COMING_SOON_DURATION));
      }
      
      override public function farmRedirect(url:String, variables:Object = null, location:String = "_parent", isRelative:Boolean = true, directToTop:Boolean = false) : void
      {
         if(url.indexOf("?") != -1)
         {
            url += "&zySuid=" + getSocialNetworkId();
         }
         else
         {
            url += "?zySuid=" + getSocialNetworkId();
         }
         url += "&zySnuid=" + this.getLoggedInUserId();
         url += "&zy_user=" + this.m_parameters.zy_user;
         url += "&zy_ts=" + this.m_parameters.zy_ts;
         url += "&zy_session=" + this.m_parameters.zy_session;
         Utilities.launchURL(url,"_self",variables);
      }
   }
}

