package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.MouseEvent;
   
   public class SellAllAmountSelectionWindow extends GenericNumberSelectionWindow
   {
      
      private static var OK:String = "LootableItemGenericConfirmationWindow_Okay";
      
      private var m_sellCallback:Function;
      
      private var m_minAmount:int = 1;
      
      private var m_incermenterButton:FarmButton;
      
      private var m_decrementerButton:FarmButton;
      
      private var m_itemToUse:FarmItem;
      
      private var m_quantity:int;
      
      public function SellAllAmountSelectionWindow(item:Object, totalAmount:int, minAmount:int = 1, sellCallback:Function = null, closeCallback:Function = null)
      {
         this.m_itemToUse = Global.farmGameSettingsManager.getFarmItemByName(item.name);
         this.m_sellCallback = sellCallback;
         m_SharedCallBack = closeCallback;
         this.m_minAmount = minAmount;
         var yieldsString:String = "";
         if(this.m_itemToUse.sellCurrency != Currency.COINS)
         {
            yieldsString = this.m_itemToUse.untunedSellPrice + " " + ZLocUtils.t("FarmGame",Currency.COINS) + " and ";
         }
         yieldsString += this.m_itemToUse.sellDisplayPrice + " " + ZLocUtils.t("FarmGame",this.m_itemToUse.sellCurrency);
         var friendlyNameText:String = this.m_itemToUse.friendlyTitle;
         if(friendlyNameText == "" && this.m_itemToUse.className != null && this.m_itemToUse.className != "")
         {
            friendlyNameText = ZLocUtils.tk_pk_asTitle("Items:" + this.m_itemToUse.className + "_friendlyName");
         }
         var message:String = ZLocUtils.t("FarmGame","SellMultipleObjectSpecific",{
            "quantity":1,
            "item":friendlyNameText,
            "yieldsString":yieldsString
         });
         if(totalAmount == 1)
         {
            this.m_quantity = 1;
            UI.displayMessageWithHtml(message,GenericPopup.TYPE_YESNO,this.onSellClicked,"sellOneGiftHandler",true);
         }
         else
         {
            super(item,closeCallback,"testing",totalAmount,"assets/dialogs/FV_regift_howMany.swf",item.friendlyName);
         }
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new ZwFrame(m_window));
         m_quantityTextField = new ZwTextField(m_window.input_tf,String(this.m_minAmount));
         m_quantityTextField.restrict("0-9",3);
         m_quantityTextField.selectable = true;
         addWidget(m_quantityTextField);
         this.m_incermenterButton = new FarmButton(m_window.arrowUp_bt,this.onUpArrowClick);
         addWidget(this.m_incermenterButton);
         this.m_decrementerButton = new FarmButton(m_window.arrowDown_bt,this.onDownArrowClick);
         addWidget(this.m_decrementerButton);
         var itemIcon:FarmIcon = new FarmIcon(m_window.icon_mc,this.m_itemToUse.icon);
         itemIcon.setIconScale(0.5,0.5);
         addWidget(itemIcon);
         addWidget(new ZwTextField(m_window.itemTitle_tf,ZLocUtils.tk_pk_asTitle(this.m_itemToUse.friendlyName)));
         addWidget(new ZwTextField(m_window.giftAmount_tf,ZLocUtils.t("Dialogs","UseAllDialog_quanity",{"quantity":m_maxValue.toString()})));
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","SellAllDialog_tile")));
         addWidget(new FarmAnimatedTextButton(m_window.share_bt,ZLocUtils.t("Dialogs","Sell"),this.askForConfirm));
         addWidget(new FarmAnimatedTextButton(m_window.cancel_bt,ZLocUtils.t("Dialogs","Cancel"),this.onCancelClicked));
      }
      
      override protected function onUpArrowClick(e:MouseEvent) : void
      {
         var amount:int = currentQuantitySelected + 1 <= m_maxValue ? int(currentQuantitySelected + 1) : 1;
         m_quantityTextField.text = String(amount);
      }
      
      override protected function onDownArrowClick(e:MouseEvent) : void
      {
         var amount:int = 0;
         if(currentQuantitySelected <= m_maxValue)
         {
            amount = currentQuantitySelected - 1 > 0 ? int(currentQuantitySelected - 1) : m_maxValue;
         }
         else
         {
            amount = m_maxValue;
         }
         m_quantityTextField.text = String(amount);
      }
      
      protected function onSellClicked(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            this.m_sellCallback({
               "item":this.m_itemToUse,
               "quantitySelected":this.m_quantity
            });
            super.close();
         }
         else
         {
            super.close();
            if(m_SharedCallBack != null)
            {
               m_SharedCallBack(event);
            }
         }
      }
      
      private function askForConfirm(e:MouseEvent) : void
      {
         if(currentQuantitySelected > m_maxValue)
         {
            m_quantityTextField.text = Math.min(currentQuantitySelected,m_maxValue).toString();
         }
         if(currentQuantitySelected < this.m_minAmount)
         {
            m_quantityTextField.text = Math.max(currentQuantitySelected,this.m_minAmount).toString();
         }
         var locKeyFriendlyName:String = this.m_itemToUse.friendlyName;
         if(!ZLocUtils.hasString(locKeyFriendlyName))
         {
            locKeyFriendlyName = "Items:" + this.m_itemToUse.className + "_friendlyName";
         }
         this.m_quantity = currentQuantitySelected;
         var yieldsString:String = "";
         if(this.m_itemToUse.sellCurrency != Currency.COINS)
         {
            yieldsString = this.m_quantity * this.m_itemToUse.untunedSellPrice + " " + ZLocUtils.t("FarmGame",Currency.COINS) + " and ";
         }
         yieldsString += this.m_quantity * this.m_itemToUse.sellDisplayPrice + " " + ZLocUtils.t("FarmGame",this.m_itemToUse.sellCurrency);
         var message:String = ZLocUtils.t("FarmGame","SellMultipleObjectSpecific",{
            "quantity":this.m_quantity,
            "item":ZLocUtils.tk_pk(locKeyFriendlyName,"",1),
            "yieldsString":yieldsString
         });
         UI.displayMessageWithHtml(message,GenericPopup.TYPE_YESNO,this.onSellClicked,"sellOneGiftHandler",true);
      }
      
      override protected function onCancelClicked(event:MouseEvent) : void
      {
         super.close();
         if(m_SharedCallBack != null)
         {
            m_SharedCallBack(event);
         }
      }
      
      private function lockManipulatorButton(button:FarmButton, shouldLock:Boolean) : void
      {
         if(shouldLock == true)
         {
            button.enabled = false;
            button.applyGrayOut = true;
         }
         else
         {
            button.enabled = true;
            button.applyGrayOut = false;
         }
      }
   }
}

