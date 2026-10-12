package Classes.DragonBreeding
{
   import Classes.Constants.QuestConstants;
   import Classes.FeatureComponents.DragonBreedingState;
   import Classes.breeding.AnimalBreedingSkillState;
   import Managers.DragonBreedingConfigManager;
   import Managers.DragonBreedingManager;
   
   public class DragonBreedingSkillState extends AnimalBreedingSkillState
   {
      
      public static const NUM_SUITES_DEFAULT:int = 2;
      
      public static const REWARD_BREEDINGSTATION_UNLOCK:String = "breedingslot_unlock";
      
      private var m_unlockedSuites:int = 2;
      
      public function DragonBreedingSkillState(featureName:String)
      {
         m_featureName = featureName;
         super(featureName);
         m_level = 1;
      }
      
      public function get unlockedSuites() : int
      {
         var result:int = NUM_SUITES_DEFAULT;
         for(var i:int = NUM_SUITES_DEFAULT; i <= DragonBreedingState.MAX_SESSIONS; i++)
         {
            if(this.hasUnlockedReward(REWARD_BREEDINGSTATION_UNLOCK,i.toString()))
            {
               result = i;
            }
         }
         return result;
      }
      
      override public function checkAndAwardLevel() : Object
      {
         var totalRewards:Object = null;
         var xpForNextLevel:int = 0;
         var rewards:Array = null;
         var reward:Object = null;
         var nextLevelRewards:Object = null;
         var rewardType:String = null;
         xpForNextLevel = DragonBreedingConfigManager.getInstance(m_featureName).getXpForLevel(m_level);
         if(m_xp >= xpForNextLevel && m_level < DragonBreedingManager.MAX_LEVEL)
         {
            totalRewards = new Object();
            m_xp -= xpForNextLevel;
            m_level += 1;
            this.resetMilestoneCompletion();
            rewards = DragonBreedingConfigManager.getInstance(m_featureName).getRewardsForLevel(m_level);
            for each(reward in rewards)
            {
               this.grantReward(reward);
            }
            totalRewards["levelups"] = rewards;
            nextLevelRewards = this.checkAndAwardLevel();
            for(rewardType in nextLevelRewards)
            {
               if(totalRewards[rewardType] is Array)
               {
                  totalRewards[rewardType] = (totalRewards[rewardType] as Array).concat(nextLevelRewards[rewardType]);
               }
            }
         }
         return totalRewards;
      }
      
      override public function checkAndAwardMilestones() : Array
      {
         var reward:Object = null;
         var milestoneXpAmount:int = 0;
         var rewards:Array = new Array();
         var xpForNextLevel:int = DragonBreedingConfigManager.getInstance(m_featureName).getXpForLevel(m_level + 1);
         var milestonesPerLevel:int = DragonBreedingConfigManager.getInstance(m_featureName).getNumMilestonesPerLevel();
         for(var milestone:int = 0; milestone < m_milestonesAchieved.length; milestone++)
         {
            if(m_milestonesAchieved[milestone] == false)
            {
               milestoneXpAmount = xpForNextLevel / (milestonesPerLevel + 1) * (milestone + 1);
               if(m_xp >= milestoneXpAmount)
               {
                  m_milestonesAchieved[milestone] = true;
                  rewards = rewards.concat(DragonBreedingConfigManager.getInstance(m_featureName).getMilestoneRewards());
               }
            }
         }
         for each(reward in rewards)
         {
            this.grantReward(reward);
         }
         return rewards;
      }
      
      private function grantReward(rewardDescription:Object) : void
      {
         var amount:int = 0;
         var itemCode:String = null;
         var bigReward:Boolean = false;
         if(rewardDescription.hasOwnProperty("type"))
         {
            switch(rewardDescription["type"])
            {
               case QuestConstants.REWARD_GRANT_ITEM:
                  amount = rewardDescription.hasOwnProperty("quantity") ? int(rewardDescription["quantity"]) : 1;
                  itemCode = rewardDescription.hasOwnProperty("value") ? rewardDescription["value"] : "";
                  if(itemCode != "")
                  {
                     Global.player.addGift(Global.farmGameSettingsManager.getFarmItemNameByCode(rewardDescription["value"]),"0",amount);
                     bigReward = rewardDescription.hasOwnProperty(DragonBreedingManager.BIG_REWARD) ? Boolean(rewardDescription[DragonBreedingManager.BIG_REWARD]) : false;
                     if(bigReward)
                     {
                        DragonBreedingManager.getInstance(m_featureName).updateParentDragonItemCount(itemCode);
                     }
                  }
            }
         }
      }
      
      override protected function resetMilestoneCompletion() : void
      {
         m_milestonesAchieved = new Array();
         var milestonesPerLevel:int = DragonBreedingConfigManager.getInstance(m_featureName).getNumMilestonesPerLevel();
         for(var milestone:int = 0; milestone < milestonesPerLevel; milestone++)
         {
            m_milestonesAchieved.push(false);
         }
      }
      
      override public function hasUnlockedReward(type:String, value:String) : Boolean
      {
         var result:Boolean = false;
         var levelRequiredForReward:int = DragonBreedingConfigManager.getInstance(m_featureName).getLevelForReward(type,value);
         if(m_level >= levelRequiredForReward)
         {
            result = true;
         }
         return result;
      }
      
      override public function getNumMilestonesAcheived() : int
      {
         var result:int = 0;
         for(var milestone:int = 0; milestone < m_milestonesAchieved.length; milestone++)
         {
            result += m_milestonesAchieved[milestone] == true ? 1 : 0;
         }
         return result;
      }
      
      override public function getXpNeededForLevel(level:int) : int
      {
         return DragonBreedingConfigManager.getInstance(m_featureName).getTotalXpForLevel(level) - this.cumulativeXp;
      }
      
      override public function get cumulativeXp() : int
      {
         return xp + DragonBreedingConfigManager.getInstance(m_featureName).getTotalXpForLevel(level);
      }
      
      override public function initializeFromInitUser(skillStateResult:Object) : void
      {
         m_xp = skillStateResult.hasOwnProperty("xp") ? int(skillStateResult.xp) : 0;
         m_level = skillStateResult.hasOwnProperty("level") ? int(skillStateResult.level) : 1;
         if(m_level == 0)
         {
            m_level = 1;
         }
         m_featureName = skillStateResult.hasOwnProperty("featureName") ? skillStateResult.featureName : "";
         m_milestonesAchieved = skillStateResult.hasOwnProperty("milestones") ? skillStateResult.milestones : new Array();
         this.m_unlockedSuites = skillStateResult.hasOwnProperty("unlockedSuites") ? int(skillStateResult.unlockedSuites) : 2;
      }
   }
}

