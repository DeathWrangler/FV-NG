package Managers
{
   import Classes.Constants.Experiments;
   import Classes.HarvestableResource;
   import Classes.Plot;
   import Classes.Quest.PrerequisiteUtility;
   import Engine.Managers.TransactionManager;
   import Transactions.TransactionWithCallBack;
   
   public class IrrigationManager
   {
      
      private static var s_instance:IrrigationManager;
      
      public static const FEATURE_NAME:String = "irrigation";
      
      public static const WATER_PLOTS:String = "waterPlots";
      
      private var m_data:Object;
      
      private var m_config:Object;
      
      public function IrrigationManager(key:SingletonEnforcer)
      {
         super();
         GlobalEngine.assert(key != null,"[IrrigationManager] :: Use GetInstance()");
      }
      
      public static function get instance() : IrrigationManager
      {
         if(!s_instance)
         {
            s_instance = new IrrigationManager(new SingletonEnforcer());
         }
         return s_instance;
      }
      
      public function isFeatureEnabled() : Boolean
      {
         return PrerequisiteUtility.checkPrereqByName("bldg_irrigationWell_base");
      }
      
      public function isInExperiment() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_IRRIGATION) >= 2;
      }
      
      public function init() : void
      {
         var actionTypeList:XMLList = null;
         var length:int = 0;
         var i:int = 0;
         var actionType:XML = null;
         var j:int = 0;
         var worldConfig:XML = null;
         this.m_config = {};
         var feature:XML = Global.farmGameSettingsManager.getFeatureXML(FEATURE_NAME);
         if(feature)
         {
            actionTypeList = feature.actionTypes.actionType;
            length = actionTypeList.length();
            for(i = 0; i < length; i++)
            {
               actionType = actionTypeList[i];
               this.m_config[actionType.@name] = {};
               for(j = 0; j < actionType.worldConfigs.worldConfig.length(); j++)
               {
                  worldConfig = actionType.worldConfigs.worldConfig[j];
                  this.m_config[actionType.@name][worldConfig.@name] = {"max":int(worldConfig.@max)};
               }
            }
         }
         this.m_data = this.getFeatureData();
         if(!this.m_data)
         {
            this.m_data = {};
         }
      }
      
      public function addWater(actionType:String, increment:int) : void
      {
         var currentWorld:String = null;
         if(actionType in this.m_data)
         {
            currentWorld = Global.worldManager.currentWorldType;
            if(!(currentWorld in this.m_data[actionType]))
            {
               this.m_data[actionType][currentWorld] = {"amount":0};
            }
            this.m_data[actionType][currentWorld]["amount"] += increment;
            Global.hud.refreshWater();
         }
      }
      
      public function getMaxWaterForActionType(actionType:String) : int
      {
         return 2000;
      }
      
      public function getWaterSourcesForActionType(actionType:String) : Array
      {
         return ["bldg_irrigationwell","bldg_irrigationwell_8hr"];
      }
      
      public function getWaterSourcesConsumables(actionType:String) : Array
      {
         return ["pkg_consume_irrigation_water_100","pkg_consume_irrigation_water_1000","pkg_consume_irrigation_water_2000","pkg_consume_irrigation_water_500"];
      }
      
      public function getSingleWaterSourceConsumable(actionType:String) : String
      {
         return "consume_irrigation_water";
      }
      
      public function getAllSprinklers(actionType:String) : Array
      {
         return ["irrigation_sprinkler1","irrigation_sprinkler2","irrigation_sprinkler3"];
      }
      
      public function useWater(actionType:String, decrement:int) : void
      {
         var currentWorld:String = null;
         if(actionType in this.m_data)
         {
            currentWorld = Global.worldManager.currentWorldType;
            if(!(currentWorld in this.m_data[actionType]))
            {
               this.m_data[actionType][currentWorld]["amount"] = 0;
            }
            this.m_data[actionType][currentWorld]["amount"] -= decrement;
            Global.hud.refreshWater();
         }
      }
      
      public function consumeWaterPackages(qty:int) : void
      {
         TransactionManager.addTransaction(new TransactionWithCallBack("IrrigationService.consumeIrrigationPackages",null,IrrigationManager.WATER_PLOTS,qty));
         IrrigationManager.instance.addWater(IrrigationManager.WATER_PLOTS,qty);
         Global.player.removeGiftWithKey("3YG",qty);
      }
      
      public function getWaterAmount(actionType:String) : int
      {
         var currentWorld:String = null;
         var result:int = 0;
         if(Boolean(this.m_data) && this.m_data.hasOwnProperty(actionType))
         {
            currentWorld = Global.worldManager.currentWorldType;
            if(this.m_data[actionType].hasOwnProperty(currentWorld))
            {
               result = this.m_data[actionType][currentWorld]["amount"] ? int(this.m_data[actionType][currentWorld]["amount"]) : 0;
            }
         }
         return result;
      }
      
      public function getWaterCost(resources:Array) : int
      {
         var resource:HarvestableResource = null;
         var plot:Plot = null;
         var result:int = 0;
         for each(resource in resources)
         {
            plot = resource as Plot;
            if(plot)
            {
               result += SuperPlotManager.getMultiplier(plot);
            }
            else
            {
               result++;
            }
         }
         return result;
      }
      
      public function getFeatureData() : Object
      {
         var result:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,FEATURE_NAME);
         if(result == null)
         {
            result = {};
            result[WATER_PLOTS] = {"farm":{"amount":20}};
         }
         return result;
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
