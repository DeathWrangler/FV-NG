package Managers
{
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   
   public class RegionAchievementsConfigManager
   {
      
      public static const REGION_CONFIG:String = "regionConfig";
      
      public static const CHAMPION_CONFIG:String = "championConfig";
      
      public static const SPECIAL_REWARD_CONFIG:String = "specialRewards";
      
      public static const MILESTONE_CONFIG:String = "milestonesConfig";
      
      public static const SHIELD_CONFIG:String = "shieldConfig";
      
      public static const ACHIEVEMENT_CONFIG:String = "achievementsConfig";
      
      public static const DIALOG_CONFIG:String = "dialogConfigdialogConfig";
      
      private static var m_instances:Array = new Array();
      
      private var m_featureName:String;
      
      private var m_featureHash:Object = {};
      
      public function RegionAchievementsConfigManager(featureName:String)
      {
         super();
         this.m_featureName = featureName;
         this.parseConfig();
      }
      
      public static function getInstance(featureName:String) : RegionAchievementsConfigManager
      {
         if(m_instances[featureName] == null)
         {
            m_instances[featureName] = new RegionAchievementsConfigManager(featureName);
         }
         return m_instances[featureName];
      }
      
      private static function parseRegionXML(regionXML:XML) : Object
      {
         var achievementXML:XML = null;
         var achievementObj:Object = null;
         var regObj:Object = {};
         regObj.id = int(regionXML.@id);
         regObj.name = int(regionXML.@name);
         regObj[SHIELD_CONFIG] = RegionAchievementsConfigManager.parseShieldXML(regionXML.shield[0]);
         var achievements:Array = new Array();
         for each(achievementXML in regionXML.achievements.achievement)
         {
            achievementObj = RegionAchievementsConfigManager.parseAchievementConfig(achievementXML);
            achievements.push(achievementObj);
         }
         regObj[ACHIEVEMENT_CONFIG] = achievements;
         return regObj;
      }
      
      private static function parseChampionXML(championXML:XML) : Object
      {
         var championObj:Object = {};
         championObj.iconUrl = championXML.@iconUrl;
         championObj.name = championXML.@name;
         championObj.milestone = championXML.@milestone;
         championObj.rewards = UserRewardUtil.getRewardsVectorFromXml(championXML.rewards[0]);
         return championObj;
      }
      
      private static function parseSpecialRewardXML(specialRewardXML:XML) : Object
      {
         var specialRewardObj:Object = {};
         if(specialRewardXML)
         {
            specialRewardXML.motdSeeenFlag = specialRewardXML.@motdSeeenFlag;
            specialRewardObj.rewards = UserRewardUtil.getRewardsVectorFromXml(specialRewardXML.rewards[0]);
         }
         return specialRewardObj;
      }
      
      private static function parseShieldXML(shieldXML:XML) : Object
      {
         var shieldObj:Object = {};
         shieldObj.itemCode = shieldXML.@itemCode;
         shieldObj.name = shieldXML.@name;
         shieldObj.milestone = shieldXML.@milestone;
         shieldObj.specialtile = shieldXML.@specialtile;
         shieldObj.motdSeeenFlag = shieldXML.@motdSeeenFlag;
         shieldObj.rewards = UserRewardUtil.getRewardsVectorFromXml(shieldXML.rewards[0]);
         return shieldObj;
      }
      
      private static function parseAchievementConfig(achievementXML:XML) : Object
      {
         var milestoneXML:XML = null;
         var milestoneObj:Object = null;
         var achObj:Object = {};
         achObj.name = achievementXML.@name;
         achObj.questId = achievementXML.@questId;
         achObj.itemCode = achievementXML.@itemCode;
         achObj.timed = achievementXML.@timed;
         var milestones:Array = new Array();
         for each(milestoneXML in achievementXML.milestones.milestone)
         {
            milestoneObj = RegionAchievementsConfigManager.parseMileStoneConfig(milestoneXML);
            milestones.push(milestoneObj);
         }
         achObj[MILESTONE_CONFIG] = milestones;
         return achObj;
      }
      
      private static function parseMileStoneConfig(milestoneXML:XML) : Object
      {
         var milestoneObj:Object = {};
         milestoneObj.id = milestoneXML.@id;
         milestoneObj.rewards = UserRewardUtil.getRewardsVectorFromXml(milestoneXML.rewards[0]);
         milestoneObj.tasks = RegionAchievementsConfigManager.getTasksVectorFromXml(milestoneXML.tasks[0]);
         return milestoneObj;
      }
      
      private static function getTasksVectorFromXml(tasksXML:XML) : Vector.<Object>
      {
         var xmlTasks:XMLList = null;
         var rewardNode:XML = null;
         var tasks:Vector.<Object> = new Vector.<Object>();
         if(tasksXML != null)
         {
            xmlTasks = tasksXML.descendants("task");
            if(xmlTasks)
            {
               for each(rewardNode in xmlTasks)
               {
                  tasks.push(FarmGameUtil.xmlNodeToAttributes(rewardNode));
               }
            }
         }
         return tasks;
      }
      
      private function parseConfig() : void
      {
         var regionXml:XML = null;
         var dialogConfig:Object = null;
         var regObj:Object = null;
         var feature:XML = Global.farmGameSettingsManager.getRegionAchievementData(this.m_featureName);
         if(feature == null)
         {
            throw new Error("Feature config xml not found for Region Achievement.");
         }
         var regionAchievementConfig:Object = {};
         regionAchievementConfig[CHAMPION_CONFIG] = RegionAchievementsConfigManager.parseChampionXML(feature.champion[0]);
         regionAchievementConfig[SPECIAL_REWARD_CONFIG] = RegionAchievementsConfigManager.parseSpecialRewardXML(feature.specialRewards[0]);
         var region:Array = new Array();
         for each(regionXml in feature.regions.region)
         {
            regObj = RegionAchievementsConfigManager.parseRegionXML(regionXml);
            region.push(regObj);
         }
         regionAchievementConfig[REGION_CONFIG] = region;
         dialogConfig = {};
         dialogConfig.dialogUrl = feature.@dialogUrl;
         regionAchievementConfig[DIALOG_CONFIG] = dialogConfig;
         this.m_featureHash[this.m_featureName] = regionAchievementConfig;
      }
      
      public function getDialogUrl() : String
      {
         var result:String = null;
         if(this.m_featureHash[this.m_featureName] != null && Boolean(this.m_featureHash[this.m_featureName].hasOwnProperty(DIALOG_CONFIG)))
         {
            result = this.m_featureHash[this.m_featureName][DIALOG_CONFIG].dialogUrl;
         }
         return result;
      }
      
      public function getRegionData() : Array
      {
         var result:Array = null;
         if(this.m_featureHash[this.m_featureName] != null && Boolean(this.m_featureHash[this.m_featureName].hasOwnProperty(REGION_CONFIG)))
         {
            result = this.m_featureHash[this.m_featureName][REGION_CONFIG];
         }
         return result;
      }
      
      public function getChampionData() : Object
      {
         var result:Object = null;
         if(this.m_featureHash[this.m_featureName] != null && Boolean(this.m_featureHash[this.m_featureName].hasOwnProperty(CHAMPION_CONFIG)))
         {
            result = this.m_featureHash[this.m_featureName][CHAMPION_CONFIG];
         }
         return result;
      }
      
      public function getSpecialRewardConfig() : Object
      {
         var result:Object = null;
         if(this.m_featureHash[this.m_featureName] != null && Boolean(this.m_featureHash[this.m_featureName].hasOwnProperty(SPECIAL_REWARD_CONFIG)))
         {
            result = this.m_featureHash[this.m_featureName][SPECIAL_REWARD_CONFIG];
         }
         return result;
      }
      
      public function getFeatureConfigData() : Object
      {
         var result:Object = {};
         if(this.m_featureHash[this.m_featureName] != null)
         {
            result = this.m_featureHash[this.m_featureName];
         }
         return result;
      }
   }
}

