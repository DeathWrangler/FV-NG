package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class FeatureHarvestRewardDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      [XmlAttribute]
      public var seedPackageSizeKey:String;
      
      [XmlAttribute]
      public var lootTable:String;
      
      public function FeatureHarvestRewardDO()
      {
         super();
      }
   }
}

