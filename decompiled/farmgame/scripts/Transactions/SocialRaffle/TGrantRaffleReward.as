package Transactions.SocialRaffle
{
   import Transactions.TFarmTransaction;
   
   public class TGrantRaffleReward extends TFarmTransaction
   {
      
      private var m_raffleIndex:Number = 0;
      
      private var m_callback:Function = null;
      
      public function TGrantRaffleReward(raffleIndex:Number, callback:Function = null)
      {
         this.m_raffleIndex = raffleIndex;
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("RaffleService.grantReward",this.m_raffleIndex);
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

