package Transactions
{
   public class TBuyBushel extends TFarmTransaction
   {
      
      private var m_bushelCode:String;
      
      private var m_recipeId:String = "";
      
      private var m_quantity:int = 0;
      
      public function TBuyBushel(bushelCode:String, quantity:int = 1, recipeId:String = "")
      {
         super();
         this.m_bushelCode = bushelCode;
         this.m_recipeId = recipeId;
         this.m_quantity = quantity;
      }
      
      override public function perform() : void
      {
         signedCall("FarmService.onPurchaseBushel",this.m_bushelCode,this.m_recipeId,this.m_quantity);
      }
   }
}

