package Transactions
{
   import Classes.util.FacebookSocialNetwork;
   import Engine.Classes.WorldObject;
   
   public class TWorldObjectFeedTransaction extends TGenericWorldObjectTransaction
   {
      
      public function TWorldObjectFeedTransaction(worldObj:WorldObject, action:String, callback:Function, params:Array = null)
      {
         super(worldObj,action,callback,params);
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
            feedCallbackHelper(transactionResult);
         };
      }
      
      private function feedCallbackHelper(result:Object) : void
      {
         super.onComplete(result);
      }
   }
}

