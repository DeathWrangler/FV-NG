package DataObjects.Items.CoreItems
{
   import DataObjects.BaseDataObject;
   
   public class ItemMasteryLevelDO extends BaseDataObject
   {
      
      [XmlAttribute(§default§="-2147483648")]
      public var count:int;
      
      [XmlAttribute(§default§="-2147483648")]
      public var xp:int;
      
      [XmlAttribute(§default§="-2147483648")]
      public var coins:int;
      
      [XmlAttribute]
      public var gift:String;
      
      public function ItemMasteryLevelDO()
      {
         super();
      }
   }
}

