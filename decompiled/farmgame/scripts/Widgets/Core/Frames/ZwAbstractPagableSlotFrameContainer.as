package Widgets.Core.Frames
{
   import Classes.Constants.Experiments;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Components.ZwSimplePagingComponent;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   
   public class ZwAbstractPagableSlotFrameContainer extends ZwAbstractSlotContainerFrame
   {
      
      protected var m_pagingComponent:ZwSimplePagingComponent = null;
      
      protected var m_pageBackWidget:ZwWidget = null;
      
      protected var m_pageForwardWidget:ZwWidget = null;
      
      protected var m_pageBackLabel:ZwTextField = null;
      
      protected var m_pageForwardLabel:ZwTextField = null;
      
      protected var m_currentPageLabel:ZwTextField = null;
      
      protected var m_pageFirstWidget:ZwWidget = null;
      
      protected var m_pageLastWidget:ZwWidget = null;
      
      public function ZwAbstractPagableSlotFrameContainer(element:DisplayObject)
      {
         super(element);
         this.m_pagingComponent = new ZwSimplePagingComponent(0,this.refresh);
      }
      
      override public function release() : void
      {
         this.m_pagingComponent.release();
         this.m_pagingComponent = null;
         this.m_pageBackWidget = null;
         this.m_pageForwardWidget = null;
         this.m_pageBackLabel = null;
         this.m_pageForwardLabel = null;
         this.m_currentPageLabel = null;
         this.m_pageFirstWidget = null;
         this.m_pageLastWidget = null;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_BUGFIX_SLOT_CONTAINER_RELEASE) > 0)
         {
            super.release();
         }
      }
      
      override public function refresh() : void
      {
         if(m_slots != null && this.m_pagingComponent != null)
         {
            this.m_pagingComponent.maxPageNumber = this.calcMaxPageNumber();
            populateSlots(m_slots.length * this.m_pagingComponent.currentPageNumber);
            this.adjustPagingWidgetVisibility();
            this.redrawCurrentPageLabel();
         }
      }
      
      protected function adjustPagingWidgetVisibility() : void
      {
         if(this.m_pageBackWidget)
         {
            this.m_pageBackWidget.visible = !this.m_pagingComponent.isOnFirstPage();
         }
         if(this.m_pageBackLabel)
         {
            this.m_pageBackLabel.visible = !this.m_pagingComponent.isOnFirstPage();
         }
         if(this.m_pageForwardWidget)
         {
            this.m_pageForwardWidget.visible = !this.m_pagingComponent.isOnLastPage();
         }
         if(this.m_pageForwardLabel)
         {
            this.m_pageForwardLabel.visible = !this.m_pagingComponent.isOnLastPage();
         }
      }
      
      protected function redrawCurrentPageLabel() : void
      {
      }
      
      public function calcMaxPageNumber() : uint
      {
         var maxPageNumber:uint = 0;
         if(Boolean(m_slotData) && m_slotData.length > 0)
         {
            maxPageNumber = Math.ceil(m_slotData.length / m_slots.length) - 1;
         }
         return maxPageNumber;
      }
      
      public function get pageNumber() : uint
      {
         return this.m_pagingComponent.currentPageNumber;
      }
      
      public function set pageNumber(value:uint) : void
      {
         var maxPageNumber:uint = this.calcMaxPageNumber();
         if(value > maxPageNumber)
         {
            value = maxPageNumber;
         }
         this.m_pagingComponent.currentPageNumber = value;
         this.refresh();
      }
   }
}

