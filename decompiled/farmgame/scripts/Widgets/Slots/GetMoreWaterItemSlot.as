package Widgets.Slots
{
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class GetMoreWaterItemSlot extends ItemPurchaseSlot
   {
      
      private var m_giftboxMc:ZwWidget;
      
      public function GetMoreWaterItemSlot(element:DisplayObject, parentWindow:FarmWindow)
      {
         super(element,parentWindow);
         addWidget(this.m_giftboxMc = new ZwWidget(m_element.giftbox_mc));
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         var cashButton:FarmAnimatedCashButton = m_buyButton as FarmAnimatedCashButton;
         if(cashButton)
         {
            cashButton.showPaymentConfirmation = true;
         }
      }
      
      override protected function onBuyCallback(event:Event) : void
      {
         if(Global.player.canBuyCash(getItemPrice()))
         {
            m_farmItem.onBuy(m_farmItem.name);
            this.m_giftboxMc.visible = true;
            (this.m_giftboxMc.element as MovieClip).gotoAndPlay(2);
         }
      }
   }
}

