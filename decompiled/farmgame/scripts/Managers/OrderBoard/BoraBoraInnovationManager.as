package Managers.OrderBoard
{
   import Classes.Constants.WorldsConstants;
   import Classes.FeedData;
   import Classes.Idle.BoraboraWindowReopenIdleTask;
   import Classes.Idle.IdleTaskQueue;
   import Classes.ItemInstance;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.HUD.HUD;
   import Display.HUD.HUDWidgets.HudBoraBoraInnovationButton;
   import Display.UI;
   import Engine.Classes.IsoViewport;
   import Engine.Classes.Viewport;
   import Engine.Classes.WorldObject;
   import Engine.Events.TransactionEvent;
   import Engine.Helpers.Vector2;
   import Engine.Helpers.Vector3;
   import Engine.Managers.InputManager;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.TileUnlockEvent;
   import GameMode.GMDecoMove;
   import GameMode.GMDecorationPlace;
   import GameMode.GameMode;
   import Managers.BaseFeatureManager;
   import Managers.DecoratorModeManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.WorldSeasonsManager;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.BoraBoraInnovationCycleEndWindow;
   import Widgets.Windows.BoraBoraInnovationDailyRewardPopup;
   import Widgets.Windows.BoraBoraInnovationFeatureEndWindow;
   import Widgets.Windows.BoraBoraInnovationFinalRewardsWindow;
   import Widgets.Windows.BoraBoraInnovationLeaderboardWindow;
   import Widgets.Windows.BoraBoraInnovationMainWindow;
   import Widgets.Windows.BoraBoraInnovationNewCycleStartWindow;
   import Widgets.Windows.BoraBoraInnovationOrderboardWindow;
   import Widgets.Windows.BoraBoraInnovationScreenshotPopUp;
   import Widgets.Windows.BoraBoraInnovationSingleRewardPopup;
   import Widgets.Windows.BoraBoraInnovationWorldLoadStartWindow;
   import Widgets.Windows.BoraboraInnovationStageComplete;
   import Widgets.Windows.BoraboraInnovationUnlimitedCycleStartWindow;
   import Widgets.Windows.GenericSingleRewardPopup;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import gs.TweenLite;
   
   public class BoraBoraInnovationManager extends GenericSlotedOrderboardManager
   {
      
      private static var m_initialized:Boolean = false;
      
      private static const FEATURE_TRACKING:String = "BoraboraInnovation";
      
      protected static var m_instance:Object = {};
      
      public static const FEATURE_NAME:String = "BoraBoraInnovation";
      
      private static const m_serviceName:String = "BoraBoraInnovationService";
      
      public static const HUD_INITIALISATION_FLAG:String = "BB_firstTime_expansionLoad";
      
      public static const BB_INNOVATION_END_DECO_FLAG:String = "xbb_BB_end_deco_delete";
      
      private static const KEY_SAVED_LEADERBOARD_RESULT:String = "leaderboard_data";
      
      private static const KEY_CURRENT_LEADERBOARD:String = "currentLeaderboard";
      
      private static const KEY_THUMBSUP_POINTS:String = "thumbs_ups";
      
      private static const KEY_CURRENT_WEEK:String = "current_week";
      
      public static const MOVE_MODE:String = "move_mode";
      
      private static const BONUS_HARVEST_COUNT:String = "hc_";
      
      private static const SERVICE_FUNC_HARVEST_BONUS:String = "harvestDecos";
      
      public static const DEFAULT_HARVEST_THROTTLE_TIME:int = 86400;
      
      public static const DEFAULT_COLLECT_THROTTLE_TIME:int = 86400;
      
      private static const EVENT_WW_INNOVATION_TILE_UNLOCK:String = "BoraBoraInnovationTileUnlock";
      
      private static const KEY_TILES_UNLOCKED:String = "tiles_unlocked";
      
      private var m_currencyName:String = "task_points";
      
      public var m_mainWindow:BoraBoraInnovationMainWindow;
      
      private var m_zoom:Number;
      
      private var m_zid:String = "";
      
      protected var m_staticData:Object;
      
      private var m_feedConfig:Object = {};
      
      private const KEY_ACTIVE_DAY_TIMESTAMP:String = "active_day_timestamp";
      
      private const WEEKLY_SCORE:String = "weekly_score";
      
      public const KEY_DAY_POINTS:String = "daily_points";
      
      private const KEY_STAR_POINTS:String = "star_points";
      
      private const KEY_DAILY_REWARD_GRANTED:String = "dailyreward_granted";
      
      private const FLAG_FIRST_STARTNEWDAY:String = "borabora_first_newday";
      
      private const ITEM_COUNT_MAPPING:String = "icm";
      
      private const KEY_MILESTONES_EARNED:String = "ms_earned";
      
      public var m_leaderboardWindow:BoraBoraInnovationLeaderboardWindow;
      
      public var m_leaderboardpane_data:Object;
      
      public var m_rewardsWindow:BoraBoraInnovationFinalRewardsWindow;
      
      private var m_gameModes:Object;
      
      private var m_centerOnCallback:Function = null;
      
      private var m_scrollTween:TweenLite;
      
      public var m_thumbsPerStarGA:Array = new Array(0,105,210,315,525,1050);
      
      public var m_thumbsPerStarEA:Array = new Array(0,105,210,315,420,525,735,1050);
      
      private var m_decos:Object = null;
      
      private const m_milestoneRewards:Array = new Array("xbb_hawaiiweddinggnomes","monkey_xbb_wardance","magicdeer_xbb_whitetahitiandeer","xbb_aquaweddinggnomes","xbb_bestinboraboratrophy","magicdeer_xbb_bluepolynesiandeer","xbb_floralweddinggnomes","llama_xbb_rusticgroomsmen","horse_xbb_ringbearer","xbb_rusticweddinggnomes","dolphin_xbb_weddingsinger","xbb_bestinpolynesiatrophy","xbb_whimsicalweddinggnomes","horse_xbb_aquafloraldress","xbb_bestinoceaniatrophy","xbb_lavishweddinggnomes","horse_xbb_tahitistallion","horse_xbb_greenbora","unicorn_xbb_pukaruaatoll","unicorn_xbb_beachside","pegasus_xbb_oceanwavepagasus","pegasus_xbb_tribal","pegacorn_xbb_tuamotupriest","pegacorn_xbb_weddingminister","xbb_bestintheworldtrophy","xbb_sunsetbeachhouse","xbb_islandvilla","xbb_oceancabin","xbb_hotelseaview");
      
      private const m_dailyRewards:Array = new Array("cat_xbb_weddinghost","xbb_tahitiweddinggazebo","xbb_tropicaldancergnomette","xbb_woodtwistfence","turtle_xbb_tahitiaqua","rabbit_xbb_weddingguest","pkg_xbb_bigbuildableplustreasurepart_pack","xbb_surfnturffence","whale_xbb_weddingtux","goat_xbb_borawedding","pkg_xbb_treasurepartothers_pack","xbb_floralcoastfence","xbb_polynesiahuttower","xbb_rusticweddingraft","turtle_xbb_floralback","xbb_ropebeachfence","xbb_sparklerbucket","crab_xbb_vacation","xbb_seashellterrarium","xbb_pastelfence","xbb_sofitelcouple","xbb_falsetikitotem","pkg_xbb_farmessentials_pack","xbb_bronzegatefence","seal_xbb_flowergirl","pkg_xbb_treasurepartothers_pack","dolphin_xbb_tahiti","bird_xbb_boralorikeet","rabbit_xbb_traditionaltahitian","pkg_xbb_vehicleesentials_pack","xbb_hisherruinschair","gnome_xbb_tahititraveller","xbb_beachsurfstall","pkg_xbb_bigbuildableplustreasurepart_pack","dog_xbb_tropicprince","dog_xbb_surfphoto","xbb_seashellsandcastle","pkg_xbb_farmessentials_pack"
      ,"xbb_tropicringbox","xbb_sandbeachhut","duck_xbb_beachparty","pkg_xbb_treasurepartothers_pack","pkg_xbb_treasurepartothers_pack");
      
      private const m_starrewards_map:Object = {
         2:"xbb_hawaiiweddinggnomes",
         4:"monkey_xbb_wardance",
         6:"magicdeer_xbb_whitetahitiandeer",
         8:"xbb_aquaweddinggnomes",
         10:"xbb_bestinboraboratrophy",
         12:"magicdeer_xbb_bluepolynesiandeer",
         14:"xbb_floralweddinggnomes",
         16:"llama_xbb_rusticgroomsmen",
         18:"horse_xbb_ringbearer",
         20:"xbb_rusticweddinggnomes",
         25:"dolphin_xbb_weddingsinger",
         30:"xbb_bestinpolynesiatrophy",
         35:"xbb_whimsicalweddinggnomes",
         40:"horse_xbb_aquafloraldress",
         45:"xbb_bestinoceaniatrophy",
         50:"xbb_lavishweddinggnomes",
         55:"horse_xbb_tahitistallion",
         60:"horse_xbb_greenbora",
         70:"unicorn_xbb_pukaruaatoll",
         80:"unicorn_xbb_beachside",
         90:"pegasus_xbb_oceanwavepagasus",
         100:"pegasus_xbb_tribal",
         110:"pegacorn_xbb_tuamotupriest",
         120:"pegacorn_xbb_weddingminister",
         130:"xbb_bestintheworldtrophy",
         140:"xbb_sunsetbeachhouse",
         150:"xbb_islandvilla",
         160:"xbb_oceancabin",
         170:"xbb_hotelseaview"
      };
      
      private const m_starsRequired:Array = new Array(2,4,6,8,10,12,14,16,18,20,25,30,35,40,45,50,55,60,70,80,90,100,110,120,130,140,150,160,170);
      
      private var m_newCycleStartWindow:BoraBoraInnovationNewCycleStartWindow;
      
      public var MAX_THUMBSUP:int = 1050;
      
      private var CYCLE_INDEX:String = "ci";
      
      private var MAX_CYCLE:int = 6;
      
      private const MAX_DAILY_LIMIT:int = 175;
      
      private var m_cycleEndWindow:BoraBoraInnovationCycleEndWindow;
      
      public const LAST_HARVEST_TIME_KEY:String = "_lastHarvestTimeKey";
      
      public var BONUS_HARVEST_MAP:Object = {
         "xbb_weddingstore":new Array("fuel1","vehiclepart","pkg_xbb_treasurepart_pack","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard"),
         "xbb_weddingstudio":new Array("consume_unwither","consume_organic_fertilizer","fuel1","vehiclepart","pkg_xbb_treasurepart_pack","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard"),
         "xbb_weddingparlor":new Array("consume_instagrow","pkg_xbb_bigbuildable_pack","consume_turbo_charger","consume_unwither","consume_organic_fertilizer","fuel1","vehiclepart","pkg_xbb_treasurepart_pack","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard"),
         "xbb_weddingsalon":new Array("consume_instagrow","pkg_xbb_bigbuildable_pack","consume_turbo_charger","consume_unwither","consume_organic_fertilizer","fuel1","vehiclepart","pkg_xbb_treasurepart_pack","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard")
      };
      
      private const REWARD_POPUP_WINDOW:String = "assets/dialogs/expansion/FV_RewardDialog.swf";
      
      private const REWARD_WINDOW_IMAGE:String = "assets/dialogs/borabora/RewardDialog.png";
      
      private const KEY_BONUS_HARVEST_START_TIME:* = "bonus_harvest_start_time";
      
      private const KEY_BONUS_REWARD_GRANTED:String = "bb_final_rewards_granted";
      
      private var m_InventionRewardPopup:BoraBoraInnovationFeatureEndWindow;
      
      private const REWARD_POPUP_WINDOW_SHARE:String = "assets/dialogs/expansion/FV_RewardDialog_Share.swf";
      
      private const KEY_TOTAL_STAR_POINTS:* = "tsp";
      
      public var MAX_CYCLE_BORABORA_LIMIT:int = 2200;
      
      private var m_screenShotWindow:BoraBoraInnovationScreenshotPopUp;
      
      private const KEY_SHOW_MILESTONE_POPUP:String = "show_mspopup";
      
      public const m_npcBrideNames:Array = new Array("Maya","Joan","Tamy","Mindy","Whitney","Pam","Patricia","Molly","Polly","Kristine","Angela","Lily","Rachel","Tina","Megan","Trudy","Emma","Amy","Priya","Alana","Monica","Amber","Summer","Katy","Janet","Ginerva","Violet","Candice","Gaby","Magaret","Rhonda","Sophia","Mia","Abigail","Olivia","Isabella","Charlotte","Harper","Eve","Madison","Scarlett","Chloe","Vicky","Grace","Riley","Aubrey","Victoria","Aria","Zoey","Penelope","Layla","Camila","Natalie","Brittany","Hannah","Nora","Lea","Aubrey","Claire","Skylar","Ellie","Samantha","Lucy","Mila","Stella","Anna","Ariana","Hazel","Lucinda","Alexa","Caroline","Elizabeth","Sadie","Kendall","Madge","Gabriella","Adeline","Madelyn","Hailey","Ruby","Aurora","Piper","Eva","Naomi","Luna","Bella","Quinn","Peyton","Kylie","Julia","Mackenzie","Taylor","Katherine","Elena","Clara","Emilia");
      
      public const m_npcGroomNames:Array = new Array("Shawn","Kurt","Dan","Dave","Jackson","Tim","Jake","Harold","Howard","Bob","Kevin","Mason","Clark","Mike","Jonathan","Paul","Firenze","Arnold","Davon","Peter","James","Sean","Roger","Tony","Clive","Troy","Gary","Oliver","Brian","Stanley","Michael","Derek","Liam","Jacob","Noah","Benji","Alex","Ethan","Elijah","Lucas","Aiden","Logan","Sam","David","Max","Sebastian","Joseph","Owen","Gabriel","Carter","Hayden","Luke","Oscar","Henry","Rory","Dylan","Anthony","Wyatt","Jayden","Ryan","Jason","Caleb","Jim","Nathan","Christopher","Hunter","Levi","Charles","Micky","Thomas","Jeremy","Jordan","Christian","Cameron","Adrian","Connor","Robert","Hudson","Nolan","Nick","Brayden","Colton","Asher","Austin","Evan","Leo","Adam","Ross","Theo","Gavin","Ezra","Carson","Zack","Bryon","Tyler","Leonardo");
      
      private const NPC_INDEX:* = "ni";
      
      private const KEY_WEDDING_TIME:* = "wt";
      
      public const m_npcImages:Array = new Array("assets/newsfeed/maya_shawn_icon.png","assets/newsfeed/joan_kurt_icon.png","assets/newsfeed/tamy_dan_icon.png","assets/newsfeed/mindy_dave_icon.png","assets/newsfeed/whitney_jackson_icon.png","assets/newsfeed/pam_tim_icon.png");
      
      public const m_cycleStartSubtext:Array = new Array("We\'re so excited to be getting married in Bora Bora! We were hoping to have a Hawaiian-style wedding.","To commemorate our first meeting at a swimming class, we wanted an aqua-theme wedding.","We\'re both big botany nerds and wanted that reflected in the wedding theme.","We’re elated to be getting hitched in Bora Bora! Can you add some elements of our home in Texas in the wedding?","We met at a Bohemian music festival and would love to have a whimsical theme for the wedding!","We\'ve been saving for the big day and would like to host a lavish wedding for our guests!");
      
      public const m_unlimitedCycleStartSubtext:Array = new Array("We\'re looking forward to a Hawaiin-style wedding!","We would love to have an aqua-themed wedding.","Can you organize a floral theme wedding for us?","We would like a rustic theme decor for our big day!","Can you help organize a whimsical-themed wedding for us?","We\'re hoping to have a lavish wedding. Will you help us?");
      
      public const m_cycleEndSubtext:Array = new Array("That was spectacular. Thank you for organizing the best wedding ever for us.","Wow! You’ve outdone yourself. Thank you for everything.","We loved everything! Thank you for planning the best wedding for us!","That was spectacular! You’ve made us really happy.","You’ve outdone our expectations! Thank you for everything.","That was fabulous! Thank you for giving us our dream wedding.");
      
      public const m_unlimitedCycleEndSubtext:Array = new Array("That was spectacular. Thank you for organizing the best wedding ever for us.","Wow! You’ve outdone yourself. Thank you for everything.","We loved everything! Thank you for planning the best wedding for us!","That was spectacular! You’ve made us really happy.","You’ve outdone our expectations! Thank you for everything.","That was fabulous! Thank you for giving us our dream wedding.");
      
      public const m_cycleNames:Array = new Array("Hawaiian \n Wedding","Aqua \n Wedding","Floral \n Wedding","Rustic \n Wedding","Whimsical \n Wedding","Lavish \n Wedding");
      
      private var m_stageCompleteWindow:BoraboraInnovationStageComplete;
      
      public const KEY_STAGE1:String = "s1";
      
      public const KEY_STAGE2:String = "s2";
      
      private const KEY_CYCLE_START_ENTRY:String = "cse";
      
      private var m_unlimitedCycleStartWindow:BoraboraInnovationUnlimitedCycleStartWindow;
      
      public const m_npcBrideImages:Array = new Array("assets/newsfeed/NPC_xbb_shawn_happy.png","assets/newsfeed/NPC_xbb_kurt_happy.png","assets/newsfeed/NPC_xbb_dan_happy.png","assets/newsfeed/NPC_xbb_mindy_happy.png","assets/newsfeed/NPC_xbb_Jackson_happy.png","assets/newsfeed/NPC_xbb_tim_happy.png");
      
      public const m_npcGroomImages:Array = new Array("assets/newsfeed/NPC_xbb_maya_happy.png","assets/newsfeed/NPC_xbb_joan_happy.png","assets/newsfeed/NPC_xbb_tamy_happy.png","assets/newsfeed/NPC_xbb_dave_happy.png","assets/newsfeed/NPC_xbb_whitney_happy.png","assets/newsfeed/NPC_xbb_pam_happy.png");
      
      private var m_milastoneRewardPopup:BoraBoraInnovationSingleRewardPopup;
      
      private const KEY_PANEL_DISPLAY:String = "kpd";
      
      public function BoraBoraInnovationManager(featureName:String)
      {
         super(featureName,m_serviceName);
         startQuest();
         this.parseData();
         this.loadStaticData();
         m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_BORABORA);
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
         Global.stage.addEventListener(KeyboardEvent.KEY_UP,this.onDecoratorModeKeyUp);
         this.m_gameModes = new Object();
         this.m_gameModes[MOVE_MODE] = new GMDecoMove();
      }
      
      public static function getInstance(featureName:String = "BoraBoraInnovation") : BoraBoraInnovationManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,BoraBoraInnovationManager) as BoraBoraInnovationManager;
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
      
      override protected function saveFeatureOptionsKey(optionName:String, optionsValue:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,optionName,optionsValue);
      }
      
      protected function getFeatureOption() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName);
      }
      
      public function get isUserEA() : Boolean
      {
         m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_BORABORA);
         return m_isEA;
      }
      
      public function get mainWindow() : BoraBoraInnovationMainWindow
      {
         return this.m_mainWindow;
      }
      
      public function get orderboardWindow() : BoraBoraInnovationOrderboardWindow
      {
         return m_orderboardWindow;
      }
      
      public function setUpBoraBoraHud() : void
      {
         Global.hud.setBottomHudBoraBoraInnovationButton(new HudBoraBoraInnovationButton("assets/dialogs/april_innovation_2020/FV_xbb_hud_Innovation.swf",FEATURE_NAME));
      }
      
      public function startNewDay() : void
      {
         var weekData:Object = null;
         FarmStatsManager.count(FEATURE_TRACKING,"daystart",this.currentDayIndex.toString(),"",this.getCycleIndex().toString(),getOrderboardProgress().toString());
         this.saveFeatureOptionsKey(this.KEY_ACTIVE_DAY_TIMESTAMP,FarmGameUtil.getMidnightTimestamp() / 1000);
         m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_FARMFEST);
         this.saveFeatureOptionsKey(this.KEY_DAILY_REWARD_GRANTED,false);
         this.saveFeatureOptionsKey(this.KEY_DAY_POINTS,0);
         if(this.hasActiveWeekExpired())
         {
            weekData = this.getCurrentWeek();
            this.saveFeatureOptionsKey(this.WEEKLY_SCORE,0);
            this.saveFeatureOptionsKey(KEY_CURRENT_WEEK,weekData.count - 1);
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startnewday",this.onStartNewDayDone,[m_featureName]));
      }
      
      private function onStartNewDayDone(result:Object) : void
      {
         if(this.mainWindow)
         {
            this.mainWindow.refreshWindow();
            this.mainWindow.startTimer();
            this.mainWindow.untintWindow();
            this.mainWindow.enableInput = true;
         }
      }
      
      public function showMainWindow() : void
      {
         var modes:Array = null;
         var mode:GameMode = null;
         var result:GameMode = null;
         if(Global.world.isGameModeActive(GMDecorationPlace))
         {
            modes = Global.world.getActiveGameModes();
            for each(mode in modes)
            {
               if(mode is GMDecorationPlace)
               {
                  result = mode;
                  break;
               }
            }
            Global.world.removeGameMode(result);
            return;
         }
         this.setBoraboraInnovationMainWindowActive(true);
         SERVICE_NAME = m_serviceName;
         startQuest();
         if(!m_initialized)
         {
            this.loadStaticData();
         }
         if(this.m_decos == null)
         {
            this.parseData();
         }
         this.startDecoMode();
      }
      
      public function isBoraboraInnovationMainWindowActive() : Boolean
      {
         return this.getFeatureOptionsKey("BoraboraInnovationMainWindowActive") as Boolean;
      }
      
      public function setBoraboraInnovationMainWindowActive(val:Boolean) : void
      {
         this.saveFeatureOptionsKey("BoraboraInnovationMainWindowActive",val);
      }
      
      public function showOrderboardWindow() : void
      {
         m_orderboardWindow = new BoraBoraInnovationOrderboardWindow(FEATURE_NAME,"assets/dialogs/april_innovation_2020/FV_xbb_Innovation_Orderboard.swf",getInstance(FEATURE_NAME));
         UI.displayPopup(m_orderboardWindow,false);
         FarmStatsManager.count(FEATURE_TRACKING,"orderboardui","open");
      }
      
      public function showLeaderboardUI(showGift:Boolean = false) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         FarmStatsManager.count(FEATURE_TRACKING,"leaderboardui","Click");
         this.m_leaderboardWindow = new BoraBoraInnovationLeaderboardWindow("assets/dialogs/april_innovation_2020/FV_xbb_Innovation_Leaderboard.swf",m_featureName,null,null,showGift);
         UI.displayPopup(this.m_leaderboardWindow,false);
      }
      
      public function showRewardsWindow() : void
      {
         this.m_rewardsWindow = new BoraBoraInnovationFinalRewardsWindow(m_featureName,"assets/dialogs/april_innovation_2020/FV_xbb_Innovation_Rewards.swf",false);
         UI.displayPopup(this.m_rewardsWindow,false);
      }
      
      public function showWorldLoadBBStartWindow() : void
      {
         var BBStartWindow:BoraBoraInnovationWorldLoadStartWindow = new BoraBoraInnovationWorldLoadStartWindow(FEATURE_NAME,"assets/dialogs/april_innovation_2020/FV_xbb_btn_test.swf");
         UI.displayPopup(BBStartWindow,false);
         FarmStatsManager.count(FEATURE_TRACKING,"initialui","open");
      }
      
      public function get currencyName() : String
      {
         return "coco_task_points";
      }
      
      public function startDecoMode() : void
      {
         var viewport:Viewport = null;
         var disableExpansionMarketing:Boolean = false;
         if(Global.player.postInitFinished)
         {
            viewport = GlobalEngine.viewport as Viewport;
            this.m_zoom = viewport.getZoom();
            if(viewport.setZoom(0.483))
            {
            }
            InputManager.disableInput();
            disableExpansionMarketing = true;
            Global.world.createLotBG(true,true,disableExpansionMarketing);
            this.centerOnCall();
         }
      }
      
      public function stopDecoMode() : void
      {
         Global.ui.visible = true;
         UI.suppressPopupQueue = false;
         Global.stage.removeEventListener(KeyboardEvent.KEY_UP,this.onDecoratorModeKeyUp);
         Global.world.createLotBG();
         Global.stage.dispatchEvent(new Event(DecoratorModeManager.CLOSE_EVENT));
         InputManager.enableInput();
      }
      
      private function centerOnCall() : void
      {
         var objects:Array = Global.world.getObjectsByName("bldg_dana");
         var bCentered:Boolean = false;
         var itemInstance:ItemInstance = objects[0] as ItemInstance;
         if(itemInstance != null && itemInstance.getItemName() == "bldg_dana" || itemInstance.getResourceItemName() == "bldg_dana")
         {
            itemInstance.setPosition(93,40,0);
            if(!bCentered)
            {
               this.centerOnObject(objects[0]);
            }
         }
      }
      
      public function centerOnObject(worldObj:WorldObject, duration:Number = 1, upDisplacement:int = 0, centerOnCallback:Function = null) : void
      {
         this.m_centerOnCallback = centerOnCallback;
         if(this.m_scrollTween)
         {
            this.m_scrollTween.complete(true);
            this.m_scrollTween = null;
         }
         var objPos:Vector3 = worldObj.getPosition();
         var params:Object = {
            "startPos":GlobalEngine.viewport.getScrollPosition(),
            "alpha":0
         };
         var viewport:IsoViewport = GlobalEngine.viewport as IsoViewport;
         viewport.centerOnTilePos(93,40);
         params.endPos = GlobalEngine.viewport.getScrollPosition();
         GlobalEngine.viewport.setScrollPosition(params.startPos);
         params.endPos.y += upDisplacement;
         this.m_scrollTween = TweenLite.to(params,duration,{
            "alpha":1,
            "onUpdate":this.onUpdateScrollTween,
            "onUpdateParams":[params],
            "onComplete":this.onCompleteScrollTween
         });
      }
      
      protected function onUpdateScrollTween(params:Object) : void
      {
         var newPos:Vector2 = Vector2.lerp(params.startPos,params.endPos,params.alpha);
         GlobalEngine.viewport.setScrollPosition(newPos);
      }
      
      protected function onCompleteScrollTween() : void
      {
         if(this.m_centerOnCallback != null)
         {
            this.m_centerOnCallback();
            this.m_centerOnCallback = null;
         }
         this.m_scrollTween = null;
         var leaderBoardData:Object = this.getCurrentLeaderboard();
         var currentLeaderboard:String = leaderBoardData.name;
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
            this.openMainUI();
         }
      }
      
      public function openMainUI() : void
      {
         if(!this.hasExpiryDatePassedForFeature())
         {
            this.m_mainWindow = new BoraBoraInnovationMainWindow(FEATURE_NAME,"assets/dialogs/april_innovation_2020/FV_xbb_Innovation.swf",false);
            UI.displayPopup(this.m_mainWindow,false);
            FarmStatsManager.count(FEATURE_TRACKING,"mainui","open");
         }
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
      
      public function onDecoratorModeKeyUp(event:KeyboardEvent) : void
      {
         if(event.keyCode == FarmGameUtil.KEYBOARD_KEY_M)
         {
         }
      }
      
      public function setGameMode(mode:String) : void
      {
         var success:Boolean = false;
         var gm:GameMode = this.m_gameModes[mode];
         if(gm != null)
         {
            Global.world.addGameMode(gm);
            success = Global.world.acquireDefaultGameMode(gm,this);
            if(!success)
            {
               throw new Error("Decorator Mode Manager - Could not acquire lock on default Game Mode when setting Game Mode");
            }
         }
      }
      
      public function initializeLeaderBoardProgress(isSync:Boolean = false) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getLeaderboardEntries",this.getLeaderboardEntries,[m_featureName,isSync]));
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
            if(Boolean(this.m_mainWindow) && Boolean(result["userData"]) && result["userData"]["value"] > 0)
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
      
      public function getLeaderboardData() : Array
      {
         if(this.m_staticData)
         {
            return this.m_staticData.leaderboardConfigData;
         }
         return null;
      }
      
      public function getCurrentLeaderboard() : Object
      {
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
      
      public function hasExpiryDatePassedForFeature() : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("06/01/2020") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         timeLeft = endTime - now;
         if(timeLeft <= 0)
         {
            result = true;
         }
         return result;
      }
      
      public function getUserZid() : String
      {
         return this.m_zid;
      }
      
      public function getWeeklyLeaderboardPoints() : int
      {
         var leaderboardPoints:int = 0;
         return this.getFeatureOptionsKey(this.WEEKLY_SCORE) as int;
      }
      
      public function get currentWeekIndex() : int
      {
         var weekIndex:int = 0;
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("04/20/2020");
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
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("04/20/2020") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         dayIndex = (activeDayTS - featureStartDayTS) / FarmGameUtil.NUM_SECS_IN_DAY;
         if(dayIndex < 0)
         {
            dayIndex = 0;
         }
         return dayIndex;
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
      
      public function checkLastDayInWeek() : int
      {
         var days:int = 0;
         var result:Number = this.getTimeLeftInWeek();
         if(result < 0)
         {
            result = 0;
         }
         var timeLeftArray:Array = FarmGameUtil.parseTimeLeft(result);
         if(Boolean(timeLeftArray) && timeLeftArray.length > 3)
         {
            days = int(timeLeftArray[0]);
         }
         return days;
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
      
      public function getActiveDayIndex() : int
      {
         var dayIndex:int = 0;
         var activeDayTS:Number = this.getFeatureOptionsKey(this.KEY_ACTIVE_DAY_TIMESTAMP) as int;
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("04/20/2020") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         dayIndex = (activeDayTS - featureStartDayTS) / FarmGameUtil.NUM_SECS_IN_DAY;
         if(dayIndex < 0)
         {
            dayIndex = 0;
         }
         return dayIndex;
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
      
      public function getTimeLeftInDay() : Number
      {
         var dayExpiredTime:Number = this.getFeatureOptionsKey(this.KEY_ACTIVE_DAY_TIMESTAMP) + 86400;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return dayExpiredTime - currenttime;
      }
      
      public function getFeatureEndDaysLeftText() : String
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var days:int = 0;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("06/01/2020");
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
      
      public function getFeatureTimeLeft() : String
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("06/01/2020");
         timeLeft = (endTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return HUD.getformattedTimeLeft(timeLeft) + " Remaining!";
      }
      
      public function getCurrentWeek() : Object
      {
         var weekXML:XML = null;
         if(this.hasExpiryDatePassedForFeature())
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
      
      public function getWeeksArray() : Array
      {
         return this.m_staticData.weeks;
      }
      
      public function getNewDailyReward() : FarmItem
      {
         var rewardItem:FarmItem = null;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("04/20/2020") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var dayIndex:int = (currenttime - featureStartDayTS) / FarmGameUtil.NUM_SECS_IN_DAY;
         if(this.m_dailyRewards.hasOwnProperty(dayIndex.toString()))
         {
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_dailyRewards[dayIndex]);
         }
         return rewardItem;
      }
      
      public function grantDailyReward() : void
      {
         var rewardItem:FarmItem = null;
         var itemsTwentiesTime:Array = null;
         var count:int = 0;
         var i:int = 0;
         if(this.getDayPoints() >= this.MAX_DAILY_LIMIT && this.getFeatureOptionsKey(this.KEY_DAILY_REWARD_GRANTED) == false)
         {
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_dailyRewards[this.currentDayIndex]);
            if(rewardItem)
            {
               itemsTwentiesTime = new Array("xbb_woodtwistfence","xbb_surfnturffence","xbb_floralcoastfence","xbb_ropebeachfence","xbb_pastelfence","xbb_bronzegatefence");
               count = 1;
               for(i = 0; i < itemsTwentiesTime.length; i++)
               {
                  if(itemsTwentiesTime[i] == this.m_dailyRewards[this.currentDayIndex])
                  {
                     count = 20;
                     break;
                  }
               }
               Global.player.addGift(rewardItem.name,"",count);
               UI.displayPopup(new BoraBoraInnovationDailyRewardPopup("assets/dialogs/april_innovation_2020/FV_xbb_daily_reward.swf",m_featureName,rewardItem,null,false),false);
               this.saveFeatureOptionsKey(this.KEY_DAILY_REWARD_GRANTED,true);
               FarmStatsManager.count(FEATURE_TRACKING,"daily",rewardItem.name,this.currentDayIndex.toString());
               StatsManager.count(FEATURE_TRACKING,"leaderboard",this.currentDayIndex.toString(),"start",this.getCurrentThumbsUp().toString());
            }
         }
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
      
      private function parseData() : void
      {
         var deco:XML = null;
         var receptionDecos:Array = null;
         var extraDecos:Array = null;
         var basicItem:String = null;
         var basicItemD:String = null;
         var basicTotal:int = 0;
         var basictThumbs:int = 0;
         var basicFc:int = 0;
         var basicEA:Boolean = false;
         var receptionItem:String = null;
         var receptionItemD:String = null;
         var receptionTotal:int = 0;
         var receptionThumbs:int = 0;
         var receptionFc:int = 0;
         var receptionEA:Boolean = false;
         var extraItem:String = null;
         var extraItemD:String = null;
         var extraTotal:int = 0;
         var extraThumbs:int = 0;
         var extraFc:int = 0;
         var extraEA:Boolean = false;
         this.m_decos = {};
         var cycleIndex:int = this.getFeatureOptionsKey(this.CYCLE_INDEX) as int;
         var cyclesData:XML = Global.farmGameSettingsManager.getXML().BoraboraInnovationData.CyclesData[0];
         var cycles:XMLList = cyclesData.Cycle;
         var cycle:XML = cycles[cycleIndex];
         var basicDecos:Array = new Array();
         var decos:XMLList = cycle.BasicDecos.deco;
         for each(deco in decos)
         {
            basicItem = deco.@item.toString();
            basicItemD = deco.@itemD.toString();
            basicTotal = int(deco.@total);
            basictThumbs = int(deco.@thumbs);
            basicFc = 0;
            basicEA = false;
            if(deco.hasOwnProperty("@fc"))
            {
               basicFc = int(deco.@fc);
            }
            if(m_isEA)
            {
               basicEA = true;
            }
            basicDecos.push({
               "item":basicItem,
               "itemD":basicItemD,
               "total":basicTotal,
               "thumbs":basictThumbs,
               "fc":basicFc,
               "ea":basicEA
            });
         }
         receptionDecos = new Array();
         decos = cycle.ReceptionDecos.deco;
         for each(deco in decos)
         {
            receptionItem = deco.@item.toString();
            receptionItemD = deco.@itemD.toString();
            receptionTotal = int(deco.@total);
            receptionThumbs = int(deco.@thumbs);
            receptionFc = 0;
            receptionEA = false;
            if(deco.hasOwnProperty("@fc"))
            {
               receptionFc = int(deco.@fc);
            }
            if(m_isEA)
            {
               receptionEA = true;
            }
            receptionDecos.push({
               "item":receptionItem,
               "itemD":receptionItemD,
               "total":receptionTotal,
               "thumbs":receptionThumbs,
               "fc":receptionFc,
               "ea":receptionEA
            });
         }
         extraDecos = new Array();
         decos = cycle.ExtraDecos.deco;
         for each(deco in decos)
         {
            extraItem = deco.@item.toString();
            extraItemD = deco.@itemD.toString();
            extraTotal = int(deco.@total);
            extraThumbs = int(deco.@thumbs);
            extraFc = 0;
            extraEA = false;
            if(deco.hasOwnProperty("@fc"))
            {
               extraFc = int(deco.@fc);
            }
            if(m_isEA)
            {
               extraEA = true;
            }
            extraDecos.push({
               "item":extraItem,
               "itemD":extraItemD,
               "total":extraTotal,
               "thumbs":extraThumbs,
               "fc":extraFc,
               "ea":extraEA
            });
         }
         this.m_decos = {
            "basicDecos":basicDecos,
            "receptionDecos":receptionDecos,
            "extraDecos":extraDecos
         };
      }
      
      public function getBasicPanelData() : Array
      {
         return this.m_decos["basicDecos"];
      }
      
      public function getReceptionPanelData() : Array
      {
         return this.m_decos["receptionDecos"];
      }
      
      public function getExtraPanelData() : Array
      {
         return this.m_decos["extraDecos"];
      }
      
      public function getMilestoneRewards() : Array
      {
         return this.m_milestoneRewards;
      }
      
      public function getCurrentThumbsUp() : int
      {
         return this.getFeatureOptionsKey(KEY_THUMBSUP_POINTS) as int;
      }
      
      public function getCurrentStarCount() : int
      {
         return this.getFeatureOptionsKey(this.KEY_STAR_POINTS) as int;
      }
      
      public function getDayPoints() : int
      {
         return this.getFeatureOptionsKey(this.KEY_DAY_POINTS) as int;
      }
      
      public function get currentMilestoneCount() : int
      {
         return this.getFeatureOptionsKey(this.KEY_MILESTONES_EARNED) as int;
      }
      
      public function getTotalStars() : int
      {
         return this.getFeatureOptionsKey(this.KEY_TOTAL_STAR_POINTS) as int;
      }
      
      public function getNextMilestoneData() : Object
      {
         var result:Object = {};
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_milestoneRewards[this.currentMilestoneCount]);
         if(rewardItem)
         {
            result["icon"] = rewardItem.iconUrl;
            result["starCount"] = this.m_starsRequired[this.currentMilestoneCount];
            result["rewardName"] = rewardItem.friendlyTitle;
         }
         return result;
      }
      
      public function getStarsForMilestoneReward(slotNumber:int) : int
      {
         return this.m_starsRequired[slotNumber];
      }
      
      public function onBuyDecoUtil(item:FarmItem) : void
      {
         item.onUse();
         IdleTaskQueue.getInstance().addTask(new BoraboraWindowReopenIdleTask());
         this.itemPlaceClose();
      }
      
      private function itemPlaceClose() : void
      {
         if(this.mainWindow)
         {
            this.mainWindow.close();
         }
      }
      
      public function updateItemCountMapping(itemCode:String) : void
      {
         var itemToCountMapping:Object = this.getFeatureOptionsKey(this.ITEM_COUNT_MAPPING);
         if(itemCode == "2m7c" && !Global.player.setSeenFlag("bbiShown"))
         {
            Global.player.setSeenFlag("bbiShown");
         }
         this.saveFeatureOptionsKey("npcWarning",itemCode);
         var isFCItem:int = this.isItemBuyByFc(itemCode);
         if(isFCItem != -1)
         {
            if(Global.player.canBuyCash(isFCItem))
            {
               Global.player.cash -= isFCItem;
               itemToCountMapping[itemCode] += 1;
               this.saveFeatureOptionsKey(this.ITEM_COUNT_MAPPING,itemToCountMapping);
               this.grantThumbsForDeco(itemCode);
               FarmStatsManager.count(FEATURE_TRACKING,"buy marriage deco",itemCode,this.getCurrentThumbsUp().toString(),this.getCycleIndex().toString(),getOrderboardProgress().toString(),this.getTotalStars());
            }
         }
         else if(this.isEnoughBoraboraMoneyToBuyDeco(itemCode))
         {
            itemToCountMapping[itemCode] += 1;
            this.saveFeatureOptionsKey(this.ITEM_COUNT_MAPPING,itemToCountMapping);
            this.deductBoraboraMoneyToBuyDeco(itemCode);
            this.grantThumbsForDeco(itemCode);
            FarmStatsManager.count(FEATURE_TRACKING,"buy marriage deco",itemCode,this.getCurrentThumbsUp().toString(),this.getCycleIndex().toString(),getOrderboardProgress().toString(),this.getTotalStars());
         }
      }
      
      private function deductBoraboraMoneyToBuyDeco(item:String) : void
      {
         var boraboraMoney:int = this.getFeatureOptionsKey(KEY_ORDERBOARD_TASK_POINTS) as int;
         var boraboraMoneyForDeco:int = this.getBoraboraMoneyRequiredForDeco(item);
         this.saveFeatureOptionsKey(KEY_ORDERBOARD_TASK_POINTS,boraboraMoney - boraboraMoneyForDeco);
      }
      
      private function isEnoughBoraboraMoneyToBuyDeco(item:String) : Boolean
      {
         var boraboraMoney:int = this.getFeatureOptionsKey(KEY_ORDERBOARD_TASK_POINTS) as int;
         var boraboraMoneyForDeco:int = this.getBoraboraMoneyRequiredForDeco(item);
         return boraboraMoney >= boraboraMoneyForDeco;
      }
      
      public function getBoraboraMoneyRequiredForDeco(item:String) : int
      {
         var key:String = null;
         var tempDecos:Array = null;
         var index:int = 0;
         if(this.m_decos == null)
         {
            this.parseData();
         }
         for(key in this.m_decos)
         {
            tempDecos = this.m_decos[key];
            for(index = 0; index < tempDecos.length; index++)
            {
               if(tempDecos[index]["item"] == item)
               {
                  return tempDecos[index]["total"];
               }
            }
         }
         return -1;
      }
      
      public function updateStars(thumbs:int) : void
      {
         var totalStar:int = 0;
         var thumbsPerStar:Array = null;
         this.saveFeatureOptionsKey(this.KEY_SHOW_MILESTONE_POPUP,false);
         var currentStar:int = this.getCurrentStarCount();
         if(this.isUserEA)
         {
            thumbsPerStar = this.m_thumbsPerStarEA;
         }
         else
         {
            thumbsPerStar = this.m_thumbsPerStarGA;
         }
         var starCount:int = 0;
         for(var i:int = 1; i < thumbsPerStar.length; i++)
         {
            if(thumbs >= thumbsPerStar[i])
            {
               starCount += 1;
            }
         }
         if(starCount > currentStar)
         {
            this.saveFeatureOptionsKey(this.KEY_TOTAL_STAR_POINTS,(this.getFeatureOptionsKey(this.KEY_TOTAL_STAR_POINTS) as int) + 1);
            totalStar = this.getTotalStars();
            if(this.m_starrewards_map.hasOwnProperty(totalStar.toString()))
            {
               this.saveFeatureOptionsKey(this.KEY_SHOW_MILESTONE_POPUP,true);
               Global.player.addGift(this.m_starrewards_map[totalStar]);
               this.saveFeatureOptionsKey(this.KEY_MILESTONES_EARNED,this.currentMilestoneCount + 1);
            }
            if(this.isUserEA && starCount == 7 || !this.isUserEA && starCount == 5)
            {
               this.saveFeatureOptionsKey(this.KEY_TOTAL_STAR_POINTS,(this.getFeatureOptionsKey(this.KEY_TOTAL_STAR_POINTS) as int) + 1);
               totalStar = this.getTotalStars();
               if(this.m_starrewards_map.hasOwnProperty(totalStar.toString()))
               {
                  this.saveFeatureOptionsKey(this.KEY_SHOW_MILESTONE_POPUP,true);
                  Global.player.addGift(this.m_starrewards_map[totalStar]);
                  this.saveFeatureOptionsKey(this.KEY_MILESTONES_EARNED,this.currentMilestoneCount + 1);
               }
            }
            if(totalStar == 10 || totalStar == 30 || totalStar == 45 || totalStar == 130)
            {
               Global.player.addGift("pkg_xbb_farmessentials_pack");
            }
            if(totalStar > 170)
            {
               this.saveFeatureOptionsKey(this.KEY_SHOW_MILESTONE_POPUP,false);
            }
         }
         this.saveFeatureOptionsKey(this.KEY_STAR_POINTS,starCount);
      }
      
      public function showMilestoneRewardPopup() : void
      {
         if(this.mainWindow)
         {
            this.mainWindow.tintWindow();
            this.mainWindow.enableInput = false;
         }
         this.saveFeatureOptionsKey(this.KEY_SHOW_MILESTONE_POPUP,false);
         var totalStars:int = this.getTotalStars();
         var starReward:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_starrewards_map[totalStars]);
         var isConsumable:Boolean = false;
         if(totalStars == 10 || totalStars == 30 || totalStars == 45 || totalStars == 130)
         {
            isConsumable = true;
         }
         this.m_milastoneRewardPopup = new BoraBoraInnovationSingleRewardPopup("assets/dialogs/april_innovation_2020/FV_xbb_mile_reward.swf",m_featureName,starReward,this.onMilestoneRewardShare(starReward),true,isConsumable);
         UI.displayPopup(this.m_milastoneRewardPopup,false);
         FarmStatsManager.count(FEATURE_TRACKING,"Milestone",totalStars.toString(),starReward.name,totalStars.toString());
      }
      
      public function isShowMilestonePopup() : Boolean
      {
         return this.getFeatureOptionsKey(this.KEY_SHOW_MILESTONE_POPUP) as Boolean;
      }
      
      private function grantThumbsForDeco(item:String) : void
      {
         var thumbs:int = this.getThumbsForDeco(item);
         var totalThumbs:int = (this.getFeatureOptionsKey(KEY_THUMBSUP_POINTS) as int) + thumbs;
         this.saveFeatureOptionsKey(KEY_THUMBSUP_POINTS,totalThumbs);
         this.saveFeatureOptionsKey(this.WEEKLY_SCORE,(this.getFeatureOptionsKey(this.WEEKLY_SCORE) as int) + thumbs);
         this.saveFeatureOptionsKey(this.KEY_DAY_POINTS,this.getDayPoints() + thumbs);
         this.updateStars(totalThumbs);
      }
      
      private function getThumbsForDeco(item:String) : int
      {
         var key:String = null;
         var tempDecos:Array = null;
         var index:int = 0;
         if(this.m_decos == null)
         {
            this.parseData();
         }
         for(key in this.m_decos)
         {
            tempDecos = this.m_decos[key];
            for(index = 0; index < tempDecos.length; index++)
            {
               if(tempDecos[index]["item"] == item)
               {
                  return tempDecos[index]["thumbs"];
               }
            }
         }
         return -1;
      }
      
      private function isItemBuyByFc(item:String) : int
      {
         var key:String = null;
         var tempDecos:Array = null;
         var index:int = 0;
         if(this.m_decos == null)
         {
            this.parseData();
         }
         for(key in this.m_decos)
         {
            tempDecos = this.m_decos[key];
            for(index = 0; index < tempDecos.length; index++)
            {
               if(tempDecos[index]["item"] == item)
               {
                  if(tempDecos[index]["fc"] == 0)
                  {
                     return -1;
                  }
                  return tempDecos[index]["fc"];
               }
            }
         }
         return -1;
      }
      
      public function getBoraboraMoney() : int
      {
         return getOrderboardProgress();
      }
      
      public function refreshDecoPanels() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.m_basicPanelFrame.refresh();
            this.m_mainWindow.m_decorPanelFrame.refresh();
            this.m_mainWindow.m_specialPanelFrame.refresh();
         }
      }
      
      public function refreshBoraboraMoney() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.refreshBoraboraMoney();
         }
      }
      
      public function showNewCycleStartWindow() : void
      {
         if(this.mainWindow)
         {
            this.mainWindow.tintWindow();
            this.mainWindow.enableInput = false;
         }
         this.m_newCycleStartWindow = new BoraBoraInnovationNewCycleStartWindow(FEATURE_NAME,"assets/dialogs/april_innovation_2020/FV_xbb_Cycle_Start.swf");
         UI.displayPopup(this.m_newCycleStartWindow,false);
         FarmStatsManager.count(FEATURE_TRACKING,"newCycleStart","open");
      }
      
      public function setCycleStartEntry() : void
      {
         this.saveFeatureOptionsKey(this.KEY_CYCLE_START_ENTRY,true);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startCyclePopUP",null,new Array(FEATURE_NAME)),true);
      }
      
      public function isCycleStartPopUp() : Boolean
      {
         return this.getFeatureOptionsKey(this.KEY_CYCLE_START_ENTRY) as Boolean;
      }
      
      public function showScreenShotWindow() : void
      {
         if(this.mainWindow)
         {
            this.mainWindow.tintWindow();
            this.mainWindow.enableInput = false;
         }
         this.m_screenShotWindow = new BoraBoraInnovationScreenshotPopUp(FEATURE_NAME,"assets/dialogs/april_innovation_2020/FV_xbb_Screenshot_Popup.swf");
         UI.displayPopup(this.m_screenShotWindow,false);
         FarmStatsManager.count(FEATURE_TRACKING,"screenshotPopUp","open");
      }
      
      public function showStageCompleteWindow(stage:int) : void
      {
         if(this.mainWindow)
         {
            this.mainWindow.tintWindow();
            this.mainWindow.enableInput = false;
         }
         this.m_stageCompleteWindow = new BoraboraInnovationStageComplete(FEATURE_NAME,"assets/dialogs/april_innovation_2020/FV_xbb_Stage_Complete.swf",stage);
         UI.displayPopup(this.m_stageCompleteWindow,false);
         FarmStatsManager.count(FEATURE_TRACKING,"StageComplete","open");
      }
      
      public function showUnlimitedCycleStartPopupWindow() : void
      {
         if(this.mainWindow)
         {
            this.mainWindow.tintWindow();
            this.mainWindow.enableInput = false;
         }
         this.m_unlimitedCycleStartWindow = new BoraboraInnovationUnlimitedCycleStartWindow(FEATURE_NAME,"assets/dialogs/april_innovation_2020/FV_xbb_Cycle_Repeat.swf");
         UI.displayPopup(this.m_unlimitedCycleStartWindow,false);
         FarmStatsManager.count(FEATURE_TRACKING,"unlimitedCycle","open");
      }
      
      public function isDecorStageLocked() : int
      {
         return this.getFeatureOptionsKey(this.KEY_STAGE1) as int;
      }
      
      public function isSpecialrStageLocked() : int
      {
         return this.getFeatureOptionsKey(this.KEY_STAGE2) as int;
      }
      
      public function setDecorStage() : void
      {
         this.saveFeatureOptionsKey(this.KEY_STAGE1,1);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"setDecorStage",null,new Array(FEATURE_NAME)),true);
      }
      
      public function setSpecialStage() : void
      {
         this.saveFeatureOptionsKey(this.KEY_STAGE2,1);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"setSpecialStage",null,new Array(FEATURE_NAME)),true);
      }
      
      public function deleteDecos() : void
      {
         var key:String = null;
         var tempDecos:Array = null;
         var index:int = 0;
         var objects:Array = null;
         var i:int = 0;
         for(key in this.m_decos)
         {
            tempDecos = this.m_decos[key];
            for(index = 0; index < tempDecos.length; index++)
            {
               objects = Global.world.getObjectsByCode(tempDecos[index]["item"]);
               for(i = 0; i < objects.length; i++)
               {
                  objects[i].detach();
               }
            }
         }
      }
      
      public function grantCycleFinishDecos() : void
      {
         var key:String = null;
         var tempDecos:Array = null;
         var index:int = 0;
         var farmItem:FarmItem = null;
         var itemToCountMapping:Object = this.getFeatureOptionsKey(this.ITEM_COUNT_MAPPING);
         for(key in this.m_decos)
         {
            tempDecos = this.m_decos[key];
            for(index = 0; index < tempDecos.length; index++)
            {
               if(itemToCountMapping[tempDecos[index]["item"]] > 0)
               {
                  farmItem = Global.farmGameSettingsManager.getFarmItemByCode(tempDecos[index]["itemD"]);
                  Global.player.addGift(farmItem.name,"",itemToCountMapping[tempDecos[index]["item"]]);
               }
            }
         }
      }
      
      private function startNewCycle() : void
      {
         this.grantCycleFinishDecos();
         this.deleteDecos();
         this.reSetNPCSFlag();
         this.saveFeatureOptionsKey(this.KEY_WEDDING_TIME,FarmGameUtil.getMidnightTimestamp() / 1000);
         this.saveFeatureOptionsKey(this.KEY_STAGE1,0);
         this.saveFeatureOptionsKey(this.KEY_STAGE2,0);
         this.saveFeatureOptionsKey(this.KEY_CYCLE_START_ENTRY,false);
         this.increaseCycleIndex();
         var cycleIndex:int = this.getFeatureOptionsKey(this.CYCLE_INDEX) as int;
         this.generateItemToCountMapping(cycleIndex);
         this.saveFeatureOptionsKey(KEY_THUMBSUP_POINTS,0);
         this.saveFeatureOptionsKey(this.KEY_STAR_POINTS,0);
         this.saveFeatureOptionsKey(KEY_TOTAL_BORABORAMONEY,this.getFeatureOptionsKey(KEY_ORDERBOARD_TASK_POINTS));
         this.setPanelDisplayValue(0);
         this.updateNPCIndex();
      }
      
      public function updateNPCIndex() : void
      {
         var npcIndex:int = this.getFeatureOptionsKey(this.NPC_INDEX) as int;
         if(npcIndex >= 97)
         {
            this.saveFeatureOptionsKey(this.NPC_INDEX,0);
         }
         else
         {
            this.saveFeatureOptionsKey(this.NPC_INDEX,npcIndex + 1);
         }
      }
      
      private function generateItemToCountMapping(cycleIndex:int) : void
      {
         var deco:XML = null;
         var basicItem:String = null;
         var receptionItem:String = null;
         var extraItem:String = null;
         this.parseData();
         var itemToCountMapping:Object = {};
         var cyclesData:XML = Global.farmGameSettingsManager.getXML().BoraboraInnovationData.CyclesData[0];
         var cycles:XMLList = cyclesData.Cycle;
         var cycle:XML = cycles[cycleIndex];
         var decos:XMLList = cycle.BasicDecos.deco;
         for each(deco in decos)
         {
            basicItem = deco.@item.toString();
            itemToCountMapping[basicItem] = 0;
         }
         decos = cycle.ReceptionDecos.deco;
         for each(deco in decos)
         {
            receptionItem = deco.@item.toString();
            itemToCountMapping[receptionItem] = 0;
         }
         decos = cycle.ExtraDecos.deco;
         for each(deco in decos)
         {
            extraItem = deco.@item.toString();
            itemToCountMapping[extraItem] = 0;
         }
         this.saveFeatureOptionsKey(this.ITEM_COUNT_MAPPING,itemToCountMapping);
      }
      
      public function cycleEndWindow(lastShown:Boolean = false) : void
      {
         if(this.mainWindow)
         {
            this.mainWindow.tintWindow();
            this.mainWindow.enableInput = false;
         }
         this.m_cycleEndWindow = new BoraBoraInnovationCycleEndWindow(FEATURE_NAME,"assets/dialogs/april_innovation_2020/FV_xbb_Cycle_Complete.swf",lastShown);
         UI.displayPopup(this.m_cycleEndWindow,false);
         FarmStatsManager.count(FEATURE_TRACKING,"cycleend",this.getCurrentThumbsUp().toString(),this.getTotalStars().toString(),this.getCycleIndex().toString(),getOrderboardProgress().toString());
      }
      
      public function getTotalUniqueDecoGranted() : int
      {
         var key:String = null;
         var total:int = 0;
         var itemToCountMapping:Object = this.getFeatureOptionsKey(this.ITEM_COUNT_MAPPING);
         for(key in itemToCountMapping)
         {
            if(itemToCountMapping[key] > 0)
            {
               total++;
            }
         }
         return total;
      }
      
      public function getStarRating() : String
      {
         var thumbsPerStar:Array = null;
         var thumbs:int = this.getFeatureOptionsKey(KEY_THUMBSUP_POINTS) as int;
         if(this.isUserEA)
         {
            thumbsPerStar = this.m_thumbsPerStarEA;
         }
         else
         {
            thumbsPerStar = this.m_thumbsPerStarGA;
         }
         var starCount:int = 0;
         var index:int = 0;
         for(var i:int = 1; i < thumbsPerStar.length; i++)
         {
            if(thumbs >= thumbsPerStar[i])
            {
               starCount += 1;
               index += 1;
            }
         }
         if(index == 0)
         {
            return "0/" + (thumbsPerStar.length - 1).toString();
         }
         if(index == thumbsPerStar.length - 1)
         {
            return (thumbsPerStar.length - 1).toString() + "/" + (thumbsPerStar.length - 1).toString();
         }
         var remainStar:Number = (thumbs - thumbsPerStar[index]) / (thumbsPerStar[index + 1] - thumbsPerStar[index]);
         return (starCount + Math.round(remainStar * 10) / 10).toString() + "/" + (thumbsPerStar.length - 1).toString();
      }
      
      public function newCycleStartActions() : void
      {
         this.startNewCycle();
         if(this.mainWindow)
         {
            this.m_mainWindow.refreshDecoPlanel();
            this.m_mainWindow.refreshNPCNamesImages();
            this.m_mainWindow.weddingCycleRefresh();
            this.m_mainWindow.updateStarProgress(false);
            this.m_mainWindow.refreshBoraboraMoney();
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startNewCycle",null,new Array(FEATURE_NAME)),true);
         FarmStatsManager.count(FEATURE_TRACKING,"cyclestart",this.currentDayIndex.toString(),"",this.getCycleIndex().toString(),getOrderboardProgress().toString());
         if(this.mainWindow)
         {
            this.mainWindow.close();
            this.showMainWindow();
         }
      }
      
      public function getTimeLeftForBonusHarvest(itemName:String) : int
      {
         var key:String = itemName + this.LAST_HARVEST_TIME_KEY;
         var throttleTime:int = DEFAULT_HARVEST_THROTTLE_TIME;
         return getTimeLeft(key,throttleTime);
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
         var flag2:Boolean = false;
         var featureKey:String = null;
         var key:String = buildingName + this.LAST_HARVEST_TIME_KEY;
         Global.player.setFeatureLastShown(key,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         var harvestRewardName:String = this.getNextHarvestItemName(buildingName);
         var harvestFarmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(harvestRewardName);
         if(harvestFarmItem)
         {
            flag2 = false;
            if(buildingName == "xbb_weddingsalon")
            {
               Global.player.addGift(harvestRewardName,"",2);
               flag2 = true;
            }
            else
            {
               Global.player.addGift(harvestRewardName);
            }
            featureKey = m_featureName + this.LAST_HARVEST_TIME_KEY;
            FarmStatsManager.count(m_featureName,"Harvest",buildingName,harvestRewardName);
            UI.displayPopup(new GenericSingleRewardPopup(this.REWARD_POPUP_WINDOW,"xbb_Bonus_",harvestFarmItem,null,this.REWARD_WINDOW_IMAGE,flag2),false);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,SERVICE_FUNC_HARVEST_BONUS,null,[m_featureName,buildingName]),true);
         }
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
         var bonusStartTime:Number = this.getFeatureOptionsKey(this.KEY_BONUS_HARVEST_START_TIME) as Number;
         if(bonusStartTime)
         {
            if(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - bonusStartTime < 13 * 86400)
            {
               isStillHarvestable = true;
            }
         }
         return isStillHarvestable;
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
         if(result)
         {
            this.cycleEndWindow(true);
            finalDeco = 0;
            if(result.hasOwnProperty("none"))
            {
               Global.player.addGift("pkg_xbb_farmessentials_pack");
            }
            else if(result.hasOwnProperty("badge"))
            {
               Global.player.addGift(result["badge"]);
               finalDeco = 1;
            }
            else
            {
               Global.player.addGift(result["badge1"]);
               Global.player.addGift(result["badge2"]);
               Global.player.addGift(result["badge3"]);
               Global.player.addGift(result["badge4"]);
               finalDeco = 2;
            }
            if(finalDeco === 0)
            {
               this.showInventionRewardPopup("pkg_xbb_farmessentials_pack",false);
               StatsManager.count(FEATURE_TRACKING,"grantBuilding","pkg_xbb_farmessentials_pack","","",this.getTotalStars().toString());
            }
            else if(finalDeco == 1)
            {
               this.showInventionRewardPopup(result["badge"]);
               StatsManager.count(FEATURE_TRACKING,"grantBuilding",result["badge"].toString(),"","",this.getTotalStars().toString());
            }
            else if(finalDeco == 2)
            {
               this.showInventionRewardPopup("xbb_threebuilding");
               StatsManager.count(FEATURE_TRACKING,"grantBuilding","xbb_threebuilding","","",this.getTotalStars().toString());
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
            Global.hud.removeBottomHudBoraBoraInnovationButton();
         }
      }
      
      public function showInventionRewardPopup(rewardName:String, isReward:Boolean = true) : void
      {
         var featureKey:String = m_featureName + "_inventionReward";
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
         if(isReward)
         {
            this.m_InventionRewardPopup = new BoraBoraInnovationFeatureEndWindow("assets/dialogs/april_innovation_2020/FV_xbb_final_reward.swf",featureKey,rewardItem,this.postInventionShare(rewardItem),this.REWARD_WINDOW_IMAGE);
         }
         else
         {
            this.m_InventionRewardPopup = new BoraBoraInnovationFeatureEndWindow("assets/dialogs/april_innovation_2020/FV_xbb_final_reward.swf",featureKey,rewardItem,this.postInventionShare(rewardItem),this.REWARD_WINDOW_IMAGE);
         }
         UI.displayPopup(this.m_InventionRewardPopup,false);
      }
      
      public function postInventionShare(rewardItem:FarmItem) : Function
      {
         return function(event:Event):void
         {
            var windowName:* = FEATURE_NAME;
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
      
      public function onMilestoneRewardShare(rewardItem:FarmItem) : Function
      {
         return function(event:Event):void
         {
            var windowName:* = FEATURE_NAME;
            var bundleId:* = windowName + "MilestoneShare";
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
            if(m_milastoneRewardPopup)
            {
               m_milastoneRewardPopup.close();
            }
         };
      }
      
      public function get thumbsUps() : int
      {
         return this.getFeatureOptionsKey(KEY_THUMBSUP_POINTS) as int;
      }
      
      public function isEnoughBoraboraMoney() : Boolean
      {
         var maxBorabora:int = this.getFeatureOptionsKey(KEY_TOTAL_BORABORAMONEY) as int;
         return maxBorabora >= this.MAX_CYCLE_BORABORA_LIMIT;
      }
      
      public function getMaxTotalBoraboraMoney() : int
      {
         return this.getFeatureOptionsKey(KEY_TOTAL_BORABORAMONEY) as int;
      }
      
      public function getCycleNPCNames(countFlag:Boolean = false) : String
      {
         var npcIndex:int = this.getFeatureOptionsKey(this.NPC_INDEX) as int;
         if(countFlag)
         {
            npcIndex++;
         }
         npcIndex %= 97;
         return this.m_npcBrideNames[npcIndex] + " & " + this.m_npcGroomNames[npcIndex];
      }
      
      public function getCycleStartNPCImage() : String
      {
         if(!Global.player.getSeenFlag("bb_npc_images_tutorial"))
         {
            Global.player.setSeenFlag("bb_npc_images_tutorial");
            return this.m_npcImages[0];
         }
         var npcIndex:int = this.getFeatureOptionsKey(this.CYCLE_INDEX) as int;
         npcIndex = ++npcIndex % 6;
         return this.m_npcImages[npcIndex];
      }
      
      public function getCycleNames() : String
      {
         var npcIndex:int = (this.getFeatureOptionsKey(this.CYCLE_INDEX) as int) % 6;
         return this.m_cycleNames[npcIndex];
      }
      
      public function getCycleNPCImage() : String
      {
         var npcIndex:int = (this.getFeatureOptionsKey(this.CYCLE_INDEX) as int) % 6;
         return this.m_npcImages[npcIndex];
      }
      
      public function getCycleNPCBrideImage() : String
      {
         var npcIndex:int = (this.getFeatureOptionsKey(this.CYCLE_INDEX) as int) % 6;
         return this.m_npcBrideImages[npcIndex];
      }
      
      public function getCycleNPCGroomImage() : String
      {
         var npcIndex:int = (this.getFeatureOptionsKey(this.CYCLE_INDEX) as int) % 6;
         return this.m_npcGroomImages[npcIndex];
      }
      
      public function getCycleIndex() : int
      {
         return this.getFeatureOptionsKey(this.CYCLE_INDEX) as int;
      }
      
      public function getCycleEndSubtext() : String
      {
         var npcIndex:int = (this.getFeatureOptionsKey(this.CYCLE_INDEX) as int) % 6;
         if(Global.player.getSeenFlag("bb_unlimited_cycle"))
         {
            return this.m_unlimitedCycleEndSubtext[npcIndex];
         }
         return this.m_cycleEndSubtext[npcIndex];
      }
      
      public function getCycleStartSubtext(countFlag:Boolean = false) : String
      {
         var npcIndex:int = this.getFeatureOptionsKey(this.CYCLE_INDEX) as int;
         if(countFlag)
         {
            npcIndex++;
         }
         npcIndex %= 6;
         if(Global.player.getSeenFlag("bb_unlimited_cycle"))
         {
            return this.m_unlimitedCycleStartSubtext[npcIndex];
         }
         return this.m_cycleStartSubtext[npcIndex];
      }
      
      public function getCycleEndChairCode() : String
      {
         var chairCodes:Array = new Array("2m7c","2mby","2mam","2m14","2men","2my6");
         var npcIndex:int = (this.getFeatureOptionsKey(this.CYCLE_INDEX) as int) % 6;
         return chairCodes[npcIndex];
      }
      
      public function increaseCycleIndex() : void
      {
         var cycleIndex:int = (this.getFeatureOptionsKey(this.CYCLE_INDEX) as int) % 6;
         if(++cycleIndex == this.MAX_CYCLE)
         {
            cycleIndex = 0;
         }
         this.saveFeatureOptionsKey(this.CYCLE_INDEX,cycleIndex);
      }
      
      public function getCycleTimeLeftUtil() : Number
      {
         var dayExpiredTime:Number = this.getFeatureOptionsKey(this.KEY_WEDDING_TIME) + 7 * 86400;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return dayExpiredTime - currenttime;
      }
      
      public function isCycleTimerMaxToEndCycle() : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var dayExpiredTime:Number = this.getFeatureOptionsKey(this.KEY_WEDDING_TIME) + 7 * 86400;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var result:Number = dayExpiredTime - currenttime;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("06/01/2020");
         timeLeft = (endTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return result >= timeLeft;
      }
      
      public function cycleEndTimerWithFeature() : Number
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("06/01/2020");
         return (endTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
      }
      
      public function getCycleTimeLeft() : String
      {
         var days:int = 0;
         var timeLeft:Number = this.getCycleTimeLeftUtil();
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
      
      public function hasActiveCycleExpired() : Boolean
      {
         var dayExpiredTime:Number = this.getFeatureOptionsKey(this.KEY_WEDDING_TIME) + 7 * 86400;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var result:Number = dayExpiredTime - currenttime;
         return result <= 0;
      }
      
      public function getPanelDisplayValue() : int
      {
         return this.getFeatureOptionsKey(this.KEY_PANEL_DISPLAY) as int;
      }
      
      public function setPanelDisplayValue(panelVal:int) : int
      {
         return this.saveFeatureOptionsKey(this.KEY_PANEL_DISPLAY,panelVal) as int;
      }
      
      public function initEventListener() : void
      {
         GlobalEventManager.getInstance().addEventListener(EVENT_WW_INNOVATION_TILE_UNLOCK,this.onTileUnlocked);
      }
      
      private function onTileUnlocked(event:TileUnlockEvent = null) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onTileUnlockProgress",this.onTileUnlockProgress,[FEATURE_NAME]),true);
      }
      
      private function onTileUnlockProgress(result:Object) : void
      {
         if(Boolean(result) && Boolean(result.success))
         {
            if(result.hasOwnProperty(KEY_TILES_UNLOCKED))
            {
               this.saveFeatureOptionsKey(KEY_TILES_UNLOCKED,result[KEY_TILES_UNLOCKED]);
            }
         }
      }
      
      public function isFeatureEnd() : Boolean
      {
         var result:Boolean = true;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("borabora_innovation_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            result = false;
         }
         return result;
      }
      
      public function removeHud() : void
      {
         if(Global.hud)
         {
            Global.hud.removeBottomHudBoraBoraInnovationButton();
         }
      }
      
      public function featureEndDeco() : void
      {
         Global.player.setSeenFlag(BoraBoraInnovationManager.BB_INNOVATION_END_DECO_FLAG);
         this.grantCycleFinishDecos();
         this.deleteDecos();
         TransactionManager.addTransaction(new TGenericTransaction("BoraBoraInnovationService","featureEndDeco",null,["BoraBoraInnovation"]));
      }
      
      public function isNPCFlagSet(npcFlag:String) : Boolean
      {
         return this.getFeatureOptionsKey(npcFlag) as Boolean;
      }
      
      public function setNPCFlag(npcFlag:String) : void
      {
         this.saveFeatureOptionsKey(npcFlag,true);
         TransactionManager.addTransaction(new TGenericTransaction("BoraBoraInnovationService","npcCallout",null,["BoraBoraInnovation",npcFlag]));
      }
      
      public function reSetNPCSFlag() : void
      {
         var npcFlags:Array = new Array("npcStreakMc","npcRemainigMc","npcRemainigNewMc","npcCalloutDeco","npcOBTLockMc");
         for(var i:int = 0; i < npcFlags.length; i++)
         {
            this.saveFeatureOptionsKey(npcFlags[i],false);
         }
      }
      
      public function onRedeemStarted() : void
      {
         this.showLeaderboardUI(true);
         this.saveFeatureOptionsKey("forceGrantedLB",1);
         FarmStatsManager.count(m_featureName,"grantLBReward","FeatureEnd");
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onRedeemStarted",null,[m_featureName]),true);
      }
      
      public function isNPCWaringActive() : Boolean
      {
         var decoCode:String = this.getFeatureOptionsKey("npcWarning") as String;
         var decosCode:Array = new Array("2mb8","2mkc","2mf5","2miw","2mn2","2n49","2n2v");
         for(var i:int = 0; i < decosCode.length; i++)
         {
            if(decosCode[i] == decoCode)
            {
               return true;
            }
         }
         return false;
      }
      
      public function setNPCWarning() : void
      {
         this.saveFeatureOptionsKey("npcWarning","");
      }
      
      public function updateTimers() : void
      {
         this.saveFeatureOptionsKey(this.KEY_WEDDING_TIME,FarmGameUtil.getMidnightTimestamp() / 1000);
         var weekData:Object = this.getCurrentWeek();
         if(weekData)
         {
            this.saveFeatureOptionsKey(KEY_CURRENT_WEEK,weekData.count - 1);
         }
         this.saveFeatureOptionsKey(this.KEY_ACTIVE_DAY_TIMESTAMP,FarmGameUtil.getMidnightTimestamp() / 1000);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onUpdateTimers",null,[m_featureName]),true);
      }
   }
}

