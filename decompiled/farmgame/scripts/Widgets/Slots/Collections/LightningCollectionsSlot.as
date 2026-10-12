package Widgets.Slots.Collections
{
   import Classes.Collections.Collectible;
   import Classes.Collections.Collection;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.ImpulseBuyEvent;
   import Transactions.TLightningCollectionTradeIn;
   import Widgets.Buttons.Collections.CollectionsAnimatedButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Collections.LightningCollectionsSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.Collections.BuyCollectionsWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class LightningCollectionsSlot extends CollectionsSlot
   {
      
      private var m_impulseBuyDialog:ImpulseBuy = null;
      
      public function LightningCollectionsSlot(element:DisplayObject, parentSlotFrame:LightningCollectionsSlotFrame)
      {
         super(element,parentSlotFrame);
         addWidget(new ZwTextField(m_element.collectionsTitleBlue_tf));
         addWidget(new ZwTextField(m_element.comingSoon_tf));
         addWidget(new ZwTextField(m_element.timeLeft_tf));
         addWidget(new ZwWidget(m_element.leComplete_mc as DisplayObject));
         addWidget(new ZwWidget(m_element.leCompleteBackground_mc as DisplayObject));
         addWidget(new ZwWidget(m_element.leIncompleteBackground_mc as DisplayObject));
         addWidget(new CollectionsAnimatedButton(m_element.storeCollection_bt,this.onStoreClick));
         addWidget(new CollectionsAnimatedButton(m_element.buyCollection_bt,this.onBuyAllClick));
      }
      
      protected function onStoreClick(event:MouseEvent) : void
      {
         var collectionCode:String = null;
         var collection:Collection = null;
         var clickedButton:CollectionsAnimatedButton = getWidget(event.currentTarget) as CollectionsAnimatedButton;
         if(clickedButton != null)
         {
            collectionCode = clickedButton.getButtonCode();
            collection = Global.farmGameSettingsManager.getCollectionByCode(collectionCode);
            collection.storeCollection();
            TransactionManager.addTransaction(new TLightningCollectionTradeIn(collectionCode),true);
            this.populate(m_collection);
         }
      }
      
      public function onImpulseBuyCancel(event:ImpulseBuyEvent) : void
      {
         this.m_parentSlotFrame.toggleMainWindow(true);
         if(this.m_impulseBuyDialog)
         {
            this.m_impulseBuyDialog.removeEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
            this.m_impulseBuyDialog = null;
         }
      }
      
      private function buyHandler(clickedButton:CollectionsAnimatedButton, buyAll:Boolean) : void
      {
         var canBuy:Boolean = false;
         var buyCollections:BuyCollectionsWindow = null;
         var code:String = null;
         var item:FarmItem = null;
         if(clickedButton)
         {
            canBuy = false;
            buyCollections = null;
            code = clickedButton.getButtonCode();
            if(buyAll)
            {
               canBuy = Global.player.canBuyCash(m_collection.getCashBuyAllAmount(),false);
               buyCollections = new BuyCollectionsWindow("",code,this.refreshCallback,true);
            }
            else
            {
               item = Global.farmGameSettingsManager.getFarmItemByCode(code);
               canBuy = Global.player.canBuyCash(item.cash,false);
               buyCollections = new BuyCollectionsWindow(code,m_collection.code,this.refreshCallback);
            }
            this.m_parentSlotFrame.toggleMainWindow(false);
            if(canBuy)
            {
               UI.displayPopup(buyCollections,false,"buyCollectionsPopup",true);
            }
            else
            {
               this.m_impulseBuyDialog = new ImpulseBuy(ImpulseBuy.TYPE_MARKET_CASH);
               this.m_impulseBuyDialog.addEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
               UI.displayPopup(this.m_impulseBuyDialog,false,"buyMoreCashPopup",true);
            }
         }
      }
      
      protected function onBuyAllClick(event:MouseEvent) : void
      {
         var clickedButton:CollectionsAnimatedButton = getWidget(event.currentTarget) as CollectionsAnimatedButton;
         this.buyHandler(clickedButton,true);
      }
      
      protected function onBuyLightningItem(event:MouseEvent) : void
      {
         var clickedButton:CollectionsAnimatedButton = getWidget(event.currentTarget) as CollectionsAnimatedButton;
         this.buyHandler(clickedButton,false);
      }
      
      public function refreshCallback() : void
      {
         this.m_parentSlotFrame.toggleMainWindow(true);
         this.populate(m_collection);
      }
      
      override public function populate(data:Object) : void
      {
         var le_incompleteBg:ZwWidget = null;
         var collectionsTitleBlue:ZwTextField = null;
         super.populate(data);
         var tradeInButton:CollectionsAnimatedButton = getWidget(m_element.tradeIn_bt) as CollectionsAnimatedButton;
         tradeInButton.visible = false;
         var storeCollectionButton:CollectionsAnimatedButton = getWidget(m_element.storeCollection_bt) as CollectionsAnimatedButton;
         storeCollectionButton.setButtonCode(m_collection.code);
         storeCollectionButton.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","LightningCollectionsStoreItems")));
         var buyCollectionButton:CollectionsAnimatedButton = getWidget(m_element.buyCollection_bt) as CollectionsAnimatedButton;
         buyCollectionButton.setButtonCode(m_collection.code);
         var le_starsComplete:ZwWidget = getWidget(m_element.leComplete_mc) as ZwWidget;
         var le_completeBg:ZwWidget = getWidget(m_element.leCompleteBackground_mc) as ZwWidget;
         le_incompleteBg = getWidget(m_element.leIncompleteBackground_mc) as ZwWidget;
         collectionsTitleBlue = getWidget(m_element.collectionsTitleBlue_tf) as ZwTextField;
         collectionsTitleBlue.text = ZLocUtils.tk_pk_asTitle(m_collection.friendlyName);
         var timeLeft:ZwTextField = getWidget(m_element.timeLeft_tf) as ZwTextField;
         if(m_collection.isCollectionComplete())
         {
            storeCollectionButton.visible = true;
            collectionsTitleBlue.visible = true;
            le_starsComplete.visible = true;
            le_completeBg.visible = true;
            le_incompleteBg.visible = false;
            buyCollectionButton.visible = false;
            timeLeft.visible = false;
         }
         else
         {
            storeCollectionButton.visible = false;
            collectionsTitleBlue.visible = false;
            le_starsComplete.visible = false;
            le_completeBg.visible = false;
            le_incompleteBg.visible = true;
            timeLeft.visible = true;
            buyCollectionButton.visible = true;
         }
         var collectionsTitleGreen:ZwTextField = getWidget(m_element.collectionsTitleGreen_tf) as ZwTextField;
         var starsComplete:ZwWidget = getWidget(m_element.starsComplete_mc) as ZwWidget;
         var completeBg:ZwWidget = getWidget(m_element.completeBackground_mc) as ZwWidget;
         var incompleteBg:ZwWidget = getWidget(m_element.incompleteBackground_mc) as ZwWidget;
         starsComplete.visible = false;
         completeBg.visible = false;
         incompleteBg.visible = false;
         collectionsTitleGreen.visible = false;
         this.toggleComingSoonMode();
      }
      
      protected function toggleComingSoonMode() : void
      {
         var tradeInButton:CollectionsAnimatedButton = null;
         var storeCollectionButton:CollectionsAnimatedButton = null;
         var buyCollectionButton:CollectionsAnimatedButton = null;
         var le_starsComplete:ZwWidget = null;
         var le_completeBg:ZwWidget = null;
         var le_incompleteBg:ZwWidget = null;
         var collectionsTitleBlue:ZwTextField = null;
         var collectionsTitleGreen:ZwTextField = null;
         var comingSoonText:ZwTextField = null;
         var starsComplete:ZwWidget = null;
         var completeBg:ZwWidget = null;
         var incompleteBg:ZwWidget = null;
         var itemIndex:int = 0;
         var uiIndex:int = 0;
         var giftAmountField:ZwTextField = null;
         var itemIcon:FarmIcon = null;
         var itemPrice:ZwWidget = null;
         var buyButton:CollectionsAnimatedButton = null;
         var itemBg:ZwWidget = null;
         var giftAmountBg:ZwWidget = null;
         if(m_collection.collectibleCount <= 0)
         {
            tradeInButton = getWidget(m_element.tradeIn_bt) as CollectionsAnimatedButton;
            tradeInButton.visible = false;
            storeCollectionButton = getWidget(m_element.storeCollection_bt) as CollectionsAnimatedButton;
            storeCollectionButton.visible = false;
            buyCollectionButton = getWidget(m_element.buyCollection_bt) as CollectionsAnimatedButton;
            buyCollectionButton.visible = false;
            le_starsComplete = getWidget(m_element.leComplete_mc) as ZwWidget;
            le_starsComplete.visible = false;
            le_completeBg = getWidget(m_element.leCompleteBackground_mc) as ZwWidget;
            le_completeBg.visible = false;
            le_incompleteBg = getWidget(m_element.leIncompleteBackground_mc) as ZwWidget;
            le_incompleteBg.visible = true;
            collectionsTitleBlue = getWidget(m_element.collectionsTitleBlue_tf) as ZwTextField;
            collectionsTitleBlue.visible = false;
            collectionsTitleGreen = getWidget(m_element.collectionsTitleGreen_tf) as ZwTextField;
            collectionsTitleGreen.visible = false;
            comingSoonText = getWidget(m_element.comingSoon_tf) as ZwTextField;
            comingSoonText.text = ZLocUtils.t("Dialogs","LightningCollectionsComingSoonText");
            comingSoonText.visible = true;
            starsComplete = getWidget(m_element.starsComplete_mc) as ZwWidget;
            starsComplete.visible = false;
            completeBg = getWidget(m_element.completeBackground_mc) as ZwWidget;
            completeBg.visible = false;
            incompleteBg = getWidget(m_element.incompleteBackground_mc) as ZwWidget;
            incompleteBg.visible = false;
            for(itemIndex = 0; itemIndex < NUM_SLOT_ITEMS; itemIndex++)
            {
               uiIndex = itemIndex + 1;
               giftAmountField = getWidget(m_element["giftAmount" + uiIndex + "_tf"]) as ZwTextField;
               giftAmountField.visible = false;
               itemIcon = getWidget(m_element["icon" + uiIndex]) as FarmIcon;
               itemIcon.visible = false;
               itemPrice = getWidget(m_element["price" + uiIndex + "_mc"]) as ZwWidget;
               itemPrice.visible = false;
               buyButton = getWidget(m_element["buy" + uiIndex + "_bt"]) as CollectionsAnimatedButton;
               buyButton.visible = false;
               itemBg = getWidget(m_element["itemBg" + uiIndex + "_mc"]) as ZwWidget;
               itemBg.visible = false;
               giftAmountBg = getWidget(m_element["giftAmountBg" + uiIndex + "_mc"]) as ZwWidget;
               giftAmountBg.visible = false;
            }
         }
      }
      
      override protected function createSlotItem(collectableIndex:int) : void
      {
         super.createSlotItem(collectableIndex);
         addWidget(new ZwWidget(m_element["price" + collectableIndex + "_mc"]));
         addWidget(new CollectionsAnimatedButton(m_element["buy" + collectableIndex + "_bt"],this.onBuyLightningItem));
      }
      
      override protected function populateSlotItem(collectableIndex:int) : void
      {
         var code:String = null;
         var uiIndex:int = 0;
         var giftAmountField:ZwTextField = null;
         var itemIcon:FarmIcon = null;
         var itemPrice:ZwWidget = null;
         var buyButton:CollectionsAnimatedButton = null;
         super.populateSlotItem(collectableIndex);
         var newCollectible:Collectible = m_collection.getCollectableByIndex(collectableIndex);
         if(Boolean(newCollectible) && Boolean(newCollectible.item))
         {
            code = newCollectible.code;
            uiIndex = collectableIndex + 1;
            giftAmountField = getWidget(m_element["giftAmount" + uiIndex + "_tf"]) as ZwTextField;
            giftAmountField.visible = true;
            itemIcon = getWidget(m_element["icon" + uiIndex]) as FarmIcon;
            itemIcon.loadIcon(newCollectible.item.icon);
            itemIcon.visible = true;
            itemIcon.setIconSize(DEFAULT_ICON_WIDTH,DEFAULT_ICON_HEIGHT);
            itemIcon.detachTooltip();
            itemIcon.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Collections",newCollectible.source + "_toolTip")));
            itemPrice = getWidget(m_element["price" + uiIndex + "_mc"]) as ZwWidget;
            itemPrice.element.generic_tf.text = newCollectible.cashCost;
            itemPrice.visible = true;
            buyButton = getWidget(m_element["buy" + uiIndex + "_bt"]) as CollectionsAnimatedButton;
            buyButton.setButtonCode(code);
            buyButton.visible = true;
            if(null != Global.player.collectionCounters[code])
            {
               if(Global.player.collectionCounters[code] >= newCollectible.numNeeded)
               {
                  itemIcon.alpha = 1;
               }
               else
               {
                  itemIcon.alpha = 0.25;
               }
               giftAmountField.text = Global.player.collectionCounters[code].toString() + "/" + newCollectible.numNeeded;
            }
            else
            {
               giftAmountField.text = "0/" + newCollectible.numNeeded;
            }
         }
      }
   }
}

