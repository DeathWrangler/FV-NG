package Managers.OrderBoard
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.ArrowType;
   import Classes.Constants.QuestConstants;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureBuilding;
   import Classes.FeedData;
   import Classes.MapTrigger;
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.HUD.HUD;
   import Display.HUD.HUDWidgets.HudBottomIrelandInnovationButton;
   import Display.QueuedIcons.QueuedIconWithArrow;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.TileUnlockEvent;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.FeatureOptionsManager;
   import Managers.ItemFinderManager;
   import Managers.MapTriggerManager;
   import Managers.WorldSeasonsManager;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.CasablancaGenericSingleRewardPopup;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.GenericSingleRewardPopup;
   import Widgets.Windows.IrelandInnovationBuildingUpgradeWindow;
   import Widgets.Windows.IrelandInnovationBuyWindow;
   import Widgets.Windows.IrelandInnovationLeaderboardWindow;
   import Widgets.Windows.IrelandInnovationMainWindow;
   import Widgets.Windows.IrelandInnovationMilestoneRewardWindow;
   import Widgets.Windows.IrelandInnovationPostBonusHarvestWindow;
   import Widgets.Windows.IrelandInnovationRewardWindow;
   import Widgets.Windows.IrelandInnovationTileUnlockwindow;
   import flash.events.Event;
   
   public class IrelandInnovationManager extends SpecialQuestManager
   {
      
      private static const SERVICE_NAME:String = "IrelandInnovationService";
      
      private static const HUD_ASSET:String = "assets/dialogs/ireland/Innovation/FV_xid_hud_Innovation.swf";
      
      private static const KEY_IS_LB_ORDERBOARD_INITIALIZED:String = "lb_init";
      
      private static const KEY_SAVED_ACTIVE_TASKS:String = "1";
      
      private static const KEY_SAVED_LB_ACTIVE_TASKS:String = "lb1";
      
      private static const KEY_TILE_UNLOCK_COUNT:String = "tile_unlock_count";
      
      public static const BRAZIL_TILE_LIST:Array = new Array("xca_rubbletreasure1","xca_rubbletreasure2","xca_rubbletreasure3","xca_rubbletreasure4","xca_rubbletreasure5","xca_rubbletreasure6","xca_rubbletreasure7","xca_rubbletreasure8","xca_rubbletreasure9","xca_rubbletreasure_payer1","xca_rubbletreasure_payer2","xca_rubbletreasure_payer3","xca_rubbletreasure_payer4","xca_rubbletreasure_payer5","xca_rubbletreasure_payer6","xca_rubbletreasure_payer7","xca_rubbletreasure_payer8","xca_rubbletreasure_payer9","xca_rubbletreasure_payer10","xca_rubbletreasure_payer11","xca_rubbletreasure_payer12","xca_rubbletreasure_payer13","xca_rubbletreasure_payer14","xca_rubbletreasure_payer15","xca_rubbletreasure_payer16","xca_rubbletreasure_payer17","xca_rubbletreasure_payer18","xca_rubbletreasure_payer19","xca_rubbletreasure_payer20","xca_rubbletreasure_payer21","xca_rubbletreasure_payer22","xca_rubbletreasure_payer23");
      
      private static const BONUS_COUNT_MAP:Array = [0,3,4,5,6,6];
      
      private static const FEATURE_SET_FINAL_REWARD:* = "final_reward_grant_flag2";
      
      private static const KEY_SAVED_DUMPED_TIMESTAMP:String = "3";
      
      private static const KEY_SAVED_LB_DUMPED_TIMESTAMP:String = "lb3";
      
      private static const KEY_NPC_MOVEMENTS:String = "4";
      
      private static const KEY_SAVED_FEATURE_SHOWN_TIMESTAMP:String = "10";
      
      public static const KEY_SAVED_FINAL_REWARD_RECEIVED:String = "k11";
      
      public static const KEY_SAVED_FINAL_REWARD_BUILDINGNAME:String = "reward_building";
      
      public static const FEATURE_TRACKING:String = "IrelandInnovation";
      
      public static const EVENT_IRELAND_INNOVATION_TILE_UNLOCK:String = "IrelandInnovationTileUnlock";
      
      private static const KEY_SAVED_BOARD_COUNT:String = "21";
      
      public static const VAL_FINAL_MILESTONE:int = 1100;
      
      private static const SKIP_COST:int = 1;
      
      private static const WINDOW_MAIN:String = "main";
      
      private static const TILE_UNLOCK_COUNT:String = "tuc";
      
      public static const DEFAULT_COLLECT_THROTTLE_TIME:int = 86400;
      
      public static const DEFAULT_HARVEST_THROTTLE_TIME:int = 86400;
      
      private static const HUD_CASABLANCA_ASSET:String = "assets/dialogs/casablanca/innovation/FV_xca_hud_Innovation.swf";
      
      public static const FTUE_SEEN_FLAG:String = "CasablancaInnovation_Tutorial";
      
      private static const LAST_BONUS_HARVEST_TIME_KEY:String = "Last_bonus_harvest_time";
      
      public static const HUD_INITIALISATION_FLAG:String = "ireland_innovation_hud_initialise_flag";
      
      private static const HUD_IRELAND_ASSET:String = "assets/dialogs/ireland/Innovation/FV_xid_hud_Innovation.swf";
      
      public static const FEATURE_NAME:String = "IrelandInnovation";
      
      private static const WINDOW_REWARD:String = "reward";
      
      private static const WINDOW_CONGRATS:String = "congrats";
      
      private static const WINDOW_BUY:String = "buyDialog";
      
      public static const COLLECT_TIME_KEY:String = "ctk";
      
      public static const FEED_NAME:String = "IrelandInnovationUI";
      
      public static const FEATURE_OPTIONS_KEY:String = "IrelandInnovation";
      
      public static const KEY_GA_FEATURE_START:String = "ga_ireland_innovation_start";
      
      private static var m_initialized:Boolean = false;
      
      private static const KEY_FLUSH_DAILY_REWARD_TASK:String = "flush_daily_reward_tasks";
      
      private static const KEY_CURRENT_WEEK:String = "currentweek";
      
      private static const KEY_SHOW_LEADERBOARD_FIRST_TIME_IN_WEEK:String = "ireland_weekly_show_leaderboard_first_time";
      
      private static const KEY_SAVED_LEADERBOARD_RESULT:String = "leaderboard_data";
      
      private static const KEY_CURRENT_LEADERBOARD:String = "currentLeaderboard";
      
      public static const IRELAND_TILE_UNLOCK_COUNT:String = "e8kb";
      
      public static const EA_CONSUMABLE_GRANT_FLAG:String = "ea_consumable_grant_flag";
      
      private static const BONUS_NAME_ARRAY:Array = ["Baron Villa","Viscount Bunglow","Earl\'s Mansion","Duke\'s Abode","King\'s Castle"];
      
      private static const CRAFTSHOP_CONSUMABLE_TAB:String = "consumable";
      
      public static const KEY_MILESTONE_LEVEL:* = "milestone_level";
      
      private var m_isEA:Boolean;
      
      private var m_hud:QueuedIconWithArrow;
      
      private var m_newHud:HudBottomIrelandInnovationButton;
      
      private var m_currencyName:String = "task_points";
      
      private var m_endTimeStamp:Number = 0;
      
      private var m_tasksById:Object = null;
      
      private var m_LBtasksById:Object = null;
      
      private var m_assetPaths:Object = {};
      
      private var m_eaRewards:Array = new Array();
      
      private var m_gaRewards:Array = new Array();
      
      private var m_lastMilestoneRewards:Array = new Array();
      
      private var m_finalRewards:Array = new Array();
      
      private var m_feedConfig:Object = {};
      
      private var BONUS_HARVEST_ARRAY_OLD:Object = {
         "1":["fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard"],
         "2":["fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard"],
         "3":["fuel1","vehiclepart","pkg_xwx_treasureparts","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard"],
         "4":["consume_instagrow","consume_turbo_charger","consume_unwither","consume_organic_fertilizer","fuel1","vehiclepart","pkg_xwx_treasureparts","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard"],
         "5":["consume_instagrow","consume_turbo_charger","consume_unwither","consume_organic_fertilizer","fuel1","vehiclepart","pkg_xwx_treasureparts","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard"]
      };
      
      private var BONUS_HARVEST_ARRAY:Object = {
         "1":["consume_organic_fertilizer","consume_unwither","consume_farm_hands"],
         "2":["consume_organic_fertilizer","consume_unwither","consume_farm_hands","fuel1"],
         "3":["consume_organic_fertilizer","consume_unwither","consume_farm_hands","fuel1","consume_instagrow"],
         "4":["consume_organic_fertilizer","consume_unwither","consume_farm_hands","fuel1","consume_instagrow","consume_turbo_charger"],
         "5":["consume_organic_fertilizer","consume_unwither","consume_farm_hands","fuel1","consume_instagrow","consume_turbo_charger"]
      };
      
      private const BONUS_HARVEST_COUNT:String = "hc";
      
      private const HARVEST_MULTIPLE_ARRAY:Array = ["consume_organic_fertilizer","consume_unwither"];
      
      private const LB_IRELAND_ORDERBOARD:String = "IrelandInnovationLB";
      
      private const SERVICE_FUNC_SET_FINAL_REWARD_GRANT:String = "setFinalRewardGrantFlag";
      
      public const PLAY_FOR_LB_ONLY_FLAG:String = "irelandInnovationLBOnly";
      
      public const KEY_FEATURE_FINISHED_TIME:String = "31";
      
      public const KEY_ACTIVE_DAY_TIMESTAMP:String = "ts";
      
      public const KEY_DAY_POINTS:String = "dp";
      
      private const KEY_TASK_ID:String = "id";
      
      public const KEY_DAY_REWARD_GRANT_STATUS:String = "34";
      
      private const SERVICE_FUNC_HARVEST_BONUS:String = "harvestBonusBuilding";
      
      protected const KEY_ID:String = "id";
      
      protected const KEY_PROGRESS:String = "progress";
      
      protected const KEY_TOTAL:String = "total";
      
      public const TILE_UNLOCK_POINTS:Number = 30;
      
      private var m_rewardWindow:IrelandInnovationRewardWindow;
      
      private var m_buildingUpgradeRewardWindow:CasablancaGenericSingleRewardPopup;
      
      private var m_rewardName:String;
      
      private var m_resultObject:Object;
      
      private var m_redeemResultObject:Object;
      
      private var m_isActive:Boolean = false;
      
      protected var m_owner:FeatureBuilding;
      
      private var m_IrelandInnovationHud:HudBottomIrelandInnovationButton;
      
      private var m_showRedeemCallout:Boolean = false;
      
      public const TILE_UNLOCK:String = "Ireland_Tile_Unlock";
      
      public const FIRST_TIME_UNLOCK:String = "Ireland_First_tile_Unlock";
      
      public const LEAGUE_OVERLAY_FLAG:String = "Ireland_League_Overlay";
      
      private const WEEKLY_SCORE:String = "weekly_score";
      
      private var m_cachedTaskData:Object;
      
      private const KEY_ORDERBOARD_COUNT:String = "orderboard_task_count";
      
      public const KEY_BUILDING_LEVEL:String = "building_level";
      
      private const KEY_BONUS_REWARD_CLAIMED:* = "xid_bonus";
      
      public const DEFAULT_THROTTLE_TIME:Number = 86400;
      
      protected var m_staticData:Object;
      
      public var m_mainWindow:IrelandInnovationMainWindow;
      
      private var m_rewardPopup:GenericSingleRewardPopup;
      
      private var m_buyWindow:IrelandInnovationBuyWindow;
      
      public var m_leaderboardWindow:IrelandInnovationLeaderboardWindow;
      
      private var m_CgTaskList:Array;
      
      private const QUEST_NAME:String = "IrelandInnovation";
      
      private var m_zid:String = "";
      
      public const LEADERBOARD_PLAYING_FLAG:String = "Ireland_Leaderboard_Playing_flag";
      
      public const KEY_SELECTED_PIN:String = "selected_pin";
      
      public const OB_TASK_DAILY_LIMIT:String = "daily_order_limit";
      
      public const FLAG_ORDER_LIMIT_REACHED_FOR_THE_DAY:* = "ireland_OB_limit_reached_for_day";
      
      private const KEY_USER_STATE:String = "state";
      
      public const IS_PLAYING_FOR_LB_TODAY:String = "playing_lb";
      
      public const EASY:int = 0;
      
      public const BUILDING_COMPLETED:int = 6;
      
      public const MEDIUM:int = 1;
      
      public const HARD:int = 2;
      
      public const LOCK2:int = 5;
      
      public const TOKEN_SINK:int = 4;
      
      public const DONE_FOR_THE_DAY:int = 3;
      
      public const NOT_INITIALIZED:int = -1;
      
      public const VAL_MILESTONE_POINTS_ARRAY:Array = [35,80,135,185,220,255,300,350,410,450,485,525,570,610,650,685,730,780,820,860,900,950,1000,1050,1100];
      
      public const VAL_LEVEL_POINTS_ARRAY:Array = [220,450,650,860,1100];
      
      public const CONSUMABLE_COUNT_ARRAY:Array = [50,60,80,100,120];
      
      private var m_activePopupCount:int = 0;
      
      private var _redeemHasStarted:Boolean = false;
      
      private var _redeemMessageShown:Boolean = false;
      
      private const REDEEM_ADDITIONAL_DAYS:int = 0;
      
      private const KEY_FEATURE_ENDED:String = "finished";
      
      private const VAL_EA_DAILY_POINTS:* = 10;
      
      public const FIRST_SESSION_TUTORIAL:String = "IRELANDFirstSessioTutorial";
      
      private var m_rewardsBySlotName:Object = null;
      
      public function IrelandInnovationManager(featureName:String)
      {
         super(featureName);
         if(!this.featureConfig)
         {
            return;
         }
         this.parseTaskObjectsFromConfig(m_featureName);
         this.parseLBTaskObjectsFromConfig(m_featureName);
         this.startQuest();
         this.fetchOrderLimit();
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
         this.m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_IRELAND);
      }
      
      public static function getInstance(featureName:String = "IrelandInnovation") : IrelandInnovationManager
      {
         var instance:IrelandInnovationManager = getInstanceOfClass(featureName,IrelandInnovationManager) as IrelandInnovationManager;
         return instance.featureConfig == null ? null : instance;
      }
      
      public function setupHud() : void
      {
         var extraData:Object = {};
         extraData["iconTooltip"] = ZLocUtils.t("Dialogs",m_featureName + "_HUD_icon_tooltip");
         this.m_hud = Global.hud.rightSideIconQueue.addIcon(m_featureName,DynamicIconQueue.ADD_BY_PRIORITY,null,extraData) as QueuedIconWithArrow;
         if(this.m_hud)
         {
            this.m_hud.attachArrow(ArrowType.ARROWNEW);
            this.m_hud.setArrowText("New Feature!");
         }
      }
      
      public function getDialogUrl() : String
      {
         return this.m_assetPaths[WINDOW_MAIN];
      }
      
      public function get isFeatureActive() : Boolean
      {
         return this.m_isActive;
      }
      
      public function initialize() : void
      {
         this.loadStaticData();
         m_initialized = true;
      }
      
      public function showMainUI() : void
      {
         var leaderBoardData:Object = null;
         var currentLeaderboard:String = null;
         if(!this.hasExpiryDatePassedForFeature())
         {
            if(!m_initialized)
            {
               this.initialize();
            }
            leaderBoardData = this.getCurrentLeaderboard();
            currentLeaderboard = leaderBoardData.name;
            if(!this.getFeatureOptionsKey(KEY_CURRENT_LEADERBOARD))
            {
               this.saveFeatureOptionsKey(KEY_CURRENT_LEADERBOARD,currentLeaderboard);
            }
            if(this.isShowLeaderBoardPopup())
            {
               this.showLeaderboardUI(true);
            }
            else
            {
               this.m_mainWindow = new IrelandInnovationMainWindow(m_featureName,this.getDialogUrl(),false);
               this.startQuest(this.m_mainWindow.refreshTaskFrame);
               UI.displayPopup(this.m_mainWindow);
            }
         }
      }
      
      public function setupIrelanddHud() : void
      {
         if(!this.hasExpiryDatePassedForFeature())
         {
            this.m_IrelandInnovationHud = new HudBottomIrelandInnovationButton(HUD_IRELAND_ASSET,m_featureName);
            Global.hud.setBottomHudIrelandInnovationButton(this.m_IrelandInnovationHud as HudBottomIrelandInnovationButton);
         }
      }
      
      public function isGAPlayer() : Boolean
      {
         return !WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_IRELAND);
      }
      
      public function isPlayingForLBToday() : Boolean
      {
         var res:* = false;
         if(this.getFeatureOptionsKey(this.IS_PLAYING_FOR_LB_TODAY) == 1)
         {
            res = true;
         }
         if(this.getUserState() == this.BUILDING_COMPLETED)
         {
            res = true;
         }
         return res;
      }
      
      private function untintWindow(evt:Event = null) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.untintWindow();
            this.m_mainWindow.enableInput = true;
            this.m_mainWindow.refreshWindow();
         }
      }
      
      public function closeMainWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
      }
      
      public function isAllTilesUnlocked() : Boolean
      {
         if(Global.world.getObjectsByNames(BRAZIL_TILE_LIST).length)
         {
            return false;
         }
         return true;
      }
      
      public function askForConsumables(event:Event = null) : void
      {
         getFeedData(FEED_NAME).postFeed(this.onAskForConsumables);
      }
      
      private function onAskForConsumables(e:Object) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.refreshAskButton();
            FarmStatsManager.count("Ask","Medieval Axe");
         }
      }
      
      public function hasExpiryDatePassedForFeature() : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("10/07/2019") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         timeLeft = endTime - now;
         if(timeLeft <= 0)
         {
            result = true;
         }
         return result;
      }
      
      public function panToMapTrigger() : void
      {
         var name:String = "IrelandInnovationMapTrigger";
         var map:MapTrigger = MapTriggerManager.getInstance().getMapTriggerByName(name);
         if(map)
         {
            if(this.m_mainWindow)
            {
               this.m_mainWindow.close();
            }
            ItemFinderManager.getInstance().highlightWorldItems(map.getItemName());
         }
      }
      
      protected function onTransactionAdded(event:TransactionEvent) : void
      {
         this.checkForTaskUpdates(event);
      }
      
      public function getTimeRemaining() : Array
      {
         var remainingDay:int = 0;
         var timeLeftMs:Number = this.m_endTimeStamp - GlobalEngine.serverTime;
         timeLeftMs = timeLeftMs < 0 ? 0 : timeLeftMs;
         var remainingTime:Array = FarmGameUtil.parseTimeLeft(timeLeftMs / 1000);
         if(parseInt(remainingTime[0]) > 0)
         {
            remainingDay = parseInt(remainingTime[0]) + 1;
            remainingTime[0] = remainingDay.toString();
         }
         return remainingTime;
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
      
      protected function parseLBTaskObjectsFromConfig(questName:String) : void
      {
         var orderBoardXml:XML = null;
         var tasksByDifficultyList:XMLList = null;
         var tasksByDiff:XML = null;
         var tasksByDiffAndTypeList:XMLList = null;
         var tasksByDiffAndType:XML = null;
         var taskXML:XML = null;
         this.m_LBtasksById = {};
         orderBoardXml = Global.farmGameSettingsManager.getXML().orderBoards.orderBoard.(@name == LB_IRELAND_ORDERBOARD)[0];
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
                     this.m_LBtasksById[taskXML.@id] = taskXML;
                  }
               }
            }
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
         var savedactiveTasksKey:String = KEY_SAVED_ACTIVE_TASKS;
         if(this.isPlayingForLBToday())
         {
            savedactiveTasksKey = KEY_SAVED_LB_ACTIVE_TASKS;
         }
         var savedTasks:Array = this.getFeatureOptionsKey(savedactiveTasksKey) as Array;
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
         }
      }
      
      public function saveBushelProgress() : void
      {
         var taskObj:Object = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         var savedactiveTasksKey:String = KEY_SAVED_ACTIVE_TASKS;
         if(this.isPlayingForLBToday())
         {
            savedactiveTasksKey = KEY_SAVED_LB_ACTIVE_TASKS;
         }
         var savedTasks:Array = this.getFeatureOptionsKey(savedactiveTasksKey) as Array;
         var tasksToSave:Array = [];
         for(var i:int = 0; i < tasks.length; i++)
         {
            taskObj = {};
            if(tasks[i].id != "")
            {
               taskObj[this.KEY_ID] = tasks[i].id;
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
         this.saveFeatureOptionsKey(savedactiveTasksKey,tasksToSave as Object);
      }
      
      protected function saveProgressForPlayer(progressArray:Array) : void
      {
         var taskObj:Object = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         var savedactiveTasksKey:String = KEY_SAVED_ACTIVE_TASKS;
         if(this.isPlayingForLBToday())
         {
            savedactiveTasksKey = KEY_SAVED_LB_ACTIVE_TASKS;
         }
         var savedTasks:Array = this.getFeatureOptionsKey(savedactiveTasksKey) as Array;
         var tasksToSave:Array = [];
         for(var i:int = 0; i < tasks.length; i++)
         {
            taskObj = {};
            if(tasks[i].id != "")
            {
               taskObj[this.KEY_ID] = tasks[i].id;
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
         this.saveFeatureOptionsKey(savedactiveTasksKey,tasksToSave as Object);
      }
      
      public function showTileUnlockGrantPopup(e:TileUnlockEvent = null) : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("ireland_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            UI.displayPopup(new IrelandInnovationTileUnlockwindow("assets/dialogs/expansion/FV_RewardDialog.swf",m_featureName,null,null,"assets/dialogs/ireland/RewardDialog.png"));
            FarmStatsManager.count(m_featureName,"feature_ui","tileUnlockPopup");
         }
         if(this.m_mainWindow)
         {
            this.m_mainWindow.refreshWindow();
         }
         if(!Global.player.getSeenFlag(this.TILE_UNLOCK))
         {
            Global.player.setSeenFlag(this.TILE_UNLOCK);
         }
      }
      
      public function getTileUnlockCount() : int
      {
         var count:int = 0;
         var result:int = 0;
         var inventoryTileCount:int = FeatureOptionsInventoryManager.getInstance().getCount(IRELAND_TILE_UNLOCK_COUNT) as int;
         count = this.getFeatureOptionsKey(TILE_UNLOCK_COUNT) as int;
         if(inventoryTileCount > 0 && inventoryTileCount > int(count))
         {
            result = inventoryTileCount - int(count);
            this.addTileUnlockCount();
         }
         return result;
      }
      
      public function addTileUnlockCount() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"addTileUnlock",this.addTileUnlockFeatureOption,[m_featureName]),true);
      }
      
      public function addTileUnlockFeatureOption(result:Object) : void
      {
         var inventoryTileCount:Number = NaN;
         if(result)
         {
            inventoryTileCount = FeatureOptionsInventoryManager.getInstance().getCount(IRELAND_TILE_UNLOCK_COUNT);
            this.saveFeatureOptionsKey(TILE_UNLOCK_COUNT,inventoryTileCount);
         }
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
         this.m_mainWindow.showAutoHideNPCCallouts(title,text);
      }
      
      public function hideNPCCallout() : void
      {
         this.m_mainWindow.hideNPCCallout();
      }
      
      public function getFeatureOptionsKey(optionName:String) : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,optionName);
      }
      
      public function getBuildingRewardsData(level:int) : String
      {
         return this.m_staticData.rewards[level];
      }
      
      public function updateSelectedPin(index:int) : void
      {
         this.saveFeatureOptionsKey(this.KEY_SELECTED_PIN,index);
         this.m_mainWindow.pinGlowState(index);
         this.m_mainWindow.updatePinsStates();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"updateSelectedPin",null,[m_featureName,index]),true);
      }
      
      public function isMilestoneAchievedForLevel(level:int) : Boolean
      {
         var result:Boolean = false;
         if(this.getDayPoints() >= this.VAL_MILESTONE_POINTS_ARRAY[level])
         {
            result = true;
         }
         return result;
      }
      
      protected function saveFeatureOptionsKey(optionName:String, optionsValue:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,optionName,optionsValue);
      }
      
      override public function getTasks() : Vector.<FarmTask>
      {
         var savedTaskInfo:Array = null;
         var task:Object = null;
         var taskXML:XML = null;
         var taskObj:Object = null;
         var farmTask:FarmTask = null;
         var taskList:Vector.<FarmTask> = new Vector.<FarmTask>();
         var savedactiveTasksKey:String = KEY_SAVED_ACTIVE_TASKS;
         if(this.isPlayingForLBToday())
         {
            savedactiveTasksKey = KEY_SAVED_LB_ACTIVE_TASKS;
            savedTaskInfo = this.getFeatureOptionsKey(savedactiveTasksKey) as Array;
            if(Boolean(savedTaskInfo) && Boolean(savedTaskInfo.length))
            {
               if(this.m_LBtasksById == null)
               {
                  this.parseLBTaskObjectsFromConfig(m_featureName);
               }
               for each(task in savedTaskInfo)
               {
                  taskXML = this.m_LBtasksById[task[this.KEY_ID]];
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
                     taskObj = new Object();
                     taskObj.action = "useItemByCode";
                     taskObj.type = "k9b1";
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
         }
         else
         {
            savedTaskInfo = this.getFeatureOptionsKey(savedactiveTasksKey) as Array;
            if(Boolean(savedTaskInfo) && Boolean(savedTaskInfo.length))
            {
               if(this.m_tasksById == null)
               {
                  this.parseTaskObjectsFromConfig(m_featureName);
               }
               for each(task in savedTaskInfo)
               {
                  taskXML = this.m_tasksById[task[this.KEY_ID]];
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
                     taskObj = new Object();
                     taskObj.action = "useItemByCode";
                     taskObj.type = "k9b1";
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
         }
         return taskList;
      }
      
      public function isTaskDumped(questIndex:int) : Boolean
      {
         var result:Boolean = false;
         var savedactiveTasksKey:String = KEY_SAVED_ACTIVE_TASKS;
         if(this.isPlayingForLBToday())
         {
            savedactiveTasksKey = KEY_SAVED_LB_ACTIVE_TASKS;
         }
         var savedTasks:Array = this.getFeatureOptionsKey(savedactiveTasksKey) as Array;
         if(!savedTasks[questIndex].hasOwnProperty(this.KEY_ID))
         {
            result = true;
         }
         return result;
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
      
      public function highlightTiles() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
         UI.displayMiniMarketDialog(this.lockedTilesArray,null,"seed",null,true,false,false,true);
      }
      
      public function getTaskProgress(taskIndex:int) : int
      {
         var progress:int = 0;
         var savedactiveTasksKey:String = KEY_SAVED_ACTIVE_TASKS;
         if(this.isPlayingForLBToday())
         {
            savedactiveTasksKey = KEY_SAVED_LB_ACTIVE_TASKS;
         }
         var savedTasksProgress:Array = this.getFeatureOptionsKey(savedactiveTasksKey) as Array;
         if(Boolean(savedTasksProgress) && Boolean(savedTasksProgress[taskIndex][this.KEY_PROGRESS]))
         {
            progress = int(savedTasksProgress[taskIndex][this.KEY_PROGRESS]);
         }
         return progress;
      }
      
      public function getBoardFrameNumber() : Number
      {
         return this.getFeatureOptionsKey(KEY_SAVED_BOARD_COUNT) as Number;
      }
      
      private function onInitQuestComplete(callback:Function, result:Object) : void
      {
         this.m_resultObject = result;
         var savedactiveTasksKey:String = KEY_SAVED_ACTIVE_TASKS;
         if(this.isPlayingForLBToday())
         {
            savedactiveTasksKey = KEY_SAVED_LB_ACTIVE_TASKS;
         }
         if(Boolean(result) && result.hasOwnProperty("activeTasks"))
         {
            this.saveFeatureOptionsKey(savedactiveTasksKey,result["activeTasks"]);
            if(Boolean(callback))
            {
               callback.call();
            }
         }
      }
      
      private function onFetchOBLimitComplete(callback:Function, result:Object) : void
      {
         this.m_resultObject = result;
         if(Boolean(result) && result.hasOwnProperty("dailyLimit"))
         {
            this.saveFeatureOptionsKey(this.OB_TASK_DAILY_LIMIT,result["dailyLimit"]);
            if(Boolean(callback))
            {
               callback.call();
            }
         }
      }
      
      public function startQuest(callback:Function = null) : void
      {
         var savedactiveTasksKey:String = KEY_SAVED_ACTIVE_TASKS;
         if(this.isPlayingForLBToday())
         {
            savedactiveTasksKey = KEY_SAVED_LB_ACTIVE_TASKS;
         }
         var savedTaskInfo:Array = this.getFeatureOptionsKey(savedactiveTasksKey) as Array;
         if(!(savedTaskInfo && savedTaskInfo.length))
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startQuest",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName)),true);
            this.saveFeatureOptionsKey(this.KEY_USER_STATE,this.NOT_INITIALIZED);
         }
      }
      
      public function fetchOrderLimit(callback:Function = null) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"fetchDailyLimit",ZCacheUtil.applyPartial(this.onFetchOBLimitComplete,this,[callback]),new Array(m_featureName)),true);
      }
      
      public function redeemRewardPoints(questIndex:int, callback:Function, taskPoints:int = 0) : void
      {
         var tasks:Vector.<FarmTask> = this.getTasks();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"redeemRewardPoints",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,questIndex)),true);
         this.resetActionCountsForTasks(tasks[questIndex]);
      }
      
      public function skipTask(questIndex:int, callback:Function) : void
      {
         var savedactiveTasksKey:String = null;
         var savedTasks:Array = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         if(Global.player.canBuyCash(tasks[questIndex].skipCashValue))
         {
            Global.player.cash -= tasks[questIndex].skipCashValue;
            savedactiveTasksKey = KEY_SAVED_ACTIVE_TASKS;
            if(this.isPlayingForLBToday())
            {
               savedactiveTasksKey = KEY_SAVED_LB_ACTIVE_TASKS;
            }
            savedTasks = this.getFeatureOptionsKey(savedactiveTasksKey) as Array;
            savedTasks[questIndex][this.KEY_PROGRESS] = tasks[questIndex].total;
            this.saveFeatureOptionsKey(savedactiveTasksKey,savedTasks);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,questIndex)),true);
            this.resetActionCountsForTasks(tasks[questIndex]);
         }
         else
         {
            callback.call();
         }
      }
      
      public function skipDumpedTask(questIndex:int, callback:Function) : void
      {
         var dumpTSKey:String = null;
         var dumpTimestamp:Object = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         if(Global.player.canBuyCash(SKIP_COST))
         {
            Global.player.cash -= SKIP_COST;
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipDumpedTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,questIndex)),true);
            dumpTSKey = KEY_SAVED_DUMPED_TIMESTAMP;
            if(this.isPlayingForLBToday())
            {
               dumpTSKey = KEY_SAVED_LB_DUMPED_TIMESTAMP;
            }
            dumpTimestamp = this.getFeatureOptionsKey(dumpTSKey) as Object;
            dumpTimestamp[questIndex] = 0;
            this.saveFeatureOptionsKey(dumpTSKey,dumpTimestamp);
            this.resetActionCountsForTasks(tasks[questIndex]);
         }
         else
         {
            callback.call();
         }
      }
      
      public function dumpTask(questIndex:int, callback:Function) : void
      {
         var dumpTSKey:String = null;
         var dumpTimestamp:Object = null;
         if(this.canDumpTask(questIndex))
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"dumpTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,questIndex)),true);
            dumpTSKey = KEY_SAVED_DUMPED_TIMESTAMP;
            if(this.isPlayingForLBToday())
            {
               dumpTSKey = KEY_SAVED_LB_DUMPED_TIMESTAMP;
            }
            dumpTimestamp = this.getFeatureOptionsKey(dumpTSKey) as Object;
            if(dumpTimestamp == null)
            {
               dumpTimestamp = new Object();
            }
            dumpTimestamp[questIndex] = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            this.saveFeatureOptionsKey(dumpTSKey,dumpTimestamp);
         }
      }
      
      public function canDumpTask(questIndex:int) : Boolean
      {
         var currentTime:Number = NaN;
         var result:Boolean = true;
         var throttleTimeInSeconds:Number = 15 * FarmGameUtil.NUM_SECS_IN_MINUTE;
         var dumpTSKey:String = KEY_SAVED_DUMPED_TIMESTAMP;
         if(this.isPlayingForLBToday())
         {
            dumpTSKey = KEY_SAVED_LB_DUMPED_TIMESTAMP;
         }
         var dumpTimestamp:Object = this.getFeatureOptionsKey(dumpTSKey) as Object;
         if(dumpTimestamp != null && dumpTimestamp.hasOwnProperty(questIndex.toString()))
         {
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            result = currentTime - dumpTimestamp[questIndex] > throttleTimeInSeconds;
         }
         return result;
      }
      
      public function getTimeRemainingForDumpedTask(questIndex:int) : Number
      {
         var result:Number = NaN;
         var currentTime:Number = NaN;
         var throttleTimeInSeconds:Number = 15 * FarmGameUtil.NUM_SECS_IN_MINUTE;
         var dumpTSKey:String = KEY_SAVED_DUMPED_TIMESTAMP;
         if(this.isPlayingForLBToday())
         {
            dumpTSKey = KEY_SAVED_LB_DUMPED_TIMESTAMP;
         }
         var dumpTimestamp:Object = this.getFeatureOptionsKey(dumpTSKey) as Object;
         if(dumpTimestamp != null && dumpTimestamp.hasOwnProperty(questIndex.toString()))
         {
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            result = throttleTimeInSeconds - (currentTime - dumpTimestamp[questIndex]);
         }
         return result;
      }
      
      public function getNewTasks(questIndex:int, callback:Function) : void
      {
         var tasks:Vector.<FarmTask> = this.getTasks();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getNewTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,questIndex)),true);
         var dumpTSKey:String = KEY_SAVED_DUMPED_TIMESTAMP;
         if(this.isPlayingForLBToday())
         {
            dumpTSKey = KEY_SAVED_LB_DUMPED_TIMESTAMP;
         }
         var dumpTimestamp:Object = this.getFeatureOptionsKey(dumpTSKey) as Object;
         dumpTimestamp[questIndex] = 0;
         this.saveFeatureOptionsKey(dumpTSKey,dumpTimestamp);
         this.resetActionCountsForTasks(tasks[questIndex]);
      }
      
      public function sinkGold(questIndex:int, callback:Function) : void
      {
         var savedactiveTasksKey:String = null;
         var savedTasks:Array = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         if(Global.player.canBuy(tasks[questIndex].total))
         {
            Global.player.gold -= tasks[questIndex].total;
            savedactiveTasksKey = KEY_SAVED_ACTIVE_TASKS;
            if(this.isPlayingForLBToday())
            {
               savedactiveTasksKey = KEY_SAVED_LB_ACTIVE_TASKS;
            }
            savedTasks = this.getFeatureOptionsKey(savedactiveTasksKey) as Array;
            savedTasks[questIndex][this.KEY_PROGRESS] = tasks[questIndex].total;
            this.saveFeatureOptionsKey(savedactiveTasksKey,savedTasks);
            this.grantMilestoneReward(tasks[questIndex].questPoints);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkGold",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,questIndex)),true);
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
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkBushel",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,questIndex)),true);
         StatsManager.count(m_featureName,"Sink Bushel","",tasks[questIndex].total.toString(),this.getDayPoints().toString());
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
      
      public function isFinalRewardChosen() : Boolean
      {
         if(this.getRewardBuildingName() != null && this.getRewardBuildingName() != "0")
         {
            return true;
         }
         return false;
      }
      
      public function isFinalRewardGranted() : Boolean
      {
         var finalRewardTaken:int = this.getFeatureOptionsKey(KEY_SAVED_FINAL_REWARD_RECEIVED) as int;
         if(finalRewardTaken)
         {
            return true;
         }
         return false;
      }
      
      public function get currencyName() : String
      {
         this.m_currencyName = "casablanca_task_points";
         return this.m_currencyName;
      }
      
      public function getRewardBuildingName() : String
      {
         return this.getFeatureOptionsKey(KEY_SAVED_FINAL_REWARD_BUILDINGNAME) as String;
      }
      
      private function postBragFeed(event:Event) : void
      {
         if(Boolean(this.m_resultObject) && Boolean(this.m_resultObject["feedData"]))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(this.m_resultObject["feedData"]);
         }
         if(this.m_rewardWindow)
         {
            this.m_rewardWindow.close();
         }
         if(this.m_buildingUpgradeRewardWindow)
         {
            this.m_buildingUpgradeRewardWindow.close();
         }
      }
      
      private function postFinalRewardFeed(event:Event) : void
      {
         if(Boolean(this.m_resultObject) && Boolean(this.m_resultObject["feedFinalRewardData"]))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(this.m_resultObject["feedFinalRewardData"]);
         }
         if(this.m_rewardWindow)
         {
            this.m_rewardWindow.close();
         }
         if(this.m_buildingUpgradeRewardWindow)
         {
            this.m_buildingUpgradeRewardWindow.close();
         }
      }
      
      private function postMilestoneBragFeed(event:Event) : void
      {
         if(Boolean(this.m_resultObject) && Boolean(this.m_resultObject["feedData"]))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(this.m_resultObject["feedData"]);
         }
         if(this.m_rewardWindow)
         {
            this.m_rewardWindow.close();
         }
         if(this.m_buildingUpgradeRewardWindow)
         {
            this.m_buildingUpgradeRewardWindow.close();
         }
      }
      
      private function postBuildingUpgradeBragFeed(event:Event) : void
      {
         if(Boolean(this.m_resultObject) && Boolean(this.m_resultObject["feedBuildingData"]))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(this.m_resultObject["feedBuildingData"]);
         }
         if(this.m_rewardWindow)
         {
            this.m_rewardWindow.close();
         }
         if(this.m_buildingUpgradeRewardWindow)
         {
            this.m_buildingUpgradeRewardWindow.close();
         }
      }
      
      public function panToBuilding(buildingName:String) : void
      {
         if(this.m_rewardWindow)
         {
            this.m_rewardWindow.close();
         }
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
         var brazilInnovationBuildingItem:Array = Global.world.getObjectsByName(buildingName);
         if(Boolean(brazilInnovationBuildingItem) && brazilInnovationBuildingItem.length > 0)
         {
            ItemFinderManager.getInstance().highlightWorldItems(buildingName);
         }
      }
      
      protected function getFeatureOption() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName);
      }
      
      public function isFeatureComplete() : Boolean
      {
         var score:int = this.getDayPoints();
         return score >= VAL_FINAL_MILESTONE;
      }
      
      public function grantPointsForTask(pointsForTask:int) : void
      {
         var currentDayPoints:int = this.getDayPoints();
         currentDayPoints += pointsForTask;
      }
      
      public function grantMilestoneReward(points:int) : void
      {
         var reward:Object = null;
         var imageMilestone:int = 0;
         var showReward:Boolean = false;
         if(this.getFeatureOptionsKey(this.IS_PLAYING_FOR_LB_TODAY) == 0)
         {
            this.saveFeatureOptionsKey(this.KEY_DAY_POINTS,this.getDayPoints() + points);
            this.saveFeatureOptionsKey(this.KEY_ORDERBOARD_COUNT,this.getOrderboardTaskCount() + 1);
            this.saveFeatureOptionsKey(this.WEEKLY_SCORE,this.getWeeklyLeaderboardPoints() + points);
         }
         else
         {
            this.saveFeatureOptionsKey(this.WEEKLY_SCORE,this.getWeeklyLeaderboardPoints() + points);
         }
         this.m_mainWindow.refreshOrdersCompleted();
         if(points > 0)
         {
            this.m_mainWindow.m_dooberPointsTf[this.getSelectedPin()].text = "" + points;
            if(this.m_mainWindow.m_pinsDooberMcArray)
            {
               this.m_mainWindow.m_pinsDooberMcArray[this.getSelectedPin()].gotoAndPlay(2);
            }
         }
         var orderboardTaskCount:int = this.getOrderboardTaskCount();
         if(orderboardTaskCount == this.getDailyOrderLimit() && this.getFeatureOptionsKey(this.IS_PLAYING_FOR_LB_TODAY) == 0)
         {
            this.saveFeatureOptionsKey(this.KEY_USER_STATE,this.DONE_FOR_THE_DAY);
            this.saveFeatureOptionsKey(this.IS_PLAYING_FOR_LB_TODAY,1);
            this.m_mainWindow.updateLockMc(true);
         }
         var OBPoints:int = this.getDayPoints();
         var mileStone:int = this.getMilestoneLevel();
         var level:int = this.getKeyBuildingLevel();
         if(OBPoints >= this.VAL_MILESTONE_POINTS_ARRAY[mileStone])
         {
            mileStone += 1;
            this.saveFeatureOptionsKey(KEY_MILESTONE_LEVEL,mileStone);
            showReward = true;
         }
         if(OBPoints >= this.VAL_LEVEL_POINTS_ARRAY[level] && this.getUserState() != this.BUILDING_COMPLETED)
         {
            this.saveFeatureOptionsKey(this.KEY_USER_STATE,this.TOKEN_SINK);
         }
         if(this.activeDayIndex % 7 == 6)
         {
            this.checkAndUpdateLeaderboardRewards();
         }
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName("consume_unwither");
         if(showReward)
         {
            reward = this.grantUserRewardforLevel(mileStone);
            UserRewardUtil.grantUserReward(reward);
            rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
            StatsManager.count(FEATURE_TRACKING,"Milestone",mileStone.toString(),rewardItem.name,"",this.getDayPoints().toString());
            imageMilestone = mileStone % 5;
            imageMilestone = mileStone > 0 && imageMilestone == 0 ? 5 : imageMilestone;
            UI.displayPopup(new IrelandInnovationMilestoneRewardWindow("assets/dialogs/expansion/FV_RewardDialog.swf",m_featureName,rewardItem,null,"assets/dialogs/ireland/RewardDialog.png",this.m_mainWindow.getMilestoneRewatdImage(imageMilestone)),false);
            this.m_mainWindow.updateDayBonus();
         }
      }
      
      public function isShowLeaderBoardPopup() : Boolean
      {
         var isShow:Boolean = false;
         var leaderBoardData:Object = this.getCurrentLeaderboard();
         var currentLeaderboard:String = leaderBoardData.name;
         var featureData:Object = this.getFeatureOption();
         if(this.getFeatureOptionsKey(KEY_CURRENT_LEADERBOARD) != currentLeaderboard && this.getFeatureOptionsKey(this.WEEKLY_SCORE) > 0)
         {
            isShow = true;
         }
         return isShow;
      }
      
      public function hasActiveDayExpired() : Boolean
      {
         var expired:Boolean = false;
         var activeTime:int = this.getFeatureOptionsKey(this.KEY_ACTIVE_DAY_TIMESTAMP) as int;
         var currenttime:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(currenttime - activeTime > 86400)
         {
            expired = true;
         }
         return expired;
      }
      
      public function getDayPoints() : int
      {
         return this.getFeatureOptionsKey(this.KEY_DAY_POINTS) as int;
      }
      
      public function getDailyOrderLimit() : int
      {
         return int(int(this.getFeatureOptionsKey(this.OB_TASK_DAILY_LIMIT)));
      }
      
      public function getDiffbySlotNumber(num:int) : String
      {
         var result:* = " : ";
         if(num <= 1)
         {
            result = "easy" + result;
         }
         else if(num <= 3)
         {
            result = "medium" + result;
         }
         else if(num <= 5)
         {
            result = "hard" + result;
         }
         return result;
      }
      
      public function isLessThan18HoursLeftForFeature() : Boolean
      {
         var result:Boolean = false;
         var featureCompletionTime:int = this.getFeatureOptionsKey(this.KEY_FEATURE_FINISHED_TIME) as int;
         if(this.m_endTimeStamp - featureCompletionTime < 64800)
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
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("10/20/2019") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         timeLeft = endTime - now;
         if(timeLeft <= 0)
         {
            result = true;
         }
         return result;
      }
      
      public function harvestBonusBuilding() : void
      {
         var key:String = null;
         var harvestRewardName:String = null;
         var lvl:int = 0;
         var harvestFarmItem:FarmItem = null;
         var count:int = 0;
         var bonusBuildingName:String = null;
         if(!m_initialized)
         {
            this.initialize();
         }
         if(this.getKeyBuildingLevel() >= 1)
         {
            key = LAST_BONUS_HARVEST_TIME_KEY;
            Global.player.setFeatureLastShown(key,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
            harvestRewardName = this.getNextHarvestItemName();
            lvl = this.getKeyBuildingLevel();
            harvestFarmItem = Global.farmGameSettingsManager.getFarmItemByName(harvestRewardName);
            if(harvestFarmItem)
            {
               count = 1;
               if(lvl == 5)
               {
                  if(this.HARVEST_MULTIPLE_ARRAY.indexOf(harvestRewardName) == -1)
                  {
                     count = 1;
                  }
                  else
                  {
                     count = 2;
                  }
               }
               Global.player.addGift(harvestRewardName,"",count);
               bonusBuildingName = BONUS_NAME_ARRAY[this.getKeyBuildingLevel() - 1];
               UI.displayPopup(new IrelandInnovationPostBonusHarvestWindow("assets/dialogs/expansion/FV_RewardDialog.swf",m_featureName,bonusBuildingName,harvestFarmItem,null,"assets/dialogs/ireland/RewardDialog.png",count));
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,this.SERVICE_FUNC_HARVEST_BONUS,null,[m_featureName]),true);
               FarmStatsManager.count("IrelanInnovation","Reward","Nisse gift house","" + this.getKeyBuildingLevel(),harvestFarmItem.friendlyTitle,this.getActiveWeek(),this.activeDayIndex + 1);
            }
         }
      }
      
      public function getTimeLeftForBonusHarvest() : int
      {
         var timeLeft:int = 0;
         var key:String = LAST_BONUS_HARVEST_TIME_KEY;
         var throttleTime:int = DEFAULT_HARVEST_THROTTLE_TIME;
         return this.getTimeLeft(key,throttleTime);
      }
      
      public function getTimeLeft(key:String, throttleTime:int = 86400) : int
      {
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         return int(throttleTime - timeSinceLastFeed);
      }
      
      public function IsBonusBuildingReadyToHarvest() : Boolean
      {
         var result:Boolean = false;
         if(this.getTimeLeftForBonusHarvest() <= 0)
         {
            result = true;
         }
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("ireland_innovation_bonus_enabled");
         if(!PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            result = false;
         }
         return result;
      }
      
      public function getHervestTime() : String
      {
         var result:String = null;
         var secondsLeft:int = this.getTimeLeftForBonusHarvest();
         var hourLeft:String = Math.floor(secondsLeft / 3600).toString();
         var minutesLeft:String = Math.floor((secondsLeft - parseInt(hourLeft) * 3600) / 60).toString();
         var remainingSecsLeft:String = (secondsLeft - (parseInt(hourLeft) * 3600 + parseInt(minutesLeft) * 60)).toString();
         if(hourLeft.length < 2)
         {
            hourLeft = "0" + hourLeft;
         }
         if(minutesLeft.length < 2)
         {
            minutesLeft = "0" + minutesLeft;
         }
         if(remainingSecsLeft.length < 2)
         {
            remainingSecsLeft = "0" + remainingSecsLeft;
         }
         return hourLeft + ":" + minutesLeft + ":" + remainingSecsLeft;
      }
      
      private function getNextHarvestItemName() : String
      {
         var harvestReward:String = null;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName);
         var lvl:int = this.getKeyBuildingLevel();
         var bonusCount:int = this.getFeatureOptionsKey(this.BONUS_HARVEST_COUNT) as int;
         var consumableRotationCount:int = int(BONUS_COUNT_MAP[lvl]);
         harvestReward = this.BONUS_HARVEST_ARRAY[lvl][bonusCount % consumableRotationCount];
         this.saveFeatureOptionsKey(this.BONUS_HARVEST_COUNT,bonusCount + 1);
         return harvestReward;
      }
      
      public function setFinalRewardGrantFlag() : void
      {
         if(!Global.player.getSeenFlag(FEATURE_SET_FINAL_REWARD))
         {
            Global.player.setSeenFlag(FEATURE_SET_FINAL_REWARD);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,this.SERVICE_FUNC_SET_FINAL_REWARD_GRANT,null,[m_featureName]),true);
         }
      }
      
      public function setRedeemCallout(flag:Boolean = false) : void
      {
         this.m_showRedeemCallout = flag;
      }
      
      public function getRedeemCallout() : Boolean
      {
         return this.m_showRedeemCallout;
      }
      
      public function getOrderboardTaskCount() : int
      {
         return this.getFeatureOptionsKey(this.KEY_ORDERBOARD_COUNT) as int;
      }
      
      public function getLeaderboardPointsCount() : int
      {
         return this.getFeatureOptionsKey(this.WEEKLY_SCORE) as int;
      }
      
      public function getSelectedPin() : int
      {
         return this.getFeatureOptionsKey(this.KEY_SELECTED_PIN) as int;
      }
      
      public function get consumableCount() : Number
      {
         return int(FeatureOptionsInventoryManager.getInstance().getCount(this.ConsumableCode));
      }
      
      public function get ConsumableCode() : String
      {
         return this.m_staticData.consumable;
      }
      
      public function get TilesArray() : Array
      {
         return this.m_staticData.tilesArray;
      }
      
      public function getFeatureEndDaysLeftText() : String
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         timeLeft = (FarmGameUtil.synchronizedDateToNumber("10/07/2019") - this.REDEEM_ADDITIONAL_DAYS * FarmGameUtil.NUM_MSECS_IN_DAY - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return HUD.getformattedTimeLeft(timeLeft);
      }
      
      public function get bonusGrantDate() : String
      {
         return this.m_staticData.bonusGrantDate;
      }
      
      public function initializeLeaderBoardProgress(isSync:Boolean = false) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getLeaderboardEntries",this.getLeaderboardEntries,[m_featureName,isSync]));
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
         var totalDays:int = 5 * 7;
         if(dayIndex == totalDays - 1)
         {
            result = true;
         }
         return true;
      }
      
      public function getLeaderboardData() : Array
      {
         return this.m_staticData.leaderboardConfigData;
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
      
      public function getLeaderboardWeekIndex(leaderboardName:String) : int
      {
         switch(leaderboardName)
         {
            case "irelandInnovationWeek1":
               return 1;
            case "irelandInnovationWeek2":
               return 2;
            case "irelandInnovationWeek3":
               return 3;
            case "irelandInnovationWeek4":
               return 4;
            case "irelandInnovationWeek5":
               return 5;
            default:
               return -1;
         }
      }
      
      public function get currentWeekIndex() : int
      {
         var weekIndex:int = 0;
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("09/02/2019");
         weekIndex = (GlobalEngine.serverTime - featureStartDayTS) / FarmGameUtil.NUM_MSECS_IN_DAY / FarmGameUtil.NUM_DAYS_IN_WEEK;
         if(weekIndex < 0)
         {
            weekIndex = 0;
         }
         return weekIndex;
      }
      
      public function grantLBFeatureEndReward(gift:Array, rank:Number, leaderboardName:String, score:int) : void
      {
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(gift[0]);
         var lbGiftIndex:* = this.getLeaderboardWeekIndex(leaderboardName);
         if(rewardItem != null)
         {
            UI.displayPopup(new IrelandInnovationMilestoneRewardWindow("assets/dialogs/expansion/FV_RewardDialog.swf",m_featureName,rewardItem,null,"assets/dialogs/ireland/RewardDialog.png",null,score,rank,true,lbGiftIndex),false);
         }
      }
      
      public function ShowLBRewardPopup(gift:Array, rank:Number, leaderboardName:String, score:int) : void
      {
         var reward:XML = null;
         var rewardItem:FarmItem = null;
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
         StatsManager.count(FEATURE_TRACKING,"leaderboard","reward",rank.toString(),itemName,this.getDayPoints().toString());
         rewardItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         if(rewardItem != null)
         {
            UI.displayPopup(new IrelandInnovationMilestoneRewardWindow("assets/dialogs/expansion/FV_RewardDialog.swf",m_featureName,rewardItem,null,"assets/dialogs/ireland/RewardDialog.png",null,score,rank,true,lbGiftIndex),false);
         }
      }
      
      public function getLeaderboardEntries(result:Object = null) : void
      {
         var collectionData:Object = null;
         var giftKey:String = null;
         var gifts:Array = null;
         var giftName:String = null;
         var weeklyLeaderboardData:Object = null;
         if(result != null)
         {
            this.m_zid = result["zid"];
            collectionData = this.getFeatureOption();
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
            }
            if(Boolean(this.m_leaderboardWindow) && result["syncMainUI"] == false)
            {
               this.m_leaderboardWindow.updateLeaderboardFrame(true);
               this.m_leaderboardWindow.populateLeaderboard(result);
            }
            if(result["userData"])
            {
               collectionData[KEY_SAVED_LEADERBOARD_RESULT] = result["userData"];
               collectionData[this.WEEKLY_SCORE] = result["userData"]["value"];
            }
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,FEATURE_OPTIONS_KEY,collectionData);
         }
         else if(this.m_leaderboardWindow)
         {
            this.m_leaderboardWindow.updateLeaderboardFrame(false);
         }
      }
      
      public function getMilestoneLevel() : int
      {
         return this.getFeatureOptionsKey(KEY_MILESTONE_LEVEL) as int;
      }
      
      public function getUserState() : int
      {
         return this.getFeatureOptionsKey(this.KEY_USER_STATE) as int;
      }
      
      public function showLeaderboardUI(showGift:Boolean = false) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.updateLeagueOverlay();
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         FarmStatsManager.count("IrelandInnovation","Leaderboard","Click");
         this.m_leaderboardWindow = new IrelandInnovationLeaderboardWindow("assets/dialogs/ireland/Innovation/FV_xid_Innovation_Leaderboard.swf",m_featureName,null,null,showGift);
         UI.displayPopup(this.m_leaderboardWindow,false);
      }
      
      public function getWeeksArray() : Array
      {
         return this.m_staticData.weeks;
      }
      
      public function getUserDataFromLeaderboard() : Object
      {
         return this.getFeatureOptionsKey(KEY_SAVED_LEADERBOARD_RESULT);
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
      
      public function consumableNeededForUnlock() : int
      {
         var level:int = this.getKeyBuildingLevel();
         return this.CONSUMABLE_COUNT_ARRAY[level];
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
      
      public function getUserZid() : String
      {
         return this.m_zid;
      }
      
      public function isUserLocked() : Boolean
      {
         var result:Boolean = false;
         if(this.getUserState() == this.TOKEN_SINK)
         {
            result = true;
         }
         return result;
      }
      
      public function setFeatureData(data:Object) : *
      {
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,m_featureName,data);
      }
      
      public function get buyDialogURL() : String
      {
         return this.m_assetPaths[WINDOW_BUY];
      }
      
      public function getBucketPackages() : Array
      {
         return this.m_staticData.bucketPackages;
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
         IrelandInnovationManager.getInstance().highlightTiles();
         FarmStatsManager.count("IrelandInnovation","UnlockTile","unlock land","click");
      }
      
      public function openBuyWindow(owner:FarmWindow) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         this.m_buyWindow = new IrelandInnovationBuyWindow(this.buyDialogURL,m_featureName,this.getBucketPackages(),owner,this.m_mainWindow);
         UI.displayPopup(this.m_buyWindow,false);
         FarmStatsManager.count("IrelandInnovation","Click","MedievalAxe","BuyWindow");
      }
      
      public function sinkConsumable() : void
      {
         var consumableNeeded:int = 0;
         if(this.isSinkActive() == true)
         {
            consumableNeeded = this.consumableNeededForUnlock();
            FeatureOptionsInventoryManager.getInstance().removeCount(this.ConsumableCode,consumableNeeded);
            FarmStatsManager.count("IrelandInnovation","sinkConsumable","MedeivalAxe",null,this.consumableCount.toString(),consumableNeeded.toString());
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkConsumable",null,[m_featureName]),true);
            this.updateBuildingLevel();
            if(this.getDayPoints() < 1100 && this.getKeyBuildingLevel() < 6)
            {
               this.saveFeatureOptionsKey(this.KEY_USER_STATE,this.EASY);
               this.m_mainWindow.updateDayBonus();
               this.m_mainWindow.updateProgressBar(true);
            }
            else
            {
               this.saveFeatureOptionsKey(this.KEY_USER_STATE,this.BUILDING_COMPLETED);
               this.saveFeatureOptionsKey(this.IS_PLAYING_FOR_LB_TODAY,1);
               this.saveFeatureOptionsKey(KEY_FLUSH_DAILY_REWARD_TASK,false);
               this.m_mainWindow.updateProgressBar(true);
            }
            if(this.getDayPoints() < 1100 && this.getKeyBuildingLevel() < 6)
            {
               this.m_mainWindow.refreshTaskFrame();
            }
         }
         else if(this.getDayPoints() >= 1100)
         {
         }
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
                  msg = "Collect more Medieval Axes to unlock the next level.";
               }
               else
               {
                  msg = "Use Medival Axes to unlock the next Building.";
               }
            }
         }
         return msg;
      }
      
      public function updateBuildingLevel() : *
      {
         var level:int = this.getKeyBuildingLevel();
         if(level < 6)
         {
            level += 1;
            this.saveFeatureOptionsKey(this.KEY_BUILDING_LEVEL,level);
         }
         this.showRewardLevelUpgradePopup(this.getKeyBuildingLevel());
         FarmStatsManager.count("IrelandInnovation","buildingUpgrade",BONUS_NAME_ARRAY[this.getKeyBuildingLevel() - 1],"" + this.getKeyBuildingLevel(),null,this.getActiveWeek());
      }
      
      public function shouldUpgradeLevel() : Boolean
      {
         var result:Boolean = false;
         var state:int = this.getFeatureOptionsKey(this.KEY_USER_STATE) as int;
         if(state == this.TOKEN_SINK)
         {
            result = true;
         }
         return result;
      }
      
      public function getKeyBuildingLevel() : int
      {
         return this.getFeatureOptionsKey(this.KEY_BUILDING_LEVEL) as int;
      }
      
      public function isFeatureEnded() : Boolean
      {
         var result:Boolean = false;
         var featureEnd:int = this.getFeatureOptionsKey(this.KEY_FEATURE_ENDED) as int;
         if(featureEnd == 1)
         {
            result = true;
         }
         return result;
      }
      
      public function isBuildingComplete() : Boolean
      {
         var result:Boolean = false;
         var userState:int = this.getUserState();
         if(userState == this.BUILDING_COMPLETED)
         {
            result = true;
         }
         return result;
      }
      
      public function getOrderboardType() : int
      {
         return this.getFeatureOptionsKey(this.IS_PLAYING_FOR_LB_TODAY) as int;
      }
      
      public function playForLeaderboard(callback:Function = null) : void
      {
         StatsManager.count(FEATURE_TRACKING,"leaderboard","Day" + this.activeDayIndex.toString(),"start",this.getDayPoints().toString());
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"playForLeaderboard",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName)),true);
         if(this.getUserState() == this.BUILDING_COMPLETED)
         {
            this.saveFeatureOptionsKey(this.IS_PLAYING_FOR_LB_TODAY,1);
         }
         else
         {
            this.saveFeatureOptionsKey(this.KEY_USER_STATE,this.EASY);
         }
         if(this.getFeatureOptionsKey(KEY_SHOW_LEADERBOARD_FIRST_TIME_IN_WEEK) == 1)
         {
            this.showLeaderboardUI();
            this.saveFeatureOptionsKey(KEY_SHOW_LEADERBOARD_FIRST_TIME_IN_WEEK,0);
         }
         FarmStatsManager.count(m_featureName,"Leaderboard","start");
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
      
      public function hasActiveWeekExpired() : Boolean
      {
         var expired:Boolean = false;
         var weekData:Object = this.getCurrentWeek();
         var curWeek:int = int(weekData.count);
         var activeWeek:int = this.getFeatureOptionsKey(KEY_CURRENT_WEEK) as int;
         if(activeWeek != curWeek)
         {
            expired = true;
         }
         return expired;
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
      
      public function onRedeemStarted() : void
      {
         if(this.hasExpiryDatePassedForFeature())
         {
            this.checkAndUpdateWeeklyStatus();
            this.saveFeatureOptionsKey(this.KEY_BONUS_REWARD_CLAIMED,1);
            FarmStatsManager.count(m_featureName,"grantBonus","FeatureEnd",this.getDayPoints().toString());
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onRedeemStarted",null,[m_featureName]),true);
         }
      }
      
      public function checkAndUpdateWeeklyStatus() : void
      {
         this.checkAndUpdateLeaderboardRewards();
      }
      
      public function checkAndUpdateLeaderboardRewards() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getLeaderboardEntries",this.grantLeaderboardRewards,[m_featureName,false]));
      }
      
      public function grantLeaderboardRewards(result:Object = null) : void
      {
         var collectionData:Object = null;
         var giftKey:String = null;
         var gifts:Array = null;
         var giftName:String = null;
         var weeklyLeaderboardData:Object = null;
         var score:int = 0;
         var rankString:String = null;
         if(result != null)
         {
            collectionData = this.getFeatureOption();
            if(Boolean(result["gift"]) && Boolean(result["giftLeaderboardName"]))
            {
               giftKey = m_featureName + "_" + result["giftLeaderboardName"] + "_awarded";
               gifts = new Array();
               for each(giftName in result["gift"])
               {
                  Global.player.addGift(giftName);
                  gifts.push(giftName);
               }
               if(!this.hasExpiryDatePassedForFeature())
               {
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
                  rankString = result["giftLeaderboardRank"].toString();
                  StatsManager.count(FEATURE_TRACKING,"leaderboard","Day" + this.activeDayIndex.toString(),"rank " + rankString,this.getDayPoints().toString());
                  this.ShowLBRewardPopup(result["gift"],result["giftLeaderboardRank"],result["giftLeaderboardName"],score);
               }
               else
               {
                  this.grantLBFeatureEndReward(result["gift"],result["giftLeaderboardRank"],result["giftLeaderboardName"],result["score"]);
               }
            }
            if(result["userData"])
            {
               collectionData[KEY_SAVED_LEADERBOARD_RESULT] = result["userData"];
               collectionData[this.WEEKLY_SCORE] = result["userData"]["value"];
            }
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,FEATURE_OPTIONS_KEY,collectionData);
         }
      }
      
      public function startNewDay(e:Event = null) : void
      {
         if(this.m_mainWindow.m_msg_overlayMc)
         {
            this.m_mainWindow.m_msg_overlayMc.visible = false;
         }
         var featureData:Object = this.getFeatureOption();
         if(this.hasActiveDayExpired() == true || this.getFeatureOptionsKey(this.KEY_USER_STATE) == this.NOT_INITIALIZED)
         {
            if(this.getFeatureOptionsKey(this.KEY_USER_STATE) != this.BUILDING_COMPLETED)
            {
               this.saveFeatureOptionsKey(this.IS_PLAYING_FOR_LB_TODAY,0);
               this.saveFeatureOptionsKey(this.KEY_ORDERBOARD_COUNT,0);
               Global.player.resetSeenFlag(this.LEADERBOARD_PLAYING_FLAG);
               this.saveFeatureOptionsKey(this.KEY_USER_STATE,this.EASY);
            }
            if(this.hasActiveWeekExpired())
            {
               this.checkAndUpdateWeeklyStatus();
            }
            this.saveFeatureOptionsKey(this.KEY_ACTIVE_DAY_TIMESTAMP,FarmGameUtil.getMidnightTimestamp() / 1000);
            this.redeemHasStarted = false;
            this.redeemMessageShown = false;
            if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_IRELAND))
            {
            }
            this.m_mainWindow.updateLockMc(false);
            this.saveFeatureOptionsKey(KEY_FLUSH_DAILY_REWARD_TASK,false);
            this.m_mainWindow.hideMessage();
            this.m_mainWindow.refreshOrdersCompleted();
            this.m_mainWindow.refreshWindow();
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startNewDay",null,[m_featureName]),true);
         }
      }
      
      public function redeemableTaskCount() : int
      {
         var redeemableTaskCount:int = 0;
         var savedactiveTasksKey:String = KEY_SAVED_ACTIVE_TASKS;
         if(this.isPlayingForLBToday())
         {
            savedactiveTasksKey = KEY_SAVED_LB_ACTIVE_TASKS;
         }
         var questTasks1:Object = this.getFeatureOptionsKey(savedactiveTasksKey);
         for(var i:int = 0; i < questTasks1.length; i++)
         {
            if(questTasks1[i][this.KEY_TASK_ID] != -1)
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
         var savedactiveTasksKey:String = KEY_SAVED_ACTIVE_TASKS;
         if(this.isPlayingForLBToday())
         {
            savedactiveTasksKey = KEY_SAVED_LB_ACTIVE_TASKS;
         }
         var questTasks1:Array = this.getFeatureOptionsKey(savedactiveTasksKey) as Array;
         if(progress >= questTasks1[slotIndex].total)
         {
            result = true;
         }
         return result;
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
         var consumableSearchStr:String = "Medieval Axe";
         CraftingManager.getInstance().openCraftshopWindow(CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType),consumableSearchStr,this.m_mainWindow,CRAFTSHOP_CONSUMABLE_TAB);
         FarmStatsManager.count("IrelandInnovation","Craft","Medieval Axe",this.consumableCount.toString());
      }
      
      public function openRewardViewWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         this.m_rewardWindow = new IrelandInnovationRewardWindow(m_featureName,this.rewardWindowURL);
         UI.displayPopup(this.m_rewardWindow,false);
      }
      
      public function get rewardWindowURL() : String
      {
         return this.m_assetPaths[WINDOW_REWARD];
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
      
      public function getWeeklyLeaderboardPoints() : int
      {
         var leaderboardPoints:int = 0;
         return this.getFeatureOptionsKey(this.WEEKLY_SCORE) as int;
      }
      
      public function get activeDayIndex() : int
      {
         var dayIndex:int = 0;
         var activeDayTS:Number = this.getFeatureOptionsKey(this.KEY_ACTIVE_DAY_TIMESTAMP) as Number;
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("09/02/2019") / FarmGameUtil.NUM_MSECS_IN_SECOND;
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
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("09/02/2019");
         dayIndex = (GlobalEngine.serverTime - featureStartDayTS) / FarmGameUtil.NUM_MSECS_IN_DAY;
         if(dayIndex < 0)
         {
            dayIndex = 0;
         }
         return dayIndex;
      }
      
      public function getTimeLeftInDay() : Number
      {
         var dayExpiredTime:Number = FarmGameUtil.getMidnightTimestamp() / 1000 + 86400;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return dayExpiredTime - currenttime;
      }
      
      public function initEventListener() : void
      {
         GlobalEventManager.getInstance().addEventListener(EVENT_IRELAND_INNOVATION_TILE_UNLOCK,this.showTileUnlockGrantPopup);
      }
      
      public function deleteEventListener() : void
      {
         GlobalEventManager.getInstance().removeEventListener(EVENT_IRELAND_INNOVATION_TILE_UNLOCK,this.showTileUnlockGrantPopup);
      }
      
      private function showRewardLevelUpgradePopup(upgrdaeLevel:int) : void
      {
         var lastUpgradeLevel:int = 0;
         lastUpgradeLevel = 6;
         var buildingData:Object = {
            "iconUrl":Global.getAssetURL("assets/buildings/xid_innovation_building_built_" + upgrdaeLevel + "_icon_200.png"),
            "isLastUpgrade":upgrdaeLevel == lastUpgradeLevel,
            "name":BONUS_NAME_ARRAY[upgrdaeLevel - 1]
         };
         UI.displayPopup(new IrelandInnovationBuildingUpgradeWindow("assets/dialogs/expansion/FV_RewardDialog.swf",m_featureName,buildingData,null,"assets/dialogs/ireland/RewardDialog.png"),false);
      }
      
      public function getActiveWeek() : *
      {
         var result:* = this.getFeatureOptionsKey(KEY_CURRENT_WEEK);
         if(result == "0")
         {
            result = "1";
         }
         return result;
      }
      
      public function grantUserRewardforLevel(milestone:int) : Object
      {
         var rewardItem:FarmItem = null;
         var reward:Object = this.getRewardsForTheDay(milestone)[0];
         if(milestone == 25)
         {
            rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(reward["value"]);
            this.checkAndAddToInventory(rewardItem.name);
         }
         return reward;
      }
      
      public function getRewardsForTheDay(milestone:*) : Vector.<Object>
      {
         var rewardXML:XML = null;
         var rewardObj:Object = null;
         var rewards:Vector.<Object> = new Vector.<Object>();
         if(this.m_rewardsBySlotName == null)
         {
            this.parseRewardsDataFromConfig(this.QUEST_NAME);
         }
         var rewardXMLList:XMLList = this.m_rewardsBySlotName[milestone].reward;
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
      
      protected function parseRewardsDataFromConfig(questName:String) : void
      {
         var orderBoardXml:XML = null;
         var rewardsList:XMLList = null;
         var rewardsByStage:XML = null;
         var str:String = null;
         var rewardsXMLListByStage:XMLList = null;
         this.m_rewardsBySlotName = {};
         orderBoardXml = Global.farmGameSettingsManager.getXML().IrelandInnovationMilestoneRewards.IrelandInnovationMilestoneReward.(@name == questName)[0];
         rewardsList = orderBoardXml.IrelandInnovationMilestones.milestone;
         for each(rewardsByStage in rewardsList)
         {
            str = rewardsByStage.@id;
            rewardsXMLListByStage = rewardsByStage.rewards;
            this.m_rewardsBySlotName[rewardsByStage.@id] = rewardsXMLListByStage;
         }
      }
      
      private function checkAndAddToInventory(itemName:String) : void
      {
         var validConsumableRewards:Object = {
            "pkg_medievalaxe_3":3,
            "pkg_medievalaxe_4":4,
            "pkg_medievalaxe_5":5
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
      
      public function getRewardsByMilestone(milestone:*) : Vector.<Object>
      {
         var rewardXML:XML = null;
         var rewardObj:Object = null;
         var rewards:Vector.<Object> = new Vector.<Object>();
         if(this.m_rewardsBySlotName == null)
         {
            this.parseRewardsDataFromConfig(this.QUEST_NAME);
         }
         var rewardXMLList:XMLList = this.m_rewardsBySlotName[milestone].reward;
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
      
      private function loadStaticData() : void
      {
         var itemXML:XML = null;
         var tile:XML = null;
         var asset:XML = null;
         var tileName:String = null;
         var leaderboardxml:XML = null;
         var feedConfigs:XMLList = null;
         var i:int = 0;
         var weekxml:XML = null;
         var rewardxml:XML = null;
         var rewardName:String = null;
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
         this.m_staticData.rewards = new Array();
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
            if(featureXML.hasOwnProperty("feedConfig"))
            {
               feedConfigs = featureXML.feedConfig.children();
               for(i = 0; i < feedConfigs.length(); i++)
               {
                  this.m_feedConfig[feedConfigs[i].@source.toString()] = new FeedData(m_featureName,feedConfigs[i]);
               }
            }
            if(featureXML.weeks)
            {
               for each(weekxml in featureXML.weeks.week)
               {
                  this.m_staticData.weeks.push(weekxml);
               }
            }
            if(featureXML.rewards)
            {
               for each(rewardxml in featureXML.rewards.reward)
               {
                  rewardName = rewardxml.@name.toString();
                  this.m_staticData.rewards.push(rewardName);
               }
            }
         }
      }
   }
}

