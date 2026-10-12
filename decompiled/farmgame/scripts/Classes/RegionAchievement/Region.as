package Classes.RegionAchievement
{
   import Classes.Avatar.AvatarItem;
   import Classes.Constants.QuestConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Managers.RegionAchievementManager;
   import Managers.RegionAchievementsConfigManager;
   
   public class Region
   {
      
      private static const CHEST_OPEN:String = "chest_open_150";
      
      private static const CHEST_CLOSED:String = "chest_close_150";
      
      private static const CHEST_OPEN_REWARD:String = "chest_close_200";
      
      private static const CHEST_CLOSED_REWARD:String = "chest_close_200";
      
      private static const TOTEM_IMAGE:String = "icon_r_150";
      
      private static const TOTEM_IMAGE_REWARD:String = "";
      
      private static var m_preloadedAssets:Boolean = false;
      
      private var m_featureName:String;
      
      private var m_unlocked:Boolean = false;
      
      private var m_id:String;
      
      private var m_name:String;
      
      private var m_shieldMileStone:int = 9999;
      
      private var m_shieldIcon:String = "";
      
      private var m_constumeIcon:String = "";
      
      private var m_shieldRewardWindowIcon:String = "";
      
      private var m_icon:String = "";
      
      private var m_totemIcon:String = "";
      
      private var m_totemItemCode:String;
      
      private var m_totemRewardWindowIcon:String = "";
      
      private var m_shieldWonIcon:String = "";
      
      private var m_extraRewardIcon:String = "";
      
      private var m_extraRewardName:String = "";
      
      private var m_specialTileName:String = "";
      
      private var m_specialTileItemName:String = "";
      
      private var m_constumeName:String = "";
      
      private var m_extraRewardItemCount:int = 0;
      
      private var m_shieldWonRewardWindowIcon:String = "";
      
      private var m_shieldRewards:Vector.<Object>;
      
      private var m_isShieldWon:Boolean = false;
      
      private var m_numAchievements:int = 0;
      
      private var m_numCompletedAchievements:int = 0;
      
      private var m_timedAchievement:RegionAchievement;
      
      private var m_regionAchievements:Array;
      
      private var m_activeRegionAchievements:Array;
      
      private var m_achievementIdToindex:Object;
      
      private var m_showShieldRewardWindow:Boolean = false;
      
      private var m_isInitRewardData:Boolean = false;
      
      public function Region(featureName:String, config:Object)
      {
         var totemItem:FarmItem = null;
         var specialTileItem:FarmItem = null;
         var achievement:RegionAchievement = null;
         this.m_regionAchievements = new Array();
         this.m_activeRegionAchievements = new Array();
         super();
         this.m_featureName = featureName;
         this.m_id = config.id;
         this.m_name = ZLocUtils.t("Dialogs",this.m_featureName + "_region_name_" + this.id);
         var shieldConfig:Object = config[RegionAchievementsConfigManager.SHIELD_CONFIG];
         if(shieldConfig)
         {
            this.m_shieldMileStone = shieldConfig.milestone;
            totemItem = Global.farmGameSettingsManager.getFarmItemByCode(shieldConfig.itemCode);
            if(totemItem)
            {
               this.m_totemItemCode = totemItem.code;
               this.m_shieldIcon = totemItem.imageRelativeUrl(CHEST_CLOSED);
               this.m_shieldRewardWindowIcon = totemItem.imageRelativeUrl(CHEST_CLOSED_REWARD);
               this.m_shieldWonIcon = totemItem.imageRelativeUrl(CHEST_OPEN);
               this.m_shieldWonRewardWindowIcon = totemItem.imageRelativeUrl(CHEST_OPEN_REWARD);
               this.m_totemIcon = totemItem.imageRelativeUrl(TOTEM_IMAGE);
               this.m_totemRewardWindowIcon = totemItem.iconUrl;
            }
            this.m_shieldRewards = shieldConfig.rewards;
            if(shieldConfig.hasOwnProperty("specialtile"))
            {
               specialTileItem = Global.farmGameSettingsManager.getFarmItemByCode(shieldConfig.specialtile);
               if(specialTileItem)
               {
                  this.m_specialTileName = specialTileItem.friendlyTitle;
                  this.m_specialTileItemName = specialTileItem.name;
               }
            }
         }
         var achievementsConfig:Array = config[RegionAchievementsConfigManager.ACHIEVEMENT_CONFIG];
         this.m_achievementIdToindex = {};
         for(var i:int = 0; i < achievementsConfig.length; i++)
         {
            achievement = new RegionAchievement(this.m_featureName,achievementsConfig[i],this.m_id);
            this.m_achievementIdToindex[achievement.name] = this.m_regionAchievements.push(achievement);
            if(achievement.timed)
            {
               this.m_timedAchievement = achievement;
            }
            else
            {
               this.m_activeRegionAchievements.push(achievement);
            }
         }
      }
      
      private function initRewardData() : void
      {
         var rewardObject:Object = null;
         var avatarItem:AvatarItem = null;
         var farmItem:FarmItem = null;
         if(Boolean(this.m_shieldRewards) && this.m_shieldRewards.length > 0)
         {
            for each(rewardObject in this.m_shieldRewards)
            {
               if(!(Boolean(rewardObject) && rewardObject.hasOwnProperty("type")))
               {
                  continue;
               }
               switch(rewardObject.type)
               {
                  case QuestConstants.REWARD_AVATAR_ITEM:
                     avatarItem = Global.avatarConfigSettings.getItemById(rewardObject.value);
                     if(avatarItem)
                     {
                        this.m_constumeIcon = avatarItem.iconPath;
                        this.m_constumeName = avatarItem.friendlyTitle;
                     }
                     break;
                  case QuestConstants.REWARD_WORLD_SCORE:
                     this.m_extraRewardIcon = Global.worldScoreSettingsManager.getIconForScoreUnit(rewardObject.unit);
                     this.m_extraRewardItemCount = rewardObject.value;
                     this.m_extraRewardName = ZLocUtils.t("FarmGame",rewardObject.unit);
                     break;
                  default:
                     farmItem = Global.farmGameSettingsManager.getFarmItemByCode(rewardObject.value);
                     if(farmItem)
                     {
                        this.m_extraRewardIcon = farmItem.icon;
                        this.m_extraRewardItemCount = int(rewardObject.quantity);
                        this.m_extraRewardName = farmItem.friendlyTitle;
                     }
               }
            }
            this.m_isInitRewardData = true;
         }
      }
      
      public function numOfAchievementsCompleted(includeTimedAchievement:Boolean = true) : int
      {
         var achievement:RegionAchievement = null;
         var result:int = 0;
         for(var i:int = 0; i < this.m_regionAchievements.length; i++)
         {
            achievement = this.m_regionAchievements[i] as RegionAchievement;
            if(!(!includeTimedAchievement && achievement.timed))
            {
               if(achievement.completed)
               {
                  result++;
               }
            }
         }
         return result;
      }
      
      public function canClaim() : Boolean
      {
         var achievement:RegionAchievement = null;
         var result:Boolean = false;
         for each(achievement in this.m_regionAchievements)
         {
            if(achievement.canClaim)
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      public function get id() : String
      {
         return this.m_id;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get rewards() : Vector.<Object>
      {
         return this.m_shieldRewards;
      }
      
      public function get timedAchievement() : RegionAchievement
      {
         return this.m_timedAchievement;
      }
      
      public function get achievements() : Array
      {
         return this.m_regionAchievements;
      }
      
      public function get activeAchievements() : Array
      {
         if(this.dismissedTimedAchievement)
         {
            return this.m_activeRegionAchievements;
         }
         return this.achievements;
      }
      
      public function get completed() : Boolean
      {
         var i:int = 0;
         var achievement:RegionAchievement = null;
         var result:Boolean = true;
         if(!this.shieldWon)
         {
            for(i = 0; i < this.achievements.length; i++)
            {
               achievement = this.achievements[i] as RegionAchievement;
               result &&= !achievement.timed && achievement.goldTrophyWon;
               if(!result)
               {
                  break;
               }
            }
         }
         return result;
      }
      
      public function get shieldWon() : Boolean
      {
         return RegionAchievementManager.getInstance(this.m_featureName).isShieldWonInRegion(this.id);
      }
      
      public function getAchievementById(achievementId:String) : RegionAchievement
      {
         var result:RegionAchievement = null;
         var index:int = int(this.m_achievementIdToindex[achievementId]);
         return this.m_regionAchievements[index - 1];
      }
      
      public function get showShieldRewardWindow() : Boolean
      {
         return this.m_showShieldRewardWindow;
      }
      
      public function set showShieldRewardWindow(value:Boolean) : void
      {
         this.m_showShieldRewardWindow = value;
      }
      
      private function canGrandShieldReward() : Boolean
      {
         var i:int = 0;
         var result:Boolean = false;
         var numAchievementsCompleted:int = 0;
         if(!this.shieldWon)
         {
            for(i = 0; i < this.m_regionAchievements.length; i++)
            {
               if((this.m_regionAchievements[i] as RegionAchievement).goldTrophyWon)
               {
                  numAchievementsCompleted++;
               }
            }
            if(numAchievementsCompleted >= this.m_shieldMileStone)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function checkAndGrandShieldRewad() : Boolean
      {
         var result:Boolean = false;
         if(this.canGrandShieldReward())
         {
            RegionAchievementManager.getInstance(this.m_featureName).setShieldWonInRegion(this.id);
            UserRewardUtil.grantUserRewards(this.m_shieldRewards);
            result = true;
         }
         return result;
      }
      
      public function get taskMilestoneCounterText() : String
      {
         var numCompleted:int = this.numOfAchievementsCompleted();
         return numCompleted.toString() + "/" + this.m_shieldMileStone.toString();
      }
      
      public function get costumeName() : String
      {
         if(!this.m_isInitRewardData)
         {
            this.initRewardData();
         }
         return this.m_constumeName;
      }
      
      public function get extraRewardQty() : int
      {
         if(!this.m_isInitRewardData)
         {
            this.initRewardData();
         }
         return this.m_extraRewardItemCount;
      }
      
      public function get extraRewardName() : String
      {
         if(!this.m_isInitRewardData)
         {
            this.initRewardData();
         }
         return this.m_extraRewardName;
      }
      
      public function get specialTileItemName() : String
      {
         return this.m_specialTileItemName;
      }
      
      public function get specialTileName() : String
      {
         return this.m_specialTileName;
      }
      
      public function get chestIcon() : String
      {
         return this.completed ? this.m_shieldWonIcon : this.m_shieldIcon;
      }
      
      public function get rewardWindowchestIcon() : String
      {
         return this.completed ? this.m_shieldWonRewardWindowIcon : this.m_shieldRewardWindowIcon;
      }
      
      public function get totemItem() : FarmItem
      {
         return Global.farmGameSettingsManager.getFarmItemByCode(this.m_totemItemCode);
      }
      
      public function get totemIcon() : String
      {
         return this.m_totemIcon;
      }
      
      public function get icon() : String
      {
         return this.m_icon;
      }
      
      public function get rewardWindowTotemIcon() : String
      {
         return this.m_totemRewardWindowIcon;
      }
      
      public function get costumeIcon() : String
      {
         if(!this.m_isInitRewardData)
         {
            this.initRewardData();
         }
         return this.m_constumeIcon;
      }
      
      public function get extraRewardIcon() : String
      {
         if(!this.m_isInitRewardData)
         {
            this.initRewardData();
         }
         return this.m_extraRewardIcon;
      }
      
      public function get shieldMilestone() : int
      {
         return this.m_shieldMileStone;
      }
      
      public function get dismissedTimedAchievement() : Boolean
      {
         return RegionAchievementManager.getInstance(this.m_featureName).isDismissedTimedAchievement(this.id);
      }
      
      public function get unlocked() : Boolean
      {
         return RegionAchievementManager.getInstance(this.m_featureName).isRegionUnlocked(this.id);
      }
      
      public function get chestName() : String
      {
         return ZLocUtils.t("Dialogs",this.m_featureName + "_ChestName_" + this.id);
      }
      
      public function getRegionUnlockTimerText() : String
      {
         var startDate:String = null;
         var startTimeMS:Number = NaN;
         var timeToUnlockMS:Number = NaN;
         var timeLeftArr:Array = null;
         var hours:String = null;
         var result:String = "";
         if(!this.unlocked)
         {
            startDate = RegionAchievementManager.getInstance(this.m_featureName).getRegionUnlockDate(this.id);
            startTimeMS = FarmGameUtil.synchronizedDateToNumber(startDate);
            timeToUnlockMS = (startTimeMS - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
            if(timeToUnlockMS > 0)
            {
               timeLeftArr = FarmGameUtil.parseTimeLeft(timeToUnlockMS);
               if(timeLeftArr[0] > 0)
               {
                  result = ZLocUtils.t("Dialogs",this.m_featureName + "_region_lockscreen_unlock_info",{
                     "days":timeLeftArr[0],
                     "hours":timeLeftArr[1]
                  });
               }
               else
               {
                  hours = FarmGameUtil.zeroPad(timeLeftArr[1],2) + ":" + FarmGameUtil.zeroPad(timeLeftArr[2],2);
                  result = ZLocUtils.t("Dialogs",this.m_featureName + "_region_lockscreen_unlock_info_hours",{
                     "days":timeLeftArr[0],
                     "hours":hours
                  });
               }
            }
         }
         return result;
      }
      
      public function preloadAssets() : void
      {
         var achievement:RegionAchievement = null;
         if(this.unlocked && !m_preloadedAssets)
         {
            RegionAchievementManager.loadAsset(this.m_icon);
            RegionAchievementManager.loadAsset(this.chestIcon);
            RegionAchievementManager.loadAsset(this.m_constumeIcon);
            for each(achievement in this.m_regionAchievements)
            {
               achievement.preloadAssets();
            }
            m_preloadedAssets = true;
         }
      }
   }
}

