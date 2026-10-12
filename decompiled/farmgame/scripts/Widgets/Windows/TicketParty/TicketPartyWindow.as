package Widgets.Windows.TicketParty
{
   import Classes.Constants.MFSConstants;
   import Classes.FeatureDataObjects.FriendSet;
   import Classes.RewardCreditsBuilding;
   import Classes.TicketPartyBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.GenericXMLDialog;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import Managers.ToasterManager;
   import Transactions.TGenericWorldObjectTransaction;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Frames.TicketParty.AvatarPartyFrame;
   import Widgets.Frames.TicketParty.TicketPartyFlyoutSlotFrame;
   import Widgets.Frames.TicketParty.TicketPartyMeterFrame;
   import Widgets.Frames.TicketParty.TicketPartyPrize;
   import Widgets.Frames.TicketParty.TicketPartyPrizePreviewFrame;
   import Widgets.Frames.TicketParty.TicketPartyStagedMeterFrame;
   import Widgets.Frames.TicketParty.VotingFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.HolidayBasketWindows.RewardCreditsWindow;
   import Widgets.Windows.IconToasterWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class TicketPartyWindow extends RewardCreditsWindow
   {
      
      private static const TICKETS_PER_INVITE:Number = 5;
      
      private static const TICKETS_PER_REQUEST:Number = 1;
      
      private static const FEATURE_FREQUENCY_VOTE_START:String = "_vote_start_";
      
      private static const COMPLETE_VOTING_SUFFIX:String = "_complete_voting_";
      
      private static var m_firstTimeOpenArray:Array = new Array();
      
      protected var m_partyFrame:AvatarPartyFrame = null;
      
      protected var m_partyMembers:Array;
      
      protected var m_votingFrame:VotingFrame = null;
      
      protected var m_accumulativeCosts:Object;
      
      protected var m_ticketFlyoutSlotFrame:TicketPartyFlyoutSlotFrame = null;
      
      protected var m_ticketPartyPrize:TicketPartyPrize = null;
      
      protected var m_ticketPartyPrizePreviewFrame:TicketPartyPrizePreviewFrame = null;
      
      protected var m_tradeInBtn:FarmAnimatedButton = null;
      
      protected var m_tradeInSubTitle:ZwTextField = null;
      
      protected var m_tradeInExecuted:Boolean = false;
      
      protected var m_ticketMeter:TicketPartyMeterFrame = null;
      
      protected var m_stagedTicketMeter:TicketPartyStagedMeterFrame = null;
      
      protected var m_ticketCountTf:ZwTextField = null;
      
      protected var m_ticketLabelTf:ZwTextField = null;
      
      protected var m_ticketDescriptionTextField:ZwTextField = null;
      
      protected var m_firstTimeOpenWindow:Boolean = false;
      
      protected var m_crewProgressRewardLink:String = "";
      
      protected var m_arrStageIcons:Array;
      
      protected var m_finishedPrizeFrame:ZwFrame = null;
      
      protected var m_askButton:FarmAnimatedButton = null;
      
      protected var m_subtitleTextField:ZwTextField = null;
      
      protected var m_subtitle2TextField:ZwTextField = null;
      
      public function TicketPartyWindow(building:TicketPartyBuilding, buildingClassName:String, dialogAssetUrl:String, showWhatIsThisOnLoad:Boolean = false, showCrewProgressFeed:Boolean = false)
      {
         var numMembers:* = 0;
         var uid:String = null;
         this.m_partyMembers = new Array();
         this.m_accumulativeCosts = {};
         this.m_arrStageIcons = new Array();
         super(building,buildingClassName,dialogAssetUrl,showWhatIsThisOnLoad,null);
         var friendSet:FriendSet = building.getFriendSet();
         if(friendSet != null)
         {
            numMembers = 0;
            for(uid in friendSet.friends)
            {
               if(friendSet.friends[uid] > 0)
               {
                  var _loc11_:Number;
                  this.m_partyMembers[_loc11_ = numMembers++] = Number(uid);
               }
            }
         }
         if(showCrewProgressFeed)
         {
            this.requestCrewProgressRewardLink();
         }
         if(building.isStaged())
         {
            building.updateStage();
         }
         if(Global.player.getSeenFlag(building.getCreditsFeatureName() + COMPLETE_VOTING_SUFFIX + building.stage.toString()))
         {
            this.finishVotingAndMoveToNextStage();
         }
      }
      
      override public function close() : void
      {
         var ticketPartyBuilding:TicketPartyBuilding = m_building as TicketPartyBuilding;
         ticketPartyBuilding.clearAskForVotesFeedPostedCallback();
         super.close();
      }
      
      override protected function triggerOpenStat() : void
      {
         var building:TicketPartyBuilding = m_building as TicketPartyBuilding;
         if(building.hasVoteBonusPrizes())
         {
            if(building.inVotingBonusStage())
            {
               FarmStatsManager.count(m_buildingClassName,"open_crew",building.stage.toString());
            }
            else
            {
               FarmStatsManager.count(m_buildingClassName,"open_basket",building.stage.toString());
            }
         }
         else if(building.isStaged())
         {
            FarmStatsManager.count(m_buildingClassName,"open_basket",building.stage.toString());
         }
         else
         {
            super.triggerOpenStat();
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var redeemItem:Object = null;
         var titlePK:String = null;
         var subtitlePK:String = null;
         var subtitle2PK:String = null;
         var tradeInItem:FarmItem = null;
         var icon:FarmIcon = null;
         var base:uint = 0;
         var max:uint = 0;
         var current:uint = 0;
         var ticketDescriptionPkg:String = null;
         var tradeInPackageKey:String = null;
         var buttonText:String = null;
         var inviteFriendsPackageKey:String = null;
         var experiments:Array = null;
         var inviteFriendsHelperPackageKey:String = null;
         var inviteFriendsInfoPackage:String = null;
         var requestLabelPackage:String = null;
         var requestTicketsInfoPackage:String = null;
         var building:TicketPartyBuilding = m_building as TicketPartyBuilding;
         var offBoard:Array = this.m_building.getOffBoardingData();
         var redeemItems:Array = Global.farmGameSettingsManager.getBuildingRewardItems(this.m_building.getCreditsFeatureName());
         redeemItems.sortOn("index",Array.NUMERIC);
         var accumulativeCost:Number = 0;
         for each(redeemItem in redeemItems)
         {
            accumulativeCost += redeemItem.cost["feature"];
            this.m_accumulativeCosts[redeemItem.name] = accumulativeCost;
            redeemItem.accumulativeCost = accumulativeCost;
            redeemItem.redeemItemSeenFlag = (m_building as TicketPartyBuilding).getRedeemItemSeenFlagName(redeemItem.name);
         }
         titlePK = RewardCreditsBuilding.getLocalizedKey(m_buildingClassName,"Title");
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.tk_pk_asTitle(titlePK)));
         if(offBoard != null && offBoard.hasOwnProperty("isOffBoard") && offBoard["isOffBoard"] == true)
         {
            subtitlePK = RewardCreditsBuilding.getLocalizedKey(m_buildingClassName,"OffBoard_Subtitle",true);
            if(offBoard.hasOwnProperty("tradeInItem") && offBoard.tradeInItem != null)
            {
               tradeInItem = offBoard.tradeInItem;
               if(m_window.hasOwnProperty("subtitle_tf") && m_window.subtitle_tf != null)
               {
                  addWidget(new ZwTextField(m_window.subtitle_tf,ZLocUtils.t(subtitlePK,"OffBoard_Subtitle",{"item":ZLocUtils.tk_pk(tradeInItem.friendlyName)})));
               }
               if(m_window.hasOwnProperty("tradeinInvitehelper_mc") && m_window.tradeinInvitehelper_mc != null)
               {
                  addWidget(new ZwFrame(m_window.tradeinInvitehelper_mc));
                  addWidget(new ZwFrame(m_window.tradeinInvitehelper_mc.invitenotifiy_mc));
                  icon = addWidget(new FarmIcon(m_window.tradeinInvitehelper_mc.tradein_ticketicon_mc,tradeInItem.iconUrl)) as FarmIcon;
               }
               if(m_window.hasOwnProperty("tradeininfo_tf") && m_window.tradeininfo_tf != null)
               {
                  this.m_tradeInSubTitle = addWidget(new ZwTextField(m_window.tradeininfo_tf,ZLocUtils.t(subtitlePK,"TradeInInfo",{"item":ZLocUtils.tk_pk(tradeInItem.friendlyName)}))) as ZwTextField;
               }
            }
            else
            {
               addWidget(new ZwTextField(m_window.subtitle_tf,ZLocUtils.t(subtitlePK,"OffBoard_Subtitle")));
            }
         }
         else
         {
            if(m_window.hasOwnProperty("subtitle_tf") && m_window.subtitle_tf != null)
            {
               subtitlePK = RewardCreditsBuilding.getLocalizedKey(m_buildingClassName,"Subtitle");
               this.m_subtitleTextField = new ZwTextField(m_window.subtitle_tf,ZLocUtils.tk_pk_asTitle(subtitlePK));
               addWidget(this.m_subtitleTextField);
            }
            if(m_window.hasOwnProperty("subtitle2_tf") && m_window.subtitle2_tf != null)
            {
               subtitle2PK = RewardCreditsBuilding.getLocalizedKey(m_buildingClassName,"Subtitle2");
               this.m_subtitle2TextField = new ZwTextField(m_window.subtitle2_tf,ZLocUtils.tk_pk_asTitle(subtitle2PK));
               addWidget(this.m_subtitle2TextField);
            }
         }
         if(m_window.hasOwnProperty("avatarFrame_mc") && m_window.avatarFrame_mc != null)
         {
            this.m_partyFrame = new AvatarPartyFrame(m_window.avatarFrame_mc,this.m_partyMembers,false);
            addWidget(this.m_partyFrame);
         }
         if(building.isStaged())
         {
            base = uint(building.getCumulativeStageReceivedCredits(building.stage - 1));
            max = building.getCumulativeStageReceivedCredits(building.stage) - base;
            current = building.getTotalCreditsReceived() - base;
            this.m_stagedTicketMeter = new TicketPartyStagedMeterFrame(m_window.progression_meter_mc,0,max,current);
            addWidget(this.m_stagedTicketMeter);
         }
         else
         {
            this.m_ticketMeter = addWidget(new TicketPartyMeterFrame(m_window.progression_meter_mc,m_building,m_buildingClassName,this.ticketCountToStartMeterAt())) as TicketPartyMeterFrame;
         }
         var totalTickets:Number = m_building.getTotalCreditsReceived();
         var ticketCountLabelPkg:String = RewardCreditsBuilding.getLocalizedKey(m_buildingClassName,"TicketCountLabel",true);
         var ticketItemPK:String = RewardCreditsBuilding.getLocalizedKey(m_buildingClassName,"Item");
         this.m_ticketLabelTf = new ZwTextField(m_window.ticketsowned_tf,ZLocUtils.t(ticketCountLabelPkg,"TicketCountLabel",{"item":ZLocUtils.tk_pk_asTitlePlural(ticketItemPK)}));
         addWidget(this.m_ticketLabelTf);
         if(m_window.hasOwnProperty("itemCost_tf") && m_window.itemCost_tf != null)
         {
            ticketDescriptionPkg = RewardCreditsBuilding.getLocalizedKey(m_buildingClassName,"TicketCountDescription",true);
            this.m_ticketDescriptionTextField = new ZwTextField(m_window.itemCost_tf,ZLocUtils.t(ticketDescriptionPkg,"TicketCountDescription"));
            addWidget(this.m_ticketDescriptionTextField);
         }
         if(m_window.hasOwnProperty("ownedcount_tf") && m_window.ownedcount_tf != null)
         {
            this.m_ticketCountTf = addWidget(new ZwTextField(m_window.ownedcount_tf,totalTickets.toString())) as ZwTextField;
         }
         if(m_window.hasOwnProperty("exp_ticketicon_mc") && m_window.exp_ticketicon_mc != null)
         {
            addWidget(new ZwWidget(m_window.exp_ticketicon_mc));
         }
         var flyoutButtonCallbacks:Object = {
            "unlock":this.unlockLevelCallback,
            "buyItem":this.buyItemButtonCallback,
            "redeemItem":this.redeemItemButtonCallback
         };
         if(m_window.hasOwnProperty("slotFrame_mc") && m_window.slotFrame_mc != null)
         {
            this.m_ticketFlyoutSlotFrame = addWidget(new TicketPartyFlyoutSlotFrame(m_window.slotFrame_mc,redeemItems,totalTickets,flyoutButtonCallbacks)) as TicketPartyFlyoutSlotFrame;
         }
         if(offBoard != null && offBoard.hasOwnProperty("isOffBoard") && offBoard["isOffBoard"] == true)
         {
            tradeInPackageKey = RewardCreditsBuilding.getLocalizedKey(m_buildingClassName,"TradeInButton");
            buttonText = ZLocUtils.tk_pk_asTitle(tradeInPackageKey);
            addWidget(new ZwTextField(m_window.tradein_bt.request_tf,buttonText));
            this.m_tradeInBtn = addWidget(new FarmAnimatedButton(m_window.tradein_bt,this.tradeInButtonCallback)) as FarmAnimatedButton;
            this.refreshTradeInButton();
         }
         else
         {
            inviteFriendsPackageKey = RewardCreditsBuilding.getLocalizedKey(m_buildingClassName,"InviteFriends");
            experiments = Global.farmGameSettingsManager.getBuildingExperimentData(m_building.getCreditsFeatureName());
            if(experiments.hasOwnProperty("requestTickets") && Global.experimentManager.getExperimentVariant(experiments["requestTickets"]) == 0)
            {
               if(m_window.hasOwnProperty("initialInvite_bt") && m_window.initialInvite_bt != null)
               {
                  addWidget(new ZwTextField(m_window.initialInvite_bt.invite_tf,ZLocUtils.tk_pk_asTitle(inviteFriendsPackageKey)));
                  addWidget(new FarmAnimatedButton(m_window.initialInvite_bt,this.inviteFriendsButtonCallback));
               }
               if(m_window.hasOwnProperty("initialInvitehelper_mc") && m_window.initialInvitehelper_mc != null)
               {
                  addWidget(new ZwWidget(m_window.initialInvitehelper_mc));
                  inviteFriendsHelperPackageKey = RewardCreditsBuilding.getLocalizedKey(m_buildingClassName,"InviteFriendsHelper");
                  addWidget(new ZwTextField(m_window.initialInvitehelper_mc.initalInvitehelper_tf,ZLocUtils.tk_pk_asTitle(inviteFriendsHelperPackageKey)));
               }
            }
            else
            {
               if(m_window.hasOwnProperty("invite_bt") && m_window.invite_bt != null)
               {
                  addWidget(new ZwTextField(m_window.invite_bt.invite_tf,ZLocUtils.tk_pk_asTitle(inviteFriendsPackageKey)));
                  addWidget(new FarmAnimatedButton(m_window.invite_bt,this.inviteFriendsButtonCallback));
               }
               if(m_window.hasOwnProperty("invitebtninfo_tf") && m_window.invitebtninfo_tf != null)
               {
                  inviteFriendsInfoPackage = RewardCreditsBuilding.getLocalizedKey(m_buildingClassName,"InviteFriendsInfo",true);
                  addWidget(new ZwTextField(m_window.invitebtninfo_tf,ZLocUtils.t(inviteFriendsInfoPackage,"InviteFriendsInfo",{
                     "count":TICKETS_PER_INVITE,
                     "item":ZLocUtils.tk_pk_asTitlePlural(ticketItemPK)
                  })));
               }
               if(m_window.hasOwnProperty("request_bt") && m_window.request_bt != null)
               {
                  requestLabelPackage = RewardCreditsBuilding.getLocalizedKey(m_buildingClassName,"RequestTicketLabel",true);
                  if(Boolean(m_window.request_bt.hasOwnProperty("request_tf")) && m_window.request_bt.request_tf != null)
                  {
                     addWidget(new ZwTextField(m_window.request_bt.request_tf,ZLocUtils.t(requestLabelPackage,"RequestTicketLabel",{"item":ZLocUtils.tk_pk_asTitlePlural(ticketItemPK)})));
                  }
                  this.m_askButton = new FarmAnimatedButton(m_window.request_bt,this.requestTicketsButtonCallback);
                  addWidget(this.m_askButton);
               }
               if(m_window.hasOwnProperty("requestbtninfo_tf") && m_window.requestbtninfo_tf != null)
               {
                  requestTicketsInfoPackage = RewardCreditsBuilding.getLocalizedKey(m_buildingClassName,"RequestTicketInfo",true);
                  addWidget(new ZwTextField(m_window.requestbtninfo_tf,ZLocUtils.t(requestTicketsInfoPackage,"RequestTicketInfo",{
                     "count":TICKETS_PER_REQUEST,
                     "item":ZLocUtils.tk_pk_asTitle(ticketItemPK)
                  })));
               }
            }
         }
         addWidget(new FarmAnimatedTextButton(m_window.whatisthis_bt,ZLocUtils.t(LOC_BUNDLE,"WhatIsThis"),this.displayWhatIsThis,true));
         setupPreOffBoarding(offBoard);
         this.setupBackgroundAnimations();
         this.updateUI();
         this.rollOutPrizePreviewFrame();
         if(!Global.player.getSeenFlag(m_buildingClassName + "StorageDialog"))
         {
            Global.player.setSeenFlag(m_buildingClassName + "StorageDialog");
            this.m_firstTimeOpenWindow = true;
            FarmStatsManager.count(m_building.getItemName(),"first main dialog","impressions");
         }
         else
         {
            FarmStatsManager.count(m_building.getItemName(),"return main dialog","impressions");
         }
      }
      
      public function pause() : void
      {
         if(m_window)
         {
            tintWindow();
            enableInput = false;
         }
      }
      
      public function unpause() : void
      {
         if(m_window)
         {
            untintWindow();
            enableInput = true;
         }
      }
      
      protected function updateBuyButton() : void
      {
         var ticketPartyBuilding:TicketPartyBuilding = null;
         var creditQuantity:int = 0;
         var strCreditQuantity:String = null;
         var str:String = null;
         var strPK:String = null;
         var itemPK:String = null;
         if(m_buyButton)
         {
            ticketPartyBuilding = m_building as TicketPartyBuilding;
            creditQuantity = ticketPartyBuilding.computeBuyCreditsAmount(5);
            if(creditQuantity > 0)
            {
               m_buyButton.visible = true;
               strCreditQuantity = creditQuantity.toString();
               m_treatPackSize = creditQuantity;
               str = "";
               strPK = RewardCreditsBuilding.getLocalizedKey(m_buildingClassName,"BuyCreditsButton",true);
               itemPK = RewardCreditsBuilding.getCreditItemFriendlyName(m_buildingClassName);
               if("" != itemPK && ZLocUtils.isObject(itemPK))
               {
                  str = ZLocUtils.t_pk(strPK,"BuyCreditsButton",{
                     "item":ZLocUtils.tk_pk(itemPK),
                     "quantity":strCreditQuantity
                  });
               }
               else
               {
                  str = ZLocUtils.t_pk(strPK,"BuyCreditsButton",{"quantity":strCreditQuantity});
               }
               if(m_buyButton != null)
               {
                  m_buyButton.text = str;
               }
            }
            else
            {
               m_buyButton.visible = false;
            }
         }
      }
      
      override protected function buildBuyButton(button1:MovieClip, button2:MovieClip = null) : void
      {
         var ticketPartyBuilding:TicketPartyBuilding = m_building as TicketPartyBuilding;
         if(ticketPartyBuilding.isStaged())
         {
            if(button1 != null)
            {
               m_buyButton = new FarmAnimatedTextButton(button1,"",this.onBuyCredits,true);
               addWidget(m_buyButton);
               this.updateBuyButton();
            }
         }
         else
         {
            super.buildBuyButton(button1);
         }
      }
      
      override protected function onBuyCredits(event:MouseEvent) : void
      {
         super.onBuyCredits(event);
         this.updateBuyButton();
      }
      
      protected function requestCrewProgressRewardLink() : void
      {
         TransactionManager.addTransaction(new TGenericWorldObjectTransaction(this.m_building,"generateCrewProgressReward",this.displayCrewProgressDialog),true);
      }
      
      protected function getCrewProgressFeedIcon() : String
      {
         return m_building.getBuildingImageUrl("crewProgressFeedIcon");
      }
      
      protected function displayCrewProgressDialog(data:Object) : void
      {
         var messageName:String = null;
         var message:String = null;
         var iconPopup:GenericIconPopup = null;
         if(data.hasOwnProperty("rewardUrl"))
         {
            this.m_crewProgressRewardLink = data.rewardUrl;
            messageName = this.m_building.getCreditsFeatureName() + "_crewProgressDialog";
            message = ZLocUtils.t("Dialogs",messageName);
            iconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShareCrewProgress,Global.getAssetURL(this.getCrewProgressFeedIcon()));
            UI.displayPopup(iconPopup,false);
         }
      }
      
      protected function onShareCrewProgress(event:GenericPopupEvent) : void
      {
         var bundleData:Object = null;
         var messageType:String = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            bundleData = {
               "reward_link":this.m_crewProgressRewardLink,
               "images":[{
                  "href":"{SN_APP_URL}" + this.m_crewProgressRewardLink,
                  "src":Global.getAssetURL(this.getCrewProgressFeedIcon())
               }]
            };
            messageType = this.m_building.getCreditsFeatureName() + "CrewProgress";
            GlobalEngine.socialNetwork.publishFeedStory(messageType,bundleData,[],false);
         }
      }
      
      private function updateStage() : void
      {
         var stageElementName:String = null;
         var building:TicketPartyBuilding = m_building as TicketPartyBuilding;
         for(var iStage:int = 0; iStage < building.maxStage; iStage++)
         {
            stageElementName = "stage" + iStage + "_mc";
            if(m_window.hasOwnProperty(stageElementName) && m_window[stageElementName] != null)
            {
               if(!this.m_arrStageIcons[iStage])
               {
                  this.m_arrStageIcons[iStage] = new FarmIcon(m_window[stageElementName]);
                  addWidget(this.m_arrStageIcons[iStage],false);
               }
               this.m_arrStageIcons[iStage].visible = iStage == building.stage ? true : false;
            }
         }
      }
      
      private function createVotingArray() : Array
      {
         var building:TicketPartyBuilding = m_building as TicketPartyBuilding;
         var arrParty:Array = new Array();
         var friendSet:FriendSet = building.getFriendSet();
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
      
      private function getAllVoteItems() : Array
      {
         var ticketPartyBuilding:TicketPartyBuilding = m_building as TicketPartyBuilding;
         return Global.farmGameSettingsManager.getBuildingRewardItems(ticketPartyBuilding.getCreditsFeatureName(),0,0,"voteItem");
      }
      
      private function displayVotingFrame() : void
      {
         var buttonCallbacks:Object = null;
         var creditsFeatureName:String = null;
         var voteStartKey:String = null;
         var voteStart:Number = NaN;
         var voteExpiration:Number = NaN;
         var forceNext:Boolean = false;
         var offBoard:Array = null;
         var friendSet:FriendSet = null;
         var emptyData:Array = null;
         var ticketPartyBuilding:TicketPartyBuilding = m_building as TicketPartyBuilding;
         if(m_window.hasOwnProperty("vote_mc") && m_window.vote_mc != null)
         {
            buttonCallbacks = {
               "unlock":this.unlockLevelCallback,
               "buyItem":this.buyVoteItemButtonCallback,
               "redeemVoteItem":this.redeemVoteItemButtonCallback
            };
            creditsFeatureName = ticketPartyBuilding.getCreditsFeatureName();
            voteStartKey = creditsFeatureName + FEATURE_FREQUENCY_VOTE_START + ticketPartyBuilding.stage.toString();
            voteStart = Global.player.getFeatureLastShown(voteStartKey);
            if(voteStart == 0)
            {
               voteStart = GlobalEngine.serverTime / 1000;
               Global.player.setFeatureLastShown(voteStartKey,voteStart,false);
               friendSet = ticketPartyBuilding.getFriendSet();
               emptyData = new Array();
               emptyData.push(new Array());
               emptyData.push(new Array());
               if(friendSet != null)
               {
                  friendSet.onInitialize(emptyData);
               }
            }
            voteExpiration = voteStart + Global.farmGameSettingsManager.getNumber(creditsFeatureName + "VoteExpireFeatureFrequency",3 * FarmGameUtil.NUM_SECS_IN_DAY);
            forceNext = Global.player.getSeenFlag(ticketPartyBuilding.getCreditsFeatureName() + COMPLETE_VOTING_SUFFIX + ticketPartyBuilding.stage.toString());
            offBoard = ticketPartyBuilding.getOffBoardingData();
            if(offBoard != null && offBoard.hasOwnProperty("isOffBoard") && offBoard["isOffBoard"] == true)
            {
               voteExpiration = GlobalEngine.serverTime / 1000;
            }
            this.m_votingFrame = new VotingFrame(m_window.vote_mc,creditsFeatureName,this.requestCrewVotingRewardLink,this.votingNextButtonCallback,buttonCallbacks,ticketPartyBuilding.votesNeededForPrize,this.createVotingArray(),this.getAllVoteItems(),ticketPartyBuilding.stage,ticketPartyBuilding.getTotalCreditsReceived(),voteExpiration,forceNext,ticketPartyBuilding.isAskForVotesEnabled());
            addWidget(this.m_votingFrame);
         }
      }
      
      private function updateVotingFrame() : void
      {
         var ticketPartyBuilding:TicketPartyBuilding = null;
         var forceNext:Boolean = false;
         if(this.m_votingFrame)
         {
            ticketPartyBuilding = m_building as TicketPartyBuilding;
            forceNext = Global.player.getSeenFlag(ticketPartyBuilding.getCreditsFeatureName() + COMPLETE_VOTING_SUFFIX + ticketPartyBuilding.stage.toString());
            this.m_votingFrame.update(this.createVotingArray(),ticketPartyBuilding.stage,ticketPartyBuilding.getTotalCreditsReceived(),forceNext,ticketPartyBuilding.isAskForVotesEnabled());
         }
      }
      
      protected function requestCrewVotingRewardLink(event:MouseEvent) : void
      {
         var ticketPartyBuilding:TicketPartyBuilding = m_building as TicketPartyBuilding;
         this.pause();
         ticketPartyBuilding.askForVotes(this.onCompletedAskingForVotes);
      }
      
      protected function onCompletedAskingForVotes() : void
      {
         this.unpause();
         this.updateUI();
      }
      
      private function setupBackgroundAnimations() : void
      {
         var farmItem:FarmItem = null;
         var instance:Object = null;
         var farmItems:Array = this.getBuildingBackgroundFarmItems(this.getNumBackgroundSlots());
         var itemIndex:Number = 0;
         for each(farmItem in farmItems)
         {
            addWidget(new ObjectPreviewFrame(m_window["backgroundFarmItem_" + itemIndex.toString() + "_mc"],farmItem,null,[2]));
            itemIndex++;
         }
         if(m_window.animatedassets_mc != null)
         {
            addWidget(new ZwWidget(m_window.animatedassets_mc));
            (m_window.animatedassets_mc as MovieClip).play();
            for each(instance in m_window.animatedassets_mc)
            {
               if(instance is MovieClip)
               {
                  (instance as MovieClip).play();
               }
            }
         }
      }
      
      private function getNumBackgroundSlots() : Number
      {
         var count:Number = 0;
         while(m_window["backgroundFarmItem_" + count.toString() + "_mc"] != null)
         {
            count++;
         }
         return count;
      }
      
      private function getBuildingBackgroundFarmItems(numItemsToDisplay:Number) : Array
      {
         var farmItemsXML:XMLList = null;
         var index:uint = 0;
         var randIndex:Number = NaN;
         var creditsXml:XML = Global.farmGameSettingsManager.getBuildingCreditsXml(m_building.getCreditsFeatureName());
         var backgroundFarmItemNames:Array = new Array();
         var backgroundFarmItems:Array = new Array();
         if(Boolean(creditsXml) && Boolean(creditsXml.hasOwnProperty("backgroundFarmItems")) && Boolean(creditsXml.backgroundFarmItems))
         {
            farmItemsXML = creditsXml.backgroundFarmItems.children();
            index = 0;
            for(index = 0; index < farmItemsXML.length(); index++)
            {
               if(farmItemsXML[index].name().toString() == "itemName")
               {
                  backgroundFarmItemNames.push(farmItemsXML[index].toString());
               }
            }
            if(numItemsToDisplay > backgroundFarmItemNames.length)
            {
               numItemsToDisplay = backgroundFarmItemNames.length;
            }
            for(index = 0; index < numItemsToDisplay; index++)
            {
               randIndex = Math.floor(Math.random() * backgroundFarmItemNames.length);
               backgroundFarmItems.push(Global.farmGameSettingsManager.getFarmItemByName(backgroundFarmItemNames[randIndex]));
               backgroundFarmItemNames.splice(randIndex,1);
            }
         }
         return backgroundFarmItems;
      }
      
      private function refreshTradeInButton() : void
      {
         var offBoard:Array = null;
         var tradeInItem:FarmItem = null;
         var subtitlePK:String = null;
         var anyRedeem:Boolean = false;
         var ticketPartyBuilding:TicketPartyBuilding = null;
         var ticketsNeeded:Number = NaN;
         if(this.m_tradeInBtn)
         {
            offBoard = this.m_building.getOffBoardingData();
            if(offBoard.hasOwnProperty("tradeInItem") && offBoard.tradeInItem != null)
            {
               tradeInItem = offBoard.tradeInItem;
               subtitlePK = null;
               anyRedeem = false;
               ticketPartyBuilding = m_building as TicketPartyBuilding;
               if(ticketPartyBuilding.isStaged())
               {
                  if(ticketPartyBuilding.inVotingBonusStage())
                  {
                     anyRedeem = true;
                  }
                  else
                  {
                     ticketsNeeded = ticketPartyBuilding.getCumulativeStageReceivedCredits(ticketPartyBuilding.stage) - ticketPartyBuilding.getTotalCreditsReceived();
                     if(ticketsNeeded > 0)
                     {
                        anyRedeem = false;
                     }
                  }
               }
               else
               {
                  anyRedeem = this.m_ticketFlyoutSlotFrame != null ? this.m_ticketFlyoutSlotFrame.isAnyRedeemButtonEnabled() : false;
               }
               if(anyRedeem == true && this.m_tradeInBtn.enabled != false)
               {
                  this.m_tradeInBtn.enabled = false;
                  subtitlePK = RewardCreditsBuilding.getLocalizedKey(m_buildingClassName,"OffBoard_Subtitle",true);
                  if(this.m_tradeInSubTitle != null)
                  {
                     this.m_tradeInSubTitle.text = ZLocUtils.t(subtitlePK,"TradeInInfoRedeemFirst",{"item":ZLocUtils.tk_pk(tradeInItem.friendlyName)});
                  }
               }
               else if(anyRedeem == false && this.m_tradeInBtn.enabled != true)
               {
                  this.m_tradeInBtn.enabled = true;
                  subtitlePK = RewardCreditsBuilding.getLocalizedKey(m_buildingClassName,"OffBoard_Subtitle",true);
                  if(this.m_tradeInSubTitle != null)
                  {
                     this.m_tradeInSubTitle.text = ZLocUtils.t(subtitlePK,"TradeInInfo",{"item":ZLocUtils.tk_pk(tradeInItem.friendlyName)});
                  }
               }
            }
         }
      }
      
      private function unlockLevelCallback(itemName:String) : Boolean
      {
         var result:Boolean = false;
         var ticketPartyBuilding:TicketPartyBuilding = this.m_building as TicketPartyBuilding;
         if(ticketPartyBuilding)
         {
            if(ticketPartyBuilding.canUnlockRedeemPrize(itemName,true))
            {
               FarmStatsManager.count(this.m_building.getItemName(),"return main dialog","unlock","redeem_" + itemName);
               result = ticketPartyBuilding.exeUnlockRedeemPrize(itemName,this);
               if(result == true)
               {
                  this.updateUI();
               }
               else if(Config.DEBUG_MODE)
               {
                  this.close();
               }
            }
         }
         return result;
      }
      
      private function buyItemButtonCallback(itemName:String, expectedPrice:int = 0) : void
      {
         var centerIconUrl:String = null;
         var ticketWindow:TicketPartyWindow = null;
         var goToGiftBoxText:String = null;
         var goToGiftBoxCallback:Function = null;
         var dialog:GenericXMLDialog = null;
         var result:Boolean = false;
         var ticketPartyBuilding:TicketPartyBuilding = this.m_building as TicketPartyBuilding;
         if(ticketPartyBuilding)
         {
            if(ticketPartyBuilding.canBuyRedeemPrize(itemName,true))
            {
               FarmStatsManager.count(this.m_building.getItemName(),"return main dialog","buy","redeem_" + itemName);
               result = ticketPartyBuilding.exeBuyRedeemPrize(itemName);
               if(result == true)
               {
                  centerIconUrl = Global.farmGameSettingsManager.getFarmItemByName(itemName).iconRelativeUrl;
                  ticketWindow = this;
                  goToGiftBoxText = null;
                  goToGiftBoxCallback = null;
                  if(!ticketPartyBuilding.isStaged())
                  {
                     goToGiftBoxText = ZLocUtils.t("Dialogs","GoToGiftBox");
                     goToGiftBoxCallback = function(event:Event):void
                     {
                        var buyFarmItem:FarmItem = null;
                        this.close();
                        ticketWindow.close();
                        if(itemName)
                        {
                           buyFarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
                           if(buyFarmItem)
                           {
                              UI.displayGiftBoxWindow(false,buyFarmItem.friendlyTitle);
                           }
                           else
                           {
                              UI.displayGiftBoxWindow();
                           }
                        }
                        else
                        {
                           UI.displayGiftBoxWindow();
                        }
                     };
                  }
                  else
                  {
                     goToGiftBoxText = ZLocUtils.t("Dialogs","Okay");
                  }
                  dialog = new GenericXMLDialog(ZLocUtils.t("Dialogs","Congratulations"),"",null,centerIconUrl,100,100,ZLocUtils.t("Dialogs","GiftboxFind"),null,true,goToGiftBoxText,goToGiftBoxCallback,null,null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
                  UI.displayPopup(dialog,false);
               }
               else if(Config.DEBUG_MODE)
               {
                  this.close();
               }
            }
         }
      }
      
      private function buyVoteItemButtonCallback(itemName:String, expectedPrice:int = 0) : void
      {
         var centerIconUrl:String = null;
         var dialog:GenericXMLDialog = null;
         var voteItem:Object = null;
         var otherVoteIndex:int = 0;
         var otherVoteItem:Object = null;
         var result:Boolean = false;
         var ticketPartyBuilding:TicketPartyBuilding = this.m_building as TicketPartyBuilding;
         if(ticketPartyBuilding)
         {
            if(ticketPartyBuilding.canBuyVotingPrize(itemName,expectedPrice,true))
            {
               FarmStatsManager.count(this.m_building.getItemName(),"return main dialog","buy","redeem_" + itemName);
               result = ticketPartyBuilding.exeBuyVotingPrize(itemName,expectedPrice);
               if(result == true)
               {
                  centerIconUrl = Global.farmGameSettingsManager.getFarmItemByName(itemName).iconRelativeUrl;
                  dialog = new GenericXMLDialog(ZLocUtils.t("Dialogs","Congratulations"),"",null,centerIconUrl,100,100,ZLocUtils.t("Dialogs","GiftboxFind"),null,true,ZLocUtils.t("Dialogs","Okay"),null,null,null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
                  UI.displayPopup(dialog,false);
                  if(this.m_votingFrame != null)
                  {
                     if(ticketPartyBuilding.inVotingBonusStage())
                     {
                        Global.player.setSeenFlag(m_building.getCreditsFeatureName() + COMPLETE_VOTING_SUFFIX + ticketPartyBuilding.stage.toString(),false,true);
                        voteItem = ticketPartyBuilding.getVoteItemByName(itemName);
                        if(voteItem != null)
                        {
                           otherVoteIndex = voteItem.voteIndex == 0 ? 1 : 0;
                           otherVoteItem = ticketPartyBuilding.getVoteItemByIndexAndVoteIndex(voteItem.index,otherVoteIndex);
                           if(!Global.player.getSeenFlag(ticketPartyBuilding.getRedeemItemSeenFlagName(otherVoteItem.name)))
                           {
                              Global.player.setSeenFlag(ticketPartyBuilding.getRedeemItemSeenFlagName(voteItem.name));
                           }
                           this.m_votingFrame.markPrizeBought(voteItem["voteIndex"]);
                        }
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
      }
      
      private function redeemItemButtonCallback(itemName:String) : void
      {
         var result:Boolean = false;
         var ticketPartyBuilding:TicketPartyBuilding = this.m_building as TicketPartyBuilding;
         if(!ticketPartyBuilding.inVotingBonusStage())
         {
            FarmStatsManager.count(this.m_building.getItemName(),"return main dialog","redeem","redeem_" + itemName);
            result = false;
            if(m_window.hasOwnProperty("redeemanimation_mc") && m_window.redeemanimation_mc != null)
            {
               (m_window.redeemanimation_mc as MovieClip).visible = true;
               (m_window.redeemanimation_mc as MovieClip).gotoAndPlay(0);
            }
            if(ticketPartyBuilding)
            {
               result = ticketPartyBuilding.exeRedeemPrize(itemName);
               if(result == true)
               {
                  if(this.m_ticketFlyoutSlotFrame != null)
                  {
                     this.m_ticketFlyoutSlotFrame.updateFlyouts(m_building.getTotalCreditsReceived());
                  }
                  this.refreshTradeInButton();
                  if(ticketPartyBuilding.inVotingBonusStage())
                  {
                     this.displayVotingFrame();
                  }
               }
               else if(Config.DEBUG_MODE)
               {
                  this.close();
               }
            }
         }
      }
      
      private function redeemVoteItemButtonCallback(itemName:String, voteIndex:int) : void
      {
         var friendSet:FriendSet = null;
         var voters:String = null;
         var friendName:String = null;
         var votesData:Array = null;
         var i:int = 0;
         var result:Boolean = false;
         var ticketPartyBuilding:TicketPartyBuilding = this.m_building as TicketPartyBuilding;
         if(ticketPartyBuilding.inVotingBonusStage())
         {
            FarmStatsManager.count(m_building.getItemName(),"return main dialog","redeem","redeem_" + itemName);
            if(m_window.hasOwnProperty("redeemanimation_mc") && m_window.redeemanimation_mc != null)
            {
               (m_window.redeemanimation_mc as MovieClip).visible = true;
               (m_window.redeemanimation_mc as MovieClip).gotoAndPlay(0);
            }
            if(ticketPartyBuilding)
            {
               friendSet = ticketPartyBuilding.getFriendSet();
               voters = "";
               friendName = "";
               if(friendSet)
               {
                  votesData = friendSet.votingFriendsByIndex(voteIndex);
                  if(votesData.length > 0)
                  {
                     for(i = 0; i < votesData.length; i++)
                     {
                        friendName = Global.friendManager.getFriendName(votesData[i] as String);
                        if(i == 0)
                        {
                           voters = friendName;
                        }
                        else
                        {
                           voters = voters + ", " + friendName;
                        }
                     }
                  }
               }
               result = ticketPartyBuilding.exeRedeemVotingPrize(itemName,voteIndex,voters);
               if(result == true)
               {
                  this.updateUI();
               }
               else if(Config.DEBUG_MODE)
               {
                  this.close();
               }
            }
         }
      }
      
      private function requestTicketsButtonCallback(event:MouseEvent) : void
      {
         if(this.m_firstTimeOpenWindow)
         {
            FarmStatsManager.count(m_building.getItemName(),"first main dialog","ask_for_tickets");
         }
         else
         {
            FarmStatsManager.count(m_building.getItemName(),"return main dialog","ask_for_tickets");
         }
         MFSRequestManager.getInstance().makeAskCreditsRequest(m_buildingClassName,MFSConstants.SOURCE_UI);
      }
      
      private function inviteFriendsButtonCallback(event:MouseEvent) : void
      {
         var ticketPartyBuilding:TicketPartyBuilding = this.m_building as TicketPartyBuilding;
         if(this.m_firstTimeOpenWindow)
         {
            FarmStatsManager.count(m_building.getItemName(),"first main dialog","invite_friends");
         }
         else
         {
            FarmStatsManager.count(m_building.getItemName(),"return main dialog","invite_friends");
         }
         ticketPartyBuilding.inviteFriends();
      }
      
      private function finishVotingAndMoveToNextStage() : void
      {
         var ticketPartyBuilding:TicketPartyBuilding = m_building as TicketPartyBuilding;
         ticketPartyBuilding.finishVoting();
         ticketPartyBuilding.updateStage();
      }
      
      private function votingNextButtonCallback(event:MouseEvent) : void
      {
         this.finishVotingAndMoveToNextStage();
         this.updateUI();
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.m_firstTimeOpenWindow)
         {
            FarmStatsManager.count(m_building.getItemName(),"first main dialog","x_button");
         }
         else
         {
            FarmStatsManager.count(m_building.getItemName(),"return main dialog","x_button");
         }
         this.setTicketCountToStartMeterAt();
         super.onClose(event);
      }
      
      private function tradeInButtonCallback(event:MouseEvent) : void
      {
         var subtitlePK:String = null;
         var tradeInItem:FarmItem = null;
         var message:String = null;
         FarmStatsManager.count(this.m_building.getItemName(),"return main dialog","trade_in","click");
         var offBoard:Array = this.m_building.getOffBoardingData();
         if(offBoard != null && offBoard.hasOwnProperty("isOffBoard") && offBoard["isOffBoard"] == true)
         {
            subtitlePK = RewardCreditsBuilding.getLocalizedKey(m_buildingClassName,"TradeInConfirm",true);
            if(offBoard.hasOwnProperty("tradeInItem") && offBoard.tradeInItem != null)
            {
               tradeInItem = offBoard.tradeInItem;
               message = ZLocUtils.t(subtitlePK,"TradeInConfirm",{"item":ZLocUtils.tk_pk(tradeInItem.friendlyName)});
               UI.displayPopup(new GenericPopup(message,GenericPopup.TYPE_OK,this.onTradeInButtonConfirmed,GenericPopup.GENERIC_ASSET,"",false,true,true),false);
            }
         }
      }
      
      private function onTradeInButtonConfirmed(event:GenericPopupEvent) : void
      {
         var ticketPartyBuilding:TicketPartyBuilding = null;
         var offBoard:Array = null;
         var tradeInItem:FarmItem = null;
         var subtitlePK:String = null;
         var toasterMessage:String = null;
         var icon:String = null;
         var result:Boolean = false;
         if(event.button == GenericPopup.ACCEPT && !this.m_tradeInExecuted)
         {
            FarmStatsManager.count(this.m_building.getItemName(),"return main dialog","trade_in","confirm");
            ticketPartyBuilding = this.m_building as TicketPartyBuilding;
            if(ticketPartyBuilding)
            {
               this.m_tradeInExecuted = true;
               result = ticketPartyBuilding.exeTradeInTicketPartyBuilding();
               if(result == true)
               {
                  this.close();
                  offBoard = this.m_building.getOffBoardingData();
                  if(offBoard.hasOwnProperty("tradeInItem") && offBoard.tradeInItem != null)
                  {
                     tradeInItem = offBoard.tradeInItem;
                     if(tradeInItem != null)
                     {
                        UI.displayGiftBoxWindow(false,tradeInItem.friendlyTitle);
                     }
                     else
                     {
                        UI.displayGiftBoxWindow();
                     }
                     subtitlePK = RewardCreditsBuilding.getLocalizedKey(m_buildingClassName,"TradeInToasterMessage",true);
                     toasterMessage = ZLocUtils.t(subtitlePK,"TradeInToasterMessage",{"item":ZLocUtils.tk_pk(tradeInItem.friendlyName)});
                     icon = tradeInItem.iconUrl;
                     ToasterManager.getInstance().add(new IconToasterWindow(icon,toasterMessage));
                  }
               }
               else if(Config.DEBUG_MODE)
               {
                  this.close();
               }
            }
         }
      }
      
      override protected function displayWhatIsThis(event:Event = null) : void
      {
         var tutorialXML:XML = null;
         var bundle:String = null;
         var bundlePrefix:String = null;
         var assetPrefix:String = null;
         var creditsXML:XML = Global.farmGameSettingsManager.getBuildingCreditsXml(m_building.getCreditsFeatureName());
         if(creditsXML.hasOwnProperty("tutorial"))
         {
            tutorialXML = creditsXML.tutorial[0];
            bundle = m_building.getCreditsFeatureName();
            bundlePrefix = "";
            assetPrefix = "";
            if(tutorialXML.hasOwnProperty("@bundle"))
            {
               bundle = tutorialXML["@bundle"].toString();
            }
            if(tutorialXML.hasOwnProperty("@bundlePrefix"))
            {
               bundlePrefix = tutorialXML["@bundlePrefix"].toString();
            }
            if(tutorialXML.hasOwnProperty("@assetPrefix"))
            {
               assetPrefix = tutorialXML["@assetPrefix"].toString();
            }
            TutorialUI.displayBundleTutorialWindow(bundle,bundlePrefix,assetPrefix,false);
         }
         else
         {
            super.displayWhatIsThis(event);
         }
      }
      
      override public function refreshCreditsMeterAndText() : void
      {
         super.refreshCreditsMeterAndText();
         this.updateUI();
      }
      
      private function rollOutPrizePreviewFrame() : void
      {
         if(this.m_ticketPartyPrizePreviewFrame != null)
         {
            this.m_ticketPartyPrizePreviewFrame.rollOut();
         }
      }
      
      private function forceRollOutPrizePreviewFrame(bForce:Boolean = true) : void
      {
         if(this.m_ticketPartyPrizePreviewFrame != null)
         {
            this.m_ticketPartyPrizePreviewFrame.forceRollOut(bForce);
         }
      }
      
      private function updateUI() : void
      {
         var creditsFeatureName:String = null;
         var bNeedCredits:Boolean = false;
         var bShowCongrats:Boolean = false;
         var baseLevel:Number = NaN;
         var buttonCallbacks:Object = null;
         var redeemItems:Array = null;
         var item:Object = null;
         var bForceRollOut:Boolean = false;
         var iItem:int = 0;
         var slotElementName:String = null;
         var ticketPartyPrize:TicketPartyPrize = null;
         var subtitlePK:String = null;
         var subtitle2PK:String = null;
         var arrVoteItem:Array = null;
         var arrPrizes:Array = null;
         var iVoteItem:int = 0;
         var redeemItemName:String = null;
         var voteItem:Object = null;
         var prize:Object = null;
         var previewCallbacks:Object = null;
         var base:uint = 0;
         var max:uint = 0;
         var current:uint = 0;
         var building:TicketPartyBuilding = m_building as TicketPartyBuilding;
         var totalTickets:Number = building.getTotalCreditsReceived();
         var ticketCount:Number = totalTickets;
         if(this.m_votingFrame != null)
         {
            removeWidget(this.m_votingFrame);
            this.m_votingFrame = null;
         }
         if(building.inVotingBonusStage())
         {
            this.displayVotingFrame();
         }
         var bShowBuy:Boolean = true;
         var bShowAsk:Boolean = true;
         if(building.isStaged())
         {
            creditsFeatureName = building.getCreditsFeatureName();
            bNeedCredits = building.computeBuyCreditsAmount() > 0 ? true : false;
            bShowCongrats = !bNeedCredits;
            baseLevel = building.stage;
            if(baseLevel > 0)
            {
               ticketCount -= building.getCumulativeStageReceivedCredits(baseLevel - 1);
            }
            this.updateStage();
            if(this.m_ticketPartyPrize != null)
            {
               removeWidget(this.m_ticketPartyPrize);
               this.m_ticketPartyPrize = null;
            }
            buttonCallbacks = {
               "unlock":this.unlockLevelCallback,
               "buyItem":this.buyItemButtonCallback,
               "redeemItem":this.redeemItemButtonCallback
            };
            redeemItems = Global.farmGameSettingsManager.getBuildingRewardItems(creditsFeatureName);
            redeemItems.sortOn("index",Array.NUMERIC);
            bForceRollOut = false;
            if(building.hasFinishedAllVoting())
            {
               if(m_window.hasOwnProperty("finish_mc") && m_window.finish_mc != null)
               {
                  if(this.m_finishedPrizeFrame)
                  {
                     removeWidget(this.m_finishedPrizeFrame);
                     this.m_finishedPrizeFrame = null;
                  }
                  this.m_finishedPrizeFrame = new ZwFrame(m_window.finish_mc);
                  for(iItem = 0; iItem < redeemItems.length; iItem++)
                  {
                     item = redeemItems[iItem];
                     slotElementName = "slot_" + iItem.toString() + "_mc";
                     if(Boolean(item) && Boolean(m_window.finish_mc.hasOwnProperty(slotElementName)) && m_window.finish_mc[slotElementName] != null)
                     {
                        ticketPartyPrize = new TicketPartyPrize(m_window.finish_mc[slotElementName],item.name,item.accumulativeCost,item.buyCost,item.icon,item.redeemItemSeenFlag,totalTickets,buttonCallbacks);
                        this.m_finishedPrizeFrame.addWidget(ticketPartyPrize);
                     }
                  }
                  addWidget(this.m_finishedPrizeFrame);
               }
               if(this.m_ticketMeter != null)
               {
                  removeWidget(this.m_ticketMeter);
                  this.m_ticketMeter = null;
               }
               if(this.m_stagedTicketMeter != null)
               {
                  removeWidget(this.m_stagedTicketMeter);
                  this.m_stagedTicketMeter = null;
               }
               bShowBuy = false;
               bShowAsk = false;
               bShowCongrats = false;
               if(this.m_ticketCountTf != null)
               {
                  removeWidget(this.m_ticketCountTf);
                  this.m_ticketCountTf = null;
               }
               if(this.m_ticketLabelTf != null)
               {
                  removeWidget(this.m_ticketLabelTf);
                  this.m_ticketLabelTf = null;
               }
               if(this.m_ticketDescriptionTextField != null)
               {
                  removeWidget(this.m_ticketDescriptionTextField);
                  this.m_ticketDescriptionTextField = null;
               }
               bForceRollOut = true;
               if(this.m_subtitleTextField != null)
               {
                  subtitlePK = RewardCreditsBuilding.getLocalizedKey(m_buildingClassName,"SubtitleComplete");
                  this.m_subtitleTextField.text = ZLocUtils.tk_pk_asTitle(subtitlePK);
               }
               if(this.m_subtitle2TextField != null)
               {
                  subtitle2PK = RewardCreditsBuilding.getLocalizedKey(m_buildingClassName,"Subtitle2Complete");
                  this.m_subtitle2TextField.text = ZLocUtils.tk_pk_asTitle(subtitle2PK);
               }
            }
            else
            {
               if(m_window.hasOwnProperty("slot_0_mc") && m_window.slot_0_mc != null)
               {
                  if(building.stage < redeemItems.length)
                  {
                     item = redeemItems[building.stage];
                     if(item)
                     {
                        this.m_ticketPartyPrize = new TicketPartyPrize(m_window.slot_0_mc,item.name,item.accumulativeCost,item.buyCost,item.icon,item.redeemItemSeenFlag,totalTickets,buttonCallbacks);
                        addWidget(this.m_ticketPartyPrize);
                     }
                  }
               }
               if(!bNeedCredits)
               {
                  bShowBuy = false;
                  bShowAsk = false;
                  bForceRollOut = true;
               }
            }
            if(m_window.hasOwnProperty("prizes_mc") && m_window.prizes_mc != null)
            {
               arrVoteItem = Global.farmGameSettingsManager.getBuildingRewardItems(creditsFeatureName,0,0,"voteItem");
               arrVoteItem.sortOn(["index","voteIndex"],Array.NUMERIC);
               arrPrizes = new Array();
               for(iVoteItem = 0; iVoteItem < arrVoteItem.length; iVoteItem++)
               {
                  voteItem = arrVoteItem[iVoteItem];
                  prize = new Object();
                  prize.itemName = voteItem.name;
                  prize.buyCost = voteItem.buyCost;
                  prize.iconURL = voteItem.icon;
                  prize.locked = building.hasFinishedVotingInStage(voteItem.index) ? false : true;
                  prize.checked = Global.player.getSeenFlag(building.getRedeemItemSeenFlagName(prize.itemName)) ? true : false;
                  arrPrizes.push(prize);
               }
               redeemItemName = redeemItems[building.stage].name;
               if(this.m_ticketPartyPrizePreviewFrame == null)
               {
                  previewCallbacks = {
                     "buyItem":this.buyVoteItemButtonCallback,
                     "redeemItem":this.redeemItemButtonCallback
                  };
                  this.m_ticketPartyPrizePreviewFrame = new TicketPartyPrizePreviewFrame(m_window.prizes_mc,m_building.getCreditsFeatureName(),arrPrizes,previewCallbacks,bShowCongrats,building.hasFinishedAllVoting(),redeemItemName);
                  addWidget(this.m_ticketPartyPrizePreviewFrame);
               }
               else
               {
                  this.m_ticketPartyPrizePreviewFrame.updateSlots(arrPrizes,bShowCongrats,building.hasFinishedAllVoting(),redeemItemName);
               }
            }
         }
         if(this.m_ticketMeter != null)
         {
            this.m_ticketMeter.refreshMeter();
         }
         if(this.m_stagedTicketMeter != null)
         {
            base = uint(building.getCumulativeStageReceivedCredits(building.stage - 1));
            max = building.getCumulativeStageReceivedCredits(building.stage) - base;
            current = building.getTotalCreditsReceived() - base;
            this.m_stagedTicketMeter.refreshMeter(0,max,current);
         }
         if(this.m_ticketFlyoutSlotFrame != null)
         {
            this.m_ticketFlyoutSlotFrame.updateFlyouts(totalTickets);
         }
         if(m_window.hasOwnProperty("buy_bt") && m_window.buy_bt != null)
         {
            if(bShowBuy)
            {
               if(m_buyButton == null)
               {
                  this.buildBuyButton(m_window.buy_bt);
               }
               this.updateBuyButton();
            }
            else if(m_buyButton != null)
            {
               removeWidget(m_buyButton);
               m_buyButton = null;
            }
         }
         if(this.m_ticketDescriptionTextField)
         {
            this.m_ticketDescriptionTextField.visible = bShowBuy;
         }
         if(this.m_askButton != null)
         {
            this.m_askButton.visible = bShowAsk;
         }
         if(this.m_ticketCountTf != null)
         {
            this.m_ticketCountTf.text = ticketCount.toString();
         }
         this.refreshTradeInButton();
         this.forceRollOutPrizePreviewFrame(bForceRollOut);
      }
      
      private function setTicketCountToStartMeterAt() : void
      {
         m_firstTimeOpenArray[m_buildingClassName] = m_building.getTotalCreditsReceived();
      }
      
      private function ticketCountToStartMeterAt() : Number
      {
         var result:Number = 0;
         if(m_firstTimeOpenArray.hasOwnProperty(m_buildingClassName))
         {
            result = Number(m_firstTimeOpenArray[m_buildingClassName]);
         }
         return result;
      }
   }
}

