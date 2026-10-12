package Managers.OrderBoard
{
   import Cache.Classes.ZCacheUtil;
   import Classes.BuildingPart;
   import Classes.Constants.ArrowType;
   import Classes.Constants.QuestConstants;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureBuilding;
   import Classes.FeedData;
   import Classes.MapResource;
   import Classes.MultiRewardTreasureConstructionBuilding;
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.SimpleHarvestableResource;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.HUD.HUDWidgets.HudBottomBrazilInnovationButton;
   import Display.HUD.HUDWidgets.HudBottomDragonvalleyInnovationButton;
   import Display.QueuedIcons.QueuedIconWithArrow;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Helpers.Vector3;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.FeatureOptionsManager;
   import Managers.ItemFinderManager;
   import Managers.WorldSeasonsManager;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.AlaskaInnovationFinalRewardPopup;
   import Widgets.Windows.AlaskaInnovationRewardGrantWindow;
   import Widgets.Windows.AlaskaInnovationRewardsWindow;
   import Widgets.Windows.BrazilInnovationBoostWindow;
   import Widgets.Windows.BrazilInnovationTileUnlockWindow;
   import Widgets.Windows.DreamWorldInnovationWindow;
   import Widgets.Windows.FinalRewardSelectionBrazilInovationWindow;
   import Widgets.Windows.GenericSingleRewardPopup;
   import Widgets.Windows.NPCRewardGrantWindow;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   
   public class DreamWorldInnovationManager extends SpecialQuestManager
   {
      
      private static const SERVICE_NAME:String = "DreamWorldInnovationService";
      
      private static const HUD_ASSET:String = "assets/dialogs/brazil/innovation/FV_xbr_hud_Innovation.swf";
      
      private static const HUD_DRAGONVALLEY_ASSET:String = "assets/dialogs/alaska/innovation/FV_xsu_hud_Innovation.swf";
      
      private static const KEY_SAVED_ACTIVE_TASKS:String = "1";
      
      private static const KEY_TILE_UNLOCK_COUNT:String = "tile_unlock_count";
      
      public static const ALASKA_TILE_LIST:Array = new Array("xsu_rubbletreasure1","xsu_rubbletreasure2","xsu_rubbletreasure3","xsu_rubbletreasure4","xsu_rubbletreasure5","xsu_rubbletreasure6","xsu_rubbletreasure7","xsu_rubbletreasure8","xsu_rubbletreasure9","xsu_rubbletreasure_payer1","xsu_rubbletreasure_payer2","xsu_rubbletreasure_payer3","xsu_rubbletreasure_payer4","xsu_rubbletreasure_payer5","xsu_rubbletreasure_payer6","xsu_rubbletreasure_payer7","xsu_rubbletreasure_payer8","xsu_rubbletreasure_payer9","xsu_rubbletreasure_payer10","xsu_rubbletreasure_payer11","xsu_rubbletreasure_payer12","xsu_rubbletreasure_payer13","xsu_rubbletreasure_payer14","xsu_rubbletreasure_payer15","xsu_rubbletreasure_payer16","xsu_rubbletreasure_payer17","xsu_rubbletreasure_payer18","xsu_rubbletreasure_payer19","xsu_rubbletreasure_payer20","xsu_rubbletreasure_payer21","xsu_rubbletreasure_payer22","xsu_rubbletreasure_payer23");
      
      private static const KEY_SAVED_DUMPED_TIMESTAMP:String = "3";
      
      private static const KEY_NPC_MOVEMENTS:String = "4";
      
      private static const KEY_SAVED_FIRST_REWARD_RECEIVED:String = "5";
      
      private static const KEY_SAVED_SECOND_REWARD_RECEIVED:String = "6";
      
      private static const KEY_SAVED_THIRD_REWARD_RECEIVED:String = "7";
      
      private static const KEY_SAVED_PPD:String = "8";
      
      private static const KEY_SAVED_FEATURE_SHOWN_TIMESTAMP:String = "10";
      
      public static const KEY_SAVED_FINAL_REWARD_RECEIVED:String = "k11";
      
      public static const KEY_SAVED_FINAL_REWARD_BUILDINGNAME:String = "reward_building";
      
      private static const KEY_NPC1_FINAL_REWARD_RECEIVED:String = "12";
      
      private static const KEY_NPC2_FINAL_REWARD_RECEIVED:String = "13";
      
      private static const KEY_NPC3_FINAL_REWARD_RECEIVED:String = "14";
      
      public static const EVENT_ALASKA_INNOVATION_TILE_UNLOCK:String = "AlaskaInnovationTileUnlock";
      
      private static const KEY_NPC1:String = "npc1";
      
      private static const KEY_NPC2:String = "npc2";
      
      private static const KEY_NPC3:String = "npc3";
      
      private static const KEY_TIMESTAMP:String = "timestamp";
      
      private static const KEY_POINTS:String = "points";
      
      private static const VAL_EA_NPC1:Number = 1561507200;
      
      private static const VAL_EA_NPC2:Number = 1561680000;
      
      private static const VAL_EA_NPC3:Number = 1561852800;
      
      private static const VAL_GA_NPC1:Number = 1561852800;
      
      private static const VAL_GA_NPC2:Number = 1562025600;
      
      private static const VAL_GA_NPC3:Number = 1562198400;
      
      private static const VAL_FIRST_MILESTONE:int = 100;
      
      private static const VAL_SECOND_MILESTONE:int = 300;
      
      private static const VAL_THIRD_MILESTONE:int = 600;
      
      public static const VAL_FINAL_MILESTONE:int = 1000;
      
      private static const SKIP_COST:int = 1;
      
      private static const WINDOW_MAIN:String = "main";
      
      private static const WINDOW_MILESTONE_REWARD:String = "milestone_reward";
      
      private static const WINDOW_FINAL_REWARD:String = "final_reward";
      
      private static const WINDOW_NPC_FINAL_REWARD:String = "npc_final_reward";
      
      private static const WINDOW_REWARDS:String = "rewards";
      
      private static const WINDO_FINAL_REWARDS_SELECTION:String = "final_reward_selection";
      
      private static const WINDOW_BOOST:String = "boost";
      
      public static const ALASKA_TASK_POINTS_ITEM_CODE:String = "erl9";
      
      public static const BRAZIL_TILE_UNLOCK_COUNT:String = "5ij6";
      
      private static const SPECIAL_TILE_NAME:String = "xdw_rubbletreasure_special";
      
      private static const PM_FEATURE_CURRENCY_NAME:String = "morphpotion";
      
      private static const PM_FEATURE_THRESHOLD_COUNT:int = 30;
      
      private static const BUNDLE_ID:String = "AlaskaInnovation_Brag";
      
      private var m_isEA:Boolean;
      
      private var m_hud:QueuedIconWithArrow;
      
      private var m_newHud:HudBottomBrazilInnovationButton;
      
      private var m_currencyName:String = "task_points";
      
      private var m_endTimeStamp:Number = 0;
      
      private var m_tasksById:Object = null;
      
      private var m_assetPaths:Object = {};
      
      private var m_eaRewards:Array = new Array();
      
      private var m_gaRewards:Array = new Array();
      
      private var m_finalposition:int;
      
      private var m_finalfeatureKey:String;
      
      private var m_lastMilestoneRewards:Array = new Array();
      
      private var m_finalRewards:Array = new Array();
      
      private var m_feedConfig:Object = {};
      
      private const BUILDING_ASSET0:String = "assets/buildings/cookiejar4_icon_200.png";
      
      private const BUILDING_ASSET1:String = "assets/buildings/cookiejar3_icon_200.png";
      
      private const BUILDING_ASSET2:String = "assets/buildings/cookiejar1_icon_200.png";
      
      private const BUILDING_ASSET3:String = "assets/buildings/cookiejar0_icon_200.png";
      
      private const TILE_UNLOCK_ASSET:String = "assets/dialogs/brazil/innovation/FV_xbr_Innovation_Prize.swf";
      
      private const BOOST_UI:String = "assets/dialogs/alaska/innovation/FV_xsu_Innovation_Boost.swf";
      
      protected const KEY_ID:String = "id";
      
      protected const KEY_PROGRESS:String = "progress";
      
      protected const KEY_TOTAL:String = "total";
      
      public const TILE_UNLOCK_POINTS:Number = 25;
      
      private var m_window:DreamWorldInnovationWindow;
      
      private var m_rewardWindow:AlaskaInnovationFinalRewardPopup;
      
      private var m_rewardName:String;
      
      private var m_resultObject:Object;
      
      private var m_isActive:Boolean = false;
      
      protected var m_owner:FeatureBuilding;
      
      private var m_dragonvalleyInnovationHud:HudBottomDragonvalleyInnovationButton;
      
      private var m_milestonerewardWindow:GenericSingleRewardPopup;
      
      private var m_selectedReward:String = null;
      
      private var m_finalrewardGrantWindow:AlaskaInnovationRewardGrantWindow;
      
      public const KEY_ACTIVE_DAY_TIMESTAMP:String = "32";
      
      public const KEY_DAY_POINTS:String = "33";
      
      public const KEY_DAY_REWARD_GRANT_STATUS:String = "34";
      
      public const DAY_REWARD_MILESTONE_POINTS:int = 50;
      
      public function DreamWorldInnovationManager(featureName:String)
      {
         super(featureName);
         if(!this.featureConfig)
         {
            return;
         }
         this.parseFeatureConfig();
         this.parseTaskObjectsFromCOnfig(m_featureName);
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
         this.m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ALASKA);
      }
      
      public static function getInstance(featureName:String) : DreamWorldInnovationManager
      {
         var instance:DreamWorldInnovationManager = getInstanceOfClass(featureName,DreamWorldInnovationManager) as DreamWorldInnovationManager;
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
      
      public function setupNewHud() : void
      {
         this.m_newHud = new HudBottomBrazilInnovationButton(HUD_ASSET,m_featureName);
         Global.hud.setBottomHudBrazilInnovationButton(this.m_newHud as HudBottomBrazilInnovationButton);
      }
      
      public function setupDragonvalleyHud() : void
      {
         this.m_dragonvalleyInnovationHud = new HudBottomDragonvalleyInnovationButton(HUD_DRAGONVALLEY_ASSET,m_featureName);
         Global.hud.setBottomHudDragonvalleyInnovationButton(this.m_dragonvalleyInnovationHud as HudBottomDragonvalleyInnovationButton);
      }
      
      public function get isFeatureActive() : Boolean
      {
         return this.m_isActive;
      }
      
      public function getDialogUrl() : String
      {
         return this.m_assetPaths[WINDOW_MAIN];
      }
      
      public function showMainUI() : void
      {
         this.m_window = new DreamWorldInnovationWindow();
         this.startQuest(this.m_window.refreshTaskFrame);
         UI.displayPopup(this.m_window);
      }
      
      public function showRewardsUI(window:DreamWorldInnovationWindow) : void
      {
         var rewardwindow:AlaskaInnovationRewardsWindow = new AlaskaInnovationRewardsWindow(this.m_assetPaths[WINDOW_REWARDS],m_featureName,WINDOW_REWARDS,window);
         UI.displayPopup(rewardwindow,false);
      }
      
      public function showBoostUI(window:DreamWorldInnovationWindow) : void
      {
         StatsManager.count(m_featureName,"Boost");
         UI.displayPopup(new BrazilInnovationBoostWindow(this.BOOST_UI,m_featureName,WINDOW_BOOST,this.untintWindow,window),false);
      }
      
      public function untintWindow(evt:Event = null) : void
      {
         if(this.m_window)
         {
            this.m_window.untintWindow();
            this.m_window.enableInput = true;
         }
      }
      
      public function closeMainWindow() : void
      {
         if(this.m_window)
         {
            this.m_window.close();
         }
      }
      
      public function isAllTilesUnlocked() : Boolean
      {
         if(Global.world.getObjectsByNames(ALASKA_TILE_LIST).length)
         {
            return false;
         }
         return true;
      }
      
      protected function onTransactionAdded(event:TransactionEvent) : void
      {
         this.checkForTaskUpdates(event);
      }
      
      protected function parseFeatureConfig() : void
      {
         var asset:XML = null;
         var feedConfigs:XMLList = null;
         var i:int = 0;
         var division:XML = null;
         var item:XML = null;
         var reward:XML = null;
         var config:XML = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         if(config != null)
         {
            this.m_isActive = true;
            this.m_currencyName = config["currency"]["@name"];
            this.m_endTimeStamp = FarmGameUtil.synchronizedDateToNumber(config["listEndDate"]);
            if(config.hasOwnProperty("assets"))
            {
               for each(asset in config.assets.asset)
               {
                  this.m_assetPaths[asset.@name] = asset.@path.toString();
               }
            }
            if(config.hasOwnProperty("feedConfig"))
            {
               feedConfigs = config.feedConfig.children();
               for(i = 0; i < feedConfigs.length(); i++)
               {
                  this.m_feedConfig[feedConfigs[i].@source.toString()] = new FeedData(m_featureName,feedConfigs[i]);
               }
            }
            if(config.hasOwnProperty("divisions"))
            {
               for each(division in config.divisions.division)
               {
                  for each(item in division.items.item)
                  {
                     if(division.@name == "ea")
                     {
                        this.m_eaRewards.push(item.@name.toString());
                     }
                     else if(division.@name == "ga")
                     {
                        this.m_gaRewards.push(item.@name.toString());
                     }
                     else if(division.@name == "finalreward")
                     {
                        this.m_lastMilestoneRewards.push(item.@name.toString());
                     }
                  }
               }
            }
            if(config.hasOwnProperty("rewards"))
            {
               for each(reward in config.rewards.reward)
               {
                  this.m_finalRewards.push(reward.@name.toString());
               }
            }
         }
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
      
      public function grantPointsForTask(pointsForTask:int) : void
      {
         var currentDayPoints:int = 0;
         var finalRewardTaken:int = this.getFeatureOptionsKey(KEY_SAVED_FINAL_REWARD_RECEIVED) as int;
         if(finalRewardTaken)
         {
            if(this.hasActiveDayExpired())
            {
               this.saveFeatureOptionsKey(this.KEY_ACTIVE_DAY_TIMESTAMP,FarmGameUtil.getMidnightTimestamp() / 1000);
               this.saveFeatureOptionsKey(this.KEY_DAY_REWARD_GRANT_STATUS,0);
               this.saveFeatureOptionsKey(this.KEY_DAY_POINTS,0);
            }
            currentDayPoints = this.getFeatureOptionsKey(this.KEY_DAY_POINTS) as int;
            currentDayPoints += pointsForTask;
            this.saveFeatureOptionsKey(this.KEY_DAY_POINTS,currentDayPoints);
         }
         else
         {
            FeatureOptionsInventoryManager.getInstance().addCount(ALASKA_TASK_POINTS_ITEM_CODE,pointsForTask);
         }
         this.m_window.NPCMovement();
      }
      
      public function getOrderboardProgress() : Number
      {
         return FeatureOptionsInventoryManager.getInstance().getCount(ALASKA_TASK_POINTS_ITEM_CODE);
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
      
      protected function parseTaskObjectsFromCOnfig(questName:String) : void
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
            if(Boolean(this.m_dragonvalleyInnovationHud) && !this.isFeatureComplete())
            {
               this.m_dragonvalleyInnovationHud.refresh(1);
            }
         }
      }
      
      public function saveProgressForPlayer(progressArray:Array) : void
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
         this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,tasksToSave as Object);
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
         this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,tasksToSave as Object);
      }
      
      public function showTileUnlockCountMc() : Number
      {
         var itemName:String = null;
         var result:int = 0;
         var inventoryTileCount:Number = FeatureOptionsInventoryManager.getInstance().getCount(BRAZIL_TILE_UNLOCK_COUNT);
         var count:Object = this.getFeatureOptionsKey(KEY_TILE_UNLOCK_COUNT) as Object;
         if(!this.isFinalRewardChosen())
         {
            if(Boolean(inventoryTileCount) && inventoryTileCount > count)
            {
               result = inventoryTileCount - (count as Number);
               FeatureOptionsInventoryManager.getInstance().addCount(ALASKA_TASK_POINTS_ITEM_CODE,result * this.TILE_UNLOCK_POINTS);
               itemName = Global.farmGameSettingsManager.getFarmItemNameByCode(ALASKA_TASK_POINTS_ITEM_CODE);
               this.addBuildingPartForUpgrade(itemName,result * this.TILE_UNLOCK_POINTS);
            }
         }
         return result;
      }
      
      public function addTileFeatureOptions() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"addTileUnlock",this.onComplete,new Array(m_featureName)),true);
      }
      
      public function onComplete(result:Object) : void
      {
         var inventoryTileCount:Number = NaN;
         if(result)
         {
            this.m_resultObject = result;
            inventoryTileCount = FeatureOptionsInventoryManager.getInstance().getCount(BRAZIL_TILE_UNLOCK_COUNT);
            if(inventoryTileCount)
            {
               FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,KEY_TILE_UNLOCK_COUNT,inventoryTileCount);
            }
         }
      }
      
      public function initEventListener() : void
      {
         GlobalEventManager.getInstance().addEventListener(EVENT_ALASKA_INNOVATION_TILE_UNLOCK,this.showGrantPopup);
      }
      
      public function deleteEventListener() : void
      {
         GlobalEventManager.getInstance().removeEventListener(EVENT_ALASKA_INNOVATION_TILE_UNLOCK,this.showGrantPopup);
      }
      
      public function showGrantPopup(e:Event = null) : void
      {
         if(this.isFeatureActive && this.getNPCProgress() < DreamWorldInnovationManager.VAL_FINAL_MILESTONE)
         {
            StatsManager.count(m_featureName,"TileBoost","","25",this.getNPCProgress().toString());
            UI.displayPopup(new BrazilInnovationTileUnlockWindow(this.TILE_UNLOCK_ASSET,m_featureName));
         }
      }
      
      protected function getFeatureOptionsKey(optionName:String) : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,optionName);
      }
      
      protected function saveFeatureOptionsKey(optionName:String, optionsValue:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,optionName,optionsValue);
      }
      
      override public function getTasks() : Vector.<FarmTask>
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
                  taskObj.type = "erl9";
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
      
      public function isTaskDumped(questIndex:int) : Boolean
      {
         var result:Boolean = false;
         var savedTasks:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         if(!savedTasks[questIndex].hasOwnProperty(this.KEY_ID))
         {
            result = true;
         }
         return result;
      }
      
      public function getTaskProgress(taskIndex:int) : int
      {
         var progress:int = 0;
         var savedTasksProgress:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         if(Boolean(savedTasksProgress) && Boolean(savedTasksProgress[taskIndex][this.KEY_PROGRESS]))
         {
            progress = int(savedTasksProgress[taskIndex][this.KEY_PROGRESS]);
         }
         return progress;
      }
      
      public function npcmovements() : void
      {
         var timeStamp:Number = NaN;
         var hourdiff:int = 0;
         var npcm:Object = this.getFeatureOptionsKey(KEY_NPC_MOVEMENTS);
         if(npcm != null)
         {
            timeStamp = Number(npcm[KEY_TIMESTAMP]);
            hourdiff = (GlobalEngine.serverTime - timeStamp * 1000) / 3600000;
            if(Boolean(hourdiff) && Boolean(npcm[KEY_TIMESTAMP]))
            {
               npcm[KEY_NPC1] += this.firstNpcMovemet(hourdiff);
               npcm[KEY_NPC2] += this.secondNpcMovemet(hourdiff);
               npcm[KEY_NPC3] += this.thirdNpcMovemet(hourdiff);
               npcm[KEY_TIMESTAMP] = timeStamp + hourdiff * 3600;
               this.saveFeatureOptionsKey(KEY_NPC_MOVEMENTS,npcm);
            }
         }
      }
      
      protected function firstNpcMovemet(hours:int) : int
      {
         var firstNpcMovement:Number = NaN;
         var featureShownTimeStamp:Number = this.getFeatureOptionsKey(KEY_SAVED_FEATURE_SHOWN_TIMESTAMP) as Number;
         var numOfHour1:Number = 0;
         if(this.m_isEA)
         {
            numOfHour1 = (VAL_EA_NPC1 - featureShownTimeStamp) / 3600;
         }
         else
         {
            numOfHour1 = (VAL_GA_NPC1 - featureShownTimeStamp) / 3600;
         }
         firstNpcMovement = VAL_FINAL_MILESTONE / numOfHour1 * hours;
         return Math.round(firstNpcMovement);
      }
      
      protected function secondNpcMovemet(hours:int) : int
      {
         var secondNpcMovemet:Number = NaN;
         var featureShownTimeStamp:Number = this.getFeatureOptionsKey(KEY_SAVED_FEATURE_SHOWN_TIMESTAMP) as Number;
         var numOfHour2:Number = 0;
         if(this.m_isEA)
         {
            numOfHour2 = (VAL_EA_NPC2 - featureShownTimeStamp) / 3600;
         }
         else
         {
            numOfHour2 = (VAL_GA_NPC2 - featureShownTimeStamp) / 3600;
         }
         secondNpcMovemet = VAL_FINAL_MILESTONE / numOfHour2 * hours;
         return Math.round(secondNpcMovemet);
      }
      
      protected function thirdNpcMovemet(hours:int) : int
      {
         var thirdNpcMovemet:Number = NaN;
         var featureShownTimeStamp:Number = this.getFeatureOptionsKey(KEY_SAVED_FEATURE_SHOWN_TIMESTAMP) as Number;
         var numOfHour3:Number = 0;
         if(this.m_isEA)
         {
            numOfHour3 = (VAL_EA_NPC3 - featureShownTimeStamp) / 3600;
         }
         else
         {
            numOfHour3 = (VAL_GA_NPC3 - featureShownTimeStamp) / 3600;
         }
         thirdNpcMovemet = VAL_FINAL_MILESTONE / numOfHour3 * hours;
         return Math.round(thirdNpcMovemet);
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
      
      public function startQuest(callback:Function) : void
      {
         var savedTaskInfo:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         if(!(savedTaskInfo && savedTaskInfo.length))
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startQuest",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName)),true);
         }
      }
      
      public function redeemRewardPoints(questIndex:int, callback:Function) : void
      {
         var tasks:Vector.<FarmTask> = this.getTasks();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"redeemRewardPoints",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,questIndex)),true);
         this.resetActionCountsForTasks(tasks[questIndex]);
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
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,questIndex)),true);
            this.resetActionCountsForTasks(tasks[questIndex]);
         }
         else
         {
            callback.call();
         }
      }
      
      public function getBuildingCurrentAsset() : String
      {
         var itemName:String = null;
         var item:FarmItem = null;
         var score:Number = this.getNPCProgress();
         switch(true)
         {
            case score < VAL_FIRST_MILESTONE:
               return Global.getAssetURL(this.BUILDING_ASSET0);
            case score < VAL_SECOND_MILESTONE && score >= VAL_FIRST_MILESTONE:
               return Global.getAssetURL(this.BUILDING_ASSET1);
            case score < VAL_THIRD_MILESTONE && score >= VAL_SECOND_MILESTONE:
               return Global.getAssetURL(this.BUILDING_ASSET2);
            case score < VAL_FINAL_MILESTONE && score >= VAL_THIRD_MILESTONE:
               return Global.getAssetURL(this.BUILDING_ASSET3);
            default:
               if(FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,KEY_SAVED_FINAL_REWARD_BUILDINGNAME) != "0" && FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,KEY_SAVED_FINAL_REWARD_BUILDINGNAME) != null)
               {
                  itemName = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,KEY_SAVED_FINAL_REWARD_BUILDINGNAME) as String;
                  item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
                  return item.getImageByName("feed");
               }
               return null;
         }
      }
      
      public function isFeatureComplete() : Boolean
      {
         var score:Number = this.getNPCProgress();
         return score >= VAL_FINAL_MILESTONE;
      }
      
      public function skipDumpedTask(questIndex:int, callback:Function) : void
      {
         var dumpTimestamp:Object = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         if(Global.player.canBuyCash(SKIP_COST))
         {
            Global.player.cash -= SKIP_COST;
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipDumpedTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,questIndex)),true);
            dumpTimestamp = this.getFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP) as Object;
            dumpTimestamp[questIndex] = 0;
            this.saveFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP,dumpTimestamp);
            this.resetActionCountsForTasks(tasks[questIndex]);
         }
         else
         {
            callback.call();
         }
      }
      
      public function dumpTask(questIndex:int, callback:Function) : void
      {
         var dumpTimestamp:Object = null;
         if(this.canDumpTask(questIndex))
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"dumpTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,questIndex)),true);
            dumpTimestamp = this.getFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP) as Object;
            if(dumpTimestamp == null)
            {
               dumpTimestamp = new Object();
            }
            dumpTimestamp[questIndex] = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            this.saveFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP,dumpTimestamp);
         }
      }
      
      public function canDumpTask(questIndex:int) : Boolean
      {
         var currentTime:Number = NaN;
         var result:Boolean = true;
         var throttleTimeInSeconds:Number = 4 * FarmGameUtil.NUM_SECS_IN_HOUR;
         var dumpTimestamp:Object = this.getFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP) as Object;
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
         var throttleTimeInSeconds:Number = 4 * FarmGameUtil.NUM_SECS_IN_HOUR;
         var dumpTimestamp:Object = this.getFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP) as Object;
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
         var dumpTimestamp:Object = this.getFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP) as Object;
         dumpTimestamp[questIndex] = 0;
         this.saveFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP,dumpTimestamp);
         this.resetActionCountsForTasks(tasks[questIndex]);
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
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkGold",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,questIndex)),true);
            StatsManager.count(m_featureName,"Coin Sink","",tasks[questIndex].total.toString(),this.getNPCProgress().toString());
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
         StatsManager.count(m_featureName,"Sink Bushel","",tasks[questIndex].total.toString(),this.getNPCProgress().toString());
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
      
      override public function getRewards() : Vector.<Object>
      {
         return null;
      }
      
      public function isFinalRewardChosen() : Boolean
      {
         if(this.getRewardBuildingName() != null && this.getRewardBuildingName() != "0")
         {
            return true;
         }
         return false;
      }
      
      public function grantFinalReward() : void
      {
         if(this.getNPC3Progress() >= VAL_FINAL_MILESTONE)
         {
            this.m_finalposition = 4;
            this.m_finalfeatureKey = m_featureName + "_fourth_position";
         }
         else if(this.getNPC2Progress() >= VAL_FINAL_MILESTONE)
         {
            this.m_finalposition = 3;
            this.m_finalfeatureKey = m_featureName + "_third_position";
         }
         else if(this.getNPC1Progress() >= VAL_FINAL_MILESTONE)
         {
            this.m_finalposition = 2;
            this.m_finalfeatureKey = m_featureName + "_second_position";
         }
         else
         {
            this.m_finalposition = 1;
            this.m_finalfeatureKey = m_featureName + "_first_position";
         }
         this.m_rewardWindow = new AlaskaInnovationFinalRewardPopup(this.m_assetPaths[WINDOW_FINAL_REWARD],this.m_finalfeatureKey,null,this.openRewardSelectionWindow,this.m_finalposition);
         UI.displayPopup(this.m_rewardWindow,false);
      }
      
      public function openRewardSelectionWindow(e:Event = null) : void
      {
         if(this.m_rewardWindow)
         {
            this.m_rewardWindow.close();
         }
         UI.displayPopup(new FinalRewardSelectionBrazilInovationWindow(this.m_assetPaths[WINDO_FINAL_REWARDS_SELECTION],m_featureName,this.m_finalposition),false);
         StatsManager.count(m_featureName,"Milestone","Final Position",this.m_finalposition.toString());
      }
      
      public function showOtherNPCFinalRewardTaken() : void
      {
         var featureKey:String = null;
         var opponentName:String = null;
         var opponentPosition:String = null;
         var showReward:Boolean = false;
         var firstRewardTaken:Boolean = this.getFeatureOptionsKey(KEY_NPC1_FINAL_REWARD_RECEIVED) as Boolean;
         var secondRewardTaken:Boolean = this.getFeatureOptionsKey(KEY_NPC2_FINAL_REWARD_RECEIVED) as Boolean;
         var thirdRewardTaken:Boolean = this.getFeatureOptionsKey(KEY_NPC3_FINAL_REWARD_RECEIVED) as Boolean;
         if(this.getNPC3Progress() >= VAL_FINAL_MILESTONE && !thirdRewardTaken)
         {
            showReward = true;
            featureKey = m_featureName + "_third_reward_taken";
            this.saveFeatureOptionsKey(KEY_NPC3_FINAL_REWARD_RECEIVED,true);
            opponentName = "Kimberly";
            opponentPosition = "3";
         }
         else if(this.getNPC2Progress() >= VAL_FINAL_MILESTONE && !secondRewardTaken)
         {
            showReward = true;
            featureKey = m_featureName + "_second_reward_taken";
            this.saveFeatureOptionsKey(KEY_NPC2_FINAL_REWARD_RECEIVED,true);
            opponentName = "Claire";
            opponentPosition = "2";
         }
         else if(this.getNPC1Progress() >= VAL_FINAL_MILESTONE && !firstRewardTaken)
         {
            showReward = true;
            featureKey = m_featureName + "_first_reward_taken";
            this.saveFeatureOptionsKey(KEY_NPC1_FINAL_REWARD_RECEIVED,true);
            opponentName = "Barbra";
            opponentPosition = "1";
         }
         if(showReward)
         {
            StatsManager.count("AlaskaInnovation",opponentName,opponentPosition,this.getNPCProgress().toString());
            UI.displayPopup(new NPCRewardGrantWindow(this.m_assetPaths[WINDOW_NPC_FINAL_REWARD],featureKey),false);
         }
      }
      
      public function grantMilestoneReward() : void
      {
         var featureKey:String = null;
         var item:FarmItem = null;
         var milestonePosition:String = null;
         this.m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ALASKA);
         var showReward:Boolean = false;
         var firstRewardGrant:Boolean = this.getFeatureOptionsKey(KEY_SAVED_FIRST_REWARD_RECEIVED) as Boolean;
         var secondRewardGrant:Boolean = this.getFeatureOptionsKey(KEY_SAVED_SECOND_REWARD_RECEIVED) as Boolean;
         var thirdRewardGrant:Boolean = this.getFeatureOptionsKey(KEY_SAVED_THIRD_REWARD_RECEIVED) as Boolean;
         if(this.getNPCProgress() >= VAL_FIRST_MILESTONE && !firstRewardGrant)
         {
            showReward = true;
            milestonePosition = "first";
            featureKey = m_featureName + "_first_milestone_reward";
            this.saveFeatureOptionsKey(KEY_SAVED_FIRST_REWARD_RECEIVED,true);
            this.m_rewardName = this.getMilestoneRewardItemName(0);
         }
         else if(this.getNPCProgress() >= VAL_SECOND_MILESTONE && !secondRewardGrant)
         {
            showReward = true;
            milestonePosition = "second";
            featureKey = m_featureName + "_second_milestone_reward";
            this.saveFeatureOptionsKey(KEY_SAVED_SECOND_REWARD_RECEIVED,true);
            this.m_rewardName = this.getMilestoneRewardItemName(1);
         }
         else if(this.getNPCProgress() >= VAL_THIRD_MILESTONE && !thirdRewardGrant)
         {
            showReward = true;
            milestonePosition = "third";
            featureKey = m_featureName + "_third_milestone_reward";
            this.saveFeatureOptionsKey(KEY_SAVED_THIRD_REWARD_RECEIVED,true);
            this.m_rewardName = this.getMilestoneRewardItemName(2);
         }
         if(showReward)
         {
            Global.player.addGift(this.m_rewardName);
            item = Global.farmGameSettingsManager.getFarmItemByName(this.m_rewardName);
            if(this.m_isEA)
            {
               featureKey += "_ea";
            }
            this.m_milestonerewardWindow = new GenericSingleRewardPopup("assets/dialogs/expansion/FV_RewardDialog_Share.swf",featureKey,item,this.postBragFeed,"assets/dialogs/alaska/RewardDialog.png");
            UI.displayPopup(this.m_milestonerewardWindow,false);
            StatsManager.count(m_featureName,"Milestone",milestonePosition);
         }
      }
      
      public function showFinalRewardPopup(selectedRewardName:String, position:int) : void
      {
         var finalMileStoneRewards:Array = new Array();
         this.m_selectedReward = selectedRewardName;
         finalMileStoneRewards = this.getFinalMileStoneReward(position);
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(selectedRewardName);
         UI.displayPopup(this.m_finalrewardGrantWindow = new AlaskaInnovationRewardGrantWindow("assets/dialogs/expansion/FV_RewardDialog.swf",m_featureName + "lastmilestone",rewardItem,this.panToRewardBuilding,"assets/dialogs/alaska/RewardDialog.png",finalMileStoneRewards),false);
      }
      
      public function getMilestoneRewardItemName(index:int) : String
      {
         var itemName:String = null;
         if(this.m_isEA)
         {
            itemName = this.m_eaRewards[index];
         }
         else
         {
            itemName = this.m_gaRewards[index];
         }
         return itemName;
      }
      
      public function getFinalMileStoneReward(position:int) : Array
      {
         var index:int = position - 1;
         var result:Array = new Array();
         var length:int = int(this.m_lastMilestoneRewards.length);
         var item:String = null;
         for(var i:int = 0; i < length - index; i++)
         {
            item = this.m_lastMilestoneRewards[length - 1 - i];
            result.push(item);
         }
         return result;
      }
      
      public function getFinalRewardInIntermediateState() : String
      {
         return this.m_finalRewards[0];
      }
      
      public function getFinalReward() : Array
      {
         return this.m_finalRewards;
      }
      
      public function get currencyName() : String
      {
         return this.m_currencyName;
      }
      
      public function getNPCProgress() : Number
      {
         return FeatureOptionsInventoryManager.getInstance().getCount(ALASKA_TASK_POINTS_ITEM_CODE);
      }
      
      public function getPlayerPosition() : int
      {
         return this.getFeatureOptionsKey(KEY_SAVED_FINAL_REWARD_RECEIVED) as int;
      }
      
      public function isFirstMilestoneAchieved() : Boolean
      {
         return this.getFeatureOptionsKey(KEY_SAVED_FIRST_REWARD_RECEIVED) as Boolean;
      }
      
      public function getRewardBuildingName() : String
      {
         return this.getFeatureOptionsKey(KEY_SAVED_FINAL_REWARD_BUILDINGNAME) as String;
      }
      
      public function isSecondMilestoneAchieved() : Boolean
      {
         return this.getFeatureOptionsKey(KEY_SAVED_SECOND_REWARD_RECEIVED) as Boolean;
      }
      
      public function isThirdMilestoneAchieved() : Boolean
      {
         return this.getFeatureOptionsKey(KEY_SAVED_THIRD_REWARD_RECEIVED) as Boolean;
      }
      
      public function getNPC1Progress() : Number
      {
         var result:Number = 0;
         var npcm:Object = this.getFeatureOptionsKey(KEY_NPC_MOVEMENTS) as Object;
         if(Boolean(npcm) && Boolean(npcm[KEY_NPC1]))
         {
            result = npcm[KEY_NPC1] as Number;
            if(result < 0)
            {
               result = 0;
            }
         }
         return result;
      }
      
      public function getNPC2Progress() : Number
      {
         var result:Number = 0;
         var npcm:Object = this.getFeatureOptionsKey(KEY_NPC_MOVEMENTS) as Object;
         if(Boolean(npcm) && Boolean(npcm[KEY_NPC2]))
         {
            result = npcm[KEY_NPC2] as Number;
            if(result < 0)
            {
               result = 0;
            }
         }
         return result;
      }
      
      public function getNPC3Progress() : Number
      {
         var result:Number = 0;
         var npcm:Object = this.getFeatureOptionsKey(KEY_NPC_MOVEMENTS) as Object;
         if(Boolean(npcm) && Boolean(npcm[KEY_NPC3]))
         {
            result = npcm[KEY_NPC3] as Number;
            if(result < 0)
            {
               result = 0;
            }
         }
         return result;
      }
      
      private function panToSpecialTile(event:Event) : void
      {
         var specialTileObj:MultiRewardTreasureConstructionBuilding = null;
         if(this.m_rewardWindow)
         {
            this.m_rewardWindow.close();
         }
         var specialTile:Array = Global.world.getObjectsByName(SPECIAL_TILE_NAME);
         if(Boolean(specialTile) && specialTile.length > 0)
         {
            ItemFinderManager.getInstance().highlightWorldItems(SPECIAL_TILE_NAME);
            specialTileObj = specialTile[0] as MultiRewardTreasureConstructionBuilding;
            specialTileObj.onClick();
         }
      }
      
      private function postBragFeed(event:Event) : void
      {
         if(Boolean(this.m_resultObject) && Boolean(this.m_resultObject["feedData"]))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(this.m_resultObject["feedData"]);
         }
         if(this.m_milestonerewardWindow)
         {
            this.m_milestonerewardWindow.close();
         }
      }
      
      public function replceIntermediateRewardWithFinalReward(indexChosen:int, position:String) : void
      {
         var finishedItem:FarmItem = null;
         var currentItemName:String = null;
         var currentItem:FarmItem = null;
         var currentPosition:Vector3 = null;
         var id:Number = NaN;
         var tempClass:Class = null;
         var transformedObject:MapResource = null;
         var storageBuilding:StorageBuilding = null;
         var interMediateReward:String = this.getFinalRewardInIntermediateState();
         var finalRewards:Array = this.getFinalReward();
         var finalReward:String = finalRewards[indexChosen];
         StatsManager.count("AlaskaInnovation","TempleChoice",finalReward,position);
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,KEY_SAVED_FINAL_REWARD_BUILDINGNAME,finalReward);
         var m_owner:FeatureBuilding = Global.world.getObjectsByName(interMediateReward)[0];
         var finishedName:String = finalReward;
         if(Boolean(finishedName) && finishedName != "")
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
            }
         }
      }
      
      public function addBuildingPartForUpgrade(itemName:String = "", count:int = 0) : Boolean
      {
         var buildings:Array = null;
         var featureBuilding:FeatureBuilding = null;
         var giftItem:FarmItem = null;
         var buildingPart:BuildingPart = null;
         if(Boolean(itemName) && count >= 1)
         {
            buildings = Global.world.getObjectsByName("xsu_girlscoutlily");
            featureBuilding = buildings[0] as FeatureBuilding;
            giftItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(giftItem != null)
            {
               buildingPart = new BuildingPart(giftItem.name);
               while(count)
               {
                  featureBuilding.addExpansionPart(buildingPart);
                  count--;
               }
               featureBuilding.reloadImage();
               return true;
            }
         }
         return false;
      }
      
      public function panToRewardBuilding(e:Event = null) : void
      {
         StatsManager.count("AlaskaInnovation","TempleChoice","VisitDogHouse");
         if(this.m_finalrewardGrantWindow)
         {
            this.m_finalrewardGrantWindow.close();
         }
         if(this.m_selectedReward)
         {
            this.panToBuilding(this.m_selectedReward);
         }
      }
      
      public function panToBuilding(buildingName:String) : void
      {
         if(this.m_rewardWindow)
         {
            this.m_rewardWindow.close();
         }
         if(this.m_window)
         {
            this.m_window.close();
         }
         var brazilInnovationBuildingItem:Array = Global.world.getObjectsByName(buildingName);
         if(Boolean(brazilInnovationBuildingItem) && brazilInnovationBuildingItem.length > 0)
         {
            ItemFinderManager.getInstance().highlightWorldItems(buildingName);
         }
      }
      
      public function getInnovationFeatureName() : String
      {
         return "AlaskaInnovation";
      }
   }
}

