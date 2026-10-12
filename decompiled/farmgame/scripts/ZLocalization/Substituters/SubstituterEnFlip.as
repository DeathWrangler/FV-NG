package ZLocalization.Substituters
{
   public class SubstituterEnFlip extends SubstituterSimple
   {
      
      protected static var flipMap:Object = {
         "v":"ʌ",
         "k":"ʞ",
         "!":"¡",
         "w":"ʍ",
         "l":"ן",
         "a":"ɐ",
         "\"":"„",
         "m":"ɯ",
         "b":"q",
         ".":"˙",
         "y":"ʎ",
         "n":"u",
         "c":"ɔ",
         "d":"p",
         ";":"؛",
         "[":"]",
         "e":"ǝ",
         "\'":",",
         "<":">",
         "f":"ɟ",
         ",":"\'",
         "r":"ɹ",
         "g":"ƃ",
         "(":")",
         "h":"ɥ",
         "_":"‾",
         "?":"¿",
         "t":"ʇ",
         "i":"ı",
         "j":"ɾ"
      };
      
      protected static const OPEN_BRACE_CODE:Number = "{".charCodeAt(0);
      
      protected static const CLOSE_BRACE_CODE:Number = "}".charCodeAt(0);
      
      public function SubstituterEnFlip()
      {
         super();
      }
      
      protected static function flipString(param1:String) : String
      {
         var _loc6_:String = null;
         var _loc2_:int = param1.length;
         var _loc3_:Array = [];
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         while(_loc5_ < _loc2_)
         {
            _loc6_ = param1.charAt(_loc5_);
            if(_loc4_ || _loc6_.charCodeAt(0) == OPEN_BRACE_CODE)
            {
               _loc3_.push(_loc6_);
               _loc4_ = _loc6_.charCodeAt(0) != CLOSE_BRACE_CODE;
            }
            else
            {
               _loc3_.push(flipChar(_loc6_));
            }
            _loc5_++;
         }
         return _loc3_.join("");
      }
      
      protected static function reverse(param1:String) : String
      {
         var _loc2_:String = "";
         var _loc3_:* = int(param1.length - 1);
         while(_loc3_ >= 0)
         {
            _loc2_ += param1.charAt(_loc3_);
            _loc3_--;
         }
         return _loc2_;
      }
      
      protected static function flipChar(param1:String) : String
      {
         if(flipMap.hasOwnProperty(param1))
         {
            return flipMap[param1];
         }
         return param1;
      }
      
      override public function replace(param1:String, param2:Object) : String
      {
         var _loc3_:String = null;
         param1 = flipString(param1);
         for(_loc3_ in param2)
         {
            param2[_loc3_] = flipString(param2[_loc3_]);
         }
         param1 = super.replace(param1,param2);
         return reverse(param1);
      }
   }
}

