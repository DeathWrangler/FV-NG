package Classes.breeding
{
   import Classes.Constants.QuestConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   
   public class AnimalBreedingSkillState
   {
      
      protected var m_xp:int;
      
      protected var m_level:int;
      
      protected var m_featureName:String;
      
      protected var m_milestonesAchieved:Array;
      
      public function AnimalBreedingSkillState(featureName:String)
      {
         super();
         this.m_xp = 0;
         this.m_level = 0;
         this.m_featureName = featureName;
         this.resetMilestoneCompletion();
      }
      
      public function initializeFromInitUser(skillStateResult:Object) : void
      {
         this.m_xp = skillStateResult.hasOwnProperty("xp") ? int(skillStateResult.xp) : 0;
         this.m_level = skillStateResult.hasOwnProperty("level") ? int(skillStateResult.level) : 1;
         this.m_featureName = skillStateResult.hasOwnProperty("featureName") ? skillStateResult.featureName : "";
         this.m_milestonesAchieved = skillStateResult.hasOwnProperty("milestones") ? skillStateResult.milestones : new Array();
         if(Boolean(skillStateResult.hasOwnProperty("initResults") && skillStateResult["initResults"].hasOwnProperty("levels")) && Boolean(skillStateResult["initResults"]["levels"] > 0) && this.m_level > 1)
         {
            UI.showMessage(ZLocUtils.t("Dialogs",this.m_featureName + "_friendsAdopted",{"quantity":skillStateResult["initResults"]["levels"]}));
         }
      }
      
      public function grantXp(amount:int) : void
      {
         this.m_xp += amount;
      }
      
      public function checkAndAwardLevel() : Object
      {
         var rewards:Array = null;
         var reward:Object = null;
         var nextLevelRewards:Object = null;
         var rewardType:String = null;
         var totalRewards:Object = new Object();
         var xpForNextLevel:int = Global.animalBreedingSettings.getXpForLevel(this.m_level + 1,this.m_featureName);
         if(this.m_xp >= xpForNextLevel)
         {
            this.m_xp -= xpForNextLevel;
            this.m_level += 1;
            this.resetMilestoneCompletion();
            rewards = Global.animalBreedingSettings.getRewardsForLevel(this.m_level,this.m_featureName);
            for each(reward in rewards)
            {
               this.grantReward(reward);
            }
            totalRewards["levelups"] = rewards;
            totalRewards["milestones"] = this.checkAndAwardMilestones();
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
      
      public function checkAndAwardMilestones() : Array
      {
         var reward:Object = null;
         var milestoneXpAmount:int = 0;
         var rewards:Array = new Array();
         var xpForNextLevel:int = Global.animalBreedingSettings.getXpForLevel(this.m_level + 1,this.m_featureName);
         var milestonesPerLevel:int = Global.animalBreedingSettings.getNumMilestonesPerLevel(this.m_featureName);
         for(var milestone:int = 0; milestone < this.m_milestonesAchieved.length; milestone++)
         {
            if(this.m_milestonesAchieved[milestone] == false)
            {
               milestoneXpAmount = xpForNextLevel / (milestonesPerLevel + 1) * (milestone + 1);
               if(this.m_xp >= milestoneXpAmount)
               {
                  this.m_milestonesAchieved[milestone] = true;
                  rewards = rewards.concat(Global.animalBreedingSettings.getMilestoneRewards(this.m_featureName));
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
         if(rewardDescription.hasOwnProperty("type"))
         {
            switch(rewardDescription["type"])
            {
               case QuestConstants.REWARD_GRANT_ITEM:
                  amount = rewardDescription.hasOwnProperty("quantity") ? int(rewardDescription["quantity"]) : 1;
                  Global.player.addGift(Global.farmGameSettingsManager.getFarmItemNameByCode(rewardDescription["value"]),"0",amount);
            }
         }
      }
      
      protected function resetMilestoneCompletion() : void
      {
         this.m_milestonesAchieved = new Array();
         var milestonesPerLevel:int = Global.animalBreedingSettings.getNumMilestonesPerLevel(this.m_featureName);
         for(var milestone:int = 0; milestone < milestonesPerLevel; milestone++)
         {
            this.m_milestonesAchieved.push(false);
         }
      }
      
      public function hasUnlockedReward(type:String, value:String) : Boolean
      {
         var result:Boolean = false;
         var levelRequiredForReward:int = Global.animalBreedingSettings.getLevelForReward(type,value,this.m_featureName);
         if(this.m_level >= levelRequiredForReward)
         {
            result = true;
         }
         return result;
      }
      
      public function getNumMilestonesAcheived() : int
      {
         var result:int = 0;
         for(var milestone:int = 0; milestone < this.m_milestonesAchieved.length; milestone++)
         {
            result += this.m_milestonesAchieved[milestone] == true ? 1 : 0;
         }
         return result;
      }
      
      public function getXpNeededForLevel(level:int) : int
      {
         return Global.animalBreedingSettings.getTotalXpForLevel(level,this.featureName) - this.cumulativeXp;
      }
      
      public function get xp() : int
      {
         return this.m_xp;
      }
      
      public function get level() : int
      {
         return this.m_level;
      }
      
      public function get cumulativeXp() : int
      {
         return this.xp + Global.animalBreedingSettings.getTotalXpForLevel(this.level,this.featureName);
      }
      
      public function get featureName() : String
      {
         return this.m_featureName;
      }
   }
}

