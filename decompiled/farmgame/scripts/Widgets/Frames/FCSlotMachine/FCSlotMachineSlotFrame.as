package Widgets.Frames.FCSlotMachine
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.LESlotMachine.LESlotMachineSlotFrame;
   import Widgets.Slots.FCSlotMachine.FCSlotMachineItemSlot;
   import flash.display.DisplayObject;
   
   public final class FCSlotMachineSlotFrame extends LESlotMachineSlotFrame
   {
      
      public function FCSlotMachineSlotFrame(element:DisplayObject, prizes:Array)
      {
         super(element,prizes);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FCSlotMachineItemSlot(slotElement);
      }
      
      public function setMatchField(matchField:Array) : void
      {
         for(var i:int = 0; i < matchField.length; i++)
         {
            m_slots[i].toggleMatchField(matchField[i]);
         }
      }
      
      override protected function slotStopSpinGap(slotNum:int) : int
      {
         var delay:int = 100;
         var gap:int = 500;
         switch(slotNum)
         {
            case 0:
               break;
            case 1:
               delay += slotNum * gap;
               break;
            case 2:
               delay += slotNum * gap;
         }
         return delay;
      }
   }
}

