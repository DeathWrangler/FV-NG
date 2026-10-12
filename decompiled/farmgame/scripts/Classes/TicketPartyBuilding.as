package Classes
{
   import Classes.Constants.MFSConstants;
   import Classes.FeatureDataObjects.FeatureFriendSet;
   import Classes.FeatureDataObjects.FriendSet;
   import Classes.FeatureDataObjects.VotingFeatureFriendSet;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Transactions.TBuyRedeemItem;
   import Transactions.TBuyVoteItem;
   import Transactions.TGenericWorldObjectTransaction;
   import Transactions.TRedeemCreditsItem;
   import Transactions.TRedeemVoteItem;
   import Transactions.TTradeInTicketPartyBuilding;
   import Transactions.TUnlockRedeemItem;
   import Widgets.Windows.ArrowIndicatorWindow;
   import Widgets.Windows.MFSFriendSet;
   import Widgets.Windows.TicketParty.TicketPartyWindow;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.utils.getQualifiedClassName;
   
   public class TicketPartyBuilding extends RewardCreditsBuilding
   {
      
      public const STATE_STAGED_PREFIX:String = "built_";
      
      public const STATE_BASE:String = "built_0";
      
      public const STATE_PROGRESS:String = "built_1";
      
      protected const INVITE_FRIENDS:String = "inviteFriends";
      
      protected var m_friendSet:FeatureFriendSet = null;
      
      protected var m_showingProgression:Boolean = false;
      
      protected var m_friendSetCode:String = "";
      
      private const ARROW_INDICATOR_CHECK_INTERVAL_MS:Number = 3000;
      
      private var m_nextArrowIndicatorCheckTimeMs:Number = 0;
      
      private var m_stage:Number = 0;
      
      private var m_maxStage:Number = 0;
      
      private var m_hasVoteBonusPrizes:Boolean = false;
      
      private var m_redeemItems:Array = null;
      
      private var m_arrRedeemReceivedCredits:Array = null;
      
      protected var m_crewVoteRewardLink:String = "";
      
      private var m_askForVotesFeedPostedCallback:Function = null;
      
      private var m_bFirstTimeUpdate:Boolean = true;
      
      public function TicketPartyBuilding(buildingType:String = null, featureName:String = null)
      {
         var costInfo:CreditCostInfo = null;
         var cumulativeCost:int = 0;
         var creditsXML:XML = null;
         super(buildingType,featureName);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            this.m_friendSetCode = m_item.getStringFromDataSource("featureFriendSet");
         }
         else
         {
            this.m_friendSetCode = m_item.xml.featureFriendSet;
         }
         this.m_redeemItems = Global.farmGameSettingsManager.getBuildingRewardItems(getCreditsFeatureName());
         this.m_redeemItems.sortOn("index",Array.NUMERIC);
         this.m_arrRedeemReceivedCredits = new Array();
         var previousCost:int = 0;
         for(var iItem:int = 0; iItem < this.m_redeemItems.length; iItem++)
         {
            cumulativeCost = previousCost + this.m_redeemItems[iItem].cost["feature"];
            this.m_arrRedeemReceivedCredits.push(cumulativeCost);
            previousCost = cumulativeCost;
         }
         if(null == featureName)
         {
            creditsXML = this.getBuildingCreditsXml();
            this.m_hasVoteBonusPrizes = creditsXML.@voteBonusPrizes.toString() == "true" ? true : false;
            if(creditsXML.@stages)
            {
               this.m_maxStage = parseInt(creditsXML.@stages.toString());
               this.updateStage();
            }
         }
      }
      
      public function getFriendSet() : FriendSet
      {
         return this.m_friendSet;
      }
      
      override public function loadObject(data:Object) : void
      {
         var hasFeatureFriendSet:Boolean = false;
         var fsXML:XML = null;
         super.loadObject(data);
         if(data.hasOwnProperty("friendSet") && Boolean(data.friendSet))
         {
            hasFeatureFriendSet = false;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               hasFeatureFriendSet = m_item.hasPropertyInDataSource("featureFriendSet");
            }
            else
            {
               hasFeatureFriendSet = m_item.xml.hasOwnProperty("featureFriendSet");
            }
            if(hasFeatureFriendSet)
            {
               fsXML = Global.farmGameSettingsManager.getFriendSetXMLByCode(this.m_friendSetCode);
               if(fsXML.hasOwnProperty("dataType") && fsXML.dataType.toString() == "VotingFeatureFriendSet")
               {
                  this.m_friendSet = new VotingFeatureFriendSet(this.m_friendSetCode);
               }
               else
               {
                  this.m_friendSet = new FeatureFriendSet(this.m_friendSetCode);
               }
               this.m_friendSet.onInitialize(data.friendSet);
            }
         }
         this.m_nextArrowIndicatorCheckTimeMs = GlobalEngine.currentTime;
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
         if(this.m_bFirstTimeUpdate)
         {
            this.m_bFirstTimeUpdate = false;
            if(this.isStaged())
            {
               this.updateStage();
               setState(this.STATE_BASE);
            }
         }
         if(this.m_nextArrowIndicatorCheckTimeMs > 0 && GlobalEngine.currentTime > this.m_nextArrowIndicatorCheckTimeMs && GlobalEngine.isServerTimeValid())
         {
            this.checkArrowIndicator();
            if(m_arrow != null)
            {
               this.m_nextArrowIndicatorCheckTimeMs = 0;
            }
            else
            {
               this.m_nextArrowIndicatorCheckTimeMs = GlobalEngine.currentTime + this.ARROW_INDICATOR_CHECK_INTERVAL_MS;
            }
         }
      }
      
      override protected function getDialogText(strPK:String) : String
      {
         var message:String = "";
         var basketPK:String = RewardCreditsBuilding.getBasketFriendlyName(getCreditsFeatureName());
         var itemPK:String = RewardCreditsBuilding.getCreditItemFriendlyName(getCreditsFeatureName());
         if("" != strPK)
         {
            if("" != basketPK && "" != itemPK)
            {
               message = ZLocUtils.t_pk(strPK,null,{
                  "basket":ZLocUtils.tk_pk(basketPK),
                  "item":ZLocUtils.tk_pk(itemPK)
               });
            }
            else
            {
               message = ZLocUtils.t_pk(strPK);
            }
         }
         return message;
      }
      
      override protected function updateToolTipText() : void
      {
         var creditKey:String = null;
         var ticketCount:int = 0;
         var creditName:String = null;
         var completedFriends:int = 0;
         var toolTip:String = "";
         if(isHighlighted())
         {
            if(m_hideArrow || m_arrow == null)
            {
               toolTip += ZLocUtils.tk_pk_asTitle("Items:" + this.m_creditsFeatureName + "_friendlyName") + "\n";
               if(!Global.worldManager.isVisiting())
               {
                  if(!this.inVotingBonusStage())
                  {
                     creditKey = this.m_creditsFeatureName + "_credit_friendlyName";
                     ticketCount = int(getTotalCreditsReceived());
                     if(this.isStaged())
                     {
                        ticketCount = this.getCumulativeStageReceivedCredits(this.stage) - ticketCount;
                        if(ticketCount < 0)
                        {
                           ticketCount = 0;
                        }
                        if(ticketCount > 0)
                        {
                           toolTip += ZLocUtils.t(getLocalizedKey(m_itemName,"NeedMoreCreditsTooltip",true),"NeedMoreCreditsTooltip",{"quantity":ticketCount});
                        }
                        else if(!this.hasRedeemedStagePrize())
                        {
                           toolTip += ZLocUtils.t(getLocalizedKey(m_itemName,"RedeemCreditsTooltip",true),"RedeemCreditsTooltip");
                        }
                     }
                     else
                     {
                        if(ticketCount == 0 || ticketCount > 1)
                        {
                           creditKey += "_plural";
                        }
                        creditName = ZLocUtils.t("Items",creditKey);
                        toolTip += ticketCount + " " + creditName + "\n";
                     }
                  }
                  else if(this.isAskForVotesEnabled())
                  {
                     toolTip += ZLocUtils.t(getLocalizedKey(m_itemName,"VotingBonusStageTooltip",true),"VotingBonusStageTooltip");
                  }
               }
               if(!this.hasVoteBonusPrizes())
               {
                  completedFriends = this.m_friendSet ? this.m_friendSet.numFriendsCompleted : 0;
                  if(completedFriends == 1)
                  {
                     toolTip += completedFriends + " Friend";
                  }
                  else
                  {
                     toolTip += completedFriends + " Friends";
                  }
               }
            }
         }
         setToolTip(toolTip);
         updateToolTipPosition();
      }
      
      private function generateArrowIndicator(friend:Friend, numOthers:int = 0) : DisplayObject
      {
         var result:ArrowIndicatorWindow = null;
         var friendName:String = friend.name;
         var title:String = ZLocUtils.tk_pk_asTitle("Items:" + this.m_creditsFeatureName + "_friendlyName");
         var text:String = "";
         if(numOthers <= 0)
         {
            text = ZLocUtils.t(getLocalizedKey(m_itemName,"ArrowTextSingular",true),"ArrowTextSingular",{"friendName":friendName});
            if(text.length == 0)
            {
               text = ZLocUtils.t("Dialogs",this.m_item.className + "_ArrowTextSingular",{"friendName":friendName});
            }
         }
         else
         {
            text = ZLocUtils.t(getLocalizedKey(m_itemName,"ArrowTextPlural",true),"ArrowTextPlural",{
               "friendName":friendName,
               "numOthers":numOthers
            });
            if(text.length == 0)
            {
               text = ZLocUtils.t("Dialogs",this.m_item.className + "_ArrowTextPlural",{
                  "friendName":friendName,
                  "numOthers":numOthers
               });
            }
         }
         if(friend.picture)
         {
            result = new ArrowIndicatorWindow(friend.picture,title,text,null,true);
         }
         else
         {
            result = new ArrowIndicatorWindow(Player.NO_PROFILE_PIC_URL,title,text,null,true);
         }
         return result;
      }
      
      override protected function checkArrowIndicator() : void
      {
         var numOthers:int = 0;
         var friendData:Friend = null;
         if(!UI.isShowingPopup())
         {
            if(m_arrow == null)
            {
               if(super.canShowPreOffboardArrow())
               {
                  m_arrow = super.generatePreOffBoardingArrowIndicator();
                  this.m_showingProgression = false;
               }
               else if(this.m_friendSet != null && this.m_friendSet.pendingFriends.length > 0)
               {
                  numOthers = this.m_friendSet.pendingFriends.length - 1;
                  friendData = Global.friendManager.getFriendData(this.m_friendSet.pendingFriends[0]);
                  if(Boolean(friendData) && Boolean(friendData.name))
                  {
                     m_arrow = this.generateArrowIndicator(friendData,numOthers);
                     this.m_showingProgression = true;
                  }
               }
            }
            if(m_arrow != null)
            {
               (m_displayObject as Sprite).addChild(m_arrow);
               m_arrow.visible = true;
               super.setArrowPosition();
            }
         }
      }
      
      override public function hideArrowDisplay() : void
      {
         if(Boolean(m_arrow) && Boolean(m_arrow.visible) && m_arrow.parent != null)
         {
            m_arrow.visible = false;
            m_arrow.parent.removeChild(m_arrow);
            m_arrow = null;
            conditionallyRedraw(true);
         }
      }
      
      override public function showMenu() : void
      {
         var offBoard:Array = this.getOffBoardingData();
         if(offBoard == null || !offBoard.hasOwnProperty("isOffBoard") || offBoard["isOffBoard"] != true)
         {
            if(!this.m_hasVoteBonusPrizes || this.inVotingBonusStage() && this.isAskForVotesEnabled())
            {
               m_menuItems.push({
                  "label":ZLocUtils.t(getLocalizedKey(m_itemName,"InviteFriends",true),"InviteFriends"),
                  "action":this.INVITE_FRIENDS
               });
            }
         }
         super.showMenu();
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case this.INVITE_FRIENDS:
                  if(!this.m_hasVoteBonusPrizes)
                  {
                     this.inviteFriends();
                  }
                  else
                  {
                     this.askForVotesWithShareDialog();
                  }
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      public function isAskForVotesEnabled() : Boolean
      {
         var strFeatureFlagName:String = m_creditsFeatureName + "_lastAskForVotes";
         var lastAskTimeInSec:Number = Global.player.getFeatureLastShown(strFeatureFlagName);
         var askFeatureFrequencyInSec:Number = Global.farmGameSettingsManager.getNumber(m_creditsFeatureName + "AskForVotesFeatureFrequency",2 * FarmGameUtil.NUM_SECS_IN_HOUR);
         var currentTimeInSec:Number = GlobalEngine.serverTime / 1000;
         return currentTimeInSec > lastAskTimeInSec + askFeatureFrequencyInSec;
      }
      
      public function askForVotesWithShareDialog(askForVotesFeedPostedCallback:Function = null) : void
      {
         this.m_askForVotesFeedPostedCallback = askForVotesFeedPostedCallback;
         if(this.isAskForVotesEnabled())
         {
            TransactionManager.addTransaction(new TGenericWorldObjectTransaction(this,"generateCrewVotingReward",this.displayCrewVotingDialog),true);
         }
         else if(this.m_askForVotesFeedPostedCallback != null)
         {
            this.m_askForVotesFeedPostedCallback();
            this.m_askForVotesFeedPostedCallback = null;
         }
      }
      
      public function askForVotes(askForVotesFeedPostedCallback:Function = null) : void
      {
         this.m_askForVotesFeedPostedCallback = askForVotesFeedPostedCallback;
         if(this.isAskForVotesEnabled())
         {
            TransactionManager.addTransaction(new TGenericWorldObjectTransaction(this,"generateCrewVotingReward",this.getRewardLinkAndPostCrewVotingFeedShare),true);
         }
         else if(this.m_askForVotesFeedPostedCallback != null)
         {
            this.m_askForVotesFeedPostedCallback();
            this.m_askForVotesFeedPostedCallback = null;
         }
      }
      
      public function clearAskForVotesFeedPostedCallback() : void
      {
         this.m_askForVotesFeedPostedCallback = null;
      }
      
      protected function displayCrewVotingDialog(data:Object) : void
      {
         var messageName:String = null;
         var message:String = null;
         var iconPopup:GenericIconPopup = null;
         if(data.hasOwnProperty("rewardUrl"))
         {
            this.m_crewVoteRewardLink = data.rewardUrl + "&feature=" + m_creditsFeatureName;
            messageName = m_creditsFeatureName + "_crewVoteDialog";
            message = ZLocUtils.t("Dialogs",messageName);
            iconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShareCrewVote,Global.getAssetURL(this.getCrewVotingFeedIcon()));
            UI.displayPopup(iconPopup,false);
         }
         else if(this.m_askForVotesFeedPostedCallback != null)
         {
            this.m_askForVotesFeedPostedCallback();
            this.m_askForVotesFeedPostedCallback = null;
         }
      }
      
      protected function getRewardLinkAndPostCrewVotingFeedShare(data:Object) : void
      {
         if(data.hasOwnProperty("rewardUrl"))
         {
            this.m_crewVoteRewardLink = data.rewardUrl + "&feature=" + m_creditsFeatureName;
            this.postCrewVotingFeedShare();
         }
         else if(this.m_askForVotesFeedPostedCallback != null)
         {
            this.m_askForVotesFeedPostedCallback();
            this.m_askForVotesFeedPostedCallback = null;
         }
      }
      
      protected function getCrewVotingFeedIcon() : String
      {
         return getBuildingImageUrl("crewVotingFeedIcon");
      }
      
      protected function onShareCrewVote(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.postCrewVotingFeedShare();
         }
      }
      
      protected function postCrewVotingFeedShare() : void
      {
         var currentTimeInSec:Number = GlobalEngine.serverTime / 1000;
         var strFeatureFlagName:String = m_creditsFeatureName + "_lastAskForVotes";
         Global.player.setFeatureLastShown(strFeatureFlagName,currentTimeInSec,true);
         var bundleData:Object = {
            "reward_link":this.m_crewVoteRewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + this.m_crewVoteRewardLink,
               "src":Global.getAssetURL(this.getCrewVotingFeedIcon())
            }]
         };
         var messageType:String = m_creditsFeatureName + "CrewVoting_" + this.stage.toString();
         GlobalEngine.socialNetwork.publishFeedStory(messageType,bundleData,[],false);
         if(this.m_askForVotesFeedPostedCallback != null)
         {
            this.m_askForVotesFeedPostedCallback();
            this.m_askForVotesFeedPostedCallback = null;
         }
      }
      
      public function inviteFriends() : void
      {
         var noGameId:Number = -2;
         var reqItemCrew:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.getItemName());
         var friendSpec:Object = {
            "tabNameSuggested":[MFSConstants.TYPE_SUGGESTED],
            "tabNameFarmVille":[MFSConstants.TYPE_FARMVILLE],
            "tabNameFacebook":[MFSConstants.TYPE_FACEBOOK]
         };
         var friendTabOrder:Array = ["tabNameSuggested","tabNameFarmVille","tabNameFacebook"];
         UI.displayPopup(new MFSFriendSet(friendSpec,friendTabOrder,reqItemCrew,m_creditsFeatureName,this.m_friendSetCode,String(noGameId),"",null),false);
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         var arrowIndicatorWindow:ArrowIndicatorWindow = null;
         if(Global.selectedAvatar)
         {
            setHighlighted(true);
            if(!m_hideArrow)
            {
               if(m_arrow)
               {
                  arrowIndicatorWindow = m_arrow as ArrowIndicatorWindow;
                  if(arrowIndicatorWindow)
                  {
                     arrowIndicatorWindow.showRolloverText(true);
                  }
               }
            }
         }
         super.onMouseOver(event);
      }
      
      override public function onMouseOut() : void
      {
         setHighlighted(false);
         if(m_arrow)
         {
            (m_arrow as ArrowIndicatorWindow).showRolloverText(false);
         }
         super.onMouseOut();
      }
      
      override public function onClick() : void
      {
         FarmStatsManager.count(m_creditsFeatureName,"clicked");
         this.onMouseOut();
         if(m_arrow)
         {
            this.hideArrowDisplay();
            if(this.m_showingProgression)
            {
               if(this.m_friendSet)
               {
                  this.m_friendSet.markSeen();
               }
               m_hideArrow = true;
            }
            setState(this.STATE_BASE);
            this.displayStorageDialog();
         }
         else if(Global.selectedAvatar)
         {
            if(Global.worldManager.isVisiting())
            {
               super.onClick();
            }
            else
            {
               m_menuItems = [];
               this.showMenu();
            }
         }
         else
         {
            super.onClick();
         }
      }
      
      override public function getCurrentImageName() : String
      {
         var imageName:String = null;
         if(this.isStaged())
         {
            imageName = this.STATE_STAGED_PREFIX + this.stage.toString();
         }
         else if(m_arrow)
         {
            imageName = this.STATE_PROGRESS;
         }
         else
         {
            imageName = this.STATE_BASE;
         }
         return imageName;
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         var swfUrl:String = null;
         var showWhatIsThis:Boolean = false;
         var showCrewProgressFeed:Boolean = false;
         var data:XML = getBuildingCreditsXml();
         if(data)
         {
            swfUrl = getLookInsideDialogSwfUrl();
            showWhatIsThis = getShowWhatIsThis();
            showCrewProgressFeed = this.m_showingProgression;
            UI.displayPopup(new TicketPartyWindow(this,m_creditsFeatureName,swfUrl,showWhatIsThis,showCrewProgressFeed),false);
            m_showRedeemableItemOnLoad = null;
            this.m_showingProgression = false;
         }
      }
      
      override protected function attemptShowEnoughCreditsToRedeemPrompt() : Boolean
      {
         return false;
      }
      
      override protected function showStateChangeFeedPrompt() : void
      {
         if(this.isStaged())
         {
            super.showStateChangeFeedPrompt();
         }
      }
      
      override protected function doPastNeighborAction(passNeighborUid:String) : void
      {
      }
      
      public function getRedeemItemSeenFlagName(redeemItemName:String) : String
      {
         return this.getItemName() + "_redeemed_" + redeemItemName;
      }
      
      public function get stage() : int
      {
         return this.m_stage;
      }
      
      public function get maxStage() : int
      {
         return this.m_maxStage;
      }
      
      public function isStaged() : Boolean
      {
         return this.m_maxStage > 0;
      }
      
      public function updateStage() : void
      {
         for(var iStage:Number = 0; iStage < this.m_maxStage; iStage++)
         {
            this.m_stage = iStage;
            if(!this.hasRedeemedStagePrize())
            {
               break;
            }
            if(this.inVotingBonusStage())
            {
               break;
            }
         }
         setState(this.STATE_BASE);
      }
      
      public function finishVoting() : void
      {
         Global.player.setSeenFlag(this.getItemName() + "_voted_" + this.m_stage,false,true);
         Global.player.setFeatureLastShown(m_creditsFeatureName + "_lastAskForVotes",0,false);
         TransactionManager.addTransaction(new TGenericWorldObjectTransaction(this,"finishVoting"),true);
      }
      
      public function hasVoteBonusPrizes() : Boolean
      {
         return this.m_hasVoteBonusPrizes;
      }
      
      public function get votesNeededForPrize() : int
      {
         return 4;
      }
      
      public function hasRedeemedStagePrize() : Boolean
      {
         return Global.player.getSeenFlag(this.getRedeemItemSeenFlagName(this.m_redeemItems[this.m_stage].name));
      }
      
      public function hasFinishedVotingInStage(stage:int) : Boolean
      {
         return Global.player.getSeenFlag(this.getItemName() + "_voted_" + stage.toString());
      }
      
      public function inVotingBonusStage() : Boolean
      {
         return this.m_hasVoteBonusPrizes && this.hasRedeemedStagePrize() && !this.hasFinishedVotingInStage(this.m_stage);
      }
      
      public function hasFinishedAllVoting() : Boolean
      {
         var result:Boolean = false;
         if(this.isStaged() && this.m_stage == this.m_maxStage - 1)
         {
            if(this.m_hasVoteBonusPrizes)
            {
               if(this.hasFinishedVotingInStage(this.m_stage))
               {
                  result = true;
               }
            }
            else if(this.hasRedeemedStagePrize())
            {
               result = true;
            }
         }
         return result;
      }
      
      override protected function isAskCreditsContextMenuDisabled() : Boolean
      {
         if(this.isStaged() && (this.inVotingBonusStage() || this.hasFinishedAllVoting()))
         {
            return true;
         }
         return super.isAskCreditsContextMenuDisabled();
      }
      
      override protected function isSendCreditsContextMenuDisabled() : Boolean
      {
         if(this.isStaged() && (this.inVotingBonusStage() || this.hasFinishedAllVoting()))
         {
            return true;
         }
         return super.isSendCreditsContextMenuDisabled();
      }
      
      public function computeBuyCreditsAmount(maxCreditsToOffer:int = -1) : int
      {
         var pack:Object = null;
         var ticketsNeeded:Number = NaN;
         var arrPack:Array = [{
            "min":70,
            "credits":20
         },{
            "min":20,
            "max":70,
            "credits":15
         },{
            "min":15,
            "max":20,
            "credits":10
         }];
         if(this.isStaged())
         {
            arrPack.push({
               "min":5,
               "max":15,
               "credits":5
            });
            arrPack.push({"credits":1});
         }
         else
         {
            arrPack.push({"credits":5});
         }
         var creditQuantity:int = 0;
         var iPack:int = 0;
         var iLastPack:int = arrPack.length - 1;
         var walletSize:int = Global.player.cash;
         while(iPack < iLastPack)
         {
            pack = arrPack[iPack];
            if((!pack.hasOwnProperty("min") || walletSize >= pack.min) && (!pack.hasOwnProperty("max") || walletSize < pack.max))
            {
               break;
            }
            iPack++;
         }
         if(maxCreditsToOffer > 1)
         {
            while(iPack < iLastPack)
            {
               if(arrPack[iPack].credits <= maxCreditsToOffer)
               {
                  break;
               }
               iPack++;
            }
         }
         if(this.isStaged())
         {
            ticketsNeeded = this.getCumulativeStageReceivedCredits(this.stage) - getTotalCreditsReceived();
            if(ticketsNeeded < 0)
            {
               ticketsNeeded = 0;
            }
            while(iPack < arrPack.length)
            {
               pack = arrPack[iPack];
               if(arrPack[iPack].credits <= ticketsNeeded)
               {
                  break;
               }
               iPack++;
            }
         }
         if(iPack <= iLastPack)
         {
            creditQuantity = int(arrPack[iPack].credits);
         }
         else
         {
            creditQuantity = 0;
         }
         return creditQuantity;
      }
      
      override protected function getCreditsToBuyFromContextMenu() : int
      {
         if(this.isStaged())
         {
            if(this.inVotingBonusStage() || this.hasFinishedAllVoting())
            {
               return 0;
            }
            return this.computeBuyCreditsAmount();
         }
         return super.getCreditsToBuyFromContextMenu();
      }
      
      public function canRedeemPrize(prizeName:String) : Boolean
      {
         var seenFlag:String = null;
         var prizeRedeemItemData:Object = null;
         var canAffordTotalData:CreditCostInfo = null;
         var cost:Object = null;
         var canAffordCostData:CreditCostInfo = null;
         var result:Boolean = false;
         var debuggingThisFunction:Boolean = Config.DEBUG_MODE;
         var prizeItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(prizeName);
         if(prizeItem != null)
         {
            if(prizeItem.checkDateGate() && prizeItem.isInExperiment)
            {
               seenFlag = this.getRedeemItemSeenFlagName(prizeName);
               if(!Global.player.getSeenFlag(seenFlag))
               {
                  prizeRedeemItemData = this.getRedeemItemByName(prizeName);
                  if(prizeRedeemItemData.hasOwnProperty("index"))
                  {
                     canAffordTotalData = getRedeemItemTotalCostInfo(prizeRedeemItemData.index);
                     if(canAffordTotalData.canAfford)
                     {
                        cost = prizeRedeemItemData.cost;
                        canAffordCostData = getRedeemItemCostInfo(cost);
                        if(canAffordCostData.canAfford)
                        {
                           result = true;
                        }
                        else if(debuggingThisFunction)
                        {
                           UI.displayMessage("Dear QA: Did you reset your redeem seenflags, but forget to reset your freature building credits?");
                           UI.displayMessage(getQualifiedClassName(this) + "::canRedeemPrize(" + prizeName + "): user does not have enough *current* credits. ");
                        }
                     }
                     else if(debuggingThisFunction)
                     {
                        UI.displayMessage(getQualifiedClassName(this) + "::canRedeemPrize(" + prizeName + "): user does not have enough *total* credits");
                     }
                  }
                  else if(debuggingThisFunction)
                  {
                     UI.displayMessage(getQualifiedClassName(this) + "::canRedeemPrize(" + prizeName + "): redeemItem data missing index");
                  }
               }
               else if(debuggingThisFunction)
               {
                  UI.displayMessage(getQualifiedClassName(this) + "::canRedeemPrize(" + prizeName + "): seenFlag already present: " + seenFlag);
               }
            }
            else if(debuggingThisFunction)
            {
               UI.displayMessage(getQualifiedClassName(this) + "::canRedeemPrize(" + prizeName + "): failed data-gate or experiement-gate");
            }
         }
         else if(debuggingThisFunction)
         {
            UI.displayMessage(getQualifiedClassName(this) + "::canRedeemPrize(" + prizeName + "): invalid redeemItem or building");
         }
         return result;
      }
      
      public function exeRedeemPrize(prizeName:String) : Boolean
      {
         var redeemObject:Object = null;
         var costInfo:CreditCostInfo = null;
         var creditName:String = null;
         var numCreditsToUse:int = 0;
         var creditType:String = null;
         var seenFlag:String = null;
         var result:Boolean = false;
         if(this.canRedeemPrize(prizeName))
         {
            redeemObject = this.getRedeemItemByName(prizeName);
            costInfo = getRedeemItemCostInfo(redeemObject.cost);
            TransactionManager.addTransaction(new TRedeemCreditsItem(this,prizeName,costInfo.totalCreditCost,false,null),true);
            for each(creditType in redeemObject.cost)
            {
               creditName = creditType == "feature" ? m_creditsFeatureName : creditType;
               this.useCredits(redeemObject.cost[creditType],creditName);
            }
            Global.player.addGift(prizeName,"0",1);
            seenFlag = this.getRedeemItemSeenFlagName(prizeName);
            Global.player.setSeenFlag(seenFlag,false,true);
            result = true;
         }
         return result;
      }
      
      public function canBuyRedeemPrize(prizeName:String, promptUserToBuyWithFarmcash:Boolean = false) : Boolean
      {
         var seenFlag:String = null;
         var prizeRedeemItemData:Object = null;
         var affordData:CreditCostInfo = null;
         var result:Boolean = false;
         var debuggingThisFunction:Boolean = Config.DEBUG_MODE;
         var prizeItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(prizeName);
         if(prizeItem != null)
         {
            if(prizeItem.checkDateGate() && prizeItem.isInExperiment)
            {
               seenFlag = this.getRedeemItemSeenFlagName(prizeName);
               if(Global.player.getSeenFlag(seenFlag))
               {
                  prizeRedeemItemData = this.getRedeemItemByName(prizeName);
                  if(prizeRedeemItemData.hasOwnProperty("index"))
                  {
                     affordData = getRedeemItemTotalCostInfo(prizeRedeemItemData.index);
                     if(affordData.canAfford)
                     {
                        if(prizeRedeemItemData.hasOwnProperty("buyCost") && prizeRedeemItemData.buyCost > 0 && Global.player.canBuyCash(prizeRedeemItemData.buyCost,promptUserToBuyWithFarmcash))
                        {
                           result = true;
                        }
                        else if(!promptUserToBuyWithFarmcash)
                        {
                           if(debuggingThisFunction)
                           {
                              UI.displayMessage(getQualifiedClassName(this) + "::canBuyRedeemPrize(" + prizeName + "): user does not have enough cash");
                           }
                        }
                     }
                     else if(debuggingThisFunction)
                     {
                        UI.displayMessage(getQualifiedClassName(this) + "::canBuyRedeemPrize(" + prizeName + "): user does not have enough *total* credits");
                     }
                  }
                  else if(debuggingThisFunction)
                  {
                     UI.displayMessage(getQualifiedClassName(this) + "::canBuyRedeemPrize(" + prizeName + "): redeemItem data missing index");
                  }
               }
               else if(debuggingThisFunction)
               {
                  UI.displayMessage(getQualifiedClassName(this) + "::canBuyRedeemPrize(" + prizeName + "): seenFlag NOT already present: " + seenFlag);
               }
            }
            else if(debuggingThisFunction)
            {
               UI.displayMessage(getQualifiedClassName(this) + "::canBuyRedeemPrize(" + prizeName + "): failed data-gate or experiement-gate");
            }
         }
         else if(debuggingThisFunction)
         {
            UI.displayMessage(getQualifiedClassName(this) + "::canBuyRedeemPrize(" + prizeName + "): invalid redeemItem or building");
         }
         return result;
      }
      
      public function exeBuyRedeemPrize(prizeName:String) : Boolean
      {
         var redeemObject:Object = null;
         var result:Boolean = false;
         if(this.canBuyRedeemPrize(prizeName))
         {
            redeemObject = this.getRedeemItemByName(prizeName);
            TransactionManager.addTransaction(new TBuyRedeemItem(this,prizeName,false,null),true);
            Global.player.cash -= redeemObject.buyCost;
            Global.player.addGift(prizeName,"0",1);
            result = true;
         }
         return result;
      }
      
      public function canUnlockRedeemPrize(prizeName:String, promptUserToBuyWithFarmcash:Boolean = false) : Boolean
      {
         var seenFlag:String = null;
         var prizeRedeemItemData:Object = null;
         var affordData:CreditCostInfo = null;
         var result:Boolean = false;
         var debuggingThisFunction:Boolean = Config.DEBUG_MODE;
         var prizeItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(prizeName);
         if(prizeItem != null)
         {
            if(prizeItem.checkDateGate() && prizeItem.isInExperiment)
            {
               seenFlag = this.getRedeemItemSeenFlagName(prizeName);
               if(!Global.player.getSeenFlag(seenFlag))
               {
                  prizeRedeemItemData = this.getRedeemItemByName(prizeName);
                  if(prizeRedeemItemData.hasOwnProperty("index"))
                  {
                     affordData = getRedeemItemTotalCostInfo(prizeRedeemItemData.index);
                     if(affordData.costToComplete > 0 && Global.player.canBuyCash(affordData.costToComplete,promptUserToBuyWithFarmcash))
                     {
                        result = true;
                     }
                     else if(!promptUserToBuyWithFarmcash)
                     {
                        if(debuggingThisFunction)
                        {
                           UI.displayMessage(getQualifiedClassName(this) + "::canUnlockRedeemPrize(" + prizeName + "): user does not have enough *total* credits or cash");
                        }
                     }
                  }
                  else if(debuggingThisFunction)
                  {
                     UI.displayMessage(getQualifiedClassName(this) + "::canUnlockRedeemPrize(" + prizeName + "): redeemItem data missing index");
                  }
               }
               else if(debuggingThisFunction)
               {
                  UI.displayMessage(getQualifiedClassName(this) + "::canUnlockRedeemPrize(" + prizeName + "): seenFlag already present: " + seenFlag);
               }
            }
            else if(debuggingThisFunction)
            {
               UI.displayMessage(getQualifiedClassName(this) + "::canUnlockRedeemPrize(" + prizeName + "): failed data-gate or experiement-gate");
            }
         }
         else if(debuggingThisFunction)
         {
            UI.displayMessage(getQualifiedClassName(this) + "::canUnlockRedeemPrize(" + prizeName + "): invalid redeemItem or building");
         }
         return result;
      }
      
      public function exeUnlockRedeemPrize(prizeName:String, window:TicketPartyWindow = null) : Boolean
      {
         var redeemObject:Object = null;
         var canAffordData:CreditCostInfo = null;
         var creditType:String = null;
         var result:Boolean = false;
         if(this.canUnlockRedeemPrize(prizeName))
         {
            redeemObject = this.getRedeemItemByName(prizeName);
            TransactionManager.addTransaction(new TUnlockRedeemItem(this,prizeName,false,null),true);
            canAffordData = getRedeemItemTotalCostInfo(redeemObject.index);
            if(canAffordData.costToComplete > 0 && Global.player.cash >= canAffordData.costToComplete)
            {
               Global.player.cash -= canAffordData.costToComplete;
               for(creditType in canAffordData.missingCredits)
               {
                  this.addCredits(canAffordData.missingCredits[creditType],creditType);
               }
            }
            result = true;
         }
         return result;
      }
      
      public function canRedeemVotingPrize(prizeName:String, voteIndex:int) : Boolean
      {
         var seenFlag:String = null;
         var result:Boolean = false;
         var prizeItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(prizeName);
         if(prizeItem != null)
         {
            if(prizeItem.checkDateGate() && prizeItem.isInExperiment)
            {
               seenFlag = this.getRedeemItemSeenFlagName(prizeName);
               if(!Global.player.getSeenFlag(seenFlag))
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      public function exeRedeemVotingPrize(prizeName:String, voteIndex:int, voters:String) : Boolean
      {
         var seenFlag:String = null;
         var result:Boolean = false;
         if(this.canRedeemVotingPrize(prizeName,voteIndex))
         {
            TransactionManager.addTransaction(new TRedeemVoteItem(this,prizeName,voteIndex,voters),true);
            Global.player.addGift(prizeName,"0",1);
            seenFlag = this.getRedeemItemSeenFlagName(prizeName);
            Global.player.setSeenFlag(seenFlag,false,true);
            result = true;
         }
         return result;
      }
      
      public function getVoteItemByName(paramName:String) : Object
      {
         var voteItem:Object = null;
         var voteItems:Array = Global.farmGameSettingsManager.getBuildingRewardItems(this.m_creditsFeatureName,0,0,"voteItem");
         var result:Object = null;
         for(var curItem:Number = 0; curItem < voteItems.length; curItem++)
         {
            voteItem = voteItems[curItem];
            if(voteItem.name == paramName)
            {
               result = voteItem;
               break;
            }
         }
         return result;
      }
      
      public function getVoteItemByIndexAndVoteIndex(index:int, voteIndex:int) : Object
      {
         var voteItem:Object = null;
         var voteItems:Array = Global.farmGameSettingsManager.getBuildingRewardItems(this.m_creditsFeatureName,0,0,"voteItem");
         var result:Object = null;
         for(var curItem:Number = 0; curItem < voteItems.length; curItem++)
         {
            voteItem = voteItems[curItem];
            if(voteItem.index == index && voteItem.voteIndex == voteIndex)
            {
               result = voteItem;
               break;
            }
         }
         return result;
      }
      
      public function canBuyVotingPrize(prizeName:String, expectedPrice:int, promptUserToBuyWithFarmcash:Boolean = false) : Boolean
      {
         var voteItem:Object = null;
         var result:Boolean = false;
         var debuggingThisFunction:Boolean = Config.DEBUG_MODE;
         var prizeItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(prizeName);
         if(prizeItem != null)
         {
            if(prizeItem.checkDateGate() && prizeItem.isInExperiment)
            {
               voteItem = this.getVoteItemByName(prizeName);
               if(voteItem.hasOwnProperty("index"))
               {
                  if(expectedPrice > 0 && Global.player.canBuyCash(expectedPrice,promptUserToBuyWithFarmcash))
                  {
                     result = true;
                  }
                  else if(!promptUserToBuyWithFarmcash)
                  {
                     if(debuggingThisFunction)
                     {
                        UI.displayMessage(getQualifiedClassName(this) + "::canBuyVotingPrize(" + prizeName + "): user does not have enough cash");
                     }
                  }
               }
               else if(debuggingThisFunction)
               {
                  UI.displayMessage(getQualifiedClassName(this) + "::canBuyVotingPrize(" + prizeName + "): voteItem data missing index");
               }
            }
            else if(debuggingThisFunction)
            {
               UI.displayMessage(getQualifiedClassName(this) + "::canBuyVotingPrize(" + prizeName + "): failed data-gate or experiement-gate");
            }
         }
         else if(debuggingThisFunction)
         {
            UI.displayMessage(getQualifiedClassName(this) + "::canBuyVotingPrize(" + prizeName + "): invalid redeemItem or building");
         }
         return result;
      }
      
      public function exeBuyVotingPrize(prizeName:String, expectedPrice:int) : Boolean
      {
         var voteObject:Object = null;
         var result:Boolean = false;
         if(this.canBuyVotingPrize(prizeName,expectedPrice))
         {
            voteObject = this.getVoteItemByName(prizeName);
            TransactionManager.addTransaction(new TBuyVoteItem(this,prizeName,expectedPrice,null),true);
            Global.player.cash -= expectedPrice;
            Global.player.addGift(prizeName,"0",1);
            result = true;
         }
         return result;
      }
      
      public function canTradeInTicketPartyBuilding() : Boolean
      {
         var result:Boolean = false;
         var debuggingThisFunction:Boolean = Config.DEBUG_MODE;
         var offBoard:Array = getOffBoardingData();
         if(offBoard != null && offBoard.hasOwnProperty("isOffBoard") && offBoard["isOffBoard"] == true && offBoard.hasOwnProperty("tradeInItem") && offBoard.tradeInItem != null)
         {
            result = true;
         }
         else if(debuggingThisFunction)
         {
            UI.displayMessage(getQualifiedClassName(this) + "::canTradeInTicketPartyBuilding(): NOT isOffBoard or No tradeInItem");
         }
         return result;
      }
      
      public function exeTradeInTicketPartyBuilding() : Boolean
      {
         var offBoard:Array = null;
         var tradeInItem:FarmItem = null;
         var result:Boolean = false;
         if(this.canTradeInTicketPartyBuilding())
         {
            onSell();
            TransactionManager.addTransaction(new TTradeInTicketPartyBuilding(this),true);
            detach();
            offBoard = getOffBoardingData();
            if(offBoard.hasOwnProperty("tradeInItem") && offBoard.tradeInItem != null)
            {
               tradeInItem = offBoard.tradeInItem;
               Global.player.addGift(tradeInItem.name,"0",1);
            }
            result = true;
         }
         return result;
      }
      
      public function getCumulativeStageReceivedCredits(iStage:int) : int
      {
         var iMaxStage:int = 0;
         var nCredits:int = 0;
         if(iStage >= 0)
         {
            iMaxStage = this.maxStage;
            if(iStage < iMaxStage)
            {
               nCredits = int(this.m_arrRedeemReceivedCredits[iStage]);
            }
            else if(iMaxStage > 0)
            {
               nCredits = int(this.m_arrRedeemReceivedCredits[iMaxStage - 1]);
            }
         }
         return nCredits;
      }
   }
}

