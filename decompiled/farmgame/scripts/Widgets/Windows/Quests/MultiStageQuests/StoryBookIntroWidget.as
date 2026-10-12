package Widgets.Windows.Quests.MultiStageQuests
{
   import Classes.Quest.FarmQuest;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import ZQuest.Init.QuestSettingsInit;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class StoryBookIntroWidget extends StageIntroWidget
   {
      
      private var m_chapterIcon:FarmIcon;
      
      private var m_currentQuest:FarmQuest;
      
      public function StoryBookIntroWidget(element:DisplayObject, quest:FarmQuest, parentWindow:FarmWindow, stage:int)
      {
         super(element,quest,parentWindow,stage);
         this.m_currentQuest = m_farmQuest;
         if(isStoryBookActive(quest.chain))
         {
            this.updateArrowVisibility();
            if(m_element.icon_mc != null)
            {
               this.m_chapterIcon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
               this.loadChapterIcon(m_farmQuest);
            }
            if(m_farmQuest.introSeenFlag == "")
            {
               this.showPreviousChapter();
            }
         }
      }
      
      private function onLeftArrowClick(event:MouseEvent) : void
      {
         if(this.m_currentQuest.previousChapter != "")
         {
            FarmStatsManager.count("dialog",m_farmQuest.name,"book","appeared","openbook");
         }
         this.showPreviousChapter();
      }
      
      private function onRightArrowClick(event:MouseEvent) : void
      {
         if(this.m_currentQuest.nextChapter != "")
         {
            FarmStatsManager.count("dialog",m_farmQuest.name,"book","appeared","openbook");
         }
         this.showNextChapter();
      }
      
      private function showNextChapter() : void
      {
         var nextQuestChapter:FarmQuest = null;
         if(this.m_currentQuest.nextChapter != "")
         {
            nextQuestChapter = QuestSettingsInit.getInstance().getItemByName(this.m_currentQuest.nextChapter) as FarmQuest;
            if(nextQuestChapter.introSeenFlag != "")
            {
               if(this.shouldShowChapter(nextQuestChapter))
               {
                  m_introTitle.text = ZLocUtils.t("Quests",nextQuestChapter.textBundle + "_IntroTitle");
                  m_introBody.text = ZLocUtils.t("Quests",nextQuestChapter.textBundle + "_IntroBody");
                  m_acceptButton.text = ZLocUtils.t("Quests",nextQuestChapter.textBundle + "_IntroButton");
                  if(m_element.icon_mc != null)
                  {
                     this.loadChapterIcon(nextQuestChapter);
                  }
                  this.m_currentQuest = nextQuestChapter;
               }
            }
         }
         this.updateArrowVisibility();
      }
      
      private function showPreviousChapter() : void
      {
         var prevQuestChapter:FarmQuest = null;
         if(this.m_currentQuest.previousChapter != "")
         {
            prevQuestChapter = QuestSettingsInit.getInstance().getItemByName(this.m_currentQuest.previousChapter) as FarmQuest;
            if(prevQuestChapter.introSeenFlag != "")
            {
               m_introTitle.text = ZLocUtils.t("Quests",prevQuestChapter.textBundle + "_IntroTitle");
               m_introBody.text = ZLocUtils.t("Quests",prevQuestChapter.textBundle + "_IntroBody");
               m_acceptButton.text = ZLocUtils.t("Quests",prevQuestChapter.textBundle + "_IntroButton");
               if(m_element.icon_mc != null)
               {
                  this.loadChapterIcon(prevQuestChapter);
               }
               this.m_currentQuest = prevQuestChapter;
            }
         }
         this.updateArrowVisibility();
      }
      
      private function loadChapterIcon(quest:FarmQuest) : void
      {
         if(quest.chapterIcon != "")
         {
            this.m_chapterIcon.loadIcon(Global.getAssetURL(quest.chapterIcon));
         }
      }
      
      private function updateArrowVisibility() : void
      {
         var leftArrowButton:ZwBaseWidget = null;
         var rightArrowButton:ZwBaseWidget = null;
         var nextQuestChapter:FarmQuest = null;
         if(m_element.leftArrow_bt != null)
         {
            leftArrowButton = getWidget(m_element.leftArrow_bt);
            if(leftArrowButton == null)
            {
               leftArrowButton = addWidget(new FarmButton(m_element.leftArrow_bt,this.onLeftArrowClick)) as FarmButton;
            }
         }
         if(m_element.rightArrow_bt != null)
         {
            rightArrowButton = getWidget(m_element.rightArrow_bt);
            if(rightArrowButton == null)
            {
               rightArrowButton = addWidget(new FarmButton(m_element.rightArrow_bt,this.onRightArrowClick)) as FarmButton;
            }
         }
         if(leftArrowButton != null)
         {
            if(this.m_currentQuest.previousChapter != "")
            {
               leftArrowButton.visible = true;
            }
            else
            {
               leftArrowButton.visible = false;
            }
         }
         if(rightArrowButton != null)
         {
            if(this.m_currentQuest.nextChapter != "")
            {
               nextQuestChapter = QuestSettingsInit.getInstance().getItemByName(this.m_currentQuest.nextChapter) as FarmQuest;
               if(this.shouldShowChapter(nextQuestChapter))
               {
                  rightArrowButton.visible = true;
               }
               else
               {
                  rightArrowButton.visible = false;
               }
            }
            else
            {
               rightArrowButton.visible = false;
            }
         }
      }
      
      private function shouldShowChapter(questChapter:FarmQuest) : Boolean
      {
         return Global.player.getSeenFlag(questChapter.introSeenFlag) || questChapter.name == m_farmQuest.name || questChapter.timeRemaining == 0;
      }
   }
}

