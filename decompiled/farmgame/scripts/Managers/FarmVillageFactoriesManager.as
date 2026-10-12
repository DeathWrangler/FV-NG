package Managers
{
   import Classes.util.FarmGameUtil;
   import flash.events.EventDispatcher;
   
   public class FarmVillageFactoriesManager extends EventDispatcher
   {
      
      private static var m_instance:FarmVillageFactoriesManager = null;
      
      public static const KEY_CURRENT_LEVEL:String = "currentLevel";
      
      public static const KEY_NUM_OF_HARVESTS:String = "numOfHarvests";
      
      public static const KEY_LAST_HARVEST_TIME:String = "lastHarvestTime";
      
      public static const FACTORY_SERVICE:String = "FarmVillageFactoryService";
      
      public static const FACTORY_HARVEST_FUNCTION:String = "onFactoryHarvest";
      
      public function FarmVillageFactoriesManager(key:SingletonEnforcer)
      {
         super();
         if(!key)
         {
            throw new Error("Invalid FarmVillageFactoriesManager Singleton class. Use FarmVillageFactoriesManager.getInstance");
         }
      }
      
      public static function getInstance() : FarmVillageFactoriesManager
      {
         if(m_instance == null)
         {
            m_instance = new FarmVillageFactoriesManager(new SingletonEnforcer());
         }
         return m_instance;
      }
      
      private function setFactoriesData(factoriesData:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.FARM_VILLAGE,FeatureOptionsManager.FARM_VILLAGE_FACTORY,factoriesData);
      }
      
      public function getFactoriesData() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.FARM_VILLAGE,FeatureOptionsManager.FARM_VILLAGE_FACTORY);
      }
      
      public function getFactoryDataByName(factoryName:String) : Object
      {
         var allFactoriesData:Object = this.getFactoriesData();
         var factoryData:Object = new Object();
         if(!allFactoriesData)
         {
            allFactoriesData = new Object();
         }
         if(!allFactoriesData.hasOwnProperty(factoryName))
         {
            factoryData = this.addNewFactoryData(factoryName);
         }
         else
         {
            factoryData = allFactoriesData[factoryName];
         }
         return factoryData;
      }
      
      public function addNewFactoryData(factoryName:String) : Object
      {
         var newFactoryData:Object = new Object();
         var factoriesData:Object = this.getFactoriesData();
         if(!factoriesData)
         {
            factoriesData = new Object();
         }
         if(factoryName)
         {
            newFactoryData[KEY_CURRENT_LEVEL] = 0;
            newFactoryData[KEY_NUM_OF_HARVESTS] = 0;
            newFactoryData[KEY_LAST_HARVEST_TIME] = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            factoriesData[factoryName] = newFactoryData;
            this.setFactoriesData(factoriesData);
         }
         return newFactoryData;
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
