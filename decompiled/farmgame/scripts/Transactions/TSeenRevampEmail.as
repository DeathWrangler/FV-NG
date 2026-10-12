package Transactions
{
   public class TSeenRevampEmail extends TFarmTransaction
   {
      
      public function TSeenRevampEmail()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("ZAPIClientService.userHasSeenRevampEmailPrompt");
      }
   }
}

