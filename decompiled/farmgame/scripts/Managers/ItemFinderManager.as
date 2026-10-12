package Managers
{
   import Classes.AreasOfEffect.AOEBonusData;
   import Classes.FarmIsoViewport;
   import Classes.HarvestableResource;
   import Classes.ItemFinderItemDescriptor;
   import Classes.ItemInstance;
   import Classes.Plot;
   import Classes.StorageBuilding;
   import Classes.WorldObjectTypes;
   import Classes.ZItem.FarmItem;
   import Classes.storage.StorageItem;
   import Engine.Classes.WorldObject;
   import Engine.Constants;
   import flash.utils.Dictionary;
   
   public class ItemFinderManager
   {
      
      private static var m_itemFinderManager:ItemFinderManager;
      
      private static const HUD_ICON_NAME:String = "itemFinder";
      
      private static const ITEM_FINDER_BLACKLIST:String = "ITEM_FINDER_BLACKLIST";
      
      private static const SUPERPLOT_AND_ORGANICFERT_HARVEST_INCREMENT:uint = 5;
      
      private static const ORGANICFERT_HARVEST_INCREMENT:uint = 1;
      
      private var m_highlightedWorldItemName:String = "";
      
      private var m_highlightedStorageItemName:String = "";
      
      private var m_blacklistedItemNames:Dictionary;
      
      public function ItemFinderManager(ifmSingletonEnforcer:IfmSingletonEnforcer)
      {
         var arrItemNames:Array = null;
         var itemName:String = null;
         this.m_blacklistedItemNames = new Dictionary();
         super();
         var blacklistedItemNames:String = Global.flashHotParams[ITEM_FINDER_BLACKLIST];
         if(blacklistedItemNames != null)
         {
            arrItemNames = blacklistedItemNames.split(",");
            for each(itemName in arrItemNames)
            {
               this.m_blacklistedItemNames[itemName] = true;
            }
         }
      }
      
      public static function getInstance() : ItemFinderManager
      {
         if(m_itemFinderManager == null)
         {
            m_itemFinderManager = new ItemFinderManager(new IfmSingletonEnforcer());
         }
         return m_itemFinderManager;
      }
      
      private static function modifyPlotCounts(itemDescriptor:ItemFinderItemDescriptor, isOrganicFertilized:Boolean, isSuperPlot:Boolean, aoeCount:int = 1) : void
      {
         if(isOrganicFertilized && isSuperPlot)
         {
            itemDescriptor.addTempHarvestCountForSeedSinceLastBushelDrop(SUPERPLOT_AND_ORGANICFERT_HARVEST_INCREMENT * aoeCount);
         }
         else if(!isSuperPlot)
         {
            if(isOrganicFertilized)
            {
               itemDescriptor.addTempHarvestCountForSeedSinceLastBushelDrop(ORGANICFERT_HARVEST_INCREMENT * aoeCount);
            }
         }
      }
      
      public function getSeedItemDictionary() : Dictionary
      {
         var object:WorldObject = null;
         var itemInstance:ItemInstance = null;
         var aoeCount:int = 0;
         var itemName:String = null;
         var itemType:String = null;
         var aoeResourceIds:Array = null;
         var bonusData:AOEBonusData = null;
         var resourceItemName:String = null;
         var plotInstance:Plot = null;
         var isOrganicFertilized:Boolean = false;
         var isSuperPlot:Boolean = false;
         var result:Dictionary = new Dictionary();
         var objects:Array = Global.world.getObjectsByType();
         for each(object in objects)
         {
            itemInstance = object as ItemInstance;
            if(itemInstance)
            {
               aoeCount = 1;
               if(object as HarvestableResource)
               {
                  aoeResourceIds = (object as HarvestableResource).getAOESourceIds();
                  bonusData = AOEManager.getInstance().computeBonusesForAoeResourceIds(aoeResourceIds,object as HarvestableResource);
                  if(bonusData.bonusMultiplierTypes)
                  {
                     aoeCount = Boolean(bonusData.bonusMultiplierTypes) && bonusData.bonusMultiplierTypes.hasOwnProperty("harvestYield") ? int(bonusData.bonusMultiplierTypes.harvestYield) : 1;
                  }
               }
               itemName = itemInstance.getItemName();
               if(!itemName)
               {
                  resourceItemName = itemInstance.getResourceItemName();
                  if(resourceItemName != "")
                  {
                     itemName = resourceItemName;
                  }
               }
               itemType = itemInstance.getItemType();
               if(itemType == "seed")
               {
                  plotInstance = object as Plot;
                  if(plotInstance.isPlotPlantedAndNotWithered())
                  {
                     isOrganicFertilized = Global.world.isHarvestableResourceOrganicFertilized(plotInstance);
                     isSuperPlot = SuperPlotManager.isSuperPlot(plotInstance);
                     this.addToDictionary(result,itemName,1,0,0,0,isOrganicFertilized,isSuperPlot,aoeCount);
                  }
               }
            }
         }
         return result;
      }
      
      public function getItemDictionary() : Dictionary
      {
         var object:WorldObject = null;
         var buildingObjects:Array = null;
         var buildingObject:WorldObject = null;
         var gifts:Dictionary = null;
         var storageItem:StorageItem = null;
         var worldInventoryId:Number = NaN;
         var storeItems:Array = null;
         var obj:Dictionary = null;
         var itemInstance:ItemInstance = null;
         var itemName:String = null;
         var resourceItemName:String = null;
         var storageBuilding:StorageBuilding = null;
         var storageBuildingContents:Array = null;
         var containedItemData:Object = null;
         var containedItem:FarmItem = null;
         var containedItemName:String = null;
         var giftItemName:String = null;
         var giftItem:FarmItem = null;
         var key:String = null;
         var inventoryItem:StorageItem = null;
         var extraData:Array = null;
         var itemCode:String = null;
         var farmItem:FarmItem = null;
         var farmItemName:String = null;
         var result:Dictionary = new Dictionary();
         var objects:Array = Global.world.getObjectsByType();
         for each(object in objects)
         {
            itemInstance = object as ItemInstance;
            if(itemInstance)
            {
               itemName = itemInstance.getItemName();
               if(itemName == null || itemName == "")
               {
                  resourceItemName = itemInstance.getResourceItemName();
                  if(resourceItemName != "")
                  {
                     itemName = resourceItemName;
                  }
               }
               this.addToDictionary(result,itemName,1,0,0,0);
            }
         }
         buildingObjects = Global.world.getObjectsByType(WorldObjectTypes.BUILDING);
         for each(buildingObject in buildingObjects)
         {
            storageBuilding = buildingObject as StorageBuilding;
            if(storageBuilding)
            {
               storageBuildingContents = storageBuilding.getContents();
               for each(containedItemData in storageBuildingContents)
               {
                  if(containedItemData.hasOwnProperty("item") && containedItemData.item != null)
                  {
                     containedItem = containedItemData.item;
                     containedItemName = containedItemData.item.name;
                     this.addToDictionary(result,containedItemName,0,containedItemData.num,0,0);
                  }
               }
            }
         }
         gifts = Global.player.gifts;
         for each(storageItem in gifts)
         {
            giftItemName = Global.farmGameSettingsManager.getFarmItemNameByCode(storageItem.itemKey);
            giftItem = Global.farmGameSettingsManager.getFarmItemByName(giftItemName);
            if(giftItem)
            {
               this.addToDictionary(result,giftItemName,0,0,storageItem.quantity,0);
            }
         }
         worldInventoryId = Global.worldManager.getStorageIdByWorld(Global.worldManager.currentWorldType);
         storeItems = [];
         obj = Global.player.getInventory(worldInventoryId);
         if(obj)
         {
            for(key in obj)
            {
               inventoryItem = obj[key] as StorageItem;
               if(Boolean(inventoryItem) && inventoryItem.quantity > 0)
               {
                  extraData = new Array();
                  itemCode = Global.farmGameSettingsManager.getItemCodeFromInventoryKey(key,extraData);
                  farmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
                  farmItemName = Global.farmGameSettingsManager.getFarmItemNameByCode(itemCode);
                  if(farmItem)
                  {
                     this.addToDictionary(result,farmItemName,0,0,0,inventoryItem.quantity);
                  }
               }
            }
         }
         return result;
      }
      
      private function addToDictionary(dictionary:Dictionary, itemName:String, worldCount:int, storageCount:int, giftCount:int, inventoryCount:int, isOrganicFertilized:Boolean = false, isSuperPlot:Boolean = false, aoeCount:int = 1) : void
      {
         var itemDescriptor:ItemFinderItemDescriptor = null;
         if(itemName != null && itemName != "" && !this.m_blacklistedItemNames[itemName])
         {
            itemDescriptor = dictionary[itemName];
            if(!itemDescriptor)
            {
               itemDescriptor = new ItemFinderItemDescriptor(itemName);
               itemDescriptor.addWorldItems(worldCount,isSuperPlot,aoeCount);
               itemDescriptor.addStorageItems(storageCount);
               itemDescriptor.addGiftItems(giftCount);
               itemDescriptor.addInventoryItems(inventoryCount);
               modifyPlotCounts(itemDescriptor,isOrganicFertilized,isSuperPlot,aoeCount);
               dictionary[itemName] = itemDescriptor;
            }
            else
            {
               itemDescriptor.addWorldItems(worldCount,isSuperPlot,aoeCount);
               itemDescriptor.addStorageItems(storageCount);
               itemDescriptor.addGiftItems(giftCount);
               modifyPlotCounts(itemDescriptor,isOrganicFertilized,isSuperPlot,aoeCount);
            }
         }
      }
      
      public function highlightWorldItems(itemName:String) : Array
      {
         var object:WorldObject = null;
         var itemInstance:ItemInstance = null;
         var arrHighlighted:Array = new Array();
         this.clearHighlightedItems();
         this.m_highlightedWorldItemName = itemName;
         var objects:Array = Global.world.getObjectsByName(this.m_highlightedWorldItemName);
         var bCentered:Boolean = false;
         for each(object in objects)
         {
            itemInstance = object as ItemInstance;
            if(itemInstance != null && itemInstance.getItemName() == this.m_highlightedWorldItemName || itemInstance.getResourceItemName() == this.m_highlightedWorldItemName)
            {
               itemInstance.showHighlight(true,Constants.COLOR_HIGHLIGHT_BLUE);
               if(!bCentered)
               {
                  object.centerOn();
                  bCentered = true;
               }
               arrHighlighted.push(object);
            }
         }
         return arrHighlighted;
      }
      
      public function atleastOneItemPlacedOnWorld(itemNames:Array) : Boolean
      {
         var numItems:Number = NaN;
         var objects:Array = null;
         var i:Number = NaN;
         var result:Boolean = false;
         if(itemNames)
         {
            numItems = itemNames.length;
            for(i = 0; i < numItems; i++)
            {
               objects = Global.world.getObjectsByName(itemNames[i]);
               if(Boolean(objects) && objects.length > 0)
               {
                  result = true;
                  break;
               }
            }
         }
         return result;
      }
      
      public function atleastOneItemInGiftBox(itemNames:Array) : Boolean
      {
         var numItems:Number = NaN;
         var giftCount:int = 0;
         var i:Number = NaN;
         var result:Boolean = false;
         if(itemNames)
         {
            numItems = itemNames.length;
            giftCount = 0;
            for(i = 0; i < numItems; i++)
            {
               giftCount = Global.player.getGiftCountForItem(itemNames[i]);
               if(giftCount > 0)
               {
                  result = true;
                  break;
               }
            }
         }
         return result;
      }
      
      public function highlightMultipleWorldItems(itemNames:Array, zoomout:Boolean = true, highlightColor:uint = 65535) : Array
      {
         var objects:Array = null;
         var object:WorldObject = null;
         var itemInstance:ItemInstance = null;
         var viewport:FarmIsoViewport = null;
         var arrHighlighted:Array = new Array();
         var numItems:Number = itemNames.length;
         var bCentered:Boolean = false;
         for(var i:Number = 0; i < numItems; i++)
         {
            this.m_highlightedWorldItemName = itemNames[i];
            objects = Global.world.getObjectsByName(this.m_highlightedWorldItemName);
            for each(object in objects)
            {
               itemInstance = object as ItemInstance;
               if(itemInstance != null && itemInstance.getItemName() == this.m_highlightedWorldItemName || itemInstance.getResourceItemName() == this.m_highlightedWorldItemName)
               {
                  itemInstance.showHighlight(true,highlightColor);
                  if(!bCentered)
                  {
                     object.centerOn();
                     bCentered = true;
                  }
                  arrHighlighted.push(object);
               }
            }
         }
         if(arrHighlighted.length > 0 && zoomout)
         {
            viewport = GlobalEngine.viewport as FarmIsoViewport;
            if(viewport)
            {
               viewport.setZoom(FarmIsoViewport.ZOOM_OUT_LIMIT_SPECIFIC);
            }
         }
         return arrHighlighted;
      }
      
      private function getBuildingsContainingItem(itemName:String) : Array
      {
         var buildingObject:WorldObject = null;
         var storageBuilding:StorageBuilding = null;
         var storageBuildingContents:Array = null;
         var containedItemData:Object = null;
         var containedItem:FarmItem = null;
         var arrHighlighted:Array = new Array();
         var bCentered:Boolean = false;
         var buildingObjects:Array = Global.world.getObjectsByType(WorldObjectTypes.BUILDING);
         for each(buildingObject in buildingObjects)
         {
            storageBuilding = buildingObject as StorageBuilding;
            if(storageBuilding)
            {
               storageBuildingContents = storageBuilding.getContents();
               for each(containedItemData in storageBuildingContents)
               {
                  if(containedItemData.hasOwnProperty("item"))
                  {
                     containedItem = containedItemData.item;
                     if(Boolean(containedItem) && containedItem.name == itemName)
                     {
                        arrHighlighted.push(storageBuilding);
                        if(!bCentered)
                        {
                           buildingObject.centerOn();
                           bCentered = true;
                        }
                     }
                  }
               }
            }
         }
         return arrHighlighted;
      }
      
      public function highlightStorageItems(itemName:String) : Array
      {
         var storageBuilding:StorageBuilding = null;
         var itemInstance:ItemInstance = null;
         this.clearHighlightedItems();
         this.m_highlightedStorageItemName = itemName;
         var storageBuildings:Array = this.getBuildingsContainingItem(itemName);
         for each(storageBuilding in storageBuildings)
         {
            itemInstance = storageBuilding as ItemInstance;
            if(itemInstance != null)
            {
               storageBuilding.showHighlight(true,Constants.COLOR_HIGHLIGHT_BLUE);
            }
         }
         return storageBuildings;
      }
      
      public function clearHighlightedItems() : void
      {
         var objects:Array = null;
         var object:WorldObject = null;
         var storageBuildings:Array = null;
         var storageBuilding:StorageBuilding = null;
         if(this.m_highlightedWorldItemName.length > 0)
         {
            objects = Global.world.getObjectsByName(this.m_highlightedWorldItemName);
            for each(object in objects)
            {
               object.setHighlighted(false);
            }
            this.m_highlightedWorldItemName = "";
         }
         if(this.m_highlightedStorageItemName.length > 0)
         {
            storageBuildings = this.getBuildingsContainingItem(this.m_highlightedStorageItemName);
            for each(storageBuilding in storageBuildings)
            {
               storageBuilding.setHighlighted(false);
            }
            this.m_highlightedStorageItemName = "";
         }
      }
   }
}

class IfmSingletonEnforcer
{
   
   public function IfmSingletonEnforcer()
   {
      super();
   }
}
