package Transactions
{
   import Classes.CIPStartNow;
   
   public class TCIPGdp extends TFarmTransaction
   {
      
      public function TCIPGdp()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("CIPService.grantPermission");
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result != null) && Boolean(result.receivedCIPStarterPack) && result.receivedCIPStarterPack == "true")
         {
            CIPStartNow.addStarterPack();
         }
      }
   }
}

