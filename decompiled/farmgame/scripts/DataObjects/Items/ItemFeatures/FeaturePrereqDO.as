package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class FeaturePrereqDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var type:String;
      
      [XmlAttribute]
      public var value:String;
      
      [XmlAttribute(§default§="-2147483648")]
      public var variant:int;
      
      [XmlAttribute]
      public var context:String;
      
      [XmlAttribute]
      public var contextBackend:String;
      
      [XmlAttribute]
      public var op:String;
      
      public function FeaturePrereqDO()
      {
         super();
      }
   }
}

