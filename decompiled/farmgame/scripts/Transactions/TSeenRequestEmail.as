package Transactions
{
   public class TSeenRequestEmail extends TFarmTransaction
   {
      
      public function TSeenRequestEmail()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("ZAPIClientService.userHasSeenEmailPermissionPrompt");
      }
   }
}

