package Classes.Quest.skipactions
{
   import Display.Quests.QuestProgressDialog;
   import Transactions.Quests.TSkipExpandStorageBuilding;
   import Transactions.Quests.TSkipQuestTask;
   
   public class ExpandStorageBuildingSkipAction extends ItemSkipAction
   {
      
      public function ExpandStorageBuildingSkipAction(cost:int, questName:String, taskIndex:int, dialog:QuestProgressDialog, itemName:String)
      {
         super(cost,questName,taskIndex,dialog,itemName);
      }
      
      override protected function getTransaction() : TSkipQuestTask
      {
         return new TSkipExpandStorageBuilding(m_questName,m_taskIndex,m_itemName);
      }
   }
}

