package Classes.Yimf
{
   import Display.FarmTerrainMap;
   import Engine.Classes.Tile;
   import Engine.Classes.Viewport;
   import Engine.Constants;
   import Engine.Helpers.Vector2;
   import flash.display.BitmapData;
   import flash.geom.Point;
   
   public class YimfMap implements FarmTerrainMap
   {
      
      protected var m_width:uint;
      
      protected var m_height:uint;
      
      protected var m_tiles:Array;
      
      protected var m_generateBitmaps:Boolean;
      
      protected var m_dirty:Boolean = false;
      
      protected var m_config:Yimf = null;
      
      protected var m_originX:int = 0;
      
      protected var m_originY:int = 0;
      
      public function YimfMap(a_width:int, a_height:int, a_baseTerrain:String, a_generateBitmaps:Boolean = true)
      {
         super();
         this.m_generateBitmaps = a_generateBitmaps;
         this.m_width = a_width;
         this.m_height = a_height;
         this.setTileType(a_baseTerrain,true);
      }
      
      public function setTileType(a_baseTerrain:String, forceCreateTiles:Boolean = false) : void
      {
         var remakeTiles:Boolean = true;
         if(this.m_config != null && this.m_config.type == a_baseTerrain)
         {
            remakeTiles = false;
         }
         else
         {
            this.m_config = YimfManager.getInstance().getYimfConfig(a_baseTerrain);
         }
         if(remakeTiles || forceCreateTiles)
         {
            this.createTiles();
         }
      }
      
      private function createTiles() : void
      {
         var totalWeight:uint = uint(this.m_config.weights[this.m_config.weights.length - 1]);
         this.m_tiles = new Array(totalWeight);
         var index:int = 0;
         var type:int = 0;
         var palette:Array = new Array(new YimfPaletteEntry(this.m_config.type,this.m_config.tileClass + "_base"));
         var tile:YimfTile = new YimfTile(this,palette,this.m_generateBitmaps);
         while(index < totalWeight)
         {
            if(this.m_config.weights[type] <= index)
            {
               type++;
               palette = new Array(new YimfPaletteEntry(this.m_config.type,this.m_config.tileClass + "_base_" + type.toString()));
               tile = new YimfTile(this,palette,this.m_generateBitmaps);
            }
            this.m_tiles[index] = tile;
            index++;
         }
         this.m_dirty = true;
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
         return this.m_tiles[this.hash(a_tileX,a_tileY)];
      }
      
      private function hash(x:uint, y:uint) : uint
      {
         var result:uint = x * 97 + y;
         result = Math.sin(result) * 214013;
         return result % this.m_tiles.length;
      }
      
      public function setTile(a_tileX:uint, a_tileY:uint, tile:Tile) : void
      {
      }
      
      public function isPathable(a_tileX:uint, a_tileY:uint) : Boolean
      {
         return true;
      }
      
      public function isDirty() : Boolean
      {
         return this.m_dirty;
      }
      
      public function setDirty(a_dirty:Boolean) : void
      {
         this.m_dirty = a_dirty;
      }
      
      public function renderFast(bitmapData:BitmapData) : void
      {
         var tile:YimfTile = null;
         var layer:BitmapData = null;
         var x:int = 0;
         var zoomLevel:Number = GlobalEngine.viewport.getZoom();
         var curPoint:Point = new Point(0,0);
         var scaledTiledWidth:Number = Constants.TILE_WIDTH * zoomLevel;
         var scaledTiledHeight:Number = Constants.TILE_HEIGHT * zoomLevel;
         var sizeX:int = bitmapData.width - scaledTiledWidth;
         var sizeY:int = bitmapData.height - scaledTiledHeight;
         scaledTiledWidth /= Constants.TILE_SCALE;
         scaledTiledHeight /= Constants.TILE_SCALE;
         YimfTile.globalZoomLevel = zoomLevel;
         for(var y:int = 0; y < this.m_height; y++)
         {
            curPoint.x = sizeX / 2 - y * scaledTiledWidth;
            curPoint.y = sizeY - y * scaledTiledHeight;
            for(x = 0; x < this.m_width; x++)
            {
               tile = this.tileAt(x,y) as YimfTile;
               if(tile)
               {
                  layer = tile.getBitmapData();
                  bitmapData.copyPixels(layer,layer.rect,curPoint,null,null,true);
               }
               else
               {
                  GlobalEngine.log("TileMap","YimfMap tile not found");
               }
               curPoint.x += scaledTiledWidth;
               curPoint.y -= scaledTiledHeight;
            }
         }
      }
      
      public function renderSlow(a_target:Viewport, minX:int, maxX:int, minY:int, maxY:int) : void
      {
         var tile:YimfTile = null;
         var layer:BitmapData = null;
         var x:int = 0;
         var zoomLevel:Number = GlobalEngine.viewport.getZoom();
         var curPoint:Point = new Point(0,0);
         YimfTile.globalZoomLevel = zoomLevel;
         var scaledTiledWidth:Number = Constants.TILE_WIDTH / Constants.TILE_SCALE;
         var scaledTiledHeight:Number = Constants.TILE_HEIGHT / Constants.TILE_SCALE;
         for(var y:int = minY; y < maxY; y++)
         {
            curPoint.x = this.m_originX - (y - minX) * scaledTiledWidth;
            curPoint.y = this.m_originY - (y + minX) * scaledTiledHeight;
            for(x = minX; x < maxX; x++)
            {
               tile = this.tileAt(x,y) as YimfTile;
               if(tile)
               {
                  layer = tile.getBitmapData();
                  a_target.copyPixels(layer,layer.rect,curPoint,null,null,true);
               }
               else
               {
                  GlobalEngine.log("TileMap","YimfMap tile not found");
               }
               curPoint.x += scaledTiledWidth;
               curPoint.y -= scaledTiledHeight;
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

