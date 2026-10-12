package Managers.Crafting
{
   import Classes.CraftingCottageBuilding;
   import Classes.crafting.RecipeItem;
   import Classes.storage.CraftedItem;
   import flash.utils.getDefinitionByName;
   
   public class CraftingRecipeQueueManager
   {
      
      private static var m_instance:CraftingRecipeQueueManager;
      
      private var m_recipeQueueManagers:Array = [CraftingRecipeQueueManager,CraftshopRecipeQueueManager,PizzashopRecipeQueueManager,HangingGardensCraftingShopRecipeQueueManager,VillageResourceBuildingRecipeQueueManager];
      
      protected var m_craftType:String;
      
      public function CraftingRecipeQueueManager(craftType:String)
      {
         super();
         this.m_craftType = craftType;
      }
      
      public static function getInstanceByCraftType(craftType:String) : CraftingRecipeQueueManager
      {
         var recipeQueueClassName:String = null;
         var classType:Class = null;
         if(craftType == null)
         {
            craftType = "winery";
         }
         if(m_instance != null && craftType != m_instance.m_craftType)
         {
            m_instance = null;
         }
         if(m_instance == null)
         {
            recipeQueueClassName = Global.craftConfigSettings.getRecipeQueueClass(craftType);
            classType = getDefinitionByName("Managers.Crafting." + recipeQueueClassName) as Class;
            m_instance = new classType(craftType);
         }
         return m_instance;
      }
      
      public function get recipeQueue() : Array
      {
         return CraftingManager.getInstance().getCottageByCraft(this.m_craftType).recipeQueue;
      }
      
      public function beginRecipe(recipeItem:RecipeItem, ignoreServerCheck:Boolean = false) : void
      {
         CraftingManager.getInstance().getCottageByRecipe(recipeItem.id).beginRecipe(recipeItem,ignoreServerCheck);
      }
      
      public function onRecipeBegun(tResult:Object) : void
      {
         var recipeItem:RecipeItem = RecipeItem.fromPhpObject(tResult);
         var cottage:CraftingCottageBuilding = CraftingManager.getInstance().getCottageByRecipe(recipeItem.id);
         cottage.onRecipeBegun(recipeItem);
      }
      
      public function endFinishedRecipesClaimed(result:Object, recipeId:String, tCallback:Function = null, fCallback:Function = null) : void
      {
         var completedRecipe:Object = null;
         var j:int = 0;
         var thisCottage:CraftingCottageBuilding = null;
         var craftedItem:CraftedItem = null;
         var postFeed:Boolean = false;
         var rewardRecipe:Object = null;
         var rewardCottage:CraftingCottageBuilding = null;
         var cottages:Array = CraftingManager.getInstance().getPlacedCraftingCottages();
         for(var i:int = 0; i < result.length; i++)
         {
            completedRecipe = result[i];
            for(j = 0; j < cottages.length; j++)
            {
               thisCottage = cottages[j] as CraftingCottageBuilding;
               if(thisCottage != null && thisCottage.isRecipeAppropriateForCottage(completedRecipe.recipeId))
               {
                  thisCottage.recordRecipeFinished(completedRecipe);
                  rewardRecipe = completedRecipe;
                  rewardCottage = thisCottage;
                  if(Boolean(completedRecipe.productItemCode) && Boolean(completedRecipe.numGiftProducts > 0) && completedRecipe.recipeLevel > 0)
                  {
                     craftedItem = CraftedItem.createCraftedItem(completedRecipe.productItemCode,completedRecipe.recipeLevel,completedRecipe.numGiftProducts);
                     Global.player.craftingState.addCraftedItemToInventory(craftedItem);
                     if(completedRecipe.rewardLink)
                     {
                        postFeed = true;
                     }
                  }
               }
            }
         }
         if(tCallback != null)
         {
            tCallback(result);
         }
         CraftingManager.getInstance().handleFinishFeed(rewardRecipe,postFeed,fCallback);
      }
   }
}

