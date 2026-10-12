package Transactions
{
   import Cache.Classes.ZCacheUtil;
   import Classes.util.FacebookSocialNetwork;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureTrackingManager;
   import Managers.HolidayCountdownManager;
   
   public class THolidayCountdownPublishItemOfTheDayFeed extends TGenericTransaction
   {
      
      public function THolidayCountdownPublishItemOfTheDayFeed(index:int = -1, callback:Function = null)
      {
         super("HolidayCountdownService","publishItemOfTheDayFeed",callback,[index]);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("feedData"))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(result.feedData,ZCacheUtil.applyPartial(this.friendRewardCallback,this,[result]));
         }
         else
         {
            super.onComplete(result);
         }
      }
      
      private function friendRewardCallback(result:Object, success:Boolean) : void
      {
         if(result == null)
         {
            result = {};
         }
         result.postSuccessful = success;
         if(success)
         {
            TransactionManager.addTransaction(new TSetFeatureFrequencyTimestamp(HolidayCountdownManager.rewardType),true);
            FeatureTrackingManager.instance.postFeed(HolidayCountdownManager.getFeatureName());
         }
         super.onComplete(result);
      }
   }
}

