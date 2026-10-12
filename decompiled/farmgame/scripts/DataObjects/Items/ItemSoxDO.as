package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class ItemSoxDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var type:String;
      
      public function ItemSoxDO()
      {
         super();
      }
   }
}

