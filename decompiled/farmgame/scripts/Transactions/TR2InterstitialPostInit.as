package Transactions
{
   import Managers.Requests2InterstitialManager;
   
   public class TR2InterstitialPostInit extends TFarmTransaction
   {
      
      public function TR2InterstitialPostInit()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.r2InterstitialPostInit");
      }
      
      override protected function onComplete(result:Object) : void
      {
         Requests2InterstitialManager.hookZMCPostInit();
         if(result.hasOwnProperty("r2InterstitialItems"))
         {
            Requests2InterstitialManager.requestItems = result.r2InterstitialItems;
         }
         if(result.hasOwnProperty("r2InterstitialFeedItems"))
         {
            Requests2InterstitialManager.feedItems = result.r2InterstitialFeedItems;
         }
         if(result.hasOwnProperty("r2InterstitialMinigameIndex"))
         {
            Requests2InterstitialManager.minigameIndex = result.r2InterstitialMinigameIndex;
         }
         if(result.hasOwnProperty("r2InterstitialTypeIndex") && result.r2InterstitialTypeIndex != null)
         {
            if(result.hasOwnProperty("r2InterstitialFriendCount") && result.r2InterstitialFriendCount != null)
            {
               Requests2InterstitialManager.conditionallyDisplayR2Interstitial(result.r2InterstitialTypeIndex,result.r2InterstitialFriendCount);
            }
         }
         if(Boolean(result.numRecentlyPlayedFriends > 0) && Boolean(result.recentlyPlayedFriendInfo) && result.recentlyPlayedFriendInfo.length > 0)
         {
            Requests2InterstitialManager.addHUDIcon(result.numRecentlyPlayedFriends,result.recentlyPlayedFriendInfo);
            Requests2InterstitialManager.recentlyPlayedFriendsCount = result.numRecentlyPlayedFriends;
         }
      }
   }
}

