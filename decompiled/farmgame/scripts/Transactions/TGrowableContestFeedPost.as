package Transactions
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Growable.GrowableConstants;
   import Classes.util.FacebookSocialNetwork;
   
   public class TGrowableContestFeedPost extends TransactionWithCallBack
   {
      
      private var m_source:String;
      
      private var m_targetId:String;
      
      private var m_storageKey:String;
      
      public function TGrowableContestFeedPost(callback:Function, contestId:String, source:String, targetId:String = null, storageKey:String = null)
      {
         this.m_source = source;
         this.m_targetId = targetId;
         this.m_storageKey = storageKey;
         super(GrowableConstants.SERVICE_GROWABLE_CONTEST + ".performPublishUserAction",callback,contestId,source,this.m_targetId,this.m_storageKey);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("feedData"))
         {
            if(this.m_targetId)
            {
               result["feedData"]["targetId"] = this.m_targetId;
            }
            if(this.m_storageKey)
            {
               result["feedData"]["storageKey"] = this.m_storageKey;
            }
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

