package Widgets.Frames.Crafting
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Components.ZwSimplePagingComponent;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Crafting.VisitingMarketStallSlot;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class VisitingMarketStallSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_InventoryItems:Array = null;
      
      protected var m_ItemClaimedCallback:Function = null;
      
      protected var m_ItemBoughtCallback:Function = null;
      
      protected var m_FromUser:String;
      
      protected var m_mode:String;
      
      public function VisitingMarketStallSlotFrame(element:MovieClip, items:Array, itemClaimedCallback:Function, itemBoughtCallback:Function, fromUser:String)
      {
         var leftArrow:ZwButton = null;
         var rightArrow:ZwButton = null;
         this.m_InventoryItems = items;
         this.m_FromUser = fromUser;
         this.m_ItemClaimedCallback = itemClaimedCallback;
         this.m_ItemBoughtCallback = itemBoughtCallback;
         super(element);
         m_pagingComponent = new ZwSimplePagingComponent(0,this.refresh);
         m_pagingComponent.maxPageNumber = Math.floor(m_slotData.length / m_slots.length);
         if(m_element.arrowButtonLeft_mc != null)
         {
            leftArrow = new ZwButton(m_element.arrowButtonLeft_mc,m_pagingComponent.onPageBack);
            rightArrow = new ZwButton(m_element.arrowButtonRight_mc,m_pagingComponent.onPageForward);
            addWidget(leftArrow);
            addWidget(rightArrow);
            m_pageBackWidget = leftArrow;
            m_pageForwardWidget = rightArrow;
         }
         this.refresh();
      }
      
      override protected function setupData() : void
      {
         this.m_slotData = this.m_InventoryItems;
      }
      
      public function setInventory(items:Array, mode:String) : void
      {
         this.m_mode = mode;
         this.m_InventoryItems = items;
         m_slotData = this.m_InventoryItems;
         var previousPage:int = int(m_pagingComponent.currentPageNumber);
         m_pagingComponent.maxPageNumber = Math.floor(m_slotData.length / m_slots.length);
         m_pagingComponent.currentPageNumber = Math.min(previousPage,m_pagingComponent.maxPageNumber);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new VisitingMarketStallSlot(slotElement,this.m_ItemClaimedCallback,this.m_ItemBoughtCallback,this.m_FromUser);
      }
      
      override public function refresh() : void
      {
         var slot:VisitingMarketStallSlot = null;
         m_pagingComponent.maxPageNumber = calcMaxPageNumber();
         for each(slot in m_slots)
         {
            slot.mode = this.m_mode;
         }
         populateSlots(m_slots.length * m_pagingComponent.currentPageNumber);
         if(this.m_pageBackWidget != null && this.m_pageForwardWidget != null)
         {
            adjustPagingWidgetVisibility();
         }
      }
      
      override protected function setupSlots() : void
      {
         super.setupSlots();
      }
      
      public function setButtonEnables(bool:Boolean) : void
      {
         var slot:VisitingMarketStallSlot = null;
         for each(slot in m_slots)
         {
            slot.setButtonEnable(bool);
         }
      }
   }
}

