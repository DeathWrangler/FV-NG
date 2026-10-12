package Classes
{
   public class FactoryItemLevel
   {
      
      private var m_levelId:int = -1;
      
      private var m_rewards:Vector.<Object> = null;
      
      private var m_harvestTime:int = 0;
      
      private var m_rushPrice:Number = 0;
      
      private var m_harvestToNextLevel:int = -1;
      
      private var m_instantLevelCostPerHarvest:int = -1;
      
      public function FactoryItemLevel(levelId:int, rewards:Vector.<Object>, harvestTime:int, rushPrice:Number, harvestToNextLevel:int = -1, instantLevelCostPerHarvest:int = -1)
      {
         super();
         this.m_levelId = levelId;
         this.m_rewards = rewards;
         this.m_harvestTime = harvestTime;
         this.m_rushPrice = rushPrice;
         this.m_harvestToNextLevel = harvestToNextLevel;
         this.m_instantLevelCostPerHarvest = instantLevelCostPerHarvest;
      }
      
      public function get rewards() : Vector.<Object>
      {
         return this.m_rewards;
      }
      
      public function get harvestTime() : int
      {
         return this.m_harvestTime;
      }
      
      public function get rushPrice() : Number
      {
         return this.m_rushPrice;
      }
      
      public function get harvestToNextLevel() : int
      {
         return this.m_harvestToNextLevel;
      }
      
      public function get instantLevelCostPerHarvest() : int
      {
         return this.m_instantLevelCostPerHarvest;
      }
   }
}

