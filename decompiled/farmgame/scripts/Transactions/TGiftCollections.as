package Transactions
{
   import Classes.Collections.Collection;
   import Classes.Collections.CollectionsToasterManager;
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Display.UI;
   import Managers.CollectionsManager;
   import Managers.ToasterManager;
   import Widgets.Windows.Collections.CollectionsToasterWindow;
   import flash.events.Event;
   
   public class TGiftCollections extends TFarmTransaction
   {
      
      protected var m_itemCode:String;
      
      protected var m_collectionsPopup:CollectionsToasterWindow = null;
      
      public function TGiftCollections(itemCode:String)
      {
         this.m_itemCode = itemCode;
         if(Global.player.collectionCounters[this.m_itemCode])
         {
            ++Global.player.collectionCounters[this.m_itemCode];
         }
         else
         {
            Global.player.collectionCounters[this.m_itemCode] = 1;
         }
         var gift:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_itemCode);
         Global.player.removeGift(null,gift.name);
         var m_collectionsPopup:CollectionsToasterWindow = CollectionsToasterManager.createToasterPopup(this.m_itemCode);
         if(m_collectionsPopup)
         {
            ToasterManager.getInstance().add(m_collectionsPopup);
            m_collectionsPopup.addEventListener(Event.CLOSE,this.onTimer);
         }
         super();
      }
      
      protected function onTimer(event:Event) : void
      {
         if(null != this.m_collectionsPopup)
         {
            this.m_collectionsPopup.removeEventListener(Event.CLOSE,this.onTimer);
            this.m_collectionsPopup = null;
         }
         UI.displayGiftBoxWindow();
      }
      
      override public function perform() : void
      {
         signedCall("CollectionsService.addGiftItemToCollection",this.m_itemCode);
      }
      
      override protected function updateCollectionCounters(result:Object) : void
      {
         var featureBuildings:Array = null;
         var featureBuilding:FeatureBuilding = null;
         super.updateCollectionCounters(result);
         var newCollection:Collection = CollectionsManager.getInstance().getCollectionByCollectibleCode(this.m_itemCode);
         if(null != newCollection && Collection.TYPE_SLOTMACHINE == newCollection.type)
         {
            featureBuildings = Global.world.getObjectsByClass(FeatureBuilding);
            for each(featureBuilding in featureBuildings)
            {
               if(null != featureBuilding && null != featureBuilding.slotmachine)
               {
                  featureBuilding.slotmachine.displayWindow();
               }
            }
         }
      }
   }
}

