package Managers.OrderBoard
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.QuestConstants;
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.GenericPopup;
   import Display.HUD.HUDWidgets.HudBottomHalloweenInnovation2019Button;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Events.TileUnlockEvent;
   import Managers.BaseFeatureManager;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.CarribeanTileUnlockWindow;
   import Widgets.Windows.GenericSingleRewardPopup;
   import Widgets.Windows.Halloween2019InnovationBadgeRewardWindow;
   import Widgets.Windows.Halloween2019InnovationCandyConversionWindow;
   import Widgets.Windows.Halloween2019InnovationMainWindow;
   import Widgets.Windows.Halloween2019InnovationOrderboardWindow;
   import Widgets.Windows.Halloween2019InnovationRewardWindow;
   import flash.events.Event;
   
   public class Halloween2019InnovationManager extends BaseFeatureManager
   {
      
      private static const FEATURE_NAME:String = "Halloween2019Innovation";
      
      private static const KEY_SAVED_ACTIVE_TASKS:String = "saved_active_tasks";
      
      private static const SERVICE_NAME:String = "Halloween2019InnovationService";
      
      private static const KEY_CURRENT_WEEK:String = "currentweek";
      
      private static var KEY_DAILY_ORDERBOARD_TASK_COUNT:String = "orderboard_task_count";
      
      private static var INCREMENT_OB_TASK:int = 1;
      
      private static var KEY_ACTIVE_DAY_TIMESTAMP:String = "ts";
      
      private static const STATION_MAKING_TIME:int = 360;
      
      private static const EASY:Number = 0;
      
      private static const MEDIUM:Number = 1;
      
      private static const HARD:Number = 2;
      
      private static const KID_WAIT_TIME:* = 240;
      
      private static const KID_RETUEN_TIME:* = 900;
      
      public static const MILESTONE_REWARDS:Array = new Array("horse_xhf_candyprison","unicorn_xhf_pumpkinmagic","horse_xhf_witcho","pegasus_xhf_superhero","unicorn_xhf_pumpkinplant","unicorn_xhf_raggedy","pegacorn_xhf_spider");
      
      private static const KEY_MILESTONE_LEVEL:String = "milestone";
      
      private static const KEY_BADGE_LEVEL:String = "badge";
      
      public static const KEY_SAVED_FINAL_REWARD_BUILDINGNAME:String = "reward_building";
      
      public static const HUD_INITIALISATION_FLAG:String = "HalloweenInnovation2019_hud_initialise_flag";
      
      public static const HUD_INITIALISATION_FLAG_HARVEST:String = "HalloweenInnovation2019_hud_initialise_flag_harvest";
      
      public static const NUMBER_ORDERBOARD_SLOT:int = 6;
      
      public static const ZRUNTIME_HALLOWEEN2019_INNOVATION_OB_LIMIT:String = "HALLOWEEN2019_INNOVATION_OB_LIMIT";
      
      public static const KID_DATA:String = "kidData";
      
      public static const milestonePostfix:Array = ["st","nd","rd","th","th","th","th","th"];
      
      private static const BONUS_HARVEST_COUNT:String = "hc_";
      
      private static const SERVICE_FUNC_HARVEST_BONUS:String = "harvestDecos";
      
      public static const EVENT_HALLOWEEN_INNOVATION_2019_TILE_UNLOCK:String = "HalloweenInnovation2019TileUnlock";
      
      public static const DEFAULT_HARVEST_THROTTLE_TIME:int = 86400;
      
      public static const DEFAULT_COLLECT_THROTTLE_TIME:int = 86400;
      
      public var m_orderboardWindow:Halloween2019InnovationOrderboardWindow;
      
      private var m_tasksById:Object = null;
      
      private const KEY_TASK_ID:String = "id";
      
      protected const KEY_PROGRESS:String = "progress";
      
      protected const KEY_TOTAL:String = "total";
      
      private var m_resultObject:Object;
      
      protected const KEY_ID:String = "id";
      
      protected const KEY_SAVED_DUMPED_TIMESTAMP:String = "3";
      
      protected const SKIP_COST:int = 1;
      
      public const KEY_ORDERBOARD_TASK_POINTS:String = "orderboard_task_points";
      
      public const ODERBORD_TASK_DESRCIPTION:* = "oderbord_task_description";
      
      public const VAL_FINAL_MILESTONE:Number = 3000;
      
      private const KEY_ORDERBOARD_COUNT:String = "orderboard_task_count";
      
      private var m_isActive:Boolean = false;
      
      private var m_currencyName:String;
      
      private var m_endTimeStamp:Number = 0;
      
      private var m_assetPaths:Object = {};
      
      private var MAX_DAILY_ODERBOARD_TASK_COUNT:int = 15;
      
      public const KEY_BASIC_CANDIES_INVENTORY:String = "basicCandiesInventory";
      
      public const KEY_SPECIAL_CANDIES_INVENTORY:String = "specialCandiesInventory";
      
      public const FIRST_DAILY_MILESTONE:int = 4;
      
      public const SECOND_DAILY_MILESTONE:int = 8;
      
      public const THIRD_DAILY_MILESTONE:int = 11;
      
      private const REWARD_POPUP_WINDOW:String = "assets/dialogs/expansion/FV_RewardDialog.swf";
      
      private const REWARD_WINDOW_IMAGE:String = "assets/dialogs/spooky/RewardDialog.png";
      
      private const TRY_COOL_DOWN_TIME:* = "try_cool_down_time";
      
      private const DEFAULT_TRY_TIME:int = 21600;
      
      private const DAILY_TRY_COUNT:* = "daily_try_count";
      
      private const DAILY_MAX_TRY_LIMIT:int = 2;
      
      private const MAX_SPECIAL_CANDY_SLOTS_COUNT:* = 3;
      
      private const SPECIAL_CANDY_SLOTS_COUNT:String = "special_candy_slots_count";
      
      private const SPECIAL_CANDY_VISITED:* = "special_candy_visited";
      
      private const SPECIAL_CANDY_MAPPING:String = "special_candy_mapping";
      
      private const SPECIAL_CANDY_MAPPING_FLAG:String = "special_candy_mapping_flag";
      
      private const SPECIAL_CANDY_MAKING_TIMER:String = "special_candy_making_timer";
      
      private const DEFAULT_SPECIAL_CANDY_MAKING_TIMER:int = 900;
      
      private const KEY_STATIONS_DATA:String = "stations_data";
      
      private const BASE_COAT_MAPPING:* = "base_coat_mapping";
      
      private const KEY_BONUS_HARVEST_START_TIME:* = "bonus_harvest_start_time";
      
      public var m_mainWindow:Halloween2019InnovationMainWindow;
      
      private var m_candyConvesrionWindow:Halloween2019InnovationCandyConversionWindow;
      
      private var m_halloweenRewardWindow:Halloween2019InnovationRewardWindow;
      
      protected var m_staticData:Object;
      
      private var m_rewardsBySlotName:Object = null;
      
      private var m_InventionRewardPopup:GenericSingleRewardPopup;
      
      private var m_milestoneRewardPopup:GenericSingleRewardPopup;
      
      private var m_basicCandiesURL:Object = null;
      
      private var m_specialCandiesURL:Object = null;
      
      private var m_baseCoatSpecial:Object = null;
      
      private var m_specialBaseCoat:Object = null;
      
      public var m_confirmPopup:GenericPopup;
      
      private var m_kidsDetails:Object = null;
      
      private var m_kidsName:Array = [];
      
      private var m_specialKidNameMap:Object = null;
      
      private const POINTS_FOR_NORMAL_CANDY:* = 1;
      
      private const POINTS_FOR_SPECIAL_CANDY:* = 3;
      
      private const NUMBER_OF_CANDIES_REDUCTION:* = 1;
      
      private const KEY_FEATURE_POINTS:* = "feature_points";
      
      private const KEY_BONUS_REWARD_GRANTED:String = "spooky_bonus_reward_granted";
      
      private const KID1_STATE:String = "kid1";
      
      private const KID2_STATE:String = "kid2";
      
      private const KID3_STATE:String = "kid3";
      
      private const KID1_WAIT_TIME_START:String = "kid1WaitTime";
      
      private const KID2_WAIT_TIME_START:String = "kid2WaitTime";
      
      private const KID3_WAIT_TIME_START:String = "kid3WaitTime";
      
      private const KID1_RETURN_TIME_START:String = "kid1ReturnTime";
      
      private const KID2_RETURN_TIME_START:String = "kid2ReturnTime";
      
      private const KID3_RETURN_TIME_START:String = "kid3ReturnTime";
      
      private const KID1_RETURN_STATE:String = "kid1ReturnState";
      
      private const KID2_RETURN_STATE:String = "kid2ReturnState";
      
      private const KID3_RETURN_STATE:String = "kid3ReturnState";
      
      private const REWARD_SHARE_WINDOW:String = "assets/dialogs/expansion/FV_RewardDialog_Share.swf";
      
      public const VAL_MILESTONE_POINTS_ARRAY:Array = [180,540,1030,1630,2330,3130,4000,4500];
      
      public const VAL_BADGE_POINTS_ARRAY:Array = [400,2000,3500,4500,7000];
      
      public const KEY_TILE_UNLOCK_POINTS:int = 10;
      
      public const KID_CHAR_ARRAY:Array = ["mason","susan","benjamin","michael","olivia","rachel","lisa","nancy","ethan","mason","michael","lisa","susan","olivia","nancy","benjamin","rachel","ethan","michael","lisa","mason"];
      
      public const emoTransaction:Object = {
         "normal":{
            "happy":"happy",
            "sad":"happy",
            "excitement":"sad"
         },
         "special":{
            "happy":"excitement",
            "sad":"excitement",
            "excitement":"excitement"
         }
      };
      
      public const KID_EMOTION_ARRAY:Array = ["sad","happy","excitement"];
      
      public const ORDERBOARD_SLOTS_DATA:String = "orderboard_slots_data";
      
      public const HUD_HALLOWEENINNOVATION_ASSET:String = "assets/dialogs/spooky/innovation/FV_xhf_hud_Innovation.swf";
      
      private var m_HalloweenInnovationHud:HudBottomHalloweenInnovation2019Button;
      
      public var m_kidReturnFlag:int = 1;
      
      public var m_kidWaitFlag:int = 1;
      
      public var slotCandy:Object = new Object();
      
      public const LAST_HARVEST_TIME_KEY:String = "_lastHarvestTimeKey";
      
      public var BONUS_HARVEST_MAP:Object = {
         "novice":new Array("fuel1","vehiclepart","pkg_xhf_treasurepart_pack","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard"),
         "expert":new Array("consume_unwither","consume_organic_fertilizer","fuel1","vehiclepart","pkg_xhf_treasurepart_pack","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard"),
         "master":new Array("consume_instagrow","pkg_xhf_bigbuildable_pack","consume_turbo_charger","consume_unwither","consume_organic_fertilizer","fuel1","vehiclepart","pkg_xhf_treasurepart_pack","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard")
      };
      
      public var m_redeemShow:Array = [];
      
      private const TILE_UNLOCK_ASSET:String = "assets/dialogs/brazil/innovation/FV_xbr_Innovation_Prize.swf";
      
      public var activeDay:Boolean = false;
      
      private const REWARD_POPUP_WINDOW_SHARE:String = "assets/dialogs/expansion/FV_RewardDialog_Share.swf";
      
      public var DAY_COUNT:String = "day_count";
      
      public var KEY_SAVED_FIRST_REWARD_RECEIVED:String = "first_milestone";
      
      public var KEY_SAVED_SECOND_REWARD_RECEIVED:String = "second_milestone";
      
      public var KEY_SAVED_THIRD_REWARD_RECEIVED:String = "third_milestone";
      
      public var KEY_SAVED_FOURTH_REWARD_RECEIVED:String = "fourth_milestone";
      
      public var KEY_SAVED_FIFTH_REWARD_RECEIVED:String = "fifth_milestone";
      
      public var KEY_SAVED_SISTH_REWARD_RECEIVED:String = "sixth_milestone";
      
      public var KEY_SAVED_SEVEN_REWARD_RECEIVED:String = "seven_milestone";
      
      public var KEY_SAVED_FIRST_BADGE_RECEIVED:String = "first_badge";
      
      public var KEY_SAVED_SECOND_BADGE_RECEIVED:String = "second_badge";
      
      public var KEY_SAVED_THIRD_BADGE_RECEIVED:String = "third_badge";
      
      public var KEY_SAVED_FOURTH_BADGE_RECEIVED:String = "fourth_badge";
      
      public const KEY_TILE_UNLOCK_COUNT:String = "tile_unlock_count";
      
      public function Halloween2019InnovationManager(featureName:String, featureConfig:XML = null)
      {
         super(featureName,featureConfig);
         this.parseFeatureConfig();
         this.startQuest();
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
      }
      
      public static function getInstance(featureName:String = "Halloween2019Innovation") : Halloween2019InnovationManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,Halloween2019InnovationManager) as Halloween2019InnovationManager;
      }
      
      private static function get oderboardWindowURL() : String
      {
         return "assets/dialogs/spooky/innovation/FV_xhf_Innovation_Orderboard.swf ";
      }
      
      private static function get candyConversionWindowUrl() : String
      {
         return "assets/dialogs/spooky/innovation/FV_xhf_Innovation_Recipe.swf ";
      }
      
      private static function get halloween19RewardWindow() : String
      {
         return "assets/dialogs/spooky/innovation/FV_xhf_Innovation_Rewards.swf ";
      }
      
      public static function getTimeLeft(key:String, throttleTime:int = 86400) : int
      {
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         return int(throttleTime - timeSinceLastFeed);
      }
      
      protected function parseFeatureConfig() : void
      {
         var tile:XML = null;
         var asset:XML = null;
         var tileName:String = null;
         var weekxml:XML = null;
         var config:XML = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         if(config != null)
         {
            this.m_staticData = new Object();
            this.m_isActive = true;
            this.m_currencyName = config["currency"]["@name"];
            this.m_endTimeStamp = FarmGameUtil.synchronizedDateToNumber(config["listEndDate"]);
            this.m_staticData.tilesArray = [];
            if(config.hasOwnProperty("assets"))
            {
               for each(asset in config.assets.asset)
               {
                  this.m_assetPaths[asset.@name] = asset.@path.toString();
               }
            }
            this.m_staticData.startDate = config.listStartDate.toString();
            for each(tile in config.items.item)
            {
               tileName = tile.@name.toString();
               this.m_staticData.tilesArray.push(tileName);
            }
            this.m_staticData.weeks = new Array();
            if(config.weeks)
            {
               for each(weekxml in config.weeks.week)
               {
                  this.m_staticData.weeks.push(weekxml);
               }
            }
         }
      }
      
      public function resetDataAndSetNewWeek(callback:Function = null) : void
      {
         this.m_mainWindow.tintWindow();
         this.m_mainWindow.enableInput = false;
         StatsManager.count("Halloween2019Innovation","weekend",this.getTotalBasicCandies().toString(),this.getTotalSpecialCandies().toString(),this.getFeaturePoints().toString());
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"resetDataAndSetNewWeek",this.resetWeekCallback,[m_featureName]),true);
      }
      
      public function resetWeekCallback(result:Object) : void
      {
         var activeWeek:int = 0;
         if(Boolean(result) && result.hasOwnProperty("featureData"))
         {
            this.saveFeatureOptionsKey(KEY_CURRENT_WEEK,result["featureData"]["week"]);
            this.saveFeatureOptionsKey(this.KEY_FEATURE_POINTS,result["featureData"]["featurePoints"]);
            this.saveFeatureOptionsKey(KEY_MILESTONE_LEVEL,result["featureData"]["milestoneLevel"]);
            this.saveFeatureOptionsKey(this.KEY_STATIONS_DATA,result["featureData"]["stationData"]);
            this.saveFeatureOptionsKey(KEY_DAILY_ORDERBOARD_TASK_COUNT,result["featureData"]["oderbordTaskCount"]);
            this.saveFeatureOptionsKey(this.KEY_ORDERBOARD_TASK_POINTS,result["featureData"]["oderbordTaskPoint"]);
            this.saveFeatureOptionsKey(this.KEY_BASIC_CANDIES_INVENTORY,result["featureData"]["basicCandyIventory"]);
            this.saveFeatureOptionsKey(this.KEY_SPECIAL_CANDIES_INVENTORY,result["featureData"]["specialCandyIventory"]);
            this.saveFeatureOptionsKey(this.TRY_COOL_DOWN_TIME,result["featureData"]["tryCoolTime"]);
            this.saveFeatureOptionsKey(this.DAILY_TRY_COUNT,result["featureData"]["dailyTryTime"]);
            this.saveFeatureOptionsKey(this.SPECIAL_CANDY_SLOTS_COUNT,result["featureData"]["specialCandySlotCount"]);
            this.saveFeatureOptionsKey(this.SPECIAL_CANDY_MAPPING,result["featureData"]["specialCandyMapping"]);
            this.saveFeatureOptionsKey(this.SPECIAL_CANDY_MAPPING_FLAG,result["featureData"]["specialCandyMappingFlag"]);
            this.saveFeatureOptionsKey(this.SPECIAL_CANDY_MAKING_TIMER,result["featureData"]["specialCandyMappingTimer"]);
            this.saveFeatureOptionsKey(this.SPECIAL_CANDY_VISITED,result["featureData"]["specialCandyVisited"]);
            this.saveFeatureOptionsKey(this.BASE_COAT_MAPPING,result["featureData"]["baseCoatMapping"]);
            this.saveFeatureOptionsKey(this.KID1_WAIT_TIME_START,result["featureData"]["kid1WaingTime"]);
            this.saveFeatureOptionsKey(this.KID2_WAIT_TIME_START,result["featureData"]["kid2WaingTime"]);
            this.saveFeatureOptionsKey(this.KID3_WAIT_TIME_START,result["featureData"]["kid3WaingTime"]);
            this.saveFeatureOptionsKey(this.KID1_RETURN_TIME_START,result["featureData"]["kid1ReturnTime"]);
            this.saveFeatureOptionsKey(this.KID2_RETURN_TIME_START,result["featureData"]["kid2ReturnTime"]);
            this.saveFeatureOptionsKey(this.KID3_RETURN_TIME_START,result["featureData"]["kid3ReturnTime"]);
            this.saveFeatureOptionsKey(this.KID1_RETURN_STATE,result["featureData"]["kid1ReturnState"]);
            this.saveFeatureOptionsKey(this.KID2_RETURN_STATE,result["featureData"]["kid2ReturnState"]);
            this.saveFeatureOptionsKey(this.KID3_RETURN_STATE,result["featureData"]["kid3ReturnState"]);
            this.saveFeatureOptionsKey(KEY_ACTIVE_DAY_TIMESTAMP,result["featureData"]["keyTimeStamp"]);
            this.saveFeatureOptionsKey(this.ORDERBOARD_SLOTS_DATA,result["featureData"]["oderbordSlotData"]);
            this.saveFeatureOptionsKey(KID_DATA,result["featureData"]["kidData"]);
            this.saveFeatureOptionsKey(this.DAY_COUNT,result["featureData"]["dayCount"]);
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,result["featureData"]["activeTasks"]);
            this.grantMilestoneReward();
            activeWeek = this.getFeatureOptionsKey(KEY_CURRENT_WEEK) as int;
            this.parseCandiesByWeek(activeWeek);
            this.parseKidsConfigByWeek(activeWeek);
         }
         if(this.m_mainWindow)
         {
            this.refreshBasicCandyFrame();
            this.refreshKidFrame();
            this.refreshSpecialCandyFrame();
            this.m_mainWindow.hideWeekOverlay();
            this.m_mainWindow.updateMainWindow();
            this.m_mainWindow.refreshDaySlot();
         }
         this.m_mainWindow.untintWindow();
         this.m_mainWindow.enableInput = true;
         StatsManager.count("Halloween2019Innovation","weekstart",this.getTotalBasicCandies().toString(),this.getTotalSpecialCandies().toString(),this.getFeaturePoints().toString());
      }
      
      public function showMainUI() : void
      {
         var activeWeek:int = 0;
         this.startQuest();
         if(this.isFeatureEnd() || this.getFeaturePoints() >= 4500)
         {
            if(this.orderboardWindow)
            {
               this.orderboardWindow.close();
            }
            if(this.rewardWindow)
            {
               this.rewardWindow.close();
            }
         }
         else
         {
            activeWeek = this.getFeatureOptionsKey(KEY_CURRENT_WEEK) as int;
            this.parseCandiesByWeek(activeWeek);
            this.parseKidsConfigByWeek(activeWeek);
            if(!this.hasActiveWeekExpired())
            {
               this.checkRedeemTask();
            }
         }
         this.m_mainWindow = new Halloween2019InnovationMainWindow(m_featureName,this.mainWindowURL);
         UI.displayPopup(this.m_mainWindow);
         FarmStatsManager.count("Halloween2019Innovation","mainui","open","daily");
      }
      
      public function initEventListener() : void
      {
         GlobalEventManager.getInstance().addEventListener(EVENT_HALLOWEEN_INNOVATION_2019_TILE_UNLOCK,this.showGrantPopup);
      }
      
      public function deleteEventListener() : void
      {
         GlobalEventManager.getInstance().removeEventListener(EVENT_HALLOWEEN_INNOVATION_2019_TILE_UNLOCK,this.showGrantPopup);
      }
      
      public function showGrantPopup(e:TileUnlockEvent = null) : void
      {
         var points:int = 0;
         if(!this.isFeatureEnd())
         {
            if(!this.isFeaturePointsReached())
            {
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"addInventoryTileUnlockCount",this.onComplete,new Array(FEATURE_NAME)),true);
               UI.displayPopup(new CarribeanTileUnlockWindow(this.REWARD_POPUP_WINDOW,m_featureName,e.tileData.getItemName()),false);
               points = this.getFeatureOptionsKey(this.KEY_FEATURE_POINTS) as int;
               this.saveFeatureOptionsKey(this.KEY_FEATURE_POINTS,points + 10);
               this.grantMilestoneReward();
            }
         }
      }
      
      public function onComplete(result:Object) : void
      {
      }
      
      public function isFeaturePointsReached() : Boolean
      {
         var points:int = this.getFeaturePoints();
         if(points >= 4500)
         {
            return true;
         }
         return false;
      }
      
      public function showFeatureEndPopUp() : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         var points:int = this.getFeaturePoints();
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("11/25/2019") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         timeLeft = endTime - now;
         if(timeLeft <= 0 || points >= 4500)
         {
            result = true;
         }
         return result;
      }
      
      public function isFeatureEnd() : Boolean
      {
         var result:Boolean = true;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("HalloweenInnovation2019_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            result = false;
         }
         return result;
      }
      
      public function featureEnd() : void
      {
         if(this.getFeatureOptionsKey(this.KEY_BONUS_REWARD_GRANTED) == 0)
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"featureEnd",this.onFeatureComplete,new Array(FEATURE_NAME)),true);
         }
      }
      
      public function onFeatureComplete(result:Object) : void
      {
         var finalDeco:int = 0;
         Global.player.setSeenFlag(Halloween2019InnovationManager.HUD_INITIALISATION_FLAG_HARVEST,true);
         if(result)
         {
            finalDeco = 0;
            if(!result.hasOwnProperty("none"))
            {
               if(result.hasOwnProperty("badge"))
               {
                  Global.player.addGift(result["badge"]);
                  finalDeco = 1;
               }
               else
               {
                  Global.player.addGift(result["badge1"]);
                  Global.player.addGift(result["badge2"]);
                  Global.player.addGift(result["badge3"]);
                  finalDeco = 2;
               }
            }
            if(finalDeco == 1)
            {
               this.showInventionRewardPopup(result["badge"]);
               StatsManager.count("Halloween19Innovation","reward","bonus",result["badge"].toString(),this.getFeaturePoints().toString());
            }
            else if(finalDeco == 2)
            {
               this.showInventionRewardPopup("xhf_threebuilding");
               StatsManager.count("Halloween19Innovation","reward","bonus","xhf_threebuilding",this.getFeaturePoints().toString());
            }
            if(result.hasOwnProperty("BONUS_GRANTED"))
            {
               this.saveFeatureOptionsKey(this.KEY_BONUS_REWARD_GRANTED,result["BONUS_GRANTED"]);
            }
            if(result.hasOwnProperty("initial_harvest_time"))
            {
               this.saveFeatureOptionsKey(this.KEY_BONUS_HARVEST_START_TIME,result["initial_harvest_time"]);
            }
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
      
      public function showInventionRewardPopup(rewardName:String) : void
      {
         var featureKey:String = m_featureName + "_inventionReward";
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
         this.m_InventionRewardPopup = new GenericSingleRewardPopup(this.REWARD_POPUP_WINDOW_SHARE,featureKey,rewardItem,this.postInventionShare(rewardItem),this.REWARD_WINDOW_IMAGE);
         UI.displayPopup(this.m_InventionRewardPopup,false);
      }
      
      public function postInventionShare(rewardItem:FarmItem) : Function
      {
         return function(event:Event):void
         {
            var windowName:* = "Halloween2019Innovation";
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
            if(m_InventionRewardPopup)
            {
               m_InventionRewardPopup.close();
            }
         };
      }
      
      public function canHarvestBonusRewardBuilding() : Boolean
      {
         var isStillHarvestable:Boolean = false;
         var bonusStartTime:* = this.getFeatureOptionsKey(this.KEY_BONUS_HARVEST_START_TIME) as int;
         if(bonusStartTime)
         {
            if(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - bonusStartTime < 14 * 86400)
            {
               isStillHarvestable = true;
            }
         }
         return isStillHarvestable;
      }
      
      public function shouldShowBonusHarvestTimer() : Boolean
      {
         var isStillHarvestable:Boolean = false;
         var bonusStartTime:* = this.getFeatureOptionsKey(this.KEY_BONUS_HARVEST_START_TIME) as int;
         if(bonusStartTime)
         {
            if(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - bonusStartTime < 13 * 86400)
            {
               isStillHarvestable = true;
            }
         }
         return isStillHarvestable;
      }
      
      public function checkRedeemTask() : void
      {
         var completedTask:Boolean = false;
         var questTasks1:Vector.<FarmTask> = null;
         var progress:int = 0;
         questTasks1 = this.getTasks();
         for(var i:int = 0; i < questTasks1.length; i++)
         {
            progress = this.getTaskProgress(i);
            completedTask = progress >= questTasks1[i].total;
            if(completedTask && !this.isSlotInReedemState(i) && !this.isSlotInLimitReachedState(i) && !this.isDailyTaskCountReached())
            {
               this.setOrderboardSlot(i,1);
               this.m_redeemShow.push(questTasks1[i].questPoints);
               this.setTaskPoints(questTasks1[i].questPoints,i);
               this.grandBasicCandies(questTasks1[i].questPoints);
               this.grantRedeemPoints(questTasks1[i].questPoints,i);
            }
         }
      }
      
      public function grantRedeemPoints(taskPoint:int, slotIndex:int, callback:Function = null) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"grantRedeemPoints",ZCacheUtil.applyPartial(this.onGrantRedeemPoints,this,[callback]),[m_featureName,taskPoint,slotIndex]),true);
      }
      
      public function onGrantRedeemPoints(callback:Function, result:Object) : void
      {
         if(result)
         {
            if(result.hasOwnProperty("orderbordTaskPoints"))
            {
               this.saveFeatureOptionsKey(this.KEY_ORDERBOARD_TASK_POINTS,result["orderbordTaskPoints"]);
            }
            if(result.hasOwnProperty("orderbordCount"))
            {
               this.saveFeatureOptionsKey(KEY_DAILY_ORDERBOARD_TASK_COUNT,result["orderbordCount"]);
            }
            if(result.hasOwnProperty("basicCandyCount"))
            {
               this.saveFeatureOptionsKey(this.KEY_BASIC_CANDIES_INVENTORY,result["basicCandyCount"]);
            }
            if(result.hasOwnProperty("orderboardSlotData"))
            {
               this.saveFeatureOptionsKey(this.ORDERBOARD_SLOTS_DATA,result["orderboardSlotData"]);
            }
            if(Boolean(result) && result.hasOwnProperty("oderbordTask"))
            {
               this.saveFeatureOptionsKey(this.ODERBORD_TASK_DESRCIPTION,result["oderbordTask"]);
            }
            if(this.m_mainWindow)
            {
               this.m_mainWindow.refreshOrderboardCount();
               if(this.m_mainWindow.m_normalCandyFrame)
               {
                  this.refreshBasicCandyFrame();
               }
            }
            if(this.m_orderboardWindow)
            {
               this.m_orderboardWindow.refreshTaskAndCandyCounts();
               this.m_orderboardWindow.updateProgressBar();
               this.m_orderboardWindow.updatePointerPosition();
               if(Boolean(callback))
               {
                  callback.call();
               }
            }
            this.grantDailyReward();
         }
      }
      
      public function npcCalloutRedeem() : void
      {
         var i:int = 0;
         if(this.m_redeemShow)
         {
            for(i = 0; i < this.m_redeemShow.length; i++)
            {
               if(Boolean(this.m_mainWindow) && Boolean(this.m_mainWindow.m_npcCalloutMc))
               {
                  this.m_mainWindow.m_npcTitleTf.text = "Summary";
                  this.m_mainWindow.m_npcTextTf.text = "You got " + this.m_redeemShow[i].toString() + " candies by finishing task on you farm.";
                  this.m_redeemShow.splice(i,1);
                  this.m_mainWindow.m_npcCalloutMc.visible = true;
               }
            }
         }
      }
      
      public function get mainWindowURL() : String
      {
         return "assets/dialogs/spooky/innovation/FV_xhf_Innovation.swf";
      }
      
      public function openOrderBoardWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         this.m_orderboardWindow = new Halloween2019InnovationOrderboardWindow(oderboardWindowURL);
         UI.displayPopup(this.m_orderboardWindow,false);
      }
      
      public function openCandyConversionWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         this.m_candyConvesrionWindow = new Halloween2019InnovationCandyConversionWindow(FEATURE_NAME,candyConversionWindowUrl);
         UI.displayPopup(this.m_candyConvesrionWindow,false);
      }
      
      public function openHalloween2019RewardWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         this.m_halloweenRewardWindow = new Halloween2019InnovationRewardWindow(FEATURE_NAME,halloween19RewardWindow);
         UI.displayPopup(this.m_halloweenRewardWindow,false);
      }
      
      override public function get featureName() : String
      {
         return FEATURE_NAME;
      }
      
      protected function getFeatureOptionsKey(optionName:String) : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,optionName);
      }
      
      protected function saveFeatureOptionsKey(optionName:String, optionsValue:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,optionName,optionsValue);
      }
      
      public function get orderboardWindow() : Halloween2019InnovationOrderboardWindow
      {
         return this.m_orderboardWindow;
      }
      
      public function get mainWindow() : Halloween2019InnovationMainWindow
      {
         return this.m_mainWindow;
      }
      
      public function get rewardWindow() : Halloween2019InnovationRewardWindow
      {
         return this.m_halloweenRewardWindow;
      }
      
      public function startQuest(callback:Function = null) : void
      {
         var savedTaskInfo:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         if(!(savedTaskInfo && savedTaskInfo.length))
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startQuest",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName)),true);
         }
      }
      
      private function onInitQuestComplete(callback:Function, result:Object) : void
      {
         var activeWeek:int = 0;
         this.m_resultObject = result;
         if(Boolean(result) && result.hasOwnProperty("featureData"))
         {
            FeatureOptionsManager.getInstance().setFeature(m_featureName,result["featureData"]);
            if(Boolean(callback))
            {
               callback.call();
            }
            activeWeek = this.getFeatureOptionsKey(KEY_CURRENT_WEEK) as int;
            this.parseCandiesByWeek(activeWeek);
            this.parseKidsConfigByWeek(activeWeek);
         }
         if(Boolean(result) && result.hasOwnProperty("oderbordSlotData"))
         {
            this.saveFeatureOptionsKey(this.ORDERBOARD_SLOTS_DATA,result["oderbordSlotData"]);
         }
         if(Boolean(result) && result.hasOwnProperty("orderbordTaskPoints"))
         {
            this.saveFeatureOptionsKey(this.KEY_ORDERBOARD_TASK_POINTS,result["orderbordTaskPoints"]);
         }
         if(Boolean(result) && result.hasOwnProperty("oderbordTask"))
         {
            this.saveFeatureOptionsKey(this.ODERBORD_TASK_DESRCIPTION,result["oderbordTask"]);
         }
         if(Boolean(result) && result.hasOwnProperty("orderbordCount"))
         {
            this.saveFeatureOptionsKey(KEY_DAILY_ORDERBOARD_TASK_COUNT,result["orderbordCount"]);
            if(this.m_orderboardWindow)
            {
               this.refreshDailyTaskCounts();
            }
            this.grantDailyReward();
         }
         if(Boolean(result) && result.hasOwnProperty("basicCandyCount"))
         {
            this.saveFeatureOptionsKey(this.KEY_BASIC_CANDIES_INVENTORY,result["basicCandyCount"]);
         }
         if(Boolean(result) && result.hasOwnProperty("activeTasks"))
         {
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,result["activeTasks"]);
         }
         if(Boolean(callback))
         {
            callback.call();
         }
         if(this.orderboardWindow)
         {
            this.orderboardWindow.refreshWindow();
         }
      }
      
      public function getOrderboardProgress() : Number
      {
         return this.getFeatureOptionsKey(this.KEY_ORDERBOARD_TASK_POINTS) as int;
      }
      
      public function getDailyOderboardTaskCount() : int
      {
         return this.getFeatureOptionsKey(KEY_DAILY_ORDERBOARD_TASK_COUNT) as int;
      }
      
      public function getMaxDailyOderboardCount() : int
      {
         var result:int = this.MAX_DAILY_ODERBOARD_TASK_COUNT;
         if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_HALLOWEEN2019_INNOVATION_OB_LIMIT))
         {
            result = int(Global.flashHotParams[ZRUNTIME_HALLOWEEN2019_INNOVATION_OB_LIMIT]);
         }
         return result;
      }
      
      public function getFirstDailyMilestone() : int
      {
         return Math.round(1 / 3 * this.getMaxDailyOderboardCount());
      }
      
      public function getSecondDailyMilestone() : int
      {
         return Math.round(2 / 3 * this.getMaxDailyOderboardCount());
      }
      
      public function getThirdDailyMilestone() : int
      {
         return this.getMaxDailyOderboardCount();
      }
      
      public function isDailyTaskCountReached() : Boolean
      {
         return this.getDailyOderboardTaskCount() >= this.getMaxDailyOderboardCount();
      }
      
      public function isSlotInReedemState(slotIndex:int) : Boolean
      {
         var redeemSlotData:Array = this.getFeatureOptionsKey(this.ORDERBOARD_SLOTS_DATA) as Array;
         return redeemSlotData[slotIndex] == 1;
      }
      
      public function isSlotInLimitReachedState(slotIndex:int) : Boolean
      {
         var redeemSlotData:Array = this.getFeatureOptionsKey(this.ORDERBOARD_SLOTS_DATA) as Array;
         return redeemSlotData[slotIndex] == 2;
      }
      
      public function incrementOderboardTaskCount() : void
      {
         var dailyOBTaskCount:int = this.getDailyOderboardTaskCount();
         this.saveFeatureOptionsKey(KEY_DAILY_ORDERBOARD_TASK_COUNT,dailyOBTaskCount + INCREMENT_OB_TASK);
         if(this.m_orderboardWindow)
         {
            this.m_orderboardWindow.updateProgressBar();
            this.m_orderboardWindow.updatePointerPosition();
         }
      }
      
      public function incrementCandyCount(candyCount:int) : void
      {
         var dailyCandyCount:int = this.getOrderboardProgress();
         this.saveFeatureOptionsKey(this.KEY_ORDERBOARD_TASK_POINTS,dailyCandyCount + candyCount);
      }
      
      public function refreshDailyTaskCounts() : void
      {
         if(this.m_orderboardWindow)
         {
            this.m_orderboardWindow.refreshTaskAndCandyCounts();
            this.m_orderboardWindow.updateProgressBar();
            this.m_orderboardWindow.updatePointerPosition();
         }
      }
      
      public function refreshBasicCandyFrame() : void
      {
         if(Boolean(this.m_mainWindow) && Boolean(this.m_mainWindow.m_normalCandyFrame))
         {
            this.m_mainWindow.m_normalCandyFrame.refresh();
            this.m_mainWindow.refreshOrderboardCount();
         }
      }
      
      public function refreshSpecialCandyFrame() : void
      {
         if(Boolean(this.m_mainWindow) && Boolean(this.m_mainWindow.m_specialCandyFrame))
         {
            this.m_mainWindow.m_specialCandyFrame.refresh();
         }
      }
      
      public function refreshSpecialCandySlot(slotId:int) : void
      {
         this.m_mainWindow.m_specialCandyFrame.refreshSlot(slotId);
      }
      
      public function refreshKidFrame() : void
      {
         if(Boolean(this.m_mainWindow) && Boolean(this.m_mainWindow.m_candyKidFrame))
         {
            this.m_mainWindow.m_candyKidFrame.refresh();
         }
      }
      
      public function refreshKidSlot(slotIndex:int) : void
      {
         if(Boolean(this.m_mainWindow) && Boolean(this.m_mainWindow.m_candyKidFrame))
         {
            this.m_mainWindow.m_candyKidFrame.refreshSlot(slotIndex);
         }
      }
      
      public function refreshDays() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.refreshDaySlot();
         }
      }
      
      public function hasActiveDayExpired() : Boolean
      {
         var expired:Boolean = false;
         var activeTime:int = this.getFeatureOptionsKey(KEY_ACTIVE_DAY_TIMESTAMP) as int;
         var currenttime:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(currenttime - activeTime > 86400)
         {
            expired = true;
         }
         return expired;
      }
      
      public function getActiveDayTimeRemain() : int
      {
         var activeTime:int = this.getFeatureOptionsKey(KEY_ACTIVE_DAY_TIMESTAMP) as int;
         var currenttime:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return 86400 - (currenttime - activeTime);
      }
      
      public function getWeeksArray() : Array
      {
         return this.m_staticData.weeks;
      }
      
      public function hasFeatureExpired() : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         endTime = this.m_endTimeStamp;
         timeLeft = (endTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(timeLeft < 0)
         {
            result = true;
         }
         return result;
      }
      
      public function hasActiveWeekExpired() : Boolean
      {
         var expired:Boolean = false;
         var activeWeek:int = this.getFeatureOptionsKey(KEY_CURRENT_WEEK) as int;
         var weekData:Object = this.getCurrentWeek();
         var curWeek:int = int(weekData.count);
         if(activeWeek != curWeek)
         {
            expired = true;
         }
         return expired;
      }
      
      public function getWeekNumber() : int
      {
         return this.getFeatureOptionsKey(KEY_CURRENT_WEEK) as int;
      }
      
      public function getCurrentWeek() : Object
      {
         var startDate:Number = NaN;
         var endDate:Number = NaN;
         var weekXML:XML = null;
         if(this.hasFeatureExpired())
         {
            return {
               "count":8,
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
            if(FarmGameUtil.checkDateGate(weekXML.@start.toString(),weekXML.@end.toString()))
            {
               result = new Object();
               result.name = weekXML.@name.toString();
               result.start = weekXML.@start.toString();
               result.end = weekXML.@end.toString();
               result.count = weekCount;
               break;
            }
            weekCount++;
         }
         return result;
      }
      
      public function getDatCount() : int
      {
         return this.getFeatureOptionsKey(this.DAY_COUNT) as int;
      }
      
      public function get featureStartDate() : String
      {
         return this.m_staticData.startDate;
      }
      
      public function startNewDay() : void
      {
         this.m_mainWindow.tintWindow();
         this.m_mainWindow.enableInput = false;
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startNewDay",this.onStartNewDay,[m_featureName]),true);
      }
      
      public function onStartNewDay(result:Object) : void
      {
         if(Boolean(result) && result["data"] == true)
         {
            this.resetDay(result["day"]);
         }
         this.m_mainWindow.untintWindow();
         this.m_mainWindow.enableInput = true;
      }
      
      public function resetDay(result:Object) : void
      {
         this.saveFeatureOptionsKey(KEY_DAILY_ORDERBOARD_TASK_COUNT,0);
         this.saveFeatureOptionsKey(KEY_ACTIVE_DAY_TIMESTAMP,result["dayTimeStamp"]);
         this.saveFeatureOptionsKey(this.ORDERBOARD_SLOTS_DATA,result["orderboardData"]);
         this.saveFeatureOptionsKey(this.KEY_FEATURE_POINTS,result["featurePoints"]);
         this.saveFeatureOptionsKey(this.DAY_COUNT,result["dayCount"]);
         this.saveFeatureOptionsKey(this.KEY_BASIC_CANDIES_INVENTORY,result["candies_Inventory"]);
         if(this.m_mainWindow)
         {
            this.refreshBasicCandyFrame();
            this.refreshKidFrame();
            this.refreshSpecialCandyFrame();
            this.refreshDays();
            this.m_mainWindow.updateMainWindow();
            this.m_mainWindow.hideDayOverlay();
         }
      }
      
      public function grandBasicCandies(candyCount:int) : void
      {
         var candyName:String = null;
         var basicCandies:Object = this.getFeatureOptionsKey(this.KEY_BASIC_CANDIES_INVENTORY);
         for(candyName in basicCandies)
         {
            basicCandies[candyName] += candyCount;
         }
         this.saveFeatureOptionsKey(this.KEY_BASIC_CANDIES_INVENTORY,basicCandies);
      }
      
      public function decreaseNormalCandyCount(candyName:String, candyCount:int) : void
      {
         var basicCandies:Object = this.getFeatureOptionsKey(this.KEY_BASIC_CANDIES_INVENTORY);
         basicCandies[candyName] -= candyCount;
         this.saveFeatureOptionsKey(this.KEY_BASIC_CANDIES_INVENTORY,basicCandies);
      }
      
      public function decreaseSpecialCandyCount(candyName:String, candyCount:int) : void
      {
         var basicCandies:Object = this.getFeatureOptionsKey(this.KEY_SPECIAL_CANDIES_INVENTORY);
         basicCandies[candyName] -= candyCount;
         this.saveFeatureOptionsKey(this.KEY_SPECIAL_CANDIES_INVENTORY,basicCandies);
      }
      
      public function getFeaturePoints() : int
      {
         return this.getFeatureOptionsKey(this.KEY_FEATURE_POINTS) as int;
      }
      
      public function getBadgeLevel() : int
      {
         return this.getFeatureOptionsKey(KEY_BADGE_LEVEL) as int;
      }
      
      public function getMilestoneLevel() : int
      {
         return this.getFeatureOptionsKey(KEY_MILESTONE_LEVEL) as int;
      }
      
      public function getMilestonePostfix(level:int) : String
      {
         return milestonePostfix[level];
      }
      
      public function getBasicCandiesNames() : Array
      {
         var key:String = null;
         var result:Array = [];
         var basicCandies:Object = this.getFeatureOptionsKey(this.KEY_BASIC_CANDIES_INVENTORY);
         for(key in basicCandies)
         {
            result.push(key);
         }
         return result.sort();
      }
      
      public function getSpecialCandiesNames() : Array
      {
         var key:String = null;
         var result:Array = [];
         var specialCandyNames:Object = this.getFeatureOptionsKey(this.KEY_SPECIAL_CANDIES_INVENTORY);
         for(key in specialCandyNames)
         {
            result.push(key);
         }
         return result.sort();
      }
      
      public function getBasicCandiesNameCount() : Object
      {
         return this.getFeatureOptionsKey(this.KEY_BASIC_CANDIES_INVENTORY);
      }
      
      public function getBaseCoatCombination() : Array
      {
         var j:int = 0;
         var combination:Array = [];
         var candies:Array = this.getBasicCandiesNames();
         for(var i:int = 0; i < candies.length; i++)
         {
            for(j = 0; j < candies.length; j++)
            {
               if(i != j)
               {
                  combination.push([candies[i],candies[j]]);
               }
            }
         }
         return combination.sort();
      }
      
      public function getBasicCandiesCounts() : Array
      {
         var key:String = null;
         var result:Array = [];
         var basicCandies:Object = this.getFeatureOptionsKey(this.KEY_BASIC_CANDIES_INVENTORY);
         for(key in basicCandies)
         {
            result.push(basicCandies[key]);
         }
         return result;
      }
      
      public function getBasicCandyCountByName(candyName:String) : int
      {
         var basicCandies:Object = this.getFeatureOptionsKey(this.KEY_BASIC_CANDIES_INVENTORY);
         return basicCandies != null ? int(basicCandies[candyName]) : 0;
      }
      
      public function getSpecialCandyCountByName(candyName:String) : int
      {
         var specialCandies:Object = this.getFeatureOptionsKey(this.KEY_SPECIAL_CANDIES_INVENTORY);
         return specialCandies != null ? int(specialCandies[candyName]) : 0;
      }
      
      public function getSpecialCandiesCounts() : Array
      {
         var key:String = null;
         var result:Array = [];
         var specialCandies:Object = this.getFeatureOptionsKey(this.KEY_SPECIAL_CANDIES_INVENTORY);
         for(key in specialCandies)
         {
            result.push(specialCandies[key]);
         }
         return result;
      }
      
      public function isDailyMilestoneReached() : Boolean
      {
         var totalTask:int = this.getDailyOderboardTaskCount();
         return totalTask == this.getFirstDailyMilestone() || totalTask == this.getSecondDailyMilestone() || totalTask == this.getThirdDailyMilestone();
      }
      
      public function grandDailyMilestoneRewardUtil() : void
      {
         var totalTask:int = this.getFeatureOptionsKey(KEY_DAILY_ORDERBOARD_TASK_COUNT) as int;
         if(totalTask == this.getFirstDailyMilestone())
         {
            this.grandDailyMilestoneReward(0);
            if(this.m_orderboardWindow)
            {
               this.m_orderboardWindow.setCheckmar(0);
            }
         }
         else if(totalTask == this.getSecondDailyMilestone())
         {
            this.grandDailyMilestoneReward(1);
            if(this.m_orderboardWindow)
            {
               this.m_orderboardWindow.setCheckmar(1);
            }
         }
         else if(totalTask == this.getThirdDailyMilestone())
         {
            this.grandDailyMilestoneReward(2);
            if(this.m_orderboardWindow)
            {
               this.m_orderboardWindow.setCheckmar(2);
            }
         }
      }
      
      public function grandDailyMilestoneReward(rewardLevel:int) : void
      {
         var rewardName:String = null;
         var rewardCode:String = (this.getRewardsForTheDay()[rewardLevel] as Object).value;
         if(rewardCode)
         {
            rewardName = Global.farmGameSettingsManager.getFarmItemNameByCode(rewardCode);
            Global.player.addGift(rewardName);
            this.showDailyMilestoneRewardPopup(rewardCode);
            StatsManager.count(m_featureName,"Milestone",rewardLevel.toString(),rewardName,"daily",this.getFeaturePoints().toString(),this.getOrderboardProgress());
         }
      }
      
      public function getRewardsForTheDay() : Vector.<Object>
      {
         var rewardXML:XML = null;
         var rewardObj:Object = null;
         var rewards:Vector.<Object> = new Vector.<Object>();
         if(this.m_rewardsBySlotName == null)
         {
            this.parseRewardsDataFromConfig(FEATURE_NAME);
         }
         var currentDay:int = this.getactiveDayIndex();
         var rewardXMLList:XMLList = this.m_rewardsBySlotName[currentDay].reward;
         for each(rewardXML in rewardXMLList)
         {
            rewardObj = FarmGameUtil.xmlNodeToAttributes(rewardXML);
            if(rewards)
            {
               rewards.push(rewardObj);
            }
         }
         return rewards;
      }
      
      public function getDailyRewardItem(rewardLevel:int) : FarmItem
      {
         var rewardCode:String = (this.getRewardsForTheDay()[rewardLevel] as Object).value;
         var farmItem:FarmItem = null;
         if(rewardCode)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(rewardCode);
         }
         if(!farmItem)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(rewardCode);
         }
         return farmItem;
      }
      
      public function getactiveDayIndex() : int
      {
         var dayIndex:int = 0;
         var activeDayTS:Number = this.getFeatureOptionsKey(KEY_ACTIVE_DAY_TIMESTAMP) as Number;
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber(this.featureStartDate) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         dayIndex = (activeDayTS - featureStartDayTS) / FarmGameUtil.NUM_SECS_IN_DAY;
         if(dayIndex < 0)
         {
            dayIndex = 0;
         }
         return dayIndex;
      }
      
      public function parseCandiesByWeek(week:int) : void
      {
         var candies:XML = null;
         var candiesList:XMLList = null;
         var candiesUrlsByWeekXML:XML = null;
         var URLSXMLListByWeek:XMLList = null;
         var candiesUrlsByWeek:XML = null;
         this.m_basicCandiesURL = {};
         this.m_specialCandiesURL = {};
         this.m_baseCoatSpecial = {};
         this.m_specialBaseCoat = {};
         candies = Global.farmGameSettingsManager.getXML().Halloween2019InnovationConfig.(@name == FEATURE_NAME).Halloween2019InnovationWeeklyCandyConfig[0];
         candiesList = candies.week;
         candiesUrlsByWeekXML = candiesList[week];
         URLSXMLListByWeek = candiesUrlsByWeekXML.basicCandiesName.candy;
         for each(candiesUrlsByWeek in URLSXMLListByWeek)
         {
            this.m_basicCandiesURL[candiesUrlsByWeek.@name.toString()] = candiesUrlsByWeek.@candyUrl.toString();
         }
         URLSXMLListByWeek = candiesUrlsByWeekXML.specialCandiesName.candy;
         for each(candiesUrlsByWeek in URLSXMLListByWeek)
         {
            this.m_specialCandiesURL[candiesUrlsByWeek.@name.toString()] = candiesUrlsByWeek.@candyUrl.toString();
         }
         URLSXMLListByWeek = candiesUrlsByWeekXML.makeSpecialCandies.specialCandy;
         for each(candiesUrlsByWeek in URLSXMLListByWeek)
         {
            this.m_baseCoatSpecial[candiesUrlsByWeek.@base.toString() + "_" + candiesUrlsByWeek.@coat.toString()] = candiesUrlsByWeek.@special.toString();
            this.m_specialBaseCoat[candiesUrlsByWeek.@special.toString()] = candiesUrlsByWeek.@base.toString() + "_" + candiesUrlsByWeek.@coat.toString();
         }
      }
      
      public function parseKidsConfigByWeek(week:int) : void
      {
         var kids:XML = null;
         var kidsList:XMLList = null;
         var candiesDetails:XML = null;
         var URLSXMLListByWeek:XMLList = null;
         var kidsByWeek:XML = null;
         var index:int = 0;
         this.m_kidsDetails = {};
         this.m_specialKidNameMap = {};
         kids = Global.farmGameSettingsManager.getXML().Halloween2019InnovationKidConfig.(@name == FEATURE_NAME).Halloween2019InnovationWeeklyKidConfig[0];
         kidsList = kids.week;
         candiesDetails = kidsList[week];
         URLSXMLListByWeek = candiesDetails.kid;
         index = 0;
         for each(kidsByWeek in URLSXMLListByWeek)
         {
            var _loc5_:Number;
            this.m_kidsName[_loc5_ = index++] = kidsByWeek.@name.toString();
            this.m_kidsDetails[kidsByWeek.@name.toString()] = [kidsByWeek.@candy1.toString(),kidsByWeek.@candy2.toString(),kidsByWeek.@specialcandy.toString()];
            this.m_specialKidNameMap[kidsByWeek.@specialcandy.toString()] = kidsByWeek.@name.toString();
         }
      }
      
      public function getKidsDetailsByWeek() : Object
      {
         return this.m_kidsDetails;
      }
      
      public function getKidsName() : Array
      {
         return this.m_kidsName;
      }
      
      public function getKidsNameBySpecialCandy(specialCandy:String) : String
      {
         return this.m_specialKidNameMap[specialCandy];
      }
      
      public function getBasicCandyNameURLS() : Object
      {
         return this.m_basicCandiesURL;
      }
      
      public function getBasicCandyURLByName(name:String) : String
      {
         return this.m_basicCandiesURL[name];
      }
      
      public function getSpecialCandyNameURLS() : Object
      {
         return this.m_specialCandiesURL;
      }
      
      public function getSpecialCandyURLByName(name:String) : String
      {
         return this.m_specialCandiesURL[name];
      }
      
      public function getBaseCoatSpecialConfig() : Object
      {
         return this.m_baseCoatSpecial;
      }
      
      public function getBaseCoatCandyBySpecialCandyName(specialCandyName:String) : Array
      {
         var baseCoat:String = this.m_specialBaseCoat[specialCandyName];
         return baseCoat.split("_");
      }
      
      public function getSpecialCandyByBaseCoat(base:String, coat:String) : String
      {
         var key:String = base + "_" + coat;
         return this.m_baseCoatSpecial[key];
      }
      
      public function getSpecialCandyByBaseCoatMapping(key:String) : String
      {
         return this.m_baseCoatSpecial[key];
      }
      
      public function getTimeLeft(key:String, throttleTime:int) : int
      {
         var lastTs:Number = Global.player.getFeatureLastShown(key) as Number;
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - lastTs;
         return int(throttleTime - timeSinceLastFeed);
      }
      
      public function getTimeLeftInFormat(key:String, throttleTime:int) : String
      {
         var format:int = 0;
         var secondsLeft:int = this.getTimeLeft(key,throttleTime);
         var hourLeft:String = Math.floor(secondsLeft / 3600).toString();
         var minutesLeft:String = Math.floor((secondsLeft - parseInt(hourLeft) * 3600) / 60).toString();
         var remainingSecsLeft:String = (secondsLeft - (parseInt(hourLeft) * 3600 + parseInt(minutesLeft) * 60)).toString();
         if(hourLeft.length < 2)
         {
            format = 1;
            hourLeft = "0" + hourLeft;
         }
         if(minutesLeft.length < 2)
         {
            format = 2;
            minutesLeft = "0" + minutesLeft;
         }
         if(remainingSecsLeft.length < 2)
         {
            format = 3;
            remainingSecsLeft = "0" + remainingSecsLeft;
         }
         if(format == 1)
         {
            return hourLeft + ":" + minutesLeft + ":" + remainingSecsLeft;
         }
         if(format == 2)
         {
            return minutesLeft + ":" + remainingSecsLeft;
         }
         return remainingSecsLeft;
      }
      
      public function getStationMakingTimerLeft(givenTime:Number) : int
      {
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var timeLeft:int = int(Math.abs(currentTime - givenTime));
         return STATION_MAKING_TIME - timeLeft;
      }
      
      public function getTryTimeLeftUtil() : int
      {
         var key:String = this.TRY_COOL_DOWN_TIME;
         var givenTime:Number = this.getFeatureOptionsKey(key) as Number;
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return int(Math.abs(currentTime - givenTime));
      }
      
      public function getKidWaitTimeByKid(kid:String) : int
      {
         var givenTime:Number = this.getFeatureOptionsKey(kid) as Number;
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return int(Math.abs(currentTime - givenTime));
      }
      
      public function getKidRetuenTimeByKid(kid:String) : int
      {
         var givenTime:Number = this.getFeatureOptionsKey(kid) as Number;
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return int(Math.abs(currentTime - givenTime));
      }
      
      public function incrementTryCount() : void
      {
         var tryCount:int = this.getFeatureOptionsKey(this.DAILY_TRY_COUNT) as int;
         this.saveFeatureOptionsKey(this.DAILY_TRY_COUNT,tryCount + 1);
      }
      
      public function setTryTimeCoolDown() : void
      {
         this.saveFeatureOptionsKey(this.TRY_COOL_DOWN_TIME,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND);
      }
      
      public function setKidWaitTime(kidWaitTime:String) : void
      {
         this.saveFeatureOptionsKey(kidWaitTime,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND);
      }
      
      public function isTryCountLimitReached() : Boolean
      {
         var tryCount:int = this.getFeatureOptionsKey(this.DAILY_TRY_COUNT) as int;
         return tryCount >= this.DAILY_MAX_TRY_LIMIT;
      }
      
      public function refreshCandyConversionWindow() : void
      {
         if(this.m_candyConvesrionWindow)
         {
            this.m_candyConvesrionWindow.refreshWindow();
         }
      }
      
      public function refreshStations() : void
      {
         if(Boolean(this.m_mainWindow) && Boolean(this.m_mainWindow.m_stationsFrame))
         {
            this.m_mainWindow.m_stationsFrame.refresh();
         }
      }
      
      public function tintCandyConvesrionWindow() : void
      {
         if(this.m_candyConvesrionWindow)
         {
            this.m_candyConvesrionWindow.tintWindow();
            this.m_candyConvesrionWindow.enableInput = false;
         }
      }
      
      public function untintCandyConvesrionWindow() : void
      {
         if(this.m_candyConvesrionWindow)
         {
            this.m_candyConvesrionWindow.untintWindow();
            this.m_candyConvesrionWindow.enableInput = true;
         }
      }
      
      public function untintCandyConvesrion(event:GenericPopupEvent) : void
      {
         if(this.m_candyConvesrionWindow)
         {
            this.m_candyConvesrionWindow.untintWindow();
            this.m_candyConvesrionWindow.enableInput = true;
         }
      }
      
      public function addNormalCandiesToStation(base:String, coat:String) : void
      {
         this.tintCandyConvesrionWindow();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"addNormalCandiesToStation",this.onAddNormalCandyToStation,[m_featureName,base,coat]),true);
      }
      
      public function onAddNormalCandyToStation(result:Object) : void
      {
         if(Boolean(result) && !result["error"])
         {
            this.saveFeatureOptionsKey(this.SPECIAL_CANDY_MAPPING_FLAG,result["specialCandyMappingFlag"]);
            this.saveFeatureOptionsKey(this.SPECIAL_CANDY_SLOTS_COUNT,result["numberOfSpecialTaskCount"]);
            this.saveFeatureOptionsKey(this.SPECIAL_CANDY_VISITED,result["specialCandyVisited"]);
            this.saveFeatureOptionsKey(this.BASE_COAT_MAPPING,result["baseCoatMapping"]);
            this.saveFeatureOptionsKey(this.KEY_STATIONS_DATA,result["stationData"]);
            if(result["specialCandyName"])
            {
               this.foundSpecialCandyPopUp(result["specialCandyName"]);
            }
         }
         this.refreshCandyConversionWindow();
         this.untintCandyConvesrionWindow();
      }
      
      public function foundSpecialCandyPopUp(specialCandy:String) : void
      {
         this.m_candyConvesrionWindow.tintWindow();
         this.m_candyConvesrionWindow.enableInput = false;
         var message:String = "New Candy Found! \n \n You just found a new candy!\n" + "From how it tastes " + this.getKidsNameBySpecialCandy(specialCandy) + " will love it \n";
         this.m_confirmPopup = new GenericPopup(message,GenericPopup.TYPE_OK,this.untintCandyConvesrion);
         this.m_confirmPopup.setAcceptTextName("Ok");
         UI.displayPopup(this.m_confirmPopup,false,"found_new_special_candy",true);
      }
      
      public function isSpecialCandySlotsCountReached() : Boolean
      {
         var specialCanySlotCount:int = this.getFeatureOptionsKey(this.SPECIAL_CANDY_SLOTS_COUNT) as int;
         return specialCanySlotCount >= this.MAX_SPECIAL_CANDY_SLOTS_COUNT;
      }
      
      public function getBasicCoatCandiesFromSpecialCandyMapping() : Array
      {
         var value:Array = null;
         var key:String = null;
         var result:Array = [];
         var mappingData:Object = this.getFeatureOptionsKey(this.SPECIAL_CANDY_MAPPING_FLAG);
         for(key in mappingData)
         {
            if(mappingData[key])
            {
               value = key.split("_");
               result.push([value[0],value[1]]);
            }
         }
         return result.sort();
      }
      
      public function canMakeSpecialCandy(specialCandy:String) : Boolean
      {
         var result:Object = this.getFeatureOptionsKey(this.SPECIAL_CANDY_MAKING_TIMER) as Object;
         var lastTs:Number = Number(result[specialCandy]);
         var throttleTime:int = this.DEFAULT_SPECIAL_CANDY_MAKING_TIMER;
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - lastTs;
         var timeRemaining:int = throttleTime - timeSinceLastFeed;
         return timeRemaining <= 0;
      }
      
      public function getSpecialCandyMakeTime(specialCandyName:String) : int
      {
         var result:Object = this.getFeatureOptionsKey(this.SPECIAL_CANDY_MAKING_TIMER) as Object;
         var lastTs:Number = Number(result[specialCandyName]);
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return int(Math.abs(currentTime - lastTs) / FarmGameUtil.NUM_SECS_IN_MINUTE);
      }
      
      public function isStationMakeTimeOver(specialCandy:String) : Boolean
      {
         return this.canMakeSpecialCandy(specialCandy);
      }
      
      public function onStationBuyBT(fc:int, stattionId:int) : void
      {
         if(Global.player.canBuyCash(fc))
         {
            Global.player.cash -= fc;
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"stationBuyBT",this.stationBuyBTCallback,[m_featureName,stattionId]),true);
         }
         else
         {
            this.m_mainWindow.untintWindow();
            this.m_mainWindow.enableInput = true;
         }
      }
      
      public function stationBuyBTCallback(result:Object) : void
      {
         if(Boolean(result) && !result.hasOwnProperty("error"))
         {
            this.saveFeatureOptionsKey(this.KEY_STATIONS_DATA,result["stationData"]);
            this.refreshSpecialCandyFrame();
            this.m_mainWindow.untintWindow();
            this.m_mainWindow.enableInput = true;
         }
      }
      
      public function onCollectSpecialCandy(specialCandyName:String, stationId:int) : void
      {
         this.m_mainWindow.tintWindow();
         this.m_mainWindow.enableInput = false;
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"collectSpecialCandy",this.collectSpecialCandyCallback,[m_featureName,specialCandyName,stationId]),true);
      }
      
      public function collectSpecialCandyCallback(result:Object) : void
      {
         if(Boolean(result) && !result.hasOwnProperty("error"))
         {
            this.saveFeatureOptionsKey(this.KEY_SPECIAL_CANDIES_INVENTORY,result["specialCandyInventory"]);
            this.saveFeatureOptionsKey(this.SPECIAL_CANDY_VISITED,result["specialCandyVisited"]);
            this.saveFeatureOptionsKey(this.KEY_STATIONS_DATA,result["stationData"]);
            this.refreshKidFrame();
            this.refreshSpecialCandySlot(result["stationId"]);
            this.m_mainWindow.untintWindow();
            this.m_mainWindow.enableInput = true;
         }
      }
      
      public function getSpecialCandySlotsCountFilled() : int
      {
         return this.getFeatureOptionsKey(this.SPECIAL_CANDY_SLOTS_COUNT) as int;
      }
      
      public function isSpecialCandyVisited(specialCandyName:String) : Boolean
      {
         var specialCandyVisited:Object = this.getFeatureOptionsKey(this.SPECIAL_CANDY_VISITED);
         return specialCandyVisited[specialCandyName] <= 1;
      }
      
      protected function parseRewardsDataFromConfig(questName:String) : void
      {
         var dailyRewards:XML = null;
         var rewardsList:XMLList = null;
         var rewardsByday:XML = null;
         var rewardsXMLListByStage:XMLList = null;
         this.m_rewardsBySlotName = {};
         dailyRewards = Global.farmGameSettingsManager.getXML().Halloween2019InnovationQuests.Halloween2019InnovationQuest.(@name == questName)[0];
         rewardsList = dailyRewards.Halloween2019InnovationRewards.day;
         for each(rewardsByday in rewardsList)
         {
            rewardsXMLListByStage = rewardsByday.rewards;
            this.m_rewardsBySlotName[rewardsByday.@id] = rewardsXMLListByStage;
         }
      }
      
      public function taskCompletionActivity(taskPoints:int, questIndex:int) : void
      {
         this.incrementOderboardTaskCount();
         if(this.isOrderboardTaskLimitReached())
         {
            this.setOrderboardSlot(questIndex,2);
         }
         this.grantPointsForTask(taskPoints);
         this.refreshDailyTaskCounts();
         if(this.isDailyTaskCountReached())
         {
         }
      }
      
      public function makeSpecialCandy(specialCandyName:String, stationId:int, base:String, coat:String) : void
      {
         this.m_mainWindow.tintWindow();
         this.m_mainWindow.enableInput = false;
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"makeSpecialCandy",this.onMakeSpecialCandy,[m_featureName,specialCandyName,stationId,base,coat]),true);
         StatsManager.count("Halloween19Innovation","make",this.getDatCount().toString(),specialCandyName,base + ":" + (this.getBasicCandyCountByName(base) + 1).toString() + " " + coat + ":" + this.getBasicCandyCountByName(coat).toString(),this.getFeaturePoints().toString());
      }
      
      public function onMakeSpecialCandy(result:Object) : void
      {
         if(Boolean(result) && !result["error"])
         {
            this.saveFeatureOptionsKey(this.KEY_STATIONS_DATA,result["stations"]);
            this.decreaseNormalCandyCount(result["baseCandy"],1);
            this.decreaseNormalCandyCount(result["coatCandy"],1);
            if(result.hasOwnProperty("kid1Wait"))
            {
               this.saveFeatureOptionsKey("kid1WaitTime",result["kid1Wait"]);
            }
            if(result.hasOwnProperty("kid2Wait"))
            {
               this.saveFeatureOptionsKey("kid2WaitTime",result["kid2Wait"]);
            }
            if(result.hasOwnProperty("kid3Wait"))
            {
               this.saveFeatureOptionsKey("kid3WaitTime",result["kid3Wait"]);
            }
         }
         this.refreshKidFrame();
         this.refreshBasicCandyFrame();
         this.refreshSpecialCandyFrame();
         this.m_mainWindow.untintWindow();
         this.m_mainWindow.enableInput = true;
      }
      
      public function getStaionsData() : Array
      {
         return this.getFeatureOptionsKey(this.KEY_STATIONS_DATA) as Array;
      }
      
      public function isBaseCoatFormSpecialCandy(base:String, coat:String) : Boolean
      {
         var key:String = base + "_" + coat;
         var mappingObj:Object = this.getFeatureOptionsKey(this.SPECIAL_CANDY_MAPPING);
         return !!mappingObj[key];
      }
      
      public function onTryBuyBT(fc:int) : void
      {
         if(Global.player.canBuyCash(fc))
         {
            Global.player.cash -= fc;
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"tryBuyBT",this.tryBuyBTCallback,[m_featureName]),true);
         }
      }
      
      public function tryBuyBTCallback(result:Object) : void
      {
         if(!(Boolean(result) && result.hasOwnProperty("error")))
         {
            this.saveFeatureOptionsKey(this.TRY_COOL_DOWN_TIME,0);
            this.m_candyConvesrionWindow.untintWindow();
            this.m_candyConvesrionWindow.enableInput = true;
            this.m_candyConvesrionWindow.refreshWindow();
         }
      }
      
      public function onSkipKidWaitTime(fcCash:int, kidWaitTime:String, slotIndex:int) : void
      {
         if(Global.player.canBuyCash(fcCash))
         {
            Global.player.cash -= fcCash;
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipKidWaitTime",this.onSkipTimeCallBack,[m_featureName,kidWaitTime,slotIndex]),true);
         }
         else
         {
            this.m_mainWindow.untintWindow();
            this.m_mainWindow.enableInput = true;
         }
      }
      
      public function onSkipTimeCallBack(result:Object) : void
      {
         if(!(Boolean(result) && result.hasOwnProperty("error")))
         {
            this.saveFeatureOptionsKey(result["kidWaitTime"],0);
            this.saveFeatureOptionsKey(result["kidReturnStatekey"],result["kidReturnStateValue"]);
            this.saveFeatureOptionsKey(result["kidReturnTimekey"],result["kidReturnTimeValue"]);
            this.refreshKidSlot(result["slotIndex"]);
         }
         this.m_mainWindow.untintWindow();
         this.m_mainWindow.enableInput = true;
      }
      
      public function isBaseCoatTried(base:String, coat:String) : Boolean
      {
         var key:String = base + "_" + coat;
         var baseCoatMapping:Object = this.getFeatureOptionsKey(this.BASE_COAT_MAPPING);
         return baseCoatMapping[key];
      }
      
      public function resetSlot(questIndex:int, callback:Function) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"resetSlot",callback,[m_featureName,questIndex]),true);
      }
      
      public function setupHalloweenInnovationHud() : void
      {
         this.m_HalloweenInnovationHud = new HudBottomHalloweenInnovation2019Button(this.HUD_HALLOWEENINNOVATION_ASSET,m_featureName);
         Global.hud.setBottomHudHalloweenInnovation2019Button(this.m_HalloweenInnovationHud as HudBottomHalloweenInnovation2019Button);
      }
      
      public function isOrderboardTaskLimitReached() : Boolean
      {
         var dailyOBTaskCount:int = this.getDailyOderboardTaskCount();
         var dailyMaxOBTaskCount:int = this.getMaxDailyOderboardCount();
         return dailyMaxOBTaskCount - NUMBER_ORDERBOARD_SLOT < dailyOBTaskCount;
      }
      
      public function setOrderboardSlot(slotIndex:int, slotValue:int) : void
      {
         var redeemSlots:Object = this.getFeatureOptionsKey(this.ORDERBOARD_SLOTS_DATA);
         redeemSlots[slotIndex] = slotValue;
         this.saveFeatureOptionsKey(this.ORDERBOARD_SLOTS_DATA,redeemSlots);
      }
      
      public function isOrderboardTaskLimitReachedByOrderboardSlot(slotNumber:int) : Boolean
      {
         var redeemSlots:Object = this.getFeatureOptionsKey(this.ORDERBOARD_SLOTS_DATA);
         return redeemSlots[slotNumber] == 2;
      }
      
      public function getTasks() : Vector.<FarmTask>
      {
         var task:Object = null;
         var taskXML:XML = null;
         var taskObj:Object = null;
         var farmTask:FarmTask = null;
         var taskList:Vector.<FarmTask> = new Vector.<FarmTask>();
         var savedTaskInfo:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         if(Boolean(savedTaskInfo) && Boolean(savedTaskInfo.length))
         {
            if(this.m_tasksById == null)
            {
               this.parseTaskObjectsFromConfig(m_featureName);
            }
            for each(task in savedTaskInfo)
            {
               taskXML = this.m_tasksById[task[this.KEY_TASK_ID]];
               if(taskXML)
               {
                  taskObj = FarmGameUtil.xmlNodeToAttributes(taskXML);
                  taskObj.questName = m_featureName;
                  taskObj.taskIndex = savedTaskInfo.indexOf(task);
                  farmTask = new FarmTask(taskObj);
                  taskList.push(farmTask);
               }
               else
               {
                  taskObj = {};
                  taskObj.action = "useItemByCode";
                  taskObj.type = "vg3q";
                  taskObj.total = "5";
                  taskObj.cashValue = "3";
                  taskObj.helper = "post_ask_for_item_feed";
                  taskObj.questName = m_featureName;
                  taskObj.taskIndex = savedTaskInfo.indexOf(task);
                  farmTask = new FarmTask(taskObj);
                  taskList.push(farmTask);
               }
            }
         }
         return taskList;
      }
      
      protected function saveProgressForPlayer(progressArray:Array) : void
      {
         var taskObj:Object = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         var savedTasks:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         var tasksToSave:Array = [];
         for(var i:int = 0; i < tasks.length; i++)
         {
            taskObj = {};
            if(tasks[i].id != "")
            {
               taskObj[this.KEY_TASK_ID] = tasks[i].id;
            }
            if(tasks[i].helperType == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
            {
               taskObj[this.KEY_PROGRESS] = CraftingManager.getInstance().getBushelQuantityInInventory(tasks[i].type);
            }
            else
            {
               taskObj[this.KEY_PROGRESS] = Math.min(Number(savedTasks[i][this.KEY_PROGRESS]) + progressArray[i],tasks[i][this.KEY_TOTAL]);
            }
            tasksToSave.push(taskObj);
         }
         this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,tasksToSave as Object);
      }
      
      protected function checkForTaskUpdates(event:TransactionEvent) : void
      {
         var progress:Number = NaN;
         var transaction:TFarmTransaction = null;
         var hasUpdatedProgress:Boolean = false;
         var hasCompletedTask:Boolean = false;
         var progressArray:Array = [];
         var tasks:Vector.<FarmTask> = this.getTasks();
         var savedTasks:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         for(var i:int = 0; i < tasks.length; i++)
         {
            transaction = event.transaction as TFarmTransaction;
            if(tasks[i].helperType == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
            {
               progress = CraftingManager.getInstance().getBushelQuantityInInventory(tasks[i].type) - savedTasks[i][this.KEY_PROGRESS];
               hasUpdatedProgress = true;
               FarmStatsManager.count("Halloween19Innovation","PerformTask",tasks[i].questName,tasks[i].type,"","",tasks[i].questPoints);
            }
            else
            {
               progress = FarmQuestUtility.getInstance().getProgression(tasks[i],transaction,null);
            }
            progressArray.push(progress);
            if(progress > 0)
            {
               hasUpdatedProgress = true;
               if(Number(savedTasks[i][this.KEY_PROGRESS]) + progress >= tasks[i].total)
               {
                  hasCompletedTask = true;
               }
            }
         }
         if(hasUpdatedProgress)
         {
            this.saveProgressForPlayer(progressArray);
         }
      }
      
      protected function onTransactionAdded(event:TransactionEvent) : void
      {
         this.checkForTaskUpdates(event);
      }
      
      protected function parseTaskObjectsFromConfig(questName:String) : void
      {
         var orderBoardXml:XML = null;
         var tasksByDifficultyList:XMLList = null;
         var tasksByDiff:XML = null;
         var tasksByDiffAndTypeList:XMLList = null;
         var tasksByDiffAndType:XML = null;
         var taskXML:XML = null;
         this.m_tasksById = {};
         orderBoardXml = Global.farmGameSettingsManager.getXML().orderBoards.orderBoard.(@name == questName)[0];
         if(orderBoardXml)
         {
            tasksByDifficultyList = orderBoardXml.orderBoardTasks.difficulty;
            for each(tasksByDiff in tasksByDifficultyList)
            {
               tasksByDiffAndTypeList = tasksByDiff.tasks;
               for each(tasksByDiffAndType in tasksByDiffAndTypeList)
               {
                  for each(taskXML in tasksByDiffAndType.task)
                  {
                     this.m_tasksById[taskXML.@id] = taskXML;
                  }
               }
            }
         }
      }
      
      public function saveBushelProgress() : void
      {
      }
      
      public function getTaskProgress(taskIndex:int) : int
      {
         var progress:int = 0;
         var savedTasksProgress:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         if(Boolean(savedTasksProgress) && Boolean(savedTasksProgress[taskIndex][this.KEY_PROGRESS]))
         {
            progress = int(savedTasksProgress[taskIndex][this.KEY_PROGRESS]);
         }
         return progress;
      }
      
      private function resetActionCountsForTasks(questTask:FarmTask) : void
      {
         var actionKey:String = null;
         if(questTask.action == QuestConstants.TASK_USE_ITEM_BY_CODE)
         {
            actionKey = questTask.getActionKey();
            if(Boolean(actionKey) && actionKey != "")
            {
               Global.player.resetActionCount(actionKey);
            }
         }
      }
      
      public function isTaskDumped(questIndex:int) : Boolean
      {
         var result:Boolean = false;
         var savedTasks:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         if(!savedTasks[questIndex].hasOwnProperty(this.KEY_ID))
         {
            result = true;
         }
         return result;
      }
      
      public function canDumpTask(questIndex:int) : Boolean
      {
         var currentTime:Number = NaN;
         var result:Boolean = true;
         var throttleTimeInSeconds:Number = 15 * FarmGameUtil.NUM_SECS_IN_MINUTE;
         var dumpTimestamp:Object = this.getFeatureOptionsKey(this.KEY_SAVED_DUMPED_TIMESTAMP) as Object;
         if(dumpTimestamp != null && dumpTimestamp.hasOwnProperty(questIndex.toString()))
         {
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            result = currentTime - dumpTimestamp[questIndex] > throttleTimeInSeconds;
         }
         return result;
      }
      
      public function dumpTask(questIndex:int, callback:Function) : void
      {
         var dumpTimestamp:Object = null;
         if(this.canDumpTask(questIndex))
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"dumpTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
            dumpTimestamp = this.getFeatureOptionsKey(this.KEY_SAVED_DUMPED_TIMESTAMP) as Object;
            if(dumpTimestamp == null)
            {
               dumpTimestamp = new Object();
            }
            dumpTimestamp[questIndex] = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            this.saveFeatureOptionsKey(this.KEY_SAVED_DUMPED_TIMESTAMP,dumpTimestamp);
         }
      }
      
      public function getTimeRemainingForDumpedTask(questIndex:int) : Number
      {
         var result:Number = NaN;
         var currentTime:Number = NaN;
         var throttleTimeInSeconds:Number = 15 * FarmGameUtil.NUM_SECS_IN_MINUTE;
         var dumpTimestamp:Object = this.getFeatureOptionsKey(this.KEY_SAVED_DUMPED_TIMESTAMP) as Object;
         if(dumpTimestamp != null && dumpTimestamp.hasOwnProperty(questIndex.toString()))
         {
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            result = throttleTimeInSeconds - (currentTime - dumpTimestamp[questIndex]);
         }
         return result;
      }
      
      public function skipDumpedTask(questIndex:int, callback:Function) : void
      {
         var dumpTimestamp:Object = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         if(Global.player.canBuyCash(this.SKIP_COST))
         {
            Global.player.cash -= this.SKIP_COST;
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipDumpedTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
            dumpTimestamp = this.getFeatureOptionsKey(this.KEY_SAVED_DUMPED_TIMESTAMP) as Object;
            dumpTimestamp[questIndex] = 0;
            this.saveFeatureOptionsKey(this.KEY_SAVED_DUMPED_TIMESTAMP,dumpTimestamp);
            this.resetActionCountsForTasks(tasks[questIndex]);
         }
         else
         {
            callback.call();
         }
      }
      
      public function skipTask(questIndex:int, taskPoints:int, callback:Function) : void
      {
         var savedTasks:Array = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         if(Global.player.canBuyCash(tasks[questIndex].skipCashValue))
         {
            Global.player.cash -= tasks[questIndex].skipCashValue;
            savedTasks = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
            savedTasks[questIndex][this.KEY_PROGRESS] = tasks[questIndex].total;
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,savedTasks);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
            this.resetActionCountsForTasks(tasks[questIndex]);
            this.taskCompletionActivity(taskPoints,questIndex);
         }
         else
         {
            callback.call();
         }
      }
      
      public function getNewTasks(questIndex:int, callback:Function) : void
      {
         var tasks:Vector.<FarmTask> = this.getTasks();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getNewTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
         var dumpTimestamp:Object = this.getFeatureOptionsKey(this.KEY_SAVED_DUMPED_TIMESTAMP) as Object;
         dumpTimestamp[questIndex] = 0;
         this.saveFeatureOptionsKey(this.KEY_SAVED_DUMPED_TIMESTAMP,dumpTimestamp);
         this.resetActionCountsForTasks(tasks[questIndex]);
      }
      
      public function grantPointsForTask(pointsForTask:int) : void
      {
         this.incrementCandyCount(pointsForTask);
         this.grandBasicCandies(pointsForTask);
         if(this.isDailyMilestoneReached())
         {
            this.grandDailyMilestoneRewardUtil();
         }
         if(this.m_mainWindow)
         {
            this.m_mainWindow.m_candyKidFrame.refresh();
         }
      }
      
      public function grantDailyReward() : void
      {
         if(this.isDailyMilestoneReached())
         {
            this.grandDailyMilestoneRewardUtil();
         }
      }
      
      public function showDailyMilestoneRewardPopup(rewardName:String) : void
      {
         var featureKey:String = m_featureName + "_dailyReward";
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(rewardName);
         this.m_InventionRewardPopup = new GenericSingleRewardPopup(this.REWARD_POPUP_WINDOW,featureKey,rewardItem,null,this.REWARD_WINDOW_IMAGE);
         UI.displayPopup(this.m_InventionRewardPopup,false);
      }
      
      public function sinkGold(questIndex:int, callback:Function) : void
      {
         var savedTasks:Array = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         if(Global.player.canBuy(tasks[questIndex].total))
         {
            Global.player.gold -= tasks[questIndex].total;
            savedTasks = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
            savedTasks[questIndex][this.KEY_PROGRESS] = tasks[questIndex].total;
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,savedTasks);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkGold",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
            this.taskCompletionActivity(tasks[questIndex].questPoints,questIndex);
            StatsManager.count(m_featureName,"Coin Sink","",tasks[questIndex].total.toString(),this.getOrderboardProgress().toString());
         }
         else
         {
            callback.call();
         }
      }
      
      public function sinkBushel(questIndex:int, callback:Function) : void
      {
         var tasks:Vector.<FarmTask> = this.getTasks();
         CraftingManager.getInstance().deductItemFromCraftingInventory(tasks[questIndex].type,tasks[questIndex].total);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkBushel",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
         StatsManager.count(m_featureName,"Sink Bushel","",tasks[questIndex].total.toString(),this.getOrderboardProgress().toString());
      }
      
      public function redeemRewardPoints(questIndex:int, callback:Function, taskPoints:int = 0) : void
      {
         var tasks:Vector.<FarmTask> = this.getTasks();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"redeemRewardPoints",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
         this.resetActionCountsForTasks(tasks[questIndex]);
         this.m_orderboardWindow.refreshWindow();
      }
      
      public function get currencyName() : String
      {
         return "casablanca_task_points";
      }
      
      public function getKidWaitTime() : int
      {
         return KID_WAIT_TIME;
      }
      
      public function getMaxKidReturnTime() : int
      {
         return KID_RETUEN_TIME;
      }
      
      public function grantFeaturePointsForCandies(point:int) : void
      {
         var featurePoints:int = this.getFeatureOptionsKey(this.KEY_FEATURE_POINTS) as int;
         featurePoints += point;
         this.saveFeatureOptionsKey(this.KEY_FEATURE_POINTS,featurePoints);
         this.grantMilestoneReward();
      }
      
      public function getKidStateByKid(kid:String) : int
      {
         return this.getFeatureOptionsKey(kid) as int;
      }
      
      public function updateKidStatusByKid(kid:String, kidState:int) : void
      {
         this.saveFeatureOptionsKey(kid,kidState);
      }
      
      public function getKidWaitStartTimeByKid(kid:String) : *
      {
         return this.getFeatureOptionsKey(kid) as int;
      }
      
      public function grantPointForNormalCandies(candyNames:Array, slotNum:int) : void
      {
         var ind:int = 0;
         var isCandiesAvailable:Boolean = true;
         for(var index:int = 0; index < candyNames.length; index++)
         {
            if(this.getBasicCandyCountByName(candyNames[index]) <= 0)
            {
               isCandiesAvailable = false;
            }
         }
         if(isCandiesAvailable)
         {
            for(ind = 0; ind < candyNames.length; ind++)
            {
               if(this.getBasicCandyCountByName(candyNames[ind]) > 0)
               {
                  this.decreaseNormalCandyCount(candyNames[ind],this.NUMBER_OF_CANDIES_REDUCTION);
               }
            }
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"grantPointForNormalCandies",this.grantPointForNormalCandiesCallback,new Array(m_featureName,candyNames,slotNum)));
            StatsManager.count("Halloween19Innovation","give",this.getDatCount().toString(),"normalcandy",candyNames[0] + ":" + this.getBasicCandyCountByName(candyNames[0]) + " " + candyNames[1] + ":" + this.getBasicCandyCountByName(candyNames[1]),slotNum.toString(),this.getFeaturePoints());
         }
      }
      
      public function grantPointForNormalCandiesCallback(result:Object) : void
      {
         if(!result["error"])
         {
            if(result.hasOwnProperty("kidState"))
            {
               this.updateKidStatusByKid(result["kidId"],result["kidState"]);
            }
            if(result.hasOwnProperty("kidWaitTime"))
            {
               this.saveFeatureOptionsKey(result["kidWaitId"],result["kidWaitTime"]);
            }
            if(result.hasOwnProperty("kidReturnTime"))
            {
               this.saveFeatureOptionsKey(result["kidReturnId"],result["kidReturnTime"]);
            }
            this.saveFeatureOptionsKey(result["kidReturnStatekey"],result["kidReturnStateValue"]);
            this.grantFeaturePointsForCandies(this.POINTS_FOR_NORMAL_CANDY);
            this.refreshBasicCandyFrame();
            this.refreshSpecialCandyFrame();
            this.refreshKidFrame();
            if(this.m_mainWindow)
            {
               this.m_mainWindow.untintWindow();
               this.m_mainWindow.enableInput = true;
               this.m_mainWindow.updateMainWindow();
            }
         }
      }
      
      public function grantPointForSpecialCandies(candyNames:Array, specialCandy:String, slotNum:int) : void
      {
         var ind:int = 0;
         var isCandiesAvailable:Boolean = true;
         for(var index:int = 0; index < candyNames.length; index++)
         {
            if(this.getBasicCandyCountByName(candyNames[index]) <= 0)
            {
               isCandiesAvailable = false;
            }
         }
         if(isCandiesAvailable && this.getSpecialCandyCountByName(specialCandy) > 0)
         {
            for(ind = 0; ind < candyNames.length; ind++)
            {
               if(this.getBasicCandyCountByName(candyNames[ind]) > 0)
               {
                  this.decreaseNormalCandyCount(candyNames[ind],this.NUMBER_OF_CANDIES_REDUCTION);
               }
            }
            this.decreaseSpecialCandyCount(specialCandy,this.NUMBER_OF_CANDIES_REDUCTION);
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"grantPointForSpecialCandies",this.grantPointForSpecialCandiesCallback,new Array(m_featureName,candyNames,specialCandy,slotNum)));
            StatsManager.count("Halloween19Innovation","give",this.getDatCount().toString(),"allcandy",specialCandy + ":" + this.getSpecialCandyCountByName(specialCandy) + " " + candyNames[0] + ":" + this.getBasicCandyCountByName(candyNames[0]) + " " + candyNames[1] + ":" + this.getBasicCandyCountByName(candyNames[1]),slotNum.toString(),this.getFeaturePoints());
         }
      }
      
      public function grantPointForSpecialCandiesCallback(result:Object) : void
      {
         if(!result["error"])
         {
            if(result.hasOwnProperty("kidState"))
            {
               this.updateKidStatusByKid(result["kidId"],result["kidState"]);
            }
            if(result.hasOwnProperty("kidWaitTime"))
            {
               this.saveFeatureOptionsKey(result["kidWaitId"],result["kidWaitTime"]);
            }
            if(result.hasOwnProperty("kidReturnTime"))
            {
               this.saveFeatureOptionsKey(result["kidReturnId"],result["kidReturnTime"]);
            }
            this.saveFeatureOptionsKey(result["kidReturnStatekey"],result["kidReturnStateValue"]);
            this.grantFeaturePointsForCandies(this.POINTS_FOR_SPECIAL_CANDY);
            this.refreshBasicCandyFrame();
            this.refreshSpecialCandyFrame();
            this.refreshKidFrame();
            if(this.m_mainWindow)
            {
               this.m_mainWindow.untintWindow();
               this.m_mainWindow.enableInput = true;
               this.m_mainWindow.updateMainWindow();
            }
         }
      }
      
      public function updateKidStatusReturnTime(kid:int, base:String, coat:String) : void
      {
         this.m_mainWindow.tintWindow();
         this.m_mainWindow.enableInput = false;
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"updateKidsStatusByKidWithRetuenTime",this.updateKidsStatusByKidWithRetuenTimeCallback,[m_featureName,kid,base,coat]),true);
      }
      
      public function updateKidsStatusByKidWithRetuenTimeCallback(result:Object) : void
      {
         if(!result["error"])
         {
            this.saveFeatureOptionsKey(result["kidStateKey"],result["kidStatevalue"]);
            this.saveFeatureOptionsKey(result["kidReturnTimeKey"],result["kidReturnTimeValue"]);
            this.saveFeatureOptionsKey(result["kidWaitTimeKey"],result["kidWaitTime"]);
            this.saveFeatureOptionsKey(result["kidReturnStateKey"],result["kidReturnStateValue"]);
            this.refreshKidSlot(result["slotIndex"]);
            if(this.m_mainWindow)
            {
               this.m_mainWindow.untintWindow();
               this.m_mainWindow.enableInput = true;
            }
         }
      }
      
      public function updateKidWaitTimer(kidKey:String, KidReturnTimer:String, base:String, coat:String) : void
      {
         this.m_mainWindow.tintWindow();
         this.m_mainWindow.enableInput = false;
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"updateKidWaitTimer",this.updateKidWaitTimerCallback,[m_featureName,kidKey,KidReturnTimer,base,coat]),true);
      }
      
      public function updateKidWaitTimerCallback(result:Object) : void
      {
         if(!result["error"])
         {
            this.saveFeatureOptionsKey(result["kidKey"],0);
            this.saveFeatureOptionsKey(result["kidReturnKey"],result["kidReturnTime"]);
            this.refreshKidFrame();
            if(this.m_mainWindow)
            {
               this.m_mainWindow.untintWindow();
               this.m_mainWindow.enableInput = true;
            }
         }
      }
      
      public function setNewTaskLayer(slotId:int, callback:Function) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"setNewTaskLayer",ZCacheUtil.applyPartial(this.onSetNewTaskLayer,this,[callback]),[m_featureName,slotId]),true);
      }
      
      public function onSetNewTaskLayer(callback:Function, result:Object) : void
      {
         if(result)
         {
            if(result.hasOwnProperty("orderboardSlotData"))
            {
               this.saveFeatureOptionsKey(this.ORDERBOARD_SLOTS_DATA,result["orderboardSlotData"]);
            }
            if(Boolean(result) && result.hasOwnProperty("activeTasks"))
            {
               this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,result["activeTasks"]);
               if(Boolean(callback))
               {
                  callback.call();
               }
            }
         }
      }
      
      public function getKidReturnState(kid:String) : int
      {
         return this.getFeatureOptionsKey(kid) as int;
      }
      
      public function isFinalRewardChosen() : Boolean
      {
         if(this.getRewardBuildingName() != null && this.getRewardBuildingName() != "0")
         {
            return true;
         }
         return false;
      }
      
      public function getRewardBuildingName() : String
      {
         return this.getFeatureOptionsKey(KEY_SAVED_FINAL_REWARD_BUILDINGNAME) as String;
      }
      
      public function isNormalCandiesAvilable(candyDetails:Array) : Boolean
      {
         var available:Boolean = true;
         for(var i:int = 0; i < 2; i++)
         {
            if(this.getBasicCandyCountByName(candyDetails[i]) <= 0)
            {
               available = false;
            }
         }
         return available;
      }
      
      public function grantMilestoneReward() : void
      {
         var badge:String = null;
         var itemName:String = null;
         var dialogTextPrefix:String = null;
         var rewardItem:FarmItem = null;
         var showReward:Boolean = false;
         var showBadgeReward:Boolean = false;
         var points:int = this.getFeaturePoints();
         var mileStone:int = this.getMilestoneLevel();
         var badgeLevel:int = this.getBadgeLevel();
         var firstRewardGrant:Boolean = this.getFeatureOptionsKey(this.KEY_SAVED_FIRST_REWARD_RECEIVED) as Boolean;
         var secondRewardGrant:Boolean = this.getFeatureOptionsKey(this.KEY_SAVED_SECOND_REWARD_RECEIVED) as Boolean;
         var thirdRewardGrant:Boolean = this.getFeatureOptionsKey(this.KEY_SAVED_THIRD_REWARD_RECEIVED) as Boolean;
         var fourthRewardGrant:Boolean = this.getFeatureOptionsKey(this.KEY_SAVED_FOURTH_REWARD_RECEIVED) as Boolean;
         var fifthRewardGrant:Boolean = this.getFeatureOptionsKey(this.KEY_SAVED_FIFTH_REWARD_RECEIVED) as Boolean;
         var sixthRewardGrant:Boolean = this.getFeatureOptionsKey(this.KEY_SAVED_SISTH_REWARD_RECEIVED) as Boolean;
         var sevenRewardGrant:Boolean = this.getFeatureOptionsKey(this.KEY_SAVED_SEVEN_REWARD_RECEIVED) as Boolean;
         if(points >= this.VAL_MILESTONE_POINTS_ARRAY[mileStone] && !firstRewardGrant)
         {
            this.saveFeatureOptionsKey(KEY_MILESTONE_LEVEL,mileStone + 1);
            this.saveFeatureOptionsKey(this.KEY_SAVED_FIRST_REWARD_RECEIVED,true);
            showReward = true;
         }
         else if(points >= this.VAL_MILESTONE_POINTS_ARRAY[mileStone] && !secondRewardGrant)
         {
            this.saveFeatureOptionsKey(KEY_MILESTONE_LEVEL,mileStone + 1);
            this.saveFeatureOptionsKey(this.KEY_SAVED_SECOND_REWARD_RECEIVED,true);
            showReward = true;
         }
         else if(points >= this.VAL_MILESTONE_POINTS_ARRAY[mileStone] && !thirdRewardGrant)
         {
            this.saveFeatureOptionsKey(KEY_MILESTONE_LEVEL,mileStone + 1);
            this.saveFeatureOptionsKey(this.KEY_SAVED_THIRD_REWARD_RECEIVED,true);
            showReward = true;
         }
         else if(points >= this.VAL_MILESTONE_POINTS_ARRAY[mileStone] && !fourthRewardGrant)
         {
            this.saveFeatureOptionsKey(KEY_MILESTONE_LEVEL,mileStone + 1);
            this.saveFeatureOptionsKey(this.KEY_SAVED_FOURTH_REWARD_RECEIVED,true);
            showReward = true;
         }
         else if(points >= this.VAL_MILESTONE_POINTS_ARRAY[mileStone] && !fifthRewardGrant)
         {
            this.saveFeatureOptionsKey(KEY_MILESTONE_LEVEL,mileStone + 1);
            this.saveFeatureOptionsKey(this.KEY_SAVED_FIFTH_REWARD_RECEIVED,true);
            showReward = true;
         }
         else if(points >= this.VAL_MILESTONE_POINTS_ARRAY[mileStone] && !sixthRewardGrant)
         {
            this.saveFeatureOptionsKey(KEY_MILESTONE_LEVEL,mileStone + 1);
            this.saveFeatureOptionsKey(this.KEY_SAVED_SISTH_REWARD_RECEIVED,true);
            showReward = true;
         }
         else if(points >= this.VAL_MILESTONE_POINTS_ARRAY[mileStone] && !sevenRewardGrant)
         {
            this.saveFeatureOptionsKey(KEY_MILESTONE_LEVEL,mileStone + 1);
            this.saveFeatureOptionsKey(this.KEY_SAVED_SEVEN_REWARD_RECEIVED,true);
            showReward = true;
         }
         var firstBadgeGrant:Boolean = this.getFeatureOptionsKey(this.KEY_SAVED_FIRST_BADGE_RECEIVED) as Boolean;
         var secondBadgeGrant:Boolean = this.getFeatureOptionsKey(this.KEY_SAVED_SECOND_BADGE_RECEIVED) as Boolean;
         var thirdBadgeGrant:Boolean = this.getFeatureOptionsKey(this.KEY_SAVED_THIRD_BADGE_RECEIVED) as Boolean;
         var fourthBadgeGrant:Boolean = this.getFeatureOptionsKey(this.KEY_SAVED_FOURTH_BADGE_RECEIVED) as Boolean;
         if(points >= this.VAL_BADGE_POINTS_ARRAY[badgeLevel] && !firstBadgeGrant)
         {
            this.saveFeatureOptionsKey(KEY_BADGE_LEVEL,badgeLevel + 1);
            this.saveFeatureOptionsKey(this.KEY_SAVED_FIRST_BADGE_RECEIVED,true);
            badge = "badges_bronze.png";
            itemName = "Novice";
            showBadgeReward = true;
         }
         else if(points >= this.VAL_BADGE_POINTS_ARRAY[badgeLevel] && !secondBadgeGrant)
         {
            this.saveFeatureOptionsKey(KEY_BADGE_LEVEL,badgeLevel + 1);
            this.saveFeatureOptionsKey(this.KEY_SAVED_SECOND_BADGE_RECEIVED,true);
            badge = "badges_silver.png";
            itemName = "Expert";
            showBadgeReward = true;
         }
         else if(points >= this.VAL_BADGE_POINTS_ARRAY[badgeLevel] && !thirdBadgeGrant)
         {
            this.saveFeatureOptionsKey(KEY_BADGE_LEVEL,badgeLevel + 1);
            this.saveFeatureOptionsKey(this.KEY_SAVED_THIRD_BADGE_RECEIVED,true);
            badge = "badges_gold.png";
            itemName = "Master";
            showBadgeReward = true;
         }
         else if(points >= this.VAL_BADGE_POINTS_ARRAY[badgeLevel] && !fourthBadgeGrant)
         {
            this.saveFeatureOptionsKey(KEY_BADGE_LEVEL,badgeLevel + 1);
            this.saveFeatureOptionsKey(this.KEY_SAVED_FOURTH_BADGE_RECEIVED,true);
            badge = "badges_diamond.png";
            itemName = "Grand Master";
            showBadgeReward = true;
         }
         if(this.m_mainWindow)
         {
            this.m_mainWindow.updateMainWindow();
         }
         if(showBadgeReward)
         {
            UI.displayPopup(new Halloween2019InnovationBadgeRewardWindow(this.REWARD_POPUP_WINDOW,m_featureName,"assets/dialogs/spooky/innovation/" + badge,null,null,null,itemName),false);
            StatsManager.count(m_featureName,"profession",badgeLevel.toString() + ":" + (badgeLevel + 1).toString(),"","",this.getFeaturePoints().toString(),this.getDailyOderboardTaskCount());
         }
         if(showReward)
         {
            dialogTextPrefix = FEATURE_NAME + "_milestoneReward";
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(MILESTONE_REWARDS[mileStone]);
            Global.player.addGift(MILESTONE_REWARDS[mileStone],"",1);
            this.m_milestoneRewardPopup = new GenericSingleRewardPopup(this.REWARD_POPUP_WINDOW_SHARE,dialogTextPrefix,rewardItem,this.milestoneShare(rewardItem),this.REWARD_WINDOW_IMAGE);
            UI.displayPopup(this.m_milestoneRewardPopup,false);
            StatsManager.count(m_featureName,"Milestone",mileStone.toString(),rewardItem.friendlyTitle,"feature",this.getFeaturePoints().toString(),this.getDailyOderboardTaskCount());
         }
      }
      
      public function milestoneShare(rewardItem:FarmItem) : Function
      {
         return function(event:Event):void
         {
            var windowName:* = "Halloween2019Innovation";
            var bundleId:* = windowName + "ShareMilestone";
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
            if(m_milestoneRewardPopup)
            {
               m_milestoneRewardPopup.close();
            }
         };
      }
      
      public function getBadgeIndex() : int
      {
         return (this.getFeatureOptionsKey(KEY_BADGE_LEVEL) as int) + 1;
      }
      
      public function getHarvestTime(itemName:String) : String
      {
         var secondsLeft:int = this.getTimeLeftForBonusHarvest(itemName);
         var hourLeft:String = Math.floor(secondsLeft / 3600).toString();
         var minutesLeft:String = Math.floor((secondsLeft - parseInt(hourLeft) * 3600) / 60).toString();
         var remainingSecsLeft:String = (secondsLeft - (parseInt(hourLeft) * 3600 + parseInt(minutesLeft) * 60)).toString();
         if(hourLeft.length < 2)
         {
            hourLeft = "0" + hourLeft;
         }
         if(minutesLeft.length < 2)
         {
            minutesLeft = "0" + minutesLeft;
         }
         if(remainingSecsLeft.length < 2)
         {
            remainingSecsLeft = "0" + remainingSecsLeft;
         }
         return hourLeft + ":" + minutesLeft + ":" + remainingSecsLeft;
      }
      
      public function hasHarvestExpiryDatePassedForFeature(itemName:String) : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var timeRemain:int = 0;
         var finishTime:Number = NaN;
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("12/08/2019") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         timeLeft = endTime - now;
         if(timeLeft < 0)
         {
            timeRemain = this.getTimeLeftForBonusHarvest(itemName);
            finishTime = FarmGameUtil.synchronizedDateTimeToNumber("12/09/2019") / FarmGameUtil.NUM_MSECS_IN_SECOND;
            return finishTime - now <= timeRemain;
         }
         return false;
      }
      
      public function getTimeLeftForBonusHarvest(itemName:String) : int
      {
         var key:String = itemName + this.LAST_HARVEST_TIME_KEY;
         var throttleTime:int = DEFAULT_HARVEST_THROTTLE_TIME;
         return this.getTimeLeft(key,throttleTime);
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
      
      public function harvestBonusBuilding(buildingName:String) : void
      {
         var featureKey:String = null;
         var key:String = buildingName + this.LAST_HARVEST_TIME_KEY;
         Global.player.setFeatureLastShown(key,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         var harvestRewardName:String = this.getNextHarvestItemName(buildingName);
         var harvestFarmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(harvestRewardName);
         if(harvestFarmItem)
         {
            Global.player.addGift(harvestRewardName);
            featureKey = m_featureName + this.LAST_HARVEST_TIME_KEY;
            FarmStatsManager.count(m_featureName,"Harvest",buildingName,harvestRewardName);
            UI.displayPopup(new GenericSingleRewardPopup(this.REWARD_POPUP_WINDOW,"xhf_Bonus_" + buildingName,harvestFarmItem,null,this.REWARD_WINDOW_IMAGE),false);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,SERVICE_FUNC_HARVEST_BONUS,null,[m_featureName,buildingName]),true);
         }
      }
      
      public function getTaskPints(slotIndex:int) : int
      {
         var data:Array = this.getFeatureOptionsKey(this.ODERBORD_TASK_DESRCIPTION) as Array;
         return data[slotIndex];
      }
      
      public function setTaskPoints(taskPoint:int, slotIndex:int) : void
      {
         var data:Array = this.getFeatureOptionsKey(this.ODERBORD_TASK_DESRCIPTION) as Array;
         data[slotIndex] = taskPoint;
         this.saveFeatureOptionsKey(this.ODERBORD_TASK_DESRCIPTION,data);
      }
      
      public function untintMainwindow() : void
      {
         this.m_mainWindow.untintWindow();
         this.m_mainWindow.enableInput = true;
      }
      
      public function tintMainWindow() : void
      {
         this.m_mainWindow.tintWindow();
         this.m_mainWindow.enableInput = false;
      }
      
      public function setOderbordNPC() : void
      {
         if(Boolean(this.m_mainWindow) && Boolean(this.m_mainWindow.m_npcCalloutMc))
         {
            this.m_mainWindow.m_npcTitleTf.text = "Daily Limit Reached!";
            this.m_mainWindow.m_npcTextTf.text = "All the tasks for today are done but there are still kids to treat!";
            this.m_mainWindow.m_npcTextTf.visible = true;
            this.m_mainWindow.m_npcClodeBt.visible = true;
            this.m_mainWindow.m_npcCalloutMc.visible = true;
         }
      }
      
      public function getTotalBasicCandies() : int
      {
         var basicCandyCountList:Array = this.getBasicCandiesCounts();
         var basicCandyCount:int = 0;
         for(var i:int = 0; i < basicCandyCountList.length; i++)
         {
            basicCandyCount += basicCandyCountList[i];
         }
         return basicCandyCount;
      }
      
      public function getTotalSpecialCandies() : int
      {
         var specialCandyCountList:Array = this.getSpecialCandiesCounts();
         var specialCandyCount:int = 0;
         for(var i:int = 0; i < specialCandyCountList.length; i++)
         {
            specialCandyCount += specialCandyCountList[i];
         }
         return specialCandyCount;
      }
      
      public function getTotalCandies() : int
      {
         var i:int = 0;
         var basicCandyCountList:Array = this.getBasicCandiesCounts();
         var basicCandyCount:int = 0;
         var specialCandyCountList:Array = this.getSpecialCandiesCounts();
         var specialCandyCount:int = 0;
         for(i = 0; i < basicCandyCountList.length; i++)
         {
            basicCandyCount += basicCandyCountList[i];
         }
         for(i = 0; i < specialCandyCountList.length; i++)
         {
            specialCandyCount += specialCandyCountList[i];
         }
         return basicCandyCount + specialCandyCount;
      }
      
      public function getCandyConversionWeekOver() : int
      {
         var candies:int = this.getTotalCandies();
         var result:int = 0;
         if(candies >= 150 && candies <= 300)
         {
            result = 75;
         }
         else if(candies >= 301 && candies <= 900)
         {
            result = 150;
         }
         else if(candies >= 901)
         {
            result = 450;
         }
         return result;
      }
      
      public function get TilesArray() : Array
      {
         return this.m_staticData.tilesArray;
      }
      
      public function get lockedTilesArray() : Array
      {
         var tilename:String = null;
         var tileObjects:Array = null;
         var lockedTiles:Array = new Array();
         var tilesArray:Array = this.TilesArray as Array;
         for each(tilename in tilesArray)
         {
            tileObjects = Global.world.getObjectsByName(tilename);
            if(Boolean(tileObjects) && tileObjects.length > 0)
            {
               lockedTiles.push(tilename);
            }
         }
         return lockedTiles;
      }
      
      public function get tileUnlockCount() : int
      {
         var tilesArray:Array = this.TilesArray as Array;
         var lockedCount:int = this.lockedTilesArray.length >= 0 ? int(this.lockedTilesArray.length) : 0;
         return int(tilesArray.length - lockedCount);
      }
      
      public function showTileUnlockCountMc() : Number
      {
         var result:int = 0;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName);
         if(this.tileUnlockCount > featureData[this.KEY_TILE_UNLOCK_COUNT])
         {
            result = this.tileUnlockCount - featureData[this.KEY_TILE_UNLOCK_COUNT];
            featureData[this.KEY_TILE_UNLOCK_COUNT] = this.tileUnlockCount;
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,m_featureName,featureData);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"updateTileUnlockCount",null,[this.featureName,this.tileUnlockCount]),true);
         }
         return result;
      }
   }
}

