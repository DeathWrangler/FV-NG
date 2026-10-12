package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class ItemExtraMenuItemDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var label:String;
      
      public var item:String;
      
      public function ItemExtraMenuItemDO()
      {
         super();
      }
      
      override public function toString() : String
      {
         return _toString(this.item);
      }
   }
}

