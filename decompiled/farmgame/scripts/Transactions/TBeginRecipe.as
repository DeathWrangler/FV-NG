package Transactions
{
   public class TBeginRecipe extends TFarmTransaction
   {
      
      public static const METHOD_BEGIN_RECIPE:String = "onBeginRecipe";
      
      private var m_recipeId:String;
      
      private var m_Callback:Function;
      
      private var m_ovenSlot:int;
      
      private var m_recipeLevel:int;
      
      private var m_isRecipeLeveledUp:Boolean = false;
      
      public function TBeginRecipe(recipeId:String, ovenSlot:int, callback:Function = null)
      {
         this.m_recipeId = recipeId;
         this.m_Callback = callback;
         this.m_ovenSlot = ovenSlot;
         this.m_recipeLevel = Global.player.craftingState.craftingSkillState.getRecipeStateById(recipeId).level;
         this.m_isRecipeLeveledUp = Global.player.craftingState.craftingSkillState.getRecipeStateById(recipeId).isRecipeLeveledUp;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("CraftingService." + METHOD_BEGIN_RECIPE,this.m_recipeId,this.m_ovenSlot);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_Callback != null)
         {
            this.m_Callback(result);
         }
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = METHOD_BEGIN_RECIPE;
         result.recipeCode = this.m_recipeId;
         result.recipeLevel = this.m_recipeLevel;
         result.recipeLeveledUp = this.m_isRecipeLeveledUp;
         return result;
      }
   }
}

