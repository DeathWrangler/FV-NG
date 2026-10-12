package Classes.storage
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   
   public class StorageItem
   {
      
      protected static const ITEM_KEY_DELIMITER:String = ":";
      
      protected const METADATA_INDEX_QUANTITY:int = 0;
      
      protected const METADATA_INDEX_SENDER_IDS:int = 1;
      
      protected const METADATA_INDEX_EXTRADATA:int = 2;
      
      protected var m_itemKey:String = "";
      
      protected var m_itemCode:String = "";
      
      protected var m_quantity:int = 0;
      
      protected var m_senderIds:Array = new Array();
      
      protected var m_extraData:Array = [];
      
      public function StorageItem(key:String, metaData:Array = null)
      {
         super();
         this.m_itemKey = key;
         this.parseKey(key);
         this.parseMetaData(metaData);
      }
      
      protected static function extractItemCode(key:String) : String
      {
         var code:String = "";
         var keyParts:Array = key.split(StorageItem.ITEM_KEY_DELIMITER);
         if(keyParts.length)
         {
            code = keyParts[0];
         }
         return code;
      }
      
      public static function getStorageItem(key:String, metaData:Array) : StorageItem
      {
         var item:FarmItem = null;
         var storageItem:StorageItem = null;
         var itemCode:String = extractItemCode(key);
         if(itemCode != null)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            if(item != null)
            {
               switch(item.className)
               {
                  case "CCrafted":
                     storageItem = new CraftedItem(key,metaData);
                     break;
                  case "BushelBabiesCraftItem":
                     storageItem = new BushelBabiesCraftItem(key,metaData);
                     break;
                  default:
                     storageItem = new StorageItem(key,metaData);
               }
            }
         }
         return storageItem;
      }
      
      protected function parseKey(itemKey:String) : void
      {
         this.m_itemCode = extractItemCode(itemKey);
      }
      
      protected function parseMetaData(metaData:Array) : void
      {
         if(metaData)
         {
            if(metaData[this.METADATA_INDEX_QUANTITY])
            {
               this.m_quantity = parseInt(metaData[this.METADATA_INDEX_QUANTITY]);
            }
            if(metaData[this.METADATA_INDEX_SENDER_IDS])
            {
               this.m_senderIds = metaData[this.METADATA_INDEX_SENDER_IDS];
            }
            if(metaData[this.METADATA_INDEX_EXTRADATA])
            {
               this.m_extraData = metaData[this.METADATA_INDEX_EXTRADATA];
            }
         }
      }
      
      public function get itemKey() : String
      {
         return this.m_itemKey;
      }
      
      public function get itemCode() : String
      {
         return this.m_itemCode;
      }
      
      public function get quantity() : int
      {
         return this.m_quantity;
      }
      
      public function add(senderIds:Array, extraData:Array) : void
      {
         if(senderIds.length != extraData.length)
         {
            throw new Error("Cannout use StorageItem#add without equivalent length arguments");
         }
         for(var i:int = 0; i < senderIds.length; i++)
         {
            this.addExtraData(extraData[i]);
            this.addSenderId(senderIds[i]);
         }
         this.adjustQuantity(senderIds.length);
      }
      
      public function getExtraData(index:Number = 0) : Object
      {
         var result:Object = null;
         if(this.m_extraData.length > index)
         {
            result = this.m_extraData[index];
         }
         return result;
      }
      
      public function getAllExtraData() : Array
      {
         return this.m_extraData;
      }
      
      public function addExtraData(data:Object) : void
      {
         this.m_extraData.push(data);
      }
      
      public function removeExtraData(index:Number) : void
      {
         this.m_extraData.splice(index,1);
      }
      
      public function set quantity(value:int) : void
      {
         this.adjustQuantity(value,true);
      }
      
      public function adjustQuantity(amount:int, trimMetdata:Boolean = true) : void
      {
         this.m_quantity += amount;
         if(trimMetdata)
         {
            while(this.m_extraData.length > this.m_quantity)
            {
               this.m_extraData.shift();
            }
         }
      }
      
      public function get senderIds() : Array
      {
         return this.m_senderIds;
      }
      
      public function addSenderId(uid:String) : void
      {
         this.m_senderIds.push(uid);
      }
      
      public function shiftSenderId() : void
      {
         if(this.m_senderIds.length)
         {
            this.m_senderIds.shift();
         }
      }
      
      public function get item() : FarmItem
      {
         return Global.farmGameSettingsManager.getFarmItemByCode(this.m_itemCode);
      }
      
      public function isEmpty() : Boolean
      {
         return this.quantity <= 0;
      }
      
      public function get level() : int
      {
         return 0;
      }
      
      public function getDisplaySubtext1() : String
      {
         var tempName:String = null;
         var tempGender:String = null;
         var senderName:Array = null;
         var text:String = "";
         var giftSenderId:String = "0";
         var multipleSenders:Boolean = false;
         if(Boolean(this.senderIds) && Boolean(this.senderIds[0]))
         {
            giftSenderId = this.senderIds[0];
            if(this.senderIds.length > 1)
            {
               multipleSenders = true;
            }
         }
         if(giftSenderId.length > 1)
         {
            tempName = Global.friendManager.getFriendName(giftSenderId);
            tempGender = Global.friendManager.getFriendGender(giftSenderId);
            if(tempName)
            {
               senderName = tempName.split(" ");
               if(senderName[0])
               {
                  text = senderName[0];
               }
               else
               {
                  text = tempName;
               }
               if(multipleSenders)
               {
                  text = ZLocUtils.t("Dialogs","SellAnd",{"user":ZLocUtils.tn(text,ZLocUtils.tg(tempGender))});
               }
            }
            else
            {
               text = ZLocUtils.t("Dialogs","SellFV");
            }
         }
         else
         {
            text = ZLocUtils.t("Dialogs","SellFV");
         }
         return text;
      }
      
      public function getDisplaySubtext2() : String
      {
         return this.item.getLimitedTimeLeft();
      }
   }
}

