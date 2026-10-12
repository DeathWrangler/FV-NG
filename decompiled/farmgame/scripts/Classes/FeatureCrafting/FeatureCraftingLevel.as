package Classes.FeatureCrafting
{
   public class FeatureCraftingLevel
   {
      
      private var m_system:FeatureCraftingSystem;
      
      private var m_levelNum:int;
      
      private var m_pointsRequired:int;
      
      private var m_coinReward:int;
      
      private var m_xpReward:int;
      
      private var m_inventoryCounts:Object;
      
      public function FeatureCraftingLevel(system:FeatureCraftingSystem, config:XML)
      {
         var inventory:FeatureCraftingInventory = null;
         super();
         this.m_system = system;
         this.m_levelNum = parseInt(config.@num);
         this.m_pointsRequired = parseInt(config.@pointsRequired);
         this.m_coinReward = parseInt(config.@coins);
         this.m_xpReward = parseInt(config.@xp);
         var inventories:Array = system.getInventories();
         this.m_inventoryCounts = {};
         for each(inventory in inventories)
         {
            if(config.hasOwnProperty("@minCapactiy_" + inventory.name))
            {
               this.m_inventoryCounts[inventory.name] = parseInt(config["@minCapactiy_" + inventory.name]);
            }
         }
      }
      
      public function get system() : FeatureCraftingSystem
      {
         return this.m_system;
      }
      
      public function get levelNum() : int
      {
         return this.m_levelNum;
      }
      
      public function get pointsRequired() : int
      {
         return this.m_pointsRequired;
      }
      
      public function get coinReward() : int
      {
         return this.m_coinReward;
      }
      
      public function get xpReward() : int
      {
         return this.m_xpReward;
      }
      
      public function get minInventoryCounts() : Object
      {
         return this.m_inventoryCounts;
      }
   }
}

