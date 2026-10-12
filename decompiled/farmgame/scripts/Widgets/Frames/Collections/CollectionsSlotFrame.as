package Widgets.Frames.Collections
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Collections.CollectionsSlot;
   import Widgets.Windows.Collections.CollectionsWindow;
   import flash.display.DisplayObject;
   
   public class CollectionsSlotFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "collectionPanel";
      
      protected static const SLOT_POSTFIX:String = "";
      
      public static const NUM_SLOTS:int = 3;
      
      private var m_mainWindow:CollectionsWindow;
      
      protected var m_collectionItems:Array = null;
      
      public function CollectionsSlotFrame(element:DisplayObject, collectionItems:Array, mainWindow:CollectionsWindow)
      {
         var rightArrow:ZwButton = null;
         this.m_mainWindow = mainWindow;
         this.m_collectionItems = collectionItems;
         super(element);
         var leftArrow:ZwButton = new ZwButton(m_element.arrowLt_bt,m_pagingComponent.onPageBack);
         rightArrow = new ZwButton(m_element.arrowRt_bt,m_pagingComponent.onPageForward);
         addWidget(leftArrow);
         addWidget(rightArrow);
         m_pageBackWidget = leftArrow;
         m_pageForwardWidget = rightArrow;
         refresh();
      }
      
      public function setCollection(collectionItems:Array) : void
      {
         this.m_collectionItems = collectionItems;
         this.setupData();
         populateSlots();
         m_pagingComponent.currentPageNumber = 0;
         refresh();
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      override protected function setupSlots() : void
      {
         var slot:ZwSlotFrame = null;
         var index:uint = 1;
         while(m_element[this.getSlotPrefix() + index + this.getSlotPostfix()])
         {
            slot = this.createSlot(m_element[this.getSlotPrefix() + index + this.getSlotPostfix()]);
            addWidget(slot,false);
            m_slots.push(slot);
            index++;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CollectionsSlot(slotElement,this);
      }
      
      override protected function setupData() : void
      {
         this.m_slotData = this.m_collectionItems;
      }
      
      public function toggleMainWindow(enable:Boolean) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.toggleEnabled(enable);
         }
      }
   }
}

