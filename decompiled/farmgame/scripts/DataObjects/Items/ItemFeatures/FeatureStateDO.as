package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class FeatureStateDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      public var title:String;
      
      public var desc:String;
      
      public var icon:String;
      
      public var buttonText:String;
      
      public var prereq:FeaturePrereqDO;
      
      public var verticalIndicatorOffset:int;
      
      public var horizontalIndicatorOffset:int;
      
      public function FeatureStateDO()
      {
         super();
      }
   }
}

