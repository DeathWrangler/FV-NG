package Widgets.Frames
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.SubscriberWalletManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.SubscriberWalletRewardCollectionNewRewardSlot;
   import flash.display.DisplayObject;
   
   public class SubscriberWalletRewardCollectionNewRewardsFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String = null;
      
      private const PAGE_TF:String = "page_tf";
      
      private const BACK_BT:String = "leftArrow_1_bt";
      
      private const NEXT_BT:String = "rightArrow_1_bt";
      
      private const MAX_PAGE:int = 3;
      
      public function SubscriberWalletRewardCollectionNewRewardsFrame(element:DisplayObject, featureName:String)
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
            m_pageForwardWidget.visible = m_slotData.length != 0;
         }
      }
      
      override protected function setupData() : void
      {
         var banner:ZwTextField = null;
         m_slotData = SubscriberWalletManager.getInstance().getNewRewardsArray();
         if(m_slotData.length == 0 && m_element.hasOwnProperty("banner_tf"))
         {
            banner = new ZwTextField(m_element["banner_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_newRewardsPlaceholder"));
            banner.visible = true;
         }
      }
      
      override protected function getSlotPrefix() : String
      {
         return "new_";
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new SubscriberWalletRewardCollectionNewRewardSlot(slotElement,this.m_featureName,this);
      }
   }
}

