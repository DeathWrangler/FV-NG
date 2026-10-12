package Classes.UserDrivenTerrain
{
   import Classes.Terrain.Terrain;
   import Classes.Terrain.TerrainConfigManager;
   import Classes.Terrain.TerrainUtil;
   import Display.FarmTerrainMap;
   import Engine.Classes.Tile;
   import Engine.Classes.Viewport;
   import Engine.Constants;
   import Engine.Helpers.Vector2;
   import flash.display.BitmapData;
   import flash.geom.Point;
   
   public class UDTMap implements FarmTerrainMap
   {
      
      public static const CHANGED_POINTS_FLUSH_THRESHOLD:int = 5;
      
      protected var m_width:uint = 0;
      
      protected var m_height:uint = 0;
      
      protected var m_deltaBitmap:BitmapData = null;
      
      protected var m_dataWidth:uint = 0;
      
      protected var m_dataHeight:uint = 0;
      
      protected var m_defaultPoint:UDTDataPoint;
      
      protected var m_defaultTile:UDTTile;
      
      protected var m_tiles:Array;
      
      protected var m_generateBitmaps:Boolean;
      
      protected var m_dirty:Boolean = false;
      
      protected var m_config:Object = null;
      
      protected var m_dataPoints:Array = null;
      
      protected var m_neighboringPoints:Array = new Array(8);
      
      protected var m_loaded:Boolean = false;
      
      protected var m_changedPoints:Array;
      
      protected var m_renderOrderDirty:Boolean = true;
      
      protected var m_originX:int = 0;
      
      protected var m_originY:int = 0;
      
      private var m_curPoint:Point = new Point(0,0);
      
      protected var m_bitmapData:BitmapData = null;
      
      public function UDTMap()
      {
         super();
         this.m_defaultPoint = new UDTDataPoint();
         this.m_defaultPoint.setCode(TerrainUtil.DEFAULT_TERRAIN_CODE);
         this.m_defaultTile = new UDTTile(this.m_defaultPoint,0);
         this.m_defaultTile.parentPoint = this.m_defaultPoint;
         this.m_changedPoints = new Array();
      }
      
      public function setTileType(a_baseTerrainName:String, forceCreateTiles:Boolean = false) : void
      {
         if(forceCreateTiles)
         {
            this.determineAllDataPoints();
         }
      }
      
      private function setConfigObject(configObject:Terrain) : void
      {
         this.m_config = configObject;
         UDTConfig.setDefaultTerrainCode(this.m_config.code);
      }
      
      public function loadObject(points:Array, sizeX:uint, sizeY:uint) : void
      {
         var i:int = 0;
         var j:int = 0;
         var point:UDTDataPoint = null;
         var loadData:Boolean = false;
         var configObject:Terrain = TerrainConfigManager.getInstance().getConfigObject(UDTConfig.INVISIBLE_TERRAIN_CODE);
         if(configObject != null)
         {
            this.setConfigObject(configObject);
            this.m_dataHeight = sizeY;
            this.m_dataWidth = sizeX;
            this.m_width = 2 * this.m_dataWidth;
            this.m_height = 2 * this.m_dataHeight;
            this.m_dataPoints = new Array(this.m_dataWidth * this.m_dataHeight);
            this.m_tiles = new Array(this.m_width * this.m_height);
            if(null != points && points.length > 0)
            {
               loadData = true;
            }
            for(i = 0; i < this.m_dataWidth; i++)
            {
               for(j = 0; j < this.m_dataHeight; j++)
               {
                  point = new UDTDataPoint();
                  this.m_dataPoints[j * this.m_dataWidth + i] = point;
                  if(loadData)
                  {
                     point.setCode(points[j * this.m_dataWidth + i]);
                  }
                  else
                  {
                     point.setCode(TerrainUtil.DEFAULT_TERRAIN_CODE);
                  }
                  this.m_tiles[(2 * j + 1) * this.m_width + 2 * i + 1] = new UDTTile(point,Math.sin((2 * i + 1) * 97 + (2 * j + 1)) * 214013);
                  this.m_tiles[2 * j * this.m_width + 2 * i + 1] = new UDTTile(point,Math.sin((2 * i + 1) * 97 + 2 * j) * 214013);
                  this.m_tiles[2 * j * this.m_width + 2 * i] = new UDTTile(point,Math.sin(2 * i * 97 + 2 * j) * 214013);
                  this.m_tiles[(2 * j + 1) * this.m_width + 2 * i] = new UDTTile(point,Math.sin(2 * i * 97 + (2 * j + 1)) * 214013);
               }
            }
            this.determineAllDataPoints();
            this.m_loaded = true;
            return;
         }
         throw new Error("UDTMap fatal error: invisible terrain was not found");
      }
      
      public function get width() : uint
      {
         return this.m_width;
      }
      
      public function get height() : uint
      {
         return this.m_height;
      }
      
      public function tileAt(a_tileX:uint, a_tileY:uint) : Tile
      {
         return this.m_loaded ? this.m_tiles[a_tileY * this.m_width + a_tileX] : this.m_defaultTile;
      }
      
      protected function determineAllDataPoints() : void
      {
         var i:int = 0;
         var j:int = 0;
         for(i = 0; i < this.m_dataWidth; i++)
         {
            for(j = 0; j < this.m_dataHeight; j++)
            {
               this.determineOneDataPoint(i,j);
            }
         }
         this.determineRenderOrder();
      }
      
      protected function determineChangedDataPoints(x:int, y:int) : void
      {
         var i:int = 0;
         var j:int = 0;
         var maxY:int = y + 1 < this.m_dataHeight ? int(y + 2) : int(this.m_dataHeight);
         var maxX:int = x + 1 < this.m_dataWidth ? int(x + 2) : int(this.m_dataWidth);
         var minY:int = y - 1 >= 0 ? int(y - 1) : 0;
         var minX:int = x - 1 >= 0 ? int(x - 1) : 0;
         for(i = minX; i < maxX; i++)
         {
            for(j = minY; j < maxY; j++)
            {
               this.determineOneDataPoint(i,j);
            }
         }
         this.determineRenderOrder(true,x * 2,y * 2);
      }
      
      protected function determineLayers(tile0:UDTTile, point1:UDTDataPoint, point2:UDTDataPoint, point3:UDTDataPoint) : void
      {
         var height0:Number = tile0.parentPoint.getHeight();
         var height1:Number = point1.getHeight();
         var height2:Number = point2.getHeight();
         var height3:Number = point3.getHeight();
         if(height2 >= height3 && height2 >= height1)
         {
            height2 = Number.MAX_VALUE;
         }
         if(height1 >= height0)
         {
            if(height2 >= height0)
            {
               if(height3 >= height0)
               {
                  tile0.point1 = null;
                  tile0.point2 = null;
                  tile0.point3 = null;
               }
               else
               {
                  tile0.point1 = point3;
                  tile0.point2 = null;
                  tile0.point3 = null;
               }
            }
            else if(height3 >= height0 || height3 == height2)
            {
               tile0.point1 = point2;
               tile0.point2 = null;
               tile0.point3 = null;
            }
            else if(height2 > height3)
            {
               tile0.point1 = point2;
               tile0.point2 = point3;
               tile0.point3 = null;
            }
            else
            {
               tile0.point1 = point3;
               tile0.point2 = point2;
               tile0.point3 = null;
            }
         }
         else if(height2 >= height0 || height2 == height1)
         {
            if(height3 >= height0 || height3 == height1)
            {
               tile0.point1 = point1;
               tile0.point2 = null;
               tile0.point3 = null;
            }
            else if(height1 > height3)
            {
               tile0.point1 = point1;
               tile0.point2 = point3;
               tile0.point3 = null;
            }
            else
            {
               tile0.point1 = point3;
               tile0.point2 = point1;
               tile0.point3 = null;
            }
         }
         else if(height3 >= height0 || height3 == height2 || height3 == height1)
         {
            if(height1 > height2)
            {
               tile0.point1 = point1;
               tile0.point2 = point2;
               tile0.point3 = null;
            }
            else
            {
               tile0.point1 = point2;
               tile0.point2 = point1;
               tile0.point3 = null;
            }
         }
         else if(height1 > height2 && height1 > height3)
         {
            tile0.point1 = point1;
            if(height2 > height3)
            {
               tile0.point2 = point2;
               tile0.point3 = point3;
            }
            else
            {
               tile0.point2 = point3;
               tile0.point3 = point2;
            }
         }
         else if(height2 > height3)
         {
            tile0.point1 = point2;
            if(height1 > height3)
            {
               tile0.point2 = point1;
               tile0.point3 = point3;
            }
            else
            {
               tile0.point2 = point3;
               tile0.point3 = point1;
            }
         }
         else
         {
            tile0.point1 = point3;
            if(height1 > height2)
            {
               tile0.point2 = point1;
               tile0.point3 = point2;
            }
            else
            {
               tile0.point2 = point2;
               tile0.point3 = point1;
            }
         }
      }
      
      protected function setNeighboringPoints(x:int, y:int) : void
      {
         this.m_neighboringPoints[0] = y - 1 >= 0 && x - 1 >= 0 ? this.m_dataPoints[x - 1 + (y - 1) * this.m_dataWidth] : this.m_defaultPoint;
         this.m_neighboringPoints[1] = x - 1 >= 0 ? this.m_dataPoints[x - 1 + y * this.m_dataWidth] : this.m_defaultPoint;
         this.m_neighboringPoints[2] = y - 1 >= 0 ? this.m_dataPoints[x + (y - 1) * this.m_dataWidth] : this.m_defaultPoint;
         this.m_neighboringPoints[3] = y + 1 < this.m_dataHeight && x - 1 >= 0 ? this.m_dataPoints[x - 1 + (y + 1) * this.m_dataWidth] : this.m_defaultPoint;
         this.m_neighboringPoints[4] = y - 1 >= 0 && x + 1 < this.m_dataWidth ? this.m_dataPoints[x + 1 + (y - 1) * this.m_dataWidth] : this.m_defaultPoint;
         this.m_neighboringPoints[5] = y + 1 < this.m_dataHeight ? this.m_dataPoints[x + (y + 1) * this.m_dataWidth] : this.m_defaultPoint;
         this.m_neighboringPoints[6] = x + 1 < this.m_dataWidth ? this.m_dataPoints[x + 1 + y * this.m_dataWidth] : this.m_defaultPoint;
         this.m_neighboringPoints[7] = y + 1 < this.m_dataHeight && x + 1 < this.m_dataWidth ? this.m_dataPoints[x + 1 + (y + 1) * this.m_dataWidth] : this.m_defaultPoint;
      }
      
      protected function determineOneDataPoint(x:int, y:int) : void
      {
         var point:UDTDataPoint = this.m_dataPoints[y * this.m_dataWidth + x];
         this.setNeighboringPoints(x,y);
         this.determineOneTile(this.m_tiles[(y * 2 + 1) * this.m_width + x * 2 + 1],0,point,this.m_neighboringPoints[5],this.m_neighboringPoints[7],this.m_neighboringPoints[6]);
         this.determineOneTile(this.m_tiles[y * 2 * this.m_width + x * 2 + 1],1,point,this.m_neighboringPoints[6],this.m_neighboringPoints[4],this.m_neighboringPoints[2]);
         this.determineOneTile(this.m_tiles[y * 2 * this.m_width + x * 2],2,point,this.m_neighboringPoints[2],this.m_neighboringPoints[0],this.m_neighboringPoints[1]);
         this.determineOneTile(this.m_tiles[(y * 2 + 1) * this.m_width + x * 2],3,point,this.m_neighboringPoints[1],this.m_neighboringPoints[3],this.m_neighboringPoints[5]);
      }
      
      protected function determineOneTile(tile:UDTTile, direction:int, terrain0:UDTDataPoint, terrain1:UDTDataPoint, terrain2:UDTDataPoint, terrain3:UDTDataPoint) : void
      {
         this.determineLayers(tile,terrain1,terrain2,terrain3);
         tile.code = this.determineOneTileTypeTop(direction,terrain0.getHeight(),terrain1.getHeight(),terrain2.getHeight(),terrain3.getHeight());
         if(tile.code > 0 && tile.point1 != null)
         {
            tile.neighborType1 = this.determineOneTileTypeBottom(direction,tile.point1.getHeight(),terrain1.getHeight(),terrain2.getHeight(),terrain3.getHeight());
            if(tile.neighborType1 > 0 && tile.point2 != null)
            {
               tile.neighborType2 = this.determineOneTileTypeBottom(direction,tile.point2.getHeight(),terrain1.getHeight(),terrain2.getHeight(),terrain3.getHeight());
               if(tile.neighborType2 > 0 && tile.point3 != null)
               {
                  tile.neighborType3 = 0;
               }
               else
               {
                  tile.neighborType3 = -1;
               }
            }
            else
            {
               tile.neighborType2 = -1;
               tile.neighborType3 = -1;
            }
         }
         else
         {
            tile.neighborType1 = -1;
            tile.neighborType2 = -1;
            tile.neighborType3 = -1;
         }
         if(terrain0.getPalette().isWet || terrain1.getPalette().isWet || terrain2.getPalette().isWet || terrain3.getPalette().isWet)
         {
            if(tile.code > 0 && terrain0.getPalette().numTypes == UDTConfig.TYPE_COUNT_WET_EDGES)
            {
               tile.code += 12;
            }
            if(tile.neighborType1 > 0 && tile.point1 != null && tile.point1.getPalette().numTypes == UDTConfig.TYPE_COUNT_WET_EDGES)
            {
               tile.neighborType1 += 12;
            }
            if(tile.neighborType2 > 0 && tile.point2 != null && tile.point2.getPalette().numTypes == UDTConfig.TYPE_COUNT_WET_EDGES)
            {
               tile.neighborType2 += 12;
            }
            if(tile.neighborType3 > 0 && tile.point3 != null && tile.point3.getPalette().numTypes == UDTConfig.TYPE_COUNT_WET_EDGES)
            {
               tile.neighborType3 += 12;
            }
         }
      }
      
      protected function determineOneTileTypeTop(direction:int, terrain0:Number, terrain1:Number, terrain2:Number, terrain3:Number) : int
      {
         var type:int = 0;
         if(terrain1 < terrain0)
         {
            if(terrain3 < terrain0)
            {
               type = 1 + direction;
            }
            else
            {
               type = 5 + (3 + direction & 3);
            }
         }
         else if(terrain3 < terrain0)
         {
            type = 5 + direction;
         }
         else if(terrain2 < terrain0)
         {
            type = 9 + direction;
         }
         else
         {
            type = 0;
         }
         return type;
      }
      
      protected function determineOneTileTypeBottom(direction:int, terrain0:Number, terrain1:Number, terrain2:Number, terrain3:Number) : int
      {
         var type:int = 0;
         if(terrain1 > terrain0)
         {
            if(terrain3 > terrain0)
            {
               if(terrain2 == terrain0)
               {
                  type = 0;
               }
               else
               {
                  type = -1;
               }
            }
            else if(terrain3 == terrain0)
            {
               if(terrain2 >= terrain0)
               {
                  type = 0;
               }
               else
               {
                  type = 9 + direction;
               }
            }
            else if(terrain2 == terrain0)
            {
               type = 1 + (1 + direction & 3);
            }
            else
            {
               type = -1;
            }
         }
         else if(terrain1 == terrain0)
         {
            if(terrain3 > terrain0)
            {
               if(terrain2 >= terrain0)
               {
                  type = 0;
               }
               else
               {
                  type = 9 + direction;
               }
            }
            else if(terrain3 == terrain0)
            {
               if(terrain2 >= terrain0)
               {
                  type = 0;
               }
               else
               {
                  type = 9 + direction;
               }
            }
            else
            {
               type = 1 + (1 + direction & 3);
            }
         }
         else if(terrain3 > terrain0)
         {
            if(terrain2 == terrain0)
            {
               type = 1 + (3 + direction & 3);
            }
            else
            {
               type = -1;
            }
         }
         else if(terrain3 == terrain0)
         {
            type = 1 + (3 + direction & 3);
         }
         else
         {
            type = -1;
         }
         return type;
      }
      
      public function determineRenderOrder(deltaOnly:Boolean = false, bottomX:int = -1, bottomY:int = -1) : void
      {
         var i:int = 0;
         var j:int = 0;
         var start:int = 0;
         var end:int = 0;
         var tile:UDTTile = null;
         var palettes:Array = UDTConfig.getSortedPalettes();
         var tileIndex:int = 0;
         for(i = 0; i < palettes.length; i++)
         {
            (palettes[i] as UDTPaletteEntry).resetTiles();
         }
         var minI:int = 0;
         var maxI:int = (this.m_width - 1) * 2;
         var minJ:Number = 0;
         var maxJ:Number = Number.MAX_VALUE;
         if(deltaOnly)
         {
            minI = bottomX + bottomY - 3;
            minJ = bottomY - 3;
            maxJ = bottomY + 1.5;
            if(minI < 0)
            {
               minJ += -minI * 0.5;
               maxJ += -minI * 0.5;
               minI = 0;
            }
            maxI = bottomX + bottomY + 5;
            if(maxI > (this.m_width - 1) * 2)
            {
               maxI = (this.m_width - 1) * 2;
            }
         }
         for(i = minI; i <= maxI; i++)
         {
            start = i >= this.m_width ? int(i - this.m_width + 1) : 0;
            end = i >= this.m_height ? int(this.m_height) : int(i + 1);
            if(deltaOnly)
            {
               if(start < minJ)
               {
                  start = minJ < 0 ? 0 : int(minJ);
               }
               minJ += 0.5;
               if(end > maxJ)
               {
                  end = maxJ > this.m_height ? int(this.m_height) : int(maxJ);
               }
               maxJ += 0.5;
            }
            for(j = start; j < end; j++)
            {
               tileIndex = j * this.m_width + (i - j);
               tile = this.m_tiles[tileIndex];
               if(tile.point3 != null)
               {
                  tile.point3.getPalette().addTile(tileIndex,deltaOnly);
               }
               if(tile.point2 != null)
               {
                  tile.point2.getPalette().addTile(tileIndex,deltaOnly);
               }
               if(tile.point1 != null)
               {
                  tile.point1.getPalette().addTile(tileIndex,deltaOnly);
               }
               if(tile.parentPoint != null)
               {
                  tile.parentPoint.getPalette().addTile(tileIndex,deltaOnly);
               }
            }
         }
         this.m_renderOrderDirty = deltaOnly;
      }
      
      public function getDataPointCode(x:uint, y:uint) : int
      {
         var result:int = 0;
         if(x >= 0 && x < this.m_dataWidth && y >= 0 && y < this.m_dataHeight)
         {
            result = (this.m_dataPoints[y * this.m_dataWidth + x] as UDTDataPoint).code;
         }
         return result;
      }
      
      public function setDataPoint(x:uint, y:uint, a_code:int, sendTransaction:Boolean = false, actionType:int = 0, x2:uint = 0, y2:uint = 0) : void
      {
         var tmpTerrainAction:TerrainAction = null;
         if(x >= 0 && x < this.m_dataWidth && y >= 0 && y < this.m_dataHeight)
         {
            (this.m_dataPoints[y * this.m_dataWidth + x] as UDTDataPoint).setCode(a_code);
            this.determineChangedDataPoints(x,y);
            this.setDirty(true);
            if(sendTransaction && actionType > 0)
            {
               tmpTerrainAction = null;
               switch(actionType)
               {
                  case TerrainActionConstants.ACTION_PLACE:
                     tmpTerrainAction = new TerrainAction(new TerrainPlaceActionData(x,y,a_code),TerrainActionConstants.ACTION_PLACE);
                     break;
                  case TerrainActionConstants.ACTION_CLEAR:
                     tmpTerrainAction = new TerrainAction(new TerrainClearActionData(x,y),TerrainActionConstants.ACTION_CLEAR);
                     break;
                  case TerrainActionConstants.ACTION_MOVE:
                     tmpTerrainAction = new TerrainAction(new TerrainMoveActionData(x,y,x2,y2),TerrainActionConstants.ACTION_MOVE);
                     break;
                  default:
                     tmpTerrainAction = null;
               }
               if(tmpTerrainAction != null)
               {
                  this.m_changedPoints.push(tmpTerrainAction);
                  if(this.m_changedPoints.length >= CHANGED_POINTS_FLUSH_THRESHOLD)
                  {
                  }
               }
            }
         }
      }
      
      public function flushTranscation() : void
      {
         if(this.m_changedPoints.length > 0)
         {
            this.m_changedPoints = new Array();
         }
      }
      
      public function getCurrentTerrainCodeMapping() : Array
      {
         var terrainMappingArray:Array = new Array(this.m_dataPoints.length);
         for(var i:int = 0; i < this.m_dataPoints.length; i++)
         {
            terrainMappingArray[i] = this.m_dataPoints[i].code;
         }
         return terrainMappingArray;
      }
      
      public function setTile(a_tileX:uint, a_tileY:uint, tile:Tile) : void
      {
      }
      
      public function isPathable(a_tileX:uint, a_tileY:uint) : Boolean
      {
         return (this.m_tiles[a_tileY * this.m_width + a_tileX] as UDTTile).parentPoint.getPalette().pathable;
      }
      
      public function isDirty() : Boolean
      {
         return this.m_dirty;
      }
      
      public function setDirty(a_dirty:Boolean) : void
      {
         this.m_dirty = a_dirty;
      }
      
      public function getSortedPalettes(deltaOnly:Boolean = false) : Array
      {
         if(!deltaOnly && this.m_renderOrderDirty)
         {
            this.determineRenderOrder();
         }
         return UDTConfig.getSortedPalettes();
      }
      
      public function renderFast(bitmapData:BitmapData) : void
      {
         var tile:UDTTile = null;
         var tileIndeces:Array = null;
         var palettes:Array = null;
         var layer:BitmapData = null;
         var x:int = 0;
         var y:int = 0;
         var i:int = 0;
         var j:int = 0;
         this.m_bitmapData = bitmapData;
         var zoomLevel:Number = GlobalEngine.viewport.getZoom();
         var tileWidth:Number = Constants.TILE_WIDTH * zoomLevel;
         var tileHeight:Number = Constants.TILE_HEIGHT * zoomLevel;
         var sizeY:int = bitmapData.height - tileHeight;
         var sizeX:int = bitmapData.width - tileWidth;
         tileWidth /= Constants.TILE_SCALE;
         tileHeight /= Constants.TILE_SCALE;
         UDTTile.globalZoomLevel = zoomLevel;
         palettes = this.getSortedPalettes();
         for(i = 0; i < palettes.length; i++)
         {
            tileIndeces = (palettes[i] as UDTPaletteEntry).getTiles();
            for(j = 0; j < tileIndeces.length; j++)
            {
               x = tileIndeces[j] % this.m_width;
               y = (tileIndeces[j] - x) / this.m_width;
               this.m_curPoint.x = sizeX / 2;
               this.m_curPoint.x += (x - y) * tileWidth;
               this.m_curPoint.y = sizeY - (x + y) * tileHeight;
               tile = this.tileAt(x,y) as UDTTile;
               if(tile)
               {
                  layer = tile.getData(palettes[i]);
                  if(layer != null)
                  {
                     bitmapData.copyPixels(layer,layer.rect,this.m_curPoint,null,null,true);
                  }
               }
            }
         }
      }
      
      public function renderSlow(a_target:Viewport, minX:int, maxX:int, minY:int, maxY:int) : void
      {
         var tile:UDTTile = null;
         var layer:BitmapData = null;
         var tileIndeces:Array = null;
         var palettes:Array = null;
         var y:int = 0;
         var x:int = 0;
         var i:int = 0;
         var j:int = 0;
         this.m_bitmapData = null;
         var zoomLevel:Number = GlobalEngine.viewport.getZoom();
         UDTTile.globalZoomLevel = zoomLevel;
         var tileWidth:Number = Constants.TILE_WIDTH / Constants.TILE_SCALE;
         var tileHeight:Number = Constants.TILE_HEIGHT / Constants.TILE_SCALE;
         if(this.m_deltaBitmap)
         {
            this.m_deltaBitmap.dispose();
            this.m_deltaBitmap = null;
         }
         var width:int = a_target.getBitmapData().width;
         var height:int = a_target.getBitmapData().height;
         palettes = UDTConfig.getSortedPalettes();
         for(i = 0; i < palettes.length; i++)
         {
            tileIndeces = (palettes[i] as UDTPaletteEntry).getTiles();
            for(j = 0; j < tileIndeces.length; j++)
            {
               x = tileIndeces[j] % this.m_width;
               y = (tileIndeces[j] - x) / this.m_width;
               if(x >= minX && x < maxX && y >= minY && y < maxY)
               {
                  this.m_curPoint.x = this.m_originX;
                  this.m_curPoint.x += (x - y) * tileWidth;
                  this.m_curPoint.y = this.m_originY - (x + y) * tileHeight;
                  tile = this.tileAt(x,y) as UDTTile;
                  if(tile)
                  {
                     layer = tile.getData(palettes[i]);
                     if(layer != null)
                     {
                        a_target.copyPixels(layer,layer.rect,this.m_curPoint,null,null,true);
                     }
                  }
               }
            }
         }
      }
      
      public function renderChange(bottomX:int, bottomY:int) : void
      {
         var tile:UDTTile = null;
         var palettes:Array = null;
         var i:int = 0;
         var j:int = 0;
         var y:int = 0;
         var x:int = 0;
         var tileIndeces:Array = null;
         var layer:BitmapData = null;
         var zoomLevel:Number = NaN;
         var tileWidth:Number = NaN;
         var tileHeight:Number = NaN;
         var sizeX:Number = NaN;
         var sizeY:Number = NaN;
         if(this.m_bitmapData != null)
         {
            palettes = this.getSortedPalettes(true);
            zoomLevel = GlobalEngine.viewport.getZoom();
            tileWidth = Constants.TILE_WIDTH / Constants.TILE_SCALE * zoomLevel;
            tileHeight = Constants.TILE_HEIGHT / Constants.TILE_SCALE * zoomLevel;
            sizeX = (this.m_width + this.m_height) * tileWidth;
            sizeY = (this.m_width + this.m_height) * tileHeight;
            if(this.m_deltaBitmap != null && this.m_deltaBitmap.height != 8 * tileWidth && this.m_deltaBitmap.width != 8 * tileHeight)
            {
               this.m_deltaBitmap.dispose();
               this.m_deltaBitmap = null;
            }
            if(this.m_deltaBitmap == null)
            {
               this.m_deltaBitmap = new BitmapData(8 * tileWidth,8 * tileHeight,true,0);
            }
            for(i = 0; i < palettes.length; i++)
            {
               tileIndeces = (palettes[i] as UDTPaletteEntry).getTiles(true);
               for(j = 0; j < tileIndeces.length; j++)
               {
                  x = tileIndeces[j] % this.m_width;
                  y = (tileIndeces[j] - x) / this.m_width;
                  this.m_curPoint.x = (3 + x - bottomX - y + bottomY) * tileWidth;
                  this.m_curPoint.y = (4 - (x - bottomX + y - bottomY)) * tileHeight;
                  tile = this.tileAt(x,y) as UDTTile;
                  if(tile)
                  {
                     layer = tile.getData(palettes[i]);
                     if(layer != null)
                     {
                        this.m_deltaBitmap.copyPixels(layer,layer.rect,this.m_curPoint,null,null,true);
                     }
                  }
               }
            }
            this.m_curPoint.x = ((this.m_width + this.m_height) / 2 + (bottomX - bottomY - 4)) * tileWidth;
            this.m_curPoint.y = (this.m_width + this.m_height - (bottomX + bottomY + 6)) * tileHeight;
            this.m_bitmapData.copyPixels(this.m_deltaBitmap,this.m_deltaBitmap.rect,this.m_curPoint,null,null,true);
         }
      }
      
      public function setOriginPosition(origin:Vector2) : void
      {
         this.m_originX = origin.x - Constants.TILE_WIDTH / 2;
         this.m_originY = origin.y - Constants.TILE_HEIGHT;
      }
   }
}

