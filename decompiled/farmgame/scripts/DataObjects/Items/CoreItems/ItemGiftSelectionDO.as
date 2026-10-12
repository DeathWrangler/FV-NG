package DataObjects.Items.CoreItems
{
   import DataObjects.BaseDataObject;
   
   public class ItemGiftSelectionDO extends BaseDataObject
   {
      
      [XmlAttribute(§default§="-2147483648")]
      public var from:int;
      
      [XmlAttribute]
      public var change:String;
      
      public var selectNo:Array;
      
      public function ItemGiftSelectionDO()
      {
         super();
      }
   }
}

