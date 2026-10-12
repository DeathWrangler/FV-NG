package Classes.ZItem
{
   import DataSources.BaseDataSource;
   
   public class BushelItem extends FarmItem
   {
      
      public function BushelItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      public function get seedItem() : SeedItem
      {
         return Global.farmGameSettingsManager.getFarmItemByCode(crop) as SeedItem;
      }
   }
}

