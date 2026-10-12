package Classes
{
   public class FactoryItem
   {
      
      private var m_factoryName:String = "";
      
      private var m_costPerHarvest:int = 0;
      
      private var m_factoryItemLevelsArray:Array = null;
      
      private var m_maxLevel:int = 0;
      
      public function FactoryItem(name:String, costPerHarvest:int, factoryItemLevels:Array)
      {
         super();
         this.m_factoryName = name;
         this.m_costPerHarvest = costPerHarvest;
         this.m_factoryItemLevelsArray = factoryItemLevels;
         this.m_maxLevel = this.m_factoryItemLevelsArray.length;
      }
      
      public function get name() : String
      {
         return this.m_factoryName;
      }
      
      public function get costPerHarvest() : int
      {
         return this.m_costPerHarvest;
      }
      
      public function getFactoryLevelById(id:int) : FactoryItemLevel
      {
         var result:FactoryItemLevel = null;
         if(Boolean(this.m_factoryItemLevelsArray) && Boolean(this.m_factoryItemLevelsArray[id]))
         {
            result = this.m_factoryItemLevelsArray[id] as FactoryItemLevel;
         }
         return result;
      }
      
      public function get maxLevel() : int
      {
         return this.m_maxLevel;
      }
   }
}

