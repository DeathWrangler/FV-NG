package Transactions
{
   import Classes.Collections.Collectible;
   import Classes.Collections.Collection;
   import Classes.ZItem.FarmItem;
   import Managers.CollectionsManager;
   
   public class TBuyAllCollectibles extends TFarmTransaction
   {
      
      protected var m_collectionName:String;
      
      protected var m_validPurchase:Boolean = true;
      
      public function TBuyAllCollectibles(collectionName:String)
      {
         var collectible:Collectible = null;
         var newItem:FarmItem = null;
         var numOwned:Number = NaN;
         var numNeeded:Number = NaN;
         var currentCount:int = 0;
         var count:int = 0;
         super();
         this.m_collectionName = collectionName;
         var newCollection:Collection = CollectionsManager.getInstance().getCollection(collectionName);
         var collectibles:Array = newCollection.getCollectibles();
         for each(collectible in collectibles)
         {
            newItem = Global.farmGameSettingsManager.getFarmItemByCode(collectible.code);
            numOwned = collectible.numOwned;
            numNeeded = collectible.numNeeded;
            currentCount = 0;
            if(Global.player.collectionCounters[collectible.code] == null)
            {
               Global.player.collectionCounters[collectible.code] = 0;
            }
            if(Global.player.collectionCounters[collectible.code])
            {
               currentCount = int(Global.player.collectionCounters[collectible.code]);
            }
            count = currentCount;
            while(count < numNeeded && this.m_validPurchase)
            {
               this.m_validPurchase = Global.player.tryBuy(null,false,newItem);
               ++Global.player.collectionCounters[collectible.code];
               count++;
            }
         }
      }
      
      override public function perform() : void
      {
         if(this.m_collectionName != "" && this.m_validPurchase)
         {
            signedCall("CollectionsService.buyAllCollectibles",this.m_collectionName);
         }
      }
   }
}

