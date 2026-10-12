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
   import Display.HUD.HUDWidgets.HudBottomPumpkinPartyInnovationButton;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.TileUnlockEvent;
   import Managers.Crafting.CraftingManager;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.GenericSingleRewardPopup;
   import Widgets.Windows.PumpkinPartyInnovationBuyWindow;
   import Widgets.Windows.PumpkinPartyInnovationDailyBonusGrantWindow;
   import Widgets.Windows.PumpkinPartyInnovationFinalRewardWindow;
   import Widgets.Windows.PumpkinPartyInnovationLBRewardWindow;
   import Widgets.Windows.PumpkinPartyInnovationMainWindow;
   import Widgets.Windows.PumpkinPartyInnovationPostBonusHarvestWindow;
   import Widgets.Windows.PumpkinPartyInnovationRewardUpgradeWindow;
   import Widgets.Windows.PumpkinPartyInnovationRewardWindow;
   import Widgets.Windows.PumpkinPartyInnovationTileRewardsWindow;
   import Widgets.Windows.PumpkinPartyInnovationTileUnlockwindow;
   import Widgets.Windows.PumpkinPartyInnovationWelcomeBackWindow;
   import com.adobe.serialization.json.JSON;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.Timer;
   
   public class PumpkinPartyInnovationManager extends BaseFeatureManager
   {
      
      public static const HUD_INITIALISATION_FLAG:String = "pumpkinparty_innovation_hud_initialise_flag";
      
      private static const HUD_TWENTIES_ASSET:String = "assets/dialogs/FV_OctoberInnovation_2020/FV_PumpkinParty_hud_Innovation.swf";
      
      public static const FEATURE_NAME:String = "PumpkinPartyInnovation";
      
      private static const WINDOW_MAIN:String = "main";
      
      private static const WINDOW_REWARD:String = "reward";
      
      private static const WINDOW_LBREWARD:String = "lbreward";
      
      private static const WINDOW_CONGRATS:String = "congrats";
      
      private static const WINDOW_BUY:String = "buyDialog";
      
      public static const COLLECT_TIME_KEY:String = "ctk";
      
      public static const FEED_NAME:String = "PumpkinPartyInnovationUI";
      
      public static const FEATURE_OPTIONS_KEY:String = "PumpkinPartyInnovation";
      
      public static const KEY_WEEKLY_REWARD_EASY_GRANTED:String = "PumpkinParty_weekly_easy_reward_granted";
      
      public static const KEY_WEEKLY_REWARD_MEDIUM_GRANTED:String = "PumpkinParty_weekly_medium_reward_granted";
      
      public static const KEY_WEEKLY_REWARD_HARD_GRANTED:String = "PumpkinParty_weekly_hard_reward_granted";
      
      public static const KEY_WEEKLY_REWARD_EASY_POPUP:String = "PumpkinParty_weekly_easy_popup_shown";
      
      public static const KEY_WEEKLY_REWARD_MEDIUM_POPUP:String = "PumpkinParty_weekly_medium_popup_shown";
      
      public static const KEY_WEEKLY_REWARD_HARD_POPUP:String = "PumpkinParty_weekly_hard_popup_shown";
      
      public static const KEY_GA_FEATURE_START:String = "ga_PumpkinParty_innovation_start";
      
      public static const KEY_EA_FEATURE_START:String = "ea_PumpkinParty_innovation_start";
      
      private static var m_initialized:Boolean = false;
      
      private static const SKIP_COST:int = 1;
      
      private static const KEY_SAVED_ACTIVE_TASKS:String = "1";
      
      private static const KEY_SAVED_DUMPED_TIMESTAMP:String = "3";
      
      private static const KEY_LAST_LB_REFRESH_TIMESTAMP:String = "lbts";
      
      private static const KEY_FLUSH_DAILY_REWARD_TASK:String = "flush_daily_reward_tasks";
      
      private static const KEY_CURRENT_WEEK:String = "currentweek";
      
      private static const KEY_CURRENT_LEVEL:String = "currentlevel";
      
      private static const KEY_CURRENT_ORDERBOARD_LEADERBOARD:String = "currentOrderboardLeaderboard";
      
      private static const KEY_CURRENT_VIRAL_LEADERBOARD:String = "currentViralLeaderboard";
      
      private static const KEY_CURRENT_LEADERBOARD:String = "currentLeaderboard";
      
      private static const KEY_SAVED_LEADERBOARD_RESULT:String = "leaderboard_data";
      
      private static const SERVICE_NAME:String = "PumpkinPartyInnovationService";
      
      public static const PUMPKINPARTY_TILE_UNLOCK_COUNT:String = "qm4e";
      
      private static const KEY_TILE_UNLOCK_COUNT:String = "PumpkinParty_tile_unlock_count";
      
      private static const LAST_BONUS_HARVEST_TIME_KEY:String = "xpu_bht";
      
      public static const DEFAULT_HARVEST_THROTTLE_TIME:Number = 86400;
      
      private static const CRAFTSHOP_CONSUMABLE_TAB:String = "consumable";
      
      private static const BONUS_HARVEST_COUNT:String = "hc";
      
      private static const BONUS_COUNT_MAP:Array = [0,0,10,12,15,15];
      
      public static const BONUS_NAME_ARRAY:Array = ["Abandoned Plot","Decorated Halloween Hut","Spooky Celebration House","Pumpkin Bungalow","Grand Party Mansion"];
      
      public static const ZRUNTIME_TROPIC_ESCAPE_LINK:String = "TROPIC_ESCAPE_LINK";
      
      public static const ZRUNTIME_TROPIC_ESCAPE_STAGE_LINK:String = "TROPIC_ESCAPE_STAGE_LINK";
      
      public static const ZRUNTIME_TROPIC_ESCAPE_TOKENS_UPDATE_DELAY:String = "TROPIC_ESCAPE_TOKENS_UPDATE_DELAY";
      
      public static const ZRUNTIME_TROPIC_ESCAPE_TOKENS_UPDATE_REPEAT_COUNT:String = "TROPIC_ESCAPE_TOKENS_UPDATE_REPEAT_COUNT";
      
      public const TILE_UNLOCK:String = "PumpkinParty_Tile_Unlock";
      
      public const FIRST_TIME_UNLOCK:String = "PumpkinParty_First_tile_Unlock";
      
      private var m_cachedTaskData:Object;
      
      private var m_LBRewardsEarned:Object;
      
      public const DEFAULT_THROTTLE_TIME:Number = 86400;
      
      private var m_assetPaths:Object = null;
      
      protected var m_staticData:Object;
      
      private var m_mainWindow:PumpkinPartyInnovationMainWindow;
      
      private var m_buyWindow:PumpkinPartyInnovationBuyWindow;
      
      private var m_rewardPopup:GenericSingleRewardPopup;
      
      private var m_zid:String = "";
      
      public const VAL_FIRST_MILESTONE:int = 20;
      
      public const VAL_SECOND_MILESTONE:int = 40;
      
      public const VAL_THIRD_MILESTONE:int = 70;
      
      public const VAL_WEEK_FIRST_MILESTONE:int = 16;
      
      public const VAL_WEEK_SECOND_MILESTONE:int = 36;
      
      public const VAL_WEEK_THIRD_MILESTONE:int = 60;
      
      protected const KEY_PROGRESS:String = "progress";
      
      protected const KEY_TOTAL:String = "total";
      
      private var m_resultObject:Object;
      
      private const QUEST_NAME:String = "PumpkinPartyInnovation";
      
      private var m_pumpkinpartyInnovationHud:HudBottomPumpkinPartyInnovationButton;
      
      private const WEEKLY_SCORE:String = "weekly_score";
      
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
      
      private const KEY_WEEKLY_AVERAGE_POINTS:String = "wavgpts";
      
      private const KEY_IS_EA_REWARD_GRANTED:String = "isEaWeeklyReward";
      
      private const FEATURE_OPTIONS_BONUS_CLAIMED_KEY:String = "bonus";
      
      private const KEY_FEATURE_ENDED:String = "finished";
      
      private const KEY_ACTIVE_DAY_TIMESTAMP:String = "ts";
      
      private var m_rewardWindow:PumpkinPartyInnovationRewardWindow;
      
      private var m_rewardLBWindow:PumpkinPartyInnovationLBRewardWindow;
      
      private var m_finalRewardWindow:PumpkinPartyInnovationFinalRewardWindow;
      
      private const KEY_TASK_LEVEL:String = "taskLevel";
      
      private const FEATURE_OPTIONS_BONUS_CODE_KEY:String = "bonusCode";
      
      private var m_rewardsBySlotName:Object = null;
      
      private var m_weeklyRewardsBySlotName:Object = null;
      
      public const VAL_MILESTONE_POINTS_ARRAY:Array = [20,40,70];
      
      public const VAL_CLASSIC:int = 70;
      
      public const VAL_SUPERB:int = 40;
      
      public const VAL_GOOD:int = 20;
      
      public const NO_OF_WEEKS:int = 5;
      
      private const SERVICE_FUNC_HARVEST_BONUS:String = "harvestBonusBuilding";
      
      private const EVENT_TWENTIES_INNOVATION_TILE_UNLOCK:String = "PumpkinPartyInnovationTileUnlock";
      
      public const CRUSH_BARREL_TUTORIAL:String = "PumpkinPartyInnovationSinkTutorial";
      
      public const FIRST_SESSION_TUTORIAL:String = "PPFirstSessioTutorial";
      
      public const INNOVATION_TUTORIAL_SEEN:String = "PumpkinPartyInnovation_tutorial";
      
      public const WEEK_START:String = "PumpkinPartyWeekStart";
      
      private var BONUS_HARVEST_ARRAY:Object = {
         "2":["fuel1","vehiclepart","pkg_xpu_treasurepart_pack","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard"],
         "3":["consume_unwither","consume_organic_fertilizer","fuel1","vehiclepart","pkg_xpu_treasurepart_pack","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard"],
         "4":["consume_instagrow","pkg_xpu_bigbuildable_pack","consume_turbo_charger","consume_unwither","consume_organic_fertilizer","fuel1","vehiclepart","pkg_xpu_treasurepart_pack","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard"]
      };
      
      private var _redeemHasStarted:Boolean = false;
      
      private var _redeemMessageShown:Boolean = false;
      
      private const REDEEM_ADDITIONAL_DAYS:int = 0;
      
      public const REWARD_ITEM:Array = ["assets/decorations/xpu_abandonedplot_icon.png","assets/decorations/xpu_decoratedhut_icon.png","assets/decorations/xpu_spookycelebrationhouse_icon.png","assets/decorations/xpu_pumpkinbungalow_icon.png","assets/decorations/xpu_grandpartymansion_icon.png"];
      
      public const REWARD_ITEM_200:Array = ["assets/decorations/xpu_abandonedplot_icon_200.png","assets/decorations/xpu_decoratedhut_icon_200.png","assets/decorations/xpu_spookycelebrationhouse_icon_200.png","assets/decorations/xpu_pumpkinbungalow_icon_200.png","assets/decorations/xpu_grandpartymansion_icon_200.png"];
      
      private const KEY_ESCAPE_TOKENS_AVAILABLE:String = "escapeTokensAvailable";
      
      private const KEY_ORDERBOARD_BOOSTS_AVAILABLE:String = "orderboardBoostsAvailable";
      
      private const KEY_TASKS_DONE_WITHOUT_ORDERBOARD_BOOST:String = "orderboardTasksDoneWithoutBoost";
      
      private const PUMPKIN_PARTY_FLAG_BOOST_POPUP_SEEN:String = "PumpkinParty_boost_popup";
      
      private var FLAG_TROPIC_CONNECTION_INITIALIZED:String = "PumpkinParty_tropic_escape_connection_initialized";
      
      private const PUMPKIN_PARTY_TASK_BOOST_CALLOUT:* = "pumpkin_party_task_boost_callout";
      
      private const KEY_CURRENT_TILE_LEVEL:String = "currentTileLevel";
      
      private const KEY_ESCAPE_TOKENS_COLLECTED:String = "escapeTokensCollected";
      
      private const KEY_TESTING_COUNT:String = "tcnt";
      
      private const KEY_ESCAPE_TOKENS_PROGRESS:String = "escapeTokensProgress";
      
      private const KEY_TE_CONNECTION_INITIALIZED:String = "tropicEscapeConnectionInitialized";
      
      private var m_tokensUpdateInProgress:Boolean = false;
      
      private var TOKENS_REQUIRED_FOR_UNLOCK:Array = [50,100,200,300,400,60000];
      
      private var TILE_REWARDS:Array = ["xpu_rubbletreasure10","xpu_rubbletreasure11","xpu_rubbletreasure12","xpu_rubbletreasure13","xpu_rubbletreasure14"];
      
      private var TILE_REWARD_NAMES:Array = ["Valleyview Corner","Haunted Acres","Pumpkin Square","Townhall Entrance","Lakeview Edge"];
      
      public var m_appEnvironment:String = null;
      
      private var m_tokensUpdateTimer:Timer = null;
      
      private var FLAG_TROPIC_ESCAPE_FIRST_TRAVEL:String = "PumpkinPartyInnovation_tropic_escape_first_travel";
      
      private var m_welcomeBackPopup:PumpkinPartyInnovationWelcomeBackWindow;
      
      private var m_tileUnlockPopup:PumpkinPartyInnovationTileUnlockwindow;
      
      public const PUMPKIN_PARTY_FTUE_SEEN:String = "PumpkinPartyInnovation_Tutorial";
      
      public const PUMPKIN_PARTY_EA_CONSUMABLE_SEEN:String = "pumkin_party_ea_consumable_seen";
      
      public const PUMPKIN_PARTY_GA_CONSUMABLE_SEEN:String = "pumkin_party_ga_consumable_seen";
      
      public function PumpkinPartyInnovationManager(featureName:String, featureConfig:XML = null)
      {
         super(featureName,featureConfig);
         this.parseTaskObjectsFromConfig(this.QUEST_NAME);
         this.parseRewardsDataFromConfig(this.QUEST_NAME);
         this.parseWeeklyRewardsDataFromConfig(this.QUEST_NAME);
         this.m_resultObject = new Object();
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
      }
      
      public static function getInstance(featureName:String = "PumpkinPartyInnovation") : PumpkinPartyInnovationManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,PumpkinPartyInnovationManager) as PumpkinPartyInnovationManager;
      }
      
      protected function onTransactionAdded(event:TransactionEvent) : void
      {
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("pumpkinparty_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            this.checkForTaskUpdates(event);
         }
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
      
      public function setupPumpkinPartyHud() : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         this.m_pumpkinpartyInnovationHud = new HudBottomPumpkinPartyInnovationButton(HUD_TWENTIES_ASSET,m_featureName);
         Global.hud.setBottomHudPumpkinPartyInnovationButton(this.m_pumpkinpartyInnovationHud as HudBottomPumpkinPartyInnovationButton);
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
                  if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TWENTIES_INNOVATION_TASK_V2) == 2)
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
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TWENTIES_INNOVATION_TASK_V2) == 2)
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
         var inventoryTileCount:int = FeatureOptionsInventoryManager.getInstance().getCount(PUMPKINPARTY_TILE_UNLOCK_COUNT) as int;
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
            inventoryTileCount = FeatureOptionsInventoryManager.getInstance().getCount(PUMPKINPARTY_TILE_UNLOCK_COUNT);
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
         GlobalEventManager.getInstance().addEventListener(this.EVENT_TWENTIES_INNOVATION_TILE_UNLOCK,this.showTileUnlockGrantPopup);
      }
      
      public function deleteEventListener() : void
      {
         GlobalEventManager.getInstance().removeEventListener(this.EVENT_TWENTIES_INNOVATION_TILE_UNLOCK,this.showTileUnlockGrantPopup);
      }
      
      public function showTileUnlockGrantPopup(e:TileUnlockEvent = null) : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         FarmStatsManager.count(m_featureName,"UnlockTile","30",this.consumableCount.toString());
      }
      
      public function showDailyBonusGrantPopup(rewardItem:FarmItem, isWeekly:Boolean = false, quantity:int = 1) : void
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
         FarmStatsManager.count(m_featureName,"feature_ui","dailyBonusPopup");
         UI.displayPopup(new PumpkinPartyInnovationDailyBonusGrantWindow("assets/dialogs/expansion/FV_RewardDialog.swf",featureName,rewardItem,isWeekly,weeklyRewardData,null,"assets/dialogs/pumpkin/RewardDialog.png",quantity),false);
      }
      
      public function ShowLBRewardPopup(gift:Array, rank:Number, leaderboardName:String, score:int) : void
      {
         var reward:XML = null;
         var itemName:String = null;
         var lbGiftIndex:* = this.getLeaderboardWeekIndex(leaderboardName);
         if(this.currentWeekIndex == 0 || lbGiftIndex == -1)
         {
            return;
         }
         var lbconfig:Array = this.getLeaderboardData();
         var weekRewards:XML = lbconfig[lbGiftIndex] as XML;
         for each(reward in weekRewards.children())
         {
            if(rank <= int(reward.@rank))
            {
               itemName = reward.@gift;
               break;
            }
         }
         if(itemName != null)
         {
            UI.displayPopup(new PumpkinPartyInnovationDailyBonusGrantWindow("assets/dialogs/expansion/FV_RewardDialog.swf",featureName,Global.farmGameSettingsManager.getFarmItemByName(itemName),false,null,null,"assets/dialogs/pumpkin/RewardDialog.png",1,true,rank,score),false);
         }
      }
      
      public function showMainUI(showTutorialWithEAPage:Boolean = false) : void
      {
         this.updateEscapeTokensCount();
         if(!m_initialized)
         {
            this.initialize();
         }
         if(this.isFeatureInActivePeriod())
         {
            this.resetActivePopupCount();
            this.m_mainWindow = new PumpkinPartyInnovationMainWindow(m_featureName,this.mainWindowURL,showTutorialWithEAPage);
            UI.displayPopup(this.m_mainWindow);
            this.initializeLeaderboardProgress(true);
         }
         if(!Global.player.getSeenFlag(this.FLAG_TROPIC_CONNECTION_INITIALIZED))
         {
            this.initializeTropicEscapeConnection();
         }
         FarmStatsManager.count("PumpkinPartyInnovation","feature_ui","main_ui","impression");
      }
      
      public function initializeTropicEscapeConnection() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"initializeTropicEscapeConnection",this.onTropicEscapeConnectionInitialized,[m_featureName]));
      }
      
      private function onTropicEscapeConnectionInitialized(result:Object) : void
      {
         var response:Object = null;
         if(result)
         {
            if(result.hasOwnProperty("response") && Boolean(result["response"]))
            {
               response = result["response"];
               if(response != null && Boolean(response["data"]["started"]))
               {
                  Global.player.setSeenFlag(this.FLAG_TROPIC_CONNECTION_INITIALIZED);
               }
            }
         }
      }
      
      public function postNeighbours() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"postNeighbours",this.onPostNeighboursDone,[m_featureName]));
      }
      
      private function onPostNeighboursDone(result:Object) : void
      {
         var response:Object = null;
         if(result)
         {
            if(result.hasOwnProperty("response") && Boolean(result["response"]))
            {
               response = com.adobe.serialization.json.JSON.decode(result["response"]);
               if(response != null && response.hasOwnProperty("data") && Boolean(response["data"]["result"]))
               {
                  Global.player.setSeenFlag("PostFarmvilleNeighboursToTropicEscapePumpkinParty");
               }
            }
         }
      }
      
      public function openBuyWindow(owner:FarmWindow) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         this.m_buyWindow = new PumpkinPartyInnovationBuyWindow(this.buyDialogURL,m_featureName,this.getBucketPackages(),owner,this.mainWindow);
         UI.displayPopup(this.m_buyWindow,false);
         FarmStatsManager.count("PumpkinPartyInnovation","Click","Bundlesofplenty","Buy");
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
      
      public function unlockLandFromBuyWindow() : void
      {
         if(this.m_buyWindow)
         {
            this.m_buyWindow.close();
         }
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
         PumpkinPartyInnovationManager.getInstance().highlightTiles();
         FarmStatsManager.count("PumpkinPartyInnovation","UnlockTile","tile_unlock","click");
      }
      
      public function craftConsumableFromMainWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
         if(this.m_buyWindow)
         {
            this.m_buyWindow.close();
         }
         FarmStatsManager.count("PumpkinPartyInnovation","Craft","Spooky party hat",this.consumableCount.toString());
         var consumableSearchStr:String = "spooky party";
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
      
      public function get rewardLBWindowURL() : String
      {
         return this.m_assetPaths[WINDOW_LBREWARD];
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
            FarmStatsManager.count("Ask","Spooky Party Hat");
         }
      }
      
      public function askForConsumables(event:Event = null) : void
      {
         getFeedData(FEED_NAME).postFeed(this.onAskForConsumables);
      }
      
      public function getTimeRemaining() : Array
      {
         var remainingSecs:int = 0;
         var endTime:Number = FarmGameUtil.synchronizedDateTimeToNumber("11/23/2020");
         var timeLeftMs:Number = endTime - GlobalEngine.serverTime;
         timeLeftMs = timeLeftMs < 0 ? 0 : timeLeftMs;
         var remainingTime:Array = FarmGameUtil.parseTimeLeft(timeLeftMs / 1000);
         if(parseInt(remainingTime[0]) > 0)
         {
            remainingSecs = parseInt(remainingTime[0]) + 1;
            remainingTime[0] = remainingSecs.toString();
         }
         return remainingTime;
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
            questTasks1 = PumpkinPartyInnovationManager.getInstance(m_featureName).getActiveTasks();
            questTasks1[slotIndex].questPoints = this.grantPointsForTask(questTasks1[slotIndex].questPoints);
            taskPt = questTasks1[slotIndex].questPoints;
            taskLBPt = questTasks1[slotIndex].questPoints;
            if(featureObject[this.KEY_DAY_POINTS] + questTasks1[slotIndex].questPoints > this.VAL_THIRD_MILESTONE)
            {
               taskPt = this.VAL_THIRD_MILESTONE - featureObject[this.KEY_DAY_POINTS];
            }
            featureObject[this.KEY_DAY_POINTS] += questTasks1[slotIndex].questPoints;
            featureObject[this.KEY_ORDERBOARD_COUNT] += 1;
            featureObject[this.KEY_ORDER_NO] += 1;
            featureObject[this.WEEKLY_SCORE] += taskLBPt;
            setFeatureData(featureObject);
            this.mainWindow.untintWindow();
            this.mainWindow.enableInput = true;
            if(this.hasActiveDayExpired() == false && this.getUserState() != this.DONE_FOR_THE_DAY)
            {
               this.m_mainWindow.updateTaskDoober(taskPt);
            }
            this.checkAndUpdateUserState();
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipTask",null,[m_featureName,slotIndex]),true);
            this.resetActionCountsForTasks(tasks[slotIndex]);
            if(!(this.getUserState() == this.DONE_FOR_THE_DAY && this.getDayEndMessageShown() == false))
            {
               this.generateAndSaveNewTask(slotIndex);
            }
            fItemName = null;
            if(tasks[slotIndex].action == "completeFeatureCraftingNPC")
            {
               fItemName = "Pumpkin Farm Stable";
            }
            else
            {
               code = tasks[slotIndex].type;
               fItemName = this.getTaskItemName(code);
            }
            if(fItemName == null)
            {
               fItemName = "PumpkinParty Task";
            }
            FarmStatsManager.count("PumpkinPartyInnovation","SkipTask",this.getKingdomText(tasks[slotIndex]),tasks[slotIndex].titleText,featureObject[this.KEY_DAY_POINTS].toString(),questTasks1[slotIndex].questPoints.toString(),tasks[slotIndex].skipCashValue);
            this.m_mainWindow.refreshTaskFrame();
            this.m_mainWindow.updateProgressBar();
            this.updateCurrentAverageKey();
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
         questTasks1 = PumpkinPartyInnovationManager.getInstance(m_featureName).getActiveTasks();
         questTasks1[slotIndex].questPoints = this.grantPointsForTask(questTasks1[slotIndex].questPoints);
         var taskPt:int = questTasks1[slotIndex].questPoints;
         var taskLBPt:int = questTasks1[slotIndex].questPoints;
         if(featureObject[this.KEY_DAY_POINTS] + questTasks1[slotIndex].questPoints > this.VAL_THIRD_MILESTONE)
         {
            taskPt -= this.VAL_THIRD_MILESTONE - featureObject[this.KEY_DAY_POINTS];
         }
         featureObject[this.KEY_DAY_POINTS] += questTasks1[slotIndex].questPoints;
         featureObject[this.KEY_ORDERBOARD_COUNT] += 1;
         featureObject[this.KEY_ORDER_NO] += 1;
         featureObject[this.WEEKLY_SCORE] += taskLBPt;
         setFeatureData(featureObject);
         this.resetActionCountsForTasks(tasks[slotIndex]);
         if(this.hasActiveDayExpired() == false && this.getUserState() != this.DONE_FOR_THE_DAY)
         {
            this.m_mainWindow.updateTaskDoober(taskPt);
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
            fItemName = "Pumpkin Farm Stable";
         }
         else
         {
            code = tasks[slotIndex].type;
            fItemName = this.getTaskItemName(code);
         }
         if(fItemName == null)
         {
            fItemName = "PumpkinParty Task";
         }
         FarmStatsManager.count("PumpkinPartyInnovation","RedeemTask",this.getKingdomText(tasks[slotIndex]),tasks[slotIndex].titleText,featureObject[this.KEY_DAY_POINTS].toString(),questTasks1[slotIndex].questPoints.toString(),tasks[slotIndex].skipCashValue);
         this.generateAndSaveNewTask(slotIndex);
         this.m_mainWindow.refreshTaskFrame();
         this.m_mainWindow.updateProgressBar();
         this.updateCurrentAverageKey();
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
               FarmStatsManager.count("PumpkinPartyInnovation","userstate","Sparse",(this.activeDayIndex + 1).toString(),dayPoints.toString(),this.getActiveWeek(),this.getCurrentAverage());
               FarmStatsManager.count("PumpkinPartyInnovation","Reward","userstate","Sparse",this.getActiveDayReward(this.EASY).friendlyTitle,this.getActiveWeek(),this.activeDayIndex + 1);
            }
            else if(dayPoints >= this.VAL_SECOND_MILESTONE && userState == this.MEDIUM)
            {
               featureObj[this.KEY_USER_STATE] = this.LOCK2;
               this.grantUserRewardforLevel(this.MEDIUM);
               FarmStatsManager.count("PumpkinPartyInnovation","userstate","Abundant",(this.activeDayIndex + 1).toString(),dayPoints.toString(),this.getActiveWeek(),this.getCurrentAverage());
               FarmStatsManager.count("PumpkinPartyInnovation","Reward","userstate","Abundant",this.getActiveDayReward(this.MEDIUM).friendlyTitle,this.getActiveWeek(),this.activeDayIndex + 1);
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
               FarmStatsManager.count("PumpkinPartyInnovation","userstate","Masterful",(this.activeDayIndex + 1).toString(),dayPoints.toString(),this.getActiveWeek(),this.getCurrentAverage());
               FarmStatsManager.count("PumpkinPartyInnovation","Reward","userstate","Masterful",this.getActiveDayReward(this.HARD).friendlyTitle,this.getActiveWeek(),this.activeDayIndex + 1);
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
      
      public function checkAndUpdateWeeklyStatus() : void
      {
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_PUMPKIN))
         {
            this.checkAndUpdateEarlierEADays();
         }
         var curAvg:int = this.getCurrentWeekAverage();
         var featureObj:Object = this.getFeatureData();
         if(curAvg >= this.VAL_WEEK_FIRST_MILESTONE && featureObj[KEY_WEEKLY_REWARD_EASY_GRANTED] == false)
         {
            featureObj[KEY_WEEKLY_REWARD_EASY_GRANTED] = true;
            this.grantWeeklyRewardforLevel(this.EASY);
            setFeatureData(featureObj);
            FarmStatsManager.count("PumpkinPartyInnovation","Reward","Milestone","Sparse",this.getActiveWeekReward(this.EASY).friendlyTitle,this.getActiveWeek(),this.activeDayIndex + 1);
         }
         if(curAvg >= this.VAL_WEEK_SECOND_MILESTONE && featureObj[KEY_WEEKLY_REWARD_MEDIUM_GRANTED] == false)
         {
            featureObj[KEY_WEEKLY_REWARD_MEDIUM_GRANTED] = true;
            this.grantWeeklyRewardforLevel(this.MEDIUM);
            setFeatureData(featureObj);
            FarmStatsManager.count("PumpkinPartyInnovation","Reward","Milestone","Adequate",this.getActiveWeekReward(this.MEDIUM).friendlyTitle,this.getActiveWeek(),this.activeDayIndex + 1);
         }
         if(curAvg >= this.VAL_WEEK_THIRD_MILESTONE && featureObj[KEY_WEEKLY_REWARD_HARD_GRANTED] == false)
         {
            featureObj[KEY_WEEKLY_REWARD_HARD_GRANTED] = true;
            this.grantWeeklyRewardforLevel(this.HARD);
            setFeatureData(featureObj);
            FarmStatsManager.count("PumpkinPartyInnovation","Reward","Milestone","Abundant",this.getActiveWeekReward(this.HARD).friendlyTitle,this.getActiveWeek(),this.activeDayIndex + 1);
            this.updateRewardLevel();
            if(this.isFeatureInActivePeriod())
            {
               this.mainWindow.updateRewardImage();
            }
         }
         this.showWeeklyRewardPopup();
         FarmStatsManager.count("PumpkinPartyInnovation","Milestone",this.getWeeklyRating(),null,null,this.getActiveWeek(),this.getCurrentAverage());
         if(this.isFeatureInActivePeriod())
         {
            this.m_mainWindow.updateWeeklyState();
         }
         else
         {
            this.checkAndUpdateLeaderboardRewards();
         }
      }
      
      public function showWeeklyRewardPopup() : void
      {
         var featureObj:Object = this.getFeatureData();
         var popupShownKeys:Array = [KEY_WEEKLY_REWARD_EASY_POPUP,KEY_WEEKLY_REWARD_MEDIUM_POPUP,KEY_WEEKLY_REWARD_HARD_POPUP];
         var currentWeek:int = int(this.getActiveWeek());
         if(currentWeek == 1)
         {
            featureObj[this.KEY_IS_EA_REWARD_GRANTED] = true;
         }
         for(var i:int = 0; i < 3; i++)
         {
            if(this.hasReceivedRewardForWeek(i) == true && this.hasShownPopupForTheWeek(i) == false)
            {
               featureObj[popupShownKeys[i]] = true;
               this.showDailyBonusGrantPopup(this.getActiveWeekReward(i),true,this.getActiveWeekRewardQuantity(i));
            }
         }
         setFeatureData(featureObj);
      }
      
      private function showRewardLevelUpgradePopup(upgradeLevel:int) : void
      {
         var lastUpgradeLevel:int = 0;
         lastUpgradeLevel = 4;
         var buildingData:Object = {
            "iconUrl":Global.getAssetURL(this.REWARD_ITEM_200[upgradeLevel]),
            "isLastUpgrade":upgradeLevel == lastUpgradeLevel,
            "name":BONUS_NAME_ARRAY[upgradeLevel]
         };
         UI.displayPopup(new PumpkinPartyInnovationRewardUpgradeWindow("assets/dialogs/expansion/FV_RewardDialog.swf",featureName,buildingData,null,"assets/dialogs/pumpkin/RewardDialog.png"),false);
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
         FarmStatsManager.count("PumpkinPartyInnovation","grantBonus","Party House",this.getCurrentLevel(),null,this.getActiveWeek(),this.getCurrentAverage());
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
            FarmStatsManager.count("PumpkinPartyInnovation","sink","Party Masques",this.consumableCount.toString(),consumableNeeded.toString(),this.getActiveWeek());
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
         else if(code == "AllPumpkinAnimals")
         {
            result = "Spooks Town Soiree Animals";
         }
         else if(code == "AllPumpkinTrees")
         {
            result = "Spooks Town Soiree Trees";
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
               fItemName = "Pumpkin Farm Stable";
            }
            else
            {
               code = tasks[slotIndex].type;
               fItemName = this.getTaskItemName(code);
            }
            if(fItemName == null)
            {
               fItemName = "PumpkinParty Task";
            }
            FarmStatsManager.count("PumpkinPartyInnovation","Trash",this.getKingdomText(tasks[slotIndex]),tasks[slotIndex].titleText);
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
            FarmStatsManager.count("PumpkinPartyInnovation","SkipTrashedTask",(this.activeDayIndex + 1).toString(),null,null,null,1);
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
            FarmStatsManager.count("PumpkinPartyInnovation","sinkGold",tasks[slotIndex].type,this.currentDayIndex.toString());
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkGold",null,[m_featureName,slotIndex]),true);
         }
      }
      
      public function sinkBushel(slotIndex:int) : void
      {
         var tasks:Vector.<FarmTask> = this.getActiveTasks();
         CraftingManager.getInstance().deductItemFromCraftingInventory(tasks[slotIndex].type,tasks[slotIndex].total);
         this.postTaskCompletionActions(slotIndex);
         FarmStatsManager.count("PumpkinPartyInnovation","sinkBushel",tasks[slotIndex].type,this.currentDayIndex.toString());
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkBushel",null,[m_featureName,slotIndex]),true);
      }
      
      public function postTaskCompletionActions(completedTaskSlotIndex:int) : void
      {
         var questTasks1:Vector.<FarmTask> = null;
         var featureObject:Object = this.getFeatureData();
         questTasks1 = PumpkinPartyInnovationManager.getInstance(m_featureName).getActiveTasks();
         questTasks1[completedTaskSlotIndex].questPoints = this.grantPointsForTask(questTasks1[completedTaskSlotIndex].questPoints);
         var taskPt:int = questTasks1[completedTaskSlotIndex].questPoints;
         var taskLBPt:int = questTasks1[completedTaskSlotIndex].questPoints;
         if(featureObject[this.KEY_DAY_POINTS] + questTasks1[completedTaskSlotIndex].questPoints > this.VAL_THIRD_MILESTONE)
         {
            taskPt -= this.VAL_THIRD_MILESTONE - featureObject[this.KEY_DAY_POINTS];
         }
         featureObject[this.KEY_DAY_POINTS] += questTasks1[completedTaskSlotIndex].questPoints;
         featureObject[this.KEY_ORDERBOARD_COUNT] += 1;
         featureObject[this.KEY_ORDER_NO] += 1;
         featureObject[this.WEEKLY_SCORE] += taskLBPt;
         setFeatureData(featureObject);
         if(this.hasActiveDayExpired() == false && this.getUserState() != this.DONE_FOR_THE_DAY)
         {
            this.m_mainWindow.updateTaskDoober(taskPt);
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
         this.updateCurrentAverageKey();
         this.m_mainWindow.updateWeeklyTable();
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
            featureData[KEY_LAST_LB_REFRESH_TIMESTAMP] = 0;
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
            featureData[KEY_GA_FEATURE_START] = false;
            featureData[KEY_EA_FEATURE_START] = false;
            featureData[this.KEY_ORDERBOARD_COUNT] = 0;
            featureData[this.KEY_ORDER_NO] = 0;
            featureData[this.KEY_CURRENT_AVERAGE] = 0;
            featureData[KEY_TILE_UNLOCK_COUNT] = 0;
            featureData[this.KEY_ESCAPE_TOKENS_COLLECTED] = 0;
            featureData[this.KEY_ESCAPE_TOKENS_PROGRESS] = 0;
            featureData[this.KEY_ESCAPE_TOKENS_AVAILABLE] = 0;
            featureData[this.KEY_ORDERBOARD_BOOSTS_AVAILABLE] = 0;
            featureData[this.KEY_TE_CONNECTION_INITIALIZED] = 0;
            featureData[this.KEY_TASKS_DONE_WITHOUT_ORDERBOARD_BOOST] = 0;
            featureData[this.KEY_CURRENT_TILE_LEVEL] = 0;
            featureData[this.KEY_TESTING_COUNT] = 0;
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
         orderBoardXml = Global.farmGameSettingsManager.getXML().PumpkinPartyInnovationQuests.PumpkinPartyInnovationQuest.(@name == questName)[0];
         rewardsList = orderBoardXml.PumpkinPartyInnovationRewards.stage;
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
         orderBoardXml = Global.farmGameSettingsManager.getXML().PumpkinPartyInnovationRewardQuests.PumpkinPartyInnovationRewardQuest.(@name == questName)[0];
         rewardsList = orderBoardXml.PumpkinPartyInnovationWeeklyRewards.stage;
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
         this.openFeatureExpiredWindow();
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
      
      public function getRewardsForWeek(weekInd:int = -1) : Vector.<Object>
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
         if(weekInd == -1)
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
         var buildingFarmItem:FarmItem = null;
         var objects:Array = null;
         var currentProgress:int = 0;
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
               fItemName = "Pumpkin Farm Stable";
            }
            else
            {
               code = tasks[i].type;
               fItemName = this.getTaskItemName(code);
            }
            if(fItemName == null)
            {
               fItemName = "PumpkinParty Task";
            }
            if(tasks[i].helperType == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
            {
               progress = CraftingManager.getInstance().getBushelQuantityInInventory(tasks[i].type) - featureData[KEY_SAVED_ACTIVE_TASKS][i][this.KEY_PROGRESS];
               hasUpdatedProgress = true;
               FarmStatsManager.count("PumpkinPartyInnovation","PerformTask",this.getKingdomText(tasks[i]),tasks[i].titleText);
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
                  FarmStatsManager.count("PumpkinPartyInnovation","PerformTask",this.getKingdomText(tasks[i]),tasks[i].titleText);
               }
               else if(tasks[i].action == "expandStorageBuildingToLevelByCode")
               {
                  buildingFarmItem = Global.farmGameSettingsManager.getFarmItemByCode(tasks[i].type);
                  objects = Global.world.getObjectsByName(buildingFarmItem.name);
                  if(objects.length == 1)
                  {
                     currentProgress = (objects[0] as FeatureBuilding).storageLevel;
                     if(currentProgress + progress >= tasks[i].total)
                     {
                        hasCompletedTask = true;
                     }
                  }
               }
            }
         }
         if(hasUpdatedProgress)
         {
            this.saveProgressForPlayer(progressArray);
         }
         if(hasCompletedTask)
         {
            if(this.m_pumpkinpartyInnovationHud)
            {
               this.m_pumpkinpartyInnovationHud.refresh(1);
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
               buildingName = "xpu_elitehorses";
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
      
      public function getWeeklyPoints() : int
      {
         var weeklyPoints:int = 0;
         var featureData:Object = this.getFeatureData();
         if(featureData.hasOwnProperty(this.WEEKLY_SCORE))
         {
            weeklyPoints = int(featureData[this.WEEKLY_SCORE]);
         }
         return weeklyPoints;
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
      
      public function getActiveWeekRewardQuantity(level:int, weekInd:int = 0) : int
      {
         return (this.getRewardsForTheWeek(weekInd)[level] as Object).quantity;
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
         if(Boolean(this.mainWindow) && Boolean(this.mainWindow.m_firstStartSessionMC))
         {
            this.mainWindow.m_firstStartSessionMC.visible = false;
         }
         if(Boolean(this.mainWindow) && Boolean(this.mainWindow.m_overlayMc))
         {
            this.mainWindow.m_overlayMc.visible = false;
         }
         var weekData:Object = this.getCurrentWeek();
         var weekNum:int = int(weekData.count);
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_PUMPKIN) == false)
         {
            weekNum--;
         }
         if(Boolean(this.mainWindow) && Boolean(this.mainWindow.m_currentWeekTfArray) && Boolean(this.mainWindow.m_currentWeekTfArray[weekNum - 1]))
         {
            this.mainWindow.m_currentWeekTfArray[weekNum - 1].visible = true;
         }
         if(Boolean(this.mainWindow) && Boolean(this.mainWindow.m_pointsCountTfArray) && Boolean(this.mainWindow.m_pointsCountTfArray[weekNum - 1]))
         {
            this.mainWindow.m_pointsCountTfArray[weekNum - 1].visible = true;
         }
         var featureData:Object = this.getFeatureData();
         if(this.hasActiveDayExpired() == true || featureData[this.KEY_USER_STATE] == this.NOT_INITIALIZED)
         {
            if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_PUMPKIN) == true && featureData.hasOwnProperty(KEY_EA_FEATURE_START) && featureData[KEY_EA_FEATURE_START] == false && !Global.player.getSeenFlag(this.PUMPKIN_PARTY_EA_CONSUMABLE_SEEN))
            {
               Global.player.setSeenFlag(this.PUMPKIN_PARTY_EA_CONSUMABLE_SEEN);
               featureData[KEY_EA_FEATURE_START] = true;
               FeatureOptionsInventoryManager.getInstance().addCount(this.ConsumableCode,50);
            }
            else if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_PUMPKIN) == false)
            {
               if(featureData.hasOwnProperty(KEY_GA_FEATURE_START) && featureData[KEY_GA_FEATURE_START] == false && !Global.player.getSeenFlag(this.PUMPKIN_PARTY_GA_CONSUMABLE_SEEN))
               {
                  Global.player.setSeenFlag(this.PUMPKIN_PARTY_GA_CONSUMABLE_SEEN);
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
            if(featureData.hasOwnProperty(KEY_CURRENT_WEEK) && featureData[KEY_CURRENT_WEEK] == 0)
            {
               weekObjFirst = this.getCurrentWeek();
               curWeekFirst = int(weekObjFirst.count);
               featureData[KEY_CURRENT_WEEK] = curWeekFirst.toString();
               this.checkAndUpdateEAWeekRewards();
               featureData[KEY_WEEKLY_REWARD_EASY_GRANTED] = false;
               featureData[KEY_WEEKLY_REWARD_MEDIUM_GRANTED] = false;
               featureData[KEY_WEEKLY_REWARD_HARD_GRANTED] = false;
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
            }
            featureData[this.KEY_ACTIVE_DAY_TIMESTAMP] = FarmGameUtil.getMidnightTimestamp() / 1000;
            this.mainWindow.updateActiveDayIndex();
            this.mainWindow.updateDayBonus();
            if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_PUMPKIN))
            {
               this.checkAndUpdateEarlierEADays();
            }
            if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_PUMPKIN) && WorldSeasonsManager.getInstance().isEAWeek(WorldsConstants.WORLD_ID_PUMPKIN))
            {
               featureData[this.KEY_DAY_POINTS] = this.VAL_FIRST_MILESTONE;
               featureData[this.KEY_USER_STATE] = this.MEDIUM;
            }
            else
            {
               featureData[this.KEY_DAY_POINTS] = 0;
               featureData[this.KEY_USER_STATE] = this.EASY;
            }
            setFeatureData(featureData);
            if(this.activeDayIndex >= 35)
            {
               featureData[this.KEY_FEATURE_ENDED] = 1;
               setFeatureData(featureData);
               if(this.m_mainWindow)
               {
                  this.m_mainWindow.close();
               }
               this.openFeatureExpiredWindow();
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
            this.mainWindow.showTropicRewardPopup(true);
            FarmStatsManager.count("PumpkinPartyInnovation","startNewDay",this.consumableCount.toString(),(this.activeDayIndex + 1).toString(),this.getCurrentLevel(),this.getActiveWeek().toString(),this.getCurrentAverage());
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startNewDay",null,[m_featureName]),true);
         }
      }
      
      public function checkAndUpdateEarlierEADays() : void
      {
         var featureData:Object = this.getFeatureData();
         var daysToCheck:int = this.currentDayIndex < 7 ? this.currentDayIndex : 7;
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
      
      public function getWeeklyRating() : String
      {
         var result:String = null;
         var featureData:Object = this.getFeatureData();
         if(featureData[KEY_WEEKLY_REWARD_HARD_GRANTED] == true)
         {
            result = "LEGEND";
         }
         else if(featureData[KEY_WEEKLY_REWARD_MEDIUM_GRANTED] == true)
         {
            result = "AWESOME";
         }
         else if(featureData[KEY_WEEKLY_REWARD_EASY_GRANTED] == true)
         {
            result = "OKAY";
         }
         else
         {
            result = "BORING";
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
      
      public function getTimeStringLeftInWeek() : String
      {
         var result:Number = this.getTimeLeftInWeek();
         if(result < 0)
         {
            result = 0;
         }
         var timeleft:String = "expired";
         var timeLeftArray:Array = FarmGameUtil.parseTimeLeft(result);
         if(Boolean(timeLeftArray) && timeLeftArray.length > 3)
         {
            if(int(timeLeftArray[0]) > 0)
            {
               timeleft = String(timeLeftArray[0]) + " days left";
            }
            else if(int(timeLeftArray[1]) > 0)
            {
               timeleft = String(timeLeftArray[1]) + " hours left";
            }
            else if(int(timeLeftArray[2]) > 0)
            {
               timeleft = String(timeLeftArray[2]) + " minutes left";
            }
            else
            {
               timeleft = String(timeLeftArray[3]) + " seconds left";
            }
         }
         return timeleft;
      }
      
      public function getTimeSinceLastLBRefresh() : String
      {
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var lastRefresh:Number = this.getFeatureOptionsKey(KEY_LAST_LB_REFRESH_TIMESTAMP) as Object as Number;
         if(lastRefresh == 0)
         {
            return "";
         }
         var result:Number = currenttime - lastRefresh;
         var timeleft:String = "expired";
         var timeLeftArray:Array = FarmGameUtil.parseTimeLeft(result);
         if(Boolean(timeLeftArray) && timeLeftArray.length > 3)
         {
            if(int(timeLeftArray[0]) > 0)
            {
               timeleft = String(timeLeftArray[0]) + " day";
            }
            else if(int(timeLeftArray[1]) > 0)
            {
               timeleft = String(timeLeftArray[1]) + " hr";
            }
            else if(int(timeLeftArray[2]) > 0)
            {
               timeleft = String(timeLeftArray[2]) + " min";
            }
            else
            {
               timeleft = "Less than a min";
            }
         }
         return timeleft;
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
                  msg = "Collect more Spooky Party Hat to unlock the next milestone.";
               }
               else
               {
                  msg = "Use Spooky Party Hat to unlock the next level.";
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
      
      public function getAverageForWeek(weekIndex:int) : int
      {
         if(weekIndex < 0)
         {
            return 0;
         }
         var startDayIndex:int = weekIndex * 7;
         var endDayIndex:int = (weekIndex + 1) * 7;
         var featureData:Object = this.getFeatureData();
         var totalPoints:int = 0;
         var dayCount:int = 0;
         var index:int = startDayIndex;
         while(index < endDayIndex && index < this.currentDayIndex)
         {
            dayCount++;
            if(featureData[this.KEY_DAILY_PROGRESS_POINTS].hasOwnProperty(index))
            {
               totalPoints += featureData[this.KEY_DAILY_PROGRESS_POINTS][index];
            }
            index++;
         }
         if(featureData[this.KEY_WEEKLY_AVERAGE_POINTS][weekIndex] != totalPoints / dayCount)
         {
            featureData[this.KEY_WEEKLY_AVERAGE_POINTS][weekIndex] = totalPoints / dayCount;
         }
         setFeatureData(featureData);
         return totalPoints / dayCount;
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
      
      public function getCurrentWeekAverage() : int
      {
         var featureData:Object = this.getFeatureData();
         var activeWeek:int = 0;
         if(featureData.hasOwnProperty(KEY_CURRENT_WEEK))
         {
            activeWeek = int(featureData[KEY_CURRENT_WEEK]) - 1;
         }
         return this.getAverageForWeek(activeWeek);
      }
      
      public function updateCurrentAverageKey() : void
      {
         var featureConfig:Object = this.getFeatureData();
         featureConfig[this.KEY_CURRENT_AVERAGE] = this.hasActiveWeekExpired() ? this.getCurrentWeekAverage() : this.getCurrentAverage();
         setFeatureData(featureConfig);
      }
      
      public function openRewardViewWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         this.m_rewardWindow = new PumpkinPartyInnovationRewardWindow(m_featureName,this.rewardWindowURL);
         UI.displayPopup(this.m_rewardWindow,false);
      }
      
      public function openLBRewardViewWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         this.m_rewardLBWindow = new PumpkinPartyInnovationLBRewardWindow(m_featureName,this.rewardLBWindowURL);
         UI.displayPopup(this.m_rewardLBWindow,false);
      }
      
      public function get mainWindow() : PumpkinPartyInnovationMainWindow
      {
         return this.m_mainWindow;
      }
      
      public function openFeatureExpiredWindow() : void
      {
         this.m_finalRewardWindow = new PumpkinPartyInnovationFinalRewardWindow(m_featureName,this.featureEndWindowURL);
         UI.displayPopup(this.m_finalRewardWindow,false);
         FarmStatsManager.count(m_featureName,"feature_ui","final_reward_ui","impression");
      }
      
      public function get activeDayIndex() : int
      {
         var dayIndex:int = 0;
         var featureData:Object = this.getFeatureData();
         var activeDayTS:Number = featureData[this.KEY_ACTIVE_DAY_TIMESTAMP] as Number;
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("10/19/2020") / FarmGameUtil.NUM_MSECS_IN_SECOND;
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
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("10/19/2020");
         dayIndex = (GlobalEngine.serverTime - featureStartDayTS) / FarmGameUtil.NUM_MSECS_IN_DAY;
         if(dayIndex < 0)
         {
            dayIndex = 0;
         }
         return dayIndex;
      }
      
      public function get currentWeekIndex() : int
      {
         var weekIndex:int = 0;
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("10/19/2020");
         weekIndex = (GlobalEngine.serverTime - featureStartDayTS) / FarmGameUtil.NUM_MSECS_IN_DAY / FarmGameUtil.NUM_DAYS_IN_WEEK;
         if(weekIndex < 0)
         {
            weekIndex = 0;
         }
         return weekIndex;
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
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("pumpkinparty_innovation_bonus_enabled");
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
               }
               Global.player.addGift(harvestRewardName,"",count);
               bonusName = BONUS_NAME_ARRAY[this.getRewardLevel()];
               UI.displayPopup(new PumpkinPartyInnovationPostBonusHarvestWindow("assets/dialogs/expansion/FV_RewardDialog.swf",featureName,bonusName,harvestFarmItem,null,"assets/dialogs/pumpkin/RewardDialog.png",count));
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,this.SERVICE_FUNC_HARVEST_BONUS,null,[m_featureName]),true);
               FarmStatsManager.count("PumpkinPartyInnovation","Reward","Party House",this.getCurrentLevel(),harvestFarmItem.friendlyTitle,this.getActiveWeek(),this.activeDayIndex + 1);
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
      
      public function set mainWindow(mainWindowInstance:PumpkinPartyInnovationMainWindow) : void
      {
         this.m_mainWindow = mainWindowInstance;
      }
      
      public function playForLeaderboard() : void
      {
         var i:int = 0;
         var featureData:Object = this.getFeatureData();
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
      
      public function refreshLeaderboard() : void
      {
         this.initializeLeaderboardProgress(true);
      }
      
      public function getCurrentLeaderboard() : Object
      {
         var startDate:Number = NaN;
         var endDate:Number = NaN;
         var leaderboardXML:XML = null;
         var leaderboardData:Object = this.getLeaderboardData();
         var result:Object = null;
         var weekCount:int = 0;
         for each(leaderboardXML in leaderboardData)
         {
            weekCount++;
            if(FarmGameUtil.checkDateGate(leaderboardXML.@start.toString(),leaderboardXML.@end.toString()))
            {
               result = new Object();
               result.name = leaderboardXML.@name.toString();
               result.start = leaderboardXML.@start.toString();
               result.end = leaderboardXML.@end.toString();
               result.count = weekCount;
               break;
            }
         }
         return result;
      }
      
      public function getLeaderboardData() : Array
      {
         return this.m_staticData.leaderboardConfigData;
      }
      
      public function getLeaderboardWeekIndex(leaderboardName:String) : int
      {
         switch(leaderboardName)
         {
            case "pumpkinpartyInnovationWeek1":
               return 0;
            case "pumpkinpartyInnovationWeek2":
               return 1;
            case "pumpkinpartyInnovationWeek3":
               return 2;
            case "pumpkinpartyInnovationWeek4":
               return 3;
            case "pumpkinpartyInnovationWeek5":
               return 4;
            default:
               return -1;
         }
      }
      
      public function initializeLeaderboardProgress(isSync:Boolean = false) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getLeaderboardEntries",this.getLeaderboardEntries,[m_featureName,isSync]));
      }
      
      public function checkAndUpdateLeaderboardRewards() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getLeaderboardEntries",this.grantLeaderboardRewards,[m_featureName,false]));
      }
      
      public function checkAndUpdateEAWeekRewards() : void
      {
         var featureData:Object = null;
         var average:* = undefined;
         var rewards:Vector.<Object> = null;
         var runesFarmItem:FarmItem = null;
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_PUMPKIN) && !WorldSeasonsManager.getInstance().isEAWeek(WorldsConstants.WORLD_ID_PUMPKIN))
         {
            this.checkAndUpdateEarlierEADays();
            featureData = this.getFeatureData();
            if(!featureData.hasOwnProperty(this.KEY_IS_EA_REWARD_GRANTED))
            {
               featureData[this.KEY_IS_EA_REWARD_GRANTED] = true;
               average = this.getAverageForWeek(0);
               rewards = this.getRewardsForWeek(0);
               if(average >= this.VAL_WEEK_FIRST_MILESTONE)
               {
                  featureData[KEY_WEEKLY_REWARD_EASY_GRANTED] = true;
                  UserRewardUtil.grantUserReward(rewards[this.EASY]);
                  runesFarmItem = Global.farmGameSettingsManager.getFarmItemByCode((rewards[this.EASY] as Object).value);
                  this.showDailyBonusGrantPopup(runesFarmItem,true,(rewards[this.EASY] as Object).quantity);
               }
               if(average >= this.VAL_WEEK_SECOND_MILESTONE)
               {
                  featureData[KEY_WEEKLY_REWARD_MEDIUM_GRANTED] = true;
                  UserRewardUtil.grantUserReward(rewards[this.MEDIUM]);
                  runesFarmItem = Global.farmGameSettingsManager.getFarmItemByCode((rewards[this.MEDIUM] as Object).value);
                  this.showDailyBonusGrantPopup(runesFarmItem,true,(rewards[this.MEDIUM] as Object).quantity);
               }
               if(average >= this.VAL_WEEK_THIRD_MILESTONE)
               {
                  featureData[KEY_WEEKLY_REWARD_HARD_GRANTED] = true;
                  UserRewardUtil.grantUserReward(rewards[this.HARD]);
                  runesFarmItem = Global.farmGameSettingsManager.getFarmItemByCode((rewards[this.HARD] as Object).value);
                  this.showDailyBonusGrantPopup(runesFarmItem,true,(rewards[this.HARD] as Object).quantity);
                  this.updateRewardLevel();
               }
               setFeatureData(featureData);
            }
         }
      }
      
      public function grantLeaderboardRewards(result:Object = null) : void
      {
         var collectionData:Object = null;
         var giftKey:String = null;
         var gifts:Array = null;
         var giftName:String = null;
         var weeklyLeaderboardData:Object = null;
         var score:int = 0;
         if(result != null)
         {
            collectionData = this.getFeatureData();
            if(Boolean(result["gift"]) && Boolean(result["giftLeaderboardName"]))
            {
               giftKey = m_featureName + "_" + result["giftLeaderboardName"] + "_awarded";
               gifts = new Array();
               for each(giftName in result["gift"])
               {
                  Global.player.addGift(giftName);
                  gifts.push(giftName);
               }
               weeklyLeaderboardData = this.getCurrentLeaderboard();
               if(weeklyLeaderboardData)
               {
                  collectionData[KEY_CURRENT_LEADERBOARD] = weeklyLeaderboardData.name;
               }
               collectionData[KEY_SAVED_LEADERBOARD_RESULT] = result["userData"];
               collectionData[giftKey] = true;
               collectionData[this.WEEKLY_SCORE] = 0;
               score = 0;
               if(result["score"])
               {
                  score = int(result["score"]);
               }
               this.ShowLBRewardPopup(result["gift"],result["giftLeaderboardRank"],result["giftLeaderboardName"],score);
            }
            if(result["userData"])
            {
               collectionData[KEY_SAVED_LEADERBOARD_RESULT] = result["userData"];
               collectionData[this.WEEKLY_SCORE] = result["userData"]["value"];
            }
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,FEATURE_OPTIONS_KEY,collectionData);
         }
      }
      
      public function getLeaderboardEntries(result:Object = null) : void
      {
         var collectionData:Object = null;
         var giftKey:String = null;
         var gifts:Array = null;
         var giftName:String = null;
         var weeklyLeaderboardData:Object = null;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         this.saveFeatureOptionsKey(KEY_LAST_LB_REFRESH_TIMESTAMP,currenttime);
         if(result != null)
         {
            this.m_zid = result["zid"];
            collectionData = this.getFeatureData();
            if(Boolean(result["gift"]) && Boolean(result["giftLeaderboardName"]))
            {
               giftKey = m_featureName + "_" + result["giftLeaderboardName"] + "_awarded";
               gifts = new Array();
               for each(giftName in result["gift"])
               {
                  Global.player.addGift(giftName);
                  gifts.push(giftName);
               }
               weeklyLeaderboardData = this.getCurrentLeaderboard();
               if(weeklyLeaderboardData)
               {
                  collectionData[KEY_CURRENT_LEADERBOARD] = weeklyLeaderboardData.name;
               }
               collectionData[KEY_SAVED_LEADERBOARD_RESULT] = result["userData"];
               collectionData[giftKey] = true;
               collectionData[this.WEEKLY_SCORE] = 0;
            }
            if(this.mainWindow)
            {
               if(result["globalLeaderboardData"])
               {
                  this.mainWindow.updateLeaderboardFrame(true);
               }
               else
               {
                  this.mainWindow.updateLeaderboardFrame(false);
               }
               this.mainWindow.populateLeaderboard(result);
            }
            if(result["userData"])
            {
               collectionData[KEY_SAVED_LEADERBOARD_RESULT] = result["userData"];
               collectionData[this.WEEKLY_SCORE] = result["userData"]["value"];
            }
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,FEATURE_OPTIONS_KEY,collectionData);
         }
         else if(this.mainWindow)
         {
            this.mainWindow.updateLeaderboardFrame(false);
         }
      }
      
      public function getUserZid() : String
      {
         return this.m_zid;
      }
      
      public function isBonusHarvestExpired() : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("06/02/2019") / FarmGameUtil.NUM_MSECS_IN_SECOND;
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
         var name:String = "PumpkinPartyInnovationMapTrigger";
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
      
      public function activateOrderboardBoost() : void
      {
         var escapeTokensAvailable:int = this.getEscapeTokensAvailable();
         var orderboardBoostsAvailable:int = this.getOrderboardBoostsAvailable();
         if(escapeTokensAvailable >= this.getEscapeTokensRequiredForABoost())
         {
            escapeTokensAvailable -= this.getEscapeTokensRequiredForABoost();
            orderboardBoostsAvailable += this.getOrderboardBoostsAvailableinABoost();
            this.saveFeatureOptionsKey(this.KEY_ESCAPE_TOKENS_AVAILABLE,escapeTokensAvailable);
            this.saveFeatureOptionsKey(this.KEY_ORDERBOARD_BOOSTS_AVAILABLE,orderboardBoostsAvailable);
            this.saveFeatureOptionsKey(this.KEY_TASKS_DONE_WITHOUT_ORDERBOARD_BOOST,0);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"activateOrderboardBoost",null,[m_featureName]));
            if(this.mainWindow)
            {
               this.mainWindow.refreshBoostComponents();
               if(!Global.player.getSeenFlag(this.PUMPKIN_PARTY_FLAG_BOOST_POPUP_SEEN))
               {
                  Global.player.setSeenFlag(this.PUMPKIN_PARTY_FLAG_BOOST_POPUP_SEEN);
                  this.mainWindow.closeBoostEndedPopup();
                  this.mainWindow.showBoostActivatedPopup();
               }
               this.mainWindow.refreshTaskFrame();
            }
            StatsManager.count(m_featureName,"mainui","ActivateBoost","Click");
         }
      }
      
      public function getEscapeTokensAvailable() : int
      {
         return int(this.getFeatureOptionsKey(this.KEY_ESCAPE_TOKENS_AVAILABLE));
      }
      
      public function getOrderboardBoostsAvailable() : int
      {
         return int(this.getFeatureOptionsKey(this.KEY_ORDERBOARD_BOOSTS_AVAILABLE));
      }
      
      public function getEscapeTokensRequiredForABoost() : int
      {
         return 3;
      }
      
      public function getOrderboardBoostsAvailableinABoost() : int
      {
         return 5;
      }
      
      public function isOrderboardBoostAvailable() : Boolean
      {
         var boostsAvailable:int = int(this.getFeatureOptionsKey(this.KEY_ORDERBOARD_BOOSTS_AVAILABLE));
         return boostsAvailable > 0;
      }
      
      public function getTasksDoneWithoutOrderboardBoost() : int
      {
         return int(this.getFeatureOptionsKey(this.KEY_TASKS_DONE_WITHOUT_ORDERBOARD_BOOST));
      }
      
      public function updateTaskBoostPopupTime() : void
      {
         Global.player.setFeatureLastShown(this.PUMPKIN_PARTY_TASK_BOOST_CALLOUT,FarmGameUtil.getMidnightTimestamp() / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"updateTaskBoostPopupTime",null,[m_featureName]));
      }
      
      public function getTimeLeftToShowTaskBoostCallout() : Number
      {
         var timeSinceLastFeed:Number = FarmGameUtil.getMidnightTimestamp() / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(this.PUMPKIN_PARTY_TASK_BOOST_CALLOUT);
         return this.DEFAULT_THROTTLE_TIME - timeSinceLastFeed;
      }
      
      public function unlockCurrentTile() : void
      {
         this.saveFeatureOptionsKey(this.KEY_CURRENT_TILE_LEVEL,int(this.getFeatureOptionsKey(this.KEY_CURRENT_TILE_LEVEL) + 1));
         if(this.mainWindow)
         {
            this.mainWindow.refreshTERewardPane();
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"unlockCurrentTile",null,[m_featureName]));
      }
      
      public function updateEscapeTokensCount() : void
      {
         if(!this.m_tokensUpdateInProgress)
         {
            this.m_tokensUpdateInProgress = true;
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"updateEscapeTokensCount",this.onUpdateEscapeTokensCount,[m_featureName]));
         }
      }
      
      private function onUpdateEscapeTokensCount(result:Object) : void
      {
         if(Boolean(result) && Boolean(result.success))
         {
            if(result.hasOwnProperty(this.KEY_ESCAPE_TOKENS_COLLECTED))
            {
               this.saveFeatureOptionsKey(this.KEY_ESCAPE_TOKENS_COLLECTED,result[this.KEY_ESCAPE_TOKENS_COLLECTED]);
            }
            if(result.hasOwnProperty(this.KEY_ESCAPE_TOKENS_AVAILABLE))
            {
               this.saveFeatureOptionsKey(this.KEY_ESCAPE_TOKENS_AVAILABLE,result[this.KEY_ESCAPE_TOKENS_AVAILABLE]);
            }
            if(result.hasOwnProperty(this.KEY_ESCAPE_TOKENS_PROGRESS))
            {
               this.saveFeatureOptionsKey(this.KEY_ESCAPE_TOKENS_PROGRESS,result[this.KEY_ESCAPE_TOKENS_PROGRESS]);
            }
            if(result.hasOwnProperty(this.KEY_ESCAPE_TOKENS_PROGRESS) && result[this.KEY_ESCAPE_TOKENS_PROGRESS] > 0 || this.isTileUnlockRequirementMet())
            {
               this.updateEscapeTokensProgress();
               if(this.mainWindow)
               {
                  if(result[this.KEY_ESCAPE_TOKENS_PROGRESS] > 0)
                  {
                     this.mainWindow.showWelcomeBackPopup(result[this.KEY_ESCAPE_TOKENS_PROGRESS]);
                  }
                  this.mainWindow.refreshBoostComponents();
               }
               else if(Global.worldManager.currentWorldType == "pumpkin" && result[this.KEY_ESCAPE_TOKENS_PROGRESS] > 0)
               {
                  this.showWelcomeBackPopup(result[this.KEY_ESCAPE_TOKENS_PROGRESS]);
               }
               this.trackEscapeTokensProgress(result[this.KEY_ESCAPE_TOKENS_PROGRESS]);
            }
            else
            {
               this.m_tokensUpdateInProgress = false;
            }
         }
         else
         {
            this.m_tokensUpdateInProgress = false;
         }
      }
      
      private function trackEscapeTokensProgress(tokensEarned:int) : void
      {
         var tokensAvailable:int = this.getEscapeTokensAvailable();
         var tokensCollected:int = this.getEscapeTokensCollected();
         StatsManager.count(m_featureName,"TokensEarned_Dialog",String(tokensEarned),String(tokensAvailable),String(tokensCollected));
      }
      
      public function getEscapeTokensCollected() : int
      {
         return int(this.getFeatureOptionsKey(this.KEY_ESCAPE_TOKENS_COLLECTED));
      }
      
      public function isTileUnlockRequirementMet() : Boolean
      {
         var escapeTokensRequiredForNextTile:int = this.getEscapeTokensRequiredForNextTile();
         var escapeTokensCollected:int = this.getEscapeTokensCollected();
         return escapeTokensCollected >= escapeTokensRequiredForNextTile;
      }
      
      public function getEscapeTokensRequiredForNextTile() : int
      {
         var tileLevel:int = int(this.getFeatureOptionsKey(this.KEY_CURRENT_TILE_LEVEL));
         return this.TOKENS_REQUIRED_FOR_UNLOCK[tileLevel];
      }
      
      public function updateEscapeTokensProgress() : void
      {
         var tokensProgress:int = int(this.getFeatureOptionsKey(this.KEY_ESCAPE_TOKENS_PROGRESS));
         if(tokensProgress > 0 || this.isTileUnlockRequirementMet())
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"updateEscapeTokensProgress",this.onUpdateEscapeTokensProgress,[m_featureName,Global.player.uid]));
         }
         else
         {
            this.m_tokensUpdateInProgress = false;
         }
      }
      
      private function onUpdateEscapeTokensProgress(result:Object) : void
      {
         if(Boolean(result) && Boolean(result.success))
         {
            this.saveFeatureOptionsKey(this.KEY_ESCAPE_TOKENS_PROGRESS,0);
            if(Boolean(result["tileUnlocked"]) && Boolean(this.isTileUnlockRequirementMet()) && !this.isCurrentTileUnlocked())
            {
               if(this.welcomeBackPopup)
               {
                  this.welcomeBackPopup.close();
               }
               if(this.mainWindow)
               {
                  this.mainWindow.closeWelcomeBackPopup();
               }
               if(Global.worldManager.currentWorldType == "pumpkin")
               {
                  this.showTileUnlockPopup();
               }
            }
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"resetEscapeTokensProgress",this.onEscapeTokensProgressReset,[m_featureName]));
         }
         else
         {
            this.m_tokensUpdateInProgress = false;
         }
      }
      
      private function isCurrentTileUnlocked() : Boolean
      {
         var placedtile:Array = Global.world.getObjectsByName(this.getCurrentTileName());
         if(placedtile.length > 0)
         {
            return false;
         }
         return true;
      }
      
      public function getCurrentTileName() : String
      {
         return this.TILE_REWARDS[this.getCurrentTileLevel()];
      }
      
      public function getCurrentTileLevel() : int
      {
         return int(this.getFeatureOptionsKey(this.KEY_CURRENT_TILE_LEVEL));
      }
      
      public function get welcomeBackPopup() : PumpkinPartyInnovationWelcomeBackWindow
      {
         return this.m_welcomeBackPopup;
      }
      
      public function showTileUnlockPopup() : void
      {
         this.m_tileUnlockPopup = new PumpkinPartyInnovationTileUnlockwindow(m_featureName,"assets/dialogs/FV_OctoberInnovation_2020/FV_LandReward_PumpkinPartyInnovation.swf",this.getEscapeTokensCollected(),this.getCurrentTileName(),this.getCurrentTileFriendlyName());
         UI.displayPopup(this.m_tileUnlockPopup,false);
      }
      
      public function highlightTile(tileName:String) : void
      {
         ItemFinderManager.getInstance().highlightWorldItems(tileName);
      }
      
      public function showWelcomeBackPopup(progress:int) : void
      {
         this.m_welcomeBackPopup = new PumpkinPartyInnovationWelcomeBackWindow(m_featureName,"assets/dialogs/FV_OctoberInnovation_2020/FV_WelcomeBack_Popup_PumpkinPartyInnovation.swf",progress);
         UI.displayPopup(this.m_welcomeBackPopup,false);
      }
      
      public function getCurrentTileFriendlyName() : String
      {
         return this.TILE_REWARD_NAMES[this.getCurrentTileLevel()];
      }
      
      private function onEscapeTokensProgressReset(result:Object) : void
      {
         this.m_tokensUpdateInProgress = false;
      }
      
      public function fetchAppEnvironment() : void
      {
         if(this.m_appEnvironment == null)
         {
            this.m_appEnvironment = "zprod";
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getEnvironment",this.onGetEnviroment,[m_featureName]),true);
         }
      }
      
      private function onGetEnviroment(result:Object) : void
      {
         if(Boolean(result) && Boolean(result.success))
         {
            if(result.hasOwnProperty("environment"))
            {
               this.m_appEnvironment = result["environment"];
            }
         }
      }
      
      public function getTropicEscapeRedirectUrl() : String
      {
         var zprodUrl:String = "https://apps.facebook.com/tropic_escape";
         if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_TROPIC_ESCAPE_LINK) && Boolean(Global.flashHotParams[ZRUNTIME_TROPIC_ESCAPE_LINK]))
         {
            zprodUrl = Global.flashHotParams[ZRUNTIME_TROPIC_ESCAPE_LINK];
         }
         var redirectUrl:String = zprodUrl;
         if(this.m_appEnvironment != null && this.m_appEnvironment != "zprod")
         {
            redirectUrl = "https://apps.facebook.com/tropic_escape_stage";
            if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_TROPIC_ESCAPE_STAGE_LINK) && Boolean(Global.flashHotParams[ZRUNTIME_TROPIC_ESCAPE_STAGE_LINK]))
            {
               redirectUrl = Global.flashHotParams[ZRUNTIME_TROPIC_ESCAPE_STAGE_LINK];
            }
         }
         return redirectUrl;
      }
      
      private function get tokensUpdateDelay() : Number
      {
         var tokensUpdateDelay:Number = 600000;
         if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_TROPIC_ESCAPE_TOKENS_UPDATE_DELAY) && Boolean(Global.flashHotParams[ZRUNTIME_TROPIC_ESCAPE_TOKENS_UPDATE_DELAY]))
         {
            tokensUpdateDelay = Number(Global.flashHotParams[ZRUNTIME_TROPIC_ESCAPE_TOKENS_UPDATE_DELAY]);
         }
         return tokensUpdateDelay;
      }
      
      private function get tokensUpdateRepeatCount() : int
      {
         var tokensUpdateRepeatCount:int = 1;
         if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_TROPIC_ESCAPE_TOKENS_UPDATE_REPEAT_COUNT) && Boolean(Global.flashHotParams[ZRUNTIME_TROPIC_ESCAPE_TOKENS_UPDATE_REPEAT_COUNT]))
         {
            tokensUpdateRepeatCount = int(Global.flashHotParams[ZRUNTIME_TROPIC_ESCAPE_TOKENS_UPDATE_REPEAT_COUNT]);
         }
         return tokensUpdateRepeatCount;
      }
      
      private function initializeTokensUpdateTimer() : void
      {
         if(!this.m_tokensUpdateTimer)
         {
            this.m_tokensUpdateTimer = new Timer(this.tokensUpdateDelay,this.tokensUpdateRepeatCount);
            this.m_tokensUpdateTimer.addEventListener(TimerEvent.TIMER,this.onTokensUpdateTimerEvent);
            this.m_tokensUpdateTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTokensUpdateTimerCompleteEvent);
         }
      }
      
      private function startEscapeTokensUpdates() : void
      {
         this.initializeTokensUpdateTimer();
         this.resetTokensUpdateTimer();
         this.startTokensUpdateTimer();
      }
      
      private function resetTokensUpdateTimer() : void
      {
         if(this.m_tokensUpdateTimer)
         {
            this.m_tokensUpdateTimer.reset();
         }
      }
      
      private function startTokensUpdateTimer() : void
      {
         if(this.m_tokensUpdateTimer)
         {
            this.m_tokensUpdateTimer.start();
         }
      }
      
      public function travelToTropicEscape() : void
      {
         var redirectUrl:String = this.getTropicEscapeRedirectUrl();
         if(!Global.player.getSeenFlag(this.FLAG_TROPIC_ESCAPE_FIRST_TRAVEL))
         {
            Global.player.setSeenFlag(this.FLAG_TROPIC_ESCAPE_FIRST_TRAVEL);
            redirectUrl += "?miscId=" + String(Global.player.uid);
         }
         navigateToURL(new URLRequest(redirectUrl),"_blank");
         this.startEscapeTokensUpdates();
      }
      
      private function onTokensUpdateTimerEvent(event:TimerEvent) : void
      {
         this.updateEscapeTokensCount();
      }
      
      private function onTokensUpdateTimerCompleteEvent(event:TimerEvent) : void
      {
      }
      
      public function grantPointsForTask(pointsForTask:int) : int
      {
         if(this.isOrderboardBoostAvailable())
         {
            pointsForTask *= 2;
            this.consumeOrderboardBoost();
         }
         else
         {
            this.saveFeatureOptionsKey(this.KEY_TASKS_DONE_WITHOUT_ORDERBOARD_BOOST,int(this.getFeatureOptionsKey(this.KEY_TASKS_DONE_WITHOUT_ORDERBOARD_BOOST)) + 1);
         }
         return pointsForTask;
      }
      
      private function consumeOrderboardBoost() : void
      {
         this.saveFeatureOptionsKey(this.KEY_ORDERBOARD_BOOSTS_AVAILABLE,int(this.getFeatureOptionsKey(this.KEY_ORDERBOARD_BOOSTS_AVAILABLE)) - 1);
      }
      
      public function resetTasksWithoutBoostCount() : void
      {
         this.saveFeatureOptionsKey(this.KEY_TASKS_DONE_WITHOUT_ORDERBOARD_BOOST,0);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"resetTasksWithoutBoostCount",null,[m_featureName]));
      }
      
      public function get tileRewards() : Array
      {
         return this.TILE_REWARDS;
      }
      
      public function showTileRewardsWindow() : void
      {
         UI.displayPopup(new PumpkinPartyInnovationTileRewardsWindow(m_featureName,"assets/dialogs/FV_OctoberInnovation_2020/FV_TilesInfo_PumpkinPartyInnovation.swf"),false);
      }
      
      public function getEscapeTokenProgress() : int
      {
         return int(this.getFeatureOptionsKey(this.KEY_ESCAPE_TOKENS_PROGRESS));
      }
   }
}

