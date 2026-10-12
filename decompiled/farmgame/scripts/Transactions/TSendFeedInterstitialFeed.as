package Transactions
{
   public class TSendFeedInterstitialFeed extends TFarmTransaction
   {
      
      private var m_itemCode:String;
      
      private var m_mfsType:String;
      
      private var m_callBack:Function;
      
      public function TSendFeedInterstitialFeed(itemCode:String, mfsType:String, callback:Function = null)
      {
         super();
         this.m_itemCode = itemCode;
         this.m_mfsType = mfsType;
         this.m_callBack = callback;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.postFeedInterstitialFeed",this.m_itemCode,this.m_mfsType);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result) && Boolean(result.feedData))
         {
            GlobalEngine.socialNetwork.streamPublishV2(result.feedData,null);
         }
         if(this.m_callBack != null)
         {
            this.m_callBack(result);
         }
      }
   }
}

