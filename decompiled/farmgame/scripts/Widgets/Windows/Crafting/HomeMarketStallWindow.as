package Widgets.Windows.Crafting
{
   import Classes.Constants.Experiments;
   import Classes.MarketStallBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.CraftingStatsManager;
   import Classes.crafting.MarketInventoryItem;
   import Classes.crafting.PendingReward;
   import Classes.storage.PartItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.CraftingUI;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Events.CloseEvent;
   import Events.GenericPopupEvent;
   import Managers.Crafting.CraftingManager;
   import Managers.Crafting.MarketViewManager;
   import Managers.ExchangeManager;
   import Managers.FarmStatsManager;
   import Managers.SubscriptionsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmTabButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Crafting.HomeMarketStallInventoryFrame;
   import Widgets.Frames.Crafting.HomeMarketStallShopSlotFrame;
   import Widgets.Frames.GenericExpandSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.UseAllAmountSelectionWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class HomeMarketStallWindow extends FarmWindow
   {
      
      private const FEED_BUNDLE_ID_SHARE_BUSHEL:String = "CraftingShareFromStall";
      
      private const BUSHEL_INVENTORY_MODE:String = "bushel_inventory";
      
      private const BUSHEL_SHOP_MODE:String = "bushel_shope";
      
      private const EOS_PLAYERLOVE_2018:String = "fv_playerlove_2018";
      
      private var m_mode:String = "bushel_inventory";
      
      private var m_stallStatusUpdateTime:int = 0;
      
      private var m_stallStatusFrame:ZwFrame;
      
      private var m_stallStatusText:ZwTextField;
      
      private var m_closeStallButton:FarmAnimatedTextButton;
      
      private var m_bushelInventoryModeButton:FarmTabButton;
      
      private var m_bushelShopModeButton:FarmTabButton;
      
      private var m_craftedGoodInventoryModeButton:FarmTabButton;
      
      private var m_craftedGoodShopModeButton:FarmTabButton;
      
      private var m_bushelSwapButton:FarmTabButton;
      
      private var m_mainTabButton:FarmTabButton;
      
      private var m_expandTabButton:FarmTabButton;
      
      private var m_bushelInventoryFrame:HomeMarketStallInventoryFrame;
      
      private var m_bushelShopFrame:HomeMarketStallShopSlotFrame;
      
      private var m_marketStallBuilding:MarketStallBuilding;
      
      private var m_forceRewardPopup:Boolean = false;
      
      private var m_cropBoostWindow:CropBoostWindow = null;
      
      private var m_shareMarketStallWindow:UseAllAmountSelectionWindow = null;
      
      private var m_marketRewardWindow:MarketRewardSocialWindow;
      
      private var m_exchangeItemCode:String;
      
      private var m_expandFrame:GenericExpandSlotFrame = null;
      
      private var m_defaultExpandTab:Boolean = false;
      
      protected var m_searchBar_mc:ZwWidget = null;
      
      private var m_clearSearchButton_mc:FarmAnimatedButton = null;
      
      private var m_clearedSearch:Boolean = false;
      
      private var m_search_mc:ZwWidget = null;
      
      private var m_searchField_tf:ZwTextField = null;
      
      private var m_defaultString:String = ZLocUtils.t("Dialogs","Search");
      
      private var m_noResultsText:ZwTextField = null;
      
      private var m_bushelSerachingVariant:int = 0;
      
      public function HomeMarketStallWindow(marketStallBuilding:MarketStallBuilding = null, forceRewardPopup:Boolean = false, defaultExpandTab:Boolean = false)
      {
         var asset:String = "assets/dialogs/FV_Craft_MyStall_expand.swf";
         this.m_bushelSerachingVariant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BUSHEL_SORTING);
         if(this.m_bushelSerachingVariant != 0)
         {
            asset = "assets/dialogs/FV_Craft_MyStall_expand2.swf";
         }
         if(ExchangeManager.getInstance().isInMainExperiment(ExchangeManager.TRADER_BUSHEL))
         {
            asset = "assets/dialogs/FV_Craft_MyStall_expand3.swf";
         }
         if(SubscriptionsManager.isRetentionProgramActivated())
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FARMERS_MARKET_SEARCH) == 1)
            {
               asset = "assets/dialogs/FV_Craft_MyStall_expand6.swf";
            }
            else
            {
               asset = "assets/dialogs/FV_Craft_MyStall_expand4.swf";
            }
            if(Global.eosManager.getEosVariant(this.EOS_PLAYERLOVE_2018) >= 1)
            {
               asset = "assets/dialogs/FV_Craft_MyStall_expand7.swf";
            }
         }
         super(asset);
         Global.player.craftingState.inventoryState.marketStallItems = CraftingManager.getInstance().pruneCraftingInventory(Global.player.craftingState.inventoryState.marketStallItems);
         this.m_marketStallBuilding = marketStallBuilding;
         this.m_forceRewardPopup = forceRewardPopup;
         this.m_defaultExpandTab = defaultExpandTab;
      }
      
      private static function sortByFriendlyName(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         var score1:String = ZLocUtils.tk_pk_asTitle((obj1 as FarmItem).friendlyName);
         var score2:String = ZLocUtils.tk_pk_asTitle((obj2 as FarmItem).friendlyName);
         if(score1 > score2)
         {
            result = -1;
         }
         else if(score1 < score2)
         {
            result = 1;
         }
         return result;
      }
      
      override public function refreshWindow() : void
      {
         this.m_expandFrame.refresh();
      }
      
      override protected function postLoadComplete() : void
      {
         var stallOpen:Boolean = false;
         var bushelFriendlyNameTK:String = null;
         var item:FarmItem = null;
         var icon:FarmIcon = null;
         var rewards:Array = null;
         var reward:PendingReward = null;
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Crafting","HomeMarketStallDialog_Title")));
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
         if(this.m_marketStallBuilding != null)
         {
            stallOpen = this.m_marketStallBuilding.isConfigured && this.m_marketStallBuilding.secondsTillClosed > 0;
            if(stallOpen)
            {
               bushelFriendlyNameTK = Global.farmGameSettingsManager.getFarmItemByCode(this.m_marketStallBuilding.bushelItemCode).friendlyName;
               this.m_stallStatusFrame = addWidget(new ZwFrame(m_window.stallStatus_mc)) as ZwFrame;
               this.m_stallStatusFrame.addWidget(new ZwTextField(m_window.stallStatus_mc.generic_tf,ZLocUtils.t("Crafting","HomeMarketStallDialog_BushelStatusTitle")));
               this.m_stallStatusText = this.m_stallStatusFrame.addWidget(new ZwTextField(m_window.stallStatus_mc.generic2_tf,ZLocUtils.t("Crafting","MarketStallDialog_CropTypeText",{"bushelItem":ZLocUtils.tk_pk(bushelFriendlyNameTK)}))) as ZwTextField;
               item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_marketStallBuilding.bushelItemCode);
               icon = new FarmIcon(m_window.stallStatus_mc.icon_mc,item.icon);
               this.m_stallStatusFrame.addWidget(icon);
               this.m_closeStallButton = this.m_stallStatusFrame.addWidget(new FarmAnimatedTextButton(m_window.stallStatus_mc.closeStall_bt,ZLocUtils.t("Crafting","HomeMarketStallDialog_CloseStallButton"),this.onCloseStallButtonClick),false) as FarmAnimatedTextButton;
               (this.m_stallStatusFrame.element as MovieClip).addEventListener(MouseEvent.MOUSE_OVER,this.onStallStatusMouseOver,false,0,true);
               (this.m_stallStatusFrame.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onStallStatusMouseOut,false,0,true);
            }
         }
         this.m_mainTabButton = addWidget(new FarmTabButton(m_window.main_bt,ZLocUtils.t("Dialogs","Main"),this.onMainButtonClicked)) as FarmTabButton;
         this.m_expandTabButton = addWidget(new FarmTabButton(m_window.expand_bt,ZLocUtils.t("Dialogs","Expand"),this.onExpandButtonClicked)) as FarmTabButton;
         if(Boolean(this.m_marketStallBuilding) && !this.m_marketStallBuilding.readyToExpand())
         {
            this.m_expandTabButton.visible = false;
            this.m_mainTabButton.visible = false;
         }
         this.m_bushelInventoryModeButton = addWidget(new FarmTabButton(m_window.bushelInventory_bt,ZLocUtils.t("Crafting","HomeMarketStallDialog_BushelInventoryButton"),this.onBushelInventoryMode)) as FarmTabButton;
         this.m_bushelShopModeButton = addWidget(new FarmTabButton(m_window.bushelGet_bt,ZLocUtils.t("Crafting","HomeMarketStallDialog_BushelShopButton"),this.onBushelShopMode)) as FarmTabButton;
         this.m_craftedGoodInventoryModeButton = addWidget(new FarmTabButton(m_window.goodsInventory_bt,ZLocUtils.t("Crafting","HomeMarketStallDialog_CraftedGoodInventoryButton"),this.onCraftedGoodInventoryMode)) as FarmTabButton;
         this.m_craftedGoodShopModeButton = addWidget(new FarmTabButton(m_window.goodsGet_bt,ZLocUtils.t("Crafting","HomeMarketStallDialog_CraftedGoodShopButton"),this.onCraftedGoodShopMode)) as FarmTabButton;
         if(m_window.hasOwnProperty("bushelSwap_bt"))
         {
            this.m_bushelSwapButton = addWidget(new FarmTabButton(m_window.bushelSwap_bt,ZLocUtils.t("Crafting","HomeMarketStallDialog_BushelSwapButton"),this.onBushelSwap)) as FarmTabButton;
         }
         this.m_bushelInventoryFrame = addWidget(new HomeMarketStallInventoryFrame(m_window.bushelInventoryFrame_mc,this.onBushelUsed,this.onBushelShared)) as HomeMarketStallInventoryFrame;
         this.m_bushelShopFrame = addWidget(new HomeMarketStallShopSlotFrame(m_window.bushelGetFrame_mc,[],this.onGetItem,this)) as HomeMarketStallShopSlotFrame;
         if(SubscriptionsManager.isRetentionProgramActivated())
         {
            if(SubscriptionsManager.instance.isSubscriber())
            {
               addWidget(new ZwWidget(m_window.vipTag_mc));
            }
         }
         if(this.m_marketStallBuilding != null)
         {
            this.m_expandFrame = new GenericExpandSlotFrame(m_window.expand_mc,this.getExpansionItemData(),this,this.m_marketStallBuilding,this.m_marketStallBuilding.expandManager);
            addWidget(this.m_expandFrame);
            m_window.expand_mc.generic_tf.text = ZLocUtils.t("Crafting","HomeMarketStallDialog_Expand");
            this.m_expandFrame.visible = false;
         }
         addWidget(new FarmAnimatedTextButton(m_window.howDoes_mc,ZLocUtils.t("Crafting","MarketStall_HowDoesThisWork"),this.onHowDoesThisWorkClick));
         if(this.m_defaultExpandTab && this.m_expandTabButton.visible)
         {
            this.onExpandButtonClicked(null);
         }
         else
         {
            this.setMode(this.BUSHEL_SHOP_MODE);
         }
         if(this.m_forceRewardPopup && CraftingManager.getInstance().hasPendingMarketReward())
         {
            rewards = Global.player.craftingState.pendingRewards;
            for each(reward in rewards)
            {
               if(!reward.claimed)
               {
                  StatsManager.social("notify",reward.visitorUid,"bushel_take","bushel");
               }
            }
            this.displayMarketRewardWindow();
         }
      }
      
      private function toggleButtons(value:Boolean) : void
      {
         this.m_bushelInventoryModeButton.visible = value;
         this.m_bushelShopModeButton.visible = value;
         this.m_craftedGoodInventoryModeButton.visible = value;
         this.m_craftedGoodShopModeButton.visible = value;
         if(this.m_bushelSwapButton != null)
         {
            this.m_bushelSwapButton.visible = value;
         }
      }
      
      private function onMainButtonClicked(event:Event) : void
      {
         this.setMode(this.BUSHEL_SHOP_MODE);
         this.m_expandFrame.visible = false;
         this.toggleButtons(true);
      }
      
      private function getExpansionItemData() : Array
      {
         var part:PartItem = null;
         var parts:Array = this.m_marketStallBuilding.getConstructionItems();
         var toReturn:Array = new Array();
         for each(part in parts)
         {
            toReturn.push({"name":part.item.name});
         }
         toReturn.push({"sendGiftsToFriends":true});
         return toReturn;
      }
      
      private function onExpandButtonClicked(event:Event) : void
      {
         this.m_bushelInventoryFrame.visible = false;
         this.m_bushelShopFrame.visible = false;
         this.m_expandFrame.visible = true;
         this.toggleButtons(false);
         this.m_marketStallBuilding.conditionallySurfaceExpandFeed();
      }
      
      private function onHowDoesThisWorkClick(event:Event) : void
      {
         tintWindow();
         enableInput = false;
         TutorialUI.displayNewMarketStallTutorialWindow(false,this.onHowDoesThisWorkClose);
      }
      
      private function onHowDoesThisWorkClose() : void
      {
         untintWindow();
         enableInput = true;
      }
      
      private function onLatestMarketViewReady() : void
      {
         var items:Array = null;
         enableInput = true;
         if(this.m_bushelShopFrame)
         {
            items = MarketViewManager.getInstance().getAllBushelsAvailable();
            items.sort(sortByFriendlyName);
            items.reverse();
            this.m_bushelShopFrame.updateItems(items);
         }
      }
      
      private function refresh() : void
      {
         enableInput = true;
         switch(this.m_mode)
         {
            default:
            case this.BUSHEL_INVENTORY_MODE:
               this.m_bushelInventoryFrame.refresh();
               break;
            case this.BUSHEL_SHOP_MODE:
               enableInput = false;
               MarketViewManager.getInstance().beginEnsureMarketViewAge(this.onLatestMarketViewReady);
         }
      }
      
      private function setMode(mode:String) : void
      {
         this.m_mode = mode;
         switch(this.m_mode)
         {
            default:
            case this.BUSHEL_INVENTORY_MODE:
               this.m_bushelInventoryModeButton.setToggleState(ZwToggleState.SELECTED);
               this.m_bushelShopModeButton.setToggleState(ZwToggleState.DESELECTED);
               this.m_bushelInventoryFrame.visible = true;
               this.m_bushelShopFrame.visible = false;
               break;
            case this.BUSHEL_SHOP_MODE:
               this.m_bushelInventoryModeButton.setToggleState(ZwToggleState.DESELECTED);
               this.m_bushelShopModeButton.setToggleState(ZwToggleState.SELECTED);
               this.m_bushelInventoryFrame.visible = false;
               this.m_bushelShopFrame.visible = true;
         }
         this.refresh();
      }
      
      private function onStallStatusMouseOver(evt:MouseEvent) : void
      {
         if(!this.m_closeStallButton.visible)
         {
            this.m_closeStallButton.visible = true;
            this.m_stallStatusText.text = ZLocUtils.t("Crafting","HomeMarketStallDialog_BushelStatusTimeRemaining",{"timeStr":FarmGameUtil.toFriendlyTime(this.m_marketStallBuilding.secondsTillClosed)});
            this.m_stallStatusUpdateTime = GlobalEngine.currentTime;
         }
      }
      
      private function onStallStatusMouseOut(evt:MouseEvent) : void
      {
         var bushelItemTK:String = null;
         if(evt.relatedObject != this.m_stallStatusFrame.element && evt.relatedObject.parent != this.m_stallStatusFrame.element)
         {
            this.m_closeStallButton.visible = false;
            bushelItemTK = Global.farmGameSettingsManager.getFarmItemByCode(this.m_marketStallBuilding.bushelItemCode).friendlyName;
            this.m_stallStatusText.text = ZLocUtils.t("Crafting","MarketStallDialog_CropTypeText",{"bushelItem":ZLocUtils.tk_pk(bushelItemTK)});
         }
      }
      
      private function onCloseStallButtonClick(evt:MouseEvent) : void
      {
         enableInput = false;
         CraftingStatsManager.recordMyStallPageCloseStallClick();
         UI.displayMessage(ZLocUtils.t("Crafting","MarketStallDialog_ConfirmMarketStallClose"),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmMarketStallClose,"confirmMarketStallClose",true);
      }
      
      private function onConfirmMarketStallClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            CraftingStatsManager.recordMyStallPageCloseStallClickConfirm();
            CraftingManager.getInstance().closeMarketStall(this.m_marketStallBuilding);
            this.m_stallStatusFrame.visible = false;
         }
         enableInput = true;
      }
      
      private function onBushelInventoryMode(evt:Event) : void
      {
         this.setMode(this.BUSHEL_INVENTORY_MODE);
      }
      
      private function onBushelShopMode(evt:Event) : void
      {
         this.setMode(this.BUSHEL_SHOP_MODE);
      }
      
      private function onCraftedGoodInventoryMode(evt:Event) : void
      {
         enableInput = false;
         CraftingUI.displayCraftingUseGoodsWindow(this,this.onUseCraftedGoodsWindowClose);
      }
      
      private function onUseCraftedGoodsWindowClose(evt:Event = null) : void
      {
         enableInput = true;
      }
      
      private function onCraftedGoodShopMode(evt:Event) : void
      {
         enableInput = false;
         CraftingUI.displayCraftingGetGoodsWindow(this.onGetCraftedGoodsWindowClose);
      }
      
      private function onBushelSwap(evt:Event) : void
      {
         ExchangeManager.getInstance().openWindow(ExchangeManager.TRADER_BUSHEL);
         this.close();
      }
      
      private function onGetCraftedGoodsWindowClose(evt:Event = null) : void
      {
         enableInput = true;
      }
      
      private function onBushelUsed(itemCode:String) : void
      {
         var bushelItem:FarmItem = null;
         var defaultBushel:FarmItem = null;
         var inventoryCount:int = 0;
         var iconDialog:GenericIconPopup = null;
         var isExpiredBushel:Boolean = CraftingManager.getInstance().isBushelExpired(itemCode);
         var inventoryQuantity:int = CraftingManager.getInstance().getBushelQuantityInInventory(itemCode);
         if(isExpiredBushel && inventoryQuantity > 0)
         {
            bushelItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            defaultBushel = CraftingManager.getInstance().getDefaultExchangeBushel();
            if(Boolean(bushelItem) && Boolean(defaultBushel))
            {
               inventoryCount = CraftingManager.getInstance().getBushelQuantityInInventory(bushelItem.code);
               iconDialog = new GenericIconPopup(ZLocUtils.t("Crafting","LimitedRecipes_Exchange_Action",{
                  "quantityA":inventoryCount,
                  "bushelA":ZLocUtils.tk_pk(bushelItem.friendlyName,"",inventoryCount),
                  "quantityB":inventoryCount,
                  "bushelB":ZLocUtils.tk_pk(defaultBushel.friendlyName,"",inventoryCount)
               }),GenericPopup.TYPE_OK,this.onExchangeLimitedBushels,bushelItem.icon,false,true,"",true);
               iconDialog.setAcceptTextName("Trade");
               this.m_exchangeItemCode = itemCode;
               UI.displayPopup(iconDialog,false);
            }
         }
         else if(this.m_cropBoostWindow == null)
         {
            this.m_cropBoostWindow = new CropBoostWindow(itemCode,this.onBushelConsumed);
            this.m_cropBoostWindow.addEventListener(Event.CLOSE,this.onCropBoostWindowClosed,false,0,true);
            UI.displayPopup(this.m_cropBoostWindow,false);
            UI.stopPopups(true);
            enableInput = false;
         }
      }
      
      private function onExchangeLimitedBushels(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            CraftingManager.getInstance().exchangeLimitedBushels(this.m_exchangeItemCode,this.onSuccessExchange);
         }
         this.m_exchangeItemCode = "";
      }
      
      private function onSuccessExchange(result:Object) : void
      {
         var beginOOS_itemsStr:String = null;
         var numExchangedBushels:Number = NaN;
         var bushel:Object = null;
         if(Boolean(result) && Boolean(result.success == true) && result.bushels != null)
         {
            numExchangedBushels = 0;
            for each(bushel in result.bushels)
            {
               if(bushel.itemQuantity == 0)
               {
                  CraftingManager.getInstance().deductItemFromCraftingInventory(bushel.itemCode,numExchangedBushels);
                  if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CRAFTING_OOS_STATS2) > 0)
                  {
                     beginOOS_itemsStr = "item_" + bushel.itemCode + ":" + numExchangedBushels;
                     FarmStatsManager.count("beginOOS","client","deduct_marketstallwindowSuccess",beginOOS_itemsStr);
                  }
               }
               else
               {
                  numExchangedBushels = Number(bushel.itemQuantity);
                  CraftingManager.getInstance().addItemToInventory(bushel.itemCode,bushel.itemQuantity);
                  if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CRAFTING_OOS_STATS) > 0)
                  {
                     beginOOS_itemsStr = "item_" + bushel.itemCode + ":" + bushel.itemQuantity;
                     FarmStatsManager.count("beginOOS","client","add_marketstallwindowSuccess",beginOOS_itemsStr);
                  }
               }
            }
            this.refresh();
         }
      }
      
      private function onCropBoostWindowClosed(evt:Event) : void
      {
         if(this.m_cropBoostWindow != null)
         {
            this.m_cropBoostWindow.removeEventListener(Event.CLOSE,this.onCropBoostWindowClosed);
            this.m_cropBoostWindow = null;
            enableInput = true;
         }
      }
      
      private function onBushelConsumed(itemCode:String) : void
      {
         CraftingManager.getInstance().consumeBushelForBuff(itemCode);
         this.refresh();
      }
      
      private function onBushelShared(item:FarmItem, data:MarketInventoryItem) : void
      {
         var textBundle:Object = null;
         var optionsBundle:Object = null;
         if(this.m_shareMarketStallWindow == null)
         {
            textBundle = {};
            textBundle[UseAllAmountSelectionWindow.TEXT_KEY_TITLE] = ZLocUtils.t("Crafting","ShareMarketStallWindow_Body",{"bushelitem":ZLocUtils.tk_pk(item.friendlyName)});
            optionsBundle = {};
            optionsBundle[UseAllAmountSelectionWindow.OPTION_KEY_STARTING_QUANTITY] = 1;
            this.m_shareMarketStallWindow = new UseAllAmountSelectionWindow(item,data.quantity,1,this.onBushelSharedCallBack,this.onBushelSharedWindowClosed,textBundle,optionsBundle);
            UI.displayPopup(this.m_shareMarketStallWindow,false);
            enableInput = false;
         }
      }
      
      private function onBushelSharedWindowClosed(data:Object) : void
      {
         this.cleanupShareWindow();
      }
      
      private function onBushelSharedCallBack(data:Object) : void
      {
         if(data != null && data.item != null && data.quantitySelected != null)
         {
            CraftingManager.getInstance().shareBushel(data.item.code,data.quantitySelected,this.FEED_BUNDLE_ID_SHARE_BUSHEL);
         }
         this.cleanupShareWindow();
         this.refresh();
      }
      
      private function cleanupShareWindow() : void
      {
         if(this.m_shareMarketStallWindow != null)
         {
            this.m_shareMarketStallWindow = null;
            enableInput = true;
         }
      }
      
      private function onGetItem(uid:String, itemCode:String) : void
      {
         CraftingUI.displayVisitingMarketStallWindow(uid,"bushels",this.onVisitingMarketStallWindowClose,"",itemCode);
         enableInput = false;
      }
      
      private function onVisitingMarketStallWindowClose(evt:Event = null) : void
      {
         this.refresh();
      }
      
      private function displayMarketRewardWindow() : void
      {
         if(null == this.m_marketRewardWindow)
         {
            enableInput = false;
            this.m_marketRewardWindow = new MarketRewardSocialWindow();
            this.m_marketRewardWindow.addEventListener(CloseEvent.CLOSE,this.onMarketRewardWindowClose);
            UI.displayPopup(this.m_marketRewardWindow,false);
            CraftingManager.getInstance().incrementOpenPopups();
         }
      }
      
      private function onMarketRewardWindowClose(event:Event) : void
      {
         if(this.m_marketRewardWindow)
         {
            this.m_marketRewardWindow.removeEventListener(CloseEvent.CLOSE,this.onMarketRewardWindowClose);
            this.m_marketRewardWindow = null;
            CraftingManager.getInstance().decrementOpenPopups();
            enableInput = true;
         }
      }
      
      private function onMarketRewardsClaimed() : void
      {
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
         this.m_bushelInventoryFrame.updateSearchString(this.m_searchField_tf.text);
         this.m_bushelInventoryFrame.refresh();
      }
      
      public function enterFrame() : void
      {
         var secondsTillClosed:Number = NaN;
         if(this.m_stallStatusFrame != null && this.m_stallStatusFrame.visible)
         {
            if(GlobalEngine.currentTime - this.m_stallStatusUpdateTime > 1000)
            {
               this.m_stallStatusUpdateTime = GlobalEngine.currentTime;
               secondsTillClosed = this.m_marketStallBuilding.secondsTillClosed;
               if(secondsTillClosed > 0)
               {
                  if(this.m_closeStallButton.visible)
                  {
                     this.m_stallStatusText.text = ZLocUtils.t("Crafting","HomeMarketStallDialog_BushelStatusTimeRemaining",{"timeStr":FarmGameUtil.toFriendlyTime(secondsTillClosed)});
                  }
               }
               else
               {
                  this.m_stallStatusFrame.visible = false;
               }
            }
         }
      }
      
      override protected function release() : void
      {
         if(this.m_stallStatusFrame != null)
         {
            (this.m_stallStatusFrame.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OVER,this.onStallStatusMouseOver);
            (this.m_stallStatusFrame.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OUT,this.onStallStatusMouseOut);
         }
         if(m_window != null && Boolean(m_window["searchBar_mc"]))
         {
            (m_window.searchBar_mc.searchField_tf as TextField).removeEventListener(FocusEvent.FOCUS_IN,this.disableShortcut);
            (m_window.searchBar_mc.searchField_tf as TextField).removeEventListener(FocusEvent.FOCUS_OUT,this.enableShortcut);
            (m_window.searchBar_mc.searchField_tf as TextField).removeEventListener(MouseEvent.CLICK,this.onSearchTextButtonClick);
            (m_window.searchBar_mc.searchField_tf as TextField).removeEventListener(KeyboardEvent.KEY_UP,this.onKeyUpHandler);
         }
         this.m_stallStatusFrame = null;
         this.m_stallStatusText = null;
         this.m_closeStallButton = null;
         this.m_bushelInventoryModeButton = null;
         this.m_bushelShopModeButton = null;
         this.m_craftedGoodInventoryModeButton = null;
         this.m_craftedGoodShopModeButton = null;
         this.m_bushelSwapButton = null;
         this.m_bushelInventoryFrame = null;
         this.m_bushelShopFrame = null;
         this.m_marketStallBuilding = null;
         this.m_cropBoostWindow = null;
         this.m_shareMarketStallWindow = null;
         this.m_marketRewardWindow = null;
         super.release();
      }
   }
}

