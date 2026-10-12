package Widgets.Frames
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Events.GenericPopupEvent;
   import Managers.WanderingPirateManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.WanderingPirateRewardItemsSlot;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.WanderingPirateWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class WanderingPirateRewardItemsFrame extends FarmSlotContainerFrame
   {
      
      private static const PRICE_FIXED:int = 9;
      
      private static const DEFAULT_MULTIPLIER:int = 3;
      
      protected var m_owner:DisplayObject;
      
      private var m_keyBoxNumber:int;
      
      private var m_RubyCount:int;
      
      private var m_cashValue:int;
      
      private var m_openCaseButton:FarmAnimatedTextButton;
      
      private var m_buyCaseButton:FarmAnimatedCashButton;
      
      private var m_close_bt:FarmButton;
      
      private var m_frameName:FarmTextField;
      
      private var m_currencyImage:FarmIcon;
      
      private var MULTIPLIER_KEY:String = "CurrencyToCashMultiplier";
      
      public function WanderingPirateRewardItemsFrame(element:DisplayObject, owner:DisplayObject)
      {
         var currencyItem:FarmItem = null;
         super(element);
         this.m_owner = owner;
         if(m_element.hasOwnProperty("openForRubys_bt"))
         {
            addWidget(this.m_openCaseButton = new FarmAnimatedTextButton(m_element.openForRubys_bt,"",this.onOpenCaseButtonClicked),true);
            if(m_element.openForRubys_bt.hasOwnProperty("icon_mc"))
            {
               currencyItem = (this.m_owner as WanderingPirateWindow).currencyItem;
               if(currencyItem)
               {
                  addWidget(this.m_currencyImage = new FarmIcon(m_element.openForRubys_bt.icon_mc,currencyItem.iconUrl));
                  this.m_currencyImage.setIconSize(70,70);
               }
            }
         }
         if(m_element.hasOwnProperty("buyopen_bt"))
         {
            addWidget(this.m_buyCaseButton = new FarmAnimatedCashButton(m_element.buyopen_bt,"","",this.onBuyCaseButtonClicked),true);
         }
         if(m_element.hasOwnProperty("close_bt"))
         {
            this.m_close_bt = addWidget(new FarmButton(m_element.close_bt,this.onHide),true) as FarmButton;
         }
         if(m_element.hasOwnProperty("areaName_tf"))
         {
            this.m_frameName = new FarmTextField(m_element.areaName_tf,"");
            addWidget(this.m_frameName,false);
         }
      }
      
      public function onHide(event:Event) : void
      {
         m_element.visible = false;
      }
      
      private function onBuyCaseButtonClicked(event:Event) : void
      {
         (this.m_owner as WanderingPirateWindow).enableInput = false;
         (this.m_owner as WanderingPirateWindow).tintWindow();
         var confirmationText:String = ZLocUtils.t("Dialogs","FarmCashBuyConfirmation",{"price":this.m_cashValue});
         UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptBuyConfirmation,"farmAnimatedCashConfirmation",true,true);
      }
      
      private function onAcceptBuyConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            WanderingPirateManager.getInstance(WanderingPirateManager.FEATURE_NAME).onBuyCase(this.m_keyBoxNumber,this.m_cashValue,this.onCloseRewardCallback);
            StatsManager.count("" + WanderingPirateManager.FEATURE_NAME,"" + this.m_keyBoxNumber,"BuyCase");
         }
         else
         {
            (this.m_owner as WanderingPirateWindow).enableInput = true;
            (this.m_owner as WanderingPirateWindow).untintWindow();
         }
      }
      
      private function onOpenCaseButtonClicked(event:Event) : void
      {
         (this.m_owner as WanderingPirateWindow).enableInput = false;
         (this.m_owner as WanderingPirateWindow).tintWindow();
         WanderingPirateManager.getInstance(WanderingPirateManager.FEATURE_NAME).onOpenCase(this.m_keyBoxNumber,this.m_RubyCount,this.onCloseRewardCallback);
         StatsManager.count("" + WanderingPirateManager.FEATURE_NAME,"" + this.m_keyBoxNumber,"OpenCase");
      }
      
      private function onCloseRewardCallback(shouldShowMap:Boolean = false) : void
      {
         var showAnimation:Boolean = false;
         (this.m_owner as WanderingPirateWindow).enableInput = true;
         (this.m_owner as WanderingPirateWindow).untintWindow();
         (this.m_owner as WanderingPirateWindow).refreshWindow();
         this.refreshSlots();
         if(shouldShowMap)
         {
            showAnimation = true;
         }
      }
      
      private function onBragFeed(event:Event) : void
      {
         WanderingPirateManager.getInstance(WanderingPirateManager.FEATURE_NAME).onBragFeed(WanderingPirateManager.FINAL_REWARD);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new WanderingPirateRewardItemsSlot(slotElement,this.m_owner,this.getKeyBoxNumber);
      }
      
      override protected function setupData() : void
      {
      }
      
      public function get items() : Object
      {
         return m_slotData;
      }
      
      public function resetUnlockButton() : void
      {
         if(this.m_openCaseButton)
         {
            this.m_openCaseButton.enabled = WanderingPirateManager.getInstance(WanderingPirateManager.FEATURE_NAME).canOpenCase(this.m_RubyCount);
         }
      }
      
      public function set items(items:Object) : void
      {
         var rewardItemDetails:Object = null;
         rewardItemDetails = items[WanderingPirateManager.REWARD_ITEMS_STRING];
         m_slotData = rewardItemDetails[WanderingPirateManager.REWARD_ITEMS_STRING];
         this.m_keyBoxNumber = items[WanderingPirateManager.KEY_BOX_NUMBER];
         if(this.m_frameName)
         {
            this.m_frameName.visible = true;
            this.m_frameName.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WanderingPirateManager.FEATURE_NAME + "_chest_" + this.m_keyBoxNumber);
         }
         this.m_RubyCount = rewardItemDetails[WanderingPirateManager.CURRENCY_COUNT];
         var multiplierKey:String = WanderingPirateManager.FEATURE_NAME + this.MULTIPLIER_KEY;
         var multiplier:int = Global.farmGameSettingsManager.getInt(multiplierKey,DEFAULT_MULTIPLIER);
         this.m_cashValue = this.m_RubyCount * multiplier;
         if(this.m_openCaseButton)
         {
            this.m_openCaseButton.text = ZLocUtils.t("Dialogs",WanderingPirateManager.FEATURE_NAME + "_openForRubiesTxt",{"quantity":rewardItemDetails[WanderingPirateManager.CURRENCY_COUNT]});
            this.m_openCaseButton.enabled = WanderingPirateManager.getInstance(WanderingPirateManager.FEATURE_NAME).canOpenCase(this.m_RubyCount);
         }
         if(this.m_buyCaseButton)
         {
            this.m_buyCaseButton.enabled = Global.player.cash >= this.m_cashValue;
            this.m_buyCaseButton.setAmountText(this.m_cashValue.toString());
            this.m_buyCaseButton.text = ZLocUtils.t("Dialogs","Buy2");
         }
         refresh();
      }
      
      override public function release() : void
      {
         this.m_openCaseButton = null;
         this.m_buyCaseButton = null;
         super.release();
      }
      
      public function getKeyBoxNumber() : int
      {
         return this.m_keyBoxNumber;
      }
      
      public function refreshSlots() : void
      {
         var slot:WanderingPirateRewardItemsSlot = null;
         for(var i:int = 0; i < m_slots.length; i++)
         {
            slot = m_slots[i] as WanderingPirateRewardItemsSlot;
            if(slot)
            {
               slot.refreshRewardCount();
            }
         }
      }
   }
}

