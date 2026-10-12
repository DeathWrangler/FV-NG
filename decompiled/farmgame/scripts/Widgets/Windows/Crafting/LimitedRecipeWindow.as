package Widgets.Windows.Crafting
{
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   
   public class LimitedRecipeWindow extends FarmWindow
   {
      
      protected static const POPUP_NAME:String = "leRecipeExpire";
      
      public static const MAX_NUM_INGREDIENTS:int = 3;
      
      protected static const DEFAULT_LE_ICON_HEIGHT:int = 35;
      
      protected static const DEFAULT_LE_ICON_WIDTH:int = 35;
      
      protected static const DEFAULT_INGRED_ICON_HEIGHT:int = 50;
      
      protected static const DEFAULT_INGRED_ICON_WIDTH:int = 50;
      
      protected static const DEFAULT_RECIPE_ICON_HEIGHT:int = 70;
      
      protected static const DEFAULT_RECIPE_ICON_WIDTH:int = 70;
      
      protected static const DEFAULT_MASTERY_ICON_HEIGHT:int = 160;
      
      protected static const DEFAULT_MASTERY_ICON_WIDTH:int = 100;
      
      protected static const DEFAULT_MASTERY_SIGN_LEVEL:Number = 5;
      
      protected var DIALOG_ASSET:String = "assets/dialogs/FV_Craft_LE_Onboard.swf";
      
      protected var m_limitedRecipe:RecipeItem;
      
      protected var m_isOnboarding:Boolean;
      
      public function LimitedRecipeWindow(limitedRecipe:RecipeItem, isOnboarding:Boolean)
      {
         super(this.DIALOG_ASSET);
         this.name = POPUP_NAME;
         this.m_limitedRecipe = limitedRecipe;
         this.m_isOnboarding = isOnboarding;
      }
      
      override protected function postLoadComplete() : void
      {
         var slotFull:MovieClip = null;
         var ingredFrame:ZwFrame = null;
         var slotEmpty:MovieClip = null;
         var slotEmptyFrame:ZwFrame = null;
         super.postLoadComplete();
         if(this.m_isOnboarding)
         {
            addWidget(new ZwFrame(m_window.frame_Default_mc));
            addWidget(new ZwTextField(m_window.frame_Default_mc.generic_tf,ZLocUtils.t("Crafting","LimitedRecipes_Onboard_TitleField")));
            addWidget(new ZwTextField(m_window.frame_Default_mc.generic2_tf,ZLocUtils.t("Crafting","LimitedRecipes_Onboard_BodyField")));
            this.markNewLimitedRecipesAsSeen(this.m_limitedRecipe.craft);
         }
         else
         {
            addWidget(new ZwFrame(m_window.frame_Expire_mc));
            addWidget(new ZwTextField(m_window.frame_Expire_mc.generic_tf,ZLocUtils.t("Crafting","LimitedRecipes_Expires_TitleField")));
            addWidget(new ZwTextField(m_window.frame_Expire_mc.generic2_tf,ZLocUtils.t("Crafting","LimitedRecipes_Expires_Date",{"dateStr":this.m_limitedRecipe.limitedEndDate})));
            addWidget(new ZwTextField(m_window.frame_Expire_mc.generic3_tf,ZLocUtils.t("Crafting","LimitedRecipes_Expires_BodyField")));
            this.markExpiringRecipesAsSeen(this.m_limitedRecipe.craft);
         }
         var masteryIcon:FarmIcon = new FarmIcon(m_window.masterySign_mc);
         masteryIcon.loadIcon(CraftingManager.getInstance().getMasterySignIcon(this.m_limitedRecipe,DEFAULT_MASTERY_SIGN_LEVEL));
         masteryIcon.visible = true;
         masteryIcon.setIconSize(DEFAULT_MASTERY_ICON_WIDTH,DEFAULT_MASTERY_ICON_HEIGHT);
         masteryIcon.detachTooltip();
         masteryIcon.attachTooltip(new FarmTextTooltip(ZLocUtils.tk_pk_asTitle(this.m_limitedRecipe.friendlyName)));
         m_window.masterySign_mc.scaleX = -1;
         m_window.masterySign_mc.x += DEFAULT_MASTERY_ICON_WIDTH;
         addWidget(masteryIcon);
         addWidget(new ZwFrame(m_window.slot_0_mc));
         addWidget(new ZwFrame(m_window.slot_0_mc.celBackgroundLE_mc));
         switch(this.m_limitedRecipe.craft)
         {
            case CraftingConstants.BAKERY_SKILL:
               addWidget(new ZwFrame(m_window.backgroundBakery_mc));
               break;
            case CraftingConstants.PERFUMERY_SKILL:
               addWidget(new ZwFrame(m_window.backgroundSpa_mc));
               break;
            case CraftingConstants.WINERY_SKILL:
               addWidget(new ZwFrame(m_window.backgroundWinery_mc));
         }
         var itemIcon:FarmIcon = new FarmIcon(m_window.slot_0_mc.icon_mc);
         itemIcon.loadIcon(this.m_limitedRecipe.image70);
         itemIcon.visible = true;
         itemIcon.setIconSize(DEFAULT_RECIPE_ICON_WIDTH,DEFAULT_RECIPE_ICON_HEIGHT);
         itemIcon.detachTooltip();
         itemIcon.attachTooltip(new FarmTextTooltip(ZLocUtils.tk_pk_asTitle(this.m_limitedRecipe.friendlyName)));
         addWidget(itemIcon);
         addWidget(new ZwTextField(m_window.slot_0_mc.recipeName_tf,ZLocUtils.tk_pk_asTitle(this.m_limitedRecipe.friendlyName)));
         for(var ingredIndex:Number = 0; ingredIndex < MAX_NUM_INGREDIENTS; ingredIndex++)
         {
            slotFull = m_window.slot_0_mc["recipeSlotFull" + (ingredIndex + 1) + "_mc"];
            ingredFrame = new ZwFrame(slotFull);
            addWidget(ingredFrame);
            ingredFrame.addWidget(new FarmIcon(slotFull.icon_mc));
            ingredFrame.addWidget(new ZwTextField(slotFull.generic_tf));
            ingredFrame.addWidget(new FarmIcon(slotFull.le_icon_mc));
            slotEmpty = m_window.slot_0_mc["recipeSlotEmpty" + (ingredIndex + 1) + "_mc"];
            slotEmptyFrame = new ZwFrame(slotEmpty);
            addWidget(slotEmptyFrame);
         }
         addWidget(new FarmAnimatedButton(m_window.okay_bt,onClose));
         this.populate();
      }
      
      private function populate() : void
      {
         var newIngredient:Object = null;
         var slotFull:MovieClip = null;
         var ingredientItem:FarmItem = null;
         var ingredientSlot:ZwFrame = null;
         var itemIcon:FarmIcon = null;
         var leIcon:FarmIcon = null;
         var ingredTextField:ZwTextField = null;
         var slotEmpty:MovieClip = null;
         var slotEmptyFrame:ZwFrame = null;
         var index:Number = NaN;
         var slotFull2:MovieClip = null;
         var ingredientSlot2:ZwFrame = null;
         for(var ingredIndex:Number = 0; ingredIndex < this.m_limitedRecipe.ingredients.length; ingredIndex++)
         {
            newIngredient = this.m_limitedRecipe.ingredients[ingredIndex];
            if(newIngredient)
            {
               slotFull = m_window.slot_0_mc["recipeSlotFull" + (ingredIndex + 1) + "_mc"];
               ingredientItem = Global.farmGameSettingsManager.getFarmItemByCode(newIngredient.itemCode);
               ingredientSlot = getWidget(slotFull) as ZwFrame;
               itemIcon = ingredientSlot.getWidget(slotFull.icon_mc) as FarmIcon;
               itemIcon.loadIcon(ingredientItem.icon);
               itemIcon.visible = true;
               itemIcon.setIconSize(DEFAULT_INGRED_ICON_WIDTH,DEFAULT_INGRED_ICON_HEIGHT);
               itemIcon.detachTooltip();
               itemIcon.attachTooltip(new FarmTextTooltip(ZLocUtils.tk_pk_asTitle(ingredientItem.friendlyName)));
               leIcon = ingredientSlot.getWidget(slotFull.le_icon_mc) as FarmIcon;
               leIcon.loadIcon(ingredientItem.getLimitedIcon());
               leIcon.visible = true;
               leIcon.setIconSize(DEFAULT_LE_ICON_WIDTH,DEFAULT_LE_ICON_HEIGHT);
               ingredTextField = ingredientSlot.getWidget(slotFull.generic_tf) as ZwTextField;
               ingredTextField.text = ZLocUtils.tk_pk_asTitle(ingredientItem.friendlyName);
               slotEmpty = m_window.slot_0_mc["recipeSlotEmpty" + (ingredIndex + 1) + "_mc"];
               slotEmptyFrame = getWidget(slotEmpty) as ZwFrame;
               slotEmptyFrame.visible = false;
            }
         }
         if(this.m_limitedRecipe.ingredients.length < MAX_NUM_INGREDIENTS)
         {
            for(index = this.m_limitedRecipe.ingredients.length; index < MAX_NUM_INGREDIENTS; index++)
            {
               slotFull2 = m_window.slot_0_mc["recipeSlotFull" + (index + 1) + "_mc"];
               ingredientSlot2 = getWidget(slotFull2) as ZwFrame;
               ingredientSlot2.visible = false;
            }
         }
      }
      
      private function markNewLimitedRecipesAsSeen(craftType:String) : void
      {
         var recipe:RecipeItem = null;
         var newRecipes:Array = CraftingManager.getInstance().getNewLimitedRecipes(this.m_limitedRecipe.craft);
         var seenFlag:String = "";
         for each(recipe in newRecipes)
         {
            seenFlag = CraftingConstants.NEW_LIMITED_RECIPE_SEEN_FLAG_PREFIX + recipe.id;
            Global.player.setSeenFlag(seenFlag);
         }
      }
      
      private function markExpiringRecipesAsSeen(craftType:String) : void
      {
         var recipe:RecipeItem = null;
         var expiringRecipes:Array = CraftingManager.getInstance().getExpiringRecipes(this.m_limitedRecipe.craft);
         var seenFlag:String = "";
         for each(recipe in expiringRecipes)
         {
            seenFlag = CraftingConstants.EXPIRING_RECIPE_SEEN_FLAG_PREFIX + recipe.id;
            Global.player.setSeenFlag(seenFlag);
         }
      }
   }
}

