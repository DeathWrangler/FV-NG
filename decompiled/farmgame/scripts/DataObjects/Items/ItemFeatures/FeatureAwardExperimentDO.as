package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class FeatureAwardExperimentDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      [XmlAttribute(§default§="-2147483648")]
      public var activeVar:int;
      
      public function FeatureAwardExperimentDO()
      {
         super();
      }
   }
}

