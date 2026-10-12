package Transactions.Quests
{
   import Transactions.TFarmTransaction;
   
   public class TQuestActionBase extends TFarmTransaction
   {
      
      protected static const NO_TASK:int = -1;
      
      protected var m_questName:String = "";
      
      protected var m_taskIndex:int = 0;
      
      public function TQuestActionBase(questName:String, taskIndex:int = -1)
      {
         super();
         this.m_questName = questName;
         this.m_taskIndex = taskIndex;
      }
   }
}

