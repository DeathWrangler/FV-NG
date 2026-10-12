package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.MapResource;
   import Classes.MutableAnimalCrate;
   import Classes.ZItem.FarmItem;
   import DataSources.BaseDataSource;
   import Managers.FarmGameSettingsManager;
   import flash.utils.getDefinitionByName;
   
   public class ContaineeFManager extends FeatureManager
   {
      
      private var m_containeeParts:Array;
      
      private var m_latestSelectedContaineeId:String = "";
      
      private var m_latestSelectedContaineeMetadata:Object = null;
      
      private var m_latestChangedResidentInstance:Object = null;
      
      private var m_classCompilingArray:Array;
      
      public function ContaineeFManager(owner:FeatureBuilding)
      {
         var featureData:BaseDataSource = null;
         var containeePartDataArray:Array = null;
         var partDataSource:BaseDataSource = null;
         var featuresXML:XMLList = null;
         var containeeFeatureXML:XMLList = null;
         var partData:XML = null;
         this.m_containeeParts = new Array();
         this.m_classCompilingArray = [MutableAnimalCrate];
         super(owner);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            featureData = owner.getFarmItem().getFeatureDataByName(FeatureManager.CONTAINEE_FEATURE_NAME);
            if(featureData)
            {
               containeePartDataArray = featureData.getArray("containeePart");
               if(containeePartDataArray.length > 0)
               {
                  for each(partDataSource in containeePartDataArray)
                  {
                     this.m_containeeParts.push(partDataSource.getString("name"));
                  }
               }
            }
         }
         else
         {
            featuresXML = owner.getFarmItem().getFeaturesXML();
            containeeFeatureXML = featuresXML.(@name == FeatureManager.CONTAINEE_FEATURE_NAME);
            if(containeeFeatureXML != null)
            {
               if(containeeFeatureXML.hasOwnProperty("containeePart"))
               {
                  for each(partData in containeeFeatureXML.containeePart)
                  {
                     this.m_containeeParts.push(containeeFeatureXML.containeePart.@name);
                  }
               }
            }
         }
      }
      
      public function isValidContaineePart(partName:String) : Boolean
      {
         var part:String = null;
         var result:Boolean = false;
         for each(part in this.m_containeeParts)
         {
            if(partName == part)
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      public function get containeeParts() : Array
      {
         return this.m_containeeParts;
      }
      
      public function get firstContaineePart() : String
      {
         var result:String = null;
         if(this.containeeParts.length)
         {
            result = this.containeeParts[0];
         }
         return result;
      }
      
      public function set latestChangedResidentInstance(instance:Object) : void
      {
         this.m_latestChangedResidentInstance = instance;
      }
      
      public function get latestChangedResidentInstance() : Object
      {
         return this.m_latestChangedResidentInstance;
      }
      
      public function set latestSelectedContaineeId(buildingId:String) : void
      {
         this.m_latestSelectedContaineeId = buildingId;
      }
      
      public function get latestSelectedContaineeId() : String
      {
         var index:int = 0;
         var i:int = 0;
         var key:String = null;
         var result:String = "";
         if(this.m_latestSelectedContaineeId != "")
         {
            result = this.m_latestSelectedContaineeId;
         }
         else
         {
            index = Math.floor(Math.random() * owner.contents.length);
            i = 0;
            for(key in owner.contents)
            {
               if(i == index)
               {
                  result = key;
                  break;
               }
               i++;
            }
         }
         return result;
      }
      
      public function set latestSelectedContaineeMetadata(metadata:Object) : void
      {
         this.m_latestSelectedContaineeMetadata = metadata;
      }
      
      public function get latestSelectedContaineeMetadata() : Object
      {
         return this.m_latestSelectedContaineeMetadata;
      }
      
      public function addItemToContainee(resource:MapResource, residentId:String, fromStorage:int = 0, isGift:Boolean = false) : Object
      {
         var storageKey:String = null;
         var residentsMatadata:Object = null;
         var newMetadata:String = null;
         var resultMetadata:Object = null;
         var metadata:Object = this.latestSelectedContaineeMetadata;
         var instanceResult:Object = this.findResidentInstance(resource,residentId,metadata);
         var residentObj:Object = instanceResult.residentObject;
         var metadataIndex:String = instanceResult.metadataIndex;
         if(Boolean(residentObj) && metadataIndex != "")
         {
            metadata = residentObj.getMetadata();
            storageKey = owner.getStorageKeyFromMapResource(residentObj as MapResource);
            residentsMatadata = owner.storageMetaData[storageKey];
            if(residentObj.addItem(resource,fromStorage,isGift))
            {
               resultMetadata = metadata;
               newMetadata = residentObj.getMetadata();
               residentsMatadata[metadataIndex] = newMetadata;
               owner.storageMetaData[storageKey] = residentsMatadata;
            }
            if(residentObj.isFullyBuilt())
            {
               owner.dispOverlay(residentObj.getOverlayUrl());
               owner.lastMetaHashRemoved = residentObj.getMetadataKey();
               owner.lastMetadataRemoved = residentObj.getMetadata();
               owner.removeContents(Global.farmGameSettingsManager.getFarmItemCodeByName(residentObj.getItemName()));
            }
            this.latestSelectedContaineeId = "";
            this.latestSelectedContaineeMetadata = null;
            this.latestChangedResidentInstance = residentObj;
         }
         var result:Object = new Object();
         result[FeatureBuilding.METADATA_INDEX_KEY] = metadataIndex;
         result[FeatureBuilding.METADATA_KEY] = resultMetadata;
         return result;
      }
      
      private function findResidentInstance(resource:MapResource, residentId:String, metadata:Object) : Object
      {
         var storageKey:String = null;
         var residentsMatadata:Object = null;
         var className:String = null;
         var residentClass:Class = null;
         var result:Object = new Object();
         var residentItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(residentId);
         var itemName:String = Global.farmGameSettingsManager.getFarmItemNameByCode(residentId);
         var metadataIndex:String = "";
         var residentObj:Object = this.createResidentInstance(residentId);
         var key:String = "";
         if(residentObj)
         {
            storageKey = owner.getStorageKeyFromMapResource(residentObj as MapResource);
            residentsMatadata = owner.storageMetaData[storageKey];
            if(metadata != null)
            {
               for(key in residentsMatadata)
               {
                  if(metadata == residentsMatadata[key])
                  {
                     metadataIndex = key;
                     break;
                  }
               }
            }
            else
            {
               className = "Classes." + residentItem.className;
               residentClass = getDefinitionByName(className) as Class;
               if(Boolean(residentsMatadata) && Boolean(residentsMatadata.length))
               {
                  if(residentClass.hasOwnProperty("chooseInstanceToAddItemTo"))
                  {
                     metadataIndex = residentClass["chooseInstanceToAddItemTo"](itemName,residentsMatadata,resource.getItem().code);
                  }
                  else
                  {
                     for(key in residentsMatadata)
                     {
                        metadataIndex = key;
                     }
                  }
                  metadata = residentsMatadata[metadataIndex];
               }
            }
            if(metadata)
            {
               residentObj.setMetadata(metadata);
               result["residentObject"] = residentObj;
               result["metadataIndex"] = metadataIndex;
            }
         }
         return result;
      }
      
      public function createResidentInstance(residentId:String) : Object
      {
         var residentClass:Class = null;
         var residentItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(residentId);
         var className:String = "Classes." + residentItem.className;
         var itemName:String = Global.farmGameSettingsManager.getFarmItemNameByCode(residentId);
         var residentObj:Object = null;
         if(className)
         {
            residentClass = getDefinitionByName(className) as Class;
            if(residentClass["createStoredFeatureInstance"])
            {
               residentObj = residentClass["createStoredFeatureInstance"](itemName);
            }
            else
            {
               residentObj = new residentClass(itemName);
            }
         }
         return residentObj;
      }
      
      public function onStoreComplete(result:Object) : void
      {
         var residentId:String = result.containeeCode;
         var metadata:Object = result.containeeMetadata;
         var residentObj:Object = this.createResidentInstance(residentId);
         if(Boolean(residentObj) && Boolean(metadata) && Boolean(residentId))
         {
            residentObj.setMetadata(metadata);
            residentObj.onStoreComplete(result);
         }
         owner.stopOverlay();
      }
   }
}

