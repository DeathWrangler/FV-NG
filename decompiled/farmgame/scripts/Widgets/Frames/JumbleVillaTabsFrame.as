package Widgets.Frames
{
   import Managers.JumbleVillaManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.JumbleVillaTabSlot;
   import flash.display.DisplayObject;
   
   public class JumbleVillaTabsFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "tab";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      protected var m_featureName:String = "JumbleVilla";
      
      private var m_clicked_puzzle_id:int = -1;
      
      public function JumbleVillaTabsFrame(element:DisplayObject)
      {
         super(element);
         element.visible = true;
         this.m_clicked_puzzle_id = this.manager.getActivePuzzleId();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new JumbleVillaTabSlot(slotElement);
      }
      
      override protected function setupData() : void
      {
         m_slotData = [];
         if(this.clickedPuzzleId == -1)
         {
            this.clickedPuzzleId = this.manager.getActivePuzzleId();
         }
         for(var i:int = 0; i < m_slots.length; i++)
         {
            m_slotData.push({
               "id":i,
               "locked":i > this.activePuzzleId,
               "completed":i < this.activePuzzleId || i == this.activePuzzleId && this.manager.isActivePuzzleCompleted(),
               "clicked":i == this.clickedPuzzleId,
               "focus":i == this.activePuzzleId && !this.manager.isActivePuzzleCompleted()
            });
         }
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      private function get manager() : JumbleVillaManager
      {
         return JumbleVillaManager.getInstance(this.m_featureName);
      }
      
      private function get activePuzzleId() : int
      {
         return this.manager.getActivePuzzleId();
      }
      
      private function get clickedPuzzleId() : int
      {
         return this.m_clicked_puzzle_id;
      }
      
      private function set clickedPuzzleId(id:int) : void
      {
         this.m_clicked_puzzle_id = id;
      }
      
      public function refreshTabs(clickedTab:int) : void
      {
         this.clickedPuzzleId = clickedTab;
         this.setupData();
         refresh();
      }
   }
}

