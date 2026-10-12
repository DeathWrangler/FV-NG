package Widgets.Frames
{
   import Classes.Quest.FarmQuest;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.ThemedQuest.ThemedQuestPieceSlot;
   import Widgets.Windows.ThemedQuestWindow;
   import flash.display.DisplayObject;
   
   public class ThemedQuestPieceSlotFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "piece";
      
      protected static const SLOT_POSTFIX:String = "";
      
      private var m_window:ThemedQuestWindow;
      
      public function ThemedQuestPieceSlotFrame(element:DisplayObject, window:ThemedQuestWindow)
      {
         this.m_window = window;
         m_slotData = [];
         super(element);
      }
      
      public function get parentWindow() : ThemedQuestWindow
      {
         return this.m_window;
      }
      
      public function setQuest(farmQuest:FarmQuest) : void
      {
         m_slotData = [];
         for(var i:int = 0; i < farmQuest.farmTasks.length; i++)
         {
            m_slotData[m_slotData.length] = {
               "quest":farmQuest,
               "index":i
            };
         }
         refresh();
      }
      
      override protected function createSlot(element:DisplayObject) : ZwSlotFrame
      {
         return new ThemedQuestPieceSlot(element,this.m_window);
      }
      
      override protected function setupData() : void
      {
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
   }
}

