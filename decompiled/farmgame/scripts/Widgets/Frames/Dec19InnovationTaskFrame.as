package Widgets.Frames
{
   import Classes.Quest.FarmTask;
   import Managers.Dec19InnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.Dec19InnovationTaskSlot;
   import Widgets.Windows.Dec19InnovationMainWindow;
   import flash.display.DisplayObject;
   
   public class Dec19InnovationTaskFrame extends FarmSlotContainerFrame
   {
      
      private var m_window:Dec19InnovationMainWindow;
      
      private var m_featureName:String;
      
      public function Dec19InnovationTaskFrame(element:DisplayObject, window:Dec19InnovationMainWindow, featureName:String)
      {
         this.m_window = window;
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new Dec19InnovationTaskSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override protected function setupData() : void
      {
         var completedTask:Boolean = false;
         var questTasks1:Vector.<FarmTask> = null;
         var progress:int = 0;
         m_slotData = [];
         questTasks1 = Dec19InnovationManager.getInstance(this.m_featureName).getActiveTasks();
         for(var i:int = 0; i < questTasks1.length; i++)
         {
            progress = Dec19InnovationManager.getInstance(this.m_featureName).getTaskProgress(i);
            completedTask = Dec19InnovationManager.getInstance().isTaskRedeemable(i);
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

