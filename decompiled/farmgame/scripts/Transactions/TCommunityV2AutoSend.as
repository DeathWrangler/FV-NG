package Transactions
{
   public class TCommunityV2AutoSend extends TFarmTransaction
   {
      
      private var m_opted_in:Boolean;
      
      private var m_callback:Function;
      
      public function TCommunityV2AutoSend(opted_in:Boolean, callback:Function = null)
      {
         super();
         this.m_opted_in = opted_in;
         this.m_callback = callback;
      }
      
      override public function perform() : void
      {
         signedCall("CommunityService.setAutoSendCommunityNeighborPermission",this.m_opted_in);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(result);
         }
      }
   }
}

