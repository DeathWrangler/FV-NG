package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class ItemStorageTypeDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var itemClass:String;
      
      [XmlAttribute]
      public var additionalItemClass:String;
      
      [XmlAttribute]
      public var nonSellableInventory:Boolean;
      
      public function ItemStorageTypeDO()
      {
         super();
      }
   }
}

