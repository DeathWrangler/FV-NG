package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class FeatureStageDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      [XmlAttribute]
      public var nextStage:String;
      
      [XmlAttribute(§default§="-2147483648")]
      public var consumables:int;
      
      [XmlAttribute]
      public var image:String;
      
      [XmlAttribute(§default§="-2147483648")]
      public var mastery:int;
      
      public function FeatureStageDO()
      {
         super();
      }
   }
}

