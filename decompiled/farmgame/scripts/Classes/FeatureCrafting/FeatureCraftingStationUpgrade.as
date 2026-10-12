package Classes.FeatureCrafting
{
   public class FeatureCraftingStationUpgrade
   {
      
      private var m_station:FeatureCraftingStation;
      
      private var m_outputCount:int;
      
      private var m_unlockCost:int;
      
      public function FeatureCraftingStationUpgrade(station:FeatureCraftingStation, config:XML)
      {
         super();
         this.m_station = station;
         this.m_outputCount = parseInt(config.@outputCount);
         this.m_unlockCost = parseInt(config.@unlockCost);
      }
      
      public function get station() : FeatureCraftingStation
      {
         return this.m_station;
      }
      
      public function get outputCount() : int
      {
         return this.m_outputCount;
      }
      
      public function get unlockCost() : int
      {
         return this.m_unlockCost;
      }
   }
}

