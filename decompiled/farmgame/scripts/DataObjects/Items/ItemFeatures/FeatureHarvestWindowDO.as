package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class FeatureHarvestWindowDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var className:String;
      
      [XmlAttribute]
      public var dialogUrl:String;
      
      [XmlAttribute]
      public var dialogBgUrl:String;
      
      [XmlAttribute]
      public var npcUrl:String;
      
      [XmlAttribute]
      public var locPrefix:String;
      
      public function FeatureHarvestWindowDO()
      {
         super();
      }
   }
}

