package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.HolidayCountdownManager;
   import Managers.TemplateUIUtility;
   import Transactions.THolidayCountdownPublishItemOfTheDayFeed;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class CountdownSlot extends GenericTimedSlot
   {
      
      private var m_index:int = -1;
      
      private var m_lastShown:Number;
      
      private var m_isTemplateUIEnabled:Boolean = false;
      
      public function CountdownSlot(element:DisplayObject, parentWindow:FarmWindow)
      {
         var quantityWidget:ZwTextField = null;
         var buyButton:FarmAnimatedCashButton = null;
         this.m_isTemplateUIEnabled = TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.COUNTDOWN);
         super(element,parentWindow);
         if(m_element.currentBG_mc != null)
         {
            addWidget(new ZwFrame(m_element.currentBG_mc));
         }
         if(m_element.iconBox_mc != null)
         {
            addWidget(new FarmIcon(m_element.iconBox_mc));
         }
         if(m_element.itemBox_mc != null)
         {
            addWidget(new FarmIcon(m_element.itemBox_mc));
         }
         if(m_element.quantity_tf != null)
         {
            quantityWidget = getWidget(new ZwTextField(m_element.quantity_tf)) as ZwTextField;
            TemplateUIUtility.applyTextColor(quantityWidget,TemplateUIUtility.COUNTDOWN,HolidayCountdownManager.textColor);
         }
         if(Boolean(!this.isTemplateUIEnabled()) && Boolean(m_element) && Boolean(m_element["description_tf"]))
         {
            addWidget(new ZwTextField(m_element.description_tf,ZLocUtils.t("HolidayCountdown","HolidayCountdownToGet")));
         }
         if(m_element.buy_bt != null)
         {
            buyButton = getWidget(m_element.buy_bt) as FarmAnimatedCashButton;
            buyButton.text = ZLocUtils.t("HolidayCountdown","HolidayCountdownBuy");
            buyButton.showPaymentConfirmation = true;
         }
         if(m_element.unlockedBG_mc != null)
         {
            addWidget(new ZwFrame(m_element.unlockedBG_mc));
         }
      }
      
      override protected function isTemplateUIEnabled() : Boolean
      {
         return this.m_isTemplateUIEnabled;
      }
      
      override public function populate(data:Object) : void
      {
         var dayTextField:ZwTextField = null;
         var elementNew:DisplayObject = null;
         var element:DisplayObject = null;
         var buyButton:FarmAnimatedCashButton = null;
         this.m_index = uint(data);
         var dayInCampaign:int = HolidayCountdownManager.getDaysSinceCampaignStarted();
         var allAcq:Boolean = HolidayCountdownManager.hasAcquiredAllItems();
         var countdownObject:Object = {};
         countdownObject["dayInCampaign"] = dayInCampaign;
         countdownObject["allAcq"] = allAcq;
         super.populate(countdownObject);
         if(m_element.day_tf != null)
         {
            dayTextField = getWidget(m_element.day_tf) as ZwTextField;
            if(dayTextField)
            {
               dayTextField.text = ZLocUtils.t("HolidayCountdown","HolidayCountdownDayN",{"quantity":this.m_index + 1});
            }
            TemplateUIUtility.applyTextColor(dayTextField,TemplateUIUtility.COUNTDOWN,HolidayCountdownManager.textColor);
         }
         if(this.isTemplateUIEnabled())
         {
            elementNew = m_element.completeBG_mc;
            getWidget(elementNew).visible = true;
            TemplateUIUtility.applyBackgroundColor(elementNew,TemplateUIUtility.COUNTDOWN,HolidayCountdownManager.textColor);
         }
         if(this.shouldShowUnlockedSlot(countdownObject))
         {
            if(!this.isTemplateUIEnabled())
            {
               element = m_element.completeBG_mc;
               if(dayInCampaign == this.m_index && !allAcq)
               {
                  element = m_element.currentBG_mc;
               }
               else if((this.m_index < dayInCampaign || HolidayCountdownManager.isIndexUnlocked(this.m_index)) && !HolidayCountdownManager.hasReachedMaxProgress(this.m_index) && !allAcq)
               {
                  element = m_element.unlockedBG_mc;
               }
               getWidget(element).visible = true;
            }
            m_cost = HolidayCountdownManager.getItemCostByIndex(this.m_index);
            if(m_element.buy_bt != null)
            {
               buyButton = getWidget(m_element.buy_bt) as FarmAnimatedCashButton;
               buyButton.setAmountText(m_cost.toString());
               buyButton.visible = true;
            }
         }
      }
      
      override protected function getUnlockPrice() : Number
      {
         return HolidayCountdownManager.getUnlockPrice(this.m_index);
      }
      
      override protected function hasFinishedSlot() : Boolean
      {
         return HolidayCountdownManager.hasReachedMaxProgress(this.m_index) || HolidayCountdownManager.hasAcquiredAllItems();
      }
      
      override protected function shouldShowUnlockedSlot(data:Object) : Boolean
      {
         var result:Boolean = false;
         if(data.hasOwnProperty("dayInCampaign") && data.hasOwnProperty("allAcq"))
         {
            result = data["dayInCampaign"] >= this.m_index || HolidayCountdownManager.isIndexUnlocked(this.m_index) || Boolean(data["allAcq"]);
         }
         return result;
      }
      
      override protected function popNotFinishedSlot() : void
      {
         var iconBox:FarmIcon = null;
         var itemBox:FarmIcon = null;
         var itemReward:FarmIcon = null;
         var itemName:ZwTextField = null;
         super.popNotFinishedSlot();
         if(m_element.iconBox_mc != null)
         {
            iconBox = getWidget(m_element.iconBox_mc) as FarmIcon;
            iconBox.loadIcon(HolidayCountdownManager.getHelperItemByIndex(this.m_index).icon);
            iconBox.visible = true;
            if(!(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.FARMICON) && iconBox.element["bounds_mc"]))
            {
               iconBox.setIconSize(45,45);
            }
         }
         if(m_element.itemBox_mc != null)
         {
            itemBox = getWidget(m_element.itemBox_mc) as FarmIcon;
            if(m_item == null)
            {
               m_item = this.getCurrentItem(null);
            }
            itemBox.loadIcon(m_item.icon);
            itemBox.visible = true;
            if(!(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.FARMICON) && iconBox.element["bounds_mc"]))
            {
               itemBox.setIconSize(60,60);
            }
         }
         if(m_element.description_tf != null)
         {
            getWidget(m_element.description_tf).visible = true;
         }
         if(Boolean(!this.isTemplateUIEnabled()) && Boolean(m_element) && m_element.itemReward_mc != null)
         {
            itemReward = getWidget(m_element.itemReward_mc) as FarmIcon;
            itemReward.visible = false;
         }
         if(m_element.itemTitle_tf != null)
         {
            itemName = getWidget(m_element.itemTitle_tf) as ZwTextField;
            itemName.visible = false;
         }
      }
      
      override protected function getItemsOwned() : int
      {
         return HolidayCountdownManager.getProgressToNextReward(this.m_index);
      }
      
      override protected function getItemsNeeded() : int
      {
         return HolidayCountdownManager.requiredHelperCount(this.m_index);
      }
      
      override protected function canAskForItem() : Boolean
      {
         return HolidayCountdownManager.canPostItemOfTheDayReward(this.m_index);
      }
      
      override protected function getCurrentItem(data:Object) : FarmItem
      {
         return Global.farmGameSettingsManager.getFarmItemByCode(HolidayCountdownManager.getItemCodeByIndex(this.m_index));
      }
      
      override protected function canUnlockDay() : Boolean
      {
         return HolidayCountdownManager.canUnlockDay(this.m_index);
      }
      
      override protected function onBuyItemCallback(event:Event) : void
      {
         var itemName:String = null;
         var itemCost:int = HolidayCountdownManager.getItemCostByIndex(this.m_index);
         if(Global.player.canBuyCash(itemCost,true,itemName))
         {
            itemName = m_item.name;
            HolidayCountdownManager.recordDialogStats("buy_button",itemName);
            HolidayCountdownManager.buyItemByIndex(this.m_index);
            m_parentWindow.close();
         }
         HolidayCountdownManager.interactedWithDialog();
      }
      
      override protected function onAskCallback(event:Event) : void
      {
         var itemName:String = m_item.name;
         HolidayCountdownManager.recordDialogStats("ask_button",itemName);
         TransactionManager.addTransaction(new THolidayCountdownPublishItemOfTheDayFeed(this.m_index,this.feedCallback),true);
         HolidayCountdownManager.interactedWithDialog();
         HolidayCountdownManager.addReward(m_item.code);
         this.m_lastShown = Global.player.getFeatureLastShown(HolidayCountdownManager.rewardType);
         Global.player.setFeatureLastShown(HolidayCountdownManager.rewardType,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         m_parentWindow.refreshWindow();
      }
      
      private function feedCallback(result:Object) : void
      {
         if(result.rewards)
         {
            HolidayCountdownManager.rewards = result.rewards;
         }
         if(!result || !result.postSuccessful)
         {
            Global.player.setFeatureLastShown(HolidayCountdownManager.rewardType,this.m_lastShown,false);
            m_parentWindow.refreshWindow();
         }
      }
      
      override protected function onUnlockCallback(event:Event) : void
      {
         var coundownKey:String = null;
         var confirmationText:String = null;
         var unlockCost:int = HolidayCountdownManager.getUnlockPrice(this.m_index);
         if(unlockCost >= FarmAnimatedCashButton.DEFAULT_PAYMENT_CONFIRMATION_MINIMUM)
         {
            coundownKey = "HolidayCountdownUnlockConfirmation";
            confirmationText = ZLocUtils.t("HolidayCountdown",coundownKey,{"price":unlockCost});
            UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptUnlockConfirmation,coundownKey,true,true);
         }
         else
         {
            this.unlockAccept();
         }
      }
      
      private function onAcceptUnlockConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.unlockAccept();
         }
      }
      
      private function unlockAccept() : void
      {
         var unlockCost:int = HolidayCountdownManager.getUnlockPrice(this.m_index);
         if(Global.player.canBuyCash(unlockCost))
         {
            HolidayCountdownManager.unlockIndex(this.m_index);
         }
         HolidayCountdownManager.interactedWithDialog();
         m_parentWindow.refreshWindow();
      }
   }
}

