package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.DailyCheckInRewardWindow;
   import Widgets.Windows.DailyCheckInWindow;
   import flash.events.Event;
   
   public class DailyCheckInManager
   {
      
      private static var m_instance:DailyCheckInManager;
      
      public static const FEATURE_OPTIONS_KEY:String = "dailyCheckIn";
      
      public static const FEATURE_NAME:String = "0";
      
      public static const COLLECTED_MAP_KEY:String = "1";
      
      public static const GOODIE_COUNT_KEY:String = "2";
      
      public static const WEEK_NUM_KEY:String = "3";
      
      public static const NUM_DELIGHTS_KEY:String = "4";
      
      public static const NUM_DAYS:int = 7;
      
      public static const UPDATE_STATE:String = "updateDailyCheckInState";
      
      private static const SERVICE_NAME:String = "DailyCheckInService";
      
      private static const METHOD_COLLECT_GOODIE:String = "collectGoodie";
      
      private static const METHOD_REDEEM_REWARD:String = "redeemReward";
      
      private static const METHOD_INIT_FEATURE:String = "initFeature";
      
      private static const GOODIE_COUNT_EXP_1:Array = [1,2,4];
      
      private static const GOODIE_COUNT_EXP_2:Array = [1,3,5];
      
      private static const GOODIE_NAME_ZLOC_SUFFIX:String = "_goodieName";
      
      private static const INDEX_GOODIE_NAME:String = "itemNameKey";
      
      private static const INDEX_ASSET_PATH:String = "assetPath";
      
      private static const INDEX_REWARD_ASSET_PATH:String = "congratsAssetPath";
      
      private static var m_initialized:Boolean = false;
      
      public static var SECS_PER_DAY:Number = FarmGameUtil.NUM_SECS_IN_DAY;
      
      public static var SECS_PER_WEEK:Number = FarmGameUtil.NUM_SECS_IN_WEEK;
      
      private var m_dialogUrl:String;
      
      private var m_configManager:FeatureConfigManager;
      
      private var m_rewards:Array;
      
      private var m_lastChanceRewards:Array;
      
      private var m_bonusRewardName:String;
      
      private var m_lastChanceGoodieUrl:String;
      
      private var m_isLastChance:Boolean = false;
      
      private var m_config:XML;
      
      private var m_currentActiveGoodie:String;
      
      public function DailyCheckInManager()
      {
         super();
      }
      
      public static function getInstance() : DailyCheckInManager
      {
         if(!m_instance)
         {
            m_instance = new DailyCheckInManager();
         }
         return m_instance;
      }
      
      public static function isInitialized() : Boolean
      {
         return m_initialized;
      }
      
      public static function isHarvestable(featureName:String) : Boolean
      {
         var result:Boolean = false;
         var featureConfigManager:FeatureConfigManager = FeatureConfigManager.getFeatureConfiguration(featureName);
         var timeElapsed:int = featureConfigManager.getTimeElapsedMS() / 1000 - Global.farmGameSettingsManager.getInt("est_to_pst_offset") * FarmGameUtil.NUM_SECS_IN_HOUR;
         var currentDay:int = timeElapsed % SECS_PER_WEEK / SECS_PER_DAY + 1;
         var collectedMap:int = int(FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,COLLECTED_MAP_KEY));
         return (collectedMap & 1 << currentDay - 1) == 0;
      }
      
      public function reinitialize() : void
      {
         var storedWeekNum:int = 0;
         var currentWeekNum:int = 0;
         var featureInit:Boolean = false;
         if(FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,FEATURE_NAME) != null)
         {
            storedWeekNum = int(FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,WEEK_NUM_KEY));
            currentWeekNum = this.getCurrentWeekFromConfig();
            this.m_isLastChance = currentWeekNum == storedWeekNum + 1 && this.currentGoodieCount != 0;
            if(currentWeekNum == storedWeekNum || this.m_isLastChance)
            {
               featureInit = true;
            }
         }
         if(!featureInit)
         {
            this.initFeatureOptions();
         }
         this.parseCurrentFeatureData();
         if(this.isInLastChance())
         {
            this.createLastChanceFeatureData();
         }
      }
      
      public function init(featureName:String, dialogUrl:String) : void
      {
         m_initialized = true;
         this.m_dialogUrl = dialogUrl;
         this.m_configManager = FeatureConfigManager.getFeatureConfiguration(featureName);
         this.m_config = Global.farmGameSettingsManager.getFeatureXML(featureName);
         SECS_PER_DAY = parseInt(Global.flashHotParams["SECS_PER_DAY_FOR_TESTING"]);
         SECS_PER_WEEK = parseInt(Global.flashHotParams["SECS_PER_WEEK_FOR_TESTING"]);
         this.reinitialize();
      }
      
      public function isV10AnniversaryWeek() : Boolean
      {
         return PrerequisiteUtility.isPrerequisiteMet(Global.farmGameSettingsManager.getPrereqByName("fv_daily_checkin_v10"));
      }
      
      public function showV10AnniversaryData() : Boolean
      {
         return this.isV10AnniversaryWeek() && !this.isInLastChance() || this.getCurrentWeekFromConfig() == 167 && this.isInLastChance();
      }
      
      private function getCurrentWeekFromConfig() : int
      {
         var timeElapsed:int = this.m_configManager.getTimeElapsedMS() / 1000 - Global.farmGameSettingsManager.getInt("est_to_pst_offset") * FarmGameUtil.NUM_SECS_IN_HOUR;
         return int(timeElapsed / SECS_PER_WEEK + 1);
      }
      
      public function hasWeekChanged() : Boolean
      {
         var storedWeek:int = int(FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,WEEK_NUM_KEY));
         var currentWeek:int = this.getCurrentWeekFromConfig();
         return currentWeek != storedWeek;
      }
      
      private function parseCurrentFeatureData() : void
      {
         var featureName:String = null;
         var stageXML:XMLList = null;
         var numDelights:int = 0;
         var timeElapsed:int = 0;
         var weekNumber:int = 0;
         var stage:XML = null;
         var stageNo:int = 0;
         var goodieFeatureConfig:XML = null;
         var rewardsXML:XMLList = null;
         var item:Object = null;
         var type:String = null;
         var itemCode:String = null;
         var reward:XML = null;
         var bonusRewardXML:XML = null;
         if(this.isInLastChance())
         {
            stageXML = this.m_config.child("stage");
            numDelights = stageXML.length();
            timeElapsed = this.m_configManager.getTimeElapsedMS() / 1000 - Global.farmGameSettingsManager.getInt("est_to_pst_offset") * FarmGameUtil.NUM_SECS_IN_HOUR;
            weekNumber = int(timeElapsed / SECS_PER_WEEK) % numDelights;
            for each(stage in stageXML)
            {
               stageNo = int(stage.@number);
               featureName = stage.@name;
               if(weekNumber == stageNo - 1)
               {
                  featureName = stage.@name;
                  break;
               }
            }
         }
         else
         {
            featureName = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,FEATURE_NAME).toString();
         }
         if(featureName)
         {
            this.m_currentActiveGoodie = featureName;
            goodieFeatureConfig = Global.farmGameSettingsManager.getFeatureXML(featureName);
            rewardsXML = goodieFeatureConfig.child("rewards");
            this.m_rewards = new Array();
            for each(reward in rewardsXML[0].children())
            {
               item = new Object();
               itemCode = reward.attribute("value").toString();
               item["code"] = itemCode;
               item["amount"] = reward.attribute("quantity").toString();
               this.m_rewards.push(item);
            }
            bonusRewardXML = goodieFeatureConfig.child("bonusReward")[0];
            this.m_bonusRewardName = bonusRewardXML.attribute("name").toString();
         }
      }
      
      private function createLastChanceFeatureData() : void
      {
         var featureConfig:XML = null;
         var featureConfigManager:FeatureConfigManager = null;
         var rewardsXML:XMLList = null;
         var item:Object = null;
         var type:String = null;
         var itemCode:String = null;
         var reward:XML = null;
         var featureName:String = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,FEATURE_NAME).toString();
         if(this.m_isLastChance)
         {
            featureConfig = Global.farmGameSettingsManager.getFeatureXML(featureName);
            featureConfigManager = FeatureConfigManager.getFeatureConfiguration(featureName);
            this.m_lastChanceGoodieUrl = this.m_configManager.getStringConstant(INDEX_ASSET_PATH);
            rewardsXML = featureConfig.child("rewards");
            this.m_lastChanceRewards = new Array();
            for each(reward in rewardsXML[0].children())
            {
               item = new Object();
               itemCode = reward.attribute("value").toString();
               item["code"] = itemCode;
               item["amount"] = reward.attribute("quantity").toString();
               this.m_lastChanceRewards.push(item);
            }
         }
      }
      
      public function initFeatureOptions() : void
      {
         var featureName:String = null;
         var stage:XML = null;
         var weekNumber:int = 0;
         var stageNo:int = 0;
         var stageXML:XMLList = this.m_config.child("stage");
         var numDelights:int = stageXML.length();
         var timeElapsed:int = this.m_configManager.getTimeElapsedMS() / 1000 - Global.farmGameSettingsManager.getInt("est_to_pst_offset") * FarmGameUtil.NUM_SECS_IN_HOUR;
         var weekMod:int = int(timeElapsed / SECS_PER_WEEK) % numDelights;
         for each(stage in stageXML)
         {
            stageNo = int(stage.@number);
            featureName = stage.@name;
            if(weekMod == stageNo - 1)
            {
               featureName = stage.@name;
               break;
            }
         }
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,FEATURE_NAME,featureName);
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,GOODIE_COUNT_KEY,0);
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,COLLECTED_MAP_KEY,0);
         weekNumber = int(timeElapsed / SECS_PER_WEEK + 1);
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,WEEK_NUM_KEY,weekNumber);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,METHOD_INIT_FEATURE,null,[this.m_configManager.featureName]),true);
      }
      
      public function collectGoodie(callback:Function) : void
      {
         var collectedMap:int = 0;
         var currentWeek:int = 0;
         var currentDay:int = 0;
         var newCollectedMapVal:int = 0;
         var rewardDialogUrl:String = null;
         if(this.canCollectGoodie())
         {
            collectedMap = int(FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,COLLECTED_MAP_KEY));
            currentWeek = int(FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,WEEK_NUM_KEY));
            currentDay = this.getCurrentDayNumber();
            newCollectedMapVal = collectedMap + (1 << currentDay - 1);
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,COLLECTED_MAP_KEY,newCollectedMapVal);
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,GOODIE_COUNT_KEY,this.currentGoodieCount + 1);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,METHOD_COLLECT_GOODIE,callback,[this.m_configManager.featureName,currentWeek,currentDay]),true);
            if(this.areAllGoodiesCollected())
            {
               Global.player.addGift(this.bonusItemName);
               rewardDialogUrl = this.m_configManager.getStringConstant(INDEX_REWARD_ASSET_PATH);
               if(this.isV10AnniversaryWeek())
               {
                  rewardDialogUrl = "assets/dialogs/Farmville10thBirthday/Barbra/FV_DailyCheckIn_10thBDay_prize.swf";
               }
               UI.displayPopup(new DailyCheckInRewardWindow(rewardDialogUrl,true,this.bonusItemName,this.openDailyCheckInUI));
            }
            GlobalEventManager.getInstance().dispatchEvent(new Event(UPDATE_STATE));
         }
      }
      
      public function canCollectGoodie() : Boolean
      {
         var collectedMap:int = 0;
         var result:Boolean = false;
         var storedWeek:int = int(FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,WEEK_NUM_KEY));
         var currentWeek:int = this.getCurrentWeekFromConfig();
         var currentDay:int = this.getCurrentDayNumber();
         if(currentWeek == storedWeek)
         {
            collectedMap = int(FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,COLLECTED_MAP_KEY));
            result = (collectedMap & 1 << currentDay - 1) == 0;
         }
         return result;
      }
      
      public function redeemReward(itemCode:String) : void
      {
         var newGoodieCount:int = 0;
         var itemName:String = null;
         var rewardDialogUrl:String = null;
         if(this.canRedeemReward(itemCode))
         {
            newGoodieCount = this.currentGoodieCount - this.getGoodiesRequiredFor(itemCode);
            itemName = Global.farmGameSettingsManager.getFarmItemNameByCode(itemCode);
            Global.player.addGift(itemName,"0",this.getRewardItemCountFor(itemCode));
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,GOODIE_COUNT_KEY,newGoodieCount);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,METHOD_REDEEM_REWARD,null,[this.m_configManager.featureName,itemCode]),true);
            rewardDialogUrl = this.m_configManager.getStringConstant(INDEX_REWARD_ASSET_PATH);
            if(this.isV10AnniversaryWeek())
            {
               rewardDialogUrl = "assets/dialogs/Farmville10thBirthday/Barbra/FV_DailyCheckIn_10thBDay_prize.swf";
            }
            UI.displayPopup(new DailyCheckInRewardWindow(rewardDialogUrl,false,itemName,this.openDailyCheckInUI));
         }
      }
      
      public function canRedeemReward(itemCode:String) : Boolean
      {
         var result:Boolean = false;
         if(this.currentGoodieCount >= this.getGoodiesRequiredFor(itemCode))
         {
            result = true;
         }
         return result;
      }
      
      public function getCurrentDayNumber() : int
      {
         var timeElapsed:int = this.m_configManager.getTimeElapsedMS() / 1000 - Global.farmGameSettingsManager.getInt("est_to_pst_offset") * FarmGameUtil.NUM_SECS_IN_HOUR;
         return int(timeElapsed % SECS_PER_WEEK / SECS_PER_DAY + 1);
      }
      
      public function getGoodiesRequiredFor(itemCode:String) : int
      {
         var reward:Object = null;
         var rewards:Array = this.isInLastChance() ? this.getLastChanceRewards() : this.getRewards();
         var goodieCount:int = 0;
         var index:int = 0;
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_DAILY_CHECKIN);
         for each(reward in rewards)
         {
            if(reward["code"] == itemCode)
            {
               if(variant == 3)
               {
                  goodieCount = int(GOODIE_COUNT_EXP_1[index]);
               }
               else
               {
                  goodieCount = int(GOODIE_COUNT_EXP_2[index]);
               }
               break;
            }
            index++;
         }
         return goodieCount;
      }
      
      public function getRewardItemCountFor(itemCode:String) : int
      {
         var reward:Object = null;
         var rewards:Array = this.isInLastChance() ? this.getLastChanceRewards() : this.getRewards();
         var itemCount:int = 0;
         for each(reward in rewards)
         {
            if(reward["code"] == itemCode)
            {
               itemCount = int(reward["amount"]);
               break;
            }
         }
         return itemCount;
      }
      
      public function get currentGoodieCount() : int
      {
         return int(FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,GOODIE_COUNT_KEY));
      }
      
      public function getRewardItemCodes(rewards:Array) : Array
      {
         var reward:Object = null;
         var itemCode:String = null;
         var rewardItemCodes:Array = new Array();
         for each(reward in rewards)
         {
            itemCode = reward["code"];
            rewardItemCodes.push(itemCode);
         }
         return rewardItemCodes;
      }
      
      public function isGoodieCollectedOn(dayNo:int) : Boolean
      {
         var result:Boolean = false;
         var collectedMap:int = int(FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,COLLECTED_MAP_KEY));
         return (collectedMap & 1 << dayNo - 1) != 0;
      }
      
      public function areAllGoodiesCollected() : Boolean
      {
         var result:Boolean = false;
         var allCollectedValue:int = (1 << NUM_DAYS) - 1;
         var collectedMap:int = int(FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,COLLECTED_MAP_KEY));
         if(collectedMap == allCollectedValue)
         {
            result = true;
         }
         return result;
      }
      
      public function openDailyCheckInUI() : void
      {
         if(this.isInLastChance() && this.currentGoodieCount == 0)
         {
            this.resetLastChance();
            this.initFeatureOptions();
         }
         var configManager:FeatureConfigManager = FeatureConfigManager.getFeatureConfiguration(this.m_currentActiveGoodie);
         var goodieUrl:String = this.m_configManager.getStringConstant(INDEX_ASSET_PATH);
         var dialogURL:String = this.m_dialogUrl;
         if(this.isV10AnniversaryWeek())
         {
            dialogURL = "assets/dialogs/Farmville10thBirthday/Barbra/FV_DailyCheckIn_10thBDay.swf";
            goodieUrl = "assets/daily_checkin/task_cupcake.swf";
         }
         UI.displayPopup(new DailyCheckInWindow(dialogURL,goodieUrl,this.isInLastChance()));
      }
      
      public function getLastChanceRewards() : Array
      {
         return this.m_lastChanceRewards;
      }
      
      public function getRewards() : Array
      {
         return this.m_rewards;
      }
      
      public function isInLastChance() : Boolean
      {
         return this.m_isLastChance;
      }
      
      public function get bonusItemName() : String
      {
         return this.m_bonusRewardName;
      }
      
      public function getGoodieName(isOldGoodie:Boolean = false, goodieHint:Boolean = false) : String
      {
         var goodieName:String = null;
         var name:String = null;
         name = this.m_configManager.getStringConstant(INDEX_GOODIE_NAME);
         goodieName = ZLocUtils.t("Dialogs",name + GOODIE_NAME_ZLOC_SUFFIX);
         if(this.isV10AnniversaryWeek() && goodieHint)
         {
            goodieName = "Barbra Cupcake";
         }
         else if(this.showV10AnniversaryData())
         {
            goodieName = "Barbra Cupcake";
         }
         if(this.showV10AnniversaryData() && goodieHint)
         {
            goodieName = ZLocUtils.t("Dialogs",name + GOODIE_NAME_ZLOC_SUFFIX);
         }
         return goodieName;
      }
      
      public function getLastChanceGoodieUrl() : String
      {
         return this.m_lastChanceGoodieUrl;
      }
      
      public function getTimeElapsedSinceThisWeek() : int
      {
         return int((this.m_configManager.getTimeElapsedMS() / 1000 - Global.farmGameSettingsManager.getInt("est_to_pst_offset") * FarmGameUtil.NUM_SECS_IN_HOUR) % SECS_PER_WEEK);
      }
      
      public function resetLastChance() : void
      {
         this.m_isLastChance = false;
      }
   }
}

