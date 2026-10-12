package Transactions.Quests
{
   import Classes.Quest.helperactions.AskForItemByFeedHelperAction;
   import Managers.FarmStatsManager;
   
   public class TAskForQuestItem extends TQuestActionBase
   {
      
      private var m_helperAction:AskForItemByFeedHelperAction = null;
      
      private var m_statsSampleRate:int = 100;
      
      public function TAskForQuestItem(helperAction:AskForItemByFeedHelperAction, questName:String, taskIndex:int)
      {
         super(questName,taskIndex);
         this.m_helperAction = helperAction;
         this.m_statsSampleRate = parseInt(GlobalEngine.getFlashVar("QUEST_FEED_STATS_SAMPLE") as String);
      }
      
      override public function perform() : void
      {
         signedCall("FarmQuestService.askForQuestItem",m_questName,m_taskIndex);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result != null) && Boolean(result.data) && Boolean(result.ts))
         {
            FarmStatsManager.sample(this.m_statsSampleRate,"quest_feed_post","txn1","complete","feeddata_rcvd",m_questName);
            this.m_helperAction.postFeed(result);
         }
         else
         {
            FarmStatsManager.sample(this.m_statsSampleRate,"quest_feed_post","errors","txn1","invalid_feeddata",m_questName);
         }
      }
   }
}

