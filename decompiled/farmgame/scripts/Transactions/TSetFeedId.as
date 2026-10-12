package Transactions
{
   import Managers.FarmStatsManager;
   
   public class TSetFeedId extends TFarmTransaction
   {
      
      private var m_localFeedId:String = "";
      
      private var m_snFeedId:String = "";
      
      public function TSetFeedId(localFeedId:String, snFeedId:String)
      {
         this.m_localFeedId = localFeedId;
         this.m_snFeedId = snFeedId;
         super();
      }
      
      override public function perform() : void
      {
         FarmStatsManager.sample(100,"TSetFeedId","sendingTransaction",this.m_localFeedId,this.m_snFeedId);
         signedCall("FeedIdService.setFeedId",this.m_localFeedId,this.m_snFeedId);
      }
   }
}

