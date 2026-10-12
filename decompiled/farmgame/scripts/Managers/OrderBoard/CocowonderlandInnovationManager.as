package Managers.OrderBoard
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.QuestConstants;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureBuilding;
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Classes.MapResource;
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.SimpleHarvestableResource;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import Display.HUD.HUDWidgets.HudBottomCocowonderlandInnovationButton;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Helpers.Vector3;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.TileUnlockEvent;
   import Managers.BaseFeatureManager;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureCraftingManager;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.FeatureOptionsManager;
   import Managers.ItemFinderManager;
   import Managers.WorldSeasonsManager;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.CocowonderlandInnovationDailyBonusGrantWindow;
   import Widgets.Windows.CocowonderlandInnovationFinalRewardGrantWindow;
   import Widgets.Windows.CocowonderlandInnovationMainWindow;
   import Widgets.Windows.CocowonderlandInnovationOrderboardWindow;
   import Widgets.Windows.CocowonderlandInnovationProgressWindow;
   import Widgets.Windows.CocowonderlandInnovationTileUnlockwindow;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FeaturePackagesBuyWindow;
   import by.blooddy.crypto.serialization.JSON;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   
   public class CocowonderlandInnovationManager extends BaseFeatureManager
   {
      
      public static const HUD_INITIALISATION_FLAG:String = "cocowonderland_innovation_hud_initialise_flag";
      
      private static const HUD_COCOWONDERLAND_ASSET:String = "hud";
      
      public static const FEATURE_NAME:String = "CocowonderlandInnovation";
      
      private static const WINDOW_MAIN:String = "main";
      
      private static const WINDOW_ORDERBOARD:String = "orderboard";
      
      private static const WINDOW_REWARD:String = "reward";
      
      private static const WINDOW_CONGRATS:String = "congrats";
      
      private static const WINDOW_BUY:String = "buyDialog";
      
      public static const FIRST_EVER_REDEEM:String = "firstTimeRedeem";
      
      public static const COLLECT_TIME_KEY:String = "ctk";
      
      public static const FEED_NAME:String = "CocowonderlandInnovationUI";
      
      public static const FEATURE_OPTIONS_KEY:String = "CocowonderlandInnovation";
      
      private static var m_initialized:Boolean = false;
      
      public static const HALLOWEEN_ORDERBOARD_POINTS_ITEM_CODE:String = "cie3";
      
      private static const SKIP_COST:int = 1;
      
      private static const KEY_SAVED_ACTIVE_TASKS:String = "saved_active_tasks";
      
      private static const KEY_SAVED_ACTIVE_ORDERS:String = "activeOrders";
      
      private static const KEY_ORDER_ID:String = "id";
      
      private static const KEY_ORDER_CONFIG:String = "OrderConfig";
      
      private static const KEY_ORDERS:String = "orders";
      
      private static const KEY_ORDER:String = "order";
      
      private static const KEY_INGREDIENT_LIST:String = "ingredientlist";
      
      private static const KEY_INGREDIENTS:String = "ingredients";
      
      private static const KEY_INGREDIENT:String = "ingredient";
      
      private static const KEY_WEEK:String = "week";
      
      private static const KEY_NAME:String = "name";
      
      private static const KEY_QUANTITY:String = "qty";
      
      private static const KEY_SAVED_STATION_STATES:String = "stationStates";
      
      private static const KEY_STATE:String = "state";
      
      private static const KEY_COOK_TIME_START:String = "cookTimeStart";
      
      private static const KEY_COOKED_ORDER:String = "cookedOrder";
      
      private static const KEY_COOKTIME:String = "cooktime";
      
      public static const STATION_STATES:Array = ["locked","unlocked"];
      
      public static const STATION_STATE_LOCKED:int = 0;
      
      public static const STATION_STATE_UNLOCKED:int = 1;
      
      public static const KEY_SAVED_INGREDIENTS:String = "currentIngredients";
      
      private static const KEY_FTUE_ORDER_DONE:String = "ftueOrderDone";
      
      private static const ORDER_SLOTS_COUNT:int = 6;
      
      private static const ORDERBOARD_SLOT_COUNT:int = 6;
      
      private static const STATION_SLOTS_COUNT:int = 3;
      
      private static const INGREDIENTS_SLOTS_COUNT:int = 8;
      
      private static const KEY_SAVED_DUMPED_TIMESTAMP:String = "3";
      
      private static const KEY_FLUSH_DAILY_REWARD_TASK:String = "flush_daily_reward_tasks";
      
      public static const KEY_SAVED_FINAL_REWARD_BUILDINGNAME:String = "reward_building";
      
      private static const SERVICE_NAME:String = "CocowonderlandInnovationService";
      
      private static const LAST_BONUS_HARVEST_TIME_KEY:String = "xty_bht";
      
      public static const DEFAULT_HARVEST_THROTTLE_TIME:Number = 86400;
      
      public static const WEEK_MENU:Array = new Array("Pies","Muffins","Shakes","Donuts","Ice cream","Cakes");
      
      private static const BONUS_HARVEST_COUNT:String = "hc";
      
      private static const BONUS_COUNT_MAP:Object = {
         "bakershaven":10,
         "cafeespresso":12,
         "poppatisserie":15
      };
      
      public const TILE_UNLOCK:String = "Tile_Unlock";
      
      public const FIRST_TIME_UNLOCK:String = "First_tile_Unlock";
      
      public const GA_FEATURE_START:* = "ga_cocowonderland_innovation_start";
      
      public const EA_FEATURE_START:* = "ea_cocowonderland_innovation_start";
      
      public const DEFAULT_THROTTLE_TIME:Number = 86400;
      
      public const VAL_FINAL_MILESTONE:Number = 3000;
      
      private var m_assetPaths:Object = null;
      
      protected var m_staticData:Object;
      
      private var m_mainWindow:CocowonderlandInnovationMainWindow;
      
      public const KEY_ORDERBOARD_TASK_POINTS:String = "orderboard_task_points";
      
      public const KEY_TILE_UNLOCK_COUNT:String = "tile_unlock_count";
      
      public const COUPON_INVENTORY_LIMIT:int = 150;
      
      public const KEY_TILE_UNLOCK_POINTS:int = 30;
      
      public const VAL_FIRST_MILESTONE:int = 10;
      
      public const VAL_SECOND_MILESTONE:int = 20;
      
      public const VAL_THIRD_MILESTONE:int = 35;
      
      protected const KEY_PROGRESS:String = "progress";
      
      protected const KEY_TOTAL:String = "total";
      
      private var m_resultObject:Object;
      
      private const QUEST_NAME:String = "CocowonderlandInnovation";
      
      private var m_cocwonderlandInnovationHud:HudBottomCocowonderlandInnovationButton;
      
      private const KEY_TASK_ID:String = "id";
      
      private const KEY_USER_STATE:String = "state";
      
      private const KEY_DAY_POINTS:String = "dp";
      
      internal const KEY_CURRENT_WEEK:* = "currentweek";
      
      private const KEY_ORDERBOARD_COUNT:String = "orderboard_task_count";
      
      private const KEY_CURRENT_AVERAGE:String = "current_average";
      
      private const WEEKLY_SCORE:String = "weekly_score";
      
      public const EASY:int = 0;
      
      public const MEDIUM:int = 1;
      
      public const HARD:int = 2;
      
      public const LOCK1:int = 4;
      
      public const LOCK2:int = 5;
      
      public const DONE_FOR_THE_DAY:int = 3;
      
      public const NOT_INITIALIZED:int = -1;
      
      private const KEY_DAILY_PROGRESS_POINTS:String = "pts";
      
      private const KEY_COCOLAND_TILE_UNLOCK_COUNT:String = "2d67";
      
      private const FEATURE_OPTIONS_BONUS_CLAIMED_KEY:String = "bonus";
      
      private const KEY_BOOSTER_APPLIED:String = "booster";
      
      private const KEY_FEATURE_ENDED:String = "finished";
      
      private const KEY_ACTIVE_DAY_TIMESTAMP:String = "ts";
      
      private var m_orderboardWindow:CocowonderlandInnovationOrderboardWindow;
      
      private var m_progressWindow:CocowonderlandInnovationProgressWindow;
      
      private var m_tasksById:Object = null;
      
      private var m_OrdersByName:Object = null;
      
      private var m_IngredientsByName:Object = null;
      
      private var m_cookTime:int = -1;
      
      private const FEATURE_OPTIONS_BONUS_CODE_KEY:String = "bonusCode";
      
      private var m_rewardsBySlotName:Object = null;
      
      public const VAL_MILESTONE_POINTS_ARRAY:Array = [10,20,35];
      
      private const VAL_CLASSIC:int = 30;
      
      private const VAL_SUPERB:int = 15;
      
      private const VAL_GOOD:int = 5;
      
      private const SERVICE_FUNC_HARVEST_BONUS:String = "harvestBonusBuilding";
      
      private const SERVICE_FUNC_BUY_INGREDIENT:String = "buyIngredient";
      
      private const SERVICE_FUNC_START_COOKING:String = "startCooking";
      
      private const SERVICE_FUNC_GRANT_BONUS:String = "grantBonus";
      
      private const EVENT_COCOWONDERLAND_INNOVATION_TILE_UNLOCK:String = "CocowonderlandInnovationTileUnlock";
      
      public const FIRST_SESSION_TUTORIAL:String = "TIFirstSessioTutorial";
      
      private var _redeemHasStarted:Boolean = false;
      
      private var _redeemMessageShown:Boolean = false;
      
      public function CocowonderlandInnovationManager(featureName:String, featureConfig:XML = null)
      {
         super(featureName,featureConfig);
         this.parseTaskObjectsFromConfig(this.QUEST_NAME);
         this.parseRewardsDataFromConfig(this.QUEST_NAME);
         this.parseOrderConfigFromConfig();
         this.startQuest();
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
      }
      
      public static function getInstance(featureName:String = "CocowonderlandInnovation") : CocowonderlandInnovationManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,CocowonderlandInnovationManager) as CocowonderlandInnovationManager;
      }
      
      public function getInnovationFeatureName() : String
      {
         return FEATURE_NAME;
      }
      
      public function getFeatureData() : Object
      {
         var index:* = undefined;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,m_featureName);
         if(!featureData)
         {
            featureData = {};
            featureData[this.KEY_USER_STATE] = this.NOT_INITIALIZED;
            featureData[KEY_SAVED_ACTIVE_TASKS] = {};
            featureData[KEY_SAVED_DUMPED_TIMESTAMP] = {};
            featureData[this.KEY_DAILY_PROGRESS_POINTS] = {};
            for(index = 0; index < 42; index++)
            {
               featureData[this.KEY_DAILY_PROGRESS_POINTS][index] = 0;
            }
            featureData[this.WEEKLY_SCORE] = 0;
            featureData[KEY_FLUSH_DAILY_REWARD_TASK] = 0;
            featureData[this.KEY_CURRENT_WEEK] = 0;
            featureData[this.KEY_TILE_UNLOCK_COUNT] = 0;
            featureData[KEY_SAVED_ACTIVE_ORDERS] = {};
            featureData[this.FEATURE_OPTIONS_BONUS_CLAIMED_KEY] = 0;
            featureData[KEY_FTUE_ORDER_DONE] = false;
            featureData[KEY_SAVED_STATION_STATES] = {};
            for(index = 0; index < STATION_SLOTS_COUNT; index++)
            {
               featureData[KEY_SAVED_STATION_STATES][index] = {};
               featureData[KEY_SAVED_STATION_STATES][index][KEY_STATE] = STATION_STATES[STATION_STATE_LOCKED];
               featureData[KEY_SAVED_STATION_STATES][index][KEY_INGREDIENTS] = [];
               featureData[KEY_SAVED_STATION_STATES][index][KEY_COOK_TIME_START] = 0;
               featureData[KEY_SAVED_STATION_STATES][index][KEY_COOKED_ORDER] = "";
            }
            featureData[KEY_SAVED_INGREDIENTS] = {};
            featureData[this.KEY_ORDERBOARD_TASK_POINTS] = 0;
            setFeatureData(featureData);
         }
         return featureData;
      }
      
      protected function parseOrderConfigFromConfig() : void
      {
         var week:XML = null;
         var order:XML = null;
         var ingredient:XML = null;
         var featureConfig:XML = Global.farmGameSettingsManager.getXML().CocowonderlandInnovationConfig[0];
         if(featureConfig.hasOwnProperty(KEY_ORDER_CONFIG))
         {
            this.m_OrdersByName = {};
            this.m_IngredientsByName = {};
            for each(week in featureConfig[KEY_ORDER_CONFIG][KEY_WEEK])
            {
               if(this.isCurrentWeek(week))
               {
                  for each(order in week[KEY_ORDERS][KEY_ORDER])
                  {
                     this.m_OrdersByName[order.@name] = order;
                  }
                  for each(ingredient in week[KEY_INGREDIENT_LIST][KEY_INGREDIENT])
                  {
                     this.m_IngredientsByName[ingredient.@name] = ingredient;
                  }
               }
            }
            this.m_cookTime = parseInt(featureConfig[KEY_ORDER_CONFIG][KEY_COOKTIME]["@time"]);
         }
      }
      
      public function getCookTime() : int
      {
         return this.m_cookTime;
      }
      
      public function getIngredientXML(ingredient:String) : XML
      {
         if(this.m_IngredientsByName)
         {
            return this.m_IngredientsByName[ingredient];
         }
         return null;
      }
      
      public function getOrderXML(orderName:String) : XML
      {
         if(this.m_OrdersByName)
         {
            return this.m_OrdersByName[orderName];
         }
         return null;
      }
      
      public function unlockLandFromOBWindow() : void
      {
         if(this.m_orderboardWindow)
         {
            this.m_orderboardWindow.close();
         }
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
         CocowonderlandInnovationManager.getInstance().highlightTiles();
         FarmStatsManager.count("CocowonderlandInnovation","UnlockTile","tile_unlock","click");
      }
      
      public function getCurrentWeekIndex() : int
      {
         var featureData:Object = this.getFeatureData();
         return featureData[this.KEY_CURRENT_WEEK];
      }
      
      private function isCurrentWeek(week:XML) : Boolean
      {
         var currentWeek:* = undefined;
         var featureData:Object = this.getFeatureData();
         var weeks:Array = this.getWeeksArray();
         if(featureData[this.KEY_CURRENT_WEEK] > 0)
         {
            currentWeek = weeks[parseInt(featureData[this.KEY_CURRENT_WEEK]) - 1];
            return currentWeek["@start"] == week["@start"];
         }
         return false;
      }
      
      protected function parseTaskObjectsFromConfig(questName:String) : void
      {
         var orderBoardXml:XML = null;
         var tasksByDifficultyList:XMLList = null;
         var tasksByDiff:XML = null;
         var tasksByDiffAndTypeList:XMLList = null;
         var tasksByDiffAndType:XML = null;
         var taskXML:XML = null;
         this.m_tasksById = {};
         orderBoardXml = Global.farmGameSettingsManager.getXML().orderBoards.orderBoard.(@name == questName)[0];
         if(orderBoardXml)
         {
            tasksByDifficultyList = orderBoardXml.orderBoardTasks.difficulty;
            for each(tasksByDiff in tasksByDifficultyList)
            {
               tasksByDiffAndTypeList = tasksByDiff.tasks;
               for each(tasksByDiffAndType in tasksByDiffAndTypeList)
               {
                  for each(taskXML in tasksByDiffAndType.task)
                  {
                     this.m_tasksById[taskXML.@id] = taskXML;
                  }
               }
            }
         }
      }
      
      public function setupCocowonderlandHud() : void
      {
         this.m_cocwonderlandInnovationHud = new HudBottomCocowonderlandInnovationButton(this.hudURL,m_featureName);
         Global.hud.setBottomHudCocowonderlandInnovationButton(this.m_cocwonderlandInnovationHud as HudBottomCocowonderlandInnovationButton);
      }
      
      public function getCustomerOrders() : Vector.<XML>
      {
         var order:Object = null;
         var orderXML:XML = null;
         var orderList:Vector.<XML> = new Vector.<XML>();
         var savedOrderInfo:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_ORDERS) as Array;
         if(Boolean(savedOrderInfo) && Boolean(savedOrderInfo.length))
         {
            if(this.m_OrdersByName == null || this.m_OrdersByName.length == 0)
            {
               this.parseOrderConfigFromConfig();
            }
            for each(order in savedOrderInfo)
            {
               orderXML = this.m_OrdersByName[order];
               if(orderXML)
               {
                  orderList.push(orderXML);
               }
            }
         }
         return orderList;
      }
      
      public function getStationsInfo() : Array
      {
         return this.getFeatureOptionsKey(KEY_SAVED_STATION_STATES) as Array;
      }
      
      public function getIngredients() : Vector.<XML>
      {
         var index:int = 0;
         var ingredient:Object = null;
         var ingredientXML:XML = null;
         var ingredientList:Vector.<XML> = new Vector.<XML>();
         var savedIngredientInfo:Object = this.getFeatureOptionsKey(KEY_SAVED_INGREDIENTS);
         if(savedIngredientInfo)
         {
            if(this.m_IngredientsByName == null || this.m_IngredientsByName.length == 0)
            {
               this.parseOrderConfigFromConfig();
            }
            index = 0;
            for(ingredient in savedIngredientInfo)
            {
               ingredientXML = this.m_IngredientsByName[ingredient.toString()];
               if(ingredientXML)
               {
                  ingredientXML["@qty"] = savedIngredientInfo[ingredient.toString()];
                  ingredientList.push(ingredientXML);
               }
            }
         }
         return ingredientList;
      }
      
      public function getTasks() : Vector.<FarmTask>
      {
         var task:Object = null;
         var taskXML:XML = null;
         var taskObj:Object = null;
         var farmTask:FarmTask = null;
         var taskList:Vector.<FarmTask> = new Vector.<FarmTask>();
         var savedTaskInfo:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         if(Boolean(savedTaskInfo) && Boolean(savedTaskInfo.length))
         {
            if(this.m_tasksById == null)
            {
               this.parseTaskObjectsFromConfig(m_featureName);
            }
            for each(task in savedTaskInfo)
            {
               taskXML = this.m_tasksById[task[this.KEY_TASK_ID]];
               if(taskXML)
               {
                  taskObj = FarmGameUtil.xmlNodeToAttributes(taskXML);
                  taskObj.questName = m_featureName;
                  taskObj.taskIndex = savedTaskInfo.indexOf(task);
                  farmTask = new FarmTask(taskObj);
                  taskList.push(farmTask);
               }
               else
               {
                  taskObj = {};
                  taskObj.action = "useItemByCode";
                  taskObj.type = "vg3q";
                  taskObj.total = "5";
                  taskObj.cashValue = "3";
                  taskObj.helper = "post_ask_for_item_feed";
                  taskObj.questName = m_featureName;
                  taskObj.taskIndex = savedTaskInfo.indexOf(task);
                  farmTask = new FarmTask(taskObj);
                  taskList.push(farmTask);
               }
            }
         }
         return taskList;
      }
      
      protected function saveProgressForPlayer(progressArray:Array) : void
      {
         var taskObj:Object = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         var savedTasks:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         var tasksToSave:Array = [];
         for(var i:int = 0; i < tasks.length; i++)
         {
            taskObj = {};
            if(tasks[i].id != "")
            {
               taskObj[this.KEY_TASK_ID] = tasks[i].id;
            }
            if(tasks[i].helperType == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
            {
               taskObj[this.KEY_PROGRESS] = CraftingManager.getInstance().getBushelQuantityInInventory(tasks[i].type);
            }
            else
            {
               taskObj[this.KEY_PROGRESS] = Math.min(Number(savedTasks[i][this.KEY_PROGRESS]) + progressArray[i],tasks[i][this.KEY_TOTAL]);
            }
            tasksToSave.push(taskObj);
         }
         this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,tasksToSave as Object);
      }
      
      public function startQuest(callback:Function = null) : void
      {
         var savedTaskInfo:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         if(!(savedTaskInfo && savedTaskInfo.length))
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startQuest",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName)),true);
         }
      }
      
      protected function checkForTaskUpdates(event:TransactionEvent) : void
      {
         var progress:Number = NaN;
         var transaction:TFarmTransaction = null;
         var hasUpdatedProgress:Boolean = false;
         var hasCompletedTask:Boolean = false;
         var progressArray:Array = [];
         var tasks:Vector.<FarmTask> = this.getTasks();
         var savedTasks:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         for(var i:int = 0; i < tasks.length; i++)
         {
            transaction = event.transaction as TFarmTransaction;
            if(tasks[i].helperType == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
            {
               progress = CraftingManager.getInstance().getBushelQuantityInInventory(tasks[i].type) - savedTasks[i][this.KEY_PROGRESS];
               hasUpdatedProgress = true;
            }
            else
            {
               progress = FarmQuestUtility.getInstance().getProgression(tasks[i],transaction,null);
            }
            progressArray.push(progress);
            if(progress > 0)
            {
               hasUpdatedProgress = true;
               if(Number(savedTasks[i][this.KEY_PROGRESS]) + progress >= tasks[i].total)
               {
                  hasCompletedTask = true;
               }
            }
         }
         if(hasUpdatedProgress)
         {
            this.saveProgressForPlayer(progressArray);
         }
         if(hasCompletedTask)
         {
            if(this.m_cocwonderlandInnovationHud)
            {
               this.m_cocwonderlandInnovationHud.refresh(1);
            }
         }
      }
      
      public function getOrderboardProgress() : int
      {
         return this.getFeatureOptionsKey(this.KEY_ORDERBOARD_TASK_POINTS) as int;
      }
      
      protected function onTransactionAdded(event:TransactionEvent) : void
      {
         this.checkForTaskUpdates(event);
      }
      
      private function resetActionCountsForTasks(questTask:FarmTask) : void
      {
         var actionKey:String = null;
         if(questTask.action == QuestConstants.TASK_USE_ITEM_BY_CODE)
         {
            actionKey = questTask.getActionKey();
            if(Boolean(actionKey) && actionKey != "")
            {
               Global.player.resetActionCount(actionKey);
            }
         }
      }
      
      public function isTaskDumped(questIndex:int) : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         var savedTasks:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         if(!savedTasks[questIndex].hasOwnProperty(this.KEY_TASK_ID))
         {
            result = true;
         }
         return result;
      }
      
      public function skipTask(questIndex:int, taskPoints:int, callback:Function) : void
      {
         var savedTasks:Array = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         if(Global.player.canBuyCash(tasks[questIndex].skipCashValue))
         {
            Global.player.cash -= tasks[questIndex].skipCashValue;
            savedTasks = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
            savedTasks[questIndex][this.KEY_PROGRESS] = tasks[questIndex].total;
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,savedTasks);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
            this.resetActionCountsForTasks(tasks[questIndex]);
            this.m_orderboardWindow.refreshWindow();
         }
         else
         {
            callback.call();
         }
      }
      
      public function getNewTasks(questIndex:int, callback:Function) : void
      {
         var tasks:Vector.<FarmTask> = this.getTasks();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getNewTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
         var dumpTimestamp:Object = this.getFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP) as Object;
         dumpTimestamp[questIndex] = 0;
         this.saveFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP,dumpTimestamp);
         this.resetActionCountsForTasks(tasks[questIndex]);
         this.m_orderboardWindow.refreshWindow();
      }
      
      public function grantPointsForTask(pointsForTask:int) : void
      {
         var currentProgress:int = this.getOrderboardProgress();
         if(currentProgress < this.VAL_FINAL_MILESTONE)
         {
            if(pointsForTask + currentProgress > this.VAL_FINAL_MILESTONE)
            {
               this.saveFeatureOptionsKey(this.KEY_ORDERBOARD_TASK_POINTS,this.VAL_FINAL_MILESTONE);
            }
            else
            {
               this.saveFeatureOptionsKey(this.KEY_ORDERBOARD_TASK_POINTS,pointsForTask + currentProgress);
            }
         }
      }
      
      public function isFinalRewardChosen() : Boolean
      {
         return this.getRewardBuildingName() != null && this.getRewardBuildingName() != "0";
      }
      
      public function getRewardBuildingName() : String
      {
         return this.getFeatureOptionsKey(KEY_SAVED_FINAL_REWARD_BUILDINGNAME) as String;
      }
      
      public function redeemRewardPoints(questIndex:int, callback:Function, taskPoints:int = 0) : void
      {
         var tasks:Vector.<FarmTask> = this.getTasks();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"redeemRewardPoints",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
         this.resetActionCountsForTasks(tasks[questIndex]);
         this.m_orderboardWindow.refreshWindow();
      }
      
      public function get lockedTilesArray() : Array
      {
         var tilename:String = null;
         var tileObjects:Array = null;
         var lockedTiles:Array = new Array();
         var tilesArray:Array = this.TilesArray as Array;
         for each(tilename in tilesArray)
         {
            tileObjects = Global.world.getObjectsByName(tilename);
            if(Boolean(tileObjects) && tileObjects.length > 0)
            {
               lockedTiles.push(tilename);
            }
         }
         return lockedTiles;
      }
      
      public function get tileUnlockCount() : int
      {
         var tilesArray:Array = this.TilesArray as Array;
         var lockedCount:int = this.lockedTilesArray.length >= 0 ? int(this.lockedTilesArray.length) : 0;
         return int(tilesArray.length - lockedCount);
      }
      
      public function highlightTiles() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
         UI.displayMiniMarketDialog(this.lockedTilesArray,null,"seed",null,true,false,false,true);
      }
      
      public function initEventListener() : void
      {
         GlobalEventManager.getInstance().addEventListener(this.EVENT_COCOWONDERLAND_INNOVATION_TILE_UNLOCK,this.showTileUnlockGrantPopup);
      }
      
      public function deleteEventListener() : void
      {
         GlobalEventManager.getInstance().removeEventListener(this.EVENT_COCOWONDERLAND_INNOVATION_TILE_UNLOCK,this.showTileUnlockGrantPopup);
      }
      
      public function showTileUnlockCountMc() : Number
      {
         var result:int = 0;
         var featureObj:Object = this.getFeatureData();
         if(this.tileUnlockCount > featureObj[this.KEY_TILE_UNLOCK_COUNT])
         {
            result = this.tileUnlockCount - featureObj[this.KEY_TILE_UNLOCK_COUNT];
            featureObj[this.KEY_TILE_UNLOCK_COUNT] = this.tileUnlockCount;
            setFeatureData(featureObj);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"updateTileUnlockCount",null,[featureName,this.tileUnlockCount]),true);
         }
         return result;
      }
      
      public function showTileUnlockGrantPopup(e:TileUnlockEvent = null) : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("cocowonderland_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            UI.displayPopup(new CocowonderlandInnovationTileUnlockwindow("assets/dialogs/expansion/FV_RewardDialog.swf",featureName,null,null,"assets/dialogs/cocoland/RewardDialog.png"));
            FarmStatsManager.count(m_featureName,"feature_ui","tileUnlockPopup");
         }
         this.refreshMainWindow();
         if(!Global.player.getSeenFlag(this.TILE_UNLOCK))
         {
            Global.player.setSeenFlag(this.TILE_UNLOCK);
         }
      }
      
      public function showDailyBonusGrantPopup(rewardItem:FarmItem, milestoneCount:int) : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         FarmStatsManager.count(m_featureName,"feature_ui","dailyBonusPopup");
         UI.displayPopup(new CocowonderlandInnovationDailyBonusGrantWindow("assets/dialogs/expansion/FV_RewardDialog.swf",featureName,rewardItem,null,"assets/dialogs/cocoland/RewardDialog.png",milestoneCount),false);
      }
      
      public function showFinalRewardGrantPopup(progressAverage:int) : void
      {
         FarmStatsManager.count(m_featureName,"feature_ui","finalBonusPopup");
         UI.displayPopup(new CocowonderlandInnovationFinalRewardGrantWindow("assets/dialogs/cocoland/innovation/FV_xcl_Innovation_End.swf",featureName,null,null,progressAverage),false);
      }
      
      public function showMainUI(showTutorialWithEAPage:Boolean = false) : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         this.startQuest();
         if(this.isFeatureInActivePeriod())
         {
            this.m_mainWindow = new CocowonderlandInnovationMainWindow(m_featureName,this.mainWindowURL,showTutorialWithEAPage);
            UI.displayPopup(this.m_mainWindow);
         }
         FarmStatsManager.count("CocowonderlandInnovation","feature_ui","main_ui","impression");
      }
      
      private function getFinalRewards() : Array
      {
         return ["bakershaven","cafeespresso","poppatisserie"];
      }
      
      public function replceIntermediateRewardWithFinalReward() : void
      {
         var finishedItem:FarmItem = null;
         var currentItemName:String = null;
         var currentItem:FarmItem = null;
         var currentPosition:Vector3 = null;
         var id:Number = NaN;
         var tempClass:Class = null;
         var transformedObject:MapResource = null;
         var storageBuilding:StorageBuilding = null;
         var interMediateReward:String = "xcl_cococakelady";
         var finalRewards:Array = this.getFinalRewards();
         if(this.overAllProgressLevel() == -1)
         {
            this.showFinalRewardGrantPopup(this.overAllProgressLevel());
            this.saveFeatureOptionsKey(this.FEATURE_OPTIONS_BONUS_CLAIMED_KEY,1);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"updateFinalBonusRewardClaim",null,[featureName]),true);
            return;
         }
         var finalReward:String = finalRewards[this.overAllProgressLevel()];
         StatsManager.count("CocowonderlandInnovation","TempleChoice",finalReward);
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,KEY_SAVED_FINAL_REWARD_BUILDINGNAME,finalReward);
         var m_owner:FeatureBuilding = Global.world.getObjectsByName(interMediateReward)[0];
         var finishedName:String = finalReward;
         if(Boolean(m_owner) && Boolean(finishedName) && finishedName != "")
         {
            finishedItem = Global.farmGameSettingsManager.getFarmItemByName(finishedName);
            if(finishedItem)
            {
               currentItemName = interMediateReward;
               currentItem = Global.farmGameSettingsManager.getFarmItemByName(currentItemName);
               Global.player.removeLimitedItem(currentItemName);
               currentPosition = m_owner.getPosition();
               id = m_owner.getId();
               m_owner.detach();
               tempClass = getDefinitionByName("Classes." + finishedItem.className) as Class;
               transformedObject = new tempClass(finishedItem.name);
               transformedObject.setMetadata(m_owner.getMetadata());
               transformedObject.attachToPersistentData(m_owner.persistentDataKey);
               transformedObject.setOuter(Global.world);
               transformedObject.setPosition(currentPosition.x,currentPosition.y,currentPosition.z);
               transformedObject.conditionallyReattach();
               transformedObject.setId(id);
               storageBuilding = transformedObject as StorageBuilding;
               if(storageBuilding)
               {
                  if(storageBuilding.shouldCopyPartsWhenReplacing())
                  {
                     storageBuilding.copyParts(m_owner);
                  }
                  if(storageBuilding.shouldCopyStorageWhenReplacing())
                  {
                     storageBuilding.copyStorage(m_owner);
                  }
                  if(storageBuilding.shouldCopyPlantTimeWhenReplacing())
                  {
                     storageBuilding.plantTime = m_owner.plantTime;
                  }
                  if(FarmGameSettingsManager.isInDataSourceExperiment())
                  {
                     if(finishedItem.hasPropertyInDataSource("initialExpansionLevel"))
                     {
                        storageBuilding.storageLevel = finishedItem.getIntFromDataSource("initialExpansionLevel");
                     }
                  }
                  else if(finishedItem.xml.hasOwnProperty("initialExpansionLevel"))
                  {
                     storageBuilding.storageLevel = parseInt(finishedItem.xml.initialExpansionLevel);
                  }
               }
               if(transformedObject is SimpleHarvestableResource)
               {
                  (transformedObject as SimpleHarvestableResource).setState(FeatureBuilding.STATE_RIPE);
               }
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onGrantFinalReward",null,[m_featureName,finalReward]),true);
               this.showFinalRewardGrantPopup(this.overAllProgressLevel());
               this.saveFeatureOptionsKey(this.FEATURE_OPTIONS_BONUS_CLAIMED_KEY,1);
            }
         }
      }
      
      public function isFeatureInActivePeriod() : Boolean
      {
         return FarmGameUtil.isFeatureInActivePeriod(this.bonusGrantDate);
      }
      
      public function openOrderBoardWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         this.startQuest();
         this.m_orderboardWindow = new CocowonderlandInnovationOrderboardWindow(this.orderboardWindowURL);
         UI.displayPopup(this.m_orderboardWindow,false);
      }
      
      public function openBuyWindow(owner:FarmWindow) : void
      {
         UI.displayPopup(new FeaturePackagesBuyWindow(this.buyDialogURL,m_featureName,this.getBucketPackages(),owner),false);
         FarmStatsManager.count("CocowonderlandInnovation","feature_ui","buy_ui","impression");
      }
      
      public function saveBushelProgress() : void
      {
         var taskObj:Object = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         var savedTasks:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         var tasksToSave:Array = [];
         for(var i:int = 0; i < tasks.length; i++)
         {
            taskObj = {};
            if(tasks[i].id != "")
            {
               taskObj[this.KEY_TASK_ID] = tasks[i].id;
            }
            if(tasks[i].helperType == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
            {
               taskObj[this.KEY_PROGRESS] = CraftingManager.getInstance().getBushelQuantityInInventory(tasks[i].type);
            }
            else
            {
               taskObj[this.KEY_PROGRESS] = savedTasks[i][this.KEY_PROGRESS];
            }
            tasksToSave.push(taskObj);
         }
         this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,tasksToSave as Object);
      }
      
      public function initialize() : void
      {
         this.loadStaticData();
      }
      
      private function loadStaticData() : void
      {
         var rewardXML:XML = null;
         var itemXML:XML = null;
         var tile:XML = null;
         var asset:XML = null;
         var tileName:String = null;
         var weekxml:XML = null;
         this.m_staticData = new Object();
         this.m_staticData.typeArray = [];
         this.m_staticData.rewardArray = [];
         this.m_staticData.rewardCostArray = [];
         this.m_staticData.bucketPackages = [];
         this.m_staticData.tilesArray = [];
         this.m_staticData.startDate = "";
         this.m_staticData.endDate = "";
         this.m_staticData.consumable = "";
         this.m_staticData.currencyName = "";
         this.m_staticData.initialGrant = 0;
         this.m_staticData.rewardGrantCount = 0;
         this.m_staticData.bonusGrantDate = new String();
         this.m_staticData.weeks = new Array();
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         if(featureXML != null)
         {
            m_initialized = true;
            this.m_assetPaths = new Object();
            if(featureXML.assets != "")
            {
               for each(asset in featureXML.assets.asset)
               {
                  this.m_assetPaths[asset.@name] = asset.@path.toString();
               }
            }
            this.m_staticData.bonusGrantDate = featureXML.listEndDate.toString();
            this.m_staticData.endDate = featureXML.listEndDate.toString();
            this.m_staticData.startDate = featureXML.listStartDate.toString();
            this.m_staticData.consumable = featureXML.bucketItem.@code.toString();
            this.m_staticData.initialGrant = featureXML.initialGrant.toString();
            this.m_staticData.currencyName = featureXML.currencyItem.@name.toString();
            for each(rewardXML in featureXML.rewards.reward)
            {
               this.m_staticData.rewardArray.push(rewardXML.@name.toString());
               this.m_staticData.rewardCostArray.push(rewardXML.@cost);
            }
            for each(itemXML in featureXML.bucketPackages.bucketPackage)
            {
               this.m_staticData.bucketPackages.push(itemXML.@name.toString());
            }
            for each(tile in featureXML.items.item)
            {
               tileName = tile.@name.toString();
               this.m_staticData.tilesArray.push(tileName);
            }
            if(featureXML.weeks)
            {
               for each(weekxml in featureXML.weeks.week)
               {
                  this.m_staticData.weeks.push(weekxml);
               }
            }
         }
      }
      
      public function get mainWindowURL() : String
      {
         return "assets/dialogs/cocoland/innovation/FV_xcl_Innovation.swf";
      }
      
      public function get hudURL() : String
      {
         return this.m_assetPaths[HUD_COCOWONDERLAND_ASSET];
      }
      
      public function get orderboardWindowURL() : String
      {
         return "assets/dialogs/cocoland/innovation/FV_xcl_Innovation_Orderboard.swf";
      }
      
      public function get progressWindowURL() : String
      {
         return "assets/dialogs/cocoland/innovation/FV_xcl_Innovation_Rewards.swf";
      }
      
      public function get rewardWindowURL() : String
      {
         return this.m_assetPaths[WINDOW_REWARD];
      }
      
      public function get currencyName() : String
      {
         if(this.m_staticData)
         {
            return this.m_staticData.currencyName;
         }
         return "";
      }
      
      public function get featureEndWindowURL() : String
      {
         return this.m_assetPaths[WINDOW_CONGRATS];
      }
      
      public function get buyDialogURL() : String
      {
         return this.m_assetPaths[WINDOW_BUY];
      }
      
      public function getBucketPackages() : Array
      {
         return this.m_staticData.bucketPackages;
      }
      
      public function get ConsumableCode() : String
      {
         return this.m_staticData.consumable;
      }
      
      public function get bonusGrantDate() : String
      {
         return this.m_staticData.bonusGrantDate;
      }
      
      public function get featureStartDate() : String
      {
         return this.m_staticData.startDate;
      }
      
      public function get TilesArray() : Array
      {
         return this.m_staticData.tilesArray;
      }
      
      public function canCollectForTheDay() : Boolean
      {
         var canCollect:Boolean = true;
         var key:String = m_featureName + COLLECT_TIME_KEY;
         if(this.getTimeLeft(key,this.DEFAULT_THROTTLE_TIME) > 0)
         {
            canCollect = false;
         }
         return canCollect;
      }
      
      public function getTimeLeft(key:String, throttleTime:int = 86400) : int
      {
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         return int(throttleTime - timeSinceLastFeed);
      }
      
      private function onAskForConsumables(e:Object) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.refreshAskButton();
         }
      }
      
      public function askForConsumables(event:Event = null) : void
      {
         getFeedData(FEED_NAME).postFeed(this.onAskForConsumables);
      }
      
      public function getFeatureEndDaysLeftText() : String
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber(this.bonusGrantDate);
         timeLeft = (endTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return this.getformattedDaysLeft(timeLeft);
      }
      
      public function getformattedDaysLeft(timeLeft:Number) : String
      {
         var days:int = 0;
         var result:String = "";
         if(timeLeft < 0)
         {
            timeLeft = 0;
         }
         var timeLeftArray:Array = FarmGameUtil.parseTimeLeft(timeLeft);
         if(Boolean(timeLeftArray) && timeLeftArray.length > 3)
         {
            days = int(timeLeftArray[0]);
            result = days.toString();
            if(days < 10)
            {
               result = "0" + result;
            }
            if(days == 0)
            {
               result = "--";
            }
         }
         return result;
      }
      
      public function hasFeatureExpired() : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber(this.bonusGrantDate);
         timeLeft = (endTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(timeLeft < 0)
         {
            result = true;
         }
         return result;
      }
      
      public function checkAndUpdateUserState() : void
      {
         var userState:int = 0;
         var rewardName:String = null;
         var milestoneCount:String = null;
         var dayPoints:int = this.getDayPoints();
         var featureObj:Object = this.getFeatureData();
         if(this.hasActiveDayExpired() == false)
         {
            userState = featureObj[this.KEY_USER_STATE] as int;
            if(dayPoints >= this.VAL_FIRST_MILESTONE && userState == this.EASY)
            {
               featureObj[this.KEY_USER_STATE] = this.MEDIUM;
               featureObj[KEY_SAVED_STATION_STATES][this.MEDIUM][KEY_STATE] = STATION_STATES[STATION_STATE_UNLOCKED];
               setFeatureData(featureObj);
               this.mainWindow.m_stationsFrame.refreshSlot(this.MEDIUM);
               this.grantUserRewardforLevel(this.EASY);
               this.showDailyBonusGrantPopup(this.getActiveDayReward(this.EASY),this.EASY);
               rewardName = this.getActiveDayReward(this.EASY).friendlyTitle;
               milestoneCount = "Day" + this.activeDayIndex.toString() + "-0";
               FarmStatsManager.count("CocowonderlandInnovation","Milestone",milestoneCount,rewardName,null,dayPoints.toString());
            }
            else if(dayPoints >= this.VAL_SECOND_MILESTONE && userState == this.MEDIUM)
            {
               featureObj[this.KEY_USER_STATE] = this.HARD;
               featureObj[KEY_SAVED_STATION_STATES][this.HARD][KEY_STATE] = STATION_STATES[STATION_STATE_UNLOCKED];
               setFeatureData(featureObj);
               this.mainWindow.m_stationsFrame.refreshSlot(this.HARD);
               this.grantUserRewardforLevel(this.MEDIUM);
               this.showDailyBonusGrantPopup(this.getActiveDayReward(this.MEDIUM),this.MEDIUM);
               rewardName = this.getActiveDayReward(this.EASY).friendlyTitle;
               milestoneCount = "Day" + this.activeDayIndex.toString() + "-1";
               FarmStatsManager.count("CocowonderlandInnovation","Milestone",milestoneCount,rewardName,null,dayPoints.toString());
            }
            else if(dayPoints >= this.VAL_THIRD_MILESTONE && userState == this.HARD)
            {
               featureObj[this.KEY_USER_STATE] = this.DONE_FOR_THE_DAY;
               FarmStatsManager.count("CocowonderlandInnovation","userstate",this.currentDayIndex.toString(),"classic");
               this.grantUserRewardforLevel(this.HARD);
               this.showDailyBonusGrantPopup(this.getActiveDayReward(this.HARD),this.HARD);
               rewardName = this.getActiveDayReward(this.EASY).friendlyTitle;
               milestoneCount = "Day" + this.activeDayIndex.toString() + "-2";
               FarmStatsManager.count("CocowonderlandInnovation","Milestone",milestoneCount,rewardName,null,dayPoints.toString());
               if(this.mainWindow)
               {
                  this.mainWindow.showEODOverlay1();
               }
               if(this.activeDayIndex == 41)
               {
                  if(featureObj[this.FEATURE_OPTIONS_BONUS_CLAIMED_KEY] == 0)
                  {
                     this.replceIntermediateRewardWithFinalReward();
                  }
               }
            }
            setFeatureData(featureObj);
            this.refreshMainWindow();
         }
      }
      
      public function sinkConsumable() : void
      {
         var consumableNeeded:int = 0;
         var featureObj:Object = null;
         var userState:int = 0;
         if(this.isSinkActive() == true)
         {
            consumableNeeded = this.consumableNeededForUnlock();
            FeatureOptionsInventoryManager.getInstance().removeCount(this.ConsumableCode,consumableNeeded);
            featureObj = this.getFeatureData();
            userState = featureObj[this.KEY_USER_STATE] as int;
            if(userState == this.LOCK1)
            {
               featureObj[this.KEY_USER_STATE] = this.MEDIUM;
            }
            else if(userState == this.LOCK2)
            {
               featureObj[this.KEY_USER_STATE] = this.HARD;
            }
            setFeatureData(featureObj);
            FarmStatsManager.count("CocowonderlandInnovation","sinkConsumable",consumableNeeded.toString(),this.consumableCount.toString());
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkConsumable",null,[m_featureName]),true);
            this.m_orderboardWindow.refreshWindow();
         }
      }
      
      public function hasEnoughConsumableToSink() : Boolean
      {
         var result:Boolean = false;
         if(this.consumableCount >= this.consumableNeededForUnlock())
         {
            result = true;
         }
         return result;
      }
      
      public function isSinkActive() : Boolean
      {
         var result:Boolean = false;
         if(this.isUserLocked() && this.hasEnoughConsumableToSink())
         {
            result = true;
         }
         return result;
      }
      
      public function isUserLocked() : Boolean
      {
         var result:Boolean = false;
         if(this.getUserState() == this.LOCK1 || this.getUserState() == this.LOCK2)
         {
            result = true;
         }
         return result;
      }
      
      public function dumpTask(questIndex:int, callback:Function) : void
      {
         var dumpTimestamp:Object = null;
         if(this.canDumpTask(questIndex))
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"dumpTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
            dumpTimestamp = this.getFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP) as Object;
            if(dumpTimestamp == null)
            {
               dumpTimestamp = new Object();
            }
            dumpTimestamp[questIndex] = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            this.saveFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP,dumpTimestamp);
            this.m_orderboardWindow.refreshWindow();
         }
      }
      
      public function skipDumpedTask(questIndex:int, callback:Function) : void
      {
         var dumpTimestamp:Object = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         if(Global.player.canBuyCash(SKIP_COST))
         {
            Global.player.cash -= SKIP_COST;
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipDumpedTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
            dumpTimestamp = this.getFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP) as Object;
            dumpTimestamp[questIndex] = 0;
            this.saveFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP,dumpTimestamp);
            this.resetActionCountsForTasks(tasks[questIndex]);
            this.m_orderboardWindow.refreshWindow();
         }
         else
         {
            callback.call();
         }
      }
      
      public function canDumpTask(questIndex:int) : Boolean
      {
         var currentTime:Number = NaN;
         var result:Boolean = true;
         var throttleTimeInSeconds:Number = 15 * FarmGameUtil.NUM_SECS_IN_MINUTE;
         var dumpTimestamp:Object = this.getFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP) as Object;
         if(dumpTimestamp != null && dumpTimestamp.hasOwnProperty(questIndex.toString()))
         {
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            result = currentTime - dumpTimestamp[questIndex] > throttleTimeInSeconds;
         }
         return result;
      }
      
      public function isTaskDumpTimeOver(questIndex:int) : Boolean
      {
         var currentTime:Number = NaN;
         var timediff:Number = NaN;
         var result:Boolean = false;
         var throttleTimeInSeconds:Number = 15 * FarmGameUtil.NUM_SECS_IN_MINUTE;
         var dumpTimestamp:Object = this.getFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP) as Object;
         if(dumpTimestamp != null && dumpTimestamp.hasOwnProperty(questIndex.toString()))
         {
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            timediff = throttleTimeInSeconds - (currentTime - dumpTimestamp[questIndex]);
            if(timediff <= 0)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function getTimeRemainingForDumpedTask(questIndex:int) : Number
      {
         var result:Number = NaN;
         var currentTime:Number = NaN;
         var throttleTimeInSeconds:Number = 15 * FarmGameUtil.NUM_SECS_IN_MINUTE;
         var dumpTimestamp:Object = this.getFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP) as Object;
         if(dumpTimestamp != null && dumpTimestamp.hasOwnProperty(questIndex.toString()))
         {
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            result = throttleTimeInSeconds - (currentTime - dumpTimestamp[questIndex]);
         }
         return result;
      }
      
      public function sinkGold(questIndex:int, callback:Function) : void
      {
         var savedTasks:Array = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         if(Global.player.canBuy(tasks[questIndex].total))
         {
            Global.player.gold -= tasks[questIndex].total;
            savedTasks = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
            savedTasks[questIndex][this.KEY_PROGRESS] = tasks[questIndex].total;
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,savedTasks);
            this.grantPointsForTask(tasks[questIndex].questPoints);
            this.postTaskCompletionActions(questIndex);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkGold",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
            StatsManager.count(m_featureName,"Coin Sink","",tasks[questIndex].total.toString(),this.getOrderboardProgress().toString());
         }
         else
         {
            callback.call();
         }
      }
      
      public function sinkBushel(questIndex:int, callback:Function) : void
      {
         var tasks:Vector.<FarmTask> = this.getTasks();
         CraftingManager.getInstance().deductItemFromCraftingInventory(tasks[questIndex].type,tasks[questIndex].total);
         this.postTaskCompletionActions(questIndex);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkBushel",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
         StatsManager.count(m_featureName,"Sink Bushel","",tasks[questIndex].total.toString(),this.getOrderboardProgress().toString());
      }
      
      public function postTaskCompletionActions(completedTaskSlotIndex:int) : void
      {
         var questTasks1:Vector.<FarmTask> = null;
         var featureObject:Object = this.getFeatureData();
         questTasks1 = CocowonderlandInnovationManager.getInstance(m_featureName).getTasks();
         setFeatureData(featureObject);
         if(this.hasActiveDayExpired() == true)
         {
            this.redeemHasStarted = true;
         }
         else
         {
            this.checkAndUpdateUserState();
         }
         var tasks:Vector.<FarmTask> = this.getTasks();
         this.resetActionCountsForTasks(tasks[completedTaskSlotIndex]);
         this.m_orderboardWindow.refreshWindow();
      }
      
      protected function getFeatureOptionsKey(optionName:String) : Object
      {
         var fatureObject:Object = this.getFeatureData();
         return fatureObject[optionName];
      }
      
      protected function saveFeatureOptionsKey(optionName:String, optionsValue:Object) : void
      {
         var fatureObject:Object = this.getFeatureData();
         fatureObject[optionName] = optionsValue;
         setFeatureData(fatureObject);
      }
      
      private function onInitQuestComplete(callback:Function, result:Object) : void
      {
         this.m_resultObject = result;
         if(Boolean(result) && result.hasOwnProperty("featureData"))
         {
            FeatureOptionsManager.getInstance().setFeature(m_featureName,result["featureData"]);
            if(Boolean(callback))
            {
               callback.call();
            }
         }
         if(Boolean(result) && result.hasOwnProperty("activeTasks"))
         {
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,result["activeTasks"]);
            if(Boolean(callback))
            {
               callback.call();
            }
         }
         if(this.orderboardWindow)
         {
            this.orderboardWindow.refreshWindow();
         }
         if(this.mainWindow)
         {
            this.mainWindow.refreshWindow();
         }
      }
      
      protected function parseRewardsDataFromConfig(questName:String) : void
      {
         var orderBoardXml:XML = null;
         var rewardsList:XMLList = null;
         var rewardsByStage:XML = null;
         var str:String = null;
         var rewardsXMLListByStage:XMLList = null;
         this.m_rewardsBySlotName = {};
         orderBoardXml = Global.farmGameSettingsManager.getXML().CocowonderlandInnovationQuests.CocowonderlandInnovationQuest.(@name == questName)[0];
         rewardsList = orderBoardXml.CocowonderlandInnovationRewards.stage;
         for each(rewardsByStage in rewardsList)
         {
            str = rewardsByStage.@id;
            rewardsXMLListByStage = rewardsByStage.rewards;
            this.m_rewardsBySlotName[rewardsByStage.@id] = rewardsXMLListByStage;
         }
      }
      
      public function getRewardsForTheDay() : Vector.<Object>
      {
         var rewardXML:XML = null;
         var rewardObj:Object = null;
         var rewards:Vector.<Object> = new Vector.<Object>();
         if(this.m_rewardsBySlotName == null)
         {
            this.parseRewardsDataFromConfig(this.QUEST_NAME);
         }
         var stageNum:int = this.activeDayIndex;
         var rewardXMLList:XMLList = this.m_rewardsBySlotName[stageNum].reward;
         for each(rewardXML in rewardXMLList)
         {
            rewardObj = FarmGameUtil.xmlNodeToAttributes(rewardXML);
            if(rewards)
            {
               rewards.push(rewardObj);
            }
         }
         return rewards;
      }
      
      public function getTaskProgress(slotIndex:int) : int
      {
         var task:FarmTask = null;
         var buildingFarmItem:FarmItem = null;
         var objects:Array = null;
         var buildingName:String = null;
         var craftingSystem:FeatureCraftingSystem = null;
         var npcData:Object = null;
         var level:int = 0;
         var animalObject:Object = null;
         var progress:int = 0;
         task = this.getTasks()[slotIndex];
         var featureData:Object = this.getFeatureData();
         switch(task.action)
         {
            case "expandStorageBuildingToLevelByCode":
               buildingFarmItem = Global.farmGameSettingsManager.getFarmItemByCode(task.type);
               objects = Global.world.getObjectsByName(buildingFarmItem.name);
               if(objects.length == 1)
               {
                  progress = (objects[0] as FeatureBuilding).storageLevel;
               }
               break;
            case "completeFeatureCraftingNPC":
               buildingName = "xcl_elitehorses";
               craftingSystem = FeatureCraftingManager.instance.getSystem(buildingName);
               if(craftingSystem)
               {
                  npcData = craftingSystem.npcData;
                  level = 0;
                  for each(animalObject in npcData)
                  {
                     if(animalObject.hasOwnProperty("complete"))
                     {
                        if(animalObject["complete"] == true)
                        {
                           level++;
                        }
                     }
                  }
                  if(level >= task.level)
                  {
                     progress = 1;
                  }
               }
               break;
            case "sinkBushel":
               progress = CraftingManager.getInstance().getBushelQuantityInInventory(task.type);
               break;
            default:
               progress = int(featureData[KEY_SAVED_ACTIVE_TASKS][slotIndex][this.KEY_PROGRESS]);
         }
         return progress;
      }
      
      public function getDayPoints() : int
      {
         var dailyPoints:int = 0;
         var featureData:Object = this.getFeatureData();
         if(featureData.hasOwnProperty(this.KEY_DAILY_PROGRESS_POINTS))
         {
            dailyPoints = int(featureData[this.KEY_DAILY_PROGRESS_POINTS][this.activeDayIndex]);
         }
         return dailyPoints;
      }
      
      public function getUserState() : int
      {
         var featureObj:Object = this.getFeatureData();
         return featureObj[this.KEY_USER_STATE] as int;
      }
      
      public function grantUserRewardforLevel(level:int) : void
      {
         FarmStatsManager.count("CocowonderlandInnovation","MileStoneCompletion",this.currentDayIndex.toString(),this.EASY.toString());
         UserRewardUtil.grantUserReward(this.getRewardsForTheDay()[level]);
      }
      
      public function getActiveDayReward(level:int) : FarmItem
      {
         var runesFarmItem:FarmItem = null;
         var rewardCode:String = (this.getRewardsForTheDay()[level] as Object).value;
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_COCOLAND) == false && level == 2 && Global.player.getSeenFlag(this.GA_FEATURE_START) == false)
         {
            runesFarmItem = Global.farmGameSettingsManager.getFarmItemByCode("1v4t");
         }
         else
         {
            runesFarmItem = Global.farmGameSettingsManager.getFarmItemByCode(rewardCode);
            if(!runesFarmItem)
            {
               runesFarmItem = Global.farmGameSettingsManager.getFarmItemByCode("1v4t");
            }
         }
         return runesFarmItem;
      }
      
      public function hasActiveDayExpired() : Boolean
      {
         var expired:Boolean = false;
         var featureData:Object = this.getFeatureData();
         var activeTime:int = int(featureData[this.KEY_ACTIVE_DAY_TIMESTAMP]);
         var currenttime:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(currenttime - activeTime > 86400)
         {
            expired = true;
         }
         return expired;
      }
      
      public function startNewWeek(e:Event = null) : void
      {
         if(this.mainWindow)
         {
            this.mainWindow.refreshWindow();
            this.mainWindow.hideOverlay(e);
         }
      }
      
      public function startNewDay(e:Event = null) : void
      {
         var weekObj:Object = null;
         var curWeek:int = 0;
         var weekObjFirst:Object = null;
         var curWeekFirst:int = 0;
         if(this.mainWindow)
         {
            this.mainWindow.hideOverlay(e);
            this.mainWindow.hideLevelOverlays();
         }
         var featureData:Object = this.getFeatureData();
         if(this.hasActiveDayExpired() == true || featureData[this.KEY_USER_STATE] == this.NOT_INITIALIZED)
         {
            if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_COCOLAND) == false && Global.player.getSeenFlag(this.GA_FEATURE_START) == false)
            {
               Global.player.setSeenFlag(this.GA_FEATURE_START);
               featureData[this.KEY_ORDERBOARD_TASK_POINTS] = 10;
            }
            else if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_COCOLAND) == true && Global.player.getSeenFlag(this.EA_FEATURE_START) == false)
            {
               featureData[this.KEY_ORDERBOARD_TASK_POINTS] = 30;
               Global.player.setSeenFlag(this.EA_FEATURE_START);
            }
            this.redeemHasStarted = false;
            if(this.hasActiveDayExpired())
            {
               featureData[this.KEY_DAILY_PROGRESS_POINTS][this.activeDayIndex] = featureData[this.KEY_DAILY_PROGRESS_POINTS][this.activeDayIndex] > this.VAL_THIRD_MILESTONE ? this.VAL_THIRD_MILESTONE : featureData[this.KEY_DAILY_PROGRESS_POINTS][this.activeDayIndex];
            }
            if(this.hasActiveWeekExpired() && Boolean(this.getCurrentWeek()))
            {
               weekObj = this.getCurrentWeek();
               curWeek = int(weekObj.count);
               if(this.isGAPlayer() && curWeek > 2)
               {
                  this.mainWindow.displayWeekStartMessage();
               }
               else if(!this.isGAPlayer() && curWeek > 1)
               {
                  this.mainWindow.displayWeekStartMessage();
               }
            }
            if(this.hasActiveWeekExpired() || featureData.hasOwnProperty(this.KEY_CURRENT_WEEK) && featureData[this.KEY_CURRENT_WEEK] == 0)
            {
               weekObjFirst = this.getCurrentWeek();
               curWeekFirst = int(weekObjFirst.count);
               featureData[this.KEY_CURRENT_WEEK] = curWeekFirst;
               featureData[this.KEY_ORDERBOARD_COUNT] = 0;
               setFeatureData(featureData);
               this.parseOrderConfigFromConfig();
            }
            this.updateCurrentAverageKey();
            featureData[this.KEY_ACTIVE_DAY_TIMESTAMP] = FarmGameUtil.getMidnightTimestamp() / 1000;
            setFeatureData(featureData);
            if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_COCOLAND))
            {
               if(WorldSeasonsManager.getInstance().isEAWeek(WorldsConstants.WORLD_ID_COCOLAND))
               {
                  featureData[this.KEY_DAILY_PROGRESS_POINTS][this.activeDayIndex] = this.VAL_FIRST_MILESTONE;
                  featureData[this.KEY_USER_STATE] = this.MEDIUM;
               }
               else
               {
                  featureData[this.KEY_USER_STATE] = this.EASY;
               }
               this.checkAndUpdateEarlierEADays();
            }
            else
            {
               featureData[this.KEY_USER_STATE] = this.EASY;
            }
            setFeatureData(featureData);
            if(this.activeDayIndex >= 42)
            {
               featureData[this.KEY_FEATURE_ENDED] = 1;
               setFeatureData(featureData);
               if(this.m_mainWindow)
               {
                  this.m_mainWindow.close();
               }
            }
            this.mainWindow.tintWindow();
            this.mainWindow.enableInput = false;
            FarmStatsManager.count("CocowonderlandInnovation","startNewDay",this.currentDayIndex.toString(),this.overAllProgressLevel().toString());
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startNewDay",this.onStartNewDayDone,[m_featureName]),true);
         }
      }
      
      private function onStartNewDayDone(result:Object) : void
      {
         this.updateData(result);
         this.mainWindow.untintWindow();
         this.mainWindow.enableInput = true;
         this.refreshMainWindow();
      }
      
      public function grantEAandGACoupons() : String
      {
         var coupons:String = "";
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_COCOLAND) == false)
         {
            coupons = "Here are 10 coupons to get you started. Have fun cooking!";
         }
         else
         {
            coupons = "Here are 30 coupons to get you started. Have fun cooking!";
         }
         return coupons;
      }
      
      public function grantEAandGACouponCount() : String
      {
         var coupons:String = "";
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_COCOLAND) == false)
         {
            coupons = "10";
         }
         else
         {
            coupons = "30";
         }
         return coupons;
      }
      
      public function hasActiveWeekExpired() : Boolean
      {
         var activeWeek:int = 0;
         var expired:Boolean = false;
         var featureData:Object = this.getFeatureData();
         var weekData:Object = this.getCurrentWeek();
         var curWeek:int = int(weekData.count);
         if(featureData.hasOwnProperty(this.KEY_CURRENT_WEEK))
         {
            activeWeek = int(featureData[this.KEY_CURRENT_WEEK]);
            if(activeWeek != curWeek)
            {
               expired = true;
            }
         }
         return expired;
      }
      
      public function updateCurrentAverageKey() : void
      {
         var featureConfig:Object = this.getFeatureData();
         featureConfig[this.KEY_CURRENT_AVERAGE] = this.currentAverage;
         setFeatureData(featureConfig);
      }
      
      public function addFTUEOrderPoints() : void
      {
         var featureData:Object = this.getFeatureData();
         if(featureData[KEY_FTUE_ORDER_DONE] == null || featureData[KEY_FTUE_ORDER_DONE] == false.toString())
         {
            this.mainWindow.tintWindow();
            this.mainWindow.enableInput = false;
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"addFTUEOrderPoints",this.onFTUEOrderPointsDone,[m_featureName]),true);
         }
      }
      
      private function onFTUEOrderPointsDone(result:Object) : void
      {
         var featureData:Object = null;
         this.mainWindow.untintWindow();
         this.mainWindow.enableInput = true;
         if(result)
         {
            featureData = this.getFeatureData();
            featureData[KEY_FTUE_ORDER_DONE] = true;
            featureData[this.KEY_DAY_POINTS] += 2;
            setFeatureData(featureData);
            this.mainWindow.showDoober(2);
            this.refreshMainWindow();
         }
      }
      
      private function updateData(result:Object) : void
      {
         var featureData:Object = null;
         if(result)
         {
            featureData = this.getFeatureData();
            if(result[KEY_SAVED_ACTIVE_ORDERS])
            {
               featureData[KEY_SAVED_ACTIVE_ORDERS] = result[KEY_SAVED_ACTIVE_ORDERS];
               setFeatureData(featureData);
               if(this.m_mainWindow)
               {
                  this.m_mainWindow.m_ordersFrame.refresh();
               }
            }
            if(result[KEY_SAVED_STATION_STATES])
            {
               featureData[KEY_SAVED_STATION_STATES] = result[KEY_SAVED_STATION_STATES];
               setFeatureData(featureData);
               if(this.m_mainWindow)
               {
                  this.m_mainWindow.m_stationsFrame.refresh();
               }
            }
            if(result[KEY_SAVED_INGREDIENTS])
            {
               featureData[KEY_SAVED_INGREDIENTS] = result[KEY_SAVED_INGREDIENTS];
               setFeatureData(featureData);
               if(this.m_mainWindow)
               {
                  this.m_mainWindow.m_ingredientsFrame.refresh();
               }
            }
            setFeatureData(featureData);
         }
      }
      
      public function getCurrentWeek() : Object
      {
         var startDate:Number = NaN;
         var endDate:Number = NaN;
         var weekXML:XML = null;
         if(this.hasFeatureExpired())
         {
            return {
               "count":7,
               "end":"",
               "name":"",
               "start":""
            };
         }
         var weekData:Object = this.getWeeksArray();
         var result:Object = null;
         var weekCount:int = 0;
         for each(weekXML in weekData)
         {
            weekCount++;
            if(FarmGameUtil.checkDateGate(weekXML.@start.toString(),weekXML.@end.toString()))
            {
               result = new Object();
               result.name = weekXML.@name.toString();
               result.start = weekXML.@start.toString();
               result.end = weekXML.@end.toString();
               result.count = weekCount;
               break;
            }
         }
         return result;
      }
      
      public function getWeeksArray() : Array
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         return this.m_staticData.weeks;
      }
      
      public function checkAndUpdateEarlierEADays() : void
      {
         var featureData:Object = this.getFeatureData();
         var daysToCheck:int = this.activeDayIndex < 7 ? this.activeDayIndex : 7;
         for(var EADayIndex:int = 0; EADayIndex < daysToCheck; EADayIndex++)
         {
            if(featureData[this.KEY_DAILY_PROGRESS_POINTS].hasOwnProperty(EADayIndex))
            {
               if(featureData[this.KEY_DAILY_PROGRESS_POINTS][EADayIndex] < this.VAL_FIRST_MILESTONE)
               {
                  featureData[this.KEY_DAILY_PROGRESS_POINTS][EADayIndex] = this.VAL_FIRST_MILESTONE;
               }
            }
            else
            {
               featureData[this.KEY_DAILY_PROGRESS_POINTS][EADayIndex] = this.VAL_FIRST_MILESTONE;
            }
         }
         setFeatureData(featureData);
      }
      
      public function get consumableCount() : Number
      {
         return int(FeatureOptionsInventoryManager.getInstance().getCount(this.ConsumableCode));
      }
      
      public function consumableNeededForUnlock() : int
      {
         var consumableNeededForUnlock:int = 0;
         switch(this.getUserState())
         {
            case this.LOCK1:
            case this.EASY:
               consumableNeededForUnlock = 5;
               break;
            case this.LOCK2:
            case this.MEDIUM:
               consumableNeededForUnlock = 10;
               break;
            default:
               consumableNeededForUnlock = 0;
         }
         return consumableNeededForUnlock;
      }
      
      public function rdeemableTaskCount() : int
      {
         var redeemableTaskCount:int = 0;
         var featureData:Object = this.getFeatureData();
         var questTasks1:Vector.<FarmTask> = this.getTasks();
         for(var i:int = 0; i < questTasks1.length; i++)
         {
            if(featureData[KEY_SAVED_ACTIVE_TASKS][i][this.KEY_TASK_ID] != -1)
            {
               if(this.isTaskRedeemable(i))
               {
                  redeemableTaskCount++;
               }
            }
         }
         return redeemableTaskCount;
      }
      
      public function redeemableStationOrders() : int
      {
         var redeemableStationOrder:int = 0;
         var featureData:Object = this.getFeatureData();
         var stations:Array = featureData[KEY_SAVED_STATION_STATES];
         for(var i:int = 0; i < stations.length; i++)
         {
            if(this.isCookDone(i))
            {
               redeemableStationOrder++;
            }
         }
         return redeemableStationOrder;
      }
      
      public function isTaskRedeemable(slotIndex:int) : Boolean
      {
         var result:Boolean = false;
         var progress:int = this.getTaskProgress(slotIndex);
         var task:FarmTask = this.getTasks()[slotIndex];
         if(progress >= task.total)
         {
            result = true;
         }
         return result;
      }
      
      public function isMilestoneAchievedForLevel(level:int) : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(featureData[this.KEY_DAILY_PROGRESS_POINTS][this.activeDayIndex] >= this.VAL_MILESTONE_POINTS_ARRAY[level])
         {
            result = true;
         }
         return result;
      }
      
      public function getTimeLeftInDay() : Number
      {
         var dayExpiredTime:Number = FarmGameUtil.getMidnightTimestamp() / 1000 + 86400;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return dayExpiredTime - currenttime;
      }
      
      public function getSinkButtonToolTipMessage() : String
      {
         var msg:String = "";
         if(!this.hasActiveDayExpired())
         {
            if(this.isUserLocked() != false)
            {
               if(this.hasEnoughConsumableToSink() == false)
               {
                  msg = "Collect more Karnaval Tickets to unlock the next level.";
               }
               else
               {
                  msg = "Exchange Karnaval Tickets to unlock the next level.";
               }
            }
         }
         return msg;
      }
      
      public function openViewProgressWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.enableInput = false;
         }
         this.m_progressWindow = new CocowonderlandInnovationProgressWindow(this.progressWindowURL);
         UI.displayPopup(this.m_progressWindow,false);
      }
      
      public function overAllProgressLevel() : int
      {
         var progressLevel:int = -1;
         var avg:int = this.currentAverage;
         if(avg >= 30)
         {
            progressLevel = 2;
         }
         else if(avg >= 15)
         {
            progressLevel = 1;
         }
         else if(avg >= 5)
         {
            progressLevel = 0;
         }
         else
         {
            progressLevel = -1;
         }
         return progressLevel;
      }
      
      public function get currentAverage() : int
      {
         var totalDaysForAvg:int = this.currentDayIndex > 41 ? 42 : int(this.currentDayIndex + 1);
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_COCOLAND) == false)
         {
            totalDaysForAvg -= 7;
         }
         else if(totalDaysForAvg > 35)
         {
            totalDaysForAvg = 35;
         }
         return int(this.getTotalPointsForUser() / totalDaysForAvg);
      }
      
      public function get weekMenuNumber() : String
      {
         var weekObj:* = this.getCurrentWeek();
         var weekCount:int = this.isGAPlayer() ? int(weekObj.count - 1) : int(weekObj.count);
         return "Week " + weekCount.toString();
      }
      
      public function get weekMenuName() : String
      {
         var weekObj:* = this.getCurrentWeek();
         var weekCount:int = int(weekObj.count);
         return WEEK_MENU[weekCount - 1];
      }
      
      public function get stationNameAtWeekStart() : String
      {
         var weekObj:* = this.getCurrentWeek();
         var weekCount:int = weekObj.count - 1;
         return WEEK_MENU[weekCount] + " Week";
      }
      
      public function get weekCountAtStart() : int
      {
         var weekObj:* = this.getCurrentWeek();
         return int(weekObj.count - 1);
      }
      
      public function getTotalPointsForUser() : int
      {
         var totalPoints:int = 0;
         var featureData:Object = this.getFeatureData();
         for(var index:int = 0; index < this.activeDayIndex; index++)
         {
            if(featureData[this.KEY_DAILY_PROGRESS_POINTS].hasOwnProperty(index))
            {
               totalPoints += int(featureData[this.KEY_DAILY_PROGRESS_POINTS][index]);
            }
         }
         if(featureData.hasOwnProperty(this.KEY_DAILY_PROGRESS_POINTS))
         {
            totalPoints += int(featureData[this.KEY_DAILY_PROGRESS_POINTS][this.activeDayIndex]) > 35 ? 35 : featureData[this.KEY_DAILY_PROGRESS_POINTS][this.activeDayIndex];
         }
         return totalPoints;
      }
      
      public function setDayTime() : void
      {
         var featureData:Object = this.getFeatureData();
         featureData[this.KEY_ACTIVE_DAY_TIMESTAMP] = FarmGameUtil.getMidnightTimestamp() / 1000;
      }
      
      public function get mainWindow() : CocowonderlandInnovationMainWindow
      {
         return this.m_mainWindow;
      }
      
      public function get orderboardWindow() : CocowonderlandInnovationOrderboardWindow
      {
         return this.m_orderboardWindow;
      }
      
      public function refreshMainWindow() : void
      {
         if(this.mainWindow != null)
         {
            this.m_mainWindow.refreshWindow();
         }
      }
      
      public function get activeDayIndex() : int
      {
         var dayIndex:int = 0;
         var featureData:Object = this.getFeatureData();
         var activeDayTS:Number = featureData[this.KEY_ACTIVE_DAY_TIMESTAMP] as Number;
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber(this.featureStartDate) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         dayIndex = (activeDayTS - featureStartDayTS) / FarmGameUtil.NUM_SECS_IN_DAY;
         if(dayIndex < 0)
         {
            dayIndex = 0;
         }
         return dayIndex;
      }
      
      public function get currentDayIndex() : int
      {
         var dayIndex:int = 0;
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber(this.featureStartDate);
         dayIndex = (GlobalEngine.serverTime - featureStartDayTS) / FarmGameUtil.NUM_MSECS_IN_DAY;
         if(dayIndex < 0)
         {
            dayIndex = 0;
         }
         return dayIndex;
      }
      
      public function get bonusRewardsArray() : Array
      {
         return ["2901","28qe","28zr"];
      }
      
      public function getpointsForTheDay(index:int) : int
      {
         var points:int = 0;
         var featureData:Object = this.getFeatureData();
         if(featureData[this.KEY_DAILY_PROGRESS_POINTS].hasOwnProperty(index.toString()))
         {
            points = int(featureData[this.KEY_DAILY_PROGRESS_POINTS][index.toString()]);
         }
         return points;
      }
      
      public function canShowfinalRewardWindow() : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(featureData[this.FEATURE_OPTIONS_BONUS_CLAIMED_KEY] == 0)
         {
            result = true;
         }
         return result;
      }
      
      public function IsBonusBuildingReadyToHarvest() : Boolean
      {
         var result:Boolean = false;
         if(this.getTimeLeftForBonusHarvest() <= 0)
         {
            result = true;
         }
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("cocowonderland_innovation_bonus_enabled");
         if(!PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            result = false;
         }
         return result;
      }
      
      public function getTimeLeftForBonusHarvest() : int
      {
         var timeLeft:int = 0;
         var key:String = LAST_BONUS_HARVEST_TIME_KEY;
         var throttleTime:int = DEFAULT_HARVEST_THROTTLE_TIME;
         return this.getTimeLeft(key,throttleTime);
      }
      
      public function HighlightBonusBuilding() : void
      {
         var bonusCode:String = null;
         var bonusFarmItem:FarmItem = null;
         var buildObjectsArray:Array = null;
         var featureData:Object = this.getFeatureData();
         if(featureData.hasOwnProperty(this.FEATURE_OPTIONS_BONUS_CODE_KEY))
         {
            bonusCode = featureData[this.FEATURE_OPTIONS_BONUS_CODE_KEY];
            bonusFarmItem = Global.farmGameSettingsManager.getFarmItemByCode(bonusCode);
            buildObjectsArray = Global.world.getObjectsByName(bonusFarmItem.name);
            if(Boolean(buildObjectsArray) && buildObjectsArray.length > 0)
            {
               ItemFinderManager.getInstance().highlightWorldItems(bonusFarmItem.name);
            }
         }
      }
      
      public function isGAPlayer() : Boolean
      {
         return !WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_COCOLAND);
      }
      
      public function isBoosterApplied() : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(featureData[this.KEY_BOOSTER_APPLIED] == 1)
         {
            result = true;
         }
         return result;
      }
      
      public function onRedeemStarted() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onRedeemStarted",null,[m_featureName]),true);
      }
      
      public function isNewWeekStarting() : Boolean
      {
         var result:Boolean = false;
         var dayCount:int = this.activeDayIndex;
         var isWeekStart:int = dayCount % 7;
         if(isWeekStart == 0)
         {
            result = true;
         }
         return result;
      }
      
      public function get redeemHasStarted() : Boolean
      {
         return this._redeemHasStarted;
      }
      
      public function set redeemHasStarted(value:Boolean) : void
      {
         this._redeemHasStarted = value;
      }
      
      public function get redeemMessageShown() : Boolean
      {
         return this._redeemMessageShown;
      }
      
      public function set redeemMessageShown(value:Boolean) : void
      {
         this._redeemMessageShown = value;
      }
      
      public function set mainWindow(mainWindowInstance:CocowonderlandInnovationMainWindow) : void
      {
         this.m_mainWindow = mainWindowInstance;
      }
      
      public function set orderboardWindow(orderboardWindowInstance:CocowonderlandInnovationOrderboardWindow) : void
      {
         this.m_orderboardWindow = orderboardWindowInstance;
      }
      
      public function getDayEndMessageShown() : int
      {
         var featureData:Object = this.getFeatureData();
         return featureData[KEY_FLUSH_DAILY_REWARD_TASK];
      }
      
      public function areStationsFree() : Boolean
      {
         var featureData:Object = this.getFeatureData();
         var result:Boolean = false;
         var isFree:int = 0;
         for(var index:int = 0; index < 3; index++)
         {
            if(featureData[KEY_SAVED_STATION_STATES][index][KEY_COOK_TIME_START] == 0 && featureData[KEY_SAVED_STATION_STATES][index][KEY_STATE] == STATION_STATES[STATION_STATE_UNLOCKED])
            {
               isFree++;
            }
         }
         if(isFree > 0)
         {
            result = true;
         }
         return result;
      }
      
      public function areStationsBusy() : Boolean
      {
         var featureData:Object = this.getFeatureData();
         var result:Boolean = false;
         var isBusy:int = 0;
         for(var index:int = 0; index < 3; index++)
         {
            if(featureData[KEY_SAVED_STATION_STATES][index][KEY_COOK_TIME_START] > 0 && featureData[KEY_SAVED_STATION_STATES][index][KEY_STATE] == STATION_STATES[STATION_STATE_UNLOCKED])
            {
               isBusy++;
            }
         }
         if(isBusy > 0)
         {
            result = true;
         }
         return result;
      }
      
      public function isBonusHarvestExpired() : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("5/29/2019") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         timeLeft = endTime - now;
         if(timeLeft <= 0)
         {
            result = true;
         }
         return result;
      }
      
      public function isCookDone(slotNumber:int) : Boolean
      {
         var now:int = 0;
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(featureData[KEY_SAVED_STATION_STATES][slotNumber][KEY_COOK_TIME_START] > 0)
         {
            now = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            result = now - featureData[KEY_SAVED_STATION_STATES][slotNumber][KEY_COOK_TIME_START] >= this.m_cookTime;
         }
         return result;
      }
      
      public function checkAndAddToStation(ingredient:XML) : Boolean
      {
         var result:Boolean = false;
         if(this.m_mainWindow)
         {
            result = this.m_mainWindow.m_stationsFrame.checkAndAddIngredientToSlot(ingredient);
         }
         return result;
      }
      
      public function dummyAddIngredients() : void
      {
         var ingredientList:Vector.<XML> = this.getIngredients();
         for(var i:* = 0; i < 4; i++)
         {
            this.checkAndAddToStation(ingredientList[i]);
         }
      }
      
      public function isStationAvailable() : Boolean
      {
         var result:Boolean = false;
         if(this.m_mainWindow)
         {
            result = this.m_mainWindow.m_stationsFrame.isStationAvailable();
         }
         return result;
      }
      
      public function isStationLocked(slotNum:int) : Boolean
      {
         var stationData:Array = this.getStationsInfo();
         var isUnlocked:Boolean = false;
         if(Boolean(stationData) && Boolean(stationData[slotNum]))
         {
            if(stationData[slotNum][KEY_STATE] == STATION_STATES[STATION_STATE_LOCKED])
            {
               isUnlocked = true;
            }
         }
         return isUnlocked;
      }
      
      public function buyIngredient(ingredient:XML, slotNumber:Number) : Boolean
      {
         var couponsRequired:int = int(ingredient["@coupons"]);
         var couponsAvailable:int = this.getOrderboardProgress();
         var ingredientName:String = ingredient["@name"];
         if(couponsAvailable >= couponsRequired)
         {
            this.m_mainWindow.m_ingredientsFrame.disableBuyButtonForSlot(slotNumber,couponsAvailable - couponsRequired,couponsRequired);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,this.SERVICE_FUNC_BUY_INGREDIENT,this.onBuyIngredientDone,[m_featureName,slotNumber,ingredientName]),true);
            return true;
         }
         return false;
      }
      
      private function onBuyIngredientDone(result:Object = null) : void
      {
         var featureData:Object = null;
         var taskPoints:int = 0;
         var quantity:int = 0;
         var coupons:int = 0;
         var ingName:String = null;
         var ingCount:int = 0;
         if(result)
         {
            if(Boolean(this.m_mainWindow) && Boolean(this.m_mainWindow.m_ingredientsFrame))
            {
               featureData = this.getFeatureData();
               taskPoints = parseInt(featureData[this.KEY_ORDERBOARD_TASK_POINTS]);
               quantity = parseInt(featureData[KEY_SAVED_INGREDIENTS][result["name"]]);
               coupons = parseInt(this.m_IngredientsByName[result[KEY_NAME]]["@coupons"]);
               quantity += 1;
               taskPoints -= coupons;
               featureData[this.KEY_ORDERBOARD_TASK_POINTS] = taskPoints;
               featureData[KEY_SAVED_INGREDIENTS][result["name"]] = quantity;
               setFeatureData(featureData);
               this.m_mainWindow.m_ingredientsFrame.onBuyIngredientDone(result);
               this.m_mainWindow.refreshCouponCount();
               ingName = result["name"];
               ingCount = parseInt(featureData[KEY_SAVED_INGREDIENTS][result["name"]]);
               StatsManager.count(m_featureName,"PurchaseIngredient",ingName,ingCount.toString(),this.getDayPoints().toString(),this.getOrderboardProgress().toString(),coupons);
            }
         }
      }
      
      public function updateIngredientSlot(ingredient:XML) : void
      {
         if(Boolean(this.mainWindow) && Boolean(this.mainWindow.m_ingredientsFrame))
         {
            this.m_mainWindow.m_ingredientsFrame.updateIngredientSlot(ingredient);
         }
      }
      
      public function startCooking(slotNumber:int, ingredientsArray:Array) : void
      {
         var jsonString:String = by.blooddy.crypto.serialization.JSON.encode(ingredientsArray);
         var params:Array = [m_featureName,slotNumber,jsonString];
         this.mainWindow.tintWindow();
         this.mainWindow.enableInput = false;
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,this.SERVICE_FUNC_START_COOKING,this.onStartCookingDone,params),true);
         StatsManager.count(m_featureName,"Cooking Start",slotNumber.toString(),null,this.activeDayIndex.toString(),null,this.getDayPoints());
      }
      
      public function onStartCookingDone(result:Object = null) : void
      {
         var featureData:Object = null;
         var slotNumber:int = 0;
         var cookTimeStart:int = 0;
         var ingredients:Array = null;
         var index:int = 0;
         var ingredient:String = null;
         var obj:XML = null;
         this.mainWindow.untintWindow();
         this.mainWindow.enableInput = true;
         if(result)
         {
            featureData = this.getFeatureData();
            slotNumber = parseInt(result["slotNumber"]);
            cookTimeStart = parseInt(result[KEY_COOK_TIME_START]);
            ingredients = result[KEY_INGREDIENT_LIST];
            index = 0;
            for each(ingredient in ingredients)
            {
               obj = new XML(ingredient);
               featureData[KEY_SAVED_STATION_STATES][slotNumber][KEY_INGREDIENTS][index] = obj["@name"];
               featureData[KEY_SAVED_INGREDIENTS][obj["@name"]] = featureData[KEY_SAVED_INGREDIENTS][obj["@name"]] - 1;
               index++;
            }
            featureData[KEY_SAVED_STATION_STATES][slotNumber][KEY_COOK_TIME_START] = cookTimeStart;
            if(result.hasOwnProperty(KEY_COOKED_ORDER))
            {
               featureData[KEY_SAVED_STATION_STATES][slotNumber][KEY_COOKED_ORDER] = result[KEY_COOKED_ORDER];
            }
            setFeatureData(featureData);
            this.m_mainWindow.m_stationsFrame.onStartCooking(slotNumber,result[KEY_COOKED_ORDER],cookTimeStart);
         }
      }
      
      public function isCookingInProgress(stationNum:int) : Boolean
      {
         var stationsData:Array = this.getStationsInfo();
         var isCooking:Boolean = false;
         if(Boolean(stationsData) && Boolean(stationsData[stationNum]))
         {
            if(stationsData[stationNum][KEY_COOK_TIME_START] > 0)
            {
               isCooking = true;
            }
         }
         return isCooking;
      }
      
      public function onComplete(slotNumber:int) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onCompleteCooking",this.onCompleteCooking,[m_featureName,slotNumber]),true);
      }
      
      public function onCompleteCooking(result:Object) : void
      {
         var featureData:Object = this.getFeatureData();
         var slotNumber:int = parseInt(result["slotNumber"]);
         var cookTimeStart:int = parseInt(result[KEY_COOK_TIME_START]);
         featureData[KEY_SAVED_STATION_STATES][slotNumber][KEY_COOK_TIME_START] = cookTimeStart;
         setFeatureData(featureData);
         StatsManager.count(m_featureName,"Cooking End",slotNumber.toString(),null,this.activeDayIndex.toString(),null,this.getDayPoints());
         this.m_mainWindow.m_stationsFrame.refresh();
      }
      
      public function onServe(slotNumber:int, cookedOrder:String) : void
      {
         this.m_mainWindow.m_ordersFrame.playAnimation(cookedOrder);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onServe",this.onCompleteServe,[m_featureName,slotNumber]),true);
      }
      
      public function onCompleteServe(result:Object) : void
      {
         var slotNumber:int = 0;
         var featureData:Object = null;
         var cookedOrder:String = null;
         var dimes:int = 0;
         if(result)
         {
            slotNumber = int(result["slotNumber"]);
            featureData = this.getFeatureData();
            featureData[KEY_SAVED_STATION_STATES][slotNumber] = {};
            featureData[KEY_SAVED_STATION_STATES][slotNumber][KEY_STATE] = STATION_STATES[STATION_STATE_UNLOCKED];
            featureData[KEY_SAVED_STATION_STATES][slotNumber][KEY_INGREDIENTS] = [];
            featureData[KEY_SAVED_STATION_STATES][slotNumber][KEY_COOK_TIME_START] = 0;
            featureData[KEY_SAVED_STATION_STATES][slotNumber][KEY_COOKED_ORDER] = "";
            setFeatureData(featureData);
            this.m_mainWindow.m_stationsFrame.refreshSlot(slotNumber);
            if(result.hasOwnProperty("cookedOrder"))
            {
               cookedOrder = result["cookedOrder"];
               dimes = int(this.m_OrdersByName[cookedOrder]["@dimes"]);
               featureData[this.KEY_DAILY_PROGRESS_POINTS][this.activeDayIndex] += dimes;
               if(Boolean(this.m_mainWindow) && Boolean(this.m_mainWindow.m_dooberMc))
               {
                  this.m_mainWindow.showDoober(dimes);
               }
               if(this.m_mainWindow)
               {
                  this.m_mainWindow.updateEarnedPoints();
                  this.m_mainWindow.updateProgressBar();
               }
               setFeatureData(featureData);
               this.checkAndUpdateUserState();
               StatsManager.count(m_featureName,"Serve",cookedOrder + ":" + slotNumber,this.activeDayIndex.toString(),null,this.getDayPoints().toString(),dimes);
            }
            else if(Boolean(this.m_mainWindow) && Boolean(this.m_mainWindow.m_duplicateMc))
            {
               this.m_mainWindow.showDuplicateOrderOverlay();
            }
            this.updateData(result);
         }
      }
   }
}

