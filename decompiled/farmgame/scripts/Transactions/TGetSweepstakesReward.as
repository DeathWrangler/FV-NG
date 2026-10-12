package Transactions
{
   public class TGetSweepstakesReward extends TFarmTransaction
   {
      
      private var m_callback:Function;
      
      public function TGetSweepstakesReward(callback:Function)
      {
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("EnglishSweepstakesService.onClaimShareReward");
      }
      
      override protected function onComplete(result:Object) : void
      {
         this.m_callback(result);
      }
   }
}

