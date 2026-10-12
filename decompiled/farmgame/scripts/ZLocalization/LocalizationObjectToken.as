package ZLocalization
{
   public class LocalizationObjectToken extends LocalizationToken
   {
      
      public static const GENDERS:Object = {
         "masc":0,
         "fem":1,
         "neuter":2
      };
      
      protected static var VALID_ATTRIUBTES:Array = ["plural","singular","count","indefinite","definite","masc","fem","common","neuter"];
      
      protected static var LOOKUP_ATTRIBUTES:Array = [["indefinite","definite"],["singular","plural"],["accusative"]];
      
      private const NO_COUNT:int = -1;
      
      private const DEFAULT_GENDER:String = "masc";
      
      private const SINGULAR:String = "singular";
      
      private const PLURAL:String = "plural";
      
      private const ATTRIBUTE_DELIM:String = ",";
      
      protected var m_locString:LocalizedString;
      
      public function LocalizationObjectToken(param1:LocalizedString, param2:String = "", param3:int = -1)
      {
         super();
         this.m_locString = param1;
         if(param2 != "")
         {
            m_attributes = m_attributes.concat(param2.split(this.ATTRIBUTE_DELIM));
         }
         if(param3 != this.NO_COUNT)
         {
            m_attributes.push(param3 == 1 ? this.SINGULAR : this.PLURAL);
         }
         if(Boolean(this.m_locString) && this.m_locString.gender != null)
         {
            m_attributes.push(this.m_locString.gender);
         }
      }
      
      protected static function validateAttributes(param1:Array) : void
      {
         var _loc2_:Array = Utilities.arrayDiff(param1,VALID_ATTRIUBTES);
         if(_loc2_.length != 0)
         {
            throw new Error("Invalid token attributes: " + _loc2_.join(","));
         }
      }
      
      override public function getString() : String
      {
         var _loc4_:Array = null;
         var _loc1_:Array = new Array();
         var _loc2_:int = 0;
         while(_loc2_ < LOOKUP_ATTRIBUTES.length)
         {
            _loc4_ = Utilities.arrayIntersect(m_attributes,LOOKUP_ATTRIBUTES[_loc2_]);
            if(_loc4_.length > 0)
            {
               if(_loc4_.length == 1)
               {
                  _loc1_.push(_loc4_[0]);
               }
               else
               {
                  _loc1_.push(_loc4_[0]);
               }
            }
            _loc2_++;
         }
         var _loc3_:String = this.m_locString.getVariation(_loc1_.join("_"));
         if(_loc3_ == null || _loc3_.indexOf("false") == 0)
         {
            _loc3_ = this.m_locString.getVariation(LocalizedString.ORIGINAL);
         }
         return _loc3_;
      }
   }
}

