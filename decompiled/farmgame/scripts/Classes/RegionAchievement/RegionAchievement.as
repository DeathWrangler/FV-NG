package Classes.RegionAchievement
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.FarmQuestSettingsInit;
   import Classes.Quest.FarmTask;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.RegionAchievementManager;
   import Managers.RegionAchievementsConfigManager;
   import ZQuest.Init.QuestSettingsInit;
   
   public class RegionAchievement
   {
      
      public static const BRONZE:String = "1";
      
      public static const SILVER:String = "2";
      
      public static const GOLD:String = "3";
      
      public static const INCOMPLETED_ICON:String = "icon_ic";
      
      public static const COMPLETED_ICON:String = "icon_c";
      
      public static const REWARD_WINDOW_ICON:String = "icon_r";
      
      private var m_featureName:String;
      
      private var m_regionId:String;
      
      private var m_name:String;
      
      private var m_questId:String;
      
      private var m_quest:FarmQuest;
      
      private var m_rewardItem:FarmItem;
      
      private var m_trophyWon:int = 0;
      
      private var m_isTimed:Boolean = false;
      
      private var m_regionAchievementMilestones:Vector.<RegionAchiemenetMilestone>;
      
      private var m_milestoneTypeMap:Object;
      
      public function RegionAchievement(featureName:String, config:Object, regionId:String)
      {
         var i:int = 0;
         var milestone:RegionAchiemenetMilestone = null;
         this.m_regionAchievementMilestones = new Vector.<RegionAchiemenetMilestone>();
         super();
         this.m_featureName = featureName;
         this.m_regionId = regionId;
         this.m_name = config.name;
         this.m_questId = config.questId;
         this.m_rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(config.itemCode);
         this.m_isTimed = false;
         if(config.hasOwnProperty("timed") && config.timed == true)
         {
            this.m_isTimed = true;
         }
         var milestonesConfig:Array = config[RegionAchievementsConfigManager.MILESTONE_CONFIG];
         this.m_milestoneTypeMap = {};
         if(this.quest)
         {
            this.updateQuestProgress();
            for(i = 0; i < milestonesConfig.length; i++)
            {
               milestone = new RegionAchiemenetMilestone(this.m_featureName,milestonesConfig[i],this.m_regionId,this.m_name,this.quest);
               this.m_milestoneTypeMap[milestone.type] = this.m_regionAchievementMilestones.push(milestone);
            }
         }
      }
      
      private function updateQuestProgress() : void
      {
         var questTask:FarmTask = null;
         var regionUnlocked:Boolean = RegionAchievementManager.getInstance(this.m_featureName).isRegionUnlocked(this.m_regionId);
         if(Boolean(this.quest && !FarmQuestManager.getInstance().isQuestActive(this.quest.name)) && Boolean(!this.timed) && regionUnlocked)
         {
            for each(questTask in this.quest.farmTasks)
            {
               questTask.setTaskProgressToTotal();
            }
         }
      }
      
      public function claimRewards() : Boolean
      {
         var claimed:Boolean = false;
         var updateBackend:Boolean = false;
         for(var i:int = 0; i < this.m_regionAchievementMilestones.length; i++)
         {
            claimed = this.m_regionAchievementMilestones[i].grandRewards();
            updateBackend ||= claimed;
         }
         return updateBackend;
      }
      
      private function grandTrophyReward() : void
      {
         Global.player.addGift(this.m_rewardItem.name);
      }
      
      public function milestoneRewardIconUrl(milestoneType:String) : String
      {
         var index:int = 0;
         var result:String = "";
         if(this.m_milestoneTypeMap.hasOwnProperty(milestoneType))
         {
            index = int(this.m_milestoneTypeMap[milestoneType]);
            result = this.m_regionAchievementMilestones[index - 1].rewardiconUrl;
         }
         return result;
      }
      
      public function getAndResetTrophyState(milestoneType:String, resetState:Boolean = true) : Boolean
      {
         var index:int = 0;
         var result:Boolean = false;
         if(this.m_milestoneTypeMap.hasOwnProperty(milestoneType))
         {
            index = int(this.m_milestoneTypeMap[milestoneType]);
            result = this.m_regionAchievementMilestones[index - 1].showRewardAnimation;
            if(resetState)
            {
               this.m_regionAchievementMilestones[index - 1].showRewardAnimation = false;
            }
         }
         return result;
      }
      
      public function isTrophyClaimed(milestoneType:String) : Boolean
      {
         var index:int = 0;
         var result:Boolean = false;
         if(this.m_milestoneTypeMap.hasOwnProperty(milestoneType))
         {
            index = int(this.m_milestoneTypeMap[milestoneType]);
            result = this.m_regionAchievementMilestones[index - 1].claimed;
         }
         return result;
      }
      
      public function get regionId() : String
      {
         return this.m_regionId;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get timed() : Boolean
      {
         return this.m_isTimed;
      }
      
      public function get quest() : FarmQuest
      {
         if(!this.m_quest)
         {
            this.m_quest = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getItemByName(this.m_questId) as FarmQuest;
         }
         return this.m_quest;
      }
      
      public function get guestName() : String
      {
         return this.m_questId;
      }
      
      public function get trophyWon() : int
      {
         return RegionAchievementManager.getInstance(this.m_featureName).getTrophyClaimedInAchievement(this.regionId,this.name);
      }
      
      public function get completed() : Boolean
      {
         return this.goldTrophyWon;
      }
      
      public function get goldTrophyWon() : Boolean
      {
         return this.trophyWon == RegionAchievementManager.GOLD_TROPHY;
      }
      
      public function get silverTrophyWon() : Boolean
      {
         return this.trophyWon == RegionAchievementManager.SILVER_TROPHY;
      }
      
      public function get bronzeTrophyWon() : Boolean
      {
         return this.trophyWon == RegionAchievementManager.BRONZE_TROPHY;
      }
      
      public function get rewardWindowTrophyUrl() : String
      {
         var result:String = "";
         if(this.m_rewardItem)
         {
            result = this.m_rewardItem.imageRelativeUrl(REWARD_WINDOW_ICON);
         }
         return result;
      }
      
      public function get trophyUrl() : String
      {
         var result:String = "";
         if(this.m_rewardItem)
         {
            if(this.goldTrophyWon)
            {
               result = this.m_rewardItem.imageRelativeUrl(COMPLETED_ICON);
            }
            else
            {
               result = this.m_rewardItem.imageRelativeUrl(INCOMPLETED_ICON);
            }
         }
         return result;
      }
      
      public function get canClaim() : Boolean
      {
         var result:Boolean = false;
         for(var i:int = 0; i < this.m_regionAchievementMilestones.length; i++)
         {
            if(this.m_regionAchievementMilestones[i].canClaim)
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      public function get canClaimGold() : Boolean
      {
         var index:int = 0;
         var result:Boolean = false;
         if(this.m_milestoneTypeMap.hasOwnProperty(GOLD))
         {
            index = int(this.m_milestoneTypeMap[GOLD]);
            result = this.m_regionAchievementMilestones[index - 1].canClaim;
         }
         return result;
      }
      
      public function get started() : Boolean
      {
         var timePassed:Number = (GlobalEngine.serverTime - this.quest.startTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return !this.timed || this.timed && timePassed > 0;
      }
      
      public function get active() : Boolean
      {
         return Boolean(this.quest) && this.started && !this.expired;
      }
      
      public function get expired() : Boolean
      {
         return !this.quest || this.timed && this.quest.timeRemaining <= 0;
      }
      
      public function get dismissed() : Boolean
      {
         return RegionAchievementManager.getInstance(this.m_featureName).isDismissedTimedAchievement(this.m_regionId);
      }
      
      public function get trophyTitle() : String
      {
         return this.m_rewardItem.friendlyTitle;
      }
      
      public function get trophyReward() : FarmItem
      {
         return this.m_rewardItem;
      }
      
      public function progressPercent() : Number
      {
         var milestone:RegionAchiemenetMilestone = null;
         var result:Number = 0;
         for each(milestone in this.m_regionAchievementMilestones)
         {
            result += milestone.progressPercent();
         }
         return result / this.m_regionAchievementMilestones.length;
      }
      
      private function getNextMilestone() : RegionAchiemenetMilestone
      {
         var milestone:RegionAchiemenetMilestone = null;
         if(this.goldTrophyWon || this.silverTrophyWon || this.timed)
         {
            milestone = this.getMilestoneByType(GOLD);
         }
         else if(this.bronzeTrophyWon)
         {
            milestone = this.getMilestoneByType(SILVER);
         }
         else
         {
            milestone = this.getMilestoneByType(BRONZE);
         }
         return milestone;
      }
      
      public function descriptionParams() : Object
      {
         var result:Object = new Object();
         var milestone:RegionAchiemenetMilestone = this.getNextMilestone();
         if(milestone)
         {
            result.description = milestone.description;
            result.includeRegionIcon = milestone.isRegionIconInDescription;
            result.regionId = milestone.regionIdInDescription;
            result.milestoneType = milestone.type;
         }
         return result;
      }
      
      public function get numOfMileStonesCompleted() : int
      {
         var milestone:RegionAchiemenetMilestone = null;
         var result:int = 0;
         for each(milestone in this.m_regionAchievementMilestones)
         {
            if(milestone.completed)
            {
               result++;
            }
         }
         return result;
      }
      
      public function get numOfMilestones() : int
      {
         return this.m_regionAchievementMilestones.length;
      }
      
      public function milestoneRewardName(milestoneType:String) : String
      {
         var result:String = "";
         var milestone:RegionAchiemenetMilestone = this.getMilestoneByType(milestoneType);
         if(milestone)
         {
            result = milestone.rewardName;
         }
         return result;
      }
      
      private function getMilestoneByType(milestoneType:String) : RegionAchiemenetMilestone
      {
         var index:int = 0;
         var result:RegionAchiemenetMilestone = null;
         if(this.m_milestoneTypeMap.hasOwnProperty(milestoneType))
         {
            index = int(this.m_milestoneTypeMap[milestoneType]);
            result = this.m_regionAchievementMilestones[index - 1];
         }
         return result;
      }
      
      public function get expiryTimerText() : String
      {
         return this.quest.getArrowExpiryString();
      }
      
      public function get expiryTimer() : String
      {
         var parsedTimeArr:Array = null;
         var startDate:Date = null;
         var month:String = null;
         var hours:String = null;
         var result:String = "";
         if(this.expired)
         {
            result = ZLocUtils.t("Dialogs",this.m_featureName + "_timed_ach_expired");
         }
         else if(!this.started)
         {
            startDate = new Date(this.quest.startTime);
            month = FarmGameUtil.convertMonthNumberToStringMonth(startDate.month);
            result = ZLocUtils.t("Dialogs",this.m_featureName + "_timed_ach_unlocks_on",{
               "date":FarmGameUtil.convertPositionToRankString(startDate.date),
               "month":month
            });
         }
         else
         {
            parsedTimeArr = FarmGameUtil.parseTimeLeft(this.quest.timeRemaining);
            if(parsedTimeArr[0] > 0)
            {
               result = FarmGameUtil.getTimeLeftTextInDays(parsedTimeArr[0]);
            }
            else
            {
               hours = result = FarmGameUtil.zeroPad(parsedTimeArr[1],2) + ":" + FarmGameUtil.zeroPad(parsedTimeArr[2],2) + ":" + FarmGameUtil.zeroPad(parsedTimeArr[3],2);
               result = ZLocUtils.t("Dialogs",this.m_featureName + "_timed_ach_hours_left",{"hours":hours});
            }
         }
         return result;
      }
      
      public function getProgressBarToolTip() : String
      {
         var progressRequired:int = 0;
         var postFix:String = null;
         var result:String = "";
         var nextMilestone:RegionAchiemenetMilestone = this.getNextMilestone();
         if(nextMilestone)
         {
            progressRequired = nextMilestone.progressRequired();
            postFix = ZLocUtils.t("Dialogs",this.m_featureName + "_trophy_progressbar_post_fix_" + nextMilestone.type);
            return ZLocUtils.t("Dialogs",this.m_featureName + "_trophy_progressbar_r" + this.regionId + "_a" + this.name,{
               "progressRequired":progressRequired,
               "postFix":postFix
            });
         }
         return result;
      }
      
      public function preloadAssets() : void
      {
         if(Boolean(this.quest) && Boolean(this.started) && !this.dismissed)
         {
            RegionAchievementManager.loadAsset(this.m_rewardItem.imageRelativeUrl(COMPLETED_ICON));
            RegionAchievementManager.loadAsset(this.m_rewardItem.imageRelativeUrl(INCOMPLETED_ICON));
            RegionAchievementManager.loadAsset(this.m_rewardItem.imageRelativeUrl(REWARD_WINDOW_ICON));
            RegionAchievementManager.loadAsset(this.milestoneRewardIconUrl(GOLD));
            RegionAchievementManager.loadAsset(this.milestoneRewardIconUrl(SILVER));
            RegionAchievementManager.loadAsset(this.milestoneRewardIconUrl(BRONZE));
         }
      }
   }
}

