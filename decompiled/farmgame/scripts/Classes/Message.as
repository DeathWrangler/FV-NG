package Classes
{
   public class Message
   {
      
      public static const GAME_MESSAGE_TYPE_FARMVILLE:String = "farmville";
      
      public static const GAME_AUTHOR_ID:String = "-1";
      
      public static const MESSAGE_TEMP_START_ID:Number = -1;
      
      private static var m_nextTempMessageId:Number = Message.MESSAGE_TEMP_START_ID;
      
      private var m_messageId:Number;
      
      private var m_timestamp:Number;
      
      private var m_message:String;
      
      private var m_authorId:String;
      
      private var m_objectId:Number;
      
      private var m_isNew:Boolean;
      
      private var m_gameMessageType:String;
      
      private var m_iconUrl:String;
      
      private var m_highlighted:Boolean;
      
      public function Message(message:String, authorId:String, objectId:Number, isNew:Boolean, id:Number = 0, timestamp:Number = 0, gameMessageType:String = "", iconUrl:String = "")
      {
         super();
         this.m_timestamp = timestamp;
         this.m_message = message;
         this.m_authorId = authorId;
         this.m_objectId = objectId;
         this.m_isNew = isNew;
         this.m_gameMessageType = gameMessageType;
         this.m_iconUrl = iconUrl;
         if(0 == id)
         {
            this.m_messageId = m_nextTempMessageId--;
         }
         else
         {
            this.m_messageId = id;
         }
         if(0 == this.m_timestamp)
         {
            this.m_timestamp = GlobalEngine.serverTime / 1000;
         }
      }
      
      public function setId(id:Number) : void
      {
         this.m_messageId = id;
      }
      
      public function getId() : Number
      {
         return this.m_messageId;
      }
      
      public function getTimestamp() : Number
      {
         return this.m_timestamp;
      }
      
      public function getMessage() : String
      {
         return this.m_message;
      }
      
      public function getAuthorId() : String
      {
         return this.m_authorId;
      }
      
      public function isSelfAuthor() : Boolean
      {
         return Global.player.uid == this.m_authorId;
      }
      
      public function isFriendAuthor() : Boolean
      {
         var friend:Friend = Global.friendManager.getFriendData(this.m_authorId);
         return !this.isGameAuthor() && null != friend;
      }
      
      public function isGameAuthor() : Boolean
      {
         return GAME_AUTHOR_ID == this.m_authorId;
      }
      
      public function getGameMessageType() : String
      {
         return this.m_gameMessageType;
      }
      
      public function getObjectId() : Number
      {
         return this.m_objectId;
      }
      
      public function getHighlighted() : Boolean
      {
         return this.m_highlighted;
      }
      
      public function setHighlighted(highlight:Boolean) : void
      {
         this.m_highlighted = highlight;
      }
      
      public function setObjectId(objectId:int) : void
      {
         this.m_objectId = objectId;
      }
      
      public function isNew() : Boolean
      {
         return this.m_isNew;
      }
      
      public function setSeen() : void
      {
         this.m_isNew = false;
      }
      
      public function getIconUrl() : String
      {
         var iconUrl:String = null;
         if(this.m_iconUrl.length > 0)
         {
            iconUrl = Global.getAssetURL(this.m_iconUrl);
         }
         return iconUrl;
      }
   }
}

