package Widgets.Frames.Trading
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Components.ZwSimplePagingComponent;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Trading.TradingPostGoodSlot;
   import Widgets.Windows.Trading.TradingPostWindow;
   import flash.display.DisplayObject;
   
   public class TradingPostGoodSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_items:Array = [];
      
      private var m_tradingWindow:TradingPostWindow = null;
      
      public function TradingPostGoodSlotFrame(element:DisplayObject, parentWindow:TradingPostWindow)
      {
         this.m_tradingWindow = parentWindow;
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
         return new TradingPostGoodSlot(slotElement,this);
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.padArray(this.m_items);
      }
      
      override public function release() : void
      {
         super.release();
         this.m_items = null;
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

