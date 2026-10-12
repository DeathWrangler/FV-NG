package ZLocalization
{
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   public class Utilities
   {
      
      public function Utilities()
      {
         super();
      }
      
      public static function clamp(param1:Number, param2:Number, param3:Number) : Number
      {
         var _loc4_:Number = Math.max(param1,param2);
         return Math.min(_loc4_,param3);
      }
      
      public static function formatNumber(param1:int) : String
      {
         var _loc4_:Number = NaN;
         var _loc2_:String = param1.toString();
         var _loc3_:Array = new Array();
         var _loc5_:Number = _loc2_.length;
         while(_loc5_ > 0)
         {
            _loc4_ = Math.max(_loc5_ - 3,0);
            _loc3_.unshift(_loc2_.slice(_loc4_,_loc5_));
            _loc5_ = _loc4_;
         }
         return _loc3_.join(",");
      }
      
      public static function parseLocalizationString(param1:String) : Object
      {
         var _loc2_:Array = param1.split(":");
         var _loc3_:Object = new Object();
         _loc3_.filename = _loc2_[0];
         _loc3_.stringname = _loc2_[1];
         return _loc3_;
      }
      
      public static function dateToNumber(param1:String, param2:Boolean = false) : Number
      {
         var _loc4_:Array = null;
         var _loc3_:Number = 0;
         if(param2)
         {
            _loc4_ = String(param1).split("/",3);
            _loc3_ = Date.UTC(parseInt(_loc4_[2]),parseInt(_loc4_[0]) - 1,parseInt(_loc4_[1]));
         }
         else
         {
            _loc3_ = new Date(param1).valueOf();
         }
         return _loc3_;
      }
      
      public static function xmlListToArray(param1:XMLList, param2:String = "") : Array
      {
         var _loc4_:XML = null;
         var _loc3_:Array = new Array();
         if(param2 == "")
         {
            for each(_loc4_ in param1)
            {
               _loc3_.push(_loc4_);
            }
         }
         else
         {
            for each(_loc4_ in param1)
            {
               _loc3_.push(String(_loc4_.attribute(param2)));
            }
         }
         return _loc3_;
      }
      
      public static function uncompress(param1:ByteArray) : String
      {
         var compressedData:ByteArray = param1;
         var compressedLength:int = int(compressedData.length);
         try
         {
            compressedData.uncompress();
         }
         catch(e:Error)
         {
            throw e;
         }
         return compressedData.toString();
      }
      
      public static function printr(param1:*, param2:int = 0, param3:String = "") : *
      {
         var _loc6_:* = undefined;
         var _loc7_:String = null;
         if(param2 == 0)
         {
            param3 = "(" + Utilities.typeOf(param1) + ") {\n";
         }
         else if(param2 == 10)
         {
            return param3;
         }
         var _loc4_:String = "\t";
         var _loc5_:int = 0;
         while(_loc5_ < param2)
         {
            _loc5_++;
            _loc4_ += "\t";
         }
         for(_loc6_ in param1)
         {
            param3 += _loc4_ + "[" + _loc6_ + "] => (" + Utilities.typeOf(param1[_loc6_]) + ") ";
            if(Utilities.count(param1[_loc6_]) == 0)
            {
               param3 += param1[_loc6_];
            }
            _loc7_ = "";
            if(typeof param1[_loc6_] != "xml")
            {
               _loc7_ = Utilities.printr(param1[_loc6_],param2 + 1);
            }
            if(_loc7_ != "")
            {
               param3 += "{\n" + _loc7_ + _loc4_ + "}";
            }
            param3 += "\n";
         }
         if(param2 == 0)
         {
            return;
         }
         return param3;
      }
      
      public static function typeOf(param1:*) : String
      {
         if(param1 is Array)
         {
            return "array";
         }
         if(param1 is Date)
         {
            return "date";
         }
         return typeof param1;
      }
      
      public static function count(param1:Object) : uint
      {
         var _loc2_:uint = 0;
         var _loc3_:* = undefined;
         if(Utilities.typeOf(param1) == "array")
         {
            return param1.length;
         }
         _loc2_ = 0;
         for(_loc3_ in param1)
         {
            if(_loc3_ != "mx_internal_uid")
            {
               _loc2_++;
            }
         }
         return _loc2_;
      }
      
      public static function trim(param1:String) : String
      {
         return param1.replace(/^(\s| )+|(\s| )+$/g,"");
      }
      
      public static function arrayRand(param1:Array) : Object
      {
         return param1[Math.floor(Math.random() * param1.length)];
      }
      
      public static function arrayDiff(param1:Array, param2:Array) : Array
      {
         var _loc3_:int = 0;
         var _loc6_:Object = null;
         var _loc4_:Array = new Array();
         var _loc5_:Dictionary = new Dictionary();
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            _loc5_[param1[_loc3_]] = true;
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < param2.length)
         {
            if(_loc5_[param2[_loc3_]])
            {
               delete _loc5_[param2[_loc3_]];
            }
            else
            {
               _loc4_.push(param2[_loc3_]);
            }
            _loc3_++;
         }
         for(_loc6_ in _loc5_)
         {
            _loc4_.push(_loc6_);
         }
         return _loc4_;
      }
      
      public static function arrayIntersect(param1:Array, param2:Array) : Array
      {
         var _loc3_:int = 0;
         var _loc4_:Array = new Array();
         var _loc5_:Dictionary = new Dictionary();
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            _loc5_[param1[_loc3_]] = true;
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < param2.length)
         {
            if(_loc5_[param2[_loc3_]])
            {
               _loc4_.push(param2[_loc3_]);
            }
            _loc3_++;
         }
         return _loc4_;
      }
      
      public static function getSuffixForFeedLocalization(param1:String) : String
      {
         var _loc2_:String = param1.substr(0,1);
         var _loc3_:String = "AEIOU";
         var _loc4_:String = "_consonant";
         if(_loc3_.indexOf(_loc2_) > -1)
         {
            _loc4_ = "_vowel";
         }
         return _loc4_;
      }
      
      public static function splitAndTrim(param1:String, param2:String) : Array
      {
         var _loc3_:Array = param2.split(param1);
         var _loc4_:int = 0;
         var _loc5_:int = int(_loc3_.length);
         while(_loc4_ < _loc5_)
         {
            _loc3_[_loc4_] = trim(_loc3_[_loc4_] as String);
            _loc4_++;
         }
         return _loc3_;
      }
   }
}

