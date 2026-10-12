package Transactions
{
   public class TCancelFriendReward extends TFarmTransaction
   {
      
      private var m_rewardUrls:Array = null;
      
      public function TCancelFriendReward(rewardUrls:Array)
      {
         this.m_rewardUrls = rewardUrls;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.conditionallyRemoveFriendRewards",this.m_rewardUrls);
      }
   }
}

