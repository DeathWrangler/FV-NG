package Widgets.Frames
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.HalloweenUSAInnovationTaskSlot;
   import flash.display.DisplayObject;
   
   public class HalloweenUSAInnovationTaskFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String = null;
      
      public function HalloweenUSAInnovationTaskFrame(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         super(element);
         if(m_element.page_tf)
         {
            m_currentPageLabel = new ZwTextField(m_element.page_tf);
            addWidget(m_currentPageLabel,true);
            m_currentPageLabel.visible = true;
         }
         if(m_element.back_bt)
         {
            m_pageBackWidget = new ZwButton(m_element["back_bt"],m_pagingComponent.onPageBack);
            addWidget(m_pageBackWidget);
            if(m_pagingComponent.currentPageNumber == 0)
            {
               m_pageBackWidget.visible = false;
            }
         }
         if(m_element["next_bt"] != null)
         {
            m_pageForwardWidget = new ZwButton(m_element["next_bt"],m_pagingComponent.onPageForward);
            addWidget(m_pageForwardWidget);
            m_pageForwardWidget.visible = m_pagingComponent.maxPageNumber > 0;
         }
         m_currentPageLabel.text = ZLocUtils.t("Dialogs","GiftBox_Page",{
            "current":m_pagingComponent.currentPageNumber + 1,
            "total":2
         });
         m_currentPageLabel.visible = true;
      }
      
      override protected function setupData() : void
      {
      }
      
      public function setupSlotData(slotData:Array) : void
      {
         m_slotData = slotData;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new HalloweenUSAInnovationTaskSlot(slotElement,this.m_featureName);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "slot_";
      }
   }
}

