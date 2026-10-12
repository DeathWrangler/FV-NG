package Engine.Classes
{
   import Engine.Helpers.Vector2;
   import Engine.Managers.InputManager;
   import cipro.Profiler.RuntimeProfiler;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   import flash.utils.*;
   
   public class Viewport extends Sprite
   {
      
      protected var m_position:Vector2 = new Vector2();
      
      private var m_zoom:Number = 1;
      
      protected var m_bitmap:Bitmap = new Bitmap();
      
      protected var m_bitmapData:BitmapData;
      
      protected var m_transformStack:Array = [];
      
      protected var m_absoluteTransformMatrix:Matrix = new Matrix();
      
      public var uiBase:Sprite = new Sprite();
      
      public var overlayBase:Sprite = new Sprite();
      
      public var objectBase:Sprite = new Sprite();
      
      public var hudBase:Sprite = new Sprite();
      
      protected var m_bitmapDirty:Boolean = true;
      
      private var m_onRefreshCallbacks:Vector.<Function> = new Vector.<Function>();
      
      private var m_refreshCallbackVectorLength:uint = 0;
      
      public function Viewport()
      {
         super();
         addEventListener(Event.RESIZE,this.onResize);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         InputManager.initializeHandlers(this);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.stage.addEventListener(Event.RESIZE,this.onResize);
         this.onResize(null);
      }
      
      public function getTransformMatrix() : Matrix
      {
         return this.m_absoluteTransformMatrix;
      }
      
      public function getScrollPosition() : Vector2
      {
         return this.m_position.cloneVec2();
      }
      
      public function setScrollPosition(param1:Vector2) : void
      {
         this.m_position = param1.cloneVec2();
         this.m_bitmapDirty = true;
      }
      
      public function getZoom() : Number
      {
         return this.m_zoom;
      }
      
      public function setZoom(param1:Number) : Boolean
      {
         var _loc2_:Boolean = false;
         if(this.m_zoom != param1)
         {
            this.m_zoom = param1;
            this.m_bitmapDirty = true;
            _loc2_ = true;
         }
         return _loc2_;
      }
      
      public function setDirty() : void
      {
         this.m_bitmapDirty = true;
      }
      
      public function clearRefreshCallbacks() : void
      {
         this.m_onRefreshCallbacks = new Vector.<Function>();
         this.m_refreshCallbackVectorLength = 0;
      }
      
      public function removeRefreshCallback(param1:uint) : void
      {
         if(this.m_refreshCallbackVectorLength > 0 && param1 < this.m_refreshCallbackVectorLength)
         {
            this.m_onRefreshCallbacks.splice(param1,1);
            --this.m_refreshCallbackVectorLength;
         }
      }
      
      public function addRefreshCallback(param1:Function) : uint
      {
         this.m_onRefreshCallbacks.push(param1);
         ++this.m_refreshCallbackVectorLength;
         return this.m_refreshCallbackVectorLength - 1;
      }
      
      public function regenerateBitmapData() : Boolean
      {
         var _loc2_:int = 0;
         var _loc1_:Boolean = false;
         if(this.stage != null && this.stage.stageWidth > 0 && this.stage.stageHeight > 0)
         {
            if(this.m_bitmapData == null || this.m_bitmapData.width != this.stage.stageWidth || this.m_bitmapData.height != this.stage.stageHeight)
            {
               if(this.m_bitmap.parent)
               {
                  this.m_bitmap.parent.removeChild(this.m_bitmap);
               }
               if(this.m_bitmapData)
               {
                  this.m_bitmapData.dispose();
                  this.m_bitmapData = null;
               }
               _loc2_ = 0;
               this.m_bitmapData = new BitmapData(this.stage.stageWidth,this.stage.stageHeight);
               this.m_bitmap.bitmapData = this.m_bitmapData;
               addChildAt(this.m_bitmap,_loc2_);
               _loc2_++;
               if(this.overlayBase.parent)
               {
                  this.overlayBase.parent.removeChild(this.overlayBase);
               }
               addChildAt(this.overlayBase,_loc2_);
               _loc2_++;
               if(this.objectBase.parent)
               {
                  this.objectBase.parent.removeChild(this.objectBase);
               }
               addChildAt(this.objectBase,_loc2_);
               _loc2_++;
               if(this.uiBase.parent)
               {
                  this.uiBase.parent.removeChild(this.uiBase);
               }
               addChildAt(this.uiBase,_loc2_);
               _loc2_++;
               if(this.hudBase.parent)
               {
                  this.hudBase.parent.removeChild(this.hudBase);
               }
               addChildAt(this.hudBase,_loc2_);
               _loc2_++;
            }
         }
         return _loc1_;
      }
      
      protected function render(param1:Boolean = false, param2:Boolean = true) : Boolean
      {
         var _loc5_:uint = 0;
         var _loc3_:int = RuntimeProfiler.enter(ZEngineCoreModules.ViewportOnEnterFrame);
         var _loc4_:Boolean = false;
         if(Boolean(this.m_bitmapData) && (this.m_bitmapDirty || param1))
         {
            this.regenerateBitmapData();
            this.m_absoluteTransformMatrix.identity();
            this.m_absoluteTransformMatrix.translate(this.m_position.x,this.m_position.y);
            this.m_absoluteTransformMatrix.translate(-this.stage.stageWidth / 2,-this.stage.stageHeight / 2);
            this.m_absoluteTransformMatrix.scale(this.m_zoom,this.m_zoom);
            this.m_absoluteTransformMatrix.translate(this.stage.stageWidth / 2,this.stage.stageHeight / 2);
            this.m_bitmapData.lock();
            this.drawBackground(this.m_bitmapData,param2);
            this.m_bitmapData.unlock();
            this.objectBase.transform.matrix = this.uiBase.transform.matrix = this.overlayBase.transform.matrix = this.m_absoluteTransformMatrix.clone();
            this.m_bitmapDirty = false;
            _loc4_ = true;
            if(this.m_refreshCallbackVectorLength > 0)
            {
               _loc5_ = 0;
               while(_loc5_ < this.m_refreshCallbackVectorLength)
               {
                  this.m_onRefreshCallbacks[_loc5_]();
                  _loc5_++;
               }
            }
         }
         RuntimeProfiler.leave(_loc3_);
         return _loc4_;
      }
      
      protected function drawBackground(param1:BitmapData, param2:Boolean = true) : void
      {
         param1.fillRect(param1.rect,Config.VIEWPORT_CLEAR_COLOR);
      }
      
      public function centerViewport() : void
      {
      }
      
      public function getBitmapData() : BitmapData
      {
         return this.m_bitmapData;
      }
      
      public function clearBitmapData() : void
      {
         if(this.m_bitmapData != null)
         {
            this.m_bitmapData.dispose();
            this.m_bitmapData = null;
            this.m_bitmapDirty = true;
         }
      }
      
      protected function onResize(param1:Event) : void
      {
         this.regenerateBitmapData();
         this.m_bitmapDirty = true;
      }
      
      protected function onEnterFrame(param1:Event) : void
      {
         if(this.stage != null)
         {
            this.render();
         }
      }
      
      public function copyPixels(param1:BitmapData, param2:Rectangle, param3:Point, param4:BitmapData, param5:Point, param6:Boolean) : void
      {
         var _loc7_:Point = this.m_absoluteTransformMatrix.transformPoint(param3);
         this.m_bitmapData.copyPixels(param1,param2,_loc7_,param4,param5,param6);
      }
   }
}

