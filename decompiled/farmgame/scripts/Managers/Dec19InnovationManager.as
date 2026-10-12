package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Constants.QuestConstants;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureBuilding;
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Classes.MapTrigger;
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import Display.HUD.HUD;
   import Display.HUD.HUDWidgets.HudBottomDec19InnovationButton;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import Events.TileUnlockEvent;
   import Managers.Crafting.CraftingManager;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.Dec19InnovationBuyWindow;
   import Widgets.Windows.Dec19InnovationChristmasSurpriseWindow;
   import Widgets.Windows.Dec19InnovationDailyBonusGrantWindow;
   import Widgets.Windows.Dec19InnovationFinalRewardWindow;
   import Widgets.Windows.Dec19InnovationLeaderboardRewardWindow;
   import Widgets.Windows.Dec19InnovationLeaderboardWindow;
   import Widgets.Windows.Dec19InnovationLeagueInfoWindow;
   import Widgets.Windows.Dec19InnovationLeagueRewardWindow;
   import Widgets.Windows.Dec19InnovationMainWindow;
   import Widgets.Windows.Dec19InnovationPostBonusHarvestWindow;
   import Widgets.Windows.Dec19InnovationRewardWindow;
   import Widgets.Windows.Dec19InnovationTileUnlockwindow;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.GenericSingleRewardPopup;
   import flash.events.Event;
   import mx.utils.StringUtil;
   
   public class Dec19InnovationManager extends BaseFeatureManager
   {
      
      public static const HUD_INITIALISATION_FLAG:String = "dec19_innovation_hud_initialise_flag";
      
      private static const HUD_DEC19_ASSET:String = "assets/dialogs/Dec19_Innovation/FV_xws_hud_Innovation.swf";
      
      public static const FEATURE_NAME:String = "Dec19Innovation";
      
      private static const WINDOW_MAIN:String = "main";
      
      private static const WINDOW_REWARD:String = "reward";
      
      private static const WINDOW_CONGRATS:String = "congrats";
      
      private static const WINDOW_BUY:String = "buyDialog";
      
      public static const COLLECT_TIME_KEY:String = "ctk";
      
      public static const FEED_NAME:String = "Dec19InnovationUI";
      
      public static const FEATURE_OPTIONS_KEY:String = "Dec19Innovation";
      
      public static const KEY_GA_FEATURE_START:String = "ga_dec19_innovation_start";
      
      public static const KEY_EA_CONSUMABLE_BENEFIT_GIVEN:String = "EA_consumable_benefit_given";
      
      private static var m_initialized:Boolean = false;
      
      private static const SKIP_COST:int = 1;
      
      private static const KEY_SAVED_ACTIVE_TASKS:String = "1";
      
      private static const KEY_SAVED_DUMPED_TIMESTAMP:String = "3";
      
      private static const KEY_FLUSH_DAILY_REWARD_TASK:String = "flush_daily_reward_tasks";
      
      private static const KEY_CURRENT_WEEK:String = "currentweek";
      
      private static const KEY_SHOW_LEADERBOARD_FIRST_TIME_IN_WEEK:String = "dec19_weekly_show_leaderboard_first_time";
      
      private static const KEY_SAVED_LEADERBOARD_RESULT:String = "leaderboard_data";
      
      private static const KEY_CURRENT_LEADERBOARD:String = "currentLeaderboard";
      
      private static const KEY_LEADERBOARD_EA_POINTS_GRANTED:String = "dec19_leaderboard_ea_pts_granted";
      
      private static const KEY_LEAGUE_UPDATED_FOR_WEEK:String = "league_updated_for_week";
      
      private static const SERVICE_NAME:String = "Dec19InnovationService";
      
      public static const DEC19_TILE_UNLOCK_COUNT:String = "85co";
      
      private static const KEY_TILE_UNLOCK_COUNT:String = "dec19_tile_unlock_count";
      
      private static const LAST_BONUS_HARVEST_TIME_KEY:String = "xty_bht";
      
      public static const DEFAULT_HARVEST_THROTTLE_TIME:Number = 86400;
      
      private static const CRAFTSHOP_CONSUMABLE_TAB:String = "consumable";
      
      private static const BONUS_HARVEST_COUNT:String = "hc";
      
      private static const BONUS_COUNT_MAP:Object = {
         "xws_giftmaker":4,
         "xws_supergiftmaker":5,
         "xws_megagiftmaker":6
      };
      
      private static const BONUS_NAME_ARRAY:Array = ["Nisse Giftbox","Nisse Workshop","Nisse Gift House","Nisse Gift Workshop","Nisse Gift Factory"];
      
      public static const PERFORMANCE_TYPE:* = {
         "PROMOTION":"promotion",
         "DEMOTION":"demotion",
         "RETENTION":"retention"
      };
      
      public static const FINAL_BUILDING_NAME:Array = ["giftmaker","supergiftmaker","megagiftmaker"];
      
      public static const FINAL_LEVEL_NAME:Array = ["EXPERT","PROFESSIONAL","CHAMPION"];
      
      public static const FV_REWARD_DIALOG_ASSET:* = "assets/dialogs/expansion/FV_RewardDialog.swf";
      
      public static const SANTA_VILLAGE_REWARD_DIALOG_BG_ASSET:* = "assets/dialogs/santavillage/RewardDialog.png";
      
      public const TILE_UNLOCK:String = "Dec19_Tile_Unlock";
      
      public const FIRST_TIME_UNLOCK:String = "Dec19_First_tile_Unlock";
      
      public const LEAGUE_OVERLAY_FLAG:String = "Dec19_League_Overlay";
      
      private const WEEKLY_SCORE:String = "weekly_score";
      
      public const DEC19_START_DATE:String = "12/02/2019";
      
      public const DEC19_BONUS_START_DATE:String = "01/13/2020";
      
      public const DEC19_BONUS_END_DATE:String = "01/27/2020";
      
      public const CHRISTMAS_WEEK:int = 4;
      
      public const CHRISTMAS_WEEK_START_DATE:String = "12/20/2019";
      
      public const CHRISTMAS_WEEK_END_DATE:String = "12/26/2019";
      
      public const TOTAL_NUMBER_OF_WEEKS:int = 6;
      
      private var m_cachedTaskData:Object;
      
      public const DEFAULT_THROTTLE_TIME:Number = 86400;
      
      private var m_assetPaths:Object = null;
      
      protected var m_staticData:Object;
      
      private var m_mainWindow:Dec19InnovationMainWindow;
      
      private var m_rewardPopup:GenericSingleRewardPopup;
      
      private var m_communityRewardsEarned:Object;
      
      public const VAL_FIRST_MILESTONE:int = 10;
      
      public const VAL_SECOND_MILESTONE:int = 20;
      
      public const VAL_THIRD_MILESTONE:int = 35;
      
      public const VAL_WEEK_FIRST_MILESTONE:int = 5;
      
      public const VAL_WEEK_SECOND_MILESTONE:int = 15;
      
      public const VAL_WEEK_THIRD_MILESTONE:int = 30;
      
      protected const KEY_PROGRESS:String = "progress";
      
      protected const KEY_TOTAL:String = "total";
      
      private var m_resultObject:Object;
      
      private var m_CgTaskList:Array;
      
      private const QUEST_NAME:String = "Dec19Innovation";
      
      private var m_dec19InnovationHud:HudBottomDec19InnovationButton;
      
      private const KEY_LAST_TASKS_IDS:String = "2";
      
      private const KEY_MISC_EASY:String = "M1";
      
      private const KEY_MISC_MEDIUM:String = "M2";
      
      private const KEY_MISC_HARD:String = "M3";
      
      private const KEY_MISC_DONE_FOR_THE_DAY:String = "M4";
      
      private const KEY_BB:String = "BB";
      
      private const KEY_EH:String = "EH";
      
      private const KEY_HB:String = "HB";
      
      private const KEY_TASK_PROGRESS:String = "progress";
      
      private const KEY_TASK_ID:String = "id";
      
      private const KEY_TASK_TYPE:String = "type";
      
      private const KEY_CURRENT_LEAGUE:String = "dec19_current_league";
      
      private const KEY_LEAGUE_UPGRADE:String = "dec19_league_upgrade";
      
      private const KEY_LEAGUE_DOWNGRADE:String = "dec19_league_downgrade";
      
      private const KEY_SHOULD_GRANT_LEAGUE_REWARD:String = "should_grant_league_reward";
      
      private const KEY_CURRENT_AVERAGE:String = "current_average";
      
      private const KEY_LAST_USED_TYPE:String = "lt";
      
      private var m_tasksByTypes:Object = null;
      
      private const KEY_USER_STATE:String = "state";
      
      private var taskTypesArray:Array = [["M1","M1","M1","M1","M1","HB","M1","M1","M1","M1","BB","M1","M1","M1","M1","EH"],["M2","M2","M2","M2","M2","HB","M2","M2","M2","M2","BB","M2","M2","M2","M2","EH"],["M3","M3","M3","M3","M3","HB","M3","M3","M3","M3","BB","M3","M3","M3","M3","EH"],["M4","M4","M4","M4","M4","M4","M4","M4","M4","M4","M4","M4","M4","M4","M4","M4"]];
      
      private const KEY_DUMPED_STATUS:String = "dump_status";
      
      private const KEY_DAY_POINTS:String = "dp";
      
      public const EASY:int = 0;
      
      public const MEDIUM:int = 1;
      
      public const HARD:int = 2;
      
      public const LOCK1:int = 4;
      
      public const LOCK2:int = 5;
      
      public const DONE_FOR_THE_DAY:int = 3;
      
      public const NOT_INITIALIZED:int = -1;
      
      private var m_activePopupCount:int = 0;
      
      private const KEY_DAILY_PROGRESS_POINTS:String = "pts";
      
      private const FEATURE_OPTIONS_BONUS_CLAIMED_KEY:String = "bonus";
      
      private const KEY_FEATURE_ENDED:String = "finished";
      
      private const KEY_ACTIVE_DAY_TIMESTAMP:String = "ts";
      
      private var m_rewardWindow:Dec19InnovationRewardWindow;
      
      private const KEY_TASK_LEVEL:String = "taskLevel";
      
      private const FEATURE_OPTIONS_BONUS_CODE_KEY:String = "bonusCode";
      
      private var m_rewardsBySlotName:Object = null;
      
      public const VAL_MILESTONE_POINTS_ARRAY:Array = [10,20,35];
      
      public const VAL_CLASSIC:int = 25;
      
      public const VAL_SUPERB:int = 15;
      
      public const VAL_GOOD:int = 5;
      
      public const NO_OF_WEEKS:int = 6;
      
      public const FINAL_LEAGUE:int = 2;
      
      private const SERVICE_FUNC_HARVEST_BONUS:String = "harvestBonusBuilding";
      
      private const SERVICE_FUNC_GRANT_BONUS:String = "grantBonus";
      
      private const EVENT_WW_INNOVATION_TILE_UNLOCK:String = "Dec19InnovationTileUnlock";
      
      public const CRUSH_BARREL_TUTORIAL:String = "Dec19InnovationSinkTutorial";
      
      public const FIRST_SESSION_TUTORIAL:String = "Dec19FirstSessionTutorial";
      
      private var BONUS_HARVEST_ARRAY:Array = ["consume_organic_fertilizer","consume_unwither","consume_farm_hands","fuel1","consume_instagrow","consume_turbo_charger"];
      
      private const CHRISTMAS_REWARD_PACKAGE_PREFIX:String = "pkg_dec19Innovation_ChristmasDay";
      
      internal const rewardTemplate:String = "pkg_dec19InnovationWeek{2}_{0}To{1}";
      
      private const KEY_DAILY_CHRISTMAS_REWARD_HARVESTED:* = "christmasRewardHarvestedFor_Day";
      
      public const LEAGUE_MAP:Object = {
         0:"Bronze",
         1:"Silver",
         2:"Gold"
      };
      
      public const DEC19_LEAGUE_MAP:Object = {
         0:"Bronze",
         1:"Silver",
         2:"Gold",
         3:"Diamond"
      };
      
      public const LEAGUE_UPGRADE_MAP:Object = {
         0:15,
         1:15,
         2:15
      };
      
      public const LEAGUE_DOWNGRADE_MAP:Object = {
         1:41,
         2:41,
         3:41
      };
      
      private var _redeemHasStarted:Boolean = false;
      
      private var _redeemMessageShown:Boolean = false;
      
      private const REDEEM_ADDITIONAL_DAYS:int = 0;
      
      private var m_buyWindow:Dec19InnovationBuyWindow;
      
      public var m_leaderboardWindow:Dec19InnovationLeaderboardWindow;
      
      private var m_finalRewardWindow:Dec19InnovationFinalRewardWindow;
      
      private var LEADERBOARD_WINDOW:String = "assets/dialogs/Dec19_Innovation/FV_xws_Innovation_Leaderboard.swf";
      
      private var LEADERBOARD_REWARD_WINDOW:String = "assets/dialogs/Dec19_Innovation/FV_xws_Innovation_Next.swf";
      
      private var CHRISTMAS_SURPRISE_WINDOW:String = "assets/dialogs/Dec19_Innovation/FV_xws_xmasgift.swf";
      
      private var LEAGUE_INFO_WINDOW:String = "assets/dialogs/Dec19_Innovation/FV_xws_Innovation_Leagues.swf";
      
      public function Dec19InnovationManager(featureName:String, featureConfig:XML = null)
      {
         super(featureName,featureConfig);
         this.parseTaskObjectsFromConfig(this.QUEST_NAME);
         this.parseRewardsDataFromConfig(this.QUEST_NAME);
         this.m_resultObject = new Object();
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
      }
      
      public static function getInstance(featureName:String = "Dec19Innovation") : Dec19InnovationManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,Dec19InnovationManager) as Dec19InnovationManager;
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
      
      public function setupDec19Hud() : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         this.m_dec19InnovationHud = new HudBottomDec19InnovationButton(HUD_DEC19_ASSET,m_featureName);
         Global.hud.setBottomHudDec19InnovationButton(this.m_dec19InnovationHud as HudBottomDec19InnovationButton);
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
         if(userState > this.DONE_FOR_THE_DAY || this.hasActiveDayExpired())
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
               taskLevelCheck = true;
               nextUsedtaskTypeIndexInUserState = (lastUsedtaskTypeIndexInUserState + 1) % 16;
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
                  if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SOUTHINDIA_INNOVATION_TASK_V2) == 2)
                  {
                     nonBuildingTask = true;
                     id = (fatureObject[this.KEY_LAST_TASKS_IDS][taskType] + 1) % 240;
                     while(this.isSameTaskActive(taskType,id) == true)
                     {
                        id = (id + 1) % 240;
                     }
                  }
                  created = true;
               }
            }
            nextTaskType = taskType;
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SOUTHINDIA_INNOVATION_TASK_V2) == 2)
            {
               if(nonBuildingTask == false)
               {
                  nextTaskId = (fatureObject[this.KEY_LAST_TASKS_IDS][nextTaskType] + 1) % 240;
               }
               else
               {
                  nextTaskId = id;
               }
            }
            else
            {
               nextTaskId = (fatureObject[this.KEY_LAST_TASKS_IDS][nextTaskType] + 1) % 240;
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
      
      public function get tileUnlockCount() : int
      {
         var tilesArray:Array = this.TilesArray as Array;
         var lockedCount:int = this.lockedTilesArray.length >= 0 ? int(this.lockedTilesArray.length) : 0;
         return int(tilesArray.length - lockedCount);
      }
      
      public function getTileUnlockCount() : int
      {
         var count:String = null;
         var result:int = 0;
         var featureData:Object = this.getFeatureData();
         var inventoryTileCount:int = FeatureOptionsInventoryManager.getInstance().getCount(DEC19_TILE_UNLOCK_COUNT) as int;
         if(featureData)
         {
            count = featureData[KEY_TILE_UNLOCK_COUNT];
         }
         if(inventoryTileCount > 0 && inventoryTileCount > int(count))
         {
            result = inventoryTileCount - int(count);
         }
         return result;
      }
      
      public function addTileUnlockCount() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"addTileUnlockCount",this.addTileUnlockFeatureOption,[m_featureName]),true);
      }
      
      public function addTileUnlockFeatureOption(result:Object) : void
      {
         var inventoryTileCount:Number = NaN;
         var featureData:Object = null;
         if(result)
         {
            inventoryTileCount = FeatureOptionsInventoryManager.getInstance().getCount(DEC19_TILE_UNLOCK_COUNT);
            if(inventoryTileCount)
            {
               featureData = this.getFeatureData();
               featureData[KEY_TILE_UNLOCK_COUNT] = inventoryTileCount;
               setFeatureData(featureData);
            }
         }
      }
      
      private function getKingdomText(task:FarmTask) : String
      {
         var result:String = "";
         switch(task.helperType)
         {
            case QuestConstants.HELPER_TYPE_OPEN_FEATURE_CRAFTING:
            case QuestConstants.HELPER_TYPE_POP_STORAGE_BUILDING_DIALOG:
            case QuestConstants.HELPER_TYPE_CHAPTER_QUEST:
               result = "Open Reward";
               break;
            case QuestConstants.HELPER_TYPE_POST_ASK_FOR_ITEM_FEED_SPECIAL_QUEST:
               result = "Ask";
               break;
            case QuestConstants.HELPER_TYPE_PLANT_SEED:
               result = "Plant";
               break;
            case QuestConstants.HELPER_TYPE_OPEN_CRAFTING:
               result = "Craft";
               break;
            case QuestConstants.HELPER_TYPE_PAN_TO_ITEM:
               result = "Harvest BB";
               break;
            case QuestConstants.HELPER_TYPE_SINK_GOLD:
               result = "Spend Coins";
               break;
            default:
               if(task.action == QuestConstants.TASK_HARVEST_BY_CATEGORY)
               {
                  if(task.type == "AllDreamworldR1Animal")
                  {
                     result = "Harvest Animals";
                  }
                  else if(task.type == "AllDreamworldR1Trees")
                  {
                     result = "Harvest Trees";
                  }
               }
         }
         return result;
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
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
         if(this.m_buyWindow)
         {
            this.m_buyWindow.close();
         }
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
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("dec19_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq) && this.isFeatureInActivePeriod())
         {
            ConsumableItem = Global.farmGameSettingsManager.getFarmItemByCode(this.ConsumableCode);
            UI.displayPopup(new Dec19InnovationTileUnlockwindow(FV_REWARD_DIALOG_ASSET,featureName,ConsumableItem,null,SANTA_VILLAGE_REWARD_DIALOG_BG_ASSET));
         }
         if(!Global.player.getSeenFlag(this.TILE_UNLOCK))
         {
            Global.player.setSeenFlag(this.TILE_UNLOCK);
         }
         FarmStatsManager.count(m_featureName,"UnlockTile",null,null,this.consumableCount.toString(),"50");
      }
      
      public function showDailyBonusGrantPopup(rewardItem:FarmItem) : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         FarmStatsManager.count(m_featureName,"feature_ui","dailyBonusPopup");
         UI.displayPopup(new Dec19InnovationDailyBonusGrantWindow(FV_REWARD_DIALOG_ASSET,featureName,rewardItem,null,SANTA_VILLAGE_REWARD_DIALOG_BG_ASSET),false);
      }
      
      public function showLeagueRewardGrantPopup(rewardItem:FarmItem = null, performanceType:String = "") : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         FarmStatsManager.count(m_featureName,"feature_ui","LeagueRewardGrantPopup");
         UI.displayPopup(new Dec19InnovationLeagueRewardWindow(FV_REWARD_DIALOG_ASSET,featureName,rewardItem,null,SANTA_VILLAGE_REWARD_DIALOG_BG_ASSET,performanceType),false);
      }
      
      public function showMainUI(showTutorialWithEAPage:Boolean = false) : void
      {
         var leaderBoardData:Object = null;
         var currentLeaderboard:String = null;
         if(!m_initialized)
         {
            this.initialize();
         }
         if(this.isFeatureInActivePeriod())
         {
            leaderBoardData = this.getCurrentLeaderboard();
            currentLeaderboard = leaderBoardData.name;
         }
         var featureData:Object = this.getFeatureData();
         if(featureData[KEY_CURRENT_LEADERBOARD] == "")
         {
            featureData[KEY_CURRENT_LEADERBOARD] = currentLeaderboard;
            featureData[KEY_SHOW_LEADERBOARD_FIRST_TIME_IN_WEEK] = 1;
            setFeatureData(featureData);
         }
         if(this.isShowLeaderBoardPopup())
         {
            featureData[KEY_SHOW_LEADERBOARD_FIRST_TIME_IN_WEEK] = 1;
            setFeatureData(featureData);
            this.showLeaderboardUI(true);
         }
         else if(featureData[this.KEY_SHOULD_GRANT_LEAGUE_REWARD] == true)
         {
            this.grantLeagueReward();
            this.resetGrantLeagueRewardKey();
         }
         else if(this.isFeatureInActivePeriod())
         {
            this.resetActivePopupCount();
            this.m_mainWindow = new Dec19InnovationMainWindow(m_featureName,this.mainWindowURL,showTutorialWithEAPage);
            UI.displayPopup(this.m_mainWindow);
         }
         FarmStatsManager.count("Dec19Innovation","feature_ui","main_ui","impression");
      }
      
      public function shouldUpdateLeague() : Boolean
      {
         var currentWeek:int = 0;
         var featureData:Object = this.getFeatureData();
         currentWeek = int(this.getCurrentWeek().count);
         var keyLeagueUpdatedForWeek:String = KEY_LEAGUE_UPDATED_FOR_WEEK + currentWeek.toString();
         return !featureData.hasOwnProperty(keyLeagueUpdatedForWeek);
      }
      
      public function showLeaderboardUI(showGift:Boolean = false) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.updateLeagueOverlay();
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         FarmStatsManager.count("Dec19Innovation","Leaderboard","Click");
         this.m_leaderboardWindow = new Dec19InnovationLeaderboardWindow(this.LEADERBOARD_WINDOW,m_featureName,null,null,showGift);
         UI.displayPopup(this.m_leaderboardWindow,false);
      }
      
      public function showLeaderboardRewardUI(e:Event) : void
      {
         var leaderboardRewardWindow:Dec19InnovationLeaderboardRewardWindow = null;
         if(this.m_leaderboardWindow)
         {
            this.m_leaderboardWindow.tintWindow();
            this.m_leaderboardWindow.enableInput = false;
         }
         leaderboardRewardWindow = new Dec19InnovationLeaderboardRewardWindow(this.LEADERBOARD_REWARD_WINDOW,m_featureName);
         UI.displayPopup(leaderboardRewardWindow,false);
      }
      
      public function showChristmasSurpriseUI() : void
      {
         var christmasSurpriseWindow:Dec19InnovationChristmasSurpriseWindow = null;
         christmasSurpriseWindow = new Dec19InnovationChristmasSurpriseWindow(this.CHRISTMAS_SURPRISE_WINDOW,m_featureName);
         UI.displayPopup(christmasSurpriseWindow,false);
      }
      
      public function showLeagueInfoUI(e:Event) : void
      {
         var leagueInfoWindow:Dec19InnovationLeagueInfoWindow = null;
         if(this.getOverlaySeenFlag() == false)
         {
            this.setOverlaySeenFlag();
         }
         if(this.m_leaderboardWindow)
         {
            this.m_leaderboardWindow.updateOverlay();
            this.m_leaderboardWindow.tintWindow();
            this.m_leaderboardWindow.enableInput = false;
         }
         leagueInfoWindow = new Dec19InnovationLeagueInfoWindow(this.LEAGUE_INFO_WINDOW,m_featureName);
         UI.displayPopup(leagueInfoWindow,false);
      }
      
      public function openBuyWindow(owner:FarmWindow) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         this.m_buyWindow = new Dec19InnovationBuyWindow(this.buyDialogURL,m_featureName,this.getBucketPackages(),owner,this.mainWindow);
         UI.displayPopup(this.m_buyWindow,false);
         FarmStatsManager.count("Dec19Innovation","Click","Gift Ribbon","BuyWindow");
      }
      
      private function resetActivePopupCount() : void
      {
         this.m_activePopupCount = 0;
      }
      
      public function incrementActivePopupCount() : void
      {
         this.m_activePopupCount += 1;
      }
      
      public function decrementActivePopupCount() : void
      {
         this.m_activePopupCount = this.m_activePopupCount - 1 > 0 ? int(this.m_activePopupCount - 1) : 0;
      }
      
      public function canUntintMainWindow() : Boolean
      {
         return this.m_activePopupCount == 0;
      }
      
      public function getOverlaySeenFlag() : Boolean
      {
         var result:Boolean = true;
         if(Global.player.getSeenFlag(this.LEAGUE_OVERLAY_FLAG) == false)
         {
            result = false;
         }
         return result;
      }
      
      public function setOverlaySeenFlag() : void
      {
         if(Global.player.getSeenFlag(this.LEAGUE_OVERLAY_FLAG) == false)
         {
            Global.player.setSeenFlag(this.LEAGUE_OVERLAY_FLAG);
         }
      }
      
      public function craftConsumableFromMainWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
         var consumableSearchStr:String = "Gift Ribbon";
         CraftingManager.getInstance().openCraftshopWindow(CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType),consumableSearchStr,this.m_mainWindow,CRAFTSHOP_CONSUMABLE_TAB);
         FarmStatsManager.count("Dec19Innovation","Craft","Gift Ribbon",this.consumableCount.toString());
      }
      
      public function initialize() : void
      {
         this.loadStaticData();
      }
      
      private function loadStaticData() : void
      {
         var itemXML:XML = null;
         var tile:XML = null;
         var asset:XML = null;
         var tileName:String = null;
         var leaderboardxml:XML = null;
         var weekxml:XML = null;
         this.m_staticData = new Object();
         this.m_staticData.typeArray = [];
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
         this.m_staticData.weeks = new Array();
         this.m_staticData.leaderboardConfigData = new Array();
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
            for each(itemXML in featureXML.bucketPackages.bucketPackage)
            {
               this.m_staticData.bucketPackages.push(itemXML.@name.toString());
            }
            for each(tile in featureXML.items.item)
            {
               tileName = tile.@name.toString();
               this.m_staticData.tilesArray.push(tileName);
            }
            if(featureXML.leaderboardConfig)
            {
               for each(leaderboardxml in featureXML.leaderboardConfig.leaderboard)
               {
                  this.m_staticData.leaderboardConfigData.push(leaderboardxml);
               }
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
         if(!m_initialized)
         {
            this.initialize();
         }
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
            FarmStatsManager.count("Dec19Innovation","Ask","Gift Ribbon");
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
         timeLeft = (FarmGameUtil.synchronizedDateToNumber(this.bonusGrantDate) - this.REDEEM_ADDITIONAL_DAYS * FarmGameUtil.NUM_MSECS_IN_DAY - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
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
      
      public function isLastDay() : Boolean
      {
         var result:Boolean = false;
         var dayIndex:int = this.activeDayIndex;
         var totalDays:int = this.NO_OF_WEEKS * 7;
         if(dayIndex == totalDays - 1)
         {
            result = true;
         }
         return result;
      }
      
      public function skipTask(slotIndex:int, callback:Function) : void
      {
         var featureObject:Object = null;
         var questTasks1:Vector.<FarmTask> = null;
         var taskPt:int = 0;
         var taskLBPt:int = 0;
         var fItemName:String = null;
         var code:String = null;
         var tasks:Vector.<FarmTask> = this.getActiveTasks();
         if(Global.player.canBuyCash(tasks[slotIndex].skipCashValue))
         {
            Global.player.cash -= tasks[slotIndex].skipCashValue;
            featureObject = this.getFeatureData();
            questTasks1 = Dec19InnovationManager.getInstance(m_featureName).getActiveTasks();
            taskPt = questTasks1[slotIndex].questPoints;
            taskLBPt = questTasks1[slotIndex].questPoints;
            if(featureObject[this.KEY_DAY_POINTS] + questTasks1[slotIndex].questPoints > this.VAL_THIRD_MILESTONE)
            {
               taskPt = this.VAL_THIRD_MILESTONE - featureObject[this.KEY_DAY_POINTS];
            }
            featureObject[this.KEY_DAY_POINTS] += questTasks1[slotIndex].questPoints;
            featureObject[this.WEEKLY_SCORE] += questTasks1[slotIndex].questPoints;
            setFeatureData(featureObject);
            this.mainWindow.untintWindow();
            this.mainWindow.enableInput = true;
            if(this.hasActiveDayExpired() == false && this.getUserState() != this.DONE_FOR_THE_DAY)
            {
               this.m_mainWindow.updateTaskDoober(taskPt);
            }
            if(this.getDayEndMessageShown() == true)
            {
               this.m_mainWindow.updateLeaderboardDoober(taskLBPt);
            }
            this.checkAndUpdateUserState();
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipTask",null,[m_featureName,slotIndex]),true);
            this.resetActionCountsForTasks(tasks[slotIndex]);
            this.generateAndSaveNewTask(slotIndex);
            fItemName = null;
            if(tasks[slotIndex].action == "completeFeatureCraftingNPC")
            {
               fItemName = "Toy Ho! Stable";
            }
            else
            {
               code = tasks[slotIndex].type;
               fItemName = this.getTaskItemName(code);
            }
            if(fItemName == null)
            {
               fItemName = "Dec19 Task";
            }
            FarmStatsManager.count("Dec19Innovation","SkipTask",this.getKingdomText(tasks[slotIndex]),tasks[slotIndex].titleText,featureObject[this.KEY_DAY_POINTS].toString(),questTasks1[slotIndex].questPoints.toString(),tasks[slotIndex].skipCashValue);
            this.m_mainWindow.refreshTaskFrame();
            this.m_mainWindow.updateProgressBar();
            this.m_mainWindow.updateLeaderBoardFrame(this.getWeeklyLeaderboardPoints(),0);
            this.m_mainWindow.showActiveNPCForCurrentLeague();
            this.updateCurrentAverageKey();
         }
         else
         {
            callback.call();
         }
      }
      
      public function redeemSlotTask(slotIndex:int) : void
      {
         var questTasks1:Vector.<FarmTask> = null;
         var code:String = null;
         var tasks:Vector.<FarmTask> = this.getActiveTasks();
         var featureObject:Object = this.getFeatureData();
         questTasks1 = Dec19InnovationManager.getInstance(m_featureName).getActiveTasks();
         var taskPt:int = questTasks1[slotIndex].questPoints;
         var taskLBPt:int = questTasks1[slotIndex].questPoints;
         if(featureObject[this.KEY_DAY_POINTS] + questTasks1[slotIndex].questPoints > this.VAL_THIRD_MILESTONE)
         {
            taskPt -= this.VAL_THIRD_MILESTONE - featureObject[this.KEY_DAY_POINTS];
         }
         featureObject[this.KEY_DAY_POINTS] += questTasks1[slotIndex].questPoints;
         featureObject[this.WEEKLY_SCORE] += questTasks1[slotIndex].questPoints;
         setFeatureData(featureObject);
         this.resetActionCountsForTasks(tasks[slotIndex]);
         if(this.hasActiveDayExpired() == false && this.getUserState() != this.DONE_FOR_THE_DAY)
         {
            this.m_mainWindow.updateTaskDoober(taskPt);
         }
         if(this.getDayEndMessageShown() == true)
         {
            this.m_mainWindow.updateLeaderboardDoober(taskLBPt);
         }
         if(this.hasActiveDayExpired() == false)
         {
            this.checkAndUpdateUserState();
         }
         else
         {
            this.redeemHasStarted = true;
            this.m_mainWindow.updateTaskDoober(taskPt);
         }
         var fItemName:String = null;
         if(tasks[slotIndex].action == "completeFeatureCraftingNPC")
         {
            fItemName = "Toy Ho! Stable";
         }
         else
         {
            code = tasks[slotIndex].type;
            fItemName = this.getTaskItemName(code);
         }
         if(fItemName == null)
         {
            fItemName = "Dec19 Task";
         }
         FarmStatsManager.count("Dec19Innovation","RedeemTask",this.getKingdomText(tasks[slotIndex]),tasks[slotIndex].titleText,featureObject[this.KEY_DAY_POINTS].toString(),questTasks1[slotIndex].questPoints.toString(),tasks[slotIndex].skipCashValue);
         this.generateAndSaveNewTask(slotIndex);
         this.m_mainWindow.refreshTaskFrame();
         this.m_mainWindow.updateProgressBar();
         this.m_mainWindow.updateLeaderBoardFrame(this.getWeeklyLeaderboardPoints());
         this.m_mainWindow.showActiveNPCForCurrentLeague();
         this.updateCurrentAverageKey();
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
               this.grantUserRewardforLevel(this.EASY);
               FarmStatsManager.count("Dec19Innovation","userstate",(this.activeDayIndex + 1).toString(),"EXPERT",dayPoints.toString(),this.consumableCount.toString(),this.getCurrentAverage());
               FarmStatsManager.count("Dec19Innovation","dailyReward","EXPERT",this.getActiveDayReward(this.EASY).friendlyTitle,(this.activeDayIndex + 1).toString(),this.getActiveWeek());
            }
            else if(dayPoints >= this.VAL_SECOND_MILESTONE && userState == this.MEDIUM)
            {
               featureObj[this.KEY_USER_STATE] = this.LOCK2;
               this.grantUserRewardforLevel(this.MEDIUM);
               FarmStatsManager.count("Dec19Innovation","userstate",(this.activeDayIndex + 1).toString(),"PROFESSIONAL",dayPoints.toString(),this.consumableCount.toString(),this.getCurrentAverage());
               FarmStatsManager.count("Dec19Innovation","dailyReward","PROFESSIONAL",this.getActiveDayReward(this.EASY).friendlyTitle,(this.activeDayIndex + 1).toString(),this.getActiveWeek());
            }
            else if(dayPoints >= this.VAL_THIRD_MILESTONE && userState == this.HARD)
            {
               featureObj[this.KEY_USER_STATE] = this.DONE_FOR_THE_DAY;
               this.grantUserRewardforLevel(this.HARD);
               this.showDailyBonusGrantPopup(this.getActiveDayReward(this.HARD));
               FarmStatsManager.count("Dec19Innovation","userstate",(this.activeDayIndex + 1).toString(),"CHAMPION",dayPoints.toString(),this.consumableCount.toString(),this.getCurrentAverage());
               FarmStatsManager.count("Dec19Innovation","dailyReward","CHAMPION",this.getActiveDayReward(this.EASY).friendlyTitle,(this.activeDayIndex + 1).toString(),this.getActiveWeek());
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
            FarmStatsManager.count("Dec19Innovation","sink","Gift Ribbons",null,this.consumableCount.toString(),consumableNeeded.toString());
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
      
      public function getTaskItemName(code:String) : String
      {
         var fItem:FarmItem = null;
         var result:String = null;
         if(code == "gold")
         {
            result = "Coins";
         }
         else if(code == "AllSantavillageAnimals")
         {
            result = "Santavillage Animals";
         }
         else if(code == "AllSantavillageTrees")
         {
            result = "Santavillage Trees";
         }
         else
         {
            fItem = Global.farmGameSettingsManager.getFarmItemByCode(code);
            result = fItem.friendlyTitle;
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
         var tasks:Vector.<FarmTask> = null;
         var fItemName:String = null;
         var code:String = null;
         if(this.canDumpTask(slotIndex))
         {
            if(this.m_mainWindow)
            {
               this.m_mainWindow.untintWindow();
               this.m_mainWindow.enableInput = true;
            }
            featureData = this.getFeatureData();
            tasks = this.getActiveTasks();
            featureData[KEY_SAVED_DUMPED_TIMESTAMP][slotIndex] = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            featureData[KEY_SAVED_ACTIVE_TASKS][slotIndex][this.KEY_DUMPED_STATUS] = 1;
            setFeatureData(featureData);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"dumpTask",null,[m_featureName,slotIndex]),true);
            fItemName = null;
            if(tasks[slotIndex].action == "completeFeatureCraftingNPC")
            {
               fItemName = "Toy Ho! Stable";
            }
            else
            {
               code = tasks[slotIndex].type;
               fItemName = this.getTaskItemName(code);
            }
            if(fItemName == null)
            {
               fItemName = "Dec19 Task";
            }
            FarmStatsManager.count("Dec19Innovation","Trash",this.getKingdomText(tasks[slotIndex]),tasks[slotIndex].titleText);
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
            FarmStatsManager.count("Dec19Innovation","SkipTrashedTask",(this.activeDayIndex + 1).toString(),null,null,null,1);
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
            Global.player.gold -= tasks[slotIndex].total;
            this.postTaskCompletionActions(slotIndex);
            FarmStatsManager.count("Dec19Innovation","sinkGold",tasks[slotIndex].type,this.currentDayIndex.toString());
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkGold",null,[m_featureName,slotIndex]),true);
         }
      }
      
      public function sinkBushel(slotIndex:int) : void
      {
         var tasks:Vector.<FarmTask> = this.getActiveTasks();
         CraftingManager.getInstance().deductItemFromCraftingInventory(tasks[slotIndex].type,tasks[slotIndex].total);
         this.postTaskCompletionActions(slotIndex);
         FarmStatsManager.count("Dec19Innovation","sinkBushel",tasks[slotIndex].type,this.currentDayIndex.toString());
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkBushel",null,[m_featureName,slotIndex]),true);
      }
      
      public function postTaskCompletionActions(completedTaskSlotIndex:int) : void
      {
         var questTasks1:Vector.<FarmTask> = null;
         var featureObject:Object = this.getFeatureData();
         questTasks1 = Dec19InnovationManager.getInstance(m_featureName).getActiveTasks();
         var taskPt:int = questTasks1[completedTaskSlotIndex].questPoints;
         var taskLBPt:int = questTasks1[completedTaskSlotIndex].questPoints;
         if(featureObject[this.KEY_DAY_POINTS] + questTasks1[completedTaskSlotIndex].questPoints > this.VAL_THIRD_MILESTONE)
         {
            taskPt -= this.VAL_THIRD_MILESTONE - featureObject[this.KEY_DAY_POINTS];
         }
         featureObject[this.KEY_DAY_POINTS] += questTasks1[completedTaskSlotIndex].questPoints;
         featureObject[this.WEEKLY_SCORE] += questTasks1[completedTaskSlotIndex].questPoints;
         setFeatureData(featureObject);
         if(this.hasActiveDayExpired() == false && this.getUserState() != this.DONE_FOR_THE_DAY)
         {
            this.m_mainWindow.updateTaskDoober(taskPt);
         }
         if(this.getDayEndMessageShown() == true)
         {
            this.m_mainWindow.updateLeaderboardDoober(taskLBPt);
         }
         if(this.hasActiveDayExpired() == true)
         {
            this.redeemHasStarted = true;
            this.m_mainWindow.updateTaskDoober(taskPt);
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
         this.m_mainWindow.updateLeaderBoardFrame(this.getWeeklyLeaderboardPoints());
         this.m_mainWindow.showActiveNPCForCurrentLeague();
         this.updateCurrentAverageKey();
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
            featureData[this.KEY_LAST_USED_TYPE][this.DONE_FOR_THE_DAY] = -1;
            featureData[this.KEY_LAST_TASKS_IDS] = {};
            featureData[this.KEY_LAST_TASKS_IDS][this.KEY_MISC_EASY] = -1;
            featureData[this.KEY_LAST_TASKS_IDS][this.KEY_MISC_MEDIUM] = -1;
            featureData[this.KEY_LAST_TASKS_IDS][this.KEY_MISC_HARD] = -1;
            featureData[this.KEY_LAST_TASKS_IDS][this.KEY_MISC_DONE_FOR_THE_DAY] = -1;
            featureData[this.KEY_LAST_TASKS_IDS][this.KEY_BB] = -1;
            featureData[this.KEY_LAST_TASKS_IDS][this.KEY_EH] = -1;
            featureData[this.KEY_LAST_TASKS_IDS][this.KEY_HB] = -1;
            featureData[this.KEY_DAY_POINTS] = 0;
            featureData[this.WEEKLY_SCORE] = 0;
            featureData[KEY_SAVED_DUMPED_TIMESTAMP] = {};
            featureData[KEY_FLUSH_DAILY_REWARD_TASK] = false;
            featureData[KEY_LEADERBOARD_EA_POINTS_GRANTED] = false;
            featureData[KEY_CURRENT_WEEK] = 0;
            featureData[KEY_CURRENT_LEADERBOARD] = "";
            featureData[this.KEY_CURRENT_LEAGUE] = 0;
            featureData[this.KEY_LEAGUE_DOWNGRADE] = false;
            featureData[this.KEY_LEAGUE_UPGRADE] = false;
            featureData[this.KEY_SHOULD_GRANT_LEAGUE_REWARD] = false;
            featureData[KEY_GA_FEATURE_START] = false;
            featureData[KEY_EA_CONSUMABLE_BENEFIT_GIVEN] = false;
            featureData[this.KEY_CURRENT_AVERAGE] = 0;
            featureData[KEY_TILE_UNLOCK_COUNT] = 0;
            featureData[KEY_SAVED_LEADERBOARD_RESULT] = {};
            featureData[KEY_SHOW_LEADERBOARD_FIRST_TIME_IN_WEEK] = 1;
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
         orderBoardXml = Global.farmGameSettingsManager.getXML().Dec19InnovationQuests.Dec19InnovationQuest.(@name == questName)[0];
         rewardsList = orderBoardXml.Dec19InnovationRewards.stage;
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
         var index:int = stageNum / 7;
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
         var fItemName:String = null;
         var code:String = null;
         var hasUpdatedProgress:Boolean = false;
         var hasCompletedTask:Boolean = false;
         var progressArray:Array = [];
         var tasks:Vector.<FarmTask> = this.getActiveTasks();
         var featureData:Object = this.getFeatureData();
         for(var i:int = 0; i < tasks.length; i++)
         {
            transaction = event.transaction as TFarmTransaction;
            fItemName = null;
            if(tasks[i].action == "completeFeatureCraftingNPC")
            {
               fItemName = "Toy Ho! Stable";
            }
            else
            {
               code = tasks[i].type;
               fItemName = this.getTaskItemName(code);
            }
            if(fItemName == null)
            {
               fItemName = "Dec19 Task";
            }
            if(tasks[i].helperType == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
            {
               progress = CraftingManager.getInstance().getBushelQuantityInInventory(tasks[i].type) - featureData[KEY_SAVED_ACTIVE_TASKS][i][this.KEY_PROGRESS];
               hasUpdatedProgress = true;
               FarmStatsManager.count("Dec19Innovation","PerformTask",this.getKingdomText(tasks[i]),"",tasks[i].titleText);
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
                  FarmStatsManager.count("Dec19Innovation","PerformTask",this.getKingdomText(tasks[i]),"",tasks[i].titleText);
               }
            }
         }
         if(hasUpdatedProgress)
         {
            this.saveProgressForPlayer(progressArray);
         }
         if(hasCompletedTask)
         {
            if(this.m_dec19InnovationHud)
            {
               this.m_dec19InnovationHud.refresh(1);
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
               buildingName = "xws_elitehorses";
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
         var rewardItem:FarmItem = null;
         var reward:Object = this.getRewardsForTheDay()[level];
         if(level == 2)
         {
            rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(reward["value"]);
            this.checkAndAddToInventory(rewardItem.name);
         }
         UserRewardUtil.grantUserReward(reward);
      }
      
      public function getActiveDayReward(level:int) : FarmItem
      {
         var rewardCode:String = (this.getRewardsForTheDay()[level] as Object).value;
         var featureObj:Object = this.getFeatureData();
         var runesFarmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(rewardCode);
         if(!runesFarmItem)
         {
            runesFarmItem = Global.farmGameSettingsManager.getFarmItemByCode("0Ev");
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
      
      public function hasActiveWeekExpired() : Boolean
      {
         var activeWeek:int = 0;
         var expired:Boolean = false;
         var featureData:Object = this.getFeatureData();
         var weekData:Object = this.getCurrentWeek();
         var curWeek:int = int(weekData.count);
         if(featureData.hasOwnProperty(KEY_CURRENT_WEEK))
         {
            activeWeek = int(featureData[KEY_CURRENT_WEEK]);
            if(activeWeek != curWeek)
            {
               expired = true;
            }
         }
         return expired;
      }
      
      public function startNewDay(e:Event = null) : void
      {
         var weekObjFirst:Object = null;
         var curWeekFirst:int = 0;
         var weekObj:Object = null;
         var curWeek:int = 0;
         var i:int = 0;
         var featureData:Object = this.getFeatureData();
         if(this.hasActiveDayExpired() == true || featureData[this.KEY_USER_STATE] == this.NOT_INITIALIZED)
         {
            if(this.getOverlaySeenFlag() == false)
            {
               this.m_mainWindow.displayLeagueOverlay();
            }
            this.mainWindow.updateActiveDay();
            this.mainWindow.updateActiveDayIndex();
            if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_SANTAVILLAGE) == false)
            {
               if(featureData.hasOwnProperty(KEY_GA_FEATURE_START) && featureData[KEY_GA_FEATURE_START] == false)
               {
                  featureData[KEY_GA_FEATURE_START] = true;
                  FeatureOptionsInventoryManager.getInstance().addCount(this.ConsumableCode,5);
               }
            }
            if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_SANTAVILLAGE) == true)
            {
               if(featureData.hasOwnProperty(KEY_EA_CONSUMABLE_BENEFIT_GIVEN) && featureData[KEY_EA_CONSUMABLE_BENEFIT_GIVEN] == false)
               {
                  featureData[KEY_EA_CONSUMABLE_BENEFIT_GIVEN] = true;
                  FeatureOptionsInventoryManager.getInstance().addCount(this.ConsumableCode,40);
               }
            }
            this.redeemHasStarted = false;
            this.redeemMessageShown = false;
            if(this.hasActiveDayExpired())
            {
               featureData[this.KEY_DAILY_PROGRESS_POINTS][this.activeDayIndex] = featureData[this.KEY_DAY_POINTS] > this.VAL_THIRD_MILESTONE ? this.VAL_THIRD_MILESTONE : featureData[this.KEY_DAY_POINTS];
            }
            if(featureData.hasOwnProperty(KEY_CURRENT_WEEK) && featureData[KEY_CURRENT_WEEK] == 0)
            {
               weekObjFirst = this.getCurrentWeek();
               curWeekFirst = int(weekObjFirst.count);
               featureData[KEY_CURRENT_WEEK] = curWeekFirst.toString();
            }
            else if(this.hasActiveWeekExpired())
            {
               weekObj = this.getCurrentWeek();
               curWeek = int(weekObj.count);
               featureData[KEY_CURRENT_WEEK] = curWeek.toString();
            }
            featureData[this.KEY_ACTIVE_DAY_TIMESTAMP] = FarmGameUtil.getMidnightTimestamp() / 1000;
            this.m_mainWindow.displayLastDayOverlay();
            this.mainWindow.updateActiveDay();
            if(this.isChristmasWeek())
            {
               if(Boolean(this.m_mainWindow) && Boolean(this.m_mainWindow.m_gift_mc))
               {
                  this.m_mainWindow.m_gift_mc.visible = true;
               }
            }
            this.mainWindow.updateActiveDayIndex();
            if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_SANTAVILLAGE))
            {
               if(WorldSeasonsManager.getInstance().isEAWeek(WorldsConstants.WORLD_ID_SANTAVILLAGE))
               {
                  featureData[this.KEY_DAY_POINTS] = this.VAL_FIRST_MILESTONE;
                  featureData[this.KEY_USER_STATE] = this.MEDIUM;
                  if(featureData[KEY_LEADERBOARD_EA_POINTS_GRANTED] == false)
                  {
                     featureData[KEY_LEADERBOARD_EA_POINTS_GRANTED] = true;
                     featureData[this.WEEKLY_SCORE] += 7 * this.VAL_FIRST_MILESTONE;
                  }
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
               featureData[KEY_FLUSH_DAILY_REWARD_TASK] = false;
               this.m_mainWindow.refreshWindow();
               this.m_mainWindow.updateLeaderBoardFrame(this.getWeeklyLeaderboardPoints());
            }
            FarmStatsManager.count("Dec19Innovation","startNewDay",this.consumableCount.toString(),this.getWeeklyLeaderboardPoints().toString(),(this.activeDayIndex + 1).toString(),this.getActiveWeek().toString(),this.getCurrentAverage());
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
      
      public function getUserDataFromLeaderboard() : Object
      {
         var featureData:Object = this.getFeatureData();
         return featureData[KEY_SAVED_LEADERBOARD_RESULT];
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
      
      public function getTimeLeftInWeek() : Number
      {
         var weekData:Object = this.getCurrentWeek();
         if(weekData == null)
         {
            return -1;
         }
         var weekExpiredTimeInString:String = weekData.end;
         var weekExpiredTime:Number = FarmGameUtil.synchronizedDateTimeToNumber(weekExpiredTimeInString) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return weekExpiredTime - currenttime;
      }
      
      public function checkLastDayInWeek() : int
      {
         var days:int = 0;
         var hours:int = 0;
         var result:Number = this.getTimeLeftInWeek();
         if(result < 0)
         {
            result = 0;
         }
         var timeLeftArray:Array = FarmGameUtil.parseTimeLeft(result);
         if(Boolean(timeLeftArray) && timeLeftArray.length > 3)
         {
            days = int(timeLeftArray[0]);
            hours = int(timeLeftArray[1]);
         }
         return days;
      }
      
      public function showNPCCallouts(calloutTitle:String = null, calloutText:String = null) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.showNPCCallouts(calloutTitle,calloutText);
         }
      }
      
      public function showAutoHideNPCCallouts(title:String, text:String) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.showAutoHideNPCCallouts(title,text);
         }
      }
      
      public function hideNPCCallout() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.hideNPCCallout();
         }
      }
      
      public function npcCalloutSlot() : Boolean
      {
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_SANTAVILLAGE) == true)
         {
            if(this.activeDayIndex < 7 && this.getTotalPointsForUser() <= (this.activeDayIndex + 1) * 10)
            {
               return true;
            }
            if(this.activeDayIndex >= 7 && this.getTotalPointsForUser() == 7 * this.VAL_FIRST_MILESTONE)
            {
               return true;
            }
            return false;
         }
         if(this.getTotalPointsForUser() == 0)
         {
            return true;
         }
         return false;
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
                  msg = "Collect more Gift Ribbons to unlock the next level";
               }
               else
               {
                  msg = "Use Gift Ribbons to unlock the next level.";
               }
            }
         }
         return msg;
      }
      
      public function overAllProgressLevel() : int
      {
         var progressLevel:int = -1;
         var avg:int = this.getCurrentAverage();
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
      
      public function getTotalPointsForUser(startDayindex:int = 0) : int
      {
         var totalPoints:int = 0;
         var featureData:Object = this.getFeatureData();
         for(var index:int = startDayindex; index < this.activeDayIndex; index++)
         {
            if(featureData[this.KEY_DAILY_PROGRESS_POINTS].hasOwnProperty(index))
            {
               totalPoints += int(featureData[this.KEY_DAILY_PROGRESS_POINTS][index]);
            }
         }
         if(featureData.hasOwnProperty(this.KEY_DAY_POINTS))
         {
            totalPoints += int(featureData[this.KEY_DAY_POINTS]) > this.VAL_THIRD_MILESTONE ? this.VAL_THIRD_MILESTONE : featureData[this.KEY_DAY_POINTS];
         }
         return totalPoints;
      }
      
      public function getCurrentWeekStartDayIndex() : int
      {
         var numDay:int = this.activeDayIndex % 7;
         return this.activeDayIndex - numDay;
      }
      
      public function hasLeagueUpgraded() : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(Boolean(featureData) && featureData.hasOwnProperty(this.KEY_LEAGUE_UPGRADE))
         {
            if(featureData[this.KEY_LEAGUE_UPGRADE] == true)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function hasLeagueDowngraded() : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(Boolean(featureData) && featureData.hasOwnProperty(this.KEY_LEAGUE_DOWNGRADE))
         {
            if(featureData[this.KEY_LEAGUE_DOWNGRADE] == true)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function hasLeagueChanged() : Boolean
      {
         return this.hasLeagueUpgraded() || this.hasLeagueDowngraded();
      }
      
      public function getCurrentAverage() : int
      {
         var totalDaysForAvg:int = this.currentDayIndex > 41 ? 42 : int(this.currentDayIndex + 1);
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_SANTAVILLAGE) == false)
         {
            totalDaysForAvg -= 7;
         }
         else if(totalDaysForAvg > 35)
         {
            totalDaysForAvg = 35;
         }
         return int(this.getTotalPointsForUser() / totalDaysForAvg);
      }
      
      public function updateCurrentAverageKey() : void
      {
         var featureConfig:Object = this.getFeatureData();
         featureConfig[this.KEY_CURRENT_AVERAGE] = this.getCurrentAverage();
         setFeatureData(featureConfig);
      }
      
      public function resetLeagueChangeKey(upgrade:Boolean = true) : void
      {
         var featureData:Object = this.getFeatureData();
         var key:String = upgrade ? this.KEY_LEAGUE_UPGRADE : this.KEY_LEAGUE_DOWNGRADE;
         if(!featureData || !featureData.hasOwnProperty(key))
         {
            return;
         }
         featureData[key] = false;
         setFeatureData(featureData);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"resetLeagueChangeKey",null,[m_featureName,upgrade]));
      }
      
      public function getNextLeagueRewardItem() : FarmItem
      {
         var curWeek:int = 0;
         var weekObj:Object = this.getCurrentWeek();
         curWeek = int(weekObj.count);
         var week:String = curWeek.toString();
         var currRewardType:String = this.DEC19_LEAGUE_MAP[this.getCurrentLeague()];
         var nextRewardType:String = this.DEC19_LEAGUE_MAP[this.getNextLeague()];
         return Global.farmGameSettingsManager.getFarmItemByName(StringUtil.substitute(this.rewardTemplate,currRewardType,nextRewardType,week));
      }
      
      public function getCurrentLeagueName() : String
      {
         return this.DEC19_LEAGUE_MAP[this.getCurrentLeague()];
      }
      
      public function getLeagueName(i:int = 0) : String
      {
         return this.DEC19_LEAGUE_MAP[i];
      }
      
      private function checkAndAddToInventory(itemName:String) : void
      {
         var validConsumableRewards:Object = {
            "pkg_giftribbon_3":3,
            "pkg_giftribbon_4":4,
            "pkg_giftribbon_5":5
         };
         if(validConsumableRewards.hasOwnProperty(itemName))
         {
            FeatureOptionsInventoryManager.getInstance().addCount(this.ConsumableCode,validConsumableRewards[itemName]);
         }
      }
      
      private function addToInventoryIfConsumable(reward:FarmItem) : void
      {
         var itemName:String = null;
         var packagedItems:Object = reward.getItemPackageHash();
         if(packagedItems != null)
         {
            for(itemName in packagedItems)
            {
               this.checkAndAddToInventory(itemName);
            }
         }
      }
      
      private function resetGrantLeagueRewardKey() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"resetGrantLeagueRewardKey",null,[m_featureName]),true);
      }
      
      public function grantLeagueReward() : void
      {
         var week:String = this.getActiveWeek();
         var featureConfig:Object = this.getFeatureData();
         var prevRewardType:String = this.DEC19_LEAGUE_MAP[this.getPreviousLeague()];
         var currRewardType:String = this.DEC19_LEAGUE_MAP[this.getCurrentLeague()];
         var rewardName:String = StringUtil.substitute(this.rewardTemplate,currRewardType,currRewardType,week);
         var performanceType:String = PERFORMANCE_TYPE.RETENTION;
         featureConfig[this.KEY_SHOULD_GRANT_LEAGUE_REWARD] = false;
         setFeatureData(featureConfig);
         if(featureConfig[this.KEY_LEAGUE_UPGRADE])
         {
            performanceType = PERFORMANCE_TYPE.PROMOTION;
            rewardName = StringUtil.substitute(this.rewardTemplate,prevRewardType,currRewardType,week);
         }
         var reward:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
         if(!reward || Boolean(featureConfig[this.KEY_LEAGUE_DOWNGRADE]))
         {
            this.resetGrantLeagueRewardKey();
            this.showMainUI();
            return;
         }
         Global.player.addGift(rewardName);
         this.addToInventoryIfConsumable(reward);
         this.showLeagueRewardGrantPopup(reward,performanceType);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"grantLeagueReward",null,[m_featureName]),true);
      }
      
      public function updateCurrentLeague(sendTransaction:Boolean = false) : void
      {
         var currentWeek:int = 0;
         var featureConfig:Object = this.getFeatureData();
         var currentLeague:int = int(this.getCurrentLeague());
         currentWeek = int(this.getCurrentWeek().count);
         var keyLeagueUpdatedForWeek:String = KEY_LEAGUE_UPDATED_FOR_WEEK + currentWeek.toString();
         featureConfig[this.KEY_LEAGUE_UPGRADE] = false;
         featureConfig[this.KEY_LEAGUE_DOWNGRADE] = false;
         var weeklyScore:int = this.getWeeklyLeaderboardPoints();
         var leaderboardRank:int = this.getWeeklyLeaderboardRank();
         if(Boolean(featureConfig) && leaderboardRank != -1)
         {
            switch(currentLeague)
            {
               case 0:
                  if(leaderboardRank <= this.LEAGUE_UPGRADE_MAP[currentLeague])
                  {
                     featureConfig[this.KEY_LEAGUE_UPGRADE] = true;
                  }
                  break;
               case 1:
                  if(leaderboardRank <= this.LEAGUE_UPGRADE_MAP[currentLeague])
                  {
                     featureConfig[this.KEY_LEAGUE_UPGRADE] = true;
                  }
                  else if(leaderboardRank >= this.LEAGUE_DOWNGRADE_MAP[currentLeague])
                  {
                     featureConfig[this.KEY_LEAGUE_DOWNGRADE] = true;
                  }
                  break;
               case 2:
                  if(leaderboardRank <= this.LEAGUE_UPGRADE_MAP[currentLeague])
                  {
                     featureConfig[this.KEY_LEAGUE_UPGRADE] = true;
                  }
                  else if(leaderboardRank >= this.LEAGUE_DOWNGRADE_MAP[currentLeague])
                  {
                     featureConfig[this.KEY_LEAGUE_DOWNGRADE] = true;
                  }
                  break;
               case 3:
                  if(leaderboardRank >= this.LEAGUE_DOWNGRADE_MAP[currentLeague])
                  {
                     featureConfig[this.KEY_LEAGUE_DOWNGRADE] = true;
                  }
            }
            if(featureConfig[this.KEY_LEAGUE_UPGRADE] == true)
            {
               currentLeague += 1;
            }
            else if(featureConfig[this.KEY_LEAGUE_DOWNGRADE] == true)
            {
               currentLeague--;
            }
            if(currentLeague >= 0 && currentLeague <= 3)
            {
               featureConfig[this.KEY_CURRENT_LEAGUE] = currentLeague.toString();
            }
            featureConfig[this.WEEKLY_SCORE] = 0;
            featureConfig[keyLeagueUpdatedForWeek] = true;
            setFeatureData(featureConfig);
            this.updateCurrentLeaderboardName();
            if(sendTransaction)
            {
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"updateCurrentLeague",null,[m_featureName]));
            }
         }
      }
      
      public function isLeaderboardExpired(leaderboardName:String) : Boolean
      {
         var leaderboardXML:XML = null;
         var endTs:Number = NaN;
         var isExpired:Boolean = false;
         var leaderboardData:Object = this.getLeaderboardData();
         for each(leaderboardXML in leaderboardData)
         {
            if(leaderboardXML.@name.toString() + this.DEC19_LEAGUE_MAP[this.getCurrentLeague()] == leaderboardName)
            {
               endTs = FarmGameUtil.synchronizedDateToNumber(leaderboardXML.@end.toString());
               if(endTs - GlobalEngine.serverTime < 0)
               {
                  isExpired = true;
               }
            }
         }
         return isExpired;
      }
      
      private function updateCurrentLeaderboardName() : void
      {
         var featureConfig:Object = this.getFeatureData();
         var weeklyLeaderboardData:Object = this.getCurrentLeaderboard();
         if(weeklyLeaderboardData)
         {
            featureConfig[KEY_CURRENT_LEADERBOARD] = weeklyLeaderboardData.name;
         }
         setFeatureData(featureConfig);
      }
      
      public function get currentAverage() : int
      {
         var totalDaysForAvg:int = this.currentDayIndex > 41 ? 42 : int(this.currentDayIndex + 1);
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_SANTAVILLAGE) == false)
         {
            totalDaysForAvg -= 7;
         }
         else if(totalDaysForAvg > 35)
         {
            totalDaysForAvg = 35;
         }
         return int(this.getTotalPointsForUser() / totalDaysForAvg);
      }
      
      public function openRewardViewWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         this.m_rewardWindow = new Dec19InnovationRewardWindow(m_featureName,this.rewardWindowURL);
         UI.displayPopup(this.m_rewardWindow,false);
      }
      
      public function get mainWindow() : Dec19InnovationMainWindow
      {
         return this.m_mainWindow;
      }
      
      public function get activeDayIndex() : int
      {
         var dayIndex:int = 0;
         var featureData:Object = this.getFeatureData();
         var activeDayTS:Number = featureData[this.KEY_ACTIVE_DAY_TIMESTAMP] as Number;
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber(this.DEC19_START_DATE) / FarmGameUtil.NUM_MSECS_IN_SECOND;
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
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber(this.DEC19_START_DATE);
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
         this.showLeaderboardUI(true);
         featureData[this.FEATURE_OPTIONS_BONUS_CLAIMED_KEY] = 1;
         setFeatureData(featureData);
         this.openFeatureExpiredWindow();
         FarmStatsManager.count(m_featureName,"Final reward",FINAL_BUILDING_NAME[this.overAllProgressLevel()],FINAL_LEVEL_NAME[this.overAllProgressLevel()],this.getCurrentAverage().toString(),this.overAllProgressLevel().toString());
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
         return ["ydfr","faqx","hjix"];
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
      
      public function getAverageForTheWeek(index:int) : int
      {
         var points:int = 0;
         var featureData:Object = this.getFeatureData();
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
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("dec19_innovation_bonus_enabled");
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
         var bonusItem:FarmItem = null;
         var count:int = 0;
         if(!m_initialized)
         {
            this.initialize();
         }
         var key:String = LAST_BONUS_HARVEST_TIME_KEY;
         Global.player.setFeatureLastShown(key,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         var featureData:Object = this.getFeatureData();
         var bonusCode:String = "";
         if(featureData.hasOwnProperty(this.FEATURE_OPTIONS_BONUS_CODE_KEY))
         {
            bonusCode = featureData[this.FEATURE_OPTIONS_BONUS_CODE_KEY];
            bonusItem = Global.farmGameSettingsManager.getFarmItemByCode(bonusCode);
         }
         var harvestRewardName:String = this.getNextHarvestItemName();
         var harvestFarmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(harvestRewardName);
         if(harvestFarmItem)
         {
            count = 1;
            Global.player.addGift(harvestRewardName,"",count);
            FarmStatsManager.count(m_featureName,"Harvest",bonusCode,harvestRewardName);
            UI.displayPopup(new Dec19InnovationPostBonusHarvestWindow(FV_REWARD_DIALOG_ASSET,featureName,bonusItem,harvestFarmItem,null,SANTA_VILLAGE_REWARD_DIALOG_BG_ASSET,count));
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
      
      public function get redeemMessageShown() : Boolean
      {
         return this._redeemMessageShown;
      }
      
      public function set redeemMessageShown(value:Boolean) : void
      {
         this._redeemMessageShown = value;
      }
      
      public function set mainWindow(mainWindowInstance:Dec19InnovationMainWindow) : void
      {
         this.m_mainWindow = mainWindowInstance;
      }
      
      public function openFeatureExpiredWindow() : void
      {
         this.m_finalRewardWindow = new Dec19InnovationFinalRewardWindow(m_featureName,this.featureEndWindowURL);
         UI.displayPopup(this.m_finalRewardWindow,false);
         if(this.m_leaderboardWindow)
         {
            this.m_leaderboardWindow.tintWindow();
            this.m_leaderboardWindow.enableInput = false;
         }
         FarmStatsManager.count(m_featureName,"feature_ui","reward_ui","impression");
      }
      
      public function playForLeaderboard() : void
      {
         var i:int = 0;
         var featureData:Object = this.getFeatureData();
         if(featureData[KEY_SHOW_LEADERBOARD_FIRST_TIME_IN_WEEK] == 1)
         {
            this.showLeaderboardUI();
            featureData[KEY_SHOW_LEADERBOARD_FIRST_TIME_IN_WEEK] = 0;
            setFeatureData(featureData);
         }
         if(featureData[KEY_FLUSH_DAILY_REWARD_TASK] == false)
         {
            featureData[KEY_FLUSH_DAILY_REWARD_TASK] = true;
            for(i = 0; i < 4; i++)
            {
               this.generateAndSaveNewTask(i);
               featureData = this.getFeatureData();
               featureData[KEY_SAVED_ACTIVE_TASKS][i][this.KEY_DUMPED_STATUS] = 0;
               setFeatureData(featureData);
            }
            this.m_mainWindow.refreshWindow();
            FarmStatsManager.count(m_featureName,"Leaderboard","start");
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"playForLeaderboard",null,[m_featureName]),true);
         }
      }
      
      public function getDayEndMessageShown() : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(featureData[KEY_FLUSH_DAILY_REWARD_TASK] == true)
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
         endTime = FarmGameUtil.synchronizedDateTimeToNumber(this.DEC19_BONUS_END_DATE) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         timeLeft = endTime - now;
         if(timeLeft <= 0)
         {
            result = true;
         }
         return result;
      }
      
      public function getActiveWeek() : String
      {
         var result:String = null;
         var featureData:Object = this.getFeatureData();
         if(featureData)
         {
            result = featureData[KEY_CURRENT_WEEK];
         }
         if(result == "0")
         {
            result = "1";
         }
         return result;
      }
      
      public function getCurrentLeague() : int
      {
         var result:String = null;
         var featureData:Object = this.getFeatureData();
         if(featureData)
         {
            result = featureData[this.KEY_CURRENT_LEAGUE];
         }
         return int(result);
      }
      
      public function getNextLeague() : int
      {
         var currentLeague:int = int(this.getCurrentLeague());
         return currentLeague >= 0 && currentLeague < 3 ? int(currentLeague + 1) : currentLeague;
      }
      
      public function getPreviousLeague() : int
      {
         var currentLeague:int = int(this.getCurrentLeague());
         return currentLeague > 0 && currentLeague <= 3 ? int(currentLeague - 1) : currentLeague;
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
      
      public function panToMapTrigger() : void
      {
         var name:String = "Dec19InnovationMapTrigger";
         var map:MapTrigger = MapTriggerManager.getInstance().getMapTriggerByName(name);
         if(map)
         {
            if(this.mainWindow)
            {
               this.mainWindow.close();
            }
            ItemFinderManager.getInstance().highlightWorldItems(map.getItemName());
         }
      }
      
      public function getWeeksArray() : Array
      {
         return this.m_staticData.weeks;
      }
      
      public function getWeeklyLeaderboardPoints() : int
      {
         var leaderboardPoints:int = 0;
         var featureData:Object = this.getFeatureData();
         if(featureData.hasOwnProperty(this.WEEKLY_SCORE))
         {
            leaderboardPoints = int(featureData[this.WEEKLY_SCORE]);
         }
         return leaderboardPoints;
      }
      
      public function getWeeklyLeaderboardRank() : int
      {
         var leaderboardRank:int = 0;
         var featureData:Object = this.getFeatureData();
         var leaderboardData:Object = featureData[KEY_SAVED_LEADERBOARD_RESULT];
         if(leaderboardData)
         {
            leaderboardRank = int(featureData[KEY_SAVED_LEADERBOARD_RESULT]["rank"]);
            return leaderboardRank ? leaderboardRank : -1;
         }
         return -1;
      }
      
      public function isGAPlayer() : Boolean
      {
         return !WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_SANTAVILLAGE);
      }
      
      public function hasGAstarted() : Boolean
      {
         var featureData:Object = this.getFeatureData();
         var result:Boolean = false;
         if(Boolean(featureData) && Boolean(featureData.hasOwnProperty(KEY_GA_FEATURE_START)) && featureData[KEY_GA_FEATURE_START] == true)
         {
            result = true;
         }
         return result;
      }
      
      public function closeMainWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
      }
      
      public function isFeatureInActivePeriod() : Boolean
      {
         return FarmGameUtil.isFeatureInActivePeriod(this.bonusGrantDate,this.REDEEM_ADDITIONAL_DAYS);
      }
      
      public function isFeatureInRedeemPeriod() : Boolean
      {
         return !this.isFeatureInActivePeriod() && FarmGameUtil.isFeatureInActivePeriod(this.bonusGrantDate);
      }
      
      public function getLeaderboardData() : Array
      {
         return this.m_staticData.leaderboardConfigData;
      }
      
      public function getCurrentLeaderboard() : Object
      {
         var leaderboardXML:XML = null;
         var leaderboardData:Object = this.getLeaderboardData();
         var result:Object = null;
         var weekCount:int = 0;
         for each(leaderboardXML in leaderboardData)
         {
            weekCount++;
            if(FarmGameUtil.checkDateGate(leaderboardXML.@start.toString(),leaderboardXML.@end.toString()))
            {
               result = {};
               result.name = leaderboardXML.@name.toString() + this.DEC19_LEAGUE_MAP[this.getCurrentLeague()];
               result.start = leaderboardXML.@start.toString();
               result.end = leaderboardXML.@end.toString();
               result.count = weekCount;
               break;
            }
         }
         return result;
      }
      
      public function leaderboardCallback() : void
      {
         this.m_leaderboardWindow = null;
      }
      
      public function getLeaderboardEntries(result:Object = null) : void
      {
         var collectionData:Object = null;
         var giftLeaderboardRank:Number = NaN;
         var giftLeaderboardName:String = null;
         var giftKey:String = null;
         var gifts:Array = null;
         var giftName:String = null;
         if(result != null)
         {
            collectionData = this.getFeatureData();
            giftLeaderboardRank = 0;
            giftLeaderboardName = "";
            if(Boolean(result["gift"]) && Boolean(result["giftLeaderboardName"]))
            {
               giftKey = m_featureName + "_" + result["giftLeaderboardName"] + "_awarded";
               gifts = new Array();
               giftLeaderboardRank = Number(result["giftLeaderboardRank"]);
               giftLeaderboardName = result["giftLeaderboardName"];
               for each(giftName in result["gift"])
               {
                  Global.player.addGift(giftName);
                  gifts.push(giftName);
               }
               this.updateCurrentLeague();
               collectionData[this.KEY_SHOULD_GRANT_LEAGUE_REWARD] = true;
               collectionData[KEY_SAVED_LEADERBOARD_RESULT] = result["userData"];
               collectionData[giftKey] = true;
            }
            if(Boolean(this.m_leaderboardWindow) && result["syncMainUI"] == false)
            {
               this.m_leaderboardWindow.populateLeaderboard(result,giftLeaderboardRank,giftLeaderboardName);
            }
            if(result["userData"])
            {
               collectionData[KEY_SAVED_LEADERBOARD_RESULT] = result["userData"];
               collectionData[this.WEEKLY_SCORE] = result["userData"]["value"];
               if(Boolean(this.mainWindow) && Boolean(result["userData"]["value"] >= 0) && Boolean(result["userData"]["rank"]))
               {
                  this.mainWindow.updateLeaderBoardFrame(result["userData"]["value"],result["userData"]["rank"]);
               }
            }
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,FEATURE_OPTIONS_KEY,collectionData);
         }
      }
      
      public function isShowLeaderBoardPopup() : Boolean
      {
         var leaderBoardData:Object = null;
         var currentLeaderboard:String = null;
         var featureData:Object = null;
         var isShow:Boolean = false;
         if(this.isFeatureInActivePeriod())
         {
            leaderBoardData = this.getCurrentLeaderboard();
            currentLeaderboard = leaderBoardData.name;
            featureData = this.getFeatureData();
            if(featureData.hasOwnProperty(KEY_CURRENT_LEADERBOARD) && featureData[KEY_CURRENT_LEADERBOARD] != currentLeaderboard && featureData[this.WEEKLY_SCORE] > 0)
            {
               isShow = true;
            }
         }
         return isShow;
      }
      
      public function initializeLeaderBoardProgress(isSync:Boolean = false) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getLeaderboardEntries",this.getLeaderboardEntries,[m_featureName,isSync]));
      }
      
      public function getCurrentLeaderboardName() : String
      {
         var featureData:* = this.getFeatureData();
         return featureData[KEY_CURRENT_LEADERBOARD];
      }
      
      public function harvestChristmasReward() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"harvestDailyChristmasReward",this.harvestDailyChristmasReward,[m_featureName]),true);
      }
      
      public function harvestDailyChristmasReward(result:Object) : void
      {
         var dayIndex:int = 0;
         var rewardName:String = null;
         var rewardItem:FarmItem = null;
         var featureData:Object = null;
         var keyDailyChristmasBonusHarvested:String = null;
         if(result.success)
         {
            if(this.isChristmasWeek() && !this.isDailyChristmasRewardHarvested())
            {
               dayIndex = this.christmasDayIndex + 1;
               rewardName = this.CHRISTMAS_REWARD_PACKAGE_PREFIX + dayIndex.toString();
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
               if(!rewardItem)
               {
                  rewardItem = Global.farmGameSettingsManager.getFarmItemByName("consume_unwither");
               }
               if(rewardItem)
               {
                  Global.player.addGift(rewardName,"",1);
                  featureData = this.getFeatureData();
                  keyDailyChristmasBonusHarvested = this.KEY_DAILY_CHRISTMAS_REWARD_HARVESTED + dayIndex.toString();
                  featureData[keyDailyChristmasBonusHarvested] = 1;
                  setFeatureData(featureData);
                  UI.displayPopup(new Dec19InnovationDailyBonusGrantWindow(FV_REWARD_DIALOG_ASSET,featureName,rewardItem,null,SANTA_VILLAGE_REWARD_DIALOG_BG_ASSET,true),false);
               }
            }
         }
      }
      
      public function isChristmasWeek() : Boolean
      {
         var dayIndex:int = this.christmasDayIndex;
         return dayIndex >= 0 && dayIndex < 7;
      }
      
      public function get christmasDayIndex() : int
      {
         var featureData:Object = this.getFeatureData();
         var activeDayTimeStamp:Number = FarmGameUtil.getMidnightTimestamp() / 1000;
         var christmasWeekStartDayTimeStamp:Number = FarmGameUtil.synchronizedDateTimeToNumber(this.CHRISTMAS_WEEK_START_DATE) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return int((activeDayTimeStamp - christmasWeekStartDayTimeStamp) / FarmGameUtil.NUM_SECS_IN_DAY);
      }
      
      public function isDailyChristmasRewardHarvested() : Boolean
      {
         var featureData:Object = this.getFeatureData();
         var dayIndex:int = this.christmasDayIndex + 1;
         var keyDailyChristmasBonusHarvested:String = this.KEY_DAILY_CHRISTMAS_REWARD_HARVESTED + dayIndex.toString();
         return featureData.hasOwnProperty(keyDailyChristmasBonusHarvested);
      }
      
      public function getDaysLeftInChristmasWeek() : int
      {
         return 7 - this.christmasDayIndex;
      }
   }
}

