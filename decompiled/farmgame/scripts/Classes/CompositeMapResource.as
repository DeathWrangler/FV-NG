package Classes
{
   import Classes.UGC.UGCItemLayer;
   import com.adobe.utils.ArrayUtil;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.PixelSnapping;
   import flash.display.Sprite;
   import flash.filters.BitmapFilter;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   
   public class CompositeMapResource extends MapResource implements IMapResourceLayerContainer
   {
      
      protected var m_layers:Array = new Array();
      
      private var m_cachedCompositeBitmap:BitmapData = null;
      
      public function CompositeMapResource(itemName:String)
      {
         super(itemName);
      }
      
      public function get layers() : Array
      {
         return ArrayUtil.copyArray(this.m_layers);
      }
      
      protected function invalidateCompositeBitmap() : void
      {
         if(this.m_cachedCompositeBitmap != null)
         {
            this.m_cachedCompositeBitmap.dispose();
            this.m_cachedCompositeBitmap = null;
         }
      }
      
      protected function get compositeBitmapCacheEnabled() : Boolean
      {
         return false;
      }
      
      override public function cleanUp() : void
      {
         super.cleanUp();
         this.invalidateCompositeBitmap();
      }
      
      protected function getBaseBitmapFilters() : Array
      {
         var result:Array = [];
         if(m_content)
         {
            result = m_content.filters;
         }
         return result;
      }
      
      override public function onUpdate(delta:Number) : void
      {
         var layer:MapResourceLayer = null;
         super.onUpdate(delta);
         for each(layer in this.m_layers)
         {
            layer.onUpdate(delta);
         }
      }
      
      override public function toggleAnimation() : void
      {
         var layer:MapResourceLayer = null;
         super.toggleAnimation();
         for each(layer in this.m_layers)
         {
            layer.synchronizeAnimation();
         }
      }
      
      private function debugLog(layer:MapResourceLayer, action:String) : void
      {
         var ugcLayer:UGCItemLayer = layer as UGCItemLayer;
         var debugInfo:String = "CompositeMapResource " + action + " [name=\'" + ugcLayer.ugcImageDef.ugcItemLayerDefinition.name + "\'";
         if(ugcLayer.ugcItemState.isCustomItem)
         {
            debugInfo += ", item=\'" + ugcLayer.ugcItemState.item.name + "\'";
         }
         debugInfo += ", image=\'" + ugcLayer.ugcImageDef.exportName + "\'";
         if(ugcLayer.ugcItemState.isCustomColor)
         {
            debugInfo += ", color=" + ugcLayer.ugcItemState.color;
         }
         GlobalEngine.info("UGC",debugInfo + "]");
      }
      
      public function addLayer(layer:MapResourceLayer) : void
      {
         var inserted:Boolean = false;
         var layerIdx:uint = 0;
         var layerCount:uint = 0;
         var container:DisplayObjectContainer = null;
         var baseLayerIdx:int = 0;
         if(layer.container != this)
         {
            layer.container = this;
            layer.skipOuterInRedraw = true;
            inserted = false;
            layerIdx = 0;
            layerCount = this.m_layers.length;
            while(layerIdx < layerCount && !inserted)
            {
               if(layer.compareTo(this.m_layers[layerIdx] as MapResourceLayer) < 0)
               {
                  this.m_layers.splice(layerIdx,0,layer);
                  inserted = true;
               }
               else
               {
                  layerIdx++;
               }
            }
            if(!inserted)
            {
               this.m_layers.push(layer);
            }
            if(layer.getDisplayObject() == null)
            {
               layer.createDisplayObject();
            }
            if(layer.isDisplayObjectDirty())
            {
               layer.drawDisplayObject();
            }
            if(m_content is MovieClip)
            {
               container = getDisplayObject() as DisplayObjectContainer;
               if(container != null)
               {
                  baseLayerIdx = container.getChildIndex(m_content);
                  if(layer.compareToBase() > 0)
                  {
                     layerIdx++;
                  }
                  if(layerIdx < container.numChildren)
                  {
                     container.addChildAt(layer.getDisplayObject(),layerIdx);
                  }
                  else
                  {
                     container.addChild(layer.getDisplayObject());
                  }
               }
            }
            else if(m_content is Bitmap && !m_usingLoadingGraphic)
            {
               this.drawDisplayObject();
            }
            this.invalidateCompositeBitmap();
         }
      }
      
      public function removeLayer(layer:MapResourceLayer, redraw:Boolean = true) : void
      {
         var idx:int = this.m_layers.indexOf(layer);
         if(idx >= 0)
         {
            this.m_layers.splice(idx,1);
            if(redraw)
            {
               this.removeLayerFromDisplay(layer);
            }
            this.cleanupLayer(layer);
            this.invalidateCompositeBitmap();
         }
      }
      
      public function removeAllLayers(redraw:Boolean = true) : void
      {
         var layer:MapResourceLayer = null;
         var layersCopy:Array = this.layers;
         for each(layer in layersCopy)
         {
            this.removeLayer(layer,redraw);
         }
         this.m_layers = [];
         this.invalidateCompositeBitmap();
      }
      
      private function cleanupLayer(layer:MapResourceLayer) : void
      {
         if(layer != null)
         {
            layer.deleteDisplayObject();
            layer.cleanUp();
         }
      }
      
      private function removeLayerFromDisplay(layer:MapResourceLayer) : void
      {
         var layerDisplayObj:DisplayObject = null;
         var displayObj:Sprite = null;
         var layerIdx:int = 0;
         if(layer != null)
         {
            layerDisplayObj = layer.getDisplayObject();
            if(layerDisplayObj != null)
            {
               displayObj = getDisplayObject() as Sprite;
               if(displayObj != null)
               {
                  layerIdx = displayObj.getChildIndex(layerDisplayObj);
                  if(layerIdx >= 0)
                  {
                     displayObj.removeChildAt(layerIdx);
                  }
               }
            }
         }
      }
      
      override public function drawDisplayObject() : void
      {
         super.drawDisplayObject();
         if(this.m_layers.length > 0)
         {
            initializeFilters();
         }
      }
      
      override public function updateDisplayObjectTransform() : void
      {
         var layer:MapResourceLayer = null;
         super.updateDisplayObjectTransform();
         for each(layer in this.m_layers)
         {
            layer.updateDisplayObjectTransform();
         }
      }
      
      override public function deleteDisplayObject() : void
      {
         this.removeAllLayers(false);
         super.deleteDisplayObject();
      }
      
      override protected function addContent(sprite:Sprite, content:DisplayObject) : void
      {
         var baseAdded:Boolean = false;
         var layer:MapResourceLayer = null;
         if(content is Bitmap)
         {
            if(this.m_layers.length > 0)
            {
               content = this.getCompositeBitmap(content as Bitmap);
            }
            sprite.addChild(content);
         }
         else
         {
            baseAdded = false;
            for each(layer in this.m_layers)
            {
               if(!baseAdded && layer.compareToBase() > 0)
               {
                  sprite.addChild(content);
                  baseAdded = true;
               }
               sprite.addChild(layer.getDisplayObject());
            }
            if(!baseAdded)
            {
               sprite.addChild(content);
            }
         }
      }
      
      private function getCompositeBitmap(baseContent:Bitmap) : Bitmap
      {
         var layersDrawn:int = 0;
         var tmp:BitmapData = null;
         var baseAdded:Boolean = false;
         var dest:Point = null;
         var layerImage:ItemImage = null;
         var layerContent:MovieClip = null;
         var baseColorMatrixFilter:ColorMatrixFilter = null;
         var layer:MapResourceLayer = null;
         var data:BitmapData = null;
         if(this.m_cachedCompositeBitmap != null && this.compositeBitmapCacheEnabled)
         {
            data = this.m_cachedCompositeBitmap;
         }
         else
         {
            layersDrawn = 0;
            data = new BitmapData(baseContent.width,baseContent.height,true,0);
            tmp = new BitmapData(data.width,data.height,true,0);
            baseAdded = false;
            dest = new Point(0,0);
            baseColorMatrixFilter = this.extractColorMatrixFilter(this.getBaseBitmapFilters());
            for each(layer in this.m_layers)
            {
               if(!baseAdded && layer.compareToBase() > 0)
               {
                  if(baseColorMatrixFilter != null)
                  {
                     tmp.fillRect(tmp.rect,0);
                     tmp.applyFilter(baseContent.bitmapData,baseContent.bitmapData.rect,dest,baseColorMatrixFilter);
                     data.copyPixels(tmp,tmp.rect,dest,null,null,true);
                  }
                  else
                  {
                     data.copyPixels(baseContent.bitmapData,baseContent.bitmapData.rect,dest,null,null,true);
                  }
                  layersDrawn++;
                  baseAdded = true;
               }
               layerImage = layer.getItemImage();
               if(layerImage != null)
               {
                  layerContent = layerImage.image as MovieClip;
                  if(layerContent != null)
                  {
                     layerContent.gotoAndStop(1);
                     tmp.fillRect(tmp.rect,0);
                     tmp.draw(layerContent,layer.getBitmapTranslationMatrix());
                     data.copyPixels(tmp,tmp.rect,dest,null,null,true);
                     layersDrawn++;
                  }
               }
            }
            tmp.dispose();
            tmp = null;
            if(layersDrawn == this.m_layers.length + 1 && this.compositeBitmapCacheEnabled)
            {
               if(this.m_cachedCompositeBitmap)
               {
                  this.m_cachedCompositeBitmap.dispose();
               }
               this.m_cachedCompositeBitmap = data;
            }
         }
         return new Bitmap(data,PixelSnapping.AUTO,true);
      }
      
      private function extractColorMatrixFilter(filters:Array) : ColorMatrixFilter
      {
         var filter:BitmapFilter = null;
         var result:ColorMatrixFilter = null;
         for each(filter in filters)
         {
            if(filter != null && filter is ColorMatrixFilter)
            {
               result = filter as ColorMatrixFilter;
               break;
            }
         }
         return result;
      }
   }
}

