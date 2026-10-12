package Widgets.Windows.Market
{
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.GreenhouseSeedItem;
   import Classes.ZItem.SeedItem;
   import Managers.FarmGameSettingsManager;
   
   public class MarketMiniGreenhouseWindow extends MarketMiniWindow
   {
      
      public function MarketMiniGreenhouseWindow(itemNames:Array)
      {
         var tmpArray:Array = null;
         var item:FarmItem = null;
         var seed:SeedItem = null;
         super(itemNames);
         tmpArray = m_displayItems;
         m_displayItems = new Array();
         for each(item in tmpArray)
         {
            seed = item as SeedItem;
            if(seed)
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  m_displayItems.push(new GreenhouseSeedItem(null,seed));
               }
               else
               {
                  m_displayItems.push(new GreenhouseSeedItem(seed.xml));
               }
            }
         }
         tmpArray = null;
      }
   }
}

