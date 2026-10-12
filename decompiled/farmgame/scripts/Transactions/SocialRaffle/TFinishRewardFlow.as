package Transactions.SocialRaffle
{
   import Transactions.TFarmTransaction;
   
   public class TFinishRewardFlow extends TFarmTransaction
   {
      
      private var m_callback:Function = null;
      
      public function TFinishRewardFlow(callback:Function = null)
      {
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("RaffleService.finishRewardFlow");
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null && this.m_callback != null)
         {
            this.m_callback(result);
         }
      }
   }
}

