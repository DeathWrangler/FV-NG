package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Constants.QuestConstants;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureBuilding;
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Classes.IsraelInnovationCommunityGoalTask;
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import Display.HUD.HUD;
   import Display.HUD.HUDWidgets.HudBottomIsraelInnovationButton;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import Events.TileUnlockEvent;
   import Managers.Crafting.CraftingManager;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Transactions.TIsraelCommunityGoalsGetProgress;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.GenericSingleRewardPopup;
   import Widgets.Windows.IsraelCommunityGoalsRewardWindow;
   import Widgets.Windows.IsraelInnovationBuyWindow;
   import Widgets.Windows.IsraelInnovationCommunityGoalWindow;
   import Widgets.Windows.IsraelInnovationDailyBonusGrantWindow;
   import Widgets.Windows.IsraelInnovationFinalRewardWindow;
   import Widgets.Windows.IsraelInnovationLeaderboardWindow;
   import Widgets.Windows.IsraelInnovationMainWindow;
   import Widgets.Windows.IsraelInnovationPostBonusHarvestWindow;
   import Widgets.Windows.IsraelInnovationRewardWindow;
   import Widgets.Windows.IsraelInnovationRewardsMarketWindow;
   import Widgets.Windows.IsraelInnovationTileUnlockwindow;
   import Widgets.Windows.IsraelLandBundleWindow;
   import flash.events.Event;
   
   public class IsraelInnovationManager extends BaseFeatureManager
   {
      
      public static const HUD_INITIALISATION_FLAG:String = "israel_innovation_hud_initialise_flag";
      
      private static const HUD_ISRAEL_ASSET:String = "assets/dialogs/israel/innovation/FV_xis_hud_Innovation.swf";
      
      public static const FEATURE_NAME:String = "IsraelInnovation";
      
      private static const WINDOW_MAIN:String = "main";
      
      private static const WINDOW_REWARD:String = "reward";
      
      private static const WINDOW_CONGRATS:String = "congrats";
      
      private static const WINDOW_BUY:String = "buyDialog";
      
      public static const FIRST_EVER_REDEEM:String = "firstTimeRedeem";
      
      public static const ISRAEL_LAND_BUNDLE_UNLOCKED:String = "Israel_LandBundle_unlocked";
      
      private static const ISRAEL_COMMUNITY_GOALS_TASK_DATA:String = "ISRAEL_COMMUNITY_GOALS_TASK_DATA";
      
      private static const ISRAEL_COMMUNITY_GOALS_TESTING_FLAG:String = "ISRAEL_COMMUNITY_GOALS_TESTING";
      
      public static const COLLECT_TIME_KEY:String = "ctk";
      
      public static const FEED_NAME:String = "IsraelInnovationUI";
      
      public static const FEATURE_OPTIONS_KEY:String = "IsraelInnovation";
      
      public static const KEY_LEADERBOARD_EA_POINTS_GRANTED:String = "leaderboard_ea_pts_granted";
      
      public static const KEY_WEEKLY_REWARD_EASY_GRANTED:String = "weekly_easy_reward_granted";
      
      public static const KEY_WEEKLY_REWARD_MEDIUM_GRANTED:String = "weekly_medium_reward_granted";
      
      public static const KEY_WEEKLY_REWARD_HARD_GRANTED:String = "weekly_hard_reward_granted";
      
      public static const KEY_WEEKLY_REWARD_FINAL_GRANTED:String = "weekly_final_reward_granted";
      
      public static const KEY_DAILY_CHIP_GRANTED:String = "daily_chip_granted";
      
      public static const KEY_DAILY_RESET_DONE:String = "daily_reset_done";
      
      public static const KEY_LANDBUNDLE_REWARD:String = "landbundle_reward_granted";
      
      public static const KEY_GA_FEATURE_START:String = "ga_innovation_start";
      
      private static var m_initialized:Boolean = false;
      
      private static const SKIP_COST:int = 1;
      
      private static const KEY_SAVED_ACTIVE_TASKS:String = "1";
      
      private static const KEY_SAVED_DUMPED_TIMESTAMP:String = "3";
      
      private static const KEY_FLUSH_DAILY_REWARD_TASK:String = "flush_daily_reward_tasks";
      
      private static const KEY_CURRENT_LEADERBOARD:String = "currentLeaderboard";
      
      private static const KEY_CURRENT_WEEK:String = "currentweek";
      
      private static const KEY_SAVED_LEADERBOARD_RESULT:String = "leaderboard_data";
      
      private static const KEY_SHOW_LEADERBOARD_FIRST_TIME_IN_WEEK:String = "weekly_show_leaderboard_first_time";
      
      private static const KEY_CURRENT_ORDERBOARD_LEADERBOARD:String = "currentOrderboardLeaderboard";
      
      private static const KEY_CURRENT_VIRAL_LEADERBOARD:String = "currentViralLeaderboard";
      
      private static const SERVICE_NAME:String = "IsraelInnovationService";
      
      public static const KEY_PLAYER_COUNT:String = "community_player_count";
      
      public static const KEY_UPDATE_COUNT:String = "community_task_update_count";
      
      public static const KEY_COMMUNITY_REWARDS:String = "community_rewards";
      
      private static const LAST_BONUS_HARVEST_TIME_KEY:String = "xty_bht";
      
      public static const DEFAULT_HARVEST_THROTTLE_TIME:Number = 86400;
      
      private static const CRAFTSHOP_CONSUMABLE_TAB:String = "consumable";
      
      private static const BONUS_HARVEST_COUNT:String = "hc";
      
      private static const BONUS_COUNT_MAP:Object = {
         "familyfarmhouse":4,
         "townfarm":5,
         "agroexportcomplex":6
      };
      
      public const TILE_UNLOCK:String = "Tile_Unlock";
      
      public const FIRST_TIME_UNLOCK:String = "First_tile_Unlock";
      
      private var m_cachedTaskData:Object;
      
      private var m_communityRewardsEarned:Object;
      
      private var m_commRewardWindow:IsraelCommunityGoalsRewardWindow;
      
      public const DEFAULT_THROTTLE_TIME:Number = 86400;
      
      private var m_assetPaths:Object = null;
      
      protected var m_staticData:Object;
      
      private var m_mainWindow:IsraelInnovationMainWindow;
      
      private var m_rewardPopup:GenericSingleRewardPopup;
      
      public const VAL_FIRST_MILESTONE:int = 15;
      
      public const VAL_SECOND_MILESTONE:int = 35;
      
      public const VAL_THIRD_MILESTONE:int = 50;
      
      public const VAL_WEEK_FIRST_MILESTONE:int = 75;
      
      public const VAL_WEEK_SECOND_MILESTONE:int = 150;
      
      public const VAL_WEEK_THIRD_MILESTONE:int = 300;
      
      public const VAL_WEEK_FINAL_MILESTONE:int = 350;
      
      protected const KEY_PROGRESS:String = "progress";
      
      protected const KEY_TOTAL:String = "total";
      
      private var m_resultObject:Object;
      
      private var m_CgTaskList:Array;
      
      private const QUEST_NAME:String = "IsraelInnovation";
      
      private var m_israelInnovationHud:HudBottomIsraelInnovationButton;
      
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
      
      private const KEY_VIRAL_ASK_COUNT:String = "viral_share_count";
      
      private const KEY_ORDERBOARD_COUNT_TASK:String = "israelInnovationOrderboardTask";
      
      private const KEY_VIRAL_SHARE_TASK:String = "israelInnovationViralTask";
      
      private const KEY_LAST_USED_TYPE:String = "lt";
      
      private var m_tasksByTypes:Object = null;
      
      private const KEY_USER_STATE:String = "state";
      
      private var taskTypesArray:Array = [["M1","M1","M1","M1","M1","M1","EH","M1","M1","M1","M1","M1","HB","M1","BB","M1","M1","M1","M1","M1"],["M2","M2","M2","M2","M2","M2","EH","M2","M2","M2","M2","M2","HB","M2","BB","M2","M2","M2","M2","M2"],["M3","M3","M3","M3","M3","M3","EH","M3","M3","M3","M3","M3","HB","M3","BB","M3","M3","M3","M3","M3"],["M4","M4","M4","M4","M4","M4","M4","M4","M4","M4","M4","M4","M4","M4","M4","M4","M4","M4","M4","M4"]];
      
      private var KEY_WEEK_MULTIPLIER_PPH:Array = [1,1,1.5,2,2,3,3];
      
      private var KEY_WEEK_INCREMENT_CRAFT:Array = [0,0,1,1,2,2,2];
      
      private const KEY_DUMPED_STATUS:String = "dump_status";
      
      private const KEY_DAY_POINTS:String = "dp";
      
      private const KEY_WEEK_POINTS:String = "wp";
      
      private const WEEKLY_SCORE:String = "weekly_score";
      
      public const EASY:int = 0;
      
      public const MEDIUM:int = 1;
      
      public const HARD:int = 2;
      
      public const LOCK1:int = 4;
      
      public const LOCK2:int = 5;
      
      public const DONE_FOR_THE_DAY:int = 3;
      
      public const NOT_INITIALIZED:int = -1;
      
      private const KEY_DAILY_PROGRESS_POINTS:String = "pts";
      
      private const KEY_WEEKLY_PROGRESS_POINTS:String = "wpts";
      
      private const FEATURE_OPTIONS_BONUS_CLAIMED_KEY:String = "bonus";
      
      private const KEY_FEATURE_ENDED:String = "finished";
      
      private const KEY_ACTIVE_DAY_TIMESTAMP:String = "ts";
      
      private var m_rewardWindow:IsraelInnovationRewardWindow;
      
      private var m_buyWindow:IsraelInnovationBuyWindow;
      
      private var m_landBundleWindow:IsraelLandBundleWindow;
      
      private var m_rewardMarketWindow:IsraelInnovationRewardsMarketWindow;
      
      public var m_communityGoalWindow:IsraelInnovationCommunityGoalWindow;
      
      private var m_finalRewardWindow:IsraelInnovationFinalRewardWindow;
      
      private const KEY_TASK_LEVEL:String = "taskLevel";
      
      private const FEATURE_OPTIONS_BONUS_CODE_KEY:String = "bonusCode";
      
      private var m_rewardsBySlotName:Object = null;
      
      public const VAL_MILESTONE_POINTS_ARRAY:Array = [15,35,50];
      
      public const VAL_WEEK_MILESTONE_POINTS_ARRAY:Array = [75,150,300,350];
      
      private const MAX_REWARDS_ALLOWED:int = 5;
      
      private const VAL_CLASSIC:int = 281;
      
      private const VAL_SUPERB:int = 201;
      
      private const VAL_GOOD:int = 100;
      
      private const NO_OF_WEEKS:int = 5;
      
      private const KEY_BUY_COUNT_FOR_SLOT:String = "buyCountForSlot";
      
      private var m_marketRewardsData:Object = null;
      
      private const SERVICE_FUNC_HARVEST_BONUS:String = "harvestBonusBuilding";
      
      private const SERVICE_FUNC_GRANT_BONUS:String = "grantBonus";
      
      private const EVENT_WW_INNOVATION_TILE_UNLOCK:String = "IsraelInnovationTileUnlock";
      
      public const CRUSH_BARREL_TUTORIAL:String = "IsraelInnovationSinkTutorial";
      
      public const FIRST_SESSION_TUTORIAL:String = "TIFirstSessioTutorial";
      
      private var BONUS_HARVEST_ARRAY:Array = ["consume_organic_fertilizer","consume_unwither","consume_farm_hands","fuel1","consume_instagrow","consume_turbo_charger"];
      
      private const REWARD_SHARE_WINDOW:String = "assets/dialogs/expansion/FV_RewardDialog_Share.swf";
      
      private const REWARD_WINDOW_IMAGE:String = "assets/dialogs/israel/RewardDialog.png";
      
      private var _redeemHasStarted:Boolean = false;
      
      public var m_leaderboardWindow:IsraelInnovationLeaderboardWindow;
      
      private const REDEEM_ADDITIONAL_DAYS:int = 2;
      
      public function IsraelInnovationManager(featureName:String, featureConfig:XML = null)
      {
         super(featureName,featureConfig);
         this.parseTaskObjectsFromConfig(this.QUEST_NAME);
         this.parseRewardsDataFromConfig(this.QUEST_NAME);
         this.m_resultObject = new Object();
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
      }
      
      public static function getInstance(featureName:String = "IsraelInnovation") : IsraelInnovationManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,IsraelInnovationManager) as IsraelInnovationManager;
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
      
      public function setupIsraelHud() : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         this.m_israelInnovationHud = new HudBottomIsraelInnovationButton(HUD_ISRAEL_ASSET,m_featureName);
         Global.hud.setBottomHudIsraelInnovationButton(this.m_israelInnovationHud as HudBottomIsraelInnovationButton);
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
               nextUsedtaskTypeIndexInUserState = (lastUsedtaskTypeIndexInUserState + 1) % 20;
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
                        if(userState == this.EASY && fatureObject[this.KEY_LAST_TASKS_IDS][taskType] >= 5)
                        {
                           taskLevelCheck = false;
                        }
                        if(userState == this.MEDIUM && fatureObject[this.KEY_LAST_TASKS_IDS][taskType] >= 19)
                        {
                           taskLevelCheck = false;
                        }
                        if(userState == this.MEDIUM && fatureObject[this.KEY_LAST_TASKS_IDS][taskType] < 5)
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
                        if(userState == this.EASY && fatureObject[this.KEY_LAST_TASKS_IDS][taskType] >= 6)
                        {
                           taskLevelCheck = false;
                        }
                        if(userState == this.MEDIUM && fatureObject[this.KEY_LAST_TASKS_IDS][taskType] >= 10)
                        {
                           taskLevelCheck = false;
                        }
                        if(userState == this.MEDIUM && fatureObject[this.KEY_LAST_TASKS_IDS][taskType] < 6)
                        {
                           taskLevelCheck = false;
                        }
                        if(userState == this.HARD && fatureObject[this.KEY_LAST_TASKS_IDS][taskType] < 10)
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
                  if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_ISRAEL_INNOVATION_TASK_V2) == 2)
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
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_ISRAEL_INNOVATION_TASK_V2) == 2)
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
      
      public function npcCalloutSlot() : Boolean
      {
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ISRAEL) == true)
         {
            if(this.activeDayIndex < 7 && this.getTotalPointsForUser() <= (this.activeDayIndex + 1) * 10)
            {
               return true;
            }
            if(this.activeDayIndex >= 7 && this.getTotalPointsForUser() == 70)
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
         var weekCount:int = 0;
         var total:int = 0;
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
                  if(taskObj.action == "harvestByCode")
                  {
                     if(taskObj.helper == "plant_seed")
                     {
                        taskObj.total *= this.KEY_WEEK_MULTIPLIER_PPH[weekCount - 1];
                     }
                  }
                  else if(taskObj.action == "makeRecipeByCode")
                  {
                     if(!(taskObj.type == "1ye2" || taskObj.type == "1ygu" || taskObj.type == "1yfp" || taskObj.type == "1yfo"))
                     {
                        total = 0;
                        total = int(taskObj.total) + int(this.KEY_WEEK_INCREMENT_CRAFT[weekCount - 1]);
                        taskObj.total = total.toString();
                     }
                  }
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
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("israel_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq) && this.isFeatureInActivePeriod())
         {
            ConsumableItem = Global.farmGameSettingsManager.getFarmItemByCode(this.ConsumableCode);
            UI.displayPopup(new IsraelInnovationTileUnlockwindow("assets/dialogs/expansion/FV_RewardDialog.swf",featureName,ConsumableItem,null,"assets/dialogs/israel/RewardDialog.png"));
            FarmStatsManager.count(m_featureName,"feature_ui","tileUnlockPopup");
         }
         if(!Global.player.getSeenFlag(this.TILE_UNLOCK))
         {
            Global.player.setSeenFlag(this.TILE_UNLOCK);
         }
         FarmStatsManager.count(m_featureName,"UnlockTile");
      }
      
      public function showLeaderboardUI() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         FarmStatsManager.count("IsraelInnovation","LeaderboardClick");
         this.m_leaderboardWindow = new IsraelInnovationLeaderboardWindow("assets/dialogs/israel/innovation/FV_xis_Innovation_Leaderboard.swf  ",m_featureName,null,null,false);
         UI.displayPopup(this.m_leaderboardWindow,false);
      }
      
      public function showDailyBonusGrantPopup(rewardItem:FarmItem) : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         FarmStatsManager.count(m_featureName,"feature_ui","dailyBonusPopup");
         UI.displayPopup(new IsraelInnovationDailyBonusGrantWindow("assets/dialogs/expansion/FV_RewardDialog.swf",featureName,rewardItem,null,"assets/dialogs/israel/RewardDialog.png"),false);
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
            this.showLeaderboardRewardPopup();
         }
         else if(this.isFeatureInActivePeriod())
         {
            this.m_mainWindow = new IsraelInnovationMainWindow(m_featureName,this.mainWindowURL,showTutorialWithEAPage);
            UI.displayPopup(this.m_mainWindow);
         }
         else if(this.isFeatureInRedeemPeriod())
         {
            this.openRewardMarketWindow();
         }
         FarmStatsManager.count("IsraelInnovation","feature_ui","main_ui","impression");
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
      
      public function showLeaderboardRewardPopup() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         this.m_leaderboardWindow = new IsraelInnovationLeaderboardWindow("assets/dialogs/israel/innovation/FV_xis_Innovation_Leaderboard.swf ",m_featureName,null,null,true);
         UI.displayPopup(this.m_leaderboardWindow,false);
      }
      
      public function openBuyWindow(owner:FarmWindow) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         this.m_buyWindow = new IsraelInnovationBuyWindow(this.buyDialogURL,m_featureName,this.getBucketPackages(),owner,this.mainWindow);
         UI.displayPopup(this.m_buyWindow,false);
         FarmStatsManager.count("IsraelInnovation","Click","Bundlesofplenty","Buy");
      }
      
      public function craftConsumableFromMainWindow() : void
      {
         if(this.m_buyWindow)
         {
            this.m_buyWindow.close();
         }
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
         FarmStatsManager.count("IsraelInnovation","Craft","Bundlesofplenty",this.consumableCount.toString());
         var consumableSearchStr:String = "Bundle";
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
         var leaderboardxml:XML = null;
         var communityGoalXml:XML = null;
         var weekxml:XML = null;
         this.m_staticData = new Object();
         this.m_staticData.typeArray = [];
         this.m_staticData.rewardArray = [];
         this.m_staticData.rewardCostArray = [];
         this.m_staticData.bucketPackages = [];
         this.m_staticData.tilesArray = [];
         this.m_staticData.endDate = "";
         this.m_staticData.consumable = "";
         this.m_staticData.chip = "";
         this.m_staticData.currencyName = "";
         this.m_staticData.initialGrant = 0;
         this.m_staticData.rewardGrantCount = 0;
         this.m_staticData.gameCost = 0;
         this.m_staticData.p2pTurnCount = 0;
         this.m_staticData.soloTurnCount = 0;
         this.m_staticData.bonusGrantDate = new String();
         this.m_staticData.leaderboardConfigData = new Array();
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
            this.m_staticData.chip = featureXML.chipItem.@code.toString();
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
            if(featureXML.leaderboardConfig)
            {
               for each(leaderboardxml in featureXML.leaderboardConfig.leaderboard)
               {
                  this.m_staticData.leaderboardConfigData.push(leaderboardxml);
               }
            }
            if(featureXML.communityGoalConfig)
            {
               for each(communityGoalXml in featureXML.communityGoalConfig.israelInnovationCgTask)
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
      
      public function get ChipCode() : String
      {
         return this.m_staticData.chip;
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
         if(this.m_buyWindow)
         {
            this.m_buyWindow.refreshAskButton();
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
         var tasks:Vector.<FarmTask> = this.getActiveTasks();
         if(Global.player.canBuyCash(tasks[slotIndex].skipCashValue))
         {
            Global.player.cash -= tasks[slotIndex].skipCashValue;
            featureObject = this.getFeatureData();
            questTasks1 = IsraelInnovationManager.getInstance(m_featureName).getActiveTasks();
            taskPt = questTasks1[slotIndex].questPoints;
            taskLBPt = questTasks1[slotIndex].questPoints;
            if(featureObject[this.KEY_DAY_POINTS] + questTasks1[slotIndex].questPoints > this.VAL_THIRD_MILESTONE)
            {
               taskPt = this.VAL_THIRD_MILESTONE - featureObject[this.KEY_DAY_POINTS];
            }
            featureObject[this.KEY_DAY_POINTS] += questTasks1[slotIndex].questPoints;
            featureObject[this.KEY_ORDERBOARD_COUNT] += 1;
            featureObject[this.WEEKLY_SCORE] += questTasks1[slotIndex].questPoints;
            if(this.hasActiveDayExpired() == false && this.getUserState() != this.DONE_FOR_THE_DAY)
            {
               featureObject[this.KEY_WEEK_POINTS] += questTasks1[slotIndex].questPoints;
            }
            setFeatureData(featureObject);
            this.mainWindow.untintWindow();
            this.mainWindow.enableInput = true;
            if(this.hasActiveDayExpired() == false && this.getUserState() != this.DONE_FOR_THE_DAY)
            {
               this.m_mainWindow.updateTaskDoober(taskPt);
            }
            if(this.getDayEndMessageShown())
            {
               this.m_mainWindow.updateLeaderboardDoober(taskLBPt);
            }
            this.checkAndUpdateUserState();
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipTask",null,[m_featureName,slotIndex]),true);
            this.resetActionCountsForTasks(tasks[slotIndex]);
            this.updateOrderboardCount();
            this.generateAndSaveNewTask(slotIndex);
            this.m_mainWindow.refreshTaskFrame();
            this.m_mainWindow.updateProgressCircle();
            this.m_mainWindow.updateWeeklyTable();
            this.m_mainWindow.updateWeeklyMeter();
            this.m_mainWindow.updateLeaderBoardFrame(featureObject[this.WEEKLY_SCORE],0);
            if(this.mainWindow)
            {
               this.mainWindow.playStompingAnimation();
            }
            FarmStatsManager.count("IsraelInnovation","SkipTask",questTasks1[slotIndex].type,null,featureObject[this.KEY_DAY_POINTS].toString(),tasks[slotIndex].skipCashValue.toString(),questTasks1[slotIndex].questPoints);
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
            this.mainWindow.playStompingAnimation();
         }
         var tasks:Vector.<FarmTask> = this.getActiveTasks();
         var featureObject:Object = this.getFeatureData();
         questTasks1 = IsraelInnovationManager.getInstance(m_featureName).getActiveTasks();
         var taskPt:int = questTasks1[slotIndex].questPoints;
         var taskLBPt:int = questTasks1[slotIndex].questPoints;
         if(featureObject[this.KEY_DAY_POINTS] + questTasks1[slotIndex].questPoints > this.VAL_THIRD_MILESTONE)
         {
            taskPt -= this.VAL_THIRD_MILESTONE - featureObject[this.KEY_DAY_POINTS];
         }
         if(this.hasActiveDayExpired() == false && this.getUserState() != this.DONE_FOR_THE_DAY)
         {
            featureObject[this.KEY_WEEK_POINTS] += questTasks1[slotIndex].questPoints;
         }
         else if(this.hasActiveDayExpired() == true && featureObject[this.KEY_DAY_POINTS] + questTasks1[slotIndex].questPoints > this.VAL_THIRD_MILESTONE && featureObject[this.KEY_DAY_POINTS] < this.VAL_THIRD_MILESTONE)
         {
            featureObject[this.KEY_WEEK_POINTS] += this.VAL_THIRD_MILESTONE - featureObject[this.KEY_DAY_POINTS];
         }
         else if(this.hasActiveDayExpired() == true && featureObject[this.KEY_DAY_POINTS] + questTasks1[slotIndex].questPoints <= this.VAL_THIRD_MILESTONE)
         {
            featureObject[this.KEY_WEEK_POINTS] += questTasks1[slotIndex].questPoints;
         }
         featureObject[this.KEY_DAY_POINTS] += questTasks1[slotIndex].questPoints;
         featureObject[this.WEEKLY_SCORE] += questTasks1[slotIndex].questPoints;
         featureObject[this.KEY_ORDERBOARD_COUNT] += 1;
         setFeatureData(featureObject);
         this.resetActionCountsForTasks(tasks[slotIndex]);
         this.updateOrderboardCount();
         if(this.hasActiveDayExpired() == false && this.getUserState() != this.DONE_FOR_THE_DAY)
         {
            this.m_mainWindow.updateTaskDoober(taskPt);
         }
         if(this.getDayEndMessageShown())
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
            this.checkAndUpdateWeeklyStatus();
         }
         this.generateAndSaveNewTask(slotIndex);
         this.m_mainWindow.refreshTaskFrame();
         this.m_mainWindow.updateProgressCircle();
         this.m_mainWindow.updateWeeklyTable();
         this.m_mainWindow.updateWeeklyMeter();
         this.m_mainWindow.updateLeaderBoardFrame(featureObject[this.WEEKLY_SCORE]);
         FarmStatsManager.count("IsraelInnovation","RedeemTask",questTasks1[slotIndex].type,this.overAllProgressLevel().toString(),featureObject[this.KEY_DAY_POINTS].toString(),"",questTasks1[slotIndex].questPoints);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"redeemTask",null,[m_featureName,slotIndex]),true);
      }
      
      public function checkAndUpdateUserState() : void
      {
         var userState:int = 0;
         var dayPoints:int = this.getDayPoints();
         var weekPoints:int = this.getWeekPoints();
         var featureObj:Object = this.getFeatureData();
         if(this.hasActiveDayExpired() == false)
         {
            userState = featureObj[this.KEY_USER_STATE] as int;
            if(dayPoints >= this.VAL_FIRST_MILESTONE && userState == this.EASY)
            {
               featureObj[this.KEY_USER_STATE] = this.LOCK1;
               this.grantFarmOffChip(1);
               FarmStatsManager.count("IsraelInnovation","userstate",this.currentDayIndex.toString(),"Good",dayPoints.toString(),this.chipCount.toString());
            }
            else if(dayPoints >= this.VAL_SECOND_MILESTONE && userState == this.MEDIUM)
            {
               featureObj[this.KEY_USER_STATE] = this.LOCK2;
               this.grantFarmOffChip(1);
               FarmStatsManager.count("IsraelInnovation","userstate",this.currentDayIndex.toString(),"superb",dayPoints.toString(),this.chipCount.toString());
            }
            else if(dayPoints >= this.VAL_THIRD_MILESTONE && userState == this.HARD)
            {
               featureObj[this.KEY_USER_STATE] = this.DONE_FOR_THE_DAY;
               this.grantFarmOffChip(1);
               if(dayPoints > this.VAL_THIRD_MILESTONE)
               {
                  featureObj[this.KEY_WEEK_POINTS] -= dayPoints - this.VAL_THIRD_MILESTONE;
                  weekPoints = int(featureObj[this.KEY_WEEK_POINTS]);
               }
               FarmStatsManager.count("IsraelInnovation","userstate",this.currentDayIndex.toString(),"classic",dayPoints.toString(),this.chipCount.toString());
            }
            setFeatureData(featureObj);
         }
         if(weekPoints >= this.VAL_WEEK_FINAL_MILESTONE && featureObj[KEY_WEEKLY_REWARD_FINAL_GRANTED] == false)
         {
            featureObj[KEY_WEEKLY_REWARD_FINAL_GRANTED] = true;
            this.grantFarmOffChip(3);
            this.showDailyBonusGrantPopup(this.chipItem);
            setFeatureData(featureObj);
         }
         else if(weekPoints >= this.VAL_WEEK_THIRD_MILESTONE && featureObj[KEY_WEEKLY_REWARD_HARD_GRANTED] == false)
         {
            featureObj[KEY_WEEKLY_REWARD_HARD_GRANTED] = true;
            this.grantUserRewardforLevel(this.HARD);
            this.showDailyBonusGrantPopup(this.getActiveDayReward(this.HARD));
            setFeatureData(featureObj);
         }
         else if(weekPoints >= this.VAL_WEEK_SECOND_MILESTONE && featureObj[KEY_WEEKLY_REWARD_MEDIUM_GRANTED] == false)
         {
            featureObj[KEY_WEEKLY_REWARD_MEDIUM_GRANTED] = true;
            this.grantUserRewardforLevel(this.MEDIUM);
            this.showDailyBonusGrantPopup(this.getActiveDayReward(this.MEDIUM));
            setFeatureData(featureObj);
         }
         else if(weekPoints >= this.VAL_WEEK_FIRST_MILESTONE && featureObj[KEY_WEEKLY_REWARD_EASY_GRANTED] == false)
         {
            featureObj[KEY_WEEKLY_REWARD_EASY_GRANTED] = true;
            this.grantUserRewardforLevel(this.EASY);
            this.showDailyBonusGrantPopup(this.getActiveDayReward(this.EASY));
            setFeatureData(featureObj);
         }
      }
      
      public function checkAndUpdateWeeklyStatus() : void
      {
         var weekPoints:int = this.getWeekPoints();
         var featureObj:Object = this.getFeatureData();
         if(weekPoints >= this.VAL_WEEK_FINAL_MILESTONE && featureObj[KEY_WEEKLY_REWARD_FINAL_GRANTED] == false)
         {
            featureObj[KEY_WEEKLY_REWARD_FINAL_GRANTED] = true;
            this.grantFarmOffChip(3);
            this.showDailyBonusGrantPopup(this.chipItem);
            setFeatureData(featureObj);
         }
         else if(weekPoints >= this.VAL_WEEK_THIRD_MILESTONE && featureObj[KEY_WEEKLY_REWARD_HARD_GRANTED] == false)
         {
            featureObj[KEY_WEEKLY_REWARD_HARD_GRANTED] = true;
            this.grantUserRewardforLevel(this.HARD);
            this.showDailyBonusGrantPopup(this.getActiveDayReward(this.HARD));
            setFeatureData(featureObj);
         }
         else if(weekPoints >= this.VAL_WEEK_SECOND_MILESTONE && featureObj[KEY_WEEKLY_REWARD_MEDIUM_GRANTED] == false)
         {
            featureObj[KEY_WEEKLY_REWARD_MEDIUM_GRANTED] = true;
            this.grantUserRewardforLevel(this.MEDIUM);
            this.showDailyBonusGrantPopup(this.getActiveDayReward(this.MEDIUM));
            setFeatureData(featureObj);
         }
         else if(weekPoints >= this.VAL_WEEK_FIRST_MILESTONE && featureObj[KEY_WEEKLY_REWARD_EASY_GRANTED] == false)
         {
            featureObj[KEY_WEEKLY_REWARD_EASY_GRANTED] = true;
            this.grantUserRewardforLevel(this.EASY);
            this.showDailyBonusGrantPopup(this.getActiveDayReward(this.EASY));
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
            FarmStatsManager.count("IsraelInnovation","sink","Bundlesofplenty",this.consumableCount.toString(),consumableNeeded.toString());
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
            FarmStatsManager.count("IsraelInnovation","Trash",this.currentDayIndex.toString());
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
            FarmStatsManager.count("IsraelInnovation","SkipTrashedTask","1",this.currentDayIndex.toString());
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
               this.mainWindow.playStompingAnimation();
            }
            Global.player.gold -= tasks[slotIndex].total;
            this.postTaskCompletionActions(slotIndex);
            FarmStatsManager.count("IsraelInnovation","sinkGold",tasks[slotIndex].type,this.currentDayIndex.toString());
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
            this.mainWindow.playStompingAnimation();
         }
         FarmStatsManager.count("IsraelInnovation","sinkBushel",tasks[slotIndex].type,this.currentDayIndex.toString());
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkBushel",null,[m_featureName,slotIndex]),true);
      }
      
      public function postTaskCompletionActions(completedTaskSlotIndex:int) : void
      {
         var questTasks1:Vector.<FarmTask> = null;
         var featureObject:Object = this.getFeatureData();
         questTasks1 = IsraelInnovationManager.getInstance(m_featureName).getActiveTasks();
         var taskPt:int = questTasks1[completedTaskSlotIndex].questPoints;
         var taskLBPt:int = questTasks1[completedTaskSlotIndex].questPoints;
         if(featureObject[this.KEY_DAY_POINTS] + questTasks1[completedTaskSlotIndex].questPoints > this.VAL_THIRD_MILESTONE)
         {
            taskPt -= this.VAL_THIRD_MILESTONE - featureObject[this.KEY_DAY_POINTS];
         }
         if(this.hasActiveDayExpired() == false && this.getUserState() != this.DONE_FOR_THE_DAY)
         {
            featureObject[this.KEY_WEEK_POINTS] += questTasks1[completedTaskSlotIndex].questPoints;
         }
         else if(this.hasActiveDayExpired() == true && featureObject[this.KEY_DAY_POINTS] + questTasks1[completedTaskSlotIndex].questPoints > this.VAL_THIRD_MILESTONE && featureObject[this.KEY_DAY_POINTS] < this.VAL_THIRD_MILESTONE)
         {
            featureObject[this.KEY_WEEK_POINTS] += this.VAL_THIRD_MILESTONE - featureObject[this.KEY_DAY_POINTS];
         }
         else if(this.hasActiveDayExpired() == true && featureObject[this.KEY_DAY_POINTS] + questTasks1[completedTaskSlotIndex].questPoints <= this.VAL_THIRD_MILESTONE)
         {
            featureObject[this.KEY_WEEK_POINTS] += questTasks1[completedTaskSlotIndex].questPoints;
         }
         featureObject[this.KEY_DAY_POINTS] += questTasks1[completedTaskSlotIndex].questPoints;
         featureObject[this.WEEKLY_SCORE] += questTasks1[completedTaskSlotIndex].questPoints;
         featureObject[this.KEY_ORDERBOARD_COUNT] += 1;
         setFeatureData(featureObject);
         if(this.hasActiveDayExpired() == false && this.getUserState() != this.DONE_FOR_THE_DAY)
         {
            this.m_mainWindow.updateTaskDoober(taskPt);
         }
         if(this.getDayEndMessageShown())
         {
            this.m_mainWindow.updateLeaderboardDoober(taskLBPt);
         }
         if(this.hasActiveDayExpired() == true)
         {
            this.redeemHasStarted = true;
            this.m_mainWindow.updateTaskDoober(taskPt);
            this.checkAndUpdateWeeklyStatus();
         }
         else
         {
            this.checkAndUpdateUserState();
         }
         var tasks:Vector.<FarmTask> = this.getActiveTasks();
         this.resetActionCountsForTasks(tasks[completedTaskSlotIndex]);
         this.updateOrderboardCount();
         this.generateAndSaveNewTask(completedTaskSlotIndex);
         this.m_mainWindow.refreshTaskFrame();
         this.m_mainWindow.updateProgressCircle();
         this.m_mainWindow.updateWeeklyTable();
         this.m_mainWindow.updateWeeklyMeter();
         this.m_mainWindow.updateLeaderBoardFrame(featureObject[this.WEEKLY_SCORE]);
      }
      
      private function checkRewardFeed(result:Object) : void
      {
         if(Boolean(result) && !result["error"])
         {
            if(Boolean(this.m_resultObject) && Boolean(result["feedData"]))
            {
               this.m_resultObject = result["feedData"];
            }
         }
      }
      
      public function postRewardBragFeed(event:Event) : void
      {
         if(this.m_resultObject)
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(this.m_resultObject);
         }
         if(this.m_rewardPopup)
         {
            this.m_rewardPopup.close();
         }
         if(this.m_rewardMarketWindow)
         {
            this.m_rewardMarketWindow.refreshMarketWindow();
         }
      }
      
      public function getFeatureData() : Object
      {
         var index:int = 0;
         var i:int = 0;
         var j:int = 0;
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
            featureData[this.KEY_WEEKLY_PROGRESS_POINTS] = {};
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
            featureData[this.KEY_WEEK_POINTS] = 0;
            featureData[this.WEEKLY_SCORE] = 0;
            featureData[KEY_SAVED_DUMPED_TIMESTAMP] = {};
            featureData[KEY_FLUSH_DAILY_REWARD_TASK] = 0;
            featureData[KEY_CURRENT_LEADERBOARD] = "";
            featureData[KEY_CURRENT_ORDERBOARD_LEADERBOARD] = "";
            featureData[KEY_CURRENT_VIRAL_LEADERBOARD] = "";
            featureData[KEY_CURRENT_WEEK] = 0;
            featureData[KEY_SAVED_LEADERBOARD_RESULT] = {};
            featureData[KEY_LEADERBOARD_EA_POINTS_GRANTED] = false;
            featureData[KEY_WEEKLY_REWARD_EASY_GRANTED] = false;
            featureData[KEY_WEEKLY_REWARD_MEDIUM_GRANTED] = false;
            featureData[KEY_WEEKLY_REWARD_HARD_GRANTED] = false;
            featureData[KEY_WEEKLY_REWARD_FINAL_GRANTED] = false;
            featureData[KEY_DAILY_CHIP_GRANTED] = false;
            featureData[KEY_DAILY_RESET_DONE] = false;
            featureData[KEY_LANDBUNDLE_REWARD] = false;
            featureData[KEY_GA_FEATURE_START] = false;
            featureData[this.KEY_ORDERBOARD_COUNT] = 0;
            featureData[this.KEY_VIRAL_ASK_COUNT] = 0;
            for(i = 0; i < this.NO_OF_WEEKS; i++)
            {
               featureData[this.KEY_ORDERBOARD_COUNT_TASK + "Week" + (i + 1).toString()] = {};
               featureData[this.KEY_ORDERBOARD_COUNT_TASK + "Week" + (i + 1).toString()][KEY_PLAYER_COUNT] = 0;
               featureData[this.KEY_ORDERBOARD_COUNT_TASK + "Week" + (i + 1).toString()][KEY_UPDATE_COUNT] = 0;
               featureData[this.KEY_ORDERBOARD_COUNT_TASK + "Week" + (i + 1).toString()][KEY_COMMUNITY_REWARDS] = 0;
            }
            for(j = 0; j < this.NO_OF_WEEKS; j++)
            {
               featureData[this.KEY_VIRAL_SHARE_TASK + "Week" + (j + 1).toString()] = {};
               featureData[this.KEY_VIRAL_SHARE_TASK + "Week" + (j + 1).toString()][KEY_PLAYER_COUNT] = 0;
               featureData[this.KEY_VIRAL_SHARE_TASK + "Week" + (j + 1).toString()][KEY_UPDATE_COUNT] = 0;
               featureData[this.KEY_VIRAL_SHARE_TASK + "Week" + (j + 1).toString()][KEY_COMMUNITY_REWARDS] = 0;
               featureData[KEY_SHOW_LEADERBOARD_FIRST_TIME_IN_WEEK] = 1;
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
         FarmStatsManager.count("IsraelInnovation","GetNewTask",this.currentDayIndex.toString(),this.overAllProgressLevel().toString());
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
         orderBoardXml = Global.farmGameSettingsManager.getXML().IsraelInnovationQuests.IsraelInnovationQuest.(@name == questName)[0];
         rewardsList = orderBoardXml.IsraelInnovationRewards.stage;
         for each(rewardsByStage in rewardsList)
         {
            str = rewardsByStage.@id;
            rewardsXMLListByStage = rewardsByStage.rewards;
            this.m_rewardsBySlotName[rewardsByStage.@id] = rewardsXMLListByStage;
         }
      }
      
      public function parseMarketRewards() : void
      {
         var result:Boolean = false;
         var orderBoardXml:XML = null;
         var rewardsList:XMLList = null;
         var rewardsByStage:XML = null;
         var str:String = null;
         var rewardsXMLListByStage:XMLList = null;
         var reward:XML = null;
         var startDate:String = null;
         var slot:String = null;
         var itemCode:String = null;
         var cash:String = null;
         var quantity:String = null;
         this.m_marketRewardsData = {};
         result = false;
         orderBoardXml = Global.farmGameSettingsManager.getXML().IsraelInnovationRewardMarketQuests.IsraelInnovationRewardMarketQuest.(@name == "IsraelInnovation")[0];
         rewardsList = orderBoardXml.IsraelInnovationlRewardMarketRewards.stage;
         for each(rewardsByStage in rewardsList)
         {
            str = rewardsByStage.@id;
            rewardsXMLListByStage = rewardsByStage.rewards.reward;
            this.m_marketRewardsData[rewardsByStage.@id] = {};
            for each(reward in rewardsXMLListByStage)
            {
               slot = reward.@slot;
               itemCode = reward.@value;
               cash = reward.@cash;
               quantity = reward.@quantity;
               this.m_marketRewardsData[rewardsByStage.@id][slot] = {};
               this.m_marketRewardsData[rewardsByStage.@id][slot]["value"] = itemCode;
               this.m_marketRewardsData[rewardsByStage.@id][slot]["cashSlot_" + slot.toString()] = cash;
               this.m_marketRewardsData[rewardsByStage.@id][slot]["quantity_" + slot.toString()] = quantity;
            }
            startDate = rewardsByStage.@startDate;
            this.m_marketRewardsData[rewardsByStage.@id]["startDate"] = startDate;
            result = true;
         }
      }
      
      public function getMarketRewardsData() : Object
      {
         if(this.m_marketRewardsData == null)
         {
            this.parseMarketRewards();
         }
         return this.m_marketRewardsData;
      }
      
      public function getBuyCountForSlot(slotNo:int) : int
      {
         var featureData:Object = this.getFeatureData();
         if(!featureData.hasOwnProperty(this.KEY_BUY_COUNT_FOR_SLOT) || featureData[this.KEY_BUY_COUNT_FOR_SLOT] == null)
         {
            this.initializeFarmOffMarket();
         }
         return featureData[this.KEY_BUY_COUNT_FOR_SLOT][slotNo];
      }
      
      public function initializeFarmOffMarket() : void
      {
         var i:int = 0;
         var featureData:Object = this.getFeatureData();
         if(!featureData.hasOwnProperty(this.KEY_BUY_COUNT_FOR_SLOT) || featureData[this.KEY_BUY_COUNT_FOR_SLOT] == null)
         {
            featureData[this.KEY_BUY_COUNT_FOR_SLOT] = [];
            for(i = 0; i < 6; i++)
            {
               if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ISRAEL))
               {
                  featureData[this.KEY_BUY_COUNT_FOR_SLOT].push(0);
               }
               else
               {
                  featureData[this.KEY_BUY_COUNT_FOR_SLOT].push(1);
               }
            }
            setFeatureData(featureData);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"initializeFarmOffMarket",null,[m_featureName]),true);
         }
      }
      
      public function getCashForSlot(buyCount:int, slotNo:int) : int
      {
         var key:String = "cashSlot_" + slotNo.toString();
         return buyCount < 5 ? int(this.m_marketRewardsData[buyCount + 1][slotNo][key]) : 0;
      }
      
      public function getQuantityForSlot(buyCount:int, slotNo:int) : int
      {
         var key:String = "quantity_" + slotNo.toString();
         return buyCount < 5 ? int(this.m_marketRewardsData[buyCount + 1][slotNo][key]) : 0;
      }
      
      public function redeemRewardForSlot(slotNo:int, chipRedeemCount:String, item:FarmItem) : void
      {
         var featureData:Object = this.getFeatureData();
         if(!featureData.hasOwnProperty(this.KEY_BUY_COUNT_FOR_SLOT) || featureData[this.KEY_BUY_COUNT_FOR_SLOT] == null)
         {
            this.initializeFarmOffMarket();
         }
         var featureKey:String = m_featureName + "Market";
         featureData[this.KEY_BUY_COUNT_FOR_SLOT][slotNo] += 1;
         setFeatureData(featureData);
         var itemCode:String = this.m_marketRewardsData[featureData[this.KEY_BUY_COUNT_FOR_SLOT][slotNo]][slotNo]["value"];
         var itemQuantity:int = int(this.m_marketRewardsData[featureData[this.KEY_BUY_COUNT_FOR_SLOT][slotNo]][slotNo]["quantity_" + slotNo.toString()]);
         var rewardFarmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         var rewardName:String = rewardFarmItem.name;
         Global.player.addGift(rewardFarmItem.name,"0",itemQuantity);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"redeemRewardForSlot",this.checkRewardFeed,[m_featureName,slotNo]),true);
         FeatureOptionsInventoryManager.getInstance().removeCount(this.ChipCode,parseInt(chipRedeemCount));
         this.m_rewardPopup = new GenericSingleRewardPopup(this.REWARD_SHARE_WINDOW,featureKey,item,this.postRewardBragFeed,this.REWARD_WINDOW_IMAGE);
         UI.displayPopup(this.m_rewardPopup,false);
         var chipCountLeft:int = this.chipCount;
         if(Boolean(this.mainWindow) && Boolean(this.mainWindow.m_daily_collect_mc) && Boolean(this.mainWindow.m_daily_collect_mc.collect_count_tf))
         {
            this.mainWindow.m_daily_collect_mc.collect_count_tf.text = chipCountLeft.toString();
         }
         if(this.m_rewardMarketWindow)
         {
            this.m_rewardMarketWindow.refreshMarketWindow();
            this.m_rewardMarketWindow.updateChipCount(chipCountLeft.toString());
         }
         FarmStatsManager.count(m_featureName,"Farm-off-chips",item.friendlyTitle,chipCountLeft.toString());
      }
      
      public function canPopulateSlot(slotNum:int) : Boolean
      {
         var canPopulate:Boolean = false;
         if(this.m_marketRewardsData == null)
         {
            this.parseMarketRewards();
         }
         var weekObj:Object = this.getCurrentWeek();
         var weekNum:int = weekObj != null ? int(weekObj.count) : 5;
         var buyCount:int = this.getBuyCountForSlot(slotNum);
         canPopulate = buyCount < weekNum;
         if(canPopulate == false)
         {
            return canPopulate;
         }
         if(buyCount > this.MAX_REWARDS_ALLOWED)
         {
            return false;
         }
         var startDate:String = buyCount < 5 ? this.m_marketRewardsData[buyCount + 1]["startDate"] : this.m_marketRewardsData[buyCount]["startDate"];
         var currentTime:Number = GlobalEngine.serverTime;
         var startTimeStamp:Number = FarmGameUtil.synchronizedDateToNumber(startDate) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return currentTime > startTimeStamp;
      }
      
      public function getRewardForSlot(buyCount:int, slotNo:int) : String
      {
         return buyCount < 5 ? this.m_marketRewardsData[buyCount + 1][slotNo]["value"] : this.m_marketRewardsData[buyCount][slotNo]["value"];
      }
      
      public function getRewardsMarketDialogUrl() : String
      {
         return "assets/dialogs/israel/innovation/FV_xis_Innovation_Redeem.swf";
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
         var rewardXMLList:XMLList = this.m_rewardsBySlotName[index].reward;
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
               FarmStatsManager.count("IsraelInnovation","PerformTask",this.currentDayIndex.toString(),tasks[i].questName,featureData[this.KEY_DAY_POINTS].toString(),"",tasks[i].questPoints);
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
                  FarmStatsManager.count("IsraelInnovation","PerformTask",this.currentDayIndex.toString(),tasks[i].type,featureData[this.KEY_DAY_POINTS].toString(),"",tasks[i].questPoints);
               }
            }
         }
         if(hasUpdatedProgress)
         {
            this.saveProgressForPlayer(progressArray);
         }
         if(hasCompletedTask)
         {
            if(this.m_israelInnovationHud)
            {
               this.m_israelInnovationHud.refresh(1);
            }
         }
      }
      
      public function updateOrderboardCount() : void
      {
         var cgProgress:int = 0;
         var cgTaskArray:Array = this.getCommunityGoalActiveTaskList();
         var cgTask:IsraelInnovationCommunityGoalTask = cgTaskArray[0];
         if(cgTask)
         {
            cgProgress = this.getOrderboardTaskCount();
            if(cgProgress > 0)
            {
               this.addCommGoalTaskCountForPlayer(cgTask.name,1);
            }
         }
      }
      
      public function updateViralAskCount() : void
      {
         var cgProgress:int = 0;
         var cgTaskArray:Array = this.getCommunityGoalActiveTaskList();
         var cgTask:IsraelInnovationCommunityGoalTask = cgTaskArray[1];
         if(cgTask)
         {
            cgProgress = this.getViralAskCount();
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
               buildingName = "xis_elitehorses";
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
      
      public function getViralAskCount() : int
      {
         var count:int = 0;
         var featureData:Object = this.getFeatureData();
         if(featureData.hasOwnProperty(this.KEY_VIRAL_ASK_COUNT))
         {
            count = int(featureData[this.KEY_VIRAL_ASK_COUNT]);
         }
         return count;
      }
      
      public function getWeekPoints() : int
      {
         var weekPoints:int = 0;
         var featureData:Object = this.getFeatureData();
         if(featureData.hasOwnProperty(this.KEY_WEEK_POINTS))
         {
            weekPoints = int(featureData[this.KEY_WEEK_POINTS]);
         }
         return weekPoints;
      }
      
      public function getUserState() : int
      {
         var featureObj:Object = this.getFeatureData();
         return featureObj[this.KEY_USER_STATE] as int;
      }
      
      public function grantUserRewardforLevel(level:int) : void
      {
         FarmStatsManager.count("IsraelInnovation","MileStoneCompletion",this.currentDayIndex.toString(),this.EASY.toString());
         UserRewardUtil.grantUserReward(this.getRewardsForTheDay()[level]);
         this.mainWindow.playJumpAnimation();
      }
      
      public function grantFarmOffChip(quantity:int) : void
      {
         FeatureOptionsInventoryManager.getInstance().addCount(this.ChipCode,quantity);
         if(this.m_mainWindow)
         {
            this.m_mainWindow.updateFarmOffChipDoober(quantity);
            this.m_mainWindow.updateFarmOffChipCount();
         }
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
         var activeInd:int = 0;
         var i:int = 0;
         var featureData:Object = this.getFeatureData();
         if(this.hasActiveDayExpired() == true || featureData[this.KEY_USER_STATE] == this.NOT_INITIALIZED)
         {
            this.mainWindow.updateActiveDayIndex();
            if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ISRAEL) == false)
            {
               if(featureData.hasOwnProperty(KEY_GA_FEATURE_START) && featureData[KEY_GA_FEATURE_START] == false)
               {
                  featureData[KEY_GA_FEATURE_START] = true;
               }
            }
            this.redeemHasStarted = false;
            if(Boolean(this.m_mainWindow) && featureData[this.KEY_USER_STATE] == this.NOT_INITIALIZED)
            {
               this.m_mainWindow.closeFirstSessionStartMC();
            }
            if(this.hasActiveDayExpired())
            {
               featureData[this.KEY_DAILY_PROGRESS_POINTS][this.activeDayIndex] = featureData[this.KEY_DAY_POINTS] > this.VAL_THIRD_MILESTONE ? this.VAL_THIRD_MILESTONE : featureData[this.KEY_DAY_POINTS];
            }
            this.updateEAWeekPoints();
            this.updateEALeaderboardPoints();
            if(featureData.hasOwnProperty(KEY_CURRENT_WEEK) && featureData[KEY_CURRENT_WEEK] == 0)
            {
               featureData[KEY_CURRENT_WEEK] = this.getCurrentWeek().count;
            }
            else if(this.hasActiveWeekExpired())
            {
               activeInd = this.activeDayIndex / 7;
               featureData[this.KEY_WEEKLY_PROGRESS_POINTS][activeInd] = featureData[this.KEY_WEEK_POINTS];
               featureData[this.KEY_WEEK_POINTS] = 0;
               featureData[this.KEY_ORDERBOARD_COUNT] = 0;
               featureData[this.KEY_VIRAL_ASK_COUNT] = 0;
               featureData[KEY_WEEKLY_REWARD_EASY_GRANTED] = false;
               featureData[KEY_WEEKLY_REWARD_MEDIUM_GRANTED] = false;
               featureData[KEY_WEEKLY_REWARD_HARD_GRANTED] = false;
               featureData[KEY_WEEKLY_REWARD_FINAL_GRANTED] = false;
               featureData[KEY_CURRENT_WEEK] = this.getCurrentWeek().count;
            }
            featureData[this.KEY_ACTIVE_DAY_TIMESTAMP] = FarmGameUtil.getMidnightTimestamp() / 1000;
            featureData[KEY_DAILY_RESET_DONE] = true;
            this.m_mainWindow.displayFarmOffOverlay();
            this.mainWindow.updateActiveDayIndex();
            if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ISRAEL))
            {
               if(WorldSeasonsManager.getInstance().isEAWeek(WorldsConstants.WORLD_ID_ISRAEL))
               {
                  featureData[this.KEY_DAY_POINTS] = this.VAL_FIRST_MILESTONE;
                  featureData[this.KEY_USER_STATE] = this.MEDIUM;
                  featureData[this.KEY_WEEK_POINTS] += this.VAL_FIRST_MILESTONE;
                  featureData[this.WEEKLY_SCORE] += this.VAL_FIRST_MILESTONE;
                  this.checkAndUpdateWeeklyStatus();
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
            if(this.activeDayIndex >= 35)
            {
               featureData[this.KEY_FEATURE_ENDED] = 1;
               setFeatureData(featureData);
               if(this.m_mainWindow)
               {
                  this.m_mainWindow.close();
               }
               this.grantBonusReward();
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
               featureData[KEY_FLUSH_DAILY_REWARD_TASK] = 0;
               this.m_mainWindow.refreshWindow();
               this.m_mainWindow.updateLeaderBoardFrame(featureData[this.WEEKLY_SCORE]);
            }
            FarmStatsManager.count("IsraelInnovation","startNewDay",this.chipCount.toString(),this.overAllProgressLevel().toString(),this.currentAverage.toString(),featureData[this.KEY_WEEK_POINTS],this.getCurrentWeek().count);
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
      
      public function updateEAWeekPoints() : void
      {
         var activeDayInd:int = 0;
         var curDayInd:int = 0;
         var featureData:Object = this.getFeatureData();
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ISRAEL) == true)
         {
            activeDayInd = this.activeDayIndex;
            curDayInd = this.currentDayIndex;
            if(curDayInd >= 7)
            {
               curDayInd = 7;
            }
            if(activeDayInd < 7)
            {
               if(curDayInd - activeDayInd > 1)
               {
                  if(activeDayInd == 0)
                  {
                     if(featureData[this.KEY_WEEK_POINTS] == 0)
                     {
                        featureData[this.KEY_WEEK_POINTS] += (curDayInd - activeDayInd) * this.VAL_FIRST_MILESTONE;
                     }
                     else
                     {
                        featureData[this.KEY_WEEK_POINTS] += (curDayInd - activeDayInd - 1) * this.VAL_FIRST_MILESTONE;
                     }
                  }
                  else
                  {
                     featureData[this.KEY_WEEK_POINTS] += (curDayInd - activeDayInd - 1) * this.VAL_FIRST_MILESTONE;
                  }
                  setFeatureData(featureData);
                  this.checkAndUpdateWeeklyStatus();
               }
            }
         }
      }
      
      public function updateEALeaderboardPoints() : void
      {
         var activeDayInd:int = 0;
         var curDayInd:int = 0;
         var featureData:Object = this.getFeatureData();
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ISRAEL) == true)
         {
            activeDayInd = this.activeDayIndex;
            curDayInd = this.currentDayIndex;
            if(curDayInd < 7)
            {
               if(curDayInd - activeDayInd > 1)
               {
                  if(activeDayInd == 0)
                  {
                     if(featureData[this.WEEKLY_SCORE] == 0)
                     {
                        featureData[this.WEEKLY_SCORE] += (curDayInd - activeDayInd) * this.VAL_FIRST_MILESTONE;
                     }
                     else
                     {
                        featureData[this.WEEKLY_SCORE] += (curDayInd - activeDayInd - 1) * this.VAL_FIRST_MILESTONE;
                     }
                  }
                  else
                  {
                     featureData[this.WEEKLY_SCORE] += (curDayInd - activeDayInd - 1) * this.VAL_FIRST_MILESTONE;
                  }
                  setFeatureData(featureData);
               }
            }
         }
      }
      
      public function get consumableCount() : Number
      {
         return int(FeatureOptionsInventoryManager.getInstance().getCount(this.ConsumableCode));
      }
      
      public function get chipCount() : Number
      {
         return int(FeatureOptionsInventoryManager.getInstance().getCount(this.ChipCode));
      }
      
      public function get chipItem() : FarmItem
      {
         return Global.farmGameSettingsManager.getFarmItemByCode(this.ChipCode);
      }
      
      public function collectFarmOffChip() : void
      {
         var featureData:Object = this.getFeatureData();
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ISRAEL) == true && this.currentDayIndex < 7)
         {
            this.grantFarmOffChip(2);
         }
         else
         {
            this.grantFarmOffChip(1);
         }
         if(featureData.hasOwnProperty(KEY_DAILY_CHIP_GRANTED))
         {
            featureData[KEY_DAILY_CHIP_GRANTED] = true;
            setFeatureData(featureData);
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"collectFarmOffChip",null,[m_featureName]),true);
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
      
      public function isWeeklyMilestoneAchievedForLevel(level:int) : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(featureData[this.KEY_WEEK_POINTS] >= this.VAL_WEEK_MILESTONE_POINTS_ARRAY[level])
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
         var LeaderBoardData:Object = this.getCurrentLeaderboard();
         if(LeaderBoardData == null)
         {
            return -1;
         }
         var leaderBoardExpiredTimeInString:String = LeaderBoardData.end;
         var leaderBoardExpiredTime:Number = FarmGameUtil.synchronizedDateTimeToNumber(leaderBoardExpiredTimeInString) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return leaderBoardExpiredTime - currenttime;
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
                  msg = "Collect more Bundles of Plenty to unlock the next level.";
               }
               else
               {
                  msg = "Use Bundles of Plenty to unlock the next level.";
               }
            }
         }
         return msg;
      }
      
      public function overAllProgressLevel() : int
      {
         var progressLevel:int = -1;
         var totalDaysForAvg:int = this.currentDayIndex > 34 ? 34 : this.currentDayIndex;
         var totalWeekForAvg:int = totalDaysForAvg / 7 + 1;
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ISRAEL) == false)
         {
            if(totalWeekForAvg > 1)
            {
               totalWeekForAvg--;
            }
         }
         var avg:int = this.getTotalWeeklyPointsForUser() / totalWeekForAvg;
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
         var totalDaysForAvg:int = this.currentDayIndex > 34 ? 34 : this.currentDayIndex;
         var totalWeekForAvg:int = totalDaysForAvg / 7 + 1;
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ISRAEL) == false)
         {
            if(totalWeekForAvg > 1)
            {
               totalWeekForAvg--;
            }
         }
         return int(this.getTotalWeeklyPointsForUser() / totalWeekForAvg);
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
            totalPoints += int(featureData[this.KEY_DAY_POINTS]) > this.VAL_THIRD_MILESTONE ? this.VAL_THIRD_MILESTONE : featureData[this.KEY_DAY_POINTS];
         }
         return totalPoints;
      }
      
      public function getTotalWeeklyPointsForUser() : int
      {
         var totalWeekPoints:int = 0;
         var featureData:Object = this.getFeatureData();
         var activeWeek:int = this.activeDayIndex / 7;
         for(var index:int = 0; index < activeWeek; index++)
         {
            if(featureData[this.KEY_WEEKLY_PROGRESS_POINTS].hasOwnProperty(index))
            {
               totalWeekPoints += int(featureData[this.KEY_WEEKLY_PROGRESS_POINTS][index]);
            }
         }
         if(featureData.hasOwnProperty(this.KEY_WEEK_POINTS))
         {
            totalWeekPoints += int(featureData[this.KEY_WEEK_POINTS]);
         }
         return totalWeekPoints;
      }
      
      public function openRewardViewWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         this.m_rewardWindow = new IsraelInnovationRewardWindow(m_featureName,this.rewardWindowURL);
         UI.displayPopup(this.m_rewardWindow,false);
         FarmStatsManager.count(m_featureName,"Click","Farm-off-chips");
      }
      
      public function openLandBundleBWindow() : void
      {
         this.closeMainWindow();
         this.m_landBundleWindow = new IsraelLandBundleWindow(m_featureName);
         UI.displayPopup(this.m_landBundleWindow,false);
      }
      
      public function openRewardMarketWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         this.m_rewardMarketWindow = new IsraelInnovationRewardsMarketWindow(m_featureName,this.m_mainWindow);
         UI.displayPopup(this.m_rewardMarketWindow,false);
      }
      
      public function openCommunityGoalsWindow(showReward:Boolean = false) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         var activeTaskList:Array = this.getCommunityGoalActiveTaskList();
         this.m_communityGoalWindow = new IsraelInnovationCommunityGoalWindow("assets/dialogs/israel/innovation/FV_xis_Innovation_CommunityGoals.swf",m_featureName,this.m_mainWindow,activeTaskList,showReward);
         UI.displayPopup(this.m_communityGoalWindow,false);
         FarmStatsManager.count(m_featureName,"Click","Farmoffcommunity");
      }
      
      public function openFeatureExpiredWindow() : void
      {
         this.m_finalRewardWindow = new IsraelInnovationFinalRewardWindow(m_featureName,this.featureEndWindowURL);
         UI.displayPopup(this.m_finalRewardWindow,false);
         if(this.m_leaderboardWindow)
         {
            this.m_leaderboardWindow.tintWindow();
            this.m_leaderboardWindow.enableInput = false;
         }
         FarmStatsManager.count(m_featureName,"feature_ui","reward_ui","impression");
      }
      
      public function get mainWindow() : IsraelInnovationMainWindow
      {
         return this.m_mainWindow;
      }
      
      public function get activeDayIndex() : int
      {
         var dayIndex:int = 0;
         var featureData:Object = this.getFeatureData();
         var activeDayTS:Number = featureData[this.KEY_ACTIVE_DAY_TIMESTAMP] as Number;
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("09/03/2018") / FarmGameUtil.NUM_MSECS_IN_SECOND;
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
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("09/03/2018");
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
         this.showLeaderboardRewardPopup();
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
      
      public function getPointsForTheWeek(index:int) : int
      {
         var points:int = 0;
         var featureData:Object = this.getFeatureData();
         if(featureData[this.KEY_WEEKLY_PROGRESS_POINTS].hasOwnProperty(index.toString()))
         {
            points = int(featureData[this.KEY_WEEKLY_PROGRESS_POINTS][index.toString()]);
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
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("israel_innovation_bonus_enabled");
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
            UI.displayPopup(new IsraelInnovationPostBonusHarvestWindow("assets/dialogs/expansion/FV_RewardDialog.swf",featureName,bonusItem,harvestFarmItem,null,"assets/dialogs/israel/RewardDialog.png",count));
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
      
      public function set mainWindow(mainWindowInstance:IsraelInnovationMainWindow) : void
      {
         this.m_mainWindow = mainWindowInstance;
      }
      
      public function playForLeaderBoard() : void
      {
         var i:int = 0;
         var featureData:Object = this.getFeatureData();
         if(featureData[KEY_SHOW_LEADERBOARD_FIRST_TIME_IN_WEEK] == 1)
         {
            this.showLeaderboardUI();
            featureData[KEY_SHOW_LEADERBOARD_FIRST_TIME_IN_WEEK] = 0;
            setFeatureData(featureData);
         }
         if(featureData[KEY_FLUSH_DAILY_REWARD_TASK] == 0)
         {
            featureData[KEY_FLUSH_DAILY_REWARD_TASK] = 1;
            for(i = 0; i < 4; i++)
            {
               this.generateAndSaveNewTask(i);
               featureData = this.getFeatureData();
               featureData[KEY_SAVED_ACTIVE_TASKS][i][this.KEY_DUMPED_STATUS] = 0;
               setFeatureData(featureData);
            }
            this.m_mainWindow.refreshWindow();
            FarmStatsManager.count(m_featureName,"Leaderboard","start");
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"playForLeaderBoard",null,[m_featureName]),true);
         }
      }
      
      public function getDayEndMessageShown() : int
      {
         var featureData:Object = this.getFeatureData();
         return featureData[KEY_FLUSH_DAILY_REWARD_TASK];
      }
      
      public function initializeLeaderBoardProgress(isSync:Boolean = false) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getLeaderboardEntries",this.getLeaderboardEntries,[m_featureName,isSync]));
      }
      
      public function getLeaderboardEntries(result:Object = null) : void
      {
         var collectionData:Object = null;
         var giftLeaderboardRank:Number = NaN;
         var giftLeaderboardName:String = null;
         var giftKey:String = null;
         var gifts:Array = null;
         var giftName:String = null;
         var weeklyLeaderboardData:Object = null;
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
               weeklyLeaderboardData = this.getCurrentLeaderboard();
               if(weeklyLeaderboardData)
               {
                  collectionData[KEY_CURRENT_LEADERBOARD] = weeklyLeaderboardData.name;
               }
               collectionData[KEY_SAVED_LEADERBOARD_RESULT] = result["userData"];
               collectionData[giftKey] = true;
               collectionData[this.WEEKLY_SCORE] = 0;
            }
            if(Boolean(this.m_leaderboardWindow) && result["syncMainUI"] == false)
            {
               this.m_leaderboardWindow.populateLeaderboard(result,giftLeaderboardRank,giftLeaderboardName);
            }
            else if(result["CommunityData"])
            {
               this.checkCommunityRewards(result["CommunityData"]);
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
      
      public function initializeCommGoalLeaderboard1() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getCommLeaderboardEntries",this.getCommLeaderboardEntries1,[m_featureName,1]));
      }
      
      public function initializeCommGoalLeaderboard2() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getCommLeaderboardEntries",this.getCommLeaderboardEntries2,[m_featureName,2]));
      }
      
      public function getCommLeaderboardEntries1(result:Object = null) : void
      {
         if(result != null)
         {
            if(this.m_communityGoalWindow)
            {
               this.m_communityGoalWindow.updateProfile1(result);
            }
         }
      }
      
      public function getCommLeaderboardEntries2(result:Object = null) : void
      {
         if(result != null)
         {
            if(this.m_communityGoalWindow)
            {
               this.m_communityGoalWindow.updateProfile2(result);
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
               if(this.hasActiveDayExpired())
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
         var activeTaskList:Array = null;
         var task:IsraelInnovationCommunityGoalTask = null;
         var ind:int = 0;
         var i:int = 0;
         var rewardDialogAsset:String = null;
         var rewardBgAsset:String = null;
         if(this.m_communityRewardsEarned)
         {
            rewardXMLs = new Array();
            taskList = this.getCommunityGoalTaskList();
            activeTaskList = this.getCommunityGoalActiveTaskList();
            if(taskList)
            {
               for each(task in taskList)
               {
                  if(this.m_communityRewardsEarned[task.name])
                  {
                     rewardXMLs.push(task.rewards);
                     this.grantCommunityGoalReward(task.rewards);
                     this.setCommGoalRewardGrantedForStage(task.name,1);
                     FarmStatsManager.count(m_featureName,"reward",task.name,this.m_communityRewardsEarned[task.name]);
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
                     rewardDialogAsset = null;
                     if(activeTaskList[i] != null)
                     {
                        if(this.m_communityRewardsEarned[activeTaskList[i].name])
                        {
                           rewardDialogAsset = activeTaskList[i].getAssetPathFor("congratsDialog");
                           rewardBgAsset = activeTaskList[i].getAssetPathFor("congratsDialogBackground");
                           if(this.m_communityGoalWindow)
                           {
                              this.m_communityGoalWindow.tintWindow();
                              this.m_communityGoalWindow.enableInput = false;
                           }
                           this.m_commRewardWindow = new IsraelCommunityGoalsRewardWindow(activeTaskList,rewardXMLs[ind],m_featureName,i + 1);
                           UI.displayPopup(this.m_commRewardWindow,false);
                           ind++;
                        }
                     }
                  }
               }
            }
         }
      }
      
      public function displayPreviousCommunityRewardDialog() : void
      {
         var rewardXMLs:Array = null;
         var taskList:Array = null;
         var activeTaskList:Array = null;
         var task:IsraelInnovationCommunityGoalTask = null;
         var ind:int = 0;
         var i:int = 0;
         var rewardDialogAsset:String = null;
         if(this.m_communityRewardsEarned)
         {
            rewardXMLs = new Array();
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
                     rewardDialogAsset = null;
                     if(activeTaskList[i] != null)
                     {
                        if(this.m_communityRewardsEarned[activeTaskList[i].name])
                        {
                           if(this.mainWindow)
                           {
                              this.mainWindow.tintWindow();
                              this.mainWindow.enableInput = false;
                           }
                           this.m_commRewardWindow = new IsraelCommunityGoalsRewardWindow(activeTaskList,rewardXMLs[ind],m_featureName,i + 1,true);
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
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("10/21/2018") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         timeLeft = endTime - now;
         if(timeLeft <= 0)
         {
            result = true;
         }
         return result;
      }
      
      public function getUserDataFromLeaderboard() : Object
      {
         var featureData:Object = this.getFeatureData();
         return featureData[KEY_SAVED_LEADERBOARD_RESULT];
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
      
      public function getCurrentWeek() : Object
      {
         var startDate:Number = NaN;
         var endDate:Number = NaN;
         var weekXML:XML = null;
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
      
      public function getLeaderboardData() : Array
      {
         return this.m_staticData.leaderboardConfigData;
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
      
      public function getWeeklyRewardPoints() : int
      {
         var featureData:Object = this.getFeatureData();
         return featureData[this.WEEKLY_SCORE];
      }
      
      public function leaderboardCallback() : void
      {
         this.m_leaderboardWindow = null;
      }
      
      public function isDailyChipGranted() : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(featureData.hasOwnProperty(KEY_DAILY_CHIP_GRANTED) && featureData[KEY_DAILY_CHIP_GRANTED] == true)
         {
            result = true;
         }
         return result;
      }
      
      public function resetDailyChipStatus() : void
      {
         var featureData:Object = this.getFeatureData();
         if(featureData.hasOwnProperty(KEY_DAILY_RESET_DONE) && featureData[KEY_DAILY_RESET_DONE] == true)
         {
            if(featureData.hasOwnProperty(KEY_DAILY_CHIP_GRANTED) && featureData[KEY_DAILY_CHIP_GRANTED] == true)
            {
               featureData[KEY_DAILY_RESET_DONE] = false;
               featureData[KEY_DAILY_CHIP_GRANTED] = false;
               setFeatureData(featureData);
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"resetDailyChipStatus",null,[m_featureName]),true);
            }
         }
      }
      
      public function isDailyResetDone() : Boolean
      {
         var featureData:Object = this.getFeatureData();
         var result:Boolean = false;
         if(featureData.hasOwnProperty(KEY_DAILY_RESET_DONE) && featureData[KEY_DAILY_RESET_DONE] == true)
         {
            result = true;
         }
         return result;
      }
      
      public function isLandBundleRewardGranted() : Boolean
      {
         var featureData:Object = this.getFeatureData();
         var result:Boolean = false;
         if(featureData.hasOwnProperty(KEY_LANDBUNDLE_REWARD) && featureData[KEY_LANDBUNDLE_REWARD] == true)
         {
            result = true;
         }
         return result;
      }
      
      public function isLandbundleActive() : Boolean
      {
         var landBundleUnlockDate:String = "09/17/2018";
         var landBundleEndDate:String = "09/27/2018";
         var startTimeStamp:Number = FarmGameUtil.synchronizedDateToNumber(landBundleUnlockDate) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var endTimeStamp:Number = FarmGameUtil.synchronizedDateToNumber(landBundleEndDate) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return startTimeStamp < currentTime && currentTime < endTimeStamp;
      }
      
      public function isLandBundleUnlocked() : Boolean
      {
         return Global.player.getSeenFlag(ISRAEL_LAND_BUNDLE_UNLOCKED);
      }
      
      public function grantLandBundleReward() : void
      {
         var featureData:Object = this.getFeatureData();
         this.grantFarmOffChip(20);
         featureData[KEY_LANDBUNDLE_REWARD] = true;
         setFeatureData(featureData);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"grantLandBundleReward",null,[m_featureName]),true);
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
         var cgTask:IsraelInnovationCommunityGoalTask = null;
         var task:XML = null;
         var result:Array = new Array();
         var communityGoalData:Object = this.getCommunityGoalData();
         if(communityGoalData)
         {
            for each(task in communityGoalData)
            {
               cgTask = new IsraelInnovationCommunityGoalTask(task);
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
      
      public function getCommunityGoalActiveTask() : IsraelInnovationCommunityGoalTask
      {
         var result:IsraelInnovationCommunityGoalTask = null;
         var task:IsraelInnovationCommunityGoalTask = null;
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
      
      public function getCommunityGoalActiveTaskList() : Array
      {
         var result:IsraelInnovationCommunityGoalTask = null;
         var task:IsraelInnovationCommunityGoalTask = null;
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
         var result:IsraelInnovationCommunityGoalTask = null;
         var task:IsraelInnovationCommunityGoalTask = null;
         var taskList:Array = this.getCommunityGoalTaskList();
         var taskArray:Array = new Array();
         var featureData:Object = this.getFeatureData();
         var weekNo:int = int(featureData[KEY_CURRENT_WEEK]);
         if(taskList)
         {
            for each(task in taskList)
            {
               if(task.name == "israelInnovationOrderboardTaskWeek" + weekNo.toString() || task.name == "israelInnovationViralTaskWeek" + weekNo.toString())
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
         if(Boolean(featureData) && Boolean(featureData.hasOwnProperty(taskName)) && Boolean(featureData[taskName][KEY_COMMUNITY_REWARDS]))
         {
            featureData[taskName][KEY_COMMUNITY_REWARDS] = 1;
            setFeatureData(featureData);
         }
      }
      
      public function getCommunityProgressForTask(taskName:String, callback:Function = null) : void
      {
         var activeTask:IsraelInnovationCommunityGoalTask = null;
         var activeTaskList:Array = this.getCommunityGoalActiveTaskList();
         if(activeTaskList)
         {
            for each(activeTask in activeTaskList)
            {
               if(activeTask.name == taskName)
               {
                  TransactionManager.addTransaction(new TIsraelCommunityGoalsGetProgress(activeTask,callback),true);
               }
            }
         }
      }
      
      public function isTestingMode() : Boolean
      {
         var result:Boolean = false;
         if(Boolean(Global.flashHotParams[ISRAEL_COMMUNITY_GOALS_TESTING_FLAG]) && Global.flashHotParams[ISRAEL_COMMUNITY_GOALS_TESTING_FLAG] == true)
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
            if(Global.flashHotParams.hasOwnProperty(ISRAEL_COMMUNITY_GOALS_TASK_DATA))
            {
               dataObj = FarmGameUtil.JSONDecode(Global.flashHotParams[ISRAEL_COMMUNITY_GOALS_TASK_DATA].toString(),"IsraelInnovationManager_getRuntimeTaskData");
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

