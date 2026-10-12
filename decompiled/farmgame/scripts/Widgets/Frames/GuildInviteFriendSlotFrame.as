package Widgets.Frames
{
   import Managers.GuildManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.GuildInviteFriendSlot;
   import Widgets.Windows.GuildAddMembersWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class GuildInviteFriendSlotFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String = null;
      
      private const BACK_BT:String = "back_bt";
      
      private const NEXT_BT:String = "next_bt";
      
      private var m_parentWindow:GuildAddMembersWindow;
      
      public function GuildInviteFriendSlotFrame(element:DisplayObject, featureName:String, window:GuildAddMembersWindow)
      {
         this.m_featureName = featureName;
         this.m_parentWindow = window;
         super(element);
         if(m_element[this.BACK_BT] != null)
         {
            m_pageBackWidget = new ZwButton(m_element[this.BACK_BT],this.onPageBack);
            addWidget(m_pageBackWidget);
            if(m_pagingComponent.currentPageNumber == 0)
            {
               m_pageBackWidget.visible = false;
            }
         }
         if(m_element[this.NEXT_BT] != null)
         {
            m_pageForwardWidget = new ZwButton(m_element[this.NEXT_BT],this.onPageForward);
            addWidget(m_pageForwardWidget);
         }
         this.refresh();
      }
      
      override protected function setupData() : void
      {
         m_slotData = GuildManager.getInstance().getFriendsDataForInvites();
      }
      
      public function setupSlotData(slotData:Array) : void
      {
         m_slotData = slotData;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new GuildInviteFriendSlot(slotElement,this.m_featureName,this.m_parentWindow);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "player";
      }
      
      public function onPageBack(event:Event) : void
      {
         m_pagingComponent.onPageBack(event);
      }
      
      public function onPageForward(event:Event) : void
      {
         m_pagingComponent.onPageForward(event);
      }
      
      override public function refresh() : void
      {
         m_pagingComponent.maxPageNumber = calcMaxPageNumber();
         populateSlots(m_slots.length * m_pagingComponent.currentPageNumber);
         adjustPagingWidgetVisibility();
      }
      
      override protected function clearSlot(slotIndex:uint) : void
      {
         var slot:GuildInviteFriendSlot = null;
         if(m_slots[slotIndex])
         {
            slot = m_slots[slotIndex];
            slot.visible = false;
            slot.clearView();
         }
      }
   }
}

