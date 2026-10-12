package Classes
{
   import Classes.Avatar.FarmAvatar;
   import Classes.Constants.Experiments;
   import Classes.Terrain.TerrainUtil;
   import Classes.ZItem.HarvestableItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.SoundManager;
   import Managers.AOEManager;
   import Managers.FarmGameSettingsManager;
   import Managers.RetentionMasterManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Windows.Toasters.AddFuelOrTurboToasterWindow;
   import by.blooddy.crypto.MD5;
   import com.infomatiq.jsi.RectangleUtil;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class HarvestableResource extends CompositeMapResource
   {
      
      public static const ENERGY_SOURCE_AVATAR:int = 0;
      
      public static const ENERGY_SOURCE_FUEL:int = 1;
      
      public static const ENERGY_SOURCE_SUPER_AVATAR:int = 2;
      
      public static const RESOURCE_ACTION_CLEAR:int = 0;
      
      public static const RESOURCE_ACTION_PLANT:int = 1;
      
      public static const RESOURCE_ACTION_HARVEST:int = 2;
      
      public static const IS_PLANTING:String = "planting";
      
      public static const IS_HARVESTING:String = "harvesting";
      
      public static const IS_PLOWING:String = "plowing";
      
      public static const IS_FERTILIZING:String = "fertilizing";
      
      public static const IS_RESTING:String = "";
      
      protected static const GROW_UPDATE_RATE:Number = 2;
      
      private static const WATER_EFFECT_URL:String = "assets/overlays/effect_water_loop.swf";
      
      private static const IRRIGATION_MINUTES_TO_INSTAGROW:int = 15;
      
      protected var m_actionState:String = "";
      
      protected var m_plantTime:Number;
      
      protected var m_aoePlantTime:Number;
      
      protected var m_witherTime:Number;
      
      protected const HARVEST_OBJECT:String = "harvestObject";
      
      protected var m_isBigPlot:Boolean = false;
      
      protected var m_timeSinceGrowUpdate:Number = 0;
      
      protected var m_growPercentage:Number = 0;
      
      protected var m_isProduceItem:Boolean = false;
      
      protected var m_isBusy:Boolean = false;
      
      public function HarvestableResource(itemName:String)
      {
         super(itemName);
      }
      
      override public function getSaveObject() : Object
      {
         var obj:Object = super.getSaveObject();
         obj.plantTime = this.plantTime;
         return obj;
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         this.plantTime = data.plantTime;
         this.m_witherTime = this.getWitherTime(data.plantTime,data.position.x,data.position.y);
         this.updateGrowPercentage();
         if(data.aoePlantTime)
         {
            this.m_aoePlantTime = data.aoePlantTime;
         }
         else
         {
            this.m_aoePlantTime = 0;
         }
      }
      
      override public function onDelete() : void
      {
         super.onDelete();
         Global.world.extraItemFlagsRemoveInst(this);
      }
      
      protected function getWitherTime(plantTime:Number, x_coord:Number, y_coord:Number, witherTime:Number = -1) : Number
      {
         var witherDelta:Number = NaN;
         var currentWorld:String = null;
         var worldHasMoreThanOneSeason:Boolean = false;
         var terrainCodePlacedOn:Array = null;
         var terrainCode:int = 0;
         if(GlobalEngine.getFlashVar("disallowWither") == 1 || getItem() != null && !getItem().expires || Global.worldManager.isVisitingNPCOfType(NPCConfigData.TYPE_MODELFARM))
         {
            witherTime = 0;
         }
         else
         {
            witherDelta = this.getWitherDelta(plantTime,x_coord,y_coord,witherTime);
            currentWorld = Global.worldManager.currentWorldType;
            worldHasMoreThanOneSeason = WorldSeasonsManager.getInstance().getNumSeasonsForWorld(currentWorld) > 1 ? true : false;
            if(worldHasMoreThanOneSeason)
            {
               terrainCodePlacedOn = TerrainUtil.getTerrainCodesForItemInstance(this);
               var _loc10_:int = 0;
               var _loc11_:* = terrainCodePlacedOn;
               for each(terrainCode in _loc11_)
               {
                  if(Global.getCurrentWitherStatusArray(terrainCode))
                  {
                     witherTime = plantTime + witherDelta;
                  }
                  else
                  {
                     witherTime = 0;
                  }
               }
            }
            else if(Global.getCurrentWitherStatus())
            {
               witherTime = plantTime + witherDelta;
            }
            else
            {
               witherTime = 0;
            }
         }
         return witherTime;
      }
      
      protected function getWitherDelta(plantTime:Number, x_coord:Number, y_coord:Number, witherTime:Number = -1) : Number
      {
         var variant:int = 0;
         var witherMultiplier:Number = Global.farmGameSettingsManager.getNumber("witherMultiplier");
         var witherRandomRange:Number = Global.farmGameSettingsManager.getNumber("witherRandomRange");
         var key:String = plantTime.toString() + x_coord.toString() + y_coord.toString();
         var md5Hash:String = MD5.hash(key);
         var hexDigits:int = 7;
         var decVal:int = parseInt("0x" + md5Hash.substr(-hexDigits));
         var witherRandomFactor:Number = (decVal % 100 + 1) / 100 * witherRandomRange;
         var witherFinalMultiplier:Number = witherMultiplier + witherRandomFactor;
         if(RetentionMasterManager.inMasterExperiment())
         {
            variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_DOUBLE_WITHER);
            if(variant == 2 || variant == 4)
            {
               witherFinalMultiplier = witherFinalMultiplier * 2 - 1;
            }
         }
         var witherDelta:Number = this.getGrowTime();
         if(witherTime == -1)
         {
            witherDelta *= witherFinalMultiplier;
         }
         else
         {
            if(witherFinalMultiplier - 1 <= 0)
            {
               witherFinalMultiplier = 2;
            }
            witherDelta += witherTime * (witherFinalMultiplier - 1);
         }
         return witherDelta;
      }
      
      public function getGrowTime() : Number
      {
         var daysToMilliseconds:Number = NaN;
         var result:Number = 1;
         if(m_item is HarvestableItem)
         {
            daysToMilliseconds = Global.farmGameSettingsManager.inGameDaySeconds * 1000;
            result = (m_item as HarvestableItem).growTime * daysToMilliseconds;
         }
         return result * Global.farmGameSettingsManager.growMultiplier;
      }
      
      override public function onUpdate(delta:Number) : void
      {
         if(delta)
         {
            this.m_timeSinceGrowUpdate += delta;
         }
         if(this.m_timeSinceGrowUpdate >= HarvestableResource.GROW_UPDATE_RATE)
         {
            this.onPeriodicUpdate();
            this.updateGrowPercentage();
            this.m_timeSinceGrowUpdate = 0;
         }
         this.determineState(delta);
         super.onUpdate(delta);
      }
      
      protected function onPeriodicUpdate() : void
      {
      }
      
      protected function determineState(delta:Number) : void
      {
      }
      
      public function getAOESourceIds() : Array
      {
         var aoeResourceIds:Array = AOEManager.getInstance().getAoeResourceIdsAffecting(this as MapResource);
         return aoeResourceIds != null && aoeResourceIds.length > 0 ? aoeResourceIds : null;
      }
      
      public function harvest(energySource:int = 0, energy:Number = 0, showNoEnergyMessage:Boolean = true, updateBackend:Boolean = true, neighborId:String = "0") : Boolean
      {
         return false;
      }
      
      public function getHarvestTime() : Number
      {
         return 2;
      }
      
      public function get plantTime() : Number
      {
         return this.m_plantTime;
      }
      
      public function set plantTime(time:Number) : void
      {
         this.m_plantTime = this.m_aoePlantTime = time;
         this.m_growPercentage = 0;
      }
      
      public function canEarnMasteryPoints(crop:Object) : Boolean
      {
         var cropXml:XML = null;
         var result:Boolean = false;
         if(!Global.worldManager.isVisiting())
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               result = crop.masteryYield > 0 && crop.hasMastery && (Global.player.level >= Global.farmGameSettingsManager.getAttribute("masteryStartLevel",15) || m_item.getStringFromDataSource("bypassMasteryLevelLock") == "1") && !crop.masteryObject.hasAllMasteries();
            }
            else
            {
               cropXml = m_item.xml;
               result = crop.masteryYield > 0 && crop.hasMastery && (Global.player.level >= Global.farmGameSettingsManager.getAttribute("masteryStartLevel",15) || cropXml.bypassMasteryLevelLock == "1") && !crop.masteryObject.hasAllMasteries();
            }
         }
         return result;
      }
      
      public function doHarvestDropOff(avatar:FarmAvatar, showStatus:Boolean = true) : Object
      {
         SoundManager.chooseAndPlaySound(["money1","money2","money3"]);
         return null;
      }
      
      public function isHarvestable() : Boolean
      {
         return true;
      }
      
      public function set isBusy(busy:Boolean) : void
      {
         this.m_isBusy = busy;
      }
      
      public function get isBusy() : Boolean
      {
         return this.m_isBusy;
      }
      
      public function getHarvestText() : String
      {
         return ZLocUtils.t("FarmGame","Harvesting");
      }
      
      public function getActionState() : String
      {
         return this.m_actionState;
      }
      
      public function setActionState(newState:String) : void
      {
         switch(newState)
         {
            case IS_PLANTING:
               this.m_actionState = IS_PLANTING;
               break;
            case IS_PLOWING:
               this.m_actionState = IS_PLOWING;
               break;
            case IS_HARVESTING:
               this.m_actionState = IS_HARVESTING;
               break;
            case IS_FERTILIZING:
               this.m_actionState = IS_FERTILIZING;
               break;
            default:
               this.m_actionState = IS_RESTING;
         }
      }
      
      public function set isBigPlot(isBigPlot:Boolean) : void
      {
         this.m_isBigPlot = isBigPlot;
      }
      
      public function get isBigPlot() : Boolean
      {
         return this.m_isBigPlot;
      }
      
      public function updateGrowPercentage() : void
      {
         var alpha:Number = NaN;
         if(this.plantTime > 0)
         {
            alpha = (Global.worldTime - this.plantTime) / this.getGrowTime();
            alpha = Math.floor(alpha * 100);
            this.m_growPercentage = Math.max(Math.min(alpha,100),0);
         }
         else
         {
            this.m_growPercentage = 0;
         }
      }
      
      public function getGrowPercentage() : Number
      {
         return this.m_growPercentage;
      }
      
      public function getGrowTimeLeft() : Number
      {
         return this.getGrowTime() - (Global.worldTime - this.plantTime);
      }
      
      public function set isProduceItem(isProduceItem:Boolean) : void
      {
         this.m_isProduceItem = isProduceItem;
      }
      
      public function get isProduceItem() : Boolean
      {
         return this.m_isProduceItem;
      }
      
      public function onHarvestComplete(result:Object) : void
      {
      }
      
      protected function hasEnergy(energySource:int, cost:int, resourceAction:int, showMessage:Boolean = true) : Boolean
      {
         var hasEnergy:Boolean = false;
         switch(energySource)
         {
            case HarvestableResource.ENERGY_SOURCE_FUEL:
               hasEnergy = Global.player.hasEnergy(cost,showMessage);
               break;
            case HarvestableResource.ENERGY_SOURCE_SUPER_AVATAR:
               hasEnergy = Global.player.getNumSuperAvatarActions(resourceAction) >= cost;
               break;
            case HarvestableResource.ENERGY_SOURCE_AVATAR:
               hasEnergy = true;
         }
         return hasEnergy;
      }
      
      protected function useEnergy(energySource:int, cost:int, resourceAction:int) : Object
      {
         var energyMetadata:Object = null;
         if(cost > 0)
         {
            switch(energySource)
            {
               case HarvestableResource.ENERGY_SOURCE_FUEL:
                  if(!Global.player.hasUnlimitedFuelOfferActivated())
                  {
                     Global.player.energy -= cost;
                     if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FUEL_TURBO_TOASTER) > 1 && Math.ceil(Global.player.energy / Global.player.energyMax) < AddFuelOrTurboToasterWindow.THRESHHOLD)
                     {
                        AddFuelOrTurboToasterWindow.showToasterWindow(AddFuelOrTurboToasterWindow.FUEL);
                     }
                  }
                  break;
               case HarvestableResource.ENERGY_SOURCE_SUPER_AVATAR:
            }
         }
         return energyMetadata;
      }
      
      public function isHarvestableByNeighbors() : Boolean
      {
         return false;
      }
      
      public function setFullGrown() : void
      {
         var growTime:int = 0;
         var delta:Number = NaN;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            growTime = getItem().getIntFromDataSource("growTime");
         }
         else
         {
            growTime = int(getItem().xml.growTime);
         }
         var daysToMilliseconds:Number = Global.farmGameSettingsManager.inGameDaySeconds * 1000;
         var totalGrowTime:Number = growTime * daysToMilliseconds * Global.farmGameSettingsManager.growMultiplier;
         var oldPlantTime:Number = this.m_plantTime;
         this.m_plantTime = Global.worldTime - totalGrowTime;
         if(AOEManager.getInstance().isAOETarget(this))
         {
            delta = this.m_plantTime - oldPlantTime;
            if(delta < 0)
            {
               m_aoePlaceTime += delta;
            }
            this.m_aoePlantTime = this.m_plantTime;
         }
         this.m_growPercentage = 100;
      }
      
      public function waterHarvestableResource(timeMultiplier:Number) : void
      {
         var growTime:Number = NaN;
         var delta:Number = NaN;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            growTime = getItem().getNumberFromDataSource("growTime");
         }
         else
         {
            growTime = Number(getItem().xml.growTime);
         }
         var daysToMilliseconds:Number = Global.farmGameSettingsManager.inGameDaySeconds * 1000;
         var totalGrowTime:Number = growTime * daysToMilliseconds * Global.farmGameSettingsManager.growMultiplier;
         var oldPlantTime:Number = this.m_plantTime;
         var remaining:Number = (totalGrowTime - (Global.worldTime - oldPlantTime)) * timeMultiplier;
         if(remaining > IRRIGATION_MINUTES_TO_INSTAGROW * FarmGameUtil.NUM_MSECS_IN_MINUTE)
         {
            this.m_plantTime = Global.worldTime - totalGrowTime + remaining;
            if(AOEManager.getInstance().isAOETarget(this))
            {
               delta = this.m_plantTime - oldPlantTime;
               if(delta < 0)
               {
                  m_aoePlaceTime += delta;
               }
               this.m_aoePlantTime = this.m_plantTime;
            }
            this.m_growPercentage = (totalGrowTime - remaining) / totalGrowTime * 100;
         }
         else
         {
            this.setFullGrown();
         }
         this.addEffect(WATER_EFFECT_URL,true,false);
      }
      
      public function conditionallyShowAntiStuffingAoeMessage() : void
      {
         var rect:Rectangle = null;
         var midPoint:Point = null;
         var message:String = null;
         if(this.isHarvestable())
         {
            rect = this.getTileRect();
            midPoint = RectangleUtil.midpoint(rect);
            midPoint = m_displayObject.localToGlobal(midPoint);
            message = ZLocUtils.t("Dialogs","AOEAntiStuffingText",{"item":ZLocUtils.tk_pk(getItem().friendlyName)});
            UI.displayStatus(message,midPoint.x,midPoint.y,"",null,3,64,UI.DEFAULT_STATUS_TWEEN_FONT_SIZE,16777215);
         }
      }
      
      public function getHarvestYieldTypes() : Array
      {
         var harvestYields:Vector.<HarvestYield> = null;
         var harvestYield:HarvestYield = null;
         var result:Array = new Array();
         var item:HarvestableItem = getItem() as HarvestableItem;
         if(item)
         {
            harvestYields = item.harvestYields;
            for each(harvestYield in harvestYields)
            {
               result.push(harvestYield.type);
            }
         }
         return result;
      }
      
      public function getAOEPlantTime() : Number
      {
         var difference:Number = NaN;
         var allowedDifference:Number = NaN;
         var result:Number = this.m_plantTime;
         if(this.m_aoePlantTime > 0)
         {
            difference = this.m_aoePlantTime - this.m_plantTime;
            allowedDifference = 255 * FarmGameUtil.NUM_MSECS_IN_SECOND;
            if(difference <= allowedDifference && difference >= 0)
            {
               result = this.m_aoePlantTime;
            }
            else
            {
               this.m_aoePlantTime = this.m_plantTime;
            }
         }
         return result;
      }
      
      public function getHarvestTimeText(pkgKeyOverride:String = "PlantedPlotTime") : String
      {
         var timeString:String = FarmGameUtil.toFriendlyTime(this.getGrowTimeLeft() / FarmGameUtil.NUM_MSECS_IN_SECOND);
         return ZLocUtils.t("FarmGame",pkgKeyOverride,{
            "item":ZLocUtils.tk_pk(m_item.friendlyName),
            "timeString":timeString
         });
      }
      
      public function setOrganicFertilized(isSet:Boolean) : void
      {
         Global.world.setIsHarvestableResourceOrganicFertilized(this,isSet);
      }
   }
}

