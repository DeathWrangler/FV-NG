package Widgets.Slots.Crafting
{
   import Classes.FeatureBuilding;
   import Classes.MarketStallBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.CraftingUI;
   import Managers.Crafting.CraftingManager;
   import Managers.Crafting.MarketViewManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Crafting.ShoppingListGetBushelSlotFrame;
   import Widgets.Frames.Crafting.ShoppingListIngredientSlotFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class ShoppingListIngredientSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 70;
      
      private static const ICON_OFFSET_X:int = 11;
      
      private static const ICON_OFFSET_Y:int = 11;
      
      private static const EXPERIMENT_FLASH_CRAFTING_BUY_BUSHELS:String = "fv_crafting_buy_bushels";
      
      private var m_ingredient:Object = null;
      
      private var m_getBushelsSlotFrame:ShoppingListGetBushelSlotFrame = null;
      
      private var m_messageFrame:ZwFrame = null;
      
      private var m_getItemCallback:Function;
      
      private var m_askForItemCallback:Function;
      
      private var m_viewInventoryCallback:Function;
      
      private var m_buyBushelCallback:Function;
      
      private var m_actionButton:FarmAnimatedTextButton = null;
      
      private var m_buyButton:FarmAnimatedCashButton = null;
      
      public function ShoppingListIngredientSlot(element:DisplayObject, getItemCallback:Function, askForItemCallback:Function, viewInventoryCallback:Function, buyBushelCallback:Function = null)
      {
         this.m_getItemCallback = getItemCallback;
         this.m_askForItemCallback = askForItemCallback;
         this.m_viewInventoryCallback = viewInventoryCallback;
         this.m_buyBushelCallback = buyBushelCallback;
         super(element);
         addWidget(new ZwTextField(m_element.generic1_tf));
         addWidget(new ZwTextField(m_element.generic2_tf));
         addWidget(new ZwWidget(m_element.checkMark_mc));
         this.m_getBushelsSlotFrame = addWidget(new ShoppingListGetBushelSlotFrame(m_element.get_mc,this.onGetItem)) as ShoppingListGetBushelSlotFrame;
         this.m_messageFrame = addWidget(new ZwFrame(m_element.ask_mc)) as ZwFrame;
         this.m_messageFrame.addWidget(new ZwTextField(m_element.ask_mc.generic_tf,""));
         this.m_actionButton = new FarmAnimatedTextButton(m_element.ask_mc.ask_bt,ZLocUtils.t("Crafting","ShoppingListDialog_AskButton"),this.onAskButtonClick);
         if(m_element.ask_mc.buy_bt != null)
         {
            this.m_buyButton = new FarmAnimatedCashButton(m_element.ask_mc.buy_bt,"Buy","1",this.onBuyButtonClick);
            this.m_messageFrame.addWidget(this.m_buyButton,false);
         }
         this.m_messageFrame.addWidget(this.m_actionButton,false);
         this.m_messageFrame.addWidget(new FarmAnimatedTextButton(m_element.ask_mc.viewInventory_bt,ZLocUtils.t("Crafting","ShoppingListDialog_ViewInventoryButton"),this.onViewInventoryButtonClick));
         var icon:FarmIcon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         icon.x += ICON_OFFSET_X;
         icon.y += ICON_OFFSET_Y;
         icon.setIconSize(ICON_SIZE,ICON_SIZE);
      }
      
      override public function populate(data:Object) : void
      {
         var ingredientItem:FarmItem = null;
         var numIngredients:int = 0;
         var quantityRequired:int = 0;
         var complete:Boolean = false;
         var nameTextField:ZwTextField = null;
         var amountTextField:ZwTextField = null;
         var iconFarmIcon:FarmIcon = null;
         var overLimit:Boolean = false;
         var marketStallFull:Boolean = false;
         var siloFull:Boolean = false;
         var shareableBushel:Boolean = false;
         var statusMessage:String = null;
         var marketStall:MarketStallBuilding = null;
         var silo:FeatureBuilding = null;
         var messageText:String = null;
         var feedLimitSeconds:Number = NaN;
         var recipe:RecipeItem = null;
         var timeLeft:Number = NaN;
         var bushelItem:FarmItem = null;
         var friendsWithBushels:Array = null;
         var bushelsRemaining:Boolean = false;
         var friendWithBushel:Object = null;
         super.populate(data);
         this.m_ingredient = data;
         if(this.m_ingredient)
         {
            ingredientItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_ingredient.itemCode);
            numIngredients = CraftingManager.getInstance().getBushelQuantityInInventory(this.m_ingredient.itemCode);
            quantityRequired = int(this.m_ingredient.quantityRequired);
            complete = numIngredients >= quantityRequired;
            nameTextField = getWidget(m_element.generic1_tf) as ZwTextField;
            nameTextField.text = ZLocUtils.tk_pk_asTitle("Items:" + ingredientItem.name + "_friendlyName");
            nameTextField.visible = true;
            amountTextField = getWidget(m_element.generic2_tf) as ZwTextField;
            amountTextField.text = ZLocUtils.t("Crafting","ShoppingListDialog_IngredientAmount",{
               "quantity":numIngredients.toString(),
               "maximum":quantityRequired.toString()
            });
            amountTextField.visible = true;
            iconFarmIcon = getWidget(m_element.icon_mc) as FarmIcon;
            iconFarmIcon.loadIcon(ingredientItem.icon);
            iconFarmIcon.visible = true;
            (getWidget(m_element.checkMark_mc) as ZwWidget).visible = complete;
            overLimit = Global.player.craftingState.shoppingState.getTotalDailyPurchases() > Global.player.craftingState.shoppingState.maxPurchasesPerDay;
            marketStallFull = Global.player.craftingState.inventoryState.isFull;
            siloFull = Global.player.craftingState.inventoryState.isSiloFull;
            shareableBushel = true;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               if(ingredientItem.hasPropertyInDataSource("shareableBushel"))
               {
                  shareableBushel = ingredientItem.getIntFromDataSource("shareableBushel") != 0;
               }
            }
            else if(ingredientItem.xml.hasOwnProperty("shareableBushel"))
            {
               shareableBushel = ingredientItem.xml.shareableBushel != 0;
            }
            if(!shareableBushel)
            {
               statusMessage = ZLocUtils.tk_pk("Dialogs:ShoppingListNoAction").getString();
               this.showMessage(statusMessage,true);
               this.m_actionButton.toggleClickableButton(false,statusMessage);
            }
            else if(marketStallFull && CraftingManager.getInstance().getCraftTypeofBushel(this.m_ingredient.itemCode) == CraftingManager.BUSHEL_TYPE_STALL)
            {
               marketStall = Global.player.craftingState.getMarketStall();
               if(Boolean(marketStall) && marketStall.readyToExpand())
               {
                  this.showMessage(ZLocUtils.t("Crafting","ShoppingListDialog_InventoryFullExpandMessage"),false,false,this.onExpandMarketStallButtonClick);
               }
               else
               {
                  this.showMessage(ZLocUtils.t("Crafting","ShoppingListDialog_InventoryFullMessage"),false,true);
               }
            }
            else if(siloFull && CraftingManager.getInstance().getCraftTypeofBushel(this.m_ingredient.itemCode) == CraftingManager.BUSHEL_TYPE_SILO)
            {
               silo = Global.player.craftingState.getCraftingSilo();
               if(Boolean(silo) && !silo.hasReachedMaxExpansionLevel())
               {
                  this.showMessage(ZLocUtils.t("Crafting","ShoppingListDialog_InventoryFullExpandMessage"),false,false,this.onExpandSiloButtonClick);
               }
               else
               {
                  this.showMessage(ZLocUtils.t("Crafting","ShoppingListDialog_InventoryFullMessage"),false,true);
               }
            }
            else if(CraftingManager.getInstance().isIngredientGetByFeed(this.m_ingredient))
            {
               if(this.getCanPublishFeed())
               {
                  feedLimitSeconds = Global.craftConfigSettings.getRecipeIngredientRequestFeedLimitSeconds();
                  messageText = ZLocUtils.t("Crafting","ShoppingListDialog_GetByFeedMessage",{"friendlyTime":FarmGameUtil.toFriendlyTime(feedLimitSeconds,true)});
                  this.showMessage(messageText,true);
               }
               else
               {
                  recipe = this.getRecipe();
                  if(recipe)
                  {
                     timeLeft = CraftingManager.getInstance().getTimeUntilCanPublishGetByFeedIngredient(recipe,this.m_ingredient);
                     messageText = ZLocUtils.t("Crafting","ShoppingListDialog_GetByFeedTimeRemainingMessage",{"friendlyTime":FarmGameUtil.toFriendlyTime(timeLeft)});
                     this.showMessage(messageText,true);
                     this.m_actionButton.enabled = false;
                  }
               }
            }
            else if(overLimit)
            {
               this.showMessage(ZLocUtils.t("Crafting","ShoppingListDialog_DailyLimitMessage",{"friendlyTime":CraftingManager.getInstance().getFriendlyTimeToMoreBags()}),false);
            }
            else if(CraftingManager.getInstance().getCraftTypeofBushel(this.m_ingredient.itemCode) == CraftingManager.BUSHEL_TYPE_SILO)
            {
               bushelItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_ingredient.itemCode);
               if(this.getCanPublishFeed())
               {
                  this.showMessage(ZLocUtils.t("Crafting","CraftingSiloDialog_InventoryItem_AskText",{"bushelitem":ZLocUtils.tk_pk(bushelItem.friendlyName)}),true);
               }
               else
               {
                  this.showMessage(ZLocUtils.t("Crafting","CraftingSiloDialog_InventoryItem_AskText_Waiting",{"bushelitem":ZLocUtils.tk_pk(bushelItem.friendlyName)}),false);
               }
            }
            else
            {
               friendsWithBushels = MarketViewManager.getInstance().getFriendsWithBushel(this.m_ingredient.itemCode);
               if(Boolean(friendsWithBushels) && friendsWithBushels.length > 0)
               {
                  bushelsRemaining = false;
                  for each(friendWithBushel in friendsWithBushels)
                  {
                     if(Number(friendWithBushel["timeToBags"]) <= 0)
                     {
                        bushelsRemaining = true;
                     }
                  }
                  if(bushelsRemaining)
                  {
                     this.m_getBushelsSlotFrame.updateItems(friendsWithBushels);
                     this.m_getBushelsSlotFrame.visible = true;
                     this.hideMessage();
                  }
                  else if(this.getCanPublishFeed())
                  {
                     this.showMessage(ZLocUtils.t("Crafting","ShoppingListDialog_DailyLimitMessage",{"friendlyTime":CraftingManager.getInstance().getFriendlyTimeToMoreBags()}),false);
                  }
                  else
                  {
                     this.showMessage(ZLocUtils.t("Crafting","ShoppingListDialog_DailyLimitMessage",{"friendlyTime":CraftingManager.getInstance().getFriendlyTimeToMoreBags()}),false);
                  }
               }
               else if(this.getCanPublishFeed())
               {
                  this.showMessage(ZLocUtils.t("Crafting","ShoppingListDialog_AskNoneMessage"),true);
               }
               else
               {
                  this.showMessage(ZLocUtils.t("Crafting","ShoppingListDialog_NoneMessage"));
               }
            }
         }
      }
      
      public function getRecipe() : RecipeItem
      {
         var result:RecipeItem = null;
         if(parent is ShoppingListIngredientSlotFrame)
         {
            result = (parent as ShoppingListIngredientSlotFrame).recipe;
         }
         return result;
      }
      
      protected function getCanPublishFeed() : Boolean
      {
         var recipe:RecipeItem = null;
         var result:Boolean = false;
         if(CraftingManager.getInstance().isIngredientGetByFeed(this.m_ingredient))
         {
            recipe = this.getRecipe();
            if(recipe)
            {
               result = CraftingManager.getInstance().canPublishGetByFeedIngredient(recipe,this.m_ingredient);
            }
         }
         else
         {
            result = Global.player.craftingState.shoppingState.lastGetBushelsRequestTS < GlobalEngine.serverTime / 1000 - Global.craftConfigSettings.getBushelRequestFeedLimitSeconds();
         }
         return result;
      }
      
      protected function showMessage(text:String, askButtonVisible:Boolean = false, viewInventoryButtonVisible:Boolean = false, expandCallback:Function = null) : void
      {
         var ingredientItem:FarmItem = null;
         (this.m_messageFrame.getWidget(m_element.ask_mc.generic_tf) as ZwTextField).text = text;
         this.m_actionButton.visible = true;
         if(Boolean(this.m_buyButton) && Global.experimentManager.getExperimentVariant(EXPERIMENT_FLASH_CRAFTING_BUY_BUSHELS) > 0)
         {
            ingredientItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_ingredient.itemCode);
            if(ingredientItem)
            {
               this.m_buyButton.setAmountText(String(CraftingManager.getInstance().getBushelPrice(ingredientItem)));
               this.m_buyButton.visible = true;
            }
         }
         if(askButtonVisible)
         {
            this.m_actionButton.text = ZLocUtils.t("Crafting","ShoppingListDialog_AskButton");
            this.m_actionButton.callback = this.onAskButtonClick;
         }
         else if(expandCallback != null)
         {
            this.m_actionButton.text = ZLocUtils.t("Dialogs","Expand");
            this.m_actionButton.callback = expandCallback;
         }
         else
         {
            this.m_actionButton.visible = false;
         }
         (this.m_messageFrame.getWidget(m_element.ask_mc.viewInventory_bt) as FarmAnimatedButton).visible = viewInventoryButtonVisible;
         this.m_messageFrame.visible = true;
         this.m_getBushelsSlotFrame.visible = false;
      }
      
      protected function onExpandMarketStallButtonClick(event:Event) : void
      {
         var marketStall:MarketStallBuilding = Global.player.craftingState.getMarketStall();
         if(marketStall)
         {
            FarmStatsManager.count("dialog","marketstall_full_expand","view","ingredients");
            marketStall.beginCompleteExpansionFlow(0,this.closeIngredientsWindow);
         }
      }
      
      protected function onExpandSiloButtonClick(event:Event) : void
      {
         var silo:FeatureBuilding = Global.player.craftingState.getCraftingSilo();
         if(silo)
         {
            FarmStatsManager.count("dialog","craftsilo_full_expand","view","ingredients");
            silo.expandCompleteCallback = this.closeIngredientsWindow;
            silo.beginCompleteExpansionFlow(0);
         }
      }
      
      private function closeIngredientsWindow() : void
      {
         CraftingUI.closeShoppingListWindow();
      }
      
      protected function hideMessage() : void
      {
         this.m_messageFrame.visible = false;
      }
      
      public function isComplete() : Boolean
      {
         var numIngredients:int = 0;
         var quantityRequired:int = 0;
         var result:Boolean = false;
         if(this.m_ingredient)
         {
            numIngredients = CraftingManager.getInstance().getBushelQuantityInInventory(this.m_ingredient.itemCode);
            quantityRequired = int(this.m_ingredient.quantityRequired);
            result = numIngredients >= quantityRequired;
         }
         else
         {
            result = true;
         }
         return result;
      }
      
      protected function onAskButtonClick(evt:Event) : void
      {
         if(this.m_askForItemCallback != null && Boolean(this.m_ingredient))
         {
            this.m_askForItemCallback(this.m_ingredient);
         }
      }
      
      protected function onBuyButtonClick(evt:Event) : void
      {
         if(this.m_buyBushelCallback != null && Boolean(this.m_ingredient))
         {
            this.m_buyBushelCallback(this.m_ingredient.itemCode);
         }
      }
      
      protected function onGetItem(uid:String) : void
      {
         if(this.m_getItemCallback != null)
         {
            this.m_getItemCallback(uid,this.m_ingredient.itemCode);
         }
      }
      
      protected function onViewInventoryButtonClick(evt:Event) : void
      {
         if(this.m_viewInventoryCallback != null)
         {
            this.m_viewInventoryCallback(CraftingManager.getInstance().getCraftTypeofBushel(this.m_ingredient.itemCode) == CraftingManager.BUSHEL_TYPE_SILO ? "silo" : "stall");
         }
      }
      
      override public function release() : void
      {
         this.m_messageFrame = null;
         this.m_getBushelsSlotFrame = null;
         this.m_ingredient = null;
         this.m_getItemCallback = null;
         this.m_askForItemCallback = null;
         this.m_viewInventoryCallback = null;
         super.release();
      }
   }
}

