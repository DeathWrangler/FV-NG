package Widgets.Frames.Stencil
{
   import Managers.StencilManager;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.StencilSlot;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class StencilFrame extends FarmSlotContainerFrame
   {
      
      private var m_backwardBtn:FarmButton;
      
      private var m_forwardBtn:FarmButton;
      
      public function StencilFrame(element:MovieClip)
      {
         super(element);
         addWidget(this.m_backwardBtn = new FarmButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack));
         addWidget(this.m_forwardBtn = new FarmButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward));
         addWidget(m_currentPageLabel = new ZwTextField(m_element.page_tf));
         m_pagingComponent.maxPageNumber = int(m_slotData.length / totalSlots()) - 1;
         if(m_slotData.length % totalSlots() != 0)
         {
            m_pagingComponent.maxPageNumber += 1;
         }
         this.refreshArrows();
      }
      
      private function get manager() : StencilManager
      {
         return StencilManager.instance();
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.manager.stencils;
      }
      
      override protected function populateSlots(pageIndex:uint = 0) : void
      {
         clearSlots();
         var dataIndex:uint = pageIndex * totalSlots();
         for(var i:int = 0; i < totalSlots(); i++)
         {
            if(m_slotData[dataIndex])
            {
               m_slots[i].visible = true;
               StencilSlot(m_slots[i]).populateSlot(m_slotData[dataIndex]);
            }
            dataIndex++;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new StencilSlot(slotElement);
      }
      
      override public function refresh() : void
      {
         this.populateSlots(m_pagingComponent.currentPageNumber);
         this.refreshArrows();
      }
      
      override public function release() : void
      {
         this.m_backwardBtn = null;
         this.m_forwardBtn = null;
         super.release();
      }
      
      private function refreshArrows() : void
      {
         this.m_forwardBtn.visible = false;
         this.m_backwardBtn.visible = false;
         if(!m_pagingComponent.isOnLastPage())
         {
            this.m_forwardBtn.visible = true;
         }
         if(!m_pagingComponent.isOnFirstPage())
         {
            this.m_backwardBtn.visible = true;
         }
      }
   }
}

