package Classes
{
   import Engine.Classes.PositionedObjectContainer;
   import Engine.Events.LoaderEvent;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Matrix;
   
   public class MapResourceLayer extends MapResource
   {
      
      protected var m_container:IMapResourceLayerContainer;
      
      public function MapResourceLayer(itemName:String)
      {
         super(itemName);
      }
      
      override public function cleanUp() : void
      {
         super.cleanUp();
         this.m_container = null;
      }
      
      public function get container() : IMapResourceLayerContainer
      {
         return this.m_container;
      }
      
      public function set container(value:IMapResourceLayerContainer) : void
      {
         if(this.m_container != value)
         {
            this.m_container = value;
         }
      }
      
      override protected function onImageLoaded(event:Event) : void
      {
         event.target.removeEventListener(LoaderEvent.LOADED,this.onImageLoaded);
         this.conditionallyRedraw(true);
         if(m_imageLoadedCallback != null)
         {
            m_imageLoadedCallback(this.getResourceItemCode());
            m_imageLoadedCallback = null;
         }
      }
      
      override public function conditionallyRedraw(forceRedraw:Boolean = false) : void
      {
         var outer:PositionedObjectContainer = null;
         if(this.m_container != null)
         {
            outer = (this.m_container as MapResource).getOuter();
            if((m_skipOuterInRedraw || outer != null && !outer.isRedrawLocked()) && (m_displayObjectDirty || forceRedraw))
            {
               drawDisplayObject();
               m_displayObjectDirty = false;
            }
         }
      }
      
      override public function updateDisplayObjectTransform() : void
      {
         var containerContent:DisplayObject = null;
         var scale:Number = NaN;
         if(this.m_container != null && m_content != null)
         {
            containerContent = this.m_container.getContent();
            if(containerContent != null)
            {
               scale = containerContent.width / m_content.width;
               m_displayObject.scaleX = scale;
               m_displayObject.scaleY = scale;
            }
            m_displayObject.visible = true;
         }
      }
      
      internal function getBitmapTranslationMatrix() : Matrix
      {
         var mc:MovieClip = null;
         var containerContent:DisplayObject = null;
         var scale:Number = NaN;
         var matrix:Matrix = new Matrix();
         if(m_itemImage != null)
         {
            mc = m_itemImage.image as MovieClip;
            if(mc != null)
            {
               matrix = mc.transform.matrix.clone();
               containerContent = this.m_container.getContent();
               if(containerContent != null)
               {
                  scale = containerContent.width / mc.width;
                  matrix.scale(scale,scale);
               }
            }
         }
         return matrix;
      }
      
      internal function synchronizeAnimation() : void
      {
         var containerMC:MovieClip = null;
         var thisMC:MovieClip = null;
         if(m_content != null && this.m_container != null)
         {
            containerMC = this.m_container.getContent() as MovieClip;
            thisMC = m_content as MovieClip;
            if(thisMC != null && containerMC != null)
            {
               if(this.m_container.isAnimating)
               {
                  thisMC.gotoAndPlay(containerMC.currentFrame);
               }
               else
               {
                  thisMC.gotoAndStop(containerMC.currentFrame);
               }
            }
         }
      }
      
      public function compareTo(otherLayer:MapResourceLayer) : int
      {
         return 0;
      }
      
      public function compareToBase() : int
      {
         return 0;
      }
      
      override protected function drawActionBar() : void
      {
      }
      
      override protected function replaceContentWithPlaceholder() : void
      {
      }
      
      override protected function addContent(sprite:Sprite, content:DisplayObject) : void
      {
         super.addContent(sprite,content);
         this.synchronizeAnimation();
      }
      
      override public function play(ignoreCanPlay:Boolean = false) : Boolean
      {
         return false;
      }
      
      override public function pause() : void
      {
      }
      
      override public function stop() : void
      {
      }
      
      override public function toggleAnimation() : void
      {
      }
      
      override protected function restartAnimation() : void
      {
      }
   }
}

