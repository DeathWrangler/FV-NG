package Widgets.Menu
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class DropDownMenu extends FarmSlotContainerFrame
   {
      
      private var m_itemSelectedCallback:Function;
      
      private var m_topArrowButton:ZwButton = null;
      
      private var m_bottomArrowButton:ZwButton = null;
      
      public function DropDownMenu(element:MovieClip, itemSelectedCallback:Function)
      {
         this.m_itemSelectedCallback = itemSelectedCallback;
         super(element);
      }
      
      public function get items() : Array
      {
         return m_slotData;
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         if(Boolean(calcMaxPageNumber() > 0) && Boolean(element.toparrow_bt) && Boolean(element.bottomarrow_bt))
         {
            this.m_topArrowButton = addWidget(new ZwButton(element.toparrow_bt,m_pagingComponent.onPageBack)) as ZwButton;
            this.m_bottomArrowButton = addWidget(new ZwButton(element.bottomarrow_bt,m_pagingComponent.onPageForward)) as ZwButton;
         }
         this.refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new DropDownMenuItemFrame(slotElement,this.m_itemSelectedCallback);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function refresh() : void
      {
         var slot:DropDownMenuItemFrame = null;
         super.refresh();
         var counter:int = 0;
         for each(slot in m_slots)
         {
            slot.isFirst = counter == 0 ? true : false;
            slot.isLast = counter == m_slotData.length - 1 ? true : false;
            counter++;
         }
         if(Boolean(this.m_topArrowButton) && Boolean(this.m_bottomArrowButton))
         {
            this.m_topArrowButton.visible = !m_pagingComponent.isOnFirstPage();
            this.m_bottomArrowButton.visible = !m_pagingComponent.isOnLastPage();
         }
      }
      
      override public function release() : void
      {
         this.m_itemSelectedCallback = null;
         this.m_topArrowButton = null;
         this.m_bottomArrowButton = null;
         super.release();
      }
   }
}

