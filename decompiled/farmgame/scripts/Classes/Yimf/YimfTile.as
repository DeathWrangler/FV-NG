package Classes.Yimf
{
   import Engine.Classes.Tile;
   import flash.display.BitmapData;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   
   public class YimfTile extends Tile
   {
      
      private static var s_composedBitmaps:Dictionary;
      
      private static var s_scaledCacheZoomLevel:Number;
      
      private static var s_scaledBitmaps:Dictionary;
      
      protected static var m_globalZoomLevel:Number;
      
      private var m_type:String;
      
      private var m_baseKey:String;
      
      private var m_zoomLevel:Number;
      
      private var m_composedTile:BitmapData;
      
      private var m_scaledTile:BitmapData;
      
      private var m_terrainMap:YimfMap;
      
      public function YimfTile(a_terrainMap:YimfMap, a_entries:Array, a_generateBitmap:Boolean)
      {
         var cachedData:BitmapData = null;
         var entry:YimfPaletteEntry = null;
         var layerData:BitmapData = null;
         super();
         this.m_terrainMap = a_terrainMap;
         this.m_type = (a_entries[a_entries.length - 1] as YimfPaletteEntry).name;
         if(s_composedBitmaps == null)
         {
            s_composedBitmaps = new Dictionary();
         }
         this.m_baseKey = this.getBaseKey(a_entries);
         if(a_generateBitmap)
         {
            cachedData = s_composedBitmaps[this.m_baseKey];
            if(cachedData == null)
            {
               for each(entry in a_entries)
               {
                  layerData = this.parseEntry(entry);
                  if(this.m_composedTile == null)
                  {
                     this.m_composedTile = new BitmapData(layerData.width,layerData.height,true,0);
                  }
                  this.m_composedTile.copyPixels(layerData,layerData.rect,new Point(0,0),null,null,true);
               }
               s_composedBitmaps[this.m_baseKey] = this.m_composedTile;
            }
            else
            {
               this.m_composedTile = cachedData;
            }
         }
         else
         {
            this.m_composedTile = null;
         }
         this.m_zoomLevel = -1;
      }
      
      private static function stripExtension(a_url:String) : String
      {
         var dotSpot:int = a_url.lastIndexOf(".");
         if(dotSpot >= 0)
         {
            return a_url.substring(0,dotSpot);
         }
         return a_url;
      }
      
      public static function set globalZoomLevel(level:Number) : void
      {
         m_globalZoomLevel = level;
      }
      
      private function getBaseKey(a_entries:Array) : String
      {
         var entry:YimfPaletteEntry = null;
         var key:String = null;
         for each(entry in a_entries)
         {
            key += entry.imageCode;
         }
         return key;
      }
      
      private function parseEntry(a_entry:YimfPaletteEntry) : BitmapData
      {
         var data:BitmapData = null;
         var miniTileNames:Array = null;
         var miniTileBitmaps:Array = null;
         var name:String = null;
         var mt0:BitmapData = null;
         var mt1:BitmapData = null;
         var mt2:BitmapData = null;
         var mt3:BitmapData = null;
         var imageCode:String = a_entry.imageCode;
         if(imageCode.charAt(0) == "+")
         {
            imageCode = imageCode.substring(imageCode.indexOf("(") + 1,imageCode.indexOf(")"));
            miniTileNames = imageCode.split(";");
            miniTileBitmaps = [];
            for each(name in miniTileNames)
            {
               miniTileBitmaps.push(this.createBitmapData(name));
            }
            mt0 = miniTileBitmaps[0] as BitmapData;
            data = new BitmapData(mt0.width * 2,mt0.height * 2,true,0);
            data.copyPixels(mt0,mt0.rect,new Point(0,mt0.height / 2),null,null,true);
            mt1 = miniTileBitmaps[1] as BitmapData;
            data.copyPixels(mt1,mt1.rect,new Point(mt0.width / 2,0),null,null,true);
            mt2 = miniTileBitmaps[2] as BitmapData;
            data.copyPixels(mt2,mt2.rect,new Point(mt2.width / 2,mt2.height - 1),null,null,true);
            mt3 = miniTileBitmaps[3] as BitmapData;
            data.copyPixels(mt3,mt3.rect,new Point(mt3.width,mt3.height / 2),null,null,true);
         }
         else
         {
            data = this.createBitmapData(imageCode);
         }
         return data;
      }
      
      private function createBitmapData(a_name:String) : BitmapData
      {
         a_name = stripExtension(a_name);
         var imgClass:Class = getDefinitionByName(a_name) as Class;
         var data:BitmapData = new imgClass(0,0) as BitmapData;
         var retVal:BitmapData = new BitmapData(data.width,data.height,true,0);
         retVal.copyPixels(data,data.rect,new Point(0,0));
         data.dispose();
         return retVal;
      }
      
      public function get type() : String
      {
         return this.m_type;
      }
      
      override public function getBitmapData() : BitmapData
      {
         if(-1 == m_globalZoomLevel)
         {
            m_globalZoomLevel = GlobalEngine.viewport.getZoom();
         }
         if(m_globalZoomLevel != this.m_zoomLevel)
         {
            this.m_zoomLevel = m_globalZoomLevel;
            this.generateScaledLayers();
         }
         return this.m_scaledTile;
      }
      
      public function getNormalBitmapData() : BitmapData
      {
         return this.m_composedTile;
      }
      
      public function get zoomLevel() : Number
      {
         return this.m_zoomLevel;
      }
      
      private function generateScaledLayers() : void
      {
         var correctedZoom:Number = NaN;
         var zoomMatrix:Matrix = null;
         if(GlobalEngine.viewport.getZoom() != this.m_zoomLevel)
         {
            this.m_zoomLevel = GlobalEngine.viewport.getZoom();
         }
         if(s_scaledCacheZoomLevel != this.m_zoomLevel)
         {
            GlobalEngine.log("TileMap","regenerating cache of scaled bitmaps");
            s_scaledBitmaps = new Dictionary();
            s_scaledCacheZoomLevel = this.m_zoomLevel;
         }
         var scaled:BitmapData = s_scaledBitmaps[this.m_baseKey];
         if(scaled != null)
         {
            this.m_scaledTile = scaled;
         }
         else
         {
            correctedZoom = this.m_zoomLevel / 2;
            zoomMatrix = new Matrix();
            zoomMatrix.scale(correctedZoom,correctedZoom);
            this.m_scaledTile = new BitmapData(this.m_composedTile.width * correctedZoom,this.m_composedTile.height * correctedZoom,true,0);
            this.m_scaledTile.draw(this.m_composedTile,zoomMatrix);
            s_scaledBitmaps[this.m_baseKey] = this.m_scaledTile;
         }
      }
   }
}

