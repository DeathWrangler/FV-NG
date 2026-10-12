package Managers.OrderBoard
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.WorldsConstants;
   import Classes.FeedData;
   import Classes.Quest.FarmTask;
   import Classes.SimpleCryptoManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.HUD.HUD;
   import Display.HUD.HUDWidgets.HudFarmersMarketInnovationButton;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.BaseFeatureManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.WorldSeasonsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.FarmersMarketBonusRewardWindow;
   import Widgets.Windows.FarmersMarketInnovationLeaderboardWindow;
   import Widgets.Windows.FarmersMarketInnovationLimitedStoragePopup;
   import Widgets.Windows.FarmersMarketInnovationMainWindow;
   import Widgets.Windows.FarmersMarketInnovationMilestoneRewardWindow;
   import Widgets.Windows.FarmersMarketInnovationSalesWindow;
   import Widgets.Windows.GenericSingleRewardPopup;
   import flash.events.Event;
   
   public class FarmersMarketInnovationManager extends GenericSlotedOrderboardManager
   {
      
      private static var m_initialized:Boolean = false;
      
      private static const FEATURE_TRACKING:String = "FarmersMarket2020Innovation";
      
      protected static var m_instance:Object = {};
      
      public static const FEATURE_NAME:String = "FarmersMarket2020Innovation";
      
      private static const m_serviceName:String = "FarmersMarketInnovationService";
      
      public static const BUILDING_INITIALISATION_FLAG_HARVEST:String = "building_hud_initialise_flag_harvest";
      
      public static const KEY_BONUS_HARVEST_START_TIME:* = "bonus_harvest_start_time";
      
      public static const DEFAULT_HARVEST_THROTTLE_TIME:int = 86400;
      
      public static const DEFAULT_COLLECT_THROTTLE_TIME:int = 86400;
      
      private static const SERVICE_FUNC_HARVEST_BONUS:String = "harvestDecos";
      
      private static const BONUS_HARVEST_COUNT:String = "hc_";
      
      private static const KEY_SELLING_PRICE:String = "sell_price";
      
      private static const KEY_WEEK:String = "week";
      
      private static const KEY_NEWS:String = "news";
      
      private static const KEY_SAVED_LEADERBOARD_RESULT:String = "leaderboard_data";
      
      private static const KEY_CURRENT_LEADERBOARD:String = "currentLeaderboard";
      
      private static const KEY_CURRENT_STORAGE_LEVEL:String = "current_storage_capacity_level";
      
      private static const KEY_SHOW_LEADERBOARD_FIRST_TIME_IN_WEEK:String = "ireland_weekly_show_leaderboard_first_time";
      
      private static const KEY_CURRENT_WEEK:String = "current_week";
      
      private static const NUM_SECS_FOUR_HOURS:Number = 14400;
      
      private static const m_storageCapacity:Array = new Array(50,100,150,200,300,400);
      
      private static const KEY_TOTAL_GOLD_COINS:String = "total_gold_coins";
      
      private static const KEY_NEWS_CHANGE_TIMESTAMP:String = "news_change_time";
      
      private static const KEY_FTUE_BENEFIT_GRANTED:String = "ftue_points_granted";
      
      private static const m_costForUpgrade:Array = new Array(0,10,20,30,50,80);
      
      public static const HUD_INITIALISATION_FLAG:String = "FarmersMarket_hud_initialise_flag";
      
      private var m_currencyName:String = "task_points";
      
      private var m_mainWindow:FarmersMarketInnovationMainWindow;
      
      private const KEY_BONUS_REWARD_GRANTED:String = "farmersMarket_bonus_reward_granted";
      
      private const FARMERS_MARKET_MARKET_FTUE_SEEN:String = "farmersmarket2020_market_ftue_seen";
      
      private const FLAG_FIRST_STARTNEWDAY:String = "farmersmarket2020_first_newday";
      
      public const LAST_HARVEST_TIME_KEY:String = "_lastHarvestTimeKey";
      
      private var m_inventionRewardBonusPopup:FarmersMarketBonusRewardWindow;
      
      private const REWARD_POPUP_WINDOW_SHARE:String = "assets/dialogs/expansion/FV_RewardDialog_Share.swf";
      
      private const REWARD_WINDOW_IMAGE:String = "assets/dialogs/farmfest/RewardDialog.png";
      
      private const REWARD_POPUP_WINDOW:String = "assets/dialogs/expansion/FV_RewardDialog.swf";
      
      private const ICONS_PATH_PREFIX:String = "assets/dialogs/FV_Jan_innovation/";
      
      private const KEY_ACTIVE_DAY_TIMESTAMP:String = "active_day_timestamp";
      
      private var m_zid:String = "";
      
      protected var m_staticData:Object;
      
      private var m_feedConfig:Object = {};
      
      private var m_skipSlotNumber:int = 0;
      
      private const WEEKLY_SCORE:String = "weekly_score";
      
      private const KEY_DAILY_REWARD_GRANTED:String = "daily_reward_granted";
      
      private const MAX_DAILY_LIMIT:int = 10000;
      
      public var m_leaderboardWindow:FarmersMarketInnovationLeaderboardWindow;
      
      public var m_marketWindow:FarmersMarketInnovationSalesWindow;
      
      private var m_limitedStoragePopup:FarmersMarketInnovationLimitedStoragePopup;
      
      public const KEY_DAY_POINTS:String = "daily_points";
      
      private var m_currentTimeSlot:int = 0;
      
      private var m_slotTimestampsList:Array = new Array(0,0,0,0,0);
      
      private var m_newsByID:Object = null;
      
      private var m_newsDataByWeek:Object = {};
      
      private var m_currentWeekNews:Array;
      
      private var m_newsWeek1:Array = new Array(new Array(0,14,0,15,28),new Array(1,29,16,2,17),new Array(3,4,18,19,30),new Array(31,5,20,6,32),new Array(33,21,34,22,7),new Array(8,9,10,23,24),new Array(11,12,25,26,27));
      
      private var m_newsWeek2:Array = new Array(new Array(0,14,1,2,28),new Array(15,16,29,17,3),new Array(4,5,30,6,18),new Array(19,20,21,31,22),new Array(32,7,23,8,9),new Array(33,24,10,25,26),new Array(27,34,11,12,13));
      
      private var m_newsWeek3:Array = new Array(new Array(28,0,14,1,15),new Array(16,2,17,3,29),new Array(18,30,4,19,5),new Array(20,31,32,6,7),new Array(21,8,22,23,33),new Array(9,10,34,24,11),new Array(25,12,26,27,13));
      
      private var m_newsWeek4:Array = new Array(new Array(0,14,15,1,28),new Array(16,29,2,17,3),new Array(18,19,30,4,5),new Array(20,6,7,31,21),new Array(8,32,9,22,23),new Array(24,10,33,11,25),new Array(12,13,26,27,34));
      
      private var m_newsWeek5:Array = new Array(new Array(0,14,28,1,15),new Array(16,2,29,17,18),new Array(3,30,19,31,20),new Array(4,5,6,21,7),new Array(8,32,22,9,23),new Array(10,24,25,26,11),new Array(12,33,27,13,34));
      
      public var BONUS_HARVEST_MAP:Object = {
         "xfs_streetvendorshop":new Array("fuel1","vehiclepart","pkg_xfs_treasureparts","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard"),
         "xfs_valleymarketshop":new Array("consume_unwither","consume_organic_fertilizer","fuel1","vehiclepart","pkg_xfs_treasureparts","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard"),
         "xfs_valleygroceryshop":new Array("consume_instagrow","pkg_xfs_bigbuildable_pack","consume_turbo_charger","consume_unwither","consume_organic_fertilizer","fuel1","vehiclepart","pkg_xfs_treasureparts","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands"),
         "xfs_farmfreshsupermarket":new Array("consume_instagrow","pkg_xfs_bigbuildable_pack","consume_turbo_charger","consume_unwither","consume_organic_fertilizer","fuel1","vehiclepart","pkg_xfs_treasureparts","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands")
      };
      
      private const m_dailyRewards:Array = new Array("rooster_xfs_icecream","pkg_xfs_buildingessentials","fox_xfs_scarecrow","pkg_xfs_buildingessentials","sheep_xfs_cottonfarmer","pkg_xfs_treasureessentials","camel_xfs_renaissance","pkg_xfs_vehicleessentials","bear_xfs_vintagevendor","pkg_xfs_buildingessentials","pig_xfs_40sfarmer","pkg_xfs_farmessentials","pkg_xfs_buildingessentials","cat_xfs_masonjar","pkg_xfs_treasureessentials","pkg_xfs_vehicleessentials","kangaroo_xfs_preserver","pkg_xfs_buildingessentials","pkg_xfs_farmessentials","monkey_xfs_rootcrop","pkg_xfs_buildingessentials","pkg_xfs_treasureessentials","llama_xfs_wheatfarm","pkg_xfs_vehicleessentials","pkg_xfs_buildingessentials","bear_xfs_poultryfarm","pkg_xfs_farmessentials","pkg_xfs_buildingessentials","gorilla_xfs_cabbagefarm","pkg_xfs_treasureessentials","pkg_xfs_vehicleessentials","penguin_xfs_irrigation","pkg_xfs_buildingessentials","pkg_xfs_farmessentials","pony_xfs_applepicker");
      
      private const m_leaderBoardBadgeNames:Array = new Array("Street Vendor","Valley Producer","Valley Grocerer","Super Farmer");
      
      public const VAL_MILESTONE_POINTS_ARRAY:Array = [50000,100000,200000,400000,600000,800000,1000000];
      
      public const VAL_BONUS_REWARDS_POINTS_ARRAY:Array = [50000,200000,500000,1000000];
      
      public var m_leaderboardpane_data:Object;
      
      private const m_produceList:Array = new Array("avacado","sweetpeppers","cherrytomato","grafefruit","dragonfruit");
      
      private const m_weeklyProduceNames:Array = new Array("Avacado","Sweet Pepper","Cherry Tomato","Grape Fruit","Dragon Fruit");
      
      private const KEY_LAST_MILESTONE_GRANTED:String = "last_milestone_granted";
      
      public function FarmersMarketInnovationManager(featureName:String)
      {
         super(featureName,m_serviceName);
         this.parseNewsDataFromConfig();
         startQuest();
         this.m_currentTimeSlot = this.getCurrentNewsTimeSlot();
         m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_FARMFEST);
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
      }
      
      public static function getInstance(featureName:String = "FarmersMarket2020Innovation") : FarmersMarketInnovationManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,FarmersMarketInnovationManager) as FarmersMarketInnovationManager;
      }
      
      public static function getTimeLeft(key:String, throttleTime:int = 86400) : int
      {
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         return int(throttleTime - timeSinceLastFeed);
      }
      
      protected function onTransactionAdded(event:TransactionEvent) : void
      {
         checkForTaskUpdates(event);
      }
      
      override protected function getFeatureOptionsKey(optionName:String) : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,optionName);
      }
      
      public function getInnovationFeatureName() : String
      {
         return FEATURE_NAME;
      }
      
      private function parseNewsDataFromConfig() : void
      {
         var week:XML = null;
         var news:XML = null;
         var newsData:XML = Global.farmGameSettingsManager.getXML().FarmersMarket2020InnovationNewsConfig[0];
         var weekInd:int = 0;
         if(newsData)
         {
            for each(week in newsData[KEY_WEEK])
            {
               this.m_newsByID = {};
               for each(news in week[KEY_NEWS])
               {
                  this.m_newsByID[news.@index] = news;
               }
               this.m_newsDataByWeek[weekInd] = this.m_newsByID;
               weekInd += 1;
            }
         }
      }
      
      public function startNewDay() : void
      {
         var capacity:int = 0;
         var available:int = 0;
         var produce:int = 0;
         var coinsAdd:int = 0;
         var weekData:Object = this.getCurrentWeek();
         this.saveFeatureOptionsKey(this.KEY_ACTIVE_DAY_TIMESTAMP,FarmGameUtil.getMidnightTimestamp() / 1000);
         Global.player.setSeenFlag(this.FLAG_FIRST_STARTNEWDAY);
         m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_FARMFEST);
         if(m_isEA && weekData.count == 1)
         {
            capacity = this.currentStorageCapacity;
            available = this.getFeatureOptionsKey(KEY_ORDERBOARD_TASK_POINTS) as int;
            if(capacity - available >= 40)
            {
               this.saveFeatureOptionsKey(KEY_ORDERBOARD_TASK_POINTS,available + 40);
            }
            else
            {
               this.saveFeatureOptionsKey(KEY_ORDERBOARD_TASK_POINTS,capacity);
            }
         }
         this.saveFeatureOptionsKey(this.KEY_DAILY_REWARD_GRANTED,false);
         this.saveFeatureOptionsKey(this.KEY_DAY_POINTS,0);
         if(this.getFeatureOptionsKey(KEY_FTUE_BENEFIT_GRANTED) == 0)
         {
            this.grantTutorialBenifits();
            this.saveFeatureOptionsKey(KEY_FTUE_BENEFIT_GRANTED,1);
         }
         if(this.hasActiveWeekExpired())
         {
            produce = this.getFeatureOptionsKey(KEY_ORDERBOARD_TASK_POINTS) as int;
            coinsAdd = 0;
            if(produce >= 21 && produce <= 100)
            {
               coinsAdd = 5000;
            }
            else if(produce > 100 && produce <= 200)
            {
               coinsAdd = 10000;
            }
            else if(produce > 200)
            {
               coinsAdd = 20000;
            }
            if(Boolean(this.mainWindow) && Boolean(coinsAdd > 0) && produce >= 21)
            {
               this.mainWindow.showConversionPopup(coinsAdd);
            }
            this.saveFeatureOptionsKey(KEY_ORDERBOARD_TASK_POINTS,0);
            this.saveFeatureOptionsKey(this.KEY_DAY_POINTS,coinsAdd);
            this.saveFeatureOptionsKey(this.WEEKLY_SCORE,coinsAdd);
            this.saveFeatureOptionsKey(KEY_TOTAL_GOLD_COINS,(this.getFeatureOptionsKey(KEY_TOTAL_GOLD_COINS) as int) + coinsAdd);
            this.saveFeatureOptionsKey(KEY_CURRENT_WEEK,weekData.count - 1);
         }
         FarmStatsManager.count(FEATURE_TRACKING,"startnewday","Click");
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startnewday",this.onStartNewDayDone,[m_featureName]));
      }
      
      private function onStartNewDayDone(result:Object) : void
      {
         if(this.mainWindow)
         {
            this.mainWindow.refreshWindow();
            this.mainWindow.untintWindow();
            this.mainWindow.enableInput = true;
         }
         if(Boolean(result) && Boolean(result.hasOwnProperty("milestoneReward")) && result["milestoneReward"] != null)
         {
            this.grantMileStoneReward(result["milestoneReward"]);
            this.showMilestoneRewardPopup(result["milestoneReward"]);
         }
      }
      
      private function grantTutorialBenifits() : void
      {
         if(this.getFeatureOptionsKey(KEY_FTUE_BENEFIT_GRANTED) == 0)
         {
            this.saveFeatureOptionsKey(this.KEY_DAY_POINTS,750);
            this.saveFeatureOptionsKey(KEY_TOTAL_GOLD_COINS,750);
            this.saveFeatureOptionsKey(this.WEEKLY_SCORE,750);
         }
      }
      
      public function getNewsContent() : Object
      {
         var newsID:int = 0;
         var newsByID:Object = null;
         var news:XML = null;
         var result:Object = {};
         var featureEndNews:Boolean = false;
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"fetchSellingPrice",this.onFetchSellingPrice,[m_featureName]));
         var currentSlot:int = this.getCurrentNewsTimeSlot();
         var dayIndex:int = this.dayIndexInCurrentWeek;
         var weekIndex:int = this.currentWeekIndex;
         if(currentSlot == 4)
         {
            dayIndex += 1;
            if(dayIndex >= 7)
            {
               dayIndex = 0;
               weekIndex += 1;
               if(weekIndex > 4)
               {
                  weekIndex = 4;
                  dayIndex--;
                  featureEndNews = true;
               }
            }
         }
         this.assignWeekNews(weekIndex);
         if(Boolean(this.m_currentWeekNews) && this.m_currentWeekNews.hasOwnProperty(dayIndex.toString()))
         {
            newsID = int(this.m_currentWeekNews[dayIndex][(currentSlot + 1) % 5]);
         }
         if(Boolean(this.m_newsDataByWeek) && this.m_newsDataByWeek.hasOwnProperty(weekIndex.toString()))
         {
            newsByID = this.m_newsDataByWeek[weekIndex];
            if(newsByID.hasOwnProperty(newsID.toString()))
            {
               news = newsByID[newsID];
               result["headline"] = this.decryptData(news.@headline);
               result["paragraph"] = this.decryptData(news.@paragraph);
               if(featureEndNews)
               {
                  result["headline"] = "Farmer\'s Market is ending";
                  result["paragraph"] = "Farmer\'s Market event in Harvest Valley is finally coming to an end!";
               }
            }
         }
         return result;
      }
      
      public function onFetchSellingPrice(result:Object) : void
      {
         if(result.hasOwnProperty("price"))
         {
            this.saveFeatureOptionsKey(KEY_SELLING_PRICE,result["price"]);
         }
         if(this.m_marketWindow)
         {
            this.m_marketWindow.hideLoaderText();
            this.m_marketWindow.untintWindow();
            this.m_marketWindow.enableInput = true;
            this.m_marketWindow.refreshWindow();
            this.m_marketWindow.startTimer();
            if(!Global.player.getSeenFlag(this.FARMERS_MARKET_MARKET_FTUE_SEEN))
            {
               this.m_marketWindow.showMainTutorial();
            }
         }
      }
      
      public function get currentSellingPrice() : int
      {
         return this.getFeatureOptionsKey(KEY_SELLING_PRICE) as int;
      }
      
      public function updateActiveDayForTutorial() : void
      {
         this.saveFeatureOptionsKey(this.KEY_ACTIVE_DAY_TIMESTAMP,FarmGameUtil.getMidnightTimestamp() / 1000);
      }
      
      private function assignWeekNews(weekIndex:int = -1) : void
      {
         this.getCurrentNewsTimeSlot();
         if(weekIndex == -1)
         {
            weekIndex = this.currentWeekIndex;
         }
         if(weekIndex == 0)
         {
            this.m_currentWeekNews = this.m_newsWeek1;
         }
         else if(weekIndex == 1)
         {
            this.m_currentWeekNews = this.m_newsWeek2;
         }
         else if(weekIndex == 2)
         {
            this.m_currentWeekNews = this.m_newsWeek3;
         }
         else if(weekIndex == 3)
         {
            this.m_currentWeekNews = this.m_newsWeek4;
         }
         else if(weekIndex == 4)
         {
            this.m_currentWeekNews = this.m_newsWeek5;
         }
      }
      
      public function decryptData(data:String) : String
      {
         var encryptionManager:SimpleCryptoManager = new SimpleCryptoManager();
         encryptionManager.init();
         return encryptionManager.decrypt(data);
      }
      
      private function isCurrentWeek(week:XML) : Boolean
      {
         var currentWeekName:String = KEY_WEEK + (this.currentWeekIndex + 1).toString();
         return currentWeekName == week["@name"];
      }
      
      private function getCurrentNewsTimeSlot() : int
      {
         var midNightTime:Number = FarmGameUtil.getMidnightTimestamp() / 1000;
         var serverTime:Number = GlobalEngine.serverTime / 1000;
         var currentTime:Number = serverTime - midNightTime;
         var timeArray:Array = FarmGameUtil.parseTimeLeft(currentTime);
         var timeHours:int = currentTime % FarmGameUtil.NUM_SECS_IN_DAY / 3600;
         var result:int = 0;
         this.m_slotTimestampsList[0] = midNightTime;
         if(timeHours >= 8 && timeHours < 12)
         {
            result = 1;
            this.m_slotTimestampsList[1] = midNightTime + NUM_SECS_FOUR_HOURS * 2;
         }
         else if(timeHours >= 12 && timeHours < 16)
         {
            result = 2;
            this.m_slotTimestampsList[2] = midNightTime + NUM_SECS_FOUR_HOURS * 3;
         }
         else if(timeHours >= 16 && timeHours < 20)
         {
            result = 3;
            this.m_slotTimestampsList[3] = midNightTime + NUM_SECS_FOUR_HOURS * 4;
         }
         else if(timeHours >= 20 && timeHours < 24)
         {
            result = 4;
            this.m_slotTimestampsList[4] = midNightTime + NUM_SECS_FOUR_HOURS * 5;
         }
         return result;
      }
      
      public function currentNewsTimeRemaining() : Number
      {
         var totalTime:Number = NaN;
         var serverTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(this.m_currentTimeSlot == 0)
         {
            totalTime = NUM_SECS_FOUR_HOURS * 2;
         }
         else
         {
            totalTime = NUM_SECS_FOUR_HOURS;
         }
         return totalTime - (serverTime - this.m_slotTimestampsList[this.m_currentTimeSlot]);
      }
      
      public function hasNewsSlotTimeExpired() : Boolean
      {
         var totalTime:Number = NaN;
         var serverTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var expired:Boolean = false;
         if(this.m_currentTimeSlot == 0)
         {
            totalTime = NUM_SECS_FOUR_HOURS * 2;
         }
         else
         {
            totalTime = NUM_SECS_FOUR_HOURS;
         }
         if(serverTime - this.m_slotTimestampsList[this.m_currentTimeSlot] > totalTime)
         {
            expired = true;
         }
         this.m_currentTimeSlot = this.getCurrentNewsTimeSlot();
         return expired;
      }
      
      public function getUserZid() : String
      {
         return this.m_zid;
      }
      
      public function getCurrentLeaderboard() : Object
      {
         var startDate:Number = NaN;
         var endDate:Number = NaN;
         var leaderboardXML:XML = null;
         var leaderboardData:Object = this.getLeaderboardData();
         var result:Object = null;
         var weekCount:int = 0;
         for each(leaderboardXML in leaderboardData)
         {
            weekCount++;
            if(FarmGameUtil.checkDateGate(leaderboardXML.@start.toString(),leaderboardXML.@end.toString()))
            {
               result = new Object();
               result.name = leaderboardXML.@name.toString();
               result.start = leaderboardXML.@start.toString();
               result.end = leaderboardXML.@end.toString();
               result.count = weekCount;
               break;
            }
         }
         return result;
      }
      
      public function getLeaderboardData() : Array
      {
         if(this.m_staticData)
         {
            return this.m_staticData.leaderboardConfigData;
         }
         return null;
      }
      
      public function getWeeklyLeaderboardPoints() : int
      {
         var leaderboardPoints:int = 0;
         return this.getFeatureOptionsKey(this.WEEKLY_SCORE) as int;
      }
      
      public function initializeLeaderBoardProgress(isSync:Boolean = false) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getLeaderboardEntries",this.getLeaderboardEntries,[m_featureName,isSync]));
      }
      
      public function checkLastDayInWeek() : int
      {
         var days:int = 0;
         var hours:int = 0;
         var result:Number = this.getTimeLeftInWeek();
         if(result < 0)
         {
            result = 0;
         }
         var timeLeftArray:Array = FarmGameUtil.parseTimeLeft(result);
         if(Boolean(timeLeftArray) && timeLeftArray.length > 3)
         {
            days = int(timeLeftArray[0]);
            hours = int(timeLeftArray[1]);
         }
         return days;
      }
      
      public function isShowLeaderBoardPopup() : Boolean
      {
         var isShow:Boolean = false;
         var leaderBoardData:Object = this.getCurrentLeaderboard();
         var currentLeaderboard:String = leaderBoardData.name;
         var leaderboard:String = this.getFeatureOptionsKey(KEY_CURRENT_LEADERBOARD).toString();
         if(leaderboard != currentLeaderboard && this.getFeatureOptionsKey(this.WEEKLY_SCORE) > 0)
         {
            isShow = true;
         }
         return isShow;
      }
      
      public function getLeaderboardEntries(result:Object = null) : void
      {
         var collectionData:Object = null;
         var giftKey:String = null;
         var gifts:Array = null;
         var giftName:String = null;
         var weeklyLeaderboardData:Object = null;
         if(result != null)
         {
            this.m_zid = result["zid"];
            collectionData = this.getFeatureOption();
            if(Boolean(result["gift"]) && Boolean(result["giftLeaderboardName"]))
            {
               giftKey = m_featureName + "_" + result["giftLeaderboardName"] + "_awarded";
               gifts = new Array();
               for each(giftName in result["gift"])
               {
                  Global.player.addGift(giftName);
                  gifts.push(giftName);
                  StatsManager.count(FEATURE_TRACKING,"leaderboard",giftName,result["userData"]["rank"],this.getWeeklyLeaderboardPoints().toString());
               }
               weeklyLeaderboardData = this.getCurrentLeaderboard();
               if(weeklyLeaderboardData)
               {
                  collectionData[KEY_CURRENT_LEADERBOARD] = weeklyLeaderboardData.name;
               }
               collectionData[KEY_SAVED_LEADERBOARD_RESULT] = result["userData"];
               collectionData[giftKey] = true;
               collectionData[this.WEEKLY_SCORE] = 0;
            }
            if(Boolean(this.m_leaderboardWindow) && result["syncMainUI"] == false)
            {
               this.m_leaderboardWindow.updateLeaderboardFrame(true);
               this.m_leaderboardWindow.populateLeaderboard(result);
            }
            if(Boolean(this.m_mainWindow) && result["userData"]["value"] > 0)
            {
               this.refreshLeaderboardPaneData(result);
               this.m_mainWindow.showLeaderboardPaneData();
            }
            if(result["userData"])
            {
               collectionData[KEY_SAVED_LEADERBOARD_RESULT] = result["userData"];
               collectionData[this.WEEKLY_SCORE] = result["userData"]["value"];
            }
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,FEATURE_NAME,collectionData);
         }
         else if(this.m_leaderboardWindow)
         {
            this.m_leaderboardWindow.updateLeaderboardFrame(false);
         }
      }
      
      public function getLeaderboardWeekIndex(leaderboardName:String) : int
      {
         switch(leaderboardName)
         {
            case "FarmersMarketInnovationWeek1":
               return 1;
            case "FarmersMarketInnovationWeek2":
               return 2;
            case "FarmersMarketInnovationWeek3":
               return 3;
            case "FarmersMarketInnovationWeek4":
               return 4;
            case "FarmersMarketInnovationWeek5":
               return 5;
            default:
               return -1;
         }
      }
      
      public function showLeaderboardUI(showGift:Boolean = false) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         FarmStatsManager.count(FEATURE_TRACKING,"Leaderboard","Click");
         this.m_leaderboardWindow = new FarmersMarketInnovationLeaderboardWindow("assets/dialogs/FV_Jan_innovation/FV_Leaderboard_FarmersMarket.swf",m_featureName,null,null,showGift);
         UI.displayPopup(this.m_leaderboardWindow,false);
      }
      
      public function onRedeemStarted() : void
      {
         this.showLeaderboardUI(true);
         this.saveFeatureOptionsKey("forceGrantedLB",1);
         FarmStatsManager.count(m_featureName,"grantLBReward","FeatureEnd");
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onRedeemStarted",null,[m_featureName]),true);
      }
      
      public function getDayPoints() : int
      {
         return this.getFeatureOptionsKey(this.KEY_DAY_POINTS) as int;
      }
      
      public function getCurrentProduceQty() : int
      {
         return this.getFeatureOptionsKey(KEY_ORDERBOARD_TASK_POINTS) as int;
      }
      
      public function getTotalGoldCoins() : int
      {
         return this.getFeatureOptionsKey(KEY_TOTAL_GOLD_COINS) as int;
      }
      
      public function getWeekProduceName(qty:int) : String
      {
         var weekIndex:int = this.currentWeekIndex;
         var result:String = this.m_weeklyProduceNames[weekIndex];
         if(qty > 1)
         {
            result += result == "Cherry Tomato" ? "es" : "s";
         }
         return result;
      }
      
      public function get currentWeekIndex() : int
      {
         var weekIndex:int = 0;
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("01/20/2020");
         weekIndex = (GlobalEngine.serverTime - featureStartDayTS) / FarmGameUtil.NUM_MSECS_IN_DAY / FarmGameUtil.NUM_DAYS_IN_WEEK;
         if(weekIndex < 0)
         {
            weekIndex = 0;
         }
         return weekIndex;
      }
      
      public function get currentDayIndex() : int
      {
         var dayIndex:int = 0;
         var activeDayTS:Number = this.getFeatureOptionsKey(this.KEY_ACTIVE_DAY_TIMESTAMP) as int;
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("01/20/2020") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         dayIndex = (activeDayTS - featureStartDayTS) / FarmGameUtil.NUM_SECS_IN_DAY;
         if(dayIndex < 0)
         {
            dayIndex = 0;
         }
         return dayIndex;
      }
      
      public function get currentDayByDate() : int
      {
         var dayIndex:int = 0;
         var activeDayTS:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("01/20/2020") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         dayIndex = (activeDayTS - featureStartDayTS) / FarmGameUtil.NUM_SECS_IN_DAY;
         if(dayIndex < 0)
         {
            dayIndex = 0;
         }
         return dayIndex;
      }
      
      public function get dayIndexInCurrentWeek() : int
      {
         var dayIndex:int = this.currentDayIndex;
         return int(dayIndex % 7);
      }
      
      public function getTimeLeftInDay() : Number
      {
         var dayExpiredTime:Number = this.getFeatureOptionsKey(this.KEY_ACTIVE_DAY_TIMESTAMP) + 86400;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return dayExpiredTime - currenttime;
      }
      
      public function hasActiveDayExpired() : Boolean
      {
         var expired:Boolean = false;
         var activeTime:int = this.getFeatureOptionsKey(this.KEY_ACTIVE_DAY_TIMESTAMP) as int;
         var currenttime:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(currenttime - activeTime > 86400)
         {
            expired = true;
         }
         return expired;
      }
      
      public function getTimeLeftInWeek() : Number
      {
         var weekData:Object = this.getCurrentWeek();
         if(weekData == null)
         {
            return -1;
         }
         var weekExpiredTimeInString:String = weekData.end;
         var weekExpiredTime:Number = FarmGameUtil.synchronizedDateTimeToNumber(weekExpiredTimeInString) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return weekExpiredTime - currenttime;
      }
      
      public function hasActiveWeekExpired() : Boolean
      {
         var expired:Boolean = false;
         var weekData:Object = this.getCurrentWeek();
         var curWeek:int = weekData.count - 1;
         var activeWeek:int = this.getFeatureOptionsKey(KEY_CURRENT_WEEK) as int;
         if(activeWeek != curWeek)
         {
            expired = true;
         }
         return expired;
      }
      
      public function getCurrentWeek() : Object
      {
         var startDate:Number = NaN;
         var endDate:Number = NaN;
         var weekXML:XML = null;
         if(this.hasFeatureExpired())
         {
            return {
               "count":6,
               "end":"",
               "name":"",
               "start":""
            };
         }
         var weekData:Object = this.getWeeksArray();
         var result:Object = null;
         var weekCount:int = 0;
         for each(weekXML in weekData)
         {
            weekCount++;
            if(FarmGameUtil.checkDateGate(weekXML.@start.toString(),weekXML.@end.toString()))
            {
               result = new Object();
               result.name = weekXML.@name.toString();
               result.start = weekXML.@start.toString();
               result.end = weekXML.@end.toString();
               result.count = weekCount;
               break;
            }
         }
         return result;
      }
      
      public function addRemainingOBPoints(questIndex:int, callback:Function, taskPoints:int = 0) : void
      {
         var tasks:Vector.<FarmTask> = getTasks();
         grantPointsForTask(taskPoints);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"addRemainingOBPoints",ZCacheUtil.applyPartial(onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
         resetActionCountsForTasks(tasks[questIndex]);
      }
      
      public function addRemainingOBPointsOnSkip(questIndex:int, callback:Function, taskPoints:int = 0) : void
      {
         var questTasks:Vector.<FarmTask> = null;
         questTasks = getTasks();
         this.m_skipSlotNumber = questIndex;
         var confirmationText:String = ZLocUtils.t("Dialogs","TaskFarmCashBuyConfirmation",{"price":questTasks[questIndex].skipCashValue});
         if(UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptSkipConfirmation1,"farmAnimatedCashConfirmation",true,true))
         {
            if(this.mainWindow)
            {
               this.mainWindow.tintWindow();
               this.mainWindow.enableInput = false;
            }
         }
      }
      
      private function onAcceptSkipConfirmation1(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.onClickSkipButtonAfterConfirmation1(event);
         }
         else if(this.mainWindow)
         {
            this.mainWindow.untintWindow();
            this.mainWindow.enableInput = true;
         }
      }
      
      private function onClickSkipButtonAfterConfirmation1(event:Event) : void
      {
         var savedTasks:Array = null;
         var tasks:Vector.<FarmTask> = getTasks();
         var remainingSpace:int = this.currentStorageCapacity - this.getCurrentProduceQty();
         if(Global.player.canBuyCash(tasks[this.m_skipSlotNumber].skipCashValue))
         {
            Global.player.cash -= tasks[this.m_skipSlotNumber].skipCashValue;
            grantPointsForTask(remainingSpace);
            savedTasks = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
            savedTasks[this.m_skipSlotNumber][KEY_ORDERBOARD_PROGRESS] = tasks[this.m_skipSlotNumber].total;
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,savedTasks);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"addRemainingOBPointsOnSkip",ZCacheUtil.applyPartial(onInitQuestComplete,this,[null]),[m_featureName,this.m_skipSlotNumber]),true);
            resetActionCountsForTasks(tasks[this.m_skipSlotNumber]);
            if(this.mainWindow)
            {
               this.mainWindow.refreshWindow();
            }
         }
         else if(this.mainWindow)
         {
            this.mainWindow.resumeWindow();
         }
      }
      
      public function grantDailyReward() : void
      {
         var rewardItem:FarmItem = null;
         if(this.getDayPoints() >= this.MAX_DAILY_LIMIT && this.getFeatureOptionsKey(this.KEY_DAILY_REWARD_GRANTED) == false)
         {
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_dailyRewards[this.currentDayIndex]);
            if(rewardItem)
            {
               Global.player.addGift(rewardItem.name);
               UI.displayPopup(new FarmersMarketInnovationMilestoneRewardWindow("assets/dialogs/expansion/FV_RewardDialog.swf",m_featureName,rewardItem,null,"assets/dialogs/farmfest/RewardDialog.png",false,null,this.getDayPoints()),false);
               this.saveFeatureOptionsKey(this.KEY_DAILY_REWARD_GRANTED,true);
               FarmStatsManager.count(FEATURE_TRACKING,"daily",rewardItem.name,this.getTotalGoldCoins().toString());
               FarmStatsManager.count(FEATURE_TRACKING,"leaderboard",this.currentDayIndex.toString(),"start",this.getTotalGoldCoins().toString());
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"grantDailyReward",null,[m_featureName]));
            }
         }
      }
      
      public function getNewDailyReward() : FarmItem
      {
         var rewardItem:FarmItem = null;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("01/20/2020") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var dayIndex:int = (currenttime - featureStartDayTS) / FarmGameUtil.NUM_SECS_IN_DAY;
         if(this.m_dailyRewards.hasOwnProperty(dayIndex.toString()))
         {
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_dailyRewards[dayIndex]);
         }
         return rewardItem;
      }
      
      public function isDailyRewardGranted() : Boolean
      {
         return this.getFeatureOptionsKey(this.KEY_DAILY_REWARD_GRANTED) as Boolean;
      }
      
      public function getWeeksArray() : Array
      {
         return this.m_staticData.weeks;
      }
      
      public function get currentWeekSellIcon() : String
      {
         return this.ICONS_PATH_PREFIX + this.m_produceList[this.currentWeekIndex] + "_sell.png";
      }
      
      public function get currentWeekStockIcon() : String
      {
         return this.ICONS_PATH_PREFIX + this.m_produceList[this.currentWeekIndex] + "_stock.png";
      }
      
      public function get currentWeekSmallIcon() : String
      {
         return this.ICONS_PATH_PREFIX + this.m_produceList[this.currentWeekIndex] + "_small.png";
      }
      
      public function get previousWeekIcon() : String
      {
         var icon_url:String = "";
         if(this.currentWeekIndex != 0)
         {
            icon_url = this.ICONS_PATH_PREFIX + this.m_produceList[this.currentWeekIndex - 1] + "_small.png";
         }
         return icon_url;
      }
      
      public function hasExpiryDatePassedForFeature() : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("02/24/2020") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         timeLeft = endTime - now;
         if(timeLeft <= 0)
         {
            result = true;
         }
         return result;
      }
      
      private function loadStaticData() : void
      {
         var leaderboardxml:XML = null;
         var feedConfigs:XMLList = null;
         var i:int = 0;
         var weekxml:XML = null;
         this.m_staticData = new Object();
         this.m_staticData.typeArray = [];
         this.m_staticData.rewardCostArray = [];
         this.m_staticData.tilesArray = [];
         this.m_staticData.endDate = "";
         this.m_staticData.consumable = "";
         this.m_staticData.currencyName = "";
         this.m_staticData.initialGrant = 0;
         this.m_staticData.rewardGrantCount = 0;
         this.m_staticData.gameCost = 0;
         this.m_staticData.bonusGrantDate = new String();
         this.m_staticData.weeks = new Array();
         this.m_staticData.rewards = new Array();
         this.m_staticData.leaderboardConfigData = new Array();
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         if(featureXML != null)
         {
            m_initialized = true;
            this.m_staticData.bonusGrantDate = featureXML.listEndDate.toString();
            this.m_staticData.initialGrant = featureXML.initialGrant.toString();
            this.m_staticData.currencyName = featureXML.currencyItem.@name.toString();
            if(featureXML.leaderboardConfig)
            {
               for each(leaderboardxml in featureXML.leaderboardConfig.leaderboard)
               {
                  this.m_staticData.leaderboardConfigData.push(leaderboardxml);
               }
            }
            if(featureXML.hasOwnProperty("feedConfig"))
            {
               feedConfigs = featureXML.feedConfig.children();
               for(i = 0; i < feedConfigs.length(); i++)
               {
                  this.m_feedConfig[feedConfigs[i].@source.toString()] = new FeedData(m_featureName,feedConfigs[i]);
               }
            }
            if(featureXML.weeks)
            {
               for each(weekxml in featureXML.weeks.week)
               {
                  this.m_staticData.weeks.push(weekxml);
               }
            }
         }
      }
      
      public function showMarketUI(showGift:Boolean = false) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         FarmStatsManager.count(FEATURE_TRACKING,"shopui","open");
         this.m_marketWindow = new FarmersMarketInnovationSalesWindow(FEATURE_NAME,"assets/dialogs/FV_Jan_innovation/FV_Market_FarmersMarket.swf",false);
         UI.displayPopup(this.m_marketWindow,false);
      }
      
      public function hasFeatureExpired() : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("02/24/2020");
         timeLeft = (endTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(timeLeft < 0)
         {
            result = true;
         }
         return result;
      }
      
      public function get currencyName() : String
      {
         this.m_currencyName = "casablanca_task_points";
         return this.m_currencyName;
      }
      
      public function get currentStorageCapacity() : int
      {
         var level:int = this.getFeatureOptionsKey(KEY_CURRENT_STORAGE_LEVEL) as int;
         var result:int = 0;
         if(m_storageCapacity.hasOwnProperty(level.toString()))
         {
            result = int(m_storageCapacity[level]);
         }
         return result;
      }
      
      public function get currentStorageLevel() : int
      {
         return this.getFeatureOptionsKey(KEY_CURRENT_STORAGE_LEVEL) as int;
      }
      
      public function get nextStorageCapacity() : int
      {
         var level:int = this.getFeatureOptionsKey(KEY_CURRENT_STORAGE_LEVEL) as int;
         var result:int = 0;
         if(m_storageCapacity.hasOwnProperty((level + 1).toString()))
         {
            result = int(m_storageCapacity[level + 1]);
         }
         return result;
      }
      
      public function getCostToUpgradeLevel() : int
      {
         var result:int = 0;
         var level:int = this.getFeatureOptionsKey(KEY_CURRENT_STORAGE_LEVEL) as int;
         var newLevel:int = level + 1;
         if(m_costForUpgrade.hasOwnProperty(newLevel.toString()))
         {
            result = int(m_costForUpgrade[newLevel]);
         }
         if(level >= 5)
         {
            result = 0;
         }
         return result;
      }
      
      public function upgradeStorageCapacity() : void
      {
         var amount:int = this.getCostToUpgradeLevel();
         var level:int = this.getFeatureOptionsKey(KEY_CURRENT_STORAGE_LEVEL) as int;
         if(Global.player.canBuyCash(amount))
         {
            Global.player.cash -= amount;
            this.saveFeatureOptionsKey(KEY_CURRENT_STORAGE_LEVEL,level + 1);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"upgradeStorageCapacity",null,[m_featureName]));
            if(this.mainWindow)
            {
               this.mainWindow.refreshWindow();
            }
         }
      }
      
      public function increaseProduceQty() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"increaseProduceQty",null,[m_featureName]));
      }
      
      public function reduceProduceQty() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"reduceProduceQty",null,[m_featureName]));
      }
      
      public function resetProduceSellQty() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"resetProduceQty",null,[m_featureName]));
      }
      
      public function sellProduce() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sellProduce",this.onSellProduceComplete,[m_featureName]));
      }
      
      public function onSellProduceComplete(result:Object) : void
      {
         var totalGold:int = 0;
         var dayPoints:int = 0;
         if(Boolean(result) && Boolean(result.hasOwnProperty("newQty")) && result.hasOwnProperty("gold_earned"))
         {
            this.saveFeatureOptionsKey(KEY_ORDERBOARD_TASK_POINTS,result["newQty"]);
            totalGold = this.getFeatureOptionsKey(KEY_TOTAL_GOLD_COINS) as int;
            dayPoints = this.getFeatureOptionsKey(this.KEY_DAY_POINTS) as int;
            this.saveFeatureOptionsKey(KEY_TOTAL_GOLD_COINS,totalGold + result["gold_earned"]);
            this.saveFeatureOptionsKey(this.WEEKLY_SCORE,this.getWeeklyLeaderboardPoints() + result["gold_earned"]);
            this.saveFeatureOptionsKey(this.KEY_DAY_POINTS,dayPoints + result["gold_earned"]);
            if(this.m_marketWindow)
            {
               this.m_marketWindow.refreshWindow();
               this.m_marketWindow.untintWindow();
               this.m_marketWindow.enableInput = true;
            }
         }
         if(Boolean(result) && Boolean(result.hasOwnProperty("milestoneReward")) && result["milestoneReward"] != null)
         {
            this.grantMileStoneReward(result["milestoneReward"]);
            this.showMilestoneRewardPopup(result["milestoneReward"]);
         }
         if(this.m_weeklyProduceNames.hasOwnProperty(this.currentWeekIndex.toString()))
         {
            FarmStatsManager.count(FEATURE_TRACKING,this.m_weeklyProduceNames[this.currentWeekIndex],result["newQty"],this.m_currentTimeSlot.toString(),dayPoints.toString(),totalGold.toString());
         }
         this.grantDailyReward();
      }
      
      public function isStorageCapacityFull() : Boolean
      {
         var result:Boolean = false;
         if(this.getCurrentProduceQty() >= this.currentStorageCapacity)
         {
            result = true;
         }
         return result;
      }
      
      public function exceedsStorageCapacity(pointsToAdd:int) : Boolean
      {
         var result:Boolean = false;
         var currentQty:int = this.getCurrentProduceQty() + pointsToAdd;
         if(currentQty > this.currentStorageCapacity)
         {
            result = true;
         }
         return result;
      }
      
      override protected function saveFeatureOptionsKey(optionName:String, optionsValue:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,optionName,optionsValue);
      }
      
      protected function getFeatureOption() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName);
      }
      
      public function closeStoragePopups() : void
      {
         if(this.m_limitedStoragePopup)
         {
            this.m_limitedStoragePopup.close();
            this.m_limitedStoragePopup = null;
         }
      }
      
      public function showLimitedStoragePopup(points:int, isSkip:Boolean = false) : void
      {
         UI.displayPopup(this.m_limitedStoragePopup = new FarmersMarketInnovationLimitedStoragePopup(FEATURE_NAME,"assets/dialogs/FV_Jan_innovation/FV_LimitedStorage_FarmersMarket.swf",points,isSkip),false);
      }
      
      public function get mainWindow() : FarmersMarketInnovationMainWindow
      {
         return this.m_mainWindow;
      }
      
      public function getFeatureEndDaysLeftText() : String
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var days:int = 0;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("02/24/2020");
         timeLeft = (endTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var result:String = "";
         if(timeLeft < 0)
         {
            timeLeft = 0;
         }
         var timeLeftArray:Array = FarmGameUtil.parseTimeLeft(timeLeft);
         if(Boolean(timeLeftArray) && timeLeftArray.length > 3)
         {
            days = int(timeLeftArray[0]);
            result = days.toString();
            if(days == 1)
            {
               result += " Day left!";
            }
            else if(days == 0)
            {
               result = HUD.getformattedTimeLeft(timeLeft) + " left!";
            }
            else
            {
               result += " Days left!";
            }
         }
         return result;
      }
      
      public function showMainWindow() : void
      {
         var leaderBoardData:Object = null;
         var currentLeaderboard:String = null;
         if(!this.hasExpiryDatePassedForFeature())
         {
            SERVICE_NAME = m_serviceName;
            if(!m_initialized)
            {
               this.loadStaticData();
            }
            leaderBoardData = this.getCurrentLeaderboard();
            currentLeaderboard = leaderBoardData.name;
            if(!this.getFeatureOptionsKey(KEY_CURRENT_LEADERBOARD))
            {
               this.saveFeatureOptionsKey(KEY_CURRENT_LEADERBOARD,currentLeaderboard);
            }
            if(this.isShowLeaderBoardPopup())
            {
               this.showLeaderboardUI(true);
            }
            else
            {
               this.m_mainWindow = new FarmersMarketInnovationMainWindow(FEATURE_NAME,"assets/dialogs/FV_Jan_innovation/FV_Orderboard_FarmersMarket.swf",false);
               startQuest(this.m_mainWindow.refreshTaskFrame);
               UI.displayPopup(this.m_mainWindow,false);
               m_orderboardWindow = this.m_mainWindow;
               FarmStatsManager.count(FEATURE_TRACKING,"mainui","open");
            }
         }
      }
      
      public function setUpHudFarmersMarket() : void
      {
         Global.hud.setBottomHudFarmersMarketInnovationButton(new HudFarmersMarketInnovationButton("assets/dialogs/FV_Jan_innovation/FV_hud_FarmersMarket.swf",FEATURE_NAME));
      }
      
      public function getNextBonusReward() : String
      {
         var totalGoldCoins:int = this.getTotalGoldCoins();
         if(totalGoldCoins >= 50000 && totalGoldCoins < 200000)
         {
            return "xfs_streetvendorshop";
         }
         if(totalGoldCoins >= 200000 && totalGoldCoins < 500000)
         {
            return "xfs_valleymarketshop";
         }
         if(totalGoldCoins >= 500000 && totalGoldCoins < 1000000)
         {
            return "xfs_valleygroceryshop";
         }
         if(totalGoldCoins >= 1000000)
         {
            return "xfs_farmfreshsupermarket";
         }
         return null;
      }
      
      public function showInventionRewardPopup(rewardName:String) : void
      {
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
         this.m_inventionRewardBonusPopup = new FarmersMarketBonusRewardWindow("assets/dialogs/FV_Jan_innovation/FV_FeatureEnd_FarmersMarket.swf",FEATURE_NAME,rewardItem,1,this.postInventionShare(rewardItem));
         UI.displayPopup(this.m_inventionRewardBonusPopup,false);
      }
      
      public function postInventionShare(rewardItem:FarmItem) : Function
      {
         return function(event:Event):void
         {
            var windowName:* = "FarmersMarket2020Innovation";
            var bundleId:* = windowName + "ShareInvention";
            var imageIcon:* = rewardItem.iconUrl;
            var bundleData:* = {
               "images":[{
                  "href":"{SN_APP_URL}",
                  "src":imageIcon
               }],
               "user":Global.player.name,
               "first_name":Global.player.firstName,
               "item":rewardItem.friendlyTitle
            };
            GlobalEngine.socialNetwork.publishFeedStory(bundleId,bundleData,[],false,null);
            if(m_inventionRewardBonusPopup)
            {
               m_inventionRewardBonusPopup.close();
            }
         };
      }
      
      public function grantFinalReward() : void
      {
         if(this.getFeatureOptionsKey(this.KEY_BONUS_REWARD_GRANTED) as int == 0)
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"featureEnd",this.onFeatureComplete,new Array(FEATURE_NAME)),true);
         }
      }
      
      public function onFeatureComplete(result:Object) : void
      {
         Global.player.setSeenFlag(FarmersMarketInnovationManager.BUILDING_INITIALISATION_FLAG_HARVEST,true);
         var building:String = "";
         if(result)
         {
            if(result.hasOwnProperty("none"))
            {
               this.m_inventionRewardBonusPopup = new FarmersMarketBonusRewardWindow("assets/dialogs/FV_Jan_innovation/FV_FeatureEnd_FarmersMarket.swf",FEATURE_NAME,null,2,null);
               UI.displayPopup(this.m_inventionRewardBonusPopup,false);
            }
            else if(result.hasOwnProperty("badge"))
            {
               Global.player.addGift(result["badge"]);
               this.showInventionRewardPopup(result["badge"]);
               building = result["badge"];
            }
            if(result.hasOwnProperty("BONUS_GRANTED"))
            {
               this.saveFeatureOptionsKey(this.KEY_BONUS_REWARD_GRANTED,result["BONUS_GRANTED"]);
            }
            if(result.hasOwnProperty("initial_harvest_time"))
            {
               this.saveFeatureOptionsKey(KEY_BONUS_HARVEST_START_TIME,result["initial_harvest_time"]);
            }
            FarmStatsManager.count(FEATURE_TRACKING,"grantBuilding",building,this.getTotalGoldCoins().toString());
         }
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
         if(Global.hud)
         {
            Global.hud.removeBottomHudHalloweenInnovation2019Button();
         }
      }
      
      public function canHarvestBonusRewardBuilding() : Boolean
      {
         var isStillHarvestable:Boolean = false;
         var bonusStartTime:Number = this.getFeatureOptionsKey(KEY_BONUS_HARVEST_START_TIME) as Number;
         if(bonusStartTime)
         {
            if(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - bonusStartTime < 14 * 86400)
            {
               isStillHarvestable = true;
            }
         }
         return isStillHarvestable;
      }
      
      public function isDecosReadyForHarvest(itemName:String) : Boolean
      {
         var result:Boolean = false;
         if(this.getTimeLeftForBonusHarvest(itemName) <= 0)
         {
            result = true;
         }
         return result;
      }
      
      public function getTimeLeftForBonusHarvest(itemName:String) : int
      {
         var key:String = itemName + this.LAST_HARVEST_TIME_KEY;
         var throttleTime:int = DEFAULT_HARVEST_THROTTLE_TIME;
         return getTimeLeft(key,throttleTime);
      }
      
      public function shouldShowBonusHarvestTimer() : Boolean
      {
         var isStillHarvestable:Boolean = false;
         var bonusStartTime:Number = this.getFeatureOptionsKey(KEY_BONUS_HARVEST_START_TIME) as Number;
         if(bonusStartTime)
         {
            if(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - bonusStartTime < 13 * 86400)
            {
               isStillHarvestable = true;
            }
         }
         return isStillHarvestable;
      }
      
      public function harvestBonusBuilding(buildingName:String) : void
      {
         var featureKey:String = null;
         var key:String = buildingName + this.LAST_HARVEST_TIME_KEY;
         Global.player.setFeatureLastShown(key,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         var harvestRewardName:String = this.getNextHarvestItemName(buildingName);
         var harvestFarmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(harvestRewardName);
         if(harvestFarmItem)
         {
            if(buildingName == "xfs_farmfreshsupermarket")
            {
               Global.player.addGift(harvestRewardName,null,2);
            }
            else
            {
               Global.player.addGift(harvestRewardName);
            }
            featureKey = m_featureName + this.LAST_HARVEST_TIME_KEY;
            FarmStatsManager.count(m_featureName,"Harvest",buildingName,harvestRewardName);
            UI.displayPopup(new GenericSingleRewardPopup(this.REWARD_POPUP_WINDOW,"xfs_Bonus_" + buildingName,harvestFarmItem,null,this.REWARD_WINDOW_IMAGE),false);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,SERVICE_FUNC_HARVEST_BONUS,null,[m_featureName,buildingName]),true);
         }
      }
      
      private function getNextHarvestItemName(itemName:String) : String
      {
         var harvestReward:String = null;
         var bonusCount:int = 0;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName);
         if(featureData.hasOwnProperty(BONUS_HARVEST_COUNT + itemName))
         {
            bonusCount = featureData[BONUS_HARVEST_COUNT + itemName] as int;
         }
         else
         {
            featureData[BONUS_HARVEST_COUNT + itemName] = 0;
            bonusCount = 0;
         }
         harvestReward = this.BONUS_HARVEST_MAP[itemName][bonusCount % this.BONUS_HARVEST_MAP[itemName].length];
         featureData[BONUS_HARVEST_COUNT + itemName] = bonusCount + 1;
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,m_featureName,featureData);
         return harvestReward;
      }
      
      public function refreshLeaderboardPaneData(result:Object) : void
      {
         var globalData:Object = result["globalLeaderboardData"] ? result["globalLeaderboardData"].slotData : null;
         var userData:Object = result["userData"];
         var dataToPopulate:Object = null;
         if(this.getWeeklyLeaderboardPoints() > 0)
         {
            if(userData["rank"] <= 3)
            {
               dataToPopulate = [globalData[0],globalData[1],globalData[2]];
            }
            else
            {
               dataToPopulate = [globalData[3],globalData[4],globalData[5]];
            }
         }
         this.m_leaderboardpane_data = dataToPopulate;
      }
      
      private function grantMileStoneReward(milestoneReward:Object) : void
      {
         Global.player.addGift(milestoneReward["name"],"",1);
         this.saveFeatureOptionsKey(this.KEY_LAST_MILESTONE_GRANTED,milestoneReward["id"]);
         FarmStatsManager.count(FEATURE_TRACKING,"Milestone",milestoneReward["id"].toString(),milestoneReward["name"],this.getTotalGoldCoins().toString());
      }
      
      private function showMilestoneRewardPopup(milestoneReward:Object) : void
      {
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(milestoneReward["name"]);
         if(rewardItem != null)
         {
            UI.displayPopup(new FarmersMarketInnovationMilestoneRewardWindow("assets/dialogs/expansion/FV_RewardDialog_Share.swf",m_featureName,rewardItem,null,"assets/dialogs/farmfest/RewardDialog.png",true,null,this.VAL_MILESTONE_POINTS_ARRAY[milestoneReward["id"]]),false);
         }
      }
      
      public function isPlayerEA() : Boolean
      {
         return WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_FARMFEST);
      }
      
      public function updateMarketTutorialFlag() : *
      {
         this.grantTutorialBenifits();
      }
   }
}

