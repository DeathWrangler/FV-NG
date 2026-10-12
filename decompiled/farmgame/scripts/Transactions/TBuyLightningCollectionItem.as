package Transactions
{
   import Classes.ZItem.FarmItem;
   
   public class TBuyLightningCollectionItem extends TFarmTransaction
   {
      
      protected var m_itemCode:String;
      
      protected var m_item:FarmItem;
      
      protected var m_validPurchase:Boolean = false;
      
      public function TBuyLightningCollectionItem(itemCode:String)
      {
         super();
         this.m_itemCode = itemCode;
         this.m_item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_itemCode);
         if(Global.player.collectionCounters[itemCode] == null)
         {
            Global.player.collectionCounters[itemCode] = 0;
         }
         this.m_validPurchase = Global.player.tryBuy(null,false,this.m_item);
         ++Global.player.collectionCounters[itemCode];
      }
      
      override public function perform() : void
      {
         if(this.m_itemCode != "" && this.m_validPurchase)
         {
            signedCall("LightningCollectionsService.buyCollectionItem",this.m_itemCode);
         }
      }
   }
}

