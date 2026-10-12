package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class ItemPriceTestDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var experiment:String;
      
      public var variant:Array;
      
      public function ItemPriceTestDO()
      {
         super();
      }
   }
}

