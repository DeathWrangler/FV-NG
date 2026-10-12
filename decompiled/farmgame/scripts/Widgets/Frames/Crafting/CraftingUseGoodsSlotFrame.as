package Widgets.Frames.Crafting
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Components.ZwSimplePagingComponent;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Crafting.CraftingUseGoodsSlot;
   import flash.display.DisplayObject;
   
   public class CraftingUseGoodsSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_items:Array = null;
      
      private var m_clickCallback:Function = null;
      
      public function CraftingUseGoodsSlotFrame(element:DisplayObject, items:Array, clickCallback:Function)
      {
         this.m_items = items;
         this.m_clickCallback = clickCallback;
         super(element);
         m_pagingComponent = new ZwSimplePagingComponent(0,this.refresh);
         m_pagingComponent.maxPageNumber = Math.floor(m_slotData.length / m_slots.length);
         m_pageBackWidget = new ZwButton(m_element.arrowLeft_bt,m_pagingComponent.onPageBack);
         m_pageForwardWidget = new ZwButton(m_element.arrowRight_bt,m_pagingComponent.onPageForward);
         addWidget(m_pageBackWidget);
         addWidget(m_pageForwardWidget);
         refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CraftingUseGoodsSlot(slotElement,this.m_clickCallback);
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_items;
      }
      
      override public function release() : void
      {
         super.release();
         this.m_items = null;
         this.m_clickCallback = null;
      }
      
      public function update(items:Array) : void
      {
         m_slotData = this.m_items = items;
         refresh();
      }
      
      public function setEnabled(enable:Boolean) : void
      {
         var slot:CraftingUseGoodsSlot = null;
         for(var i:int = 0; i < m_slots.length; i++)
         {
            slot = m_slots[i] as CraftingUseGoodsSlot;
            slot.setEnabled(enable);
         }
      }
   }
}

