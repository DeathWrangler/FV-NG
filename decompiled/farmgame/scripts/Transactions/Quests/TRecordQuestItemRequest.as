package Transactions.Quests
{
   public class TRecordQuestItemRequest extends TQuestActionBase
   {
      
      private var m_timeRequestedAt:String = "";
      
      public function TRecordQuestItemRequest(questName:String, taskIndex:int, timeRequestedAt:String)
      {
         super(questName,taskIndex);
         this.m_timeRequestedAt = timeRequestedAt;
      }
      
      override public function perform() : void
      {
         signedCall("FarmQuestService.recordQuestItemRequest",m_questName,m_taskIndex,this.m_timeRequestedAt);
      }
   }
}

