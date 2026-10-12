package Managers
{
   import Classes.util.FarmGameUtil;
   import Engine.Constants;
   import Engine.Managers.StatsManager;
   import Managers.InGameConsole.InGameConsoleManager;
   
   public class FarmStatsManager
   {
      
      public static const FEATURE_SAMPLE_RATE:int = 10;
      
      public static const FEATURE_SAMPLE_DELAY_DAYS:int = 90;
      
      public static const SAMPLE_OVERRIDE_RUNTIME_PREFIX:String = "SAMPLE_OVERRIDE_";
      
      public function FarmStatsManager()
      {
         super();
      }
      
      public static function featureCount(releaseDate:int, counter:String, kingdom:String = "", phylum:String = "", zclass:String = "", family:String = "", genus:String = "", value:int = 1) : void
      {
         var rate:int = 1;
         if(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - releaseDate > FarmGameUtil.NUM_SECS_IN_DAY * FEATURE_SAMPLE_DELAY_DAYS)
         {
            rate = FEATURE_SAMPLE_RATE;
         }
         StatsManager.sample(rate,counter,kingdom,phylum,zclass,family,genus,value);
      }
      
      public static function featureSample(counter:String, kingdom:String = "", phylum:String = "", zclass:String = "", family:String = "", genus:String = "", value:int = 1) : void
      {
         var rateOverride:int = 0;
         var rate:int = FEATURE_SAMPLE_RATE;
         var overrideKey:String = SAMPLE_OVERRIDE_RUNTIME_PREFIX + counter.toUpperCase();
         var rateOverrideString:String = GlobalEngine.getFlashVar(overrideKey) as String;
         if(rateOverrideString != null)
         {
            rateOverride = parseInt(rateOverrideString);
            if(rateOverride > 0)
            {
               rate = rateOverride;
            }
         }
         StatsManager.sample(rate,counter,kingdom,phylum,zclass,family,genus,value);
      }
      
      public static function count(counter:String, kingdom:String = "", phylum:String = "", zclass:String = "", family:String = "", genus:String = "", value:int = 1) : void
      {
         if(genus == "")
         {
            genus = Global.worldManager.currentWorldType;
         }
         InGameConsoleManager.consoleStatsDisplay(counter,kingdom,phylum,zclass,family,genus,value);
         StatsManager.count(counter,kingdom,phylum,zclass,family,genus,value);
      }
      
      public static function countOncePerSession(counter:String, kingdom:String = "", phylum:String = "", zclass:String = "", family:String = "", genus:String = "", value:int = 1) : void
      {
         var sessionSeenFlag:String = counter + kingdom + phylum + zclass + family + genus + String(value);
         if(!Global.player.getSeenSessionFlag(sessionSeenFlag))
         {
            Global.player.setSeenSessionFlag(sessionSeenFlag);
            count(counter,kingdom,phylum,zclass,family,genus,value);
         }
      }
      
      public static function sample(rate:int, counter:String, kingdom:String = "", phylum:String = "", zclass:String = "", family:String = "", genus:String = "", value:int = 1) : void
      {
         if(genus == "")
         {
            genus = Global.worldManager.currentWorldType;
         }
         StatsManager.sample(rate,counter,kingdom,phylum,zclass,family,genus,value);
      }
      
      public static function sampleOrCount(experiment:String, rate:int, counter:String, kingdom:String = "", phylum:String = "", zclass:String = "", family:String = "", genus:String = "", value:int = 1, maxControl:int = 0) : void
      {
         if(Global.experimentManager.getExperimentVariant(experiment) > maxControl)
         {
            count(counter,kingdom,phylum,zclass,family,genus,value);
         }
         else
         {
            sample(rate,counter,kingdom,phylum,zclass,family,genus,value);
         }
      }
      
      public static function d1drop(kingdom:String, time:Number = 0, zclass:String = "") : void
      {
         time /= 1000;
         time = Math.min(Constants.D1DROP_STATS_MAX_TIMESTAMP,time);
         count("d1_drop",kingdom,int(time).toString(),zclass);
      }
   }
}

