package com.infomatiq.jsi
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class RectangleUtil
   {
      
      public function RectangleUtil()
      {
         super();
      }
      
      public static function create(param1:Number, param2:Number, param3:Number, param4:Number) : Rectangle
      {
         var _loc5_:Rectangle = new Rectangle();
         if(param1 < param3)
         {
            _loc5_.left = param1;
            _loc5_.right = param3;
         }
         else
         {
            _loc5_.left = param3;
            _loc5_.right = param1;
         }
         if(param2 < param4)
         {
            _loc5_.top = param2;
            _loc5_.bottom = param4;
         }
         else
         {
            _loc5_.top = param4;
            _loc5_.bottom = param2;
         }
         return _loc5_;
      }
      
      public static function clone(param1:Rectangle) : Rectangle
      {
         var _loc2_:Rectangle = null;
         if(param1 != null)
         {
            _loc2_ = new Rectangle(param1.x,param1.y,param1.width,param1.height);
         }
         return _loc2_;
      }
      
      public static function intersects(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number) : Boolean
      {
         return param3 >= param5 && param1 <= param7 && param4 >= param6 && param2 <= param8;
      }
      
      public static function intersection(param1:Rectangle, param2:Rectangle) : Rectangle
      {
         var _loc3_:Rectangle = null;
         if(intersects(param1.left,param1.top,param1.right,param1.bottom,param2.left,param2.top,param2.right,param2.bottom))
         {
            _loc3_ = create(Math.max(param1.left,param2.left),Math.max(param1.top,param2.top),Math.min(param1.right,param2.right),Math.min(param1.bottom,param2.bottom));
         }
         return _loc3_;
      }
      
      public static function contains(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number) : Boolean
      {
         return param3 >= param7 && param1 <= param5 && param4 >= param8 && param2 <= param6;
      }
      
      public static function distance(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number) : Number
      {
         return Math.sqrt(distanceSq(param1,param2,param3,param4,param5,param6));
      }
      
      public static function distanceSq(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number) : Number
      {
         var _loc7_:Number = 0;
         var _loc8_:Number = 0;
         if(param1 > param5)
         {
            _loc7_ = param1 - param5;
            _loc7_ *= _loc7_;
         }
         else if(param5 > param3)
         {
            _loc7_ = param5 - param3;
            _loc7_ *= _loc7_;
         }
         if(param2 > param6)
         {
            _loc8_ = param2 - param6;
            _loc8_ *= _loc8_;
         }
         else if(param6 > param4)
         {
            _loc8_ = param6 - param4;
            _loc8_ *= _loc8_;
         }
         return _loc7_ + _loc8_;
      }
      
      public static function enlargement(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number) : Number
      {
         var _loc9_:Number = (param3 - param1) * (param4 - param2);
         if(_loc9_ == Number.POSITIVE_INFINITY)
         {
            return 0;
         }
         if(param5 < param1)
         {
            param1 = param5;
         }
         if(param6 < param2)
         {
            param2 = param6;
         }
         if(param7 > param3)
         {
            param3 = param7;
         }
         if(param8 > param4)
         {
            param4 = param8;
         }
         var _loc10_:Number = (param3 - param1) * (param4 - param2);
         if(_loc10_ == Number.POSITIVE_INFINITY)
         {
            return Number.POSITIVE_INFINITY;
         }
         return _loc10_ - _loc9_;
      }
      
      public static function area(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return (param3 - param1) * (param4 - param2);
      }
      
      public static function midpoint(param1:Rectangle) : Point
      {
         var _loc2_:Point = null;
         if(param1 != null)
         {
            _loc2_ = new Point(param1.x + param1.width / 2,param1.y + param1.height / 2);
         }
         return _loc2_;
      }
      
      public static function equals(param1:Rectangle, param2:Rectangle) : Boolean
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc3_:Boolean = false;
         if(param1 != null && param2 != null)
         {
            if(param1.left < param1.right)
            {
               _loc4_ = param1.left;
               _loc6_ = param1.right;
            }
            else
            {
               _loc4_ = param1.right;
               _loc6_ = param1.left;
            }
            if(param1.top < param1.bottom)
            {
               _loc5_ = param1.top;
               _loc7_ = param1.bottom;
            }
            else
            {
               _loc5_ = param1.bottom;
               _loc7_ = param1.top;
            }
            if(param2.left < param2.right)
            {
               _loc8_ = param2.left;
               _loc10_ = param2.right;
            }
            else
            {
               _loc8_ = param2.right;
               _loc10_ = param2.left;
            }
            if(param2.top < param2.bottom)
            {
               _loc9_ = param2.top;
               _loc11_ = param2.bottom;
            }
            else
            {
               _loc9_ = param2.bottom;
               _loc11_ = param2.top;
            }
            _loc3_ = _loc4_ == _loc8_ && _loc5_ == _loc9_ && _loc6_ == _loc10_ && _loc7_ == _loc11_;
         }
         return _loc3_;
      }
   }
}

