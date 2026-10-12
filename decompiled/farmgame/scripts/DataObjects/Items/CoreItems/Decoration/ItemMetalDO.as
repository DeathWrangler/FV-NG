package DataObjects.Items.CoreItems.Decoration
{
   import DataObjects.BaseDataObject;
   
   public class ItemMetalDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      [XmlAttribute]
      public var url:String;
      
      public function ItemMetalDO()
      {
         super();
      }
   }
}

