package Transactions.Quests
{
   public class TFullQuestRefresh extends TQuestActionBase
   {
      
      public function TFullQuestRefresh(questName:String = null, taskIndex:int = -1)
      {
         super(questName,taskIndex);
      }
      
      override public function perform() : void
      {
         signedCall("FarmQuestService.fullQuestRefresh");
      }
   }
}

