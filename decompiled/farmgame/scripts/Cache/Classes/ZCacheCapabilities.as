package Cache.Classes
{
   import flash.external.ExternalInterface;
   import flash.system.Capabilities;
   
   public class ZCacheCapabilities
   {
      
      private static const REGEX_FIREFOX:RegExp = /Firefox[\/\s](\d+\.\d+)/g;
      
      private static const REGEX_IE:RegExp = /MSIE (\d+\.\d+);/g;
      
      private static const REGEX_OPERA:RegExp = /Opera[\/\s](\d+\.\d+)/g;
      
      private static const REGEX_VERSION:RegExp = /^(\w*) (\d*),(\d*),(\d*),(\d*)$/;
      
      private static const GET_NAVIGATOR_INFO:String = (<![CDATA[
			 function() { 
				return { 
					appName: navigator.appName, 
					appVersion: navigator.appVersion,
					userAgent: navigator.userAgent 
				};
			 }
			]]>).toString();
      
      public function ZCacheCapabilities()
      {
         super();
      }
      
      private static function getBrowserInfo() : Object
      {
         var info:Object = null;
         try
         {
            if(ExternalInterface.available)
            {
               info = ExternalInterface.call(GET_NAVIGATOR_INFO);
            }
         }
         catch(e:Error)
         {
            GlobalEngine.error("ZCache","Error getting browser info: " + e);
         }
         return info;
      }
      
      private static function isFirefox(param1:Object) : Boolean
      {
         var _loc2_:Boolean = false;
         if(param1.userAgent)
         {
            _loc2_ = REGEX_FIREFOX.test(param1.userAgent);
            REGEX_FIREFOX.lastIndex = 0;
         }
         return _loc2_;
      }
      
      public static function isZCacheCompatible() : Boolean
      {
         var _loc5_:String = null;
         var _loc7_:String = null;
         var _loc8_:Object = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc1_:Boolean = true;
         var _loc2_:String = Capabilities.os;
         var _loc3_:String = Capabilities.playerType;
         var _loc4_:Boolean = _loc2_.indexOf("Mac OS") == 0;
         if(_loc4_)
         {
            _loc5_ = _loc2_.substring("Mac OS".length);
         }
         var _loc6_:Object = null;
         if(_loc3_ == "ActiveX" || _loc3_ == "PlugIn")
         {
            _loc6_ = getBrowserInfo();
            if(_loc6_)
            {
               if(_loc4_ && isFirefox(_loc6_))
               {
                  _loc7_ = Capabilities.version;
                  _loc8_ = REGEX_VERSION.exec(_loc7_);
                  REGEX_VERSION.lastIndex = 0;
                  _loc9_ = int(_loc8_[2]);
                  _loc10_ = int(_loc8_[3]);
                  _loc11_ = int(_loc8_[4]);
                  _loc12_ = int(_loc8_[5]);
                  if(_loc9_ < 11)
                  {
                     _loc1_ = false;
                  }
                  else if(_loc9_ == 11)
                  {
                     if(_loc10_ < 2)
                     {
                        _loc1_ = false;
                     }
                     else if(_loc10_ == 2)
                     {
                        if(_loc11_ < 202)
                        {
                           _loc1_ = false;
                        }
                        else if(_loc11_ == 202)
                        {
                           if(_loc12_ < 235)
                           {
                              _loc1_ = false;
                           }
                        }
                     }
                  }
               }
            }
         }
         return _loc1_;
      }
   }
}

