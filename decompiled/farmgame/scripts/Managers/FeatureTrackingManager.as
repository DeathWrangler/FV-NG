package Managers
{
   import Classes.Constants.Experiments;
   
   public class FeatureTrackingManager
   {
      
      private static var s_instance:FeatureTrackingManager;
      
      private static const FEATURE_NAME:String = "featureTracking";
      
      private var m_featureConfigs:Object = {};
      
      private var m_initProcessed:Boolean = false;
      
      public function FeatureTrackingManager(key:SingletonEnforcer)
      {
         super();
         GlobalEngine.assert(key != null,"[FeatureTrackingManager] :: Use FeatureTrackingManager.instance");
      }
      
      public static function get instance() : FeatureTrackingManager
      {
         if(!s_instance)
         {
            s_instance = new FeatureTrackingManager(new SingletonEnforcer());
         }
         return s_instance;
      }
      
      private function initConfig() : void
      {
         var xml:XML = null;
         var trackingConfigs:XMLList = null;
         var config:Object = null;
         var featureName:String = null;
         var key:String = null;
         var i:int = 0;
         if(!this.m_initProcessed)
         {
            xml = Global.farmGameSettingsManager.getFeatureXML(FEATURE_NAME);
            if(xml)
            {
               trackingConfigs = xml.trackingConfigs.trackingConfig;
               for(i = 0; i < trackingConfigs.length(); i++)
               {
                  config = trackingConfigs[i];
                  key = config.@key.toString();
                  if(config["featureName"])
                  {
                     featureName = config.@featureName.toString();
                  }
                  else
                  {
                     featureName = key;
                  }
                  this.m_featureConfigs[key] = {
                     "key":key,
                     "type":config.@type.toString(),
                     "subType":config.@subType.toString(),
                     "featureName":featureName
                  };
               }
               this.m_initProcessed = true;
            }
         }
      }
      
      private function statsHelper(featureName:String, action:String) : void
      {
         var settings:Object = null;
         if(this.inExperiment())
         {
            this.initConfig();
            settings = this.m_featureConfigs[featureName];
            if(settings)
            {
               FarmStatsManager.count(settings.type,settings.subType,settings.featureName,action);
            }
         }
      }
      
      public function placement(featureName:String) : void
      {
         this.statsHelper(featureName,"placement");
      }
      
      public function uiOpen(featureName:String) : void
      {
         this.statsHelper(featureName,"uiOpen");
      }
      
      public function sendR4R(featureName:String) : void
      {
         this.statsHelper(featureName,"sendR4R");
      }
      
      public function postFeed(featureName:String) : void
      {
         this.statsHelper(featureName,"postFeed");
      }
      
      public function madePurchase(featureName:String) : void
      {
         this.statsHelper(featureName,"purchase");
      }
      
      public function completePartial(featureName:String) : void
      {
         this.statsHelper(featureName,"completePartial");
      }
      
      public function completeFully(featureName:String) : void
      {
         this.statsHelper(featureName,"completeFully");
      }
      
      private function inExperiment() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_PERSONALIZTION_STATS) == 1;
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
