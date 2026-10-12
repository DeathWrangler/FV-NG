package
{
   public class Config
   {
      
      public static var SN_APP_URL:String = "";
      
      public static var BASE_PATH:String = "";
      
      public static var SERVICES_GATEWAY_PATH:String = BASE_PATH + "flashservices/gateway.php";
      
      public static var ASSET_BASE_PATH:String = "";
      
      public static var RECORD_STATS_PATH:String = BASE_PATH + "record_stats.php";
      
      public static var ASSET_POLICY_FILE:String = "";
      
      public static var ASSET_PATHS:Array = new Array();
      
      public static var DEBUG_MODE:Boolean = false;
      
      public static var verboseLogging:Boolean = false;
      
      public static var VIEWPORT_CLEAR_COLOR:uint = 4282622275;
      
      public static var TRACE_SECTIONS:Object = null;
      
      public static var TRACE_DEFAULT_LEVEL:int = GlobalEngine.LEVEL_WARNING;
      
      public static var INVERT_TRACE:Boolean = false;
      
      public function Config()
      {
         super();
      }
   }
}

