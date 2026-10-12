package Classes.Quest
{
   import Classes.util.FarmGameUtil;
   import ZQuest.Init.QuestSettingsInit;
   
   public class ReplayableFarmQuestData
   {
      
      public static const COMPLETION_COUNT:String = "completion_count";
      
      public static const COMPLETION_DATE:String = "completion_date";
      
      public static const MEM_STORE_ID:String = "memStoreId";
      
      public static const HIDE_FROM_QUEST_MANAGER_COMPLETE:String = "hideFromQuestManagerComplete";
      
      private var m_memStoreId:String;
      
      private var m_mostRecentlyCompletedDate:Date = null;
      
      private var m_numTimesCompleted:int;
      
      private var m_questName:String = null;
      
      private var m_hideFromQuestManagerComplete:Boolean;
      
      public function ReplayableFarmQuestData(questData:Object)
      {
         var questSettingsInit:QuestSettingsInit = null;
         super();
         if(questData[MEM_STORE_ID])
         {
            this.m_memStoreId = questData[MEM_STORE_ID];
            questSettingsInit = QuestSettingsInit.getInstance();
            this.m_questName = questSettingsInit.getQuestNameFromMemStoreIdAndAddToCache(this.m_memStoreId);
         }
         if(questData[COMPLETION_DATE])
         {
            this.m_mostRecentlyCompletedDate = new Date(questData[COMPLETION_DATE] * FarmGameUtil.NUM_MSECS_IN_SECOND);
         }
         if(questData[COMPLETION_COUNT])
         {
            this.m_numTimesCompleted = questData[COMPLETION_COUNT];
         }
         if(questData[HIDE_FROM_QUEST_MANAGER_COMPLETE])
         {
            this.m_hideFromQuestManagerComplete = questData[HIDE_FROM_QUEST_MANAGER_COMPLETE];
         }
      }
      
      public function get memStoreId() : String
      {
         return this.m_memStoreId;
      }
      
      public function get questName() : String
      {
         return this.m_questName;
      }
      
      public function get hideFromQuestManagerComplete() : Boolean
      {
         return this.m_hideFromQuestManagerComplete;
      }
      
      public function get mostRecentlyCompletedDate() : Date
      {
         return this.m_mostRecentlyCompletedDate;
      }
      
      public function get numTimesCompleted() : int
      {
         return this.m_numTimesCompleted;
      }
   }
}

