package DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building
{
   import DataObjects.BaseDataObject;
   
   public class ItemExpansionDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var incompleteFeed:String;
      
      public var expansion:String;
      
      public function ItemExpansionDO()
      {
         super();
      }
      
      override public function toString() : String
      {
         return _toString(this.expansion);
      }
   }
}

