package Transactions
{
   import Classes.Collections.Collection;
   import Classes.ZItem.FarmItem;
   
   public class TBuyAllLightningCollectionItems extends TFarmTransaction
   {
      
      protected var m_collectionCode:String;
      
      protected var m_item:FarmItem;
      
      protected var m_validPurchase:Boolean = false;
      
      public function TBuyAllLightningCollectionItems(collectionCode:String)
      {
         var count:int = 0;
         super();
         this.m_collectionCode = collectionCode;
         var newCollection:Collection = Global.farmGameSettingsManager.getCollectionByCode(this.m_collectionCode);
         var collectables:XMLList = newCollection.getCollectablesXMLList();
         var newItem:FarmItem = null;
         var numNeeded:int = 0;
         var itemCode:String = "";
         var currentCount:int = 0;
         for(var collectIndex:int = 0; collectIndex < collectables.length(); collectIndex++)
         {
            itemCode = collectables[collectIndex].@code;
            newItem = Global.farmGameSettingsManager.getFarmItemByCode(collectables[collectIndex].@code);
            numNeeded = parseInt(collectables[collectIndex].@numneeded);
            if(Global.player.collectionCounters[itemCode] == null)
            {
               Global.player.collectionCounters[itemCode] = 0;
            }
            if(Global.player.collectionCounters[itemCode])
            {
               currentCount = int(Global.player.collectionCounters[itemCode]);
            }
            for(count = currentCount; count < numNeeded; count++)
            {
               this.m_validPurchase = Global.player.tryBuy(null,false,newItem);
               ++Global.player.collectionCounters[itemCode];
            }
            currentCount = 0;
         }
      }
      
      override public function perform() : void
      {
         if(this.m_collectionCode != "" && this.m_validPurchase)
         {
            signedCall("LightningCollectionsService.buyAllCollectionItems",this.m_collectionCode);
         }
      }
   }
}

