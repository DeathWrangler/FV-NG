package com.boostworthy.animation.sequence.tweens
{
   import com.boostworthy.animation.easing.Transitions;
   
   public class Tween implements ITween
   {
      
      protected const DEFAULT_TRANSITION:String = "linear";
      
      protected var m_objToTween:Object;
      
      protected var m_strProperty:String;
      
      protected var m_uFirstFrame:uint;
      
      protected var m_uLastFrame:uint;
      
      protected var m_nStartValue:Number;
      
      protected var m_nTargetValue:Number;
      
      protected var m_nChangeValue:Number;
      
      protected var m_strTransition:String;
      
      protected var m_fncTransition:Function;
      
      protected var m_bIsDirty:Boolean;
      
      public function Tween(param1:Object, param2:String, param3:Number, param4:uint, param5:uint, param6:String = "linear")
      {
         super();
         this.m_objToTween = param1;
         this.m_strProperty = param2;
         this.m_nTargetValue = param3;
         this.m_uFirstFrame = param4;
         this.m_uLastFrame = param5;
         this.m_strTransition = param6;
         this.m_fncTransition = Transitions[this.m_strTransition];
      }
      
      public function clone() : ITween
      {
         return new Tween(this.m_objToTween,this.m_strProperty,this.m_nTargetValue,this.m_uFirstFrame,this.m_uLastFrame,this.m_strTransition);
      }
      
      public function renderFrame(param1:uint) : void
      {
         var _loc2_:Number = NaN;
         if(param1 < this.m_uFirstFrame && !isNaN(this.m_nStartValue))
         {
            this.m_objToTween[this.m_strProperty] = this.m_nStartValue;
            this.m_bIsDirty = true;
         }
         else if(param1 >= this.m_uFirstFrame && param1 <= this.m_uLastFrame)
         {
            _loc2_ = (param1 - this.m_uFirstFrame) / (this.m_uLastFrame - this.m_uFirstFrame);
            if(isNaN(this.m_nStartValue) && param1 == this.m_uFirstFrame)
            {
               this.m_nStartValue = this.m_objToTween[this.m_strProperty];
               this.m_nChangeValue = this.m_nTargetValue - this.m_nStartValue;
            }
            this.m_objToTween[this.m_strProperty] = this.m_fncTransition(_loc2_,this.m_nStartValue,this.m_nChangeValue,1);
            this.m_bIsDirty = true;
         }
         else if(param1 > this.m_uLastFrame && this.m_bIsDirty)
         {
            this.m_objToTween[this.m_strProperty] = this.m_nTargetValue;
            this.m_bIsDirty = false;
         }
      }
      
      public function get firstFrame() : uint
      {
         return this.m_uFirstFrame;
      }
      
      public function get lastFrame() : uint
      {
         return this.m_uLastFrame;
      }
      
      public function get target() : Object
      {
         return this.m_objToTween;
      }
      
      public function get property() : String
      {
         return this.m_strProperty;
      }
   }
}

