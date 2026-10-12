package Managers.OrderBoard
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.ArrowType;
   import Classes.Constants.Experiments;
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
   import Display.HUD.HUDWidgets.HudBottomCarribeanInnovationButton;
   import Display.HUD.HUDWidgets.HudBottomFrontierInnovationButton;
   import Display.QueuedIcons.QueuedIconWithArrow;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.FarmGameWorldEvent;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.WorldSeasonsManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.CarribeanGenericSingleRewardPopup;
   import Widgets.Windows.CarribeanInnovationAchievementRewardPopup;
   import Widgets.Windows.CarribeanInnovationAchievementWindow;
   import Widgets.Windows.CongratsForNewBrazilInovationWindow;
   import Widgets.Windows.CongratsForNewCaribbeanInovationWindow;
   import Widgets.Windows.FarmRunV7OrderBoardWindow;
   import Widgets.Windows.FarmRunV7QuestionarreWindow;
   import Widgets.Windows.FarmRunV7QuizDetailsWindow;
   import Widgets.Windows.FarmRunV7ScoreBoardWindow;
   import Widgets.Windows.FarmRunV7SingleRewardPopup;
   import Widgets.Windows.FarmRunV7Window;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FrontierInnovationBarnWindow;
   import Widgets.Windows.FrontierInnovationBuildingUpgradeWindow;
   import Widgets.Windows.FrontierInnovationForageRewardPopUp;
   import Widgets.Windows.FrontierInnovationTradePostWindow;
   import Widgets.Windows.GenericSingleRewardPopup;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class FarmRunV7Manager extends SpecialQuestManager
   {
      
      private static const SERVICE_NAME:String = "FarmRunV7Service";
      
      public static const FEATURE_NAME:String = "FarmRunV7";
      
      public static const FARMRUN_QUIZ_TIMER_RAN_OUT_FLAG:String = "FarmRunV7_QuizTimerRanOut";
      
      public static const FEATURE_TRACKING:String = "GPF_FarmRunV7";
      
      public static const FEATURE_OPTIONS_KEY:String = "FarmRunV7";
      
      public static const FV_FARMRUN2018_QUESTION:String = "count";
      
      public static const FV_FARMRUN2018_SCORE:String = "score";
      
      public static const FV_FARMRUN2018_QUESTION_START:String = "start";
      
      public static const FV_FARMRUN2018_CURRENT_STATE:String = "state";
      
      public static const FV_FARMRUN2018_QUESTION1:String = "q1";
      
      public static const FV_FARMRUN2018_QUESTION2:String = "q2";
      
      public static const FV_FARMRUN2018_QUESTION3:String = "q3";
      
      public static const KEY_QUESTIONAIRE_STATE:int = 1;
      
      public static const KEY_ORDERBOARD_STATE:int = 0;
      
      private static const KEY_SAVED_ACTIVE_TASKS:String = "1";
      
      public static const ACHIEVEMENT_POINTS_ARRAY:Array = new Array(250,500,750,950);
      
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
      
      private static const KEY_TIMESTAMP:String = "timestamp";
      
      private static const KEY_POINTS:String = "points";
      
      private static const VAL_EA_NPC1:Number = 1506063599;
      
      private static const VAL_EA_NPC2:Number = 1506236399;
      
      private static const VAL_EA_NPC3:Number = 1506409199;
      
      private static const VAL_GA_NPC1:Number = 1506322799;
      
      private static const VAL_GA_NPC2:Number = 1506495599;
      
      private static const VAL_GA_NPC3:Number = 1506668399;
      
      public static const VAL_FIRST_MILESTONE:int = 250;
      
      public static const VAL_SECOND_MILESTONE:int = 600;
      
      public static const VAL_THIRD_MILESTONE:int = 950;
      
      public static const VAL_FINAL_MILESTONE:int = 1400;
      
      private static const SKIP_COST:int = 2;
      
      private static const KEY_COMPLETED:String = "task_completed";
      
      private static const KEY_COMPLETED_TASKS:String = "completedTasks";
      
      private static const WINDOW_MAIN:String = "main";
      
      private static const WINDOW_ORDERBOARD:String = "orderboard";
      
      private static const WINDOW_QUESTIONARRE:String = "questionarre";
      
      private static const WINDOW_SCORE:String = "questionarre";
      
      private static const WINDOW_MILESTONE_REWARD:String = "milestone_reward";
      
      public static const WINDOW_FINAL_REWARD:String = "k11";
      
      private static const WINDOW_NPC_FINAL_REWARD:String = "npc_final_reward";
      
      private static const WINDOW_REWARDS:String = "rewards";
      
      private static const WINDOW_ACHIEVEMENT:String = "achievement";
      
      private static const WINDO_FINAL_REWARDS_SELECTION:String = "final_reward_selection";
      
      private static const WINDOW_BOOST:String = "boost";
      
      public static const QUIZ_TIME_LIMIT:Number = 60000;
      
      private static const SPECIAL_TILE_NAME:String = "xdw_rubbletreasure_special";
      
      private static const TILE_UNLOCK_COUNT:String = "tuc";
      
      public static const KEY_REWARD_GRANT_COUNT:String = "reward_grant_count";
      
      public static const FARMRUN_HAWAII_QUESTION_COUNT:int = 15;
      
      public static const FARMRUN_ASIA_QUESTION_COUNT:int = 18;
      
      public static const FARMRUN_ENGLAND_QUESTION_COUNT:int = 21;
      
      public static const FARMRUN_FISHERMAN_QUESTION_COUNT:int = 15;
      
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
      
      private static const LAST_BONUS_HARVEST_TIME_KEY:String = "Last_bonus_harvest_time";
      
      public static const LAND_BUNDLE_UNLOCKED:String = "Caribbean_LandBundle_unlocked";
      
      public static const LAND_BUNDLE_POPUP:String = "Caribbean_LandBundle_popup";
      
      private static const KEY_SPECIAL_RECIPES:String = "special_recipes";
      
      private static const FIRST_TIME_TILE_UNLOCK:String = "First_time_tile_unlock";
      
      private static const TILE_UNLOCK:String = "Tile_Unlock";
      
      private static const FIRST_TIME_LANDBUNDLE_UNLOCK:String = "First_time_landbundle_unlock";
      
      private static const FIRST_TIME_LANDBUNDLE_ACTIVE:String = "First_time_landbundle_active";
      
      private const WORLD_REWARD_NAMES_ARRAY:Array = ["pegasus_palmwings","unicorn_winterready","pegasus_fisherman","horse_goldskin"];
      
      private const MILESTONE_REWARD_NAMES_ARRAY:Array = ["penguin_english","cow_oldfarm","rabbit_sailor","chicken_fisherman","chicken_beachready","sheep_beachdancer","wolf_samuraiwarrior","bigcat_ancienttravellerlion"];
      
      private var m_isEA:Boolean;
      
      private var m_hud:QueuedIconWithArrow;
      
      private var m_currencyName:String = "task_points";
      
      private var m_endTimeStamp:Number = 0;
      
      private var m_startTimeStamp:Number = 0;
      
      private var m_quizLimitTimeStamp:Number = 0;
      
      private var m_tasksById:Object = null;
      
      private var m_recipesById:Array = null;
      
      private var m_assetPaths:Object = {};
      
      private var m_eaRewards:Array = new Array();
      
      private var m_gaRewards:Array = new Array();
      
      private var m_worlds:Array = new Array();
      
      private var m_lastMilestoneRewards:Array = new Array();
      
      protected var m_featureData:Object = new Object();
      
      protected var m_staticData:Object = {};
      
      protected var m_rewards:Array = new Array();
      
      private var m_finalRewards:Array = new Array();
      
      private var m_questionData:Array = new Array();
      
      private var options:Array = new Array();
      
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
      
      private const TILE_UNLOCK_ASSET:String = "assets/dialogs/brazil/innovation/FV_xbr_Innovation_Prize.swf";
      
      private const LAND_BUNDLE_UNLOCK_POPUP:String = "assets/buildings/xcb_beachcafe.swf";
      
      private const REWARD_POPUP_WINDOW:String = "assets/dialogs/FarmRun2019_V7/FV_FarmRun2019_prize_V7.swf";
      
      private const REWARD_SHARE_WINDOW:String = "assets/dialogs/expansion/FV_RewardDialog_Share.swf";
      
      private const REWARD_WINDOW_IMAGE:String = "assets/dialogs/newfrontier/RewardDialog.png";
      
      public const KEY_SCORE:String = "farmrun_v7_score";
      
      protected const KEY_ID:String = "id";
      
      protected const KEY_PROGRESS:String = "progress";
      
      protected const KEY_TOTAL:String = "total";
      
      private var m_frontierInnovationHud:HudBottomFrontierInnovationButton;
      
      public const TILE_UNLOCK_POINTS:Number = 30;
      
      public var m_window:FarmRunV7Window;
      
      public var m_BarnWindow:FrontierInnovationBarnWindow;
      
      public var m_TradePostWindow:FrontierInnovationTradePostWindow;
      
      private var m_rewardWindow:FarmRunV7SingleRewardPopup;
      
      private var m_finalRewardWindow:FarmRunV7SingleRewardPopup;
      
      private var m_buildingUpgradeRewardWindow:CarribeanGenericSingleRewardPopup;
      
      private var m_forageRewardPopUp:FrontierInnovationForageRewardPopUp;
      
      private var m_rewardName:String;
      
      private var m_rewardItem:FarmItem;
      
      private var m_resultObject:Object;
      
      private var m_redeemResultObject:Object;
      
      private var m_isActive:Boolean = false;
      
      protected var m_owner:FeatureBuilding;
      
      private var m_CarribeanInnovationHud:HudBottomCarribeanInnovationButton;
      
      private const TILE_UNLOCK_LIMIT_FOR_POINTS:int = 8;
      
      private var m_achievementWindow:CarribeanInnovationAchievementWindow;
      
      private var m_achievementRewardWindow:CarribeanInnovationAchievementRewardPopup;
      
      private var m_buildingUpgradeWindow:FrontierInnovationBuildingUpgradeWindow;
      
      public var m_questionarreWindow:FarmRunV7QuestionarreWindow;
      
      public var m_orderBoardWindow:FarmRunV7OrderBoardWindow;
      
      public var m_scoreboardWindow:FarmRunV7ScoreBoardWindow;
      
      public var m_quizIntroWindow:FarmRunV7QuizDetailsWindow;
      
      private var m_rewardDailyWindow:GenericSingleRewardPopup;
      
      private var m_showRedeemCallout:Boolean = false;
      
      private var m_recipe:Object;
      
      private var m_timer:Timer;
      
      public const MAX_BARN_CAPACITY:int = 430;
      
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
      
      private const NO_OF_REWARDS:int = 12;
      
      private const KEY_FTUE:String = "FarmrunV7_ftue_flag";
      
      public function FarmRunV7Manager(featureName:String)
      {
         super(featureName);
         if(!this.featureConfig)
         {
            return;
         }
         this.parseFeatureConfig();
         this.parseTaskObjectsFromCOnfig(m_featureName);
         this.parseQuestionarreDataFromConfig(m_featureName);
         this.startQuest();
         this.setSpecialRecipe();
         this.m_featureData = this.getFeatureData();
         this.m_resultObject = new Object();
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
         this.setupHud();
      }
      
      public static function getInstance(featureName:String = "FarmRunV7") : FarmRunV7Manager
      {
         var instance:FarmRunV7Manager = getInstanceOfClass(featureName,FarmRunV7Manager) as FarmRunV7Manager;
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
      
      public function get worldArray() : Array
      {
         return this.m_worlds;
      }
      
      public function getworldWorldFromIndex(index:int) : String
      {
         return this.m_worlds[index];
      }
      
      public function getworldIndexFromName(name:String) : int
      {
         return this.worldArray.indexOf(name);
      }
      
      public function get isFeatureActive() : Boolean
      {
         return this.m_isActive;
      }
      
      public function getDialogUrl() : String
      {
         return "assets/dialogs/FarmRun2019_V7/FV_FarmRun2019_V7.swf";
      }
      
      public function getOrderboardUrl() : String
      {
         return "assets/dialogs/FarmRun2019_V7/FV_FarmRun2019_Orders_V7.swf";
      }
      
      public function getQuestionarreUrl() : String
      {
         return "assets/dialogs/FarmRun2019_V7/FV_FarmRun2019_Questions_V7.swf";
      }
      
      public function getScoreBoardUrl() : String
      {
         return "assets/dialogs/FarmRun2019_V7/FV_FarmRun2019_Messages_V7.swf";
      }
      
      public function showMainUI(val:Boolean = true) : void
      {
         if(val)
         {
            this.m_window = new FarmRunV7Window();
            UI.displayPopup(this.m_window,false);
         }
         if(this.getNPCProgress() < 1400)
         {
            this.updateMainUI();
         }
         StatsManager.count(FEATURE_TRACKING,"mainui","open");
      }
      
      public function updateMainUI() : void
      {
         if(Global.worldManager.currentWorldType == this.getFarmrunWorldFromPoints())
         {
            if(this.getCurrentState() == KEY_ORDERBOARD_STATE)
            {
               if(this.m_questionarreWindow)
               {
                  this.m_questionarreWindow.close();
               }
               this.openOrderBoardWindow();
            }
            else
            {
               if(this.m_orderBoardWindow)
               {
                  this.m_orderBoardWindow.close();
               }
               this.openQuestionarreWindow();
            }
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
      
      public function showRewardsUI() : void
      {
         var item:String = "xnf_hardyhome";
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(item);
         var window:FarmWindow = new CongratsForNewCaribbeanInovationWindow(this.m_assetPaths[WINDOW_REWARDS],m_featureName + "lastmilestone",rewardItem,null,null,item);
         StatsManager.count(m_featureName,"Awards_Click");
         UI.displayPopup(window,false);
         this.m_window.close();
      }
      
      public function hasExpiryDatePassedForFeature() : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("10/21/2019") / FarmGameUtil.NUM_MSECS_IN_SECOND;
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
      
      public function parseFeatureConfig() : void
      {
         var rewardObject:Object = null;
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
                     if(division.@name == "worlds")
                     {
                        this.m_worlds.push(item.@name.toString());
                     }
                     if(division.@name == "finalreward")
                     {
                        this.m_lastMilestoneRewards.push(item.@name.toString());
                     }
                  }
               }
            }
            rewardObject = {};
            if(config.hasOwnProperty("rewards"))
            {
               for each(reward in config.rewards.reward)
               {
                  rewardObject = {};
                  rewardObject["name"] = reward.@name.toString();
                  rewardObject["world"] = reward.@stage.toString();
                  rewardObject["points"] = reward.@cost.toString();
                  this.m_rewards.push(rewardObject);
               }
            }
         }
      }
      
      public function parseQuestionarreDataFromConfig(questName:String) : void
      {
         var worldName:String = null;
         var quest:String = null;
         var questionarreXml:XML = null;
         var questsList:XMLList = null;
         var questsByStage:XML = null;
         var questionData:Array = null;
         var m_OptionsBySlotName:Array = null;
         var questionNum:String = null;
         var questionText:String = null;
         var optionsXMLListbyStage:XMLList = null;
         var count:int = 0;
         var i:int = 0;
         var optionsBackup:Array = null;
         var object:Object = null;
         var option:String = null;
         this.m_quizLimitTimeStamp = GlobalEngine.serverTime + QUIZ_TIME_LIMIT;
         worldName = Global.worldManager.currentWorldType;
         quest = worldName + "_" + questName;
         questionarreXml = Global.farmGameSettingsManager.getXML().FarmRunV7Quests.FarmRunV7Quest.(@name == quest)[0];
         this.m_questionData = new Array();
         this.options = new Array();
         if(questionarreXml)
         {
            questsList = questionarreXml.FarmRunV7Questions.stage;
            for each(questsByStage in questsList)
            {
               questionData = new Array();
               m_OptionsBySlotName = new Array();
               questionNum = questsByStage.@id;
               questionText = questsByStage.@question;
               optionsXMLListbyStage = questsByStage.options;
               count = optionsXMLListbyStage.children().length();
               for(i = 0; i < count; i++)
               {
                  option = optionsXMLListbyStage.children()[i].@value;
                  m_OptionsBySlotName.push(option);
               }
               optionsBackup = m_OptionsBySlotName;
               object = {};
               object["questionNum"] = questionNum;
               object["questionText"] = questionText;
               if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FARMRUNQUESTS) == 2)
               {
                  object["options"] = optionsBackup;
               }
               else
               {
                  this.options = this.shuffleOptions(m_OptionsBySlotName);
                  object["options"] = this.options;
               }
               this.m_questionData.push(object);
            }
         }
      }
      
      public function getQuestionData() : Array
      {
         if(this.m_questionData == null)
         {
            this.parseQuestionarreDataFromConfig(FEATURE_NAME);
         }
         return this.m_questionData;
      }
      
      public function shuffleOptions(options:Array) : Array
      {
         var shuffled:Array = new Array();
         while(options.length > 0)
         {
            shuffled.push(options.splice(Math.round(Math.random() * (options.length - 1)),1)[0]);
         }
         return shuffled;
      }
      
      public function openQuestionarreWindow(showReward:Boolean = false) : void
      {
         FarmRunV7Manager.getInstance().openQuestionarreTutorial();
         this.resetfeatureData();
         if(Global.player.getSeenFlag(FARMRUN_QUIZ_TIMER_RAN_OUT_FLAG))
         {
            Global.player.resetSeenFlag(FARMRUN_QUIZ_TIMER_RAN_OUT_FLAG);
         }
         FarmStatsManager.count(m_featureName,"Click","Farmoffcommunity");
         FarmStatsManager.count(FEATURE_TRACKING,"Questionstart","Click","","Ready");
      }
      
      public function openQuestionarre(showReward:Boolean = false) : void
      {
         if(this.getNPCProgress() < VAL_FINAL_MILESTONE)
         {
            this.m_questionarreWindow = new FarmRunV7QuestionarreWindow("assets/dialogs/FarmRun2019_V7/FV_FarmRun2019_Questions_V7.swf",m_featureName);
            UI.displayPopup(this.m_questionarreWindow,false);
         }
         FarmStatsManager.count(m_featureName,"Click","Farmoffcommunity");
      }
      
      public function openOrderBoardWindow() : void
      {
         if(this.getNPCProgress() < VAL_FINAL_MILESTONE)
         {
            this.m_orderBoardWindow = new FarmRunV7OrderBoardWindow();
            this.startQuest(this.m_orderBoardWindow.refreshTaskFrame);
            UI.displayPopup(this.m_orderBoardWindow,false);
            if(this.m_window)
            {
               this.m_window.untintWindow();
               this.m_window.enableInput = true;
            }
         }
      }
      
      public function openScoreBoard() : void
      {
         this.m_scoreboardWindow = new FarmRunV7ScoreBoardWindow();
         UI.displayPopup(this.m_scoreboardWindow,false);
         if(this.m_window)
         {
            this.m_window.tintWindow();
            this.m_window.enableInput = false;
         }
      }
      
      public function openQuestionarreTutorial() : void
      {
         this.m_quizIntroWindow = new FarmRunV7QuizDetailsWindow();
         UI.displayPopup(this.m_quizIntroWindow,false);
         if(this.m_window)
         {
            this.m_window.tintWindow();
            this.m_window.enableInput = false;
         }
      }
      
      public function getTimeRemaining() : Array
      {
         var remainingSecs:int = 0;
         var timeLeftMs:Number = this.m_endTimeStamp - GlobalEngine.serverTime;
         timeLeftMs = timeLeftMs < 0 ? 0 : timeLeftMs;
         var remainingTime:Array = FarmGameUtil.parseTimeLeft(timeLeftMs / 1000);
         if(parseInt(remainingTime[0]) > 0)
         {
            remainingSecs = parseInt(remainingTime[0]) + 1;
            remainingTime[0] = remainingSecs.toString();
         }
         return remainingTime;
      }
      
      public function getQuizTimeRemaining() : int
      {
         var timeLeftMs:Number = (this.m_quizLimitTimeStamp - GlobalEngine.serverTime) / 1000;
         return parseInt(timeLeftMs.toString());
      }
      
      public function startTimer() : void
      {
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         if(this.m_questionarreWindow)
         {
            this.m_questionarreWindow.updateTime();
            if(this.getQuizTimeRemaining() <= 5 && this.getQuizTimeRemaining() > 0)
            {
               this.m_questionarreWindow.m_timeranimMc.visible = true;
            }
            if(this.getQuizTimeRemaining() <= 0)
            {
               Global.player.setSeenFlag(FARMRUN_QUIZ_TIMER_RAN_OUT_FLAG);
               this.stopTimer();
               this.incrementOverallScore();
               this.incrementQuestionCountForUnattempted();
               this.m_questionarreWindow.close();
               this.openScoreBoard();
            }
         }
      }
      
      public function stopTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
      }
      
      public function parseTaskObjectsFromCOnfig(questName:String) : void
      {
         var world:String = null;
         var orderBoardName:String = null;
         var orderBoardXml:XML = null;
         var tasksByDifficultyList:XMLList = null;
         var tasksByDiff:XML = null;
         var tasksByDiffAndTypeList:XMLList = null;
         var tasksByDiffAndType:XML = null;
         var taskXML:XML = null;
         this.m_tasksById = {};
         for each(world in this.m_worlds)
         {
            orderBoardName = questName + world;
            this.m_tasksById[world] = {};
            orderBoardXml = Global.farmGameSettingsManager.getXML().orderBoards.orderBoard.(@name == orderBoardName)[0];
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
                        this.m_tasksById[world][taskXML.@id] = taskXML;
                     }
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
            if(this.m_hud)
            {
               this.m_hud.attachArrow(ArrowType.ARROWUPDATE);
               this.m_hud.setArrowText("Progress!");
            }
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
      
      public function updateFeatureProgress(pointsToAdd:int) : void
      {
         this.saveFeatureOptionsKey(this.KEY_SCORE,this.getNPCProgress() + pointsToAdd);
         if(this.m_window)
         {
            this.m_window.updateProgressBar(this.getNPCProgress(),this.m_window.m_meter_mc);
            this.m_window.updatePointerPosition(this.getNPCProgress(),this.m_window.m_pointerMc);
            this.m_window.refreshWindow();
         }
      }
      
      public function getQuestionCount(key:String) : int
      {
         var count:int = this.getFeatureOptionsKey(FV_FARMRUN2018_QUESTION) as int;
         var currentWorld:String = Global.worldManager.currentWorldType;
         var total:int = this.getTotalQuestionsByWorld(currentWorld);
         return count % total;
      }
      
      public function getTotalQuestionsByWorld(world:String) : int
      {
         var val:int = 1;
         if(world == "hawaii")
         {
            val = FARMRUN_HAWAII_QUESTION_COUNT;
         }
         if(world == "asia")
         {
            val = FARMRUN_ASIA_QUESTION_COUNT;
         }
         if(world == "england")
         {
            val = FARMRUN_ENGLAND_QUESTION_COUNT;
         }
         if(world == "fisherman")
         {
            val = FARMRUN_FISHERMAN_QUESTION_COUNT;
         }
         return val;
      }
      
      public function incrementQuestionCount(key:String) : void
      {
         var count:int = this.getFeatureOptionsKey(FV_FARMRUN2018_QUESTION) as int;
         this.saveFeatureOptionsKey(FV_FARMRUN2018_QUESTION,count + 1);
      }
      
      public function incrementQuestionCountForUnattempted() : void
      {
         var count:int = this.getFeatureOptionsKey(FV_FARMRUN2018_QUESTION) as int;
         this.saveFeatureOptionsKey(FV_FARMRUN2018_QUESTION,count + 1);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"incrementQuestionCountForUnattempted",this.onIncrementSuccess),true);
      }
      
      public function getQuesQueueNum() : String
      {
         var count:int = this.getFeatureOptionsKey(FV_FARMRUN2018_QUESTION_START) as int;
         return count.toString();
      }
      
      public function getNPCText() : String
      {
         var que:int = this.getFeatureOptionsKey(FV_FARMRUN2018_QUESTION_START) as int;
         var text:String = (que + 2).toString();
         return "Here is Question " + text + ".";
      }
      
      public function incrementQuesQueueNumAndState(key:String) : void
      {
         var count:int = this.getFeatureOptionsKey(FV_FARMRUN2018_QUESTION_START) as int;
         var currState:int = this.getFeatureOptionsKey(FV_FARMRUN2018_CURRENT_STATE) as int;
         this.saveFeatureOptionsKey(FV_FARMRUN2018_QUESTION_START,count + 1);
         currState = currState + 1 == 4 ? KEY_ORDERBOARD_STATE : int(currState + 1);
         if(currState == KEY_ORDERBOARD_STATE)
         {
            this.updateCompletedTaskArray();
         }
         this.saveFeatureOptionsKey(FV_FARMRUN2018_CURRENT_STATE,currState);
      }
      
      public function getNumberofQuestionsAskedSoFar() : int
      {
         return this.getFeatureOptionsKey(FV_FARMRUN2018_QUESTION_START) as int;
      }
      
      public function getCurrentScore(key:String) : int
      {
         return this.getFeatureOptionsKey(FV_FARMRUN2018_SCORE) as int;
      }
      
      public function getCurrentState() : int
      {
         return this.getFeatureOptionsKey(FV_FARMRUN2018_CURRENT_STATE) as int;
      }
      
      public function setStateAsOrderBoard() : void
      {
         this.saveFeatureOptionsKey(FV_FARMRUN2018_CURRENT_STATE,KEY_ORDERBOARD_STATE);
      }
      
      public function initfeatureData() : void
      {
         this.saveFeatureOptionsKey(FV_FARMRUN2018_QUESTION_START,0);
         this.saveFeatureOptionsKey(FV_FARMRUN2018_SCORE,0);
         this.saveFeatureOptionsKey(FV_FARMRUN2018_QUESTION,0);
         this.saveFeatureOptionsKey(FV_FARMRUN2018_CURRENT_STATE,1);
         this.saveFeatureOptionsKey(FV_FARMRUN2018_QUESTION1,0);
         this.saveFeatureOptionsKey(FV_FARMRUN2018_QUESTION2,0);
         this.saveFeatureOptionsKey(FV_FARMRUN2018_QUESTION3,0);
      }
      
      public function resetfeatureData() : void
      {
         this.saveFeatureOptionsKey(FV_FARMRUN2018_QUESTION_START,0);
         this.saveFeatureOptionsKey(FV_FARMRUN2018_SCORE,0);
         this.saveFeatureOptionsKey(FV_FARMRUN2018_QUESTION1,0);
         this.saveFeatureOptionsKey(FV_FARMRUN2018_QUESTION2,0);
         this.saveFeatureOptionsKey(FV_FARMRUN2018_QUESTION3,0);
      }
      
      public function onIncrementSuccess() : void
      {
      }
      
      public function getFeatureData() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME);
      }
      
      public function getFeatureOptionsKey(optionName:String) : Object
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
         var world:String = this.getFarmrunWorldFromPoints();
         if(Boolean(savedTaskInfo) && Boolean(savedTaskInfo.length) && Boolean(world))
         {
            if(this.m_tasksById == null)
            {
               this.parseTaskObjectsFromConfig(m_featureName);
            }
            for each(task in savedTaskInfo)
            {
               taskXML = this.m_tasksById[world][task[this.KEY_ID]];
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
         var featureData:Object = this.getFeatureOption();
         return taskList;
      }
      
      public function getCompletedTaskSlots() : Array
      {
         return this.getFeatureOptionsKey(KEY_COMPLETED) as Array;
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
      
      public function incrementOverallScore() : void
      {
         var callback:Function = null;
         var scoreFromQuestionarre:int = this.getFeatureOptionsKey(FV_FARMRUN2018_SCORE) as int;
         this.saveFeatureOptionsKey(this.KEY_SCORE,this.getNPCProgress() + scoreFromQuestionarre);
         this.saveFeatureOptionsKey(FV_FARMRUN2018_CURRENT_STATE,KEY_ORDERBOARD_STATE);
         StatsManager.count(FEATURE_TRACKING,"Question"," ",scoreFromQuestionarre.toString(),this.getNPCProgress().toString());
         this.m_window.refreshWindow();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"incrementScoreOnTimerExpire",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(FEATURE_OPTIONS_KEY)),true);
      }
      
      public function incrementScore(points:int) : void
      {
         var currScore:int = this.getFeatureOptionsKey(FV_FARMRUN2018_SCORE) as int;
         var updatedScore:int = currScore + points;
         this.saveFeatureOptionsKey(FV_FARMRUN2018_SCORE,updatedScore);
      }
      
      public function markAnsweredCorrectly() : void
      {
         var currQuestion:int = this.getFeatureOptionsKey(FV_FARMRUN2018_QUESTION_START) as int;
         var keyQuestion:String = this.getKeyForQuestion(currQuestion) as String;
         this.saveFeatureOptionsKey(keyQuestion,1);
      }
      
      public function markAnsweredWrong() : void
      {
         var currQuestion:int = this.getFeatureOptionsKey(FV_FARMRUN2018_QUESTION_START) as int;
         var keyQuestion:String = this.getKeyForQuestion(currQuestion) as String;
         this.saveFeatureOptionsKey(keyQuestion,-1);
      }
      
      public function getKeyForQuestion(count:int) : String
      {
         var key:String = "";
         if(count == 0)
         {
            key = FV_FARMRUN2018_QUESTION1;
         }
         if(count == 1)
         {
            key = FV_FARMRUN2018_QUESTION2;
         }
         if(count == 2)
         {
            key = FV_FARMRUN2018_QUESTION3;
         }
         return key;
      }
      
      public function wasAnsweredCorrectly(key:String) : Boolean
      {
         var check:Boolean = false;
         var value:int = this.getFeatureOptionsKey(key) as int;
         if(value == 1)
         {
            check = true;
         }
         return check;
      }
      
      public function wasNotAttempted(key:String) : Boolean
      {
         var check:Boolean = false;
         var value:int = this.getFeatureOptionsKey(key) as int;
         if(value == 0)
         {
            check = true;
         }
         return check;
      }
      
      public function questionsNotAttemted() : int
      {
         var count:int = 0;
         for(var i:int = 0; i < 3; i++)
         {
            if(this.getFeatureOptionsKey(this.getKeyForQuestion(i)) == 0)
            {
               count++;
            }
         }
         return count;
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
      
      private function onInitQuestComplete(callback:Function, result:Object, openOrderBoard:Boolean = false) : void
      {
         var rewardItem:FarmItem = null;
         var worldname:String = null;
         var milestoneCount:int = 0;
         var milestoneKey:String = null;
         var worldrewardkey:String = null;
         this.m_resultObject = result;
         var bonusItem:FarmItem = null;
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
            if(result.hasOwnProperty(KEY_COMPLETED_TASKS))
            {
               this.saveFeatureOptionsKey(KEY_COMPLETED,result[KEY_COMPLETED_TASKS]);
            }
            if(Boolean(callback))
            {
               callback.call();
            }
         }
         if(Boolean(result) && result.hasOwnProperty("MileStoneReward"))
         {
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(result["MileStoneReward"]);
            if(rewardItem)
            {
               this.resetfeatureData();
            }
         }
         if(Boolean(result) && result.hasOwnProperty("FinalBonusReward"))
         {
            if(this.getNPCProgress() >= VAL_FINAL_MILESTONE)
            {
               bonusItem = Global.farmGameSettingsManager.getFarmItemByName(result["FinalBonusReward"]);
               if(bonusItem)
               {
                  this.grantFinalReward();
               }
            }
         }
         if(openOrderBoard)
         {
            if(this.m_scoreboardWindow)
            {
               this.m_scoreboardWindow.close();
            }
         }
         if(openOrderBoard && this.getNPCProgress() < VAL_FINAL_MILESTONE)
         {
            if(this.getFarmrunWorldFromPoints() == Global.worldManager.currentWorldType)
            {
               this.openOrderBoardWindow();
            }
            else if(this.m_window)
            {
               this.m_window.untintWindow();
               this.m_window.enableInput = true;
            }
         }
         if(rewardItem)
         {
            Global.player.addGift(rewardItem.name);
            worldname = "";
            worldname = this.getFarmrunWorldFromPoints();
            if(this.WORLD_REWARD_NAMES_ARRAY.indexOf(rewardItem.name) == -1)
            {
               this.m_rewardWindow = new FarmRunV7SingleRewardPopup(this.REWARD_POPUP_WINDOW,FEATURE_NAME,rewardItem,this.grantRewardCallback,this.REWARD_WINDOW_IMAGE);
               milestoneCount = this.MILESTONE_REWARD_NAMES_ARRAY.indexOf(rewardItem.name) + 1;
               if(milestoneCount % 2 == 0)
               {
                  milestoneCount = 2;
               }
               else
               {
                  milestoneCount = 1;
               }
               milestoneKey = worldname + "-" + milestoneCount.toString();
               StatsManager.count(FEATURE_TRACKING,"Milestone",milestoneKey,this.getNPCProgress().toString(),rewardItem.name);
            }
            else
            {
               this.m_rewardWindow = new FarmRunV7SingleRewardPopup(this.REWARD_POPUP_WINDOW,FEATURE_NAME,rewardItem,this.grantRewardCallback,this.REWARD_WINDOW_IMAGE);
               worldrewardkey = worldname + "-3";
               StatsManager.count(FEATURE_TRACKING,"Milestone",worldrewardkey,this.getNPCProgress().toString(),rewardItem.name);
            }
            UI.displayPopup(this.m_rewardWindow,false);
         }
         if(this.m_window)
         {
            this.m_window.refreshWindow();
         }
         var currentWorld:String = Global.worldManager.currentWorldType;
         if(currentWorld != this.getFarmrunWorldFromPoints())
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getUpdatedFeatureData",this.updateJustFeatureData,new Array(FEATURE_OPTIONS_KEY)),true);
         }
      }
      
      private function updateJustFeatureData(result:Object) : void
      {
         this.m_resultObject = result;
         if(Boolean(result) && result.hasOwnProperty("featureData"))
         {
            FeatureOptionsManager.getInstance().setFeature(m_featureName,result["featureData"]);
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
         if(!(savedTaskInfo && savedTaskInfo.length) && !Global.player.getSeenFlag(this.KEY_FTUE))
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startQuest",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName)),true);
            this.saveFeatureOptionsKey(KEY_SAVED_BOARD_COUNT,1);
            Global.player.setSeenFlag(this.KEY_FTUE);
         }
      }
      
      public function redeemRewardPoints(questIndex:int, callback:Function, taskPoints:int = 0) : void
      {
         var tasks:Vector.<FarmTask> = this.getTasks();
         var completedTasks:Array = this.getFeatureOptionsKey(KEY_COMPLETED) as Array;
         completedTasks[questIndex] = 1;
         this.saveFeatureOptionsKey(KEY_COMPLETED,completedTasks);
         this.grantPointsForTask(0);
         this.checkAndUpdateUserState();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"redeemRewardPoints",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,questIndex)),true);
         this.resetActionCountsForTasks(tasks[questIndex]);
      }
      
      public function skipTask(questIndex:int, callback:Function) : void
      {
         var savedTasks:Array = null;
         var completedTasks:Array = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         if(Global.player.canBuyCash(tasks[questIndex].skipCashValue))
         {
            Global.player.cash -= tasks[questIndex].skipCashValue;
            savedTasks = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
            completedTasks = this.getFeatureOptionsKey(KEY_COMPLETED) as Array;
            completedTasks[questIndex] = 1;
            savedTasks[questIndex][this.KEY_PROGRESS] = tasks[questIndex].total;
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,savedTasks);
            this.saveFeatureOptionsKey(KEY_COMPLETED,completedTasks);
            this.grantPointsForTask(0);
            this.checkAndUpdateUserState();
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,questIndex)),true);
            this.resetActionCountsForTasks(tasks[questIndex]);
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
         var completedTasks:Array = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         if(Global.player.canBuy(tasks[questIndex].total))
         {
            Global.player.gold -= tasks[questIndex].total;
            savedTasks = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
            savedTasks[questIndex][this.KEY_PROGRESS] = tasks[questIndex].total;
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,savedTasks);
            completedTasks = this.getFeatureOptionsKey(KEY_COMPLETED) as Array;
            completedTasks[questIndex] = 1;
            this.saveFeatureOptionsKey(KEY_COMPLETED,completedTasks);
            this.grantPointsForTask(tasks[questIndex].questPoints);
            this.checkAndUpdateUserState();
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkGold",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,questIndex)),true);
            StatsManager.count(m_featureName,"Coin Sink","",tasks[questIndex].total.toString(),this.getOrderboardProgress().toString());
         }
         else
         {
            callback.call();
         }
      }
      
      public function sinkWorldCurrency(questIndex:int, callback:Function) : void
      {
         var currCount:Number = NaN;
         var savedTasks:Array = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         var currency:String = tasks[questIndex].type;
         if(Global.player.canBuyWithCurrency(currency,tasks[questIndex].total))
         {
            currCount = Global.player.getWorldCurrencyTotal(currency);
            Global.player.deductWorldCurrencyCount(currency,tasks[questIndex].total);
            savedTasks = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
            savedTasks[questIndex][this.KEY_PROGRESS] = tasks[questIndex].total;
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,savedTasks);
            this.grantPointsForTask(tasks[questIndex].questPoints);
            this.checkAndUpdateUserState();
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkWorldCurrency",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),new Array(m_featureName,questIndex)),true);
            StatsManager.count(m_featureName,"Coconuts Sink","",tasks[questIndex].total.toString(),this.getOrderboardProgress().toString());
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
         var completedTasks:Array = this.getFeatureOptionsKey(KEY_COMPLETED) as Array;
         completedTasks[questIndex] = 1;
         this.saveFeatureOptionsKey(KEY_COMPLETED,completedTasks);
         this.grantPointsForTask(0);
         this.checkAndUpdateUserState();
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
      
      public function grantRewardCallback(event:Event) : void
      {
         if(this.m_rewardWindow)
         {
            this.m_rewardWindow.close();
         }
      }
      
      public function grantFinalrewardCallback(event:Event) : void
      {
         this.grantFinalReward();
      }
      
      public function grantFinalReward() : void
      {
         var position:int = 0;
         var finalMileStoneReward:String = null;
         var rewardItem:FarmItem = null;
         var featureKey:String = m_featureName + "_lastmilestone_";
         var finalRewardTaken:int = this.getFeatureOptionsKey(KEY_SAVED_FINAL_REWARD_RECEIVED) as int;
         var iconUrl:String = "assets/dialogs/newfrontier/innovation/xnf_pack4_200.png";
         if(this.getNPCProgress() >= VAL_FINAL_MILESTONE && !Global.player.getSeenFlag("farmrunv7_bonuspopup_seenflag"))
         {
            finalMileStoneReward = this.m_lastMilestoneRewards[0];
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(finalMileStoneReward);
            Global.player.addGift(finalMileStoneReward);
            Global.player.setSeenFlag("farmrunv7_bonuspopup_seenflag");
            this.m_finalRewardWindow = new FarmRunV7SingleRewardPopup(this.REWARD_POPUP_WINDOW,FEATURE_NAME + "_lastmilestone_",rewardItem,this.postMilestoneBragFeed,this.REWARD_WINDOW_IMAGE);
            UI.displayPopup(this.m_finalRewardWindow,false);
            FarmStatsManager.count(FEATURE_TRACKING,"grantBonus",finalMileStoneReward);
            this.saveFeatureOptionsKey(KEY_SAVED_FINAL_REWARD_RECEIVED,1);
         }
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
               this.m_rewardWindow = new FarmRunV7SingleRewardPopup(this.REWARD_SHARE_WINDOW,featureKey,item,this.postMilestoneBragFeed,this.REWARD_WINDOW_IMAGE);
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
      
      public function getNPCProgress() : int
      {
         var progress:* = this.getFeatureOptionsKey(this.KEY_SCORE);
         return int(progress);
      }
      
      public function getOrderboardProgress() : Number
      {
         var progress:* = this.getFeatureOptionsKey(this.KEY_SCORE);
         return int(progress);
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
         var isOrderBoardCompleted:Boolean = true;
         var completedTasks:Array = this.getCompletedTaskSlots();
         for(var i:int = 0; i < completedTasks.length; i++)
         {
            if(completedTasks[i] == 0)
            {
               isOrderBoardCompleted = false;
            }
         }
         var currentWorld:String = Global.worldManager.currentWorldType;
         var currentState:int = this.getCurrentState();
         var scoreToAdd:int = this.getFeatureOptionsKey(FV_FARMRUN2018_SCORE) as int;
         if(currentState == KEY_ORDERBOARD_STATE)
         {
            if(isOrderBoardCompleted && currentWorld == this.getFarmrunWorldFromPoints())
            {
               this.saveFeatureOptionsKey(this.KEY_SCORE,this.getNPCProgress() + 25);
               FarmStatsManager.count(FEATURE_TRACKING,"orderboardtask","complete","25",this.getNPCProgress().toString(),this.getFarmrunWorldFromPoints());
               if(this.m_orderBoardWindow)
               {
                  this.m_orderBoardWindow.updateNPCTextAfterQuiz();
               }
               if(this.m_window)
               {
                  this.m_window.refreshWindow();
               }
            }
         }
         if(currentWorld != this.getFarmrunWorldFromPoints())
         {
            if(this.m_window)
            {
               this.m_window.refreshWindow();
            }
         }
      }
      
      public function getFarmrunWorldFromPoints() : String
      {
         var playerPoints:int = this.getOrderboardProgress();
         var world:String = "";
         if(playerPoints < VAL_FIRST_MILESTONE)
         {
            world = this.m_worlds[0];
         }
         else if(playerPoints < VAL_SECOND_MILESTONE)
         {
            world = this.m_worlds[1];
         }
         else if(playerPoints < VAL_THIRD_MILESTONE)
         {
            world = this.m_worlds[2];
         }
         else if(playerPoints <= VAL_FINAL_MILESTONE)
         {
            world = this.m_worlds[3];
         }
         return world;
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
      
      public function onTravelButtonClick(slotNo:int = 0) : Function
      {
         return function(evt:MouseEvent):void
         {
            var worldType:* = undefined;
            var hasUnlockedWorld:* = undefined;
            var currentFarmrunWorld:* = getFarmrunWorldFromPoints();
            var currentState:* = getCurrentState();
            if(Global.worldManager.currentWorldType == currentFarmrunWorld)
            {
               showMainUI(false);
               m_window.updateWorldProgressBarUtil();
            }
            else if(Boolean(currentFarmrunWorld) && m_worlds[slotNo] == currentFarmrunWorld)
            {
               worldType = currentFarmrunWorld;
               if(Boolean(worldType) && worldType.length > 0)
               {
                  hasUnlockedWorld = Global.worldManager.hasUnlockedWorld(worldType);
                  if(hasUnlockedWorld)
                  {
                     saveFeatureOptionsKey(FV_FARMRUN2018_CURRENT_STATE,KEY_ORDERBOARD_STATE);
                     Global.worldManager.swapFarm(worldType,false);
                     Global.worldManager.addEventListener(FarmGameWorldEvent.WORLD_LOADED,onWorldLoaded);
                  }
               }
            }
         };
      }
      
      private function onWorldLoaded(event:FarmGameWorldEvent) : void
      {
         Global.worldManager.removeEventListener(FarmGameWorldEvent.WORLD_LOADED,this.onWorldLoaded);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getUpdatedFeatureData",this.updateFeatureData,new Array(FEATURE_OPTIONS_KEY)),true);
      }
      
      public function fetchFeatureData() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getUpdatedFeatureData",this.updateOrderboard,new Array(FEATURE_OPTIONS_KEY)),true);
      }
      
      private function updateFeatureData(result:Object) : void
      {
         this.onInitQuestComplete(null,result);
         this.showMainUI(false);
      }
      
      private function updateOrderboard(result:Object) : void
      {
         this.onInitQuestComplete(null,result,true);
      }
      
      public function isWorldEnabled(slotIndex:int) : Boolean
      {
         return this.getFarmrunWorldFromPoints() == this.m_worlds[slotIndex];
      }
      
      public function isWorldCompleted(index:int) : Boolean
      {
         var currentFarmRunWorld:String = this.getFarmrunWorldFromPoints();
         var isTrue:Boolean = false;
         for(var i:int = 0; i < this.m_worlds.length; i++)
         {
            if(this.m_worlds[i] == currentFarmRunWorld)
            {
               break;
            }
         }
         isTrue = i > index;
         if(this.getNPCProgress() >= 1000)
         {
            isTrue = true;
         }
         return isTrue;
      }
      
      private function checkMilestoneRewardWorldIndex(worldIndex:int) : Boolean
      {
         var world:String = this.m_worlds[worldIndex];
         return world == Global.worldManager.currentWorldType;
      }
      
      private function checkAndUpdateUserState() : void
      {
         var completedTask:Array = this.getCompletedTaskSlots();
         var toSwitch:Boolean = true;
         var i:int = 0;
         for(i = 0; i < completedTask.length; i++)
         {
            if(completedTask[i] == 0)
            {
               toSwitch = false;
               break;
            }
         }
         if(toSwitch)
         {
            this.saveFeatureOptionsKey(FV_FARMRUN2018_CURRENT_STATE,KEY_QUESTIONAIRE_STATE);
            this.updateCompletedTaskArray();
            if(Global.worldManager.currentWorldType == this.getFarmrunWorldFromPoints())
            {
               if(this.m_orderBoardWindow)
               {
                  this.m_orderBoardWindow.updateOntaskComplete(true);
               }
            }
            else
            {
               if(this.m_window)
               {
                  this.m_window.refreshWindow();
               }
               if(this.m_orderBoardWindow)
               {
                  this.m_orderBoardWindow.updateOntaskComplete(false);
               }
            }
         }
      }
      
      private function updateCompletedTaskArray() : void
      {
         var completedTask:Array = this.getCompletedTaskSlots();
         for(var i:int = 0; i < completedTask.length; i++)
         {
            completedTask[i] = 0;
         }
         this.saveFeatureOptionsKey(KEY_COMPLETED,completedTask);
      }
      
      public function validatedAnswer(selectedAnswer:String) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"validateAnswer",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[null]),new Array(FEATURE_OPTIONS_KEY,selectedAnswer)),true);
      }
   }
}

