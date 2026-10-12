package Widgets.Frames.Clubs
{
   import Classes.ZItem.FarmItem;
   import Managers.Clubs.FarmClubUtility;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Clubs.FarmClubTierSlot;
   import Widgets.Windows.Clubs.FarmClubWindow2;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class FarmClubTierSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      private var m_parentWindow:FarmClubWindow2 = null;
      
      public function FarmClubTierSlotContainerFrame(element:DisplayObject, parentWindow:FarmClubWindow2)
      {
         this.m_parentWindow = parentWindow;
         super(element);
         m_pageForwardWidget = addWidget(new ZwButton(m_element.arrowUp_bt,m_pagingComponent.onPageForward)) as ZwButton;
         m_pageBackWidget = addWidget(new ZwButton(m_element.arrowDown_bt,m_pagingComponent.onPageBack)) as ZwButton;
         refresh();
         var topClubs:ZwFrame = addWidget(new ZwFrame(m_element.topClubButton_mc)) as ZwFrame;
         topClubs.element.buttonMode = true;
         topClubs.element.addEventListener(MouseEvent.CLICK,this.onTopClubs);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "topClubSlot_";
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FarmClubTierSlot(slotElement,this.m_parentWindow);
      }
      
      override protected function setupData() : void
      {
         var slotData:Object = null;
         var tierItem:FarmItem = null;
         var totalTiers:int = FarmClubUtility.getNumTiers();
         for(var tierIndex:int = 1; tierIndex <= totalTiers; tierIndex++)
         {
            slotData = new Object();
            slotData.tierNum = tierIndex;
            tierItem = FarmClubUtility.getFarmItemFromTier(tierIndex);
            slotData.tierItem = tierItem;
            if(tierItem != null)
            {
               m_slotData.push(slotData);
            }
         }
      }
      
      private function onTopClubs(event:MouseEvent) : void
      {
         this.m_parentWindow.onTopClubsClick();
      }
   }
}

