package Widgets.Frames.FCSlotMachine
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.FCSlotMachine.FCSlotMachinePrizeSlot;
   import Widgets.Windows.FCSlotMachineWindow;
   import flash.display.DisplayObject;
   
   public class FCSlotMachinePrizeFrame extends FarmSlotContainerFrame
   {
      
      private var m_slotPrefix:String = "p";
      
      private var m_parentWindow:FCSlotMachineWindow;
      
      private var m_prizes:Array;
      
      public function FCSlotMachinePrizeFrame(element:DisplayObject, prizes:Array, parentWindow:FCSlotMachineWindow)
      {
         this.m_parentWindow = parentWindow;
         this.m_prizes = prizes;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FCSlotMachinePrizeSlot(slotElement,this.m_parentWindow);
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_prizes;
      }
      
      override protected function getSlotPrefix() : String
      {
         return this.m_slotPrefix;
      }
   }
}

