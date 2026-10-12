package Managers
{
   import Classes.FeedData;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   
   public class FeatureConfigManager
   {
      
      private static var m_featureManagerCache:Object = {};
      
      protected var m_constants:Object = {};
      
      protected var m_assets:Object = {};
      
      protected var m_consumable:String = "";
      
      protected var m_feedConfig:Object = {};
      
      protected var m_featureName:String = "";
      
      protected var m_bornMS:Number = 0;
      
      protected var m_diesMS:Number = 0;
      
      protected var m_featureExists:Boolean = false;
      
      public function FeatureConfigManager(featureName:String)
      {
         super();
         this.m_featureName = featureName;
      }
      
      public static function getFeatureConfiguration(featureName:String) : FeatureConfigManager
      {
         var node:XML = null;
         var manager:FeatureConfigManager = null;
         if(!m_featureManagerCache.hasOwnProperty(featureName))
         {
            node = Global.farmGameSettingsManager.getFeatureXML(featureName);
            manager = createFeatureConfigManager(featureName,node);
            m_featureManagerCache[featureName] = manager;
         }
         return m_featureManagerCache[featureName];
      }
      
      private static function createFeatureConfigManager(featureName:String, node:XML) : FeatureConfigManager
      {
         var attributes:XMLList = null;
         var i:int = 0;
         var key:String = null;
         var value:String = null;
         var children:XMLList = null;
         var feedConfigs:XMLList = null;
         var manager:FeatureConfigManager = new FeatureConfigManager(featureName);
         if(node)
         {
            if(node.hasOwnProperty("@born"))
            {
               manager.m_constants["@born"] = String(node.@born);
               manager.m_bornMS = FarmGameUtil.synchronizedDateToNumber(manager.m_constants["@born"]);
            }
            else
            {
               manager.m_bornMS = 0;
            }
            if(node.hasOwnProperty("@dies"))
            {
               manager.m_constants["@dies"] = String(node.@dies);
               manager.m_diesMS = FarmGameUtil.synchronizedDateToNumber(manager.m_constants["@dies"]);
            }
            else
            {
               manager.m_diesMS = 0;
            }
            if(node.hasOwnProperty("constants"))
            {
               attributes = node.constants.attributes();
               for(i = 0; i < attributes.length(); i++)
               {
                  key = String(attributes[i].name());
                  value = String(attributes[i]);
                  manager.m_constants[key] = value;
               }
            }
            if(node.hasOwnProperty("assets"))
            {
               children = node.assets.children();
               for(i = 0; i < children.length(); i++)
               {
                  key = children[i].@name.toString();
                  value = children[i].@path.toString();
                  manager.m_assets[key] = value;
               }
            }
            if(node.hasOwnProperty("currencyItem"))
            {
               manager.m_consumable = node.currencyItem[0].@name.toString();
            }
            if(node.hasOwnProperty("feedConfig"))
            {
               feedConfigs = node.feedConfig.children();
               for(i = 0; i < feedConfigs.length(); i++)
               {
                  manager.m_feedConfig[feedConfigs[i].@source.toString()] = new FeedData(featureName,feedConfigs[i]);
               }
            }
            manager.m_featureExists = true;
         }
         return manager;
      }
      
      public static function featureConfigMatchesCurrentUser(node:XML) : Boolean
      {
         var experiment:String = null;
         var variant:Number = NaN;
         var requiredVariant:Number = NaN;
         var countryString:String = null;
         var countries:Array = null;
         var foundMatch:Boolean = false;
         var i:Number = NaN;
         var prereqs:Array = null;
         var result:Boolean = true;
         var diesMS:Number = node.hasOwnProperty("@dies") ? FarmGameUtil.synchronizedDateToNumber(String(node.@dies)) : 0;
         var bornMS:Number = node.hasOwnProperty("@born") ? FarmGameUtil.synchronizedDateToNumber(String(node.@born)) : 0;
         if(diesMS > 0 && GlobalEngine.serverTime > diesMS)
         {
            result = false;
         }
         if(node.hasOwnProperty("@name") && node.@name == "GhoulBallCraftingBasket")
         {
         }
         if(GlobalEngine.serverTime < bornMS)
         {
            result = false;
         }
         if(result && node.hasOwnProperty("@experiment"))
         {
            experiment = String(node.@experiment);
            variant = Global.experimentManager.getExperimentVariant(experiment);
            if(node.hasOwnProperty("@variant"))
            {
               requiredVariant = Number(node.@variant);
               result = requiredVariant == variant;
            }
            else
            {
               result = variant > 0;
            }
         }
         if(result && node.hasOwnProperty("geoIpAllowedCountries"))
         {
            countryString = node.geoIpAllowedCountries;
            countries = countryString.split(",");
            foundMatch = false;
            for(i = 0; i < countries.length; i++)
            {
               if(Global.geoIpManager.geoip != null && Global.geoIpManager.geoip.country_code == countries[i])
               {
                  foundMatch = true;
                  break;
               }
            }
            result = foundMatch;
         }
         if(result && node.hasOwnProperty("@level_min"))
         {
            result = Global.player.level >= parseInt(node.@level_min);
         }
         if(result && node.hasOwnProperty("prereqs"))
         {
            prereqs = PrerequisiteUtility.parseXmlNodePrereqs(node.prereqs.children());
            result = PrerequisiteUtility.arePrerequisitesMet(prereqs);
         }
         return result;
      }
      
      public function get featureName() : String
      {
         return this.m_featureName;
      }
      
      public function isFeatureVisible() : Boolean
      {
         var result:Boolean = this.m_featureExists;
         var wt:Number = GlobalEngine.serverTime;
         var bt:Number = this.m_bornMS;
         result &&= wt >= this.m_bornMS;
         return result && (this.m_diesMS == 0 || wt <= this.m_diesMS);
      }
      
      public function getTimeRemaining() : Array
      {
         var timeLeftMs:Number = this.m_diesMS - GlobalEngine.serverTime;
         timeLeftMs = timeLeftMs < 0 ? 0 : timeLeftMs;
         return FarmGameUtil.parseTimeLeft(timeLeftMs / 1000);
      }
      
      public function getTimeElapsedMS() : Number
      {
         var timePassedMs:Number = GlobalEngine.serverTime - this.m_bornMS;
         return timePassedMs < 0 ? 0 : timePassedMs;
      }
      
      public function getTimeElapsed() : Array
      {
         return FarmGameUtil.parseTimeLeft(this.getTimeElapsedMS());
      }
      
      public function getStringConstant(key:String) : String
      {
         return this.m_constants.hasOwnProperty(key) ? String(this.m_constants[key]) : null;
      }
      
      public function getNumberConstant(key:String) : Number
      {
         return this.m_constants.hasOwnProperty(key) ? Number(this.m_constants[key]) : 0;
      }
      
      public function getBooleanConstant(key:String) : Boolean
      {
         return this.m_constants.hasOwnProperty(key) ? Boolean(this.m_constants[key]) : false;
      }
      
      public function hasConstant(key:String) : Boolean
      {
         return this.m_constants[key];
      }
      
      public function getFeatureDuration() : Array
      {
         var timeDurationMs:Number = this.m_diesMS - this.m_bornMS;
         timeDurationMs = timeDurationMs < 0 ? 0 : timeDurationMs;
         return FarmGameUtil.parseTimeLeft(timeDurationMs / 1000);
      }
      
      public function getAssetUrl(type:String) : String
      {
         if(this.m_assets.hasOwnProperty(type))
         {
            return this.m_assets[type];
         }
         return null;
      }
      
      public function get consumable() : FarmItem
      {
         return Global.farmGameSettingsManager.getFarmItemByName(this.m_consumable);
      }
      
      public function getFeedData(source:String) : FeedData
      {
         return this.m_feedConfig[source];
      }
   }
}

