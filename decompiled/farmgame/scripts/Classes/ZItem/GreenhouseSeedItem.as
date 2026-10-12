package Classes.ZItem
{
   import Classes.util.ZLocUtils;
   import Managers.FarmGameSettingsManager;
   
   public class GreenhouseSeedItem extends SeedItem
   {
      
      public static const NUM_SEEDS_IN_PACK:Number = 50;
      
      public function GreenhouseSeedItem(itemXML:XML, seedItem:SeedItem = null)
      {
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            copyDataSource(seedItem);
         }
         super(itemXML,m_dataSource);
      }
      
      public function getBuyingMultipleText() : String
      {
         return ZLocUtils.t("Dialogs","BuyingMultiple",{"quantity":String(NUM_SEEDS_IN_PACK)});
      }
   }
}

