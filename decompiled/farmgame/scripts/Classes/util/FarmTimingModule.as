package Classes.util
{
   import Engine.Managers.StatsManager;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class FarmTimingModule
   {
      
      private static const TEMPORARY_RUNTIME_KEY_STATS:String = "TEMPRT_OPS_JSON_OPT";
      
      private static const STATS_COUNTER:String = "FarmTimingModule";
      
      private var startTimes:Dictionary;
      
      private var enableLogs:Boolean;
      
      public function FarmTimingModule()
      {
         super();
         this.startTimes = new Dictionary();
         this.enableLogs = false;
      }
      
      public function start(key:String) : void
      {
         if(!this.startTimes[key])
         {
            this.startTimes[key] = getTimer();
         }
         else
         {
            this.logError("start","key already exists: " + key);
         }
      }
      
      public function end(key:String, forceStats:Boolean = false, kingdom:String = "", phylum:String = "", classStr:String = "", family:String = "") : void
      {
         var timeTaken:int = 0;
         if(this.startTimes[key])
         {
            timeTaken = getTimer() - this.startTimes[key];
            this.startTimes[key] = null;
            if(kingdom == "")
            {
               kingdom = key;
            }
            if(Boolean(Global.flashHotParams[TEMPORARY_RUNTIME_KEY_STATS]) || forceStats)
            {
               StatsManager.count(STATS_COUNTER,kingdom,phylum,classStr,family,"",timeTaken);
            }
            if(this.enableLogs)
            {
            }
         }
         else
         {
            this.logError("end","no start time exists for key: " + key);
         }
      }
      
      private function logError(fn:String, msg:String) : void
      {
      }
   }
}

