package Widgets.Windows.Crafting
{
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.crafting.RecipeState;
   import Classes.util.ZLocUtils;
   import Display.CraftingUI;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Crafting.ShoppingListIngredientSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class ShoppingListWindow extends FarmWindow
   {
      
      private static const ICON_SIZE:int = 70;
      
      private static const ICON_OFFSET_X:int = 30;
      
      private static const ICON_OFFSET_Y:int = 10;
      
      private var m_currentCapacity:ZwTextField;
      
      private var m_recipe:RecipeItem;
      
      private var m_recipeNameTextField:ZwTextField;
      
      private var m_recipeLevelTextField:ZwTextField;
      
      private var m_recipeIngredientsSlotFrame:ShoppingListIngredientSlotFrame;
      
      private var m_genericGoods:Boolean;
      
      public function ShoppingListWindow(recipe:RecipeItem, useShortView:Boolean = false, genericGoods:Boolean = false)
      {
         super(useShortView ? "assets/dialogs/FV_Craft_ShoppingList_short.swf" : "assets/dialogs/FV_Craft_ShoppingList.swf");
         this.m_recipe = recipe;
         this.m_genericGoods = genericGoods;
      }
      
      override protected function postLoadComplete() : void
      {
         var maxCapacity:int = 0;
         var currentCapacity:int = 0;
         var recipeState:RecipeState = null;
         var recipeLevel:int = 0;
         var progressToNextLevel:Number = NaN;
         var progressMeter:ZwFrame = null;
         var progressBar:ZwWidget = null;
         if(this.m_genericGoods)
         {
            maxCapacity = Global.player.craftingState.inventoryState.craftingSiloMaxCapacity;
            currentCapacity = Global.player.craftingState.inventoryState.craftingSiloCurrentCapacity;
         }
         else
         {
            maxCapacity = Global.player.craftingState.inventoryState.maxCapacity;
            currentCapacity = Global.player.craftingState.inventoryState.currentCapacity;
         }
         addWidget(new ZwTextField(m_window.capacity_tf,ZLocUtils.t("Crafting","ShoppingListDialog_MaxCapacity",{"quantity":maxCapacity})));
         this.m_currentCapacity = new ZwTextField(m_window.current_tf,ZLocUtils.t("Crafting","ShoppingListDialog_CurrentCapacity",{"quantity":currentCapacity}));
         addWidget(this.m_currentCapacity);
         addWidget(new ZwTextField(m_window.shoppingList_tf,ZLocUtils.t("Crafting","ShoppingListDialog_Title")));
         this.m_recipeNameTextField = addWidget(new ZwTextField(m_window.recipeName_tf,ZLocUtils.tk_pk_asTitle("Items:" + this.m_recipe.name + "_friendlyName"))) as ZwTextField;
         var icon:FarmIcon = new FarmIcon(m_window.icon_mc);
         addWidget(icon);
         icon.setIconSize(ICON_SIZE,ICON_SIZE);
         icon.x += ICON_OFFSET_X;
         icon.y += ICON_OFFSET_Y;
         icon.loadIcon(this.m_recipe.image);
         icon.setIconSize(70,70);
         icon.setSmoothing(true);
         if(!this.m_genericGoods)
         {
            recipeState = Global.player.craftingState.craftingSkillState.getRecipeStateById(this.m_recipe.id);
            recipeLevel = recipeState.level;
            this.m_recipeLevelTextField = addWidget(new ZwTextField(m_window.level_tf,ZLocUtils.t("Crafting","CraftingCottages_Level2",{"quantity":recipeLevel.toString()}))) as ZwTextField;
            progressToNextLevel = recipeState.getFractionalProgessToNextLevel() % 1;
            progressMeter = addWidget(new ZwFrame(m_window.meterRecipeUpgrade)) as ZwFrame;
            progressBar = progressMeter.addWidget(new ZwWidget(m_window.meterRecipeUpgrade.bar_mc)) as ZwWidget;
            progressBar.element.scaleY = progressToNextLevel;
         }
         this.m_recipeIngredientsSlotFrame = addWidget(new ShoppingListIngredientSlotFrame(m_window.ingredientSlots_mc,this.m_recipe,this.onGetItem,this.onAskForItem,this.onViewInventory,this.onBuyItem)) as ShoppingListIngredientSlotFrame;
         addWidget(new FarmAnimatedTextButton(m_window.buyAll_mc,ZLocUtils.t("Crafting","ShoppingListDialog_BuyAllButton"),this.onBuyAllButtonClick)) as FarmAnimatedButton;
         var isInTutorial:Boolean = Boolean(CraftingUI.getCraftingMainWindow()) && CraftingManager.getInstance().inTutorialMode;
         var avatarMessageFrame:ZwFrame = addWidget(new ZwFrame(m_window.avatarMessage_mc),!isInTutorial) as ZwFrame;
         avatarMessageFrame.addWidget(new ZwTextField(m_window.avatarMessage_mc.generic1_tf,ZLocUtils.t("Crafting","ShoppingListDialog_DailyLimitInfo",{"quantity":Global.player.craftingState.shoppingState.maxBagsPerUser})));
         var useBushelInfoStringKey:String = this.m_genericGoods ? "ShoppingListDialog_UseBushelInfo_Generic" : "ShoppingListDialog_UseBushelInfo";
         avatarMessageFrame.addWidget(new ZwTextField(m_window.avatarMessage_mc.generic2_tf,ZLocUtils.t("Crafting",useBushelInfoStringKey)));
         FarmStatsManager.count("cottage_ui_new","shopping_list","view_shopping_list");
         if(isInTutorial)
         {
            enableInput = false;
            if(CraftingUI.getCraftingMainWindow().assertTutorialIndexIs(CraftingMainWindow.TUTORIAL_GET_BUSHELS))
            {
               CraftingUI.getCraftingMainWindow().displayTutorialMessage(CraftingMainWindow.TUTORIAL_SHOPPING_LIST);
               tintWindow();
            }
         }
      }
      
      public function get recipe() : RecipeItem
      {
         return this.m_recipe;
      }
      
      private function onBuyAllButtonClick(evt:Event) : void
      {
         CraftingManager.getInstance().beginPurchaseRecipeBundle(this.m_recipe,this.onBuyAllClose,this.onBuyAllPurchase);
         tintWindow();
         enableInput = false;
         FarmStatsManager.count("crafting_cottage","BuyRecipeIngredients",this.m_recipe.craft,this.m_recipe.name,"impressions");
      }
      
      private function onSocialMissionInProgressMessageClose(event:GenericPopupEvent) : void
      {
         enableInput = true;
      }
      
      private function onBuyAllClose(evt:Event = null) : void
      {
         untintWindow();
         enableInput = true;
      }
      
      private function onBuyAllPurchase(recipeId:String = null) : void
      {
         untintWindow();
         close();
      }
      
      private function onGetItem(uid:String, itemCode:String) : void
      {
         var thankYouFeedBundle:String = Global.craftConfigSettings.getThankYouFeedBundle(this.m_recipe.craft);
         CraftingUI.displayVisitingMarketStallWindow(uid,"bushels",this.onVisitingMarketStallWindowClose,thankYouFeedBundle,itemCode);
         tintWindow();
         enableInput = false;
         FarmStatsManager.count("cottage_ui_new","shopping_list","click_get_bushels_button");
      }
      
      private function onVisitingMarketStallWindowClose() : void
      {
         this.refresh();
      }
      
      private function onAskForItem(ingredientConfig:Object) : void
      {
         var bushelItem:FarmItem = null;
         var craftingManager:CraftingManager = null;
         var itemCode:String = ingredientConfig[RecipeItem.ITEM_CODE];
         if(itemCode)
         {
            bushelItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            if(bushelItem)
            {
               craftingManager = CraftingManager.getInstance();
               if(craftingManager.isIngredientGetByFeed(ingredientConfig))
               {
                  craftingManager.startGetByFeedIngredientFlow(this.m_recipe,ingredientConfig,this.onCloseAskForItem);
               }
               else if(craftingManager.getCraftTypeofBushel(itemCode) == CraftingManager.BUSHEL_TYPE_SILO)
               {
                  craftingManager.onNoBushelsAvailableShopping(itemCode,"silo",this.onCloseAskForItem,bushelItem.icon);
               }
               else
               {
                  craftingManager.onNoBushelsAvailableShopping(itemCode,this.m_recipe.craft,this.onCloseAskForItem);
               }
               enableInput = false;
               tintWindow();
               FarmStatsManager.count("cottage_ui_new","shopping_list","click_ask_for_bushels_button ");
            }
         }
      }
      
      private function onBuyItem(itemCode:String) : void
      {
         CraftingManager.getInstance().onPurchaseBushel(itemCode,this.m_recipe.id);
         this.refresh();
      }
      
      private function onCloseAskForItem(evt:Event = null) : void
      {
         this.refresh();
      }
      
      private function onViewInventory(inventoryType:String) : void
      {
         enableInput = false;
         switch(inventoryType)
         {
            case "silo":
               if(CraftingManager.getInstance().getCraftingSilosInWorld().length > 0)
               {
                  CraftingUI.displayCraftingSiloWindow(Global.player.craftingState.getCraftingSilo(),this.onViewInventoryWindowClose);
               }
               else
               {
                  UI.displayMessage(ZLocUtils.t("Crafting","ShoppingListDialog_NoCraftingStallsMessage"),GenericPopup.TYPE_OK,this.onNoMarketStallsMessageClose,"noMarketStallsMessage",true);
               }
               break;
            case "stall":
               if(CraftingManager.getInstance().getPlacedMarketStalls() > 0)
               {
                  CraftingUI.displayMarketStallWindow(Global.player.craftingState.getMarketStall(),false,this.onViewInventoryWindowClose);
               }
               else
               {
                  UI.displayMessage(ZLocUtils.t("Crafting","ShoppingListDialog_NoMarketStallsMessage"),GenericPopup.TYPE_OK,this.onNoMarketStallsMessageClose,"noMarketStallsMessage",true);
               }
         }
      }
      
      private function onViewInventoryWindowClose() : void
      {
         enableInput = true;
      }
      
      private function onNoMarketStallsMessageClose(event:GenericPopupEvent) : void
      {
         enableInput = true;
      }
      
      private function refresh() : void
      {
         var currentCapacity:int = 0;
         if(this.m_genericGoods)
         {
            currentCapacity = Global.player.craftingState.inventoryState.craftingSiloCurrentCapacity;
         }
         else
         {
            currentCapacity = Global.player.craftingState.inventoryState.currentCapacity;
         }
         this.m_currentCapacity.text = ZLocUtils.t("Crafting","ShoppingListDialog_CurrentCapacity",{"quantity":currentCapacity});
         this.m_recipeIngredientsSlotFrame.refresh();
         untintWindow();
         enableInput = true;
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_recipe = null;
         this.m_recipeNameTextField = null;
         this.m_recipeLevelTextField = null;
         this.m_recipeIngredientsSlotFrame = null;
      }
   }
}

