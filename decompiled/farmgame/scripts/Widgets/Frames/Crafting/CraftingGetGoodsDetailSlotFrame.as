package Widgets.Frames.Crafting
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Components.ZwSimplePagingComponent;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Crafting.CraftingGetGoodsDetailSlot;
   import flash.display.DisplayObject;
   
   public class CraftingGetGoodsDetailSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_items:Array = [];
      
      private var m_callback:Function = null;
      
      public function CraftingGetGoodsDetailSlotFrame(element:DisplayObject, callback:Function)
      {
         this.m_callback = callback;
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
         return new CraftingGetGoodsDetailSlot(slotElement,this.m_callback);
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.padArray(this.m_items);
      }
      
      override public function release() : void
      {
         super.release();
         this.m_items = null;
         this.m_callback = null;
      }
      
      public function update(items:Array) : void
      {
         m_slotData = this.m_items = this.padArray(items);
         refresh();
      }
      
      private function padArray(arrayIn:Array) : Array
      {
         var arrayOut:Array = arrayIn;
         while(arrayOut.length % 4 != 0)
         {
            arrayOut.push(new Object());
         }
         return arrayOut;
      }
   }
}

