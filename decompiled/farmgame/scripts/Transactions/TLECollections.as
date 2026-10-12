package Transactions
{
   import Widgets.Windows.Collections.CollectionsToasterWindow;
   
   public class TLECollections extends TFarmTransaction
   {
      
      protected var m_itemCode:String;
      
      protected var m_collectionsPopup:CollectionsToasterWindow = null;
      
      protected var m_collectionName:String;
      
      public function TLECollections(itemCode:String, collectionName:String = "")
      {
         this.m_itemCode = itemCode;
         this.m_collectionName = collectionName;
         super();
      }
      
      override public function perform() : void
      {
         if(this.m_collectionName == "")
         {
            signedCall("CollectionsService.addItemToCollection",this.m_itemCode);
         }
         else
         {
            signedCall("CollectionsService.buyAllCollectibles",this.m_collectionName);
         }
      }
      
      override protected function updateCollectionCounters(result:Object) : void
      {
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result.item != null)
         {
            Global.player.addGift(result.item,"0",1);
         }
      }
   }
}

