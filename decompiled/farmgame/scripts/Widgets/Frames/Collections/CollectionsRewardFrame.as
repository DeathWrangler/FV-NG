package Widgets.Frames.Collections
{
   import Classes.Collections.Collection;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Events.ImpulseBuyEvent;
   import Transactions.TBuyAllCollectibles;
   import Transactions.TCollectionTradeIn;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Collections.CollectibleSlot;
   import Widgets.Windows.Collections.CollectionsWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class CollectionsRewardFrame extends FarmSlotContainerFrame
   {
      
      private var m_parentWindow:CollectionsWindow;
      
      private var m_collection:Collection;
      
      private var m_rewardPanel:RewardPanelFrame;
      
      private var m_collectionTitle:ZwTextField;
      
      private var m_collectionLevel:ZwTextField;
      
      private var m_collectionComplete:ZwTextField;
      
      private var m_completeNow:FarmAnimatedButton;
      
      private var m_tradeIn:FarmAnimatedTextButton;
      
      private var m_grayedTradeIn:FarmAnimatedButton;
      
      private var m_impulseBuyDialog:ImpulseBuy = null;
      
      public function CollectionsRewardFrame(element:DisplayObject, parentWindow:CollectionsWindow, collection:Collection)
      {
         this.m_parentWindow = parentWindow;
         this.m_collection = collection;
         super(element);
         this.m_collectionLevel = addWidget(new ZwTextField(m_element.collectionLevel_tf,ZLocUtils.t("Collections","Level",{"levelNum":this.m_collection.getLevel() + 1}))) as ZwTextField;
         this.m_collectionTitle = addWidget(new ZwTextField(m_element.collectionName_tf,this.m_collection.friendlyName)) as ZwTextField;
         this.m_collectionComplete = addWidget(new ZwTextField(m_element.complete_tf,ZLocUtils.t("Collections","Complete"))) as ZwTextField;
         this.m_tradeIn = addWidget(new FarmAnimatedTextButton(m_element.trade_bt,ZLocUtils.t("Collections","TradeIn"),this.onTradeInClick)) as FarmAnimatedTextButton;
         this.m_completeNow = addWidget(new FarmAnimatedTextButton(m_element.addCoins_bt,ZLocUtils.t("Collections","CompleteNow"),this.onBuyAllClick)) as FarmAnimatedTextButton;
         this.m_grayedTradeIn = addWidget(new FarmAnimatedTextButton(m_element.tradeGrey_mc,ZLocUtils.t("Collections","TradeIn"),null)) as FarmAnimatedTextButton;
         var collectionComplete:Boolean = this.m_collection.isCollectionComplete();
         if(collectionComplete)
         {
            this.m_collectionComplete.visible = true;
            this.m_tradeIn.visible = true;
            this.m_completeNow.visible = false;
            this.m_grayedTradeIn.visible = false;
         }
         else
         {
            this.m_collectionComplete.visible = false;
            this.m_tradeIn.visible = false;
            this.m_completeNow.visible = true;
            this.m_grayedTradeIn.visible = true;
         }
         this.m_rewardPanel = addWidget(new RewardPanelFrame(m_element.reward_mc,this,collection)) as RewardPanelFrame;
         m_slotData = this.m_collection.getCollectibles();
         this.updateContents(this.m_collection);
      }
      
      public function updateContents(collection:Collection) : void
      {
         this.m_collection = collection;
         m_slotData = collection.getCollectibles();
         this.m_rewardPanel.updateCollection(collection);
         this.refresh();
         populateSlots();
      }
      
      public function onImpulseBuyCancel(event:ImpulseBuyEvent) : void
      {
         this.m_parentWindow.visible = true;
         if(this.m_impulseBuyDialog)
         {
            this.m_impulseBuyDialog.removeEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
            this.m_impulseBuyDialog = null;
         }
      }
      
      private function onBuyAllClick(event:MouseEvent) : void
      {
         var message:String = null;
         var cashForCollectibles:Number = this.m_collection.getCashBuyAllAmount();
         var canBuy:Boolean = Global.player.canBuyCash(cashForCollectibles,false);
         if(canBuy)
         {
            this.m_parentWindow.visible = false;
            message = ZLocUtils.t("Dialogs","CollectionsCompleteNowConfirm",{"cashQuantity":cashForCollectibles});
            UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,this.completeNowHandler,"CollectionCompleteNow",true,false,"CollectionCompleteNow");
         }
         else
         {
            this.m_parentWindow.visible = false;
            this.m_impulseBuyDialog = new ImpulseBuy(ImpulseBuy.TYPE_MARKET_CASH);
            this.m_impulseBuyDialog.addEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
            UI.displayPopup(this.m_impulseBuyDialog,false,"buyMoreCashPopup",true);
         }
      }
      
      private function completeNowHandler(event:GenericPopupEvent) : void
      {
         this.m_parentWindow.visible = true;
         if(event.button == GenericPopup.YES)
         {
            TransactionManager.addTransaction(new TBuyAllCollectibles(this.m_collection.name));
            this.updateContents(this.m_collection);
            this.m_parentWindow.updateCollectionFrame(this.m_collection);
         }
      }
      
      protected function onTradeInClick(event:MouseEvent) : void
      {
         this.m_collection.levelUp();
         TransactionManager.addTransaction(new TCollectionTradeIn(this.m_collection.name,this.m_parentWindow),true);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CollectibleSlot(slotElement,this.m_parentWindow);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function release() : void
      {
         super.release();
         this.m_parentWindow = null;
      }
      
      override public function refresh() : void
      {
         this.m_collectionTitle.text = ZLocUtils.tk_pk_asTitle(this.m_collection.friendlyName);
         this.m_collectionLevel.text = ZLocUtils.t("Collections","Level",{"levelNum":this.m_collection.getLevel() + 1});
         var collectionComplete:Boolean = this.m_collection.isCollectionComplete();
         if(collectionComplete)
         {
            this.m_collectionComplete.visible = true;
            this.m_tradeIn.visible = true;
            this.m_completeNow.visible = false;
            this.m_grayedTradeIn.visible = false;
         }
         else
         {
            this.m_collectionComplete.visible = false;
            this.m_tradeIn.visible = false;
            this.m_completeNow.visible = true;
            this.m_grayedTradeIn.visible = true;
         }
         this.m_rewardPanel.updateCollection(this.m_collection);
         this.m_rewardPanel.visible = true;
      }
   }
}

