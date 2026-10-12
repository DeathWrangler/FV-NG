package Widgets.Windows.BeatExpansion
{
   import Managers.BeatExpansion.BeatExpansionBaseManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.BeatExpansion.BeatExpansionTaskSlot;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class BeatExpansionTaskContainerFrame extends FarmSlotContainerFrame
   {
      
      private var m_manager:BeatExpansionBaseManager;
      
      private var m_parentWindow:BeatExpansionWindow;
      
      private var m_topArrowButton:ZwButton = null;
      
      private var m_bottomArrowButton:ZwButton = null;
      
      public function BeatExpansionTaskContainerFrame(element:DisplayObject, manager:BeatExpansionBaseManager, parentWindow:BeatExpansionWindow)
      {
         this.m_manager = manager;
         this.m_parentWindow = parentWindow;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new BeatExpansionTaskSlot(slotElement,this.m_manager,this.m_parentWindow);
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         if(Boolean(calcMaxPageNumber() > 0) && Boolean((element as MovieClip).leftArrow_bt) && Boolean((element as MovieClip).rightArrow_bt))
         {
            if(!this.m_topArrowButton && !this.m_bottomArrowButton)
            {
               this.m_topArrowButton = addWidget(new ZwButton((element as MovieClip).leftArrow_bt,m_pagingComponent.onPageBack)) as ZwButton;
               this.m_bottomArrowButton = addWidget(new ZwButton((element as MovieClip).rightArrow_bt,m_pagingComponent.onPageForward)) as ZwButton;
            }
         }
         this.refresh();
      }
      
      override public function refresh() : void
      {
         super.refresh();
         if(Boolean(this.m_topArrowButton) && Boolean(this.m_bottomArrowButton))
         {
            this.m_topArrowButton.visible = !m_pagingComponent.isOnFirstPage();
            this.m_bottomArrowButton.visible = !m_pagingComponent.isOnLastPage();
         }
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function release() : void
      {
         super.release();
         this.m_topArrowButton = null;
         this.m_bottomArrowButton = null;
      }
   }
}

