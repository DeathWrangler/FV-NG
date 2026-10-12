package Widgets.Buttons
{
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FarmAnimatedCashButton extends FarmAnimatedMultiTextButton
   {
      
      public static const DEFAULT_PAYMENT_CONFIRMATION_MINIMUM:int = 10;
      
      public static const BUTTON_AMOUNT_TF:String = "amount_tf";
      
      public static const BUTTON_COST_TF:String = "cost_tf";
      
      public static const BUTTON_GENERIC_TF:String = "generic_tf";
      
      private var m_showPaymentConfirmation:Boolean;
      
      private var m_buyConfirmationText:String;
      
      private var m_paymentConfirmationMinimum:int = 10;
      
      private var m_cachedAmount:String;
      
      private var m_keepDisabled:Boolean = false;
      
      public function FarmAnimatedCashButton(element:MovieClip, text:String = "", amountText:String = "00", callback:Function = null, autoSize:Boolean = false, htmlText:Boolean = false, showPaymentConfirmation:Boolean = false, buyConfirmationText:String = "", paymentConfirmationMinimum:int = 10)
      {
         this.m_showPaymentConfirmation = showPaymentConfirmation;
         this.m_buyConfirmationText = buyConfirmationText;
         this.m_paymentConfirmationMinimum = paymentConfirmationMinimum;
         var textButtonArray:Array = [];
         if(element.generic_tf)
         {
            textButtonArray[BUTTON_GENERIC_TF] = text;
         }
         if(element.amount_tf)
         {
            textButtonArray[BUTTON_AMOUNT_TF] = amountText;
         }
         if(element.cost_tf)
         {
            textButtonArray[BUTTON_COST_TF] = amountText;
         }
         this.m_cachedAmount = amountText;
         super(element,textButtonArray,callback,autoSize,htmlText);
      }
      
      override public function preCallback(event:Event) : void
      {
         var confirmationText:String = null;
         var price:int = int(this.getAmountText());
         if(this.m_showPaymentConfirmation && price >= this.m_paymentConfirmationMinimum)
         {
            confirmationText = this.m_buyConfirmationText != "" ? this.m_buyConfirmationText : ZLocUtils.t("Dialogs","FarmCashBuyConfirmation",{"price":price});
            if(UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptBuyConfirmation,"farmAnimatedCashConfirmation",true,true))
            {
               this.enabled = false;
            }
         }
         else
         {
            super.preCallback(event);
         }
      }
      
      private function onAcceptBuyConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            super.preCallback(event);
         }
         this.enabled = true;
         if(event.button == GenericPopup.ACCEPT && this.m_keepDisabled)
         {
            this.enabled = false;
         }
      }
      
      public function setAmountText(text:String) : void
      {
         setText(BUTTON_AMOUNT_TF,text);
         setText(BUTTON_COST_TF,text);
         this.m_cachedAmount = text;
      }
      
      public function getAmountText() : String
      {
         var text:String = getText(BUTTON_AMOUNT_TF);
         if(text == "")
         {
            text = getText(BUTTON_COST_TF);
         }
         if(text == "")
         {
            text = this.m_cachedAmount;
         }
         return text;
      }
      
      public function setGenericText(text:String) : void
      {
         setText(BUTTON_GENERIC_TF,text);
      }
      
      public function get text() : String
      {
         return getText(BUTTON_GENERIC_TF);
      }
      
      public function set text(value:String) : void
      {
         this.setGenericText(value);
      }
      
      public function get showPaymentConfirmation() : Boolean
      {
         return this.m_showPaymentConfirmation;
      }
      
      public function set showPaymentConfirmation(value:Boolean) : void
      {
         this.m_showPaymentConfirmation = value;
      }
      
      public function set buyConfirmationText(text:String) : void
      {
         this.m_buyConfirmationText = text;
      }
      
      public function set keepDisabledAfterPaymentConfirmation(value:Boolean) : void
      {
         this.m_keepDisabled = value;
      }
   }
}

