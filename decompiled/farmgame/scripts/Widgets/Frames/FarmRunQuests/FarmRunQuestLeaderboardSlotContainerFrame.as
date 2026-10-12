package Widgets.Frames.FarmRunQuests
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.FarmRunQuests.FarmRunQuestLeaderboardSlot;
   import flash.display.DisplayObject;
   
   public class FarmRunQuestLeaderboardSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      public function FarmRunQuestLeaderboardSlotContainerFrame(element:DisplayObject)
      {
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FarmRunQuestLeaderboardSlot(slotElement);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function release() : void
      {
         super.release();
      }
      
      public function get numSlots() : int
      {
         return m_slots.length;
      }
      
      public function get items() : Array
      {
         return m_slotData;
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
      }
   }
}

