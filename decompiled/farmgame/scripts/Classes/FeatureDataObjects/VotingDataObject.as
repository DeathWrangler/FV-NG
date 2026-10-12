package Classes.FeatureDataObjects
{
   import Classes.FeatureComponents.VotingComponent;
   import Classes.util.FarmGameUtil;
   import Managers.FeatureOptionsManager;
   
   public class VotingDataObject
   {
      
      public static const UNINITIALIZED:int = -1;
      
      private static const SERVER_UNINITIALIZED_TIME:int = 0;
      
      private static const UNLOCK_PREV_STAGE_TIME:int = -2;
      
      public static const DEFAULT_STAGE_UNLOCK_COST:int = 0;
      
      public static const DEFAULT_ASK_LIMIT_TIME:int = 6;
      
      public static const DEFAULT_STAGE_DURATION_LIMIT_TIME:int = 3;
      
      public static const DEFAULT_STAGE_UNLOCK_TIME:int = 0;
      
      public var friendSet:FeatureFriendSet = null;
      
      public var friendSetCode:String = "";
      
      private var m_askTimeLimit:int;
      
      private var m_stageDuration:int;
      
      private var m_stage:int = -1;
      
      private var m_collectedItems:Array;
      
      private var m_voteResults:Array;
      
      private var m_featureName:String;
      
      private var m_startTime:Number = -1;
      
      private var m_lastStageReachedTime:Number = -1;
      
      private var m_currentStageReachedTime:Number = -1;
      
      private var m_finalResult:int = -1;
      
      private var m_hasRedeemedFinalPrize:int = -1;
      
      private var m_stageUnlockTime:int;
      
      private var m_stageUnlockCost:int;
      
      private var m_stageUnlockCosts:Array;
      
      private var m_inOffboarding:Boolean;
      
      public function VotingDataObject(featureName:String)
      {
         super();
         this.m_featureName = featureName;
         this.m_askTimeLimit = this.getNumericDataByPropertyName("askTimeLimit",DEFAULT_ASK_LIMIT_TIME);
         this.m_stageDuration = this.getNumericDataByPropertyName("stageDuration",DEFAULT_STAGE_DURATION_LIMIT_TIME);
         this.m_stageUnlockTime = this.getNumericDataByPropertyName("stageUnlockTime",DEFAULT_STAGE_UNLOCK_TIME);
         this.m_stageUnlockCost = this.getNumericDataByPropertyName("stageUnlockCost",DEFAULT_STAGE_UNLOCK_COST);
         this.m_stageUnlockCosts = this.getStageUnlockCosts();
         this.m_inOffboarding = false;
      }
      
      private function getNumericDataByPropertyName(property:String, defaultValue:int) : int
      {
         var timeValueStr:String = VotingComponent.getConfigData(this.m_featureName,property);
         return timeValueStr != null && timeValueStr != "" ? int(parseInt(timeValueStr)) : defaultValue;
      }
      
      private function getStageUnlockCosts() : Array
      {
         var voteItem:Object = null;
         var index:int = 0;
         var unlockCost:int = 0;
         var result:Array = new Array();
         var xml:XML = Global.farmGameSettingsManager.getFeatureXML(this.m_featureName);
         var voteItems:Array = new Array();
         if(xml != null)
         {
            voteItems = Global.farmGameSettingsManager.getRewardItemsFromXML(xml,"voteItem");
         }
         for each(voteItem in voteItems)
         {
            if("index" in voteItem && "unlockCost" in voteItem)
            {
               index = int(voteItem["index"]);
               unlockCost = int(voteItem["unlockCost"]);
               result[index] = unlockCost;
            }
         }
         return result;
      }
      
      private function getFeatureData() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureName,FeatureOptionsManager.VOTING_STATE);
      }
      
      public function get stage() : int
      {
         var data:Object = null;
         if(this.m_stage == UNINITIALIZED)
         {
            data = this.getFeatureData();
            if(data != null && data.hasOwnProperty("stage"))
            {
               this.m_stage = data.stage;
            }
         }
         return this.m_stage == UNINITIALIZED ? 0 : this.m_stage;
      }
      
      public function updateCurrentStage(val:int) : void
      {
         var curr:int = 0;
         if(val > this.m_stage)
         {
            curr = this.getCurrentStageReachedTime();
            if(curr == UNINITIALIZED || curr == SERVER_UNINITIALIZED_TIME)
            {
               this.setCurrentStageReachedTime();
               this.m_lastStageReachedTime = this.getCurrentStageReachedTime();
            }
            else
            {
               this.m_lastStageReachedTime = this.getCurrentStageReachedTime();
               this.setCurrentStageReachedTime();
            }
         }
         this.m_stage = val;
      }
      
      public function get collectedItems() : Array
      {
         var data:Object = null;
         if(this.m_collectedItems == null)
         {
            data = this.getFeatureData();
            if(data != null && data.hasOwnProperty("collectedItems"))
            {
               this.m_collectedItems = data.collectedItems;
            }
            else
            {
               this.m_collectedItems = new Array();
            }
         }
         return this.m_collectedItems;
      }
      
      public function get voteResults() : Array
      {
         var data:Object = null;
         if(this.m_voteResults == null)
         {
            data = this.getFeatureData();
            if(data != null && data.hasOwnProperty("voteResults"))
            {
               this.m_voteResults = data.voteResults;
            }
            else
            {
               this.m_voteResults = new Array();
            }
         }
         return this.m_voteResults;
      }
      
      public function get startTime() : Number
      {
         var data:Object = null;
         if(this.m_startTime == UNINITIALIZED)
         {
            data = this.getFeatureData();
            if(data != null && data.hasOwnProperty("startTime"))
            {
               this.m_startTime = data.startTime;
            }
         }
         return this.m_startTime;
      }
      
      public function get lastStageReachedTime() : Number
      {
         var data:Object = null;
         if(this.m_lastStageReachedTime == UNINITIALIZED)
         {
            data = this.getFeatureData();
            if(data != null && data.hasOwnProperty("lastStageReachedTime"))
            {
               this.m_lastStageReachedTime = data.lastStageReachedTime;
            }
         }
         return this.m_lastStageReachedTime;
      }
      
      public function unlockCurrentStage() : void
      {
         this.m_lastStageReachedTime = UNLOCK_PREV_STAGE_TIME;
      }
      
      private function getCurrentStageReachedTime() : Number
      {
         var data:Object = null;
         if(this.m_currentStageReachedTime == UNINITIALIZED)
         {
            data = this.getFeatureData();
            if(data != null && data.hasOwnProperty("currentStageReachedTime"))
            {
               this.m_currentStageReachedTime = data.currentStageReachedTime;
            }
         }
         return this.m_currentStageReachedTime;
      }
      
      private function setCurrentStageReachedTime() : void
      {
         this.m_currentStageReachedTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
      }
      
      public function isInOffboarding() : Boolean
      {
         var offBoard:Array = null;
         if(!this.m_inOffboarding)
         {
            offBoard = Global.farmGameSettingsManager.getBuildingOffBoardData(this.m_featureName);
            this.m_inOffboarding = offBoard != null && offBoard.hasOwnProperty("isOffBoard") && Boolean(offBoard["isOffBoard"]);
         }
         return this.m_inOffboarding;
      }
      
      public function set startTime(startTime:Number) : void
      {
         this.m_startTime = startTime;
         var curr:int = this.getCurrentStageReachedTime();
         if(curr == SERVER_UNINITIALIZED_TIME)
         {
            this.setCurrentStageReachedTime();
         }
      }
      
      public function get finalResult() : int
      {
         var data:Object = null;
         if(this.m_finalResult == UNINITIALIZED)
         {
            data = this.getFeatureData();
            if(data != null && data.hasOwnProperty("finalResult"))
            {
               this.m_finalResult = data.finalResult;
            }
         }
         return this.m_finalResult;
      }
      
      public function set finalResult(finalResult:int) : void
      {
         this.m_finalResult = finalResult;
      }
      
      public function reset() : void
      {
         this.m_collectedItems = new Array();
         this.m_stage = 0;
         this.m_startTime = 0;
         this.m_voteResults = new Array();
         this.m_hasRedeemedFinalPrize = 0;
         this.m_lastStageReachedTime = 0;
         this.setCurrentStageReachedTime();
      }
      
      public function get hasRedeemedFinalPrize() : Boolean
      {
         var data:Object = null;
         if(this.m_hasRedeemedFinalPrize == UNINITIALIZED)
         {
            data = this.getFeatureData();
            if(data != null && data.hasOwnProperty("hasRedeemedFinalPrize"))
            {
               this.m_hasRedeemedFinalPrize = data.hasRedeemedFinalPrize ? 1 : 0;
            }
         }
         return this.m_hasRedeemedFinalPrize == 1;
      }
      
      public function set hasRedeemedFinalPrize(hasRedeemed:Boolean) : void
      {
         this.m_hasRedeemedFinalPrize = hasRedeemed ? 1 : 0;
      }
      
      public function get askTimeLimit() : int
      {
         return this.m_askTimeLimit;
      }
      
      public function get stageDuration() : int
      {
         return this.m_stageDuration;
      }
      
      public function get stageUnlockTime() : int
      {
         return this.m_stageUnlockTime;
      }
      
      public function getStageUnlockCost() : int
      {
         var result:int = this.m_stageUnlockCost;
         if(this.m_stageUnlockCosts[this.stage] != undefined)
         {
            result = int(this.m_stageUnlockCosts[this.stage]);
         }
         return result;
      }
   }
}

