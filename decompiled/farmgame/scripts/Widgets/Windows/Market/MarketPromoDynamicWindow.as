package Widgets.Windows.Market
{
   import Classes.MarketPromotion;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.events.MouseEvent;
   
   public class MarketPromoDynamicWindow extends FarmWindow
   {
      
      protected var m_promoData:MarketPromotion = null;
      
      protected var m_onLoadedCallback:Function = null;
      
      protected var m_onPromoClickCallback:Function = null;
      
      public function MarketPromoDynamicWindow(promoData:MarketPromotion, onLoadedCallback:Function, onPromoClickCallback:Function)
      {
         this.m_promoData = promoData;
         this.m_onLoadedCallback = onLoadedCallback;
         this.m_onPromoClickCallback = onPromoClickCallback;
         super(this.m_promoData.asset);
         this.name = this.m_promoData.name;
      }
      
      override protected function postLoadComplete() : void
      {
         var subField:ZwTextField = null;
         super.postLoadComplete();
         if(this.m_promoData.localizedBtnText != "")
         {
            addWidget(new FarmAnimatedTextButton(m_window.generic_bt,this.m_promoData.localizedBtnText,this.onPromoButtonClick));
         }
         var headerField:ZwTextField = new ZwTextField(m_window.header_tf);
         headerField.text = this.m_promoData.localizedTitle;
         headerField.color = this.m_promoData.titleColor;
         addWidget(headerField);
         subField = new ZwTextField(m_window.sub_tf);
         subField.text = this.m_promoData.localizedSubTitle;
         subField.color = this.m_promoData.subColor;
         addWidget(subField);
         var cardBackground:FarmIcon = new FarmIcon(m_window.loader_mc);
         cardBackground.loadIcon(this.m_promoData.background);
         cardBackground.visible = true;
         addWidget(cardBackground);
         if(this.m_onLoadedCallback != null)
         {
            this.m_onLoadedCallback(m_window);
         }
      }
      
      protected function onPromoButtonClick(event:MouseEvent) : void
      {
         if(this.m_onPromoClickCallback != null)
         {
            this.m_onPromoClickCallback(this.m_promoData);
         }
      }
   }
}

