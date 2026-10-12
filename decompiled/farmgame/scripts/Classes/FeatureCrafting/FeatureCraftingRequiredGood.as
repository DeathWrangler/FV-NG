package Classes.FeatureCrafting
{
   public class FeatureCraftingRequiredGood
   {
      
      private var m_system:FeatureCraftingSystem;
      
      private var m_good:FeatureCraftingGood;
      
      private var m_numRequired:int;
      
      public function FeatureCraftingRequiredGood(system:FeatureCraftingSystem, good:FeatureCraftingGood, numRequired:int)
      {
         super();
         this.m_system = system;
         this.m_good = good;
         this.m_numRequired = numRequired;
      }
      
      public function get system() : FeatureCraftingSystem
      {
         return this.m_system;
      }
      
      public function get numRequired() : int
      {
         return this.m_numRequired;
      }
      
      public function get good() : FeatureCraftingGood
      {
         return this.m_good;
      }
      
      public function get hasEnough() : Boolean
      {
         return this.m_good.inventoryCount >= this.m_numRequired;
      }
   }
}

