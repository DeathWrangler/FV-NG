package Classes.FeatureComponents
{
   import Classes.Constants.Experiments;
   import Classes.FeatureDataObjects.FriendSet;
   import Classes.FeatureDataObjects.VotingDataObject;
   import Classes.FeatureDataObjects.VotingFeatureFriendSet;
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.FarmGameWorldEvent;
   import Managers.FarmStatsManager;
   import Managers.TemplateUIUtility;
   import Managers.VotingDataManager;
   import Transactions.TransactionWithCallBack;
   import Transactions.Voting.TAskForVotePublish;
   import Transactions.Voting.TAwardVotePrize;
   import Transactions.Voting.TBuyVoteItem;
   import Transactions.Voting.TRedeemVoteItem;
   import Widgets.Windows.Voting.PostVotingWindow;
   import Widgets.Windows.Voting.VotingWindow;
   import flash.events.Event;
   import flash.utils.getQualifiedClassName;
   
   public class VotingComponent
   {
      
      public static const VOTING_STATE_CHANGE:String = "voting_state_change";
      
      public static const FEATURE_COUNTER:String = "feature_survey";
      
      public static const VOTING_PACKAGE:String = "Voting";
      
      private var m_askForVotesFeedPostedCallback:Function = null;
      
      protected var m_feedPublishFailCallback:Function;
      
      protected var m_crewVoteRewardLink:String = "";
      
      protected var m_friendSetInitializing:Boolean = false;
      
      private var m_context:MapResource;
      
      private var m_votingWindow:VotingWindow;
      
      private var m_postVotingWindow:PostVotingWindow;
      
      private var m_featureName:String;
      
      public function VotingComponent(inContext:MapResource)
      {
         super();
         this.m_context = inContext;
         this.m_featureName = this.m_context.getItemName();
      }
      
      public static function getLocalizedKey(buildingName:String, key:String, onlyReturnPackage:Boolean = false) : String
      {
         var pkg_result:String = "";
         var key_result:String = "";
         if(ZLocUtils.hasString(VOTING_PACKAGE,buildingName + "_" + key))
         {
            pkg_result = VOTING_PACKAGE;
            key_result = buildingName + "_" + key;
         }
         else if(ZLocUtils.hasString(VOTING_PACKAGE,key))
         {
            pkg_result = VOTING_PACKAGE;
            key_result = key;
         }
         else if(ZLocUtils.hasString("Dialogs",key))
         {
            pkg_result = "Dialogs";
            key_result = key;
         }
         var result:String = "";
         if(onlyReturnPackage)
         {
            result = pkg_result;
         }
         else
         {
            result = pkg_result + ":" + key_result;
         }
         return result;
      }
      
      public static function getConfigData(featureName:String, tag:String) : String
      {
         var value:String = null;
         var xml:XML = Global.farmGameSettingsManager.getFeatureXML(featureName);
         if(xml)
         {
            value = xml.attribute(tag);
         }
         return value;
      }
      
      public function displayDialog() : void
      {
         var friendSetCode:String = null;
         var friendSet:VotingFeatureFriendSet = null;
         var data:XML = this.getGameSettingsXml();
         if(Boolean(data) && Boolean(!this.m_friendSetInitializing) && this.isFeatureOptionDataLoaded)
         {
            if(VotingDataManager.getInstance().getDataObject(this.context.getItemName()).friendSet == null)
            {
               if(data.hasOwnProperty("friendSet"))
               {
                  friendSetCode = data.friendSet;
                  friendSet = new VotingFeatureFriendSet(friendSetCode,-2,this.onInitializeFriendSet);
                  friendSet.initializeData();
                  this.m_friendSetInitializing = true;
               }
            }
            else
            {
               this.showVotingWindow();
            }
         }
      }
      
      private function get isFeatureOptionDataLoaded() : Boolean
      {
         return Boolean(Global.player) && Global.player.isDataLoaded;
      }
      
      private function onInitializeFriendSet(friendSet:FriendSet, result:Object) : void
      {
         this.m_friendSetInitializing = false;
         if(Boolean(result) && !result.hasOwnProperty("error"))
         {
            VotingDataManager.getInstance().getDataObject(this.context.getItemName()).friendSet = friendSet as VotingFeatureFriendSet;
            if(!UI.isShowingPopup())
            {
               this.showVotingWindow();
            }
         }
      }
      
      private function showVotingWindow() : void
      {
         if(this.m_postVotingWindow)
         {
            this.m_postVotingWindow.close();
            this.m_postVotingWindow = null;
         }
         if(this.m_votingWindow)
         {
            this.m_votingWindow.close();
            this.m_votingWindow = null;
         }
         var swfUrl:String = this.isTemplateUIEnabled() ? this.getLookInsideDialogSwfUrl() : this.getImageUrl("lookInsideDialog");
         var showWhatIsThis:Boolean = false;
         this.m_votingWindow = new VotingWindow(this,this.context.getItemName(),swfUrl,showWhatIsThis,false);
         if(this.m_votingWindow.getCurrentTabIndex() == this.numStage)
         {
            this.m_postVotingWindow = new PostVotingWindow(this,this.context.getItemName(),this.getPostVotingDialogBackground(),showWhatIsThis,false);
            this.m_postVotingWindow.addEventListener(Event.CLOSE,this.onWindowClose);
            UI.displayPopup(this.m_postVotingWindow,true,this.m_featureName,true);
         }
         else
         {
            this.m_votingWindow.addEventListener(Event.CLOSE,this.onWindowClose);
            UI.displayPopup(this.m_votingWindow,true,this.m_featureName,true);
         }
      }
      
      private function onWindowClose(event:Event) : void
      {
         if(this.m_votingWindow)
         {
            this.m_votingWindow.removeEventListener(Event.CLOSE,this.onWindowClose);
            this.m_votingWindow = null;
         }
      }
      
      public function getFriendSet() : FriendSet
      {
         return VotingDataManager.getInstance().getDataObject(this.m_featureName).friendSet;
      }
      
      public function get stage() : int
      {
         return VotingDataManager.getInstance().getDataObject(this.m_featureName).stage;
      }
      
      public function set stage(val:int) : void
      {
         VotingDataManager.getInstance().getDataObject(this.m_featureName).updateCurrentStage(val);
      }
      
      public function get context() : MapResource
      {
         return this.m_context;
      }
      
      public function getFeatureName() : String
      {
         return this.m_featureName;
      }
      
      public function finishVoting() : void
      {
         Global.player.setFeatureLastShown(this.m_featureName + "_lastAskForVotes",0,false);
         if(this.stage < this.numStage - 1)
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SMART_NAUGHTY_NICE) > 0)
            {
               this.gotoNextStage();
            }
            else
            {
               TransactionManager.addTransaction(new TransactionWithCallBack("VotingService.onGoToNextStage",this.onFinishVotingCallback,this.m_featureName),true);
            }
            this.stage += 1;
         }
         else if(!VotingDataManager.getInstance().getDataObject(this.m_featureName).hasRedeemedFinalPrize && VotingDataManager.m_redeemedFinalPrizeInProgress == false)
         {
            TransactionManager.addTransaction(new TAwardVotePrize(this.m_featureName));
            VotingDataManager.m_redeemedFinalPrizeInProgress = true;
            VotingDataManager.getInstance().computeFinalResult(this.m_featureName);
            Global.player.setSeenFlag(this.m_context.getItemName() + "Finalized",false,true);
         }
         VotingDataManager.getInstance().getDataObject(this.m_featureName).startTime = 0;
         Global.world.dispatchEvent(new FarmGameWorldEvent(VOTING_STATE_CHANGE));
      }
      
      public function gotoNextStage() : void
      {
         TransactionManager.addTransaction(new TransactionWithCallBack("VotingService.onGoToNextStage",this.onFinishVotingCallback,this.m_featureName),true);
      }
      
      protected function onFinishVotingCallback(result:Object) : void
      {
         if(result)
         {
            if(result.hasOwnProperty("voteIndex") && result.voteIndex != null && result.hasOwnProperty("stageIndex") && result.stageIndex != null)
            {
               VotingDataManager.getInstance().setVoteResults(this.m_featureName,result.voteIndex,result.stageIndex);
               if(result.hasOwnProperty("voteItemName") && result.voteItemName != null)
               {
                  Global.player.addGift(result.voteItemName,"0",1);
                  VotingDataManager.getInstance().setCollectedItem(this.m_featureName,result.voteItemName);
               }
            }
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SMART_NAUGHTY_NICE) > 0)
            {
               if(result.hasOwnProperty("nextFriendSetData"))
               {
                  VotingDataManager.getInstance().refreshFriendSet(this.m_featureName,result.nextFriendSetData);
                  if(this.m_votingWindow)
                  {
                     this.m_votingWindow.refreshWindow();
                  }
               }
            }
         }
      }
      
      public function askForVotes(askForVotesFeedPostedCallback:Function = null, feedPublishFailCallback:Function = null) : void
      {
         var voteStart:Number = NaN;
         this.m_askForVotesFeedPostedCallback = askForVotesFeedPostedCallback;
         this.m_feedPublishFailCallback = feedPublishFailCallback;
         if(this.isAskForVotesEnabled())
         {
            voteStart = VotingDataManager.getInstance().getDataObject(this.m_featureName).startTime;
            if(voteStart <= 0)
            {
               voteStart = GlobalEngine.serverTime / 1000;
               VotingDataManager.getInstance().getDataObject(this.m_featureName).startTime = voteStart;
            }
            TransactionManager.addTransaction(new TransactionWithCallBack("VotingService.onGenerateCrewVotingReward",this.getRewardLinkAndPostCrewVotingFeedShare,this.m_featureName),true);
            FarmStatsManager.count(FEATURE_COUNTER,this.m_featureName,"stage_" + this.stage,"ask");
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
            this.m_crewVoteRewardLink = data.rewardUrl + "&feature=" + this.m_featureName;
            this.postCrewVotingFeedShare();
         }
         else if(this.m_askForVotesFeedPostedCallback != null)
         {
            this.m_askForVotesFeedPostedCallback();
            this.m_askForVotesFeedPostedCallback = null;
         }
      }
      
      protected function postCrewVotingFeedShare() : void
      {
         var bundleData:Object = {
            "reward_link":this.m_crewVoteRewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + this.m_crewVoteRewardLink,
               "src":Global.getAssetURL(this.getCrewVotingFeedIcon())
            }]
         };
         var messageType:String = this.context.getItemName() + "CrewVoting_" + this.stage.toString();
         TransactionManager.addTransaction(new TAskForVotePublish(messageType,bundleData,[],false,this.feedPostSucess,this.m_feedPublishFailCallback),true);
      }
      
      public function feedPostSucess() : void
      {
         var currentTimeInSec:Number = GlobalEngine.serverTime / 1000;
         var strFeatureFlagName:String = this.m_featureName + "_lastAskForVotes";
         Global.player.setFeatureLastShown(strFeatureFlagName,currentTimeInSec,true);
         if(this.m_askForVotesFeedPostedCallback != null)
         {
            this.m_askForVotesFeedPostedCallback();
            this.m_askForVotesFeedPostedCallback = null;
         }
      }
      
      protected function getCrewVotingFeedIcon() : String
      {
         var startReplace:int = 0;
         var endReplace:int = 0;
         var result:String = this.getImageUrl("crewVotingFeedIcon");
         if(result != null)
         {
            startReplace = result.indexOf("{");
            endReplace = result.indexOf("}");
            if(endReplace > startReplace && startReplace >= 0)
            {
               result = result.substring(0,startReplace) + this.stage + result.substring(endReplace + 1);
            }
         }
         return result;
      }
      
      public function get votesNeededForPrize() : int
      {
         return VotingDataManager.getInstance().getVotesNeededForPrize(this.m_featureName);
      }
      
      public function exeRedeemVotingPrize(prizeName:String, voteIndex:int, voters:String) : Boolean
      {
         var result:Boolean = false;
         if(this.canRedeemVotingPrize(prizeName,voteIndex))
         {
            TransactionManager.addTransaction(new TRedeemVoteItem(this.m_featureName,prizeName,voteIndex,voters,this.stage),true);
            VotingDataManager.getInstance().setVoteResults(this.m_featureName,voteIndex,this.stage);
            Global.player.addGift(prizeName,"0",1);
            VotingDataManager.getInstance().setCollectedItem(this.m_featureName,prizeName);
            result = true;
         }
         return result;
      }
      
      public function canRedeemVotingPrize(prizeName:String, voteIndex:int) : Boolean
      {
         var result:Boolean = false;
         var prizeItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(prizeName);
         if(prizeItem != null)
         {
            if(prizeItem.checkDateGate() && prizeItem.isInExperiment)
            {
               if(!VotingDataManager.getInstance().isItemCollected(this.m_featureName,prizeName))
               {
                  result = true;
               }
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
      
      public function getVoteItemByName(paramName:String) : Object
      {
         var voteItem:Object = null;
         var voteItems:Array = this.getAllVoteItems();
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
         return VotingDataManager.getFeatureVoteItemByIndexAndVoteIndex(this.m_featureName,index,voteIndex);
      }
      
      public function exeBuyVotingPrize(prizeName:String, expectedPrice:int) : Boolean
      {
         var voteObject:Object = null;
         var result:Boolean = false;
         if(this.canBuyVotingPrize(prizeName,expectedPrice))
         {
            voteObject = this.getVoteItemByName(prizeName);
            TransactionManager.addTransaction(new TBuyVoteItem(this.m_featureName,prizeName,expectedPrice,null),true);
            Global.player.cash -= expectedPrice;
            Global.player.addGift(prizeName,"0",1);
            result = true;
         }
         return result;
      }
      
      public function unlockCurrentStage(completeCallBack:Function = null) : Boolean
      {
         var result:Boolean = false;
         var voteManager:VotingDataManager = VotingDataManager.getInstance();
         var voteState:VotingDataObject = voteManager.getDataObject(this.m_featureName);
         var stageCost:int = voteState.getStageUnlockCost();
         var stageLocked:Boolean = !voteManager.isCurrentStageUnlocked(this.m_featureName);
         if(stageLocked && Global.player.canBuyCash(stageCost))
         {
            Global.player.cash -= stageCost;
            TransactionManager.addTransaction(new TransactionWithCallBack("VotingService.onUnlockCurrentStage",completeCallBack,this.m_featureName));
            voteState.unlockCurrentStage();
            result = true;
            FarmStatsManager.count(FEATURE_COUNTER,this.m_featureName,"stage_" + this.stage,"unlock");
         }
         return result;
      }
      
      public function getAllVoteItems() : Array
      {
         return VotingDataManager.getRewardItemsForFeatureName(this.m_featureName);
      }
      
      public function getAllPrizeItems() : Array
      {
         var index:uint = 0;
         var prizeItemXML:XML = null;
         var prizeItemData:Object = null;
         var xml:XML = this.getGameSettingsXml();
         var result:Array = new Array();
         var prizeItemsXML:XMLList = new XMLList();
         if(Boolean(xml) && Boolean(xml["prizeItem"]))
         {
            prizeItemsXML = xml["prizeItem"];
         }
         if(prizeItemsXML)
         {
            for(index = 0; index < prizeItemsXML.length(); index++)
            {
               prizeItemXML = prizeItemsXML[index];
               prizeItemData = new Object();
               if(prizeItemXML.hasOwnProperty("@index"))
               {
                  prizeItemData.index = parseInt(prizeItemXML.@index.toString());
               }
               if(prizeItemXML.hasOwnProperty("@code"))
               {
                  prizeItemData.code = prizeItemXML.@code.toString();
               }
               result.push(prizeItemData);
            }
         }
         return result;
      }
      
      public function getPrizeItemByIndex(index:int) : Object
      {
         var prizeItem:Object = null;
         var prizeItems:Array = this.getAllPrizeItems();
         var result:Object = null;
         for(var curItem:Number = 0; curItem < prizeItems.length; curItem++)
         {
            prizeItem = prizeItems[curItem];
            if(prizeItem.index == index)
            {
               result = prizeItem;
               break;
            }
         }
         return result;
      }
      
      public function getOffBoardingData() : Array
      {
         return Global.farmGameSettingsManager.getBuildingOffBoardData(this.m_featureName);
      }
      
      public function isAskForVotesEnabled() : Boolean
      {
         return VotingDataManager.getInstance().isAskForVotesEnabled(this.m_featureName);
      }
      
      public function getGameSettingsXml() : XML
      {
         return Global.farmGameSettingsManager.getFeatureXML(this.m_featureName);
      }
      
      public function getImageUrl(sImageName:String) : String
      {
         var result:String = null;
         var xml:XML = this.getGameSettingsXml();
         if(Boolean(xml) && Boolean(xml.image.(@name == sImageName)))
         {
            result = xml.image.(@name == sImageName).@url;
         }
         return result;
      }
      
      public function getDialogBackground() : String
      {
         return this.getImageUrl("dialogBackground");
      }
      
      public function getPostVotingDialogBackground() : String
      {
         return this.getImageUrl("postVotingDialogBackground");
      }
      
      public function getTemplateDialog() : String
      {
         return this.getImageUrl("templateDialog");
      }
      
      public function getTextColor() : String
      {
         var result:String = null;
         var xml:XML = this.getGameSettingsXml();
         if(Boolean(xml) && Boolean(xml.textColor))
         {
            result = xml.textColor;
         }
         return result;
      }
      
      public function getDialogSideIconUrl() : String
      {
         return this.getImageUrl("icon");
      }
      
      public function getLookInsideDialogSwfUrl() : String
      {
         var result:String = TemplateUIUtility.VOTING_TEMPLATE_SWF;
         if(this.getTemplateDialog() != null && this.getTemplateDialog() != "")
         {
            result = this.getTemplateDialog();
         }
         else if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SMART_NAUGHTY_NICE) > 0)
         {
            result = TemplateUIUtility.VOTING_TEMPLATE_SWF_DYNAMIC_SLOTS;
         }
         else if(VotingDataManager.getInstance().getVotesNeededForPrize(this.m_featureName) > VotingDataManager.DEFAULT_VOTES_NEEDED)
         {
            result = TemplateUIUtility.VOTING_TEMPLATE_SWF_DYNAMIC_SLOTS;
         }
         return result;
      }
      
      public function isTemplateUIEnabled() : Boolean
      {
         var result:Boolean = false;
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.VOTING) && this.getDialogBackground() != null && this.getDialogBackground() != "" && this.getTextColor() != null && this.getTextColor() != "")
         {
            result = true;
         }
         return result;
      }
      
      public function get numStage() : int
      {
         var result:int = 0;
         var xml:XML = this.getGameSettingsXml();
         if(Boolean(xml) && xml.hasOwnProperty("@stages"))
         {
            result = int(xml.@stages);
         }
         return result;
      }
      
      public function replay() : void
      {
         this.showVotingWindow();
      }
      
      public function closeVotingwindow() : void
      {
         if(this.m_postVotingWindow)
         {
            this.m_postVotingWindow.close();
            this.m_postVotingWindow = null;
         }
         if(this.m_votingWindow)
         {
            this.m_votingWindow.close();
            this.m_votingWindow = null;
         }
      }
   }
}

