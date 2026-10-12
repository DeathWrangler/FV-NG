package Managers
{
   import Classes.Constants.QuestConstants;
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import Managers.Crafting.CraftingManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.GuildEventBuildingGrantWindow;
   import Widgets.Windows.GuildEventCompleteWindow;
   import Widgets.Windows.GuildEventDetailWindow;
   import Widgets.Windows.GuildEventElderWindow;
   import Widgets.Windows.GuildEventMainWindow;
   import Widgets.Windows.GuildEventMapWindow;
   import Widgets.Windows.GuildEventMilestoneRewardWindow;
   import Widgets.Windows.GuildEventOrderSelectionWindow;
   import Widgets.Windows.GuildEventPostHarvestRewardWindow;
   import Widgets.Windows.GuildMessageWindow;
   import flash.events.Event;
   
   public class GuildEventManager extends BaseFeatureManager
   {
      
      private static var m_endDate:String;
      
      private static var m_startDate:String;
      
      private static const coopXML:Class = GuildEventManager_coopXML;
      
      public static const featureXML:XML = XML(new coopXML());
      
      private static const FEATURE_NAME:String = featureXML.child("featureName");
      
      private static const SERVICE_NAME:String = "GuildEventService";
      
      private static const FIRST_TIME_FILL_ORDER:String = "FIRST_TIME_FILL_ORDER";
      
      private static const WINDOW_MAIN:String = "main";
      
      private static const WINDOW_REWARD:String = "reward";
      
      private static const WINDOW_ORDER:String = "order";
      
      private static const WINDOW_DETAIL:String = "detail";
      
      private static const WINDOW_END:String = "end";
      
      private static const SKIP_COST:int = 1;
      
      private static var m_initialized:Boolean = false;
      
      private static const KEY_SAVED_ACTIVE_TASKS:String = "1";
      
      private static const KEY_SAVED_DUMPED_TIMESTAMP:String = "3";
      
      public static const KEY_TASK_COMPLETED:String = "taskCompleted";
      
      public static const KEY_OB_POINTS:String = "OBPoints";
      
      public static const KEY_CURRENT_TIER:String = "currentTier";
      
      public static const KEY_TASK:String = "task";
      
      public static const TEMP_FO_GUILd_ORDER_DATA:String = "guildOrderData";
      
      public static const TEMP_FO_GUILD_OB_POINTS:String = featureXML.child("tempFoGuildOBPoints");
      
      public static const TEMP_FO_GUILD_CURRENT_TIER:String = "currentTier";
      
      public static const TEMP_FO_GUILD_MILESTONE_LEVEL:String = "milestone";
      
      public static const KEY_HELPING_TASK_STATUS:String = "helpTaskStatus";
      
      public static const KEY_SELECTED_HELP_TASK_DATA:String = "helpTaskData";
      
      public static const LAST_ASK_HELP_TIME_KEY:String = "lastAskHelpTimeKey";
      
      public static const ASK_HELP_TIME_INTERVAL:int = 14400;
      
      public static const TEMP_FO_GUILD_HELP_ORDER_DATA:String = "guildEventHelpData";
      
      public static const GUILD_HELP_ORDER_DATA:String = "helpData";
      
      public static const KEY_HELP_TASK_INDEX:String = "helpTaskIndex";
      
      public static const PLAYER_DATA:String = "playerData";
      
      public static const HELPED_TASK_COUNT:String = "helpedTaskCount";
      
      public static const KEY_REWARD_MILESTONE_LEVEL:String = "milestone";
      
      private static const LAST_BONUS_HARVEST_TIME_KEY:String = "bht";
      
      public static const DEFAULT_HARVEST_THROTTLE_TIME:Number = 86400;
      
      private static const BONUS_HARVEST_COUNT:String = "hc";
      
      private static const BONUS_COUNT_MAP:Object = {
         "lostcity":4,
         "desertmonastry":5,
         "skytemple":6
      };
      
      private static const SERVICE_FUNC_HARVEST_BONUS:String = "harvestBonusBuilding";
      
      private static const GRANT_STATUS:String = "grant_status";
      
      private static const GRANTED:int = 1;
      
      private static const NOT_GRANTED:int = 0;
      
      private static const GUILD_EVENT_NAME:String = featureXML.child("GUILD_EVENT_NAME");
      
      private const QUEST_NAME:String = featureXML.child("questName");
      
      public const NOT_INITIALIZED:int = -1;
      
      public const EASY:int = 0;
      
      public const MEDIUM:int = 1;
      
      public const HARD:int = 2;
      
      protected var m_staticData:Object;
      
      private var m_assetPaths:Object;
      
      public var m_orderSelectionWindow:GuildEventOrderSelectionWindow;
      
      private var taskTypesArray:Array = [["M1","M1","M1","M1","M1","M1","M1","M1","M1","M1","M1","M1"],["M2","M2","M2","M2","M2","M2","M2","M2","M2","M2","M2","M2","M2"],["M3","M3","M3","M3","M3","M3","M3","M3","M3","M3","M3","M3","M3"]];
      
      public var tierMilestone:Array = [1050,2100,3500];
      
      public var FINAL_MILESTONE:int = 3500;
      
      public var milestonePoints:Array = [350,700,1050,1400,1750,2100,2567,3033,3500];
      
      private const KEY_LAST_USED_TYPE:String = "lt";
      
      private var m_tasksByTypes:Object = null;
      
      private const KEY_USER_STATE:String = "state";
      
      private const KEY_LAST_TASKS_IDS:String = "2";
      
      private const KEY_MISC_EASY:String = "M1";
      
      private const KEY_MISC_MEDIUM:String = "M2";
      
      private const KEY_MISC_HARD:String = "M3";
      
      private const KEY_TASK_PROGRESS:String = "progress";
      
      private const KEY_TASK_ID:String = "id";
      
      private const KEY_TASK_TYPE:String = "type";
      
      private const KEY_ACTIVE_TASK:String = "activeTask";
      
      private const KEY_INDEX:String = "slotIndex";
      
      private const KEY_REQ_SLOT_INDEX:String = "reqSlotIndex";
      
      protected const KEY_TOTAL:String = "total";
      
      protected const KEY_PROGRESS:String = "progress";
      
      public const KEY_POINTS:String = "tp";
      
      private const KEY_DUMPED_STATUS:String = "dump_status";
      
      private var m_waitingDialog:GenericPopup;
      
      public var m_guildEventMainWindow:GuildEventMainWindow;
      
      public const GUILD_CURRENT_EVENT_LOCK_STATUS:String = "eventLockStatus";
      
      private const LOCKED:int = 0;
      
      private const UNLOCKED:int = 1;
      
      private var GUILD_ORDER_DATA:String = "orderData";
      
      private const GUILD_ORDER_ALREADY_SELECT:String = "orderAlreadySelected";
      
      private const GUILD_ORDER_ID_MISMATCH:String = "orderIdMismatch";
      
      private const GUILD_SLOT_ALREADY_FULL:String = "slotAlreadyFull";
      
      private const GUILD_SAME_TYPE_ORDER_ALREADY_PRESENT:String = "sameTypeTaslAlreadyPresent";
      
      public var m_guildEventDetailWindow:GuildEventDetailWindow;
      
      public var m_guildEventMapWindow:GuildEventMapWindow;
      
      private var m_orderWaitingDialog:GenericPopup;
      
      private var m_guildEventMilestoneRewardWindow:GuildEventMilestoneRewardWindow;
      
      private var m_guildEventBuildingRewardWindow:GuildEventBuildingGrantWindow;
      
      private var m_rewardsBySlotName:Object = null;
      
      private var BONUS_HARVEST_ARRAY:Array = ["consume_organic_fertilizer","consume_unwither","consume_farm_hands","fuel1","consume_instagrow","consume_turbo_charger"];
      
      private var m_guildElderWindow:GuildEventElderWindow;
      
      private var m_guildEventCompleteWindow:GuildEventCompleteWindow;
      
      private var m_grantStarted:Boolean = false;
      
      public var m_guildMessageWindow:GuildMessageWindow;
      
      public function GuildEventManager(featureName:String, featureConfig:XML = null)
      {
         super(featureName,featureConfig);
         this.parseTaskObjectsFromConfig(this.QUEST_NAME);
         this.parseRewardsDataFromConfig(this.QUEST_NAME);
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
      }
      
      public static function getInstance(featureName:String = "") : GuildEventManager
      {
         featureName = FEATURE_NAME;
         return BaseFeatureManager.getInstanceOfClass(featureName,GuildEventManager) as GuildEventManager;
      }
      
      public static function isSinkForEventActive() : Boolean
      {
         return getTimeLeftForEventEnd() >= 0 && timeLeftInNextSinkStart() <= 0;
      }
      
      public static function eventStartDate() : String
      {
         return m_startDate ? m_startDate : featureXML.child("eventStartDate");
      }
      
      public static function isEventOver() : Boolean
      {
         return getTimeLeftForEventEnd() <= 0;
      }
      
      public static function eventEndDate() : String
      {
         return m_endDate ? m_endDate : featureXML.child("eventEndDate");
      }
      
      public static function getTimeLeftForEventStart() : Number
      {
         var dayExpiredTime:Number = FarmGameUtil.synchronizedDateTimeToNumber(eventStartDate()) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return dayExpiredTime - currenttime;
      }
      
      public static function getTimeLeftForEventEnd() : Number
      {
         var dayExpiredTime:Number = FarmGameUtil.synchronizedDateTimeToNumber(eventEndDate()) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return dayExpiredTime - currenttime;
      }
      
      public static function get rewardBuildingNameArray() : Array
      {
         return [featureXML.child("BONUS_COUNT_MAP").child("buildingNames").child("buildingName1"),featureXML.child("BONUS_COUNT_MAP").child("buildingNames").child("buildingName2"),featureXML.child("BONUS_COUNT_MAP").child("buildingNames").child("buildingName3")];
      }
      
      public static function timeLeftInNextSinkStart() : Number
      {
         var dayExpiredTime:Number = FarmGameUtil.synchronizedDateTimeToNumber("4/20/2019") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return dayExpiredTime - currenttime;
      }
      
      public function getUserGrantedRewardLevel() : int
      {
         var featureData:Object = this.getFeatureData();
         if(!featureData.hasOwnProperty(KEY_REWARD_MILESTONE_LEVEL))
         {
            featureData[KEY_REWARD_MILESTONE_LEVEL] = 0;
         }
         return featureData[KEY_REWARD_MILESTONE_LEVEL];
      }
      
      public function grantAllPendingRewards() : void
      {
         var userRewardLevel:int = 0;
         var playerOBPoints:int = 0;
         var featureObject:Object = null;
         var guildMilestoneLevel:int = 0;
         if(this.hasUserStartedCurrentEvent() && getTimeLeftForEventStart() < 0)
         {
            if(this.hasCompletedCurrentEvent() == false)
            {
               userRewardLevel = this.getUserGrantedRewardLevel();
               if(userRewardLevel >= 9)
               {
                  if(this.m_guildEventMapWindow)
                  {
                     this.m_guildEventMapWindow.close();
                  }
                  if(this.m_guildEventDetailWindow)
                  {
                     this.m_guildEventDetailWindow.close();
                  }
                  if(this.m_guildEventMainWindow)
                  {
                     this.m_guildEventMainWindow.close();
                  }
                  playerOBPoints = this.getUserPoints();
                  playerOBPoints = int(playerOBPoints * 0.08);
                  featureObject = GuildManager.getInstance().getFeatureData();
                  if(featureObject)
                  {
                     featureObject[GuildManager.PLAYER_GUILD_POINTS] += playerOBPoints;
                  }
                  GuildManager.getInstance().setFeatureData(featureObject);
                  if(GuildManager.getInstance().m_guildMainWindow)
                  {
                     GuildManager.getInstance().m_guildMainWindow.refreshUserPoints();
                     GuildManager.getInstance().m_guildMainWindow.updatePlayerPointsDoober(playerOBPoints);
                  }
                  this.m_guildEventCompleteWindow = new GuildEventCompleteWindow(m_featureName,featureXML.child("guildEventCompleteWindow"),{},playerOBPoints);
                  UI.displayPopup(this.m_guildEventCompleteWindow,false);
                  this.markFeatureAsCompleted();
               }
               else
               {
                  guildMilestoneLevel = this.getGuildMilestoneLevel();
                  if(this.m_grantStarted == false)
                  {
                     if(GuildEventManager.getTimeLeftForEventEnd() <= 0)
                     {
                        TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"grantAllPendingRewards",this.onGrantAllPendingRewards,[m_featureName]),true);
                     }
                     else if(userRewardLevel < guildMilestoneLevel)
                     {
                        TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"grantAllPendingRewards",this.onGrantAllPendingRewards,[m_featureName]),true);
                     }
                  }
               }
            }
         }
      }
      
      public function onGrantAllPendingRewards(result:Object = null) : void
      {
         var currentTier:int = 0;
         var currentMileStoneInCurrentTier:int = 0;
         var rewardItemCode:String = null;
         var rewardFarmItem:FarmItem = null;
         var featureData:Object = null;
         var userRewardLevel:int = this.getUserGrantedRewardLevel();
         var guildMilestoneLevel:int = this.getGuildMilestoneLevel();
         if(userRewardLevel < guildMilestoneLevel)
         {
            currentTier = userRewardLevel / 3;
            currentMileStoneInCurrentTier = userRewardLevel % 3;
            userRewardLevel += 1;
            rewardItemCode = (this.getRewardsForTier(currentTier)[currentMileStoneInCurrentTier] as Object).value;
            rewardFarmItem = Global.farmGameSettingsManager.getFarmItemByCode(rewardItemCode);
            Global.player.addGift(rewardFarmItem.name);
            featureData = this.getFeatureData();
            featureData[KEY_REWARD_MILESTONE_LEVEL] = userRewardLevel;
            setFeatureData(featureData);
            if(this.getUserGrantedRewardLevel() % 3 == 0 && this.hasGrantedBuildingRewardForPreviousTier() == false)
            {
               this.grantedBuildingRewardForPreviousTier();
            }
            else
            {
               this.m_guildEventMilestoneRewardWindow = new GuildEventMilestoneRewardWindow(m_featureName,featureXML.child("guildEventMilestoneRewardWindow"),rewardFarmItem);
               UI.displayPopup(this.m_guildEventMilestoneRewardWindow,false);
               this.m_guildEventMainWindow.updateMiniMilestoneRewards();
            }
         }
         else
         {
            this.m_grantStarted = false;
            if(getTimeLeftForEventEnd() <= 0 && this.hasCompletedCurrentEvent() == false)
            {
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"markFeatureAsCompletedForIncompleteEvent",this.onMarkFeatureAsCompletedForIncompleteEvent,[m_featureName]),true);
               this.onMarkFeatureAsCompletedForIncompleteEvent();
            }
         }
      }
      
      public function onMarkFeatureAsCompletedForIncompleteEvent(result:Object = null) : void
      {
         var playerOBPoints:int = 0;
         var featureObject:Object = null;
         if(result)
         {
            playerOBPoints = this.getUserPoints();
            playerOBPoints = int(playerOBPoints * 0.08);
            featureObject = GuildManager.getInstance().getFeatureData();
            if(featureObject)
            {
               featureObject[GuildManager.PLAYER_GUILD_POINTS] += playerOBPoints;
            }
            GuildManager.getInstance().setFeatureData(featureObject);
            if(GuildManager.getInstance().m_guildMainWindow)
            {
               GuildManager.getInstance().m_guildMainWindow.refreshUserPoints();
               GuildManager.getInstance().m_guildMainWindow.updatePlayerPointsDoober(playerOBPoints);
            }
            this.m_guildEventCompleteWindow = new GuildEventCompleteWindow(m_featureName,featureXML.child("guildEventCompleteWindow"),{},playerOBPoints);
            UI.displayPopup(this.m_guildEventCompleteWindow,false);
            this.markFeatureAsCompleted();
         }
      }
      
      public function checkAndGrantAllPendingRewardsFromPreviousGuild() : void
      {
         if(this.hasCompletedCurrentEvent() == false)
         {
            if(this.hasUserStartedCurrentEvent() && getTimeLeftForEventStart() < 0)
            {
               if(this.hasCompletedCurrentEvent() == false)
               {
                  TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"checkAndGrantAllPendingRewardsFromPreviousGuild",this.onCheckAndGrantAllPendingRewardsFromPreviousGuild,[m_featureName]),true);
               }
            }
         }
      }
      
      public function onCheckAndGrantAllPendingRewardsFromPreviousGuild(result:Object) : void
      {
         var prevGuildMileStone:int = 0;
         var userRewardLevel:int = 0;
         var guildMilestoneLevel:int = 0;
         var currentTier:int = 0;
         var currentMileStoneInCurrentTier:int = 0;
         var rewardItemCode:String = null;
         var rewardFarmItem:FarmItem = null;
         var featureData:Object = null;
         var playerOBPoints:int = 0;
         var featureObject:Object = null;
         if(Boolean(result) && Boolean(result["data"]))
         {
            prevGuildMileStone = int(result["data"]["mileStone"]);
            userRewardLevel = this.getUserGrantedRewardLevel();
            guildMilestoneLevel = prevGuildMileStone;
            if(userRewardLevel < guildMilestoneLevel)
            {
               currentTier = userRewardLevel / 3;
               currentMileStoneInCurrentTier = userRewardLevel % 3;
               userRewardLevel += 1;
               rewardItemCode = (this.getRewardsForTier(currentTier)[currentMileStoneInCurrentTier] as Object).value;
               rewardFarmItem = Global.farmGameSettingsManager.getFarmItemByCode(rewardItemCode);
               Global.player.addGift(rewardFarmItem.name);
               featureData = this.getFeatureData();
               featureData[KEY_REWARD_MILESTONE_LEVEL] = userRewardLevel;
               setFeatureData(featureData);
               if(this.getUserGrantedRewardLevel() % 3 == 0 && this.hasGrantedBuildingRewardForPreviousTier() == false)
               {
                  this.grantedBuildingRewardForPreviousTier();
                  GuildManager.getInstance().setHudNotifText("Map section finished!");
                  FarmStatsManager.count(featureXML.child("coop_feature_v3"),"tier_complete",this.getUserGrantedRewardLevel().toString(),GuildManager.getInstance().getGuildId());
               }
               else
               {
                  this.m_guildEventMilestoneRewardWindow = new GuildEventMilestoneRewardWindow(m_featureName,featureXML.child("guildEventMilestoneRewardWindow"),rewardFarmItem);
                  UI.displayPopup(this.m_guildEventMilestoneRewardWindow,false);
                  GuildManager.getInstance().setHudNotifText("Milestone reached!");
                  FarmStatsManager.count(featureXML.child("coop_feature_v3"),"milestone_complete",this.getUserGrantedRewardLevel().toString(),GuildManager.getInstance().getGuildId());
               }
            }
            else
            {
               playerOBPoints = this.getUserPoints();
               playerOBPoints = int(playerOBPoints * 0.08);
               featureObject = GuildManager.getInstance().getFeatureData();
               if(featureObject)
               {
                  featureObject[GuildManager.PLAYER_GUILD_POINTS] += playerOBPoints;
               }
               GuildManager.getInstance().setFeatureData(featureObject);
               if(GuildManager.getInstance().m_guildMainWindow)
               {
                  GuildManager.getInstance().m_guildMainWindow.refreshUserPoints();
                  GuildManager.getInstance().m_guildMainWindow.updatePlayerPointsDoober(playerOBPoints);
               }
               this.m_guildEventCompleteWindow = new GuildEventCompleteWindow(m_featureName,featureXML.child("guildEventCompleteWindow"),{},playerOBPoints);
               UI.displayPopup(this.m_guildEventCompleteWindow,false);
               this.markFeatureAsCompleted();
               FarmStatsManager.count(featureXML.child("coop_feature_v3"),"feature_complete",this.getUserGrantedRewardLevel().toString(),GuildManager.getInstance().getGuildId());
            }
         }
      }
      
      protected function onTransactionAdded(event:TransactionEvent) : void
      {
         this.checkForTaskUpdates(event);
      }
      
      protected function checkForTaskUpdates(event:TransactionEvent) : void
      {
         var progress:Number = NaN;
         var transaction:TFarmTransaction = null;
         var hasUpdatedProgress:Boolean = false;
         var hasCompletedTask:Boolean = false;
         var progressArray:Array = [];
         var tasks:Vector.<FarmTask> = this.getActiveTasks();
         var featureData:Object = this.getFeatureData();
         for(var i:int = 0; i < tasks.length; i++)
         {
            transaction = event.transaction as TFarmTransaction;
            if(tasks[i].helperType == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
            {
               progress = CraftingManager.getInstance().getBushelQuantityInInventory(tasks[i].type) - featureData[KEY_SAVED_ACTIVE_TASKS][i][this.KEY_PROGRESS];
               hasUpdatedProgress = true;
               FarmStatsManager.count(featureXML.child("coop_feature_v3"),"PerformTask",tasks[i].type,GuildManager.getInstance().getGuildId());
            }
            else if(tasks[i].helperType == QuestConstants.HELPER_TYPE_WORLD_SCORE)
            {
               progress = Global.player.getWorldScore(tasks[i].type);
            }
            else
            {
               progress = FarmQuestUtility.getInstance().getProgression(tasks[i],transaction,null);
            }
            progressArray.push(progress);
            if(progress > 0)
            {
               hasUpdatedProgress = true;
               if(Number(featureData[KEY_SAVED_ACTIVE_TASKS][i][this.KEY_PROGRESS]) + progress >= tasks[i].total)
               {
                  hasCompletedTask = true;
                  FarmStatsManager.count(featureXML.child("coop_feature_v3"),"PerformTask",tasks[i].type,GuildManager.getInstance().getGuildId());
               }
            }
         }
         if(hasUpdatedProgress)
         {
            this.saveProgressForPlayer(progressArray);
         }
         if(hasCompletedTask)
         {
            GuildManager.getInstance().setHudNotifText("Task ready to redeem");
         }
      }
      
      protected function saveProgressForPlayer(progressArray:Array) : void
      {
         var tasks:Vector.<FarmTask> = this.getActiveTasks();
         var featureData:Object = this.getFeatureData();
         for(var i:int = 0; i < tasks.length; i++)
         {
            if(tasks[i].helperType == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
            {
               featureData[KEY_SAVED_ACTIVE_TASKS][i][this.KEY_PROGRESS] = CraftingManager.getInstance().getBushelQuantityInInventory(tasks[i].type);
            }
            else if(tasks[i].helperType == QuestConstants.HELPER_TYPE_WORLD_SCORE)
            {
               featureData[KEY_SAVED_ACTIVE_TASKS][i][this.KEY_PROGRESS] = int(progressArray[i]);
            }
            else
            {
               featureData[KEY_SAVED_ACTIVE_TASKS][i][this.KEY_PROGRESS] = Math.min(Number(featureData[KEY_SAVED_ACTIVE_TASKS][i][this.KEY_PROGRESS]) + progressArray[i],tasks[i][this.KEY_TOTAL]);
            }
         }
         setFeatureData(featureData);
      }
      
      public function initialize() : void
      {
         this.loadStaticData();
      }
      
      private function loadStaticData() : void
      {
         var asset:XML = null;
         this.m_staticData = {};
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         if(featureXML != null)
         {
            m_initialized = true;
            this.m_assetPaths = {};
            if(featureXML.assets != "")
            {
               for each(asset in featureXML.assets.asset)
               {
                  this.m_assetPaths[asset.@name] = asset.@path.toString();
               }
            }
            if(featureXML.listEndDate)
            {
               m_endDate = featureXML.listEndDate.toString();
            }
            if(featureXML.listStartDate)
            {
               m_startDate = featureXML.listStartDate.toString();
            }
         }
      }
      
      public function get mainWindowURL() : String
      {
         return this.m_assetPaths[WINDOW_MAIN];
      }
      
      public function get rewardWindowURL() : String
      {
         return this.m_assetPaths[WINDOW_REWARD];
      }
      
      public function get detailWindowURL() : String
      {
         return this.m_assetPaths[WINDOW_DETAIL];
      }
      
      public function get orderWindowURL() : String
      {
         return this.m_assetPaths[WINDOW_ORDER];
      }
      
      public function get endWindowURL() : String
      {
         return this.m_assetPaths[WINDOW_END];
      }
      
      public function getFeatureData() : Object
      {
         var index:int = 0;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,m_featureName);
         if(!featureData)
         {
            featureData = {};
            featureData[this.KEY_USER_STATE] = this.NOT_INITIALIZED;
            featureData[KEY_SAVED_ACTIVE_TASKS] = {};
            for(index = 0; index < 4; index++)
            {
               featureData[KEY_SAVED_ACTIVE_TASKS][index] = {};
               featureData[KEY_SAVED_ACTIVE_TASKS][index][this.KEY_TASK_TYPE] = "M0";
               featureData[KEY_SAVED_ACTIVE_TASKS][index][this.KEY_TASK_ID] = -1;
               featureData[KEY_SAVED_ACTIVE_TASKS][index][this.KEY_TASK_PROGRESS] = 0;
               featureData[KEY_SAVED_ACTIVE_TASKS][index][this.KEY_DUMPED_STATUS] = 0;
               featureData[KEY_SAVED_ACTIVE_TASKS][index]["help"] = 0;
            }
            featureData[KEY_OB_POINTS] = 0;
            featureData[KEY_TASK_COMPLETED] = 0;
            featureData[KEY_REWARD_MILESTONE_LEVEL] = 0;
            featureData[KEY_HELPING_TASK_STATUS] = 0;
            featureData[HELPED_TASK_COUNT] = 0;
            featureData[KEY_SAVED_DUMPED_TIMESTAMP] = {};
            setFeatureData(featureData);
         }
         return featureData;
      }
      
      public function isSameTaskActive(taskType:String, taskIndex:int) : Boolean
      {
         var taskXML:XML = null;
         var farmTask:FarmTask = null;
         var taskObj:Object = null;
         var result:Boolean = false;
         var tasks:Vector.<FarmTask> = this.getActiveTasksForGuild();
         taskXML = this.m_tasksByTypes[taskType][taskIndex];
         taskObj = FarmGameUtil.xmlNodeToAttributes(taskXML);
         taskObj.questName = m_featureName;
         farmTask = new FarmTask(taskObj);
         for(var i:int = 0; i < tasks.length; i++)
         {
            if(Boolean(tasks[i] && farmTask) && Boolean(farmTask.action != "DummyTask") && tasks[i].action != "DummyTask")
            {
               if(tasks[i].type == farmTask.type)
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      public function getActiveTasks() : Vector.<FarmTask>
      {
         var taskType:String = null;
         var taskIndex:int = 0;
         var taskXML:XML = null;
         var farmTask:FarmTask = null;
         var taskObj:Object = null;
         var index:int = 0;
         var taskList:Vector.<FarmTask> = new Vector.<FarmTask>();
         if(this.m_tasksByTypes == null)
         {
            this.parseTaskObjectsFromConfig(this.QUEST_NAME);
         }
         var activeTask:int = 3;
         if(this.isHelpTaskSelected())
         {
            activeTask = 4;
         }
         var featureData:Object = this.getFeatureData();
         if(featureData)
         {
            for(index = 0; index < activeTask; index++)
            {
               taskType = featureData[KEY_SAVED_ACTIVE_TASKS][index][this.KEY_TASK_TYPE];
               taskIndex = int(featureData[KEY_SAVED_ACTIVE_TASKS][index][this.KEY_TASK_ID]);
               if(taskType == null || taskIndex == -1)
               {
                  taskObj = new Object();
                  taskObj.action = "DummyTask";
                  taskObj.type = "fa1v";
                  taskObj.total = "50";
                  taskObj.cashValue = "3";
                  taskObj.helper = "post_ask_for_item_feed";
                  taskObj.questName = m_featureName;
                  taskObj.taskIndex = index;
                  farmTask = new FarmTask(taskObj);
                  taskList.push(farmTask);
               }
               else
               {
                  taskXML = this.m_tasksByTypes[taskType][taskIndex];
                  taskObj = FarmGameUtil.xmlNodeToAttributes(taskXML);
                  taskObj.questName = m_featureName;
                  taskObj.taskIndex = index;
                  farmTask = new FarmTask(taskObj);
                  taskList.push(farmTask);
               }
            }
         }
         return taskList;
      }
      
      public function getActiveTasksForGuild() : Vector.<FarmTask>
      {
         var taskType:String = null;
         var taskIndex:int = 0;
         var taskXML:XML = null;
         var farmTask:FarmTask = null;
         var taskObj:Object = null;
         var index:int = 0;
         var taskList:Vector.<FarmTask> = new Vector.<FarmTask>();
         if(this.m_tasksByTypes == null)
         {
            this.parseTaskObjectsFromConfig(this.QUEST_NAME);
         }
         var featureData:Object = this.getFeatureOrderData();
         if(featureData)
         {
            for(index = 0; index < 12; index++)
            {
               taskType = featureData[KEY_SAVED_ACTIVE_TASKS][index][this.KEY_TASK_TYPE];
               taskIndex = int(featureData[KEY_SAVED_ACTIVE_TASKS][index][this.KEY_TASK_ID]);
               if(taskType == null || taskIndex == -1)
               {
                  taskObj = new Object();
                  taskObj.action = "DummyTask";
                  taskObj.type = "fa1v";
                  taskObj.total = "50";
                  taskObj.cashValue = "3";
                  taskObj.helper = "post_ask_for_item_feed";
                  taskObj.questName = m_featureName;
                  taskObj.taskIndex = index;
                  farmTask = new FarmTask(taskObj);
                  taskList.push(farmTask);
               }
               else
               {
                  taskXML = this.m_tasksByTypes[taskType][taskIndex];
                  taskObj = FarmGameUtil.xmlNodeToAttributes(taskXML);
                  taskObj.questName = m_featureName;
                  taskObj.taskIndex = index;
                  farmTask = new FarmTask(taskObj);
                  taskList.push(farmTask);
               }
            }
         }
         return taskList;
      }
      
      protected function parseTaskObjectsFromConfig(questName:String) : void
      {
         var index:int = 0;
         var taskType:String = null;
         var orderBoardXml:XML = null;
         var tasksByDifficultyList:XMLList = null;
         var tasksByDiff:XML = null;
         var tasksByDiffAndTypeList:XMLList = null;
         var tasksByDiffAndType:XML = null;
         var taskXML:XML = null;
         this.m_tasksByTypes = {};
         index = 0;
         orderBoardXml = Global.farmGameSettingsManager.getXML().orderBoards.orderBoard.(@name == questName)[0];
         if(orderBoardXml)
         {
            tasksByDifficultyList = orderBoardXml.orderBoardTasks;
            for each(tasksByDiff in tasksByDifficultyList)
            {
               tasksByDiffAndTypeList = tasksByDiff.tasks;
               for each(tasksByDiffAndType in tasksByDiffAndTypeList)
               {
                  index = 0;
                  taskType = tasksByDiffAndType.@type.toString();
                  this.m_tasksByTypes[taskType] = {};
                  for each(taskXML in tasksByDiffAndType.task)
                  {
                     this.m_tasksByTypes[taskType][index] = taskXML;
                     index++;
                  }
               }
            }
         }
      }
      
      protected function parseRewardsDataFromConfig(questName:String) : void
      {
         var orderBoardXml:XML = null;
         var rewardsList:XMLList = null;
         var rewardsByStage:XML = null;
         var str:String = null;
         var rewardsXMLListByStage:XMLList = null;
         this.m_rewardsBySlotName = {};
         orderBoardXml = Global.farmGameSettingsManager.getXML().child(featureXML.child("FVGuildEventQuests")).child(featureXML.child("FVGuildEventQuest")).(@name == questName)[0];
         rewardsList = orderBoardXml.child(featureXML.child("FVGuildEventRewards")).stage;
         for each(rewardsByStage in rewardsList)
         {
            str = rewardsByStage.@id;
            rewardsXMLListByStage = rewardsByStage.rewards;
            this.m_rewardsBySlotName[rewardsByStage.@id] = rewardsXMLListByStage;
         }
      }
      
      public function getRewardsForTier(tierNum:int) : Vector.<Object>
      {
         var rewardXML:XML = null;
         var rewardObj:Object = null;
         var rewards:Vector.<Object> = new Vector.<Object>();
         if(this.m_rewardsBySlotName == null)
         {
            this.parseRewardsDataFromConfig(this.QUEST_NAME);
         }
         if(tierNum > 2)
         {
            tierNum = 2;
         }
         var rewardXMLList:XMLList = this.m_rewardsBySlotName[tierNum].reward;
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
      
      public function getTaskProgress(slotIndex:int) : int
      {
         var progress:int = 0;
         var task:FarmTask = this.getActiveTasks()[slotIndex];
         var featureData:Object = this.getFeatureData();
         switch(task.action)
         {
            case "sinkBushel":
               progress = CraftingManager.getInstance().getBushelQuantityInInventory(task.type);
               break;
            case "worldScore":
               progress = Global.player.getWorldScore(task.type);
               break;
            default:
               progress = int(featureData[KEY_SAVED_ACTIVE_TASKS][slotIndex][this.KEY_TASK_PROGRESS]);
         }
         return progress;
      }
      
      public function firstTimeOrderFilled() : Boolean
      {
         var result:Boolean = false;
         if(Global.player.getSeenFlag(FIRST_TIME_FILL_ORDER) == true)
         {
            result = true;
         }
         return result;
      }
      
      public function fillFirstTimeOrder() : void
      {
         if(Global.player.getSeenFlag(FIRST_TIME_FILL_ORDER) == false)
         {
            Global.player.setSeenFlag(FIRST_TIME_FILL_ORDER);
         }
      }
      
      public function openGuildMessageWindow(message:String = "", closeHandler:Function = null, title:String = null, fromSelect:Boolean = false) : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         if(this.m_orderSelectionWindow)
         {
            this.m_orderSelectionWindow.tintWindow();
            this.m_orderSelectionWindow.enableInput = false;
         }
         if(fromSelect)
         {
            if(this.m_guildEventMainWindow)
            {
               this.m_guildEventMainWindow.m_overlayMc.visible = true;
            }
         }
         else if(this.m_guildEventMainWindow)
         {
            this.m_guildEventMainWindow.tintWindow();
            this.m_guildEventMainWindow.enableInput = false;
         }
         this.m_guildMessageWindow = new GuildMessageWindow(m_featureName,"assets/dialogs/Coop2019/FV_Coop2019_Message.swf",message,closeHandler,title,fromSelect);
         UI.displayPopup(this.m_guildMessageWindow,false);
      }
      
      public function openGuildEventDetailWindow() : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         if(GuildEventManager.getInstance().m_guildEventMainWindow)
         {
            GuildEventManager.getInstance().m_guildEventMainWindow.tintWindow();
            GuildEventManager.getInstance().m_guildEventMainWindow.enableInput = false;
         }
         this.m_guildEventDetailWindow = new GuildEventDetailWindow(m_featureName,featureXML.child("guildEventDetailWindow"));
         UI.displayPopup(this.m_guildEventDetailWindow,false);
      }
      
      public function openGuildEventMapWindow() : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         if(this.m_guildEventMainWindow)
         {
            this.m_guildEventMainWindow.tintWindow();
            this.m_guildEventMainWindow.enableInput = false;
         }
         this.m_guildEventMapWindow = new GuildEventMapWindow(m_featureName,featureXML.child("guildEventMapWindow"));
         UI.displayPopup(this.m_guildEventMapWindow,false);
      }
      
      public function openGuildEventMainWindow() : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         this.m_guildEventMainWindow = new GuildEventMainWindow(m_featureName,featureXML.child("guildEventMainWindow"));
         UI.displayPopup(this.m_guildEventMainWindow,false);
      }
      
      public function openOrderboardSelectionUI(reqSlotNumber:int) : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         if(GuildEventManager.getInstance().m_guildEventMainWindow)
         {
            GuildEventManager.getInstance().m_guildEventMainWindow.tintWindow();
            GuildEventManager.getInstance().m_guildEventMainWindow.enableInput = false;
         }
         this.m_orderSelectionWindow = new GuildEventOrderSelectionWindow(m_featureName,featureXML.child("orderSelectionWindow"),reqSlotNumber);
         UI.displayPopup(this.m_orderSelectionWindow,false);
         FarmStatsManager.count(featureXML.child("statCounter"),"event","event_order_ui","open","impression");
      }
      
      public function fillOrder() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"fillOrder",this.onFillOrder,[m_featureName]),true);
      }
      
      public function onFillOrder(result:Object) : void
      {
         if(Boolean(result) && Boolean(result[this.GUILD_ORDER_DATA]))
         {
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILd_ORDER_DATA,result[this.GUILD_ORDER_DATA]);
            if(result.hasOwnProperty(GUILD_HELP_ORDER_DATA))
            {
               FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILD_HELP_ORDER_DATA,result[GUILD_HELP_ORDER_DATA]);
               if(this.m_guildEventMainWindow)
               {
                  this.m_guildEventMainWindow.refreshTaskFrame();
               }
            }
            if(this.m_orderSelectionWindow)
            {
               this.m_orderSelectionWindow.refreshOrderboardFrame();
            }
         }
      }
      
      public function fillOrder1() : void
      {
         var message:String = null;
         if(this.m_orderWaitingDialog == null)
         {
            if(this.m_orderSelectionWindow)
            {
               this.m_orderSelectionWindow.tintWindow();
               this.m_orderSelectionWindow.enableInput = false;
               if(this.m_guildEventMainWindow)
               {
                  this.m_guildEventMainWindow.m_overlayMc.visible = true;
               }
               message = "Tasks are being refreshed. Please wait...";
               this.m_orderWaitingDialog = UI.displayMessage(message,GenericPopup.TYPE_MODAL,null,"",true);
            }
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"fillOrder",this.onFillOrder1,[m_featureName]),true);
      }
      
      public function onFillOrder1(result:Object) : void
      {
         if(this.m_orderWaitingDialog)
         {
            this.m_orderWaitingDialog.close();
            this.m_orderWaitingDialog = null;
         }
         if(Boolean(result) && Boolean(result[this.GUILD_ORDER_DATA]))
         {
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILd_ORDER_DATA,result[this.GUILD_ORDER_DATA]);
            if(result.hasOwnProperty(GUILD_HELP_ORDER_DATA))
            {
               FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILD_HELP_ORDER_DATA,result[GUILD_HELP_ORDER_DATA]);
               if(this.m_guildEventMainWindow)
               {
                  this.m_guildEventMainWindow.refreshTaskFrame();
               }
            }
            if(this.m_orderSelectionWindow)
            {
               this.m_orderSelectionWindow.untintWindow();
               this.m_orderSelectionWindow.enableInput = true;
               this.m_orderSelectionWindow.refreshOrderboardFrame();
            }
            if(this.m_guildEventMainWindow)
            {
               this.m_guildEventMainWindow.m_overlayMc.visible = false;
            }
         }
      }
      
      public function onGetNewOrders(e:Event) : void
      {
         if(this.m_orderSelectionWindow)
         {
            this.m_orderSelectionWindow.refreshOrderboardFrame();
         }
      }
      
      public function onGetHelpOrders(e:Event) : void
      {
         if(this.m_guildEventMainWindow)
         {
            this.m_guildEventMainWindow.refreshHelpTaskFrame();
         }
      }
      
      public function onCloseSelectionWindow(e:Event) : void
      {
         if(this.m_orderSelectionWindow)
         {
            this.m_orderSelectionWindow.close();
         }
      }
      
      public function selectNewOrder(slotIndex:int, reqSlotIndex:int) : void
      {
         var OrderData:Object = this.getFeatureOrderData();
         var taskId:int = int(OrderData[KEY_SAVED_ACTIVE_TASKS][slotIndex][this.KEY_TASK_ID]);
         if(this.m_orderSelectionWindow)
         {
            this.m_orderSelectionWindow.tintWindow();
            this.m_orderSelectionWindow.enableInput = false;
         }
         var message:String = "Task selection in progress";
         this.m_waitingDialog = UI.displayMessage(message,GenericPopup.TYPE_MODAL,null,"",true);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"selectNewOrder",this.onSelectNewOrder,[m_featureName,slotIndex,taskId,reqSlotIndex]),true);
      }
      
      public function onSelectNewOrder(result:Object) : void
      {
         if(this.m_orderSelectionWindow)
         {
            this.m_orderSelectionWindow.untintWindow();
            this.m_orderSelectionWindow.enableInput = true;
         }
         if(this.m_waitingDialog)
         {
            this.m_waitingDialog.close();
            this.m_waitingDialog = null;
         }
         if(Boolean(result) && Boolean(result[this.GUILD_SLOT_ALREADY_FULL]))
         {
            this.openGuildMessageWindow("This slot is already occupied. Please select another free slot.",this.onCloseSelectionWindow,"",true);
         }
         else if(Boolean(result) && Boolean(result[this.GUILD_ORDER_ALREADY_SELECT]))
         {
            this.openGuildMessageWindow("This task is already selected by another member of your clan. Please select another task.",this.onGetNewOrders,"",true);
         }
         else if(Boolean(result) && Boolean(result[this.GUILD_ORDER_ID_MISMATCH]))
         {
            this.openGuildMessageWindow("Your selection does not match the orderboard. Please select another task.",this.onGetNewOrders,"",true);
         }
         else if(Boolean(result) && Boolean(result[this.GUILD_SAME_TYPE_ORDER_ALREADY_PRESENT]))
         {
            this.openGuildMessageWindow("You have already selected a similar task on one of your slots. Please select a different task.",this.onGetNewOrders,"",true);
         }
         else
         {
            if(Boolean(result) && Boolean(result[this.GUILD_ORDER_DATA]))
            {
               this.onFillOrder(result);
            }
            if(Boolean(result) && Boolean(result[this.KEY_ACTIVE_TASK]))
            {
               this.fillOrderInRequiedSlot(result);
            }
            if(this.m_orderSelectionWindow)
            {
               this.m_orderSelectionWindow.close();
               if(GuildEventMainWindow.m_FTUEState == 2)
               {
                  ++GuildEventMainWindow.m_FTUEState;
                  if(this.m_guildEventMainWindow)
                  {
                     this.m_guildEventMainWindow.resumeFTUEFlow();
                  }
               }
            }
         }
      }
      
      public function fillOrderInRequiedSlot(result:Object) : void
      {
         var slotIndex:int = 0;
         var featureData:Object = this.getFeatureData();
         if(featureData)
         {
            if(Boolean(result) && Boolean(result[this.KEY_ACTIVE_TASK]))
            {
               slotIndex = int(result[this.KEY_REQ_SLOT_INDEX]);
               featureData[KEY_SAVED_ACTIVE_TASKS][slotIndex][this.KEY_TASK_TYPE] = result[this.KEY_TASK_TYPE];
               featureData[KEY_SAVED_ACTIVE_TASKS][slotIndex][this.KEY_TASK_ID] = result[this.KEY_TASK_ID];
               featureData[KEY_SAVED_DUMPED_TIMESTAMP][slotIndex] = 0;
               featureData[KEY_SAVED_ACTIVE_TASKS][slotIndex][this.KEY_DUMPED_STATUS] = 0;
               setFeatureData(featureData);
               FarmStatsManager.count(featureXML.child("coop_feature_v3"),"AddTask",result[this.KEY_TASK_TYPE],GuildManager.getInstance().getGuildId(),slotIndex.toString());
            }
         }
      }
      
      public function getFeatureOrderData() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILd_ORDER_DATA);
      }
      
      public function isEventActive() : Boolean
      {
         var result:Boolean = false;
         if(this.hasUserStartedCurrentEvent())
         {
            if(getTimeLeftForEventStart() <= 0 && getTimeLeftForEventEnd() > 0 && !this.hasCompletedCurrentEvent())
            {
               result = true;
            }
         }
         return result;
      }
      
      public function getKeysRequiredForCurrentEvent() : int
      {
         return 80;
      }
      
      public function unlockGuildEventForUser() : void
      {
         if(GuildManager.getInstance().m_guildMainWindow)
         {
            GuildManager.getInstance().m_guildMainWindow.tintWindow();
            GuildManager.getInstance().m_guildMainWindow.enableInput = false;
         }
         var requiredKeys:int = this.getKeysRequiredForCurrentEvent();
         GuildManager.getInstance().deductKeysForEvent(requiredKeys);
         GuildManager.getInstance().grantEventEntryPoints();
         var fo:Object = this.getFeatureData();
         if(fo)
         {
            fo[this.GUILD_CURRENT_EVENT_LOCK_STATUS] = this.UNLOCKED;
            setFeatureData(fo);
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"unlockGuildEventForUser",null,[m_featureName]),true);
         var message:String = "You have earned 80 Stat Points!";
         var title:String = "Stats up!";
         this.openGuildMessageWindow(message,this.onunlockGuildEventForUser,title);
      }
      
      public function onunlockGuildEventForUser(e:Event) : void
      {
         if(GuildManager.getInstance().m_guildMainWindow)
         {
            GuildManager.getInstance().m_guildMainWindow.untintWindow();
            GuildManager.getInstance().m_guildMainWindow.enableInput = true;
            GuildManager.getInstance().m_guildMainWindow.updateMembersStatus();
         }
      }
      
      public function hasUserStartedCurrentEvent() : Boolean
      {
         var result:Boolean = false;
         var fo:Object = this.getFeatureData();
         if(Boolean(fo) && fo.hasOwnProperty(this.GUILD_CURRENT_EVENT_LOCK_STATUS))
         {
            if(fo[this.GUILD_CURRENT_EVENT_LOCK_STATUS] == this.UNLOCKED)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function allSlotsFull() : Boolean
      {
         var taskType:String = null;
         var taskIndex:int = 0;
         var i:int = 0;
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(featureData)
         {
            for(i = 0; i < 3; i++)
            {
               taskType = featureData[KEY_SAVED_ACTIVE_TASKS][i][this.KEY_TASK_TYPE];
               taskIndex = int(featureData[KEY_SAVED_ACTIVE_TASKS][i][this.KEY_TASK_ID]);
               if(taskType == "M0" || taskIndex == -1)
               {
                  break;
               }
            }
            if(i == 3)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function isTaskRedeemable(slotIndex:int) : Boolean
      {
         var result:Boolean = false;
         var progress:int = this.getTaskProgress(slotIndex);
         var task:FarmTask = this.getActiveTasks()[slotIndex];
         var total:int = task.total;
         if(this.isHelpAskedForTask(slotIndex) || slotIndex == 3)
         {
            total /= 2;
         }
         if(progress >= total)
         {
            result = true;
         }
         return result;
      }
      
      private function resetActionCountsForTasks(questTask:FarmTask) : void
      {
         var actionKey:String = null;
         if(questTask.action == QuestConstants.TASK_USE_ITEM_BY_CODE)
         {
            actionKey = FEATURE_NAME + "_" + questTask.type;
            if(Boolean(actionKey) && actionKey != "")
            {
               Global.player.resetActionCount(actionKey);
            }
         }
      }
      
      public function onUpdateGuildScore(result:Object) : void
      {
         var obPoints:int = 0;
         var curTier:int = 0;
         var upgrade:Boolean = false;
         if(result)
         {
            obPoints = 0;
            curTier = 0;
            upgrade = false;
            if(result[TEMP_FO_GUILD_OB_POINTS])
            {
               obPoints = int(result[TEMP_FO_GUILD_OB_POINTS]);
               FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILD_OB_POINTS,obPoints);
            }
            if(result[KEY_CURRENT_TIER])
            {
               FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILD_CURRENT_TIER,result[KEY_CURRENT_TIER]);
            }
            if(result[KEY_REWARD_MILESTONE_LEVEL])
            {
               FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILD_MILESTONE_LEVEL,result[KEY_REWARD_MILESTONE_LEVEL]);
            }
            if(this.m_guildEventMainWindow)
            {
               this.m_guildEventMainWindow.updateGuildPoints();
               this.m_guildEventMainWindow.updateMiniSagaMap();
               this.m_guildEventMainWindow.updateGuildBackground();
            }
            this.grantAllPendingRewards();
         }
      }
      
      public function sinkGold(slotIndex:int) : void
      {
         var tasks:Vector.<FarmTask> = this.getActiveTasks();
         var helpcut:int = 1;
         if(Global.player.canBuy(tasks[slotIndex].total))
         {
            if(this.isHelpAskedForTask(slotIndex) || slotIndex == 3)
            {
               helpcut = 2;
            }
            Global.player.gold -= tasks[slotIndex].total / helpcut;
            this.postTaskCompletionActions(slotIndex);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkGold",this.onUpdateGuildScore,[m_featureName,slotIndex]),true);
         }
      }
      
      public function sinkBushel(slotIndex:int) : void
      {
         var tasks:Vector.<FarmTask> = this.getActiveTasks();
         CraftingManager.getInstance().deductItemFromCraftingInventory(tasks[slotIndex].type,tasks[slotIndex].total);
         this.postTaskCompletionActions(slotIndex);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkBushel",this.onUpdateGuildScore,[m_featureName,slotIndex]),true);
      }
      
      public function postTaskCompletionActions(completedTaskSlotIndex:int) : void
      {
         var questTasks1:Vector.<FarmTask> = null;
         var featureObject:Object = this.getFeatureData();
         questTasks1 = GuildEventManager.getInstance(m_featureName).getActiveTasks();
         var helpcut:int = 1;
         if(this.isHelpAskedForTask(completedTaskSlotIndex) || completedTaskSlotIndex == 3)
         {
            helpcut = 2;
         }
         featureObject[KEY_OB_POINTS] += questTasks1[completedTaskSlotIndex].questPoints / helpcut;
         if(completedTaskSlotIndex == 3)
         {
            featureObject[HELPED_TASK_COUNT] += 1;
            featureObject[KEY_HELPING_TASK_STATUS] = 0;
         }
         else
         {
            featureObject[KEY_TASK_COMPLETED] += 1;
         }
         setFeatureData(featureObject);
         var tasks:Vector.<FarmTask> = this.getActiveTasks();
         this.resetActionCountsForTasks(tasks[completedTaskSlotIndex]);
         this.makeSlotEmpty(completedTaskSlotIndex);
         this.m_guildEventMainWindow.updateTaskDoober(questTasks1[completedTaskSlotIndex].questPoints / helpcut);
         this.m_guildEventMainWindow.refreshTaskFrame();
         this.m_guildEventMainWindow.updateUserPoints();
         this.m_guildEventMainWindow.m_playerTasksFrame.updateNoOfUserTasks();
      }
      
      public function redeemSlotTask(slotIndex:int) : void
      {
         var questTasks1:Vector.<FarmTask> = null;
         var tasks:Vector.<FarmTask> = this.getActiveTasks();
         var featureObject:Object = this.getFeatureData();
         questTasks1 = GuildEventManager.getInstance(m_featureName).getActiveTasks();
         var taskPt:int = questTasks1[slotIndex].questPoints;
         var helpCut:int = 1;
         if(this.isHelpAskedForTask(slotIndex) || slotIndex == 3)
         {
            helpCut = 2;
         }
         if(slotIndex == 3)
         {
            featureObject[HELPED_TASK_COUNT] += 1;
            featureObject[KEY_HELPING_TASK_STATUS] = 0;
         }
         else
         {
            featureObject[KEY_TASK_COMPLETED] += 1;
         }
         featureObject[KEY_OB_POINTS] += questTasks1[slotIndex].questPoints / helpCut;
         setFeatureData(featureObject);
         this.makeSlotEmpty(slotIndex);
         this.resetActionCountsForTasks(tasks[slotIndex]);
         this.m_guildEventMainWindow.updateTaskDoober(questTasks1[slotIndex].questPoints / helpCut);
         this.m_guildEventMainWindow.refreshTaskFrame();
         this.m_guildEventMainWindow.updateUserPoints();
         this.m_guildEventMainWindow.m_playerTasksFrame.updateNoOfUserTasks();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"redeemTask",this.onUpdateGuildScore,[m_featureName,slotIndex]),true);
         FarmStatsManager.count(featureXML.child("coop_feature_v3"),"RedeemTask",tasks[slotIndex].type,GuildManager.getInstance().getGuildId());
      }
      
      public function redeemWorldScoreTask(slotIndex:int) : void
      {
         var featureObject:Object = this.getFeatureData();
         var questTasks:Vector.<FarmTask> = this.getActiveTasks();
         var helpCut:int = 1;
         if(this.isHelpAskedForTask(slotIndex) || slotIndex == 3)
         {
            helpCut = 2;
         }
         if(slotIndex == 3)
         {
            featureObject[HELPED_TASK_COUNT] += 1;
            featureObject[KEY_HELPING_TASK_STATUS] = 0;
         }
         else
         {
            featureObject[KEY_TASK_COMPLETED] += 1;
         }
         featureObject[KEY_OB_POINTS] += questTasks[slotIndex].questPoints / helpCut;
         setFeatureData(featureObject);
         this.makeSlotEmpty(slotIndex);
         this.resetActionCountsForTasks(questTasks[slotIndex]);
         this.m_guildEventMainWindow.updateTaskDoober(questTasks[slotIndex].questPoints / helpCut);
         this.m_guildEventMainWindow.refreshTaskFrame();
         this.m_guildEventMainWindow.updateUserPoints();
         this.m_guildEventMainWindow.m_playerTasksFrame.updateNoOfUserTasks();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"redeemWorldScoreTask",this.onUpdateGuildScore,[m_featureName,slotIndex]),true);
      }
      
      public function skipTask(slotIndex:int, callback:Function) : void
      {
         var featureObject:Object = null;
         var questTasks1:Vector.<FarmTask> = null;
         var tasks:Vector.<FarmTask> = this.getActiveTasks();
         var helpCut:int = 1;
         if(this.isHelpAskedForTask(slotIndex) || slotIndex == 3)
         {
            helpCut = 2;
         }
         if(Global.player.canBuyCash(tasks[slotIndex].skipCashValue / helpCut))
         {
            Global.player.cash -= tasks[slotIndex].skipCashValue / helpCut;
            featureObject = this.getFeatureData();
            questTasks1 = GuildEventManager.getInstance(m_featureName).getActiveTasks();
            if(slotIndex == 3)
            {
               featureObject[HELPED_TASK_COUNT] += 1;
               featureObject[KEY_HELPING_TASK_STATUS] = 0;
            }
            else
            {
               featureObject[KEY_TASK_COMPLETED] += 1;
            }
            featureObject[KEY_OB_POINTS] += int(questTasks1[slotIndex].questPoints / helpCut);
            setFeatureData(featureObject);
            this.makeSlotEmpty(slotIndex);
            this.m_guildEventMainWindow.untintWindow();
            this.m_guildEventMainWindow.enableInput = true;
            this.m_guildEventMainWindow.updateTaskDoober(questTasks1[slotIndex].questPoints / helpCut);
            this.m_guildEventMainWindow.updateUserPoints();
            this.m_guildEventMainWindow.m_playerTasksFrame.updateNoOfUserTasks();
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipTask",this.onUpdateGuildScore,[m_featureName,slotIndex]),true);
            FarmStatsManager.count(featureXML.child("coop_feature_v3"),"SkipTask",questTasks1[slotIndex].type,GuildManager.getInstance().getGuildId());
            this.resetActionCountsForTasks(tasks[slotIndex]);
            this.m_guildEventMainWindow.refreshTaskFrame();
         }
         else
         {
            callback.call();
         }
      }
      
      public function isTaskDumped(questIndex:int) : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(featureData[KEY_SAVED_ACTIVE_TASKS][questIndex].hasOwnProperty(this.KEY_DUMPED_STATUS))
         {
            if(featureData[KEY_SAVED_ACTIVE_TASKS][questIndex][this.KEY_DUMPED_STATUS] == 1)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function dumpTask(slotIndex:int) : void
      {
         var featureData:Object = null;
         var tasks:Vector.<FarmTask> = null;
         if(this.canDumpTask(slotIndex))
         {
            if(this.m_guildEventMainWindow)
            {
               this.m_guildEventMainWindow.untintWindow();
               this.m_guildEventMainWindow.enableInput = true;
            }
            featureData = this.getFeatureData();
            tasks = this.getActiveTasks();
            featureData[KEY_SAVED_DUMPED_TIMESTAMP][slotIndex] = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            featureData[KEY_SAVED_ACTIVE_TASKS][slotIndex][this.KEY_DUMPED_STATUS] = 1;
            if(slotIndex == 3)
            {
               featureData[KEY_HELPING_TASK_STATUS] = 0;
            }
            setFeatureData(featureData);
            this.makeSlotEmpty(slotIndex,true);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"dumpTask",null,[m_featureName,slotIndex]),true);
            FarmStatsManager.count(featureXML.child("coop_feature_v3"),"DumpTask",tasks[slotIndex].type,GuildManager.getInstance().getGuildId());
            this.m_guildEventMainWindow.refreshTaskFrame();
         }
      }
      
      public function skipDumpedTask(slotIndex:int) : void
      {
         var tasks:Vector.<FarmTask> = null;
         var featureData:Object = null;
         if(Global.player.canBuyCash(SKIP_COST))
         {
            tasks = this.getActiveTasks();
            Global.player.cash -= SKIP_COST;
            this.resetActionCountsForTasks(tasks[slotIndex]);
            featureData = this.getFeatureData();
            featureData[KEY_SAVED_DUMPED_TIMESTAMP][slotIndex] = 0;
            featureData[KEY_SAVED_ACTIVE_TASKS][slotIndex][this.KEY_DUMPED_STATUS] = 0;
            setFeatureData(featureData);
            this.makeSlotEmpty(slotIndex);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipDumpedTask",null,[m_featureName,slotIndex]),true);
            this.m_guildEventMainWindow.refreshTaskFrame();
         }
      }
      
      public function canDumpTask(questIndex:int) : Boolean
      {
         var currentTime:Number = NaN;
         var result:Boolean = true;
         var throttleTimeInSeconds:Number = 15 * FarmGameUtil.NUM_SECS_IN_MINUTE;
         var dumpTimestamp:Object = this.getFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP) as Object;
         if(dumpTimestamp != null && dumpTimestamp.hasOwnProperty(questIndex.toString()))
         {
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            result = currentTime - dumpTimestamp[questIndex] > throttleTimeInSeconds;
         }
         return result;
      }
      
      public function isTaskDumpTimeOver(questIndex:int) : Boolean
      {
         var currentTime:Number = NaN;
         var timediff:Number = NaN;
         var result:Boolean = false;
         var throttleTimeInSeconds:Number = 15 * FarmGameUtil.NUM_SECS_IN_MINUTE;
         var dumpTimestamp:Object = this.getFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP) as Object;
         if(dumpTimestamp != null && dumpTimestamp.hasOwnProperty(questIndex.toString()))
         {
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            timediff = throttleTimeInSeconds - (currentTime - dumpTimestamp[questIndex]);
            if(timediff <= 0)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function getTimeRemainingForDumpedTask(questIndex:int) : Number
      {
         var result:Number = NaN;
         var currentTime:Number = NaN;
         var throttleTimeInSeconds:Number = 15 * FarmGameUtil.NUM_SECS_IN_MINUTE;
         var dumpTimestamp:Object = this.getFeatureOptionsKey(KEY_SAVED_DUMPED_TIMESTAMP) as Object;
         if(dumpTimestamp != null && dumpTimestamp.hasOwnProperty(questIndex.toString()))
         {
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            result = throttleTimeInSeconds - (currentTime - dumpTimestamp[questIndex]);
         }
         return result;
      }
      
      protected function getFeatureOptionsKey(optionName:String) : Object
      {
         var fatureObject:Object = this.getFeatureData();
         return fatureObject[optionName];
      }
      
      protected function saveFeatureOptionsKey(optionName:String, optionsValue:Object) : void
      {
         var fatureObject:Object = this.getFeatureData();
         fatureObject[optionName] = optionsValue;
         setFeatureData(fatureObject);
      }
      
      public function makeSlotEmpty(slotIndex:int, isDumpTask:Boolean = false) : void
      {
         var featureData:Object = this.getFeatureData();
         if(featureData)
         {
            featureData[KEY_SAVED_ACTIVE_TASKS][slotIndex][this.KEY_TASK_TYPE] = "M0";
            featureData[KEY_SAVED_ACTIVE_TASKS][slotIndex][this.KEY_TASK_ID] = -1;
            featureData[KEY_SAVED_ACTIVE_TASKS][slotIndex][this.KEY_TASK_PROGRESS] = 0;
            if(isDumpTask == false)
            {
               featureData[KEY_SAVED_ACTIVE_TASKS][slotIndex][this.KEY_DUMPED_STATUS] = 0;
            }
            featureData[KEY_SAVED_ACTIVE_TASKS][slotIndex]["help"] = 0;
            setFeatureData(featureData);
         }
      }
      
      public function canAskForTaskHelp(slotIndex:int) : Boolean
      {
         var result:Boolean = true;
         var fo:Object = this.getFeatureData();
         if(fo[KEY_SAVED_ACTIVE_TASKS][slotIndex]["help"] == 1 || this.getTimeRemainingToAskTaskHelp() > 0)
         {
            result = false;
         }
         return result;
      }
      
      public function getTimeRemainingToAskTaskHelp() : int
      {
         var key:String = m_featureName + LAST_ASK_HELP_TIME_KEY;
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         var timeRemaining:int = ASK_HELP_TIME_INTERVAL - timeSinceLastFeed;
         return timeRemaining > 0 ? timeRemaining : 0;
      }
      
      public function askForTaskHelp(slotIndex:int) : void
      {
         var message:String = null;
         if(this.m_waitingDialog == null)
         {
            if(this.m_guildEventMainWindow)
            {
               this.m_guildEventMainWindow.tintWindow();
               this.m_guildEventMainWindow.enableInput = false;
               message = "Putting your task up for Help.";
               this.m_waitingDialog = UI.displayMessage(message,GenericPopup.TYPE_MODAL,null,"",true);
            }
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"askForTaskHelp",this.onAskForTaskHelp,[m_featureName,slotIndex]),true);
         FarmStatsManager.count(featureXML.child("coop_feature_v3"),"HelpNeeded",slotIndex.toString(),GuildManager.getInstance().getGuildId());
      }
      
      public function onAskForTaskHelp(result:Object) : void
      {
         var key:String = null;
         var fo:Object = null;
         var message:String = null;
         if(this.m_waitingDialog)
         {
            this.m_waitingDialog.close();
            this.m_waitingDialog = null;
         }
         if(Boolean(result) && Boolean(result.hasOwnProperty("status")) && result["status"] != "fail")
         {
            key = m_featureName + LAST_ASK_HELP_TIME_KEY;
            Global.player.setFeatureLastShown(key,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
            fo = this.getFeatureData();
            fo[KEY_SAVED_ACTIVE_TASKS][result["slotIndex"]]["help"] = 1;
            setFeatureData(fo);
            if(this.m_guildEventMainWindow)
            {
               this.m_guildEventMainWindow.refreshTaskFrame();
            }
         }
         else
         {
            message = "Oops! There was a network error. Please try putting your task up for Help again.";
            UI.displayMessage(message,GenericPopup.TYPE_OK,null,"",true);
         }
         if(this.m_guildEventMainWindow)
         {
            this.m_guildEventMainWindow.untintWindow();
            this.m_guildEventMainWindow.enableInput = true;
            this.m_guildEventMainWindow.refreshTaskFrame();
         }
      }
      
      public function selectHelpTask(helpTaskIndex:int) : void
      {
         if(this.m_guildEventMainWindow)
         {
            this.m_guildEventMainWindow.tintWindow();
            this.m_guildEventMainWindow.enableInput = false;
         }
         var message:String = "Picking up a clan member’s task to Help.";
         this.m_waitingDialog = UI.displayMessage(message,GenericPopup.TYPE_MODAL,null,"",true);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"selectHelpTask",this.onSelectHelpTask,[m_featureName,helpTaskIndex]),true);
         FarmStatsManager.count(featureXML.child("coop_feature_v3"),"Helped",helpTaskIndex.toString(),GuildManager.getInstance().getGuildId());
      }
      
      public function onSelectHelpTask(result:Object) : void
      {
         var fo:Object = null;
         var index:int = 0;
         var message:String = null;
         if(this.m_guildEventMainWindow)
         {
            this.m_guildEventMainWindow.untintWindow();
            this.m_guildEventMainWindow.enableInput = true;
         }
         if(this.m_waitingDialog)
         {
            this.m_waitingDialog.close();
            this.m_waitingDialog = null;
         }
         if(Boolean(result) && Boolean(result[this.GUILD_SAME_TYPE_ORDER_ALREADY_PRESENT]))
         {
            this.openGuildMessageWindow("You have already selected a similar task another one of your  slots. Please select a different task for Help slot.",this.onGetHelpOrders);
         }
         else if(Boolean(result) && Boolean(result.hasOwnProperty("status")) && result["status"] != "fail")
         {
            fo = this.getFeatureData();
            if(fo)
            {
               index = 3;
               fo[KEY_SAVED_ACTIVE_TASKS][index] = result[KEY_SELECTED_HELP_TASK_DATA];
               fo[KEY_SAVED_ACTIVE_TASKS][index][this.KEY_TASK_PROGRESS] = 0;
               fo[KEY_HELPING_TASK_STATUS] = 1;
               setFeatureData(fo);
               if(this.m_guildEventMainWindow)
               {
                  this.m_guildEventMainWindow.refreshHelpTaskFrame();
               }
            }
         }
         else
         {
            message = "Sorry! Another member of your clan is already helping with this task. Please select another task to Help.";
            this.openGuildMessageWindow(message);
         }
      }
      
      public function getHelpTaskCount() : int
      {
         var count:int = 0;
         var fo:Array = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILD_HELP_ORDER_DATA) as Array;
         if(fo)
         {
            count = int(fo.length);
         }
         return count;
      }
      
      public function getHelpTaskList() : Vector.<FarmTask>
      {
         var taskType:String = null;
         var taskId:int = 0;
         var taskXML:XML = null;
         var farmTask:FarmTask = null;
         var taskObj:Object = null;
         var index:int = 0;
         var taskList:Vector.<FarmTask> = new Vector.<FarmTask>();
         var helpData:Array = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILD_HELP_ORDER_DATA) as Array;
         if(helpData)
         {
            for(index = 0; index < helpData.length; index++)
            {
               taskType = helpData[index][this.KEY_TASK_TYPE];
               taskId = int(helpData[index][this.KEY_TASK_ID]);
               taskXML = this.m_tasksByTypes[taskType][taskId];
               taskObj = FarmGameUtil.xmlNodeToAttributes(taskXML);
               taskObj.questName = m_featureName;
               taskObj.taskIndex = index;
               taskObj[PLAYER_DATA] = helpData[index][PLAYER_DATA];
               taskObj[KEY_HELP_TASK_INDEX] = helpData[index][KEY_HELP_TASK_INDEX];
               farmTask = new FarmTask(taskObj);
               if(Boolean(helpData[index]["playerId"]) && helpData[index]["playerId"] != GuildManager.getInstance().getZId())
               {
                  taskList.push(farmTask);
               }
            }
         }
         return taskList;
      }
      
      public function getRealHelpCount() : int
      {
         var index:int = 0;
         var taskList:Vector.<FarmTask> = new Vector.<FarmTask>();
         var helpData:Array = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILD_HELP_ORDER_DATA) as Array;
         var count:int = 0;
         if(helpData)
         {
            for(index = 0; index < helpData.length; index++)
            {
               if(Boolean(helpData[index]["playerId"]) && helpData[index]["playerId"] != GuildManager.getInstance().getZId())
               {
                  count++;
               }
            }
         }
         return count;
      }
      
      public function isHelpTaskSelected() : Boolean
      {
         var result:Boolean = false;
         var fo:Object = this.getFeatureData();
         if(Boolean(fo) && fo.hasOwnProperty(KEY_HELPING_TASK_STATUS))
         {
            if(fo[KEY_HELPING_TASK_STATUS] == 1)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function getActiveHelpTask() : FarmTask
      {
         var helpTaskData:Object = null;
         var taskType:String = null;
         var taskId:int = 0;
         var taskXML:XML = null;
         var taskObj:Object = null;
         var helpFarmTask:FarmTask = null;
         var fo:Object = this.getFeatureData();
         if(fo.hasOwnProperty(KEY_SAVED_ACTIVE_TASKS))
         {
            helpTaskData = fo[KEY_SAVED_ACTIVE_TASKS][3];
            taskType = helpTaskData[this.KEY_TASK_TYPE];
            taskId = int(helpTaskData[this.KEY_TASK_ID]);
            taskXML = this.m_tasksByTypes[taskType][taskId];
            taskObj = FarmGameUtil.xmlNodeToAttributes(taskXML);
            taskObj.questName = m_featureName;
            taskObj.taskIndex = 3;
            taskObj["playerId"] = helpTaskData["playerId"];
            taskObj[KEY_HELP_TASK_INDEX] = helpTaskData[KEY_HELP_TASK_INDEX];
            helpFarmTask = new FarmTask(taskObj);
         }
         return helpFarmTask;
      }
      
      public function getActiveHelpTaskObject() : Object
      {
         var progress:int = 0;
         var completedTask:Boolean = false;
         var result:Object = null;
         var data:FarmTask = this.getActiveHelpTask();
         if(data)
         {
            progress = GuildEventManager.getInstance(m_featureName).getHelpTaskProgress();
            completedTask = GuildEventManager.getInstance().isTaskRedeemable(3);
            result = {
               "questTaskSlotNumber":3,
               "questTask":data,
               "questType":data.action,
               "questText":data.titleText,
               "helperText":data.helperText,
               "taskType":data.helperType,
               "skipCashValue":data.skipCashValue,
               "extraData":data.extraData,
               "progress":progress,
               "completed":completedTask
            };
         }
         return result;
      }
      
      public function getHelpTaskProgress() : int
      {
         var progress:int = 0;
         var helpTask:FarmTask = this.getActiveHelpTask();
         var featureData:Object = this.getFeatureData();
         switch(helpTask.action)
         {
            case "sinkBushel":
               progress = CraftingManager.getInstance().getBushelQuantityInInventory(helpTask.type);
               break;
            case "worldScore":
               progress = Global.player.getWorldScore(helpTask.type);
               break;
            default:
               progress = int(featureData[KEY_SAVED_ACTIVE_TASKS][3][this.KEY_TASK_PROGRESS]);
         }
         return progress;
      }
      
      public function getNoOfTasksDone() : int
      {
         var featureData:Object = this.getFeatureData();
         var result:int = 0;
         if(Boolean(featureData) && featureData.hasOwnProperty(KEY_TASK_COMPLETED))
         {
            result = int(featureData[KEY_TASK_COMPLETED]);
         }
         return result;
      }
      
      public function getUserPoints() : int
      {
         var points:int = 0;
         var featureData:Object = this.getFeatureData();
         if(featureData.hasOwnProperty(KEY_OB_POINTS))
         {
            points = int(featureData[KEY_OB_POINTS]);
         }
         return points;
      }
      
      public function getHelpedTaskCount() : int
      {
         var count:int = 0;
         var featureData:Object = this.getFeatureData();
         if(featureData.hasOwnProperty(HELPED_TASK_COUNT))
         {
            count = int(featureData[HELPED_TASK_COUNT]);
         }
         return count;
      }
      
      public function getGuildPoints() : int
      {
         return int(FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILD_OB_POINTS));
      }
      
      public function saveGuildPoints(points:int = 0) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILD_OB_POINTS,points);
         if(this.m_guildEventMainWindow)
         {
            this.m_guildEventMainWindow.updateGuildPoints();
            this.m_guildEventMainWindow.updateMiniSagaMap();
            this.m_guildEventMainWindow.updateGuildBackground();
         }
      }
      
      public function saveGuildCurrentTier(tier:int = 0) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILD_CURRENT_TIER,tier);
         if(this.m_guildEventMainWindow)
         {
            this.m_guildEventMainWindow.updateMiniSagaMap();
            this.m_guildEventMainWindow.updateGuildBackground();
         }
      }
      
      public function saveGuildMilestoneLevel(level:int = 0) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TEMP_FO_GUILD_MILESTONE_LEVEL,level);
         this.grantAllPendingRewards();
      }
      
      public function getCurrentTier() : int
      {
         var result:int = 0;
         return int(FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILD_CURRENT_TIER));
      }
      
      public function getGuildMilestoneLevel() : int
      {
         var result:int = 0;
         return int(FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,TEMP_FO_GUILD_MILESTONE_LEVEL));
      }
      
      public function isHelpAskedForTask(slotIndex:int) : Boolean
      {
         var result:Boolean = false;
         var fo:Object = this.getFeatureData();
         if(Boolean(fo) && Boolean(fo[KEY_SAVED_ACTIVE_TASKS][slotIndex]["help"]) && fo[KEY_SAVED_ACTIVE_TASKS][slotIndex]["help"] == 1)
         {
            result = true;
         }
         return result;
      }
      
      public function hasGrantedBuildingRewardForPreviousTier() : Boolean
      {
         var result:Boolean = false;
         var userRewardLevel:int = this.getUserGrantedRewardLevel();
         var previousTier:int = userRewardLevel / 3;
         var buildingName:String = rewardBuildingNameArray[previousTier];
         var fo:Object = this.getFeatureData();
         if(fo.hasOwnProperty(buildingName) && fo[buildingName][GRANT_STATUS] == GRANTED)
         {
            result = true;
         }
         return result;
      }
      
      public function grantedBuildingRewardForPreviousTier() : void
      {
         var userRewardLevel:int = this.getUserGrantedRewardLevel();
         var previousTier:int = userRewardLevel / 3;
         var buildingName:String = rewardBuildingNameArray[previousTier - 1];
         var buildingRewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(buildingName);
         Global.player.addGift(buildingName);
         var fo:Object = this.getFeatureData();
         if(!fo.hasOwnProperty(buildingName))
         {
            fo[buildingName] = {};
         }
         fo[buildingName][GRANT_STATUS] = GRANTED;
         setFeatureData(fo);
         this.m_guildEventBuildingRewardWindow = new GuildEventBuildingGrantWindow(m_featureName,featureXML.child("guildEventBuildingRewardWindow"),buildingRewardItem,previousTier);
         UI.displayPopup(this.m_guildEventBuildingRewardWindow,false);
      }
      
      public function showElderWindow() : void
      {
         this.m_guildElderWindow = new GuildEventElderWindow(m_featureName,featureXML.child("guildElderWindow"),{});
         UI.displayPopup(this.m_guildElderWindow,false);
      }
      
      public function shouldShowElderWindow() : Boolean
      {
         return false;
      }
      
      public function isBonusBuildingReadyToHarvest(buildingName:String) : Boolean
      {
         var result:Boolean = false;
         if(this.getTimeLeftForBonusHarvest(buildingName) <= 0)
         {
            result = true;
         }
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName(featureXML.child("guildEeventv3BonusEnabled"));
         if(!PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            result = false;
         }
         return result;
      }
      
      public function isBonusHarvestExpired() : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber(featureXML.child("bonusHarvestEndTime")) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         timeLeft = endTime - now;
         if(timeLeft <= 0)
         {
            result = true;
         }
         return result;
      }
      
      public function harvestBonusBuilding(buildingName:String) : void
      {
         var count:int = 0;
         var key:String = buildingName + LAST_BONUS_HARVEST_TIME_KEY;
         Global.player.setFeatureLastShown(key,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         var harvestRewardName:String = this.getNextHarvestItemName(buildingName);
         var harvestFarmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(harvestRewardName);
         if(harvestFarmItem)
         {
            count = 1;
            Global.player.addGift(harvestRewardName,"",count);
            FarmStatsManager.count(featureXML.child("coop_feature_v3"),"harvest_bonus",buildingName,harvestRewardName,GuildManager.getInstance().getGuildId());
            UI.displayPopup(new GuildEventPostHarvestRewardWindow(featureName,featureXML.child("guildEventPostHarvestRewardWindow"),harvestFarmItem));
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,SERVICE_FUNC_HARVEST_BONUS,null,[m_featureName,buildingName]),true);
         }
      }
      
      private function getNextHarvestItemName(buildingName:String) : String
      {
         var couponName:String = null;
         var bonusCount:int = 0;
         var featureData:Object = this.getFeatureData();
         var featureBonusData:Object = featureData[buildingName];
         if(!featureBonusData)
         {
            featureBonusData = {};
         }
         if(featureBonusData.hasOwnProperty(BONUS_HARVEST_COUNT))
         {
            bonusCount = featureBonusData[BONUS_HARVEST_COUNT] as int;
         }
         else
         {
            featureBonusData[BONUS_HARVEST_COUNT] = 0;
            bonusCount = 0;
         }
         var consumableRotationCount:int = int(BONUS_COUNT_MAP[buildingName]);
         couponName = this.BONUS_HARVEST_ARRAY[bonusCount % consumableRotationCount];
         featureBonusData[BONUS_HARVEST_COUNT] = bonusCount + 1;
         featureData[buildingName] = featureBonusData;
         setFeatureData(featureData);
         return couponName;
      }
      
      public function getTimeLeftForBonusHarvest(buildingName:String) : int
      {
         var timeLeft:int = 0;
         var key:String = buildingName + LAST_BONUS_HARVEST_TIME_KEY;
         var throttleTime:int = DEFAULT_HARVEST_THROTTLE_TIME;
         return this.getTimeLeft(key,throttleTime);
      }
      
      public function getTimeLeft(key:String, throttleTime:int = 86400) : int
      {
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         return int(throttleTime - timeSinceLastFeed);
      }
      
      public function markFeatureAsCompleted() : void
      {
         if(!Global.player.getSeenFlag(m_featureName + "_Completed"))
         {
            GuildManager.getInstance().setHudNotifText("Event completed!");
         }
         Global.player.setSeenFlag(m_featureName + "_Completed");
      }
      
      public function hasCompletedCurrentEvent() : Boolean
      {
         var result:Boolean = false;
         if(Global.player.getSeenFlag(m_featureName + "_Completed"))
         {
            result = true;
         }
         return result;
      }
      
      public function getExpansionName(taskAction:String, taskType:String) : String
      {
         var itemData:FarmItem = null;
         var cropItem:FarmItem = null;
         var worldName:String = null;
         var expansionName:String = null;
         if(taskAction == QuestConstants.TASK_HARVEST_BY_CATEGORY)
         {
            if(taskType == featureXML.child("taskTypes").child("trees").child("tree1") || taskType == featureXML.child("taskTypes").child("animals").child("animal1"))
            {
               worldName = featureXML.child("worldNames").child("worldName1");
            }
            else if(taskType == featureXML.child("taskTypes").child("trees").child("tree2") || taskType == featureXML.child("taskTypes").child("animals").child("animal2"))
            {
               worldName = featureXML.child("worldNames").child("worldName2");
            }
         }
         else if(taskAction == QuestConstants.TASK_MAKE_RECIPE_BY_CODE)
         {
            itemData = Global.farmGameSettingsManager.getFarmItemByCode(taskType);
            worldName = Global.worldSettingsManager.getWorldNameByMarketCard(itemData.marketCardName);
         }
         else if(taskAction == QuestConstants.TASK_SINK_BUSHEL)
         {
            itemData = Global.farmGameSettingsManager.getFarmItemByCode(taskType);
            cropItem = Global.farmGameSettingsManager.getFarmItemByCode(itemData.crop);
            worldName = cropItem.worldRestrictions[0];
         }
         else if(taskAction == QuestConstants.TASK_WORLD_SCORE)
         {
            if(taskType == featureXML.child("taskTypes").child("points").child("point1"))
            {
               worldName = featureXML.child("worldNames").child("worldName1");
            }
            else if(taskType == featureXML.child("taskTypes").child("points").child("point2"))
            {
               worldName = featureXML.child("worldNames").child("worldName2");
            }
         }
         else
         {
            itemData = Global.farmGameSettingsManager.getFarmItemByCode(taskType);
            worldName = itemData.worldRestrictions[0];
         }
         if(worldName == featureXML.child("worldNames").child("worldName1"))
         {
            expansionName = featureXML.child("expansionNames").child("expansionName1");
         }
         else if(worldName == featureXML.child("worldNames").child("worldName2"))
         {
            expansionName = featureXML.child("expansionNames").child("expansionName2");
         }
         return expansionName;
      }
      
      public function shouldTravelTask(taskAction:String) : Boolean
      {
         var result:Boolean = false;
         if(taskAction == QuestConstants.TASK_SINK_BUSHEL || taskAction == QuestConstants.TASK_MAKE_RECIPE_BY_CODE || taskAction == QuestConstants.TASK_HARVEST_BY_CODE || taskAction == QuestConstants.TASK_HARVEST_BY_CATEGORY)
         {
            result = true;
         }
         return result;
      }
      
      public function getGuildEventName() : String
      {
         return GUILD_EVENT_NAME;
      }
   }
}

