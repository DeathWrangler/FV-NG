package DataObjects.Items.ItemFeatures
{
   import DataObjects.Items.ItemUpgradeDO;
   
   public class FeatureInfiniteUpgradeDataDO extends ItemUpgradeDO
   {
      
      [XmlAttribute]
      public var experiment:String;
      
      [XmlAttribute]
      public var runtimeString:String;
      
      [XmlAttribute(§default§="-2147483648")]
      public var additionalCapacity:int;
      
      public function FeatureInfiniteUpgradeDataDO()
      {
         super();
      }
   }
}

