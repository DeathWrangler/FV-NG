package Managers
{
   import Classes.Constants.PrerequisiteConstants;
   import Classes.MatchMaking.MatchMakingManager;
   import Classes.SimpleCryptoManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.HUD.HUD;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TAfInnovationFinishGame;
   import Transactions.TGenericTransaction;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.AFInnovationGameCongratsWindow;
   import Widgets.Windows.AFInnovationP2PGameWindow;
   import Widgets.Windows.AFInnovationPlaySoloWindow;
   import Widgets.Windows.AFInnovationRedeemCongratsWindow;
   import Widgets.Windows.AFInnovationRedeemWindow;
   import Widgets.Windows.AFInnovationTileUnlockWindow;
   import Widgets.Windows.AFInnovationWindow;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FeaturePackagesBuyWindow;
   import Widgets.Windows.MatchmakingBetaToasterWindow;
   import flash.events.DataEvent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class AFInnovationManager extends BaseFeatureManager
   {
      
      private static const FEATURE_NAME:String = "AFInnovation";
      
      private static const WINDOW_MAIN:String = "main";
      
      private static const WINDOW_REDEEM:String = "redeem";
      
      private static const WINDOW_BUYDIALOG:String = "buyDialog";
      
      private static const WINDOW_GAME:String = "game";
      
      private static const WINDOW_PRIZE:String = "prize";
      
      private static const WINDOW_TOASTER:String = "toaster";
      
      private static const WINDOW_MFS:String = "mfswindow";
      
      public static const COLLECT_TIME_KEY:String = "ctk";
      
      public static const FEED_NAME:String = "FeatureUI";
      
      private static const EVENT_AF_INNOVATION_TILE_UNLOCK:String = "AFInnovationTileUnlock";
      
      public static const AFINNOVATION_BONUSVALUE:String = "AFINNOVATION_BONUSVALUE";
      
      public static const AFINNOVATION_BONUSENABLED_FLAG:String = "AFINNOVATION_BONUSENABLED_FLAG";
      
      public static const FEATURE_OPTIONS_KEY:String = "AFInnovation";
      
      public static const FEATURE_OPTIONS_COLLECT_KEY:String = "collection";
      
      public static const PRIMARY_USER:int = 0;
      
      public static const SECONDARY_USER:int = 1;
      
      private static const TOASTER_TIMEOUT:int = 20000;
      
      private static var m_initialized:Boolean = false;
      
      private const SERVICE_CLASS:String = "AFInnovationService";
      
      private const SERVICE_FUNC_COLLECT_RUNES:String = "collectDailyRunes";
      
      private const SERVICE_FUNC_RESET_COLLECT_TIMER:String = "resetCollectTimer";
      
      private const SERVICE_FUNC_REDEEMGIFT:String = "redeemReward";
      
      private const SERVICE_FUNC_GRANT_REWARD:String = "grantReward";
      
      private const SERVICE_FUNC_CLEAR_GAME_BOARD:String = "clearGameBoard";
      
      private const SERVICE_FUNC_CREATE_GAME_BOARD:String = "createGameBoard";
      
      private const SERVICE_FUNC_GET_GAME_BOARD:String = "getGameBoard";
      
      private const SERVICE_FUNC_DEDUCT_RUNES:String = "deductRunesForGame";
      
      public const DEFAULT_THROTTLE_TIME:Number = 86400;
      
      public const DEFAULT_WAITING_PERIOD:Number = 15;
      
      private const DEFAULT_STARTGAME_WAITING_PERIOD:Number = 10000;
      
      private var m_assetPaths:Object = null;
      
      protected var m_staticData:Object;
      
      private var m_PlaySoloWindow:AFInnovationPlaySoloWindow;
      
      private var m_P2PGameWindow:AFInnovationP2PGameWindow;
      
      private var m_mainWindow:AFInnovationWindow;
      
      private var m_toaster:MatchmakingBetaToasterWindow;
      
      private var m_gameId:String;
      
      private var m_player2UID:String;
      
      private var m_matchTimer:Timer;
      
      private var m_activePrizeX:Number = -1;
      
      private var m_activePrizeY:Number = -1;
      
      private var m_playerStatus:int;
      
      private var m_shouldDeductRunes:Boolean = false;
      
      public var TILES_NAME_ARRAY:Array = new Array("xfe_rubbletreasure6","xfe_rubbletreasure9","xfe_rubbletreasure_payer2");
      
      public function AFInnovationManager(featureName:String, featureConfig:XML = null)
      {
         super(featureName,featureConfig);
      }
      
      public static function getInstance(featureName:String = "AFInnovation") : AFInnovationManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,AFInnovationManager) as AFInnovationManager;
      }
      
      public static function getNumberOfGamesPlayed() : int
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,"gamesPlayed") as int;
      }
      
      public function showMainUI(showTutorialWithEAPage:Boolean = false) : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         if(this.m_mainWindow)
         {
            this.m_mainWindow.untintWindow();
            this.m_mainWindow.enableInput = true;
         }
         else
         {
            UI.displayPopup(this.m_mainWindow = new AFInnovationWindow(m_featureName,this.mainWindowURL,showTutorialWithEAPage));
            FarmStatsManager.count(m_featureName,"feature_ui","main_ui","impression");
         }
      }
      
      public function openBuyWindow(owner:FarmWindow) : void
      {
         UI.displayPopup(new FeaturePackagesBuyWindow(this.buyDialogURL,m_featureName,this.getBucketPackages(),owner),false);
      }
      
      public function initialize() : void
      {
         this.loadStaticData();
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,m_featureName);
         if(!featureData)
         {
            featureData = new Object();
            FeatureOptionsInventoryManager.getInstance().addCount(this.ConsumableCode,this.initialRunesGrant);
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,m_featureName,featureData);
         }
      }
      
      public function ongameRequestReceived(e:DataEvent) : void
      {
      }
      
      private function onStartGameTimerExpired(event:TimerEvent) : void
      {
         this.m_matchTimer.stop();
         AFInnovationManager.getInstance().p2pWindow.setOverlayText("Unable to load game","Sorry about that.","Okay",AFInnovationManager.getInstance().p2pWindow.closeWindowAndShowMainUI);
      }
      
      private function shouldSuppressToaster(uid:String) : Boolean
      {
         var lastToasterRejectedTime:Number = NaN;
         var timeInterval:Number = NaN;
         var result:Boolean = false;
         var shouldSuppressToaster:Number = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,"shouldSuppressToaster") as Number;
         if(Global.friendManager.neighborUids.indexOf(uid) == -1 && Global.friendManager.appFriendUids.indexOf(uid) == -1)
         {
            if(Boolean(shouldSuppressToaster) && shouldSuppressToaster > 0)
            {
               lastToasterRejectedTime = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,"lastToasterRejectedTime") as Number;
               if(Boolean(lastToasterRejectedTime) && lastToasterRejectedTime > 0)
               {
                  timeInterval = GlobalEngine.serverTime - lastToasterRejectedTime;
                  if(timeInterval > 6 * FarmGameUtil.NUM_MSECS_IN_HOUR)
                  {
                     FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,"shouldSuppressToaster",0);
                     FeatureOptionsManager.getInstance().saveSingleFeature(FEATURE_OPTIONS_KEY,"shouldSuppressToaster");
                  }
                  else
                  {
                     result = true;
                  }
               }
            }
         }
         return result;
      }
      
      private function onchatMessageReceived(e:DataEvent) : void
      {
         if(e.data.indexOf("StartGame:" + this.m_gameId) != -1)
         {
            if(this.m_matchTimer)
            {
               this.m_matchTimer.stop();
            }
            MatchMakingManager.getInstance().removeEventListener(MatchMakingManager.EVENTTYPE_CHAT,this.onchatMessageReceived);
            this.setPlayerStatus(this.m_player2UID);
            this.m_P2PGameWindow.initializeGameBoard(this.m_player2UID,this.m_gameId,this.m_playerStatus);
         }
      }
      
      public function setPlayerStatus(uid:String) : void
      {
         if(Global.player.uid > uid)
         {
            this.m_playerStatus = PRIMARY_USER;
         }
         else
         {
            this.m_playerStatus = SECONDARY_USER;
         }
      }
      
      public function get playerStatus() : int
      {
         return this.m_playerStatus;
      }
      
      public function set player2UId(player2Uid:String) : void
      {
         this.m_player2UID = player2Uid;
      }
      
      private function loadStaticData() : void
      {
         var rewardXML:XML = null;
         var itemXML:XML = null;
         var division:XML = null;
         var asset:XML = null;
         var item:XML = null;
         this.m_staticData = new Object();
         this.m_staticData.typeArray = new Array();
         this.m_staticData.rewardArray = new Array();
         this.m_staticData.rewardCostArray = new Array();
         this.m_staticData.bucketPackages = new Array();
         this.m_staticData.endDate = "";
         this.m_staticData.runes = "";
         this.m_staticData.currencyName = "";
         this.m_staticData.initialGrant = 0;
         this.m_staticData.rewardGrantCount = 0;
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
            this.m_staticData.runes = featureXML.bucketItem.@code.toString();
            this.m_staticData.currencyName = featureXML.currencyItem.@name.toString();
            for each(rewardXML in featureXML.rewards.reward)
            {
               this.m_staticData.rewardArray.push(rewardXML.@name.toString());
               this.m_staticData.rewardCostArray.push(rewardXML.@cost);
            }
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
                     if(item.@name.toString() == "reward_grant_count")
                     {
                        this.m_staticData.rewardGrantCount = item.@count.toString();
                     }
                     else if(item.@name.toString() == "initial_grant_count")
                     {
                        this.m_staticData.initialGrant = item.@count.toString();
                     }
                     else if(item.@name.toString() == "game_cost")
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
         }
      }
      
      public function get mainWindowURL() : String
      {
         return this.m_assetPaths[WINDOW_MAIN];
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
      
      public function get tileUnlockCongratsDialogURL() : String
      {
         return this.m_assetPaths[WINDOW_PRIZE];
      }
      
      public function get gamePrizeDialogURL() : String
      {
         return this.m_assetPaths[WINDOW_PRIZE];
      }
      
      public function get redeemCongratsDialogURL() : String
      {
         return this.m_assetPaths[WINDOW_PRIZE];
      }
      
      public function get toasterDialogURL() : String
      {
         return this.m_assetPaths[WINDOW_TOASTER];
      }
      
      public function get mfsDialogURL() : String
      {
         return this.m_assetPaths[WINDOW_MFS];
      }
      
      public function getBucketPackages() : Array
      {
         return this.m_staticData.bucketPackages;
      }
      
      public function get initialRunesGrant() : int
      {
         return int(this.m_staticData.initialGrant);
      }
      
      public function get ConsumableCode() : String
      {
         return this.m_staticData.runes;
      }
      
      public function get CurrencyName() : String
      {
         return this.m_staticData.currencyName;
      }
      
      public function get CurrencyCode() : String
      {
         var currencyItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.CurrencyName);
         return currencyItem.code;
      }
      
      public function getRewardArray() : Array
      {
         return this.m_staticData.rewardArray;
      }
      
      public function getRewardCostArray() : Array
      {
         return this.m_staticData.rewardCostArray;
      }
      
      public function getConsumableCount() : Number
      {
         return int(FeatureOptionsInventoryManager.getInstance().getCount(this.ConsumableCode));
      }
      
      public function getCurrencyCount() : Number
      {
         return int(FeatureOptionsInventoryManager.getInstance().getCount(this.CurrencyCode));
      }
      
      public function buyRunesBuckets(buyPackage:String) : void
      {
         var runesPackage:FarmItem = null;
         if(buyPackage != null)
         {
            runesPackage = Global.farmGameSettingsManager.getFarmItemByName(buyPackage);
            Global.player.buyFarmItem(runesPackage,Currency.CASH,1);
         }
      }
      
      public function collectDailyRunes() : void
      {
         var runesDrop:Number = this.calculateDailyCollectableRunes();
         FeatureOptionsInventoryManager.getInstance().addCount(this.ConsumableCode,runesDrop);
         var key:String = m_featureName + COLLECT_TIME_KEY;
         Global.player.setFeatureLastShown(key,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,this.SERVICE_FUNC_COLLECT_RUNES,null,[m_featureName]));
      }
      
      public function calculateDailyCollectableRunes() : Number
      {
         var dropForTheDay:Number = this.gameCost;
         if(Global.flashHotParams.hasOwnProperty(AFInnovationManager.AFINNOVATION_BONUSENABLED_FLAG) && Boolean(Global.flashHotParams[AFINNOVATION_BONUSVALUE]))
         {
            dropForTheDay = Number(Global.flashHotParams[AFINNOVATION_BONUSVALUE]);
         }
         return dropForTheDay;
      }
      
      public function resetCollectTimer() : void
      {
         var key:String = m_featureName + COLLECT_TIME_KEY;
         Global.player.setFeatureLastShown(key,(GlobalEngine.serverTime - FarmGameUtil.NUM_MSECS_IN_DAY) / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,this.SERVICE_FUNC_RESET_COLLECT_TIMER,null,[m_featureName]));
      }
      
      public function canCollectForTheDay() : Boolean
      {
         var canCollect:Boolean = true;
         var key:String = m_featureName + COLLECT_TIME_KEY;
         if(this.getTimeLeft(key,this.DEFAULT_THROTTLE_TIME) > 0)
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
      
      public function canUserStartPlaying() : Boolean
      {
         var canStart:Boolean = false;
         var runesCount:Number = FeatureOptionsInventoryManager.getInstance().getCount(this.ConsumableCode);
         if(runesCount >= this.gameCost)
         {
            canStart = true;
         }
         return canStart;
      }
      
      public function openP2PGameWindow() : void
      {
         UI.displayPopup(this.m_P2PGameWindow = new AFInnovationP2PGameWindow(m_featureName,this.gamePlayDialogURL),false);
         FarmStatsManager.count(m_featureName,"feature_ui","p2p_game_ui","impression");
      }
      
      public function openPlaySoloWindow() : void
      {
         UI.displayPopup(this.m_PlaySoloWindow = new AFInnovationPlaySoloWindow(m_featureName,this.gamePlayDialogURL),false);
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,this.SERVICE_FUNC_CREATE_GAME_BOARD,this.onReceiveSoloGameBoard,[m_featureName,0]));
         FarmStatsManager.count(m_featureName,"feature_ui","play_solo_ui","impression");
      }
      
      public function onReceiveSoloGameBoard(resultData:Object) : void
      {
         var gameBoardString:String = null;
         var encryptionManager:SimpleCryptoManager = null;
         var decryptedStr:String = null;
         var cellArray:Array = null;
         if(Boolean(resultData) && resultData.hasOwnProperty("gameBoard"))
         {
            gameBoardString = resultData["gameBoard"]["data"];
            encryptionManager = new SimpleCryptoManager();
            encryptionManager.init();
            decryptedStr = encryptionManager.decrypt(gameBoardString);
            cellArray = decryptedStr.split(",");
            this.m_activePrizeX = cellArray[0];
            this.m_activePrizeY = cellArray[1];
            if(this.m_PlaySoloWindow)
            {
               this.m_PlaySoloWindow.startGame();
            }
         }
      }
      
      private function onaskForRunes(e:Object) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.refreshAskButton();
         }
      }
      
      public function askForRunes(event:Event = null) : void
      {
         getFeedData(FEED_NAME).postFeed(this.onaskForRunes);
      }
      
      public function get p2pWindow() : AFInnovationP2PGameWindow
      {
         return this.m_P2PGameWindow;
      }
      
      public function get mainWindow() : AFInnovationWindow
      {
         return this.m_mainWindow;
      }
      
      public function set mainWindow(window:AFInnovationWindow) : void
      {
         this.m_mainWindow = window;
      }
      
      public function get turnsInSoloMode() : Number
      {
         return this.m_staticData.soloTurnCount;
      }
      
      public function get gameCost() : Number
      {
         return this.m_staticData.gameCost;
      }
      
      public function get rewardGrantCount() : Number
      {
         return this.m_staticData.rewardGrantCount;
      }
      
      public function get turnsInP2PMode() : Number
      {
         return this.m_staticData.p2pTurnCount;
      }
      
      public function openRedeemWindow() : void
      {
         UI.displayPopup(new AFInnovationRedeemWindow(m_featureName,this.redeemDialogURL),false);
         FarmStatsManager.count(m_featureName,"feature_ui","redeem_ui","impression");
      }
      
      public function isRewardRedeemable(slotIndex:int) : Boolean
      {
         var canRedeem:Boolean = false;
         var rewardCost:Number = Number(this.getRewardCostArray()[slotIndex]);
         var consumableCount:Number = FeatureOptionsInventoryManager.getInstance().getCount(this.CurrencyCode);
         if(consumableCount >= rewardCost)
         {
            canRedeem = true;
         }
         return canRedeem;
      }
      
      public function redeemItem(itemName:String, slotIndex:int, redeemWindow:AFInnovationRedeemWindow) : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         FeatureOptionsInventoryManager.getInstance().removeCount(this.CurrencyCode,this.getRewardCostArray()[slotIndex]);
         Global.player.addGift(item.name);
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,m_featureName);
         if(featureData)
         {
            if(featureData.hasOwnProperty(FEATURE_OPTIONS_COLLECT_KEY) == false)
            {
               featureData[FEATURE_OPTIONS_COLLECT_KEY] = new Object();
            }
            featureData[FEATURE_OPTIONS_COLLECT_KEY][item.name] = 1;
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,m_featureName,featureData);
         }
         redeemWindow.refreshWindow();
         if(this.redeemCongratsDialogURL != null)
         {
            UI.displayPopup(new AFInnovationRedeemCongratsWindow(this.redeemCongratsDialogURL,m_featureName,item,null),false);
            FarmStatsManager.count(m_featureName,"redeem_congrats_ui","redeem",item.name);
         }
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,this.SERVICE_FUNC_REDEEMGIFT,null,[m_featureName,slotIndex]));
      }
      
      public function get lockedTilesArray() : Array
      {
         var tilename:String = null;
         var tileObjects:Array = null;
         var lockedTiles:Array = new Array();
         for each(tilename in this.TILES_NAME_ARRAY)
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
      
      public function determineCellColor(x:Number, y:Number) : Number
      {
         var colorState:int = -1;
         var dis_x:int = this.m_activePrizeX - x;
         var dis_y:int = this.m_activePrizeY - y;
         var dis:int = Math.sqrt(dis_x * dis_x + dis_y * dis_y);
         if(dis == 0)
         {
            colorState = 5;
         }
         else if(dis == 1)
         {
            colorState = 4;
         }
         else if(dis == 2)
         {
            colorState = 3;
         }
         else
         {
            colorState = 2;
         }
         return colorState;
      }
      
      public function finishGameWithReward(event:MouseEvent = null) : void
      {
         if(this.m_PlaySoloWindow)
         {
            this.m_PlaySoloWindow.close();
         }
         if(this.m_P2PGameWindow)
         {
            this.m_P2PGameWindow.close();
         }
         this.showMainUI();
         var currencyItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.CurrencyName);
         FeatureOptionsInventoryManager.getInstance().addCount(this.CurrencyCode,this.rewardGrantCount);
         UI.displayPopup(new AFInnovationGameCongratsWindow(this.gamePrizeDialogURL,m_featureName,currencyItem,null),false);
         FarmStatsManager.count(m_featureName,"redeem_congrats_ui","redeem",currencyItem.name);
         TransactionManager.addTransaction(new TAfInnovationFinishGame(this.SERVICE_CLASS,this.SERVICE_FUNC_GRANT_REWARD,null,[m_featureName,this.m_activePrizeX,this.m_activePrizeY]));
      }
      
      public function finishGameWithOutReward() : void
      {
         TransactionManager.addTransaction(new TAfInnovationFinishGame(this.SERVICE_CLASS,this.SERVICE_FUNC_CLEAR_GAME_BOARD,null,[m_featureName,this.m_activePrizeX,this.m_activePrizeY]));
      }
      
      public function get prizeX() : Number
      {
         return this.m_activePrizeX;
      }
      
      public function get prizeY() : Number
      {
         return this.m_activePrizeY;
      }
      
      public function createP2PGameBoard(uid:String) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,this.SERVICE_FUNC_CREATE_GAME_BOARD,this.onReceiveP2PGameBoard,[m_featureName,uid]));
      }
      
      public function getP2PGameBoard(m_player2UID:String) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,this.SERVICE_FUNC_GET_GAME_BOARD,this.onReceiveP2PGameBoard,[m_featureName,m_player2UID]));
      }
      
      public function onReceiveP2PGameBoard(resultData:Object) : void
      {
         var gameBoardString:String = null;
         var encryptionManager:SimpleCryptoManager = null;
         var decryptedStr:String = null;
         var cellArray:Array = null;
         if(Boolean(resultData) && resultData.hasOwnProperty("gameBoard"))
         {
            gameBoardString = resultData["gameBoard"]["data"];
            encryptionManager = new SimpleCryptoManager();
            encryptionManager.init();
            decryptedStr = encryptionManager.decrypt(gameBoardString);
            cellArray = decryptedStr.split(",");
            this.m_activePrizeX = cellArray[0];
            this.m_activePrizeY = cellArray[1];
            if(this.m_P2PGameWindow)
            {
               this.m_P2PGameWindow.initiateGame();
            }
         }
      }
      
      public function closeP2PAndOpenMainWindow() : void
      {
         if(this.m_P2PGameWindow)
         {
            this.m_P2PGameWindow.close();
            this.showMainUI();
         }
      }
      
      public function openGameTutorial() : void
      {
         UI.displayPopup(new AFInnovationP2PGameWindow(m_featureName,this.gamePlayDialogURL,true),false);
      }
      
      public function initEventListener() : void
      {
         GlobalEventManager.getInstance().addEventListener(EVENT_AF_INNOVATION_TILE_UNLOCK,this.showTileUnlockGrantPopup);
      }
      
      public function deleteEventListener() : void
      {
         GlobalEventManager.getInstance().removeEventListener(EVENT_AF_INNOVATION_TILE_UNLOCK,this.showTileUnlockGrantPopup);
      }
      
      public function showTileUnlockGrantPopup(e:Event = null) : void
      {
         this.showGrantPopup();
      }
      
      public function showGrantPopup() : void
      {
         var runesFarmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.ConsumableCode);
         UI.displayPopup(new AFInnovationTileUnlockWindow(this.tileUnlockCongratsDialogURL,m_featureName,runesFarmItem));
      }
      
      public function get shouldDeductRunes() : Boolean
      {
         return this.m_shouldDeductRunes;
      }
      
      public function set shouldDeductRunes(shouldDeduct:Boolean) : void
      {
         this.m_shouldDeductRunes = shouldDeduct;
      }
      
      public function deductRunesForGame() : void
      {
         FeatureOptionsInventoryManager.getInstance().removeCount(this.ConsumableCode,this.gameCost);
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,this.SERVICE_FUNC_DEDUCT_RUNES,null,[m_featureName]));
         this.shouldDeductRunes = false;
      }
      
      public function getFeatureEndDaysLeftText() : String
      {
         var endTimeText:String = null;
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var requirement:Object = null;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("AFInnovation_feature_enabled");
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
   }
}

