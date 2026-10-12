package Widgets.Frames
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class ItemPrizeFrame extends ZwFrame
   {
      
      protected static const STATE_NO_ACTIONS:int = 0;
      
      protected static const STATE_LOCKED:int = 1;
      
      protected static const STATE_REDEEM:int = 2;
      
      protected static const STATE_BUY:int = 3;
      
      protected static const ICON_SIZE:int = 65;
      
      protected var m_state:int = 1;
      
      protected var m_itemName:String = "";
      
      protected var m_itemNameTextField:ZwTextField = null;
      
      protected var m_button:FarmAnimatedButton = null;
      
      protected var m_buttonTextField:ZwTextField = null;
      
      protected var m_buttonQuantityTextField:ZwTextField = null;
      
      protected var m_callbacks:Object = null;
      
      private var m_textColor:String = null;
      
      public function ItemPrizeFrame(element:DisplayObject, itemName:String, iconURL:String, callbacks:Object, iconSize:Number = 65, textColor:String = null)
      {
         super(element);
         this.m_itemName = itemName;
         this.m_callbacks = callbacks;
         this.m_state = STATE_NO_ACTIONS;
         this.m_textColor = textColor;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         if(item != null)
         {
            if(m_element.itemTitle_tf)
            {
               this.m_itemNameTextField = new ZwTextField(m_element.itemTitle_tf,ZLocUtils.tk_pk_asTitle(item.friendlyName));
               addWidget(this.m_itemNameTextField);
               if(Boolean(this.m_itemNameTextField) && this.m_textColor != null)
               {
                  TemplateUIUtility.applyTextColor(this.m_itemNameTextField,TemplateUIUtility.VOTING,this.m_textColor);
               }
            }
         }
         var icon:FarmIcon = addWidget(new FarmIcon(m_element.item_mc,iconURL)) as FarmIcon;
         icon.setIconSize(iconSize,iconSize);
         if(m_element.hasOwnProperty("iconBox_mc") && m_element.iconBox_mc != null)
         {
            addWidget(new ZwFrame(m_element.iconBox_mc));
         }
      }
      
      protected function removeAllButtons() : void
      {
         if(this.m_button != null)
         {
            removeWidget(this.m_button);
            this.m_button = null;
         }
         if(this.m_buttonTextField != null)
         {
            removeWidget(this.m_buttonTextField);
            this.m_buttonTextField = null;
         }
         if(this.m_buttonQuantityTextField != null)
         {
            removeWidget(this.m_buttonQuantityTextField);
            this.m_buttonQuantityTextField = null;
         }
      }
      
      protected function enableRedeemButton() : void
      {
         this.removeAllButtons();
         if(m_element.hasOwnProperty("redeemitem_bt") && m_element.redeemitem_bt != null)
         {
            if(m_element.redeemitem_bt.hasOwnProperty("generic_tf"))
            {
               this.m_buttonTextField = new ZwTextField(m_element.redeemitem_bt.generic_tf,ZLocUtils.t("Dialogs","TicketPartyFlyout_redeem"));
               addWidget(this.m_buttonTextField);
            }
            this.m_button = new FarmAnimatedButton(m_element.redeemitem_bt,this.redeemButtonCallback);
            addWidget(this.m_button);
         }
      }
      
      protected function enableBuyButton(buyCost:String) : void
      {
         this.removeAllButtons();
         var buttonElement:Object = null;
         if(m_element.hasOwnProperty("buyitem_bt") && m_element.buyitem_bt != null)
         {
            buttonElement = m_element.buyitem_bt;
         }
         else if(m_element.hasOwnProperty("okay_bt") && m_element.okay_bt != null)
         {
            buttonElement = m_element.okay_bt;
         }
         if(buttonElement)
         {
            if(buttonElement.hasOwnProperty("cost_tf") && buttonElement.cost_tf != null)
            {
               this.m_buttonQuantityTextField = new ZwTextField(buttonElement.cost_tf,buyCost);
               addWidget(this.m_buttonQuantityTextField);
            }
            else if(buttonElement.hasOwnProperty("farmCash_tf") && buttonElement.farmCash_tf != null)
            {
               this.m_buttonQuantityTextField = new ZwTextField(buttonElement.farmCash_tf,buyCost);
               addWidget(this.m_buttonQuantityTextField);
            }
            if(buttonElement.hasOwnProperty("generic_tf") && Boolean(buttonElement.generic_tf))
            {
               this.m_buttonTextField = new ZwTextField(buttonElement.generic_tf,this.getBuyButtonText());
               addWidget(this.m_buttonTextField);
            }
            if(buttonElement.hasOwnProperty("buyfor_tf") && buttonElement.buyfor_tf != null)
            {
               this.m_buttonTextField = new ZwTextField(buttonElement.buyfor_tf,ZLocUtils.t("Dialogs","TicketPartyFlyout_buyfor",{"cost":buyCost}));
            }
            this.m_button = new FarmAnimatedButton(buttonElement as MovieClip,this.buyButtonCallback);
            addWidget(this.m_button);
         }
      }
      
      protected function enableUnlockButton(unlockCost:String) : void
      {
         this.removeAllButtons();
         if(m_element.hasOwnProperty("buyitem_bt") && m_element.buyitem_bt != null)
         {
            if(Boolean(m_element.buyitem_bt.hasOwnProperty("cost_tf")) && m_element.buyitem_bt.cost_tf != null)
            {
               this.m_buttonQuantityTextField = new ZwTextField(m_element.buyitem_bt.cost_tf,unlockCost);
               addWidget(this.m_buttonQuantityTextField);
            }
            else if(Boolean(m_element.buyitem_bt.hasOwnProperty("farmCash_tf")) && m_element.buyitem_bt.farmCash_tf != null)
            {
               this.m_buttonQuantityTextField = new ZwTextField(m_element.buyitem_bt.farmCash_tf,unlockCost);
               addWidget(this.m_buttonQuantityTextField);
            }
            if(Boolean(m_element.buyitem_bt.hasOwnProperty("generic_tf")) && Boolean(m_element.buyitem_bt.generic_tf))
            {
               this.m_buttonTextField = new ZwTextField(m_element.buyitem_bt.generic_tf,ZLocUtils.t("Dialogs","CompleteNowCamel"));
               addWidget(this.m_buttonTextField);
            }
            this.m_button = new FarmAnimatedButton(m_element.buyitem_bt,this.unlockButtonCallback);
            addWidget(this.m_button);
         }
      }
      
      protected function refreshUI() : void
      {
         switch(this.m_state)
         {
            case STATE_NO_ACTIONS:
               this.removeAllButtons();
               break;
            case STATE_LOCKED:
               this.enableUnlockButton(this.getUnlockCost().toString());
               break;
            case STATE_REDEEM:
               this.enableRedeemButton();
               break;
            case STATE_BUY:
               this.enableBuyButton(this.getBuyCost().toString());
         }
      }
      
      protected function getUnlockCost() : Number
      {
         return 0;
      }
      
      protected function getBuyCost() : Number
      {
         return 0;
      }
      
      protected function canBeRedeemed() : Boolean
      {
         return false;
      }
      
      protected function getBuyButtonText() : String
      {
         return ZLocUtils.t("Dialogs","BuyNow");
      }
      
      protected function unlockButtonCallback(event:MouseEvent) : void
      {
         if(this.m_callbacks != null && this.m_callbacks.hasOwnProperty("unlock"))
         {
            if(this.m_callbacks.unlock(this.m_itemName))
            {
               if(this.canBeRedeemed())
               {
                  this.m_state = STATE_REDEEM;
               }
               else
               {
                  this.m_state = STATE_BUY;
               }
            }
         }
      }
      
      protected function buyButtonCallback(event:MouseEvent) : void
      {
         var message:String = null;
         var cost:Number = this.getBuyCost();
         if(cost >= FarmAnimatedCashButton.DEFAULT_PAYMENT_CONFIRMATION_MINIMUM)
         {
            message = ZLocUtils.t("Dialogs","FarmCashBuyConfirmation",{"price":cost});
            UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,this.onByCashMessageClose,"BuyAvatarItemConfirmation",true);
         }
         else if(this.m_callbacks != null && this.m_callbacks.hasOwnProperty("buyItem"))
         {
            this.m_callbacks.buyItem(this.m_itemName,this.getBuyCost());
         }
      }
      
      private function onByCashMessageClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.OK)
         {
            if(this.m_callbacks != null && this.m_callbacks.hasOwnProperty("buyItem"))
            {
               this.m_callbacks.buyItem(this.m_itemName,this.getBuyCost());
            }
         }
      }
      
      protected function redeemButtonCallback(event:MouseEvent) : void
      {
         if(this.m_callbacks != null && this.m_callbacks.hasOwnProperty("redeemItem"))
         {
            this.m_callbacks.redeemItem(this.m_itemName);
            if(this.canBeRedeemed())
            {
               this.m_state = STATE_REDEEM;
            }
            else
            {
               this.m_state = STATE_BUY;
            }
         }
      }
   }
}

