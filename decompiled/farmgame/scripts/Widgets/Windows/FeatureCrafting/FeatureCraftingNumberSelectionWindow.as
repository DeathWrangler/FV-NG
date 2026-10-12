package Widgets.Windows.FeatureCrafting
{
   import Classes.FeatureCrafting.FeatureCraftingGood;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.GenericNumberSelectionWindow;
   import flash.events.MouseEvent;
   
   public class FeatureCraftingNumberSelectionWindow extends GenericNumberSelectionWindow
   {
      
      public static const OPTION_KEY_STARTING_QUANTITY:String = "startingQuantity";
      
      public static const TEXT_KEY_CURRENT_QUANTITY:String = "currentQuantity";
      
      public static const TEXT_KEY_TITLE:String = "title";
      
      public static const TEXT_KEY_BOTTOM_TEXT:String = "warning";
      
      public static const TEXT_KEY_ACCEPT_BUTTON:String = "acceptButton";
      
      public static const TEXT_KEY_CANCEL_BUTTON:String = "cancelButton";
      
      private var m_callback:Function;
      
      private var m_incrementerButton:FarmButton;
      
      private var m_decrementerButton:FarmButton;
      
      private var m_quantity:int;
      
      protected var m_options:Object = null;
      
      protected var m_closeCallback:Function = null;
      
      protected var m_textBundle:Object = null;
      
      public function FeatureCraftingNumberSelectionWindow(item:FeatureCraftingGood, maximum:int, minimum:int = 0, acceptCallback:Function = null, closeCallback:Function = null, textBundle:Object = null, options:Object = null)
      {
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
         super(item,acceptCallback,"testing",maximum,"assets/dialogs/FV_regift_howMany.swf",item.friendlyTitle);
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
         this.m_incrementerButton = new FarmButton(m_window.arrowUp_bt,this.onUpArrowClick);
         addWidget(this.m_incrementerButton);
         this.m_decrementerButton = new FarmButton(m_window.arrowDown_bt,this.onDownArrowClick);
         addWidget(this.m_decrementerButton);
         var icon:FarmIcon = new FarmIcon(m_window.icon_mc,Global.getAssetURL((m_item as FeatureCraftingGood).iconUrl()));
         icon.fitIconInsideBounds(50,50);
         addWidget(icon);
         addWidget(new ZwTextField(m_window.itemTitle_tf,m_units));
         var currentQuantityText:String = ZLocUtils.t("Dialogs","UseAllDialog_quanity",{"quantity":m_maxValue});
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
         if(m_SharedCallBack != null)
         {
            m_SharedCallBack(currentQuantitySelected);
         }
         close();
      }
      
      override protected function onCancelClicked(e:MouseEvent) : void
      {
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback();
         }
         super.onCancelClicked(e);
      }
   }
}

