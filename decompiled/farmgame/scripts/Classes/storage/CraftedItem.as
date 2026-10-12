package Classes.storage
{
   public class CraftedItem extends StorageItem
   {
      
      private static const KEY_INDEX_LEVEL:int = 1;
      
      private var m_level:int = 0;
      
      public function CraftedItem(key:String, metaData:Array = null)
      {
         super(key,metaData);
      }
      
      public static function sortItems(item1:CraftedItem, item2:CraftedItem) : int
      {
         var result:int = 0;
         if(item1.level < item2.level)
         {
            result = -1;
         }
         else if(item2.level < item1.level)
         {
            result = 1;
         }
         else
         {
            result = 0;
         }
         return result;
      }
      
      public static function createCraftedItem(itemCode:String, level:int, quantity:int) : CraftedItem
      {
         var keyParts:Array = [itemCode,level.toString()];
         var keyString:String = keyParts.join(StorageItem.ITEM_KEY_DELIMITER);
         var newMetaData:Array = [quantity];
         return new CraftedItem(keyString,newMetaData);
      }
      
      public static function getKey(itemCode:String, level:int) : String
      {
         var keyParts:Array = [itemCode,level.toString()];
         return keyParts.join(StorageItem.ITEM_KEY_DELIMITER);
      }
      
      override protected function parseKey(itemKey:String) : void
      {
         super.parseKey(itemKey);
         var keyParts:Array = itemKey.split(StorageItem.ITEM_KEY_DELIMITER);
         if(keyParts[KEY_INDEX_LEVEL])
         {
            this.m_level = parseInt(keyParts[KEY_INDEX_LEVEL]);
         }
      }
      
      override public function get level() : int
      {
         return this.m_level;
      }
      
      override public function getDisplaySubtext1() : String
      {
         return "";
      }
      
      override public function getDisplaySubtext2() : String
      {
         return "";
      }
   }
}

