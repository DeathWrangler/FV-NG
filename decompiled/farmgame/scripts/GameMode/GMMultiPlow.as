package GameMode
{
   import AvatarMode.AMMultiPlow;
   import AvatarMode.AMPlow;
   import Classes.Avatar.FarmAvatar;
   import Classes.Constants.ClickTrackingConstants;
   import Classes.EmbeddedArt;
   import Classes.FarmGameWorld;
   import Classes.Plot;
   import Classes.Terrain.TerrainUtil;
   import Classes.WorldObjectTypes;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Display.UnwitherDialog;
   import Engine.Classes.WorldObject;
   import Engine.Constants;
   import Engine.Utilities;
   import Managers.ClickTrackingManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.getDefinitionByName;
   
   public class GMMultiPlow extends GMDefault
   {
      
      protected static const TILE_OUTLINE_WIDTH:int = 4;
      
      private static const CURSOR_PPH_BASE_IMG:String = "cursor_plow_PPH_limit_";
      
      private var m_maxPlowSize:Number = 1;
      
      private var m_highlightedPoint:Point;
      
      private var m_dragStartPos:Point;
      
      protected var m_plot:Plot;
      
      protected var m_hasWorldPlotLimits:Boolean = false;
      
      private var m_terrainCode:int = -1;
      
      private var m_pphCursorBaseImgPrefix:String = null;
      
      public function GMMultiPlow()
      {
         super();
         this.m_pphCursorBaseImgPrefix = CURSOR_PPH_BASE_IMG;
         this.setTerrainCode(TerrainUtil.DEFAULT_TERRAIN_CODE);
      }
      
      private function setTerrainCode(terrainCode:int) : void
      {
         var terrainLimitGroupName:String = null;
         var baseImg:Object = null;
         var asset:MovieClip = null;
         var loader:Loader = null;
         var info:LoaderInfo = null;
         if(m_cursorImage == null || this.m_terrainCode != terrainCode)
         {
            this.m_terrainCode = terrainCode;
            this.m_hasWorldPlotLimits = Global.worldManager.currentWorldHasPlotLimits;
            if(this.m_hasWorldPlotLimits)
            {
               terrainLimitGroupName = Global.worldManager.getLimitGroupNameByTerrainCode(this.m_terrainCode);
               baseImg = this.getPrefixedItemImageForPPHCursor(terrainLimitGroupName);
               asset = baseImg as MovieClip;
               loader = asset.getChildAt(0) as Loader;
               info = loader.contentLoaderInfo;
               info.addEventListener(Event.COMPLETE,this.onCursorLoadedCallback);
               m_cursorImage = null;
            }
            else
            {
               m_cursorImage = new EmbeddedArt.cursor_plow() as MovieClip;
            }
         }
      }
      
      protected function getPrefixedItemImageForPPHCursor(terrainName:String) : Object
      {
         var imageForPlot:Object = null;
         var embeddedArtKey:String = this.m_pphCursorBaseImgPrefix + terrainName;
         var cursorForTractor:Object = null;
         var embeddedArtKeyForWorldType:String = embeddedArtKey + "_" + Global.worldManager.currentWorldType;
         cursorForTractor = EmbeddedArt[embeddedArtKeyForWorldType];
         embeddedArtKey = cursorForTractor == null ? embeddedArtKey : embeddedArtKeyForWorldType;
         return new EmbeddedArt[embeddedArtKey]();
      }
      
      private function onCursorLoadedCallback(event:Event) : void
      {
         var info:LoaderInfo = event.target as LoaderInfo;
         info.removeEventListener(Event.COMPLETE,this.onCursorLoadedCallback);
         m_cursorImage = info.loader.content as MovieClip;
         m_cursorImage.cursor_mc.count_tf.text = Global.world.getNumPlots(this.m_terrainCode);
         m_cursorImage.cursor_mc.count2_tf.text = ZLocUtils.t("FarmGame","of") + " " + Global.worldManager.getMaximumPlotsAllowed(this.m_terrainCode);
      }
      
      override protected function getSelectableTypes() : int
      {
         return WorldObjectTypes.PLOT;
      }
      
      override protected function isObjectSelectable(object:WorldObject) : Boolean
      {
         var result:Boolean = false;
         var plot:Plot = object as Plot;
         if(Boolean(plot) && plot.isPlowable())
         {
            result = true;
         }
         return result;
      }
      
      override protected function getCursor() : Object
      {
         return m_cursorImage;
      }
      
      override protected function shouldScaleCursor() : Boolean
      {
         return !this.m_hasWorldPlotLimits;
      }
      
      override public function onMouseMove(event:MouseEvent) : Boolean
      {
         super.onMouseMove(event);
         if(m_highlightedObject == null && m_dragging == false)
         {
            this.m_highlightedPoint = getMouseTilePos();
            this.m_highlightedPoint.x = Utilities.clamp(this.m_highlightedPoint.x,0,Global.world.getGridWidth() - Plot.SIZE_X);
            this.m_highlightedPoint.y = Utilities.clamp(this.m_highlightedPoint.y,0,Global.world.getGridHeight() - Plot.SIZE_Y);
            this.m_highlightedPoint.x = Math.floor(this.m_highlightedPoint.x);
            this.m_highlightedPoint.y = Math.floor(this.m_highlightedPoint.y);
         }
         else
         {
            this.m_highlightedPoint = null;
         }
         this.updateOverlay();
         return true;
      }
      
      override public function onMouseDown(event:MouseEvent) : Boolean
      {
         super.onMouseDown(event);
         this.m_dragStartPos = getMouseTilePos();
         this.m_dragStartPos.x = Utilities.clamp(this.m_dragStartPos.x,0,Global.world.getGridWidth() - Plot.SIZE_X);
         this.m_dragStartPos.y = Utilities.clamp(this.m_dragStartPos.y,0,Global.world.getGridHeight() - Plot.SIZE_Y);
         this.m_dragStartPos.x = Math.floor(this.m_dragStartPos.x);
         this.m_dragStartPos.y = Math.floor(this.m_dragStartPos.y);
         return true;
      }
      
      override public function onMouseUp(event:MouseEvent) : Boolean
      {
         super.onMouseUp(event);
         this.m_dragStartPos = null;
         deselectObject();
         return true;
      }
      
      override public function dispatchAddToStackEvent() : void
      {
         Global.world.dispatchEvent(new Event(EVENT_PPH_WARNING_PLOW));
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         var avatar:FarmAvatar = null;
         var worldPlotCostData:Object = null;
         var remainingPlotsAllowed:int = 0;
         var tileSize:Point = null;
         var startPos:Point = null;
         var plots:Array = null;
         var upRow:Boolean = false;
         var tileX:int = 0;
         var tileY:int = 0;
         var plot:Plot = null;
         var yPos:int = 0;
         var unwitherDialogShown:Boolean = UnwitherDialog.showUnwitherDialogIfAppropriate();
         var terrainLimitGroupName:String = Global.worldManager.getLimitGroupNameByTerrainCode(this.m_terrainCode);
         if(!unwitherDialogShown)
         {
            ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_PLOW);
            avatar = Global.selectedAvatar;
            if(this.canPlow())
            {
               if(Boolean(avatar) && Boolean(Global.player))
               {
                  if(m_highlightedObject)
                  {
                     this.m_plot = m_highlightedObject as Plot;
                     if(this.m_plot)
                     {
                        FarmStatsManager.count("farm_world_actions","plow","Plot","plow_no_vehicle",terrainLimitGroupName);
                        avatar.getStateMachine().addState(new AMPlow(avatar,this.m_plot),true);
                     }
                  }
                  else if(Global.world.checkNumObjectLimit())
                  {
                     worldPlotCostData = Plot.getWorldPlowPlotCostData();
                     if(Global.player.canBuyWithCurrency(worldPlotCostData.currencyUnit,worldPlotCostData.cost))
                     {
                        remainingPlotsAllowed = Global.worldManager.getRemainingPlotsAllowed(this.m_terrainCode);
                        tileSize = this.getTileDragSize();
                        startPos = this.getTileSquareStart();
                        plots = [];
                        upRow = false;
                        for(tileX = 0; tileX < tileSize.x; tileX += Plot.SIZE_X)
                        {
                           for(tileY = 0; tileY < tileSize.y; tileY += Plot.SIZE_Y)
                           {
                              plot = new Plot();
                              plot.setOuter(Global.world);
                              yPos = upRow ? tileY : int(tileSize.y - tileY - Plot.SIZE_Y);
                              plot.setPosition(startPos.x + tileX,startPos.y + yPos);
                              plot.attach();
                              plots.push(plot);
                              Global.world.incrementPlotCount(this.m_terrainCode);
                              Global.worldManager.checkPPHLimitReached(this.m_terrainCode);
                              if(remainingPlotsAllowed <= plots.length)
                              {
                                 break;
                              }
                           }
                           if(remainingPlotsAllowed <= plots.length)
                           {
                              break;
                           }
                           upRow = !upRow;
                        }
                        FarmStatsManager.count("farm_world_actions","plow","Plot","plow_no_vehicle",terrainLimitGroupName);
                        if(this.m_hasWorldPlotLimits && Boolean(m_cursorImage))
                        {
                           m_cursorImage.cursor_mc.count_tf.text = Global.world.getNumPlots(this.m_terrainCode);
                        }
                        avatar.getStateMachine().addState(new AMMultiPlow(avatar,plots),true);
                     }
                  }
                  else
                  {
                     UI.displayMessage(ZLocUtils.t("Dialogs","Maxed_Objects_Full"));
                     Global.world.addGameMode(this);
                  }
               }
            }
            else
            {
               Global.worldManager.checkPPHLimitReached(this.m_terrainCode);
            }
         }
      }
      
      protected function getTileSquareStart() : Point
      {
         var startPoint:Point = this.m_highlightedPoint.clone();
         if(this.m_dragStartPos)
         {
            startPoint = this.m_dragStartPos.clone();
         }
         var dragSize:Point = this.getTileDragSize();
         var diff:Point = this.m_highlightedPoint.subtract(startPoint);
         if(diff.x < 0)
         {
            startPoint.x = startPoint.x - dragSize.x + Plot.SIZE_X;
         }
         if(diff.y < 0)
         {
            startPoint.y = startPoint.y - dragSize.y + Plot.SIZE_Y;
         }
         return startPoint;
      }
      
      protected function getTileDragSize() : Point
      {
         var startPoint:Point = this.m_highlightedPoint.clone();
         if(this.m_dragStartPos)
         {
            startPoint = this.m_dragStartPos.clone();
         }
         var size:Point = new Point();
         var diff:Point = this.m_highlightedPoint.subtract(startPoint);
         diff.x /= Plot.SIZE_X;
         if(diff.x < 0)
         {
            size.x = Math.ceil(-diff.x);
         }
         else
         {
            size.x = Math.floor(diff.x);
         }
         diff.y /= Plot.SIZE_Y;
         if(diff.y < 0)
         {
            size.y = Math.ceil(-diff.y);
         }
         else
         {
            size.y = Math.floor(diff.y);
         }
         if(this.m_maxPlowSize == 1)
         {
            size.x = 0;
            size.y = 0;
         }
         size.x = (size.x + 1) * Plot.SIZE_X;
         size.y = (size.y + 1) * Plot.SIZE_Y;
         return size;
      }
      
      protected function canPlow() : Boolean
      {
         var plot:Plot = null;
         var startPos:Point = null;
         var tileSize:Point = null;
         var flags:int = 0;
         var terrainCodeArray:Array = null;
         var arrAcceptableTerrain:Array = null;
         var result:Boolean = false;
         if(m_highlightedObject)
         {
            plot = m_highlightedObject as Plot;
            if(plot)
            {
               result = plot.isPlowable();
            }
         }
         else if(this.m_highlightedPoint)
         {
            startPos = this.getTileSquareStart();
            tileSize = this.getTileDragSize();
            flags = Constants.WORLDOBJECT_ALL_EXCEPT_AVATAR;
            terrainCodeArray = TerrainUtil.getTerrainCodesInArea(startPos.x,startPos.y,startPos.x + 1,startPos.y + 1);
            if(terrainCodeArray.length > 0)
            {
               this.setTerrainCode(Global.farmGameSettingsManager.selectPrimaryTerrainCodeFromGivenCodes(terrainCodeArray));
            }
            if(Global.worldManager.getRemainingPlotsAllowed(this.m_terrainCode) > 0 && Global.world.checkCollision(startPos.x,startPos.y,startPos.x + tileSize.x,startPos.y + tileSize.y,[],null,flags,null,true) == false)
            {
               arrAcceptableTerrain = Global.farmGameSettingsManager.getTerrainCodes(FarmGameSettingsManager.TERRAIN_PLOWABLE);
               if(TerrainUtil.isAreaAcceptable(arrAcceptableTerrain,startPos.x,startPos.y,startPos.x + tileSize.x,startPos.y + tileSize.y))
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      override protected function updateOverlay() : void
      {
         var color:uint = 0;
         var alpha:Number = NaN;
         var startPoint:Point = null;
         var tileSize:Point = null;
         m_displayObject.graphics.clear();
         if(this.m_highlightedPoint)
         {
            if(this.canPlow())
            {
               color = Constants.COLOR_VALID_PLACEMENT;
               alpha = Constants.ALPHA_VALID_PLACEMENT;
            }
            else
            {
               color = Constants.COLOR_NOT_VALID_PLACEMENT;
               alpha = Constants.ALPHA_NOT_VALID_PLACEMENT;
            }
            startPoint = this.getTileSquareStart();
            tileSize = this.getTileDragSize();
            m_displayObject.graphics.lineStyle(TILE_OUTLINE_WIDTH,color,1);
            m_displayObject.graphics.beginFill(color,0.5);
            FarmGameWorld.drawTileArea(m_displayObject.graphics,startPoint,tileSize.x,tileSize.y);
            m_displayObject.graphics.endFill();
         }
      }
   }
}

