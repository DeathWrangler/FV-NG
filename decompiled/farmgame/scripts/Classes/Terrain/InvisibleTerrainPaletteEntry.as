package Classes.Terrain
{
   import Classes.InvisibleTerrain.InvisibleTerrainMap;
   import Engine.Constants;
   import Engine.Managers.LoadingManager;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.utils.Dictionary;
   
   public class InvisibleTerrainPaletteEntry
   {
      
      protected static const MAX_ZOOM_LEVEL:Number = 2;
      
      private static var m_codeToObjects:Dictionary = new Dictionary();
      
      private var m_terrain:Terrain = null;
      
      protected var m_swf:MovieClip = null;
      
      protected var m_zoomedBitmapData:BitmapData = null;
      
      protected var m_zoomLevel:Number;
      
      public function InvisibleTerrainPaletteEntry(a_code:int)
      {
         super();
         this.m_terrain = TerrainConfigManager.getInstance().getConfigObject(a_code);
         if(this.m_terrain.url)
         {
            LoadingManager.load(Global.getAssetURL(this.m_terrain.url),this.onTileLoaded);
         }
      }
      
      public static function getInvisiblePaletteEntry(a_code:int) : InvisibleTerrainPaletteEntry
      {
         var paletteEntry:InvisibleTerrainPaletteEntry = m_codeToObjects[a_code];
         if(paletteEntry == null)
         {
            paletteEntry = new InvisibleTerrainPaletteEntry(a_code);
            m_codeToObjects[a_code] = paletteEntry;
         }
         return paletteEntry;
      }
      
      protected function onTileLoaded(e:Event) : void
      {
         this.m_swf = e.target.content;
         GlobalEngine.viewport.setDirty();
         (Global.world.terrainMap as InvisibleTerrainMap).setDirty(true);
      }
      
      public function getBitmapData() : BitmapData
      {
         var className:String = null;
         var imgClass:Class = null;
         var tmp:BitmapData = null;
         var result:BitmapData = null;
         var zoomLevel:Number = GlobalEngine.viewport.getZoom();
         var zoomMatrix:Matrix = new Matrix();
         if(this.m_swf != null)
         {
            className = this.m_terrain.name + "_0_0";
            if(this.m_swf.loaderInfo.applicationDomain.hasDefinition(className))
            {
               imgClass = this.m_swf.loaderInfo.applicationDomain.getDefinition(className) as Class;
               tmp = new imgClass(0,0) as BitmapData;
               if(this.m_zoomedBitmapData == null || this.m_zoomLevel != zoomLevel)
               {
                  if(this.m_zoomedBitmapData == null)
                  {
                     this.m_zoomedBitmapData = new BitmapData(Constants.TILE_WIDTH * MAX_ZOOM_LEVEL * TerrainUtil.TERRAIN_SCALE_FACTOR,Constants.TILE_HEIGHT * MAX_ZOOM_LEVEL * TerrainUtil.TERRAIN_SCALE_FACTOR,true,0);
                  }
                  else if(this.m_zoomLevel != zoomLevel)
                  {
                     this.m_zoomedBitmapData.fillRect(this.m_zoomedBitmapData.rect,0);
                     this.m_zoomLevel = zoomLevel;
                  }
                  zoomMatrix.identity();
                  zoomMatrix.scale(zoomLevel / MAX_ZOOM_LEVEL * TerrainUtil.TERRAIN_SCALE_FACTOR,zoomLevel / MAX_ZOOM_LEVEL * TerrainUtil.TERRAIN_SCALE_FACTOR);
                  this.m_zoomedBitmapData.draw(tmp,zoomMatrix);
               }
               result = this.m_zoomedBitmapData;
            }
            else if(Config.DEBUG_MODE)
            {
               GlobalEngine.error("InvisibleTile","Tile class not found in file. class = " + className + " url = " + this.m_terrain.url);
            }
         }
         return result;
      }
   }
}

