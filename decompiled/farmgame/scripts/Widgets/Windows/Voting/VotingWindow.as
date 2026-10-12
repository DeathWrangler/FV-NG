package Widgets.Windows.Voting
{
   import Classes.Constants.Experiments;
   import Classes.FeatureComponents.VotingComponent;
   import Classes.FeatureDataObjects.FriendSet;
   import Classes.FeatureDataObjects.VotingFeatureFriendSet;
   import Classes.ZItem.DeprecatorSettings;
   import Classes.ZItem.FarmItem;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.GenericXMLDialog;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.OffboardingManager;
   import Managers.TemplateUIUtility;
   import Managers.VotingDataManager;
   import Transactions.TransactionWithCallBack;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.TicketParty.VotingFrame;
   import Widgets.Frames.Voting.VotingFrameBuyState;
   import Widgets.Frames.Voting.VotingFrameSummary;
   import Widgets.Icons.FarmIcon;
   import Widgets.Menu.FarmTabMenu;
   import Widgets.Menu.FarmTabMenuButton;
   import Widgets.Menu.MenuItem;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class VotingWindow extends FarmWindow
   {
      
      private static const FEATURE_FREQUENCY_VOTE_START:String = "_vote_start_";
      
      private static const COMPLETE_VOTING_SUFFIX:String = "_complete_voting_";
      
      protected var m_votingFrame:VotingFrame = null;
      
      protected var m_votingFrameBuyState:VotingFrameBuyState = null;
      
      protected var m_votingFrameSummary:VotingFrameSummary = null;
      
      protected var m_tradeInBtn:FarmAnimatedButton = null;
      
      protected var m_tradeInSubTitle:ZwTextField = null;
      
      protected var m_tradeInExecuted:Boolean = false;
      
      protected var m_firstTimeOpenWindow:Boolean = false;
      
      protected var m_crewProgressRewardLink:String = "";
      
      protected var m_askButton:FarmAnimatedButton = null;
      
      protected var m_subtitleTextField:ZwTextField = null;
      
      protected var m_subtitle2TextField:ZwTextField = null;
      
      protected var m_farmTabMenu:FarmTabMenu = null;
      
      private var m_featureName:String;
      
      private var m_votingComponent:VotingComponent;
      
      private var m_votingDataManager:VotingDataManager;
      
      private var m_currentTabIndex:int;
      
      private var m_deprecator:DeprecatorSettings;
      
      private var m_dynamicSlotMovieClipClass:Class = null;
      
      public function VotingWindow(votingComponent:VotingComponent, featureName:String, dialogAssetUrl:String, showWhatIsThisOnLoad:Boolean = false, showCrewProgressFeed:Boolean = false)
      {
         super(dialogAssetUrl);
         this.m_featureName = featureName;
         this.m_votingComponent = votingComponent;
         this.m_votingDataManager = VotingDataManager.getInstance();
         this.m_currentTabIndex = this.m_votingComponent.stage;
         if(this.m_votingDataManager.getVoteResults(featureName,this.m_votingComponent.stage) >= 0)
         {
            this.finishVotingAndMoveToNextStage();
         }
         if(this.canAutoRedeem())
         {
            this.finishVotingAndMoveToNextStage();
         }
      }
      
      public function getCurrentTabIndex() : int
      {
         return this.m_currentTabIndex;
      }
      
      private function canAutoRedeem() : Boolean
      {
         var bExpired:Boolean = this.getVoteExpirationTime() - GlobalEngine.serverTime / 1000 <= 0;
         var friendSet:FriendSet = this.m_votingComponent.getFriendSet();
         var numVotes:int = friendSet != null ? friendSet.numFriends : 0;
         var isLastStage:Boolean = this.m_votingComponent.stage == this.m_votingComponent.numStage - 1;
         return bExpired && !isLastStage && Global.player.getSeenFlag(this.m_featureName + "_seenRedeem") && this.m_votingDataManager.getVoteResults(this.m_featureName,this.m_votingComponent.stage) == -1 && numVotes >= this.m_votingComponent.votesNeededForPrize;
      }
      
      override public function close() : void
      {
         super.close();
      }
      
      override protected function postLoadComplete() : void
      {
         var subtitlePK:String = null;
         var subtitle2PK:String = null;
         var tradeInItem:FarmItem = null;
         var icon:FarmIcon = null;
         var tradeinfoPK:String = null;
         var tradeInPackageKey:String = null;
         var buttonText:String = null;
         var offBoard:Array = this.m_votingComponent.getOffBoardingData();
         if(VotingDataManager.getInstance().getVotesNeededForPrize(this.m_votingComponent.getFeatureName()) > VotingDataManager.DEFAULT_VOTES_NEEDED || Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SMART_NAUGHTY_NICE) > 0)
         {
            try
            {
               this.m_dynamicSlotMovieClipClass = m_window.loaderInfo.applicationDomain.getDefinition("friendSlot") as Class;
            }
            catch(error:Error)
            {
            }
         }
         if(Boolean(this.m_votingComponent && this.m_votingComponent.isTemplateUIEnabled()) && Boolean(m_window) && Boolean(m_window["loader_mc"]))
         {
            addWidget(new FarmIcon(m_window.loader_mc,this.m_votingComponent.getDialogBackground()));
         }
         var titlePK:String = VotingComponent.getLocalizedKey(this.m_featureName,"Title");
         var titleTextField:ZwTextField = addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.tk_pk_asTitle(titlePK))) as ZwTextField;
         if(Boolean(this.m_votingComponent) && Boolean(this.m_votingComponent.isTemplateUIEnabled()) && Boolean(titleTextField))
         {
            TemplateUIUtility.applyTextScaling(titleTextField,TemplateUIUtility.VOTING);
            TemplateUIUtility.applyDropShadowFilter(titleTextField,TemplateUIUtility.VOTING,this.m_votingComponent.getTextColor());
         }
         if(offBoard != null && offBoard.hasOwnProperty("isOffBoard") && offBoard["isOffBoard"] == true)
         {
            subtitlePK = VotingComponent.getLocalizedKey(this.m_featureName,"OffBoard_Subtitle");
            if(offBoard.hasOwnProperty("tradeInItem") && offBoard.tradeInItem != null)
            {
               tradeInItem = offBoard.tradeInItem;
               if(m_window.hasOwnProperty("subtitle_tf") && m_window.subtitle_tf != null)
               {
                  addWidget(new ZwTextField(m_window.subtitle_tf,ZLocUtils.t_pk(subtitlePK,null,{"item":ZLocUtils.tk_pk(tradeInItem.friendlyName)})));
               }
               if(m_window.hasOwnProperty("tradeinInvitehelper_mc") && m_window.tradeinInvitehelper_mc != null)
               {
                  addWidget(new ZwFrame(m_window.tradeinInvitehelper_mc));
                  addWidget(new ZwFrame(m_window.tradeinInvitehelper_mc.invitenotifiy_mc));
                  icon = addWidget(new FarmIcon(m_window.tradeinInvitehelper_mc.tradein_ticketicon_mc,tradeInItem.iconUrl)) as FarmIcon;
               }
               if(m_window.hasOwnProperty("tradeininfo_tf") && m_window.tradeininfo_tf != null)
               {
                  tradeinfoPK = VotingComponent.getLocalizedKey(this.m_featureName,"TradeInInfo");
                  this.m_tradeInSubTitle = addWidget(new ZwTextField(m_window.tradeininfo_tf,ZLocUtils.t_pk(tradeinfoPK,null,{"item":ZLocUtils.tk_pk(tradeInItem.friendlyName)}))) as ZwTextField;
               }
            }
            else if(m_window.hasOwnProperty("subtitle_tf") && m_window.subtitle_tf != null)
            {
               addWidget(new ZwTextField(m_window.subtitle_tf,ZLocUtils.t_pk(subtitlePK)));
            }
         }
         else
         {
            if(m_window.hasOwnProperty("subtitle_tf") && m_window.subtitle_tf != null)
            {
               subtitlePK = VotingComponent.getLocalizedKey(this.m_featureName,"Subtitle");
               this.m_subtitleTextField = new ZwTextField(m_window.subtitle_tf,ZLocUtils.tk_pk_asTitle(subtitlePK));
               addWidget(this.m_subtitleTextField);
            }
            if(m_window.hasOwnProperty("subtitle2_tf") && m_window.subtitle2_tf != null)
            {
               subtitle2PK = VotingComponent.getLocalizedKey(this.m_featureName,"Subtitle2");
               this.m_subtitle2TextField = new ZwTextField(m_window.subtitle2_tf,ZLocUtils.tk_pk_asTitle(subtitle2PK));
               addWidget(this.m_subtitle2TextField);
            }
         }
         if(Boolean(this.m_votingComponent && this.m_votingComponent.isTemplateUIEnabled()) && Boolean(m_window) && Boolean(m_window["tradein_bt"]))
         {
            m_window.tradein_bt.visible = false;
         }
         this.m_deprecator = Global.farmGameSettingsManager.getDeprecatorSettings(this.m_featureName);
         if(Boolean(Global.player.isDataLoaded) && Boolean(this.m_deprecator) && this.m_deprecator.checkPrereqs())
         {
            if(ObjectUtil.pathExists(m_window,["tradein_bt","request_tf"]))
            {
               tradeInPackageKey = VotingComponent.getLocalizedKey(this.m_featureName,"TradeInButton");
               buttonText = ZLocUtils.tk_pk_asTitle(tradeInPackageKey);
               addWidget(new ZwTextField(m_window.tradein_bt.request_tf,buttonText));
               this.m_tradeInBtn = addWidget(new FarmAnimatedButton(m_window.tradein_bt,this.popReplacementConfirmationDialog)) as FarmAnimatedButton;
            }
            if(!Global.player.getSeenFlag(this.m_featureName + "ReplacementDialogSeen"))
            {
               FarmStatsManager.count(this.m_featureName,"offboarding","initial_option","view");
               this.popReplacementConfirmationDialog();
            }
         }
         if(!this.m_votingComponent || !this.m_votingComponent.isTemplateUIEnabled())
         {
            addWidget(new FarmAnimatedTextButton(m_window.whatisthis_bt,ZLocUtils.t("Dialogs","WhatIsThis"),this.displayWhatIsThis,true));
         }
         if(Boolean(this.m_votingComponent && this.m_votingComponent.isTemplateUIEnabled()) && Boolean(m_window) && Boolean(m_window["bar_mc"]) && Boolean(m_window.bar_mc["color_mc"]) && Boolean(m_window.bar_mc["shadow_mc"]) && Boolean(m_window.bar_mc.shadow_mc["color_mc"]))
         {
            addWidget(new ColorBarFrame(m_window.bar_mc,this.m_votingComponent.getTextColor()));
            addWidget(new ColorBarFrame(m_window.bar_mc.shadow_mc,this.m_votingComponent.getTextColor()));
         }
         this.setupTabs();
         FarmStatsManager.count(VotingComponent.FEATURE_COUNTER,this.m_featureName,"stage_" + this.m_votingComponent.stage,"view");
         this.updateUI(false);
      }
      
      override public function refreshWindow() : void
      {
         this.updateUI(false);
      }
      
      public function popReplacementConfirmationDialog(result:Object = null) : void
      {
         var stringPackage:String = VotingComponent.getLocalizedKey(this.m_featureName,"OffboardDescription");
         var popup:GenericPopup = new GenericPopup(ZLocUtils.t_pk(stringPackage,null,{"basketName":ZLocUtils.tk_pk_asTitle("Items:" + this.m_featureName + "_friendlyName")}),GenericPopup.TYPE_ACCEPTCANCEL,this.offboardBuilding);
         popup.setAcceptTextName("VotingOffboardAccept");
         popup.setCancelTextName("VotingOffboardPostpone");
         UI.displayPopup(popup,false);
         if(Global.player.getSeenFlag(this.m_featureName + "ReplacementDialogSeen"))
         {
            FarmStatsManager.count(this.m_featureName,"offboarding","option","view");
         }
      }
      
      protected function offboardBuilding(event:GenericPopupEvent) : void
      {
         var canOffboard:Boolean = false;
         var option:String = "option";
         if(!Global.player.getSeenFlag(this.m_featureName + "ReplacementDialogSeen"))
         {
            option = "initial_option";
         }
         if(Boolean(event) && event.button == GenericPopup.ACCEPT)
         {
            canOffboard = Boolean(this.m_votingComponent) && Boolean(this.m_votingComponent.context);
            if(canOffboard)
            {
               FarmStatsManager.count(this.m_featureName,"offboarding",option,"make_storable");
               OffboardingManager.handleOffBoarding(this.m_votingComponent.context,false,true);
               this.m_votingComponent.closeVotingwindow();
            }
         }
         else
         {
            FarmStatsManager.count(this.m_featureName,"offboarding",option,"keep_basket");
         }
         Global.player.setSeenFlag(this.m_featureName + "ReplacementDialogSeen");
      }
      
      private function pause() : void
      {
         if(m_window)
         {
            tintWindow();
            enableInput = false;
         }
      }
      
      private function unpause() : void
      {
         if(m_window)
         {
            untintWindow();
            enableInput = true;
         }
      }
      
      protected function getCrewProgressFeedIcon() : String
      {
         return this.m_votingComponent.getImageUrl("crewProgressFeedIcon");
      }
      
      private function setupTabs() : void
      {
         var tabPK:String = null;
         var numTabs:int = 0;
         var menuItems:Array = null;
         var index:int = 0;
         var textColor:String = null;
         if(m_window.hasOwnProperty("tabs_mc") && m_window.tabs_mc != null)
         {
            numTabs = this.m_votingComponent.numStage + 1;
            menuItems = [];
            for(index = 0; index < numTabs; index++)
            {
               tabPK = VotingComponent.getLocalizedKey(this.m_featureName,"tab" + index);
               menuItems.push(new MenuItem(String(index),ZLocUtils.t_pk(tabPK)));
            }
            textColor = null;
            if(Boolean(this.m_votingComponent) && this.m_votingComponent.isTemplateUIEnabled())
            {
               textColor = this.m_votingComponent.getTextColor();
            }
            this.m_farmTabMenu = new FarmTabMenu(m_window.tabs_mc,this.onTabSelected,menuItems,false,10,textColor);
            addWidget(this.m_farmTabMenu);
            this.updateTabs();
         }
      }
      
      private function updateTabs() : void
      {
         var tabMenuItem:FarmTabMenuButton = null;
         var tabIsActive:Boolean = false;
         var numActiveTabs:int = this.m_votingComponent.stage + 1;
         for(var i:int = 0; i < this.m_farmTabMenu.numTabs; i++)
         {
            tabMenuItem = this.m_farmTabMenu.getTab(i);
            tabIsActive = i < numActiveTabs;
            tabMenuItem.enabled = tabIsActive;
            if(tabMenuItem.element.hasOwnProperty("lock_mc") && Boolean(tabMenuItem.element.lock_mc))
            {
               tabMenuItem.element.lock_mc.visible = !tabIsActive;
            }
            if(i == this.m_votingComponent.numStage)
            {
               tabMenuItem.enabled = this.isAllVotingCompleted();
               if(tabMenuItem.element.hasOwnProperty("lock_mc") && Boolean(tabMenuItem.element.lock_mc))
               {
                  tabMenuItem.element.lock_mc.visible = !this.isAllVotingCompleted();
               }
            }
         }
         this.m_farmTabMenu.selectTab(this.m_currentTabIndex);
      }
      
      private function onTabSelected(item:MenuItem) : void
      {
         var index:int = parseInt(item.data as String);
         this.m_currentTabIndex = index;
         this.updateUI(false);
         if(this.m_currentTabIndex == this.m_votingComponent.numStage)
         {
            this.m_votingComponent.displayDialog();
         }
      }
      
      private function createVotingArray() : Array
      {
         var arrParty:Array = new Array();
         var friendSet:FriendSet = this.m_votingComponent.getFriendSet();
         if(friendSet != null)
         {
            arrParty = friendSet.votingFriends;
         }
         else
         {
            arrParty.push(new Array());
            arrParty.push(new Array());
         }
         return arrParty;
      }
      
      private function displayVotingFrame(clearVotes:Boolean) : void
      {
         var buttonCallbacks:Object = null;
         var textColor:String = null;
         var voteStart:Number = NaN;
         var voteExpiration:Number = NaN;
         var forceNext:Boolean = false;
         var offBoard:Array = null;
         var isLastStage:Boolean = false;
         var friendSet:VotingFeatureFriendSet = null;
         var emptyData:Array = null;
         var isBuyMode:Boolean = false;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SMART_NAUGHTY_NICE) == 0)
         {
            clearVotes = true;
         }
         if(m_window.hasOwnProperty("vote_mc") && m_window.vote_mc != null)
         {
            buttonCallbacks = {
               "unlock":null,
               "buyItem":this.buyVoteItemButtonCallback,
               "redeemVoteItem":this.redeemVoteItemButtonCallback
            };
            textColor = null;
            if(Boolean(this.m_votingComponent) && this.m_votingComponent.isTemplateUIEnabled())
            {
               textColor = this.m_votingComponent.getTextColor();
            }
            if(this.m_currentTabIndex == this.m_votingComponent.numStage)
            {
               this.m_votingFrameSummary = new VotingFrameSummary(m_window.vote_mc,this.m_featureName,this.prizeItemCallback,this.replayButtonCallback,textColor);
               addWidget(this.m_votingFrameSummary);
            }
            else if(this.m_currentTabIndex == this.m_votingComponent.stage && !this.isAllVotingCompleted() && !(this.m_deprecator && this.m_deprecator.checkPrereqs()))
            {
               voteStart = this.m_votingDataManager.getDataObject(this.m_featureName).startTime;
               if(voteStart <= 0)
               {
                  friendSet = this.m_votingComponent.getFriendSet() as VotingFeatureFriendSet;
                  if(friendSet != null && clearVotes)
                  {
                     emptyData = new Array();
                     emptyData.push(new Array());
                     emptyData.push(new Array());
                     friendSet.onInitialize(emptyData);
                  }
               }
               voteExpiration = this.getVoteExpirationTime();
               forceNext = this.m_votingDataManager.getVoteResults(this.m_featureName,this.m_votingComponent.stage) >= 0;
               offBoard = this.m_votingComponent.getOffBoardingData();
               if(offBoard != null && offBoard.hasOwnProperty("isOffBoard") && offBoard["isOffBoard"] == true)
               {
                  voteExpiration = GlobalEngine.serverTime / 1000;
               }
               isLastStage = this.m_votingComponent.stage == this.m_votingComponent.numStage - 1;
               this.m_votingFrame = new VotingFrame(m_window.vote_mc,this.m_featureName,this.requestCrewVotingRewardLink,this.votingNextButtonCallback,buttonCallbacks,this.m_votingComponent.votesNeededForPrize,this.createVotingArray(),this.getAllVoteItems(),this.m_currentTabIndex,0,voteExpiration,forceNext,this.m_votingComponent.isAskForVotesEnabled(),isLastStage,this.buyStageUnlockCallback,textColor,this.m_dynamicSlotMovieClipClass);
               addWidget(this.m_votingFrame);
            }
            else
            {
               isBuyMode = this.m_currentTabIndex <= this.m_votingComponent.stage;
               this.m_votingFrameBuyState = new VotingFrameBuyState(m_window.vote_mc,this.m_featureName,buttonCallbacks,this.createVotingArray(),this.getAllVoteItems(),this.m_currentTabIndex,isBuyMode,textColor);
               addWidget(this.m_votingFrameBuyState);
            }
         }
      }
      
      private function getVoteExpirationTime() : Number
      {
         return VotingDataManager.getInstance().getVoteExpirationTime(this.m_featureName);
      }
      
      private function updateVotingFrame() : void
      {
         var forceNext:Boolean = false;
         var isLastStage:Boolean = this.m_votingComponent.stage == this.m_votingComponent.numStage - 1;
         if(this.m_votingFrame)
         {
            forceNext = this.m_votingDataManager.getVoteResults(this.m_featureName,this.m_votingComponent.stage) >= 0;
            this.m_votingFrame.update(this.createVotingArray(),this.m_currentTabIndex,0,forceNext,this.m_votingComponent.isAskForVotesEnabled(),isLastStage);
         }
         else if(this.m_votingFrameBuyState)
         {
            this.m_votingFrameBuyState.update(this.createVotingArray(),this.m_currentTabIndex,true);
         }
         else if(this.m_votingFrameSummary)
         {
            this.m_votingFrameSummary.update();
         }
      }
      
      protected function requestCrewVotingRewardLink(event:MouseEvent) : void
      {
         this.pause();
         this.m_votingComponent.askForVotes(this.onCompletedAskingForVotes,this.onFeedPublishFail);
      }
      
      protected function onCompletedAskingForVotes() : void
      {
         this.unpause();
         this.updateUI(false);
      }
      
      protected function onFeedPublishFail() : void
      {
         this.unpause();
      }
      
      private function buyStageUnlockCallback(event:MouseEvent = null) : void
      {
         if(this.m_votingComponent.unlockCurrentStage())
         {
            this.updateVotingFrame();
         }
      }
      
      private function buyVoteItemButtonCallback(itemName:String, expectedPrice:int = 0) : void
      {
         var centerIconUrl:String = null;
         var dialog:GenericXMLDialog = null;
         var voteItem:Object = null;
         var result:Boolean = false;
         if(this.m_votingComponent.canBuyVotingPrize(itemName,expectedPrice,true))
         {
            FarmStatsManager.count(VotingComponent.FEATURE_COUNTER,this.m_featureName,itemName,"buy",expectedPrice.toString());
            result = this.m_votingComponent.exeBuyVotingPrize(itemName,expectedPrice);
            if(result == true)
            {
               if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SMART_NAUGHTY_NICE) < 3)
               {
                  centerIconUrl = Global.farmGameSettingsManager.getFarmItemByName(itemName).iconRelativeUrl;
                  dialog = new GenericXMLDialog(ZLocUtils.t("Dialogs","Congratulations"),"",null,centerIconUrl,100,100,ZLocUtils.t("Dialogs","GiftboxFind"),null,true,ZLocUtils.t("Dialogs","Okay"),null,null,null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
                  UI.displayPopup(dialog,false);
               }
               if(this.m_votingFrame != null)
               {
                  voteItem = this.m_votingComponent.getVoteItemByName(itemName);
                  this.m_votingDataManager.setVoteResults(this.m_featureName,voteItem.voteIndex,this.m_votingComponent.stage);
                  if(voteItem != null)
                  {
                     this.m_votingDataManager.setCollectedItem(this.m_featureName,voteItem.name);
                     this.m_votingFrame.markPrizeBought(voteItem["voteIndex"]);
                  }
                  this.updateVotingFrame();
               }
            }
            else if(Config.DEBUG_MODE)
            {
               this.close();
            }
         }
      }
      
      private function redeemVoteItemButtonCallback(itemName:String, voteIndex:int) : void
      {
         var votesData:Array = null;
         var friendNameCount:int = 0;
         var i:int = 0;
         var result:Boolean = false;
         FarmStatsManager.count(VotingComponent.FEATURE_COUNTER,this.m_featureName,itemName,"redeem");
         if(m_window.hasOwnProperty("redeemanimation_mc") && m_window.redeemanimation_mc != null)
         {
            (m_window.redeemanimation_mc as MovieClip).visible = true;
            (m_window.redeemanimation_mc as MovieClip).gotoAndPlay(0);
         }
         var friendSet:FriendSet = this.m_votingComponent.getFriendSet();
         var voters:String = "";
         var friendName:String = "";
         if(friendSet)
         {
            votesData = friendSet.votingFriendsByIndex(voteIndex);
            if(votesData.length > 0)
            {
               friendNameCount = 0;
               for(i = 0; i < votesData.length; i++)
               {
                  friendName = Global.friendManager.getFriendName(votesData[i] as String);
                  if(friendName != "")
                  {
                     if(friendNameCount == 0)
                     {
                        voters = friendName;
                     }
                     else
                     {
                        voters = voters + ", " + friendName;
                     }
                     friendNameCount++;
                  }
               }
            }
         }
         result = this.m_votingComponent.exeRedeemVotingPrize(itemName,voteIndex,voters);
         if(votesData.length >= this.m_votingComponent.votesNeededForPrize)
         {
            FarmStatsManager.count(VotingComponent.FEATURE_COUNTER,this.m_featureName,"stage_" + stage,"vote_redeem");
         }
         if(result == true)
         {
            this.finishVotingAndMoveToNextStage();
            this.updateUI(true);
            if(this.m_currentTabIndex == this.m_votingComponent.numStage)
            {
               this.m_votingComponent.displayDialog();
            }
         }
         else if(Config.DEBUG_MODE)
         {
            this.close();
         }
      }
      
      private function finishVotingAndMoveToNextStage() : void
      {
         this.logVotingCompletionStats(this.m_votingComponent.numStage);
         this.m_votingComponent.finishVoting();
         var bHasCompleted:Boolean = this.m_votingComponent.stage == this.m_votingComponent.numStage - 1 && this.isAllVotingCompleted();
         this.m_currentTabIndex = bHasCompleted ? this.m_votingComponent.numStage : this.m_votingComponent.stage;
      }
      
      private function votingNextButtonCallback(event:MouseEvent) : void
      {
         FarmStatsManager.count(VotingComponent.FEATURE_COUNTER,this.m_featureName,"stage_" + this.m_votingComponent.stage,"next_question");
         this.finishVotingAndMoveToNextStage();
         this.updateUI(true);
         if(this.m_currentTabIndex == this.m_votingComponent.numStage)
         {
            this.m_votingComponent.displayDialog();
         }
      }
      
      private function prizeItemCallback(index:int) : Object
      {
         return this.m_votingComponent.getPrizeItemByIndex(index);
      }
      
      private function replayButtonCallback(event:MouseEvent) : void
      {
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SMART_NAUGHTY_NICE) > 0)
         {
            this.m_votingComponent.gotoNextStage();
         }
         else
         {
            TransactionManager.addTransaction(new TransactionWithCallBack("VotingService.onGoToNextStage",null,this.m_featureName),true);
         }
         FarmStatsManager.count(VotingComponent.FEATURE_COUNTER,this.m_featureName,"replay","click");
         VotingDataManager.getInstance().getDataObject(this.m_featureName).reset();
         var voteResults:Array = VotingDataManager.getInstance().getDataObject(this.m_featureName).voteResults;
         Global.player.setFeatureLastShown(this.m_featureName,0,false);
         this.m_currentTabIndex = 0;
         this.updateUI(true);
      }
      
      private function tradeInButtonCallback(event:MouseEvent) : void
      {
         var subtitlePK:String = null;
         var tradeInItem:FarmItem = null;
         var message:String = null;
         FarmStatsManager.count(VotingComponent.FEATURE_COUNTER,this.m_featureName,"trade_in","click");
         var offBoard:Array = this.m_votingComponent.getOffBoardingData();
         if(offBoard != null && offBoard.hasOwnProperty("isOffBoard") && offBoard["isOffBoard"] == true)
         {
            subtitlePK = VotingComponent.getLocalizedKey(this.m_featureName,"TradeInConfirm");
            if(offBoard.hasOwnProperty("tradeInItem") && offBoard.tradeInItem != null)
            {
               tradeInItem = offBoard.tradeInItem;
               message = ZLocUtils.t_pk(subtitlePK,null,{"item":ZLocUtils.tk_pk(tradeInItem.friendlyName)});
            }
         }
      }
      
      protected function displayWhatIsThis(event:Event = null) : void
      {
         var tutorialXML:XML = null;
         var baseBundlePrefix:String = null;
         var bundlePrefix:String = null;
         var assetPrefix:String = null;
         var xml:XML = this.m_votingComponent.getGameSettingsXml();
         if(xml.hasOwnProperty("tutorial"))
         {
            tutorialXML = xml.tutorial[0];
            baseBundlePrefix = this.m_featureName + "_";
            bundlePrefix = "";
            assetPrefix = "";
            if(tutorialXML.hasOwnProperty("@bundle"))
            {
               baseBundlePrefix = tutorialXML["@bundle"].toString() + "_";
            }
            if(tutorialXML.hasOwnProperty("@bundlePrefix"))
            {
               bundlePrefix = tutorialXML["@bundlePrefix"].toString();
            }
            if(tutorialXML.hasOwnProperty("@assetPrefix"))
            {
               assetPrefix = tutorialXML["@assetPrefix"].toString();
            }
            TutorialUI.displayBundleTutorialWindow("Voting",baseBundlePrefix + bundlePrefix,assetPrefix,false);
         }
      }
      
      private function updateUI(clearVotes:Boolean) : void
      {
         if(this.m_votingFrame != null)
         {
            removeWidget(this.m_votingFrame);
            this.m_votingFrame = null;
         }
         if(this.m_votingFrameBuyState != null)
         {
            removeWidget(this.m_votingFrameBuyState);
            this.m_votingFrameBuyState = null;
         }
         if(this.m_votingFrameSummary != null)
         {
            removeWidget(this.m_votingFrameSummary);
            this.m_votingFrameSummary = null;
         }
         this.displayVotingFrame(clearVotes);
         this.updateTabs();
      }
      
      private function getAllVoteItems() : Array
      {
         return this.m_votingComponent.getAllVoteItems();
      }
      
      private function getGameSettingsXml() : XML
      {
         return this.m_votingComponent.getGameSettingsXml();
      }
      
      private function isAllVotingCompleted() : Boolean
      {
         return VotingDataManager.getInstance().getVoteResults(this.m_featureName,this.m_votingComponent.numStage - 1) >= 0;
      }
      
      protected function logVotingCompletionStats(stageIndex:int) : void
      {
         var votingFriends:Array = null;
         var counts:Array = null;
         var isFull:Boolean = false;
         var isTie:Boolean = false;
         var hasVotes:Boolean = false;
         var i:int = 0;
         var friendSet:FriendSet = this.m_votingComponent.getFriendSet();
         FarmStatsManager.count(VotingComponent.FEATURE_COUNTER,this.m_featureName,"stage_" + stageIndex,"complete");
         var bExpired:Boolean = this.getVoteExpirationTime() - GlobalEngine.serverTime / 1000 <= 0;
         if(bExpired)
         {
            if(friendSet != null)
            {
               votingFriends = friendSet.votingFriends;
               counts = new Array();
               isFull = false;
               for(i = 0; i < votingFriends.length; i++)
               {
                  if(votingFriends[i] != null)
                  {
                     counts[i] = votingFriends[i].length;
                     if(counts[i] == this.m_votingComponent.votesNeededForPrize)
                     {
                        isFull = true;
                     }
                     if(i > 0)
                     {
                        isTie = counts[i] == counts[i - 1];
                     }
                     hasVotes = counts[i] > 0;
                  }
               }
               if(!isFull && hasVotes)
               {
                  if(isTie)
                  {
                     FarmStatsManager.count(VotingComponent.FEATURE_COUNTER,this.m_featureName,"stage_" + stageIndex,"tie");
                  }
                  else
                  {
                     FarmStatsManager.count(VotingComponent.FEATURE_COUNTER,this.m_featureName,"stage_" + stageIndex,"majority_wins");
                  }
               }
            }
         }
      }
   }
}

