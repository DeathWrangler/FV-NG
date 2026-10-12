package Widgets.Frames.Crafting
{
   import Classes.CraftingCottageBuilding;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Components.ZwSimplePagingComponent;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Crafting.CraftingStoreFrontSlot;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class CraftingStoreFrontFrame extends FarmSlotContainerFrame
   {
      
      private static const NUM_SLOTS:int = 4;
      
      private var m_cottage:CraftingCottageBuilding;
      
      protected var m_ItemsForSale:Array;
      
      private var m_leftButton:ZwButton;
      
      private var m_rightButton:ZwButton;
      
      private var m_setPriceCallBack:Function;
      
      public function CraftingStoreFrontFrame(element:MovieClip, items:Array, setPriceCallBack:Function, cottage:CraftingCottageBuilding)
      {
         this.m_cottage = cottage;
         this.m_ItemsForSale = items.sortOn("friendlyName");
         this.m_setPriceCallBack = setPriceCallBack;
         super(element);
         this.m_pagingComponent = new ZwSimplePagingComponent(0,this.refresh);
         this.m_pagingComponent.maxPageNumber = Math.floor(m_slotData.length / m_slots.length);
         this.m_leftButton = new ZwButton(element.arrowButtonLeft_mc,m_pagingComponent.onPageBack);
         this.m_rightButton = new ZwButton(element.arrowButtonRight_mc,m_pagingComponent.onPageForward);
         addWidget(this.m_leftButton);
         addWidget(this.m_rightButton);
         m_pageBackWidget = this.m_leftButton;
         m_pageForwardWidget = this.m_rightButton;
         addWidget(new SalesReportFrame(m_element.salesReport_mc,this.m_cottage));
         this.refresh();
      }
      
      override protected function setupData() : void
      {
         this.m_slotData = this.m_ItemsForSale;
         while(m_slotData.length < NUM_SLOTS || m_slotData.length % NUM_SLOTS != 0)
         {
            m_slotData.push({});
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CraftingStoreFrontSlot(slotElement,this.m_setPriceCallBack);
      }
      
      override public function refresh() : void
      {
         m_pagingComponent.maxPageNumber = calcMaxPageNumber();
         populateSlots(m_slots.length * m_pagingComponent.currentPageNumber);
         adjustPagingWidgetVisibility();
      }
      
      public function reload(items:Array) : void
      {
         this.m_ItemsForSale = items.sortOn("friendlyName");
         this.setupData();
         this.m_pagingComponent.currentPageNumber = 0;
         this.refresh();
      }
      
      override protected function setupSlots() : void
      {
         super.setupSlots();
      }
      
      override public function release() : void
      {
         super.release();
         this.m_leftButton = null;
         this.m_rightButton = null;
         this.m_ItemsForSale = null;
      }
   }
}

