package Widgets.Frames.Clubs
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Clubs.BrowseClubSlot;
   import Widgets.Slots.Clubs.MyClubSlot;
   import Widgets.Slots.Clubs.Top50ClubSlot;
   import Widgets.Slots.Clubs.TopFarmersSlot;
   import flash.display.DisplayObject;
   import flash.utils.getDefinitionByName;
   
   public class FarmClubGenericSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      private static var m_slotClassName:String;
      
      private static const SLOT_PREFIX:String = "slot";
      
      protected var m_slotTypes:Array = [BrowseClubSlot,MyClubSlot,Top50ClubSlot,TopFarmersSlot];
      
      public function FarmClubGenericSlotContainerFrame(element:DisplayObject, slotClassName:String)
      {
         m_slotClassName = slotClassName;
         super(element);
         m_pageBackWidget = addWidget(new ZwButton(m_element.upArrow_bt,m_pagingComponent.onPageBack)) as ZwButton;
         m_pageForwardWidget = addWidget(new ZwButton(m_element.downArrow_bt,m_pagingComponent.onPageForward)) as ZwButton;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         var slotClass:Class = getDefinitionByName("Widgets.Slots.Clubs." + m_slotClassName) as Class;
         return new slotClass(slotElement);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function release() : void
      {
         super.release();
         m_pageBackWidget = null;
         m_pageForwardLabel = null;
         m_slotClassName = null;
      }
      
      public function get numSlots() : int
      {
         return m_slots.length;
      }
      
      public function get items() : Array
      {
         return m_slotData;
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         m_pagingComponent.reset();
         refresh();
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
   }
}

