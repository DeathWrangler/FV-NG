package Display
{
   import Classes.util.ZLocUtils;
   import Events.ImpulseBuyEvent;
   import Managers.FarmStatsManager;
   import flash.events.MouseEvent;
   
   public class ImpulseBuy extends Dialog
   {
      
      public static const TYPE_FUEL:String = "out_of_fuel";
      
      public static const TYPE_COINS:String = "need_coins";
      
      public static const TYPE_CASH:String = "need_cash";
      
      public static const TYPE_MARKET_COINS:String = "market_coins";
      
      public static const TYPE_MARKET_CASH:String = "market_cash";
      
      public static const OUT_OF_CASH:String = "out_of_cash";
      
      public static const OUT_OF_COINS:String = "out_of_coins";
      
      private var m_accept:GenericButton;
      
      private var m_reject:GenericButton;
      
      private var m_type:String;
      
      private var m_attemptedPurchaseName:String;
      
      public function ImpulseBuy(type:String, attemptedPurchaseName:String = "Other")
      {
         m_dialogAsset = "assets/dialogs/FV_ImpulseBuy_alt.swf";
         super();
         this.m_type = type;
         this.m_attemptedPurchaseName = attemptedPurchaseName;
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         this.initDialog();
         this.m_accept = new GenericButton(m_window.popupBox_mc.accept_bt,this.onAccept);
         this.m_accept.text = ZLocUtils.t("Dialogs","ImpulseYes");
         this.m_reject = new GenericButton(m_window.popupBox_mc.cancel_bt,this.onCancel);
         this.m_reject.text = ZLocUtils.t("Dialogs","ImpulseNo");
      }
      
      private function initDialog() : void
      {
         m_window.popupBox_mc.notEnough_tf.text = ZLocUtils.t("Dialogs","ImpulseNotEnough");
         m_window.popupBox_mc.fuel_mc.visible = false;
         m_window.popupBox_mc.cash_mc.visible = false;
         m_window.popupBox_mc.coin_mc.visible = false;
         switch(this.m_type)
         {
            case ImpulseBuy.TYPE_FUEL:
               m_window.popupBox_mc.fuel_mc.visible = true;
               m_window.popupBox_mc.popupBox_tf.text = ZLocUtils.t("Dialogs","ImpulseFuel");
               break;
            case ImpulseBuy.TYPE_COINS:
               m_window.popupBox_mc.coin_mc.visible = true;
               m_window.popupBox_mc.popupBox_tf.text = ZLocUtils.t("Dialogs","ImpulseCoins");
               FarmStatsManager.count("dialog","old_out_of_coins","view",this.m_attemptedPurchaseName,"ingame_purchase");
               break;
            case ImpulseBuy.TYPE_CASH:
               m_window.popupBox_mc.cash_mc.visible = true;
               m_window.popupBox_mc.popupBox_tf.text = ZLocUtils.t("Dialogs","ImpulseCash");
               FarmStatsManager.count("dialog","old_out_of_cash","view",this.m_attemptedPurchaseName,"ingame_purchase");
               break;
            case ImpulseBuy.TYPE_MARKET_COINS:
               m_window.popupBox_mc.coin_mc.visible = true;
               m_window.popupBox_mc.popupBox_tf.text = ZLocUtils.t("Dialogs","ImpulseMarketCoins");
               FarmStatsManager.count("dialog","old_out_of_coins","view",this.m_attemptedPurchaseName,"market_purchase");
               break;
            case ImpulseBuy.TYPE_MARKET_CASH:
               m_window.popupBox_mc.cash_mc.visible = true;
               m_window.popupBox_mc.popupBox_tf.text = ZLocUtils.t("Dialogs","ImpulseMarketCash");
               FarmStatsManager.count("dialog","old_out_of_cash","view",this.m_attemptedPurchaseName,"market_purchase");
         }
      }
      
      protected function onAccept(event:MouseEvent) : void
      {
         event.stopPropagation();
         close();
         switch(this.m_type)
         {
            case ImpulseBuy.TYPE_FUEL:
               UI.displayMarketDialog("impulse_fuel","aide",null,"fuel");
               break;
            case ImpulseBuy.TYPE_COINS:
               this.showInGamePayment("money.php?ref=" + OUT_OF_COINS + "&affiliate=" + this.m_attemptedPurchaseName + "&buttonInteraction=button_buy","add_money_ingame_coins");
               break;
            case ImpulseBuy.TYPE_CASH:
               this.showInGamePayment("money.php?ref=" + OUT_OF_CASH + "&affiliate=" + this.m_attemptedPurchaseName + "&buttonInteraction=button_buy","add_money_ingame_cash");
               break;
            case ImpulseBuy.TYPE_MARKET_COINS:
               this.showInGamePayment("money.php?ref=" + OUT_OF_COINS + "&affiliate=" + this.m_attemptedPurchaseName + "&buttonInteraction=button_buy","add_money_market_coins");
               break;
            case ImpulseBuy.TYPE_MARKET_CASH:
               this.showInGamePayment("money.php?ref=" + OUT_OF_CASH + "&affiliate=" + this.m_attemptedPurchaseName + "&buttonInteraction=button_buy","add_money_market_cash");
         }
         dispatchEvent(new ImpulseBuyEvent(ImpulseBuyEvent.ACCEPT));
      }
      
      protected function showInGamePayment(url:String, subCounter:String) : void
      {
      }
      
      protected function onCancel(event:MouseEvent) : void
      {
         event.stopPropagation();
         switch(this.m_type)
         {
            case ImpulseBuy.TYPE_COINS:
               FarmStatsManager.count("dialog","old_out_of_coins","button_x",this.m_attemptedPurchaseName,"add_money_ingame_coins");
               break;
            case ImpulseBuy.TYPE_CASH:
               FarmStatsManager.count("dialog","old_out_of_cash","button_x",this.m_attemptedPurchaseName,"add_money_ingame_cash");
               break;
            case ImpulseBuy.TYPE_MARKET_COINS:
               FarmStatsManager.count("dialog","old_out_of_coins","button_x",this.m_attemptedPurchaseName,"add_money_market_coins");
               break;
            case ImpulseBuy.TYPE_MARKET_CASH:
               FarmStatsManager.count("dialog","old_out_of_cash","button_x",this.m_attemptedPurchaseName,"add_money_market_cash");
         }
         dispatchEvent(new ImpulseBuyEvent(ImpulseBuyEvent.CANCEL));
         close();
      }
   }
}

