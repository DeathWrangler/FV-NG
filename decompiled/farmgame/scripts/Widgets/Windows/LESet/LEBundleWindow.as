package Widgets.Windows.LESet
{
   import Classes.LESaleBundle;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.LEBundleManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.LESet.LEBundleSlotFrame;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class LEBundleWindow extends FarmWindow
   {
      
      public static const SINGLE_ASSET_URL:String = "assets/dialogs/FV_LE_single.swf";
      
      public static const MULTIPLE_ASSET_URL:String = "assets/dialogs/FV_LE_multiple.swf";
      
      public static const BUNDLE_ASSET_URL:String = "assets/dialogs/FV_LE_collection.swf";
      
      private var m_frame:LEBundleSlotFrame;
      
      private var m_leSaleBundle:LESaleBundle;
      
      private var m_saleBundleViewType:String;
      
      private var m_buyAllButton:FarmAnimatedTextButton;
      
      public function LEBundleWindow(leSaleBundle:LESaleBundle)
      {
         var overrideViewValue:String = null;
         var displayArray:Array = null;
         var dialogURL:String = "";
         this.m_leSaleBundle = leSaleBundle;
         if(this.m_leSaleBundle)
         {
            overrideViewValue = Global.player.getItemFlag(LEBundleManager.OVERRIDE_SALE_BUNDLE_VIEW_TYPE_FLAG);
            if(overrideViewValue)
            {
               this.m_saleBundleViewType = overrideViewValue;
            }
            else
            {
               displayArray = null;
               switch(this.m_leSaleBundle.targetCustomer)
               {
                  case "casual":
                     displayArray = new Array(LEBundleManager.SINGLE_SALE_VIEW_TYPE,LEBundleManager.MULTIPLE_SALE_VIEW_TYPE);
                     this.m_saleBundleViewType = displayArray[Math.floor(Math.random() * displayArray.length)];
                     break;
                  case "collector":
                     displayArray = new Array(LEBundleManager.SINGLE_SALE_VIEW_TYPE,LEBundleManager.MULTIPLE_SALE_VIEW_TYPE,LEBundleManager.BUNDLE_SALE_VIEW_TYPE);
                     this.m_saleBundleViewType = displayArray[Math.floor(Math.random() * displayArray.length)];
                     break;
                  case "master":
                     this.m_saleBundleViewType = LEBundleManager.BUNDLE_SALE_VIEW_TYPE;
               }
            }
            switch(this.m_saleBundleViewType)
            {
               case LEBundleManager.SINGLE_SALE_VIEW_TYPE:
                  dialogURL = LEBundleWindow.SINGLE_ASSET_URL;
                  break;
               case LEBundleManager.MULTIPLE_SALE_VIEW_TYPE:
                  dialogURL = LEBundleWindow.MULTIPLE_ASSET_URL;
                  break;
               case LEBundleManager.BUNDLE_SALE_VIEW_TYPE:
                  dialogURL = LEBundleWindow.BUNDLE_ASSET_URL;
            }
         }
         super(dialogURL);
      }
      
      override protected function postLoadComplete() : void
      {
         var elementCheck:Boolean = false;
         this.m_frame = new LEBundleSlotFrame(m_window.slotFrame_mc,this.m_leSaleBundle.saleObjects,this);
         addWidget(this.m_frame);
         if(!this.slotsHaveDescription())
         {
            elementCheck = Boolean(m_window) && Boolean(m_window.headline_mc) && Boolean(m_window.headline_mc.popup_mc) && Boolean(m_window.headline_mc.popup_mc.popupBox_tf);
            if(elementCheck)
            {
               addWidget(new ZwTextField(m_window.headline_mc.popup_mc.popupBox_tf,this.getSaleBundleDescription()));
            }
         }
         if(!this.slotsHaveBuyButtons())
         {
            elementCheck = Boolean(m_window) && Boolean(m_window.buy_bt) && Boolean(m_window.buy_bt.farmCash_tf);
            if(elementCheck)
            {
               addWidget(this.m_buyAllButton = new FarmAnimatedTextButton(m_window.buy_bt,ZLocUtils.t("Dialogs","Buy"),this.onBuyAllCallback));
               addWidget(new ZwTextField(m_window.buy_bt.farmCash_tf,this.m_leSaleBundle.getBundleSalePrice().toString()));
               this.m_buyAllButton.visible = true;
            }
         }
         this.trackLEBundleStat("view");
      }
      
      override protected function onClose(event:Event) : void
      {
         this.trackLEBundleStat("click_cancel");
         this.m_leSaleBundle.declineBundlePurchase();
         super.onClose(event);
      }
      
      protected function onBuyAllCallback(event:Event) : void
      {
         var confirmationText:String = null;
         var buyPrice:int = this.m_leSaleBundle.getBundleSalePrice();
         if(buyPrice >= FarmAnimatedCashButton.DEFAULT_PAYMENT_CONFIRMATION_MINIMUM)
         {
            confirmationText = ZLocUtils.t("Dialogs","FarmCashBuyConfirmation",{"price":buyPrice});
            UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptUnlockConfirmation,"leBundleConfirmation",true,true);
         }
         else
         {
            this.buyAll();
         }
      }
      
      private function buyAll() : void
      {
         if(Global.player.canBuyCash(this.m_leSaleBundle.getBundleSalePrice()))
         {
            this.m_leSaleBundle.attemptFullBundlePurchase();
            this.trackLEBundleStat("click_buy_all");
            this.close();
         }
      }
      
      private function onAcceptUnlockConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.buyAll();
         }
      }
      
      public function get saleBundle() : LESaleBundle
      {
         return this.m_leSaleBundle;
      }
      
      public function get saleBundleViewType() : String
      {
         return this.m_saleBundleViewType;
      }
      
      public function slotsHaveBuyButtons() : Boolean
      {
         return this.m_saleBundleViewType != LEBundleManager.BUNDLE_SALE_VIEW_TYPE;
      }
      
      public function slotsHaveDescription() : Boolean
      {
         return this.m_saleBundleViewType == LEBundleManager.MULTIPLE_SALE_VIEW_TYPE;
      }
      
      public function getSaleBundleDescription() : String
      {
         var description:String = "";
         var discount:int = 0;
         if(this.m_leSaleBundle)
         {
            discount = this.m_leSaleBundle.discount;
         }
         if(this.m_saleBundleViewType != LEBundleManager.BUNDLE_SALE_VIEW_TYPE)
         {
            description = ZLocUtils.t("Dialogs","LESaleBundle_Description",{"discount":discount});
         }
         else
         {
            description = ZLocUtils.t("Dialogs","LESaleBundle_Description_Short",{"discount":discount});
         }
         return description;
      }
      
      public function trackLEBundleStat(variablePhylum:String) : void
      {
         FarmStatsManager.count("le_bundle_promo",this.getStatKingdom(),variablePhylum,this.m_leSaleBundle.targetCustomer);
      }
      
      private function getStatKingdom() : String
      {
         var kingdom:String = "";
         var numSlots:Number = 0;
         if(this.m_frame)
         {
            numSlots = this.m_frame.totalSlots();
         }
         switch(this.m_saleBundleViewType)
         {
            case LEBundleManager.SINGLE_SALE_VIEW_TYPE:
            case LEBundleManager.MULTIPLE_SALE_VIEW_TYPE:
               kingdom = "upsell_" + numSlots;
               break;
            case LEBundleManager.BUNDLE_SALE_VIEW_TYPE:
               kingdom = "bundle_" + numSlots;
         }
         return kingdom;
      }
   }
}

