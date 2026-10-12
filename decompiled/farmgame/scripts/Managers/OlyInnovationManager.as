package Managers
{
   import Classes.AreasOfEffect.AOEConfig;
   import Classes.CommunityGoals.CommunityGoalsTask;
   import Classes.Constants.ZLocConstants;
   import Classes.Consumable;
   import Classes.FeatureBuilding;
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Classes.SimpleHarvestableResource;
   import Classes.consumables.CHarvestAnimals;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.*;
   import Display.HUD.HUD;
   import Engine.Constants;
   import Engine.Managers.TransactionManager;
   import Events.FarmGameWorldEvent;
   import Events.TileUnlockEvent;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FeaturePackagesBuyWindow;
   import Widgets.Windows.OlyInnovationAOEWindow;
   import Widgets.Windows.OlyInnovationFinalRewardWindow;
   import Widgets.Windows.OlyInnovationProgresswindow;
   import Widgets.Windows.OlyInnovationWindow;
   import flash.events.Event;
   
   public class OlyInnovationManager extends BaseFeatureManager
   {
      
      public static const ELITEHORSES_BUILDING:String = "xmo_elitehorses";
      
      public static const BIGBUILDABLE_BUILDING:String = "xmo_bigbuildable";
      
      public static const HARVESTBUILDABLE_BUILDING:String = "bldg_xmo_harvestbuildable";
      
      private static const FEATURE_NAME:String = "olympus_innovation";
      
      public static const EVENT_BB_COMPLETE:String = "bbcomplete";
      
      public static const EVENT_HB_COMPLETE:String = "hbcomplete";
      
      public static const EVENT_EH_COMPLETE:String = "ehcomplete";
      
      public static const EVENT_TILE_UNLOCK:String = "OlyInnovationTileUnlock";
      
      public static const WORLD_TYPE:String = "mount";
      
      public static const SERVICE_NAME:String = "OlyInnovationService";
      
      public static const UPDATE_STATE:String = "updateState";
      
      private var m_staticData:Object;
      
      private var m_olyInnovationWindow:OlyInnovationWindow;
      
      private var m_olyInnovationAOEWindow:OlyInnovationAOEWindow;
      
      private var m_assetPaths:Object;
      
      private var m_rewardItemsByType:Array = null;
      
      private const MAPTRIGGER_LAST_USE_TIME_KEY:String = "maptriggerTimeKey";
      
      private const REWARD_KEY:String = "reward";
      
      private const REWARD_REGULAR_KEY:String = "rewardRegular";
      
      private const FINAL_REWARD_KEY:String = "finalReward";
      
      private const RESTORE_TOTEM_SERVICE_CALL:String = "restoreTotem";
      
      private const HARVEST_ANIMALS_SERVICE_CALL:String = "harvestAllAnimals";
      
      private const CREATE_MAPTRIGGER_SERVICE_CALL:String = "createMapTrigger";
      
      private const HARVEST_ANIMALS_CONSUMABLE:String = "consume_farm_hands";
      
      private const TEXT_HEROMENES_NOANIMALS:String = "_heromenes_no_animals";
      
      private const DEFAULT_THROTTLE_TIME:int = 43200;
      
      private var m_animalStorageConsumable:CHarvestAnimals;
      
      private var m_harvestInProgressFlag:Boolean = false;
      
      private var m_harvestableAnimals:Array;
      
      public function OlyInnovationManager(featureName:String)
      {
         super(featureName);
         this.populateFeatureConfig();
         GlobalEventManager.getInstance().addEventListener(EVENT_EH_COMPLETE,this.triggerEHCompletePopUp);
      }
      
      public static function getInstance(featureName:String = "olympus_innovation") : OlyInnovationManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,OlyInnovationManager) as OlyInnovationManager;
      }
      
      public function populateFeatureConfig() : void
      {
         this.loadStaticData();
      }
      
      private function setTileHighlightColors() : void
      {
         var itemXML:XML = null;
         var unlockItemName:String = null;
         var aoeConfig:AOEConfig = null;
         if(featureConfig)
         {
            for each(itemXML in featureConfig.items.item)
            {
               unlockItemName = itemXML.@unlockItemName.toString();
               if(this.isTotemRestored(unlockItemName))
               {
                  aoeConfig = Global.farmGameSettingsManager.getFarmItemByName(unlockItemName).aoeConfig;
                  aoeConfig.highlightColorActive = true;
               }
            }
         }
      }
      
      private function loadStaticData() : void
      {
         var bucketPackagesXML:XML = null;
         var asset:XML = null;
         var item:XML = null;
         var config:Object = null;
         this.m_staticData = new Object();
         this.m_staticData.bucketPackages = new Array();
         this.m_staticData.buyDialogAssetURL = "";
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         if(featureXML != null)
         {
            this.m_assetPaths = new Object();
            if(featureXML.assets != "")
            {
               for each(asset in featureXML.assets.asset)
               {
                  this.m_assetPaths[asset.@name] = asset.@path.toString();
               }
            }
            this.m_staticData.tileConfig = new Array();
            this.m_staticData.buildingConfig = new Array();
            this.m_staticData.cgTasks = new Array();
            if(featureXML.items != "")
            {
               for each(item in featureXML.items.item)
               {
                  config = new Object();
                  config["type"] = item.@type.toString();
                  config["name"] = item.@name.toString();
                  if(config["type"] == "tile")
                  {
                     config["totemCode"] = item.@unlockItemName.toString();
                     config["restoreCost"] = item.@unlockPrice.toString();
                     config["index"] = item.@index.toString();
                     this.m_staticData.tileConfig.push(config);
                  }
                  else if(config["type"] == "building")
                  {
                     config["maxLevel"] = item.@max.toString();
                     config["index"] = item.@index.toString();
                     this.m_staticData.buildingConfig.push(config);
                  }
                  else if(config["type"] == "cgtask")
                  {
                     this.m_staticData.cgTasks.push(config);
                  }
               }
            }
            for each(bucketPackagesXML in featureXML.bucketPackages.bucketPackage)
            {
               this.m_staticData.bucketPackages.push(bucketPackagesXML.@name.toString());
            }
            this.m_staticData.buyDialogAssetURL = featureXML.UI.buyDialog.@path.toString();
            this.m_staticData.currencyItem = featureXML.currency.@name.toString();
         }
      }
      
      public function isTileUnlocked(itemName:String) : Boolean
      {
         if(Global.world.getObjectsByName(itemName).length > 0)
         {
            return false;
         }
         return true;
      }
      
      public function isTotemRestored(totemId:String) : Boolean
      {
         var totemRestored:Boolean = false;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureData(m_featureName);
         if(featureData)
         {
            if(featureData[totemId] == true)
            {
               totemRestored = true;
            }
         }
         return totemRestored;
      }
      
      public function isBuildingComplete(buildingName:String) : Boolean
      {
         var building:Object = null;
         var buildingsArray:Array = this.m_staticData.buildingConfig;
         var completed:Boolean = false;
         for each(building in buildingsArray)
         {
            if(building["name"] == buildingName && building["maxLevel"] == this.getCurrentBuildingLevel(buildingName))
            {
               completed = true;
            }
         }
         return completed;
      }
      
      public function getCurrentBuildingLevel(buildingId:String) : int
      {
         var craftingSystem:FeatureCraftingSystem = null;
         var npcData:Object = null;
         var objects:Array = null;
         var animalObject:Object = null;
         var level:int = 0;
         switch(buildingId)
         {
            case ELITEHORSES_BUILDING:
               craftingSystem = FeatureCraftingManager.instance.getSystem(buildingId);
               npcData = craftingSystem.npcData;
               for each(animalObject in npcData)
               {
                  if(animalObject.hasOwnProperty("complete"))
                  {
                     if(animalObject["complete"] == true)
                     {
                        level++;
                     }
                  }
               }
               break;
            case HARVESTBUILDABLE_BUILDING:
            case BIGBUILDABLE_BUILDING:
               objects = Global.world.getObjectsByName(buildingId);
               if(objects.length == 1)
               {
                  level = (objects[0] as FeatureBuilding).storageLevel - 1;
               }
         }
         return level;
      }
      
      public function get tileConfig() : Array
      {
         return this.m_staticData.tileConfig;
      }
      
      public function get buildingConfig() : Array
      {
         return this.m_staticData.buildingConfig;
      }
      
      public function getcurrencyCount() : Number
      {
         return FeatureOptionsInventoryManager.getInstance().getCount(this.getFeatureCurrencyCode());
      }
      
      public function showFeatureUI() : void
      {
         if(Global.worldManager.isWorldSwapStable)
         {
            if(Global.worldManager.currentWorldType != WORLD_TYPE && Global.worldManager.hasUnlockedWorld(WORLD_TYPE))
            {
               Global.worldManager.swapFarm(WORLD_TYPE,true);
               Global.worldManager.addEventListener(FarmGameWorldEvent.WORLD_LOADED,this.openFeatureWindow);
            }
            else if(Global.worldManager.currentWorldType == WORLD_TYPE)
            {
               this.openFeatureWindow(null);
            }
         }
      }
      
      private function openFeatureWindow(e:Event) : void
      {
         Global.worldManager.removeEventListener(FarmGameWorldEvent.WORLD_LOADED,this.openFeatureWindow);
         if(this.isFeatureCompleted())
         {
            this.setFeatureComplete();
            UI.displayPopup(new OlyInnovationFinalRewardWindow(this.m_assetPaths[this.FINAL_REWARD_KEY],m_featureName));
         }
         else
         {
            this.showUI();
         }
      }
      
      public function showUI() : void
      {
         UI.displayPopup(this.m_olyInnovationWindow = new OlyInnovationWindow(this.m_assetPaths["main"],m_featureName));
      }
      
      public function getTotemNameForTile(tileName:String) : String
      {
         var itemXML:XML = null;
         var totemName:String = "";
         for each(itemXML in featureConfig.items.item)
         {
            if(itemXML.@name.toString() == tileName)
            {
               totemName = itemXML.@unlockItemName.toString();
               break;
            }
         }
         return totemName;
      }
      
      public function showTotemUI(e:TileUnlockEvent) : void
      {
         var building:FeatureBuilding = new FeatureBuilding(this.getTotemNameForTile(e.tileData.getItemName()));
         UI.displayPopup(this.m_olyInnovationAOEWindow = new OlyInnovationAOEWindow(building,this.m_assetPaths["totem"],m_featureName));
         FarmStatsManager.count(m_featureName,"morpheus_statue","olympus_innovation_totem","tile_unlock");
      }
      
      public function getItemsByType(itemType:String) : Array
      {
         var itemXML:XML = null;
         var type:String = null;
         if(!this.m_rewardItemsByType)
         {
            this.m_rewardItemsByType = [];
            for each(itemXML in featureConfig.items.item)
            {
               type = itemXML.@type.toString();
               if(!this.m_rewardItemsByType[type])
               {
                  this.m_rewardItemsByType[type] = [];
               }
               this.m_rewardItemsByType[type].push(itemXML.@name.toString());
            }
         }
         return this.m_rewardItemsByType[itemType];
      }
      
      private function getBuyWindowAssetPath() : String
      {
         return this.m_assetPaths["buyDialog"];
      }
      
      private function getFeatureCurrencyCode() : String
      {
         var name:String = this.m_staticData.currencyItem;
         return Global.farmGameSettingsManager.getFarmItemCodeByName(name);
      }
      
      public function openBuyWindow(owner:FarmWindow) : void
      {
         UI.displayPopup(new FeaturePackagesBuyWindow(this.getBuyWindowAssetPath(),FEATURE_NAME,this.BucketPackageArray,owner),false);
         FarmStatsManager.count(m_featureName,"button_click","buy_gold","click");
      }
      
      public function isFeatureRelatedTotem(totemName:String) : Boolean
      {
         var tileConfig:Object = null;
         var isRelatedTile:Boolean = false;
         for each(tileConfig in this.m_staticData.tileConfig)
         {
            if(tileConfig.totemCode == totemName)
            {
               isRelatedTile = true;
            }
         }
         return isRelatedTile;
      }
      
      private function get BucketPackageArray() : Array
      {
         return this.m_staticData.bucketPackages;
      }
      
      public function initEventListener() : void
      {
         this.setTileHighlightColors();
         GlobalEventManager.getInstance().addEventListener(EVENT_BB_COMPLETE,this.triggerBBCompletePopUp);
         GlobalEventManager.getInstance().addEventListener(EVENT_HB_COMPLETE,this.triggerHBCompletePopUp);
         GlobalEventManager.getInstance().addEventListener(EVENT_TILE_UNLOCK,this.showTotemUI);
      }
      
      public function deleteEventListener() : void
      {
         GlobalEventManager.getInstance().removeEventListener(EVENT_BB_COMPLETE,this.triggerBBCompletePopUp);
         GlobalEventManager.getInstance().removeEventListener(EVENT_HB_COMPLETE,this.triggerHBCompletePopUp);
         GlobalEventManager.getInstance().removeEventListener(EVENT_TILE_UNLOCK,this.showTotemUI);
      }
      
      public function triggerBBCompletePopUp(e:Event = null) : void
      {
         UI.displayPopup(new OlyInnovationProgresswindow(this.m_assetPaths[this.REWARD_KEY],m_featureName,BIGBUILDABLE_BUILDING));
         FarmStatsManager.count(m_featureName,BIGBUILDABLE_BUILDING,"task_completed","milestone");
      }
      
      public function triggerHBCompletePopUp(e:Event = null) : void
      {
         UI.displayPopup(new OlyInnovationProgresswindow(this.m_assetPaths[this.REWARD_KEY],m_featureName,HARVESTBUILDABLE_BUILDING));
         FarmStatsManager.count(m_featureName,HARVESTBUILDABLE_BUILDING,"task_completed","milestone");
      }
      
      public function triggerEHCompletePopUp(e:Event = null) : void
      {
         UI.displayPopup(new OlyInnovationProgresswindow(this.m_assetPaths[this.REWARD_KEY],m_featureName,ELITEHORSES_BUILDING));
         FarmStatsManager.count(m_featureName,ELITEHORSES_BUILDING,"task_completed","milestone");
      }
      
      public function setFeatureComplete() : void
      {
         this.setFeatureOptionData("maptrigger");
         MapTriggerManager.getInstance().createMapTriggers();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,this.CREATE_MAPTRIGGER_SERVICE_CALL,this.onTotemRestored,[m_featureName]));
         var olyInnovationHudIcon:QueuedIcon = Global.hud.rightSideIconQueue.getIconByFeatureName(m_featureName);
         if(olyInnovationHudIcon)
         {
            Global.hud.rightSideIconQueue.removeIcon(olyInnovationHudIcon);
         }
         Global.hud.refreshIconVisibility();
      }
      
      private function setFeatureOptionData(optionName:String) : void
      {
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureData(m_featureName);
         if(!featureData)
         {
            featureData = new Object();
         }
         featureData[optionName] = true;
         FeatureOptionsManager.getInstance().setFeature(m_featureName,featureData);
      }
      
      public function restoreTotem(mapResourceName:String) : void
      {
         FeatureOptionsInventoryManager.getInstance().removeCount(this.getFeatureCurrencyCode(),this.getRestoreCostForTotem(mapResourceName));
         FarmStatsManager.count(m_featureName,mapResourceName,"use_gold" + this.getRestoreCostForTotem(mapResourceName).toString(),"click");
         this.setFeatureOptionData(mapResourceName);
         AOEManager.getInstance().setAOELicenseByResourceName(mapResourceName);
         if(this.isFeatureRelatedTotem(mapResourceName))
         {
            UI.displayPopup(new OlyInnovationProgresswindow(this.m_assetPaths[this.REWARD_KEY],m_featureName,mapResourceName,true));
         }
         else
         {
            UI.displayPopup(new OlyInnovationProgresswindow(this.m_assetPaths[this.REWARD_REGULAR_KEY],m_featureName,mapResourceName,true));
         }
         var aoeConfig:AOEConfig = Global.farmGameSettingsManager.getFarmItemByName(mapResourceName).aoeConfig;
         aoeConfig.highlightColorActive = true;
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,this.RESTORE_TOTEM_SERVICE_CALL,this.onTotemRestored,[m_featureName,mapResourceName]));
         if(this.isFeatureCompleted() && this.isFeatureRelatedTotem(mapResourceName))
         {
            this.setFeatureComplete();
            UI.displayPopup(new OlyInnovationFinalRewardWindow(this.m_assetPaths[this.FINAL_REWARD_KEY],m_featureName));
         }
      }
      
      public function isTaskComplete(taskNum:int) : Boolean
      {
         var taskName:String = this.mapSlotIndexToTaskName(taskNum);
         var completed:Boolean = false;
         if(this.isTotemRestored(taskName) || this.isBuildingComplete(taskName))
         {
            completed = true;
         }
         return completed;
      }
      
      public function getRestoreCostForTotem(totemName:String) : int
      {
         var itemXML:XML = null;
         var unlockItemName:String = null;
         var restoreCost:int = 0;
         for each(itemXML in featureConfig.items.item)
         {
            unlockItemName = itemXML.@unlockItemName.toString();
            if(unlockItemName == totemName)
            {
               restoreCost = parseInt(itemXML.@unlockPrice.toString());
            }
         }
         return restoreCost;
      }
      
      public function mapTaskNameToSlotIndex(taskName:String) : int
      {
         var itemXML:XML = null;
         var unlockItemName:String = null;
         var index:int = 1;
         for each(itemXML in featureConfig.items.item)
         {
            unlockItemName = itemXML.@unlockItemName.toString();
            if(unlockItemName == taskName || itemXML.@type.toString() == "building" && itemXML.@name.toString() == taskName)
            {
               index = parseInt(itemXML.@index.toString());
            }
         }
         return index;
      }
      
      public function mapSlotIndexToTaskName(index:int) : String
      {
         var tileConfig:Object = null;
         var buildingConfig:Object = null;
         var name:String = null;
         for each(tileConfig in this.m_staticData.tileConfig)
         {
            if(tileConfig.index == index)
            {
               return tileConfig.totemCode;
            }
         }
         for each(buildingConfig in this.m_staticData.buildingConfig)
         {
            if(buildingConfig.index == index)
            {
               name = buildingConfig.name;
            }
         }
         return name;
      }
      
      public function onTotemRestored(e:Object) : void
      {
         if(e.error == null)
         {
         }
      }
      
      public function isCommunityGoalsActive() : Boolean
      {
         var task:Object = null;
         var isActive:Boolean = false;
         var activeTask:CommunityGoalsTask = CommunityGoalsManager.getInstance().getActiveTask();
         for each(task in this.m_staticData.cgTasks)
         {
            if(Boolean(activeTask) && task.name == activeTask.name)
            {
               isActive = true;
            }
         }
         return isActive;
      }
      
      public function panToTotem(totemName:String) : void
      {
         var specialTileGameObjects:Array = Global.world.getObjectsByName(totemName);
         if(Boolean(specialTileGameObjects) && specialTileGameObjects.length > 0)
         {
            if(ItemFinderManager.getInstance().highlightWorldItems(totemName).length > 0)
            {
               if(this.m_olyInnovationWindow)
               {
                  this.m_olyInnovationWindow.close();
               }
               ItemFinderManager.getInstance().highlightWorldItems(totemName);
            }
         }
      }
      
      public function isFeatureCompleted() : Boolean
      {
         var building:Object = null;
         var tilesArray:Array = null;
         var tile:Object = null;
         var featureCompleted:Boolean = true;
         var buildingsArray:Array = this.buildingConfig;
         for each(building in buildingsArray)
         {
            if(building["maxLevel"] != this.getCurrentBuildingLevel(building["name"]))
            {
               featureCompleted = false;
            }
         }
         tilesArray = this.tileConfig;
         for each(tile in tilesArray)
         {
            if(this.isTotemRestored(tile["totemCode"]) == false)
            {
               featureCompleted = false;
            }
         }
         return featureCompleted;
      }
      
      public function harvestAllAnimals() : void
      {
         this.m_animalStorageConsumable = Consumable.createConsumable(this.HARVEST_ANIMALS_CONSUMABLE) as CHarvestAnimals;
         if(this.m_animalStorageConsumable.canUse())
         {
            this.m_harvestInProgressFlag = true;
            GlobalEventManager.getInstance().dispatchEvent(new Event(UPDATE_STATE));
            this.m_harvestableAnimals = this.m_animalStorageConsumable.setTargetsBusy();
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,this.HARVEST_ANIMALS_SERVICE_CALL,this.onHarvestAllAnimalsSuccess,[m_featureName]),true);
            FarmStatsManager.count("olympus_innovation","heromenes","harvest_all","click");
         }
         else
         {
            UI.displayMessage(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + this.TEXT_HEROMENES_NOANIMALS),GenericPopup.TYPE_OK);
         }
      }
      
      private function onHarvestAllAnimalsSuccess(e:Object) : void
      {
         var key:String = null;
         var target:SimpleHarvestableResource = null;
         if(e.error == null)
         {
            if(this.m_harvestableAnimals != null)
            {
               for each(target in this.m_harvestableAnimals)
               {
                  target.isBusy = false;
               }
            }
            this.m_animalStorageConsumable.onUse();
            key = m_featureName + this.MAPTRIGGER_LAST_USE_TIME_KEY;
            Global.player.setFeatureLastShown(key,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         }
         this.m_harvestInProgressFlag = false;
      }
      
      public function isMapTriggeractive() : Boolean
      {
         var throttleTime:int = 0;
         var key:String = null;
         var mapTriggerActive:Boolean = false;
         if(this.m_harvestInProgressFlag == false)
         {
            throttleTime = this.DEFAULT_THROTTLE_TIME;
            key = m_featureName + this.MAPTRIGGER_LAST_USE_TIME_KEY;
            if(this.getTimeLeft(key,throttleTime) < 0)
            {
               mapTriggerActive = true;
            }
         }
         return mapTriggerActive;
      }
      
      public function getAllRegionNames() : Array
      {
         var regionXML:XML = null;
         var name:String = null;
         var regionArray:Array = new Array();
         for each(regionXML in featureConfig.regions.region)
         {
            name = regionXML.@name.toString();
            regionArray.push(name);
         }
         return regionArray;
      }
      
      public function getRegionNameForTotem(totemName:String) : String
      {
         var itemXML:XML = null;
         var unlockItemName:String = null;
         var regionName:String = "";
         for each(itemXML in featureConfig.items.item)
         {
            unlockItemName = itemXML.@unlockItemName.toString();
            if(unlockItemName == totemName)
            {
               regionName = itemXML.@region.toString();
            }
         }
         return regionName;
      }
      
      public function getTimeLeftForNextHavest() : String
      {
         var throttleTime:int = this.DEFAULT_THROTTLE_TIME;
         var key:String = m_featureName + this.MAPTRIGGER_LAST_USE_TIME_KEY;
         return HUD.getformattedTimeLeft(this.getTimeLeft(key,throttleTime));
      }
      
      public function getTimeLeft(key:String, throttleTime:int) : int
      {
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         return int(throttleTime - timeSinceLastFeed);
      }
      
      public function getHighlightColorForType(type:String) : uint
      {
         var regionXML:XML = null;
         var name:String = null;
         var highlightColor:uint = Constants.COLOR_HIGHLIGHT_BLUE;
         for each(regionXML in featureConfig.regions.region)
         {
            name = regionXML.@name.toString();
            if(name.toLowerCase() == type.toLowerCase())
            {
               highlightColor = uint(regionXML.@highlightColor.toString());
            }
         }
         return highlightColor;
      }
      
      public function highlightItemsOfType(type:String) : Boolean
      {
         var itemsArray:Array = OlyInnovationManager.getInstance().getItemsByType(type);
         var highlighted:Boolean = false;
         var color:uint = this.getHighlightColorForType(type);
         if(itemsArray)
         {
            if(ItemFinderManager.getInstance().highlightMultipleWorldItems(itemsArray,true,color).length > 0)
            {
               highlighted = true;
            }
         }
         return highlighted;
      }
      
      public function highlightItemsByName(itemName:String) : Boolean
      {
         var highlighted:Boolean = false;
         var itemsArray:Array = new Array(itemName);
         if(ItemFinderManager.getInstance().highlightMultipleWorldItems(itemsArray).length > 0)
         {
            highlighted = true;
         }
         return highlighted;
      }
   }
}

