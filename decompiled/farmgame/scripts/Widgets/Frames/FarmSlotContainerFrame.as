package Widgets.Frames
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwAbstractPagableSlotFrameContainer;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   
   public class FarmSlotContainerFrame extends ZwAbstractPagableSlotFrameContainer
   {
      
      protected static const SLOT_PREFIX:String = "slot_";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      protected static const BUNDLE_LOC_KEY:String = "FarmGame";
      
      protected static const CURRENT_PAGE_LABEL_LOC_KEY:String = "General_CurrentPageLabel";
      
      protected static const PAGE_BACK_LABEL_LOC_KEY:String = "General_PageBackLabel";
      
      protected static const PAGE_FORWARD_LABEL_LOC_KEY:String = "General_PageForwardLabel";
      
      public function FarmSlotContainerFrame(element:DisplayObject)
      {
         super(element);
         if(m_element.pageCount_tf)
         {
            m_currentPageLabel = new ZwTextField(m_element.pageCount_tf);
            addWidget(m_currentPageLabel);
         }
         if(m_element.backArrow_tf)
         {
            m_pageBackLabel = new ZwTextField(m_element.backArrow_tf,ZLocUtils.t(BUNDLE_LOC_KEY,PAGE_BACK_LABEL_LOC_KEY));
            addWidget(m_pageBackLabel);
         }
         if(m_element.nextArrow_tf)
         {
            m_pageForwardLabel = new ZwTextField(m_element.nextArrow_tf,ZLocUtils.t(BUNDLE_LOC_KEY,PAGE_FORWARD_LABEL_LOC_KEY));
            addWidget(m_pageForwardLabel);
         }
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      override protected function setupData() : void
      {
      }
      
      override protected function redrawCurrentPageLabel() : void
      {
         if(m_currentPageLabel)
         {
            if(m_pagingComponent.maxPageNumber)
            {
               m_currentPageLabel.text = ZLocUtils.t(BUNDLE_LOC_KEY,CURRENT_PAGE_LABEL_LOC_KEY,{
                  "quantity":m_pagingComponent.currentPageNumber + 1,
                  "maximum":m_pagingComponent.maxPageNumber + 1
               });
            }
            else
            {
               m_currentPageLabel.text = "";
            }
         }
      }
   }
}

