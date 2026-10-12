package DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building
{
   import DataObjects.BaseDataObject;
   
   public class ItemFreeGiftDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var border:String;
      
      [XmlAttribute]
      public var title:String;
      
      public function ItemFreeGiftDO()
      {
         super();
      }
   }
}

