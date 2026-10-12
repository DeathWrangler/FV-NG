package Managers.Crafting
{
   import Classes.crafting.CraftingState;
   import Classes.crafting.RecipeItem;
   import Display.UI;
   import Managers.HangingGardensManager;
   import Widgets.Windows.Crafting.HangingGardensCraftingShopRewardWindow;
   import Widgets.Windows.Crafting.ThreeRewardDialog;
   import flash.utils.getDefinitionByName;
   
   public class PizzashopRecipeQueueManager extends CraftshopRecipeQueueManager
   {
      
      private static var m_classCompilingArray:Array = [ThreeRewardDialog,HangingGardensCraftingShopRewardWindow];
      
      public function PizzashopRecipeQueueManager(craftType:String)
      {
         super(craftType);
      }
      
      override public function endFinishedRecipesClaimed(result:Object, recipeId:String, tCallback:Function = null, fCallback:Function = null) : void
      {
         var ovenSlot:int = 0;
         var recipeItem:RecipeItem = Global.craftConfigSettings.getRecipeById(recipeId);
         var recipeXML:XML = Global.craftConfigSettings.getRecipeXml(recipeId);
         if(HangingGardensManager.isInHangingGardensExperiment() && Boolean(Global.flashHotParams["HANGING_GARDENS_CRAFTSHOP"]))
         {
            ovenSlot = CraftingState.OVEN_SLOT_DEAFULT;
            if((Boolean(result[0]) || Boolean(result[0].hasOwnProperty("ovenSlot"))) && result.length == 1)
            {
               ovenSlot = int(result[0].ovenSlot);
            }
            Global.player.craftingState.onEndFinishedRecipesClaimedForCraftType(m_craftType,recipeItem,ovenSlot);
         }
         else
         {
            Global.player.craftingState.onEndFinishedRecipesClaimedForCraftType(m_craftType,recipeItem);
         }
         grantModernRewards(recipeXML);
         if(tCallback != null)
         {
            tCallback(result);
         }
         this.displayRewardDialog(recipeItem,fCallback);
      }
      
      public function displayRewardDialog(recipeItem:RecipeItem, fCallback:Function) : void
      {
         var dialogClassName:String = null;
         var dialogClass:Class = null;
         var rewardDialog:* = undefined;
         var dialogConfig:Object = Global.craftConfigSettings.getCottageItemForSkill(recipeItem.craft).getDialogConfig("reward");
         if(dialogConfig)
         {
            dialogClassName = dialogConfig.className;
            dialogClass = getDefinitionByName(dialogClassName) as Class;
            rewardDialog = new dialogClass(dialogConfig.path,recipeItem,fCallback);
            UI.displayPopup(rewardDialog,false);
         }
      }
   }
}

