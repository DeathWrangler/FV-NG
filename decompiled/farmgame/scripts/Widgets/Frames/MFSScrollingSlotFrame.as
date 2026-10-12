package Widgets.Frames
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Interfaces.IFarmScrollBarInteractiveComponent;
   import Widgets.Slots.MFSWindowSlot;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class MFSScrollingSlotFrame extends MFSWindowSlotFrame implements IFarmScrollBarInteractiveComponent
   {
      
      private var m_clickCallback:Function = null;
      
      private var m_startIndex:int = 0;
      
      private var m_scrollBar:ZwScrollbar = null;
      
      private var m_defaultSelectedState:Boolean = false;
      
      public function MFSScrollingSlotFrame(element:MovieClip, clickCallback:Function, defaultSelectedState:Boolean = false)
      {
         this.m_clickCallback = clickCallback;
         this.m_defaultSelectedState = defaultSelectedState;
         super(element,clickCallback);
         if(m_element.scrollbar_mc)
         {
            this.m_scrollBar = new ZwScrollbar(m_element.scrollbar_mc,this);
            addWidget(this.m_scrollBar);
         }
      }
      
      public function scrollCallback(percent:Number) : void
      {
         if(m_slotData.length > 0)
         {
            this.m_startIndex = Math.round(percent * (m_slotData.length - 1));
         }
         this.refresh();
      }
      
      public function scrollForwardCallback() : Number
      {
         if(this.m_startIndex < m_slotData.length - 1)
         {
            ++this.m_startIndex;
            this.refresh();
         }
         return this.getPositionAsPercent();
      }
      
      public function scrollBackCallback() : Number
      {
         if(this.m_startIndex > 0)
         {
            --this.m_startIndex;
            this.refresh();
         }
         return this.getPositionAsPercent();
      }
      
      private function getPositionAsPercent() : Number
      {
         var percent:Number = 0;
         if(m_slotData.length > 1)
         {
            percent = this.m_startIndex / (m_slotData.length - 1);
         }
         return percent;
      }
      
      override public function refresh() : void
      {
         var slotDataLength:int = int(m_slotData.length);
         if(this.m_startIndex > slotDataLength - 1 && slotDataLength > 0)
         {
            this.m_startIndex = slotDataLength - 1;
         }
         if(m_slots != null)
         {
            populateSlots(this.m_startIndex);
         }
      }
      
      override protected function populateSlot(slot:ZwSlotFrame, data:Object) : void
      {
         var mfsSlot:MFSWindowSlot = slot as MFSWindowSlot;
         mfsSlot.populate(data);
         mfsSlot.visible = true;
         mfsSlot.selected = this.m_defaultSelectedState;
      }
      
      public function addItems(items:Array) : void
      {
         if(items)
         {
            m_slotData = items.concat(m_slotData);
            this.refresh();
         }
      }
      
      private function transferSlots(uidsToTransfer:Array) : void
      {
         var transferSlotData:Array = null;
         var slotDataLength:int = int(m_slotData.length);
         var newSlotData:Array = new Array();
         transferSlotData = new Array();
         for(var i:int = 0; i < slotDataLength; i++)
         {
            if(Boolean(m_slotData[i]) && Boolean(uidsToTransfer[m_slotData[i].uid]))
            {
               transferSlotData.push(m_slotData[i]);
            }
            else
            {
               newSlotData.push(m_slotData[i]);
            }
         }
         m_slotData = newSlotData;
         this.m_clickCallback(transferSlotData);
      }
      
      private function transferSlotsSelected() : void
      {
         var slot:MFSWindowSlot = null;
         var slotsLength:int = int(m_slots.length);
         var uidsToTransfer:Array = new Array();
         for(var i:int = 0; i < slotsLength; i++)
         {
            slot = m_slots[i];
            if(Boolean(slot.data) && slot.selected != this.m_defaultSelectedState)
            {
               uidsToTransfer[slot.data.uid] = true;
            }
         }
         this.transferSlots(uidsToTransfer);
         this.refresh();
      }
      
      override public function selectAllToggle(toggle:Boolean) : void
      {
         this.m_clickCallback(m_slotData);
         m_slotData = new Array();
         this.refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new MFSWindowSlot(slotElement,this.transferSlotsSelected);
      }
      
      override public function getSelectedFriends() : Array
      {
         var slot:Object = null;
         var result:Array = new Array();
         for each(slot in items)
         {
            result.push(slot.uid);
         }
         return result;
      }
      
      override public function get numSelectedItems() : int
      {
         var result:int = 0;
         if(items)
         {
            result = int(items.length);
         }
         return result;
      }
      
      override public function release() : void
      {
         this.m_clickCallback = null;
         this.m_scrollBar.release();
         super.release();
      }
   }
}

