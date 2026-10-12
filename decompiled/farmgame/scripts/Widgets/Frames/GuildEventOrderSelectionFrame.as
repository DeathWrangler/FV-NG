package Widgets.Frames
{
   import Classes.Quest.FarmTask;
   import Managers.GuildEventManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.GuildEventOrderSelectionSlot;
   import Widgets.Windows.GuildEventOrderSelectionWindow;
   import flash.display.DisplayObject;
   
   public class GuildEventOrderSelectionFrame extends FarmSlotContainerFrame
   {
      
      private var m_window:GuildEventOrderSelectionWindow;
      
      private var m_featureName:String;
      
      public var m_reqSlotNumber:int;
      
      public function GuildEventOrderSelectionFrame(element:DisplayObject, window:GuildEventOrderSelectionWindow, featureName:String, reqSlotNumber:int)
      {
         this.m_window = window;
         this.m_featureName = featureName;
         this.m_reqSlotNumber = reqSlotNumber;
         super(element);
         this.eventManager.fillOrder();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new GuildEventOrderSelectionSlot(this.m_featureName,slotElement,this.m_window,this.m_reqSlotNumber);
      }
      
      override protected function setupData() : void
      {
         var completedTask:Boolean = false;
         var questTasks1:Vector.<FarmTask> = null;
         m_slotData = [];
         questTasks1 = GuildEventManager.getInstance(this.m_featureName).getActiveTasksForGuild();
         for(var i:int = 0; i < questTasks1.length; i++)
         {
            m_slotData.push({
               "questTaskSlotNumber":i,
               "questTask":questTasks1[i],
               "questType":questTasks1[i].action,
               "questText":questTasks1[i].titleText,
               "helperText":questTasks1[i].helperText,
               "taskType":questTasks1[i].helperType,
               "skipCashValue":questTasks1[i].skipCashValue
            });
         }
      }
      
      private function get eventManager() : GuildEventManager
      {
         return GuildEventManager.getInstance();
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
   }
}

