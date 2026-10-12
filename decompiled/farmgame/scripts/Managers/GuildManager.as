package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Constants.ZLocConstants;
   import Classes.ImageLoader;
   import Classes.MatchMaking.MatchMakingManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.HUD.HUD;
   import Display.HUD.HudGuildCreationButton;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.GuildAddMembersWindow;
   import Widgets.Windows.GuildConsumableCraftWindow;
   import Widgets.Windows.GuildCreationWindow;
   import Widgets.Windows.GuildEditWindow;
   import Widgets.Windows.GuildListWindow;
   import Widgets.Windows.GuildMainWindow;
   import Widgets.Windows.GuildMessageWindow;
   import Widgets.Windows.GuildViewWindow;
   import Widgets.Windows.GuildWelcomeWindow;
   import com.adobe.serialization.json.JSON;
   import flash.display.DisplayObject;
   import flash.events.DataEvent;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import mx.utils.StringUtil;
   
   public class GuildManager extends BaseFeatureManager
   {
      
      public static const SERVICE_NAME:String = "GuildService";
      
      public static const NOT_SEEN:int = -1;
      
      public static const NOT_GRANTED:int = 0;
      
      public static const GRANTED:int = 1;
      
      public static const NON_MEMBER:int = 0;
      
      public static const MEMBER:int = 1;
      
      public static const LEADER:int = 2;
      
      public static const OWNER:int = 3;
      
      public static const CREATOR:int = 4;
      
      public static const FEATURE_NAME:String = "FVGuild";
      
      private static const coopXML:Class = GuildManager_coopXML;
      
      public static const featureXML:XML = XML(new coopXML());
      
      public static const TEMP_FO_GUILD_OB_POINTS:String = featureXML.child("tempFoGuildOBPoints");
      
      public static const TICKET_TO_CREATE_GUILD:String = "1";
      
      public static const MEMBERSHIP_STATUS:String = "2";
      
      public static const CURRENT_GUILD_ID:String = "3";
      
      public static const OLD_GUILD_IDS_ARRAY:String = "4";
      
      public static const MEMBERSHIP_STATUS_CHANGED:String = "5";
      
      public static const ALREADY_INVITED_FRIENDS:String = "6";
      
      private static const HUD_GUILD_ASSET:String = "assets/dialogs/Coop2019/FV_hud_Coop2019.swf";
      
      private static var m_initialized:Boolean = false;
      
      private static const WINDOW_CREATE:String = "create";
      
      private static const WINDOW_WELCOME:String = "welcome";
      
      private static const WINDOW_VIEW:String = "view";
      
      private static const WINDOW_MFS:String = "mfs";
      
      public static const COLLECT_TIME_KEY:String = "ctk";
      
      public static const DEFAULT_THROTTLE_TIME:int = 86400;
      
      public static const THROTTLE_TIME_ARRAY:Array = [120,120,120];
      
      public static const SERVICE_FUNC_COLLECT:String = "collectConsumable";
      
      public static const SERVICE_FUNC_REQUEST_KEY:String = "requestKey";
      
      public static const SERVICE_FUNC_GIVE_KEY:String = "giveKey";
      
      public static const SERVICE_FUNC_SEND_MSG:String = "sendMsgToGuild";
      
      public static const SERVICE_FUNC_INVITE_FRIENDS:String = "inviteFriends";
      
      public static const FLAG_GUILD_LIST_DATA_RECEIVED:String = "guildListDataReceived";
      
      public static const TEMP_FO_GUILd_LIST_INFO:String = "guildListInfo";
      
      public static const TEMP_FO_GUILd_VIEW_INFO:String = "GuildViewInfo";
      
      public static const TEMP_FO_GUILd_MEMBERS_INFO:String = "MembersBlob";
      
      public static const TEMP_FO_GUILD_CHAT_INFO:String = "ChatBlob";
      
      public static const TEMP_FO_GUILd_INVITES_INFO:String = "invitesBlob";
      
      public static const TEMP_FO_JOIN_REQUEST_BY_PLAYER:String = "joinReqByPlayer";
      
      public static const TEMP_FO_JOIN_REQUEST_TO_GUILD:String = "joinReqToGuild";
      
      public static const TEMP_FO_GUILD_NOTIFICATION_INFO:String = "NotificationBlob";
      
      public static const TEMP_FO_FRIENDS_DATA:String = "friendsData";
      
      public static const TEMP_FO_GUILD_TOTAL_POINTS:String = "GuildTotalPoints";
      
      public static const MAX_GUILD_KEY_CAP:int = 90;
      
      public static const GUILD_KEY_ASK_TIME_KEY:String = "lastAskTimeforGuildKey";
      
      public static const THROTTLE_TIME_FOR_ASK_GUILD_KEY:Number = 14400;
      
      public static const MAX_REQUESTED_GUILD_KEY_CAP:int = 5;
      
      public static const PLAYER_GUILD_POINTS:String = "PlayerGuildPoints";
      
      public static const TOTAL_GUILD_POINTS:String = "guildPoints";
      
      public static const GUILD_IGNORE_COUPON:String = "GUILD_IGNORE_COUPON";
      
      private static const GuildUIFiles:Array = ["assets/dialogs/Coop2019/Banner.jpg","assets/dialogs/Coop2019/FV_Coop2019.swf","assets/dialogs/Coop2019/FV_Coop2019_Add.swf","assets/dialogs/Coop2019/FV_Coop2019_Craft.swf","assets/dialogs/Coop2019/FV_Coop2019_Details.swf","assets/dialogs/Coop2019/FV_Coop2019_MainUI.swf","assets/dialogs/Coop2019/FV_Coop2019_Properties.swf",featureXML.child("guildEventDetailWindow"),featureXML.child("guildEventBuildingRewardWindow"),featureXML.child("guildEventMainWindow"),featureXML.child("guildEventMapWindow"),featureXML.child("orderSelectionWindow"),featureXML.child("guildEventMilestoneRewardWindow")];
      
      public static const COMPLETED_NOTIFICATION_LOADING:String = "COMPLETED_NOTIFICATION_LOADING";
      
      public static const COMPLETED_CHAT_HISTORY_LOADING:String = "COMPLETED_CHAT_HISTORY_LOADING";
      
      private static const ZRUNTIME_KEY_GUILD_DATA_REFRESH_TIME:String = "GUILD_DATA_REFRESH_TIME";
      
      public const FEATURE_OPTIONS_KEY:String = "FVGuild";
      
      private var m_assetPaths:Object = null;
      
      protected var m_staticData:Object;
      
      public var m_welcomeWindow:GuildWelcomeWindow;
      
      public var m_loadedUserBlob:Boolean = false;
      
      public var m_guildViewWindow:GuildViewWindow;
      
      public var m_guildCreateWindow:GuildCreationWindow;
      
      public var m_guildMainWindow:GuildMainWindow;
      
      public var m_guildEditWindow:GuildEditWindow;
      
      public var m_guildConsumableCraftWindow:GuildConsumableCraftWindow;
      
      public const consumableCodeArray:Array = ["6sg3","9bal","8a1d"];
      
      public const consumablePkgArray:Array = ["pkg_clantoken_1","pkg_clantoken_3","pkg_clantoken_5"];
      
      public const consumableReqArray:Array = ["1","3","5"];
      
      private var m_withFC:Boolean = false;
      
      private var m_receivedHelp:Boolean = false;
      
      private var m_createGuildWaitingDialog:GenericPopup;
      
      private var m_editGuildWaitingDialog:GenericPopup;
      
      private var m_waitingDialog:GenericPopup = null;
      
      private var m_guildListWaitingDialog:GenericPopup;
      
      private var m_guildJoinWaitingDialog:GenericPopup;
      
      public var m_guildListWindow:GuildListWindow;
      
      private var m_timer:Timer;
      
      private var m_guildAddMembersWindow:GuildAddMembersWindow;
      
      private var m_mainWindowWaitingDiaog:GenericPopup;
      
      private var m_searchGuildWaitingDialog:GenericPopup;
      
      private var m_lastNotificationType:String = "";
      
      private var m_memberPicMap:Object = {};
      
      private var m_memberNameMap:Object = {};
      
      public const COUNT_ARRAY:Array = [[7,0,0],[8,13,0],[10,15,10]];
      
      private var m_guildCreationHud:HudGuildCreationButton;
      
      private var m_scratch_Timer:Timer;
      
      private var m_scratchResult:Object;
      
      public function GuildManager(featureName:String, featureConfig:XML = null)
      {
         super(featureName,featureConfig);
      }
      
      public static function get GUILD_LOGO_IMAGE_ARRAY() : Array
      {
         var resultArray:Array = [];
         for(var index:int = 1; index <= 12; index++)
         {
            resultArray[index] = "assets/newsfeed/co-opicon" + index.toString() + ".png";
         }
         return resultArray;
      }
      
      private static function onUrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
      }
      
      public static function getInstance(featureName:String = "FVGuild") : GuildManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,GuildManager) as GuildManager;
      }
      
      public function updateUserGuildData() : void
      {
         var imageUrl:String = null;
         var image:String = null;
         var i:int = 0;
         var featureData:Object = this.getFeatureData();
         if(featureData[TICKET_TO_CREATE_GUILD] == NOT_SEEN)
         {
            if(this.isScratchPeriodOver())
            {
               featureData[TICKET_TO_CREATE_GUILD] = NOT_GRANTED;
               setFeatureData(featureData);
            }
         }
         else if(featureData[TICKET_TO_CREATE_GUILD] == GRANTED)
         {
         }
         this.getUserGuildBlob();
         this.getAllJoinRequestsByPlayer();
         this.getRecommondedGuildData();
         for each(image in GuildUIFiles)
         {
            imageUrl = Global.getAssetURL(image);
            ImageLoader.getInstance(imageUrl).getContent(onUrlLoaded);
         }
         for(i = 1; i <= 12; i++)
         {
            imageUrl = GUILD_LOGO_IMAGE_ARRAY[i];
            imageUrl = Global.getAssetURL(imageUrl);
            ImageLoader.getInstance(imageUrl).getContent(onUrlLoaded);
         }
         if(this.eventManager.hasUserStartedCurrentEvent() && GuildEventManager.getTimeLeftForEventStart() < 0)
         {
            GuildEventManager.getInstance().grantAllPendingRewards();
         }
         this.eventManager.checkAndGrantAllPendingRewardsFromPreviousGuild();
      }
      
      public function setupGuildCreationHud() : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         this.m_guildCreationHud = new HudGuildCreationButton(HUD_GUILD_ASSET,m_featureName);
         Global.hud.setUpHudGuildCreationButton(this.m_guildCreationHud as HudGuildCreationButton);
      }
      
      public function getRecommondedGuildData() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getRecommondedGuildData",this.onGetRecommondedGuildData,[m_featureName]),true);
      }
      
      public function onGetRecommondedGuildData(result:Object) : void
      {
         if(Boolean(result) && Boolean(result["data"]))
         {
            Global.player.setSeenFlag(FLAG_GUILD_LIST_DATA_RECEIVED,true,true);
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILd_LIST_INFO,result["data"]);
            if(this.m_guildListWaitingDialog)
            {
               this.m_guildListWaitingDialog.close();
               this.m_guildListWaitingDialog = null;
               this.openGuildListWindow();
            }
         }
         else
         {
            this.getRecommondedGuildData();
            if(this.m_guildListWaitingDialog)
            {
               this.m_guildListWaitingDialog.close();
               this.m_guildListWaitingDialog = null;
               this.DisplayErrorDialog();
            }
         }
      }
      
      public function getAllJoinRequestsByPlayer() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getAllJoinRequestsByPlayer",this.onGetAllJoinRequestsByPlayer,[m_featureName]),true);
      }
      
      public function onGetAllJoinRequestsByPlayer(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("data"))
         {
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_JOIN_REQUEST_BY_PLAYER,result["data"]);
         }
      }
      
      public function getAllJoinRequestsToGuild() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getAllJoinRequestsToGuild",this.onGetAllJoinRequestsToGuild,[m_featureName]),true);
      }
      
      public function onGetAllJoinRequestsToGuild(result:Object) : void
      {
         if(result)
         {
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_JOIN_REQUEST_TO_GUILD,result["data"]);
            if(this.getJoinRequestsCount() > 0)
            {
               this.m_guildCreationHud.notifText = "New join request";
            }
         }
      }
      
      public function getFriendsData() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getFriendsData",this.onGetFriendsData,[m_featureName]),true);
      }
      
      public function onGetFriendsData(result:Object) : void
      {
         if(result)
         {
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_FRIENDS_DATA,result["data"]);
         }
      }
      
      public function openGuildListWindow() : void
      {
         var guildListInfo:Object = null;
         var message:String = null;
         if(this.m_guildMainWindow)
         {
            this.m_guildMainWindow.close();
         }
         if(this.m_welcomeWindow)
         {
            this.m_welcomeWindow.close();
         }
         if(true || Global.player.getSeenFlag(FLAG_GUILD_LIST_DATA_RECEIVED))
         {
            guildListInfo = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILd_LIST_INFO);
            this.m_guildListWindow = new GuildListWindow(m_featureName,"assets/dialogs/Coop2019/FV_Coop2019_List.swf",guildListInfo);
            UI.displayPopup(this.m_guildListWindow);
         }
         else
         {
            message = "Getting few popular clans ...";
            this.m_guildListWaitingDialog = UI.displayMessage(message,GenericPopup.TYPE_MODAL,null,"",true);
         }
      }
      
      public function DisplayErrorDialog() : void
      {
         var message:String = "Some network error occurred, Please try again later";
         UI.displayMessage(message,GenericPopup.TYPE_OK,null,"",true);
      }
      
      public function showUI() : void
      {
         var guildViewData:Object = null;
         var msg:String = null;
         if(!m_initialized)
         {
            this.initialize();
         }
         var guildData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,m_featureName);
         if(guildData)
         {
            if(guildData[MEMBERSHIP_STATUS] == NON_MEMBER)
            {
               this.m_welcomeWindow = new GuildWelcomeWindow(m_featureName,this.mainWindowURL);
               UI.displayPopup(this.m_welcomeWindow);
               FarmStatsManager.count(featureXML.child("statCounter"),"welcome","welcome_ui","open","impression");
            }
            else
            {
               guildViewData = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILd_VIEW_INFO);
               if(guildViewData)
               {
                  this.m_guildMainWindow = new GuildMainWindow(m_featureName,"assets/dialogs/Coop2019/FV_Coop2019_MainUI.swf",guildViewData);
                  UI.displayPopup(this.m_guildMainWindow,false);
                  FarmStatsManager.count(featureXML.child("statCounter"),"main","main_ui","open","impression");
                  if(this.eventManager.isEventActive())
                  {
                     GuildEventManager.getInstance().openGuildEventMainWindow();
                     FarmStatsManager.count(featureXML.child("statCounter"),"event","event_ui","open","impression");
                  }
               }
               else
               {
                  msg = "Getting your clan membership status ...";
                  this.m_mainWindowWaitingDiaog = UI.displayMessage(msg,GenericPopup.TYPE_MODAL,null,"",true);
                  FarmStatsManager.count(featureXML.child("statCounter"),"main","main_ui","waiting","impression");
               }
            }
         }
      }
      
      public function showWelcomeUI() : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         this.m_welcomeWindow = new GuildWelcomeWindow(m_featureName,this.mainWindowURL);
         UI.displayPopup(this.m_welcomeWindow);
         FarmStatsManager.count("GrapeEscape","feature_ui","main_ui","impression");
      }
      
      public function initialize() : void
      {
         this.loadStaticData();
      }
      
      private function loadStaticData() : void
      {
         var asset:XML = null;
         this.m_staticData = {};
         this.m_staticData.initialGrant = 0;
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         if(featureXML != null)
         {
            m_initialized = true;
            this.m_assetPaths = {};
            if(featureXML.assets != "")
            {
               for each(asset in featureXML.assets.asset)
               {
                  this.m_assetPaths[asset.@name] = asset.@path.toString();
               }
            }
            if(featureXML.hasOwnProperty("initialGrant"))
            {
               this.m_staticData.initialGrant = featureXML.initialGrant.toString();
            }
         }
      }
      
      public function get mainWindowURL() : String
      {
         return this.m_assetPaths[WINDOW_WELCOME];
      }
      
      public function get createWindowURL() : String
      {
         return this.m_assetPaths[WINDOW_CREATE];
      }
      
      public function get guildViewWindowURL() : String
      {
         return this.m_assetPaths[WINDOW_VIEW];
      }
      
      public function get autoGrantConsumableCount() : int
      {
         return 7;
      }
      
      public function isScratchPeriodOver() : Boolean
      {
         return false;
      }
      
      public function getFeatureData() : Object
      {
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,m_featureName);
         if(!featureData)
         {
            featureData = {};
            featureData[TICKET_TO_CREATE_GUILD] = NOT_SEEN;
            featureData[MEMBERSHIP_STATUS] = NON_MEMBER;
            featureData[CURRENT_GUILD_ID] = -1;
            featureData[OLD_GUILD_IDS_ARRAY] = {};
            featureData["keyCount"] = 0;
            setFeatureData(featureData);
            FeatureOptionsInventoryManager.getInstance().addCount(this.consumableCodeArray[0],int(this.autoGrantConsumableCount));
         }
         return featureData;
      }
      
      public function getUserGuildBlob() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getUserGuildBlob",this.onGetUserGuildBlob,[]),true);
      }
      
      public function onGetUserGuildBlob(result:Object = null) : void
      {
         var featureData:Object = null;
         var guildName:String = null;
         var invitesInfo:Object = null;
         if(result != null)
         {
            this.m_loadedUserBlob = true;
            featureData = this.getFeatureData();
            if(result.hasOwnProperty("role"))
            {
               if(result["role"] == "none")
               {
                  featureData[MEMBERSHIP_STATUS] = NON_MEMBER;
                  featureData[CURRENT_GUILD_ID] = -1;
                  if(this.m_timer)
                  {
                     this.m_timer.removeEventListener(TimerEvent.TIMER,this.triggerDataRefreshEvent);
                     this.m_timer.stop();
                     this.m_timer = null;
                  }
                  FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,m_featureName,featureData);
               }
               else
               {
                  featureData[CURRENT_GUILD_ID] = result["guildId"];
                  if(!Global.player.getSeenFlag(GUILD_IGNORE_COUPON))
                  {
                     Global.player.setSeenFlag(GUILD_IGNORE_COUPON);
                  }
                  if(result["role"] == "Owner")
                  {
                     featureData[MEMBERSHIP_STATUS] = OWNER;
                  }
                  else if(result["role"] == "Leader")
                  {
                     featureData[MEMBERSHIP_STATUS] = LEADER;
                  }
                  else if(result["role"] == "Member")
                  {
                     featureData[MEMBERSHIP_STATUS] = MEMBER;
                  }
                  if(result[TEMP_FO_GUILD_OB_POINTS])
                  {
                     this.eventManager.saveGuildPoints(result[TEMP_FO_GUILD_OB_POINTS]);
                  }
                  if(result["currentTier"])
                  {
                     this.eventManager.saveGuildCurrentTier(result["currentTier"]);
                  }
                  if(result["milestone"])
                  {
                     this.eventManager.saveGuildMilestoneLevel(result["milestone"]);
                  }
                  if(result["guildPoints"])
                  {
                     this.saveGuildtotalPoints(result[TOTAL_GUILD_POINTS]);
                  }
                  FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILd_VIEW_INFO,result);
                  if(result.hasOwnProperty("name"))
                  {
                     guildName = result["name"];
                     if(this.m_guildCreationHud)
                     {
                        if(this.m_guildCreationHud.ishudTextVisible())
                        {
                           this.setDefaulHudText();
                        }
                     }
                  }
                  FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,m_featureName,featureData);
                  if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MATCHMAKING_ENABLE) > 0)
                  {
                     if(Global.player.getSeenFlag("ZOMM_CONNECTION_INITIATED") == false)
                     {
                        Global.player.setSeenFlag("ZOMM_CONNECTION_INITIATED",true,true);
                        MatchMakingManager.getInstance().initZoom();
                        MatchMakingManager.getInstance().createSession(this.getZId(),[],0);
                     }
                  }
                  if(!this.m_timer)
                  {
                     this.startDataRefresherEvents();
                  }
               }
            }
            if(result.hasOwnProperty("invites"))
            {
               invitesInfo = result["invites"];
               FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILd_INVITES_INFO,invitesInfo);
            }
         }
         if(this.m_mainWindowWaitingDiaog)
         {
            this.m_mainWindowWaitingDiaog.close();
            this.m_mainWindowWaitingDiaog = null;
            this.showUI();
         }
      }
      
      public function saveGuildtotalPoints(points:int) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILD_TOTAL_POINTS,points);
      }
      
      public function getGuildtotalPoints() : int
      {
         var guildPoints:int = int(FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILD_TOTAL_POINTS));
         var userPoints:int = this.getUserPoints();
         return guildPoints >= userPoints ? guildPoints : userPoints;
      }
      
      public function onGetChatMessages(result:Object) : void
      {
         var msgData:Object = null;
         var messagesObj:Object = null;
         var chatData:Array = null;
         var msgIndex:String = null;
         var chatMessage:Object = null;
         if(Boolean(result) && result.hasOwnProperty("data"))
         {
            msgData = result["data"];
            if(msgData)
            {
               messagesObj = msgData["messages"];
               chatData = [];
               for(msgIndex in messagesObj)
               {
                  chatMessage = {};
                  chatMessage["zid"] = messagesObj[msgIndex]["zid"];
                  chatMessage["text"] = messagesObj[msgIndex]["text"];
                  chatMessage["time"] = messagesObj[msgIndex]["creationTime"];
                  chatData.push(chatMessage);
               }
               FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILD_CHAT_INFO,chatData);
            }
         }
         Global.player.setSeenFlag(COMPLETED_CHAT_HISTORY_LOADING,true,true);
         if(this.m_guildMainWindow)
         {
            this.m_guildMainWindow.refreshChatWindow();
         }
      }
      
      public function onGetNotificationMessages(result:Object) : void
      {
         var msgData:Object = null;
         var messagesObj:Object = null;
         var chatData:Array = null;
         var msgIndex:String = null;
         var chatMessage:Object = null;
         if(Boolean(result) && result.hasOwnProperty("data"))
         {
            msgData = result["data"];
            if(Boolean(msgData) && msgData.hasOwnProperty("messages"))
            {
               messagesObj = msgData["messages"];
               chatData = [];
               for(msgIndex in messagesObj)
               {
                  chatMessage = {};
                  chatMessage["zid"] = messagesObj[msgIndex]["zid"];
                  chatMessage["text"] = messagesObj[msgIndex]["text"];
                  chatMessage["time"] = messagesObj[msgIndex]["creationTime"];
                  chatData.push(chatMessage);
               }
               FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILD_NOTIFICATION_INFO,chatData);
            }
         }
         Global.player.setSeenFlag(COMPLETED_NOTIFICATION_LOADING,true,true);
         if(this.m_guildMainWindow)
         {
            this.m_guildMainWindow.refreshNotificationWindow();
         }
      }
      
      public function onChatMessageReceived(e:DataEvent) : void
      {
         var msgJson:Object = null;
         var chatData:Object = null;
         var chatMessage:Object = null;
         var notificationMessageData:Object = null;
         var notificationData:Object = null;
         var msg:String = e.data;
         var fullMsgJson:Object = com.adobe.serialization.json.JSON.decode(msg);
         if(fullMsgJson.hasOwnProperty("servicename"))
         {
            if(fullMsgJson["servicename"] == "conversation")
            {
               msgJson = com.adobe.serialization.json.JSON.decode(fullMsgJson.msg);
               if(msgJson.conversationID == "guild_" + GuildManager.getInstance().getGuildId().toString() + "_conversation")
               {
                  if(msgJson.zid != GuildManager.getInstance().getZId())
                  {
                     chatData = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILD_CHAT_INFO);
                     if(!chatData)
                     {
                        chatData = [];
                     }
                     chatMessage = {};
                     chatMessage["zid"] = msgJson.zid;
                     chatMessage["text"] = msgJson.text;
                     chatMessage["time"] = int(msgJson.timestamp);
                     chatData.push(chatMessage);
                     FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILD_CHAT_INFO,chatData);
                     if(this.m_guildMainWindow)
                     {
                        if(this.m_guildMainWindow.getSelectedMessageTab() == 1)
                        {
                           this.m_guildMainWindow.highlighMessageFrameMark(0);
                        }
                        this.m_guildMainWindow.refreshChatWindow();
                     }
                     this.m_guildCreationHud.notifText = "new message received";
                  }
               }
               else if(msgJson.conversationID == "guild_" + GuildManager.getInstance().getGuildId().toString() + "_fv_notification")
               {
                  if(msgJson.hasOwnProperty("text") && msgJson["text"] != "")
                  {
                     if(msgJson["text"].indexOf("token") != -1)
                     {
                        GuildManager.getInstance().triggerDataRefreshEvent();
                     }
                     if(msgJson["text"].indexOf("joined") != -1)
                     {
                        GuildManager.getInstance().triggerDataRefreshEvent();
                     }
                     if(msgJson["text"].indexOf("left") != -1)
                     {
                        GuildManager.getInstance().triggerDataRefreshEvent();
                     }
                  }
                  notificationMessageData = {};
                  notificationData = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILD_NOTIFICATION_INFO);
                  if(!notificationData)
                  {
                     notificationData = [];
                  }
                  notificationMessageData["text"] = msgJson.text;
                  notificationMessageData["time"] = int(msgJson.timestamp);
                  notificationMessageData["zid"] = msgJson.zid;
                  notificationData.push(notificationMessageData);
                  FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILD_NOTIFICATION_INFO,notificationData);
                  if(this.m_guildMainWindow)
                  {
                     if(this.m_guildMainWindow.getSelectedMessageTab() == 0)
                     {
                        this.m_guildMainWindow.highlighMessageFrameMark(1);
                     }
                     this.m_guildMainWindow.refreshNotificationWindow();
                  }
                  if(msgJson.hasOwnProperty("text") && msgJson["text"] != "")
                  {
                     if(msgJson["text"].indexOf("joined") != -1)
                     {
                        this.m_guildCreationHud.notifText = "New member joined";
                     }
                  }
               }
               else if(msgJson.conversationID == "guild_" + GuildManager.getInstance().getGuildId().toString() + "_fv_slot_notification")
               {
                  if(msgJson.hasOwnProperty("text") && msgJson["text"] != "")
                  {
                     if(msgJson.zid != GuildManager.getInstance().getZId())
                     {
                        GuildEventManager.getInstance().fillOrder1();
                        GuildManager.getInstance().triggerDataRefreshEvent();
                     }
                  }
               }
            }
         }
      }
      
      public function onGetGuildMembersInfoResult(result:Object) : void
      {
         var membersInfo:Object = null;
         var userZId:String = null;
         var memberIndex:int = 0;
         var giftedKeysCountFromOthersMembers:int = 0;
         var featureData:Object = null;
         var currentKeyCount:int = 0;
         if(Boolean(result) && Boolean(result["data"]))
         {
            membersInfo = result["data"];
            userZId = this.getZId();
            if(membersInfo)
            {
               for(memberIndex = 0; memberIndex < membersInfo.length; memberIndex++)
               {
                  if(membersInfo[memberIndex]["pic_square"])
                  {
                     this.m_memberPicMap[membersInfo[memberIndex]["playerId"]] = membersInfo[memberIndex]["pic_square"];
                  }
                  if(membersInfo[memberIndex]["name"])
                  {
                     this.m_memberNameMap[membersInfo[memberIndex]["playerId"]] = membersInfo[memberIndex]["name"];
                  }
                  if(membersInfo[memberIndex]["playerId"] == userZId)
                  {
                     if(membersInfo[memberIndex]["key1"] > 0)
                     {
                        giftedKeysCountFromOthersMembers = int(membersInfo[memberIndex]["key1"]);
                        featureData = this.getFeatureData();
                        if(featureData.hasOwnProperty("keyCount") == false)
                        {
                           featureData["keyCount"] = 0;
                        }
                        currentKeyCount = int(featureData["keyCount"]);
                        featureData["keyCount"] = currentKeyCount + giftedKeysCountFromOthersMembers;
                        featureData["requestedKeyCount"] = featureData["requestedKeyCount"] - 1;
                        if(featureData["requestedKeyCount"] < 0)
                        {
                           featureData["requestedKeyCount"] = 0;
                        }
                        setFeatureData(featureData);
                        FarmStatsManager.count(featureXML.child("statCounter"),"clan_action","received","clanToken",this.getGuildId());
                        membersInfo["key1"] = 0;
                        this.m_receivedHelp = true;
                        if(this.m_guildMainWindow)
                        {
                           this.m_guildMainWindow.refreshAskGuildKeyButton();
                        }
                     }
                     if(membersInfo[memberIndex]["role"] == "Elder")
                     {
                        if(!Global.player.getSeenFlag(GuildEventManager.getInstance().featureName + "_ElderwindowSeenFlag"))
                        {
                           Global.player.setSeenFlag(GuildEventManager.getInstance().featureName + "_ElderwindowSeenFlag");
                           GuildEventManager.getInstance().showElderWindow();
                           this.m_guildCreationHud.notifText = "You are new General";
                        }
                     }
                  }
               }
            }
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILd_MEMBERS_INFO,membersInfo);
            if(this.m_guildMainWindow)
            {
               this.m_guildMainWindow.refreshKeyFrame();
               if(giftedKeysCountFromOthersMembers > 0)
               {
                  this.m_guildMainWindow.updateConsumableDoober(giftedKeysCountFromOthersMembers);
                  this.m_guildMainWindow.refreshRequestCount();
               }
               this.m_guildMainWindow.updateMembersStatus();
            }
         }
      }
      
      public function tryScratchCard() : void
      {
         if(this.m_welcomeWindow)
         {
            this.m_welcomeWindow.tintWindow();
            this.m_welcomeWindow.enableInput = false;
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"scratchPromoCard",this.onScratchResult,[]),true);
         FarmStatsManager.count(featureXML.child("statCounter"),"scratch","welcome_ui","start");
      }
      
      private function showScratchResult(event:TimerEvent = null) : void
      {
         var ticketToCreate:Boolean = false;
         var featureData:Object = null;
         var message:String = null;
         if(Boolean(this.m_welcomeWindow) && this.m_welcomeWindow.m_scratchAnimationRunning == false)
         {
            if(this.m_scratch_Timer)
            {
               this.m_scratch_Timer.removeEventListener(TimerEvent.TIMER,this.showScratchResult);
               this.m_scratch_Timer = null;
            }
            ticketToCreate = false;
            featureData = this.getFeatureData();
            if(this.m_scratchResult != null)
            {
               if(this.m_scratchResult.hasOwnProperty("win"))
               {
                  if(this.m_scratchResult["win"] == true)
                  {
                     ticketToCreate = true;
                  }
               }
            }
            if(ticketToCreate)
            {
               featureData[TICKET_TO_CREATE_GUILD] = GRANTED;
            }
            else
            {
               featureData[TICKET_TO_CREATE_GUILD] = NOT_GRANTED;
            }
            setFeatureData(featureData);
            if(this.m_welcomeWindow)
            {
               this.m_welcomeWindow.hideScratchAnimation();
            }
            if(ticketToCreate)
            {
               message = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"guild_scratch_win_text");
               UI.displayPopup(new GuildMessageWindow(m_featureName,"assets/dialogs/Coop2019/FV_Coop2019_Message.swf",message,this.onScratchWinOK),false);
               FarmStatsManager.count(featureXML.child("statCounter"),"scratch","welcome_ui","win");
            }
            else
            {
               message = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"guild_scratch_loose_text");
               UI.displayPopup(new GuildMessageWindow(m_featureName,"assets/dialogs/Coop2019/FV_Coop2019_Message.swf",message,this.onScratchLooseOK),false);
               FarmStatsManager.count(featureXML.child("statCounter"),"scratch","welcome_ui","loose");
            }
         }
      }
      
      public function onScratchResult(result:Object) : void
      {
         this.m_scratchResult = result;
         if(Boolean(this.m_welcomeWindow) && this.m_welcomeWindow.m_scratchAnimationRunning == true)
         {
            if(!this.m_scratch_Timer)
            {
               this.m_scratch_Timer = new Timer(1000);
               this.m_scratch_Timer.addEventListener(TimerEvent.TIMER,this.showScratchResult);
               this.m_scratch_Timer.start();
            }
         }
         else
         {
            this.showScratchResult();
         }
      }
      
      public function onScratchWinOK(e:Event) : void
      {
         if(this.m_welcomeWindow)
         {
            this.m_welcomeWindow.close();
            this.m_welcomeWindow = null;
         }
         var closeButtonVisibility:Boolean = false;
         this.openCreateGuildWithTicket(closeButtonVisibility);
      }
      
      public function onScratchLooseOK(e:Event) : void
      {
         if(this.m_welcomeWindow)
         {
            this.m_welcomeWindow.close();
            this.m_welcomeWindow = null;
         }
         this.showWelcomeUI();
      }
      
      public function openCreateGuildWithTicket(closeButtonVisibility:Boolean = true) : void
      {
         if(this.m_welcomeWindow)
         {
            this.m_welcomeWindow.close();
            this.m_welcomeWindow = null;
         }
         this.m_guildCreateWindow = new GuildCreationWindow(FEATURE_NAME,this.createWindowURL,false,closeButtonVisibility);
         UI.displayPopup(this.m_guildCreateWindow);
         FarmStatsManager.count(featureXML.child("statCounter"),"create","create_ui","coupon");
      }
      
      public function openCreateGuildWithFVCash() : void
      {
         if(this.m_welcomeWindow)
         {
            this.m_welcomeWindow.close();
            this.m_welcomeWindow = null;
         }
         this.m_guildCreateWindow = new GuildCreationWindow(FEATURE_NAME,this.createWindowURL,true);
         UI.displayPopup(this.m_guildCreateWindow);
         FarmStatsManager.count(featureXML.child("statCounter"),"create","create_ui","FC");
      }
      
      public function isScratchAvailable() : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(featureData[TICKET_TO_CREATE_GUILD] == NOT_SEEN)
         {
            result = true;
         }
         if(Global.player.getSeenFlag("GUILD_IGNORE_COUPON"))
         {
            result = false;
         }
         return result;
      }
      
      public function isCreateCouponAvailable() : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(featureData[TICKET_TO_CREATE_GUILD] == GRANTED)
         {
            result = true;
         }
         if(Global.player.getSeenFlag("GUILD_IGNORE_COUPON"))
         {
            result = false;
         }
         return result;
      }
      
      public function createGuild(inviteStatus:String, guildName:String, guildDescription:String, guildImageId:String, withFC:Boolean) : void
      {
         var message:String = "";
         if(withFC && Global.player.canBuyCash(10))
         {
            this.m_guildCreateWindow.close();
            this.m_guildCreateWindow = null;
            this.m_withFC = true;
            message = "Creating a new Clan ...";
            this.m_createGuildWaitingDialog = UI.displayMessage(message,GenericPopup.TYPE_MODAL,null,"",true);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"createGuild",this.onGuildCreated,[inviteStatus,guildName,guildDescription,guildImageId,withFC]),true);
            FarmStatsManager.count(featureXML.child("statCounter"),"create","create_bt","coupon");
         }
         else if(withFC == false)
         {
            this.m_guildCreateWindow.close();
            this.m_guildCreateWindow = null;
            this.m_withFC = false;
            message = "Creating a new Clan ...";
            this.m_createGuildWaitingDialog = UI.displayMessage(message,GenericPopup.TYPE_MODAL,null,"",true);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"createGuild",this.onGuildCreated,[inviteStatus,guildName,guildDescription,guildImageId,withFC]),true);
            FarmStatsManager.count(featureXML.child("statCounter"),"create","create_bt","FC");
         }
      }
      
      public function onGuildCreated(result:Object) : void
      {
         var fo:Object = null;
         var fobject:Object = null;
         var message:String = null;
         var msg:String = null;
         if(this.m_createGuildWaitingDialog)
         {
            this.m_createGuildWaitingDialog.close();
            this.m_createGuildWaitingDialog = null;
         }
         if(Boolean(result) && Boolean(result["status"] != "fail") && result.hasOwnProperty("already_member") == false)
         {
            if(!Global.player.getSeenFlag("GUILD_IGNORE_COUPON"))
            {
               Global.player.setSeenFlag("GUILD_IGNORE_COUPON");
            }
            fo = this.getFeatureData();
            fo[CURRENT_GUILD_ID] = result["guildId"];
            if(result["role"] == "Owner")
            {
               fo[MEMBERSHIP_STATUS] = OWNER;
            }
            else if(result["role"] == "Leader")
            {
               fo[MEMBERSHIP_STATUS] = LEADER;
            }
            else if(result["role"] == "Member")
            {
               fo[MEMBERSHIP_STATUS] = MEMBER;
            }
            setFeatureData(fo);
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILd_VIEW_INFO,result);
            this.m_guildMainWindow = new GuildMainWindow(m_featureName,"assets/dialogs/Coop2019/FV_Coop2019_MainUI.swf",result);
            UI.displayPopup(this.m_guildMainWindow);
            this.startDataRefresherEvents();
            Global.player.setSeenFlag(COMPLETED_CHAT_HISTORY_LOADING,true,true);
            Global.player.setSeenFlag(COMPLETED_NOTIFICATION_LOADING,true,true);
            if(this.m_withFC)
            {
               Global.player.cash -= 10;
            }
            FarmStatsManager.count(featureXML.child("statCounter"),"create","result","success","FC",result["guildId"]);
         }
         else if(Boolean(result) && result["already_member"] == true)
         {
            fobject = this.getFeatureData();
            fobject[CURRENT_GUILD_ID] = result["guildId"];
            if(result["role"] == "Owner")
            {
               fobject[MEMBERSHIP_STATUS] = OWNER;
            }
            else if(result["role"] == "Leader")
            {
               fobject[MEMBERSHIP_STATUS] = LEADER;
            }
            else if(result["role"] == "Member")
            {
               fobject[MEMBERSHIP_STATUS] = MEMBER;
            }
            setFeatureData(fobject);
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILd_VIEW_INFO,result);
            message = "You are already part of a clan. Enter Farmers Clan to see the details.";
            UI.displayMessage(message,GenericPopup.TYPE_OK,this.openGuildMainUI,"",true);
            this.startDataRefresherEvents();
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getChatMessages",this.onGetChatMessages,[m_featureName]),true);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getNotificationMessages",this.onGetNotificationMessages,[m_featureName]),true);
            FarmStatsManager.count(featureXML.child("statCounter"),"create","result","success","coupon",result["guildId"]);
         }
         else
         {
            msg = "An error occurred. Please try again.";
            UI.displayMessage(msg,GenericPopup.TYPE_OK,null,"",true);
            FarmStatsManager.count(featureXML.child("statCounter"),"create","result","failed",this.m_withFC ? "FC" : "coupon");
         }
      }
      
      public function openConsumableCraftWindow() : void
      {
         if(this.m_guildMainWindow)
         {
            if(this.m_guildMainWindow.m_overlayMC)
            {
               this.m_guildMainWindow.m_overlayMC.visible = true;
            }
         }
         else if(this.m_welcomeWindow)
         {
            if(this.m_welcomeWindow.m_overlayMC)
            {
               this.m_welcomeWindow.m_overlayMC.visible = true;
            }
         }
         this.m_guildConsumableCraftWindow = new GuildConsumableCraftWindow(m_featureName,"assets/dialogs/Coop2019/FV_Coop2019_Craft.swf");
         UI.displayPopup(this.m_guildConsumableCraftWindow,false);
         FarmStatsManager.count(featureXML.child("statCounter"),"craft","craft_ui","open","impression");
      }
      
      public function collectConsumable(slotIndex:int) : void
      {
         var key:String = null;
         if(this.canCollectConsuamble(slotIndex))
         {
            FeatureOptionsInventoryManager.getInstance().addCount(this.consumableCodeArray[slotIndex],1);
            key = m_featureName + COLLECT_TIME_KEY + slotIndex.toString();
            Global.player.setFeatureLastShown(key,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,SERVICE_FUNC_COLLECT,null,[m_featureName,slotIndex]),true);
            if(Boolean(this.m_guildMainWindow) && Boolean(this.m_guildMainWindow.m_consumableSlotFrame))
            {
               this.m_guildMainWindow.m_consumableSlotFrame.refresh();
            }
            if(Boolean(this.m_welcomeWindow) && Boolean(this.m_welcomeWindow.m_consumableSlotFrame))
            {
               this.m_welcomeWindow.m_consumableSlotFrame.refresh();
            }
            if(this.m_guildConsumableCraftWindow)
            {
               this.m_guildConsumableCraftWindow.refreshGuildCraftWindow();
            }
            FarmStatsManager.count(featureXML.child("statCounter"),"collect",this.consumableCodeArray[slotIndex],"1");
         }
      }
      
      public function get consumableList() : Array
      {
         return this.consumableCodeArray;
      }
      
      public function canAskForGuildKeys() : Boolean
      {
         var canAsk:Boolean = true;
         var featureData:Object = this.getFeatureData();
         if(this.timeLeftToAskNewGuildKey() > 0)
         {
            canAsk = false;
            if(this.m_guildMainWindow.m_askGuildKey != null)
            {
               this.m_guildMainWindow.m_askGuildKey.attachTooltip(new FarmTextTooltip("You can ask another in " + HUD.getformattedTimeLeft(this.timeLeftToAskNewGuildKey())));
            }
         }
         if(Boolean(featureData) && Boolean(featureData.hasOwnProperty("keyCount")) && featureData["keyCount"] >= MAX_GUILD_KEY_CAP)
         {
            canAsk = false;
            if(this.m_guildMainWindow.m_askGuildKey != null)
            {
               this.m_guildMainWindow.m_askGuildKey.attachTooltip(new FarmTextTooltip("Your token inventory is full"));
            }
         }
         if(Boolean(featureData) && Boolean(featureData.hasOwnProperty("requestedKeyCount")) && featureData["requestedKeyCount"] >= MAX_REQUESTED_GUILD_KEY_CAP)
         {
            canAsk = false;
            if(this.m_guildMainWindow.m_askGuildKey != null)
            {
               this.m_guildMainWindow.m_askGuildKey.attachTooltip(new FarmTextTooltip("You have reached the daily limit of asking for Tokens from your clan members"));
            }
         }
         return canAsk;
      }
      
      public function timeLeftToAskNewGuildKey() : int
      {
         var key:String = m_featureName + GUILD_KEY_ASK_TIME_KEY;
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         var timeRemaining:int = THROTTLE_TIME_FOR_ASK_GUILD_KEY - timeSinceLastFeed;
         return timeRemaining > 0 ? timeRemaining : 0;
      }
      
      public function askGuildKey() : void
      {
         var featureData:Object = this.getFeatureData();
         if(!featureData["requestedKeyCount"])
         {
            featureData["requestedKeyCount"] = 0;
         }
         var requestedCount:int = int(featureData["requestedKeyCount"]);
         requestedCount += 1;
         featureData["requestedKeyCount"] = requestedCount;
         setFeatureData(featureData);
         var key:String = m_featureName + GUILD_KEY_ASK_TIME_KEY;
         Global.player.setFeatureLastShown(key,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,SERVICE_FUNC_REQUEST_KEY,null,[m_featureName]),true);
         FarmStatsManager.count(featureXML.child("statCounter"),"request","clanToken","1","",this.getGuildId());
      }
      
      public function giveKey(targetUserId:String) : void
      {
         var featureData:Object = this.getFeatureData();
         if(!featureData[PLAYER_GUILD_POINTS])
         {
            featureData[PLAYER_GUILD_POINTS] = 0;
         }
         var pointsBonus:int = 1;
         var playerguildPoints:int = int(featureData[PLAYER_GUILD_POINTS]);
         playerguildPoints += pointsBonus;
         featureData[PLAYER_GUILD_POINTS] = playerguildPoints;
         featureData["keyCount"] = featureData["keyCount"] - 1;
         setFeatureData(featureData);
         var guildPoints:int = this.getGuildtotalPoints();
         this.saveGuildtotalPoints(guildPoints + pointsBonus);
         this.decrementPlayerRequest(targetUserId);
         if(this.m_guildMainWindow)
         {
            this.m_guildMainWindow.refreshKeyFrame();
            this.m_guildMainWindow.updatePlayerPointsDoober(1);
            this.m_guildMainWindow.refreshKeyCount();
            this.m_guildMainWindow.refreshAskGuildKeyButton();
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,SERVICE_FUNC_GIVE_KEY,null,[m_featureName,targetUserId]),true);
         FarmStatsManager.count(featureXML.child("statCounter"),"help","clanToken","1","",this.getGuildId());
      }
      
      private function decrementPlayerRequest(targetUserId:String) : void
      {
         var memberIndex:int = 0;
         var membersInfoData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILd_MEMBERS_INFO);
         if(membersInfoData)
         {
            for(memberIndex = 0; memberIndex < membersInfoData.length; memberIndex++)
            {
               if(membersInfoData[memberIndex]["playerId"] == targetUserId)
               {
                  membersInfoData[memberIndex]["request1"] = membersInfoData[memberIndex]["request1"] - 1;
               }
            }
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILd_MEMBERS_INFO,membersInfoData);
         }
      }
      
      public function getKeyRequestData() : Array
      {
         var index:* = 0;
         var memberIndex:int = 0;
         var memberInfo:Object = null;
         var keyRequestData:Array = [];
         var membersInfoData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILd_MEMBERS_INFO);
         if(membersInfoData)
         {
            index = 0;
            for(memberIndex = 0; memberIndex < membersInfoData.length; memberIndex++)
            {
               memberInfo = {};
               memberInfo["pic_square"] = membersInfoData[memberIndex]["pic_square"];
               memberInfo["name"] = Boolean(membersInfoData[memberIndex]["name"]) && membersInfoData[memberIndex]["name"] != "" ? membersInfoData[memberIndex]["name"] : "Player";
               memberInfo["playerId"] = membersInfoData[memberIndex]["playerId"];
               memberInfo["uid"] = membersInfoData[memberIndex]["uid"];
               memberInfo["role"] = membersInfoData[memberIndex]["role"];
               memberInfo["key1"] = membersInfoData[memberIndex]["key1"];
               memberInfo["request1"] = membersInfoData[memberIndex]["request1"];
               if(memberInfo["request1"] > 0 && memberInfo["playerId"].toString() != this.getZId().toString())
               {
                  memberInfo["index"] = index++;
                  keyRequestData.push(memberInfo);
               }
            }
         }
         return keyRequestData;
      }
      
      public function getChatMessages() : Array
      {
         var messageIndex:* = 0;
         var chatMessage:Object = null;
         var zid:String = null;
         var trimMsgStr:String = null;
         var chatMessages:Array = [];
         var chatData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILD_CHAT_INFO);
         var index:* = 0;
         if(chatData)
         {
            for(messageIndex = int(chatData.length - 1); messageIndex >= 0; messageIndex--)
            {
               chatMessage = {};
               zid = chatData[messageIndex]["zid"];
               chatMessage["pic_square"] = this.m_memberPicMap[zid];
               chatMessage["name"] = this.m_memberNameMap[zid];
               chatMessage["playerId"] = zid;
               chatMessage["time"] = int(chatData[messageIndex]["time"]);
               chatMessage["text"] = chatData[messageIndex]["text"];
               chatMessage["index"] = index++;
               trimMsgStr = StringUtil.trim(chatData[messageIndex]["text"]);
               if(Boolean(chatData[messageIndex]["text"]) && Boolean(chatData[messageIndex]["text"] != "") && trimMsgStr != "")
               {
                  chatMessages.push(chatMessage);
               }
            }
         }
         return chatMessages;
      }
      
      public function getNotificationMessages() : Array
      {
         var messageIndex:* = 0;
         var chatMessage:Object = null;
         var zid:String = null;
         var trimMsgStr:String = null;
         var chatMessages:Array = [];
         var chatData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILD_NOTIFICATION_INFO);
         var index:* = 0;
         if(chatData)
         {
            for(messageIndex = int(chatData.length - 1); messageIndex >= 0; messageIndex--)
            {
               chatMessage = {};
               zid = chatData[messageIndex]["zid"];
               chatMessage["pic_square"] = this.m_memberPicMap[zid];
               chatMessage["name"] = this.m_memberNameMap[zid];
               chatMessage["playerId"] = chatData[messageIndex]["zid"];
               chatMessage["text"] = chatData[messageIndex]["text"];
               chatMessage["time"] = int(chatData[messageIndex]["time"]);
               chatMessage["index"] = index++;
               trimMsgStr = StringUtil.trim(chatData[messageIndex]["text"]);
               if(Boolean(chatData[messageIndex]["text"]) && Boolean(chatData[messageIndex]["text"] != "") && trimMsgStr != "")
               {
                  chatMessages.push(chatMessage);
               }
            }
         }
         return chatMessages;
      }
      
      public function sendMessageToGuild(msg:String) : void
      {
         var chatData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILD_CHAT_INFO);
         if(!chatData)
         {
            chatData = [];
         }
         var chatMessage:Object = {};
         chatMessage["zid"] = this.getZId();
         chatMessage["text"] = msg;
         chatMessage["time"] = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         chatData.push(chatMessage);
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILD_CHAT_INFO,chatData);
         if(this.m_guildMainWindow)
         {
            this.m_guildMainWindow.refreshChatWindow();
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,SERVICE_FUNC_SEND_MSG,null,[m_featureName,msg]),true);
      }
      
      public function getGuildLogoList() : Array
      {
         var logoObj:Object = null;
         var logoList:Array = [];
         for(var logoIndex:int = 0; logoIndex < 12; logoIndex++)
         {
            logoObj = {};
            logoObj["index"] = logoIndex;
            logoObj["image"] = GUILD_LOGO_IMAGE_ARRAY[logoIndex + 1];
            logoList.push(logoObj);
         }
         return logoList;
      }
      
      public function getCraftData() : Array
      {
         var craftPkg:Object = null;
         var craftData:Array = [];
         var key:FarmItem = Global.farmGameSettingsManager.getFarmItemByName("clantoken");
         for(var i:int = 0; i < 3; i++)
         {
            craftPkg = {};
            craftPkg["consumable0"] = this.consumableCodeArray[0];
            craftPkg["consumable1"] = this.consumableCodeArray[1];
            craftPkg["consumable2"] = this.consumableCodeArray[2];
            craftPkg["icon"] = key.icon;
            craftPkg["index"] = i;
            craftPkg["count0"] = this.COUNT_ARRAY[i][0];
            craftPkg["count1"] = this.COUNT_ARRAY[i][1];
            craftPkg["count2"] = this.COUNT_ARRAY[i][2];
         }
         return craftData;
      }
      
      public function getGuildConsumableData() : Array
      {
         var consumableInfo:Object = null;
         var consumableData:Array = [];
         for(var index:int = 0; index < this.consumableList.length; index++)
         {
            consumableInfo = {};
            consumableInfo["code"] = this.consumableCodeArray[index];
            consumableInfo["index"] = index;
            consumableData.push(consumableInfo);
         }
         return consumableData;
      }
      
      public function getGuildConsumableCraftData() : Array
      {
         var consumableInfo:Object = null;
         var consumableData:Array = [];
         var key:String = "clantoken";
         for(var index:int = 0; index < this.consumableList.length; index++)
         {
            consumableInfo = {};
            consumableInfo["pkgName"] = this.consumablePkgArray[index];
            consumableInfo["consumable0"] = this.consumableCodeArray[0];
            consumableInfo["consumable1"] = this.consumableCodeArray[1];
            consumableInfo["consumable2"] = this.consumableCodeArray[2];
            consumableInfo["key"] = key;
            consumableInfo["index"] = index;
            consumableInfo["req"] = this.consumableReqArray[index];
            consumableInfo["count0"] = this.COUNT_ARRAY[index][0];
            consumableInfo["count1"] = this.COUNT_ARRAY[index][1];
            consumableInfo["count2"] = this.COUNT_ARRAY[index][2];
            consumableData.push(consumableInfo);
         }
         return consumableData;
      }
      
      public function buyCraftPackages(index:int = 0) : void
      {
         var itemPackage:FarmItem = null;
         var pkgName:String = this.consumablePkgArray[index];
         if(pkgName != null)
         {
            itemPackage = Global.farmGameSettingsManager.getFarmItemByName(pkgName);
            if(Global.player.canBuyFarmItem(itemPackage))
            {
               Global.player.cash -= itemPackage.cash;
               FarmStatsManager.count(featureXML.child("statCounter"),"buy",pkgName,"1","",this.getGuildId());
               this.updateCraftKeyCount(index);
               if(this.m_guildMainWindow)
               {
                  this.m_guildMainWindow.refreshWindow();
               }
               else if(this.m_welcomeWindow)
               {
                  this.m_welcomeWindow.refreshKeyCount();
               }
               if(this.m_guildConsumableCraftWindow)
               {
                  this.m_guildConsumableCraftWindow.untintWindow();
                  this.m_guildConsumableCraftWindow.enableInput = true;
                  this.m_guildConsumableCraftWindow.refreshGuildCraftWindow();
               }
            }
            else if(this.m_guildConsumableCraftWindow)
            {
               this.m_guildConsumableCraftWindow.untintWindow();
               this.m_guildConsumableCraftWindow.enableInput = true;
               this.m_guildConsumableCraftWindow.refreshGuildCraftWindow();
            }
         }
      }
      
      public function updateCraftKeyCount(index:int) : void
      {
         var pkgName:String = null;
         var pkgItem:FarmItem = null;
         var pkgCount:int = 0;
         var featureObj:Object = this.getFeatureData();
         if(Boolean(featureObj) && featureObj.hasOwnProperty("keyCount"))
         {
            pkgName = this.consumablePkgArray[index];
            pkgItem = Global.farmGameSettingsManager.getFarmItemByName(pkgName);
            pkgCount = int(this.consumableReqArray[index]);
            featureObj["keyCount"] += pkgCount;
            setFeatureData(featureObj);
            if(this.m_guildMainWindow)
            {
               this.m_guildMainWindow.updateConsumableDoober(pkgCount);
            }
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"updateCraftKeyCount",null,[m_featureName,index]),true);
         }
      }
      
      public function makeKey(index:int = 0) : void
      {
         var featureObj:Object = this.getFeatureData();
         var pkgCount:int = int(this.consumableReqArray[index]);
         featureObj["keyCount"] += pkgCount;
         setFeatureData(featureObj);
         for(var i:int = 0; i < index + 1; i++)
         {
            FeatureOptionsInventoryManager.getInstance().removeCount(this.consumableCodeArray[i],this.COUNT_ARRAY[index][i]);
         }
         if(this.m_guildMainWindow)
         {
            this.m_guildMainWindow.updateConsumableDoober(pkgCount);
         }
         if(this.m_guildMainWindow)
         {
            this.m_guildMainWindow.refreshWindow();
         }
         else if(this.m_welcomeWindow)
         {
            this.m_welcomeWindow.refreshKeyCount();
         }
         if(this.m_guildConsumableCraftWindow)
         {
            this.m_guildConsumableCraftWindow.untintWindow();
            this.m_guildConsumableCraftWindow.enableInput = true;
            this.m_guildConsumableCraftWindow.refreshGuildCraftWindow();
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"makeKey",null,[m_featureName,index]),true);
         FarmStatsManager.count(featureXML.child("statCounter"),"craft","clanToken","1","",this.getGuildId());
      }
      
      public function inviteFriends(playerId:String) : void
      {
         var featureData:Object = this.getFeatureData();
         if(!featureData.hasOwnProperty(ALREADY_INVITED_FRIENDS))
         {
            featureData[ALREADY_INVITED_FRIENDS] = {};
         }
         featureData[ALREADY_INVITED_FRIENDS][playerId] = 1;
         setFeatureData(featureData);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,SERVICE_FUNC_INVITE_FRIENDS,null,[m_featureName,playerId]),true);
         FarmStatsManager.count(featureXML.child("statCounter"),"clan_action","invite",playerId,"",this.getGuildId());
      }
      
      public function openGuildViewWindow() : void
      {
         if(this.m_guildListWindow)
         {
            this.m_guildListWindow.close();
            this.m_guildListWindow = null;
         }
         var guildViewData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILd_VIEW_INFO);
         this.m_guildViewWindow = new GuildViewWindow(m_featureName,"assets/dialogs/Coop2019/FV_Coop2019_Details.swf",guildViewData);
         if(this.m_guildMainWindow)
         {
            this.m_guildMainWindow.close();
         }
         UI.displayPopup(this.m_guildViewWindow);
      }
      
      public function getGuildMembersData() : Array
      {
         var memberIndex:int = 0;
         var memberInfo:Object = null;
         var membersData:Array = [];
         var membersInfoData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILd_MEMBERS_INFO);
         if(membersInfoData)
         {
            for(memberIndex = 0; memberIndex < membersInfoData.length; memberIndex++)
            {
               memberInfo = {};
               memberInfo["pic_square"] = membersInfoData[memberIndex]["pic_square"];
               memberInfo["name"] = membersInfoData[memberIndex]["name"];
               memberInfo["playerId"] = membersInfoData[memberIndex]["playerId"];
               memberInfo["role"] = membersInfoData[memberIndex]["role"];
               memberInfo["key1"] = membersInfoData[memberIndex]["key1"];
               memberInfo["request1"] = membersInfoData[memberIndex]["request1"];
               memberInfo["keyCount"] = membersInfoData[memberIndex]["ClanToken"];
               memberInfo[PLAYER_GUILD_POINTS] = membersInfoData[memberIndex][PLAYER_GUILD_POINTS];
               memberInfo["v1_status"] = membersInfoData[memberIndex]["v1_status"];
               if(membersInfoData[memberIndex]["entry_status"])
               {
                  memberInfo["entry_status"] = membersInfoData[memberIndex]["entry_status"];
               }
               else
               {
                  memberInfo["entry_status"] = 0;
               }
               memberInfo["index"] = memberIndex;
               membersData.push(memberInfo);
            }
         }
         return membersData;
      }
      
      public function openGuildEditWindow() : void
      {
         if(this.m_guildViewWindow)
         {
            this.m_guildViewWindow.close();
            this.m_guildViewWindow = null;
         }
         var guildViewData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILd_VIEW_INFO);
         UI.displayPopup(this.m_guildEditWindow = new GuildEditWindow(m_featureName,this.createWindowURL,guildViewData));
      }
      
      public function openGuildAddMembersWindow() : void
      {
         if(this.m_guildViewWindow)
         {
            this.m_guildViewWindow.close();
            this.m_guildViewWindow = null;
         }
         var featureData:Object = this.getFeatureData();
         var leadershipStatus:Boolean = Boolean(featureData) && featureData[MEMBERSHIP_STATUS] >= LEADER;
         UI.displayPopup(this.m_guildAddMembersWindow = new GuildAddMembersWindow(m_featureName,"assets/dialogs/Coop2019/FV_Coop2019_Add.swf",leadershipStatus));
      }
      
      public function editGuild(inviteStatus:String, name:String, des:String, imageId:int) : void
      {
         if(this.m_guildEditWindow)
         {
            this.m_guildEditWindow.close();
            this.m_guildEditWindow = null;
         }
         var message:String = "Saving Clan changes...";
         this.m_editGuildWaitingDialog = UI.displayMessage(message,GenericPopup.TYPE_MODAL,null,"",true);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"editGuild",this.onGuildEdited,[inviteStatus,name,des,imageId]),true);
      }
      
      public function onGuildEdited(result:Object) : void
      {
         var guildViewData:Object = null;
         var message:String = null;
         if(this.m_editGuildWaitingDialog)
         {
            this.m_editGuildWaitingDialog.close();
            this.m_editGuildWaitingDialog = null;
         }
         if(Boolean(result) && result["status"] != "fail")
         {
            guildViewData = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILd_VIEW_INFO);
            guildViewData["description"] = result["description"];
            guildViewData["name"] = result["name"];
            guildViewData["alias"] = result["alias"];
            guildViewData["inviteStatus"] = result["inviteStatus"];
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILd_VIEW_INFO,guildViewData);
            this.m_guildMainWindow = new GuildMainWindow(m_featureName,"assets/dialogs/Coop2019/FV_Coop2019_MainUI.swf",guildViewData);
            UI.displayPopup(this.m_guildMainWindow);
         }
         else
         {
            message = "Saving Clan information failed. Please try again later.";
            UI.displayMessage(message,GenericPopup.TYPE_OK,null,"",true);
         }
      }
      
      public function setImageId(index:int) : void
      {
         if(this.m_guildCreateWindow)
         {
            this.m_guildCreateWindow.imageId = index;
         }
         if(this.m_guildEditWindow)
         {
            this.m_guildEditWindow.imageId = index;
         }
      }
      
      public function leaveGuild() : void
      {
         if(this.m_guildViewWindow)
         {
            this.m_guildViewWindow.close();
         }
         var message:String = "Leaving Clan ...";
         this.m_waitingDialog = UI.displayMessage(message,GenericPopup.TYPE_MODAL,null,"",true);
         if(this.m_timer)
         {
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.triggerDataRefreshEvent);
            this.m_timer.stop();
            this.m_timer = null;
         }
         var fo:Object = this.getFeatureData();
         var role:String = fo[MEMBERSHIP_STATUS];
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"leaveGuild",this.onLeaveGuildCompleted,[m_featureName]),true);
         FarmStatsManager.count(featureXML.child("statCounter"),"clan_action","leave_clan",role.toString(),this.getGuildId());
      }
      
      public function onLeaveGuildCompleted(result:Object) : void
      {
         var featureData:Object = null;
         var message:String = null;
         if(this.m_waitingDialog)
         {
            this.m_waitingDialog.close();
            this.m_waitingDialog = null;
         }
         if(result["status"] == "success")
         {
            featureData = this.getFeatureData();
            featureData[MEMBERSHIP_STATUS] = NON_MEMBER;
            if(featureData.hasOwnProperty("ignoredList"))
            {
               featureData["ignoredList"].push(featureData[CURRENT_GUILD_ID]);
            }
            else
            {
               featureData["ignoredList"] = [];
               featureData["ignoredList"].push(featureData[CURRENT_GUILD_ID]);
            }
            featureData[CURRENT_GUILD_ID] = -1;
            setFeatureData(featureData);
            FeatureOptionsManager.resetFeatureOption(m_featureName,TEMP_FO_GUILd_VIEW_INFO);
            FeatureOptionsManager.resetFeatureOption(m_featureName,TEMP_FO_GUILd_MEMBERS_INFO);
            FeatureOptionsManager.resetFeatureOption(m_featureName,TEMP_FO_GUILD_CHAT_INFO);
            FeatureOptionsManager.resetFeatureOption(m_featureName,TEMP_FO_GUILD_NOTIFICATION_INFO);
            Global.player.resetSeenFlag(COMPLETED_CHAT_HISTORY_LOADING,true,true);
            Global.player.resetSeenFlag(COMPLETED_NOTIFICATION_LOADING,true,true);
            this.showUI();
         }
         else
         {
            message = "Network error occurred. Please try again later";
            UI.displayMessage(message,GenericPopup.TYPE_OK,null,"",true);
         }
      }
      
      public function removePlayerFromGuild(playerId:String) : void
      {
         if(this.m_guildViewWindow)
         {
            this.m_guildViewWindow.tintWindow();
         }
         var message:String = "Remvoing player from Clan ...";
         this.m_waitingDialog = UI.displayMessage(message,GenericPopup.TYPE_MODAL,null,"",true);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"removePlayerFromGuild",this.onRemovePlayerCompleted,[m_featureName,playerId]),true);
         FarmStatsManager.count(featureXML.child("statCounter"),"clan_action","remove_player",playerId,this.getGuildId());
      }
      
      public function onRemovePlayerCompleted(result:Object) : void
      {
         if(this.m_waitingDialog)
         {
            this.m_waitingDialog.close();
            this.m_waitingDialog = null;
         }
         if(result)
         {
            this.onGetGuildMembersInfoResult(result);
            if(this.m_guildViewWindow)
            {
               this.m_guildViewWindow.untintWindow();
               this.m_guildViewWindow.refreshWindow();
            }
         }
      }
      
      private function startDataRefresherEvents() : void
      {
         this.triggerDataRefreshEvent();
         var refreshInterval:int = 60000;
         if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_KEY_GUILD_DATA_REFRESH_TIME))
         {
            refreshInterval = Number(Global.flashHotParams[ZRUNTIME_KEY_GUILD_DATA_REFRESH_TIME]);
            refreshInterval *= 1000;
         }
         this.m_timer = new Timer(refreshInterval);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.triggerDataRefreshEvent);
         this.m_timer.start();
      }
      
      private function triggerDataRefreshEvent(event:TimerEvent = null) : void
      {
         var featureData:Object = this.getFeatureData();
         var guildId:int = int(featureData[CURRENT_GUILD_ID]);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getGuildMembersInfo",this.onGetGuildMembersInfoResult,[m_featureName,guildId]),true);
         if(!MatchMakingManager.getInstance().isConnected())
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getChatMessages",this.onGetChatMessages,[m_featureName]),true);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getNotificationMessages",this.onGetNotificationMessages,[m_featureName]),true);
         }
         if(Boolean(featureData) && featureData[MEMBERSHIP_STATUS] >= LEADER)
         {
            this.getAllJoinRequestsToGuild();
         }
         this.getUserGuildBlob();
         this.getAllJoinRequestsByPlayer();
         var fData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_FRIENDS_DATA);
         if(!fData)
         {
            this.getFriendsData();
         }
         MatchMakingManager.getInstance().removeEventListener(MatchMakingManager.EVENTTYPE_GUILDCHAT_MESSAGE,this.onChatMessageReceived);
         MatchMakingManager.getInstance().addEventListener(MatchMakingManager.EVENTTYPE_GUILDCHAT_MESSAGE,this.onChatMessageReceived);
         this.eventManager.fillOrder();
      }
      
      public function getGuildListData() : Array
      {
         var slotIndex:* = 0;
         var guildIdList:Array = null;
         var index:int = 0;
         var guildInfo:Object = null;
         var fo:Object = null;
         var name:String = null;
         var hi:* = 0;
         var key:Object = null;
         var guildListData:Array = [];
         var guildListInfoData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILd_LIST_INFO);
         if(guildListInfoData)
         {
            slotIndex = 0;
            guildIdList = [];
            for(index = 0; index < guildListInfoData.length; index++)
            {
               guildInfo = {};
               fo = this.getFeatureData();
               if(guildListInfoData[index]["guildId"] != fo[CURRENT_GUILD_ID] && guildIdList.indexOf(guildListInfoData[index]["guildId"]) == -1)
               {
                  if(!fo.hasOwnProperty("ignoredList") || (fo["ignoredList"] as Array).indexOf(guildListInfoData[index]["guildId"]) == -1)
                  {
                     guildInfo["logo"] = GUILD_LOGO_IMAGE_ARRAY[int(guildListInfoData[index]["alias"]) + 1];
                     guildInfo["name"] = guildListInfoData[index]["name"];
                     guildInfo["alias"] = guildListInfoData["alias"];
                     guildInfo["guildId"] = guildListInfoData[index]["guildId"];
                     guildInfo["memberCount"] = guildListInfoData[index]["memberCount"];
                     guildInfo["inviteStatus"] = guildListInfoData[index]["inviteStatus"];
                     guildInfo["total_points"] = guildListInfoData[index][TOTAL_GUILD_POINTS];
                     guildInfo["description"] = guildListInfoData[index]["description"];
                     guildInfo["isInvited"] = guildListInfoData[index]["isInvited"];
                     guildInfo["isInvitedByAdmin"] = guildListInfoData[index]["isInvitedByAdmin"];
                     if(guildInfo["isInvited"])
                     {
                        guildInfo["hostsProfileInfo"] = guildListInfoData[index]["hostsProfileInfo"];
                        if(guildInfo["hostsProfileInfo"])
                        {
                           guildInfo["hostNames"] = "";
                           name = "";
                           hi = 0;
                           for each(key in guildInfo["hostsProfileInfo"])
                           {
                              name = key["name"];
                              if(Boolean(name) && name != "")
                              {
                                 if(hi++ > 0)
                                 {
                                    guildInfo["hostNames"] += ", ";
                                 }
                                 guildInfo["hostNames"] += name;
                              }
                           }
                        }
                     }
                     guildInfo["index"] = slotIndex++;
                     guildListData.push(guildInfo);
                     guildIdList.push(guildInfo["guildId"]);
                  }
               }
            }
         }
         return guildListData;
      }
      
      public function sendJoinRequest(guildId:String, inviteStatus:Boolean = false) : void
      {
         if(this.m_guildViewWindow)
         {
            this.m_guildViewWindow.close();
         }
         if(this.m_guildListWindow)
         {
            this.m_guildListWindow.close();
         }
         var fo:Object = this.getFeatureData();
         if(fo.hasOwnProperty("ignoredList"))
         {
            fo["ignoredList"].push(guildId);
         }
         else
         {
            fo["ignoredList"] = [];
            fo["ignoredList"].push(guildId);
         }
         setFeatureData(fo);
         var requestedGuildArray:Array = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_JOIN_REQUEST_BY_PLAYER) as Array;
         if(requestedGuildArray == null)
         {
            requestedGuildArray = [];
         }
         requestedGuildArray.push(guildId);
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_JOIN_REQUEST_BY_PLAYER,requestedGuildArray);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sendJoinRequest",this.onSendJoinRequestResult,[m_featureName,guildId,inviteStatus]),true);
         var message:String = "Please wait ...";
         this.m_guildJoinWaitingDialog = UI.displayMessage(message,GenericPopup.TYPE_MODAL,null,"",true);
         FarmStatsManager.count(featureXML.child("statCounter"),"browse","browse_main","join_click",guildId,inviteStatus ? "invited" : "not_invited");
      }
      
      public function onSendJoinRequestResult(result:Object) : void
      {
         var message:String = null;
         var fo:Object = null;
         var fobject:Object = null;
         if(this.m_guildJoinWaitingDialog)
         {
            this.m_guildJoinWaitingDialog.close();
         }
         var guildId:String = "";
         if(result)
         {
            message = "";
            if(result.hasOwnProperty("join_completed"))
            {
               fo = this.getFeatureData();
               fo[CURRENT_GUILD_ID] = result["guildId"];
               if(result["role"] == "Owner")
               {
                  fo[MEMBERSHIP_STATUS] = OWNER;
               }
               else if(result["role"] == "Leader")
               {
                  fo[MEMBERSHIP_STATUS] = LEADER;
               }
               else if(result["role"] == "Member")
               {
                  fo[MEMBERSHIP_STATUS] = MEMBER;
               }
               setFeatureData(fo);
               FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILd_VIEW_INFO,result);
               this.m_guildMainWindow = new GuildMainWindow(m_featureName,"assets/dialogs/Coop2019/FV_Coop2019_MainUI.swf",result);
               UI.displayPopup(this.m_guildMainWindow);
               this.startDataRefresherEvents();
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getChatMessages",this.onGetChatMessages,[m_featureName]),true);
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getNotificationMessages",this.onGetNotificationMessages,[m_featureName]),true);
               if(result.hasOwnProperty("guildId"))
               {
                  guildId = result["guildId"];
               }
               FarmStatsManager.count(featureXML.child("statCounter"),"browse","browse_main","join_result","success",guildId);
            }
            else if(result.hasOwnProperty("join_pending"))
            {
               message = "Your request is pending approval from the clan";
               UI.displayMessage(message,GenericPopup.TYPE_OK,null,"",true);
               FarmStatsManager.count(featureXML.child("statCounter"),"browse","browse_main","join_result","pending");
            }
            else if(result.hasOwnProperty("already_member"))
            {
               fobject = this.getFeatureData();
               fobject[CURRENT_GUILD_ID] = result["guildId"];
               if(result["role"] == "Owner")
               {
                  fobject[MEMBERSHIP_STATUS] = OWNER;
               }
               else if(result["role"] == "Leader")
               {
                  fobject[MEMBERSHIP_STATUS] = LEADER;
               }
               else if(result["role"] == "Member")
               {
                  fobject[MEMBERSHIP_STATUS] = MEMBER;
               }
               setFeatureData(fobject);
               FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILd_VIEW_INFO,result);
               message = "You are already part of a clan. Enter Farmers Clan to see the details.";
               UI.displayMessage(message,GenericPopup.TYPE_OK,this.openGuildMainUI,"",true);
               this.startDataRefresherEvents();
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getChatMessages",this.onGetChatMessages,[m_featureName]),true);
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getNotificationMessages",this.onGetNotificationMessages,[m_featureName]),true);
               if(result.hasOwnProperty("guildId"))
               {
                  guildId = result["guildId"];
               }
               FarmStatsManager.count(featureXML.child("statCounter"),"browse","browse_main","join_result","already_member",guildId);
            }
            else if(result.hasOwnProperty("join_failed"))
            {
               message = "Clan is full";
               UI.displayMessage(message,GenericPopup.TYPE_OK,null,"",true);
               FarmStatsManager.count(featureXML.child("statCounter"),"browse","browse_main","join_result","failed");
            }
            else
            {
               message = "Network error occurred, Please try again later";
               UI.displayMessage(message,GenericPopup.TYPE_OK,null,"",true);
               FarmStatsManager.count(featureXML.child("statCounter"),"browse","browse_main","join_result","failed");
            }
         }
         else
         {
            message = "Clan is full";
            UI.displayMessage(message,GenericPopup.TYPE_OK,null,"",true);
            FarmStatsManager.count(featureXML.child("statCounter"),"browse","browse_main","join_result","failed");
         }
      }
      
      private function openGuildMainUI(e:Event = null) : void
      {
         this.showUI();
      }
      
      public function searchGuilds(searchField:String, attr:String) : void
      {
         if(this.m_guildListWindow)
         {
            this.m_guildListWindow.tintWindow();
         }
         var message:String = "Searching Clans ...";
         this.m_searchGuildWaitingDialog = UI.displayMessage(message,GenericPopup.TYPE_MODAL,null,"",true);
         searchField = encodeURI(searchField);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"searchGuilds",this.onSearchGuilds,[m_featureName,searchField,attr]),true);
         FarmStatsManager.count(featureXML.child("statCounter"),"browse","browse_main","search",attr,searchField);
      }
      
      public function onSearchGuilds(result:Object) : void
      {
         var guildListData:Array = null;
         var guildListInfoData:Array = null;
         var index:int = 0;
         var guildInfo:Object = null;
         if(this.m_searchGuildWaitingDialog)
         {
            this.m_searchGuildWaitingDialog.close();
            this.m_searchGuildWaitingDialog = null;
         }
         if(this.m_guildListWindow)
         {
            this.m_guildListWindow.untintWindow();
            this.m_guildListWindow.enableInput = true;
            guildListData = [];
            if(Boolean(result) && result.hasOwnProperty("data"))
            {
               guildListInfoData = result["data"];
               if(guildListInfoData)
               {
                  for(index = 0; index < guildListInfoData.length; index++)
                  {
                     guildInfo = {};
                     guildInfo["logo"] = GUILD_LOGO_IMAGE_ARRAY[int(guildListInfoData["alias"]) + 1];
                     guildInfo["name"] = guildListInfoData[index]["name"];
                     guildInfo["alias"] = guildListInfoData["alias"];
                     guildInfo["guildId"] = guildListInfoData[index]["guildId"];
                     guildInfo["memberCount"] = guildListInfoData[index]["memberCount"];
                     guildInfo["inviteStatus"] = guildListInfoData[index]["inviteStatus"];
                     guildInfo["total_points"] = guildListInfoData[index][TOTAL_GUILD_POINTS];
                     guildInfo["description"] = guildListInfoData[index]["description"];
                     guildInfo["isInvited"] = guildListInfoData[index]["isInvited"];
                     guildInfo["isInvitedByAdmin"] = guildListInfoData[index]["isInvitedByAdmin"];
                     if(guildInfo["isInvited"])
                     {
                        guildInfo["hostsProfileInfo"] = guildListInfoData["hostsProfileInfo"];
                     }
                     guildInfo["index"] = index;
                     guildListData.push(guildInfo);
                  }
               }
            }
            this.m_guildListWindow.setGuildListData(guildListData);
            this.m_guildListWindow.refreshWindow();
         }
      }
      
      public function viewOtherGuildDetail(guildId:String) : void
      {
         if(this.m_guildListWindow)
         {
            this.m_guildListWindow.tintWindow();
         }
         var message:String = "Getting Clan Info ...";
         this.m_waitingDialog = UI.displayMessage(message,GenericPopup.TYPE_MODAL,null,"",true);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getOtherGuildDetail",this.onGetOtherGuildDetail,[m_featureName,guildId]),true);
         FarmStatsManager.count(featureXML.child("statCounter"),"browse","browse_main","view",guildId,"details");
      }
      
      public function onGetOtherGuildDetail(result:Object) : void
      {
         var membersInfoData:Object = null;
         var memberIndex:int = 0;
         var memberInfo:Object = null;
         if(this.m_waitingDialog)
         {
            this.m_waitingDialog.close();
            this.m_waitingDialog = null;
         }
         if(this.m_guildListWindow)
         {
            this.m_guildListWindow.close();
            this.m_guildListWindow = null;
         }
         var message:String = "This guild is inactive now";
         var membersData:Array = [];
         if(result["guildStatus"] != "Inactive")
         {
            membersInfoData = result["membersData"];
            if(membersInfoData)
            {
               for(memberIndex = 0; memberIndex < membersInfoData.length; memberIndex++)
               {
                  memberInfo = {};
                  memberInfo["pic_square"] = membersInfoData[memberIndex]["pic_square"];
                  memberInfo["name"] = membersInfoData[memberIndex]["name"];
                  memberInfo["playerId"] = membersInfoData[memberIndex]["playerId"];
                  memberInfo["uid"] = membersInfoData[memberIndex]["uid"];
                  memberInfo["role"] = membersInfoData[memberIndex]["role"];
                  memberInfo[PLAYER_GUILD_POINTS] = membersInfoData[memberIndex][PLAYER_GUILD_POINTS];
                  memberInfo["index"] = memberIndex;
                  membersData.push(memberInfo);
               }
               result["membersData"] = membersData;
               UI.displayPopup(this.m_guildViewWindow = new GuildViewWindow(m_featureName,"assets/dialogs/Coop2019/FV_Coop2019_Details.swf",result,true));
            }
            else
            {
               UI.displayMessage(message,GenericPopup.TYPE_OK,null,"",true);
            }
         }
         else
         {
            UI.displayMessage(message,GenericPopup.TYPE_OK,null,"",true);
         }
      }
      
      public function isGuildAlreadyRequested(guildId:String) : Boolean
      {
         var result:Boolean = false;
         var requestedGuildArray:Array = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_JOIN_REQUEST_BY_PLAYER) as Array;
         if(Boolean(requestedGuildArray) && requestedGuildArray.indexOf(guildId) != -1)
         {
            result = true;
         }
         return result;
      }
      
      public function getFriendsDataForInvites() : Array
      {
         var index:int = 0;
         var memberInfo:Object = null;
         var friendsDataList:Array = [];
         var friendsData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_FRIENDS_DATA);
         if(friendsData)
         {
            for(index = 0; index < friendsData.length; index++)
            {
               memberInfo = {};
               memberInfo["pic_square"] = friendsData[index]["pic_square"];
               memberInfo["name"] = friendsData[index]["name"];
               memberInfo["playerId"] = friendsData[index]["playerId"];
               if(!this.isFriendInvitedAlready(memberInfo["playerId"].toString()))
               {
                  if(!this.m_memberNameMap.hasOwnProperty(memberInfo["playerId"]))
                  {
                     friendsDataList.push(memberInfo);
                  }
               }
            }
         }
         return friendsDataList;
      }
      
      private function isFriendInvitedAlready(playerId:String) : Boolean
      {
         var result:Boolean = false;
         var fo:Object = this.getFeatureData();
         if(Boolean(fo) && Boolean(fo[ALREADY_INVITED_FRIENDS]))
         {
            if(fo[ALREADY_INVITED_FRIENDS][playerId] == 1)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function getJoinRequestsData() : Array
      {
         var index:int = 0;
         var memberInfo:Object = null;
         var requesterDataList:Array = [];
         var requestData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_JOIN_REQUEST_TO_GUILD);
         if(requestData)
         {
            for(index = 0; index < requestData.length; index++)
            {
               memberInfo = {};
               memberInfo["pic_square"] = requestData[index]["pic_square"];
               memberInfo["name"] = requestData[index]["name"];
               memberInfo["playerId"] = requestData[index]["playerId"];
               memberInfo["index"] = index;
               requesterDataList.push(memberInfo);
            }
         }
         return requesterDataList;
      }
      
      public function getJoinRequestsCount() : int
      {
         var count:int = 0;
         var requestData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_JOIN_REQUEST_TO_GUILD);
         if(requestData)
         {
            count = int(requestData.length);
         }
         return count;
      }
      
      public function respondToJoinRequest(playerId:String, action:String) : void
      {
         FarmStatsManager.count(featureXML.child("statCounter"),"clan_action","respond",playerId,action,this.getGuildId());
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"respondToJoinRequest",this.OnRespondToJoinRequest,[m_featureName,playerId,action]),true);
      }
      
      public function OnRespondToJoinRequest(result:Object) : void
      {
         if(result)
         {
            if(result["status"] != "fail")
            {
               this.getAllJoinRequestsToGuild();
            }
            else
            {
               if(this.m_guildAddMembersWindow)
               {
                  this.m_guildAddMembersWindow.close();
                  this.m_guildAddMembersWindow = null;
               }
               if(result.hasOwnProperty("message"))
               {
                  UI.displayMessage(result["message"],GenericPopup.TYPE_OK,null,"",true);
               }
            }
         }
      }
      
      public function getUserPoints() : int
      {
         var userPoints:int = 0;
         var fo:Object = this.getFeatureData();
         if(Boolean(fo) && fo.hasOwnProperty(PLAYER_GUILD_POINTS))
         {
            userPoints = int(fo[PLAYER_GUILD_POINTS]);
         }
         return userPoints;
      }
      
      public function getOtherRequestText() : String
      {
         var msg:String = "";
         var requestLength:int = 0;
         var guildListArray:Array = this.getGuildListData();
         for(var i:int = 0; i < guildListArray.length; i++)
         {
            if(guildListArray[i]["isInvited"])
            {
               requestLength++;
            }
         }
         if(requestLength > 1)
         {
            msg = requestLength + " requests from other Clans";
         }
         else if(requestLength == 1)
         {
            msg = requestLength + " request from other Clans";
         }
         return msg;
      }
      
      public function getGuildMemberName(playerId:String) : String
      {
         var result:String = "Player";
         if(this.m_memberNameMap[playerId])
         {
            result = this.m_memberNameMap[playerId];
         }
         return result;
      }
      
      public function getGuildMemberPic(playerId:String) : String
      {
         var result:String = null;
         if(this.m_memberPicMap[playerId])
         {
            result = this.m_memberPicMap[playerId];
         }
         return result;
      }
      
      public function isGuildMember() : Boolean
      {
         var result:Boolean = false;
         var fo:Object = this.getFeatureData();
         if(Boolean(fo) && fo[CURRENT_GUILD_ID] != -1)
         {
            result = true;
         }
         return result;
      }
      
      public function isLeader() : Boolean
      {
         var isAdmin:Boolean = false;
         var fo:Object = this.getFeatureData();
         if(Boolean(fo) && fo[MEMBERSHIP_STATUS] >= LEADER)
         {
            isAdmin = true;
         }
         return isAdmin;
      }
      
      public function isOwner() : Boolean
      {
         var isOwner:Boolean = false;
         var fo:Object = this.getFeatureData();
         if(Boolean(fo) && fo[MEMBERSHIP_STATUS] == OWNER)
         {
            isOwner = true;
         }
         return isOwner;
      }
      
      public function getZId() : String
      {
         var zid:String = "";
         var fo:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILd_VIEW_INFO);
         if(Boolean(fo) && Boolean(fo["playerId"]))
         {
            zid = fo["playerId"];
         }
         return zid;
      }
      
      public function canGiveKey() : Boolean
      {
         var result:Boolean = false;
         var fo:Object = this.getFeatureData();
         if(Boolean(fo) && Boolean(fo["keyCount"]) && fo["keyCount"] > 0)
         {
            result = true;
         }
         return result;
      }
      
      public function getTimeRemainingToCollectConsumable(slotIndex:int) : int
      {
         var key:String = m_featureName + COLLECT_TIME_KEY + slotIndex.toString();
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         var timeRemaining:int = THROTTLE_TIME_ARRAY[slotIndex] - timeSinceLastFeed;
         return timeRemaining > 0 ? timeRemaining : 0;
      }
      
      public function canCollectConsuamble(slotIndex:int) : Boolean
      {
         return this.getTimeRemainingToCollectConsumable(slotIndex) <= 0;
      }
      
      public function getKeyCount() : int
      {
         var result:int = 0;
         var fo:Object = this.getFeatureData();
         if(Boolean(fo) && Boolean(fo["keyCount"]))
         {
            result = int(fo["keyCount"]);
         }
         return result;
      }
      
      public function getRequestedKeyCount() : int
      {
         var count:int = 0;
         var fo:Object = this.getFeatureData();
         if(Boolean(fo) && Boolean(fo["requestedKeyCount"]))
         {
            count = int(fo["requestedKeyCount"]);
         }
         return count;
      }
      
      public function rejectJoinRequest(guildId:String) : void
      {
         var fo:Object = this.getFeatureData();
         if(fo.hasOwnProperty("ignoredList"))
         {
            fo["ignoredList"].push(guildId);
         }
         else
         {
            fo["ignoredList"] = [];
            fo["ignoredList"].push(guildId);
         }
         setFeatureData(fo);
         if(this.m_guildListWindow)
         {
            this.m_guildListWindow.setGuildListData(this.getGuildListData());
            this.m_guildListWindow.refreshWindow();
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"rejectJoinRequest",null,[m_featureName,guildId]),true);
      }
      
      private function get eventManager() : GuildEventManager
      {
         return GuildEventManager.getInstance();
      }
      
      public function getGuildId() : String
      {
         var guildId:String = "";
         var fo:Object = this.getFeatureData();
         if(Boolean(fo) && Boolean(fo[CURRENT_GUILD_ID]))
         {
            guildId = fo[CURRENT_GUILD_ID].toString();
         }
         return guildId;
      }
      
      public function isSinkForEventActive() : Boolean
      {
         return GuildEventManager.isSinkForEventActive();
      }
      
      public function hasSufficientKeysToEnterInEvent() : Boolean
      {
         var result:Boolean = false;
         if(GuildManager.getInstance().getKeyCount() >= GuildEventManager.getInstance().getKeysRequiredForCurrentEvent())
         {
            result = true;
         }
         return result;
      }
      
      public function deductKeysForEvent(requiredKeys:int) : void
      {
         var fo:Object = this.getFeatureData();
         if(fo)
         {
            fo["keyCount"] -= requiredKeys;
            setFeatureData(fo);
         }
      }
      
      public function getGuildMembersStatus() : Array
      {
         var memberIndex:int = 0;
         var memberInfo:Object = null;
         var fo:Object = null;
         var membersData:Array = [];
         var membersInfoData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILd_MEMBERS_INFO);
         if(membersInfoData)
         {
            for(memberIndex = 0; memberIndex < membersInfoData.length; memberIndex++)
            {
               memberInfo = {};
               memberInfo["pic_square"] = membersInfoData[memberIndex]["pic_square"];
               memberInfo["name"] = membersInfoData[memberIndex]["name"];
               if(this.getZId() == membersInfoData[memberIndex]["playerId"])
               {
                  fo = this.getFeatureData();
                  if(fo.hasOwnProperty("keyCount"))
                  {
                     memberInfo["keyCount"] = fo["keyCount"];
                  }
                  if(GuildEventManager.getInstance().hasUserStartedCurrentEvent())
                  {
                     memberInfo["entry_status"] = 1;
                  }
                  else
                  {
                     memberInfo["entry_status"] = 0;
                  }
               }
               else
               {
                  memberInfo["keyCount"] = membersInfoData[memberIndex]["ClanToken"];
                  memberInfo["entry_status"] = membersInfoData[memberIndex]["entry_status"];
               }
               memberInfo["index"] = memberIndex;
               membersData.push(memberInfo);
            }
         }
         return membersData;
      }
      
      public function getGuildeventJoinedMembersCount() : int
      {
         var memberIndex:int = 0;
         var fo:Object = null;
         var joinCount:int = 0;
         var membersInfoData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILd_MEMBERS_INFO);
         if(membersInfoData)
         {
            for(memberIndex = 0; memberIndex < membersInfoData.length; memberIndex++)
            {
               if(this.getZId() == membersInfoData[memberIndex]["playerId"])
               {
                  fo = this.getFeatureData();
                  if(GuildEventManager.getInstance().hasUserStartedCurrentEvent())
                  {
                     joinCount++;
                  }
               }
               else if(membersInfoData[memberIndex]["entry_status"] == 1)
               {
                  joinCount++;
               }
            }
         }
         return joinCount;
      }
      
      public function guildMembersCount() : int
      {
         var memberCount:int = 0;
         var membersInfoData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILd_MEMBERS_INFO);
         if(membersInfoData)
         {
            memberCount = int(membersInfoData.length);
         }
         return memberCount;
      }
      
      public function grantEventEntryPoints() : void
      {
         var pointsBonus:int = 80;
         var fo:Object = this.getFeatureData();
         if(fo.hasOwnProperty(PLAYER_GUILD_POINTS))
         {
            fo[PLAYER_GUILD_POINTS] = 0;
         }
         fo[PLAYER_GUILD_POINTS] += pointsBonus;
         setFeatureData(fo);
         var guildPoints:int = this.getGuildtotalPoints();
         this.saveGuildtotalPoints(guildPoints + pointsBonus);
         if(this.m_guildMainWindow)
         {
            this.m_guildMainWindow.refreshKeyFrame();
            this.m_guildMainWindow.updatePlayerPointsDoober(pointsBonus);
         }
      }
      
      public function getGuildMembersOrderBoardStatus() : Array
      {
         var memberIndex:int = 0;
         var memberInfo:Object = null;
         var membersData:Array = [];
         var membersInfoData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILd_MEMBERS_INFO);
         if(membersInfoData)
         {
            for(memberIndex = 0; memberIndex < membersInfoData.length; memberIndex++)
            {
               memberInfo = {};
               memberInfo["pic_square"] = membersInfoData[memberIndex]["pic_square"];
               memberInfo["name"] = membersInfoData[memberIndex]["name"];
               memberInfo["role"] = membersInfoData[memberIndex]["role"];
               if(this.getZId() == membersInfoData[memberIndex]["playerId"] && GuildEventManager.getInstance().hasUserStartedCurrentEvent())
               {
                  memberInfo[GuildEventManager.KEY_OB_POINTS] = GuildEventManager.getInstance().getUserPoints();
                  memberInfo[GuildEventManager.KEY_TASK_COMPLETED] = GuildEventManager.getInstance().getNoOfTasksDone();
                  memberInfo[GuildEventManager.HELPED_TASK_COUNT] = GuildEventManager.getInstance().getHelpedTaskCount();
                  membersData.push(memberInfo);
               }
               else if(membersInfoData[memberIndex]["entry_status"] == 1)
               {
                  memberInfo[GuildEventManager.KEY_OB_POINTS] = membersInfoData[memberIndex][GuildEventManager.KEY_OB_POINTS];
                  memberInfo[GuildEventManager.KEY_TASK_COMPLETED] = membersInfoData[memberIndex][GuildEventManager.KEY_TASK_COMPLETED];
                  memberInfo[GuildEventManager.HELPED_TASK_COUNT] = membersInfoData[memberIndex][GuildEventManager.HELPED_TASK_COUNT];
                  membersData.push(memberInfo);
               }
            }
         }
         return membersData;
      }
      
      public function hasGuildKeyCapReached() : Boolean
      {
         var hasLimitReached:Boolean = false;
         var fo:Object = this.getFeatureData();
         if(fo.hasOwnProperty("keyCount") && int(fo["keyCount"]) >= 90)
         {
            hasLimitReached = true;
         }
         return hasLimitReached;
      }
      
      public function canTriggerReceivedHelpFTUE() : Boolean
      {
         return this.m_receivedHelp;
      }
      
      public function setDefaulHudText() : void
      {
         var guildId:int = -1;
         var fo:Object = this.getFeatureData();
         if(Boolean(fo) && Boolean(fo[CURRENT_GUILD_ID]))
         {
            guildId = int(fo[CURRENT_GUILD_ID]);
         }
         if(guildId == -1)
         {
            this.m_guildCreationHud.hudText = "Farmer\'s Clan!";
         }
         else if(GuildEventManager.getTimeLeftForEventStart() < FarmGameUtil.NUM_SECS_IN_DAY && GuildEventManager.getTimeLeftForEventStart() > 0)
         {
            if(!Global.player.getSeenFlag(GuildEventManager.getInstance().featureName + "_Event_hud_notification"))
            {
               Global.player.setSeenFlag(GuildEventManager.getInstance().featureName + "_Event_hud_notification");
               this.m_guildCreationHud.notifText = "Get ready for event";
            }
         }
         else if(GuildEventManager.getInstance().isEventActive())
         {
            this.m_guildCreationHud.hudText = GuildEventManager.getInstance().getGuildEventName();
         }
         else
         {
            this.m_guildCreationHud.hudText = this.getGuildName();
         }
      }
      
      public function getGuildName() : String
      {
         var guildName:String = "";
         var fo:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILd_VIEW_INFO);
         if(fo)
         {
            guildName = fo["name"];
         }
         return guildName;
      }
      
      public function setHudNotifText(text:String) : *
      {
         this.m_guildCreationHud.notifText = text;
      }
   }
}

