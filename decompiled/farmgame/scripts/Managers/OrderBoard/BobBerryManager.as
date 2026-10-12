package Managers.OrderBoard
{
   import Cache.Classes.ZCacheUtil;
   import Classes.BobBerryFarmMapTrigger;
   import Classes.Constants.ArrowType;
   import Classes.Constants.QuestConstants;
   import Classes.MapTrigger;
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.QueuedIcons.SpecialQuestIcon;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.InputManager;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureMessagingManager;
   import Managers.FeatureOptionsManager;
   import Managers.ItemFinderManager;
   import Managers.MapTriggerManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.BobBerryFarmWindow;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class BobBerryManager extends SpecialQuestManager
   {
      
      private static const OPEN_UI_DELAY:int = 4000;
      
      public static const CASH_VALUE_FOR_DIFFICULTY_CHANGE:int = 1;
      
      private static const TIME_FOR_CHANGE_QUEST_IN_HRS:int = 24;
      
      private static const TIME_FOR_SHOWING_COMEBACK_POPUP_IN_DAYS:int = 3;
      
      private static const KEY_SAVED_DIFFICULTY:String = "0";
      
      private static const KEY_SAVED_ACTIVE_TASKS:String = "1";
      
      private static const KEY_SAVED_DIFFICULTY_CHANGE_TIMESTAMP:String = "3";
      
      private static const KEY_SAVED_SEEN_REWARD:String = "4";
      
      private static const KEY_SAVED_HAS_SEEN_FIRST_REWARD_DIALOG:String = "5";
      
      private static const KEY_SAVED_FEATURE_SHOWN_TIMESTAMP:String = "6";
      
      private static const VAL_SAVED_REWARD_NOT_SEEN:String = "0";
      
      private static const VAL_SAVED_REWARD_SEEN:String = "1";
      
      private static const VAL_SAVED_FIRST_REWARD_DIALOG_SEEN:String = "1";
      
      private static const SERVICE_NAME:String = "BobBerryService";
      
      private static const FUNCTION_DIFFICULTY_CHANGE:String = "resetDifficulty";
      
      private static const FUNTION_SET_FEATURE_SHOWN_TIMESTAMP:String = "setFeatureShownTimestamp";
      
      private static const FUNCTION_SET_REWARD_AS_SEEN:String = "setRewardSeen";
      
      private static const FUNCTION_SET_FIRST_REWARD_AS_SEEN:String = "setFirstRewardSeen";
      
      private var m_tasksById:Object = null;
      
      private var m_rewardsBySlotName:Object = null;
      
      private var m_currencyName:String = "berry";
      
      private var m_currencyLimit:int = -1;
      
      private var m_dialog:String = null;
      
      private var m_endTimeStamp:Number = 0;
      
      private var m_timer:Timer;
      
      private var m_hud:SpecialQuestIcon;
      
      protected const KEY_ID:String = "id";
      
      protected const KEY_PROGRESS:String = "progress";
      
      protected const KEY_TYPE:String = "type";
      
      protected const KEY_TOTAL:String = "total";
      
      protected const KEY_WORLD_CURRENCY:String = "world_currency";
      
      protected const KEY_VALUE:String = "value";
      
      public function BobBerryManager(featureName:String)
      {
         super(featureName);
         this.parseFeatureConfig();
         this.parseTaskObjectsFromConfig(m_featureName);
         this.parseRewardsDataFromConfig(m_featureName);
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
         this.setupHud();
      }
      
      public static function getInstance(featureName:String) : BobBerryManager
      {
         return getInstanceOfClass(featureName,BobBerryManager) as BobBerryManager;
      }
      
      private function setupHud() : void
      {
         var extraData:Object = {};
         extraData["iconTooltip"] = ZLocUtils.t("Dialogs",m_featureName + "_tooltip");
         this.m_hud = Global.hud.rightSideIconQueue.addIcon(m_featureName,DynamicIconQueue.ADD_BY_PRIORITY,null,extraData) as SpecialQuestIcon;
         if(this.m_hud)
         {
            this.m_hud.onAdd();
            this.m_hud.attachArrow(ArrowType.ARROWNEW);
            this.m_hud.playProgressBarAnimation(this.getTasksProgressRatio());
         }
      }
      
      private function saveSeenRewardStatus(hasSeen:String) : void
      {
         this.saveFeatureOptionsKey(KEY_SAVED_SEEN_REWARD,hasSeen);
      }
      
      public function setRewardStatusAsSeen(callback:Function) : void
      {
         this.saveSeenRewardStatus(VAL_SAVED_REWARD_SEEN);
         var mapTrigger:BobBerryFarmMapTrigger = MapTriggerManager.getInstance().getMapTriggerByName(m_featureName) as BobBerryFarmMapTrigger;
         mapTrigger.updateState();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,FUNCTION_SET_REWARD_AS_SEEN,ZCacheUtil.applyPartial(this.onRewardTransactionComplete,this,[callback]),new Array(m_featureName)),true);
      }
      
      public function onRewardTransactionComplete(callback:Function, result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("activeTasks"))
         {
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,result["activeTasks"]);
            callback.call();
            if(this.m_hud)
            {
               this.m_hud.onComplete();
               this.m_hud.attachArrow(ArrowType.ARROWNEW);
            }
         }
      }
      
      public function shouldShowReward() : Boolean
      {
         var result:Boolean = false;
         var key:String = this.getFeatureOptionsKey(KEY_SAVED_SEEN_REWARD) as String;
         if(Boolean(key) && key == VAL_SAVED_REWARD_NOT_SEEN)
         {
            result = true;
         }
         return result;
      }
      
      public function hasSeenFirstRewardDialog() : Boolean
      {
         var result:Boolean = false;
         var key:String = this.getFeatureOptionsKey(KEY_SAVED_HAS_SEEN_FIRST_REWARD_DIALOG) as String;
         if(Boolean(key) && key == VAL_SAVED_FIRST_REWARD_DIALOG_SEEN)
         {
            result = true;
         }
         return result;
      }
      
      private function saveSeenFirstRewardStatus(hasSeen:String) : void
      {
         this.saveFeatureOptionsKey(KEY_SAVED_HAS_SEEN_FIRST_REWARD_DIALOG,hasSeen);
      }
      
      public function setFirstRewardStatusAsSeen() : void
      {
         this.saveSeenFirstRewardStatus(VAL_SAVED_FIRST_REWARD_DIALOG_SEEN);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,FUNCTION_SET_FIRST_REWARD_AS_SEEN,null,new Array(m_featureName)));
      }
      
      public function skipTask(questIndex:int) : void
      {
         var savedTasks:Array = null;
         var isQuestComplete:Boolean = false;
         var tasks:Vector.<FarmTask> = this.getTasks();
         if(Global.player.canBuyCash(tasks[questIndex].skipCashValue))
         {
            Global.player.cash -= tasks[questIndex].skipCashValue;
            savedTasks = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
            savedTasks[questIndex][this.KEY_PROGRESS] = tasks[questIndex].total;
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,savedTasks);
            isQuestComplete = this.checkQuestCompletion();
            if(isQuestComplete)
            {
               this.doQuestPostCompletionTasks();
            }
            else if(this.m_hud)
            {
               this.m_hud.attachArrow(ArrowType.ARROWUPDATE);
               this.m_hud.playProgressBarAnimation(this.getTasksProgressRatio());
            }
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipTask",null,new Array(m_featureName,questIndex)),true);
         }
      }
      
      public function skipAllTasks() : void
      {
         var skipAllCash:int = BobBerryManager.getInstance(m_featureName).getSkipAllCashValue();
         if(skipAllCash > 0 && Global.player.canBuyCash(skipAllCash))
         {
            Global.player.cash -= skipAllCash;
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipAllTasks",null,new Array(m_featureName)),true);
            this.doQuestPostCompletionTasks();
         }
      }
      
      public function showBobAndOpenWindow() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(m_featureName,this.showUI);
         var mapTrigger:MapTrigger = MapTriggerManager.getInstance().getMapTriggerByName(m_featureName);
         if(mapTrigger)
         {
            ItemFinderManager.getInstance().highlightWorldItems(mapTrigger.getItemName());
            this.m_timer = new Timer(OPEN_UI_DELAY,1);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.showUI);
            this.m_timer.start();
            InputManager.disableInput();
         }
         else
         {
            this.showUI();
         }
      }
      
      public function showUI(event:Event = null) : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.showUI);
            InputManager.enableInput();
            UI.stopPopups(false);
         }
         this.openBobBerryFarmWindow();
      }
      
      protected function onTransactionAdded(event:TransactionEvent) : void
      {
         this.checkForTaskUpdates(event);
      }
      
      protected function checkForTaskUpdates(event:TransactionEvent) : void
      {
         var transaction:TFarmTransaction = null;
         var task:FarmTask = null;
         var isComplete:Boolean = false;
         var progress:Number = 0;
         var hasUpdatedProgress:Boolean = false;
         var progressArray:Array = [];
         var tasks:Vector.<FarmTask> = this.getTasks();
         for each(task in tasks)
         {
            transaction = event.transaction as TFarmTransaction;
            progress = FarmQuestUtility.getInstance().getProgression(task,transaction,null);
            progressArray.push(progress);
            if(progress > 0)
            {
               hasUpdatedProgress = true;
            }
         }
         if(hasUpdatedProgress)
         {
            this.saveProgressForPlayer(progressArray);
            isComplete = this.checkQuestCompletion();
            if(isComplete)
            {
               this.doQuestPostCompletionTasks();
            }
            else if(this.m_hud)
            {
               this.m_hud.attachArrow(ArrowType.ARROWUPDATE);
               this.m_hud.playProgressBarAnimation(this.getTasksProgressRatio());
            }
         }
      }
      
      protected function doQuestPostCompletionTasks() : void
      {
         var rewards:Vector.<Object> = this.getRewards();
         UserRewardUtil.grantUserRewards(rewards);
         this.saveSeenRewardStatus(VAL_SAVED_REWARD_NOT_SEEN);
         var mapTrigger:BobBerryFarmMapTrigger = MapTriggerManager.getInstance().getMapTriggerByName(m_featureName) as BobBerryFarmMapTrigger;
         mapTrigger.updateState();
         this.resetActionCountsForTasks();
         this.removeFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS);
         if(this.hasReachedCurrencyLimit())
         {
            this.removeFeatureOptionsKey(KEY_SAVED_DIFFICULTY);
            this.saveSeenRewardStatus(VAL_SAVED_REWARD_SEEN);
         }
         if(this.m_hud)
         {
            this.m_hud.attachArrow(ArrowType.ARROWUPDATE);
            this.m_hud.playProgressBarAnimation(this.getTasksProgressRatio());
         }
      }
      
      private function resetActionCountsForTasks() : void
      {
         var actionKey:String = null;
         var questTasks:Vector.<FarmTask> = this.getTasks();
         for(var i:int = 0; i < questTasks.length; i++)
         {
            if(questTasks[i].action == QuestConstants.TASK_USE_ITEM_BY_CODE)
            {
               actionKey = questTasks[i].getActionKey();
               if(Boolean(actionKey) && actionKey != "")
               {
                  Global.player.resetActionCount(actionKey);
               }
            }
         }
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
            taskObj[this.KEY_ID] = tasks[i].id;
            taskObj[this.KEY_PROGRESS] = Math.min(savedTasks[i][this.KEY_PROGRESS] + progressArray[i],tasks[i][this.KEY_TOTAL]);
            tasksToSave.push(taskObj);
         }
         this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,tasksToSave as Object);
      }
      
      protected function checkQuestCompletion() : Boolean
      {
         var isComplete:Boolean = false;
         var tasks:Vector.<FarmTask> = this.getTasks();
         var stepsComplete:int = 0;
         var savedTaskInfo:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
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
      
      private function getTasksProgressRatio() : Number
      {
         var i:int = 0;
         var result:Number = 0;
         var tasks:Vector.<FarmTask> = this.getTasks();
         var stepsComplete:int = 0;
         var savedTaskInfo:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         if(Boolean(savedTaskInfo) && Boolean(savedTaskInfo.length))
         {
            for(i = 0; i < tasks.length; i++)
            {
               if(savedTaskInfo[i][this.KEY_PROGRESS] >= tasks[i].total)
               {
                  stepsComplete++;
               }
            }
            result = stepsComplete / savedTaskInfo.length;
         }
         return result;
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
               taskObj = FarmGameUtil.xmlNodeToAttributes(taskXML);
               taskObj.questName = m_featureName;
               taskObj.taskIndex = savedTaskInfo.indexOf(task);
               farmTask = new FarmTask(taskObj);
               taskList.push(farmTask);
            }
         }
         return taskList;
      }
      
      override public function getRewards() : Vector.<Object>
      {
         var rewards:Vector.<Object> = new Vector.<Object>();
         if(this.m_rewardsBySlotName == null)
         {
            this.parseRewardsDataFromConfig(m_featureName);
         }
         var slotName:String = this.getFeatureOptionsKey(KEY_SAVED_DIFFICULTY) as String;
         return this.m_rewardsBySlotName[slotName];
      }
      
      public function getSkipAllCashValue() : int
      {
         var progress:int = 0;
         var value:int = 0;
         var tasks:Vector.<FarmTask> = this.getTasks();
         for(var i:int = 0; i < tasks.length; i++)
         {
            progress = this.getTaskProgress(i);
            if(progress < tasks[i].total)
            {
               value += tasks[i].skipCashValue;
            }
         }
         return value;
      }
      
      public function deductCashForDifficulty() : void
      {
         if(Global.player.canBuyCash(BobBerryManager.CASH_VALUE_FOR_DIFFICULTY_CHANGE))
         {
            Global.player.cash -= BobBerryManager.CASH_VALUE_FOR_DIFFICULTY_CHANGE;
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"saveDifficultyChangedTimestamp",null,[m_featureName]),true);
            this.saveFeatureOptionsKey(KEY_SAVED_DIFFICULTY_CHANGE_TIMESTAMP,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND);
            this.resetActionCountsForTasks();
            this.removeFeatureOptionsKey(KEY_SAVED_DIFFICULTY);
         }
      }
      
      public function getAllDifficultyRewardsData() : Object
      {
         var rewards:Vector.<Object> = new Vector.<Object>();
         if(this.m_rewardsBySlotName == null)
         {
            this.parseRewardsDataFromConfig(m_featureName);
         }
         return this.m_rewardsBySlotName;
      }
      
      protected function getFeatureOptionsKey(optionName:String) : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,optionName);
      }
      
      protected function saveFeatureOptionsKey(optionName:String, optionsValue:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,optionName,optionsValue);
      }
      
      protected function removeFeatureOptionsKey(optionName:String) : void
      {
         FeatureOptionsManager.deleteFeatureOption(m_featureName,optionName);
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
      
      public function startQuest(difficulty:String, callback:Function) : void
      {
         this.saveFeatureOptionsKey(KEY_SAVED_DIFFICULTY,difficulty);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startQuest",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,difficulty)),true);
      }
      
      public function onInitQuestComplete(callback:Function, result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("activeTasks"))
         {
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,result["activeTasks"]);
            callback.call();
         }
      }
      
      protected function parseFeatureConfig() : void
      {
         var config:XML = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         if(config != null)
         {
            this.m_currencyName = config["currency"]["@name"];
            this.m_currencyLimit = config["currency"]["@limit"];
            this.m_dialog = config["window"]["@name"];
            this.m_endTimeStamp = FarmGameUtil.synchronizedDateToNumber(config["listEndDate"]) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         }
      }
      
      protected function parseRewardsDataFromConfig(questName:String) : void
      {
         var orderBoardXml:XML = null;
         var rewardsList:XMLList = null;
         var rewardsBySlot:XML = null;
         var rewardsVector:Vector.<Object> = null;
         var rewards:XMLList = null;
         var reward:XML = null;
         this.m_rewardsBySlotName = {};
         orderBoardXml = Global.farmGameSettingsManager.getXML().orderBoards.orderBoard.(@name == questName)[0];
         rewardsList = orderBoardXml.orderBoardRewards.slot;
         for each(rewardsBySlot in rewardsList)
         {
            rewardsVector = new Vector.<Object>();
            rewards = rewardsBySlot.children();
            for each(reward in rewards)
            {
               rewardsVector.push(FarmGameUtil.xmlNodeToAttributes(reward));
            }
            this.m_rewardsBySlotName[rewardsBySlot.@name] = rewardsVector;
         }
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
      
      public function isDifficultySet() : Boolean
      {
         var isActive:Boolean = false;
         var difficulty:String = this.getFeatureOptionsKey(KEY_SAVED_DIFFICULTY) as String;
         if(Boolean(difficulty) && difficulty != "")
         {
            isActive = true;
         }
         return isActive;
      }
      
      public function getDifficulty() : String
      {
         return this.getFeatureOptionsKey(KEY_SAVED_DIFFICULTY) as String;
      }
      
      public function isFreeDifficultyChangeAllowed() : Boolean
      {
         var result:Boolean = false;
         var throttleTime:Number = TIME_FOR_CHANGE_QUEST_IN_HRS * FarmGameUtil.NUM_SECS_IN_HOUR;
         var lastDiffChangedTimestamp:Number = this.getFeatureOptionsKey(KEY_SAVED_DIFFICULTY_CHANGE_TIMESTAMP) as Number;
         if(!lastDiffChangedTimestamp)
         {
            lastDiffChangedTimestamp = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         }
         var timeSinceLastChanged:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - lastDiffChangedTimestamp;
         var timeLeftForAllow:Number = throttleTime - timeSinceLastChanged;
         return timeLeftForAllow <= 0;
      }
      
      public function changeDifficulty(difficulty:String, callback:Function) : void
      {
         this.saveFeatureOptionsKey(KEY_SAVED_DIFFICULTY,difficulty);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,FUNCTION_DIFFICULTY_CHANGE,ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,difficulty)),true);
         if(this.m_hud)
         {
            this.m_hud.onComplete();
            this.m_hud.attachArrow(ArrowType.ARROWNEW);
         }
      }
      
      public function shouldShowComeBackPopup() : Boolean
      {
         var timeSinceLastPlayed:Number = NaN;
         var result:Boolean = false;
         var lastPlayedTimestamp:int = this.getFeatureOptionsKey(KEY_SAVED_FEATURE_SHOWN_TIMESTAMP) as Number;
         if(Boolean(lastPlayedTimestamp) && lastPlayedTimestamp > 0)
         {
            timeSinceLastPlayed = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - lastPlayedTimestamp;
            result = timeSinceLastPlayed >= TIME_FOR_SHOWING_COMEBACK_POPUP_IN_DAYS * FarmGameUtil.NUM_SECS_IN_DAY;
         }
         return result;
      }
      
      public function setFeatureSeenTimeStamp() : void
      {
         this.saveFeatureOptionsKey(KEY_SAVED_FEATURE_SHOWN_TIMESTAMP,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,FUNTION_SET_FEATURE_SHOWN_TIMESTAMP,null,new Array(m_featureName)),false);
      }
      
      public function hasReachedCurrencyLimit() : Boolean
      {
         var result:Boolean = true;
         if(Boolean(this.m_currencyName) && this.m_currencyLimit != -1)
         {
            if(Global.player.getWorldCurrencyTotal(this.m_currencyName) < this.m_currencyLimit)
            {
               result = false;
            }
         }
         return result;
      }
      
      public function get currencyLimit() : int
      {
         return this.m_currencyLimit;
      }
      
      public function get currencyName() : String
      {
         return this.m_currencyName;
      }
      
      public function getCurrentCurrencyCount() : int
      {
         return Global.player.getWorldCurrencyTotal(this.m_currencyName);
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
      
      public function openBobBerryFarmWindow() : void
      {
         UI.displayPopup(new BobBerryFarmWindow(this.m_dialog,m_featureName));
      }
      
      public function isExpired() : Boolean
      {
         var result:Boolean = true;
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(this.m_endTimeStamp > 0 && this.m_endTimeStamp > currentTime)
         {
            result = false;
         }
         return result;
      }
      
      public function isQuestsActive() : Boolean
      {
         var tasks:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         var result:Boolean = false;
         if(Boolean(tasks) && tasks.length > 0)
         {
            result = true;
         }
         return result;
      }
      
      public function getWaitTimeText() : String
      {
         var throttle:Number = FarmGameUtil.NUM_HOURS_IN_DAY * FarmGameUtil.NUM_SECS_IN_HOUR;
         var timeLeft:String = throttle.toString();
         var timeInInt:int = int(FarmGameUtil.NUM_HOURS_IN_DAY);
         var timeSinceLastChanged:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - (this.getFeatureOptionsKey(KEY_SAVED_DIFFICULTY_CHANGE_TIMESTAMP) as Number);
         var timeLeftForAllow:Number = throttle - timeSinceLastChanged;
         if(timeLeftForAllow > 0 && timeLeftForAllow < throttle)
         {
            timeInInt = timeLeftForAllow / FarmGameUtil.NUM_SECS_IN_HOUR;
            if(timeInInt == 0)
            {
               timeInInt = 1;
               timeInInt = 1;
            }
         }
         return timeInInt.toString() + " hours";
      }
      
      public function changeQuestWithoutCash() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"saveDifficultyChangedTimestamp",null,[m_featureName]),true);
         this.saveFeatureOptionsKey(KEY_SAVED_DIFFICULTY_CHANGE_TIMESTAMP,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND);
         this.resetActionCountsForTasks();
         this.removeFeatureOptionsKey(KEY_SAVED_DIFFICULTY);
      }
   }
}

