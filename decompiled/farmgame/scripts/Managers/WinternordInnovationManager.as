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
   import Classes.WinternordInnovationCommunityGoalTask;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import Display.HUD.HUD;
   import Display.HUD.HUDWidgets.HudBottomWinternordInnovationButton;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import Events.TileUnlockEvent;
   import Managers.Crafting.CraftingManager;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Transactions.TWinternordCommunityGoalsGetProgress;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FeaturePackagesBuyWindow;
   import Widgets.Windows.GenericSingleRewardPopup;
   import Widgets.Windows.WinternordCommunityGoalsRewardWindow;
   import Widgets.Windows.WinternordInnovationBadgeGrantWindow;
   import Widgets.Windows.WinternordInnovationCommunityGoalWindow;
   import Widgets.Windows.WinternordInnovationDailyBonusGrantWindow;
   import Widgets.Windows.WinternordInnovationMainWindow;
   import Widgets.Windows.WinternordInnovationPostBonusHarvestWindow;
   import Widgets.Windows.WinternordInnovationRewardUpgradeWindow;
   import Widgets.Windows.WinternordInnovationRewardWindow;
   import Widgets.Windows.WinternordInnovationTileUnlockwindow;
   import flash.events.Event;
   import mx.utils.StringUtil;
   
   public class WinternordInnovationManager extends BaseFeatureManager
   {
      
      public static const HUD_INITIALISATION_FLAG:String = "winternord_innovation_hud_initialise_flag";
      
      private static const HUD_WINTERNORD_ASSET:String = "assets/dialogs/winternord/innovation/FV_xwx_hud_Innovation.swf";
      
      private static const COMMUNITY_GOAL_WINDOW:String = "assets/dialogs/winternord/innovation/FV_xwx_community.swf";
      
      public static const FEATURE_NAME:String = "WinternordInnovation";
      
      private static const WINDOW_MAIN:String = "main";
      
      private static const WINDOW_REWARD:String = "reward";
      
      private static const WINDOW_CONGRATS:String = "congrats";
      
      private static const WINDOW_BUY:String = "buyDialog";
      
      private static const WINTERNORD_COMMUNITY_GOALS_TASK_DATA:String = "WINTERNORD_COMMUNITY_GOALS_TASK_DATA";
      
      private static const WINTERNORD_COMMUNITY_GOALS_TESTING_FLAG:String = "WINTERNORD_COMMUNITY_GOALS_TESTING";
      
      public static const COLLECT_TIME_KEY:String = "ctk";
      
      public static const FEED_NAME:String = "WinternordInnovationUI";
      
      public static const FEATURE_OPTIONS_KEY:String = "WinternordInnovation";
      
      public static const KEY_WEEKLY_REWARD_EASY_GRANTED:String = "weekly_easy_reward_granted";
      
      public static const KEY_WEEKLY_REWARD_MEDIUM_GRANTED:String = "weekly_medium_reward_granted";
      
      public static const KEY_WEEKLY_REWARD_HARD_GRANTED:String = "weekly_hard_reward_granted";
      
      public static const KEY_WEEKLY_REWARD_EASY_POPUP:String = "weekly_easy_popup_shown";
      
      public static const KEY_WEEKLY_REWARD_MEDIUM_POPUP:String = "weekly_medium_popup_shown";
      
      public static const KEY_WEEKLY_REWARD_HARD_POPUP:String = "weekly_hard_popup_shown";
      
      public static const KEY_FIRST_BADGE_GRANTED:String = "first_badge_granted";
      
      public static const KEY_SECOND_BADGE_GRANTED:String = "second_badge_granted";
      
      public static const KEY_THIRD_BADGE_GRANTED:String = "third_badge_granted";
      
      public static const KEY_GA_FEATURE_START:String = "ga_winternord_innovation_start";
      
      public static const KEY_CHRISTMAS_ENTER:String = "christmas_entered";
      
      private static var m_initialized:Boolean = false;
      
      private static const SKIP_COST:int = 1;
      
      private static const KEY_SAVED_ACTIVE_TASKS:String = "1";
      
      private static const KEY_SAVED_DUMPED_TIMESTAMP:String = "3";
      
      private static const KEY_FLUSH_DAILY_REWARD_TASK:String = "flush_daily_reward_tasks";
      
      private static const KEY_CURRENT_WEEK:String = "currentweek";
      
      private static const KEY_CURRENT_LEVEL:String = "currentlevel";
      
      private static const KEY_SHOW_COMMUNITY_FIRST_TIME_IN_WEEK:String = "weekly_show_community_first_time";
      
      private static const KEY_CURRENT_ORDERBOARD_LEADERBOARD:String = "currentOrderboardLeaderboard";
      
      private static const KEY_CURRENT_VIRAL_LEADERBOARD:String = "currentViralLeaderboard";
      
      private static const SERVICE_NAME:String = "WinternordInnovationService";
      
      public static const KEY_PLAYER_COUNT:String = "community_player_count";
      
      public static const KEY_UPDATE_COUNT:String = "community_task_update_count";
      
      public static const KEY_COMMUNITY_REWARDS:String = "community_rewards";
      
      public static const WINTERNORD_TILE_UNLOCK_COUNT:String = "vuq0";
      
      private static const KEY_TILE_UNLOCK_COUNT:String = "winternord_tile_unlock_count";
      
      private static const LAST_BONUS_HARVEST_TIME_KEY:String = "xty_bht";
      
      public static const DEFAULT_HARVEST_THROTTLE_TIME:Number = 86400;
      
      private static const CRAFTSHOP_CONSUMABLE_TAB:String = "consumable";
      
      private static const BONUS_HARVEST_COUNT:String = "hc";
      
      private static const BONUS_COUNT_MAP:Array = [0,0,7,10,14];
      
      private static const BONUS_NAME_ARRAY:Array = ["Nisse Giftbox","Nisse Workshop","Nisse Gift House","Nisse Gift Workshop","Nisse Gift Factory"];
      
      public const TILE_UNLOCK:String = "Winternord_Tile_Unlock";
      
      public const FIRST_TIME_UNLOCK:String = "Winternord_First_tile_Unlock";
      
      private var m_cachedTaskData:Object;
      
      private var m_communityRewardsEarned:Object;
      
      private var m_commRewardWindow:WinternordCommunityGoalsRewardWindow;
      
      public const DEFAULT_THROTTLE_TIME:Number = 86400;
      
      private var m_assetPaths:Object = null;
      
      protected var m_staticData:Object;
      
      private var m_mainWindow:WinternordInnovationMainWindow;
      
      private var m_rewardPopup:GenericSingleRewardPopup;
      
      public const VAL_FIRST_MILESTONE:int = 10;
      
      public const VAL_SECOND_MILESTONE:int = 20;
      
      public const VAL_THIRD_MILESTONE:int = 35;
      
      public const VAL_WEEK_FIRST_MILESTONE:int = 5;
      
      public const VAL_WEEK_SECOND_MILESTONE:int = 15;
      
      public const VAL_WEEK_THIRD_MILESTONE:int = 30;
      
      public const VAL_FIRST_ORDER_MILESTONE:int = 50;
      
      public const VAL_SECOND_ORDER_MILESTONE:int = 100;
      
      public const VAL_THIRD_ORDER_MILESTONE:int = 250;
      
      protected const KEY_PROGRESS:String = "progress";
      
      protected const KEY_TOTAL:String = "total";
      
      private var m_resultObject:Object;
      
      private var m_CgTaskList:Array;
      
      private const QUEST_NAME:String = "WinternordInnovation";
      
      private var m_winternordInnovationHud:HudBottomWinternordInnovationButton;
      
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
      
      private const KEY_ORDERBOARD_COUNT:String = "orderboard_task_count";
      
      private const KEY_ORDER_NO:String = "no_of_orders";
      
      private const KEY_BADGE_NO:String = "no_of_badges";
      
      private const KEY_ORDERBOARD_COUNT_TASK:String = "winternordInnovationOrderboardTask";
      
      private const KEY_CURRENT_AVERAGE:String = "current_average";
      
      public const badgeFeedIcons:Array = ["assets/newsfeed/specialsnowflakebadge_icon.png","assets/newsfeed/outstandingornamentbadge_icon.png","assets/newsfeed/wreathofwonderbadge_icon.png"];
      
      private const KEY_LAST_USED_TYPE:String = "lt";
      
      private var m_tasksByTypes:Object = null;
      
      private const KEY_USER_STATE:String = "state";
      
      private var taskTypesArray:Array = [["M1","M1","M1","M1","HB","M1","M1","M1","BB","M1","M1","M1","M1","EH"],["M2","M2","M2","M2","HB","M2","M2","M2","BB","M2","M2","M2","M2","EH"],["M3","M3","M3","M3","HB","M3","M3","M3","BB","M3","M3","M3","M3","EH"],["M4","M4","M4","M4","M4","M4","M4","M4","M4","M4","M4","M4","M4","M4"]];
      
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
      
      private const KEY_WEEKLY_AVERAGE_POINTS:String = "wavgpts";
      
      private const FEATURE_OPTIONS_BONUS_CLAIMED_KEY:String = "bonus";
      
      private const KEY_FEATURE_ENDED:String = "finished";
      
      private const KEY_ACTIVE_DAY_TIMESTAMP:String = "ts";
      
      private var m_rewardWindow:WinternordInnovationRewardWindow;
      
      public var m_communityGoalWindow:WinternordInnovationCommunityGoalWindow;
      
      private const KEY_TASK_LEVEL:String = "taskLevel";
      
      private const FEATURE_OPTIONS_BONUS_CODE_KEY:String = "bonusCode";
      
      private var m_rewardsBySlotName:Object = null;
      
      private var m_weeklyRewardsBySlotName:Object = null;
      
      public const VAL_MILESTONE_POINTS_ARRAY:Array = [10,20,35];
      
      public const VAL_CLASSIC:int = 30;
      
      public const VAL_SUPERB:int = 15;
      
      public const VAL_GOOD:int = 5;
      
      public const NO_OF_WEEKS:int = 5;
      
      public const COMMUNITY_TASK_PREFIX:String = "winternordInnovationOrderboardTaskWeek";
      
      private const SERVICE_FUNC_HARVEST_BONUS:String = "harvestBonusBuilding";
      
      private const SERVICE_FUNC_GRANT_BONUS:String = "grantBonus";
      
      private const EVENT_WW_INNOVATION_TILE_UNLOCK:String = "WinternordInnovationTileUnlock";
      
      public const CRUSH_BARREL_TUTORIAL:String = "WinternordInnovationSinkTutorial";
      
      public const FIRST_SESSION_TUTORIAL:String = "WIFirstSessioTutorial";
      
      private var BONUS_HARVEST_ARRAY:Object = {
         "2":["fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard"],
         "3":["fuel1","vehiclepart","pkg_xwx_treasureparts","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard"],
         "4":["consume_instagrow","consume_turbo_charger","consume_unwither","consume_organic_fertilizer","fuel1","vehiclepart","pkg_xwx_treasureparts","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard"]
      };
      
      private var _redeemHasStarted:Boolean = false;
      
      private var _redeemMessageShown:Boolean = false;
      
      private const REDEEM_ADDITIONAL_DAYS:int = 0;
      
      public const REWARD_ITEM:Array = ["assets/buildings/xwx_christmasbuilding_built_0_icon.png","assets/buildings/xwx_christmasbuilding_built_1_icon.png","assets/buildings/xwx_christmasbuilding_built_2_icon.png","assets/buildings/xwx_christmasbuilding_built_3_icon.png","assets/buildings/xwx_christmasbuilding_built_4_icon.png"];
      
      public const REWARD_ITEM_200:Array = ["assets/buildings/xwx_christmasbuilding_built_0_icon_200.png","assets/buildings/xwx_christmasbuilding_built_1_icon_200.png","assets/buildings/xwx_christmasbuilding_built_2_icon_200.png","assets/buildings/xwx_christmasbuilding_built_3_icon_200.png","assets/buildings/xwx_christmasbuilding_built_4_icon_200.png"];
      
      public function WinternordInnovationManager(featureName:String, featureConfig:XML = null)
      {
         super(featureName,featureConfig);
         this.parseTaskObjectsFromConfig(this.QUEST_NAME);
         this.parseRewardsDataFromConfig(this.QUEST_NAME);
         this.parseWeeklyRewardsDataFromConfig(this.QUEST_NAME);
         this.m_resultObject = new Object();
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
      }
      
      public static function getInstance(featureName:String = "WinternordInnovation") : WinternordInnovationManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,WinternordInnovationManager) as WinternordInnovationManager;
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
      
      public function setupWinternordHud() : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         this.m_winternordInnovationHud = new HudBottomWinternordInnovationButton(HUD_WINTERNORD_ASSET,m_featureName);
         Global.hud.setBottomHudWinternordInnovationButton(this.m_winternordInnovationHud as HudBottomWinternordInnovationButton);
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
               nextUsedtaskTypeIndexInUserState = (lastUsedtaskTypeIndexInUserState + 1) % 14;
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
                  if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_WINTERNORD_INNOVATION_TASK_V2) == 2)
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
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_WINTERNORD_INNOVATION_TASK_V2) == 2)
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
         var inventoryTileCount:int = FeatureOptionsInventoryManager.getInstance().getCount(WINTERNORD_TILE_UNLOCK_COUNT) as int;
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
            inventoryTileCount = FeatureOptionsInventoryManager.getInstance().getCount(WINTERNORD_TILE_UNLOCK_COUNT);
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
         var weekCount:int = 0;
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
               weekCount = int(featureData[KEY_CURRENT_WEEK]);
               weekCount = weekCount == 0 ? 1 : weekCount;
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
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("winternord_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq) && this.isFeatureInActivePeriod())
         {
            ConsumableItem = Global.farmGameSettingsManager.getFarmItemByCode(this.ConsumableCode);
            UI.displayPopup(new WinternordInnovationTileUnlockwindow("assets/dialogs/expansion/FV_RewardDialog.swf",featureName,ConsumableItem,null,"assets/dialogs/winternord/RewardDialog.png"));
         }
         if(!Global.player.getSeenFlag(this.TILE_UNLOCK))
         {
            Global.player.setSeenFlag(this.TILE_UNLOCK);
         }
         FarmStatsManager.count(m_featureName,"UnlockTile","30",this.consumableCount.toString());
      }
      
      public function showDailyBonusGrantPopup(rewardItem:FarmItem, isWeekly:Boolean = false, isChristmas:Boolean = false) : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         var weeklyRewardData:Object = {};
         if(isWeekly)
         {
            weeklyRewardData.rating = this.getWeeklyRating();
            weeklyRewardData.week = this.getActiveWeek();
         }
         if(isChristmas)
         {
            weeklyRewardData.rating = "CONTENT";
            weeklyRewardData.week = "4";
         }
         FarmStatsManager.count(m_featureName,"feature_ui","dailyBonusPopup");
         UI.displayPopup(new WinternordInnovationDailyBonusGrantWindow("assets/dialogs/expansion/FV_RewardDialog.swf",featureName,rewardItem,isWeekly,weeklyRewardData,null,"assets/dialogs/winternord/RewardDialog.png"),false);
      }
      
      public function showBadgeEarnedPopup(index:int = 0, qty:int = 0) : void
      {
         var badgeIcons:Array = ["assets/newsfeed/specialsnowflakebadge_icon_200.png","assets/newsfeed/outstandingornamentbadge_icon_200.png","assets/newsfeed/wreathofwonderbadge_icon_200.png"];
         UI.displayPopup(new WinternordInnovationBadgeGrantWindow("assets/dialogs/expansion/FV_RewardDialog_Share.swf",featureName,Global.getAssetURL(badgeIcons[index]),null,"assets/dialogs/winternord/RewardDialog.png",qty,Global.getAssetURL(this.badgeFeedIcons[index])),false);
      }
      
      public function showMainUI(showTutorialWithEAPage:Boolean = false) : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         if(this.isFeatureInActivePeriod())
         {
            this.resetActivePopupCount();
            this.m_mainWindow = new WinternordInnovationMainWindow(m_featureName,this.mainWindowURL,showTutorialWithEAPage);
            UI.displayPopup(this.m_mainWindow);
            this.initializeCommunityProgress();
         }
         FarmStatsManager.count("WinternordInnovation","feature_ui","main_ui","impression");
      }
      
      public function openBuyWindow(owner:FarmWindow) : void
      {
         UI.displayPopup(new FeaturePackagesBuyWindow(this.buyDialogURL,m_featureName,this.getBucketPackages(),owner),false);
         FarmStatsManager.count("WinternordInnovation","Buy","Wrapping papers","Click");
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
      
      public function craftConsumableFromMainWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
         FarmStatsManager.count("WinternordInnovation","Craft","Wrapping papers",this.consumableCount.toString());
         var consumableSearchStr:String = "Wrapping Paper";
         CraftingManager.getInstance().openCraftshopWindow(CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType),consumableSearchStr,this.m_mainWindow,CRAFTSHOP_CONSUMABLE_TAB);
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
         var communityGoalXml:XML = null;
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
         this.m_staticData.communityGoalConfigData = new Array();
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
            if(featureXML.communityGoalConfig)
            {
               for each(communityGoalXml in featureXML.communityGoalConfig.innovationCgTask)
               {
                  this.m_staticData.communityGoalConfigData.push(communityGoalXml);
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
            FarmStatsManager.count("Ask","Wrapping papers");
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
            questTasks1 = WinternordInnovationManager.getInstance(m_featureName).getActiveTasks();
            taskPt = questTasks1[slotIndex].questPoints;
            taskLBPt = questTasks1[slotIndex].questPoints;
            if(featureObject[this.KEY_DAY_POINTS] + questTasks1[slotIndex].questPoints > this.VAL_THIRD_MILESTONE)
            {
               taskPt = this.VAL_THIRD_MILESTONE - featureObject[this.KEY_DAY_POINTS];
            }
            featureObject[this.KEY_DAY_POINTS] += questTasks1[slotIndex].questPoints;
            featureObject[this.KEY_ORDERBOARD_COUNT] += 1;
            featureObject[this.KEY_ORDER_NO] += 1;
            setFeatureData(featureObject);
            this.mainWindow.untintWindow();
            this.mainWindow.enableInput = true;
            if(this.hasActiveDayExpired() == false && this.getUserState() != this.DONE_FOR_THE_DAY)
            {
               this.m_mainWindow.updateTaskDoober(taskPt);
            }
            if(this.getDayEndMessageShown() == true)
            {
               this.m_mainWindow.updateCommunityDoober();
            }
            this.checkAndUpdateUserState();
            this.checkAndUpdateBadgeState();
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipTask",null,[m_featureName,slotIndex]),true);
            this.resetActionCountsForTasks(tasks[slotIndex]);
            this.updateOrderboardCount();
            this.generateAndSaveNewTask(slotIndex);
            fItemName = null;
            if(tasks[slotIndex].action == "completeFeatureCraftingNPC")
            {
               fItemName = "Yuletide Stable";
            }
            else
            {
               code = tasks[slotIndex].type;
               fItemName = this.getTaskItemName(code);
            }
            if(fItemName == null)
            {
               fItemName = "Winternord Task";
            }
            FarmStatsManager.count("WinternordInnovation","SkipTask",this.getKingdomText(tasks[slotIndex]),tasks[slotIndex].titleText,featureObject[this.KEY_DAY_POINTS].toString(),questTasks1[slotIndex].questPoints.toString(),tasks[slotIndex].skipCashValue);
            this.m_mainWindow.refreshTaskFrame();
            this.m_mainWindow.updateProgressBar();
            this.m_mainWindow.updateWeeklyOrderCount();
            this.m_mainWindow.updateLifetimeOrderCount();
            this.updateCurrentAverageKey();
            this.m_mainWindow.updateBadgeVisibility();
            this.m_mainWindow.updateWeeklyTable();
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
         questTasks1 = WinternordInnovationManager.getInstance(m_featureName).getActiveTasks();
         var taskPt:int = questTasks1[slotIndex].questPoints;
         var taskLBPt:int = questTasks1[slotIndex].questPoints;
         if(featureObject[this.KEY_DAY_POINTS] + questTasks1[slotIndex].questPoints > this.VAL_THIRD_MILESTONE)
         {
            taskPt -= this.VAL_THIRD_MILESTONE - featureObject[this.KEY_DAY_POINTS];
         }
         featureObject[this.KEY_DAY_POINTS] += questTasks1[slotIndex].questPoints;
         featureObject[this.KEY_ORDERBOARD_COUNT] += 1;
         featureObject[this.KEY_ORDER_NO] += 1;
         setFeatureData(featureObject);
         this.resetActionCountsForTasks(tasks[slotIndex]);
         this.updateOrderboardCount();
         this.checkAndUpdateBadgeState();
         if(this.hasActiveDayExpired() == false && this.getUserState() != this.DONE_FOR_THE_DAY)
         {
            this.m_mainWindow.updateTaskDoober(taskPt);
         }
         if(this.getDayEndMessageShown() == true)
         {
            this.m_mainWindow.updateCommunityDoober();
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
            fItemName = "Yuletide Stable";
         }
         else
         {
            code = tasks[slotIndex].type;
            fItemName = this.getTaskItemName(code);
         }
         if(fItemName == null)
         {
            fItemName = "Winternord Task";
         }
         FarmStatsManager.count("WinternordInnovation","RedeemTask",this.getKingdomText(tasks[slotIndex]),tasks[slotIndex].titleText,featureObject[this.KEY_DAY_POINTS].toString(),questTasks1[slotIndex].questPoints.toString(),tasks[slotIndex].skipCashValue);
         this.generateAndSaveNewTask(slotIndex);
         this.m_mainWindow.refreshTaskFrame();
         this.m_mainWindow.updateProgressBar();
         this.m_mainWindow.updateWeeklyOrderCount();
         this.m_mainWindow.updateLifetimeOrderCount();
         this.updateCurrentAverageKey();
         this.m_mainWindow.updateBadgeVisibility();
         this.m_mainWindow.updateWeeklyTable();
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
               FarmStatsManager.count("WinternordInnovation","userstate","Able",(this.activeDayIndex + 1).toString(),dayPoints.toString(),this.getActiveWeek(),this.getCurrentAverage());
               FarmStatsManager.count("WinternordInnovation","Reward","userstate","Able",this.getActiveDayReward(this.EASY).friendlyTitle,this.getActiveWeek(),this.activeDayIndex + 1);
            }
            else if(dayPoints >= this.VAL_SECOND_MILESTONE && userState == this.MEDIUM)
            {
               featureObj[this.KEY_USER_STATE] = this.LOCK2;
               this.grantUserRewardforLevel(this.MEDIUM);
               FarmStatsManager.count("WinternordInnovation","userstate","Proficient",(this.activeDayIndex + 1).toString(),dayPoints.toString(),this.getActiveWeek(),this.getCurrentAverage());
               FarmStatsManager.count("WinternordInnovation","Reward","userstate","Proficient",this.getActiveDayReward(this.MEDIUM).friendlyTitle,this.getActiveWeek(),this.activeDayIndex + 1);
            }
            else if(dayPoints >= this.VAL_THIRD_MILESTONE && userState == this.HARD)
            {
               if(this.activeDayIndex % 7 == 6)
               {
                  this.checkAndUpdateWeeklyStatus();
               }
               featureObj[this.KEY_USER_STATE] = this.DONE_FOR_THE_DAY;
               this.grantUserRewardforLevel(this.HARD);
               this.showDailyBonusGrantPopup(this.getActiveDayReward(this.HARD));
               FarmStatsManager.count("WinternordInnovation","userstate","Masterful",(this.activeDayIndex + 1).toString(),dayPoints.toString(),this.getActiveWeek(),this.getCurrentAverage());
               FarmStatsManager.count("WinternordInnovation","Reward","userstate","Masterful",this.getActiveDayReward(this.HARD).friendlyTitle,this.getActiveWeek(),this.activeDayIndex + 1);
            }
            setFeatureData(featureObj);
         }
      }
      
      public function hasReceivedRewardForWeek(level:int) : Boolean
      {
         var rewardGrantKeys:Array = [KEY_WEEKLY_REWARD_EASY_GRANTED,KEY_WEEKLY_REWARD_MEDIUM_GRANTED,KEY_WEEKLY_REWARD_HARD_GRANTED];
         var featureObj:Object = this.getFeatureData();
         return featureObj[rewardGrantKeys[level]];
      }
      
      public function hasShownPopupForTheWeek(level:int) : Boolean
      {
         var popupShownKeys:Array = [KEY_WEEKLY_REWARD_EASY_POPUP,KEY_WEEKLY_REWARD_MEDIUM_POPUP,KEY_WEEKLY_REWARD_HARD_POPUP];
         var featureObj:Object = this.getFeatureData();
         return featureObj[popupShownKeys[level]];
      }
      
      public function getBadgeTooltipText(hasReceivedBadge:Boolean, badgeNumber:int = 0) : String
      {
         var badgePointsRemainingText:String = "Complete {0} orders to get the {1}";
         var badgeName:String = ["Special Snowflake Badge","Outstanding Ornament Badge","Wreath Of Wonder Badge"][badgeNumber];
         if(hasReceivedBadge)
         {
            return badgeName;
         }
         return StringUtil.substitute(badgePointsRemainingText,this.pointsRemainingForBadge(badgeNumber),badgeName);
      }
      
      public function checkAndUpdateWeeklyStatus() : void
      {
         var curAvg:int = this.getCurrentAverage();
         var featureObj:Object = this.getFeatureData();
         if(curAvg >= this.VAL_WEEK_FIRST_MILESTONE && featureObj[KEY_WEEKLY_REWARD_EASY_GRANTED] == false)
         {
            featureObj[KEY_WEEKLY_REWARD_EASY_GRANTED] = true;
            this.grantWeeklyRewardforLevel(this.EASY);
            setFeatureData(featureObj);
            FarmStatsManager.count("WinternordInnovation","Reward","Milestone","Content",this.getActiveWeekReward(this.EASY).friendlyTitle,this.getActiveWeek(),this.activeDayIndex + 1);
         }
         if(curAvg >= this.VAL_WEEK_SECOND_MILESTONE && featureObj[KEY_WEEKLY_REWARD_MEDIUM_GRANTED] == false)
         {
            featureObj[KEY_WEEKLY_REWARD_MEDIUM_GRANTED] = true;
            this.grantWeeklyRewardforLevel(this.MEDIUM);
            setFeatureData(featureObj);
            FarmStatsManager.count("WinternordInnovation","Reward","Milestone","Jolly",this.getActiveWeekReward(this.MEDIUM).friendlyTitle,this.getActiveWeek(),this.activeDayIndex + 1);
         }
         if(curAvg >= this.VAL_WEEK_THIRD_MILESTONE && featureObj[KEY_WEEKLY_REWARD_HARD_GRANTED] == false)
         {
            featureObj[KEY_WEEKLY_REWARD_HARD_GRANTED] = true;
            this.grantWeeklyRewardforLevel(this.HARD);
            setFeatureData(featureObj);
            FarmStatsManager.count("WinternordInnovation","Reward","Milestone","Ectastic",this.getActiveWeekReward(this.HARD).friendlyTitle,this.getActiveWeek(),this.activeDayIndex + 1);
            this.updateRewardLevel();
            if(this.isFeatureInActivePeriod())
            {
               this.mainWindow.updateRewardImage();
            }
         }
         this.showWeeklyRewardPopup();
         FarmStatsManager.count("WinternordInnovation","Milestone",this.getWeeklyRating(),null,null,this.getActiveWeek(),this.getCurrentAverage());
         if(this.isFeatureInActivePeriod())
         {
            this.m_mainWindow.updateWeeklyState();
         }
      }
      
      public function showWeeklyRewardPopup() : void
      {
         var featureObj:Object = this.getFeatureData();
         var popupShownKeys:Array = [KEY_WEEKLY_REWARD_EASY_POPUP,KEY_WEEKLY_REWARD_MEDIUM_POPUP,KEY_WEEKLY_REWARD_HARD_POPUP];
         for(var i:int = 0; i < 3; i++)
         {
            if(this.hasReceivedRewardForWeek(i) == true && this.hasShownPopupForTheWeek(i) == false)
            {
               featureObj[popupShownKeys[i]] = true;
               this.showDailyBonusGrantPopup(this.getActiveWeekReward(i),true);
            }
         }
         setFeatureData(featureObj);
      }
      
      private function showRewardLevelUpgradePopup(upgrdaeLevel:int) : void
      {
         var lastUpgradeLevel:int = 0;
         lastUpgradeLevel = 4;
         var buildingData:Object = {
            "iconUrl":Global.getAssetURL(this.REWARD_ITEM_200[upgrdaeLevel]),
            "isLastUpgrade":upgrdaeLevel == lastUpgradeLevel,
            "name":BONUS_NAME_ARRAY[upgrdaeLevel]
         };
         UI.displayPopup(new WinternordInnovationRewardUpgradeWindow("assets/dialogs/expansion/FV_RewardDialog.swf",featureName,buildingData,null,"assets/dialogs/winternord/RewardDialog.png"),false);
      }
      
      public function updateRewardLevel() : void
      {
         var featureObj:Object = this.getFeatureData();
         var curLevel:int = int(this.getCurrentLevel());
         if(curLevel < 4)
         {
            if(featureObj)
            {
               featureObj[KEY_CURRENT_LEVEL] = (curLevel + 1).toString();
               setFeatureData(featureObj);
            }
         }
         if(curLevel < 4)
         {
            this.showRewardLevelUpgradePopup(curLevel + 1);
         }
         FarmStatsManager.count("WinternordInnovation","grantBonus","Nisse gift house",this.getCurrentLevel(),null,this.getActiveWeek(),this.getCurrentAverage());
      }
      
      public function checkAndUpdateBadgeState() : void
      {
         var curOrder:int = this.getLifetimeOrders();
         var featureObj:Object = this.getFeatureData();
         if(curOrder >= this.VAL_FIRST_ORDER_MILESTONE && featureObj[KEY_FIRST_BADGE_GRANTED] == false)
         {
            featureObj[KEY_FIRST_BADGE_GRANTED] = true;
            featureObj[this.KEY_BADGE_NO] += 1;
            this.showBadgeEarnedPopup(0,this.VAL_FIRST_ORDER_MILESTONE);
            setFeatureData(featureObj);
         }
         if(curOrder >= this.VAL_SECOND_ORDER_MILESTONE && featureObj[KEY_SECOND_BADGE_GRANTED] == false)
         {
            featureObj[KEY_SECOND_BADGE_GRANTED] = true;
            featureObj[this.KEY_BADGE_NO] += 1;
            this.showBadgeEarnedPopup(1,this.VAL_SECOND_ORDER_MILESTONE);
            setFeatureData(featureObj);
         }
         if(curOrder >= this.VAL_THIRD_ORDER_MILESTONE && featureObj[KEY_THIRD_BADGE_GRANTED] == false)
         {
            featureObj[KEY_THIRD_BADGE_GRANTED] = true;
            featureObj[this.KEY_BADGE_NO] += 1;
            this.showBadgeEarnedPopup(2,this.VAL_THIRD_ORDER_MILESTONE);
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
            FarmStatsManager.count("WinternordInnovation","sink","Wrapping papers",this.consumableCount.toString(),consumableNeeded.toString(),this.getActiveWeek());
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
         else if(code == "AllWinternordAnimals")
         {
            result = "Winternord Animals";
         }
         else if(code == "AllWinternordTrees")
         {
            result = "Winternord Trees";
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
               fItemName = "Yuletide Stable";
            }
            else
            {
               code = tasks[slotIndex].type;
               fItemName = this.getTaskItemName(code);
            }
            if(fItemName == null)
            {
               fItemName = "Winternord Task";
            }
            FarmStatsManager.count("WinternordInnovation","Trash",this.getKingdomText(tasks[slotIndex]),tasks[slotIndex].titleText);
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
            FarmStatsManager.count("WinternordInnovation","SkipTrashedTask",(this.activeDayIndex + 1).toString(),null,null,null,1);
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
            FarmStatsManager.count("WinternordInnovation","sinkGold",tasks[slotIndex].type,this.currentDayIndex.toString());
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkGold",null,[m_featureName,slotIndex]),true);
         }
      }
      
      public function sinkBushel(slotIndex:int) : void
      {
         var tasks:Vector.<FarmTask> = this.getActiveTasks();
         CraftingManager.getInstance().deductItemFromCraftingInventory(tasks[slotIndex].type,tasks[slotIndex].total);
         this.postTaskCompletionActions(slotIndex);
         FarmStatsManager.count("WinternordInnovation","sinkBushel",tasks[slotIndex].type,this.currentDayIndex.toString());
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkBushel",null,[m_featureName,slotIndex]),true);
      }
      
      public function postTaskCompletionActions(completedTaskSlotIndex:int) : void
      {
         var questTasks1:Vector.<FarmTask> = null;
         var featureObject:Object = this.getFeatureData();
         questTasks1 = WinternordInnovationManager.getInstance(m_featureName).getActiveTasks();
         var taskPt:int = questTasks1[completedTaskSlotIndex].questPoints;
         var taskLBPt:int = questTasks1[completedTaskSlotIndex].questPoints;
         if(featureObject[this.KEY_DAY_POINTS] + questTasks1[completedTaskSlotIndex].questPoints > this.VAL_THIRD_MILESTONE)
         {
            taskPt -= this.VAL_THIRD_MILESTONE - featureObject[this.KEY_DAY_POINTS];
         }
         featureObject[this.KEY_DAY_POINTS] += questTasks1[completedTaskSlotIndex].questPoints;
         featureObject[this.KEY_ORDERBOARD_COUNT] += 1;
         featureObject[this.KEY_ORDER_NO] += 1;
         setFeatureData(featureObject);
         if(this.hasActiveDayExpired() == false && this.getUserState() != this.DONE_FOR_THE_DAY)
         {
            this.m_mainWindow.updateTaskDoober(taskPt);
         }
         if(this.getDayEndMessageShown() == true)
         {
            this.m_mainWindow.updateCommunityDoober();
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
         this.updateOrderboardCount();
         this.checkAndUpdateBadgeState();
         this.generateAndSaveNewTask(completedTaskSlotIndex);
         this.m_mainWindow.refreshTaskFrame();
         this.m_mainWindow.updateProgressBar();
         this.m_mainWindow.updateWeeklyOrderCount();
         this.m_mainWindow.updateLifetimeOrderCount();
         this.updateCurrentAverageKey();
         this.m_mainWindow.updateBadgeVisibility();
         this.m_mainWindow.updateWeeklyTable();
      }
      
      public function getFeatureData() : Object
      {
         var index:int = 0;
         var i:int = 0;
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
            featureData[this.KEY_WEEKLY_AVERAGE_POINTS] = {};
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
            featureData[KEY_SAVED_DUMPED_TIMESTAMP] = {};
            featureData[KEY_FLUSH_DAILY_REWARD_TASK] = false;
            featureData[KEY_CURRENT_ORDERBOARD_LEADERBOARD] = "";
            featureData[KEY_CURRENT_VIRAL_LEADERBOARD] = "";
            featureData[KEY_CURRENT_WEEK] = 0;
            featureData[KEY_CURRENT_LEVEL] = 0;
            featureData[KEY_WEEKLY_REWARD_EASY_GRANTED] = false;
            featureData[KEY_WEEKLY_REWARD_MEDIUM_GRANTED] = false;
            featureData[KEY_WEEKLY_REWARD_HARD_GRANTED] = false;
            featureData[KEY_WEEKLY_REWARD_EASY_POPUP] = false;
            featureData[KEY_WEEKLY_REWARD_MEDIUM_POPUP] = false;
            featureData[KEY_WEEKLY_REWARD_HARD_POPUP] = false;
            featureData[KEY_FIRST_BADGE_GRANTED] = false;
            featureData[KEY_SECOND_BADGE_GRANTED] = false;
            featureData[KEY_THIRD_BADGE_GRANTED] = false;
            featureData[KEY_GA_FEATURE_START] = false;
            featureData[KEY_CHRISTMAS_ENTER] = false;
            featureData[this.KEY_ORDERBOARD_COUNT] = 0;
            featureData[this.KEY_ORDER_NO] = 0;
            featureData[this.KEY_BADGE_NO] = 0;
            featureData[this.KEY_CURRENT_AVERAGE] = 0;
            featureData[KEY_TILE_UNLOCK_COUNT] = 0;
            for(i = 0; i < this.NO_OF_WEEKS; i++)
            {
               featureData[this.KEY_ORDERBOARD_COUNT_TASK + "Week" + (i + 1).toString()] = {};
               featureData[this.KEY_ORDERBOARD_COUNT_TASK + "Week" + (i + 1).toString()][KEY_PLAYER_COUNT] = 0;
               featureData[this.KEY_ORDERBOARD_COUNT_TASK + "Week" + (i + 1).toString()][KEY_UPDATE_COUNT] = 0;
               featureData[this.KEY_ORDERBOARD_COUNT_TASK + "Week" + (i + 1).toString()][KEY_COMMUNITY_REWARDS] = 0;
            }
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
         orderBoardXml = Global.farmGameSettingsManager.getXML().WinternordInnovationQuests.WinternordInnovationQuest.(@name == questName)[0];
         rewardsList = orderBoardXml.WinternordInnovationRewards.stage;
         for each(rewardsByStage in rewardsList)
         {
            str = rewardsByStage.@id;
            rewardsXMLListByStage = rewardsByStage.rewards;
            this.m_rewardsBySlotName[rewardsByStage.@id] = rewardsXMLListByStage;
         }
      }
      
      protected function parseWeeklyRewardsDataFromConfig(questName:String) : void
      {
         var orderBoardXml:XML = null;
         var rewardsList:XMLList = null;
         var rewardsByStage:XML = null;
         var str:String = null;
         var rewardsXMLListByStage:XMLList = null;
         this.m_weeklyRewardsBySlotName = {};
         orderBoardXml = Global.farmGameSettingsManager.getXML().WinternordInnovationRewardQuests.WinternordInnovationRewardQuest.(@name == questName)[0];
         rewardsList = orderBoardXml.WinternordInnovationWeeklyRewards.stage;
         for each(rewardsByStage in rewardsList)
         {
            str = rewardsByStage.@id;
            rewardsXMLListByStage = rewardsByStage.rewards;
            this.m_weeklyRewardsBySlotName[rewardsByStage.@id] = rewardsXMLListByStage;
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
      
      public function onRedeemStarted() : void
      {
         this.checkAndUpdateWeeklyStatus();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onRedeemStarted",null,[m_featureName]),true);
      }
      
      public function getRewardsForTheWeek(weekInd:int = 0) : Vector.<Object>
      {
         var rewardXML:XML = null;
         var stageNum:int = 0;
         var rewardObj:Object = null;
         var rewards:Vector.<Object> = new Vector.<Object>();
         var index:int = 0;
         if(this.m_weeklyRewardsBySlotName == null)
         {
            this.parseWeeklyRewardsDataFromConfig(this.QUEST_NAME);
         }
         if(weekInd == 0)
         {
            stageNum = this.activeDayIndex;
            index = stageNum / 7;
         }
         else
         {
            index = weekInd;
         }
         var rewardXMLList:XMLList = this.m_weeklyRewardsBySlotName[index].reward;
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
               fItemName = "Yuletide Stable";
            }
            else
            {
               code = tasks[i].type;
               fItemName = this.getTaskItemName(code);
            }
            if(fItemName == null)
            {
               fItemName = "Winternord Task";
            }
            if(tasks[i].helperType == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
            {
               progress = CraftingManager.getInstance().getBushelQuantityInInventory(tasks[i].type) - featureData[KEY_SAVED_ACTIVE_TASKS][i][this.KEY_PROGRESS];
               hasUpdatedProgress = true;
               FarmStatsManager.count("WinternordInnovation","PerformTask",this.getKingdomText(tasks[i]),tasks[i].titleText);
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
                  FarmStatsManager.count("WinternordInnovation","PerformTask",this.getKingdomText(tasks[i]),tasks[i].titleText);
               }
            }
         }
         if(hasUpdatedProgress)
         {
            this.saveProgressForPlayer(progressArray);
         }
         if(hasCompletedTask)
         {
            if(this.m_winternordInnovationHud)
            {
               this.m_winternordInnovationHud.refresh(1);
            }
         }
      }
      
      public function updateOrderboardCount() : void
      {
         var cgProgress:int = 0;
         var cgTask:WinternordInnovationCommunityGoalTask = this.getCommunityGoalActiveTask();
         if(cgTask)
         {
            cgProgress = this.getOrderboardTaskCount();
            if(cgProgress > 0)
            {
               this.addCommGoalTaskCountForPlayer(cgTask.name,1);
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
               buildingName = "xwx_elitehorses";
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
      
      public function getOrderboardTaskCount() : int
      {
         var count:int = 0;
         var featureData:Object = this.getFeatureData();
         if(featureData.hasOwnProperty(this.KEY_ORDERBOARD_COUNT))
         {
            count = int(featureData[this.KEY_ORDERBOARD_COUNT]);
         }
         return count;
      }
      
      public function getLifetimeOrders() : int
      {
         var count:int = 0;
         var featureData:Object = this.getFeatureData();
         if(featureData.hasOwnProperty(this.KEY_ORDER_NO))
         {
            count = int(featureData[this.KEY_ORDER_NO]);
         }
         return count;
      }
      
      public function getUserState() : int
      {
         var featureObj:Object = this.getFeatureData();
         return featureObj[this.KEY_USER_STATE] as int;
      }
      
      public function grantUserRewardforLevel(level:int) : void
      {
         UserRewardUtil.grantUserReward(this.getRewardsForTheDay()[level]);
      }
      
      public function getActiveDayReward(level:int) : FarmItem
      {
         var rewardCode:String = (this.getRewardsForTheDay()[level] as Object).value;
         return Global.farmGameSettingsManager.getFarmItemByCode(rewardCode);
      }
      
      public function grantWeeklyRewardforLevel(level:int, weekind:int = 0) : void
      {
         UserRewardUtil.grantUserReward(this.getRewardsForTheWeek(weekind)[level]);
      }
      
      public function getActiveWeekReward(level:int, weekInd:int = 0) : FarmItem
      {
         var rewardCode:String = (this.getRewardsForTheWeek(weekInd)[level] as Object).value;
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
         var activeInd:int = 0;
         var weekObj:Object = null;
         var curWeek:int = 0;
         var i:int = 0;
         var featureData:Object = this.getFeatureData();
         if(this.hasActiveDayExpired() == true || featureData[this.KEY_USER_STATE] == this.NOT_INITIALIZED)
         {
            this.mainWindow.updateActiveDayIndex();
            if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_WINTERNORD) == false)
            {
               if(featureData.hasOwnProperty(KEY_GA_FEATURE_START) && featureData[KEY_GA_FEATURE_START] == false)
               {
                  featureData[KEY_GA_FEATURE_START] = true;
                  FeatureOptionsInventoryManager.getInstance().addCount(this.ConsumableCode,10);
               }
            }
            this.redeemHasStarted = false;
            this.redeemMessageShown = false;
            if(this.hasActiveDayExpired())
            {
               featureData[this.KEY_DAILY_PROGRESS_POINTS][this.activeDayIndex] = featureData[this.KEY_DAY_POINTS] > this.VAL_THIRD_MILESTONE ? this.VAL_THIRD_MILESTONE : featureData[this.KEY_DAY_POINTS];
            }
            if(featureData.hasOwnProperty(KEY_CURRENT_WEEK) && featureData[KEY_CURRENT_WEEK] != 0)
            {
               this.initializeCommunityRewardGrant();
            }
            this.checkAndUpdateChristmasPoints();
            if(featureData.hasOwnProperty(KEY_CURRENT_WEEK) && featureData[KEY_CURRENT_WEEK] == 0)
            {
               weekObjFirst = this.getCurrentWeek();
               curWeekFirst = int(weekObjFirst.count);
               featureData[KEY_CURRENT_WEEK] = curWeekFirst.toString();
            }
            else if(this.hasActiveWeekExpired())
            {
               this.checkAndUpdateWeeklyStatus();
               activeInd = this.activeDayIndex / 7;
               this.updateCurrentAverageKey();
               featureData[this.KEY_WEEKLY_AVERAGE_POINTS][activeInd] = featureData[this.KEY_CURRENT_AVERAGE];
               featureData[this.KEY_CURRENT_AVERAGE] = 0;
               featureData[this.KEY_ORDERBOARD_COUNT] = 0;
               featureData[KEY_WEEKLY_REWARD_EASY_GRANTED] = false;
               featureData[KEY_WEEKLY_REWARD_MEDIUM_GRANTED] = false;
               featureData[KEY_WEEKLY_REWARD_HARD_GRANTED] = false;
               featureData[KEY_WEEKLY_REWARD_EASY_POPUP] = false;
               featureData[KEY_WEEKLY_REWARD_MEDIUM_POPUP] = false;
               featureData[KEY_WEEKLY_REWARD_HARD_POPUP] = false;
               weekObj = this.getCurrentWeek();
               curWeek = int(weekObj.count);
               featureData[KEY_CURRENT_WEEK] = curWeek.toString();
               featureData[KEY_SHOW_COMMUNITY_FIRST_TIME_IN_WEEK] = 1;
            }
            featureData[this.KEY_ACTIVE_DAY_TIMESTAMP] = FarmGameUtil.getMidnightTimestamp() / 1000;
            this.mainWindow.updateActiveDayIndex();
            if(this.isChristmasWeek())
            {
               if(featureData.hasOwnProperty(KEY_CHRISTMAS_ENTER) && featureData[KEY_CHRISTMAS_ENTER] == false)
               {
                  featureData[KEY_CHRISTMAS_ENTER] = true;
               }
               featureData[this.KEY_DAY_POINTS] = this.VAL_FIRST_MILESTONE;
               featureData[this.KEY_USER_STATE] = this.MEDIUM;
            }
            else
            {
               featureData[this.KEY_DAY_POINTS] = 0;
               featureData[this.KEY_USER_STATE] = this.EASY;
            }
            this.grantChristmasWeekRewardConditionally();
            setFeatureData(featureData);
            if(this.activeDayIndex >= 35)
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
            }
            FarmStatsManager.count("WinternordInnovation","startNewDay",this.consumableCount.toString(),(this.activeDayIndex + 1).toString(),this.getCurrentLevel(),this.getActiveWeek().toString(),this.getCurrentAverage());
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startNewDay",null,[m_featureName]),true);
         }
      }
      
      private function grantChristmasWeekRewardConditionally() : void
      {
         var featureData:Object = this.getFeatureData();
         if(this.activeDayIndex >= 28 && featureData[KEY_CHRISTMAS_ENTER] == false)
         {
            featureData[KEY_CHRISTMAS_ENTER] = true;
            this.grantWeeklyRewardforLevel(this.EASY,3);
            this.showDailyBonusGrantPopup(this.getActiveWeekReward(this.EASY,3),true,true);
         }
      }
      
      public function grantChristmasRewardOnFeatureExpiry() : void
      {
         var featureData:Object = this.getFeatureData();
         if(!this.isFeatureInActivePeriod() && featureData[KEY_CHRISTMAS_ENTER] == false)
         {
            featureData[KEY_CHRISTMAS_ENTER] = true;
            this.grantWeeklyRewardforLevel(this.EASY,3);
            this.showDailyBonusGrantPopup(this.getActiveWeekReward(this.EASY,3),true,true);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"grantChristmasRewardOnFeatureExpiry",null,[m_featureName]),true);
         }
      }
      
      public function checkAndUpdateChristmasPoints() : void
      {
         var cPoint:int = 0;
         var cAvg:int = 0;
         var cIndex1:int = 0;
         var featureData:Object = this.getFeatureData();
         var daysToCheck:int = this.currentDayIndex < 28 ? this.currentDayIndex : 28;
         for(var cIndex:int = 21; cIndex < daysToCheck; cIndex++)
         {
            if(featureData[this.KEY_DAILY_PROGRESS_POINTS].hasOwnProperty(cIndex))
            {
               if(featureData[this.KEY_DAILY_PROGRESS_POINTS][cIndex] < this.VAL_FIRST_MILESTONE)
               {
                  featureData[this.KEY_DAILY_PROGRESS_POINTS][cIndex] = this.VAL_FIRST_MILESTONE;
               }
            }
            else
            {
               featureData[this.KEY_DAILY_PROGRESS_POINTS][cIndex] = this.VAL_FIRST_MILESTONE;
            }
         }
         if(this.currentDayIndex >= 28)
         {
            cPoint = 0;
            cAvg = 0;
            for(cIndex1 = 21; cIndex1 < daysToCheck; cIndex1++)
            {
               cPoint += featureData[this.KEY_DAILY_PROGRESS_POINTS][cIndex1];
            }
            cAvg = cPoint / 7;
            featureData[this.KEY_WEEKLY_AVERAGE_POINTS][3] = cAvg;
         }
         setFeatureData(featureData);
      }
      
      public function get consumableCount() : Number
      {
         return int(FeatureOptionsInventoryManager.getInstance().getCount(this.ConsumableCode));
      }
      
      public function isChristmasWeek() : Boolean
      {
         var result:Boolean = false;
         var curDayInd:int = this.currentDayIndex;
         if(curDayInd >= 21 && curDayInd < 28)
         {
            result = true;
         }
         return result;
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
      
      public function pointsRemainingForBadge(badgeNo:int) : int
      {
         var milestones:Array = [this.VAL_FIRST_ORDER_MILESTONE,this.VAL_SECOND_ORDER_MILESTONE,this.VAL_THIRD_ORDER_MILESTONE];
         var featureData:Object = this.getFeatureData();
         return milestones[badgeNo] - featureData[this.KEY_ORDER_NO];
      }
      
      public function isFirstBadgeRecieved() : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(featureData[this.KEY_ORDER_NO] >= this.VAL_FIRST_ORDER_MILESTONE && featureData[KEY_FIRST_BADGE_GRANTED] == true)
         {
            result = true;
         }
         return result;
      }
      
      public function isSecondBadgeRecieved() : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(featureData[this.KEY_ORDER_NO] >= this.VAL_SECOND_ORDER_MILESTONE && featureData[KEY_SECOND_BADGE_GRANTED] == true)
         {
            result = true;
         }
         return result;
      }
      
      public function isThirdBadgeRecieved() : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(featureData[this.KEY_ORDER_NO] >= this.VAL_THIRD_ORDER_MILESTONE && featureData[KEY_THIRD_BADGE_GRANTED] == true)
         {
            result = true;
         }
         return result;
      }
      
      public function allBadgesEarned() : Boolean
      {
         var result:Boolean = false;
         if(this.isFirstBadgeRecieved() && this.isSecondBadgeRecieved() && this.isThirdBadgeRecieved())
         {
            result = true;
         }
         return result;
      }
      
      public function getWeeklyRating() : String
      {
         var result:String = null;
         var featureData:Object = this.getFeatureData();
         if(featureData[KEY_WEEKLY_REWARD_HARD_GRANTED] == true)
         {
            result = "ECTASTIC";
         }
         else if(featureData[KEY_WEEKLY_REWARD_MEDIUM_GRANTED] == true)
         {
            result = "JOLLY";
         }
         else if(featureData[KEY_WEEKLY_REWARD_EASY_GRANTED] == true)
         {
            result = "CONTENT";
         }
         else
         {
            result = "SAD";
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
      
      public function getSinkButtonToolTipMessage() : String
      {
         var msg:String = "";
         if(!this.hasActiveDayExpired())
         {
            if(this.isUserLocked() != false)
            {
               if(this.hasEnoughConsumableToSink() == false)
               {
                  msg = "Collect more Wrapping Papers to unlock the next milestone.";
               }
               else
               {
                  msg = "Use Wrapping Paper to unlock the next level.";
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
         if(this.hasActiveWeekExpired() && this.activeDayIndex >= 21 && this.activeDayIndex < 28 && this.currentDayIndex >= 28)
         {
            totalPoints = 0;
            for(index = 21; index < 28; index++)
            {
               totalPoints += featureData[this.KEY_DAILY_PROGRESS_POINTS][index];
            }
         }
         return totalPoints;
      }
      
      public function getCurrentWeekStartDayIndex() : int
      {
         var numDay:int = this.activeDayIndex % 7;
         return this.activeDayIndex - numDay;
      }
      
      public function getCurrentAverage() : int
      {
         var startDayIndexForWeek:int = 0;
         var numDay:int = this.activeDayIndex % 7;
         var divisor:int = this.hasActiveWeekExpired() ? 7 : int(numDay + 1);
         startDayIndexForWeek = this.getCurrentWeekStartDayIndex();
         var totalPoints:int = this.getTotalPointsForUser(startDayIndexForWeek);
         return int(totalPoints / divisor);
      }
      
      public function updateCurrentAverageKey() : void
      {
         var featureConfig:Object = this.getFeatureData();
         featureConfig[this.KEY_CURRENT_AVERAGE] = this.getCurrentAverage();
         setFeatureData(featureConfig);
      }
      
      public function openRewardViewWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         this.m_rewardWindow = new WinternordInnovationRewardWindow(m_featureName,this.rewardWindowURL);
         UI.displayPopup(this.m_rewardWindow,false);
      }
      
      public function openCommunityGoalsWindow(showReward:Boolean = false) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         var activeTask:WinternordInnovationCommunityGoalTask = this.getActiveTaskByName(this.activeTaskName);
         this.m_communityGoalWindow = new WinternordInnovationCommunityGoalWindow(COMMUNITY_GOAL_WINDOW,m_featureName,this.m_mainWindow,activeTask,showReward);
         UI.displayPopup(this.m_communityGoalWindow,false);
         FarmStatsManager.count(m_featureName,"Click","Community");
      }
      
      public function get mainWindow() : WinternordInnovationMainWindow
      {
         return this.m_mainWindow;
      }
      
      public function get activeDayIndex() : int
      {
         var dayIndex:int = 0;
         var featureData:Object = this.getFeatureData();
         var activeDayTS:Number = featureData[this.KEY_ACTIVE_DAY_TIMESTAMP] as Number;
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("12/03/2018") / FarmGameUtil.NUM_MSECS_IN_SECOND;
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
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("12/03/2018");
         dayIndex = (GlobalEngine.serverTime - featureStartDayTS) / FarmGameUtil.NUM_MSECS_IN_DAY;
         if(dayIndex < 0)
         {
            dayIndex = 0;
         }
         return dayIndex;
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
         return ["3vm8","yxfz","6oxl"];
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
         if(featureData[this.KEY_WEEKLY_AVERAGE_POINTS].hasOwnProperty(index.toString()))
         {
            points = int(featureData[this.KEY_WEEKLY_AVERAGE_POINTS][index.toString()]);
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
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("winternord_innovation_bonus_enabled");
         if(!PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            result = false;
         }
         if(this.getRewardLevel() < 2)
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
         var key:String = null;
         var harvestRewardName:String = null;
         var harvestFarmItem:FarmItem = null;
         var count:int = 0;
         var bonusName:String = null;
         var lvl:int = 0;
         var bonusCount:int = 0;
         var consumableRotationCount:int = 0;
         var bcnt:int = 0;
         if(!m_initialized)
         {
            this.initialize();
         }
         var featureData:Object = this.getFeatureData();
         if(this.getRewardLevel() >= 2)
         {
            key = LAST_BONUS_HARVEST_TIME_KEY;
            Global.player.setFeatureLastShown(key,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
            harvestRewardName = this.getNextHarvestItemName();
            harvestFarmItem = Global.farmGameSettingsManager.getFarmItemByName(harvestRewardName);
            if(harvestFarmItem)
            {
               count = 1;
               if(this.getRewardLevel() == 4)
               {
                  lvl = this.getRewardLevel();
                  if(featureData.hasOwnProperty(BONUS_HARVEST_COUNT))
                  {
                     bonusCount = featureData[BONUS_HARVEST_COUNT] as int;
                  }
                  else
                  {
                     bonusCount = 0;
                  }
                  consumableRotationCount = int(BONUS_COUNT_MAP[lvl]);
                  bcnt = bonusCount % consumableRotationCount;
                  if(bcnt >= 7 && bcnt <= 10)
                  {
                     count = 2;
                  }
               }
               Global.player.addGift(harvestRewardName,"",count);
               bonusName = BONUS_NAME_ARRAY[this.getRewardLevel()];
               UI.displayPopup(new WinternordInnovationPostBonusHarvestWindow("assets/dialogs/expansion/FV_RewardDialog.swf",featureName,bonusName,harvestFarmItem,null,"assets/dialogs/winternord/RewardDialog.png",count));
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,this.SERVICE_FUNC_HARVEST_BONUS,null,[m_featureName]),true);
               FarmStatsManager.count("WinternordInnovation","Reward","Nisse gift house",this.getCurrentLevel(),harvestFarmItem.friendlyTitle,this.getActiveWeek(),this.activeDayIndex + 1);
            }
         }
      }
      
      private function getNextHarvestItemName() : String
      {
         var couponName:String = null;
         var lvl:int = 0;
         var consumableRotationCount:int = 0;
         var bonusCount:int = 0;
         var featureData:Object = this.getFeatureData();
         if(this.getRewardLevel() >= 2)
         {
            lvl = this.getRewardLevel();
            if(featureData.hasOwnProperty(BONUS_HARVEST_COUNT))
            {
               bonusCount = featureData[BONUS_HARVEST_COUNT] as int;
            }
            else
            {
               featureData[BONUS_HARVEST_COUNT] = 0;
               bonusCount = 0;
            }
            consumableRotationCount = int(BONUS_COUNT_MAP[lvl]);
            couponName = this.BONUS_HARVEST_ARRAY[this.getCurrentLevel()][bonusCount % consumableRotationCount];
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
      
      public function set mainWindow(mainWindowInstance:WinternordInnovationMainWindow) : void
      {
         this.m_mainWindow = mainWindowInstance;
      }
      
      public function playForCommunityGoals() : void
      {
         var i:int = 0;
         var featureData:Object = this.getFeatureData();
         if(featureData[KEY_SHOW_COMMUNITY_FIRST_TIME_IN_WEEK] == 1)
         {
            this.openCommunityGoalsWindow(false);
            featureData[KEY_SHOW_COMMUNITY_FIRST_TIME_IN_WEEK] = 0;
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
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"playForCommunityGoals",null,[m_featureName]),true);
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
      
      public function initializeCommunityProgress(isSync:Boolean = false) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getCommunityEntries",this.getCommunityEntries,[m_featureName,isSync]));
      }
      
      public function getCommunityEntries(result:Object = null) : void
      {
         if(result != null)
         {
            if(result["CommunityData"])
            {
               this.checkCommunityRewards(result["CommunityData"]);
            }
         }
      }
      
      public function initializeCommGoalLeaderboard() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getCommLeaderboardEntries",this.getCommLeaderboardEntries,[m_featureName]));
      }
      
      public function getCommLeaderboardEntries(result:Object = null) : void
      {
         if(result != null)
         {
            if(this.m_communityGoalWindow)
            {
               this.m_communityGoalWindow.populateLeaderboard(result);
            }
         }
      }
      
      public function initializeCommunityRewardGrant() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"checkCommunityRewards",this.checkCommunityRewards,[m_featureName]));
      }
      
      public function checkCommunityRewards(data:Object) : void
      {
         if(data)
         {
            if(data.hasOwnProperty("rewards"))
            {
               this.m_communityRewardsEarned = data.rewards;
               if(this.hasActiveWeekExpired())
               {
                  this.displayPreviousCommunityRewardDialog();
               }
               else
               {
                  this.displayCommunityRewardDialog();
               }
            }
         }
      }
      
      public function displayCommunityRewardDialog() : void
      {
         var rewardXMLs:Array = null;
         var taskList:Array = null;
         var activeTask:WinternordInnovationCommunityGoalTask = null;
         var task:WinternordInnovationCommunityGoalTask = null;
         if(this.m_communityRewardsEarned)
         {
            rewardXMLs = [];
            taskList = this.getCommunityGoalTaskList();
            activeTask = this.getCommunityGoalActiveTask();
            if(taskList)
            {
               for each(task in taskList)
               {
                  if(this.m_communityRewardsEarned[task.name])
                  {
                     rewardXMLs.push(task.rewards);
                     this.grantCommunityGoalReward(task.rewards);
                     this.setCommGoalRewardGrantedForStage(task.name,1);
                     FarmStatsManager.count(m_featureName,"Reward","Community",this.getOrderboardTaskCount().toString(),this.m_communityRewardsEarned[task.name],this.getActiveWeek(),this.activeDayIndex + 1);
                  }
               }
            }
            if(rewardXMLs.length > 0 && Boolean(activeTask))
            {
               if(this.m_communityRewardsEarned[activeTask.name])
               {
                  if(this.m_communityGoalWindow)
                  {
                     this.m_communityGoalWindow.tintWindow();
                     this.m_communityGoalWindow.enableInput = false;
                  }
                  this.m_commRewardWindow = new WinternordCommunityGoalsRewardWindow(activeTask,rewardXMLs[0],m_featureName);
                  UI.displayPopup(this.m_commRewardWindow,false);
               }
            }
         }
      }
      
      public function displayPreviousCommunityRewardDialog() : void
      {
         var rewardXMLs:Array = null;
         var taskList:Array = null;
         var activeTaskList:Array = null;
         var task:WinternordInnovationCommunityGoalTask = null;
         var ind:int = 0;
         var i:int = 0;
         if(this.m_communityRewardsEarned)
         {
            rewardXMLs = [];
            taskList = this.getCommunityGoalTaskList();
            activeTaskList = this.getCommunityGoalLastWeekTaskList();
            if(taskList)
            {
               for each(task in taskList)
               {
                  if(this.m_communityRewardsEarned[task.name])
                  {
                     rewardXMLs.push(task.rewards);
                     this.grantCommunityGoalReward(task.rewards);
                     this.setCommGoalRewardGrantedForStage(task.name,1);
                     FarmStatsManager.count(m_featureName,"Reward","Community",this.getOrderboardTaskCount().toString(),this.m_communityRewardsEarned[task.name],this.getActiveWeek(),this.activeDayIndex + 1);
                  }
               }
            }
            if(rewardXMLs.length > 0)
            {
               if(activeTaskList)
               {
                  ind = 0;
                  for(i = 0; i < 2; i++)
                  {
                     if(activeTaskList[i] != null)
                     {
                        if(this.m_communityRewardsEarned[activeTaskList[i].name])
                        {
                           if(this.mainWindow)
                           {
                              this.mainWindow.tintWindow();
                              this.mainWindow.enableInput = false;
                           }
                           this.m_commRewardWindow = new WinternordCommunityGoalsRewardWindow(activeTaskList[i],rewardXMLs[ind],m_featureName,i + 1,true);
                           UI.displayPopup(this.m_commRewardWindow,false);
                           ind++;
                        }
                     }
                  }
               }
            }
         }
      }
      
      public function grantCommunityGoalReward(rewardData:XMLList) : void
      {
         var rewardXML:XML = null;
         var rewardName:String = null;
         var rewardCount:int = 0;
         var farmItem:FarmItem = null;
         for each(rewardXML in rewardData)
         {
            if(rewardXML)
            {
               rewardName = rewardXML.attribute("name").toString();
               rewardCount = parseInt(rewardXML.attribute("qty").toString());
               if(Boolean(rewardName) && rewardName != "")
               {
                  farmItem = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
                  Global.player.addGift(rewardName,"0",rewardCount);
               }
            }
         }
      }
      
      public function isBonusHarvestExpired() : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("01/13/2019") / FarmGameUtil.NUM_MSECS_IN_SECOND;
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
         return result;
      }
      
      public function getCurrentLevel() : String
      {
         var result:String = null;
         var featureData:Object = this.getFeatureData();
         if(featureData)
         {
            result = featureData[KEY_CURRENT_LEVEL];
         }
         return result;
      }
      
      public function isChristmasActive() : Boolean
      {
         var result:Boolean = false;
         if(this.activeDayIndex >= 21 && this.activeDayIndex < 28)
         {
            result = true;
         }
         return result;
      }
      
      public function getRewardLevel() : int
      {
         return int(this.getCurrentLevel());
      }
      
      public function getCurrentWeek() : Object
      {
         var startDate:Number = NaN;
         var endDate:Number = NaN;
         var weekXML:XML = null;
         if(this.hasFeatureExpired())
         {
            return {
               "count":6,
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
         var name:String = "WinternordInnovationMapTrigger";
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
      
      public function getCommunityGoalData() : Array
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         return this.m_staticData.communityGoalConfigData;
      }
      
      public function getWeeksArray() : Array
      {
         return this.m_staticData.weeks;
      }
      
      public function isGAPlayer() : Boolean
      {
         var featureData:Object = this.getFeatureData();
         var result:Boolean = false;
         if(featureData.hasOwnProperty(KEY_GA_FEATURE_START) && featureData[KEY_GA_FEATURE_START] == true)
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
      
      public function setCommunityGoalTaskList() : void
      {
         var cgTask:WinternordInnovationCommunityGoalTask = null;
         var task:XML = null;
         var result:Array = new Array();
         var communityGoalData:Object = this.getCommunityGoalData();
         if(communityGoalData)
         {
            for each(task in communityGoalData)
            {
               cgTask = new WinternordInnovationCommunityGoalTask(task);
               if(cgTask)
               {
                  result.push(cgTask);
               }
            }
         }
         this.m_CgTaskList = result;
      }
      
      public function getCommunityGoalTaskList() : Array
      {
         if(!this.m_CgTaskList)
         {
            this.setCommunityGoalTaskList();
         }
         return this.m_CgTaskList;
      }
      
      private function addCommGoalTaskCountForPlayer(taskName:String, progress:int) : void
      {
         var featureData:Object = this.getFeatureData();
         if(featureData)
         {
            if(featureData.hasOwnProperty(taskName))
            {
               featureData[taskName][KEY_PLAYER_COUNT] += progress;
               setFeatureData(featureData);
            }
         }
      }
      
      public function getCommGoalPlayerCountForTask(taskName:String) : Number
      {
         var result:int = 0;
         var featureData:Object = this.getFeatureData();
         if(Boolean(featureData) && Boolean(featureData.hasOwnProperty(taskName)) && Boolean(featureData[taskName][KEY_PLAYER_COUNT]))
         {
            result = int(featureData[taskName][KEY_PLAYER_COUNT]);
         }
         return result;
      }
      
      public function getCommunityGoalActiveTask() : WinternordInnovationCommunityGoalTask
      {
         var result:WinternordInnovationCommunityGoalTask = null;
         var task:WinternordInnovationCommunityGoalTask = null;
         var taskList:Array = this.getCommunityGoalTaskList();
         if(taskList)
         {
            for each(task in taskList)
            {
               if(task.isActive())
               {
                  result = task;
                  break;
               }
            }
         }
         return result;
      }
      
      public function get activeTaskName() : String
      {
         var activeWeek:String = this.getActiveWeek() == "0" ? "1" : this.getActiveWeek();
         return this.COMMUNITY_TASK_PREFIX + activeWeek;
      }
      
      public function getCommunityGoalTaskRemainingPoints() : int
      {
         var activeTask:WinternordInnovationCommunityGoalTask = this.getActiveTaskByName(this.activeTaskName);
         return activeTask.playerGoal - this.getCommGoalPlayerCountForTask(this.activeTaskName);
      }
      
      public function getActiveTaskByName(taskName:String) : WinternordInnovationCommunityGoalTask
      {
         var task:WinternordInnovationCommunityGoalTask = null;
         var activeTask:WinternordInnovationCommunityGoalTask = this.getCommunityGoalActiveTask();
         if(taskName == activeTask.name)
         {
            return activeTask;
         }
         for each(task in this.getCommunityGoalTaskList())
         {
            if(task.name == taskName)
            {
               return task;
            }
         }
         return activeTask;
      }
      
      public function getCommunityGoalActiveTaskList() : Array
      {
         var result:WinternordInnovationCommunityGoalTask = null;
         var task:WinternordInnovationCommunityGoalTask = null;
         var taskList:Array = this.getCommunityGoalTaskList();
         var taskArray:Array = new Array();
         if(taskList)
         {
            for each(task in taskList)
            {
               if(task.isActive())
               {
                  result = task;
                  taskArray.push(result);
               }
            }
         }
         return taskArray;
      }
      
      public function getCommunityGoalLastWeekTaskList() : Array
      {
         var result:WinternordInnovationCommunityGoalTask = null;
         var task:WinternordInnovationCommunityGoalTask = null;
         var taskList:Array = this.getCommunityGoalTaskList();
         var taskArray:Array = new Array();
         var featureData:Object = this.getFeatureData();
         var weekNo:int = int(featureData[KEY_CURRENT_WEEK]);
         if(taskList)
         {
            for each(task in taskList)
            {
               if(task.name == "winternordInnovationOrderboardTaskWeek" + weekNo.toString())
               {
                  result = task;
                  taskArray.push(result);
               }
            }
         }
         return taskArray;
      }
      
      public function isCommGoalRewardGranted(taskName:String, stageNumber:Number) : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(Boolean(featureData) && Boolean(featureData.hasOwnProperty(taskName)) && Boolean(featureData[taskName][KEY_COMMUNITY_REWARDS]))
         {
            if(featureData[taskName][KEY_COMMUNITY_REWARDS] == 1)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function setCommGoalRewardGrantedForStage(taskName:String, stage:Number) : void
      {
         var featureData:Object = this.getFeatureData();
         if(Boolean(featureData) && Boolean(featureData.hasOwnProperty(taskName)) && featureData[taskName][KEY_COMMUNITY_REWARDS] == 0)
         {
            featureData[taskName][KEY_COMMUNITY_REWARDS] = 1;
            setFeatureData(featureData);
         }
      }
      
      public function getCommunityProgressForTask(taskName:String, callback:Function = null) : void
      {
         var activeTask:WinternordInnovationCommunityGoalTask = this.getCommunityGoalActiveTask();
         if(activeTask.name == taskName)
         {
            TransactionManager.addTransaction(new TWinternordCommunityGoalsGetProgress(activeTask,callback),true);
         }
      }
      
      public function isTestingMode() : Boolean
      {
         var result:Boolean = false;
         if(Boolean(Global.flashHotParams[WINTERNORD_COMMUNITY_GOALS_TESTING_FLAG]) && Global.flashHotParams[WINTERNORD_COMMUNITY_GOALS_TESTING_FLAG] == true)
         {
            result = true;
         }
         return result;
      }
      
      public function getRuntimeTaskData(taskName:String) : Object
      {
         var dataObj:Object = null;
         var taskData:Object = null;
         if(!this.m_cachedTaskData)
         {
            this.m_cachedTaskData = new Object();
            if(Global.flashHotParams.hasOwnProperty(WINTERNORD_COMMUNITY_GOALS_TASK_DATA))
            {
               dataObj = FarmGameUtil.JSONDecode(Global.flashHotParams[WINTERNORD_COMMUNITY_GOALS_TASK_DATA].toString(),"WinternordInnovationManager_getRuntimeTaskData");
               if(dataObj)
               {
                  this.m_cachedTaskData = dataObj;
               }
            }
         }
         if(this.m_cachedTaskData[taskName])
         {
            taskData = this.m_cachedTaskData[taskName];
         }
         return taskData;
      }
   }
}

