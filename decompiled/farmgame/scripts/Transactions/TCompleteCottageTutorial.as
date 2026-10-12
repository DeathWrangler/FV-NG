package Transactions
{
   public class TCompleteCottageTutorial extends TFarmTransaction
   {
      
      public function TCompleteCottageTutorial()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("CraftingService.onCompleteCottageTutorial");
      }
   }
}

