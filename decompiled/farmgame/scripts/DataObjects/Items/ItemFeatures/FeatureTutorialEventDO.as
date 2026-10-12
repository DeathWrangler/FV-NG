package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class FeatureTutorialEventDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      [XmlAttribute]
      public var tutorial:String;
      
      public function FeatureTutorialEventDO()
      {
         super();
      }
   }
}

