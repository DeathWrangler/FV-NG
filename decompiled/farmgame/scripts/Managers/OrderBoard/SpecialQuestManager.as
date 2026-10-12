package Managers.OrderBoard
{
   import Classes.FeedData;
   import Classes.Quest.FarmTask;
   import Managers.FeatureConfigManager;
   import flash.events.EventDispatcher;
   import flash.utils.getDefinitionByName;
   
   public class SpecialQuestManager extends EventDispatcher
   {
      
      protected static var s_allowInstantiation:Boolean;
      
      protected static var s_instances:Object = {};
      
      protected var m_featureConfigManager:FeatureConfigManager;
      
      protected var m_featureName:String;
      
      protected var m_featureConfig:XML;
      
      private var m_feedConfig:FeedData;
      
      public function SpecialQuestManager(featureName:String)
      {
         super();
         if(s_allowInstantiation)
         {
            s_allowInstantiation = false;
            this.m_featureName = featureName;
            this.m_featureConfig = this.featureConfig ? this.featureConfig : Global.farmGameSettingsManager.getFeatureXML(featureName);
            this.m_featureConfigManager = FeatureConfigManager.getFeatureConfiguration(featureName);
            return;
         }
         throw new Error("Instantiation failed: Use SpecialQuestManager.getInstance");
      }
      
      public static function getInstance(featureName:String) : SpecialQuestManager
      {
         return getInstanceOfClass(featureName,SpecialQuestManager);
      }
      
      protected static function getInstanceOfClass(featureName:String, className:Class) : SpecialQuestManager
      {
         var manager:SpecialQuestManager = null;
         if(s_instances[featureName])
         {
            manager = s_instances[featureName];
         }
         else
         {
            s_allowInstantiation = true;
            manager = new className(featureName);
            s_instances[featureName] = manager;
         }
         return manager;
      }
      
      public static function initAllOrderBoards(worldCurrencies:Object) : void
      {
         var nameXML:XML = null;
         var orderName:String = null;
         var orderConfig:XML = null;
         var managerClass:Class = null;
         var manager:* = undefined;
         var delta:int = 0;
         var allOrderBoards:XML = Global.farmGameSettingsManager.getFeatureXML("allorderboards");
         for each(nameXML in allOrderBoards.children())
         {
            orderName = nameXML["@name"];
            orderConfig = Global.farmGameSettingsManager.getFeatureXML(orderName);
            if(orderConfig)
            {
               managerClass = getDefinitionByName("Managers.OrderBoard." + orderConfig["manager"]["@name"]) as Class;
               manager = managerClass["getInstance"].call(null,orderName);
               if(Boolean(worldCurrencies) && worldCurrencies.hasOwnProperty(manager.currencyName))
               {
                  delta = parseInt(worldCurrencies[manager.currencyName]) - Global.player.getWorldCurrencyTotal(manager.currencyName);
                  if(delta > 0)
                  {
                     Global.player.updateWorldCurrency(manager.currencyName,delta);
                  }
               }
            }
         }
      }
      
      public function getTasks() : Vector.<FarmTask>
      {
         return null;
      }
      
      public function getRewards() : Vector.<Object>
      {
         return null;
      }
      
      public function get featureConfig() : XML
      {
         return this.m_featureConfig;
      }
      
      public function getFeedData(source:String) : FeedData
      {
         return this.m_featureConfigManager.getFeedData(source);
      }
      
      public function postFeed(source:String, callback:Function = null) : void
      {
         var feed:FeedData = this.m_featureConfigManager.getFeedData(source);
         feed.postFeed(callback);
      }
      
      public function getThrottleTimeRemaining(source:String) : int
      {
         var feed:FeedData = this.m_featureConfigManager.getFeedData(source);
         return feed.throttleTimeRemaining;
      }
   }
}

