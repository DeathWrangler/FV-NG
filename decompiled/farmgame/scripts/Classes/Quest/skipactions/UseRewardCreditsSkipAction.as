package Classes.Quest.skipactions
{
   import Display.Quests.QuestProgressDialog;
   import Transactions.Quests.TSkipQuestTask;
   import Transactions.Quests.TSkipRewardCreditTask;
   
   public class UseRewardCreditsSkipAction extends ItemSkipAction
   {
      
      public function UseRewardCreditsSkipAction(cost:int, questName:String, taskIndex:int, dialog:QuestProgressDialog, itemName:String)
      {
         super(cost,questName,taskIndex,dialog,itemName);
      }
      
      override protected function getTransaction() : TSkipQuestTask
      {
         return new TSkipRewardCreditTask(m_questName,m_taskIndex);
      }
   }
}

