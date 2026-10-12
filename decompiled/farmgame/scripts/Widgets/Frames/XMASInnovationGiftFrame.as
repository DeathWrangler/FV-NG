package Widgets.Frames
{
   import Managers.XMASInnovationManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.XMASInnovationGiftSlot;
   import flash.display.DisplayObject;
   
   public class XMASInnovationGiftFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String = null;
      
      private const PAGE_TF:String = "page_tf";
      
      private const BACK_BT:String = "back_bt";
      
      private const NEXT_BT:String = "next_bt";
      
      private const MAX_PAGE:int = 3;
      
      public function XMASInnovationGiftFrame(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         super(element);
         m_pagingComponent.maxPageNumber = this.MAX_PAGE;
         if(m_element[this.PAGE_TF])
         {
            m_currentPageLabel = new ZwTextField(m_element[this.PAGE_TF],"Page 1 of " + m_pagingComponent.maxPageNumber);
            addWidget(m_currentPageLabel);
         }
         if(m_element[this.BACK_BT] != null)
         {
            m_pageBackWidget = new ZwButton(m_element[this.BACK_BT],m_pagingComponent.onPageBack);
            addWidget(m_pageBackWidget);
            if(m_pagingComponent.currentPageNumber == 0)
            {
               m_pageBackWidget.visible = false;
            }
         }
         if(m_element[this.NEXT_BT] != null)
         {
            m_pageForwardWidget = new ZwButton(m_element[this.NEXT_BT],m_pagingComponent.onPageForward);
            addWidget(m_pageForwardWidget);
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new XMASInnovationGiftSlot(slotElement,this.m_featureName,this);
      }
      
      override protected function setupData() : void
      {
         var XMASInnovationSlotData:Object = XMASInnovationManager.getInstance().RewardsList;
         for(var i:int = 0; i < XMASInnovationSlotData.length; i++)
         {
            m_slotData.push({
               "rewardItemName":XMASInnovationSlotData[i],
               "slotIndex":i
            });
         }
      }
   }
}

