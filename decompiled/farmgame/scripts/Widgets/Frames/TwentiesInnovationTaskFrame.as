package Widgets.Frames
{
   import Classes.Quest.FarmTask;
   import Managers.TwentiesInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.TwentiesInnovationTaskSlot;
   import Widgets.Windows.TwentiesInnovationMainWindow;
   import flash.display.DisplayObject;
   
   public class TwentiesInnovationTaskFrame extends FarmSlotContainerFrame
   {
      
      private var m_window:TwentiesInnovationMainWindow;
      
      private var m_featureName:String;
      
      public function TwentiesInnovationTaskFrame(element:DisplayObject, window:TwentiesInnovationMainWindow, featureName:String)
      {
         this.m_window = window;
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new TwentiesInnovationTaskSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override protected function setupData() : void
      {
         var completedTask:Boolean = false;
         var questTasks1:Vector.<FarmTask> = null;
         var progress:int = 0;
         m_slotData = [];
         questTasks1 = TwentiesInnovationManager.getInstance(this.m_featureName).getActiveTasks();
         for(var i:int = 0; i < questTasks1.length; i++)
         {
            progress = TwentiesInnovationManager.getInstance(this.m_featureName).getTaskProgress(i);
            completedTask = TwentiesInnovationManager.getInstance().isTaskRedeemable(i);
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

