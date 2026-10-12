package Widgets.Frames
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Managers.FarmStatsManager;
   import Managers.JournalManager;
   import Widgets.Buttons.FarmButton;
   import Widgets.Icons.FarmIcon;
   import ZQuest.Init.QuestSettingsInit;
   import com.adobe.utils.DictionaryUtil;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class JournalWindowFrameContainer extends FarmSlotContainerFrame
   {
      
      private static const ICON_X:int = 25;
      
      private static const ICON_Y:int = 25;
      
      private var m_bubbleImageContainer:FarmIcon = null;
      
      private var m_acceptBtn:FarmButton = null;
      
      private var m_manager:JournalManager = null;
      
      private var m_iconMC:FarmIcon = null;
      
      private var m_closeBt:FarmButton = null;
      
      public function JournalWindowFrameContainer(element:MovieClip)
      {
         super(element);
         this.m_manager = JournalManager.getInstance();
         if(m_element.close_bt)
         {
            this.m_closeBt = addWidget(new FarmButton(m_element.close_bt,this.onClose)) as FarmButton;
         }
         if(m_element.leftArrow_bt)
         {
            m_pageBackWidget = addWidget(new FarmButton(m_element.leftArrow_bt,this.onPageBack)) as FarmButton;
         }
         if(m_element.rightArrow_bt)
         {
            m_pageForwardWidget = addWidget(new FarmButton(m_element.rightArrow_bt,this.onPageForward)) as FarmButton;
         }
         if(m_element.first_bt)
         {
            m_pageFirstWidget = addWidget(new FarmButton(m_element.first_bt,this.onPageFirst)) as FarmButton;
         }
         if(m_element.last_bt)
         {
            m_pageLastWidget = addWidget(new FarmButton(m_element.last_bt,this.onPageLast)) as FarmButton;
         }
         if(m_element.hasOwnProperty("icon_mc"))
         {
            this.m_bubbleImageContainer = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         }
         if(m_element.hasOwnProperty("accept_bt"))
         {
            this.m_acceptBtn = addWidget(new FarmButton(m_element.accept_bt,this.onAccept)) as FarmButton;
            if(m_element.accept_bt.hasOwnProperty("icon1_mc"))
            {
               this.m_iconMC = addWidget(new FarmIcon(m_element.accept_bt.icon1_mc)) as FarmIcon;
            }
         }
         m_pagingComponent.maxPageNumber = DictionaryUtil.getKeys(this.m_manager.completedQuestBubble).length - 1;
         m_pagingComponent.currentPageNumber = m_pagingComponent.maxPageNumber;
      }
      
      private function onClose(event:Event) : void
      {
         FarmStatsManager.count(this.m_manager.featureName(),"Main UI","close");
         this.closeParentWindow();
      }
      
      private function onPageBack(event:Event) : void
      {
         FarmStatsManager.count(this.m_manager.featureName(),"Main UI","nav_left");
         m_pagingComponent.onPageBack(event);
      }
      
      private function onPageForward(event:Event) : void
      {
         FarmStatsManager.count(this.m_manager.featureName(),"Main UI","nav_right");
         m_pagingComponent.onPageForward(event);
      }
      
      private function onPageFirst(event:Event) : void
      {
         FarmStatsManager.count(this.m_manager.featureName(),"Main UI","nav_first_page");
         m_pagingComponent.onPageFirst(event);
      }
      
      private function onPageLast(event:Event) : void
      {
         FarmStatsManager.count(this.m_manager.featureName(),"Main UI","nav_last_page");
         m_pagingComponent.onPageLast(event);
      }
      
      private function onAccept(event:Event) : void
      {
         FarmStatsManager.count(this.m_manager.featureName(),"Main UI","play_quest_cta");
         var nextActiveQuest:FarmQuest = this.getNextActiveQuest();
         this.m_manager.hideUI();
         nextActiveQuest.showProgress();
      }
      
      private function getNextActiveQuest() : FarmQuest
      {
         var result:FarmQuest = null;
         var quest:FarmQuest = QuestSettingsInit.getInstance().getItemByName(this.m_manager.completedQuestBubble[m_pagingComponent.maxPageNumber]) as FarmQuest;
         if(quest)
         {
            while(true)
            {
               if(FarmQuestManager.getInstance().isQuestActive(quest.name))
               {
                  result = quest;
                  break;
               }
               if(!(quest.children.length > 0 && Boolean(quest.children[0])))
               {
                  break;
               }
               quest = QuestSettingsInit.getInstance().getItemByName(quest.children[0].value) as FarmQuest;
            }
         }
         return result;
      }
      
      private function resetNavigationButtons() : void
      {
         m_pageFirstWidget.enabled = true;
         m_pageBackWidget.enabled = true;
         m_pageForwardWidget.enabled = true;
         m_pageLastWidget.enabled = true;
         FarmButton(m_pageFirstWidget).applyGrayOut = false;
         FarmButton(m_pageBackWidget).applyGrayOut = false;
         FarmButton(m_pageForwardWidget).applyGrayOut = false;
         FarmButton(m_pageLastWidget).applyGrayOut = false;
      }
      
      private function resetPlayQuestButton() : void
      {
         this.m_acceptBtn.enabled = true;
         this.m_acceptBtn.visible = true;
         this.m_acceptBtn.applyGrayOut = false;
      }
      
      override public function refresh() : void
      {
         var quest:FarmQuest = null;
         if(m_pagingComponent != null)
         {
            this.resetNavigationButtons();
            this.resetPlayQuestButton();
            if(m_pagingComponent.isOnLastPage())
            {
               m_pageForwardWidget.enabled = false;
               m_pageLastWidget.enabled = false;
               FarmButton(m_pageLastWidget).applyGrayOut = true;
               FarmButton(m_pageForwardWidget).applyGrayOut = true;
            }
            if(m_pagingComponent.isOnFirstPage())
            {
               m_pageBackWidget.enabled = false;
               m_pageFirstWidget.enabled = false;
               FarmButton(m_pageBackWidget).applyGrayOut = true;
               FarmButton(m_pageFirstWidget).applyGrayOut = true;
            }
            quest = this.getNextActiveQuest();
            if(quest == null)
            {
               this.m_acceptBtn.enabled = false;
               this.m_acceptBtn.applyGrayOut = true;
            }
            else if(this.m_iconMC)
            {
               this.m_iconMC.loadIcon(quest.displayIcon);
               this.m_iconMC.setIconSize(ICON_X,ICON_Y);
            }
            this.m_bubbleImageContainer.loadIcon(this.getBubbleImageFromQuestName(this.m_manager.completedQuestBubble[m_pagingComponent.currentPageNumber]));
         }
      }
      
      private function getBubbleImageFromQuestName(questName:String) : String
      {
         var quest:FarmQuest = null;
         var result:String = null;
         if(questName != null)
         {
            quest = QuestSettingsInit.getInstance().getItemByName(questName) as FarmQuest;
            result = quest.bubbleImage;
         }
         return result;
      }
   }
}

