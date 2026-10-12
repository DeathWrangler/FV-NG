package Widgets.Windows.Crafting
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureBuilding;
   import Classes.VillageResourceBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.CraftingInventoryStateV2;
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Managers.FarmVillageManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Crafting.VillageResourceBuildingOvenFrame;
   import Widgets.Frames.Crafting.VillageResourceBuildingRecipeFrame;
   import Widgets.Menu.FarmTabMenu;
   import Widgets.Menu.MenuItem;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FarmWindowWithTutorial;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class VillageResourceBuildingWindow extends FarmWindowWithTutorial
   {
      
      public static const CRAFT_SHOP_STAT:String = "craft_shop";
      
      public static const RESOURCE_BUILDING:String = "resourcebuilding";
      
      private static const RESOURCE_BUILDING_WINDOW_ASSET:String = "assets/dialogs/Village/FV_village_workshop.swf";
      
      private static const NUM_TUTORIAL_SCENES:int = 4;
      
      private static const TABS_DATA:Array = [{
         "name":"lumbermill",
         "title":"LumberMillResourceBuildingTab"
      },{
         "name":"supplyshopbricksupplier",
         "title":"SupplyShopResourceBuildingTab"
      },{
         "name":"farmdairy",
         "title":"DairyResourceBuildingTab"
      },{
         "name":"recyclingcenter",
         "title":"RecyclingCenterResourceBuildingTab"
      },{
         "name":"silograin",
         "title":"GrainSiloResourceBuildingTab"
      },{
         "name":"cottonmill",
         "title":"CottonMillResourceBuildingTab"
      }];
      
      public static const BUYABLE_WITH_CASH:String = "cash";
      
      public static const BUYABLE_WITH_CURRENCY:String = "village";
      
      private var m_recipeFrame:VillageResourceBuildingRecipeFrame = null;
      
      private var m_ovenFrame:VillageResourceBuildingOvenFrame = null;
      
      private var m_selectedTab:String = "";
      
      public var m_villageResourceBuilding:VillageResourceBuilding = null;
      
      private var m_makeButton:FarmAnimatedTextButton = null;
      
      protected var m_makeItToolTip:FarmTextTooltip = null;
      
      private var m_getAllButton:FarmAnimatedCashButton = null;
      
      private var m_rushCostCash:int = 0;
      
      private var m_slotRecipeItem:RecipeItem = null;
      
      private var m_getAllCostCash:int = 0;
      
      private var m_recipeItemName:String = "";
      
      private var m_buildingsInMarketList:Array = null;
      
      public function VillageResourceBuildingWindow(building:FeatureBuilding = null, recipeItemName:String = "")
      {
         var buildingName:String = null;
         var itemBuildingObject:Object = null;
         if(building)
         {
            buildingName = building.getItemName();
         }
         if(recipeItemName != "")
         {
            this.m_recipeItemName = recipeItemName;
            itemBuildingObject = FarmVillageManager.instance.getItemsBuilding(this.m_recipeItemName);
            if(itemBuildingObject)
            {
               buildingName = itemBuildingObject.buildingName;
            }
         }
         this.selectTabByItemName(buildingName);
         this.m_villageResourceBuilding = Global.world.getObjectsByName(RESOURCE_BUILDING)[0] as VillageResourceBuilding;
         super(RESOURCE_BUILDING,RESOURCE_BUILDING_WINDOW_ASSET,NUM_TUTORIAL_SCENES);
      }
      
      override public function show() : void
      {
         super.show();
         FarmStatsManager.count(FarmVillageManager.FARM_VILLAGE_STAT,CRAFT_SHOP_STAT,"impression",this.m_selectedTab);
      }
      
      override protected function postLoadComplete() : void
      {
         var subMenu:FarmTabMenu = null;
         var items:Array = null;
         var selectedTab:int = 0;
         var tabsLength:int = 0;
         var tab:Object = null;
         var isLocked:Boolean = false;
         var i:int = 0;
         var marketButton:FarmAnimatedTextButton = null;
         super.postLoadComplete();
         var main_mc:MovieClip = m_window.main_mc;
         var mainFrame:ZwFrame = addWidget(new ZwFrame(main_mc)) as ZwFrame;
         if(main_mc.hasOwnProperty("title_tf"))
         {
            mainFrame.addWidget(new ZwTextField(main_mc.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"ResourceBuildingRecipeSlotTitle")));
         }
         if(main_mc.hasOwnProperty("recipeSlot_mc"))
         {
            this.m_recipeFrame = mainFrame.addWidget(new VillageResourceBuildingRecipeFrame(main_mc.recipeSlot_mc,CraftingConstants.VILLAGE_RESOURCE_BUILDING_SKILL,this.m_selectedTab,this)) as VillageResourceBuildingRecipeFrame;
         }
         if(main_mc.hasOwnProperty("slotCraft_mc"))
         {
            this.m_ovenFrame = mainFrame.addWidget(new VillageResourceBuildingOvenFrame(main_mc.slotCraft_mc,this,CraftingConstants.VILLAGE_RESOURCE_BUILDING_SKILL)) as VillageResourceBuildingOvenFrame;
         }
         if(main_mc.hasOwnProperty("subNav_mc"))
         {
            subMenu = mainFrame.addWidget(new FarmTabMenu(main_mc.subNav_mc,this.onSubMenuItemSelected,null,true)) as FarmTabMenu;
            items = new Array();
            selectedTab = 0;
            tabsLength = int(TABS_DATA.length);
            tab = new Object();
            isLocked = false;
            this.m_buildingsInMarketList = new Array();
            for(i = 0; i < tabsLength; i++)
            {
               tab = TABS_DATA[i];
               isLocked = Global.world.getObjectsByName(tab.name).length < 1;
               if(isLocked)
               {
                  this.m_buildingsInMarketList.push(tab.name);
               }
               items.push(new MenuItem(tab.name,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,tab.title),false,false,isLocked));
               if(tab.name == this.m_selectedTab)
               {
                  selectedTab = i;
                  FarmStatsManager.count(FarmVillageManager.FARM_VILLAGE_STAT,CRAFT_SHOP_STAT,tab.name);
               }
            }
            subMenu.items = items;
            subMenu.selectTab(selectedTab);
         }
         if(main_mc.hasOwnProperty("market_bt"))
         {
            marketButton = mainFrame.addWidget(new FarmAnimatedTextButton(main_mc.market_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Market"),this.onClickMarketButton)) as FarmAnimatedTextButton;
            marketButton.visible = this.m_buildingsInMarketList.length > 0;
         }
         if(Boolean(this.m_recipeFrame) && Boolean(this.m_recipeItemName != "") && this.m_selectedTab != "")
         {
            this.m_recipeFrame.setSelectedRecipeById(this.m_recipeItemName,this.m_selectedTab);
         }
         if(main_mc.hasOwnProperty("inventory_bt"))
         {
            mainFrame.addWidget(new FarmAnimatedTextButton(main_mc.inventory_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"CraftshopWindow_inventory_btn"),this.onInventoryButtonClick));
         }
         if(main_mc.hasOwnProperty("whatisthis_mc"))
         {
            mainFrame.addWidget(new FarmAnimatedButton(main_mc.whatisthis_mc,this.onClickMoreInfo));
         }
         if(main_mc.hasOwnProperty("craft_bt") && main_mc.hasOwnProperty("getAll_bt"))
         {
            this.m_makeButton = mainFrame.addWidget(new FarmAnimatedTextButton(main_mc.craft_bt,ZLocUtils.t("Crafting","MenuItem_MyCottage"),this.onClickMakeButton)) as FarmAnimatedTextButton;
            this.m_makeItToolTip = new FarmTextTooltip("");
            this.m_makeButton.attachTooltip(this.m_makeItToolTip);
            this.m_getAllButton = mainFrame.addWidget(new FarmAnimatedCashButton(main_mc.getAll_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"getParts"),"0",this.onClickGetAllButton,false,false,true)) as FarmAnimatedCashButton;
            this.updateMakeOrGetAllButton();
         }
      }
      
      public function updateSelectedRecipe(selectedRecipeItemName:String) : void
      {
         var buildingName:String = null;
         this.m_recipeItemName = selectedRecipeItemName;
         var itemBuildingObject:Object = FarmVillageManager.instance.getItemsBuilding(this.m_recipeItemName);
         if(itemBuildingObject)
         {
            buildingName = itemBuildingObject.buildingName;
            this.selectTabByItemName(buildingName);
         }
         if(Boolean(this.m_recipeFrame) && this.m_selectedTab != "")
         {
            this.m_recipeFrame.setSelectedRecipeById(this.m_recipeItemName,this.m_selectedTab);
         }
      }
      
      override protected function release() : void
      {
         this.m_recipeFrame = null;
         this.m_ovenFrame = null;
         this.m_selectedTab = "";
         this.m_villageResourceBuilding = null;
         this.m_makeButton = null;
         this.m_makeItToolTip = null;
         this.m_getAllButton = null;
         this.m_rushCostCash = 0;
         this.m_slotRecipeItem = null;
         this.m_getAllCostCash = 0;
         super.release();
      }
      
      public function getBuildingCraftType() : String
      {
         var result:String = "";
         if(Boolean(this.m_villageResourceBuilding) && Boolean(this.m_villageResourceBuilding.getItem()))
         {
            result = this.m_villageResourceBuilding.getItem().craftType;
         }
         return result;
      }
      
      private function isOvenSlotAvailable() : int
      {
         var totalOvenAllowed:int = 0;
         var canMakeRecipe:int = CraftingConstants.CAN_MAKE_RECIPE;
         if(this.m_villageResourceBuilding)
         {
            totalOvenAllowed = this.m_villageResourceBuilding.storageLevel;
            if(this.getUsedOvensInWorld() >= totalOvenAllowed)
            {
               canMakeRecipe = CraftingConstants.OVEN_SLOTS_FULL;
            }
         }
         return canMakeRecipe;
      }
      
      private function getUsedOvensInWorld() : int
      {
         var recipeQueue:Array = null;
         var i:int = 0;
         var usedOvens:int = 0;
         if(this.m_villageResourceBuilding)
         {
            recipeQueue = Global.player.craftingState.getRecipeQueueForCraftType(this.m_villageResourceBuilding.getItem().craftType);
            for(i = 0; i < recipeQueue.length; i++)
            {
               if((recipeQueue[i] as RecipeItem).worldType == Global.worldManager.currentWorldType)
               {
                  usedOvens++;
               }
            }
         }
         return usedOvens;
      }
      
      public function getNextAvailableOvenSlot() : int
      {
         var recipeQueue:Array = null;
         var recipe:RecipeItem = null;
         var i:int = 0;
         var totalOvensAllowedInWorld:int = 0;
         var j:int = 0;
         var usedOvenSlots:Array = new Array();
         var result:int = -1;
         if(this.m_villageResourceBuilding)
         {
            recipeQueue = Global.player.craftingState.getRecipeQueueForCraftType(this.m_villageResourceBuilding.getItem().craftType);
            recipe = null;
            for(i = 0; i < recipeQueue.length; i++)
            {
               recipe = recipeQueue[i] as RecipeItem;
               if(Boolean(recipe) && Boolean(recipe.ovenSlot) && recipe.worldType == Global.worldManager.currentWorldType)
               {
                  usedOvenSlots.push(recipe.ovenSlot);
               }
            }
            totalOvensAllowedInWorld = this.m_villageResourceBuilding.storageLevel;
            for(j = 0; j < totalOvensAllowedInWorld; j++)
            {
               if(usedOvenSlots.indexOf(j) == -1)
               {
                  result = j;
               }
            }
         }
         return result;
      }
      
      public function getBuildingStorageLevel() : int
      {
         var storageLevel:int = 0;
         if(this.m_villageResourceBuilding)
         {
            storageLevel = this.m_villageResourceBuilding.storageLevel;
         }
         return storageLevel;
      }
      
      public function getUnlockPriceAndCurrency() : Object
      {
         var parts:Object = null;
         var currencyType:String = null;
         var needed:Number = NaN;
         var partItem:FarmItem = null;
         var value:int = 0;
         var code:String = null;
         var unlockDetail:Object = new Object();
         if(this.m_villageResourceBuilding)
         {
            parts = this.m_villageResourceBuilding.nextExpansionPartsNeeded();
            if(parts)
            {
               currencyType = "";
               needed = 0;
               partItem = null;
               value = 0;
               var _loc8_:int = 0;
               var _loc9_:* = parts;
               for(code in _loc9_)
               {
                  needed = Number(parts[code]);
                  partItem = Global.farmGameSettingsManager.getFarmItemByCode(code);
                  if(partItem)
                  {
                     if(partItem.buyableWithWorldCurrency() && Boolean(partItem.cost))
                     {
                        currencyType = BUYABLE_WITH_CURRENCY;
                        value = partItem.cost * needed;
                     }
                     else if(partItem.cash)
                     {
                        currencyType = BUYABLE_WITH_CASH;
                        value = partItem.cash * needed;
                     }
                     unlockDetail.currencyType = currencyType;
                     unlockDetail.value = value;
                  }
               }
            }
         }
         return unlockDetail;
      }
      
      public function unlockBuilding() : void
      {
         if(this.m_villageResourceBuilding)
         {
            this.m_villageResourceBuilding.expandBuildingUsingCurrencyOrCash();
         }
         if(this.m_ovenFrame)
         {
            this.m_ovenFrame.update();
         }
      }
      
      private function onSubMenuItemSelected(item:MenuItem) : void
      {
         if(Boolean(item) && Boolean(item.data))
         {
            this.m_selectedTab = item.data as String;
            FarmStatsManager.count(FarmVillageManager.FARM_VILLAGE_STAT,CRAFT_SHOP_STAT,this.m_selectedTab);
            this.refreshRecipeFrame();
         }
      }
      
      private function refreshRecipeFrame() : void
      {
         if(this.m_recipeFrame)
         {
            this.m_recipeFrame.setCurrentTab(this.m_selectedTab);
            this.m_recipeFrame.update();
            this.m_recipeFrame.refresh();
         }
      }
      
      private function onInventoryButtonClick(event:MouseEvent) : void
      {
         this.close();
         UI.displayPopup(new VillageIngredientStorageWindow());
      }
      
      private function onClickMarketButton(event:MouseEvent) : void
      {
         if(Boolean(this.m_buildingsInMarketList) && this.m_buildingsInMarketList.length > 0)
         {
            this.close();
            UI.displayMiniMarketDialog(this.m_buildingsInMarketList);
         }
      }
      
      private function selectTabByItemName(itemName:String) : void
      {
         var tabsLength:int = 0;
         var tab:Object = null;
         var i:int = 0;
         this.m_selectedTab = TABS_DATA[0].name;
         if(itemName != "")
         {
            tabsLength = int(TABS_DATA.length);
            tab = new Object();
            for(i = 0; i < tabsLength; i++)
            {
               tab = TABS_DATA[i];
               if(tab.name == itemName)
               {
                  this.m_selectedTab = tab.name;
                  break;
               }
            }
         }
      }
      
      private function onClickMoreInfo(event:MouseEvent) : void
      {
         super.showTutorial();
      }
      
      public function updateMakeOrGetAllButton() : void
      {
         var selectedRecipe:RecipeItem = null;
         var canMakeRecipe:Boolean = false;
         if(Boolean(this.m_recipeFrame && this.m_recipeFrame.selectedRecipe) && Boolean(this.m_makeButton) && Boolean(this.m_getAllButton))
         {
            selectedRecipe = this.m_recipeFrame.selectedRecipe;
            canMakeRecipe = selectedRecipe.canMake;
            this.m_makeButton.visible = canMakeRecipe;
            this.m_getAllButton.visible = !canMakeRecipe;
            if(canMakeRecipe)
            {
               if(this.isOvenSlotAvailable())
               {
                  this.m_makeButton.applyGrayOut = true;
                  this.m_makeButton.callback = null;
                  this.m_makeItToolTip.setText(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"CraftshopRecipeSlot_slotFull"));
               }
               else
               {
                  this.m_makeButton.applyGrayOut = false;
                  this.m_makeButton.callback = this.onClickMakeButton;
                  this.m_makeButton.detachTooltip();
               }
            }
            else
            {
               this.m_getAllCostCash = CraftingManager.getInstance().getRemainingItemsToCompleteRecipePrice(selectedRecipe);
               this.m_getAllButton.setAmountText(this.m_getAllCostCash.toString());
            }
         }
      }
      
      private function onClickGetAllButton(event:Event) : void
      {
         var recipeItem:RecipeItem = null;
         if(this.m_recipeFrame)
         {
            recipeItem = this.m_recipeFrame.selectedRecipe;
            if(recipeItem)
            {
               if(this.isEnoughRoomInStorageToGetAll(recipeItem))
               {
                  CraftingManager.getInstance().onPurchaseRemainingItemsToCompleteRecipe(recipeItem);
                  this.m_recipeFrame.updateRecipeSlots();
                  FarmStatsManager.count(FarmVillageManager.FARM_VILLAGE_STAT,CRAFT_SHOP_STAT,"onGetAllClick",recipeItem.name,this.m_getAllCostCash.toString());
               }
               else
               {
                  this.close();
                  FarmVillageManager.instance.onExpandStorage();
               }
            }
         }
      }
      
      private function isEnoughRoomInStorageToGetAll(recipeItem:RecipeItem) : Boolean
      {
         var ingredient:Object = null;
         var item:FarmItem = null;
         var inventoryState:CraftingInventoryStateV2 = null;
         var maxCapacity:Number = NaN;
         var currentCapacity:Number = NaN;
         var canGetAll:Boolean = false;
         var required:int = 0;
         var have:int = 0;
         var difference:int = 0;
         var totalRequired:int = 0;
         for each(ingredient in recipeItem.ingredients)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(ingredient.itemCode);
            required = int(ingredient.quantityRequired);
            have = CraftingManager.getInstance().getInventoryCountHelper(item.code,required,recipeItem.craft);
            difference = required - have > 0 ? int(required - have) : 0;
            totalRequired += difference;
         }
         inventoryState = Global.player.craftingState.inventoryState;
         maxCapacity = inventoryState.villageStorageMaxCapacity;
         currentCapacity = inventoryState.villageStorageCurrentCapacity;
         if(currentCapacity + totalRequired <= maxCapacity)
         {
            canGetAll = true;
         }
         return canGetAll;
      }
      
      private function onClickMakeButton(event:MouseEvent) : void
      {
         var recipeItem:RecipeItem = null;
         var ovenSlot:int = 0;
         this.pause();
         if(this.m_recipeFrame)
         {
            recipeItem = this.m_recipeFrame.selectedRecipe;
            ovenSlot = this.getNextAvailableOvenSlot();
            if(Boolean(recipeItem) && Boolean(recipeItem.canMake) && ovenSlot >= 0)
            {
               recipeItem.ovenSlot = ovenSlot;
               recipeItem.worldType = Global.worldManager.currentWorldType;
               CraftingManager.getInstance().beginRecipe(recipeItem,this.onRecipeBeginDone);
               Global.stage.dispatchEvent(new Event(FarmVillageManager.ORDER_BOARD_REFRESH_EVENT));
            }
         }
      }
      
      private function onRecipeBeginDone(tResult:Object) : void
      {
         this.unpause();
      }
      
      public function pause() : void
      {
         if(m_window)
         {
            tintWindow();
            enableInput = false;
         }
      }
      
      public function unpause() : void
      {
         if(m_window)
         {
            this.update();
            untintWindow();
            enableInput = true;
         }
      }
      
      public function update() : void
      {
         if(this.m_ovenFrame)
         {
            this.m_ovenFrame.update();
         }
         if(this.m_recipeFrame)
         {
            this.m_recipeFrame.setSelectedRecipeById(this.m_recipeFrame.selectedRecipe.name,this.m_selectedTab);
         }
      }
      
      override public function close() : void
      {
         if(this.m_selectedTab)
         {
            FarmStatsManager.count(FarmVillageManager.FARM_VILLAGE_STAT,CRAFT_SHOP_STAT,"close",this.m_selectedTab);
         }
         super.close();
      }
      
      public function finishedRecipeRushed(recipeId:String, ovenSlot:int, rushCostCash:int) : void
      {
         this.pause();
         this.m_rushCostCash = rushCostCash;
         this.m_slotRecipeItem = CraftingManager.getRecipeItemFromIdAndSlot(recipeId,ovenSlot,this.getBuildingCraftType());
         if(Boolean(this.m_slotRecipeItem) && this.m_slotRecipeItem.isComplete)
         {
            this.finishRecipe(recipeId,ovenSlot);
         }
         else if(this.m_rushCostCash > 0 && Global.player.canBuyCash(this.m_rushCostCash,true))
         {
            Global.player.cash -= this.m_rushCostCash;
            CraftingManager.getInstance().beginBuyRecipeRush(this.m_slotRecipeItem,false,this.onEndClaimFinishedRecipes,true);
         }
         Global.stage.dispatchEvent(new Event(FarmVillageManager.ORDER_BOARD_REFRESH_EVENT));
      }
      
      public function finishRecipe(recipeId:String, ovenSlot:int) : void
      {
         CraftingManager.getInstance().beginClaimFinishedRecipes(this.onEndClaimFinishedRecipes,recipeId,null,ovenSlot);
         Global.stage.dispatchEvent(new Event(FarmVillageManager.ORDER_BOARD_REFRESH_EVENT));
      }
      
      public function onEndClaimFinishedRecipes(result:Object) : void
      {
         this.unpause();
      }
   }
}

