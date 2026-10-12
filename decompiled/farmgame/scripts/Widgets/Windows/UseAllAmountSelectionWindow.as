package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.MouseEvent;
   
   public class UseAllAmountSelectionWindow extends GenericNumberSelectionWindow
   {
      
      private static var OK:String = "LootableItemGenericConfirmationWindow_Okay";
      
      public static const TEXT_KEY_CURRENT_QUANTITY:String = "currentQuantity";
      
      public static const TEXT_KEY_TITLE:String = "title";
      
      public static const TEXT_KEY_BOTTOM_TEXT:String = "warning";
      
      public static const TEXT_KEY_ACCEPT_BUTTON:String = "acceptButton";
      
      public static const TEXT_KEY_CANCEL_BUTTON:String = "cancelButton";
      
      public static const OPTION_KEY_STARTING_QUANTITY:String = "startingQuantity";
      
      private var m_callback:Function;
      
      private var m_incermenterButton:FarmButton;
      
      private var m_decrementerButton:FarmButton;
      
      private var m_itemToUse:FarmItem;
      
      private var m_quantity:int;
      
      protected var m_closeCallback:Function = null;
      
      protected var m_textBundle:Object = null;
      
      protected var m_options:Object = null;
      
      public function UseAllAmountSelectionWindow(item:FarmItem, totalAmount:int, minAmount:int = 0, acceptCallback:Function = null, closeCallback:Function = null, textBundle:Object = null, options:Object = null)
      {
         this.m_itemToUse = item;
         this.m_closeCallback = closeCallback;
         this.m_textBundle = textBundle;
         if(this.m_textBundle == null)
         {
            this.m_textBundle = {};
         }
         this.m_options = options;
         if(this.m_options == null)
         {
            this.m_options = {};
         }
         super(item,acceptCallback,"testing",totalAmount,"assets/dialogs/FV_regift_howMany.swf",ZLocUtils.tk_pk_asTitle(item.friendlyName));
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new ZwFrame(m_window));
         var startingValue:int = m_maxValue;
         if(this.m_options[OPTION_KEY_STARTING_QUANTITY] != null)
         {
            startingValue = int(this.m_options[OPTION_KEY_STARTING_QUANTITY]);
         }
         m_quantityTextField = new ZwTextField(m_window.input_tf,String(startingValue));
         m_quantityTextField.restrict("0-9",3);
         m_quantityTextField.selectable = true;
         addWidget(m_quantityTextField);
         this.m_incermenterButton = new FarmButton(m_window.arrowUp_bt,this.onUpArrowClick);
         addWidget(this.m_incermenterButton);
         this.m_decrementerButton = new FarmButton(m_window.arrowDown_bt,this.onDownArrowClick);
         addWidget(this.m_decrementerButton);
         var itemIcon:FarmIcon = new FarmIcon(m_window.icon_mc,m_item.icon);
         itemIcon.fitIconInsideBounds(50,50);
         addWidget(itemIcon);
         addWidget(new ZwTextField(m_window.itemTitle_tf,m_units));
         var currentQuantityText:String = ZLocUtils.t("Dialogs","UseAllDialog_quanity",{"quantity":m_maxValue.toString()});
         if(this.m_textBundle[TEXT_KEY_CURRENT_QUANTITY] != null)
         {
            currentQuantityText = this.m_textBundle[TEXT_KEY_CURRENT_QUANTITY];
         }
         addWidget(new ZwTextField(m_window.giftAmount_tf,currentQuantityText));
         var titleText:String = ZLocUtils.t("Dialogs","UseAllDialog_tile");
         if(this.m_textBundle[TEXT_KEY_TITLE] != null)
         {
            titleText = this.m_textBundle[TEXT_KEY_TITLE];
         }
         addWidget(new ZwTextField(m_window.title_tf,titleText));
         var warningText:String = "";
         if(this.m_textBundle[TEXT_KEY_BOTTOM_TEXT] != null)
         {
            warningText = this.m_textBundle[TEXT_KEY_BOTTOM_TEXT];
         }
         addWidget(new ZwTextField(m_window.warning_tf,warningText));
         var acceptButtonText:String = ZLocUtils.t("Dialogs","UseAll_useButton");
         if(this.m_textBundle[TEXT_KEY_ACCEPT_BUTTON] != null)
         {
            acceptButtonText = this.m_textBundle[TEXT_KEY_ACCEPT_BUTTON];
         }
         addWidget(new FarmAnimatedTextButton(m_window.share_bt,acceptButtonText,this.onUseClicked));
         var cancelButtonText:String = ZLocUtils.t("Dialogs","Cancel");
         if(this.m_textBundle[TEXT_KEY_CANCEL_BUTTON] != null)
         {
            cancelButtonText = this.m_textBundle[TEXT_KEY_CANCEL_BUTTON];
         }
         addWidget(new FarmAnimatedTextButton(m_window.cancel_bt,cancelButtonText,this.onCancelClicked));
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
      
      protected function onUseClicked(e:MouseEvent) : void
      {
         var amount:int = 0;
         if(currentQuantitySelected > m_maxValue)
         {
            amount = m_maxValue;
            m_quantityTextField.text = String(amount);
         }
         else
         {
            if(this.m_SharedCallBack != null)
            {
               m_SharedCallBack({
                  "item":this.m_itemToUse,
                  "quantitySelected":currentQuantitySelected
               });
            }
            close();
         }
      }
      
      override protected function onCancelClicked(e:MouseEvent) : void
      {
         var amount:int = 0;
         if(this.m_closeCallback != null)
         {
            amount = currentQuantitySelected > m_maxValue ? m_maxValue : currentQuantitySelected;
            this.m_closeCallback({
               "item":this.m_itemToUse,
               "quantitySelected":currentQuantitySelected
            });
         }
         super.onCancelClicked(e);
      }
      
      private function checkInputBounds() : void
      {
         if(this.currentQuantitySelected >= m_maxValue)
         {
            this.lockManipulatorButton(this.m_incermenterButton,true);
         }
         else
         {
            this.lockManipulatorButton(this.m_incermenterButton,false);
         }
         if(this.currentQuantitySelected <= 1)
         {
            this.lockManipulatorButton(this.m_decrementerButton,true);
         }
         else
         {
            this.lockManipulatorButton(this.m_decrementerButton,false);
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

