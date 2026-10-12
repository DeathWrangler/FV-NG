package Managers.Crafting
{
   import Classes.ZItem.FarmItem;
   import Classes.crafting.CraftingState;
   import Classes.crafting.RecipeItem;
   
   public class VillageResourceBuildingRecipeQueueManager extends CraftshopRecipeQueueManager
   {
      
      public function VillageResourceBuildingRecipeQueueManager(craftType:String)
      {
         super(craftType);
      }
      
      override public function endFinishedRecipesClaimed(result:Object, recipeId:String, tCallback:Function = null, fCallback:Function = null) : void
      {
         var giftsToAdd:int = 0;
         var item:FarmItem = null;
         var recipeItem:RecipeItem = Global.craftConfigSettings.getRecipeById(recipeId);
         var recipeXML:XML = Global.craftConfigSettings.getRecipeXml(recipeId);
         var ovenSlot:int = CraftingState.OVEN_SLOT_DEAFULT;
         if(Boolean(result[0]) && Boolean(result[0].hasOwnProperty("ovenSlot")))
         {
            ovenSlot = int(result[0].ovenSlot);
         }
         Global.player.craftingState.onEndFinishedRecipesClaimedForCraftType(CraftingConstants.VILLAGE_RESOURCE_BUILDING_SKILL,recipeItem,ovenSlot);
         var rewardRecipe:Object = null;
         if(result)
         {
            rewardRecipe = result[0];
            if(Boolean(!grantModernRewards(recipeXML) && rewardRecipe) && Boolean(rewardRecipe.hasOwnProperty("productItemCode")) && rewardRecipe.hasOwnProperty("numGiftProducts"))
            {
               giftsToAdd = int(rewardRecipe.numGiftProducts);
               item = Global.farmGameSettingsManager.getFarmItemByCode(rewardRecipe.productItemCode);
               if(Boolean(item) && CraftingManager.GIFTBOX_BLACKLIST_CLASSNAMES.indexOf(item.className) == -1)
               {
                  Global.player.addGift(item.name,"0",giftsToAdd);
               }
            }
         }
         if(tCallback != null)
         {
            tCallback(result);
         }
      }
   }
}

