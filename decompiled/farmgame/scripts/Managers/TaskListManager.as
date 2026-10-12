package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Mastery;
   import Classes.ZItem.HarvestableItem;
   import Display.QueuedIcons.TaskListQueuedIcon;
   import Display.UI;
   import Events.FarmGameWorldEvent;
   import Widgets.Windows.TaskListWindow;
   import flash.events.Event;
   
   public class TaskListManager
   {
      
      private static var m_objInstance:TaskListManager;
      
      public static const STATS_COUNTER:String = "gildas_list";
      
      private static const MIN_PLAYER_LEVEL:int = 15;
      
      private static const DEFAULT_DELAY_COMPLETED_TASK_REMOVAL:int = 5000;
      
      private static const RUNTIME_COMPLETED_TASK_REMOVAL_DELAY:String = "TASKLIST_REMOVAL_DELAY";
      
      private var m_numTasks:int;
      
      private var m_taskTypes:Array;
      
      private var m_currentTasks:Array;
      
      private var m_availableTasks:Object;
      
      private var m_numCompletedTasks:int = 0;
      
      private var m_masterExperimentVariant:int = 0;
      
      private var m_clientTaskReplaceExpVariant:int = 0;
      
      private var m_completedTaskRemovalDelay:int = 0;
      
      private var m_shouldAutoReplaceCompletedTask:Boolean = false;
      
      private var m_taskListWindowOpen:Boolean = false;
      
      public function TaskListManager(objEnforcer:SingletonEnforcer)
      {
         var delay:int = 0;
         super();
         this.m_masterExperimentVariant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_GILDAS_LIST);
         this.m_clientTaskReplaceExpVariant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_GILDAS_LIST_CLIENT_TASK_UPDATES);
         if(this.isEnabled())
         {
            this.loadTaskListSettings();
            this.getTasksFromFeatureOptions();
            FeatureOptionsManager.getInstance().addEventListener(FeatureOptionsManager.EVENT_FEATURE_OPTIONS_UPDATED,this.updateTaskLists);
            Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.postInitChecks);
            delay = Global.flashHotParams[RUNTIME_COMPLETED_TASK_REMOVAL_DELAY] as Number;
            if(isNaN(delay))
            {
               delay = DEFAULT_DELAY_COMPLETED_TASK_REMOVAL;
            }
            this.m_completedTaskRemovalDelay = delay;
            this.m_shouldAutoReplaceCompletedTask = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_GILDAS_LIST_AUTOREMOVE_COMPLETED_TASK) == 1;
         }
      }
      
      public static function getInstance() : TaskListManager
      {
         if(m_objInstance == null)
         {
            m_objInstance = new TaskListManager(new SingletonEnforcer());
         }
         return m_objInstance;
      }
      
      public function openTaskListWindow() : void
      {
         if(this.windowOpen)
         {
            FarmStatsManager.count(STATS_COUNTER,"error","duplicate_window");
         }
         else
         {
            UI.displayPopup(new TaskListWindow(),true,TaskListWindow.WINDOW_NAME,true);
         }
      }
      
      public function getCurrentTasks() : Array
      {
         var tasks:Array = null;
         var task:Object = null;
         var currentCount:int = 0;
         var i:int = 0;
         if(!this.m_currentTasks || this.m_currentTasks.length < this.m_numTasks)
         {
            tasks = new Array();
            for each(task in this.m_currentTasks)
            {
               if(task)
               {
                  tasks.push(task);
               }
            }
            currentCount = 0;
            if(this.m_currentTasks)
            {
               currentCount = int(this.m_currentTasks.length);
            }
            FarmStatsManager.count(STATS_COUNTER,"tasks_loaded",currentCount.toString(),this.m_numTasks.toString());
            for(i = currentCount; i < this.m_numTasks; i++)
            {
               tasks.push(this.createEmptySlotTask());
            }
            this.m_currentTasks = tasks;
         }
         return this.m_currentTasks;
      }
      
      public function isEmptySlot(task:Object) : Boolean
      {
         return task.hasOwnProperty("emptySlot");
      }
      
      private function createEmptySlotTask() : Object
      {
         return {"emptySlot":true};
      }
      
      public function updateTaskLists(e:Event) : void
      {
         this.getTasksFromFeatureOptions();
         this.checkTasksProgress();
      }
      
      public function getTasksFromFeatureOptions() : void
      {
         this.m_currentTasks = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.TASK_LIST,FeatureOptionsManager.TASKLIST_CURRENT_TASKS) as Array;
         this.m_availableTasks = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.TASK_LIST,FeatureOptionsManager.TASKLIST_AVAILABLE_TASKS);
      }
      
      public function set windowOpen(open:Boolean) : void
      {
         this.m_taskListWindowOpen = open;
      }
      
      public function get windowOpen() : Boolean
      {
         return this.m_taskListWindowOpen;
      }
      
      private function loadTaskListSettings() : void
      {
         var taskType:XML = null;
         var taskName:String = null;
         var cost:int = 0;
         var sortOrder:int = 0;
         var xml:XML = Global.farmGameSettingsManager.getXML();
         var settings:XML = xml.taskList[0];
         this.m_numTasks = int(settings.child("numTasks")[0].text()[0]);
         var taskTypesXML:XMLList = settings.child("taskTypes")[0].children();
         this.m_taskTypes = new Array();
         for each(taskType in taskTypesXML)
         {
            taskName = taskType.name();
            cost = int(taskType.child("cost")[0].text()[0]);
            sortOrder = int(taskType.child("sortOrder")[0].text()[0]);
            this.m_taskTypes.push({
               "type":taskName,
               "cost":cost,
               "sortOrder":sortOrder
            });
         }
         this.m_taskTypes.sortOn("sortOrder",Array.NUMERIC);
      }
      
      private function removeTask(task:Object) : void
      {
         var currentTask:Object = null;
         var newTasks:Array = new Array();
         for each(currentTask in this.m_currentTasks)
         {
            if(currentTask.code != task.code)
            {
               newTasks.push(currentTask);
            }
         }
         this.m_currentTasks = newTasks;
      }
      
      public function replaceCurrentTask(task:Object) : Object
      {
         var taskTypeCounts:Array = null;
         var taskType:Object = null;
         var currentTask:Object = null;
         var taskTypeCount:Object = null;
         var tasks:Array = null;
         var newTask:Object = null;
         if(this.replaceTaskOnClient())
         {
            this.removeTask(task);
            taskTypeCounts = new Array();
            for each(taskType in this.m_taskTypes)
            {
               taskTypeCounts.push({
                  "type":taskType.type,
                  "sortOrder":taskType.sortOrder,
                  "count":0
               });
            }
            for each(currentTask in this.m_currentTasks)
            {
               for each(taskTypeCount in taskTypeCounts)
               {
                  if(taskTypeCount.type == currentTask.type)
                  {
                     taskTypeCount.count += 1;
                     break;
                  }
               }
            }
            taskTypeCounts.sortOn(["count","sortOrder"]);
            for each(taskType in taskTypeCounts)
            {
               if(this.m_availableTasks.hasOwnProperty(taskType.type))
               {
                  tasks = this.m_availableTasks[taskType.type];
                  if(tasks.length > 0)
                  {
                     newTask = tasks.shift();
                     this.m_currentTasks.push(newTask);
                     break;
                  }
               }
            }
            FarmStatsManager.count(STATS_COUNTER,"replace_task","client",this.m_currentTasks.length.toString());
         }
         return newTask;
      }
      
      public function checkTasksProgress() : void
      {
         var numCompletedTasks:int = 0;
         var task:Object = null;
         var item:HarvestableItem = null;
         var mastery:Mastery = null;
         if(this.isEnabled() && Global.player.postInitFinished)
         {
            numCompletedTasks = 0;
            for each(task in this.m_currentTasks)
            {
               if(!this.isEmptySlot(task))
               {
                  item = Global.farmGameSettingsManager.getFarmItemByCode(task.code) as HarvestableItem;
                  mastery = item.mastery;
                  if(mastery.currentLevel >= int(task.level))
                  {
                     numCompletedTasks += 1;
                  }
               }
            }
            if(numCompletedTasks > this.m_numCompletedTasks)
            {
               TaskListQueuedIcon.showCompletionAnimation();
               if(this.isAutoPopEnabled())
               {
                  this.openTaskListWindow();
               }
               FarmStatsManager.count(STATS_COUNTER,"tasks_completed_display",numCompletedTasks.toString());
            }
            else if(numCompletedTasks == 0)
            {
               TaskListQueuedIcon.hideCompletionAnimation();
            }
            this.m_numCompletedTasks = numCompletedTasks;
         }
      }
      
      public function postInitChecks(e:Event) : void
      {
         Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.postInitChecks);
         this.checkTasksProgress();
      }
      
      public function showHUDIcon() : void
      {
         if(this.isEnabled())
         {
            TaskListQueuedIcon.showHUDIcon();
         }
      }
      
      public function isEnabled() : Boolean
      {
         return Global.player.level > MIN_PLAYER_LEVEL && this.m_masterExperimentVariant > 1;
      }
      
      private function isAutoPopEnabled() : Boolean
      {
         return this.m_masterExperimentVariant == 2;
      }
      
      public function replaceTaskOnClient() : Boolean
      {
         return this.m_clientTaskReplaceExpVariant == 1;
      }
      
      public function getReplaceCompletedTaskDelay() : int
      {
         return this.m_completedTaskRemovalDelay;
      }
      
      public function shouldAutoReplaceCompletedTask() : Boolean
      {
         return this.m_shouldAutoReplaceCompletedTask;
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
