package Widgets.Windows
{
   import Classes.Constants.Experiments;
   import Classes.FeatureComponents.IngameSurveyManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.HolidayCountdownManager;
   import Managers.TemplateUIUtility;
   import Transactions.THolidayCountdownCompleteNow;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedIconButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.CountdownObjectPreviewFrame;
   import Widgets.Frames.CountdownSlotFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class CountdownWindow extends FarmWindow
   {
      
      private static const SURVEY_ICON_URL:String = "assets/dialogs/4d_elements/surveys/surveyIcon.swf";
      
      private var m_dialog:CountdownSlotFrame = null;
      
      private var m_featureName:String = null;
      
      private var m_surveyButton:FarmAnimatedIconButton = null;
      
      private var inRepeatabilityExperiment:Boolean = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_REPEATABLE_COUNTDOWN) == Experiments.VARIANT_FLASH_REPEATABLE_COUNTDOWN_ON;
      
      private var inIngameSurveyExperiment:Boolean = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_INGAME_SURVEYS) == Experiments.VARIANT_FLASH_INGAME_SURVEYS_ON;
      
      public function CountdownWindow(assetUrl:String, featureName:String)
      {
         super(assetUrl);
         this.m_featureName = featureName;
      }
      
      override protected function postLoadComplete() : void
      {
         var titleWidget:ZwTextField = null;
         var descriptionWidget:ZwTextField = null;
         var bonusItem:FarmItem = null;
         var timerWidget:ZwTextField = null;
         var tempFarmItem:FarmItem = null;
         var igsManager:IngameSurveyManager = null;
         var numActionCount:int = 0;
         super.postLoadComplete();
         if(Boolean(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.COUNTDOWN)) && Boolean(m_window) && Boolean(m_window["loader_mc"]))
         {
            addWidget(new FarmIcon(m_window.loader_mc,Global.getAssetURL(HolidayCountdownManager.dialogBackground)));
         }
         if(m_window.title_tf != null)
         {
            titleWidget = addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("HolidayCountdown",HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdownTitle"),{"countdownName":ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdownTitle"))}))) as ZwTextField;
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.COUNTDOWN) && Boolean(titleWidget))
            {
               TemplateUIUtility.applyDropShadowFilter(titleWidget,TemplateUIUtility.COUNTDOWN,HolidayCountdownManager.textColor);
               TemplateUIUtility.applyTextScaling(titleWidget,TemplateUIUtility.COUNTDOWN);
            }
         }
         if(m_window.description_tf != null)
         {
            descriptionWidget = null;
            if(HolidayCountdownManager.restartCount() > 0)
            {
               bonusItem = HolidayCountdownManager.getBonusItem();
               descriptionWidget = addWidget(new ZwTextField(m_window.description_tf,ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("Replay_Header"),{"item":bonusItem.friendlyTitle}))) as ZwTextField;
            }
            else
            {
               descriptionWidget = addWidget(new ZwTextField(m_window.description_tf,ZLocUtils.t("HolidayCountdown",HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdownHeader"),{"countdownName":ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdownTitle"))}))) as ZwTextField;
            }
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.COUNTDOWN) && Boolean(descriptionWidget))
            {
               TemplateUIUtility.applyTextColor(descriptionWidget,TemplateUIUtility.COUNTDOWN,HolidayCountdownManager.textColor);
            }
         }
         if(m_window.complete_tf != null)
         {
            addWidget(new ZwTextField(m_window.complete_tf,ZLocUtils.t("HolidayCountdown",HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdownCollectAll"),{"countdownName":ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdownTitle"))})));
         }
         if(m_window.complete_bt != null)
         {
            addWidget(new FarmAnimatedCashButton(m_window.complete_bt));
         }
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.COUNTDOWN) && Boolean(m_window["timer_tf"]))
         {
            timerWidget = addWidget(new ZwTextField(m_window.timer_tf,"Ask every 6 Hours!")) as ZwTextField;
            TemplateUIUtility.applyTextColor(timerWidget,TemplateUIUtility.COUNTDOWN,HolidayCountdownManager.textColor);
         }
         else if(m_window.timer_mc != null)
         {
            addWidget(new ZwWidget(m_window.timer_mc));
         }
         if(m_window.presents_mc != null)
         {
            addWidget(new ZwWidget(m_window.presents_mc));
            if(m_window.presents_mc.gift_mc != null)
            {
               addWidget(new ZwWidget(m_window.presents_mc.gift_mc));
            }
            if(m_window.presents_mc.reward_mc != null && m_window.presents_mc.reward_mc.icon_mc != null)
            {
               addWidget(new ZwWidget(m_window.presents_mc.reward_mc));
               addWidget(new FarmIcon(m_window.presents_mc.reward_mc.icon_mc));
            }
            this.showGift();
         }
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.COUNTDOWN) && Boolean(m_window["prizeLoader_mc"]))
         {
            tempFarmItem = HolidayCountdownManager.getBonusItem();
            if(tempFarmItem)
            {
               addWidget(new CountdownObjectPreviewFrame(m_window.prizeLoader_mc,tempFarmItem));
            }
         }
         if(m_window.complete_bt != null)
         {
            this.completeNowOrBonusBuy();
         }
         if(Boolean(!TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.COUNTDOWN)) && Boolean(m_window["hdtwFrame_mc"]) && HolidayCountdownManager.shouldShowWhatIsThis() != -1)
         {
            addWidget(new ZwWidget(m_window.hdtwFrame_mc));
            if(m_window.hdtwFrame_mc.hdtw_title_tf != null)
            {
               addWidget(new ZwTextField(m_window.hdtwFrame_mc.hdtw_title_tf,ZLocUtils.t("HolidayCountdown",HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdownHDTWTitle"),{"countdownName":ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdownTitle"))})));
            }
            if(m_window.hdtwFrame_mc.hdtw_description_tf != null)
            {
               addWidget(new ZwTextField(m_window.hdtwFrame_mc.hdtw_description_tf,ZLocUtils.t("HolidayCountdown",HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdownHDTWDescription"),{"countdownName":ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("HolidayCountdownTitle"))})));
            }
            if(m_window.hdtwFrame_mc.hdtwClose_bt != null)
            {
               addWidget(new FarmButton(m_window.hdtwFrame_mc.hdtwClose_bt,this.hDTWClose));
            }
            this.howDoesThisWorkSetup(m_window.hdtwFrame_mc);
         }
         if(m_window.survey_mc != null && this.inIngameSurveyExperiment)
         {
            igsManager = IngameSurveyManager.instanceForFeature(this.m_featureName);
            if(igsManager != null && igsManager.answeredFlag == false)
            {
               Global.player.incrementActionCount("ingameSurvey_" + this.m_featureName);
               igsManager.callback = this.onSurveyComplete;
               numActionCount = Global.player.getActionCount("ingameSurvey_" + this.m_featureName);
               if(numActionCount == 3)
               {
                  this.m_surveyButton = addWidget(new FarmAnimatedIconButton(m_window.survey_mc,SURVEY_ICON_URL,this.onSurveyIconClick,true,this.onSurveyIconLoadComplete)) as FarmAnimatedIconButton;
               }
               else if(numActionCount > 3)
               {
                  this.m_surveyButton = addWidget(new FarmAnimatedIconButton(m_window.survey_mc,SURVEY_ICON_URL,this.onSurveyIconClick,true)) as FarmAnimatedIconButton;
               }
            }
         }
         if(m_window.replayCounter_mc != null && this.inRepeatabilityExperiment)
         {
            addWidget(new ZwWidget(m_window.replayCounter_mc));
            if(m_window.replayCounter_mc.itemAmount_tf != null)
            {
               addWidget(new ZwTextField(m_window.replayCounter_mc.itemAmount_tf,"x" + HolidayCountdownManager.restartCount().toString()));
            }
         }
         this.m_dialog = new CountdownSlotFrame(m_window.slotFrame_mc,this);
         this.m_dialog.setItemData();
         addWidget(this.m_dialog);
         if(HolidayCountdownManager.canRestartCountdown())
         {
            UI.displayPopup(new CountdownReplayPopup(HolidayCountdownManager.replaySwf),false);
         }
      }
      
      private function showGift() : void
      {
         var allAcq:Boolean = false;
         var giftClip:ZwWidget = null;
         var rewardClip:ZwWidget = null;
         var iconBox:FarmIcon = null;
         var bonusItem:FarmItem = null;
         if(m_window.presents_mc != null)
         {
            allAcq = HolidayCountdownManager.hasAcquiredAllItems();
            if(ObjectUtil.pathExists(m_window,["presents_mc","gift_mc"]))
            {
               giftClip = getWidget(m_window.presents_mc.gift_mc) as ZwWidget;
               if(allAcq)
               {
                  giftClip.visible = false;
               }
               else
               {
                  giftClip.visible = true;
               }
            }
            if(ObjectUtil.pathExists(m_window,["presents_mc","reward_mc","icon_mc"]))
            {
               rewardClip = getWidget(m_window.presents_mc.reward_mc) as ZwWidget;
               iconBox = getWidget(m_window.presents_mc.reward_mc.icon_mc) as FarmIcon;
               if(!allAcq)
               {
                  rewardClip.visible = false;
                  iconBox.visible = false;
               }
               else
               {
                  bonusItem = HolidayCountdownManager.getBonusItem();
                  rewardClip.visible = true;
                  if(bonusItem != null)
                  {
                     iconBox.loadIcon(bonusItem.icon);
                     iconBox.visible = true;
                     iconBox.setIconSize(75,75);
                  }
               }
            }
         }
      }
      
      private function completeNowOrBonusBuy() : void
      {
         var allAcq:Boolean = HolidayCountdownManager.hasAcquiredAllItems();
         var completeButton:FarmAnimatedCashButton = getWidget(m_window.complete_bt) as FarmAnimatedCashButton;
         if(allAcq)
         {
            completeButton.setAmountText(String(HolidayCountdownManager.bonusItemCost()));
            if(completeButton.text != null)
            {
               completeButton.text = ZLocUtils.t("HolidayCountdown","HolidayCountdownBuyMore");
            }
            completeButton.callback = this.onBonusBuyCallback;
            completeButton.showPaymentConfirmation = true;
         }
         else
         {
            completeButton.setAmountText(String(HolidayCountdownManager.getCompleteNowPrice()));
            if(completeButton.text != null)
            {
               completeButton.text = ZLocUtils.t("HolidayCountdown","HolidayCountdownCompleteNowButtonText");
            }
            completeButton.callback = this.onCompleteNowCallback;
            completeButton.showPaymentConfirmation = false;
         }
      }
      
      protected function howDoesThisWorkSetup(element:DisplayObject) : void
      {
         var slotString:String = null;
         var nextSlotString:String = null;
         var slotImage:FarmIcon = null;
         var slot:int = 0;
         while(element["hdtw_slot_" + slot.toString()])
         {
            slotString = slot.toString();
            nextSlotString = (slot + 1).toString();
            addWidget(new ZwTextField(element["hdtw_slot_" + slotString]["description_tf_" + slotString],ZLocUtils.t("HolidayCountdown","HolidayCountdownHDTWDescription" + nextSlotString)));
            addWidget(new ZwTextField(element["hdtw_slot_" + slotString]["step_tf_" + slotString],ZLocUtils.t("HolidayCountdown","HolidayCountdownHDTWStep",{"step":nextSlotString})));
            slotImage = addWidget(new FarmIcon(element["hdtw_slot_" + slot.toString()]["imageplaceholder_mc_" + slot.toString()])) as FarmIcon;
            slotImage.loadIcon(HolidayCountdownManager.getHDTWImage(slot + 1));
            slotImage.visible = true;
            slot++;
         }
         HolidayCountdownManager.setSeenWhatIsThis(HolidayCountdownManager.shouldShowWhatIsThis() + 1);
      }
      
      protected function hDTWClose(event:Event) : void
      {
         getWidget(m_window.hdtwFrame_mc).visible = false;
      }
      
      private function onCompleteNowCallback(event:Event) : void
      {
         var popup:GenericPopup = new GenericPopup(ZLocUtils.t("Dialogs","CompleteNowPopup"),GenericPopup.TYPE_ACCEPTCANCEL,this.completeNowAccept);
         UI.displayPopup(popup,false);
         HolidayCountdownManager.interactedWithDialog();
      }
      
      private function completeNowAccept(event:GenericPopupEvent) : void
      {
         var completeNowPrice:int = 0;
         if(event.button == GenericPopup.ACCEPT)
         {
            completeNowPrice = HolidayCountdownManager.getCompleteNowPrice();
            if(Global.player.canBuyCash(completeNowPrice))
            {
               Global.player.cash -= completeNowPrice;
               HolidayCountdownManager.acquiredAllItems = true;
               HolidayCountdownManager.unlockAllIndices();
               HolidayCountdownManager.refreshDialog();
               HolidayCountdownManager.showShareBonusDialog();
               TransactionManager.addTransaction(new THolidayCountdownCompleteNow(completeNowPrice));
            }
         }
      }
      
      private function onBonusBuyCallback(event:Event) : void
      {
         var bonusPrice:int = parseInt(HolidayCountdownManager.bonusItemCost());
         if(Global.player.canBuyCash(bonusPrice))
         {
            HolidayCountdownManager.buyBonusItem();
         }
         HolidayCountdownManager.interactedWithDialog();
      }
      
      private function onSurveyIconClick(event:Event) : void
      {
         var igsManager:IngameSurveyManager = IngameSurveyManager.instanceForFeature(this.m_featureName);
         igsManager.display();
      }
      
      private function onSurveyComplete() : void
      {
         if(this.m_surveyButton != null)
         {
            removeWidget(this.m_surveyButton);
            this.m_surveyButton = null;
         }
      }
      
      private function onSurveyIconLoadComplete() : void
      {
         var igs_icon_mc:MovieClip = null;
         var surveyIcon:MovieClip = null;
         if(Boolean(this.m_surveyButton) && Boolean(this.m_surveyButton.farmIcon) && Boolean(this.m_surveyButton.farmIcon.element))
         {
            igs_icon_mc = this.m_surveyButton.farmIcon.element as MovieClip;
            if(igs_icon_mc.numChildren > 0 && Boolean(igs_icon_mc.getChildAt(0)))
            {
               surveyIcon = igs_icon_mc.getChildAt(0) as MovieClip;
               surveyIcon.gotoAndPlay(2);
            }
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         HolidayCountdownManager.dialogClosed();
         super.onClose(event);
      }
      
      override public function refreshWindow() : void
      {
         var window:DisplayObject = null;
         if(m_window == null)
         {
            window = UI.getCurrentPopup();
            if(window is CountdownWindow)
            {
               (window as CountdownWindow).refreshWindow();
            }
         }
         else
         {
            this.m_dialog.refresh();
            this.showGift();
            if(m_window.complete_bt != null)
            {
               this.completeNowOrBonusBuy();
            }
            if(m_window.replayCounter_mc != null && this.inRepeatabilityExperiment)
            {
               if(m_window.replayCounter_mc.itemAmount_tf != null)
               {
                  this.m_window.replayCounter_mc.itemAmount_tf.text = "x" + HolidayCountdownManager.restartCount();
               }
            }
         }
      }
   }
}

