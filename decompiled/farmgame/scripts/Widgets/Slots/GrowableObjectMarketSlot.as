package Widgets.Slots
{
   import Classes.Growable.GrowableConstants;
   import Classes.Growable.GrowableContest;
   import Classes.ZItem.FarmItem;
   import Classes.util.ObjectUtil;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureOptionsManager;
   import Managers.InstanceDataStoreManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Windows.GrowableContestWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class GrowableObjectMarketSlot extends ZwSlotFrame
   {
      
      private static var m_buyInProgress:Boolean = false;
      
      private var m_contest:GrowableContest;
      
      private const SLOT_PREFIX:String = "pig";
      
      private const FEATURE_DIALOG_PREFIX:String = "MarketSlotFrame_";
      
      private var m_titleTextField:ZwTextField;
      
      private var m_statusTextField:ZwTextField;
      
      private var m_objectPreview:ObjectPreviewFrame;
      
      private var m_lockedWidget:ZwWidget;
      
      private var m_centerTextField:ZwTextField;
      
      private var m_buyCashButton:FarmAnimatedTextButton;
      
      private var m_buyCoinsButton:FarmAnimatedTextButton;
      
      private var m_placeButton:FarmAnimatedButton;
      
      private var m_item:FarmItem;
      
      private var m_window:GrowableContestWindow;
      
      private var m_updatesReceived:int = 0;
      
      private var m_buyItemStorageKey:String = null;
      
      public function GrowableObjectMarketSlot(window:GrowableContestWindow, element:DisplayObject, contest:GrowableContest)
      {
         this.m_window = window;
         this.m_contest = contest;
         super(element);
         var titleName:String = this.SLOT_PREFIX + "Name_tf";
         if(ObjectUtil.pathExists(m_element,titleName))
         {
            this.m_titleTextField = new ZwTextField(m_element[titleName]);
            addWidget(this.m_titleTextField);
         }
         if(ObjectUtil.pathExists(m_element,"buy_cash_bt"))
         {
            this.m_buyCashButton = addWidget(new FarmAnimatedTextButton(m_element.buy_cash_bt,"00",this.handleBuyButtonClicked)) as FarmAnimatedTextButton;
         }
         if(ObjectUtil.pathExists(m_element,"buy_coin_bt"))
         {
            this.m_buyCoinsButton = addWidget(new FarmAnimatedTextButton(m_element.buy_coin_bt,"00",this.handleBuyButtonClicked)) as FarmAnimatedTextButton;
         }
         if(ObjectUtil.pathExists(m_element,"place_mc"))
         {
            this.m_placeButton = addWidget(new FarmAnimatedTextButton(m_element.place_mc,"Place!",this.handleBuyButtonClicked)) as FarmAnimatedTextButton;
         }
         if(ObjectUtil.pathExists(m_element,"lock_mc"))
         {
            this.m_lockedWidget = new ZwWidget(m_element.lock_mc);
            addWidget(this.m_lockedWidget);
         }
         if(ObjectUtil.pathExists(m_element,"generic_tf"))
         {
            this.m_centerTextField = new ZwTextField(m_element.generic_tf,this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "FinishMoreTip"));
            addWidget(this.m_centerTextField,false);
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_item = Global.farmGameSettingsManager.getFarmItemByCode(data as String);
         var enable:Boolean = this.m_item.checkPurchasePrereqs();
         this.m_lockedWidget.visible = !enable;
         this.toggleButton(this.m_buyCashButton,enable);
         this.toggleButton(this.m_buyCoinsButton,enable);
         this.toggleButton(this.m_placeButton,enable);
         if(this.m_objectPreview)
         {
            removeWidget(this.m_objectPreview);
         }
         var imageName:String = this.SLOT_PREFIX + "Image_mc";
         if(ObjectUtil.pathExists(m_element,imageName))
         {
            this.m_objectPreview = new ObjectPreviewFrame(m_element[imageName],this.m_item,null,[this.m_contest.objectPreviewScale]) as ObjectPreviewFrame;
            this.m_objectPreview.y = 0;
            addWidget(this.m_objectPreview);
         }
         this.updateBuyButtonState(null);
         FeatureOptionsManager.getInstance().addEventListener(FeatureOptionsManager.EVENT_FEATURE_OPTIONS_UPDATED,this.updateBuyButtonState);
         this.m_titleTextField.text = this.m_item.friendlyTitle;
         this.m_titleTextField.visible = true;
      }
      
      override public function release() : void
      {
         FeatureOptionsManager.getInstance().removeEventListener(FeatureOptionsManager.EVENT_FEATURE_OPTIONS_UPDATED,this.updateBuyButtonState);
         this.m_titleTextField = null;
         this.m_statusTextField = null;
         this.m_objectPreview = null;
         this.m_lockedWidget = null;
         this.m_centerTextField = null;
         this.m_buyCashButton = null;
         this.m_buyCoinsButton = null;
         this.m_item = null;
         this.m_window = null;
         this.m_contest = null;
         super.release();
      }
      
      private function handleBuyButtonClicked(e:MouseEvent) : void
      {
         var canBuy:Boolean = false;
         var currency:String = null;
         var button:FarmAnimatedTextButton = null;
         if(this.m_item.cash > 0)
         {
            canBuy = Global.player.canBuyCash(this.m_item.cash);
            currency = "cash";
            button = this.m_buyCashButton;
         }
         else
         {
            canBuy = Global.player.canBuy(this.m_item.cost);
            currency = "coins";
            button = this.m_buyCoinsButton;
         }
         if(canBuy)
         {
            switch(currency)
            {
               case "cash":
                  Global.player.cash -= this.m_item.cash;
                  break;
               case "coins":
                  Global.player.gold -= this.m_item.cost;
            }
            this.toggleButton(button,false);
            m_buyInProgress = true;
            this.m_window.showLoadingIndicator();
            TransactionManager.addTransaction(new TGenericTransaction(GrowableConstants.SERVICE_GROWABLE_CONTEST,"buyGrowable",this.callbackBuyGrowable,[this.m_contest.contestId,this.m_item.code]),true);
         }
         this.statCount("buy",this.m_item.name);
      }
      
      private function updateBuyButtonState(e:Event) : void
      {
         var isSpaceAvailable:Boolean = this.m_contest.availableCapacity() > 0;
         var isStateValid:Boolean = isSpaceAvailable && !m_buyInProgress && this.m_item.checkPurchasePrereqs();
         this.m_centerTextField.visible = false;
         if(!isStateValid)
         {
            this.m_centerTextField.visible = true;
            if(!this.m_item.checkPurchasePrereqs())
            {
               this.m_centerTextField.text = this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "FinishMoreTip");
               this.m_lockedWidget.visible = true;
            }
            else if(!isSpaceAvailable)
            {
               this.m_centerTextField.text = this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "NoRoom");
            }
         }
         if(this.m_item.cash > 0)
         {
            this.m_buyCashButton.text = "" + this.m_item.cash;
            this.m_buyCashButton.visible = true;
            this.m_buyCoinsButton.visible = false;
            this.m_placeButton.visible = false;
            this.toggleButton(this.m_buyCashButton,isStateValid);
         }
         else if(this.m_item.cost > 0)
         {
            this.m_buyCoinsButton.text = "" + this.m_item.cost;
            this.m_buyCoinsButton.visible = true;
            this.m_buyCashButton.visible = false;
            this.m_placeButton.visible = false;
            this.toggleButton(this.m_buyCoinsButton,isStateValid);
         }
         else
         {
            this.m_buyCoinsButton.visible = false;
            this.m_buyCashButton.visible = false;
            this.m_placeButton.visible = true;
            this.toggleButton(this.m_placeButton,isStateValid);
         }
      }
      
      private function callbackBuyGrowable(result:Object) : void
      {
         m_buyInProgress = false;
         if(result.success)
         {
            this.m_updatesReceived = 0;
            this.m_buyItemStorageKey = result.storageKey;
            InstanceDataStoreManager.listenForChange(result.storageKey,this.buyGrowableIdsUpdate);
            FeatureOptionsManager.getInstance().addEventListener(FeatureOptionsManager.EVENT_FEATURE_OPTIONS_UPDATED,this.buyGrowableFeatureUpdate);
         }
      }
      
      private function buyGrowableIdsUpdate(e:Event) : void
      {
         ++this.m_updatesReceived;
         InstanceDataStoreManager.stopListeningForChange(this.m_buyItemStorageKey,this.buyGrowableIdsUpdate);
         if(this.m_updatesReceived == 2)
         {
            this.buyCompleteAndUpdated();
         }
      }
      
      private function buyGrowableFeatureUpdate(e:Event) : void
      {
         ++this.m_updatesReceived;
         FeatureOptionsManager.getInstance().removeEventListener(FeatureOptionsManager.EVENT_FEATURE_OPTIONS_UPDATED,this.buyGrowableFeatureUpdate);
         if(this.m_updatesReceived == 2)
         {
            this.buyCompleteAndUpdated();
         }
      }
      
      private function buyCompleteAndUpdated() : void
      {
         this.m_window.hideLoadingIndicator();
         this.m_window.enterPlacementMode(this.m_item.name,this.m_buyItemStorageKey);
      }
      
      public function statCount(phylum:String = "", zclass:String = "", family:String = "", genus:String = "", value:int = 1) : void
      {
         this.m_contest.statCount("market_tab",phylum,zclass,family,genus,value);
      }
      
      private function toggleButton(button:FarmAnimatedButton, to:Boolean) : void
      {
         button.enabled = to;
         button.applyGrayOut = !to;
      }
   }
}

