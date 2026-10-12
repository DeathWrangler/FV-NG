package Managers
{
   import Classes.Constants.ArrowType;
   import Classes.Constants.Experiments;
   import Classes.Constants.QuestConstants;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureBuilding;
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import Display.HUD.HUD;
   import Display.QueuedIcons.FeatureQueuedIcon;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import Events.TileUnlockEvent;
   import Managers.Crafting.CraftingManager;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FeaturePackagesBuyWindow;
   import Widgets.Windows.TuscanyInnovationDailyBonusGrantWindow;
   import Widgets.Windows.TuscanyInnovationFinalRewardWindow;
   import Widgets.Windows.TuscanyInnovationMainWindow;
   import Widgets.Windows.TuscanyInnovationPostBonusHarvestWindow;
   import Widgets.Windows.TuscanyInnovationRewardWindow;
   import Widgets.Windows.TuscanyInnovationTileUnlockwindow;
   import flash.events.Event;
   
   public class TuscanyInnovationManager extends BaseFeatureManager
   {
      
      public static const HUD_INITIALISATION_FLAG:String = "tuscany_innovation_hud_initialise_flag";
      
      public static const FEATURE_NAME:String = "TuscanyInnovation";
      
      private static const WINDOW_MAIN:String = "main";
      
      private static const WINDOW_REWARD:String = "reward";
      
      private static const WINDOW_CONGRATS:String = "congrats";
      
      private static const WINDOW_BUY:String = "buyDialog";
      
      public static const COLLECT_TIME_KEY:String = "ctk";
      
      public static const FEED_NAME:String = "TuscanyInnovationUI";
      
      public static const FEATURE_OPTIONS_KEY:String = "TuscanyInnovation";
      
      private static var m_initialized:Boolean = false;
      
      private static const SKIP_COST:int = 1;
      
      private static const KEY_SAVED_ACTIVE_TASKS:String = "1";
      
      private static const KEY_SAVED_DUMPED_TIMESTAMP:String = "3";
      
      private static const SERVICE_NAME:String = "TuscanyInnovationService";
      
      private static const LAST_BONUS_HARVEST_TIME_KEY:String = "xty_bht";
      
      public static const DEFAULT_HARVEST_THROTTLE_TIME:Number = 86400;
      
      private static const CRAFTSHOP_CONSUMABLE_TAB:String = "consumable";
      
      private static const BONUS_HARVEST_COUNT:String = "hc";
      
      private static const BONUS_COUNT_MAP:Object = {
         "goodwinery":4,
         "betterwinery":5,
         "bestwinery":6
      };
      
      public const DEFAULT_THROTTLE_TIME:Number = 86400;
      
      private var m_assetPaths:Object = null;
      
      protected var m_staticData:Object;
      
      private var m_mainWindow:TuscanyInnovationMainWindow;
      
      public const VAL_FIRST_MILESTONE:int = 10;
      
      public const VAL_SECOND_MILESTONE:int = 20;
      
      public const VAL_THIRD_MILESTONE:int = 35;
      
      protected const KEY_PROGRESS:String = "progress";
      
      protected const KEY_TOTAL:String = "total";
      
      private var m_resultObject:Object;
      
      private const QUEST_NAME:String = "TuscanyInnovation";
      
      private const KEY_LAST_TASKS_IDS:String = "2";
      
      private const KEY_MISC_EASY:String = "M1";
      
      private const KEY_MISC_MEDIUM:String = "M2";
      
      private const KEY_MISC_HARD:String = "M3";
      
      private const KEY_BB:String = "BB";
      
      private const KEY_EH:String = "EH";
      
      private const KEY_HB:String = "HB";
      
      private const KEY_TASK_PROGRESS:String = "progress";
      
      private const KEY_TASK_ID:String = "id";
      
      private const KEY_TASK_TYPE:String = "type";
      
      private const KEY_LAST_USED_TYPE:String = "lt";
      
      private var m_tasksByTypes:Object = null;
      
      private const KEY_USER_STATE:String = "state";
      
      private var taskTypesArray:Array = [["M1","M1","HB","EH","M1","M1","M1","M1","M1","BB"],["M2","M2","HB","EH","M2","M2","M2","M2","M2","BB"],["M3","M3","HB","EH","M3","M3","M3","M3","M3","BB"]];
      
      private const KEY_DUMPED_STATUS:String = "dump_status";
      
      private const KEY_DAY_POINTS:String = "dp";
      
      public const EASY:int = 0;
      
      public const MEDIUM:int = 1;
      
      public const HARD:int = 2;
      
      public const LOCK1:int = 3;
      
      public const LOCK2:int = 4;
      
      public const DONE_FOR_THE_DAY:int = 5;
      
      public const NOT_INITIALIZED:int = -1;
      
      private const KEY_DAILY_PROGRESS_POINTS:String = "pts";
      
      private const FEATURE_OPTIONS_BONUS_CLAIMED_KEY:String = "bonus";
      
      private const KEY_BOOSTER_APPLIED:String = "booster";
      
      private const KEY_FEATURE_ENDED:String = "finished";
      
      private const KEY_ACTIVE_DAY_TIMESTAMP:String = "ts";
      
      private var m_rewardWindow:TuscanyInnovationRewardWindow;
      
      private var m_finalRewardWindow:TuscanyInnovationFinalRewardWindow;
      
      private const KEY_TASK_LEVEL:String = "taskLevel";
      
      private const FEATURE_OPTIONS_BONUS_CODE_KEY:String = "bonusCode";
      
      private var m_rewardsBySlotName:Object = null;
      
      public const VAL_MILESTONE_POINTS_ARRAY:Array = [10,20,35];
      
      private const VAL_CLASSIC:int = 30;
      
      private const VAL_SUPERB:int = 15;
      
      private const VAL_GOOD:int = 5;
      
      private const SERVICE_FUNC_HARVEST_BONUS:String = "harvestBonusBuilding";
      
      private const SERVICE_FUNC_APPLY_BOOSTER:String = "applyBooster";
      
      public const WINERY_BOOSTER_CODE:String = "1pwk";
      
      private const SERVICE_FUNC_GRANT_BONUS:String = "grantBonus";
      
      private const EVENT_WW_INNOVATION_TILE_UNLOCK:String = "TuscanyInnovationTileUnlock";
      
      public const CRUSH_BARREL_TUTORIAL:String = "TuscanyInnovationSinkTutorial";
      
      public const FIRST_SESSION_TUTORIAL:String = "TIFirstSessionTutorial";
      
      private var BONUS_HARVEST_ARRAY:Array = ["consume_organic_fertilizer","consume_unwither","consume_farm_hands","fuel1","consume_instagrow","consume_turbo_charger"];
      
      private var _redeemHasStarted:Boolean = false;
      
      public function TuscanyInnovationManager(featureName:String, featureConfig:XML = null)
      {
         super(featureName,featureConfig);
         this.parseTaskObjectsFromConfig(this.QUEST_NAME);
         this.parseRewardsDataFromConfig(this.QUEST_NAME);
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
      }
      
      public static function getInstance(featureName:String = "TuscanyInnovation") : TuscanyInnovationManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,TuscanyInnovationManager) as TuscanyInnovationManager;
      }
      
      protected function onTransactionAdded(event:TransactionEvent) : void
      {
         this.checkForTaskUpdates(event);
      }
      
      protected function parseTaskObjectsFromConfig(questName:String) : void
      {
         var index:int = 0;
         var taskType:String = null;
         var orderBoardXml:XML = null;
         var tasksByDifficultyList:XMLList = null;
         var tasksByDiff:XML = null;
         var tasksByDiffAndTypeList:XMLList = null;
         var tasksByDiffAndType:XML = null;
         var taskXML:XML = null;
         this.m_tasksByTypes = {};
         index = 0;
         orderBoardXml = Global.farmGameSettingsManager.getXML().orderBoards.orderBoard.(@name == questName)[0];
         if(orderBoardXml)
         {
            tasksByDifficultyList = orderBoardXml.orderBoardTasks;
            for each(tasksByDiff in tasksByDifficultyList)
            {
               tasksByDiffAndTypeList = tasksByDiff.tasks;
               for each(tasksByDiffAndType in tasksByDiffAndTypeList)
               {
                  index = 0;
                  taskType = tasksByDiffAndType.@type.toString();
                  this.m_tasksByTypes[taskType] = {};
                  for each(taskXML in tasksByDiffAndType.task)
                  {
                     this.m_tasksByTypes[taskType][index] = taskXML;
                     index++;
                  }
               }
            }
         }
      }
      
      public function generateAndSaveNewTask(slotIndex:int) : void
      {
         var nextTaskType:String = null;
         var nextTaskId:int = 0;
         var created:Boolean = false;
         var activeTaskCheck:Boolean = false;
         var taskLevelCheck:Boolean = false;
         var nonBuildingTask:Boolean = false;
         var lastUsedtaskTypeIndexInUserState:int = 0;
         var nextUsedtaskTypeIndexInUserState:int = 0;
         var taskType:String = null;
         var i:int = 0;
         var id:int = 0;
         var fatureObject:Object = this.getFeatureData();
         var userState:int = int(fatureObject[this.KEY_USER_STATE]);
         if(userState > this.HARD || this.hasActiveDayExpired())
         {
            nextTaskType = null;
            nextTaskId = -1;
         }
         else
         {
            created = false;
            activeTaskCheck = true;
            taskLevelCheck = true;
            nonBuildingTask = false;
            lastUsedtaskTypeIndexInUserState = int(fatureObject[this.KEY_LAST_USED_TYPE][userState]);
            while(created == false)
            {
               nextUsedtaskTypeIndexInUserState = (lastUsedtaskTypeIndexInUserState + 1) % 10;
               taskType = this.taskTypesArray[userState][nextUsedtaskTypeIndexInUserState];
               if(taskType == "BB" || taskType == "HB" || taskType == "EH")
               {
                  for(i = 0; i < 4; i++)
                  {
                     if(fatureObject[KEY_SAVED_ACTIVE_TASKS][i][this.KEY_TASK_TYPE] == taskType)
                     {
                        activeTaskCheck = false;
                        break;
                     }
                  }
                  switch(taskType)
                  {
                     case "BB":
                        if(userState == this.EASY && fatureObject[this.KEY_LAST_TASKS_IDS][taskType] >= 2)
                        {
                           taskLevelCheck = false;
                        }
                        if(userState == this.MEDIUM && fatureObject[this.KEY_LAST_TASKS_IDS][taskType] >= 5)
                        {
                           taskLevelCheck = false;
                        }
                        if(userState == this.MEDIUM && fatureObject[this.KEY_LAST_TASKS_IDS][taskType] < 2)
                        {
                           taskLevelCheck = false;
                        }
                        if(userState == this.HARD && fatureObject[this.KEY_LAST_TASKS_IDS][taskType] < 5)
                        {
                           taskLevelCheck = false;
                        }
                        if(fatureObject[this.KEY_LAST_TASKS_IDS][taskType] >= 8)
                        {
                           taskLevelCheck = false;
                        }
                        break;
                     case "HB":
                        if(userState == this.EASY && fatureObject[this.KEY_LAST_TASKS_IDS][taskType] >= 9)
                        {
                           taskLevelCheck = false;
                        }
                        if(userState == this.MEDIUM && fatureObject[this.KEY_LAST_TASKS_IDS][taskType] >= 19)
                        {
                           taskLevelCheck = false;
                        }
                        if(userState == this.MEDIUM && fatureObject[this.KEY_LAST_TASKS_IDS][taskType] < 9)
                        {
                           taskLevelCheck = false;
                        }
                        if(userState == this.HARD && fatureObject[this.KEY_LAST_TASKS_IDS][taskType] < 19)
                        {
                           taskLevelCheck = false;
                        }
                        if(fatureObject[this.KEY_LAST_TASKS_IDS][taskType] >= 29)
                        {
                           taskLevelCheck = false;
                        }
                        break;
                     case "EH":
                        if(userState == this.EASY && fatureObject[this.KEY_LAST_TASKS_IDS][taskType] >= 4)
                        {
                           taskLevelCheck = false;
                        }
                        if(userState == this.MEDIUM && fatureObject[this.KEY_LAST_TASKS_IDS][taskType] >= 9)
                        {
                           taskLevelCheck = false;
                        }
                        if(userState == this.MEDIUM && fatureObject[this.KEY_LAST_TASKS_IDS][taskType] < 4)
                        {
                           taskLevelCheck = false;
                        }
                        if(userState == this.HARD && fatureObject[this.KEY_LAST_TASKS_IDS][taskType] < 9)
                        {
                           taskLevelCheck = false;
                        }
                        if(fatureObject[this.KEY_LAST_TASKS_IDS][taskType] >= 14)
                        {
                           taskLevelCheck = false;
                        }
                  }
                  if(taskLevelCheck == false || activeTaskCheck == false)
                  {
                     created = false;
                     lastUsedtaskTypeIndexInUserState++;
                  }
                  else
                  {
                     created = true;
                  }
               }
               else
               {
                  if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TUSCANY_INNOVATION_TASK_V2) == 2)
                  {
                     nonBuildingTask = true;
                     id = (fatureObject[this.KEY_LAST_TASKS_IDS][taskType] + 1) % 200;
                     while(this.isSameTaskActive(taskType,id) == true)
                     {
                        id = (id + 1) % 200;
                     }
                  }
                  created = true;
               }
            }
            nextTaskType = taskType;
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TUSCANY_INNOVATION_TASK_V2) == 2)
            {
               if(nonBuildingTask == false)
               {
                  nextTaskId = (fatureObject[this.KEY_LAST_TASKS_IDS][nextTaskType] + 1) % 200;
               }
               else
               {
                  nextTaskId = id;
               }
            }
            else
            {
               nextTaskId = (fatureObject[this.KEY_LAST_TASKS_IDS][nextTaskType] + 1) % 200;
            }
            fatureObject[this.KEY_LAST_USED_TYPE][userState] = nextUsedtaskTypeIndexInUserState;
            fatureObject[this.KEY_LAST_TASKS_IDS][nextTaskType] = nextTaskId;
         }
         fatureObject[KEY_SAVED_ACTIVE_TASKS][slotIndex][this.KEY_TASK_TYPE] = nextTaskType;
         fatureObject[KEY_SAVED_ACTIVE_TASKS][slotIndex][this.KEY_TASK_ID] = nextTaskId;
         fatureObject[KEY_SAVED_ACTIVE_TASKS][slotIndex][this.KEY_TASK_PROGRESS] = 0;
         fatureObject[KEY_SAVED_ACTIVE_TASKS][slotIndex][this.KEY_TASK_LEVEL] = fatureObject[this.KEY_USER_STATE];
         setFeatureData(fatureObject);
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
      
      public function isSameTaskActive(taskType:String, taskIndex:int) : Boolean
      {
         var taskXML:XML = null;
         var farmTask:FarmTask = null;
         var taskObj:Object = null;
         var result:Boolean = false;
         var tasks:Vector.<FarmTask> = this.getActiveTasks();
         taskXML = this.m_tasksByTypes[taskType][taskIndex];
         taskObj = FarmGameUtil.xmlNodeToAttributes(taskXML);
         taskObj.questName = m_featureName;
         farmTask = new FarmTask(taskObj);
         for(var i:int = 0; i < tasks.length; i++)
         {
            if(Boolean(tasks[i] && farmTask) && Boolean(farmTask.action != "DummyTask") && tasks[i].action != "DummyTask")
            {
               if(tasks[i].type == farmTask.type)
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      public function highlightTiles() : void
      {
         UI.displayMiniMarketDialog(this.lockedTilesArray,null,"seed",null,true,false,false,true);
      }
      
      public function getActiveTasks() : Vector.<FarmTask>
      {
         var taskType:String = null;
         var taskIndex:int = 0;
         var taskXML:XML = null;
         var farmTask:FarmTask = null;
         var taskObj:Object = null;
         var index:int = 0;
         var taskList:Vector.<FarmTask> = new Vector.<FarmTask>();
         if(this.m_tasksByTypes == null)
         {
            this.parseTaskObjectsFromConfig(this.QUEST_NAME);
         }
         var featureData:Object = this.getFeatureData();
         if(featureData)
         {
            for(index = 0; index < 4; index++)
            {
               taskType = featureData[KEY_SAVED_ACTIVE_TASKS][index][this.KEY_TASK_TYPE];
               taskIndex = int(featureData[KEY_SAVED_ACTIVE_TASKS][index][this.KEY_TASK_ID]);
               if(taskType == null || taskIndex == -1)
               {
                  taskObj = new Object();
                  taskObj.action = "DummyTask";
                  taskObj.type = "fa1v";
                  taskObj.total = "50";
                  taskObj.cashValue = "3";
                  taskObj.helper = "post_ask_for_item_feed";
                  taskObj.questName = m_featureName;
                  taskObj.taskIndex = index;
                  farmTask = new FarmTask(taskObj);
                  taskList.push(farmTask);
               }
               else
               {
                  taskXML = this.m_tasksByTypes[taskType][taskIndex];
                  taskObj = FarmGameUtil.xmlNodeToAttributes(taskXML);
                  taskObj.questName = m_featureName;
                  taskObj.taskIndex = index;
                  farmTask = new FarmTask(taskObj);
                  taskList.push(farmTask);
               }
            }
         }
         return taskList;
      }
      
      public function initEventListener() : void
      {
         GlobalEventManager.getInstance().addEventListener(this.EVENT_WW_INNOVATION_TILE_UNLOCK,this.showTileUnlockGrantPopup);
      }
      
      public function deleteEventListener() : void
      {
         GlobalEventManager.getInstance().removeEventListener(this.EVENT_WW_INNOVATION_TILE_UNLOCK,this.showTileUnlockGrantPopup);
      }
      
      public function showTileUnlockGrantPopup(e:TileUnlockEvent = null) : void
      {
         var ConsumableItem:FarmItem = null;
         if(!m_initialized)
         {
            this.initialize();
         }
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("tuscany_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            ConsumableItem = Global.farmGameSettingsManager.getFarmItemByCode(this.ConsumableCode);
            UI.displayPopup(new TuscanyInnovationTileUnlockwindow("assets/dialogs/expansion/FV_RewardDialog.swf",featureName,ConsumableItem,null,"assets/dialogs/tuscany/RewardDialog.png"));
            FarmStatsManager.count(m_featureName,"feature_ui","tileUnlockPopup");
         }
      }
      
      public function showDailyBonusGrantPopup(rewardItem:FarmItem) : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         FarmStatsManager.count(m_featureName,"feature_ui","dailyBonusPopup");
         UI.displayPopup(new TuscanyInnovationDailyBonusGrantWindow("assets/dialogs/expansion/FV_RewardDialog.swf",featureName,rewardItem,null,"assets/dialogs/tuscany/RewardDialog.png"),false);
      }
      
      public function showMainUI(showTutorialWithEAPage:Boolean = false) : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         this.m_mainWindow = new TuscanyInnovationMainWindow(m_featureName,this.mainWindowURL,showTutorialWithEAPage);
         UI.displayPopup(this.m_mainWindow);
         FarmStatsManager.count("GrapeEscape","feature_ui","main_ui","impression");
      }
      
      public function openBuyWindow(owner:FarmWindow) : void
      {
         UI.displayPopup(new FeaturePackagesBuyWindow(this.buyDialogURL,m_featureName,this.getBucketPackages(),owner),false);
         FarmStatsManager.count("GrapeEscape","feature_ui","buy_ui","impression");
      }
      
      public function craftConsumableFromMainWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
         FarmStatsManager.count("GrapeEscape","craftConsumables","click",this.consumableCount.toString());
         var consumableSearchStr:String = "grape barrel";
         CraftingManager.getInstance().openCraftshopWindow(CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType),consumableSearchStr,this.m_mainWindow,CRAFTSHOP_CONSUMABLE_TAB);
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
         this.m_staticData = new Object();
         this.m_staticData.typeArray = [];
         this.m_staticData.rewardArray = [];
         this.m_staticData.rewardCostArray = [];
         this.m_staticData.bucketPackages = [];
         this.m_staticData.tilesArray = [];
         this.m_staticData.endDate = "";
         this.m_staticData.consumable = "";
         this.m_staticData.currencyName = "";
         this.m_staticData.initialGrant = 0;
         this.m_staticData.rewardGrantCount = 0;
         this.m_staticData.gameCost = 0;
         this.m_staticData.p2pTurnCount = 0;
         this.m_staticData.soloTurnCount = 0;
         this.m_staticData.bonusGrantDate = new String();
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
         }
      }
      
      public function get mainWindowURL() : String
      {
         return this.m_assetPaths[WINDOW_MAIN];
      }
      
      public function get rewardWindowURL() : String
      {
         return this.m_assetPaths[WINDOW_REWARD];
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
         return HUD.getformattedTimeLeft(timeLeft);
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
      
      public function skipTask(slotIndex:int, callback:Function) : void
      {
         var featureObject:Object = null;
         var questTasks1:Vector.<FarmTask> = null;
         var tasks:Vector.<FarmTask> = this.getActiveTasks();
         if(Global.player.canBuyCash(tasks[slotIndex].skipCashValue))
         {
            Global.player.cash -= tasks[slotIndex].skipCashValue;
            featureObject = this.getFeatureData();
            questTasks1 = TuscanyInnovationManager.getInstance(m_featureName).getActiveTasks();
            featureObject[this.KEY_DAY_POINTS] += questTasks1[slotIndex].questPoints;
            setFeatureData(featureObject);
            this.mainWindow.untintWindow();
            this.mainWindow.enableInput = true;
            this.checkAndUpdateUserState();
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipTask",null,[m_featureName,slotIndex]),true);
            this.resetActionCountsForTasks(tasks[slotIndex]);
            this.generateAndSaveNewTask(slotIndex);
            this.m_mainWindow.refreshTaskFrame();
            this.m_mainWindow.updateProgressBar();
            if(this.mainWindow)
            {
               this.mainWindow.playJumpAnimation();
            }
            FarmStatsManager.count("GrapeEscape","SkipTask",this.currentDayIndex.toString(),tasks[slotIndex].skipCashValue.toString());
         }
         else
         {
            callback.call();
         }
      }
      
      public function redeemSlotTask(slotIndex:int) : void
      {
         var questTasks1:Vector.<FarmTask> = null;
         if(this.mainWindow)
         {
            this.mainWindow.playJumpAnimation();
         }
         var tasks:Vector.<FarmTask> = this.getActiveTasks();
         var featureObject:Object = this.getFeatureData();
         questTasks1 = TuscanyInnovationManager.getInstance(m_featureName).getActiveTasks();
         featureObject[this.KEY_DAY_POINTS] += questTasks1[slotIndex].questPoints;
         setFeatureData(featureObject);
         this.resetActionCountsForTasks(tasks[slotIndex]);
         if(this.hasActiveDayExpired() == false)
         {
            this.checkAndUpdateUserState();
         }
         else
         {
            this.redeemHasStarted = true;
         }
         this.generateAndSaveNewTask(slotIndex);
         this.m_mainWindow.refreshTaskFrame();
         this.m_mainWindow.updateProgressBar();
         FarmStatsManager.count("GrapeEscape","RedeemTask",this.currentDayIndex.toString(),this.overAllProgressLevel().toString());
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"redeemTask",null,[m_featureName,slotIndex]),true);
      }
      
      public function checkAndUpdateUserState() : void
      {
         var userState:int = 0;
         var dayPoints:int = this.getDayPoints();
         var featureObj:Object = this.getFeatureData();
         if(this.hasActiveDayExpired() == false)
         {
            userState = featureObj[this.KEY_USER_STATE] as int;
            if(dayPoints >= this.VAL_FIRST_MILESTONE && userState == this.EASY)
            {
               featureObj[this.KEY_USER_STATE] = this.LOCK1;
               FarmStatsManager.count("GrapeEscape","userstate",this.currentDayIndex.toString(),"Good");
               this.grantUserRewardforLevel(this.EASY);
            }
            else if(dayPoints >= this.VAL_SECOND_MILESTONE && userState == this.MEDIUM)
            {
               featureObj[this.KEY_USER_STATE] = this.LOCK2;
               FarmStatsManager.count("GrapeEscape","userstate",this.currentDayIndex.toString(),"superb");
               this.grantUserRewardforLevel(this.MEDIUM);
            }
            else if(dayPoints >= this.VAL_THIRD_MILESTONE && userState == this.HARD)
            {
               featureObj[this.KEY_USER_STATE] = this.DONE_FOR_THE_DAY;
               FarmStatsManager.count("GrapeEscape","userstate",this.currentDayIndex.toString(),"classic");
               this.grantUserRewardforLevel(this.HARD);
               this.showDailyBonusGrantPopup(this.getActiveDayReward(this.HARD));
               if(this.mainWindow)
               {
                  this.mainWindow.tintWindow();
                  this.mainWindow.enableInput = false;
               }
            }
            setFeatureData(featureObj);
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
            FarmStatsManager.count("GrapeEscape","sinkConsumable",consumableNeeded.toString(),this.consumableCount.toString());
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkConsumable",null,[m_featureName]),true);
            this.getNewTaskForLockedSlot();
            this.m_mainWindow.CloseCrushMC(null);
            this.m_mainWindow.refreshTaskFrame();
         }
      }
      
      public function getNewTaskForLockedSlot() : void
      {
         var index:int = 0;
         var taskType:String = null;
         var taskIndex:int = 0;
         var featureData:Object = this.getFeatureData();
         if(featureData)
         {
            for(index = 0; index < 4; index++)
            {
               taskType = featureData[KEY_SAVED_ACTIVE_TASKS][index][this.KEY_TASK_TYPE];
               taskIndex = featureData[KEY_SAVED_ACTIVE_TASKS][index][this.KEY_TASK_ID] % 24;
               if(taskType == null || taskIndex == -1)
               {
                  this.getNewTask(index);
               }
            }
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
      
      public function isTaskDumped(questIndex:int) : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(featureData[KEY_SAVED_ACTIVE_TASKS][questIndex].hasOwnProperty(this.KEY_DUMPED_STATUS))
         {
            if(featureData[KEY_SAVED_ACTIVE_TASKS][questIndex][this.KEY_DUMPED_STATUS] == 1)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function dumpTask(slotIndex:int) : void
      {
         var featureData:Object = null;
         if(this.canDumpTask(slotIndex))
         {
            if(this.m_mainWindow)
            {
               this.m_mainWindow.untintWindow();
               this.m_mainWindow.enableInput = true;
            }
            featureData = this.getFeatureData();
            featureData[KEY_SAVED_DUMPED_TIMESTAMP][slotIndex] = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            featureData[KEY_SAVED_ACTIVE_TASKS][slotIndex][this.KEY_DUMPED_STATUS] = 1;
            setFeatureData(featureData);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"dumpTask",null,[m_featureName,slotIndex]),true);
            FarmStatsManager.count("GrapeEscape","DumpTask",this.currentDayIndex.toString());
            this.m_mainWindow.refreshTaskFrame();
         }
      }
      
      public function skipDumpedTask(slotIndex:int) : void
      {
         var tasks:Vector.<FarmTask> = null;
         var featureData:Object = null;
         if(Global.player.canBuyCash(SKIP_COST))
         {
            tasks = this.getActiveTasks();
            Global.player.cash -= SKIP_COST;
            this.resetActionCountsForTasks(tasks[slotIndex]);
            featureData = this.getFeatureData();
            featureData[KEY_SAVED_DUMPED_TIMESTAMP][slotIndex] = 0;
            featureData[KEY_SAVED_ACTIVE_TASKS][slotIndex][this.KEY_DUMPED_STATUS] = 0;
            setFeatureData(featureData);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipDumpedTask",null,[m_featureName,slotIndex]),true);
            FarmStatsManager.count("GrapeEscape","SkipDump","1",this.currentDayIndex.toString());
            this.generateAndSaveNewTask(slotIndex);
            this.m_mainWindow.refreshTaskFrame();
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
      
      public function sinkGold(slotIndex:int) : void
      {
         var tasks:Vector.<FarmTask> = this.getActiveTasks();
         if(Global.player.canBuy(tasks[slotIndex].total))
         {
            if(this.mainWindow)
            {
               this.mainWindow.playJumpAnimation();
            }
            Global.player.gold -= tasks[slotIndex].total;
            this.postTaskCompletionActions(slotIndex);
            FarmStatsManager.count("GrapeEscape","sinkGold",tasks[slotIndex].type,this.currentDayIndex.toString());
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkGold",null,[m_featureName,slotIndex]),true);
         }
      }
      
      public function sinkBushel(slotIndex:int) : void
      {
         var tasks:Vector.<FarmTask> = this.getActiveTasks();
         CraftingManager.getInstance().deductItemFromCraftingInventory(tasks[slotIndex].type,tasks[slotIndex].total);
         this.postTaskCompletionActions(slotIndex);
         if(this.mainWindow)
         {
            this.mainWindow.playJumpAnimation();
         }
         FarmStatsManager.count("GrapeEscape","sinkBushel",tasks[slotIndex].type,this.currentDayIndex.toString());
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkBushel",null,[m_featureName,slotIndex]),true);
      }
      
      public function postTaskCompletionActions(completedTaskSlotIndex:int) : void
      {
         var questTasks1:Vector.<FarmTask> = null;
         var featureObject:Object = this.getFeatureData();
         questTasks1 = TuscanyInnovationManager.getInstance(m_featureName).getActiveTasks();
         featureObject[this.KEY_DAY_POINTS] += questTasks1[completedTaskSlotIndex].questPoints;
         setFeatureData(featureObject);
         if(this.hasActiveDayExpired() == true)
         {
            this.redeemHasStarted = true;
         }
         else
         {
            this.checkAndUpdateUserState();
         }
         var tasks:Vector.<FarmTask> = this.getActiveTasks();
         this.resetActionCountsForTasks(tasks[completedTaskSlotIndex]);
         this.generateAndSaveNewTask(completedTaskSlotIndex);
         this.m_mainWindow.refreshTaskFrame();
         this.m_mainWindow.updateProgressBar();
      }
      
      public function getFeatureData() : Object
      {
         var index:int = 0;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,m_featureName);
         if(!featureData)
         {
            featureData = {};
            featureData[this.KEY_USER_STATE] = this.NOT_INITIALIZED;
            featureData[KEY_SAVED_ACTIVE_TASKS] = {};
            for(index = 0; index < 4; index++)
            {
               featureData[KEY_SAVED_ACTIVE_TASKS][index] = {};
               featureData[KEY_SAVED_ACTIVE_TASKS][index][this.KEY_TASK_TYPE] = "M1";
               featureData[KEY_SAVED_ACTIVE_TASKS][index][this.KEY_TASK_ID] = -1;
               featureData[KEY_SAVED_ACTIVE_TASKS][index][this.KEY_TASK_PROGRESS] = 0;
            }
            featureData[this.KEY_DAILY_PROGRESS_POINTS] = {};
            featureData[this.KEY_LAST_USED_TYPE] = {};
            featureData[this.KEY_LAST_USED_TYPE][this.EASY] = -1;
            featureData[this.KEY_LAST_USED_TYPE][this.MEDIUM] = -1;
            featureData[this.KEY_LAST_USED_TYPE][this.HARD] = -1;
            featureData[this.KEY_LAST_TASKS_IDS] = {};
            featureData[this.KEY_LAST_TASKS_IDS][this.KEY_MISC_EASY] = -1;
            featureData[this.KEY_LAST_TASKS_IDS][this.KEY_MISC_MEDIUM] = -1;
            featureData[this.KEY_LAST_TASKS_IDS][this.KEY_MISC_HARD] = -1;
            featureData[this.KEY_LAST_TASKS_IDS][this.KEY_BB] = -1;
            featureData[this.KEY_LAST_TASKS_IDS][this.KEY_EH] = -1;
            featureData[this.KEY_LAST_TASKS_IDS][this.KEY_HB] = -1;
            featureData[this.KEY_DAY_POINTS] = 0;
            featureData[KEY_SAVED_DUMPED_TIMESTAMP] = {};
            setFeatureData(featureData);
         }
         return featureData;
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
      
      public function getNewTask(slotIndex:int) : void
      {
         var featureData:Object = null;
         var tasks:Vector.<FarmTask> = null;
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getNewTask",null,[m_featureName,slotIndex]),true);
         if(this.isTaskDumped(slotIndex))
         {
            featureData = this.getFeatureData();
            featureData[KEY_SAVED_ACTIVE_TASKS][slotIndex][this.KEY_DUMPED_STATUS] = 0;
            featureData[KEY_SAVED_DUMPED_TIMESTAMP][slotIndex] = 0;
            tasks = this.getActiveTasks();
            this.resetActionCountsForTasks(tasks[slotIndex]);
            setFeatureData(featureData);
         }
         FarmStatsManager.count("GrapeEscape","GetNewTask",this.currentDayIndex.toString(),this.overAllProgressLevel().toString());
         this.generateAndSaveNewTask(slotIndex);
         this.m_mainWindow.refreshTaskFrame();
      }
      
      private function onInitQuestComplete(callback:Function, result:Object) : void
      {
         this.m_resultObject = result;
         if(Boolean(result) && result.hasOwnProperty("activeTasks"))
         {
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,result["activeTasks"]);
            callback.call();
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
         orderBoardXml = Global.farmGameSettingsManager.getXML().TuscanyInnovationQuests.TuscanyInnovationQuest.(@name == questName)[0];
         rewardsList = orderBoardXml.TuscanyInnovationRewards.stage;
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
      
      protected function checkForTaskUpdates(event:TransactionEvent) : void
      {
         var progress:Number = NaN;
         var transaction:TFarmTransaction = null;
         var icon:FeatureQueuedIcon = null;
         var hasUpdatedProgress:Boolean = false;
         var hasCompletedTask:Boolean = false;
         var progressArray:Array = [];
         var tasks:Vector.<FarmTask> = this.getActiveTasks();
         var featureData:Object = this.getFeatureData();
         for(var i:int = 0; i < tasks.length; i++)
         {
            transaction = event.transaction as TFarmTransaction;
            if(tasks[i].helperType == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
            {
               progress = CraftingManager.getInstance().getBushelQuantityInInventory(tasks[i].type) - featureData[KEY_SAVED_ACTIVE_TASKS][i][this.KEY_PROGRESS];
               hasUpdatedProgress = true;
               FarmStatsManager.count("GrapeEscape","PerformTask",this.currentDayIndex.toString(),tasks[i].type);
            }
            else
            {
               progress = FarmQuestUtility.getInstance().getProgression(tasks[i],transaction,null);
            }
            progressArray.push(progress);
            if(progress > 0)
            {
               hasUpdatedProgress = true;
               if(Number(featureData[KEY_SAVED_ACTIVE_TASKS][i][this.KEY_PROGRESS]) + progress >= tasks[i].total)
               {
                  hasCompletedTask = true;
                  FarmStatsManager.count("GrapeEscape","PerformTask",this.currentDayIndex.toString(),tasks[i].type);
               }
            }
         }
         if(hasUpdatedProgress)
         {
            this.saveProgressForPlayer(progressArray);
         }
         if(hasCompletedTask)
         {
            icon = Global.hud.rightSideIconQueue.getIconByFeatureName(m_featureName) as FeatureQueuedIcon;
            if(icon)
            {
               icon.attachArrow(ArrowType.ARROWUPDATE);
               icon.setArrowText("Redeem");
            }
         }
      }
      
      protected function saveProgressForPlayer(progressArray:Array) : void
      {
         var tasks:Vector.<FarmTask> = this.getActiveTasks();
         var featureData:Object = this.getFeatureData();
         for(var i:int = 0; i < tasks.length; i++)
         {
            if(tasks[i].helperType == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
            {
               featureData[KEY_SAVED_ACTIVE_TASKS][i][this.KEY_PROGRESS] = CraftingManager.getInstance().getBushelQuantityInInventory(tasks[i].type);
            }
            else
            {
               featureData[KEY_SAVED_ACTIVE_TASKS][i][this.KEY_PROGRESS] = Math.min(Number(featureData[KEY_SAVED_ACTIVE_TASKS][i][this.KEY_PROGRESS]) + progressArray[i],tasks[i][this.KEY_TOTAL]);
            }
         }
         setFeatureData(featureData);
      }
      
      public function getTaskProgress(slotIndex:int) : int
      {
         var task:FarmTask = null;
         var buildingFarmItem:FarmItem = null;
         var objects:Array = null;
         var buildingName:String = null;
         var craftingSystem:FeatureCraftingSystem = null;
         var npcData:Object = null;
         var animalObject:Object = null;
         var progress:int = 0;
         task = this.getActiveTasks()[slotIndex];
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
               buildingName = "xty_elitehorses";
               craftingSystem = FeatureCraftingManager.instance.getSystem(buildingName);
               if(craftingSystem)
               {
                  npcData = craftingSystem.npcData;
                  for each(animalObject in npcData)
                  {
                     if(animalObject.hasOwnProperty("complete"))
                     {
                        if(animalObject["complete"] == true)
                        {
                           progress++;
                        }
                     }
                  }
               }
               break;
            case "sinkBushel":
               progress = CraftingManager.getInstance().getBushelQuantityInInventory(task.type);
               break;
            default:
               progress = int(featureData[KEY_SAVED_ACTIVE_TASKS][slotIndex][this.KEY_TASK_PROGRESS]);
         }
         return progress;
      }
      
      public function getDayPoints() : int
      {
         var dailyPoints:int = 0;
         var featureData:Object = this.getFeatureData();
         if(featureData.hasOwnProperty(this.KEY_DAY_POINTS))
         {
            dailyPoints = int(featureData[this.KEY_DAY_POINTS]);
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
         FarmStatsManager.count("GrapeEscape","MileStoneCompletion",this.currentDayIndex.toString(),this.EASY.toString());
         UserRewardUtil.grantUserReward(this.getRewardsForTheDay()[level]);
      }
      
      public function getActiveDayReward(level:int) : FarmItem
      {
         var rewardCode:String = (this.getRewardsForTheDay()[level] as Object).value;
         return Global.farmGameSettingsManager.getFarmItemByCode(rewardCode);
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
      
      public function startNewDay(e:Event = null) : void
      {
         var i:int = 0;
         var featureData:Object = this.getFeatureData();
         if(this.hasActiveDayExpired() == true || featureData[this.KEY_USER_STATE] == this.NOT_INITIALIZED)
         {
            this.redeemHasStarted = false;
            if(Boolean(this.m_mainWindow) && featureData[this.KEY_USER_STATE] == this.NOT_INITIALIZED)
            {
               this.m_mainWindow.closeFirstSessionStartMC();
            }
            if(this.hasActiveDayExpired())
            {
               featureData[this.KEY_DAILY_PROGRESS_POINTS][this.activeDayIndex] = featureData[this.KEY_DAY_POINTS] > 35 ? 35 : featureData[this.KEY_DAY_POINTS];
            }
            featureData[this.KEY_ACTIVE_DAY_TIMESTAMP] = FarmGameUtil.getMidnightTimestamp() / 1000;
            if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_TUSCANY))
            {
               if(WorldSeasonsManager.getInstance().isEAWeek(WorldsConstants.WORLD_ID_TUSCANY))
               {
                  featureData[this.KEY_DAY_POINTS] = this.VAL_FIRST_MILESTONE;
                  featureData[this.KEY_USER_STATE] = this.MEDIUM;
               }
               else
               {
                  featureData[this.KEY_DAY_POINTS] = 0;
                  featureData[this.KEY_USER_STATE] = this.EASY;
               }
               this.checkAadUpdateEarlierEADays();
            }
            else
            {
               featureData[this.KEY_DAY_POINTS] = 0;
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
            else
            {
               for(i = 0; i < 4; i++)
               {
                  this.generateAndSaveNewTask(i);
                  featureData = this.getFeatureData();
                  featureData[KEY_SAVED_ACTIVE_TASKS][i][this.KEY_DUMPED_STATUS] = 0;
                  setFeatureData(featureData);
               }
               this.m_mainWindow.refreshWindow();
            }
            FarmStatsManager.count("GrapeEscape","startNewDay",this.currentDayIndex.toString(),this.overAllProgressLevel().toString());
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startNewDay",null,[m_featureName]),true);
         }
      }
      
      public function checkAadUpdateEarlierEADays() : void
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
         var questTasks1:Vector.<FarmTask> = this.getActiveTasks();
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
      
      public function isTaskRedeemable(slotIndex:int) : Boolean
      {
         var result:Boolean = false;
         var progress:int = this.getTaskProgress(slotIndex);
         var task:FarmTask = this.getActiveTasks()[slotIndex];
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
         if(featureData[this.KEY_DAY_POINTS] >= this.VAL_MILESTONE_POINTS_ARRAY[level])
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
         if(this.hasActiveDayExpired())
         {
            msg = "Crush button will be active when you reach a milestone.";
         }
         else if(this.isUserLocked() == false)
         {
            msg = "Crush button will be active when you reach a milestone.";
         }
         else if(this.hasEnoughConsumableToSink() == false)
         {
            msg = "Collect more Grape Barrels to activate Crush button.";
         }
         else
         {
            msg = "Crush Grape Barrels to unlock the next part of the Wine Meter.";
         }
         return msg;
      }
      
      public function overAllProgressLevel() : int
      {
         var progressLevel:int = -1;
         var totalDaysForAvg:int = this.currentDayIndex > 41 ? 42 : int(this.currentDayIndex + 1);
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_TUSCANY) == false)
         {
            totalDaysForAvg -= 7;
         }
         else if(totalDaysForAvg > 35)
         {
            totalDaysForAvg = 35;
         }
         var avg:int = this.getTotalPointsForUser() / totalDaysForAvg;
         if(avg >= this.VAL_CLASSIC)
         {
            progressLevel = 2;
         }
         else if(avg >= this.VAL_SUPERB)
         {
            progressLevel = 1;
         }
         else if(avg >= this.VAL_GOOD)
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
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_TUSCANY) == false)
         {
            totalDaysForAvg -= 7;
         }
         else if(totalDaysForAvg > 35)
         {
            totalDaysForAvg = 35;
         }
         return int(this.getTotalPointsForUser() / totalDaysForAvg);
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
         if(featureData.hasOwnProperty(this.KEY_DAY_POINTS))
         {
            totalPoints += int(featureData[this.KEY_DAY_POINTS]) > 35 ? 35 : featureData[this.KEY_DAY_POINTS];
         }
         return totalPoints;
      }
      
      public function openRewardViewWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         this.m_rewardWindow = new TuscanyInnovationRewardWindow(m_featureName,this.rewardWindowURL);
         UI.displayPopup(this.m_rewardWindow,false);
         FarmStatsManager.count(m_featureName,"feature_ui","reward_ui","impression");
      }
      
      public function openFeatureExpiredWindow() : void
      {
         this.m_finalRewardWindow = new TuscanyInnovationFinalRewardWindow(m_featureName,this.featureEndWindowURL);
         UI.displayPopup(this.m_finalRewardWindow,false);
         FarmStatsManager.count(m_featureName,"feature_ui","reward_ui","impression");
      }
      
      public function get mainWindow() : TuscanyInnovationMainWindow
      {
         return this.m_mainWindow;
      }
      
      public function get activeDayIndex() : int
      {
         var dayIndex:int = 0;
         var featureData:Object = this.getFeatureData();
         var activeDayTS:Number = featureData[this.KEY_ACTIVE_DAY_TIMESTAMP] as Number;
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("01/15/2018") / FarmGameUtil.NUM_MSECS_IN_SECOND;
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
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("01/15/2018");
         dayIndex = (GlobalEngine.serverTime - featureStartDayTS) / FarmGameUtil.NUM_MSECS_IN_DAY;
         if(dayIndex < 0)
         {
            dayIndex = 0;
         }
         return dayIndex;
      }
      
      public function grantBonusReward() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,this.SERVICE_FUNC_GRANT_BONUS,this.onBonusGrantComplete,[m_featureName]),true);
      }
      
      public function onBonusGrantComplete(result:Object = null) : void
      {
         var bonusRewardCode:String = null;
         var bonusRewardItem:FarmItem = null;
         if(!m_initialized)
         {
            this.initialize();
         }
         var featureData:Object = this.getFeatureData();
         if(this.overAllProgressLevel() >= 0)
         {
            bonusRewardCode = this.bonusRewardsArray[this.overAllProgressLevel()];
            bonusRewardItem = Global.farmGameSettingsManager.getFarmItemByCode(bonusRewardCode);
            Global.player.addGift(bonusRewardItem.name);
            featureData[this.FEATURE_OPTIONS_BONUS_CODE_KEY] = bonusRewardCode;
         }
         featureData[this.FEATURE_OPTIONS_BONUS_CLAIMED_KEY] = 1;
         setFeatureData(featureData);
         this.openFeatureExpiredWindow();
         FarmStatsManager.count(m_featureName,"grantBonus",this.overAllProgressLevel().toString());
      }
      
      public function get grantedBonusRewardItem() : FarmItem
      {
         var bonusCode:String = null;
         var bonusItem:FarmItem = null;
         var featureData:Object = this.getFeatureData();
         if(featureData.hasOwnProperty(this.FEATURE_OPTIONS_BONUS_CODE_KEY))
         {
            bonusCode = featureData[this.FEATURE_OPTIONS_BONUS_CODE_KEY];
            bonusItem = Global.farmGameSettingsManager.getFarmItemByCode(bonusCode);
         }
         return bonusItem;
      }
      
      public function get bonusRewardsArray() : Array
      {
         return ["1p5d","1p39","1p2s"];
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
         if(featureData.hasOwnProperty(this.KEY_FEATURE_ENDED) && featureData[this.KEY_FEATURE_ENDED] == 1)
         {
            result = true;
         }
         return result;
      }
      
      public function getTaskLevel(slotnumber:int) : int
      {
         var taskLevel:int = 0;
         var featureData:Object = this.getFeatureData();
         if(Boolean(featureData) && Boolean(featureData[KEY_SAVED_ACTIVE_TASKS]))
         {
            taskLevel = featureData[KEY_SAVED_ACTIVE_TASKS][slotnumber][this.KEY_TASK_LEVEL] as int;
         }
         return taskLevel;
      }
      
      public function IsBonusBuildingReadyToHarvest() : Boolean
      {
         var result:Boolean = false;
         if(this.getTimeLeftForBonusHarvest() <= 0)
         {
            result = true;
         }
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("tuscany_innovation_bonus_enabled");
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
      
      public function harvestBonusBuilding() : void
      {
         var count:int = 0;
         var featureData:Object = null;
         if(!m_initialized)
         {
            this.initialize();
         }
         var key:String = LAST_BONUS_HARVEST_TIME_KEY;
         Global.player.setFeatureLastShown(key,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         var harvestRewardName:String = this.getNextHarvestItemName();
         var harvestFarmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(harvestRewardName);
         if(harvestFarmItem)
         {
            count = 1;
            if(this.isBoosterApplied() == true)
            {
               count = 2;
               featureData = this.getFeatureData();
               featureData[this.KEY_BOOSTER_APPLIED] = 0;
               setFeatureData(featureData);
            }
            Global.player.addGift(harvestRewardName,"",count);
            FarmStatsManager.count(m_featureName,"feature_ui","harvestpopup",harvestRewardName);
            UI.displayPopup(new TuscanyInnovationPostBonusHarvestWindow("assets/dialogs/expansion/FV_RewardDialog.swf",featureName,harvestFarmItem,null,"assets/dialogs/tuscany/RewardDialog.png",count));
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,this.SERVICE_FUNC_HARVEST_BONUS,null,[m_featureName]),true);
         }
      }
      
      private function getNextHarvestItemName() : String
      {
         var couponName:String = null;
         var bonusCode:String = null;
         var bonusFarmItem:FarmItem = null;
         var consumableRotationCount:int = 0;
         var bonusCount:int = 0;
         var featureData:Object = this.getFeatureData();
         if(featureData.hasOwnProperty(this.FEATURE_OPTIONS_BONUS_CODE_KEY))
         {
            if(featureData.hasOwnProperty(BONUS_HARVEST_COUNT))
            {
               bonusCount = featureData[BONUS_HARVEST_COUNT] as int;
            }
            else
            {
               featureData[BONUS_HARVEST_COUNT] = 0;
               bonusCount = 0;
            }
            bonusCode = featureData[this.FEATURE_OPTIONS_BONUS_CODE_KEY];
            bonusFarmItem = Global.farmGameSettingsManager.getFarmItemByCode(bonusCode);
            consumableRotationCount = int(BONUS_COUNT_MAP[bonusFarmItem["name"]]);
            couponName = this.BONUS_HARVEST_ARRAY[bonusCount % consumableRotationCount];
            featureData[BONUS_HARVEST_COUNT] = bonusCount + 1;
            setFeatureData(featureData);
         }
         return couponName;
      }
      
      public function canApplyBooster() : Boolean
      {
         var result:Boolean = false;
         var boosterItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.WINERY_BOOSTER_CODE);
         var hasUserBooster:Boolean = boosterItem.getNumInstancesOfThisItem() > 0;
         var boosterAlreadyApplied:Boolean = this.isBoosterApplied();
         if(hasUserBooster && !boosterAlreadyApplied)
         {
            result = true;
         }
         return result;
      }
      
      public function applyBooster() : void
      {
         var featureData:Object = this.getFeatureData();
         featureData[this.KEY_BOOSTER_APPLIED] = 1;
         setFeatureData(featureData);
         Global.player.removeGiftWithKey(this.WINERY_BOOSTER_CODE,1);
         FarmStatsManager.count(m_featureName,"applyBooster",this.overAllProgressLevel().toString());
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,this.SERVICE_FUNC_APPLY_BOOSTER,null,[m_featureName]),true);
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
      
      private function resetActionCountsForTasks(questTask:FarmTask) : void
      {
         var actionKey:String = null;
         if(questTask.action == QuestConstants.TASK_USE_ITEM_BY_CODE)
         {
            actionKey = FEATURE_NAME + "_" + questTask.type;
            if(Boolean(actionKey) && actionKey != "")
            {
               Global.player.resetActionCount(actionKey);
            }
         }
      }
      
      public function get redeemHasStarted() : Boolean
      {
         return this._redeemHasStarted;
      }
      
      public function set redeemHasStarted(value:Boolean) : void
      {
         this._redeemHasStarted = value;
      }
      
      public function set mainWindow(mainWindowInstance:TuscanyInnovationMainWindow) : void
      {
         this.m_mainWindow = mainWindowInstance;
      }
   }
}

