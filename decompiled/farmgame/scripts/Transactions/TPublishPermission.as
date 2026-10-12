package Transactions
{
   public class TPublishPermission extends TWorldState
   {
      
      public function TPublishPermission()
      {
         super(null);
      }
      
      override public function perform() : void
      {
         signedCall("UserService.setPublishPermission");
      }
   }
}

