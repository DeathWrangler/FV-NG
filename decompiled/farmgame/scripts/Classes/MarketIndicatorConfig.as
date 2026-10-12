package Classes
{
   import Classes.util.FarmGameUtil;
   import Managers.FarmStatsManager;
   
   public class MarketIndicatorConfig
   {
      
      private static var m_instance:MarketIndicatorConfig = null;
      
      private static var m_canInstantiate:Boolean = false;
      
      private const SEEN_TIMESTAMP_FLAG:String = "marketArrow";
      
      private var m_isTimeValid:Boolean = false;
      
      private var m_isInExperiment:Boolean = true;
      
      private var m_startDate:String = "";
      
      private var m_endDate:String = "";
      
      private var m_iconUrl:String = "";
      
      private var m_marketCategory:String;
      
      private var m_marketSubcategory:String;
      
      private var m_statsName:String;
      
      public function MarketIndicatorConfig()
      {
         var successVariant:int = 0;
         super();
         if(!m_canInstantiate)
         {
            throw new Error("Cannot call MarketIndicatorConfig constructor directly - use getInstance() instead.");
         }
         var config:Object = Global.farmGameSettingsManager.getCurrentMarketIndicatorConfig();
         if(config)
         {
            this.m_statsName = config.statsName;
            this.m_startDate = config.limitedStart;
            this.m_endDate = config.limitedEnd;
            this.m_isTimeValid = FarmGameUtil.isTimeWithinDateRange(this.m_startDate,this.m_endDate);
            this.m_iconUrl = config.icon;
            this.m_marketCategory = config.marketCategory;
            this.m_marketSubcategory = config.marketSubcategory;
            if(config.experiment != "" && config.variant != "")
            {
               successVariant = parseInt(config.variant);
               this.m_isInExperiment = Global.experimentManager.getExperimentVariant(config.experiment) == successVariant;
            }
         }
      }
      
      public static function getInstance() : MarketIndicatorConfig
      {
         if(null == m_instance)
         {
            m_canInstantiate = true;
            m_instance = new MarketIndicatorConfig();
            m_canInstantiate = false;
         }
         return m_instance;
      }
      
      public function isActive() : Boolean
      {
         return this.m_isInExperiment && this.m_isTimeValid && !this.hasSeen();
      }
      
      public function get iconUrl() : String
      {
         return this.m_iconUrl;
      }
      
      public function get marketCategory() : String
      {
         return this.m_marketCategory;
      }
      
      public function get marketSubcategory() : String
      {
         return this.m_marketSubcategory;
      }
      
      private function hasSeen() : Boolean
      {
         var hasSeen:Boolean = false;
         var lastTimeSeenMs:Number = Global.player.getFeatureLastShown(this.SEEN_TIMESTAMP_FLAG) * 1000;
         if(lastTimeSeenMs > 0)
         {
            hasSeen = FarmGameUtil.isTimeWithinDateRange(this.m_startDate,this.m_endDate,lastTimeSeenMs);
         }
         return hasSeen;
      }
      
      public function setSeen() : void
      {
         Global.player.setFeatureLastShown(this.SEEN_TIMESTAMP_FLAG,GlobalEngine.serverTime / 1000,true);
      }
      
      public function logStatsImpression() : void
      {
         FarmStatsManager.count("marketingchannel_revenue",this.m_statsName,"impression");
      }
      
      public function logStatsClick() : void
      {
         FarmStatsManager.count("marketingchannel_revenue",this.m_statsName,"click");
      }
   }
}

