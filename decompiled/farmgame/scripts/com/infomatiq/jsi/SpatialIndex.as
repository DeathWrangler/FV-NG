package com.infomatiq.jsi
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public interface SpatialIndex
   {
      
      function init(param1:Object) : void;
      
      function add(param1:Rectangle, param2:int) : Boolean;
      
      function remove(param1:Rectangle, param2:int) : Boolean;
      
      function nearest(param1:Point, param2:Number, param3:Function = null) : Vector.<int>;
      
      function nearestN(param1:Point, param2:int, param3:Number, param4:Function = null) : Vector.<int>;
      
      function nearestNUnsorted(param1:Point, param2:int, param3:Number, param4:Function = null) : Vector.<int>;
      
      function intersects(param1:Rectangle, param2:Function) : void;
      
      function contains(param1:Rectangle, param2:Function = null) : Vector.<int>;
      
      function containing(param1:Rectangle, param2:Function = null) : Vector.<int>;
      
      function size() : int;
      
      function getBounds() : Rectangle;
   }
}

