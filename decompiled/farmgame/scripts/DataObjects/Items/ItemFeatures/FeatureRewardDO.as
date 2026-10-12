package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class FeatureRewardDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var type:String;
      
      [XmlAttribute]
      public var actionType:String;
      
      [XmlAttribute]
      public var value:String;
      
      [XmlAttribute]
      public var unit:String;
      
      [XmlAttribute(§default§="-2147483648")]
      public var quantity:int;
      
      [XmlAttribute]
      public var licenseType:String;
      
      public function FeatureRewardDO()
      {
         super();
      }
   }
}

