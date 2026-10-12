package DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems.Building
{
   import DataObjects.BaseDataObject;
   
   public class ItemHoverContextMenuDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var experiment:String;
      
      [XmlAttribute(§default§="-2147483648")]
      public var activevar:int;
      
      [XmlAttribute]
      public var action:String;
      
      [XmlAttribute]
      public var value:String;
      
      [XmlAttribute]
      public var prereqName:String;
      
      public function ItemHoverContextMenuDO()
      {
         super();
      }
   }
}

