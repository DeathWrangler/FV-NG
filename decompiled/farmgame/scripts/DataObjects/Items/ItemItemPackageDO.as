package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class ItemItemPackageDO extends BaseDataObject
   {
      
      [XmlAttribute(§default§="-2147483648")]
      public var amount:int;
      
      public var itemPackage:String;
      
      public function ItemItemPackageDO()
      {
         super();
      }
      
      override public function toString() : String
      {
         return _toString(this.itemPackage);
      }
   }
}

