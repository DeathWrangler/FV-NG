package Transactions.Quests
{
   import Transactions.TFarmTransaction;
   
   public class TShareWorldScoreLevelUpReward extends TFarmTransaction
   {
      
      private var m_scoreUnit:String = null;
      
      private var m_scoreLevel:int = 0;
      
      private var m_shouldGenerateFriendReward:Boolean = false;
      
      private var m_callback:Function = null;
      
      public function TShareWorldScoreLevelUpReward(scoreUnit:String, scoreLevel:int, shouldGenerateFriendReward:Boolean, callback:Function)
      {
         super();
         this.m_scoreUnit = scoreUnit;
         this.m_scoreLevel = scoreLevel;
         this.m_shouldGenerateFriendReward = shouldGenerateFriendReward;
         this.m_callback = callback;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.updateRecentlyCompletedWorldScoreLevel",this.m_scoreUnit,this.m_scoreLevel,this.m_shouldGenerateFriendReward);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var rewardLink:String = null;
         if(result.hasOwnProperty("rewardLink") && result["rewardLink"] != null)
         {
            rewardLink = result["rewardLink"];
         }
         if(this.m_callback != null)
         {
            this.m_callback(this.m_scoreUnit,this.m_scoreLevel,rewardLink);
         }
      }
   }
}

