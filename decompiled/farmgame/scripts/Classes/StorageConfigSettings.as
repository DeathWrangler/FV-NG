package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.storage.MasterySignStorageFilter;
   import Classes.storage.PartItem;
   import Classes.storage.StorageFilter;
   import Managers.FarmGameSettingsManager;
   import Managers.breeding.AnimalBreedingManager;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class StorageConfigSettings
   {
      
      public static const INVALID_STORAGE_MAX:Number = -1;
      
      private static const INVENTORY_NAME:String = "Inventory";
      
      private var m_xml:XML;
      
      private var m_storageObj:Object;
      
      private var m_storageFilters:Object;
      
      private var m_storageEntities:Object;
      
      private var m_loadClasses:Array = [MasterySignStorageFilter];
      
      public function StorageConfigSettings(xml:XML, storageObject:Object)
      {
         super();
         if(storageObject)
         {
            this.m_storageObj = storageObject["storage"];
            this.initStorageObj();
         }
         else if(xml)
         {
            this.m_xml = xml;
            this.initXML();
         }
      }
      
      private function initXML() : void
      {
         var tag:String = null;
         var xml:XML = null;
         var storageFilter:StorageFilter = null;
         var name:String = null;
         var className:Class = null;
         var extensionBase:String = null;
         this.m_storageFilters = {};
         this.m_storageEntities = {};
         for each(tag in ["StorageEntity","StorageBuilding","FeatureCreditStorage"])
         {
            for each(xml in this.m_xml.descendants(tag))
            {
               if("@storageFilterClass" in xml)
               {
                  try
                  {
                     className = getDefinitionByName("Classes.storage." + xml.attribute("storageFilterClass").toString()) as Class;
                     storageFilter = new className(xml,null);
                  }
                  catch(error:Error)
                  {
                     throw new Error("StorageConfigSettings::init() - A storage filter class was defined in XML that cannot be found. Looking for: Classes.storage." + xml.attribute("storageFilterClass").toString());
                  }
               }
               else
               {
                  storageFilter = new StorageFilter(xml,null);
               }
               if("@extends" in xml)
               {
                  extensionBase = xml.attribute("extends");
                  storageFilter.updateValuesFromExtensionBase(this.getStorageFilter(extensionBase));
               }
               name = storageFilter.name;
               if(this.m_storageFilters.hasOwnProperty(name))
               {
                  throw new Error("StorageConfigSettings::init() XML error - storage : " + name + " has duplicate entry");
               }
               this.m_storageFilters[name] = storageFilter;
               if(tag == "StorageEntity")
               {
                  this.m_storageEntities[xml.@id] = storageFilter;
               }
            }
         }
      }
      
      private function initStorageObj() : void
      {
         var tag:String = null;
         var storageTypeData:Object = null;
         var storageFilter:StorageFilter = null;
         var name:String = null;
         var className:Class = null;
         var extensionBase:String = null;
         this.m_storageFilters = {};
         this.m_storageEntities = {};
         for each(tag in ["StorageEntity","StorageBuilding","FeatureCreditStorage"])
         {
            for each(storageTypeData in this.m_storageObj[tag])
            {
               if(storageTypeData["storageFilterClass"])
               {
                  try
                  {
                     className = getDefinitionByName("Classes.storage." + storageTypeData["storageFilterClass"].toString()) as Class;
                     storageFilter = new className(null,storageTypeData);
                  }
                  catch(error:Error)
                  {
                     throw new Error("StorageConfigSettings::init() - A storage filter class was defined in XML that cannot be found. Looking for: Classes.storage." + storageTypeData["storageFilterClass"].toString());
                  }
               }
               else
               {
                  storageFilter = new StorageFilter(null,storageTypeData);
               }
               if(storageTypeData["extends"])
               {
                  extensionBase = storageTypeData["extends"];
                  storageFilter.updateValuesFromExtensionBase(this.getStorageFilter(extensionBase));
               }
               name = storageFilter.name;
               if(this.m_storageFilters.hasOwnProperty(name))
               {
                  throw new Error("StorageConfigSettings::init() AMF error - storage : " + name + " has duplicate entry");
               }
               this.m_storageFilters[name] = storageFilter;
               if(tag == "StorageEntity")
               {
                  this.m_storageEntities[storageTypeData["id"]] = storageFilter;
               }
            }
         }
      }
      
      public function getStorageFilter(storageName:String) : StorageFilter
      {
         var storageFilter:StorageFilter = null;
         if(this.m_storageFilters.hasOwnProperty(storageName))
         {
            storageFilter = this.m_storageFilters[storageName];
         }
         return storageFilter;
      }
      
      public function getAllStorageFilters(itemName:String) : Array
      {
         var filter:Object = null;
         var result:Array = new Array();
         var mapResource:MapResource = new MapResource(itemName,false);
         for(filter in this.m_storageFilters)
         {
            if(this.storageCanTake(filter as String,mapResource))
            {
               result.push(filter);
            }
         }
         mapResource.cleanUp();
         return result;
      }
      
      public function storageCanTake(storageName:String, item:MapResource) : Boolean
      {
         var storageFilter:StorageFilter = null;
         var result:Boolean = false;
         if(this.m_storageFilters.hasOwnProperty(storageName))
         {
            storageFilter = this.m_storageFilters[storageName];
            result = storageFilter.canTake(item);
         }
         return result;
      }
      
      public function inventoryCanTakeMoreMutableAnimals() : Boolean
      {
         return AnimalBreedingManager.getMutableAnimalCountInInventory(Global.worldManager.getCurrentWorldStorageId()) < this.maxInventoryUGCCap("Inventory");
      }
      
      public function maxStorageCap(storageName:String) : int
      {
         var storageFilter:StorageFilter = null;
         var result:int = INVALID_STORAGE_MAX;
         if(this.m_storageFilters.hasOwnProperty(storageName))
         {
            storageFilter = this.m_storageFilters[storageName];
            result = storageFilter.maxCapacity;
         }
         return result;
      }
      
      public function maxInventoryUGCCap(storageName:String) : int
      {
         var result:int = INVALID_STORAGE_MAX;
         if(storageName == null)
         {
            storageName = INVENTORY_NAME;
         }
         var inventoryFilter:StorageFilter = this.getStorageFilter(storageName);
         if(inventoryFilter != null)
         {
            result = inventoryFilter.maxUGCCapacity;
         }
         return result;
      }
      
      public function getMaxInventoryCapById(storageId:Number) : int
      {
         var storageFilter:StorageFilter = null;
         var result:int = INVALID_STORAGE_MAX;
         if(this.m_storageEntities.hasOwnProperty(storageId.toString()))
         {
            storageFilter = this.m_storageEntities[storageId];
            result = storageFilter.maxCapacity;
         }
         return result;
      }
      
      public function getStorageItems(storageName:String, excludeParts:Boolean = false, includeConditionals:Boolean = false, hidePrizedAnimal:Boolean = false) : Array
      {
         var itemNamesList:Array = null;
         var nameIndex:int = 0;
         var farmItem:FarmItem = null;
         var itemNames:XMLList = null;
         var itemXML:XML = null;
         var item:FarmItem = null;
         var itemList:Array = [];
         var storageFilter:StorageFilter = this.getStorageFilter(storageName);
         if(storageFilter != null)
         {
            if(FarmGameSettingsManager.isInStorageConfigAMFExperiment())
            {
               itemNamesList = includeConditionals ? storageFilter.allItemsIncludingConditionalsOpt : storageFilter.itemNamesOpt;
               for(nameIndex = 0; nameIndex < itemNamesList.length; nameIndex++)
               {
                  if(!(excludeParts && Boolean(itemNamesList[nameIndex].hasOwnProperty("part")) && itemNamesList[nameIndex]["part"] == "true"))
                  {
                     if(!(hidePrizedAnimal && Boolean(itemNamesList[nameIndex].hasOwnProperty("prizedAnimal")) && itemNamesList[nameIndex]["prizedAnimal"] == "true"))
                     {
                        if(getQualifiedClassName(itemNamesList[nameIndex]) == "Object")
                        {
                           farmItem = Global.farmGameSettingsManager.getFarmItemByName(itemNamesList[nameIndex].value);
                        }
                        else
                        {
                           farmItem = Global.farmGameSettingsManager.getFarmItemByName(itemNamesList[nameIndex]);
                        }
                        itemList.push(farmItem);
                     }
                  }
               }
            }
            else
            {
               itemNames = includeConditionals ? storageFilter.allItemsIncludingConditionals : storageFilter.itemNames;
               for each(itemXML in itemNames)
               {
                  if(!(excludeParts && itemXML.attribute("part").toString() == "true"))
                  {
                     if(!(hidePrizedAnimal && itemXML.attribute("prizedAnimal").toString() == "true"))
                     {
                        item = Global.farmGameSettingsManager.getFarmItemByName(itemXML.toString());
                        itemList.push(item);
                     }
                  }
               }
            }
         }
         return itemList;
      }
      
      public function getStorageItemsByClass(storageName:String) : Array
      {
         var className:String = null;
         var itemList:Array = [];
         var storageFilter:StorageFilter = this.getStorageFilter(storageName);
         if(storageFilter != null)
         {
            for each(className in storageFilter.allowedClasses)
            {
               itemList = itemList.concat(Global.farmGameSettingsManager.getItemsByClassArray(className));
            }
         }
         return itemList;
      }
      
      public function getStorageItemNames(storageName:String, additionalItemClass:String = "") : Array
      {
         var itemName:* = undefined;
         var itemXML:XML = null;
         var itemXML2:XML = null;
         var nameList:Array = [];
         var storageFilter:StorageFilter = this.getStorageFilter(storageName);
         if(storageFilter)
         {
            if(FarmGameSettingsManager.isInStorageConfigAMFExperiment())
            {
               for each(itemName in storageFilter.itemNamesOpt)
               {
                  if(itemName.hasOwnProperty("value"))
                  {
                     nameList.push(itemName["value"].toString());
                  }
                  else
                  {
                     nameList.push(itemName.toString());
                  }
               }
               if(additionalItemClass)
               {
                  storageFilter = this.getStorageFilter(additionalItemClass);
                  if(storageFilter)
                  {
                     for each(itemName in storageFilter.itemNamesOpt)
                     {
                        if(itemName.hasOwnProperty("value"))
                        {
                           nameList.push(itemName["value"].toString());
                        }
                        else
                        {
                           nameList.push(itemName.toString());
                        }
                     }
                  }
               }
            }
            else
            {
               for each(itemXML in storageFilter.itemNames)
               {
                  nameList.push(itemXML.toString());
               }
               if(additionalItemClass)
               {
                  storageFilter = this.getStorageFilter(additionalItemClass);
                  if(storageFilter)
                  {
                     for each(itemXML2 in storageFilter.itemNames)
                     {
                        nameList.push(itemXML2.toString());
                     }
                  }
               }
            }
         }
         return nameList;
      }
      
      public function getConstructionParts(storageName:String, building:StorageBuilding = null) : Array
      {
         var itemName:* = undefined;
         var itemData:FarmItem = null;
         var needData:int = 0;
         var partItemData:PartItem = null;
         var itemXML:XML = null;
         var item:FarmItem = null;
         var need:int = 0;
         var partItem:PartItem = null;
         var constructionParts:Array = [];
         var storageFilter:StorageFilter = this.getStorageFilter(storageName);
         if(storageFilter != null)
         {
            if(FarmGameSettingsManager.isInStorageConfigAMFExperiment())
            {
               for each(itemName in storageFilter.itemNamesOpt)
               {
                  if(itemName.hasOwnProperty("need"))
                  {
                     if(itemName.hasOwnProperty("value"))
                     {
                        itemData = Global.farmGameSettingsManager.getFarmItemByName(itemName["value"]);
                        needData = 0;
                        if(Boolean(building) && StorageBuilding.isDynamicPartsExperimentOn())
                        {
                           needData = building.getTunedPartRequirement(itemName,building.storageLevel);
                        }
                        else if(itemName.hasOwnProperty("need"))
                        {
                           needData = int(itemName["need"]);
                        }
                        partItemData = new PartItem(itemData,needData);
                        if(itemName.hasOwnProperty("currency"))
                        {
                           partItemData.currency = itemName["currency"];
                        }
                        constructionParts.push(partItemData);
                     }
                  }
               }
            }
            else
            {
               for each(itemXML in storageFilter.itemNames)
               {
                  if(itemXML.hasOwnProperty("@need"))
                  {
                     item = Global.farmGameSettingsManager.getFarmItemByName(itemXML.toString());
                     need = 0;
                     if(Boolean(building) && StorageBuilding.isDynamicPartsExperimentOn())
                     {
                        need = building.getTunedPartRequirement(itemXML,building.storageLevel);
                     }
                     else
                     {
                        need = int(itemXML.@need);
                     }
                     partItem = new PartItem(item,need);
                     if(itemXML.hasOwnProperty("@currency"))
                     {
                        partItem.currency = itemXML.@currency;
                     }
                     constructionParts.push(partItem);
                  }
               }
            }
         }
         return constructionParts;
      }
   }
}

