package Transactions
{
   import Cache.Classes.ZCacheUtil;
   import Classes.util.FacebookSocialNetwork;
   
   public class TSocialCharityAction extends TransactionWithCallBack
   {
      
      private var m_source:String;
      
      public function TSocialCharityAction(callback:Function, featureName:String, source:String)
      {
         super("SocialCharityService.postFeed",callback,featureName,source);
         this.m_source = source;
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("feedData"))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(result.feedData,ZCacheUtil.applyPartial(this.handleFeedPostReturn,this,[result]));
         }
         else
         {
            super.onComplete(result);
         }
      }
      
      private function handleFeedPostReturn(result:Object, success:Boolean) : void
      {
         if(result == null)
         {
            result = {};
         }
         result.postSuccessful = success;
         super.onComplete(result);
      }
   }
}

