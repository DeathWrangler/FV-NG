package Classes.crafting
{
   import Classes.ZItem.FarmItem;
   import Managers.Crafting.CraftingManager;
   import flash.utils.Dictionary;
   
   public class CraftingInventoryStateV2
   {
      
      public static const MAX_UNSHARABLE_BUSHEL_CAPACITY:int = 400;
      
      private var m_marketStallItems:Dictionary = new Dictionary();
      
      private var m_craftingSiloItems:Dictionary = new Dictionary();
      
      private var m_labItems:Dictionary = new Dictionary();
      
      private var m_unsharableItems:Dictionary = new Dictionary();
      
      private var m_villageItems:Dictionary = new Dictionary();
      
      private var m_isStallCountInit:Boolean = false;
      
      private var m_isCottageCountInit:Boolean = false;
      
      private var m_isBaseCapacityInit:Boolean = false;
      
      private var m_baseCapacity:int;
      
      private var m_placedMarketStallCount:int;
      
      private var m_craftingSiloMaxCapacity:int;
      
      private var m_villageStorageMaxCapacity:int;
      
      protected var m_isMarketDirty:Boolean = true;
      
      private var m_placedCraftingCottageCount:int;
      
      public function CraftingInventoryStateV2()
      {
         super();
      }
      
      private static function currentCapacityHelper(itemArray:Dictionary) : int
      {
         var item:MarketInventoryItem = null;
         var total:int = 0;
         for each(item in itemArray)
         {
            total += item.quantity;
         }
         return total;
      }
      
      public function get isMarketDirty() : Boolean
      {
         return this.m_isMarketDirty;
      }
      
      public function set isMarketDirty(_dirty:Boolean) : void
      {
         this.m_isMarketDirty = _dirty;
      }
      
      public function get craftingSiloItems() : Dictionary
      {
         return this.m_craftingSiloItems;
      }
      
      public function set craftingSiloItems(value:Dictionary) : void
      {
         this.m_isMarketDirty = true;
         this.m_craftingSiloItems = value;
      }
      
      public function get marketStallItems() : Dictionary
      {
         return this.m_marketStallItems;
      }
      
      public function get marketStallItemsArray() : Array
      {
         var item:MarketInventoryItem = null;
         var marketStallItemsArray:Array = [];
         for each(item in this.m_marketStallItems)
         {
            marketStallItemsArray.push(item);
         }
         return marketStallItemsArray;
      }
      
      public function set marketStallItems(value:Dictionary) : void
      {
         this.m_isMarketDirty = true;
         this.m_marketStallItems = value;
      }
      
      public function get labItems() : Dictionary
      {
         return this.m_labItems;
      }
      
      public function set labItems(value:Dictionary) : void
      {
         this.m_isMarketDirty = true;
         this.m_labItems = value;
      }
      
      public function get unsharableItems() : Dictionary
      {
         return this.m_unsharableItems;
      }
      
      public function set unsharableItems(value:Dictionary) : void
      {
         this.m_isMarketDirty = true;
         this.m_unsharableItems = value;
      }
      
      public function get villageStorageItems() : Dictionary
      {
         return this.m_villageItems;
      }
      
      public function set villageStorageItems(value:Dictionary) : void
      {
         this.m_isMarketDirty = true;
         this.m_villageItems = value;
      }
      
      public function get currentCapacity() : int
      {
         return currentCapacityHelper(this.m_marketStallItems);
      }
      
      public function get numUnsharableBushels() : int
      {
         return currentCapacityHelper(this.m_unsharableItems);
      }
      
      public function get craftingSiloCurrentCapacity() : int
      {
         return currentCapacityHelper(this.m_craftingSiloItems);
      }
      
      public function get villageStorageCurrentCapacity() : int
      {
         return currentCapacityHelper(this.m_villageItems);
      }
      
      public function get availableUnsharableInventorySpace() : int
      {
         return CraftingInventoryStateV2.MAX_UNSHARABLE_BUSHEL_CAPACITY - (this.numUnsharableBushels + CraftingManager.getNumBushelsOfSubtypeInQueues(CraftingManager.CRAFTING_BUSHEL_SUBTYPE_UNSHARABLE));
      }
      
      public function getUnsharableBushelWithLargestQuantity() : FarmItem
      {
         var item:MarketInventoryItem = null;
         var itemWithMost:FarmItem = null;
         var largestQuantity:int = 0;
         var numUnsharableItems:int = int(this.m_unsharableItems.length);
         for each(item in this.m_unsharableItems)
         {
            if(Boolean(item.underlyingItem) && item.quantity > largestQuantity)
            {
               largestQuantity = item.quantity;
               itemWithMost = item.underlyingItem;
            }
         }
         return itemWithMost;
      }
      
      public function getNumUnsharableBushelWithCode(itemCode:String) : int
      {
         var item:MarketInventoryItem = null;
         var quantity:int = 0;
         for each(item in this.m_unsharableItems)
         {
            if(item.itemCode == itemCode)
            {
               quantity = item.quantity;
            }
         }
         return quantity;
      }
      
      public function getItemsBySubtype(subtype:String) : Array
      {
         var thisItem:MarketInventoryItem = null;
         var item:FarmItem = null;
         var results:Array = new Array();
         for each(thisItem in this.m_marketStallItems)
         {
            if(thisItem.quantity > 0)
            {
               item = Global.farmGameSettingsManager.getFarmItemByCode(thisItem.itemCode);
               if(item.subType == subtype)
               {
                  results.push(thisItem);
               }
            }
         }
         return results;
      }
      
      public function get isFull() : Boolean
      {
         return this.currentCapacity >= this.maxCapacity;
      }
      
      public function get isSiloFull() : Boolean
      {
         return this.craftingSiloCurrentCapacity >= this.craftingSiloMaxCapacity;
      }
      
      public function get isVillageStorageFull() : Boolean
      {
         return this.villageStorageCurrentCapacity >= this.villageStorageMaxCapacity;
      }
      
      public function get isUnsharableStorageFull() : Boolean
      {
         return this.numUnsharableBushels >= MAX_UNSHARABLE_BUSHEL_CAPACITY;
      }
      
      public function get maxCapacity() : int
      {
         return this.m_baseCapacity;
      }
      
      public function set baseCapacity(newBaseCapacity:int) : void
      {
         this.m_baseCapacity = newBaseCapacity;
         if(!this.m_isBaseCapacityInit)
         {
            this.m_isBaseCapacityInit = true;
         }
      }
      
      public function set craftingSiloMaxCapacity(newCraftingSiloMaxCapacity:int) : void
      {
         this.m_craftingSiloMaxCapacity = newCraftingSiloMaxCapacity;
      }
      
      public function get craftingSiloMaxCapacity() : int
      {
         return this.m_craftingSiloMaxCapacity;
      }
      
      public function set villageStorageMaxCapacity(newVillageStorageMaxCapacity:int) : void
      {
         this.m_villageStorageMaxCapacity = newVillageStorageMaxCapacity;
      }
      
      public function get villageStorageMaxCapacity() : int
      {
         return this.m_villageStorageMaxCapacity;
      }
      
      public function get placedMarketStallCount() : int
      {
         return this.m_placedMarketStallCount;
      }
      
      public function set placedMarketStallCount(newPlacedMarketStallCount:int) : void
      {
         this.m_placedMarketStallCount = newPlacedMarketStallCount;
         if(!this.m_isStallCountInit)
         {
            this.m_isStallCountInit = true;
         }
      }
      
      public function get placedCraftingCottageCount() : int
      {
         return this.m_placedCraftingCottageCount;
      }
      
      public function set placedCraftingCottageCount(newPlacedCraftingCottageCount:int) : void
      {
         this.m_placedCraftingCottageCount = newPlacedCraftingCottageCount;
         if(!this.m_isCottageCountInit)
         {
            this.m_isCottageCountInit = true;
         }
      }
   }
}

