package Classes
{
   import Classes.ZItem.FarmItem;
   import Display.UI;
   import GameMode.GMSpecialDeliveryApply;
   import Widgets.Windows.LootableItemGenericConfirmationWindow;
   
   public class SocialPlumbingMysteryGift extends MysteryGift
   {
      
      public function SocialPlumbingMysteryGift(itemName:String = null)
      {
         super(itemName);
      }
      
      override public function displayPostOpenPopup(wonItem:FarmItem, closeCallback:Function) : void
      {
         UI.displayPopup(new LootableItemGenericConfirmationWindow(this.getItem().name,wonItem,closeCallback));
      }
      
      override public function giftBoxOpen() : void
      {
         Global.world.addGameMode(new GMSpecialDeliveryApply(this),false);
      }
   }
}

