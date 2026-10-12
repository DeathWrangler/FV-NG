package Classes
{
   import Classes.Avatar.AvatarConfigSettings;
   import Classes.Constants.XMLKeys;
   import Classes.FeatureDataObjects.FeatureFriendSet;
   import Classes.FeatureDataObjects.FriendSet;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Managers.FarmGameSettingsManager;
   
   public class FriendSetGoal extends GameSettingsObject
   {
      
      protected static const ATTR_CASH_COST_PER_FRIEND:String = "@cashCostPerFriend";
      
      protected var m_friendSet:FriendSet;
      
      public function FriendSetGoal(xml:XML)
      {
         super(xml);
      }
      
      public function get code() : String
      {
         return m_xml.@code;
      }
      
      public function get currentLevel() : int
      {
         var levelXml:XML = null;
         var idx:int = 0;
         var result:Number = 0;
         var levelCount:int = this.getNumberOfGoalLevels();
         var completedFriends:int = this.friendSet.numFriendsCompleted;
         var countMax:int = 0;
         var countMin:int = 0;
         var goalLevels:XMLList = m_xml.goalData..level;
         if(goalLevels.length())
         {
            for(idx = 0; idx < goalLevels.length(); idx++)
            {
               levelXml = goalLevels[idx];
               if(levelXml.hasOwnProperty(XMLKeys.ATTR_COUNT_MAX))
               {
                  countMax = int(levelXml[XMLKeys.ATTR_COUNT_MAX]);
                  if(levelXml.hasOwnProperty(XMLKeys.ATTR_COUNT_MIN))
                  {
                     countMin = int(levelXml[XMLKeys.ATTR_COUNT_MIN]);
                     if(completedFriends >= countMin && completedFriends <= countMax)
                     {
                        if(levelXml.hasOwnProperty(XMLKeys.ATTR_INDEX))
                        {
                           result = Number(levelXml[XMLKeys.ATTR_INDEX]);
                        }
                        else
                        {
                           result = idx;
                        }
                        break;
                     }
                     if(idx == levelCount - 1 && completedFriends > countMax)
                     {
                        if(levelXml.hasOwnProperty(XMLKeys.ATTR_INDEX))
                        {
                           result = Number(levelXml[XMLKeys.ATTR_INDEX]);
                        }
                        else
                        {
                           result = idx;
                        }
                     }
                  }
               }
            }
         }
         return result;
      }
      
      public function isStarted() : Boolean
      {
         var result:Boolean = true;
         var featureFriendSet:FeatureFriendSet = this.m_friendSet as FeatureFriendSet;
         if(featureFriendSet)
         {
            if(featureFriendSet.getStartTime() == 0)
            {
               if(!this.hasTimerExpired())
               {
                  result = false;
               }
            }
         }
         return result;
      }
      
      public function isCompleted() : Boolean
      {
         var result:Boolean = false;
         if(this.completionRatio >= 1 || this.hasTimerExpired())
         {
            result = true;
         }
         return result;
      }
      
      public function getDaysForLevel(aLevel:int) : Number
      {
         var result:Number = 0;
         var level:XML = this.getGoalLevelXML(aLevel);
         if(Boolean(level) && level.hasOwnProperty(XMLKeys.ATTR_DAYS_TO_COMPLETE))
         {
            result = Number(level[XMLKeys.ATTR_DAYS_TO_COMPLETE]);
         }
         return result;
      }
      
      public function get secondsToCompleteLevel() : Number
      {
         var daysToComplete:Number = NaN;
         var secsToCompleteLevel:Number = NaN;
         var timeElapsed:Number = NaN;
         var result:Number = 0;
         var featureFriendSet:FeatureFriendSet = this.m_friendSet as FeatureFriendSet;
         if(featureFriendSet)
         {
            daysToComplete = this.getDaysForLevel(this.currentLevel);
            secsToCompleteLevel = daysToComplete * FarmGameUtil.NUM_SECS_IN_DAY;
            timeElapsed = GlobalEngine.serverTime / 1000 - featureFriendSet.getStartTime();
            result = secsToCompleteLevel - timeElapsed;
            if(result < 0)
            {
               result = 0;
            }
         }
         return result;
      }
      
      public function get completionRatio() : Number
      {
         var result:Number = 0;
         var completedFriends:int = this.friendSet.numFriendsCompleted;
         if(this.maxRequiredFriends > 0)
         {
            result = completedFriends / this.maxRequiredFriends;
         }
         return result;
      }
      
      public function getNumFriendsNeededForLevel(aLevel:int) : int
      {
         var result:int = 0;
         var levelXml:XML = this.getGoalLevelXML(aLevel);
         if(null != levelXml)
         {
            if(levelXml.hasOwnProperty(XMLKeys.ATTR_COUNT_MIN))
            {
               result = int(levelXml[XMLKeys.ATTR_COUNT_MIN]);
            }
         }
         return result;
      }
      
      public function get maxRequiredFriends() : Number
      {
         var result:Number = 0;
         var highestLevel:int = this.getHighestGoalLevel();
         var levelXml:XML = this.getGoalLevelXML(highestLevel);
         if(levelXml.hasOwnProperty(XMLKeys.ATTR_COUNT_MAX))
         {
            result = Number(levelXml[XMLKeys.ATTR_COUNT_MAX]);
         }
         return result;
      }
      
      public function set friendSet(fs:FriendSet) : void
      {
         this.m_friendSet = fs;
      }
      
      public function get friendSet() : FriendSet
      {
         return this.m_friendSet;
      }
      
      public function get rewardFeedItem() : FarmItem
      {
         var result:FarmItem = null;
         if(m_xml.hasOwnProperty("goalReward"))
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               result = Global.farmGameSettingsManager.getFarmItemByName(m_xml.goalReward);
            }
            else
            {
               result = new FarmItem(Global.farmGameSettingsManager.getItemXMLByName(m_xml.goalReward));
            }
         }
         return result;
      }
      
      public function isEnabled() : Boolean
      {
         var result:Boolean = true;
         if(Boolean(m_xml.listStartDate) && Boolean(m_xml.listEndDate) && !FarmGameUtil.checkDateGate(m_xml.listStartDate,m_xml.listEndDate))
         {
            result = false;
         }
         return result;
      }
      
      public function get hasData() : Boolean
      {
         var result:Boolean = true;
         if(Boolean(m_xml.DataEndDate) && Boolean(m_xml.listStartDate) && !FarmGameUtil.checkDateGate(m_xml.listStartDate,m_xml.DataEndDate))
         {
            result = false;
         }
         return result;
      }
      
      public function getNumberOfGoalLevels() : int
      {
         var goalLevel:XMLList = m_xml.goalData..level;
         return goalLevel.length();
      }
      
      public function getHighestGoalLevel() : int
      {
         var curGoal:XML = null;
         var index:int = 0;
         var result:int = 0;
         var goals:XMLList = m_xml.goalData..level;
         var highestValue:int = 0;
         var curGoalIndex:int = 0;
         if(goals.length())
         {
            for(index = 0; index < goals.length(); index++)
            {
               curGoal = goals[index];
               curGoalIndex = int(curGoal["@index"]);
               if(curGoalIndex > highestValue)
               {
                  highestValue = curGoalIndex;
               }
            }
            result = highestValue;
         }
         return highestValue;
      }
      
      private function getGoalLevelXML(level:int) : XML
      {
         var result:XML = null;
         var goalLevel:XMLList = null;
         result = null;
         goalLevel = m_xml.goalData..level.(@index == level);
         if(goalLevel.length())
         {
            result = goalLevel[0];
         }
         return result;
      }
      
      public function getRequirementByLevel(level:int) : int
      {
         var goal:XML = this.getGoalLevelXML(level);
         var min:int = int(goal.@countMin);
         var max:int = int(goal.@countMax);
         if(Config.DEBUG_MODE && (min == 0 || max == 0))
         {
            UI.displayMessage("[Debug] Either your \'min\' or \'max\' is set to 0. Is this REALLY what you want to do? Goal min: " + min + ", Goal max: " + max,0,null,"",true);
         }
         return this.m_friendSet.getDifficultyForLevel(level,min,max);
      }
      
      public function getRewardForLevel(level:int) : XML
      {
         var rewardIdentifier:String = null;
         var goal:XML = this.getGoalLevelXML(level);
         var result:XML = null;
         if(goal)
         {
            rewardIdentifier = goal.@gift;
            result = Global.farmGameSettingsManager.getItemXMLByName(rewardIdentifier);
            if(!result && rewardIdentifier == "avatar")
            {
               if(Global.player.avatar.gender == AvatarConfigSettings.GENDER_CODE_FEMALE)
               {
                  rewardIdentifier = goal.@female;
               }
               else
               {
                  rewardIdentifier = goal.@male;
               }
               result = Global.avatarConfigSettings.getItemById(rewardIdentifier).toItemXML();
            }
         }
         return result;
      }
      
      public function getRewardNameForLevel(level:int) : String
      {
         var rewardIdentifier:String = null;
         var rewardItem:FarmItem = null;
         var goal:XML = this.getGoalLevelXML(level);
         var result:String = "";
         if(goal)
         {
            rewardIdentifier = goal.@gift;
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(rewardIdentifier);
            if(rewardItem)
            {
               result = rewardItem.name;
            }
            else if(rewardIdentifier == "avatar")
            {
               if(Global.player.avatar.gender == AvatarConfigSettings.GENDER_CODE_FEMALE)
               {
                  rewardIdentifier = goal.@female;
               }
               else
               {
                  rewardIdentifier = goal.@male;
               }
               result = Global.avatarConfigSettings.getItemById(rewardIdentifier).toItemXML().@name;
            }
         }
         return result;
      }
      
      public function getDaysToCompleteForLevel(level:int) : Number
      {
         var daysToComplete:Number = 0;
         var levelXml:XML = this.getGoalLevelXML(level);
         if(Boolean(levelXml) && levelXml.hasOwnProperty(XMLKeys.ATTR_DAYS_TO_COMPLETE))
         {
            daysToComplete = Number(levelXml[XMLKeys.ATTR_DAYS_TO_COMPLETE]);
         }
         return daysToComplete;
      }
      
      public function getMaximumLevelRequirement() : int
      {
         var maxLevel:int = this.getHighestGoalLevel();
         return this.getRequirementByLevel(maxLevel);
      }
      
      public function hasTimerExpired() : Boolean
      {
         var startTime:Number = NaN;
         var endTime:Number = NaN;
         var result:Boolean = false;
         var featureFriendSet:FeatureFriendSet = this.m_friendSet as FeatureFriendSet;
         if(featureFriendSet)
         {
            startTime = featureFriendSet.getStartTime();
            if(startTime > 0)
            {
               endTime = startTime + FarmGameUtil.NUM_SECS_IN_DAY * this.getDaysForLevel(this.currentLevel);
               if(GlobalEngine.serverTime / 1000 > endTime)
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      public function getCostToCompleteLevel(level:int) : Number
      {
         var featureFriendSet:FeatureFriendSet = null;
         var numFriendsNeeded:Number = NaN;
         var cashCost:Number = 0;
         var costPerFriend:Number = 0;
         var levelXml:XML = this.getGoalLevelXML(level);
         if(Boolean(levelXml) && levelXml.hasOwnProperty(ATTR_CASH_COST_PER_FRIEND))
         {
            costPerFriend = Number(levelXml[ATTR_CASH_COST_PER_FRIEND]);
            featureFriendSet = this.m_friendSet as FeatureFriendSet;
            if(featureFriendSet)
            {
               numFriendsNeeded = this.getNumFriendsNeededForLevel(level) - featureFriendSet.numFriendsCompleted;
               if(numFriendsNeeded > 0)
               {
                  cashCost = costPerFriend * numFriendsNeeded;
               }
            }
         }
         return cashCost;
      }
      
      public function get buySlotCash() : int
      {
         return m_xml.buySlotCash ? int(m_xml.buySlotCash) : 0;
      }
   }
}

