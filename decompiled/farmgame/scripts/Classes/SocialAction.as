package Classes
{
   import Classes.ZItem.FarmItem;
   
   public class SocialAction
   {
      
      public static const ACTION_SEND_GIFT:int = 0;
      
      public static const ACTION_VISIT_FARM:int = 1;
      
      public static const ACTION_FERTILIZE_FARM:int = 2;
      
      public static const ACTION_FEED_CHICKEN_COOP:int = 3;
      
      public static const ACTION_FERTILIZE_FIND_ITEM:int = 4;
      
      private var m_id:int;
      
      private var m_action:int;
      
      private var m_friendId:String;
      
      private var m_timestamp:Number;
      
      private var m_isNew:Boolean;
      
      private var m_itemCode:String;
      
      public function SocialAction(id:int, action:int, friendId:String, timestamp:int, isNew:Boolean, itemCode:String = null)
      {
         super();
         this.m_id = id;
         this.m_action = action;
         this.m_friendId = friendId;
         this.m_timestamp = timestamp;
         this.m_isNew = isNew;
         this.m_itemCode = itemCode;
      }
      
      public function getId() : int
      {
         return this.m_id;
      }
      
      public function getActionType() : int
      {
         return this.m_action;
      }
      
      public function getFriendId() : String
      {
         return this.m_friendId;
      }
      
      public function getTimestamp() : int
      {
         return this.m_timestamp;
      }
      
      public function isNew() : Boolean
      {
         return this.m_isNew;
      }
      
      public function getActionItem() : FarmItem
      {
         var item:FarmItem = null;
         if(this.m_itemCode != null)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_itemCode);
         }
         return item;
      }
      
      public function setSeen() : void
      {
         this.m_isNew = false;
      }
   }
}

