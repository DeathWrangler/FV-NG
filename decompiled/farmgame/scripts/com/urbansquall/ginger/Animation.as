package com.urbansquall.ginger
{
   import com.urbansquall.ginger.tools.AnimationBuilder;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.StageQuality;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   public class Animation extends EventDispatcher
   {
      
      internal var m_degToRotBy:Number;
      
      internal var m_framesOfRotation:int;
      
      internal var m_frames:Array;
      
      internal var m_frameMap:Dictionary;
      
      internal var m_cachedFrames:Dictionary;
      
      internal var m_fps:int;
      
      internal var m_totalFrames:int;
      
      internal var m_width:int;
      
      internal var m_height:int;
      
      private var m_isLooping:Boolean;
      
      private var m_totalMemory:int;
      
      private var m_source:MovieClip;
      
      private var m_scale:Number;
      
      private var m_name:String;
      
      private var m_sourceImage:Object;
      
      private var m_frameIDLookup:Array;
      
      private var m_frameOffsets:Array;
      
      public function Animation(a_sourceImage:Object, a_fps:int, a_numRotations:int = 1, a_source:MovieClip = null, a_scale:Number = 1, a_name:String = "")
      {
         super();
         this.m_sourceImage = a_sourceImage;
         this.m_frames = [];
         this.m_frameIDLookup = [];
         this.m_frameOffsets = [];
         this.m_frameMap = new Dictionary();
         this.m_cachedFrames = new Dictionary();
         this.m_fps = a_fps;
         this.m_isLooping = false;
         this.m_source = a_source;
         this.m_scale = a_scale;
         this.m_name = a_name;
         this.m_framesOfRotation = a_numRotations;
         if(this.m_framesOfRotation < 1)
         {
            this.m_framesOfRotation = 1;
         }
         this.m_degToRotBy = 360 / this.m_framesOfRotation;
      }
      
      public function addFrame(a_numFrames:int, a_bitmapData:BitmapData, a_frameLocation:Rectangle, a_offsetX:Number = 0, a_offsetY:Number = 0, a_frameID:String = null) : BitmapData
      {
         if(a_frameID == "")
         {
            a_frameID = null;
         }
         var bmpData:BitmapData = new BitmapData(a_frameLocation.width,a_frameLocation.height,true,0);
         bmpData.copyPixels(a_bitmapData,a_frameLocation,new Point());
         this.m_frames.push(new Frame(a_numFrames,bmpData,this.m_framesOfRotation,a_frameID,a_offsetX,a_offsetY));
         if(a_frameID != null)
         {
            this.m_frameMap[a_frameID] = this.m_totalFrames;
         }
         ++this.m_totalFrames;
         this.m_totalMemory += bmpData.width * bmpData.height * 4;
         return this.m_frames[this.m_frames.length - 1].bitmapData[0];
      }
      
      public function setFrameMap(a_frameID:String, a_index:int) : void
      {
         this.m_frameMap[a_frameID] = a_index;
         this.m_frameIDLookup[a_index] = a_frameID;
      }
      
      public function setFrameOffsets(a_offsetX:Number, a_offsetY:Number, a_frameIndex:int) : void
      {
         var offsetPoint:Point = new Point(a_offsetX,a_offsetY);
         this.m_frameOffsets[a_frameIndex] = offsetPoint;
      }
      
      public function setTotalFrames(a_count:int) : void
      {
         this.m_totalFrames = a_count;
      }
      
      public function setWidthHeight(a_width:int, a_height:int) : void
      {
         this.m_width = a_width;
         this.m_height = a_height;
      }
      
      public function changeFrameID(a_frameIndex:int, a_id:String) : void
      {
         var frame:Frame = this.m_frames[a_frameIndex];
         frame.changeID(a_id);
      }
      
      public function changeFrameCount(a_frameIndex:int, a_newFrameCount:int) : void
      {
         var frame:Frame = this.m_frames[a_frameIndex];
         frame.numFrames = a_newFrameCount;
      }
      
      public function isUsingDeltaFrames() : Boolean
      {
         return Boolean(this.m_sourceImage) && this.m_sourceImage.rasterMetaData != null;
      }
      
      public function get totalMemory() : int
      {
         return this.m_totalMemory;
      }
      
      public function get isDisposed() : Boolean
      {
         return this.m_totalFrames == 0;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get isLooping() : Boolean
      {
         return this.m_isLooping;
      }
      
      public function set isLooping(a_value:Boolean) : void
      {
         this.m_isLooping = a_value;
      }
      
      public function reverseFrames() : void
      {
         this.m_frames.reverse();
      }
      
      public function releaseCachedFrame(a_frameIndex:int) : void
      {
         var frameObj:Object = this.m_cachedFrames[a_frameIndex];
         if(frameObj)
         {
            --frameObj.cnt;
            if(!frameObj.cnt)
            {
               delete this.m_cachedFrames[a_frameIndex];
            }
         }
      }
      
      public function getFrame(a_frameIndex:int, a_curBitmap:BitmapData) : Frame
      {
         var result:Frame = null;
         if(Boolean(this.m_frames) && Boolean(a_frameIndex >= 0) && a_frameIndex < this.m_totalFrames)
         {
            if(this.isUsingDeltaFrames() == false)
            {
               if(this.m_frames[a_frameIndex] is Frame)
               {
                  result = this.m_frames[a_frameIndex] as Frame;
               }
            }
            else
            {
               result = this.buildFramefromDeltas(a_frameIndex,a_curBitmap);
            }
         }
         return result;
      }
      
      public function getFrameBitmapData(a_frameIndex:int) : BitmapData
      {
         var frame:Frame = null;
         var result:BitmapData = null;
         if(Boolean(this.m_frames) && Boolean(a_frameIndex >= 0) && a_frameIndex < this.m_frames.length)
         {
            frame = this.m_frames[a_frameIndex] as Frame;
            if(frame)
            {
               result = frame.bitmapData[0] as BitmapData;
               frame.preventDispose = true;
            }
         }
         return result;
      }
      
      public function buildFramefromDeltas(a_frameIndex:int, a_curBitmap:BitmapData) : Frame
      {
         var result:Frame = null;
         var uniqueFrameIdx:int = a_frameIndex;
         var frameObj:Object = this.m_cachedFrames[a_frameIndex];
         var curFrameBitmapData:BitmapData = (this.m_frames[uniqueFrameIdx] as Frame).bitmapData[0] as BitmapData;
         var offset:Point = this.m_frameOffsets[uniqueFrameIdx] as Point;
         if(frameObj == null)
         {
            result = new Frame((this.m_frames[uniqueFrameIdx] as Frame).numFrames,a_curBitmap,this.m_framesOfRotation,this.m_frameIDLookup[a_frameIndex],-(this.m_frames[uniqueFrameIdx] as Frame).offsetX[0],-(this.m_frames[uniqueFrameIdx] as Frame).offsetY[0]);
            a_curBitmap.copyPixels(curFrameBitmapData,curFrameBitmapData.rect,offset);
            frameObj = {
               "frame":result,
               "cnt":1
            };
            this.m_cachedFrames[a_frameIndex] = frameObj;
         }
         else
         {
            ++frameObj.cnt;
            result = frameObj.frame;
            a_curBitmap.copyPixels(curFrameBitmapData,curFrameBitmapData.rect,offset);
         }
         return result;
      }
      
      public function start() : void
      {
         var currentQuality:String = null;
         var oldScaleX:Number = NaN;
         var oldScaleY:Number = NaN;
         if(this.m_totalFrames == 0 && this.m_source != null)
         {
            currentQuality = Global.stage.quality;
            Global.stage.quality = StageQuality.HIGH;
            oldScaleX = this.m_source.scaleX;
            oldScaleY = this.m_source.scaleY;
            this.m_source.scaleX = this.m_scale;
            this.m_source.scaleY = this.m_scale;
            AnimationBuilder.importMovieClip(this.m_source,this,this.m_sourceImage);
            this.m_source.scaleX = oldScaleX;
            this.m_source.scaleY = oldScaleY;
            Global.stage.quality = currentQuality;
         }
      }
      
      public function dispose() : void
      {
         var frame:Frame = null;
         var idx:int = 0;
         for each(frame in this.m_frames)
         {
            frame.dispose();
         }
         for each(idx in this.m_cachedFrames)
         {
            delete this.m_cachedFrames[idx];
         }
         this.m_frames = [];
         this.m_frameIDLookup = [];
         this.m_frameOffsets = [];
         this.m_frameMap = new Dictionary();
         this.m_totalFrames = 0;
         this.m_totalMemory = 0;
      }
   }
}

