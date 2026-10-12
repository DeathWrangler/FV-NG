package Transactions
{
   public class TClaimFinishedRecipes extends TFarmTransaction
   {
      
      public static const METHOD_CLAIM_RECIPE:String = "onClaimFinishedRecipes";
      
      private var m_Callback:Function;
      
      private var m_recipeId:String = null;
      
      private var m_ovenSlot:int = -1;
      
      public function TClaimFinishedRecipes(callBack:Function = null, recipeId:String = null, ovenSlot:int = -1)
      {
         super();
         this.m_recipeId = recipeId;
         this.m_Callback = callBack;
         this.m_ovenSlot = ovenSlot;
      }
      
      override public function perform() : void
      {
         signedCall("CraftingService." + METHOD_CLAIM_RECIPE,this.m_recipeId,this.m_ovenSlot);
      }
      
      override protected function onComplete(result:Object) : void
      {
         this.m_Callback(result);
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = METHOD_CLAIM_RECIPE;
         result.recipeCode = this.m_recipeId;
         return result;
      }
   }
}

