package AvatarMode
{
   import Classes.Airplane;
   import Classes.AnimalStorageBuilding;
   import Classes.Avatar.FarmAvatar;
   import Classes.Constants.Experiments;
   import Classes.Consumable;
   import Classes.Equipment;
   import Classes.FeatureBuilding;
   import Classes.HarvestableResource;
   import Classes.HarvestableStorageBuilding;
   import Classes.OrchardBuilding;
   import Classes.OrchardFeatureBuilding;
   import Classes.Plot;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.SeedItem;
   import Classes.instagrow.InstagrowUtils;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Classes.TileMap;
   import Engine.IsoMath;
   import GameMode.GMAirplaneFly;
   import GameMode.GMDefault;
   import Managers.FarmGameSettingsManager;
   import Managers.InstagrowHelper;
   import Managers.ToasterManager;
   import Widgets.Windows.IconTitleToasterWindow;
   import com.greensock.easing.Linear;
   import com.greensock.easing.Sine;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.utils.setTimeout;
   import gs.TweenLite;
   
   public class AMAirplane extends AMEquipment
   {
      
      public static const DEFAULT_AIRPLANE_ITEM:String = "biplanered";
      
      private static const REPOPUP_DELAY:int = 1000;
      
      private var m_pathTimeInSeconds:Number = 2;
      
      private var m_pathDistanceMultiplier:Number = 2;
      
      protected var m_flyingPlane:Airplane;
      
      private var m_planeOrigin:Point;
      
      private var m_tempAirplane:Boolean = false;
      
      private var m_wayPoints:Array;
      
      private var m_planeOriginalDisplayParent:Sprite;
      
      private var m_shouldSendTransaction:Boolean;
      
      private var m_instagrowHelper:InstagrowHelper;
      
      private var m_tweenComplete:Boolean = false;
      
      private var m_showSeedsNotPlantedMsg:Boolean = false;
      
      private var m_seedIconUrl:String = "";
      
      private var bloomConsumable:Consumable;
      
      private var gardenConsumable:Consumable;
      
      private var animalConsumable:Consumable;
      
      private var animalStorageConsumable:Consumable;
      
      private var orchardConsumable:Consumable;
      
      private var treeConsumable:Consumable;
      
      public function AMAirplane(avatar:FarmAvatar, instagrowHelper:InstagrowHelper, equipment:Equipment, doTransaction:Boolean = true)
      {
         var airplaneName:String = null;
         var worldTileMap:TileMap = null;
         if(equipment == null)
         {
            airplaneName = Global.worldSettingsManager.getWorldSpecificPlaneItemName(Global.worldManager.currentWorldType,DEFAULT_AIRPLANE_ITEM);
            equipment = new Airplane(airplaneName,true);
            equipment.setOuter(Global.world);
            worldTileMap = Global.world.getTileMap();
            equipment.setPosition(worldTileMap.getWidth() / 2,worldTileMap.getHeight());
            equipment.attach();
            equipment.setVisible(true);
            this.m_tempAirplane = true;
         }
         var centerPos:Point = new Point(equipment.getPosition().x,equipment.getPosition().y);
         super(avatar,instagrowHelper.getTotalPlots(),equipment,centerPos);
         this.m_instagrowHelper = instagrowHelper;
         this.m_flyingPlane = m_actionEquipment as Airplane;
         this.m_flyingPlane.setVisible(true);
         this.m_shouldSendTransaction = doTransaction;
         Global.hud.iconQueue.removeIconByName(InstagrowUtils.INSTA_GROW_HUD_ICON_NAME);
      }
      
      public function set pathTimeInSeconds(numSeconds:Number) : void
      {
         this.m_pathTimeInSeconds = numSeconds;
      }
      
      public function set pathDistanceMultiplier(scalar:Number) : void
      {
         this.m_pathDistanceMultiplier = scalar;
      }
      
      override protected function fadeAndLockResources(onOff:Boolean, noFade:Boolean = false) : void
      {
         var allResources:Array = null;
         var resource:HarvestableResource = null;
         var fadeAlpha:Number = 1;
         if(onOff && !noFade)
         {
            fadeAlpha = RESOURCE_FADE_ALPHA;
         }
         if(this.m_instagrowHelper)
         {
            allResources = this.m_instagrowHelper.getAllResourcesActedUpon();
            for each(resource in allResources)
            {
               resource.setAlpha(fadeAlpha);
               if(onOff)
               {
                  resource.lock();
               }
               else
               {
                  resource.unlock();
               }
            }
         }
      }
      
      override public function update(delta:Number) : void
      {
         var progress:Number = NaN;
         var statusKeySuffix:String = null;
         if(this.m_tweenComplete && !(this.m_flyingPlane !== null && this.m_flyingPlane.isFlying))
         {
            if(m_actionStarted)
            {
               m_actionTime += delta;
               progress = m_actionTime / Global.farmGameSettingsManager.getNumber("instaGrowplantTime");
               if(progress > 1)
               {
                  if(this.m_instagrowHelper.isAutoPPH)
                  {
                     if(m_plots.length)
                     {
                        statusKeySuffix = Global.player.hasNoFuelDayActive() ? AMMultiPlotAction.STATUS_ENERGY_SOURCE_FREE_FUEL : AMMultiPlotAction.STATUS_ENERGY_SOURCE_FUEL;
                        multiCombine(HarvestableResource.ENERGY_SOURCE_AVATAR,null,m_plots,m_avatar,statusKeySuffix,false,false);
                     }
                     else
                     {
                        this.m_instagrowHelper.setRePop(false);
                     }
                     this.cleanUpState();
                  }
               }
               else if(!this.m_instagrowHelper.isAutoPPH)
               {
                  this.cleanUpState();
               }
               else
               {
                  m_avatar.setActionProgress(ZLocUtils.t("FarmGame","Farming"),progress);
               }
            }
         }
      }
      
      private function cleanUpState() : void
      {
         var repop:Function;
         var genericItemToaster:IconTitleToasterWindow = null;
         var message:String = null;
         var messageHeader:String = null;
         var delay:Number = NaN;
         m_avatar.getStateMachine().removeState(this);
         if(Global.world.getTopGameMode() is GMAirplaneFly)
         {
            Global.world.getTopGameMode().disableMode();
            Global.world.addGameMode(new GMDefault());
         }
         if(this.m_showSeedsNotPlantedMsg)
         {
            message = ZLocUtils.t("Dialogs","InstantGrow_DialogSeedsNotPlanted");
            messageHeader = ZLocUtils.t("Dialogs","InstantGrow_DialogSeedsNotPlantedHeader");
            genericItemToaster = new IconTitleToasterWindow(messageHeader,message,this.m_seedIconUrl,IconTitleToasterWindow.DIALOG_ASSET,0.7);
         }
         if(this.m_instagrowHelper.isAutoPPH)
         {
            this.fadeAndLockResources(false);
            if(this.m_instagrowHelper.isRePop)
            {
               repop = function():void
               {
                  var message:String = null;
                  var dialog:GenericPopup = null;
                  if(Global.world.addGameMode(new GMAirplaneFly(),true) == false)
                  {
                     message = ZLocUtils.t("Dialogs","InstantGrow_OnlyOnePlaneAtATime");
                     dialog = new GenericPopup(message,GenericPopup.TYPE_OK);
                     UI.displayPopup(dialog);
                  }
               };
               delay = REPOPUP_DELAY;
               if(genericItemToaster)
               {
                  ToasterManager.getInstance().add(genericItemToaster);
                  delay = genericItemToaster.timeToLive;
               }
               setTimeout(repop,delay);
            }
            else if(genericItemToaster)
            {
               ToasterManager.getInstance().add(genericItemToaster);
            }
         }
         this.doAutoHarvestForAll();
      }
      
      private function prepareAutoPPHCrops() : void
      {
         var plot:Plot = null;
         var pickSeed:Boolean = false;
         var seed:FarmItem = null;
         var seedName:String = null;
         var seedItem:SeedItem = null;
         var hasSeedPackage:Boolean = false;
         var plotsToPPH:Array = new Array();
         var plotsBySeed:Object = {};
         var plotList:Array = this.m_instagrowHelper.getTotalPlots();
         plotList.sort(function(a:Plot, b:Plot):int
         {
            if(a.getId() < b.getId())
            {
               return -1;
            }
            if(a.getId() > b.getId())
            {
               return 1;
            }
            return 0;
         });
         for each(plot in plotList)
         {
            seed = plot.getItem();
            seedName = seed.name;
            seedItem = Global.farmGameSettingsManager.getFarmItemByName(seedName) as SeedItem;
            pickSeed = true;
            hasSeedPackage = false;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               hasSeedPackage = seed.hasPropertyInDataSource("seedpackage");
            }
            else
            {
               hasSeedPackage = seed.xml.hasOwnProperty("seedpackage");
            }
            if(hasSeedPackage && Global.player.hasSeed(seedName))
            {
               if(!plotsBySeed.hasOwnProperty(seedName))
               {
                  plotsBySeed[seedName] = {"count":Global.player.countSeeds(seedName)};
               }
               if(plotsBySeed[seedName].count <= 0)
               {
                  pickSeed = false;
               }
               else
               {
                  --plotsBySeed[seedName].count;
               }
            }
            if(pickSeed && seedItem.isVisible && !seedItem.isLocked)
            {
               plotsToPPH.push(plot);
            }
            else
            {
               this.m_seedIconUrl = seedItem.iconUrl;
               this.m_showSeedsNotPlantedMsg = true;
            }
         }
         m_plots = plotsToPPH;
      }
      
      private function onPlaneTweenComplete() : void
      {
         var startPoint:Point = null;
         var endPoint:Point = null;
         var planeDisplayObject:DisplayObject = null;
         var oldX:Number = NaN;
         var oldY:Number = NaN;
         var invert:Boolean = false;
         var direction:String = null;
         var easeType:Function = null;
         var endAlpha:Number = NaN;
         this.m_wayPoints.shift();
         if(this.m_wayPoints.length == 0)
         {
            this.landPlane();
            this.growAllResources();
            this.m_tweenComplete = true;
            if(this.m_instagrowHelper.isAutoPPH)
            {
               this.prepareAutoPPHCrops();
               if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_INSTAGROW_AUTO_PPH_COLOR) > 2)
               {
                  this.fadeAndLockResources(true,true);
               }
               else
               {
                  this.fadeAndLockResources(true,false);
               }
            }
            else
            {
               this.cleanUpState();
            }
         }
         else
         {
            startPoint = this.m_wayPoints[0].start as Point;
            endPoint = this.m_wayPoints[0].end as Point;
            planeDisplayObject = this.m_flyingPlane.getDisplayObject();
            oldX = planeDisplayObject.x;
            oldY = planeDisplayObject.y;
            invert = Boolean(this.m_wayPoints[0].invert);
            direction = this.m_wayPoints[0].direction;
            easeType = Linear.easeNone;
            if(this.m_wayPoints[0].hasOwnProperty("easeType"))
            {
               easeType = this.m_wayPoints[0].easeType;
            }
            if(this.m_wayPoints[0].hasOwnProperty("startAlpha"))
            {
               planeDisplayObject.alpha = this.m_wayPoints[0].startAlpha;
            }
            endAlpha = 1;
            if(this.m_wayPoints[0].hasOwnProperty("endAlpha"))
            {
               endAlpha = Number(this.m_wayPoints[0].endAlpha);
            }
            this.m_flyingPlane.setflying(true,direction);
            if(invert)
            {
               planeDisplayObject.scaleX = Math.abs(planeDisplayObject.scaleX) * -1;
            }
            else
            {
               planeDisplayObject.scaleX = Math.abs(planeDisplayObject.scaleX);
            }
            if(startPoint == null)
            {
               planeDisplayObject.x = oldX;
               planeDisplayObject.y = oldY;
            }
            else
            {
               planeDisplayObject.x = startPoint.x;
               planeDisplayObject.y = startPoint.y;
            }
            this.m_tweenComplete = false;
            TweenLite.to(planeDisplayObject,this.m_pathTimeInSeconds,{
               "x":endPoint.x,
               "y":endPoint.y,
               "ease":easeType,
               "alpha":endAlpha,
               "onComplete":this.onPlaneTweenComplete
            });
         }
      }
      
      override protected function hide() : void
      {
         var preActionPlotItems:Object = null;
         super.hide();
         m_equipment.setVisible(false);
         this.takeOffPlane();
         if(this.m_instagrowHelper.isAutoPPH)
         {
            preActionPlotItems = getPreActionPlotItemsList(m_plots,Plot.STATE_GROWN);
         }
         this.sendBackendTransaction(preActionPlotItems);
      }
      
      protected function sendBackendTransaction(preActionPlotItems:Object = null) : void
      {
         var plotBundle:Object = null;
         var aoeSources:Object = null;
         var plotIdx:int = 0;
         var currentPlot:Plot = null;
         var currentPlotAoeSources:Array = null;
         if(this.m_shouldSendTransaction == true && Boolean(this.m_instagrowHelper))
         {
            plotBundle = {};
            aoeSources = {};
            if(m_plots.length)
            {
               for(plotIdx = 0; plotIdx < m_plots.length; plotIdx++)
               {
                  currentPlot = m_plots[plotIdx] as Plot;
                  plotBundle[plotIdx] = {
                     "id":currentPlot.getId(),
                     "position":currentPlot.getPosition()
                  };
                  currentPlotAoeSources = currentPlot.getAOESourceIds();
                  if(currentPlotAoeSources != null)
                  {
                     aoeSources[currentPlot.getId()] = currentPlotAoeSources;
                  }
               }
            }
            this.m_instagrowHelper.sendTransaction(plotBundle,preActionPlotItems,aoeSources);
         }
      }
      
      override protected function show() : void
      {
         super.show();
         if(m_equipment)
         {
            m_equipment.setVisible(true);
         }
      }
      
      private function growAllResources() : void
      {
         if(this.m_instagrowHelper)
         {
            this.m_instagrowHelper.execute();
         }
      }
      
      private function landPlane() : void
      {
         if(!this.m_tempAirplane)
         {
            this.m_flyingPlane.getDisplayObject().x = this.m_planeOrigin.x;
            this.m_flyingPlane.getDisplayObject().y = this.m_planeOrigin.y;
            this.m_flyingPlane.setflying(false);
            this.m_flyingPlane.getDisplayObject().scaleX = Math.abs(this.m_flyingPlane.getDisplayObject().scaleX);
            this.m_planeOriginalDisplayParent.addChild(this.m_flyingPlane.getDisplayObject());
         }
         else
         {
            m_equipment.setVisible(false);
            m_equipment.detach();
            m_equipment = null;
            this.m_flyingPlane.setVisible(false);
            this.m_flyingPlane.detach();
            this.m_flyingPlane = null;
         }
      }
      
      protected function takeOffPlane() : void
      {
         var startEndPair:Object = null;
         var endPoint:Point = null;
         var planeDisplayObject:Sprite = this.m_flyingPlane.getDisplayObject() as Sprite;
         this.m_planeOrigin = new Point(planeDisplayObject.x,planeDisplayObject.y);
         this.m_planeOriginalDisplayParent = planeDisplayObject.parent as Sprite;
         var tileMapWidth:Number = Global.world.getTileMap().getWidth();
         var tileMapHeight:Number = Global.world.getTileMap().getHeight();
         var farmMidpointX:Number = tileMapWidth * 0.5;
         var farmMidpointY:Number = tileMapHeight * 0.5;
         var bottomWaypoint:Point = IsoMath.tilePosToPixelPos(farmMidpointX,farmMidpointY - tileMapHeight * this.m_pathDistanceMultiplier);
         var rightWaypoint:Point = IsoMath.tilePosToPixelPos(farmMidpointX + tileMapWidth * this.m_pathDistanceMultiplier,farmMidpointY);
         var topWaypoint:Point = IsoMath.tilePosToPixelPos(farmMidpointX,farmMidpointY + tileMapHeight * this.m_pathDistanceMultiplier);
         var leftWaypoint:Point = IsoMath.tilePosToPixelPos(farmMidpointX - tileMapWidth * this.m_pathDistanceMultiplier,farmMidpointY);
         var centerWaypoint:Point = IsoMath.tilePosToPixelPos(farmMidpointX,farmMidpointY);
         this.visualizeWayPoint(topWaypoint,rightWaypoint,bottomWaypoint,leftWaypoint);
         this.m_wayPoints = [{
            "end":bottomWaypoint,
            "invert":false,
            "startAlpha":1,
            "endAlpha":0,
            "eastType":Linear.easeOut,
            "direction":Airplane.FRONT_FLY
         },{
            "end":centerWaypoint,
            "invert":true,
            "startAlpha":0,
            "endAlpha":1,
            "easeType":Sine.easeIn,
            "direction":Airplane.REAR_FLY
         },{
            "end":topWaypoint,
            "invert":true,
            "startAlpha":1,
            "endAlpha":0,
            "easeType":Linear.easeOut,
            "direction":Airplane.REAR_FLY
         },{
            "start":leftWaypoint,
            "end":centerWaypoint,
            "invert":false,
            "startAlpha":0,
            "endAlpha":1,
            "easeType":Sine.easeIn,
            "direction":Airplane.REAR_FLY
         },{
            "end":rightWaypoint,
            "invert":false,
            "startAlpha":1,
            "endAlpha":0,
            "easeType":Sine.easeOut,
            "direction":Airplane.REAR_FLY
         },{
            "start":topWaypoint,
            "end":this.m_planeOrigin,
            "invert":false,
            "startAlpha":0,
            "endAlpha":1,
            "easeType":Sine.easeInOut,
            "direction":Airplane.FRONT_FLY
         }];
         if(this.m_tempAirplane)
         {
            this.m_wayPoints.pop();
         }
         var offset:Number = 60;
         for each(startEndPair in this.m_wayPoints)
         {
            if(startEndPair.hasOwnProperty("start"))
            {
               startEndPair.start.y -= offset;
            }
            if(startEndPair.hasOwnProperty("end"))
            {
               startEndPair.end.y -= offset;
            }
         }
         GlobalEngine.viewport.uiBase.addChild(planeDisplayObject);
         this.m_flyingPlane.setflying(true);
         endPoint = this.m_wayPoints[0].end as Point;
         planeDisplayObject.alpha = 1;
         TweenLite.to(planeDisplayObject,this.m_pathTimeInSeconds,{
            "x":endPoint.x,
            "y":endPoint.y,
            "ease":Sine.easeIn,
            "alpha":0,
            "onComplete":this.onPlaneTweenComplete
         });
      }
      
      private function visualizeWayPoint(point1:Point, point2:Point, point3:Point, point4:Point) : void
      {
         var s:Sprite = null;
         var rad:Number = NaN;
         if(Config.DEBUG_MODE)
         {
            s = new Sprite();
            rad = 10;
            s.graphics.beginFill(16711680);
            s.graphics.drawCircle(point1.x,point1.y,rad);
            s.graphics.endFill();
            s.graphics.beginFill(65280);
            s.graphics.drawCircle(point2.x,point2.y,rad);
            s.graphics.endFill();
            s.graphics.beginFill(255);
            s.graphics.drawCircle(point3.x,point3.y,rad);
            s.graphics.endFill();
            s.graphics.beginFill(16711935);
            s.graphics.drawCircle(point4.x,point4.y,rad);
            s.graphics.endFill();
            GlobalEngine.viewport.uiBase.addChild(s);
         }
      }
      
      override protected function getEnergyForPlot(plotIndex:int) : int
      {
         return 0;
      }
      
      private function doAutoHarvestForAll() : void
      {
         var isOrchardBuildingAvailable:Boolean = false;
         var orchardBuildings:Array = null;
         var orchardFBuildings:Array = null;
         var orchardBuilding:HarvestableStorageBuilding = null;
         var isGardenAvailable:Boolean = false;
         var buildings:Array = null;
         var harvestBuilding:FeatureBuilding = null;
         var buildingItem:FarmItem = null;
         var animalHarvestBuildings:Array = null;
         if(this.m_instagrowHelper.isAutoTH)
         {
            isOrchardBuildingAvailable = false;
            this.treeConsumable = Consumable.createConsumable("consume_arborists");
            this.treeConsumable.consume(true,true,"",true,-1,1);
            orchardBuildings = Global.world.getObjectsByClass(OrchardBuilding);
            orchardFBuildings = Global.world.getObjectsByClass(OrchardFeatureBuilding);
            orchardBuildings = orchardBuildings.concat(orchardFBuildings);
            for each(orchardBuilding in orchardBuildings)
            {
               if(Boolean(orchardBuilding) && (orchardBuilding is OrchardBuilding || orchardBuilding is OrchardFeatureBuilding))
               {
                  isOrchardBuildingAvailable = true;
                  break;
               }
            }
            if(isOrchardBuildingAvailable)
            {
               this.orchardConsumable = Consumable.createConsumable("consume_autoharvest_orchards");
               this.orchardConsumable.consume(true,true,"",true,-1,1);
            }
         }
         if(this.m_instagrowHelper.isAutoBH)
         {
            isGardenAvailable = false;
            buildings = Global.world.getObjectsByClass(FeatureBuilding);
            for each(harvestBuilding in buildings)
            {
               if(Boolean(harvestBuilding) && Boolean(harvestBuilding.getItem()))
               {
                  buildingItem = harvestBuilding.getItem();
                  if(buildingItem.name == "flower_garden_finished")
                  {
                     isGardenAvailable = true;
                     break;
                  }
               }
            }
            if(isGardenAvailable)
            {
               this.gardenConsumable = Consumable.createConsumable("consume_autoharvest_gardens");
               this.gardenConsumable.consume(true,true,"",true,-1,1);
            }
            this.bloomConsumable = Consumable.createConsumable("consume_gardener");
            this.bloomConsumable.consume(true,true,"",true,-1,1);
         }
         if(this.m_instagrowHelper.isAutoAH)
         {
            this.animalConsumable = Consumable.createConsumable("consume_farm_hands");
            this.animalConsumable.consume(true,true,"",true,-1,1);
            animalHarvestBuildings = Global.world.getObjectsByClass(AnimalStorageBuilding);
            if(Boolean(animalHarvestBuildings) && animalHarvestBuildings.length > 0)
            {
               this.animalStorageConsumable = Consumable.createConsumable("consume_autoharvest_animals");
               this.animalStorageConsumable.consume(true,true,"",true,-1,1);
            }
         }
      }
   }
}

