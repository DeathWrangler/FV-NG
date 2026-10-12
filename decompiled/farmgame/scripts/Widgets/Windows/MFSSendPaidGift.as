package Widgets.Windows
{
   import Classes.Animal;
   import Classes.Constants.Experiments;
   import Classes.Constants.MFSConstants;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.Plot;
   import Classes.SimpleHarvestableResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.DisplayObjectUtils;
   import Classes.util.FarmGameUtil;
   import Classes.util.PaymentUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.InGamePaymentsManager;
   import Transactions.TBuyAndSendPresent;
   import Transactions.TGenericTransaction;
   import Transactions.TRefreshBalance;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmTabButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Tooltips.ZwAbstractTooltip;
   import Widgets.Frames.MFSWindowSlotFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Menu.DropDownMenu;
   import Widgets.Menu.MenuItem;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class MFSSendPaidGift extends MFSSendGiftBase
   {
      
      protected var m_giftItem:FarmItem;
      
      private var m_context:String;
      
      private var m_buyButton:ZwButton = null;
      
      private var m_buyButtonCostField:ZwTextField = null;
      
      private var m_buyButtonDescription:ZwTextField = null;
      
      protected var m_sortByButton:FarmTabButton;
      
      protected var m_sortByMenu:DropDownMenu;
      
      private var m_friendSelectedCount:ZwTextField = null;
      
      private var m_giftItemName:ZwTextField = null;
      
      private var m_giftObject:ObjectPreviewFrame = null;
      
      private var m_isBuying:Boolean = false;
      
      protected var m_successCallback:Function = null;
      
      private var m_hideOnCongrats:Boolean = false;
      
      protected var m_dialogURL:String;
      
      private var m_giftingStatsCounter:String = StatsTrackingConstants.MARKETPLACE_GIFTING;
      
      public function MFSSendPaidGift(giftItem:FarmItem, source:String, completeCallback:Function, giftingStatsCounter:String = null)
      {
         var friendSpec:Object = {
            "MarketplaceGifting_SortRecommended":["CurrentMostGifts"],
            "MarketplaceGifting_SortHelpful":["CurrentMostHelpful"],
            "MarketplaceGifting_SortAlphabetical":["CurrentFriendsAlpha"]
         };
         var friendTabOrder:Array = ["MarketplaceGifting_SortRecommended","MarketplaceGifting_SortHelpful","MarketplaceGifting_SortAlphabetical"];
         this.m_giftItem = giftItem;
         this.m_context = source;
         if(!this.m_dialogURL)
         {
            this.m_dialogURL = "assets/dialogs/FV_MarketplaceGifting.swf";
         }
         if(giftingStatsCounter != null)
         {
            this.m_giftingStatsCounter = giftingStatsCounter;
         }
         super(giftItem,source,false,completeCallback,"MarketplaceGifting",friendSpec,friendTabOrder,this.m_dialogURL);
         m_batchLimit = 14;
         this.m_hideOnCongrats = true;
         this.m_successCallback = this.reactivateCallback;
      }
      
      public static function get giftingV2Enabled() : Boolean
      {
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_GIFTING_V2);
         return variant > 1;
      }
      
      override protected function sendPopulatingTransaction() : void
      {
         var paramArray:Array = [convertToUniqueValuesArray(friendSpec)];
         TransactionManager.addTransaction(new TGenericTransaction("FriendListService","getFriendsForPaidGifting",onFriendPopulation,paramArray),true);
      }
      
      override protected function fbResponseAction(requestIds:Array) : void
      {
         this.triggerGiftPurchase(requestIds);
      }
      
      override protected function getStatsFlowName() : String
      {
         return MFSConstants.MFS_TYPE_SEND_PAID_GIFT;
      }
      
      override protected function onClose(event:Event) : void
      {
         UI.enableMarketDialog();
         if(event != null)
         {
            FarmStatsManager.count(this.m_giftingStatsCounter,"gifting_mfs","close_click");
         }
         if(m_completeCallback != null)
         {
            m_completeCallback();
         }
         super.onClose(event);
      }
      
      public function closeCallback() : void
      {
         this.onClose(null);
      }
      
      public function reactivateCallback() : void
      {
         this.m_isBuying = false;
         enableInput = true;
         setVisibleChild(m_friendsSlotFrame,true);
         setVisibleChild(m_loadingSpinner,false);
         this.updateButtonVisibility();
         this.refresh();
         if(m_currentlyDisplayedFriends.length < 1)
         {
            this.closeCallback();
         }
         else
         {
            visible = true;
         }
      }
      
      override protected function updateButtonVisibility() : void
      {
         super.updateButtonVisibility();
         this.updateBuyButton();
         this.updateFriendSelectCount();
         if(m_loadingComplete)
         {
            if(m_currentlyDisplayedFriends.length < 1 || this.m_isBuying)
            {
               this.m_sortByButton.visible = false;
               this.m_friendSelectedCount.visible = false;
            }
            else
            {
               this.m_sortByButton.visible = true;
               this.m_friendSelectedCount.visible = true;
            }
         }
      }
      
      override protected function release() : void
      {
         if(this.m_sortByButton)
         {
            (this.m_sortByButton.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OVER,this.onSortByMouseOver);
            (this.m_sortByButton.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OUT,this.onSortByMouseOut);
            this.m_sortByButton = null;
         }
         if(this.m_sortByMenu)
         {
            (this.m_sortByMenu.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OUT,this.onSortByMouseOut);
            this.m_sortByMenu = null;
         }
         m_windowBgTextField = null;
         this.m_buyButtonCostField = null;
         this.m_buyButtonDescription = null;
         this.m_buyButton = null;
         this.m_giftItemName = null;
         this.m_friendSelectedCount = null;
         this.m_giftObject = null;
         super.release();
      }
      
      override protected function postLoadComplete() : void
      {
         var tabName:String = null;
         var terrain:String = null;
         var menuItem:MenuItem = null;
         var terrainOverlayName:String = null;
         super.postLoadComplete();
         if(this.m_giftingStatsCounter != StatsTrackingConstants.MARKETPLACE_GIFTING && this.m_giftingStatsCounter != StatsTrackingConstants.MARKETPLACE_EA_GIFTING)
         {
            m_titleTextField.text = ZLocUtils.t("Dialogs",this.m_giftingStatsCounter + "_Title");
         }
         if(m_windowBgTextField)
         {
            m_windowBgTextField.text = ZLocUtils.t("Dialogs","MarketplaceGifting_NoFriendsInTab_Body",{"itemName":this.m_giftItem.friendlyTitle});
         }
         this.m_buyButton = addWidget(new FarmAnimatedTextButton(m_window.buy_bt,"",this.onClickBuy)) as ZwButton;
         this.m_buyButtonCostField = addWidget(new ZwTextField(m_window.buy_bt.buy_mc.fc_amount_tf,"0")) as ZwTextField;
         this.m_buyButtonDescription = addWidget(new ZwTextField(m_window.buy_bt.buy_mc.generic_tf,ZLocUtils.t("Dialogs","MarketplaceGifting_BuyAndSend"))) as ZwTextField;
         this.m_buyButton.visible = true;
         DisplayObjectUtils.grayOut(this.m_buyButton.element as Sprite,true);
         this.updateTotalCost();
         this.m_sortByButton = addWidget(new FarmTabButton(m_window.sortBy_bt,ZLocUtils.t("Dialogs","SortBy"))) as FarmTabButton;
         (this.m_sortByButton.element as MovieClip).addEventListener(MouseEvent.MOUSE_OVER,this.onSortByMouseOver,false,0,true);
         (this.m_sortByButton.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onSortByMouseOut,false,0,true);
         this.m_sortByMenu = addWidget(new DropDownMenu(m_window.frame_subNav2_mc,this.onSortByMenuItemSelected),false) as DropDownMenu;
         (this.m_sortByMenu.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onSortByMouseOut,false,0,true);
         this.m_sortByButton.setToggleState(ZwToggleState.DESELECTED);
         this.m_sortByMenu.visible = false;
         var sortByMenuItems:Array = [];
         for each(tabName in m_tabNames)
         {
            menuItem = new MenuItem(tabName,ZLocUtils.t("Dialogs",tabName));
            sortByMenuItems.push(menuItem);
         }
         this.m_sortByMenu.items = sortByMenuItems;
         this.m_sortByButton.visible = false;
         this.m_friendSelectedCount = addWidget(new ZwTextField(m_window.friendCount_tf,"")) as ZwTextField;
         this.m_friendSelectedCount.visible = false;
         this.updateFriendSelectCount();
         this.m_giftItemName = addWidget(new ZwTextField(m_window.item_tf,ZLocUtils.t("Dialogs","MarketplaceGifting_ItemName",{"itemName":this.m_giftItem.friendlyTitle}))) as ZwTextField;
         this.m_giftItemName.visible = true;
         terrain = Global.farmGameSettingsManager.selectPrimaryTerrainNameFromGivenCodes(this.m_giftItem.getTerrainCodes());
         if(terrain != FarmGameSettingsManager.TERRAIN_DEFAULT)
         {
            terrainOverlayName = terrain + "_mc";
            if(m_window.hasOwnProperty(terrainOverlayName))
            {
               addWidget(new ZwWidget(m_window[terrainOverlayName]),true);
            }
         }
         var itemState:String = "";
         var scale:Number = 2.4;
         switch(this.m_giftItem.type)
         {
            case "seed":
            case "plot":
               itemState = Plot.STATE_GROWN;
               break;
            case "tree":
               itemState = SimpleHarvestableResource.STATE_RIPE;
               scale = 2;
               break;
            case "animal":
            case "gopher":
               itemState = Animal.STATE_FRONT_IDLE;
               scale = this.m_giftItem.sizeX == 1 ? 3.5 : 3.25;
         }
         this.createObjectPreview(scale,itemState);
         FarmStatsManager.count(this.m_giftingStatsCounter,"gifting_mfs","impressions");
      }
      
      protected function createObjectPreview(scale:Number, itemState:String) : void
      {
         this.m_giftObject = new ObjectPreviewFrame(m_window.item_mc,this.m_giftItem,null,[scale],null,itemState);
         addWidget(this.m_giftObject,true);
         this.m_giftObject.visible = true;
      }
      
      private function onSortByMouseOver(evt:MouseEvent) : void
      {
         if(!this.m_sortByMenu.visible)
         {
            this.m_sortByButton.setToggleState(ZwToggleState.SELECTED);
            this.m_sortByMenu.visible = true;
         }
      }
      
      private function onCloseWarning() : void
      {
         this.toggleButtonsOnWarningEnable(true);
      }
      
      override protected function navigatePage(navigatePageBy:int) : void
      {
         if(m_friendsSlotFrame.checkSelectedStatus(m_currentlyDisplayedFriends.length) == MFSWindowSlotFrame.SELECT_STATE_MIX)
         {
            UI.displayPopup(new MFSWarning(this.onCloseWarning,conditionallyLoadNextBatch,false,navigatePageBy,m_statsFlowName,"MarketplaceGifting_Warning"),false);
            this.toggleButtonsOnWarningEnable(false);
         }
         else
         {
            conditionallyLoadNextBatch(false,navigatePageBy);
         }
      }
      
      override protected function toggleButtonsOnWarningEnable(enable:Boolean) : void
      {
         super.toggleButtonsOnWarningEnable(enable);
         this.m_buyButton.enabled = enable;
      }
      
      private function updateFriendSelectCount() : void
      {
         var numFriends:int = 0;
         var numSelected:int = 0;
         if(this.m_isBuying)
         {
            this.m_friendSelectedCount.visible = false;
         }
         else
         {
            this.m_friendSelectedCount.visible = true;
            numFriends = 0;
            numFriends = int(m_currentlyDisplayedFriends.length);
            numSelected = numSelectedFriends;
            this.m_friendSelectedCount.text = ZLocUtils.t("Dialogs","MarketplaceGifting_FriendsSelected",{
               "selected":numSelected,
               "max":numFriends
            });
         }
      }
      
      private function updateTotalCost() : void
      {
         var cost:String = String(this.totalGiftCost);
         this.m_buyButtonCostField.text = cost;
      }
      
      override protected function postRefreshActions() : void
      {
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_GIFTING_V2);
         var defaultSortingVariant:int = Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_MARKET_GIFTING_V2_SORTING);
         var defaultTab:int = Math.max(defaultSortingVariant - 1,0);
         m_currentTab = defaultTab;
         this.refresh(false);
      }
      
      private function get totalGiftCost() : int
      {
         var mult:int = numSelectedFriends;
         if(mult < 1)
         {
            mult = 1;
         }
         return this.m_giftItem.realCashCost * mult;
      }
      
      private function updateBuyButton() : void
      {
         this.updateTotalCost();
         var tooltip:ZwAbstractTooltip = null;
         if(m_loadingComplete)
         {
            if(this.m_isBuying)
            {
               DisplayObjectUtils.grayOut(this.m_buyButton.element as Sprite,true);
               this.m_buyButtonDescription.text = ZLocUtils.t("Dialogs","MarketplaceGifting_Buying");
               tooltip = this.m_buyButton.detachTooltip();
               if(tooltip)
               {
                  tooltip.release();
               }
               this.m_buyButton.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","MarketplaceGifting_Buying")));
            }
            else if(m_currentlyDisplayedFriends.length < 1)
            {
               this.m_buyButton.visible = true;
               DisplayObjectUtils.grayOut(this.m_buyButton.element as Sprite,true);
               this.m_buyButtonDescription.text = ZLocUtils.t("Dialogs","MarketplaceGifting_BuyAndSend");
               tooltip = this.m_buyButton.detachTooltip();
               if(tooltip)
               {
                  tooltip.release();
               }
               this.m_buyButton.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","MarketplaceGifting_BuyTooltipSelect")));
            }
            else
            {
               this.m_buyButton.visible = true;
               tooltip = this.m_buyButton.detachTooltip();
               if(tooltip)
               {
                  tooltip.release();
               }
               this.m_buyButton.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","MarketplaceGifting_BuyTooltipBuy",{
                  "friends":numSelectedFriends,
                  "cost":this.totalGiftCost
               })));
               if(Global.player.canBuyCash(this.totalGiftCost,false))
               {
                  this.m_buyButtonDescription.text = ZLocUtils.t("Dialogs","MarketplaceGifting_BuyAndSend");
               }
               else
               {
                  this.m_buyButtonDescription.text = ZLocUtils.t("Dialogs","MarketplaceGifting_GetCash");
               }
               if(m_selectionStatus == MFSWindowSlotFrame.SELECT_STATE_NONE)
               {
                  DisplayObjectUtils.grayOut(this.m_buyButton.element as Sprite,true);
               }
               else
               {
                  DisplayObjectUtils.grayOut(this.m_buyButton.element as Sprite,false);
               }
            }
         }
         else
         {
            this.m_buyButton.visible = false;
         }
      }
      
      private function onSortByMouseOut(evt:MouseEvent) : void
      {
         if(!FarmGameUtil.isDescendant(this.m_sortByButton.element as MovieClip,evt.relatedObject) && !FarmGameUtil.isDescendant(this.m_sortByMenu.element as MovieClip,evt.relatedObject))
         {
            this.m_sortByButton.setToggleState(ZwToggleState.DESELECTED);
            this.m_sortByMenu.visible = false;
         }
      }
      
      private function onSortByMenuItemSelected(item:MenuItem) : void
      {
         this.m_sortByButton.setToggleState(ZwToggleState.DESELECTED);
         this.m_sortByMenu.visible = false;
         var index:int = m_tabNames.indexOf(item.data as String);
         m_currentTab = index;
         FarmStatsManager.count(this.m_giftingStatsCounter,"gifting_mfs","sort_click",m_tabNames[index]);
         this.refresh();
      }
      
      override protected function updateSendButtonOnSlotSelection() : void
      {
         this.updateFriendSelectCount();
         this.updateBuyButton();
      }
      
      override protected function refresh(showProgressAnimation:Boolean = true) : void
      {
         super.refresh(showProgressAnimation);
         this.setCheckAllState(false);
      }
      
      private function onClickBuy(event:MouseEvent = null) : void
      {
         var uids:Array = null;
         var farmCashAmount:int = 0;
         FarmStatsManager.count(this.m_giftingStatsCounter,"gifting_mfs","send_click",this.m_giftItem.name,String(this.totalGiftCost),String(m_friendsSlotFrame.numSelectedItems));
         if(Global.player.cash >= this.totalGiftCost)
         {
            uids = m_friendsSlotFrame.getSelectedFriends();
            if(uids.length > 0)
            {
               this.triggerGiftPurchase(uids);
            }
         }
         else
         {
            farmCashAmount = InGamePaymentsManager.getMinimumPackageSize(this.totalGiftCost);
            PaymentUtil.instance.addCashToCart(farmCashAmount,"MarketplaceGifting",this.onPaymentSuccess,this.onPaymentFailure);
            FarmStatsManager.count("fv_buyableGift","not_enough_cash");
            this.tintWindow();
            this.enableInput = false;
         }
      }
      
      protected function onPaymentSuccess(orderId:String, status:String) : void
      {
         TransactionManager.addTransaction(new TRefreshBalance(),true);
         this.untintWindow();
         this.enableInput = true;
      }
      
      protected function onPaymentFailure(errorCode:String, errorMessage:String) : void
      {
         this.untintWindow();
         this.enableInput = true;
      }
      
      private function invalidate(uids:Array) : void
      {
         var friendType:String = null;
         var friendTypeLength:int = 0;
         var i:int = 0;
         var uidLength:int = int(uids.length);
         for(var invalidateUID:int = 0; invalidateUID < uidLength; invalidateUID++)
         {
            for(friendType in m_friends)
            {
               friendTypeLength = int(m_friends[friendType].length);
               for(i = 0; i < friendTypeLength; i++)
               {
                  if(uids[invalidateUID] == m_friends[friendType][i].uid)
                  {
                     m_friends[friendType][i].valid = false;
                  }
               }
            }
         }
      }
      
      protected function triggerGiftPurchase(friendList:Array) : void
      {
         if(Global.player.cash >= this.totalGiftCost)
         {
            TransactionManager.addTransaction(new TBuyAndSendPresent(this.m_giftItem,friendList,this.m_context,null,false,this.m_giftingStatsCounter));
            this.m_buyButtonDescription.text = ZLocUtils.t("Dialogs","MarketplaceGifting_Buying");
            this.m_isBuying = true;
            this.invalidate(friendList);
            setVisibleChild(m_friendsSlotFrame,false);
            setVisibleChild(m_loadingSpinner,true);
            this.updateButtonVisibility();
            this.m_buyButton.detachTooltip();
            enableInput = false;
            if(this.m_hideOnCongrats)
            {
               visible = false;
            }
            this.showGiftingSuccessWindow(friendList);
         }
      }
      
      protected function showGiftingSuccessWindow(friendList:Array) : void
      {
         UI.displayPopup(new MarketplaceGiftingSuccess(friendList.length,this.m_giftItem,this.m_successCallback,this.m_giftingStatsCounter),false);
      }
   }
}

