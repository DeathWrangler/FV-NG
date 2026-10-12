package Transactions
{
   public class TBuyBushelBundle extends TFarmTransaction
   {
      
      private var m_amount:int = 1;
      
      private var m_recipe:String;
      
      public function TBuyBushelBundle(recipe:String, amount:int = 1)
      {
         super();
         this.m_amount = amount;
         this.m_recipe = recipe;
      }
      
      override public function perform() : void
      {
         signedCall("FarmService.onPurchaseRecipeBundle",this.m_recipe,this.m_amount);
      }
   }
}

