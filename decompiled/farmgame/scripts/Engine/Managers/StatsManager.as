package Engine.Managers
{
   import cipro.Profiler.RuntimeProfiler;
   import com.adobe.crypto.MD5;
   import com.adobe.serialization.json.JSON;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.utils.Timer;
   
   public class StatsManager
   {
      
      public static const ONE_LINE_FEED:int = 1;
      
      public static const SHORT_FEED:int = 2;
      
      public static const APP_TO_USER_NOTIF:int = 3;
      
      public static const USER_TO_USER_NOTIF:int = 4;
      
      public static const STATUS:int = 5;
      
      public static const APP_EMAIL:int = 6;
      
      public static const REQUEST:int = 7;
      
      private static const REPORT_DELAY:int = 10000;
      
      private static const IDLE_TIMER_ENABLED:Boolean = true;
      
      private static const HEARTBEAT_STATS_ENABLED:Boolean = false;
      
      public static var m_stats:Array = new Array();
      
      public static var m_timer:Timer = null;
      
      protected static var m_idle:Boolean = false;
      
      public static const DEFERRED_TRACK_FUNCTION:String = "deferredTrack";
      
      public static const FEATURE_SAMPLE_RATE:int = 100;
      
      public function StatsManager()
      {
         super();
      }
      
      protected static function addStatDataToBatch(param1:Array, param2:String, ... rest) : void
      {
         GlobalEngine.msg("Stats",rest);
         RuntimeProfiler.log_stats(param2,rest);
         param1.push({
            "statfunction":param2,
            "data":rest
         });
         scheduleBatch();
      }
      
      protected static function addBatchStatDataToSchedule(param1:String, param2:Array, ... rest) : void
      {
         RuntimeProfiler.log_stats(param1,rest);
         m_stats.push({
            "statfunction":param1,
            "batchedfunctions":param2,
            "data":rest
         });
         scheduleBatch();
      }
      
      protected static function scheduleBatch() : void
      {
         if(m_timer == null)
         {
            m_timer = new Timer(REPORT_DELAY);
            m_timer.addEventListener(TimerEvent.TIMER,onTimer,false,0,true);
            m_timer.start();
         }
      }
      
      public static function deferredTrack(param1:Array, param2:String, param3:int, param4:int, param5:int) : void
      {
         addBatchStatDataToSchedule(DEFERRED_TRACK_FUNCTION,param1,param2,param3,param4,param5);
      }
      
      public static function count_batch(param1:Array, param2:String, param3:String = "", param4:String = "", param5:String = "", param6:String = "", param7:String = "", param8:int = 1) : void
      {
         GlobalEngine.msg("StatsManager.count",param2,param3,param4,param5,param6,param7,param8);
         addStatDataToBatch(param1,"count",param2,param3,param4,param5,param6,param7,param8);
      }
      
      public static function count_dtl_batch(param1:Array, param2:String, param3:String, param4:String, param5:String, param6:String, param7:String, param8:String, param9:String, param10:Number, param11:Number, param12:Number, param13:Number, param14:Number, param15:Number, param16:Number, param17:Number) : void
      {
         addStatDataToBatch(param1,"count_dtl",param2,param3,param4,param5,param6,param7,param8,param9,param10,param11,param12,param13,param14,param15,param16,param17);
      }
      
      public static function count(param1:String, param2:String = "", param3:String = "", param4:String = "", param5:String = "", param6:String = "", param7:int = 1) : void
      {
         count_batch(m_stats,param1,param2,param3,param4,param5,param6,param7);
         scheduleBatch();
      }
      
      public static function trackMessage(param1:int, param2:String, param3:int, param4:String = "", param5:String = "", param6:String = "", param7:Boolean = true) : void
      {
         addStatDataToBatch(m_stats,"trackMessage",param1,param2,param3,param4,param5,param6,param7);
         scheduleBatch();
      }
      
      public static function sample(param1:int, param2:String, param3:String = "", param4:String = "", param5:String = "", param6:String = "", param7:String = "", param8:int = 1) : void
      {
         addStatDataToBatch(m_stats,"sample",param1,param2,param3,param4,param5,param6,param7,param8);
         scheduleBatch();
      }
      
      public static function perf(param1:String = "", param2:String = "", param3:String = "", param4:String = "", param5:String = "", param6:String = "", param7:String = "") : void
      {
         addStatDataToBatch(m_stats,"perf",param1,param2,param3,param4,param5,param6,param7);
         scheduleBatch();
      }
      
      public static function social(param1:String, param2:String, param3:String = "", param4:String = "", param5:String = "", param6:String = "", param7:int = 0, param8:String = "") : void
      {
         addStatDataToBatch(m_stats,"social",param1,param2,param3,param4,param5,param6,param7,param8);
         scheduleBatch();
      }
      
      public static function startExperiment(param1:String, param2:String, param3:int) : int
      {
         var _loc4_:int = 0;
         var _loc5_:int = 7;
         var _loc6_:String = MD5.hash(param2 + param1);
         var _loc7_:int = parseInt("0x" + _loc6_.substr(-_loc5_));
         _loc4_ = _loc7_ % (param3 + 1);
         addStatDataToBatch(m_stats,"setUserExperimentVariant",param1,param2,_loc4_);
         scheduleBatch();
         return _loc4_;
      }
      
      public static function experimentGoal(param1:String, param2:String, param3:int = 0) : void
      {
         addStatDataToBatch(m_stats,"experimentGoal",param1,param2,param3);
         scheduleBatch();
      }
      
      public static function notIdle() : void
      {
         m_idle = false;
      }
      
      public static function sendStats(param1:Boolean = false) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:URLRequest = null;
         var _loc7_:URLLoader = null;
         if(m_stats.length)
         {
            _loc2_ = new Object();
            _loc2_.signedParams = TransactionManager.additionalSignedParams;
            _loc2_.stats = m_stats;
            _loc3_ = com.adobe.serialization.json.JSON.encode(_loc2_);
            _loc4_ = "";
            if(GlobalEngine.zyParams)
            {
               if(GlobalEngine.zyParams["zySig"])
               {
                  _loc4_ = GlobalEngine.zyParams["zySig"];
               }
            }
            _loc5_ = Config.RECORD_STATS_PATH;
            if(_loc4_ != "")
            {
               _loc5_ += "?zySig=" + _loc4_;
            }
            _loc6_ = new URLRequest(_loc5_);
            _loc6_.method = URLRequestMethod.POST;
            _loc6_.contentType = "application/json";
            _loc6_.data = _loc3_;
            _loc7_ = new URLLoader();
            _loc7_.dataFormat = URLLoaderDataFormat.BINARY;
            addEventListeners(_loc7_);
            _loc7_.load(_loc6_);
            m_stats = [];
         }
      }
      
      private static function addEventListeners(param1:URLLoader) : void
      {
         param1.addEventListener(Event.COMPLETE,onSendStatsComplete);
         param1.addEventListener(IOErrorEvent.IO_ERROR,onSendStatsError);
         param1.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onSendStatsError);
      }
      
      private static function removeEventListeners(param1:URLLoader) : void
      {
         param1.removeEventListener(Event.COMPLETE,onSendStatsComplete);
         param1.removeEventListener(IOErrorEvent.IO_ERROR,onSendStatsError);
         param1.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onSendStatsError);
      }
      
      private static function onSendStatsComplete(param1:Event) : void
      {
         removeEventListeners(param1.target as URLLoader);
      }
      
      private static function onSendStatsError(param1:ErrorEvent) : void
      {
         GlobalEngine.error("Stats","Error sending stats: " + param1.text);
         count("errors","flash","stats_send_fail",param1.type);
         removeEventListeners(param1.target as URLLoader);
      }
      
      private static function onTimer(param1:TimerEvent) : void
      {
         if(HEARTBEAT_STATS_ENABLED)
         {
            if(m_idle && IDLE_TIMER_ENABLED)
            {
               count("timer","idle");
            }
            else
            {
               count("timer","active");
            }
         }
         sendStats();
         m_idle = true;
      }
      
      public static function milestone(param1:String, param2:Number = 0) : void
      {
         addStatDataToBatch(m_stats,"milestone",param1,param2);
         scheduleBatch();
      }
   }
}

