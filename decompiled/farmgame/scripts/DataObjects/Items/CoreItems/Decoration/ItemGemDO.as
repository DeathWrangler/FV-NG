package DataObjects.Items.CoreItems.Decoration
{
   import DataObjects.BaseDataObject;
   
   public class ItemGemDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      [XmlAttribute]
      public var url:String;
      
      public function ItemGemDO()
      {
         super();
      }
   }
}

