package Widgets.Frames
{
   import Classes.Quest.FarmTask;
   import Managers.OrderBoard.CarribeanInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.CarribeanInnovationTaskSlot;
   import Widgets.Windows.CarribeanInnovationWindow;
   import flash.display.DisplayObject;
   
   public class CarribeanInnovationTaskFrame extends FarmSlotContainerFrame
   {
      
      private var m_window:CarribeanInnovationWindow;
      
      private var m_featureName:String;
      
      public function CarribeanInnovationTaskFrame(element:DisplayObject, window:CarribeanInnovationWindow, featureName:String)
      {
         this.m_window = window;
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CarribeanInnovationTaskSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override protected function setupData() : void
      {
         var completedTask:Boolean = false;
         var questTasks1:Vector.<FarmTask> = null;
         var progress:int = 0;
         m_slotData = [];
         questTasks1 = CarribeanInnovationManager.getInstance(this.m_featureName).getTasks();
         for(var i:int = 0; i < questTasks1.length; i++)
         {
            CarribeanInnovationManager.getInstance(this.m_featureName).saveBushelProgress();
            progress = CarribeanInnovationManager.getInstance(this.m_featureName).getTaskProgress(i);
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
               "completed":completedTask
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

