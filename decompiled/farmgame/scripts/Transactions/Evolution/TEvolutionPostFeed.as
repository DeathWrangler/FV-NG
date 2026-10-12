package Transactions.Evolution
{
   import Cache.Classes.ZCacheUtil;
   import Classes.util.FacebookSocialNetwork;
   import Managers.EvolutionManager;
   import Transactions.TransactionWithCallBack;
   
   public class TEvolutionPostFeed extends TransactionWithCallBack
   {
      
      private var m_source:String;
      
      public function TEvolutionPostFeed(callback:Function, source:String)
      {
         super("EvolutionService.postFeed",callback,source);
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
         if(success)
         {
            EvolutionManager.instance.setAskThrottle(this.m_source);
         }
         super.onComplete(result);
      }
   }
}

