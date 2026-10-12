package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class FeatureLevelDO extends BaseDataObject
   {
      
      [XmlAttribute(§default§="-2147483648")]
      public var index:int;
      
      [XmlAttribute]
      public var collection:String;
      
      [XmlAttribute(§default§="-2147483648")]
      public var duplicateXP:int;
      
      [XmlAttribute]
      public var extraLootTable:String;
      
      public function FeatureLevelDO()
      {
         super();
      }
   }
}

