package Widgets.Windows.MOTD
{
   import Classes.Constants.Experiments;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.Subscriptions.SubscriptionsTutorialWindow;
   import flash.events.Event;
   
   public class SubscriptionsMOTDWindow extends CustomWindowMOTDBase
   {
      
      private static const SUBSCRIPTION_FC_TRIAL:int = 2;
      
      private static const SUBSCRIPTION_COINS_TRIAL:int = 10000;
      
      private static const MAX_FC_AMOUNT:int = 120;
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_Subscriptions_MOTD.swf";
      
      private static const MONTLY_SUBSCRIPTION_FEE:int = 10;
      
      private static const STATS_COUNTER:String = "subs_coins_cash";
      
      private static const STATS_KINGDOM:String = "MOTD";
      
      private var m_whatIsThisPanel:ZwFrame;
      
      public function SubscriptionsMOTDWindow()
      {
         super(ASSET_PATH);
      }
      
      public static function canTrade() : Boolean
      {
         var inExperiment:Boolean = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_COINS_SUBSCRIPTIONS) == 3;
         var inMOTDExperiment:Boolean = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_COINS_SUBSCRIPTIONS_MOTD) == 1;
         var tradedTrial:Boolean = Global.player.getSeenFlag("subscriptions_tradedMOTD");
         var enoughCoins:Boolean = Global.player.gold >= SUBSCRIPTION_COINS_TRIAL;
         return inExperiment && inMOTDExperiment && enoughCoins && !tradedTrial;
      }
      
      override protected function postLoadComplete() : void
      {
         var signupFrame:ZwFrame = null;
         super.postLoadComplete();
         if(!SubscriptionsMOTDWindow.canTrade())
         {
            FarmStatsManager.count(STATS_COUNTER,STATS_KINGDOM,"view_teaser");
            signupFrame = new ZwFrame(m_window.slotFrame2_mc);
            addWidget(signupFrame);
            signupFrame.addWidget(new ZwTextField(m_window.slotFrame2_mc.generic1_tf,ZLocUtils.t("Dialogs","Subscriptions_MOTD_Inactive_Title")));
            signupFrame.addWidget(new ZwTextField(m_window.slotFrame2_mc.generic2_tf,MAX_FC_AMOUNT.toString()));
            signupFrame.addWidget(new ZwTextField(m_window.slotFrame2_mc.generic3_tf,ZLocUtils.t("Dialogs","Subscriptions_MOTD_Inactive_EveryMonth")));
            addWidget(new FarmAnimatedTextButton(m_window.slotFrame2_mc.signUp_bt,ZLocUtils.t("Dialogs","Subscriptions_MOTD_Inactive_Signup"),this.onSignUpNow));
            addWidget(new ZwTextField(m_window.slotFrame2_mc.signUp_bt.generic1_tf,MONTLY_SUBSCRIPTION_FEE.toString()));
            addWidget(new ZwTextField(m_window.slotFrame2_mc.signUp_bt.generic2_tf,ZLocUtils.t("Dialogs","Subscriptions_Currency_USD")));
            addWidget(new ZwTextField(m_window.slotFrame2_mc.signUp_bt.generic3_tf,ZLocUtils.t("Dialogs","Subscriptions_MOTD_Inactive_PerMonth")));
         }
         else
         {
            FarmStatsManager.count(STATS_COUNTER,STATS_KINGDOM,"view_static");
            addWidget(new ZwFrame(m_window.slotFrame1_mc));
            addWidget(new ZwTextField(m_window.slotFrame1_mc.generic1_tf,ZLocUtils.t("Dialogs","Subscriptions_MOTD_Active_Title")));
            addWidget(new ZwTextField(m_window.slotFrame1_mc.generic2_tf,ZLocUtils.t("Dialogs","Subscriptions_MOTD_Active_TradeCoins",{"coins":SUBSCRIPTION_COINS_TRIAL})));
            addWidget(new ZwTextField(m_window.slotFrame1_mc.generic3_tf,ZLocUtils.t("Dialogs","Subscriptions_MOTD_Active_For")));
            addWidget(new ZwTextField(m_window.slotFrame1_mc.generic4_tf,ZLocUtils.t("Dialogs","Subscriptions_MOTD_Active_TradeCash",{"cash":SUBSCRIPTION_FC_TRIAL})));
            addWidget(new FarmAnimatedTextButton(m_window.slotFrame1_mc.trade_bt,ZLocUtils.t("Dialogs","Subscriptions_Slot_TradeNow"),this.onTradeTrial));
         }
         if(m_window.hasOwnProperty("whatisthis_mc"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,"",this.howDoesThisWorkClick));
         }
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         UI.displayPopup(new SubscriptionsTutorialWindow(),false,"SubscriptionsTutorialWindow",true);
      }
      
      private function onSignUpNow(event:Event) : void
      {
         FarmStatsManager.count(STATS_COUNTER,STATS_KINGDOM,"sign_up");
      }
      
      private function onTradeTrial(event:Event) : void
      {
         FarmStatsManager.count(STATS_COUNTER,STATS_KINGDOM,"convert_free");
         Global.player.cash += SUBSCRIPTION_FC_TRIAL;
         Global.player.gold -= SUBSCRIPTION_COINS_TRIAL;
         var tradeTransaction:TGenericTransaction = new TGenericTransaction("SubscriptionsService","motdTrial",null,null);
         TransactionManager.addTransaction(tradeTransaction,true);
         Global.player.setSeenFlag("subscriptions_tradedMOTD",false,true);
         close();
         this.showConfirmationDialog();
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count(STATS_COUNTER,STATS_KINGDOM,"close");
         super.onClose(event);
      }
      
      private function showConfirmationDialog() : void
      {
         var message:String = ZLocUtils.t("Dialogs","Subscriptions_MOTD_Congrats");
         UI.displayMessage(message,GenericPopup.TYPE_OK,this.showInfoView,"Subscription_MOTD_Congrats",true,true);
      }
      
      private function showInfoView(event:Event) : void
      {
         var dialog:SubscriptionsMOTDWindow = new SubscriptionsMOTDWindow();
         UI.displayPopup(dialog,true,"SubscriptionsWindow",true);
      }
   }
}

