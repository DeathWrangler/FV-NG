package Widgets.Slots
{
   import Classes.Animal;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class ItemPurchaseSlot extends ZwSlotFrame
   {
      
      private static const PREVIEW_SIZE:int = 100;
      
      protected static const PRICE_CONFIRMATION_THRESHOLD:int = 10;
      
      protected var m_objectPreviewFrame:ObjectPreviewFrame;
      
      protected var m_iconPreview:FarmIcon;
      
      protected var m_farmItem:FarmItem;
      
      protected var m_itemName:ZwTextField;
      
      protected var m_price:ZwTextField;
      
      protected var m_buyButton:FarmAnimatedCashButton;
      
      protected var m_parentWindow:FarmWindow;
      
      protected var m_slotFrameIndex:int = -1;
      
      public function ItemPurchaseSlot(element:DisplayObject, parentWindow:FarmWindow)
      {
         super(element);
         this.m_parentWindow = parentWindow;
      }
      
      protected function getItemPrice() : int
      {
         var returnVal:int = 0;
         if(this.m_farmItem)
         {
            returnVal = this.m_farmItem.cash;
         }
         return returnVal;
      }
      
      protected function setupPrice() : void
      {
         if(Boolean(m_element) && Boolean(m_element.price_tf))
         {
            if(this.m_price)
            {
               removeWidget(this.m_price);
               this.m_price = null;
            }
            addWidget(this.m_price = new ZwTextField(m_element.price_tf,this.getItemPrice().toString()));
            this.m_price.visible = true;
         }
      }
      
      protected function setupBuyButton() : void
      {
         if(Boolean(m_element) && Boolean(m_element.buy_bt))
         {
            if(this.m_buyButton)
            {
               removeWidget(this.m_buyButton);
               this.m_buyButton = null;
            }
            addWidget(this.m_buyButton = new FarmAnimatedCashButton(m_element.buy_bt,ZLocUtils.t("Dialogs","Buy"),this.getItemPrice().toString(),this.onBuyCallback,false,false,true));
            this.m_buyButton.visible = true;
         }
      }
      
      protected function setupPreview() : void
      {
         var sizeScale:Number = NaN;
         if(this.m_itemName)
         {
            removeWidget(this.m_itemName);
            this.m_itemName = null;
         }
         addWidget(this.m_itemName = new ZwTextField(m_element.name_tf,this.m_farmItem.friendlyTitle));
         this.m_itemName.visible = true;
         if(this.m_objectPreviewFrame != null)
         {
            removeWidget(this.m_objectPreviewFrame);
            this.m_objectPreviewFrame = null;
         }
         if(this.m_iconPreview != null)
         {
            removeWidget(this.m_iconPreview);
            this.m_iconPreview = null;
         }
         if(m_element.hasOwnProperty("icon_mc") && this.m_farmItem.getImageByName("frt_idle") != null)
         {
            sizeScale = Math.min(2,7 / (this.m_farmItem.sizeX + this.m_farmItem.sizeY) / this.m_farmItem.imageScale);
            this.m_objectPreviewFrame = new ObjectPreviewFrame(m_element.icon_mc,this.m_farmItem,null,[sizeScale],null,Animal.STATE_FRONT_IDLE);
            (this.m_objectPreviewFrame.element as MovieClip).filters = [];
            addWidget(this.m_objectPreviewFrame,true);
         }
         else if(m_element.hasOwnProperty("staticPreview_mc"))
         {
            this.m_iconPreview = new FarmIcon(m_element.staticPreview_mc,this.m_farmItem.icon);
            this.m_iconPreview.setIconSize(this.previewSize(),this.previewSize());
            addWidget(this.m_iconPreview,true);
         }
         else if(m_element.hasOwnProperty("icon_mc"))
         {
            this.m_iconPreview = new FarmIcon(m_element.icon_mc,this.m_farmItem.icon);
            this.m_iconPreview.setIconSize(this.previewSize(),this.previewSize());
            addWidget(this.m_iconPreview,true);
         }
      }
      
      override public function populate(data:Object) : void
      {
         this.m_farmItem = data as FarmItem;
         this.setupPreview();
         this.setupBuyButton();
         this.setupPrice();
      }
      
      override public function release() : void
      {
         super.release();
         this.m_objectPreviewFrame = null;
      }
      
      protected function onBuyCallback(event:Event) : void
      {
         if(Global.player.canBuyCash(this.getItemPrice()))
         {
            this.m_farmItem.onBuy(this.m_farmItem.name);
         }
      }
      
      protected function previewSize() : int
      {
         return PREVIEW_SIZE;
      }
   }
}

