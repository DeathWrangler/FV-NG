package Widgets.Frames
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.RecentlyPlayedFriendsGiftSlot;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class RecentlyPlayedFriendsGiftSlotFrame extends FarmSlotContainerFrame
   {
      
      private var m_clickCallback:Function;
      
      public function RecentlyPlayedFriendsGiftSlotFrame(element:MovieClip, clickCallback:Function)
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
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new RecentlyPlayedFriendsGiftSlot(slotElement,this.m_clickCallback);
      }
      
      override protected function setupData() : void
      {
      }
      
      public function getSelectedFriends() : Array
      {
         var slot:RecentlyPlayedFriendsGiftSlot = null;
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
      
      public function setNumberOfSelected(num:int) : void
      {
         var slot:RecentlyPlayedFriendsGiftSlot = null;
         for each(slot in m_slots)
         {
            if(num > 0)
            {
               slot.selected = true;
            }
            else
            {
               slot.selected = false;
            }
            num--;
         }
      }
      
      override public function release() : void
      {
         this.m_clickCallback = null;
         super.release();
      }
   }
}

