package Classes.Quest
{
   import Classes.AnimalStorageBuilding;
   import Classes.Constants.QuestConstants;
   import Classes.EverGrowingHarvestableBuilding;
   import Classes.FeatureBuilding;
   import Classes.Growable.GrowableConstants;
   import Classes.HarvestableResource;
   import Classes.HarvestableStorageBuilding;
   import Classes.ItemInstance;
   import Classes.MapResource;
   import Classes.Mastery;
   import Classes.MutableAnimalBaby;
   import Classes.OrchardBuilding;
   import Classes.Plot;
   import Classes.Terrain.TerrainConfigManager;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.HarvestableItem;
   import Classes.breeding.AnimalBreedingSession;
   import Classes.breeding.MutableAnimalState;
   import Classes.crafting.RecipeItem;
   import DataSources.BaseDataSource;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmVillageFactoriesManager;
   import Managers.MystreeNurseryManager;
   import Managers.MystreeReskinManager;
   import Managers.OrderBoard.TropicalMarketInnovationManager;
   import Managers.PumpkinPartyInnovationManager;
   import Managers.SuperPlotManager;
   import Transactions.TEquipmentAction;
   import Transactions.TFarmTransaction;
   import Transactions.TInstantGrow;
   import Transactions.TPlace;
   import Transactions.TRedeemCreditsItem;
   import Transactions.TStoreItem;
   import Transactions.TTransformBuilding;
   import Transactions.TTransformTreasure;
   import Transactions.TWorldState;
   import ZQuest.Init.QuestSettingsInit;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   public class FarmQuestUtility
   {
      
      private static var m_allowInstantiation:Boolean;
      
      private static var m_instance:FarmQuestUtility = null;
      
      private static var m_itemMasteryCounters:Object = {};
      
      private static const MAX_CACHED_TRANSACTION_AGE:int = 10;
      
      private var m_typeMasteryProgressionPerTransaction:Object = {};
      
      public function FarmQuestUtility()
      {
         super();
         if(!m_allowInstantiation)
         {
            throw new Error("Error: Instantiation failed: Use FarmQuestUtility.getInstance() instead of new.");
         }
      }
      
      public static function getInstance() : FarmQuestUtility
      {
         if(m_instance == null)
         {
            m_allowInstantiation = true;
            m_instance = new FarmQuestUtility();
            m_allowInstantiation = false;
         }
         return m_instance;
      }
      
      private static function getActOnItemByCashProgression(type:String, transactionData:Object) : int
      {
         var taskProgression:int = 0;
         var item:FarmItem = transactionData.item;
         if(item)
         {
            if(type == "any")
            {
               if(transactionData.hasOwnProperty("params") && Boolean(transactionData.params.hasOwnProperty("currency")))
               {
                  taskProgression = transactionData.params.currency == "cash" ? 1 : taskProgression;
               }
            }
         }
         return taskProgression;
      }
      
      private static function getStoreItemByCashProgression(type:String, transactionData:Object) : int
      {
         var count:int = 0;
         var taskProgression:int = 0;
         var targetItemResult:int = getActOnItemByCashProgression(type,transactionData);
         if(transactionData.hasOwnProperty("storedItem") && transactionData.storedItem != null)
         {
            count = transactionData.storedItem.count > 0 ? int(transactionData.storedItem.count) : 1;
            taskProgression = targetItemResult * count;
         }
         return taskProgression;
      }
      
      public function getProgression(task:FarmTask, transaction:TFarmTransaction, quest:FarmQuest) : int
      {
         var transactionData:Object = null;
         var correctTargetItem:int = 0;
         var targetItemResult:int = 0;
         var taskAction:String = null;
         var storageEntityId:String = null;
         var vehicleMultiplier:int = 0;
         var vehicleCategoryMultiplier:int = 0;
         var result:int = 0;
         if(transaction != null && task.doesRequireServerResponse() == false)
         {
            transactionData = transaction.getTransactionData();
            correctTargetItem = 0;
            targetItemResult = 0;
            if(transactionData != null)
            {
               taskAction = task.action;
               if(this.isValidTransactionType(transactionData,taskAction))
               {
                  switch(taskAction)
                  {
                     case QuestConstants.TASK_BUY_ITEM_BY_CATEGORY:
                        result = this.getBuyItemByCategoryProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_BUY_ITEM_BY_CLASS:
                        result = this.getBuyItemByClassProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_BUY_ITEM_BY_CODE:
                        result = this.getBuyItemByCodeProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_BUY_ITEM_WITH_CASH:
                        result = this.getBuyItemByCashProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_HAVE_ITEM_IN_GIFTBOX_BY_CODE:
                        result = this.getHaveItemInGiftboxByCodeProgression(task,task.type,transactionData);
                        break;
                     case QuestConstants.TASK_VISIT_NEIGHBOR:
                        result = 1;
                        break;
                     case QuestConstants.TASK_VISIT_NPC:
                        result = this.getVisitNPCProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_HARVEST_BY_TYPE:
                        result = this.getHarvestByTypeProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_UNLOCK_TILE:
                        result = this.getTileUnlock(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_HARVEST_BY_SUBTYPE:
                        result = this.getHarvestBySubtypeProgression(task.type,task.subtype,transactionData);
                        break;
                     case QuestConstants.TASK_HARVEST_BY_CATEGORY:
                        result = this.getHarvestByCategoryProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_HARVEST_BY_CODE:
                        result = this.getHarvestByCodeProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_HARVEST_ANY:
                        result = this.getHarvestAnyProgression(transactionData);
                        break;
                     case QuestConstants.TASK_HARVEST_BY_STORAGE_BUILDING:
                        result = this.getHarvestByStorageBuildingProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_STORE_ITEM_BY_CODE:
                        result = this.getStoreItemByCodeProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_STORE_ITEM_BY_CATEGORY:
                        result = this.getStoreItemByCategoryProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_STORE_ITEM_BY_CLASS:
                        result = this.getStoreItemByClassProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_STORE_ITEM_BY_ANY_SPECIFIC_INVENTORY_STORAGE:
                        storageEntityId = this.extractTaskExtraData(task,"storageEntityId");
                        result = this.getStoreItemByAnyInSpecificInventoryStorage(transactionData,storageEntityId);
                        break;
                     case QuestConstants.TASK_STORE_ITEM_BY_CODE_SPECIFIC_BUILDING:
                        result = this.getStoreItemByCodeProgression(task.type,transactionData,task.extraData.buildingCode);
                        break;
                     case QuestConstants.TASK_STORE_ITEM_BY_CATEGORY_SPECIFIC_BUILDING:
                        result = this.getStoreItemByCategoryProgression(task.type,transactionData,task.extraData.buildingCode);
                        break;
                     case QuestConstants.TASK_STORE_ITEM_BY_CLASS_SPECIFIC_BUILDING:
                        targetItemResult = Math.min(this.getActOnItemByCodeProgression(task.extraData.buildingCode,transactionData),1);
                        result = this.getStoreItemByClassProgression(task.type,transactionData,task) * targetItemResult;
                        break;
                     case QuestConstants.TASK_STORE_ITEM_BY_CLASS_BUILDING_BY_CLASS:
                        targetItemResult = Math.min(this.getActOnItemByClassProgression(task.extraData.buildingClass,transactionData),1);
                        result = this.getStoreItemByClassProgression(task.type,transactionData,task) * targetItemResult;
                        break;
                     case QuestConstants.TASK_COUNT_STORED_ITEM_IN_SPECIFIC_BUILDING_BY_CODE:
                        result = this.getCountStoredItemBySpecificBuildingByCodeProgression(task.type,transactionData,task.extraData.targetItemCount);
                        break;
                     case QuestConstants.TASK_COMPLETE_CONSTRUCTION_BY_CODE:
                     case QuestConstants.TASK_COMPLETE_NONDETERMINISTIC_CONSTRUCTION_BY_CODE:
                        correctTargetItem = Math.min(this.getActOnItemByCodeProgression(task.type,transactionData),1);
                        result = correctTargetItem * this.getCompleteConstructionProgression(transactionData);
                        break;
                     case QuestConstants.TASK_UNLOCK_LAND_EXPANSION_BY_CATEGORY:
                     case QuestConstants.TASK_COMPLETE_CONSTRUCTION_BY_CATEGORY:
                        correctTargetItem = Math.min(this.getActOnItemByCategoryProgression(task.type,transactionData),1);
                        result = correctTargetItem * this.getCompleteConstructionProgression(transactionData);
                        break;
                     case QuestConstants.TASK_COMPLETE_CONSTRUCTION_BY_CLASS:
                        correctTargetItem = Math.min(this.getActOnItemByClassProgression(task.type,transactionData),1);
                        result = correctTargetItem * this.getCompleteConstructionProgression(transactionData);
                        break;
                     case QuestConstants.TASK_COMPLETE_CONSTRUCTION_OR_BUY_COMPLETE_ITEM_BY_CATEGORY:
                        if(transactionData.item != null)
                        {
                           result = this.getCompleteConstructionOrBuyCompleteItemByCategoryProgression(task.type,transactionData);
                        }
                        break;
                     case QuestConstants.TASK_CHANGE_TILE_SET:
                        result = this.getSimpleTransactionProgression(task.type,transactionData,"item");
                        break;
                     case QuestConstants.TASK_USE_INSTANT_GROW:
                        result = this.getUseInstantGrowProgression(transactionData);
                        break;
                     case QuestConstants.TASK_USE_ITEM_BY_CODE:
                        result = this.getActOnItemByCodeProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_DO_NEIGHBOR_ACTION:
                        result = this.getSimpleTransactionProgression(task.type,transactionData,"actionType");
                        break;
                     case QuestConstants.TASK_USE_REWARD_CREDIT_SPECIFIC_BUILDING_BY_CODE:
                        targetItemResult = Math.min(this.getActOnItemByCodeProgression(task.type,transactionData),1);
                        result = this.getStoreItemByClassProgression(task.extraData.featureCreditClass,transactionData,task) * targetItemResult;
                        break;
                     case QuestConstants.TASK_USE_REWARD_CREDIT_SPECIFIC_BUILDING_BY_CODE_WITHOUT_WORLD_UPDATE:
                        targetItemResult = Math.min(this.getActOnItemByCodeProgression(task.type,transactionData),1);
                        result = this.getStoreItemByClassProgression(task.extraData.featureCreditClass,transactionData,task) * targetItemResult;
                        break;
                     case QuestConstants.TASK_POST_NEIGHBOR_MESSAGE:
                        result = this.getPostNeighborMessageProgression(transactionData);
                        break;
                     case QuestConstants.TASK_GET_MASTERY_LEVEL_BY_CODE:
                        result = this.getAchieveMasteryLevelByCodeProgression(task.type,transactionData,task.extraData.level);
                        break;
                     case QuestConstants.TASK_GET_MASTERY_LEVEL_BY_CATEGORY:
                        result = this.getAchieveMasteryLevelByCategoryProgression(task.type,transactionData,task.extraData.level);
                        break;
                     case QuestConstants.TASK_MASTER_BY_TYPE:
                        result = this.getMasterByTypeProgression(task.type,transactionData,transaction.getId());
                        break;
                     case QuestConstants.TASK_PLANT_CROP_BY_CODE:
                        vehicleMultiplier = this.getVehicleMultiplier(transactionData);
                        result = this.getActOnItemByCodeProgression(task.type,transactionData) * vehicleMultiplier;
                        break;
                     case QuestConstants.TASK_PLANT_CROP_BY_CATEGORY:
                        vehicleCategoryMultiplier = this.getVehicleMultiplier(transactionData);
                        result = this.getActOnItemByCategoryProgression(task.type,transactionData) * vehicleCategoryMultiplier;
                        break;
                     case QuestConstants.TASK_EXPAND_FARM:
                        result = this.getExpandFarmProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_USE_VEHICLE:
                        result = this.getUseVehicleProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_MAKE_RECIPE_ANY:
                        result = this.getMakeRecipeAnyProgression(transactionData);
                        break;
                     case QuestConstants.TASK_MAKE_RECIPE_BY_CODE:
                        result = this.getSimpleTransactionProgression(task.type,transactionData,"recipeCode");
                        break;
                     case QuestConstants.TASK_GET_RECIPE_LEVEL_BY_CODE:
                        result = this.getAchieveRecipeLevelByCodeProgression(task.type,transactionData,task.extraData.level);
                        break;
                     case QuestConstants.TASK_GET_RECIPE_LEVEL_BY_CATEGORY:
                        result = this.getAchieveRecipeLevelByCategoryProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_GRANT_STORAGE_BUILINGS_REWARDS_BY_CATEGORY:
                        result = this.getStorageBuildingRewardsByCategoryProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_MAKE_RECIPE_BY_CATEGORY:
                        result = this.getMakeRecipeByCategoryProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_REACH_CRAFT_SKILL_LEVEL:
                        result = this.getReachCraftSkillLevelProgression(task.type,transactionData,task.extraData.level);
                        break;
                     case QuestConstants.TASK_USE_MOVE_TOOL_ANY:
                        result = 1;
                        break;
                     case QuestConstants.TASK_USE_MOVE_TOOL_BY_CLASS:
                        result = this.getActOnItemByClassProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_USE_MOVE_TOOL_BY_CODE:
                        result = this.getActOnItemByCodeProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_VIEW_SEEN_FLAG:
                        result = this.getSimpleTransactionProgression(task.type,transactionData,"flagName");
                        break;
                     case QuestConstants.TASK_GET_FRIEND_BUSHELS_ANY:
                        result = 1;
                        break;
                     case QuestConstants.TASK_GET_FRIEND_BUSHELS_BY_CODE:
                        result = this.getSimpleTransactionProgression(task.type,transactionData,"itemCode");
                        break;
                     case QuestConstants.TASK_PLOW_PLOT:
                        result = this.getPlowPlotProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_COMPLETE_FRIENDSET:
                        result = this.getCompleteFriendSetCompletion(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_SIMPLE_ACTION:
                        result = this.getSimpleTransactionProgression(task.type,transactionData,"taskAction");
                        break;
                     case QuestConstants.TASK_EXPAND_STORAGE_BUILDING_TO_LEVEL_BY_CODE:
                        result = this.getExpandStorageBuildingToLevelByCodeProgression(task.type,transactionData,task.extraData.level);
                        break;
                     case QuestConstants.TASK_PLAY_MATCH_MAKING_FEATURE:
                        result = 1;
                        break;
                     case QuestConstants.TASK_USE_ANIMAL_LOVE_POTION_BY_CODE:
                        result = this.getUseAnimalLovePotionByCodeProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_ADOPT_AWAY_ANIMAL_BY_CODE:
                        result = this.getAdoptAwayAnimalByCodeProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_RAISE_ANIMAL_WITH_PATTERN_BY_CODE:
                        result = this.getRaiseAnimalWithPatternByCodeProgression(task.type,transactionData,task.extraData.pattern);
                        break;
                     case QuestConstants.TASK_PLACE_ITEM_BY_CATEGORY:
                        result = this.getPlaceItemByCategoryProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_HARVEST_EVERGROWING_CROP:
                        result = this.getHarvestBeanstalkProgression(transactionData);
                        break;
                     case QuestConstants.TASK_PHOTO_CONTEST_SUBMIT:
                        result = this.getPhotoContestSubmitProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_PHOTO_CONTEST_CAST_VOTE:
                        result = this.getPhotoContestCastVoteProgression(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_USE_GROWABLE_CONSUMABLE_BY_CODE:
                        result = this.useGrowableConsumableByCode(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_HARVEST_FEATURE_CRAFTING_STATION_BY_CRAFTING_SYSTEM:
                        result = this.getHarvestFeatureCraftingStationByCraftingSystem(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_HARVEST_FEATURE_CRAFTING_STATION_BY_NAME:
                        result = this.getHarvestFeatureCraftingStationByName(task.type,transactionData,task.extraData.craftingSystem);
                        break;
                     case QuestConstants.TASK_HARVEST_FEATURE_CRAFTING_STATION_BY_RECIPE:
                        result = this.getHarvestFeatureCraftingStationByRecipe(task.type,transactionData,task.extraData.craftingSystem);
                        break;
                     case QuestConstants.TASK_FILL_FEATURE_CRAFTING_ORDER:
                        result = this.fillFeatureCraftingOrder(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_FILL_FARMVILLAGE_ORDER:
                        result = this.fillFarmVillageOrder(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_TEND_SAPLING_IN_MYSTREE:
                        result = this.tendSaplingInMystree(transactionData);
                        break;
                     case QuestConstants.TASK_REACH_WORLD_SCORE_LEVEL:
                        result = this.getWorldScoreLevelUpProgress(task.type,transactionData,task.extraData.level);
                        break;
                     case QuestConstants.TASK_COMPLETE_MYSTREE_COLLECTION:
                        result = this.getCompleteMystreeCollectionProgress(task.progress,transactionData);
                        break;
                     case QuestConstants.TASK_COMPLETE_FEATURE_CRAFTING_NPC:
                        result = this.completeFeatureCraftingNPC(task.extraData.craftingSystem,task.type,transactionData);
                        break;
                     case QuestConstants.TASK_COMPLETE_FEATURE_CRAFTING_LEVEL:
                        result = this.completeFeatureCraftingLevel(task.extraData.craftingSystem,task,transactionData);
                        break;
                     case QuestConstants.TASK_UNLOCK_COUNTDOWN_ITEM_BY_CODE:
                        result = this.countdownItemUnlockByCode(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_COLLECT_HARVEST_BUILDABLE_PART:
                        result = this.getHarvestBuildablePartProgress(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_COLLECT_SNOWFLAKES_BY_CATEGORY:
                        result = this.getCollectSnowflakesProgress(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_GROW_FAWN_BABY:
                        result = this.getGrownFawnBabyCount(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_GROW_MYSTERY_SEEDLING:
                        result = this.getMysterySeedlingGrowthCount(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_USE_SDB:
                        result = this.getSDBProgress(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_USE_FAWN_FEED:
                        result = this.getFawnFeedProgress(task.type,transactionData);
                        break;
                     case QuestConstants.TASK_COLLECT_ESCAPE_TOKENS:
                        result = this.getEscapeTokenProgress(task.type,transactionData);
                        break;
                     default:
                        result = 0;
                  }
               }
               else if(transactionData.hasOwnProperty("method") && transactionData.method == "skipTask" && Boolean(quest))
               {
                  if(Boolean(quest) && Boolean(transactionData.questName == quest.name) && transactionData.taskIndex == task.taskIndex)
                  {
                     result = task.total;
                  }
               }
            }
         }
         return result;
      }
      
      private function extractTaskExtraData(task:FarmTask, key:String) : String
      {
         var result:String = "";
         if(task != null)
         {
            if(key != null)
            {
               if(task.hasOwnProperty("extraData") && task.extraData != null)
               {
                  if(task.extraData.hasOwnProperty(key) && task.extraData[key] != null)
                  {
                     result = task.extraData[key];
                  }
               }
            }
         }
         return result;
      }
      
      private function isValidTransactionType(transactionData:Object, taskAction:String) : Boolean
      {
         var taskTransactions:Array = null;
         var transactionInfo:Object = null;
         var checkAction:Boolean = false;
         var isValidTransactionForTask:Boolean = false;
         if(transactionData != null)
         {
            taskTransactions = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getTaskTransactions(taskAction);
            for each(transactionInfo in taskTransactions)
            {
               if(!transactionData.hasOwnProperty("method"))
               {
                  break;
               }
               isValidTransactionForTask = transactionInfo.type == transactionData.method;
               checkAction = transactionInfo.hasOwnProperty("action") && transactionInfo.action.length > 0;
               if(checkAction == true)
               {
                  isValidTransactionForTask = isValidTransactionForTask && transactionData.hasOwnProperty("action") && transactionData.action == transactionInfo.action;
               }
               if(isValidTransactionForTask == true)
               {
                  break;
               }
            }
         }
         return isValidTransactionForTask;
      }
      
      private function getActOnItemByCategoryProgression(categoryName:String, transactionData:Object) : int
      {
         var resource:HarvestableResource = null;
         var preActionPlotItems:Dictionary = null;
         var plot:Object = null;
         var taskProgression:int = 0;
         var questSettingsInit:FarmQuestSettingsInit = QuestSettingsInit.getInstance() as FarmQuestSettingsInit;
         var item:FarmItem = transactionData.item as FarmItem;
         if(Boolean(item) && questSettingsInit.isItemCodeInCategory(item.code,categoryName))
         {
            resource = transactionData.resource as HarvestableResource;
            if(resource)
            {
               taskProgression += this.getResourceProgressionValue(resource);
            }
            else
            {
               taskProgression++;
            }
         }
         else if(transactionData.context == TInstantGrow.CONTEXT_INSTA_GROW)
         {
            if(Boolean(transactionData.preActionPlotItems) && Boolean(transactionData.preActionPlotItems.hasOwnProperty(Plot.STATE_GROWN)))
            {
               preActionPlotItems = transactionData.preActionPlotItems[Plot.STATE_GROWN] as Dictionary;
               if(preActionPlotItems)
               {
                  for(plot in preActionPlotItems)
                  {
                     item = preActionPlotItems[plot] as FarmItem;
                     if(Boolean(item) && questSettingsInit.isItemCodeInCategory(item.code,categoryName))
                     {
                        taskProgression += this.getResourceProgressionValue(plot as Plot);
                     }
                  }
               }
            }
         }
         return taskProgression;
      }
      
      private function getActOnItemByClassProgression(itemClass:String, transactionData:Object) : int
      {
         var itemClassName:String = null;
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("item"))
         {
            itemClassName = this.getQuestFriendlyClassName(transactionData.item);
            taskProgression = itemClassName == itemClass ? 1 : 0;
         }
         return taskProgression;
      }
      
      private function getQuestFriendlyClassName(item:FarmItem) : String
      {
         var itemClassName:String = getQualifiedClassName(item.getMapResourceClass());
         return itemClassName.slice(itemClassName.lastIndexOf("::") + 2);
      }
      
      private function getVisitNPCProgression(npcIdLookingFor:String, transactionData:Object) : int
      {
         var taskProgression:int = 0;
         if(npcIdLookingFor == null || npcIdLookingFor == "")
         {
            taskProgression = 1;
         }
         else if(transactionData.hasOwnProperty("npcId"))
         {
            if(npcIdLookingFor == transactionData.npcId)
            {
               taskProgression = 1;
            }
         }
         return taskProgression;
      }
      
      private function getActOnItemByCodeProgression(code:String, transactionData:Object) : int
      {
         var desiredItem:FarmItem = null;
         var finishedName:String = null;
         var finishedItem:FarmItem = null;
         var preActionPlotItems:Dictionary = null;
         var plot:Object = null;
         var taskProgression:int = 0;
         var item:FarmItem = transactionData.item as FarmItem;
         if(item)
         {
            if(item.code == code)
            {
               if(transactionData.resource is HarvestableResource)
               {
                  taskProgression += this.getResourceProgressionValue(transactionData.resource as HarvestableResource);
               }
               else
               {
                  taskProgression++;
               }
            }
            else
            {
               desiredItem = Global.farmGameSettingsManager.getFarmItemByCode(code);
               if(desiredItem != null)
               {
                  finishedName = desiredItem.getFinishedName();
                  if(finishedName.length > 0)
                  {
                     finishedItem = Global.farmGameSettingsManager.getFarmItemByName(finishedName);
                     if(finishedItem != null)
                     {
                        taskProgression = finishedItem.code == item.code ? 1 : 0;
                     }
                  }
               }
            }
         }
         else if(Boolean(transactionData.preActionPlotItems) && Boolean(transactionData.preActionPlotItems.hasOwnProperty(Plot.STATE_GROWN)))
         {
            preActionPlotItems = transactionData.preActionPlotItems[Plot.STATE_GROWN] as Dictionary;
            if(preActionPlotItems)
            {
               for(plot in preActionPlotItems)
               {
                  item = preActionPlotItems[plot] as FarmItem;
                  if(Boolean(item) && item.code == code)
                  {
                     taskProgression += this.getResourceProgressionValue(plot as Plot);
                  }
               }
            }
         }
         return taskProgression;
      }
      
      private function getBuyItemByCashProgression(type:String, transactionData:Object) : int
      {
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("action"))
         {
            switch(transactionData.action)
            {
               case TPlace.ACTION_PLACE:
                  if(this.isValidPlaceOriginForBuy(transactionData))
                  {
                     taskProgression = getActOnItemByCashProgression(type,transactionData);
                  }
                  break;
               case TStoreItem.ACTION_STORE:
                  if(this.isValidStoreOriginForBuy(transactionData))
                  {
                     taskProgression = getStoreItemByCashProgression(type,transactionData);
                  }
            }
         }
         return taskProgression;
      }
      
      private function getBuyItemByCodeProgression(code:String, transactionData:Object) : int
      {
         var taskProgression:int = 0;
         var validOrigin:int = 0;
         if(transactionData.hasOwnProperty("action"))
         {
            switch(transactionData.action)
            {
               case TPlace.ACTION_PLACE:
                  if(this.isValidPlaceOriginForBuy(transactionData) == true)
                  {
                     taskProgression = this.getActOnItemByCodeProgression(code,transactionData);
                  }
                  break;
               case TStoreItem.ACTION_STORE:
                  if(this.isValidStoreOriginForBuy(transactionData) == true)
                  {
                     taskProgression = this.getStoreItemByCodeProgression(code,transactionData);
                  }
            }
         }
         return taskProgression;
      }
      
      private function getHaveItemInGiftboxByCodeProgression(task:FarmTask, code:String, transactionData:Object) : int
      {
         var amtInGiftbox:Number = NaN;
         var storageType:Object = null;
         var totalNeeded:Number = NaN;
         var currentProgress:Number = NaN;
         var arrayOfItems:Object = null;
         var key:String = null;
         var taskProgression:int = 0;
         if(Boolean(transactionData) && Boolean(transactionData.storageData))
         {
            amtInGiftbox = 0;
            for(storageType in transactionData.storageData)
            {
               arrayOfItems = transactionData.storageData[storageType];
               for(key in arrayOfItems)
               {
                  if(key == code)
                  {
                     amtInGiftbox = Number(arrayOfItems[key][0]);
                     break;
                  }
               }
               if(amtInGiftbox > 0)
               {
                  break;
               }
            }
            totalNeeded = task.total;
            currentProgress = task.progress;
            if(amtInGiftbox >= totalNeeded)
            {
               taskProgression = totalNeeded - currentProgress;
            }
            else if(amtInGiftbox > currentProgress)
            {
               taskProgression = amtInGiftbox - currentProgress;
            }
         }
         return taskProgression;
      }
      
      private function getBuyItemByClassProgression(className:String, transactionData:Object) : int
      {
         var taskProgression:int = 0;
         var validOrigin:int = 0;
         if(transactionData.hasOwnProperty("action"))
         {
            switch(transactionData.action)
            {
               case TPlace.ACTION_PLACE:
                  if(this.isValidPlaceOriginForBuy(transactionData) == true)
                  {
                     taskProgression = this.getActOnItemByClassProgression(className,transactionData);
                  }
                  break;
               case TStoreItem.ACTION_STORE:
                  if(this.isValidStoreOriginForBuy(transactionData) == true)
                  {
                     taskProgression = this.getStoreItemByClassProgression(className,transactionData);
                  }
            }
         }
         return taskProgression;
      }
      
      private function getBuyItemByCategoryProgression(category:String, transactionData:Object) : int
      {
         var taskProgression:int = 0;
         var validOrigin:int = 0;
         if(transactionData.hasOwnProperty("action"))
         {
            switch(transactionData.action)
            {
               case TPlace.ACTION_PLACE:
                  if(this.isValidPlaceOriginForBuy(transactionData) == true)
                  {
                     taskProgression = this.getActOnItemByCategoryProgression(category,transactionData);
                  }
                  break;
               case TStoreItem.ACTION_STORE:
                  if(this.isValidStoreOriginForBuy(transactionData) == true)
                  {
                     taskProgression = this.getStoreItemByCategoryProgression(category,transactionData);
                  }
            }
         }
         return taskProgression;
      }
      
      private function getPlaceItemByCategoryProgression(category:String, transactionData:Object) : int
      {
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("action"))
         {
            switch(transactionData.action)
            {
               case TPlace.ACTION_PLACE:
                  taskProgression = this.getActOnItemByCategoryProgression(category,transactionData);
            }
         }
         return taskProgression;
      }
      
      private function getPhotoContestSubmitProgression(category:String, transactionData:Object) : int
      {
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("photoContest") && transactionData.photoContest == true)
         {
            taskProgression = 1;
         }
         return taskProgression;
      }
      
      private function getPhotoContestCastVoteProgression(category:String, transactionData:Object) : int
      {
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("count"))
         {
            taskProgression = int(transactionData.count);
         }
         return taskProgression;
      }
      
      private function useGrowableConsumableByCode(consumableCode:String, transactionData:Object) : int
      {
         var result:int = 0;
         if(transactionData[GrowableConstants.QUEST_FIELD_CONSUMABLE_CODE] == consumableCode)
         {
            result = int(transactionData[GrowableConstants.QUEST_FIELD_CONSUMABLE_COUNT]);
         }
         return result;
      }
      
      private function fillFarmVillageOrder(orderIndex:String, transactionData:Object) : int
      {
         var result:int = 0;
         if(orderIndex == "any" && transactionData.hasOwnProperty("ordersFilled"))
         {
            result = transactionData.ordersFilled as int;
         }
         return result;
      }
      
      private function tendSaplingInMystree(transactionData:Object) : int
      {
         var result:int = 0;
         if(transactionData.hasOwnProperty("tendSapling"))
         {
            result = transactionData.tendSapling as int;
         }
         return result;
      }
      
      private function getCompleteMystreeCollectionProgress(currentProgress:int, transactionData:Object) : int
      {
         var featureName:String = null;
         var uniqueCount:int = 0;
         var result:int = 0;
         if(transactionData.hasOwnProperty("featureName"))
         {
            featureName = transactionData.featureName;
            if(featureName == "mystree_v1")
            {
               uniqueCount = MystreeNurseryManager.getInstance().getUniqueMystreeCount();
            }
            else
            {
               uniqueCount = MystreeReskinManager.getInstance(featureName).getUniqueMystreeCount();
            }
            result = uniqueCount - currentProgress;
         }
         return result;
      }
      
      private function getHarvestBuildablePartProgress(type:String, transactionData:Object) : int
      {
         var recipeId:String = null;
         var recipe:RecipeItem = null;
         var result:int = 0;
         if(transactionData.hasOwnProperty("recipeCode"))
         {
            recipeId = transactionData.recipeCode;
            if(recipeId)
            {
               recipe = Global.craftConfigSettings.getRecipeById(recipeId);
               if(recipe)
               {
                  if(Boolean(recipe.rewardsModern) && Boolean(recipe.rewardsModern.item_grant) && recipe.rewardsModern.item_grant.@value == type)
                  {
                     result = int(recipe.rewardsModern.item_grant.@quantity);
                  }
               }
            }
         }
         return result;
      }
      
      private function getHarvestFeatureCraftingStationByCraftingSystem(craftingSystem:String, transactionData:Object) : int
      {
         var result:int = 0;
         if(transactionData.hasOwnProperty("craftingSystem") && transactionData.craftingSystem == craftingSystem && transactionData.hasOwnProperty("hasAutoStart") && !transactionData.hasAutoStart)
         {
            result = 1;
         }
         return result;
      }
      
      private function getHarvestFeatureCraftingStationByName(stationName:String, transactionData:Object, craftingSystem:String) : int
      {
         var result:int = 0;
         if(transactionData.hasOwnProperty("craftingSystem") && transactionData.craftingSystem == craftingSystem)
         {
            if(transactionData.hasOwnProperty("stationName") && transactionData.stationName == stationName)
            {
               result = 1;
            }
         }
         return result;
      }
      
      private function getHarvestFeatureCraftingStationByRecipe(recipeName:String, transactionData:Object, craftingSystem:String) : int
      {
         var result:int = 0;
         if(transactionData.hasOwnProperty("craftingSystem") && transactionData.craftingSystem == craftingSystem)
         {
            if(transactionData.hasOwnProperty("recipeName") && transactionData.recipeName == recipeName)
            {
               result = 1;
            }
         }
         return result;
      }
      
      private function fillFeatureCraftingOrder(craftingSystem:String, transactionData:Object) : int
      {
         var result:int = 0;
         if(transactionData.hasOwnProperty("craftingSystem") && transactionData.craftingSystem == craftingSystem && transactionData.hasOwnProperty("ordersFilled"))
         {
            result = transactionData.ordersFilled as int;
         }
         return result;
      }
      
      private function completeFeatureCraftingNPC(craftingSystem:String, npcName:String, transactionData:Object) : int
      {
         var result:int = 0;
         if(transactionData.hasOwnProperty("craftingSystem") && transactionData.craftingSystem == craftingSystem && transactionData.hasOwnProperty("npcName"))
         {
            result = npcName == transactionData.npcName ? 1 : 0;
         }
         return result;
      }
      
      private function completeFeatureCraftingLevel(craftingSystemName:String, task:FarmTask, transactionData:Object) : int
      {
         var result:int = 0;
         if(transactionData.hasOwnProperty("craftingSystem") && transactionData.craftingSystem == craftingSystemName && transactionData.hasOwnProperty("npcName"))
         {
            result = 1;
         }
         return result;
      }
      
      private function isValidPlaceOriginForBuy(transactionData:Object) : Boolean
      {
         var validOrigin:Boolean = false;
         if(transactionData.hasOwnProperty("isStorageWithdrawl"))
         {
            if(transactionData.isStorageWithdrawl == Global.world.NO_STORAGE || transactionData.isStorageWithdrawl == Global.world.GIFTBOX_ID)
            {
               validOrigin = true;
            }
         }
         return validOrigin;
      }
      
      private function isValidStoreOriginForBuy(transactionData:Object) : Boolean
      {
         var validOrigin:Boolean = false;
         if(transactionData.hasOwnProperty("cameFromLocation") && transactionData.hasOwnProperty("resource"))
         {
            if(transactionData.resource == QuestConstants.ITEM_ID_NONE)
            {
               if(transactionData.cameFromLocation == Global.world.NO_STORAGE || transactionData.cameFromLocation == Global.world.GIFTBOX_ID)
               {
                  validOrigin = true;
               }
            }
         }
         return validOrigin;
      }
      
      private function getCompleteConstructionOrBuyCompleteItemByCategoryProgression(categoryName:String, transactionData:Object) : int
      {
         var desiredItem:FarmItem = null;
         var taskProgression:int = 0;
         var correctTargetItem:int = 0;
         var finishedName:String = null;
         if(Boolean(transactionData) && Boolean(transactionData.hasOwnProperty("item")) && Boolean(transactionData.item.hasOwnProperty("code")))
         {
            desiredItem = Global.farmGameSettingsManager.getFarmItemByCode(transactionData.item.code);
            if(desiredItem)
            {
               finishedName = desiredItem.getFinishedName();
            }
         }
         if(Boolean(finishedName) && finishedName != "")
         {
            correctTargetItem = Math.min(this.getActOnItemByCategoryProgression(categoryName,transactionData),1);
            taskProgression = correctTargetItem * this.getCompleteConstructionProgression(transactionData);
         }
         if(taskProgression <= 0 && (finishedName == null || finishedName == ""))
         {
            taskProgression = this.getBuyItemByCategoryProgression(categoryName,transactionData);
         }
         return taskProgression;
      }
      
      private function getHarvestByTypeProgression(type:String, transactionData:Object) : int
      {
         var itemCode:String = null;
         var farmItem:FarmItem = null;
         var harvestables:Array = null;
         var harvestable:HarvestableResource = null;
         var harvestableFarmItem:FarmItem = null;
         var preActionPlotItems:Dictionary = null;
         var plot:Object = null;
         var item:FarmItem = null;
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("method"))
         {
            switch(transactionData.method)
            {
               case TWorldState.METHOD_PERFORM_ACTION:
                  if(transactionData.item is FarmItem && (transactionData.item as FarmItem).type == type)
                  {
                     if(transactionData.resource is HarvestableResource)
                     {
                        taskProgression += this.getResourceProgressionValue(transactionData.resource as HarvestableResource);
                     }
                     else
                     {
                        taskProgression++;
                     }
                  }
                  if(transactionData.hasOwnProperty("resource") && transactionData.resource is FeatureBuilding)
                  {
                     for(itemCode in transactionData.resource.contents)
                     {
                        farmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
                        if(farmItem.type == type)
                        {
                           taskProgression += transactionData.resource.contents[itemCode];
                        }
                     }
                  }
                  else if(transactionData.hasOwnProperty("harvestables") && transactionData.hasOwnProperty("action") && transactionData.action == TWorldState.ACTION_USE)
                  {
                     harvestables = transactionData.harvestables;
                     for each(harvestable in harvestables)
                     {
                        harvestableFarmItem = Global.farmGameSettingsManager.getFarmItemByName(harvestable.getItemName());
                        if(harvestableFarmItem.type == type)
                        {
                           taskProgression += this.getResourceProgressionValue(harvestable);
                        }
                     }
                  }
                  break;
               case TEquipmentAction.METHOD_USE_EQUIPMENT:
                  if(Boolean(transactionData.preActionPlotItems) && Boolean(transactionData.preActionPlotItems.hasOwnProperty(Plot.STATE_GROWN)))
                  {
                     preActionPlotItems = transactionData.preActionPlotItems[Plot.STATE_GROWN] as Dictionary;
                     if(preActionPlotItems)
                     {
                        for(plot in preActionPlotItems)
                        {
                           item = preActionPlotItems[plot] as FarmItem;
                           if(Boolean(item) && item.type == type)
                           {
                              taskProgression += this.getResourceProgressionValue(plot as Plot);
                           }
                        }
                     }
                  }
            }
         }
         return taskProgression;
      }
      
      private function getHarvestBySubtypeProgression(type:String, subtype:String, transactionData:Object) : int
      {
         var itemCode:String = null;
         var farmItem:FarmItem = null;
         var harvestables:Array = null;
         var harvestable:HarvestableResource = null;
         var harvestableFarmItem:FarmItem = null;
         var preActionPlotItems:Dictionary = null;
         var plot:Object = null;
         var item:FarmItem = null;
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("method"))
         {
            switch(transactionData.method)
            {
               case TWorldState.METHOD_PERFORM_ACTION:
                  if(transactionData.item is FarmItem && (transactionData.item as FarmItem).type == type && (transactionData.item as FarmItem).subType == subtype)
                  {
                     if(transactionData.resource is HarvestableResource)
                     {
                        taskProgression += this.getResourceProgressionValue(transactionData.resource as HarvestableResource);
                     }
                     else
                     {
                        taskProgression++;
                     }
                  }
                  if(transactionData.hasOwnProperty("resource") && transactionData.resource is FeatureBuilding)
                  {
                     for(itemCode in transactionData.resource.contents)
                     {
                        farmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
                        if(farmItem.subType == subtype)
                        {
                           taskProgression += transactionData.resource.contents[itemCode];
                        }
                     }
                  }
                  else if(transactionData.hasOwnProperty("harvestables") && transactionData.hasOwnProperty("action") && transactionData.action == TWorldState.ACTION_USE)
                  {
                     harvestables = transactionData.harvestables;
                     for each(harvestable in harvestables)
                     {
                        harvestableFarmItem = Global.farmGameSettingsManager.getFarmItemByName(harvestable.getItemName());
                        if(harvestableFarmItem.subType == subtype)
                        {
                           taskProgression += this.getResourceProgressionValue(harvestable as Plot);
                        }
                     }
                  }
                  break;
               case TEquipmentAction.METHOD_USE_EQUIPMENT:
                  if(Boolean(transactionData.preActionPlotItems) && Boolean(transactionData.preActionPlotItems.hasOwnProperty(Plot.STATE_GROWN)))
                  {
                     preActionPlotItems = transactionData.preActionPlotItems[Plot.STATE_GROWN] as Dictionary;
                     if(preActionPlotItems)
                     {
                        for(plot in preActionPlotItems)
                        {
                           item = preActionPlotItems[plot] as FarmItem;
                           if(Boolean(item) && item.subType == subtype)
                           {
                              taskProgression += this.getResourceProgressionValue(plot as Plot);
                           }
                        }
                     }
                  }
            }
         }
         return taskProgression;
      }
      
      private function getHarvestByCategoryProgression(category:String, transactionData:Object) : int
      {
         var questSettingsInit:FarmQuestSettingsInit = null;
         var itemCode:String = null;
         var harvestables:Array = null;
         var harvestable:HarvestableResource = null;
         var harvestableItemCode:String = null;
         var preActionPlotItems:Dictionary = null;
         var plot:Object = null;
         var item:FarmItem = null;
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("method"))
         {
            questSettingsInit = QuestSettingsInit.getInstance() as FarmQuestSettingsInit;
            switch(transactionData.method)
            {
               case TWorldState.METHOD_PERFORM_ACTION:
                  taskProgression = this.getActOnItemByCategoryProgression(category,transactionData);
                  if(transactionData.hasOwnProperty("resource") && transactionData.resource is HarvestableStorageBuilding)
                  {
                     for(itemCode in transactionData.resource.contents)
                     {
                        if(questSettingsInit.isItemCodeInCategory(itemCode,category))
                        {
                           taskProgression += transactionData.resource.contents[itemCode];
                        }
                     }
                  }
                  else if(transactionData.hasOwnProperty("harvestables") && transactionData.hasOwnProperty("action") && transactionData.action == TWorldState.ACTION_USE)
                  {
                     harvestables = transactionData.harvestables;
                     for each(harvestable in harvestables)
                     {
                        harvestableItemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(harvestable.getItemName());
                        if(questSettingsInit.isItemCodeInCategory(harvestableItemCode,category))
                        {
                           taskProgression += this.getResourceProgressionValue(harvestable);
                        }
                     }
                  }
                  break;
               case TEquipmentAction.METHOD_USE_EQUIPMENT:
                  if(Boolean(transactionData.preActionPlotItems) && Boolean(transactionData.preActionPlotItems.hasOwnProperty(Plot.STATE_GROWN)))
                  {
                     preActionPlotItems = transactionData.preActionPlotItems[Plot.STATE_GROWN] as Dictionary;
                     if(preActionPlotItems)
                     {
                        for(plot in preActionPlotItems)
                        {
                           item = preActionPlotItems[plot] as FarmItem;
                           if(Boolean(item) && questSettingsInit.isItemCodeInCategory(item.code,category))
                           {
                              taskProgression += this.getResourceProgressionValue(plot as Plot);
                           }
                        }
                     }
                  }
                  break;
               case FarmVillageFactoriesManager.FACTORY_HARVEST_FUNCTION:
                  if(transactionData.hasOwnProperty("itemCode") && (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).isItemCodeInCategory(transactionData.itemCode,category) == true)
                  {
                     taskProgression++;
                  }
            }
         }
         return taskProgression;
      }
      
      private function getHarvestAnyProgression(transactionData:Object) : int
      {
         var itemCode:String = null;
         var harvestables:Array = null;
         var harvestable:HarvestableResource = null;
         var preActionPlotItems:Dictionary = null;
         var plot:Object = null;
         var taskProgression:int = 0;
         var itemToUse:FarmItem = transactionData.item;
         if(transactionData.hasOwnProperty("method"))
         {
            switch(transactionData.method)
            {
               case TWorldState.METHOD_PERFORM_ACTION:
                  if(transactionData.hasOwnProperty("resource") && transactionData.resource is HarvestableStorageBuilding)
                  {
                     for(itemCode in transactionData.resource.contents)
                     {
                        taskProgression += transactionData.resource.contents[itemCode];
                     }
                  }
                  else if(transactionData.hasOwnProperty("harvestables") && transactionData.hasOwnProperty("action") && transactionData.action == TWorldState.ACTION_USE)
                  {
                     harvestables = transactionData.harvestables;
                     for each(harvestable in harvestables)
                     {
                        taskProgression += this.getResourceProgressionValue(harvestable);
                     }
                  }
                  else if(itemToUse is HarvestableItem)
                  {
                     if(transactionData.resource is HarvestableResource)
                     {
                        taskProgression += this.getResourceProgressionValue(transactionData.resource as HarvestableResource);
                     }
                     else
                     {
                        taskProgression++;
                     }
                  }
                  break;
               case TEquipmentAction.METHOD_USE_EQUIPMENT:
                  if(Boolean(transactionData.preActionPlotItems) && Boolean(transactionData.preActionPlotItems.hasOwnProperty(Plot.STATE_GROWN)))
                  {
                     preActionPlotItems = transactionData.preActionPlotItems[Plot.STATE_GROWN] as Dictionary;
                     if(preActionPlotItems)
                     {
                        for(plot in preActionPlotItems)
                        {
                           taskProgression += this.getResourceProgressionValue(plot as Plot);
                        }
                     }
                  }
            }
         }
         return taskProgression;
      }
      
      private function getHarvestByStorageBuildingProgression(StorageBuildingType:String, transactionData:Object) : int
      {
         var item:MapResource = null;
         var itemCode:String = null;
         var itemName:String = null;
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("resource") && transactionData.resource is HarvestableStorageBuilding)
         {
            for(itemCode in transactionData.resource.contents)
            {
               itemName = Global.farmGameSettingsManager.getFarmItemNameByCode(itemCode);
               item = new MapResource(itemName,false);
               if(Global.storageSettings.storageCanTake(StorageBuildingType,item))
               {
                  taskProgression += transactionData.resource.contents[itemCode];
               }
            }
         }
         else if(transactionData.item is HarvestableItem && Boolean(transactionData.item.name))
         {
            item = new MapResource(transactionData.item.name,false);
            if(Global.storageSettings.storageCanTake(StorageBuildingType,item))
            {
               taskProgression++;
            }
         }
         return taskProgression;
      }
      
      private function getHarvestByCodeProgression(code:String, transactionData:Object) : int
      {
         var itemCode:String = null;
         var harvestables:Array = null;
         var harvestable:HarvestableResource = null;
         var harvestableItemCode:String = null;
         var preActionPlotItems:Dictionary = null;
         var plot:Object = null;
         var item:FarmItem = null;
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("method"))
         {
            switch(transactionData.method)
            {
               case TWorldState.METHOD_PERFORM_ACTION:
                  taskProgression = this.getActOnItemByCodeProgression(code,transactionData);
                  if(transactionData.hasOwnProperty("resource") && (transactionData.resource is AnimalStorageBuilding || transactionData.resource is OrchardBuilding))
                  {
                     for(itemCode in transactionData.resource.contents)
                     {
                        if(itemCode == code)
                        {
                           taskProgression += transactionData.resource.contents[itemCode];
                        }
                     }
                  }
                  else if(transactionData.hasOwnProperty("harvestables") && transactionData.hasOwnProperty("action") && transactionData.action == TWorldState.ACTION_USE)
                  {
                     harvestables = transactionData.harvestables;
                     for each(harvestable in harvestables)
                     {
                        harvestableItemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(harvestable.getItemName());
                        if(harvestableItemCode == code)
                        {
                           taskProgression += this.getResourceProgressionValue(harvestable);
                        }
                     }
                  }
                  break;
               case TEquipmentAction.METHOD_USE_EQUIPMENT:
                  if(Boolean(transactionData.preActionPlotItems) && Boolean(transactionData.preActionPlotItems.hasOwnProperty(Plot.STATE_GROWN)))
                  {
                     preActionPlotItems = transactionData.preActionPlotItems[Plot.STATE_GROWN] as Dictionary;
                     if(preActionPlotItems)
                     {
                        for(plot in preActionPlotItems)
                        {
                           item = preActionPlotItems[plot] as FarmItem;
                           if(Boolean(item) && item.code == code)
                           {
                              taskProgression += this.getResourceProgressionValue(plot as Plot);
                           }
                        }
                     }
                  }
            }
         }
         return taskProgression;
      }
      
      private function getCountStoredItemBySpecificBuildingByCodeProgression(code:String, transactionData:Object, targetItemCount:int) : int
      {
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("item") && transactionData.item.code == code)
         {
            if(transactionData.hasOwnProperty("building") && transactionData.building != null)
            {
               if(Boolean(transactionData.building.hasOwnProperty("count")) && transactionData.building.count != null)
               {
                  if(transactionData.building.count >= targetItemCount)
                  {
                     taskProgression = 1;
                  }
               }
            }
         }
         return taskProgression;
      }
      
      private function getTileUnlock(code:String, transactionData:Object) : int
      {
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("item") && transactionData.item.code == code)
         {
            taskProgression = 1;
         }
         return taskProgression;
      }
      
      private function getStoreItemByCodeProgression(code:String, transactionData:Object, targetItemCode:String = "") : int
      {
         var count:int = 0;
         var taskProgression:int = 0;
         var targetItemResult:int = 1;
         if(targetItemCode.length > 0)
         {
            targetItemResult = Math.min(this.getActOnItemByCodeProgression(targetItemCode,transactionData),1);
         }
         if(transactionData.hasOwnProperty("storedItem") && transactionData.storedItem != null)
         {
            if(transactionData.storedItem.code == code)
            {
               count = transactionData.storedItem.count > 0 ? int(transactionData.storedItem.count) : 1;
               taskProgression = targetItemResult * count;
            }
         }
         return taskProgression;
      }
      
      private function getStoreItemByAnyInSpecificInventoryStorage(transactionData:Object, inventoryStorageIndex:String) : int
      {
         var count:int = 0;
         var taskProgression:int = 0;
         var targetItemResult:int = 0;
         if(Boolean(transactionData) && transactionData.hasOwnProperty("storageEntityId"))
         {
            if(transactionData.storageEntityId == inventoryStorageIndex)
            {
               targetItemResult = 1;
            }
         }
         if(transactionData.hasOwnProperty("storedItem") && transactionData.storedItem != null)
         {
            count = transactionData.storedItem.count > 0 ? int(transactionData.storedItem.count) : 1;
            taskProgression = targetItemResult * count;
         }
         return taskProgression;
      }
      
      private function getStoreItemByCategoryProgression(category:String, transactionData:Object, targetItemCode:String = "") : int
      {
         var count:int = 0;
         var taskProgression:int = 0;
         var targetItemResult:int = 1;
         if(targetItemCode.length > 0)
         {
            targetItemResult = Math.min(this.getActOnItemByCodeProgression(targetItemCode,transactionData),1);
         }
         if(transactionData.hasOwnProperty("storedItem") && transactionData.storedItem != null)
         {
            if((QuestSettingsInit.getInstance() as FarmQuestSettingsInit).isItemCodeInCategory(transactionData.storedItem.code,category))
            {
               count = transactionData.storedItem.count > 0 ? int(transactionData.storedItem.count) : 1;
               taskProgression = targetItemResult * count;
            }
         }
         return taskProgression;
      }
      
      private function getStoreItemByClassProgression(itemClass:String, transactionData:Object, task:FarmTask = null) : int
      {
         var count:int = 0;
         var storedItemClassName:String = null;
         var taskProgression:int = 0;
         switch(transactionData.action)
         {
            case TStoreItem.ACTION_STORE:
               if(transactionData.hasOwnProperty("storedItem") && transactionData.storedItem != null)
               {
                  count = transactionData.storedItem.count > 0 ? int(transactionData.storedItem.count) : 1;
                  storedItemClassName = this.getQuestFriendlyClassName(transactionData.storedItem);
                  taskProgression = count * (storedItemClassName == itemClass ? 1 : 0);
               }
               break;
            case TTransformBuilding.ACTION_TRANSFORM_BUILDING:
               if(task != null)
               {
                  taskProgression = task.total;
               }
               break;
            case TRedeemCreditsItem.SERVER_ACTION:
               if(transactionData.hasOwnProperty("amountRedeemedWithCash") && transactionData.amountRedeemedWithCash != null && transactionData.amountRedeemedWithCash > 0)
               {
                  taskProgression = int(transactionData.amountRedeemedWithCash);
               }
         }
         return taskProgression;
      }
      
      private function getCompleteConstructionProgression(transactionData:Object) : int
      {
         var taskProgression:int = 0;
         switch(transactionData.action)
         {
            case TTransformTreasure.ACTION_TRANSFORM_BUILDING_CASHLESS:
            case TTransformBuilding.ACTION_TRANSFORM_BUILDING:
               taskProgression = 1;
               break;
            case TStoreItem.ACTION_STORE:
               if(transactionData.hasOwnProperty("isFull"))
               {
                  taskProgression = transactionData.isFull ? 1 : 0;
               }
         }
         return taskProgression;
      }
      
      private function getPostNeighborMessageProgression(transactionData:Object) : int
      {
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("authorId") && transactionData.hasOwnProperty("hostId"))
         {
            taskProgression = transactionData.authorId != transactionData.hostId ? 1 : 0;
         }
         return taskProgression;
      }
      
      private function extractItemsFromHarvestTransaction(transactionData:Object, itemComparer:Function, itemHandler:Function) : void
      {
         var item:FarmItem = null;
         var buildingContents:Dictionary = null;
         var itemCode:String = null;
         var itemNum:int = 0;
         var containedItem:FarmItem = null;
         var harvestables:Array = null;
         var numHarvestables:int = 0;
         var hIndex:int = 0;
         var itemInstance:ItemInstance = null;
         var plotItem:FarmItem = null;
         if(transactionData.hasOwnProperty("method"))
         {
            switch(transactionData.method)
            {
               case TWorldState.METHOD_PERFORM_ACTION:
                  if(transactionData.hasOwnProperty("item"))
                  {
                     item = transactionData.item;
                     if(itemComparer(item))
                     {
                        itemHandler(item);
                     }
                     else if(transactionData.hasOwnProperty("resource") && transactionData.resource is HarvestableStorageBuilding)
                     {
                        buildingContents = (transactionData.resource as HarvestableStorageBuilding).contents;
                        for(itemCode in buildingContents)
                        {
                           itemNum = int(buildingContents[itemCode]);
                           if(itemNum > 0)
                           {
                              containedItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
                              if(containedItem != null && Boolean(itemComparer(containedItem)))
                              {
                                 while(itemNum > 0)
                                 {
                                    itemHandler(containedItem);
                                    itemNum--;
                                 }
                              }
                           }
                        }
                     }
                     else if(transactionData.hasOwnProperty("harvestables"))
                     {
                        harvestables = transactionData["harvestables"];
                        if(harvestables)
                        {
                           numHarvestables = int(harvestables.length);
                           for(hIndex = 0; hIndex < numHarvestables; hIndex++)
                           {
                              itemInstance = harvestables[hIndex];
                              if(itemInstance)
                              {
                                 item = itemInstance.getItem();
                                 if(itemComparer(item))
                                 {
                                    itemHandler(item);
                                 }
                              }
                           }
                        }
                     }
                  }
                  break;
               case TEquipmentAction.METHOD_USE_EQUIPMENT:
                  if(transactionData.hasOwnProperty("preActionPlotItems"))
                  {
                     if(transactionData.preActionPlotItems.hasOwnProperty(Plot.STATE_GROWN))
                     {
                        for each(plotItem in transactionData.preActionPlotItems[Plot.STATE_GROWN])
                        {
                           if(itemComparer(plotItem))
                           {
                              itemHandler(plotItem);
                           }
                        }
                     }
                  }
            }
         }
      }
      
      private function getUseInstantGrowProgression(transactionData:Object) : int
      {
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("growCount") && transactionData.growCount != null)
         {
            taskProgression = int(transactionData.growCount);
         }
         return taskProgression;
      }
      
      private function calculateIfMasteryLeveltIsReached(items:Array, requiredLevel:int) : Boolean
      {
         var requiredMasteryCount:int = 0;
         var totalMasteryCount:int = 0;
         var applicableItem:FarmItem = null;
         var delta:int = 0;
         var result:Boolean = false;
         requiredLevel--;
         var code:String = items[0].code;
         var masteryCounters:Object = Global.player.masteryCounters;
         var currentMasteryCount:int = 0;
         if(masteryCounters.hasOwnProperty(code))
         {
            currentMasteryCount = int(masteryCounters[code]);
         }
         var masteryObj:Mastery = Global.farmGameSettingsManager.getMasteryByCode(code);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            requiredMasteryCount = int(masteryObj.levelsData[requiredLevel].getInt("count"));
         }
         else
         {
            requiredMasteryCount = int(masteryObj.levels[requiredLevel].@count);
         }
         if(currentMasteryCount < requiredMasteryCount)
         {
            totalMasteryCount = currentMasteryCount;
            for each(applicableItem in items)
            {
               delta = Mastery.createMasteryForItem(applicableItem).calculateMasteryYield();
               totalMasteryCount += delta;
               if(totalMasteryCount >= requiredMasteryCount)
               {
                  result = true;
                  break;
               }
            }
         }
         return result;
      }
      
      private function getAchieveMasteryLevelByCodeProgression(code:String, transactionData:Object, requiredLevel:int) : int
      {
         var applicableItems:Array = null;
         var compareByCode:Function = null;
         var addToItems:Function = null;
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("method"))
         {
            applicableItems = new Array();
            compareByCode = function(item:FarmItem):Boolean
            {
               return item.code == code;
            };
            addToItems = function(item:FarmItem):void
            {
               applicableItems.push(item);
            };
            this.extractItemsFromHarvestTransaction(transactionData,compareByCode,addToItems);
            if(applicableItems.length > 0)
            {
               if(this.calculateIfMasteryLeveltIsReached(applicableItems,requiredLevel))
               {
                  taskProgression = 1;
               }
            }
         }
         return taskProgression;
      }
      
      private function getAchieveMasteryLevelByCategoryProgression(categoryName:String, transactionData:Object, requiredLevel:int) : int
      {
         var applicableItems:Object = null;
         var compareByCategory:Function = null;
         var addToItems:Function = null;
         var applicableItemCode:String = null;
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("method"))
         {
            applicableItems = {};
            compareByCategory = function(item:FarmItem):Boolean
            {
               return (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).isItemCodeInCategory(item.code,categoryName);
            };
            addToItems = function(item:FarmItem):void
            {
               if(applicableItems[item.code] == null)
               {
                  applicableItems[item.code] = [];
               }
               applicableItems[item.code].push(item);
            };
            this.extractItemsFromHarvestTransaction(transactionData,compareByCategory,addToItems);
            for(applicableItemCode in applicableItems)
            {
               if(this.calculateIfMasteryLeveltIsReached(applicableItems[applicableItemCode],requiredLevel))
               {
                  taskProgression++;
               }
            }
         }
         return taskProgression;
      }
      
      private function getMasterByTypeProgression(itemType:String, transactionData:Object, transactionId:Number) : int
      {
         var progressionCacheIndex:String = null;
         var applicableItems:Dictionary = null;
         var compareByType:Function = null;
         var addToItems:Function = null;
         var key:Object = null;
         var applicableItem:FarmItem = null;
         var itemCode:String = null;
         var currentCount:int = 0;
         var itemCount:int = 0;
         var mastery:Mastery = null;
         var updatedCount:int = 0;
         var threshold:int = 0;
         var masteryCounters:Object = null;
         var levelDataArray:Array = null;
         var levelData:BaseDataSource = null;
         var levels:XMLList = null;
         var level:XML = null;
         var purgeCutoff:int = 0;
         var oldCacheIndex:String = null;
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("method"))
         {
            progressionCacheIndex = null;
            if(transactionId > 0)
            {
               progressionCacheIndex = itemType + "_" + transactionId;
            }
            if(progressionCacheIndex != null && this.m_typeMasteryProgressionPerTransaction.hasOwnProperty(progressionCacheIndex))
            {
               taskProgression = int(this.m_typeMasteryProgressionPerTransaction[progressionCacheIndex].value);
            }
            else
            {
               applicableItems = new Dictionary();
               compareByType = function(item:FarmItem):Boolean
               {
                  return item.type == itemType;
               };
               addToItems = function(item:FarmItem):void
               {
                  if(applicableItems[item] == null)
                  {
                     applicableItems[item] = 1;
                  }
                  else
                  {
                     ++applicableItems[item];
                  }
               };
               this.extractItemsFromHarvestTransaction(transactionData,compareByType,addToItems);
               for(key in applicableItems)
               {
                  applicableItem = key as FarmItem;
                  itemCode = applicableItem.code;
                  if(!m_itemMasteryCounters.hasOwnProperty(itemCode))
                  {
                     masteryCounters = Global.player.masteryCounters;
                     if(Boolean(masteryCounters) && Boolean(masteryCounters[itemCode]))
                     {
                        m_itemMasteryCounters[itemCode] = masteryCounters[itemCode] as int;
                     }
                     else
                     {
                        m_itemMasteryCounters[itemCode] = 0;
                     }
                  }
                  currentCount = m_itemMasteryCounters[itemCode] as int;
                  itemCount = applicableItems[applicableItem] as int;
                  mastery = Mastery.createMasteryForItem(applicableItem);
                  updatedCount = currentCount + itemCount * mastery.calculateMasteryYield();
                  if(FarmGameSettingsManager.isInDataSourceExperiment())
                  {
                     levelDataArray = mastery.levelsData;
                     for each(levelData in levelDataArray)
                     {
                        threshold = levelData.getInt("count");
                        if(currentCount < threshold && updatedCount >= threshold)
                        {
                           taskProgression++;
                        }
                     }
                  }
                  else
                  {
                     levels = mastery.levels;
                     for each(level in levels)
                     {
                        threshold = int(level.@count);
                        if(currentCount < threshold && updatedCount >= threshold)
                        {
                           taskProgression++;
                        }
                     }
                  }
                  m_itemMasteryCounters[itemCode] = updatedCount;
               }
               if(progressionCacheIndex != null)
               {
                  purgeCutoff = transactionData.id - MAX_CACHED_TRANSACTION_AGE;
                  for(oldCacheIndex in this.m_typeMasteryProgressionPerTransaction)
                  {
                     if(this.m_typeMasteryProgressionPerTransaction[oldCacheIndex].id < purgeCutoff)
                     {
                        delete this.m_typeMasteryProgressionPerTransaction[oldCacheIndex];
                     }
                  }
                  this.m_typeMasteryProgressionPerTransaction[progressionCacheIndex] = {
                     "id":transactionId,
                     "value":taskProgression
                  };
               }
            }
         }
         return taskProgression;
      }
      
      private function getVehicleMultiplier(transactionData:Object) : int
      {
         var multiplier:int = 1;
         if(transactionData.hasOwnProperty("numPlotsSeeded"))
         {
            multiplier = int(transactionData.numPlotsSeeded);
         }
         return multiplier;
      }
      
      private function getExpandFarmProgression(farmExpansionName:String, transactionData:Object) : int
      {
         var taskProgression:int = this.getSimpleTransactionProgression(farmExpansionName,transactionData,"itemName");
         if(taskProgression == 0)
         {
            taskProgression = this.getSimpleTransactionProgression(farmExpansionName + "_cash",transactionData,"itemName");
         }
         return taskProgression;
      }
      
      private function getUseVehicleProgression(vehicleClass:String, transactionData:Object) : int
      {
         var item:FarmItem = null;
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("equipmentItem"))
         {
            item = transactionData.equipmentItem;
            if(item.className == vehicleClass)
            {
               taskProgression = 1;
            }
         }
         return taskProgression;
      }
      
      private function getMakeRecipeAnyProgression(transactionData:Object) : int
      {
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("recipeCode"))
         {
            taskProgression = 1;
         }
         return taskProgression;
      }
      
      private function getMakeRecipeByCategoryProgression(categoryName:String, transactionData:Object) : int
      {
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("recipeCode"))
         {
            if((QuestSettingsInit.getInstance() as FarmQuestSettingsInit).isItemCodeInCategory(transactionData.recipeCode,categoryName))
            {
               taskProgression = 1;
            }
         }
         return taskProgression;
      }
      
      private function getAchieveRecipeLevelByCodeProgression(recipeCode:String, transactionData:Object, requiredLevel:int) : int
      {
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("recipeCode") && transactionData.recipeCode == recipeCode)
         {
            if(transactionData.hasOwnProperty("recipeLevel") && transactionData.recipeLevel == requiredLevel)
            {
               taskProgression = 1;
            }
         }
         return taskProgression;
      }
      
      private function getAchieveRecipeLevelByCategoryProgression(category:String, transactionData:Object) : int
      {
         var recipeCode:String = null;
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("recipeCode") && transactionData.hasOwnProperty("recipeLeveledUp") && transactionData.recipeLeveledUp == true)
         {
            recipeCode = transactionData["recipeCode"];
            if(recipeCode != null && (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).isItemCodeInCategory(recipeCode,category))
            {
               taskProgression = 1;
            }
         }
         return taskProgression;
      }
      
      private function getStorageBuildingRewardsByCategoryProgression(category:String, transactionData:Object) : int
      {
         var rewardItemCodes:Array = null;
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("rewardItemCodes"))
         {
            rewardItemCodes = transactionData.rewardItemCodes;
            if(Boolean(rewardItemCodes) && Boolean(rewardItemCodes.length > 0) && (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).areEntriesInCategory(rewardItemCodes,category))
            {
               taskProgression = 1;
            }
         }
         return taskProgression;
      }
      
      private function getReachCraftSkillLevelProgression(craftType:String, transactionData:Object, requiredLevel:int) : int
      {
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("craftType") && transactionData.craftType == craftType)
         {
            if(transactionData.hasOwnProperty("nextLevel") && transactionData.nextLevel == requiredLevel)
            {
               taskProgression = 1;
            }
         }
         return taskProgression;
      }
      
      private function getSimpleTransactionProgression(targetType:String, transactionData:Object, propertyName:String) : int
      {
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty(propertyName) && transactionData[propertyName] == targetType)
         {
            taskProgression = 1;
         }
         return taskProgression;
      }
      
      private function getPlowPlotProgression(category:String, transactionData:Object) : int
      {
         var index:int = 0;
         var stringArray:Array = null;
         var i:int = 0;
         var taskProgression:int = 0;
         if(category == "")
         {
            category = QuestConstants.DEFAULT_PLOW_PLOT_TYPE;
         }
         if(transactionData.type)
         {
            for(index = 0; index < transactionData.type.length; index++)
            {
               stringArray = new Array();
               for(i = 0; i < transactionData.type[index].length; i++)
               {
                  stringArray.push(TerrainConfigManager.getInstance().getNameFromCode(transactionData.type[index][i]));
               }
               if((QuestSettingsInit.getInstance() as FarmQuestSettingsInit).areEntriesInCategory(stringArray,category))
               {
                  taskProgression++;
               }
            }
         }
         return taskProgression;
      }
      
      private function getCompleteFriendSetCompletion(friendSetId:String, transactionData:Object) : int
      {
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("friendSetCode") && transactionData.friendSetCode == friendSetId)
         {
            taskProgression = 1;
         }
         return taskProgression;
      }
      
      private function getExpandStorageBuildingToLevelByCodeProgression(storageBuildingCode:String, transactionData:Object, minimumCompletionLevel:String) : int
      {
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("item"))
         {
            if(storageBuildingCode == transactionData.item.code)
            {
               if(transactionData.hasOwnProperty("storageLevelUp"))
               {
                  if(transactionData.storageLevelUp == minimumCompletionLevel)
                  {
                     taskProgression = 1;
                  }
               }
            }
         }
         return taskProgression;
      }
      
      private function getWorldScoreLevelUpProgress(requiredWorldScoreUnit:String, transactionData:Object, minimumCompletionLevel:String) : int
      {
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("worldScoreUnit"))
         {
            if(requiredWorldScoreUnit == transactionData.worldScoreUnit)
            {
               if(transactionData.hasOwnProperty("worldScoreLevel"))
               {
                  if(transactionData.worldScoreLevel >= minimumCompletionLevel)
                  {
                     taskProgression = 1;
                  }
               }
            }
         }
         return taskProgression;
      }
      
      private function getUseAnimalLovePotionByCodeProgression(lovePotionItemCode:String, transactionData:Object) : int
      {
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("breedSession"))
         {
            if(transactionData.breedSession is AnimalBreedingSession)
            {
               taskProgression = int(transactionData.breedSession.numPotions);
            }
         }
         return taskProgression;
      }
      
      private function getAdoptAwayAnimalByCodeProgression(animalItemCode:String, transactionData:Object) : int
      {
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("itemCode"))
         {
            if(transactionData.itemCode == animalItemCode)
            {
               taskProgression = 1;
            }
         }
         return taskProgression;
      }
      
      private function getRaiseAnimalWithPatternByCodeProgression(animalItemCode:String, transactionData:Object, animalPatternCode:String) : int
      {
         var mutableAnimalState:MutableAnimalState = null;
         var taskProgression:int = 0;
         if(this.hasTransactionCompletedConstruction(transactionData))
         {
            if(transactionData.hasOwnProperty("item") && transactionData.item.code == animalItemCode)
            {
               if(transactionData.hasOwnProperty("building") && transactionData.building is MutableAnimalBaby)
               {
                  mutableAnimalState = transactionData.building.getMutableAnimalState();
                  if(mutableAnimalState.pattern == animalPatternCode)
                  {
                     taskProgression = 1;
                  }
               }
            }
         }
         return taskProgression;
      }
      
      private function hasTransactionCompletedConstruction(transactionData:Object) : Boolean
      {
         var hasCompletedConstruction:Boolean = false;
         if(transactionData.hasOwnProperty("action"))
         {
            switch(transactionData.action)
            {
               case TTransformBuilding.ACTION_TRANSFORM_BUILDING:
                  hasCompletedConstruction = true;
                  break;
               case TStoreItem.ACTION_STORE:
                  if(transactionData.hasOwnProperty("isFull"))
                  {
                     hasCompletedConstruction = Boolean(transactionData.isFull);
                  }
            }
         }
         return hasCompletedConstruction;
      }
      
      private function getHarvestBeanstalkProgression(transactionData:Object) : int
      {
         var taskProgression:int = 0;
         if(transactionData.hasOwnProperty("resource") && transactionData.resource is EverGrowingHarvestableBuilding)
         {
            taskProgression = (transactionData.resource as EverGrowingHarvestableBuilding).growthStep;
         }
         return taskProgression;
      }
      
      private function countdownItemUnlockByCode(itemCode:String, transactionData:Object) : int
      {
         var result:int = 0;
         if(transactionData.hasOwnProperty("purchasedItemCode"))
         {
            if(transactionData.purchasedItemCode === itemCode)
            {
               result = 1;
            }
         }
         else if(transactionData.hasOwnProperty("purchasedAll"))
         {
            if(transactionData.purchasedAll === true)
            {
               result = 1;
            }
         }
         return result;
      }
      
      private function getResourceProgressionValue(resource:HarvestableResource) : int
      {
         var result:int = 1;
         var plot:Plot = resource as Plot;
         if(plot)
         {
            result = SuperPlotManager.getMultiplier(plot);
         }
         return result;
      }
      
      private function getCollectSnowflakesProgress(type:String, transactionData:Object) : int
      {
         var itemCode:String = null;
         var count:int = 0;
         var result:int = 0;
         if(transactionData.hasOwnProperty("code"))
         {
            itemCode = transactionData.code;
            if((QuestSettingsInit.getInstance() as FarmQuestSettingsInit).isItemCodeInCategory(itemCode,type))
            {
               count = transactionData.hasOwnProperty("count") ? int(transactionData.count) : 1;
               result = count;
            }
         }
         return result;
      }
      
      private function getGrownFawnBabyCount(taskType:String, transactionData:Object) : int
      {
         return Boolean(transactionData.hasOwnProperty("item")) && Boolean(transactionData["item"].hasOwnProperty("code")) && transactionData["item"]["code"] == taskType ? 1 : 0;
      }
      
      private function getMysterySeedlingGrowthCount(taskType:String, transactionData:Object) : int
      {
         return Boolean(transactionData.hasOwnProperty("item")) && Boolean(transactionData["item"].hasOwnProperty("name")) && transactionData["item"]["name"] == taskType ? this.getCompleteConstructionProgression(transactionData) : 0;
      }
      
      private function getSDBProgress(taskType:String, transactionData:Object) : int
      {
         return transactionData.params.length > 0 && transactionData.params[0] == taskType ? 1 : 0;
      }
      
      private function getFawnFeedProgress(taskType:String, transactionData:Object) : int
      {
         var fawnItem:FarmItem = null;
         if(transactionData.hasOwnProperty("item"))
         {
            fawnItem = transactionData["item"];
            if(fawnItem)
            {
               return fawnItem.getIntFromDataSource("growPrice");
            }
         }
         return 0;
      }
      
      private function getEscapeTokenProgress(taskType:String, transactionData:Object) : int
      {
         var manager:* = undefined;
         var worldId:String = Global.worldManager.currentWorldType;
         switch(worldId)
         {
            case "aloha":
               manager = TropicalMarketInnovationManager.getInstance("TropicalMarketInnovation");
               break;
            case "pumpkin":
               manager = PumpkinPartyInnovationManager.getInstance("PumpkinPartyInnovation");
         }
         var progress:int = 0;
         if(manager)
         {
            progress = int(manager.getEscapeTokenProgress());
         }
         return progress;
      }
   }
}

