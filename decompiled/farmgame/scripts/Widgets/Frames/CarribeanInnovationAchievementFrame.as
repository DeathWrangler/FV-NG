package Widgets.Frames
{
   import Managers.FarmStatsManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.CarribeanInnovationAchievementSlot;
   import Widgets.Windows.CarribeanInnovationAchievementWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class CarribeanInnovationAchievementFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String = null;
      
      private const PAGE_TF:String = "page_tf";
      
      private const BACK_BT:String = "back_bt";
      
      private const NEXT_BT:String = "next_bt";
      
      private const MAX_PAGE:int = 3;
      
      private var m_parentWindow:CarribeanInnovationAchievementWindow;
      
      public function CarribeanInnovationAchievementFrame(element:DisplayObject, featureName:String, parentWindow:CarribeanInnovationAchievementWindow)
      {
         this.m_featureName = featureName;
         this.m_parentWindow = parentWindow;
         super(element);
         m_pagingComponent.maxPageNumber = this.MAX_PAGE;
         if(m_element[this.PAGE_TF])
         {
            m_currentPageLabel = new ZwTextField(m_element[this.PAGE_TF],"Page 1 of " + m_pagingComponent.maxPageNumber);
            addWidget(m_currentPageLabel);
         }
         if(m_element[this.BACK_BT] != null)
         {
            m_pageBackWidget = new ZwButton(m_element[this.BACK_BT],this.onPageBack);
            addWidget(m_pageBackWidget);
            if(m_pagingComponent.currentPageNumber == 0)
            {
               m_pageBackWidget.visible = false;
            }
         }
         if(m_element[this.NEXT_BT] != null)
         {
            m_pageForwardWidget = new ZwButton(m_element[this.NEXT_BT],this.onPageForward);
            addWidget(m_pageForwardWidget);
         }
      }
      
      private function onPageBack(event:Event) : void
      {
         FarmStatsManager.count("CarribeanInnovation","Achivement_UI","left_scroll");
         m_pagingComponent.onPageBack(event);
      }
      
      private function onPageForward(event:Event) : void
      {
         FarmStatsManager.count("CarribeanInnovation","Achivement_UI","right_scroll");
         m_pagingComponent.onPageForward(event);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CarribeanInnovationAchievementSlot(slotElement,this.m_featureName,this.m_parentWindow);
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
      
      override protected function setupData() : void
      {
         m_slotData = [];
         for(var i:int = 0; i < 4; i++)
         {
            m_slotData.push({"rewardSlotNumber":i});
         }
      }
   }
}

