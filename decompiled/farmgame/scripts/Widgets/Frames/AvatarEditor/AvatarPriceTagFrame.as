package Widgets.Frames.AvatarEditor
{
   import Classes.util.ZLocUtils;
   import Engine.Utilities;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   
   public class AvatarPriceTagFrame extends ZwFrame
   {
      
      private var m_cash:Number;
      
      private var m_coins:Number;
      
      private var m_infoButton:FarmAnimatedButton;
      
      private var m_priceCashTextField:ZwTextField;
      
      private var m_priceCoinTextField:ZwTextField;
      
      public function AvatarPriceTagFrame(element:MovieClip)
      {
         super(element);
         addWidget(new ZwTextField(m_element.generic_tf,ZLocUtils.t("Dialogs","AvatarEditorWindow_PriceTag_Title")));
         this.m_infoButton = addWidget(new FarmAnimatedButton(m_element.info_bt)) as FarmAnimatedButton;
         addWidget(new ZwWidget(m_element.cashIcon_mc));
         addWidget(new ZwWidget(m_element.coinIcon_mc));
         this.m_priceCashTextField = addWidget(new ZwTextField(m_element.cashCost_tf,"0")) as ZwTextField;
         this.m_priceCoinTextField = addWidget(new ZwTextField(m_element.coinCost_tf,"0")) as ZwTextField;
      }
      
      public function set cash(value:Number) : void
      {
         this.m_cash = value;
         this.refresh();
      }
      
      public function set coins(value:Number) : void
      {
         this.m_coins = value;
         this.refresh();
      }
      
      public function refresh() : void
      {
         this.m_priceCashTextField.text = Utilities.formatNumber(this.m_cash);
         this.m_priceCoinTextField.text = Utilities.formatNumber(this.m_coins);
         if(this.m_cash > 0 || this.m_coins > 0)
         {
            this.m_infoButton.visible = true;
         }
         else
         {
            this.m_infoButton.visible = false;
         }
      }
      
      override public function release() : void
      {
         this.m_infoButton = null;
         this.m_priceCashTextField = null;
         this.m_priceCoinTextField = null;
         super.release();
      }
   }
}

