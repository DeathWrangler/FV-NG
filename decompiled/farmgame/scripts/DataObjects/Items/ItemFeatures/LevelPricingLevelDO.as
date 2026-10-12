package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class LevelPricingLevelDO extends BaseDataObject
   {
      
      [XmlAttribute(§default§="-2147483648")]
      public var num:int;
      
      [XmlAttribute(§default§="-2147483648")]
      public var cost:int;
      
      public function LevelPricingLevelDO()
      {
         super();
      }
   }
}

