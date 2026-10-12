package Widgets.Frames
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class GenericTimedSlotFrame extends GenericSlotContainerFrame
   {
      
      public function GenericTimedSlotFrame(element:DisplayObject, slotClass:Class, items:Array, parentWindow:FarmWindow)
      {
         super(element,slotClass,items,parentWindow);
      }
      
      public function setItemData() : void
      {
         this.populateSlots();
      }
      
      override protected function setupSlots() : void
      {
         var slot:ZwSlotFrame = null;
         var index:uint = 0;
         var saveIndices:Boolean = false;
         if(m_items.length == 0)
         {
            saveIndices = true;
         }
         var slotPrefix:String = getSlotPrefix();
         var slotPostfix:String = getSlotPostfix();
         while(m_element[slotPrefix + index.toString() + slotPostfix])
         {
            slot = createSlot(m_element[slotPrefix + index.toString() + slotPostfix]);
            addWidget(slot,false);
            m_slots.push(slot);
            if(saveIndices)
            {
               m_items.push(index);
            }
            index++;
         }
      }
      
      override protected function populateSlots(dataIndex:uint = 0) : void
      {
         clearSlots();
         var slotIdx:uint = 0;
         var slotsLength:int = int(m_slots.length);
         var slotDataLength:int = int(m_slotData.length);
         while(slotIdx < slotsLength && Boolean(m_slots[slotIdx]))
         {
            if(dataIndex >= slotDataLength)
            {
               break;
            }
            populateSlot(m_slots[slotIdx] as ZwSlotFrame,m_slotData[dataIndex]);
            slotIdx++;
            dataIndex++;
         }
         m_lastPopulateStartIndex = dataIndex;
      }
   }
}

