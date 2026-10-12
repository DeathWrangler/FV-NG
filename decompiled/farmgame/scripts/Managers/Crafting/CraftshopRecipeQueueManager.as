package Managers.Crafting
{
   import Classes.ZItem.FarmItem;
   import Classes.crafting.CraftingState;
   import Classes.crafting.RecipeItem;
   import Classes.util.UserRewardUtil;
   import Managers.HangingGardensManager;
   
   public class CraftshopRecipeQueueManager extends CraftingRecipeQueueManager
   {
      
      public function CraftshopRecipeQueueManager(craftType:String)
      {
         super(craftType);
      }
      
      override public function get recipeQueue() : Array
      {
         var nullRecipeItem:RecipeItem = null;
         var fullQueue:Array = [];
         var recipesInQueue:Array = Global.player.craftingState.getRecipeQueueForCraftType(this.m_craftType);
         for(var i:int = 0; i < recipesInQueue.length; i++)
         {
            if((recipesInQueue[i] as RecipeItem).worldType == Global.worldManager.currentWorldType)
            {
               fullQueue.push(recipesInQueue[i]);
            }
         }
         while(fullQueue.length < 1)
         {
            nullRecipeItem = new RecipeItem();
            fullQueue.push(nullRecipeItem);
         }
         return fullQueue;
      }
      
      override public function beginRecipe(recipeItem:RecipeItem, ignoreServerCheck:Boolean = false) : void
      {
         Global.player.craftingState.beginRecipeForCraftType(m_craftType,recipeItem,ignoreServerCheck);
      }
      
      override public function onRecipeBegun(tResult:Object) : void
      {
         var recipeItem:RecipeItem = RecipeItem.fromPhpObject(tResult);
         Global.player.craftingState.onRecipeBegunForCraftType(m_craftType,recipeItem);
      }
      
      protected function grantModernRewards(recipeXML:XML) : Boolean
      {
         var rewardsList:XMLList = null;
         var result:Boolean = false;
         if(Boolean(recipeXML.Reward) && Boolean(recipeXML.Reward.OnFinish) && Boolean(recipeXML.Reward.OnFinish.rewards))
         {
            rewardsList = recipeXML.Reward.OnFinish.rewards;
            if(rewardsList.length() > 0)
            {
               UserRewardUtil.grantUserRewardsFromXml(rewardsList[0]);
               result = true;
            }
         }
         return result;
      }
      
      override public function endFinishedRecipesClaimed(result:Object, recipeId:String, tCallback:Function = null, fCallback:Function = null) : void
      {
         var ovenSlot:int = 0;
         var giftsToAdd:int = 0;
         var item:FarmItem = null;
         var recipeItem:RecipeItem = Global.craftConfigSettings.getRecipeById(recipeId);
         var recipeXML:XML = Global.craftConfigSettings.getRecipeXml(recipeId);
         if(HangingGardensManager.isInHangingGardensExperiment() && Boolean(Global.flashHotParams["HANGING_GARDENS_CRAFTSHOP"]))
         {
            ovenSlot = CraftingState.OVEN_SLOT_DEAFULT;
            if((Boolean(result[0]) || Boolean(result[0].hasOwnProperty("ovenSlot"))) && result.length == 1)
            {
               ovenSlot = int(result[0].ovenSlot);
            }
            Global.player.craftingState.onEndFinishedRecipesClaimedForCraftType(CraftingConstants.CRAFTSHOP_SKILL,recipeItem,ovenSlot);
         }
         else
         {
            Global.player.craftingState.onEndFinishedRecipesClaimedForCraftType(CraftingConstants.CRAFTSHOP_SKILL,recipeItem);
         }
         var rewardRecipe:Object = null;
         var postFeed:Boolean = false;
         if(result[0])
         {
            rewardRecipe = result[0];
            if(rewardRecipe.hasOwnProperty("rewardLink"))
            {
               postFeed = true;
            }
            if(!this.grantModernRewards(recipeXML))
            {
               if(rewardRecipe.hasOwnProperty("productItemCode") && rewardRecipe.hasOwnProperty("numGiftProducts"))
               {
                  giftsToAdd = int(rewardRecipe.numGiftProducts);
                  item = Global.farmGameSettingsManager.getFarmItemByCode(rewardRecipe.productItemCode);
                  if(Boolean(item) && CraftingManager.GIFTBOX_BLACKLIST_CLASSNAMES.indexOf(item.className) == -1)
                  {
                     Global.player.addGift(item.name,"0",giftsToAdd);
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

