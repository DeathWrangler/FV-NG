package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class FeatureFrequencyDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      public var interval:int;
      
      public var limit:int;
      
      public function FeatureFrequencyDO()
      {
         super();
      }
   }
}

