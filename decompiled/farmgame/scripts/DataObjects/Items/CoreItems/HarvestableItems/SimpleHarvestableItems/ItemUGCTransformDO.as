package DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems
{
   import DataObjects.BaseDataObject;
   
   public class ItemUGCTransformDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      [XmlAttribute(§default§="-2147483648")]
      public var translateX:int;
      
      [XmlAttribute(§default§="-2147483648")]
      public var translateY:int;
      
      [XmlAttribute(§default§="-2147483648")]
      public var scaleX:Number;
      
      [XmlAttribute(§default§="-2147483648")]
      public var scaleY:Number;
      
      public function ItemUGCTransformDO()
      {
         super();
      }
   }
}

