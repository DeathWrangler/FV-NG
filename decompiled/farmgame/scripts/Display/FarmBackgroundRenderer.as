package Display
{
   import Classes.Yimf.Yimf;
   import Classes.Yimf.YimfManager;
   import Engine.Classes.Viewport;
   import Engine.Constants;
   import Engine.Helpers.Vector2;
   import Engine.Managers.LoadingManager;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class FarmBackgroundRenderer
   {
      
      private static const BITMAPDATA_PIXEL_DIMENSION_LIMTATION:Number = 2879;
      
      private static const HORIZON_ZOOM_FACTOR:Number = 1 / 3;
      
      private static const HORIZON_HORIZONTAL_SCROLL_FACTOR:Number = 2 / 3;
      
      private static const HORIZON_VERTICAL_SCROLL_FACTOR:Number = 1 / 4;
      
      private static const OUTSIDE_IMAGE_SIZE_FACTOR:Number = 0.5;
      
      protected var m_width:int;
      
      protected var m_height:int;
      
      protected var m_outsideOverlay:String = "";
      
      protected var m_outsideImage:DisplayObject = null;
      
      protected var m_cachedOutsideImage:BitmapData = null;
      
      protected var m_cachedOutsideImageZoomLevel:Number = 0;
      
      protected var m_cachedOutsideImageTopLeft:Point = null;
      
      protected var m_forceRecache:Boolean = false;
      
      protected var m_horizonImage:DisplayObject = null;
      
      protected var m_outsideTransform:Matrix = new Matrix();
      
      protected var m_config:Yimf = null;
      
      protected var m_freezeBackgroundImage:Boolean = false;
      
      private var m_outsideImageWidth:Number;
      
      private var m_outsideImageHeight:Number;
      
      public function FarmBackgroundRenderer(a_width:int, a_height:int)
      {
         super();
         this.m_width = a_width;
         this.m_height = a_height;
      }
      
      public function setBackgroundAndColor(themeType:String) : void
      {
         this.m_freezeBackgroundImage = false;
         this.m_config = YimfManager.getInstance().getYimfConfig(themeType);
         Config.VIEWPORT_CLEAR_COLOR = this.m_config.bgColor;
         Global.world.lotOutlineColor = this.m_config.outlineColor;
         Global.world.lotOutlineAlpha = this.m_config.outlineAlpha;
         Global.world.expansionOutlineColor = this.m_config.expansionOutlineColor;
         this.resetOutsideImage();
         this.resetHorizonImage();
      }
      
      public function setBackgroundUrl(url:String) : void
      {
         this.m_config.backgroundPath = url;
         this.m_freezeBackgroundImage = true;
         this.resetOutsideImage();
         this.resetHorizonImage();
      }
      
      public function setHorizonUrl(url:String) : void
      {
         this.m_config.horizon = url;
         this.resetOutsideImage();
         this.resetHorizonImage();
      }
      
      public function useLotOutline() : Boolean
      {
         return Boolean(this.m_config) && this.m_config.drawOutline;
      }
      
      public function canShowExpansionMarketingGrid() : Boolean
      {
         return !this.m_config || this.m_config.backgroundPath == null;
      }
      
      public function resetOutsideImage() : void
      {
         this.m_outsideImage = null;
         this.loadOutsideImage(this.onOutsideImageLoaded);
      }
      
      public function set outsideOverlay(a_outsideOverlay:String) : void
      {
         this.m_outsideOverlay = a_outsideOverlay;
      }
      
      public function loadOutsideImage(callback:Function) : void
      {
         var url:String = null;
         if(this.m_config.backgroundPath != null)
         {
            url = this.m_config.backgroundPath;
            if(!this.m_freezeBackgroundImage && !this.m_config.isToolGenerated)
            {
               url = url + ((this.m_width - 2) / 4).toString() + ".swf";
            }
            LoadingManager.load(Global.getAssetURL(url),callback);
         }
         else if(this.m_outsideOverlay != null && this.m_outsideOverlay != "")
         {
            LoadingManager.load(Global.getAssetURL(this.m_outsideOverlay),callback);
         }
         else
         {
            callback(null);
         }
      }
      
      public function resetHorizonImage() : void
      {
         this.m_horizonImage = null;
         this.loadHorizonImage(this.onHorizonImageLoaded);
      }
      
      public function loadHorizonImage(callback:Function) : void
      {
         var url:String = null;
         if(this.m_config.horizon != null)
         {
            url = this.m_config.horizon;
            LoadingManager.load(Global.getAssetURL(url),callback);
         }
      }
      
      protected function onOutsideImageLoaded(event:Event) : void
      {
         var dim:Point = null;
         if(event != null && event.target != null && event.target.content != null)
         {
            this.m_outsideImage = event.target.content;
            this.m_forceRecache = true;
            GlobalEngine.viewport.setDirty();
            dim = Global.worldSettingsManager.getWorldSpecificOutsideImageDimensions();
            if(dim.x != 0 && dim.y != 0)
            {
               this.m_outsideImageWidth = dim.x * OUTSIDE_IMAGE_SIZE_FACTOR;
               this.m_outsideImageHeight = dim.y * OUTSIDE_IMAGE_SIZE_FACTOR;
            }
            else
            {
               this.m_outsideImageWidth = this.m_outsideImage.width * OUTSIDE_IMAGE_SIZE_FACTOR;
               this.m_outsideImageHeight = this.m_outsideImage.height * OUTSIDE_IMAGE_SIZE_FACTOR;
            }
         }
         else
         {
            this.m_outsideImage = null;
         }
      }
      
      protected function onHorizonImageLoaded(event:Event) : void
      {
         if(event != null && event.target != null && event.target.content != null)
         {
            this.m_horizonImage = event.target.content;
            GlobalEngine.viewport.setDirty();
         }
         else
         {
            this.m_horizonImage = null;
         }
      }
      
      private function getSkyColor() : uint
      {
         return this.m_config.skyColor;
      }
      
      public function setSkyColor(argbColor:uint) : void
      {
         this.m_config.skyColor = argbColor;
      }
      
      public function render(targetViewport:Viewport) : void
      {
         var currentZoom:Number = NaN;
         var scrollPos:Vector2 = null;
         var stageWidth:int = 0;
         var stageHeight:int = 0;
         var translationPoint:Point = null;
         var renderingTopLeftPoint:Point = null;
         var rectangle:Rectangle = null;
         var errorMessage:String = null;
         try
         {
            if(this.m_horizonImage)
            {
               this.renderHorizon(targetViewport);
            }
            if(this.m_outsideImage)
            {
               currentZoom = targetViewport.getZoom();
               scrollPos = targetViewport.getScrollPosition();
               stageWidth = targetViewport.stage.stageWidth;
               stageHeight = targetViewport.stage.stageHeight;
               translationPoint = this.findAbsoluteTranslationForCachedOutsideImage(currentZoom,scrollPos,stageWidth,stageHeight);
               renderingTopLeftPoint = new Point(-translationPoint.x,-translationPoint.y);
               if(this.isOutsideImageVisibleOnStage(renderingTopLeftPoint,currentZoom,stageWidth,stageHeight))
               {
                  if(this.m_forceRecache || this.m_cachedOutsideImage == null || currentZoom != this.m_cachedOutsideImageZoomLevel || !this.isCachedOutsideImageSufficientToRenderGivenPoint(renderingTopLeftPoint,currentZoom,stageWidth,stageHeight))
                  {
                     if(this.m_cachedOutsideImage)
                     {
                        this.m_cachedOutsideImage.dispose();
                     }
                     this.m_forceRecache = false;
                     this.m_cachedOutsideImageZoomLevel = currentZoom;
                     rectangle = this.determineCachedOutsideImageDataFromRenderingTopLeftPoint(renderingTopLeftPoint,currentZoom,stageWidth,stageHeight);
                     this.m_outsideTransform.identity();
                     this.m_outsideTransform.scale(currentZoom * OUTSIDE_IMAGE_SIZE_FACTOR,currentZoom * OUTSIDE_IMAGE_SIZE_FACTOR);
                     this.m_outsideTransform.translate(-rectangle.x,-rectangle.y);
                     this.m_cachedOutsideImageTopLeft = new Point(rectangle.x,rectangle.y);
                     this.m_cachedOutsideImage = new BitmapData(rectangle.width,rectangle.height,true,0);
                     this.m_cachedOutsideImage.draw(this.m_outsideImage,this.m_outsideTransform);
                     rectangle = null;
                  }
                  this.m_outsideTransform.identity();
                  this.m_outsideTransform.translate(translationPoint.x + this.m_cachedOutsideImageTopLeft.x,translationPoint.y + this.m_cachedOutsideImageTopLeft.y);
                  if(this.m_cachedOutsideImage)
                  {
                     targetViewport.getBitmapData().draw(this.m_cachedOutsideImage,this.m_outsideTransform);
                  }
               }
            }
         }
         catch(e:ArgumentError)
         {
            errorMessage = e.message;
            errorMessage += ",source=FarmBackgroundRenderer.render";
            if(rectangle)
            {
               errorMessage += ",width=" + rectangle.width;
               errorMessage += ",height=" + rectangle.height;
            }
            GlobalEngine.error("FarmBackgroundRenderer",errorMessage);
         }
      }
      
      private function getOutsideImageWidth() : Number
      {
         return this.m_outsideImageWidth;
      }
      
      private function getOutsideImageHeight() : Number
      {
         return this.m_outsideImageHeight;
      }
      
      private function findAbsoluteTranslationForCachedOutsideImage(currentZoom:Number, scrollPos:Vector2, stageWidth:int, stageHeight:int) : Point
      {
         var point:Point = new Point(currentZoom * (Constants.TILE_WIDTH * this.m_width / 2 - this.getOutsideImageWidth() / 2),currentZoom * (Constants.TILE_HEIGHT * this.m_height / 2 - this.getOutsideImageHeight() / 2));
         point.offset(-stageWidth / 2 * currentZoom,-stageHeight / 2 * currentZoom);
         point.offset(stageWidth / 2,stageHeight / 2);
         point.offset(scrollPos.x * currentZoom,scrollPos.y * currentZoom);
         return new Point(int(point.x),int(point.y));
      }
      
      private function isCachedOutsideImageSufficientToRenderGivenPoint(topLeftPoint:Point, currentZoom:Number, stageWidth:int, stageHeight:int) : Boolean
      {
         var point:Point = topLeftPoint.clone();
         var outsideImageWidth:int = int(this.getOutsideImageWidth() * currentZoom);
         var outsideImageHeight:int = int(this.getOutsideImageHeight() * currentZoom);
         if(point.x < 0)
         {
            point.x = 0;
         }
         else if(point.x + stageWidth > outsideImageWidth)
         {
            point.x = outsideImageWidth - stageWidth;
         }
         if(point.y < 0)
         {
            point.y = 0;
         }
         else if(point.y + stageHeight > outsideImageHeight)
         {
            point.y = outsideImageHeight - stageHeight;
         }
         return point.x >= this.m_cachedOutsideImageTopLeft.x && point.y >= this.m_cachedOutsideImageTopLeft.y && point.x + stageWidth <= this.m_cachedOutsideImageTopLeft.x + this.m_cachedOutsideImage.width && point.y + stageHeight <= this.m_cachedOutsideImageTopLeft.y + this.m_cachedOutsideImage.height;
      }
      
      private function isOutsideImageVisibleOnStage(topLeftPoint:Point, currentZoom:Number, stageWidth:int, stageHeight:int) : Boolean
      {
         return topLeftPoint.x >= -stageWidth && topLeftPoint.y >= -stageHeight && topLeftPoint.x < int(this.getOutsideImageWidth() * currentZoom) && topLeftPoint.y < int(this.getOutsideImageHeight() * currentZoom);
      }
      
      private function determineCachedOutsideImageDataFromRenderingTopLeftPoint(renderingTopLeftPoint:Point, currentZoom:Number, stageWidth:int, stageHeight:int) : Rectangle
      {
         var imageWidth:int = int(this.getOutsideImageWidth() * currentZoom);
         var imageHeight:int = int(this.getOutsideImageHeight() * currentZoom);
         var x:int = 0;
         var y:int = 0;
         var width:int = imageWidth;
         var height:int = imageHeight;
         if(width > BITMAPDATA_PIXEL_DIMENSION_LIMTATION)
         {
            width = BITMAPDATA_PIXEL_DIMENSION_LIMTATION;
            x = this.evaluateOutsideImageCachedCoordinate(int(renderingTopLeftPoint.x + stageWidth / 2 - BITMAPDATA_PIXEL_DIMENSION_LIMTATION / 2),imageWidth,width);
         }
         if(height > BITMAPDATA_PIXEL_DIMENSION_LIMTATION)
         {
            height = BITMAPDATA_PIXEL_DIMENSION_LIMTATION;
            y = this.evaluateOutsideImageCachedCoordinate(int(renderingTopLeftPoint.y + stageHeight / 2 - BITMAPDATA_PIXEL_DIMENSION_LIMTATION / 2),imageHeight,height);
         }
         return new Rectangle(x,y,width,height);
      }
      
      private function evaluateOutsideImageCachedCoordinate(coordinate:int, zoomedFullImageSize:int, cachedImageSize:int) : int
      {
         if(coordinate < 0)
         {
            coordinate = 0;
         }
         else if(coordinate + cachedImageSize >= zoomedFullImageSize)
         {
            coordinate = zoomedFullImageSize - cachedImageSize;
         }
         return coordinate;
      }
      
      protected function renderHorizon(a_target:Viewport) : void
      {
         var rect:Rectangle = null;
         var zoom:Number = a_target.getZoom();
         var scrollPos:Vector2 = a_target.getScrollPosition();
         var zoomEffect:Number = zoom / HORIZON_ZOOM_FACTOR;
         var imageWidth:int = this.m_horizonImage.width * zoomEffect;
         var imageHeight:int = int(this.m_horizonImage.height * zoomEffect);
         var horizonHorizontalPos:Number = (scrollPos.x - a_target.stage.stageWidth / 2) * zoom + a_target.stage.stageWidth / 2;
         horizonHorizontalPos *= HORIZON_HORIZONTAL_SCROLL_FACTOR;
         var x:int = int(horizonHorizontalPos % imageWidth);
         var y:int = int((scrollPos.y - a_target.stage.stageHeight / 2) * zoom + a_target.stage.stageHeight / 2 - imageHeight);
         this.m_outsideTransform.identity();
         this.m_outsideTransform.scale(zoomEffect,zoomEffect);
         this.m_outsideTransform.translate(x > 0 ? x - imageWidth : x,y);
         for(var i:int = 0; i < int(a_target.stage.stageWidth / imageWidth) + 2; i++)
         {
            a_target.getBitmapData().draw(this.m_horizonImage,this.m_outsideTransform);
            this.m_outsideTransform.translate(imageWidth,0);
         }
         if(y >= 0)
         {
            rect = new Rectangle(0,0,a_target.stage.stageWidth,y);
            a_target.getBitmapData().fillRect(rect,this.getSkyColor());
         }
      }
      
      public function getThemeType() : String
      {
         var type:String = "";
         if(this.m_config)
         {
            type = this.m_config.type;
         }
         return type;
      }
   }
}

