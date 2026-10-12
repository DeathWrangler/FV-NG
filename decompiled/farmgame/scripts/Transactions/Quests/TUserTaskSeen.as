package Transactions.Quests
{
   public class TUserTaskSeen extends TQuestActionBase
   {
      
      public function TUserTaskSeen(questName:String)
      {
         super(questName);
      }
      
      override public function perform() : void
      {
         signedCall("FarmQuestService.markViewDialogTaskDone",m_questName);
      }
   }
}

