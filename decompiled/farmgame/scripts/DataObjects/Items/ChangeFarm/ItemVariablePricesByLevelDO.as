package DataObjects.Items.ChangeFarm
{
   import DataObjects.BaseDataObject;
   
   public class ItemVariablePricesByLevelDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var type:String;
      
      [XmlAttribute]
      public var name:String;
      
      [XmlAttribute]
      public var statsPrefix:String;
      
      public var priceScheme:Array;
      
      public function ItemVariablePricesByLevelDO()
      {
         super();
      }
   }
}

