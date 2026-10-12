package Display.Party
{
   import Classes.FeatureDataObjects.FeatureFriendSet;
   import Classes.FeatureDataObjects.FriendSet;
   import Classes.FeatureDataObjects.PartyDataObject;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.GenericDialog;
   import Display.FarmDynamicDialog;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.PartyManager;
   import Transactions.TCompleteFriendSet;
   import Transactions.TFriendSetCompleteSeen;
   import com.troyer.widget.controller.BaseWidgetController;
   import com.troyer.widget.controller.ButtonController;
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.controller.ProgressBarController;
   import com.troyer.widget.controller.TooltipController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   
   public class TeaPartyDialog extends PartyDialog
   {
      
      public static const FRIEND_SET_CODE:String = "FS03";
      
      public static const STATS_COUNTER_NAME:String = "bonvoyage";
      
      private static const WHAT_IS_THIS_LOC_RESOURCE:String = "teaParty_whatIsThis";
      
      private static const DUKE_CIRCLE_ASSET:String = "assets/dialogs/4d_elements/Questing/NPC_circle_duke_standard.png";
      
      private static const FIRST_TIME_TEA_PARTY_SEEN_FLAG:String = "seenTeaParty";
      
      private var m_confirmBuyAll:GenericDialog = null;
      
      public function TeaPartyDialog(view:BaseWidgetView)
      {
         super(view);
         this.m_friendSetCode = FRIEND_SET_CODE;
      }
      
      override protected function setupWindow() : void
      {
         var xml:XML = Global.farmGameSettingsManager.getFriendSetXMLByCode(m_friendSetCode);
         m_cashAmountToSkip = parseInt(xml.buyAllCash[0].toString());
         var partyDataObj:PartyDataObject = PartyManager.getInstance().getPartyObjectByCode(m_friendSetCode);
         var friendSet:FriendSet = partyDataObj.friendSet;
         if(friendSet.pendingFriends.length > 0)
         {
            friendSet.markSeen();
            PartyManager.getInstance().fadeOutAllPartyAvatars(m_friendSetCode,false,false);
         }
         if(Global.player.getSeenFlag(FIRST_TIME_TEA_PARTY_SEEN_FLAG) == false)
         {
            FeatureFriendSet(friendSet).startFriendSetTimer();
         }
         this.setShortcutAttribute("InviteButton",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","TeaPartyInviteMore"));
         this.setShortcutListener("InviteButton",WidgetControllerEvent.BUTTON_PRESSED,this.onInvite);
         this.setShortcutAttribute("topInfoBuyButtonText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","TeaPartyUnlockForText"));
         this.setShortcutAttribute("topInfoBuyButtonCostText",TextFieldView.ATTRIBUTE_TEXT,m_cashAmountToSkip.toString());
         this.setShortcutListener("topInfoBuyButton",WidgetControllerEvent.BUTTON_PRESSED,this.onBuyAll);
         this.setShortcutListener("finishButton",WidgetControllerEvent.BUTTON_PRESSED,this.onFinishParty);
         this.setShortcutAttribute("finishButton",ButtonController.ATTRIBUTE_TEXT,ZLocUtils.t("FarmGame","FarmTravel_england_teaParty"));
         this.setShortcutAttribute("whatIsThisText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","WhatIsThis"));
         this.setShortcutListener("whatIsThisButton",WidgetControllerEvent.BUTTON_PRESSED,this.onWhatIsThis);
         this.m_partyDataObj = PartyManager.getInstance().getPartyObjectByCode(m_friendSetCode);
         this.setupHeader();
         setupGuestInfo();
         this.setupProgressMeter();
         this.setupTooltips();
         this.m_isSetup = true;
      }
      
      override public function show(addToQueue:Boolean = false, popupName:String = "", checkDuplicates:Boolean = false) : void
      {
         if(this.m_isSetup)
         {
            FarmStatsManager.count(TeaPartyDialog.STATS_COUNTER_NAME,"dialog","dialog_view");
            super.show(addToQueue);
            if(Global.player.getSeenFlag(FIRST_TIME_TEA_PARTY_SEEN_FLAG) == false)
            {
               this.onWhatIsThis(null);
               Global.player.setSeenFlag(FIRST_TIME_TEA_PARTY_SEEN_FLAG);
            }
         }
      }
      
      private function setupHeader() : void
      {
         var days:int = 0;
         var hours:int = 0;
         var mins:int = 0;
         var secondsToCompleteLevel:Number = this.m_partyDataObj.goal.secondsToCompleteLevel;
         var view:BaseWidgetView = null;
         if(!this.m_partyDataObj.goal.isStarted() && this.m_partyDataObj.goal.currentLevel < 1)
         {
            this.setShortcutAttribute("notReadyText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","TeaPartyNotReady"));
            view = this.getShortcutController("coundDown").getView();
         }
         else if(this.m_partyDataObj.goal.isCompleted())
         {
            this.toggleVisibleAndObstruct("countDownHeader",false);
            this.toggleVisibleAndObstruct("finishedHeader",true);
         }
         else
         {
            this.toggleVisibleAndObstruct("countDownHeader",true);
            this.toggleVisibleAndObstruct("finishedHeader",false);
            days = secondsToCompleteLevel / FarmGameUtil.NUM_SECS_IN_DAY;
            secondsToCompleteLevel -= days * FarmGameUtil.NUM_SECS_IN_DAY;
            hours = secondsToCompleteLevel / FarmGameUtil.NUM_SECS_IN_HOUR;
            secondsToCompleteLevel -= hours * FarmGameUtil.NUM_SECS_IN_HOUR;
            mins = secondsToCompleteLevel / FarmGameUtil.NUM_SECS_IN_MINUTE;
            this.setupCountDownClock(days,hours,mins);
            view = this.getShortcutController("notReadyText").getView();
         }
         if(view)
         {
            view.setAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT,false);
            view.setAttribute(BaseWidgetView.ATTRIBUTE_VISIBLE,false);
         }
      }
      
      private function setupCountDownClock(days:int, hours:int, mins:int) : void
      {
         var countDownGroup:BaseWidgetController = null;
         var countDownClock:BaseWidgetController = this.getShortcutController("countDownClock");
         if(countDownClock != null)
         {
            countDownGroup = null;
            countDownGroup = countDownClock.getChildController("day");
            if(countDownGroup != null)
            {
               this.setupCountDownGroup(days,ZLocUtils.t("Dialogs","Days").toLocaleUpperCase(),countDownGroup);
            }
            countDownGroup = countDownClock.getChildController("hour");
            if(countDownGroup != null)
            {
               this.setupCountDownGroup(hours,ZLocUtils.t("Dialogs","Hours").toLocaleUpperCase(),countDownGroup);
            }
            countDownGroup = countDownClock.getChildController("min");
            if(countDownGroup != null)
            {
               this.setupCountDownGroup(mins,ZLocUtils.t("Dialogs","Mins").toLocaleUpperCase(),countDownGroup);
            }
         }
      }
      
      private function setupCountDownGroup(time:int, label:String, group:BaseWidgetController) : void
      {
         var timeStr:String = time.toString();
         var digit1:String = null;
         var digit2:String = null;
         if(timeStr.length < 2)
         {
            digit1 = "0";
            digit2 = timeStr.charAt(0);
         }
         else
         {
            digit1 = timeStr.charAt(0);
            digit2 = timeStr.charAt(1);
         }
         group.getChildController("body.leftText.text").setAttribute(TextFieldView.ATTRIBUTE_TEXT,digit1);
         group.getChildController("body.rightText.text").setAttribute(TextFieldView.ATTRIBUTE_TEXT,digit2);
         group.getChildController("magnitudeText").setAttribute(TextFieldView.ATTRIBUTE_TEXT,label);
      }
      
      private function setupProgressMeter() : void
      {
         var completionRatio:Number = this.m_partyDataObj.goal.completionRatio;
         this.setShortcutAttribute("bar",ProgressBarController.ATTRIBUTE_PERCENT,completionRatio);
         var levelCount:int = m_partyDataObj.goal.getHighestGoalLevel();
         var levelRequirement:int = 0;
         var daysRemaining:Array = [];
         var levelRequirements:Array = [];
         for(var levelIndex:int = 1; levelIndex <= levelCount; levelIndex++)
         {
            levelRequirement = m_partyDataObj.goal.getRequirementByLevel(levelIndex);
            levelRequirements.push(levelRequirement);
            daysRemaining.push(m_partyDataObj.goal.getDaysToCompleteForLevel(levelIndex));
         }
         this.setShortcutAttribute("bottomMeterText",TextFieldView.ATTRIBUTE_TEXT,levelRequirements[0].toString());
         this.setShortcutAttribute("midMeterText",TextFieldView.ATTRIBUTE_TEXT,levelRequirements[1].toString());
         this.setShortcutAttribute("maxMeterText",TextFieldView.ATTRIBUTE_TEXT,levelRequirements[2].toString());
         this.setShortcutAttribute("bottomInfoText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","TeaPartyTravelInDays",{"quantity":daysRemaining[0]}));
         this.setShortcutAttribute("midInfoText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","TeaPartyTravelInDays",{"quantity":daysRemaining[1]}));
         this.setShortcutAttribute("topInfoText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","TeaPartyTravelNow"));
         if(this.m_partyDataObj.goal.isCompleted())
         {
            this.setShortcutAttribute("topInfoBuyButton",ButtonController.ATTRIBUTE_DISABLED,true);
            this.setShortcutAttribute("InviteButton",ButtonController.ATTRIBUTE_DISABLED,true);
         }
      }
      
      private function setupTooltips() : void
      {
         var rewardName:String = null;
         var rewardXml:XML = null;
         var levelCount:int = m_partyDataObj.goal.getHighestGoalLevel();
         var rewardItems:Array = [];
         var item:FarmItem = null;
         for(var levelIndex:int = 1; levelIndex <= levelCount; levelIndex++)
         {
            rewardName = "";
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               rewardName = m_partyDataObj.goal.getRewardNameForLevel(levelIndex);
            }
            else
            {
               rewardXml = m_partyDataObj.goal.getRewardForLevel(levelIndex);
               if(rewardXml)
               {
                  rewardName = rewardXml.@name;
               }
            }
            if(rewardName)
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
               rewardItems.push(item);
               if(levelIndex <= this.m_partyDataObj.goal.currentLevel)
               {
                  this.setShortcutAttribute("level" + levelIndex + "Check",BaseWidgetView.ATTRIBUTE_VISIBLE,true);
               }
            }
         }
         var controller:BaseWidgetController = this.getShortcutController("bottomInfoBoxTooltip");
         this.setupToolTip(controller,rewardItems[0]);
         controller = this.getShortcutController("middleInfoBoxTooltip");
         this.setupToolTip(controller,rewardItems[1]);
         controller = this.getShortcutController("topInfoBoxTooltip");
         this.setupToolTip(controller,rewardItems[2]);
      }
      
      private function setupToolTip(controller:BaseWidgetController, item:FarmItem) : void
      {
         var rewardLabel:String = ZLocUtils.t("Dialogs","TeaPartyRewardLabel");
         controller.getAttribute(TooltipController.ATTRIBUTE_DISPLAY_VIEW).getChildController("body.headerText").setAttribute(TextFieldView.ATTRIBUTE_TEXT,rewardLabel);
         if(item)
         {
            controller.getAttribute(TooltipController.ATTRIBUTE_DISPLAY_VIEW).getChildController("body.prizeImage").setAttribute(ImageController.ATTRIBUTE_SOURCE,item.icon);
            controller.getAttribute(TooltipController.ATTRIBUTE_DISPLAY_VIEW).getChildController("body.prizeNameText").setAttribute(TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.tk_pk_asTitle(item.friendlyName));
         }
      }
      
      override protected function onContentLoaded(controller:BaseWidgetController) : void
      {
         if(controller.getName() == "mainPartyView")
         {
            this.setupAvatarView(controller);
         }
      }
      
      override public function onInvite(event:WidgetControllerEvent) : void
      {
         super.onInvite(event);
         FarmStatsManager.count("expansion","tea_party_ui_dialog","ask_for_help");
      }
      
      override public function destroy() : void
      {
         if(m_whatsThisDialog != null)
         {
            m_whatsThisDialog.destroy();
         }
         super.destroy();
      }
      
      private function onBuyAll(event:WidgetControllerEvent) : void
      {
         FarmStatsManager.count(TeaPartyDialog.STATS_COUNTER_NAME,"dialog","click_buy_all");
         if(null == this.m_confirmBuyAll)
         {
            if(Global.player.canBuyCash(m_cashAmountToSkip))
            {
               this.m_confirmBuyAll = UI.showMessage(ZLocUtils.t("Dialogs","TeaPartyUnlockConfirm",{"cashQuantity":m_cashAmountToSkip}),UI.BUTTON_LAYOUT_YES_NO,null,null,false,this.onBuyAllConfirm);
               this.m_confirmBuyAll.listen(WidgetControllerEvent.DIALOG_DESTROY,this.onBuyAllCancel);
            }
         }
      }
      
      private function onBuyAllCancel(event:WidgetControllerEvent) : void
      {
         this.m_confirmBuyAll = null;
      }
      
      private function onBuyAllConfirm(event:WidgetControllerEvent) : void
      {
         FarmStatsManager.count(TeaPartyDialog.STATS_COUNTER_NAME,"dialog","click_confirm_buy_all");
         this.setShortcutAttribute("topInfoBuyButton",ButtonController.ATTRIBUTE_DISABLED,true);
         TransactionManager.addTransaction(new TCompleteFriendSet(this.m_partyDataObj.friendSet,this.onBuyAllComplete),true);
         this.m_confirmBuyAll.destroy();
      }
      
      private function onBuyAllComplete() : void
      {
         setup();
      }
      
      private function onFinishParty(event:WidgetControllerEvent) : void
      {
         FarmStatsManager.count(TeaPartyDialog.STATS_COUNTER_NAME,"dialog","click_finish_party");
         TransactionManager.addTransaction(new TFriendSetCompleteSeen(m_friendSetCode));
         this.toggleVisibleAndObstruct("countDownHeader",false);
         this.toggleVisibleAndObstruct("finishedHeader",true);
         this.destroy();
      }
      
      private function onWhatIsThis(event:WidgetControllerEvent) : void
      {
         FarmStatsManager.count(TeaPartyDialog.STATS_COUNTER_NAME,"dialog","click_whats_this");
         if(m_whatsThisDialog == null)
         {
            m_whatsThisDialog = FarmDynamicDialog.createDialog("teaPartyWhatsThisDialog",FarmDynamicDialog);
            m_whatsThisDialog.setup();
            m_whatsThisDialog.setShortcutAttribute("titleText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","TeaPartyWhatsThisTitle"));
            m_whatsThisDialog.setShortcutAttribute("image1Caption",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","TeaPartWhatsThisImage1Caption"));
            m_whatsThisDialog.setShortcutAttribute("image2ACaption",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","TeaPartyWhatsThisImage2ACaption"));
            m_whatsThisDialog.setShortcutAttribute("imageDividerText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","TeaPartyWhatsThisImageDividerText"));
            m_whatsThisDialog.setShortcutAttribute("image2BCaption",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","TeaPartyWhatsThisImage2BCaption"));
            m_whatsThisDialog.setShortcutAttribute("image3Caption",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","TeaPartyWhatsThisImage3Caption"));
            m_whatsThisDialog.setShortcutAttribute("okayButton",ButtonController.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Okay"));
            m_whatsThisDialog.setShortcutListener("okayButton",WidgetControllerEvent.BUTTON_PRESSED,this.onWhatIsThisClose);
            m_whatsThisDialog.show();
            this.setVisibility(false);
         }
      }
      
      private function onWhatIsThisClose(event:WidgetControllerEvent) : void
      {
         this.setVisibility(true);
         m_whatsThisDialog = null;
      }
      
      override protected function getCounter() : String
      {
         return TeaPartyDialog.STATS_COUNTER_NAME;
      }
   }
}

