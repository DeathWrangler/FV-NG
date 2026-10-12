package Classes.PphToDo
{
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingManager;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class GetBushelsAction extends PphAction
   {
      
      private var m_remainingBushels:int = 0;
      
      private var m_recipe:RecipeItem;
      
      public function GetBushelsAction()
      {
         super();
      }
      
      override public function createData() : Boolean
      {
         var recipeItem:RecipeItem = null;
         var minCompletePercentThreshold:int = 0;
         var totalIngredientsRequired:int = 0;
         var totalIngredientsOwned:int = 0;
         var mostCompleteBushelPercent:int = 0;
         var mostCompleteBushelId:String = null;
         var mostCompleteBushelRemainingCount:int = 0;
         var totalRecipeCompletionPercent:int = 0;
         var numIngredients:int = 0;
         var quantityRequired:int = 0;
         var remainingIngredient:int = 0;
         var ingredientCompletionPercent:int = 0;
         var bushel:FarmItem = null;
         var crop:FarmItem = null;
         var recipe:RecipeItem = null;
         var result:Boolean = false;
         var ingredient:Object = null;
         var recipeCompletionData:Object = null;
         var recipesCompletionData:Array = [];
         var allRecipes:Array = Global.craftConfigSettings.getAllRecipes();
         var unlockedRecipes:Array = [];
         for each(recipeItem in allRecipes)
         {
            if(CraftingManager.getInstance().isRecipeLocked(recipeItem.id) == 0)
            {
               totalIngredientsRequired = 0;
               totalIngredientsOwned = 0;
               mostCompleteBushelPercent = 0;
               mostCompleteBushelId = null;
               mostCompleteBushelRemainingCount = 0;
               for each(ingredient in recipeItem.ingredients)
               {
                  numIngredients = CraftingManager.getInstance().getBushelQuantityInInventory(ingredient.itemCode);
                  quantityRequired = int(ingredient.quantityRequired);
                  remainingIngredient = quantityRequired - numIngredients;
                  if(remainingIngredient < 0)
                  {
                     remainingIngredient = 0;
                  }
                  totalIngredientsOwned += numIngredients;
                  totalIngredientsRequired += quantityRequired;
                  ingredientCompletionPercent = numIngredients / quantityRequired * 100;
                  if(remainingIngredient > 0 && ingredientCompletionPercent >= mostCompleteBushelPercent)
                  {
                     mostCompleteBushelPercent = ingredientCompletionPercent;
                     mostCompleteBushelId = ingredient.itemCode;
                     mostCompleteBushelRemainingCount = remainingIngredient;
                  }
               }
               unlockedRecipes.push(recipeItem);
               totalRecipeCompletionPercent = totalIngredientsOwned / totalIngredientsRequired * 100;
               if(totalRecipeCompletionPercent < 100)
               {
                  recipeCompletionData = {
                     "recipeId":recipeItem.id,
                     "remainingBushels":mostCompleteBushelRemainingCount,
                     "bushelId":mostCompleteBushelId,
                     "totalIngredientsRequired":totalIngredientsRequired,
                     "totalIngredientsOwned":totalIngredientsOwned,
                     "percentComplete":totalRecipeCompletionPercent
                  };
                  recipesCompletionData.push(recipeCompletionData);
               }
            }
         }
         recipesCompletionData.sortOn(["percentComplete"],Array.NUMERIC | Array.DESCENDING);
         minCompletePercentThreshold = Global.farmGameSettingsManager.getNumber("toDoListMinRecipeCompletePercent",50);
         for each(recipeCompletionData in recipesCompletionData)
         {
            if(recipeCompletionData["percentComplete"] >= minCompletePercentThreshold)
            {
               bushel = Global.farmGameSettingsManager.getFarmItemByCode(recipeCompletionData["bushelId"]);
               if(bushel != null)
               {
                  crop = Global.farmGameSettingsManager.getFarmItemByCode(bushel.crop);
                  recipe = Global.craftConfigSettings.getRecipeById(recipeCompletionData["recipeId"]);
                  if(crop != null && recipe != null)
                  {
                     m_crop = crop;
                     this.m_recipe = recipe;
                     this.m_remainingBushels = recipeCompletionData["remainingBushels"];
                     result = true;
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      override protected function getStatKingdom() : String
      {
         return "plant_for_bushel_event";
      }
      
      override protected function attachHudIconToolTip() : void
      {
         m_hudIcon.toolTip = ZLocUtils.t("Dialogs","Pph_GetBushels",{
            "quantity":this.m_remainingBushels,
            "item":ZLocUtils.tk_pk(m_crop.friendlyName,"",this.m_remainingBushels),
            "recipe":ZLocUtils.tk_pk(this.m_recipe.friendlyName)
         });
      }
      
      override protected function onIconLoaded(content:DisplayObject) : void
      {
         super.onIconLoaded(content);
         var mc:MovieClip = content as MovieClip;
         if(mc)
         {
            if(mc.starBar_mc != null)
            {
               mc.starBar_mc.visible = false;
            }
         }
      }
   }
}

