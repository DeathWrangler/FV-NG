package Widgets.Frames
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.MFSWindowSlot;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class MFSDualScrollingSlotFrame extends MFSWindowSlotFrame
   {
      
      private var m_unselectedList:MFSScrollingSlotFrame = null;
      
      private var m_selectedList:MFSScrollingSlotFrame = null;
      
      private var m_slotClickCallback:Function = null;
      
      public function MFSDualScrollingSlotFrame(element:MovieClip, callback:Function)
      {
         super(element,null);
         this.m_slotClickCallback = callback;
         if(element.hasOwnProperty("scrollContainer_list_mc"))
         {
            this.m_unselectedList = new MFSScrollingSlotFrame(element.scrollContainer_list_mc,this.slotsSelected,false);
            addWidget(this.m_unselectedList);
            element.scrollContainer_list_mc.visible = true;
            if(element.scrollContainer_list_mc.hasOwnProperty("scrollbar_mc"))
            {
               element.scrollContainer_list_mc.scrollbar_mc.visible = true;
            }
         }
         if(element.hasOwnProperty("scrollContainer_selected_mc"))
         {
            this.m_selectedList = new MFSScrollingSlotFrame(element.scrollContainer_selected_mc,this.slotsDeSelected,true);
            addWidget(this.m_selectedList);
            element.scrollContainer_selected_mc.visible = true;
            if(element.scrollContainer_selected_mc.hasOwnProperty("scrollbar_mc"))
            {
               element.scrollContainer_selected_mc.scrollbar_mc.visible = true;
            }
         }
      }
      
      private function slotsSelected(slotData:Array) : void
      {
         this.m_selectedList.addItems(slotData);
         this.m_slotClickCallback();
      }
      
      private function slotsDeSelected(slotData:Array) : void
      {
         this.m_unselectedList.addItems(slotData);
         this.m_slotClickCallback();
      }
      
      override public function isPaginated() : Boolean
      {
         return false;
      }
      
      override public function set items(items:Array) : void
      {
         var item:Object = null;
         var selectedItems:Array = new Array();
         var unselectedItems:Array = new Array();
         for each(item in items)
         {
            if(this.m_selectedList.items.indexOf(item) >= 0)
            {
               selectedItems.push(item);
            }
            else
            {
               unselectedItems.push(item);
            }
         }
         this.m_unselectedList.items = unselectedItems;
         this.m_selectedList.items = selectedItems;
      }
      
      override public function getInvalidatedFriendsOnSend() : Array
      {
         return this.m_selectedList.items;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new MFSWindowSlot(slotElement,null);
      }
      
      override public function set enableAll(enable:Boolean) : void
      {
         this.m_unselectedList.enableAll = enable;
         this.m_selectedList.enableAll = enable;
      }
      
      override public function selectAllToggle(selectAll:Boolean) : void
      {
         if(selectAll)
         {
            this.m_unselectedList.selectAllToggle(selectAll);
         }
         else
         {
            this.m_selectedList.selectAllToggle(selectAll);
         }
      }
      
      override public function checkSelectedStatus(totalNumFriendsOnCurrentPage:int) : int
      {
         var result:int = SELECT_STATE_MIX;
         var numSlotsSelected:int = this.numSelectedItems;
         if(numSlotsSelected == totalNumFriendsOnCurrentPage)
         {
            result = SELECT_STATE_ALL;
         }
         else if(numSlotsSelected == 0)
         {
            result = SELECT_STATE_NONE;
         }
         return result;
      }
      
      override public function getSelectedFriends() : Array
      {
         return this.m_selectedList.getSelectedFriends();
      }
      
      override public function get numSelectedItems() : int
      {
         return this.m_selectedList.numSelectedItems;
      }
   }
}

