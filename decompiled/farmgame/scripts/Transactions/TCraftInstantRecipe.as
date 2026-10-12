package Transactions
{
   public class TCraftInstantRecipe extends TFarmTransaction
   {
      
      public static const METHOD_INSTANT_RECIPE:String = "onCraftInstantRecipe";
      
      private var m_callback:Function;
      
      private var m_serviceName:String;
      
      private var m_serviceFunctionName:String;
      
      private var m_params:Array;
      
      private var m_recipeId:String;
      
      private var m_trackMadeRecipe:Boolean;
      
      public function TCraftInstantRecipe(recipeId:String, trackMadeRecipe:Boolean, callback:Function = null)
      {
         this.m_callback = callback;
         this.m_recipeId = recipeId;
         this.m_trackMadeRecipe = trackMadeRecipe;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("CraftingService." + METHOD_INSTANT_RECIPE,this.m_recipeId,this.m_trackMadeRecipe);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(result);
         }
         super.onComplete(result);
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = METHOD_INSTANT_RECIPE;
         result.recipeCode = this.m_recipeId;
         return result;
      }
   }
}

