package Transactions
{
   import Classes.FixedTreasureConstructionBuilding;
   import Classes.MapResource;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.LEUtil;
   import Managers.HangingGardensManager;
   
   public class TStoreItem extends TWorldState
   {
      
      public static const ACTION_STORE:String = "store";
      
      private var m_params:Object;
      
      private var m_building:StorageBuilding;
      
      private var m_storageLevelUp:int = -1;
      
      private var m_shouldSendTransaction:Boolean = true;
      
      public function TStoreItem(building:StorageBuilding, resource:MapResource, isFromStorage:Number, itemId:int = 0, isGift:Boolean = false, currencyUnit:String = "", storageLevelUp:int = -1, containeeItemCode:String = "", containeeMetadata:Object = null, isFull:Boolean = false, containeeMetadataIndex:int = -1, numToStore:int = 1)
      {
         var currencyToSubtract:Object = null;
         var storeNum:int = 0;
         var giftRemovedFromGiftBox:Boolean = false;
         this.m_params = {};
         this.m_storageLevelUp = storageLevelUp;
         this.m_params.cameFromLocation = isFromStorage;
         this.m_params.storedClassName = resource.getClassName();
         this.m_params.storedItemName = resource.getItemName();
         this.m_params.metadata = resource.packStoreItemMetaData();
         this.m_params.resource = itemId;
         this.m_params.isGift = isGift;
         var code:String = Global.farmGameSettingsManager.getFarmItemCodeByName(this.m_params.storedItemName);
         this.m_params.storedItemCode = code;
         this.m_params.isFull = int(building.count >= building.capacity);
         if(Boolean(containeeMetadata) && containeeItemCode != "")
         {
            this.m_params.isFull = isFull;
         }
         this.m_params.clientQty = -1;
         this.m_params.clientTotal = -1;
         this.m_params.currency = currencyUnit;
         this.m_params.containeeItemCode = containeeItemCode;
         this.m_params.containeeMetadata = containeeMetadata;
         this.m_params.containeeMetadataIndex = containeeMetadataIndex;
         if(!Global.flashHotParams["MULTISTORE_COMPLETENOW"])
         {
            numToStore = 1;
         }
         this.m_params.numToStore = numToStore;
         this.m_building = building;
         if(this.m_params.isGift == true)
         {
            currencyToSubtract = building.getCurrencyBeingAdded(resource);
            if(HangingGardensManager.isInHangingGardensExperiment() && Boolean(currencyToSubtract))
            {
               Global.player.updateWorldCurrency(currencyToSubtract["currency"],-1 * currencyToSubtract["amount"]);
            }
            else
            {
               for(storeNum = 0; storeNum < numToStore; storeNum++)
               {
                  giftRemovedFromGiftBox = Global.player.removeGift(resource);
                  this.m_shouldSendTransaction = resource is FixedTreasureConstructionBuilding ? giftRemovedFromGiftBox : this.m_shouldSendTransaction;
               }
            }
         }
         else if(resource.getId() > 0)
         {
            resource.onStorage();
            resource.detach();
         }
         LEUtil.handleLETransactionStart(resource.getItem());
         super(building);
      }
      
      override public function perform() : void
      {
         if(this.m_shouldSendTransaction)
         {
            signedWorldAction(ACTION_STORE,this.m_params);
         }
      }
      
      override protected function onComplete(result:Object) : void
      {
         this.m_building.onStoreComplete(result);
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_params.storedItemName);
         LEUtil.handleLETransactionComplete(result,item);
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = TWorldState.METHOD_PERFORM_ACTION;
         result.action = ACTION_STORE;
         result.storedItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_params.storedItemName);
         result.item = this.m_building.getItem();
         if(this.m_params.containeeItemCode != "" && Boolean(this.m_params.containeeMetadata))
         {
            result.item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_params.containeeItemCode);
         }
         result.building = this.m_building;
         result.isFull = this.m_params.isFull;
         result.resource = this.m_params.resource;
         result.cameFromLocation = this.m_params.cameFromLocation;
         result.currentExpansionLevel = this.m_building.storageLevel;
         if(this.m_storageLevelUp > 0)
         {
            result.storageLevelUp = this.m_storageLevelUp;
         }
         return result;
      }
   }
}

