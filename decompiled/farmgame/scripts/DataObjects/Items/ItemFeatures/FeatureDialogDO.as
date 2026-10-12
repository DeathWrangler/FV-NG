package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class FeatureDialogDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var className:String;
      
      [XmlAttribute]
      public var path:String;
      
      public function FeatureDialogDO()
      {
         super();
      }
   }
}

