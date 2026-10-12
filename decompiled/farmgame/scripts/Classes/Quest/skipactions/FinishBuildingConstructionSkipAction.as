package Classes.Quest.skipactions
{
   import Display.Quests.QuestProgressDialog;
   import Transactions.Quests.TSkipBuildingConstruction;
   import Transactions.Quests.TSkipQuestTask;
   
   public class FinishBuildingConstructionSkipAction extends ItemSkipAction
   {
      
      public function FinishBuildingConstructionSkipAction(cost:int, questName:String, taskIndex:int, dialog:QuestProgressDialog, itemName:String)
      {
         super(cost,questName,taskIndex,dialog,itemName);
      }
      
      override protected function getTransaction() : TSkipQuestTask
      {
         return new TSkipBuildingConstruction(m_questName,m_taskIndex);
      }
   }
}

