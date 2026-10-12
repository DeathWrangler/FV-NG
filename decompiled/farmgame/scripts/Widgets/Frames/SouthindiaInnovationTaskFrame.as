package Widgets.Frames
{
   import Classes.Quest.FarmTask;
   import Managers.SouthindiaInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.SouthindiaInnovationTaskSlot;
   import Widgets.Windows.SouthindiaInnovationMainWindow;
   import flash.display.DisplayObject;
   
   public class SouthindiaInnovationTaskFrame extends FarmSlotContainerFrame
   {
      
      private var m_window:SouthindiaInnovationMainWindow;
      
      private var m_featureName:String;
      
      public function SouthindiaInnovationTaskFrame(element:DisplayObject, window:SouthindiaInnovationMainWindow, featureName:String)
      {
         this.m_window = window;
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new SouthindiaInnovationTaskSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override protected function setupData() : void
      {
         var completedTask:Boolean = false;
         var questTasks1:Vector.<FarmTask> = null;
         var progress:int = 0;
         m_slotData = [];
         questTasks1 = SouthindiaInnovationManager.getInstance(this.m_featureName).getActiveTasks();
         for(var i:int = 0; i < questTasks1.length; i++)
         {
            progress = SouthindiaInnovationManager.getInstance(this.m_featureName).getTaskProgress(i);
            completedTask = SouthindiaInnovationManager.getInstance().isTaskRedeemable(i);
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

