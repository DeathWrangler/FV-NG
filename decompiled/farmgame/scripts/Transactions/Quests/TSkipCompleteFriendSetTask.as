package Transactions.Quests
{
   public class TSkipCompleteFriendSetTask extends TSkipQuestTask
   {
      
      public function TSkipCompleteFriendSetTask(questName:String, taskIndex:int)
      {
         super(questName,taskIndex);
      }
      
      override public function perform() : void
      {
         signedCall("FarmQuestService.skipCompleteFriendSetTask",m_questName,m_taskIndex);
      }
   }
}

