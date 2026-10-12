package Engine
{
   import Engine.Interfaces.IComparator;
   
   public class ArrayUtil
   {
      
      public function ArrayUtil()
      {
         super();
      }
      
      public static function reduce(param1:Array, param2:Function) : *
      {
         var _loc3_:* = null;
         if(param1.length == 0)
         {
            _loc3_ = null;
         }
         else if(param1.length == 1)
         {
            _loc3_ = param1[0];
         }
         else
         {
            _loc3_ = param2(param1[0],reduce(param1.slice(1),param2));
         }
         return _loc3_;
      }
      
      public static function mapreduce(param1:Array, param2:Function, param3:Function) : *
      {
         return reduce(param1.map(param2),param3);
      }
      
      public static function flatten(param1:Array) : Array
      {
         var _loc2_:Array = null;
         if(param1.length == 0)
         {
            _loc2_ = new Array();
         }
         else if(param1[0] is Array)
         {
            _loc2_ = flatten(param1[0] as Array).concat(flatten(param1.slice(1)));
         }
         else
         {
            _loc2_ = [param1[0]].concat(flatten(param1.slice(1)));
         }
         return _loc2_;
      }
      
      public static function partition(param1:Array, param2:Function, param3:* = null) : Array
      {
         var t:Array = null;
         var f:Array = null;
         var source:Array = param1;
         var predicate:Function = param2;
         var context:* = param3;
         t = [];
         f = [];
         source.forEach(function(param1:*, param2:int, param3:Array):void
         {
            if(predicate.call(this,param1))
            {
               t.push(param1);
            }
            else
            {
               f.push(param1);
            }
         },context);
         return [t,f];
      }
      
      public static function without(param1:Array, param2:*) : Array
      {
         var _loc3_:Array = null;
         var _loc5_:int = 0;
         var _loc4_:int = param1.indexOf(param2);
         if(_loc4_ < 0)
         {
            _loc3_ = param1;
         }
         else
         {
            _loc3_ = new Array(param1.length - 1);
            _loc5_ = 0;
            while(_loc5_ < param1.length)
            {
               if(_loc5_ != _loc4_)
               {
                  _loc3_.push(param1[_loc5_]);
               }
               _loc5_++;
            }
         }
         return _loc3_;
      }
      
      public static function join(param1:Array, param2:String = "", param3:String = "", param4:String = "") : String
      {
         return param2 + param1.join(param3) + param4;
      }
      
      public static function randomize(param1:Array, param2:int = 0, param3:int = 2147483647) : void
      {
         var _loc4_:* = undefined;
         var _loc5_:int = 0;
         if(param3 > param1.length)
         {
            param3 = int(param1.length);
         }
         if(param2 < 0)
         {
            param2 = 0;
         }
         var _loc6_:int = param2;
         while(_loc6_ < param3)
         {
            _loc5_ = param2 + int(Math.random() * (param3 - param2));
            _loc4_ = param1[_loc5_];
            param1[_loc5_] = param1[_loc6_];
            param1[_loc6_] = _loc4_;
            _loc6_++;
         }
      }
      
      public static function insertionSort(param1:Array, param2:IComparator) : void
      {
         var _loc3_:uint = 0;
         var _loc4_:uint = 0;
         var _loc5_:* = undefined;
         var _loc6_:uint = 0;
         if(param1.length > 1)
         {
            _loc3_ = param1.length;
            _loc4_ = 1;
            while(_loc4_ < _loc3_)
            {
               _loc5_ = param1[_loc4_];
               _loc6_ = _loc4_;
               while(_loc6_ > 0 && param2.compare(param1[_loc6_ - 1],_loc5_) == 1)
               {
                  param1[_loc6_] = param1[_loc6_ - 1];
                  _loc6_--;
               }
               param1[_loc6_] = _loc5_;
               _loc4_++;
            }
         }
      }
      
      public static function mergeSort(param1:Array, param2:IComparator) : void
      {
         var _loc3_:uint = 0;
         var _loc4_:uint = 0;
         var _loc5_:Array = null;
         var _loc6_:Array = null;
         var _loc7_:uint = 0;
         var _loc8_:uint = 0;
         var _loc9_:uint = 0;
         if(param1.length > 1)
         {
            _loc3_ = Math.floor(param1.length / 2);
            _loc4_ = param1.length - _loc3_;
            _loc5_ = new Array(_loc3_);
            _loc6_ = new Array(_loc4_);
            _loc7_ = 0;
            _loc7_ = 0;
            while(_loc7_ < _loc3_)
            {
               _loc5_[_loc7_] = param1[_loc7_];
               _loc7_++;
            }
            _loc7_ = _loc3_;
            while(_loc7_ < _loc3_ + _loc4_)
            {
               _loc6_[_loc7_ - _loc3_] = param1[_loc7_];
               _loc7_++;
            }
            mergeSort(_loc5_,param2);
            mergeSort(_loc6_,param2);
            _loc7_ = 0;
            _loc8_ = 0;
            _loc9_ = 0;
            while(_loc5_.length != _loc8_ && _loc6_.length != _loc9_)
            {
               if(param2.compare(_loc5_[_loc8_],_loc6_[_loc9_]) != 1)
               {
                  param1[_loc7_] = _loc5_[_loc8_];
                  _loc7_++;
                  _loc8_++;
               }
               else
               {
                  param1[_loc7_] = _loc6_[_loc9_];
                  _loc7_++;
                  _loc9_++;
               }
            }
            while(_loc5_.length != _loc8_)
            {
               param1[_loc7_] = _loc5_[_loc8_];
               _loc7_++;
               _loc8_++;
            }
            while(_loc6_.length != _loc9_)
            {
               param1[_loc7_] = _loc6_[_loc9_];
               _loc7_++;
               _loc9_++;
            }
         }
      }
   }
}

