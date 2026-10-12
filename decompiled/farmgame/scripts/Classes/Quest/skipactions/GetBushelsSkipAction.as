package Classes.Quest.skipactions
{
   import Display.Quests.QuestProgressDialog;
   import Transactions.Quests.TSkipGetBushels;
   import Transactions.Quests.TSkipQuestTask;
   
   public class GetBushelsSkipAction extends ItemSkipAction
   {
      
      public function GetBushelsSkipAction(cost:int, questName:String, taskIndex:int, dialog:QuestProgressDialog, itemName:String)
      {
         super(cost,questName,taskIndex,dialog,itemName);
      }
      
      override protected function getTransaction() : TSkipQuestTask
      {
         return new TSkipGetBushels(m_questName,m_taskIndex,m_itemName);
      }
   }
}

