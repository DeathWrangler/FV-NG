package Widgets.Frames.Trading
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Trading.TradingPostOrderSlot;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.Trading.TradingPostWindow;
   import flash.display.DisplayObject;
   
   public class TradingPostOrderSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_myOrders:Array = null;
      
      private var m_tradingWindow:TradingPostWindow = null;
      
      public function TradingPostOrderSlotFrame(element:DisplayObject, myOrders:Array, tradingWindow:TradingPostWindow)
      {
         var isSorryVisible:Boolean = false;
         this.m_myOrders = myOrders;
         this.m_tradingWindow = tradingWindow;
         super(element);
         m_pageBackWidget = addWidget(new ZwButton(m_element.arrowUp_bt,m_pagingComponent.onPageBack)) as ZwButton;
         m_pageForwardWidget = addWidget(new ZwButton(m_element.arrowDown_bt,m_pagingComponent.onPageForward)) as ZwButton;
         if(m_element.hasOwnProperty("sorry_tf"))
         {
            isSorryVisible = myOrders.length > 0 ? false : true;
            addWidget(new FarmTextField(m_element.sorry_tf,ZLocUtils.t("Dialogs","tradingpost_UI_sorry_orders")),isSorryVisible);
         }
         m_pagingComponent.maxPageNumber = calcMaxPageNumber();
         adjustPagingWidgetVisibility();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new TradingPostOrderSlot(slotElement,this,this.m_tradingWindow);
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_myOrders;
      }
      
      public function refreshSlotData(items:Array) : void
      {
         m_slotData = this.m_myOrders = items;
         refresh();
      }
      
      override public function release() : void
      {
         super.release();
         this.m_myOrders = null;
         this.m_tradingWindow = null;
      }
   }
}

