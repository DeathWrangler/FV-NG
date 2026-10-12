package DataObjects.Items.ItemFeatures
{
   import DataObjects.BaseDataObject;
   
   public class ItemFeatureDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      [XmlAttribute]
      public var className:String;
      
      [XmlAttribute]
      public var experiment:String;
      
      public var prereq:Array;
      
      public function ItemFeatureDO()
      {
         super();
      }
   }
}

