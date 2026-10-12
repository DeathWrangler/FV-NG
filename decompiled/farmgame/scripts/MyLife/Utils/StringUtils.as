package MyLife.Utils
{
   public class StringUtils
   {
      
      public function StringUtils()
      {
         super();
      }
      
      public static function getSingleUnitTimeStringFromMilliseconds(param1:Number, param2:String = null, param3:Boolean = true) : String
      {
         var _loc4_:String = null;
         var _loc5_:Number = NaN;
         if(param2 == null && param1 < 60000 || param2 == "S")
         {
            _loc5_ = Math.floor(param1 / 1000);
            _loc4_ = " second";
         }
         else if(param2 == null && param1 < 3600000 || param2 == "M")
         {
            _loc5_ = Math.floor(param1 / 60000);
            _loc4_ = " minute";
         }
         else if(param2 == null && param1 < 86400000 || param2 == "H")
         {
            _loc5_ = Math.floor(param1 / 3600000);
            _loc4_ = " hour";
         }
         else
         {
            _loc5_ = Math.floor(param1 / 86400000);
            _loc4_ = " day";
         }
         if(param3)
         {
            if(_loc5_ > 1)
            {
               _loc4_ += "s";
            }
            return String(_loc5_ + _loc4_);
         }
         if(_loc5_ < 10)
         {
            return String("0" + _loc5_);
         }
         return String(_loc5_);
      }
      
      public static function getMultiUnitTimeStringFromMilliseconds(param1:Number, param2:String) : String
      {
         var _loc5_:String = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc3_:Array = ["DHMS","DHM","HMS","DH","HM","MS","D","H","M","S"];
         var _loc4_:Boolean = false;
         for each(_loc5_ in _loc3_)
         {
            if(param2 == _loc5_)
            {
               _loc4_ = true;
               break;
            }
         }
         if(!_loc4_)
         {
            param2 = "DHMS";
         }
         var _loc6_:String = "";
         var _loc7_:Number = param1;
         var _loc8_:int = 0;
         while(_loc8_ < param2.length)
         {
            _loc9_ = param2.charAt(_loc8_);
            _loc10_ = getSingleUnitTimeStringFromMilliseconds(_loc7_,_loc9_,false);
            if(_loc9_ == "D")
            {
               _loc7_ %= 86400000;
            }
            else if(_loc9_ == "H")
            {
               _loc7_ %= 3600000;
            }
            else if(_loc9_ == "M")
            {
               _loc7_ %= 60000;
            }
            else if(_loc9_ == "S")
            {
               _loc7_ %= 1000;
            }
            if(_loc8_ > 0)
            {
               _loc6_ += ":";
            }
            _loc6_ += _loc10_;
            _loc8_++;
         }
         return _loc6_;
      }
      
      public static function getRankString(param1:int) : String
      {
         var _loc3_:String = null;
         var _loc2_:String = param1.toString();
         if(param1 > 100 || param1 == 0)
         {
            return _loc2_;
         }
         _loc3_ = _loc2_.charAt(_loc2_.length - 1);
         if(_loc3_ == "1")
         {
            if(param1 == 11)
            {
               return "11th";
            }
            return _loc2_ + "st";
         }
         if(_loc3_ == "2")
         {
            if(param1 == 12)
            {
               return "12th";
            }
            return _loc2_ + "nd";
         }
         if(_loc3_ == "3")
         {
            if(param1 == 13)
            {
               return "13th";
            }
            return _loc2_ + "rd";
         }
         return _loc2_ + "th";
      }
      
      public static function convertMetaDataStringToObject(param1:String) : Object
      {
         var _loc5_:Array = null;
         var _loc2_:Object = new Object();
         if(param1 == null || param1 == "")
         {
            return _loc2_;
         }
         var _loc3_:Array = param1.split("|");
         var _loc4_:Number = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = _loc3_[_loc4_].split(":");
            if(_loc5_.length == 2)
            {
               _loc2_[_loc5_[0]] = _loc5_[1];
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      public static function stripHTMLTags(param1:String) : String
      {
         var _loc2_:RegExp = /<[^<]+?>/gi;
         return param1.replace(_loc2_,"");
      }
      
      public static function stripLineBreaks(param1:String, param2:String = "\n") : String
      {
         var _loc3_:RegExp = /\r\n/g;
         var _loc4_:RegExp = /\r/g;
         var _loc5_:RegExp = /\n/g;
         param1 = param1.replace(_loc3_,param2);
         return param1.replace(_loc4_,param2);
      }
      
      public static function appendGETParams(param1:String, param2:Object) : String
      {
         var _loc5_:String = null;
         var _loc3_:String = param1 || "";
         var _loc4_:Boolean = true;
         for(_loc5_ in param2)
         {
            if(_loc4_)
            {
               _loc3_ += "?";
            }
            else
            {
               _loc3_ += "&";
            }
            _loc3_ += _loc5_ + "=" + param2[_loc5_];
         }
         return _loc3_;
      }
   }
}

