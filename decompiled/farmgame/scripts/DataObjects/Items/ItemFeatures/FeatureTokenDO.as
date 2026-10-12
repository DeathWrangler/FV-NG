package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class FeatureTokenDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var itemName:String;
      
      [XmlAttribute]
      public var toBuy:String;
      
      public function FeatureTokenDO()
      {
         super();
      }
   }
}

