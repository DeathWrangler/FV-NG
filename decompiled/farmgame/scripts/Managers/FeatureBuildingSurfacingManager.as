package Managers
{
   import Classes.ConstructionBuilding;
   import Classes.FeatureBuilding;
   import Classes.HarvestableStorageBuilding;
   import Classes.MapResource;
   import Classes.OrchardFeatureBuilding;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.StorageBuilding;
   import Classes.Tree;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Engine.Constants;
   import flash.utils.getDefinitionByName;
   
   public class FeatureBuildingSurfacingManager
   {
      
      public static const BUILDING_SURFACE_KEY:String = "surface";
      
      public static const PEN_SURFACE_KEY:String = "pen_surface";
      
      public static const TREE_SURFACING_KEYWORD:String = "tree";
      
      public static const MASTERYBILLBOARD_SURFACING_KEYWORD:String = "masterybillboard";
      
      public static const GNOME_SURFACING_KEYWORD:String = "gnome";
      
      public static const ANIMAL_SURFACING_KEYWORD:String = "animal";
      
      private static const FINISHED_BUILDING_POSTFIX:String = "_finished";
      
      private static const COOLDOWN_DAYS_FIRST:int = 2;
      
      private static const COOLDOWN_DAYS_SECOND:int = 7;
      
      private static const COOLDOWN_KILL:int = -1;
      
      private static var m_instance:FeatureBuildingSurfacingManager = null;
      
      private static var m_initialized:Boolean = false;
      
      private var m_cachedBuildings:Array;
      
      public function FeatureBuildingSurfacingManager()
      {
         super();
         if(!m_initialized)
         {
            m_initialized = true;
            return;
         }
         throw new Error("Error: Instantiation failed: Use FeatureBuildingSurfacingManager.getInstance() instead of new.");
      }
      
      public static function getInstance() : FeatureBuildingSurfacingManager
      {
         if(m_instance == null)
         {
            m_instance = new FeatureBuildingSurfacingManager();
         }
         return m_instance;
      }
      
      public static function canAddToBuilding(building:FeatureBuilding, item:MapResource) : Boolean
      {
         var result:Boolean = false;
         if(building.storage != null)
         {
            result = Global.storageSettings.storageCanTake(building.storage.getStorageItemClass(),item);
            result &&= building.count < building.capacity;
            if(item is FeatureBuilding)
            {
               result &&= !(item as FeatureBuilding).isWithered();
            }
         }
         return result;
      }
      
      public static function surfaceFeatureBuilding(buildingItem:FarmItem, showMarketIfNotGift:Boolean = false) : void
      {
         var buildingName:String = null;
         var fromMarket:Boolean = false;
         if(buildingItem)
         {
            buildingName = buildingItem.name;
            if(buildingName)
            {
               fromMarket = Global.player.getGiftCountForItem(buildingName) <= 0;
               if(fromMarket && showMarketIfNotGift)
               {
                  UI.displayMiniMarketDialog([buildingName]);
                  FarmStatsManager.count("SurfaceFeatureBuilding","showMarket",buildingName);
               }
               else
               {
                  Global.world.enterForcePlaceMode(buildingName,fromMarket,0,true,!fromMarket);
                  FarmStatsManager.count("SurfaceFeatureBuilding","enterForcePlaceMode",buildingName);
               }
            }
         }
      }
      
      public function highlightBuildings(item:MapResource, highlight:Boolean = true) : void
      {
         var i:* = 0;
         var len:int = 0;
         if(this.m_cachedBuildings == null)
         {
            this.m_cachedBuildings = this.searchForBuildingsInWorld(item);
         }
         if(this.m_cachedBuildings)
         {
            len = this.m_cachedBuildings.length - 1;
            for(i = len; i >= 0; i--)
            {
               (this.m_cachedBuildings[i] as FeatureBuilding).showHighlight(highlight,Constants.COLOR_HIGHLIGHT_BLUE);
            }
         }
         if(highlight == false)
         {
            this.m_cachedBuildings = null;
         }
      }
      
      protected function searchForBuildingsInWorld(item:MapResource) : Array
      {
         var i:* = 0;
         var featureBuildingClass:Class = getDefinitionByName("Classes.FeatureBuilding") as Class;
         var buildings:Array = Global.world.getObjectsByClass(featureBuildingClass);
         var acceptableBuildings:Array = new Array();
         var len:int = buildings.length - 1;
         for(i = len; i >= 0; i--)
         {
            if(canAddToBuilding(buildings[i],item))
            {
               acceptableBuildings.push(buildings[i]);
            }
         }
         return acceptableBuildings;
      }
      
      public function searchForConstructionBuildingsInWorld(item:MapResource) : Array
      {
         var finishedItem:FarmItem = null;
         var storageName:String = null;
         var buildingConstructionClass:Class = getDefinitionByName("Classes.ConstructionBuilding") as Class;
         var buildingsInWorld:Array = Global.world.getObjectsByClass(buildingConstructionClass);
         var validConstructionBuildings:Array = new Array();
         var i:* = 0;
         var len:int = buildingsInWorld.length - 1;
         for(i = len; i >= 0; i--)
         {
            finishedItem = (buildingsInWorld[i] as ConstructionBuilding).getFinishedItem();
            if(finishedItem != null)
            {
               storageName = finishedItem.storageClass;
               if(Global.storageSettings.storageCanTake(storageName,item))
               {
                  validConstructionBuildings.push(buildingsInWorld[i]);
               }
            }
         }
         return validConstructionBuildings;
      }
      
      public function searchForStorageBuildingsInWorld(item:MapResource, excludeFull:Boolean = false, excludeFrames:Boolean = false) : Array
      {
         var i:* = 0;
         var len:int = 0;
         var buildingItem:FarmItem = null;
         var building:HarvestableStorageBuilding = null;
         var storageName:String = null;
         var featureBuildingClass:Class = null;
         var acceptableStorages:Array = new Array();
         if(item is Tree && !PrerequisiteUtility.checkPrereqByName(OrchardFeatureBuilding.ORCHARD_FEATUREBUILDING_ENABLED_PREREQ))
         {
            featureBuildingClass = getDefinitionByName("Classes.OrchardBuilding") as Class;
         }
         else
         {
            featureBuildingClass = getDefinitionByName("Classes.FeatureBuilding") as Class;
         }
         var buildings:Array = Global.world.getObjectsByClass(featureBuildingClass);
         if(buildings)
         {
            i = 0;
            len = buildings.length - 1;
            for(i = len; i >= 0; i--)
            {
               building = buildings[i] as HarvestableStorageBuilding;
               buildingItem = building.getItem();
               if(buildingItem != null)
               {
                  storageName = buildingItem.storageClass;
                  if(Global.storageSettings.storageCanTake(storageName,item))
                  {
                     if((!excludeFrames || building.capacity == 0) && (!excludeFull || !building.isFull()))
                     {
                        acceptableStorages.push(buildings[i]);
                     }
                  }
               }
            }
         }
         return acceptableStorages;
      }
      
      protected function getPossibleBuildingForItem(item:MapResource, keyword:String) : String
      {
         var bldgStorageNames:Array = Global.farmGameSettingsManager.getSurfacingStorageBuildingSet(keyword);
         return this.getPossibleBuildingForItemFromNames(item,bldgStorageNames);
      }
      
      public function getPossibleBuildingForItemFromNames(item:MapResource, names:Array) : String
      {
         var bldgItem:FarmItem = null;
         var bldgName:String = null;
         var result:String = null;
         for each(bldgName in names)
         {
            bldgItem = Global.farmGameSettingsManager.getFarmItemByName(bldgName);
            if(bldgItem != null && bldgItem.isInExperiment && bldgItem.meetsWorldRestrictions())
            {
               if(Global.storageSettings.storageCanTake(bldgItem.storageClass,item))
               {
                  result = bldgName;
                  break;
               }
            }
         }
         return result;
      }
      
      public function sortMapResourcesByFeatureBuildingRank(items:Array, keyword:String) : void
      {
         var bldgRanks:Object = null;
         var item:MapResource = null;
         var itemName:String = null;
         var bldgRank:int = 0;
         var bldgName:String = null;
         var bldgStorageNames:Array = Global.farmGameSettingsManager.getSurfacingStorageBuildingSet(keyword);
         bldgRanks = {};
         for each(item in items)
         {
            itemName = item.getItem().name;
            if(bldgRanks[itemName] == null)
            {
               bldgName = this.getPossibleBuildingForItemFromNames(item,bldgStorageNames);
               if(bldgName != null)
               {
                  bldgRank = bldgStorageNames.indexOf(bldgName);
               }
               else
               {
                  bldgRank = int.MAX_VALUE;
               }
               bldgRanks[itemName] = bldgRank;
            }
         }
         items.sort(function(a:MapResource, b:MapResource):int
         {
            return bldgRanks[a.getItem().name] - bldgRanks[b.getItem().name];
         });
      }
      
      public function conditionallyGetBuildingToSurface(item:MapResource, keyword:String, ignoreExistingFull:Boolean = false, ignoreExistingFrames:Boolean = false) : FarmItem
      {
         var buildings:Array = null;
         var buildingName:String = null;
         var building:FarmItem = null;
         var buildingFrameName:String = null;
         var itemLimit:Boolean = false;
         var buildingFrame:FarmItem = null;
         var worldNameKey:String = null;
         var result:FarmItem = null;
         if(item != null)
         {
            if(!Global.worldManager.isVisiting())
            {
               buildings = this.searchForStorageBuildingsInWorld(item,ignoreExistingFull,ignoreExistingFrames);
               buildings = buildings.concat(this.searchForConstructionBuildingsInWorld(item));
               if(buildings.length == 0)
               {
                  buildingName = this.getPossibleBuildingForItem(item,keyword);
                  if(buildingName != null)
                  {
                     building = Global.farmGameSettingsManager.getFarmItemByName(buildingName);
                     if(building != null)
                     {
                        buildingFrameName = this.getBuildingFrameName(building.name);
                        itemLimit = false;
                        buildingFrame = Global.farmGameSettingsManager.getFarmItemByName(buildingFrameName);
                        if(buildingFrame != null)
                        {
                           if(Global.world.getObjectsByName(buildingFrameName).length >= buildingFrame.limit)
                           {
                              itemLimit = true;
                           }
                        }
                        worldNameKey = this.getWorldNameKey(building.name,keyword);
                        if(this.canSurfaceForWorldNameKey(worldNameKey) && !itemLimit)
                        {
                           result = building;
                           this.initializeSurfacingThrottle(worldNameKey);
                           FarmStatsManager.count("SurfaceFeatureBuilding","show",buildingFrameName,item.getItem().name);
                        }
                     }
                  }
               }
            }
         }
         return result;
      }
      
      public function canSurfaceForWorldNameKey(worldNameKey:String) : Boolean
      {
         return Global.player.getSeenSessionFlag(worldNameKey) == false && !this.shouldThrottleSurfacing(worldNameKey);
      }
      
      public function initializeSurfacingThrottle(worldNameKey:String) : void
      {
         Global.player.setFeatureLastShown(worldNameKey,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
         Global.player.setSeenSessionFlag(worldNameKey);
      }
      
      public function surfaceFeatureBuildingFrame(buildingItem:FarmItem) : void
      {
         var constructionBuildingName:String = null;
         var fromMarket:Boolean = false;
         if(buildingItem != null)
         {
            constructionBuildingName = this.getBuildingFrameName(buildingItem.name);
            fromMarket = Global.player.getGiftCountForItem(constructionBuildingName) <= 0;
            Global.world.enterForcePlaceMode(constructionBuildingName,fromMarket,0,true,!fromMarket);
            FarmStatsManager.count("SurfaceFeatureBuilding","enterForcePlaceMode",constructionBuildingName);
         }
      }
      
      public function surfaceFeatureBuildingCancel(buildingItem:FarmItem) : void
      {
         var worldNameKey:String = null;
         var constructionBuildingName:String = null;
         if(buildingItem != null)
         {
            worldNameKey = this.getWorldNameKey(buildingItem.name);
            Global.player.incrementActionCount(worldNameKey,true);
            constructionBuildingName = this.getBuildingFrameName(buildingItem.name);
            FarmStatsManager.count("SurfaceFeatureBuilding","cancelled",constructionBuildingName);
         }
      }
      
      private function getBuildingFrameName(buildingName:String) : String
      {
         return buildingName.substring(0,buildingName.lastIndexOf(FINISHED_BUILDING_POSTFIX));
      }
      
      public function getWorldNameKey(buildingName:String, keyword:String = null) : String
      {
         var prefix:String = null;
         if(keyword == ANIMAL_SURFACING_KEYWORD)
         {
            prefix = PEN_SURFACE_KEY;
         }
         else
         {
            prefix = this.getBuildingFrameName(buildingName) + "_" + BUILDING_SURFACE_KEY;
         }
         return prefix + Global.worldManager.currentWorldType;
      }
      
      private function shouldThrottleSurfacing(worldNameKey:String) : Boolean
      {
         var shouldThrottle:Boolean = false;
         var closeCount:int = Global.player.getActionCount(worldNameKey);
         var cooldownTime:Number = this.getCooldownTimeFromCloseCount(closeCount);
         var lastShown:Number = Global.player.getFeatureLastShown(worldNameKey);
         if(lastShown != 0 && (cooldownTime == COOLDOWN_KILL || GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - lastShown < cooldownTime))
         {
            shouldThrottle = true;
         }
         return shouldThrottle;
      }
      
      private function getCooldownTimeFromCloseCount(closeCount:int) : Number
      {
         var cooldown:Number = 0;
         switch(closeCount)
         {
            case 0:
               break;
            case 1:
               cooldown = COOLDOWN_DAYS_FIRST * FarmGameUtil.NUM_SECS_IN_DAY;
               break;
            case 2:
               cooldown = COOLDOWN_DAYS_SECOND * FarmGameUtil.NUM_SECS_IN_DAY;
               break;
            case 3:
            default:
               cooldown = COOLDOWN_KILL;
         }
         return cooldown;
      }
      
      public function getBuildingsByName(building:BuildingItem, excludeFull:Boolean = false) : Array
      {
         var len:int = 0;
         var worldBuilding:StorageBuilding = null;
         var result:Array = [];
         var featureBuildingClass:Class = getDefinitionByName("Classes." + building.className) as Class;
         var featureBuildingsInWorld:Array = Global.world.getObjectsByClass(featureBuildingClass);
         len = featureBuildingsInWorld.length - 1;
         for(var featureBuildingsIndex:* = len; featureBuildingsIndex >= 0; featureBuildingsIndex--)
         {
            worldBuilding = featureBuildingsInWorld[featureBuildingsIndex] as StorageBuilding;
            if(worldBuilding != null && building.name == worldBuilding.getItemName())
            {
               if(!excludeFull || !worldBuilding.isFull())
               {
                  result.push(worldBuilding);
               }
            }
         }
         return result;
      }
      
      public function getConstructionsBuildingsByName(building:BuildingItem) : Array
      {
         var featureBuildingClass:Class = null;
         var featureBuildingsInWorld:Array = null;
         var len:int = 0;
         var featureBuildingsIndex:* = 0;
         var worldBuilding:StorageBuilding = null;
         var result:Array = [];
         var constructionBuildingName:String = this.getBuildingFrameName(building.name);
         var constructionItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(constructionBuildingName);
         if(constructionItem != null)
         {
            featureBuildingClass = getDefinitionByName("Classes." + constructionItem.className) as Class;
            featureBuildingsInWorld = Global.world.getObjectsByClass(featureBuildingClass);
            len = featureBuildingsInWorld.length - 1;
            for(featureBuildingsIndex = len; featureBuildingsIndex >= 0; featureBuildingsIndex--)
            {
               worldBuilding = featureBuildingsInWorld[featureBuildingsIndex] as StorageBuilding;
               if(worldBuilding != null && constructionBuildingName == worldBuilding.getItemName())
               {
                  if(worldBuilding.getItemName().indexOf(FINISHED_BUILDING_POSTFIX) == -1 || worldBuilding.capacity == 0)
                  {
                     result.push(worldBuilding);
                  }
               }
            }
         }
         return result;
      }
      
      public function canPlaceBuilding(building:BuildingItem) : Boolean
      {
         return !building.checkItemLimit() && building.checkMarketPrereqs() && building.checkPurchasePrereqs() && building.checkExperimentGate() && building.checkDateGate() && building.buyable;
      }
   }
}

