package Classes.InvisibleTerrain
{
   import Classes.Terrain.Terrain;
   import Classes.Terrain.TerrainConfigManager;
   import Display.FarmTerrainMap;
   import Engine.Classes.Tile;
   import Engine.Classes.Viewport;
   import Engine.Constants;
   import Engine.Helpers.Vector2;
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class InvisibleTerrainMap implements FarmTerrainMap
   {
      
      private static var m_codeToTiles:Dictionary = new Dictionary();
      
      protected var m_width:uint = 0;
      
      protected var m_height:uint = 0;
      
      protected var m_tiles:Array;
      
      protected var m_debugVisibility:Boolean = false;
      
      protected var m_originX:int = 0;
      
      protected var m_originY:int = 0;
      
      protected var m_dirty:Boolean = false;
      
      public function InvisibleTerrainMap(points:Array, sizeX:uint, sizeY:uint)
      {
         var i:int = 0;
         var j:int = 0;
         var tmpIndex:int = 0;
         var tmpVar:int = 0;
         var terrainObject:Terrain = null;
         super();
         this.m_height = sizeY;
         this.m_width = sizeX;
         this.m_tiles = new Array(this.m_width * this.m_height);
         for(j = 0; j < this.m_height; j++)
         {
            tmpVar = j * this.m_width;
            for(i = 0; i < this.m_width; i++)
            {
               tmpIndex = tmpVar + i;
               terrainObject = TerrainConfigManager.getInstance().getConfigObject(points[tmpIndex]);
               this.m_tiles[tmpIndex] = getInvisibleTile(terrainObject);
            }
         }
      }
      
      public static function getInvisibleTile(terrainObject:Terrain) : InvisibleTile
      {
         var tile:InvisibleTile = m_codeToTiles[terrainObject.code];
         if(tile == null)
         {
            tile = new InvisibleTile(terrainObject.code,terrainObject.name,terrainObject.pathable);
            m_codeToTiles[terrainObject.code] = tile;
         }
         return tile;
      }
      
      public function setTileType(a_baseTerrainName:String, forceCreateTiles:Boolean = false) : void
      {
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
         return this.m_tiles[a_tileY * this.m_width + a_tileX];
      }
      
      public function setTile(a_tileX:uint, a_tileY:uint, tile:Tile) : void
      {
      }
      
      public function isPathable(a_tileX:uint, a_tileY:uint) : Boolean
      {
         return (this.m_tiles[a_tileY * this.m_width + a_tileX] as InvisibleTile).pathable;
      }
      
      public function isDirty() : Boolean
      {
         return this.m_dirty;
      }
      
      public function setDirty(a_dirty:Boolean) : void
      {
         this.m_dirty = a_dirty;
      }
      
      public function set debugVisibility(debugVisibility:Boolean) : void
      {
         this.m_debugVisibility = debugVisibility;
      }
      
      public function get debugVisibility() : Boolean
      {
         return this.m_debugVisibility;
      }
      
      public function renderFast(bitmapData:BitmapData) : void
      {
         var zoomLevel:Number = NaN;
         var tile:InvisibleTile = null;
         var layer:BitmapData = null;
         var curPoint:Point = null;
         var scaledTiledWidth:Number = NaN;
         var scaledTiledHeight:Number = NaN;
         var sizeX:int = 0;
         var sizeY:int = 0;
         var y:int = 0;
         var x:int = 0;
         if(this.m_debugVisibility)
         {
            zoomLevel = GlobalEngine.viewport.getZoom() * 2;
            curPoint = new Point(0,0);
            scaledTiledWidth = Constants.TILE_WIDTH * zoomLevel;
            scaledTiledHeight = Constants.TILE_HEIGHT * zoomLevel;
            sizeX = bitmapData.width - scaledTiledWidth;
            sizeY = bitmapData.height - scaledTiledHeight;
            scaledTiledWidth /= Constants.TILE_SCALE;
            scaledTiledHeight /= Constants.TILE_SCALE;
            for(y = 0; y < this.m_height; y++)
            {
               curPoint.x = sizeX / 2 - y * scaledTiledWidth;
               curPoint.y = sizeY - y * scaledTiledHeight;
               for(x = 0; x < this.m_width; x++)
               {
                  tile = this.tileAt(x,y) as InvisibleTile;
                  if(tile)
                  {
                     layer = tile.getDebugBitmapData();
                     if(layer)
                     {
                        bitmapData.copyPixels(layer,layer.rect,curPoint,null,null,true);
                     }
                  }
                  else
                  {
                     GlobalEngine.log("TileMap","InvisibleTile not found");
                  }
                  curPoint.x += scaledTiledWidth;
                  curPoint.y -= scaledTiledHeight;
               }
            }
         }
      }
      
      public function renderSlow(a_target:Viewport, minX:int, maxX:int, minY:int, maxY:int) : void
      {
         var zoomLevel:Number = NaN;
         var tile:InvisibleTile = null;
         var layer:BitmapData = null;
         var curPoint:Point = null;
         var scaledTiledWidth:Number = NaN;
         var scaledTiledHeight:Number = NaN;
         var y:int = 0;
         var x:int = 0;
         if(this.m_debugVisibility)
         {
            zoomLevel = GlobalEngine.viewport.getZoom();
            curPoint = new Point(0,0);
            scaledTiledWidth = Constants.TILE_WIDTH / Constants.TILE_SCALE;
            scaledTiledHeight = Constants.TILE_HEIGHT / Constants.TILE_SCALE;
            for(y = minY; y < maxY; y++)
            {
               curPoint.x = this.m_originX - (y - minX) * scaledTiledWidth;
               curPoint.y = this.m_originY - (y + minX) * scaledTiledHeight;
               for(x = minX; x < maxX; x++)
               {
                  tile = this.tileAt(x,y) as InvisibleTile;
                  if(tile)
                  {
                     layer = tile.getDebugBitmapData();
                     a_target.copyPixels(layer,layer.rect,curPoint,null,null,true);
                  }
                  else
                  {
                     GlobalEngine.log("TileMap","InvisibleTile not found");
                  }
                  curPoint.x += scaledTiledWidth;
                  curPoint.y -= scaledTiledHeight;
               }
            }
         }
      }
      
      public function setOriginPosition(origin:Vector2) : void
      {
         this.m_originX = origin.x - Constants.TILE_WIDTH / 2;
         this.m_originY = origin.y - Constants.TILE_HEIGHT;
      }
   }
}

