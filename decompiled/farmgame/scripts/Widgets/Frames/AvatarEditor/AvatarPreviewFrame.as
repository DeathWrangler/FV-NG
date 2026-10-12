package Widgets.Frames.AvatarEditor
{
   import Classes.Avatar.AvatarItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Frames.ZwFrame;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class AvatarPreviewFrame extends ZwFrame
   {
      
      private var m_items:Array;
      
      private var m_buyNowButton:FarmAnimatedTextButton;
      
      private var m_resetButton:FarmAnimatedTextButton;
      
      private var m_priceFrame:AvatarPriceTagFrame;
      
      private var m_receiptSlotFrame:AvatarReceiptSlotFrame;
      
      public function AvatarPreviewFrame(element:MovieClip, buyCallback:Function, resetCallback:Function)
      {
         super(element);
         this.m_buyNowButton = addWidget(new FarmAnimatedTextButton(m_element.buyNow_bt,ZLocUtils.t("Dialogs","AvatarEditorWindow_BuyNowButton"),buyCallback)) as FarmAnimatedTextButton;
         this.m_resetButton = addWidget(new FarmAnimatedTextButton(m_element.reset_bt,ZLocUtils.t("Dialogs","AvatarEditorWindow_ResetButton"),resetCallback)) as FarmAnimatedTextButton;
         this.m_priceFrame = addWidget(new AvatarPriceTagFrame(m_element.priceTag_mc)) as AvatarPriceTagFrame;
         (this.m_priceFrame.element as MovieClip).addEventListener(MouseEvent.MOUSE_OVER,this.onPriceFrameMouseOver,false,0,true);
         (this.m_priceFrame.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onPriceFrameMouseOut,false,0,true);
         this.m_receiptSlotFrame = addWidget(new AvatarReceiptSlotFrame(m_element.frame_reciept_mc),false) as AvatarReceiptSlotFrame;
         this.refresh();
      }
      
      public function get items() : Array
      {
         return this.m_items;
      }
      
      public function set items(value:Array) : void
      {
         this.m_items = value;
         this.m_receiptSlotFrame.items = this.items;
         this.refresh();
      }
      
      private function refresh() : void
      {
         var item:AvatarItem = null;
         var cash:int = 0;
         var coins:int = 0;
         if(this.m_items != null)
         {
            for each(item in this.m_items)
            {
               switch(item.market)
               {
                  case Currency.COINS:
                     coins += item.cost;
                     break;
                  case Currency.CASH:
                     cash += item.cost;
               }
            }
         }
         this.m_priceFrame.cash = cash;
         this.m_priceFrame.coins = coins;
         if(cash > 0 || coins > 0)
         {
            this.m_buyNowButton.enabled = true;
         }
         else
         {
            this.m_buyNowButton.enabled = false;
         }
      }
      
      private function onPriceFrameMouseOver(evt:MouseEvent) : void
      {
         if(!this.m_receiptSlotFrame.visible && this.m_items != null && this.m_items.length > 0)
         {
            this.m_receiptSlotFrame.visible = true;
         }
      }
      
      private function onPriceFrameMouseOut(evt:MouseEvent) : void
      {
         if(!FarmGameUtil.isDescendant(this.m_priceFrame.element as MovieClip,evt.relatedObject))
         {
            this.m_receiptSlotFrame.visible = false;
         }
      }
      
      override public function release() : void
      {
         this.m_items = null;
         this.m_buyNowButton = null;
         this.m_resetButton = null;
         (this.m_priceFrame.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OVER,this.onPriceFrameMouseOver);
         (this.m_priceFrame.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OUT,this.onPriceFrameMouseOut);
         this.m_priceFrame = null;
         this.m_receiptSlotFrame = null;
         super.release();
      }
   }
}

