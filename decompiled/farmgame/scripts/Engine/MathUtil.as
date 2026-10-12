package Engine
{
   import flash.geom.Point;
   
   public class MathUtil
   {
      
      public function MathUtil()
      {
         super();
      }
      
      public static function clamp(param1:Number, param2:Number, param3:Number) : Number
      {
         return Math.min(Math.max(param2,param1),param3);
      }
      
      public static function wrap(param1:Number, param2:Number, param3:Number = 0) : Number
      {
         var _loc4_:Number = param2 - param3;
         while(param1 >= param2)
         {
            param1 -= _loc4_;
         }
         while(param1 < param3)
         {
            param1 += _loc4_;
         }
         return param1;
      }
      
      public static function interpolate(param1:Number, param2:Number, param3:Number) : Number
      {
         return (1 - param1) * param2 + param1 * param3;
      }
      
      public static function random(param1:int, param2:int = 0) : int
      {
         return Math.floor(Math.random() * (param1 - param2)) + param2;
      }
      
      public static function randomIncl(param1:int, param2:int) : int
      {
         return Math.floor(Math.random() * (param1 - param2 + 1)) + param2;
      }
      
      public static function randomEpsilon(param1:int, param2:int) : int
      {
         return random(param1 + param2,param1 - param2);
      }
      
      public static function randomIndex(param1:Array) : int
      {
         return random(param1.length);
      }
      
      public static function randomElement(param1:Array) : *
      {
         return param1.length == 0 ? null : param1[random(param1.length)];
      }
      
      public static function randomIndexWeighed(param1:Array) : int
      {
         var _loc5_:Number = NaN;
         var _loc2_:Number = 0;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_ += param1[_loc3_];
            _loc3_++;
         }
         var _loc4_:Number = Math.random() * _loc2_;
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            _loc5_ = Number(param1[_loc3_]);
            if(_loc4_ < _loc5_)
            {
               return _loc3_;
            }
            _loc4_ -= _loc5_;
            _loc3_++;
         }
         return -1;
      }
      
      public static function randomWobble(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = param2 * param1;
         return param1 + (2 * Math.random() - 1) * _loc3_;
      }
      
      public static function inEpsilonRange(param1:Number, param2:Number, param3:Number) : Boolean
      {
         return Math.abs(param1 - param2) < param3;
      }
      
      public static function distance(param1:Point, param2:Point, param3:int = 2) : Number
      {
         var _loc4_:Number = param1.x - param2.x;
         var _loc5_:Number = param1.y - param2.y;
         if(param3 == 2)
         {
            return Math.sqrt(_loc4_ * _loc4_ + _loc5_ * _loc5_);
         }
         if(param3 == 1)
         {
            return Math.abs(_loc4_) + Math.abs(_loc5_);
         }
         if(param3 > 0)
         {
            return Math.pow(Math.pow(Math.abs(_loc4_),param3) + Math.pow(Math.abs(_loc5_),param3),1 / param3);
         }
         return _loc4_ > _loc5_ ? _loc4_ : _loc5_;
      }
   }
}

