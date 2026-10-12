package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Constants.QuestConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.MarketInventoryItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Display.FarmVillageOrderBoardRewardDialog;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.DynamicObjectEvent;
   import Events.GenericPopupEvent;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Transactions.FarmVillage.TCompleteFarmvillageOrder;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.Crafting.VillageIngredientStorageWindow;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class FarmVillageManager extends EventDispatcher
   {
      
      private static var s_instance:FarmVillageManager;
      
      public static const FEATURE_NAME:String = "farmVillage";
      
      public static const ORDER_BOARD_FEATURE_OPTIONS_NAME:String = "farmVillageOrderBoard";
      
      public static const SERVICE_NAME:String = "FarmVillageService";
      
      public static const CURRENCY_NAME:String = "villageCoins";
      
      public static const WORLD_SCORE_NAME:String = "villagePoints";
      
      public static const FARM_VILLAGE_STAT:String = "farm_village";
      
      public static const ATTRIBUTES:String = "@attributes";
      
      public static const ITEM_NAME:String = "itemName";
      
      public static const QUANTITY:String = "quantity";
      
      public static const INGREDIENTS_KEY:String = "ingredients";
      
      public static const ORDERS:String = "orders";
      
      public static const RESERVE_ORDERS:String = "reserveOrders";
      
      public static const CURRENCY_REWARD:String = "currencyReward";
      
      public static const EXPERIENCE_REWARD:String = "xpReward";
      
      public static const REWARD:String = "reward";
      
      public static const SLOT:String = "slot";
      
      public static const SKIP_TIME:String = "skipTime";
      
      public static const SKIP_PRICE:int = 1;
      
      public static const ORDER_BOARD_REFRESH_EVENT:String = "orderBoardRefresh";
      
      public static const ORDER_FILLED:String = "orderFilled";
      
      public static const ORDER_SKIPPED:String = "orderSkipped";
      
      public static const ORDER_BOARD_SET_DATA_EVENT:String = "orderBoardSetData";
      
      private static const FONT_COLOR:uint = 16776960;
      
      private static const PLUS_ONE:String = "GenericPlusOne";
      
      public static const SKIP_TIME_ONE:int = 299;
      
      public static const SKIP_TIME_TWO:int = 899;
      
      public static const SKIP_TIME_THREE:int = 1799;
      
      public static const SKIP_VARIANT_TWO:int = 2;
      
      public static const SKIP_VARIANT_THREE:int = 3;
      
      public static const SKIP_VARIANT_FOUR:int = 4;
      
      private var m_skipVariant:int;
      
      private var m_orders:Array;
      
      private var m_reserveOrders:Array;
      
      public function FarmVillageManager(key:SingletonEnforcer)
      {
         super();
         GlobalEngine.assert(key != null,"[FarmVillageManager] :: Use GetInstance()");
      }
      
      public static function get instance() : FarmVillageManager
      {
         if(!s_instance)
         {
            s_instance = new FarmVillageManager(new SingletonEnforcer());
         }
         return s_instance;
      }
      
      public static function isInFarmVillage() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_VILLAGE) == 1;
      }
      
      public function initOrderBoardData() : void
      {
         var orders:Object = FeatureOptionsManager.getInstance().getFeatureOption(ORDER_BOARD_FEATURE_OPTIONS_NAME);
         if(orders)
         {
            this.setOrderData(orders);
         }
         else
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getData",this.setOrderData));
         }
         this.m_skipVariant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_VILLAGE_PASS);
      }
      
      public function setOrderData(orders:Object) : void
      {
         if(orders)
         {
            if(orders[ORDER_BOARD_FEATURE_OPTIONS_NAME])
            {
               this.m_orders = orders[ORDER_BOARD_FEATURE_OPTIONS_NAME][ORDERS];
               this.m_reserveOrders = orders[ORDER_BOARD_FEATURE_OPTIONS_NAME][RESERVE_ORDERS];
            }
            else
            {
               this.m_orders = orders[ORDERS];
               this.m_reserveOrders = orders[RESERVE_ORDERS];
            }
            Global.stage.dispatchEvent(new DynamicObjectEvent(ORDER_BOARD_SET_DATA_EVENT,this.m_orders));
         }
      }
      
      public function getOrderData() : Object
      {
         return this.m_orders;
      }
      
      public function addOrderToReserve(order:Object) : void
      {
         if(Boolean(this.m_reserveOrders) && Boolean(order))
         {
            this.m_reserveOrders.push(order);
         }
      }
      
      public function getInventoryCountForItem(itemName:String) : int
      {
         var inventoryItem:MarketInventoryItem = null;
         var underlyingItem:FarmItem = null;
         var inventory:Dictionary = Global.player.craftingState.inventoryState.villageStorageItems;
         var itemCount:int = 0;
         for each(inventoryItem in inventory)
         {
            underlyingItem = inventoryItem.underlyingItem;
            if(Boolean(underlyingItem) && underlyingItem.name == itemName)
            {
               itemCount = inventoryItem.quantity;
               break;
            }
         }
         return itemCount;
      }
      
      private function getSkipTime() : int
      {
         var result:int = 0;
         switch(this.m_skipVariant)
         {
            case SKIP_VARIANT_TWO:
               result = SKIP_TIME_ONE;
               break;
            case SKIP_VARIANT_THREE:
               result = SKIP_TIME_TWO;
               break;
            case SKIP_VARIANT_FOUR:
            default:
               result = SKIP_TIME_THREE;
         }
         return result;
      }
      
      public function showNewOrder(slot:int, wasSkipped:Boolean = false) : void
      {
         var newOrder:Object = null;
         var oldOrder:Object = null;
         if(Boolean(this.m_orders) && Boolean(this.m_reserveOrders))
         {
            newOrder = this.m_reserveOrders.shift();
            oldOrder = this.m_orders[slot];
            if(newOrder)
            {
               newOrder[SLOT] = slot;
               if(wasSkipped)
               {
                  newOrder[SKIP_TIME] = Math.floor(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND) + this.getSkipTime();
               }
               else
               {
                  newOrder[SKIP_TIME] = oldOrder[SKIP_TIME];
               }
               this.m_orders.splice(slot,1,newOrder);
            }
         }
      }
      
      public function onExpandStorage() : void
      {
         var buildings:Array = Global.world.getObjectsByName(VillageIngredientStorageWindow.BUILDING_NAME_CONST);
         var building:FeatureBuilding = null;
         if(buildings != null && buildings.length > 0)
         {
            building = buildings.pop();
         }
         if(Boolean(building) && building.hasReachedMaxExpansionLevel())
         {
            UI.displayMessage(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"InventoryStorageFull"),GenericPopup.TYPE_OK,this.onExpandStorageConfirmation,"InventoryExpandConfirmation",true,true);
         }
         else
         {
            UI.displayMessage(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"InventoryExpandConfirmation"),GenericPopup.TYPE_OK,this.onExpandStorageConfirmation,"InventoryExpandConfirmation",true,true);
         }
      }
      
      private function onExpandStorageConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            UI.displayPopup(new VillageIngredientStorageWindow());
         }
      }
      
      public function getItemsBuilding(itemName:String) : Object
      {
         var mapObject:Object = null;
         var recipe:RecipeItem = null;
         var result:Object = null;
         var ingredientToBuildingGameSettings:Array = Global.farmGameSettingsManager.getFarmVillageIngredientsMapping();
         var foundItem:Boolean = false;
         for each(mapObject in ingredientToBuildingGameSettings)
         {
            if(itemName == mapObject.name)
            {
               result = new Object();
               result.buildingName = mapObject.buildingName;
               result.inCraftshop = false;
               foundItem = true;
               break;
            }
         }
         if(!foundItem)
         {
            recipe = Global.craftConfigSettings.getRecipeById(itemName);
            if(recipe)
            {
               result = new Object();
               result.buildingName = recipe.recipeType;
               result.inCraftshop = true;
               foundItem = true;
            }
         }
         return result;
      }
      
      public function getFindItemInBuildingString(itemName:String) : String
      {
         var buildingItem:FarmItem = null;
         var dialogsKey:String = null;
         var result:String = "";
         var itemInBuildingObject:Object = this.getItemsBuilding(itemName);
         if(itemInBuildingObject)
         {
            buildingItem = Global.farmGameSettingsManager.getFarmItemByName(itemInBuildingObject.buildingName);
            if(buildingItem)
            {
               dialogsKey = "FarmVillage_Make_Building";
               if(!itemInBuildingObject.inCraftshop)
               {
                  dialogsKey = "FarmVillage_Harvest_Building";
               }
               result = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,dialogsKey,{"buildingName":buildingItem.friendlyTitle});
               if(Boolean(itemInBuildingObject.inCraftshop) && !this.isEligibleForFarmVillageRecipe(itemName))
               {
                  result = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"FarmVillage_Locked",{"level":this.getFarmVillageRecipeLevelRequirement(itemName)});
               }
            }
         }
         return result;
      }
      
      public function buyItem(itemName:String, quantity:int, slotIndex:int) : void
      {
         var item:FarmItem = null;
         var params:Array = null;
         var cashCost:int = 0;
         slotIndex = slotIndex;
         var storageCount:int = this.getInventoryCountForItem(itemName);
         var quantityToBuy:int = quantity - storageCount;
         if(quantityToBuy > 0)
         {
            if(itemName)
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
               params = new Array(slotIndex,itemName,quantityToBuy);
               if(Global.player.craftingState.inventoryState.villageStorageCurrentCapacity + quantityToBuy <= Global.player.craftingState.inventoryState.villageStorageMaxCapacity)
               {
                  cashCost = item.cash * quantityToBuy;
                  if(Global.player.canBuyCash(cashCost))
                  {
                     Global.player.addGift(itemName,"0",quantityToBuy);
                     Global.player.cash -= cashCost;
                     Global.player.avatar.displayStatus(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,PLUS_ONE,{"item":ZLocUtils.tk_pk_asTitle(item.friendlyName)}),item.icon,null,UI.DEFAULT_STATUS_TWEEN_DURATION,UI.DEFAULT_STATUS_TWEEN_DISPLACEMENT,UI.DEFAULT_STATUS_TWEEN_FONT_SIZE,FONT_COLOR);
                     TransactionManager.addTransaction(new TGenericTransaction(FarmVillageManager.SERVICE_NAME,"buyIngredients",null,params));
                  }
               }
               else
               {
                  FarmVillageManager.instance.onExpandStorage();
               }
            }
         }
         Global.stage.dispatchEvent(new Event(FarmVillageManager.ORDER_BOARD_REFRESH_EVENT));
      }
      
      public function timeUntilCanSkipAgain(slot:int) : int
      {
         var order:Object = null;
         var skipTime:uint = 0;
         var currentTimeSeconds:int = 0;
         var timeToWait:int = 0;
         var result:int = 0;
         if(Boolean(this.m_orders) && Boolean(this.m_orders[slot]))
         {
            order = this.m_orders[slot];
            if(order[SKIP_TIME])
            {
               skipTime = uint(order[SKIP_TIME]);
               currentTimeSeconds = Math.floor(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND);
               timeToWait = skipTime - currentTimeSeconds;
               if(timeToWait > 0)
               {
                  result = timeToWait / FarmGameUtil.NUM_SECS_IN_MINUTE;
               }
            }
         }
         return result;
      }
      
      public function skipOrder(slot:int, paid:Boolean) : void
      {
         var canSkip:Boolean = false;
         var params:Array = null;
         if(slot >= 0)
         {
            canSkip = false;
            if(paid)
            {
               if(Global.player.canBuyCash(SKIP_PRICE))
               {
                  Global.player.cash -= SKIP_PRICE;
                  canSkip = true;
               }
            }
            else
            {
               canSkip = true;
            }
            if(canSkip)
            {
               params = new Array();
               params.push(slot);
               params.push(paid);
               TransactionManager.addTransaction(new TGenericTransaction(FarmVillageManager.SERVICE_NAME,"skipOrder",this.onOrderReturn,params));
               FarmVillageManager.instance.showNewOrder(slot,true);
               Global.stage.dispatchEvent(new Event(FarmVillageManager.ORDER_SKIPPED));
            }
         }
      }
      
      private function onOrderReturn(result:Object) : void
      {
         if(Boolean(result) && Boolean(result["newOrder"]))
         {
            FarmVillageManager.instance.addOrderToReserve(result["newOrder"]);
         }
      }
      
      public function isEligibleForFarmVillageRecipe(recipeName:String) : Boolean
      {
         return Global.player.getWorldLevel(WORLD_SCORE_NAME) >= this.getFarmVillageRecipeLevelRequirement(recipeName);
      }
      
      private function getFarmVillageRecipeLevelRequirement(recipeName:String) : int
      {
         var prereqs:Array = null;
         var prereq:Object = null;
         var result:int = 0;
         var recipeItem:RecipeItem = CraftingManager.getRecipeItemFromId(recipeName,CraftingConstants.VILLAGE_RESOURCE_BUILDING_SKILL);
         if(recipeItem)
         {
            prereqs = recipeItem.prerequisites;
            for each(prereq in prereqs)
            {
               if(prereq.type == "world_level_min" && prereq.value == WORLD_SCORE_NAME)
               {
                  result = int(prereq.quantity);
                  break;
               }
            }
         }
         return result;
      }
      
      private function getRequirements(order:Object) : Array
      {
         var requirement:Object = null;
         var requirementData:Object = null;
         var result:Array = new Array();
         var requirements:Object = order["requirements"];
         for each(requirement in requirements)
         {
            requirementData = new Object();
            if(Boolean(requirement[ATTRIBUTES]) && Boolean(requirement[ATTRIBUTES][ITEM_NAME]) && Boolean(requirement[ATTRIBUTES][QUANTITY]))
            {
               requirementData.itemName = requirement[ATTRIBUTES][ITEM_NAME];
               requirementData.quantity = requirement[ATTRIBUTES][QUANTITY];
            }
            else if(Boolean(requirement[ITEM_NAME]) && Boolean(requirement[QUANTITY]))
            {
               requirementData.itemName = requirement[ITEM_NAME];
               requirementData.quantity = requirement[QUANTITY];
            }
            result.push(requirementData);
         }
         return result;
      }
      
      public function completeOrder(slot:int, completeNow:Boolean = false) : void
      {
         var quantityToBuy:int = 0;
         var order:Object = null;
         var itemName:String = null;
         var requiredQuantity:int = 0;
         var inventoryCount:int = 0;
         var item:FarmItem = null;
         var requirement:Object = null;
         var itemCode:String = null;
         var currencyReward:Object = null;
         var experienceReward:Object = null;
         var rewardItem:String = null;
         var cashCost:int = 0;
         var canFulfillOrder:Boolean = true;
         var sendTransaction:Boolean = false;
         if(this.m_orders)
         {
            order = this.m_orders[slot];
         }
         var requirements:Object = this.getRequirements(order);
         var itemsToDeduct:Dictionary = new Dictionary();
         for each(requirement in requirements)
         {
            itemName = requirement.itemName;
            requiredQuantity = int(requirement.quantity);
            inventoryCount = this.getInventoryCountForItem(itemName);
            item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(requiredQuantity > inventoryCount)
            {
               canFulfillOrder = false;
            }
            else
            {
               itemsToDeduct[item.code] = requiredQuantity;
            }
            if(completeNow)
            {
               quantityToBuy = requiredQuantity - inventoryCount;
               if(quantityToBuy > 0)
               {
                  cashCost += item.cash * quantityToBuy;
               }
            }
         }
         if(!completeNow)
         {
            if(canFulfillOrder)
            {
               for(itemCode in itemsToDeduct)
               {
                  CraftingManager.getInstance().deductItemFromCraftingInventory(itemCode,itemsToDeduct[itemCode]);
                  sendTransaction = true;
               }
            }
         }
         else if(Global.player.canBuyCash(cashCost))
         {
            Global.player.cash -= cashCost;
            sendTransaction = true;
         }
         if(sendTransaction && Boolean(order))
         {
            TransactionManager.addTransaction(new TCompleteFarmvillageOrder(slot,completeNow));
            currencyReward = new Object();
            currencyReward.type = QuestConstants.REWARD_WORLD_CURRENCY;
            currencyReward.unit = CURRENCY_NAME;
            if(order[CURRENCY_REWARD])
            {
               currencyReward.value = order[CURRENCY_REWARD];
            }
            experienceReward = new Object();
            experienceReward.type = QuestConstants.REWARD_WORLD_SCORE;
            experienceReward.unit = WORLD_SCORE_NAME;
            if(order[EXPERIENCE_REWARD])
            {
               experienceReward.value = order[EXPERIENCE_REWARD];
            }
            UserRewardUtil.grantUserReward(currencyReward);
            UserRewardUtil.grantUserReward(experienceReward);
            rewardItem = order[REWARD];
            if(rewardItem)
            {
               Global.player.addGift(rewardItem);
               UI.displayPopup(new FarmVillageOrderBoardRewardDialog(rewardItem,currencyReward.value,experienceReward.value));
            }
            this.showNewOrder(slot);
         }
         Global.stage.dispatchEvent(new Event(FarmVillageManager.ORDER_FILLED));
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
