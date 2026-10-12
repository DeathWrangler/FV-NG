package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class FeatureTextRenderFieldDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var type:String;
      
      public function FeatureTextRenderFieldDO()
      {
         super();
      }
   }
}

