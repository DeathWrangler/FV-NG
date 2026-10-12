package Widgets.Windows.Crafting
{
   import Classes.Constants.Experiments;
   import Classes.ConstructionBuilding;
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.MarketInventoryItem;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.ImpulseBuy;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Events.ImpulseBuyEvent;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Transactions.TBuySiloBushel;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Toggles.ZwVisibilityToggle;
   import Widgets.Frames.Crafting.CraftingSiloInventoryFrame;
   import Widgets.Frames.GenericExpandSlotFrame;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.GenericNumberSelectionWindow;
   import Widgets.Windows.UseAllAmountSelectionWindow;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class CraftingSiloWindow extends FarmWindow
   {
      
      public static const VIEW_INVENTORY:int = 0;
      
      public static const VIEW_EXPAND:int = 1;
      
      private static const FARMCASH_PRICE_FOR_ONE_INGREDIENT:Number = 1;
      
      private static const SHARE_ICON_OFFSET:Point = new Point(0,-15);
      
      private const FEED_BUNDLE_ID_SHARE_BUSHEL:String = "craftingsilo_sharebushel";
      
      private var m_state:int = 0;
      
      private var m_building:FeatureBuilding = null;
      
      private var m_locPrefix:String = "";
      
      private var m_toggleManager:ZwToggleManager = null;
      
      private var m_defaultViewToggle:ZwVisibilityToggle = null;
      
      private var m_expandViewToggle:ZwVisibilityToggle = null;
      
      private var m_gotoCraftShopButton:FarmAnimatedTextButton = null;
      
      private var m_inventoryViewButton:FarmAnimatedTextButton = null;
      
      private var m_expansionViewButton:FarmAnimatedTextButton = null;
      
      private var m_inventoryFrame:CraftingSiloInventoryFrame = null;
      
      private var m_expandFrame:GenericExpandSlotFrame = null;
      
      private var m_itemToBuyAskShare:FarmItem = null;
      
      private var m_impulseBuyDialog:ImpulseBuy = null;
      
      private var m_shareCraftingSiloItemWindow:GenericNumberSelectionWindow = null;
      
      protected var m_searchBar_mc:ZwWidget = null;
      
      private var m_clearSearchButton_mc:FarmAnimatedButton = null;
      
      private var m_clearedSearch:Boolean = false;
      
      private var m_search_mc:ZwWidget = null;
      
      private var m_searchField_tf:ZwTextField = null;
      
      private var m_defaultString:String = ZLocUtils.t("Dialogs","Search");
      
      private var m_noResultsText:ZwTextField = null;
      
      private var m_bushelSerachingVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BUSHEL_SORTING);
      
      public function CraftingSiloWindow(craftingSiloBuilding:FeatureBuilding = null, windowAssetRelUrl:String = "assets/dialogs/FV_Craft_Silo.swf", locPrefix:String = "CraftingSiloDialog")
      {
         if(this.m_bushelSerachingVariant != 0)
         {
            windowAssetRelUrl = "assets/dialogs/FV_Craft_Silo2.swf";
         }
         super(windowAssetRelUrl,true,true);
         this.m_building = craftingSiloBuilding;
         this.m_locPrefix = locPrefix;
      }
      
      public function pause() : void
      {
         tintWindow();
         enableInput = false;
      }
      
      public function unpause() : void
      {
         untintWindow();
         enableInput = true;
      }
      
      override public function refreshWindow() : void
      {
         this.m_expandFrame.refresh();
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Crafting",this.m_locPrefix + "_Title")));
         addWidget(new FarmAnimatedTextButton(m_window.howDoes_mc,ZLocUtils.t("Crafting",this.m_locPrefix + "_HowDoesThisWorkButton"),this.onHowDoesThisWorkClick));
         if(this.m_bushelSerachingVariant != 0)
         {
            this.m_searchBar_mc = addWidget(new ZwWidget(m_window.searchBar_mc)) as ZwWidget;
            this.m_searchField_tf = addWidget(new ZwTextField(m_window.searchBar_mc.searchField_tf,this.m_defaultString)) as ZwTextField;
            m_window.searchBar_mc.searchField_tf.addEventListener(FocusEvent.FOCUS_IN,this.disableShortcut);
            m_window.searchBar_mc.searchField_tf.addEventListener(FocusEvent.FOCUS_OUT,this.enableShortcut);
            m_window.searchBar_mc.searchField_tf.addEventListener(MouseEvent.CLICK,this.onSearchTextButtonClick);
            m_window.searchBar_mc.searchField_tf.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUpHandler);
            this.m_searchField_tf.restrict("0-9 a-zA-Z\\-\'");
            if(m_window.searchBar_mc.clearsearch_bt == null)
            {
               if(m_window.searchBar_mc.search_bt != null)
               {
                  this.m_clearSearchButton_mc = addWidget(new FarmAnimatedButton(m_window.searchBar_mc.search_bt,this.onClearSearchButtonClick)) as FarmAnimatedButton;
               }
            }
            else
            {
               this.m_clearSearchButton_mc = addWidget(new FarmAnimatedButton(m_window.searchBar_mc.clearsearch_bt,this.onClearSearchButtonClick)) as FarmAnimatedButton;
            }
            if(m_window.searchBar_mc.search_mc != null)
            {
               this.m_search_mc = addWidget(new ZwWidget(m_window.searchBar_mc.search_mc)) as ZwWidget;
            }
         }
         var hasCraftShop:Boolean = false;
         var buildings:Array = Global.world.getObjectsByNames(Global.craftConfigSettings.getCraftingWorkshopBuildable());
         if(buildings.length > 0)
         {
            hasCraftShop = true;
         }
         else
         {
            buildings = Global.world.getObjectsByNames(Global.craftConfigSettings.getCraftingWorkshopFinished());
            if(buildings.length > 0)
            {
               hasCraftShop = true;
            }
         }
         if(hasCraftShop)
         {
            this.m_gotoCraftShopButton = new FarmAnimatedTextButton(m_window.craftNow_bt,ZLocUtils.t("Crafting",this.m_locPrefix + "_CraftNowButtonLabel"),this.onClickCraftNow);
            addWidget(this.m_gotoCraftShopButton);
         }
         this.m_inventoryFrame = addWidget(new CraftingSiloInventoryFrame(m_window.bushelGetFrame_mc,this.m_building,this.m_locPrefix,this.onItemBuy,this.onItemShare,this.onItemAsk)) as CraftingSiloInventoryFrame;
         this.initExpansionWidgets();
         this.m_inventoryViewButton = new FarmAnimatedTextButton(m_window.inventory_bt,ZLocUtils.t("Crafting",this.m_locPrefix + "_InventoryButtonLabel"),this.onClickInventoryMode);
         addWidget(this.m_inventoryViewButton);
         this.m_expansionViewButton = new FarmAnimatedTextButton(m_window.expand_bt,ZLocUtils.t("Crafting",this.m_locPrefix + "_ExpandButtonLabel"),this.onClickExpandMode);
         if(this.m_building.hasReachedMaxExpansionLevel())
         {
            this.m_expansionViewButton.enabled = false;
         }
         addWidget(this.m_expansionViewButton);
         var expandStateActive:Boolean = !this.m_building.hasReachedMaxExpansionLevel();
         this.m_toggleManager = new ZwToggleManager();
         this.m_defaultViewToggle = new ZwVisibilityToggle(this.m_inventoryViewButton,this.m_inventoryFrame);
         this.m_toggleManager.addToggle(this.m_defaultViewToggle,!expandStateActive);
         if(expandStateActive)
         {
            this.m_state = VIEW_EXPAND;
            this.m_expandViewToggle = new ZwVisibilityToggle(this.m_expansionViewButton,this.m_expandFrame);
            this.m_toggleManager.addToggle(this.m_expandViewToggle,expandStateActive);
         }
         else
         {
            this.m_expansionViewButton.visible = false;
            this.m_inventoryViewButton.visible = false;
         }
         if(this.m_state == CraftingSiloWindow.VIEW_EXPAND && this.m_expandViewToggle != null)
         {
            this.m_toggleManager.performToggle(this.m_expandViewToggle);
            if(this.m_building.hasNextExpansion())
            {
               addWidget(new ZwTextField(m_window.frame_expand_mc.expand_tf,ZLocUtils.t("Crafting",this.m_locPrefix + "_Description",{"quantity":(this.m_building.getNextExpansionCapacity() - this.m_building.capacity).toString()}))).visible = true;
            }
            this.m_inventoryFrame.visible = false;
         }
         else
         {
            this.m_toggleManager.performToggle(this.m_defaultViewToggle);
            if(this.m_expandFrame != null)
            {
               this.m_expandFrame.visible = false;
            }
         }
      }
      
      private function initExpansionWidgets() : void
      {
         var expansionItems:Array = this.m_building.expand.getExpandSlotData();
         if(expansionItems)
         {
            this.m_expandFrame = new GenericExpandSlotFrame(m_window.frame_expand_mc,expansionItems,this,this.m_building,this.m_building.expand);
            addWidget(this.m_expandFrame);
         }
      }
      
      private function onClickInventoryMode(evt:Event) : void
      {
         this.m_state = CraftingSiloWindow.VIEW_INVENTORY;
      }
      
      private function onClickExpandMode(evt:Event) : void
      {
         this.m_state = CraftingSiloWindow.VIEW_EXPAND;
      }
      
      private function onItemBuy(item:FarmItem, data:MarketInventoryItem) : void
      {
         this.m_itemToBuyAskShare = item;
         var messageText:String = ZLocUtils.t("Dialogs","ConstructionBuilding_BuyConfirmation",{
            "item":ZLocUtils.tk_pk(item.friendlyName),
            "cashQuantity":FARMCASH_PRICE_FOR_ONE_INGREDIENT
         });
         var message:GenericIconPopup = new GenericIconPopup(messageText,GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmBuy,item.icon,false,true,"",true,GenericIconPopup.GENERIC_CALLOUT_ASSET,null,false);
         UI.displayPopup(message,false);
         this.pause();
      }
      
      private function onConfirmBuy(event:GenericPopupEvent) : void
      {
         var quantity:Number = NaN;
         var maxCapacity:Number = NaN;
         var currentCapacity:Number = NaN;
         var neededCash:int = 0;
         var beginOOS_itemsStr:String = null;
         var unlockedWorlds:Array = null;
         var totalUnlockedWorlds:Number = NaN;
         var totalWorldRestrictions:Number = NaN;
         var totalWorldsThisItemCanBeIn:Number = NaN;
         var itemLimitPerWorld:Number = NaN;
         var buildingCapacity:Number = NaN;
         var displayMessage:String = null;
         var itemMaxUpgradeData:BaseDataSource = null;
         var itemMaxUpgrade:XML = null;
         var dialog:GenericPopup = null;
         this.unpause();
         if(event.button == GenericPopup.ACCEPT && this.m_itemToBuyAskShare != null)
         {
            if(CraftingManager.getInstance().getCraftTypeofBushel(this.m_itemToBuyAskShare.code) == CraftingManager.BUSHEL_TYPE_SILO)
            {
               quantity = 1;
               maxCapacity = Global.player.craftingState.inventoryState.craftingSiloMaxCapacity;
               currentCapacity = Global.player.craftingState.inventoryState.craftingSiloCurrentCapacity;
               if(currentCapacity + quantity <= maxCapacity)
               {
                  neededCash = FARMCASH_PRICE_FOR_ONE_INGREDIENT * quantity;
                  if(Global.player.cash >= neededCash)
                  {
                     Global.player.cash -= neededCash;
                     CraftingManager.getInstance().addItemToInventory(this.m_itemToBuyAskShare.code,quantity);
                     if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CRAFTING_OOS_STATS) > 0)
                     {
                        beginOOS_itemsStr = "item_" + this.m_itemToBuyAskShare.code + ":" + quantity;
                        FarmStatsManager.count("beginOOS","client","add_craftingSiloWindowConfirmBuy",beginOOS_itemsStr);
                     }
                     this.m_inventoryFrame.refreshItemCount(this.m_itemToBuyAskShare.code);
                     TransactionManager.addTransaction(new TBuySiloBushel(this.m_itemToBuyAskShare.code,quantity),true);
                  }
                  else
                  {
                     this.m_impulseBuyDialog = new ImpulseBuy(ImpulseBuy.TYPE_MARKET_CASH,this.m_itemToBuyAskShare.type);
                     this.m_impulseBuyDialog.addEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
                     UI.displayPopup(this.m_impulseBuyDialog,false,"buyMoreCashPopup",true);
                     this.pause();
                  }
               }
               else
               {
                  unlockedWorlds = Global.worldManager.unlockedWorldTypes;
                  totalUnlockedWorlds = unlockedWorlds.length;
                  totalWorldRestrictions = this.m_building.getItem().worldRestrictions.length;
                  totalWorldsThisItemCanBeIn = totalWorldRestrictions == 0 ? totalUnlockedWorlds : totalWorldRestrictions;
                  itemLimitPerWorld = this.m_building.getItem().limit;
                  if(FarmGameSettingsManager.isInDataSourceExperiment())
                  {
                     itemMaxUpgradeData = this.m_building.getItem().getMaxUpgradeDataSource();
                     buildingCapacity = itemMaxUpgradeData.getNumber("capacity");
                  }
                  else
                  {
                     itemMaxUpgrade = this.m_building.getItem().getMaxUpgradeData();
                     buildingCapacity = Number(itemMaxUpgrade.@capacity);
                  }
                  displayMessage = null;
                  if(!this.m_building.expand.hasReachedMaxExpansionLevel())
                  {
                     displayMessage = ZLocUtils.t("Crafting",this.m_locPrefix + "_BuyFail_TryExpand");
                  }
                  else if(maxCapacity < totalWorldsThisItemCanBeIn * buildingCapacity * itemLimitPerWorld)
                  {
                     displayMessage = ZLocUtils.t("Crafting",this.m_locPrefix + "_BuyFail_TryOtherWorlds");
                  }
                  else
                  {
                     this.m_inventoryFrame.refreshBuyButtons();
                  }
                  if(displayMessage != null)
                  {
                     dialog = new GenericPopup(displayMessage,GenericPopup.TYPE_OK,this.onCloseBuyFailTooFullDialog);
                     dialog.setAcceptTextName(ZLocUtils.t("Dialogs","Okay"));
                     UI.displayPopup(dialog);
                     this.pause();
                  }
               }
            }
         }
      }
      
      public function onImpulseBuyCancel(event:ImpulseBuyEvent) : void
      {
         if(this.m_impulseBuyDialog)
         {
            this.unpause();
            this.m_impulseBuyDialog.removeEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
            this.m_impulseBuyDialog = null;
         }
      }
      
      public function onCloseBuyFailTooFullDialog(evt:GenericPopupEvent) : void
      {
         this.unpause();
      }
      
      private function onItemShare(item:FarmItem, data:MarketInventoryItem) : void
      {
         var bundleText:Object = null;
         if(this.m_shareCraftingSiloItemWindow == null)
         {
            bundleText = {};
            bundleText[UseAllAmountSelectionWindow.TEXT_KEY_TITLE] = ZLocUtils.t("Crafting",this.m_locPrefix + "_InventoryItem_ShareDialog_Body");
            bundleText[UseAllAmountSelectionWindow.TEXT_KEY_ACCEPT_BUTTON] = ZLocUtils.t("Dialogs","GenericShareButton");
            this.m_shareCraftingSiloItemWindow = new UseAllAmountSelectionWindow(item,data.quantity,0,this.onItemSharedCallBack,this.onItemShareWindowClosed,bundleText);
            UI.displayPopup(this.m_shareCraftingSiloItemWindow,false);
            this.pause();
         }
      }
      
      private function onItemSharedCallBack(obj:Object) : void
      {
         if(Boolean(obj) && Boolean(obj["item"]) && Boolean(obj["quantitySelected"]))
         {
            CraftingManager.getInstance().shareBushel(obj.item.code,obj.quantitySelected,this.FEED_BUNDLE_ID_SHARE_BUSHEL);
            this.m_inventoryFrame.refreshItemCount(obj.item.code);
         }
         if(this.m_shareCraftingSiloItemWindow != null)
         {
            this.m_shareCraftingSiloItemWindow = null;
            this.unpause();
         }
      }
      
      private function onItemShareWindowClosed(Obj:Object) : void
      {
         if(this.m_shareCraftingSiloItemWindow != null)
         {
            this.m_shareCraftingSiloItemWindow = null;
            this.unpause();
         }
      }
      
      private function onItemAsk(item:FarmItem, data:MarketInventoryItem) : void
      {
         this.m_itemToBuyAskShare = item;
         CraftingManager.getInstance().onNoBushelsAvailableShopping(item.code,"silo",this.onCloseAsk,item.icon);
         this.pause();
      }
      
      private function onCloseAsk(evt:Event = null) : void
      {
         this.m_inventoryFrame.refresh();
         this.unpause();
      }
      
      private function onClickCraftNow(event:Event) : void
      {
         var dialog:CraftshopWindow = null;
         this.close();
         var buildings:Array = Global.world.getObjectsByNames(Global.craftConfigSettings.getCraftingWorkshopBuildable());
         if(buildings.length > 0)
         {
            (buildings[0] as ConstructionBuilding).displayStorageDialog();
         }
         else
         {
            buildings = Global.world.getObjectsByNames(Global.craftConfigSettings.getCraftingWorkshopFinished());
            if(buildings.length > 0)
            {
               dialog = new CraftshopWindow(buildings[0]);
               UI.displayPopup(dialog,true,"CraftshopWindow",true);
            }
         }
      }
      
      private function onSearchTextButtonClick(event:MouseEvent) : void
      {
         Global.farmGame.switchOutFullScreen();
         if(this.m_searchField_tf.text == this.m_defaultString)
         {
            this.m_searchField_tf.text = "";
            this.m_clearedSearch = true;
         }
      }
      
      public function clearSearch() : void
      {
         if(this.m_searchField_tf)
         {
            this.m_searchField_tf.text = "";
            this.m_clearedSearch = true;
         }
      }
      
      private function onClearSearchButtonClick(event:MouseEvent) : void
      {
         this.clearSearch();
      }
      
      private function enableShortcut(event:FocusEvent) : void
      {
         Global.overrideDebugKeys = false;
      }
      
      private function disableShortcut(event:FocusEvent) : void
      {
         Global.overrideDebugKeys = true;
      }
      
      private function onKeyUpHandler(event:KeyboardEvent) : void
      {
         this.m_inventoryFrame.updateSearchString(this.m_searchField_tf.text);
         this.m_inventoryFrame.refresh();
      }
      
      private function onHowDoesThisWorkClick(event:Event) : void
      {
         TutorialUI.displayCraftingSiloMoreInfoWindow(false,this.onHowDoesThisWorkClose);
         this.pause();
      }
      
      private function onHowDoesThisWorkClose() : void
      {
         this.unpause();
      }
   }
}

