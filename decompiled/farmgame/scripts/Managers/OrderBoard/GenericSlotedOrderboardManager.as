package Managers.OrderBoard
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.QuestConstants;
   import Classes.FeatureBuilding;
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Managers.BaseFeatureManager;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureCraftingManager;
   import Managers.FeatureOptionsManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   
   public class GenericSlotedOrderboardManager extends BaseFeatureManager
   {
      
      protected static var m_instance:Object = {};
      
      protected static const KEY_SAVED_ACTIVE_TASKS:String = "saved_active_tasks";
      
      protected static const ORDERBOARD_MAX_LIMIT:int = 10000;
      
      protected static const KEY_SAVED_DUMPED_TIMESTAMP:String = "saved_dumped_timestamp";
      
      protected static const SKIP_COST:int = 1;
      
      protected var m_featureConfigData:Object;
      
      public var m_isEA:Boolean;
      
      protected var SERVICE_NAME:String;
      
      protected var m_tasksById:Object = null;
      
      protected const KEY_TASK_ID:String = "id";
      
      protected const KEY_ORDERBOARD_PROGRESS:String = "orderboard_progress";
      
      protected var m_orderboardWindow:*;
      
      protected const KEY_TOTAL:String = "total";
      
      protected const KEY_ORDERBOARD_TASK_POINTS:String = "orderboard_task_points";
      
      protected const KEY_TOTAL_BORABORAMONEY:String = "bbt";
      
      public function GenericSlotedOrderboardManager(featureName:String, serviceName:String)
      {
         super(featureName);
         this.parseTaskObjectsFromConfig(featureName);
         this.SERVICE_NAME = serviceName;
         this.m_featureConfigData = new Object();
      }
      
      public static function getInstance(featureName:String) : GenericSlotedOrderboardManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,GenericSlotedOrderboardManager) as GenericSlotedOrderboardManager;
      }
      
      public function onInitQuestComplete(callback:Function, result:Object) : void
      {
         var resultObject:Object = result;
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
            if(Boolean(callback))
            {
               callback.call();
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
      
      public function getTasks() : Vector.<FarmTask>
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
               taskXML = this.m_tasksById[task[this.KEY_TASK_ID]];
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
                  taskObj = {};
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
               taskObj[this.KEY_TASK_ID] = tasks[i].id;
            }
            if(tasks[i].helperType == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
            {
               taskObj[this.KEY_ORDERBOARD_PROGRESS] = CraftingManager.getInstance().getBushelQuantityInInventory(tasks[i].type);
            }
            else
            {
               taskObj[this.KEY_ORDERBOARD_PROGRESS] = Math.min(Number(savedTasks[i][this.KEY_ORDERBOARD_PROGRESS]) + progressArray[i],tasks[i][this.KEY_TOTAL]);
            }
            tasksToSave.push(taskObj);
         }
         this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,tasksToSave as Object);
      }
      
      public function startQuest(callback:Function = null) : void
      {
         var savedTaskInfo:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         if(!(savedTaskInfo && savedTaskInfo.length))
         {
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"startQuest",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName)),true);
         }
      }
      
      protected function checkForTaskUpdates(event:TransactionEvent) : void
      {
         var progress:Number = NaN;
         var transaction:TFarmTransaction = null;
         var buildingFarmItem:FarmItem = null;
         var objects:Array = null;
         var currentProgress:int = 0;
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
               progress = CraftingManager.getInstance().getBushelQuantityInInventory(tasks[i].type) - savedTasks[i][this.KEY_ORDERBOARD_PROGRESS];
               hasUpdatedProgress = true;
               FarmStatsManager.count("TropicalMarketInnovation","PerformTask",tasks[i].questName,tasks[i].titleText);
            }
            else
            {
               progress = FarmQuestUtility.getInstance().getProgression(tasks[i],transaction,null);
            }
            progressArray.push(progress);
            if(progress > 0)
            {
               hasUpdatedProgress = true;
               if(Number(savedTasks[i][this.KEY_ORDERBOARD_PROGRESS]) + progress >= tasks[i].total)
               {
                  hasCompletedTask = true;
                  FarmStatsManager.count("TropicalMarketInnovation","PerformTask",tasks[i].questName,tasks[i].titleText);
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
            if(Global.hud.m_bottomHudTropicalMarketInnovationButton)
            {
               Global.hud.m_bottomHudTropicalMarketInnovationButton.refresh(1);
            }
         }
      }
      
      public function getTaskProgress(slotIndex:int) : int
      {
         var task:FarmTask = null;
         var buildingFarmItem:FarmItem = null;
         var objects:Array = null;
         var buildingName:String = null;
         var craftingSystem:FeatureCraftingSystem = null;
         var npcData:Object = null;
         var level:int = 0;
         var animalObject:Object = null;
         var progress:int = 0;
         task = this.getTasks()[slotIndex];
         var savedActiveTasks:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
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
               buildingName = "xah_elitehorses";
               craftingSystem = FeatureCraftingManager.instance.getSystem(buildingName);
               if(craftingSystem)
               {
                  npcData = craftingSystem.npcData;
                  level = 0;
                  for each(animalObject in npcData)
                  {
                     if(animalObject.hasOwnProperty("complete"))
                     {
                        if(animalObject["complete"] == true)
                        {
                           level++;
                        }
                     }
                  }
                  if(level >= task.level)
                  {
                     progress = 1;
                  }
               }
               break;
            case "sinkBushel":
               progress = CraftingManager.getInstance().getBushelQuantityInInventory(task.type);
               break;
            default:
               progress = int(savedActiveTasks[slotIndex][this.KEY_ORDERBOARD_PROGRESS]);
         }
         return progress;
      }
      
      public function isTaskRedeemable(slotIndex:int) : Boolean
      {
         var result:Boolean = false;
         var progress:int = this.getTaskProgress(slotIndex);
         var task:FarmTask = this.getTasks()[slotIndex];
         if(progress >= task.total)
         {
            result = true;
         }
         return result;
      }
      
      protected function resetActionCountsForTasks(questTask:FarmTask) : void
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
      
      public function isTaskDumped(questIndex:int) : Boolean
      {
         var result:Boolean = false;
         var savedTasks:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         if(!savedTasks[questIndex].hasOwnProperty(this.KEY_TASK_ID))
         {
            result = true;
         }
         return result;
      }
      
      public function skipTask(questIndex:int, taskPoints:int, callback:Function) : void
      {
         var savedTasks:Array = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         if(Global.player.canBuyCash(tasks[questIndex].skipCashValue))
         {
            Global.player.cash -= tasks[questIndex].skipCashValue;
            this.grantPointsForTask(taskPoints);
            savedTasks = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
            savedTasks[questIndex][this.KEY_ORDERBOARD_PROGRESS] = tasks[questIndex].total;
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,savedTasks);
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"skipTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
            this.resetActionCountsForTasks(tasks[questIndex]);
            if(this.m_orderboardWindow)
            {
               this.m_orderboardWindow.refreshWindow();
            }
         }
         else
         {
            callback.call();
         }
      }
      
      public function getNewTasks(questIndex:int, callback:Function) : void
      {
         var tasks:Vector.<FarmTask> = this.getTasks();
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"getNewTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
         var dumpTimestamp:Object = this.getFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP) as Object;
         dumpTimestamp[questIndex] = 0;
         this.saveFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP,dumpTimestamp);
         this.resetActionCountsForTasks(tasks[questIndex]);
         if(this.m_orderboardWindow)
         {
            this.m_orderboardWindow.refreshTaskFrame();
         }
      }
      
      public function grantPointsForTask(pointsForTask:int) : void
      {
         var currentProgress:int = this.getOrderboardProgress();
         if(currentProgress < ORDERBOARD_MAX_LIMIT)
         {
            if(pointsForTask + currentProgress > ORDERBOARD_MAX_LIMIT)
            {
               this.saveFeatureOptionsKey(this.KEY_ORDERBOARD_TASK_POINTS,ORDERBOARD_MAX_LIMIT);
            }
            else
            {
               this.saveFeatureOptionsKey(this.KEY_ORDERBOARD_TASK_POINTS,pointsForTask + currentProgress);
               this.saveFeatureOptionsKey(this.KEY_TOTAL_BORABORAMONEY,(this.getFeatureOptionsKey(this.KEY_TOTAL_BORABORAMONEY) as int) + pointsForTask);
            }
         }
      }
      
      public function redeemRewardPoints(questIndex:int, callback:Function, taskPoints:int = 0) : void
      {
         var tasks:Vector.<FarmTask> = this.getTasks();
         this.grantPointsForTask(tasks[questIndex].questPoints);
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"redeemRewardPoints",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
         this.resetActionCountsForTasks(tasks[questIndex]);
         if(this.m_orderboardWindow)
         {
            this.m_orderboardWindow.refreshTaskFrame();
            this.m_orderboardWindow.refreshWindow();
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
               taskObj[this.KEY_TASK_ID] = tasks[i].id;
            }
            if(tasks[i].helperType == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
            {
               taskObj[this.KEY_ORDERBOARD_PROGRESS] = CraftingManager.getInstance().getBushelQuantityInInventory(tasks[i].type);
            }
            else
            {
               taskObj[this.KEY_ORDERBOARD_PROGRESS] = savedTasks[i][this.KEY_ORDERBOARD_PROGRESS];
            }
            tasksToSave.push(taskObj);
         }
         this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,tasksToSave as Object);
      }
      
      public function dumpTask(questIndex:int, callback:Function) : void
      {
         var dumpTimestamp:Object = null;
         if(this.canDumpTask(questIndex))
         {
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"dumpTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
            dumpTimestamp = this.getFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP) as Object;
            if(dumpTimestamp == null)
            {
               dumpTimestamp = new Object();
            }
            dumpTimestamp[questIndex] = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            this.saveFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP,dumpTimestamp);
            if(this.m_orderboardWindow)
            {
               this.m_orderboardWindow.refreshTaskFrame();
            }
         }
      }
      
      public function skipDumpedTask(questIndex:int, callback:Function) : void
      {
         var dumpTimestamp:Object = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         if(Global.player.canBuyCash(SKIP_COST))
         {
            Global.player.cash -= SKIP_COST;
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"skipDumpedTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
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
      
      public function sinkGold(questIndex:int, callback:Function) : void
      {
         var savedTasks:Array = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         if(Global.player.canBuy(tasks[questIndex].total))
         {
            Global.player.gold -= tasks[questIndex].total;
            savedTasks = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
            savedTasks[questIndex][this.KEY_ORDERBOARD_PROGRESS] = tasks[questIndex].total;
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,savedTasks);
            this.grantPointsForTask(tasks[questIndex].questPoints);
            this.postTaskCompletionActions(questIndex);
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"sinkGold",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
            StatsManager.count(m_featureName,"Coin Sink",questIndex.toString(),"",tasks[questIndex].total.toString(),this.getOrderboardProgress().toString());
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
         this.grantPointsForTask(tasks[questIndex].questPoints);
         this.postTaskCompletionActions(questIndex);
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"sinkBushel",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
         StatsManager.count(m_featureName,"Sink Bushel",questIndex.toString(),"",tasks[questIndex].total.toString(),this.getOrderboardProgress().toString());
      }
      
      public function postTaskCompletionActions(completedTaskSlotIndex:int) : void
      {
         var questTasks1:Vector.<FarmTask> = null;
         questTasks1 = this.getTasks();
         var tasks:Vector.<FarmTask> = this.getTasks();
         this.resetActionCountsForTasks(tasks[completedTaskSlotIndex]);
         if(this.m_orderboardWindow)
         {
            this.m_orderboardWindow.refreshTaskFrame();
            this.m_orderboardWindow.refreshWindow();
         }
      }
      
      public function getOrderboardProgress() : int
      {
         return this.getFeatureOptionsKey(this.KEY_ORDERBOARD_TASK_POINTS) as int;
      }
      
      protected function getFeatureOptionsKey(optionName:String) : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,optionName);
      }
      
      protected function saveFeatureOptionsKey(optionName:String, optionsValue:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,optionName,optionsValue);
      }
   }
}

