package ZLocalization
{
   import ZLocalization.Substituters.SubstituterSimple;
   
   public class LocalizedString
   {
      
      public static const ORIGINAL:String = "original";
      
      protected static var PROPAGATED_ATTRIBUTES:Array = ["indefinite","definite","singular","plural","accusative"];
      
      protected var m_original:String;
      
      protected var m_variations:Object;
      
      protected var m_gender:String;
      
      public function LocalizedString(param1:String, param2:Object = null)
      {
         super();
         this.m_original = param1;
         this.m_variations = param2;
         this.m_gender = null;
      }
      
      public function set gender(param1:String) : void
      {
         this.m_gender = param1;
      }
      
      public function get gender() : String
      {
         return this.m_gender;
      }
      
      public function toString(param1:Object, param2:SubstituterSimple) : String
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc9_:Array = null;
         var _loc10_:Array = null;
         var _loc11_:LocalizationToken = null;
         var _loc12_:int = 0;
         var _loc13_:Array = null;
         var _loc14_:Array = null;
         var _loc15_:Array = null;
         var _loc16_:Array = null;
         var _loc17_:String = null;
         var _loc18_:Number = NaN;
         var _loc3_:Array = new Array();
         for(_loc4_ in this.m_variations)
         {
            _loc3_.push(_loc4_);
         }
         if(_loc3_.length == 0)
         {
            _loc3_.push(ORIGINAL);
         }
         _loc6_ = {};
         for(_loc17_ in param1)
         {
            if(param1[_loc17_] is LocalizationToken)
            {
               _loc11_ = param1[_loc17_] as LocalizationToken;
               _loc13_ = [];
               _loc14_ = PROPAGATED_ATTRIBUTES;
               _loc12_ = 0;
               _loc7_ = 0;
               while(_loc7_ < _loc3_.length)
               {
                  _loc8_ = this.getVariation(_loc3_[_loc7_]);
                  _loc9_ = _loc8_.match(new RegExp("{" + _loc17_ + "(?:,\\s*([a-z,\\s*]+))?}"));
                  if((Boolean(_loc9_)) && _loc9_.length == 2)
                  {
                     _loc12_++;
                     if(_loc9_[1] is String)
                     {
                        _loc10_ = _loc9_[1].split(",");
                        _loc18_ = 0;
                        while(_loc18_ < _loc10_.length)
                        {
                           _loc10_[_loc18_] = _loc10_[_loc18_].replace(/^\s+|\s+$/g,"");
                           _loc18_++;
                        }
                        _loc14_ = Utilities.arrayIntersect(_loc14_,_loc10_);
                        _loc13_.push(_loc10_);
                     }
                  }
                  _loc7_++;
               }
               if(_loc12_ > 0)
               {
                  if(_loc13_.length > 0)
                  {
                     _loc11_.addAttributes(_loc14_);
                     _loc15_ = _loc11_.filterIndexes(_loc13_);
                     _loc16_ = [];
                     _loc7_ = 0;
                     while(_loc7_ < _loc15_.length)
                     {
                        _loc16_.push(_loc3_[_loc15_[_loc7_]]);
                        _loc7_++;
                     }
                     _loc3_ = _loc16_;
                  }
                  _loc6_[_loc17_] = _loc11_.getString();
               }
            }
            else
            {
               _loc6_[_loc17_] = param1[_loc17_].toString();
            }
         }
         if(_loc3_.length > 1)
         {
            _loc5_ = this.getVariation(_loc3_[0]).replace(/{([^},]+),\s*[a-z0-9,\s*]+}/g,"{$1}");
         }
         else
         {
            if(_loc3_.length < 1)
            {
               throw new Error("No matches found.");
            }
            _loc5_ = this.getVariation(_loc3_[0]).replace(/{([^},]+),\s*[a-z0-9,\s*]+}/g,"{$1}");
         }
         return param2.replace(_loc5_,_loc6_);
      }
      
      public function getVariation(param1:String) : String
      {
         if(param1 == ORIGINAL)
         {
            return this.m_original;
         }
         if(Boolean(this.m_variations) && Boolean(this.m_variations[param1]))
         {
            return this.m_variations[param1];
         }
         return "false:" + param1;
      }
   }
}

