package Widgets.Frames
{
   import Classes.Quest.FarmTask;
   import Managers.WhitewinterInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.WhitewinterInnovationTaskSlot;
   import Widgets.Windows.WhitewinterInnovationWindow;
   import flash.display.DisplayObject;
   
   public class WhitewinterInnovationQuestTaskFrame extends FarmSlotContainerFrame
   {
      
      private var m_window:WhitewinterInnovationWindow;
      
      private var m_featureName:String;
      
      public function WhitewinterInnovationQuestTaskFrame(element:DisplayObject, window:WhitewinterInnovationWindow, featureName:String)
      {
         this.m_window = window;
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new WhitewinterInnovationTaskSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override protected function setupData() : void
      {
         var completedTask:Boolean = false;
         var questTasks1:Vector.<FarmTask> = null;
         var progress:int = 0;
         m_slotData = [];
         questTasks1 = WhitewinterInnovationManager.getInstance().getTasks();
         for(var i:int = 0; i < questTasks1.length; i++)
         {
            progress = WhitewinterInnovationManager.getInstance().getTaskProgress(i);
            completedTask = progress >= questTasks1[i].total;
            m_slotData.push({
               "taskSlotNumber":i,
               "task":questTasks1[i]
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

