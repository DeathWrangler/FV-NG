package Managers
{
   import Classes.Constants.ClickTrackingConstants;
   
   public class ClickTrackingManager
   {
      
      private static var m_instance:ClickTrackingManager;
      
      private static var STATS_SAMPLE_RATE:int = 1000;
      
      public static var STATS_FUNC_COUNT:String = "count";
      
      public static var STATS_FUNC_SAMPLE:String = "sample";
      
      public static var STATS_FUNC_SAMPLEORCOUNT:String = "sampleOrCount";
      
      private static var m_allowInstantiation:Boolean = false;
      
      private var m_statCounts:Array;
      
      public function ClickTrackingManager()
      {
         super();
         if(!m_allowInstantiation)
         {
            throw new Error("Error: Instantiation failed: Use ClickTrackingManager.getInstance() instead of new.");
         }
         this.m_statCounts = new Array();
      }
      
      public static function getInstance() : ClickTrackingManager
      {
         if(!m_instance)
         {
            m_allowInstantiation = true;
            m_instance = new ClickTrackingManager();
            m_allowInstantiation = false;
         }
         return m_instance;
      }
      
      public function countClick(clickKingdom:String, clickPhylum:String = "") : void
      {
         this.addCount(STATS_FUNC_SAMPLE,ClickTrackingConstants.CLICK_STATS_COUNTER,clickKingdom,clickPhylum);
      }
      
      public function sampleOrCount(experiment:String, counter:String, kingdom:String = "", phylum:String = "", maxControl:int = 0) : void
      {
         this.addCount(STATS_FUNC_SAMPLEORCOUNT,counter,kingdom,phylum,"","","",1,1000,experiment,maxControl);
      }
      
      public function addCount(statFunc:String, counter:String, kingdom:String = "", phylum:String = "", zclass:String = "", family:String = "", genus:String = "", value:int = 1, sampleRate:int = 1000, experiment:String = "", maxControl:int = 0) : void
      {
         var countObj:Object = null;
         var foundCounter:Boolean = false;
         for each(countObj in this.m_statCounts)
         {
            if(countObj.statFunc == statFunc && countObj.counter == counter && countObj.kingdom == kingdom && countObj.phylum == phylum && countObj.zclass == zclass && countObj.family == family && countObj.genus == genus && countObj.sampleRate == sampleRate && countObj.experiment == experiment)
            {
               foundCounter = true;
               countObj.count += value;
               break;
            }
         }
         if(!foundCounter)
         {
            this.m_statCounts.push({
               "statFunc":statFunc,
               "counter":counter,
               "kingdom":kingdom,
               "phylum":phylum,
               "zclass":zclass,
               "family":family,
               "genus":genus,
               "sampleRate":sampleRate,
               "count":value,
               "experiment":experiment,
               "maxControl":maxControl
            });
         }
      }
      
      public function sendStats() : void
      {
         var countObj:Object = null;
         for each(countObj in this.m_statCounts)
         {
            switch(countObj.statFunc)
            {
               case STATS_FUNC_COUNT:
                  FarmStatsManager.count(countObj.counter,countObj.kingdom,countObj.phylum,countObj.zclass,countObj.family,countObj.genus,countObj.count);
                  break;
               case STATS_FUNC_SAMPLE:
                  FarmStatsManager.sample(countObj.sampleRate,countObj.counter,countObj.kingdom,countObj.phylum,countObj.zclass,countObj.family,countObj.genus,countObj.count);
                  break;
               case STATS_FUNC_SAMPLEORCOUNT:
                  FarmStatsManager.sampleOrCount(countObj.experiment,countObj.sampleRate,countObj.counter,countObj.kingdom,countObj.phylum,countObj.zclass,countObj.family,countObj.genus,countObj.count,countObj.maxControl);
                  break;
               default:
                  throw new Error("Error: Invalid stats function " + countObj.statFunc + " passed to ClickTrackingManager.");
            }
         }
         this.m_statCounts = new Array();
      }
   }
}

