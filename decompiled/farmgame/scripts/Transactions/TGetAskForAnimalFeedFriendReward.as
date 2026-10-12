package Transactions
{
   import Classes.FeedTroughBuilding;
   
   public class TGetAskForAnimalFeedFriendReward extends TWorldState
   {
      
      private var m_trough:FeedTroughBuilding;
      
      public function TGetAskForAnimalFeedFriendReward(trough:FeedTroughBuilding)
      {
         super(trough);
         this.m_trough = trough;
      }
      
      override public function perform() : void
      {
         signedWorldAction("getAskForFeedFriendReward");
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         if(result != null)
         {
            result["feedImg"] = this.getFeedImage();
            result["bundle"] = this.getBundleName();
            this.m_trough.displayAskForMoreFeed(result);
         }
      }
      
      protected function getFeedImage() : String
      {
         return "assets/newsfeed/feedtroughempty.png";
      }
      
      protected function getBundleName() : String
      {
         return "FeedTroughBuildingAskForMore";
      }
   }
}

