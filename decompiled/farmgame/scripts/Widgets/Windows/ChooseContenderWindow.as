package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.ChoiceDrivenManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ChoiceDrivenFeatureSlotFrame;
   import Widgets.Frames.ContenderSlotFrame;
   import Widgets.Frames.ResourcePreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class ChooseContenderWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 4;
      
      private static const ATTACK_STATE:String = ".fight_mc";
      
      private static const TutorialSuffix:String = "_contender";
      
      protected var m_featureName:String;
      
      private var m_contendersObject:Array;
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const DESCRIPTION_TF:String = "description_tf";
      
      private const NPCICON_MC:String = "npcIcon_mc";
      
      private const ACTION_BT:String = "action_bt";
      
      private const TIMER_MC:String = "timer_mc";
      
      private const BUY_TIMER_MC:String = "buyTimer_mc";
      
      private const BONUS_MC:String = "bonus_mc";
      
      private const ICON1_MC:String = "icon1_mc";
      
      private const ICON2_MC:String = "icon2_mc";
      
      private const ICON3_MC:String = "icon3_mc";
      
      private const BONUSEXPIRY_TF:String = "bonusExpiry_tf";
      
      private const BONUSSTATE_TF:String = "bonusState_tf";
      
      private const SLOTS_MC:String = "rewardSlots_mc";
      
      private const CONTENDERS_MC:String = "contenderSlots_mc";
      
      private const FEATURE_MC:String = "featureComplete_mc";
      
      private const TEXT_TITLE:String = "_contender_title";
      
      private const TEXT_DESC:String = "_contender_description";
      
      private const TEXT_COMPLETION_TITLE:String = "_contender_CompletionTitle";
      
      private const TEXT_COMPLETION_DESC:String = "_contender_CompletionDescription";
      
      private const TEXT_CALL_OUT:String = "_callOut";
      
      private const TEXT_EXPIRY_TITLE:String = "_contender_ExpiryTitle";
      
      private const TEXT_EXPIRY_DESC:String = "_contender_ExpiryDescription";
      
      private const TEXT_BONUS_EXPIRY:String = "_contender_bonus_expiry";
      
      private const TEXT_BONUS_EXPIRED:String = "_contender_bonus_expired";
      
      private const TEXT_BONUS_STATE1:String = "_contender_bonus_state1";
      
      private const TEXT_BONUS_STATE2:String = "_contender_bonus_state2";
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private const TEXT_FEATURE_TIME_LEFT:String = "_feature_timeLeft";
      
      private const TEXT_TIME_LEFT:String = "_timeLeft";
      
      protected var m_slotsFrame:ChoiceDrivenFeatureSlotFrame;
      
      protected var m_contendersFrame:ContenderSlotFrame;
      
      protected var m_actionButton:FarmAnimatedTextButton;
      
      protected var m_timerFrame:ZwFrame;
      
      protected var m_buyTimerFrame:ZwFrame;
      
      protected var m_bonusFrame:ZwFrame;
      
      protected var m_tournamentComplete:ZwFrame;
      
      protected var m_titleTf:ZwTextField;
      
      protected var m_descTf:ZwTextField;
      
      protected var m_iconPreview:ResourcePreviewFrame;
      
      private var m_timer:Timer;
      
      private var months:Array = ["January","February","March","April","May","June","July","August","September","October","November","December"];
      
      public function ChooseContenderWindow(assetPathUrl:String, featureName:String)
      {
         this.m_featureName = featureName;
         super(this.m_featureName + TutorialSuffix,assetPathUrl,NUM_TUTORIAL_SCENES,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         var activeContender:String = null;
         var timeRemaining:Number = NaN;
         var fightButtonText:String = null;
         var expiryDate:Date = null;
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            this.m_titleTf = addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_TITLE))) as ZwTextField;
         }
         if(m_window.hasOwnProperty(this.DESCRIPTION_TF))
         {
            this.m_descTf = addWidget(new ZwTextField(m_window[this.DESCRIPTION_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_DESC))) as ZwTextField;
         }
         if(m_window.hasOwnProperty(this.WHATISTHIS_MC))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.WHATISTHIS_MC],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_WHATISTHIS),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty(this.CONTENDERS_MC))
         {
            addWidget(this.m_contendersFrame = new ContenderSlotFrame(this.m_featureName,m_window[this.CONTENDERS_MC],this));
         }
         if(m_window.hasOwnProperty(this.NPCICON_MC))
         {
            activeContender = this.manager.getActiveContender();
            this.m_iconPreview = new ResourcePreviewFrame(m_window[this.NPCICON_MC],this.manager.contenderMovieClip(activeContender),this.manager.getActiveContenderFightExportName());
            addWidget(this.m_iconPreview,true);
         }
         if(m_window.hasOwnProperty(this.TIMER_MC) && this.manager.isFeaturePlayable())
         {
            addWidget(this.m_timerFrame = new ZwFrame(m_window[this.TIMER_MC]));
         }
         else if(m_window.hasOwnProperty(this.BUY_TIMER_MC) && !this.manager.isFeaturePlayable())
         {
            addWidget(this.m_buyTimerFrame = new ZwFrame(m_window[this.BUY_TIMER_MC]),false);
         }
         this.setTimerText();
         this.setBuyTimerText();
         if(m_window.hasOwnProperty(this.BONUS_MC))
         {
            addWidget(this.m_bonusFrame = new ZwFrame(m_window[this.BONUS_MC]));
            if(this.manager.isContenderBonusActive())
            {
               timeRemaining = (FarmGameUtil.synchronizedDateToNumber(this.manager.bonusEndDate) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
               addWidget(new ZwTextField(m_window[this.BONUS_MC][this.BONUSEXPIRY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BONUS_EXPIRY,{"days":HUD.getformattedTimeLeft(timeRemaining)})));
               if(this.manager.getBonusSelected() == null)
               {
                  addWidget(new ZwTextField(m_window[this.BONUS_MC][this.BONUSSTATE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BONUS_STATE1)));
                  this.showBonusOptions();
               }
               else
               {
                  addWidget(new ZwTextField(m_window[this.BONUS_MC][this.BONUSSTATE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BONUS_STATE2)));
                  this.showBonusSelected();
               }
            }
            else
            {
               this.m_bonusFrame.enabled = false;
               this.m_bonusFrame.grayOut = true;
               addWidget(new ZwTextField(m_window[this.BONUS_MC][this.BONUSEXPIRY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BONUS_EXPIRED)));
               if(this.manager.getBonusSelected() == null)
               {
                  this.showBonusOptions();
               }
               else
               {
                  addWidget(new ZwTextField(m_window[this.BONUS_MC][this.BONUSSTATE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BONUS_STATE2)));
                  this.showBonusSelected();
               }
            }
         }
         if(m_window.hasOwnProperty(this.ACTION_BT))
         {
            fightButtonText = "Start Fight";
            if(Boolean(this.manager.getBonusSelected()) || this.manager.isBonusSetExpired())
            {
               fightButtonText = "Resume Fight";
            }
            this.m_actionButton = new FarmAnimatedTextButton(m_window[this.ACTION_BT],fightButtonText,this.onChooseContender);
            addWidget(this.m_actionButton);
         }
         if(!this.manager.isFeaturePlayable())
         {
            this.m_titleTf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_EXPIRY_TITLE);
            this.m_descTf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_EXPIRY_DESC);
            if(this.m_timerFrame)
            {
               this.m_timerFrame.visible = false;
            }
            this.m_iconPreview.visible = false;
            this.m_bonusFrame.visible = false;
            this.m_actionButton.visible = false;
            removeWidget(this.m_actionButton);
            this.m_buyTimerFrame.visible = true;
            if(m_window.hasOwnProperty(this.SLOTS_MC))
            {
               addWidget(this.m_slotsFrame = new ChoiceDrivenFeatureSlotFrame(this.m_featureName,m_window[this.SLOTS_MC],this));
            }
         }
         else if(this.manager.isTournamentComplete())
         {
            this.m_titleTf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_COMPLETION_TITLE);
            expiryDate = new Date(this.manager.featureEndDate);
            this.m_descTf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_COMPLETION_DESC);
            this.m_timerFrame.visible = false;
            this.m_iconPreview.visible = false;
            this.m_bonusFrame.visible = false;
            this.m_actionButton.visible = false;
            if(m_window.hasOwnProperty(this.FEATURE_MC))
            {
               addWidget(this.m_tournamentComplete = new ZwFrame(m_window[this.FEATURE_MC]));
               this.m_tournamentComplete.visible = true;
               if(m_window.hasOwnProperty("callOut_mc"))
               {
                  m_window.callOut_mc.visible = true;
                  addWidget(new ZwTextField(m_window.callOut_mc.callOut_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_CALL_OUT,{"time":this.months[expiryDate.month] + " " + expiryDate.date})));
               }
            }
         }
         super.postLoadComplete();
      }
      
      private function get manager() : ChoiceDrivenManager
      {
         return ChoiceDrivenManager.getInstance(this.m_featureName);
      }
      
      private function onChooseContender(event:Event) : void
      {
         this.m_actionButton.enabled = false;
         if(this.manager.isContenderBonusActive())
         {
            if(this.manager.getBonusSelected() == null)
            {
               this.manager.openBonusSelectionUI();
            }
            else
            {
               this.manager.showFightUI();
            }
         }
         else
         {
            this.manager.setBonusExpired();
            this.manager.showFightUI();
         }
         close();
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         showTutorial();
      }
      
      private function showBonusOptions() : void
      {
         var item:FarmItem = null;
         var itemName:String = null;
         var infoTooltip:FarmTextTooltip = null;
         var bonusItemList:Array = this.manager.currentBonusCollection;
         if(this.m_bonusFrame.element.hasOwnProperty(this.ICON2_MC))
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(bonusItemList[0].name);
            itemName = ZLocUtils.tk_pk_asTitle(item.friendlyName);
            infoTooltip = new FarmTextTooltip(itemName);
            addWidget(new FarmIcon(this.m_bonusFrame.element[this.ICON2_MC],item.iconUrl));
            (getWidget(this.m_bonusFrame.element[this.ICON2_MC]) as FarmIcon).attachTooltip(infoTooltip);
         }
         if(this.m_bonusFrame.element.hasOwnProperty(this.ICON3_MC))
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(bonusItemList[1].name);
            itemName = ZLocUtils.tk_pk_asTitle(item.friendlyName);
            infoTooltip = new FarmTextTooltip(itemName);
            addWidget(new FarmIcon(this.m_bonusFrame.element[this.ICON3_MC],item.iconUrl));
            (getWidget(this.m_bonusFrame.element[this.ICON3_MC]) as FarmIcon).attachTooltip(infoTooltip);
         }
      }
      
      private function showBonusSelected() : void
      {
         var item:FarmItem = null;
         var itemName:String = null;
         var infoTooltip:FarmTextTooltip = null;
         if(this.m_bonusFrame.element.hasOwnProperty(this.ICON1_MC))
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(this.manager.getBonusSelected());
            itemName = ZLocUtils.tk_pk_asTitle(item.friendlyName);
            infoTooltip = new FarmTextTooltip(itemName);
            addWidget(new FarmIcon(this.m_bonusFrame.element[this.ICON1_MC],item.iconUrl));
            (getWidget(this.m_bonusFrame.element[this.ICON1_MC]) as FarmIcon).attachTooltip(infoTooltip);
         }
      }
      
      private function setTimerText() : void
      {
         var timeRemaining:Number = NaN;
         var numDays:int = 0;
         var daysLeft:String = null;
         if(this.m_timerFrame)
         {
            timeRemaining = (FarmGameUtil.synchronizedDateToNumber(this.manager.featureEndDate) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
            numDays = Math.ceil(timeRemaining / FarmGameUtil.NUM_SECS_IN_DAY);
            daysLeft = this.getExpiryDateText(this.manager.featureEndDate);
            addWidget(new ZwTextField(this.m_timerFrame.element.timerTitle_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_FEATURE_TIME_LEFT)));
            addWidget(new ZwTextField(this.m_timerFrame.element.timer1_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_TIME_LEFT,{"days":daysLeft})));
            if(!isNaN(timeRemaining))
            {
               if(numDays > 2)
               {
                  this.m_timerFrame.element.timer2_mc.visible = false;
               }
               else
               {
                  this.startTimer();
                  this.m_timerFrame.element.timer1_tf.visible = false;
                  this.m_timerFrame.element.timer2_mc.visible = true;
                  ZLocUtils.setText(m_window,"timer_mc.timer2_mc.timerAnim_mc.timer2_tf","Dialogs",this.m_featureName + this.TEXT_TIME_LEFT,{"days":daysLeft});
               }
            }
         }
      }
      
      private function setBuyTimerText() : void
      {
         var timeRemaining:Number = NaN;
         var daysLeft:String = null;
         if(this.m_buyTimerFrame)
         {
            timeRemaining = (FarmGameUtil.synchronizedDateToNumber(this.manager.featureEndDate) + ChoiceDrivenManager.REDEEM_ADDITIONAL_DAYS * FarmGameUtil.NUM_MSECS_IN_DAY - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
            daysLeft = this.getExpiryDateText(this.manager.featureEndDate,ChoiceDrivenManager.REDEEM_ADDITIONAL_DAYS);
            addWidget(new ZwTextField(this.m_buyTimerFrame.element.timerTitle_tf,"Time Left to Buy:"));
            this.m_buyTimerFrame.element.timer1_tf.visible = false;
            if(!isNaN(timeRemaining))
            {
               this.startTimer();
               this.m_buyTimerFrame.element.timer2_mc.visible = true;
               ZLocUtils.setText(m_window,"buyTimer_mc.timer2_mc.timerAnim_mc.timer2_tf","Dialogs",this.m_featureName + this.TEXT_TIME_LEFT,{"days":daysLeft});
            }
         }
      }
      
      private function startTimer() : void
      {
         if(this.m_timer == null)
         {
            this.m_timer = new Timer(1000);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer.start();
         }
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         var timeRemaining:Number = (FarmGameUtil.synchronizedDateToNumber(this.manager.featureEndDate) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(!isNaN(timeRemaining) && Boolean(this.m_timerFrame))
         {
            if(Boolean(this.m_timerFrame) && Boolean(this.m_timerFrame.element))
            {
               this.m_timerFrame.element.timer1_tf.visible = false;
               this.m_timerFrame.element.timer2_mc.visible = true;
            }
            ZLocUtils.setText(m_window,"timer_mc.timer2_mc.timerAnim_mc.timer2_tf","Dialogs",this.m_featureName + this.TEXT_TIME_LEFT,{"days":this.getformattedTimeLeftInHours(timeRemaining)});
         }
         var buyTimeRemaining:Number = (FarmGameUtil.synchronizedDateToNumber(this.manager.featureEndDate) + ChoiceDrivenManager.REDEEM_ADDITIONAL_DAYS * FarmGameUtil.NUM_MSECS_IN_DAY - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(!isNaN(buyTimeRemaining) && Boolean(this.m_buyTimerFrame))
         {
            ZLocUtils.setText(m_window,"buyTimer_mc.timer2_mc.timerAnim_mc.timer2_tf","Dialogs",this.m_featureName + this.TEXT_TIME_LEFT,{"days":this.getformattedTimeLeftInHours(buyTimeRemaining)});
         }
      }
      
      private function getExpiryDateText(endDate:String, additionalDays:int = 0) : String
      {
         var result:String = "";
         var timeRemaining:Number = (FarmGameUtil.synchronizedDateToNumber(endDate) + additionalDays * FarmGameUtil.NUM_MSECS_IN_DAY - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var numDays:int = Math.ceil(timeRemaining / FarmGameUtil.NUM_SECS_IN_DAY);
         if(!isNaN(timeRemaining))
         {
            if(numDays > 2)
            {
               result = numDays.toString() + " Days";
            }
            else
            {
               result = this.getformattedTimeLeftInHours(timeRemaining);
            }
         }
         return result;
      }
      
      private function getformattedTimeLeftInHours(timeLeft:Number) : String
      {
         var result:String = "";
         var timeLeftArray:Array = FarmGameUtil.parseTimeLeft(timeLeft);
         var hours:int = timeLeftArray[0] * 24 + timeLeftArray[1];
         result += hours < 10 ? "0" + hours : hours.toString();
         result += ":";
         var minutes:int = int(timeLeftArray[2]);
         result += minutes < 10 ? "0" + minutes : minutes.toString();
         result += ":";
         var seconds:int = int(timeLeftArray[3]);
         return result + (seconds < 10 ? "0" + seconds : seconds.toString());
      }
      
      override public function refreshWindow() : void
      {
         this.m_slotsFrame.refresh();
         this.m_contendersFrame.refresh();
      }
      
      override protected function release() : void
      {
         this.m_timerFrame = null;
         this.m_buyTimerFrame = null;
         this.m_bonusFrame = null;
         super.release();
      }
   }
}

