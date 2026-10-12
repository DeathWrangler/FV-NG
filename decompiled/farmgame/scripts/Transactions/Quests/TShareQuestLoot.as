package Transactions.Quests
{
   import Widgets.Interfaces.IQuestRewardView;
   
   public class TShareQuestLoot extends TQuestActionBase
   {
      
      private var m_shouldGenerateFriendReward:Boolean = false;
      
      private var m_rewardDialog:IQuestRewardView = null;
      
      public function TShareQuestLoot(questName:String, shouldGenerateFriendReward:Boolean, rewardDialog:IQuestRewardView)
      {
         super(questName,0);
         this.m_shouldGenerateFriendReward = shouldGenerateFriendReward;
         this.m_rewardDialog = rewardDialog;
      }
      
      override public function perform() : void
      {
         signedCall("FarmQuestService.updateRecentlyCompletedQuests",m_questName,this.m_shouldGenerateFriendReward);
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         if(result["friendReward"] != null)
         {
            this.m_rewardDialog.postRewardFeed(result["friendReward"]);
         }
      }
   }
}

