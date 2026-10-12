package Widgets.Windows.Promotions
{
   import Classes.Idle.PromoIdleTask;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TPromotion;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class PromoBuyerAbandonmentWindow extends FarmWindow
   {
      
      protected var m_variant:XML;
      
      public function PromoBuyerAbandonmentWindow(userVariant:XML)
      {
         this.m_variant = userVariant;
         super("assets/dialogs/FV_RevAbandon.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         var header:ZwFrame = null;
         var durationFrame:ZwFrame = addWidget(new ZwFrame(m_window.burst_mc),false) as ZwFrame;
         durationFrame.addWidget(new ZwTextField(m_window.burst_mc.generic_tf,ZLocUtils.t("Dialogs","PromoBuyerAbandonment_DurationPart1")));
         durationFrame.addWidget(new ZwTextField(m_window.burst_mc.generic2_tf,FarmGameUtil.toFriendlyTime(Number(PromoIdleTask.activePromoSettings.@promoExpirationTime))));
         durationFrame.addWidget(new ZwTextField(m_window.burst_mc.generic3_tf,ZLocUtils.t("Dialogs","PromoBuyerAbandonment_DurationPart3")));
         var amountTextField:ZwTextField = addWidget(new ZwTextField(m_window.generic_tf,String(this.m_variant.@cashAmount))) as ZwTextField;
         var priceTextField:ZwTextField = addWidget(new ZwTextField(m_window.generic2_tf,ZLocUtils.t("Dialogs","PromoBuyerAbandonment_Price",{"quantity":String(this.m_variant.@cashPrice)}))) as ZwTextField;
         var acceptButton:FarmAnimatedTextButton = addWidget(new FarmAnimatedTextButton(m_window.buy_bt,"",this.onAccept)) as FarmAnimatedTextButton;
         switch(int(this.m_variant.@variantNum))
         {
            case 1:
               durationFrame.visible = false;
               header = addWidget(new ZwFrame(m_window.headerVar1_mc)) as ZwFrame;
               header.addWidget(new ZwTextField(m_window.headerVar1_mc.generic_tf,ZLocUtils.t("Dialogs","PromoBuyerAbandonment_SubHeadingCash")));
               acceptButton.text = ZLocUtils.t("Dialogs","PromoBuyerAbandonment_LearnMoreButton");
               FarmStatsManager.count("rev_abandonment","great_value_promo","great_value_promo","dialogue_impressions");
               break;
            case 2:
               durationFrame.visible = true;
               header = addWidget(new ZwFrame(m_window.headerVar2_mc)) as ZwFrame;
               header.addWidget(new ZwTextField(m_window.headerVar2_mc.generic_tf,ZLocUtils.t("Dialogs","PromoBuyerAbandonment_SubHeadingAllPackages")));
               acceptButton.text = ZLocUtils.t("Dialogs","PromoBuyerAbandonment_BuyNowButton");
               FarmStatsManager.count("rev_abandonment","great_value_promo","fifty_percent_off_promo","dialogue_impressions");
         }
      }
      
      private function onAccept(event:Event) : void
      {
         TransactionManager.addTransaction(new TPromotion(true),true);
         switch(int(this.m_variant.@variantNum))
         {
            case 1:
               FarmStatsManager.count("rev_abandonment","great_value_promo","great_value_promo","click_learn_more");
               break;
            case 2:
               FarmStatsManager.count("rev_abandonment","great_value_promo","fifty_percent_off_promo","click_learn_more");
         }
         super.close();
      }
      
      override public function close() : void
      {
         TransactionManager.addTransaction(new TPromotion(false),true);
         super.close();
      }
   }
}

