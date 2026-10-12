package Classes
{
   import Classes.ZItem.FarmItem;
   import Display.MysteryGiftPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TOpenLootItem;
   
   public class MysteryGift extends LootableDecoration
   {
      
      private static const OPEN_OVERLAY_URL:String = "assets/effects/effect_mysterycrate2.swf";
      
      public function MysteryGift(itemName:String = null)
      {
         super(itemName);
      }
      
      override protected function open() : void
      {
         if(m_isGift)
         {
            Global.player.removeGift(null,itemName);
         }
         else
         {
            detach();
         }
         var params:Object = new Object();
         params.isGift = this.m_isGift;
         TransactionManager.addTransaction(new TOpenLootItem(this,params),true);
      }
      
      override public function getOpenOverlayUrl() : String
      {
         return OPEN_OVERLAY_URL;
      }
      
      override public function displayPostOpenPopup(wonItem:FarmItem, closeCallback:Function) : void
      {
         UI.displayPopup(new MysteryGiftPopup(closeCallback,wonItem,"MysteryGift",m_isGift));
      }
   }
}

