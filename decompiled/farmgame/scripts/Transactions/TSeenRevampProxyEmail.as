package Transactions
{
   public class TSeenRevampProxyEmail extends TFarmTransaction
   {
      
      public function TSeenRevampProxyEmail()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("ZAPIClientService.userHasSeenRevampEmailPromptProxy");
      }
   }
}

