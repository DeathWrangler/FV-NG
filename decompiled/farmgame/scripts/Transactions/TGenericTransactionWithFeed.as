package Transactions
{
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.FarmGameUtil;
   
   public class TGenericTransactionWithFeed extends TGenericTransaction
   {
      
      public function TGenericTransactionWithFeed(serviceName:String, serviceFunctionName:String, callback:Function = null, parameters:Array = null)
      {
         super(serviceName,serviceFunctionName,callback,parameters);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("feedData"))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(result.feedData,this.generateFeedCallback(result));
         }
         else
         {
            super.onComplete(result);
         }
      }
      
      private function generateFeedCallback(transactionResult:Object) : Function
      {
         return function(feedPostingResult:Boolean):void
         {
            if(transactionResult == null)
            {
               transactionResult = {};
            }
            transactionResult.postSuccessful = feedPostingResult;
            if(Boolean(feedPostingResult) && Boolean(transactionResult.feedData) && Boolean(transactionResult.feedData.hasOwnProperty("frequencyFlag")))
            {
               Global.player.setFeatureLastShown(transactionResult.feedData.frequencyFlag,Math.floor(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND),true);
            }
            feedCallbackHelper(transactionResult);
         };
      }
      
      private function feedCallbackHelper(result:Object) : void
      {
         super.onComplete(result);
      }
   }
}

