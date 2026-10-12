package Widgets.Frames
{
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class GenericSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      protected var m_items:Array = null;
      
      protected var m_slotClass:Class;
      
      protected var m_parentWindow:FarmWindow;
      
      public function GenericSlotContainerFrame(element:DisplayObject, slotClass:Class, items:Array, parentWindow:FarmWindow)
      {
         this.m_items = items;
         this.m_slotClass = slotClass;
         this.m_parentWindow = parentWindow;
         super(element);
         if(!m_pageBackWidget && Boolean(m_element["leftArrow_bt"]))
         {
            m_pageBackWidget = addWidget(new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack)) as ZwWidget;
         }
         if(!m_pageForwardWidget && Boolean(m_element["rightArrow_bt"]))
         {
            m_pageForwardWidget = addWidget(new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward)) as ZwWidget;
         }
         refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new this.m_slotClass(slotElement,this.m_parentWindow);
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_items;
      }
      
      override public function release() : void
      {
         super.release();
         this.m_items = null;
         this.m_slotClass = null;
      }
      
      public function setData(data:Array) : void
      {
         m_slotData = this.m_items = data;
         refresh();
      }
   }
}

