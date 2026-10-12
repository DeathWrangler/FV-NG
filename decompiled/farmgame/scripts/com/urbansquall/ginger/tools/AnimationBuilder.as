package com.urbansquall.ginger.tools
{
   import Managers.PerformanceExperimentManager;
   import com.urbansquall.ginger.Animation;
   import com.urbansquall.ginger.RasterFrameDesc;
   import com.urbansquall.ginger.RasterMetadata;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   
   public class AnimationBuilder
   {
      
      private static var m_frameJump:int;
      
      private static var m_previousChildren:Object = {};
      
      private static var m_newChildren:Object = {};
      
      public function AnimationBuilder()
      {
         super();
      }
      
      public static function importStrip(a_fps:int, a_bitmapData:BitmapData, a_tileWidth:int, a_tileHeight:int, a_tileCount:int = -1, a_startingX:int = 0, a_startingY:int = 0, a_rotations:int = 1, a_offsetX:int = 0, a_offsetY:int = 0) : Animation
      {
         var frameLocation:Rectangle = null;
         var tileX:int = 0;
         var tileY:int = 0;
         var animation:Animation = new Animation(null,a_fps,a_rotations);
         var rows:int = Math.ceil(a_bitmapData.height / a_tileHeight);
         var cols:int = Math.ceil(a_bitmapData.width / a_tileWidth);
         if(a_tileCount == -1)
         {
            a_tileCount = rows * cols;
         }
         for(var i:int = 0; i < a_tileCount; i++)
         {
            tileX = i % cols;
            tileY = Math.floor(i / cols);
            frameLocation = new Rectangle(a_startingX + tileX * a_tileWidth,a_startingY + tileY * a_tileHeight,a_tileWidth,a_tileHeight);
            animation.addFrame(1,a_bitmapData,frameLocation,a_tileWidth / 2 + a_offsetX,a_tileHeight / 2 + a_offsetY);
         }
         return animation;
      }
      
      public static function importDisplayObject(a_displayObject:DisplayObject, a_fps:int, image:Object, a_rotations:int = 1, a_offsetX:Number = 0, a_offsetY:Number = 0, a_startFrame:int = 1, a_endFrame:int = -1) : Animation
      {
         var animation:Animation = new Animation(image,a_fps,a_rotations);
         if(a_displayObject is MovieClip)
         {
            return importMovieClip(a_displayObject as MovieClip,animation,image,a_offsetX,a_offsetY,a_startFrame,a_endFrame);
         }
         if(a_displayObject is Sprite)
         {
            return importSprite(a_displayObject as Sprite,animation,a_offsetX,a_offsetY);
         }
         if(a_displayObject is Bitmap)
         {
            return importBitmap(a_displayObject as Bitmap,animation,a_offsetX,a_offsetY);
         }
         throw new Error("<AnimationBuilder> " + a_displayObject + " is an unsupported type!");
      }
      
      private static function gotoAndStopFrame(input:DisplayObjectContainer, frame:int) : void
      {
         var child:DisplayObjectContainer = null;
         if(input is MovieClip)
         {
            MovieClip(input).gotoAndStop(frame);
            m_previousChildren[input.name] = true;
            m_newChildren[input.name] = input;
         }
         for(var index:int = 0; index < input.numChildren; index++)
         {
            child = input.getChildAt(index) as DisplayObjectContainer;
            if(child)
            {
               gotoAndStopFrame(child,frame);
            }
         }
      }
      
      private static function checkForNewFrames(container:DisplayObjectContainer) : void
      {
         var child:DisplayObject = null;
         if(m_previousChildren[container.name] == null)
         {
            MovieClip(container).gotoAndStop(1);
            m_previousChildren[container.name] = true;
            m_newChildren[container.name] = container;
         }
         for(var index:int = 0; index < container.numChildren; index++)
         {
            child = container.getChildAt(index);
            if(child)
            {
               if(child is DisplayObjectContainer)
               {
                  checkForNewFrames(child as DisplayObjectContainer);
               }
            }
         }
      }
      
      private static function nextRecursiveFrame(input:DisplayObjectContainer) : void
      {
         var clip:MovieClip = null;
         var parent:MovieClip = null;
         var child:MovieClip = null;
         var FRAME_DURATION:int = 4;
         if(input is MovieClip)
         {
            clip = input as MovieClip;
            if(clip.currentFrame == clip.totalFrames && clip.totalFrames > 1)
            {
               if(clip.parent is MovieClip)
               {
                  parent = clip.parent as MovieClip;
                  if(parent.currentFrame - 1 + clip.totalFrames <= parent.totalFrames)
                  {
                     clip.gotoAndStop(1);
                  }
               }
            }
            else
            {
               clip.gotoAndStop(clip.currentFrame + FRAME_DURATION);
            }
         }
         for(var index:int = 0; index < input.numChildren; index++)
         {
            child = input.getChildAt(index) as MovieClip;
            if(child)
            {
               nextRecursiveFrame(child);
            }
         }
      }
      
      private static function roundBounds(rect:Rectangle) : Rectangle
      {
         var adjusted:Rectangle = rect.clone();
         adjusted.x = Math.ceil(Math.abs(rect.x));
         if(rect.x < 0)
         {
            adjusted.x = -adjusted.x;
         }
         adjusted.y = Math.ceil(Math.abs(rect.y));
         if(rect.y < 0)
         {
            adjusted.y = -adjusted.y;
         }
         adjusted.right = Math.ceil(Math.abs(rect.right));
         if(rect.right < 0)
         {
            adjusted.right = -adjusted.right;
         }
         adjusted.bottom = Math.ceil(Math.abs(rect.bottom));
         if(rect.bottom < 0)
         {
            adjusted.bottom = -adjusted.bottom;
         }
         return adjusted;
      }
      
      public static function importMovieClip(a_movieClip:MovieClip, a_animation:Animation, image:Object, a_offsetX:Number = 0, a_offsetY:Number = 0, a_startFrame:int = 1, a_endFrame:int = -1) : Animation
      {
         var bd:BitmapData = null;
         var bounds:Rectangle = null;
         var matrix:Matrix = null;
         var mainX:Number = NaN;
         var mainY:Number = NaN;
         var f:int = 0;
         var rasterMDBytes:ByteArray = null;
         var rasterMD:RasterMetadata = null;
         var uniqueFrameLookup:Array = null;
         var totalWidth:int = 0;
         var totalHeight:int = 0;
         var fridx:int = 0;
         var frameCount:int = 0;
         var frameDesc:RasterFrameDesc = null;
         var tmpX:Number = NaN;
         var tmpY:Number = NaN;
         var copyrect:Rectangle = null;
         var stepCount:* = 0;
         a_movieClip.gotoAndStop(a_startFrame);
         var ef:int = a_endFrame;
         if(ef == -1 || ef > a_movieClip.totalFrames)
         {
            ef = a_movieClip.totalFrames;
         }
         var i:int = a_startFrame;
         var comparisonSprite:Sprite = new Sprite();
         if(!PerformanceExperimentManager.isInRasterMetadataExperiment || image == null || image.rasterMetaData == null)
         {
            while(i <= ef)
            {
               bounds = a_movieClip.getBounds(comparisonSprite);
               mainX = Math.floor(bounds.x);
               mainY = Math.floor(bounds.y);
               bounds.width = Math.ceil(bounds.width + bounds.x) - mainX;
               bounds.height = Math.ceil(bounds.height + bounds.y) - mainY;
               bounds.x = mainX;
               bounds.y = mainY;
               bd = new BitmapData(Math.max(1,Math.min(2880,bounds.width)),Math.max(1,Math.min(2880,bounds.height)),true,0);
               matrix = new Matrix(1,0,0,1);
               matrix.scale(a_movieClip.scaleX,a_movieClip.scaleY);
               matrix.translate(-bounds.x,-bounds.y);
               bd.draw(a_movieClip,matrix,null,null,null,true);
               if(!m_frameJump)
               {
                  m_frameJump = int(GlobalEngine.getFlashVar("rasterFrameJump"));
                  if(!m_frameJump)
                  {
                     m_frameJump = 2;
                  }
               }
               a_animation.addFrame(m_frameJump,bd,bd.rect,bounds.x + a_offsetX,bounds.y + a_offsetY,a_movieClip.currentLabel);
               for(f = 0; f < m_frameJump; f++)
               {
                  if(i <= ef)
                  {
                     stepFrameOnChildren(a_movieClip);
                     a_movieClip.nextFrame();
                     i++;
                  }
               }
               if(PerformanceExperimentManager.isInAnimationMemoryExperiment)
               {
                  bd.dispose();
               }
            }
         }
         else
         {
            rasterMDBytes = image.rasterMetaData;
            rasterMD = new RasterMetadata();
            if(rasterMDBytes.position == 0)
            {
               rasterMDBytes.inflate();
            }
            rasterMDBytes.position = 0;
            rasterMD.m_totalFrames = rasterMDBytes.readUnsignedInt();
            rasterMD.m_totalUniqueFrames = rasterMDBytes.readUnsignedInt();
            rasterMD.m_x = rasterMDBytes.readInt();
            rasterMD.m_y = rasterMDBytes.readInt();
            rasterMD.m_width = rasterMDBytes.readInt();
            rasterMD.m_height = rasterMDBytes.readInt();
            uniqueFrameLookup = new Array();
            mainX = rasterMD.m_x * a_movieClip.scaleX;
            mainY = rasterMD.m_y * a_movieClip.scaleY;
            totalWidth = Math.ceil(rasterMD.m_width * a_movieClip.scaleX + mainX) - Math.floor(mainX);
            totalHeight = Math.ceil(rasterMD.m_height * a_movieClip.scaleY + mainY) - Math.floor(mainY);
            a_animation.setTotalFrames(rasterMD.m_totalUniqueFrames);
            a_animation.setWidthHeight(totalWidth,totalHeight);
            m_previousChildren = {};
            gotoAndStopFrame(a_movieClip,1);
            rasterMD.m_UniqueFrames = new Array();
            fridx = 0;
            frameCount = 0;
            for(i = 0; i < rasterMD.m_totalUniqueFrames; i++)
            {
               bd = new BitmapData(Math.max(1,Math.min(2880,totalWidth)),Math.max(1,Math.min(2880,totalHeight)),true,0);
               matrix = a_movieClip.transform.matrix.clone();
               matrix.translate(-mainX,-mainY);
               bd.draw(a_movieClip,matrix,null,null,null,true);
               rasterMD.m_UniqueFrames[i] = new RasterFrameDesc();
               frameDesc = rasterMD.m_UniqueFrames[i];
               tmpX = rasterMDBytes.readFloat() * a_movieClip.scaleX;
               tmpY = rasterMDBytes.readFloat() * a_movieClip.scaleY;
               frameDesc.m_offsetX = Math.floor(tmpX);
               frameDesc.m_offsetY = Math.floor(tmpY);
               frameDesc.m_width = Math.ceil(rasterMDBytes.readFloat() * a_movieClip.scaleX + tmpX) - frameDesc.m_offsetX;
               frameDesc.m_height = Math.ceil(rasterMDBytes.readFloat() * a_movieClip.scaleY + tmpY) - frameDesc.m_offsetY;
               if(i == rasterMD.m_totalUniqueFrames - 1)
               {
                  frameDesc.m_frameDuration = 4;
               }
               else
               {
                  frameDesc.m_frameDuration = rasterMDBytes.readUnsignedInt();
                  frameCount += frameDesc.m_frameDuration;
               }
               copyrect = new Rectangle();
               copyrect.x = frameDesc.m_offsetX;
               copyrect.y = frameDesc.m_offsetY;
               copyrect.width = frameDesc.m_width;
               copyrect.height = frameDesc.m_height;
               a_animation.addFrame(frameDesc.m_frameDuration,bd,copyrect,a_offsetX,a_offsetY,a_movieClip.currentLabel);
               bd.dispose();
               a_animation.setFrameOffsets(frameDesc.m_offsetX,frameDesc.m_offsetY,i);
               a_animation.setFrameMap(a_movieClip.currentLabel,i);
               stepCount = int(frameDesc.m_frameDuration / 4);
               while(stepCount--)
               {
                  m_newChildren = {};
                  nextRecursiveFrame(a_movieClip);
                  checkForNewFrames(a_movieClip);
               }
            }
            if(!PerformanceExperimentManager.isInAnimationMemoryExperiment)
            {
               rasterMDBytes.clear();
            }
         }
         return a_animation;
      }
      
      private static function stepFrameOnChildren(a_container:DisplayObjectContainer) : void
      {
         var childContainer:DisplayObjectContainer = null;
         for(var i:int = 0; i < a_container.numChildren; i++)
         {
            childContainer = a_container.getChildAt(i) as DisplayObjectContainer;
            if(childContainer != null)
            {
               if(childContainer is MovieClip)
               {
                  (childContainer as MovieClip).nextFrame();
               }
               stepFrameOnChildren(childContainer);
            }
         }
      }
      
      private static function importSprite(a_sprite:Sprite, a_animation:Animation, a_offsetX:Number = 0, a_offsetY:Number = 0) : Animation
      {
         var bounds:Rectangle = a_sprite.getBounds(a_sprite);
         var bd:BitmapData = new BitmapData(Math.max(1,Math.min(2880,bounds.width)),Math.max(1,Math.min(2880,bounds.height)),true,0);
         bd.draw(a_sprite,new Matrix(1,0,0,1,-bounds.x,-bounds.y),null,null,null,true);
         a_animation.addFrame(1,bd,bd.rect,bounds.x + a_offsetX,bounds.y + a_offsetY);
         return a_animation;
      }
      
      private static function importBitmap(a_bitmap:Bitmap, a_animation:Animation, a_offsetX:Number = 0, a_offsetY:Number = 0) : Animation
      {
         var bd:BitmapData = null;
         bd = new BitmapData(a_bitmap.width,a_bitmap.height,true,0);
         bd.copyPixels(a_bitmap.bitmapData,a_bitmap.bitmapData.rect,new Point());
         a_animation.addFrame(1,bd,bd.rect,a_offsetX,a_offsetY);
         return a_animation;
      }
   }
}

