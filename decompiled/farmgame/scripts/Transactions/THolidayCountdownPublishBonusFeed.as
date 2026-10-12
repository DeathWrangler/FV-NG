package Transactions
{
   import Classes.util.FacebookSocialNetwork;
   
   public class THolidayCountdownPublishBonusFeed extends TGenericTransaction
   {
      
      public function THolidayCountdownPublishBonusFeed()
      {
         super("HolidayCountdownService","publishShareBonusFeed");
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("feedData"))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(result.feedData);
         }
         else
         {
            super.onComplete(result);
         }
      }
   }
}

