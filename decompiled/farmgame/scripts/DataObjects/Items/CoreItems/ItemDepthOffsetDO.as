package DataObjects.Items.CoreItems
{
   import DataObjects.BaseDataObject;
   
   public class ItemDepthOffsetDO extends BaseDataObject
   {
      
      [XmlAttribute(§default§="-2147483648")]
      public var x:int;
      
      [XmlAttribute(§default§="-2147483648")]
      public var y:int;
      
      public function ItemDepthOffsetDO()
      {
         super();
      }
   }
}

