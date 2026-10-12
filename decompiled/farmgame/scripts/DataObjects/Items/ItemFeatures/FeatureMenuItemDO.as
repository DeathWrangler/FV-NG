package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class FeatureMenuItemDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      [XmlAttribute]
      public var action:String;
      
      [XmlAttribute]
      public var dataHelper:String;
      
      [XmlAttribute]
      public var gate:String;
      
      [XmlAttribute]
      public var gateHelper:String;
      
      [XmlAttribute]
      public var experiment:String;
      
      [XmlAttribute]
      public var experimentVariant:int;
      
      [XmlAttribute]
      public var showCash:Boolean;
      
      public var param:Array;
      
      public function FeatureMenuItemDO()
      {
         super();
      }
   }
}

