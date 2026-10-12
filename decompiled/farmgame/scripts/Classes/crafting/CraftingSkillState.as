package Classes.crafting
{
   import flash.utils.Dictionary;
   
   public class CraftingSkillState
   {
      
      private var m_craftTypeStates:Dictionary = new Dictionary();
      
      private var m_recipeStates:Object = new Object();
      
      public function CraftingSkillState()
      {
         super();
      }
      
      public function addCraftTypeState(craftTypeState:CraftTypeState) : void
      {
         this.m_craftTypeStates[craftTypeState.craftType] = craftTypeState;
      }
      
      public function getCraftTypeState(craftType:String) : CraftTypeState
      {
         var state:CraftTypeState = null;
         if(this.m_craftTypeStates[craftType])
         {
            state = this.m_craftTypeStates[craftType];
         }
         return state;
      }
      
      public function getAllCraftTypeStates() : Dictionary
      {
         return this.m_craftTypeStates;
      }
      
      public function resetRecipeStates() : void
      {
         this.m_recipeStates = new Object();
      }
      
      public function addRecipeState(recipeState:RecipeState) : void
      {
         this.m_recipeStates[recipeState.recipeId] = recipeState;
      }
      
      public function getRecipeStateById(recipeId:String) : RecipeState
      {
         var result:RecipeState = null;
         var recipe:RecipeItem = Global.craftConfigSettings.getRecipeById(recipeId);
         if(recipe != null && recipe.sharedMastery != "")
         {
            recipeId = recipe.sharedMastery;
         }
         if(this.m_recipeStates.hasOwnProperty(recipeId))
         {
            result = this.m_recipeStates[recipeId];
         }
         return result;
      }
      
      public function getAllRecipeStates() : Array
      {
         var recipeState:RecipeState = null;
         var result:Array = new Array();
         for each(recipeState in this.m_recipeStates)
         {
            result.push(recipeState);
         }
         return result;
      }
      
      public function grantDefaultRecipes() : void
      {
         var craftTypeState:CraftTypeState = null;
         var craftRecipes:Array = null;
         var recipeItem:RecipeItem = null;
         var recipeState:RecipeState = null;
         for each(craftTypeState in this.m_craftTypeStates)
         {
            if(craftTypeState != null)
            {
               craftRecipes = Global.craftConfigSettings.getAllRecipes(craftTypeState.craftType,craftTypeState.level);
               for each(recipeItem in craftRecipes)
               {
                  if(!this.m_recipeStates.hasOwnProperty(recipeItem.id))
                  {
                     recipeState = new RecipeState(recipeItem.id,recipeItem.initialRecipeLevel,0,true);
                     this.addRecipeState(recipeState);
                  }
                  else
                  {
                     recipeState = this.m_recipeStates[recipeItem.id];
                     recipeState.unlock();
                  }
               }
            }
         }
      }
   }
}

