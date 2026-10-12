package Widgets.Frames
{
   import Classes.Quest.FarmTask;
   import Managers.OrderBoard.FarmRunV5Manager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.FarmRunV5OrderboardSlot;
   import Widgets.Windows.FarmRunV5OrderBoardWindow;
   import Widgets.Windows.GenericOrderBoardWindow;
   import flash.display.DisplayObject;
   
   public class FarmRunV5OrderboardFrame extends FarmSlotContainerFrame
   {
      
      private var m_window:FarmRunV5OrderBoardWindow;
      
      private var m_owner:GenericOrderBoardWindow;
      
      private var managerObject:FarmRunV5Manager;
      
      private var m_featureName:String;
      
      public function FarmRunV5OrderboardFrame(element:DisplayObject, window:FarmRunV5OrderBoardWindow, featureName:String, manager:FarmRunV5Manager)
      {
         this.m_window = window;
         this.m_featureName = featureName;
         this.managerObject = manager;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FarmRunV5OrderboardSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override protected function setupData() : void
      {
         var completedTask:Boolean = false;
         var questTasks1:Vector.<FarmTask> = null;
         var progress:int = 0;
         m_slotData = [];
         var completedTasksArray:Array = this.managerObject.getCompletedTaskSlots();
         questTasks1 = this.managerObject.getTasks();
         for(var i:int = 0; i < questTasks1.length; i++)
         {
            this.managerObject.saveBushelProgress();
            progress = this.managerObject.getTaskProgress(i);
            completedTask = progress >= questTasks1[i].total;
            m_slotData.push({
               "questTaskSlotNumber":i,
               "questTask":questTasks1[i],
               "questType":questTasks1[i].action,
               "questText":questTasks1[i].titleText,
               "helperText":questTasks1[i].helperText,
               "taskType":questTasks1[i].helperType,
               "skipCashValue":questTasks1[i].skipCashValue,
               "progress":progress,
               "completed":completedTask,
               "isTaskComplete":completedTasksArray[i]
            });
         }
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
   }
}

