package Widgets.Windows
{
   import Classes.Constants.Experiments;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.util.PaymentUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.InGamePaymentsManager;
   import Transactions.TRefreshBalance;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class BuyMoneyWindow extends FarmWindowWithTutorial
   {
      
      private static const DEFAULT_BUTTON_MAPPING:Array = [0,2,4];
      
      private static const BDDD_TUTORIAL_FEATURE_NAME:String = "buy_dialog_daily_drip_tutorial";
      
      protected static const BDDD_VARIANT_ON:int = 3;
      
      protected static const BDDD_FULL_BURST_UI_VARIANT_ON:int = 2;
      
      protected var m_dialogAsset:String = "";
      
      protected var m_buttonPaymentMapping:Array;
      
      protected var m_featureName:String;
      
      protected var m_attemptedPurchaseAmount:int = 0;
      
      private var m_socialProofSuccessfullyShown:Boolean = false;
      
      protected var m_attemptedSpend:int;
      
      public function BuyMoneyWindow(featureName:String = "payment_interstitial", dialogAsset:String = "assets/dialogs/FV_Payment_dialog.swf", buttonPaymentMapping:Array = null, attemptedSpend:int = -1)
      {
         this.m_featureName = featureName;
         this.m_attemptedSpend = attemptedSpend;
         if(buttonPaymentMapping)
         {
            this.m_buttonPaymentMapping = buttonPaymentMapping;
         }
         else
         {
            this.m_buttonPaymentMapping = DEFAULT_BUTTON_MAPPING;
         }
         var tutorialFeatureName:String = "";
         var numTutorialFrames:int = 0;
         if(this.canUseBDDD())
         {
            tutorialFeatureName = BDDD_TUTORIAL_FEATURE_NAME;
            numTutorialFrames = 1;
         }
         else
         {
            tutorialFeatureName = featureName;
         }
         super(tutorialFeatureName,this.m_dialogAsset,numTutorialFrames,true,true);
      }
      
      public static function inBDDDExperiment() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BUYDIALOG_DAILY_DRIP) == BDDD_VARIANT_ON;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.setupHeaders();
         this.setupPaymentButtons();
         this.setupFacepile();
         FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,this.m_featureName,StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM,this.m_socialProofSuccessfullyShown ? StatsTrackingConstants.WITH_FACEPILE_STAT : "",this.m_socialProofSuccessfullyShown ? String(Global.player.numRecentlyPaidFriends) : "");
      }
      
      private function setupFacepile() : void
      {
         var facepileLength:int = 0;
         var i:int = 0;
         var icon:FarmIcon = null;
         var facepileData:Vector.<Object> = Global.player.socialProofFacepileData;
         var numRecentlyPaidFriends:int = Global.player.numRecentlyPaidFriends;
         var expVar:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SOCIAL_PROOF_IMPULSE_BUY);
         var facepileText:String = ZLocUtils.t("Dialogs","socialProofNoFriends");
         if(expVar >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START && expVar < Experiments.SOCIAL_PROOF_EXP_VAR_NO_FACE_PILE_START && facepileData.length > 0)
         {
            facepileLength = int(facepileData.length);
            if(m_window.hasOwnProperty("social_" + (facepileLength - 1) + "_mc") && m_window["social_" + (facepileLength - 1) + "_mc"] != null)
            {
               m_window["social_" + (facepileLength - 1) + "_mc"].visible = true;
               for(i = 0; i < facepileLength; i++)
               {
                  if(Boolean(m_window["social_" + (facepileLength - 1) + "_mc"].hasOwnProperty("face_slot_" + i + "_mc")) && m_window["social_" + (facepileLength - 1) + "_mc"]["face_slot_" + i + "_mc"] != null)
                  {
                     this.m_socialProofSuccessfullyShown = true;
                     icon = new FarmIcon(m_window["social_" + (facepileLength - 1) + "_mc"]["face_slot_" + i + "_mc"],facepileData[i].picUrl);
                     icon.attachTooltip(new FarmTextTooltip(facepileData[i].firstName + " " + facepileData[i].lastName.charAt(0) + "."));
                     addWidget(icon);
                  }
               }
               switch(numRecentlyPaidFriends)
               {
                  case 1:
                     facepileText = ZLocUtils.t("Dialogs","socialProofFacePile0ExtraFriends",{"firstName":facepileData[0].firstName});
                     break;
                  case 2:
                     facepileText = ZLocUtils.t("Dialogs","socialProofFacePile1ExtraFriend",{"firstName":facepileData[0].firstName});
                     break;
                  default:
                     facepileText = ZLocUtils.t("Dialogs","socialProofFacePileMultipleExtraFriends",{
                        "firstName":facepileData[0].firstName,
                        "numExtraFriends":numRecentlyPaidFriends - 1
                     });
               }
               if(facepileText != "")
               {
                  addWidget(new ZwTextField(m_window["social_" + (facepileLength - 1) + "_mc"].header_social_tf,facepileText));
               }
            }
         }
         else
         {
            if(expVar >= Experiments.SOCIAL_PROOF_EXP_VAR_NO_FACE_PILE_START && numRecentlyPaidFriends > 0)
            {
               if(numRecentlyPaidFriends == 1)
               {
                  facepileText = ZLocUtils.t("Dialogs","socialProofNoFacePile1Friend");
               }
               else if(numRecentlyPaidFriends > 1)
               {
                  facepileText = ZLocUtils.t("Dialogs","socialProofNoFacePileMultipleFriends",{"numFriends":numRecentlyPaidFriends});
               }
               this.m_socialProofSuccessfullyShown = true;
            }
            if(facepileText != "" && m_window.hasOwnProperty("generic_4_tf"))
            {
               m_window.generic_4_tf.visible = true;
               addWidget(new ZwTextField(m_window.generic_4_tf,facepileText));
            }
            else
            {
               this.m_socialProofSuccessfullyShown = false;
            }
         }
      }
      
      protected function setupPaymentButtons() : void
      {
         var buttonPaymentMappingLength:int = 0;
         var i:int = 0;
         var packageObj:Object = null;
         var buttonObj:DisplayObject = null;
         var frame:ZwFrame = null;
         var priceSelectBt:FarmAnimatedTextButton = null;
         if(this.m_buttonPaymentMapping)
         {
            buttonPaymentMappingLength = int(this.m_buttonPaymentMapping.length);
            for(i = 0; i < buttonPaymentMappingLength; i++)
            {
               packageObj = InGamePaymentsManager.getPaymentByIndex(this.m_buttonPaymentMapping[i]);
               buttonObj = this.getPaymentButtonObject(i);
               if(Boolean(packageObj) && Boolean(buttonObj))
               {
                  frame = addWidget(new ZwFrame(buttonObj)) as ZwFrame;
                  priceSelectBt = frame.addWidget(new FarmAnimatedTextButton(frame.element["accept_bt"],this.getPaymentButtonText(),this.onClickBuyNow)) as FarmAnimatedTextButton;
                  frame.visible = true;
                  priceSelectBt.id = i.toString();
                  frame.addWidget(new ZwTextField(frame.element.cost_tf,ZLocUtils.t("Dialogs","InGamePaymentsCost",{"quantity":packageObj["cost"]})));
                  frame.addWidget(new ZwTextField(frame.element.fvcash_tf,packageObj["amount"]));
               }
            }
         }
      }
      
      protected function getPaymentButtonObject(index:int) : DisplayObject
      {
         return m_window["pricelist" + index + "_bt"];
      }
      
      protected function getPaymentButtonText() : String
      {
         return ZLocUtils.t("Dialogs","BuyNow");
      }
      
      protected function setupHeaders() : void
      {
         if(m_window.header_tf)
         {
            addWidget(new ZwTextField(m_window.header_tf,ZLocUtils.t("Dialogs","PaymentsPopupTitle")));
         }
         if(m_window.subhead_tf)
         {
            addWidget(new ZwTextField(m_window.subhead_tf,ZLocUtils.t("Dialogs","PaymentsPopupTitleSub")));
         }
         if(m_window.optionshead_tf)
         {
            addWidget(new ZwTextField(m_window.optionshead_tf,ZLocUtils.t("Dialogs","PaymentsPopupOptionsText")));
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,this.m_featureName,StatsTrackingConstants.DIALOG_STATS_X_CLICK_PHYLUM);
         super.onClose(event);
      }
      
      protected function onClickBuyNow(event:Event) : void
      {
         var clickedId:int = 0;
         var packageObj:Object = null;
         var frame:ZwFrame = getWidget(event.currentTarget.parent) as ZwFrame;
         var clicked:FarmAnimatedTextButton = frame.getWidget(event.currentTarget) as FarmAnimatedTextButton;
         if(clicked)
         {
            clickedId = parseInt(clicked.id);
            this.trackButtonClick(clickedId);
            if(Boolean(this.m_buttonPaymentMapping) && this.m_buttonPaymentMapping.length > clickedId)
            {
               packageObj = InGamePaymentsManager.getPaymentByIndex(this.m_buttonPaymentMapping[clickedId]);
               if(packageObj)
               {
                  this.launchBuyCashPrompt(parseInt(packageObj["amount"]));
                  this.m_attemptedPurchaseAmount = parseInt(packageObj["amount"]);
               }
            }
         }
      }
      
      protected function launchBuyCashPrompt(farmCashAmount:int) : void
      {
         PaymentUtil.instance.addCashToCart(farmCashAmount,this.m_featureName,this.onPaymentSuccess,this.onPaymentFailure);
      }
      
      protected function onPaymentSuccess(orderId:String, status:String) : void
      {
         TransactionManager.addTransaction(new TRefreshBalance(),true);
         close();
      }
      
      protected function onPaymentFailure(errorCode:String, errorMessage:String) : void
      {
      }
      
      protected function trackButtonClick(buttonId:int) : void
      {
         FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,this.m_featureName,StatsTrackingConstants.DIALOG_STATS_BUTTON_CLICK_PHYLUM);
      }
      
      protected function canUseBDDD() : Boolean
      {
         return this.m_attemptedSpend == 0 && inBDDDExperiment();
      }
      
      protected function isBDDDFullBurstMode() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_DAILY_DRIP_UI) == BDDD_FULL_BURST_UI_VARIANT_ON;
      }
   }
}

