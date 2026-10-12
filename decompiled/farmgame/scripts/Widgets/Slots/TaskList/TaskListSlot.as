package Widgets.Slots.TaskList
{
   import Classes.Constants.Experiments;
   import Classes.Mastery;
   import Classes.ZItem.HarvestableItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.TaskListManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.ProgressBars.FarmProgressBar;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.TaskListWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class TaskListSlot extends ZwSlotFrame
   {
      
      private static const SLOT_SIZE:Number = 75;
      
      private static const DISPLAY_COMPLETE_DELAY:Number = 500;
      
      protected var m_task:Object = null;
      
      protected var m_item:HarvestableItem = null;
      
      protected var m_slotTitle:ZwTextField;
      
      protected var m_slotDesc:ZwTextField;
      
      protected var m_delayTimer:Timer = null;
      
      protected var m_replaceTaskTimer:Timer = null;
      
      protected var m_icon:FarmIcon;
      
      protected var m_starsFrame:ZwFrame;
      
      protected var m_progressBar:FarmProgressBar;
      
      protected var m_actionButton:FarmAnimatedTextButton = null;
      
      protected var m_completeNowButton:FarmAnimatedTextButton = null;
      
      protected var m_completionCost:int;
      
      protected var m_completeNowCostText:ZwTextField;
      
      protected var m_finishedFrame:ZwFrame;
      
      protected var m_loadingFrame:ZwFrame;
      
      protected var m_finishedOkayButton:FarmAnimatedTextButton = null;
      
      protected var m_toolTip:FarmTextTooltip;
      
      protected var m_taskComplete:Boolean = false;
      
      protected var m_taskListWindow:TaskListWindow;
      
      private var m_noTaskFrame:ZwFrame;
      
      public function TaskListSlot(element:DisplayObject, mainWindow:TaskListWindow)
      {
         super(element);
         this.m_taskListWindow = mainWindow;
         this.m_slotTitle = new ZwTextField(m_element.sectionTitle_tf,"",true);
         addWidget(this.m_slotTitle);
         this.m_slotDesc = new ZwTextField(m_element.sectionDescription_tf,"",true);
         addWidget(this.m_slotDesc);
         this.m_icon = new FarmIcon(m_element.item_mc);
         this.m_icon.setIconSize(SLOT_SIZE,SLOT_SIZE);
         addWidget(this.m_icon);
         this.m_toolTip = new FarmTextTooltip();
         this.m_starsFrame = new ZwFrame(m_element.stars_mc);
         addWidget(this.m_starsFrame);
         this.m_progressBar = new FarmProgressBar(m_element.progressBar_mc);
         addWidget(this.m_progressBar);
         this.m_progressBar.attachTooltip(this.m_toolTip);
         this.m_starsFrame.attachTooltip(this.m_toolTip);
         this.m_actionButton = new FarmAnimatedTextButton(m_element.action_bt,"",this.onActionButtonClick);
         addWidget(this.m_actionButton);
         this.m_completeNowButton = new FarmAnimatedTextButton(m_element.completeNow_bt,ZLocUtils.t("Dialogs","TaskList_completeNow"),this.onCompleteNow);
         addWidget(this.m_completeNowButton);
         this.m_completeNowCostText = new ZwTextField(this.m_completeNowButton.element.farmCash_tf,"20",true);
         addWidget(this.m_completeNowCostText);
         this.m_finishedFrame = new ZwFrame(m_element.done_mc);
         addWidget(this.m_finishedFrame);
         this.m_finishedOkayButton = new FarmAnimatedTextButton(this.m_finishedFrame.element.okay_bt,ZLocUtils.t("Dialogs","TaskList_nextTask"),this.getNewTask);
         addWidget(this.m_finishedOkayButton);
         this.m_loadingFrame = new ZwFrame(m_element.loading_mc);
         addWidget(this.m_loadingFrame);
         this.m_noTaskFrame = new ZwFrame(m_element.none_mc);
         addWidget(this.m_noTaskFrame);
      }
      
      override public function populate(data:Object) : void
      {
         var mastery:Mastery = null;
         var harvestsRequired:Number = NaN;
         var iconUrl:String = null;
         var noTaskText:ZwTextField = null;
         this.m_task = data;
         if(!TaskListManager.getInstance().isEmptySlot(data))
         {
            this.m_item = Global.farmGameSettingsManager.getFarmItemByCode(data.code) as HarvestableItem;
            mastery = this.m_item.mastery;
            harvestsRequired = mastery.remainingCropsToNextLevel;
            if(mastery.currentLevel < int(data.level))
            {
               this.m_taskComplete = false;
               this.m_progressBar.progress = mastery.currentProgress / mastery.totalCropsNeeded * 100;
               this.m_toolTip.setText(ZLocUtils.t("Dialogs","MasteryProgress",{
                  "quantity":mastery.currentProgress,
                  "quantityTotal":mastery.totalCropsNeeded
               }));
               this.m_slotDesc.text = ZLocUtils.t("Dialogs","TaskList_taskText",{
                  "quantity":harvestsRequired.toString(),
                  "stars":(int(data.level) + 1).toString()
               });
            }
            else
            {
               this.m_taskComplete = true;
               harvestsRequired = 0;
               this.m_progressBar.progress = 100;
               this.m_slotDesc.text = ZLocUtils.t("Dialogs","TaskList_taskCompletedText",{"stars":(int(this.m_task.level) + 1).toString()});
            }
            this.m_slotDesc.visible = true;
            this.m_progressBar.visible = true;
            this.m_slotTitle.text = this.m_item.friendlyTitle;
            this.m_slotTitle.visible = true;
            iconUrl = this.m_item.masteryIconUrl();
            if(iconUrl == null)
            {
               iconUrl = this.m_item.icon;
            }
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_GILDAS_LIST_BITMAP_SMOOTHING) == 1)
            {
               this.m_icon.setSmoothing(true);
            }
            this.m_icon.loadIcon(iconUrl);
            this.m_icon.visible = true;
            (this.m_starsFrame.element as MovieClip).gotoAndStop(mastery.currentLevel + 2);
            this.m_starsFrame.visible = true;
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_GILDAS_LIST_ACTION_BUTTON) > 0)
            {
               this.m_actionButton.text = this.getActionButtonText();
               this.m_actionButton.visible = true;
            }
            this.m_completionCost = int(data.cost);
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_GILDAS_LIST_REMOVE_PAY_BUTTON) == 0)
            {
               this.m_completeNowButton.visible = true;
               this.m_completeNowCostText.text = this.m_completionCost.toString();
               this.m_completeNowCostText.visible = true;
               this.toggleButton(this.m_completeNowButton,true);
            }
            this.m_delayTimer = new Timer(DISPLAY_COMPLETE_DELAY * this.m_taskListWindow.numTasksCompleted,1);
            this.m_replaceTaskTimer = new Timer(TaskListManager.getInstance().getReplaceCompletedTaskDelay(),1);
            if(this.m_taskComplete)
            {
               this.displayTaskComplete();
            }
         }
         else
         {
            this.m_noTaskFrame.visible = true;
            noTaskText = addWidget(new ZwTextField(this.m_noTaskFrame.element.title_tf,ZLocUtils.t("Dialogs","TaskList_noTaskText")),true) as ZwTextField;
         }
      }
      
      private function displayTaskComplete() : void
      {
         FarmStatsManager.count(TaskListManager.STATS_COUNTER,"completed",this.m_task.type,this.m_task.code);
         this.m_actionButton.visible = false;
         this.m_completeNowButton.visible = false;
         this.toggleButton(this.m_completeNowButton,false);
         this.m_taskListWindow.numTasksCompleted += 1;
         this.m_delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onDelayDisplayTimeout);
         this.m_delayTimer.start();
      }
      
      private function onDelayDisplayTimeout(event:Event) : void
      {
         this.m_delayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onDelayDisplayTimeout);
         this.m_finishedFrame.visible = true;
         this.m_finishedOkayButton.visible = true;
         (this.m_finishedFrame.element as MovieClip).gotoAndPlay(2);
         if(TaskListManager.getInstance().shouldAutoReplaceCompletedTask())
         {
            this.m_replaceTaskTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.autoReplaceCompletedTask);
            this.m_replaceTaskTimer.start();
         }
      }
      
      private function autoReplaceCompletedTask(e:Event) : void
      {
         this.m_finishedOkayButton.visible = false;
         this.m_replaceTaskTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.autoReplaceCompletedTask);
         this.getNewTask(e);
      }
      
      private function getNewTask(event:Event) : void
      {
         this.m_replaceTaskTimer.stop();
         this.m_replaceTaskTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.autoReplaceCompletedTask);
         this.m_finishedFrame.visible = false;
         this.m_finishedOkayButton.visible = false;
         this.m_loadingFrame.visible = true;
         (this.m_loadingFrame.element as MovieClip).gotoAndPlay(1);
         var newTask:Object = TaskListManager.getInstance().replaceCurrentTask(this.m_task);
         var newTaskCode:String = null;
         if(newTask)
         {
            newTaskCode = newTask.code;
         }
         TransactionManager.addTransaction(new TGenericTransaction("TaskListService","replaceCompletedTask",this.onReplaceCompletedTaskTransactionComplete,[this.m_task.code,newTaskCode]),true);
         if(newTask)
         {
            this.populateNewTask(newTask);
         }
      }
      
      private function toggleButton(btn:FarmButton, enabled:Boolean) : void
      {
         btn.enabled = enabled;
         btn.applyGrayOut = !enabled;
      }
      
      private function populateNewTask(newTask:Object) : void
      {
         this.populate(newTask);
         this.m_completeNowButton.visible = true;
         this.toggleButton(this.m_completeNowButton,false);
         this.m_loadingFrame.visible = false;
         TaskListManager.getInstance().checkTasksProgress();
      }
      
      private function onCompleteNow(event:Event) : void
      {
         var confirmation:String = null;
         FarmStatsManager.count(TaskListManager.STATS_COUNTER,"complete_now_click",this.m_task.type,this.m_task.cost.toString());
         if(Global.player.cash >= int(this.m_task.cost))
         {
            this.m_taskListWindow.toggleCloseButton(false);
            this.toggleButton(this.m_completeNowButton,false);
            confirmation = ZLocUtils.t("Dialogs","TaskList_completeNowConfirmation",{
               "stars":(int(this.m_task.level) + 1).toString(),
               "item":this.m_item.friendlyTitle,
               "cost":this.m_task.cost.toString()
            });
            UI.displayMessage(confirmation,GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmCompleteNow,"TaskListCompleteNow",true,true,"TaskListCompleteNow");
         }
         else
         {
            UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyMarket",this.m_task.cost,TaskListManager.STATS_COUNTER);
            FarmStatsManager.count(TaskListManager.STATS_COUNTER,"complete_now_click","out_of_cash",this.m_task.type,this.m_task.cost.toString());
         }
      }
      
      private function onActionButtonClick(event:Event) : void
      {
         this.m_taskListWindow.close();
         switch(this.m_task.type)
         {
            case "seed":
               UI.displayMiniMarketDialog([this.m_item.name]);
         }
      }
      
      private function getActionButtonText() : String
      {
         var actionText:String = ZLocUtils.t("Dialogs","TaskList_gotoFarm");
         switch(this.m_task.type)
         {
            case "seed":
               actionText = ZLocUtils.t("Dialogs","TaskList_openMarket");
         }
         return actionText;
      }
      
      private function onConfirmCompleteNow(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            Global.player.cash -= int(this.m_task.cost);
            TransactionManager.addTransaction(new TGenericTransaction("TaskListService","completeNow",this.onCompleteNowTransactionComplete,[this.m_task.code]),true);
            this.m_loadingFrame.visible = true;
            (this.m_loadingFrame.element as MovieClip).gotoAndPlay(1);
         }
         else
         {
            this.m_taskListWindow.toggleCloseButton(true);
            this.toggleButton(this.m_completeNowButton,true);
         }
      }
      
      public function onCompleteNowTransactionComplete(result:Object) : void
      {
         this.m_taskListWindow.toggleCloseButton(true);
         if(result)
         {
            this.m_progressBar.progress = 100;
            (this.m_starsFrame.element as MovieClip).gotoAndStop(this.m_task.level + 2);
            this.m_loadingFrame.visible = false;
            this.m_slotDesc.text = ZLocUtils.t("Dialogs","TaskList_taskCompletedText",{"stars":(int(this.m_task.level) + 1).toString()});
            this.displayTaskComplete();
         }
         else
         {
            FarmStatsManager.count(TaskListManager.STATS_COUNTER,"error","complete_now_failed");
         }
      }
      
      public function onReplaceCompletedTaskTransactionComplete(result:Object) : void
      {
         if(result.newTask)
         {
            if(this.m_task.code != result.newTask.code)
            {
               this.populate(result.newTask);
               if(TaskListManager.getInstance().replaceTaskOnClient())
               {
                  FarmStatsManager.count(TaskListManager.STATS_COUNTER,"error","client_task_update_mismatch");
               }
            }
            this.toggleButton(this.m_completeNowButton,true);
         }
         else if(result.currentTasks)
         {
            this.m_taskListWindow.refreshSlots(result.currentTasks as Array);
            FarmStatsManager.count(TaskListManager.STATS_COUNTER,"error","replaceTaskMismatch","windowrefresh");
         }
         else
         {
            FarmStatsManager.count(TaskListManager.STATS_COUNTER,"error","no_available_task");
         }
         this.m_loadingFrame.visible = false;
      }
      
      override public function release() : void
      {
         super.release();
         this.m_slotTitle = null;
         this.m_slotDesc = null;
         this.m_icon = null;
         this.m_starsFrame = null;
         this.m_progressBar = null;
         this.m_taskListWindow = null;
         this.m_actionButton = null;
         this.m_completeNowButton = null;
         this.m_delayTimer = null;
         this.m_toolTip = null;
      }
   }
}

