package Classes.MatchMaking
{
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TGenericTransaction;
   import com.adobe.serialization.json.JSON;
   import flash.events.DataEvent;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.Socket;
   import flash.utils.Timer;
   
   public class MatchMakingManager extends EventDispatcher
   {
      
      private static var m_instance:MatchMakingManager;
      
      public static const ZOOM_DEFAULT_ADDRESS:String = "zoom.zynga.com";
      
      public static const ZOOM_DEFAULT_PORT:int = 8890;
      
      public static var EVENTTYPE_PRESENCE_CHANGED:String = "presenceChanged";
      
      public static var EVENTTYPE_CHAT:String = "chat";
      
      public static var EVENTTYPE_GAMEREQUEST:String = "gameRequest";
      
      public static var EVENTTYPE_GUILDCHAT_MESSAGE:String = "guildChatMessageRecieved";
      
      private var m_address:String;
      
      private var m_port:int;
      
      private var m_heartbeat:ZoomHeartbeatHandler;
      
      private var m_uid:String;
      
      private var m_friendList:Array;
      
      private var m_notif:int;
      
      private var m_player2UID:String;
      
      private var m_gameId:String;
      
      private var m_matchTimer:Timer;
      
      private var m_timerRetries:int = 0;
      
      private var m_numUIDsRequested:int = 0;
      
      private var m_matchSuccessCallback:Function;
      
      private var m_matchFailureCallback:Function;
      
      private var m_socket:Socket = null;
      
      private var m_zoomRetryCount:int = 0;
      
      private var m_waitTimeForResponse:Number = 0;
      
      private var m_matchFound:Boolean = false;
      
      public function MatchMakingManager(e:SingletonEnforcer)
      {
         super();
      }
      
      public static function getInstance() : MatchMakingManager
      {
         if(m_instance == null)
         {
            m_instance = new MatchMakingManager(new SingletonEnforcer());
         }
         return m_instance;
      }
      
      private static function unserialize(message:String) : Object
      {
         var result:Object = null;
         try
         {
            result = com.adobe.serialization.json.JSON.decode(message);
         }
         catch(error:Error)
         {
         }
         return result;
      }
      
      public function initZoom(address:String = "zoom.zynga.com", port:int = 8890) : void
      {
         if(this.m_socket != null)
         {
            throw new Error("SocketConnection already exists:");
         }
         this.m_address = address;
         this.m_port = port;
      }
      
      public function createSession(uid:String, friendList:Array, notif:int = 1) : void
      {
         if(this.m_socket != null)
         {
            throw new Error("SocketConnection already exists:");
         }
         this.m_uid = uid;
         this.m_friendList = friendList;
         this.m_notif = notif;
         this.m_socket = new Socket(this.m_address,this.m_port);
         this.m_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.zoomError);
         this.m_socket.addEventListener(ProgressEvent.SOCKET_DATA,this.zoomRead);
         this.m_socket.addEventListener(Event.CONNECT,this.zoomConnected);
         this.m_socket.addEventListener(IOErrorEvent.IO_ERROR,this.zoomError);
         this.m_socket.addEventListener(Event.CLOSE,this.zoomClose);
      }
      
      public function isConnected() : Boolean
      {
         if(this.m_socket)
         {
            return this.m_socket.connected;
         }
         return false;
      }
      
      public function setUserActive() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction("MatchService","setUserActive",null),true);
      }
      
      public function setUserInactive() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction("MatchService","setUserInactive",null),true);
      }
      
      public function set matchFound(found:Boolean) : void
      {
         this.m_matchFound = found;
      }
      
      public function getMatchFromActivePool(successCallback:Function = null, failureCallBack:Function = null) : void
      {
         this.m_matchSuccessCallback = successCallback;
         this.m_matchFailureCallback = failureCallBack;
         this.m_numUIDsRequested = 5;
         this.m_waitTimeForResponse = 4000;
         this.getUIDsFromActivePool(this.m_numUIDsRequested,this.onUIDSuccess,this.m_matchFailureCallback);
      }
      
      public function getMatchFromOnlinePool(successCallback:Function = null, failureCallBack:Function = null) : void
      {
         this.m_matchSuccessCallback = successCallback;
         this.m_matchFailureCallback = failureCallBack;
         this.m_numUIDsRequested = 3;
         this.m_waitTimeForResponse = 40000;
         this.getUIDsFromOnlinePool(this.m_numUIDsRequested,this.onUIDSuccess,this.m_matchFailureCallback);
      }
      
      public function createGameId(player1:String, player2:String) : String
      {
         var gameId:String = player1.slice(player1.length - 3,player1.length) + "_" + player2.slice(player2.length - 3,player2.length);
         var time:int = GlobalEngine.serverTime / 1000;
         time -= time % 60;
         return gameId + ("_" + time);
      }
      
      public function sendMessage(msg:String, uid:String) : void
      {
         var message:String = "4 ochat to:" + uid + " msg:" + encodeURIComponent(msg);
         if(this.m_socket.connected)
         {
            this.m_socket.writeUTFBytes(message + "\n");
            this.m_socket.flush();
         }
      }
      
      public function sendGameRequest(uid:String) : void
      {
         this.m_gameId = this.createGameId(Global.player.uid,uid);
         TransactionManager.addTransaction(new TGenericTransaction("MatchService","sendGameRequest",null,[uid,this.m_gameId]),true);
      }
      
      public function addZoomFriend(uid:String) : void
      {
         var message:String = "4 friendlist add:" + uid;
         if(this.m_socket.connected)
         {
            this.m_socket.writeUTFBytes(message + "\n");
            this.m_socket.flush();
         }
      }
      
      public function removeZoomFriend(uid:String) : void
      {
         var message:String = "4 friendlist del:" + uid;
         if(this.m_socket.connected)
         {
            this.m_socket.writeUTFBytes(message + "\n");
            this.m_socket.flush();
         }
      }
      
      public function getFBProfile(uid:String, callback:Function) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction("MatchService","getFBProfile",callback,[uid]),true);
      }
      
      private function onchatMessageReceived(e:DataEvent) : void
      {
         if(e.data.indexOf("Accepted:" + this.m_gameId) != -1 && !this.m_matchFound)
         {
            if(this.m_matchTimer)
            {
               this.m_matchTimer.stop();
            }
            this.addZoomFriend(this.m_player2UID);
            this.sendMessage("StartGame:" + this.m_gameId,this.m_player2UID);
            removeEventListener(MatchMakingManager.EVENTTYPE_CHAT,this.onchatMessageReceived);
            if(this.m_matchSuccessCallback is Function)
            {
               this.m_matchSuccessCallback(this.m_player2UID,this.m_gameId);
            }
         }
      }
      
      private function onUIDSuccess(uids:Array) : void
      {
         var onTimerExpired:Function = function(event:TimerEvent):void
         {
            ++m_timerRetries;
            if(m_matchFound || m_timerRetries >= m_numUIDsRequested || m_timerRetries >= uids.length)
            {
               m_matchTimer.stop();
               if(m_matchFailureCallback is Function)
               {
                  removeEventListener(MatchMakingManager.EVENTTYPE_CHAT,onchatMessageReceived);
                  m_matchFailureCallback();
               }
            }
            else
            {
               m_player2UID = uids[m_timerRetries];
               MatchMakingManager.getInstance().addZoomFriend(m_player2UID);
               MatchMakingManager.getInstance().sendGameRequest(m_player2UID);
            }
         };
         this.m_player2UID = uids[0];
         addEventListener(MatchMakingManager.EVENTTYPE_CHAT,this.onchatMessageReceived);
         MatchMakingManager.getInstance().addZoomFriend(this.m_player2UID);
         MatchMakingManager.getInstance().sendGameRequest(this.m_player2UID);
         if(this.m_matchTimer != null)
         {
            this.m_matchTimer.stop();
            this.m_matchTimer = null;
         }
         this.m_matchTimer = new Timer(this.m_waitTimeForResponse);
         this.m_timerRetries = 0;
         this.m_matchTimer.addEventListener(TimerEvent.TIMER,onTimerExpired);
         this.m_matchTimer.start();
      }
      
      public function getUIDsFromActivePool(numOfUIDs:int, successCallback:Function = null, failureCallBack:Function = null) : void
      {
         var onActiveMatchResponse:Function = function(result:Object):void
         {
            var activeUsersArray:Array = null;
            var uid:String = null;
            var success:Boolean = false;
            if(result.activeUsers)
            {
               activeUsersArray = new Array();
               for each(uid in result.activeUsers)
               {
                  activeUsersArray.push(uid);
               }
               if(activeUsersArray.indexOf(Global.player.uid) != -1)
               {
                  activeUsersArray.splice(activeUsersArray.indexOf(Global.player.uid),1);
               }
               if(activeUsersArray.length > 0)
               {
                  success = true;
               }
            }
            if(success && successCallback is Function)
            {
               successCallback(activeUsersArray);
            }
            else if(!success && failureCallBack is Function)
            {
               failureCallBack();
            }
         };
         TransactionManager.addTransaction(new TGenericTransaction("MatchService","getActiveUsers",onActiveMatchResponse,[numOfUIDs]),true);
      }
      
      public function getUIDsFromOnlinePool(numOfMatches:int, successCallback:Function = null, failureCallBack:Function = null) : void
      {
         var onOnlineMatchResponse:Function = function(result:Object):void
         {
            var activeUsersArray:Array = null;
            var uid:String = null;
            var success:Boolean = false;
            if(result.onlineUsers)
            {
               activeUsersArray = new Array();
               for each(uid in result.onlineUsers)
               {
                  activeUsersArray.push(uid);
               }
               if(activeUsersArray.indexOf(Global.player.uid) != -1)
               {
                  activeUsersArray.splice(activeUsersArray.indexOf(Global.player.uid),1);
               }
               if(activeUsersArray.length > 0)
               {
                  success = true;
               }
            }
            if(success && successCallback is Function)
            {
               successCallback(activeUsersArray);
            }
            else if(!success && failureCallBack is Function)
            {
               failureCallBack();
            }
         };
         TransactionManager.addTransaction(new TGenericTransaction("MatchService","getOnlineUsers",onOnlineMatchResponse,[numOfMatches]),true);
      }
      
      private function zoomError(e:ErrorEvent) : void
      {
         ++this.m_zoomRetryCount;
         FarmStatsManager.count("SocialBetaFeature","ZoomError",this.m_zoomRetryCount.toString());
         if(this.m_zoomRetryCount < 3)
         {
            this.m_socket = new Socket(this.m_address,this.m_port);
         }
      }
      
      private function zoomClose(event:Event) : void
      {
         FarmStatsManager.count("SocialBetaFeature","ZoomError");
         this.m_heartbeat.stop();
      }
      
      private function zoomRead(e:Event) : void
      {
         var msgData:String = null;
         var msg:String = this.m_socket.readUTFBytes(this.m_socket.bytesAvailable);
         if(msg.indexOf("heartbeat") == -1)
         {
            if(msg.indexOf("idarwin") != -1)
            {
               msgData = this.decodeDarwinMessage(msg);
               m_instance.dispatchEvent(new DataEvent(MatchMakingManager.EVENTTYPE_GUILDCHAT_MESSAGE,false,false,msgData));
            }
            else
            {
               msg = this.parseZoomMessage(msg);
               m_instance.dispatchEvent(new DataEvent(MatchMakingManager.EVENTTYPE_CHAT,false,false,msg));
            }
         }
      }
      
      private function zoomConnected(e:Event) : void
      {
         FarmStatsManager.count("SocialBetaFeature","ZoomConnected");
         var msg:String = "4 session uid:" + this.m_uid + " gid:63" + " notif:" + this.m_notif;
         this.m_socket.writeUTFBytes(msg + "\n");
         this.m_socket.flush();
         TransactionManager.addTransaction(new TGenericTransaction("MatchService","registerPresence",null),true);
         this.m_heartbeat = new ZoomHeartbeatHandler(this);
         this.m_heartbeat.start();
      }
      
      private function decodeDarwinMessage(msg:String) : String
      {
         var parts:Array = msg.split(" ");
         msg = "";
         for(var i:int = 2; i < parts.length; i++)
         {
            msg += parts[i] + " ";
         }
         return msg.slice(4,msg.length - 1);
      }
      
      private function parseZoomMessage(msg:String) : String
      {
         var result:String = decodeURIComponent(msg);
         return result.slice(0,result.length - 1);
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
