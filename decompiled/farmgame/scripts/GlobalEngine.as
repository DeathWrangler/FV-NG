package
{
   import Engine.ArrayUtil;
   import Engine.Classes.SocialNetwork;
   import Engine.Classes.Viewport;
   import Engine.Classes.ZEngineOptions;
   import Engine.Init.InitializationManager;
   import Engine.Managers.LocalizationManager;
   import Engine.Managers.TransactionManager;
   import Engine.Managers.ZaspManager;
   import com.adobe.utils.StringUtil;
   import flash.debugger.enterDebugger;
   import flash.display.Stage;
   import flash.media.SoundMixer;
   import flash.media.SoundTransform;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class GlobalEngine
   {
      
      public static var viewport:Viewport;
      
      public static var socialNetwork:SocialNetwork;
      
      public static var initializationManager:InitializationManager;
      
      public static var zaspManager:ZaspManager;
      
      protected static var m_serverTime:Number;
      
      protected static var m_currentTime:int;
      
      public static var stage:Stage = null;
      
      public static var onFeedCloseCallback:Function = null;
      
      public static var feedCallbackTimer:Timer = null;
      
      public static var engineOptions:ZEngineOptions = null;
      
      protected static var m_internalServerTime:Number = 0;
      
      protected static var m_isDST:Boolean = false;
      
      protected static var m_syncTime:Number = 0;
      
      protected static var m_flashVars:Object = {};
      
      protected static var m_startingWaitTime:Number = 0;
      
      protected static var m_zyParams:Object = null;
      
      private static var stc_stackCache:Object = {};
      
      public static const LEVEL_ERROR:int = 1;
      
      public static const LEVEL_WARNING:int = 2;
      
      public static const LEVEL_INFO:int = 3;
      
      public static const LEVEL_ALL:int = LEVEL_INFO;
      
      public static const LEVEL_NONE:int = -1;
      
      public function GlobalEngine()
      {
         super();
      }
      
      public static function updateTimers() : void
      {
         m_serverTime = getTimer();
         m_currentTime = getTimer();
      }
      
      public static function setInternalServerTime(param1:Number) : void
      {
         var _loc2_:Boolean = isServerTimeValid();
         m_internalServerTime = param1;
         m_syncTime = getTimer();
         if(!_loc2_)
         {
            updateTimers();
         }
      }
      
      public static function get isDST() : Boolean
      {
         return m_isDST;
      }
      
      public static function setIsDSTFlag(param1:Boolean) : void
      {
         m_isDST = param1;
      }
      
      public static function get serverTime() : Number
      {
         return m_serverTime;
      }
      
      public static function get currentTime() : int
      {
         return m_currentTime;
      }
      
      public static function get startingWaitTime() : Number
      {
         return m_startingWaitTime;
      }
      
      public static function setStartingWaitTime() : void
      {
         m_startingWaitTime = getTimer() / 1000;
      }
      
      public static function isServerTimeValid() : Boolean
      {
         return m_internalServerTime != 0;
      }
      
      public static function quickLocalize(param1:String, param2:String = null, param3:Array = null) : String
      {
         var _loc4_:Array = null;
         if(param2 == null)
         {
            _loc4_ = param1.split(":");
            if(_loc4_.length == 2)
            {
               param1 = _loc4_[0];
               param2 = _loc4_[1];
            }
         }
         return LocalizationManager.quickLocalize(param1,param2,param3);
      }
      
      public static function getTimer() : Number
      {
         return getTimer() - m_syncTime + m_internalServerTime * 1000;
      }
      
      public static function getCurrentTime() : Number
      {
         return getTimer() + m_syncTime + m_internalServerTime * 1000;
      }
      
      public static function get zyParams() : Object
      {
         var _loc1_:Object = null;
         var _loc2_:String = null;
         if(GlobalEngine.m_zyParams == null)
         {
            _loc1_ = {};
            for(_loc2_ in m_flashVars)
            {
               if(_loc2_.substr(0,2) == "zy")
               {
                  _loc1_[_loc2_] = m_flashVars[_loc2_];
               }
            }
            GlobalEngine.m_zyParams = _loc1_;
         }
         return GlobalEngine.m_zyParams;
      }
      
      public static function set zyParams(param1:Object) : void
      {
         GlobalEngine.m_zyParams = param1;
         TransactionManager.additionalSignedParams = param1;
      }
      
      public static function getFlashVars() : Object
      {
         return m_flashVars;
      }
      
      public static function parseFlashVars(param1:Object) : void
      {
         m_flashVars = param1;
         if(param1.noSound == 1)
         {
            SoundMixer.soundTransform = new SoundTransform(0);
         }
         if(param1.app_url != null)
         {
            Config.BASE_PATH = param1.app_url;
            Config.SERVICES_GATEWAY_PATH = param1.app_url + "flashservices/gateway.php";
            Config.RECORD_STATS_PATH = param1.app_url + "record_stats.php";
         }
         if(param1.sn_app_url != null)
         {
            Config.SN_APP_URL = param1.sn_app_url;
         }
         if(param1.additional_asset_urls != null || param1.asset_url != null)
         {
            setAssetUrls(param1.asset_url,param1.additional_asset_urls);
         }
         if(param1.serverTime != null)
         {
            GlobalEngine.setInternalServerTime(param1.serverTime);
         }
         if(param1.debugMode)
         {
            Config.DEBUG_MODE = true;
         }
      }
      
      public static function getFlashVar(param1:String) : Object
      {
         return m_flashVars[param1];
      }
      
      public static function isFlashVarSetAndTrue(param1:String) : Boolean
      {
         return getFlashVar(param1) as String == "true";
      }
      
      public static function error(param1:String, param2:String) : void
      {
         logByLevel(LEVEL_ERROR,param1,param2);
      }
      
      public static function warning(param1:String, param2:String) : void
      {
         logByLevel(LEVEL_WARNING,param1,param2);
      }
      
      public static function log(param1:String, param2:String) : void
      {
         logByLevel(LEVEL_INFO,param1,param2);
      }
      
      public static function info(param1:String, param2:String) : void
      {
         logByLevel(LEVEL_INFO,param1,param2);
      }
      
      public static function msg(param1:String = null, ... rest) : void
      {
         logByLevel(LEVEL_INFO,param1,ArrayUtil.flatten(rest).join(" "));
      }
      
      private static function logByLevel(param1:int, param2:String, param3:String) : void
      {
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         if(Config.verboseLogging)
         {
            if(null == param2 || param1 <= LEVEL_WARNING)
            {
               _loc4_ = computeSectionFromStack();
            }
            if(null == param2)
            {
               param2 = _loc4_.sectionName;
            }
            _loc5_ = Config.TRACE_DEFAULT_LEVEL;
            if(null != Config.TRACE_SECTIONS && param1 >= LEVEL_INFO)
            {
               if(Config.TRACE_SECTIONS.hasOwnProperty(param2))
               {
                  _loc5_ = int(Config.TRACE_SECTIONS[param2]);
               }
            }
            if(param1 <= _loc5_)
            {
               _loc6_ = "" + dateToShortTime(new Date()) + " " + param2 + ": ";
               if(LEVEL_ERROR == param1)
               {
                  _loc6_ += "**ERROR** " + param3 + "\r\n" + _loc4_.stackTrace;
               }
               else if(LEVEL_WARNING == param1)
               {
                  _loc6_ += "**WARNING** " + param3;
               }
               else
               {
                  _loc6_ += param3;
               }
            }
         }
      }
      
      private static function computeSectionFromStack() : Object
      {
         var _loc5_:Object = null;
         var _loc6_:Array = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:Array = null;
         var _loc10_:int = 0;
         var _loc11_:RegExp = null;
         var _loc12_:Object = null;
         var _loc1_:String = null;
         var _loc2_:Object = {
            "stackTrace":"",
            "rawLine":"",
            "packageName":"",
            "className":"",
            "methodName":"<unknown>",
            "fileName":"",
            "lineNumber":0
         };
         var _loc3_:Error = new Error();
         var _loc4_:int = 5;
         _loc1_ = _loc3_.getStackTrace();
         if(_loc1_ != null && _loc1_ != "")
         {
            _loc5_ = stc_stackCache[_loc1_];
            if(null == _loc5_)
            {
               _loc6_ = _loc1_.split("\n");
               if(_loc6_.length >= _loc4_)
               {
                  _loc2_.stackTrace = _loc6_.slice(_loc4_ - 1).join("\r\n");
                  _loc7_ = String(_loc6_[_loc4_ - 1]);
                  _loc2_.rawLine = StringUtil.ltrim(_loc7_);
                  _loc8_ = _loc7_.substring(4,_loc7_.indexOf("()",4));
                  _loc10_ = _loc8_.indexOf("::");
                  if(-1 != _loc10_)
                  {
                     _loc2_.packageName = _loc8_.substr(0,_loc10_);
                     _loc8_ = _loc8_.substr(_loc10_ + 2);
                  }
                  _loc11_ = /\[(.*):(\d+)\]/i;
                  _loc12_ = _loc11_.exec(_loc7_);
                  if(_loc12_)
                  {
                     _loc2_.fileName = _loc12_[1];
                     _loc2_.lineNumber = _loc12_[2];
                  }
                  if(-1 != _loc8_.indexOf("$/"))
                  {
                     _loc9_ = _loc8_.split("$/",2);
                     _loc2_.className = _loc9_[0];
                     _loc2_.methodName = _loc9_[1];
                  }
                  else
                  {
                     _loc10_ = _loc8_.indexOf("/");
                     if(-1 != _loc10_)
                     {
                        _loc9_ = _loc8_.split("/",2);
                        _loc2_.className = _loc9_[0];
                        _loc2_.methodName = _loc9_[1];
                     }
                     else
                     {
                        _loc2_.className = _loc8_;
                        _loc2_.methodName = "ctor";
                     }
                  }
               }
               if(_loc2_.className == "global")
               {
                  _loc2_.sectionName = _loc2_.methodName;
               }
               else
               {
                  _loc2_.sectionName = _loc2_.className;
               }
               stc_stackCache[_loc1_] = _loc2_;
            }
            else
            {
               _loc2_ = _loc5_;
            }
         }
         return _loc2_;
      }
      
      public static function dateToShortTime(param1:Date) : String
      {
         var _loc2_:Number = param1.getHours();
         var _loc3_:Number = param1.getMinutes();
         var _loc4_:Number = param1.getSeconds();
         var _loc5_:String = new String();
         if(_loc2_ < 10)
         {
            _loc5_ += "0";
         }
         _loc5_ += _loc2_;
         _loc5_ = _loc5_ + ":";
         if(_loc3_ < 10)
         {
            _loc5_ += "0";
         }
         _loc5_ += _loc3_;
         _loc5_ = _loc5_ + ":";
         if(_loc4_ < 10)
         {
            _loc5_ += "0";
         }
         return _loc5_ + _loc4_;
      }
      
      public static function addTraceLevel(param1:String, param2:int) : void
      {
         if(null == Config.TRACE_SECTIONS)
         {
            Config.TRACE_SECTIONS = {};
         }
         Config.TRACE_SECTIONS[param1] = param2;
      }
      
      public static function getAssetUrl(param1:String) : String
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc2_:String = "";
         if(Boolean(Config.ASSET_PATHS) && Config.ASSET_PATHS.length > 0)
         {
            _loc3_ = 0;
            if(m_flashVars["IsInDomainShardingV2"] > 0)
            {
               _loc5_ = param1.lastIndexOf(".");
               if(_loc5_ < 0)
               {
                  _loc5_ = param1.length;
               }
               _loc6_ = param1.substr(_loc5_ - 2,2);
               _loc3_ = parseInt(_loc6_,16);
               if(isNaN(_loc3_))
               {
                  _loc3_ = 0;
               }
            }
            else
            {
               _loc3_ = param1.length;
            }
            _loc4_ = _loc3_ % Config.ASSET_PATHS.length;
            _loc2_ = Config.ASSET_PATHS[_loc4_] + param1;
         }
         else
         {
            _loc2_ = param1;
            GlobalEngine.log("Config","WARNING: no asset path specified!");
         }
         return _loc2_;
      }
      
      public static function setAssetUrls(param1:String, param2:String) : void
      {
         if(Boolean(param2) && param2.length > 1)
         {
            Config.ASSET_PATHS = param2.split(",");
         }
         if(Boolean(param1) && param1.length > 1)
         {
            Config.ASSET_PATHS.push(param1);
         }
      }
      
      public static function assert(param1:Boolean, param2:String) : void
      {
         if(!param1)
         {
            error("Assert","ASSERTION FAILED - " + param2);
            enterDebugger();
         }
      }
   }
}

