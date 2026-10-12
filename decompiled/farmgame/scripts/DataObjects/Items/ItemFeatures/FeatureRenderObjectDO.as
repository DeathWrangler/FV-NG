package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class FeatureRenderObjectDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var className:String;
      
      public function FeatureRenderObjectDO()
      {
         super();
      }
   }
}

