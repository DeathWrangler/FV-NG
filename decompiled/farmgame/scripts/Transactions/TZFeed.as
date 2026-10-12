package Transactions
{
   public class TZFeed extends TFarmTransaction
   {
      
      private var m_feedPayload:String;
      
      public function TZFeed(feedPayload:String)
      {
         super();
         this.m_feedPayload = feedPayload;
      }
      
      override public function perform() : void
      {
         signedCall("ZFeedService.shadowFeed",this.m_feedPayload);
      }
   }
}

