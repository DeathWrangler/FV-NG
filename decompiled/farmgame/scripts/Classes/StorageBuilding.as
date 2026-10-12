package Classes
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.Experiments;
   import Classes.Constants.XMLKeys;
   import Classes.FeatureDataObjects.BuildingExpansionData;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.FarmItem;
   import Classes.storage.PartItem;
   import Classes.storage.StorageFilter;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.ContextMenuItem;
   import Display.GenericPopup;
   import Display.InventoryWithdrawal;
   import Display.StorageWithdrawal;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import GameMode.GMBuildingPart;
   import GameMode.GameMode;
   import Managers.ContextMenuQuestManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.HangingGardensManager;
   import Managers.breeding.AnimalBreedingManager;
   import Transactions.TInventoryStore;
   import Transactions.TStoreItem;
   import Transactions.TUpgradeStorage;
   import Transactions.TWorldObjectFeedTransaction;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.MOTD.FarmvilleAnniversaryV10DecorateBarn;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class StorageBuilding extends Building
   {
      
      protected static const SMART_SYSTEM_RESULTS_KEY:String = "smartSystemResult";
      
      protected const HOVERING_CONTEXT_MOUSE_OVER:String = "hoveringContextMenuHoverOver";
      
      protected const HOVERING_CONTEXT_OFF:String = "hoveringContextMenuOff";
      
      protected const OVERRIDE_COMPLETE_NOW:String = "OverrideCompleteNowPrice";
      
      protected const INVENTORY_CLASSNAME:String = "Inventory";
      
      protected const STATE_CONSTRUCTION:String = "construction";
      
      private const EXPANSION_REWARD_TYPE_PART:int = 1;
      
      private const EXPANSION_REWARD_TYPE_COMPLETE:int = 2;
      
      private const EXPANSION_REWARD_TYPE_HALF_COMPLETE:int = 3;
      
      private const EXPANSION_REWARD_TYPE_PARTS_INTERVAL:int = 4;
      
      protected var m_contents:Dictionary;
      
      protected var m_capacity:int;
      
      protected var m_seasonPrereq:String;
      
      protected var m_buildingMatsNeeded:int;
      
      protected var m_tutorialImagePrefix:String;
      
      protected var m_count:int = 0;
      
      protected var m_storageLevel:int = 0;
      
      protected var m_expansionParts:Dictionary;
      
      protected const REMOVEFROM_OBJECT:String = "removeFromObject";
      
      protected const EXPAND_OBJECT:String = "expandStorage";
      
      protected const UPGRADE_STORAGE:String = "upgrade";
      
      private const CONTEXT_QUEST:String = "context_quest";
      
      protected var m_hoverWindowAction:String = null;
      
      protected var m_hoverWindowActionValue:String = null;
      
      protected var m_numConstructImageStates:int = 0;
      
      protected var m_isFullyBuilt:Boolean = true;
      
      protected var m_paintColor:String = null;
      
      protected var m_alreadyShownFullPopup:Boolean = false;
      
      protected var m_nullArrow:Boolean = true;
      
      protected var m_expansionExperiment:String = "";
      
      protected var m_experimentGate:String = "";
      
      private var m_hoveringContextMenuActiveVar:int = 0;
      
      protected var m_frictionlessBuyExperiment:String = "";
      
      private var m_frictionlessBuyActiveVar:int = 0;
      
      private var m_partRequestTypes:XMLList = null;
      
      private var m_partRequestTypesData:Array = null;
      
      protected var m_isOffboarded:Boolean = false;
      
      protected var m_purchaseCurrencyUnit:String = "";
      
      protected var m_isStoredFeature:Boolean = false;
      
      private var m_contextFailedPrereq:String = null;
      
      private var m_buildingExpansionData:Dictionary;
      
      protected var m_completeNowInProgress:Boolean = false;
      
      protected var m_classCompilingTypes:Array;
      
      public function StorageBuilding(itemName:String = null)
      {
         var itemXML:XML = null;
         var frictionlessBuyTag:XMLList = null;
         var hoverContextMenuTag:XMLList = null;
         this.m_contents = new Dictionary();
         this.m_expansionParts = new Dictionary();
         this.m_buildingExpansionData = new Dictionary();
         this.m_classCompilingTypes = [TradingPostBuilding];
         super(itemName);
         this.setNumImageStates();
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(m_item.hasPropertyInDataSource("capacity"))
            {
               this.m_capacity = m_item.getIntFromDataSource("capacity");
            }
            if(m_item.hasPropertyInDataSource("matsNeeded"))
            {
               this.m_buildingMatsNeeded = m_item.getIntFromDataSource("matsNeeded");
            }
            if(m_item.hasPropertyInDataSource("tutorialImagePrefix","path"))
            {
               this.m_tutorialImagePrefix = m_item.getStringFromDataSource("tutorialImagePrefix","path");
            }
            if(m_item.hasPropertyInDataSource("frictionlessBuy","experiment") && m_item.hasPropertyInDataSource("frictionlessBuy","activevar"))
            {
               this.m_frictionlessBuyExperiment = m_item.getStringFromDataSource("frictionlessBuy","experiment");
               this.m_frictionlessBuyActiveVar = m_item.getIntFromDataSource("frictionlessBuy","activevar");
            }
            if(m_item.hasPropertyInDataSource("partRequestType"))
            {
               this.m_partRequestTypesData = m_item.getArrayFromDataSource("partRequestType");
            }
            if(m_item.hasPropertyInDataSource("storageSize"))
            {
               this.m_storageLevel = m_item.getIntFromDataSource("storageSize");
            }
            if(m_item.hasPropertyInDataSource("expansionExperimentGate"))
            {
               this.m_expansionExperiment = m_item.getStringFromDataSource("expansionExperimentGate");
            }
            if(m_item.hasPropertyInDataSource("experimentGate"))
            {
               this.m_experimentGate = m_item.getStringFromDataSource("experimentGate");
            }
            m_overlayVersion = this.m_storageLevel - 1;
            if(m_item.hasPropertyInDataSource("hoverContextMenu","action"))
            {
               this.m_hoverWindowAction = m_item.getStringFromDataSource("hoverContextMenu","action");
               if(m_item.hasPropertyInDataSource("hoverContextMenu","value"))
               {
                  this.m_hoverWindowActionValue = m_item.getStringFromDataSource("hoverContextMenu","value");
               }
            }
         }
         else
         {
            itemXML = m_item.xml;
            if(itemXML)
            {
               if(itemXML.capacity)
               {
                  this.m_capacity = itemXML.capacity;
               }
               if(itemXML.matsNeeded)
               {
                  this.m_buildingMatsNeeded = itemXML.matsNeeded;
               }
               if(itemXML.hasOwnProperty("tutorialImagePrefix") && itemXML.tutorialImagePrefix.hasOwnProperty("@path"))
               {
                  this.m_tutorialImagePrefix = itemXML.tutorialImagePrefix.@path;
               }
               if(itemXML.hasOwnProperty("frictionlessBuy"))
               {
                  frictionlessBuyTag = itemXML.frictionlessBuy;
                  if(frictionlessBuyTag.hasOwnProperty("@experiment") && frictionlessBuyTag.hasOwnProperty("@activevar"))
                  {
                     this.m_frictionlessBuyExperiment = frictionlessBuyTag.@experiment;
                     this.m_frictionlessBuyActiveVar = frictionlessBuyTag.@activevar;
                  }
               }
               if(itemXML.hasOwnProperty("partRequestType"))
               {
                  this.m_partRequestTypes = itemXML.descendants("partRequestType");
               }
               if(itemXML.hasOwnProperty("storageSize"))
               {
                  this.m_storageLevel = itemXML.storageSize;
               }
               if(itemXML.hasOwnProperty("expansionExperimentGate"))
               {
                  this.m_expansionExperiment = itemXML.expansionExperimentGate;
               }
               if(itemXML.hasOwnProperty("experimentGate"))
               {
                  this.m_experimentGate = itemXML.experimentGate;
               }
               m_overlayVersion = this.m_storageLevel - 1;
               if(itemXML.hasOwnProperty("hoverContextMenu"))
               {
                  hoverContextMenuTag = itemXML.hoverContextMenu;
                  if(hoverContextMenuTag.hasOwnProperty("@action"))
                  {
                     this.m_hoverWindowAction = hoverContextMenuTag.@action;
                     if(hoverContextMenuTag.hasOwnProperty("@value"))
                     {
                        this.m_hoverWindowActionValue = hoverContextMenuTag.@value;
                     }
                  }
               }
            }
         }
      }
      
      public static function getBuildingExpansionDataFromXML(buildingExpansionXML:XML, building:StorageBuilding = null) : BuildingExpansionData
      {
         var i:int = 0;
         var itemName:String = null;
         var partFarmItem:FarmItem = null;
         var numPartsNeeded:int = 0;
         var requestType:String = null;
         var capacity:int = parseInt(buildingExpansionXML.attribute("capacity"));
         var level:int = parseInt(buildingExpansionXML.attribute("level"));
         var experimentGate:String = buildingExpansionXML.attribute("experimentGate").length() > 0 ? buildingExpansionXML.attribute("experimentGate") : null;
         var experimentVariant:int = buildingExpansionXML.attribute("experimentVariant").length() > 0 ? int(parseInt(buildingExpansionXML.attribute("experimentVariant"))) : 0;
         var runtimeGate:String = buildingExpansionXML.attribute("runtimeGate").length() > 0 ? buildingExpansionXML.attribute("runtimeGate") : null;
         var parts:Vector.<PartItem> = new Vector.<PartItem>();
         var partsXML:XMLList = buildingExpansionXML.descendants("part");
         var numParts:int = partsXML.length();
         if(Boolean(partsXML) && numParts > 0)
         {
            for(i = 0; i < numParts; i++)
            {
               itemName = partsXML[i].@name;
               partFarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
               if(partFarmItem)
               {
                  numPartsNeeded = 0;
                  if(building)
                  {
                     numPartsNeeded = building.getTunedPartRequirement(partsXML[i],level);
                  }
                  else
                  {
                     numPartsNeeded = parseInt(partsXML[i].@need);
                  }
                  requestType = String(partsXML[i][XMLKeys.ATTR_REQUEST_TYPE]);
                  parts.push(new PartItem(partFarmItem,numPartsNeeded,requestType));
               }
            }
         }
         return new BuildingExpansionData(parts,level,capacity,experimentGate,experimentVariant,runtimeGate);
      }
      
      public static function getBuildingExpansionDataFromDataSource(buildingExpansionDataSource:BaseDataSource, building:StorageBuilding = null) : BuildingExpansionData
      {
         var partData:BaseDataSource = null;
         var itemName:String = null;
         var partFarmItem:FarmItem = null;
         var numPartsNeeded:int = 0;
         var requestType:String = null;
         var capacity:int = buildingExpansionDataSource.getInt("capacity");
         var level:int = buildingExpansionDataSource.getInt("level");
         var experimentGate:String = buildingExpansionDataSource.getString("experimentGate");
         if(experimentGate.length == 0)
         {
            experimentGate = null;
         }
         var experimentVariant:int = buildingExpansionDataSource.getInt("experimentVariant");
         var runtimeGate:String = buildingExpansionDataSource.getString("runtimeGate");
         if(runtimeGate.length == 0)
         {
            runtimeGate = null;
         }
         var parts:Vector.<PartItem> = new Vector.<PartItem>();
         var partsDataArray:Array = buildingExpansionDataSource.getArray("part");
         if(partsDataArray.length > 0)
         {
            for each(partData in partsDataArray)
            {
               itemName = partData.getString("name");
               partFarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
               if(partFarmItem)
               {
                  numPartsNeeded = 0;
                  if(building)
                  {
                     numPartsNeeded = building.getTunedPartRequirement(null,level,partData);
                  }
                  else
                  {
                     numPartsNeeded = partData.getInt("need");
                  }
                  requestType = partData.getString("requestType");
                  parts.push(new PartItem(partFarmItem,numPartsNeeded,requestType));
               }
            }
         }
         return new BuildingExpansionData(parts,level,capacity,experimentGate,experimentVariant,runtimeGate);
      }
      
      public static function getItemLimitForStorageBuilding(building:StorageBuilding, item:FarmItem) : Number
      {
         var buildingExpansionData:BuildingExpansionData = null;
         var part:PartItem = null;
         var items:Array = null;
         var index:int = 0;
         var partItemNameOpt:String = null;
         var partFarmItemOpt:FarmItem = null;
         var itemList:XMLList = null;
         var i:int = 0;
         var partItemName:String = null;
         var partFarmItem:FarmItem = null;
         var itemNames:XMLList = null;
         var shouldUseXMLImplementation:Boolean = false;
         var nextExpansionDataSource:BaseDataSource = null;
         var partDataArray:Array = null;
         var partData:BaseDataSource = null;
         var itemToCheck:FarmItem = null;
         var partLimit:int = 0;
         var partNeed:int = 0;
         var nextExpansionData:XML = null;
         var idx:int = 0;
         var itemName:String = null;
         var checkItem:FarmItem = null;
         var itemsData:Array = null;
         var itemIndex:int = 0;
         var itemNameOpt:String = null;
         var checkItemOpt:FarmItem = null;
         var limit:Number = 0;
         if(isDynamicPartsExperimentOn())
         {
            buildingExpansionData = building.getNextBuildingExpansionData();
            if(buildingExpansionData)
            {
               part = buildingExpansionData.getPartByName(item.name);
               if(part)
               {
                  limit = part.qtyNeeded;
               }
            }
            else if(FarmGameSettingsManager.isInStorageConfigAMFExperiment())
            {
               items = building.storageFilter.itemNamesOpt;
               if(Boolean(items) && items.length > 0)
               {
                  for(index = 0; index < items.length; index++)
                  {
                     if(items[index].hasOwnProperty("value"))
                     {
                        partItemNameOpt = items[index]["value"];
                     }
                     else
                     {
                        partItemNameOpt = items[index];
                     }
                     partFarmItemOpt = Global.farmGameSettingsManager.getFarmItemByName(partItemNameOpt);
                     if(Boolean(partFarmItemOpt) && partFarmItemOpt.name == item.name)
                     {
                        limit = building.getTunedPartRequirement(items[index],building.storageLevel);
                     }
                  }
               }
            }
            else
            {
               itemList = building.storageFilter.itemNames;
               if(Boolean(itemList) && itemList.length() > 0)
               {
                  for(i = 0; i < itemList.length(); i++)
                  {
                     partItemName = itemList[i];
                     partFarmItem = Global.farmGameSettingsManager.getFarmItemByName(partItemName);
                     if(Boolean(partFarmItem) && partFarmItem.name == item.name)
                     {
                        limit = building.getTunedPartRequirement(itemList[i],building.storageLevel);
                     }
                  }
               }
            }
         }
         else
         {
            itemNames = building.storageFilter.itemNames;
            shouldUseXMLImplementation = true;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               nextExpansionDataSource = building.getNextExpansionDataSource();
               if(nextExpansionDataSource)
               {
                  shouldUseXMLImplementation = false;
                  partDataArray = nextExpansionDataSource.getArray("part");
                  if(partDataArray.length > 0)
                  {
                     for each(partData in partDataArray)
                     {
                        itemToCheck = Global.farmGameSettingsManager.getFarmItemByName(partData.getString("name"));
                        if(Boolean(itemToCheck) && itemToCheck.name == item.name)
                        {
                           partLimit = partData.getInt("limit");
                           if(partLimit)
                           {
                              limit = partLimit;
                           }
                           else
                           {
                              partNeed = partData.getInt("need");
                              if(partNeed)
                              {
                                 limit = partNeed;
                              }
                           }
                        }
                     }
                  }
               }
            }
            if(shouldUseXMLImplementation)
            {
               nextExpansionData = building.getNextExpansionData();
               if(Boolean(nextExpansionData) || !FarmGameSettingsManager.isInStorageConfigAMFExperiment())
               {
                  itemNames = nextExpansionData.descendants("part");
                  if(Boolean(itemNames) && itemNames.length() > 0)
                  {
                     for(idx = 0; idx < itemNames.length(); idx++)
                     {
                        itemName = nextExpansionData ? itemNames[idx].@name : itemNames[idx];
                        checkItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
                        if(Boolean(checkItem) && checkItem.name == item.name)
                        {
                           if(itemNames[idx].attribute("limit").length() > 0)
                           {
                              limit = Number(itemNames[idx].@limit);
                           }
                           if(0 == limit && itemNames[idx].attribute("need").length() > 0)
                           {
                              limit = Number(itemNames[idx].@need);
                           }
                        }
                     }
                  }
               }
               else
               {
                  itemsData = building.storageFilter.itemNamesOpt;
                  if(Boolean(itemsData) && itemsData.length > 0)
                  {
                     for(itemIndex = 0; itemIndex < itemsData.length; )
                     {
                        itemNameOpt = itemsData[itemIndex].hasOwnProperty("name") ? itemsData[itemIndex]["name"] : itemsData[itemIndex]["value"];
                        checkItemOpt = Global.farmGameSettingsManager.getFarmItemByName(itemNameOpt);
                        if(Boolean(checkItemOpt) && checkItemOpt.name == item.name)
                        {
                           if(itemsData[itemIndex].hasOwnProperty("limit"))
                           {
                              limit = Number(itemsData[itemIndex]["limit"]);
                           }
                           if(0 == limit && Boolean(itemsData[itemIndex].hasOwnProperty("need")))
                           {
                              limit = Number(itemsData[itemIndex]["need"]);
                           }
                        }
                     }
                  }
               }
            }
         }
         return limit;
      }
      
      public static function getInitialExpansionLevelFromItem(item:FarmItem) : int
      {
         var expLevel:int = 0;
         var storageSize:int = 0;
         var result:int = 1;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            expLevel = item.getIntFromDataSource("initialExpansionLevel");
            storageSize = item.getIntFromDataSource("storageSize");
         }
         else
         {
            expLevel = int(item.xml.initialExpansionLevel);
            storageSize = int(item.xml.storageSize);
         }
         if(Boolean(storageSize) && (!expLevel || expLevel < storageSize))
         {
            result = item.storageSize;
         }
         else if(Boolean(expLevel) && expLevel >= storageSize)
         {
            result = expLevel;
         }
         return result;
      }
      
      public static function isDynamicPartsExperimentOn() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_DYNAMIC_PART_REQUIREMENTS_REFACTOR) > 0;
      }
      
      public static function isSmartBuildablesEnabled() : Boolean
      {
         return isDynamicPartsExperimentOn() && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SMART_QUESTS) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SMART_BUILDABLES) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START;
      }
      
      public function set seasonPrereq(prereq:String) : void
      {
         this.m_seasonPrereq = prereq;
      }
      
      public function get seasonPrereq() : String
      {
         return this.m_seasonPrereq;
      }
      
      public function isExpansionLevelComplete() : Boolean
      {
         var code:String = null;
         var needed:Number = NaN;
         var result:Boolean = true;
         var expansionParts:Object = this.nextExpansionPartsNeeded();
         if(expansionParts)
         {
            for(code in expansionParts)
            {
               needed = Number(expansionParts[code]);
               if(expansionParts[code] > 0)
               {
                  result = false;
                  break;
               }
            }
         }
         return result;
      }
      
      public function isNextStageRegionLocked() : Boolean
      {
         var upgradeDataSource:BaseDataSource = null;
         var upgradeData:XML = null;
         var result:Boolean = false;
         var nextStorageLevel:int = this.storageLevel + 1;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            upgradeDataSource = m_item.getUpgradeDataSource(nextStorageLevel);
            if(upgradeDataSource)
            {
               this.seasonPrereq = upgradeDataSource.getString("prereq");
            }
         }
         else
         {
            upgradeData = m_item.getUpgradeData(nextStorageLevel);
            if(upgradeData)
            {
               this.seasonPrereq = upgradeData.@prereq;
            }
         }
         if(this.seasonPrereq != "" && this.seasonPrereq != null)
         {
            result = !PrerequisiteUtility.checkPrereqByName(this.seasonPrereq);
         }
         return result;
      }
      
      public function getImageStates(imagePrefix:String) : Vector.<int>
      {
         var imageName:String = null;
         var idx:int = 0;
         var itemImagesLength:int = 0;
         var item:FarmItem = null;
         var imageArr:Array = null;
         var itemXML:XML = null;
         var imageStates:Vector.<int> = new Vector.<int>();
         var builtPattern:RegExp = new RegExp(imagePrefix);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            item = getItem();
            imageArr = item.getArrayFromDataSource("image");
            itemImagesLength = int(imageArr.length);
            for(idx = 0; idx < itemImagesLength; idx++)
            {
               imageName = (imageArr[idx] as BaseDataSource).getString("name");
               if(builtPattern.test(imageName))
               {
                  imageStates.push(int(imageName.substr(imagePrefix.length)));
               }
            }
         }
         else
         {
            itemXML = getItem().xml;
            itemImagesLength = itemXML.image.length();
            for(idx = 0; idx < itemImagesLength; idx++)
            {
               imageName = itemXML.image[idx]["@name"].toString();
               if(builtPattern.test(imageName))
               {
                  imageStates.push(int(imageName.substr(imagePrefix.length)));
               }
            }
         }
         imageStates.sort(Array.NUMERIC);
         return imageStates;
      }
      
      public function getCorrectSuffix(imageStates:Vector.<int>) : int
      {
         var currentLevel:int = 0;
         var index:* = 0;
         var result:int = -1;
         if(imageStates != null && imageStates.length > 0)
         {
            currentLevel = this.storageLevel - 1;
            for(index = int(imageStates.length - 1); index >= 0; index--)
            {
               if(currentLevel >= imageStates[index])
               {
                  result = imageStates[index];
                  break;
               }
            }
         }
         return result + 1;
      }
      
      public function getRequestTypes(partName:String) : Array
      {
         var requestListArr:Array = null;
         var requestObj:Object = null;
         var partRequestTypeData:BaseDataSource = null;
         var requestData:BaseDataSource = null;
         var partRequestType:XML = null;
         var requestList:XMLList = null;
         var requestNode:XML = null;
         var requestObject:Object = null;
         var result:Array = [];
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(this.m_partRequestTypesData)
            {
               requestListArr = [];
               requestObj = {};
               for each(partRequestTypeData in this.m_partRequestTypesData)
               {
                  if(partRequestTypeData.getString("item") == partName)
                  {
                     requestListArr = partRequestTypeData.getArray("request");
                  }
                  if(requestListArr.length > 0)
                  {
                     for each(requestData in requestListArr)
                     {
                        requestObj = {};
                        if(requestData.hasProperty("type"))
                        {
                           requestObj["type"] = requestData.getString("type");
                        }
                        if(requestData.hasProperty("prereq"))
                        {
                           requestObj["prereq"] = requestData.getString("prereq");
                        }
                        result.push(requestObj);
                     }
                  }
                  requestListArr = [];
               }
            }
         }
         else if(this.m_partRequestTypes)
         {
            for each(partRequestType in this.m_partRequestTypes)
            {
               requestList = partRequestType.(@item == partName).request;
               if(requestList.length() > 0)
               {
                  for each(requestNode in requestList)
                  {
                     requestObject = {};
                     if(requestNode.attribute("type").length() > 0)
                     {
                        requestObject["type"] = requestNode.@type.toString();
                     }
                     if(requestNode.attribute("prereq").length() > 0)
                     {
                        requestObject["prereq"] = requestNode.@prereq.toString();
                     }
                     result.push(requestObject);
                  }
               }
            }
         }
         return result;
      }
      
      public function get expansionExperiment() : String
      {
         return this.m_expansionExperiment;
      }
      
      public function isBuildingExperimentLocked() : Boolean
      {
         var result:Boolean = false;
         if(this.m_experimentGate != "")
         {
            result = Global.experimentManager.getExperimentVariant(this.m_experimentGate) > 0 ? false : true;
         }
         return result;
      }
      
      public function isInventoryBuilding() : Boolean
      {
         var isInventoryBuilding:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            isInventoryBuilding = this.getItem().getStringFromDataSource("storageType","itemClass") == this.INVENTORY_CLASSNAME;
         }
         else
         {
            isInventoryBuilding = this.getItem().xml.storageType.@itemClass == this.INVENTORY_CLASSNAME;
         }
         return isInventoryBuilding;
      }
      
      public function isStorageBuilding() : Boolean
      {
         return true;
      }
      
      public function inventoryIsSellable() : Boolean
      {
         var nonSellableInventory:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            nonSellableInventory = !this.getItem().getBoolFromDataSource("storageType","nonSellableInventory");
         }
         else
         {
            nonSellableInventory = this.getItem().xml.storageType.@nonSellableInventory != "true";
         }
         return nonSellableInventory;
      }
      
      protected function getMultiTreasurePrereqName() : String
      {
         var item:FarmItem = null;
         var itemXML:XML = null;
         var hoverContextMenuTag:XMLList = null;
         var result:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(getItem())
            {
               item = getItem();
               if(item.hasPropertyInDataSource("hoverContextMenu"))
               {
                  result = item.getStringFromDataSource("hoverContextMenu","prereqName");
               }
            }
         }
         else if(getItem())
         {
            itemXML = getItem().xml;
            if(Boolean(itemXML) && itemXML.hasOwnProperty("hoverContextMenu"))
            {
               hoverContextMenuTag = itemXML.hoverContextMenu;
               if(hoverContextMenuTag.hasOwnProperty("@prereqName"))
               {
                  result = hoverContextMenuTag.@prereqName;
               }
            }
         }
         return result;
      }
      
      protected function getHoveringContextMenuState() : String
      {
         var prereqName:String = null;
         var item:FarmItem = null;
         var itemXML:XML = null;
         var hoverContextMenuTag:XMLList = null;
         var prereq:Object = null;
         var prereqNotMet:Array = null;
         var result:String = this.HOVERING_CONTEXT_OFF;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            item = getItem();
            if(item.hasPropertyInDataSource("hoverContextMenu"))
            {
               result = this.HOVERING_CONTEXT_MOUSE_OVER;
               prereqName = item.getStringFromDataSource("hoverContextMenu","prereqName");
            }
         }
         else
         {
            itemXML = getItem().xml;
            if(Boolean(itemXML) && itemXML.hasOwnProperty("hoverContextMenu"))
            {
               result = this.HOVERING_CONTEXT_MOUSE_OVER;
               hoverContextMenuTag = itemXML.hoverContextMenu;
               if(hoverContextMenuTag.hasOwnProperty("@prereqName"))
               {
                  prereqName = hoverContextMenuTag.@prereqName;
               }
            }
         }
         if(prereqName)
         {
            prereq = Global.farmGameSettingsManager.getPrereqByName(prereqName);
            if(prereq)
            {
               prereqNotMet = PrerequisiteUtility.getPrerequisiteNotMet(new Array(prereq));
               if(prereqNotMet.length > 0)
               {
                  this.m_contextFailedPrereq = prereqNotMet.pop().name;
               }
               else
               {
                  this.m_contextFailedPrereq = null;
               }
            }
         }
         return result;
      }
      
      public function getFailedContextPrereq() : String
      {
         return this.m_contextFailedPrereq;
      }
      
      protected function useFrictionlessBuy() : Boolean
      {
         var result:Boolean = false;
         if(this.m_frictionlessBuyExperiment != "")
         {
            result = Global.experimentManager.getExperimentVariant(this.m_frictionlessBuyExperiment) == this.m_frictionlessBuyActiveVar ? true : false;
         }
         return result;
      }
      
      public function get contents() : Dictionary
      {
         return this.m_contents;
      }
      
      override protected function setNumImageStates() : void
      {
         var imageName:String = null;
         var constructMatch:Array = null;
         var idx:int = 0;
         var constructState:String = null;
         var imageArr:Array = null;
         var curDS:BaseDataSource = null;
         var arrLen:int = 0;
         var item:XML = null;
         super.setNumImageStates();
         this.m_numConstructImageStates = 0;
         var constructStates:Object = new Object();
         var constructPattern:RegExp = /construct_\d+/;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            imageArr = this.getItem().getArrayFromDataSource("image");
            arrLen = int(imageArr.length);
            for(idx = 0; idx < arrLen; idx++)
            {
               curDS = imageArr[idx] as BaseDataSource;
               imageName = curDS.getString("name");
               constructMatch = imageName.match(constructPattern);
               if(constructMatch)
               {
                  constructStates[constructMatch[0]] = 1;
               }
            }
         }
         else
         {
            item = this.getItem().xml;
            for(idx = 0; idx < item.image.length(); idx++)
            {
               imageName = item.image[idx]["@name"].toString();
               constructMatch = imageName.match(constructPattern);
               if(constructMatch)
               {
                  constructStates[constructMatch[0]] = 1;
               }
            }
         }
         for(constructState in constructStates)
         {
            ++this.m_numConstructImageStates;
         }
      }
      
      public function isFull() : Boolean
      {
         return this.m_count >= this.m_capacity;
      }
      
      public function upgrade(window:InventoryWithdrawal = null, skipTransactions:Boolean = false) : void
      {
         var itemName:String = this.getItem().getExpansion();
         var currentName:String = this.getItem().name;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         Global.player.removeLimitedItem(currentName);
         Global.player.addLimitedItem(itemName);
         setItem(item);
         this.m_capacity = item.capacity;
         ++this.m_storageLevel;
         dispOverlay(FarmGameObject.SPARKLE_URL);
         setState(this.state);
         if(!skipTransactions)
         {
            if(window)
            {
               addTransaction(new TUpgradeStorage(this,window,"cancel"),true);
            }
            else
            {
               addTransaction(new TUpgradeStorage(this,window,"complete"),true);
            }
         }
      }
      
      public function showStorageFullDialog() : void
      {
         var message:GenericPopup = null;
         var showPopup:Boolean = true;
         var showFullOnce:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            showFullOnce = m_item.getBoolFromDataSource("showFullOnce");
         }
         else
         {
            showFullOnce = "true" == m_item.xml.@showFullOnce;
         }
         if(showFullOnce)
         {
            if(this.m_alreadyShownFullPopup)
            {
               showPopup = false;
            }
            else
            {
               this.m_alreadyShownFullPopup = true;
            }
         }
         if(showPopup)
         {
            message = new GenericPopup(ZLocUtils.t("Dialogs","StorageFull",{"item":ZLocUtils.tk_pk(m_item.friendlyName)}),GenericPopup.TYPE_OK);
            message.setAcceptTextName("Okay");
            UI.displayPopup(message);
         }
      }
      
      public function showHasAllMatsDialog(resource:MapResource) : void
      {
         var message:GenericPopup = new GenericPopup(ZLocUtils.t("Dialogs","HasAllMats",{
            "item":ZLocUtils.tk_pk(m_item.friendlyName),
            "building":ZLocUtils.tk_pk(resource.getItemFriendlyName())
         }),GenericPopup.TYPE_OK);
         message.setAcceptTextName("Okay");
         UI.displayPopup(message);
      }
      
      public function canTakeItem(item:MapResource, isMouseOver:Boolean = true) : Boolean
      {
         var count:int = 0;
         var result:Boolean = false;
         if(getItem().storageClass == this.INVENTORY_CLASSNAME)
         {
            if(Global.player.hasInventorySpace())
            {
               result = Global.storageSettings.storageCanTake(this.INVENTORY_CLASSNAME,item) && (!AnimalBreedingManager.isMutableAnimal(item.getItem()) || Global.storageSettings.inventoryCanTakeMoreMutableAnimals());
            }
         }
         else if(this.isFullyBuilt() && this.m_count < this.m_capacity)
         {
            result = this.checkAllowedItem(item);
         }
         else if(!this.isFullyBuilt() && this.m_count < this.getMaterialsNeeded() && this.checkAllowedItem(item))
         {
            count = this.m_contents.hasOwnProperty(item.getItem().code) ? int(this.m_contents[item.getItem().code]) : 0;
            result = this.checkBuildingMats(item.getItem().name,count);
         }
         return result;
      }
      
      protected function getMaterialsNeeded() : int
      {
         var parts:Array = null;
         var partItem:PartItem = null;
         var result:int = 0;
         if(isDynamicPartsExperimentOn())
         {
            parts = this.getConstructionItems();
            for each(partItem in parts)
            {
               result += partItem.qtyNeeded;
            }
         }
         else
         {
            result = this.m_buildingMatsNeeded;
         }
         return result;
      }
      
      public function isUnderItemLimit(resourceItem:FarmItem) : Boolean
      {
         return this.getAmount(resourceItem.code) < this.getItemLimit(resourceItem);
      }
      
      public function showItemStorageLimitFullDialog(item:MapResource) : void
      {
         var limit:int = 0;
         var message:GenericPopup = null;
         var dispObj:DisplayObject = Global.stage.getChildByName("showItemStorageLimitFullDialog");
         if(dispObj == null)
         {
            limit = this.getItemLimit(item.getItem());
            message = new GenericPopup(ZLocUtils.t("Dialogs","ItemStorageLimitFull",{
               "itemLimit":limit,
               "item":ZLocUtils.tk_pk(item.getItem().friendlyName,"",limit),
               "building":ZLocUtils.tk_pk(m_item.friendlyName)
            }),GenericPopup.TYPE_OK);
            message.setAcceptTextName("Okay");
            UI.displayPopup(message,true,"showItemStorageLimitFullDialog",true);
         }
      }
      
      public function getStorageKey(object:Object) : String
      {
         return object.itemCode;
      }
      
      public function getStorageKeyFromMapResource(resource:MapResource) : String
      {
         return Global.farmGameSettingsManager.getFarmItemCodeByName(resource.getItemName());
      }
      
      public function get isStoredFeature() : Boolean
      {
         return this.m_isStoredFeature;
      }
      
      public function set isStoredFeature(isStored:Boolean) : void
      {
         this.m_isStoredFeature = isStored;
      }
      
      public function addItem(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false) : Boolean
      {
         var resourceItem:FarmItem = null;
         var key:String = null;
         var currencyBeingAdded:Object = null;
         var currencyToAdd:Number = NaN;
         var storeItem:Boolean = false;
         var success:Boolean = false;
         FarmStatsManager.featureSample("farm_world_action","add_item_to_storage",m_item.name,resource.getItem().name);
         if(this.isFullyBuilt() && this.isValidExpansionPart(resource))
         {
            success = this.addExpansionPart(resource);
         }
         else if(this.canTakeItem(resource,false))
         {
            resourceItem = resource.getItem();
            if(this.getItemLimit(resourceItem) == 0 || this.isUnderItemLimit(resourceItem))
            {
               setState(state);
               key = this.getStorageKeyFromMapResource(resource);
               if(!this.m_contents[key])
               {
                  this.m_contents[key] = 0;
               }
               if(HangingGardensManager.isInHangingGardensExperiment())
               {
                  currencyBeingAdded = this.getCurrencyBeingAdded(resource);
                  if(currencyBeingAdded)
                  {
                     currencyToAdd = Number(currencyBeingAdded["amount"]);
                     this.m_contents[key] += currencyToAdd;
                     this.m_count += currencyToAdd;
                     Global.player.updateWorldCurrency(currencyBeingAdded["currency"],-1 * currencyToAdd);
                  }
                  else
                  {
                     ++this.m_contents[key];
                     ++this.m_count;
                  }
               }
               else
               {
                  ++this.m_contents[key];
                  ++this.m_count;
               }
               if(this.shouldShowOverlayOnAdd())
               {
                  this.dispOverlay(getOverlayUrl());
               }
               success = true;
            }
            else
            {
               this.showItemStorageLimitFullDialog(resource);
            }
         }
         else if(this.isFullyBuilt() && this.m_count >= this.m_capacity)
         {
            this.showStorageFullDialog();
         }
         else if(!this.isFullyBuilt() && this.m_count < this.getMaterialsNeeded())
         {
            this.showHasAllMatsDialog(resource);
         }
         if(success)
         {
            storeItem = true;
            if(sendStoreItem)
            {
               if(getItem().storageClass == this.INVENTORY_CLASSNAME)
               {
                  storeItem = resource.preAddToInventoryCheck();
                  if(storeItem)
                  {
                     addTransaction(new TInventoryStore(resource,fromStorage,resource.getId(),isGift,this.m_purchaseCurrencyUnit),force);
                     FarmStatsManager.sample(100,"Storage","goods","stored","drag_drop");
                  }
               }
               else
               {
                  addTransaction(new TStoreItem(this,resource,fromStorage,resource.getId(),isGift,this.m_purchaseCurrencyUnit));
               }
            }
            if(storeItem)
            {
               resource.detach();
            }
            else
            {
               success = false;
            }
         }
         return success;
      }
      
      public function getCurrencyBeingAdded(resource:MapResource) : Object
      {
         var buildingPartItems:Array = null;
         var buildingPart:PartItem = null;
         var buildingItem:FarmItem = null;
         var currencyName:String = null;
         var result:Object = null;
         if(HangingGardensManager.isInHangingGardensExperiment())
         {
            buildingPartItems = this.getConstructionItems();
            buildingPart = null;
            for each(buildingPart in buildingPartItems)
            {
               buildingItem = buildingPart.item;
               if(buildingItem != null && buildingItem.name == resource.getItemName())
               {
                  currencyName = buildingPart.getCurrency();
                  if(currencyName)
                  {
                     result = {
                        "currency":currencyName,
                        "amount":this.getInventoryPartCountUseable(buildingPart)
                     };
                  }
                  break;
               }
            }
         }
         return result;
      }
      
      public function shouldCopyPlantTimeWhenReplacing() : Boolean
      {
         return false;
      }
      
      public function shouldCopyPartsWhenReplacing() : Boolean
      {
         return false;
      }
      
      public function shouldCopyStorageWhenReplacing() : Boolean
      {
         return false;
      }
      
      public function copyParts(srcBuilding:StorageBuilding, overrideShouldCopy:Boolean = false) : Boolean
      {
         var part:PartItem = null;
         var partCode:String = null;
         var partName:String = null;
         var partAmountNeeded:int = 0;
         var partsToAdd:int = 0;
         var i:int = 0;
         var result:Boolean = false;
         if(overrideShouldCopy || this.shouldCopyStorageWhenReplacing())
         {
            for each(part in srcBuilding.getConstructionItems())
            {
               partCode = part.item.code;
               partName = part.item.name;
               partAmountNeeded = this.getExpansionPartLimit(partCode) - this.getExpansionPartLimit(partCode);
               partsToAdd = Math.min(partAmountNeeded,part.onHand);
               if(this.isValidExpansionPartByName(partName))
               {
                  for(i = 0; i < partsToAdd; i++)
                  {
                     this.addExpansionPart(new MapResource(partName));
                  }
               }
            }
            result = true;
         }
         return result;
      }
      
      public function copyStorage(srcBuilding:StorageBuilding, overrideShouldCopy:Boolean = false) : Boolean
      {
         var item:FarmItem = null;
         var itemCode:String = null;
         var resourceClass:Class = null;
         var itemResource:MapResource = null;
         var itemCount:int = 0;
         var result:Boolean = false;
         if(overrideShouldCopy || this.shouldCopyStorageWhenReplacing())
         {
            for(itemCode in srcBuilding.contents)
            {
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
               }
               else
               {
                  item = new FarmItem(Global.farmGameSettingsManager.getItemXMLByCode(itemCode));
               }
               resourceClass = item.getMapResourceClass();
               itemResource = new resourceClass(item.name);
               if(this.canTakeItem(itemResource))
               {
                  itemCount = int(srcBuilding.contents[itemCode]);
                  this.m_count += itemCount;
                  this.m_contents[itemCode] = itemCount;
               }
            }
            result = true;
         }
         return result;
      }
      
      protected function generateRequestExpansionPartFeed(farmItem:FarmItem, callback:Function = null, bundleName:String = "featureBuildingAskPart") : void
      {
         var bundle:String = null;
         if(this.canRequestPartFeed(farmItem.code))
         {
            bundle = bundleName;
            TransactionManager.addTransaction(new TWorldObjectFeedTransaction(this,"requestExpansionPart",ZCacheUtil.applyPartial(this.requestExpansionPartFeedComplete,this,[farmItem.code,callback]),[farmItem.code,bundle]),true);
         }
      }
      
      public function requestExpansionPartFeedComplete(itemCode:String, callback:Function, result:Object) : void
      {
         if(Boolean(result) && Boolean(result.postSuccessful))
         {
            Global.player.setFeatureLastShown(this.getItem().name + "_partRequest",GlobalEngine.serverTime / 1000,true);
            Global.player.setFeatureLastShown(this.getItem().name + "_" + itemCode + "_partRequest",GlobalEngine.serverTime / 1000,true);
         }
         if(callback != null)
         {
            callback(result);
         }
      }
      
      public function canRequestPartFeed(itemCode:String) : Boolean
      {
         var buildingString:String = this.getItem().name + "_partRequest";
         var itemString:String = this.getItem().name + "_" + itemCode + "_partRequest";
         var buildingLimit:int = Global.farmGameSettingsManager.getInt(buildingString + "_limit",Global.farmGameSettingsManager.getInt("default_building_partRequest_limit"));
         var itemLimit:int = Global.farmGameSettingsManager.getInt(itemString + "_limit",Global.farmGameSettingsManager.getInt("default_building_item_partRequest_limit"));
         var currentTime:int = GlobalEngine.serverTime / 1000;
         return currentTime - Global.player.getFeatureLastShown(buildingString) > buildingLimit && currentTime - Global.player.getFeatureLastShown(itemString) > itemLimit;
      }
      
      public function getTimeUntilPostAnotherFeed(itemCode:String) : int
      {
         var buildingString:String = getItemName() + "_partRequest";
         var itemString:String = getItemName() + "_" + itemCode + "_partRequest";
         var buildingLimit:int = Global.farmGameSettingsManager.getInt(buildingString + "_limit",Global.farmGameSettingsManager.getInt("default_building_partRequest_limit"));
         var itemLimit:int = Global.farmGameSettingsManager.getInt(itemString + "_limit",Global.farmGameSettingsManager.getInt("default_building_item_partRequest_limit"));
         var currentTime:int = GlobalEngine.serverTime / 1000;
         var buildingElapsedTime:int = currentTime - Global.player.getFeatureLastShown(buildingString);
         var buildingTimeUntil:int = buildingLimit - buildingElapsedTime;
         var itemElapsedTime:int = currentTime - Global.player.getFeatureLastShown(itemString);
         var itemTimeUntil:int = itemLimit - itemElapsedTime;
         return int(Math.max(buildingTimeUntil,itemTimeUntil));
      }
      
      public function addItemUsingCurrency(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false, currencyUnit:String = "") : Boolean
      {
         this.m_purchaseCurrencyUnit = currencyUnit;
         return this.addItem(resource,fromStorage,isGift,sendStoreItem,force);
      }
      
      override public function preAddToInventoryCheck() : Boolean
      {
         var excessAmount:int = 0;
         var storeItem:Boolean = true;
         var expansionPartCount:int = this.getTotalExpansionPartCount();
         if(expansionPartCount > 0)
         {
            storeItem = false;
            excessAmount = 1 + expansionPartCount + Global.player.getGiftCount() - Number(GlobalEngine.getFlashVar("GIFTBOX_TOTAL_ITEM_LIMIT"));
            if(!Global.player.hasGiftBoxCapacity(expansionPartCount))
            {
               if(excessAmount < 0)
               {
                  excessAmount = 20;
               }
               UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","StorageExpansionPartsGiftboxFull",{"quantity":excessAmount}),GenericPopup.TYPE_OK,null));
            }
            else
            {
               UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","StorageExpansionPartsWarning"),GenericPopup.TYPE_YESNO,this.onStoreExpandable));
            }
         }
         return storeItem;
      }
      
      public function onStoreExpandable(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            addTransaction(new TInventoryStore(this,0,this.getId(),true));
            FarmStatsManager.sample(100,"Storage","goods","stored","store_it_menu","sucess");
            this.detach();
         }
      }
      
      public function isValidExpansionPart(resource:MapResource) : Boolean
      {
         var resourceItemName:String = null;
         var result:Boolean = false;
         if(resource)
         {
            resourceItemName = resource.getItemName();
            if(resourceItemName)
            {
               result = this.isValidExpansionPartByName(resourceItemName);
            }
         }
         return result;
      }
      
      public function isValidExpansionPartByName(itemName:String) : Boolean
      {
         var buildingExpansionData:BuildingExpansionData = null;
         var upgradeDataSource:BaseDataSource = null;
         var partDataArray:Array = null;
         var partData:BaseDataSource = null;
         var upgradeData:XML = null;
         var isValid:Boolean = false;
         if(isDynamicPartsExperimentOn())
         {
            buildingExpansionData = this.getNextBuildingExpansionData();
            if(buildingExpansionData)
            {
               isValid = buildingExpansionData.getPartByName(itemName) != null;
            }
         }
         else if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            upgradeDataSource = this.getNextExpansionDataSource();
            if(upgradeDataSource)
            {
               partDataArray = upgradeDataSource.getArray("part");
               if(partDataArray.length > 0)
               {
                  for each(partData in partDataArray)
                  {
                     if(partData.getString("name") == itemName)
                     {
                        isValid = true;
                        break;
                     }
                  }
               }
            }
         }
         else
         {
            upgradeData = this.getNextExpansionData();
            if(Boolean(upgradeData) && Boolean(upgradeData.part))
            {
               isValid = upgradeData.part.(@name == itemName).length() > 0;
            }
         }
         return isValid;
      }
      
      public function isValidContaineePart(resource:MapResource) : Boolean
      {
         return false;
      }
      
      public function hasNextExpansion() : Boolean
      {
         var result:Boolean = false;
         if(isDynamicPartsExperimentOn())
         {
            result = this.getNextBuildingExpansionData() != null;
         }
         else if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            result = this.getNextExpansionDataSource() != null;
         }
         else
         {
            result = this.getNextExpansionData() != null;
         }
         return result;
      }
      
      public function getPartNames() : Array
      {
         var buildingExpansionData:BuildingExpansionData = null;
         var upgradeDataSource:BaseDataSource = null;
         var partDataArray:Array = null;
         var partData:BaseDataSource = null;
         var upgradeXML:XML = null;
         var partsXML:XMLList = null;
         var numParts:int = 0;
         var idx:int = 0;
         var result:Array = null;
         if(isDynamicPartsExperimentOn())
         {
            buildingExpansionData = this.getNextBuildingExpansionData();
            if(buildingExpansionData)
            {
               result = buildingExpansionData.getPartNames();
            }
         }
         else if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            upgradeDataSource = this.getNextExpansionDataSource();
            if(upgradeDataSource)
            {
               partDataArray = upgradeDataSource.getArray("part");
               if(partDataArray.length > 0)
               {
                  for each(partData in partDataArray)
                  {
                     result.push(partData.getString("name"));
                  }
               }
            }
         }
         else
         {
            upgradeXML = this.getNextExpansionData();
            if(upgradeXML)
            {
               partsXML = upgradeXML.descendants("part");
               numParts = partsXML.length();
               if(Boolean(partsXML) && numParts > 0)
               {
                  for(idx = 0; idx < numParts; idx++)
                  {
                     result.push(partsXML[idx].@name);
                  }
               }
            }
         }
         return result;
      }
      
      public function getNextExpansionLevel() : int
      {
         var buildingExpansionData:BuildingExpansionData = null;
         var upgradeDataSource:BaseDataSource = null;
         var upgradeXML:XML = null;
         var result:int = 0;
         if(isDynamicPartsExperimentOn())
         {
            buildingExpansionData = this.getNextBuildingExpansionData();
            if(buildingExpansionData)
            {
               result = buildingExpansionData.level;
            }
         }
         else if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            upgradeDataSource = this.getNextExpansionDataSource();
            if(upgradeDataSource)
            {
               result = upgradeDataSource.getInt("level");
            }
         }
         else
         {
            upgradeXML = this.getNextExpansionData();
            if(upgradeXML)
            {
               result = int(upgradeXML.attribute("level").toString());
            }
         }
         return result;
      }
      
      public function getNextExpansionCapacity() : int
      {
         var buildingExpansionData:BuildingExpansionData = null;
         var upgradeDataSource:BaseDataSource = null;
         var upgradeXML:XML = null;
         var result:int = 0;
         if(isDynamicPartsExperimentOn())
         {
            buildingExpansionData = this.getNextBuildingExpansionData();
            if(buildingExpansionData)
            {
               result = buildingExpansionData.capacity;
            }
         }
         else if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            upgradeDataSource = this.getNextExpansionDataSource();
            if(upgradeDataSource)
            {
               result = upgradeDataSource.getInt("capacity");
            }
         }
         else
         {
            upgradeXML = this.getNextExpansionData();
            if(upgradeXML)
            {
               result = int(upgradeXML.attribute("capacity").toString());
            }
         }
         return result;
      }
      
      public function getNextExpansionData() : XML
      {
         return getItem().getUpgradeData(this.m_storageLevel + 1);
      }
      
      public function getNextExpansionDataSource() : BaseDataSource
      {
         return getItem().getUpgradeDataSource(this.m_storageLevel + 1);
      }
      
      public function getNextBuildingExpansionData() : BuildingExpansionData
      {
         return this.getBuildingExpansionDataByLevel(this.m_storageLevel + 1);
      }
      
      public function getBuildingExpansionDataByLevel(level:int) : BuildingExpansionData
      {
         var result:BuildingExpansionData = null;
         var buildingExpansionData:BaseDataSource = null;
         var buildingExpansionXML:XML = null;
         var key:String = level.toString();
         if(this.m_buildingExpansionData.hasOwnProperty(key) && this.m_buildingExpansionData[key] != null)
         {
            result = this.m_buildingExpansionData[key];
         }
         else
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               buildingExpansionData = getItem().getUpgradeDataSource(level);
               if(buildingExpansionData)
               {
                  result = getBuildingExpansionDataFromDataSource(buildingExpansionData,this);
               }
            }
            else
            {
               buildingExpansionXML = getItem().getUpgradeData(level);
               if(buildingExpansionXML)
               {
                  result = getBuildingExpansionDataFromXML(buildingExpansionXML,this);
               }
            }
            this.m_buildingExpansionData[key] = result;
         }
         return result;
      }
      
      public function getTunedPartRequirement(partData:*, level:int, partDataSource:BaseDataSource = null) : int
      {
         var partXML:XML = null;
         var numPartsNeeded:int = 0;
         if(partDataSource != null)
         {
            numPartsNeeded = partDataSource.getInt("limit");
            if(numPartsNeeded == 0)
            {
               numPartsNeeded = partDataSource.getInt("need");
            }
         }
         else if(partData)
         {
            if(FarmGameSettingsManager.isInStorageConfigAMFExperiment())
            {
               if(partData.hasOwnProperty("limit"))
               {
                  numPartsNeeded = int(partData["limit"]);
               }
               if(numPartsNeeded == 0 && Boolean(partData.hasOwnProperty("need")))
               {
                  numPartsNeeded = int(partData["need"]);
               }
            }
            else
            {
               partXML = partData;
               if(partXML.attribute("limit").length() > 0)
               {
                  numPartsNeeded = int(partXML.@limit);
               }
               if(numPartsNeeded == 0 && partXML.attribute("need").length() > 0)
               {
                  numPartsNeeded = int(partXML.@need);
               }
            }
         }
         if(isSmartBuildablesEnabled() && this.usesSmartSystems() && (!Global.world.shouldIgnoreSmartBuildableRequirements(this) || level > this.m_storageLevel + 1))
         {
            numPartsNeeded = Math.ceil(numPartsNeeded * 1.2);
         }
         return numPartsNeeded;
      }
      
      public function getExpansionPartCount(itemCode:String) : int
      {
         var count:int = 0;
         if(this.m_expansionParts[itemCode])
         {
            count = int(this.m_expansionParts[itemCode]);
         }
         return count;
      }
      
      public function getTotalExpansionPartCount() : int
      {
         var expansionPartCount:int = 0;
         var count:int = 0;
         for each(expansionPartCount in this.m_expansionParts)
         {
            count += expansionPartCount;
         }
         return count;
      }
      
      public function getExpansionPartLimit(itemCode:String) : int
      {
         var buildingExpansionData:BuildingExpansionData = null;
         var partFarmItem:FarmItem = null;
         var part:PartItem = null;
         var upgradeDataSource:BaseDataSource = null;
         var partDataArray:Array = null;
         var farmItem:FarmItem = null;
         var partData:BaseDataSource = null;
         var upgradeData:XML = null;
         var item:FarmItem = null;
         var partList:XMLList = null;
         var limit:int = 0;
         if(isDynamicPartsExperimentOn())
         {
            buildingExpansionData = this.getNextBuildingExpansionData();
            if(buildingExpansionData)
            {
               partFarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
               if(partFarmItem)
               {
                  part = buildingExpansionData.getPartByCode(itemCode);
                  if(part)
                  {
                     limit = part.qtyNeeded;
                  }
               }
            }
         }
         else if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            upgradeDataSource = this.getNextExpansionDataSource();
            if(upgradeDataSource)
            {
               partDataArray = upgradeDataSource.getArray("part");
               if(partDataArray.length > 0)
               {
                  farmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
                  if(farmItem)
                  {
                     for each(partData in partDataArray)
                     {
                        if(partData.getString("name") == farmItem.name)
                        {
                           limit = partData.getInt("need");
                           break;
                        }
                     }
                  }
               }
            }
         }
         else
         {
            upgradeData = this.getNextExpansionData();
            if(Boolean(upgradeData) && Boolean(upgradeData.part))
            {
               item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
               if(item)
               {
                  partList = upgradeData.part.(@name == item.name);
                  if(partList.length())
                  {
                     limit = parseInt(partList[0].@need);
                  }
               }
            }
         }
         return limit;
      }
      
      public function get storageLevel() : int
      {
         return this.m_storageLevel;
      }
      
      public function set storageLevel(storageLevel:int) : void
      {
         this.m_storageLevel = storageLevel;
      }
      
      public function hasReachedMaxExpansionLevel() : Boolean
      {
         return !this.hasNextExpansion();
      }
      
      public function addExpansionPart(resource:MapResource) : Boolean
      {
         var buildingExpansionData:BuildingExpansionData = null;
         var part:PartItem = null;
         var resoureceItemCode:String = null;
         var numPartsNeeded:Number = NaN;
         var isExpansionComplete:Boolean = false;
         var parts:Vector.<PartItem> = null;
         var expansionPart:PartItem = null;
         var expansionPartItem:FarmItem = null;
         var partsNeeded:int = 0;
         var completedExpansion:Boolean = false;
         var upgradeDataSource:BaseDataSource = null;
         var partDataArray:Array = null;
         var resourceName:String = null;
         var partDataSource:BaseDataSource = null;
         var hasSpecifiedPart:Boolean = false;
         var resourceCode:String = null;
         var max:Number = NaN;
         var partName:String = null;
         var partFarmItem:FarmItem = null;
         var partNeed:int = 0;
         var upgradeData:XML = null;
         var itemName:String = null;
         var partList:XMLList = null;
         var partData:XML = null;
         var itemCode:String = null;
         var maxCount:Number = NaN;
         var partXml:XML = null;
         var partItem:FarmItem = null;
         var needed:int = 0;
         var success:Boolean = false;
         if(isDynamicPartsExperimentOn())
         {
            buildingExpansionData = this.getNextBuildingExpansionData();
            if(buildingExpansionData)
            {
               part = buildingExpansionData.getPartByName(resource.getItem().name);
               if(part)
               {
                  resoureceItemCode = resource.getItem().code;
                  numPartsNeeded = part.qtyNeeded;
                  if(!this.m_expansionParts[resoureceItemCode])
                  {
                     this.m_expansionParts[resoureceItemCode] = 0;
                  }
                  if(this.m_expansionParts[resoureceItemCode] < numPartsNeeded)
                  {
                     ++this.m_expansionParts[resoureceItemCode];
                     isExpansionComplete = true;
                     parts = buildingExpansionData.parts;
                     for each(expansionPart in parts)
                     {
                        expansionPartItem = expansionPart.item;
                        if(expansionPartItem)
                        {
                           partsNeeded = expansionPart.qtyNeeded;
                           if(!this.m_expansionParts[expansionPartItem.code] || this.m_expansionParts[expansionPartItem.code] < partsNeeded)
                           {
                              isExpansionComplete = false;
                              break;
                           }
                        }
                     }
                     if(isExpansionComplete)
                     {
                        this.completeExpansionLevel();
                     }
                     success = true;
                  }
               }
            }
         }
         else
         {
            completedExpansion = false;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               upgradeDataSource = this.getNextExpansionDataSource();
               if(upgradeDataSource)
               {
                  partDataArray = upgradeDataSource.getArray("part");
                  if(partDataArray.length > 0)
                  {
                     resourceName = resource.getItem().name;
                     hasSpecifiedPart = false;
                     for each(partDataSource in partDataArray)
                     {
                        if(partDataSource.getString("name") == resourceName)
                        {
                           hasSpecifiedPart = true;
                           break;
                        }
                     }
                     if(hasSpecifiedPart)
                     {
                        resourceCode = resource.getItem().code;
                        max = partDataSource.getInt("need");
                        if(!this.m_expansionParts[resourceCode])
                        {
                           this.m_expansionParts[resourceCode] = 0;
                        }
                        if(this.m_expansionParts[resourceCode] < max)
                        {
                           ++this.m_expansionParts[resourceCode];
                           completedExpansion = true;
                           for each(partDataSource in partDataArray)
                           {
                              partName = partDataSource.getString("name");
                              partFarmItem = Global.farmGameSettingsManager.getFarmItemByName(partName);
                              if(partFarmItem)
                              {
                                 partNeed = partDataSource.getInt("need");
                                 if(!this.m_expansionParts[partFarmItem.code] || this.m_expansionParts[partFarmItem.code] < partNeed)
                                 {
                                    completedExpansion = false;
                                    break;
                                 }
                              }
                           }
                        }
                        success = true;
                     }
                  }
               }
            }
            else
            {
               upgradeData = this.getNextExpansionData();
               if(Boolean(upgradeData) && Boolean(upgradeData.part))
               {
                  itemName = resource.getItem().name;
                  partList = upgradeData.part.(@name == itemName);
                  if(partList.length())
                  {
                     partData = partList[0];
                     itemCode = resource.getItem().code;
                     maxCount = parseInt(partData.@need);
                     if(!this.m_expansionParts[itemCode])
                     {
                        this.m_expansionParts[itemCode] = 0;
                     }
                     if(this.m_expansionParts[itemCode] < maxCount)
                     {
                        ++this.m_expansionParts[itemCode];
                        completedExpansion = true;
                        for each(partXml in upgradeData.part)
                        {
                           partItem = Global.farmGameSettingsManager.getFarmItemByName(partXml.@name);
                           if(partItem)
                           {
                              needed = parseInt(partXml.@need);
                              if(!this.m_expansionParts[partItem.code] || this.m_expansionParts[partItem.code] < needed)
                              {
                                 completedExpansion = false;
                                 break;
                              }
                           }
                        }
                     }
                     success = true;
                  }
               }
            }
            if(completedExpansion)
            {
               this.completeExpansionLevel();
            }
         }
         return success;
      }
      
      public function shouldShowOverlayOnHighlight() : Boolean
      {
         return true;
      }
      
      protected function shouldShowOverlayOnAdd() : Boolean
      {
         return true;
      }
      
      protected function checkAllowedItem(item:MapResource) : Boolean
      {
         return Global.storageSettings.storageCanTake(getItem().storageClass,item);
      }
      
      protected function checkBuildingMats(itemName:String, count:int) : Boolean
      {
         var partFarmItem:FarmItem = null;
         var numPartsNeeded:int = 0;
         var index:int = 0;
         var idx:int = 0;
         var result:Boolean = false;
         if(isDynamicPartsExperimentOn())
         {
            partFarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            numPartsNeeded = this.getItemLimit(partFarmItem);
            if(count < numPartsNeeded)
            {
               result = true;
            }
         }
         else if(FarmGameSettingsManager.isInStorageConfigAMFExperiment())
         {
            for(index = 0; index < this.storageFilter.itemNamesOpt.length; index++)
            {
               if(Boolean(this.storageFilter.itemNamesOpt[index].hasOwnProperty("value")) && itemName == this.storageFilter.itemNamesOpt[index]["value"])
               {
                  if(Boolean(this.storageFilter.itemNamesOpt[index].hasOwnProperty("need")) && count < this.storageFilter.itemNamesOpt[index]["need"])
                  {
                     result = true;
                  }
                  break;
               }
            }
         }
         else
         {
            for(idx = 0; idx < this.storageFilter.itemNames.length(); idx++)
            {
               if(itemName == this.storageFilter.itemNames[idx].toString())
               {
                  if(count < this.storageFilter.itemNames[idx].@need)
                  {
                     result = true;
                  }
                  break;
               }
            }
         }
         return result;
      }
      
      override public function loadObject(data:Object) : void
      {
         var objContents:Array = null;
         var idx:int = 0;
         var key:String = null;
         var upgradeDataSource:BaseDataSource = null;
         var upgradeData:XML = null;
         var buildingName:String = null;
         super.loadObject(data);
         if(data.paintColor)
         {
            this.m_paintColor = data.paintColor;
         }
         if(data.contents)
         {
            objContents = data.contents;
            for(idx = 0; idx < objContents.length; idx++)
            {
               key = this.getStorageKey(objContents[idx]);
               this.m_contents[key] = int(objContents[idx].numItem);
               this.m_count += int(objContents[idx].numItem);
               this.setNumImageStates();
            }
            if(this.m_count == 0)
            {
               setState(STATE_BUILT);
            }
         }
         if(data.hasOwnProperty("isFullyBuilt"))
         {
            this.m_isFullyBuilt = data.isFullyBuilt;
            if(!this.m_isFullyBuilt)
            {
               setState(this.STATE_CONSTRUCTION);
            }
         }
         if(data.expansionLevel > 1)
         {
            this.m_storageLevel = data.expansionLevel;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               upgradeDataSource = getItem().getUpgradeDataSource(this.m_storageLevel);
               if(upgradeDataSource)
               {
                  this.m_capacity = upgradeDataSource.getInt("capacity");
               }
            }
            else
            {
               upgradeData = getItem().getUpgradeData(this.m_storageLevel);
               if(upgradeData)
               {
                  this.m_capacity = upgradeData.@capacity;
               }
            }
         }
         if(data.expansionParts)
         {
            this.refreshExpansionParts(data.expansionParts);
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TRACK_WRONG_STORAGE_CAPACITY) == 1)
         {
            if(this.m_capacity < this.m_count)
            {
               buildingName = data.hasOwnProperty("itemName") ? data.itemName : "Building";
               FarmStatsManager.count("wrongBuildingCapacity",buildingName,"capacity_" + this.m_capacity,"","count_" + this.m_count,"",this.m_storageLevel);
            }
         }
      }
      
      public function refreshExpansionParts(parts:Object) : void
      {
         var code:String = null;
         if(parts)
         {
            for(code in parts)
            {
               this.m_expansionParts[code] = parts[code];
            }
         }
      }
      
      override public function getSaveObject() : Object
      {
         var obj:Object = super.getSaveObject();
         obj.contents = new Array();
         return obj;
      }
      
      protected function showStorageContextMenu() : Boolean
      {
         return this.m_count > 0 || !this.hasReachedMaxExpansionLevel() || this.isInventoryBuilding() && Global.player.getInventoryUsage() > 0;
      }
      
      override public function showMenu() : void
      {
         var validUpgradeStatus:Boolean = false;
         if(!this.isBuildingExperimentLocked())
         {
            if(this.showStorageContextMenu() && !this.hasDuplicate() && this.isStorageBuilding())
            {
               if(!this.m_isOffboarded)
               {
                  m_menuItems.unshift({
                     "label":ZLocUtils.t("Items","storage_remove"),
                     "action":this.REMOVEFROM_OBJECT
                  });
               }
            }
            if(ContextMenuQuestManager.instance.hasActiveQuest(getItemName()))
            {
               m_menuItems.unshift({
                  "label":ZLocUtils.t("Dialogs","menu_open_context_quest"),
                  "action":this.CONTEXT_QUEST
               });
            }
            validUpgradeStatus = Global.player.upgradeStatus.hasOwnProperty("isActive");
            if(validUpgradeStatus && this.getItem().getExpansion() != "")
            {
               m_menuItems.push({
                  "label":ZLocUtils.t("Items","storage_expand"),
                  "action":this.EXPAND_OBJECT
               });
            }
         }
         super.showMenu();
      }
      
      private function hasDuplicate() : Boolean
      {
         var dup:Boolean = false;
         var length:int = int(m_menuItems.length);
         var stringToCompare:String = ZLocUtils.t("Items","storage_remove");
         for(var idx:int = 0; idx < length; idx++)
         {
            if(m_menuItems[idx].label == stringToCompare)
            {
               dup = true;
               break;
            }
         }
         return dup;
      }
      
      override public function isStorage() : Boolean
      {
         return true;
      }
      
      public function getStorageItemClass() : String
      {
         return m_item.storageClass;
      }
      
      public function usesSmartSystems() : Boolean
      {
         var result:Boolean = false;
         var buildingItem:BuildingItem = m_item as BuildingItem;
         if(buildingItem)
         {
            result = buildingItem.usesSmartSystems;
         }
         return result;
      }
      
      public function buildContainedItem(key:String) : Object
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(key);
         var realName:String = Global.farmGameSettingsManager.getFarmItemNameByCode(key);
         return {
            "item":item,
            "num":this.m_contents[key],
            "code":key,
            "name":realName
         };
      }
      
      public function getContents() : Array
      {
         var key:String = null;
         var itemsContained:Array = new Array();
         for(key in this.m_contents)
         {
            if(this.m_contents[key] > 0)
            {
               itemsContained.push(this.buildContainedItem(key));
            }
         }
         return itemsContained;
      }
      
      public function getStorageTypes() : Array
      {
         var itemData:Object = null;
         var itemOpt:FarmItem = null;
         var quantityOpt:int = 0;
         var saleCodeOpt:String = null;
         var itemXML:XML = null;
         var item:FarmItem = null;
         var quantity:int = 0;
         var saleCode:String = null;
         var itemsContained:Array = [];
         var storageFilter:StorageFilter = Global.storageSettings.getStorageFilter(this.getStorageItemClass());
         if(FarmGameSettingsManager.isInStorageConfigAMFExperiment())
         {
            for each(itemData in storageFilter.itemNamesOpt)
            {
               itemOpt = Global.farmGameSettingsManager.getFarmItemByName(itemData.toString());
               if(itemOpt)
               {
                  quantityOpt = this.m_contents.hasOwnProperty(itemOpt.code) ? int(this.m_contents[itemOpt.code]) : 0;
                  if(FarmGameSettingsManager.isInDataSourceExperiment())
                  {
                     saleCodeOpt = itemOpt.saleCode;
                     if(Boolean(saleCodeOpt) && itemOpt.name + FarmItem.ITEM_POSTFIX_SALE == itemData.toString())
                     {
                        quantityOpt += this.m_contents.hasOwnProperty(saleCodeOpt) ? this.m_contents[saleCodeOpt] : 0;
                     }
                     itemsContained.push({
                        "item":itemOpt,
                        "num":quantityOpt,
                        "object":itemData
                     });
                  }
                  else
                  {
                     if(itemOpt.saleXML != null && itemOpt.name + FarmItem.ITEM_POSTFIX_SALE == itemData.toString())
                     {
                        quantityOpt += this.m_contents.hasOwnProperty(itemOpt.saleXML.@code.toString()) ? this.m_contents[itemOpt.saleXML.@code.toString()] : 0;
                     }
                     itemsContained.push({
                        "item":itemOpt,
                        "num":quantityOpt,
                        "object":itemData
                     });
                  }
               }
            }
         }
         else
         {
            for each(itemXML in storageFilter.itemNames)
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(itemXML.toString());
               if(item)
               {
                  quantity = this.m_contents.hasOwnProperty(item.code) ? int(this.m_contents[item.code]) : 0;
                  if(FarmGameSettingsManager.isInDataSourceExperiment())
                  {
                     saleCode = item.saleCode;
                     if(Boolean(saleCode) && item.name + FarmItem.ITEM_POSTFIX_SALE == itemXML.toString())
                     {
                        quantity += this.m_contents.hasOwnProperty(saleCode) ? this.m_contents[saleCode] : 0;
                     }
                     itemsContained.push({
                        "item":item,
                        "num":quantity,
                        "xml":itemXML
                     });
                  }
                  else
                  {
                     if(item.saleXML != null && item.name + FarmItem.ITEM_POSTFIX_SALE == itemXML.toString())
                     {
                        quantity += this.m_contents.hasOwnProperty(item.saleXML.@code.toString()) ? this.m_contents[item.saleXML.@code.toString()] : 0;
                     }
                     itemsContained.push({
                        "item":item,
                        "num":quantity,
                        "xml":itemXML
                     });
                  }
               }
            }
         }
         return itemsContained;
      }
      
      public function showInInventoryWithdrawal() : Boolean
      {
         return true;
      }
      
      public function getConstructionItems() : Array
      {
         var part:PartItem = null;
         var code:String = null;
         var resultItems:Array = new Array();
         var constructionItems:Array = Global.storageSettings.getConstructionParts(this.getStorageItemClass(),this);
         for each(part in constructionItems)
         {
            code = part.item.code;
            part.onHand = this.getCurrentLevelConstructionItemCount(code);
            resultItems.push(part);
         }
         return resultItems;
      }
      
      public function getCurrentLevelConstructionItemCount(itemCode:String) : int
      {
         var count:int = 0;
         if(this.isFullyBuilt())
         {
            count = this.m_expansionParts.hasOwnProperty(itemCode) ? int(this.m_expansionParts[itemCode]) : 0;
         }
         else
         {
            count = this.m_contents.hasOwnProperty(itemCode) ? int(this.m_contents[itemCode]) : 0;
         }
         return count;
      }
      
      public function getTotalPartsNeededForItem(itemCode:String) : int
      {
         var constructionItem:PartItem = null;
         var result:int = 0;
         var constructionItems:Array = Global.storageSettings.getConstructionParts(this.getStorageItemClass(),this);
         for each(constructionItem in constructionItems)
         {
            if(constructionItem.item.code == itemCode)
            {
               result = constructionItem.qtyNeeded;
               break;
            }
         }
         return result;
      }
      
      public function getPartsOnHand() : Number
      {
         var part:PartItem = null;
         var constructionItems:Array = this.getConstructionItems();
         var partsOnHand:Number = 0;
         for each(part in constructionItems)
         {
            partsOnHand += part.onHand;
         }
         return partsOnHand;
      }
      
      public function getCashNeeded(partcost:int = 1) : Number
      {
         var buildingContents:Array = null;
         var index:int = 0;
         var partItem:PartItem = null;
         var cashCost:Number = NaN;
         var needed:int = 0;
         var result:int = 0;
         var overridePrice:Number = Global.farmGameSettingsManager.getNumber(this.getItemName() + this.OVERRIDE_COMPLETE_NOW);
         if(HangingGardensManager.isInHangingGardensExperiment() && Boolean(overridePrice))
         {
            result = overridePrice;
         }
         else
         {
            buildingContents = this.getConstructionItems();
            for(index = 0; index < buildingContents.length; index++)
            {
               partItem = buildingContents[index];
               cashCost = Number(partItem.item.cash);
               needed = partItem.qtyNeeded - partItem.onHand;
               if(needed < 0)
               {
                  needed = 0;
               }
               result += needed * cashCost;
            }
         }
         return result;
      }
      
      public function getMostNeededItem() : PartItem
      {
         var partItem:PartItem = null;
         var buildingContents:Array = this.getConstructionItems();
         var maxDifference:Number = -1;
         var mostNeededPart:PartItem = null;
         for each(partItem in buildingContents)
         {
            if(maxDifference < 0 || partItem.qtyNeeded - partItem.onHand > maxDifference)
            {
               maxDifference = partItem.qtyNeeded - partItem.onHand;
               mostNeededPart = partItem;
            }
         }
         return mostNeededPart;
      }
      
      public function getPartsString() : String
      {
         var partItem:PartItem = null;
         var result:String = "";
         var buildingContents:Array = this.getConstructionItems();
         var firstItem:Boolean = true;
         for each(partItem in buildingContents)
         {
            if(firstItem)
            {
               result = partItem.item.name;
               firstItem = false;
            }
            else
            {
               result += "," + partItem.item.name;
            }
         }
         return result;
      }
      
      public function getPartsArray() : Array
      {
         var partItem:PartItem = null;
         var result:Array = [];
         var buildingContents:Array = this.getConstructionItems();
         for each(partItem in buildingContents)
         {
            result.push(partItem.item.name);
         }
         return result;
      }
      
      public function getCurrentSuffix() : int
      {
         var initialExpansionLevel:int = 0;
         var intervalBreak:Number = NaN;
         var result:int = 0;
         var numImageStates:int = m_numImageStates;
         var capacity:int = this.m_capacity;
         if(!this.m_isFullyBuilt)
         {
            numImageStates = this.m_numConstructImageStates;
            capacity = this.getMaterialsNeeded();
            if(this.m_count < capacity)
            {
               numImageStates++;
            }
         }
         if(numImageStates > 1)
         {
            intervalBreak = capacity / (numImageStates - 1);
            if(this.m_count > capacity)
            {
               this.m_count = capacity;
            }
            result = int(Math.floor(this.m_count / intervalBreak));
         }
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(m_item.hasPropertyInDataSource("initialExpansionLevel"))
            {
               initialExpansionLevel = m_item.getIntFromDataSource("initialExpansionLevel");
               result = Math.max(result,initialExpansionLevel);
            }
         }
         else if(m_item.xml.hasOwnProperty("initialExpansionLevel"))
         {
            initialExpansionLevel = int(m_item.xml.initialExpansionLevel);
            result = Math.max(result,initialExpansionLevel);
         }
         return result;
      }
      
      override public function getCurrentImageName() : String
      {
         var suffix:int = 0;
         var builtNo:String = null;
         var imageName:String = null;
         switch(state)
         {
            case STATE_BUSY:
            case this.STATE_CONSTRUCTION:
               imageName = this.getConstructionImageName();
               m_arrow = null;
               break;
            case STATE_PREVIEW:
               if(this.m_isFullyBuilt)
               {
                  imageName = "built_" + this.getCurrentSuffix();
               }
               else
               {
                  imageName = "construct_" + this.getCurrentSuffix();
               }
               m_arrow = null;
               break;
            case STATE_BUILT:
            case STATE_BARE:
               suffix = this.getCurrentSuffix();
               if(suffix >= 0)
               {
                  imageName = "built_" + suffix;
               }
               else
               {
                  imageName = "construct_0";
               }
               if(this.m_nullArrow)
               {
                  m_arrow = null;
               }
               if(Boolean(Global.flashHotParams["TOY_MANSION_RED_BOX_FIX"]) && Global.flashHotParams["TOY_MANSION_RED_BOX_FIX"] == true)
               {
                  if(m_item.code == "08vg" && suffix == 9)
                  {
                     imageName = "built_8";
                  }
               }
               break;
            case STATE_RIPE:
               imageName = "built_" + this.getCurrentSuffix();
               if(m_arrow == null)
               {
                  m_arrow = generateHarvestArrow();
               }
               break;
            default:
               imageName = super.getCurrentImageName();
         }
         if(m_arrow != null)
         {
            m_hideArrow = false;
         }
         if((m_item.code == FarmvilleAnniversaryV10DecorateBarn.NURSERY_BARN_BUILT_FINISHED || m_item.code == FarmvilleAnniversaryV10DecorateBarn.NURSERY_BARN_BUILT_INCOMPLETE) && this.m_isFullyBuilt && Global.worldManager.currentWorldType == "farm")
         {
            builtNo = FeatureOptionsManager.getInstance().getFeatureOption(FarmvilleAnniversaryV10DecorateBarn.NURSERY_BARN_ANNIVERSARY_DECORATION,FarmvilleAnniversaryV10DecorateBarn.NURSERY_BARN_BUILT_NUMBER) as String;
            if(builtNo)
            {
               imageName = "built_" + builtNo;
            }
         }
         return imageName;
      }
      
      protected function getConstructionImageName() : String
      {
         return "construct_" + this.getCurrentSuffix();
      }
      
      override public function postProcessImageName(name:String) : String
      {
         var imageName:String = name;
         if(this.m_paintColor)
         {
            imageName += "_" + this.m_paintColor;
         }
         return super.postProcessImageName(imageName);
      }
      
      public function removeContents(itemCode:String, itemCount:int = 1, itemParts:int = 0) : void
      {
         this.m_contents[itemCode] -= itemCount;
         this.resetCount();
      }
      
      public function matchesOrigin(originId:int) : Boolean
      {
         var result:Boolean = false;
         if(this.getId() == originId || this.isInventoryBuilding() && originId == Global.worldManager.getCurrentWorldStorageId())
         {
            result = true;
         }
         return result;
      }
      
      public function setAmount(itemCode:String, amount:int) : void
      {
         this.m_contents[itemCode] = amount;
         this.resetCount();
      }
      
      public function getAmount(itemCode:String) : Number
      {
         var count:Number = this.m_contents.hasOwnProperty(itemCode) ? Number(this.m_contents[itemCode]) : 0;
         if(0 == count && Boolean(this.m_expansionParts[itemCode]))
         {
            count = Number(this.m_expansionParts[itemCode]);
         }
         return count;
      }
      
      public function getInventoryPartCountUseable(item:PartItem) : int
      {
         var partsNeeded:int = this.getPartsNeeded(item);
         var partsInInventory:int = this.getInventoryPartCount(item);
         return Math.min(partsInInventory,partsNeeded);
      }
      
      protected function getPartsNeeded(partItem:PartItem) : int
      {
         var partFarmItem:FarmItem = partItem.item;
         var partLimit:int = this.getItemLimit(partFarmItem);
         return partLimit - this.getAmount(partFarmItem.code);
      }
      
      protected function getInventoryPartCount(partItem:PartItem) : int
      {
         var result:Number = NaN;
         var currencyName:String = partItem.getCurrency();
         if(currencyName)
         {
            result = Global.player.getWorldCurrencyTotal(currencyName);
         }
         else
         {
            result = Global.player.getGiftCountForItem(partItem.item.name);
         }
         return result;
      }
      
      protected function get storageFilter() : StorageFilter
      {
         return Global.storageSettings.getStorageFilter(getItem().storageClass);
      }
      
      public function getItemLimit(item:FarmItem) : Number
      {
         return getItemLimitForStorageBuilding(this,item);
      }
      
      override public function isSellable() : Boolean
      {
         var result:Boolean = super.isSellable();
         if(this.isInventoryBuilding() && Global.player.getInventoryCapacity(true) - Global.player.getInventoryUsage() < this.capacity)
         {
            result = false;
         }
         return result;
      }
      
      protected function resetCount() : void
      {
         var key:String = null;
         this.m_count = 0;
         for(key in this.m_contents)
         {
            this.m_count += this.m_contents[key];
         }
         if(this.m_count == 0)
         {
            setState(STATE_BUILT);
         }
         else
         {
            setState(state);
         }
      }
      
      override public function isClearable() : Boolean
      {
         var result:Boolean = true;
         if(Boolean(!m_item.allowDelete) && Boolean(Global.flashHotParams["STORAGE_DELETE_FIX_TEMPRT"]) || this.isInventoryBuilding() && Global.player.getInventoryCapacity(true) - Global.player.getInventoryUsage() < this.capacity)
         {
            result = false;
         }
         return result;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case this.REMOVEFROM_OBJECT:
                  if(this.isInventoryBuilding())
                  {
                     UI.displayInventoryDialog("inventory",this);
                     FarmStatsManager.sample(100,"Storage","accessing_goods","storage_menu");
                  }
                  else if(this.isStorageBuilding())
                  {
                     this.displayStorageDialog();
                  }
                  break;
               case this.EXPAND_OBJECT:
                  UI.displayInventoryDialog(this.UPGRADE_STORAGE,this);
                  break;
               case SELL_OBJECT:
                  if(!this.isSellable())
                  {
                     UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","SellInventoryFail")));
                  }
                  else
                  {
                     super.onMenuClick(event);
                  }
                  break;
               case this.CONTEXT_QUEST:
                  ContextMenuQuestManager.instance.openQuest(getItemName());
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      public function displayStorageDialog(defaultAction:String = "") : void
      {
         UI.displayStorageDialog(new StorageWithdrawal(this));
      }
      
      override protected function buildTooltipText() : String
      {
         var toolTip:String = null;
         if(isHighlighted())
         {
            if(Global.worldManager.isVisiting())
            {
               toolTip = m_item.friendlyTitle;
            }
            else
            {
               toolTip = m_item.friendlyTitle + "\n" + this.getOwnerToolTipText();
            }
         }
         return toolTip;
      }
      
      protected function getOwnerToolTipText() : String
      {
         var count:int = 0;
         var capacity:int = 0;
         var result:String = "";
         var mode:GameMode = Global.world.getTopGameMode();
         if(mode is GMBuildingPart)
         {
            result = this.getBuildingPartCapacityToolTipText((mode as GMBuildingPart).buildingPart.itemName);
         }
         else
         {
            count = Global.player.getInventoryUsage();
            capacity = Global.player.getInventoryCapacity();
            result = ZLocUtils.t("Items","storage_capacity",{
               "quantity":count,
               "maximum":capacity
            });
         }
         return result;
      }
      
      protected function getBuildingPartCapacityToolTipText(buildingPartName:String) : String
      {
         var tooltipText:String = "";
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(buildingPartName);
         if(item)
         {
            if(this.isFullyBuilt())
            {
               tooltipText = ZLocUtils.t("Items","buildingpart_capacity",{
                  "item":ZLocUtils.tk_pk(item.friendlyName),
                  "quantity":this.getExpansionPartCount(item.code),
                  "maximum":this.getExpansionPartLimit(item.code)
               });
            }
            else
            {
               tooltipText = ZLocUtils.t("Items","buildingpart_capacity",{
                  "item":ZLocUtils.tk_pk(item.friendlyName),
                  "quantity":this.getAmount(item.code),
                  "maximum":this.getItemLimit(item)
               });
            }
         }
         return tooltipText;
      }
      
      override protected function postSellAction() : void
      {
         var farmItem:FarmItem = null;
         var key:String = null;
         if(!this.inventoryIsSellable())
         {
            for(key in this.m_contents)
            {
               if(key != "null" && this.m_contents[key] > 0)
               {
                  farmItem = Global.farmGameSettingsManager.getFarmItemByCode(key);
                  if(farmItem != null)
                  {
                     Global.player.addGift(farmItem.name,"0",this.m_contents[key]);
                  }
               }
            }
         }
      }
      
      override protected function getSellDisplayMessage() : String
      {
         var countingPrices:String = null;
         var curItemCount:int = 0;
         var currencyUnit:String = null;
         var params:Object = null;
         var message:String = null;
         var messageKey:String = null;
         var customMessageKey:String = null;
         var sellPrices:Dictionary = this.getSellPrices();
         var costCurrencyString:String = "";
         var sellPricesCount:int = 0;
         for(countingPrices in sellPrices)
         {
            sellPricesCount++;
         }
         curItemCount = 1;
         for(currencyUnit in sellPrices)
         {
            if(curItemCount > 1)
            {
               costCurrencyString += " ";
            }
            if(curItemCount == sellPricesCount && sellPricesCount > 1)
            {
               costCurrencyString += ZLocUtils.t("FarmGame","and") + " ";
            }
            costCurrencyString += sellPrices[currencyUnit] + " " + ZLocUtils.t("FarmGame",currencyUnit);
            curItemCount++;
         }
         params = {
            "item":ZLocUtils.tk_pk(getItemFriendlyName()),
            "costCurrencyString":costCurrencyString
         };
         messageKey = "SellStorageBuildingSpecific";
         customMessageKey = messageKey + "_" + getItemName();
         if(ZLocUtils.hasString("Dialogs",customMessageKey))
         {
            message = ZLocUtils.t("Dialogs",customMessageKey,params);
         }
         else
         {
            message = ZLocUtils.t("FarmGame","SellStorageBuildingSpecific",params);
         }
         return message;
      }
      
      override protected function getSellPrice() : int
      {
         var sellPrices:Dictionary = this.getSellPrices();
         return sellPrices[this.m_item.sellCurrency];
      }
      
      protected function getSellPrices() : Dictionary
      {
         var inventoryItem:FarmItem = null;
         var key:String = null;
         var sellAmounts:Dictionary = new Dictionary();
         var buildingSellCurrency:String = m_item.sellCurrency;
         var buildingSellPrice:int = m_item.sellPrice;
         sellAmounts[buildingSellCurrency] = buildingSellPrice;
         var inventorySellPrice:int = 0;
         var inventorySellCurrency:String = Currency.COINS;
         if(!this.isInventoryBuilding() && this.inventoryIsSellable())
         {
            for(key in this.m_contents)
            {
               if(key != "null" && this.m_contents[key] > 0)
               {
                  inventoryItem = Global.farmGameSettingsManager.getFarmItemByCode(key);
                  inventorySellCurrency = inventoryItem.sellCurrency;
                  inventorySellPrice = this.m_contents[key] * inventoryItem.sellPrice;
                  sellAmounts[inventorySellCurrency] = sellAmounts[inventorySellCurrency] == null ? inventorySellPrice : inventorySellPrice + sellAmounts[inventorySellCurrency];
               }
            }
         }
         return sellAmounts;
      }
      
      override protected function executeSell() : void
      {
         var currencyUnit:String = null;
         var sellAmounts:Dictionary = this.getSellPrices();
         var status:String = "";
         for(currencyUnit in sellAmounts)
         {
            Global.player.updateWorldCurrency(currencyUnit,sellAmounts[currencyUnit]);
            status += ZLocUtils.t("FarmGame","Status_ObjectSold",{
               "coinNum":sellAmounts[currencyUnit],
               "currency":ZLocUtils.t("FarmGame",currencyUnit)
            }) + " ";
         }
         displayStatus(status);
      }
      
      public function get capacity() : Number
      {
         var capacity:int = this.m_capacity;
         if(!this.isFullyBuilt())
         {
            capacity = this.getMaterialsNeeded();
         }
         return capacity;
      }
      
      public function get maxPotentialCapacity() : Number
      {
         return this.m_capacity;
      }
      
      public function get numImageStates() : int
      {
         return m_numImageStates;
      }
      
      public function get count() : Number
      {
         return this.m_count;
      }
      
      public function grantUpgradeAwards(result:Object) : void
      {
      }
      
      public function onStoreComplete(result:Object) : void
      {
         if(result.hasOwnProperty("expansionRewardLink") && Boolean(result.expansionRewardLink))
         {
            result.rewardLink = result.expansionRewardLink;
         }
         if(Boolean(result.rewardLink) && Boolean(result.expansionRewardType) && Boolean(result.rewardItem))
         {
            switch(result.expansionRewardType)
            {
               case this.EXPANSION_REWARD_TYPE_PART:
                  this.onCompleteExpansionPart(result.rewardLink,result.rewardItem);
                  break;
               case this.EXPANSION_REWARD_TYPE_HALF_COMPLETE:
                  this.onCompleteHalfExpansion(result.rewardLink);
                  break;
               case this.EXPANSION_REWARD_TYPE_COMPLETE:
                  if(isSmartBuildablesEnabled())
                  {
                     this.applySmartSystems(result);
                  }
                  this.onCompleteExpansion(result.rewardLink,result.rewardItem);
                  break;
               case this.EXPANSION_REWARD_TYPE_PARTS_INTERVAL:
                  this.onCompleteExpansionPartsInterval(result.rewardLink,result.rewardItem);
            }
         }
      }
      
      protected function onCompleteExpansion(rewardLink:String, itemName:String) : void
      {
      }
      
      protected function onCompleteHalfExpansion(rewardLink:String) : void
      {
      }
      
      protected function onCompleteExpansionPart(rewardLink:String, itemName:String) : void
      {
      }
      
      protected function onCompleteExpansionPartsInterval(rewardLink:String, itemName:String) : void
      {
      }
      
      override protected function onBuilt() : void
      {
         var itemName:String = null;
         var amount:int = 0;
         var defaultItem:FarmItem = null;
         var flagName:String = null;
         var buyStorageDialog:GenericPopup = null;
         var defaultItemArr:Array = null;
         var curDS:BaseDataSource = null;
         var item:XML = null;
         var canAddItems:Boolean = true;
         var seenStoragePopup:String = "BuyStoragePopup";
         var itemIdx:int = 0;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(m_item.hasPropertyInDataSource("defaultItem"))
            {
               if(m_item.getBoolFromDataSource("addDefaultItemsOnce"))
               {
                  flagName = "defaultItems_" + item["@code"];
                  if(Global.player.getSeenFlag(flagName))
                  {
                     canAddItems = false;
                  }
                  else
                  {
                     Global.player.setSeenFlag(flagName);
                  }
               }
               if(this.m_item.storageClass == this.INVENTORY_CLASSNAME && !Global.player.getSeenFlag(seenStoragePopup))
               {
                  buyStorageDialog = new GenericPopup(ZLocUtils.t("Dialogs","BuyStorageDialog"));
                  UI.displayPopup(buyStorageDialog);
                  Global.player.setSeenFlag(seenStoragePopup);
               }
               if(canAddItems)
               {
                  defaultItemArr = m_item.getArrayFromDataSource("defaultItem");
                  for(itemIdx = 0; itemIdx < defaultItemArr.length; itemIdx++)
                  {
                     curDS = defaultItemArr[itemIdx] as BaseDataSource;
                     itemName = curDS.getString("name");
                     amount = curDS.getInt("amount");
                     defaultItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
                     if(defaultItem)
                     {
                        this.addDefaultItems(defaultItem,amount);
                     }
                  }
               }
            }
         }
         else
         {
            item = m_item.xml;
            if(item.defaultItem)
            {
               if("true" == item.addDefaultItemsOnce)
               {
                  flagName = "defaultItems_" + item["@code"];
                  if(Global.player.getSeenFlag(flagName))
                  {
                     canAddItems = false;
                  }
                  else
                  {
                     Global.player.setSeenFlag(flagName);
                  }
               }
               if(this.m_item.storageClass == this.INVENTORY_CLASSNAME && !Global.player.getSeenFlag(seenStoragePopup))
               {
                  buyStorageDialog = new GenericPopup(ZLocUtils.t("Dialogs","BuyStorageDialog"));
                  UI.displayPopup(buyStorageDialog);
                  Global.player.setSeenFlag(seenStoragePopup);
               }
               if(canAddItems)
               {
                  for(itemIdx = 0; itemIdx < item.defaultItem.length(); itemIdx++)
                  {
                     itemName = item.defaultItem[itemIdx]["@name"];
                     amount = int(item.defaultItem[itemIdx]["@amount"]);
                     defaultItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
                     if(defaultItem)
                     {
                        this.addDefaultItems(defaultItem,amount);
                     }
                  }
               }
            }
         }
      }
      
      protected function addDefaultItems(defaultItem:FarmItem, amount:int) : void
      {
         this.m_contents[defaultItem.code] = amount;
         this.m_count += amount;
      }
      
      public function isFullyBuilt() : Boolean
      {
         return this.m_isFullyBuilt;
      }
      
      public function buildStatusMessage(messageData:Array) : String
      {
         return "";
      }
      
      public function setPaintColor(paintColor:String) : void
      {
         this.m_paintColor = paintColor;
      }
      
      public function isPaintable(paintItemName:String) : Boolean
      {
         var buildingItem:BuildingItem = null;
         var paintItem:FarmItem = null;
         var paintColor:String = null;
         var canPaint:Boolean = false;
         if(this.isFullyBuilt())
         {
            buildingItem = this.getItem() as BuildingItem;
            if(Boolean(buildingItem) && buildingItem.paintable == true)
            {
               paintItem = Global.farmGameSettingsManager.getFarmItemByName(paintItemName);
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  paintColor = paintItem.getStringFromDataSource("paintColor");
               }
               else if(paintItem.xml.paintColor)
               {
                  paintColor = paintItem.xml.paintColor.toString();
               }
               if(this.m_paintColor != paintColor)
               {
                  canPaint = true;
               }
            }
         }
         return canPaint;
      }
      
      public function getBuildingIcon(finished:Boolean = true) : String
      {
         var iconUrl:String = "";
         if(finished)
         {
            iconUrl = this.getFinishedBuildingIcon();
         }
         if(iconUrl == "")
         {
            iconUrl = this.getItem().icon;
         }
         return iconUrl;
      }
      
      private function getFinishedBuildingIcon() : String
      {
         var iconUrl:String = "";
         var finishedItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.getItem().getFinishedName());
         if(finishedItem)
         {
            iconUrl = finishedItem.icon;
         }
         return iconUrl;
      }
      
      override public function getInventoryCode() : String
      {
         var storageLevel:int = 0;
         var inventoryCode:String = Global.farmGameSettingsManager.getFarmItemCodeByName(this.getItemName());
         if(this.hasOwnProperty("storageLevel"))
         {
            storageLevel = this.storageLevel;
            if(storageLevel > 0)
            {
               inventoryCode = inventoryCode + ":" + storageLevel;
            }
         }
         return inventoryCode;
      }
      
      public function nextExpansionPartsNeeded() : Object
      {
         var buildingExpansionData:BuildingExpansionData = null;
         var parts:Vector.<PartItem> = null;
         var part:PartItem = null;
         var partFarmItem:FarmItem = null;
         var partItemCode:String = null;
         var numPartsNeeded:Number = NaN;
         var numPartsOwned:Number = NaN;
         var upgradeDataSource:BaseDataSource = null;
         var partDataArray:Array = null;
         var partData:BaseDataSource = null;
         var farmItem:FarmItem = null;
         var partCode:String = null;
         var partNeed:Number = NaN;
         var partCurrent:Number = NaN;
         var upgradeData:XML = null;
         var partXml:XML = null;
         var partItem:FarmItem = null;
         var code:String = null;
         var needed:Number = NaN;
         var current:Number = NaN;
         var result:Object = null;
         if(isDynamicPartsExperimentOn())
         {
            buildingExpansionData = this.getNextBuildingExpansionData();
            if(buildingExpansionData)
            {
               parts = buildingExpansionData.parts;
               if(parts)
               {
                  result = {};
                  for each(part in parts)
                  {
                     partFarmItem = part.item;
                     if(partFarmItem)
                     {
                        partItemCode = partFarmItem.code;
                        numPartsNeeded = part.qtyNeeded;
                        numPartsOwned = this.getExpansionPartCount(partItemCode);
                        if(numPartsOwned <= numPartsNeeded)
                        {
                           result[partItemCode] = numPartsNeeded - numPartsOwned;
                        }
                        else
                        {
                           result[partItemCode] = 0;
                        }
                     }
                  }
               }
            }
         }
         else if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            upgradeDataSource = this.getNextExpansionDataSource();
            if(upgradeDataSource)
            {
               partDataArray = upgradeDataSource.getArray("part");
               if(partDataArray.length > 0)
               {
                  result = {};
                  for each(partData in partDataArray)
                  {
                     farmItem = Global.farmGameSettingsManager.getFarmItemByName(partData.getString("name"));
                     if(farmItem)
                     {
                        partCode = farmItem.code;
                        partNeed = partData.getNumber("need");
                        partCurrent = this.getExpansionPartCount(partCode);
                        if(partCurrent <= partNeed)
                        {
                           result[partCode] = partCurrent - partNeed;
                        }
                        else
                        {
                           result[partCode] = 0;
                        }
                     }
                  }
               }
            }
         }
         else
         {
            upgradeData = this.getNextExpansionData();
            if(Boolean(upgradeData) && Boolean(upgradeData.part))
            {
               result = {};
               for each(partXml in upgradeData.part)
               {
                  partItem = Global.farmGameSettingsManager.getFarmItemByName(partXml.@name);
                  if(partItem)
                  {
                     code = partItem.code;
                     needed = parseInt(partXml.@need);
                     current = this.getExpansionPartCount(code);
                     result[code] = needed - current;
                     if(current <= needed)
                     {
                        result[code] = needed - current;
                     }
                     else
                     {
                        result[code] = 0;
                     }
                  }
               }
            }
         }
         return result;
      }
      
      public function nextExpansionPartsNumberNeeded() : int
      {
         var objectKey:String = null;
         var partsObject:Object = this.nextExpansionPartsNeeded();
         var result:int = 0;
         for(objectKey in partsObject)
         {
            result += partsObject[objectKey];
         }
         return result;
      }
      
      public function expandToNextStorageLevel() : Boolean
      {
         var itemCode:String = null;
         var partItem:FarmItem = null;
         var qtyNeeded:Number = NaN;
         var buildingPart:BuildingPart = null;
         var parts:int = 0;
         var result:Boolean = false;
         var expansionParts:Object = this.nextExpansionPartsNeeded();
         var partsAdded:int = 0;
         if(expansionParts != null)
         {
            for(itemCode in expansionParts)
            {
               partItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
               qtyNeeded = Number(expansionParts[itemCode]);
               buildingPart = new BuildingPart(partItem.name);
               partsAdded += qtyNeeded;
               for(parts = 0; parts < qtyNeeded; parts++)
               {
                  this.addItem(buildingPart,0,false,false);
               }
            }
            if(partsAdded <= 0)
            {
               this.completeExpansionLevel();
            }
            result = true;
         }
         return result;
      }
      
      public function completeBuildable() : void
      {
         this.m_completeNowInProgress = true;
         while(!this.hasReachedMaxExpansionLevel())
         {
            this.expandToNextStorageLevel();
         }
         this.m_completeNowInProgress = false;
      }
      
      protected function completeExpansionLevel() : void
      {
         this.m_capacity = this.getNextExpansionCapacity();
         ++this.m_storageLevel;
         this.m_expansionParts = new Dictionary();
      }
      
      public function onApplyMaxPossibleBuildingParts(buildingPartName:String, miniMarketItems:Array, combineTransactions:Boolean = true) : Object
      {
         var buildingPartItem:FarmItem = null;
         var numApplied:Number = NaN;
         var itemLimit:Number = NaN;
         var numNeeded:Number = NaN;
         var result:Object = {
            "success":false,
            "numAdded":0
         };
         var buildingPartCount:Number = Global.player.getGiftCountForItem(buildingPartName);
         if(buildingPartCount <= 0)
         {
            UI.displayMiniMarketDialog(miniMarketItems);
            result.success = false;
         }
         else
         {
            buildingPartItem = Global.farmGameSettingsManager.getFarmItemByName(buildingPartName);
            if(buildingPartItem != null)
            {
               numApplied = this.getAmount(buildingPartItem.code);
               itemLimit = this.getItemLimit(buildingPartItem);
               numNeeded = itemLimit - numApplied;
               if(numNeeded > buildingPartCount)
               {
                  numNeeded = buildingPartCount;
               }
               buildingPartItem.onUse(this.getId(),{
                  "isGift":true,
                  "suppressGiftRepop":true,
                  "storageBuilding":this,
                  "numParts":numNeeded,
                  "combineTransactions":combineTransactions
               });
               result.success = true;
               result.numAdded = numNeeded;
            }
         }
         return result;
      }
      
      public function applySmartSystems(result:Object) : int
      {
         var partsAdded:int = 0;
         if(result.hasOwnProperty(SMART_SYSTEM_RESULTS_KEY))
         {
            this.tuneHarderForSmartSystems();
            this.refreshExpansionParts(result[SMART_SYSTEM_RESULTS_KEY]);
            partsAdded = this.getTotalExpansionPartCount();
         }
         return partsAdded;
      }
      
      protected function tuneHarderForSmartSystems() : void
      {
         if(Global.world.shouldIgnoreSmartBuildableRequirements(this))
         {
            Global.world.setIgnoreSmartBuildableRequirementsFlag(false,this);
            this.m_buildingExpansionData = new Dictionary();
         }
      }
      
      override public function onBuildComplete(result:Object) : void
      {
         if(isSmartBuildablesEnabled())
         {
            this.applySmartSystems(result);
         }
         super.onBuildComplete(result);
      }
   }
}

