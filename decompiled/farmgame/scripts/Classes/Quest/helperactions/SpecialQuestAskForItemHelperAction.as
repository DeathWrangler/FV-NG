package Classes.Quest.helperactions
{
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   
   public class SpecialQuestAskForItemHelperAction extends AskForItemByFeedHelperAction
   {
      
      public function SpecialQuestAskForItemHelperAction(questName:String, itemName:String, actionCountKey:String, taskIndex:int)
      {
         super(questName,itemName,actionCountKey,taskIndex);
      }
      
      override public function perform() : void
      {
         if(!m_outstandingTransaction)
         {
            m_outstandingTransaction = true;
            TransactionManager.addTransaction(new TGenericTransaction("SpecialQuestService","askForItem",postFeed,[m_questName,m_taskIndex]),true);
         }
      }
   }
}

