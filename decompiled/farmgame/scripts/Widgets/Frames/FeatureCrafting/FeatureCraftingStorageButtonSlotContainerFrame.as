package Widgets.Frames.FeatureCrafting
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.FeatureCrafting.FeatureCraftingStorageButtonSlot;
   import Widgets.Windows.FeatureCrafting.FeatureCraftingContentsWindow;
   import flash.display.DisplayObject;
   
   public class FeatureCraftingStorageButtonSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      private var m_currentContentWindow:FeatureCraftingContentsWindow;
      
      private var m_location:String = "";
      
      public function FeatureCraftingStorageButtonSlotContainerFrame(element:DisplayObject, location:String = "")
      {
         this.m_location = location;
         super(element);
         if(m_element.leftArrow_bt)
         {
            m_pageBackWidget = addWidget(new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack)) as ZwButton;
         }
         if(m_element.rightArrow_bt)
         {
            m_pageForwardWidget = addWidget(new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward)) as ZwButton;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FeatureCraftingStorageButtonSlot(slotElement,this.m_location);
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
         m_slotData = items;
         refresh();
      }
      
      public function getElement(storageName:String) : DisplayObject
      {
         var slot:FeatureCraftingStorageButtonSlot = null;
         var result:DisplayObject = null;
         for each(slot in m_slots)
         {
            if(slot.data.name == storageName)
            {
               result = slot.element as DisplayObject;
               break;
            }
         }
         return result;
      }
      
      public function refreshCounts() : void
      {
         var slot:FeatureCraftingStorageButtonSlot = null;
         for each(slot in m_slots)
         {
            slot.currentContentWindow = this.currentContentWindow;
            slot.refreshCount();
         }
      }
      
      public function get currentContentWindow() : FeatureCraftingContentsWindow
      {
         return this.m_currentContentWindow;
      }
      
      public function set currentContentWindow(currentContentWindow:FeatureCraftingContentsWindow) : void
      {
         this.m_currentContentWindow = currentContentWindow;
      }
   }
}

