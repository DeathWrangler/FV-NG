package Classes.Quest.helperactions
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestSettingsInit;
   import ZQuest.Init.QuestSettingsInit;
   
   public class OpenChapterQuestHelperAction extends QuestHelperAction
   {
      
      private var m_chapterQuestName:String = null;
      
      public function OpenChapterQuestHelperAction(questName:String, chapterQuestName:String)
      {
         this.m_chapterQuestName = chapterQuestName;
         super(questName);
      }
      
      override public function perform() : void
      {
         super.perform();
         var quest:FarmQuest = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getQuestItemByName(this.m_chapterQuestName);
         if(quest)
         {
            quest.showProgress();
         }
      }
   }
}

