package Classes.crafting
{
   public class RecipeState
   {
      
      private var m_recipeId:String;
      
      private var m_level:int;
      
      private var m_xp:int;
      
      private var m_isUnlocked:Boolean = false;
      
      private var m_isLeveledUp:Boolean = false;
      
      public function RecipeState(recipeId:String, level:int, xp:int, isUnlocked:Boolean = false)
      {
         super();
         this.m_recipeId = recipeId;
         this.m_level = level;
         this.m_xp = xp;
         this.m_isUnlocked = isUnlocked;
      }
      
      public static function fromPhpObject(obj:Object) : RecipeState
      {
         return new RecipeState(obj.m_type,obj.m_level,obj.m_experience,obj.m_isUnlocked);
      }
      
      public function get isUnlocked() : Boolean
      {
         return this.m_isUnlocked;
      }
      
      public function get recipeId() : String
      {
         return this.m_recipeId;
      }
      
      public function get level() : int
      {
         return this.m_level;
      }
      
      public function get xp() : int
      {
         return this.m_xp;
      }
      
      public function unlock() : void
      {
         this.m_isUnlocked = true;
      }
      
      public function incrementLevel() : void
      {
         this.m_level += 1;
         this.m_xp = 0;
         var recipeItem:RecipeItem = Global.craftConfigSettings.getRecipeById(this.m_recipeId);
         var craftTypeState:CraftTypeState = Global.player.craftingState.craftingSkillState.getCraftTypeState(recipeItem.craft);
         craftTypeState.addExperience(1);
         this.m_isLeveledUp = true;
      }
      
      public function addExperience(xp:int) : void
      {
         var nextLevel:int = 0;
         var nextLevelXp:int = 0;
         var xpToLevel:int = 0;
         var overflowXp:int = 0;
         this.m_xp += xp;
         this.m_isLeveledUp = false;
         if(this.m_level < Global.craftConfigSettings.getMaxRecipeLevel(this.m_recipeId))
         {
            nextLevel = this.m_level + 1;
            nextLevelXp = this.getExperienceIncNeededForLevel(nextLevel);
            if(nextLevelXp > 0)
            {
               xpToLevel = this.getExperienceIncNeededForLevel(this.m_level);
               if(this.m_xp >= xpToLevel)
               {
                  overflowXp = this.m_xp - xpToLevel;
                  this.incrementLevel();
                  if(overflowXp > 0)
                  {
                     this.addExperience(overflowXp);
                  }
               }
            }
         }
      }
      
      public function getExperienceIncNeededForLevel(level:int) : int
      {
         return Global.craftConfigSettings.getXpIncForRecipeLevel(level,this.m_recipeId);
      }
      
      public function getCompletedLevel() : int
      {
         var level:int = this.level;
         if(this.m_xp < this.getExperienceIncNeededForLevel(level))
         {
            level--;
         }
         return level;
      }
      
      public function getEstimatedItemsForLevel() : Number
      {
         var xpNeeded:Number = this.getExperienceIncNeededForLevel(this.m_level) - this.m_xp;
         if(xpNeeded < 0)
         {
            xpNeeded = 0;
         }
         var xpPerRecipe:Number = Global.craftConfigSettings.getRecipeById(this.m_recipeId).rewardRecipeXp;
         return xpNeeded / xpPerRecipe;
      }
      
      public function getFractionalProgessToNextLevel() : Number
      {
         var result:Number = 1;
         var xpForNextLevel:Number = this.getExperienceIncNeededForLevel(this.m_level);
         if(xpForNextLevel > 0)
         {
            if(this.m_xp < xpForNextLevel)
            {
               result = this.m_xp / xpForNextLevel;
            }
         }
         return result;
      }
      
      public function get isRecipeLeveledUp() : Boolean
      {
         return this.m_isLeveledUp;
      }
   }
}

