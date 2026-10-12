package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class FeatureContaineePartDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      public function FeatureContaineePartDO()
      {
         super();
      }
   }
}

