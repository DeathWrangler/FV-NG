package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.HolidayCountdownManager;
   import Managers.TemplateUIUtility;
   import Transactions.TBuyItemPutGiftbox;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class GenericTimedSlot extends ZwSlotFrame
   {
      
      protected var m_cost:int = -1;
      
      protected var m_item:FarmItem = null;
      
      protected var m_parentWindow:FarmWindow = null;
      
      protected var m_questionMark:ZwFrame = null;
      
      public function GenericTimedSlot(element:DisplayObject, parentWindow:FarmWindow)
      {
         super(element);
         this.m_parentWindow = parentWindow;
         if(m_element.day_tf != null)
         {
            addWidget(new ZwTextField(m_element.day_tf));
         }
         if(m_element.checkmark_mc != null)
         {
            addWidget(new ZwFrame(m_element.checkmark_mc));
         }
         if(m_element.hiddenBox_mc != null && m_element.hiddenBox_mc.questionmark_mc != null)
         {
            this.m_questionMark = addWidget(new ZwFrame(m_element.hiddenBox_mc.questionmark_mc)) as ZwFrame;
         }
         if(m_element.buy_bt != null)
         {
            addWidget(new FarmAnimatedCashButton(m_element.buy_bt,ZLocUtils.t("Dialogs","BuyPlain"),"00",this.onBuyItemCallback,false,false,true));
         }
         if(m_element.ask_bt != null)
         {
            addWidget(new FarmAnimatedTextButton(m_element.ask_bt,ZLocUtils.t("Dialogs","Ask"),this.onAskCallback));
         }
         if(m_element.completeBG_mc != null)
         {
            addWidget(new ZwFrame(m_element.completeBG_mc));
         }
         if(Boolean(!this.isTemplateUIEnabled()) && Boolean(m_element) && m_element.itemReward_mc != null)
         {
            addWidget(new FarmIcon(m_element.itemReward_mc));
         }
         if(m_element.itemTitle_tf != null)
         {
            addWidget(new ZwTextField(m_element.itemTitle_tf));
         }
         if(m_element.quantity_tf != null)
         {
            addWidget(new ZwTextField(m_element.quantity_tf));
         }
         if(m_element.unlockDesc_tf != null)
         {
            addWidget(new ZwTextField(m_element.unlockDesc_tf,ZLocUtils.t("Dialogs","TimedSlotUnlockMessage")));
         }
         if(m_element.unlockSlot_bt != null)
         {
            addWidget(new FarmAnimatedTextButton(m_element.unlockSlot_bt,"",this.onUnlockCallback));
         }
      }
      
      override public function populate(data:Object) : void
      {
         var buyButton:FarmAnimatedCashButton = null;
         var canBuy:Boolean = false;
         var canAsk:Boolean = false;
         var askButton:FarmAnimatedTextButton = null;
         var itemReward:FarmIcon = null;
         var itemName:ZwTextField = null;
         super.populate(data);
         this.m_item = this.getCurrentItem(data);
         if(this.shouldShowUnlockedSlot(data))
         {
            if(m_element.unlockDesc_tf != null)
            {
               getWidget(m_element.unlockDesc_tf).visible = false;
            }
            if(m_element.unlockSlot_bt != null)
            {
               getWidget(m_element.unlockSlot_bt).visible = false;
            }
            if(m_element.completeBG_mc != null)
            {
               getWidget(m_element.completeBG_mc).visible = true;
            }
            if(m_element.buy_bt != null)
            {
               buyButton = getWidget(m_element.buy_bt) as FarmAnimatedCashButton;
               this.m_cost = this.getCostForCurrItem();
               canBuy = this.m_cost > 0;
               if(canBuy)
               {
                  buyButton.setAmountText(this.m_cost.toString());
               }
               buyButton.visible = canBuy;
            }
            if(m_element.ask_bt != null)
            {
               canAsk = this.canAskForItem();
               askButton = getWidget(m_element.ask_bt) as FarmAnimatedTextButton;
               askButton.visible = this.showAskButton();
               askButton.toggleClickableButton(canAsk);
            }
            if(Boolean(!this.isTemplateUIEnabled()) && Boolean(m_element) && m_element.itemReward_mc != null)
            {
               itemReward = getWidget(m_element.itemReward_mc) as FarmIcon;
               itemReward.loadIcon(this.m_item.icon);
               itemReward.visible = true;
               itemReward.setIconSize(100,100);
            }
            if(m_element.itemTitle_tf != null)
            {
               itemName = getWidget(m_element.itemTitle_tf) as ZwTextField;
               itemName.text = this.m_item.friendlyTitle;
               itemName.visible = true;
            }
            if(this.hasFinishedSlot())
            {
               this.popFinishedSlot();
            }
            else
            {
               this.popNotFinishedSlot();
            }
         }
         else
         {
            this.popLockedSlot();
         }
      }
      
      protected function isTemplateUIEnabled() : Boolean
      {
         return false;
      }
      
      protected function shouldShowUnlockedSlot(data:Object) : Boolean
      {
         return data != null && this.m_item != null;
      }
      
      protected function getCostForCurrItem() : Number
      {
         var result:Number = this.m_item.cash;
         if(this.isProrated())
         {
            result = Math.ceil(result * this.getProration());
         }
         return result;
      }
      
      protected function isProrated() : Boolean
      {
         return false;
      }
      
      protected function getProration() : Number
      {
         return 1;
      }
      
      protected function hasFinishedSlot() : Boolean
      {
         return true;
      }
      
      protected function canAskForItem() : Boolean
      {
         return true;
      }
      
      protected function showAskButton() : Boolean
      {
         return true;
      }
      
      protected function popLockedSlot() : void
      {
         if(m_element.day_tf != null)
         {
            getWidget(m_element.day_tf).visible = true;
         }
         if(m_element.hiddenBox_mc != null && this.m_questionMark != null)
         {
            m_element.hiddenBox_mc.visible = true;
            this.m_questionMark.visible = true;
         }
         if(this.canUnlockDay())
         {
            if(m_element.unlockDesc_tf != null)
            {
               getWidget(m_element.unlockDesc_tf).visible = true;
            }
            if(m_element.unlockSlot_bt != null)
            {
               getWidget(m_element.unlockSlot_bt).visible = true;
               if(m_element.unlockSlot_bt.unlock_tf != null)
               {
                  m_element.unlockSlot_bt.unlock_tf.text = ZLocUtils.t("Dialogs","TimedSlotUnlock",{"quantity":this.getUnlockPrice()});
               }
            }
         }
      }
      
      protected function canUnlockDay() : Boolean
      {
         return false;
      }
      
      protected function getUnlockPrice() : Number
      {
         return 0;
      }
      
      protected function popFinishedSlot() : void
      {
         var itemBox:FarmIcon = null;
         var itemReward:FarmIcon = null;
         var itemName:ZwTextField = null;
         if(Boolean(this.isTemplateUIEnabled()) && Boolean(m_element) && Boolean(m_element["itemBox_mc"]))
         {
            itemBox = getWidget(m_element.itemBox_mc) as FarmIcon;
            if(this.m_item == null)
            {
               this.m_item = this.getCurrentItem(null);
            }
            if(itemBox)
            {
               itemBox.loadIcon(this.m_item.icon);
               itemBox.visible = true;
            }
         }
         if(Boolean(!this.isTemplateUIEnabled()) && Boolean(m_element) && m_element.itemReward_mc != null)
         {
            itemReward = getWidget(m_element.itemReward_mc) as FarmIcon;
            itemReward.loadIcon(this.m_item.icon);
            itemReward.visible = true;
            if(!itemReward.element["bounds_mc"])
            {
               itemReward.setIconSize(100,100);
            }
         }
         if(m_element.checkmark_mc != null)
         {
            getWidget(m_element.checkmark_mc).visible = true;
         }
         if(m_element.ask_bt != null)
         {
            getWidget(m_element.ask_bt).visible = false;
         }
         if(m_element.itemTitle_tf != null)
         {
            itemName = getWidget(m_element.itemTitle_tf) as ZwTextField;
            itemName.text = this.m_item.friendlyTitle;
            itemName.visible = true;
            TemplateUIUtility.applyTextColor(itemName,TemplateUIUtility.COUNTDOWN,HolidayCountdownManager.textColor);
         }
      }
      
      protected function popNotFinishedSlot() : void
      {
         var itemsOwned:int = 0;
         var itemsNeeded:int = 0;
         var quantityWidget:ZwTextField = null;
         if(m_element.checkmark_mc != null)
         {
            getWidget(m_element.checkmark_mc).visible = false;
         }
         if(m_element.quantity_tf != null)
         {
            itemsOwned = this.getItemsOwned();
            itemsNeeded = this.getItemsNeeded();
            quantityWidget = getWidget(m_element.quantity_tf) as ZwTextField;
            quantityWidget.text = ZLocUtils.t("HolidayCountdown","HolidayCountdownQuantity",{
               "quantity1":itemsOwned,
               "quantity2":itemsNeeded
            });
            quantityWidget.visible = true;
         }
      }
      
      protected function getItemsOwned() : int
      {
         return 0;
      }
      
      protected function getItemsNeeded() : int
      {
         return 0;
      }
      
      protected function getCurrentItem(data:Object) : FarmItem
      {
         return null;
      }
      
      protected function onBuyItemCallback(event:Event) : void
      {
         if(this.m_item != null && !this.isProrated() && Global.player.canBuyCash(this.m_item.cash,true,this.m_item.name))
         {
            TransactionManager.addTransaction(new TBuyItemPutGiftbox(this.m_item,Currency.CASH),true);
            this.m_parentWindow.close();
         }
      }
      
      protected function onAskCallback(event:Event) : void
      {
         this.m_parentWindow.refreshWindow();
      }
      
      protected function onUnlockCallback(event:Event) : void
      {
      }
      
      override public function release() : void
      {
         this.m_questionMark = null;
         this.m_item = null;
         this.m_cost = -1;
         this.m_parentWindow = null;
         super.release();
      }
   }
}

