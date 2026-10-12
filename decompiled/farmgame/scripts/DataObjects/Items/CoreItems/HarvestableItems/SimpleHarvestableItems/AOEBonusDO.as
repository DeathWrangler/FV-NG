package DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems
{
   import DataObjects.BaseDataObject;
   
   public class AOEBonusDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var type:String;
      
      [XmlAttribute]
      public var value:String;
      
      [XmlAttribute]
      public var op:String;
      
      [XmlAttribute]
      public var highlightColor:String;
      
      public function AOEBonusDO()
      {
         super();
      }
   }
}

