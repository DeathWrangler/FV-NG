package Transactions.Quests
{
   import Classes.Quest.FarmQuestManager;
   
   public class TReplayQuestChapter extends TQuestActionBase
   {
      
      public function TReplayQuestChapter(lastQuestName:String)
      {
         super(lastQuestName);
      }
      
      override public function perform() : void
      {
         signedCall("FarmQuestService.userResetQuestChapter",m_questName);
      }
      
      override protected function onComplete(result:Object) : void
      {
         FarmQuestManager.getInstance().onResetLastCompletedQuestChapter();
      }
   }
}

