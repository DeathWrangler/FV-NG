package Transactions
{
   import Classes.FeedTroughBuilding;
   import Widgets.Windows.FeedTrough.FeedTroughWindow;
   
   public class TGetMissedAnimalFriendReward extends TGetAskForAnimalFeedFriendReward
   {
      
      public function TGetMissedAnimalFriendReward(trough:FeedTroughBuilding)
      {
         super(trough);
      }
      
      override public function perform() : void
      {
         signedWorldAction("getMissedAnimalFeedFriendReward");
      }
      
      override protected function getFeedImage() : String
      {
         return FeedTroughWindow.FAIL_FEED_IMG;
      }
      
      override protected function getBundleName() : String
      {
         return "FeedTroughBuildingShareFailure";
      }
   }
}

