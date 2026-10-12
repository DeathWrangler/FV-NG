package Widgets.Frames.TaskList
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.TaskList.TaskListSlot;
   import Widgets.Windows.TaskListWindow;
   import flash.display.DisplayObject;
   
   public class TaskListSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_mainWindow:TaskListWindow;
      
      private var m_tasks:Array;
      
      public function TaskListSlotFrame(element:DisplayObject, tasks:Array, mainWindow:TaskListWindow)
      {
         this.m_mainWindow = mainWindow;
         this.m_tasks = tasks;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new TaskListSlot(slotElement,this.m_mainWindow);
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_tasks;
      }
      
      public function refreshSlots(slotData:Array) : void
      {
         m_slotData = slotData;
         refresh();
      }
   }
}

