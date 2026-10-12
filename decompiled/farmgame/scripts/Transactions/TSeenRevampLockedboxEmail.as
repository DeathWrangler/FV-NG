package Transactions
{
   public class TSeenRevampLockedboxEmail extends TFarmTransaction
   {
      
      public function TSeenRevampLockedboxEmail()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("ZAPIClientService.userHasSeenRevampEmailPromptLockedbox");
      }
   }
}

