package ZLocalization
{
   public class LocalizerSWF extends Localizer
   {
      
      private const ORIGINAL_KEY:String = "original";
      
      public function LocalizerSWF(param1:Object)
      {
         super(param1);
         this.m_locale = param1.info.locale;
         this.m_cached = param1.text;
         this.setSubstituter();
      }
      
      private static function hashStringAdd(param1:String) : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = param1.length;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ += param1.charCodeAt(_loc4_);
            _loc4_++;
         }
         return _loc2_;
      }
      
      private function getStringFromBucket(param1:String, param2:int, param3:String) : LocalizedString
      {
         var _loc5_:Object = null;
         var _loc6_:String = null;
         var _loc7_:Object = null;
         var _loc8_:LocalizedString = null;
         var _loc4_:LocalizedString = null;
         if(Boolean(this.m_cached[param1].hasOwnProperty(param2)) && Boolean(this.m_cached[param1][param2].hasOwnProperty(param3)))
         {
            _loc5_ = this.m_cached[param1][param2][param3];
            if(_loc5_ is LocalizedString)
            {
               _loc4_ = _loc5_ as LocalizedString;
            }
            else
            {
               _loc6_ = _loc5_["original"];
               _loc7_ = _loc5_.hasOwnProperty("variations") ? _loc5_["variations"] : null;
               _loc8_ = new LocalizedString(_loc6_,_loc7_);
               if(_loc5_.hasOwnProperty("gender"))
               {
                  _loc8_.gender = _loc5_["gender"];
               }
               this.m_cached[param1][param2][param3] = _loc8_;
               _loc4_ = _loc8_;
            }
         }
         return _loc4_;
      }
      
      override public function getString(param1:String, param2:String) : LocalizedString
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:LocalizedString = null;
         if(this.m_cached.hasOwnProperty(param1))
         {
            _loc4_ = int(this.m_cached[param1]["length"]);
            if(_loc4_ <= 1)
            {
               _loc5_ = 0;
               _loc3_ = this.getStringFromBucket(param1,_loc5_,param2);
            }
            else if(_loc4_ < 4)
            {
               _loc5_ = 0;
               while(_loc5_ < _loc4_)
               {
                  _loc3_ = this.getStringFromBucket(param1,_loc5_,param2);
                  if(_loc3_)
                  {
                     break;
                  }
                  _loc5_++;
               }
            }
            else
            {
               _loc6_ = LocalizerSWF.hashStringAdd(param2);
               _loc5_ = _loc6_ & _loc4_ - 1;
               _loc3_ = this.getStringFromBucket(param1,_loc5_,param2);
            }
         }
         return _loc3_;
      }
      
      override public function injectString(param1:String, param2:String, param3:String) : void
      {
         if(!this.m_cached.hasOwnProperty(param1))
         {
            this.m_cached[param1] = {};
         }
         var _loc4_:int = int(this.m_cached[param1]["length"]);
         if(_loc4_ > 0)
         {
            _loc4_--;
         }
         else
         {
            this.m_cached[param1][_loc4_] = {};
         }
         this.m_cached[param1][_loc4_][param2] = {};
         this.m_cached[param1][_loc4_][param2][this.ORIGINAL_KEY] = param3;
      }
   }
}

