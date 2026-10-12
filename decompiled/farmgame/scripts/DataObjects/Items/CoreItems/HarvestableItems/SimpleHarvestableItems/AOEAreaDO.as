package DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems
{
   import DataObjects.BaseDataObject;
   
   public class AOEAreaDO extends BaseDataObject
   {
      
      [XmlAttribute(§default§="-2147483648")]
      public var x:int;
      
      [XmlAttribute(§default§="-2147483648")]
      public var y:int;
      
      [XmlAttribute(§default§="-2147483648")]
      public var width:int;
      
      [XmlAttribute(§default§="-2147483648")]
      public var height:int;
      
      public function AOEAreaDO()
      {
         super();
      }
   }
}

