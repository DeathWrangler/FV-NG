package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmVillageFactoriesManager;
   import Managers.FarmVillageManager;
   import Transactions.FarmVillage.THarvestFarmvillageFactory;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.GetVillageCurrencyWindow;
   
   public class FarmVillageFactoryObject
   {
      
      private var m_factoryName:String = "";
      
      private var m_factoryConfig:FactoryItem = null;
      
      private var m_currentLevelId:int = -1;
      
      private var m_numOfHarvests:int = -1;
      
      private var m_lastHarvestTime:int = -1;
      
      private var m_factoryLevel:FactoryItemLevel = null;
      
      private var m_factoryFarmItem:FarmItem = null;
      
      private var m_factoryBuilding:FarmVillageFactoryBuilding = null;
      
      public function FarmVillageFactoryObject(factoryName:String, factoryBuilding:FarmVillageFactoryBuilding)
      {
         super();
         this.m_factoryName = factoryName;
         this.m_factoryFarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_factoryName);
         this.m_factoryConfig = Global.farmGameSettingsManager.getFactoryConfigByName(this.m_factoryName);
         this.m_factoryBuilding = factoryBuilding;
         var factoryData:Object = FarmVillageFactoriesManager.getInstance().getFactoryDataByName(this.m_factoryName);
         if(Boolean(this.m_factoryConfig) && Boolean(factoryData))
         {
            if(factoryData.hasOwnProperty(FarmVillageFactoriesManager.KEY_CURRENT_LEVEL))
            {
               this.m_currentLevelId = factoryData[FarmVillageFactoriesManager.KEY_CURRENT_LEVEL];
               this.m_factoryLevel = this.m_factoryConfig.getFactoryLevelById(this.m_currentLevelId);
            }
            if(factoryData.hasOwnProperty(FarmVillageFactoriesManager.KEY_NUM_OF_HARVESTS))
            {
               this.m_numOfHarvests = factoryData[FarmVillageFactoriesManager.KEY_NUM_OF_HARVESTS];
            }
            if(factoryData.hasOwnProperty(FarmVillageFactoriesManager.KEY_LAST_HARVEST_TIME))
            {
               this.m_lastHarvestTime = factoryData[FarmVillageFactoriesManager.KEY_LAST_HARVEST_TIME];
            }
         }
         this.m_factoryBuilding.setTimer(this.getTimeRemaining());
      }
      
      public function get factoryFarmItem() : FarmItem
      {
         return this.m_factoryFarmItem;
      }
      
      public function onHarvest() : Boolean
      {
         var result:Boolean = false;
         if(this.getTimeRemaining() == 0)
         {
            if(Global.player.canBuyWithCurrency(FarmVillageManager.CURRENCY_NAME,this.m_factoryConfig.costPerHarvest))
            {
               TransactionManager.addTransaction(new THarvestFarmvillageFactory(this.m_factoryName));
               UserRewardUtil.grantUserRewards(this.m_factoryLevel.rewards);
               Global.player.updateWorldCurrency(FarmVillageManager.CURRENCY_NAME,-this.m_factoryConfig.costPerHarvest);
               this.onPostHarvestHelper();
               result = true;
            }
            else
            {
               UI.displayPopup(new GetVillageCurrencyWindow());
            }
         }
         return result;
      }
      
      public function costPerHarvest() : int
      {
         return this.m_factoryConfig.costPerHarvest;
      }
      
      private function onPostHarvestHelper() : void
      {
         ++this.m_numOfHarvests;
         if(this.canLevelUp() && this.m_numOfHarvests >= this.m_factoryLevel.harvestToNextLevel)
         {
            this.m_numOfHarvests = 0;
            ++this.m_currentLevelId;
            this.m_factoryLevel = this.m_factoryConfig.getFactoryLevelById(this.m_currentLevelId);
         }
         this.m_lastHarvestTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(this.m_factoryBuilding)
         {
            this.m_factoryBuilding.setTimer(this.getTimeRemaining());
         }
      }
      
      public function harvestsNeededToLevelUp() : int
      {
         return this.m_factoryLevel.harvestToNextLevel - this.m_numOfHarvests;
      }
      
      public function canLevelUp() : Boolean
      {
         return this.m_currentLevelId + 1 < this.m_factoryConfig.maxLevel;
      }
      
      public function onSpeedUpHarvesting() : Boolean
      {
         var result:Boolean = false;
         var speedUpHarvestingPrice:int = this.getSpeedUpPrice();
         if(Global.player.canBuyCash(speedUpHarvestingPrice,true))
         {
            TransactionManager.addTransaction(new TGenericTransaction(FarmVillageFactoriesManager.FACTORY_SERVICE,"onSpeedUpHarvesting",null,[this.m_factoryName]));
            this.makeFactoryInstantHarvestable();
            Global.player.cash -= speedUpHarvestingPrice;
            result = true;
         }
         return result;
      }
      
      public function getSpeedUpPrice() : int
      {
         var timeRemaining:int = Math.round(this.getTimeRemaining() / FarmGameUtil.NUM_SECS_IN_HOUR);
         var price:int = Math.floor(timeRemaining * this.m_factoryLevel.rushPrice);
         return price > 0 ? price : 1;
      }
      
      private function makeFactoryInstantHarvestable() : void
      {
         var currentTime:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         this.m_lastHarvestTime = currentTime - this.m_factoryLevel.harvestTime;
         if(this.m_factoryBuilding)
         {
            this.m_factoryBuilding.onHarvestTimerComplete();
         }
      }
      
      public function getLevelupPrice() : int
      {
         return (this.m_factoryLevel.harvestToNextLevel - this.m_numOfHarvests) * this.m_factoryLevel.instantLevelCostPerHarvest;
      }
      
      public function onInstantLevelUp() : Boolean
      {
         var result:Boolean = false;
         var levelRushPrice:int = this.getLevelupPrice();
         if(this.m_currentLevelId + 1 <= this.m_factoryConfig.maxLevel && Global.player.canBuyCash(levelRushPrice))
         {
            TransactionManager.addTransaction(new TGenericTransaction(FarmVillageFactoriesManager.FACTORY_SERVICE,"onInstantLeveUp",null,[this.m_factoryName]));
            Global.player.cash -= levelRushPrice;
            this.m_numOfHarvests = 0;
            ++this.m_currentLevelId;
            this.m_factoryLevel = this.m_factoryConfig.getFactoryLevelById(this.m_currentLevelId);
            this.makeFactoryInstantHarvestable();
            result = true;
         }
         return result;
      }
      
      public function getTimeRemaining() : Number
      {
         var levelHarvestTime:int = 0;
         var currentTime:int = 0;
         var result:Number = 0;
         if(Boolean(this.m_lastHarvestTime) && Boolean(this.m_factoryLevel))
         {
            levelHarvestTime = this.m_factoryLevel.harvestTime;
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            if(currentTime - this.m_lastHarvestTime < levelHarvestTime)
            {
               result = levelHarvestTime - (currentTime - this.m_lastHarvestTime);
            }
         }
         return result;
      }
      
      public function getFactoryLevel() : int
      {
         return this.m_currentLevelId;
      }
      
      public function getReward() : Object
      {
         var result:Object = new Object();
         if(this.m_factoryLevel.rewards)
         {
            result = this.m_factoryLevel.rewards[0];
         }
         return result;
      }
   }
}

