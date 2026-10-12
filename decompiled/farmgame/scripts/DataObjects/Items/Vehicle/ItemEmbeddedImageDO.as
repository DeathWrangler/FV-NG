package DataObjects.Items.Vehicle
{
   import DataObjects.BaseDataObject;
   
   public class ItemEmbeddedImageDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      [XmlAttribute]
      public var symbol:String;
      
      public function ItemEmbeddedImageDO()
      {
         super();
      }
   }
}

