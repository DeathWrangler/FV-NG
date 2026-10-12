package ZLocalization.Substituters
{
   public class SubstituterEnZy extends SubstituterSimple
   {
      
      protected static var greekMap:Object = {
         "a":"α",
         "b":"β",
         "c":"ψ",
         "d":"δ",
         "e":"ε",
         "f":"φ",
         "g":"γ",
         "h":"η",
         "i":"ι",
         "j":"ξ",
         "k":"κ",
         "l":"λ",
         "m":"μ",
         "n":"ν",
         "o":"ο",
         "p":"π",
         "q":";",
         "r":"ρ",
         "s":"σ",
         "t":"τ",
         "u":"θ",
         "v":"ω",
         "w":"ς",
         "x":"χ",
         "y":"υ",
         "z":"ζ",
         "A":"Α",
         "B":"Β",
         "C":"Ψ",
         "D":"Δ",
         "E":"Ε",
         "F":"Φ",
         "G":"Γ",
         "H":"Η",
         "I":"Ι",
         "J":"Ξ",
         "K":"Κ",
         "L":"Λ",
         "M":"Μ",
         "N":"Ν",
         "O":"Ο",
         "P":"Π",
         "Q":";",
         "R":"Ρ",
         "S":"Σ",
         "T":"Τ",
         "U":"Θ",
         "V":"Ω",
         "W":"Σ",
         "X":"Χ",
         "Y":"Υ",
         "Z":"Ζ"
      };
      
      public function SubstituterEnZy()
      {
         super();
      }
      
      protected static function convertString(param1:String) : String
      {
         var _loc6_:String = null;
         var _loc2_:int = param1.length;
         var _loc3_:Array = [];
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         while(_loc5_ < _loc2_)
         {
            _loc6_ = param1.charAt(_loc5_);
            if(_loc4_ || _loc6_ == "{")
            {
               _loc3_.push(_loc6_);
               _loc4_ = _loc6_ != "}";
            }
            else
            {
               _loc3_.push(convertChar(_loc6_));
            }
            _loc5_++;
         }
         return _loc3_.join("");
      }
      
      protected static function convertChar(param1:String) : String
      {
         if(greekMap.hasOwnProperty(param1))
         {
            return greekMap[param1];
         }
         return param1;
      }
      
      override public function replace(param1:String, param2:Object) : String
      {
         var _loc3_:String = null;
         param1 = convertString(param1);
         for(_loc3_ in param2)
         {
            param2[_loc3_] = convertString(param2[_loc3_]);
         }
         super.replace(param1,param2);
         return param1;
      }
   }
}

