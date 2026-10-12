package Widgets.Frames.FriendInvite
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.FriendInvite.FriendInviteSlot;
   import flash.display.DisplayObject;
   
   public class FriendInviteSlotFrame extends FarmSlotContainerFrame
   {
      
      public static const SLOT_PER_FRAME_PAGE:Number = 16;
      
      private var m_friendInviteFrame:FriendInviteFrame = null;
      
      public function FriendInviteSlotFrame(element:DisplayObject, friendInviteFrame:FriendInviteFrame)
      {
         var arrowsVisible:Boolean = false;
         this.m_friendInviteFrame = friendInviteFrame;
         super(element);
         var numberOfAppFriends:uint = this.m_friendInviteFrame.friendList.length;
         arrowsVisible = numberOfAppFriends > SLOT_PER_FRAME_PAGE;
         m_pageBackWidget = new ZwButton(m_element.arrowLeft_mc,m_pagingComponent.onPageBack);
         addWidget(m_pageBackWidget,arrowsVisible);
         m_pageForwardWidget = new ZwButton(m_element.arrowRight_mc,m_pagingComponent.onPageForward);
         addWidget(m_pageForwardWidget,arrowsVisible);
         refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FriendInviteSlot(slotElement,this.m_friendInviteFrame);
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_friendInviteFrame.friendObjs;
      }
   }
}

