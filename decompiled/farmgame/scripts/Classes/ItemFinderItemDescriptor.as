package Classes
{
   import Classes.ZItem.FarmItem;
   import Managers.SuperPlotManager;
   
   public class ItemFinderItemDescriptor
   {
      
      private var m_itemName:String = "";
      
      private var m_worldCount:uint = 0;
      
      private var m_worldCountAOE:uint = 0;
      
      private var m_storageCount:uint = 0;
      
      private var m_giftCount:uint = 0;
      
      private var m_inventoryCount:uint = 0;
      
      private var m_tempHarvestCountForSeedSinceLastBushelDrop:uint = 0;
      
      public function ItemFinderItemDescriptor(itemName:String)
      {
         super();
         this.m_itemName = itemName;
      }
      
      public function get itemName() : String
      {
         return this.m_itemName;
      }
      
      public function get friendlyName() : String
      {
         var friendlyName:String = "";
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         if(farmItem)
         {
            friendlyName = farmItem.friendlyTitle;
         }
         return friendlyName;
      }
      
      public function get iconUrl() : String
      {
         var iconUrl:String = "";
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         if(farmItem)
         {
            iconUrl = farmItem.iconUrl;
         }
         return iconUrl;
      }
      
      public function get worldCount() : uint
      {
         return this.m_worldCount;
      }
      
      public function get worldCountAOE() : uint
      {
         return this.m_worldCountAOE;
      }
      
      public function addWorldItems(worldCount:uint, isSuperPlot:Boolean = false, aoeCount:int = 1) : void
      {
         if(isSuperPlot)
         {
            this.m_worldCount += worldCount * SuperPlotManager.SUPER_PLOT_MULTIPLIER;
            this.m_worldCountAOE += aoeCount * SuperPlotManager.SUPER_PLOT_MULTIPLIER;
         }
         else
         {
            this.m_worldCount += worldCount;
            this.m_worldCountAOE += aoeCount;
         }
      }
      
      public function get storageCount() : uint
      {
         return this.m_storageCount;
      }
      
      public function addStorageItems(storageCount:uint) : void
      {
         this.m_storageCount += storageCount;
      }
      
      public function addTempHarvestCountForSeedSinceLastBushelDrop(itemCount:uint) : void
      {
         this.m_tempHarvestCountForSeedSinceLastBushelDrop += itemCount;
      }
      
      public function get tempHarvestCountForSeedInItemFinder() : uint
      {
         return this.m_tempHarvestCountForSeedSinceLastBushelDrop;
      }
      
      public function get giftCount() : uint
      {
         return this.m_giftCount;
      }
      
      public function get inventoryCount() : uint
      {
         return this.m_inventoryCount;
      }
      
      public function addGiftItems(giftCount:uint) : void
      {
         this.m_giftCount += giftCount;
      }
      
      public function addInventoryItems(inventoryCount:uint) : void
      {
         this.m_inventoryCount += inventoryCount;
      }
   }
}

