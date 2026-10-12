package Widgets.Frames.Clubs
{
   import Managers.Clubs.FarmClubUtility;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import flash.display.DisplayObject;
   
   public class ClubLogoSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      private static const SLOT_PREFIX:String = "logo";
      
      private static const SLOT_POSTFIX:String = "_mc";
      
      private var m_selectedLogo:String;
      
      public function ClubLogoSlotContainerFrame(element:DisplayObject, selectedLogoId:String = "0")
      {
         super(element);
         m_pageBackWidget = addWidget(new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack)) as ZwButton;
         m_pageForwardWidget = addWidget(new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward)) as ZwButton;
         m_pagingComponent.maxPageNumber = calcMaxPageNumber();
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      override public function refresh() : void
      {
         super.refresh();
         this.highlightSelected(this.m_selectedLogo);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new ClubLogoSlotFrame(slotElement,this.onLogoClicked);
      }
      
      override protected function setupData() : void
      {
         var logos:Object = null;
         var logoId:Object = null;
         var logo:Object = null;
         logos = FarmClubUtility.getClubLogoHash();
         m_slotData = new Array();
         for(logoId in logos)
         {
            logo = logos[logoId];
            logo.id = logoId;
            m_slotData.push(logo);
         }
         if(m_slots[0])
         {
            this.m_selectedLogo = (m_slots[0] as ClubLogoSlotFrame).logoId;
            this.highlightSelected(this.m_selectedLogo);
         }
      }
      
      public function onLogoClicked(id:String) : void
      {
         this.m_selectedLogo = id;
         this.highlightSelected(id);
      }
      
      public function get selectedLogoId() : String
      {
         return this.m_selectedLogo;
      }
      
      private function highlightSelected(logoId:String) : void
      {
         var slot:ClubLogoSlotFrame = null;
         for each(slot in m_slots)
         {
            if(slot.logoId != logoId)
            {
               slot.highlight(false);
            }
            else
            {
               slot.highlight(true);
            }
         }
      }
   }
}

