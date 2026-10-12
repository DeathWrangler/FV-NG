package Classes.crafting
{
   public class CraftSpecialization
   {
      
      private var m_craftType:String;
      
      private var m_id:String;
      
      public function CraftSpecialization(craftType:String, id:String)
      {
         super();
         this.m_craftType = craftType;
         this.m_id = id;
      }
      
      public function get craftType() : String
      {
         return this.m_craftType;
      }
      
      public function get id() : String
      {
         return this.m_id;
      }
      
      public function get experience() : int
      {
         var recipeId:String = null;
         var recipeState:RecipeState = null;
         var experienceToAdd:int = 0;
         var experience:int = 0;
         var recipeIds:Array = Global.craftConfigSettings.getRecipeIdsForSpecialization(this.m_craftType,this.m_id);
         var craftingSkillState:CraftingSkillState = Global.player.craftingState.craftingSkillState;
         for each(recipeId in recipeIds)
         {
            recipeState = craftingSkillState.getRecipeStateById(recipeId);
            if(recipeState)
            {
               experienceToAdd = recipeState.getCompletedLevel();
               experience += experienceToAdd;
            }
         }
         return experience;
      }
      
      public function get level() : int
      {
         return 1;
      }
      
      public function get experienceToLevel() : int
      {
         return 30;
      }
   }
}

