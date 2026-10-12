package Managers.OrderBoard
{
   import Classes.Constants.ArrowType;
   import Classes.Constants.PrerequisiteConstants;
   import Classes.Constants.QuestConstants;
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureBuilding;
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Classes.Mastery;
   import Classes.MatchMaking.MatchMakingManager;
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.HUD.HUD;
   import Display.QueuedIcons.FeatureQueuedIcon;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Events.TileUnlockEvent;
   import Managers.BaseFeatureManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureCraftingManager;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.FeatureOptionsManager;
   import Managers.ItemFinderManager;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FeaturePackagesBuyWindow;
   import Widgets.Windows.HalloweenInnovationAddNeighborWindow;
   import Widgets.Windows.HalloweenInnovationBonusGrantWindow;
   import Widgets.Windows.HalloweenInnovationPostGameWindow;
   import Widgets.Windows.HalloweenInnovationPostHarvestWindow;
   import Widgets.Windows.HalloweenInnovationPostRedeemWindow;
   import Widgets.Windows.HalloweenUSAInnovationBonusInfoWindow;
   import Widgets.Windows.HalloweenUSAInnovationGameWindow;
   import Widgets.Windows.HalloweenUSAInnovationMainWindow;
   import Widgets.Windows.HalloweenUSAInnovationTierUnlock;
   import Widgets.Windows.HalloweenUSAInnovationTileUnlockWindow;
   import Widgets.Windows.HalloweenUSARedeemWindow;
   import flash.events.DataEvent;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class HalloweenInnovationManager extends BaseFeatureManager
   {
      
      private static const FEATURE_NAME:String = "HalloweenUSAInnovation";
      
      private static const WINDOW_MAIN:String = "main";
      
      private static const WINDOW_REDEEM:String = "redeem";
      
      private static const WINDOW_BUYDIALOG:String = "buyDialog";
      
      private static const WINDOW_GAME:String = "game";
      
      private static const WINDOW_PRIZE:String = "prize";
      
      private static const WINDOW_NEIGHBOR:String = "neighbor";
      
      private static const SERVICE_CLASS:String = "HalloweenUSAInnovationService";
      
      private static const EVENT_HU_INNOVATION_TILE_UNLOCK:String = "HUInnovationTileUnlock";
      
      private static const SERVICE_FUNC_RESET_COLLECT_TIMER:String = "resetCollectConsumablesTimer";
      
      private static const SERVICE_FUNC_BONUS_COLLECT:String = "collectBonus";
      
      private static const SERVICE_FUNC_REDEEM_ITEM:String = "redeemCouponItem";
      
      public static const HALLOWEEN_COLLECT_CONSUMABLE_KEY:String = "halloweenconsumablekey";
      
      private static const WINCOUNT_FO_KEY:String = "0";
      
      private static const REDEEM_FO_KEY:String = "1";
      
      private static const LAST_BONUS_HARVEST_TIME_KEY:String = "xha_bht";
      
      private static const SERVICE_FUNC_HARVEST_BONUS:String = "harvestBonusBuilding";
      
      private static const SERVICE_FUNC_DEDUCT_CONSUMABLE:String = "deductConsumableForGame";
      
      private static const FEATURE_OPTIONS_BONUS_CLAIMED_KEY:String = "BonusClaimed";
      
      private static const DEFAULT_STARTGAME_WAITING_PERIOD:Number = 4000;
      
      private static const BONUS_HARVEST_COUNT:String = "hc";
      
      public static const DEFAULT_HARVEST_THROTTLE_TIME:Number = 86400;
      
      public static const DEFAULT_COLLECT_THROTTLE_TIME:Number = 86400;
      
      public static const FEED_NAME:String = "FeatureUI";
      
      private static const HALLOWEEN_INNOVATION_BONUSVALUE:String = "HALLOWEEN_INNOVATION_BONUSVALUE";
      
      private static const HALLOWEEN_INNOVATION_PPP_ATTEMPTS_COUNT:String = "HALLOWEEN_INNOVATION_PPP_ATTEMPTS_COUNT";
      
      private static const HALLOWEEN_INNOVATION_MATCH_WAIT_TIME:String = "HALLOWEEN_INNOVATION_MATCH_WAIT_TIME";
      
      private static var m_initialized:Boolean = false;
      
      private static const SERVICE_FUNC_DEACTIATE_GAMEMODE:String = "deActivateGameMode";
      
      public const FEATURE_OPTIONS_KEY:String = "HalloweenUSAInnovation";
      
      public const DEFAULT_WAITING_PERIOD:Number = 14;
      
      public const PLAYER_RESPONSE_PERIOD:int = 7;
      
      private var m_mainWindow:HalloweenUSAInnovationMainWindow;
      
      private var m_tierEnabledFlag:Array;
      
      private var m_tierRewardsEnabledFlag:Array;
      
      private var m_featureConfigData:Object;
      
      private var m_isDisabledByRuntime:Boolean = false;
      
      private var m_isRuntimeLoaded:Boolean = false;
      
      private var m_GameWindow:HalloweenUSAInnovationGameWindow;
      
      protected var m_staticData:Object;
      
      private var m_assetPaths:Object = null;
      
      private var m_timer:Timer;
      
      private var m_currentTimeCount:Number = 0;
      
      private var m_matchTimer:Timer;
      
      private var m_timerRetries:int = 0;
      
      private var _m_selectedItemCodeForGame:String;
      
      private var m_disabledTiers:Dictionary = new Dictionary();
      
      private var m_player2UID:String;
      
      private var m_gameId:String;
      
      private var m_startGameTimer:Timer;
      
      private var m_matchFailed:Boolean = false;
      
      private var m_CurrentcouponName:String = "";
      
      private var BONUS_HARVEST_ARRAY:Array = ["consume_xha_animal_redeem","consume_xha_tree_redeem","consume_xha_deco_redeem","consume_xha_building_redeem"];
      
      private var m_currentTasksTierIndex:int = 1;
      
      private var m_taskCount:Array = [0,10,12,12];
      
      public const COLLECT_TUTORIAL_FLAG:String = "HalloweenUSAInnovation_collect_tutorial";
      
      private var m_bonusInfoWindow:HalloweenUSAInnovationBonusInfoWindow;
      
      private const KEY_ONE_TIME_GRANT:String = "rps_bonus";
      
      public function HalloweenInnovationManager(featureName:String)
      {
         super(featureName);
         this.m_featureConfigData = new Object();
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
      }
      
      public static function getInstance(featureName:String = "HalloweenUSAInnovation") : HalloweenInnovationManager
      {
         return getInstanceOfClass(featureName,HalloweenInnovationManager) as HalloweenInnovationManager;
      }
      
      public function openBuyWindow(owner:FarmWindow) : void
      {
         UI.displayPopup(new FeaturePackagesBuyWindow("assets/dialogs/halloweenusa/innovation/FV_xha_Innovation_Buy.swf",m_featureName,this.getBucketPackages(),owner),false);
      }
      
      public function initialize() : void
      {
         this.loadStaticData();
         this.setupTasks();
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.FEATURE_OPTIONS_KEY,m_featureName);
         if(!featureData)
         {
            featureData = new Object();
            featureData["rewards"] = new Object();
            featureData["tiers"] = new Object();
            featureData["currentTasksTierIndex"] = 1;
            featureData["1kgy"] = 0;
            FeatureOptionsManager.getInstance().setFeatureOption(this.FEATURE_OPTIONS_KEY,m_featureName,featureData);
         }
         this.updateCurrentTier();
      }
      
      private function loadStaticData() : void
      {
         var itemXML:XML = null;
         var division:XML = null;
         var tier:XML = null;
         var tile:XML = null;
         var asset:XML = null;
         var item:XML = null;
         var tierNumber:int = 0;
         var item2:XML = null;
         var itemCode:String = null;
         var tileName:String = null;
         this.m_staticData = new Object();
         this.m_staticData.bucketPackages = new Array();
         this.m_staticData.rewardsTierArray = new Array();
         this.m_staticData.endDate = "";
         this.m_staticData.tricktreats = "";
         this.m_staticData.gameCost = 0;
         this.m_staticData.p2pTurnCount = 0;
         this.m_staticData.soloTurnCount = 0;
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         if(featureXML != null)
         {
            m_initialized = true;
            this.m_assetPaths = new Object();
            if(featureXML.assets != "")
            {
               for each(asset in featureXML.assets.asset)
               {
                  this.m_assetPaths[asset.@name] = asset.@path.toString();
               }
            }
            this.m_staticData.tricktreats = featureXML.bucketItem.@code.toString();
            for each(itemXML in featureXML.bucketPackages.bucketPackage)
            {
               this.m_staticData.bucketPackages.push(itemXML.@name.toString());
            }
            for each(division in featureXML.divisions.division)
            {
               if(division.@name == "tuningData")
               {
                  for each(item in division.items.item)
                  {
                     if(item.@name.toString() == "game_cost")
                     {
                        this.m_staticData.gameCost = item.@count.toString();
                     }
                     else if(item.@name.toString() == "solo_turn_count")
                     {
                        this.m_staticData.soloTurnCount = item.@count.toString();
                     }
                     else if(item.@name.toString() == "p2p_turn_count")
                     {
                        this.m_staticData.p2pTurnCount = item.@count.toString();
                     }
                  }
               }
            }
            for each(tier in featureXML.divisions.division)
            {
               if(tier.@name != "tuningData")
               {
                  tierNumber = int(tier.@level);
                  this.m_staticData.rewardsTierArray[tierNumber] = new Array();
                  for each(item2 in tier.items.item)
                  {
                     itemCode = item2.@code.toString();
                     this.m_staticData.rewardsTierArray[tierNumber].push({
                        "code":itemCode,
                        "required":item2.@count.toString()
                     });
                  }
               }
            }
            this.m_staticData.tilesArray = new Array();
            for each(tile in featureXML.items.item)
            {
               tileName = tile.@name.toString();
               this.m_staticData.tilesArray.push(tileName);
            }
         }
      }
      
      public function get mainWindowURL() : String
      {
         return this.m_assetPaths[WINDOW_MAIN];
      }
      
      public function get addNeighborWindowURL() : String
      {
         return this.m_assetPaths[WINDOW_NEIGHBOR];
      }
      
      public function get tierUnlockWindowURL() : String
      {
         return "assets/dialogs/halloweenusa/innovation/FV_xha_Innovation_TierUnlock.swf";
      }
      
      public function get buyDialogURL() : String
      {
         return this.m_assetPaths[WINDOW_BUYDIALOG];
      }
      
      public function get gamePlayDialogURL() : String
      {
         return this.m_assetPaths[WINDOW_GAME];
      }
      
      public function get redeemDialogURL() : String
      {
         return this.m_assetPaths[WINDOW_REDEEM];
      }
      
      public function get congratsDialogURL() : String
      {
         return this.m_assetPaths[WINDOW_PRIZE];
      }
      
      public function getBucketPackages() : Array
      {
         return this.m_staticData.bucketPackages;
      }
      
      public function get ConsumableCode() : String
      {
         return this.m_staticData.tricktreats;
      }
      
      public function get consumableCount() : Number
      {
         return int(FeatureOptionsInventoryManager.getInstance().getCount(this.ConsumableCode));
      }
      
      public function getTimeLeft(key:String, throttleTime:int = 86400) : int
      {
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         return int(throttleTime - timeSinceLastFeed);
      }
      
      public function canUserStartPlaying() : Boolean
      {
         var canStart:Boolean = false;
         var trickytreatsCount:Number = FeatureOptionsInventoryManager.getInstance().getCount(this.ConsumableCode);
         if(trickytreatsCount >= this.gameCost)
         {
            canStart = true;
         }
         if(!this.m_isRuntimeLoaded)
         {
            canStart = false;
         }
         return canStart;
      }
      
      private function onaskForRunes(e:Object) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.refreshAskButton();
         }
      }
      
      public function askForConsumable(event:Event = null) : void
      {
         getFeedData(FEED_NAME).postFeed(this.onaskForRunes);
      }
      
      public function get gameWindow() : HalloweenUSAInnovationGameWindow
      {
         return this.m_GameWindow;
      }
      
      public function get mainWindow() : HalloweenUSAInnovationMainWindow
      {
         return this.m_mainWindow;
      }
      
      public function set mainWindow(window:HalloweenUSAInnovationMainWindow) : void
      {
         this.m_mainWindow = window;
      }
      
      public function get gameCost() : Number
      {
         return this.m_staticData.gameCost;
      }
      
      public function get turnsInGame() : Number
      {
         return this.m_staticData.p2pTurnCount;
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
      
      public function highlightTiles() : void
      {
         ItemFinderManager.getInstance().highlightMultipleWorldItems(this.lockedTilesArray);
      }
      
      public function openGameTutorial() : void
      {
         UI.displayPopup(new HalloweenUSAInnovationGameWindow(m_featureName,this.gamePlayDialogURL,true),false);
      }
      
      public function getFeatureEndDaysLeftText() : String
      {
         var endTimeText:String = null;
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var requirement:Object = null;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("halloweenusa_feature_enabled");
         var requirementsArray:Array = prereq[FarmGameSettingsManager.XML_CHILDREN_FIELD];
         for each(requirement in requirementsArray)
         {
            if(requirement.type == PrerequisiteConstants.PREREQUISITE_END_TIME)
            {
               endTimeText = requirement.value;
               break;
            }
         }
         endTime = FarmGameUtil.synchronizedDateTimeToNumber(endTimeText);
         timeLeft = (endTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return HUD.getformattedTimeLeft(timeLeft);
      }
      
      public function showMainUI(showEATutorialPage:Boolean = false) : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         FarmStatsManager.count("RockPaperShivers","Main_UI","open_window");
         this.m_mainWindow = new HalloweenUSAInnovationMainWindow(m_featureName,this.mainWindowURL,showEATutorialPage);
         UI.displayPopup(this.m_mainWindow);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"isGameDisabled",this.onReceiveRuntimeVar),true);
      }
      
      public function onReceiveRuntimeVar(result:Object) : void
      {
         this.m_isRuntimeLoaded = true;
         if(result)
         {
            this.m_isDisabledByRuntime = result.isDisabled as Boolean;
            if(Boolean(this.mainWindow) && this.mainWindow.isLoaded())
            {
               this.mainWindow.refreshWindow();
            }
         }
      }
      
      public function closeMainUI() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
      }
      
      public function initializeGameWindow(itemCode:String) : void
      {
         var message:String = null;
         if(this.mainWindow)
         {
            this.mainWindow.close();
         }
         if(MatchMakingManager.getInstance().isConnected())
         {
            if(this.m_isDisabledByRuntime)
            {
               message = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"AFInnovation" + "_disabledMessage");
               UI.displayMessage(message,GenericPopup.TYPE_OK,null,"AfInnovationDisabledMsg",true);
               FarmStatsManager.count("RockPaperShivers","Main_UI","find_game_disabled");
            }
            else
            {
               this.openGameWindow();
               this.startConnectionTimer();
               this._m_selectedItemCodeForGame = itemCode;
               MatchMakingManager.getInstance().getMatchFromActivePool(this.onActiveMatchSuccess,this.onActiveMatchFirstFailure);
            }
         }
         else
         {
            message = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"zoomErrorMessage");
            UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,this.closeCallback,"",true);
         }
      }
      
      public function openGameWindow() : void
      {
         UI.displayPopup(this.m_GameWindow = new HalloweenUSAInnovationGameWindow(m_featureName,this.gamePlayDialogURL),false);
         FarmStatsManager.count("RockPaperShivers","game_window","open","impression");
      }
      
      private function closeCallback(e:GenericPopupEvent) : void
      {
         if(e.button == GenericPopup.ACCEPT)
         {
            FarmGameUtil.redirectHomeNoError();
         }
      }
      
      public function isTierEnabled(tierNumber:int) : Boolean
      {
         return this.m_tierEnabledFlag[tierNumber];
      }
      
      public function isTierRewardsEnabled(tierNumber:int) : Boolean
      {
         return this.m_tierRewardsEnabledFlag[tierNumber];
      }
      
      public function canCollectConsumables() : Boolean
      {
         var canCollect:Boolean = true;
         var key:String = HALLOWEEN_COLLECT_CONSUMABLE_KEY;
         if(this.getTimeLeft(key,DEFAULT_COLLECT_THROTTLE_TIME) > 0)
         {
            canCollect = false;
         }
         return canCollect;
      }
      
      public function resetCollectConsumableTimer(tileName:String) : void
      {
         var featureData:Object = this.getFeatureOption();
         var key:String = HALLOWEEN_COLLECT_CONSUMABLE_KEY;
         var tilesArray:Array = this.TilesArray as Array;
         if(tilesArray.indexOf(tileName) >= 0)
         {
            featureData["tiles"][tileName] = 1;
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,FEATURE_NAME,featureData);
            Global.player.setFeatureLastShown(key,(GlobalEngine.serverTime - FarmGameUtil.NUM_MSECS_IN_DAY) / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,SERVICE_FUNC_RESET_COLLECT_TIMER,null,[m_featureName,tileName]));
         }
      }
      
      public function collectConsumables() : int
      {
         var tile:String = null;
         var consumableCount:int = this.gameCost;
         for each(tile in this.TilesArray as Array)
         {
            if(this.isTileUnLocked(tile))
            {
               consumableCount++;
            }
         }
         FeatureOptionsInventoryManager.getInstance().addCount(this.ConsumableCode,consumableCount);
         Global.player.setFeatureLastShown(HALLOWEEN_COLLECT_CONSUMABLE_KEY,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"collectConsumables",null,[m_featureName]));
         return consumableCount;
      }
      
      public function get TilesArray() : Array
      {
         return this.m_staticData.tilesArray;
      }
      
      private function setupTasks() : void
      {
         var tier:XML = null;
         var tierNumber:int = 0;
         var task:XML = null;
         var taskStatus:int = 0;
         var taskId:String = null;
         var taskObj:Object = null;
         var ft:FarmTask = null;
         var featureData:Object = this.getFeatureOption();
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         this.m_staticData["tiers"] = new Object();
         for each(tier in featureXML.tiers.tier)
         {
            tierNumber = int(tier.@index.toString());
            this.m_staticData["tiers"][tierNumber] = new Array();
            for each(task in tier.task)
            {
               taskStatus = 0;
               taskId = task.@type.toString() + "_" + task.@level.toString();
               if(featureData.hasOwnProperty("tiers") && Boolean(featureData["tiers"].hasOwnProperty(taskId)))
               {
                  taskStatus = int(featureData["tiers"][taskId]);
               }
               taskObj = FarmGameUtil.xmlNodeToAttributes(task);
               taskObj.questName = m_featureName;
               taskObj.taskIndex = taskId;
               ft = new FarmTask(taskObj);
               this.m_staticData["tiers"][tierNumber].push({
                  "action":task.@action.toString(),
                  "type":task.@type.toString(),
                  "helper":task.@helper.toString(),
                  "taskId":taskId,
                  "status":taskStatus,
                  "tierName":tierNumber,
                  "level":task.@level.toString(),
                  "obj":ft
               });
            }
         }
      }
      
      public function getTasksofTier(tierNumber:int) : Array
      {
         return this.m_staticData["tiers"][tierNumber];
      }
      
      public function getRewardsOfTier(tierNumber:int) : Array
      {
         return this.m_staticData.rewardsTierArray[tierNumber];
      }
      
      private function onActiveMatchSuccess(uid:String, gameId:String) : void
      {
         if(!this.gameWindow.gameStarted)
         {
            FarmStatsManager.count("RockPaperShivers","Matchmaking_Track",uid,"Active",gameId,"",this.m_currentTimeCount);
            MatchMakingManager.getInstance().setUserInactive();
            this.stopConnectionTimer();
            MatchMakingManager.getInstance().removeEventListener(MatchMakingManager.EVENTTYPE_GAMEREQUEST,this.ongameRequestReceived);
            MatchMakingManager.getInstance().removeEventListener(MatchMakingManager.EVENTTYPE_CHAT,this.onchatMessageReceived);
            if(this.m_matchTimer)
            {
               this.m_matchTimer.stop();
            }
            this.m_player2UID = uid;
            this.m_gameId = gameId;
            FarmStatsManager.count("RockPaperShivers","Matchmaking_Track",uid,gameId);
            this.gameWindow.startGame(false,uid,gameId);
            this.deductConsumableForGame();
         }
      }
      
      private function onActiveMatchFirstFailure() : void
      {
         MatchMakingManager.getInstance().setUserActive();
         MatchMakingManager.getInstance().addEventListener(MatchMakingManager.EVENTTYPE_GAMEREQUEST,this.ongameRequestReceived);
         if(this.m_matchTimer != null)
         {
            this.m_matchTimer.stop();
            this.m_matchTimer = null;
         }
         this.m_matchTimer = new Timer(15000);
         this.m_timerRetries = 0;
         this.m_matchTimer.addEventListener(TimerEvent.TIMER,this.onActiveMatchTimerExpired);
         this.m_matchTimer.start();
      }
      
      private function onActiveMatchTimerExpired(event:TimerEvent) : void
      {
         ++this.m_timerRetries;
         if(this.m_timerRetries >= this.getDefaultPPPAttempts())
         {
            this.m_matchTimer.stop();
            MatchMakingManager.getInstance().getMatchFromActivePool(this.onActiveMatchSuccess,this.onActiveMatchFailure);
         }
         else
         {
            MatchMakingManager.getInstance().getMatchFromActivePool(this.onActiveMatchSuccess,null);
         }
      }
      
      private function onchatMessageReceived(e:DataEvent) : void
      {
         if(e.data.indexOf("StartGame:" + this.m_gameId) != -1 && !this.gameWindow.gameStarted)
         {
            if(this.m_matchTimer)
            {
               this.m_matchTimer.stop();
            }
            if(this.m_startGameTimer)
            {
               this.m_startGameTimer.stop();
            }
            MatchMakingManager.getInstance().matchFound = false;
            this.stopConnectionTimer();
            MatchMakingManager.getInstance().setUserInactive();
            MatchMakingManager.getInstance().removeEventListener(MatchMakingManager.EVENTTYPE_GAMEREQUEST,this.ongameRequestReceived);
            MatchMakingManager.getInstance().removeEventListener(MatchMakingManager.EVENTTYPE_CHAT,this.onchatMessageReceived);
            FarmStatsManager.count("RockPaperShivers","Matchmaking_Track",this.m_player2UID,this.m_gameId);
            this.gameWindow.startGame(false,this.m_player2UID,this.m_gameId);
            this.deductConsumableForGame();
         }
      }
      
      private function ongameRequestReceived(e:DataEvent) : void
      {
         var parts:Array = null;
         var uid:String = null;
         var gameId:String = null;
         if(e.data)
         {
            parts = e.data.split(",");
            uid = parts[0];
            gameId = parts[1];
            if(!this.gameWindow.gameStarted)
            {
               MatchMakingManager.getInstance().matchFound = true;
               MatchMakingManager.getInstance().addZoomFriend(uid);
               MatchMakingManager.getInstance().sendMessage("Accepted:" + gameId,uid);
               this.m_gameId = gameId;
               this.m_player2UID = uid;
               MatchMakingManager.getInstance().addEventListener(MatchMakingManager.EVENTTYPE_CHAT,this.onchatMessageReceived);
               if(this.m_matchTimer)
               {
                  this.m_matchTimer.stop();
               }
               this.m_startGameTimer = new Timer(DEFAULT_STARTGAME_WAITING_PERIOD);
               this.m_startGameTimer.addEventListener(TimerEvent.TIMER,this.onStartGameTimerExpired);
               this.m_startGameTimer.start();
            }
            else
            {
               MatchMakingManager.getInstance().removeEventListener(MatchMakingManager.EVENTTYPE_GAMEREQUEST,this.ongameRequestReceived);
               MatchMakingManager.getInstance().sendMessage("Rejected:" + gameId,uid);
            }
         }
      }
      
      private function onStartGameTimerExpired(event:TimerEvent) : void
      {
         this.m_startGameTimer.stop();
         MatchMakingManager.getInstance().matchFound = false;
         if(!this.m_matchFailed)
         {
            if(this.m_matchTimer != null)
            {
               this.m_matchTimer.stop();
               this.m_matchTimer = null;
            }
            this.m_matchTimer = new Timer(5000);
            this.m_timerRetries = 0;
            this.m_matchTimer.addEventListener(TimerEvent.TIMER,this.onActiveMatchTimerExpired);
            this.m_matchTimer.start();
         }
      }
      
      private function onActiveMatchFailure() : void
      {
         if(!this.gameWindow.gameStarted)
         {
            this.m_matchFailed = true;
            this.showConnectionFailMessage();
            FarmStatsManager.count("RockPaperShivers","Matchmaking_Track","match_notfound");
            MatchMakingManager.getInstance().removeEventListener(MatchMakingManager.EVENTTYPE_GAMEREQUEST,this.ongameRequestReceived);
         }
      }
      
      private function onActiveMatchRetryFailure() : void
      {
         MatchMakingManager.getInstance().addEventListener(MatchMakingManager.EVENTTYPE_GAMEREQUEST,this.ongameRequestReceived);
      }
      
      private function startConnectionTimer() : void
      {
         this.m_currentTimeCount = 0;
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         this.refreshConnectionTimerText();
      }
      
      private function refreshConnectionTimerText() : void
      {
         var timerText:String = null;
         if(this.m_currentTimeCount > this.getDefaultWaitingTime())
         {
            this.onP2ConnectionTimerExpired();
         }
         else
         {
            timerText = HUD.getformattedTimeLeft(this.getDefaultWaitingTime() - this.m_currentTimeCount);
            this.gameWindow.setConnectOverlayText(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_FindGameText1"),ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_FindGameText2",{"timer":timerText}));
            this.m_currentTimeCount += 1;
         }
      }
      
      public function onP2ConnectionTimerExpired() : void
      {
         FarmStatsManager.count("RockPaperShivers","Matchmaking_Track","connection_time_expired");
         this.showConnectionFailMessage();
      }
      
      public function showConnectionFailMessage() : void
      {
         this.stopConnectionTimer();
         this.gameWindow.setOverlayText(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_NoGameFoundText1"),ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_NoGameFoundText2"),ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_Okay"),this.startSoloGame);
      }
      
      public function startSoloGame(event:Event) : void
      {
         this.m_player2UID = "";
         FarmStatsManager.count("RockPaperShivers","Matchmaking_Track","game_with_bot");
         this.m_GameWindow.startGame(true);
         this.deductConsumableForGame();
      }
      
      private function stopConnectionTimer() : void
      {
         if(this.m_timer)
         {
            this.m_currentTimeCount = 0;
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
      }
      
      public function getBonusRewardIconUrl() : String
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.bonusRewardCode);
         return item.iconUrl;
      }
      
      public function getFeatureOption() : Object
      {
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,FEATURE_NAME);
         if(!featureData)
         {
            featureData = new Object();
            featureData["rewards"] = new Object();
            featureData["tiers"] = new Object();
            featureData["currentTasksTierIndex"] = 1;
            featureData["consumableCount"] = 0;
            featureData["bonusReward"] = 0;
            featureData["lastCollectTimestamp"] = 0;
            featureData["tiles"] = new Object();
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,FEATURE_NAME,featureData);
         }
         return featureData;
      }
      
      public function updateCurrentTier() : int
      {
         var count:int = 0;
         var taskObj:Object = null;
         var fo:Object = this.getFeatureOption();
         var currentTier:int = int(fo["currentTasksTierIndex"]);
         for(var tierNumber:int = 1; tierNumber < 4; tierNumber++)
         {
            if(tierNumber >= currentTier)
            {
               count = 0;
               for each(taskObj in this.m_staticData["tiers"][tierNumber])
               {
                  if(fo["tiers"].hasOwnProperty(taskObj.taskId))
                  {
                     count++;
                  }
               }
               if(count != this.m_taskCount[tierNumber])
               {
                  break;
               }
               fo["currentTasksTierIndex"] = tierNumber + 1;
            }
         }
         if(currentTier != fo["currentTasksTierIndex"])
         {
            FeatureOptionsManager.getInstance().setFeatureOption(this.FEATURE_OPTIONS_KEY,m_featureName,fo);
         }
         this.m_currentTasksTierIndex = fo["currentTasksTierIndex"];
         return fo["currentTasksTierIndex"];
      }
      
      public function getCurrentTier() : int
      {
         return this.m_currentTasksTierIndex;
      }
      
      public function refreshTab() : void
      {
         var unlockedTierName:String = null;
         var prevTab:int = this.m_currentTasksTierIndex;
         this.updateCurrentTier();
         if(prevTab != this.getCurrentTier() && Boolean(this.m_mainWindow))
         {
            this.m_mainWindow.updateSlots();
            this.m_mainWindow.tintWindow();
            this.mainWindow.enableInput = false;
            unlockedTierName = HalloweenUSAInnovationMainWindow.TAB_NAMES_ARRAY[this.getCurrentTier() - 1];
            FarmStatsManager.count("RockPaperShivers","TierUnlock_window","open_window",unlockedTierName);
            UI.displayPopup(new HalloweenUSAInnovationTierUnlock(this.tierUnlockWindowURL,m_featureName,unlockedTierName),false);
         }
      }
      
      public function isTileUnLocked(tileName:String) : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureOption();
         if(Boolean(featureData) && Boolean(featureData["tiles"].hasOwnProperty(tileName)) && featureData["tiles"][tileName] == 1)
         {
            result = true;
         }
         return result;
      }
      
      public function conditionallyOpenPostGamewindows(e:Event) : void
      {
         if(this.m_GameWindow)
         {
            this.m_GameWindow.close();
         }
         if(this.m_player2UID != "" && this.m_player2UID != null && Global.friendManager.neighborUids.indexOf(this.m_player2UID) == -1)
         {
            this.OpenAddNeighborwindow();
         }
         else
         {
            this.conditionallyShowRewardWindow();
         }
      }
      
      public function OpenAddNeighborwindow() : void
      {
         FarmStatsManager.count("RockPaperShivers","AddNeighbour_window","open_window",this.m_player2UID);
         UI.displayPopup(new HalloweenInnovationAddNeighborWindow(this.addNeighborWindowURL,m_featureName,this.m_player2UID,this.conditionallyShowRewardWindow),false);
      }
      
      public function conditionallyShowRewardWindow(e:Event = null) : void
      {
         var farmItem:FarmItem = null;
         if(Boolean(this._m_selectedItemCodeForGame) && Boolean(this.isRewardRedeemable(this._m_selectedItemCodeForGame)) && this.congratsDialogURL != null)
         {
            this.resetWinCountForReward(this._m_selectedItemCodeForGame);
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(this._m_selectedItemCodeForGame);
            FarmStatsManager.count("RockPaperShivers","reward_congrats_window","open",farmItem.name);
            UI.displayPopup(new HalloweenInnovationPostGameWindow(this.congratsDialogURL,m_featureName,farmItem,this.m_player2UID,null),false);
            this._m_selectedItemCodeForGame = null;
         }
         else
         {
            this.showMainUI();
         }
      }
      
      public function resetWinCountForReward(rewardCode:String) : void
      {
         var featureData:Object = this.getFeatureOption();
         if(Boolean(featureData) && featureData.hasOwnProperty("rewards"))
         {
            if(featureData["rewards"].hasOwnProperty(rewardCode))
            {
               featureData["rewards"][rewardCode][WINCOUNT_FO_KEY] = 0;
            }
         }
      }
      
      public function updateAndGetDisabledTiers() : Dictionary
      {
         var featureData:Object = this.getFeatureOption();
         var activeTier:int = int(featureData["currentTasksTierIndex"]);
         for(var i:int = activeTier + 2; i < 5; i++)
         {
            this.m_disabledTiers[i.toString()] = true;
         }
         return this.m_disabledTiers;
      }
      
      public function updateWinCountForReward() : void
      {
         var winCountForReward:int = 0;
         var rewardItem:FarmItem = null;
         var featureData:Object = this.getFeatureOption();
         if(Boolean(featureData) && featureData.hasOwnProperty("rewards"))
         {
            if(featureData["rewards"].hasOwnProperty(this._m_selectedItemCodeForGame) == false)
            {
               featureData["rewards"][this._m_selectedItemCodeForGame] = new Object();
               featureData["rewards"][this._m_selectedItemCodeForGame][WINCOUNT_FO_KEY] = 0;
            }
            winCountForReward = int(featureData["rewards"][this._m_selectedItemCodeForGame][WINCOUNT_FO_KEY]);
            winCountForReward += 1;
            featureData["rewards"][this._m_selectedItemCodeForGame][WINCOUNT_FO_KEY] = winCountForReward;
            if(featureData["rewards"][this._m_selectedItemCodeForGame][WINCOUNT_FO_KEY] >= this.getWinCountGoalForReward(this._m_selectedItemCodeForGame))
            {
               rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(this._m_selectedItemCodeForGame);
               Global.player.addGift(rewardItem.name);
               featureData["rewards"][this._m_selectedItemCodeForGame][REDEEM_FO_KEY] = 1;
            }
            FeatureOptionsManager.getInstance().setFeatureOption(this.FEATURE_OPTIONS_KEY,m_featureName,featureData);
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"updateWinCountforReward",null,[m_featureName,this._m_selectedItemCodeForGame]));
      }
      
      public function conditionallyOpenBonusRewardWindow() : void
      {
         var bonusRewardItem:FarmItem = null;
         if(this.canGrantBonusReward())
         {
            bonusRewardItem = Global.farmGameSettingsManager.getFarmItemByCode(this.bonusRewardCode);
            if(this.congratsDialogURL != null)
            {
               UI.displayPopup(new HalloweenInnovationBonusGrantWindow(this.congratsDialogURL,m_featureName,bonusRewardItem,this.onCloseBonusWindow),false);
               FarmStatsManager.count("RockPaperShivers","bonus_window","open",bonusRewardItem.name);
            }
         }
         else
         {
            this.showMainUI();
         }
      }
      
      public function onCloseBonusWindow(e:Event = null) : void
      {
         var featureData:Object = this.getFeatureOption();
         var bonusRewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.bonusRewardCode);
         Global.player.addGift(bonusRewardItem.name);
         var giftItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.bonusRewardCode);
         if(Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_HALLOWEENUSA)
         {
            if(this.m_mainWindow)
            {
               this.m_mainWindow.close();
            }
            Global.world.enterForcePlaceMode(giftItem.name);
         }
         featureData["rewards"][FEATURE_OPTIONS_BONUS_CLAIMED_KEY] = 1;
      }
      
      public function getWinCountForReward(rewardCode:String) : int
      {
         var rewardCount:int = 0;
         var featureData:Object = this.getFeatureOption();
         if(Boolean(featureData) && Boolean(featureData.hasOwnProperty("rewards")) && Boolean(featureData["rewards"].hasOwnProperty(rewardCode)) && Boolean(featureData["rewards"][rewardCode].hasOwnProperty(WINCOUNT_FO_KEY)))
         {
            rewardCount = int(featureData["rewards"][rewardCode][WINCOUNT_FO_KEY]);
         }
         return rewardCount;
      }
      
      public function getWinCountGoalForReward(rewardItemCode:String) : int
      {
         var winCountGoal:int = 0;
         var rewardsArray:Array = null;
         var reward:Object = null;
         for(var tierIndex:int = 0; tierIndex < 4; tierIndex++)
         {
            rewardsArray = this.getRewardsOfTier(tierIndex);
            for each(reward in rewardsArray)
            {
               if(reward.code == rewardItemCode)
               {
                  winCountGoal = int(reward.required);
               }
            }
         }
         return winCountGoal;
      }
      
      public function isRewardRedeemable(rewardCode:String) : Boolean
      {
         var result:Boolean = false;
         if(this.getWinCountForReward(rewardCode) >= this.getWinCountGoalForReward(rewardCode))
         {
            result = true;
         }
         return result;
      }
      
      public function openRedeemWindow(category:String, couponName:String) : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         this.m_CurrentcouponName = couponName;
         FarmStatsManager.count("RockPaperShivers","Market_UI","open",category);
         UI.displayPopup(new HalloweenUSARedeemWindow(m_featureName,category,this.redeemDialogURL),false);
      }
      
      public function redeemCouponItem(itemCode:String, parentWindow:HalloweenUSARedeemWindow) : void
      {
         var item:FarmItem = null;
         if(this.m_CurrentcouponName != "" && this.m_CurrentcouponName != null)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            Global.player.addGift(item.name);
            if(this.congratsDialogURL != null)
            {
               UI.displayPopup(new HalloweenInnovationPostRedeemWindow(this.congratsDialogURL,m_featureName,item,null),false);
            }
            Global.player.removeGiftWithKey(Global.farmGameSettingsManager.getFarmItemCodeByName(this.m_CurrentcouponName),1);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,SERVICE_FUNC_REDEEM_ITEM,null,[m_featureName,item.code,this.m_CurrentcouponName]));
            this.m_CurrentcouponName = "";
         }
      }
      
      private function updateCompletedTasks() : void
      {
         var taskObj:Object = null;
         var taskId:String = null;
         var result:int = 0;
         TransactionManager.addTransaction(new TGenericTransaction("HalloweenUSAInnovationService","updateCompletedTasks",this.updateCompletedTasksCallback,[FEATURE_NAME]));
         var progressFlag:Boolean = false;
         var fo:Object = this.getFeatureOption();
         for(var tierNumber:int = 1; tierNumber < 4; tierNumber++)
         {
            for each(taskObj in this.m_staticData["tiers"][tierNumber])
            {
               taskId = taskObj.type + "_" + taskObj.level;
               result = 0;
               switch(taskObj.action)
               {
                  case QuestConstants.TASK_GET_MASTERY_LEVEL_BY_CODE:
                     result = this.isCropAtMasteryLevel(taskObj.type,taskObj.level);
                     break;
                  case QuestConstants.TASK_EXPAND_STORAGE_BUILDING_TO_LEVEL_BY_CODE:
                     result = this.isBuildingAtLevel(taskObj.type,taskObj.level);
                     break;
                  case QuestConstants.TASK_COMPLETE_FEATURE_CRAFTING_NPC:
                     result = this.isEliteHorsesAtLevel(taskObj.level);
                     break;
                  case QuestConstants.TASK_HARVEST_BY_CODE:
                     if(taskObj.name == "bigbuildable")
                     {
                        result = this.isBuildingAtLevel(taskObj.type,taskObj.level);
                     }
                     else if(taskObj.name == "tileUnlock")
                     {
                        result = this.isTileUnLocked(taskObj.type) ? 1 : 0;
                     }
                     break;
                  case QuestConstants.TASK_MAKE_RECIPE_BY_CODE:
               }
               if(result)
               {
                  progressFlag = true;
                  if(!fo["tiers"].hasOwnProperty(taskId))
                  {
                     fo["tiers"][taskId] = 1;
                  }
               }
            }
         }
         if(progressFlag)
         {
         }
      }
      
      private function isCropAtMasteryLevel(code:String, level:int) : int
      {
         var m:Mastery = Global.farmGameSettingsManager.getMasteryByCode(code);
         return m.currentLevel >= level ? 1 : 0;
      }
      
      private function isBuildingAtLevel(buildingCode:String, requiredLevel:int) : int
      {
         var objects:Array = Global.world.getObjectsByCode(buildingCode);
         var level:int = 0;
         var buildingItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(buildingCode);
         if(objects.length == 1)
         {
            level = (objects[0] as FeatureBuilding).storageLevel - 1;
         }
         return level > requiredLevel ? 1 : 0;
      }
      
      private function isEliteHorsesAtLevel(requiredLevel:int) : int
      {
         var npcData:Object = null;
         var animalObject:Object = null;
         var buildingName:String = "xha_elitehorses";
         var level:int = 0;
         var craftingSystem:FeatureCraftingSystem = FeatureCraftingManager.instance.getSystem(buildingName);
         if(craftingSystem)
         {
            npcData = craftingSystem.npcData;
            for each(animalObject in npcData)
            {
               if(animalObject.hasOwnProperty("complete"))
               {
                  if(animalObject["complete"] == true)
                  {
                     level++;
                  }
               }
            }
         }
         return level > requiredLevel ? 1 : 0;
      }
      
      private function updateCompletedTasksCallback(result:Object) : void
      {
      }
      
      public function IsBonusBuildingReadyToHarvest() : Boolean
      {
         var result:Boolean = false;
         if(this.getTimeLeftForBonusHarvest() <= 0)
         {
            result = true;
         }
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("halloweenusa_feature_enabled");
         if(!PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            result = false;
         }
         return result;
      }
      
      public function getTimeLeftForBonusHarvest() : int
      {
         var timeLeft:int = 0;
         var key:String = LAST_BONUS_HARVEST_TIME_KEY;
         var throttleTime:int = DEFAULT_HARVEST_THROTTLE_TIME;
         return this.getTimeLeft(key,throttleTime);
      }
      
      public function harvestBonusBuilding() : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         var key:String = LAST_BONUS_HARVEST_TIME_KEY;
         Global.player.setFeatureLastShown(key,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         var harvestCouponName:String = this.getNextHarvestCouponName();
         var couponFarmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(harvestCouponName);
         Global.player.addGift(harvestCouponName);
         if(this.congratsDialogURL != null)
         {
            UI.displayPopup(new HalloweenInnovationPostHarvestWindow(this.congratsDialogURL,m_featureName,couponFarmItem,null),false);
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,SERVICE_FUNC_HARVEST_BONUS,null,[m_featureName]),true);
      }
      
      public function getNextHarvestCouponName() : String
      {
         var couponName:String = null;
         var bonusCount:int = 0;
         var featureData:Object = getFeatureOptionData();
         if(featureData)
         {
            if(featureData.hasOwnProperty(BONUS_HARVEST_COUNT))
            {
               bonusCount = featureData[BONUS_HARVEST_COUNT] as int;
            }
            else
            {
               featureData[BONUS_HARVEST_COUNT] = 0;
               bonusCount = 0;
            }
         }
         couponName = this.BONUS_HARVEST_ARRAY[bonusCount % 4];
         featureData[BONUS_HARVEST_COUNT] = bonusCount + 1;
         setFeatureData(featureData);
         return couponName;
      }
      
      public function canGrantBonusReward() : Boolean
      {
         var rewardsArray:Array = null;
         var rewardIndex:int = 0;
         var result:Boolean = true;
         for(var tierIndex:int = 0; tierIndex < 4; tierIndex++)
         {
            rewardsArray = this.getRewardsOfTier(tierIndex);
            for(rewardIndex = 0; rewardIndex < rewardsArray.length; rewardIndex++)
            {
               if(this.isRewardClaimed(rewardsArray[rewardIndex].code) == false)
               {
                  result = false;
                  break;
               }
            }
         }
         if(this.isBonusClaimed == true)
         {
            result = false;
         }
         return result;
      }
      
      public function isBonusClaimed() : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureOption();
         if(Boolean(featureData) && Boolean(featureData.hasOwnProperty("rewards")) && Boolean(featureData["rewards"].hasOwnProperty(FEATURE_OPTIONS_BONUS_CLAIMED_KEY)) && featureData["rewards"][FEATURE_OPTIONS_BONUS_CLAIMED_KEY] == 1)
         {
            result = true;
         }
         return result;
      }
      
      public function isRewardClaimed(rewardCode:String) : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureOption();
         if(Boolean(featureData) && Boolean(featureData.hasOwnProperty("rewards")) && Boolean(featureData["rewards"].hasOwnProperty(rewardCode)) && Boolean(featureData["rewards"][rewardCode].hasOwnProperty(REDEEM_FO_KEY)))
         {
            result = int(featureData["rewards"][rewardCode][REDEEM_FO_KEY]) == 1;
         }
         return result;
      }
      
      public function get bonusRewardCode() : String
      {
         return "1l8g";
      }
      
      public function get selectedItemCodeForGame() : String
      {
         return this._m_selectedItemCodeForGame;
      }
      
      public function initEventListener() : void
      {
         GlobalEventManager.getInstance().addEventListener(EVENT_HU_INNOVATION_TILE_UNLOCK,this.showTileUnlockGrantPopup);
      }
      
      public function deleteEventListener() : void
      {
         GlobalEventManager.getInstance().removeEventListener(EVENT_HU_INNOVATION_TILE_UNLOCK,this.showTileUnlockGrantPopup);
      }
      
      public function showTileUnlockGrantPopup(e:TileUnlockEvent = null) : void
      {
         this.showGrantPopup();
         this.resetCollectConsumableTimer(e.tileData.getItemName());
      }
      
      public function showGrantPopup() : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         var trickyTreatsFarmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.ConsumableCode);
         UI.displayPopup(new HalloweenUSAInnovationTileUnlockWindow(this.congratsDialogURL,m_featureName,trickyTreatsFarmItem));
      }
      
      public function deductConsumableForGame() : void
      {
         FeatureOptionsInventoryManager.getInstance().removeCount(this.ConsumableCode,this.gameCost);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,SERVICE_FUNC_DEDUCT_CONSUMABLE,null,[m_featureName]));
      }
      
      protected function onTransactionAdded(event:TransactionEvent) : void
      {
         this.checkForTaskUpdates(event);
      }
      
      protected function checkForTaskUpdates(event:TransactionEvent) : void
      {
         var progress:Number = NaN;
         var transaction:TFarmTransaction = null;
         var tasks:Object = null;
         var tierTasks:Object = null;
         var individualTasks:Object = null;
         var taskId:String = null;
         var craftingSystem:FeatureCraftingSystem = null;
         var npcData:Object = null;
         var currentProgressLevel:int = 0;
         var animalObject:Object = null;
         var prevProgress:int = 0;
         var icon:FeatureQueuedIcon = null;
         if(!m_initialized)
         {
            this.initialize();
         }
         var levelIncrementFlag:Boolean = false;
         var hascompletedTask:Boolean = false;
         var fo:Object = this.getFeatureOption();
         if(Boolean(this.m_staticData) && Boolean(fo))
         {
            tasks = this.m_staticData["tiers"];
            transaction = event.transaction as TFarmTransaction;
            for each(tierTasks in tasks)
            {
               for each(individualTasks in tierTasks)
               {
                  progress = FarmQuestUtility.getInstance().getProgression(individualTasks.obj,transaction,null);
                  if(progress > 0)
                  {
                     taskId = individualTasks.type + "_" + individualTasks.level;
                     if(individualTasks.type == "1kgy")
                     {
                        if(!levelIncrementFlag)
                        {
                           ++fo["1kgy"];
                           levelIncrementFlag = true;
                        }
                        if(fo["1kgy"] >= individualTasks.level)
                        {
                           if(!fo["tiers"].hasOwnProperty(taskId))
                           {
                              fo["tiers"][taskId] = 1;
                              hascompletedTask = true;
                           }
                        }
                     }
                     else if(individualTasks.action == QuestConstants.TASK_COMPLETE_FEATURE_CRAFTING_LEVEL)
                     {
                        craftingSystem = FeatureCraftingManager.instance.getSystem("xha_elitehorses");
                        npcData = craftingSystem.npcData;
                        currentProgressLevel = 0;
                        for each(animalObject in npcData)
                        {
                           if(animalObject.hasOwnProperty("complete"))
                           {
                              if(animalObject["complete"] == true)
                              {
                                 currentProgressLevel++;
                              }
                           }
                        }
                        if(currentProgressLevel + 1 >= individualTasks.level)
                        {
                           if(!fo["tiers"].hasOwnProperty(taskId))
                           {
                              fo["tiers"][taskId] = 1;
                              hascompletedTask = true;
                           }
                        }
                     }
                     else if(individualTasks.action == QuestConstants.TASK_MAKE_RECIPE_BY_CODE)
                     {
                        prevProgress = 0;
                        if(fo.hasOwnProperty(individualTasks.type))
                        {
                           prevProgress = int(fo[individualTasks.type]);
                        }
                        fo[individualTasks.type] = prevProgress + 1;
                        if(fo[individualTasks.type] >= individualTasks.level)
                        {
                           if(!fo["tiers"].hasOwnProperty(taskId))
                           {
                              fo["tiers"][taskId] = 1;
                              hascompletedTask = true;
                           }
                        }
                     }
                     else if(!fo["tiers"].hasOwnProperty(taskId))
                     {
                        fo["tiers"][taskId] = 1;
                        hascompletedTask = true;
                     }
                  }
                  if(hascompletedTask && Boolean(individualTasks))
                  {
                     FarmStatsManager.count("RockPaperShivers","task_complete",individualTasks.level,individualTasks.action,individualTasks.type);
                  }
               }
            }
            setFeatureData(fo);
            if(hascompletedTask)
            {
               this.updateCurrentTier();
               icon = Global.hud.rightSideIconQueue.getIconByFeatureName(m_featureName) as FeatureQueuedIcon;
               if(icon)
               {
                  icon.attachArrow(ArrowType.ARROWUPDATE);
                  icon.setArrowText("Progress");
               }
            }
         }
      }
      
      public function openKnowMoreBonusWindow() : void
      {
         this.m_bonusInfoWindow = new HalloweenUSAInnovationBonusInfoWindow(m_featureName,"assets/dialogs/halloweenusa/innovation/FV_xha_Innovation_Bonus.swf");
         UI.displayPopup(this.m_bonusInfoWindow,false);
      }
      
      public function deActivateGameMode() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,SERVICE_FUNC_DEACTIATE_GAMEMODE,null,[m_featureName]));
      }
      
      public function getDefaultWaitingTime() : Number
      {
         var deafultWaitingTime:Number = 40;
         if(Global.flashHotParams.hasOwnProperty(HalloweenInnovationManager.HALLOWEEN_INNOVATION_MATCH_WAIT_TIME) && Global.flashHotParams[HALLOWEEN_INNOVATION_MATCH_WAIT_TIME] > 40)
         {
            deafultWaitingTime = Number(Global.flashHotParams[HALLOWEEN_INNOVATION_MATCH_WAIT_TIME]);
         }
         return deafultWaitingTime;
      }
      
      public function getDefaultPPPAttempts() : Number
      {
         var deafultPPPAttempts:Number = 3;
         if(Global.flashHotParams.hasOwnProperty(HalloweenInnovationManager.HALLOWEEN_INNOVATION_PPP_ATTEMPTS_COUNT) && Global.flashHotParams[HALLOWEEN_INNOVATION_PPP_ATTEMPTS_COUNT] > 3)
         {
            deafultPPPAttempts = Number(Global.flashHotParams[HALLOWEEN_INNOVATION_PPP_ATTEMPTS_COUNT]);
         }
         return deafultPPPAttempts;
      }
      
      public function getOneTimeCosumableGrantValue() : Number
      {
         return 200;
      }
      
      public function grantOneTimeBonus() : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         var featureData:Object = this.getFeatureOption();
         if(!(featureData.hasOwnProperty(this.KEY_ONE_TIME_GRANT) && featureData[this.KEY_ONE_TIME_GRANT] == 1))
         {
            featureData[this.KEY_ONE_TIME_GRANT] = 1;
            setFeatureData(featureData);
            FeatureOptionsInventoryManager.getInstance().addCount(this.ConsumableCode,this.getOneTimeCosumableGrantValue());
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,SERVICE_FUNC_BONUS_COLLECT,null,[m_featureName]));
         }
         HalloweenInnovationManager.getInstance().showMainUI();
      }
   }
}

