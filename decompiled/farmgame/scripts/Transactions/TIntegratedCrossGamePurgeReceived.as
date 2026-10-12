package Transactions
{
   public class TIntegratedCrossGamePurgeReceived extends TFarmTransaction
   {
      
      private var m_gameId:String;
      
      public function TIntegratedCrossGamePurgeReceived(gameId:String)
      {
         super();
         this.m_gameId = gameId;
      }
      
      override public function perform() : void
      {
         signedCall("IntegratedCrossGameGiftingService.pruneSeenReceivedGifts",this.m_gameId);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null)
         {
         }
      }
   }
}

