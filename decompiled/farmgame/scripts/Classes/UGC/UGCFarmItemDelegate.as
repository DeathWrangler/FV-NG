package Classes.UGC
{
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.IUGCItem;
   import Engine.Managers.ErrorManager;
   import GameMode.GMUGCItemPlace;
   
   public class UGCFarmItemDelegate
   {
      
      public function UGCFarmItemDelegate()
      {
         super();
      }
      
      public static function getInstanceName(metadata:String) : String
      {
         var ugcItemState:UGCItemState = null;
         var result:String = null;
         if(metadata)
         {
            ugcItemState = Global.player.ugcItemData.getStateByUUID(metadata);
            if(ugcItemState)
            {
               if(Boolean(ugcItemState.name) && ugcItemState.name.length > 0)
               {
                  result = ugcItemState.name;
               }
            }
         }
         return result;
      }
      
      public static function onBuy(item:FarmItem, name:String, extraData:Object = null) : Boolean
      {
         return false;
      }
      
      public static function onUse(item:FarmItem, buildingId:int = 0, extraData:Object = null) : void
      {
         var isGift:Boolean = false;
         var repopGift:Boolean = false;
         var inventoryKey:String = null;
         var ugcUuid:Object = null;
         if(item is IUGCItem)
         {
            isGift = true;
            repopGift = true;
            inventoryKey = item.code;
            if(extraData)
            {
               if(extraData.hasOwnProperty("isGift"))
               {
                  isGift = Boolean(extraData.isGift);
               }
               if(extraData.hasOwnProperty("repopGift"))
               {
                  repopGift = Boolean(extraData.repopGift);
               }
               if(extraData["inventoryKey"])
               {
                  inventoryKey = extraData.inventoryKey;
               }
            }
            ugcUuid = null;
            if(extraData["metadata"])
            {
               ugcUuid = extraData.metadata;
            }
            else if(extraData["ugcUuid"])
            {
               ugcUuid = extraData.ugcUuid;
            }
            else if(isGift)
            {
               ugcUuid = Global.player.getGiftMetadata(item.code);
            }
            else if(buildingId < 0)
            {
               ugcUuid = Global.player.getInventoryItemExtraData(inventoryKey,0,buildingId);
            }
            Global.world.addGameMode(new GMUGCItemPlace(item as IUGCItem,ugcUuid,buildingId,isGift,repopGift));
         }
         else
         {
            ErrorManager.addError("Incompatible non-IUGCItem passed to UGCFarmItemDelegate#onUse.");
         }
      }
   }
}

