package Classes.MOTD
{
   import Classes.Constants.Experiments;
   import Classes.ConstructionBuilding;
   import Classes.FeatureBuilding;
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Display.DataDrivenOkayPopup;
   import Display.UI;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   
   public class CraftingV2MOTDHandler extends MOTDHandler
   {
      
      private static const ONBOARD_DIALOG_FLOW_0_URL:String = "assets/dialogs/4d_elements/Crafting/craftingv2_onboarding_0.png";
      
      private static const ONBOARD_DIALOG_FLOW_1_URL:String = "assets/dialogs/4d_elements/Crafting/craftingv2_onboarding_1.png";
      
      private static const ONBOARD_DIALOG_FLOW_2_URL:String = "assets/dialogs/4d_elements/Crafting/craftingv2_onboarding_2.png";
      
      private static const USER_FLOW_COMPLETED_BUILDING:Number = 0;
      
      private static const USER_FLOW_CONSTRUCT_BUILDING:Number = 1;
      
      private static const USER_FLOW_CONSTRUCT_GIFTBOX:Number = 2;
      
      private static const USER_FLOW_NO_BUILDING:Number = 3;
      
      public function CraftingV2MOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override public function execute() : void
      {
         var finishedCraftWorkshop:FeatureBuilding = null;
         var allRecipes:Array = null;
         var recipeItem:RecipeItem = null;
         var ingredient:Object = null;
         var recipesGranted:int = 0;
         var beginOOS_itemsStr:String = null;
         var craftWorkshop:ConstructionBuilding = null;
         var imageUrl:String = "";
         var title:String = "";
         var text:String = "";
         var buttonText:String = "";
         var cancelButtonText:String = "";
         var flowPrefix:String = "";
         var finishedItems:Array = Global.world.getObjectsByName("craftingworkshop_finished");
         var constructionItems:Array = Global.world.getObjectsByName("craftingworkshop");
         var giftConstructionItems:Number = Global.player.getGiftCountForItem("craftingworkshop");
         if(finishedItems.length > 0)
         {
            recipesGranted = 0;
            m_callbackData.userFlow = USER_FLOW_COMPLETED_BUILDING;
            flowPrefix = "Flow_0";
            imageUrl = ONBOARD_DIALOG_FLOW_0_URL;
            finishedCraftWorkshop = finishedItems[0] as FeatureBuilding;
            if(finishedCraftWorkshop)
            {
               finishedCraftWorkshop.displayStorageDialog();
               allRecipes = Global.craftConfigSettings.getAllRecipes(CraftingConstants.CRAFTSHOP_SKILL);
               for each(recipeItem in allRecipes)
               {
                  if(CraftingManager.getInstance().isRecipeAvailable(recipeItem.id))
                  {
                     if(recipesGranted < CraftingConstants.ON_MOTD_RECIPE_INGREDIENTS_GRANTED)
                     {
                        for each(ingredient in recipeItem.ingredients)
                        {
                           CraftingManager.getInstance().addItemToInventory(ingredient.itemCode,ingredient.quantityRequired);
                           if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CRAFTING_OOS_STATS) > 0)
                           {
                              beginOOS_itemsStr = "item_" + ingredient.itemCode + ":" + ingredient.quantityRequired;
                              FarmStatsManager.count("beginOOS","client","add_V2MOTD",beginOOS_itemsStr);
                           }
                        }
                        recipesGranted++;
                     }
                  }
               }
            }
         }
         else if(constructionItems.length > 0)
         {
            m_callbackData.userFlow = USER_FLOW_CONSTRUCT_BUILDING;
            Global.player.addGift("concrete","0",3);
            Global.player.addGift("hammer","0",3);
            Global.player.addGift("crafting_twine","0",3);
            flowPrefix = "Flow_1";
            imageUrl = ONBOARD_DIALOG_FLOW_1_URL;
            craftWorkshop = constructionItems[0] as ConstructionBuilding;
            if(craftWorkshop)
            {
               craftWorkshop.displayStorageDialog();
            }
         }
         else if(giftConstructionItems > 0)
         {
            m_callbackData.userFlow = USER_FLOW_CONSTRUCT_GIFTBOX;
            m_callbackData.gift = "craftingworkshop";
            flowPrefix = "Flow_2";
            imageUrl = ONBOARD_DIALOG_FLOW_2_URL;
         }
         else
         {
            m_callbackData.userFlow = USER_FLOW_NO_BUILDING;
            m_callbackData.gift = "craftingworkshop";
            Global.player.addGift(m_callbackData.gift);
            flowPrefix = "Flow_2";
            imageUrl = ONBOARD_DIALOG_FLOW_2_URL;
         }
         title = ZLocUtils.t("Dialogs","MOTD_craftingv2_" + flowPrefix + "_Title");
         text = ZLocUtils.t("Dialogs","MOTD_craftingv2_" + flowPrefix + "_Text");
         buttonText = ZLocUtils.t("Dialogs","MOTD_craftingv2_" + flowPrefix + "_ButtonText");
         cancelButtonText = ZLocUtils.t("Dialogs","MOTD_craftingv2_" + flowPrefix + "_CancelButtonText");
         var params:Array = [imageUrl,text,title,buttonText];
         var displayPopup:DataDrivenOkayPopup = new DataDrivenOkayPopup(MOTD_DIALOG_NAME_NO_CANCEL,params,this.acceptMOTD);
         UI.displayPopup(displayPopup,false);
         super.execute();
      }
      
      override protected function acceptMOTD() : void
      {
         super.acceptMOTD();
         switch(m_callbackData.userFlow)
         {
            case USER_FLOW_NO_BUILDING:
            case USER_FLOW_CONSTRUCT_GIFTBOX:
               Global.world.enterForcePlaceMode(m_callbackData.gift,true);
               break;
            case USER_FLOW_CONSTRUCT_BUILDING:
            case USER_FLOW_COMPLETED_BUILDING:
         }
      }
   }
}

