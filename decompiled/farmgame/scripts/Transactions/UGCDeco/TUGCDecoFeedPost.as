package Transactions.UGCDeco
{
   import Cache.Classes.ZCacheUtil;
   import Classes.util.FacebookSocialNetwork;
   import Managers.UGCDecoManager;
   import Transactions.TransactionWithCallBack;
   
   public class TUGCDecoFeedPost extends TransactionWithCallBack
   {
      
      private var m_source:String;
      
      public function TUGCDecoFeedPost(callback:Function, itemCode:String, source:String, friendReward:String, featureName:String)
      {
         super("UGCDecoService.postFeed",callback,itemCode,source,friendReward,featureName);
         this.m_source = source;
         UGCDecoManager.instance.lockUGCDecoFeedPost(source);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("feedData"))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(result.feedData,ZCacheUtil.applyPartial(this.handleFeedPostReturn,this,[result]));
         }
         else
         {
            UGCDecoManager.instance.unlockUGCDecoFeedPost(this.m_source);
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
            UGCDecoManager.instance.setAskThrottle(this.m_source);
         }
         UGCDecoManager.instance.unlockUGCDecoFeedPost(this.m_source);
         super.onComplete(result);
      }
   }
}

