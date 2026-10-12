package Widgets.Windows.Market
{
   import Classes.StarterPack.StarterPack;
   import Classes.StarterPack.StarterPackUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Events.CloseEvent;
   import Managers.PackPurchaseManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   
   public class MarketBuyStarterPackWindow extends FarmWindow
   {
      
      private static const STARTER_PACK_DIALOG_ASSET_URL:String = "assets/dialogs/FV_starterpack.swf";
      
      private static const ICON_SIZE_LARGE:int = 75;
      
      private static const ICON_SIZE_SMALL:int = 60;
      
      private static const MAX_ICONS_DISPLAY:int = 5;
      
      protected var m_item:FarmItem = null;
      
      private var m_starterPack:StarterPack = null;
      
      private var m_acceptCallback:Function;
      
      private var m_cancelCallback:Function;
      
      private var m_buyButton:FarmAnimatedTextButton = null;
      
      private var m_marketWindow:MarketWindow = null;
      
      private var m_refreshMarketWindow:Boolean = false;
      
      private var m_paymentRef:String = "";
      
      public function MarketBuyStarterPackWindow(item:FarmItem, acceptCallback:Function, cancelCallback:Function, marketWindow:MarketWindow, packToUse:StarterPack = null, paymentRef:String = "starterpack_inGame")
      {
         this.m_item = item;
         this.m_acceptCallback = acceptCallback;
         this.m_cancelCallback = cancelCallback;
         this.m_paymentRef = paymentRef;
         this.m_marketWindow = marketWindow;
         if(packToUse)
         {
            this.m_starterPack = packToUse;
         }
         else
         {
            this.m_starterPack = StarterPackUtility.getBestVisibleStarterPack();
         }
         if(this.m_starterPack)
         {
            PackPurchaseManager.getInstance().trackPack(this.m_starterPack.name);
         }
         super(STARTER_PACK_DIALOG_ASSET_URL,true,true);
      }
      
      private static function onMarketClose(event:Event) : void
      {
         if(PackPurchaseManager.getInstance().shouldShowPackPurchasesToaster())
         {
            PackPurchaseManager.getInstance().showPackPurchasesToaster();
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var packGifts:Array = null;
         var giftIndex:Number = NaN;
         var gift:Object = null;
         var giftIconURL:String = null;
         var giftQuantity:Number = NaN;
         var visualIndex:int = 0;
         var iconSlot:FarmIcon = null;
         var txtSlot:ZwTextField = null;
         super.postLoadComplete();
         m_window.mainWindow.visible = true;
         if(this.m_starterPack)
         {
            addWidget(new ZwTextField(m_window.mainWindow.wasvalue_tf,ZLocUtils.t("Dialogs","StarterPack_Popup_Value",{"value":this.m_starterPack.value})));
            addWidget(new ZwTextField(m_window.mainWindow.nowonly_tf,ZLocUtils.t("Dialogs","StarterPack_Popup_Cost",{"cost":this.m_starterPack.cost})));
            packGifts = this.m_starterPack.gifts;
            packGifts.sort(StarterPackUtility.starterPackItemSort);
            giftIndex = 0;
            giftIndex = 0;
            while(giftIndex < packGifts.length && giftIndex < MAX_ICONS_DISPLAY)
            {
               gift = packGifts[giftIndex];
               if(gift)
               {
                  giftIconURL = StarterPackUtility.getStarterPackIcon(gift);
                  giftQuantity = StarterPackUtility.getStarterPackQuantity(gift);
                  if(giftIconURL != "")
                  {
                     visualIndex = giftIndex + 1;
                     iconSlot = new FarmIcon(m_window.mainWindow["slot" + visualIndex + "_mc"],giftIconURL);
                     addWidget(iconSlot,true);
                     txtSlot = new ZwTextField(m_window.mainWindow["slot" + visualIndex + "_tf"],giftQuantity.toString());
                     addWidget(txtSlot,true);
                     if(giftQuantity > 1)
                     {
                        iconSlot.setIconSize(ICON_SIZE_SMALL,ICON_SIZE_SMALL);
                     }
                     else
                     {
                        iconSlot.setIconSize(ICON_SIZE_LARGE,ICON_SIZE_LARGE);
                        txtSlot.visible = false;
                     }
                  }
               }
               giftIndex++;
            }
         }
         addWidget(new ZwTextField(m_window.mainWindow.title_tf,ZLocUtils.tk_pk_asTitle(this.m_item.friendlyName)));
         addWidget(new ZwTextField(m_window.mainWindow.popupdetails_tf,ZLocUtils.t("Dialogs","StarterPack_Popup_Description")));
         this.m_buyButton = new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,ZLocUtils.t("Dialogs","MarketCardBuyButton"),this.onBuyButtonClick);
         addWidget(this.m_buyButton);
         m_window.mainWindow.close_bt.addEventListener(MouseEvent.CLICK,this.onClose);
      }
      
      private function onBuyButtonClick(event:Event) : void
      {
         this.m_refreshMarketWindow = true;
         if(this.m_acceptCallback != null)
         {
            this.m_acceptCallback(this.m_item);
         }
         var fullPurchaseCode:String = StarterPackUtility.STARTERPACK_PURCHASE_CATEGORY + ":" + this.m_starterPack.purchaseCode;
         if(ExternalInterface.available)
         {
            ExternalInterface.call("newInGameStarterPackPayment",Global.getPlayer().uid,fullPurchaseCode,this.m_paymentRef);
         }
         this.m_buyButton.enabled = false;
         this.m_buyButton.applyGrayOut = true;
      }
      
      override protected function onClose(event:Event) : void
      {
         m_window.mainWindow.visible = false;
         PackPurchaseManager.getInstance().trackPack();
         if(Boolean(this.m_marketWindow) && this.m_refreshMarketWindow)
         {
            this.m_refreshMarketWindow = false;
            this.m_marketWindow.refreshMarketWindow();
            this.m_marketWindow.addEventListener(CloseEvent.CLOSE,onMarketClose);
         }
         if(this.m_cancelCallback != null)
         {
            this.m_cancelCallback(this.m_item);
         }
         super.onClose(event);
      }
      
      override protected function release() : void
      {
         this.m_refreshMarketWindow = false;
         this.m_item = null;
         this.m_marketWindow = null;
         this.m_starterPack = null;
         this.m_acceptCallback = null;
         this.m_cancelCallback = null;
         super.release();
      }
   }
}

