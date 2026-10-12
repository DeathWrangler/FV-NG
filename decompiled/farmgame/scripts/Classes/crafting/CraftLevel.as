package Classes.crafting
{
   public class CraftLevel
   {
      
      private var m_level:int;
      
      private var m_experience:int;
      
      private var m_goldCost:int;
      
      private var m_cashCost:int;
      
      private var m_recipeSlots:int;
      
      private var m_prereqName:String;
      
      public function CraftLevel(xml:XML)
      {
         super();
         this.m_level = xml.@num;
         this.m_experience = xml.@xp;
         this.m_goldCost = xml.@gold;
         this.m_cashCost = xml.@cash;
         this.m_recipeSlots = xml.@recipeSlots;
         this.m_prereqName = xml.@prereqName;
      }
      
      public function get level() : int
      {
         return this.m_level;
      }
      
      public function get experience() : int
      {
         return this.m_experience;
      }
      
      public function get goldCost() : int
      {
         return this.m_goldCost;
      }
      
      public function get cashCost() : int
      {
         return this.m_cashCost;
      }
      
      public function get recipeSlots() : int
      {
         return this.m_recipeSlots;
      }
      
      public function get prereqName() : String
      {
         return this.m_prereqName;
      }
   }
}

