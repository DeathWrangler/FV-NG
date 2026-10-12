package Widgets.Windows.RegionAchievement
{
   import Managers.RegionAchievementManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class RegionAchievementTaskContainerFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "task";
      
      private var m_featureName:String;
      
      private var m_topArrowButton:ZwButton = null;
      
      private var m_bottomArrowButton:ZwButton = null;
      
      public function RegionAchievementTaskContainerFrame(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new RegionAchievementTaskSlot(slotElement,this.m_featureName);
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         if(Boolean(calcMaxPageNumber() > 0) && Boolean((m_element as MovieClip).topArrow_bt) && Boolean((m_element as MovieClip).bottomArrow_bt))
         {
            if(!this.m_topArrowButton && !this.m_bottomArrowButton)
            {
               this.m_topArrowButton = addWidget(new ZwButton((m_element as MovieClip).topArrow_bt,m_pagingComponent.onPageBack)) as ZwButton;
               this.m_bottomArrowButton = addWidget(new ZwButton((m_element as MovieClip).bottomArrow_bt,m_pagingComponent.onPageForward)) as ZwButton;
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
         m_slotData = RegionAchievementManager.getInstance(this.m_featureName).getActiveRegionAchievementsByRegionId("");
      }
      
      override public function release() : void
      {
         super.release();
         this.m_topArrowButton = null;
         this.m_bottomArrowButton = null;
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
   }
}

