package ZLocalization
{
   public class LocalizerXML extends Localizer
   {
      
      public function LocalizerXML(param1:XML)
      {
         var _loc3_:XML = null;
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:XML = null;
         super(param1);
         this.m_raw = {};
         this.m_cached = {};
         var _loc2_:int = 0;
         while(_loc2_ < param1.pkg.length())
         {
            _loc3_ = param1.pkg[_loc2_];
            _loc4_ = {};
            _loc5_ = 0;
            while(_loc5_ < _loc3_.string.length())
            {
               _loc7_ = _loc3_.string[_loc5_];
               _loc4_[_loc7_.@key.toString()] = _loc7_;
               _loc5_++;
            }
            _loc6_ = _loc3_.@name.toString();
            this.m_raw[_loc6_] = _loc4_;
            this.m_cached[_loc6_] = {};
            _loc2_++;
         }
         this.m_locale = param1.@locale.toString();
         this.setSubstituter();
      }
      
      protected function parseStringNode(param1:XML) : LocalizedString
      {
         var _loc6_:XML = null;
         var _loc2_:String = param1.original.toString();
         var _loc3_:Object = {};
         var _loc4_:int = 0;
         while(_loc4_ < param1.variation.length())
         {
            _loc6_ = param1.variation[_loc4_];
            _loc3_[_loc6_.@index.toString()] = _loc6_.toString();
            _loc4_++;
         }
         var _loc5_:LocalizedString = new LocalizedString(_loc2_,_loc3_);
         if(param1.@gender.toString() != "")
         {
            _loc5_.gender = param1.@gender.toString();
         }
         return _loc5_;
      }
      
      override public function getString(param1:String, param2:String) : LocalizedString
      {
         if(!this.m_raw.hasOwnProperty(param1))
         {
            return null;
         }
         if(!this.m_cached[param1].hasOwnProperty(param2))
         {
            if(!this.m_raw[param1].hasOwnProperty(param2))
            {
               return null;
            }
            this.m_cached[param1][param2] = this.parseStringNode(this.m_raw[param1][param2]);
         }
         return this.m_cached[param1][param2];
      }
   }
}

