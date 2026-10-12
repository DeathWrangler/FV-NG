package Widgets.Windows.Quests
{
   import Classes.Constants.ZLocConstants;
   import Classes.Quest.FarmQuest;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.FarmDynamicDialog;
   import Display.GenericPopup;
   import Display.Quests.QuestProgressDialog;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.SubscriptionsManager;
   import Transactions.Quests.TReplayQuestChapter;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Constants.ZwToggleMode;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FarmWindow;
   import ZQuest.Init.QuestSettingsInit;
   import by.blooddy.crypto.MD5;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   
   public class QuestBonusStagesUnlock extends FarmWindow
   {
      
      private const CLOSE_BT:String = "close_bt";
      
      private var m_closeBT:SimpleButton;
      
      private const ASK_BT:String = "ask_bt";
      
      private var m_askBT:FarmAnimatedTextButton;
      
      private const BUY1_BT:String = "buy1_bt";
      
      private var m_buy1BT:MovieClip;
      
      private const BUY2_BT:String = "buy2_bt";
      
      private var m_buy2BT:MovieClip;
      
      private const REPLAY_BT:String = "replay_bt";
      
      private var m_replayBT:MovieClip;
      
      private const UNLOCK_BT:String = "unlock_bt";
      
      private var m_unlockBT:MovieClip;
      
      private const GENERIC1_TF:String = "generic1_tf";
      
      private var m_generic1TF:ZwTextField;
      
      private const GENERIC2_TF:String = "generic2_tf";
      
      private var m_generic2TF:ZwTextField;
      
      private const GENERIC3_TF:String = "generic3_tf";
      
      private var m_generic3TF:ZwTextField;
      
      private const ASKCOUNT_TF:String = "askCount_tf";
      
      private var m_askcountTF:ZwTextField;
      
      private const TITLE_TF:String = "title_tf";
      
      private var m_titleTF:ZwTextField;
      
      private const BONUS_MC:String = "bonus_mc";
      
      private var m_bonusMC:MovieClip;
      
      private const VIPTAG_MC:String = "viptag_mc";
      
      private var m_viptagMC:MovieClip;
      
      private const VIPTEXT_TF:String = "vipText_tf";
      
      private var m_viptextTF:ZwTextField;
      
      private const AMOUNT_TF:String = "amount_tf";
      
      private var m_amountTF:ZwTextField;
      
      private var s_generic1TF:String;
      
      private var s_generic2TF:String;
      
      private var s_generic3TF:String;
      
      private var s_askcountTF:int;
      
      private var s_titleTF:String;
      
      private var s_viptextTF:String;
      
      private var s_questName:String;
      
      private var s_askRecievedCount:int;
      
      private var s_bonusStageUnlockCost:int;
      
      private var s_feedItemCode:String;
      
      private var s_timeRequestedAt:String = null;
      
      private var s_lastCompletedFarmQuest:FarmQuest;
      
      public function QuestBonusStagesUnlock(windowAssetRelUrl:String, questName:String, feedItemCode:String, bonusStageUnlockCost:int = 5, generic1TF:String = "", generic2TF:String = "", generic3TF:String = "", askcountTF:int = 12, titleTF:String = "", viptextTF:String = "", modal:Boolean = true, bAddClickBlocker:Boolean = false)
      {
         super(windowAssetRelUrl,modal,bAddClickBlocker);
         this.s_generic1TF = generic1TF;
         this.s_generic2TF = generic2TF;
         this.s_generic3TF = generic3TF;
         this.s_askcountTF = askcountTF;
         this.s_titleTF = titleTF;
         this.s_viptextTF = viptextTF;
         this.s_questName = questName;
         this.s_askRecievedCount = 0;
         this.s_bonusStageUnlockCost = bonusStageUnlockCost;
         this.s_feedItemCode = feedItemCode;
         this.s_lastCompletedFarmQuest = QuestSettingsInit.getInstance().getItemByName(this.s_questName) as FarmQuest;
      }
      
      public function getAskReceivedCount() : int
      {
         return this.s_askRecievedCount;
      }
      
      override protected function postLoadComplete() : void
      {
         var hoursRemaining:Number = NaN;
         var timeRemaining:String = null;
         var minutesRemaining:Number = NaN;
         var daysRemaining:Number = NaN;
         var timeRemaining1:Array = null;
         var bonusStageUnlockCost:int = 0;
         super.postLoadComplete();
         var message:String = "";
         if(Boolean(this.s_lastCompletedFarmQuest) && Boolean(this.s_lastCompletedFarmQuest.timeRemaining > 0) && this.s_lastCompletedFarmQuest.replayable)
         {
            hoursRemaining = this.s_lastCompletedFarmQuest.timeRemaining / 3600;
            timeRemaining = "";
            if(hoursRemaining < 1)
            {
               minutesRemaining = int(hoursRemaining * 60);
               timeRemaining = ZLocUtils.t("Dialogs","TimeRemaining",{
                  "quantity":minutesRemaining,
                  "unit":ZLocUtils.tk("SocialMission","min_word","",minutesRemaining)
               });
            }
            else if(hoursRemaining <= 24)
            {
               timeRemaining = ZLocUtils.t("Dialogs","TimeRemaining",{
                  "quantity":int(hoursRemaining),
                  "unit":ZLocUtils.tk("SocialMission","hr_word","",int(hoursRemaining))
               });
            }
            else
            {
               daysRemaining = Math.round(hoursRemaining / 24);
               timeRemaining = ZLocUtils.t("Dialogs","TimeRemaining",{
                  "quantity":int(daysRemaining),
                  "unit":ZLocUtils.tk("SocialMission","day_word","",int(daysRemaining))
               });
            }
            message = "Awesome! You’ve completed the \'" + this.s_lastCompletedFarmQuest.chapterTitle + "\' Quest with " + timeRemaining + " left to play";
         }
         var isSubscriber:Boolean = SubscriptionsManager.instance.isSubscriber();
         if(isSubscriber)
         {
            if(m_window.hasOwnProperty(this.BUY2_BT))
            {
               this.m_buy2BT = m_window[this.BUY2_BT];
               this.m_buy2BT.addEventListener(MouseEvent.CLICK,this.onUnlockClick);
               this.m_buy2BT.visible = true;
            }
            if(m_window.hasOwnProperty(this.VIPTAG_MC))
            {
               this.m_viptagMC = m_window[this.VIPTAG_MC];
               this.m_viptagMC.visible = true;
            }
            if(m_window.hasOwnProperty(this.VIPTEXT_TF))
            {
               addWidget(this.m_viptextTF = new ZwTextField(m_window[this.VIPTEXT_TF],this.s_viptextTF),true);
               this.m_viptextTF.visible = true;
            }
         }
         else
         {
            this.s_askRecievedCount = FeatureOptionsInventoryManager.getInstance().getCount(this.s_feedItemCode);
            if(this.s_askRecievedCount >= this.s_askcountTF)
            {
               if(m_window.hasOwnProperty(this.ASK_BT))
               {
                  addWidget(this.m_askBT = new FarmAnimatedTextButton(m_window[this.ASK_BT],"Ask Friends",this.onAskClick),true);
                  this.m_askBT.enabled = false;
                  this.m_askBT.visible = false;
               }
               if(m_window.hasOwnProperty(this.UNLOCK_BT))
               {
                  this.m_unlockBT = m_window[this.UNLOCK_BT];
                  this.m_unlockBT.addEventListener(MouseEvent.CLICK,this.onUnlockClick);
                  this.m_unlockBT.visible = true;
               }
               if(m_window.hasOwnProperty(this.BUY1_BT))
               {
                  this.m_buy1BT = m_window[this.BUY1_BT];
                  this.m_buy1BT.visible = true;
                  if(this.m_buy1BT.hasOwnProperty(this.AMOUNT_TF))
                  {
                     addWidget(this.m_amountTF = new ZwTextField(this.m_buy1BT[this.AMOUNT_TF],this.getBonusStageUnlockCashCost().toString()),true);
                     this.m_amountTF.visible = true;
                  }
                  while(this.m_buy1BT.currentFrame != 4)
                  {
                     this.m_buy1BT.nextFrame();
                  }
               }
               if(m_window.hasOwnProperty(this.ASKCOUNT_TF))
               {
                  addWidget(this.m_askcountTF = new ZwTextField(m_window[this.ASKCOUNT_TF],this.s_askRecievedCount.toString() + " of " + this.s_askcountTF.toString()),true);
                  this.m_askcountTF.visible = true;
               }
            }
            else
            {
               if(this.getTimeUntilPostFeedEnabled() < 0)
               {
                  if(m_window.hasOwnProperty(this.ASK_BT))
                  {
                     if(!this.m_askBT)
                     {
                        addWidget(this.m_askBT = new FarmAnimatedTextButton(m_window[this.ASK_BT],"Ask Friends",this.onAskClick),true);
                     }
                     this.m_askBT.visible = true;
                     this.m_askBT.enabled = true;
                  }
               }
               else if(m_window.hasOwnProperty(this.ASK_BT))
               {
                  timeRemaining1 = FarmGameUtil.parseTimeLeft(this.getTimeUntilPostFeedEnabled());
                  if(!this.m_askBT)
                  {
                     addWidget(this.m_askBT = new FarmAnimatedTextButton(m_window[this.ASK_BT],"Ask Friends",this.onAskClick),true);
                  }
                  this.m_askBT.visible = true;
                  this.m_askBT.enabled = false;
                  this.m_askBT.setToggleMode(ZwToggleMode.SINGLE_SELECT);
                  this.m_askBT.setToggleState(ZwToggleState.SELECTED);
                  this.m_askBT.applyGrayOut = true;
                  this.m_askBT.element.buttonMode = false;
                  this.m_askBT.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"asksnowflake_timeleft",{
                     "hrs":timeRemaining1[1],
                     "min":timeRemaining1[2]
                  })));
               }
               if(m_window.hasOwnProperty(this.BUY1_BT))
               {
                  this.m_buy1BT = m_window[this.BUY1_BT];
                  this.m_buy1BT.addEventListener(MouseEvent.CLICK,this.onBuy1Click);
                  this.m_buy1BT.visible = true;
                  if(this.m_buy1BT.hasOwnProperty(this.AMOUNT_TF))
                  {
                     bonusStageUnlockCost = this.getBonusStageUnlockCashCost();
                     addWidget(this.m_amountTF = new ZwTextField(this.m_buy1BT[this.AMOUNT_TF],bonusStageUnlockCost.toString()),true);
                     this.m_amountTF.visible = true;
                  }
               }
               if(m_window.hasOwnProperty(this.ASKCOUNT_TF))
               {
                  addWidget(this.m_askcountTF = new ZwTextField(m_window[this.ASKCOUNT_TF],this.s_askRecievedCount.toString() + " of " + this.s_askcountTF.toString()),true);
                  this.m_askcountTF.visible = true;
               }
            }
         }
         if(m_window.hasOwnProperty(this.CLOSE_BT))
         {
            this.m_closeBT = m_window[this.CLOSE_BT];
            this.m_closeBT.addEventListener(MouseEvent.CLICK,this.onCloseClick);
            this.m_closeBT.visible = true;
         }
         if(m_window.hasOwnProperty(this.REPLAY_BT))
         {
            this.m_replayBT = m_window[this.REPLAY_BT];
            this.m_replayBT.addEventListener(MouseEvent.CLICK,this.onReplayClick);
            this.m_replayBT.visible = true;
         }
         if(m_window.hasOwnProperty(this.GENERIC1_TF))
         {
            addWidget(this.m_generic1TF = new ZwTextField(m_window[this.GENERIC1_TF],message),true);
            this.m_generic1TF.visible = true;
         }
         if(m_window.hasOwnProperty(this.GENERIC2_TF))
         {
            addWidget(this.m_generic2TF = new ZwTextField(m_window[this.GENERIC2_TF],this.s_generic2TF),true);
            this.m_generic2TF.visible = true;
         }
         if(m_window.hasOwnProperty(this.GENERIC3_TF))
         {
            addWidget(this.m_generic3TF = new ZwTextField(m_window[this.GENERIC3_TF],this.s_generic3TF),true);
            this.m_generic3TF.visible = true;
         }
         if(m_window.hasOwnProperty(this.BONUS_MC))
         {
            this.m_bonusMC = m_window[this.BONUS_MC];
            this.m_bonusMC.visible = false;
         }
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(this.m_titleTF = new ZwTextField(m_window[this.TITLE_TF],this.s_titleTF),true);
            this.m_titleTF.visible = true;
         }
      }
      
      private function onAskClick(evt:MouseEvent = null) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction("SpecialQuestService","askForUnlockBonusStageItem",this.postFeed,[this.s_questName,this.s_feedItemCode]),true);
         if(this.m_askBT)
         {
            this.m_askBT.enabled = false;
         }
      }
      
      private function onCloseClick(evt:MouseEvent = null) : void
      {
         super.onClose(evt);
      }
      
      private function onBuy1Click(evt:MouseEvent = null) : void
      {
         this.showBonusStageUnlockConfirmation(this.onAcceptUnlockBonusStage);
         super.onClose(evt);
      }
      
      private function onUnlockClick(evt:MouseEvent = null) : void
      {
         var progressView:Object = null;
         super.onClose(evt);
         Global.player.setSeenFlag("QuestBonusUnlocked" + this.s_questName);
         var quest:FarmQuest = QuestSettingsInit.getInstance().getItemByName(this.s_questName) as FarmQuest;
         if(Boolean(quest) && quest.name == this.s_questName)
         {
            progressView = FarmDynamicDialog.createDialog("questProgress",QuestProgressDialog);
            progressView.addImport("questObject",quest);
            progressView.setup();
            progressView.show(false,progressView.getView().name,false);
         }
      }
      
      private function onReplayClick(evt:MouseEvent = null) : void
      {
         var hoursRemaining:Number = NaN;
         var timeRemaining:String = null;
         var message:String = null;
         var replayPrompt:GenericPopup = null;
         var minutesRemaining:Number = NaN;
         var daysRemaining:Number = NaN;
         super.onClose(evt);
         if(Boolean(this.s_lastCompletedFarmQuest) && Boolean(this.s_lastCompletedFarmQuest.timeRemaining > 0) && this.s_lastCompletedFarmQuest.replayable)
         {
            hoursRemaining = this.s_lastCompletedFarmQuest.timeRemaining / 3600;
            timeRemaining = "";
            if(hoursRemaining < 1)
            {
               minutesRemaining = int(hoursRemaining * 60);
               timeRemaining = ZLocUtils.t("Dialogs","TimeRemaining",{
                  "quantity":minutesRemaining,
                  "unit":ZLocUtils.tk("SocialMission","min_word","",minutesRemaining)
               });
            }
            else if(hoursRemaining <= 24)
            {
               timeRemaining = ZLocUtils.t("Dialogs","TimeRemaining",{
                  "quantity":int(hoursRemaining),
                  "unit":ZLocUtils.tk("SocialMission","hr_word","",int(hoursRemaining))
               });
            }
            else
            {
               daysRemaining = Math.round(hoursRemaining / 24);
               timeRemaining = ZLocUtils.t("Dialogs","TimeRemaining",{
                  "quantity":int(daysRemaining),
                  "unit":ZLocUtils.tk("SocialMission","day_word","",int(daysRemaining))
               });
            }
            message = ZLocUtils.t("Quests","ReplayQuestChain",{
               "questTitle":this.s_lastCompletedFarmQuest.chapterTitle,
               "timeRemaining":timeRemaining
            });
            replayPrompt = new GenericPopup(message,GenericPopup.TYPE_YESNO,this.onCloseReplayQuestPrompt);
            if(replayPrompt)
            {
               TransactionManager.sendAllTransactions(true);
               UI.displayPopup(replayPrompt);
               FarmStatsManager.count("quest_replay_dialog","dialog_impressions");
            }
         }
      }
      
      private function onCloseReplayQuestPrompt(event:GenericPopupEvent) : void
      {
         if(Boolean(event) && event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count("quest_replay_dialog","dialog_clicks","click_replay");
            if(Boolean(this.s_lastCompletedFarmQuest) && Boolean(this.s_lastCompletedFarmQuest.name))
            {
               this.s_lastCompletedFarmQuest.removeIconFromIconQueue();
               TransactionManager.addTransaction(new TReplayQuestChapter(this.s_lastCompletedFarmQuest.name),true);
            }
         }
         else if(Boolean(event) && event.button == GenericPopup.CANCEL)
         {
            FarmStatsManager.count("quest_replay_dialog","dialog_clicks","click_cancel");
         }
      }
      
      private function getBonusStageUnlockCashCost() : int
      {
         return this.s_bonusStageUnlockCost;
      }
      
      private function onAcceptUnlockBonusStage(event:GenericPopupEvent) : void
      {
         var skipped:Boolean = false;
         var cost:int = 0;
         var quest:FarmQuest = null;
         var progressView:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            skipped = false;
            cost = this.getBonusStageUnlockCashCost();
            if(cost > 0 && Global.player.canBuyCash(cost))
            {
               TransactionManager.addTransaction(new TGenericTransaction("FarmQuestService","unlockQuestBonusStages",null,[this.s_questName]));
               Global.player.cash -= cost;
               Global.player.setSeenFlag("QuestBonusUnlocked" + this.s_questName);
            }
            super.close();
            quest = QuestSettingsInit.getInstance().getItemByName(this.s_questName) as FarmQuest;
            if(Boolean(quest) && quest.name == this.s_questName)
            {
               progressView = FarmDynamicDialog.createDialog("questProgress",QuestProgressDialog);
               progressView.addImport("questObject",quest);
               progressView.setup();
               progressView.show(false,progressView.getView().name,false);
            }
         }
      }
      
      public function showBonusStageUnlockConfirmation(callback:Function) : GenericPopup
      {
         var UNLOCK_BONUS_STAGE:String = "Hey Farmer! Are you sure you want to spend " + this.getBonusStageUnlockCashCost() + " Farm Cash to unlock the bonus parts of " + this.s_lastCompletedFarmQuest.chapterTitle + " ?";
         return UI.displayMessage(UNLOCK_BONUS_STAGE,GenericPopup.TYPE_ACCEPTCANCEL,callback,this.s_questName + "_QUEST_BONUS_STAGE_UNLOCK",true,true);
      }
      
      private function postFeed(result:Object) : void
      {
         var callBackName:String = null;
         var data:Object = result.data;
         var actionCountKey:String = this.getActionCountKey();
         var currentTimeInSec:Number = GlobalEngine.serverTime / 1000;
         if(Boolean(data) && Boolean(data.showFeedDialog))
         {
            if(Boolean(data.attachment) && Boolean(data.actionLink) && Boolean(data.userMessagePrompt))
            {
               this.s_timeRequestedAt = result.ts;
               callBackName = "feedPostCallback";
               try
               {
                  callBackName = "feedPostCallback_" + MD5.hash(data.actionLink[0].href);
               }
               catch(error:Error)
               {
               }
               ExternalInterface.addCallback(callBackName,this.feedPostCallback);
               GlobalEngine.socialNetwork.streamPublish(data.attachment,data.actionLink,null,data.userMessagePrompt);
            }
            else if(Config.DEBUG_MODE)
            {
               ErrorManager.addError("UserMessagePrompt, actionLink or attachment is missing for: " + actionCountKey);
            }
         }
         else if(Boolean(data) && Boolean(data.published))
         {
            Global.player.incrementIntervalActionCount(actionCountKey,Global.farmGameSettingsManager.getInt(actionCountKey + this.getTimeIntervalSuffix(),21600));
            Global.player.setFeatureLastShown(actionCountKey,currentTimeInSec,true);
            GlobalEngine.socialNetwork.feedPostConfirmation(data);
         }
      }
      
      protected function getTimeIntervalSuffix() : String
      {
         return "_TimeInterval";
      }
      
      private function getIntervalLimitSuffix() : String
      {
         return "_IntervalLimit";
      }
      
      public function getActionCountKey() : String
      {
         return this.s_questName + "_" + this.s_feedItemCode;
      }
      
      public function feedPostCallback(result:Object) : void
      {
         var postSuccess:Boolean = false;
         var actionCountKey:String = this.getActionCountKey();
         var currentTimeInSec:Number = GlobalEngine.serverTime / 1000;
         if(Boolean(result.result) && Boolean(result.postId) && Boolean(result.callBackName))
         {
            if(result.result == "posted")
            {
               TransactionManager.addTransaction(new TGenericTransaction("SpecialQuestService","recordBonusUnlockItemRequest",null,[this.s_questName,this.s_feedItemCode,this.s_timeRequestedAt]));
               Global.player.incrementIntervalActionCount(this.getActionCountKey(),Global.farmGameSettingsManager.getInt(actionCountKey + this.getTimeIntervalSuffix(),21600));
               Global.player.setFeatureLastShown(actionCountKey,currentTimeInSec,true);
               this.disableAskButton();
            }
            else if(this.getTimeUntilPostFeedEnabled() < 0)
            {
               if(this.m_askBT)
               {
                  this.m_askBT.enabled = true;
                  this.m_askBT.visible = true;
               }
            }
            postSuccess = true;
            ExternalInterface.addCallback(result.callBackName,null);
         }
      }
      
      private function disableAskButton() : void
      {
         var timeRemaining:Array = null;
         if(this.m_askBT)
         {
            this.m_askBT.enabled = false;
            this.m_askBT.setToggleMode(ZwToggleMode.SINGLE_SELECT);
            this.m_askBT.setToggleState(ZwToggleState.SELECTED);
            this.m_askBT.applyGrayOut = true;
            this.m_askBT.element.buttonMode = false;
            timeRemaining = FarmGameUtil.parseTimeLeft(this.getTimeUntilPostFeedEnabled());
            this.m_askBT.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"asksnowflake_timeleft",{
               "hrs":timeRemaining[1],
               "min":timeRemaining[2]
            })));
         }
      }
      
      public function getTimeUntilPostFeedEnabled() : Number
      {
         var actionKey:String = this.getActionCountKey();
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / 1000 - Global.player.getFeatureLastShown(actionKey);
         return 21600 - timeSinceLastFeed;
      }
   }
}

