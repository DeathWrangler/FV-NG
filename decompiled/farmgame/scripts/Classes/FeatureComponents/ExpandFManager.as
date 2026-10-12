package Classes.FeatureComponents
{
   import Classes.Building;
   import Classes.Constants.Experiments;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.Constants.XMLKeys;
   import Classes.FeatureBuilding;
   import Classes.FeatureDataObjects.BuildingExpansionData;
   import Classes.MapResource;
   import Classes.NextExpandAwardData;
   import Classes.SimpleHarvestableResource;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.storage.PartItem;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.HUD.StatsDropDown;
   import Display.UI;
   import Engine.Helpers.Vector3;
   import Engine.Managers.TransactionManager;
   import Events.FarmGameWorldEvent;
   import Events.GenericPopupEvent;
   import GameMode.GMSpecialDeliveryApply;
   import GameMode.GameMode;
   import Managers.ExpansionFeedManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Transactions.TGenericWorldObjectTransaction;
   import Transactions.TInventoryStore;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.GenericSingleRewardPopup;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   
   public class ExpandFManager extends FeatureManager implements IExpandComponent
   {
      
      public static const EXPAND_IMAGE_ICON_URL_SUFFIX:String = "_icon.png";
      
      public static const EXPAND_IMAGE_ICON_URL_SUFFIX_200:String = "_icon_200.png";
      
      public static const EXPAND_IMAGE_ICON_URL_PREFIX:String = "assets/buildings/building_";
      
      public static const EXPAND_PART_IMAGE_ICON_PREFIX:String = "assets/newsfeed/";
      
      private const EXPANSION_REWARD_TYPE_PART:int = 1;
      
      private const EXPANSION_REWARD_TYPE_COMPLETE:int = 2;
      
      private const EXPANSION_REWARD_TYPE_HALF_COMPLETE:int = 3;
      
      private const EXPANSION_REWARD_TYPE_PARTS_INTERVAL:int = 4;
      
      protected var m_featureName:String = "expand";
      
      protected var m_expansionParts:Dictionary;
      
      protected var m_askMethods:Dictionary;
      
      private var m_friendRewardTypesHash:Array = null;
      
      private var m_upgradeMax:int = -1;
      
      private var m_dialogPrefix:String = null;
      
      private var m_frictionless:Boolean = false;
      
      private var m_experiment:String = null;
      
      private var m_inAppPurchase:Boolean = false;
      
      private var m_frictionlessExpandCallback:Function = null;
      
      private var m_beginCompleteExpansionFlowCallback:Function = null;
      
      private var m_storageLevel:uint = 0;
      
      protected var m_showExpansionOnBuild:Boolean;
      
      protected var m_iconUrl:String;
      
      protected var m_transformedObject:MapResource;
      
      private var m_awardDialog:String;
      
      private var m_awardDialogBackground:String;
      
      public function ExpandFManager(owner:FeatureBuilding)
      {
         var featureData:BaseDataSource = null;
         var friendRewardsDataArray:Array = null;
         var friendRewardData:BaseDataSource = null;
         var featureXML:XML = null;
         var rewardItemXML:XML = null;
         this.m_expansionParts = new Dictionary();
         this.m_askMethods = new Dictionary();
         super(owner);
         var item:FarmItem = m_owner.getFarmItem();
         this.m_friendRewardTypesHash = new Array();
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            featureData = item.getFeatureDataByName(this.m_featureName);
            if(featureData != null)
            {
               this.m_frictionless = featureData.getBoolean("frictionless");
               if(featureData.hasProperty("experimentGate"))
               {
                  this.m_experiment = featureData.getString("experimentGate");
               }
               this.m_inAppPurchase = featureData.getBoolean("inAppPurchase");
               this.m_showExpansionOnBuild = featureData.getBoolean("showExpansionOnBuild");
               if(featureData.hasProperty("icon"))
               {
                  this.m_iconUrl = featureData.getString("icon");
               }
               if(featureData.hasProperty("awardDialog"))
               {
                  this.m_awardDialog = featureData.getString("awardDialog");
               }
               if(featureData.hasProperty("awardDialogBackground"))
               {
                  this.m_awardDialogBackground = featureData.getString("awardDialogBackground");
               }
               if(featureData.hasProperty("upgradeMax"))
               {
                  this.m_upgradeMax = featureData.getInt("upgradeMax");
               }
               friendRewardsDataArray = featureData.getArray("friendRewards","friendReward");
               for each(friendRewardData in friendRewardsDataArray)
               {
                  this.m_friendRewardTypesHash[friendRewardData.getString("type")] = friendRewardData.getString("rewardName");
               }
            }
         }
         else
         {
            featureXML = item.getFeatureXMLByName(this.m_featureName);
            if(Boolean(featureXML) && featureXML.hasOwnProperty("frictionless"))
            {
               this.m_frictionless = featureXML.frictionless == "true";
            }
            if(Boolean(featureXML) && featureXML.hasOwnProperty("experimentGate"))
            {
               this.m_experiment = featureXML.experimentGate;
            }
            if(Boolean(featureXML) && featureXML.hasOwnProperty("inAppPurchase"))
            {
               this.m_inAppPurchase = featureXML.inAppPurchase;
            }
            if(Boolean(featureXML) && featureXML.hasOwnProperty("showExpansionOnBuild"))
            {
               this.m_showExpansionOnBuild = featureXML.showExpansionOnBuild == "true";
            }
            if(Boolean(featureXML) && featureXML.hasOwnProperty("icon"))
            {
               this.m_iconUrl = featureXML.icon;
            }
            if(Boolean(featureXML) && featureXML.hasOwnProperty("awardDialog"))
            {
               this.m_awardDialog = featureXML.awardDialog;
            }
            if(Boolean(featureXML) && featureXML.hasOwnProperty("awardDialogBackground"))
            {
               this.m_awardDialogBackground = featureXML.awardDialogBackground;
            }
            if(featureXML.hasOwnProperty("upgradeMax"))
            {
               this.m_upgradeMax = featureXML.upgradeMax;
            }
            for each(rewardItemXML in featureXML.friendRewards.friendReward)
            {
               this.m_friendRewardTypesHash[String(rewardItemXML.@type)] = String(rewardItemXML.@rewardName);
            }
         }
         this.m_storageLevel = StorageBuilding.getInitialExpansionLevelFromItem(item);
         owner.storageLevel = this.m_storageLevel;
         this.m_dialogPrefix = item.dialogName;
         if(this.m_dialogPrefix.length == 0)
         {
            this.m_dialogPrefix = item.resourcePrefix;
         }
         if(!StorageBuilding.isDynamicPartsExperimentOn())
         {
            this.refreshPartData();
         }
      }
      
      private static function checkExperiment(data:XML, dataSource:BaseDataSource = null) : Boolean
      {
         var experimentGate:String = null;
         var experimentVariant:int = 0;
         var variant:int = 0;
         var result:Boolean = true;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(dataSource)
            {
               experimentGate = dataSource.getString("experimentGate");
               if(experimentGate.length > 0)
               {
                  if(dataSource.hasProperty("experimentVariant"))
                  {
                     experimentVariant = dataSource.getInt("experimentVariant");
                     result = Global.experimentManager.getExperimentVariant(experimentGate) == experimentVariant;
                  }
                  else
                  {
                     result = Global.experimentManager.getExperimentVariant(experimentGate) > 0;
                  }
               }
            }
         }
         else if(data)
         {
            if(data.attribute("experimentGate").length() > 0)
            {
               if(data.attribute("experimentVariant").length() > 0)
               {
                  variant = parseInt(data.attribute("experimentVariant"));
                  result = Global.experimentManager.getExperimentVariant(data.attribute("experimentGate")) == variant;
               }
               else
               {
                  result = Global.experimentManager.getExperimentVariant(data.attribute("experimentGate")) > 0;
               }
            }
         }
         return result;
      }
      
      private static function checkRuntime(data:XML, dataSource:BaseDataSource = null) : Boolean
      {
         var result:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(dataSource)
            {
               result = true;
               if(dataSource.hasProperty("runtimeGate"))
               {
                  result = Global.flashHotParams[dataSource.getString("runtimeGate")] > 0;
               }
            }
         }
         else if(data)
         {
            result = data.attribute("runtimeGate").length() == 0 || Global.flashHotParams[data.attribute("runtimeGate")] > 0;
         }
         return result;
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
      
      public function set storageLevel(level:uint) : void
      {
         this.m_storageLevel = level;
      }
      
      public function get storageLevel() : uint
      {
         return this.m_storageLevel;
      }
      
      public function get inAppPurchase() : Boolean
      {
         if(!this.m_experiment || this.m_experiment == "fv_in_app_purchase" && Global.experimentManager.getExperimentVariant(this.m_experiment) == 2)
         {
            return this.m_inAppPurchase;
         }
         return false;
      }
      
      public function get frictionless() : Boolean
      {
         return this.m_frictionless;
      }
      
      override public function loadObject(data:Object) : void
      {
         var seasonPrereq:String = null;
         var upgradeDataSource:BaseDataSource = null;
         var upgradeData:XML = null;
         if(data.expansionLevel >= 1)
         {
            owner.storageLevel = data.expansionLevel;
            seasonPrereq = "";
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               upgradeDataSource = owner.getItem().getUpgradeDataSource(owner.storageLevel);
               if(upgradeDataSource)
               {
                  owner.capacity = upgradeDataSource.getInt("capacity");
                  owner.seasonPrereq = upgradeDataSource.getString("prereq");
               }
            }
            else
            {
               upgradeData = owner.getItem().getUpgradeData(owner.storageLevel);
               if(upgradeData)
               {
                  owner.capacity = upgradeData.@capacity;
                  owner.seasonPrereq = upgradeData.@prereq;
               }
            }
            if(GlobalEngine.getFlashVar("FEATURE_ANIMAL_PEN_EXPANSIONS") == 1)
            {
               if(Global.player.isDataLoaded)
               {
                  this.showExpansionArrow();
               }
               else
               {
                  Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferShowExpansionArrow,false,0,true);
               }
            }
         }
         this.refreshPartData(data);
      }
      
      private function deferShowExpansionArrow(event:Event) : void
      {
         Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferShowExpansionArrow,false);
         this.showExpansionArrow();
      }
      
      private function showExpansionArrow() : void
      {
         var nextLevelData:BaseDataSource = null;
         var nextLevel:XML = null;
         var backoffKey:String = null;
         var actionCount:int = 0;
         var arrInd:ArrowIndicatorFManager = null;
         var feaBuild:FarmItem = owner.getItem();
         var newLevel:Number = owner.storageLevel + 1;
         var hasNextLevelData:Boolean = false;
         var isNextLevelInfinite:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            nextLevelData = feaBuild.getUpgradeDataSource(newLevel);
            if(nextLevelData)
            {
               hasNextLevelData = true;
               isNextLevelInfinite = nextLevelData.getBoolean("infinite");
            }
         }
         else
         {
            nextLevel = feaBuild.getUpgradeData(newLevel);
            if(nextLevel != null)
            {
               hasNextLevelData = true;
               isNextLevelInfinite = nextLevel["@infinite"] == "true";
            }
         }
         if(hasNextLevelData)
         {
            backoffKey = feaBuild.name + newLevel.toString() + "InfiniteBouncyArrow";
            actionCount = Global.player.getActionCount(backoffKey);
            if(actionCount < 3 && !Global.player.getSeenSessionFlag(backoffKey) && isNextLevelInfinite)
            {
               Global.player.setSeenSessionFlag(backoffKey);
               Global.player.incrementActionCount(backoffKey);
               arrInd = owner.arrowIndicator;
               if(arrInd == null)
               {
                  arrInd = new AnimalBreedingExpandIndicatorFManager(owner);
                  owner.overrideArrowIndicator = arrInd;
               }
               arrInd.show("expand");
            }
         }
      }
      
      public function get friendRewardTypesHash() : Array
      {
         return this.m_friendRewardTypesHash;
      }
      
      public function get showExpansionOnBuild() : Boolean
      {
         return this.m_showExpansionOnBuild;
      }
      
      public function getFriendRewardNameByType(friendRewardType:String) : String
      {
         var result:String = null;
         if(this.m_friendRewardTypesHash.hasOwnProperty(friendRewardType))
         {
            result = this.m_friendRewardTypesHash[friendRewardType];
         }
         return result;
      }
      
      public function getPartAskMethod(itemCode:String) : String
      {
         return this.m_askMethods[itemCode];
      }
      
      public function maxExpansionLevel() : int
      {
         return this.m_upgradeMax;
      }
      
      protected function get itemName() : String
      {
         return owner.getItem().name;
      }
      
      public function onStoreExpandable(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            TransactionManager.addTransaction(new TInventoryStore(owner,0,owner.getId(),true));
            FarmStatsManager.sample(100,"Storage","goods","stored","store_it_menu","sucess");
            owner.detach();
         }
      }
      
      public function isValidExpansionPart(resource:MapResource) : Boolean
      {
         var buildingExpansionData:BuildingExpansionData = null;
         var part:PartItem = null;
         var upgradeDataSource:BaseDataSource = null;
         var partDataArray:Array = null;
         var resourceItemName:String = null;
         var partData:BaseDataSource = null;
         var upgradeData:XML = null;
         var itemName:String = null;
         var isValid:Boolean = false;
         if(StorageBuilding.isDynamicPartsExperimentOn())
         {
            buildingExpansionData = this.getNextBuildingExpansionData();
            if(buildingExpansionData)
            {
               part = buildingExpansionData.getPartByName(resource.getItem().name);
               isValid = part != null;
            }
         }
         else if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            upgradeDataSource = this.getNextExpansionDataSource();
            if(Boolean(upgradeDataSource) && Boolean(checkExperiment(null,upgradeDataSource)) && checkRuntime(null,upgradeDataSource))
            {
               partDataArray = upgradeDataSource.getArray("part");
               if(partDataArray.length > 0)
               {
                  resourceItemName = resource.getItem().name;
                  for each(partData in partDataArray)
                  {
                     if(partData.getString("name") == resourceItemName)
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
            if(Boolean(upgradeData && upgradeData.part) && Boolean(checkExperiment(upgradeData)) && checkRuntime(upgradeData))
            {
               itemName = resource.getItem().name;
               isValid = upgradeData.part.(@name == itemName).length() > 0;
            }
         }
         return isValid;
      }
      
      public function getNextExpansionData() : XML
      {
         var result:XML = null;
         var data:XML = owner.getItem().getUpgradeData(this.storageLevel + 1);
         if(Boolean(data) && Boolean(checkExperiment(data)) && checkRuntime(data))
         {
            result = data;
         }
         return result;
      }
      
      public function getNextExpansionDataSource() : BaseDataSource
      {
         var result:BaseDataSource = null;
         var data:BaseDataSource = owner.getItem().getUpgradeDataSource(this.storageLevel + 1);
         if(Boolean(data) && Boolean(checkExperiment(null,data)) && checkRuntime(null,data))
         {
            result = data;
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
      
      public function getExpandSlotData() : Array
      {
         var buildingExpansionData:BuildingExpansionData = null;
         var parts:Vector.<PartItem> = null;
         var part:PartItem = null;
         var upgradeDataSource:BaseDataSource = null;
         var partDataArray:Array = null;
         var partData:BaseDataSource = null;
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
         else if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            upgradeDataSource = this.getNextExpansionDataSource();
            if(upgradeDataSource)
            {
               partDataArray = upgradeDataSource.getArray("part");
               result = [];
               if(partDataArray.length > 0)
               {
                  for each(partData in partDataArray)
                  {
                     result.push({
                        "name":partData.getString("name"),
                        "need":partData.getInt("need")
                     });
                  }
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
      
      public function getNextBuildingExpansionData() : BuildingExpansionData
      {
         var result:BuildingExpansionData = null;
         var buildingExpansionData:BuildingExpansionData = m_owner.getBuildingExpansionDataByLevel(this.storageLevel + 1);
         if(Boolean(buildingExpansionData) && buildingExpansionData.isEnabled())
         {
            result = buildingExpansionData;
         }
         return result;
      }
      
      public function getCurrentBuildingExpansionData() : BuildingExpansionData
      {
         var result:BuildingExpansionData = null;
         var buildingExpansionData:BuildingExpansionData = m_owner.getBuildingExpansionDataByLevel(this.storageLevel);
         if(Boolean(buildingExpansionData) && buildingExpansionData.isEnabled())
         {
            result = buildingExpansionData;
         }
         return result;
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
      
      public function get expansionParts() : Dictionary
      {
         return this.m_expansionParts;
      }
      
      public function getExpansionPartLimit(itemCode:String) : int
      {
         var buildingExpansionData:BuildingExpansionData = null;
         var part:PartItem = null;
         var upgradeDataSource:BaseDataSource = null;
         var partDataArray:Array = null;
         var farmItem:FarmItem = null;
         var partData:BaseDataSource = null;
         var upgradeData:XML = null;
         var item:FarmItem = null;
         var partList:XMLList = null;
         var limit:int = 0;
         if(StorageBuilding.isDynamicPartsExperimentOn())
         {
            buildingExpansionData = this.getNextBuildingExpansionData();
            if(buildingExpansionData)
            {
               part = buildingExpansionData.getPartByCode(itemCode);
               if(Boolean(part) && Boolean(part.item))
               {
                  limit = part.qtyNeeded;
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
      
      public function getTotalExpansionLimitCount() : int
      {
         var expansionPart:String = null;
         var count:int = 0;
         for(expansionPart in this.m_expansionParts)
         {
            count += this.getExpansionPartLimit(expansionPart);
         }
         return count;
      }
      
      public function hasReachedMaxExpansionLevel() : Boolean
      {
         var result:Boolean = false;
         var nextBuildingExpansionData:BuildingExpansionData = null;
         var data:XML = null;
         var dataSource:BaseDataSource = null;
         if(StorageBuilding.isDynamicPartsExperimentOn())
         {
            nextBuildingExpansionData = this.getNextBuildingExpansionData();
            result = nextBuildingExpansionData == null;
         }
         else
         {
            data = null;
            dataSource = null;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               dataSource = this.getNextExpansionDataSource();
            }
            else
            {
               data = this.getNextExpansionData();
            }
            result = !((data || dataSource) && checkExperiment(data,dataSource) && checkRuntime(data,dataSource));
         }
         return result;
      }
      
      public function addExpansionPart(resource:MapResource) : Boolean
      {
         var buildingExpansionData:BuildingExpansionData = null;
         var part:PartItem = null;
         var resourceItemCode:String = null;
         var numPartsNeeded:Number = NaN;
         var isExpansionComplete:Boolean = false;
         var parts:Vector.<PartItem> = null;
         var partItem:PartItem = null;
         var partFarmItem:FarmItem = null;
         var partsNeeded:int = 0;
         var itemCode:String = null;
         var maxCount:Number = NaN;
         var completedExpansion:Boolean = false;
         var farmItemForPart:FarmItem = null;
         var itemName:String = null;
         var upgradeDataSource:BaseDataSource = null;
         var partDataArray:Array = null;
         var partDataSource:BaseDataSource = null;
         var hasSpecifiedPart:Boolean = false;
         var partName:String = null;
         var partNeed:int = 0;
         var upgradeData:XML = null;
         var partList:XMLList = null;
         var partData:XML = null;
         var partXml:XML = null;
         var needed:int = 0;
         var success:Boolean = false;
         if(StorageBuilding.isDynamicPartsExperimentOn())
         {
            buildingExpansionData = this.getNextBuildingExpansionData();
            if(buildingExpansionData)
            {
               part = buildingExpansionData.getPartByName(resource.getItem().name);
               if(part)
               {
                  resourceItemCode = resource.getItem().code;
                  numPartsNeeded = part.qtyNeeded;
                  if(!this.m_expansionParts[resourceItemCode])
                  {
                     this.m_expansionParts[resourceItemCode] = 0;
                  }
                  if(this.m_expansionParts[resourceItemCode] < numPartsNeeded)
                  {
                     ++this.m_expansionParts[resourceItemCode];
                     isExpansionComplete = true;
                     parts = buildingExpansionData.parts;
                     for each(partItem in parts)
                     {
                        partFarmItem = partItem.item;
                        if(partFarmItem)
                        {
                           partsNeeded = partItem.qtyNeeded;
                           if(!this.m_expansionParts[partFarmItem.code] || this.m_expansionParts[partFarmItem.code] < partsNeeded)
                           {
                              isExpansionComplete = false;
                              break;
                           }
                        }
                     }
                     if(isExpansionComplete && !owner.isNextStageRegionLocked())
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
            itemName = resource.getItem().name;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               upgradeDataSource = this.getNextExpansionDataSource();
               if(upgradeDataSource)
               {
                  partDataArray = upgradeDataSource.getArray("part");
                  if(partDataArray.length > 0)
                  {
                     hasSpecifiedPart = false;
                     for each(partDataSource in partDataArray)
                     {
                        if(partDataSource.getString("name") == itemName)
                        {
                           hasSpecifiedPart = true;
                           break;
                        }
                     }
                     if(hasSpecifiedPart)
                     {
                        itemCode = resource.getItem().code;
                        maxCount = partDataSource.getInt("need");
                        if(!this.m_expansionParts[itemCode])
                        {
                           this.m_expansionParts[itemCode] = 0;
                        }
                        if(this.m_expansionParts[itemCode] < maxCount)
                        {
                           ++this.m_expansionParts[itemCode];
                           completedExpansion = true;
                           for each(partDataSource in partDataArray)
                           {
                              partName = partDataSource.getString("name");
                              farmItemForPart = Global.farmGameSettingsManager.getFarmItemByName(partName);
                              if(farmItemForPart)
                              {
                                 partNeed = partDataSource.getInt("need");
                                 if(!this.m_expansionParts[farmItemForPart.code] || this.m_expansionParts[farmItemForPart.code] < partNeed)
                                 {
                                    completedExpansion = false;
                                    break;
                                 }
                              }
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
                           farmItemForPart = Global.farmGameSettingsManager.getFarmItemByName(partXml.@name);
                           if(farmItemForPart)
                           {
                              needed = parseInt(partXml.@need);
                              if(!this.m_expansionParts[farmItemForPart.code] || this.m_expansionParts[farmItemForPart.code] < needed)
                              {
                                 completedExpansion = false;
                                 break;
                              }
                           }
                        }
                     }
                  }
               }
            }
            if(completedExpansion && !owner.isNextStageRegionLocked())
            {
               this.completeExpansionLevel();
            }
            success = true;
         }
         return success;
      }
      
      public function completeExpansionLevel() : void
      {
         var nextExpansionXml:XML = null;
         var nextExpansionDS:BaseDataSource = null;
         var activeGameMode:GameMode = null;
         var isWitherable:Boolean = owner.witherer != null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            nextExpansionDS = this.getNextExpansionDataSource();
         }
         else
         {
            nextExpansionXml = this.getNextExpansionData();
         }
         owner.setState(owner.STATE_BUSY);
         owner.capacity = owner.getNextExpansionCapacity();
         this.grantUpgradeAwards([new NextExpandAwardData(nextExpansionXml,nextExpansionDS)]);
         ++owner.storageLevel;
         this.refreshPartData();
         if(isWitherable != (owner.witherer != null))
         {
            owner.plantTime = Global.worldTime;
         }
         if(this.hasNextExpansion())
         {
            for each(activeGameMode in Global.world.getActiveGameModes())
            {
               if(activeGameMode is GMSpecialDeliveryApply)
               {
                  (activeGameMode as GMSpecialDeliveryApply).suppressBuildingSpliceThenRefresh();
                  break;
               }
            }
         }
      }
      
      public function refreshPartData(data:Object = null) : void
      {
         var buildingExpansionData:BuildingExpansionData = null;
         var parts:Vector.<PartItem> = null;
         var part:PartItem = null;
         var itemCode:String = null;
         var askMethod:String = null;
         var upgradeDataSource:BaseDataSource = null;
         var partDataArray:Array = null;
         var partDataSource:BaseDataSource = null;
         var partCode:String = null;
         var partRequestType:String = null;
         var upgradeData:XML = null;
         var partData:XML = null;
         var partItemCode:String = null;
         var partAskMethod:String = null;
         this.m_expansionParts = new Dictionary();
         this.m_askMethods = new Dictionary();
         if(StorageBuilding.isDynamicPartsExperimentOn())
         {
            buildingExpansionData = this.getNextBuildingExpansionData();
            if(buildingExpansionData)
            {
               parts = buildingExpansionData.parts;
               for each(part in parts)
               {
                  itemCode = part.item.code;
                  askMethod = part.requestType;
                  if(askMethod == null || askMethod == "")
                  {
                     askMethod = FeatureBuilding.DEFAULT_PART_ASK_METHOD;
                  }
                  if(data)
                  {
                     this.m_expansionParts[itemCode] = data.expansionParts[itemCode];
                  }
                  else
                  {
                     this.m_expansionParts[itemCode] = 0;
                  }
                  this.m_askMethods[itemCode] = askMethod;
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
                  for each(partDataSource in partDataArray)
                  {
                     partCode = Global.farmGameSettingsManager.getFarmItemCodeByName(partDataSource.getString("name"));
                     partRequestType = partDataSource.getString("requestType");
                     if(partRequestType == "")
                     {
                        partRequestType = FeatureBuilding.DEFAULT_PART_ASK_METHOD;
                     }
                     if(data)
                     {
                        this.m_expansionParts[partCode] = data.expansionParts[partCode];
                     }
                     else
                     {
                        this.m_expansionParts[partCode] = 0;
                     }
                     this.m_askMethods[partCode] = partRequestType;
                  }
               }
            }
         }
         else
         {
            upgradeData = this.getNextExpansionData();
            if(upgradeData)
            {
               for each(partData in upgradeData.part)
               {
                  partItemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(partData[XMLKeys.ATTR_NAME]);
                  partAskMethod = String(partData[XMLKeys.ATTR_REQUEST_TYPE]);
                  if(partAskMethod == null || partAskMethod == "")
                  {
                     partAskMethod = FeatureBuilding.DEFAULT_PART_ASK_METHOD;
                  }
                  if(data)
                  {
                     this.m_expansionParts[partItemCode] = data.expansionParts[partItemCode];
                  }
                  else
                  {
                     this.m_expansionParts[partItemCode] = 0;
                  }
                  this.m_askMethods[partItemCode] = partAskMethod;
               }
            }
         }
      }
      
      public function refreshAskMethods() : void
      {
         var buildingExpansionData:BuildingExpansionData = null;
         var parts:Vector.<PartItem> = null;
         var part:PartItem = null;
         var itemCode:String = null;
         var askMethod:String = null;
         if(StorageBuilding.isDynamicPartsExperimentOn() && Boolean(Global.flashHotParams["FEATUREBUILDING_REFRESH_ASK_METHOD"]))
         {
            this.m_askMethods = new Dictionary();
            buildingExpansionData = this.getNextBuildingExpansionData();
            if(buildingExpansionData)
            {
               parts = buildingExpansionData.parts;
               for each(part in parts)
               {
                  itemCode = part.item.code;
                  askMethod = part.requestType;
                  if(askMethod == null || askMethod == "")
                  {
                     askMethod = FeatureBuilding.DEFAULT_PART_ASK_METHOD;
                  }
                  this.m_askMethods[itemCode] = askMethod;
               }
            }
         }
      }
      
      protected function onCompleteExpansion(rewardLink:String, itemName:String) : void
      {
         var rewardObj:Object = null;
         owner.setState(owner.STATE_BUILT);
         owner.reloadImage();
         var farmItem:FarmItem = this.owner.getItem();
         var iconUrlSuffix:String = this.owner.getCurrentSuffix().toString();
         var iconUrl:String = farmItem.getImageByName("icon_" + iconUrlSuffix,false);
         if(iconUrl == null || iconUrl == "")
         {
            iconUrl = EXPAND_IMAGE_ICON_URL_PREFIX + owner.getImageIcon() + EXPAND_IMAGE_ICON_URL_SUFFIX;
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FACEBOOK_FEED_ICONS) > 1)
         {
            iconUrl = farmItem.getImageByName("icon_" + iconUrlSuffix + "_200",false);
            if(iconUrl == null || iconUrl == "")
            {
               iconUrl = EXPAND_IMAGE_ICON_URL_PREFIX + owner.getImageIcon() + EXPAND_IMAGE_ICON_URL_SUFFIX_200;
            }
         }
         if(this.m_iconUrl)
         {
            iconUrl = this.m_iconUrl;
         }
         var feedKey:String = owner.getItem().resourcePrefix + "_" + StatsTrackingConstants.DIALOG_STATE_EXPANSION_COMPLETE_KINGDOM;
         var feedImage:String = Global.getAssetURL(iconUrl);
         var itemFriendlyName:String = Global.farmGameSettingsManager.getFarmItemByName(itemName).friendlyName;
         var dialogKey:String = this.m_dialogPrefix + "_" + StatsTrackingConstants.DIALOG_STATE_EXPANSION_COMPLETE_KINGDOM;
         var fallbackKey:String = FeatureBuilding.FALLBACK_KEY + StatsTrackingConstants.DIALOG_STATE_EXPANSION_COMPLETE_KINGDOM;
         var fallbackDialogKey:String = fallbackKey;
         FarmStatsManager.count(farmItem.friendlyTitle,owner.storageLevel.toString(),"level_completed",itemName);
         var rewardName:String = owner.getHarvestRewardName();
         if(rewardName == "")
         {
            fallbackDialogKey += "_noReward";
         }
         var promptParams:Object = {
            "item":ZLocUtils.tk_pk(itemFriendlyName),
            "building":ZLocUtils.tk_pk(this.owner.getItemFriendlyName()),
            "rewardItem":ZLocUtils.tk_pk(rewardName)
         };
         if(farmItem)
         {
            rewardObj = farmItem.getUpgradeWorldScoreRewardObject(owner.storageLevel);
            if(rewardObj != null)
            {
               promptParams[rewardObj.unit] = rewardObj.amount;
            }
         }
         var message:String = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs",dialogKey + owner.storageLevel.toString()),new ZLocFailoverEntry("Dialogs",dialogKey),new ZLocFailoverEntry("Dialogs",fallbackDialogKey)],promptParams);
         var fallbackStats:Object = {"subcategory":farmItem.name};
         var trackerKey:String = "feed-" + feedKey;
         var tutorialShown:Boolean = owner.dispatchTutorialEvent(TutorialFManager.TUTORIAL_EVENT_EXPAND_COMPLETE);
         if(!tutorialShown)
         {
            ExpansionFeedManager.onCompleteExpansionMilestone(rewardLink,feedKey,Global.getAssetURL(iconUrl),trackerKey,message,this.owner.getItemFriendlyName(),itemFriendlyName,this.onFinishShareExpansionReward,fallbackKey,fallbackStats);
         }
      }
      
      protected function onCompleteHalfExpansion(rewardLink:String) : void
      {
         var farmItem:FarmItem = this.owner.getItem();
         var iconUrlSuffix:String = this.owner.getCurrentSuffix().toString();
         var iconUrl:String = farmItem.getImageByName("icon_" + iconUrlSuffix,false);
         if(iconUrl == null || iconUrl == "")
         {
            iconUrl = EXPAND_IMAGE_ICON_URL_PREFIX + owner.assetKey + "_" + owner.storageLevel.toString() + EXPAND_IMAGE_ICON_URL_SUFFIX;
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FACEBOOK_FEED_ICONS) > 1)
         {
            iconUrl = farmItem.getImageByName("icon_" + iconUrlSuffix + "_200",false);
            if(iconUrl == null || iconUrl == "")
            {
               iconUrl = EXPAND_IMAGE_ICON_URL_PREFIX + owner.assetKey + "_" + owner.storageLevel.toString() + EXPAND_IMAGE_ICON_URL_SUFFIX_200;
            }
         }
         var feedKey:String = owner.getItem().resourcePrefix + "_" + StatsTrackingConstants.DIALOG_STATE_HALFWAY_COMPLETE_KINGDOM;
         var dialogKey:String = this.m_dialogPrefix + "_" + StatsTrackingConstants.DIALOG_STATE_HALFWAY_COMPLETE_KINGDOM;
         var fallbackKey:String = FeatureBuilding.FALLBACK_KEY + StatsTrackingConstants.DIALOG_STATE_HALFWAY_COMPLETE_KINGDOM;
         var message:String = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs",dialogKey),new ZLocFailoverEntry("Dialogs",fallbackKey)],{"building":ZLocUtils.tk_pk(farmItem.friendlyName)});
         var fallbackStats:Object = {"subcategory":farmItem.name};
         var trackerKey:String = "feed-" + feedKey;
         ExpansionFeedManager.onCompleteExpansionMilestone(rewardLink,feedKey,Global.getAssetURL(iconUrl),trackerKey,message,farmItem.friendlyName,"",this.onFinishShareExpansionReward,fallbackKey,fallbackStats,Global.farmGameSettingsManager.shouldBlockProgressionPopupForItem(farmItem));
      }
      
      protected function onCompleteExpansionPart(rewardLink:String, itemName:String) : void
      {
         var farmItem:FarmItem = this.owner.getItem();
         var feedKey:String = owner.getItem().resourcePrefix + "_" + StatsTrackingConstants.DIALOG_STATE_MATERIALS_COMPLETE_KINGDOM;
         var itemFriendlyName:String = Global.farmGameSettingsManager.getFarmItemByName(itemName).friendlyName;
         var partItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         var partImage:String = partItem.iconUrl;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FACEBOOK_FEED_ICONS) > 1)
         {
            partImage = partItem.getImageByName("feed",true);
         }
         var dialogKey:String = this.m_dialogPrefix + "_" + StatsTrackingConstants.DIALOG_STATE_MATERIALS_COMPLETE_KINGDOM;
         var fallbackKey:String = FeatureBuilding.FALLBACK_KEY + StatsTrackingConstants.DIALOG_STATE_MATERIALS_COMPLETE_KINGDOM;
         var message:String = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs",dialogKey),new ZLocFailoverEntry("Dialogs",fallbackKey)],{
            "item":ZLocUtils.tk_pk(itemFriendlyName),
            "building":ZLocUtils.tk_pk(farmItem.friendlyName)
         });
         var fallbackStats:Object = {"subcategory":farmItem.name};
         var trackerKey:String = "feed-" + feedKey;
         ExpansionFeedManager.onCompleteExpansionMilestone(rewardLink,feedKey,partImage,trackerKey,message,farmItem.friendlyName,itemFriendlyName,this.onFinishShareExpansionReward,fallbackKey,fallbackStats,Global.farmGameSettingsManager.shouldBlockProgressionPopupForItem(farmItem));
      }
      
      protected function onCompleteExpansionPartsInterval(rewardLink:String, itemName:String) : void
      {
         var farmItem:FarmItem = this.owner.getItem();
         var iconUrlSuffix:String = this.owner.getCurrentSuffix().toString();
         var iconUrl:String = farmItem.getImageByName("icon_" + iconUrlSuffix,false);
         if(iconUrl == null || iconUrl == "")
         {
            iconUrl = EXPAND_IMAGE_ICON_URL_PREFIX + owner.assetKey + "_" + owner.storageLevel.toString() + EXPAND_IMAGE_ICON_URL_SUFFIX;
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FACEBOOK_FEED_ICONS) > 1)
         {
            iconUrl = farmItem.getImageByName("icon_" + iconUrlSuffix + "_200",false);
            if(iconUrl == null || iconUrl == "")
            {
               iconUrl = EXPAND_IMAGE_ICON_URL_PREFIX + owner.assetKey + "_" + owner.storageLevel.toString() + EXPAND_IMAGE_ICON_URL_SUFFIX_200;
            }
         }
         var feedKey:String = owner.getItem().resourcePrefix + "_" + StatsTrackingConstants.DIALOG_STATE_MATERIALS_INTERVAL_KINGDOM;
         var feedImage:String = Global.getAssetURL(iconUrl);
         var trackerKey:String = "feed-" + feedKey;
         var dialogKey:String = this.m_dialogPrefix + "_" + StatsTrackingConstants.DIALOG_STATE_MATERIALS_INTERVAL_KINGDOM;
         var fallbackKey:String = FeatureBuilding.FALLBACK_KEY + StatsTrackingConstants.DIALOG_STATE_MATERIALS_INTERVAL_KINGDOM;
         var message:String = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs",dialogKey),new ZLocFailoverEntry("Dialogs",fallbackKey)],{"building":ZLocUtils.tk_pk(farmItem.friendlyName)});
         var fallbackStats:Object = {"subcategory":farmItem.name};
         ExpansionFeedManager.onCompleteExpansionMilestone(rewardLink,feedKey,feedImage,trackerKey,message,farmItem.friendlyName,"",this.onFinishShareExpansionReward,fallbackKey,fallbackStats,Global.farmGameSettingsManager.shouldBlockProgressionPopupForItem(farmItem));
      }
      
      private function onFinishShareExpansionReward(feedAction:String, bundleData:Object) : void
      {
         if(!this.hasReachedMaxExpansionLevel() && feedAction.indexOf("expansionComplete") > 0)
         {
            if(this.m_showExpansionOnBuild)
            {
               owner.displayExpandDialog();
            }
         }
      }
      
      public function onStoreComplete(result:Object) : void
      {
         var finishedStorageBuilding:StorageBuilding = null;
         var smartBuildablesEnabled:Boolean = StorageBuilding.isSmartBuildablesEnabled();
         if(smartBuildablesEnabled)
         {
            if(Boolean(result.expansionRewardType) && result.expansionRewardType == this.EXPANSION_REWARD_TYPE_COMPLETE)
            {
               owner.setState(owner.STATE_BUILT);
               this.conditionallySwapOnFullyExpanded();
            }
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
                  this.onCompleteExpansion(result.rewardLink,result.rewardItem);
                  if(smartBuildablesEnabled)
                  {
                     finishedStorageBuilding = this.m_transformedObject as StorageBuilding;
                     if(finishedStorageBuilding)
                     {
                        finishedStorageBuilding.applySmartSystems(result);
                     }
                     else
                     {
                        m_owner.applySmartSystems(result);
                     }
                  }
                  break;
               case this.EXPANSION_REWARD_TYPE_PARTS_INTERVAL:
                  this.onCompleteExpansionPartsInterval(result.rewardLink,result.rewardItem);
            }
         }
         if(!smartBuildablesEnabled)
         {
            if(Boolean(result.expansionRewardType) && result.expansionRewardType == this.EXPANSION_REWARD_TYPE_COMPLETE)
            {
               owner.setState(owner.STATE_BUILT);
               this.conditionallySwapOnFullyExpanded();
            }
         }
      }
      
      public function conditionallySwapOnFullyExpanded() : void
      {
         var finishedName:String = null;
         var finishedItem:FarmItem = null;
         var currentItemName:String = null;
         var currentPosition:Vector3 = null;
         var id:Number = NaN;
         var tempClass:Class = null;
         var transformedObject:MapResource = null;
         var storageBuilding:StorageBuilding = null;
         if(this.hasReachedMaxExpansionLevel() && m_owner.isAttached())
         {
            finishedName = m_owner.getItem().getFinishedName();
            if(Boolean(finishedName) && finishedName != "")
            {
               finishedItem = Global.farmGameSettingsManager.getFarmItemByName(finishedName);
               if(finishedItem)
               {
                  currentItemName = m_owner.getItem().name;
                  Global.player.removeLimitedItem(currentItemName);
                  currentPosition = m_owner.getPosition();
                  id = m_owner.getId();
                  m_owner.detach();
                  if(m_owner.count < m_owner.capacity)
                  {
                     Global.player.updatePlayerStat(StatsDropDown.INDEX_BUILDINGS,0);
                  }
                  tempClass = getDefinitionByName("Classes." + finishedItem.className) as Class;
                  transformedObject = new tempClass(finishedItem.name);
                  transformedObject.setMetadata(m_owner.getMetadata());
                  transformedObject.attachToPersistentData(m_owner.persistentDataKey);
                  transformedObject.setOuter(Global.world);
                  transformedObject.setPosition(currentPosition.x,currentPosition.y,currentPosition.z);
                  transformedObject.conditionallyReattach();
                  transformedObject.setId(id);
                  storageBuilding = transformedObject as StorageBuilding;
                  if(storageBuilding)
                  {
                     if(storageBuilding.shouldCopyPartsWhenReplacing())
                     {
                        storageBuilding.copyParts(m_owner);
                     }
                     if(storageBuilding.shouldCopyStorageWhenReplacing())
                     {
                        storageBuilding.copyStorage(m_owner);
                     }
                     if(storageBuilding.shouldCopyPlantTimeWhenReplacing())
                     {
                        storageBuilding.plantTime = m_owner.plantTime;
                     }
                     if(FarmGameSettingsManager.isInDataSourceExperiment())
                     {
                        if(finishedItem.hasPropertyInDataSource("initialExpansionLevel"))
                        {
                           storageBuilding.storageLevel = finishedItem.getIntFromDataSource("initialExpansionLevel");
                        }
                     }
                     else if(finishedItem.xml.hasOwnProperty("initialExpansionLevel"))
                     {
                        storageBuilding.storageLevel = parseInt(finishedItem.xml.initialExpansionLevel);
                     }
                  }
                  if(transformedObject is Building)
                  {
                     (transformedObject as Building).setState(FeatureBuilding.STATE_BUILT);
                  }
                  else if(transformedObject is SimpleHarvestableResource)
                  {
                     (transformedObject as SimpleHarvestableResource).setState(FeatureBuilding.STATE_BARE);
                  }
                  this.m_transformedObject = transformedObject;
               }
            }
         }
      }
      
      public function grantUpgradeAwards(result:Array) : void
      {
         var award:NextExpandAwardData = null;
         var awardItem:FarmItem = null;
         var addToBuilding:Boolean = false;
         var classType:Class = null;
         var mapResource:MapResource = null;
         var messageKey:String = null;
         var customMessageKey:String = null;
         var params:Object = null;
         var message:String = null;
         var dialog:GenericIconPopup = null;
         var ownerItemName:String = m_owner.getItemName();
         var upgradeAwardBuilding:String = "Items:" + ownerItemName + "_friendlyName";
         var arrLen:int = int(result.length);
         for(var i:int = 0; i < arrLen; i++)
         {
            award = result[i];
            if(award.itemName != null && award.itemName != "")
            {
               awardItem = Global.farmGameSettingsManager.getFarmItemByName(award.itemName);
               if(awardItem != null)
               {
                  addToBuilding = award.addToBuilding;
                  if(addToBuilding)
                  {
                     classType = awardItem.getMapResourceClass();
                     mapResource = new classType(awardItem.name);
                     if(m_owner.canTakeItem(mapResource))
                     {
                        m_owner.addItem(mapResource,0,false,false);
                     }
                  }
                  else
                  {
                     Global.player.addGift(award.itemName,"0",award.quantity);
                  }
                  if(award.awardDialog != null)
                  {
                     UI.displayPopup(new GenericSingleRewardPopup(award.awardDialog,ownerItemName + award.itemName,awardItem,null,award.awardDialogBackground),false);
                  }
                  else if(this.m_awardDialog != null)
                  {
                     UI.displayPopup(new GenericSingleRewardPopup(this.m_awardDialog,ownerItemName,awardItem,null,this.m_awardDialogBackground),false);
                  }
                  else
                  {
                     if(award.hasOwnProperty("number") && award["number"] > 1)
                     {
                        messageKey = addToBuilding ? "UpgradeAwardAddedToBuildingToasterReward" : "UpgradeAwardToasterReward";
                     }
                     else
                     {
                        messageKey = addToBuilding ? "UpgradeAwardAddedToBuildingToasterReward_Numberless" : "UpgradeAwardToasterReward_Numberless";
                     }
                     customMessageKey = messageKey + "_" + m_owner.getItemName();
                     if(ZLocUtils.hasString("Dialogs",customMessageKey))
                     {
                        messageKey = customMessageKey;
                     }
                     params = {
                        "number":(award.hasOwnProperty("number") ? award["number"] : 1),
                        "item":ZLocUtils.tk_pk_asTitle(awardItem.friendlyName),
                        "building":ZLocUtils.tk_pk_asTitle(upgradeAwardBuilding)
                     };
                     message = ZLocUtils.t("Dialogs",messageKey,params);
                     if(message)
                     {
                        dialog = new GenericIconPopup(message,GenericPopup.TYPE_OK,null,awardItem.icon);
                        UI.displayPopup(dialog);
                     }
                  }
               }
            }
         }
      }
      
      public function getNextUpgradeAward() : String
      {
         var result:String = null;
         var upgradeDataSource:BaseDataSource = null;
         var awardDataSource:BaseDataSource = null;
         var upgradeData:XML = null;
         var awardData:XML = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            upgradeDataSource = this.getNextExpansionDataSource();
            if(upgradeDataSource)
            {
               awardDataSource = upgradeDataSource.getData("award");
               if(awardDataSource)
               {
                  result = awardDataSource.getString("name");
               }
            }
         }
         else
         {
            upgradeData = this.getNextExpansionData();
            if(upgradeData)
            {
               var _loc6_:int = 0;
               var _loc7_:* = upgradeData.award;
               for each(awardData in _loc7_)
               {
                  result = awardData[XMLKeys.ATTR_NAME];
               }
            }
         }
         return result;
      }
      
      public function getExpandCashNeeded() : int
      {
         var totalCashNeed:Number = m_owner.getRawExpansionPartsCost();
         var multiplier:Number = this.expandPriceMultiplier;
         if(multiplier > 0 && multiplier != 1)
         {
            totalCashNeed = Math.ceil(multiplier * totalCashNeed);
         }
         return totalCashNeed;
      }
      
      public function get expandPriceMultiplier() : Number
      {
         var experiment:String = null;
         var variant:int = 0;
         var featureData:BaseDataSource = null;
         var variantDataArray:Array = null;
         var variantData:BaseDataSource = null;
         var featureXML:XML = null;
         var variantXML:XML = null;
         var multiplier:Number = 1;
         var item:FarmItem = m_owner.getFarmItem();
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            featureData = item.getFeatureDataByName(this.m_featureName);
            if(featureData.hasProperty("expandPriceTest"))
            {
               experiment = featureData.getString("expandPriceTest","experiment");
               variantDataArray = featureData.getArray("exparndPriceTest","variant");
               variant = Global.experimentManager.getExperimentVariant(experiment);
               for each(variantData in variantDataArray)
               {
                  if(variantData.getInt("number") == variant)
                  {
                     multiplier = variantData.getNumber("multiplier");
                     break;
                  }
               }
            }
         }
         else
         {
            featureXML = item.getFeatureXMLByName(this.m_featureName);
            if(featureXML.hasOwnProperty("expandPriceTest"))
            {
               experiment = featureXML.expandPriceTest.@experiment;
               variant = Global.experimentManager.getExperimentVariant(experiment);
               for each(variantXML in featureXML.expandPriceTest.variant)
               {
                  if(variantXML.@number == variant)
                  {
                     multiplier = Number(variantXML.@multiplier);
                     break;
                  }
               }
            }
         }
         return multiplier;
      }
      
      public function getExpansionPartString() : String
      {
         var buildingExpansionData:BuildingExpansionData = null;
         var parts:Vector.<PartItem> = null;
         var isFirstItem:Boolean = false;
         var partItem:PartItem = null;
         var farmItem:FarmItem = null;
         var firstItem:Boolean = false;
         var partFarmItem:FarmItem = null;
         var upgradeDataSource:BaseDataSource = null;
         var partDataArray:Array = null;
         var partData:BaseDataSource = null;
         var upgradeData:XML = null;
         var partXml:XML = null;
         var result:String = "";
         if(StorageBuilding.isDynamicPartsExperimentOn())
         {
            if(this.hasNextExpansion())
            {
               buildingExpansionData = this.getNextBuildingExpansionData();
            }
            else
            {
               buildingExpansionData = this.getCurrentBuildingExpansionData();
            }
            if(buildingExpansionData)
            {
               parts = buildingExpansionData.parts;
               if(parts)
               {
                  isFirstItem = true;
                  for each(partItem in parts)
                  {
                     farmItem = partItem.item;
                     if(farmItem)
                     {
                        if(isFirstItem)
                        {
                           result = farmItem.name;
                           isFirstItem = false;
                        }
                        else
                        {
                           result += "," + farmItem.name;
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
                  firstItem = true;
                  for each(partData in partDataArray)
                  {
                     partFarmItem = Global.farmGameSettingsManager.getFarmItemByName(partData.getString("name"));
                     if(partFarmItem)
                     {
                        if(firstItem)
                        {
                           result = partFarmItem.name;
                           firstItem = false;
                        }
                        else
                        {
                           result += "," + partFarmItem.name;
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
               firstItem = true;
               for each(partXml in upgradeData.part)
               {
                  partFarmItem = Global.farmGameSettingsManager.getFarmItemByName(partXml.@name);
                  if(partFarmItem)
                  {
                     if(firstItem)
                     {
                        result = partFarmItem.name;
                        firstItem = false;
                     }
                     else
                     {
                        result += "," + partFarmItem.name;
                     }
                  }
               }
            }
         }
         return result;
      }
      
      public function expandBuildingUsingCurrencyOrCash() : Boolean
      {
         var marketCurr:String = null;
         var result:Boolean = false;
         var priceObject:Object = this.getPriceForExpansion();
         var quantity:int = 0;
         var canBuy:Boolean = true;
         for(marketCurr in priceObject)
         {
            quantity = int(priceObject[marketCurr]);
            if(marketCurr != Currency.CASH && !Global.player.canBuyWithCurrency(marketCurr,quantity,true) || marketCurr == Currency.CASH && !Global.player.canBuy(quantity,true))
            {
               canBuy = false;
               break;
            }
         }
         if(canBuy)
         {
            result = this.buyExpansionWithCurrencyOrCash();
         }
         return result;
      }
      
      private function buyExpansionWithCurrencyOrCash() : Boolean
      {
         var cost:int = 0;
         var costCurr:String = null;
         var result:Boolean = false;
         var priceObject:Object = this.getPriceForExpansion();
         if(m_owner.expandToNextStorageLevel() == true)
         {
            cost = 0;
            for(costCurr in priceObject)
            {
               cost = int(priceObject[costCurr]);
               if(costCurr == Currency.CASH)
               {
                  Global.player.cash -= cost;
                  result = true;
               }
               else
               {
                  result = Global.player.updateWorldCurrency(costCurr,-1 * cost);
               }
            }
            TransactionManager.addTransaction(new TGenericWorldObjectTransaction(m_owner,"ExpandWithCurrency"));
         }
         return result;
      }
      
      public function getPriceForExpansion() : Object
      {
         var itemCode:String = null;
         var currPrice:int = 0;
         var priceObject:Object = new Object();
         var quantity:int = 0;
         var partItem:FarmItem = null;
         var marketCurrency:String = null;
         var expansionParts:Object = m_owner.nextExpansionPartsNeeded();
         for(itemCode in expansionParts)
         {
            quantity = int(expansionParts[itemCode]);
            partItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            marketCurrency = partItem.market;
            currPrice = 0;
            if(priceObject.hasOwnProperty(marketCurrency))
            {
               currPrice = int(priceObject[marketCurrency]);
            }
            if(marketCurrency != Currency.CASH)
            {
               priceObject[marketCurrency] = quantity * partItem.cost + currPrice;
            }
            else
            {
               priceObject[marketCurrency] = quantity * partItem.cash + currPrice;
            }
         }
         return priceObject;
      }
   }
}

