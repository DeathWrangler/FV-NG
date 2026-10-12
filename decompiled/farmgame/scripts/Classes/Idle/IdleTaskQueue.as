package Classes.Idle
{
   import Classes.Idle.Quest.NewIndicatorIdleTask;
   import Display.UI;
   import Managers.ActionDrivenManager;
   import Managers.ReturningUserExperienceManager;
   import flash.utils.getQualifiedClassName;
   
   public class IdleTaskQueue
   {
      
      private static var m_Instance:IdleTaskQueue;
      
      private static const UPDATE_INTERVAL:Number = 1000;
      
      private var m_Queue:Array = new Array();
      
      private var m_LastTaskExecuted:Number = 0;
      
      private var m_PopupQueueEmpty:Boolean = false;
      
      private var m_PopupQueueEmptySince:Number = 0;
      
      private var m_ActionQueueEmpty:Boolean = false;
      
      private var m_ActionQueueEmptySince:Number = 0;
      
      private var m_nextUpdateTime:Number = 0;
      
      private var m_queuePaused:Boolean = false;
      
      private var m_blockIdleTasks:Boolean = false;
      
      public function IdleTaskQueue()
      {
         super();
      }
      
      public static function getInstance() : IdleTaskQueue
      {
         if(m_Instance == null)
         {
            m_Instance = new IdleTaskQueue();
         }
         return m_Instance;
      }
      
      public function addTask(task:BaseIdleTask) : void
      {
         var taskClassName:String = null;
         var i:int = 0;
         var existingTask:BaseIdleTask = null;
         var shouldAdd:Boolean = Boolean(task) && task.shouldAdd;
         if(shouldAdd && task.singleton)
         {
            taskClassName = getQualifiedClassName(task);
            if(!task.canHaveDuplicates)
            {
               for(i = 0; i < this.m_Queue.length; i++)
               {
                  existingTask = this.m_Queue[i];
                  if(getQualifiedClassName(existingTask) == taskClassName)
                  {
                     if(task.singletonClobber)
                     {
                        this.m_Queue.splice(i,1);
                        shouldAdd = true;
                     }
                     else
                     {
                        shouldAdd = false;
                     }
                     break;
                  }
               }
            }
         }
         if(shouldAdd)
         {
            task.timeAdded = GlobalEngine.currentTime;
            this.m_Queue.push(task);
         }
      }
      
      public function blockIdleTasks() : void
      {
         this.m_blockIdleTasks = true;
      }
      
      public function unblockIdleTasks() : void
      {
         this.m_blockIdleTasks = false;
      }
      
      public function checkTasks() : void
      {
         var execTask:BaseIdleTask = null;
         var i:int = 0;
         var task:BaseIdleTask = null;
         if(GlobalEngine.currentTime > this.m_nextUpdateTime && !this.m_queuePaused)
         {
            this.m_nextUpdateTime = GlobalEngine.currentTime + IdleTaskQueue.UPDATE_INTERVAL;
            this.checkTimeStamps();
            if(this.m_Queue.length > 0)
            {
               for(i = 0; i < this.m_Queue.length; i++)
               {
                  task = this.m_Queue[i];
                  if(this.checkIfTaskCanRun(task))
                  {
                     execTask = task;
                     this.m_Queue.splice(i,1);
                     break;
                  }
               }
               if(execTask != null && !this.m_blockIdleTasks)
               {
                  this.m_LastTaskExecuted = GlobalEngine.currentTime;
                  execTask.fire();
               }
            }
         }
      }
      
      private function checkIfTaskCanRun(task:BaseIdleTask) : Boolean
      {
         var now:Number = GlobalEngine.currentTime;
         var result:Boolean = true;
         if(task.requireActionQueueIdle)
         {
            if(!this.m_ActionQueueEmpty || now - this.m_ActionQueueEmptySince < task.minActionIdleMilliseconds)
            {
               result = false;
            }
         }
         if(result && task.requireMouseIdle)
         {
            if(now - Global.lastInputTick < task.minMouseIdleMilliseconds)
            {
               result = false;
            }
         }
         if(result && task.requirePopupQueueEmpty)
         {
            if(!this.m_PopupQueueEmpty || now - this.m_PopupQueueEmptySince < task.minPopupIdleMilliseconds)
            {
               result = false;
            }
         }
         if(result && now - this.m_LastTaskExecuted < task.queueCoolDownMilliseconds)
         {
            result = false;
         }
         if(result && !task.canFire)
         {
            result = false;
         }
         return result;
      }
      
      private function checkTimeStamps() : void
      {
         if(UI.numberOfPopupsInQueue == 0 && !UI.isShowingPopup())
         {
            if(!this.m_PopupQueueEmpty)
            {
               this.m_PopupQueueEmptySince = GlobalEngine.currentTime;
            }
            this.m_PopupQueueEmpty = true;
         }
         else
         {
            this.m_PopupQueueEmpty = false;
         }
         if(Global.player != null && Global.player.avatar != null && Global.player.avatar.getStateMachine().getStates().length == 0)
         {
            if(!this.m_ActionQueueEmpty)
            {
               this.m_ActionQueueEmptySince = GlobalEngine.currentTime;
            }
            this.m_ActionQueueEmpty = true;
         }
         else
         {
            this.m_ActionQueueEmpty = false;
         }
      }
      
      public function togglePause(value:Boolean) : void
      {
         this.m_queuePaused = value;
      }
      
      public function clearQueue() : void
      {
         this.m_Queue = new Array();
      }
      
      public function addIdleTasksOnEnterWorld() : void
      {
         this.addTask(new InterstitialVideoAdIdleTask());
         this.addTask(new LonelyAnimalIdleTask());
         this.addTask(new AdIdleTask());
         this.addTask(new W2EIdleTask());
         this.addTask(new DragonBreedingTask());
         this.addTask(new PromoIdleTask());
         this.addTask(new WanderingAnimalTask());
         this.addTask(new ClickTrackingIdleTask());
         this.addTask(new CollectionsIdleTask());
         this.addTask(new ConsumableBundleIdleTask());
         if(Global.player.postInitFinished || !ReturningUserExperienceManager.isInExperiment())
         {
            this.addTask(new MarketIndicatorIdleTask());
            this.addTask(new NewIndicatorIdleTask());
         }
         this.addTask(new AvatarFeedIdleTask());
         this.addTask(new PaidGiftingIdleTask());
         ActionDrivenManager.conditionallyAddToasterIdleTasks();
      }
      
      public function addVisitIdleTasks() : void
      {
         this.addTask(new MutualFriendsTask());
         this.addTask(new AvatarFeedIdleTask());
      }
   }
}

