package GameMode
{
   import Classes.AreasOfEffect.AOEBonusData;
   import Classes.Avatar.FarmAvatar;
   import Classes.BuildingDecoration;
   import Classes.Constants.ClickTrackingConstants;
   import Classes.Constants.Experiments;
   import Classes.EmbeddedArt;
   import Classes.Equipment;
   import Classes.FarmGameObject;
   import Classes.FarmGameWorld;
   import Classes.FeatureBuilding;
   import Classes.IRotatable;
   import Classes.ItemInstance;
   import Classes.MapResource;
   import Classes.Plot;
   import Classes.StorageBuilding;
   import Classes.Terrain.TerrainUtil;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Engine.Constants;
   import Engine.Helpers.Vector2;
   import Engine.Helpers.Vector3;
   import Engine.IsoMath;
   import Engine.Managers.SoundManager;
   import Engine.Managers.StatsManager;
   import Engine.Utilities;
   import GameMode.ModeComponents.AOESourceMoveComponent;
   import GameMode.ModeComponents.AOETargetMoveComponent;
   import GameMode.ModeComponents.StencilDecoMoveComponent;
   import Managers.AOEManager;
   import Managers.ClickTrackingManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureBuildingSurfacingManager;
   import Transactions.TMove;
   import flash.display.Sprite;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import gs.TweenLite;
   
   public class GMObjectMove extends GMGiftReOpen
   {
      
      private static const COMPONENT_CLASS_LIST:Array = [AOETargetMoveComponent,AOESourceMoveComponent,StencilDecoMoveComponent];
      
      private static const DELAY_AMOUNT:Number = 0.3;
      
      private static const SFX_DROP_ITEM_ID:String = "drop_place_item";
      
      private static const SFX_DROP_ITEM_URL:String = "assets/sounds/actions/sfx_drop_decoration.mp3";
      
      protected static const TILE_OUTLINE_WIDTH:int = 4;
      
      protected var m_containerCollision:StorageBuilding;
      
      protected var m_cid:int;
      
      protected var m_highlightedPoint:Point;
      
      protected var m_selectedObject:FarmGameObject = null;
      
      protected var m_positionValid:Boolean = false;
      
      protected var m_objectStartPos:Vector2 = null;
      
      protected var m_objectStartAoeSrc:Array = null;
      
      protected var m_objectPlacedSuccess:Boolean = false;
      
      protected var m_objectStoredSuccess:Boolean = false;
      
      protected var m_validStorageClasses:Array;
      
      protected var m_viewDragStartPos:Point = null;
      
      protected var m_dragging:Boolean = false;
      
      protected var m_oldState:String;
      
      protected var m_isMoveTool:Boolean;
      
      protected var m_storedOrigin:int = 0;
      
      protected var m_containerCollided:Boolean = false;
      
      protected var m_dropSuspended:Boolean = false;
      
      protected var m_currency:String = "";
      
      private var m_dragStartPos:Point;
      
      private var m_rotateBtn:Sprite;
      
      private var m_rotateFlag:Boolean = false;
      
      private var m_decoMove:GMDecoMove;
      
      private var m_objectToRotate:*;
      
      private var m_startingTerrainCode:int;
      
      private var m_objectSize:Vector3;
      
      private var m_inOnMouseMovePerfExperiment:Boolean;
      
      public function GMObjectMove(selectedObject:FarmGameObject, oldState:String = null, isGift:Boolean = false, shouldReOpenGift:Boolean = true, isMoveTool:Boolean = false, currency:String = "")
      {
         var plotObject:Plot = null;
         var bonuses:AOEBonusData = null;
         this.m_validStorageClasses = new Array();
         if(Global.world.getTopGameMode() is GMObjectMove)
         {
            Global.world.popGameMode();
         }
         this.addMoveSounds();
         m_cursorImage = EmbeddedArt.cursor_hand_closed_small;
         this.m_selectedObject = selectedObject;
         this.m_oldState = oldState;
         this.m_currency = currency;
         if(selectedObject)
         {
            this.m_objectStartPos = selectedObject.getPosition().toVector2();
            if(this.m_selectedObject is Plot)
            {
               plotObject = this.m_selectedObject as Plot;
               if(Boolean(plotObject) && Boolean(plotObject.getState() != Plot.STATE_FALLOW) && plotObject.getState() != Plot.STATE_PLOWED)
               {
                  this.m_objectStartAoeSrc = AOEManager.getInstance().getAoeResourceIdsAffecting(this.m_selectedObject as MapResource);
               }
            }
         }
         this.m_inOnMouseMovePerfExperiment = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_PERF_ONOBJECTMOVE) == Experiments.SINGLE_CONTROL_VALID_VARIANT_START;
         super(isGift,shouldReOpenGift);
         this.m_isMoveTool = isMoveTool;
         if(this.m_isMoveTool)
         {
            m_cursorImage = EmbeddedArt.cursor_hand_closed;
         }
         if(!Global.stage.hasEventListener(KeyboardEvent.KEY_UP))
         {
            Global.stage.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUp,false,1,false);
         }
         if(this.m_selectedObject != null && this.m_selectedObject is Plot)
         {
            this.m_objectSize = this.m_selectedObject.getSize();
            this.m_startingTerrainCode = this.currentHoverOverTerrainCode;
         }
         var aoeManager:AOEManager = AOEManager.getInstance();
         var selectedResource:MapResource = selectedObject as MapResource;
         if(selectedResource != null)
         {
            bonuses = AOEManager.getInstance().computeBonusesForResource(selectedResource,false);
            if(bonuses.possibleStates != null && bonuses.possibleStates.length > 0)
            {
               selectedResource.applyAoeAffects(bonuses);
            }
         }
      }
      
      public function get selectedObject() : FarmGameObject
      {
         return this.m_selectedObject;
      }
      
      public function get storedOrigin() : int
      {
         return this.m_storedOrigin;
      }
      
      private function get currentHoverOverTerrainCode() : int
      {
         var currentPos:Vector3 = this.m_selectedObject.getPosition();
         var endX:int = currentPos.x + this.m_objectSize.x;
         var endY:int = currentPos.y + this.m_objectSize.y;
         var hoverOverTerrainCodes:Array = TerrainUtil.getTerrainCodesInArea(currentPos.x,currentPos.y,endX,endY);
         return Global.farmGameSettingsManager.selectPrimaryTerrainCodeFromGivenCodes(hoverOverTerrainCodes);
      }
      
      override public function enableMode() : void
      {
         super.enableMode();
         if(this.m_selectedObject)
         {
            this.m_selectedObject.startMove();
            if(this.m_selectedObject.canBeSurfaced())
            {
               FeatureBuildingSurfacingManager.getInstance().highlightBuildings(this.m_selectedObject as MapResource);
            }
         }
         this.onMouseMove(null);
      }
      
      override public function disableMode() : void
      {
         if(this.m_objectPlacedSuccess == false && this.m_objectStoredSuccess == false)
         {
            if(this.m_objectStartPos == null)
            {
               this.m_selectedObject.detach();
            }
            else
            {
               this.m_selectedObject.preDisableMove(this.m_oldState);
               this.m_selectedObject.setPosition(this.m_objectStartPos.x,this.m_objectStartPos.y);
               this.m_selectedObject.conditionallyReattach();
               this.m_selectedObject.postDisableMove();
               this.m_selectedObject.alpha = 1;
            }
         }
         if(this.m_selectedObject.canBeSurfaced())
         {
            FeatureBuildingSurfacingManager.getInstance().highlightBuildings(this.m_selectedObject as MapResource,false);
         }
         super.disableMode();
      }
      
      override protected function addComponents() : void
      {
         var componentClass:Object = null;
         m_components = new Array();
         for each(componentClass in COMPONENT_CLASS_LIST)
         {
            if(componentClass.canApply(this,this.m_selectedObject))
            {
               m_components.push(new componentClass(this.m_selectedObject));
            }
         }
      }
      
      public function setStoredSuccess(value:Boolean) : void
      {
         this.m_objectStoredSuccess = value;
      }
      
      public function isFromStorage() : Boolean
      {
         return this.m_storedOrigin > 0 || Global.worldManager.isValidInventoryStorageId(this.m_storedOrigin);
      }
      
      protected function updateOverlay() : void
      {
         var objSize:Vector3 = null;
         var pos:Point = null;
         var x:int = 0;
         var y:int = 0;
         var colFlags:int = 0;
         var color:int = 0;
         m_displayObject.graphics.clear();
         if(this.m_highlightedPoint)
         {
            if(this.m_highlightedPoint.x != -1 && this.m_highlightedPoint.y != -1)
            {
               objSize = this.m_selectedObject.getSize();
               pos = this.m_highlightedPoint.clone();
               for(x = 0; x < objSize.x; x++)
               {
                  pos.y = this.m_highlightedPoint.y;
                  for(y = 0; y < objSize.y; y++)
                  {
                     colFlags = this.m_selectedObject.getCollisionFlags(x,y);
                     if(this.m_positionValid)
                     {
                        color = (colFlags & Constants.COLLISION_OVERLAP) << 0 == Constants.COLLISION_OVERLAP ? int(Constants.COLOR_OVERLAP) : int(Constants.COLOR_VALID_PLACEMENT);
                        m_displayObject.graphics.beginFill(color,0.5);
                        this.m_selectedObject.alpha = 1;
                     }
                     else
                     {
                        m_displayObject.graphics.beginFill(Constants.COLOR_NOT_VALID_PLACEMENT,0.5);
                        this.m_selectedObject.alpha = 0.6;
                     }
                     FarmGameWorld.drawTileArea(m_displayObject.graphics,pos,1,1);
                     m_displayObject.graphics.endFill();
                     ++pos.y;
                  }
                  ++pos.x;
               }
               color = this.m_positionValid ? int(Constants.COLOR_VALID_PLACEMENT) : int(Constants.COLOR_NOT_VALID_PLACEMENT);
               m_displayObject.graphics.lineStyle(TILE_OUTLINE_WIDTH,color,Constants.ALPHA_VALID_PLACEMENT);
               m_displayObject.graphics.beginFill(0,0);
               FarmGameWorld.drawTileArea(m_displayObject.graphics,this.m_highlightedPoint,objSize.x,objSize.y);
               m_displayObject.graphics.endFill();
            }
         }
      }
      
      protected function canMultiPlace() : Boolean
      {
         var result:Boolean = false;
         var item:FarmItem = (this.m_selectedObject as ItemInstance).getItem();
         if(Boolean(item) && item.multiplace)
         {
            if(m_isGift)
            {
               if(Global.player.getGiftCountForItemKey(item.code) > 1)
               {
                  result = true;
               }
            }
            else if(this.m_cid == 0 && Global.player.canBuyItem(null,true,item,0,this.m_currency,false) || this.m_cid < 0 && Global.player.hasInventoryItem(item.code,this.m_cid) || this.m_cid > 0 && (Global.world.getObjectById(this.m_cid) as StorageBuilding).getAmount(item.code) > 0)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function addMoveSounds() : void
      {
         SoundManager.addSound(SFX_DROP_ITEM_ID,Global.getAssetURL(SFX_DROP_ITEM_URL),false);
      }
      
      override public function onKeyUp(event:KeyboardEvent) : Boolean
      {
         var rotatable:IRotatable = null;
         var gameModes:Array = null;
         if(event.keyCode == FarmGameUtil.KEYBOARD_KEY_SPACE)
         {
            rotatable = this.m_selectedObject as IRotatable;
            if(rotatable != null && rotatable.canRotate())
            {
               rotatable.rotate(true);
            }
            this.updateOverlay();
            FarmStatsManager.count("movetool","movetool_rotated");
            TweenLite.to(this.m_objectToRotate,DELAY_AMOUNT,{});
         }
         if(event.keyCode == FarmGameUtil.KEYBOARD_KEY_ESC)
         {
            gameModes = Global.world.getActiveGameModes();
            if(gameModes.length > 1)
            {
               Global.world.popGameMode();
            }
            else
            {
               Global.world.setDefaultGameMode();
            }
         }
         return true;
      }
      
      override public function onMouseMove(event:MouseEvent) : Boolean
      {
         var newPos:Vector2 = null;
         var currentPos:Point = getMouseStagePos();
         if(Boolean(this.m_viewDragStartPos) && Boolean(currentPos) && Boolean(m_mouseDownPos) && currentPos.subtract(m_mouseDownPos).length >= Constants.DRAG_CLICK_EPSILON)
         {
            this.m_dragging = true;
         }
         if(this.m_dragging && Boolean(this.m_viewDragStartPos))
         {
            newPos = new Vector2();
            newPos.x = this.m_viewDragStartPos.x + (currentPos.x - m_mouseDownPos.x) / GlobalEngine.viewport.getZoom();
            newPos.y = this.m_viewDragStartPos.y + (currentPos.y - m_mouseDownPos.y) / GlobalEngine.viewport.getZoom();
            GlobalEngine.viewport.setScrollPosition(newPos);
         }
         else
         {
            if(this.m_selectedObject)
            {
               if(this.m_selectedObject is FeatureBuilding)
               {
                  (this.m_selectedObject as FeatureBuilding).hideIndicator();
               }
               if(this.m_selectedObject is BuildingDecoration)
               {
                  (this.m_selectedObject as BuildingDecoration).hideArrowDisplay();
               }
               if(this.m_selectedObject.canBeSurfaced())
               {
                  FeatureBuildingSurfacingManager.getInstance().highlightBuildings(this.m_selectedObject as MapResource);
               }
               this.m_positionValid = this.updateHighlightPoint(event);
               this.m_selectedObject.setPosition(this.m_highlightedPoint.x,this.m_highlightedPoint.y);
               this.m_selectedObject.conditionallyReattach();
            }
            if(this.m_inOnMouseMovePerfExperiment)
            {
               executeComponents("onMouseMove",event);
            }
         }
         this.updateOverlay();
         if(!this.m_inOnMouseMovePerfExperiment)
         {
            executeComponents("onMouseMove",event);
         }
         return true;
      }
      
      override public function onMouseDown(event:MouseEvent) : Boolean
      {
         super.onMouseDown(event);
         this.m_viewDragStartPos = GlobalEngine.viewport.getScrollPosition().clone();
         this.m_dragging = false;
         if(this.m_selectedObject is FeatureBuilding)
         {
            (this.m_selectedObject as FeatureBuilding).showIndicator();
         }
         return true;
      }
      
      override public function onMouseUp(event:MouseEvent) : Boolean
      {
         if(this.m_dragging == false && !this.m_dropSuspended)
         {
            ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_PLACE_ITEM);
            this.handleObjectDrop(event);
         }
         this.m_dragging = false;
         this.m_viewDragStartPos = null;
         super.onMouseUp(event);
         return true;
      }
      
      protected function updateHighlightPoint(event:MouseEvent) : Boolean
      {
         var idx:int = 0;
         var arrTerrainCodes:Array = null;
         var selectedItemInstance:ItemInstance = null;
         var selectedAvatar:FarmAvatar = null;
         var hoverOverTerrainCodes:Array = null;
         var terrainCode:int = 0;
         var plotObject:Plot = null;
         var prevPoint:Vector2 = null;
         var newAoeSrc:Array = null;
         var objSize:Vector3 = this.m_selectedObject.getSize();
         this.m_highlightedPoint = getMouseTilePos(event);
         this.m_highlightedPoint.x = Math.floor(this.m_highlightedPoint.x);
         this.m_highlightedPoint.y = Math.floor(this.m_highlightedPoint.y);
         this.m_highlightedPoint.x = Utilities.clamp(this.m_highlightedPoint.x,0,Global.world.getGridWidth() - objSize.x);
         this.m_highlightedPoint.y = Utilities.clamp(this.m_highlightedPoint.y,0,Global.world.getGridHeight() - objSize.y);
         var endX:int = this.m_highlightedPoint.x + objSize.x;
         var endY:int = this.m_highlightedPoint.y + objSize.y;
         var bCheckTerrain:Boolean = true;
         var collisions:Array = new Array();
         var result:Boolean = !Global.world.checkCollision(this.m_highlightedPoint.x,this.m_highlightedPoint.y,endX,endY,[this.m_selectedObject],collisions,Constants.WORLDOBJECT_ALL,this.m_selectedObject,true);
         if(collisions.length > 0)
         {
            for(idx = 0; idx < collisions.length; idx++)
            {
               if(collisions[idx] is StorageBuilding && !collisions[idx].inQueue() && !collisions[idx].isBuilding())
               {
                  if(!(this.m_selectedObject is FarmAvatar) && (Boolean(collisions[idx].canTakeItem(this.m_selectedObject)) || Boolean(collisions[idx].matchesOrigin(this.m_storedOrigin))))
                  {
                     if(this.m_containerCollision != null)
                     {
                        this.m_containerCollision.setHighlighted(false);
                        this.m_containerCollision.stopOverlay();
                     }
                     this.m_containerCollision = collisions[idx];
                     result = true;
                     bCheckTerrain = false;
                     this.m_containerCollision.setHighlighted(true);
                     if(this.m_containerCollision.shouldShowOverlayOnHighlight())
                     {
                        this.m_containerCollision.startOverlay(this.m_containerCollision.getOverlayUrl());
                     }
                  }
               }
            }
         }
         else if(this.m_containerCollision != null)
         {
            this.m_containerCollision.setHighlighted(false);
            this.m_containerCollision.stopOverlay();
            this.m_containerCollision = null;
         }
         if(bCheckTerrain && result)
         {
            arrTerrainCodes = null;
            selectedItemInstance = this.m_selectedObject as ItemInstance;
            if(selectedItemInstance != null)
            {
               arrTerrainCodes = selectedItemInstance.getSupportedTerrainCodes();
            }
            else if(this.m_selectedObject is FarmAvatar)
            {
               selectedAvatar = this.m_selectedObject as FarmAvatar;
               if(selectedAvatar != null)
               {
                  arrTerrainCodes = selectedAvatar.getSupportedTerrainCodes();
               }
            }
            if(arrTerrainCodes != null)
            {
               if(!TerrainUtil.isAreaAcceptable(arrTerrainCodes,this.m_highlightedPoint.x,this.m_highlightedPoint.y,endX,endY))
               {
                  result = false;
               }
            }
            if(this.m_selectedObject != null && this.m_selectedObject is Plot)
            {
               hoverOverTerrainCodes = TerrainUtil.getTerrainCodesInArea(this.m_highlightedPoint.x,this.m_highlightedPoint.y,endX,endY);
               terrainCode = Global.farmGameSettingsManager.selectPrimaryTerrainCodeFromGivenCodes(hoverOverTerrainCodes);
               if(Global.worldManager.getRemainingPlotsAllowed(terrainCode) <= 0 && terrainCode != this.m_startingTerrainCode)
               {
                  result = false;
               }
               if(result)
               {
                  plotObject = this.m_selectedObject as Plot;
                  if(plotObject.getState() != Plot.STATE_FALLOW && plotObject.getState() != Plot.STATE_PLOWED)
                  {
                     prevPoint = this.m_selectedObject.getPosition().toVector2();
                     this.m_selectedObject.setPosition(this.m_highlightedPoint.x,this.m_highlightedPoint.y);
                     newAoeSrc = AOEManager.getInstance().getAoeResourceIdsAffecting(this.m_selectedObject as MapResource);
                     result = false;
                     if(this.m_objectStartAoeSrc == null && newAoeSrc == null || Boolean(this.m_objectStartAoeSrc && newAoeSrc && newAoeSrc.length == this.m_objectStartAoeSrc.length) && Boolean(this.m_objectStartAoeSrc[0] == newAoeSrc[0]))
                     {
                        result = true;
                     }
                     this.m_selectedObject.setPosition(prevPoint.x,prevPoint.y);
                  }
               }
            }
         }
         return result;
      }
      
      protected function handleObjectDrop(event:MouseEvent) : void
      {
         var rotatable:IRotatable = null;
         var resource:MapResource = null;
         var origin:StorageBuilding = null;
         var resourceCode:String = null;
         var useRealItemNameEnabled:Boolean = false;
         var itemSourceCode:String = null;
         var isBought:Boolean = false;
         var addSuccess:Boolean = false;
         var releasedPoint:Point = null;
         var objSize:Vector3 = null;
         var mapObject:MapResource = null;
         var params:Object = null;
         this.m_positionValid = this.updateHighlightPoint(event);
         if(this.m_positionValid)
         {
            if(this.m_isMoveTool)
            {
               FarmStatsManager.count("movetool","movetool_place");
            }
            rotatable = this.m_objectToRotate as IRotatable;
            if(rotatable)
            {
               rotatable.syncRotationChange();
            }
            resource = this.m_selectedObject as MapResource;
            if(this.m_storedOrigin > 0)
            {
               origin = Global.world.getObjectById(this.m_storedOrigin) as StorageBuilding;
               resourceCode = Global.farmGameSettingsManager.getFarmItemCodeByName(resource.getItemName());
               if(resource as Equipment)
               {
                  origin.removeContents(resourceCode,1,(resource as Equipment).equipmentPartsCount);
               }
               else
               {
                  origin.removeContents(resourceCode);
               }
            }
            else if(Global.worldManager.isValidInventoryStorageId(this.m_storedOrigin))
            {
               useRealItemNameEnabled = Boolean(Global.flashHotParams["REALITEMNAME_ENABLED"]);
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  itemSourceCode = resource.getItem().getStringFromDataSource("code");
               }
               else
               {
                  itemSourceCode = resource.getItem().xml.@code;
               }
               if(useRealItemNameEnabled && resource.getItem().code != itemSourceCode)
               {
                  Global.player.removeInventoryItem(itemSourceCode,1,this.m_storedOrigin);
                  StatsManager.count("REALITEMNAME_ENABLED","GMObjectMove",resource.getItem().code,itemSourceCode);
               }
               else
               {
                  Global.player.removeInventoryItem(resource.getInventoryCode(),1,this.m_storedOrigin);
               }
            }
            if(this.m_containerCollision != null)
            {
               isBought = !m_isGift && this.m_storedOrigin == 0 && !this.m_objectStartPos;
               resource.fromMarket = isBought;
               addSuccess = false;
               if(isBought)
               {
                  addSuccess = this.m_containerCollision.addItemUsingCurrency(resource,this.m_storedOrigin,m_isGift,true,false,this.m_currency);
               }
               else
               {
                  addSuccess = this.m_containerCollision.addItem(resource,this.m_storedOrigin,m_isGift);
               }
               this.m_containerCollision.setHighlighted(false);
               this.m_containerCollision.stopOverlay();
               if(addSuccess)
               {
                  this.m_containerCollided = true;
                  if(isBought)
                  {
                     Global.player.tryBuy(resource,m_isGift,null,0,"",this.m_currency);
                  }
                  this.m_containerCollision = null;
                  this.m_objectPlacedSuccess = false;
                  this.m_objectStoredSuccess = true;
                  reOpenGiftIfNecessary();
               }
               else
               {
                  this.m_objectPlacedSuccess = false;
                  this.m_objectStoredSuccess = false;
               }
               Global.world.popGameMode();
               if(this.m_isMoveTool)
               {
                  Global.world.addGameMode(new GMDecoMove(),true);
               }
               else
               {
                  Global.world.setDefaultGameMode();
               }
            }
            else
            {
               releasedPoint = IsoMath.screenPosToTilePos(event.stageX,event.stageY);
               objSize = this.m_selectedObject.getSize();
               releasedPoint.x = Math.floor(releasedPoint.x);
               releasedPoint.y = Math.floor(releasedPoint.y);
               releasedPoint.x = Utilities.clamp(releasedPoint.x,0,Global.world.getGridWidth() - objSize.x);
               releasedPoint.y = Utilities.clamp(releasedPoint.y,0,Global.world.getGridHeight() - objSize.y);
               if(Boolean(this.m_objectStartPos) && (this.m_selectedObject.getClassName() != "Avatar" && this.m_selectedObject.getClassName() != "MessageAvatar"))
               {
                  mapObject = this.m_selectedObject as MapResource;
                  if(mapObject)
                  {
                     params = new Object();
                     params.x = Math.round(releasedPoint.x);
                     params.y = Math.round(releasedPoint.y);
                     params.state = mapObject.getState();
                     params = mapObject.addTMoveParams(params);
                     mapObject.addTransaction(new TMove(mapObject,params));
                     if(this.m_selectedObject != null && this.m_selectedObject is Plot)
                     {
                        Global.world.decrementPlotCount(this.m_startingTerrainCode);
                        Global.world.incrementPlotCount(this.currentHoverOverTerrainCode);
                     }
                  }
               }
               SoundManager.playSound(SFX_DROP_ITEM_ID);
               this.m_selectedObject.setPosition(Math.round(releasedPoint.x),Math.round(releasedPoint.y));
               this.m_selectedObject.conditionallyReattach();
               this.m_selectedObject.onObjectDrop();
               this.m_objectPlacedSuccess = true;
               Global.world.popGameMode();
               if(Global.stage.hasEventListener(KeyboardEvent.KEY_UP))
               {
                  Global.stage.removeEventListener(KeyboardEvent.KEY_UP,this.onKeyUp);
               }
               if(this.m_isMoveTool)
               {
                  this.m_decoMove = new GMDecoMove();
                  Global.world.addGameMode(this.m_decoMove,true);
               }
               reOpenGiftIfNecessary();
            }
         }
         else if(this.m_containerCollision != null && this.m_containerCollision.isFull())
         {
            this.m_containerCollision.showStorageFullDialog();
            this.m_containerCollision = null;
         }
         else if(this.m_isMoveTool)
         {
            FarmStatsManager.count("movetool","movetool_pickup");
         }
         executeComponents("handleObjectDrop",event);
      }
   }
}

