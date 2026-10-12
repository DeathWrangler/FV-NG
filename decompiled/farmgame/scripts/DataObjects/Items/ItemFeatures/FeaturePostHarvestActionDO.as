package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class FeaturePostHarvestActionDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var type:String;
      
      [XmlAttribute]
      public var surfacingKeyword:String;
      
      [XmlAttribute]
      public var toasterAsset:String;
      
      public function FeaturePostHarvestActionDO()
      {
         super();
      }
   }
}

