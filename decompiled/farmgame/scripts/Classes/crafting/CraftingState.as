package Classes.crafting
{
   import Classes.Constants.Experiments;
   import Classes.CraftingCottageBuilding;
   import Classes.FeatureBuilding;
   import Classes.MarketStallBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.storage.BushelBabiesCraftItem;
   import Classes.storage.CraftedItem;
   import Classes.storage.StorageItem;
   import Events.FriendManagerEvent;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Managers.HangingGardensManager;
   import Managers.SubscriptionsManager;
   import flash.utils.Dictionary;
   
   public class CraftingState
   {
      
      public static const NUM_CREW_REQUIRED_TO_HELP:int = 4;
      
      private static const CRAFTING_SILO_ITEM_CODE:String = "i-";
      
      public static const OVEN_SLOT_DEAFULT:int = -2;
      
      public static const SECS_IN_8_HOURS:int = 28800;
      
      public static const SECS_IN_12_HOURS:int = 43200;
      
      public static const SECS_IN_24_HOURS:int = 86400;
      
      private var m_initialized:Boolean = false;
      
      private var m_hasCottage:Boolean = false;
      
      private var m_craftingInventoryState:CraftingInventoryStateV2 = new CraftingInventoryStateV2();
      
      private var m_craftedGoodInventory:Dictionary = new Dictionary();
      
      private var m_bushelbabiesCraftItemInventory:Dictionary = new Dictionary();
      
      private var m_shoppingState:ShoppingState = new ShoppingState();
      
      private var m_craftingCalendarDate:Number;
      
      private var m_nextCraftingDate:Number;
      
      private var m_pendingRewards:Array = new Array();
      
      private var m_craftingSkillState:CraftingSkillState = new CraftingSkillState();
      
      private var m_firstCraft:String;
      
      private var m_craftingCrew:Array = new Array();
      
      private var m_recipeQueue:Object = new Object();
      
      private var m_marketStall:MarketStallBuilding = null;
      
      private var m_craftingSilo:FeatureBuilding = null;
      
      private var m_numOfRecipesCompleted:Array = new Array();
      
      public function CraftingState()
      {
         super();
      }
      
      public function loadRecipeQueue(recipeQueue:Object) : void
      {
         var craftSkill:String = null;
         var recipeQueueLength:int = 0;
         var i:int = 0;
         for(craftSkill in recipeQueue)
         {
            if(!this.m_recipeQueue.hasOwnProperty(craftSkill))
            {
               this.m_recipeQueue[craftSkill] = new Array();
            }
            recipeQueueLength = int(recipeQueue[craftSkill].length);
            for(i = 0; i < recipeQueueLength; i++)
            {
               this.m_recipeQueue[craftSkill].push(RecipeItem.fromPhpObject(recipeQueue[craftSkill][i]));
            }
         }
      }
      
      public function getRecipeQueueForCraftType(craftType:String) : Array
      {
         var result:Array = new Array();
         if(this.m_recipeQueue.hasOwnProperty(craftType))
         {
            result = this.m_recipeQueue[craftType];
         }
         return result;
      }
      
      public function beginRecipeForCraftType(craftType:String, recipeItem:RecipeItem, ignoreServerCheck:Boolean = false) : void
      {
         if(recipeItem.serverStarted && !ignoreServerCheck)
         {
            throw new Error("CraftingState::beginRecipeForCraftType tried to start a recipe that has already been started");
         }
         if(!this.m_recipeQueue.hasOwnProperty(craftType) || this.m_recipeQueue[craftType] == null)
         {
            this.m_recipeQueue[craftType] = new Array();
         }
         this.m_recipeQueue[craftType].push(recipeItem);
      }
      
      public function onRecipeBegunForCraftType(craftType:String, recipeItem:RecipeItem) : void
      {
         var checkRecipe:RecipeItem = null;
         if(!recipeItem.serverStarted)
         {
            throw new Error("CraftingState::onRecipeBegunForCraftType tried to add a recipe that has not been started on the server");
         }
         var added:Boolean = false;
         for(var i:int = 0; i < this.m_recipeQueue[craftType].length; i++)
         {
            checkRecipe = this.m_recipeQueue[craftType][i];
            if(checkRecipe.id == recipeItem.id && !checkRecipe.serverStarted)
            {
               this.m_recipeQueue[craftType][i] = recipeItem;
               added = true;
               break;
            }
         }
         if(!added)
         {
            throw new Error("CraftingState::onRecipeBegunForCraftType could not find reserved slot for server response recipe");
         }
      }
      
      public function getMarketStall() : MarketStallBuilding
      {
         var stallArray:Array = null;
         var toReturn:MarketStallBuilding = this.m_marketStall;
         if(toReturn == null)
         {
            stallArray = Global.world.getObjectsByClass(MarketStallBuilding);
            if(Boolean(stallArray) && Boolean(stallArray.length))
            {
               toReturn = stallArray[0];
               this.m_marketStall = toReturn;
            }
         }
         return toReturn;
      }
      
      public function getCraftingSilo() : FeatureBuilding
      {
         var siloArray:Array = null;
         var toReturn:FeatureBuilding = this.m_craftingSilo;
         if(toReturn == null)
         {
            siloArray = Global.world.getObjectsByClass(FeatureBuilding).filter(function(building:FeatureBuilding, _index:int, _array:Array):Boolean
            {
               return building.getFarmItem().code == CRAFTING_SILO_ITEM_CODE;
            });
            if(Boolean(siloArray) && Boolean(siloArray.length))
            {
               toReturn = siloArray[0];
               this.m_craftingSilo = toReturn;
            }
         }
         return toReturn;
      }
      
      public function onEndFinishedRecipesClaimedForCraftType(craftType:String, recipeItem:RecipeItem, ovenSlot:int = -2) : void
      {
         var recipe:RecipeItem = null;
         var recipeQueueCraftType:Array = this.m_recipeQueue[craftType];
         for(var i:int = 0; i < recipeQueueCraftType.length; i++)
         {
            recipe = recipeQueueCraftType[i];
            if(HangingGardensManager.isInHangingGardensExperiment() && Boolean(Global.flashHotParams["HANGING_GARDENS_CRAFTSHOP"]))
            {
               if(recipe.id == recipeItem.id && (recipe.ovenSlot == ovenSlot || ovenSlot == OVEN_SLOT_DEAFULT) && recipe.worldType == Global.worldManager.currentWorldType)
               {
                  if(this.m_numOfRecipesCompleted[craftType] == null)
                  {
                     this.m_numOfRecipesCompleted[craftType] = 0;
                  }
                  ++this.m_numOfRecipesCompleted[craftType];
                  recipeQueueCraftType.splice(i,1);
                  break;
               }
            }
            else if(recipe.id == recipeItem.id && recipe.worldType == Global.worldManager.currentWorldType)
            {
               recipeQueueCraftType.splice(i,1);
               break;
            }
         }
      }
      
      public function getNumOfRecipesToCompleteByType(craftType:String) : int
      {
         return this.m_numOfRecipesCompleted[craftType];
      }
      
      public function setNumOfRecipesCompleted(numOfRecipesToCompleted:Object) : void
      {
         var craftType:String = null;
         if(numOfRecipesToCompleted == null)
         {
            this.m_numOfRecipesCompleted = new Array();
         }
         else
         {
            for(craftType in numOfRecipesToCompleted)
            {
               if(!this.m_numOfRecipesCompleted.hasOwnProperty(craftType))
               {
                  this.m_numOfRecipesCompleted[craftType] = numOfRecipesToCompleted[craftType];
               }
            }
         }
      }
      
      public function get pendingRewards() : Array
      {
         return this.m_pendingRewards;
      }
      
      public function get craftingCrew() : Array
      {
         return this.m_craftingCrew;
      }
      
      public function getCrewOnRecipe(recipeId:String) : Array
      {
         var crewMember:CraftingCrewMember = null;
         var recipeCrew:Array = new Array();
         for(var crewIndex:int = 0; crewIndex < this.m_craftingCrew.length; crewIndex++)
         {
            crewMember = this.m_craftingCrew[crewIndex] as CraftingCrewMember;
            if(crewMember.m_recipeId == recipeId && crewMember.m_worldType == Global.worldManager.currentWorldType)
            {
               recipeCrew.push(this.m_craftingCrew[crewIndex]);
            }
         }
         return recipeCrew;
      }
      
      public function set pendingRewards(newPendingRewards:Array) : void
      {
         this.m_pendingRewards = newPendingRewards;
      }
      
      public function get inventoryState() : CraftingInventoryStateV2
      {
         return this.m_craftingInventoryState;
      }
      
      public function get shoppingState() : ShoppingState
      {
         return this.m_shoppingState;
      }
      
      public function get placedCottage() : Boolean
      {
         return this.m_hasCottage;
      }
      
      public function onCottageModified(removal:Boolean = false) : void
      {
         var cottageInWorld:Boolean = true;
         if(removal)
         {
            cottageInWorld = CraftingManager.getInstance().getNumberOfPlacedCraftingCottages() > 0;
         }
         this.m_hasCottage = !removal || cottageInWorld;
      }
      
      public function get placedCottageCount() : int
      {
         return Global.player.craftingState.inventoryState.placedCraftingCottageCount;
      }
      
      public function set placedCottageCount(value:int) : void
      {
         Global.player.craftingState.inventoryState.placedCraftingCottageCount = value;
      }
      
      public function get placedMarketStallCount() : int
      {
         return Global.player.craftingState.inventoryState.placedMarketStallCount;
      }
      
      public function set placedMarketStallCount(newPlacedMarketStallCount:int) : void
      {
         Global.player.craftingState.inventoryState.placedMarketStallCount = newPlacedMarketStallCount;
      }
      
      public function get craftingSkillState() : CraftingSkillState
      {
         return this.m_craftingSkillState;
      }
      
      private function orderByTimeStamp(crewA:Object, crewB:Object) : int
      {
         if(crewA.m_timestamp < crewB.m_timestamp)
         {
            return -1;
         }
         if(crewA.m_timestamp > crewB.m_timestamp)
         {
            return 1;
         }
         return 0;
      }
      
      public function initCraftingStateFromInitUser(craftingStateResult:Object) : void
      {
         var item:Object = null;
         var marketItem:MarketInventoryItem = null;
         var craftType:int = 0;
         var beginOOS_itemsStr:String = null;
         var shoppingStateObject:Object = null;
         var i:int = 0;
         var consumedBag:Object = null;
         var craftingBag:Object = null;
         var j:int = 0;
         var rewardObject:Object = null;
         var thisReward:PendingReward = null;
         var craftTypes:Object = null;
         var stateIdx:int = 0;
         var craftTypeObj:Object = null;
         var craftTypeState:CraftTypeState = null;
         this.m_initialized = true;
         for each(item in craftingStateResult.craftingItems)
         {
            marketItem = new MarketInventoryItem();
            marketItem.constructFromResponseObject(item);
            craftType = CraftingManager.getInstance().getCraftTypeofBushel(marketItem.itemCode);
            if(craftType == CraftingManager.BUSHEL_TYPE_SILO)
            {
               this.m_craftingInventoryState.craftingSiloItems[marketItem.itemCode] = marketItem;
            }
            else if(craftType == CraftingManager.BUSHEL_TYPE_STALL)
            {
               this.m_craftingInventoryState.marketStallItems[marketItem.itemCode] = marketItem;
            }
            else if(craftType == CraftingManager.BUSHEL_TYPE_LAB)
            {
               this.m_craftingInventoryState.labItems[marketItem.itemCode] = marketItem;
            }
            else if(craftType == CraftingManager.BUSHEL_TYPE_UNSHARABLE)
            {
               this.m_craftingInventoryState.unsharableItems[marketItem.itemCode] = marketItem;
            }
            else if(craftType == CraftingManager.BUSHEL_TYPE_VILLAGE)
            {
               this.m_craftingInventoryState.villageStorageItems[marketItem.itemCode] = marketItem;
            }
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CRAFTING_OOS_STATS) > 0)
            {
               beginOOS_itemsStr = "item_" + marketItem.itemCode + ":" + marketItem.quantity;
               FarmStatsManager.count("beginOOS","client","initPush",beginOOS_itemsStr);
            }
         }
         if(craftingStateResult.shoppingState != null)
         {
            shoppingStateObject = craftingStateResult.shoppingState;
            this.shoppingState.maxBagsPerUser = shoppingStateObject.maxDailyBags;
            this.shoppingState.maxPurchasesPerDay = shoppingStateObject.maxDailyPurchases;
            this.shoppingState.maxCraftingBagsPerUser = shoppingStateObject.maxDailyCraftingBags;
            this.shoppingState.maxCraftingPurchasesPerDay = shoppingStateObject.maxDailyCraftingPurchases;
            this.shoppingState.lastGetBushelsRequestTS = shoppingStateObject.lastBushelsRequestTS;
            for(i = 0; i < shoppingStateObject.consumedBags.length; i++)
            {
               consumedBag = shoppingStateObject.consumedBags[i];
               this.shoppingState.addBagsUsed(consumedBag.uid,consumedBag.bags);
            }
            for(i = 0; i < shoppingStateObject.consumedCraftingBags.length; i++)
            {
               craftingBag = shoppingStateObject.consumedCraftingBags[i];
               this.shoppingState.addCraftingBagsUsed(craftingBag.uid,craftingBag.bags);
            }
         }
         this.nextCraftingDate = craftingStateResult.nextCalendarDate;
         this.craftingCalendarDate = craftingStateResult.calendarDate;
         if(craftingStateResult.pendingRewards != null)
         {
            for(j = 0; j < craftingStateResult.pendingRewards.length; j++)
            {
               rewardObject = craftingStateResult.pendingRewards[j];
               thisReward = new PendingReward();
               thisReward.claimed = false;
               thisReward.visitorUid = rewardObject.visitor;
               thisReward.time = rewardObject.time;
               thisReward.count = rewardObject.count;
               this.m_pendingRewards.push(thisReward);
            }
            if(this.m_pendingRewards.length > 0)
            {
               CraftingStatsManager.recordHasRewardAvailableOnLogin();
            }
         }
         this.m_craftingInventoryState.baseCapacity = craftingStateResult.maxCapacity;
         this.m_craftingInventoryState.placedMarketStallCount = craftingStateResult.currentMarketStallCount;
         this.m_craftingInventoryState.placedCraftingCottageCount = CraftingManager.getInstance().getNumberOfPlacedCraftingCottages();
         if(craftingStateResult.craftingSkillState != null)
         {
            if(craftingStateResult.craftingSkillState.craftTypes != null)
            {
               craftTypes = craftingStateResult.craftingSkillState.craftTypes;
               for(stateIdx = 0; stateIdx < craftTypes.length; stateIdx++)
               {
                  craftTypeObj = craftTypes[stateIdx];
                  craftTypeState = new CraftTypeState(craftTypeObj.type,craftTypeObj.level,craftTypeObj.xp);
                  craftTypeState.level = craftTypeObj.level;
                  craftTypeState.experience = craftTypeObj.exp;
                  this.craftingSkillState.addCraftTypeState(craftTypeState);
               }
            }
         }
         this.m_firstCraft = craftingStateResult.firstCraft;
         this.loadPublicCraftingData(craftingStateResult);
         if(craftingStateResult.hasOwnProperty("crewQueue"))
         {
            this.updateCrewHelpers(craftingStateResult.crewQueue);
         }
         this.initRecipeStates(craftingStateResult.craftingSkillState.recipeStates);
         Global.friendManager.registerEventListener(this.onFriendManagerEvent);
         if(craftingStateResult.hasOwnProperty("recipeQueue"))
         {
            this.loadRecipeQueue(craftingStateResult.recipeQueue);
         }
         if(craftingStateResult.hasOwnProperty("numOfRecipesCompleted"))
         {
            this.setNumOfRecipesCompleted(craftingStateResult.numOfRecipesCompleted);
         }
         CraftingManager.getInstance().updateCraftingCottageStates();
      }
      
      private function onFriendManagerEvent(event:FriendManagerEvent) : void
      {
         if(event.type == FriendManagerEvent.PARSEFRIENDS_COMPLETE)
         {
            CraftingManager.getInstance().showAllMarketRewardIndicators();
         }
      }
      
      public function loadCraftedGoodsFromInitUser(storageData:Object) : void
      {
         var itemCode:String = null;
         var craftedGood:CraftedItem = null;
         for(itemCode in storageData[Global.world.CRAFTEDGOODS_ID])
         {
            craftedGood = StorageItem.getStorageItem(itemCode,storageData[Global.world.CRAFTEDGOODS_ID][itemCode]) as CraftedItem;
            if(craftedGood != null)
            {
               this.addCraftedItemToInventory(craftedGood);
            }
         }
      }
      
      public function loadBushelBabiesCraftItemsFromInitUser(storageData:Object) : void
      {
         var itemCode:String = null;
         var craftedGood:BushelBabiesCraftItem = null;
         for(itemCode in storageData[Global.world.BUSHELBABIES_ID])
         {
            craftedGood = StorageItem.getStorageItem(itemCode,storageData[Global.world.BUSHELBABIES_ID][itemCode]) as BushelBabiesCraftItem;
            if(craftedGood != null)
            {
               this.addBushelBabiesCraftItemToInventory(craftedGood.itemKey,craftedGood.quantity);
            }
         }
      }
      
      private function loadPublicCraftingData(craftingStateData:Object) : void
      {
         var allCraftTypes:Array = null;
         var craftType:String = null;
         var cottageName:String = null;
         var cottageList:Array = null;
         var cottageListObj:Object = null;
         var craftingCottage:CraftingCottageBuilding = null;
         var allCraftingPublicGoodData:Object = null;
         var craftPublicInventory:Object = null;
         var transactionLogData:Object = null;
         if(craftingStateData)
         {
            allCraftTypes = Global.craftConfigSettings.getAllCraftTypes();
            for each(craftType in allCraftTypes)
            {
               cottageName = Global.craftConfigSettings.getCottageItemNameForSkill(craftType);
               if(cottageName)
               {
                  cottageList = Global.world.getObjectsByName(cottageName);
                  if(cottageList.length > 0)
                  {
                     if(null != craftingStateData.craftingPublicInventory && null != craftingStateData.craftingPublicInventory.publicGoods)
                     {
                        allCraftingPublicGoodData = craftingStateData.craftingPublicInventory.publicGoods;
                        if(allCraftingPublicGoodData.hasOwnProperty(craftType))
                        {
                           craftPublicInventory = allCraftingPublicGoodData[craftType];
                           for each(cottageListObj in cottageList)
                           {
                              if(cottageListObj is CraftingCottageBuilding)
                              {
                                 craftingCottage = cottageListObj as CraftingCottageBuilding;
                                 craftingCottage.setFinishedRecipes(craftPublicInventory);
                              }
                           }
                        }
                     }
                     if(null != craftingStateData.craftingTransactionLogs && Boolean(craftingStateData.craftingTransactionLogs.hasOwnProperty(craftType)))
                     {
                        transactionLogData = craftingStateData.craftingTransactionLogs[craftType];
                        for each(cottageListObj in cottageList)
                        {
                           if(cottageListObj is CraftingCottageBuilding)
                           {
                              craftingCottage = cottageListObj as CraftingCottageBuilding;
                              craftingCottage.loadTransactionHistory(transactionLogData);
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      
      public function addCraftedItemToInventory(craftedGood:CraftedItem) : void
      {
         var existingItem:StorageItem = null;
         if(this.m_craftedGoodInventory[craftedGood.itemKey])
         {
            existingItem = this.m_craftedGoodInventory[craftedGood.itemKey] as StorageItem;
            existingItem.adjustQuantity(craftedGood.quantity);
         }
         else
         {
            this.m_craftedGoodInventory[craftedGood.itemKey] = craftedGood;
         }
      }
      
      public function addBushelBabiesCraftItemToInventory(itemKey:String, quantity:int) : void
      {
         var existingItem:BushelBabiesCraftItem = null;
         var craftItem:BushelBabiesCraftItem = null;
         if(this.m_bushelbabiesCraftItemInventory[itemKey])
         {
            existingItem = this.m_bushelbabiesCraftItemInventory[itemKey];
            existingItem.adjustQuantity(quantity);
         }
         else
         {
            craftItem = BushelBabiesCraftItem.createBushelBabiesCraftedItem(itemKey,quantity);
            this.m_bushelbabiesCraftItemInventory[itemKey] = craftItem;
         }
      }
      
      public function decrementCraftedGood(craftedGood:CraftedItem, quantity:int) : void
      {
         var existingItem:StorageItem = null;
         if(this.m_craftedGoodInventory[craftedGood.itemKey])
         {
            existingItem = this.m_craftedGoodInventory[craftedGood.itemKey] as StorageItem;
            existingItem.adjustQuantity(-quantity);
            if(existingItem.quantity <= 0)
            {
               this.m_craftedGoodInventory[craftedGood.itemKey] = null;
            }
         }
      }
      
      public function decrementBushelBabiesCraftItem(itemKey:String, quantity:int) : void
      {
         var existingItem:BushelBabiesCraftItem = null;
         if(this.m_bushelbabiesCraftItemInventory[itemKey])
         {
            existingItem = this.m_bushelbabiesCraftItemInventory[itemKey];
            existingItem.adjustQuantity(-quantity);
            if(existingItem.quantity <= 0)
            {
               this.m_bushelbabiesCraftItemInventory[itemKey] = null;
            }
         }
      }
      
      public function get totalCraftedGoods() : int
      {
         var itemCode:String = null;
         var craftedGood:CraftedItem = null;
         var foundQuantity:int = 0;
         for(itemCode in this.m_craftedGoodInventory)
         {
            craftedGood = this.m_craftedGoodInventory[itemCode] as CraftedItem;
            if(craftedGood != null)
            {
               foundQuantity += craftedGood.quantity;
            }
         }
         return foundQuantity;
      }
      
      public function get totalCraftedGoodsIgnoringQuantity() : int
      {
         var itemCode:String = null;
         var craftedGood:CraftedItem = null;
         var count:int = 0;
         for(itemCode in this.m_craftedGoodInventory)
         {
            craftedGood = this.m_craftedGoodInventory[itemCode] as CraftedItem;
            if(craftedGood != null)
            {
               count++;
            }
         }
         return count;
      }
      
      public function totalCraftedGoodsByItemCode(code:String) : int
      {
         var itemCode:String = null;
         var craftedGood:CraftedItem = null;
         var foundQuantity:int = 0;
         for(itemCode in this.m_craftedGoodInventory)
         {
            if(code == itemCode)
            {
               craftedGood = this.m_craftedGoodInventory[itemCode] as CraftedItem;
               if(craftedGood != null)
               {
                  foundQuantity += craftedGood.quantity;
               }
            }
         }
         return foundQuantity;
      }
      
      public function totalBushelBabiesCraftItemByItemCode(itemKey:String) : int
      {
         var craftedGood:BushelBabiesCraftItem = null;
         var foundQuantity:int = 0;
         if(this.m_bushelbabiesCraftItemInventory[itemKey])
         {
            craftedGood = this.m_bushelbabiesCraftItemInventory[itemKey];
            foundQuantity += craftedGood.quantity;
         }
         return foundQuantity;
      }
      
      public function get allCraftedGoods() : Array
      {
         var itemCode:String = null;
         var craftedGood:CraftedItem = null;
         var result:Array = new Array();
         for(itemCode in this.m_craftedGoodInventory)
         {
            craftedGood = this.m_craftedGoodInventory[itemCode] as CraftedItem;
            if(craftedGood != null && craftedGood.quantity > 0)
            {
               result.push(craftedGood);
            }
         }
         result.sort(CraftedItem.sortItems);
         return result;
      }
      
      public function getCraftedGoodsByCraftType(craftType:String) : Array
      {
         var itemCode:String = null;
         var craftedGood:CraftedItem = null;
         var item:FarmItem = null;
         var result:Array = new Array();
         for(itemCode in this.m_craftedGoodInventory)
         {
            craftedGood = this.m_craftedGoodInventory[itemCode] as CraftedItem;
            if(craftedGood != null && craftedGood.quantity > 0)
            {
               item = Global.farmGameSettingsManager.getFarmItemByCode(craftedGood.itemCode);
               if(item != null && item.subType == craftType)
               {
                  result.push(craftedGood);
               }
            }
         }
         result.sort(CraftedItem.sortItems);
         return result;
      }
      
      public function initRecipeStates(recipeStates:Object) : void
      {
         var phpRecipeState:Object = null;
         this.craftingSkillState.resetRecipeStates();
         for each(phpRecipeState in recipeStates)
         {
            this.craftingSkillState.addRecipeState(RecipeState.fromPhpObject(phpRecipeState));
         }
      }
      
      public function get nextCraftingDate() : Number
      {
         return this.m_nextCraftingDate;
      }
      
      public function set nextCraftingDate(newCraftingDate:Number) : void
      {
         this.m_nextCraftingDate = newCraftingDate;
      }
      
      public function get craftingCalendarDate() : Number
      {
         return this.m_craftingCalendarDate;
      }
      
      public function set craftingCalendarDate(newCraftingCalendarDate:Number) : void
      {
         this.m_craftingCalendarDate = newCraftingCalendarDate;
      }
      
      public function get firstCraft() : String
      {
         return this.m_firstCraft;
      }
      
      public function set firstCraft(craftType:String) : void
      {
         this.m_firstCraft = craftType;
      }
      
      public function get isInitialized() : Boolean
      {
         return this.m_initialized;
      }
      
      public function checkCraftingRollOver() : void
      {
         var serverTime:Number = Math.floor(GlobalEngine.serverTime / 1000);
         if(serverTime > this.m_nextCraftingDate)
         {
            this.m_craftingCalendarDate = this.m_nextCraftingDate;
            if(SubscriptionsManager.isEligibleForVIPBenifit())
            {
               this.m_nextCraftingDate = this.m_craftingCalendarDate + SECS_IN_8_HOURS;
            }
            else
            {
               this.m_nextCraftingDate = this.m_craftingCalendarDate + SECS_IN_24_HOURS;
            }
            this.m_shoppingState.clearBags();
         }
      }
      
      public function getTimeToNextRollOver() : Number
      {
         this.checkCraftingRollOver();
         var serverTime:Number = Math.floor(GlobalEngine.serverTime / 1000);
         return Math.max(0,this.m_nextCraftingDate - serverTime);
      }
      
      public function updateCrewHelpers(crewQueue:Array) : void
      {
         var crewIdx:int = 0;
         var uid:String = null;
         var timestamp:int = 0;
         var recipeId:String = null;
         var ovenSlot:String = null;
         var worldType:String = null;
         this.m_craftingCrew = new Array();
         if(Boolean(crewQueue) && crewQueue.length > 0)
         {
            for(crewIdx = 0; crewIdx < crewQueue.length; crewIdx++)
            {
               uid = crewQueue[crewIdx]["uid"];
               timestamp = int(crewQueue[crewIdx]["timestamp"]);
               recipeId = crewQueue[crewIdx]["recipeId"];
               ovenSlot = crewQueue[crewIdx]["ovenSlot"];
               worldType = crewQueue[crewIdx]["worldType"];
               this.m_craftingCrew.push(new CraftingCrewMember(uid,timestamp,recipeId,ovenSlot,worldType));
            }
         }
         this.m_craftingCrew.sort(this.orderByTimeStamp);
      }
   }
}

