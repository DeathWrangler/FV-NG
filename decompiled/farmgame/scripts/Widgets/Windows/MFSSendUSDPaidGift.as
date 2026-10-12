package Widgets.Windows
{
   import Classes.Animal;
   import Classes.Constants.Experiments;
   import Classes.Constants.MFSConstants;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.Plot;
   import Classes.SimpleHarvestableResource;
   import Classes.USDPaidGifting.USDPaidGiftInfo;
   import Classes.USDPaidGifting.USDPaidGiftingManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.DisplayObjectUtils;
   import Classes.util.FarmGameUtil;
   import Classes.util.PaymentUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmTabButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Constants.ZwToggleMode;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Tooltips.ZwAbstractTooltip;
   import Widgets.Frames.MFSWindowSlotFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Menu.DropDownMenu;
   import Widgets.Menu.MenuItem;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class MFSSendUSDPaidGift extends MFSSendGiftBase
   {
      
      private var m_giftingManager:USDPaidGiftingManager;
      
      private var m_giftInfo:USDPaidGiftInfo;
      
      protected var m_giftItem:FarmItem;
      
      private var m_buyButton:FarmAnimatedTextButton = null;
      
      private var m_usdBurst:ZwWidget;
      
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
      
      public function MFSSendUSDPaidGift(giftingManager:USDPaidGiftingManager, source:String, completeCallback:Function, giftingStatsCounter:String = null)
      {
         var friendSpec:Object = {
            "MarketplaceGifting_SortRecommended":["CurrentMostGifts"],
            "MarketplaceGifting_SortHelpful":["CurrentMostHelpful"],
            "MarketplaceGifting_SortAlphabetical":["CurrentFriendsAlpha"]
         };
         var friendTabOrder:Array = ["MarketplaceGifting_SortRecommended","MarketplaceGifting_SortHelpful","MarketplaceGifting_SortAlphabetical"];
         this.m_giftingManager = giftingManager;
         this.m_giftInfo = this.m_giftingManager.getRandomGiftInfo();
         this.m_giftItem = this.m_giftInfo.getGiftItem();
         if(giftingStatsCounter != null)
         {
            this.m_giftingStatsCounter = giftingStatsCounter;
         }
         if(!this.m_dialogURL)
         {
            this.m_dialogURL = "assets/dialogs/FV_MarketplaceGifting2.swf";
         }
         super(this.m_giftItem,source,false,completeCallback,"MarketplaceGifting",friendSpec,friendTabOrder,this.m_dialogURL);
         m_batchLimit = this.m_giftingManager.getmaxRecipients();
         this.m_hideOnCongrats = true;
         this.m_successCallback = this.reactivateCallback;
      }
      
      override protected function sendPopulatingTransaction() : void
      {
         var paramArray:Array = [convertToUniqueValuesArray(friendSpec),true];
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
         this.setProgressIndicatorVisibility(false);
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
      
      override protected function postLoadComplete() : void
      {
         var tabName:String = null;
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
         this.m_buyButton = addWidget(new FarmAnimatedTextButton(m_window.buy2_bt,"",this.onClickBuy)) as FarmAnimatedTextButton;
         this.m_buyButton.visible = true;
         DisplayObjectUtils.grayOut(this.m_buyButton.element as Sprite,true);
         if(m_window.hasOwnProperty("burst_mc"))
         {
            this.m_usdBurst = addWidget(new ZwWidget(m_window.burst_mc)) as ZwWidget;
            this.m_usdBurst.visible = true;
         }
         this.updateBuyButton();
         this.m_sortByButton = addWidget(new FarmTabButton(m_window.sortBy_bt,ZLocUtils.t("Dialogs","SortBy"))) as FarmTabButton;
         (this.m_sortByButton.element as MovieClip).addEventListener(MouseEvent.MOUSE_OVER,this.onSortByMouseOver,false,0,true);
         (this.m_sortByButton.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onSortByMouseOut,false,0,true);
         if(m_window.hasOwnProperty("frame_subNav2_mc"))
         {
            this.m_sortByMenu = addWidget(new DropDownMenu(m_window.frame_subNav2_mc,this.onSortByMenuItemSelected),false) as DropDownMenu;
            (this.m_sortByMenu.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onSortByMouseOut,false,0,true);
         }
         this.m_sortByButton.setToggleState(ZwToggleState.DESELECTED);
         if(this.m_sortByMenu != null)
         {
            this.m_sortByMenu.visible = false;
         }
         var sortByMenuItems:Array = [];
         for each(tabName in m_tabNames)
         {
            menuItem = new MenuItem(tabName,ZLocUtils.t("Dialogs",tabName));
            sortByMenuItems.push(menuItem);
         }
         if(this.m_sortByMenu != null)
         {
            this.m_sortByMenu.items = sortByMenuItems;
         }
         this.m_sortByButton.visible = false;
         this.m_friendSelectedCount = addWidget(new ZwTextField(m_window.friendCount_tf,"")) as ZwTextField;
         this.m_friendSelectedCount.visible = false;
         this.updateFriendSelectCount();
         this.m_giftItemName = addWidget(new ZwTextField(m_window.item_tf,ZLocUtils.t("Dialogs","MarketplaceGifting_ItemName",{"itemName":this.m_giftItem.friendlyTitle}))) as ZwTextField;
         this.m_giftItemName.visible = true;
         var terrain:String = Global.farmGameSettingsManager.selectPrimaryTerrainNameFromGivenCodes(this.m_giftItem.getTerrainCodes());
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
         this.m_buyButton = null;
         this.m_usdBurst = null;
         this.m_giftItemName = null;
         this.m_friendSelectedCount = null;
         this.m_giftObject = null;
         super.release();
      }
      
      protected function createObjectPreview(scale:Number, itemState:String) : void
      {
         this.m_giftObject = new ObjectPreviewFrame(m_window.item_mc,this.m_giftItem,null,[scale],null,itemState);
         addWidget(this.m_giftObject,true);
         this.m_giftObject.visible = true;
      }
      
      private function onSortByMouseOver(evt:MouseEvent) : void
      {
         if(Boolean(this.m_sortByMenu) && !this.m_sortByMenu.visible)
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
         if(this.m_isBuying || m_loadingSpinner.visible == true)
         {
            this.m_friendSelectedCount.visible = false;
         }
         else
         {
            this.m_friendSelectedCount.visible = true;
            numFriends = int(m_currentlyDisplayedFriends.length);
            numSelected = numSelectedFriends;
            this.m_friendSelectedCount.text = ZLocUtils.t("Dialogs","MarketplaceGifting_FriendsSelected",{
               "selected":numSelected,
               "max":numFriends
            });
         }
      }
      
      override protected function postRefreshActions() : void
      {
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_GIFTING_V2);
         var defaultSortingVariant:int = Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_MARKET_GIFTING_V2_SORTING);
         var defaultTab:int = Math.max(defaultSortingVariant - 1,0);
         m_currentTab = defaultTab;
         this.refresh(false);
      }
      
      private function get totalGiftCost() : Number
      {
         var mult:int = numSelectedFriends;
         if(mult < 1)
         {
            mult = 1;
         }
         return this.m_giftingManager.getUSDPrice() * mult;
      }
      
      private function updateBuyButton() : void
      {
         var enableButton:Boolean = false;
         var buttonText:String = null;
         var tooltipText:String = null;
         var oldTooltip:ZwAbstractTooltip = null;
         if(m_loadingComplete)
         {
            this.m_buyButton.visible = true;
            if(this.m_usdBurst != null)
            {
               this.m_usdBurst.visible = true;
            }
            enableButton = false;
            buttonText = "";
            tooltipText = "";
            if(this.m_isBuying)
            {
               enableButton = false;
               buttonText = ZLocUtils.t("Dialogs","MarketplaceGifting_Buying");
            }
            else if(m_currentlyDisplayedFriends.length < 1)
            {
               enableButton = false;
               buttonText = ZLocUtils.t("Dialogs","MarketplaceGifting_BuyAndSend");
               tooltipText = ZLocUtils.t("Dialogs","MarketplaceGifting_BuyTooltipSelect");
            }
            else
            {
               enableButton = m_selectionStatus != MFSWindowSlotFrame.SELECT_STATE_NONE;
               if(enableButton)
               {
                  tooltipText = ZLocUtils.t("Dialogs","MarketplaceGifting_BuyTooltipBuyUSD",{
                     "friends":numSelectedFriends,
                     "cost":Utilities.padDecimals(this.totalGiftCost,2,true)
                  });
               }
               else
               {
                  tooltipText = ZLocUtils.t("Dialogs","MarketplaceGifting_BuyTooltipSelect");
               }
               buttonText = ZLocUtils.t("Dialogs","MarketplaceGifting_BuyAndSendUSD",{"cost":Utilities.padDecimals(this.totalGiftCost,2,true)});
            }
            if(enableButton)
            {
               this.m_buyButton.setToggleState(ZwToggleState.DESELECTED);
            }
            else
            {
               this.m_buyButton.setToggleMode(ZwToggleMode.SINGLE_SELECT);
               this.m_buyButton.setToggleState(ZwToggleState.SELECTED);
            }
            oldTooltip = this.m_buyButton.detachTooltip();
            if(oldTooltip)
            {
               oldTooltip.release();
            }
            this.m_buyButton.toggleClickableButton(enableButton,tooltipText);
            this.m_buyButton.text = buttonText;
         }
         else
         {
            this.m_buyButton.visible = false;
            if(this.m_usdBurst != null)
            {
               this.m_usdBurst.visible = false;
            }
         }
      }
      
      private function onSortByMouseOut(evt:MouseEvent) : void
      {
         if(!FarmGameUtil.isDescendant(this.m_sortByButton.element as MovieClip,evt.relatedObject) && this.m_sortByMenu != null && !FarmGameUtil.isDescendant(this.m_sortByMenu.element as MovieClip,evt.relatedObject))
         {
            this.m_sortByButton.setToggleState(ZwToggleState.DESELECTED);
            this.m_sortByMenu.visible = false;
         }
      }
      
      private function onSortByMenuItemSelected(item:MenuItem) : void
      {
         var index:int = 0;
         this.m_sortByButton.setToggleState(ZwToggleState.DESELECTED);
         if(this.m_sortByMenu != null)
         {
            this.m_sortByMenu.visible = false;
         }
         index = m_tabNames.indexOf(item.data as String);
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
         FarmStatsManager.count(this.m_giftingStatsCounter,"gifting_mfs","send_click",this.m_giftItem.name,String(this.totalGiftCost),String(m_friendsSlotFrame.numSelectedItems));
         var uids:Array = m_friendsSlotFrame.getSelectedFriends();
         if(uids.length > 0)
         {
            this.triggerGiftPurchase(uids);
         }
      }
      
      protected function triggerGiftPurchase(friendList:Array) : void
      {
         this.m_giftInfo.setRecipients(friendList);
         PaymentUtil.instance.addGiftToCart(this.m_giftingManager.getVirtualItem().code,friendList.length,this.m_giftInfo.toRefString(),this.onPaymentSuccess,this.onPaymentFailure,m_item.friendlyTitle,m_item.friendlyTitle,m_item.icon);
         this.m_buyButton.text = ZLocUtils.t("Dialogs","MarketplaceGifting_Buying");
         this.m_isBuying = true;
         this.setProgressIndicatorVisibility(true);
         this.updateButtonVisibility();
         enableInput = false;
      }
      
      protected function onPaymentSuccess(orderId:String, status:String) : void
      {
         FarmStatsManager.count(this.m_giftingStatsCounter,"gifting_mfs","payment_success",this.m_giftItem.name,String(this.totalGiftCost),String(m_friendsSlotFrame.numSelectedItems));
         this.invalidate(m_friendsSlotFrame.getSelectedFriends());
         this.untintWindow();
         this.enableInput = true;
         if(this.m_hideOnCongrats)
         {
            visible = false;
         }
         this.showGiftingSuccessWindow();
      }
      
      protected function onPaymentFailure(errorCode:String, errorMessage:String) : void
      {
         this.untintWindow();
         visible = true;
         this.enableInput = true;
         this.m_isBuying = false;
         this.updateButtonVisibility();
         this.setProgressIndicatorVisibility(false);
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
      
      protected function showGiftingSuccessWindow() : void
      {
         UI.displayPopup(new MarketplaceGiftingSuccess(numSelectedFriends,this.m_giftItem,this.m_successCallback,this.m_giftingStatsCounter),false);
      }
      
      protected function setProgressIndicatorVisibility(showProgressIndicator:Boolean) : void
      {
         setVisibleChild(m_friendsSlotFrame,!showProgressIndicator);
         setVisibleChild(m_loadingSpinner,showProgressIndicator);
      }
   }
}

