package Transactions
{
   public class TLEBundleDecline extends TFarmTransaction
   {
      
      public function TLEBundleDecline()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.declineLEBundle");
      }
   }
}

