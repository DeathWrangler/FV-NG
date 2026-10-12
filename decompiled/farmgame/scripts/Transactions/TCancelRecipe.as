package Transactions
{
   import Classes.crafting.RecipeItem;
   
   public class TCancelRecipe extends TFarmTransaction
   {
      
      private var m_recipe:RecipeItem;
      
      public function TCancelRecipe(recipe:RecipeItem)
      {
         this.m_recipe = recipe;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("CraftingService.onCancelRecipe",this.m_recipe.id,this.m_recipe.serverStartTS);
      }
   }
}

