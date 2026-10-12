package Widgets.Slots
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.ZLocConstants;
   import Classes.ExchangeSystemObject;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.ExchangeManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.ExchangeWindow;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class ExchangeSlot extends ZwSlotFrame
   {
      
      private static var m_manager:ExchangeManager = null;
      
      private var m_parentWindow:ExchangeWindow = null;
      
      private var m_featureName:String = "";
      
      private var m_cookingSlot:int = 0;
      
      public function ExchangeSlot(element:DisplayObject, parentWindow:FarmWindow)
      {
         var finishCost:String = null;
         super(element);
         m_manager = ExchangeManager.getInstance();
         this.m_parentWindow = parentWindow as ExchangeWindow;
         this.m_featureName = this.m_parentWindow.getFeatureName();
         if(m_element.hasOwnProperty("timer_tf"))
         {
            addWidget(new ZwTextField(m_element.timer_tf,""));
         }
         if(m_element.hasOwnProperty("icon_mc"))
         {
            addWidget(new FarmIcon(m_element.icon_mc));
         }
         if(m_element.hasOwnProperty("smallbushel_mc"))
         {
            addWidget(new ZwWidget(m_element.smallbushel_mc));
         }
         if(m_element.hasOwnProperty("lockicon_mc"))
         {
            addWidget(new ZwWidget(m_element.lockicon_mc));
         }
         if(m_element.hasOwnProperty("claim_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_element.claim_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"ExchangeSlotClaim"),this.claimCallback));
         }
         if(m_element.hasOwnProperty("buy_bt"))
         {
            finishCost = m_manager.getFinishCost(this.m_featureName).toString();
            addWidget(new FarmAnimatedCashButton(m_element.buy_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"ExchangeSlotFinish"),finishCost,this.finishCallback,false,false,true,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeSlotFinishConfirm",{"price":finishCost})));
         }
      }
      
      override public function populate(data:Object) : void
      {
         var unlocked:Boolean = false;
         var lockWidget:ZwWidget = null;
         var unlockButton:FarmAnimatedCashButton = null;
         var unlockCost:String = null;
         var claimButton:FarmAnimatedTextButton = null;
         var timerWidget:ZwTextField = null;
         var finishButton:FarmAnimatedCashButton = null;
         var finishCost:String = null;
         var iconWidget:FarmIcon = null;
         var cookingItem:FarmItem = null;
         this.m_cookingSlot = data["slotNumber"];
         var systemObject:ExchangeSystemObject = m_manager.getExchangeSystemObject(this.m_featureName);
         super.populate(data);
         var itemName:String = systemObject.getItemName(this.m_cookingSlot);
         if(itemName == null || itemName == "")
         {
            unlocked = systemObject.getUnlocked(this.m_cookingSlot) == "true";
            if(m_element.hasOwnProperty("smallbushel_mc"))
            {
               getWidget(m_element.smallbushel_mc).visible = true;
            }
            if(m_element.hasOwnProperty("timer_tf"))
            {
               getWidget(m_element.timer_tf).visible = false;
            }
            if(m_element.hasOwnProperty("icon_mc"))
            {
               getWidget(m_element.icon_mc).visible = false;
            }
            if(m_element.hasOwnProperty("lockicon_mc"))
            {
               lockWidget = getWidget(m_element.lockicon_mc) as ZwWidget;
               lockWidget.visible = !unlocked;
               if(!unlocked)
               {
                  lockWidget.detachTooltip();
                  lockWidget.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "LockedHoverOverText",{"quantityNeeded":systemObject.neededForUnlock(this.m_cookingSlot)})));
               }
            }
            if(m_element.hasOwnProperty("buy_bt"))
            {
               unlockButton = getWidget(m_element.buy_bt) as FarmAnimatedCashButton;
               unlockButton.visible = !unlocked && systemObject.canUnlock(this.m_cookingSlot);
               if(!unlocked)
               {
                  unlockButton.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"ExchangeSlotUnlock");
                  unlockCost = m_manager.getExpandCost(this.m_featureName,this.m_cookingSlot).toString();
                  unlockButton.setAmountText(unlockCost);
                  unlockButton.callback = this.unlockCallback;
                  unlockButton.buyConfirmationText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeSlotUnlockConfirm",{"price":unlockCost});
               }
            }
            if(m_element.hasOwnProperty("claim_bt"))
            {
               getWidget(m_element.claim_bt).visible = false;
            }
         }
         else
         {
            if(m_manager.isExchangeFinished(this.m_featureName,this.m_cookingSlot))
            {
               if(m_element.hasOwnProperty("claim_bt"))
               {
                  claimButton = getWidget(m_element.claim_bt) as FarmAnimatedTextButton;
                  claimButton.visible = true;
                  if(m_manager.canClaim(this.m_featureName,this.m_cookingSlot))
                  {
                     claimButton.toggleClickableButton(true);
                  }
                  else
                  {
                     claimButton.toggleClickableButton(false,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "CantClaim"));
                  }
               }
               if(m_element.hasOwnProperty("buy_bt"))
               {
                  getWidget(m_element.buy_bt).visible = false;
               }
               if(m_element.hasOwnProperty("timer_tf"))
               {
                  getWidget(m_element.timer_tf).visible = false;
               }
            }
            else
            {
               if(m_element.hasOwnProperty("claim_bt"))
               {
                  getWidget(m_element.claim_bt).visible = false;
               }
               if(m_element.hasOwnProperty("timer_tf"))
               {
                  timerWidget = getWidget(m_element.timer_tf) as ZwTextField;
                  timerWidget.text = m_manager.getTimeLeftFriendlyText(this.m_featureName,this.m_cookingSlot);
                  timerWidget.visible = true;
               }
               if(m_element.hasOwnProperty("buy_bt"))
               {
                  finishButton = getWidget(m_element.buy_bt) as FarmAnimatedCashButton;
                  finishButton.visible = true;
                  finishButton.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"ExchangeSlotFinish");
                  finishCost = m_manager.getFinishCost(this.m_featureName).toString();
                  finishButton.setAmountText(finishCost);
                  finishButton.callback = this.finishCallback;
                  finishButton.buyConfirmationText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeSlotFinishConfirm",{"price":finishCost});
                  if(m_manager.canClaim(this.m_featureName,this.m_cookingSlot))
                  {
                     finishButton.toggleClickableButton(true);
                  }
                  else
                  {
                     finishButton.toggleClickableButton(false,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "CantClaim"));
                  }
               }
            }
            if(m_element.hasOwnProperty("icon_mc"))
            {
               iconWidget = getWidget(m_element.icon_mc) as FarmIcon;
               cookingItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
               iconWidget.loadIcon(cookingItem.iconUrl);
               iconWidget.visible = true;
            }
            if(m_element.hasOwnProperty("smallbushel_mc"))
            {
               getWidget(m_element.smallbushel_mc).visible = false;
            }
            if(m_element.hasOwnProperty("lockicon_mc"))
            {
               getWidget(m_element.lockicon_mc).visible = false;
            }
         }
      }
      
      public function finishCallback(event:Event) : void
      {
         var dialog:GenericPopup = null;
         var finishButton:FarmAnimatedCashButton = null;
         var finishCost:int = m_manager.getFinishCost(this.m_featureName);
         if(finishCost >= 10)
         {
            m_manager.instantFinishExchange(this.m_featureName,this.m_cookingSlot);
            this.m_parentWindow.refreshWindow();
         }
         else
         {
            dialog = new GenericPopup(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeSlotFinishConfirm",{"price":finishCost}),GenericPopup.TYPE_ACCEPTCANCEL,ZCacheUtil.applyPartial(this.finishExchangeConfirmed,this,[this.m_featureName,this.m_cookingSlot]));
            UI.displayPopup(dialog,false,"ExchangeInstantFinishConfirmation",true);
            if(m_element.hasOwnProperty("buy_bt"))
            {
               finishButton = getWidget(m_element.buy_bt) as FarmAnimatedCashButton;
               finishButton.toggleClickableButton(false);
            }
         }
      }
      
      public function finishExchangeConfirmed(traderName:String, slotNumber:int, event:GenericPopupEvent = null) : void
      {
         var finishButton:FarmAnimatedCashButton = null;
         var finishCost:int = m_manager.getFinishCost(traderName);
         if(event == null || event.button == GenericPopup.ACCEPT)
         {
            m_manager.instantFinishExchange(this.m_featureName,this.m_cookingSlot);
         }
         if(m_element.hasOwnProperty("buy_bt"))
         {
            finishButton = getWidget(m_element.buy_bt) as FarmAnimatedCashButton;
            finishButton.toggleClickableButton(true);
         }
         this.m_parentWindow.refreshWindow();
      }
      
      public function claimCallback(event:Event) : void
      {
         m_manager.claimExchange(this.m_parentWindow.getFeatureName(),this.m_cookingSlot);
         this.m_parentWindow.refreshWindow();
      }
      
      public function unlockCallback(event:Event) : void
      {
         var dialog:GenericPopup = null;
         var unlockButton:FarmAnimatedCashButton = null;
         var systemObject:ExchangeSystemObject = m_manager.getExchangeSystemObject(this.m_featureName);
         var expandPrice:int = systemObject.getExpandPrice(this.m_cookingSlot);
         if(expandPrice >= 10)
         {
            m_manager.unlockExchangeSlot(this.m_featureName,this.m_cookingSlot);
            this.m_parentWindow.refreshWindow();
         }
         else
         {
            dialog = new GenericPopup(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeSlotUnlockConfirm",{"price":expandPrice}),GenericPopup.TYPE_ACCEPTCANCEL,ZCacheUtil.applyPartial(this.unlockSlotConfirmed,this,[this.m_featureName,this.m_cookingSlot]));
            UI.displayPopup(dialog,false,"ExchangeUnlockConfirmation",true);
            if(m_element.hasOwnProperty("buy_bt"))
            {
               unlockButton = getWidget(m_element.buy_bt) as FarmAnimatedCashButton;
               unlockButton.toggleClickableButton(false);
            }
         }
      }
      
      public function unlockSlotConfirmed(traderName:String, slotNumber:int, event:GenericPopupEvent = null) : void
      {
         var unlockButton:FarmAnimatedCashButton = null;
         if(event == null || event.button == GenericPopup.ACCEPT)
         {
            m_manager.unlockExchangeSlot(this.m_featureName,this.m_cookingSlot);
         }
         if(m_element.hasOwnProperty("buy_bt"))
         {
            unlockButton = getWidget(m_element.buy_bt) as FarmAnimatedCashButton;
            unlockButton.toggleClickableButton(true);
         }
         this.m_parentWindow.refreshWindow();
      }
   }
}

