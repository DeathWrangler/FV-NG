package Widgets.Frames
{
   import Classes.Quest.FarmQuestSettingsInit;
   import Classes.ZItem.FarmItem;
   import Managers.FarmStatsManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.HalloweenUSARedeemSlot;
   import Widgets.Windows.HalloweenUSARedeemWindow;
   import ZQuest.Init.QuestSettingsInit;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class HalloweenUSARedeemFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String = null;
      
      private const PAGE_TF:String = "page_tf";
      
      private const BACK_BT:String = "back_bt";
      
      private const NEXT_BT:String = "next_bt";
      
      private const MAX_PAGE:int = 3;
      
      private var m_parentWindow:HalloweenUSARedeemWindow;
      
      public function HalloweenUSARedeemFrame(element:DisplayObject, featureName:String, parentWindow:HalloweenUSARedeemWindow)
      {
         this.m_featureName = featureName;
         this.m_parentWindow = parentWindow;
         m_slotData = [];
         super(element);
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
         this.refresh();
      }
      
      private function onPageBack(event:Event) : void
      {
         FarmStatsManager.count("RockPaperShivers","Market_UI","left_scroll");
         m_pagingComponent.onPageBack(event);
      }
      
      private function onPageForward(event:Event) : void
      {
         FarmStatsManager.count("RockPaperShivers","Market_UI","right_scroll");
         m_pagingComponent.onPageForward(event);
      }
      
      override public function refresh() : void
      {
         m_pagingComponent.maxPageNumber = calcMaxPageNumber();
         populateSlots(m_slots.length * m_pagingComponent.currentPageNumber);
         adjustPagingWidgetVisibility();
         m_currentPageLabel.text = "Page " + (m_pagingComponent.currentPageNumber + 1).toString() + " of " + (m_pagingComponent.maxPageNumber + 1).toString();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new HalloweenUSARedeemSlot(slotElement,this.m_featureName,this.m_parentWindow);
      }
      
      override protected function setupData() : void
      {
         var itemCode:String = null;
         var i:int = 0;
         var categoryItem:FarmItem = null;
         var itemList:Array = new Array();
         var questInit:FarmQuestSettingsInit = QuestSettingsInit.getInstance() as FarmQuestSettingsInit;
         var itemCodesInCategory:Array = questInit.getItemCodesInCategory(this.m_parentWindow.category);
         for each(itemCode in itemCodesInCategory)
         {
            categoryItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            if(categoryItem != null && categoryItem.isVisible && categoryItem.checkPurchasePrereqs())
            {
               itemList.push(categoryItem.code);
            }
         }
         for(i = 0; i < itemList.length; i++)
         {
            m_slotData.push({
               "rewardSlotNumber":i,
               "rewardCode":itemList[i]
            });
         }
      }
   }
}

