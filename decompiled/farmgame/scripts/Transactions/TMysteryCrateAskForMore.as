package Transactions
{
   import Cache.Classes.ZCacheUtil;
   import Classes.MysteryCrateBuilding;
   import Classes.util.FacebookSocialNetwork;
   
   public class TMysteryCrateAskForMore extends TWorldState
   {
      
      public static const ACTION_REQUEST_PART:String = "RequestExpansionPart";
      
      public static const ACTION_UPDATE_VIRAL_TIME:String = "UpdateViralTime";
      
      protected var m_partName:String;
      
      protected var m_isFeed:Boolean = true;
      
      public function TMysteryCrateAskForMore(mysteryCrate:MysteryCrateBuilding, partName:String, isFeed:Boolean, callback:Function)
      {
         this.m_partName = partName;
         this.m_isFeed = isFeed;
         super(mysteryCrate);
      }
      
      override public function perform() : void
      {
         if(this.m_isFeed)
         {
            signedWorldAction(ACTION_REQUEST_PART,this.m_partName);
         }
         else
         {
            signedWorldAction(ACTION_UPDATE_VIRAL_TIME);
         }
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result) && Boolean(result.hasOwnProperty("feedData")) && this.m_isFeed)
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

