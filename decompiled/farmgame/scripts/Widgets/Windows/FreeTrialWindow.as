package Widgets.Windows
{
   import Classes.Constants.ToasterIconPaths;
   import Classes.FreeTrialMapTrigger;
   import Classes.util.PaymentUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.ToasterManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class FreeTrialWindow extends FarmWindow
   {
      
      private static const SWF_URL:String = "assets/dialogs/FV_freeTrial_pop.swf";
      
      private static const ZPAYMENTS_REF:String = "free_trial";
      
      public static const PAID_PACK_ITEM_CODE:String = "1rW";
      
      public static const PACK_FC_AMOUNT:int = 15;
      
      private var m_paid:Boolean = false;
      
      private var m_statsKingdom:String = "";
      
      public function FreeTrialWindow(paid:Boolean = false)
      {
         super(SWF_URL);
         this.m_paid = paid;
         this.m_statsKingdom = this.m_paid ? FreeTrialMapTrigger.FREE_TRIAL_PURCHASE_KINGDOM : FreeTrialMapTrigger.FREE_TRIAL_ANNOUNCE_KINGDOM;
         FarmStatsManager.count(FreeTrialMapTrigger.FREE_TRIAL_STATS_COUNTER,this.m_statsKingdom,"dialog_view");
         FarmStatsManager.count("payment","in_app","free_trial","","view");
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(!this.m_paid)
         {
            m_closeButton.visible = false;
         }
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwWidget(m_window.buttons_mc));
         var subheaderText:String = "";
         var buttonText:String = "";
         if(this.m_paid)
         {
            addWidget(new ZwWidget(m_window.headline1_mc));
            subheaderText = ZLocUtils.t("Dialogs","freeTrialSubtitleExpired");
            buttonText = ZLocUtils.t("Dialogs","BuyNow");
         }
         else
         {
            addWidget(new ZwWidget(m_window.headline0_mc));
            subheaderText = ZLocUtils.t("Dialogs","freeTrialSubtitleFree");
            buttonText = ZLocUtils.t("Dialogs","CheckGiftBox");
         }
         addWidget(new ZwTextField(m_window.subheader_tf,subheaderText));
         addWidget(new FarmAnimatedTextButton(m_window.accept_bt,buttonText,this.onAccept));
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         FarmStatsManager.count(FreeTrialMapTrigger.FREE_TRIAL_STATS_COUNTER,this.m_statsKingdom,"button_x");
      }
      
      private function onAccept(event:Event) : void
      {
         if(this.m_paid)
         {
            PaymentUtil.instance.addToCart(PAID_PACK_ITEM_CODE,1,ZPAYMENTS_REF,this.onPaymentSuccess,this.onPaymentFailure);
            FarmStatsManager.count("payment","in_app","free_trial","","click");
         }
         else
         {
            UI.displayGiftBoxWindow();
         }
         close();
         FarmStatsManager.count(FreeTrialMapTrigger.FREE_TRIAL_STATS_COUNTER,this.m_statsKingdom,"button_buy");
      }
      
      private function onPaymentSuccess(orderId:String, status:String) : void
      {
         FarmStatsManager.count(FreeTrialMapTrigger.FREE_TRIAL_STATS_COUNTER,this.m_statsKingdom,"purchased");
         FarmStatsManager.count("payment","in_app","free_trial","",PAID_PACK_ITEM_CODE,Global.worldManager.currentWorldType,PACK_FC_AMOUNT);
         Global.player.addGift(Global.farmGameSettingsManager.getFarmItemNameByCode(PAID_PACK_ITEM_CODE));
         Global.player.cash += PACK_FC_AMOUNT;
         ToasterManager.getInstance().add(new IconTitleToasterWindow(ZLocUtils.t("Dialogs","CongratsShort"),ZLocUtils.t("Dialogs","ConsumablesBought_Title"),ToasterIconPaths.GIFT_ICON,"assets/dialogs/FV_Craft_BannerAd.swf",0.6,new Point(14,11),null));
      }
      
      private function onPaymentFailure(errorCode:String, errorMessage:String) : void
      {
         FarmStatsManager.count(FreeTrialMapTrigger.FREE_TRIAL_STATS_COUNTER,this.m_statsKingdom,"paymentFailure",errorCode,errorMessage);
      }
   }
}

