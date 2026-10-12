package Widgets.Windows.AvatarEditor
{
   import Classes.Avatar.AvatarItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.ImpulseBuy;
   import Display.UI;
   import Events.ImpulseBuyEvent;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.AvatarEditor.AvatarPriceTagFrame;
   import Widgets.Frames.AvatarEditor.AvatarReceiptSlotFrame;
   import Widgets.Windows.FarmWindow;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class AvatarEditorWaitWindow extends FarmWindow
   {
      
      private const SNAPSHOT_CENTER_X:Number = 134;
      
      private const SNAPSHOT_CENTER_Y:Number = 164;
      
      private var m_snapshot:Bitmap;
      
      private var m_items:Array;
      
      private var m_buyNowCallback:Function;
      
      private var m_cancelCallback:Function;
      
      private var m_buyNowButton:FarmAnimatedTextButton;
      
      private var m_cancelButton:FarmAnimatedTextButton;
      
      private var m_priceFrame:AvatarPriceTagFrame;
      
      private var m_receiptSlotFrame:AvatarReceiptSlotFrame;
      
      private var m_impulseBuyDialog:ImpulseBuy;
      
      public function AvatarEditorWaitWindow(snapshot:Bitmap, items:Array, buyNowCallback:Function, cancelCallback:Function)
      {
         super("assets/dialogs/FV_AvatarEditor_Wait.swf");
         this.m_snapshot = snapshot;
         this.m_items = items;
         this.m_buyNowCallback = buyNowCallback;
         this.m_cancelCallback = cancelCallback;
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","AvatarEditorWaitWindow_Title")));
         addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.t("Dialogs","AvatarEditorWaitWindow_Message"))) as ZwTextField;
         this.m_buyNowButton = addWidget(new FarmAnimatedTextButton(m_window.buyNow_bt,ZLocUtils.t("Dialogs","AvatarEditorWindow_BuyNowButton"),this.onBuyNowButtonClick)) as FarmAnimatedTextButton;
         this.m_cancelButton = addWidget(new FarmAnimatedTextButton(m_window.cancel_bt,ZLocUtils.t("Dialogs","AvatarEditorWindow_CancelButton"),this.onCancelButtonClick)) as FarmAnimatedTextButton;
         this.m_priceFrame = addWidget(new AvatarPriceTagFrame(m_window.priceTag_mc)) as AvatarPriceTagFrame;
         (this.m_priceFrame.element as MovieClip).addEventListener(MouseEvent.MOUSE_OVER,this.onPriceFrameMouseOver,false,0,true);
         (this.m_priceFrame.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onPriceFrameMouseOut,false,0,true);
         this.m_receiptSlotFrame = addWidget(new AvatarReceiptSlotFrame(m_window.frame_reciept_mc),false) as AvatarReceiptSlotFrame;
         if(this.m_snapshot != null)
         {
            m_window.addChildAt(this.m_snapshot,m_window.getChildIndex(m_window.frame_reciept_mc));
            this.m_snapshot.x = this.SNAPSHOT_CENTER_X - Math.round(this.m_snapshot.width / 2);
            this.m_snapshot.y = this.SNAPSHOT_CENTER_Y - Math.round(this.m_snapshot.height / 2);
         }
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
         this.m_receiptSlotFrame.items = this.m_items;
      }
      
      private function onBuyNowButtonClick(evt:MouseEvent) : void
      {
         var cashTotal:int = 0;
         var coinTotal:int = 0;
         var item:AvatarItem = null;
         var currency:String = null;
         if(this.m_items != null)
         {
            cashTotal = 0;
            coinTotal = 0;
            for each(item in this.m_items)
            {
               currency = item.market;
               switch(currency)
               {
                  case Currency.CASH:
                     cashTotal += item.cost;
                     break;
                  case Currency.COINS:
                     coinTotal += item.cost;
               }
            }
            if(cashTotal > 0)
            {
               if(!Global.player.canBuyCash(cashTotal,false))
               {
                  this.m_impulseBuyDialog = UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",0,"avatar_cash_buy");
               }
            }
            else if(coinTotal > 0)
            {
               if(!Global.player.canBuy(coinTotal,false))
               {
                  this.m_impulseBuyDialog = UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_COINS,"impulseBuyPopup",0,"avatar_coin_buy");
               }
            }
            if(this.m_impulseBuyDialog)
            {
               this.m_impulseBuyDialog.addEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
               enableInput = false;
            }
            else
            {
               if(this.m_buyNowCallback != null)
               {
                  this.m_buyNowCallback();
               }
               close();
            }
         }
      }
      
      private function onCancelButtonClick(evt:MouseEvent) : void
      {
         if(this.m_cancelCallback != null)
         {
            this.m_cancelCallback();
         }
         close();
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
      
      private function onImpulseBuyCancel(event:ImpulseBuyEvent) : void
      {
         enableInput = true;
         if(this.m_impulseBuyDialog)
         {
            this.m_impulseBuyDialog.removeEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
            this.m_impulseBuyDialog = null;
         }
      }
      
      override protected function release() : void
      {
         this.m_snapshot = null;
         this.m_items = null;
         this.m_buyNowCallback = null;
         this.m_cancelCallback = null;
         this.m_buyNowButton = null;
         this.m_cancelButton = null;
         (this.m_priceFrame.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OVER,this.onPriceFrameMouseOver);
         (this.m_priceFrame.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OUT,this.onPriceFrameMouseOut);
         this.m_priceFrame = null;
         this.m_receiptSlotFrame = null;
         super.release();
      }
   }
}

