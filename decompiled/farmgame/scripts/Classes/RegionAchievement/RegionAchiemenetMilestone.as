package Classes.RegionAchievement
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmTask;
   import Classes.ZItem.FarmItem;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Managers.RegionAchievementManager;
   
   public class RegionAchiemenetMilestone
   {
      
      private var m_featureName:String;
      
      private var m_regionId:String;
      
      private var m_achievementId:String;
      
      private var m_quest:FarmQuest;
      
      private var m_tasks:Vector.<Object>;
      
      private var m_rewards:Vector.<Object>;
      
      private var m_rewardItem:FarmItem;
      
      private var m_type:String = "0";
      
      private var m_animatedUIState:Boolean = false;
      
      private var m_regionIdInDesc:String = "";
      
      private var m_isRegionIconInDesc:Boolean = false;
      
      private var m_description:String = null;
      
      public function RegionAchiemenetMilestone(featureName:String, config:Object, regionid:String, achievementId:String, quest:FarmQuest)
      {
         super();
         this.m_featureName = featureName;
         this.m_type = config.id;
         this.m_rewards = config.rewards;
         this.m_rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_rewards[0].value);
         this.m_regionId = regionid;
         this.m_achievementId = achievementId;
         this.m_quest = quest;
         this.doTaskMap(config.tasks);
      }
      
      private function doTaskMap(tasks:Vector.<Object>) : void
      {
         var taskObj:Object = null;
         var task:FarmTask = null;
         this.m_tasks = new Vector.<Object>();
         for each(taskObj in tasks)
         {
            if(taskObj.hasOwnProperty("type"))
            {
               task = this.getTaskFromQuest(taskObj.type);
               if(task)
               {
                  taskObj.farmTask = task;
                  this.m_tasks.push(taskObj);
               }
            }
         }
      }
      
      private function getTaskFromQuest(taskType:String) : FarmTask
      {
         var task:FarmTask = null;
         var key:String = null;
         var result:FarmTask = null;
         var questTasks:Vector.<FarmTask> = this.m_quest.farmTasks;
         for each(task in questTasks)
         {
            key = task.action + "_" + task.type;
            if(key == taskType)
            {
               result = task;
               break;
            }
         }
         return result;
      }
      
      public function get completed() : Boolean
      {
         return this.isCompleted();
      }
      
      public function get canClaim() : Boolean
      {
         return this.completed && !this.claimed;
      }
      
      public function get claimed() : Boolean
      {
         return RegionAchievementManager.getInstance(this.m_featureName).getTrophyClaimedInAchievement(this.regionId,this.achievementId) >= int(this.type);
      }
      
      public function grandRewards() : Boolean
      {
         var result:Boolean = false;
         if(this.canClaim)
         {
            if(Boolean(this.m_rewards) && this.m_rewards.length > 0)
            {
               UserRewardUtil.grantUserRewards(this.m_rewards);
               RegionAchievementManager.getInstance(this.m_featureName).completeMilestone(this.regionId,this.achievementId,this.type);
               this.showRewardAnimation = true;
               result = true;
            }
         }
         return result;
      }
      
      public function get achievementId() : String
      {
         return this.m_achievementId;
      }
      
      public function get regionId() : String
      {
         return this.m_regionId;
      }
      
      public function get type() : String
      {
         return this.m_type;
      }
      
      public function get showRewardAnimation() : Boolean
      {
         return this.m_animatedUIState;
      }
      
      public function set showRewardAnimation(value:Boolean) : void
      {
         this.m_animatedUIState = value;
      }
      
      private function isCompleted() : Boolean
      {
         var taskObj:Object = null;
         var farmTask:FarmTask = null;
         var milestone:int = 0;
         var result:Boolean = false;
         if(this.m_tasks.length > 0)
         {
            result = true;
            for each(taskObj in this.m_tasks)
            {
               farmTask = taskObj.farmTask as FarmTask;
               if(!farmTask)
               {
                  result = false;
                  break;
               }
               milestone = int(taskObj.total);
               result &&= milestone <= farmTask.progress;
               if(result == false)
               {
                  break;
               }
            }
         }
         return result;
      }
      
      public function progressPercent() : Number
      {
         var taskObj:Object = null;
         var farmTask:FarmTask = null;
         var result:Number = 0;
         var isCliamed:Boolean = this.claimed;
         for each(taskObj in this.m_tasks)
         {
            farmTask = taskObj.farmTask as FarmTask;
            if(isCliamed)
            {
               result += 1;
            }
            else
            {
               result += farmTask.progress / taskObj.total;
            }
         }
         return result / this.m_tasks.length;
      }
      
      public function progressRequired() : int
      {
         var taskObj:Object = null;
         var farmTask:FarmTask = null;
         var result:int = 0;
         var isCliamed:Boolean = this.claimed;
         for each(taskObj in this.m_tasks)
         {
            farmTask = taskObj.farmTask as FarmTask;
            if(isCliamed)
            {
               result += 0;
            }
            else
            {
               result += taskObj.total - farmTask.progress;
            }
         }
         return result;
      }
      
      public function get rewardiconUrl() : String
      {
         return UserRewardUtil.getImageForReward(this.m_rewards[0]);
      }
      
      public function get rewardName() : String
      {
         return this.m_rewardItem.friendlyTitle;
      }
      
      private function updateTaskDescription() : void
      {
         var taskDesc:String = this.getTaskDescription();
         var match:Array = taskDesc.match(this.regex);
         if(Boolean(match) && match.length == 2)
         {
            this.m_isRegionIconInDesc = true;
            this.m_regionIdInDesc = match[1];
         }
         this.m_description = this.formatText(taskDesc);
      }
      
      public function get description() : String
      {
         if(this.m_description == null)
         {
            this.updateTaskDescription();
         }
         return this.m_description;
      }
      
      private function getTaskDescription() : String
      {
         var resource:String = this.descriptionKey();
         var params:Object = this.getMilestoneReplacementObj();
         if(this.m_isRegionIconInDesc)
         {
            params.regionName = RegionAchievementManager.getInstance(this.m_featureName).getRegionNameById(this.m_regionIdInDesc);
         }
         return ZLocUtils.t("Quests",resource,params);
      }
      
      public function get isRegionIconInDescription() : Boolean
      {
         return this.m_isRegionIconInDesc;
      }
      
      public function get regionIdInDescription() : String
      {
         return this.m_regionIdInDesc;
      }
      
      private function formatText(desc:String) : String
      {
         var regionName:String = RegionAchievementManager.getInstance(this.m_featureName).getRegionNameById(this.m_regionIdInDesc);
         return desc.replace(this.regex,regionName);
      }
      
      private function get regex() : RegExp
      {
         return /{_(\d+)}/;
      }
      
      private function descriptionKey() : String
      {
         var result:String = "";
         if(Boolean(this.m_tasks) && this.m_tasks.length > 0)
         {
            result = this.m_quest.name + "_" + this.m_tasks[0].type + "_" + "Flavor" + "_" + this.type;
         }
         return result;
      }
      
      private function getMilestoneReplacementObj() : Object
      {
         var i:int = 0;
         var result:Object = {};
         if(Boolean(this.m_tasks) && this.m_tasks.length > 0)
         {
            for(i = 0; i < this.m_tasks.length; i++)
            {
               result["milestone_" + (i + 1).toString()] = this.m_tasks[i].total;
            }
         }
         return result;
      }
   }
}

