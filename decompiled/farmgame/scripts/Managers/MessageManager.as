package Managers
{
   import Classes.Friend;
   import Classes.Message;
   import Classes.MessageAvatar;
   import Classes.util.ZLocUtils;
   import Display.EmailPopup;
   import Display.HUD.MessageCenterButton;
   import Engine.Classes.SocialNetworkUser;
   import Engine.Classes.WorldObject;
   import Engine.Helpers.Vector3;
   import Engine.Managers.TransactionManager;
   import GameMode.GMMessageSignPlace;
   import Transactions.TAllowMessageEmails;
   import Transactions.TMarkSeenMessages;
   import Transactions.TPostMessage;
   import Transactions.TRemoveMessage;
   
   public class MessageManager
   {
      
      public static const AVATAR_POSITIONS:Array = [[9,0.5],[-10,-3],[-8,-8],[-2,5],[-2,-10],[5,5],[-8,3],[4,9],[3.5,-7],[3,-1]];
      
      public static const COMMENT_BOX_EMAIL_VARIANT_SOFTGATE:int = 1;
      
      private static var m_instance:MessageManager = null;
      
      private static var m_canInstantiate:Boolean = false;
      
      private var m_messages:Array = new Array();
      
      private var m_allowSendEmails:Boolean = false;
      
      private var m_messageAvatars:Array = new Array();
      
      private var m_emailPermissionsCallback:Function;
      
      private var m_defaultAvatarBasePosition:Vector3 = null;
      
      public function MessageManager()
      {
         super();
         if(!m_canInstantiate)
         {
            throw new Error("Cannot call MessageManager constructor directly - use getInstance() instead.");
         }
         this.m_defaultAvatarBasePosition = this.calcDefaultAvatarBasePosition();
      }
      
      public static function getInstance() : MessageManager
      {
         if(null == m_instance)
         {
            m_canInstantiate = true;
            m_instance = new MessageManager();
            m_canInstantiate = false;
         }
         return m_instance;
      }
      
      public static function getPlayerName(uid:String, getFullName:Boolean = true) : String
      {
         var friendPlayer:Friend = null;
         var farmOwner:String = null;
         var farmOwnerGender:String = null;
         var snUser:SocialNetworkUser = null;
         var name:String = "";
         if(uid == Global.player.snUser.uid)
         {
            snUser = Global.player.snUser;
         }
         else
         {
            friendPlayer = Global.friendManager.getFriendData(uid);
            if(friendPlayer)
            {
               snUser = friendPlayer.snUser;
            }
            else if(Global.worldManager.isVisiting())
            {
               farmOwner = Global.worldManager.getVisitName(true);
               if(Boolean(farmOwner) && farmOwner.length > 1)
               {
                  farmOwnerGender = Global.worldManager.getVisitGender();
                  name = ZLocUtils.t("Dialogs","message_center_notfriend_name",{"user":ZLocUtils.tn(farmOwner,ZLocUtils.tg(farmOwnerGender))});
               }
            }
         }
         if(snUser)
         {
            if(getFullName)
            {
               name = snUser.name;
            }
            else
            {
               name = snUser.firstName;
            }
         }
         return name;
      }
      
      public static function getPlayerGender(uid:String) : String
      {
         var friendPlayer:Friend = null;
         var gender:String = "male";
         if(uid == Global.player.snUser.uid)
         {
            gender = Global.player.snUser.gender;
         }
         else
         {
            friendPlayer = Global.friendManager.getFriendData(uid);
            if(Boolean(friendPlayer) && Boolean(friendPlayer.snUser))
            {
               gender = friendPlayer.snUser.gender;
            }
            else if(Global.worldManager.isVisiting())
            {
               gender = Global.worldManager.getVisitGender();
            }
         }
         return gender;
      }
      
      public function loadObject(data:Object) : void
      {
         var msgIdx:int = 0;
         var messageData:Object = null;
         var messageText:String = null;
         var messageType:String = null;
         var iconUrl:String = null;
         var canAdd:Boolean = false;
         var timestamp:Number = NaN;
         var deltaSeconds:Number = NaN;
         var gameMessageData:Object = null;
         this.m_messages = [];
         if(data.messages)
         {
            for(msgIdx = 0; msgIdx < data.messages.length; msgIdx++)
            {
               messageData = data.messages[msgIdx];
               messageText = messageData.message;
               messageType = "";
               iconUrl = "";
               canAdd = true;
               if(Message.GAME_AUTHOR_ID == messageData.authorId)
               {
                  gameMessageData = Global.farmGameSettingsManager.getGameMessage(Number(messageText));
                  if(gameMessageData)
                  {
                     messageText = ZLocUtils.t("Notifications",gameMessageData["localeKey"]);
                     messageType = gameMessageData["type"];
                     iconUrl = gameMessageData["icon"];
                  }
                  else
                  {
                     canAdd = false;
                  }
               }
               timestamp = Number(messageData.timestamp);
               deltaSeconds = GlobalEngine.getTimer() / 1000 - timestamp;
               if(deltaSeconds < 0)
               {
                  timestamp /= 1000;
               }
               if(canAdd)
               {
                  this.addMessage(new Message(messageText,messageData.authorId,messageData.objectId,messageData.isNew,messageData.id,timestamp,messageType,iconUrl));
               }
            }
         }
         var messageCenterButton:MessageCenterButton = Global.hud.messageCenterButton;
         if(messageCenterButton)
         {
            messageCenterButton.setUpNotificationBubble();
         }
         this.addMessageAvatarsToWorld();
         if(!Global.worldManager.isVisiting())
         {
            this.m_allowSendEmails = data.allowSendEmails;
            if(this.m_allowSendEmails && !GlobalEngine.socialNetwork.userHasEmailPermission())
            {
               this.m_allowSendEmails = false;
            }
         }
      }
      
      public function getMessages() : Array
      {
         var message:Message = null;
         var messages:Array = [];
         for each(message in this.m_messages)
         {
            if(message.getId() > 0)
            {
               messages.push(message);
            }
         }
         messages.sort(this.sortById);
         return messages;
      }
      
      public function getMessage(messageId:int) : Message
      {
         var curMessage:Message = null;
         var message:Message = null;
         for each(curMessage in this.m_messages)
         {
            if(curMessage.getId() == messageId)
            {
               message = curMessage;
               break;
            }
         }
         return message;
      }
      
      public function addMessage(message:Message, sendTransaction:Boolean = false, postMessageFinishCallback:Function = null) : void
      {
         var recipientId:String = null;
         if(sendTransaction)
         {
            recipientId = this.getCurrentRecipientId();
            TransactionManager.addTransaction(new TPostMessage(message,recipientId,0,postMessageFinishCallback),true);
         }
         else
         {
            this.m_messages.push(message);
         }
      }
      
      public function sendReplyMessage(message:Message, replyMessageId:Number) : Boolean
      {
         var originalAuthorId:String = null;
         var success:Boolean = false;
         var originalMessage:Message = this.getMessage(replyMessageId);
         if(originalMessage != null)
         {
            originalAuthorId = originalMessage.getAuthorId();
            if(Global.friendManager.getFriendData(originalAuthorId) != null)
            {
               TransactionManager.addTransaction(new TPostMessage(message,originalAuthorId,replyMessageId));
            }
         }
         return success;
      }
      
      public function addMessageWithSign(message:Message) : void
      {
         Global.world.addGameMode(new GMMessageSignPlace("messageSign",message));
      }
      
      public function removeMessage(messageId:Number, sendTransaction:Boolean = false) : void
      {
         var message:Message = null;
         var messageSignId:Number = NaN;
         var recipientId:String = null;
         var messageSign:WorldObject = null;
         for(var msgIdx:int = 0; msgIdx < this.m_messages.length; msgIdx++)
         {
            message = this.m_messages[msgIdx];
            if(message.getId() == messageId)
            {
               this.m_messages.splice(msgIdx,1);
               if(sendTransaction)
               {
                  recipientId = this.getCurrentRecipientId();
                  TransactionManager.addTransaction(new TRemoveMessage(messageId,recipientId));
               }
               messageSignId = message.getObjectId();
               if(messageSignId > 0)
               {
                  messageSign = Global.world.getObjectById(messageSignId);
                  if(messageSign)
                  {
                     messageSign.detach();
                  }
               }
               break;
            }
         }
      }
      
      public function getNumNewMessages() : int
      {
         var message:Message = null;
         var count:int = 0;
         for each(message in this.m_messages)
         {
            if(message.isNew())
            {
               count++;
            }
         }
         return count;
      }
      
      public function markNewMessagesAsSeen() : void
      {
         var message:Message = null;
         var messageIds:Array = new Array();
         for each(message in this.m_messages)
         {
            if(message.isNew())
            {
               messageIds.push(message.getId());
               message.setSeen();
            }
         }
         if(!Global.worldManager.isVisiting() && messageIds.length > 0)
         {
            TransactionManager.addTransaction(new TMarkSeenMessages(messageIds));
         }
      }
      
      public function getMessageByMessageSignId(messageSignId:int) : Message
      {
         var curMessage:Message = null;
         var message:Message = null;
         for each(curMessage in this.m_messages)
         {
            if(curMessage.getObjectId() == messageSignId)
            {
               message = curMessage;
               break;
            }
         }
         return message;
      }
      
      public function updateMessageFromServer(authorId:String, timestamp:Number, newMessageId:Number) : void
      {
         var message:Message = null;
         for(var msgIdx:int = 0; msgIdx < this.m_messages.length; msgIdx++)
         {
            message = this.m_messages[msgIdx];
            if(message.getAuthorId() == authorId && message.getTimestamp() == timestamp)
            {
               message.setId(newMessageId);
               break;
            }
         }
      }
      
      public function onPlaceMessageSignDone() : void
      {
         var tempFert:int = 0;
         var tempFood:int = 0;
         if(Global.worldManager.isVisiting())
         {
            tempFert = Global.player.fertilizer;
            Global.player.fertilizer = tempFert;
            Global.player.queuedFertilizer = Global.player.fertilizer;
            tempFood = Global.player.animalFood;
            Global.player.animalFood = tempFood;
            Global.player.queuedAnimalFood = Global.player.animalFood;
         }
      }
      
      public function canShowMessageCenter() : Boolean
      {
         return true;
      }
      
      public function setAllowSendEmails(isAllow:Boolean) : void
      {
         this.m_allowSendEmails = isAllow;
         TransactionManager.addTransaction(new TAllowMessageEmails(isAllow),true);
      }
      
      public function isAllowSendEmails() : Boolean
      {
         return this.m_allowSendEmails;
      }
      
      public function showCommentBoxEmailPrompt(onFinishPermissionsCallback:Function = null) : void
      {
         var showPrompt:Boolean = false;
         var lastTimestamp:Number = NaN;
         var currentTime:Number = NaN;
         var timeBetweenPrompts:int = 0;
         if(Global.farmSocialNetwork.emailSupported())
         {
            this.m_emailPermissionsCallback = onFinishPermissionsCallback;
            if(!GlobalEngine.socialNetwork.userHasEmailPermission())
            {
               showPrompt = false;
               if(!Global.player.getSeenFlag("lastCommentBoxEmailPrompt"))
               {
                  lastTimestamp = Global.player.getFeatureLastShown("commentBoxEmail");
                  currentTime = GlobalEngine.getTimer() / 1000;
                  timeBetweenPrompts = Global.farmGameSettingsManager.getInt("commentBoxTimeBetweenEmailPrompts",345600);
                  if(currentTime - lastTimestamp > timeBetweenPrompts)
                  {
                     Global.player.setFeatureLastShown("commentBoxEmail",currentTime,true);
                     showPrompt = true;
                     if(lastTimestamp > 0)
                     {
                        Global.player.setSeenFlag("lastCommentBoxEmailPrompt");
                     }
                  }
               }
            }
            if(showPrompt)
            {
               EmailManager.displayEmailPermissionPrompt(EmailPopup.EMAIL_COMMENT_BOX_VARIANT_SOFTGATE,this.onFinishEmailPermissions);
            }
         }
      }
      
      private function onFinishEmailPermissions() : void
      {
         if(GlobalEngine.socialNetwork.userHasEmailPermission())
         {
            this.setAllowSendEmails(true);
         }
         if(this.m_emailPermissionsCallback != null)
         {
            this.m_emailPermissionsCallback();
         }
      }
      
      public function addMessageAvatarsToWorld() : void
      {
         var message:Message = null;
         var randIndex:int = 0;
         var splicedItems:Array = null;
         var authorId:String = null;
         var friend:Friend = null;
         var position:Vector3 = null;
         var positionData:Array = null;
         var objectId:Number = NaN;
         var friendAvatar:MessageAvatar = null;
         var messageSign:WorldObject = null;
         var positionOffset:Vector3 = null;
         var basePosition:Vector3 = null;
         var positions:Array = AVATAR_POSITIONS.concat();
         var shuffledPositions:Array = [];
         while(positions.length > 0)
         {
            randIndex = Math.round(Math.random() * (positions.length - 1));
            splicedItems = positions.splice(randIndex,1);
            shuffledPositions.push(splicedItems[0]);
         }
         for each(message in this.m_messages)
         {
            if(shuffledPositions.length == 0)
            {
               break;
            }
            if(message.isNew() && !message.isGameAuthor())
            {
               authorId = message.getAuthorId();
               friend = Global.friendManager.getFriendData(authorId);
               if(friend != null && friend.avatarData != null)
               {
                  position = null;
                  positionData = shuffledPositions.shift();
                  objectId = message.getObjectId();
                  if(objectId > 0)
                  {
                     messageSign = Global.world.getObjectById(objectId);
                     if(messageSign)
                     {
                        position = messageSign.getPosition().add(new Vector3(-1.5));
                     }
                  }
                  if(null == position)
                  {
                     positionOffset = new Vector3(positionData[0],positionData[1]);
                     basePosition = this.m_defaultAvatarBasePosition;
                     if(Global.player.avatar)
                     {
                        basePosition = Global.player.avatar.getPosition();
                     }
                     position = basePosition.add(positionOffset);
                  }
                  friendAvatar = new MessageAvatar(message.getId(),friend.avatarData);
                  Global.world.addAvatar(friendAvatar,position);
                  this.m_messageAvatars.push(friendAvatar);
               }
            }
         }
      }
      
      public function removeMessageAvatars() : void
      {
         var avatar:MessageAvatar = null;
         for each(avatar in this.m_messageAvatars)
         {
            avatar.detach();
         }
         this.m_messageAvatars = [];
      }
      
      public function getCurrentRecipientId() : String
      {
         var uid:String = null;
         if(Global.worldManager.isVisiting())
         {
            uid = Global.worldManager.getVisiting();
         }
         else
         {
            uid = Global.player.uid;
         }
         return uid;
      }
      
      private function sortById(message1:Message, message2:Message) : int
      {
         var result:int = 0;
         var message1Id:Number = message1.getId();
         var message2Id:Number = message2.getId();
         if(message1Id > message2Id)
         {
            result = -1;
         }
         else if(message2Id > message1Id)
         {
            result = 1;
         }
         else
         {
            result = 0;
         }
         return result;
      }
      
      private function calcDefaultAvatarBasePosition() : Vector3
      {
         return Global.world.getDefaultAvatarPosition();
      }
   }
}

