package Transactions
{
   import Classes.RewardCreditsBuilding;
   
   public class TCreditsPassNeighbor extends TWorldState
   {
      
      protected var m_neighborUid:String = "0";
      
      protected var m_building:RewardCreditsBuilding;
      
      public function TCreditsPassNeighbor(building:RewardCreditsBuilding, neighborUid:String)
      {
         this.m_neighborUid = neighborUid;
         this.m_building = building;
         super(building);
      }
      
      override public function perform() : void
      {
         signedWorldAction("createFriendRewardForPassing");
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result.hasOwnProperty("rewardUrl") && Boolean(result.rewardUrl))
         {
            this.m_building.showPassNeighborFeedPrompt(this.m_neighborUid,result.rewardUrl);
         }
      }
   }
}

