package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class FeatureCanHarvestDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var neighbor:Boolean;
      
      public function FeatureCanHarvestDO()
      {
         super();
      }
   }
}

