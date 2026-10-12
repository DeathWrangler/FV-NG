package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class ItemDefaultItemDO extends BaseDataObject
   {
      
      [XmlAttribute(§default§="-2147483648")]
      public var amount:int;
      
      [XmlAttribute]
      public var expansion:Boolean;
      
      [XmlAttribute]
      public var giftbox:Boolean;
      
      [XmlAttribute]
      public var name:String;
      
      [XmlAttribute]
      public var render:Boolean;
      
      public function ItemDefaultItemDO()
      {
         super();
      }
   }
}

