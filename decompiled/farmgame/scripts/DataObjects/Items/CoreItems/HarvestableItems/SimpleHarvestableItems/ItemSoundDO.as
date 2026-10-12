package DataObjects.Items.CoreItems.HarvestableItems.SimpleHarvestableItems
{
   import DataObjects.BaseDataObject;
   
   public class ItemSoundDO extends BaseDataObject
   {
      
      [XmlAttribute]
      public var url:String;
      
      public function ItemSoundDO()
      {
         super();
      }
   }
}

