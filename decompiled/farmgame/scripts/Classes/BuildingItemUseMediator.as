package Classes
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import GameMode.GMBuildingPart;
   import GameMode.GMConstructBuilding;
   import GameMode.GMCreditsBuildingItemPlace;
   import Managers.FarmStatsManager;
   import Managers.FeatureBuildingSurfacingManager;
   import Transactions.TBuyItemPutGiftbox;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.BuildingSurfaceWindow;
   import Widgets.Windows.ConstructionBuilding.ConstructionSelectWindow;
   import flash.utils.getDefinitionByName;
   
   public class BuildingItemUseMediator
   {
      
      private static var m_instance:BuildingItemUseMediator = null;
      
      private static var m_initialized:Boolean = false;
      
      protected var m_buildingPart:BuildingPart = null;
      
      protected var m_building:StorageBuilding = null;
      
      protected var m_isGift:Boolean = false;
      
      protected var m_suppressGiftRepop:Boolean = false;
      
      protected var m_hasABuilding:Boolean = false;
      
      protected var m_numParts:int = 1;
      
      public function BuildingItemUseMediator()
      {
         super();
         if(!m_initialized)
         {
            m_initialized = true;
            return;
         }
         throw new Error("Error: Instantiation failed: Use BuildingItemUseMediator.getInstance() instead of new.");
      }
      
      public static function getInstance() : BuildingItemUseMediator
      {
         if(m_instance == null)
         {
            m_instance = new BuildingItemUseMediator();
         }
         return m_instance;
      }
      
      public static function canAddToBuilding(building:StorageBuilding, buildingPart:LootableDecoration) : Boolean
      {
         var expansionExperiment:String = null;
         var result:Boolean = false;
         var itemCode:String = buildingPart.getItem().code;
         if(buildingPart is BuildingPart)
         {
            if(building.isFullyBuilt())
            {
               if(building is RewardCreditsBuilding && (Boolean(buildingPart.getItem().basket) && Boolean(buildingPart.getItem().basket == building.getItem().name) || Boolean(buildingPart.getItem().basketClass) && Boolean(buildingPart.getItem().basketClass == building.getItem().className)))
               {
                  result = true;
               }
               else
               {
                  result = building.isValidExpansionPart(buildingPart) && building.getExpansionPartCount(itemCode) < building.getExpansionPartLimit(itemCode) && !building.isNextStageRegionLocked() || building.isValidContaineePart(buildingPart) && building.count > 0;
               }
            }
            else
            {
               result = building.canTakeItem(buildingPart);
            }
            expansionExperiment = building.expansionExperiment;
            if(expansionExperiment != "" && Global.experimentManager.getExperimentVariant(expansionExperiment) <= 0)
            {
               result = false;
            }
         }
         return result;
      }
      
      public static function displayFeedbackPopup(hasABuilding:Boolean, overrideSuffix:String = null) : void
      {
         var locString:String = null;
         var popupMessage:String = "";
         if(hasABuilding)
         {
            popupMessage = ZLocUtils.t("Dialogs","ConstructionBuilding_IsFullyBuilt");
            if(overrideSuffix != null)
            {
               locString = "ConstructionBuilding_IsFullyBuilt_" + overrideSuffix;
               if(ZLocUtils.hasString("Dialogs",locString))
               {
                  popupMessage = ZLocUtils.t("Dialogs",locString);
               }
            }
            UI.displayPopup(new GenericPopup(popupMessage,GenericPopup.TYPE_ACCEPTCANCEL,alreadyCompleteCallback));
         }
         else
         {
            popupMessage = ZLocUtils.t("Dialogs","ConstructionBuilding_DontHave");
            if(overrideSuffix != null)
            {
               locString = "ConstructionBuilding_DontHave_" + overrideSuffix;
               if(ZLocUtils.hasString("Dialogs",locString))
               {
                  popupMessage = ZLocUtils.t("Dialogs",locString);
               }
            }
            UI.displayPopup(new GenericPopup(popupMessage,GenericPopup.TYPE_OK,noBuildingCallback));
         }
      }
      
      private static function noBuildingCallback(event:GenericPopupEvent) : void
      {
         var partName:String = BuildingItemUseMediator.getInstance().m_buildingPart.getItem().name;
         if(event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count("farmville_sell_gift_screen","regift_prompt_accept",partName,"noBuildingCallback","BuildingItemUseMediator");
            UI.displayGiftBoxWindow(true);
         }
         else
         {
            FarmStatsManager.count("farmville_sell_gift_screen","regift_prompt_cancel",partName,"noBuildingCallback","BuildingItemUseMediator");
         }
      }
      
      private static function alreadyCompleteCallback(event:GenericPopupEvent) : void
      {
         var partName:String = BuildingItemUseMediator.getInstance().m_buildingPart.getItem().name;
         if(event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count("farmville_sell_gift_screen","regift_prompt_accept",partName,"alreadyCompleteCallback","BuildingItemUseMediator");
            UI.displayGiftBoxWindow(true);
         }
         else
         {
            FarmStatsManager.count("farmville_sell_gift_screen","regift_prompt_cancel",partName,"alreadyCompleteCallback","BuildingItemUseMediator");
         }
      }
      
      private function isOnPlacementPromptExperiement() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_GIFTBOX_PLACEMENT) == 2;
      }
      
      public function mediate(name:String, isGift:Boolean = false, forceBuilding:StorageBuilding = null, suppressGiftRepop:Boolean = false, centerOnBuilding:Boolean = true, numParts:int = 1, combineTransactions:Boolean = true) : void
      {
         var acceptableBuildings:Array = null;
         var buildings:Array = null;
         var buildingData:Array = null;
         var possibleBuilding:Array = null;
         var building:FarmItem = null;
         var item:BuildingPart = null;
         var itemNameToGift:String = null;
         var finishedIndex:int = 0;
         var build:FarmItem = null;
         this.m_buildingPart = new BuildingPart(name);
         this.m_isGift = isGift;
         this.m_suppressGiftRepop = suppressGiftRepop;
         this.m_numParts = numParts;
         if(forceBuilding != null)
         {
            this.enterGameMode(forceBuilding,this.m_buildingPart,centerOnBuilding,combineTransactions);
         }
         else
         {
            acceptableBuildings = this.searchForBuildings();
            if(this.m_isGift)
            {
               if(acceptableBuildings.length > 0)
               {
                  buildings = new Array();
                  for each(buildingData in acceptableBuildings)
                  {
                     buildings.push(buildingData["building"]);
                  }
                  Global.world.addGameMode(new GMBuildingPart(this.m_buildingPart,buildings,isGift,this.m_suppressGiftRepop));
               }
               else if(this.isOnPlacementPromptExperiement())
               {
                  possibleBuilding = this.getPossibleFeatureBuildingsForPart(this.m_buildingPart,true);
                  if(possibleBuilding.length > 0)
                  {
                     building = possibleBuilding[0];
                     item = new BuildingPart(name);
                     FarmStatsManager.count("Gbplacement","View",name);
                     itemNameToGift = null;
                     finishedIndex = building.name.lastIndexOf("_finished");
                     if(finishedIndex == -1)
                     {
                        for each(build in possibleBuilding)
                        {
                           if(build.marketIsCoin && build.coins == 0)
                           {
                              itemNameToGift = build.name;
                              break;
                           }
                        }
                     }
                     else
                     {
                        itemNameToGift = building.name.substring(0,finishedIndex);
                     }
                     UI.displayPopup(new BuildingSurfaceWindow(building,item,true,null,itemNameToGift,null,true));
                  }
                  else
                  {
                     displayFeedbackPopup(this.m_hasABuilding,name);
                  }
               }
               else
               {
                  displayFeedbackPopup(this.m_hasABuilding,name);
               }
            }
            else if(acceptableBuildings.length > 1)
            {
               this.displayChoicePopup(acceptableBuildings);
            }
            else if(acceptableBuildings.length == 1)
            {
               this.enterGameMode(acceptableBuildings[0].building,this.m_buildingPart);
            }
            else if(this.m_hasABuilding && this.m_buildingPart.getItem().className == DoghouseTreat.CLASS_NAME)
            {
               TransactionManager.addTransaction(new TBuyItemPutGiftbox(this.m_buildingPart.getItem(),Currency.CASH,numParts,false),true);
            }
            else
            {
               displayFeedbackPopup(this.m_hasABuilding);
            }
         }
      }
      
      private function enterGameMode(storageBuilding:StorageBuilding, buildingPart:BuildingPart, centerOnBuilding:Boolean = true, combineTransactions:Boolean = true) : void
      {
         var repopGift:Boolean = this.m_isGift;
         if(this.m_suppressGiftRepop)
         {
            repopGift = !this.m_suppressGiftRepop;
         }
         if(storageBuilding is RewardCreditsBuilding)
         {
            Global.world.addGameMode(new GMCreditsBuildingItemPlace(buildingPart.itemName,this.m_isGift,repopGift,centerOnBuilding,1,storageBuilding.getItem().name),false);
         }
         else if(storageBuilding is MysterySeedling)
         {
            Global.world.addGameMode(new GMConstructBuilding(buildingPart.itemName,storageBuilding,this.m_isGift,true,repopGift,this.m_numParts,centerOnBuilding),false);
            repopGift = false;
         }
         else
         {
            Global.world.addGameMode(new GMConstructBuilding(buildingPart.itemName,storageBuilding,this.m_isGift,true,repopGift,this.m_numParts,centerOnBuilding,true,combineTransactions),false);
         }
         if(repopGift)
         {
            UI.displayGiftBoxWindow();
         }
         this.m_isGift = false;
         this.m_buildingPart = null;
         this.m_building = null;
         this.m_hasABuilding = false;
      }
      
      protected function searchForBuildings() : Array
      {
         var buildingType:String = null;
         var buildingClass:Class = null;
         var buildings:Array = null;
         var building:StorageBuilding = null;
         var addBuilding:Boolean = false;
         var chosenBuilding:Array = null;
         var buildingData:Array = null;
         var possibleBuildingTypes:Array = this.m_buildingPart.buildingTypes;
         var acceptableBuildings:Array = new Array();
         var targetBuilding:StorageBuilding = null;
         for each(buildingType in possibleBuildingTypes)
         {
            buildingClass = getDefinitionByName("Classes." + buildingType) as Class;
            buildings = Global.world.getObjectsByClass(buildingClass);
            if(!this.m_hasABuilding && buildings.length > 0)
            {
               this.m_hasABuilding = true;
            }
            for each(building in buildings)
            {
               if(canAddToBuilding(building,this.m_buildingPart))
               {
                  addBuilding = true;
                  for each(chosenBuilding in acceptableBuildings)
                  {
                     if(chosenBuilding["building"] == building)
                     {
                        addBuilding = false;
                        break;
                     }
                  }
                  if(addBuilding)
                  {
                     targetBuilding = building;
                     buildingData = new Array();
                     buildingData["building"] = building;
                     buildingData["part"] = this.m_buildingPart;
                     acceptableBuildings.push(buildingData);
                  }
               }
            }
         }
         return acceptableBuildings;
      }
      
      private function displayChoicePopup(buildingChoices:Array) : void
      {
         UI.displayPopup(new ConstructionSelectWindow(buildingChoices,this.m_buildingPart.getItem(),this.enterGameMode));
      }
      
      protected function getPossibleFeatureBuildingsForPart(part:BuildingPart, includeOrchards:Boolean = false) : Array
      {
         var index:* = 0;
         var building:BuildingItem = null;
         var parts:Array = null;
         var partLength:int = 0;
         var partIndex:int = 0;
         var orchardBuilding:BuildingItem = null;
         var featureBuildingsIndex:int = 0;
         var removeBuilding:Boolean = false;
         var worlds:Array = null;
         var featureBuildingsInWorld:Array = null;
         var possibleBuildings:Array = new Array();
         var featureBuildings:Array = Global.farmGameSettingsManager.getItemsByClassArray("FeatureBuilding");
         var orchardBuildings:Array = Global.farmGameSettingsManager.getItemsByClassArray("OrchardConstructionBuilding");
         var len:int = featureBuildings.length - 1;
         var featureBuildingManager:FeatureBuildingSurfacingManager = FeatureBuildingSurfacingManager.getInstance();
         for(index = len; index >= 0; index--)
         {
            building = featureBuildings[index];
            if(building.storageClass != null && building.storageClass != "")
            {
               parts = Global.storageSettings.getConstructionParts(building.storageClass);
               partLength = int(parts.length);
               for(partIndex = 0; partIndex < partLength; partIndex++)
               {
                  if(parts[partIndex].item.name == part.itemName)
                  {
                     possibleBuildings.push(building);
                  }
               }
            }
         }
         if(includeOrchards)
         {
            len = orchardBuildings.length - 1;
            for(index = len; index >= 0; index--)
            {
               building = orchardBuildings[index];
               if(building.storageClass != null && building.storageClass != "")
               {
                  parts = Global.storageSettings.getConstructionParts(building.storageClass);
                  partLength = int(parts.length);
                  for(partIndex = 0; partIndex < partLength; partIndex++)
                  {
                     if(parts[partIndex].item.name == part.itemName)
                     {
                        orchardBuilding = Global.farmGameSettingsManager.getFarmItemByName(building.name + "_finished") as BuildingItem;
                        if(orchardBuilding != null)
                        {
                           possibleBuildings.push(orchardBuilding);
                        }
                     }
                  }
               }
            }
         }
         len = possibleBuildings.length - 1;
         for(index = len; index >= 0; index--)
         {
            building = possibleBuildings[index];
            removeBuilding = false;
            removeBuilding = !featureBuildingManager.canPlaceBuilding(building);
            if(!removeBuilding)
            {
               removeBuilding = building.isFullyUpgraded();
            }
            if(!removeBuilding)
            {
               worlds = building.worldRestrictions;
               if(worlds.length > 0 && worlds.indexOf(Global.worldManager.currentWorldType) == -1)
               {
                  removeBuilding = true;
               }
            }
            if(!removeBuilding)
            {
               featureBuildingsInWorld = featureBuildingManager.getConstructionsBuildingsByName(building);
               if(featureBuildingsInWorld.length > 0)
               {
                  removeBuilding = true;
               }
            }
            if(removeBuilding)
            {
               possibleBuildings.splice(index,1);
            }
         }
         return this.sortBuildingsByWorld(possibleBuildings);
      }
      
      private function getBuildingFrameName(buildingName:String) : String
      {
         return buildingName.substring(0,buildingName.lastIndexOf("_finished"));
      }
      
      private function sortBuildingsByWorld(buildings:Array) : Array
      {
         var worldKey:String = null;
         var building:BuildingItem = null;
         var added:Boolean = false;
         var prefixIndex:int = 0;
         var prefixKey:Object = null;
         var buildingsByWorld:Object = {};
         var firstWorld:String = Global.worldManager.currentWorldType;
         var result:Array = [];
         for(var index:int = 0; index < buildings.length; index++)
         {
            building = buildings[index];
            added = false;
            for(prefixIndex = 0; prefixIndex < WorldsConstants.ALL_WORLD_PREFIXES.length; prefixIndex++)
            {
               prefixKey = WorldsConstants.ALL_WORLD_PREFIXES[prefixIndex];
               if(building.name.indexOf(prefixKey.prefix) != -1)
               {
                  if(!buildingsByWorld.hasOwnProperty(prefixKey.world))
                  {
                     buildingsByWorld[prefixKey.world] = new Array();
                  }
                  buildingsByWorld[prefixKey.world].push(building);
                  added = true;
               }
            }
            if(!added)
            {
               if(!buildingsByWorld.hasOwnProperty(WorldsConstants.WORLD_ID_HOME))
               {
                  buildingsByWorld[WorldsConstants.WORLD_ID_HOME] = new Array();
               }
               buildingsByWorld[WorldsConstants.WORLD_ID_HOME].push(building);
            }
         }
         if(firstWorld != WorldsConstants.WORLD_ID_HOME || firstWorld != WorldsConstants.WORLD_ID_FISHERMAN)
         {
            if(buildingsByWorld.hasOwnProperty(firstWorld))
            {
               result = buildingsByWorld[firstWorld];
            }
         }
         if(buildingsByWorld.hasOwnProperty(WorldsConstants.WORLD_ID_HOME))
         {
            result = result.concat(buildingsByWorld[WorldsConstants.WORLD_ID_HOME]);
         }
         for(worldKey in WorldsConstants.ALL_WORLDS)
         {
            if(worldKey != firstWorld && worldKey != WorldsConstants.WORLD_ID_HOME)
            {
               if(buildingsByWorld.hasOwnProperty(worldKey))
               {
                  result = result.concat(buildingsByWorld[worldKey]);
               }
            }
         }
         return result;
      }
   }
}

