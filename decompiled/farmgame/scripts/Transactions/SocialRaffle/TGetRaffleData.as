package Transactions.SocialRaffle
{
   import Transactions.TFarmTransaction;
   
   public class TGetRaffleData extends TFarmTransaction
   {
      
      private var m_callback:Function = null;
      
      public function TGetRaffleData(callback:Function = null)
      {
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("RaffleService.getRaffleData");
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

