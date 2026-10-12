package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class ItemMarketEntryDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var type:String;
      
      [XmlAttribute]
      public var subtype:String;
      
      [XmlAttribute]
      public var subsubtype:String;
      
      public function ItemMarketEntryDO()
      {
         super();
      }
   }
}

