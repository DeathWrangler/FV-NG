package Managers.OrderBoard
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.ArrowType;
   import Classes.Constants.QuestConstants;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureBuilding;
   import Classes.FeedData;
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.GenericPopup;
   import Display.HUD.HUDWidgets.HudBottomBrazilInnovationButton;
   import Display.HUD.HUDWidgets.HudBottomCarribeanInnovationButton;
   import Display.HUD.HUDWidgets.HudBottomFrontierInnovationButton;
   import Display.QueuedIcons.QueuedIconWithArrow;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Events.TileUnlockEvent;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.FeatureOptionsManager;
   import Managers.WorldSeasonsManager;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.CarribeanGenericSingleRewardPopup;
   import Widgets.Windows.CarribeanInnovationAchievementRewardPopup;
   import Widgets.Windows.CarribeanInnovationAchievementWindow;
   import Widgets.Windows.CarribeanInnovationFranchiseWindow;
   import Widgets.Windows.CarribeanTileUnlockWindow;
   import Widgets.Windows.CongratsForNewBrazilInovationWindow;
   import Widgets.Windows.CongratsForNewCaribbeanInovationWindow;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FrontierInnovationBarnWindow;
   import Widgets.Windows.FrontierInnovationBuildingUpgradeWindow;
   import Widgets.Windows.FrontierInnovationForageRewardPopUp;
   import Widgets.Windows.FrontierInnovationTradePostWindow;
   import Widgets.Windows.FrontierInnovationWindow;
   import Widgets.Windows.GenericSingleRewardPopup;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class FrontierInnovationManager extends SpecialQuestManager
   {
      
      public static const HUD_INITIALISATION_FLAG:String = "frontier_innovation_hud_initialise_flag";
      
      private static const SERVICE_NAME:String = "FrontierInnovationService";
      
      private static const HUD_FRONTIER_ASSET:String = "assets/dialogs/newfrontier/innovation/FV_xnf_hud_Innovation.swf";
      
      private static const KEY_SAVED_ACTIVE_TASKS:String = "1";
      
      private static const KEY_TILE_UNLOCK_COUNT:String = "tile_unlock_count";
      
      public static const BRAZIL_TILE_LIST:Array = new Array("xcb_rubbletreasure1","xcb_rubbletreasure2","xcb_rubbletreasure3","xcb_rubbletreasure4","xcb_rubbletreasure5","xcb_rubbletreasure6","xcb_rubbletreasure7","xcb_rubbletreasure8","xcb_rubbletreasure9","xcb_rubbletreasure_payer1","xcb_rubbletreasure_payer2","xcb_rubbletreasure_payer3","xcb_rubbletreasure_payer4","xcb_rubbletreasure_payer5","xcb_rubbletreasure_payer6","xcb_rubbletreasure_payer7","xcb_rubbletreasure_payer8","xcb_rubbletreasure_payer9","xcb_rubbletreasure_payer10","xcb_rubbletreasure_payer11","xcb_rubbletreasure_payer12","xcb_rubbletreasure_payer13","xcb_rubbletreasure_payer14","xcb_rubbletreasure_payer15","xcb_rubbletreasure_payer16","xcb_rubbletreasure_payer17","xcb_rubbletreasure_payer18","xcb_rubbletreasure_payer19","xcb_rubbletreasure_payer20","xcb_rubbletreasure_payer21","xcb_rubbletreasure_payer22","xcb_rubbletreasure_payer23");
      
      public static const ACHIEVEMENT_EXPIRY_DATES:Array = new Array("5/6/2018","5/13/2018","5/20/2018","5/27/2018");
      
      public static const ACHIEVEMENT_UNLOCK_DATES:Array = new Array("4/24/2018","5/1/2018","5/8/2018","5/15/2018");
      
      public static const ACHIEVEMENT_POINTS_ARRAY:Array = new Array(250,500,750,950);
      
      private static const UPGRADE:Object = {
         "xfnu":1,
         "4bi9":1,
         "6uc2":1
      };
      
      private static const BASIC:Object = {
         "mtq7":1,
         "yl41":1,
         "2zvs":1,
         "53fz":1,
         "zgex":1
      };
      
      private static const LUXURY:Object = {
         "kfl5":1,
         "64ob":1,
         "xu3t":1,
         "70hm":1,
         "tjbo":1
      };
      
      private static const KEY_SAVED_DUMPED_TIMESTAMP:String = "3";
      
      private static const KEY_NPC_MOVEMENTS:String = "4";
      
      private static const KEY_SAVED_FIRST_REWARD_RECEIVED:String = "5";
      
      private static const KEY_SAVED_SECOND_REWARD_RECEIVED:String = "6";
      
      private static const KEY_SAVED_THIRD_REWARD_RECEIVED:String = "7";
      
      private static const KEY_SAVED_PPD:String = "8";
      
      private static const KEY_SAVED_FEATURE_SHOWN_TIMESTAMP:String = "10";
      
      public static const KEY_SAVED_FINAL_REWARD_RECEIVED:String = "k11";
      
      public static const KEY_SAVED_FINAL_REWARD_BUILDINGNAME:String = "reward_building";
      
      private static const KEY_NPC1_FINAL_REWARD_RECEIVED:String = "12";
      
      private static const KEY_NPC2_FINAL_REWARD_RECEIVED:String = "13";
      
      private static const KEY_NPC3_FINAL_REWARD_RECEIVED:String = "14";
      
      public static const EVENT_FRONTIER_INNOVATION_TILE_UNLOCK:String = "FrontierInnovationTileUnlock";
      
      private static const KEY_SAVED_FIRST_ACHIEVEMENT:String = "17";
      
      private static const KEY_SAVED_SECOND_ACHIEVEMENT:String = "18";
      
      private static const KEY_SAVED_THIRD_ACHIEVEMENT:String = "19";
      
      private static const KEY_SAVED_FOURTH_ACHIEVEMENT:String = "20";
      
      private static const KEY_SAVED_LAST_ACHIEVEMENT_REDEEMED:String = "35";
      
      private static const KEY_SAVED_BOARD_COUNT:String = "21";
      
      private static const ACHIEVEMENT_COMPLETED:Number = 1;
      
      private static const ACHIEVEMENT_REDEEMED:Number = 2;
      
      private static const KEY_NPC1:String = "npc1";
      
      private static const KEY_NPC2:String = "npc2";
      
      private static const KEY_NPC3:String = "npc3";
      
      private static const KEY_TIMESTAMP:String = "timestamp";
      
      private static const KEY_POINTS:String = "points";
      
      private static const VAL_EA_NPC1:Number = 1506063599;
      
      private static const VAL_EA_NPC2:Number = 1506236399;
      
      private static const VAL_EA_NPC3:Number = 1506409199;
      
      private static const VAL_GA_NPC1:Number = 1506322799;
      
      private static const VAL_GA_NPC2:Number = 1506495599;
      
      private static const VAL_GA_NPC3:Number = 1506668399;
      
      public static const VAL_FIRST_MILESTONE:int = 300;
      
      public static const VAL_SECOND_MILESTONE:int = 900;
      
      public static const VAL_THIRD_MILESTONE:int = 1800;
      
      public static const VAL_FINAL_MILESTONE:int = 3000;
      
      private static const SKIP_COST:int = 1;
      
      private static const WINDOW_MAIN:String = "main";
      
      private static const WINDOW_BARN:String = "barn";
      
      private static const WINDOW_TRADEPOST:String = "tradepost";
      
      private static const WINDOW_FRANCHISE:String = "franchise";
      
      private static const WINDOW_FORAGE_POPUP:String = "forage_PopUp";
      
      private static const WINDOW_MILESTONE_REWARD:String = "milestone_reward";
      
      public static const WINDOW_FINAL_REWARD:String = "k11";
      
      private static const WINDOW_NPC_FINAL_REWARD:String = "npc_final_reward";
      
      private static const WINDOW_REWARDS:String = "rewards";
      
      private static const WINDOW_ACHIEVEMENT:String = "achievement";
      
      private static const WINDO_FINAL_REWARDS_SELECTION:String = "final_reward_selection";
      
      private static const WINDOW_BOOST:String = "boost";
      
      public static const CARIBBEAN_TASK_POINTS_ITEM_CODE:String = "vg3q";
      
      public static const FRONTIER_FEATURE_POINTS_ITEM_CODE:String = "oq3s";
      
      public static const FRONTIER_ORDERBOARD_POINTS_ITEM_CODE:String = "gmim";
      
      public static const FRONTIER_TILE_UNLOCK_COUNT:String = "enra";
      
      private static const SPECIAL_TILE_NAME:String = "xdw_rubbletreasure_special";
      
      private static const TILE_UNLOCK_COUNT:String = "tuc";
      
      private static const PM_FEATURE_CURRENCY_NAME:String = "morphpotion";
      
      private static const PM_FEATURE_THRELD_COUNT:int = 30;
      
      private static const BUNDLE_ID:String = "CarribeanInnovation_Brag";
      
      private static const m_marketItems:Array = new Array("xnf_rubbletreasure1","xnf_rubbletreasure2","xnf_rubbletreasure3","xnf_rubbletreasure4","xnf_rubbletreasure5","xnf_rubbletreasure6","xnf_rubbletreasure7","xnf_rubbletreasure8","xnf_rubbletreasure9","xnf_rubbletreasure_payer1","xnf_rubbletreasure_payer2","xnf_rubbletreasure_payer3","xnf_rubbletreasure_payer4","xnf_rubbletreasure_payer5","xnf_rubbletreasure_payer6","xnf_rubbletreasure_payer7","xnf_rubbletreasure_payer8","xnf_rubbletreasure_payer9","xnf_rubbletreasure_payer10","xnf_rubbletreasure_payer11","xnf_rubbletreasure_payer12","xnf_rubbletreasure_payer13","xnf_rubbletreasure_payer14","xnf_rubbletreasure_payer15","xnf_rubbletreasure_payer16","xnf_rubbletreasure_payer17","xnf_rubbletreasure_payer18","xnf_rubbletreasure_payer19","xnf_rubbletreasure_payer20","xnf_rubbletreasure_payer21","xnf_rubbletreasure_payer22","xnf_rubbletreasure_payer23");
      
      private static const COLLECT_CONSUMABLE_COUNT:int = 1;
      
      public static const DEFAULT_COLLECT_THROTTLE_TIME:int = 86400;
      
      public static const DEFAULT_COLLECT_THROTTLE_TIME_MSECS:int = 86400000;
      
      public static const NUM_MSECS_IN_SIX_HRS:uint = 21600000;
      
      public static const DEFAULT_HARVEST_THROTTLE_TIME:int = 86400;
      
      private static const HUD_CARRIBEAN_ASSET:String = "assets/dialogs/newfrontier/innovation/FV_xnf_hud_Innovation.swf";
      
      public static const FTUE_SEEN_FLAG:String = "CarribeanInnovation_Tutorial";
      
      public static const FEATURE_FORCED_TUT_FRIST_STEP:String = "FrontierInnovation_step1";
      
      public static const FEATURE_FORCED_TUT_SECOND_STEP:String = "FrontierInnovation_step2";
      
      public static const FEATURE_FORCED_BARN_TUT_FIRST_STEP:String = "FrontierInnovation_barn_step1";
      
      public static const FEATURE_FORCED_BARN_TUT_SECOND_STEP:String = "FrontierInnovation_barn_step2";
      
      public static const FEATURE_FORCED_BARN_TUT_THIRD_STEP:String = "FrontierInnovation_barn_step3";
      
      private static const LAST_BONUS_HARVEST_TIME_KEY:String = "Last_bonus_harvest_time";
      
      public static const LAND_BUNDLE_UNLOCKED:String = "Caribbean_LandBundle_unlocked";
      
      public static const LAND_BUNDLE_POPUP:String = "Caribbean_LandBundle_popup";
      
      private static const KEY_SPECIAL_RECIPES:* = "special_recipes";
      
      private static const FIRST_TIME_TILE_UNLOCK:String = "First_time_tile_unlock";
      
      private static const TILE_UNLOCK:String = "Tile_Unlock";
      
      private static const FIRST_TIME_LANDBUNDLE_UNLOCK:String = "First_time_landbundle_unlock";
      
      private static const FIRST_TIME_LANDBUNDLE_ACTIVE:String = "First_time_landbundle_active";
      
      private var m_isEA:Boolean;
      
      private var m_hud:QueuedIconWithArrow;
      
      private var m_newHud:HudBottomBrazilInnovationButton;
      
      private var m_currencyName:String = "task_points";
      
      private var m_endTimeStamp:Number = 0;
      
      private var m_tasksById:Object = null;
      
      private var m_recipesById:Array = null;
      
      private var m_assetPaths:Object = {};
      
      private var m_eaRewards:Array = new Array();
      
      private var m_gaRewards:Array = new Array();
      
      private var m_lastMilestoneRewards:Array = new Array();
      
      protected var m_staticData:Object = {};
      
      private var m_finalRewards:Array = new Array();
      
      private var m_feedConfig:Object = {};
      
      private const BONUS_HARVEST_ARRAY:Array = new Array("consume_organic_fertilizer","consume_turbo_charger","consume_instagrow","fuel1","consume_unwither","vehiclepart","pkg_xnf_harvest_treasureparts","consume_arborists","consume_farm_hands","fawn_feed");
      
      private const BONUS_HARVEST_COUNT:String = "hc";
      
      public const KEY_FEATURE_FINISHED_TIME:String = "31";
      
      public const KEY_FEATURE_FINISHED_DAILY_TIME:String = "36";
      
      public const KEY_ACTIVE_DAY_TIMESTAMP:String = "32";
      
      public const KEY_DAY_POINTS:String = "33";
      
      public const KEY_DAY_REWARD_GRANT_STATUS:String = "34";
      
      public const DAY_REWARD_MILESTONE_POINTS:int = 50;
      
      private const SERVICE_FUNC_HARVEST_BONUS:String = "harvestFinalBuilding";
      
      private const BUILDING_ASSET0:String = "assets/buildings/carnivalfloat0_icon_200.png";
      
      private const BUILDING_ASSET1:String = "assets/buildings/carnivalfloat1_icon_200.png";
      
      private const BUILDING_ASSET2:String = "assets/buildings/carnivalfloat2_icon_200.png";
      
      private const BUILDING_ASSET3:String = "assets/buildings/carnivalfloat3_icon_200.png";
      
      private const TILE_UNLOCK_ASSET:String = "assets/dialogs/brazil/innovation/FV_xbr_Innovation_Prize.swf";
      
      private const LAND_BUNDLE_UNLOCK_POPUP:String = "assets/buildings/xcb_beachcafe.swf";
      
      private const REWARD_POPUP_WINDOW:String = "assets/dialogs/expansion/FV_RewardDialog.swf";
      
      private const REWARD_SHARE_WINDOW:String = "assets/dialogs/expansion/FV_RewardDialog_Share.swf";
      
      private const REWARD_WINDOW_IMAGE:String = "assets/dialogs/newfrontier/RewardDialog.png";
      
      protected const KEY_ID:String = "id";
      
      protected const KEY_PROGRESS:String = "progress";
      
      protected const KEY_TOTAL:String = "total";
      
      private var m_frontierInnovationHud:HudBottomFrontierInnovationButton;
      
      public const TILE_UNLOCK_POINTS:Number = 30;
      
      public var m_window:FrontierInnovationWindow;
      
      public var m_BarnWindow:FrontierInnovationBarnWindow;
      
      public var m_TradePostWindow:FrontierInnovationTradePostWindow;
      
      private var m_rewardWindow:GenericSingleRewardPopup;
      
      private var m_buildingUpgradeRewardWindow:CarribeanGenericSingleRewardPopup;
      
      private var m_forageRewardPopUp:FrontierInnovationForageRewardPopUp;
      
      private var m_rewardName:String;
      
      private var m_resultObject:Object;
      
      private var m_redeemResultObject:Object;
      
      private var m_isActive:Boolean = false;
      
      protected var m_owner:FeatureBuilding;
      
      private var m_CarribeanInnovationHud:HudBottomCarribeanInnovationButton;
      
      private const TILE_UNLOCK_LIMIT_FOR_POINTS:int = 8;
      
      private var m_achievementWindow:CarribeanInnovationAchievementWindow;
      
      private var m_achievementRewardWindow:CarribeanInnovationAchievementRewardPopup;
      
      private var m_buildingUpgradeWindow:FrontierInnovationBuildingUpgradeWindow;
      
      private var m_rewardDailyWindow:GenericSingleRewardPopup;
      
      private var m_showRedeemCallout:Boolean = false;
      
      private var m_recipe:Object;
      
      private var m_timer:Timer;
      
      public const MAX_BARN_CAPACITY:* = 430;
      
      private const EMPTY_SLOT:int = 0;
      
      private var m_emptySlot:int;
      
      public var allSpecialRecipes:Object;
      
      private var m_tradePostSlotToEmpty:int;
      
      public const KEY_TRADE_POST_SLOTS:String = "51";
      
      public const KEY_UPGRADE_RESOURCES:String = "52";
      
      public const KEY_BASIC_RESOURCES:String = "53";
      
      public const KEY_LUXURY_RESOURCES:String = "54";
      
      public const KEY_FORAGE_DATA:String = "55";
      
      public const KEY_BARN_RESOURCES_CAPACITY:String = "barnCapacity";
      
      public const TRADE_POST_CAPACITY:int = 6;
      
      public const MAX_UPGRADE_RESOURCES:int = 3;
      
      public const REQUIRED_UPGRADE_RESOURCES:int = 3;
      
      public const TUNING_BARN_CAPACITY:int = 10;
      
      public var foragingResources:Object;
      
      public var m_confirmPopup:GenericPopup;
      
      public var ACTIVE_FORAGE_AREA:String;
      
      public var areas:Array = ["Calming Glade","Hidden Pond","Wonder Waterfalls"];
      
      public function FrontierInnovationManager(featureName:String)
      {
         super(featureName);
         if(!this.featureConfig)
         {
            return;
         }
         this.parseFeatureConfig();
         this.parseTaskObjectsFromCOnfig(m_featureName);
         this.startQuest();
         this.setSpecialRecipe();
         this.m_resultObject = new Object();
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
         this.m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_CARIBBEAN);
      }
      
      public static function getInstance(featureName:String) : FrontierInnovationManager
      {
         var instance:FrontierInnovationManager = getInstanceOfClass(featureName,FrontierInnovationManager) as FrontierInnovationManager;
         return instance.featureConfig == null ? null : instance;
      }
      
      public function setupHud() : void
      {
         var extraData:Object = {};
         extraData["iconTooltip"] = ZLocUtils.t("Dialogs",m_featureName + "_HUD_icon_tooltip");
         this.m_hud = Global.hud.rightSideIconQueue.addIcon(m_featureName,DynamicIconQueue.ADD_BY_PRIORITY,null,extraData) as QueuedIconWithArrow;
         if(this.m_hud)
         {
            this.m_hud.attachArrow(ArrowType.ARROWNEW);
            this.m_hud.setArrowText("New Feature!");
         }
      }
      
      public function getAreaName() : Array
      {
         return this.areas;
      }
      
      public function getForageAreaNameByAreaId(areaId:int) : String
      {
         return this.areas[areaId];
      }
      
      private function refreshTradebyTimer(event:TimerEvent) : void
      {
         if(this.getTradePostNonEmptySlotCount() > 0)
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onActiveTradePostSlot",this.onperformTrade,[m_featureName]),true);
         }
      }
      
      private function onperformTrade(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("tradeData"))
         {
            this.saveFeatureOptionsKey(this.KEY_TRADE_POST_SLOTS,result["tradeData"]);
            if(this.isTradePostNotifyShow())
            {
               if(this.m_window)
               {
                  this.m_window.m_notifMc.visible = true;
               }
               if(this.m_frontierInnovationHud)
               {
                  this.m_frontierInnovationHud.refresh(2);
               }
            }
         }
      }
      
      public function getFCByForageAreaId(areaId:int) : int
      {
         var payFC:Array = [3,5,10];
         return payFC[areaId];
      }
      
      public function getFCForForage() : Array
      {
         return [3,5,10];
      }
      
      public function getAreaImage() : Array
      {
         return ["assets/dialogs/Frontier_Innovation/calmingglade_icon.png","assets/dialogs/Frontier_Innovation/hiddenpond_icon.png","assets/dialogs/Frontier_Innovation/wonderwaterfalls_icon.png"];
      }
      
      public function getAreaPickaxes() : Array
      {
         return [5,10,20];
      }
      
      public function getForageTime() : Array
      {
         return [15,30,60];
      }
      
      public function getForageData() : Object
      {
         return this.getFeatureOptionsKey(this.KEY_FORAGE_DATA);
      }
      
      public function get isFeatureActive() : Boolean
      {
         return this.m_isActive;
      }
      
      public function getDialogUrl() : String
      {
         return this.m_assetPaths[WINDOW_MAIN];
      }
      
      public function getBarnDialogUrl() : String
      {
         return this.m_assetPaths[WINDOW_BARN];
      }
      
      public function getTradePostDialogUrl() : String
      {
         return this.m_assetPaths[WINDOW_TRADEPOST];
      }
      
      public function getForageRewardPopUp() : String
      {
         return this.m_assetPaths[WINDOW_FORAGE_POPUP];
      }
      
      public function getFranchiseDialogUrl() : String
      {
         return this.m_assetPaths[WINDOW_FRANCHISE];
      }
      
      public function showMainUI() : void
      {
         if(!this.hasExpiryDatePassedForFeature())
         {
            this.m_window = new FrontierInnovationWindow();
            this.startQuest(this.m_window.refreshTaskFrame);
            UI.displayPopup(this.m_window);
         }
      }
      
      public function showBarnUI() : void
      {
         if(this.m_window)
         {
            this.m_window.tintWindow();
            this.m_window.enableInput = false;
         }
         this.m_BarnWindow = new FrontierInnovationBarnWindow();
         UI.displayPopup(this.m_BarnWindow,false);
      }
      
      public function showForageRewardPopUp(forageAreaData:Object) : void
      {
         this.m_forageRewardPopUp = new FrontierInnovationForageRewardPopUp(forageAreaData);
         UI.displayPopup(this.m_forageRewardPopUp,false);
      }
      
      public function openMainWindow() : void
      {
         this.m_BarnWindow.close();
         if(this.m_window)
         {
            UI.displayPopup(this.m_window,false);
         }
         else
         {
            this.m_window = new FrontierInnovationWindow();
            UI.displayPopup(this.m_window,false);
         }
      }
      
      public function visitBarnUIFromTradePost() : void
      {
         this.m_TradePostWindow.close();
         this.m_BarnWindow = new FrontierInnovationBarnWindow();
         UI.displayPopup(this.m_BarnWindow,false);
      }
      
      public function visitBarnUIFromForage() : void
      {
         this.m_BarnWindow = new FrontierInnovationBarnWindow();
         UI.displayPopup(this.m_BarnWindow,false);
      }
      
      public function getBarnCapacity() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,this.KEY_BARN_RESOURCES_CAPACITY);
      }
      
      public function getBarnInventoryCount() : int
      {
         var capacity:String = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,this.KEY_BARN_RESOURCES_CAPACITY) as String;
         var ar:Array = capacity.split("/");
         return int(ar[0]);
      }
      
      public function getRemainBarnCapacity() : int
      {
         var capacity:String = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,this.KEY_BARN_RESOURCES_CAPACITY) as String;
         var ar:Array = capacity.split("/");
         return int(int(ar[1]) - int(ar[0]));
      }
      
      public function getTotalBarnCapacity() : int
      {
         var capacity:String = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,this.KEY_BARN_RESOURCES_CAPACITY) as String;
         var ar:Array = capacity.split("/");
         return int(ar[1]);
      }
      
      public function triggerTradeFrame(slotNumber:int, m_slotResource:String, resourceType:String, emptySlot:int) : void
      {
         if(!this.m_BarnWindow)
         {
         }
         this.m_BarnWindow.triggerTadeFrameInWindow(slotNumber,m_slotResource,resourceType,emptySlot);
      }
      
      public function getTradePostNonEmptySlotCount() : Number
      {
         var i:int = 0;
         var data:Object = this.getTradePostData();
         var count:Number = 0;
         if(data)
         {
            for(i = 0; i < data.length; i++)
            {
               if(data[i][0] != this.EMPTY_SLOT)
               {
                  count++;
               }
            }
         }
         return count;
      }
      
      public function getTradePostSlotCount() : String
      {
         var data:Object = this.getTradePostData();
         var count:int = 0;
         for(var i:int = 0; i < data.length; i++)
         {
            if(data[i][0] != this.EMPTY_SLOT)
            {
               count++;
            }
         }
         return String(count) + "/" + this.TRADE_POST_CAPACITY;
      }
      
      public function onForgeClick(areaId:int) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"forageArea",this.onForageClickCallback,[m_featureName,areaId]),true);
      }
      
      public function onForageClickCallback(result:Array) : void
      {
         var areaPacax:Array = null;
         var areaId:int = 0;
         var forageData:Object = null;
         var forageAreaResources:Array = null;
         var forageAreaName:String = null;
         var forageAreaData:Object = null;
         if(Boolean(result) && !result["error"])
         {
            areaPacax = this.getAreaPickaxes();
            areaId = int(result[1]);
            forageData = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,this.KEY_FORAGE_DATA);
            this.setOrderboardProgress(areaPacax[areaId]);
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,this.KEY_FORAGE_DATA,result[0]["forage"]);
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,this.KEY_UPGRADE_RESOURCES,result[0]["upgrade"]);
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,this.KEY_BASIC_RESOURCES,result[0]["basic"]);
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,this.KEY_LUXURY_RESOURCES,result[0]["luxury"]);
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,this.KEY_BARN_RESOURCES_CAPACITY,result[0]["barnCapacity"]);
            this.gotSpecialRecipes(result[2]);
            this.m_window.disabledForage();
            forageAreaResources = forageData[areaId];
            forageAreaName = this.getForageAreaNameByAreaId(areaId);
            forageAreaData = {
               "AreaName":forageAreaName,
               "AreaResources":forageAreaResources[0]
            };
            this.showForageRewardPopUp(forageAreaData);
         }
      }
      
      public function onForageSucessPopUp() : void
      {
         this.m_window.refreshWindow();
         this.m_window.setForageOverlayMc(false);
         this.m_window.enableForage();
         this.m_window.refreshForage();
         this.m_forageRewardPopUp.close();
      }
      
      public function getTradePostFullMessage() : String
      {
         return "Your Trade Post is Full! \n Clear slot to start trading!";
      }
      
      public function isBarnCapacityFull() : Boolean
      {
         var capacity:String = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,this.KEY_BARN_RESOURCES_CAPACITY) as String;
         var ar:Array = capacity.split("/");
         var result:Boolean = false;
         if(ar[0] == ar[1])
         {
            result = true;
         }
         return result;
      }
      
      public function clearTradeSlot(frameName:String) : void
      {
         this.m_BarnWindow.clearTradeSlots(frameName);
      }
      
      public function closeTradeFrame(resourceType:String) : void
      {
         this.m_BarnWindow.closeTradeFrameInWindow(resourceType);
      }
      
      public function openTradePostWindow() : void
      {
         if(this.m_BarnWindow)
         {
            this.m_BarnWindow.tintWindow();
            this.m_BarnWindow.enableInput = false;
         }
         this.m_TradePostWindow = new FrontierInnovationTradePostWindow();
         UI.displayPopup(this.m_TradePostWindow,false);
      }
      
      public function isTradePostNotifyShow() : Boolean
      {
         var i:int = 0;
         var data:Object = this.getTradePostData();
         if(data)
         {
            for(i = 0; i < data.length; i++)
            {
               if(data[i][0] == 2 || data[i][0] == 3)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function getTradePostData() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,this.KEY_TRADE_POST_SLOTS);
      }
      
      public function failureTradePost(slot:int) : void
      {
         this.m_tradePostSlotToEmpty = slot;
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onFailureTradePostSlot",this.onFailureCallectItemCallback,[m_featureName,this.m_tradePostSlotToEmpty]),true);
      }
      
      public function onFailureCallectItemCallback(result:Object) : void
      {
         if(Boolean(result) && !result["error"])
         {
            this.updateResourceCountOnFailure(this.m_tradePostSlotToEmpty,1);
            this.resetTradePostSlot(this.m_tradePostSlotToEmpty);
            this.increaseBarnInventory(1);
            this.m_TradePostWindow.refreshTradePostFrame();
            this.m_TradePostWindow.untintWindow();
            this.m_TradePostWindow.enableInput = true;
            this.onTradingFailurePopUp();
            this.m_BarnWindow.refreshWindow();
            this.m_window.refreshWindow();
         }
      }
      
      public function successTradePost(slot:int) : void
      {
         this.m_tradePostSlotToEmpty = slot;
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onSuccessTradePostSlot",this.onSuccessCallectItemCallback,[m_featureName,this.m_tradePostSlotToEmpty]),true);
      }
      
      public function onSuccessCallectItemCallback(result:Object) : void
      {
         if(Boolean(result) && !result["error"])
         {
            this.updateResourceCountOnSucess(this.m_tradePostSlotToEmpty,1);
            this.resetTradePostSlot(this.m_tradePostSlotToEmpty);
            this.increaseBarnInventory(1);
            this.m_TradePostWindow.refreshTradePostFrame();
            this.onTradingSuccessPopUp();
            this.m_BarnWindow.refreshWindow();
            this.m_window.refreshWindow();
         }
      }
      
      public function onTradingSuccessPopUp() : void
      {
         var sellMessage:String = "Your resource has been added to your Barn.";
         UI.displayMessage(sellMessage,GenericPopup.TYPE_OK,this.untintTradepostWndow,"",true);
      }
      
      public function untintTradepostWndow(event:GenericPopupEvent) : void
      {
         this.m_TradePostWindow.untintWindow();
         this.m_TradePostWindow.enableInput = true;
      }
      
      public function onTradingFailurePopUp() : void
      {
         var sellMessage:String = "Your resource has been sent back to the Barn.";
         UI.displayMessage(sellMessage,GenericPopup.TYPE_OK,this.untintTradepostWndow,"",true);
      }
      
      public function updateResourceCountOnSucess(slot:int, quantity:int) : void
      {
         var resourceCount:int = 0;
         var slotData:Object = this.getFeatureOptionsKey(this.KEY_TRADE_POST_SLOTS);
         var resource:String = slotData[slot][1];
         var resourceType:String = this.getResourceTypeByItemCode(resource);
         if(resourceType == "upgrade")
         {
            resourceCount = this.getUpgradeResourceCount(resource);
         }
         else if(resourceType == "basic")
         {
            resourceCount = this.getBasicResourceCount(resource);
         }
         else if(resourceType == "luxury")
         {
            resourceCount = this.getLuxuryResourceCount(resource);
         }
         resourceCount += quantity;
         this.updateResources(resourceType,resource,resourceCount);
      }
      
      public function updateResourceCountOnFailure(slot:int, quantity:int) : void
      {
         var resourceCount:int = 0;
         var slotData:Object = this.getFeatureOptionsKey(this.KEY_TRADE_POST_SLOTS);
         var resource:String = slotData[slot][2];
         var resourceType:String = this.getResourceTypeByItemCode(resource);
         if(resourceType == "upgrade")
         {
            resourceCount = this.getUpgradeResourceCount(resource);
         }
         else if(resourceType == "basic")
         {
            resourceCount = this.getBasicResourceCount(resource);
         }
         else if(resourceType == "luxury")
         {
            resourceCount = this.getLuxuryResourceCount(resource);
         }
         resourceCount += quantity;
         this.updateResources(resourceType,resource,resourceCount);
      }
      
      public function resetTradePostSlot(slot:int) : void
      {
         var data:Object = this.getTradePostData();
         var slotData:Array = data[slot];
         slotData[0] = 0;
         slotData[1] = "";
         slotData[2] = "";
         slotData[3] = -1;
         slotData[4] = "";
         slotData[5] = "";
         data[slot] = slotData;
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,this.KEY_TRADE_POST_SLOTS,data);
      }
      
      public function getResourceTypeByItemCode(itemCode:String) : String
      {
         if(UPGRADE.hasOwnProperty(itemCode) && UPGRADE[itemCode] == 1)
         {
            return "upgrade";
         }
         if(BASIC.hasOwnProperty(itemCode) && BASIC[itemCode] == 1)
         {
            return "basic";
         }
         if(LUXURY.hasOwnProperty(itemCode) && LUXURY[itemCode] == 1)
         {
            return "luxury";
         }
         return null;
      }
      
      public function updateResources(resourceType:String, itemCode:String, result:int) : void
      {
         var data:Object = null;
         if(resourceType == "upgrade")
         {
            data = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,this.KEY_UPGRADE_RESOURCES);
            data[itemCode] = result;
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,this.KEY_UPGRADE_RESOURCES,data);
         }
         else if(resourceType == "basic")
         {
            data = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,this.KEY_BASIC_RESOURCES);
            data[itemCode] = result;
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,this.KEY_BASIC_RESOURCES,data);
         }
         else if(resourceType == "luxury")
         {
            data = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,this.KEY_LUXURY_RESOURCES);
            data[itemCode] = result;
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,this.KEY_LUXURY_RESOURCES,data);
         }
      }
      
      public function getEmptySlot() : int
      {
         var data:Object = this.getTradePostData();
         var slot:int = -1;
         for(var i:int = 0; i < data.length; i++)
         {
            if(data[i][0] == this.EMPTY_SLOT)
            {
               slot = i;
               break;
            }
         }
         return slot;
      }
      
      public function onTradePostConfirm(r1:String, r2:String, emptySlot:int) : void
      {
         this.m_emptySlot = emptySlot;
         FarmStatsManager.count(m_featureName,"BarnHouse","ConfirmTrade",r2,r1);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onTradePostConfirm",this.onAllocateSlot,[m_featureName,r1,r2,this.m_emptySlot]),true);
      }
      
      public function onAllocateSlot(result:Object) : void
      {
         var itemCode:String = null;
         if(!(!result && result.hasOwnProperty("error")))
         {
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,this.KEY_TRADE_POST_SLOTS,result);
            itemCode = result[this.m_emptySlot][2];
            this.decreaseResourceCountByItemCode(itemCode,1);
            this.decreaseBarnInventory(1);
            this.m_BarnWindow.closeTradeFrame();
            this.openTradePostWindow();
            this.initTradeTimer();
         }
      }
      
      public function setupFrontierHud() : void
      {
         if(!this.hasExpiryDatePassedForFeature())
         {
            this.m_frontierInnovationHud = new HudBottomFrontierInnovationButton(HUD_FRONTIER_ASSET,m_featureName);
            Global.hud.setBottomHudFrontierInnovationButton(this.m_frontierInnovationHud as HudBottomFrontierInnovationButton);
         }
      }
      
      public function decreaseResourceCountByItemCode(itemCode:String, count:int) : void
      {
         var resourceCount:int = 0;
         var resourceType:String = this.getResourceTypeByItemCode(itemCode);
         if(resourceType == "upgrade")
         {
            resourceCount = this.getUpgradeResourceCount(itemCode);
         }
         else if(resourceType == "basic")
         {
            resourceCount = this.getBasicResourceCount(itemCode);
         }
         else if(resourceType == "luxury")
         {
            resourceCount = this.getLuxuryResourceCount(itemCode);
         }
         resourceCount -= count;
         this.updateResources(resourceType,itemCode,resourceCount);
      }
      
      public function getResourceCountByItemCode(itemCode:String) : int
      {
         var resourceType:String = this.getResourceTypeByItemCode(itemCode);
         var resourceCount:int = 0;
         if(resourceType == "upgrade")
         {
            resourceCount = this.getUpgradeResourceCount(itemCode);
         }
         else if(resourceType == "basic")
         {
            resourceCount = this.getBasicResourceCount(itemCode);
         }
         else if(resourceType == "luxury")
         {
            resourceCount = this.getLuxuryResourceCount(itemCode);
         }
         return resourceCount;
      }
      
      public function getUpgradeResourceCount(item:String) : int
      {
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,this.KEY_UPGRADE_RESOURCES);
         return data[item];
      }
      
      public function getBasicResourceCount(item:String) : int
      {
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,this.KEY_BASIC_RESOURCES);
         return data[item];
      }
      
      public function getLuxuryResourceCount(item:String) : int
      {
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,this.KEY_LUXURY_RESOURCES);
         return data[item];
      }
      
      public function discardClick(itemCode:String, R2:int, frameName:String) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onDiscardClick",this.onDiscardClickCallback,[m_featureName,itemCode,R2,frameName]),true);
      }
      
      public function onDiscardClickCallback(result:Object) : void
      {
         var itemCode:String = null;
         if(!(Boolean(result) && result.hasOwnProperty("error")))
         {
            itemCode = result["itemCode"];
            this.decreaseResourceCountByItemCode(itemCode,1);
            this.decreaseBarnInventory(1);
            this.m_BarnWindow.refreshWindow();
            this.m_BarnWindow.clearFrameSlot(result["frameName"],result["slotId"]);
         }
      }
      
      public function onForageByPayFC(fc:int, areaId:int) : void
      {
         if(Global.player.canBuyCash(fc))
         {
            Global.player.cash -= fc;
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"forageByPayFCService",this.forageByPayFCCallback,[m_featureName,fc,areaId]),true);
         }
      }
      
      public function forageByPayFCCallback(result:Object) : void
      {
         var areaName:String = null;
         var forageAreaFC:int = 0;
         if(Boolean(result) && !result.hasOwnProperty("error"))
         {
            this.saveFeatureOptionsKey(this.KEY_FORAGE_DATA,result["forageData"]);
            this.m_window.setForageOverlayMc(false);
            this.m_window.refreshForage();
            this.m_window.enableForageWindow();
            areaName = this.getForageAreaNameByAreaId(result["areaId"]);
            forageAreaFC = this.getFCByForageAreaId(result["areaId"]);
            FarmStatsManager.count(m_featureName,"Foraging",areaName,"SkipWait","","",forageAreaFC);
         }
      }
      
      public function onUpgradeByPayFC() : void
      {
         if(Global.player.canBuyCash(10))
         {
            Global.player.cash -= 10;
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onUpgradeByPayFC",this.onUpgradeByPayFCCallback,[m_featureName]),true);
         }
      }
      
      public function onUpgradeByPayFCCallback(result:Object) : void
      {
         if(Boolean(result) && !result.hasOwnProperty("error"))
         {
            this.saveFeatureOptionsKey(this.KEY_BARN_RESOURCES_CAPACITY,result["barnCapacity"]);
            this.m_BarnWindow.refreshWindow();
            this.successUpgradeBarnCapacityPopUp("FC");
            FarmStatsManager.count(m_featureName,"BarnHouse","Complete","","","",10);
         }
      }
      
      public function isBarnCapacityReached() : Boolean
      {
         var result:Boolean = false;
         var capacity:int = this.getTotalBarnCapacity();
         var maxCapacity:int = this.MAX_BARN_CAPACITY;
         return capacity == maxCapacity;
      }
      
      public function increaseBarnInventory(value:int) : void
      {
         var barnCapacity:String = this.getFeatureOptionsKey(this.KEY_BARN_RESOURCES_CAPACITY) as String;
         var valAr:Array = barnCapacity.split("/");
         valAr[0] = int(valAr[0]) + value;
         var result:String = valAr[0] + "/" + valAr[1];
         this.saveFeatureOptionsKey(this.KEY_BARN_RESOURCES_CAPACITY,result);
      }
      
      public function decreaseBarnInventory(value:int) : void
      {
         var barnCapacity:String = this.getFeatureOptionsKey(this.KEY_BARN_RESOURCES_CAPACITY) as String;
         var valAr:Array = barnCapacity.split("/");
         valAr[0] = int(valAr[0]) - value;
         var result:String = valAr[0] + "/" + valAr[1];
         this.saveFeatureOptionsKey(this.KEY_BARN_RESOURCES_CAPACITY,result);
      }
      
      public function upgradeAction() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onUpgradeClick",this.onUpgradeClickCallback,[m_featureName]),true);
      }
      
      public function onUpgradeClickCallback(result:Object) : void
      {
         var barnCapacity:int = 0;
         if(!(Boolean(result) && result.hasOwnProperty("error")))
         {
            this.decreaseUpgradeResources(this.REQUIRED_UPGRADE_RESOURCES);
            this.increaseBarnCapacity(this.TUNING_BARN_CAPACITY);
            this.decreaseBarnInventoryByUpgradeResources();
            this.m_BarnWindow.refreshWindow();
            this.successUpgradeBarnCapacityPopUp("upgrade");
            barnCapacity = this.getTotalBarnCapacity();
            FarmStatsManager.count(m_featureName,"BarnHouse","Upgrade","","10","",barnCapacity);
         }
      }
      
      public function successUpgradeBarnCapacityPopUp(mode:String) : void
      {
         var sellMessage:String = null;
         if(mode == "upgrade")
         {
            sellMessage = "Congratulations! You have used resources to increase the Barn Capacity by 10!";
         }
         else
         {
            sellMessage = "Congratulations! You have increased the Barn Capacity by 10!";
         }
         this.m_confirmPopup = new GenericPopup(sellMessage,GenericPopup.TYPE_OK,this.untintBarnWindow);
         this.m_confirmPopup.setAcceptTextName("Okay");
         UI.displayPopup(this.m_confirmPopup,false,"Barn_Capacity_Increase",true);
      }
      
      public function untintBarnWindow(event:GenericPopupEvent) : *
      {
         this.m_BarnWindow.untintWindow();
         this.m_BarnWindow.enableInput = true;
      }
      
      public function decreaseBarnInventoryByUpgradeResources() : void
      {
         var barnCapacity:String = this.getFeatureOptionsKey(this.KEY_BARN_RESOURCES_CAPACITY) as String;
         var valAr:Array = barnCapacity.split("/");
         valAr[0] = String(int(valAr[0]) - int(this.MAX_UPGRADE_RESOURCES) * int(this.REQUIRED_UPGRADE_RESOURCES));
         var result:String = valAr[0] + "/" + valAr[1];
         this.saveFeatureOptionsKey(this.KEY_BARN_RESOURCES_CAPACITY,result);
      }
      
      public function increaseBarnCapacity(value:int) : void
      {
         var barnCapacity:String = this.getFeatureOptionsKey(this.KEY_BARN_RESOURCES_CAPACITY) as String;
         var valAr:Array = barnCapacity.split("/");
         valAr[1] = String(int(valAr[1]) + value);
         var result:String = valAr[0] + "/" + valAr[1];
         this.saveFeatureOptionsKey(this.KEY_BARN_RESOURCES_CAPACITY,result);
      }
      
      public function upgradeBarnCapacityByTile(tileCount:int) : void
      {
         var barnCapacity:String = this.getFeatureOptionsKey(this.KEY_BARN_RESOURCES_CAPACITY) as String;
         var valAr:Array = barnCapacity.split("/");
         valAr[1] = String(int(valAr[1]) + int(this.TUNING_BARN_CAPACITY * tileCount));
         var result:String = valAr[0] + "/" + valAr[1];
         this.saveFeatureOptionsKey(this.KEY_BARN_RESOURCES_CAPACITY,result);
      }
      
      public function decreaseUpgradeResources(count:int) : void
      {
         var key:String = null;
         var value:int = 0;
         var data:Object = this.getFeatureOptionsKey(this.KEY_UPGRADE_RESOURCES);
         for(key in data)
         {
            value = data[key] - count;
            data[key] = value;
         }
         this.saveFeatureOptionsKey(this.KEY_UPGRADE_RESOURCES,data);
      }
      
      public function sufficientUpgradeResources() : Boolean
      {
         var key:String = null;
         var count:int = 0;
         var data:Object = this.getFeatureOptionsKey(this.KEY_UPGRADE_RESOURCES);
         var flag:Boolean = true;
         for(key in data)
         {
            count = this.getUpgradeResourceCount(key);
            if(count < this.MAX_UPGRADE_RESOURCES)
            {
               flag = false;
            }
         }
         return flag;
      }
      
      public function addFeatureProgressByCrafting(points:int, recipeId:int) : void
      {
         this.m_window.playPointsAnimationMc();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"updateProgress",this.updateProgress,[m_featureName,recipeId]),true);
      }
      
      private function updateProgress(result:Object) : void
      {
         if(Boolean(result) && !result["error"])
         {
            FrontierInnovationManager.getInstance("FrontierInnovation").updateFeatureProgress(parseInt(result["points"]));
            this.saveFeatureOptionsKey(this.KEY_UPGRADE_RESOURCES,result["upgrade"]);
            this.saveFeatureOptionsKey(this.KEY_BASIC_RESOURCES,result["basic"]);
            this.saveFeatureOptionsKey(this.KEY_LUXURY_RESOURCES,result["luxury"]);
            this.saveFeatureOptionsKey(this.KEY_BARN_RESOURCES_CAPACITY,result["barnCapacity"]);
            if(Boolean(this.m_resultObject) && Boolean(result["FrontierFeed"]))
            {
               this.m_resultObject = result["FrontierFeed"];
            }
            this.m_window.refreshCraftFrame();
            this.m_window.refreshWindow();
         }
      }
      
      public function showRewardsUI() : void
      {
         var item:String = "xnf_hardyhome";
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(item);
         var window:FarmWindow = new CongratsForNewCaribbeanInovationWindow(this.m_assetPaths[WINDOW_REWARDS],m_featureName + "lastmilestone",rewardItem,null,null,item);
         StatsManager.count(m_featureName,"Awards_Click");
         UI.displayPopup(window,false);
         this.m_window.close();
      }
      
      public function showBoostUI() : void
      {
         StatsManager.count(m_featureName,"BarnSpace_Click");
         UI.displayMiniMarketDialog(m_marketItems,null,"seed",null,true,false,false,true);
         this.m_window.close();
      }
      
      public function showFranchiseUI() : void
      {
         StatsManager.count(m_featureName,"Add_Click");
         UI.displayPopup(new CarribeanInnovationFranchiseWindow(m_featureName),false);
      }
      
      public function hasExpiryDatePassedForFeature() : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("8/20/2018") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         timeLeft = endTime - now;
         if(timeLeft <= 0)
         {
            result = true;
         }
         return result;
      }
      
      public function hasHarvestExpiryDatePassedForFeature() : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var timeRemain:int = 0;
         var finishTime:Number = NaN;
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("8/26/2018") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         timeLeft = endTime - now;
         if(timeLeft < 0)
         {
            timeRemain = this.getTimeLeftForBonusHarvest();
            finishTime = FarmGameUtil.synchronizedDateTimeToNumber("8/27/2018") / FarmGameUtil.NUM_MSECS_IN_SECOND;
            return finishTime - now <= timeRemain;
         }
         return false;
      }
      
      protected function onTransactionAdded(event:TransactionEvent) : void
      {
         this.checkForTaskUpdates(event);
      }
      
      protected function parseFeatureConfig() : void
      {
         var asset:XML = null;
         var feedConfigs:XMLList = null;
         var i:int = 0;
         var division:XML = null;
         var item:XML = null;
         var reward:XML = null;
         var config:XML = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         if(config != null)
         {
            this.m_isActive = true;
            this.m_currencyName = config["currency"]["@name"];
            this.m_endTimeStamp = FarmGameUtil.synchronizedDateToNumber(config["listEndDate"]);
            if(config.hasOwnProperty("assets"))
            {
               for each(asset in config.assets.asset)
               {
                  this.m_assetPaths[asset.@name] = asset.@path.toString();
               }
            }
            if(config.hasOwnProperty("feedConfig"))
            {
               feedConfigs = config.feedConfig.children();
               for(i = 0; i < feedConfigs.length(); i++)
               {
                  this.m_feedConfig[feedConfigs[i].@source.toString()] = new FeedData(m_featureName,feedConfigs[i]);
               }
            }
            if(config.hasOwnProperty("divisions"))
            {
               for each(division in config.divisions.division)
               {
                  for each(item in division.items.item)
                  {
                     if(division.@name == "ea")
                     {
                        this.m_eaRewards.push(item.@name.toString());
                     }
                     else if(division.@name == "ga")
                     {
                        this.m_gaRewards.push(item.@name.toString());
                     }
                     else if(division.@name == "finalreward")
                     {
                        this.m_lastMilestoneRewards.push(item.@name.toString());
                     }
                  }
               }
            }
            if(config.hasOwnProperty("rewards"))
            {
               for each(reward in config.rewards.reward)
               {
                  this.m_finalRewards.push(reward.@name.toString());
               }
            }
         }
      }
      
      public function getTimeRemaining() : Array
      {
         var remainingDay:int = 0;
         var timeLeftMs:Number = this.m_endTimeStamp - GlobalEngine.serverTime;
         timeLeftMs = timeLeftMs < 0 ? 0 : timeLeftMs;
         var remainingTime:Array = FarmGameUtil.parseTimeLeft(timeLeftMs / 1000);
         if(parseInt(remainingTime[0]) > 0)
         {
            remainingDay = parseInt(remainingTime[0]) + 1;
            remainingTime[0] = remainingDay.toString();
         }
         return remainingTime;
      }
      
      protected function parseTaskObjectsFromCOnfig(questName:String) : void
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
      
      public function gotSpecialRecipes(result:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,KEY_SPECIAL_RECIPES,result);
      }
      
      public function getSpecialRecipes() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,KEY_SPECIAL_RECIPES);
      }
      
      public function parseCraftingRecipes() : Object
      {
         var recipeList:XMLList = null;
         var recipeById:XML = null;
         var recipeId:int = 0;
         var recipeXml:XMLList = Global.farmGameSettingsManager.getXML().FrontierInnovationTables.CraftingRecipe;
         this.m_staticData.recipes = new Object();
         if(recipeXml)
         {
            recipeList = recipeXml.Recipe;
            for each(recipeById in recipeList)
            {
               recipeId = int(recipeById.@id);
               this.m_staticData["recipes"][recipeId] = new Array();
               this.m_staticData["recipes"][recipeId].push({
                  "id":recipeById.@id,
                  "asset":recipeById.@asset,
                  "name":recipeById.@name,
                  "points":recipeById.@points,
                  "re1code":recipeById.Re1.@code,
                  "re2code":recipeById.Re2.@code,
                  "re3code":recipeById.Re3.@code,
                  "re1quant":recipeById.Re1.@qty,
                  "re2quant":recipeById.Re2.@qty,
                  "re3quant":recipeById.Re3.@qty
               });
            }
         }
         return this.m_staticData["recipes"];
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
         if(hasCompletedTask)
         {
            if(this.m_frontierInnovationHud)
            {
               this.m_frontierInnovationHud.refresh(1);
            }
         }
      }
      
      public function saveBushelProgress() : void
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
               taskObj[this.KEY_ID] = tasks[i].id;
            }
            if(tasks[i].helperType == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
            {
               taskObj[this.KEY_PROGRESS] = CraftingManager.getInstance().getBushelQuantityInInventory(tasks[i].type);
            }
            else
            {
               taskObj[this.KEY_PROGRESS] = savedTasks[i][this.KEY_PROGRESS];
            }
            tasksToSave.push(taskObj);
         }
         this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,tasksToSave as Object);
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
               taskObj[this.KEY_ID] = tasks[i].id;
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
      
      public function updateFeatureProgress(pointsToAdd:int) : *
      {
         FeatureOptionsInventoryManager.getInstance().addCount(FRONTIER_FEATURE_POINTS_ITEM_CODE,pointsToAdd);
         if(this.m_window)
         {
            this.m_window.updateProgressBar(this.getNPCProgress(),this.m_window.m_meter_mc);
            this.m_window.updatePointerPosition(this.getNPCProgress(),this.m_window.m_pointerMc);
            this.m_window.refreshWindow();
         }
      }
      
      public function showTileUnlockCountMc() : Number
      {
         var currentCapacity:int = 0;
         var assumedResult:int = 0;
         var result:int = 0;
         var inventoryTileCount:Number = FeatureOptionsInventoryManager.getInstance().getCount(FRONTIER_TILE_UNLOCK_COUNT);
         var count:Object = this.getFeatureOptionsKey(KEY_TILE_UNLOCK_COUNT) as Object;
         if(!this.isFinalRewardChosen())
         {
            if(Boolean(inventoryTileCount) && inventoryTileCount > count)
            {
               result = inventoryTileCount - (count as Number);
               currentCapacity = this.getTotalBarnCapacity();
               assumedResult = (this.MAX_BARN_CAPACITY - currentCapacity) / this.TUNING_BARN_CAPACITY;
               result = Math.min(assumedResult,result);
               this.upgradeBarnCapacityByTile(result);
            }
         }
         return result;
      }
      
      public function getTileUnlockCount() : Number
      {
         var inventoryTileCount:Number = FeatureOptionsInventoryManager.getInstance().getCount(FRONTIER_TILE_UNLOCK_COUNT) as Number;
         return inventoryTileCount ? inventoryTileCount : 0;
      }
      
      public function getUpgradeFrameData() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,this.KEY_UPGRADE_RESOURCES);
      }
      
      public function getSortedUpgradeFrameData() : Array
      {
         var i:String = null;
         var data:Object = this.getUpgradeFrameData();
         var sorted:Array = [];
         for(i in data)
         {
            sorted.push({
               "key":i,
               "value":data[i]
            });
         }
         sorted.sortOn("key");
         return sorted;
      }
      
      public function getBasicFrameData() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,this.KEY_BASIC_RESOURCES);
      }
      
      public function getSortedBasicFrameData() : Array
      {
         var i:String = null;
         var data:Object = this.getBasicFrameData();
         var sorted:Array = [];
         for(i in data)
         {
            sorted.push({
               "key":i,
               "value":data[i]
            });
         }
         sorted.sortOn("key");
         return sorted;
      }
      
      public function getLuxuryFrameData() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,this.KEY_LUXURY_RESOURCES);
      }
      
      public function getSortedLuxuryFrameData() : Array
      {
         var i:String = null;
         var data:Object = this.getLuxuryFrameData();
         var sorted:Array = [];
         for(i in data)
         {
            sorted.push({
               "key":i,
               "value":data[i]
            });
         }
         sorted.sortOn("key");
         return sorted;
      }
      
      public function addTileFeatureOptions() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"addTileUnlock",this.onComplete,new Array(m_featureName)),true);
      }
      
      public function onComplete(result:Object) : void
      {
         var inventoryTileCount:Number = NaN;
         if(result)
         {
            inventoryTileCount = FeatureOptionsInventoryManager.getInstance().getCount(FRONTIER_TILE_UNLOCK_COUNT);
            if(inventoryTileCount)
            {
               FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,KEY_TILE_UNLOCK_COUNT,inventoryTileCount);
            }
         }
      }
      
      public function initEventListener() : void
      {
         GlobalEventManager.getInstance().addEventListener(EVENT_FRONTIER_INNOVATION_TILE_UNLOCK,this.showGrantPopup);
         this.initTradeTimer();
      }
      
      public function initTradeTimer() : void
      {
         if(!this.m_timer && this.getTradePostNonEmptySlotCount() > 0)
         {
            this.m_timer = new Timer(Global.flashHotParams["FRONTIERINNOVATION_TRADING_TIMER"]);
            this.m_timer.addEventListener("timer",this.refreshTradebyTimer);
            this.m_timer.start();
         }
      }
      
      public function deleteEventListener() : void
      {
         GlobalEventManager.getInstance().removeEventListener(EVENT_FRONTIER_INNOVATION_TILE_UNLOCK,this.showGrantPopup);
         if(this.m_timer)
         {
            this.m_timer.stop();
         }
      }
      
      public function showGrantPopup(e:TileUnlockEvent = null) : void
      {
         if(!this.isBarnCapacityReached())
         {
            StatsManager.count(m_featureName,"TileBoost","","10",this.getTotalBarnCapacity().toString());
            UI.displayPopup(new CarribeanTileUnlockWindow(this.TILE_UNLOCK_ASSET,m_featureName,e.tileData.getItemName()));
         }
      }
      
      protected function getFeatureOptionsKey(optionName:String) : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,optionName);
      }
      
      protected function saveFeatureOptionsKey(optionName:String, optionsValue:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,optionName,optionsValue);
      }
      
      override public function getTasks() : Vector.<FarmTask>
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
               taskXML = this.m_tasksById[task[this.KEY_ID]];
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
                  taskObj = new Object();
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
      
      public function npcmovements() : void
      {
         var timeStamp:Number = NaN;
         var hourdiff:int = 0;
         var npcm:Object = this.getFeatureOptionsKey(KEY_NPC_MOVEMENTS);
         if(npcm != null)
         {
            timeStamp = Number(npcm[KEY_TIMESTAMP]);
            hourdiff = (GlobalEngine.serverTime - timeStamp * 1000) / 3600000;
            if(Boolean(hourdiff) && Boolean(npcm[KEY_TIMESTAMP]))
            {
               npcm[KEY_NPC1] += this.firstNpcMovemet(hourdiff);
               npcm[KEY_NPC2] += this.secondNpcMovemet(hourdiff);
               npcm[KEY_NPC3] += this.thirdNpcMovemet(hourdiff);
               npcm[KEY_TIMESTAMP] = timeStamp + hourdiff * 3600;
               this.saveFeatureOptionsKey(KEY_NPC_MOVEMENTS,npcm);
            }
         }
      }
      
      public function getBoardFrameNumber() : Number
      {
         return this.getFeatureOptionsKey(KEY_SAVED_BOARD_COUNT) as Number;
      }
      
      protected function firstNpcMovemet(hours:int) : int
      {
         var firstNpcMovement:Number = NaN;
         var featureShownTimeStamp:Number = this.getFeatureOptionsKey(KEY_SAVED_FEATURE_SHOWN_TIMESTAMP) as Number;
         var numOfHour1:Number = 0;
         if(this.m_isEA)
         {
            numOfHour1 = (VAL_EA_NPC1 - featureShownTimeStamp) / 3600;
         }
         else
         {
            numOfHour1 = (VAL_GA_NPC1 - featureShownTimeStamp) / 3600;
         }
         firstNpcMovement = VAL_FINAL_MILESTONE / numOfHour1 * hours;
         return Math.round(firstNpcMovement);
      }
      
      protected function secondNpcMovemet(hours:int) : int
      {
         var secondNpcMovemet:Number = NaN;
         var featureShownTimeStamp:Number = this.getFeatureOptionsKey(KEY_SAVED_FEATURE_SHOWN_TIMESTAMP) as Number;
         var numOfHour2:Number = 0;
         if(this.m_isEA)
         {
            numOfHour2 = (VAL_EA_NPC2 - featureShownTimeStamp) / 3600;
         }
         else
         {
            numOfHour2 = (VAL_GA_NPC2 - featureShownTimeStamp) / 3600;
         }
         secondNpcMovemet = VAL_FINAL_MILESTONE / numOfHour2 * hours;
         return Math.round(secondNpcMovemet);
      }
      
      protected function thirdNpcMovemet(hours:int) : int
      {
         var thirdNpcMovemet:Number = NaN;
         var featureShownTimeStamp:Number = this.getFeatureOptionsKey(KEY_SAVED_FEATURE_SHOWN_TIMESTAMP) as Number;
         var numOfHour3:Number = 0;
         if(this.m_isEA)
         {
            numOfHour3 = (VAL_EA_NPC3 - featureShownTimeStamp) / 3600;
         }
         else
         {
            numOfHour3 = (VAL_GA_NPC3 - featureShownTimeStamp) / 3600;
         }
         thirdNpcMovemet = VAL_FINAL_MILESTONE / numOfHour3 * hours;
         return Math.round(thirdNpcMovemet);
      }
      
      public function setSpecialRecipe() : void
      {
         var timestamp:int = 0;
         var currentTime:Number = NaN;
         var timeLeft:int = 0;
         var recipeData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,KEY_SPECIAL_RECIPES);
         if(recipeData)
         {
            timestamp = int(recipeData[1]);
            if(timestamp != -1)
            {
               currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
               timeLeft = int(Math.abs(currentTime - timestamp) / FarmGameUtil.NUM_SECS_IN_HOUR);
               if(timeLeft >= 24)
               {
                  TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getSpecialRecipes",this.gotSpecialRecipes,[m_featureName]),true);
               }
            }
         }
      }
      
      private function onInitQuestComplete(callback:Function, result:Object) : void
      {
         this.m_resultObject = result;
         if(Boolean(result) && result.hasOwnProperty("featureData"))
         {
            FeatureOptionsManager.getInstance().setFeature(m_featureName,result["featureData"]);
            if(Boolean(callback))
            {
               callback.call();
            }
         }
         if(Boolean(result) && result.hasOwnProperty("activeTasks"))
         {
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,result["activeTasks"]);
            if(Boolean(callback))
            {
               callback.call();
            }
         }
         if(this.m_window)
         {
            this.m_window.refreshWindow();
         }
      }
      
      private function updateBoardFrameNumber() : void
      {
         var boardNumber:Number = this.getBoardFrameNumber();
         boardNumber++;
         if(boardNumber > 17)
         {
            boardNumber = 9;
         }
         this.saveFeatureOptionsKey(KEY_SAVED_BOARD_COUNT,boardNumber);
      }
      
      public function startQuest(callback:Function = null) : void
      {
         var savedTaskInfo:Array = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
         if(!(savedTaskInfo && savedTaskInfo.length))
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startQuest",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName)),true);
            this.saveFeatureOptionsKey(KEY_SAVED_BOARD_COUNT,1);
         }
      }
      
      public function redeemRewardPoints(questIndex:int, callback:Function, taskPoints:int = 0) : void
      {
         var tasks:Vector.<FarmTask> = this.getTasks();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"redeemRewardPoints",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,questIndex)),true);
         this.resetActionCountsForTasks(tasks[questIndex]);
         this.updateBoardFrameNumber();
      }
      
      public function skipTask(questIndex:int, callback:Function) : void
      {
         var savedTasks:Array = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         if(Global.player.canBuyCash(tasks[questIndex].skipCashValue))
         {
            Global.player.cash -= tasks[questIndex].skipCashValue;
            savedTasks = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
            savedTasks[questIndex][this.KEY_PROGRESS] = tasks[questIndex].total;
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,savedTasks);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,questIndex)),true);
            this.resetActionCountsForTasks(tasks[questIndex]);
            this.updateBoardFrameNumber();
         }
         else
         {
            callback.call();
         }
      }
      
      public function goBack() : void
      {
      }
      
      public function goNext() : void
      {
      }
      
      public function getBuildingCurrentAsset() : String
      {
         var itemName:String = null;
         var item:FarmItem = null;
         var score:Number = this.getNPCProgress();
         switch(true)
         {
            case score < VAL_FIRST_MILESTONE:
               return Global.getAssetURL(this.BUILDING_ASSET0);
            case score < VAL_SECOND_MILESTONE && score >= VAL_FIRST_MILESTONE:
               return Global.getAssetURL(this.BUILDING_ASSET1);
            case score < VAL_THIRD_MILESTONE && score >= VAL_SECOND_MILESTONE:
               return Global.getAssetURL(this.BUILDING_ASSET2);
            case score < VAL_FINAL_MILESTONE && score >= VAL_THIRD_MILESTONE:
               return Global.getAssetURL(this.BUILDING_ASSET3);
            default:
               if(FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,KEY_SAVED_FINAL_REWARD_BUILDINGNAME) != "0" && FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,KEY_SAVED_FINAL_REWARD_BUILDINGNAME) != null)
               {
                  itemName = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,KEY_SAVED_FINAL_REWARD_BUILDINGNAME) as String;
                  item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
                  return item.getImageByName("feed");
               }
               return null;
         }
      }
      
      public function skipDumpedTask(questIndex:int, callback:Function) : void
      {
         var dumpTimestamp:Object = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         if(Global.player.canBuyCash(SKIP_COST))
         {
            Global.player.cash -= SKIP_COST;
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipDumpedTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,questIndex)),true);
            dumpTimestamp = this.getFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP) as Object;
            dumpTimestamp[questIndex] = 0;
            this.saveFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP,dumpTimestamp);
            this.resetActionCountsForTasks(tasks[questIndex]);
         }
         else
         {
            callback.call();
         }
      }
      
      public function dumpTask(questIndex:int, callback:Function) : void
      {
         var dumpTimestamp:Object = null;
         if(this.canDumpTask(questIndex))
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"dumpTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,questIndex)),true);
            dumpTimestamp = this.getFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP) as Object;
            if(dumpTimestamp == null)
            {
               dumpTimestamp = new Object();
            }
            dumpTimestamp[questIndex] = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            this.saveFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP,dumpTimestamp);
         }
      }
      
      public function canDumpTask(questIndex:int) : Boolean
      {
         var currentTime:Number = NaN;
         var result:Boolean = true;
         var throttleTimeInSeconds:Number = 2 * FarmGameUtil.NUM_SECS_IN_HOUR;
         var dumpTimestamp:Object = this.getFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP) as Object;
         if(dumpTimestamp != null && dumpTimestamp.hasOwnProperty(questIndex.toString()))
         {
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            result = currentTime - dumpTimestamp[questIndex] > throttleTimeInSeconds;
         }
         return result;
      }
      
      public function getTimeRemainingForDumpedTask(questIndex:int) : Number
      {
         var result:Number = NaN;
         var currentTime:Number = NaN;
         var throttleTimeInSeconds:Number = 2 * FarmGameUtil.NUM_SECS_IN_HOUR;
         var dumpTimestamp:Object = this.getFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP) as Object;
         if(dumpTimestamp != null && dumpTimestamp.hasOwnProperty(questIndex.toString()))
         {
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            result = throttleTimeInSeconds - (currentTime - dumpTimestamp[questIndex]);
         }
         return result;
      }
      
      public function getNewTasks(questIndex:int, callback:Function) : void
      {
         var tasks:Vector.<FarmTask> = this.getTasks();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getNewTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,questIndex)),true);
         var dumpTimestamp:Object = this.getFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP) as Object;
         dumpTimestamp[questIndex] = 0;
         this.saveFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP,dumpTimestamp);
         this.resetActionCountsForTasks(tasks[questIndex]);
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
            this.grantPointsForTask(tasks[questIndex].questPoints);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkGold",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,questIndex)),true);
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
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkBushel",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,questIndex)),true);
         StatsManager.count(m_featureName,"Sink Bushel","",tasks[questIndex].total.toString(),this.getOrderboardProgress().toString());
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
      
      override public function getRewards() : Vector.<Object>
      {
         return null;
      }
      
      public function isFinalRewardChosen() : Boolean
      {
         if(this.getRewardBuildingName() != null && this.getRewardBuildingName() != "0")
         {
            return true;
         }
         return false;
      }
      
      public function isFinalRewardGranted() : Boolean
      {
         var finalRewardTaken:int = this.getFeatureOptionsKey(KEY_SAVED_FINAL_REWARD_RECEIVED) as int;
         if(finalRewardTaken)
         {
            return true;
         }
         return false;
      }
      
      public function grantFinalReward() : void
      {
         var position:int = 0;
         var finalMileStoneReward:String = null;
         var rewardItem:FarmItem = null;
         var featureKey:String = m_featureName + "_lastmilestone_";
         var finalRewardTaken:int = this.getFeatureOptionsKey(KEY_SAVED_FINAL_REWARD_RECEIVED) as int;
         this.m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_NEWFRONTIER);
         var iconUrl:String = "assets/dialogs/newfrontier/innovation/xnf_pack4_200.png";
         if(!finalRewardTaken)
         {
            finalMileStoneReward = this.getFinalMileStoneReward(1);
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(finalMileStoneReward);
            Global.player.addGift(finalMileStoneReward);
            if(this.m_isEA)
            {
               finalMileStoneReward = this.getFinalMileStoneReward(2);
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName(finalMileStoneReward);
               Global.player.addGift(finalMileStoneReward);
               iconUrl = "assets/dialogs/newfrontier/innovation/xnf_pack4_EA_200.png";
            }
            this.m_buildingUpgradeWindow = new FrontierInnovationBuildingUpgradeWindow(this.REWARD_POPUP_WINDOW,m_featureName + "_lastmilestone_",rewardItem,this.onClickOkButton,this.REWARD_WINDOW_IMAGE,iconUrl,"finalReward",true);
            UI.displayPopup(this.m_buildingUpgradeWindow,false);
            this.saveFeatureOptionsKey(KEY_SAVED_FINAL_REWARD_RECEIVED,1);
         }
         StatsManager.count(m_featureName,"Milestone","fourth");
      }
      
      public function onClickOkButton(e:MouseEvent) : void
      {
         var item:String = "xnf_hardyhome";
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(item);
         var iconUrl:String = "assets/buildings/xnf_hardyhome2_icon_200.png";
         if(this.m_buildingUpgradeWindow)
         {
            this.m_buildingUpgradeWindow = null;
         }
         this.m_buildingUpgradeWindow = new FrontierInnovationBuildingUpgradeWindow(this.REWARD_SHARE_WINDOW,m_featureName + "_lastmilestone",rewardItem,this.postFinalRewardFeed,this.REWARD_WINDOW_IMAGE,iconUrl,"hardyhome",false);
         UI.displayPopup(this.m_buildingUpgradeWindow,false);
         if(this.m_rewardWindow)
         {
            this.m_rewardWindow.close();
         }
         this.m_window.refreshWindow();
      }
      
      public function grantMilestoneReward() : void
      {
         var featureKey:String = null;
         var item:FarmItem = null;
         var milestonePosition:String = null;
         this.m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_NEWFRONTIER);
         var showReward:Boolean = false;
         var firstRewardGrant:Boolean = this.getFeatureOptionsKey(KEY_SAVED_FIRST_REWARD_RECEIVED) as Boolean;
         var secondRewardGrant:Boolean = this.getFeatureOptionsKey(KEY_SAVED_SECOND_REWARD_RECEIVED) as Boolean;
         var thirdRewardGrant:Boolean = this.getFeatureOptionsKey(KEY_SAVED_THIRD_REWARD_RECEIVED) as Boolean;
         var featureProgress:Number = this.getNPCProgress();
         if(featureProgress >= VAL_FIRST_MILESTONE && !firstRewardGrant)
         {
            showReward = true;
            milestonePosition = "first";
            featureKey = m_featureName + "_first_milestone_reward";
            this.saveFeatureOptionsKey(KEY_SAVED_FIRST_REWARD_RECEIVED,true);
            this.m_rewardName = this.getMilestoneRewardItemName(0);
         }
         else if(featureProgress >= VAL_SECOND_MILESTONE && !secondRewardGrant)
         {
            showReward = true;
            milestonePosition = "second";
            featureKey = m_featureName + "_second_milestone_reward";
            this.saveFeatureOptionsKey(KEY_SAVED_SECOND_REWARD_RECEIVED,true);
            this.m_rewardName = this.getMilestoneRewardItemName(1);
         }
         else if(featureProgress >= VAL_THIRD_MILESTONE && !thirdRewardGrant)
         {
            showReward = true;
            milestonePosition = "third";
            featureKey = m_featureName + "_third_milestone_reward";
            this.saveFeatureOptionsKey(KEY_SAVED_THIRD_REWARD_RECEIVED,true);
            this.m_rewardName = this.getMilestoneRewardItemName(2);
         }
         if(showReward)
         {
            Global.player.addGift(this.m_rewardName);
            item = Global.farmGameSettingsManager.getFarmItemByName(this.m_rewardName);
            if(milestonePosition == "second")
            {
               this.m_buildingUpgradeRewardWindow = new CarribeanGenericSingleRewardPopup(this.REWARD_POPUP_WINDOW,featureKey,item,this.showBuildingUpgradePopup,this.REWARD_WINDOW_IMAGE);
               UI.displayPopup(this.m_buildingUpgradeRewardWindow,false);
            }
            else
            {
               this.m_rewardWindow = new GenericSingleRewardPopup(this.REWARD_SHARE_WINDOW,featureKey,item,this.postMilestoneBragFeed,this.REWARD_WINDOW_IMAGE);
               UI.displayPopup(this.m_rewardWindow,false);
            }
            StatsManager.count(m_featureName,"Milestone",milestonePosition);
         }
      }
      
      private function showBuildingUpgradePopup(event:Event) : void
      {
         this.m_rewardName = this.getMilestoneRewardItemName(1);
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_rewardName);
         if(this.m_rewardWindow)
         {
            this.m_rewardWindow.close();
         }
         var featureKey:String = m_featureName + "buildingUpgrade";
         var iconUrl:String = "assets/buildings/xnf_hardyhome1_icon_200.png";
         this.m_buildingUpgradeWindow = new FrontierInnovationBuildingUpgradeWindow(this.REWARD_SHARE_WINDOW,featureKey,item,this.postBuildingUpgradeBragFeed,this.REWARD_WINDOW_IMAGE,iconUrl,"hardy",false);
         UI.displayPopup(this.m_buildingUpgradeWindow,false);
      }
      
      public function showFinalRewardPopup(selectedRewardName:String, position:int) : void
      {
         var finalMileStoneReward:String = this.getFinalMileStoneReward(position);
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(selectedRewardName);
         UI.displayPopup(new CongratsForNewBrazilInovationWindow("assets/dialogs/expansion/FV_RewardDialog_Share.swf",m_featureName + "lastmilestone",rewardItem,null,null,finalMileStoneReward),false);
      }
      
      public function getMilestoneRewardItemName(index:int) : String
      {
         var itemName:String = null;
         if(this.m_isEA)
         {
            itemName = this.m_eaRewards[index];
         }
         else
         {
            itemName = this.m_gaRewards[index];
         }
         return itemName;
      }
      
      public function getFinalMileStoneReward(position:int) : String
      {
         position--;
         return this.m_lastMilestoneRewards[position];
      }
      
      public function getFinalRewardInIntermediateState() : String
      {
         return this.m_finalRewards[0];
      }
      
      public function getFinalReward() : Array
      {
         return this.m_finalRewards;
      }
      
      public function get currencyName() : String
      {
         return this.m_currencyName;
      }
      
      public function getNPCProgress() : Number
      {
         return FeatureOptionsInventoryManager.getInstance().getCount(FRONTIER_FEATURE_POINTS_ITEM_CODE);
      }
      
      public function getOrderboardProgress() : Number
      {
         return FeatureOptionsInventoryManager.getInstance().getCount(FRONTIER_ORDERBOARD_POINTS_ITEM_CODE);
      }
      
      public function setOrderboardProgress(picaxCount:int) : void
      {
         FeatureOptionsInventoryManager.getInstance().removeCount(FRONTIER_ORDERBOARD_POINTS_ITEM_CODE,picaxCount);
      }
      
      public function isFirstMilestoneAchieved() : Boolean
      {
         return this.getFeatureOptionsKey(KEY_SAVED_FIRST_REWARD_RECEIVED) as Boolean;
      }
      
      public function getRewardBuildingName() : String
      {
         return this.getFeatureOptionsKey(KEY_SAVED_FINAL_REWARD_BUILDINGNAME) as String;
      }
      
      public function isSecondMilestoneAchieved() : Boolean
      {
         return this.getFeatureOptionsKey(KEY_SAVED_SECOND_REWARD_RECEIVED) as Boolean;
      }
      
      public function isThirdMilestoneAchieved() : Boolean
      {
         return this.getFeatureOptionsKey(KEY_SAVED_THIRD_REWARD_RECEIVED) as Boolean;
      }
      
      private function postFinalRewardFeed(event:Event) : void
      {
         if(Boolean(this.m_resultObject) && Boolean(this.m_resultObject["feedFinalRewardData"]))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(this.m_resultObject["feedFinalRewardData"]);
         }
         if(this.m_rewardWindow)
         {
            this.m_rewardWindow.close();
         }
         if(this.m_buildingUpgradeRewardWindow)
         {
            this.m_buildingUpgradeRewardWindow.close();
         }
      }
      
      private function postMilestoneBragFeed(event:Event) : void
      {
         if(Boolean(this.m_resultObject) && Boolean(this.m_resultObject["feedData"]))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(this.m_resultObject["feedData"]);
         }
         if(this.m_rewardWindow)
         {
            this.m_rewardWindow.close();
         }
         if(this.m_buildingUpgradeRewardWindow)
         {
            this.m_buildingUpgradeRewardWindow.close();
         }
      }
      
      private function postBuildingUpgradeBragFeed(event:Event) : void
      {
         if(Boolean(this.m_resultObject) && Boolean(this.m_resultObject["feedBuildingData"]))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(this.m_resultObject["feedBuildingData"]);
         }
         if(this.m_rewardWindow)
         {
            this.m_rewardWindow.close();
         }
         if(this.m_buildingUpgradeRewardWindow)
         {
            this.m_buildingUpgradeRewardWindow.close();
         }
      }
      
      protected function getFeatureOption() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName);
      }
      
      public function canCollectConsumables() : Boolean
      {
         var canCollect:Boolean = true;
         var key:String = FRONTIER_FEATURE_POINTS_ITEM_CODE;
         if(this.getTimeLeft(key,DEFAULT_COLLECT_THROTTLE_TIME / 2) > 0 || this.getTileUnlockCount() == 0)
         {
            canCollect = false;
         }
         return canCollect;
      }
      
      public function getTimeLeft(key:String, throttleTime:int = 86400) : int
      {
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         return int(throttleTime - timeSinceLastFeed);
      }
      
      public function isFeatureComplete() : Boolean
      {
         var score:Number = this.getNPCProgress();
         return score >= VAL_FINAL_MILESTONE;
      }
      
      public function grantPointsForTask(pointsForTask:int) : void
      {
         var currentProgress:Number = this.getOrderboardProgress();
         if(currentProgress < VAL_FINAL_MILESTONE)
         {
            FeatureOptionsInventoryManager.getInstance().addCount(FRONTIER_ORDERBOARD_POINTS_ITEM_CODE,pointsForTask);
            if(!Global.player.getSeenFlag(FEATURE_FORCED_TUT_FRIST_STEP) && currentProgress + pointsForTask >= 5 && Boolean(this.m_window))
            {
               Global.player.setSeenFlag(FEATURE_FORCED_TUT_FRIST_STEP);
               this.m_window.setForcedTut();
            }
         }
      }
      
      public function harvestFinalBuilding(itemName:String = null) : void
      {
         var count:int = 0;
         var key:String = LAST_BONUS_HARVEST_TIME_KEY;
         Global.player.setFeatureLastShown(key,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         var harvestRewardName:String = this.getNextHarvestItemName();
         var harvestFarmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(harvestRewardName);
         if(harvestFarmItem)
         {
            count = 1;
            Global.player.addGift(harvestRewardName);
            FarmStatsManager.count(m_featureName,"Harvest",itemName,harvestRewardName);
            UI.displayPopup(new GenericSingleRewardPopup(this.REWARD_POPUP_WINDOW,"FrontierInnovation_daily_harvest_reward",harvestFarmItem,null,this.REWARD_WINDOW_IMAGE));
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,this.SERVICE_FUNC_HARVEST_BONUS,null,[m_featureName]),true);
         }
      }
      
      public function getTimeLeftForBonusHarvest() : int
      {
         var timeLeft:int = 0;
         var key:String = LAST_BONUS_HARVEST_TIME_KEY;
         var throttleTime:int = DEFAULT_HARVEST_THROTTLE_TIME;
         return this.getTimeLeft(key,throttleTime);
      }
      
      public function IsBonusBuildingReadyToHarvest() : Boolean
      {
         var result:Boolean = false;
         if(this.getTimeLeftForBonusHarvest() <= 0)
         {
            result = true;
         }
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("frontier_innovation_harvest_enabled");
         if(!PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            result = false;
         }
         if(this.getNPCProgress() < 3000)
         {
            result = false;
         }
         return result;
      }
      
      public function getHervestTime() : String
      {
         var result:String = null;
         var secondsLeft:int = this.getTimeLeftForBonusHarvest();
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
      
      private function getNextHarvestItemName() : String
      {
         var harvestReward:String = null;
         var bonusCount:int = 0;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName);
         if(featureData.hasOwnProperty(this.BONUS_HARVEST_COUNT))
         {
            bonusCount = featureData[this.BONUS_HARVEST_COUNT] as int;
         }
         else
         {
            featureData[this.BONUS_HARVEST_COUNT] = 0;
            bonusCount = 0;
         }
         harvestReward = this.BONUS_HARVEST_ARRAY[bonusCount % this.BONUS_HARVEST_ARRAY.length];
         featureData[this.BONUS_HARVEST_COUNT] = bonusCount + 1;
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,m_featureName,featureData);
         return harvestReward;
      }
      
      public function setRedeemCallout(flag:Boolean = false) : void
      {
         this.m_showRedeemCallout = flag;
      }
   }
}

