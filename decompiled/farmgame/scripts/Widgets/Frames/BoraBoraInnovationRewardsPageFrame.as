package Widgets.Frames
{
   import Classes.ZItem.FarmItem;
   import Managers.OrderBoard.BoraBoraInnovationManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.BoraBoraInnovationRewardsPageSlot;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class BoraBoraInnovationRewardsPageFrame extends FarmSlotContainerFrame
   {
      
      private static const FEATURE_NAME:String = "BoraBoraInnovation";
      
      private var m_featureName:String;
      
      private var m_TotalPages:uint;
      
      private var m_page_tf:ZwTextField;
      
      private var m_totalStars:int;
      
      public function BoraBoraInnovationRewardsPageFrame(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         this.m_totalStars = this.manager.getTotalStars();
         super(element);
         if(m_element.hasOwnProperty("left_btn_mc"))
         {
            m_pageBackWidget = addWidget(new ZwButton(m_element["left_btn_mc"],this.onPageBack)) as ZwButton;
            if(m_pagingComponent.currentPageNumber == 0)
            {
               m_pageBackWidget.visible = false;
            }
         }
         if(m_element.hasOwnProperty("right_btn_mc"))
         {
            m_pageForwardWidget = addWidget(new ZwButton(m_element["right_btn_mc"],this.onPageForward)) as ZwButton;
         }
         if(m_element.hasOwnProperty("page_count_tf"))
         {
            this.m_page_tf = addWidget(new ZwTextField(m_element["page_count_tf"],"")) as ZwTextField;
            this.m_page_tf.visible = true;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new BoraBoraInnovationRewardsPageSlot(slotElement,this.m_featureName,this.m_totalStars);
      }
      
      override protected function setupData() : void
      {
         var starCount:int = 0;
         var rewardItem:FarmItem = null;
         var rewards:Array = this.manager.getMilestoneRewards();
         for(var i:int = 0; i < rewards.length; i++)
         {
            starCount = this.manager.getStarsForMilestoneReward(i);
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(rewards[i]);
            m_slotData.push({
               "iconUrl":rewardItem.iconUrl,
               "thumbsUp":starCount,
               "rewardName":rewardItem.friendlyTitle
            });
         }
      }
      
      public function onPageBack(event:Event) : void
      {
         if(m_pagingComponent.currentPageNumber > 0)
         {
            --m_pagingComponent.currentPageNumber;
         }
         this.conditionOnPagination();
         this.setPagination();
      }
      
      public function onPageForward(event:Event) : void
      {
         if(m_pagingComponent.currentPageNumber < m_pagingComponent.maxPageNumber)
         {
            m_pagingComponent.currentPageNumber += 1;
         }
         this.conditionOnPagination();
         this.setPagination();
      }
      
      private function conditionOnPagination() : void
      {
         if(m_pagingComponent.currentPageNumber == m_pagingComponent.maxPageNumber)
         {
            m_pageForwardWidget.visible = false;
         }
         else
         {
            m_pageForwardWidget.visible = true;
         }
      }
      
      public function getTotalPages() : uint
      {
         m_pagingComponent.maxPageNumber = int(m_slotData.length / totalSlots());
         if(m_slotData.length % totalSlots() != 0)
         {
            m_pagingComponent.maxPageNumber += 1;
         }
         return m_pagingComponent.maxPageNumber;
      }
      
      public function setPagination() : void
      {
         this.m_TotalPages = this.getTotalPages();
         if(this.m_page_tf)
         {
            this.m_page_tf.text = m_pagingComponent.currentPageNumber + 1 + " " + "of" + " " + this.m_TotalPages;
         }
      }
      
      private function get manager() : BoraBoraInnovationManager
      {
         return BoraBoraInnovationManager.getInstance(FEATURE_NAME);
      }
   }
}

