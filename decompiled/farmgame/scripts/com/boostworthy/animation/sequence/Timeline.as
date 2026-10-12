package com.boostworthy.animation.sequence
{
   import com.boostworthy.animation.BoostworthyAnimation;
   import com.boostworthy.animation.rendering.Renderer;
   import com.boostworthy.animation.sequence.tweens.Action;
   import com.boostworthy.animation.sequence.tweens.ITween;
   import com.boostworthy.collections.iterators.IIterator;
   import com.boostworthy.collections.iterators.IteratorType;
   import com.boostworthy.core.IDisposable;
   import com.boostworthy.events.AnimationEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   
   [Event(name="animationFinish",type="com.boostworthy.events.AnimationEvent")]
   [Event(name="animationStop",type="com.boostworthy.events.AnimationEvent")]
   [Event(name="animationChange",type="com.boostworthy.events.AnimationEvent")]
   [Event(name="animationStart",type="com.boostworthy.events.AnimationEvent")]
   public class Timeline extends EventDispatcher implements IDisposable
   {
      
      protected const DEFAULT_RENDER_METHOD:uint = 2;
      
      protected const DEFAULT_FRAME_RATE:Number = 60;
      
      protected const DEFAULT_LOOP:Boolean = false;
      
      protected var m_objRendererPrev:Renderer;
      
      protected var m_objRendererNext:Renderer;
      
      protected var m_uRenderMethod:uint;
      
      protected var m_uFrameRate:uint;
      
      protected var m_nRefreshRate:Number;
      
      protected var m_objTweenStack:TweenStack;
      
      protected var m_uFrame:uint;
      
      protected var m_uLength:uint;
      
      protected var m_bLoop:Boolean;
      
      public function Timeline(param1:uint = 2, param2:Number = 60)
      {
         super();
         this.init(param1,param2);
      }
      
      protected function onPrevFrameEF(param1:Event) : void
      {
         this.prevFrame();
      }
      
      protected function onNextFrameEF(param1:Event) : void
      {
         this.nextFrame();
      }
      
      protected function onPrevFrameT(param1:TimerEvent) : void
      {
         this.prevFrame();
         param1.updateAfterEvent();
      }
      
      protected function onNextFrameT(param1:TimerEvent) : void
      {
         this.nextFrame();
         param1.updateAfterEvent();
      }
      
      public function setFrameRate(param1:Number) : void
      {
         this.m_uFrameRate = param1 > 0 ? uint(param1) : uint(this.DEFAULT_FRAME_RATE);
         this.m_nRefreshRate = Math.floor(1000 / this.m_uFrameRate);
      }
      
      public function addTween(param1:ITween) : void
      {
         var _loc2_:ITween = param1.clone();
         this.m_uLength = _loc2_.lastFrame > this.m_uLength ? _loc2_.lastFrame : this.m_uLength;
         this.m_objTweenStack.addElement(_loc2_);
         this.computeFrameData(_loc2_.firstFrame,_loc2_.lastFrame);
      }
      
      public function play() : void
      {
         this.stop();
         dispatchEvent(new AnimationEvent(AnimationEvent.START));
         this.m_objRendererNext.start(this.m_uRenderMethod);
      }
      
      public function playReverse() : void
      {
         this.stop();
         dispatchEvent(new AnimationEvent(AnimationEvent.START));
         this.m_objRendererPrev.start(this.m_uRenderMethod);
      }
      
      public function stop() : void
      {
         this.m_objRendererPrev.stop(this.m_uRenderMethod);
         this.m_objRendererNext.stop(this.m_uRenderMethod);
         dispatchEvent(new AnimationEvent(AnimationEvent.STOP));
      }
      
      public function gotoAndPlay(param1:uint) : void
      {
         this.stop();
         this.setFrame(param1);
         this.play();
      }
      
      public function gotoAndPlayReverse(param1:uint) : void
      {
         this.stop();
         this.setFrame(param1);
         this.playReverse();
      }
      
      public function gotoAndStop(param1:uint) : void
      {
         this.stop();
         this.setFrame(param1);
      }
      
      public function prevFrame() : void
      {
         this.setFrame(this.m_uFrame - 1);
      }
      
      public function nextFrame() : void
      {
         this.setFrame(this.m_uFrame + 1);
      }
      
      public function get length() : Number
      {
         return this.m_uLength;
      }
      
      public function get loop() : Boolean
      {
         return this.m_bLoop;
      }
      
      public function set loop(param1:Boolean) : void
      {
         this.m_bLoop = param1;
      }
      
      public function dispose() : void
      {
         this.stop();
         this.m_objRendererPrev.dispose();
         this.m_objRendererNext.dispose();
         this.m_objTweenStack.dispose();
         this.m_uRenderMethod = NaN;
         this.m_uFrameRate = NaN;
         this.m_nRefreshRate = NaN;
         this.m_uFrame = NaN;
         this.m_uLength = NaN;
         this.m_bLoop = false;
      }
      
      protected function init(param1:uint, param2:Number) : void
      {
         BoostworthyAnimation.log();
         this.setFrameRate(param2);
         this.m_uRenderMethod = param1;
         this.m_objRendererPrev = new Renderer(this.onPrevFrameEF,this.onPrevFrameT,this.m_nRefreshRate);
         this.m_objRendererNext = new Renderer(this.onNextFrameEF,this.onNextFrameT,this.m_nRefreshRate);
         this.m_objTweenStack = new TweenStack();
         this.m_uFrame = this.m_uLength = 1;
         this.loop = this.DEFAULT_LOOP;
      }
      
      protected function setFrame(param1:Number) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = false;
         if(param1 > this.m_uLength)
         {
            if(this.m_bLoop)
            {
               param1 = 1;
            }
            else
            {
               _loc3_ = true;
            }
         }
         if(param1 < 1)
         {
            if(this.m_bLoop)
            {
               param1 = this.m_uLength;
               _loc2_ = true;
            }
            else
            {
               _loc3_ = true;
            }
         }
         this.m_uFrame = Math.min(Math.max(1,param1),this.m_uLength);
         if(!_loc3_)
         {
            this.render(_loc2_);
         }
         dispatchEvent(new AnimationEvent(AnimationEvent.CHANGE));
         if(_loc3_)
         {
            this.stop();
            dispatchEvent(new AnimationEvent(AnimationEvent.FINISH));
         }
      }
      
      protected function computeFrameData(param1:uint, param2:uint) : void
      {
         var _loc5_:ITween = null;
         var _loc3_:IIterator = this.m_objTweenStack.getIterator(IteratorType.ARRAY_REVERSE);
         var _loc4_:int = int(param1);
         while(_loc4_ <= param2)
         {
            while(_loc3_.hasNext())
            {
               _loc5_ = _loc3_.next() as ITween;
               if(!(_loc5_ is Action))
               {
                  _loc5_.renderFrame(_loc4_);
               }
            }
            _loc3_.reset();
            _loc4_++;
         }
         this.render();
      }
      
      protected function render(param1:Boolean = false) : void
      {
         var _loc2_:IIterator = this.m_objTweenStack.getIterator(param1 ? IteratorType.ARRAY_REVERSE : IteratorType.ARRAY_FORWARD);
         while(_loc2_.hasNext())
         {
            _loc2_.next().renderFrame(this.m_uFrame);
         }
      }
   }
}

