package Widgets.Frames.LESlotMachine
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.LESlotMachine.LESlotMachineDiscountPanel;
   import Widgets.Slots.LESlotMachine.LESlotMachineItemPanel;
   import flash.display.DisplayObject;
   
   public class LESlotMachinePanelFrame extends FarmSlotContainerFrame
   {
      
      private var m_slotPrefix:String = "icon_";
      
      private var m_slotSuffix:String = "_mc";
      
      private var m_discountSlotType:Boolean = false;
      
      public const WINNING_SLOT_INDEX:int = 5;
      
      protected var m_items:Array = [];
      
      public function LESlotMachinePanelFrame(element:DisplayObject, discountSlots:Boolean = false)
      {
         this.m_discountSlotType = discountSlots;
         super(element);
      }
      
      public function updateData(slotItems:Array) : void
      {
         this.m_items = slotItems;
         this.setupData();
         if(m_slots[this.WINNING_SLOT_INDEX] != null && m_slots[this.WINNING_SLOT_INDEX] is LESlotMachineItemPanel)
         {
            (m_slots[this.WINNING_SLOT_INDEX] as LESlotMachineItemPanel).AnimatedSlot = true;
         }
         this.refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         if(this.m_discountSlotType == true)
         {
            return new LESlotMachineDiscountPanel(slotElement);
         }
         return new LESlotMachineItemPanel(slotElement);
      }
      
      override protected function getSlotPrefix() : String
      {
         if(this.m_discountSlotType)
         {
            return "discount_";
         }
         return this.m_slotPrefix;
      }
      
      override protected function getSlotPostfix() : String
      {
         if(this.m_discountSlotType)
         {
            return "_mc";
         }
         return this.m_slotSuffix;
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_items;
      }
   }
}

