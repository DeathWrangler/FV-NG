package Transactions
{
   import Transactions.Quests.TQuestActionBase;
   
   public class TMarkQuestAsViewed extends TQuestActionBase
   {
      
      public function TMarkQuestAsViewed(questName:String)
      {
         super(questName,0);
      }
      
      override public function perform() : void
      {
         signedCall("FarmQuestService.interactedWithQuest",m_questName);
      }
   }
}

