package Managers
{
   import Classes.Constants.PrerequisiteConstants;
   import Classes.FeatureBuildingOpenUIOnClick;
   import Classes.MultiRewardTreasureConstructionBuilding;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmTask;
   import Classes.RegionAchievement.Region;
   import Classes.RegionAchievement.RegionAchievement;
   import Classes.RegionAchievement.RegionAchievementAction;
   import Classes.ZItem.ExpansionData;
   import Classes.ZItem.FarmItem;
   import Classes.util.UserRewardUtil;
   import Display.HUD.HUDWidgets.HudBottomAchievementButton;
   import Display.MOTD;
   import Display.QueuedIcons.QueuedIconWithArrow;
   import Display.UI;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Events.RegionAchievementEvent;
   import Transactions.TGenericTransaction;
   import Transactions.TGetMOTD;
   import Widgets.Windows.RegionAchievement.RegionAchievementChampionWindow;
   import Widgets.Windows.RegionAchievement.RegionAchievementShieldRewardWindow;
   import Widgets.Windows.RegionAchievement.RegionAchievementSmallRelicWindow;
   import Widgets.Windows.RegionAchievement.RegionAchievementSpecialRewardWindow;
   import Widgets.Windows.RegionAchievement.RegionAchievementTabbedWindow;
   import Widgets.Windows.RegionAchievement.RegionAchievementWindow;
   import ZQuest.Events.QuestEvent;
   import ZQuest.Managers.QuestManager;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class RegionAchievementManager
   {
      
      private static const CHAMPION_DLG_URL:String = "assets/dialogs/RegionAchievement/FV_xjp_Achievements_FinalReward_2015.swf";
      
      private static const SPECIAL_REWARD_DLG_URL:String = "assets/dialogs/RegionAchievement/FV_xjp_Achievements_LicenseReward_2015.swf";
      
      public static const ACHIEVEMENT_TUTORIAL_URL:String = "assets/dialogs/RegionAchievement/FV_xjp_Achievements_FTUE_2015.swf";
      
      public static const ACHIEVEMENT_TABBED_WINDOW_URL:String = "assets/dialogs/RegionAchievement/FV_xjp_Achievements_TabbedWindow_2015.swf";
      
      public static const ACHIEVEMENT_TROPY_REWARD_WINDOW_URL:String = "assets/dialogs/RegionAchievement/FV_xjp_Achievements_SmallTrophy_2015.swf";
      
      public static const ACHIEVEMENT_SHIELD_REWARD_WINDOW_URL:String = "assets/dialogs/RegionAchievement/FV_xjp_Achievements_MediumTrophy_2015.swf";
      
      public static const ACHIEVEMENT_FAQ_URL:String = "https://zyngasupport.helpshift.com/a/farmville/?s=faq-the-story-of-sakura&f=faq---achievements";
      
      public static const FO_FEATURE:String = "region_ach";
      
      public static const FO_REGION_SHIED_WON:String = "SW";
      
      public static const FO_REGION_COMPLETE:String = "RC";
      
      public static const FO_ACHIEVEMENTS:String = "ACH";
      
      public static const FO_CHAMPION_WON:String = "CW";
      
      public static const FO_SPECIAL_REWARD_WON:String = "SRW";
      
      public static const FO_DISMISSED_TIMED_ACHIEVEMENT:String = "DTA";
      
      public static const ALL_REGION_COMPLETED:String = "ARC";
      
      public static const SERVICE_CLASS:String = "RegionAchievementsService";
      
      public static const ON_CLAIM_ACHIEVEMENT_REWARD:String = "onClaim";
      
      public static const ACTION_SHARE_BRAG_FEED:String = "onBragFeed";
      
      public static const BRAG_FEED_TROPHY:String = "japanRALevelShareReward";
      
      public static const FEATURE_NAME:String = "japanRA";
      
      public static const ON_DISMISS_ACHIEVEMENT:String = "onDismiss";
      
      private static var m_instance:RegionAchievementManager = null;
      
      public static const GET_COMPLETED_TIMED_ACHIEVEMENTS:String = "onGetCompletedTimedAchievementQuestIds";
      
      private static const INCSLUDE_COMPLETED_TIMED_ACHIEVEMENTS:Boolean = true;
      
      public static const NONE_TROPHY:int = 0;
      
      public static const BRONZE_TROPHY:int = 1;
      
      public static const SILVER_TROPHY:int = 2;
      
      public static const GOLD_TROPHY:int = 3;
      
      private static var m_initialized:Boolean = false;
      
      protected var m_featureName:String;
      
      private var m_actionQueue:Array = new Array();
      
      private var m_regionAchievementWindow:RegionAchievementWindow;
      
      private var m_taskWindow:RegionAchievementTabbedWindow;
      
      private var m_championWindow:RegionAchievementChampionWindow;
      
      private var m_specialRewardWindow:RegionAchievementSpecialRewardWindow;
      
      private var m_smallRelicWindow:RegionAchievementSmallRelicWindow;
      
      private var m_shieldRewardWindow:RegionAchievementShieldRewardWindow;
      
      private var m_regions:Array;
      
      private var m_regionIdmap:Object;
      
      private var m_assetUrl:String;
      
      private var m_championMilestone:int;
      
      private var m_championRewards:Vector.<Object>;
      
      private var m_specialRewards:Vector.<Object>;
      
      private var m_specialRewardMTD:String;
      
      private var m_eventManager:EventDispatcher;
      
      private var m_bragFeedTrophyName:String;
      
      private var m_regionUnlockDates:Object;
      
      protected var m_icon:QueuedIconWithArrow;
      
      public function RegionAchievementManager(key:SingletonEnforcer, featureName:String = "japanRA")
      {
         super();
         GlobalEngine.assert(key != null,"[RegionAchievementManager] :: Use getInstance()");
         this.m_featureName = featureName;
      }
      
      public static function getInstance(featureName:String = "japanRA") : RegionAchievementManager
      {
         if(m_instance == null)
         {
            m_instance = new RegionAchievementManager(new SingletonEnforcer(),featureName);
         }
         if(!isInitialized())
         {
            m_initialized = true;
            m_instance.init();
         }
         return m_instance;
      }
      
      private static function isInitialized() : Boolean
      {
         return m_initialized;
      }
      
      public static function loadAsset(url:String, onLoadCallback:Function = null) : void
      {
         var loadUrl:String = null;
         if(Boolean(url) && url != "")
         {
            loadUrl = url;
            if(!url.indexOf("http://") == 0 && !url.indexOf("https://") == 0)
            {
               loadUrl = Global.getAssetURL(loadUrl);
            }
            LoadingManager.load(loadUrl,onLoadCallback);
         }
      }
      
      public function init() : void
      {
         var region:Region = null;
         this.m_assetUrl = RegionAchievementsConfigManager.getInstance(this.m_featureName).getDialogUrl();
         var regionConfig:Array = RegionAchievementsConfigManager.getInstance(this.m_featureName).getRegionData();
         this.m_regions = new Array();
         this.m_regionIdmap = {};
         for(var i:int = 0; i < regionConfig.length; i++)
         {
            region = new Region(this.m_featureName,regionConfig[i]);
            this.m_regionIdmap[region.id] = this.m_regions.push(region);
         }
         var championConfig:Object = RegionAchievementsConfigManager.getInstance(this.m_featureName).getChampionData();
         this.m_championMilestone = championConfig.milestone;
         this.m_championRewards = championConfig.rewards as Vector.<Object>;
         var specialRewardConfig:Object = RegionAchievementsConfigManager.getInstance(this.m_featureName).getSpecialRewardConfig();
         this.m_specialRewards = specialRewardConfig.rewards as Vector.<Object>;
         this.m_specialRewardMTD = specialRewardConfig.motdSeeenFlag;
         this.initEventListeners();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,GET_COMPLETED_TIMED_ACHIEVEMENTS,this.onGetCompletedTAQuestIds,[this.m_featureName]));
      }
      
      private function initEventListeners() : void
      {
         this.addRegionAchievementEventListner(RegionAchievementEvent.CHAMPION_ICON_CLK,this.showChampionRewardWindow);
         this.addRegionAchievementEventListner(RegionAchievementEvent.REFRESH_UI,this.refreshWindow);
         this.addRegionAchievementEventListner(RegionAchievementEvent.UPDATE_HUD,this.updateHud);
         this.addRegionAchievementEventListner(RegionAchievementEvent.EXECUTE_NEXT_ACTION,this.executeNextAction);
         this.addRegionAchievementEventListner(RegionAchievementEvent.TOGGLE_MAIN_WINDOW_NPC,this.toggleMainWindowNPC);
         QuestManager.getInstance().addEventListener(QuestEvent.PROGRESS,this.onQuestUpdates);
         QuestManager.getInstance().addEventListener(QuestEvent.COMPLETED,this.onQuestUpdates);
      }
      
      public function removeEventListeners() : void
      {
         if(this.m_eventManager)
         {
            this.m_eventManager.removeEventListener(RegionAchievementEvent.CHAMPION_ICON_CLK,this.showChampionRewardWindow);
            this.m_eventManager.removeEventListener(RegionAchievementEvent.REFRESH_UI,this.refreshWindow);
            this.m_eventManager.removeEventListener(RegionAchievementEvent.UPDATE_HUD,this.updateHud);
            this.m_eventManager.removeEventListener(RegionAchievementEvent.EXECUTE_NEXT_ACTION,this.executeNextAction);
            this.m_eventManager.removeEventListener(RegionAchievementEvent.TOGGLE_MAIN_WINDOW_NPC,this.toggleMainWindowNPC);
         }
         this.m_eventManager = null;
         QuestManager.getInstance().removeEventListener(QuestEvent.PROGRESS,this.onQuestUpdates);
         QuestManager.getInstance().removeEventListener(QuestEvent.COMPLETED,this.onQuestUpdates);
      }
      
      public function addRegionAchievementEventListner(eventType:String, callback:Function) : void
      {
         if(!this.m_eventManager)
         {
            this.m_eventManager = new EventDispatcher();
         }
         this.m_eventManager.addEventListener(eventType,callback);
      }
      
      public function dispatchRegionAchievementEvent(event:RegionAchievementEvent) : void
      {
         if(this.m_eventManager)
         {
            this.m_eventManager.dispatchEvent(event);
         }
      }
      
      private function onQuestUpdates(event:QuestEvent) : void
      {
         if(this.isAchievementProgress(event.quest.name))
         {
            this.dispatchRegionAchievementEvent(new RegionAchievementEvent(RegionAchievementEvent.UPDATE_HUD));
         }
      }
      
      private function isAchievementProgress(questName:String) : Boolean
      {
         var region:Region = null;
         var achievement:RegionAchievement = null;
         var result:Boolean = false;
         for each(region in this.regions)
         {
            if(region.unlocked)
            {
               for each(achievement in region.achievements)
               {
                  if(achievement.active && achievement.guestName == questName && achievement.canClaim)
                  {
                     result = true;
                     break;
                  }
               }
               if(result == true)
               {
                  break;
               }
            }
         }
         return result;
      }
      
      private function updateHud(event:RegionAchievementEvent) : void
      {
         var state:int = this.getHudIconState();
         Global.hud.refreshAchievementHud(state);
      }
      
      public function getHudIconState() : int
      {
         var region:Region = null;
         var achievement:RegionAchievement = null;
         var state:int = HudBottomAchievementButton.STATE_IDLE;
         for each(region in this.regions)
         {
            if(region.unlocked)
            {
               for each(achievement in region.achievements)
               {
                  if(achievement.active && achievement.canClaim)
                  {
                     state = HudBottomAchievementButton.STATE_HARVEST_NOTIF;
                     break;
                  }
               }
            }
         }
         return state;
      }
      
      public function get regions() : Array
      {
         return this.m_regions;
      }
      
      public function get championMilestone() : int
      {
         return this.m_championMilestone;
      }
      
      public function getRegionById(regionId:String = "") : Region
      {
         var index:int = 0;
         var result:Region = null;
         if(regionId == "")
         {
            result = this.m_regions[0];
         }
         else if(this.m_regionIdmap.hasOwnProperty(regionId))
         {
            index = int(this.m_regionIdmap[regionId]);
            result = this.m_regions[index - 1];
         }
         return result;
      }
      
      public function getRegionIdByTotemName(totemItemName:String) : String
      {
         var reg:Region = null;
         var result:String = null;
         for each(reg in this.m_regions)
         {
            if(reg.totemItem.name == totemItemName)
            {
               result = reg.id;
               break;
            }
         }
         return result;
      }
      
      public function getRegionNameById(regionId:String) : String
      {
         var result:String = "";
         if(regionId != "")
         {
            result = this.getRegionById(regionId).name;
         }
         return result;
      }
      
      public function getRegionAchievementsByRegionId(regionId:String) : Array
      {
         var region:Region = this.getRegionById(regionId);
         return region.achievements;
      }
      
      public function getActiveRegionAchievementsByRegionId(regionId:String) : Array
      {
         var region:Region = this.getRegionById(regionId);
         return region.activeAchievements;
      }
      
      public function getRegionAchievementByAchievementId(regionId:String, achievementId:String) : RegionAchievement
      {
         var region:Region = this.getRegionById(regionId);
         return region.getAchievementById(achievementId);
      }
      
      public function onClaimCallback(result:Object) : void
      {
      }
      
      public function panToTotem(specialTileName:String) : void
      {
         var totemName:String = specialTileName.replace("_rubbletreasure","");
         var specialTileGameObjects:Array = Global.world.getObjectsByName(totemName);
         if(Boolean(specialTileGameObjects) && specialTileGameObjects.length > 0)
         {
            ItemFinderManager.getInstance().highlightWorldItems(totemName);
         }
      }
      
      public function claimAchievementRewards(regionId:String, achievementId:String) : void
      {
         var regionAchievement:RegionAchievement = null;
         var updateBackend:Boolean = false;
         var actionData:Object = null;
         var allShieldsWon:Boolean = false;
         var featureData:Object = null;
         var region:Region = this.getRegionById(regionId);
         if(region)
         {
            regionAchievement = region.getAchievementById(achievementId);
            updateBackend = false;
            if(regionAchievement)
            {
               updateBackend = regionAchievement.claimRewards();
               actionData = {
                  "regionId":regionId,
                  "achievementId":achievementId
               };
               this.addAction(RegionAchievementAction.SHOW_SMALL_RELIC_REWARD_WINDOW,actionData);
            }
            if(updateBackend)
            {
               if(region.checkAndGrandShieldRewad())
               {
                  this.addAction(RegionAchievementAction.SHOW_MEDIUM_RELIC_REWARD_WINDOW,actionData);
                  this.addAction(RegionAchievementAction.CHECKOUT_REGION_SPECIAL_TILE,actionData);
               }
               if(this.canGrandSpecialReward())
               {
                  this.grandSpecialReward();
                  this.addAction(RegionAchievementAction.SHOW_SPECIAL_REWARD_WINDOW,actionData);
                  this.addAction(RegionAchievementAction.SHOW_MOTD,{"motdName":this.m_specialRewardMTD});
               }
               if(this.canGrandChampionTrophy())
               {
                  this.grandChanmpionTrophyAndRewards();
                  this.closeWindow();
                  this.addAction(RegionAchievementAction.SHOW_CHAMPION_REWARD_WINDOW,null);
                  this.addAction(RegionAchievementAction.SHOW_SPECIAL_TILES,{"buildingName":region.specialTileItemName});
               }
               allShieldsWon = RegionAchievementManager.getInstance(this.m_featureName).areAllShieldsWon();
               if(allShieldsWon == true)
               {
                  featureData = FeatureOptionsManager.getInstance().getFeatureOption(RegionAchievementManager.FO_FEATURE,RegionAchievementManager.FEATURE_NAME);
                  featureData[RegionAchievementManager.ALL_REGION_COMPLETED] = "1";
                  FeatureOptionsManager.getInstance().setFeatureOption(RegionAchievementManager.FO_FEATURE,RegionAchievementManager.FEATURE_NAME,featureData);
               }
               this.addAction(RegionAchievementAction.REFRESH_MAIN_WINDOW,null);
               this.addAction(RegionAchievementAction.REFRESH_HUD,null);
            }
         }
         this.executeNextAction();
         if(updateBackend)
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,ON_CLAIM_ACHIEVEMENT_REWARD,this.onClaimCallback,[this.m_featureName,regionId,achievementId]));
         }
      }
      
      private function getFeatureOption() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(FO_FEATURE,this.m_featureName);
      }
      
      private function getRegionDataFromFO(regionId:String) : Object
      {
         var result:Object = null;
         var featureOption:Object = this.getFeatureOption();
         if(Boolean(featureOption) && featureOption.hasOwnProperty(regionId))
         {
            result = featureOption[regionId];
         }
         return result;
      }
      
      private function getAchievementsDataFromFO(regionId:String) : Object
      {
         var result:Object = null;
         var regionData:Object = this.getRegionDataFromFO(regionId);
         if(Boolean(regionData) && regionData.hasOwnProperty(FO_ACHIEVEMENTS))
         {
            result = regionData[FO_ACHIEVEMENTS];
         }
         return result;
      }
      
      public function getTrophyClaimedInAchievement(regionId:String, achievementId:String) : int
      {
         var result:int = NONE_TROPHY;
         var achievementsData:Object = this.getAchievementsDataFromFO(regionId);
         if(Boolean(achievementsData) && achievementsData.hasOwnProperty(achievementId))
         {
            result = int(achievementsData[achievementId]);
         }
         return result;
      }
      
      public function isShieldWonInRegion(regionId:String) : Boolean
      {
         var result:Boolean = false;
         var regionData:Object = this.getRegionDataFromFO(regionId);
         if(Boolean(regionData) && regionData.hasOwnProperty(FO_REGION_SHIED_WON))
         {
            result = regionData[FO_REGION_SHIED_WON] as Boolean;
         }
         return result;
      }
      
      public function getRegionProgressFromFO(regionId:String, progressType:String) : Boolean
      {
         var result:Boolean = false;
         var regionData:Object = this.getRegionDataFromFO(regionId);
         if(Boolean(regionData) && regionData.hasOwnProperty(progressType))
         {
            result = regionData[progressType] as Boolean;
         }
         return result;
      }
      
      public function isRegionCompleted(regionId:String) : Boolean
      {
         var result:Boolean = false;
         var regionData:Object = this.getRegionDataFromFO(regionId);
         if(Boolean(regionData) && regionData.hasOwnProperty(FO_REGION_COMPLETE))
         {
            result = regionData[FO_REGION_COMPLETE] as Boolean;
         }
         return result;
      }
      
      public function isDismissedTimedAchievement(regionId:String) : Boolean
      {
         var result:Boolean = false;
         var regionData:Object = this.getRegionDataFromFO(regionId);
         if(Boolean(regionData) && regionData.hasOwnProperty(FO_DISMISSED_TIMED_ACHIEVEMENT))
         {
            result = regionData[FO_DISMISSED_TIMED_ACHIEVEMENT] as Boolean;
         }
         return result;
      }
      
      public function isChampionFromFO() : Boolean
      {
         var result:Boolean = false;
         var featureOption:Object = this.getFeatureOption();
         if(Boolean(featureOption) && featureOption.hasOwnProperty(FO_CHAMPION_WON))
         {
            result = featureOption[FO_CHAMPION_WON] as Boolean;
         }
         return result;
      }
      
      public function isGotSpecialRewardFromFO() : Boolean
      {
         var result:Boolean = false;
         var featureOption:Object = this.getFeatureOption();
         if(Boolean(featureOption) && featureOption.hasOwnProperty(FO_SPECIAL_REWARD_WON))
         {
            result = featureOption[FO_SPECIAL_REWARD_WON] as Boolean;
         }
         return result;
      }
      
      private function setFeatureOption(featureOptionData:Object) : void
      {
         if(featureOptionData)
         {
            FeatureOptionsManager.getInstance().setFeatureOption(FO_FEATURE,this.m_featureName,featureOptionData);
         }
      }
      
      private function setRegionDataInFO(regionId:String, regionData:Object) : void
      {
         var featureOptionData:Object = null;
         if(Boolean(regionId) && Boolean(regionId != "") && Boolean(regionData))
         {
            featureOptionData = this.getFeatureOption();
            if(!featureOptionData)
            {
               featureOptionData = {};
            }
            featureOptionData[regionId] = regionData;
            this.setFeatureOption(featureOptionData);
         }
      }
      
      private function setAchievementsDataInFO(regionId:String, achievementsData:Object) : void
      {
         var regionData:Object = null;
         if(Boolean(regionId) && Boolean(regionId != "") && Boolean(achievementsData))
         {
            regionData = this.getRegionDataFromFO(regionId);
            if(!regionData)
            {
               regionData = {};
            }
            regionData[FO_ACHIEVEMENTS] = achievementsData;
            this.setRegionDataInFO(regionId,regionData);
         }
      }
      
      public function setTrophyClaimedInAchievement(regionId:String, achievementId:String, trophyClaimed:int = 0) : void
      {
         var achievementsData:Object = null;
         if(Boolean(regionId && regionId != "") && Boolean(achievementId) && achievementId != "")
         {
            achievementsData = this.getAchievementsDataFromFO(regionId);
            if(!achievementsData)
            {
               achievementsData = {};
            }
            achievementsData[achievementId] = trophyClaimed;
            this.setAchievementsDataInFO(regionId,achievementsData);
         }
      }
      
      public function setRegionProgressinFO(regionId:String, progressType:String, value:Boolean) : void
      {
         var regionData:Object = null;
         if(Boolean(regionId) && regionId != "")
         {
            regionData = this.getRegionDataFromFO(regionId);
            if(!regionData)
            {
               regionData = {};
            }
            regionData[progressType] = value;
            this.setRegionDataInFO(regionId,regionData);
         }
      }
      
      public function setShieldWonInRegion(regionId:String) : void
      {
         this.setRegionProgressinFO(regionId,FO_REGION_SHIED_WON,true);
      }
      
      public function setRegionCompleted(regionId:String) : void
      {
         this.setRegionProgressinFO(regionId,FO_REGION_COMPLETE,true);
      }
      
      public function setDismissedTimedAchievement(regionId:String, achivementId:String) : void
      {
         this.setRegionProgressinFO(regionId,FO_DISMISSED_TIMED_ACHIEVEMENT,true);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,ON_DISMISS_ACHIEVEMENT,null,[this.m_featureName,regionId,achivementId]));
      }
      
      public function setChampionInFO() : void
      {
         var featureOptionData:Object = this.getFeatureOption();
         if(featureOptionData)
         {
            featureOptionData[FO_CHAMPION_WON] = true;
            this.setFeatureOption(featureOptionData);
         }
      }
      
      public function setSpecialRewardInFO() : void
      {
         var featureOptionData:Object = this.getFeatureOption();
         if(featureOptionData)
         {
            featureOptionData[FO_SPECIAL_REWARD_WON] = true;
            this.setFeatureOption(featureOptionData);
         }
      }
      
      public function canGrandSpecialReward() : Boolean
      {
         var result:Boolean = !this.isGotSpecialRewardFromFO();
         if(result)
         {
            result = this.areAllShieldsWon();
         }
         return result;
      }
      
      public function areAllShieldsWon() : Boolean
      {
         var result:Boolean = false;
         for(var i:int = 0; i < this.m_regions.length; i++)
         {
            result = (this.m_regions[i] as Region).shieldWon;
            if(!result)
            {
               break;
            }
         }
         return result;
      }
      
      public function canGrandChampionTrophy() : Boolean
      {
         var numRelicsComleted:int = 0;
         var result:Boolean = !this.isChampionFromFO() && this.areAllShieldsWon();
         if(result)
         {
            numRelicsComleted = this.numOfAchievementsCompleted();
            result = numRelicsComleted >= this.m_championMilestone;
         }
         return result;
      }
      
      public function completeMilestone(regionId:String, achievementId:String, milestoneType:String) : void
      {
         var milestoneCompleted:int = this.getTrophyClaimedInAchievement(regionId,achievementId);
         if(milestoneCompleted < int(milestoneType))
         {
            this.setTrophyClaimedInAchievement(regionId,achievementId,int(milestoneType));
         }
      }
      
      private function grandSpecialReward() : void
      {
         UserRewardUtil.grantUserRewards(this.m_specialRewards);
         this.setSpecialRewardInFO();
      }
      
      private function grandChanmpionTrophyAndRewards() : void
      {
         UserRewardUtil.grantUserRewards(this.m_championRewards);
         this.setChampionInFO();
      }
      
      public function showUI(event:Event = null) : void
      {
         if(this.m_regionAchievementWindow)
         {
            this.m_regionAchievementWindow = null;
         }
         this.preloadAssets();
         this.m_regionAchievementWindow = new RegionAchievementWindow(this.m_assetUrl,this.m_featureName);
         UI.displayPopup(this.m_regionAchievementWindow,false);
         this.executeNextAction();
      }
      
      private function closeWindow() : void
      {
         if(this.m_regionAchievementWindow)
         {
            this.m_regionAchievementWindow.close();
         }
         if(this.m_taskWindow)
         {
            this.m_taskWindow.close();
         }
      }
      
      private function openWindow() : void
      {
         if(!this.m_regionAchievementWindow)
         {
            this.showUI();
         }
      }
      
      public function isRegionUnlocked(regionId:String) : Boolean
      {
         var currentRegionId:int = WorldSeasonsManager.getInstance().getCurrentSeason(Global.worldManager.currentWorldType);
         return currentRegionId > 0 && currentRegionId >= int(regionId);
      }
      
      public function showChampionRewardWindow(event:RegionAchievementEvent = null) : void
      {
         UI.displayPopup(this.m_championWindow = new RegionAchievementChampionWindow(CHAMPION_DLG_URL,this.m_featureName),false);
      }
      
      public function showTabbedWindow(regionId:String) : void
      {
         if(Boolean(regionId) && Boolean(this.m_regionAchievementWindow))
         {
            this.m_taskWindow = new RegionAchievementTabbedWindow(ACHIEVEMENT_TABBED_WINDOW_URL,this.m_featureName,regionId);
            UI.displayPopup(this.m_taskWindow,false);
            this.m_regionAchievementWindow.toggleMainWindowNPC(false);
         }
      }
      
      public function showSpecialRewadWindow(event:RegionAchievementEvent = null) : void
      {
         UI.displayPopup(this.m_specialRewardWindow = new RegionAchievementSpecialRewardWindow(SPECIAL_REWARD_DLG_URL,this.m_featureName),false);
      }
      
      public function showSmallRelicRewardWindow(regionId:String, achievementId:String) : void
      {
         var regionAchievement:RegionAchievement = this.getRegionAchievementByAchievementId(regionId,achievementId);
         if(Boolean(regionAchievement) && Boolean(this.m_regionAchievementWindow))
         {
            UI.displayPopup(this.m_smallRelicWindow = new RegionAchievementSmallRelicWindow(ACHIEVEMENT_TROPY_REWARD_WINDOW_URL,this.m_featureName,regionAchievement),false);
            this.m_regionAchievementWindow.toggleMainWindowNPC(false);
         }
      }
      
      public function toggleMainWindowNPC(event:RegionAchievementEvent = null) : void
      {
         var visible:Boolean = false;
         if(Boolean(this.m_regionAchievementWindow) && Boolean(event))
         {
            visible = Boolean(event.data) && Boolean(event.data.hasOwnProperty("visible")) && event.data.visible == true ? true : false;
            this.m_regionAchievementWindow.toggleMainWindowNPC(visible);
         }
      }
      
      public function showMediumRelicRewardWindow(regionId:String) : void
      {
         if(Boolean(regionId) && Boolean(this.m_regionAchievementWindow))
         {
            UI.displayPopup(this.m_shieldRewardWindow = new RegionAchievementShieldRewardWindow(ACHIEVEMENT_SHIELD_REWARD_WINDOW_URL,this.m_featureName,regionId),false);
            this.m_regionAchievementWindow.toggleMainWindowNPC(false);
         }
      }
      
      private function refreshWindow(event:RegionAchievementEvent) : void
      {
         if(this.m_regionAchievementWindow)
         {
            this.m_regionAchievementWindow.refreshWindow();
         }
         if(this.m_taskWindow)
         {
            this.m_taskWindow.refreshWindow();
         }
      }
      
      public function get completedChampionMilestoneText() : String
      {
         return this.numOfAchievementsCompleted().toString() + "/" + this.m_championMilestone.toString();
      }
      
      public function get championMilestoneText() : String
      {
         return this.m_championMilestone.toString() + "/" + this.totalNumOfAchievements.toString();
      }
      
      private function numOfAchievementsCompleted() : int
      {
         var reg:Region = null;
         var result:int = 0;
         for each(reg in this.regions)
         {
            result += reg.numOfAchievementsCompleted(INCSLUDE_COMPLETED_TIMED_ACHIEVEMENTS);
         }
         return result;
      }
      
      private function get totalNumOfAchievements() : int
      {
         var reg:Region = null;
         var result:int = 0;
         for each(reg in this.regions)
         {
            result += reg.achievements.length;
         }
         return result;
      }
      
      private function canClaim() : Boolean
      {
         var reg:Region = null;
         var result:Boolean = false;
         for each(reg in this.regions)
         {
            if(reg.canClaim())
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      private function getQuestIdToTAQuestMapping() : Object
      {
         var reg:Region = null;
         var result:Object = {};
         for each(reg in this.regions)
         {
            if(reg.timedAchievement.quest)
            {
               result[reg.timedAchievement.quest.name] = reg.timedAchievement.quest;
            }
         }
         return result;
      }
      
      public function isAnyTAActive() : Boolean
      {
         var region:Region = null;
         var result:Boolean = false;
         for each(region in this.m_regions)
         {
            if(region.unlocked)
            {
               result = region.timedAchievement.active && !region.timedAchievement.completed && !region.timedAchievement.canClaim;
               if(result == true)
               {
                  break;
               }
            }
         }
         return result;
      }
      
      private function onGetCompletedTAQuestIds(result:Array) : void
      {
         var questIdToTAQuestMapping:Object = null;
         var questId:String = null;
         var quest:FarmQuest = null;
         var questTask:FarmTask = null;
         if(Boolean(result) && result.length > 0)
         {
            questIdToTAQuestMapping = this.getQuestIdToTAQuestMapping();
            if(questIdToTAQuestMapping)
            {
               for each(questId in result)
               {
                  if(Boolean(questId) && questIdToTAQuestMapping.hasOwnProperty(questId))
                  {
                     quest = questIdToTAQuestMapping[questId] as FarmQuest;
                     if(quest)
                     {
                        for each(questTask in quest.farmTasks)
                        {
                           questTask.setTaskProgressToTotal();
                        }
                     }
                  }
               }
               this.dispatchRegionAchievementEvent(new RegionAchievementEvent(RegionAchievementEvent.REFRESH_UI));
            }
         }
      }
      
      public function shareBragFeed(trophyName:String) : void
      {
         this.m_bragFeedTrophyName = trophyName;
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,ACTION_SHARE_BRAG_FEED,this.onShareBragFeed,[this.m_featureName,BRAG_FEED_TROPHY]));
      }
      
      private function onShareBragFeed(result:Object) : void
      {
         var rewardName:String = null;
         var rewardLink:String = null;
         var rewardItem:FarmItem = null;
         var bundleData:Object = null;
         if(Boolean(result) && Boolean(result.hasOwnProperty("rewardName")) && result.hasOwnProperty("rewardLink"))
         {
            rewardName = result.rewardName;
            rewardLink = result.rewardLink;
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
            bundleData = {
               "reward_link":rewardLink,
               "level":this.m_bragFeedTrophyName,
               "creative":this.m_featureName,
               "subcategory":BRAG_FEED_TROPHY,
               "images":[{
                  "href":"{SN_APP_URL}" + rewardLink,
                  "src":rewardItem.getImageByName(FarmItem.ICON_FEED)
               }]
            };
            GlobalEngine.socialNetwork.publishFeedStory(BRAG_FEED_TROPHY,bundleData,[],false);
         }
      }
      
      public function setRegionUnlockDates() : void
      {
         var seasonData:Object = null;
         var region:Region = null;
         var data:Object = null;
         var aceessPrereq:String = null;
         var prereq:Object = null;
         var requirementsArray:Array = null;
         var requirement:Object = null;
         this.m_regionUnlockDates = {};
         var currentWorld:String = Global.worldManager.currentWorldType;
         var userAccessType:String = WorldSeasonsManager.getInstance().getAccessType(currentWorld) as String;
         var expansionData:ExpansionData = Global.farmGameSettingsManager.getExpansionData(currentWorld);
         if(Boolean(currentWorld) && Boolean(userAccessType) && Boolean(expansionData))
         {
            seasonData = expansionData.seasons;
            for each(region in this.m_regions)
            {
               data = seasonData[region.id];
               if(Boolean(data) && data.hasOwnProperty(userAccessType))
               {
                  aceessPrereq = data[userAccessType];
                  if(Boolean(aceessPrereq) && aceessPrereq != "")
                  {
                     prereq = Global.farmGameSettingsManager.getPrereqByName(aceessPrereq);
                     requirementsArray = prereq[FarmGameSettingsManager.XML_CHILDREN_FIELD];
                     for each(requirement in requirementsArray)
                     {
                        if(requirement.type == PrerequisiteConstants.PREREQUISITE_START_TIME)
                        {
                           this.m_regionUnlockDates[region.id] = requirement.value;
                           break;
                        }
                     }
                  }
               }
            }
         }
      }
      
      public function getRegionUnlockDate(regionId:String) : String
      {
         var result:String = "";
         if(this.m_regionUnlockDates == null)
         {
            this.setRegionUnlockDates();
         }
         if(Boolean(this.m_regionUnlockDates) && this.m_regionUnlockDates.hasOwnProperty(regionId))
         {
            result = this.m_regionUnlockDates[regionId];
         }
         return result;
      }
      
      public function addAction(actionType:String, data:Object = null) : void
      {
         this.m_actionQueue.push(new RegionAchievementAction(actionType,this.m_featureName,data));
      }
      
      public function executeNextAction(event:RegionAchievementEvent = null) : void
      {
         var action:RegionAchievementAction = null;
         if(Boolean(this.m_actionQueue) && this.m_actionQueue.length > 0)
         {
            action = this.m_actionQueue.shift() as RegionAchievementAction;
            if(action)
            {
               action.execute();
            }
         }
      }
      
      public function checkOutRegionSpecialTile(regionId:String) : void
      {
         var specialTileGameObjects:Array = null;
         var specialTileObj:MultiRewardTreasureConstructionBuilding = null;
         var region:Region = this.getRegionById(regionId);
         if(Boolean(region) && Boolean(region.specialTileItemName))
         {
            specialTileGameObjects = Global.world.getObjectsByName(region.specialTileItemName);
            if(Boolean(specialTileGameObjects) && specialTileGameObjects.length > 0)
            {
               this.closeWindow();
               ItemFinderManager.getInstance().highlightWorldItems(region.specialTileItemName);
               specialTileObj = specialTileGameObjects[0] as MultiRewardTreasureConstructionBuilding;
               if(specialTileObj)
               {
                  specialTileObj.unlockNow(null,this.generateSpecialTileTransformCallback(regionId));
               }
            }
         }
      }
      
      public function showMOTD(motdName:String) : void
      {
         if(!Global.player.isMotdSeenFlagSet(motdName))
         {
            TransactionManager.addTransaction(new TGetMOTD(motdName,this.onGetMOTD),true);
         }
      }
      
      private function onGetMOTD(amfResult:Object) : void
      {
         if(Boolean(amfResult) && amfResult.hasOwnProperty("motdSeenFlag"))
         {
            this.closeWindow();
            MOTD.displayMOTD(amfResult,false);
         }
      }
      
      private function generateSpecialTileTransformCallback(regionId:String) : Function
      {
         return function(result:Object):void
         {
            var totemGameObjects:* = undefined;
            var totem:* = undefined;
            var region:* = getRegionById(regionId);
            if(region.totemItem)
            {
               totemGameObjects = Global.world.getObjectsByName(region.totemItem.name);
               if(Boolean(totemGameObjects) && totemGameObjects.length > 0)
               {
                  totem = totemGameObjects[0] as FeatureBuildingOpenUIOnClick;
                  if(totem)
                  {
                     totem.onClick();
                  }
               }
            }
         };
      }
      
      public function preloadAssets() : void
      {
         var reg:Region = null;
         for each(reg in this.m_regions)
         {
            reg.preloadAssets();
         }
      }
      
      public function releaseTaskWindow() : void
      {
         this.m_taskWindow = null;
      }
      
      public function release() : void
      {
         this.removeEventListeners();
         this.m_actionQueue = null;
         if(this.m_regionAchievementWindow)
         {
            this.m_regionAchievementWindow.close();
         }
         if(this.m_taskWindow)
         {
            this.m_taskWindow.close();
         }
         if(this.m_championWindow)
         {
            this.m_championWindow.close();
         }
         if(this.m_specialRewardWindow)
         {
            this.m_specialRewardWindow.close();
         }
         if(this.m_smallRelicWindow)
         {
            this.m_smallRelicWindow.close();
         }
         if(this.m_shieldRewardWindow)
         {
            this.m_shieldRewardWindow.close();
         }
         this.m_taskWindow = null;
         this.m_regionAchievementWindow = null;
         this.m_regions = null;
         this.m_regionIdmap = null;
         this.m_assetUrl = null;
         this.m_championRewards = null;
         this.m_specialRewards = null;
         this.m_specialRewardMTD = null;
         this.m_eventManager = null;
         this.m_icon = null;
         m_initialized = false;
         m_instance = null;
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
