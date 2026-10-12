package Widgets.Frames.CaptureFeatureBuilding
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.CaptureFeatureBuilding.CaptureFeatureBuildingSlot;
   import flash.display.DisplayObject;
   
   public class CaptureFeatureBuildingFrame extends FarmSlotContainerFrame
   {
      
      private const SLOT_PREFIX:String = "upgradeCard_";
      
      private var m_currentLevel:int = 1;
      
      private var m_captureCount:int = 0;
      
      private var m_featureName:String = null;
      
      public function CaptureFeatureBuildingFrame(featureName:String, element:DisplayObject, buildingData:Array, currentLevel:int, captureCount:int)
      {
         this.m_featureName = featureName;
         this.m_currentLevel = currentLevel;
         this.m_captureCount = captureCount;
         super(element);
         m_slotData = buildingData;
         if(m_element.leftArrow_bt)
         {
            m_pageBackWidget = new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack);
            addWidget(m_pageBackWidget);
         }
         if(m_element.rightArrow_bt)
         {
            m_pageForwardWidget = new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward);
            addWidget(m_pageForwardWidget);
         }
         if(m_element.gopherCount_tf)
         {
            addWidget(new ZwTextField(m_element.gopherCount_tf,this.m_captureCount.toString()));
         }
         refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CaptureFeatureBuildingSlot(this.m_featureName,slotElement,this.m_currentLevel,this.m_captureCount);
      }
      
      override protected function getSlotPrefix() : String
      {
         return this.SLOT_PREFIX;
      }
      
      override protected function setupData() : void
      {
      }
   }
}

