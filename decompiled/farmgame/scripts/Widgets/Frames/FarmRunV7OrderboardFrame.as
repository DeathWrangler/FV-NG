package Widgets.Frames
{
   import Classes.Quest.FarmTask;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.FarmRunV7OrderboardSlot;
   import Widgets.Windows.FarmRunV7OrderBoardWindow;
   import flash.display.DisplayObject;
   
   public class FarmRunV7OrderboardFrame extends FarmSlotContainerFrame
   {
      
      private var m_window:FarmRunV7OrderBoardWindow;
      
      private var managerObject:Object;
      
      private var m_featureName:String;
      
      public function FarmRunV7OrderboardFrame(element:DisplayObject, window:FarmRunV7OrderBoardWindow, featureName:String, managerObjectc:Object)
      {
         this.m_window = window;
         this.m_featureName = featureName;
         this.managerObject = managerObjectc;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FarmRunV7OrderboardSlot(this.m_featureName,slotElement,this.m_window);
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
            progress = int(this.managerObject.getTaskProgress(i));
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

