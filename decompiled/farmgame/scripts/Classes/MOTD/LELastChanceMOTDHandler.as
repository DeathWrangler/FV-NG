package Classes.MOTD
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemType;
   import Display.UI;
   import Events.MarketEvent;
   import Managers.FarmStatsManager;
   import Managers.LESurfacingManager;
   import Widgets.Windows.Market.MarketWindow;
   
   public class LELastChanceMOTDHandler extends CustomWindowActionMOTDHandler
   {
      
      private static const LE_STATS_CATEGORY_EXPIRE:String = "MOTD_lelastchance_expiring";
      
      private static const LE_STATS_KINGDOM_EXPIRE:String = "MOTD_Expiring";
      
      private static const LE_STATS_CATEGORY_NEW:String = "MOTD_lelastchance_new";
      
      private static const LE_STATS_KINGDOM_NEW:String = "MOTD_New";
      
      private static const LE_STATS_KINGDOM_BUY:String = "Click_Buy";
      
      private static const LE_STATS_PHYLUM_IMPRESSION:String = "Impressions";
      
      private static const LE_STATS_PHYLUM_CLICK:String = "Click";
      
      private static const LE_STATS_KINGDOM_VIEW:String = "View";
      
      private var m_miniMarketWindow:MarketWindow = null;
      
      private var m_statsCategory:String = null;
      
      private var m_statsKingdom:String = null;
      
      private var m_daysOfDefinition:int;
      
      private var m_isNew:Boolean;
      
      public function LELastChanceMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      public function openLEMiniMarket(actionParams:Object) : void
      {
         var itemsToShow:Array = null;
         var itemsToShowNames:Array = null;
         var item:FarmItem = null;
         itemsToShow = Global.farmGameSettingsManager.getNewOrExpiringLEItems(this.m_daysOfDefinition,this.m_isNew);
         FarmStatsManager.count(this.m_statsCategory,this.m_statsKingdom,LE_STATS_PHYLUM_CLICK);
         if(itemsToShow.length != 0)
         {
            itemsToShowNames = [];
            for each(item in itemsToShow)
            {
               itemsToShowNames.push(item.name);
               FarmStatsManager.count(this.m_statsCategory,LE_STATS_KINGDOM_VIEW,item.name);
            }
            this.m_miniMarketWindow = UI.displayMiniMarketDialog(itemsToShowNames,UI.MARKET_CONTEXT_UNKNOWN,"",this.onMiniMarketClose) as MarketWindow;
            this.m_miniMarketWindow.addEventListener(MarketEvent.MARKET_BUY,this.leMiniMarketPurchased);
         }
         else
         {
            UI.displayMarketDialog(UI.MARKET_CONTEXT_UNKNOWN,FarmItemType.LIMITED) as MarketWindow;
         }
      }
      
      public function openLEMiniMarketWithItemList(actionParams:Object) : void
      {
         var itemsToShow:Array = null;
         var itemsToShowNames:Array = null;
         var item:FarmItem = null;
         itemsToShow = Global.farmGameSettingsManager.getNewOrExpiringLEItems(this.m_daysOfDefinition,this.m_isNew);
         FarmStatsManager.count(this.m_statsCategory,this.m_statsKingdom,LE_STATS_PHYLUM_CLICK);
         if(itemsToShow.length != 0 && actionParams.hasOwnProperty("itemList"))
         {
            itemsToShowNames = [];
            for each(item in itemsToShow)
            {
               if(actionParams["itemList"].item.indexOf(item.name) != -1)
               {
                  itemsToShowNames.push(item.name);
                  FarmStatsManager.count(this.m_statsCategory,LE_STATS_KINGDOM_VIEW,item.name);
               }
            }
            this.m_miniMarketWindow = UI.displayMiniMarketDialog(itemsToShowNames,UI.MARKET_CONTEXT_UNKNOWN,"",this.onMiniMarketClose) as MarketWindow;
            this.m_miniMarketWindow.addEventListener(MarketEvent.MARKET_BUY,this.leMiniMarketPurchased);
         }
         else
         {
            UI.displayMarketDialog(UI.MARKET_CONTEXT_UNKNOWN,FarmItemType.LIMITED) as MarketWindow;
         }
      }
      
      override public function execute() : void
      {
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LE_LAST_CHANCE) == Experiments.VARIANT_LE_LAST_CHANCE_EXPIRING)
         {
            this.m_statsCategory = LE_STATS_CATEGORY_EXPIRE;
            this.m_statsKingdom = LE_STATS_KINGDOM_EXPIRE;
            this.m_daysOfDefinition = LESurfacingManager.EXPIRING_DAYS;
            this.m_isNew = false;
         }
         else
         {
            this.m_statsCategory = LE_STATS_CATEGORY_NEW;
            this.m_statsKingdom = LE_STATS_KINGDOM_NEW;
            this.m_daysOfDefinition = LESurfacingManager.NEW_DAYS;
            this.m_isNew = true;
         }
         FarmStatsManager.count(this.m_statsCategory,this.m_statsKingdom,LE_STATS_PHYLUM_IMPRESSION);
         super.execute();
      }
      
      private function onMiniMarketClose(closeIsBuy:Boolean) : void
      {
         this.m_miniMarketWindow.removeEventListener(MarketEvent.MARKET_BUY,this.leMiniMarketPurchased);
         this.m_miniMarketWindow = null;
      }
      
      private function leMiniMarketPurchased(event:MarketEvent) : void
      {
         var itemName:String = null;
         var item:FarmItem = null;
         if(event.hasOwnProperty("item"))
         {
            itemName = event.item;
            item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            FarmStatsManager.count(this.m_statsCategory,LE_STATS_KINGDOM_BUY,itemName,String(item.cash));
         }
      }
   }
}

