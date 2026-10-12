package Managers
{
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.FarmGameUtil;
   import Display.HUD.HUD;
   import Display.HUD.HUDWidgets.HudBottomJumbleVillaButton;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.TileUnlockEvent;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.JumbleVillaMainWindow;
   import Widgets.Windows.JumbleVillaRewardPopup;
   
   public class JumbleVillaManager extends BaseFeatureManager
   {
      
      private static var s_config:Object;
      
      private static const FEATURE_CONFIG_KEY:String = "JumbleVilla";
      
      private static const FEATURE_NAME:String = "JumbleVilla";
      
      private static const SERVICE_NAME:String = "JumbleVillaService";
      
      private static const EVENT_WW_INNOVATION_TILE_UNLOCK:String = "JumbleVillaTileUnlock";
      
      private static const DATE_FEATURE_START:String = "06/15/2020";
      
      private static const DATE_FEATURE_END:String = "07/13/2020";
      
      private static const DATE_STORY_END:String = "07/20/2020";
      
      private static const MAIN_WINDOW_ASSET_URL:String = "assets/dialogs/Jumblevilla_2020/FV_Jumblevilla_2020.swf";
      
      private static const REWARD_DIALOG_ASSET_URL:String = "assets/dialogs/Jumblevilla_2020/FV_Jumblevilla_prize_2020.swf";
      
      private static const HUD_ASSET_URL:String = "assets/dialogs/Jumblevilla_2020/FV_Jumblevilla_hud_2020.swf";
      
      private static const KEY_TILES_UNLOCKED_IN_PREVIOUS_EXPANSION:String = "tiles_unlocked_previously";
      
      private static const KEY_TILES_UNLOCKED:String = "tiles_unlocked";
      
      private static const KEY_SAVED_BUSHEL_PROGRESS:String = "saved_bushel_progress";
      
      private static const KEY_ACTIVE_PUZZLE:String = "active_puzzle";
      
      private static const KEY_ACTIVE_PUZZLE_DATA:String = "active_puzzle_data";
      
      private static const KEY_CONVERTOR_PARTS_COUNT:String = "convertor_parts_count";
      
      private static const KEY_CONVERTOR_PARTS_PROGRESS:String = "convertor_parts_progress";
      
      private static const KEY_PPH_DROP_LEVEL:String = "pph_drop_level";
      
      private static const KEY_FINDER_LEVEL:String = "finder_level";
      
      private static const KEY_LAST_GRANT_ID:String = "last_grant_id";
      
      private static const PROGRESS_REQUIRED_FOR_PART_DROP:Number = 40;
      
      private static const MIN_NO_OF_PARTS_REQUIRED_TO_CONVERT:Number = 100;
      
      private static const LAST_PUZZLE_ID:Number = 3;
      
      private static const NO_OF_PUZZLES:Number = 4;
      
      private static const tilesArray:Object = {
         "xdm_rubbletreasure_payer":[1,25],
         "xdm_rubbletreasure":[1,9]
      };
      
      private var m_mainWindow:JumbleVillaMainWindow;
      
      private var m_bottomHud:HudBottomJumbleVillaButton;
      
      private var m_activePopupCount:int = 0;
      
      public function JumbleVillaManager(featureName:String = "JumbleVilla")
      {
         super(featureName);
         this.parseFeatureDataFromConfig(FEATURE_NAME);
         this.startQuest();
         if(this.isFeatureinActivePeriod())
         {
            TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
         }
      }
      
      public static function getInstance(featureName:String = "JumbleVilla") : JumbleVillaManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,JumbleVillaManager) as JumbleVillaManager;
      }
      
      private static function getLockedTiles() : Array
      {
         var tilesArrayKey:String = null;
         var i:int = 0;
         var tileName:String = null;
         var tileObjects:Array = null;
         var lockedTiles:Array = [];
         for(tilesArrayKey in tilesArray)
         {
            for(i = int(tilesArray[tilesArrayKey][0]); i <= tilesArray[tilesArrayKey][1]; i++)
            {
               tileName = tilesArrayKey + String(i);
               tileObjects = Global.world.getObjectsByName(tileName);
               if(Boolean(tileObjects) && tileObjects.length > 0)
               {
                  lockedTiles.push(tileName);
               }
            }
         }
         return lockedTiles;
      }
      
      public function setupHud() : void
      {
         this.m_bottomHud = new HudBottomJumbleVillaButton(HUD_ASSET_URL,FEATURE_NAME);
         Global.hud.setBottomHudJumbleVillaButton(this.m_bottomHud as HudBottomJumbleVillaButton);
      }
      
      public function isFeatureinActivePeriod() : Boolean
      {
         return PrerequisiteUtility.checkPrereqByName("jumblevilla_feature_enabled");
      }
      
      protected function parseFeatureDataFromConfig(featureName:String) : void
      {
         var rawFeatureConfig:XML = null;
         if(!s_config)
         {
            s_config = {};
         }
         if(!s_config.hasOwnProperty(FEATURE_CONFIG_KEY))
         {
            rawFeatureConfig = Global.farmGameSettingsManager.getXML().JumbleVillaFeatureConfig.JumbleVillaConfigData.(@name == featureName)[0];
            s_config[FEATURE_CONFIG_KEY] = rawFeatureConfig;
         }
      }
      
      public function showMainWindow() : void
      {
         this.resetActivePopupCount();
         this.m_mainWindow = new JumbleVillaMainWindow(FEATURE_NAME,MAIN_WINDOW_ASSET_URL);
         UI.displayPopup(this.m_mainWindow,false);
         var puzzleStatus:String = "puzzle_wip";
         if(this.isActivePuzzleCompleted())
         {
            puzzleStatus = "puzzle_completed";
         }
         StatsManager.count(m_featureName,"mainui","open","",puzzleStatus);
      }
      
      public function startQuest(callback:Function = null) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startQuest",null,[FEATURE_NAME]),true);
      }
      
      protected function onTransactionAdded(event:TransactionEvent) : void
      {
         this.checkForTaskUpdates(event);
      }
      
      protected function checkForTaskUpdates(event:TransactionEvent) : void
      {
         var bushelTask:FarmTask = null;
         var taskProgress:Number = NaN;
         var transaction:TFarmTransaction = event.transaction as TFarmTransaction;
         var bushelTasks:Vector.<FarmTask> = this.getBushelTasksFromConfig();
         var savedBushelProgress:Number = Number(this.getFeatureOptionsKey(KEY_SAVED_BUSHEL_PROGRESS));
         var hasBushelProgress:Boolean = false;
         if(bushelTasks)
         {
            for each(bushelTask in bushelTasks)
            {
               taskProgress = FarmQuestUtility.getInstance().getProgression(bushelTask,transaction,null);
               if(taskProgress > 0)
               {
                  hasBushelProgress = true;
                  savedBushelProgress += taskProgress;
               }
            }
            if(hasBushelProgress)
            {
               if(savedBushelProgress >= PROGRESS_REQUIRED_FOR_PART_DROP)
               {
                  this.checkForPuzzleProgress();
                  savedBushelProgress %= PROGRESS_REQUIRED_FOR_PART_DROP;
               }
               this.setFeatureOptionsKey(KEY_SAVED_BUSHEL_PROGRESS,savedBushelProgress);
            }
         }
      }
      
      private function checkForPuzzleProgress() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getPuzzleProgressData",this.onPuzzleProgress,[FEATURE_NAME]),true);
      }
      
      private function onPuzzleProgress(result:Object) : void
      {
         if(Boolean(result) && Boolean(result.success))
         {
            if(result.hasOwnProperty(KEY_ACTIVE_PUZZLE_DATA))
            {
               this.setFeatureOptionsKey(KEY_ACTIVE_PUZZLE_DATA,result[KEY_ACTIVE_PUZZLE_DATA]);
            }
            if(result.hasOwnProperty(KEY_CONVERTOR_PARTS_COUNT))
            {
               this.setFeatureOptionsKey(KEY_CONVERTOR_PARTS_COUNT,result[KEY_CONVERTOR_PARTS_COUNT]);
            }
            if(result.hasOwnProperty(KEY_CONVERTOR_PARTS_PROGRESS))
            {
               this.setFeatureOptionsKey(KEY_CONVERTOR_PARTS_PROGRESS,result[KEY_CONVERTOR_PARTS_PROGRESS]);
            }
            if(Boolean(this.m_bottomHud) && (this.hasPuzzleProgressed() || this.hasConvertorProgressed()))
            {
               this.m_bottomHud.playProgressDoober();
            }
         }
      }
      
      private function hasConvertorProgressed() : Boolean
      {
         var convertorProgress:Number = this.getConvertorProgress();
         return convertorProgress > 0;
      }
      
      private function hasPuzzleProgressed() : Boolean
      {
         var pieceData:Object = null;
         var activePuzzleData:Object = this.getFeatureOptionsKey(KEY_ACTIVE_PUZZLE_DATA);
         for each(pieceData in activePuzzleData["pieces"])
         {
            if(pieceData["progress"] > 0)
            {
               return true;
            }
         }
         return false;
      }
      
      public function updatePuzzleProgress() : void
      {
         var pieceData:Object = null;
         var puzzleData:Object = this.getFeatureOptionsKey(KEY_ACTIVE_PUZZLE_DATA);
         var hasPieceProgression:Boolean = Boolean(0);
         var partsInConvertor:Number = Number(this.getFeatureOptionsKey(KEY_CONVERTOR_PARTS_COUNT));
         var convertorProgress:Number = Number(this.getFeatureOptionsKey(KEY_CONVERTOR_PARTS_PROGRESS));
         this.setFeatureOptionsKey(KEY_CONVERTOR_PARTS_COUNT,partsInConvertor + convertorProgress);
         this.setFeatureOptionsKey(KEY_CONVERTOR_PARTS_PROGRESS,0);
         for each(pieceData in puzzleData["pieces"])
         {
            if(pieceData["progress"] > 0)
            {
               hasPieceProgression = Boolean(1);
               pieceData["collected"] += pieceData["progress"];
               pieceData["progress"] = 0;
            }
         }
         this.setFeatureOptionsKey(KEY_ACTIVE_PUZZLE_DATA,puzzleData);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"updatePuzzleProgress",null,[FEATURE_NAME]),true);
      }
      
      private function onPuzzleCompleted(result:Object) : void
      {
         var activePuzzleId:Number = NaN;
         if(Boolean(result) && Boolean(result.success))
         {
            activePuzzleId = this.getActivePuzzleId();
            if(this.isActivePuzzleCompleted())
            {
               if(result.hasOwnProperty("puzzleReward"))
               {
                  if(this.grantRewardByName(result["puzzleReward"]))
                  {
                     this.showPuzzleCompletionRewardPopup(result["puzzleReward"]);
                     this.setFeatureOptionsKey(KEY_LAST_GRANT_ID,activePuzzleId);
                  }
               }
               if(activePuzzleId == LAST_PUZZLE_ID && result.hasOwnProperty("bonusReward"))
               {
                  if(this.grantRewardByName(result["bonusReward"]))
                  {
                     this.showBonusRewardPopup(result["bonusReward"]);
                     this.setFeatureOptionsKey(KEY_LAST_GRANT_ID,LAST_PUZZLE_ID + 1);
                  }
               }
               if(this.isFeatureinActivePeriod())
               {
                  if(result.hasOwnProperty(KEY_ACTIVE_PUZZLE))
                  {
                     this.setFeatureOptionsKey(KEY_ACTIVE_PUZZLE,result[KEY_ACTIVE_PUZZLE]);
                  }
                  if(result.hasOwnProperty(KEY_ACTIVE_PUZZLE_DATA))
                  {
                     this.setFeatureOptionsKey(KEY_ACTIVE_PUZZLE_DATA,result[KEY_ACTIVE_PUZZLE_DATA]);
                  }
               }
               if(this.m_mainWindow)
               {
                  this.m_mainWindow.updatePuzzleProgress(this.getActivePuzzleId());
               }
            }
         }
      }
      
      public function get mainWindow() : JumbleVillaMainWindow
      {
         return this.m_mainWindow;
      }
      
      public function set mainWindow(windowInstance:JumbleVillaMainWindow) : void
      {
         this.m_mainWindow = windowInstance;
      }
      
      private function showBonusRewardPopup(rewardName:String) : void
      {
         UI.displayPopup(new JumbleVillaRewardPopup(FEATURE_NAME,REWARD_DIALOG_ASSET_URL,rewardName,false,this.getCurrentFinderLevel(),true),false);
      }
      
      private function grantRewardByName(rewardName:String, count:Number = 1) : Boolean
      {
         Global.player.addGift(rewardName,"",count);
         return true;
      }
      
      private function showPuzzleCompletionRewardPopup(rewardName:String) : void
      {
         UI.displayPopup(new JumbleVillaRewardPopup(FEATURE_NAME,REWARD_DIALOG_ASSET_URL,rewardName),false);
      }
      
      public function getFeatureEndDaysLeftText() : String
      {
         var timeLeft:Number = NaN;
         timeLeft = (FarmGameUtil.synchronizedDateToNumber(this.featureEndDate) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return HUD.getformattedTimeLeft(timeLeft);
      }
      
      public function initEventListener() : void
      {
         GlobalEventManager.getInstance().addEventListener(EVENT_WW_INNOVATION_TILE_UNLOCK,this.onTileUnlocked);
      }
      
      private function onTileUnlocked(event:TileUnlockEvent = null) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onTileUnlockProgress",this.onTileUnlockProgress,[FEATURE_NAME]),true);
      }
      
      public function addTileUnlockProgress() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onTileUnlockProgress",this.onTileUnlockProgress,[FEATURE_NAME]),true);
      }
      
      private function onTileUnlockProgress(result:Object) : void
      {
         if(Boolean(result) && Boolean(result.success))
         {
            if(result.hasOwnProperty(KEY_TILES_UNLOCKED))
            {
               this.setFeatureOptionsKey(KEY_TILES_UNLOCKED,result[KEY_TILES_UNLOCKED]);
            }
            if(result.hasOwnProperty(KEY_PPH_DROP_LEVEL))
            {
               this.setFeatureOptionsKey(KEY_PPH_DROP_LEVEL,result[KEY_PPH_DROP_LEVEL]);
            }
         }
      }
      
      private function getBushelTasksFromConfig() : Vector.<FarmTask>
      {
         var cropConfig:XML = null;
         var cropTask:Object = null;
         var farmTask:FarmTask = null;
         var bushelTaskList:Vector.<FarmTask> = new Vector.<FarmTask>();
         var featureConfig:XML = this.getFeatureConfig();
         var cropsConfig:XMLList = featureConfig["crops"]["plant"];
         for each(cropConfig in cropsConfig)
         {
            cropTask = {};
            cropTask.name = String(cropConfig.@name);
            cropTask.action = String(cropConfig.@action);
            cropTask.type = String(cropConfig.@type);
            farmTask = new FarmTask(cropTask);
            bushelTaskList.push(farmTask);
         }
         return bushelTaskList;
      }
      
      private function getFeatureData() : Object
      {
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,m_featureName);
         if(!featureData)
         {
            featureData = {};
            featureData[KEY_TILES_UNLOCKED_IN_PREVIOUS_EXPANSION] = this.getTilesUnlockedPreviously();
            featureData[KEY_TILES_UNLOCKED] = 0;
            featureData[KEY_SAVED_BUSHEL_PROGRESS] = 0;
            featureData[KEY_ACTIVE_PUZZLE] = 0;
            featureData[KEY_ACTIVE_PUZZLE_DATA] = this.initPuzzleData(featureData[KEY_ACTIVE_PUZZLE]);
            featureData[KEY_CONVERTOR_PARTS_COUNT] = 0;
            featureData[KEY_CONVERTOR_PARTS_PROGRESS] = 0;
            featureData[KEY_PPH_DROP_LEVEL] = 0;
            featureData[KEY_FINDER_LEVEL] = -1;
            featureData[KEY_LAST_GRANT_ID] = -1;
            setFeatureData(featureData);
         }
         return featureData;
      }
      
      private function initPuzzleData(puzzleIndex:Number) : Object
      {
         var pieceConfig:XML = null;
         var pieceData:Object = null;
         var puzzleData:Object = {};
         var featureConfig:XML = this.getFeatureConfig();
         var puzzleConfig:XML = featureConfig["puzzles"]["puzzle"][puzzleIndex];
         puzzleData["name"] = String(puzzleConfig.@name);
         puzzleData["pieces"] = [];
         var piecesConfig:XMLList = puzzleConfig["piece"];
         for each(pieceConfig in piecesConfig)
         {
            pieceData = {};
            pieceData["name"] = String(pieceConfig.@name);
            pieceData["progress"] = 0;
            pieceData["collected"] = 0;
            pieceData["required"] = Number(pieceConfig.@total);
            puzzleData["pieces"].push(pieceData);
         }
         return puzzleData;
      }
      
      private function getTilesUnlockedPreviously() : Number
      {
         var tilesUnlockedPreviously:Number = Number(FeatureOptionsManager.getInstance().getFeatureOption("BoraBoraInnovation",KEY_TILES_UNLOCKED));
         if(!tilesUnlockedPreviously)
         {
            tilesUnlockedPreviously = 0;
         }
         return tilesUnlockedPreviously;
      }
      
      public function openCropsMiniMarket() : void
      {
         var cropConfig:XML = null;
         var cropsList:Array = [];
         var featureConfig:XML = this.getFeatureConfig();
         var cropsConfig:XMLList = featureConfig["crops"]["plant"];
         for each(cropConfig in cropsConfig)
         {
            cropsList.push(String(cropConfig.@name));
         }
         UI.displayMiniMarketDialog(cropsList,null,"seed");
      }
      
      private function getFeatureConfig() : XML
      {
         this.parseFeatureDataFromConfig(FEATURE_NAME);
         return s_config[FEATURE_CONFIG_KEY];
      }
      
      public function getActivePuzzleData() : Object
      {
         return this.getFeatureOptionsKey(KEY_ACTIVE_PUZZLE_DATA);
      }
      
      public function getPuzzleNames() : Array
      {
         var puzzleConfig:XML = null;
         var puzzleNames:Array = [];
         var featureConfig:XML = this.getFeatureConfig();
         var puzzlesConfig:XMLList = featureConfig["puzzles"]["puzzle"];
         for each(puzzleConfig in puzzlesConfig)
         {
            puzzleNames.push(String(puzzleConfig.@name));
         }
         return puzzleNames;
      }
      
      private function getFeatureOptionsKey(optionName:String) : Object
      {
         var featureData:Object = this.getFeatureData();
         return featureData[optionName];
      }
      
      private function setFeatureOptionsKey(optionName:String, optionValue:Object) : void
      {
         var featureData:Object = this.getFeatureData();
         featureData[optionName] = optionValue;
         setFeatureData(featureData);
      }
      
      public function convertExtraParts() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"convertExtraParts",this.onExtraPartsConverted,[FEATURE_NAME]),true);
      }
      
      private function onExtraPartsConverted(result:Object) : void
      {
         if(Boolean(result) && Boolean(result.success))
         {
            if(result.hasOwnProperty(KEY_ACTIVE_PUZZLE_DATA))
            {
               this.setFeatureOptionsKey(KEY_ACTIVE_PUZZLE_DATA,result[KEY_ACTIVE_PUZZLE_DATA]);
            }
            if(result.hasOwnProperty(KEY_CONVERTOR_PARTS_COUNT))
            {
               this.setFeatureOptionsKey(KEY_CONVERTOR_PARTS_COUNT,result[KEY_CONVERTOR_PARTS_COUNT]);
            }
         }
         if(this.m_mainWindow)
         {
            this.m_mainWindow.updatePuzzleProgress(this.getActivePuzzleId());
         }
      }
      
      public function isPieceCompleted(pieceIndex:int, considerProgress:Boolean) : Boolean
      {
         var pieceData:Object = this.getFeatureOptionsKey(KEY_ACTIVE_PUZZLE_DATA)["pieces"][pieceIndex];
         if(considerProgress)
         {
            return pieceData["collected"] + pieceData["progress"] >= pieceData["required"];
         }
         return pieceData["collected"] >= pieceData["required"];
      }
      
      public function isActivePuzzleCompleted(considerProgress:Boolean = false) : Boolean
      {
         var piecesData:Object = this.getFeatureOptionsKey(KEY_ACTIVE_PUZZLE_DATA)["pieces"];
         for(var i:int = 0; i < piecesData.length; i++)
         {
            if(!this.isPieceCompleted(i,considerProgress))
            {
               return false;
            }
         }
         return true;
      }
      
      public function getActivePuzzleId() : int
      {
         return int(this.getFeatureOptionsKey(KEY_ACTIVE_PUZZLE));
      }
      
      public function markPuzzleCompleted() : void
      {
         if(this.isActivePuzzleCompleted())
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"markPuzzleCompleted",this.onPuzzleCompleted,[FEATURE_NAME]),true);
         }
      }
      
      public function getPartsInConvertor() : Number
      {
         return Number(this.getFeatureOptionsKey(KEY_CONVERTOR_PARTS_COUNT));
      }
      
      public function getMinPartsNeededToConvert() : Number
      {
         return MIN_NO_OF_PARTS_REQUIRED_TO_CONVERT;
      }
      
      public function getCurrentFinderLevel() : Number
      {
         return Number(this.getFeatureOptionsKey(KEY_FINDER_LEVEL));
      }
      
      public function getConvertorProgress() : Number
      {
         return Number(this.getFeatureOptionsKey(KEY_CONVERTOR_PARTS_PROGRESS));
      }
      
      private function resetActivePopupCount() : void
      {
         this.m_activePopupCount = 0;
      }
      
      public function incrementActivePopupCount() : void
      {
         this.m_activePopupCount += 1;
      }
      
      public function decrementActivePopupCount() : void
      {
         this.m_activePopupCount = this.m_activePopupCount - 1 > 0 ? int(this.m_activePopupCount - 1) : 0;
      }
      
      public function canUntintMainWindow() : Boolean
      {
         return this.m_activePopupCount == 0;
      }
      
      public function highlightTiles() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
         UI.displayMiniMarketDialog(getLockedTiles(),null,"seed",null,true,false,false,true);
      }
      
      public function changeActiveTab(clickedTab:int) : void
      {
         if(Boolean(this.m_mainWindow) && clickedTab <= this.getActivePuzzleId())
         {
            this.m_mainWindow.updatePuzzleProgress(clickedTab);
         }
      }
      
      public function getLastPuzzleId() : int
      {
         return LAST_PUZZLE_ID;
      }
      
      public function updateFinderLevel() : void
      {
         var currentPPHDropLevel:Number = Number(this.getFeatureOptionsKey(KEY_PPH_DROP_LEVEL));
         this.setFeatureOptionsKey(KEY_FINDER_LEVEL,currentPPHDropLevel);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"updateFinderLevel",null,[FEATURE_NAME]),true);
      }
      
      public function hasFinderUpgraded() : Boolean
      {
         var currentPPHDropLevel:Number = Number(this.getFeatureOptionsKey(KEY_PPH_DROP_LEVEL));
         var finderLevel:Number = Number(this.getFeatureOptionsKey(KEY_FINDER_LEVEL));
         return currentPPHDropLevel > finderLevel;
      }
      
      public function isConvertorReady() : Boolean
      {
         var partsInConvertor:Number = Number(this.getFeatureOptionsKey(KEY_CONVERTOR_PARTS_COUNT));
         return partsInConvertor >= MIN_NO_OF_PARTS_REQUIRED_TO_CONVERT;
      }
      
      public function getTilesRequiredForFinderLevel(level:Number) : Number
      {
         var tilesUnlockedPreviously:Number = Number(this.getFeatureOptionsKey(KEY_TILES_UNLOCKED_IN_PREVIOUS_EXPANSION));
         var tilesUnlocked:Number = Number(this.getFeatureOptionsKey(KEY_TILES_UNLOCKED));
         var tilesRequired:Number = 0;
         if(level == 0)
         {
            return tilesRequired;
         }
         return Math.max(0,tilesUnlockedPreviously + level - 1 - tilesUnlocked);
      }
      
      public function isFeatureCompleted() : Boolean
      {
         var lastRewardGrantId:Number = Number(this.getFeatureOptionsKey(KEY_LAST_GRANT_ID));
         return lastRewardGrantId >= LAST_PUZZLE_ID;
      }
      
      public function isInStoryMode() : Boolean
      {
         return FarmGameUtil.checkDateGate(this.featureEndDate,this.storyEndDate);
      }
      
      public function get featureStartDate() : String
      {
         return DATE_FEATURE_START;
      }
      
      public function get featureEndDate() : String
      {
         return DATE_FEATURE_END;
      }
      
      public function get storyEndDate() : String
      {
         return DATE_STORY_END;
      }
      
      public function getPagesCompletedByUser() : Number
      {
         return Math.min(Number(this.getFeatureOptionsKey(KEY_LAST_GRANT_ID)),LAST_PUZZLE_ID) + 1;
      }
   }
}

