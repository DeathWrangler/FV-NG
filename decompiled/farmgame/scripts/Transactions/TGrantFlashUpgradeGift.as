package Transactions
{
   import Managers.ToasterManager;
   import Widgets.Windows.FlashUpgradeToasterWindow;
   
   public class TGrantFlashUpgradeGift extends TFarmTransaction
   {
      
      public function TGrantFlashUpgradeGift()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("FlashUpgradeGiftService.grantFlashUpgradeEnabledGift");
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result != null && result.receivedFlashUpgradeGift) && Boolean(result.receivedFlashUpgradeGift == "true") && Boolean(result.giftName))
         {
            Global.player.addGift(result.giftName);
            ToasterManager.getInstance().togglePause(false);
            ToasterManager.getInstance().add(new FlashUpgradeToasterWindow());
         }
      }
   }
}

