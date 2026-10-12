package Widgets.Frames.Market
{
   import Classes.util.ZLocUtils;
   import Engine.Utilities;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.Graphics;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public class MarketSlotSaleFrame extends ZwFrame
   {
      
      private static const ICON_PADDING:int = 4;
      
      private var m_strikethrough:Sprite;
      
      private var m_cashIcon:ZwWidget;
      
      private var m_coinIcon:ZwWidget;
      
      private var m_costTextField:ZwTextField;
      
      private var m_saleTextField:ZwTextField;
      
      public function MarketSlotSaleFrame(element:MovieClip, cost:int = 0, currency:String = "cash")
      {
         super(element);
         this.m_cashIcon = addWidget(new ZwWidget(m_element.cashIcon_mc)) as ZwWidget;
         this.m_coinIcon = addWidget(new ZwWidget(m_element.coinIcon_mc)) as ZwWidget;
         this.m_costTextField = addWidget(new ZwTextField(m_element.cost_tf)) as ZwTextField;
         (this.m_costTextField.element as TextField).autoSize = TextFieldAutoSize.RIGHT;
         (this.m_costTextField.element as TextField).multiline = false;
         (this.m_costTextField.element as TextField).wordWrap = false;
         this.m_saleTextField = addWidget(new ZwTextField(m_element.sale_tf,ZLocUtils.t("Dialogs","Sale"))) as ZwTextField;
         this.m_strikethrough = new Sprite();
         (m_element as MovieClip).addChild(this.m_strikethrough);
         this.cost = cost;
         this.currency = currency;
      }
      
      public function setSaleTextField(value:String) : void
      {
         this.m_saleTextField.text = value;
      }
      
      public function set cost(value:int) : void
      {
         this.m_costTextField.text = Utilities.formatNumber(value);
         this.m_cashIcon.x = this.m_costTextField.x - ICON_PADDING;
         this.m_coinIcon.x = this.m_costTextField.x - ICON_PADDING;
         var canvas:Graphics = this.m_strikethrough.graphics;
         canvas.clear();
         canvas.lineStyle(2,16711680,1,true);
         canvas.moveTo(0,0);
         canvas.lineTo(this.m_costTextField.width,0);
         this.m_strikethrough.x = this.m_costTextField.x;
         this.m_strikethrough.y = this.m_costTextField.y + this.m_costTextField.height / 2;
         this.m_saleTextField.x = this.m_cashIcon.x - this.m_cashIcon.width - ICON_PADDING - this.m_saleTextField.width;
      }
      
      public function set currency(value:String) : void
      {
         switch(value)
         {
            case Currency.CASH:
               this.m_cashIcon.visible = true;
               this.m_coinIcon.visible = false;
               break;
            case Currency.COINS:
               this.m_cashIcon.visible = false;
               this.m_coinIcon.visible = true;
         }
      }
      
      override public function release() : void
      {
         this.m_cashIcon = null;
         this.m_coinIcon = null;
         this.m_costTextField = null;
         this.m_saleTextField = null;
         this.m_strikethrough = null;
         super.release();
      }
      
      public function disableIcons() : void
      {
         this.m_cashIcon.visible = false;
         this.m_coinIcon.visible = false;
         this.m_saleTextField.x = this.m_cashIcon.x - ICON_PADDING - this.m_saleTextField.width;
      }
      
      public function disableSaleText() : void
      {
         this.m_saleTextField.visible = false;
      }
      
      public function enableIcons() : void
      {
         this.m_cashIcon.visible = true;
         this.m_coinIcon.visible = true;
      }
      
      public function enableSaleText() : void
      {
         this.m_saleTextField.visible = true;
      }
   }
}

