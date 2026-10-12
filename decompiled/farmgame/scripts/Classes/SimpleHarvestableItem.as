package Classes
{
   import Classes.ZItem.HarvestableItem;
   import DataSources.BaseDataSource;
   
   public class SimpleHarvestableItem extends HarvestableItem
   {
      
      public function SimpleHarvestableItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
   }
}

