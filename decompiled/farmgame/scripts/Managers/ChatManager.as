package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Friend;
   import Classes.Zoom.ZoomMessage;
   import Display.FriendBar.FriendBarSlot;
   import Display.FriendBar.NPCSlot;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.OnlineStatusEvent;
   import Events.ZoomMessageEvent;
   import Events.ZoomPresenceEvent;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.ChatWindow;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.xml.XMLNode;
   import flash.xml.XMLNodeType;
   
   public class ChatManager extends EventDispatcher
   {
      
      public static var EVENTTYPE_CHAT:String = "chat";
      
      public static var EVENTTYPE_SELF_CHAT:String = "selfChat";
      
      public static var EVENTTYPE_CHAT_WINDOW_OPEN:String = "openChat";
      
      public static const FARM_TALK_HOLDOUT_UID_SUFFIXES_RUNTIME_PARAM:String = "FARM_TALK_HOLDOUT_UID_SUFFIXES";
      
      private static var m_instance:ChatManager = null;
      
      private static var m_messages:Object = new Object();
      
      private static var m_onlineStatuses:Object = new Object();
      
      private static var m_farmTalkEnabledCache:Object = new Object();
      
      private static var m_currentChatWindowOpen:String = "0";
      
      public function ChatManager()
      {
         super();
      }
      
      public static function get instance() : ChatManager
      {
         if(m_instance == null)
         {
            m_instance = new ChatManager();
         }
         return m_instance;
      }
      
      public static function init() : void
      {
         ZoomManager.instance.addEventListener(ZoomManager.EVENTTYPE_PRESENCE_CHANGED,onPresenceChanged);
         ZoomManager.instance.addEventListener(ChatManager.EVENTTYPE_CHAT,onZoomChatMsgReceived);
         ZoomManager.instance.addEventListener(ChatManager.EVENTTYPE_SELF_CHAT,onZoomSelfChatMsgReceived);
      }
      
      public static function onPresenceChanged(event:ZoomPresenceEvent) : void
      {
         var userStatus:String = null;
         var zMessage:ZoomMessage = null;
         var uid:* = event.m_uid;
         var gameId:int = event.m_gameId;
         var status:String = event.m_status;
         var neighbors:Array = Global.friendManager.neighborUids;
         var validUid:Boolean = false;
         for(var i:int = 0; i < neighbors.length; i++)
         {
            if(neighbors[i] == uid)
            {
               validUid = true;
               break;
            }
         }
         if(validUid && !instance.isFarmTalkEnabled(uid))
         {
            validUid = false;
         }
         if(validUid)
         {
            userStatus = "";
            switch(status)
            {
               case "online":
                  userStatus = OnlineStatusEvent.STATUS_ONLINE;
                  break;
               case "offline":
               default:
                  userStatus = OnlineStatusEvent.STATUS_OFFLINE;
            }
            m_onlineStatuses[uid] = userStatus;
            if(Global.player.farmTalkPermission == true)
            {
               zMessage = new ZoomMessage("status",uid,"");
               instance.dispatchEvent(new OnlineStatusEvent(userStatus,zMessage));
               if((userStatus == OnlineStatusEvent.STATUS_ONLINE || userStatus == OnlineStatusEvent.STATUS_OFFLINE) && !ChatManager.currentChatWindowOpen)
               {
                  Global.ui.m_friendBar.autoSortStart();
               }
            }
         }
      }
      
      private static function htmlEscape(str:String) : String
      {
         return XML(new XMLNode(XMLNodeType.TEXT_NODE,str)).toXMLString();
      }
      
      public static function onZoomChatMsgReceived(event:ZoomMessageEvent) : void
      {
         var slot:FriendBarSlot = null;
         var msgText:String = null;
         var newMessage:ZoomMessage = null;
         var fromUid:String = event.m_fromUid;
         var allFriendSlots:Array = Global.ui.m_friendBar.allSlots;
         var allFriendUids:Array = new Array();
         for each(slot in allFriendSlots)
         {
            allFriendUids.push(slot.friend.uid);
         }
         if(allFriendUids.indexOf(fromUid) >= 0)
         {
            msgText = unescape(event.m_message);
            msgText = htmlEscape(msgText);
            newMessage = new ZoomMessage(event.type,fromUid,msgText,event.m_timeStamp);
            if(!m_messages.hasOwnProperty(fromUid))
            {
               m_messages[fromUid] = new Array();
            }
            (m_messages[fromUid] as Array).push(newMessage);
            if(Global.player.farmTalkPermission == true)
            {
               instance.dispatchEvent(new OnlineStatusEvent(OnlineStatusEvent.NEW_MESSAGE,newMessage));
               if(event.type == EVENTTYPE_CHAT && !ChatManager.currentChatWindowOpen)
               {
                  Global.ui.m_friendBar.autoSortStart();
               }
            }
         }
      }
      
      public static function onZoomSelfChatMsgReceived(event:ZoomMessageEvent) : void
      {
         var otherPersonUid:String = event.m_extraData;
         onZoomChatMsgReceived(new ZoomMessageEvent(event.type,otherPersonUid,event.m_message,event.m_timeStamp));
      }
      
      public static function onClickMessage(slotIndex:int, uid:String) : void
      {
         var zMessage:ZoomMessage = null;
         var numUnreadMsgs:int = 0;
         if(!m_onlineStatuses.hasOwnProperty(uid))
         {
            m_onlineStatuses[uid] = OnlineStatusEvent.STATUS_OFFLINE;
         }
         var friendInfo:Friend = Global.friendManager.getFriendData(uid);
         if(!m_messages.hasOwnProperty(uid))
         {
            m_messages[uid] = new Array();
         }
         if(Global.player.farmTalkPermission == true)
         {
            zMessage = new ZoomMessage("status",uid,"");
            instance.dispatchEvent(new OnlineStatusEvent(m_onlineStatuses[uid],zMessage));
            numUnreadMsgs = getNumUnreadMessageFrom(uid);
            markMessagesReadFromUid(uid);
         }
         var hasUnreadMsgs:Boolean = numUnreadMsgs > 0 ? true : false;
         UI.displayPopup(new ChatWindow(friendInfo,m_messages[uid] as Array,slotIndex,hasUnreadMsgs));
         m_currentChatWindowOpen = uid;
         instance.dispatchEvent(new Event(EVENTTYPE_CHAT_WINDOW_OPEN));
      }
      
      public static function markMessagesReadFromUid(uid:String) : void
      {
         var numUnreadMsgs:int = 0;
         var message:ZoomMessage = null;
         var time:Number = NaN;
         var params:Array = null;
         var groupId:String = null;
         var onlineStatus:String = null;
         var messages:Array = new Array();
         if(m_messages.hasOwnProperty(uid))
         {
            messages = m_messages[uid] as Array;
         }
         if(messages.length > 0)
         {
            numUnreadMsgs = getNumUnreadMessageFrom(uid);
            if(numUnreadMsgs > 0)
            {
               groupId = Global.friendManager.getFriendData(uid).isCommunityNeighbor ? "community" : "fb";
               onlineStatus = ChatManager.getOnlineStatus(uid) == OnlineStatusEvent.STATUS_OFFLINE ? "offline" : "online";
               StatsManager.social("chat",String(uid),"messages_viewed","",groupId,onlineStatus,numUnreadMsgs,Global.worldManager.currentWorldType);
            }
            message = messages[messages.length - 1];
            time = message.timeStamp;
            params = new Array(uid.toString(),time);
            TransactionManager.addTransaction(new TGenericTransaction("ChatService","setLastMessageReadTime",null,params));
            Global.player.setChatLastMessageReadTime(uid,time);
         }
      }
      
      public static function hasUnreadMessageFrom(friendUid:String) : Boolean
      {
         var lastMessageReadTimeStamp:Number = NaN;
         var friendMessages:Array = null;
         var i:* = 0;
         var message:ZoomMessage = null;
         var lastMessageTimeStamp:Number = NaN;
         var ret:Boolean = false;
         if(m_messages.hasOwnProperty(friendUid))
         {
            lastMessageReadTimeStamp = Global.player.getChatLastMessageReadTime(friendUid);
            friendMessages = m_messages[friendUid] as Array;
            for(i = int(friendMessages.length - 1); i >= 0; i--)
            {
               message = friendMessages[i];
               if(message.type == EVENTTYPE_CHAT)
               {
                  lastMessageTimeStamp = message.timeStamp;
                  ret = lastMessageTimeStamp > lastMessageReadTimeStamp;
                  break;
               }
            }
         }
         return ret;
      }
      
      public static function getNumUnreadMessageFrom(friendUid:String) : int
      {
         var lastMessageReadTimeStamp:Number = NaN;
         var friendMessages:Array = null;
         var i:* = 0;
         var message:ZoomMessage = null;
         var numUnreadMsgs:int = 0;
         if(m_messages.hasOwnProperty(friendUid))
         {
            lastMessageReadTimeStamp = Global.player.getChatLastMessageReadTime(friendUid);
            friendMessages = m_messages[friendUid] as Array;
            for(i = int(friendMessages.length - 1); i >= 0; i--)
            {
               message = friendMessages[i];
               if(message.type == EVENTTYPE_CHAT)
               {
                  if(message.timeStamp <= lastMessageReadTimeStamp)
                  {
                     break;
                  }
                  numUnreadMsgs++;
               }
            }
         }
         return numUnreadMsgs;
      }
      
      public static function getNumUnreadConversations() : int
      {
         var uid:String = null;
         var result:int = 0;
         for(uid in m_messages)
         {
            if(hasUnreadMessageFrom(uid))
            {
               result++;
            }
         }
         return result;
      }
      
      public static function get currentChatWindowOpen() : String
      {
         return m_currentChatWindowOpen;
      }
      
      public static function set currentChatWindowOpen(uid:String) : void
      {
         m_currentChatWindowOpen = uid;
      }
      
      public static function getOnlineStatus(uid:String) : String
      {
         var status:String = OnlineStatusEvent.STATUS_OFFLINE;
         if(m_onlineStatuses.hasOwnProperty(uid))
         {
            status = m_onlineStatuses[uid];
         }
         return status;
      }
      
      private static function countNeighborsHelper(neighborUids:Array, kingdom:String) : void
      {
         var uid:String = null;
         var status:String = null;
         var numOnlineFriends:int = 0;
         var numOfflineFriends:int = 0;
         for(var i:int = 0; i < neighborUids.length; i++)
         {
            uid = String(neighborUids[i]);
            if(uid != "0" && uid != Global.player.uid)
            {
               status = ChatManager.getOnlineStatus(uid);
               if(status === OnlineStatusEvent.STATUS_ONLINE)
               {
                  numOnlineFriends++;
               }
            }
         }
         FarmStatsManager.count("chat",kingdom,"online","","",Global.worldManager.currentWorldType,numOnlineFriends);
         numOfflineFriends = neighborUids.length - numOnlineFriends;
         FarmStatsManager.count("chat",kingdom,"offline","","",Global.worldManager.currentWorldType,numOfflineFriends);
      }
      
      public static function countOnlineNeighbors() : void
      {
         var friend:Friend = null;
         var communityNeighbors:Array = new Array();
         var regularNeighbors:Array = new Array();
         for each(friend in Global.friendManager.neighbors)
         {
            if(friend.isCommunityNeighbor)
            {
               communityNeighbors.push(friend.uid);
            }
            else
            {
               regularNeighbors.push(friend.uid);
            }
         }
         countNeighborsHelper(regularNeighbors,"num_fb_neighbors");
         countNeighborsHelper(communityNeighbors,"num_community_neighbors");
      }
      
      public static function farmTalkSurface() : void
      {
         var slot:FriendBarSlot = null;
         var slotId:String = null;
         var friendSlots:Array = Global.ui.m_friendBar.slots;
         for(var slotIndex:* = int(friendSlots.length - 1); slotIndex >= 0; slotIndex--)
         {
            slot = friendSlots[slotIndex];
            if(!slot.m_empty && !(slot is NPCSlot))
            {
               slotId = String(slot.uid);
               if(slotId != Global.player.uid)
               {
                  slot.openChatWindow();
                  break;
               }
            }
         }
      }
      
      public function isFarmTalkEnabled(uid:* = 0) : Boolean
      {
         var experimentCheck:Boolean = false;
         var holdoutUidSuffixes:String = null;
         var uidStr:String = null;
         var suffixArray:Array = null;
         var i:int = 0;
         var suffix:String = null;
         var ret:Boolean = false;
         if(uid == 0)
         {
            uid = Global.player.uid;
         }
         if(m_farmTalkEnabledCache.hasOwnProperty(uid))
         {
            ret = Boolean(m_farmTalkEnabledCache[uid]);
         }
         else
         {
            experimentCheck = true;
            uid = String(uid);
            if(uid == Global.player.uid)
            {
               experimentCheck = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FARM_TALK) >= 2;
            }
            if(experimentCheck)
            {
               ret = true;
               holdoutUidSuffixes = Global.flashHotParams[FARM_TALK_HOLDOUT_UID_SUFFIXES_RUNTIME_PARAM];
               if(Boolean(holdoutUidSuffixes) && holdoutUidSuffixes != "")
               {
                  uidStr = uid.toString();
                  suffixArray = holdoutUidSuffixes.split(",");
                  for(i = 0; i < suffixArray.length; i++)
                  {
                     suffix = suffixArray[i];
                     if(suffix == uidStr.substring(uidStr.length - suffix.length))
                     {
                        ret = false;
                        break;
                     }
                  }
               }
            }
            m_farmTalkEnabledCache[uid] = ret;
         }
         return ret;
      }
   }
}

