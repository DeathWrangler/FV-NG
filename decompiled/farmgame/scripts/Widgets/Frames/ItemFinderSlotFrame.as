package Widgets.Frames
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.ItemFinderSlot;
   import flash.display.DisplayObject;
   
   public class ItemFinderSlotFrame extends FarmSlotContainerFrame
   {
      
      private static const SLOTS_PER_PAGE:uint = 3;
      
      protected var m_contents:Array = new Array();
      
      public function ItemFinderSlotFrame(element:DisplayObject, contents:Array)
      {
         this.m_contents = contents;
         super(element);
      }
      
      override protected function setupSlots() : void
      {
         var slot:ZwSlotFrame = null;
         var slotIndex:int = 0;
         while(m_element[getSlotPrefix() + slotIndex + getSlotPostfix()])
         {
            slot = this.createSlot(m_element[getSlotPrefix() + slotIndex + getSlotPostfix()]);
            addWidget(slot,false);
            m_slots.push(slot);
            slotIndex++;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new ItemFinderSlot(slotElement);
      }
      
      public function updateFoundItems(arrFoundItems:Array, pageIndex:uint) : void
      {
         this.m_contents = new Array();
         var slotsPerPage:uint = this.getSlotsPerPage();
         var iBase:uint = pageIndex * slotsPerPage;
         var iItem:uint = 0;
         var nFoundItems:uint = arrFoundItems.length;
         var iFoundItem:uint = iBase;
         while(iFoundItem < nFoundItems && iItem < slotsPerPage)
         {
            this.m_contents.push(arrFoundItems[iFoundItem]);
            iFoundItem++;
            iItem++;
         }
      }
      
      public function getSlotsPerPage() : uint
      {
         return SLOTS_PER_PAGE;
      }
      
      override public function refresh() : void
      {
         clearSlots();
         this.setupData();
         populateSlots();
      }
      
      override protected function setupData() : void
      {
         this.m_slotData = this.m_contents;
      }
   }
}

