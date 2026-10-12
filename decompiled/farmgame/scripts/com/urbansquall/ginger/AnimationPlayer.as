package com.urbansquall.ginger
{
   import Managers.PerformanceExperimentManager;
   import com.urbansquall.ginger.events.AnimationEvent;
   import com.urbansquall.ginger.events.FrameEvent;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class AnimationPlayer extends Sprite
   {
      
      private var m_framesPassed:int;
      
      private var m_totalFrames:int;
      
      private var m_currentFrame:Frame;
      
      private var m_frameIndex:int;
      
      private var m_frames:Array;
      
      private var m_framesMap:Dictionary;
      
      private var m_isLooping:Boolean;
      
      private var m_rotationFrame:int;
      
      private var m_hasRotationChanged:Boolean;
      
      private var m_rotation:Number = 0;
      
      private var m_IDArray:Array;
      
      private var m_hasAnimationEnded:Boolean;
      
      private var m_animationDelay:int;
      
      private var m_timeSinceLastUpdate:int;
      
      private var m_currentAnimation:Animation;
      
      private var m_isPlaying:Boolean;
      
      private var m_animationMap:Dictionary;
      
      private var m_animationQueue:Array;
      
      private var m_currentAnimationID:String;
      
      private var m_defaultAnimationID:String;
      
      private var m_fps:int;
      
      private var m_desiredX:Number = 0;
      
      private var m_desiredY:Number = 0;
      
      private var m_bitmap:Bitmap;
      
      private var m_timer:Timer;
      
      private var m_timerInterval:int = 0;
      
      public function AnimationPlayer()
      {
         super();
         this.m_IDArray = [];
         this.m_animationQueue = [];
         this.m_frames = [];
         this.m_animationMap = new Dictionary();
         this.m_framesMap = new Dictionary();
         var pixelSnap:String = PerformanceExperimentManager.isInAnimationMemoryExperiment ? "auto" : "never";
         this.m_bitmap = new Bitmap(null,pixelSnap,false);
         addChild(this.m_bitmap);
      }
      
      override public function set rotation(value:Number) : void
      {
         this.m_rotation = int(value);
         this.m_rotation %= 360;
         if(this.m_rotation < 0)
         {
            this.m_rotation += 360;
         }
         this.m_rotationFrame = Math.round(this.m_rotation / this.m_currentAnimation.m_degToRotBy);
         if(this.m_rotationFrame >= this.m_currentAnimation.m_framesOfRotation)
         {
            this.m_rotationFrame = 0;
         }
         this.performOffset();
         this.m_hasRotationChanged = true;
      }
      
      override public function get rotation() : Number
      {
         return this.m_rotation;
      }
      
      override public function set x(value:Number) : void
      {
         this.m_desiredX = value;
         this.performOffset();
      }
      
      override public function get x() : Number
      {
         return this.m_desiredX;
      }
      
      override public function set y(value:Number) : void
      {
         this.m_desiredY = value;
         this.performOffset();
      }
      
      override public function get y() : Number
      {
         return this.m_desiredY;
      }
      
      override public function set scaleX(a_value:Number) : void
      {
         super.scaleX = a_value;
         this.performOffset();
      }
      
      override public function set scaleY(a_value:Number) : void
      {
         super.scaleY = a_value;
         this.performOffset();
      }
      
      public function set fps(value:int) : void
      {
         this.m_fps = value;
         if(value <= 0)
         {
            this.m_fps = 0;
            this.m_animationDelay = 0;
         }
         else
         {
            this.m_fps = value;
            this.m_animationDelay = 1000 / value;
         }
      }
      
      public function get fps() : int
      {
         return this.m_fps;
      }
      
      public function get defaultAnimationID() : String
      {
         return this.m_defaultAnimationID;
      }
      
      public function set defaultAnimationID(value:String) : void
      {
         this.m_defaultAnimationID = value;
      }
      
      public function get currentAnimationID() : String
      {
         return this.m_currentAnimationID;
      }
      
      public function get currentFrameID() : String
      {
         return this.m_currentFrame.frameID;
      }
      
      public function get animationIDs() : Array
      {
         return this.m_IDArray.slice();
      }
      
      public function get offsetX() : Number
      {
         return this.m_currentFrame.offsetX[this.m_rotationFrame];
      }
      
      public function get offsetY() : Number
      {
         return this.m_currentFrame.offsetY[this.m_rotationFrame];
      }
      
      public function get totalFrames() : int
      {
         return this.m_totalFrames;
      }
      
      public function get frameIndex() : int
      {
         return this.m_frameIndex;
      }
      
      public function get isUsingRasterMetadata() : Boolean
      {
         return Boolean(this.m_currentAnimation) && this.m_currentAnimation.isUsingDeltaFrames();
      }
      
      override public function get width() : Number
      {
         return this.m_currentFrame.width[this.m_rotationFrame];
      }
      
      override public function set width(value:Number) : void
      {
         throw new Error("<AnimationPlayer> Width / Height cannot be changed!");
      }
      
      override public function get height() : Number
      {
         return this.m_currentFrame.height[this.m_rotationFrame];
      }
      
      override public function set height(value:Number) : void
      {
         throw new Error("<AnimationPlayer> Width / Height cannot be changed!");
      }
      
      public function addAnimation(a_animationID:String, a_animation:Animation) : void
      {
         this.m_IDArray.push(a_animationID);
         this.m_animationMap[a_animationID] = a_animation;
         if(this.m_defaultAnimationID == null)
         {
            this.m_defaultAnimationID = a_animationID;
            this.play(a_animationID);
            this.performOffset();
         }
      }
      
      public function play(a_animationID:String, a_startFrame:int = 0) : void
      {
         if(this.m_animationMap[a_animationID] == null)
         {
            throw new Error("<AnimationPlayer> Invalid Animation ID [" + a_animationID + "]");
         }
         this.m_isPlaying = true;
         this.m_hasAnimationEnded = false;
         this.m_animationQueue = [this.m_currentAnimation];
         this.startNewAnimation(a_animationID);
         this.m_frameIndex = a_startFrame;
      }
      
      public function gotoFrame(a_frameID:String, a_animationID:String = null) : void
      {
         if(a_animationID != null)
         {
            this.startNewAnimation(a_animationID);
         }
         var index:int = int(this.m_framesMap[a_frameID]);
         this.m_currentFrame = this.m_currentAnimation.getFrame(index,this.m_bitmap.bitmapData);
         this.performOffset();
         if(this.m_currentAnimation.isUsingDeltaFrames() == false)
         {
            this.m_bitmap.bitmapData = this.m_currentFrame.bitmapData[this.m_rotationFrame] as BitmapData;
         }
         this.m_frameIndex = index;
         this.m_framesPassed = 0;
         this.m_isPlaying = false;
         if(this.m_currentFrame.frameID != null)
         {
            if(hasEventListener(FrameEvent.CHANGE))
            {
               dispatchEvent(new FrameEvent(FrameEvent.CHANGE,true,this.m_currentFrame.frameID,this.m_currentAnimationID));
            }
         }
      }
      
      public function restartAnimation() : void
      {
         if(this.m_currentAnimationID != null)
         {
            this.startNewAnimation(this.m_currentAnimationID);
         }
      }
      
      public function isPaused() : Boolean
      {
         return this.m_isPlaying;
      }
      
      public function unpause() : void
      {
         if(this.m_currentAnimation != null)
         {
            this.m_isPlaying = true;
         }
      }
      
      public function pause() : void
      {
         this.m_isPlaying = false;
      }
      
      public function togglePause() : void
      {
         if(this.m_currentAnimation != null)
         {
            this.m_isPlaying = !this.m_isPlaying;
         }
      }
      
      public function startSelfTick(a_interval:int) : void
      {
         if(a_interval <= 0)
         {
            return;
         }
         this.stopSelfTick();
         this.m_timerInterval = a_interval;
         this.m_timer = new Timer(this.m_timerInterval);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.tickTimer,false,0,true);
         this.m_timer.start();
         this.addEventListener(Event.REMOVED_FROM_STAGE,this.handleRemovedFromStage,false,0,true);
      }
      
      public function stopSelfTick() : void
      {
         if(this.m_timer != null)
         {
            this.removeEventListener(Event.REMOVED_FROM_STAGE,this.handleRemovedFromStage,false);
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.tickTimer,false);
            this.m_timer.stop();
            this.m_timer = null;
         }
      }
      
      public function update(a_ms:Number) : void
      {
         if(this.m_hasAnimationEnded)
         {
            if(hasEventListener(AnimationEvent.CHANGE))
            {
               dispatchEvent(new AnimationEvent(AnimationEvent.CHANGE,false,this.m_currentAnimationID));
            }
            if(this.m_isLooping)
            {
               this.startNewAnimation(this.m_animationQueue[0]);
            }
            else if(this.m_animationQueue.length <= 1)
            {
               this.m_animationQueue.splice(0);
               if(this.m_currentAnimationID == this.m_defaultAnimationID)
               {
                  this.m_isPlaying = false;
               }
               else
               {
                  this.startNewAnimation(this.m_defaultAnimationID);
               }
            }
            else
            {
               this.m_animationQueue.shift();
               this.startNewAnimation(this.m_animationQueue[0]);
            }
            this.m_hasAnimationEnded = false;
         }
         else if(this.m_hasRotationChanged)
         {
            this.m_bitmap.bitmapData = this.m_currentFrame.bitmapData[this.m_rotationFrame];
            this.m_hasRotationChanged = false;
         }
         if(this.m_isPlaying)
         {
            this.m_timeSinceLastUpdate += a_ms;
            if(this.m_timeSinceLastUpdate > this.m_animationDelay)
            {
               this.m_timeSinceLastUpdate -= this.m_animationDelay;
               this.updateFrame();
            }
         }
      }
      
      public function queue(a_animationID:String) : void
      {
         var animation:Animation = this.m_animationMap[a_animationID];
         if(animation == null)
         {
            throw new Error("<AnimationPlayer> Invalid Animation ID!");
         }
         this.m_animationQueue.push(a_animationID);
      }
      
      public function copy() : AnimationPlayer
      {
         var id:String = null;
         var player:AnimationPlayer = new AnimationPlayer();
         for(var i:int = 0; i < this.m_IDArray.length; i++)
         {
            id = this.m_IDArray[i];
            player.addAnimation(id,this.m_animationMap[id]);
         }
         player.defaultAnimationID = this.m_defaultAnimationID;
         player.fps = this.m_fps;
         player.play(this.m_defaultAnimationID);
         player.m_bitmap.bitmapData = this.m_bitmap.bitmapData;
         return player;
      }
      
      private function handleRemovedFromStage(a_event:Event) : void
      {
         this.stopSelfTick();
      }
      
      private function tickTimer(a_event:TimerEvent) : void
      {
         this.update(this.m_timerInterval);
      }
      
      private function performOffset() : void
      {
         var signX:int = -1;
         var signY:int = -1;
         if(scaleX < 0)
         {
            signX = 1;
         }
         if(scaleY < 0)
         {
            signY = 1;
         }
         super.x = this.m_desiredX + signX * this.offsetX;
         super.y = this.m_desiredY + signY * this.offsetY;
      }
      
      private function startNewAnimation(a_animationID:String) : void
      {
         this.m_timeSinceLastUpdate = 0;
         this.m_currentAnimationID = a_animationID;
         this.m_currentAnimation = this.m_animationMap[this.m_currentAnimationID];
         if(this.m_currentAnimation == null)
         {
            this.m_currentAnimationID = this.m_defaultAnimationID;
            this.m_currentAnimation = this.m_animationMap[this.m_currentAnimationID];
         }
         else
         {
            this.m_currentAnimation.releaseCachedFrame(this.m_frameIndex);
         }
         if(this.m_currentAnimation.isUsingDeltaFrames() || this.m_currentAnimation.isDisposed && PerformanceExperimentManager.isInAnimationMemoryExperiment)
         {
            this.m_currentAnimation.start();
         }
         this.fps = this.m_currentAnimation.m_fps;
         this.m_frames = this.m_currentAnimation.m_frames;
         this.m_framesMap = this.m_currentAnimation.m_frameMap;
         this.m_isLooping = this.m_currentAnimation.isLooping;
         this.m_totalFrames = this.m_frames.length;
         this.m_frameIndex = 0;
         if(this.m_currentAnimation.isUsingDeltaFrames())
         {
            this.m_bitmap.bitmapData = new BitmapData(this.m_currentAnimation.m_width,this.m_currentAnimation.m_height,true,0);
         }
         this.m_currentFrame = this.m_currentAnimation.getFrame(0,this.m_bitmap.bitmapData);
         if(this.m_currentAnimation.isUsingDeltaFrames() == false)
         {
            this.m_bitmap.bitmapData = this.m_currentFrame.bitmapData[this.m_rotationFrame];
         }
         this.performOffset();
         if(hasEventListener(AnimationEvent.CHANGE))
         {
            dispatchEvent(new AnimationEvent(AnimationEvent.CHANGE,true,this.m_currentAnimationID));
         }
      }
      
      private function updateFrame() : void
      {
         if(this.m_currentFrame == null)
         {
            return;
         }
         ++this.m_framesPassed;
         if(this.m_framesPassed >= this.m_currentFrame.numFrames)
         {
            this.m_framesPassed = 0;
            this.m_currentAnimation.releaseCachedFrame(this.m_frameIndex);
            if(++this.m_frameIndex >= this.m_totalFrames)
            {
               if(!this.m_isLooping)
               {
                  this.m_hasAnimationEnded = true;
                  return;
               }
               this.m_frameIndex = 0;
            }
            this.m_currentFrame = this.m_currentAnimation.getFrame(this.m_frameIndex,this.m_bitmap.bitmapData);
            if(this.m_currentAnimation.isUsingDeltaFrames() == false)
            {
               this.m_bitmap.bitmapData = this.m_currentFrame.bitmapData[this.m_rotationFrame];
            }
            this.performOffset();
            if(this.m_currentFrame.frameID != null)
            {
               if(hasEventListener(FrameEvent.CHANGE))
               {
                  dispatchEvent(new FrameEvent(FrameEvent.CHANGE,true,this.m_currentFrame.frameID,this.m_currentAnimationID));
               }
            }
         }
      }
   }
}

