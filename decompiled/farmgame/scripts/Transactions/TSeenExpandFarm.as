package Transactions
{
   public class TSeenExpandFarm extends TFarmTransaction
   {
      
      private var m_amount:int = 0;
      
      public function TSeenExpandFarm(amount:int)
      {
         super();
         this.m_amount = amount;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.setSeenExpandFarm",this.m_amount);
      }
      
      override public function isFaultable() : Boolean
      {
         return false;
      }
   }
}

