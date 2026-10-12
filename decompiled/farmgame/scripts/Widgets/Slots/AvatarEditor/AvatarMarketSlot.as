package Widgets.Slots.AvatarEditor
{
   import Classes.Avatar.AvatarItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.AvatarEditor.AvatarMarketSlotFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public class AvatarMarketSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_container:AvatarMarketSlotFrame;
      
      private var m_selected:Boolean = false;
      
      private var m_data:AvatarItem;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_icon:FarmIcon;
      
      private var m_selectedHighlight:ZwWidget;
      
      private var m_xpTextField:ZwTextField;
      
      private var m_boughtFrame:ZwFrame;
      
      private var m_priceFrame:ZwFrame;
      
      private var m_priceTextField:ZwTextField;
      
      private var m_priceCashIcon:ZwWidget;
      
      private var m_priceCoinIcon:ZwWidget;
      
      private var m_buyButton:FarmAnimatedTextButton;
      
      private var m_buyCallback:Function;
      
      private var m_tryOnButton:FarmAnimatedTextButton;
      
      private var m_tryOnCallback:Function;
      
      private var m_removeButton:FarmAnimatedTextButton;
      
      private var m_removeCallback:Function;
      
      public function AvatarMarketSlot(element:DisplayObject, container:AvatarMarketSlotFrame, buyCallback:Function, tryOnCallback:Function, removeCallback:Function)
      {
         this.m_container = container;
         this.m_buyCallback = buyCallback;
         this.m_tryOnCallback = tryOnCallback;
         this.m_removeCallback = removeCallback;
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_nameTextField = addWidget(new ZwTextField(m_element.generic_tf)) as ZwTextField;
         this.m_xpTextField = addWidget(new ZwTextField(m_element.xp_tf)) as ZwTextField;
         this.m_priceFrame = addWidget(new ZwFrame(m_element.costGroup_mc)) as ZwFrame;
         this.m_priceTextField = this.m_priceFrame.addWidget(new ZwTextField(m_element.costGroup_mc.cost_tf,"")) as ZwTextField;
         (this.m_priceTextField.element as TextField).autoSize = TextFieldAutoSize.LEFT;
         this.m_priceCashIcon = this.m_priceFrame.addWidget(new ZwWidget(m_element.costGroup_mc.cashIcon_mc)) as ZwWidget;
         this.m_priceCoinIcon = this.m_priceFrame.addWidget(new ZwWidget(m_element.costGroup_mc.coinIcon_mc)) as ZwWidget;
         this.m_boughtFrame = addWidget(new ZwFrame(m_element.bought_mc)) as ZwFrame;
         this.m_boughtFrame.addWidget(new ZwTextField(m_element.bought_mc.generic_tf,ZLocUtils.t("Dialogs","AvatarEditorWindow_Bought")));
         this.m_selectedHighlight = addWidget(new ZwWidget(m_element.seleceted_mc)) as ZwWidget;
         this.m_buyButton = addWidget(new FarmAnimatedTextButton(m_element.buy_bt,ZLocUtils.t("Dialogs","AvatarEditorWindow_BuyButton"),this.onBuyButtonClick)) as FarmAnimatedTextButton;
         this.m_tryOnButton = addWidget(new FarmAnimatedTextButton(m_element.tryOn_mc,ZLocUtils.t("Dialogs","AvatarEditorWindow_PreviewButton"),this.onTryOnButtonClick)) as FarmAnimatedTextButton;
         this.m_removeButton = addWidget(new FarmAnimatedTextButton(m_element.takeOff_bt,ZLocUtils.t("Dialogs","AvatarEditorWindow_RemoveButton"),this.onRemoveButtonClick)) as FarmAnimatedTextButton;
      }
      
      override public function populate(data:Object) : void
      {
         var endDate:Number = NaN;
         super.populate(data);
         this.m_data = data as AvatarItem;
         if(this.m_data)
         {
            this.m_nameTextField.text = ZLocUtils.tk_pk_asTitle(this.m_data.friendlyName);
            this.m_nameTextField.visible = true;
            this.m_icon.loadIcon(this.m_data.iconPath);
            this.m_icon.visible = true;
            if(m_element.burstNew_mc)
            {
               m_element.burstNew_mc.visible = this.m_data.featured;
            }
            if(Global.player.avatarState.isPurchased(this.m_data.itemId))
            {
               this.m_boughtFrame.visible = true;
            }
            else
            {
               if(this.m_data.isLimited)
               {
                  endDate = FarmGameUtil.synchronizedDateToNumber(this.m_data.limitedEndDate);
                  this.m_xpTextField.text = FarmGameUtil.getTimeLeftText(endDate / 1000);
               }
               else
               {
                  this.m_xpTextField.text = ZLocUtils.t("Dialogs","AvatarEditorWindow_XPGained",{"quantity":this.m_data.xp});
               }
               this.m_xpTextField.visible = true;
               switch(this.m_data.market)
               {
                  case Currency.COINS:
                     this.m_priceCashIcon.visible = false;
                     this.m_priceCoinIcon.visible = true;
                     break;
                  case Currency.CASH:
                     this.m_priceCashIcon.visible = true;
                     this.m_priceCoinIcon.visible = false;
               }
               this.m_priceTextField.visible = true;
               this.m_priceTextField.text = Utilities.formatNumber(this.m_data.cost);
               this.m_priceFrame.x = 64 - Math.round(this.m_priceFrame.width / 2);
               this.m_priceFrame.visible = true;
               this.m_buyButton.visible = true;
               this.selected = this.m_container.isItemSelected(this.m_data.itemId);
            }
         }
      }
      
      public function get data() : AvatarItem
      {
         return this.m_data;
      }
      
      public function get selected() : Boolean
      {
         return this.m_selected;
      }
      
      public function set selected(value:Boolean) : void
      {
         this.m_selected = value;
         this.m_selectedHighlight.visible = this.m_selected;
         this.m_tryOnButton.visible = this.m_xpTextField.visible = this.m_buyButton.visible && !this.m_selected ? true : false;
         this.m_removeButton.visible = this.m_buyButton.visible && this.m_selected ? true : false;
      }
      
      private function onBuyButtonClick(evt:Event) : void
      {
         var message:String = null;
         if(this.m_buyButton.enabled)
         {
            if(this.m_buyCallback != null && Boolean(this.m_data))
            {
               if(this.m_data.market == Currency.CASH)
               {
                  message = ZLocUtils.t("Dialogs","FarmCashBuyConfirmation",{"price":this.m_data.cost});
                  UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,this.onByCashMessageClose,"BuyAvatarItemConfirmation",true);
               }
               else
               {
                  this.m_buyCallback(this.m_data,this.onItemBought);
               }
            }
         }
      }
      
      private function onByCashMessageClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.OK)
         {
            if(this.m_buyCallback != null && Boolean(this.m_data))
            {
               this.m_buyCallback(this.m_data,this.onItemBought);
            }
         }
      }
      
      private function onTryOnButtonClick(evt:Event) : void
      {
         if(this.m_tryOnButton.enabled)
         {
            if(this.m_tryOnCallback != null && Boolean(this.m_data))
            {
               this.m_tryOnCallback(this.m_data);
            }
         }
      }
      
      private function onRemoveButtonClick(evt:Event) : void
      {
         if(this.m_removeButton.enabled)
         {
            if(this.m_removeCallback != null && Boolean(this.m_data))
            {
               this.m_removeCallback(this.m_data);
            }
         }
      }
      
      public function onItemBought() : void
      {
         if(this.m_data != null)
         {
            this.m_boughtFrame.visible = true;
            this.m_priceFrame.visible = false;
            this.m_tryOnButton.visible = false;
            this.m_buyButton.visible = false;
         }
      }
      
      override public function release() : void
      {
         this.m_container = null;
         this.m_data = null;
         this.m_nameTextField = null;
         this.m_icon = null;
         this.m_selectedHighlight = null;
         this.m_xpTextField = null;
         this.m_priceFrame = null;
         this.m_priceTextField = null;
         this.m_priceCashIcon = null;
         this.m_priceCoinIcon = null;
         this.m_boughtFrame = null;
         this.m_buyButton = null;
         this.m_buyCallback = null;
         this.m_tryOnButton = null;
         this.m_tryOnCallback = null;
         this.m_removeButton = null;
         this.m_removeCallback = null;
         super.release();
      }
   }
}

