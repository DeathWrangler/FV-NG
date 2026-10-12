package com.boostworthy.animation.sequence.tweens
{
   public interface ITween
   {
      
      function clone() : ITween;
      
      function renderFrame(param1:uint) : void;
      
      function get firstFrame() : uint;
      
      function get lastFrame() : uint;
      
      function get target() : Object;
      
      function get property() : String;
   }
}

