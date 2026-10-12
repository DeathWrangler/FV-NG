package Managers
{
   import Classes.Constants.ArrowType;
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.QueuedIcons.QueuedIconWithArrow;
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
   import Widgets.Windows.WhiteWinterInnovationRewardPopup;
   import Widgets.Windows.WhitewinterInnovationRewardWindow;
   import Widgets.Windows.WhitewinterInnovationWindow;
   import flash.events.Event;
   
   public class WhitewinterInnovationManager extends BaseFeatureManager
   {
      
      public static const FEATURE_NAME:String = "WhitewinterInnovation";
      
      private static const WINDOW_MAIN:String = "main";
      
      private static const WINDOW_GIFT:String = "gift";
      
      private static const WINDOW_BUYDIALOG:String = "buy";
      
      private static const WINDOW_CONGRATS:String = "congrats";
      
      private static const WINDOW_TILE_UNLOCK:String = "tileunlock";
      
      public static const MILESTONE1_REWARD_NAME:String = "pegasus_xfw_holidayblast";
      
      public static const MILESTONE2_REWARD_NAME:String = "horse_xfw_newyearfun";
      
      public static const MILESTONE3_REWARD_NAME:String = "xfw_iceskatingfun";
      
      private static const KEY_MILESTONE1_STATUS:String = "ms1";
      
      private static const KEY_MILESTONE2_STATUS:String = "ms2";
      
      private static const KEY_MILESTONE3_STATUS:String = "ms3";
      
      private static const KEY_GIFT_STATUS:String = "gs";
      
      private static const TILE_UNLOCK_COUNT:String = "tuc";
      
      private static var m_initialized:Boolean = false;
      
      private static const KEY_SAVED_ACTIVE_TASKS:String = "ActiveTasks";
      
      private static const KEY_CURRENT_STAGE:String = "currentStage";
      
      public static const ICON_SIZE:int = 25;
      
      public static const WHITEWINTER_COLLECT_CONSUMABLE_KEY:String = "wwick";
      
      public static const DEFAULT_COLLECT_THROTTLE_TIME:int = 21600;
      
      private static const SERVICE_CLASS:String = "WhitewinterInnovationService";
      
      private static const SERVICE_FUNC_RESET_COLLECT_TIMER:String = "resetCollectConsumablesTimer";
      
      private static const EVENT_WW_INNOVATION_TILE_UNLOCK:String = "WWInnovationTileUnlock";
      
      private static const SERVICE_FUNC_GRANT_ELIGIBLE_REWARDS:String = "grantAllEligibleRewards";
      
      public static const COLLECTION1:String = "Festive Collection";
      
      public static const COLLECTION2:String = "New Year\'s Collection";
      
      public static const COLLECTION3:String = "Season\'s Collection";
      
      private static const SINK_CONSUMABLE_TASK_INDEX:int = 2;
      
      private static const SERVICE_FUNC_SINK_CONSUMABLE:String = "sinkConsumables";
      
      private static const SINK_BUSHEL_TASK_INDEX:int = 0;
      
      private static const SERVICE_FUNC_SINK_BUSHEL:String = "sinkBushels";
      
      private static const COLLECT_CONSUMABLE_COUNT:int = 5;
      
      public static const NUM_MSECS_IN_SIX_HRS:uint = 21600000;
      
      public const FEED_NAME:String = "FeatureUI";
      
      private var m_tasksById:Object = null;
      
      private var m_mainWindow:WhitewinterInnovationWindow;
      
      private const VAL_TASK_LENGTH:Number = 3;
      
      private var m_endTimeStamp:Number = 0;
      
      protected const KEY_PROGRESS:String = "progress";
      
      protected const KEY_TYPE:String = "type";
      
      protected const KEY_VALUE:String = "value";
      
      private var m_staticData:Object = null;
      
      private var m_assetPaths:Object;
      
      private var m_giftWindow:WhitewinterInnovationRewardWindow;
      
      public var MILESTONE_STAGES:Array = [12,17,20];
      
      public var TREE_STAGES:Array = [6,12,17,20];
      
      private var m_hud:QueuedIconWithArrow;
      
      public function WhitewinterInnovationManager(featureName:String = "WhitewinterInnovation")
      {
         super(featureName);
         this.parseTaskObjectsFromConfig();
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
      }
      
      public static function getInstance(featureName:String = "WhitewinterInnovation") : WhitewinterInnovationManager
      {
         var instance:WhitewinterInnovationManager = getInstanceOfClass(featureName,WhitewinterInnovationManager) as WhitewinterInnovationManager;
         return instance.featureConfig == null ? null : instance;
      }
      
      public function getCurrentStage() : int
      {
         var fo:Object = this.getFeatureOption();
         return fo[KEY_CURRENT_STAGE];
      }
      
      public function getCurrentStagetoDsiplay() : int
      {
         var fo:Object = this.getFeatureOption();
         return fo[KEY_CURRENT_STAGE] + 1;
      }
      
      public function showMainUI() : void
      {
         var endTimeStamp3:Number = NaN;
         var endTimeStamp4:Number = NaN;
         var featureLastRedeemDate:String = "01/07/2018";
         if(!m_initialized)
         {
            this.initialize();
         }
         endTimeStamp3 = FarmGameUtil.synchronizedDateToNumber(this.dateArray[this.MILESTONE_STAGES[2] - 1]) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTimeStamp4 = FarmGameUtil.synchronizedDateToNumber(featureLastRedeemDate) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(currentTime < endTimeStamp3)
         {
            if(this.getRedeemableRewardCount() > 0)
            {
               this.openGiftWindow();
               return;
            }
            if(this.m_mainWindow)
            {
               this.m_mainWindow.close();
            }
            UI.displayPopup(this.m_mainWindow = new WhitewinterInnovationWindow(m_featureName,this.mainWindowURL));
         }
         else if(currentTime < endTimeStamp4)
         {
            this.openGiftWindow();
         }
      }
      
      public function is_initialized() : Boolean
      {
         return m_initialized;
      }
      
      public function skipTask(taskIndex:int) : Boolean
      {
         var featureData:Object = null;
         var savedTasks:Array = null;
         var isQuestComplete:Boolean = false;
         var tasksToSave:Array = null;
         var i:int = 0;
         var taskObj:Object = null;
         var result:Boolean = false;
         var tasks:Vector.<FarmTask> = this.getTasks();
         if(Global.player.canBuyCash(tasks[taskIndex].skipCashValue))
         {
            Global.player.cash -= tasks[taskIndex].skipCashValue;
            result = true;
            featureData = this.getFeatureOption();
            savedTasks = featureData[KEY_SAVED_ACTIVE_TASKS] as Array;
            if(!savedTasks)
            {
               tasksToSave = [];
               for(i = 0; i < tasks.length; i++)
               {
                  taskObj = {};
                  taskObj[this.KEY_PROGRESS] = 0;
                  tasksToSave.push(taskObj);
               }
               savedTasks = tasksToSave;
            }
            savedTasks[taskIndex][this.KEY_PROGRESS] = tasks[taskIndex].total;
            featureData[KEY_SAVED_ACTIVE_TASKS] = savedTasks;
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,FEATURE_NAME,featureData);
            isQuestComplete = this.checkStageCompletion();
            if(isQuestComplete)
            {
               this.doPostStageCompletionTask();
            }
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"skipTask",null,[m_featureName,taskIndex]),true);
         }
         else
         {
            result = false;
         }
         return result;
      }
      
      protected function onTransactionAdded(event:TransactionEvent) : void
      {
         this.checkForTaskUpdates(event);
      }
      
      protected function checkForTaskUpdates(event:TransactionEvent) : void
      {
         var progress:Number = NaN;
         var transaction:TFarmTransaction = null;
         var isComplete:Boolean = false;
         var hasUpdatedProgress:Boolean = false;
         var progressArray:Array = [];
         var featureData:Object = this.getFeatureOption();
         var savedTasks:Array = featureData[KEY_SAVED_ACTIVE_TASKS] as Array;
         var tasks:Vector.<FarmTask> = this.getTasks();
         for(var i:int = 0; i < tasks.length; i++)
         {
            transaction = event.transaction as TFarmTransaction;
            progress = FarmQuestUtility.getInstance().getProgression(tasks[i],transaction,null);
            progressArray.push(progress);
            if(progress > 0)
            {
               hasUpdatedProgress = true;
            }
         }
         if(hasUpdatedProgress)
         {
            if(this.m_hud)
            {
               this.m_hud.attachArrow(ArrowType.ARROWUPDATE);
               this.m_hud.setArrowText("Progress!");
            }
            this.saveProgressForPlayer(progressArray);
            isComplete = this.checkStageCompletion();
            if(isComplete)
            {
               this.doPostStageCompletionTask();
            }
         }
      }
      
      public function doPostStageCompletionTask() : void
      {
         var fo:Object = this.getFeatureOption();
         var completedStage:int = this.getCurrentStage();
         fo[KEY_GIFT_STATUS][completedStage] = 1;
         setFeatureData(fo);
         this.checkAndGrantMileStoneRewards(completedStage);
         this.generateAndSaveNextTasks();
         this.openGiftWindow(null,true);
      }
      
      public function checkBushelUpdate() : Boolean
      {
         var progress:Number = NaN;
         var tasks:Vector.<FarmTask> = this.getTasks();
         var featureData:Object = this.getFeatureOption();
         var savedTasks:Array = featureData[KEY_SAVED_ACTIVE_TASKS] as Array;
         progress = CraftingManager.getInstance().getBushelQuantityInInventory(tasks[SINK_BUSHEL_TASK_INDEX].type);
         return progress >= tasks[SINK_BUSHEL_TASK_INDEX].total && savedTasks[SINK_BUSHEL_TASK_INDEX][this.KEY_PROGRESS] != tasks[SINK_BUSHEL_TASK_INDEX].total ? true : false;
      }
      
      public function sinkbushel() : void
      {
         var tasksToSave:Array = null;
         var i:int = 0;
         var taskObj:Object = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         var sinkCount:int = tasks[SINK_BUSHEL_TASK_INDEX].total;
         CraftingManager.getInstance().deductItemFromCraftingInventory(tasks[SINK_BUSHEL_TASK_INDEX].type,sinkCount);
         var featureData:Object = this.getFeatureOption();
         var savedTasks:Array = featureData[KEY_SAVED_ACTIVE_TASKS] as Array;
         if(!savedTasks)
         {
            tasksToSave = [];
            for(i = 0; i < tasks.length; i++)
            {
               taskObj = {};
               taskObj[this.KEY_PROGRESS] = 0;
               tasksToSave.push(taskObj);
            }
            savedTasks = tasksToSave;
         }
         savedTasks[SINK_BUSHEL_TASK_INDEX][this.KEY_PROGRESS] = tasks[SINK_BUSHEL_TASK_INDEX].total;
         featureData[KEY_SAVED_ACTIVE_TASKS] = savedTasks;
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,FEATURE_NAME,featureData);
         var isQuestComplete:Boolean = this.checkStageCompletion();
         if(isQuestComplete)
         {
            this.doPostStageCompletionTask();
         }
         else if(this.m_mainWindow)
         {
            this.m_mainWindow.refreshWindow();
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,SERVICE_FUNC_SINK_BUSHEL,null,[m_featureName]),true);
      }
      
      public function isMileStoneAchieved(milestone:int) : Boolean
      {
         var fo:Object = this.getFeatureOption();
         var result:Boolean = false;
         if(milestone == 1)
         {
            if(int(fo[KEY_MILESTONE1_STATUS]) == 2)
            {
               result = true;
            }
         }
         else if(milestone == 2)
         {
            if(int(fo[KEY_MILESTONE2_STATUS]) == 2)
            {
               result = true;
            }
         }
         else if(milestone == 3)
         {
            if(int(fo[KEY_MILESTONE3_STATUS]) == 2)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function checkAndGrantMileStoneRewards(completedStage:int) : void
      {
         var fo:Object = this.getFeatureOption();
         var milestoneReward:String = null;
         var milestoneFlag:Boolean = false;
         var treeLevel:int = 1;
         var showGrantPopup:Boolean = false;
         if(completedStage == this.TREE_STAGES[0] - 1)
         {
            treeLevel = 2;
            showGrantPopup = true;
         }
         if(completedStage == this.MILESTONE_STAGES[0] - 1)
         {
            treeLevel = 3;
            showGrantPopup = true;
            if(this.hasDatePassedForSlot(completedStage) == false)
            {
               fo[KEY_MILESTONE1_STATUS] = 2;
               Global.player.addGift(MILESTONE1_REWARD_NAME);
               milestoneReward = MILESTONE1_REWARD_NAME;
               milestoneFlag = true;
            }
         }
         else if(completedStage == this.MILESTONE_STAGES[1] - 1)
         {
            treeLevel = 4;
            showGrantPopup = true;
            if(this.hasDatePassedForSlot(completedStage) == false)
            {
               fo[KEY_MILESTONE2_STATUS] = 2;
               Global.player.addGift(MILESTONE2_REWARD_NAME);
               milestoneReward = MILESTONE2_REWARD_NAME;
               milestoneFlag = true;
            }
         }
         else if(completedStage == this.MILESTONE_STAGES[2] - 1)
         {
            treeLevel = 5;
            showGrantPopup = true;
            if(this.hasDatePassedForSlot(completedStage) == false)
            {
               fo[KEY_MILESTONE3_STATUS] = 2;
               Global.player.addGift(MILESTONE3_REWARD_NAME);
               milestoneReward = MILESTONE3_REWARD_NAME;
               milestoneFlag = true;
            }
         }
         if(milestoneFlag)
         {
            setFeatureData(fo);
         }
         if(showGrantPopup && Boolean(milestoneReward))
         {
            UI.displayPopup(new WhiteWinterInnovationRewardPopup("assets/dialogs/whitewinter/innovation/FV_xfw_Innovation_Prize.swf",featureName,Global.farmGameSettingsManager.getFarmItemByName(milestoneReward),null,"assets/dialogs/whitewinter/RewardDialog.png",milestoneFlag,treeLevel));
            FarmStatsManager.count("WhitewinterInnovation","CollectionComplete","",(treeLevel - 1).toString());
            FarmStatsManager.count("WhitewinterInnovation","MilestoneComplete",milestoneReward,(treeLevel - 2).toString());
         }
         else if(showGrantPopup)
         {
            UI.displayPopup(new WhiteWinterInnovationRewardPopup("assets/dialogs/whitewinter/innovation/FV_xfw_Innovation_Prize.swf",featureName,null,null,"assets/dialogs/whitewinter/RewardDialog.png",milestoneFlag,treeLevel));
            FarmStatsManager.count("WhitewinterInnovation","CollectionComplete","",(treeLevel - 1).toString());
         }
      }
      
      public function canCollectConsumables() : Boolean
      {
         var canCollect:Boolean = true;
         var key:String = WHITEWINTER_COLLECT_CONSUMABLE_KEY;
         if(this.getTimeLeft(key,DEFAULT_COLLECT_THROTTLE_TIME) > 0)
         {
            canCollect = false;
         }
         return canCollect;
      }
      
      public function getTimeLeft(key:String, throttleTime:int = 21600) : int
      {
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         return int(throttleTime - timeSinceLastFeed);
      }
      
      public function resetCollectConsumableTimer(tileName:String) : void
      {
         var featureData:Object = this.getFeatureOption();
         var key:String = WHITEWINTER_COLLECT_CONSUMABLE_KEY;
         var tilesArray:Array = this.TilesArray as Array;
         if(tilesArray.indexOf(tileName) >= 0)
         {
            featureData["tiles"][tileName] = 1;
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,FEATURE_NAME,featureData);
            Global.player.setFeatureLastShown(key,(GlobalEngine.serverTime - NUM_MSECS_IN_SIX_HRS) / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,SERVICE_FUNC_RESET_COLLECT_TIMER,null,[m_featureName,tileName]));
         }
      }
      
      public function collectConsumables() : int
      {
         var tile:String = null;
         var consumableCount:int = COLLECT_CONSUMABLE_COUNT;
         for each(tile in this.TilesArray as Array)
         {
            if(this.isTileUnLocked(tile))
            {
               consumableCount += COLLECT_CONSUMABLE_COUNT;
            }
         }
         FeatureOptionsInventoryManager.getInstance().addCount(this.ConsumableCode,consumableCount);
         Global.player.setFeatureLastShown(WHITEWINTER_COLLECT_CONSUMABLE_KEY,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"collectConsumables",null,[m_featureName]));
         return consumableCount;
      }
      
      public function isTileUnLocked(tileName:String) : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureOption();
         if(Boolean(featureData) && Boolean(featureData["tiles"].hasOwnProperty(tileName)) && featureData["tiles"][tileName] == 1)
         {
            result = true;
         }
         return result;
      }
      
      public function openBuyWindow(owner:FarmWindow) : void
      {
         UI.displayPopup(new FeaturePackagesBuyWindow(this.buyDialogURL,m_featureName,this.getBucketPackages(),owner),false);
      }
      
      public function askForConsumable(event:Event = null) : void
      {
         getFeedData(this.FEED_NAME).postFeed(this.onaskForConsumabel);
      }
      
      private function onaskForConsumabel(e:Object) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.refreshAskButton();
         }
      }
      
      public function generateAndSaveNextTasks() : void
      {
         var tasksToSave:Array = null;
         var i:int = 0;
         var taskObj:Object = null;
         var currentStageNum:int = this.getCurrentStage();
         var featureData:Object = this.getFeatureOption();
         currentStageNum++;
         featureData[KEY_CURRENT_STAGE] = currentStageNum;
         if(currentStageNum <= 20)
         {
            tasksToSave = [];
            for(i = 0; i < this.VAL_TASK_LENGTH; i++)
            {
               taskObj = {};
               taskObj[this.KEY_PROGRESS] = 0;
               tasksToSave.push(taskObj);
            }
            featureData[KEY_SAVED_ACTIVE_TASKS] = tasksToSave as Object;
         }
         setFeatureData(featureData);
      }
      
      protected function saveProgressForPlayer(progressArray:Array) : void
      {
         var taskObj:Object = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         var featureData:Object = this.getFeatureOption();
         var savedTasks:Array = featureData[KEY_SAVED_ACTIVE_TASKS] as Array;
         var tasksToSave:Array = [];
         for(var i:int = 0; i < this.VAL_TASK_LENGTH; i++)
         {
            taskObj = {};
            taskObj[this.KEY_PROGRESS] = savedTasks[i][this.KEY_PROGRESS] + progressArray[i];
            tasksToSave.push(taskObj);
         }
         featureData[KEY_SAVED_ACTIVE_TASKS] = tasksToSave as Object;
         setFeatureData(featureData);
      }
      
      protected function checkStageCompletion() : Boolean
      {
         var isComplete:Boolean = false;
         var tasks:Vector.<FarmTask> = this.getTasks();
         var stepsComplete:int = 0;
         var featureData:Object = this.getFeatureOption();
         var savedTaskInfo:Array = featureData[KEY_SAVED_ACTIVE_TASKS] as Array;
         for(var i:int = 0; i < tasks.length; i++)
         {
            if(savedTaskInfo[i][this.KEY_PROGRESS] >= tasks[i].total)
            {
               stepsComplete++;
            }
         }
         if(stepsComplete == tasks.length)
         {
            isComplete = true;
         }
         return isComplete;
      }
      
      public function getTasks() : Vector.<FarmTask>
      {
         var tasksXMLList:XMLList = null;
         var taskXML:XML = null;
         var taskObj:Object = null;
         var farmTask:FarmTask = null;
         var taskList:Vector.<FarmTask> = new Vector.<FarmTask>();
         if(this.m_tasksById == null)
         {
            this.parseTaskObjectsFromConfig();
         }
         var stageToShow:int = this.getCurrentStage();
         if(stageToShow > -1 && stageToShow < 20)
         {
            tasksXMLList = this.m_tasksById[this.getCurrentStage()].task;
            for each(taskXML in tasksXMLList)
            {
               taskObj = FarmGameUtil.xmlNodeToAttributes(taskXML);
               taskObj.questName = m_featureName;
               farmTask = new FarmTask(taskObj);
               taskList.push(farmTask);
            }
         }
         return taskList;
      }
      
      protected function parseTaskObjectsFromConfig(questName:String = "WhitewinterInnovation") : void
      {
         var taskXml:XML = null;
         var index:int = 0;
         var stagetasksList:XMLList = null;
         var tasksByStage:XML = null;
         var tasksXMLListByStage:XMLList = null;
         this.m_tasksById = {};
         taskXml = Global.farmGameSettingsManager.getXML().WhitewinterInnovationXml.WhitewinterInnovation.(@name == questName)[0];
         index = 0;
         if(taskXml)
         {
            stagetasksList = taskXml.WhitewinterInnovationTasks.stagetasks;
            for each(tasksByStage in stagetasksList)
            {
               tasksXMLListByStage = tasksByStage.tasks;
               var _loc5_:Number;
               this.m_tasksById[_loc5_ = index++] = tasksXMLListByStage;
            }
         }
      }
      
      public function getTaskProgress(taskIndex:int) : int
      {
         var progress:int = 0;
         var fo:Object = this.getFeatureOption();
         var savedTasksProgress:Array = fo[KEY_SAVED_ACTIVE_TASKS] as Array;
         if(Boolean(savedTasksProgress) && Boolean(savedTasksProgress[taskIndex][this.KEY_PROGRESS]))
         {
            progress = int(savedTasksProgress[taskIndex][this.KEY_PROGRESS]);
         }
         return progress;
      }
      
      public function getTimeRemaining() : String
      {
         var remainingTime:Number = NaN;
         var result:String = "0 Hours";
         if(!this.isExpired())
         {
            remainingTime = this.m_endTimeStamp - GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            result = FarmGameUtil.toFriendlyTime(remainingTime);
         }
         return result;
      }
      
      public function isExpired() : Boolean
      {
         var result:Boolean = true;
         var config:XML = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         if(config != null)
         {
            this.m_endTimeStamp = FarmGameUtil.synchronizedDateToNumber(config["listEndDate"]) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         }
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(this.m_endTimeStamp > 0 && this.m_endTimeStamp > currentTime)
         {
            result = false;
         }
         return result;
      }
      
      public function get rewardsArray() : Array
      {
         return this.m_staticData.rewardsArray;
      }
      
      public function get dateArray() : Array
      {
         return this.m_staticData.datesArray;
      }
      
      public function initialize() : void
      {
         this.loadStaticData();
         m_initialized = true;
      }
      
      public function getFeatureOption() : Object
      {
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption("WhitewinterInnovation","WhitewinterInnovation");
         if(!featureData)
         {
            featureData = new Object();
            featureData[KEY_GIFT_STATUS] = new Object();
            featureData[KEY_CURRENT_STAGE] = 0;
            featureData[TILE_UNLOCK_COUNT] = 0;
            featureData["tiles"] = new Object();
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,FEATURE_NAME,featureData);
         }
         return featureData;
      }
      
      public function isGiftAvailableForRedeem(slotIndex:int) : Boolean
      {
         var redeemable:Boolean = false;
         if(this.isrewardInEarnedState(slotIndex) && this.hasDatePassedForSlot(slotIndex))
         {
            redeemable = true;
         }
         return redeemable;
      }
      
      public function hasDatePassedForSlot(slotIndex:int) : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber(this.dateArray[slotIndex]) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         timeLeft = endTime - now;
         if(timeLeft <= 0)
         {
            result = true;
         }
         return result;
      }
      
      public function hasEndDatePassed() : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("01/05/2018") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         timeLeft = endTime - now;
         if(timeLeft <= 0)
         {
            result = true;
         }
         return result;
      }
      
      public function getCurrentCollectionName() : String
      {
         var stage:int = this.getCurrentStage();
         var result:String = null;
         if(stage < this.MILESTONE_STAGES[0])
         {
            result = COLLECTION1;
         }
         else if(stage < this.MILESTONE_STAGES[1])
         {
            result = COLLECTION2;
         }
         else if(stage <= this.MILESTONE_STAGES[2])
         {
            result = COLLECTION3;
         }
         return result;
      }
      
      public function isrewardRedeemed(slotIndex:int) : Boolean
      {
         var redeemed:Boolean = false;
         var featureOptionData:Object = this.getFeatureOption();
         if(featureOptionData.hasOwnProperty(KEY_GIFT_STATUS))
         {
            if(Boolean(featureOptionData[KEY_GIFT_STATUS].hasOwnProperty(slotIndex)) && featureOptionData[KEY_GIFT_STATUS][slotIndex] == 2)
            {
               redeemed = true;
            }
         }
         return redeemed;
      }
      
      public function isrewardInEarnedState(slotIndex:int) : Boolean
      {
         var earned:Boolean = false;
         var featureOptionData:Object = this.getFeatureOption();
         if(featureOptionData[KEY_GIFT_STATUS].hasOwnProperty(slotIndex))
         {
            if(featureOptionData[KEY_GIFT_STATUS][slotIndex] == 1)
            {
               earned = true;
            }
         }
         return earned;
      }
      
      public function grantAllEligibleRewards() : void
      {
         var rewardGrantCount:int = 0;
         var featureOptionData:Object = this.getFeatureOption();
         var rewardsList:Array = this.rewardsArray;
         for(var rewardIndex:int = 0; rewardIndex < rewardsList.length; rewardIndex++)
         {
            if(this.isGiftAvailableForRedeem(rewardIndex))
            {
               Global.player.addGift(rewardsList[rewardIndex]);
               rewardGrantCount++;
               featureOptionData[KEY_GIFT_STATUS][rewardIndex] = 2;
            }
         }
         FarmStatsManager.count("WhitewinterInnovation","RedeemGift","","","",rewardsList.length.toString());
         setFeatureData(featureOptionData);
         if(rewardGrantCount > 0)
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,SERVICE_FUNC_GRANT_ELIGIBLE_REWARDS,null,[m_featureName]));
         }
      }
      
      public function get TilesArray() : Array
      {
         return this.m_staticData.tilesArray;
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
         UI.displayMiniMarketDialog(this.lockedTilesArray,null,"seed",null,true,false,false,true);
      }
      
      private function loadStaticData() : void
      {
         var itemXML:XML = null;
         var tile:XML = null;
         var rewardName:String = null;
         var date:String = null;
         var reward:XML = null;
         var asset:XML = null;
         var tileName:String = null;
         this.m_staticData = new Object();
         this.m_staticData.bucketPackages = new Array();
         this.m_staticData.rewardsArray = new Array();
         this.m_staticData.datesArray = new Array();
         this.m_staticData.tilesArray = new Array();
         this.m_staticData.endDate = "";
         this.m_staticData.tricktreats = "";
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML("WhitewinterInnovation");
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
            this.m_staticData.tricktreats = featureXML.bucketItem.@code.toString();
            for each(itemXML in featureXML.bucketPackages.bucketPackage)
            {
               this.m_staticData.bucketPackages.push(itemXML.@name.toString());
            }
            for each(tile in featureXML.items.item)
            {
               tileName = tile.@name.toString();
               this.m_staticData.tilesArray.push(tileName);
            }
            for each(reward in featureXML.rewards.reward)
            {
               rewardName = reward.@name.toString();
               date = reward.@unlockDate.toString();
               this.m_staticData.rewardsArray.push(rewardName);
               this.m_staticData.datesArray.push(date);
            }
         }
      }
      
      public function get mainWindowURL() : String
      {
         return this.m_assetPaths[WINDOW_MAIN];
      }
      
      public function get buyDialogURL() : String
      {
         return this.m_assetPaths[WINDOW_BUYDIALOG];
      }
      
      public function get tileUnlockDialogURL() : String
      {
         return this.m_assetPaths[WINDOW_TILE_UNLOCK];
      }
      
      public function get giftDialogURL() : String
      {
         return this.m_assetPaths[WINDOW_GIFT];
      }
      
      public function get congratsDialogURL() : String
      {
         return this.m_assetPaths[WINDOW_CONGRATS];
      }
      
      public function getBucketPackages() : Array
      {
         return this.m_staticData.bucketPackages;
      }
      
      public function get ConsumableCode() : String
      {
         return this.m_staticData.tricktreats;
      }
      
      public function get consumableCount() : Number
      {
         return int(FeatureOptionsInventoryManager.getInstance().getCount(this.ConsumableCode));
      }
      
      public function openGiftWindow(e:Event = null, showGrant:Boolean = false) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
         UI.displayPopup(this.m_giftWindow = new WhitewinterInnovationRewardWindow(m_featureName,this.giftDialogURL,showGrant));
      }
      
      public function setupHud() : void
      {
         var extraData:Object = {};
         extraData["iconTooltip"] = ZLocUtils.t("Dialogs",m_featureName + "_HUDIcon_Tooltip");
         this.m_hud = Global.hud.rightSideIconQueue.addIcon(m_featureName,DynamicIconQueue.ADD_BY_PRIORITY,null,extraData) as QueuedIconWithArrow;
         if(this.m_hud)
         {
            this.m_hud.attachArrow(ArrowType.ARROWNEW);
            this.m_hud.setArrowText("New Feature!");
         }
      }
      
      public function showTileUnlockGrantPopup(e:TileUnlockEvent = null) : void
      {
         var featureOptionData:Object = null;
         if(this.hasEndDatePassed() == false && !this.isFeatureComplete())
         {
            this.showGrantPopup();
            featureOptionData = this.getFeatureOption();
            if(featureOptionData.hasOwnProperty(TILE_UNLOCK_COUNT))
            {
               featureOptionData[TILE_UNLOCK_COUNT] += 1;
               FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,FEATURE_NAME,featureOptionData);
            }
            this.resetCollectConsumableTimer(e.tileData.getItemName());
         }
      }
      
      public function showGrantPopup() : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         var consumableFarmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.ConsumableCode);
         UI.displayPopup(new WhiteWinterInnovationRewardPopup("assets/dialogs/expansion/FV_RewardDialog.swf",featureName,consumableFarmItem,null,"assets/dialogs/whitewinter/RewardDialog.png",false,1,true,"Awesome!"));
      }
      
      public function initEventListener() : void
      {
         GlobalEventManager.getInstance().addEventListener(EVENT_WW_INNOVATION_TILE_UNLOCK,this.showTileUnlockGrantPopup);
      }
      
      public function deleteEventListener() : void
      {
         GlobalEventManager.getInstance().removeEventListener(EVENT_WW_INNOVATION_TILE_UNLOCK,this.showTileUnlockGrantPopup);
      }
      
      public function getnextMilestoneDateAfterFeatureCompletion() : String
      {
         var endTimeStamp1:Number = NaN;
         var endTimeStamp2:Number = NaN;
         var endTimeStamp3:Number = NaN;
         var result:String = "";
         endTimeStamp1 = FarmGameUtil.synchronizedDateToNumber(this.dateArray[this.MILESTONE_STAGES[0] - 1]) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTimeStamp2 = FarmGameUtil.synchronizedDateToNumber(this.dateArray[this.MILESTONE_STAGES[1] - 1]) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTimeStamp3 = FarmGameUtil.synchronizedDateToNumber(this.dateArray[this.MILESTONE_STAGES[2] - 1]) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(currentTime < endTimeStamp1)
         {
            result = "25 Dec 2017";
         }
         else if(currentTime < endTimeStamp2)
         {
            result = "1st Jan 2018";
         }
         else if(currentTime < endTimeStamp3)
         {
            result = "5th Jan 2018";
         }
         return result;
      }
      
      public function getnextMileStoneDate() : String
      {
         var result:String = "";
         if(!this.hasDatePassedForSlot(this.MILESTONE_STAGES[0]))
         {
            result = this.dateArray[this.MILESTONE_STAGES[0]];
         }
         else if(!this.hasDatePassedForSlot(this.MILESTONE_STAGES[1]))
         {
            result = this.dateArray[this.MILESTONE_STAGES[1]];
         }
         else if(!this.hasDatePassedForSlot(this.MILESTONE_STAGES[2]))
         {
            result = this.dateArray[this.MILESTONE_STAGES[2]];
         }
         return result;
      }
      
      public function isFeatureComplete() : Boolean
      {
         var stage:int = int(this.getCurrentStage());
         return stage >= 20 ? true : false;
      }
      
      public function getTreeProgressLevel() : int
      {
         var result:int = 0;
         var stage:int = int(this.getCurrentStage());
         if(stage < this.TREE_STAGES[0])
         {
            result = 1;
         }
         else if(stage < this.TREE_STAGES[1])
         {
            result = 2;
         }
         else if(stage < this.TREE_STAGES[2])
         {
            result = 3;
         }
         else if(stage < this.TREE_STAGES[3])
         {
            result = 4;
         }
         else
         {
            result = 5;
         }
         return result;
      }
      
      public function getProgressMeterLevelCounter() : Object
      {
         var stage:int = int(this.getCurrentStage());
         var result:Object = new Object();
         if(stage < this.TREE_STAGES[0])
         {
            result.stage = stage;
            result.counter = 1;
         }
         else if(stage < this.TREE_STAGES[1])
         {
            result.stage = stage - this.TREE_STAGES[0];
            result.counter = 1;
         }
         else if(stage < this.TREE_STAGES[2])
         {
            result.stage = stage - this.TREE_STAGES[1];
            result.counter = 2;
         }
         else if(stage < this.TREE_STAGES[3])
         {
            result.stage = stage - this.TREE_STAGES[2];
            result.counter = 3;
         }
         return result;
      }
      
      public function getRedeemableRewardCount() : int
      {
         var count:int = 0;
         for(var index:int = 0; index < this.rewardsArray.length; index++)
         {
            if(this.isGiftAvailableForRedeem(index))
            {
               count++;
            }
         }
         return count;
      }
      
      public function hasEnoughConsumableForSink(total:int) : Boolean
      {
         var canSink:Boolean = false;
         var lettersCount:Number = FeatureOptionsInventoryManager.getInstance().getCount(this.ConsumableCode);
         if(lettersCount >= total)
         {
            canSink = true;
         }
         return canSink;
      }
      
      public function sinkConsumable() : void
      {
         var tasksToSave:Array = null;
         var i:int = 0;
         var taskObj:Object = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         var sinkCount:int = tasks[SINK_CONSUMABLE_TASK_INDEX].total;
         FeatureOptionsInventoryManager.getInstance().removeCount(this.ConsumableCode,sinkCount);
         var featureData:Object = this.getFeatureOption();
         var savedTasks:Array = featureData[KEY_SAVED_ACTIVE_TASKS] as Array;
         if(!savedTasks)
         {
            tasksToSave = [];
            for(i = 0; i < tasks.length; i++)
            {
               taskObj = {};
               taskObj[this.KEY_PROGRESS] = 0;
               tasksToSave.push(taskObj);
            }
            savedTasks = tasksToSave;
         }
         if(this.m_mainWindow)
         {
            this.m_mainWindow.refreshCollectButton();
         }
         savedTasks[SINK_CONSUMABLE_TASK_INDEX][this.KEY_PROGRESS] = tasks[SINK_CONSUMABLE_TASK_INDEX].total;
         featureData[KEY_SAVED_ACTIVE_TASKS] = savedTasks;
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,FEATURE_NAME,featureData);
         var isQuestComplete:Boolean = this.checkStageCompletion();
         if(isQuestComplete)
         {
            this.doPostStageCompletionTask();
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,SERVICE_FUNC_SINK_CONSUMABLE,null,[m_featureName]),true);
      }
      
      public function isShowGrantMC() : Boolean
      {
         var result:Boolean = false;
         if(this.m_giftWindow)
         {
            result = this.m_giftWindow.isShowGrantMC();
         }
         return result;
      }
      
      public function getLastEarnedRewardIndex() : int
      {
         var key:int = 0;
         var featureOptionData:Object = this.getFeatureOption();
         var giftStatusArray:Object = featureOptionData[KEY_GIFT_STATUS] as Object;
         var result:int = 0;
         if(giftStatusArray)
         {
            for each(key in giftStatusArray)
            {
               result++;
            }
         }
         return result > 0 ? int(result - 1) : int(result);
      }
      
      public function checkrewardDate(m_slotIndex:int) : String
      {
         return this.dateArray[m_slotIndex];
      }
      
      public function resetTileUnlock() : void
      {
         var featureOptionData:Object = this.getFeatureOption();
         if(featureOptionData.hasOwnProperty(TILE_UNLOCK_COUNT))
         {
            featureOptionData[TILE_UNLOCK_COUNT] = 0;
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,FEATURE_NAME,featureOptionData);
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"resetTileUnlockCount",null,[m_featureName]),true);
      }
      
      public function getTileUnlockCount() : int
      {
         var result:int = 0;
         var featureOptionData:Object = this.getFeatureOption();
         if(featureOptionData.hasOwnProperty(TILE_UNLOCK_COUNT))
         {
            result = int(featureOptionData[TILE_UNLOCK_COUNT]);
         }
         return result;
      }
      
      public function forceGrantWhiteWinterRewards() : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         if(this.getRedeemableRewardCount() > 0)
         {
            this.openGiftWindow();
         }
      }
   }
}

