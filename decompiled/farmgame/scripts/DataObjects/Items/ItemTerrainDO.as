package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class ItemTerrainDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var name:String;
      
      [XmlAttribute]
      public var prefix:String;
      
      public function ItemTerrainDO()
      {
         super();
      }
   }
}

