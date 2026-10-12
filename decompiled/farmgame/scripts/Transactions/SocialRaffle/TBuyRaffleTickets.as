package Transactions.SocialRaffle
{
   import Transactions.TFarmTransaction;
   
   public class TBuyRaffleTickets extends TFarmTransaction
   {
      
      private var m_numTickets:Number = 0;
      
      public function TBuyRaffleTickets(numTickets:Number)
      {
         this.m_numTickets = numTickets;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("RaffleService.buyTickets",this.m_numTickets);
      }
   }
}

