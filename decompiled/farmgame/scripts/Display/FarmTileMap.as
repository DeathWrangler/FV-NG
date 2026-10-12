package Display
{
   import Classes.Constants.Experiments;
   import Classes.Yimf.YimfManager;
   import Engine.Classes.TileMap;
   import Engine.Classes.Viewport;
   import Engine.Constants;
   import Engine.Helpers.Vector2;
   import Engine.Interfaces.ITerrainMap;
   import Engine.IsoMath;
   import flash.display.BitmapData;
   import flash.geom.Point;
   
   public class FarmTileMap extends TileMap
   {
      
      private static const HORIZONTAL_FARM_SIZE_BOUNDARY_FACTOR:Number = 4;
      
      private static const VERTICAL_FARM_SIZE_BOUNDARY_FACTOR:Number = 5;
      
      private static const HORIZONTAL_EXTRA_BOUNDARY_PAD:Number = 600;
      
      private static const VERTICAL_LOWER_EXTRA_BOUNDARY_PAD:Number = 500;
      
      private static const VERTICAL_UPPER_EXTRA_BOUNDARY_PAD:Number = 800;
      
      protected var m_oldZoom:Number = 0;
      
      protected var m_bitmapData:BitmapData = null;
      
      protected var m_useFast:Boolean = true;
      
      protected var m_farmTerrain:FarmTerrainMap = null;
      
      private var m_farmBackgroundRenderer:FarmBackgroundRenderer = null;
      
      private var m_renderBackgroundAtBottom:Boolean = false;
      
      private var m_tileSet:String = "";
      
      public function FarmTileMap(a_width:int, a_height:int)
      {
         super(a_width,a_height);
         this.m_farmBackgroundRenderer = new FarmBackgroundRenderer(a_width,a_height);
      }
      
      public function getFarmBackgroundRenderer() : FarmBackgroundRenderer
      {
         return this.m_farmBackgroundRenderer;
      }
      
      public function setBackgroundSkyColor(argbColor:uint) : void
      {
         this.m_farmBackgroundRenderer.setSkyColor(argbColor);
      }
      
      public function setBackgroundTileAndColor(tileSet:String) : void
      {
         this.m_tileSet = tileSet;
         this.m_renderBackgroundAtBottom = YimfManager.getInstance().getYimfConfig(tileSet).renderBackgroundAtBottom;
         this.m_farmBackgroundRenderer.setBackgroundAndColor(tileSet);
         this.m_farmTerrain.setTileType(tileSet);
         this.m_farmTerrain.setDirty(true);
      }
      
      public function get tileSet() : String
      {
         return this.m_tileSet;
      }
      
      public function setBackground(url:String) : void
      {
         this.m_renderBackgroundAtBottom = true;
         this.m_farmBackgroundRenderer.setBackgroundUrl(url);
         this.m_farmTerrain.setDirty(true);
      }
      
      public function setHorizon(url:String) : void
      {
         this.m_renderBackgroundAtBottom = true;
         this.m_farmBackgroundRenderer.setHorizonUrl(url);
         this.m_farmTerrain.setDirty(true);
      }
      
      override public function setTerrain(terrain:ITerrainMap) : void
      {
         super.setTerrain(terrain);
         this.m_farmTerrain = terrain as FarmTerrainMap;
      }
      
      override public function render(a_target:Viewport) : void
      {
         if(this.m_renderBackgroundAtBottom)
         {
            this.getFarmBackgroundRenderer().render(a_target);
         }
         if(m_terrain)
         {
            if(this.chooseSystem())
            {
               this.renderFast(a_target);
               if(!this.chooseSystem())
               {
                  this.renderLowMem(a_target);
               }
            }
            else
            {
               this.renderLowMem(a_target);
            }
         }
         if(!this.m_renderBackgroundAtBottom)
         {
            this.getFarmBackgroundRenderer().render(a_target);
         }
      }
      
      protected function renderFast(a_target:Viewport) : void
      {
         var tileWidth:Number = NaN;
         var tileHeight:Number = NaN;
         var sizeX:Number = NaN;
         var sizeY:Number = NaN;
         var zoomLevel:Number = GlobalEngine.viewport.getZoom();
         if(this.m_oldZoom != zoomLevel || this.m_farmTerrain.isDirty())
         {
            if(this.m_bitmapData)
            {
               this.m_bitmapData.dispose();
            }
            tileWidth = Constants.TILE_WIDTH / Constants.TILE_SCALE * zoomLevel;
            tileHeight = Constants.TILE_HEIGHT / Constants.TILE_SCALE * zoomLevel;
            sizeX = (this.m_width + this.m_height) * tileWidth;
            sizeY = (this.m_width + this.m_height) * tileHeight;
            try
            {
               this.m_bitmapData = new BitmapData(sizeX,sizeY,true,0);
            }
            catch(err:Error)
            {
               m_useFast = false;
               m_bitmapData = null;
            }
            if(this.m_useFast)
            {
               this.m_farmTerrain.renderFast(this.m_bitmapData);
               this.m_farmTerrain.setDirty(false);
            }
         }
         if(null != this.m_bitmapData)
         {
            a_target.copyPixels(this.m_bitmapData,this.m_bitmapData.rect,new Point(0,0),null,null,true);
            this.m_oldZoom = zoomLevel;
         }
      }
      
      protected function renderLowMem(a_target:Viewport) : void
      {
         var zoomLevel:Number = GlobalEngine.viewport.getZoom();
         if(this.m_bitmapData)
         {
            this.m_bitmapData.dispose();
            this.m_bitmapData = null;
         }
         var width:int = a_target.getBitmapData().width;
         var height:int = a_target.getBitmapData().height;
         var minY:int = IsoMath.screenPosToTilePos(width,height).y;
         minY = minY < 0 ? 0 : minY;
         var minX:int = IsoMath.screenPosToTilePos(0,height).x;
         minX = minX < 0 ? 0 : minX;
         var maxY:int = IsoMath.screenPosToTilePos(0,0).y;
         maxY = maxY > m_height ? m_height : maxY;
         var maxX:int = IsoMath.screenPosToTilePos(width,0).x;
         maxX = maxX > m_width ? m_width : maxX;
         this.m_farmTerrain.renderSlow(a_target,minX,maxX,minY,maxY);
         this.m_farmTerrain.setDirty(false);
         this.m_oldZoom = zoomLevel;
      }
      
      protected function chooseSystem() : Boolean
      {
         this.m_useFast = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_DISABLE_FAST_TILE_RENDER) > 0 ? false : true;
         return this.m_useFast;
      }
      
      public function getFarmScrollBoundaries() : Array
      {
         var point1:Point = null;
         var point2:Point = null;
         var viewport:Viewport = GlobalEngine.viewport;
         var zoom:Number = GlobalEngine.viewport.getZoom();
         var bottomPoint:Vector2 = IsoMath.tilePosToPixelPos(0,0);
         var leftPoint:Vector2 = IsoMath.tilePosToPixelPos(0,getHeight());
         var rightPoint:Vector2 = IsoMath.tilePosToPixelPos(getWidth(),0);
         var topPoint:Vector2 = IsoMath.tilePosToPixelPos(getWidth(),getHeight());
         var centerScrollPosition:Point = this.getCenterScrollPosition();
         var horizontalSize:Number = rightPoint.x - leftPoint.x;
         var verticalSize:Number = bottomPoint.y - topPoint.y;
         horizontalSize = horizontalSize / 2 - viewport.stage.stageWidth / 2 / zoom;
         verticalSize = verticalSize / 2 - viewport.stage.stageHeight / 2 / zoom;
         var upperVertical:Number = Math.max(0,verticalSize + VERTICAL_UPPER_EXTRA_BOUNDARY_PAD);
         var lowerVertical:Number = Math.max(-upperVertical,verticalSize + VERTICAL_LOWER_EXTRA_BOUNDARY_PAD);
         horizontalSize = Math.max(0,horizontalSize + HORIZONTAL_EXTRA_BOUNDARY_PAD);
         point1 = new Point(centerScrollPosition.x + horizontalSize,centerScrollPosition.y - lowerVertical);
         point2 = new Point(centerScrollPosition.x - horizontalSize,centerScrollPosition.y + upperVertical);
         return new Array(point1,point2);
      }
      
      public function getCenterScrollPosition() : Point
      {
         var viewPort:Viewport = GlobalEngine.viewport;
         var centerDeltaX:Point = IsoMath.getPixelDeltaFromTileDelta(getWidth(),0);
         var centerDeltaY:Point = IsoMath.getPixelDeltaFromTileDelta(0,getHeight());
         var centerDeltaXY:Point = centerDeltaX.add(centerDeltaY);
         var centerScrollPosX:Number = (viewPort.stage.stageWidth - (centerDeltaX.x - centerDeltaY.x)) / 2;
         var centerScrollPosY:Number = (viewPort.stage.stageHeight + centerDeltaXY.y) / 2;
         return new Point(centerScrollPosX,centerScrollPosY);
      }
   }
}

