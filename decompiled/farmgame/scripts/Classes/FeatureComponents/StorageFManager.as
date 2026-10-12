package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.MapResource;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.storage.StorageFilter;
   import Classes.util.FarmGameUtil;
   import Classes.util.FeatureThrottlingUtil;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureBuildingSurfacingManager;
   import Transactions.TInventoryStore;
   import Transactions.TStoreItem;
   import Widgets.Windows.BuildingSurfaceWindow;
   import flash.display.DisplayObject;
   
   public class StorageFManager implements IStorageComponent
   {
      
      protected var m_owner:FeatureBuilding;
      
      protected var m_alreadyShownFullPopup:Boolean = false;
      
      protected var m_limitedEndDate:String = null;
      
      protected var m_suppressDialog:Boolean = false;
      
      protected var m_surfaceBuildingOnFull:Boolean = false;
      
      protected var m_surfaceExpandOnFull:Boolean = false;
      
      protected var m_purchaseCurrencyUnit:String = "";
      
      public function StorageFManager(owner:FeatureBuilding)
      {
         var featureData:BaseDataSource = null;
         var featuresXML:XMLList = null;
         var storageFeature:XMLList = null;
         super();
         this.m_owner = owner;
         this.init(owner);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            featureData = owner.getFarmItem().getFeatureDataByName(FeatureManager.STORAGE_FEATURE_NAME);
            if(featureData)
            {
               if(featureData.hasProperty("limitedEnd"))
               {
                  this.m_limitedEndDate = featureData.getString("limitedEnd");
               }
               this.m_suppressDialog = featureData.getBoolean("suppressDialog");
               this.m_surfaceBuildingOnFull = featureData.getBoolean("surfaceBuildingOnFull");
               this.m_surfaceExpandOnFull = featureData.getBoolean("surfaceExpandOnFull");
            }
         }
         else
         {
            featuresXML = owner.getFarmItem().getFeaturesXML();
            storageFeature = featuresXML.(@name == FeatureManager.STORAGE_FEATURE_NAME);
            if(storageFeature != null)
            {
               if(storageFeature.hasOwnProperty("limitedEnd"))
               {
                  this.m_limitedEndDate = storageFeature.limitedEnd;
               }
               if(storageFeature.hasOwnProperty("suppressDialog"))
               {
                  this.m_suppressDialog = storageFeature.suppressDialog == "true";
               }
               if(storageFeature.hasOwnProperty("surfaceBuildingOnFull"))
               {
                  this.m_surfaceBuildingOnFull = storageFeature.surfaceBuildingOnFull == "true";
               }
               if(storageFeature.hasOwnProperty("surfaceExpandOnFull"))
               {
                  this.m_surfaceExpandOnFull = storageFeature.surfaceExpandOnFull == "true";
               }
            }
         }
      }
      
      public function init(owner:FeatureBuilding) : void
      {
         var item:FarmItem = owner.getFarmItem();
         var hasCapacity:Boolean = false;
         var hasLimitedEnd:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            hasCapacity = item.hasPropertyInDataSource("capacity");
            hasLimitedEnd = item.hasPropertyInDataSource("limitedEnd");
         }
         else
         {
            hasCapacity = item.xml.hasOwnProperty("capacity");
            hasLimitedEnd = item.xml.hasOwnProperty("limitedEnd");
         }
         if(hasCapacity)
         {
            owner.capacity = item.capacity;
         }
         if(hasLimitedEnd)
         {
            this.m_limitedEndDate = item.limitedEndDate;
         }
      }
      
      public function loadObject(data:Object) : void
      {
         var objContents:Array = null;
         var idx:int = 0;
         var key:String = null;
         if(data.contents)
         {
            objContents = data.contents;
            this.owner.count = 0;
            for(idx = 0; idx < objContents.length; idx++)
            {
               key = this.owner.getStorageKey(objContents[idx]);
               this.owner.contents[key] = int(objContents[idx].numItem);
               this.owner.count += int(objContents[idx].numItem);
            }
            if(this.owner.count == 0)
            {
               this.owner.setState(FeatureBuilding.STATE_BUILT);
            }
         }
      }
      
      public function get owner() : FeatureBuilding
      {
         return this.m_owner;
      }
      
      public function set owner(owner:FeatureBuilding) : void
      {
         this.m_owner = owner;
      }
      
      public function buildContainedItem(key:String) : Object
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(key);
         return {
            "item":item,
            "num":this.owner.contents[key]
         };
      }
      
      public function getStorageItemClass() : String
      {
         return this.owner.getFarmItem().storageClass;
      }
      
      protected function get storageFilter() : StorageFilter
      {
         return Global.storageSettings.getStorageFilter(this.getStorageItemClass());
      }
      
      public function getContents() : Array
      {
         var key:String = null;
         var itemsContained:Array = new Array();
         for(key in this.owner.contents)
         {
            if(this.owner.contents[key] > 0)
            {
               itemsContained.push(this.buildContainedItem(key));
            }
         }
         return itemsContained;
      }
      
      public function getStorageTypes() : Array
      {
         var itemObj:Object = null;
         var itemData:FarmItem = null;
         var quantityData:int = 0;
         var itemXML:XML = null;
         var item:FarmItem = null;
         var quantity:int = 0;
         var itemsContained:Array = [];
         var storageFilter:StorageFilter = Global.storageSettings.getStorageFilter(this.getStorageItemClass());
         if(FarmGameSettingsManager.isInStorageConfigAMFExperiment())
         {
            for each(itemObj in storageFilter.itemNamesOpt)
            {
               itemData = Global.farmGameSettingsManager.getFarmItemByName(itemObj["value"].toString());
               quantityData = this.owner.contents.hasOwnProperty(itemData.code) ? int(this.owner.contents[itemData.code]) : 0;
               if(itemData)
               {
                  itemsContained.push({
                     "item":itemData,
                     "num":quantityData,
                     "object":itemObj
                  });
               }
            }
         }
         else
         {
            for each(itemXML in storageFilter.itemNames)
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(itemXML.toString());
               quantity = this.owner.contents.hasOwnProperty(item.code) ? int(this.owner.contents[item.code]) : 0;
               if(item)
               {
                  itemsContained.push({
                     "item":item,
                     "num":quantity,
                     "xml":itemXML
                  });
               }
            }
         }
         return itemsContained;
      }
      
      public function removeContents(itemCode:String, itemCount:int = 1, itemParts:int = 0) : void
      {
         this.owner.contents[itemCode] -= itemCount;
         this.resetCount();
      }
      
      public function matchesOrigin(originId:int) : Boolean
      {
         var result:Boolean = false;
         if(this.owner.getId() == originId || this.owner.isInventoryBuilding() && originId == Global.worldManager.getCurrentWorldStorageId())
         {
            result = true;
         }
         return result;
      }
      
      public function setAmount(itemCode:String, amount:int) : void
      {
         this.owner.contents[itemCode] = amount;
         this.resetCount();
      }
      
      public function getAmount(itemCode:String) : Number
      {
         return this.owner.contents.hasOwnProperty(itemCode) ? Number(this.owner.contents[itemCode]) : 0;
      }
      
      public function getItemLimit(item:FarmItem) : Number
      {
         return StorageBuilding.getItemLimitForStorageBuilding(this.owner,item);
      }
      
      public function showStorageFullDialog() : void
      {
         var message:GenericPopup = null;
         var showPopup:Boolean = true;
         var showFullOnce:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            showFullOnce = this.owner.getItem().getBoolFromDataSource("showFullOnce");
         }
         else
         {
            showFullOnce = "true" == this.owner.getItem().xml.@showFullOnce;
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
            message = new GenericPopup(ZLocUtils.t("Dialogs","StorageFull",{"item":ZLocUtils.tk_pk(this.owner.getItem().friendlyName)}),GenericPopup.TYPE_OK);
            message.setAcceptTextName("Okay");
            UI.displayPopup(message);
         }
      }
      
      public function canTakeItem(item:MapResource, isMouseOver:Boolean = true) : Boolean
      {
         var result:Boolean = false;
         if(this.owner.getItem().storageClass == FeatureBuilding.INVENTORY_CLASSNAME)
         {
            if(Global.player.hasInventorySpace())
            {
               result = Global.storageSettings.storageCanTake(FeatureBuilding.INVENTORY_CLASSNAME,item);
            }
         }
         else if(this.isFullyBuilt() && this.owner.count < this.owner.capacity)
         {
            result = this.checkAllowedItem(item);
         }
         return result;
      }
      
      protected function checkAllowedItem(item:MapResource) : Boolean
      {
         return Global.storageSettings.storageCanTake(this.owner.getItem().storageClass,item);
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
               "building":ZLocUtils.tk_pk(this.owner.getItem().friendlyName)
            }),GenericPopup.TYPE_OK);
            message.setAcceptTextName("Okay");
            UI.displayPopup(message,true,"showItemStorageLimitFullDialog",true);
         }
      }
      
      public function addItem(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false, number:int = 1) : Boolean
      {
         var selectedContaineeMetadata:Object;
         var previousStorageLevel:int;
         var latestSelectedContaineeId:String;
         var containeeMetadataIndex:int;
         var isFull:Boolean;
         var itemNum:int;
         var result:Object = null;
         var index:int = 0;
         var containeeInstance:Object = null;
         var resourceItem:FarmItem = null;
         var key:String = null;
         var resourceMetaData:Object = null;
         var metaKey:String = null;
         var ownerItem:FarmItem = null;
         var surfacingManager:FeatureBuildingSurfacingManager = null;
         var surfacingWorldNameKey:String = null;
         var availableStorageBuildings:Array = null;
         var featureThrottler:FeatureThrottlingUtil = null;
         var level:String = null;
         var capacity:int = 0;
         var expansionThrottlingKey:String = null;
         var expansionMessage:String = null;
         var prompt:GenericIconPopup = null;
         var storeItem:Boolean = false;
         var storageLevelUp:int = 0;
         var success:Boolean = false;
         FarmStatsManager.featureSample("farm_world_action","add_item_to_storage",this.owner.getItem().name,resource.getItem().name);
         selectedContaineeMetadata = null;
         previousStorageLevel = this.owner.storageLevel;
         latestSelectedContaineeId = "";
         containeeMetadataIndex = -1;
         isFull = false;
         for(itemNum = 0; itemNum < number; itemNum++)
         {
            if(this.owner.isFullyBuilt() && this.owner.isValidExpansionPart(resource))
            {
               success = this.owner.addExpansionPart(resource);
            }
            else if(this.owner.isFullyBuilt() && this.owner.isValidContaineePart(resource) && this.owner.count > 0)
            {
               latestSelectedContaineeId = this.owner.containeeManager.latestSelectedContaineeId;
               if(latestSelectedContaineeId != "")
               {
                  result = this.owner.containeeManager.addItemToContainee(resource,latestSelectedContaineeId,fromStorage,isGift);
                  selectedContaineeMetadata = result[FeatureBuilding.METADATA_KEY];
                  success = selectedContaineeMetadata != null ? true : false;
                  if(result.hasOwnProperty(FeatureBuilding.METADATA_INDEX_KEY))
                  {
                     index = parseInt(result[FeatureBuilding.METADATA_INDEX_KEY]);
                     if(!isNaN(index))
                     {
                        containeeMetadataIndex = index;
                     }
                  }
                  if(success)
                  {
                     containeeInstance = this.owner.containeeManager.latestChangedResidentInstance;
                     isFull = Boolean(containeeInstance.isFullyBuilt());
                  }
               }
            }
            else if(this.canTakeItem(resource,false))
            {
               resourceItem = resource.getItem();
               if(this.getItemLimit(resourceItem) == 0 || this.getAmount(resourceItem.code) < this.getItemLimit(resourceItem))
               {
                  ++this.owner.count;
                  resourceItem.aoeImageState = null;
                  this.owner.setState(this.owner.getState());
                  key = this.owner.getStorageKeyFromMapResource(resource);
                  if(!this.owner.contents[key])
                  {
                     this.owner.contents[key] = 0;
                  }
                  ++this.owner.contents[key];
                  if(this.shouldShowOverlayOnAdd())
                  {
                     this.owner.dispOverlay(this.owner.getOverlayUrl());
                  }
                  resourceMetaData = resource.getMetadata();
                  if(resourceMetaData != null)
                  {
                     metaKey = resource.getMetadataKey();
                     if(this.owner.storageMetaData[metaKey] == null)
                     {
                        this.owner.storageMetaData[metaKey] = new Array();
                     }
                     (this.owner.storageMetaData[metaKey] as Array).push(resourceMetaData);
                  }
                  success = true;
                  if(this.owner.isFull())
                  {
                     ownerItem = this.owner.getFarmItem();
                     if(this.owner.hasReachedMaxExpansionLevel())
                     {
                        if(this.m_surfaceBuildingOnFull && this.owner.isFull())
                        {
                           surfacingManager = FeatureBuildingSurfacingManager.getInstance();
                           surfacingWorldNameKey = surfacingManager.getWorldNameKey(ownerItem.name);
                           if(surfacingManager.canSurfaceForWorldNameKey(surfacingWorldNameKey))
                           {
                              availableStorageBuildings = surfacingManager.searchForStorageBuildingsInWorld(resource,true);
                              if(availableStorageBuildings.length == 0)
                              {
                                 surfacingManager.initializeSurfacingThrottle(surfacingWorldNameKey);
                                 UI.displayPopup(new BuildingSurfaceWindow(ownerItem,resource,true,null,null,"StorageNowFullSurfacing"),true);
                              }
                           }
                        }
                     }
                     else
                     {
                        featureThrottler = new FeatureThrottlingUtil();
                        level = this.owner.getNextExpansionLevel().toString();
                        capacity = this.owner.getNextExpansionCapacity();
                        expansionThrottlingKey = ownerItem.name + "_expand_" + level + "_" + Global.worldManager.currentWorldType;
                        if(!featureThrottler.isKeywordThrottled(expansionThrottlingKey))
                        {
                           featureThrottler.throttleKeyword(expansionThrottlingKey);
                           expansionMessage = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs","StorageNowFullSurfacing_expand_" + ownerItem.name),new ZLocFailoverEntry("Dialogs","StorageNowFullSurfacing_expand")],{
                              "buildingName":ZLocUtils.tk_pk(ownerItem.friendlyName),
                              "quantity":capacity - this.owner.capacity
                           });
                           prompt = new GenericIconPopup(expansionMessage,GenericPopup.TYPE_OK,function(event:GenericPopupEvent):void
                           {
                              if(event.button == GenericPopup.OK)
                              {
                                 owner.displayExpandDialog();
                              }
                              else
                              {
                                 featureThrottler.registerUserCancelAction(expansionThrottlingKey);
                              }
                           },Global.farmGameSettingsManager.getImageByName(ownerItem.name,"icon",true),false,true);
                           prompt.setAcceptTextName("Expand");
                           UI.displayPopup(prompt,true,expansionThrottlingKey,true);
                        }
                     }
                  }
               }
               else
               {
                  this.showItemStorageLimitFullDialog(resource);
               }
            }
            else if(this.isFullyBuilt() && this.owner.count >= this.owner.capacity)
            {
               this.showStorageFullDialog();
            }
         }
         if(success)
         {
            if(sendStoreItem)
            {
               if(this.owner.getItem().storageClass == FeatureBuilding.INVENTORY_CLASSNAME)
               {
                  storeItem = resource.preAddToInventoryCheck();
                  if(storeItem)
                  {
                     TransactionManager.addTransaction(new TInventoryStore(resource,fromStorage,resource.getId(),isGift,this.m_purchaseCurrencyUnit),force);
                     FarmStatsManager.sample(100,"Storage","goods","stored","drag_drop");
                  }
               }
               else
               {
                  storageLevelUp = -1;
                  if(this.owner.storageLevel > previousStorageLevel)
                  {
                     storageLevelUp = this.owner.storageLevel;
                  }
                  TransactionManager.addTransaction(new TStoreItem(this.owner,resource,fromStorage,resource.getId(),isGift,this.m_purchaseCurrencyUnit,storageLevelUp,latestSelectedContaineeId,selectedContaineeMetadata,isFull,containeeMetadataIndex,number),true);
               }
            }
            resource.detach();
         }
         return success;
      }
      
      public function addItemUsingCurrency(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false, currencyUnit:String = "", number:int = 1) : Boolean
      {
         this.m_purchaseCurrencyUnit = currencyUnit;
         return this.addItem(resource,fromStorage,isGift,sendStoreItem,force,number);
      }
      
      public function get capacity() : Number
      {
         return int(this.owner.capacity);
      }
      
      public function set capacity(capacity:Number) : void
      {
         this.owner.capacity = capacity;
      }
      
      public function get maxPotentialCapacity() : Number
      {
         return this.owner.capacity;
      }
      
      public function get count() : Number
      {
         return this.owner.count;
      }
      
      public function onStoreComplete(result:Object) : void
      {
      }
      
      protected function resetCount() : void
      {
         var key:String = null;
         this.owner.count = 0;
         for(key in this.owner.contents)
         {
            this.owner.count += this.owner.contents[key];
         }
         if(this.owner.count == 0)
         {
            this.owner.setState(FeatureBuilding.STATE_BUILT);
         }
      }
      
      public function isFullyBuilt() : Boolean
      {
         return this.owner.isFullyBuilt();
      }
      
      public function showStorageContextMenu() : Boolean
      {
         var result:Boolean = false;
         if(this.m_suppressDialog)
         {
            result = false;
         }
         else if(null != this.m_limitedEndDate)
         {
            result = FarmGameUtil.checkEndDateGate(this.m_limitedEndDate);
         }
         else
         {
            result = true;
         }
         return result;
      }
      
      protected function shouldShowOverlayOnAdd() : Boolean
      {
         return true;
      }
   }
}

