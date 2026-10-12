package Classes
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Managers.LESurfacingManager;
   import Managers.PerformanceExperimentManager;
   
   public class MarketRecommendations
   {
      
      private var m_initData:Object = {};
      
      private var m_bestSellers:Array = [];
      
      private var m_brandedItems:Array = [];
      
      private var m_recommendedItems:Array;
      
      private var m_farmAidesSlot:Array;
      
      private var m_latestLERelease:Array;
      
      private var m_LEOrder:Object = {};
      
      public var m_marketImpressions:int = 0;
      
      public var m_slot0MarketCards:Array = null;
      
      private const TYPE_TREE:String = "tree";
      
      private const TYPE_ANIMAL:String = "animal";
      
      private const TYPE_BUILDING:String = "building";
      
      private const TYPE_DECO:String = "decoration";
      
      private const TYPE_CONSUMABLE:String = "consumable";
      
      private const TYPES_AVAILABLE:Array = [this.TYPE_TREE,this.TYPE_ANIMAL,this.TYPE_BUILDING,this.TYPE_CONSUMABLE,this.TYPE_DECO];
      
      private const FARM_AIDES_DEFAULT:Array = ["fuel10,pkg_farm_hands_5,turbo_charger_60pack"];
      
      private const NUM_FARM_AIDE_SLOTS:int = 3;
      
      private const NUM_EACH_ITEM:int = 4;
      
      public function MarketRecommendations()
      {
         super();
      }
      
      public function initialize(initData:Object) : void
      {
         this.m_initData = initData;
         this.m_bestSellers = null;
         this.m_brandedItems = null;
         this.LEOrderInit();
      }
      
      public function LEOrderInit() : void
      {
         this.m_LEOrder = {};
         this.m_LEOrder[this.TYPE_ANIMAL] = {
            "number":0,
            "order":5
         };
         this.m_LEOrder[this.TYPE_TREE] = {
            "number":0,
            "order":4
         };
         this.m_LEOrder[this.TYPE_BUILDING] = {
            "number":0,
            "order":3
         };
         this.m_LEOrder[this.TYPE_DECO] = {
            "number":0,
            "order":2
         };
         this.m_LEOrder[this.TYPE_CONSUMABLE] = {
            "number":0,
            "order":1
         };
      }
      
      public function getBestSellers() : Array
      {
         var count:Number = NaN;
         var itemCode:String = null;
         var farmItem:FarmItem = null;
         var limit:Number = Global.marketConfigSettings.maxBestSellers;
         if(this.m_bestSellers == null)
         {
            count = 0;
            this.m_bestSellers = [];
            for each(itemCode in this.m_initData)
            {
               farmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
               if(Boolean(farmItem) && Boolean(farmItem.isVisible) && farmItem.isUnlocked)
               {
                  this.m_bestSellers.push(farmItem);
                  count++;
               }
               if(count >= limit)
               {
                  break;
               }
            }
         }
         if(this.m_bestSellers.length <= 0)
         {
            this.m_bestSellers = Global.marketConfigSettings.getDefaultBestSellers();
         }
         return this.m_bestSellers;
      }
      
      public function getBrandedItems() : Array
      {
         if(!this.m_brandedItems && (Global.farmGameSettingsManager.itemsXMLParsingComplete || !PerformanceExperimentManager.isInInterruptFreeItemParsingExperiment))
         {
            this.m_brandedItems = [];
         }
         return this.m_brandedItems;
      }
      
      public function getRecommendedItems() : Array
      {
         var sortingArray:Array = null;
         var i:int = 0;
         var type:String = null;
         var LEItems:Array = null;
         var randomizedArray:Array = null;
         var resultArray:Array = null;
         var j:* = 0;
         var farmItem:FarmItem = null;
         if(this.m_recommendedItems == null)
         {
            this.m_recommendedItems = [];
            sortingArray = this.getSortingArray();
            for(i = 0; i < sortingArray.length; i++)
            {
               type = sortingArray[i].type;
               LEItems = [];
               randomizedArray = [];
               resultArray = [];
               if(type == this.TYPE_CONSUMABLE)
               {
                  LEItems = Global.farmGameSettingsManager.getFarmItemsArray("aide");
               }
               else
               {
                  LEItems = Global.farmGameSettingsManager.getFarmItemsArray("limited",type);
               }
               while(LEItems.length > 0)
               {
                  randomizedArray = randomizedArray.concat(LEItems.splice(Math.round(Math.random() * (LEItems.length - 1)),1));
               }
               j = int(randomizedArray.length - 1);
               while(j >= 0 && resultArray.length < this.NUM_EACH_ITEM)
               {
                  farmItem = randomizedArray[j] as FarmItem;
                  if(farmItem)
                  {
                     if(LESurfacingManager.instance.numberOfItemPurchases(farmItem.name) == 0 && !farmItem.isLocked && farmItem.isVisible && farmItem.isCash)
                     {
                        resultArray = resultArray.concat(randomizedArray.splice(j,1));
                     }
                  }
                  j--;
               }
               resultArray = resultArray.concat(randomizedArray.splice(0,this.NUM_EACH_ITEM - resultArray.length));
               this.m_recommendedItems = this.m_recommendedItems.concat(resultArray);
            }
         }
         return this.m_recommendedItems;
      }
      
      private function getSortingArray(minPurchase:int = 5) : Array
      {
         var key:String = null;
         var fewItem:Object = null;
         var item:Object = null;
         var itemForType:FarmItem = null;
         this.LEOrderInit();
         var purchasedItems:Array = LESurfacingManager.instance.cashItemsPurchasedRecently(15);
         var categoryOrder:Object = this.m_LEOrder;
         var sortingArray:Array = [];
         var itemType:String = "";
         var count:int = 0;
         if(purchasedItems.length > 0 && purchasedItems.length < minPurchase)
         {
            for each(fewItem in purchasedItems)
            {
               count += fewItem[LESurfacingManager.PURCHASED_ITEM_NUMBER_PURCHASED_INDEX];
            }
         }
         if(purchasedItems.length >= minPurchase || count >= minPurchase)
         {
            for each(item in purchasedItems)
            {
               itemForType = Global.farmGameSettingsManager.getFarmItemByName(item[LESurfacingManager.PURCHASED_ITEM_NAME_INDEX]);
               if(Boolean(itemForType) && Boolean(itemForType.type) && this.TYPES_AVAILABLE.indexOf(itemForType.type) > -1)
               {
                  itemType = itemForType.type;
                  categoryOrder[itemType].number += item[LESurfacingManager.PURCHASED_ITEM_NUMBER_PURCHASED_INDEX];
               }
               else if(Boolean(itemForType) && Boolean(itemForType.type) && item[LESurfacingManager.PURCHASED_ITEM_TYPE_OF_PURCHASE_INDEX] == LESurfacingManager.PURCHASED_ITEM_TYPE_BUY)
               {
                  itemType = itemForType.type;
                  categoryOrder[this.TYPE_CONSUMABLE].number += item[LESurfacingManager.PURCHASED_ITEM_NUMBER_PURCHASED_INDEX];
               }
            }
         }
         var arrayIndex:int = 0;
         for(key in categoryOrder)
         {
            sortingArray[arrayIndex] = categoryOrder[key];
            sortingArray[arrayIndex].type = key;
            arrayIndex++;
         }
         sortingArray.sortOn(["number","order"],Array.DESCENDING);
         return sortingArray;
      }
      
      public function sortItemsByRecomended(items:Array, numPerType:int = 5, minPurchase:int = 5) : Array
      {
         var item:FarmItem = null;
         var type:String = null;
         var tempArray:Array = null;
         var j:int = 0;
         var farmItem:FarmItem = null;
         var result:Array = [];
         var sortingArray:Array = this.getSortingArray();
         for(var i:int = 0; i < sortingArray.length; i++)
         {
            type = sortingArray[i].type;
            tempArray = [];
            j = 0;
            while(j < items.length && tempArray.length < numPerType)
            {
               farmItem = items[j] as FarmItem;
               if(Boolean(farmItem) && farmItem.type == type)
               {
                  tempArray.push(farmItem);
               }
               j++;
            }
            result = result.concat(tempArray);
         }
         for each(item in items)
         {
            if(result.indexOf(item) == -1)
            {
               result.push(item);
            }
         }
         return result;
      }
      
      public function getLatestLESet() : Array
      {
         var latestLE:Array = null;
         var orderedArray:Array = null;
         var animal:Array = null;
         var tree:Array = null;
         var otherType:Array = null;
         var item:FarmItem = null;
         var runtimeItems:Array = null;
         var randomizedArray:Array = null;
         if(this.m_latestLERelease == null)
         {
            this.m_latestLERelease = new Array();
            latestLE = LESurfacingManager.instance.getLatestLESet();
            if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_MARKETPLACE_3_HOMEPAGE_NEW_ARRIVALS) == 2)
            {
               orderedArray = new Array();
               animal = new Array();
               tree = new Array();
               otherType = new Array();
               for each(item in latestLE)
               {
                  if(item.type == "animal")
                  {
                     animal.push(item);
                  }
                  else if(item.type == "tree")
                  {
                     tree.push(item);
                  }
                  else
                  {
                     otherType.push(item);
                  }
               }
               while(otherType.length > 0 || animal.length > 1 || tree.length > 0)
               {
                  if(animal.length > 1)
                  {
                     this.m_latestLERelease = this.m_latestLERelease.concat(animal.splice(Math.round(Math.random() * (animal.length - 1)),2));
                  }
                  else if(animal.length > 0)
                  {
                     this.m_latestLERelease = this.m_latestLERelease.concat(animal.splice(Math.round(Math.random() * (animal.length - 1)),1));
                  }
                  if(tree.length > 0)
                  {
                     this.m_latestLERelease = this.m_latestLERelease.concat(tree.splice(Math.round(Math.random() * (tree.length - 1)),1));
                  }
                  if(otherType.length > 0)
                  {
                     this.m_latestLERelease = this.m_latestLERelease.concat(otherType.splice(Math.round(Math.random() * (otherType.length - 1)),1));
                  }
               }
               runtimeItems = this.runtimeToFarmItems("MARKETHOMEPAGE_NEW_ARRIVALS");
               if(runtimeItems.length > 0)
               {
                  this.m_latestLERelease = runtimeItems.splice(0,runtimeItems.length).concat(this.m_latestLERelease);
               }
            }
            else
            {
               randomizedArray = new Array();
               while(latestLE.length > 0)
               {
                  randomizedArray = randomizedArray.concat(latestLE.splice(Math.round(Math.random() * (latestLE.length - 1)),1));
               }
               this.m_latestLERelease = randomizedArray;
            }
         }
         return this.m_latestLERelease;
      }
      
      public function getFarmAidsSlot() : Array
      {
         var itemNameArray:Array = null;
         var itemName:String = null;
         if(this.m_farmAidesSlot == null)
         {
            this.m_farmAidesSlot = this.runtimeToFarmItems("MARKETHOMEPAGE_ITEMS");
            if(this.m_farmAidesSlot.length != this.NUM_FARM_AIDE_SLOTS)
            {
               this.m_farmAidesSlot = new Array();
               itemNameArray = this.FARM_AIDES_DEFAULT;
               for each(itemName in itemNameArray)
               {
                  this.m_farmAidesSlot.push(Global.farmGameSettingsManager.getFarmItemByName(itemName));
               }
            }
         }
         return this.m_farmAidesSlot;
      }
      
      private function runtimeToFarmItems(runtimeName:String) : Array
      {
         var itemName:String = null;
         var itemNames:String = Global.flashHotParams[runtimeName];
         var itemNameArray:Array = itemNames.replace(" ","").split(",");
         var result:Array = new Array();
         for each(itemName in itemNameArray)
         {
            if(Global.farmGameSettingsManager.getFarmItemByName(itemName) != null)
            {
               result.push(Global.farmGameSettingsManager.getFarmItemByName(itemName));
            }
         }
         return result;
      }
   }
}

