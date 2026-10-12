package Managers
{
   import Classes.ConstructionBuilding;
   import Classes.FeatureBuilding;
   import Classes.FeatureComponents.IExpandComponent;
   import Classes.OrchardBuilding;
   import Classes.StorageBuilding;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.UI;
   import Widgets.Windows.MOTD.FinishAllBuildingsMOTDWindow;
   import flash.utils.getDefinitionByName;
   
   public class FinishAllBuildingsUtil
   {
      
      public static const ICON_NAME:String = "finishAllBuildings";
      
      public static const DEFAULT_DURATION:int = 2;
      
      private static const DEFAULT_FREQ_FLAG:String = "MOTD_FINISH_ALL_BUILDINGS_06_22_2012";
      
      public function FinishAllBuildingsUtil()
      {
         super();
      }
      
      public static function getSaleItems() : Array
      {
         var buildingsInWorld:Array = null;
         var itemName:String = null;
         var idx:int = 0;
         var building:ConstructionBuilding = null;
         var matsNeeded:int = 0;
         var hasStorageType:Boolean = false;
         var buildingConstructionClass:Class = getDefinitionByName("Classes.ConstructionBuilding") as Class;
         var excludeItems:String = "";
         var result:Array = new Array();
         if(Global.flashHotParams["FINISH_ALL_BUILDINGS_EXCLUDE_ITEMS"] != null)
         {
            excludeItems = Global.flashHotParams["FINISH_ALL_BUILDINGS_EXCLUDE_ITEMS"];
         }
         if(isWorldExcluded(Global.worldManager.currentWorldType))
         {
            buildingsInWorld = new Array();
         }
         else
         {
            buildingsInWorld = Global.world.getObjectsByClass(buildingConstructionClass);
         }
         var excludeClassList:String = Global.farmGameSettingsManager.getString("finish_all_buildings_excluded_classes","MutableAnimalCrate,MutableAnimalBaby,MutableAnimalEgg,MysterySeedling");
         var len:int = int(buildingsInWorld.length);
         for(idx = 0; idx < len; idx++)
         {
            building = buildingsInWorld[idx] as ConstructionBuilding;
            matsNeeded = building.capacity - building.count;
            hasStorageType = false;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               hasStorageType = building.getItem().hasPropertyInDataSource("storageType");
            }
            else
            {
               hasStorageType = building.getItem().xml.hasOwnProperty("storageType");
            }
            if(building.getFinishedItem() != null && excludeClassList.indexOf(building.getItem().className) == -1 && hasStorageType && building.capacity > 0 && matsNeeded > 1 && excludeItems.indexOf(building.getFinishedItem().name) == -1)
            {
               result.push(building);
            }
         }
         result.sort(sortOnPercentageComplete);
         return result;
      }
      
      public static function getExpandibleItems() : Array
      {
         var buildings:Array = null;
         var building:StorageBuilding = null;
         var expand:IExpandComponent = null;
         var result:Array = [];
         var buildingClass:Class = getDefinitionByName("Classes.StorageBuilding") as Class;
         var excludeItems:String = "";
         if(Global.flashHotParams["FINISH_ALL_BUILDINGS_EXCLUDE_ITEMS"] != null)
         {
            excludeItems = Global.flashHotParams["FINISH_ALL_BUILDINGS_EXCLUDE_ITEMS"];
         }
         if(isWorldExcluded(Global.worldManager.currentWorldType))
         {
            buildings = new Array();
         }
         else
         {
            buildings = Global.world.getObjectsByClass(buildingClass);
         }
         var length:int = int(buildings.length);
         var excludeClassList:String = Global.farmGameSettingsManager.getString("finish_all_buildings_excluded_classes","MutableAnimalCrate,MutableAnimalBaby,MutableAnimalEgg,MysterySeedling");
         for(var index:int = 0; index < length; index++)
         {
            building = buildings[index];
            if(excludeClassList.indexOf(building.getItem().className) == -1 && building.capacity > 0 && excludeItems.indexOf(building.getItem().name) == -1)
            {
               if(building is FeatureBuilding)
               {
                  expand = (building as FeatureBuilding).expand;
                  if(expand != null && expand.hasNextExpansion() && expand.getExpandCashNeeded() > 1)
                  {
                     result.push(building);
                  }
               }
               else if(building is OrchardBuilding && (building as OrchardBuilding).isExpandable())
               {
                  result.push(building);
               }
            }
         }
         return result;
      }
      
      protected static function sortOnPercentageComplete(bldgA:ConstructionBuilding, bldgB:ConstructionBuilding) : Number
      {
         var aPercentComplete:Number = bldgA.count / bldgA.capacity;
         var bPercentComplete:Number = bldgB.count / bldgB.capacity;
         var result:Number = 0;
         if(aPercentComplete < bPercentComplete)
         {
            result = 1;
         }
         else if(aPercentComplete > bPercentComplete)
         {
            result = -1;
         }
         return result;
      }
      
      public static function isWorldExcluded(worldType:String) : Boolean
      {
         var excludeFarms:String = "";
         if(Global.flashHotParams["FINISH_ALL_BUILDINGS_EXCLUDE_FARMS"] != null)
         {
            excludeFarms = Global.flashHotParams["FINISH_ALL_BUILDINGS_EXCLUDE_FARMS"];
         }
         return excludeFarms.indexOf(worldType) > -1;
      }
      
      public static function conditionallyShowMOTD() : void
      {
         if(getTimeLeft() <= 0)
         {
            UI.showMessage(ZLocUtils.t("Dialogs","limitedSaleTimerExpired"),UI.BUTTON_LAYOUT_OK,null,null,false);
            Global.hud.rightSideIconQueue.removeIconByName(ICON_NAME);
         }
         else
         {
            UI.displayPopup(new FinishAllBuildingsMOTDWindow(),true,FinishAllBuildingsMOTDWindow.POPUP_NAME,true);
         }
      }
      
      public static function conditionallyShowHudIcon() : void
      {
         var timeLeft:Number = getTimeLeft();
         var freqFlag:String = getFrequencyFlag();
         if(Global.player.getFeatureLastShown(freqFlag) != 0 && timeLeft > 0 && Global.hud.rightSideIconQueue.getIconByName(ICON_NAME) == null)
         {
            Global.hud.rightSideIconQueue.addIcon(ICON_NAME,DynamicIconQueue.ADD_BY_PRIORITY,null,{"expirationTime":timeLeft},false);
         }
      }
      
      public static function getTimeLeft() : Number
      {
         var result:Number = NaN;
         var duration:int = Global.flashHotParams["FINISH_ALL_BUILDINGS_DURATION"] != null ? int(Global.flashHotParams["FINISH_ALL_BUILDINGS_DURATION"]) : DEFAULT_DURATION;
         var freqFlag:String = getFrequencyFlag();
         var timeStamp:Number = Global.player.getFeatureLastShown(freqFlag) * FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(timeStamp == 0)
         {
            result = duration * FarmGameUtil.NUM_MSECS_IN_HOUR;
         }
         else
         {
            result = timeStamp + duration * FarmGameUtil.NUM_MSECS_IN_HOUR - GlobalEngine.serverTime;
         }
         return result;
      }
      
      public static function getFrequencyFlag() : String
      {
         return Global.flashHotParams["FINISH_ALL_BUILDINGS_FREQ_FLAG"] != null ? Global.flashHotParams["FINISH_ALL_BUILDINGS_FREQ_FLAG"] : DEFAULT_FREQ_FLAG;
      }
   }
}

