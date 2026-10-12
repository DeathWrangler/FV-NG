package Transactions
{
   public class TPphToDoTakeAction extends TFarmTransaction
   {
      
      public function TPphToDoTakeAction()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("PphActionService.takeActionForTodaysAction");
      }
   }
}

