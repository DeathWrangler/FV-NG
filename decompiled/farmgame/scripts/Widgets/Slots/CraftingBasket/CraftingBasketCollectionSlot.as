package Widgets.Slots.CraftingBasket
{
   import Classes.CraftingBasket;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class CraftingBasketCollectionSlot extends ZwSlotFrame
   {
      
      private static const OFFSET_OPF_Y:int = -20;
      
      private static const ICON_SIZE:int = 100;
      
      private var m_basketName:String;
      
      private var m_data:Object;
      
      private var m_shouldShowCheckMark:Boolean = false;
      
      private var m_shouldShowCommonBg:Boolean = false;
      
      private var m_callbacks:Object;
      
      private var m_countTextField:ZwTextField = null;
      
      private var m_buyButton:FarmAnimatedCashButton = null;
      
      private var m_redeemButton:FarmAnimatedTextButton = null;
      
      private var m_objectPreviewFrame:ObjectPreviewFrame = null;
      
      protected var m_iconPreview:FarmIcon;
      
      private var m_checkMark:ZwWidget;
      
      private var m_rewardBg:ZwWidget;
      
      private var m_commonRewardBg:ZwWidget;
      
      private var infoTooltip:FarmTextTooltip;
      
      public function CraftingBasketCollectionSlot(element:DisplayObject, basketName:String, callbacks:Object)
      {
         super(element);
         this.m_basketName = basketName;
         this.m_callbacks = callbacks;
         addWidget(this.m_buyButton = new FarmAnimatedCashButton(m_element.buy_bt,ZLocUtils.t("Dialogs",this.m_basketName + "_buy"),"",this.onBuyItem),true);
         addWidget(this.m_redeemButton = new FarmAnimatedTextButton(m_element.redeem_bt,ZLocUtils.t("Dialogs",this.m_basketName + "_redeem"),this.onRedeemItem),true);
         addWidget(this.m_countTextField = new ZwTextField(m_element.count_tf,""),true);
         if(m_element.hasOwnProperty("checkmark_mc"))
         {
            addWidget(this.m_checkMark = new ZwWidget(m_element.checkmark_mc),this.m_shouldShowCheckMark);
         }
         if(m_element.hasOwnProperty("glowbg_mc"))
         {
            addWidget(this.m_commonRewardBg = new ZwWidget(m_element.glowbg_mc),this.m_shouldShowCommonBg);
         }
         if(m_element.hasOwnProperty("slotbg_mc"))
         {
            addWidget(this.m_rewardBg = new ZwWidget(m_element.slotbg_mc),true);
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data["itemData"];
         this.m_shouldShowCheckMark = data["checkMarkVisible"];
         this.m_shouldShowCommonBg = data["showCommonBg"];
         this.m_buyButton.visible = data["canBuyItem"];
         this.m_redeemButton.visible = true;
         this.m_countTextField.visible = true;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.name);
         this.m_buyButton.setAmountText(item.cash.toString());
         if(this.m_objectPreviewFrame != null)
         {
            removeWidget(this.m_objectPreviewFrame);
            this.m_objectPreviewFrame = null;
         }
         if(this.m_iconPreview)
         {
            this.m_iconPreview.clearDimensions();
            removeWidget(this.m_iconPreview);
            this.m_iconPreview = null;
         }
         if(this.m_checkMark)
         {
            this.m_checkMark.visible = this.m_shouldShowCheckMark;
         }
         if(this.m_commonRewardBg)
         {
            this.m_commonRewardBg.visible = this.m_shouldShowCommonBg;
         }
         if(this.m_rewardBg)
         {
            this.m_rewardBg.visible = true;
         }
         var itemName:String = ZLocUtils.tk_pk_asTitle(item.friendlyName);
         this.infoTooltip = new FarmTextTooltip(ZLocUtils.t("Dialogs",this.m_basketName + "_iconTooltip",{
            "quantity":this.m_data.exchangeQty,
            "itemName":itemName
         }));
         if(m_element.hasOwnProperty("objectPreviewFrame_mc") && (item.getImageByName("frt_idle") != null || item.getImageByName("bare") != null || item.getImageByName("static") != null))
         {
            this.m_objectPreviewFrame = new ObjectPreviewFrame(m_element.objectPreviewFrame_mc,item,null,[item.sizeX == 1 ? 2 : 1.75],null,"","",null,new Point(0,OFFSET_OPF_Y));
            (this.m_objectPreviewFrame.element as MovieClip).filters = [];
            addWidget(this.m_objectPreviewFrame,true);
            this.m_objectPreviewFrame.attachTooltip(this.infoTooltip);
         }
         else if(m_element.hasOwnProperty("icon_mc"))
         {
            this.m_iconPreview = new FarmIcon(m_element.icon_mc,item.icon);
            this.m_iconPreview.setIconSize(ICON_SIZE,ICON_SIZE);
            addWidget(this.m_iconPreview,true);
            this.m_iconPreview.attachTooltip(this.infoTooltip);
         }
         this.m_countTextField.text = this.m_data.exchangeQty;
         this.toggleRedeemVisible(data["toggleRedeemVisible"]);
         if(!this.m_redeemButton.enabled)
         {
            this.m_redeemButton.callback = null;
            this.m_redeemButton.detachTooltip();
            this.m_redeemButton.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs",this.m_basketName + "_iconTooltip",{
               "quantity":this.m_data.exchangeQty,
               "itemName":itemName
            })));
            this.m_redeemButton.element.mouseEnabled = this.m_redeemButton.element.mouseChildren = true;
         }
         else
         {
            this.m_redeemButton.detachTooltip();
         }
      }
      
      override public function release() : void
      {
         if(this.m_objectPreviewFrame)
         {
            this.m_objectPreviewFrame.detachTooltip();
            this.m_objectPreviewFrame = null;
         }
         if(this.m_iconPreview)
         {
            this.m_iconPreview.detachTooltip();
            this.m_iconPreview = null;
         }
         if(this.m_checkMark)
         {
            this.m_checkMark = null;
         }
         this.m_countTextField = null;
         this.m_buyButton = null;
         this.m_redeemButton = null;
         super.release();
      }
      
      private function onBuyItem(event:Event) : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.name);
         UI.displayMessage(ZLocUtils.t("Dialogs",this.m_basketName + "BuyConfirmPopup",{
            "cashQuantity":item.cash,
            "item":item.friendlyTitle
         }),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmBuyItemPopupClose,"",true);
      }
      
      private function onConfirmBuyItemPopupClose(event:GenericPopupEvent) : void
      {
         var callback:Function = null;
         if(event.button == GenericPopup.YES)
         {
            callback = this.m_callbacks[CraftingBasket.BUY_ITEM];
            callback(this.m_data.name);
         }
      }
      
      private function onRedeemItem(event:Event) : void
      {
         var callback:Function = this.m_callbacks[CraftingBasket.REDEEM_ITEM];
         callback(this.m_data.name);
      }
      
      public function toggleRedeemVisible(visible:Boolean) : void
      {
         if(visible)
         {
            this.m_redeemButton.enabled = true;
            this.m_redeemButton.applyGrayOut = false;
         }
         else
         {
            this.m_redeemButton.enabled = false;
            this.m_redeemButton.applyGrayOut = true;
         }
      }
   }
}

