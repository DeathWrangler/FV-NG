package Classes.storage
{
   public class BushelBabiesCraftItem extends StorageItem
   {
      
      public function BushelBabiesCraftItem(key:String, metaData:Array = null)
      {
         super(key,metaData);
      }
      
      public static function createBushelBabiesCraftedItem(itemKey:String, quantity:int) : BushelBabiesCraftItem
      {
         var newMetaData:Array = [quantity];
         return new BushelBabiesCraftItem(itemKey,newMetaData);
      }
      
      override protected function parseKey(itemKey:String) : void
      {
         m_itemCode = itemKey;
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

