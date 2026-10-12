package Widgets.Buttons
{
   import Widgets.Core.Frames.ZwFrame;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FarmAnimatedAdjustableCashButton extends ZwFrame
   {
      
      private var m_fcButton:FarmAnimatedCashButton;
      
      private var m_downButton:FarmButton;
      
      private var m_delta:int;
      
      private var m_anchorPrice:int;
      
      public function FarmAnimatedAdjustableCashButton(element:MovieClip, anchorPrice:int = 1, delta:int = 1, text:String = "", amountText:String = "00", callback:Function = null, autoSize:Boolean = false, htmlText:Boolean = false)
      {
         super(element);
         this.m_delta = delta;
         this.m_anchorPrice = anchorPrice;
         if(this.m_anchorPrice > int(amountText))
         {
            this.m_anchorPrice = int(amountText);
         }
         if(m_element.hasOwnProperty("buy_bt"))
         {
            addWidget(this.m_fcButton = new FarmAnimatedCashButton(m_element.buy_bt,text,amountText,callback,autoSize,htmlText));
         }
         if(m_element.hasOwnProperty("bottomArrow_bt"))
         {
            addWidget(this.m_downButton = new FarmButton(m_element.bottomArrow_bt,this.decrementAmount));
         }
         if(m_element.hasOwnProperty("topArrow_bt"))
         {
            addWidget(new FarmButton(m_element.topArrow_bt,this.incrementAmount));
         }
      }
      
      public function getAmountText() : String
      {
         return this.m_fcButton.getAmountText();
      }
      
      public function set callback(value:Function) : void
      {
         this.m_fcButton.callback = value;
      }
      
      private function incrementAmount(event:Event) : void
      {
         this.m_fcButton.setAmountText((int(this.m_fcButton.getAmountText()) + this.m_delta).toString());
         if(!this.m_downButton.visible)
         {
            this.m_downButton.visible = true;
         }
      }
      
      private function decrementAmount(event:Event) : void
      {
         var newAmount:int = int(this.m_fcButton.getAmountText()) - this.m_delta;
         if(newAmount <= this.m_anchorPrice)
         {
            this.m_fcButton.setAmountText(this.m_anchorPrice.toString());
            this.m_downButton.visible = false;
         }
         else
         {
            this.m_fcButton.setAmountText(newAmount.toString());
         }
      }
   }
}

