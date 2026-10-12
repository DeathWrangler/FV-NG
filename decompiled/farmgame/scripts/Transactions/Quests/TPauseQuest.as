package Transactions.Quests
{
   public class TPauseQuest extends TQuestActionBase
   {
      
      public function TPauseQuest(questName:String)
      {
         super(questName);
      }
      
      override public function perform() : void
      {
         signedCall("FarmQuestService.userPauseQuest",m_questName);
      }
   }
}

