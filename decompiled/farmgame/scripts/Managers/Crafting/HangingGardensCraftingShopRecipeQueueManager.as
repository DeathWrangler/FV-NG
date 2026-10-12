package Managers.Crafting
{
   import Classes.HangingGardensCraftingShopBuilding;
   import Classes.crafting.RecipeItem;
   import Display.UI;
   import Widgets.Windows.Crafting.HangingGardensCraftingShopRewardWindow;
   
   public class HangingGardensCraftingShopRecipeQueueManager extends PizzashopRecipeQueueManager
   {
      
      public static const NUM_UNLOCK_SLOT_2:int = 2;
      
      public static const NUM_UNLOCK_SLOT_3:int = 14;
      
      public static const NUM_UNLOCK_SLOT_4:int = 50;
      
      public static const NUM_UNLOCK_SLOT_5:int = 138;
      
      public static const UNLOCK_PREFIX:String = "NUM_UNLOCK_SLOT_";
      
      private var m_recipeQueue:Array = new Array();
      
      public function HangingGardensCraftingShopRecipeQueueManager(craftType:String)
      {
         super(craftType);
      }
      
      override public function get recipeQueue() : Array
      {
         var nullRecipeItem:RecipeItem = null;
         var fullQueue:Array = new Array();
         var recipesInQueue:Array = Global.player.craftingState.getRecipeQueueForCraftType(this.m_craftType);
         var slots:Array = Global.craftConfigSettings.getSlotLevelsByType(m_craftType);
         for(var i:int = 0; i < recipesInQueue.length; i++)
         {
            fullQueue.push(recipesInQueue[i]);
         }
         while(fullQueue.length < slots.length)
         {
            nullRecipeItem = new RecipeItem();
            fullQueue.push(nullRecipeItem);
         }
         return fullQueue;
      }
      
      override public function displayRewardDialog(recipeItem:RecipeItem, fCallback:Function) : void
      {
         if(!this.expandSlotByCompletingRecipes(recipeItem,fCallback))
         {
            super.displayRewardDialog(recipeItem,fCallback);
         }
      }
      
      public function expandSlotByCompletingRecipes(recipeItem:RecipeItem, fCallback:Function) : Boolean
      {
         var upgradeLevel:String = null;
         var unlockConst:String = null;
         var unlockRecipesNeeded:int = 0;
         var totalNumRecipesCompleted:int = 0;
         var dialog:HangingGardensCraftingShopRewardWindow = null;
         var showedDialog:Boolean = false;
         var buildings:Array = Global.world.getObjectsByClass(HangingGardensCraftingShopBuilding);
         var hangingGardensCraftShopBuilding:HangingGardensCraftingShopBuilding = buildings[0] as HangingGardensCraftingShopBuilding;
         if(hangingGardensCraftShopBuilding.hasNextExpansion())
         {
            upgradeLevel = hangingGardensCraftShopBuilding.getNextExpansionLevel().toString();
            unlockConst = UNLOCK_PREFIX + upgradeLevel;
            unlockRecipesNeeded = int(HangingGardensCraftingShopRecipeQueueManager[unlockConst]);
            totalNumRecipesCompleted = Global.player.craftingState.getNumOfRecipesToCompleteByType(CraftingConstants.HANGING_GARDENS_CRAFTINGSHOP_SKILL);
            if(totalNumRecipesCompleted >= unlockRecipesNeeded)
            {
               hangingGardensCraftShopBuilding.expandWithoutCash();
               dialog = new HangingGardensCraftingShopRewardWindow(null,recipeItem,fCallback,HangingGardensCraftingShopRewardWindow.EXPAND_SLOT_REWARD_TYPE);
               UI.displayPopup(dialog,false);
               showedDialog = true;
            }
         }
         return showedDialog;
      }
   }
}

