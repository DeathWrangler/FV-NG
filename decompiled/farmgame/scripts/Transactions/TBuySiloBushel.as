package Transactions
{
   public class TBuySiloBushel extends TFarmTransaction
   {
      
      private var m_quantity:int = 1;
      
      private var m_bushelCode:String;
      
      public function TBuySiloBushel(bushelCode:String, quantity:int = 1)
      {
         super();
         this.m_bushelCode = bushelCode;
         this.m_quantity = quantity;
      }
      
      override public function perform() : void
      {
         signedCall("FarmService.onPurchaseSiloBushel",this.m_bushelCode,this.m_quantity);
      }
   }
}

