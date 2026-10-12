package Transactions
{
   import Display.UI;
   
   public class TReceiveWelcomeGift extends TFarmTransaction
   {
      
      public function TReceiveWelcomeGift()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("ZAPIClientService.receiveWelcomeGift");
      }
      
      override protected function onComplete(result:Object) : void
      {
         var idx:* = undefined;
         if(Boolean(result != null) && Boolean(result.receivedWelcomeGift) && result.receivedWelcomeGift == "true")
         {
            if(result.giftNames)
            {
               for(idx in result.giftNames)
               {
                  if(result.giftNames[idx])
                  {
                     Global.player.addGift(result.giftNames[idx]);
                  }
               }
               UI.displayGiftBoxWindow();
            }
         }
      }
   }
}

