package Classes
{
   import Cache.Classes.ZCacheUtil;
   import Classes.AreasOfEffect.AOEConfig;
   import Classes.Avatar.AvatarConfigSettings;
   import Classes.Avatar.AvatarManager;
   import Classes.Avatar.FarmAvatar;
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.DisplayLoading.DLManager;
   import Classes.Idle.IdleTaskQueue;
   import Classes.InvisibleTerrain.InvisibleTerrainMap;
   import Classes.Terrain.TerrainUtil;
   import Classes.TimedActions.TimedAction;
   import Classes.UserDrivenTerrain.UDTMap;
   import Classes.Yimf.Yimf;
   import Classes.Yimf.YimfManager;
   import Classes.Yimf.YimfMap;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.ChangeFarmItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.CustomizeAvatar;
   import Display.FarmTerrainMap;
   import Display.FarmTileMap;
   import Display.GenericPopup;
   import Display.StrokeTextField;
   import Display.UI;
   import Engine.ArrayUtil;
   import Engine.Classes.IsoViewport;
   import Engine.Classes.SoundObject;
   import Engine.Classes.World;
   import Engine.Classes.WorldObject;
   import Engine.Constants;
   import Engine.Events.LoaderEvent;
   import Engine.Events.SocialNetworkEvent;
   import Engine.Helpers.Vector2;
   import Engine.Helpers.Vector3;
   import Engine.Init.InitializationManager;
   import Engine.IsoMath;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.SoundManager;
   import Engine.Managers.StatsManager;
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import GameMode.*;
   import Managers.AOEManager;
   import Managers.DefconManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.OrganicFertilizerHelper;
   import Managers.PerformanceExperimentManager;
   import Managers.ToasterManager;
   import Managers.WorldManager;
   import Managers.WorldScoreManager;
   import Managers.WorldSeasonsManager;
   import MyLife.Events.SaveAvatarEvent;
   import MyLife.NPC.SimpleNPC;
   import Widgets.Windows.AOETooltip;
   import Widgets.Windows.AvatarEditor.AvatarEditorWindow;
   import Widgets.Windows.IconTitleToasterWindow;
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.BlendMode;
   import flash.display.DisplayObject;
   import flash.display.GradientType;
   import flash.display.Graphics;
   import flash.display.Sprite;
   import flash.display.StageQuality;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.media.Sound;
   import flash.system.System;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import gs.TweenLite;
   
   public class FarmGameWorld extends World
   {
      
      private static const PERF_UPDATE_INTERVAL:Number = 5000;
      
      private static const PERF_PROBABILITY:int = 10000;
      
      private static const FPS_UPDATE_INTERVAL:Number = 1000;
      
      private static const LOT_OUTLINE_VERTICAL_ANGLE:Number = Math.PI * (26 / 180);
      
      private static const LOT_OUTLINE_RATIO_ARRAY:Array = [20,235];
      
      private static const LE_TAG_FADE_DURATION:Number = 1;
      
      private static const LE_TAG_LIFETIME:Number = 5;
      
      private static const HOTPARAM_ANIMATION_START_INTERVAL:String = "WORLD_START_ANIMATION_INTERVAL";
      
      private static var AMBIENT_MUSIC_ID_PREFIX:String = "ambient_";
      
      private static const AOE_AREA_COLOR_TRANSFORM:ColorTransform = new ColorTransform(0,2,2,1,0,153,255);
      
      public static const DEFAULT_MAX_ANIMATIONS:int = 20;
      
      public static const EXTRA_ITEM_FLAG_ORGANIC_FERTILIZER:uint = 1;
      
      public static const EXTRA_ITEM_FLAG_IGNORE_SMART_BUILDABLE_REQUIREMENTS:uint = 2;
      
      public static const EXTRA_ITEM_FLAG_SUPER_PLOT:uint = 3;
      
      public const NO_STORAGE:int = 0;
      
      public const GIFTBOX_ID:int = -1;
      
      public const CONSUME_ID:int = -6;
      
      public const CRAFTEDGOODS_ID:int = -7;
      
      public const BUSHELBABIES_ID:int = -30;
      
      private const MAX_OBJECTS_WARNING:int = 100;
      
      protected var m_lastAnimationUpdate:int = 0;
      
      protected var m_startingQualityTime:int = 10;
      
      public var lotOutlineColor:uint = 3829545;
      
      public var lotOutlineAlpha:Number = 1;
      
      public var expansionOutlineColor:uint = 3829545;
      
      protected var m_musicChannel:SoundObject;
      
      protected var m_musicIndex:int = -1;
      
      protected var m_playNextMusicTimer:Timer;
      
      protected var m_activeModes:Array = [];
      
      protected var m_modeLock:int = 0;
      
      protected var m_pendingVisitUserId:String = "0";
      
      protected var m_lotSprite:Sprite = null;
      
      private var customizationUI:CustomizeAvatar;
      
      private var m_lastUpdate:int;
      
      private var m_frameCount:int;
      
      private var m_scrollTween:TweenLite;
      
      private var m_maxNumObjects:int = 0;
      
      protected var m_numUserClicks:int = 0;
      
      protected var m_numUserMoves:int = 0;
      
      protected var m_initializedPlusFrame:Boolean = false;
      
      public var m_chosenSeeder:Seeder = null;
      
      protected var m_lotTextBitmapDatas:Array = null;
      
      protected var m_lotTextBitmaps:Array = null;
      
      private var m_centerOnCallback:Function = null;
      
      protected const CORNER_NEIGHBOR_TEXT_DISPLACEMENT:int = 20;
      
      protected var m_expansionMarketing:Boolean = false;
      
      protected var m_lastMouseMoveCount:int = 0;
      
      protected var m_lastMouseClickCount:int = 0;
      
      protected var m_isLoading:Boolean = false;
      
      protected var m_isDragging:Boolean = false;
      
      protected var m_animationStartInterval:int = -1;
      
      protected var m_maxAnimations:int = 20;
      
      protected var m_timeLastAnimationStarted:int = 0;
      
      protected var m_numControlledPlayingMapResources:int = 0;
      
      protected var m_numUncontrolledMapResources:int = 0;
      
      protected var m_playingMapResources:Object = {};
      
      protected var m_resourcesPlayingBeforeDrag:Array = null;
      
      protected var m_timePlayableMapResourcesRefreshed:int = 0;
      
      protected var m_playableMapResources:Array = [];
      
      protected var m_animationMapResources:Array = [];
      
      protected var m_plotLimitCounts:Array = null;
      
      private var m_tagsLayer:Sprite = new Sprite();
      
      private var m_tagLoader:ImageLoader;
      
      private var m_tagMatrix:Matrix = new Matrix();
      
      public var m_timeEntered:Number = 0;
      
      private var m_isSoundForcefullyPaused:Boolean = false;
      
      private var m_extraItemFlags:BitFlagsById = null;
      
      private var m_aoeRenderLayer:Sprite;
      
      private var m_aoeToolTipLayer:Sprite;
      
      private var m_aoeRenderMap:Dictionary;
      
      private var m_timedActionPriorityQueue:Array;
      
      private var m_defaultGameMode:GameMode;
      
      private var m_defaultGameModeLockHolder:Object;
      
      private var m_originalGameMode:GameMode = new GMDefault();
      
      private var m_worldObjectBatchLoader:WorldObjectBatchLoader;
      
      private var m_stencilRenderLayer:Sprite;
      
      private var m_stencilRenderMap:Dictionary;
      
      public function FarmGameWorld()
      {
         var gridSize:Number = Global.farmGameSettingsManager.getInt("farmSize",80);
         super(gridSize,gridSize);
         this.m_lastUpdate = GlobalEngine.currentTime;
         this.m_lastAnimationUpdate = this.m_lastUpdate;
         this.m_frameCount = 0;
         Global.stage.quality = StageQuality.MEDIUM;
         this.m_aoeRenderMap = new Dictionary(true);
         this.m_aoeRenderLayer = new Sprite();
         this.m_aoeRenderLayer.blendMode = BlendMode.NORMAL;
         this.m_aoeToolTipLayer = new Sprite();
         GlobalEngine.viewport.overlayBase.addChildAt(this.m_aoeRenderLayer,0);
         GlobalEngine.viewport.uiBase.addChild(this.m_aoeToolTipLayer);
         this.m_stencilRenderMap = new Dictionary(true);
         this.m_stencilRenderLayer = new Sprite();
         this.m_stencilRenderLayer.blendMode = BlendMode.NORMAL;
         GlobalEngine.viewport.overlayBase.addChildAt(this.m_stencilRenderLayer,0);
         this.m_timedActionPriorityQueue = new Array();
         this.m_defaultGameMode = this.m_originalGameMode;
         this.m_extraItemFlags = new BitFlagsById(new Array());
      }
      
      public static function getNewUserWelcomeFeedImages() : Array
      {
         var images:Array = [];
         images.push({
            "src":Global.getAssetURL("assets/newsfeed/new_user_welcome_feed.png"),
            "href":"{SN_APP_URL}{creative:new_user_welcome}gifts.php?giftRecipient=" + Global.player.snUser.uid.toString() + "&newUser=true"
         });
         return images;
      }
      
      private static function getMusicId(worldId:String, index:int) : String
      {
         return worldId + index;
      }
      
      private static function getAmbientMusicId(worldId:String) : String
      {
         return AMBIENT_MUSIC_ID_PREFIX + worldId;
      }
      
      public static function drawTileArea(graphics:Graphics, basePosition:Point, tileSizeX:Number, tileSizeY:Number) : void
      {
         var startPoint:Point = IsoMath.tilePosToPixelPos(basePosition.x,basePosition.y);
         var deltaX:Vector2 = IsoMath.getPixelDeltaFromTileDelta(tileSizeX,0);
         var deltaY:Vector2 = IsoMath.getPixelDeltaFromTileDelta(0,tileSizeY);
         graphics.moveTo(startPoint.x,startPoint.y);
         graphics.lineTo(startPoint.x + deltaX.x,startPoint.y + deltaX.y);
         graphics.lineTo(startPoint.x + deltaX.x + deltaY.x,startPoint.y + deltaX.y + deltaY.y);
         graphics.lineTo(startPoint.x + deltaY.x,startPoint.y + deltaY.y);
         graphics.lineTo(startPoint.x,startPoint.y);
      }
      
      override public function loadObject(data:Object) : void
      {
         var maxFarmSize:Number;
         var tileType:String;
         var terrainSizeX:uint = 0;
         var terrainSizeY:uint = 0;
         var terrainPoints:Array = null;
         var arraySize:int = 0;
         var udtMap:UDTMap = null;
         this.stopAll();
         this.m_isLoading = true;
         LoadingManager.getInstance().addEventListener(LoaderEvent.LOAD_QUEUE_EMPTY,this.onLoadingMangerQueueEmpty);
         maxFarmSize = Global.farmGameSettingsManager.getInt("maxFarmSize",114);
         if(data.sizeX > maxFarmSize || data.sizeY > maxFarmSize)
         {
            data.sizeX = maxFarmSize;
            data.sizeY = maxFarmSize;
         }
         if(data.maxNumObjects)
         {
            this.m_maxNumObjects = data.maxNumObjects;
         }
         else
         {
            this.m_maxNumObjects = Global.farmGameSettingsManager.getInt("maxNumObjects",5000);
         }
         data.objects = data.objectsArray.concat();
         data.objectsArray = null;
         tileType = YimfManager.DEFAULT_TYPE;
         if(data.tileSet != null && data.tileSet != "")
         {
            tileType = data.tileSet;
         }
         if(data.terrain)
         {
            terrainSizeX = data.sizeX / TerrainUtil.TERRAIN_SCALE_FACTOR;
            terrainSizeY = data.sizeY / TerrainUtil.TERRAIN_SCALE_FACTOR;
            terrainPoints = null;
            arraySize = terrainSizeX * terrainSizeY;
            if(data.terrain is Array)
            {
               terrainPoints = data.terrain;
               if(terrainPoints.length != arraySize)
               {
                  throw new Error("Terrain Mapping Size Array Fatal Error. Expecting " + arraySize + " but received " + terrainPoints.length);
               }
            }
            else
            {
               terrainPoints = data.terrain as Array;
            }
            if(TerrainUtil.isDevTerrainMappingCreationToolAvailable())
            {
               udtMap = new UDTMap();
               udtMap.loadObject(terrainPoints,terrainSizeX,terrainSizeY);
               m_terrain = udtMap;
            }
            else
            {
               m_terrain = new InvisibleTerrainMap(terrainPoints,terrainSizeX,terrainSizeY);
            }
         }
         else
         {
            m_terrain = new YimfMap(data.sizeX,data.sizeY,tileType,true);
         }
         if(data.serializedExtraItemFlags)
         {
            this.m_extraItemFlags = new BitFlagsById(data.serializedExtraItemFlags);
         }
         try
         {
            super.loadObject(data);
         }
         catch(error:Error)
         {
            WorldManager.trackFastTravelStat("clientException","FarmGameWorld-loadObject-super-loadObject",Global.worldManager.currentWorldType,error.message);
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_WORLD_LOAD_BATCH) == 0)
         {
            this.completeWorldLoad(data);
         }
      }
      
      override protected function loadWorldObjects(data:Object) : void
      {
         var batchTime:int = 0;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_WORLD_LOAD_BATCH) > 0)
         {
            batchTime = 7500;
            if(Global.flashHotParams["WORLD_LOAD_BATCH_TIME_TMPRT"])
            {
               batchTime = int(Global.flashHotParams["WORLD_LOAD_BATCH_TIME_TMPRT"]);
            }
            this.m_worldObjectBatchLoader = new WorldObjectBatchLoader(data,batchTime,this);
            this.loadWorldObjectBatch();
         }
         else
         {
            super.loadWorldObjects(data);
         }
      }
      
      private function loadWorldObjectBatch() : void
      {
         var isFinished:Boolean = false;
         var data:Object = null;
         if(this.m_worldObjectBatchLoader)
         {
            isFinished = this.m_worldObjectBatchLoader.loadWorldObjectBatch();
            if(isFinished)
            {
               data = this.m_worldObjectBatchLoader.getWorldData();
               this.m_worldObjectBatchLoader.cleanUp();
               this.m_worldObjectBatchLoader = null;
               this.completeWorldLoad(data);
            }
         }
      }
      
      private function completeWorldLoad(data:Object) : void
      {
         var origin:Vector2 = null;
         var config:Yimf = null;
         if(m_terrain is FarmTerrainMap)
         {
            origin = IsoMath.tilePosToPixelPos(0,0,0,true);
            (m_terrain as FarmTerrainMap).setOriginPosition(origin);
         }
         DLManager.startLoading();
         LoadingManager.getInstance().setWorldAssetsRequested();
         this.getFarmTileMap().getFarmBackgroundRenderer().outsideOverlay = data.outsideOverlay;
         var tileType:String = YimfManager.DEFAULT_TYPE;
         if(data.tileSet != null && data.tileSet != "")
         {
            config = YimfManager.getInstance().getYimfConfig(data.tileSet);
            if(config.correspondingTheme == null)
            {
               tileType = data.tileSet;
            }
            else
            {
               tileType = config.correspondingTheme;
            }
         }
         this.setBackgroundTileAndColor(tileType);
         m_collisionMap.setTerrain(m_terrain);
         this.initPlotLimitCounts();
         this.setDefaultGameMode();
         this.initializeExpansionAreaItems();
         WorldScoreManager.onWorldLoaded();
      }
      
      public function addTimedActionToQueue(action:TimedAction) : void
      {
         this.m_timedActionPriorityQueue.push(action);
      }
      
      override public function detach(worldObj:WorldObject) : void
      {
         this.clearAreaOfEffect(worldObj as MapResource,true);
         super.detach(worldObj);
      }
      
      private function initPlotLimitCounts() : void
      {
         var code:int = 0;
         var plot:WorldObject = null;
         var terrainCodes:Array = null;
         var terrainCodesByLimitIndex:Array = null;
         var limitGroupIndex:String = null;
         this.m_plotLimitCounts = new Array();
         var allPlots:Array = getObjectsByType(WorldObjectTypes.PLOT);
         for each(plot in allPlots)
         {
            if(plot is ItemInstance)
            {
               terrainCodes = TerrainUtil.getTerrainCodesForItemInstance(plot as ItemInstance);
               terrainCodesByLimitIndex = Global.worldManager.convertTerrainCodesToCodesByLimitIndex(terrainCodes);
               for(limitGroupIndex in terrainCodesByLimitIndex)
               {
                  this.incrementPlotCount(terrainCodesByLimitIndex[limitGroupIndex]);
               }
            }
         }
      }
      
      public function getFarmTileMap() : FarmTileMap
      {
         return m_tileMap as FarmTileMap;
      }
      
      public function get numPlots() : int
      {
         var numPlotsOfType:int = 0;
         var total:int = 0;
         for each(numPlotsOfType in this.m_plotLimitCounts)
         {
            total += numPlotsOfType;
         }
         return total;
      }
      
      protected function onLoadingMangerQueueEmpty(event:LoaderEvent) : void
      {
         LoadingManager.getInstance().removeEventListener(LoaderEvent.LOAD_QUEUE_EMPTY,this.onLoadingMangerQueueEmpty);
         this.m_isLoading = false;
         DefconManager.refresh();
      }
      
      override public function initialize() : void
      {
         super.initialize();
         m_tileMap.setTerrain(m_terrain);
         this.m_initializedPlusFrame = false;
         InitializationManager.getInstance().addEventListener(Event.COMPLETE,this.onGameInitComplete);
         this.setDefaultGameMode();
         if(GlobalEngine.socialNetwork)
         {
            GlobalEngine.socialNetwork.addEventListener(SocialNetworkEvent.GET_FRIENDS_COMPLETE,this.onGetFriends);
         }
         if(this.m_lotSprite == null)
         {
            this.createLotBG(true);
         }
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function setBackgroundTileAndColor(tileSet:String) : void
      {
         this.getFarmTileMap().setBackgroundTileAndColor(tileSet);
         this.createLotBG(true);
         GlobalEngine.viewport.setDirty();
      }
      
      public function setBackground(url:String) : void
      {
         this.getFarmTileMap().setBackground(url);
         this.createLotBG(true);
         GlobalEngine.viewport.setDirty();
      }
      
      public function setHorizon(url:String) : void
      {
         this.getFarmTileMap().setHorizon(url);
         this.createLotBG(true);
         GlobalEngine.viewport.setDirty();
      }
      
      override protected function createObjectInstance(data:Object) : WorldObject
      {
         var className:String = null;
         var itemName:String = null;
         var SavedObjectClassType:Class = null;
         var instance:WorldObject = null;
         try
         {
            className = data.className;
            itemName = data.itemName;
            SavedObjectClassType = FarmItem.getMapResourceClassByType(data.type,data.className);
            if(itemName != null)
            {
               instance = new SavedObjectClassType(itemName);
            }
            else
            {
               instance = new SavedObjectClassType();
            }
         }
         catch(e:ReferenceError)
         {
            ErrorManager.addError("Type is not found " + className,ErrorManager.ERROR_REMOTEOBJECT_FAULT);
         }
         return instance;
      }
      
      public function getObjectsByName(itemName:String) : Array
      {
         var worldObj:ItemInstance = null;
         var results:Array = new Array();
         var objects:Array = getObjects();
         var objIdx:int = 0;
         var objLen:uint = objects.length;
         while(objIdx < objLen)
         {
            worldObj = objects[objIdx] as ItemInstance;
            if(worldObj != null && worldObj.getItem() != null && worldObj.getItem().name == itemName)
            {
               results.push(worldObj);
            }
            objIdx++;
         }
         return results;
      }
      
      public function getObjectsByCode(itemCode:String) : Array
      {
         var worldObj:ItemInstance = null;
         var results:Array = new Array();
         var objects:Array = getObjects();
         var objIdx:int = 0;
         var objLen:uint = objects.length;
         while(objIdx < objLen)
         {
            worldObj = objects[objIdx] as ItemInstance;
            if(worldObj != null && worldObj.getItem() != null && worldObj.getItem().code == itemCode)
            {
               results.push(worldObj);
            }
            objIdx++;
         }
         return results;
      }
      
      public function isOverBuildingNameTypeLimit(buildingName:String, limit:int) : Boolean
      {
         var result:Boolean = false;
         var buildingsCount:int = 0;
         var objects:Array = getObjects();
         var objLength:int = int(objects.length);
         var worldObj:ItemInstance = null;
         var farmItem:FarmItem = null;
         var buildingItem:BuildingItem = null;
         for(var objIdx:int = 0; objIdx < objLength; objIdx++)
         {
            worldObj = objects[objIdx] as ItemInstance;
            if(worldObj != null)
            {
               farmItem = worldObj.getItem();
               if(farmItem != null && farmItem.type == "building" && farmItem is BuildingItem)
               {
                  buildingItem = farmItem as BuildingItem;
                  if(buildingItem.buildingName == buildingName)
                  {
                     if(++buildingsCount >= limit)
                     {
                        result = true;
                        break;
                     }
                  }
               }
            }
         }
         return result;
      }
      
      public function getStorageBuildings(buildingName:String, itemName:String) : Array
      {
         var building:ItemInstance = null;
         var buildingItem:FarmItem = null;
         var storageItemClass:String = null;
         var storageItemNames:Array = null;
         var result:Array = new Array();
         var buildings:Array = this.getObjectsByName(buildingName);
         for each(building in buildings)
         {
            buildingItem = building.getItem();
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               storageItemClass = buildingItem.getStringFromDataSource("storageType","additionalItemClass");
            }
            else
            {
               storageItemClass = buildingItem.xml.storageType.@additionalItemClass;
            }
            storageItemNames = Global.storageSettings.getStorageItemNames(buildingItem.storageClass,storageItemClass);
            if(storageItemNames.indexOf(itemName) >= 0)
            {
               result.push(building);
            }
         }
         return result;
      }
      
      private function updateTagMatrix() : void
      {
         var zoom:Number = Math.min(GlobalEngine.viewport.getZoom(),1);
         this.m_tagMatrix.identity();
         this.m_tagMatrix.scale(zoom,zoom);
      }
      
      public function attachTagsToItems(tagImageUrl:String, filter:Function = null, autoRemove:Boolean = false) : int
      {
         var hashedTagUrl:String = null;
         var objs:Array = null;
         var inst:ItemInstance = null;
         var item:FarmItem = null;
         var objIdx:int = 0;
         var objLen:uint = 0;
         var count:int = 0;
         if(!tagImageUrl)
         {
            ErrorManager.addError("tagImageUrl missing in FarmGameWorld#attachTagsToItems");
         }
         else
         {
            hashedTagUrl = Global.getAssetURL(tagImageUrl);
            if(!this.m_tagLoader || this.m_tagLoader.url != hashedTagUrl)
            {
               this.m_tagLoader = ImageLoader.getInstance(hashedTagUrl,true);
            }
            this.updateTagMatrix();
            objs = getObjects();
            ArrayUtil.randomize(objs);
            objIdx = 0;
            objLen = objs.length;
            while(objIdx < objLen)
            {
               inst = objs[objIdx] as ItemInstance;
               if(inst)
               {
                  item = inst.getItem();
                  if(Boolean(item) && (Boolean(filter === null) || Boolean(filter(item))))
                  {
                     this.m_tagLoader.getContent(ZCacheUtil.applyPartial(this.onTagImageLoaded,this,[inst]));
                     count++;
                  }
               }
               objIdx++;
            }
            if(count > 0)
            {
               if(!this.m_tagsLayer.parent)
               {
                  GlobalEngine.viewport.hudBase.addChild(this.m_tagsLayer);
               }
               if(autoRemove)
               {
                  TweenLite.delayedCall(LE_TAG_LIFETIME,this.removeTagsFromItems,[true]);
               }
            }
         }
         return count;
      }
      
      protected function onTagImageLoaded(itemInst:ItemInstance, tag:DisplayObject) : void
      {
         if(Boolean(itemInst) && Boolean(tag))
         {
            itemInst.tag = tag;
            tag.alpha = 0;
            this.m_tagsLayer.addChild(tag);
            this.positionTagOverItem(tag,itemInst);
            TweenLite.to(tag,LE_TAG_FADE_DURATION,{
               "alpha":1,
               "delay":Math.random() / 2
            });
         }
      }
      
      public function positionTagOverItem(tag:DisplayObject, itemInst:ItemInstance) : void
      {
         tag.transform.matrix = this.m_tagMatrix.clone();
         var itemPos:Vector3 = itemInst.getPosition();
         var screenPos:Point = IsoMath.tilePosToPixelPos(itemPos.x,itemPos.y);
         var itemSz:Vector2 = itemInst.getActualDisplayObjectSize();
         screenPos.y -= itemSz.y;
         screenPos = IsoMath.viewportToStage(screenPos);
         if(tag.x != screenPos.x || tag.y != screenPos.y)
         {
            tag.x = screenPos.x;
            tag.y = screenPos.y;
         }
      }
      
      public function removeTagsFromItems(animate:Boolean = false) : void
      {
         var objs:Array = null;
         var inst:ItemInstance = null;
         var objIdx:int = 0;
         var objLen:uint = 0;
         var tags:Array = null;
         if(this.m_tagsLayer.parent)
         {
            objs = getObjects();
            if(animate)
            {
               tags = new Array();
               objIdx = 0;
               objLen = objs.length;
               while(objIdx < objLen)
               {
                  inst = objs[objIdx] as ItemInstance;
                  if(Boolean(inst) && Boolean(inst.tag))
                  {
                     tags.push(inst.tag);
                  }
                  objIdx++;
               }
               ArrayUtil.randomize(tags);
               TweenMax.allTo(tags,LE_TAG_FADE_DURATION,{
                  "y":"10",
                  "alpha":0
               },0.02,this.removeTagsFromItems,[false]);
            }
            else
            {
               objIdx = 0;
               objLen = objs.length;
               while(objIdx < objLen)
               {
                  inst = objs[objIdx] as ItemInstance;
                  if(Boolean(inst) && Boolean(inst.tag))
                  {
                     inst.tag = null;
                  }
                  objIdx++;
               }
               Utilities.removeAllChildren(this.m_tagsLayer);
               this.m_tagsLayer.parent.removeChild(this.m_tagsLayer);
            }
         }
      }
      
      override public function updateWorld(updateVisibleObjectsOnly:Boolean = false) : void
      {
         var action:TimedAction = null;
         super.updateWorld(true);
         this.loadWorldObjectBatch();
         if(!this.m_initializedPlusFrame)
         {
            this.registerSecondFrame();
         }
         this.updateAnimations();
         this.monitorPerformance();
         IdleTaskQueue.getInstance().checkTasks();
         Global.player.update();
         Global.popupManager.update();
         if(Global.animationState == Global.ANIMATION_STATE_PLAY)
         {
            if(this.shouldPlayMapResources)
            {
               this.playRandomMapResources();
            }
         }
         var aoeSources:Array = null;
         if(!Global.player.getSeenSessionFlag(Global.worldManager.currentWorldType + "AOESTATECHANGE_ADDEDTOQUEUE"))
         {
            aoeSources = AOEManager.getInstance().getAOEStateChangeSources();
            if(aoeSources != null && aoeSources.length > 0)
            {
               AOEManager.getInstance().addAOETasksToQueue();
               Global.player.setSeenSessionFlag(Global.worldManager.currentWorldType + "AOESTATECHANGE_ADDEDTOQUEUE");
            }
         }
         if(this.m_timedActionPriorityQueue != null && this.m_timedActionPriorityQueue.length > 0 && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_TIMED_ACTION_QUEUE) == 1)
         {
            action = this.m_timedActionPriorityQueue.shift() as TimedAction;
            action.perform();
         }
      }
      
      override public function updateCulling() : void
      {
         var inst:ItemInstance = null;
         super.updateCulling();
         this.updateTagMatrix();
         var objs:Array = getObjects();
         var objIdx:int = 0;
         var objLen:uint = objs.length;
         while(objIdx < objLen)
         {
            inst = objs[objIdx] as ItemInstance;
            if(Boolean(inst) && Boolean(inst.tag))
            {
               this.positionTagOverItem(inst.tag,inst);
            }
            objIdx++;
         }
      }
      
      public function updateFrozen() : void
      {
         if(m_perfTracking)
         {
            this.trackPerf();
         }
      }
      
      protected function registerSecondFrame() : void
      {
         this.m_initializedPlusFrame = true;
         UI.pumpPopupQueue();
         UI.displayPendingHoverWindows();
      }
      
      protected function updateAnimations() : void
      {
         var now:int = 0;
         var delta:int = 0;
         var objects:Array = null;
         var isAvatarUpdated:Boolean = false;
         var objIdx:int = 0;
         var objLen:uint = 0;
         var obj:FarmGameObject = null;
         if(m_initialized)
         {
            now = GlobalEngine.currentTime;
            delta = now - this.m_lastAnimationUpdate;
            objects = getVisibleObjects();
            isAvatarUpdated = false;
            objects = this.arrayRemove(objects,"BackgroundAnimationDecoMapTrigger");
            objIdx = 0;
            objLen = objects.length;
            while(objIdx < objLen)
            {
               obj = objects[objIdx] as FarmGameObject;
               if(obj)
               {
                  obj.updateAnimation(delta);
                  if(obj == Global.selectedAvatar)
                  {
                     isAvatarUpdated = true;
                  }
               }
               objIdx++;
            }
            if(!isAvatarUpdated && Boolean(Global.selectedAvatar))
            {
               Global.selectedAvatar.updateAnimation(delta);
            }
            this.m_lastAnimationUpdate = now;
         }
      }
      
      internal function arrayRemove(arr:*, value:*) : *
      {
         return arr.filter(function(ele:*):*
         {
            if(ele.getClassName() != null)
            {
               return ele.getClassName() != value;
            }
         });
      }
      
      public function cleanup() : void
      {
         var obj:WorldObject = null;
         var objects:Array = getObjects();
         var objIdx:int = 0;
         var objLen:uint = objects.length;
         while(objIdx < objLen)
         {
            obj = objects[objIdx] as WorldObject;
            if(obj)
            {
               obj.cleanup();
            }
            objIdx++;
         }
      }
      
      protected function monitorPerformance() : void
      {
         var timeDelta:Number = NaN;
         ++this.m_frameCount;
         DefconManager.checkThrottling(GlobalEngine.currentTime);
         if(GlobalEngine.currentTime >= this.m_lastUpdate + FPS_UPDATE_INTERVAL)
         {
            timeDelta = GlobalEngine.currentTime - this.m_lastUpdate;
            this.m_lastUpdate = GlobalEngine.currentTime;
            if(!PerformanceExperimentManager.isInDefconHideExperiment || !DefconManager.isThrottled)
            {
               DefconManager.checkPerformance(int(Number(this.m_frameCount) * 1000 / timeDelta + 0.5));
            }
            this.m_frameCount = 0;
         }
      }
      
      public function pauseEffects() : void
      {
         var resource:MapResource = null;
         Global.playOverlayEffects = false;
         var objects:Array = Global.world.getObjects();
         var objIdx:int = 0;
         var objLen:uint = objects.length;
         while(objIdx < objLen)
         {
            resource = objects[objIdx] as MapResource;
            if(resource)
            {
               resource.pauseEffect();
            }
            objIdx++;
         }
      }
      
      public function playEffects() : void
      {
         var resource:MapResource = null;
         Global.playOverlayEffects = true;
         var objects:Array = Global.world.getObjects();
         var objIdx:int = 0;
         var objLen:uint = objects.length;
         while(objIdx < objLen)
         {
            resource = objects[objIdx] as MapResource;
            if(resource)
            {
               resource.playEffect();
            }
            objIdx++;
         }
      }
      
      public function idleAll() : void
      {
         var resource:MapResource = null;
         var objects:Array = Global.world.getObjects();
         var objIdx:int = 0;
         var objLen:uint = objects.length;
         while(objIdx < objLen)
         {
            resource = objects[objIdx] as MapResource;
            if(resource)
            {
               resource.idle();
            }
            objIdx++;
         }
      }
      
      public function playAll() : void
      {
         Global.animationState = Global.ANIMATION_STATE_PLAY;
         this.idleAll();
         this.playRandomMapResources(this.m_resourcesPlayingBeforeDrag);
      }
      
      public function pauseAll() : void
      {
         var resource:MapResource = null;
         Global.animationState = Global.ANIMATION_STATE_PAUSE;
         var objects:Array = Global.world.getObjects();
         var objIdx:int = 0;
         var objLen:uint = objects.length;
         while(objIdx < objLen)
         {
            resource = objects[objIdx] as MapResource;
            if(resource)
            {
               resource.pause();
            }
            objIdx++;
         }
         this.clearPlayingMapResources();
      }
      
      public function stopAll() : void
      {
         var resource:MapResource = null;
         Global.animationState = Global.ANIMATION_STATE_STOP;
         var objects:Array = Global.world.getObjects();
         var objIdx:int = 0;
         var objLen:uint = objects.length;
         while(objIdx < objLen)
         {
            resource = objects[objIdx] as MapResource;
            if(resource)
            {
               resource.stop();
            }
            objIdx++;
         }
         this.clearPlayingMapResources();
      }
      
      public function get isAnimationStateLocked() : Boolean
      {
         return this.m_isLoading || this.m_isDragging;
      }
      
      public function set maxAnimations(value:int) : void
      {
         this.m_maxAnimations = value;
      }
      
      public function get numPlayingMapResources() : int
      {
         return this.m_numControlledPlayingMapResources + this.m_numUncontrolledMapResources;
      }
      
      protected function get animationStartInterval() : int
      {
         if(this.m_animationStartInterval < 0)
         {
            if(Global.flashHotParams.hasOwnProperty(HOTPARAM_ANIMATION_START_INTERVAL))
            {
               this.m_animationStartInterval = int(Global.flashHotParams[HOTPARAM_ANIMATION_START_INTERVAL]);
            }
            else
            {
               this.m_animationStartInterval = 0;
            }
         }
         return this.m_animationStartInterval;
      }
      
      public function get shouldPlayMapResources() : Boolean
      {
         return this.numPlayingMapResources < this.m_maxAnimations;
      }
      
      protected function refreshPlayableMapResources() : void
      {
         var objects:Array = null;
         var objIdx:int = 0;
         var objLen:int = 0;
         var resource:MapResource = null;
         if(this.m_timePlayableMapResourcesRefreshed < GlobalEngine.currentTime)
         {
            this.m_numUncontrolledMapResources = 0;
            this.m_timePlayableMapResourcesRefreshed = GlobalEngine.currentTime;
            this.m_playableMapResources = [];
            this.m_animationMapResources = [];
            objects = getVisibleObjects();
            objects = this.arrayRemove(objects,"BackgroundAnimationDecoMapTrigger");
            objIdx = 0;
            objLen = int(objects.length);
            while(objIdx < objLen)
            {
               resource = objects[objIdx] as MapResource;
               if(Boolean(resource) && resource.canPlay())
               {
                  if(resource.obeysAnimationTracking)
                  {
                     this.m_playableMapResources.push(resource);
                  }
                  else
                  {
                     ++this.m_numUncontrolledMapResources;
                  }
               }
               if(PerformanceExperimentManager.isInRasterMetadataExperiment && Global.ui.performanceHudEnabled)
               {
                  if(Boolean(resource) && Boolean(resource.isVisible()) && resource.hasAnimation)
                  {
                     this.m_animationMapResources.push(resource);
                  }
               }
               objIdx++;
            }
         }
      }
      
      protected function playRandomMapResources(highPriorityResources:Array = null) : void
      {
         var resource:MapResource = null;
         var idx:int = 0;
         var len:int = 0;
         var tryHighPriority:Boolean = false;
         if(Global.animationState == Global.ANIMATION_STATE_PLAY)
         {
            if(this.shouldPlayMapResources)
            {
               tryHighPriority = highPriorityResources != null && highPriorityResources.length > 0;
               if(tryHighPriority)
               {
                  idx = 0;
                  len = int(highPriorityResources.length);
                  while(this.shouldPlayMapResources && idx < len)
                  {
                     resource = highPriorityResources[idx];
                     this.playMapResource(resource);
                     idx++;
                  }
               }
               if(!tryHighPriority || this.shouldPlayMapResources)
               {
                  this.refreshPlayableMapResources();
                  ArrayUtil.randomize(this.m_playableMapResources);
                  len = int(this.m_playableMapResources.length);
                  if(len > 0)
                  {
                     if(GlobalEngine.currentTime > this.m_timeLastAnimationStarted + this.animationStartInterval)
                     {
                        for(idx = 0; idx < len; idx++)
                        {
                           resource = this.m_playableMapResources[idx] as MapResource;
                           if(this.playMapResource(resource))
                           {
                              break;
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      
      private function playMapResource(resource:MapResource) : Boolean
      {
         var result:Boolean = false;
         if(resource)
         {
            result = resource.play();
            this.m_playingMapResources[resource.getId()] = resource;
            ++this.m_numControlledPlayingMapResources;
            this.m_timeLastAnimationStarted = GlobalEngine.currentTime;
         }
         return result;
      }
      
      private function removePlayingMapResource(resource:MapResource) : void
      {
         if(this.m_playingMapResources.hasOwnProperty(String(resource.getId())))
         {
            delete this.m_playingMapResources[resource.getId()];
            --this.m_numControlledPlayingMapResources;
         }
      }
      
      private function clearPlayingMapResources() : void
      {
         this.m_numControlledPlayingMapResources = 0;
         this.m_playingMapResources = {};
      }
      
      public function onMapResourcePlayComplete(resource:MapResource) : void
      {
         this.removePlayingMapResource(resource);
      }
      
      public function getMapResourceContentTypes() : Array
      {
         var resource:MapResource = null;
         var resources:Array = [0,0,0,0,0];
         this.refreshPlayableMapResources();
         resources[0] = this.m_animationMapResources.length;
         for each(resource in this.m_animationMapResources)
         {
            resources[resource.typeOfAnimation()] = resources[resource.typeOfAnimation()] + 1;
         }
         return resources;
      }
      
      public function onDragStart() : void
      {
         var resource:MapResource = null;
         this.m_isDragging = true;
         if(Global.animationState == Global.ANIMATION_STATE_PLAY)
         {
            this.m_resourcesPlayingBeforeDrag = [];
            for each(resource in this.m_playingMapResources)
            {
               this.m_resourcesPlayingBeforeDrag.push(resource);
            }
            this.pauseAll();
         }
      }
      
      public function onDragStop() : void
      {
         this.m_isDragging = false;
         DefconManager.refresh();
         this.m_resourcesPlayingBeforeDrag = null;
      }
      
      protected function onGameInitComplete(event:Event) : void
      {
         this.createLotBG();
         Global.postInitActions.execute();
         this.removeEventListener(Event.COMPLETE,this.onGameInitComplete);
      }
      
      public function displayAvatarCustomizationScreen(oldWindow:Boolean = true, marketItem:XML = null, item:FarmItem = null) : void
      {
         var showCancel:Boolean = false;
         var subCategory:String = null;
         var previewItemId:String = null;
         var avatar:FarmAvatar = null;
         if(Boolean(Global.player) && Boolean(Global.player.avatar))
         {
            avatar = Global.player.avatar;
         }
         var newAvatar:Boolean = false;
         if(Global.player.avatar)
         {
            showCancel = true;
         }
         else
         {
            showCancel = false;
            newAvatar = true;
         }
         if(oldWindow)
         {
            this.customizationUI = new CustomizeAvatar(showCancel);
            this.customizationUI.addEventListener(SaveAvatarEvent.SAVE,this.onCustomizationScreenSave);
            this.customizationUI.show();
            this.customizationUI.newAvatar = newAvatar;
         }
         else if(marketItem == null && item == null)
         {
            if(Global.player.avatarState.inventoryInitialized)
            {
               UI.displayPopup(new AvatarEditorWindow(avatar),false);
            }
         }
         else
         {
            subCategory = item ? item.subType : marketItem.@subtype;
            previewItemId = item ? item.code : marketItem.@code;
            if(Global.player.avatarState.inventoryInitialized)
            {
               UI.displayPopup(new AvatarEditorWindow(avatar,AvatarEditorWindow.CATEGORY_CLOTHING,subCategory,previewItemId),false);
            }
         }
         if(newAvatar)
         {
            FarmStatsManager.count("avatar_new","displayAvatarCustomization");
         }
         else
         {
            FarmStatsManager.count("avatar_modify","displayAvatarCustomization");
         }
      }
      
      protected function onCustomizationScreenSave(ev:SaveAvatarEvent) : void
      {
         var gender:String = null;
         var createdAvatar:FarmAvatar = null;
         if(this.customizationUI.newAvatar)
         {
            FarmStatsManager.count("avatar_new","saveAvatarEvent");
         }
         else
         {
            FarmStatsManager.count("avatar_modify","saveAvatarEvent");
         }
         if(ev.customizationData)
         {
            gender = ev.gender == SimpleNPC.GENDER_MALE ? AvatarConfigSettings.GENDER_MALE : AvatarConfigSettings.GENDER_FEMALE;
            createdAvatar = new FarmAvatar(ev.customizationData,gender);
            this.saveAvatar(createdAvatar);
         }
         this.removeEventListener(SaveAvatarEvent.SAVE,this.onCustomizationScreenSave);
      }
      
      public function generateDefaultAvatar(gender:String = "female") : void
      {
         var createdAvatar:FarmAvatar = new FarmAvatar(FarmAvatar.getDefaultAvatarCustomizationData(gender));
         this.saveAvatar(createdAvatar);
      }
      
      protected function saveAvatar(avatar:FarmAvatar) : void
      {
         var avatarPos:Vector3 = null;
         if(Global.player)
         {
            if(!Global.player.avatar)
            {
               this.addPlayerAvatar(avatar);
               StatsManager.milestone("avatar_feed");
               FarmStatsManager.count("avatar","create_avatar");
               if(!Global.worldManager.isVisiting())
               {
                  this.addGameMode(new GMDefault());
               }
               this.onAvatarFeedClosed();
            }
            else
            {
               avatarPos = Global.player.avatar.getPosition();
               Global.player.avatar.detach();
               this.addPlayerAvatar(avatar,avatarPos);
            }
            Global.player.avatar = Global.selectedAvatar = avatar;
            AvatarManager.saveAvatar();
         }
      }
      
      public function growAllPlots() : void
      {
         var plot:Plot = null;
         var plots:Array = this.getObjectsByClass(Plot);
         for(var plotIdx:int = 0; plotIdx < plots.length; plotIdx++)
         {
            plot = plots[plotIdx] as Plot;
            if(plot.isWithered() || plot.isGrown())
            {
               plot.setFullGrown();
            }
         }
      }
      
      private function onAvatarFeedClosed() : void
      {
         TutController.createTutorial();
      }
      
      protected function onGetFriends(event:Event) : void
      {
         this.updateNeighborText();
         this.removeEventListener(SocialNetworkEvent.GET_FRIENDS_COMPLETE,this.onGetFriends);
      }
      
      protected function renderExpansionMarketingGrid() : void
      {
         var startPoint:Point = null;
         var endPoint:Point = null;
         var i:int = 0;
         var expansionDistance:int = 8;
         var plotWidth:int = 4;
         var gridWidth:int = getGridWidth();
         var gridHeight:int = getGridHeight();
         this.m_lotSprite.graphics.lineStyle(0.5,this.expansionOutlineColor,0.5);
         for(i = -1 * expansionDistance; i < 0; i += plotWidth)
         {
            startPoint = IsoMath.tilePosToPixelPos(i,gridHeight);
            endPoint = IsoMath.tilePosToPixelPos(i,-1 * expansionDistance);
            this.m_lotSprite.graphics.moveTo(startPoint.x,startPoint.y);
            this.m_lotSprite.graphics.lineTo(endPoint.x,endPoint.y);
            startPoint = IsoMath.tilePosToPixelPos(-1 * expansionDistance,i);
            endPoint = IsoMath.tilePosToPixelPos(gridWidth,i);
            this.m_lotSprite.graphics.moveTo(startPoint.x,startPoint.y);
            this.m_lotSprite.graphics.lineTo(endPoint.x,endPoint.y);
         }
         var deltaX:Vector2 = IsoMath.getPixelDeltaFromTileDelta(1,0);
         deltaX.x *= plotWidth;
         deltaX.y *= plotWidth;
         startPoint = IsoMath.tilePosToPixelPos(0,0);
         endPoint = IsoMath.tilePosToPixelPos(0,-1 * expansionDistance);
         for(i = plotWidth; i < gridWidth; i += plotWidth)
         {
            startPoint = startPoint.add(deltaX);
            endPoint = endPoint.add(deltaX);
            this.m_lotSprite.graphics.moveTo(startPoint.x,startPoint.y);
            this.m_lotSprite.graphics.lineTo(endPoint.x,endPoint.y);
         }
         var deltaY:Vector2 = IsoMath.getPixelDeltaFromTileDelta(0,1);
         deltaY.x *= plotWidth;
         deltaY.y *= plotWidth;
         startPoint = IsoMath.tilePosToPixelPos(0,0);
         endPoint = IsoMath.tilePosToPixelPos(-1 * expansionDistance,0);
         for(i = plotWidth; i < gridHeight; i += plotWidth)
         {
            startPoint = startPoint.add(deltaY);
            endPoint = endPoint.add(deltaY);
            this.m_lotSprite.graphics.moveTo(startPoint.x,startPoint.y);
            this.m_lotSprite.graphics.lineTo(endPoint.x,endPoint.y);
         }
      }
      
      public function onMarketClose(isBuy:Boolean = false) : void
      {
         var statsStr:String = isBuy ? "buy" : "dismiss";
         FarmStatsManager.count("Expansion_strip","user_eligible",this.getFarmSizeName(),statsStr);
         this.optionallyEnableExpansionMarketing();
      }
      
      public function optionallyEnableExpansionMarketing(trackStats:Boolean = false) : void
      {
         var maxFarmSize:Number = NaN;
         var availableArea:int = 0;
         var lastShown:Number = NaN;
         var featureFrequencyKey:String = null;
         var featureFrequency:Number = NaN;
         var currentTime:int = 0;
         var minFreeSpace:Number = NaN;
         var minFarmSize:Number = NaN;
         var seenFlagName:String = null;
         this.m_expansionMarketing = false;
         if(!Global.worldManager.isVisiting() || !Global.worldManager.isInStaticWorld())
         {
            maxFarmSize = Global.farmGameSettingsManager.getInt("maxFarmSize",106);
            availableArea = getGridWidth() * getGridHeight();
            if(availableArea < maxFarmSize * maxFarmSize)
            {
               if(Global.player.level >= Global.farmGameSettingsManager.getInt("expansionMarketingMinLevel",5))
               {
                  lastShown = Global.player.getFeatureLastShown("expansionMarketingClick");
                  featureFrequencyKey = "";
                  if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_EXPANSION_TEXT_TEST) == 2)
                  {
                     featureFrequencyKey = "expansionMarketingFrequencyShorter_" + Global.worldManager.currentWorldType;
                  }
                  else
                  {
                     featureFrequencyKey = "expansionMarketingFrequency_" + Global.worldManager.currentWorldType;
                  }
                  featureFrequency = Global.farmGameSettingsManager.getNumber(featureFrequencyKey,2592000);
                  currentTime = GlobalEngine.serverTime / 1000;
                  if(currentTime > lastShown + featureFrequency || Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_EXPANSION_TEXT_SKIP_TEST) > 0)
                  {
                     minFarmSize = Global.farmGameSettingsManager.getInt("farmSize",50);
                     if(availableArea > minFarmSize * minFarmSize || Global.worldManager.currentWorldType != WorldsConstants.WORLD_ID_HOME)
                     {
                        if(Global.flashHotParams["EXP_MKTG_PERCENT_SPACE"] != null)
                        {
                           minFreeSpace = Number(Global.flashHotParams["EXP_MKTG_PERCENT_SPACE"]);
                        }
                        else
                        {
                           minFreeSpace = Global.farmGameSettingsManager.getNumber("expansionMarketingMinFreeSpacePercentage",75) / 100;
                        }
                        minFreeSpace = Math.max(0,Math.min(1,minFreeSpace));
                        this.m_expansionMarketing = this.calculateOccupiedArea() / availableArea > 1 - minFreeSpace;
                        if(Global.worldManager.currentWorldType != WorldsConstants.WORLD_ID_HOME)
                        {
                           seenFlagName = "visitedWorld_" + Global.worldManager.currentWorldType;
                           if(Global.player.getSeenFlag(seenFlagName) == false)
                           {
                              this.m_expansionMarketing = false;
                              Global.player.setSeenFlag(seenFlagName);
                           }
                        }
                     }
                     else
                     {
                        this.m_expansionMarketing = true;
                     }
                     if(trackStats)
                     {
                        if(this.m_expansionMarketing)
                        {
                           FarmStatsManager.count("Expansion_strip","user_eligible",this.getFarmSizeName(),"not_enough_free_space");
                        }
                        else
                        {
                           FarmStatsManager.count("Expansion_strip","user_eligible",this.getFarmSizeName(),"enough_free_space");
                        }
                     }
                  }
                  else if(trackStats)
                  {
                     FarmStatsManager.count("Expansion_strip","user_eligible",this.getFarmSizeName(),"blackout_period");
                  }
               }
            }
         }
         this.createLotBG();
      }
      
      public function getFarmSizeName() : String
      {
         return getGridWidth().toString() + "x" + getGridHeight().toString();
      }
      
      protected function calculateOccupiedArea() : int
      {
         var object:MapResource = null;
         var objSize:Vector3 = null;
         var occupiedArea:int = 0;
         var objects:Array = getObjects();
         var objIdx:int = 0;
         var objLen:uint = objects.length;
         while(objIdx < objLen)
         {
            object = objects[objIdx] as MapResource;
            if(object)
            {
               objSize = object.getSizeNoClone();
               occupiedArea += objSize.x * objSize.y;
            }
            objIdx++;
         }
         return occupiedArea;
      }
      
      protected function resetLotSprite() : void
      {
         if(this.m_lotSprite != null && this.m_lotSprite.parent != null)
         {
            this.m_lotSprite.parent.removeChild(this.m_lotSprite);
         }
         this.m_lotSprite = new Sprite();
         GlobalEngine.viewport.overlayBase.addChildAt(this.m_lotSprite,0);
      }
      
      public function createLotBG(createOutline:Boolean = true, updateText:Boolean = true, disableExpansionMarketingText:Boolean = false) : void
      {
         var themeColor:uint = 0;
         var themeAlpha:Number = NaN;
         var delta:Vector2 = null;
         var deltaX:Vector2 = null;
         var deltaY:Vector2 = null;
         var bClear:Boolean = false;
         var currency:String = null;
         var arrExpansionItems:Array = null;
         var expansionItem:FarmItem = null;
         var drawExpansionMarketingGrid:Boolean = false;
         var offset:Number = NaN;
         var normalX:Point = null;
         var normalY:Point = null;
         this.resetLotSprite();
         var bottomPoint:Vector2 = IsoMath.tilePosToPixelPos(0,0);
         var leftPoint:Vector2 = IsoMath.tilePosToPixelPos(0,getGridHeight());
         var rightPoint:Vector2 = IsoMath.tilePosToPixelPos(getGridWidth(),0);
         var topPoint:Vector2 = IsoMath.tilePosToPixelPos(getGridWidth(),getGridHeight());
         var drawLotOutline:Boolean = this.getFarmTileMap().getFarmBackgroundRenderer().useLotOutline();
         if(createOutline && drawLotOutline)
         {
            themeColor = this.lotOutlineColor;
            themeAlpha = this.lotOutlineAlpha;
            delta = new Vector2(0,0);
            this.renderLotLine(this.m_lotSprite,topPoint,rightPoint,delta,themeColor,themeAlpha,false);
            this.renderLotLine(this.m_lotSprite,leftPoint,bottomPoint,delta,themeColor,themeAlpha,false);
            this.renderLotLine(this.m_lotSprite,bottomPoint,rightPoint,delta,themeColor,themeAlpha,true);
            this.renderLotLine(this.m_lotSprite,leftPoint,topPoint,delta,themeColor,themeAlpha,true);
         }
         if(updateText)
         {
            deltaX = IsoMath.getPixelDeltaFromTileDelta(-1,0);
            deltaY = IsoMath.getPixelDeltaFromTileDelta(0,1);
            if(null == this.m_lotTextBitmapDatas)
            {
               this.m_lotTextBitmapDatas = new Array(2);
               this.m_lotTextBitmaps = new Array(2);
            }
            bClear = true;
            if(!disableExpansionMarketingText && this.isEligibleForExpansionMarketingText())
            {
               currency = "";
               if(Global.farmGame.isAllHighPriorityLoadComplete())
               {
                  arrExpansionItems = Global.farmGameSettingsManager.getFarmItemsArray("landExpansion","expansion");
                  if(arrExpansionItems != null || arrExpansionItems.length > 0)
                  {
                     for each(expansionItem in arrExpansionItems)
                     {
                        if(expansionItem.buyableWithCurrency() && expansionItem.isInCoinExperiment)
                        {
                           if(expansionItem.buyableWithWorldCurrency())
                           {
                              currency = Global.worldManager.getCurrencyForWorld(Global.worldManager.currentWorldType);
                              break;
                           }
                           currency = "gold";
                        }
                        if(currency.length == 0 && expansionItem.buyableWithCash() && expansionItem.isInCashExperiment)
                        {
                           currency = "cash";
                        }
                     }
                  }
               }
               if(currency != "")
               {
                  drawExpansionMarketingGrid = this.getFarmTileMap().getFarmBackgroundRenderer().canShowExpansionMarketingGrid();
                  if(drawExpansionMarketingGrid)
                  {
                     this.renderExpansionMarketingGrid();
                  }
                  offset = 35;
                  normalX = deltaX.clone();
                  normalX.normalize(offset);
                  normalY = deltaY.clone();
                  normalY.normalize(offset);
                  this.renderLotText(Vector2.lerp(leftPoint,bottomPoint,0.5).add(normalX),this.expansionOutlineColor,false,0,true,currency);
                  this.renderLotText(Vector2.lerp(bottomPoint,rightPoint,0.5).subtract(normalY),this.expansionOutlineColor,true,1,true,currency);
                  bClear = false;
               }
            }
            if(bClear)
            {
               this.clearLotText(0);
               this.clearLotText(1);
            }
         }
      }
      
      private function isEligibleForExpansionMarketingText() : Boolean
      {
         return this.m_expansionMarketing && !Global.worldManager.isVisitingNPC() && !Global.worldManager.isVisiting() && !Global.worldManager.isInStaticWorld();
      }
      
      public function updateNeighborText() : void
      {
         this.createLotBG(false);
      }
      
      protected function getNeighborName(neighborIdx:int) : String
      {
         var result:String = null;
         neighborIdx = Global.friendManager.networkNeighborUids.length - neighborIdx - 1;
         if(Boolean(Global.player) && neighborIdx >= 0)
         {
            result = Global.friendManager.getFriendName(Global.friendManager.networkNeighborUids[neighborIdx],true);
         }
         return result;
      }
      
      public function addPlayerAvatar(avatar:FarmAvatar, position:Vector3 = null) : void
      {
         if(avatar)
         {
            Global.player.avatar = avatar;
            this.addAvatar(avatar,position);
         }
      }
      
      public function addAvatar(avatar:FarmAvatar, position:Vector3 = null) : void
      {
         var worldSpecificPosition:Vector3 = null;
         if(avatar)
         {
            avatar.setOuter(this);
            if(position == null)
            {
               worldSpecificPosition = this.getWorldSpecificAvatarPosition();
               if(worldSpecificPosition)
               {
                  position = worldSpecificPosition;
               }
               else
               {
                  position = this.getDefaultAvatarPosition();
               }
            }
            avatar.setPosition(position.x,position.y);
            avatar.attach();
         }
      }
      
      public function getWorldSpecificAvatarPosition() : Vector3
      {
         var currentSeasonNumber:int = WorldSeasonsManager.getInstance().getCurrentSeason(Global.worldManager.currentWorldType);
         var worldSpecificPosition:Point = Global.worldSettingsManager.getWorldSpecificAvatarPositionBySeason(currentSeasonNumber);
         var result:Vector3 = null;
         if(worldSpecificPosition)
         {
            result = this.getPathablePointRelativeToThePosition(worldSpecificPosition.x,worldSpecificPosition.y);
            if(result == null)
            {
               result = new Vector3(worldSpecificPosition.x,worldSpecificPosition.y);
            }
         }
         return result;
      }
      
      public function getDefaultAvatarPosition() : Vector3
      {
         var x:int = Math.floor(Global.world.getGridWidth() / 2);
         var y:int = Math.floor(Global.world.getGridHeight() / 2);
         var result:Vector3 = this.getPathablePointRelativeToThePosition(x,y);
         if(result == null)
         {
            result = new Vector3(x,y);
         }
         return result;
      }
      
      public function getPathablePointRelativeToThePosition(x:int, y:int) : Vector3
      {
         var count:int = 0;
         var i:int = 0;
         var result:Vector3 = null;
         if(!m_collisionMap.isPositionPathable(x,y))
         {
            count = 1;
            while(result == null && count < x && count < y)
            {
               i = -count;
               while(result == null && i <= count)
               {
                  result = this.checkAvatarPositionValid(x + i,y + count);
                  if(result == null)
                  {
                     result = this.checkAvatarPositionValid(x + i,y - count);
                  }
                  if(result == null)
                  {
                     result = this.checkAvatarPositionValid(x + count,y + i);
                  }
                  if(result == null)
                  {
                     result = this.checkAvatarPositionValid(x - count,y + i);
                  }
                  i++;
               }
               count++;
            }
         }
         else
         {
            result = new Vector3(x,y);
         }
         return result;
      }
      
      public function ispathable(x:int, y:int) : Boolean
      {
         return m_collisionMap.isPositionPathable(x,y);
      }
      
      private function checkAvatarPositionValid(x:int, y:int) : Vector3
      {
         var result:Vector3 = null;
         if(m_collisionMap.isPositionPathable(x,y))
         {
            result = new Vector3(x,y);
         }
         return result;
      }
      
      protected function clearLotText(neighborIndex:uint) : void
      {
         var bData:BitmapData = null;
         var bitmap:Bitmap = null;
         var sprite:Sprite = null;
         var imageDimension:int = 1;
         if(this.m_lotTextBitmapDatas != null)
         {
            if(null == this.m_lotTextBitmapDatas[neighborIndex])
            {
               this.m_lotTextBitmapDatas[neighborIndex] = new BitmapData(imageDimension,imageDimension,true,0);
            }
            bData = this.m_lotTextBitmapDatas[neighborIndex] as BitmapData;
            if(bData.width != imageDimension || bData.height != imageDimension)
            {
               bData.dispose();
               bData = this.m_lotTextBitmapDatas[neighborIndex] = new BitmapData(imageDimension,imageDimension,true,0);
               this.m_lotTextBitmaps[neighborIndex].parent.removeEventListener(MouseEvent.MOUSE_MOVE,this.lotTextMouseOverCallback);
               this.m_lotTextBitmaps[neighborIndex].parent.removeEventListener(MouseEvent.MOUSE_OUT,this.lotTextMouseOverCallback);
               this.m_lotTextBitmaps[neighborIndex] = null;
            }
            else
            {
               bData.fillRect(bData.rect,0);
            }
         }
         if(this.m_lotTextBitmaps != null)
         {
            if(null == this.m_lotTextBitmaps[neighborIndex])
            {
               bitmap = new Bitmap(bData,"auto",true);
               sprite = new Sprite();
               sprite.addChild(bitmap);
               GlobalEngine.viewport.overlayBase.addChild(sprite);
               this.m_lotTextBitmaps[neighborIndex] = bitmap;
            }
            else
            {
               (this.m_lotTextBitmaps[neighborIndex] as Bitmap).bitmapData = bData;
            }
         }
      }
      
      protected function renderLotText(basePoint:Point, themeColor:uint, horizontal:Boolean, neighborIndex:uint, expansionMarketing:Boolean = false, currency:String = "") : void
      {
         var lotText:String = null;
         var lotSubText:String = null;
         var textPadding:int = 0;
         var arrowGlowFilter:GlowFilter = null;
         var expandArrowClass:Class = null;
         var arrow:DisplayObject = null;
         var arrow2:DisplayObject = null;
         var textField2:StrokeTextField = null;
         var bitmap:Bitmap = null;
         var sprite:Sprite = null;
         var resource_fmt:TextFormat = new TextFormat();
         var fontSize:Number = 28;
         var lotTextScale:Number = 1;
         var lotTextStroke:int = 3;
         var lotTextClickCallback:Function = this.onNeighborTextClick;
         if(expansionMarketing)
         {
            if(currency != "" && currency != "cash" && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_EXPANSION_TEXT_TEST) == 2)
            {
               if(currency == "gold")
               {
                  currency = "Coins";
               }
               lotText = ZLocUtils.t("FarmGame","ExpandYouFarmNew" + currency);
            }
            else
            {
               lotText = ZLocUtils.t("FarmGame","ExpandYourFarm");
            }
            lotSubText = ZLocUtils.t("FarmGame","ClickHere");
            lotTextScale = 1;
            lotTextStroke = 5;
            lotTextClickCallback = this.onExpandTextClick;
            fontSize = 48;
         }
         else
         {
            lotText = this.getNeighborName(neighborIndex);
            if(lotText == null)
            {
               lotText = ZLocUtils.t("FarmGame","EmptyLot");
            }
            else
            {
               lotText = ZLocUtils.t("FarmGame","FriendLot",{"user":ZLocUtils.tn(lotText)});
            }
         }
         resource_fmt.font = "Merkin2";
         resource_fmt.size = fontSize;
         resource_fmt.color = this.chooseColorOfLotTextByWorld();
         var lotTextSprite:Sprite = new Sprite();
         var textField:StrokeTextField = new StrokeTextField(themeColor,0.8,lotTextStroke);
         textField.toolTipText = lotText;
         textField.setTextFormat(resource_fmt);
         textField.embedFonts = true;
         lotTextSprite.addChild(textField);
         if(expansionMarketing)
         {
            textPadding = 25;
            arrowGlowFilter = new GlowFilter(themeColor,1,lotTextStroke,lotTextStroke,200);
            expandArrowClass = this.chooseClassOfLotArrowsByWorld();
            arrow = new expandArrowClass() as DisplayObject;
            arrow2 = new expandArrowClass() as DisplayObject;
            arrow.filters = [arrowGlowFilter];
            arrow.scaleX = arrow.scaleY = 1;
            lotTextSprite.addChild(arrow);
            textField.x = arrow.width + textPadding;
            arrow2.filters = [arrowGlowFilter];
            arrow2.scaleX = arrow2.scaleY = 1;
            arrow2.x = textField.x + textField.width + textPadding;
            lotTextSprite.addChild(arrow2);
            textField2 = new StrokeTextField(0,0.1,2,128,true);
            resource_fmt.size = fontSize * 0.7;
            resource_fmt.color = this.chooseColorOfLotTextByWorld();
            textField2.htmlText = lotSubText;
            textField2.setTextFormat(resource_fmt);
            textField2.embedFonts = true;
            textField2.x = (lotTextSprite.width - textField2.width) / 2;
            textField2.y = textField.height;
            lotTextSprite.addChild(textField2);
         }
         var transformMat:Matrix = new Matrix();
         var angle:Number = Math.atan2(horizontal ? -6 : 6,12.5);
         transformMat.rotate(angle);
         transformMat.d = 0.25;
         lotTextSprite.transform.matrix = transformMat;
         lotTextSprite.scaleX = lotTextSprite.scaleY = lotTextScale;
         lotTextSprite.filters = [new GlowFilter(themeColor,0.05,10,10,200)];
         if(null == this.m_lotTextBitmapDatas[neighborIndex])
         {
            this.m_lotTextBitmapDatas[neighborIndex] = new BitmapData(lotTextSprite.width,lotTextSprite.height,true,0);
         }
         var bData:BitmapData = this.m_lotTextBitmapDatas[neighborIndex] as BitmapData;
         if(bData.width != int(lotTextSprite.width) || bData.height != int(lotTextSprite.height))
         {
            bData.dispose();
            bData = this.m_lotTextBitmapDatas[neighborIndex] = new BitmapData(lotTextSprite.width,lotTextSprite.height,true,0);
            this.m_lotTextBitmaps[neighborIndex] = null;
         }
         else
         {
            bData.fillRect(bData.rect,0);
         }
         var rect:Rectangle = lotTextSprite.getBounds(Global.stage);
         lotTextSprite.y -= rect.top;
         if(horizontal)
         {
            lotTextSprite.x -= rect.left;
         }
         else
         {
            lotTextSprite.x -= rect.right - lotTextSprite.width;
         }
         bData.draw(lotTextSprite,lotTextSprite.transform.matrix);
         transformMat = new Matrix();
         transformMat.scale(0.5,0.5);
         transformMat.translate(basePoint.x - bData.width * 0.25,basePoint.y - bData.height * 0.25);
         if(null == this.m_lotTextBitmaps[neighborIndex])
         {
            bitmap = new Bitmap(bData,"auto",true);
            bitmap.transform.matrix = transformMat;
            sprite = new Sprite();
            sprite.addChild(bitmap);
            sprite.addEventListener(MouseEvent.MOUSE_DOWN,lotTextClickCallback);
            sprite.addEventListener(MouseEvent.MOUSE_MOVE,this.lotTextMouseOverCallback);
            sprite.addEventListener(MouseEvent.MOUSE_OUT,this.lotTextMouseOverCallback);
            GlobalEngine.viewport.overlayBase.addChild(sprite);
            this.m_lotTextBitmaps[neighborIndex] = bitmap;
         }
         else
         {
            (this.m_lotTextBitmaps[neighborIndex] as Bitmap).bitmapData = bData;
            (this.m_lotTextBitmaps[neighborIndex] as Bitmap).transform.matrix = transformMat;
         }
      }
      
      protected function lotTextMouseOverCallback(event:MouseEvent) : void
      {
         var sprite:Sprite = event.currentTarget as Sprite;
         var bitmap:Bitmap = sprite.getChildAt(0) as Bitmap;
         if(this.isPixelInside(new Point(event.localX,event.localY),bitmap))
         {
            sprite.filters = [new GlowFilter(Constants.COLOR_HIGHLIGHT,1,4,4,200)];
            event.stopImmediatePropagation();
            event.stopPropagation();
         }
         else
         {
            sprite.filters = [];
         }
      }
      
      public function initializeExpansionAreaItems() : void
      {
         var nextExpansionItem:ChangeFarmItem = null;
         var nextSquareSize:int = 0;
         var diffX:Number = NaN;
         var diffY:Number = NaN;
         var addedItems:Array = null;
         var addedItemIdx:int = 0;
         var addedItemObj:Object = null;
         var mapTrigger:ExpansionAreaMapTrigger = null;
         if(!Global.worldManager.isVisiting())
         {
            nextExpansionItem = Global.worldManager.getNextExpansion();
            if(null != nextExpansionItem && nextExpansionItem.isVisible && Boolean(nextExpansionItem.squares))
            {
               nextSquareSize = nextExpansionItem.squares;
               diffX = getGridWidth() - nextSquareSize;
               diffY = getGridHeight() - nextSquareSize;
               addedItems = Global.farmGameSettingsManager.getFarmExpansionAddedItemsForWorldAndSize(Global.worldManager.currentWorldType,nextSquareSize);
               for(addedItemIdx = 0; addedItemIdx < addedItems.length; addedItemIdx++)
               {
                  addedItemObj = addedItems[addedItemIdx];
                  addedItemObj["itemName"] = Global.farmGameSettingsManager.getFarmItemNameByCode(addedItemObj["code"]);
                  mapTrigger = new ExpansionAreaMapTrigger(addedItemObj["itemName"],diffX,diffY);
                  mapTrigger.loadObject(addedItemObj);
               }
            }
         }
      }
      
      public function get maxNumObjects() : int
      {
         return this.m_maxNumObjects;
      }
      
      public function getNumPlots(terrainCode:int) : int
      {
         var limitIndex:int = 0;
         var result:int = 0;
         if(this.m_plotLimitCounts)
         {
            limitIndex = Global.worldManager.getLimitGroupIndexByTerrainCode(terrainCode);
            if(this.m_plotLimitCounts.hasOwnProperty(String(limitIndex)))
            {
               result = int(this.m_plotLimitCounts[limitIndex]);
            }
         }
         return result;
      }
      
      public function incrementPlotCount(terrainCode:int) : void
      {
         var limitIndex:int = Global.worldManager.getLimitGroupIndexByTerrainCode(terrainCode);
         if(!this.m_plotLimitCounts.hasOwnProperty(String(limitIndex)))
         {
            this.m_plotLimitCounts[limitIndex] = 1;
         }
         else
         {
            ++this.m_plotLimitCounts[limitIndex];
         }
      }
      
      public function incrementPlotCountArray(arrTerrainCodes:Array) : void
      {
         var limitIndex:String = null;
         var arrLimitIndex:Array = Global.worldManager.convertTerrainCodesToCodesByLimitIndex(arrTerrainCodes);
         for(limitIndex in arrLimitIndex)
         {
            if(!this.m_plotLimitCounts.hasOwnProperty(limitIndex))
            {
               this.m_plotLimitCounts[int(limitIndex)] = 1;
            }
            else
            {
               ++this.m_plotLimitCounts[int(limitIndex)];
            }
         }
      }
      
      public function decrementPlotCount(terrainCode:int) : void
      {
         var limitIndex:int = Global.worldManager.getLimitGroupIndexByTerrainCode(terrainCode);
         if(!(!this.m_plotLimitCounts.hasOwnProperty(String(limitIndex)) || this.m_plotLimitCounts[limitIndex] == 0))
         {
            --this.m_plotLimitCounts[limitIndex];
         }
      }
      
      public function incrementUserClicks() : void
      {
         ++this.m_numUserClicks;
      }
      
      public function get numUserClicks() : int
      {
         return this.m_numUserClicks;
      }
      
      public function incrementUserMoves() : void
      {
         ++this.m_numUserMoves;
      }
      
      public function get numUserMoves() : int
      {
         return this.m_numUserMoves;
      }
      
      public function resetUserClicks(resetByClick:Boolean) : void
      {
         if(resetByClick)
         {
            this.m_numUserClicks = -1;
         }
         else
         {
            this.m_numUserClicks = 0;
         }
      }
      
      protected function isPixelInside(pixel:Point, bitmap:Bitmap) : Boolean
      {
         var bData:BitmapData = bitmap.bitmapData;
         var localPixel:Point = pixel.subtract(new Point(bitmap.x,bitmap.y));
         localPixel.x /= bitmap.scaleX;
         localPixel.y /= bitmap.scaleY;
         return bData.hitTest(new Point(0,0),10,localPixel);
      }
      
      protected function onNeighborTextClick(event:MouseEvent) : void
      {
         var neighborIdx:int = 0;
         var origIdx:int = 0;
         var visitLotObj:DisplayObject = null;
         var visitMessage:String = null;
         var bitmap:Bitmap = (event.currentTarget as Sprite).getChildAt(0) as Bitmap;
         if(this.isPixelInside(new Point(event.localX,event.localY),bitmap))
         {
            neighborIdx = this.m_lotTextBitmaps.indexOf(bitmap);
            origIdx = neighborIdx;
            neighborIdx = Global.friendManager.networkNeighborUids.length - neighborIdx - 1;
            if(neighborIdx >= 0 && neighborIdx < Global.friendManager.networkNeighborUids.length)
            {
               this.m_pendingVisitUserId = Global.friendManager.networkNeighborUids[neighborIdx];
               visitLotObj = Global.stage.getChildByName("visitLotPopup");
               if(visitLotObj == null)
               {
                  visitMessage = ZLocUtils.t("FarmGame","VisitLot",{"user":ZLocUtils.tn(this.getNeighborName(origIdx))});
                  UI.displayPopup(new GenericPopup(visitMessage,GenericPopup.TYPE_YESNO,this.onConfirmVisit),true,"visitLotPopup",true);
               }
            }
            else
            {
               UI.confirmAddNeighbor();
            }
            event.stopImmediatePropagation();
            event.stopPropagation();
         }
      }
      
      protected function onExpandTextClick(event:MouseEvent) : void
      {
         var bitmap:Bitmap = (event.currentTarget as Sprite).getChildAt(0) as Bitmap;
         if(this.isPixelInside(new Point(event.localX,event.localY),bitmap))
         {
            FarmStatsManager.count("Expansion_strip","user_eligible",this.getFarmSizeName(),"click");
            Global.player.setFeatureLastShown("expansionMarketingClick",GlobalEngine.serverTime / 1000,true);
            UI.displayMarketDialog("lot_text","change_farm",null,"expand_farm",this.onMarketClose);
            event.stopImmediatePropagation();
            event.stopPropagation();
         }
      }
      
      protected function onConfirmVisit(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            Global.worldManager.visitNeighbor(this.m_pendingVisitUserId);
         }
      }
      
      protected function renderLotLine(lotSprite:Sprite, point1:Point, point2:Point, delta:Vector2, themeColor:uint, themeAlpha:Number, horizontal:Boolean) : void
      {
         var scaledDelta:Point = new Point(delta.x * getGridWidth() * 0.5,delta.y * getGridHeight() * 0.5);
         var startPoint:Point = point1.add(scaledDelta);
         var endPoint:Point = point2.subtract(scaledDelta);
         var lineThickness:Number = 2;
         var angle:Number = horizontal ? -1 * LOT_OUTLINE_VERTICAL_ANGLE : LOT_OUTLINE_VERTICAL_ANGLE;
         var colorArray:Array = [themeColor,themeColor];
         var mxBox:Matrix = new Matrix();
         mxBox.createGradientBox(scaledDelta.length,scaledDelta.length,angle,startPoint.x,startPoint.y);
         lotSprite.graphics.lineStyle(lineThickness,themeColor,0);
         lotSprite.graphics.lineGradientStyle(GradientType.LINEAR,colorArray,[0,themeAlpha],LOT_OUTLINE_RATIO_ARRAY,mxBox);
         lotSprite.graphics.moveTo(startPoint.x,startPoint.y);
         lotSprite.graphics.lineTo(point1.x,point1.y);
         lotSprite.graphics.lineGradientStyle(GradientType.LINEAR,colorArray,[themeAlpha,themeAlpha],LOT_OUTLINE_RATIO_ARRAY);
         lotSprite.graphics.lineTo(point2.x,point2.y);
         mxBox.createGradientBox(scaledDelta.length,scaledDelta.length,angle,point2.x,point2.y);
         lotSprite.graphics.lineGradientStyle(GradientType.LINEAR,colorArray,[themeAlpha,0],LOT_OUTLINE_RATIO_ARRAY,mxBox);
         lotSprite.graphics.lineTo(endPoint.x,endPoint.y);
      }
      
      override public function cleanUp() : void
      {
         while(this.m_activeModes.length)
         {
            this.popGameMode();
         }
         if(this.m_lotSprite != null && this.m_lotSprite.parent != null)
         {
            this.m_lotSprite.parent.removeChild(this.m_lotSprite);
            this.m_lotSprite = null;
         }
         if(this.m_playNextMusicTimer != null)
         {
            this.m_playNextMusicTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onPlayNextMusicTimerComplete,false);
            if(this.m_playNextMusicTimer.running)
            {
               this.m_playNextMusicTimer.stop();
            }
            this.m_playNextMusicTimer = null;
         }
         super.cleanUp();
         DLManager.cleanUp();
      }
      
      private function generateNewMusicIndexForReload() : void
      {
         if(this.m_musicChannel != null)
         {
            this.m_musicChannel.stop(false);
            this.m_musicChannel = null;
         }
         var worldId:String = Global.worldManager.currentWorldType;
         var musicAssetsUrls:Array = Global.farmGameSettingsManager.getMusicByWorldType(worldId);
         this.m_musicIndex = int(Math.floor(Math.random() * musicAssetsUrls.length));
      }
      
      public function stopPreviousWorldMusic() : void
      {
         SoundManager.stopSound(getAmbientMusicId(Global.worldManager.previousWorldType));
         this.m_musicIndex = -1;
      }
      
      public function syncMusicToPlayerOptions(isReload:Boolean = false) : void
      {
         var musicDisabled:Boolean = false;
         var worldId:String = null;
         var musicId:String = null;
         var music:Sound = null;
         var musicAssetsUrls:Array = null;
         if(Global.farmGame.isAllHighPriorityLoadComplete())
         {
            musicDisabled = Global.player.isMusicDisabled() || this.m_isSoundForcefullyPaused;
            if(!musicDisabled)
            {
               if(isReload || this.m_musicIndex == -1)
               {
                  this.generateNewMusicIndexForReload();
               }
               worldId = Global.worldManager.currentWorldType;
               musicId = getMusicId(worldId,this.m_musicIndex);
               music = SoundManager.getSoundById(musicId);
               if(music == null)
               {
                  musicAssetsUrls = Global.farmGameSettingsManager.getMusicByWorldType(worldId);
                  SoundManager.addSound(musicId,Global.getAssetURL(musicAssetsUrls[this.m_musicIndex]),false,this.onMusicLoaded);
               }
               else if(Boolean(this.m_musicChannel) && this.m_musicChannel.sound == SoundManager.getSoundById(musicId))
               {
                  if(!this.m_musicChannel.isPlaying())
                  {
                     this.m_musicChannel.unpause();
                  }
               }
               else
               {
                  this.m_musicChannel = SoundManager.playSound(musicId,0,0,null,true,this.onMusicComplete);
               }
            }
            else if(Boolean(this.m_musicChannel) && this.m_musicChannel.isPlaying())
            {
               this.m_musicChannel.pause();
            }
         }
      }
      
      private function onMusicLoaded(event:Event) : void
      {
         this.syncMusicToPlayerOptions();
      }
      
      private function onMusicComplete(event:Event) : void
      {
         if(this.m_playNextMusicTimer == null)
         {
            this.m_playNextMusicTimer = new Timer(FarmGameUtil.NUM_MSECS_IN_SECOND,1);
            this.m_playNextMusicTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onPlayNextMusicTimerComplete,false,0,true);
         }
         else
         {
            this.m_playNextMusicTimer.reset();
         }
         this.m_playNextMusicTimer.start();
      }
      
      protected function onPlayNextMusicTimerComplete(evt:TimerEvent) : void
      {
         this.syncMusicToPlayerOptions(true);
      }
      
      private function loadAmbientMusic() : void
      {
         var music:Sound = null;
         var soundObject:SoundObject = null;
         var worldId:String = Global.worldManager.currentWorldType;
         var ambientMusicAssetUrl:String = Global.farmGameSettingsManager.getAmbientMusicByWorldType(worldId);
         if(ambientMusicAssetUrl != null)
         {
            music = SoundManager.getSoundById(getAmbientMusicId(worldId));
            if(music == null)
            {
               SoundManager.addSound(getAmbientMusicId(worldId),Global.getAssetURL(ambientMusicAssetUrl),false,this.onAmbientMusicLoaded);
            }
            else
            {
               soundObject = SoundManager.getSoundObject(music);
               if(soundObject == null)
               {
                  soundObject = SoundManager.playSound(getAmbientMusicId(Global.worldManager.currentWorldType),0,999999,null,false);
               }
               if(soundObject != null)
               {
                  soundObject.volume = 0.75;
               }
            }
         }
      }
      
      public function pauseSoundForcefully() : void
      {
         this.m_isSoundForcefullyPaused = true;
         this.syncMusicToPlayerOptions();
         this.syncSoundsToPlayerOptions();
      }
      
      public function resetForcedSoundPause() : void
      {
         this.m_isSoundForcefullyPaused = false;
         this.syncMusicToPlayerOptions();
         this.syncSoundsToPlayerOptions();
      }
      
      public function syncSoundsToPlayerOptions() : void
      {
         var music:Sound = null;
         var options:Object = Global.player.options;
         var soundDisabled:Boolean = Global.player.isSfxDisabled() || this.m_isSoundForcefullyPaused;
         if(!soundDisabled)
         {
            SoundManager.unmute();
         }
         else
         {
            SoundManager.mute();
         }
         if(!soundDisabled && Global.farmGame.isAllHighPriorityLoadComplete())
         {
            music = SoundManager.getSoundById("money1");
            if(music == null)
            {
               this.addSounds();
            }
            this.loadAmbientMusic();
         }
      }
      
      private function onAmbientMusicLoaded(event:Event) : void
      {
         this.syncSoundsToPlayerOptions();
      }
      
      public function lockGameMode() : void
      {
         ++this.m_modeLock;
      }
      
      public function unlockGameMode() : void
      {
         if(this.m_modeLock > 0)
         {
            --this.m_modeLock;
         }
      }
      
      public function isModeLocked() : Boolean
      {
         return this.m_modeLock > 0;
      }
      
      public function hasFertilizablePlot() : Boolean
      {
         var result:Boolean = false;
         var objects:Array = getObjects();
         var objIdx:int = 0;
         var objLen:uint = objects.length;
         while(objIdx < objLen)
         {
            if(objects[objIdx] is Plot)
            {
               result ||= (objects[objIdx] as Plot).isFertilizable();
            }
            objIdx++;
         }
         return result;
      }
      
      public function getExtraItemFlag(itemId:uint, flagIndex:uint) : Boolean
      {
         return this.m_extraItemFlags.getFlag(itemId,flagIndex);
      }
      
      public function setExtraItemFlag(itemId:uint, flagIndex:uint, trueOrFalse:Boolean) : void
      {
         this.m_extraItemFlags.setFlag(itemId,flagIndex,trueOrFalse);
      }
      
      public function setIsHarvestableResourceOrganicFertilized(objectInst:HarvestableResource, isSet:Boolean) : void
      {
         if(OrganicFertilizerHelper.playerCanSeeFeature())
         {
            this.m_extraItemFlags.setFlag(objectInst.getId(),EXTRA_ITEM_FLAG_ORGANIC_FERTILIZER,isSet);
         }
      }
      
      public function isHarvestableResourceOrganicFertilized(objectInst:HarvestableResource) : Boolean
      {
         var result:Boolean = false;
         if(OrganicFertilizerHelper.playerCanSeeFeature())
         {
            result = this.m_extraItemFlags.getFlag(objectInst.getId(),EXTRA_ITEM_FLAG_ORGANIC_FERTILIZER);
         }
         return result;
      }
      
      public function setIgnoreSmartBuildableRequirementsFlag(shouldIgnoreSmartBuildableRequirements:Boolean, building:StorageBuilding) : void
      {
         this.m_extraItemFlags.setFlag(building.getId(),EXTRA_ITEM_FLAG_IGNORE_SMART_BUILDABLE_REQUIREMENTS,shouldIgnoreSmartBuildableRequirements);
      }
      
      public function shouldIgnoreSmartBuildableRequirements(building:StorageBuilding) : Boolean
      {
         return this.m_extraItemFlags.getFlag(building.getId(),EXTRA_ITEM_FLAG_IGNORE_SMART_BUILDABLE_REQUIREMENTS);
      }
      
      public function extraItemFlagsRemoveInst(objectInst:HarvestableResource) : void
      {
         this.m_extraItemFlags.removeId(objectInst.getId());
      }
      
      public function extraItemFlagsRelocateId(fromId:uint, toId:uint) : void
      {
         this.m_extraItemFlags.relocateId(fromId,toId);
      }
      
      public function acquireDefaultGameMode(gameMode:GameMode, lockHolder:Object) : Boolean
      {
         var success:Boolean = false;
         if(lockHolder === this.m_defaultGameModeLockHolder || this.m_defaultGameModeLockHolder == null)
         {
            this.m_defaultGameMode = gameMode;
            this.m_defaultGameModeLockHolder = lockHolder;
            success = true;
         }
         return success;
      }
      
      public function resetDefaultGameMode(lockHolder:Object) : Boolean
      {
         var success:Boolean = false;
         if(lockHolder === this.m_defaultGameModeLockHolder)
         {
            this.m_defaultGameMode = this.m_originalGameMode;
            this.m_defaultGameModeLockHolder = null;
            success = true;
         }
         return success;
      }
      
      public function setDefaultGameMode() : void
      {
         if(Global.worldManager.isVisiting())
         {
            VisitorManager.getInstance().setDefaultGameMode();
         }
         else
         {
            this.addGameMode(this.m_defaultGameMode);
         }
      }
      
      public function addGameMode(mode:GameMode, removeAllOtherModes:Boolean = true) : Boolean
      {
         var gameModeClassName:String = null;
         var modeIdx:* = 0;
         var otherMode:GameMode = null;
         var result:Boolean = false;
         if(this.isModeLocked() == false && mode.canAdd() == true)
         {
            gameModeClassName = getQualifiedClassName(mode);
            for(modeIdx = 0; modeIdx < this.m_activeModes.length; modeIdx++)
            {
               otherMode = this.m_activeModes[modeIdx] as GameMode;
               otherMode.disableMode();
               dispatchEvent(new GameModeEvent(GameModeEvent.TYPE_PREFIX_GAME_MODE_DISABLED,otherMode));
               if(getQualifiedClassName(otherMode) == gameModeClassName)
               {
                  this.m_activeModes.splice(modeIdx,1);
                  modeIdx--;
               }
            }
            if(removeAllOtherModes)
            {
               this.m_activeModes = new Array(mode);
            }
            else
            {
               this.m_activeModes.push(mode);
            }
            mode.enableMode();
            mode.dispatchAddToStackEvent();
            result = true;
         }
         return result;
      }
      
      public function popGameMode() : void
      {
         var mode:GameMode = null;
         if(Boolean(this.m_activeModes.length) && this.isModeLocked() == false)
         {
            mode = this.m_activeModes.pop() as GameMode;
            mode.disableMode();
            dispatchEvent(new GameModeEvent(GameModeEvent.TYPE_PREFIX_GAME_MODE_DISABLED,mode));
            if(this.m_activeModes.length)
            {
               this.m_activeModes[this.m_activeModes.length - 1].enableMode();
            }
         }
      }
      
      public function removeGameMode(gameMode:GameMode) : void
      {
         var modeIdx:int = 0;
         var otherMode:GameMode = null;
         if(Boolean(this.m_activeModes.length) && this.isModeLocked() == false)
         {
            for(modeIdx = 0; modeIdx < this.m_activeModes.length; modeIdx++)
            {
               otherMode = this.m_activeModes[modeIdx] as GameMode;
               if(otherMode == gameMode)
               {
                  gameMode.disableMode();
                  dispatchEvent(new GameModeEvent(GameModeEvent.TYPE_PREFIX_GAME_MODE_DISABLED,gameMode));
                  this.m_activeModes.splice(modeIdx,1);
                  if(modeIdx == this.m_activeModes.length && this.m_activeModes.length > 0)
                  {
                     this.m_activeModes[this.m_activeModes.length - 1].enableMode();
                  }
                  break;
               }
            }
         }
      }
      
      public function getActiveGameModes() : Array
      {
         return this.m_activeModes;
      }
      
      public function getTopGameMode() : GameMode
      {
         var result:GameMode = null;
         if(this.m_activeModes.length)
         {
            result = this.m_activeModes[this.m_activeModes.length - 1];
         }
         return result;
      }
      
      public function isGameModeActive(gmClass:Class) : Boolean
      {
         var mode:GameMode = null;
         var modes:Array = this.getActiveGameModes();
         var result:Boolean = false;
         for each(mode in modes)
         {
            if(mode is gmClass)
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      public function plowablePlots(terrainCodes:Array = null) : Boolean
      {
         var plot:Plot = null;
         var plotTerrainCodes:Array = null;
         var result:Boolean = false;
         var plotsInWorld:Array = getObjectsByType(WorldObjectTypes.PLOT);
         for each(plot in plotsInWorld)
         {
            if(plot.isPlowable())
            {
               if(terrainCodes == null)
               {
                  result = true;
                  break;
               }
               plotTerrainCodes = TerrainUtil.getTerrainCodesForItemInstance(plot);
               if(TerrainUtil.intersectTerrainCodeArrays(plotTerrainCodes,terrainCodes))
               {
                  result = true;
                  break;
               }
            }
         }
         return result;
      }
      
      public function removablePlots(terrainCodes:Array = null) : Boolean
      {
         var plot:Plot = null;
         var plotTerrainCodes:Array = null;
         var result:Boolean = false;
         var plotsInWorld:Array = getObjectsByType(WorldObjectTypes.PLOT);
         for each(plot in plotsInWorld)
         {
            if(plot.isRemovable())
            {
               if(terrainCodes == null)
               {
                  result = true;
                  break;
               }
               plotTerrainCodes = TerrainUtil.getTerrainCodesForItemInstance(plot);
               if(TerrainUtil.intersectTerrainCodeArrays(plotTerrainCodes,terrainCodes))
               {
                  result = true;
                  break;
               }
            }
         }
         return result;
      }
      
      public function getEquipment(className:Class = null, terrainCodes:Array = null, itemNamePurchased:String = null) : Equipment
      {
         var objects:Array = null;
         var maxParts:int = 0;
         var objIdx:int = 0;
         var objLen:uint = 0;
         var itemPurchased:FarmItem = null;
         var object:Object = null;
         var objectClass:Class = null;
         var compareParts:int = 0;
         var equipmentObject:Equipment = null;
         var garageObject:GarageBuilding = null;
         var storedEquipment:Array = null;
         var equipIdx:int = 0;
         var storedObject:Object = null;
         var garageEquipmentObject:Equipment = null;
         var result:Equipment = null;
         if(Boolean(this.m_chosenSeeder && className) && Boolean(this.m_chosenSeeder is className) && (!terrainCodes || TerrainUtil.intersectTerrainCodeArrays(terrainCodes,this.m_chosenSeeder.getSupportedTerrainCodes())))
         {
            result = this.m_chosenSeeder;
         }
         else
         {
            if(itemNamePurchased != null)
            {
               itemPurchased = Global.farmGameSettingsManager.getFarmItemByName(itemNamePurchased);
               if(itemPurchased != null)
               {
                  terrainCodes = itemPurchased.getTerrainCodes();
               }
            }
            objects = getObjects();
            maxParts = 0;
            objIdx = 0;
            objLen = objects.length;
            while(objIdx < objLen)
            {
               object = objects[objIdx];
               objectClass = Class(getDefinitionByName(getQualifiedClassName(object)));
               compareParts = 0;
               if(object is Equipment && (className == null || objectClass == className) && (!terrainCodes || TerrainUtil.intersectTerrainCodeArrays(terrainCodes,object.getItem().getTerrainCodes())))
               {
                  equipmentObject = object as Equipment;
                  compareParts = equipmentObject.actionSizeArea;
                  if(compareParts > maxParts)
                  {
                     maxParts = compareParts;
                     result = equipmentObject;
                  }
               }
               else if(object is GarageBuilding)
               {
                  garageObject = object as GarageBuilding;
                  storedEquipment = garageObject.getEquipmentObjects();
                  for(equipIdx = 0; equipIdx < storedEquipment.length; equipIdx++)
                  {
                     storedObject = storedEquipment[equipIdx];
                     objectClass = Class(getDefinitionByName(getQualifiedClassName(storedObject)));
                     if(storedObject is Equipment && (className == null || objectClass == className) && (!terrainCodes || TerrainUtil.intersectTerrainCodeArrays(terrainCodes,storedObject.getItem().getTerrainCodes())))
                     {
                        garageEquipmentObject = storedObject as Equipment;
                        compareParts = garageEquipmentObject.actionSizeArea;
                        if(compareParts > maxParts)
                        {
                           maxParts = compareParts;
                           result = garageEquipmentObject;
                        }
                     }
                  }
               }
               objIdx++;
            }
         }
         return result;
      }
      
      public function getObjectsByNames(itemNames:Array) : Array
      {
         var object:MapResource = null;
         var objectName:String = null;
         var nameIdx:int = 0;
         var results:Array = new Array();
         var objects:Array = getObjects();
         var objIdx:int = 0;
         var objLen:uint = objects.length;
         while(objIdx < objLen)
         {
            object = objects[objIdx] as MapResource;
            if(Boolean(object) && Boolean(object.getItem()))
            {
               objectName = object.getItem().name;
               for(nameIdx = 0; nameIdx < itemNames.length; nameIdx++)
               {
                  if(objectName == itemNames[nameIdx])
                  {
                     results.push(object);
                  }
               }
            }
            objIdx++;
         }
         return results;
      }
      
      public function resetPerformanceTracking() : void
      {
         if(m_perfTracking == true)
         {
            m_lastPerfUpdate = GlobalEngine.currentTime;
            m_perfFrameCount = 0;
         }
      }
      
      override protected function trackPerf() : void
      {
         var framerate:int = 0;
         var bucketSize:int = 0;
         var frameString:String = null;
         var memory:Number = NaN;
         var memoryString:String = null;
         var objString:String = null;
         var objCount:int = 0;
         var runtimeCount:int = 0;
         var runtimeString:String = null;
         var maxTime:int = 0;
         var mouseMoveCount:int = 0;
         var elapsedMoveCount:int = 0;
         var mouseMoveCountString:String = null;
         var mouseClickCount:int = 0;
         var elapsedClickCount:int = 0;
         var mouseClickCountString:String = null;
         var currentTime:Number = GlobalEngine.currentTime;
         ++m_perfFrameCount;
         if(currentTime >= m_lastPerfUpdate + PERF_UPDATE_INTERVAL)
         {
            framerate = m_perfFrameCount / (currentTime - m_lastPerfUpdate) * 1000;
            if(Boolean(GlobalEngine && GlobalEngine.viewport) && Boolean(GlobalEngine.viewport.objectBase) && (!PerformanceExperimentManager.isInDefconHideExperiment || !DefconManager.isThrottled))
            {
               bucketSize = 0;
               if(framerate < 2)
               {
                  frameString = "0-1";
               }
               else if(framerate <= 5)
               {
                  frameString = "2-5";
               }
               else
               {
                  bucketSize = 5;
                  framerate -= framerate % bucketSize;
                  frameString = framerate.toString() + "-" + (framerate + bucketSize).toString();
               }
               memory = Number(System.totalMemory / 1024 / 1024);
               bucketSize = 25;
               memory -= memory % bucketSize;
               memoryString = memory.toString() + "-" + (memory + bucketSize).toString();
               objCount = GlobalEngine.viewport.objectBase.numChildren;
               bucketSize = 250;
               if(objCount > 3000)
               {
                  bucketSize = 500;
               }
               objCount -= objCount % bucketSize;
               objString = objCount.toString() + "-" + (objCount + bucketSize).toString() + " objects";
               runtimeCount = currentTime / PERF_UPDATE_INTERVAL;
               maxTime = 21;
               if(runtimeCount < maxTime)
               {
                  runtimeString = runtimeCount.toString();
               }
               else
               {
                  runtimeString = maxTime.toString() + "+";
               }
               mouseMoveCount = this.numUserMoves;
               elapsedMoveCount = mouseMoveCount - this.m_lastMouseMoveCount;
               mouseMoveCountString = elapsedMoveCount.toString();
               this.m_lastMouseMoveCount = mouseMoveCount;
               mouseClickCount = this.numUserClicks;
               elapsedClickCount = mouseClickCount - this.m_lastMouseClickCount;
               mouseClickCountString = elapsedClickCount.toString();
               this.m_lastMouseClickCount = mouseClickCount;
               FarmStatsManager.count("performance",objString,"framerate",frameString,runtimeString);
               FarmStatsManager.count("performance",objString,"memory",memoryString,runtimeString);
               FarmStatsManager.count("performance",objString,"defconLevel",DefconManager.defconLevel.toString(),runtimeString);
               FarmStatsManager.count("performance",objString,"mousemove",mouseMoveCountString,runtimeString);
               FarmStatsManager.count("performance",objString,"mouseclick",mouseClickCountString,runtimeString);
               FarmStatsManager.count("performance",objString,"zoom",GlobalEngine.viewport.getZoom().toString().substr(0,5),runtimeString);
            }
            m_perfFrameCount = 0;
            m_lastPerfUpdate = currentTime;
         }
      }
      
      public function centerOnObject(worldObj:WorldObject, duration:Number = 1, upDisplacement:int = 0, centerOnCallback:Function = null) : void
      {
         this.m_centerOnCallback = centerOnCallback;
         if(this.m_scrollTween)
         {
            this.m_scrollTween.complete(true);
            this.m_scrollTween = null;
         }
         var objPos:Vector3 = worldObj.getPosition();
         var params:Object = {
            "startPos":GlobalEngine.viewport.getScrollPosition(),
            "alpha":0
         };
         var viewport:IsoViewport = GlobalEngine.viewport as IsoViewport;
         viewport.centerOnTilePos(objPos.x,objPos.y);
         params.endPos = GlobalEngine.viewport.getScrollPosition();
         GlobalEngine.viewport.setScrollPosition(params.startPos);
         params.endPos.y += upDisplacement;
         this.m_scrollTween = TweenLite.to(params,duration,{
            "alpha":1,
            "onUpdate":this.onUpdateScrollTween,
            "onUpdateParams":[params],
            "onComplete":this.onCompleteScrollTween
         });
      }
      
      protected function onUpdateScrollTween(params:Object) : void
      {
         var newPos:Vector2 = Vector2.lerp(params.startPos,params.endPos,params.alpha);
         GlobalEngine.viewport.setScrollPosition(newPos);
      }
      
      protected function onCompleteScrollTween() : void
      {
         if(this.m_centerOnCallback != null)
         {
            this.m_centerOnCallback();
            this.m_centerOnCallback = null;
         }
         this.m_scrollTween = null;
      }
      
      public function switchRenderSystemByType(code:String) : void
      {
         var worldObj:MapResource = null;
         var objects:Array = getObjects();
         var objIdx:int = 0;
         var objLen:uint = objects.length;
         while(objIdx < objLen)
         {
            worldObj = objects[objIdx] as MapResource;
            if(Boolean(worldObj != null) && Boolean(worldObj.getItem()) && worldObj.getItem().code == code)
            {
               worldObj.switchRenderSystem();
            }
            objIdx++;
         }
      }
      
      public function checkNumObjectLimit() : Boolean
      {
         var objects:Array = getObjects();
         var result:Boolean = this.m_maxNumObjects > objects.length - 1;
         if(result && this.m_maxNumObjects == objects.length + this.MAX_OBJECTS_WARNING - 2)
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","Maxed_Objects_100_Left"));
         }
         if(result && int(this.m_maxNumObjects / 2) == objects.length)
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","Maxed_Objects_Half"));
         }
         return result;
      }
      
      public function redrawObjectsOfClass(className:Class) : void
      {
         var objects:Array = null;
         var object:FarmGameObject = null;
         if(className)
         {
            objects = getObjectsByClass(className);
            for each(object in objects)
            {
               object.reloadImage();
            }
         }
      }
      
      public function loadContextMenusForEvolutionAnimals(className:Class) : void
      {
         var objects:Array = null;
         var object:EvolutionAnimal = null;
         if(className)
         {
            objects = getObjectsByClass(className);
            for each(object in objects)
            {
               object.loadMenu();
            }
         }
      }
      
      public function get backgroundRendered() : Boolean
      {
         return this.m_initializedPlusFrame;
      }
      
      public function getEmptyArea(aWidth:int, aHeight:int, ignoreObjects:Array = null) : Object
      {
         var collisionCheckResult:Object = null;
         var targetX:int = 0;
         var targetY:int = 0;
         ignoreObjects ||= [];
         var result:Object = null;
         var gWidth:int = getGridWidth();
         var midX:Number = gWidth >> 1;
         var gHeight:int = getGridHeight();
         var midY:Number = gHeight >> 1;
         var lineWidth:int = 1;
         var increment:int = 1;
         var curX:int = midX;
         var curY:int = midY;
         loop0:
         while(curX > 0 && curX < gWidth - 1 && curY > 0 && curY < gHeight - 1)
         {
            targetX = curX + increment * lineWidth;
            while(curX != targetX)
            {
               collisionCheckResult = checkCollision(curX,curY,curX + aWidth,curY + aHeight,ignoreObjects);
               if(!collisionCheckResult)
               {
                  result = {
                     "x":curX,
                     "y":curY,
                     "z":0
                  };
                  break loop0;
               }
               curX += increment;
            }
            targetY = curY + increment * lineWidth;
            while(curY != targetY)
            {
               collisionCheckResult = checkCollision(curX,curY,curX + aWidth,curY + aHeight,ignoreObjects);
               if(!collisionCheckResult)
               {
                  result = result = {
                     "x":curX,
                     "y":curY,
                     "z":0
                  };
                  break loop0;
               }
               curY += increment;
            }
            lineWidth++;
            increment *= -1;
         }
         return result;
      }
      
      public function getWorldCenter() : Vector3
      {
         return new Vector3(getGridWidth() / 2,getGridHeight() / 2,0);
      }
      
      public function enterForcePlaceModeWithEvent(itemName:String, callback:Function, eventType:String = "gameModeDisabled") : void
      {
         this.enterForcePlaceMode(itemName,false,0,true,true,null,true,callback,eventType);
      }
      
      public function enterForcePlaceMode(itemName:String, isFromMarket:Boolean = false, forceBuildingId:int = 0, remindToaster:Boolean = true, fromGiftbox:Boolean = true, extraData:Object = null, showToaster:Boolean = true, callback:Function = null, eventType:String = "gameModeDisabled") : void
      {
         var buildMode:GMBuild = null;
         var toasterTitle:String = null;
         var toasterMessageLocKey:String = null;
         var toasterMessage:String = null;
         var icon:String = null;
         var giftItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         if(giftItem.type == "building" && giftItem.className != "BuildingPart")
         {
            buildMode = new GMBuild(itemName,fromGiftbox,0,false);
            if(callback != null)
            {
               this.addEventListener(GameModeEvent.getEventType(eventType,buildMode),callback);
            }
            this.addGameMode(buildMode);
         }
         else
         {
            if(extraData == null)
            {
               extraData = {"isGift":fromGiftbox};
            }
            if(!extraData.hasOwnProperty("fromMarket"))
            {
               extraData.fromMarket = isFromMarket;
            }
            if(!extraData.hasOwnProperty("repopGift"))
            {
               extraData.repopGift = false;
            }
            giftItem.onUse(forceBuildingId,extraData);
         }
         if(remindToaster)
         {
            Global.player.setItemFlag("ForcePlace_Reminder",giftItem.code);
         }
         if(showToaster)
         {
            toasterTitle = ZLocUtils.t("Crafting","PlacementToasterTitle");
            toasterMessageLocKey = "PlaceCottageToasterMessage";
            if(!fromGiftbox)
            {
               toasterMessageLocKey = "PlaceCottageFromMarketToasterMessage";
            }
            toasterMessage = ZLocUtils.t("Crafting",toasterMessageLocKey);
            icon = Global.farmGameSettingsManager.getFarmItemByName(itemName).iconUrl;
            ToasterManager.getInstance().togglePause(false);
            ToasterManager.getInstance().add(new IconTitleToasterWindow(toasterTitle,toasterMessage,icon,"assets/dialogs/FV_PlacementMode_BannerAd.swf",0.5,new Point(15,8)));
         }
      }
      
      public function getNumWitheredPlots() : int
      {
         var witherCount:int = 0;
         var plots:Array = getObjectsByClass(Plot);
         for(var plotIdx:int = 0; plotIdx < plots.length; plotIdx++)
         {
            if(plots[plotIdx].isWithered())
            {
               witherCount++;
            }
         }
         return witherCount;
      }
      
      public function getThemeType() : String
      {
         return this.getFarmTileMap().getFarmBackgroundRenderer().getThemeType();
      }
      
      public function drawAreaOfEffect(mapResource:MapResource) : void
      {
         var rect:Rectangle = null;
         var aoeShape:Sprite = this.m_aoeRenderMap[mapResource];
         var color:uint = Constants.COLOR_HIGHLIGHT_BLUE;
         if(aoeShape == null)
         {
            aoeShape = new Sprite();
            aoeShape.blendMode = BlendMode.NORMAL;
            this.m_aoeRenderMap[mapResource] = aoeShape;
         }
         if(aoeShape.parent == null)
         {
            this.m_aoeRenderLayer.addChild(aoeShape);
         }
         else if(aoeShape.parent != this.m_aoeRenderLayer)
         {
            aoeShape.parent.removeChild(aoeShape);
            this.m_aoeRenderLayer.addChild(aoeShape);
         }
         aoeShape.graphics.clear();
         if(!isNaN(Number(mapResource.getItem().aoeConfig.highlightColor)) && mapResource.getItem().aoeConfig.highlightColor > 0)
         {
            if(mapResource.getItem().aoeConfig.highlightColorActive)
            {
               color = mapResource.getItem().aoeConfig.highlightColor;
            }
            else
            {
               color = 10066329;
            }
         }
         aoeShape.graphics.beginFill(color);
         aoeShape.graphics.lineStyle(3,color);
         var position:Vector3 = mapResource.getPositionNoClone();
         var aoeConfig:AOEConfig = mapResource.getItem().aoeConfig;
         var point:Point = new Point();
         for each(rect in aoeConfig.areas)
         {
            point.x = position.x + rect.x;
            point.y = position.y + rect.y;
            drawTileArea(aoeShape.graphics,point,rect.width,rect.height);
         }
      }
      
      public function drawStencilEffect(mapResource:MapResource, itemImage:ItemImage) : void
      {
         var stencilShape:Sprite = this.m_stencilRenderMap[mapResource];
         if(stencilShape == null)
         {
            stencilShape = new Sprite();
            stencilShape.blendMode = BlendMode.NORMAL;
            this.m_stencilRenderMap[mapResource] = stencilShape;
         }
         Utilities.removeAllChildren(stencilShape);
         if(itemImage.image)
         {
            stencilShape.addChild(itemImage.image as DisplayObject);
         }
         if(stencilShape.parent == null)
         {
            this.m_stencilRenderLayer.addChild(stencilShape);
         }
         else if(stencilShape.parent != this.m_stencilRenderLayer)
         {
            stencilShape.parent.removeChild(stencilShape);
            this.m_stencilRenderLayer.addChild(stencilShape);
         }
         var position:Vector3 = mapResource.getPositionNoClone();
         var pixPos:Point = IsoMath.tilePosToPixelPos(position.x,position.y);
         stencilShape.x = pixPos.x;
         stencilShape.y = pixPos.y;
         stencilShape.alpha = 0.13;
         stencilShape.height = mapResource.getItem().stencilArea.height;
         stencilShape.width = mapResource.getItem().stencilArea.width;
      }
      
      public function clearStencilEffect(mapResource:MapResource, cleanup:Boolean = false) : void
      {
         var stencilShape:Sprite = this.m_stencilRenderMap[mapResource];
         if(stencilShape != null)
         {
            Utilities.removeAllChildren(stencilShape);
            if(stencilShape.parent != null && stencilShape.parent == this.m_stencilRenderLayer)
            {
               this.m_stencilRenderLayer.removeChild(stencilShape);
            }
            if(cleanup)
            {
               delete this.m_stencilRenderMap[mapResource];
            }
         }
      }
      
      public function addAOEToolTip(toolTip:AOETooltip) : void
      {
         this.m_aoeToolTipLayer.addChild(toolTip);
      }
      
      public function removeAOEToolTip(toolTip:AOETooltip) : void
      {
         if(Boolean(toolTip) && toolTip.parent == this.m_aoeToolTipLayer)
         {
            this.m_aoeToolTipLayer.removeChild(toolTip);
            toolTip.close();
         }
      }
      
      public function clearAreaOfEffect(mapResource:MapResource, cleanup:Boolean = false) : void
      {
         var aoeShape:Sprite = this.m_aoeRenderMap[mapResource];
         if(aoeShape != null)
         {
            aoeShape.graphics.clear();
            if(aoeShape.parent != null && aoeShape.parent == this.m_aoeRenderLayer)
            {
               this.m_aoeRenderLayer.removeChild(aoeShape);
            }
            if(cleanup)
            {
               delete this.m_aoeRenderMap[mapResource];
            }
         }
      }
      
      public function clearAllAreasOfEffect() : void
      {
         this.m_aoeRenderMap = new Dictionary(true);
         Utilities.removeAllChildren(this.m_aoeRenderLayer);
      }
      
      private function chooseColorOfLotTextByWorld() : uint
      {
         var color:uint = 16777215;
         var worldColorStr:String = Global.farmGameSettingsManager.getString("expansionMarketingTextColor_" + Global.worldManager.currentWorldType,"0xFFFFFF");
         if(worldColorStr != null && worldColorStr != "")
         {
            color = parseInt(worldColorStr,16);
         }
         return color;
      }
      
      private function chooseClassOfLotArrowsByWorld() : Class
      {
         var arrowAssetClass:Class = EmbeddedArt.expandArrow;
         switch(Global.worldManager.currentWorldType)
         {
            case WorldsConstants.WORLD_ID_WINTER_WONDERLAND:
               arrowAssetClass = EmbeddedArt.ww_expandArrow;
               break;
            default:
               arrowAssetClass = EmbeddedArt.expandArrow;
         }
         return arrowAssetClass;
      }
      
      private function addSounds() : void
      {
         SoundManager.addSound("money1",Global.getAssetURL("assets/sounds/actions/sfx_receive_coins_01.mp3"),false);
         SoundManager.addSound("money2",Global.getAssetURL("assets/sounds/actions/sfx_receive_coins_02.mp3"),false);
         SoundManager.addSound("money3",Global.getAssetURL("assets/sounds/actions/sfx_receive_coins_03.mp3"),false);
         SoundManager.addSound("crop1",Global.getAssetURL("assets/sounds/actions/sfx_harvest_crop_01.mp3"),false);
         SoundManager.addSound("crop2",Global.getAssetURL("assets/sounds/actions/sfx_harvest_crop_02.mp3"),false);
         SoundManager.addSound("crop3",Global.getAssetURL("assets/sounds/actions/sfx_harvest_crop_03.mp3"),false);
         SoundManager.addSound("tree1",Global.getAssetURL("assets/sounds/actions/sfx_harvest_tree_01.mp3"),false);
         SoundManager.addSound("tree2",Global.getAssetURL("assets/sounds/actions/sfx_harvest_tree_02.mp3"),false);
         SoundManager.addSound("tree3",Global.getAssetURL("assets/sounds/actions/sfx_harvest_tree_03.mp3"),false);
         SoundManager.addSound("tractorStart",Global.getAssetURL("assets/sounds/equipment/sfx_tractor_start.mp3"),false);
         SoundManager.addSound("tractorIdle",Global.getAssetURL("assets/sounds/equipment/sfx_tractor_engine_loop.mp3"),false);
         SoundManager.addSound("hotrodTractorStart",Global.getAssetURL("assets/sounds/equipment/tractor_hotrod_engine.mp3"),false);
         SoundManager.addSound("neighbor",Global.getAssetURL("assets/sounds/ui/sfx_ui_neighbor.mp3"),false);
         SoundManager.addSound("dialogSpawn",Global.getAssetURL("assets/sounds/ui/sfx_ui_dialog_show.mp3"),false);
         SoundManager.addSound("dialogClose",Global.getAssetURL("assets/sounds/ui/sfx_ui_dialog_hide.mp3"),false);
         SoundManager.addSound("expandMenu",Global.getAssetURL("assets/sounds/ui/sfx_ui_expand_menu.mp3"),false);
         SoundManager.addSound("click1",Global.getAssetURL("assets/sounds/ui/sfx_ui_click_1.mp3"),false);
         SoundManager.addSound("click2",Global.getAssetURL("assets/sounds/ui/sfx_ui_click_2.mp3"),false);
         SoundManager.addSound("click3",Global.getAssetURL("assets/sounds/ui/sfx_ui_click_3.mp3"),false);
         SoundManager.addSound("setgraphic",Global.getAssetURL("assets/sounds/ui/sfx_achieve_stage4.mp3"),false);
      }
   }
}

