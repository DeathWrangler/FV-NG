package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class FeatureTutorialDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      [XmlAttribute]
      public var seenFlag:String;
      
      [XmlAttribute(alias="function")]
      public var functionName:String;
      
      [XmlAttribute]
      public var windowSrc:String;
      
      [XmlAttribute]
      public var itemPlaceOnAccept:String;
      
      [XmlAttribute]
      public var openDialog:Boolean;
      
      [XmlAttribute]
      public var message:String;
      
      [XmlAttribute]
      public var button:String;
      
      [XmlAttribute]
      public var item:String;
      
      [XmlAttribute]
      public var surfacingKeyword:String;
      
      public var param:Array;
      
      public function FeatureTutorialDO()
      {
         super();
      }
   }
}

