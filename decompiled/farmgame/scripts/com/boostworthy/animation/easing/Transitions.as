package com.boostworthy.animation.easing
{
   public final class Transitions
   {
      
      public static const LINEAR:String = "linear";
      
      public static const LINEAR_RANDOM:String = "linearRandom";
      
      public static const SINE_IN:String = "sineIn";
      
      public static const SINE_OUT:String = "sineOut";
      
      public static const SINE_IN_AND_OUT:String = "sineInAndOut";
      
      public static const QUAD_IN:String = "quadIn";
      
      public static const QUAD_OUT:String = "quadOut";
      
      public static const QUAD_IN_AND_OUT:String = "quadInAndOut";
      
      public static const CUBIC_IN:String = "cubicIn";
      
      public static const CUBIC_OUT:String = "cubicOut";
      
      public static const CUBIC_IN_AND_OUT:String = "cubicInAndOut";
      
      public static const QUART_IN:String = "quartIn";
      
      public static const QUART_OUT:String = "quartOut";
      
      public static const QUART_IN_AND_OUT:String = "quartInAndOut";
      
      public static const QUINT_IN:String = "quintIn";
      
      public static const QUINT_OUT:String = "quintOut";
      
      public static const QUINT_IN_AND_OUT:String = "quintInAndOut";
      
      public static const EXPO_IN:String = "expoIn";
      
      public static const EXPO_OUT:String = "expoOut";
      
      public static const EXPO_IN_AND_OUT:String = "expoInAndOut";
      
      public static const BACK_IN:String = "backIn";
      
      public static const BACK_OUT:String = "backOut";
      
      public static const BACK_IN_AND_OUT:String = "backInAndOut";
      
      public static const BOUNCE:String = "bounce";
      
      public static const ELASTIC_IN:String = "elasticIn";
      
      public static const ELASTIC_OUT:String = "elasticOut";
      
      public static const ELASTIC_IN_AND_OUT:String = "elasticInAndOut";
      
      public static const DEFAULT_TRANSITION:String = LINEAR;
      
      private static const BACK_OVERSHOOT:Number = 1.70158;
      
      private static const ELASTIC_AMPLITUDE:Number = undefined;
      
      private static const ELASTIC_PERIOD:Number = 400;
      
      public function Transitions()
      {
         super();
      }
      
      public static function linearRandom(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         var _loc5_:Number = Math.sin(param1 * 2 * 3.1415);
         _loc5_ = _loc5_ / param3;
         _loc5_ = _loc5_ * 1;
         return param3 * param1 / param4 + param2 + _loc5_;
      }
      
      public static function linear(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return param3 * param1 / param4 + param2;
      }
      
      public static function sineIn(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return -param3 * Math.cos(param1 / param4 * (Math.PI / 2)) + param2 + param3;
      }
      
      public static function sineOut(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return param3 * Math.sin(param1 / param4 * (Math.PI / 2)) + param2;
      }
      
      public static function sineInAndOut(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return -param3 / 2 * (Math.cos(param1 / param4 * Math.PI) - 1) + param2;
      }
      
      public static function quadIn(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return param3 * (param1 = param1 / param4) * param1 + param2;
      }
      
      public static function quadOut(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return -param3 * (param1 = param1 / param4) * (param1 - 2) + param2;
      }
      
      public static function quadInAndOut(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         param1 = param1 / (param4 / 2);
         if(param1 < 1)
         {
            return param3 / 2 * param1 * param1 + param2;
         }
         return -param3 / 2 * (--param1 * (param1 - 2) - 1) + param2;
      }
      
      public static function cubicIn(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return param3 * (param1 = param1 / param4) * param1 * param1 + param2;
      }
      
      public static function cubicOut(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return param3 * ((param1 = param1 / param4 - 1) * param1 * param1 + 1) + param2;
      }
      
      public static function cubicInAndOut(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         param1 = param1 / (param4 / 2);
         if(param1 < 1)
         {
            return param3 / 2 * param1 * param1 * param1 + param2;
         }
         return param3 / 2 * ((param1 = param1 - 2) * param1 * param1 + 2) + param2;
      }
      
      public static function quartIn(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return param3 * (param1 = param1 / param4) * param1 * param1 * param1 + param2;
      }
      
      public static function quartOut(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return -param3 * ((param1 = param1 / param4 - 1) * param1 * param1 * param1 - 1) + param2;
      }
      
      public static function quartInAndOut(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         param1 = param1 / (param4 / 2);
         if(param1 < 1)
         {
            return param3 / 2 * param1 * param1 * param1 * param1 + param2;
         }
         return -param3 / 2 * ((param1 = param1 - 2) * param1 * param1 * param1 - 2) + param2;
      }
      
      public static function quintIn(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return param3 * (param1 = param1 / param4) * param1 * param1 * param1 * param1 + param2;
      }
      
      public static function quintOut(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return param3 * ((param1 = param1 / param4 - 1) * param1 * param1 * param1 * param1 + 1) + param2;
      }
      
      public static function quintInAndOut(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         param1 = param1 / (param4 / 2);
         if(param1 < 1)
         {
            return param3 / 2 * param1 * param1 * param1 * param1 * param1 + param2;
         }
         return param3 / 2 * ((param1 = param1 - 2) * param1 * param1 * param1 * param1 + 2) + param2;
      }
      
      public static function expoIn(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return param1 == 0 ? param2 : param3 * Math.pow(2,10 * (param1 / param4 - 1)) + param2;
      }
      
      public static function expoOut(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return param1 == param4 ? param2 + param3 : param3 * (-Math.pow(2,-10 * param1 / param4) + 1) + param2;
      }
      
      public static function expoInAndOut(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         if(param1 == 0)
         {
            return param2;
         }
         if(param1 == param4)
         {
            return param2 + param3;
         }
         param1 = param1 / (param4 / 2);
         if(param1 < 1)
         {
            return param3 / 2 * Math.pow(2,10 * (param1 - 1)) + param2;
         }
         return param3 / 2 * (-Math.pow(2,-10 * --param1) + 2) + param2;
      }
      
      public static function backIn(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         var _loc5_:Number = BACK_OVERSHOOT;
         return param3 * (param1 = param1 / param4) * param1 * ((_loc5_ + 1) * param1 - _loc5_) + param2;
      }
      
      public static function backOut(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         var _loc5_:Number = BACK_OVERSHOOT;
         return param3 * ((param1 = param1 / param4 - 1) * param1 * ((_loc5_ + 1) * param1 + _loc5_) + 1) + param2;
      }
      
      public static function backInAndOut(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         var _loc5_:Number = BACK_OVERSHOOT;
         param1 = param1 / (param4 / 2);
         if(param1 < 1)
         {
            return param3 / 2 * (param1 * param1 * (((_loc5_ = _loc5_ * 1.525) + 1) * param1 - _loc5_)) + param2;
         }
         return param3 / 2 * ((param1 = param1 - 2) * param1 * (((_loc5_ = _loc5_ * 1.525) + 1) * param1 + _loc5_) + 2) + param2;
      }
      
      public static function bounce(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         param1 = param1 / param4;
         if(param1 < 1 / 2.75)
         {
            return param3 * (7.5625 * param1 * param1) + param2;
         }
         if(param1 < 2 / 2.75)
         {
            return param3 * (7.5625 * (param1 = param1 - 1.5 / 2.75) * param1 + 0.75) + param2;
         }
         if(param1 < 2.5 / 2.75)
         {
            return param3 * (7.5625 * (param1 = param1 - 2.25 / 2.75) * param1 + 0.9375) + param2;
         }
         return param3 * (7.5625 * (param1 = param1 - 2.625 / 2.75) * param1 + 0.984375) + param2;
      }
      
      public static function elasticIn(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         var _loc7_:Number = NaN;
         var _loc5_:Number = ELASTIC_AMPLITUDE;
         var _loc6_:Number = ELASTIC_PERIOD;
         if(param1 == 0)
         {
            return param2;
         }
         param1 = param1 / param4;
         if(param1 == 1)
         {
            return param2 + param3;
         }
         if(!_loc6_)
         {
            _loc6_ = param4 * 0.3;
         }
         if(!_loc5_ || _loc5_ < Math.abs(param3))
         {
            _loc5_ = param3;
            _loc7_ = _loc6_ / 4;
         }
         else
         {
            _loc7_ = _loc6_ / (2 * Math.PI) * Math.asin(param3 / _loc5_);
         }
         return -(_loc5_ * Math.pow(2,10 * (param1 = param1 - 1)) * Math.sin((param1 * param4 - _loc7_) * (2 * Math.PI) / _loc6_)) + param2;
      }
      
      public static function elasticOut(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         var _loc7_:Number = NaN;
         var _loc5_:Number = ELASTIC_AMPLITUDE;
         var _loc6_:Number = ELASTIC_PERIOD;
         if(param1 == 0)
         {
            return param2;
         }
         param1 = param1 / param4;
         if(param1 == 1)
         {
            return param2 + param3;
         }
         if(!_loc6_)
         {
            _loc6_ = param4 * 0.3;
         }
         if(!_loc5_ || _loc5_ < Math.abs(param3))
         {
            _loc5_ = param3;
            _loc7_ = _loc6_ / 4;
         }
         else
         {
            _loc7_ = _loc6_ / (2 * Math.PI) * Math.asin(param3 / _loc5_);
         }
         return _loc5_ * Math.pow(2,-10 * param1) * Math.sin((param1 * param4 - _loc7_) * (2 * Math.PI) / _loc6_) + param3 + param2;
      }
      
      public static function elasticInAndOut(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         var _loc7_:Number = NaN;
         var _loc5_:Number = ELASTIC_AMPLITUDE;
         var _loc6_:Number = ELASTIC_PERIOD;
         if(param1 == 0)
         {
            return param2;
         }
         param1 = param1 / (param4 / 2);
         if(param1 == 2)
         {
            return param2 + param3;
         }
         if(!_loc6_)
         {
            _loc6_ = param4 * (0.3 * 1.5);
         }
         if(!_loc5_ || _loc5_ < Math.abs(param3))
         {
            _loc5_ = param3;
            _loc7_ = _loc6_ / 4;
         }
         else
         {
            _loc7_ = _loc6_ / (2 * Math.PI) * Math.asin(param3 / _loc5_);
         }
         if(param1 < 1)
         {
            return -0.5 * (_loc5_ * Math.pow(2,10 * (param1 = param1 - 1)) * Math.sin((param1 * param4 - _loc7_) * (2 * Math.PI) / _loc6_)) + param2;
         }
         return _loc5_ * Math.pow(2,-10 * (param1 = param1 - 1)) * Math.sin((param1 * param4 - _loc7_) * (2 * Math.PI) / _loc6_) * 0.5 + param3 + param2;
      }
   }
}

