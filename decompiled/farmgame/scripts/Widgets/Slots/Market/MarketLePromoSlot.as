package Widgets.Slots.Market
{
   import Classes.MarketPromotion;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Market.MarketPromoLESlotFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class MarketLePromoSlot extends ZwSlotFrame
   {
      
      private var m_container:MarketPromoLESlotFrame;
      
      private var m_loader:FarmIcon = null;
      
      private var m_button:FarmAnimatedTextButton = null;
      
      private var m_header:ZwTextField = null;
      
      private var m_subtitle:ZwTextField = null;
      
      private var m_data:Array = null;
      
      private var m_promoCallback:Function = null;
      
      public function MarketLePromoSlot(element:DisplayObject, container:MarketPromoLESlotFrame)
      {
         this.m_container = container;
         super(element);
         this.m_loader = addWidget(new FarmIcon(m_element.loader_mc)) as FarmIcon;
         this.m_button = addWidget(new FarmAnimatedTextButton(m_element.generic_bt,"",null)) as FarmAnimatedTextButton;
         this.m_header = addWidget(new ZwTextField(m_element.header_tf)) as ZwTextField;
         this.m_subtitle = addWidget(new ZwTextField(m_element.sub_tf)) as ZwTextField;
      }
      
      override public function populate(data:Object) : void
      {
         var promo:MarketPromotion = null;
         super.populate(data);
         if(data.length > 0)
         {
            this.m_data = data as Array;
            promo = this.m_data[0];
            this.m_button.text = promo.localizedBtnText;
            this.m_promoCallback = this.m_container.promoClickCallback;
            this.m_button.callback = this.onPromoButtonClick;
            this.m_header.color = promo.titleColor;
            this.m_subtitle.text = promo.localizedSubTitle;
            this.m_subtitle.color = promo.subColor;
            this.m_loader.loadIcon(promo.background,this.onAssetLoaded);
            this.m_header.visible = true;
            this.m_subtitle.visible = true;
         }
      }
      
      private function onAssetLoaded() : void
      {
         this.m_button.visible = true;
         this.m_loader.visible = true;
      }
      
      private function onPromoButtonClick(event:MouseEvent) : void
      {
         if(this.m_promoCallback != null && Boolean(this.m_data))
         {
            this.m_promoCallback(this.m_data[0]);
         }
      }
   }
}

