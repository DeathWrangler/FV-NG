package Widgets.Windows
{
   import Classes.Constants.Experiments;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.Constants.ToasterIconPaths;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.ToasterManager;
   import Transactions.TSetFeatureFrequencyWithBackoff;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class LowCashBuyMoneyWindow extends BuyMoneyWindow
   {
      
      private static const PACKAGE_MAPPING_VARIANT_3:Array = [3,2,1];
      
      private static const INTERSTITIAL_PACKAGE_VARIANT:Array = [2,1,0];
      
      private static const GOLD_VARIANT_INDEX:int = 1;
      
      private static const LOW_CASH_FEATURE_NAME:String = "low_fc_prompt";
      
      private static const LOW_CASH_FF_VIEWED:String = "low_cash_prompt_viewed";
      
      private static const LOW_CASH_RUNTIME_PREREQ:String = "LOWFCPROMPT_TRIGGER_PREREQ";
      
      private static const LOW_CASH_RUNTIME_MAX_BACKOFF_INCREMENTS:String = "LOWFCPROMPT_MAXBACKOFF_WEEKS";
      
      private var buttonDescriptors:Array = ["low","medium","high"];
      
      public function LowCashBuyMoneyWindow(featureName:String = null, fromInterstitial:Boolean = false)
      {
         var buttonPaymentMapping:Array = PACKAGE_MAPPING_VARIANT_3;
         if(featureName == null)
         {
            featureName = LOW_CASH_FEATURE_NAME;
         }
         if(fromInterstitial)
         {
            buttonPaymentMapping = INTERSTITIAL_PACKAGE_VARIANT;
         }
         var result:Boolean = Boolean(Global.flashHotParams["SHOW_FC_POPUP"]);
         if(result)
         {
            super(featureName,"assets/dialogs/FV_lowfarmcash_social.swf",buttonPaymentMapping);
         }
      }
      
      public static function shouldShowPopup() : Boolean
      {
         var runtimePrereq:Object = null;
         var result:Boolean = false;
         if(GlobalEngine.serverTime > Global.player.getFeatureLastShown(LOW_CASH_FF_VIEWED))
         {
            runtimePrereq = Global.farmGameSettingsManager.getPrereqByName(Global.flashHotParams[LOW_CASH_RUNTIME_PREREQ]);
            if(Boolean(runtimePrereq) && PrerequisiteUtility.isPrerequisiteMet(runtimePrereq))
            {
               result = true;
            }
         }
         return false;
      }
      
      public static function showStatic() : void
      {
      }
      
      override protected function setupHeaders() : void
      {
         if(m_window.header_tf)
         {
            addWidget(new ZwTextField(m_window.header_tf,ZLocUtils.t("Dialogs","LowCashPopupTitle")));
         }
      }
      
      override protected function getPaymentButtonObject(index:int) : DisplayObject
      {
         var nameModifier:String = index == GOLD_VARIANT_INDEX ? "gold" : "blue";
         return m_window["pricelist" + nameModifier + index + "_bt"];
      }
      
      override protected function getPaymentButtonText() : String
      {
         return ZLocUtils.t("Dialogs","Buy");
      }
      
      override protected function trackButtonClick(buttonId:int) : void
      {
         var readableButtonId:int = buttonId + 1;
         FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,m_featureName,StatsTrackingConstants.DIALOG_STATS_BUTTON_CLICK_PHYLUM + "pkg_" + readableButtonId);
         var expVar:Boolean = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SOCIAL_PROOF_IMPULSE_BUY) > 1;
         FarmStatsManager.count("payment","in_app","low_fc_prompt",this.buttonDescriptors[buttonId],expVar ? StatsTrackingConstants.WITH_FACEPILE_STAT : "",expVar ? String(Global.player.numRecentlyPaidFriends) : "");
      }
      
      override protected function onPaymentSuccess(orderId:String, status:String) : void
      {
         super.onPaymentSuccess(orderId,status);
         UI.displayMarketDialog(m_featureName,"special");
         ToasterManager.getInstance().add(new IconToasterWindow(ToasterIconPaths.CASH_MINI_ICON,ZLocUtils.t("Dialogs","LowCashPopupToaster")));
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         TransactionManager.addTransaction(new TSetFeatureFrequencyWithBackoff(LOW_CASH_FF_VIEWED,Global.flashHotParams[LOW_CASH_RUNTIME_MAX_BACKOFF_INCREMENTS]));
      }
   }
}

