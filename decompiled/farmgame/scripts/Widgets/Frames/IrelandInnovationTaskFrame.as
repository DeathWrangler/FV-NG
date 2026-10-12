package Widgets.Frames
{
   import Classes.Quest.FarmTask;
   import Managers.OrderBoard.IrelandInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.IrelandInnovationTaskSlot;
   import Widgets.Windows.IrelandInnovationMainWindow;
   import flash.display.DisplayObject;
   
   public class IrelandInnovationTaskFrame extends FarmSlotContainerFrame
   {
      
      private var m_window:IrelandInnovationMainWindow;
      
      private var m_featureName:String;
      
      public function IrelandInnovationTaskFrame(element:DisplayObject, window:IrelandInnovationMainWindow, featureName:String)
      {
         this.m_window = window;
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new IrelandInnovationTaskSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override protected function setupData() : void
      {
         var completedTask:Boolean = false;
         var questTasks1:Vector.<FarmTask> = null;
         m_slotData = [];
         questTasks1 = IrelandInnovationManager.getInstance(this.m_featureName).getTasks();
         var i:int = this.manager.getFeatureOptionsKey(this.manager.KEY_SELECTED_PIN) as int;
         IrelandInnovationManager.getInstance(this.m_featureName).saveBushelProgress();
         var progress:int = IrelandInnovationManager.getInstance(this.m_featureName).getTaskProgress(i);
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
      
      private function get manager() : IrelandInnovationManager
      {
         return IrelandInnovationManager.getInstance("IrelandInnovation");
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
   }
}

