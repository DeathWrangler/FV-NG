package Managers
{
   import Classes.FeatureDataObjects.FriendSet;
   import Classes.FeatureDataObjects.VotingDataObject;
   import Classes.FeatureDataObjects.VotingFeatureFriendSet;
   import Classes.util.FarmGameUtil;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import flash.utils.Dictionary;
   
   public class VotingDataManager
   {
      
      protected static var m_rewards:Array;
      
      private static var m_arrVotingDataObject:Array = new Array();
      
      private static var m_instance:VotingDataManager = null;
      
      private static var m_initialized:Boolean = false;
      
      private static var s_featureObject:Dictionary = new Dictionary();
      
      private static var s_rewardObject:Dictionary = new Dictionary();
      
      public static const IS_TIE:int = 1;
      
      public static const IS_CREW_FULL:int = 2;
      
      public static const TIMER_NOT_STARTED:Number = 999999999999;
      
      public static const DEFAULT_VOTES_NEEDED:int = 4;
      
      public static const PERSONALITY_ONE_TEXT:String = "_Personality_One";
      
      public static const PERSONALITY_TWO_TEXT:String = "_Personality_Two";
      
      public static var m_selectedTabIndex:int = 0;
      
      public static var m_redeemedFinalPrizeInProgress:Boolean = false;
      
      private var m_dataIsReady:Boolean = false;
      
      public function VotingDataManager()
      {
         super();
         if(!m_initialized)
         {
            m_initialized = true;
            return;
         }
         throw new Error("Error: Instantiation failed: Use VotingDataManager.getInstance() instead of new.");
      }
      
      public static function set rewards(rewards:Array) : void
      {
         m_rewards = rewards;
      }
      
      public static function get rewardType() : String
      {
         return "";
      }
      
      public static function getInstance() : VotingDataManager
      {
         if(m_instance == null)
         {
            m_instance = new VotingDataManager();
         }
         return m_instance;
      }
      
      public static function getFeatureVoteItemByIndexAndVoteIndex(featureName:String, index:int, voteIndex:int) : Object
      {
         var voteItem:Object = null;
         var voteItems:Array = getRewardItemsForFeatureName(featureName);
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
      
      private static function getVoteItemsByFeatureName(featureName:String) : Array
      {
         var result:Array = new Array();
         var xml:XML = getFeatureXMLForFeatureName(featureName);
         if(xml != null)
         {
            result = Global.farmGameSettingsManager.getRewardItemsFromXML(xml,"voteItem");
         }
         return result;
      }
      
      private static function getFeatureXMLForFeatureName(featureName:String) : XML
      {
         if(!s_featureObject[featureName])
         {
            s_featureObject[featureName] = Global.farmGameSettingsManager.getFeatureXML(featureName);
         }
         return s_featureObject[featureName];
      }
      
      public static function getRewardItemsForFeatureName(featureName:String) : Array
      {
         if(!s_rewardObject[featureName])
         {
            s_rewardObject[featureName] = getVoteItemsByFeatureName(featureName);
         }
         return s_rewardObject[featureName];
      }
      
      public function getDataObject(featureName:String) : VotingDataObject
      {
         if(this.m_dataIsReady)
         {
            if(m_arrVotingDataObject[featureName] == null)
            {
               m_arrVotingDataObject[featureName] = new VotingDataObject(featureName);
            }
         }
         else
         {
            ErrorManager.addError("VotingDataObject::getFeatureData - FeatureOptionsManager not initlized");
         }
         return m_arrVotingDataObject[featureName];
      }
      
      public function isCurrentStageUnlocked(featureName:String) : Boolean
      {
         return this.getTimeLeftForStageUnlock(featureName) <= 0;
      }
      
      public function isAskForVotesEnabled(featureName:String) : Boolean
      {
         return this.isCurrentStageUnlocked(featureName) && this.askForVotesTimeRemaining(featureName) <= 0 && !this.isFeatureOffboarded(featureName);
      }
      
      public function isAskForFeedsEnabled(featureName:String) : Boolean
      {
         return this.askForFeedsTimeRemaining(featureName) <= 0 && !this.isFeatureOffboarded(featureName);
      }
      
      public function askForVotesTimeRemaining(featureName:String) : Number
      {
         var strFeatureFlagName:String = featureName + "_lastAskForVotes";
         var lastAskTimeInSec:Number = Global.player.getFeatureLastShown(strFeatureFlagName);
         var askLimitTimeValue:int = this.getDataObject(featureName).askTimeLimit;
         var askFeatureFrequencyInSec:Number = Global.farmGameSettingsManager.getNumber(featureName + "AskForVotesFeatureFrequency",askLimitTimeValue * FarmGameUtil.NUM_SECS_IN_HOUR);
         var currentTimeInSec:Number = GlobalEngine.serverTime / 1000;
         return lastAskTimeInSec + askFeatureFrequencyInSec - currentTimeInSec;
      }
      
      public function askForFeedsTimeRemaining(featureName:String) : Number
      {
         var strFeatureFlagName:String = "PostVoting" + "_lastAskForFeeds";
         var lastAskTimeInSec:Number = Global.player.getFeatureLastShown(strFeatureFlagName);
         var askLimitTimeValue:int = this.getDataObject(featureName).askTimeLimit;
         var askFeatureFrequencyInSec:Number = Global.farmGameSettingsManager.getNumber(featureName + "AskForFeedsFeatureFrequency",askLimitTimeValue * FarmGameUtil.NUM_SECS_IN_HOUR);
         var currentTimeInSec:Number = GlobalEngine.serverTime / 1000;
         return lastAskTimeInSec + askFeatureFrequencyInSec * 3 / 2 - currentTimeInSec;
      }
      
      public function setCollectedItem(featureName:String, itemName:String) : void
      {
         var collectedItems:Array = this.getDataObject(featureName).collectedItems;
         if(collectedItems != null && !this.isItemCollected(featureName,itemName))
         {
            collectedItems.push(itemName);
         }
      }
      
      public function isItemCollected(featureName:String, itemName:String) : Boolean
      {
         var i:int = 0;
         var data:Object = null;
         var collectedItems:Array = this.getDataObject(featureName).collectedItems;
         var result:Boolean = false;
         if(collectedItems != null)
         {
            for(i = 0; i < collectedItems.length; i++)
            {
               if(itemName == collectedItems[i])
               {
                  result = true;
                  break;
               }
            }
         }
         if(result == false)
         {
            data = FeatureOptionsManager.getInstance().getFeatureOption(featureName,FeatureOptionsManager.POST_VOTING_STATE);
            if(Boolean(data) && data.hasOwnProperty(itemName))
            {
               if(data[itemName] >= this.getVotesNeededForPrize(featureName))
               {
                  Global.player.addGift(itemName,"0",1);
                  data[itemName] = 0;
                  FeatureOptionsManager.getInstance().setFeatureOption(featureName,FeatureOptionsManager.POST_VOTING_STATE,data);
                  TransactionManager.addTransaction(new TGenericTransaction("VotingService","resetPostVoteItemData",null,[featureName,itemName]),true);
                  collectedItems = this.getDataObject(featureName).collectedItems;
                  collectedItems.push(itemName);
                  result = true;
               }
            }
         }
         return result;
      }
      
      public function setVoteResults(featureName:String, voteIndex:int, stage:int) : void
      {
         var voteResults:Array = this.getDataObject(featureName).voteResults;
         if(voteResults != null && voteResults[stage] == null)
         {
            voteResults[stage] = voteIndex;
         }
      }
      
      public function refreshFriendSet(featureName:String, newFriendSetData:Object) : void
      {
         var newFriendSet:VotingFeatureFriendSet = null;
         var friendSet:VotingFeatureFriendSet = this.getDataObject(featureName).friendSet as VotingFeatureFriendSet;
         if(friendSet)
         {
            newFriendSet = new VotingFeatureFriendSet(friendSet.code);
            newFriendSet.onInitialize(newFriendSetData);
            this.getDataObject(featureName).friendSet = newFriendSet;
         }
      }
      
      public function getVoteResults(featureName:String, stage:int) : int
      {
         var result:int = -1;
         var voteResults:Array = this.getDataObject(featureName).voteResults;
         if(voteResults != null && voteResults[stage] != null)
         {
            result = parseInt(voteResults[stage]);
         }
         return result;
      }
      
      public function computeFinalResult(featureName:String) : int
      {
         var winner:int = this.getCurrentWinner(featureName,true);
         this.getDataObject(featureName).finalResult = winner;
         return winner;
      }
      
      public function getFeatureCompleted(featureName:String) : Boolean
      {
         return this.getDataObject(featureName).finalResult != -1;
      }
      
      public function getCurrentWinner(featureName:String, isFinal:Boolean = false) : int
      {
         var vote:int = 0;
         var voteResults:Array = this.getDataObject(featureName).voteResults;
         var tally:Array = new Array();
         var numStages:int = int(voteResults.length);
         if(numStages % 2 == 0 && isFinal)
         {
            numStages--;
         }
         for(var i:int = 0; i < numStages; i++)
         {
            vote = int(voteResults[i]);
            if(tally[vote] != null)
            {
               ++tally[vote];
            }
            else
            {
               tally[vote] = 1;
            }
         }
         var result:int = 0;
         var maxCount:int = 0;
         for(var j:int = 0; j < tally.length; j++)
         {
            if(tally[j] > maxCount)
            {
               maxCount = int(tally[j]);
               result = j;
            }
         }
         return result;
      }
      
      public function initialize() : void
      {
         this.m_dataIsReady = true;
      }
      
      public function get isInitialized() : Boolean
      {
         return this.m_dataIsReady;
      }
      
      public function getCurrentFriendSetState(featureName:String) : int
      {
         var isTie:Boolean = false;
         var isFull:Boolean = false;
         var counts:Array = new Array();
         var result:int = 0;
         var friendSet:FriendSet = this.getDataObject(featureName).friendSet;
         var votingFriends:Array = friendSet.votingFriends;
         for(var i:int = 0; i < votingFriends.length; i++)
         {
            if(votingFriends[i] != null)
            {
               counts[i] = votingFriends[i].length;
               if(counts[i] == this.getVotesNeededForPrize(featureName))
               {
                  isFull = true;
               }
               if(i > 0)
               {
                  isTie = counts[i] == counts[i - 1];
               }
            }
         }
         if(isTie)
         {
            result = IS_TIE;
         }
         else if(isFull)
         {
            result = IS_CREW_FULL;
         }
         return result;
      }
      
      public function getTimeLeftForStageUnlock(featureName:String) : Number
      {
         var prevStageReachedTime:Number = this.getDataObject(featureName).lastStageReachedTime;
         var curTimeInSeconds:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var timeSincePrevStage:Number = curTimeInSeconds - prevStageReachedTime;
         var stageLockoutTime:Number = this.getDataObject(featureName).stageUnlockTime * FarmGameUtil.NUM_SECS_IN_HOUR;
         return Math.max(stageLockoutTime - timeSincePrevStage,0);
      }
      
      public function isFeatureOffboarded(featureName:String) : Boolean
      {
         return this.getDataObject(featureName).isInOffboarding();
      }
      
      public function getVoteExpirationTime(featureName:String) : Number
      {
         var voteExpiration:Number = NaN;
         var stageDuration:int = 0;
         var voteStart:Number = this.getDataObject(featureName).startTime;
         if(voteStart <= 0)
         {
            voteExpiration = TIMER_NOT_STARTED;
         }
         else
         {
            stageDuration = this.getDataObject(featureName).stageDuration;
            voteExpiration = voteStart + Global.farmGameSettingsManager.getNumber(featureName + "VoteExpireFeatureFrequency",stageDuration * FarmGameUtil.NUM_SECS_IN_DAY);
         }
         return voteExpiration;
      }
      
      public function getVotesNeededForPrize(featureName:String, stageIndex:int = -1) : int
      {
         var votesNeeded:int = 0;
         var featureXML:XML = null;
         var friendSetCode:String = null;
         var friendSetXml:XML = null;
         var totalVotesNeeded:int = 0;
         var stage:int = this.getDataObject(featureName).stage;
         if(stageIndex != -1)
         {
            stage = stageIndex;
         }
         var voteItem:Object = getFeatureVoteItemByIndexAndVoteIndex(featureName,stage,0);
         if(voteItem.crewSize != null)
         {
            votesNeeded = int(voteItem.crewSize);
         }
         else
         {
            votesNeeded = 0;
            featureXML = getFeatureXMLForFeatureName(featureName);
            if(Boolean(featureXML) && featureXML.hasOwnProperty("friendSet"))
            {
               friendSetCode = featureXML.friendSet;
               friendSetXml = Global.farmGameSettingsManager.getFriendSetXMLByCode(friendSetCode);
               if(Boolean(friendSetXml) && Boolean(friendSetXml.numFriendsNeeded))
               {
                  totalVotesNeeded = parseInt(friendSetXml.numFriendsNeeded.toString());
                  votesNeeded = totalVotesNeeded / 2;
               }
            }
            if(votesNeeded == 0)
            {
               votesNeeded = DEFAULT_VOTES_NEEDED;
            }
         }
         return votesNeeded;
      }
      
      public function getAllVotingFeatures() : Array
      {
         var featureName:String = null;
         var result:Array = new Array();
         for(featureName in m_arrVotingDataObject)
         {
            result.push(featureName);
         }
         return result;
      }
      
      public function get redeemedFinalPrizeInProgress() : Boolean
      {
         return m_redeemedFinalPrizeInProgress;
      }
   }
}

