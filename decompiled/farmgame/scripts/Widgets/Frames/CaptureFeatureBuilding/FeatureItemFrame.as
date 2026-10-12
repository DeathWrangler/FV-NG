package Widgets.Frames.CaptureFeatureBuilding
{
   import Classes.util.ZLocUtils;
   import Managers.CaptureFeatureManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.CaptureFeatureBuilding.FeatureItemSlot;
   import flash.display.DisplayObject;
   
   public class FeatureItemFrame extends FarmSlotContainerFrame
   {
      
      private const SLOT_PREFIX:String = "gopher_";
      
      private var m_buildingLevel:int = 0;
      
      private var m_featureName:String = null;
      
      public function FeatureItemFrame(featureName:String, element:DisplayObject, gophers:Array, capturedCount:int, buildingLevel:int)
      {
         var capturedText:String = null;
         this.m_featureName = featureName;
         this.m_buildingLevel = buildingLevel;
         super(element);
         m_slotData = gophers;
         if(capturedCount == 1)
         {
            capturedText = ZLocUtils.t("Dialogs",CaptureFeatureManager.instance.getStringsPrefix(this.m_featureName) + "_GophersCaptured_singular");
         }
         else
         {
            capturedText = ZLocUtils.t("Dialogs",CaptureFeatureManager.instance.getStringsPrefix(this.m_featureName) + "_GophersCaptured",{"count":capturedCount});
         }
         addWidget(new ZwTextField(m_element.gopherCount_tf,capturedText));
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
         refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FeatureItemSlot(this.m_featureName,slotElement,this.m_buildingLevel);
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

