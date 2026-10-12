package DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building
{
   import DataObjects.BaseDataObject;
   
   public class ItemPartRequestTypeDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var item:String;
      
      public var request:Array;
      
      public function ItemPartRequestTypeDO()
      {
         super();
      }
   }
}

