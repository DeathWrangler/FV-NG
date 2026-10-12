package Widgets.Frames.Equipment
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Equipment.ResourceHarvesterRewardSlot;
   import flash.display.DisplayObject;
   
   public class ResourceHarvesterRewardSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      private var m_numShared:int = 0;
      
      private var m_numSharesAllowed:int = 0;
      
      public function ResourceHarvesterRewardSlotContainerFrame(element:DisplayObject)
      {
         super(element);
         if(m_element.leftArrow_bt)
         {
            m_pageBackWidget = new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack);
            addWidget(m_pageBackWidget);
         }
         if(m_element.rightArrow_bt)
         {
            m_pageForwardWidget = new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward);
            addWidget(m_pageForwardWidget);
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new ResourceHarvesterRewardSlot(slotElement);
      }
      
      override protected function setupData() : void
      {
      }
      
      public function get items() : Array
      {
         return m_slotData;
      }
      
      public function set items(items:Array) : void
      {
         var item:Array = null;
         m_slotData = items;
         for each(item in m_slotData)
         {
            this.m_numSharesAllowed += item.length;
         }
         refresh();
      }
      
      public function enableShareButtons() : void
      {
         var slot:ResourceHarvesterRewardSlot = null;
         for each(slot in m_slots)
         {
            slot.shareButtonEnabled = true;
         }
      }
      
      public function disableShareButtons() : void
      {
         var slot:ResourceHarvesterRewardSlot = null;
         for each(slot in m_slots)
         {
            slot.shareButtonEnabled = false;
         }
      }
      
      public function refreshShareButtons() : void
      {
         var slot:ResourceHarvesterRewardSlot = null;
         for each(slot in m_slots)
         {
            slot.refreshShareButton();
         }
      }
      
      public function cancelFriendRewards() : void
      {
         var slot:ResourceHarvesterRewardSlot = null;
         for each(slot in m_slots)
         {
            slot.cancelFriendRewards();
         }
      }
      
      public function incrementSharedCount() : void
      {
         ++this.m_numShared;
      }
      
      public function get hasMoreRewards() : Boolean
      {
         return this.m_numShared < this.m_numSharesAllowed;
      }
   }
}

