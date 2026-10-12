package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class FeatureImageProgressionObjectDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var className:String;
      
      [XmlAttribute(§default§="-2147483648")]
      public var maxLevel:int;
      
      public function FeatureImageProgressionObjectDO()
      {
         super();
      }
   }
}

