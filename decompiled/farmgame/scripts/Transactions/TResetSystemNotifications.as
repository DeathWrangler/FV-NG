package Transactions
{
   public class TResetSystemNotifications extends TFarmTransaction
   {
      
      public function TResetSystemNotifications()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.resetSystemNotifications");
      }
   }
}

