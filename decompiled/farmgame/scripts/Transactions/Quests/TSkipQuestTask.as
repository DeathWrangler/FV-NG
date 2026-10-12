package Transactions.Quests
{
   public class TSkipQuestTask extends TQuestActionBase
   {
      
      public static const METHOD_SKIP_TASK:String = "skipTask";
      
      public function TSkipQuestTask(questName:String, taskIndex:int)
      {
         super(questName,taskIndex);
      }
      
      override public function perform() : void
      {
         signedCall("FarmQuestService." + METHOD_SKIP_TASK,m_questName,m_taskIndex);
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = METHOD_SKIP_TASK;
         result.questName = m_questName;
         result.taskIndex = m_taskIndex;
         return result;
      }
   }
}

