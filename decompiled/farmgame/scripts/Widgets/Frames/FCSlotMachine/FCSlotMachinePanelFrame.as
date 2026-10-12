package Widgets.Frames.FCSlotMachine
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.LESlotMachine.LESlotMachinePanelFrame;
   import Widgets.Slots.FCSlotMachine.FCSlotMachineItemPanel;
   import flash.display.DisplayObject;
   
   public final class FCSlotMachinePanelFrame extends LESlotMachinePanelFrame
   {
      
      public function FCSlotMachinePanelFrame(element:DisplayObject)
      {
         super(element);
      }
      
      override public function updateData(slotItems:Array) : void
      {
         m_items = slotItems;
         setupData();
         if(m_slots[WINNING_SLOT_INDEX] != null && m_slots[WINNING_SLOT_INDEX] is FCSlotMachineItemPanel)
         {
            (m_slots[WINNING_SLOT_INDEX] as FCSlotMachineItemPanel).AnimatedSlot = true;
         }
         this.refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FCSlotMachineItemPanel(slotElement);
      }
   }
}

