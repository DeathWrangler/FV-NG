package Managers.OrderBoard
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.ArrowType;
   import Classes.Constants.QuestConstants;
   import Classes.FeatureBuilding;
   import Classes.FeedData;
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.ZItem.FarmItem;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.QueuedIcons.QueuedIconWithArrow;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Events.FarmGameWorldEvent;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.FeatureOptionsManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.CarribeanGenericSingleRewardPopup;
   import Widgets.Windows.CongratsForNewCaribbeanInovationWindow;
   import Widgets.Windows.FarmRunV5GameWindow;
   import Widgets.Windows.FarmRunV5MainWindow;
   import Widgets.Windows.FarmRunV5OrderBoardWindow;
   import Widgets.Windows.FarmRunV5ScoreBoardWindow;
   import Widgets.Windows.FarmRunV5SingleRewardPopup;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   import mx.utils.StringUtil;
   
   public class FarmRunV5Manager extends SpecialQuestManager
   {
      
      private static const SERVICE_NAME:String = "FarmRunV5Service";
      
      public static const FEATURE_NAME:String = "FarmRunV5";
      
      public static const FEATURE_TRACKING:String = "GPF_FarmRunV5";
      
      public static const TYPE_MINI_GAME_TIME_BOOST:String = "minigametimeboost";
      
      public static const TYPE_MINI_GAME_REPLAY:String = "minigamereplay";
      
      private static const ACTION_TYPE_TO_COST:Object = {
         "minigametimeboost":1,
         "minigamereplay":2
      };
      
      private static const WINDOW_MAIN:String = "main";
      
      private static const WINDOW_ORDERBOARD:String = "orderboard";
      
      private static const WINDOW_GAME:String = "game";
      
      private static const WINDOW_MESSAGE:String = "message";
      
      private static const KEY_MINI_GAME_ACTIVE_ROUND:String = "active_round";
      
      private static const KEY_MINI_GAME_R1_SCORE:String = "score1";
      
      private static const KEY_MINI_GAME_R2_SCORE:String = "score2";
      
      private static const KEY_MINI_GAME_PAIRED_SLOTS:String = "mini_game_paired_slots";
      
      private static const KEY_MINI_GAME_LAYOUT:String = "mini_game_layout";
      
      private static const KEY_MINI_GAME_CURRENT_POOL_INDEX:String = "mini_game_current_pool_index";
      
      private static const KEY_SAVED_ACTIVE_TASKS:String = "1";
      
      private static const KEY_SAVED_DUMPED_TIMESTAMP:String = "3";
      
      public static const KEY_SAVED_FINAL_REWARD_RECEIVED:String = "k11";
      
      private static const KEY_REWARD_GRANT_COUNT:String = "reward_grant_count";
      
      public static const FEATURE_OPTIONS_KEY:String = "FarmRunV5";
      
      public static const FV_FarmRunV5_CURRENT_STATE:String = "state";
      
      public static const KEY_MINIGAME_STATE:int = 1;
      
      public static const KEY_ORDERBOARD_STATE:int = 0;
      
      private static const KEY_SAVED_BOARD_COUNT:String = "21";
      
      private static const REWARD_POPUP_WINDOW:String = "assets/dialogs/FarmRun2019_v2/FV_FarmRun2019_v2_prize.swf";
      
      private static const REWARD_WINDOW_IMAGE:String = "assets/dialogs/newfrontier/RewardDialog.png";
      
      public static const VAL_FIRST_MILESTONE:int = 200;
      
      public static const VAL_SECOND_MILESTONE:int = 425;
      
      public static const VAL_THIRD_MILESTONE:int = 700;
      
      public static const VAL_FINAL_MILESTONE:int = 1000;
      
      private static const SKIP_COST:int = 2;
      
      private static const KEY_COMPLETED:String = "task_completed";
      
      private static const KEY_COMPLETED_TASKS:String = "completedTasks";
      
      private static const WINDOW_REWARDS:String = "rewards";
      
      private static const KEY_FTUE:String = "FarmRunV5_ftue_flag";
      
      private var m_hud:QueuedIconWithArrow;
      
      private var m_currency:String = "task_points";
      
      private var m_endTimeStamp:Number = 0;
      
      private var m_tasksById:Object = null;
      
      private var m_assetPaths:Object = {};
      
      private var m_worlds:Array = [];
      
      private var m_lastMilestoneRewards:Array = [];
      
      protected var m_featureData:Object = {};
      
      protected var m_staticData:Object = {};
      
      protected var m_rewards:Array = [];
      
      private var m_feedConfig:Object = {};
      
      protected const KEY_ID:String = "id";
      
      protected const KEY_PROGRESS:String = "progress";
      
      protected const KEY_TOTAL:String = "total";
      
      public var m_window:FarmRunV5MainWindow;
      
      private var m_rewardWindow:FarmRunV5SingleRewardPopup;
      
      private var m_buildingUpgradeRewardWindow:CarribeanGenericSingleRewardPopup;
      
      private var m_resultObject:Object;
      
      private var m_isActive:Boolean = false;
      
      protected var m_owner:FeatureBuilding;
      
      public var m_orderBoardWindow:FarmRunV5OrderBoardWindow;
      
      public var m_scoreboardWindow:FarmRunV5ScoreBoardWindow;
      
      private var m_showRedeemCallout:Boolean = false;
      
      private var m_timer:Timer;
      
      private var m_assetPools:Array;
      
      public function FarmRunV5Manager(featureName:String)
      {
         super(featureName);
         if(!this.featureConfig)
         {
            return;
         }
         this.parseFeatureConfig();
         this.parseTaskObjectsFromCOnfig(m_featureName);
         this.startQuest();
         this.m_featureData = this.getFeatureData();
         this.m_resultObject = {};
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
         this.setupHud();
      }
      
      public static function getInstance(featureName:String = "FarmRunV5") : FarmRunV5Manager
      {
         var instance:FarmRunV5Manager = getInstanceOfClass(featureName,FarmRunV5Manager) as FarmRunV5Manager;
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
      
      public function get worldArray() : Array
      {
         return this.m_worlds;
      }
      
      public function getworldIndexFromName(name:String) : int
      {
         return this.worldArray.indexOf(name);
      }
      
      public function get isFeatureActive() : Boolean
      {
         return this.m_isActive;
      }
      
      public function get dialogURL() : String
      {
         return this.m_assetPaths[WINDOW_MAIN];
      }
      
      public function get orderboardURL() : String
      {
         return this.m_assetPaths[WINDOW_ORDERBOARD];
      }
      
      public function get gameWindowURL() : String
      {
         return this.m_assetPaths[WINDOW_GAME];
      }
      
      public function get messageWindowUrl() : String
      {
         return this.m_assetPaths[WINDOW_MESSAGE];
      }
      
      public function showMainUI(val:Boolean = true) : void
      {
         if(val)
         {
            this.m_window = new FarmRunV5MainWindow(m_featureName,this.dialogURL);
            UI.displayPopup(this.m_window,false);
         }
         this.updateMainUI();
         StatsManager.count(FEATURE_TRACKING,"mainui","open");
      }
      
      public function showGameUI(isReplay:Boolean = false) : void
      {
         if(this.getFeatureProgress() >= VAL_FINAL_MILESTONE)
         {
            return;
         }
         if(this.m_window)
         {
            this.m_window.enableInput = true;
         }
         UI.displayPopup(new FarmRunV5GameWindow(FEATURE_NAME,this.gameWindowURL,isReplay),false);
      }
      
      public function updateMainUI() : void
      {
         if(Global.worldManager.currentWorldType == this.getFarmrunWorldFromPoints())
         {
            if(this.getCurrentState() == KEY_ORDERBOARD_STATE)
            {
               this.openOrderBoardWindow();
            }
            else
            {
               if(this.m_orderBoardWindow)
               {
                  this.m_orderBoardWindow.close();
               }
               this.openScoreBoard();
            }
         }
      }
      
      public function showRewardsUI() : void
      {
         var item:String = "xnf_hardyhome";
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(item);
         var window:FarmWindow = new CongratsForNewCaribbeanInovationWindow(this.m_assetPaths[WINDOW_REWARDS],m_featureName + "lastmilestone",rewardItem,null,null,item);
         StatsManager.count(m_featureName,"Awards_Click");
         UI.displayPopup(window,false);
         this.m_window.close();
      }
      
      protected function onTransactionAdded(event:TransactionEvent) : void
      {
         this.checkForTaskUpdates(event);
      }
      
      public function parseFeatureConfig() : void
      {
         var rewardObject:Object = null;
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
            this.m_currency = Global.farmGameSettingsManager.getFarmItemCodeByName(config["currency"]["@name"]);
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
                     if(division.@name == "worlds")
                     {
                        this.m_worlds.push(item.@name.toString());
                     }
                     if(division.@name == "finalreward")
                     {
                        this.m_lastMilestoneRewards.push(item.@name.toString());
                     }
                  }
               }
            }
            rewardObject = {};
            if(config.hasOwnProperty("rewards"))
            {
               for each(reward in config.rewards.reward)
               {
                  rewardObject = {};
                  rewardObject["name"] = reward.@name.toString();
                  rewardObject["world"] = reward.@stage.toString();
                  rewardObject["points"] = reward.@cost.toString();
                  this.m_rewards.push(rewardObject);
               }
            }
         }
      }
      
      private function parseMiniGameAssetPools() : void
      {
         var poolIndex:int = 0;
         var worldName:String = null;
         var currentWorldPools:XMLList = null;
         var pool:XML = null;
         var asset:XML = null;
         poolIndex = 0;
         worldName = this.getFarmrunWorldFromPoints();
         currentWorldPools = Global.farmGameSettingsManager.getXML().FarmRunV5MiniGame.worlds.world.(@name == worldName);
         this.m_assetPools = [];
         if(currentWorldPools)
         {
            for each(pool in currentWorldPools.pool)
            {
               this.m_assetPools[poolIndex] = [];
               for each(asset in pool.asset)
               {
                  this.m_assetPools[poolIndex].push(asset.@name);
               }
               poolIndex++;
            }
         }
      }
      
      public function openOrderBoardWindow() : void
      {
         if(this.getFeatureProgress() < VAL_FINAL_MILESTONE)
         {
            this.m_orderBoardWindow = new FarmRunV5OrderBoardWindow(m_featureName,this.orderboardURL);
            this.startQuest(this.m_orderBoardWindow.refreshTaskFrame);
            UI.displayPopup(this.m_orderBoardWindow,false);
            if(this.m_window)
            {
               this.m_window.enableInput = true;
            }
         }
      }
      
      public function openScoreBoard(isGameOver:Boolean = false, foundAllPairs:Boolean = false) : void
      {
         if(this.getFeatureProgress() >= VAL_FINAL_MILESTONE)
         {
            return;
         }
         this.m_scoreboardWindow = new FarmRunV5ScoreBoardWindow(m_featureName,this.messageWindowUrl,isGameOver,foundAllPairs);
         UI.displayPopup(this.m_scoreboardWindow,false);
      }
      
      public function getTimeRemaining() : Array
      {
         var remainingSecs:int = 0;
         var timeLeftMs:Number = this.m_endTimeStamp - GlobalEngine.serverTime;
         timeLeftMs = timeLeftMs < 0 ? 0 : timeLeftMs;
         var remainingTime:Array = FarmGameUtil.parseTimeLeft(timeLeftMs / 1000);
         if(parseInt(remainingTime[0]) > 0)
         {
            remainingSecs = parseInt(remainingTime[0]) + 1;
            remainingTime[0] = remainingSecs.toString();
         }
         return remainingTime;
      }
      
      public function parseTaskObjectsFromCOnfig(questName:String) : void
      {
         var world:String = null;
         var orderBoardName:String = null;
         var orderBoardXml:XML = null;
         var tasksByDifficultyList:XMLList = null;
         var tasksByDiff:XML = null;
         var tasksByDiffAndTypeList:XMLList = null;
         var tasksByDiffAndType:XML = null;
         var taskXML:XML = null;
         this.m_tasksById = {};
         for each(world in this.m_worlds)
         {
            orderBoardName = questName + world;
            this.m_tasksById[world] = {};
            orderBoardXml = Global.farmGameSettingsManager.getXML().orderBoards.orderBoard.(@name == orderBoardName)[0];
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
                        this.m_tasksById[world][taskXML.@id] = taskXML;
                     }
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
            if(this.m_hud)
            {
               this.m_hud.attachArrow(ArrowType.ARROWUPDATE);
               this.m_hud.setArrowText("Progress!");
            }
         }
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
      
      public function getCurrentState() : int
      {
         return this.getFeatureOptionsKey(FV_FarmRunV5_CURRENT_STATE) as int;
      }
      
      public function getFeatureData() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName);
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
         var world:String = this.getFarmrunWorldFromPoints();
         if(Boolean(savedTaskInfo) && Boolean(savedTaskInfo.length) && Boolean(world))
         {
            if(this.m_tasksById == null)
            {
               this.parseTaskObjectsFromConfig(m_featureName);
            }
            for each(task in savedTaskInfo)
            {
               taskXML = this.m_tasksById[world][task[this.KEY_ID]];
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
      
      public function getCompletedTaskSlots() : Array
      {
         return this.getFeatureOptionsKey(KEY_COMPLETED) as Array;
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
      
      public function addMiniGamePoints() : void
      {
         var currentScore:int = 0;
         currentScore = this.getFeatureProgress();
         var scoreToAdd:int = VAL_FINAL_MILESTONE - currentScore >= this.miniGameScore ? this.miniGameScore : int(VAL_FINAL_MILESTONE - currentScore);
         FarmStatsManager.count(FEATURE_TRACKING,m_featureName,this.miniGameScore.toString(),"miniGamePoints",this.getFeatureProgress().toString(),this.getFarmrunWorldFromPoints());
         FeatureOptionsInventoryManager.getInstance().addCount(this.currency,scoreToAdd);
         this.m_window.refreshWindow();
         this.grantMilestoneRewardConditionally();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"grantPoints",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[null]),[m_featureName,this.miniGameScore]),true);
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
            if(result.hasOwnProperty(KEY_COMPLETED_TASKS))
            {
               this.saveFeatureOptionsKey(KEY_COMPLETED,result[KEY_COMPLETED_TASKS]);
            }
            if(Boolean(callback))
            {
               callback.call();
            }
         }
         if(this.m_window)
         {
            this.m_window.refreshWindow();
         }
         var currentWorld:String = Global.worldManager.currentWorldType;
         if(currentWorld != this.getFarmrunWorldFromPoints())
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getUpdatedFeatureData",this.updateJustFeatureData,new Array(FEATURE_OPTIONS_KEY)),true);
         }
      }
      
      private function updateJustFeatureData(result:Object) : void
      {
         this.m_resultObject = result;
         if(Boolean(result) && result.hasOwnProperty("featureData"))
         {
            FeatureOptionsManager.getInstance().setFeature(m_featureName,result["featureData"]);
         }
      }
      
      public function startQuest(callback:Function = null) : void
      {
         var savedTaskInfo:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         if(!(savedTaskInfo && savedTaskInfo.length) && !Global.player.getSeenFlag(KEY_FTUE))
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startQuest",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName)),true);
            this.saveFeatureOptionsKey(KEY_SAVED_BOARD_COUNT,1);
            Global.player.setSeenFlag(KEY_FTUE);
         }
      }
      
      public function redeemRewardPoints(questIndex:int, callback:Function, taskPoints:int = 0) : void
      {
         var tasks:Vector.<FarmTask> = this.getTasks();
         var completedTasks:Array = this.getFeatureOptionsKey(KEY_COMPLETED) as Array;
         completedTasks[questIndex] = 1;
         this.saveFeatureOptionsKey(KEY_COMPLETED,completedTasks);
         this.checkForOrderboardCompletion();
         this.checkAndUpdateUserState();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"redeemRewardPoints",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
         this.resetActionCountsForTasks(tasks[questIndex]);
      }
      
      public function skipTask(questIndex:int, callback:Function) : void
      {
         var savedTasks:Array = null;
         var completedTasks:Array = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         if(Global.player.canBuyCash(tasks[questIndex].skipCashValue))
         {
            Global.player.cash -= tasks[questIndex].skipCashValue;
            savedTasks = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
            completedTasks = this.getFeatureOptionsKey(KEY_COMPLETED) as Array;
            completedTasks[questIndex] = 1;
            savedTasks[questIndex][this.KEY_PROGRESS] = tasks[questIndex].total;
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,savedTasks);
            this.saveFeatureOptionsKey(KEY_COMPLETED,completedTasks);
            this.checkForOrderboardCompletion();
            this.checkAndUpdateUserState();
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
            this.resetActionCountsForTasks(tasks[questIndex]);
         }
         else
         {
            callback.call();
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
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"dumpTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
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
         var throttleTimeInSeconds:Number = 2 * FarmGameUtil.NUM_SECS_IN_HOUR;
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
         var throttleTimeInSeconds:Number = 2 * FarmGameUtil.NUM_SECS_IN_HOUR;
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
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getNewTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
         var dumpTimestamp:Object = this.getFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP) as Object;
         dumpTimestamp[questIndex] = 0;
         this.saveFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP,dumpTimestamp);
         this.resetActionCountsForTasks(tasks[questIndex]);
      }
      
      public function sinkGold(questIndex:int, callback:Function) : void
      {
         var savedTasks:Array = null;
         var completedTasks:Array = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         if(Global.player.canBuy(tasks[questIndex].total))
         {
            Global.player.gold -= tasks[questIndex].total;
            savedTasks = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
            savedTasks[questIndex][this.KEY_PROGRESS] = tasks[questIndex].total;
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,savedTasks);
            completedTasks = this.getFeatureOptionsKey(KEY_COMPLETED) as Array;
            completedTasks[questIndex] = 1;
            this.saveFeatureOptionsKey(KEY_COMPLETED,completedTasks);
            this.checkForOrderboardCompletion();
            this.checkAndUpdateUserState();
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkGold",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
            StatsManager.count(m_featureName,"Coin Sink","",tasks[questIndex].total.toString(),this.getFeatureProgress().toString());
         }
         else
         {
            callback.call();
         }
      }
      
      public function sinkWorldCurrency(questIndex:int, callback:Function) : void
      {
         var savedTasks:Array = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         var currency:String = tasks[questIndex].type;
         if(Global.player.canBuyWithCurrency(currency,tasks[questIndex].total))
         {
            Global.player.deductWorldCurrencyCount(currency,tasks[questIndex].total);
            savedTasks = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
            savedTasks[questIndex][this.KEY_PROGRESS] = tasks[questIndex].total;
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,savedTasks);
            this.checkForOrderboardCompletion();
            this.checkAndUpdateUserState();
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkWorldCurrency",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
            StatsManager.count(m_featureName,"Coconuts Sink","",tasks[questIndex].total.toString(),this.getFeatureProgress().toString());
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
         var completedTasks:Array = this.getFeatureOptionsKey(KEY_COMPLETED) as Array;
         completedTasks[questIndex] = 1;
         this.saveFeatureOptionsKey(KEY_COMPLETED,completedTasks);
         this.checkForOrderboardCompletion();
         this.checkAndUpdateUserState();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkBushel",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
         StatsManager.count(m_featureName,"Sink Bushel","",tasks[questIndex].total.toString(),this.getFeatureProgress().toString());
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
      
      public function grantRewardCallback(event:Event) : void
      {
         if(this.m_rewardWindow)
         {
            this.m_rewardWindow.close();
         }
      }
      
      private function getMilestoneRewardIdx() : int
      {
         var milestoneRewardIdx:int = this.getFeatureOptionsKey(KEY_REWARD_GRANT_COUNT) as int;
         if(!milestoneRewardIdx)
         {
            milestoneRewardIdx = 0;
         }
         return milestoneRewardIdx;
      }
      
      private function shouldGrantMilestoneReward(milestoneRewardIdx:int, rewardGrantKey:String) : Boolean
      {
         return !this.getFeatureOptionsKey(rewardGrantKey) && this.m_rewards[milestoneRewardIdx]["points"] <= this.getFeatureProgress();
      }
      
      private function grantMilestoneRewardConditionally() : void
      {
         var milestoneRewardIdx:int = 0;
         var milestoneCountInWorld:int = 0;
         var worldname:String = null;
         milestoneRewardIdx = this.getMilestoneRewardIdx();
         var rewardGrantKey:String = m_featureName + "_Milestone_" + milestoneRewardIdx + "_awarded";
         if(!this.shouldGrantMilestoneReward(milestoneRewardIdx,rewardGrantKey))
         {
            return;
         }
         var callback:Function = this.grantRewardCallback;
         var reward:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_rewards[milestoneRewardIdx]["name"]);
         this.saveFeatureOptionsKey(rewardGrantKey,true);
         this.saveFeatureOptionsKey(KEY_REWARD_GRANT_COUNT,milestoneRewardIdx + 1);
         Global.player.addGift(reward.name);
         if(this.getFeatureProgress() >= VAL_FINAL_MILESTONE)
         {
            callback = this.grantFinalrewardCallback;
            FarmStatsManager.count(FEATURE_TRACKING,"Featurecomplete");
         }
         milestoneCountInWorld = milestoneRewardIdx % 3 + 1;
         worldname = this.getFarmrunWorldFromPoints();
         var milestoneKey:String = worldname + "-" + milestoneCountInWorld.toString();
         StatsManager.count(FEATURE_TRACKING,"Milestone",milestoneKey,this.getFeatureProgress().toString(),reward.name);
         this.m_rewardWindow = new FarmRunV5SingleRewardPopup(REWARD_POPUP_WINDOW,m_featureName,reward,callback,REWARD_WINDOW_IMAGE);
         this.m_rewardWindow.addEventListener("close",this.RedirectInput);
         UI.displayPopup(this.m_rewardWindow,false);
      }
      
      private function RedirectInput(event:Event) : void
      {
         if(this.m_rewardWindow)
         {
            this.m_rewardWindow.removeEventListener("close",this.RedirectInput);
            this.m_rewardWindow = null;
         }
         Utilities.toggleInputAndChildren(Global.ui,false);
         Utilities.toggleInputAndChildren(this.m_window,true);
      }
      
      public function grantFinalrewardCallback(event:Event) : void
      {
         this.grantFinalReward();
      }
      
      public function grantFinalReward() : void
      {
         var finalMileStoneReward:String = null;
         var rewardItem:FarmItem = null;
         if(this.m_rewardWindow)
         {
            this.m_rewardWindow.close();
         }
         var finalRewardTaken:int = this.getFeatureOptionsKey(KEY_SAVED_FINAL_REWARD_RECEIVED) as int;
         if(!finalRewardTaken)
         {
            finalMileStoneReward = this.m_lastMilestoneRewards[0];
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(finalMileStoneReward);
            Global.player.addGift(finalMileStoneReward);
            this.m_rewardWindow = new FarmRunV5SingleRewardPopup(REWARD_POPUP_WINDOW,FEATURE_NAME,rewardItem,this.postMilestoneBragFeed,REWARD_WINDOW_IMAGE);
            this.m_rewardWindow.addEventListener("close",this.RedirectInput);
            UI.displayPopup(this.m_rewardWindow,false);
            FarmStatsManager.count(FEATURE_TRACKING,"grantBonus",finalMileStoneReward);
            this.saveFeatureOptionsKey(KEY_SAVED_FINAL_REWARD_RECEIVED,1);
         }
      }
      
      public function get currency() : String
      {
         return this.m_currency;
      }
      
      public function getFeatureProgress() : Number
      {
         return FeatureOptionsInventoryManager.getInstance().getCount(this.currency);
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
      
      protected function getFeatureOption() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName);
      }
      
      public function checkForOrderboardCompletion() : void
      {
         var isOrderBoardCompleted:Boolean = true;
         var completedTasks:Array = this.getCompletedTaskSlots();
         var currentWorld:String = Global.worldManager.currentWorldType;
         var currentState:int = this.getCurrentState();
         for(var i:int = 0; i < completedTasks.length; i++)
         {
            if(completedTasks[i] == 0)
            {
               isOrderBoardCompleted = false;
            }
         }
         if(currentState == KEY_ORDERBOARD_STATE)
         {
            if(isOrderBoardCompleted && currentWorld == this.getFarmrunWorldFromPoints())
            {
               FeatureOptionsInventoryManager.getInstance().addCount(this.currency,25);
               this.grantMilestoneRewardConditionally();
               FarmStatsManager.count(FEATURE_TRACKING,"orderboardtask","complete","25",this.getFeatureProgress().toString(),this.getFarmrunWorldFromPoints());
               if(this.m_orderBoardWindow)
               {
                  this.m_orderBoardWindow.updateNPCTextAfterQuiz();
               }
               if(this.m_window)
               {
                  this.m_window.refreshWindow();
               }
            }
         }
         if(currentWorld != this.getFarmrunWorldFromPoints())
         {
            if(this.m_window)
            {
               this.m_window.refreshWindow();
            }
            this.saveFeatureOptionsKey(FV_FarmRunV5_CURRENT_STATE,KEY_ORDERBOARD_STATE);
            this.resetMiniGameAssetPool();
         }
      }
      
      public function getFarmrunWorldFromPoints() : String
      {
         var playerPoints:int = this.getFeatureProgress();
         var world:String = "";
         if(playerPoints < VAL_FIRST_MILESTONE)
         {
            world = this.m_worlds[0];
         }
         else if(playerPoints < VAL_SECOND_MILESTONE)
         {
            world = this.m_worlds[1];
         }
         else if(playerPoints < VAL_THIRD_MILESTONE)
         {
            world = this.m_worlds[2];
         }
         else
         {
            world = this.m_worlds[3];
         }
         return world;
      }
      
      public function setRedeemCallout(flag:Boolean = false) : void
      {
         this.m_showRedeemCallout = flag;
      }
      
      public function onTravelButtonClick(slotNo:int = 0) : Function
      {
         return function(evt:MouseEvent):void
         {
            var worldType:* = undefined;
            var hasUnlockedWorld:* = undefined;
            var currentFarmrunWorld:* = getFarmrunWorldFromPoints();
            if(Global.worldManager.currentWorldType == currentFarmrunWorld)
            {
               showMainUI(false);
            }
            else if(Boolean(currentFarmrunWorld) && m_worlds[slotNo] == currentFarmrunWorld)
            {
               worldType = currentFarmrunWorld;
               if(Boolean(worldType) && worldType.length > 0)
               {
                  hasUnlockedWorld = Global.worldManager.hasUnlockedWorld(worldType);
                  if(hasUnlockedWorld)
                  {
                     saveFeatureOptionsKey(FV_FarmRunV5_CURRENT_STATE,KEY_ORDERBOARD_STATE);
                     Global.worldManager.swapFarm(worldType,false);
                     Global.worldManager.addEventListener(FarmGameWorldEvent.WORLD_LOADED,onWorldLoaded);
                  }
               }
            }
         };
      }
      
      private function onWorldLoaded(event:FarmGameWorldEvent) : void
      {
         this.displayMainWindowNPC();
         this.resetMiniGameAssetPool();
         Global.worldManager.removeEventListener(FarmGameWorldEvent.WORLD_LOADED,this.onWorldLoaded);
         if(this.m_window)
         {
            this.m_window.hide();
            this.m_window.show();
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getUpdatedFeatureData",this.updateFeatureData,new Array(FEATURE_OPTIONS_KEY)),true);
      }
      
      public function onMiniGameEnd() : void
      {
         this.addMiniGamePoints();
         this.resetGameData();
         if(this.getFeatureProgress() < VAL_FINAL_MILESTONE)
         {
            this.saveFeatureOptionsKey(FV_FarmRunV5_CURRENT_STATE,KEY_ORDERBOARD_STATE);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getUpdatedFeatureData",this.onMiniGameEndTransactionComplete,[m_featureName]),true);
         }
         else if(this.m_scoreboardWindow)
         {
            this.m_scoreboardWindow.enableOkayButton();
         }
      }
      
      private function onMiniGameEndTransactionComplete(result:Object) : void
      {
         if(this.m_scoreboardWindow)
         {
            this.m_scoreboardWindow.enableOkayButton();
         }
         this.onInitQuestComplete(null,result);
      }
      
      private function updateFeatureData(result:Object) : void
      {
         this.onInitQuestComplete(null,result);
         this.showMainUI(false);
      }
      
      public function isWorldEnabled(slotIndex:int) : Boolean
      {
         return this.getFarmrunWorldFromPoints() == this.m_worlds[slotIndex];
      }
      
      public function isWorldCompleted(index:int) : Boolean
      {
         var currentFarmRunWorld:String = this.getFarmrunWorldFromPoints();
         return this.m_worlds.indexOf(currentFarmRunWorld) > index || this.getFeatureProgress() >= 1000;
      }
      
      private function checkAndUpdateUserState() : void
      {
         var completedTask:Array = this.getCompletedTaskSlots();
         var toSwitch:Boolean = true;
         for(var i:int = 0; i < completedTask.length; i++)
         {
            if(completedTask[i] == 0)
            {
               toSwitch = false;
               break;
            }
         }
         if(toSwitch)
         {
            this.saveFeatureOptionsKey(FV_FarmRunV5_CURRENT_STATE,KEY_MINIGAME_STATE);
            this.updateCompletedTaskArray();
            if(this.m_window)
            {
               this.m_window.refreshWindow();
            }
            if(this.m_orderBoardWindow)
            {
               this.m_orderBoardWindow.updateOnOrderboardEnd(Global.worldManager.currentWorldType == this.getFarmrunWorldFromPoints());
            }
         }
      }
      
      private function updateCompletedTaskArray() : void
      {
         var completedTask:Array = this.getCompletedTaskSlots();
         for(var i:int = 0; i < completedTask.length; i++)
         {
            completedTask[i] = 0;
         }
         this.saveFeatureOptionsKey(KEY_COMPLETED,completedTask);
      }
      
      public function displayPowerupButtonStatusText(element:Object, delta:int, unit:String, positive:Boolean = true) : void
      {
         var messageTemplate:String = null;
         var displayPoint:Point = null;
         if(delta <= 0)
         {
            return;
         }
         messageTemplate = "<font color=\'#{0}\'>{1}{2} {3}</font>";
         var message:String = StringUtil.substitute(messageTemplate,positive ? "00AA00" : "FF0000",positive ? "+" : "-",delta,unit);
         if(element != null && message != null && message != "")
         {
            displayPoint = new Point(0,0);
            displayPoint = element.localToGlobal(displayPoint);
            UI.displayStatus(message,displayPoint.x,displayPoint.y);
         }
      }
      
      public function startTimer(delay:Number, eventListener:Function = null) : void
      {
         if(!this.m_timer)
         {
            this.m_timer = new Timer(delay);
            this.m_timer.addEventListener(TimerEvent.TIMER,eventListener);
            this.m_timer.start();
         }
      }
      
      public function stopTimer(eventListener:Function = null) : void
      {
         if(Boolean(this.m_timer) && Boolean(eventListener))
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,eventListener);
            this.m_timer = null;
         }
      }
      
      public function updateAssetPoolIndex() : void
      {
         var index:int = (this.assetPoolIndex + 1) % 3;
         this.saveFeatureOptionsKey(KEY_MINI_GAME_CURRENT_POOL_INDEX,index);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"updateAssetPoolIndex",null,[m_featureName,index]));
      }
      
      private function get assetPoolIndex() : int
      {
         return this.getFeatureOptionsKey(KEY_MINI_GAME_CURRENT_POOL_INDEX) as int;
      }
      
      private function resetMiniGameAssetPool() : void
      {
         this.m_assetPools = null;
      }
      
      public function get miniGameAssetPool() : Array
      {
         if(!this.m_assetPools)
         {
            this.parseMiniGameAssetPools();
         }
         return this.m_assetPools[this.assetPoolIndex];
      }
      
      public function get miniGameRound1Score() : int
      {
         return this.getFeatureOptionsKey(KEY_MINI_GAME_R1_SCORE) as int;
      }
      
      public function set miniGameRound1Score(score:int) : void
      {
         this.saveFeatureOptionsKey(KEY_MINI_GAME_R1_SCORE,score);
      }
      
      public function get miniGameRound2Score() : int
      {
         return this.getFeatureOptionsKey(KEY_MINI_GAME_R2_SCORE) as int;
      }
      
      public function set miniGameRound2Score(score:int) : void
      {
         this.saveFeatureOptionsKey(KEY_MINI_GAME_R2_SCORE,score);
      }
      
      public function get miniGameScore() : int
      {
         return this.miniGameRound1Score + this.miniGameRound2Score;
      }
      
      public function get miniGameActiveRound() : int
      {
         return this.getFeatureOptionsKey(KEY_MINI_GAME_ACTIVE_ROUND) as int;
      }
      
      public function set miniGameActiveRound(activeRound:int) : void
      {
         this.saveFeatureOptionsKey(KEY_MINI_GAME_ACTIVE_ROUND,activeRound);
      }
      
      public function get activeMiniGameLayout() : Array
      {
         return this.getFeatureOptionsKey(KEY_MINI_GAME_LAYOUT) as Array;
      }
      
      public function set activeMiniGameLayout(gameLayout:Array) : void
      {
         this.saveFeatureOptionsKey(KEY_MINI_GAME_LAYOUT,gameLayout);
      }
      
      public function get activeMiniGamePairedSlots() : Array
      {
         return this.getFeatureOptionsKey(KEY_MINI_GAME_PAIRED_SLOTS) as Array;
      }
      
      public function set activeMiniGamePairedSlots(pairedSlots:Array) : void
      {
         this.saveFeatureOptionsKey(KEY_MINI_GAME_PAIRED_SLOTS,pairedSlots);
      }
      
      public function resetGameData() : void
      {
         this.miniGameRound1Score = 0;
         this.miniGameRound2Score = 0;
         this.miniGameActiveRound = 1;
         this.activeMiniGameLayout = [];
         this.activeMiniGamePairedSlots = [];
      }
      
      public function saveGameProgress(gameLayout:Array, pairedSlots:Array) : void
      {
         this.activeMiniGamePairedSlots = pairedSlots;
         this.activeMiniGameLayout = gameLayout;
         if(this.miniGameActiveRound == 1)
         {
            this.miniGameRound1Score = pairedSlots.length;
         }
         else
         {
            this.miniGameRound2Score = pairedSlots.length;
         }
      }
      
      public function onSummaryConfirmationClick(event:Event) : void
      {
         if(this.getFeatureProgress() < VAL_FINAL_MILESTONE && this.getFarmrunWorldFromPoints() == Global.worldManager.currentWorldType)
         {
            this.openOrderBoardWindow();
         }
         else
         {
            this.displayMainWindowNPC();
         }
         if(this.m_scoreboardWindow)
         {
            this.m_scoreboardWindow.closeWindow();
         }
      }
      
      public function spendFarmCashService(spendType:String, successCallback:Function = null, failureCallback:Function = null) : void
      {
         var trackingType:String = null;
         var cost:int = int(ACTION_TYPE_TO_COST[spendType]);
         if(Global.player.canBuyCash(cost))
         {
            Global.player.cash -= cost;
            if(Boolean(successCallback))
            {
               successCallback();
            }
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"spendFarmCash",null,[m_featureName,spendType]));
            trackingType = cost == 1 ? "minigame_extend" : "minigame_replay";
            FarmStatsManager.count(FEATURE_TRACKING,m_featureName,cost.toString(),trackingType,this.getFeatureProgress().toString(),this.getFarmrunWorldFromPoints());
         }
         if(Boolean(failureCallback))
         {
            failureCallback();
         }
      }
      
      public function displayMainWindowNPC() : void
      {
         if(this.m_window)
         {
            this.m_window.displayNPC();
         }
      }
   }
}

