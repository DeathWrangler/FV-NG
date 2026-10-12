package Widgets.Frames
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.MFSWindowSlot;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class MFSWindowSlotFrame extends FarmSlotContainerFrame
   {
      
      public static const SELECT_STATE_NONE:int = 0;
      
      public static const SELECT_STATE_ALL:int = 1;
      
      public static const SELECT_STATE_MIX:int = 2;
      
      private var m_clickCallback:Function = null;
      
      public function MFSWindowSlotFrame(element:MovieClip, clickCallback:Function)
      {
         this.m_clickCallback = clickCallback;
         super(element);
      }
      
      public function get items() : Array
      {
         return m_slotData;
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         refresh();
      }
      
      public function getInvalidatedFriendsOnSend() : Array
      {
         return this.items;
      }
      
      public function isPaginated() : Boolean
      {
         return true;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new MFSWindowSlot(slotElement,this.m_clickCallback);
      }
      
      override protected function setupData() : void
      {
      }
      
      public function set enableAll(enable:Boolean) : void
      {
         var slot:MFSWindowSlot = null;
         if(m_slots)
         {
            for each(slot in m_slots)
            {
               slot.enabled = enable;
            }
         }
      }
      
      public function selectAllToggle(selectAll:Boolean) : void
      {
         var slot:MFSWindowSlot = null;
         if(m_slots)
         {
            for each(slot in m_slots)
            {
               slot.selected = selectAll;
            }
         }
      }
      
      public function checkSelectedStatus(totalNumFriendsOnCurrentPage:int) : int
      {
         var result:int = 0;
         var numSlotsSelected:int = 0;
         for(var i:int = 0; i < totalNumFriendsOnCurrentPage; i++)
         {
            if(m_slots[i].selected)
            {
               numSlotsSelected++;
            }
         }
         if(numSlotsSelected == totalNumFriendsOnCurrentPage)
         {
            result = SELECT_STATE_ALL;
         }
         else if(numSlotsSelected == 0)
         {
            result = SELECT_STATE_NONE;
         }
         else
         {
            result = SELECT_STATE_MIX;
         }
         return result;
      }
      
      public function getSelectedUID(totalNumFriendsOnCurrentPage:int) : String
      {
         var result:String = null;
         for(var i:int = 0; i < totalNumFriendsOnCurrentPage; i++)
         {
            if(m_slots[i].selected)
            {
               result = m_slots[i].uid;
            }
         }
         return result;
      }
      
      public function setState(data:Object) : void
      {
         var slot:MFSWindowSlot = null;
         for each(slot in m_slots)
         {
            if(slot.visible && slot.data["uid"] == data["uid"])
            {
               slot.visible = false;
            }
         }
      }
      
      public function getSelectedFriends() : Array
      {
         var slot:MFSWindowSlot = null;
         var data:Object = null;
         var result:Array = new Array();
         for each(slot in m_slots)
         {
            if(slot.visible && slot.selected)
            {
               data = slot.data;
               if(data)
               {
                  result.push(data["uid"]);
               }
            }
         }
         return result;
      }
      
      public function getSelectedFriendsData() : Array
      {
         var slot:MFSWindowSlot = null;
         var data:Object = null;
         var result:Array = new Array();
         for each(slot in m_slots)
         {
            if(slot.visible && slot.selected)
            {
               data = slot.data;
               if(data)
               {
                  result.push(data);
               }
            }
         }
         return result;
      }
      
      public function get numSelectedItems() : int
      {
         var slot:MFSWindowSlot = null;
         var result:int = 0;
         for each(slot in m_slots)
         {
            if(slot.visible && slot.selected)
            {
               result++;
            }
         }
         return result;
      }
      
      override public function release() : void
      {
         this.m_clickCallback = null;
         super.release();
      }
      
      override protected function clearSlot(slotIndex:uint) : void
      {
         var slot:MFSWindowSlot = null;
         if(m_slots[slotIndex])
         {
            slot = m_slots[slotIndex];
            slot.visible = false;
            slot.selected = true;
            slot.data = null;
            slot.clearView();
         }
      }
   }
}

