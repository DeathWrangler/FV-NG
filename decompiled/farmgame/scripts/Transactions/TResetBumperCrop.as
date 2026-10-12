package Transactions
{
   public class TResetBumperCrop extends TFarmTransaction
   {
      
      public function TResetBumperCrop()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("BumperCropService.resetBumperCropFlag");
      }
      
      override protected function onComplete(result:Object) : void
      {
      }
   }
}

