package ZLocalization.Substituters
{
   public class SubstituterContractions extends SubstituterSimple
   {
      
      protected static var contractionMap:Object = {};
      
      public function SubstituterContractions()
      {
         super();
      }
      
      override public function replace(param1:String, param2:Object) : String
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:RegExp = null;
         var _loc6_:Array = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:Object = null;
         var _loc10_:Object = null;
         var _loc11_:String = null;
         var _loc12_:Object = null;
         var _loc13_:String = null;
         var _loc14_:String = null;
         for(_loc3_ in param2)
         {
            _loc4_ = param2[_loc3_];
            _loc5_ = this.getContractionPattern();
            _loc6_ = _loc4_.match(_loc5_);
            if(_loc6_)
            {
               _loc7_ = _loc6_[1];
               _loc8_ = _loc4_.replace(new RegExp("^" + _loc7_),"");
               _loc7_ = _loc7_.toLowerCase();
               _loc7_ = _loc7_.replace(/\s+$/,"");
               _loc9_ = this.getContractionMap();
               _loc10_ = _loc9_[_loc7_];
               for(_loc11_ in _loc10_)
               {
                  _loc12_ = _loc9_[_loc7_][_loc11_];
                  _loc13_ = this.getContraction(_loc12_,_loc8_);
                  if(_loc13_.substr(-1,1) == "\'")
                  {
                     _loc14_ = " " + _loc13_ + _loc8_;
                  }
                  else
                  {
                     _loc14_ = " " + _loc13_ + " " + _loc8_;
                  }
                  param1 = param1.replace(new RegExp("^" + _loc11_ + " {" + _loc3_ + "}"),_loc14_);
                  param1 = param1.replace(new RegExp(" " + _loc11_ + " {" + _loc3_ + "}","g"),_loc14_);
               }
            }
            param1 = param1.replace(new RegExp("{" + _loc3_ + "}","g"),_loc4_);
         }
         return param1;
      }
      
      protected function getContractionMap() : Object
      {
         return SubstituterContractions.contractionMap;
      }
      
      protected function getContractionPattern() : RegExp
      {
         var _loc3_:String = null;
         var _loc4_:RegExp = null;
         var _loc1_:Object = this.getContractionMap();
         var _loc2_:String = "";
         for(_loc3_ in _loc1_)
         {
            if(_loc3_.charAt(_loc3_.length - 1) != "\'")
            {
               _loc2_ += _loc3_ + " |";
            }
            else
            {
               _loc2_ += _loc3_ + "|";
            }
         }
         _loc2_ = _loc2_.substr(0,_loc2_.length - 1);
         return new RegExp("^(" + _loc2_ + ")","i");
      }
      
      protected function getContraction(param1:Object, param2:String) : String
      {
         if(typeof param1 == "string")
         {
            return String(param1);
         }
         return "";
      }
   }
}

