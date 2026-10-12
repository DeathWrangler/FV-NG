package Transactions.Quests
{
   public class TKillQuest extends TQuestActionBase
   {
      
      public function TKillQuest(questName:String)
      {
         super(questName);
      }
      
      override public function perform() : void
      {
         signedCall("FarmQuestService.userKillQuest",m_questName);
      }
   }
}

