package GameMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.BuildingDecoration;
   import Classes.Constants.ClickTrackingConstants;
   import Classes.Equipment;
   import Classes.FarmGameObject;
   import Classes.FarmGameWorld;
   import Classes.FeatureBuilding;
   import Classes.ItemInstance;
   import Classes.MapResource;
   import Classes.MiniGameDecoration;
   import Classes.Plot;
   import Classes.StorageBuilding;
   import Classes.Terrain.TerrainUtil;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.FarmDynamicDialog;
   import Display.UI;
   import Engine.Classes.TileMap;
   import Engine.Classes.WorldObject;
   import Engine.Constants;
   import Engine.Helpers.Vector2;
   import Engine.Helpers.Vector3;
   import Engine.IsoMath;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.SoundManager;
   import Engine.Utilities;
   import Managers.ClickTrackingManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureBuildingSurfacingManager;
   import Managers.FishingDerbyManager;
   import Widgets.Windows.FishingDerby.FishingDerbyStoreWindow;
   import Widgets.Windows.FishingDerby.FishingDerbyToasterWindow;
   import Widgets.Windows.FishingDerby.FishingTooltip;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.utils.Timer;
   
   public class GMFishing extends GMDefault
   {
      
      protected static var m_dialog:FarmDynamicDialog;
      
      private static const DELAY_AMOUNT:Number = 0.3;
      
      private static const SFX_DROP_ITEM_ID:String = "drop_place_item";
      
      private static const SFX_DROP_ITEM_URL:String = "assets/sounds/actions/sfx_drop_decoration.mp3";
      
      protected static const TILE_OUTLINE_WIDTH:int = 4;
      
      public static const FISHING_DISABLED:String = "fishing_disabled";
      
      public static const FISHING_CAST:String = "fishing_cast";
      
      protected var m_containerCollision:StorageBuilding;
      
      protected var m_cid:int;
      
      protected var m_highlightedPoint:Point;
      
      protected var m_selectedObject:FarmGameObject = null;
      
      protected var m_positionValid:Boolean = false;
      
      protected var m_objectStartPos:Vector2 = null;
      
      protected var m_objectPlacedSuccess:Boolean = false;
      
      protected var m_objectStoredSuccess:Boolean = false;
      
      protected var m_oldState:String;
      
      protected var m_isMoveTool:Boolean;
      
      protected var m_storedOrigin:int = 0;
      
      protected var m_containerCollided:Boolean = false;
      
      protected var m_dropSuspended:Boolean = false;
      
      protected var m_currency:String = "";
      
      private var m_decoMove:GMDecoMove;
      
      private var m_startingTerrainCode:int;
      
      private var m_objectSize:Vector3;
      
      private var m_params:Object;
      
      private var m_forcedMode:Boolean;
      
      private var m_reloadCurrentCursor:Boolean = true;
      
      private const BAIT_SHOP_IMAGE_URL:String = "assets/buildings/bldg_rusticbaitshop_icon.png";
      
      public function GMFishing(selectedObject:FarmGameObject = null, forcedMode:Boolean = false, optionalParmaters:Object = null)
      {
         var worldTileMap:TileMap = null;
         super();
         this.m_params = optionalParmaters;
         if(!this.m_params)
         {
            this.m_params = {};
         }
         this.m_forcedMode = forcedMode;
         if(selectedObject == null)
         {
            selectedObject = new MiniGameDecoration("xap_bobber");
            worldTileMap = Global.world.getTileMap();
            selectedObject.setOuter(Global.world);
            selectedObject.setPosition(worldTileMap.getWidth() / 2,worldTileMap.getHeight());
            selectedObject.conditionallyReattach(true);
            selectedObject.setVisible(true);
         }
         if(Global.world.getTopGameMode() is GMObjectMove)
         {
            Global.world.popGameMode();
         }
         this.m_selectedObject = selectedObject;
         if(selectedObject)
         {
            this.m_objectStartPos = selectedObject.getPosition().toVector2();
         }
         if(!Global.stage.hasEventListener(KeyboardEvent.KEY_UP))
         {
            Global.stage.addEventListener(KeyboardEvent.KEY_UP,onKeyUp,false,1,false);
         }
      }
      
      private static function reEnableGameMode(event:Event) : void
      {
         Global.world.removeEventListener(FishingDerbyToasterWindow.FISHING_TOASTER_CLOSE,reEnableGameMode);
         Global.world.getTopGameMode().disableMode();
         Global.world.popGameMode();
         Global.world.addGameMode(new GMFishing(),true);
      }
      
      public static function gotoBaitShop(event:Event) : void
      {
         var baitShopArray:Array = Global.world.getObjectsByCode("1lB");
         if(baitShopArray.length > 0)
         {
            UI.displayPopup(new FishingDerbyStoreWindow(baitShopArray[0],FishingDerbyStoreWindow.TAB_BAITS),true,"FishingDerbyStoreWindow",true);
         }
         if(m_dialog)
         {
            m_dialog.destroy();
         }
      }
      
      override public function canAdd() : Boolean
      {
         return true;
      }
      
      override public function enableMode() : void
      {
         super.enableMode();
         this.loadRodImage();
      }
      
      private function loadRodImage() : void
      {
         var currentRodName:String;
         var rodItem:FarmItem;
         var loader:Loader = null;
         UI.removeAllCursors();
         if(m_cursorId != 0)
         {
            UI.removeCursor(m_cursorId);
            m_cursorId = 0;
         }
         currentRodName = FishingDerbyManager.getFishingInventory()["rod"] as String;
         rodItem = Global.farmGameSettingsManager.getFarmItemByName(currentRodName);
         loader = LoadingManager.load(rodItem.icon,function(event:Event = null):void
         {
            var displayObject:* = loader.content;
            var bitmapData:* = new BitmapData(100,100,true,16777215);
            var horizontal:* = new Matrix();
            horizontal.scale(-1,1);
            horizontal.translate(bitmapData.width - 5,-5);
            bitmapData.draw(displayObject,horizontal);
            m_cursorImage = new Bitmap(bitmapData);
            m_cursorId = UI.setCursor(m_cursorImage,false,shouldScaleCursor(),100);
            m_reloadCurrentCursor = false;
            Global.world.addEventListener("equipRod",shouldReloadRodIcon);
         });
      }
      
      private function showRodCursor(shouldShow:Boolean) : void
      {
         if(shouldShow)
         {
            if(this.m_reloadCurrentCursor)
            {
               this.loadRodImage();
            }
            else
            {
               UI.updateCurrentCursorWithVisibility(true);
            }
         }
         else
         {
            UI.updateCurrentCursorWithVisibility(false);
         }
      }
      
      public function shouldReloadRodIcon(event:Event) : void
      {
         Global.world.removeEventListener("equipRod",this.shouldReloadRodIcon);
         this.m_reloadCurrentCursor = true;
      }
      
      override public function onMouseMove(event:MouseEvent) : Boolean
      {
         var newPos:Vector2 = null;
         super.onMouseMove(event);
         var currentPos:Point = getMouseStagePos();
         if(Boolean(m_viewDragStartPos) && Boolean(currentPos) && Boolean(m_mouseDownPos) && currentPos.subtract(m_mouseDownPos).length >= Constants.DRAG_CLICK_EPSILON)
         {
            m_dragging = true;
         }
         if(m_dragging && Boolean(m_viewDragStartPos))
         {
            newPos = new Vector2();
            newPos.x = m_viewDragStartPos.x + (currentPos.x - m_mouseDownPos.x) / GlobalEngine.viewport.getZoom();
            newPos.y = m_viewDragStartPos.y + (currentPos.y - m_mouseDownPos.y) / GlobalEngine.viewport.getZoom();
            GlobalEngine.viewport.setScrollPosition(newPos);
         }
         else if(this.m_selectedObject)
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
         this.updateOverlay();
         executeComponents("onMouseMove",event);
         return true;
      }
      
      override public function onMouseDown(event:MouseEvent) : Boolean
      {
         super.onMouseDown(event);
         m_viewDragStartPos = GlobalEngine.viewport.getScrollPosition().clone();
         m_dragging = false;
         if(this.m_selectedObject is FeatureBuilding)
         {
            (this.m_selectedObject as FeatureBuilding).showIndicator();
         }
         return true;
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
               this.m_selectedObject.setPosition(this.m_objectStartPos.x,this.m_objectStartPos.y);
               this.m_selectedObject.conditionallyReattach();
               this.m_selectedObject.postDisableMove();
               this.m_selectedObject.alpha = 1;
            }
         }
         super.disableMode();
         if(this.m_forcedMode)
         {
            Global.world.dispatchEvent(new Event(FISHING_DISABLED));
         }
      }
      
      protected function handleObjectDrop(event:MouseEvent) : void
      {
         var resource:MapResource = null;
         var origin:StorageBuilding = null;
         var resourceCode:String = null;
         var releasedPoint:Point = null;
         var objSize:Vector3 = null;
         var mapObject:MapResource = null;
         var fishingBaits:Object = null;
         var delayTimer:Timer = null;
         var message:String = null;
         this.m_positionValid = this.updateHighlightPoint(event);
         if(this.m_positionValid)
         {
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
               Global.player.removeInventoryItem(resource.getInventoryCode(),1,this.m_storedOrigin);
            }
            if(this.m_containerCollision != null)
            {
               Global.world.popGameMode();
               if(this.m_isMoveTool)
               {
                  Global.world.addGameMode(new GMDecoMove(),true);
               }
               else
               {
                  Global.world.addGameMode(new GMDefault());
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
                     fishingBaits = FishingDerbyManager.getFishingBaits();
                     if(fishingBaits["baits"][fishingBaits["active"]] > 0)
                     {
                        this.m_params.x = Math.round(releasedPoint.x);
                        this.m_params.y = Math.round(releasedPoint.y);
                        this.m_params.activeBait = fishingBaits["active"];
                        this.m_params.state = mapObject.getState();
                        this.m_params = mapObject.addTMoveParams(this.m_params);
                        this.m_selectedObject.centerOn();
                        Global.world.dispatchEvent(new Event(FISHING_CAST));
                        delayTimer = new Timer(Math.random() * 1500 + 2000,1);
                        delayTimer.addEventListener(TimerEvent.TIMER,this.showMiniGameWindow);
                        delayTimer.start();
                        FishingDerbyManager.instance.useFishingBait();
                        FishingDerbyManager.instance.useFishingBuff();
                        if(Global.world.getTopGameMode() is GMFishing)
                        {
                           Global.world.getTopGameMode().disableMode();
                           Global.world.popGameMode();
                           Global.world.addGameMode(new GMDefault());
                           if(!this.m_params["tutorial"])
                           {
                              Global.world.addEventListener(FishingDerbyToasterWindow.FISHING_TOASTER_CLOSE,reEnableGameMode);
                           }
                        }
                     }
                     else
                     {
                        message = ZLocUtils.t_pk("Dialogs","Fishingbait_finished");
                        m_dialog = UI.showMessage(message,UI.BUTTON_LAYOUT_ACCEPT,null,this.BAIT_SHOP_IMAGE_URL,true,gotoBaitShop,null,false,"Bait Shop");
                     }
                  }
               }
               SoundManager.playSound(SFX_DROP_ITEM_ID);
               this.m_selectedObject.setPosition(Math.round(releasedPoint.x),Math.round(releasedPoint.y));
               this.m_selectedObject.conditionallyReattach();
               this.m_selectedObject.onObjectDrop();
               this.m_objectPlacedSuccess = true;
               if(Global.stage.hasEventListener(KeyboardEvent.KEY_UP))
               {
                  Global.stage.removeEventListener(KeyboardEvent.KEY_UP,onKeyUp);
               }
               if(this.m_isMoveTool)
               {
                  this.m_decoMove = new GMDecoMove();
                  Global.world.addGameMode(this.m_decoMove,true);
               }
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
      
      private function showMiniGameWindow(event:Event = null) : void
      {
         UI.displayPopup(new FishingTooltip(this.m_params),false,"FishingTooltip",true);
      }
      
      private function get currentHoverOverTerrainCode() : int
      {
         var currentPos:Vector3 = this.m_selectedObject.getPosition();
         var endX:int = currentPos.x + this.m_objectSize.x;
         var endY:int = currentPos.y + this.m_objectSize.y;
         var hoverOverTerrainCodes:Array = TerrainUtil.getTerrainCodesInArea(currentPos.x,currentPos.y,endX,endY);
         return Global.farmGameSettingsManager.selectPrimaryTerrainCodeFromGivenCodes(hoverOverTerrainCodes);
      }
      
      override protected function updateOverlay() : void
      {
         var objSize:Vector3 = null;
         var pos:Point = null;
         var x:int = 0;
         var y:int = 0;
         var colFlags:int = 0;
         var color:int = 0;
         m_displayObject.graphics.clear();
         var drawTileArea:Boolean = true;
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
                        this.showRodCursor(true);
                     }
                     else
                     {
                        this.m_selectedObject.detach();
                        drawTileArea = false;
                        this.showRodCursor(false);
                     }
                     if(drawTileArea)
                     {
                        FarmGameWorld.drawTileArea(m_displayObject.graphics,pos,1,1);
                     }
                     m_displayObject.graphics.endFill();
                     ++pos.y;
                  }
                  ++pos.x;
               }
               if(drawTileArea)
               {
                  color = this.m_positionValid ? int(Constants.COLOR_VALID_PLACEMENT) : int(Constants.COLOR_NOT_VALID_PLACEMENT);
                  m_displayObject.graphics.lineStyle(TILE_OUTLINE_WIDTH,color,Constants.ALPHA_VALID_PLACEMENT);
                  m_displayObject.graphics.beginFill(0,0);
                  FarmGameWorld.drawTileArea(m_displayObject.graphics,this.m_highlightedPoint,objSize.x,objSize.y);
                  m_displayObject.graphics.endFill();
               }
            }
         }
      }
      
      override public function onMouseUp(event:MouseEvent) : Boolean
      {
         m_highlightedObject = null;
         if(m_dragging == false && !this.m_dropSuspended)
         {
            ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_PLACE_ITEM);
            this.handleObjectDrop(event);
         }
         m_dragging = false;
         m_viewDragStartPos = null;
         super.onMouseUp(event);
         return true;
      }
      
      override protected function selectObject(object:WorldObject, event:MouseEvent = null) : void
      {
         if(object != m_highlightedObject)
         {
            this.deselectObject();
            m_highlightedObject = object;
            if(object)
            {
               object.onMouseOver(event);
            }
         }
      }
      
      override protected function deselectObject() : void
      {
         if(m_highlightedObject)
         {
            m_highlightedObject.onMouseOut();
            m_highlightedObject = null;
         }
      }
      
      protected function updateHighlightPoint(event:MouseEvent) : Boolean
      {
         var idx:int = 0;
         var arrTerrainCodes:Array = null;
         var selectedItemInstance:ItemInstance = null;
         var hoverOverTerrainCodes:Array = null;
         var terrainCode:int = 0;
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
               arrTerrainCodes = Global.farmGameSettingsManager.getTerrainCodes(FarmGameSettingsManager.TERRAIN_LAND);
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
            }
         }
         return result;
      }
   }
}

