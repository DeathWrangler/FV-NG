package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class FeatureExpandPriceTestDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var experiment:String;
      
      public var variant:Array;
      
      public function FeatureExpandPriceTestDO()
      {
         super();
      }
   }
}

