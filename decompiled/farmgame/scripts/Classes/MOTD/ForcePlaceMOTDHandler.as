package Classes.MOTD
{
   import Classes.ZItem.FarmItem;
   
   public class ForcePlaceMOTDHandler extends CustomWindowMOTDHandler
   {
      
      public function ForcePlaceMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override protected function acceptMOTD() : void
      {
         var itemName:String = null;
         var giftItem:FarmItem = null;
         var canPlace:Boolean = false;
         super.acceptMOTD();
         if(m_currentMOTD.freeGift)
         {
            itemName = m_currentMOTD.freeGift;
            giftItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            canPlace = !giftItem.checkItemLimit(false);
            if(canPlace)
            {
               Global.world.enterForcePlaceMode(itemName);
            }
         }
      }
   }
}

