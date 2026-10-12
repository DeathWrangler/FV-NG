package Managers.OrderBoard
{
   import Cache.Classes.ZCacheUtil;
   import Classes.BuildingPart;
   import Classes.Constants.ArrowType;
   import Classes.Constants.QuestConstants;
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureBuilding;
   import Classes.FeedData;
   import Classes.MapResource;
   import Classes.MapTrigger;
   import Classes.MultiRewardTreasureConstructionBuilding;
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.SimpleHarvestableResource;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.HUD.HUDWidgets.HudBottomBrazilInnovationButton;
   import Display.HUD.HUDWidgets.HudBottomCasablancaInnovationButton;
   import Display.QueuedIcons.QueuedIconWithArrow;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Helpers.Vector3;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.TileUnlockEvent;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.FeatureOptionsManager;
   import Managers.ItemFinderManager;
   import Managers.MapTriggerManager;
   import Managers.WorldSeasonsManager;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.BrazilInnovationBoostWindow;
   import Widgets.Windows.CarribeanTileUnlockWindow;
   import Widgets.Windows.CasablancaGenericSingleRewardPopup;
   import Widgets.Windows.CasablancaInnovationAchievementRewardPopup;
   import Widgets.Windows.CasablancaInnovationAchievementWindow;
   import Widgets.Windows.CasablancaInnovationBuildingUpgradeWindow;
   import Widgets.Windows.CasablancaInnovationFranchiseWindow;
   import Widgets.Windows.CasablancaInnovationWindow;
   import Widgets.Windows.CongratsForNewBrazilInovationWindow;
   import Widgets.Windows.CongratsForNewCaribbeanInovationWindow;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.GenericSingleRewardPopup;
   import Widgets.Windows.NPCRewardGrantWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   
   public class CasablancaInnovationManager extends SpecialQuestManager
   {
      
      private static const SERVICE_NAME:String = "CasablancaInnovationService";
      
      private static const HUD_ASSET:String = "assets/dialogs/brazil/innovation/FV_xbr_hud_Innovation.swf";
      
      private static const KEY_SAVED_ACTIVE_TASKS:String = "1";
      
      private static const KEY_TILE_UNLOCK_COUNT:String = "tile_unlock_count";
      
      public static const BRAZIL_TILE_LIST:Array = new Array("xca_rubbletreasure1","xca_rubbletreasure2","xca_rubbletreasure3","xca_rubbletreasure4","xca_rubbletreasure5","xca_rubbletreasure6","xca_rubbletreasure7","xca_rubbletreasure8","xca_rubbletreasure9","xca_rubbletreasure_payer1","xca_rubbletreasure_payer2","xca_rubbletreasure_payer3","xca_rubbletreasure_payer4","xca_rubbletreasure_payer5","xca_rubbletreasure_payer6","xca_rubbletreasure_payer7","xca_rubbletreasure_payer8","xca_rubbletreasure_payer9","xca_rubbletreasure_payer10","xca_rubbletreasure_payer11","xca_rubbletreasure_payer12","xca_rubbletreasure_payer13","xca_rubbletreasure_payer14","xca_rubbletreasure_payer15","xca_rubbletreasure_payer16","xca_rubbletreasure_payer17","xca_rubbletreasure_payer18","xca_rubbletreasure_payer19","xca_rubbletreasure_payer20","xca_rubbletreasure_payer21","xca_rubbletreasure_payer22","xca_rubbletreasure_payer23");
      
      public static const ACHIEVEMENT_EXPIRY_DATES:Array = new Array("1/28/2019","2/4/2019","2/11/2019","2/18/2019");
      
      public static const ACHIEVEMENT_UNLOCK_DATES:Array = new Array("1/21/2019","1/28/2019","2/4/2019","2/11/2019");
      
      public static const ACHIEVEMENT_POINTS_ARRAY:Array = new Array(250,500,750,950);
      
      public static const DAILY_REWARDS:Array = new Array("bigcat_xca_desertmosaicpanther","horse_xca_moroccoheart","magicdeer_xca_adobeflowerdeer","unicorn_xca_morrocanmaiden","horse_xca_moroccannight","pegasus_xca_purpleblaze","pegasus_xca_morrocanrazzle");
      
      public static const LAND_BUNDLE_TILES_ARRAY:Array = new Array("xca_rubbletreasure_payer20","xca_rubbletreasure_payer21","xca_rubbletreasure_payer22","xca_rubbletreasure_payer23");
      
      private static const FEATURE_SET_FINAL_REWARD:* = "final_reward_grant_flag";
      
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
      
      public static const EVENT_CASABLANCA_INNOVATION_TILE_UNLOCK:String = "CasablancaInnovationTileUnlock";
      
      public static const FEATURE_TRACKING:String = "CasablancaInnovation";
      
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
      
      private static const VAL_FIRST_MILESTONE:int = 100;
      
      private static const VAL_SECOND_MILESTONE:int = 300;
      
      private static const VAL_THIRD_MILESTONE:int = 600;
      
      public static const VAL_FINAL_MILESTONE:int = 1000;
      
      private static const SKIP_COST:int = 1;
      
      private static const WINDOW_MAIN:String = "main";
      
      private static const WINDOW_FRANCHISE:String = "franchise";
      
      private static const WINDOW_MILESTONE_REWARD:String = "milestone_reward";
      
      public static const WINDOW_FINAL_REWARD:String = "k11";
      
      private static const WINDOW_NPC_FINAL_REWARD:String = "npc_final_reward";
      
      private static const WINDOW_REWARDS:String = "rewards";
      
      private static const WINDOW_ACHIEVEMENT:String = "achievement";
      
      private static const WINDO_FINAL_REWARDS_SELECTION:String = "final_reward_selection";
      
      private static const WINDOW_BOOST:String = "boost";
      
      public static const CASABLANCA_TASK_POINTS_ITEM_CODE:String = "k9b1";
      
      public static const CASABLANCA_TILE_UNLOCK_COUNT:String = "5egw";
      
      private static const SPECIAL_TILE_NAME:String = "xdw_rubbletreasure_special";
      
      private static const TILE_UNLOCK_COUNT:String = "tuc";
      
      private static const PM_FEATURE_THRESHOLD_COUNT:int = 30;
      
      private static const BUNDLE_ID:String = "CasablancaInnovation_Brag";
      
      private static const COLLECT_CONSUMABLE_COUNT:int = 1;
      
      public static const DEFAULT_COLLECT_THROTTLE_TIME:int = 86400;
      
      public static const DEFAULT_COLLECT_THROTTLE_TIME_MSECS:int = 86400000;
      
      public static const NUM_MSECS_IN_SIX_HRS:uint = 21600000;
      
      public static const DEFAULT_HARVEST_THROTTLE_TIME:int = 86400;
      
      private static const HUD_CASABLANCA_ASSET:String = "assets/dialogs/casablanca/innovation/FV_xca_hud_Innovation.swf";
      
      public static const FTUE_SEEN_FLAG:String = "CasablancaInnovation_Tutorial";
      
      private static const LAST_BONUS_HARVEST_TIME_KEY:String = "Last_bonus_harvest_time";
      
      public static const LAND_BUNDLE_UNLOCKED:String = "Casablanca_LandBundle_unlocked";
      
      public static const LAND_BUNDLE_POPUP:String = "Casablanca_LandBundle_popup";
      
      private static const FIRST_TIME_TILE_UNLOCK:String = "First_time_tile_unlock";
      
      private static const TILE_UNLOCK:String = "Casablanca_Tile_Unlock";
      
      private static const FIRST_TIME_LANDBUNDLE_UNLOCK:String = "First_time_landbundle_unlock";
      
      private static const FIRST_TIME_LANDBUNDLE_ACTIVE:String = "First_time_landbundle_active";
      
      private var m_isEA:Boolean;
      
      private var m_hud:QueuedIconWithArrow;
      
      private var m_newHud:HudBottomBrazilInnovationButton;
      
      private var m_currencyName:String = "task_points";
      
      private var m_endTimeStamp:Number = 0;
      
      private var m_tasksById:Object = null;
      
      private var m_assetPaths:Object = {};
      
      private var m_eaRewards:Array = new Array();
      
      private var m_gaRewards:Array = new Array();
      
      private var m_lastMilestoneRewards:Array = new Array();
      
      private var m_finalRewards:Array = new Array();
      
      private var m_feedConfig:Object = {};
      
      private const BONUS_HARVEST_ARRAY:Array = new Array("consume_organic_fertilizer","consume_turbo_charger","consume_instagrow","fuel1","consume_unwither","vehiclepart","pkg_xca_harvest_treasureparts","consume_arborists","consume_farm_hands","fawn_feed");
      
      private const BONUS_HARVEST_COUNT:String = "hc";
      
      private const SERVICE_FUNC_SET_FINAL_REWARD_GRANT:String = "setFinalRewardGrantFlag";
      
      public const KEY_FEATURE_FINISHED_TIME:String = "31";
      
      public const KEY_FEATURE_FIRST_DAY_CORNER_CASE:String = "firstday";
      
      public const KEY_FEATURE_FINISHED_DAILY_TIME:String = "36";
      
      public const KEY_ACTIVE_DAY_TIMESTAMP:String = "32";
      
      public const KEY_DAY_POINTS:String = "33";
      
      public const KEY_DAY_REWARD_GRANT_STATUS:String = "34";
      
      public const KEY_FEATURE_FINISHED_EXACT_TIMESTAMP:* = "40";
      
      public const DAY_REWARD_MILESTONE_POINTS:int = 50;
      
      private const SERVICE_FUNC_HARVEST_BONUS:String = "harvestCasablancaBuilding";
      
      private const BUILDING_ASSET0:String = "assets/buildings/carnivalfloat0_icon_200.png";
      
      private const BUILDING_ASSET1:String = "assets/buildings/carnivalfloat1_icon_200.png";
      
      private const BUILDING_ASSET2:String = "assets/buildings/carnivalfloat2_icon_200.png";
      
      private const BUILDING_ASSET3:String = "assets/buildings/carnivalfloat3_icon_200.png";
      
      private const TILE_UNLOCK_ASSET:String = "assets/dialogs/brazil/innovation/FV_xbr_Innovation_Prize.swf";
      
      private const LAND_BUNDLE_UNLOCK_POPUP:String = "assets/buildings/xca_beachcafe.swf";
      
      private const REWARD_POPUP_WINDOW:String = "assets/dialogs/expansion/FV_RewardDialog.swf";
      
      private const REWARD_SHARE_WINDOW:String = "assets/dialogs/expansion/FV_RewardDialog_Share.swf";
      
      private const REWARD_WINDOW_IMAGE:String = "assets/dialogs/casablanca/RewardDialog.png";
      
      protected const KEY_ID:String = "id";
      
      protected const KEY_PROGRESS:String = "progress";
      
      protected const KEY_TOTAL:String = "total";
      
      public const TILE_UNLOCK_POINTS:Number = 30;
      
      private var m_window:CasablancaInnovationWindow;
      
      private var m_rewardWindow:GenericSingleRewardPopup;
      
      private var m_buildingUpgradeRewardWindow:CasablancaGenericSingleRewardPopup;
      
      private var m_rewardName:String;
      
      private var m_resultObject:Object;
      
      private var m_redeemResultObject:Object;
      
      private var m_isActive:Boolean = false;
      
      protected var m_owner:FeatureBuilding;
      
      private var m_CasablancaInnovationHud:HudBottomCasablancaInnovationButton;
      
      private const TILE_UNLOCK_LIMIT_FOR_POINTS:int = 8;
      
      private var m_achievementWindow:CasablancaInnovationAchievementWindow;
      
      private var m_achievementRewardWindow:CasablancaInnovationAchievementRewardPopup;
      
      private var m_buildingUpgradeWindow:CasablancaInnovationBuildingUpgradeWindow;
      
      private var m_rewardDailyWindow:GenericSingleRewardPopup;
      
      private var m_showRedeemCallout:Boolean = false;
      
      internal var m_redeemAchivement_ItemName:FarmItem;
      
      internal var m_achivement_bonusItemName:String = null;
      
      public function CasablancaInnovationManager(featureName:String)
      {
         super(featureName);
         if(!this.featureConfig)
         {
            return;
         }
         this.parseFeatureConfig();
         this.parseTaskObjectsFromCOnfig(m_featureName);
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
         this.m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_CASABLANCA);
      }
      
      public static function getInstance(featureName:String) : CasablancaInnovationManager
      {
         var instance:CasablancaInnovationManager = getInstanceOfClass(featureName,CasablancaInnovationManager) as CasablancaInnovationManager;
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
      
      public function setupNewHud() : void
      {
         this.m_newHud = new HudBottomBrazilInnovationButton(HUD_ASSET,m_featureName);
         Global.hud.setBottomHudBrazilInnovationButton(this.m_newHud as HudBottomBrazilInnovationButton);
      }
      
      public function get isFeatureActive() : Boolean
      {
         return this.m_isActive;
      }
      
      public function getDialogUrl() : String
      {
         return this.m_assetPaths[WINDOW_MAIN];
      }
      
      public function getFranchiseDialogUrl() : String
      {
         return this.m_assetPaths[WINDOW_FRANCHISE];
      }
      
      public function showMainUI() : void
      {
         if(!this.hasExpiryDatePassedForFeature())
         {
            this.m_window = new CasablancaInnovationWindow();
            if(this.hasActiveDayExpired())
            {
               this.saveFeatureOptionsKey(this.KEY_ACTIVE_DAY_TIMESTAMP,FarmGameUtil.getMidnightTimestamp() / 1000);
               this.saveFeatureOptionsKey(this.KEY_DAY_REWARD_GRANT_STATUS,0);
               this.saveFeatureOptionsKey(this.KEY_DAY_POINTS,0);
            }
            this.startQuest(this.m_window.refreshTaskFrame);
            UI.displayPopup(this.m_window);
         }
      }
      
      public function setupCasablancaHud() : void
      {
         if(!this.hasExpiryDatePassedForFeature())
         {
            this.m_CasablancaInnovationHud = new HudBottomCasablancaInnovationButton(HUD_CASABLANCA_ASSET,m_featureName);
            Global.hud.setBottomCasablancaInnovationButton(this.m_CasablancaInnovationHud as HudBottomCasablancaInnovationButton);
         }
      }
      
      public function updateMapTriggers(ByTileEvent:Boolean = false) : void
      {
         var name:String = null;
         var map:MapTrigger = null;
         var count:Number = this.getTileUnlockCount();
         if(ByTileEvent)
         {
            count++;
         }
         for(var i:int = 1; i <= 8; i++)
         {
            name = "CasablancaInnovationFranchiseMapTrigger" + i.toString();
            map = MapTriggerManager.getInstance().getMapTriggerByName(name);
            if(map)
            {
               map.setVisible(count >= i);
            }
         }
      }
      
      public function showRewardsUI() : void
      {
         var item:String = "xca_thecafe";
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(item);
         var window:FarmWindow = new CongratsForNewCaribbeanInovationWindow(this.m_assetPaths[WINDOW_REWARDS],m_featureName + "lastmilestone",rewardItem,null,null,item);
         UI.displayPopup(window,false);
         this.m_window.close();
      }
      
      public function showAchievementUI() : void
      {
         this.m_achievementWindow = new CasablancaInnovationAchievementWindow(this.m_assetPaths[WINDOW_ACHIEVEMENT],m_featureName,WINDOW_ACHIEVEMENT,this.untintWindow);
         UI.displayPopup(this.m_achievementWindow,false);
      }
      
      public function showBoostUI() : void
      {
         UI.displayPopup(new BrazilInnovationBoostWindow("assets/dialogs/brazil/innovation/FV_xbr_Innovation_Boost.swf",m_featureName,WINDOW_BOOST,this.untintWindow),false);
      }
      
      public function showFranchiseUI() : void
      {
         UI.displayPopup(new CasablancaInnovationFranchiseWindow(m_featureName),false);
      }
      
      private function untintWindow(evt:Event = null) : void
      {
         if(this.m_window)
         {
            this.m_window.untintWindow();
            this.m_window.enableInput = true;
            this.m_window.refreshWindow();
         }
      }
      
      public function closeMainWindow() : void
      {
         if(this.m_window)
         {
            this.m_window.close();
         }
      }
      
      public function isAllTilesUnlocked() : Boolean
      {
         if(Global.world.getObjectsByNames(BRAZIL_TILE_LIST).length)
         {
            return false;
         }
         return true;
      }
      
      public function hasExpiryDatePassedForAchievement(slotIndex:int) : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber(ACHIEVEMENT_EXPIRY_DATES[slotIndex]) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         timeLeft = endTime - now;
         if(timeLeft <= 0)
         {
            result = true;
         }
         return result;
      }
      
      public function hasExpiryDatePassedForFeature() : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("02/25/2019") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         timeLeft = endTime - now;
         if(timeLeft <= 0)
         {
            result = true;
         }
         return result;
      }
      
      public function isAchievementAbouttoExpire(slotIndex:int) : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         var now:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber(ACHIEVEMENT_EXPIRY_DATES[slotIndex]) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         timeLeft = endTime - now;
         if(timeLeft <= 86400 && timeLeft > 0)
         {
            result = true;
         }
         return result;
      }
      
      public function hasUnlockDatePassedForAchievement(slotIndex:int) : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber(ACHIEVEMENT_UNLOCK_DATES[slotIndex]) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         timeLeft = endTime - now;
         if(timeLeft <= 0)
         {
            result = true;
         }
         return result;
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
            if(this.m_CasablancaInnovationHud)
            {
               this.m_CasablancaInnovationHud.refresh(1);
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
      
      public function showTileUnlockCountMc() : Number
      {
         var itemName:String = null;
         var result:int = 0;
         var inventoryTileCount:Number = FeatureOptionsInventoryManager.getInstance().getCount(CASABLANCA_TILE_UNLOCK_COUNT);
         var count:Object = this.getFeatureOptionsKey(KEY_TILE_UNLOCK_COUNT) as Object;
         if(!this.isFinalRewardChosen())
         {
            if(Boolean(inventoryTileCount) && inventoryTileCount > count)
            {
               result = inventoryTileCount - (count as Number);
               itemName = Global.farmGameSettingsManager.getFarmItemNameByCode(CASABLANCA_TASK_POINTS_ITEM_CODE);
            }
         }
         return result;
      }
      
      public function getTileUnlockCount() : Number
      {
         var inventoryTileCount:Number = FeatureOptionsInventoryManager.getInstance().getCount(CASABLANCA_TILE_UNLOCK_COUNT) as Number;
         return inventoryTileCount ? inventoryTileCount : 0;
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
            inventoryTileCount = FeatureOptionsInventoryManager.getInstance().getCount(CASABLANCA_TILE_UNLOCK_COUNT);
            if(inventoryTileCount)
            {
               FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,KEY_TILE_UNLOCK_COUNT,inventoryTileCount);
            }
         }
      }
      
      public function showTileUnlockCallout() : void
      {
         if(Global.player.getSeenFlag(TILE_UNLOCK))
         {
            if(!Global.player.getSeenFlag(FIRST_TIME_TILE_UNLOCK))
            {
               Global.player.setSeenFlag(FIRST_TIME_TILE_UNLOCK);
               this.forcedNPCCallouts("Collect Acclaim","Your franchises will generate Acclaim every 12 hours. Make sure you collect it to add to your score");
            }
            else if(this.getTileUnlockCount() <= 8)
            {
               this.showNPCCallouts("Get your Acclaim","Your franchises have added to your Acclaim. Collect it now!");
            }
         }
         Global.player.resetSeenFlag(TILE_UNLOCK);
         if(!this.isLandBundleUnlocked() && this.isLandbundleActive() && !Global.player.getSeenFlag(FIRST_TIME_LANDBUNDLE_ACTIVE))
         {
            Global.player.setSeenFlag(FIRST_TIME_LANDBUNDLE_ACTIVE);
            this.forcedNPCCallouts("Starfish Island","If you purchase the Starfish Island land bundle, you will get a beach cafe which gives you double the Acclaim of a single franchise!",true);
         }
      }
      
      public function initEventListener() : void
      {
         GlobalEventManager.getInstance().addEventListener(EVENT_CASABLANCA_INNOVATION_TILE_UNLOCK,this.showGrantPopup);
      }
      
      public function deleteEventListener() : void
      {
         GlobalEventManager.getInstance().removeEventListener(EVENT_CASABLANCA_INNOVATION_TILE_UNLOCK,this.showGrantPopup);
      }
      
      public function showGrantPopup(e:TileUnlockEvent = null) : void
      {
         if(this.getTileUnlockCount() + 1 <= this.TILE_UNLOCK_LIMIT_FOR_POINTS && !this.hasExpiryDatePassedForFeature())
         {
            UI.displayPopup(new CarribeanTileUnlockWindow(this.TILE_UNLOCK_ASSET,m_featureName,e.tileData.getItemName()));
         }
         if(this.getTileUnlockCount() + 1 <= this.TILE_UNLOCK_LIMIT_FOR_POINTS)
         {
            this.resetCollectConsumableTimer(e.tileData.getItemName());
         }
         Global.player.setSeenFlag(TILE_UNLOCK);
         this.updateMapTriggers(true);
      }
      
      public function forcedNPCCallouts(calloutTitle:String = null, calloutText:String = null, landBundleCallout:Boolean = false) : void
      {
         this.m_window.forcedNPCCallouts(calloutTitle,calloutText,landBundleCallout);
      }
      
      public function showNPCCallouts(calloutTitle:String = null, calloutText:String = null) : void
      {
         if(this.m_window)
         {
            this.m_window.showNPCCallouts(calloutTitle,calloutText);
         }
      }
      
      public function showAutoHideNPCCallouts(title:String, text:String) : void
      {
         this.m_window.showAutoHideNPCCallouts(title,text);
      }
      
      public function hideNPCCallout() : void
      {
         this.m_window.hideNPCCallout();
      }
      
      protected function getFeatureOptionsKey(optionName:String) : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,optionName);
      }
      
      public function isFirstDayCornerCase() : Boolean
      {
         var result:Boolean = false;
         var key:int = this.getFeatureOptionsKey(this.KEY_FEATURE_FIRST_DAY_CORNER_CASE) as int;
         if(key == 1)
         {
            result = true;
         }
         return result;
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
                  taskObj.type = "k9b1";
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
      
      private function onInitQuestComplete(callback:Function, result:Object) : void
      {
         this.m_resultObject = result;
         if(Boolean(result) && result.hasOwnProperty("activeTasks"))
         {
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,result["activeTasks"]);
            callback.call();
         }
         if(this.m_window)
         {
            this.m_window.NPCMovement();
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
      
      public function startQuest(callback:Function) : void
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
            StatsManager.count(m_featureName,"Coin Sink","",tasks[questIndex].total.toString(),this.getNPCProgress().toString());
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
         StatsManager.count(m_featureName,"Sink Bushel","",tasks[questIndex].total.toString(),this.getNPCProgress().toString());
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
         var currentTime:int = 0;
         var result:Boolean = false;
         var featureKey:String = m_featureName + "_lastmilestone_";
         var finalRewardTaken:int = this.getFeatureOptionsKey(KEY_SAVED_FINAL_REWARD_RECEIVED) as int;
         this.m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_CASABLANCA);
         var iconUrl:String = "assets/dialogs/casablanca/innovation/xca_pack4_200.png";
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
               iconUrl = "assets/dialogs/casablanca/innovation/xca_pack4_EA_200.png";
            }
            this.m_buildingUpgradeWindow = new CasablancaInnovationBuildingUpgradeWindow(this.REWARD_POPUP_WINDOW,m_featureName + "_lastmilestone_",rewardItem,this.onClickOkButton,this.REWARD_WINDOW_IMAGE,iconUrl,"finalReward",true);
            UI.displayPopup(this.m_buildingUpgradeWindow,false);
            this.saveFeatureOptionsKey(KEY_SAVED_FINAL_REWARD_RECEIVED,1);
            FarmStatsManager.count(FEATURE_TRACKING,"featurecomplete","","","",this.getNPCProgress().toString());
            FarmStatsManager.count(FEATURE_TRACKING,"grantBonus",rewardItem.friendlyTitle,"","",this.getNPCProgress().toString());
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            this.saveFeatureOptionsKey(this.KEY_FEATURE_FINISHED_EXACT_TIMESTAMP,currentTime);
            this.saveFeatureOptionsKey(this.KEY_FEATURE_FINISHED_TIME,FarmGameUtil.getMidnightTimestamp() / 1000);
            this.saveFeatureOptionsKey(this.KEY_FEATURE_FINISHED_DAILY_TIME,(FarmGameUtil.getMidnightTimestamp() + 604800000) / 1000);
            this.saveFeatureOptionsKey(this.KEY_ACTIVE_DAY_TIMESTAMP,FarmGameUtil.getMidnightTimestamp() / 1000);
            this.saveFeatureOptionsKey(this.KEY_DAY_REWARD_GRANT_STATUS,0);
            this.saveFeatureOptionsKey(this.KEY_DAY_POINTS,0);
            if(this.getActiveDayIndex() == 0 && this.isFirstDayCornerCase() == false)
            {
               result = this.hasActiveDayExpired();
            }
         }
      }
      
      public function onClickOkButton(e:MouseEvent) : void
      {
         var item:String = "xca_thecafe";
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(item);
         var iconUrl:String = "assets/buildings/xca_thecafe2_icon_200.png";
         if(this.m_buildingUpgradeWindow)
         {
            this.m_buildingUpgradeWindow = null;
         }
         this.m_buildingUpgradeWindow = new CasablancaInnovationBuildingUpgradeWindow(this.REWARD_SHARE_WINDOW,m_featureName + "_lastmilestone",rewardItem,this.postFinalRewardFeed,this.REWARD_WINDOW_IMAGE,iconUrl,"cafe",false);
         UI.displayPopup(this.m_buildingUpgradeWindow,false);
         if(this.m_rewardWindow)
         {
            this.m_rewardWindow.close();
         }
         this.m_window.refreshWindow();
      }
      
      public function showOtherNPCFinalRewardTaken() : void
      {
         var featureKey:String = null;
         var opponentName:String = null;
         var opponentPosition:String = null;
         var showReward:Boolean = false;
         var firstRewardTaken:Boolean = this.getFeatureOptionsKey(KEY_NPC1_FINAL_REWARD_RECEIVED) as Boolean;
         var secondRewardTaken:Boolean = this.getFeatureOptionsKey(KEY_NPC2_FINAL_REWARD_RECEIVED) as Boolean;
         var thirdRewardTaken:Boolean = this.getFeatureOptionsKey(KEY_NPC3_FINAL_REWARD_RECEIVED) as Boolean;
         if(this.getNPC3Progress() >= VAL_FINAL_MILESTONE && !thirdRewardTaken)
         {
            showReward = true;
            featureKey = m_featureName + "_third_reward_taken";
            this.saveFeatureOptionsKey(KEY_NPC3_FINAL_REWARD_RECEIVED,true);
            opponentName = "Santiago";
            opponentPosition = "3";
         }
         else if(this.getNPC2Progress() >= VAL_FINAL_MILESTONE && !secondRewardTaken)
         {
            showReward = true;
            featureKey = m_featureName + "_second_reward_taken";
            this.saveFeatureOptionsKey(KEY_NPC2_FINAL_REWARD_RECEIVED,true);
            opponentName = "Matias";
            opponentPosition = "2";
         }
         else if(this.getNPC1Progress() >= VAL_FINAL_MILESTONE && !firstRewardTaken)
         {
            showReward = true;
            featureKey = m_featureName + "_first_reward_taken";
            this.saveFeatureOptionsKey(KEY_NPC1_FINAL_REWARD_RECEIVED,true);
            opponentName = "Catalina";
            opponentPosition = "1";
         }
         if(showReward)
         {
            StatsManager.count("CasablancaInnovation",opponentName,opponentPosition,this.getNPCProgress().toString());
            UI.displayPopup(new NPCRewardGrantWindow(this.m_assetPaths[WINDOW_NPC_FINAL_REWARD],featureKey),false);
         }
      }
      
      public function grantMilestoneReward() : void
      {
         var featureKey:String = null;
         var item:FarmItem = null;
         var milestonePosition:String = null;
         this.m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_CASABLANCA);
         var showReward:Boolean = false;
         var firstRewardGrant:Boolean = this.getFeatureOptionsKey(KEY_SAVED_FIRST_REWARD_RECEIVED) as Boolean;
         var secondRewardGrant:Boolean = this.getFeatureOptionsKey(KEY_SAVED_SECOND_REWARD_RECEIVED) as Boolean;
         var thirdRewardGrant:Boolean = this.getFeatureOptionsKey(KEY_SAVED_THIRD_REWARD_RECEIVED) as Boolean;
         if(this.getNPCProgress() >= VAL_FIRST_MILESTONE && !firstRewardGrant)
         {
            showReward = true;
            milestonePosition = "first";
            featureKey = m_featureName + "_first_milestone_reward";
            this.saveFeatureOptionsKey(KEY_SAVED_FIRST_REWARD_RECEIVED,true);
            this.m_rewardName = this.getMilestoneRewardItemName(0);
         }
         else if(this.getNPCProgress() >= VAL_SECOND_MILESTONE && !secondRewardGrant)
         {
            showReward = true;
            milestonePosition = "second";
            featureKey = m_featureName + "_second_milestone_reward";
            this.saveFeatureOptionsKey(KEY_SAVED_SECOND_REWARD_RECEIVED,true);
            this.m_rewardName = this.getMilestoneRewardItemName(1);
         }
         else if(this.getNPCProgress() >= VAL_THIRD_MILESTONE && !thirdRewardGrant)
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
               this.m_buildingUpgradeRewardWindow = new CasablancaGenericSingleRewardPopup(this.REWARD_POPUP_WINDOW,featureKey,item,this.showBuildingUpgradePopup,this.REWARD_WINDOW_IMAGE);
               UI.displayPopup(this.m_buildingUpgradeRewardWindow,false);
               FarmStatsManager.count(FEATURE_TRACKING,"Milestone",milestonePosition,item.friendlyTitle,"",this.getNPCProgress().toString());
            }
            else
            {
               this.m_rewardWindow = new GenericSingleRewardPopup(this.REWARD_SHARE_WINDOW,featureKey,item,this.postMilestoneBragFeed,this.REWARD_WINDOW_IMAGE);
               UI.displayPopup(this.m_rewardWindow,false);
               FarmStatsManager.count(FEATURE_TRACKING,"Milestone",milestonePosition,item.friendlyTitle,"",this.getNPCProgress().toString());
            }
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
         var iconUrl:String = "assets/buildings/xca_thecafe1_icon_200.png";
         this.m_buildingUpgradeWindow = new CasablancaInnovationBuildingUpgradeWindow(this.REWARD_SHARE_WINDOW,featureKey,item,this.postBuildingUpgradeBragFeed,this.REWARD_WINDOW_IMAGE,iconUrl,"stall",false);
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
         return FeatureOptionsInventoryManager.getInstance().getCount(CASABLANCA_TASK_POINTS_ITEM_CODE);
      }
      
      public function getDailyNPCProgress() : int
      {
         return this.getFeatureOptionsKey(this.KEY_DAY_POINTS) as int;
      }
      
      public function getPlayerPosition() : int
      {
         return this.getFeatureOptionsKey(KEY_SAVED_FINAL_REWARD_RECEIVED) as int;
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
      
      public function getNPC1Progress() : Number
      {
         var result:Number = 0;
         var npcm:Object = this.getFeatureOptionsKey(KEY_NPC_MOVEMENTS) as Object;
         if(Boolean(npcm) && Boolean(npcm[KEY_NPC1]))
         {
            result = npcm[KEY_NPC1] as Number;
            if(result < 0)
            {
               result = 0;
            }
         }
         return result;
      }
      
      public function getNPC2Progress() : Number
      {
         var result:Number = 0;
         var npcm:Object = this.getFeatureOptionsKey(KEY_NPC_MOVEMENTS) as Object;
         if(Boolean(npcm) && Boolean(npcm[KEY_NPC2]))
         {
            result = npcm[KEY_NPC2] as Number;
            if(result < 0)
            {
               result = 0;
            }
         }
         return result;
      }
      
      public function getNPC3Progress() : Number
      {
         var result:Number = 0;
         var npcm:Object = this.getFeatureOptionsKey(KEY_NPC_MOVEMENTS) as Object;
         if(Boolean(npcm) && Boolean(npcm[KEY_NPC3]))
         {
            result = npcm[KEY_NPC3] as Number;
            if(result < 0)
            {
               result = 0;
            }
         }
         return result;
      }
      
      private function panToSpecialTile(event:Event) : void
      {
         var specialTileObj:MultiRewardTreasureConstructionBuilding = null;
         if(this.m_rewardWindow)
         {
            this.m_rewardWindow.close();
         }
         var specialTile:Array = Global.world.getObjectsByName(SPECIAL_TILE_NAME);
         if(Boolean(specialTile) && specialTile.length > 0)
         {
            ItemFinderManager.getInstance().highlightWorldItems(SPECIAL_TILE_NAME);
            specialTileObj = specialTile[0] as MultiRewardTreasureConstructionBuilding;
            specialTileObj.onClick();
         }
      }
      
      private function postBragFeed(event:Event) : void
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
      
      private function postAchievementRedeemBragFeed(event:Event) : void
      {
         if(Boolean(this.m_redeemResultObject) && Boolean(this.m_redeemResultObject["feedAchievementData"]))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(this.m_redeemResultObject["feedAchievementData"]);
         }
         if(this.m_achievementRewardWindow)
         {
            this.m_achievementRewardWindow.close();
         }
         if(this.m_buildingUpgradeRewardWindow)
         {
            this.m_buildingUpgradeRewardWindow.close();
         }
      }
      
      private function postElderDailyChallenegBragFeed(event:Event) : void
      {
         if(Boolean(this.m_resultObject) && Boolean(this.m_resultObject["feedDailyChallengeData"]))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(this.m_resultObject["feedDailyChallengeData"]);
         }
         if(this.m_rewardWindow)
         {
            this.m_rewardWindow.close();
         }
         if(this.m_buildingUpgradeRewardWindow)
         {
            this.m_buildingUpgradeRewardWindow.close();
         }
         if(this.m_rewardDailyWindow)
         {
            this.m_rewardDailyWindow.close();
         }
      }
      
      private function postFeaturecomplete(event:Event) : void
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
         if(this.m_window)
         {
            this.m_window.refreshWindow();
         }
      }
      
      public function replceIntermediateRewardWithFinalReward(indexChosen:int, position:String) : void
      {
         var finishedItem:FarmItem = null;
         var currentItemName:String = null;
         var currentItem:FarmItem = null;
         var currentPosition:Vector3 = null;
         var id:Number = NaN;
         var tempClass:Class = null;
         var transformedObject:MapResource = null;
         var storageBuilding:StorageBuilding = null;
         var interMediateReward:String = this.getFinalRewardInIntermediateState();
         var finalRewards:Array = this.getFinalReward();
         var finalReward:String = finalRewards[indexChosen];
         StatsManager.count("CasablancaInnovation","FloatChoice",finalReward,position);
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,KEY_SAVED_FINAL_REWARD_BUILDINGNAME,finalReward);
         var m_owner:FeatureBuilding = Global.world.getObjectsByName(interMediateReward)[0];
         var finishedName:String = finalReward;
         if(Boolean(finishedName) && finishedName != "")
         {
            finishedItem = Global.farmGameSettingsManager.getFarmItemByName(finishedName);
            if(finishedItem)
            {
               currentItemName = interMediateReward;
               currentItem = Global.farmGameSettingsManager.getFarmItemByName(currentItemName);
               Global.player.removeLimitedItem(currentItemName);
               currentPosition = m_owner.getPosition();
               id = m_owner.getId();
               m_owner.detach();
               tempClass = getDefinitionByName("Classes." + finishedItem.className) as Class;
               transformedObject = new tempClass(finishedItem.name);
               transformedObject.setMetadata(m_owner.getMetadata());
               transformedObject.attachToPersistentData(m_owner.persistentDataKey);
               transformedObject.setOuter(Global.world);
               transformedObject.setPosition(currentPosition.x,currentPosition.y,currentPosition.z);
               transformedObject.conditionallyReattach();
               transformedObject.setId(id);
               storageBuilding = transformedObject as StorageBuilding;
               if(storageBuilding)
               {
                  if(storageBuilding.shouldCopyPartsWhenReplacing())
                  {
                     storageBuilding.copyParts(m_owner);
                  }
                  if(storageBuilding.shouldCopyStorageWhenReplacing())
                  {
                     storageBuilding.copyStorage(m_owner);
                  }
                  if(storageBuilding.shouldCopyPlantTimeWhenReplacing())
                  {
                     storageBuilding.plantTime = m_owner.plantTime;
                  }
                  if(FarmGameSettingsManager.isInDataSourceExperiment())
                  {
                     if(finishedItem.hasPropertyInDataSource("initialExpansionLevel"))
                     {
                        storageBuilding.storageLevel = finishedItem.getIntFromDataSource("initialExpansionLevel");
                     }
                  }
                  else if(finishedItem.xml.hasOwnProperty("initialExpansionLevel"))
                  {
                     storageBuilding.storageLevel = parseInt(finishedItem.xml.initialExpansionLevel);
                  }
               }
               if(transformedObject is SimpleHarvestableResource)
               {
                  (transformedObject as SimpleHarvestableResource).setState(FeatureBuilding.STATE_RIPE);
               }
            }
         }
      }
      
      public function addBuildingPartForUpgrade(itemName:String = "", count:int = 0) : Boolean
      {
         var buildings:Array = null;
         var featureBuilding:FeatureBuilding = null;
         var giftItem:FarmItem = null;
         var buildingPart:BuildingPart = null;
         if(Boolean(itemName) && count >= 1)
         {
            buildings = Global.world.getObjectsByName("carnivalfloat");
            featureBuilding = buildings[0] as FeatureBuilding;
            giftItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(giftItem != null)
            {
               buildingPart = new BuildingPart(giftItem.name);
               while(count)
               {
                  featureBuilding.addExpansionPart(buildingPart);
                  count--;
               }
               featureBuilding.reloadImage();
               return true;
            }
         }
         return false;
      }
      
      public function panToBuilding(buildingName:String) : void
      {
         if(this.m_rewardWindow)
         {
            this.m_rewardWindow.close();
         }
         if(this.m_window)
         {
            this.m_window.close();
         }
         var brazilInnovationBuildingItem:Array = Global.world.getObjectsByName(buildingName);
         if(Boolean(brazilInnovationBuildingItem) && brazilInnovationBuildingItem.length > 0)
         {
            ItemFinderManager.getInstance().highlightWorldItems(buildingName);
         }
      }
      
      protected function getFeatureOption() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName);
      }
      
      public function getFranchiseUnlockPoints() : int
      {
         var tileUnlockCount:int = this.getTileUnlockCount();
         return int(COLLECT_CONSUMABLE_COUNT * (tileUnlockCount < this.TILE_UNLOCK_LIMIT_FOR_POINTS ? tileUnlockCount : this.TILE_UNLOCK_LIMIT_FOR_POINTS));
      }
      
      public function collectConsumables() : int
      {
         var consumableCount:int = this.getFranchiseUnlockPoints();
         var tileUnlockCount:int = this.getTileUnlockCount();
         this.m_window.disableCollectOverlay();
         this.grantPointsForTask(consumableCount);
         Global.player.setFeatureLastShown(CASABLANCA_TASK_POINTS_ITEM_CODE,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"collectConsumables",null,[m_featureName]));
         FarmStatsManager.count(FEATURE_TRACKING,"Franchise",tileUnlockCount.toString(),"",consumableCount.toString(),this.getNPCProgress().toString());
         return consumableCount;
      }
      
      public function canCollectConsumables() : Boolean
      {
         var canCollect:Boolean = true;
         var key:String = CASABLANCA_TASK_POINTS_ITEM_CODE;
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
      
      public function resetCollectConsumableTimer(tileName:String = null) : void
      {
         var featureData:Object = this.getFeatureOption();
         var key:String = CASABLANCA_TASK_POINTS_ITEM_CODE;
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,m_featureName,featureData);
         Global.player.setFeatureLastShown(key,(GlobalEngine.serverTime - DEFAULT_COLLECT_THROTTLE_TIME_MSECS / 2) / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"resetCollectConsumablesTimer",null,[m_featureName,tileName]));
      }
      
      public function checkandUpdateAchievementCompletedState() : void
      {
         var score:Number = this.getNPCProgress();
         var firstAchievementGrant:Object = this.getFeatureOptionsKey(KEY_SAVED_FIRST_ACHIEVEMENT) as Object;
         var secondAchievementGrant:Object = this.getFeatureOptionsKey(KEY_SAVED_SECOND_ACHIEVEMENT) as Object;
         var thirdAchievementGrant:Object = this.getFeatureOptionsKey(KEY_SAVED_THIRD_ACHIEVEMENT) as Object;
         var fourthAchievementGrant:Object = this.getFeatureOptionsKey(KEY_SAVED_FOURTH_ACHIEVEMENT) as Object;
         if(score >= ACHIEVEMENT_POINTS_ARRAY[0] && firstAchievementGrant == null && !this.hasExpiryDatePassedForAchievement(0))
         {
            this.saveFeatureOptionsKey(KEY_SAVED_FIRST_ACHIEVEMENT,ACHIEVEMENT_COMPLETED);
         }
         else if(score >= ACHIEVEMENT_POINTS_ARRAY[1] && secondAchievementGrant == null && !this.hasExpiryDatePassedForAchievement(1))
         {
            this.saveFeatureOptionsKey(KEY_SAVED_SECOND_ACHIEVEMENT,ACHIEVEMENT_COMPLETED);
         }
         else if(score >= ACHIEVEMENT_POINTS_ARRAY[2] && thirdAchievementGrant == null && !this.hasExpiryDatePassedForAchievement(2))
         {
            this.saveFeatureOptionsKey(KEY_SAVED_THIRD_ACHIEVEMENT,ACHIEVEMENT_COMPLETED);
         }
         else if(score >= ACHIEVEMENT_POINTS_ARRAY[3] && fourthAchievementGrant == null && !this.hasExpiryDatePassedForAchievement(3))
         {
            this.saveFeatureOptionsKey(KEY_SAVED_FOURTH_ACHIEVEMENT,ACHIEVEMENT_COMPLETED);
         }
      }
      
      public function redeemAchievement(m_slotIndex:Number) : void
      {
         var achievementId:String = null;
         var featureKeyString:String = null;
         var itemName:String = null;
         var bonusItemName:String = null;
         switch(m_slotIndex)
         {
            case 0:
               featureKeyString = KEY_SAVED_FIRST_ACHIEVEMENT;
               itemName = "xca_foodiesfavouritecertificate";
               bonusItemName = "duck_xca_blancacanvas";
               achievementId = "17";
               break;
            case 1:
               featureKeyString = KEY_SAVED_SECOND_ACHIEVEMENT;
               itemName = "xca_heavenlyfoodaward";
               bonusItemName = "cow_xca_morrocansand";
               achievementId = "18";
               break;
            case 2:
               featureKeyString = KEY_SAVED_THIRD_ACHIEVEMENT;
               itemName = "xca_foodacademyaward";
               bonusItemName = "magicdeer_xca_strawberryspotpony";
               achievementId = "19";
               break;
            case 3:
               featureKeyString = KEY_SAVED_FOURTH_ACHIEVEMENT;
               itemName = "xca_gourmetkingtrophy";
               bonusItemName = "horse_xca_windstripe";
               achievementId = "20";
               break;
            default:
               featureKeyString = "";
         }
         this.saveFeatureOptionsKey(featureKeyString,ACHIEVEMENT_REDEEMED);
         this.saveFeatureOptionsKey(KEY_SAVED_LAST_ACHIEVEMENT_REDEEMED,achievementId);
         var achievementItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         if(this.m_achievementWindow)
         {
            this.m_achievementWindow.refreshTaskFrame();
         }
         Global.player.addGift(bonusItemName);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"redeemAchievement",this.onRedeemAchievement,new Array(m_featureName,m_slotIndex)));
         this.m_redeemAchivement_ItemName = achievementItem;
         this.m_achivement_bonusItemName = bonusItemName;
         var slotIdString:String = (m_slotIndex + 1).toString();
         FarmStatsManager.count(FEATURE_TRACKING,"Reward",slotIdString,achievementItem.friendlyTitle,bonusItemName,this.getNPCProgress().toString());
      }
      
      private function onRedeemAchievement(result:Object) : void
      {
         if(Boolean(result) && Boolean(this.m_achievementWindow))
         {
            this.m_achievementWindow.refreshTaskFrame();
         }
         this.m_redeemResultObject = result;
         this.m_achievementRewardWindow = new CasablancaInnovationAchievementRewardPopup(this.REWARD_SHARE_WINDOW,"CasablancaInnovationAchievementReward",this.m_redeemAchivement_ItemName,this.m_achivement_bonusItemName,this.postAchievementRedeemBragFeed,this.REWARD_WINDOW_IMAGE);
         UI.displayPopup(this.m_achievementRewardWindow,false);
         this.m_redeemAchivement_ItemName = null;
         this.m_achivement_bonusItemName = null;
      }
      
      public function getAchievementState(m_slotIndex:Number) : Object
      {
         var featureKeyString:String = null;
         switch(m_slotIndex)
         {
            case 0:
               featureKeyString = KEY_SAVED_FIRST_ACHIEVEMENT;
               break;
            case 1:
               featureKeyString = KEY_SAVED_SECOND_ACHIEVEMENT;
               break;
            case 2:
               featureKeyString = KEY_SAVED_THIRD_ACHIEVEMENT;
               break;
            case 3:
               featureKeyString = KEY_SAVED_FOURTH_ACHIEVEMENT;
               break;
            default:
               featureKeyString = "";
         }
         if(featureKeyString)
         {
            return this.getFeatureOptionsKey(featureKeyString) as Object;
         }
         return null;
      }
      
      public function isAchievementRedeemActive(m_slotIndex:Number) : Boolean
      {
         var state:Object = this.getAchievementState(m_slotIndex);
         if(state == 1)
         {
            if(this.m_achievementWindow)
            {
               this.m_achievementWindow.showNPCCallouts("Grab that Award!","Go to the awards menu and click on Redeem to win an exclusive reward!");
            }
            return true;
         }
         return false;
      }
      
      public function isAchievementExpired(m_slotIndex:Number) : Boolean
      {
         var state:Object = this.getAchievementState(m_slotIndex);
         if(this.hasExpiryDatePassedForAchievement(m_slotIndex) && state != 2)
         {
            return true;
         }
         return false;
      }
      
      public function isAchievementRedeemed(m_slotIndex:Number) : Boolean
      {
         var state:Object = this.getAchievementState(m_slotIndex);
         if(state == 2)
         {
            return true;
         }
         return false;
      }
      
      public function isAnyAchievementReadyToRedeem() : int
      {
         var state:Object = null;
         var i:int = 0;
         while(i < 4)
         {
            state = this.getAchievementState(i);
            if(state == 1)
            {
               return ++i;
            }
            i++;
         }
         return 0;
      }
      
      public function isAnyAchievementClosetoExpire() : int
      {
         var state:Object = null;
         var i:int = 0;
         while(i < 4)
         {
            state = this.getAchievementState(i);
            if(state == null && this.isAchievementAbouttoExpire(i))
            {
               return ++i;
            }
            i++;
         }
         return 0;
      }
      
      public function getLatestRedeemedAchievement() : Number
      {
         var result:Number = 1;
         var latestRedeem:Object = this.getFeatureOptionsKey(KEY_SAVED_LAST_ACHIEVEMENT_REDEEMED) as Object;
         if(latestRedeem)
         {
            switch(latestRedeem)
            {
               case "17":
                  result = 2;
                  break;
               case "18":
                  result = 3;
                  break;
               case "19":
                  result = 4;
                  break;
               case "20":
                  result = 5;
                  break;
               default:
                  result = 1;
            }
            return result;
         }
         return result;
      }
      
      public function getAchievementRedeemedCount() : Number
      {
         var result:Number = 0;
         var i:int = 0;
         while(i < 4)
         {
            if(this.getAchievementState(i) == 2)
            {
               result++;
            }
            i++;
         }
         return result;
      }
      
      public function isFeatureComplete() : Boolean
      {
         var score:Number = this.getNPCProgress();
         return score >= VAL_FINAL_MILESTONE;
      }
      
      public function grantPointsForTask(pointsForTask:int) : void
      {
         var currentDayPoints:int = 0;
         var finalRewardTaken:int = this.getFeatureOptionsKey(CasablancaInnovationManager.KEY_SAVED_FINAL_REWARD_RECEIVED) as int;
         if(finalRewardTaken)
         {
            if(this.hasActiveDayExpired())
            {
               this.saveFeatureOptionsKey(this.KEY_ACTIVE_DAY_TIMESTAMP,FarmGameUtil.getMidnightTimestamp() / 1000);
               this.saveFeatureOptionsKey(this.KEY_DAY_REWARD_GRANT_STATUS,0);
               this.saveFeatureOptionsKey(this.KEY_DAY_POINTS,0);
            }
            currentDayPoints = this.getFeatureOptionsKey(this.KEY_DAY_POINTS) as int;
            currentDayPoints += pointsForTask;
            this.saveFeatureOptionsKey(this.KEY_DAY_POINTS,currentDayPoints);
            if(this.isEligibleForDayReward())
            {
               if(this.m_window)
               {
                  this.m_window.closeShopShutter();
               }
               this.grantDayReward();
            }
         }
         else
         {
            FeatureOptionsInventoryManager.getInstance().addCount(CASABLANCA_TASK_POINTS_ITEM_CODE,pointsForTask);
         }
      }
      
      public function getAchievementName(AchievementReadytoRedeem:int) : String
      {
         switch(AchievementReadytoRedeem)
         {
            case 0:
               return "Foodie’s Favourite Certificate";
            case 1:
               return "Heavenly Food Award";
            case 2:
               return "Food Academy Award";
            case 3:
               return "Gourmet King Trophy";
            default:
               return null;
         }
      }
      
      public function hasActiveDayExpired() : Boolean
      {
         var diff:int = 0;
         var expired:Boolean = false;
         var activeTime:int = this.getFeatureOptionsKey(this.KEY_ACTIVE_DAY_TIMESTAMP) as int;
         var currenttime:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(currenttime - activeTime > 86400)
         {
            expired = true;
         }
         var featureFinishedTimeStamp:int = this.getFeatureOptionsKey(this.KEY_FEATURE_FINISHED_EXACT_TIMESTAMP) as int;
         var featureFinishedDayEndTime:int = (this.getFeatureOptionsKey(this.KEY_FEATURE_FINISHED_TIME) as int) + 86400;
         if(this.getActiveDayIndex() == 0)
         {
            if(featureFinishedDayEndTime - featureFinishedTimeStamp < 64800)
            {
               diff = featureFinishedDayEndTime - currenttime + 86400;
               this.saveFeatureOptionsKey(this.KEY_FEATURE_FIRST_DAY_CORNER_CASE,1);
               if(diff > 0)
               {
                  expired = false;
               }
            }
         }
         return expired;
      }
      
      public function getNumberOfDailyHours() : String
      {
         var result:String = null;
         var minuteString:String = "00";
         var secondsString:String = "00";
         var hoursString:String = "00";
         var activeTime:int = this.getFeatureOptionsKey(this.KEY_ACTIVE_DAY_TIMESTAMP) as int;
         var featureFinishedTimeStamp:int = this.getFeatureOptionsKey(this.KEY_FEATURE_FINISHED_EXACT_TIMESTAMP) as int;
         var featureFinishedDayStartTime:int = (this.getFeatureOptionsKey(this.KEY_FEATURE_FINISHED_TIME) as int) + 86400;
         var currenttime:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var hasDayExpired:Boolean = this.hasActiveDayExpired();
         var diff:int = activeTime - currenttime;
         if(this.getActiveDayIndex() == 0)
         {
            if(featureFinishedDayStartTime - featureFinishedTimeStamp < 64800)
            {
               diff += 86400;
            }
         }
         var seconds:int = Math.floor((diff + 86400) % 60);
         var minutes:int = Math.floor((diff + 86400) / 60);
         var hours:int = Math.floor(minutes / 60);
         minutes %= 60;
         if(minutes < 0)
         {
            minutes = 0;
         }
         if(seconds < 0)
         {
            seconds = 0;
         }
         if(hours < 0)
         {
            hours = 0;
         }
         hoursString = hours.toString();
         minuteString = minutes.toString();
         secondsString = seconds.toString();
         if(hours <= 9)
         {
            hoursString = "0" + hoursString;
         }
         if(minutes >= 0 && minutes <= 9)
         {
            minuteString = "0" + minuteString;
         }
         if(seconds >= 0 && seconds <= 9)
         {
            secondsString = "0" + secondsString;
         }
         return hoursString + ":" + minuteString + ":" + secondsString + " remaining";
      }
      
      public function isEligibleForDayReward() : Boolean
      {
         var result:Boolean = false;
         if(this.hasGrantedDayReward() == false)
         {
            if(this.getFeatureOptionsKey(this.KEY_DAY_POINTS) as int >= this.DAY_REWARD_MILESTONE_POINTS)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function isLessThan18HoursLeftForFeature() : Boolean
      {
         var result:Boolean = false;
         var featureCompletionTime:int = this.getFeatureOptionsKey(this.KEY_FEATURE_FINISHED_TIME) as int;
         if(this.m_endTimeStamp - featureCompletionTime < 64800)
         {
            result = true;
         }
         return result;
      }
      
      public function isDailyRewardDaysCountOver() : Boolean
      {
         var result:Boolean = false;
         if(this.getActiveDayIndex() >= 7)
         {
            result = true;
         }
         return result;
      }
      
      public function getActiveDayIndex() : int
      {
         var result:int = 0;
         var activeDayTS:int = FarmGameUtil.getMidnightTimestamp() / 1000;
         var featureStartDayTS:int = this.getFeatureOptionsKey(this.KEY_FEATURE_FINISHED_TIME) as int;
         var dayIndex:int = (activeDayTS - featureStartDayTS) / 86400;
         result = dayIndex;
         if(this.getFeatureOptionsKey(this.KEY_FEATURE_FIRST_DAY_CORNER_CASE) == 1)
         {
            if(result != 0)
            {
               result--;
            }
         }
         return result;
      }
      
      public function isFeatureCompletedOnLastDay() : Boolean
      {
         var isLast:Boolean = false;
         var featureStartDayTS:int = this.getFeatureOptionsKey(this.KEY_FEATURE_FINISHED_TIME) as int;
         if(this.getActiveDayIndex() == 0)
         {
            isLast = int(this.m_endTimeStamp / 1000) - featureStartDayTS == 86400;
         }
         return isLast;
      }
      
      public function isBonusHarvestExpired() : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("03/03/2019") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         timeLeft = endTime - now;
         if(timeLeft <= 0)
         {
            result = true;
         }
         return result;
      }
      
      public function isDailyPlayActive() : Boolean
      {
         var isActive:Boolean = false;
         if(this.isFinalRewardGranted() && this.getActiveDayIndex() < 7)
         {
            isActive = true;
         }
         else
         {
            isActive = false;
         }
         if(this.isFeatureCompletedOnLastDay())
         {
            isActive = false;
         }
         return isActive;
      }
      
      public function isCurrentDayExpired() : Boolean
      {
         if(this.isFinalRewardGranted() && this.getActiveDayIndex() < 7 && this.hasActiveDayExpired())
         {
            return true;
         }
         return false;
      }
      
      public function getcurrentDayIndex() : int
      {
         var activeDayTS:int = this.getFeatureOptionsKey(this.KEY_ACTIVE_DAY_TIMESTAMP) as int;
         var featureStartDayTS:int = this.getFeatureOptionsKey(this.KEY_FEATURE_FINISHED_TIME) as int;
         return int((activeDayTS - featureStartDayTS) / 86400);
      }
      
      public function getTotalDayIndex() : int
      {
         var dayIndex:int = 0;
         var activeDayTS:int = this.getFeatureOptionsKey(this.KEY_ACTIVE_DAY_TIMESTAMP) as int;
         var featureStartDayTS:int = this.getFeatureOptionsKey(this.KEY_FEATURE_FINISHED_TIME) as int;
         var featureEndDayTS:int = featureStartDayTS + 604800;
         var featureExpiryDate:int = FarmGameUtil.synchronizedDateToNumber("02/25/2019") / 1000;
         featureEndDayTS = featureEndDayTS > featureExpiryDate ? featureExpiryDate : featureEndDayTS;
         return int((featureEndDayTS - featureStartDayTS) / 86400);
      }
      
      public function hasGrantedDayReward() : Boolean
      {
         var result:Boolean = false;
         if(this.getFeatureOptionsKey(this.KEY_DAY_REWARD_GRANT_STATUS) == 1)
         {
            result = true;
         }
         return result;
      }
      
      public function grantDayReward() : void
      {
         var itemName:String = DAILY_REWARDS[this.getActiveDayIndex()];
         var daycount:String = (this.getActiveDayIndex() + 1).toString();
         Global.player.addGift(itemName);
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         var featureKey:String = m_featureName + "_daily_reward_reward";
         FarmStatsManager.count(FEATURE_TRACKING,"Challenge",daycount,"Complete",itemName,this.getDailyNPCProgress().toString());
         this.saveFeatureOptionsKey(this.KEY_DAY_REWARD_GRANT_STATUS,1);
         this.m_rewardDailyWindow = new GenericSingleRewardPopup(this.REWARD_SHARE_WINDOW,featureKey,rewardItem,this.resetDailyProgressMeter,this.REWARD_WINDOW_IMAGE);
         UI.displayPopup(this.m_rewardDailyWindow,false);
      }
      
      private function resetDailyProgressMeter(e:MouseEvent) : void
      {
         if(this.m_window)
         {
            this.m_window.refreshTaskFrame();
         }
         this.postElderDailyChallenegBragFeed(e);
      }
      
      public function harvestCasablancaBuilding(itemName:String = null) : void
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
            UI.displayPopup(new GenericSingleRewardPopup(this.REWARD_POPUP_WINDOW,"CasablancaInnovation_daily_harvest_reward",harvestFarmItem,null,this.REWARD_WINDOW_IMAGE));
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
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("casablanca_innovation_harvest_enabled");
         if(!PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            result = false;
         }
         if(this.getNPCProgress() < 1000)
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
      
      public function setFinalRewardGrantFlag() : void
      {
         if(!Global.player.getSeenFlag(FEATURE_SET_FINAL_REWARD))
         {
            Global.player.setSeenFlag(FEATURE_SET_FINAL_REWARD);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,this.SERVICE_FUNC_SET_FINAL_REWARD_GRANT,null,[m_featureName]),true);
         }
      }
      
      public function isLandbundleActive() : Boolean
      {
         var landBundleUnlockDate:String = "05/07/2018";
         var landBundleEndDate:String = "05/17/2018";
         var startTimeStamp:Number = FarmGameUtil.synchronizedDateToNumber(landBundleUnlockDate) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var endTimeStamp:Number = FarmGameUtil.synchronizedDateToNumber(landBundleEndDate) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return startTimeStamp < currentTime && currentTime < endTimeStamp;
      }
      
      public function isLandBundleUnlocked() : Boolean
      {
         return Global.player.getSeenFlag(LAND_BUNDLE_UNLOCKED);
      }
      
      public function setRedeemCallout(flag:Boolean = false) : void
      {
         this.m_showRedeemCallout = flag;
      }
      
      public function getRedeemCallout() : Boolean
      {
         return this.m_showRedeemCallout;
      }
   }
}

