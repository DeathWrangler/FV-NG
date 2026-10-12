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
   import Display.HUD.HUDWidgets.HudTropicalMarketInnovationButton;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.BaseFeatureManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.ItemFinderManager;
   import Managers.WorldSeasonsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.GenericSingleRewardPopup;
   import Widgets.Windows.TropicalMarketBonusRewardWindow;
   import Widgets.Windows.TropicalMarketInnovationLeaderboardWindow;
   import Widgets.Windows.TropicalMarketInnovationLimitedStoragePopup;
   import Widgets.Windows.TropicalMarketInnovationMainWindow;
   import Widgets.Windows.TropicalMarketInnovationMilestoneRewardWindow;
   import Widgets.Windows.TropicalMarketInnovationSalesWindow;
   import Widgets.Windows.TropicalMarketInnovationTileRewardsWindow;
   import Widgets.Windows.TropicalMarketInnovationTileUnlockWindow;
   import Widgets.Windows.TropicalMarketInnovationWelcomeBackWindow;
   import com.adobe.serialization.json.JSON;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.Timer;
   
   public class TropicalMarketInnovationManager extends GenericSlotedOrderboardManager
   {
      
      private static var m_initialized:Boolean = false;
      
      private static const FEATURE_TRACKING:String = "TropicalMarketInnovation";
      
      protected static var m_instance:Object = {};
      
      public static const FEATURE_NAME:String = "TropicalMarketInnovation";
      
      private static const m_serviceName:String = "TropicalMarketInnovationService";
      
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
      
      private static const m_storageCapacity:Array = [30,50,80,100,150,200];
      
      private static const KEY_TOTAL_GOLD_COINS:String = "total_gold_coins";
      
      private static const KEY_NEWS_CHANGE_TIMESTAMP:String = "news_change_time";
      
      private static const KEY_FTUE_BENEFIT_GRANTED:String = "ftue_points_granted";
      
      private static const m_costForUpgrade:Array = [0,10,20,25,40,50];
      
      public static const HUD_INITIALISATION_FLAG:String = "TropicalMarket_hud_initialise_flag";
      
      public static const ZRUNTIME_TROPIC_ESCAPE_LINK:String = "TROPIC_ESCAPE_LINK";
      
      public static const ZRUNTIME_TROPIC_ESCAPE_STAGE_LINK:String = "TROPIC_ESCAPE_STAGE_LINK";
      
      public static const ZRUNTIME_TROPIC_ESCAPE_TOKENS_UPDATE_DELAY:String = "TROPIC_ESCAPE_TOKENS_UPDATE_DELAY";
      
      public static const ZRUNTIME_TROPIC_ESCAPE_TOKENS_UPDATE_REPEAT_COUNT:String = "TROPIC_ESCAPE_TOKENS_UPDATE_REPEAT_COUNT";
      
      private static const TROPICAL_MARKET_TASK_BOOST_CALLOUT:String = "tropical_market_task_boost_callout";
      
      private var m_currencyName:String = "task_points";
      
      private var m_mainWindow:TropicalMarketInnovationMainWindow;
      
      private var m_welcomeBackPopup:TropicalMarketInnovationWelcomeBackWindow;
      
      private var m_tileUnlockPopup:TropicalMarketInnovationTileUnlockWindow;
      
      private const KEY_BONUS_REWARD_GRANTED:String = "tropical_market_bonus_reward_granted";
      
      public const TROPICAL_MARKET_MARKET_FTUE_SEEN:String = "tropical_market_market_ftue_seen";
      
      private const FLAG_FIRST_STARTNEWDAY:String = "tropical_market_first_newday";
      
      public const LAST_HARVEST_TIME_KEY:String = "_lastHarvestTimeKey";
      
      private var m_inventionRewardBonusPopup:TropicalMarketBonusRewardWindow;
      
      private const REWARD_POPUP_WINDOW_SHARE:String = "assets/dialogs/expansion/FV_RewardDialog_Share.swf";
      
      private const REWARD_WINDOW_IMAGE:String = "assets/dialogs/aloha/RewardDialog.png";
      
      private const REWARD_POPUP_WINDOW:String = "assets/dialogs/expansion/FV_RewardDialog.swf";
      
      private const ICONS_PATH_PREFIX:String = "assets/dialogs/FV_AugustInnovation_2020/";
      
      private const KEY_ACTIVE_DAY_TIMESTAMP:String = "active_day_timestamp";
      
      private const KEY_ESCAPE_TOKENS_COLLECTED:String = "escapeTokensCollected";
      
      private const KEY_ESCAPE_TOKENS_PROGRESS:String = "escapeTokensProgress";
      
      private const KEY_ESCAPE_TOKENS_AVAILABLE:String = "escapeTokensAvailable";
      
      private const KEY_ORDERBOARD_BOOSTS_AVAILABLE:String = "orderboardBoostsAvailable";
      
      private const KEY_TE_CONNECTION_INITIALIZED:String = "tropicEscapeConnectionInitialized";
      
      private const KEY_TASKS_DONE_WITHOUT_ORDERBOARD_BOOST:String = "orderboardTasksDoneWithoutBoost";
      
      private const KEY_CURRENT_TILE_LEVEL:String = "currentTileLevel";
      
      private var m_zid:String = "";
      
      protected var m_staticData:Object;
      
      private var m_feedConfig:Object = {};
      
      private var m_skipSlotNumber:int = 0;
      
      private const WEEKLY_SCORE:String = "weekly_score";
      
      private const KEY_DAILY_REWARD_GRANTED:String = "daily_reward_granted";
      
      private const MAX_DAILY_LIMIT:int = 10000;
      
      public var m_leaderboardWindow:TropicalMarketInnovationLeaderboardWindow;
      
      public var m_marketWindow:TropicalMarketInnovationSalesWindow;
      
      private var m_limitedStoragePopup:TropicalMarketInnovationLimitedStoragePopup;
      
      public const KEY_DAY_POINTS:String = "daily_points";
      
      private var m_currentTimeSlot:int = 0;
      
      private var m_slotTimestampsList:Array = [0,0,0,0,0];
      
      private var m_newsByID:Object = null;
      
      private var m_newsDataByWeek:Object = {};
      
      private var m_currentWeekNews:Array;
      
      private var m_newsWeek1:Array = [[14,28,14,0,1],[15,16,29,17,2],[3,18,19,30,20],[4,5,6,21,7],[22,8,31,9,23],[32,24,10,11,33],[12,13,25,26,27]];
      
      private var m_newsWeek2:Array = [[28,0,14,15,29],[30,1,2,31,16],[17,18,3,19,20],[4,5,21,22,6],[7,32,23,8,9],[24,25,33,10,26],[11,12,13,34,35]];
      
      private var m_newsWeek3:Array = [[14,0,15,1,28],[16,2,3,17,18],[4,29,19,20,5],[6,21,7,8,22],[30,9,31,23,10],[24,32,25,33,26],[11,27,12,13,34]];
      
      private var m_newsWeek4:Array = [[14,15,16,0,1],[29,17,2,3,18],[19,4,30,20,31],[5,21,6,7,22],[23,8,9,32,10],[24,25,33,11,26],[12,34,27,28,13]];
      
      private var m_newsWeek5:Array = [[28,14,0,29,15],[1,2,3,16,4],[17,30,18,5,6],[31,7,8,32,19],[9,10,20,21,33],[22,23,11,24,25],[12,34,26,13,35]];
      
      private var m_newsWeek6:Array = [[14,15,0,16,29],[1,2,17,30,3],[18,19,4,5,20],[31,6,21,7,32],[8,33,22,23,9],[24,25,10,34,26],[11,12,35,27,13]];
      
      public var BONUS_HARVEST_MAP:Object = {
         "xah_pineappledrinkhut":["fuel1","vehiclepart","pkg_xah_treasureparts","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard"],
         "xah_fruitdrinkshop":["consume_unwither","consume_organic_fertilizer","fuel1","vehiclepart","pkg_xah_treasureparts","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard"],
         "xah_freshsummerbar":["consume_instagrow","pkg_xah_bigbuildableparts","consume_turbo_charger","consume_unwither","consume_organic_fertilizer","fuel1","vehiclepart","pkg_xah_treasureparts","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands"],
         "xah_islandjuicemarket":["consume_instagrow","pkg_xah_bigbuildableparts","consume_turbo_charger","consume_unwither","consume_organic_fertilizer","fuel1","vehiclepart","pkg_xah_treasureparts","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands"]
      };
      
      private const m_dailyRewards:Array = ["goat_xah_hawaiishirt","pkg_xah_buildingessentials","chicken_xah_lighthouse","pkg_xah_buildingessentials","dog_xah_seashell","pkg_xah_treasureessentials","sheep_xah_sarong","pkg_xah_vehicleessentials","chipmunk_xah_palm","pkg_xah_buildingessentials","panda_xah_sundress","pkg_xah_farmessentials","pkg_xah_buildingessentials","cat_xah_lifeguard","pkg_xah_treasureessentials","pkg_xah_vehicleessentials","turtle_xah_hulaflower","pkg_xah_buildingessentials","pkg_xah_farmessentials","duck_xah_hooping","pkg_xah_buildingessentials","pkg_xah_treasureessentials","monkey_xah_beachball","pkg_xah_vehicleessentials","pkg_xah_buildingessentials","whale_xah_deepsea","pkg_xah_farmessentials","pkg_xah_buildingessentials","elephant_xah_bananalover","pkg_xah_treasureessentials","pkg_xah_vehicleessentials","penguin_xah_summer","pkg_xah_buildingessentials","pkg_xah_farmessentials","rabbit_xah_tropical","llama_xah_beachdrummer","pkg_xah_buildingessentials","pkg_xah_treasureessentials"
      ,"horse_xah_tropicbeauty","pkg_xah_vehicleessentials","dog_xah_sandwaypoodle","rhino_xah_sailready"];
      
      private const m_leaderBoardBadgeNames:Array = ["Street Vendor","Valley Producer","Valley Grocerer","Super Farmer"];
      
      public const VAL_MILESTONE_POINTS_ARRAY:Array = [50000,100000,250000,500000,800000,1200000,1500000];
      
      public const VAL_BONUS_REWARDS_POINTS_ARRAY:Array = [50000,300000,800000,1500000];
      
      public var m_leaderboardpane_data:Object;
      
      private const m_produceList:Array = ["passionfruitbunch","grapebunch","guavabunch","starfruitbunch","papayabunch","pinapplebunch"];
      
      private const m_weeklyProduceNames:Array = ["Passion Fruit","Grape","Guava","Starfruit","Papaya","Pineapple"];
      
      private const m_weeklyProduceBoostIconNames:Array = ["Passionfruit","Grapes","Guava","Starfruit","Papaya","Pineapple"];
      
      private const KEY_LAST_MILESTONE_GRANTED:String = "last_milestone_granted";
      
      private var TOKENS_REQUIRED_FOR_UNLOCK:Array = [20,50,100,200,300,60000];
      
      private var TILE_REWARDS:Array = ["xah_rubbletreasure9","xah_rubbletreasure10","xah_rubbletreasure11","xah_rubbletreasure12","xah_rubbletreasure13","xah_rubbletreasure13"];
      
      private var TILE_REWARD_NAMES:Array = ["Greenhill Beach","Resort Glen","Holiday Fields","Vistaview Plains","Sunshade Town","Sunshade Town"];
      
      private var FLAG_BOOST_POPUP_SEEN:String = "TropicalMarketInnovation_boost_popup";
      
      private var FLAG_TROPIC_CONNECTION_INITIALIZED:String = "TropicalMarketInnovation_tropic_escape_connection_initialized";
      
      private var FLAG_TROPIC_ESCAPE_FIRST_TRAVEL:String = "TropicalMarketInnovation_tropic_escape_first_travel";
      
      public const DEFAULT_THROTTLE_TIME:Number = 86400;
      
      public var m_appEnvironment:String = null;
      
      private var m_tokensUpdateInProgress:Boolean = false;
      
      private var m_tokensUpdateTimer:Timer = null;
      
      public function TropicalMarketInnovationManager(featureName:String)
      {
         super(featureName,m_serviceName);
         this.parseNewsDataFromConfig();
         startQuest();
         this.m_currentTimeSlot = this.getCurrentNewsTimeSlot();
         m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ALOHA);
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
      }
      
      public static function getInstance(featureName:String = "TropicalMarketInnovation") : TropicalMarketInnovationManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,TropicalMarketInnovationManager) as TropicalMarketInnovationManager;
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
         var newsData:XML = Global.farmGameSettingsManager.getXML().TropicalMarketInnovationNewsConfig[0];
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
         m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ALOHA);
         if(m_isEA && weekData.count == 1)
         {
            capacity = this.currentStorageCapacity;
            available = int(this.getFeatureOptionsKey(KEY_ORDERBOARD_TASK_POINTS));
            if(capacity - available >= 20)
            {
               this.saveFeatureOptionsKey(KEY_ORDERBOARD_TASK_POINTS,available + 20);
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
            produce = int(this.getFeatureOptionsKey(KEY_ORDERBOARD_TASK_POINTS));
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
            this.saveFeatureOptionsKey(KEY_TOTAL_GOLD_COINS,int(this.getFeatureOptionsKey(KEY_TOTAL_GOLD_COINS)) + coinsAdd);
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
            this.mainWindow.showTropicRewardPopup(true);
         }
         if(Boolean(result) && Boolean(result.hasOwnProperty("milestoneReward")) && result["milestoneReward"] != null)
         {
            this.grantMileStoneReward(result["milestoneReward"]);
            this.showMilestoneRewardPopup(result["milestoneReward"]);
         }
         this.grantDailyReward();
      }
      
      private function grantTutorialBenifits() : void
      {
         if(this.getFeatureOptionsKey(KEY_FTUE_BENEFIT_GRANTED) == 0)
         {
            this.saveFeatureOptionsKey(this.KEY_DAY_POINTS,2100);
            this.saveFeatureOptionsKey(KEY_TOTAL_GOLD_COINS,2100);
            this.saveFeatureOptionsKey(this.WEEKLY_SCORE,2100);
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
               if(weekIndex > 5)
               {
                  weekIndex = 5;
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
                  result["headline"] = "Tropical Market is ending";
                  result["paragraph"] = "Tropical Market event in Costal Countryside is finally coming to an end!";
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
            if(!Global.player.getSeenFlag(this.TROPICAL_MARKET_MARKET_FTUE_SEEN))
            {
               this.m_marketWindow.showMainTutorial();
            }
         }
      }
      
      public function get currentSellingPrice() : int
      {
         return int(this.getFeatureOptionsKey(KEY_SELLING_PRICE));
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
         else if(weekIndex == 5)
         {
            this.m_currentWeekNews = this.m_newsWeek6;
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
               result = {};
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
         return int(this.getFeatureOptionsKey(this.WEEKLY_SCORE));
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
         if(leaderboard != currentLeaderboard && int(this.getFeatureOptionsKey(this.WEEKLY_SCORE)) > 0)
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
               gifts = [];
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
            case "TropicalMarketInnovationWeek1":
               return 1;
            case "TropicalMarketInnovationWeek2":
               return 2;
            case "TropicalMarketInnovationWeek3":
               return 3;
            case "TropicalMarketInnovationWeek4":
               return 4;
            case "TropicalMarketInnovationWeek5":
               return 5;
            case "TropicalMarketInnovationWeek6":
               return 6;
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
         this.m_leaderboardWindow = new TropicalMarketInnovationLeaderboardWindow("assets/dialogs/FV_AugustInnovation_2020/FV_Leaderboard_AugustInnovation.swf",m_featureName,null,null,showGift);
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
         return int(this.getFeatureOptionsKey(this.KEY_DAY_POINTS));
      }
      
      public function getCurrentProduceQty() : int
      {
         return int(this.getFeatureOptionsKey(KEY_ORDERBOARD_TASK_POINTS));
      }
      
      public function getTotalGoldCoins() : int
      {
         return int(this.getFeatureOptionsKey(KEY_TOTAL_GOLD_COINS));
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
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("08/31/2020");
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
         var activeDayTS:Number = Number(this.getFeatureOptionsKey(this.KEY_ACTIVE_DAY_TIMESTAMP));
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("08/31/2020") / FarmGameUtil.NUM_MSECS_IN_SECOND;
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
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("08/31/2020") / FarmGameUtil.NUM_MSECS_IN_SECOND;
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
         var dayExpiredTime:Number = Number(this.getFeatureOptionsKey(this.KEY_ACTIVE_DAY_TIMESTAMP)) + 86400;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return dayExpiredTime - currenttime;
      }
      
      public function hasActiveDayExpired() : Boolean
      {
         var expired:Boolean = false;
         var activeTime:int = int(this.getFeatureOptionsKey(this.KEY_ACTIVE_DAY_TIMESTAMP));
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
         var activeWeek:int = int(this.getFeatureOptionsKey(KEY_CURRENT_WEEK));
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
               "count":7,
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
               result = {};
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
         this.grantPointsForTask(taskPoints);
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
            this.grantPointsForTask(remainingSpace);
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
               UI.displayPopup(new TropicalMarketInnovationMilestoneRewardWindow(this.REWARD_POPUP_WINDOW,m_featureName,rewardItem,null,this.REWARD_WINDOW_IMAGE,false,null,this.getDayPoints()),false);
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
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("08/31/2020") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var dayIndex:int = (currenttime - featureStartDayTS) / FarmGameUtil.NUM_SECS_IN_DAY;
         if(this.m_dailyRewards.hasOwnProperty(dayIndex.toString()))
         {
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_dailyRewards[dayIndex]);
         }
         return rewardItem;
      }
      
      public function isDailyRewardGranted() : Boolean
      {
         return Boolean(this.getFeatureOptionsKey(this.KEY_DAILY_REWARD_GRANTED));
      }
      
      public function getWeeksArray() : Array
      {
         return this.m_staticData.weeks;
      }
      
      public function get currentWeekSellIcon() : String
      {
         return this.ICONS_PATH_PREFIX + this.m_produceList[this.currentWeekIndex] + "_185.png";
      }
      
      public function get currentWeekStockIcon() : String
      {
         return this.ICONS_PATH_PREFIX + this.m_produceList[this.currentWeekIndex] + "_185.png";
      }
      
      public function get currentWeekSmallIcon() : String
      {
         return this.ICONS_PATH_PREFIX + this.m_produceList[this.currentWeekIndex] + "_100.png";
      }
      
      public function get currentWeekBoostIcon() : String
      {
         return this.ICONS_PATH_PREFIX + "BoostShare_Icon_" + this.m_weeklyProduceBoostIconNames[this.currentWeekIndex] + ".png";
      }
      
      public function get previousWeekIcon() : String
      {
         var icon_url:String = "";
         if(this.currentWeekIndex != 0)
         {
            icon_url = this.ICONS_PATH_PREFIX + this.m_produceList[this.currentWeekIndex - 1] + "_100.png";
         }
         return icon_url;
      }
      
      public function hasExpiryDatePassedForFeature() : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("10/12/2020") / FarmGameUtil.NUM_MSECS_IN_SECOND;
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
         this.m_staticData = {};
         this.m_staticData.typeArray = [];
         this.m_staticData.rewardCostArray = [];
         this.m_staticData.tilesArray = [];
         this.m_staticData.endDate = "";
         this.m_staticData.consumable = "";
         this.m_staticData.currencyName = "";
         this.m_staticData.initialGrant = 0;
         this.m_staticData.rewardGrantCount = 0;
         this.m_staticData.gameCost = 0;
         this.m_staticData.bonusGrantDate = String("");
         this.m_staticData.weeks = [];
         this.m_staticData.rewards = [];
         this.m_staticData.leaderboardConfigData = [];
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
         this.m_marketWindow = new TropicalMarketInnovationSalesWindow(FEATURE_NAME,"assets/dialogs/FV_AugustInnovation_2020/FV_Market_AugustInnovation.swf",false);
         UI.displayPopup(this.m_marketWindow,false);
      }
      
      public function hasFeatureExpired() : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("10/12/2020");
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
         var level:int = int(this.getFeatureOptionsKey(KEY_CURRENT_STORAGE_LEVEL));
         var result:int = 0;
         if(m_storageCapacity.hasOwnProperty(level.toString()))
         {
            result = int(m_storageCapacity[level]);
         }
         return result;
      }
      
      public function get currentStorageLevel() : int
      {
         return int(this.getFeatureOptionsKey(KEY_CURRENT_STORAGE_LEVEL));
      }
      
      public function get nextStorageCapacity() : int
      {
         var level:int = int(this.getFeatureOptionsKey(KEY_CURRENT_STORAGE_LEVEL));
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
         var level:int = int(this.getFeatureOptionsKey(KEY_CURRENT_STORAGE_LEVEL));
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
         var level:int = int(this.getFeatureOptionsKey(KEY_CURRENT_STORAGE_LEVEL));
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
            totalGold = int(this.getFeatureOptionsKey(KEY_TOTAL_GOLD_COINS));
            dayPoints = int(this.getFeatureOptionsKey(this.KEY_DAY_POINTS));
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
         if(this.isOrderboardBoostAvailable())
         {
            pointsToAdd *= 2;
         }
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
         UI.displayPopup(this.m_limitedStoragePopup = new TropicalMarketInnovationLimitedStoragePopup(FEATURE_NAME,"assets/dialogs/FV_AugustInnovation_2020/FV_LimitedStorage_AugustInnovation.swf",points,isSkip),false);
      }
      
      public function get mainWindow() : TropicalMarketInnovationMainWindow
      {
         return this.m_mainWindow;
      }
      
      public function set mainWindow(window:TropicalMarketInnovationMainWindow) : void
      {
         this.m_mainWindow = window;
      }
      
      public function get welcomeBackPopup() : TropicalMarketInnovationWelcomeBackWindow
      {
         return this.m_welcomeBackPopup;
      }
      
      public function get tileUnlockPopup() : TropicalMarketInnovationTileUnlockWindow
      {
         return this.m_tileUnlockPopup;
      }
      
      public function getFeatureEndDaysLeftText() : String
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var days:int = 0;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("10/12/2020");
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
         this.updateEscapeTokensCount();
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
               this.m_mainWindow = new TropicalMarketInnovationMainWindow(FEATURE_NAME,"assets/dialogs/FV_AugustInnovation_2020/FV_Orderboard_AugustInnovation.swf",false);
               startQuest(this.m_mainWindow.refreshTaskFrame);
               UI.displayPopup(this.m_mainWindow,false);
               m_orderboardWindow = this.m_mainWindow;
               FarmStatsManager.count(FEATURE_TRACKING,"mainui","open");
            }
         }
         if(!Global.player.getSeenFlag(this.FLAG_TROPIC_CONNECTION_INITIALIZED))
         {
            this.initializeTropicEscapeConnection();
         }
      }
      
      public function updateEscapeTokensCount() : void
      {
         if(!this.m_tokensUpdateInProgress)
         {
            this.m_tokensUpdateInProgress = true;
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"updateEscapeTokensCount",this.onUpdateEscapeTokensCount,[m_featureName]));
         }
      }
      
      private function onUpdateEscapeTokensCount(result:Object) : void
      {
         if(Boolean(result) && Boolean(result.success))
         {
            if(result.hasOwnProperty(this.KEY_ESCAPE_TOKENS_COLLECTED))
            {
               this.saveFeatureOptionsKey(this.KEY_ESCAPE_TOKENS_COLLECTED,result[this.KEY_ESCAPE_TOKENS_COLLECTED]);
            }
            if(result.hasOwnProperty(this.KEY_ESCAPE_TOKENS_AVAILABLE))
            {
               this.saveFeatureOptionsKey(this.KEY_ESCAPE_TOKENS_AVAILABLE,result[this.KEY_ESCAPE_TOKENS_AVAILABLE]);
            }
            if(result.hasOwnProperty(this.KEY_ESCAPE_TOKENS_PROGRESS))
            {
               this.saveFeatureOptionsKey(this.KEY_ESCAPE_TOKENS_PROGRESS,result[this.KEY_ESCAPE_TOKENS_PROGRESS]);
            }
            if(result.hasOwnProperty(this.KEY_ESCAPE_TOKENS_PROGRESS) && result[this.KEY_ESCAPE_TOKENS_PROGRESS] > 0 || this.isTileUnlockRequirementMet())
            {
               this.updateEscapeTokensProgress();
               if(this.mainWindow)
               {
                  if(result[this.KEY_ESCAPE_TOKENS_PROGRESS] > 0)
                  {
                     this.mainWindow.showWelcomeBackPopup(result[this.KEY_ESCAPE_TOKENS_PROGRESS]);
                  }
                  this.mainWindow.refreshBoostComponents();
               }
               else if(Global.worldManager.currentWorldType == "aloha" && result[this.KEY_ESCAPE_TOKENS_PROGRESS] > 0)
               {
                  this.showWelcomeBackPopup(result[this.KEY_ESCAPE_TOKENS_PROGRESS]);
               }
               this.trackEscapeTokensProgress(result[this.KEY_ESCAPE_TOKENS_PROGRESS]);
            }
            else
            {
               this.m_tokensUpdateInProgress = false;
            }
         }
         else
         {
            this.m_tokensUpdateInProgress = false;
         }
      }
      
      private function trackEscapeTokensProgress(tokensEarned:int) : void
      {
         var tokensAvailable:int = this.getEscapeTokensAvailable();
         var tokensCollected:int = this.getEscapeTokensCollected();
         StatsManager.count(m_featureName,"TokensEarned_Dialog",String(tokensEarned),String(tokensAvailable),String(tokensCollected));
      }
      
      public function isTileUnlockRequirementMet() : Boolean
      {
         var escapeTokensRequiredForNextTile:int = this.getEscapeTokensRequiredForNextTile();
         var escapeTokensCollected:int = this.getEscapeTokensCollected();
         return escapeTokensCollected >= escapeTokensRequiredForNextTile;
      }
      
      public function showTileUnlockPopup() : void
      {
         this.m_tileUnlockPopup = new TropicalMarketInnovationTileUnlockWindow(m_featureName,"assets/dialogs/FV_AugustInnovation_2020/FV_LandReward_AugustInnovation.swf",this.getEscapeTokensCollected(),this.getCurrentTileName(),this.getCurrentTileFriendlyName());
         UI.displayPopup(this.m_tileUnlockPopup,false);
      }
      
      public function getCurrentTileLevel() : int
      {
         return int(this.getFeatureOptionsKey(this.KEY_CURRENT_TILE_LEVEL));
      }
      
      public function showWelcomeBackPopup(progress:int) : void
      {
         this.m_welcomeBackPopup = new TropicalMarketInnovationWelcomeBackWindow(m_featureName,"assets/dialogs/FV_AugustInnovation_2020/FV_WelcomeBack_Popup_AugustInnovation.swf",progress);
         UI.displayPopup(this.m_welcomeBackPopup,false);
      }
      
      public function updateEscapeTokensProgress() : void
      {
         var tokensProgress:int = int(this.getFeatureOptionsKey(this.KEY_ESCAPE_TOKENS_PROGRESS));
         if(tokensProgress > 0 || this.isTileUnlockRequirementMet())
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"updateEscapeTokensProgress",this.onUpdateEscapeTokensProgress,[m_featureName,Global.player.uid]));
         }
         else
         {
            this.m_tokensUpdateInProgress = false;
         }
      }
      
      private function onUpdateEscapeTokensProgress(result:Object) : void
      {
         if(Boolean(result) && Boolean(result.success))
         {
            this.saveFeatureOptionsKey(this.KEY_ESCAPE_TOKENS_PROGRESS,0);
            if(Boolean(result["tileUnlocked"]) && Boolean(this.isTileUnlockRequirementMet()) && !this.isCurrentTileUnlocked())
            {
               if(this.welcomeBackPopup)
               {
                  this.welcomeBackPopup.close();
               }
               if(this.mainWindow)
               {
                  this.mainWindow.closeWelcomeBackPopup();
               }
               if(Global.worldManager.currentWorldType == "aloha")
               {
                  this.showTileUnlockPopup();
               }
            }
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"resetEscapeTokensProgress",this.onEscapeTokensProgressReset,[m_featureName]));
         }
         else
         {
            this.m_tokensUpdateInProgress = false;
         }
      }
      
      private function isCurrentTileUnlocked() : Boolean
      {
         var placedtile:Array = Global.world.getObjectsByName(this.getCurrentTileName());
         if(placedtile.length > 0)
         {
            return false;
         }
         return true;
      }
      
      private function onEscapeTokensProgressReset(result:Object) : void
      {
         this.m_tokensUpdateInProgress = false;
      }
      
      public function getEscapeTokenProgress() : int
      {
         return int(this.getFeatureOptionsKey(this.KEY_ESCAPE_TOKENS_PROGRESS));
      }
      
      public function setUpHudTropicalMarket() : void
      {
         Global.hud.setBottomHudTropicalMarketInnovationButton(new HudTropicalMarketInnovationButton("assets/dialogs/FV_AugustInnovation_2020/FV_hud_AugustInnovation.swf",FEATURE_NAME));
      }
      
      public function getNextBonusReward() : String
      {
         var totalGoldCoins:int = this.getTotalGoldCoins();
         if(totalGoldCoins >= 50000 && totalGoldCoins < 300000)
         {
            return "xah_pineappledrinkhut";
         }
         if(totalGoldCoins >= 300000 && totalGoldCoins < 800000)
         {
            return "xah_fruitdrinkshop";
         }
         if(totalGoldCoins >= 800000 && totalGoldCoins < 1500000)
         {
            return "xah_freshsummerbar";
         }
         if(totalGoldCoins >= 1500000)
         {
            return "xah_islandjuicemarket";
         }
         return null;
      }
      
      public function showInventionRewardPopup(rewardName:String) : void
      {
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
         this.m_inventionRewardBonusPopup = new TropicalMarketBonusRewardWindow("assets/dialogs/FV_AugustInnovation_2020/FV_FeatureEnd_AugustInnovation.swf",FEATURE_NAME,rewardItem,1,this.postInventionShare(rewardItem));
         UI.displayPopup(this.m_inventionRewardBonusPopup,false);
      }
      
      public function postInventionShare(rewardItem:FarmItem) : Function
      {
         return function(event:Event):void
         {
            var windowName:* = "TropicalMarketInnovation";
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
         if(int(this.getFeatureOptionsKey(this.KEY_BONUS_REWARD_GRANTED)) == 0)
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"featureEnd",this.onFeatureComplete,new Array(FEATURE_NAME)),true);
         }
      }
      
      public function onFeatureComplete(result:Object) : void
      {
         Global.player.setSeenFlag(TropicalMarketInnovationManager.BUILDING_INITIALISATION_FLAG_HARVEST,true);
         var building:String = "";
         if(result)
         {
            if(result.hasOwnProperty("none"))
            {
               this.m_inventionRewardBonusPopup = new TropicalMarketBonusRewardWindow("assets/dialogs/FV_AugustInnovation_2020/FV_FeatureEnd_AugustInnovation.swf",FEATURE_NAME,null,2,null);
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
         var bonusStartTime:Number = Number(this.getFeatureOptionsKey(KEY_BONUS_HARVEST_START_TIME));
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
         var bonusStartTime:Number = Number(this.getFeatureOptionsKey(KEY_BONUS_HARVEST_START_TIME));
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
            if(buildingName == "xah_islandjuicemarket")
            {
               Global.player.addGift(harvestRewardName,null,2);
            }
            else
            {
               Global.player.addGift(harvestRewardName);
            }
            featureKey = m_featureName + this.LAST_HARVEST_TIME_KEY;
            FarmStatsManager.count(m_featureName,"Harvest",buildingName,harvestRewardName);
            UI.displayPopup(new GenericSingleRewardPopup(this.REWARD_POPUP_WINDOW,"xah_Bonus_" + buildingName,harvestFarmItem,null,this.REWARD_WINDOW_IMAGE),false);
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
            UI.displayPopup(new TropicalMarketInnovationMilestoneRewardWindow(this.REWARD_POPUP_WINDOW_SHARE,m_featureName,rewardItem,null,this.REWARD_WINDOW_IMAGE,true,null,this.VAL_MILESTONE_POINTS_ARRAY[milestoneReward["id"]]),false);
         }
      }
      
      public function isPlayerEA() : Boolean
      {
         return WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ALOHA);
      }
      
      public function updateMarketTutorialFlag() : *
      {
         this.grantTutorialBenifits();
      }
      
      public function showTileRewardsWindow() : void
      {
         UI.displayPopup(new TropicalMarketInnovationTileRewardsWindow(m_featureName,"assets/dialogs/FV_AugustInnovation_2020/FV_TilesInfo_AugustInnovation.swf"),false);
      }
      
      public function travelToTropicEscape() : void
      {
         var redirectUrl:String = this.getTropicEscapeRedirectUrl();
         if(!Global.player.getSeenFlag(this.FLAG_TROPIC_ESCAPE_FIRST_TRAVEL))
         {
            Global.player.setSeenFlag(this.FLAG_TROPIC_ESCAPE_FIRST_TRAVEL);
            redirectUrl += "?miscId=" + String(Global.player.uid);
         }
         navigateToURL(new URLRequest(redirectUrl),"_blank");
         this.startEscapeTokensUpdates();
      }
      
      public function stopEscapeTokensUpdates() : void
      {
         this.resetTokensUpdateTimer();
         this.stopTokensUpdateTimer();
      }
      
      private function startEscapeTokensUpdates() : void
      {
         this.initializeTokensUpdateTimer();
         this.resetTokensUpdateTimer();
         this.startTokensUpdateTimer();
      }
      
      private function initializeTokensUpdateTimer() : void
      {
         if(!this.m_tokensUpdateTimer)
         {
            this.m_tokensUpdateTimer = new Timer(this.tokensUpdateDelay,this.tokensUpdateRepeatCount);
            this.m_tokensUpdateTimer.addEventListener(TimerEvent.TIMER,this.onTokensUpdateTimerEvent);
            this.m_tokensUpdateTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTokensUpdateTimerCompleteEvent);
         }
      }
      
      private function startTokensUpdateTimer() : void
      {
         if(this.m_tokensUpdateTimer)
         {
            this.m_tokensUpdateTimer.start();
         }
      }
      
      private function stopTokensUpdateTimer() : void
      {
         if(this.m_tokensUpdateTimer)
         {
            this.m_tokensUpdateTimer.stop();
         }
      }
      
      private function resetTokensUpdateTimer() : void
      {
         if(this.m_tokensUpdateTimer)
         {
            this.m_tokensUpdateTimer.reset();
         }
      }
      
      private function get tokensUpdateRepeatCount() : int
      {
         var tokensUpdateRepeatCount:int = 1;
         if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_TROPIC_ESCAPE_TOKENS_UPDATE_REPEAT_COUNT) && Boolean(Global.flashHotParams[ZRUNTIME_TROPIC_ESCAPE_TOKENS_UPDATE_REPEAT_COUNT]))
         {
            tokensUpdateRepeatCount = int(Global.flashHotParams[ZRUNTIME_TROPIC_ESCAPE_TOKENS_UPDATE_REPEAT_COUNT]);
         }
         return tokensUpdateRepeatCount;
      }
      
      private function get tokensUpdateDelay() : Number
      {
         var tokensUpdateDelay:Number = 600000;
         if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_TROPIC_ESCAPE_TOKENS_UPDATE_DELAY) && Boolean(Global.flashHotParams[ZRUNTIME_TROPIC_ESCAPE_TOKENS_UPDATE_DELAY]))
         {
            tokensUpdateDelay = Number(Global.flashHotParams[ZRUNTIME_TROPIC_ESCAPE_TOKENS_UPDATE_DELAY]);
         }
         return tokensUpdateDelay;
      }
      
      private function onTokensUpdateTimerEvent(event:TimerEvent) : void
      {
         this.updateEscapeTokensCount();
      }
      
      private function onTokensUpdateTimerCompleteEvent(event:TimerEvent) : void
      {
      }
      
      public function getTropicEscapeRedirectUrl() : String
      {
         var zprodUrl:String = "https://apps.facebook.com/tropic_escape";
         if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_TROPIC_ESCAPE_LINK) && Boolean(Global.flashHotParams[ZRUNTIME_TROPIC_ESCAPE_LINK]))
         {
            zprodUrl = Global.flashHotParams[ZRUNTIME_TROPIC_ESCAPE_LINK];
         }
         var redirectUrl:String = zprodUrl;
         if(this.m_appEnvironment != null && this.m_appEnvironment != "zprod")
         {
            redirectUrl = "https://apps.facebook.com/tropic_escape_stage";
            if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_TROPIC_ESCAPE_STAGE_LINK) && Boolean(Global.flashHotParams[ZRUNTIME_TROPIC_ESCAPE_STAGE_LINK]))
            {
               redirectUrl = Global.flashHotParams[ZRUNTIME_TROPIC_ESCAPE_STAGE_LINK];
            }
         }
         return redirectUrl;
      }
      
      public function fetchAppEnvironment() : void
      {
         if(this.m_appEnvironment == null)
         {
            this.m_appEnvironment = "zprod";
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getEnvironment",this.onGetEnviroment,[m_featureName]),true);
         }
      }
      
      private function onGetEnviroment(result:Object) : void
      {
         if(Boolean(result) && Boolean(result.success))
         {
            if(result.hasOwnProperty("environment"))
            {
               this.m_appEnvironment = result["environment"];
            }
         }
      }
      
      override public function grantPointsForTask(pointsForTask:int) : void
      {
         if(this.isOrderboardBoostAvailable())
         {
            pointsForTask *= 2;
            this.consumeOrderboardBoost();
         }
         else
         {
            this.saveFeatureOptionsKey(this.KEY_TASKS_DONE_WITHOUT_ORDERBOARD_BOOST,int(this.getFeatureOptionsKey(this.KEY_TASKS_DONE_WITHOUT_ORDERBOARD_BOOST)) + 1);
         }
         pointsForTask = Math.min(pointsForTask,this.currentStorageCapacity - this.getCurrentProduceQty());
         super.grantPointsForTask(pointsForTask);
      }
      
      public function isOrderboardBoostAvailable() : Boolean
      {
         var boostsAvailable:int = int(this.getFeatureOptionsKey(this.KEY_ORDERBOARD_BOOSTS_AVAILABLE));
         return boostsAvailable > 0;
      }
      
      private function consumeOrderboardBoost() : void
      {
         this.saveFeatureOptionsKey(this.KEY_ORDERBOARD_BOOSTS_AVAILABLE,int(this.getFeatureOptionsKey(this.KEY_ORDERBOARD_BOOSTS_AVAILABLE)) - 1);
      }
      
      public function getEscapeTokensAvailable() : int
      {
         return int(this.getFeatureOptionsKey(this.KEY_ESCAPE_TOKENS_AVAILABLE));
      }
      
      public function getOrderboardBoostsAvailable() : int
      {
         return int(this.getFeatureOptionsKey(this.KEY_ORDERBOARD_BOOSTS_AVAILABLE));
      }
      
      public function getEscapeTokensCollected() : int
      {
         return int(this.getFeatureOptionsKey(this.KEY_ESCAPE_TOKENS_COLLECTED));
      }
      
      public function getEscapeTokensRequiredForNextTile() : int
      {
         var tileLevel:int = int(this.getFeatureOptionsKey(this.KEY_CURRENT_TILE_LEVEL));
         return this.TOKENS_REQUIRED_FOR_UNLOCK[tileLevel];
      }
      
      public function getEscapeTokensRequiredForABoost() : int
      {
         return 3;
      }
      
      public function getOrderboardBoostsAvailableinABoost() : int
      {
         return 5;
      }
      
      public function activateOrderboardBoost() : void
      {
         var escapeTokensAvailable:int = this.getEscapeTokensAvailable();
         var orderboardBoostsAvailable:int = this.getOrderboardBoostsAvailable();
         if(escapeTokensAvailable >= this.getEscapeTokensRequiredForABoost())
         {
            escapeTokensAvailable -= this.getEscapeTokensRequiredForABoost();
            orderboardBoostsAvailable += this.getOrderboardBoostsAvailableinABoost();
            this.saveFeatureOptionsKey(this.KEY_ESCAPE_TOKENS_AVAILABLE,escapeTokensAvailable);
            this.saveFeatureOptionsKey(this.KEY_ORDERBOARD_BOOSTS_AVAILABLE,orderboardBoostsAvailable);
            this.saveFeatureOptionsKey(this.KEY_TASKS_DONE_WITHOUT_ORDERBOARD_BOOST,0);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"activateOrderboardBoost",null,[m_featureName]));
            if(this.mainWindow)
            {
               this.mainWindow.refreshBoostComponents();
               if(!Global.player.getSeenFlag(this.FLAG_BOOST_POPUP_SEEN))
               {
                  Global.player.setSeenFlag(this.FLAG_BOOST_POPUP_SEEN);
                  this.mainWindow.closeBoostEndedPopup();
                  this.mainWindow.showBoostActivatedPopup();
               }
               this.mainWindow.refreshTaskFrame();
            }
            StatsManager.count(m_featureName,"mainui","ActivateBoost","Click");
         }
      }
      
      public function initializeTropicEscapeConnection() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"initializeTropicEscapeConnection",this.onTropicEscapeConnectionInitialized,[m_featureName]));
      }
      
      private function onTropicEscapeConnectionInitialized(result:Object) : void
      {
         var response:Object = null;
         if(result)
         {
            if(result.hasOwnProperty("response") && Boolean(result["response"]))
            {
               response = result["response"];
               if(response["data"]["started"])
               {
                  Global.player.setSeenFlag(this.FLAG_TROPIC_CONNECTION_INITIALIZED);
               }
            }
         }
      }
      
      public function postNeighbours() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"postNeighbours",this.onPostNeighboursDone,[m_featureName]));
      }
      
      private function onPostNeighboursDone(result:Object) : void
      {
         var response:Object = null;
         if(result)
         {
            if(result.hasOwnProperty("response") && Boolean(result["response"]))
            {
               response = com.adobe.serialization.json.JSON.decode(result["response"]);
               if(response != null && response.hasOwnProperty("data") && Boolean(response["data"]["result"]))
               {
                  Global.player.setSeenFlag("PostFarmvilleNeighboursToTropicEscape");
               }
            }
         }
      }
      
      public function getTasksDoneWithoutOrderboardBoost() : int
      {
         return int(this.getFeatureOptionsKey(this.KEY_TASKS_DONE_WITHOUT_ORDERBOARD_BOOST));
      }
      
      public function resetTasksWithoutBoostCount() : void
      {
         this.saveFeatureOptionsKey(this.KEY_TASKS_DONE_WITHOUT_ORDERBOARD_BOOST,0);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"resetTasksWithoutBoostCount",null,[m_featureName]));
      }
      
      public function unlockCurrentTile() : void
      {
         this.saveFeatureOptionsKey(this.KEY_CURRENT_TILE_LEVEL,int(this.getFeatureOptionsKey(this.KEY_CURRENT_TILE_LEVEL) + 1));
         if(this.mainWindow)
         {
            this.mainWindow.refreshTERewardPane();
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"unlockCurrentTile",null,[m_featureName]));
      }
      
      public function getCurrentTileName() : String
      {
         return this.TILE_REWARDS[this.getCurrentTileLevel()];
      }
      
      public function get tileRewards() : Array
      {
         return this.TILE_REWARDS;
      }
      
      public function getCurrentTileFriendlyName() : String
      {
         return this.TILE_REWARD_NAMES[this.getCurrentTileLevel()];
      }
      
      public function highlightTiles(tileName:String) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
         UI.displayMiniMarketDialog([tileName],null,"seed",null,true,false,false,true);
      }
      
      public function highlightTile(tileName:String) : void
      {
         ItemFinderManager.getInstance().highlightWorldItems(tileName);
      }
      
      public function updateTaskBoostPopupTime() : void
      {
         Global.player.setFeatureLastShown(TROPICAL_MARKET_TASK_BOOST_CALLOUT,FarmGameUtil.getMidnightTimestamp() / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"updateTaskBoostPopupTime",null,[m_featureName]));
      }
      
      public function getTimeLeftToShowTaskBoostCallout() : Number
      {
         var timeSinceLastFeed:Number = FarmGameUtil.getMidnightTimestamp() / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(TROPICAL_MARKET_TASK_BOOST_CALLOUT);
         return this.DEFAULT_THROTTLE_TIME - timeSinceLastFeed;
      }
   }
}

