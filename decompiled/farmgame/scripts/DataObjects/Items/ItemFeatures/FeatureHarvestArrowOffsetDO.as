package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class FeatureHarvestArrowOffsetDO extends BaseDataObject
   {
      
      [XmlAttribute(§default§="-2147483648")]
      public var x:int;
      
      [XmlAttribute(§default§="-2147483648")]
      public var y:int;
      
      public function FeatureHarvestArrowOffsetDO()
      {
         super();
      }
   }
}

