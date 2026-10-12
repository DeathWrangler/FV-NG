package Widgets.Windows.QuestManager
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import flash.display.DisplayObject;
   
   public class QMWActiveQuestsSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_mainWindow:QuestManagerWindowV2 = null;
      
      protected var m_page:ZwTextField = null;
      
      public function QMWActiveQuestsSlotFrame(element:DisplayObject, mainWindow:QuestManagerWindowV2)
      {
         this.m_mainWindow = mainWindow;
         super(element);
         if(m_element.arrowUp_bt != null)
         {
            m_pageBackWidget = new ZwButton(m_element.arrowUp_bt,m_pagingComponent.onPageBack);
            addWidget(m_pageBackWidget);
         }
         if(m_element.arrowDown_bt != null)
         {
            m_pageForwardWidget = new ZwButton(m_element.arrowDown_bt,m_pagingComponent.onPageForward);
            addWidget(m_pageForwardWidget);
         }
      }
      
      override public function refresh() : void
      {
         m_pagingComponent.maxPageNumber = Math.max(0,m_slotData.length - m_slots.length);
         populateSlots(m_pagingComponent.currentPageNumber);
         adjustPagingWidgetVisibility();
         centerSlots();
      }
      
      override protected function setupSlots() : void
      {
         var slot:ZwSlotFrame = null;
         var slotIndex:int = 0;
         while(m_element[getSlotPrefix() + slotIndex + getSlotPostfix()])
         {
            slot = this.createSlot(m_element[getSlotPrefix() + slotIndex + getSlotPostfix()]);
            addWidget(slot,false);
            m_slots.push(slot);
            slotIndex++;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new QMWActiveQuestSlot(slotElement,this.m_mainWindow);
      }
      
      private function orderQuestEndDate(questNameA:String, questNameB:String) : int
      {
         var sort:int = 0;
         var farmQuestManager:FarmQuestManager = FarmQuestManager.getInstance();
         var questExpirationTimeA:Number = farmQuestManager.getActiveQuestByName(questNameA).expirationTime;
         var questExpirationTimeB:Number = farmQuestManager.getActiveQuestByName(questNameB).expirationTime;
         if(questExpirationTimeA < questExpirationTimeB)
         {
            sort = -1;
         }
         else if(questExpirationTimeA > questExpirationTimeB)
         {
            sort = 1;
         }
         return sort;
      }
      
      public function forceRefresh() : void
      {
         this.setupData();
         this.refresh();
      }
      
      override protected function setupData() : void
      {
         var quest:FarmQuest = null;
         var slotData:Array = new Array();
         for each(quest in this.m_mainWindow.activeQuestsStandard)
         {
            if(quest.displayIcon != FarmQuest.ICON_NONE)
            {
               slotData.push(quest.name);
            }
         }
         slotData.sort(this.orderQuestEndDate);
         this.m_slotData = slotData;
      }
   }
}

