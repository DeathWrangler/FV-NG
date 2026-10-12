package Transactions
{
   public class TCIPTos extends TFarmTransaction
   {
      
      public function TCIPTos()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("CIPService.sawTOS");
      }
   }
}

