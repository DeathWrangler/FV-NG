package Transactions
{
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.LEUtil;
   import Engine.Helpers.Vector2;
   import Engine.Managers.StatsManager;
   import Managers.FarmGameSettingsManager;
   import flash.geom.Point;
   
   public class TInventoryStore extends TWorldState
   {
      
      private var m_params:Object;
      
      protected const SPARKLE_URL:String = "assets/overlays/effect_dairyfarm_sparkle.swf";
      
      public function TInventoryStore(resource:MapResource, isFromStorage:Number, itemId:int = 0, isGift:Boolean = false, currencyUnit:String = "")
      {
         var itemCodeFromSource:String = null;
         var inventoryCode:String = null;
         var code:String = null;
         var pt:Point = null;
         var scale:Vector2 = null;
         this.m_params = {};
         this.m_params.origin = isFromStorage.toString();
         this.m_params.resource = itemId;
         this.m_params.isGift = isGift;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            itemCodeFromSource = resource.getItem().getStringFromDataSource("code");
         }
         else
         {
            itemCodeFromSource = resource.getItem().xml.@code;
         }
         var useRealItemNameEnabled:Boolean = Boolean(Global.flashHotParams["REALITEMNAME_ENABLED"]);
         if(useRealItemNameEnabled && resource.getItem().code != itemCodeFromSource)
         {
            this.m_params.code = itemCodeFromSource;
            StatsManager.count("REALITEMNAME_ENABLED","TInventoryStore",resource.getItem().code,itemCodeFromSource);
         }
         else
         {
            this.m_params.code = resource.getItem().code.toString();
         }
         this.m_params.target = Global.worldManager.getCurrentWorldStorageId();
         this.m_params.currency = currencyUnit;
         this.m_params.metadata = resource.packStoreItemMetaData();
         this.m_params.isStorageWithdrawal = isFromStorage;
         if(this.m_params.isGift == true)
         {
            Global.player.removeGift(resource);
         }
         else if(resource.getId() > 0)
         {
            resource.onStorage();
            scale = new Vector2(resource.getActualDisplayObjectSize().x * 1,resource.getActualDisplayObjectSize().y);
            pt = new Point(resource.getScreenPosition().x,resource.getScreenPosition().y - 1);
            Global.ui.displayOverlaySWF(Global.getAssetURL(this.SPARKLE_URL),pt,scale,0);
            resource.detach();
         }
         if(useRealItemNameEnabled && resource.getItem().code != itemCodeFromSource)
         {
            inventoryCode = itemCodeFromSource;
         }
         else
         {
            inventoryCode = resource.getInventoryCode();
         }
         var extraData:Object = resource.getMetadata();
         Global.player.addInventoryItem(inventoryCode,extraData);
         this.m_params.cameFromLocation = isFromStorage;
         this.m_params.storedClassName = resource.getClassName();
         this.m_params.storedItemName = resource.getItemName();
         this.m_params.resource = itemId;
         this.m_params.isGift = isGift;
         if(useRealItemNameEnabled && resource.getItem().code != itemCodeFromSource)
         {
            code = itemCodeFromSource;
         }
         else
         {
            code = Global.farmGameSettingsManager.getFarmItemCodeByName(this.m_params.storedItemName);
         }
         this.m_params.storedItemCode = code;
         LEUtil.handleLETransactionStart(resource.getItem());
         super(resource);
      }
      
      override public function perform() : void
      {
         signedWorldAction(TStoreItem.ACTION_STORE,this.m_params);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var giftItems:Object = null;
         var gift:String = null;
         var count:int = 0;
         var item:FarmItem = null;
         if(result.giftItems)
         {
            giftItems = result.giftItems;
            for(gift in giftItems)
            {
               count = int(giftItems[gift]);
               item = Global.farmGameSettingsManager.getFarmItemByCode(gift);
               Global.player.addGift(item.name,"0",count);
            }
         }
         var storedItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_params.code);
         if(storedItem != null)
         {
            if(Boolean(storedItem) && storedItem.limit > 0)
            {
               Global.player.addLimitedItem(storedItem.name);
            }
         }
         LEUtil.handleLETransactionComplete(result,storedItem);
         super.onComplete(result);
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = TWorldState.METHOD_PERFORM_ACTION;
         result.action = TStoreItem.ACTION_STORE;
         result.storageEntityId = this.m_params.target;
         result.storedItem = result.item = Global.farmGameSettingsManager.getFarmItemByName(this.m_params.storedItemName);
         result.resource = this.m_params.resource;
         result.cameFromLocation = this.m_params.cameFromLocation;
         result.params = this.m_params;
         return result;
      }
   }
}

