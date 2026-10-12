package Transactions
{
   import Classes.crafting.RecipeItem;
   
   public class TBuyRecipeRush extends TFarmTransaction
   {
      
      private var m_recipeItem:RecipeItem;
      
      private var m_withCoins:Boolean;
      
      private var m_callback:Function;
      
      private var m_withTime:Boolean;
      
      public function TBuyRecipeRush(recipeItem:RecipeItem, withCoins:Boolean, callback:Function = null, withTime:Boolean = false)
      {
         this.m_recipeItem = recipeItem;
         this.m_withCoins = withCoins;
         this.m_callback = callback;
         this.m_withTime = withTime;
         super();
      }
      
      override public function perform() : void
      {
         var functionName:String = "onRushRecipe";
         if(this.m_withTime)
         {
            functionName = "onRushRecipeWithTime";
         }
         else if(this.m_withCoins)
         {
            Global.player.gold -= this.m_recipeItem.rushCostCoins;
         }
         else
         {
            Global.player.cash -= this.m_recipeItem.rushCostCash;
         }
         signedCall("CraftingService." + functionName,this.m_recipeItem.id,this.m_recipeItem.serverStartTS,this.m_withCoins,this.m_recipeItem.ovenSlot);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(result);
         }
      }
   }
}

