package Transactions.CaptureFeatures
{
   import Cache.Classes.ZCacheUtil;
   import Classes.util.FacebookSocialNetwork;
   import Managers.CaptureFeatureManager;
   import Transactions.TransactionWithCallBack;
   
   public class TCaptureFeatureAskForTreats extends TransactionWithCallBack
   {
      
      private var m_source:String;
      
      private var m_featureName:String;
      
      public function TCaptureFeatureAskForTreats(callback:Function, featureName:String, source:String)
      {
         super("CaptureFeatureService.postFeed",callback,featureName,source);
         this.m_source = source;
         this.m_featureName = featureName;
         CaptureFeatureManager.instance.lockAskForTreats(this.m_featureName,source);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("feedData"))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(result.feedData,ZCacheUtil.applyPartial(this.handleFeedPostReturn,this,[result]));
         }
         else
         {
            CaptureFeatureManager.instance.unlockAskForTreats(this.m_featureName,this.m_source);
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
            CaptureFeatureManager.instance.setAskThrottle(this.m_featureName,this.m_source);
         }
         CaptureFeatureManager.instance.unlockAskForTreats(this.m_featureName,this.m_source);
         super.onComplete(result);
      }
   }
}

