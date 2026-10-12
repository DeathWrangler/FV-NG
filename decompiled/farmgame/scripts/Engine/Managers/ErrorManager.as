package Engine.Managers
{
   import flash.events.ErrorEvent;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.system.Capabilities;
   import flash.utils.Timer;
   
   public class ErrorManager extends EventDispatcher
   {
      
      protected static var m_instance:ErrorManager;
      
      private static const REPORT_DELAY:int = 10000;
      
      public static const ERROR_UNKNOWN:int = 0;
      
      public static const ERROR_FAILED_TO_LOAD:int = 1;
      
      public static const ERROR_LOAD_TIMED_OUT:int = 2;
      
      public static const ERROR_LOAD_SECURITY_ERROR:int = 3;
      
      public static const ERROR_LOAD_HTTP_ERROR:int = 4;
      
      public static const ERROR_LOAD_IO_ERROR:int = 5;
      
      public static const ERROR_REMOTEOBJECT_FAULT:int = 6;
      
      protected static var m_errors:Array = new Array();
      
      protected static var m_timer:Timer = new Timer(REPORT_DELAY);
      
      public function ErrorManager()
      {
         super();
         m_timer.addEventListener(TimerEvent.TIMER,onReport,false,0,true);
         m_timer.start();
      }
      
      public static function getInstance() : ErrorManager
      {
         if(m_instance == null)
         {
            m_instance = new ErrorManager();
         }
         return m_instance;
      }
      
      public static function addError(param1:String, param2:int = 0, param3:Object = null) : void
      {
         m_errors.push({
            "message":param1,
            "type":param2,
            "version":Capabilities.version,
            "fields":param3
         });
         GlobalEngine.log("ErrorManager",param1 + " (Type: " + param2 + ")");
         getInstance().dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,param1));
      }
      
      public static function addInfo(param1:String, param2:int = 0, param3:Object = null) : void
      {
         var _loc4_:String = "INFO LOG: " + param1;
         ErrorManager.addError(_loc4_,param2,param3);
      }
      
      public static function getFormattedErrorMessage(param1:String, ... rest) : String
      {
         var _loc3_:String = null;
         if(rest)
         {
            for each(_loc3_ in rest)
            {
               param1 += "," + _loc3_;
            }
         }
         return param1;
      }
      
      private static function onReport(param1:TimerEvent) : void
      {
         if(m_errors.length)
         {
            m_errors = [];
         }
      }
   }
}

