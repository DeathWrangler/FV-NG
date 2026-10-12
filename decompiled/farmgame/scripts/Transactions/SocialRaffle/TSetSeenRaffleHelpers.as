package Transactions.SocialRaffle
{
   import Transactions.TFarmTransaction;
   
   public class TSetSeenRaffleHelpers extends TFarmTransaction
   {
      
      public function TSetSeenRaffleHelpers()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("RaffleService.setSeenRaffleHelpers");
      }
   }
}

