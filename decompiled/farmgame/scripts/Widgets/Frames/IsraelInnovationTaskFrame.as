package Widgets.Frames
{
   import Classes.Quest.FarmTask;
   import Managers.IsraelInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.IsraelInnovationTaskSlot;
   import Widgets.Windows.IsraelInnovationMainWindow;
   import flash.display.DisplayObject;
   
   public class IsraelInnovationTaskFrame extends FarmSlotContainerFrame
   {
      
      private var m_window:IsraelInnovationMainWindow;
      
      private var m_featureName:String;
      
      public function IsraelInnovationTaskFrame(element:DisplayObject, window:IsraelInnovationMainWindow, featureName:String)
      {
         this.m_window = window;
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new IsraelInnovationTaskSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override protected function setupData() : void
      {
         var completedTask:Boolean = false;
         var questTasks1:Vector.<FarmTask> = null;
         var progress:int = 0;
         m_slotData = [];
         questTasks1 = IsraelInnovationManager.getInstance(this.m_featureName).getActiveTasks();
         for(var i:int = 0; i < questTasks1.length; i++)
         {
            progress = IsraelInnovationManager.getInstance(this.m_featureName).getTaskProgress(i);
            completedTask = IsraelInnovationManager.getInstance().isTaskRedeemable(i);
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

