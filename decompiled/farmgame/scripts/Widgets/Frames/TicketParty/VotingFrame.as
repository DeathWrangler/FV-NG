package Widgets.Frames.TicketParty
{
   import Classes.FeatureComponents.VotingComponent;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.TemplateUIUtility;
   import Managers.VotingDataManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.Voting.ColorBarFrame;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class VotingFrame extends ZwFrame
   {
      
      private var m_creditsFeatureName:String;
      
      private var m_voteCallback:Function;
      
      private var m_nextCallback:Function;
      
      private var m_unlockStageCallback:Function;
      
      private var m_buttonCallbacks:Object;
      
      private var m_nVotesNeeded:int = 4;
      
      private var m_arrPrizeSlot:Array;
      
      private var m_arrAllVoteItems:Array;
      
      private var m_arrFriendFrame:Array;
      
      private var m_arrArrowFrame:Array;
      
      private var m_askOrNextButton:FarmAnimatedTextButton;
      
      private var m_skipButton:FarmAnimatedTextButton;
      
      private var m_bAskForVotesEnabled:Boolean = true;
      
      private var m_askOrNextToolTip:FarmTextTooltip = null;
      
      private var m_remainingTimeTextField:ZwTextField;
      
      protected var m_questionTextField:ZwTextField = null;
      
      protected var m_arrVoteTextField:Array;
      
      private var m_expireTime:Number = 0;
      
      private var m_headerFrame:ZwFrame;
      
      private var m_completeFrame:ZwFrame;
      
      private var m_expiredFrame:ZwFrame;
      
      private var m_arrPrizeCanBeBought:Array;
      
      private var m_stage:int;
      
      private var m_questionBackPanel:ZwFrame;
      
      private var m_unlockLevelFrame:ZwFrame;
      
      private var m_unlockTextField:ZwTextField;
      
      private var m_unlockLevelButton:FarmAnimatedTextButton;
      
      private var m_textColor:String = null;
      
      public function VotingFrame(element:DisplayObject, creditsFeatureName:String, voteCallback:Function, nextCallback:Function, buttonCallbacks:Object, nVotesNeeded:int, arrParty:Array, arrAllVoteItems:Array, stage:int, totalTickets:Number, expireTime:Number, forceNext:Boolean, bAskForVotesEnabled:Boolean, bIsLastStage:Boolean = false, unlockStageCallback:Function = null, textColor:String = null, slotClipClass:Class = null)
      {
         var headerTextField:ZwTextField = null;
         super(element);
         this.m_creditsFeatureName = creditsFeatureName;
         this.m_voteCallback = voteCallback;
         this.m_nextCallback = nextCallback;
         this.m_unlockStageCallback = unlockStageCallback;
         this.m_buttonCallbacks = buttonCallbacks;
         this.m_nVotesNeeded = nVotesNeeded;
         this.m_expireTime = expireTime;
         this.m_arrAllVoteItems = arrAllVoteItems;
         this.m_arrPrizeCanBeBought = new Array();
         this.m_stage = stage;
         this.m_textColor = textColor;
         for(var iParty:int = 0; iParty < arrParty.length; iParty++)
         {
            this.m_arrPrizeCanBeBought.push(true);
         }
         this.update(arrParty,stage,totalTickets,forceNext,bAskForVotesEnabled,bIsLastStage,slotClipClass);
         if(m_element.hasOwnProperty("header_tf") && m_element.header_tf != null)
         {
            headerTextField = addWidget(new ZwTextField(m_element.header_tf,ZLocUtils.t("Voting","HeaderText"))) as ZwTextField;
            if(Boolean(headerTextField) && this.m_textColor != null)
            {
               TemplateUIUtility.applyTextColor(headerTextField,TemplateUIUtility.VOTING,this.m_textColor);
            }
         }
      }
      
      private function removeUpdateWidgets() : void
      {
         var iPartyFriend:int = 0;
         var iPartyPrize:int = 0;
         var iArrow:int = 0;
         if(this.m_arrFriendFrame != null)
         {
            for(iPartyFriend = 0; iPartyFriend < this.m_arrFriendFrame.length; iPartyFriend++)
            {
               if(this.m_arrFriendFrame[iPartyFriend] != null)
               {
                  removeWidget(this.m_arrFriendFrame[iPartyFriend]);
               }
            }
            this.m_arrFriendFrame = null;
         }
         if(this.m_arrPrizeSlot != null)
         {
            for(iPartyPrize = 0; iPartyPrize < this.m_arrPrizeSlot.length; iPartyPrize++)
            {
               if(this.m_arrPrizeSlot[iPartyPrize] != null)
               {
                  removeWidget(this.m_arrPrizeSlot[iPartyPrize]);
               }
            }
         }
         if(this.m_remainingTimeTextField != null)
         {
            removeWidget(this.m_remainingTimeTextField);
            this.m_remainingTimeTextField = null;
         }
         if(this.m_questionTextField != null)
         {
            removeWidget(this.m_questionTextField);
            this.m_questionTextField = null;
         }
         if(this.m_arrArrowFrame != null)
         {
            for(iArrow = 0; iArrow < this.m_arrArrowFrame.length; iArrow++)
            {
               if(this.m_arrArrowFrame[iArrow])
               {
                  removeWidget(this.m_arrArrowFrame[iArrow]);
               }
            }
            this.m_arrArrowFrame = null;
         }
         if(this.m_arrVoteTextField != null)
         {
            for(iPartyPrize = 0; iPartyPrize < this.m_arrPrizeSlot.length; iPartyPrize++)
            {
               if(this.m_arrVoteTextField[iPartyPrize] != null)
               {
                  removeWidget(this.m_arrVoteTextField[iPartyPrize]);
               }
            }
         }
         if(this.m_expiredFrame != null)
         {
            removeWidget(this.m_expiredFrame);
            this.m_expiredFrame = null;
         }
         if(this.m_headerFrame != null)
         {
            removeWidget(this.m_headerFrame);
            this.m_headerFrame = null;
         }
         if(this.m_completeFrame != null)
         {
            removeWidget(this.m_completeFrame);
            this.m_completeFrame = null;
         }
         if(this.m_askOrNextButton != null)
         {
            removeWidget(this.m_askOrNextButton);
            this.m_askOrNextButton = null;
         }
         if(this.m_questionBackPanel != null)
         {
            removeWidget(this.m_questionBackPanel);
            this.m_questionBackPanel = null;
         }
         if(this.m_unlockLevelFrame != null)
         {
            removeWidget(this.m_unlockLevelFrame);
            this.m_unlockLevelFrame = null;
         }
         if(this.m_unlockLevelButton != null)
         {
            removeWidget(this.m_unlockLevelButton);
            this.m_unlockLevelButton = null;
         }
         if(this.m_unlockTextField != null)
         {
            removeWidget(this.m_unlockTextField);
            this.m_unlockTextField = null;
         }
      }
      
      private function createRedeemArrow(iParty:int) : void
      {
         var redeemDisplayObject:Object = null;
         var infoGroupObject:Object = null;
         var infoGroupFrame:ZwFrame = null;
         var redeemPrizeElementName:String = "redeemPrize" + iParty.toString() + "_mc";
         if(this.element.hasOwnProperty(redeemPrizeElementName) && this.element[redeemPrizeElementName] != null)
         {
            redeemDisplayObject = this.element[redeemPrizeElementName];
            if(Boolean(redeemDisplayObject) && Boolean(redeemDisplayObject["color_mc"]) && this.m_textColor != null)
            {
               this.m_arrArrowFrame[iParty] = new ColorBarFrame(redeemDisplayObject as DisplayObject,this.m_textColor);
            }
            else
            {
               this.m_arrArrowFrame[iParty] = new ZwFrame(redeemDisplayObject as DisplayObject);
            }
            if(redeemDisplayObject.hasOwnProperty("infoGroup_mc") && redeemDisplayObject.infoGroup_mc != null)
            {
               infoGroupObject = redeemDisplayObject.infoGroup_mc;
               infoGroupFrame = new ZwFrame(infoGroupObject as DisplayObject);
               if(infoGroupObject.hasOwnProperty("generic_tf") && infoGroupObject.generic_tf != null)
               {
                  infoGroupFrame.addWidget(new ZwTextField(infoGroupObject.generic_tf,ZLocUtils.tk_pk_asTitle("Dialogs:TicketPartyFlyout_redeem")));
               }
               this.m_arrArrowFrame[iParty].addWidget(infoGroupFrame);
            }
            addWidget(this.m_arrArrowFrame[iParty]);
         }
      }
      
      private function createLastChanceArrow(iParty:int, nCrew:int = 0) : void
      {
         var lastChanceObject:Object = null;
         var colorFrame:ZwFrame = null;
         var lastChanceElementName:String = "lastChance" + iParty.toString() + "_mc";
         if(this.element.hasOwnProperty(lastChanceElementName) && this.element[lastChanceElementName] != null)
         {
            lastChanceObject = this.element[lastChanceElementName];
            this.m_arrArrowFrame[iParty] = new ZwFrame(lastChanceObject as DisplayObject);
            if(Boolean(this.m_textColor != null) && Boolean(this.element) && Boolean(this.element[lastChanceElementName]) && Boolean(this.element[lastChanceElementName]["color_mc"]))
            {
               colorFrame = this.m_arrArrowFrame[iParty].addWidget(new ZwFrame(this.element[lastChanceElementName]["color_mc"])) as ZwFrame;
               if(colorFrame)
               {
                  TemplateUIUtility.applyBackgroundColor(colorFrame.element as DisplayObject,TemplateUIUtility.VOTING,this.m_textColor);
                  colorFrame.visible = true;
               }
            }
            if(lastChanceObject.hasOwnProperty("generic_tf") && lastChanceObject.generic_tf != null)
            {
               if(nCrew > 0)
               {
                  this.m_arrArrowFrame[iParty].addWidget(new ZwTextField(lastChanceObject.generic_tf,ZLocUtils.tk_pk_asTitle("Dialogs:LastChanceToBuyAtDiscount")));
               }
               else
               {
                  this.m_arrArrowFrame[iParty].addWidget(new ZwTextField(lastChanceObject.generic_tf,ZLocUtils.tk_pk_asTitle("Dialogs:LastChanceToBuy")));
               }
            }
            addWidget(this.m_arrArrowFrame[iParty]);
         }
      }
      
      private function createRedeemChoiceArrow(voteIndex:int) : void
      {
         var redeemDisplayObject:Object = null;
         var redeemPrizeElementName:String = "lastChoice" + voteIndex.toString() + "_mc";
         if(this.element.hasOwnProperty(redeemPrizeElementName) && this.element[redeemPrizeElementName] != null)
         {
            redeemDisplayObject = this.element[redeemPrizeElementName];
            this.m_arrArrowFrame[voteIndex] = new ZwFrame(redeemDisplayObject as DisplayObject);
            if(redeemDisplayObject.hasOwnProperty("generic_tf") && redeemDisplayObject.generic_tf != null)
            {
               this.m_arrArrowFrame[voteIndex].addWidget(new ZwTextField(redeemDisplayObject.generic_tf,ZLocUtils.tk_pk_asTitle("Voting:RedeemFlyoutYourChoice")));
            }
            addWidget(this.m_arrArrowFrame[voteIndex]);
         }
      }
      
      private function createQuestionWidget(stage:int) : void
      {
         var PKQuestion:String = VotingComponent.getLocalizedKey(this.m_creditsFeatureName,"CrewVoting_" + stage + "_Text");
         if(m_element.hasOwnProperty("question_mc") && m_element.question_mc.question_tf != null)
         {
            this.m_questionTextField = new ZwTextField(m_element.question_mc.question_tf,ZLocUtils.t_pk(PKQuestion));
            addWidget(this.m_questionTextField);
            if(Boolean(this.m_questionTextField) && this.m_textColor != null)
            {
               TemplateUIUtility.applyTextColor(this.m_questionTextField,TemplateUIUtility.VOTING,this.m_textColor);
            }
            m_element.question_mc.visible = true;
         }
         if(m_element.hasOwnProperty("voteBack_mc") && m_element.voteBack_mc != null)
         {
            this.m_questionBackPanel = new ZwFrame(m_element.voteBack_mc);
            addWidget(this.m_questionBackPanel);
         }
      }
      
      private function createUnlockWidget() : void
      {
         var unlockBtn:MovieClip = null;
         var unlockButton:MovieClip = null;
         var cost:int = 0;
         var temp:ZwTextField = null;
         var timeLeft:Number = NaN;
         if(m_element.hasOwnProperty("lock_mc") && m_element.lock_mc != null)
         {
            this.m_unlockLevelFrame = new ZwFrame(m_element.lock_mc);
            addWidget(this.m_unlockLevelFrame);
            unlockBtn = m_element.lock_mc as MovieClip;
            if(unlockBtn != null)
            {
               if(unlockBtn.hasOwnProperty("unlock_bt") && unlockBtn.unlock_bt != null)
               {
                  this.m_unlockLevelButton = new FarmAnimatedTextButton(unlockBtn.unlock_bt);
                  addWidget(this.m_unlockLevelButton);
                  unlockButton = unlockBtn.unlock_bt as MovieClip;
                  if(unlockButton != null)
                  {
                     if(unlockButton.hasOwnProperty("cost_tf") && unlockButton.cost_tf != null)
                     {
                        cost = VotingDataManager.getInstance().getDataObject(this.m_creditsFeatureName).getStageUnlockCost();
                        temp = new ZwTextField(unlockButton.cost_tf);
                        temp.text = String(cost);
                        addWidget(temp);
                     }
                     this.m_unlockLevelButton.text = ZLocUtils.t("Dialogs","Unlock");
                  }
               }
               if(unlockBtn.hasOwnProperty("generic_tf") && unlockBtn.generic_tf != null)
               {
                  this.m_unlockTextField = new ZwTextField(unlockBtn.generic_tf);
                  timeLeft = VotingDataManager.getInstance().getTimeLeftForStageUnlock(this.m_creditsFeatureName);
                  this.m_unlockTextField.text = ZLocUtils.t("Dialogs","UnlockStage") + " " + FarmGameUtil.toFriendlyTime(timeLeft);
                  addWidget(this.m_unlockTextField);
                  if(Boolean(this.m_unlockTextField) && this.m_textColor != null)
                  {
                     TemplateUIUtility.applyTextColor(this.m_unlockTextField,TemplateUIUtility.VOTING,this.m_textColor);
                  }
               }
            }
            if(this.m_unlockLevelButton != null)
            {
               this.m_unlockLevelButton.callback = this.m_unlockStageCallback;
            }
         }
      }
      
      private function createTimeWidgets(secondsRemaining:Number) : void
      {
         var daysRemaining:Number = NaN;
         if(secondsRemaining <= 0)
         {
            if(m_element.hasOwnProperty("expired_mc") && m_element.expired_mc != null)
            {
               this.m_expiredFrame = new ZwFrame(m_element.expired_mc);
               addWidget(this.m_expiredFrame);
            }
         }
         else
         {
            daysRemaining = Math.ceil(secondsRemaining / FarmGameUtil.NUM_SECS_IN_DAY);
            if(m_element.hasOwnProperty("header_mc") && m_element.header_mc != null)
            {
               this.m_headerFrame = new ZwFrame(m_element.header_mc);
               addWidget(this.m_headerFrame);
            }
            if(m_element.hasOwnProperty("daysLeft_tf") && m_element.daysLeft_tf != null)
            {
               this.m_remainingTimeTextField = new ZwTextField(m_element.daysLeft_tf,FarmGameUtil.getTimeLeftTextInDays(daysRemaining,this.m_creditsFeatureName));
               addWidget(this.m_remainingTimeTextField);
               if(Boolean(this.m_remainingTimeTextField) && this.m_textColor != null)
               {
                  TemplateUIUtility.applyTextColor(this.m_remainingTimeTextField,TemplateUIUtility.VOTING,this.m_textColor);
               }
            }
         }
      }
      
      private function showCompleteCrewHeader(voteIndex:int, stage:int, isTie:Boolean = false) : void
      {
         var element:Object = null;
         var headerTextField:ZwTextField = null;
         var genericText:String = null;
         var genericTextField:ZwTextField = null;
         var outcomeKey:String = null;
         var PKOutcome:String = null;
         var outcomeStr:String = null;
         var completionKey:String = null;
         var PKCompletion:String = null;
         var elementName:String = "complete" + voteIndex.toString() + "_mc";
         if(m_element.hasOwnProperty(elementName) && m_element[elementName] != null)
         {
            this.m_completeFrame = new ZwFrame(m_element[elementName]);
            addWidget(this.m_completeFrame);
            element = m_element[elementName];
            if(element.hasOwnProperty("header_tf") && element.header_tf != null)
            {
               headerTextField = this.m_completeFrame.addWidget(new ZwTextField(element.header_tf,ZLocUtils.tk_pk_asTitle("Voting:CongratulationsTitle"))) as ZwTextField;
               if(Boolean(headerTextField) && this.m_textColor != null)
               {
                  TemplateUIUtility.applyDropShadowFilter(headerTextField,TemplateUIUtility.VOTING,this.m_textColor);
                  TemplateUIUtility.applyTextColor(headerTextField,TemplateUIUtility.VOTING,this.m_textColor);
               }
            }
            if(element.hasOwnProperty("generic_tf") && element.generic_tf != null)
            {
               if(isTie)
               {
                  genericText = ZLocUtils.t("Voting","CompletionTextTie");
               }
               else
               {
                  outcomeKey = "Outcome_" + stage + "_" + voteIndex + "_Text";
                  PKOutcome = VotingComponent.getLocalizedKey(this.m_creditsFeatureName,outcomeKey);
                  outcomeStr = ZLocUtils.t_pk(PKOutcome);
                  completionKey = "CompletionText";
                  PKCompletion = VotingComponent.getLocalizedKey(this.m_creditsFeatureName,completionKey);
                  genericText = ZLocUtils.t_pk(PKCompletion,null,{"vote":outcomeStr});
               }
               genericTextField = this.m_completeFrame.addWidget(new ZwTextField(element.generic_tf,genericText)) as ZwTextField;
               if(Boolean(genericTextField) && this.m_textColor != null)
               {
                  TemplateUIUtility.applyTextColor(genericTextField,TemplateUIUtility.VOTING,this.m_textColor);
               }
            }
         }
      }
      
      private function createOutcomeWidget(iParty:int, stage:int) : void
      {
         var outcomeStr:String = null;
         var PKOutcome:String = null;
         var outcomeText:String = null;
         var elementName:String = "vote" + iParty.toString() + "_tf";
         if(m_element.hasOwnProperty(elementName) && m_element[elementName] != null)
         {
            outcomeStr = "Vote_" + stage + "_" + iParty + "_Text";
            PKOutcome = VotingComponent.getLocalizedKey(this.m_creditsFeatureName,outcomeStr);
            outcomeText = ZLocUtils.t_pk(PKOutcome);
            this.m_arrVoteTextField[iParty] = new ZwTextField(m_element[elementName],outcomeText);
            if(Boolean(this.m_arrVoteTextField) && Boolean(this.m_arrVoteTextField[iParty]) && this.m_textColor != null)
            {
               TemplateUIUtility.applyTextColor(this.m_arrVoteTextField[iParty],TemplateUIUtility.VOTING,this.m_textColor);
            }
            addWidget(this.m_arrVoteTextField[iParty]);
         }
      }
      
      private function createAnimatedAskButton() : void
      {
         if(this.element.hasOwnProperty("askAnimated_bt") && this.element.askAnimated_bt != null)
         {
            if(this.m_askOrNextButton == null)
            {
               this.m_askOrNextButton = new FarmAnimatedTextButton(this.element.askAnimated_bt);
               addWidget(this.m_askOrNextButton);
               this.m_askOrNextToolTip = new FarmTextTooltip("");
               this.m_askOrNextButton.attachTooltip(this.m_askOrNextToolTip);
            }
         }
      }
      
      private function createAskButton() : void
      {
         if(this.element.hasOwnProperty("ask_bt") && this.element.ask_bt != null)
         {
            if(this.m_askOrNextButton == null)
            {
               this.m_askOrNextButton = new FarmAnimatedTextButton(this.element.ask_bt);
               addWidget(this.m_askOrNextButton);
               this.m_askOrNextToolTip = new FarmTextTooltip("");
               this.m_askOrNextButton.attachTooltip(this.m_askOrNextToolTip);
            }
         }
      }
      
      public function createNextOrAskButton(isNextEnabled:Boolean) : void
      {
         var hoursRemaining:Number = NaN;
         this.createAnimatedAskButton();
         if(this.m_askOrNextButton == null)
         {
            this.createAskButton();
         }
         if(isNextEnabled)
         {
            this.m_askOrNextButton.callback = this.m_nextCallback;
            this.m_askOrNextButton.text = ZLocUtils.tk_pk_asTitle("Voting:NextQuestion");
            this.m_askOrNextToolTip.setText("");
            this.m_askOrNextButton.applyGrayOut = false;
            this.m_askOrNextButton.enabled = true;
         }
         else
         {
            this.m_askOrNextButton.callback = this.askForVotesCallback;
            if(this.m_bAskForVotesEnabled)
            {
               this.m_askOrNextButton.text = ZLocUtils.tk_pk_asTitle("Dialogs:AskForVotes");
               this.m_askOrNextToolTip.setText("");
            }
            else
            {
               hoursRemaining = Math.ceil(VotingDataManager.getInstance().askForVotesTimeRemaining(this.m_creditsFeatureName) / FarmGameUtil.NUM_SECS_IN_HOUR);
               this.m_askOrNextButton.text = ZLocUtils.t("Voting","AskForVotesWithTimer",{"timeLeft":hoursRemaining});
               this.m_askOrNextToolTip.setText(ZLocUtils.t_pk(VotingComponent.getLocalizedKey(this.m_creditsFeatureName,"AskFailedFrequencyCheck")));
            }
            this.m_askOrNextButton.applyGrayOut = !this.m_bAskForVotesEnabled;
            this.m_askOrNextButton.enabled = this.m_bAskForVotesEnabled;
         }
      }
      
      public function createSkipButton() : void
      {
         if(this.element.hasOwnProperty("skip_bt") && this.element.skip_bt != null)
         {
            if(this.m_skipButton == null)
            {
               this.m_skipButton = new FarmAnimatedTextButton(this.element.skip_bt);
               this.m_skipButton.text = ZLocUtils.tk_pk_asTitle("Voting:Skip");
               this.m_skipButton.callback = this.skipCallback;
               addWidget(this.m_skipButton);
            }
         }
      }
      
      protected function askForVotesCallback(event:MouseEvent) : void
      {
         if(this.m_bAskForVotesEnabled)
         {
            this.m_voteCallback(event);
         }
      }
      
      protected function skipCallback(event:MouseEvent) : void
      {
         FarmStatsManager.count(VotingComponent.FEATURE_COUNTER,this.m_creditsFeatureName,this.m_stage.toString(),"skip");
         if(this.m_nextCallback != null)
         {
            this.m_nextCallback(event);
         }
      }
      
      protected function getVoteItems(stage:int) : Array
      {
         var voteItem:Object = null;
         var voteItems:Array = new Array();
         for each(voteItem in this.m_arrAllVoteItems)
         {
            if(voteItem.index == stage)
            {
               voteItems.push(voteItem);
            }
         }
         voteItems.sortOn("voteIndex",Array.NUMERIC);
         return voteItems;
      }
      
      public function update(arrParty:Array, stage:int, totalTickets:Number, bForceNext:Boolean, bAskForVotesEnabled:Boolean, bIsLastStage:Boolean = false, slotClipClass:Class = null) : void
      {
         var numTotalVotes:int = 0;
         var numMaxVotes:int = 0;
         var bIsTie:Boolean = false;
         var voteCountCache:int = 0;
         var iParty:int = 0;
         var item:Object = null;
         var nCrew:int = 0;
         var bCrewCompleted:Boolean = false;
         var friendElementName:String = null;
         var buyCost:Number = NaN;
         var discountFraction:Number = NaN;
         this.removeUpdateWidgets();
         this.m_bAskForVotesEnabled = bAskForVotesEnabled;
         var voteItems:Array = this.getVoteItems(stage);
         var secondsRemaining:Number = this.m_expireTime - GlobalEngine.serverTime / 1000;
         if(secondsRemaining < 0)
         {
            secondsRemaining = 0;
         }
         var bTimerStarted:Boolean = this.m_expireTime != VotingDataManager.TIMER_NOT_STARTED;
         var bAnyPrizeBought:Boolean = bForceNext;
         var bTimeExpired:Boolean = secondsRemaining <= 0;
         var bAnyCrewFilled:Boolean = false;
         var bAnyPrizeRedeemed:Boolean = false;
         for(iParty = 0; iParty < arrParty.length; iParty++)
         {
            if(arrParty[iParty].length >= this.m_nVotesNeeded)
            {
               bAnyCrewFilled = true;
            }
            item = voteItems[iParty];
            if(item)
            {
               if(VotingDataManager.getInstance().isItemCollected(this.m_creditsFeatureName,item.name))
               {
                  bAnyPrizeRedeemed = true;
                  this.m_arrPrizeCanBeBought[iParty] = false;
               }
            }
            numTotalVotes += arrParty[iParty].length;
            numMaxVotes = Math.max(numMaxVotes,arrParty[iParty].length);
            if(iParty == 0)
            {
               voteCountCache = int(arrParty[iParty].length);
            }
            else
            {
               bIsTie = voteCountCache == arrParty[iParty].length;
            }
         }
         var bShowHeader:Boolean = false;
         var bShowExpired:Boolean = false;
         var bShowAskButton:Boolean = false;
         var bShowNextButton:Boolean = false;
         var bShowLastChance:Boolean = false;
         var bShowRedeem:Boolean = false;
         var bShowCrewCompleteHeader:Boolean = false;
         var bShowRedeemForBoth:Boolean = false;
         var bShowMajorityWins:Boolean = false;
         var bShowSkipButton:Boolean = false;
         var bCurStageUnlocked:Boolean = this.isCurrentStageUnlocked();
         if(!bAnyCrewFilled)
         {
            if(!bAnyPrizeBought)
            {
               if(!bTimeExpired)
               {
                  bShowHeader = bShowAskButton = true;
               }
               else
               {
                  bShowExpired = true;
                  if(numMaxVotes >= this.m_nVotesNeeded)
                  {
                     if(bIsTie)
                     {
                        bShowRedeemForBoth = bShowCrewCompleteHeader = true;
                     }
                     else
                     {
                        bShowMajorityWins = bShowCrewCompleteHeader = true;
                     }
                  }
                  else
                  {
                     bShowAskButton = true;
                     if(!bIsLastStage)
                     {
                        bShowSkipButton = true;
                     }
                  }
               }
            }
            else
            {
               bShowNextButton = bShowLastChance = true;
            }
         }
         else if(!bAnyPrizeRedeemed)
         {
            bShowRedeem = bShowCrewCompleteHeader = true;
         }
         else
         {
            bShowNextButton = bShowLastChance = true;
         }
         bAnyCrewFilled = false;
         this.m_arrFriendFrame = new Array();
         this.m_arrPrizeSlot = new Array();
         this.m_arrArrowFrame = new Array();
         this.m_arrVoteTextField = new Array();
         var bHasShownCrewHeader:Boolean = false;
         for(iParty = 0; iParty < arrParty.length; iParty++)
         {
            nCrew = int(arrParty[iParty].length);
            bCrewCompleted = false;
            if(nCrew >= this.m_nVotesNeeded || bShowRedeemForBoth)
            {
               nCrew = this.m_nVotesNeeded;
               bCrewCompleted = bAnyCrewFilled = true;
            }
            else if(bShowMajorityWins && nCrew > Math.floor(numTotalVotes / 2))
            {
               bCrewCompleted = true;
            }
            friendElementName = "friends" + iParty + "_mc";
            this.m_arrFriendFrame[iParty] = new TicketPartyFriendSlotFrame(element[friendElementName],arrParty[iParty],this.m_nVotesNeeded,false,slotClipClass);
            addWidget(this.m_arrFriendFrame[iParty]);
            item = voteItems[iParty];
            buyCost = this.m_arrPrizeCanBeBought[iParty] == true ? Number(item.buyCost) : 0;
            discountFraction = this.m_nVotesNeeded - nCrew;
            discountFraction /= this.m_nVotesNeeded;
            buyCost *= discountFraction;
            buyCost = Math.ceil(buyCost);
            this.m_arrPrizeSlot[iParty] = new TicketPartyVotePrize(m_element["slot_" + iParty.toString() + "_mc"],item.name,iParty,buyCost,item.icon,this.m_creditsFeatureName,this.m_buttonCallbacks,bCrewCompleted,this.m_textColor);
            addWidget(this.m_arrPrizeSlot[iParty]);
            if(bCrewCompleted && bShowCrewCompleteHeader && !bHasShownCrewHeader)
            {
               this.showCompleteCrewHeader(iParty,stage,bIsTie);
               bHasShownCrewHeader = true;
            }
            if(nCrew > 0 && bShowRedeem && bCrewCompleted && !VotingDataManager.getInstance().isItemCollected(this.m_creditsFeatureName,item.name))
            {
               this.createRedeemArrow(iParty);
            }
            else if(bShowLastChance && Boolean(this.m_arrPrizeCanBeBought[iParty]))
            {
               this.createLastChanceArrow(iParty,nCrew);
            }
            else if(bShowRedeemForBoth)
            {
               this.createRedeemChoiceArrow(iParty);
            }
            if(bShowRedeem || bShowRedeemForBoth || bShowMajorityWins)
            {
               Global.player.setSeenFlag(this.m_creditsFeatureName + "_seenRedeem");
            }
            if(bCurStageUnlocked)
            {
               this.createOutcomeWidget(iParty,stage);
            }
         }
         if(bCurStageUnlocked)
         {
            if(bShowNextButton || bShowAskButton)
            {
               this.createNextOrAskButton(bShowNextButton);
            }
            if(bShowAskButton)
            {
               this.createQuestionWidget(stage);
            }
         }
         else
         {
            this.createUnlockWidget();
         }
         if((bShowHeader || bShowExpired) && bTimerStarted)
         {
            this.createTimeWidgets(secondsRemaining);
         }
         if(bShowSkipButton)
         {
            this.createSkipButton();
         }
      }
      
      private function isCurrentStageUnlocked() : Boolean
      {
         return VotingDataManager.getInstance().isCurrentStageUnlocked(this.m_creditsFeatureName);
      }
      
      public function markPrizeBought(iParty:int) : void
      {
         if(iParty >= 0 && iParty < this.m_arrPrizeCanBeBought.length)
         {
            this.m_arrPrizeCanBeBought[iParty] = false;
         }
      }
   }
}

