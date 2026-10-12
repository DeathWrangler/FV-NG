package Classes.FeatureDataObjects
{
   import Classes.DataSources.XMLDataSource;
   import Classes.FeatureComponents.IExpandComponent;
   import Classes.MapResource;
   import Classes.StorageBuilding;
   import Classes.storage.PartItem;
   import DataSources.BaseDataSource;
   import Events.GenericPopupEvent;
   import Managers.FeatureOptionsManager;
   import flash.utils.Dictionary;
   
   public class FeatureExpansionState implements IExpandComponent
   {
      
      public static const FEATURE_OPTION_EXPANSION_STATE:String = "exp_parts";
      
      public static const FEATURE_OPTION_EXPANSION_LEVEL:String = "exp_level";
      
      public static const RT_MARKET_STALL_MAX_LEVEL_UPGRADE_NAME:String = "FEATURE_MARKET_STALL_CAPACITY_LEVEL_CAP";
      
      public static const PARTINFO_NEED_KEY:String = "need";
      
      public static const PARTINFO_ONHAND_KEY:String = "onhand";
      
      public static const PARTINFO_NAME_KEY:String = "name";
      
      public static const GLOBAL_MAX_FEATURE_EXPAND_LEVEL:int = 999;
      
      private var m_featureName:String = "";
      
      private var m_frictionlessExpandCallback:Function = null;
      
      private var m_beginCompleteExpansionFlowCallback:Function = null;
      
      private var m_buildingExpansionData:Dictionary = new Dictionary();
      
      public function FeatureExpansionState(featureName:String)
      {
         super();
         this.m_featureName = featureName;
      }
      
      public function refreshPartData(data:Object = null) : void
      {
      }
      
      public function get frictionless() : Boolean
      {
         return false;
      }
      
      public function get inAppPurchase() : Boolean
      {
         return false;
      }
      
      public function onStoreExpandable(event:GenericPopupEvent) : void
      {
      }
      
      public function set storageLevel(level:uint) : void
      {
      }
      
      public function get showExpansionOnBuild() : Boolean
      {
         return false;
      }
      
      public function getPartAskMethod(itemCode:String) : String
      {
         return "";
      }
      
      public function get storageLevel() : uint
      {
         return this.getExpansionLevel();
      }
      
      public function initialize(frictionlessExpandCallback:Function, beginCompleteExpansionFlowCallback:Function) : void
      {
         this.m_frictionlessExpandCallback = frictionlessExpandCallback;
         this.m_beginCompleteExpansionFlowCallback = beginCompleteExpansionFlowCallback;
      }
      
      public function frictionlessExpand() : void
      {
         this.m_frictionlessExpandCallback();
      }
      
      public function beginCompleteExpansionFlow(source:int = 0) : void
      {
         this.m_beginCompleteExpansionFlowCallback(source);
      }
      
      public function isValidExpansionPart(resource:MapResource) : Boolean
      {
         var info:Object = null;
         var tokenName:String = resource.getItem().name;
         var result:Boolean = false;
         var constructionInfo:Array = this.getConstructionInfo();
         for each(info in constructionInfo)
         {
            if(constructionInfo.name == tokenName)
            {
               result = true;
               break;
            }
         }
         return true;
      }
      
      public function getNextExpansionData() : XML
      {
         return this.getUpgradeData(this.getExpansionLevel() + 1);
      }
      
      public function getNextExpansionDataSource() : BaseDataSource
      {
         var nextExpansionDataSource:XMLDataSource = null;
         var nextExpansionXML:XML = this.getNextExpansionData();
         if(nextExpansionXML)
         {
            nextExpansionDataSource = new XMLDataSource(nextExpansionXML);
         }
         return nextExpansionDataSource;
      }
      
      public function getExpansionLevel() : int
      {
         var featureOptions:FeatureOptionsManager = FeatureOptionsManager.getInstance();
         return featureOptions.getFeatureOption(this.m_featureName,FEATURE_OPTION_EXPANSION_LEVEL) as int;
      }
      
      public function maxExpansionLevel() : int
      {
         var upgradeData:XML = null;
         var resultItems:Array = null;
         var itemXML:XML = null;
         var maxLevel:int = 0;
         for(var i:int = 1; i < GLOBAL_MAX_FEATURE_EXPAND_LEVEL; i++)
         {
            upgradeData = this.getUpgradeData(i);
            resultItems = [];
            if(Boolean(upgradeData) && Boolean(upgradeData.part))
            {
               for each(itemXML in upgradeData.part)
               {
                  resultItems.push(itemXML.@name as String);
               }
            }
            if(resultItems.length <= 0)
            {
               break;
            }
            maxLevel = i;
         }
         return maxLevel;
      }
      
      public function getExpansionPartCount(itemCode:String) : int
      {
         var qty:int = 0;
         var tokenName:String = Global.farmGameSettingsManager.getFarmItemByCode(itemCode).name;
         var featureOptions:FeatureOptionsManager = FeatureOptionsManager.getInstance();
         var expParts:Object = featureOptions.getFeatureOption(this.m_featureName,FEATURE_OPTION_EXPANSION_STATE);
         if(Boolean(expParts) && expParts.hasOwnProperty(tokenName))
         {
            qty = expParts[tokenName] as int;
         }
         return qty;
      }
      
      public function getTotalExpansionPartCount() : int
      {
         var key:String = null;
         var qty:int = 0;
         var featureOptions:FeatureOptionsManager = FeatureOptionsManager.getInstance();
         var expParts:Object = featureOptions.getFeatureOption(this.m_featureName,FEATURE_OPTION_EXPANSION_STATE);
         for(key in expParts)
         {
            qty += expParts[key];
         }
         return qty;
      }
      
      public function getTotalExpansionLimitCount() : int
      {
         var partInfo:Object = null;
         var total:int = 0;
         var info:Array = this.getConstructionInfo();
         for each(partInfo in info)
         {
            if(Boolean(partInfo) && Boolean(partInfo.hasOwnProperty(PARTINFO_NAME_KEY)) && partInfo.hasOwnProperty(PARTINFO_NEED_KEY))
            {
               total += partInfo[PARTINFO_NEED_KEY];
            }
         }
         return total;
      }
      
      public function getExpansionPartLimit(itemCode:String) : int
      {
         var partInfo:Object = null;
         var result:int = 0;
         var info:Array = this.getConstructionInfo();
         var tokenName:String = Global.farmGameSettingsManager.getFarmItemByCode(itemCode).name;
         for each(partInfo in info)
         {
            if(Boolean(partInfo && partInfo.hasOwnProperty(PARTINFO_NAME_KEY)) && Boolean(partInfo.hasOwnProperty(PARTINFO_NEED_KEY)) && partInfo[PARTINFO_NAME_KEY] == tokenName)
            {
               result = int(partInfo[PARTINFO_NEED_KEY]);
               break;
            }
         }
         return result;
      }
      
      public function hasReachedMaxExpansionLevel() : Boolean
      {
         return this.getExpansionLevel() >= this.maxExpansionLevel();
      }
      
      public function addExpansionPart(resource:MapResource) : Boolean
      {
         var featureOptions:FeatureOptionsManager = null;
         var expParts:Object = null;
         var qty:int = 0;
         var result:Boolean = false;
         var tokenName:String = resource.getItem().name;
         if(this.isValidExpansionPart(resource))
         {
            featureOptions = FeatureOptionsManager.getInstance();
            expParts = featureOptions.getFeatureOption(this.m_featureName,FEATURE_OPTION_EXPANSION_STATE);
            if(!expParts)
            {
               expParts = {};
            }
            if(expParts.hasOwnProperty(tokenName))
            {
               qty = expParts[tokenName] as int;
               expParts[tokenName] = qty + 1;
            }
            else
            {
               expParts[tokenName] = 1;
            }
            featureOptions.setFeatureOption(this.m_featureName,FEATURE_OPTION_EXPANSION_STATE,expParts);
            result = true;
            this.checkAndSetLevelup();
         }
         return result;
      }
      
      public function onStoreComplete(result:Object) : void
      {
      }
      
      public function grantUpgradeAwards(upgradeDataArray:Array) : void
      {
      }
      
      public function getNextUpgradeAward() : String
      {
         return null;
      }
      
      public function getExpandCashNeeded() : int
      {
         return this.getTotalExpansionLimitCount() - this.getTotalExpansionPartCount();
      }
      
      public function get expandPriceMultiplier() : Number
      {
         return 1;
      }
      
      public function getExpansionPartString() : String
      {
         var partInfo:Object = null;
         var neededItems:Array = [];
         var info:Array = this.getConstructionInfo();
         for each(partInfo in info)
         {
            neededItems.push(partInfo[PARTINFO_NAME_KEY]);
         }
         return neededItems.join(",");
      }
      
      public function getFriendRewardNameByType(friendRewardType:String) : String
      {
         return "";
      }
      
      public function getUpgradeData(level:int) : XML
      {
         var xml:XML = Global.farmGameSettingsManager.getFeatureXML(FeatureOptionsManager.FEATURE_MARKET_STALL);
         var list:XMLList = null;
         if(xml.hasOwnProperty("upgrade"))
         {
            list = xml.upgrade.(@level == level);
         }
         if(list !== null && Boolean(list.length()))
         {
            xml = list[0];
         }
         else if(level > this.getMaxExplicitUpgradeData()["level"])
         {
            xml = this.getInfiniteUpgradeData(level);
         }
         return xml;
      }
      
      public function getMaxExplicitUpgradeData() : Dictionary
      {
         var upgradeXML:XML = null;
         var maxLevel:int = 0;
         var maxCapacity:int = 0;
         var upgradeXMLs:XMLList = null;
         var xml:XML = Global.farmGameSettingsManager.getFeatureXML(FeatureOptionsManager.FEATURE_MARKET_STALL);
         if(xml.hasOwnProperty("upgrade"))
         {
            upgradeXMLs = xml.upgrade;
         }
         if(upgradeXMLs)
         {
            for each(upgradeXML in upgradeXMLs)
            {
               if(upgradeXML.@level > maxLevel)
               {
                  maxLevel = int(upgradeXML.@level);
                  maxCapacity = int(upgradeXML.@capacity);
               }
            }
         }
         var values:Dictionary = new Dictionary();
         values["level"] = maxLevel;
         values["capacity"] = maxCapacity;
         return values;
      }
      
      private function getInfiniteUpgradeData(level:int) : XML
      {
         var toReturn:XML = null;
         var xml:XML = Global.farmGameSettingsManager.getFeatureXML(FeatureOptionsManager.FEATURE_MARKET_STALL);
         var maxExplicitUpgradeData:Dictionary = this.getMaxExplicitUpgradeData();
         var maxExplicitLevel:int = int(maxExplicitUpgradeData["level"]);
         var maxExplicitCapacity:int = int(maxExplicitUpgradeData["capacity"]);
         var infiniteUpgradeData:XML = xml.infiniteUpgradeData[0];
         var maxLeveLUpgrade:int = parseInt(GlobalEngine.getFlashVar(RT_MARKET_STALL_MAX_LEVEL_UPGRADE_NAME) as String);
         if(Boolean(infiniteUpgradeData && level > maxExplicitLevel) && Boolean(maxLeveLUpgrade) && maxLeveLUpgrade > level)
         {
            toReturn = new XML("<upgrade level=\"" + level + "\" capacity=\"" + (maxExplicitCapacity + (level - maxExplicitLevel) * infiniteUpgradeData.@additionalCapacity) + "\" matsNeeded=\"" + infiniteUpgradeData.@matsNeeded + "\" rewardInterval=\"" + infiniteUpgradeData.@rewardInterval + "\"></upgrade>");
            toReturn.setChildren(infiniteUpgradeData.children());
         }
         return toReturn;
      }
      
      public function getConstructionInfo() : Array
      {
         var buildingExpansionData:BuildingExpansionData = null;
         var parts:Vector.<PartItem> = null;
         var partItem:PartItem = null;
         var onHand:int = 0;
         var partItemName:String = null;
         var expansionParts:Object = null;
         var upgradeData:XML = null;
         var itemXML:XML = null;
         var itemName:String = null;
         var need:int = 0;
         var onhand:int = 0;
         var expParts:Object = null;
         var resultItems:Array = [];
         if(StorageBuilding.isDynamicPartsExperimentOn())
         {
            buildingExpansionData = this.getNextBuildingExpansionData();
            if(buildingExpansionData)
            {
               parts = buildingExpansionData.parts;
               for each(partItem in parts)
               {
                  onHand = 0;
                  partItemName = partItem.item.name;
                  expansionParts = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureName,FEATURE_OPTION_EXPANSION_STATE);
                  if(Boolean(expansionParts) && expansionParts.hasOwnProperty(partItemName))
                  {
                     onHand = expansionParts[partItemName] as int;
                  }
                  resultItems.push({
                     "name":partItemName,
                     "need":partItem.qtyNeeded,
                     "onhand":onHand
                  });
               }
            }
         }
         else
         {
            upgradeData = this.getNextExpansionData();
            if(Boolean(upgradeData) && Boolean(upgradeData.part))
            {
               for each(itemXML in upgradeData.part)
               {
                  itemName = itemXML.@name;
                  need = int(itemXML.@need);
                  onhand = 0;
                  expParts = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureName,FEATURE_OPTION_EXPANSION_STATE);
                  if(Boolean(expParts) && expParts.hasOwnProperty(itemName))
                  {
                     onhand = expParts[itemName] as int;
                  }
                  resultItems.push({
                     "name":itemName,
                     "need":need,
                     "onhand":onhand
                  });
               }
            }
         }
         return resultItems;
      }
      
      private function checkAndSetLevelup() : Boolean
      {
         var partInfo:Object = null;
         var result:Boolean = false;
         var info:Array = this.getConstructionInfo();
         var canExpand:Boolean = true;
         for(var i:int = 0; i < info.length; i++)
         {
            partInfo = info[i];
            if(partInfo[PARTINFO_NEED_KEY] > partInfo[PARTINFO_ONHAND_KEY])
            {
               canExpand = false;
               break;
            }
         }
         if(canExpand)
         {
            this.completeExpansionLevel();
            result = true;
         }
         return result;
      }
      
      public function conditionallySwapOnFullyExpanded() : void
      {
      }
      
      public function getNextBuildingExpansionData() : BuildingExpansionData
      {
         return this.getBuildingExpansionDataByLevel(this.getExpansionLevel() + 1);
      }
      
      private function getBuildingExpansionDataByLevel(level:int) : BuildingExpansionData
      {
         var result:BuildingExpansionData = null;
         var buildingExpansionXML:XML = null;
         var key:String = level.toString();
         if(this.m_buildingExpansionData.hasOwnProperty(key))
         {
            result = this.m_buildingExpansionData[key];
         }
         else
         {
            buildingExpansionXML = this.getUpgradeData(level);
            if(buildingExpansionXML)
            {
               result = StorageBuilding.getBuildingExpansionDataFromXML(buildingExpansionXML);
            }
            this.m_buildingExpansionData[key] = result;
         }
         return result;
      }
      
      public function hasNextExpansion() : Boolean
      {
         var result:Boolean = false;
         if(StorageBuilding.isDynamicPartsExperimentOn())
         {
            result = this.getNextBuildingExpansionData() != null;
         }
         else
         {
            result = this.getNextExpansionData() != null;
         }
         return result;
      }
      
      public function getExpandSlotData() : Array
      {
         var buildingExpansionData:BuildingExpansionData = null;
         var parts:Vector.<PartItem> = null;
         var part:PartItem = null;
         var upgradeData:XML = null;
         var partList:XMLList = null;
         var idx:int = 0;
         var result:Array = null;
         if(StorageBuilding.isDynamicPartsExperimentOn())
         {
            buildingExpansionData = this.getNextBuildingExpansionData();
            if(buildingExpansionData)
            {
               parts = buildingExpansionData.parts;
               result = [];
               for each(part in parts)
               {
                  result.push({
                     "name":String(part.item.name),
                     "need":part.qtyNeeded
                  });
               }
               result.push({"name":""});
            }
         }
         else
         {
            upgradeData = this.getNextExpansionData();
            if(upgradeData != null)
            {
               partList = upgradeData.part;
               result = [];
               for(idx = 0; idx < partList.length(); idx++)
               {
                  result.push({
                     "name":String(partList[idx].@name),
                     "need":int(partList[idx].@need)
                  });
               }
               result.push({"name":""});
            }
         }
         return result;
      }
      
      public function completeExpansionLevel() : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,FEATURE_OPTION_EXPANSION_LEVEL,this.getExpansionLevel() + 1);
         FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,FEATURE_OPTION_EXPANSION_STATE,{});
      }
      
      public function refreshAskMethods() : void
      {
      }
      
      public function expandBuildingUsingCurrencyOrCash() : Boolean
      {
         return false;
      }
      
      public function getPriceForExpansion() : Object
      {
         return null;
      }
   }
}

