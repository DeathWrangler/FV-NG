package Classes.Quest.helperactions
{
   import Classes.Constants.Experiments;
   import Classes.CraftingCottageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Display.CraftingUI;
   import Display.UI;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   
   public class CraftingHelperAction extends QuestHelperAction
   {
      
      private static const ACT_OPEN_CRAFTING_UI:int = 100;
      
      private static const ACT_OPEN_GIFTBOX:int = 101;
      
      private static const ACT_OPEN_MARKET:int = 102;
      
      private static const ACT_OPEN_CRAFT_SHOP:int = 103;
      
      private var m_recipeId:String = null;
      
      public function CraftingHelperAction(questName:String, recipeId:String)
      {
         super(questName);
         this.m_recipeId = recipeId;
         m_shouldCloseOnPerform = true;
      }
      
      private function whichAction() : int
      {
         var cottageName:String = null;
         var code:String = null;
         var numOwned:int = 0;
         var result:int = ACT_OPEN_MARKET;
         var cottage:CraftingCottageBuilding = CraftingManager.getInstance().getCottageByRecipe(this.m_recipeId);
         var recipeItem:RecipeItem = Global.craftConfigSettings.getRecipeById(this.m_recipeId);
         if(Boolean(cottage) && CraftingManager.getInstance().hasPlacedCraftingCottage(cottage.craftType))
         {
            result = ACT_OPEN_CRAFTING_UI;
         }
         else if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MINIRECIPE_WINDOW) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START && recipeItem != null && recipeItem.craft == CraftingConstants.CRAFTSHOP_SKILL)
         {
            result = ACT_OPEN_CRAFT_SHOP;
         }
         else
         {
            cottageName = Global.craftConfigSettings.getCottageItemNameForSkill(recipeItem.craft);
            code = Global.farmGameSettingsManager.getFarmItemCodeByName(cottageName);
            numOwned = Global.player.getGiftCountForItemKey(code);
            if(numOwned > 0)
            {
               result = ACT_OPEN_GIFTBOX;
            }
            else
            {
               result = ACT_OPEN_MARKET;
            }
         }
         return result;
      }
      
      override public function perform() : void
      {
         var cottage:CraftingCottageBuilding = null;
         var craftShopName:String = null;
         super.perform();
         var recipeItem:RecipeItem = null;
         var cottageItem:FarmItem = null;
         var cottageName:String = null;
         var action:int = this.whichAction();
         switch(action)
         {
            case ACT_OPEN_CRAFTING_UI:
               cottage = CraftingManager.getInstance().getCottageByRecipe(this.m_recipeId);
               recipeItem = Global.craftConfigSettings.getRecipeById(this.m_recipeId);
               CraftingUI.displayCraftingMainWindow(cottage,0,recipeItem.friendlyTitle.toLowerCase());
               break;
            case ACT_OPEN_GIFTBOX:
               recipeItem = Global.craftConfigSettings.getRecipeById(this.m_recipeId);
               cottageItem = Global.craftConfigSettings.getCottageItemForSkill(recipeItem.craft);
               UI.displayGiftBoxWindow(false,cottageItem.friendlyTitle);
               break;
            case ACT_OPEN_CRAFT_SHOP:
               craftShopName = CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType);
               CraftingManager.getInstance().openCraftingUiForRecipe(this.m_recipeId,craftShopName);
               break;
            case ACT_OPEN_MARKET:
            default:
               recipeItem = Global.craftConfigSettings.getRecipeById(this.m_recipeId);
               cottageName = Global.craftConfigSettings.getCottageItemNameForSkill(recipeItem.craft);
               UI.displayMiniMarketDialog([cottageName]);
         }
      }
      
      override public function get readableText() : String
      {
         var result:String = null;
         var recipeItem:RecipeItem = null;
         var cottageItem:FarmItem = null;
         var action:int = this.whichAction();
         switch(action)
         {
            case ACT_OPEN_CRAFTING_UI:
            case ACT_OPEN_CRAFT_SHOP:
               result = ZLocUtils.t("Quests","Helper_OpenCrafting_Button");
               break;
            case ACT_OPEN_GIFTBOX:
               result = ZLocUtils.t("Quests","Helper_Giftbox_Button");
               break;
            case ACT_OPEN_MARKET:
            default:
               recipeItem = Global.craftConfigSettings.getRecipeById(this.m_recipeId);
               cottageItem = Global.craftConfigSettings.getCottageItemForSkill(recipeItem.craft);
               result = ZLocUtils.getZLocString("Quests",m_questName + "Helper_" + recipeItem.craft,"Helper_OpenMarket","Button",{"item":ZLocUtils.tk_pk(cottageItem.friendlyName)});
         }
         return result;
      }
   }
}

