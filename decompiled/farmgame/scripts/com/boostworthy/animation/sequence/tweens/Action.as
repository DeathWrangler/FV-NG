package com.boostworthy.animation.sequence.tweens
{
   public class Action implements ITween
   {
      
      protected const PROPERTY:String = "action";
      
      protected var m_fncForward:Function;
      
      protected var m_aParamsForward:Array;
      
      protected var m_fncReverse:Function;
      
      protected var m_aParamsReverse:Array;
      
      protected var m_uFirstFrame:uint;
      
      protected var m_uLastFrame:uint;
      
      protected var m_uPreviousFrame:uint;
      
      public function Action(param1:Function, param2:Array, param3:Function, param4:Array, param5:uint)
      {
         super();
         this.m_fncForward = param1;
         this.m_aParamsForward = param2;
         this.m_fncReverse = param3;
         this.m_aParamsReverse = param4;
         this.m_uFirstFrame = param5;
         this.m_uLastFrame = param5;
         this.m_uPreviousFrame = 1;
      }
      
      public function clone() : ITween
      {
         return new Action(this.m_fncForward,this.m_aParamsForward,this.m_fncReverse,this.m_aParamsReverse,this.m_uFirstFrame);
      }
      
      public function renderFrame(param1:uint) : void
      {
         if(param1 == this.m_uFirstFrame)
         {
            if(this.m_uPreviousFrame > param1)
            {
               this.m_fncReverse.apply(null,this.m_aParamsReverse);
            }
            else
            {
               this.m_fncForward.apply(null,this.m_aParamsForward);
            }
         }
         this.m_uPreviousFrame = param1;
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
         return null;
      }
      
      public function get property() : String
      {
         return this.PROPERTY;
      }
   }
}

