package Widgets.Windows.ItemContest
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import flash.display.DisplayObject;
   
   public class ICActiveContestSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_mainWindow:ItemContestWindow = null;
      
      public function ICActiveContestSlotFrame(element:DisplayObject, mainWindow:ItemContestWindow)
      {
         this.m_mainWindow = mainWindow;
         super(element);
         if(m_element.arrowUp_bt != null)
         {
            m_pageBackWidget = new ZwButton(m_element.arrowUp_bt,m_pagingComponent.onPageBack);
            addWidget(m_pageBackWidget);
         }
         if(m_element.arrowDown_bt != null)
         {
            m_pageForwardWidget = new ZwButton(m_element.arrowDown_bt,m_pagingComponent.onPageForward);
            addWidget(m_pageForwardWidget);
         }
         this.refresh();
         centerSlots();
      }
      
      override public function refresh() : void
      {
         m_pagingComponent.maxPageNumber = Math.max(0,m_slotData.length - m_slots.length);
         populateSlots(m_pagingComponent.currentPageNumber);
         adjustPagingWidgetVisibility();
      }
      
      override protected function setupSlots() : void
      {
         var slot:ZwSlotFrame = null;
         var slotIndex:int = 0;
         while(m_element[getSlotPrefix() + slotIndex + getSlotPostfix()])
         {
            slot = this.createSlot(m_element[getSlotPrefix() + slotIndex + getSlotPostfix()]);
            addWidget(slot,false);
            m_slots.push(slot);
            slotIndex++;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new ICActiveContestSlot(slotElement,this.m_mainWindow);
      }
      
      override protected function setupData() : void
      {
         var contestName:String = null;
         var slotData:Array = new Array();
         for each(contestName in this.m_mainWindow.getActiveContestNames())
         {
            if(contestName != null && contestName != "")
            {
               slotData.push(contestName);
            }
         }
         this.m_slotData = slotData;
      }
   }
}

