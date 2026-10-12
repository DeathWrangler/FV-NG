package Managers
{
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.Idle.GenericToasterIdleTask;
   import Classes.Idle.IdleTaskQueue;
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.AntiqueMuseumV2CollectionWindow;
   import Widgets.Windows.AntiqueMuseumV2ConsumableFoundWindow;
   import Widgets.Windows.AntiqueMuseumV2ForceAddPartsWindow;
   import Widgets.Windows.AntiqueMuseumV2LevelCompletedWindow;
   import Widgets.Windows.AntiqueMuseumV2MainWindow;
   import Widgets.Windows.AntiqueMuseumV2MilestoneRewardWindow;
   import Widgets.Windows.AntiqueMuseumV2SurveyMapWindow;
   import Widgets.Windows.AntiqueMuseumV2TosterWindow;
   import Widgets.Windows.ConsumableToasterWindow;
   import Widgets.Windows.GenericSingleRewardPopup;
   import Widgets.Windows.MOTD.AntiqueMuseumV2MOTDWindow;
   import Widgets.Windows.Market.MarketWindow;
   import flash.events.Event;
   
   public class AntiqueMuseumV2Manager extends BaseFeatureManager
   {
      
      private static var m_initialized:Boolean = false;
      
      public static const FEATURE_TRACKING:String = "AntiqueMuseumV2";
      
      private static const SERVICE_NAME:String = "AntiqueMuseumV2Service";
      
      private static const PPH_SERVICE_CALL:String = "checkAndGrantPPHDrop";
      
      private static const UPDATE_BUSHEL_PROGRESS:String = "updateBushelProgress";
      
      private static const TOTAL_TILEWEIGHT:Number = 50;
      
      private static const KEY_SAVED_ACTIVE_ORDERS:String = "activeOrders";
      
      private static const KEY_ORDER_SEQUENCE:String = "order_sequence";
      
      private static const INITIAL_PIECE_LIST:Array = ["xcd_prehistorictoolsstone","xcd_fossiltyrannosaurus","xcd_plesiosaurusfossil"];
      
      private static const BONUS_HARVEST_COUNT:String = "hc_";
      
      private static const SERVICE_FUNC_HARVEST_BONUS:String = "harvestDecos";
      
      public static const DEFAULT_HARVEST_THROTTLE_TIME:int = 86400;
      
      public static const DEFAULT_COLLECT_THROTTLE_TIME:int = 86400;
      
      private static var m_harvestHitCount:int = 0;
      
      private static var m_isTaskComplete:int = 0;
      
      private static var m_selectedTile:String = null;
      
      public static const AMV2MOTD_SEEN:String = "amv2motd_seen";
      
      protected static var m_instance:Object = {};
      
      public static const FEATURE_NAME:String = "AntiqueMuseumV2";
      
      private var m_assetPaths:Object = null;
      
      private const KEY_SAVED_BUSHEL_PROGRESS:String = "saved_bushel_progress";
      
      private const KEY_COMPLETED_PIECES:String = "completed";
      
      private const KEY_MILESTONE_REWARDS:String = "milestone_rewards";
      
      private const KEY_FEATURE_ENDED:String = "feature_end";
      
      private const KEY_GRANT_ARRAY_INDEX:String = "index";
      
      private const KEY_TILE_WEIGHT:String = "tile_weight";
      
      public const KEY_SAVED_ACTIVE_PIECES:String = "saved_active_pieces";
      
      public const KEY_TEMP_SUBPARTS_PROGRESS:String = "temp_subparts_progress";
      
      public const KEY_SAVED_SUBPARTS_PROGRESS:String = "saved_subparts_progress";
      
      public const KEY_GRANT_PPH:String = "antique_musuem_grant_pph";
      
      public const KEY_PPH_GRANT_ONLY:String = "pph_only";
      
      public const PPH_GRANTED:String = "pph_grant";
      
      public const KEY_PIECES_PROGRESS:String = "saved_pieces_progress";
      
      private const KEY_RANDOM_COUNT:String = "random";
      
      private const KEY_REWARD_GRANTED:String = "reward_given";
      
      public const KEY_ORDER_SEQUENCE:String = "order_sequence";
      
      public const ANTIQUE_MESUEM_INDEX:String = "ami";
      
      public const PARTS_PER_PIECE:int = 20;
      
      public const MAX_SUBPARTS_COUNT:int = 100;
      
      public const GRANT_PARTS_ON_BUY:int = 5;
      
      public const COST_PER_PACK:int = 4;
      
      public const KEY_TILE_UNLOCK_COUNT:String = "tile_unlock_count";
      
      private var m_allItemsInOrder:Array = ["xcd_prehistorictoolsstone","xcd_fossiltyrannosaurus","xcd_plesiosaurusfossil","xcd_ankylosaurusfossil","xcd_fossilmastodon","xcd_paintingprehistrioc","xcd_amberfossilset","xcd_fossilmegalonyx","xcd_ancientseafloorfossil"];
      
      private var m_marketItems:Array = ["xcd_canadianbloodroot","xcd_summerbearberry","xcd_burgundyaster","xcd_canadacolumbine","xcd_commonbluet","xcd_ontarioliatris","xcd_mountainmilkweed","xcd_annapolisapple","xcd_bartlettpear","xcd_sundewprune","xcd_valleyraspberry","xcd_calgaryapricot","xcd_honeyberrygrapes","xcd_quebecplum","xcd_crescentbroccoli","xcd_brunswickblueberry","xcd_canadiansweetcorn","xcd_yohoonion"];
      
      public var m_marketTilesItems:Array = ["xcd_rubbletreasure1","xcd_rubbletreasure2","xcd_rubbletreasure3","xcd_rubbletreasure4","xcd_rubbletreasure5","xcd_rubbletreasure6","xcd_rubbletreasure7","xcd_rubbletreasure8","xcd_rubbletreasure9","xcd_rubbletreasure_payer1","xxcd_rubbletreasure_payer2","xcd_rubbletreasure_payer3","xcd_rubbletreasure_payer4","xcd_rubbletreasure_payer5","xcd_rubbletreasure_payer6","xcd_rubbletreasure_payer7","xcd_rubbletreasure_payer8","xcd_rubbletreasure_payer9","xcd_rubbletreasure_payer10","xcd_rubbletreasure_payer11","xcd_rubbletreasure_payer12","xcd_rubbletreasure_payer13","xcd_rubbletreasure_payer14","xcd_rubbletreasure_payer15","xcd_rubbletreasure_payer16","xcd_rubbletreasure_payer17","xcd_rubbletreasure_payer18","xcd_rubbletreasure_payer19","xcd_rubbletreasure_payer20","xcd_rubbletreasure_payer21"];
      
      private const REWARD_FARM_ESSENTIALS:String = "pkg_antique_farm_essentials";
      
      private var m_marketWindow:MarketWindow = null;
      
      private var m_antiqueFiction:AntiqueMuseumV2MOTDWindow;
      
      public var m_consumableMapping:Object = {
         "PrehistoricStoneToolsStage":"PrehistoricStoneTools_icon_50.png",
         "TyrannosaurusFossilStage":"Tyrannosaurus_icon_50.png",
         "PlesiosaurusFossilStage":"Plesiosaurus_icon_50.png",
         "AnkylosaurusFossilStage":"Ankylosaurus_icon_50.png",
         "FossilmastodonStage":"Mastodon_icon_50.png",
         "PrehistriocPaintingStage":"Paintingprehistrioc_icon_50.png",
         "AmberFossilSetStage":"AmberFossilSet_icon_50.png",
         "MegalonyxFossilStage":"Megalonyx_icon_50.png",
         "AncientSeaFloorFossilStage":"AncientSeaFloor_icon_50.png"
      };
      
      public var m_consumableCodeMapping:Object = {
         "xcd_prehistorictoolsstone":"PrehistoricStoneTools",
         "xcd_fossiltyrannosaurus":"Tyrannosaurus",
         "xcd_plesiosaurusfossil":"Plesiosaurus",
         "xcd_ankylosaurusfossil":"Ankylosaurus",
         "xcd_fossilmastodon":"Mastodon",
         "xcd_paintingprehistrioc":"Paintingprehistrioc",
         "xcd_amberfossilset":"AmberFossilSet",
         "xcd_fossilmegalonyx":"Megalonyx",
         "xcd_ancientseafloorfossil":"AncientSeaFloor"
      };
      
      public var m_consumableCodeNameMapping:Object = {
         "xcd_prehistorictoolsstone":"Prehistoric Stone Tools",
         "xcd_fossiltyrannosaurus":"Tyrannosaurus Fossil",
         "xcd_plesiosaurusfossil":"Plesiosaurus Fossil",
         "xcd_ankylosaurusfossil":"Ankylosaurus Fossil",
         "xcd_fossilmastodon":"Mastodon Fossil",
         "xcd_paintingprehistrioc":"Prehistoric Painting",
         "xcd_amberfossilset":"Amber Fossil Set",
         "xcd_fossilmegalonyx":"Megalonyx Fossil",
         "xcd_ancientseafloorfossil":"Ancient Sea Floor Fossil"
      };
      
      private const ANTIQUE_PIECES_ARRAY:Array = ["lp09","dlwc","bmx0","thm5","uv52","gz1k","26mu"];
      
      public const LAST_HARVEST_TIME_KEY:String = "_lastHarvestTimeKey";
      
      public var BONUS_HARVEST_MAP:Object = {"xcd_naturalhistorymuseum":new Array("consume_instagrow","pkg_xcd_bigbuildable_sidecar_pack","consume_turbo_charger","consume_unwither","consume_organic_fertilizer","fuel1","vehiclepart","pkg_xcd_treasurepart_sidecar_pack","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard")};
      
      private const REWARD_POPUP_WINDOW:String = "assets/dialogs/expansion/FV_RewardDialog.swf";
      
      private const REWARD_WINDOW_IMAGE:String = "assets/dialogs/canada/RewardDialog.png";
      
      private const KEY_BONUS_HARVEST_START_TIME:String = "bonus_harvest_start_time";
      
      private var m_grantProbArray:Array;
      
      private var m_currentProbArray:Array = new Array(100);
      
      private const KEY_SEEN_FTUE:String = "antique_museum_v2_ftue_seen";
      
      protected var m_featureConfigData:Object;
      
      public var m_mainWindow:AntiqueMuseumV2MainWindow;
      
      public var m_levelCompleteRewardPopup:AntiqueMuseumV2LevelCompletedWindow;
      
      public var m_forceAddPartsPopup:AntiqueMuseumV2ForceAddPartsWindow;
      
      public var m_milestoneRewardPopup:AntiqueMuseumV2MilestoneRewardWindow;
      
      public var m_antiquePieceFoundPopup:AntiqueMuseumV2ConsumableFoundWindow;
      
      private var m_collectionWindow:AntiqueMuseumV2CollectionWindow;
      
      private var m_surveyMapWindow:AntiqueMuseumV2SurveyMapWindow;
      
      private var m_bundleFirstTile:String = "xid_special_tile";
      
      private var m_tilesByName:Object;
      
      private var m_cropsByName:Object;
      
      private var m_piecesByName:Object;
      
      private var m_toasterHud:ConsumableToasterWindow;
      
      private var m_piecesByIndex:Object;
      
      private var m_bushelTasklist:Vector.<FarmTask>;
      
      private var totalTileCost:int = 0;
      
      public function AntiqueMuseumV2Manager(featureName:String)
      {
         super(featureName);
         this.parseFeatureDataFromConfig(FEATURE_NAME);
         this.m_featureConfigData = new Object();
         this.startQuest();
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
      }
      
      public static function getInstance(featureName:String = "AntiqueMuseumV2") : AntiqueMuseumV2Manager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,AntiqueMuseumV2Manager) as AntiqueMuseumV2Manager;
      }
      
      public static function getMilestoneNumberByName(name:String) : int
      {
         if(name == "unicorn_xcd_bluejacket")
         {
            return 1;
         }
         if(name == "pegasus_xcd_canadianmaplepenasus")
         {
            return 3;
         }
         if(name == "pegacorn_xcd_canadiantraditional")
         {
            return 6;
         }
         return 9;
      }
      
      public static function getTimeLeft(key:String, throttleTime:int = 86400) : int
      {
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         return int(throttleTime - timeSinceLastFeed);
      }
      
      private static function isAntiqueMuseumV2Active() : Boolean
      {
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("antique_museum_v2_feature_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            if(Boolean(AntiqueMuseumV2Manager.getInstance()) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_CANADA)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function getInnovationFeatureName() : String
      {
         return FEATURE_NAME;
      }
      
      public function setupNeighborBarHud() : void
      {
         var seenToaster:Function = function(event:Event):void
         {
         };
         this.m_toasterHud = new ConsumableToasterWindow("Antique Museum","Antique Museum",this.hudURL,this.onClickToaster,5000);
         this.m_toasterHud.addEventListener(ToasterManager.DISPLAYED_EVENT,seenToaster);
         IdleTaskQueue.getInstance().addTask(new GenericToasterIdleTask(this.m_toasterHud,30000));
      }
      
      public function showToasterHud() : void
      {
         var toaster:AntiqueMuseumV2TosterWindow = new AntiqueMuseumV2TosterWindow("Natural History Museum","Natural History Museum",this.hudURL,this.onClickToaster,3000);
         ToasterManager.getInstance().add(toaster);
      }
      
      public function onClickToaster() : void
      {
         this.showMainWindow();
      }
      
      public function getFeatureData() : Object
      {
         var crop:XML = null;
         var piece:XML = null;
         var i:int = 0;
         var j:int = 0;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,FEATURE_NAME);
         if(!featureData)
         {
            featureData = {};
            featureData[this.KEY_SAVED_BUSHEL_PROGRESS] = {};
            for each(crop in this.m_cropsByName)
            {
               featureData[this.KEY_SAVED_BUSHEL_PROGRESS][crop.@name] = 0;
            }
            featureData[this.KEY_PIECES_PROGRESS] = {};
            featureData[this.KEY_TEMP_SUBPARTS_PROGRESS] = {};
            featureData[this.KEY_SAVED_SUBPARTS_PROGRESS] = {};
            featureData[this.KEY_COMPLETED_PIECES] = new Array();
            featureData[this.KEY_MILESTONE_REWARDS] = new Array();
            featureData[this.KEY_PPH_GRANT_ONLY] = new Array();
            featureData[this.KEY_REWARD_GRANTED] = {};
            for each(piece in this.m_piecesByName)
            {
               featureData[this.KEY_PIECES_PROGRESS][piece.@name] = 0;
               featureData[this.KEY_TEMP_SUBPARTS_PROGRESS][piece.@name] = 0;
               featureData[this.KEY_SAVED_SUBPARTS_PROGRESS][piece.@name] = 0;
               featureData[this.KEY_REWARD_GRANTED][piece.@name] = 0;
            }
            for(i = 0; i < 3; i++)
            {
               featureData[this.KEY_PPH_GRANT_ONLY][i] = 0;
            }
            for(j = 0; j < 4; j++)
            {
               featureData[this.KEY_MILESTONE_REWARDS][j] = 0;
            }
            featureData[this.KEY_GRANT_ARRAY_INDEX] = 0;
            featureData[this.KEY_TILE_WEIGHT] = 0;
            featureData[this.KEY_RANDOM_COUNT] = 0;
            featureData[this.KEY_FEATURE_ENDED] = false;
            featureData[this.KEY_SAVED_ACTIVE_PIECES] = INITIAL_PIECE_LIST;
            featureData[this.KEY_TILE_UNLOCK_COUNT] = 0;
            featureData[KEY_SAVED_ACTIVE_ORDERS] = {};
            featureData[this.KEY_ORDER_SEQUENCE] = 3;
            featureData[this.ANTIQUE_MESUEM_INDEX] = 0;
            setFeatureData(featureData);
         }
         return featureData;
      }
      
      public function getCurrentTileWeight() : int
      {
         var tileData:XML = null;
         var weight:int = 5;
         var tileLockedCount:Number = 0;
         for each(tileData in this.m_tilesByName)
         {
            if(Global.world.getObjectsByName(tileData.@name).length <= 0)
            {
               weight += int(tileData.@weight);
               tileLockedCount++;
            }
         }
         return weight;
      }
      
      public function getCurrentTileWeightBar() : int
      {
         var tileData:XML = null;
         var weight:int = 0;
         var tileLockedCount:Number = 0;
         for each(tileData in this.m_tilesByName)
         {
            if(Global.world.getObjectsByName(tileData.@name).length <= 0)
            {
               weight += int(tileData.@weight);
               tileLockedCount++;
            }
         }
         return weight;
      }
      
      public function getCurrentTileBrought() : int
      {
         var tileData:XML = null;
         var tileLockedCount:Number = 0;
         for each(tileData in this.m_tilesByName)
         {
            if(Global.world.getObjectsByName(tileData.@name).length <= 0)
            {
               tileLockedCount++;
            }
         }
         return tileLockedCount;
      }
      
      public function getPPHGrantArrayIndex() : int
      {
         var featureObject:Object = this.getFeatureData();
         return featureObject[this.KEY_GRANT_ARRAY_INDEX];
      }
      
      public function generateGrantArrayString() : Array
      {
         var toAdd:int = 0;
         var j:int = 0;
         var arrayToReturn:Array = new Array();
         var halfWayArray:Array = new Array();
         var initialArray:Array = new Array();
         for(var i:int = 0; i < 100; i++)
         {
            initialArray.push(0);
            if(i % 2 == 0)
            {
               halfWayArray.push(1);
            }
            else
            {
               halfWayArray.push(0);
            }
         }
         var weight:int = this.getCurrentTileWeight();
         var index:int = 0;
         if(weight <= 50)
         {
            initialArray[0] = 1;
            toAdd = 100 / weight;
            j = 0;
            for(j = 0; j < weight - 1; j++)
            {
               index += toAdd;
               if(index <= 99)
               {
                  initialArray[index] = 1;
               }
            }
            arrayToReturn = initialArray;
         }
         else
         {
            halfWayArray[0] = 1;
            toAdd = 100 / weight;
            j = 0;
            for(j = 0; j < weight - 1; j++)
            {
               index += toAdd;
               if(index <= 99)
               {
                  if(halfWayArray[index] == 1 && index + 1 <= 99)
                  {
                     halfWayArray[index + 1] = 1;
                  }
                  else if(halfWayArray[index] == 0)
                  {
                     halfWayArray[index] = 1;
                  }
               }
            }
            arrayToReturn = halfWayArray;
         }
         this.m_grantProbArray = arrayToReturn;
         return arrayToReturn;
      }
      
      public function isUserEligibleForPPHGrant() : Boolean
      {
         var chanceArray:Array = null;
         var shouldGrant:Boolean = false;
         var featureObject:Object = this.getFeatureData();
         var currWeight:int = this.getCurrentTileWeight();
         if(!this.m_grantProbArray)
         {
            this.m_grantProbArray = new Array(100);
            this.m_grantProbArray = this.generateGrantArrayString();
         }
         var weight:int = int(featureObject[this.KEY_TILE_WEIGHT]);
         if(currWeight > weight)
         {
            featureObject[this.KEY_TILE_WEIGHT] = currWeight;
            featureObject[this.KEY_GRANT_ARRAY_INDEX] = 0;
            chanceArray = this.generateGrantArrayString();
            setFeatureData(featureObject);
         }
         else
         {
            chanceArray = this.m_grantProbArray;
         }
         var currfeatureObject:Object = this.getFeatureData();
         var index:int = currfeatureObject[this.KEY_GRANT_ARRAY_INDEX] % 100;
         if(chanceArray[index] == 1)
         {
            shouldGrant = true;
         }
         currfeatureObject[this.KEY_GRANT_ARRAY_INDEX] += 1;
         setFeatureData(currfeatureObject);
         return shouldGrant;
      }
      
      public function areAllTilesUnlocked() : Boolean
      {
         var weight:int = this.getCurrentTileWeight();
         var isAllUnlocked:Boolean = false;
         if(weight >= 100)
         {
            isAllUnlocked = true;
         }
         return isAllUnlocked;
      }
      
      public function getStatusByWeight(weight:int) : int
      {
         var res:int = 0;
         if(weight >= 80)
         {
            res = 4;
         }
         else if(weight >= 50)
         {
            res = 3;
         }
         else if(weight >= 30)
         {
            res = 2;
         }
         else if(weight >= 20)
         {
            res = 1;
         }
         else if(weight >= 4)
         {
            res = 0;
         }
         return res;
      }
      
      protected function onTransactionAdded(event:TransactionEvent) : void
      {
         if(isAntiqueMuseumV2Active())
         {
            this.checkForTaskUpdates(event);
         }
      }
      
      public function getFeatureOptionsKey(optionName:String) : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,optionName);
      }
      
      public function startQuest(callback:Function = null) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startQuest",null,[FEATURE_NAME]),true);
      }
      
      private function onInitQuestComplete(callback:Function, result:Object) : void
      {
         var savedactiveTasksKey:String = this.KEY_SAVED_BUSHEL_PROGRESS;
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
            this.saveFeatureOptionsKey(savedactiveTasksKey,result["activeTasks"]);
            if(Boolean(callback))
            {
               callback.call();
            }
         }
         if(this.mainWindow)
         {
            this.mainWindow.refreshWindow();
         }
      }
      
      public function saveFeatureOptionsKey(optionName:String, optionsValue:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,optionName,optionsValue);
      }
      
      protected function parseFeatureDataFromConfig(questName:String) : void
      {
         var tilesConfig:XML = null;
         var tile:XML = null;
         var piece:XML = null;
         var plant:XML = null;
         tilesConfig = Global.farmGameSettingsManager.getXML().AntiqueMuseumV2FeatureConfig.AntiqueMuseumV2ConfigData.(@name == questName)[0];
         if(tilesConfig.hasOwnProperty("TilesConfigData"))
         {
            this.m_tilesByName = {};
            this.m_cropsByName = {};
            this.m_piecesByName = {};
            this.m_piecesByIndex = {};
            for each(tile in tilesConfig["TilesConfigData"]["tile"])
            {
               this.m_tilesByName[tile.@name] = tile;
            }
         }
         if(tilesConfig.hasOwnProperty("piecesData"))
         {
            for each(piece in tilesConfig["piecesData"]["piece"])
            {
               this.m_piecesByName[piece.@name] = piece;
               this.m_piecesByIndex[piece.@count] = piece;
            }
         }
         if(tilesConfig.hasOwnProperty("CropConfigData"))
         {
            for each(plant in tilesConfig["CropConfigData"]["plant"])
            {
               this.m_cropsByName[plant.@name] = plant;
            }
         }
      }
      
      public function getTileData(tileName:String) : XML
      {
         if(this.m_tilesByName)
         {
            return this.m_tilesByName[tileName];
         }
         return null;
      }
      
      public function getPiecesData(pieceName:String) : XML
      {
         if(this.m_piecesByName)
         {
            return this.m_piecesByName[pieceName];
         }
         return null;
      }
      
      public function getCropData(cropName:String) : XML
      {
         if(this.m_cropsByName)
         {
            return this.m_cropsByName[cropName];
         }
         return null;
      }
      
      public function getCropCountRequired(cropName:String) : Number
      {
         var cropData:XML = this.getCropData(cropName);
         return cropData.@count;
      }
      
      public function getTileWeight(tileName:String) : Number
      {
         var tileData:XML = this.getTileData(tileName);
         return tileData.@weight;
      }
      
      public function getTileCost(tileName:String) : Number
      {
         var tileData:XML = this.getTileData(tileName);
         return tileData.@cost;
      }
      
      public function getPieceId(pieceName:String) : Number
      {
         var pieceData:XML = this.getPiecesData(pieceName);
         return pieceData.@count;
      }
      
      public function shouldFeatureContinue() : Boolean
      {
         var tileData:XML = null;
         var result:Boolean = false;
         var tileLockedCount:Number = 0;
         for each(tileData in this.m_tilesByName)
         {
            if(Global.world.getObjectsByName(tileData.@name).length > 0)
            {
               tileLockedCount++;
            }
         }
         if(tileLockedCount >= 4)
         {
            result = true;
         }
         return result;
      }
      
      public function get mainWindow() : AntiqueMuseumV2MainWindow
      {
         return this.m_mainWindow;
      }
      
      public function showAntiqueFiction() : *
      {
         Global.player.setSeenFlag("AntiqueMuseumV2_FictionSeen");
         this.m_antiqueFiction = new AntiqueMuseumV2MOTDWindow(AntiqueMuseumV2Manager.FEATURE_NAME,this.fictionURL);
         UI.displayPopup(this.m_antiqueFiction,false);
         StatsManager.count(FEATURE_TRACKING,"mainui_fiction","open");
      }
      
      public function showMainWindow() : void
      {
         if(!Global.player.getSeenFlag("AntiqueMuseumV2_FictionSeen"))
         {
            this.showAntiqueFiction();
         }
         else if(this.isFeatureCompleted())
         {
            this.showCollectionUI();
         }
         else
         {
            this.m_mainWindow = new AntiqueMuseumV2MainWindow("AntiqueMuseumV2MainWindow","assets/dialogs/JulySideCarFeature_CanadianMuseum/FV_MainScreen_CanadianMuseum.swf",false);
            UI.displayPopup(this.m_mainWindow,false);
            StatsManager.count(FEATURE_TRACKING,"mainui","open");
         }
      }
      
      public function checkPopUps() : void
      {
         if(this.shouldShowForceAddPopup())
         {
            if(this.m_mainWindow)
            {
               this.m_mainWindow.tintWindow();
               this.m_mainWindow.enableInput = false;
            }
            this.showForceAddPopup();
         }
         if(this.shouldShowPPHGrantPopup())
         {
            if(this.m_mainWindow)
            {
               this.m_mainWindow.tintWindow();
               this.m_mainWindow.enableInput = false;
            }
            this.showFoundConsumablePopup();
         }
      }
      
      private function resetPPHGrantData(event:Event = null) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.untintWindow();
            this.m_mainWindow.enableInput = true;
         }
         if(this.m_antiquePieceFoundPopup)
         {
            this.m_antiquePieceFoundPopup.close();
         }
         this.resetPPHCount();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"resetPPHGrantData",null,[m_featureName]),true);
      }
      
      private function resetPPHCount() : void
      {
         var featureObject:Object = this.getFeatureData();
         for(var i:int = 0; i < 3; i++)
         {
            featureObject[this.KEY_PPH_GRANT_ONLY][i] = 0;
         }
         setFeatureData(featureObject);
      }
      
      public function showAntiqueCompletedPopup(pieceName:String) : void
      {
         var item:FarmItem = null;
         var featureObject:Object = this.getFeatureData();
         if(featureObject[this.KEY_REWARD_GRANTED][pieceName] == 0)
         {
            featureObject[this.KEY_REWARD_GRANTED][pieceName] = 1;
            setFeatureData(featureObject);
            Global.player.addGift(pieceName,"",1);
            Global.player.addGift(this.REWARD_FARM_ESSENTIALS,"",1);
            item = Global.farmGameSettingsManager.getFarmItemByName(pieceName);
            if(item)
            {
               this.m_levelCompleteRewardPopup = new AntiqueMuseumV2LevelCompletedWindow(this.levelCompletedURL,m_featureName,item,this.closeLevelCompletedPopup,"assets/dialogs/ireland/RewardDialog.png",item.iconUrl,item.name);
               UI.displayPopup(this.m_levelCompleteRewardPopup,false);
            }
         }
      }
      
      public function onFetchFeatureData(result:Object) : void
      {
         this.updatePiecesData(result);
      }
      
      public function updatePiecesData(result:Object) : void
      {
         var featureData:Object = null;
         var milestoneName:String = null;
         var completedPiecesCount:int = 0;
         if(result)
         {
            featureData = this.getFeatureData();
            if(result["featureData"])
            {
               featureData[this.KEY_SAVED_ACTIVE_PIECES] = result[this.KEY_SAVED_ACTIVE_PIECES];
               if(result[this.KEY_ORDER_SEQUENCE])
               {
                  featureData[this.KEY_ORDER_SEQUENCE] = result[this.KEY_ORDER_SEQUENCE];
               }
               if(result[this.KEY_FEATURE_ENDED])
               {
                  featureData[this.KEY_FEATURE_ENDED] = result[this.KEY_FEATURE_ENDED];
               }
               if(result[this.KEY_MILESTONE_REWARDS])
               {
                  featureData[this.KEY_MILESTONE_REWARDS] = result[this.KEY_MILESTONE_REWARDS];
               }
               if(result[this.KEY_COMPLETED_PIECES])
               {
                  featureData[this.KEY_COMPLETED_PIECES] = result[this.KEY_COMPLETED_PIECES];
               }
               if(result.hasOwnProperty(this.KEY_BONUS_HARVEST_START_TIME))
               {
                  featureData[this.KEY_BONUS_HARVEST_START_TIME] = result[this.KEY_BONUS_HARVEST_START_TIME];
               }
               setFeatureData(featureData);
               if(this.m_mainWindow)
               {
                  this.m_mainWindow.m_piecesFrame.refresh();
               }
            }
            if(result["milestone"])
            {
               milestoneName = result["milestone"];
               completedPiecesCount = this.getNumberofCompletedPieces();
               StatsManager.count(FEATURE_TRACKING,"item_complete","milestone",completedPiecesCount.toString(),milestoneName);
               this.showMilestonePopup(result["milestone"]);
            }
         }
      }
      
      public function showMilestonePopup(name:String) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(name);
         if(item)
         {
            Global.player.addGift(name,"",1);
            this.m_milestoneRewardPopup = new AntiqueMuseumV2MilestoneRewardWindow(this.levelCompletedURL,m_featureName,item,this.onMilestoneRewardShare(item),"assets/dialogs/spooky/RewardDialog.png",item.iconUrl,name,true);
         }
         UI.displayPopup(this.m_milestoneRewardPopup,false);
      }
      
      public function closeMainWindow(event:Event) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
      }
      
      public function onMilestoneRewardShare(rewardItem:FarmItem) : Function
      {
         return function(event:Event):void
         {
            var bundleId:* = undefined;
            var windowName:* = FEATURE_NAME;
            if(rewardItem.name == "xcd_naturalhistorymuseum")
            {
               bundleId = windowName + "FinalRewardShare";
            }
            else
            {
               bundleId = windowName + "MilestoneShare";
            }
            var imageIcon:* = rewardItem.iconUrl;
            var bundleData:* = {
               "images":[{
                  "href":"{SN_APP_URL}",
                  "src":imageIcon
               }],
               "user":Global.player.name,
               "first_name":Global.player.firstName,
               "item":rewardItem.friendlyTitle,
               "number":getMilestoneNumberByName(rewardItem.name)
            };
            GlobalEngine.socialNetwork.publishFeedStory(bundleId,bundleData,[],false,null);
            if(m_milestoneRewardPopup)
            {
               m_milestoneRewardPopup.close();
            }
         };
      }
      
      public function closeLevelCompletedPopup(event:Event) : *
      {
         if(this.m_levelCompleteRewardPopup)
         {
            this.m_levelCompleteRewardPopup.close();
         }
      }
      
      public function closeAllWindows(event:Event) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.untintWindow();
            this.m_mainWindow.enableInput = true;
         }
         if(this.m_forceAddPartsPopup)
         {
            this.m_forceAddPartsPopup.close();
         }
      }
      
      public function pushPieceToCompletedList(pieceName:String) : void
      {
         var completedList:Array = this.getCompletedPiecesList();
         completedList.push(pieceName);
         var featureData:Object = this.getFeatureData();
         featureData[this.KEY_COMPLETED_PIECES] = completedList;
         if(completedList.length == 9)
         {
            featureData[this.KEY_FEATURE_ENDED] = true;
            FarmStatsManager.count(FEATURE_TRACKING,"","feature_end");
            if(this.m_mainWindow)
            {
               this.m_mainWindow.refreshPlantButtonVisibility();
            }
         }
         setFeatureData(featureData);
      }
      
      public function isFeatureCompleted() : Boolean
      {
         var featureData:Object = this.getFeatureData();
         return featureData[this.KEY_FEATURE_ENDED];
      }
      
      public function isMilestoneAchieved(count:int) : Boolean
      {
         var milestoneData:* = this.getMilestoneData();
         return milestoneData[count];
      }
      
      public function getMilestoneData() : Array
      {
         var featureData:Object = this.getFeatureData();
         return featureData[this.KEY_MILESTONE_REWARDS];
      }
      
      public function updateAntiquePartProgress(pieceName:String) : void
      {
         var completedCount:int = 0;
         var featureObject:Object = this.getFeatureData();
         featureObject[this.KEY_SAVED_SUBPARTS_PROGRESS][pieceName] = featureObject[this.KEY_TEMP_SUBPARTS_PROGRESS][pieceName];
         var stage:int = this.getCurrentStage(pieceName);
         var currCount:int = int(featureObject[this.KEY_TEMP_SUBPARTS_PROGRESS][pieceName]);
         var grantCount:int = this.getNumberOfPartsGrantedByName(pieceName);
         StatsManager.count(FEATURE_TRACKING,"addpart",pieceName,stage.toString(),currCount.toString(),"",grantCount);
         setFeatureData(featureObject);
         this.checkAndUpdateStage(pieceName);
         if(this.getCurrentStage(pieceName) == 5)
         {
            if(this.m_mainWindow)
            {
               this.m_mainWindow.tintWindow();
               this.m_mainWindow.enableInput = false;
            }
            this.showAntiqueCompletedPopup(pieceName);
            completedCount = this.getNumberofCompletedPieces();
            StatsManager.count(FEATURE_TRACKING,"item_complete",pieceName,completedCount.toString(),pieceName + "FarmEssentials");
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"fetchFeatureData",this.onFetchFeatureData,[m_featureName]),true);
         }
         else if(this.m_mainWindow)
         {
            this.m_mainWindow.refreshPiecesFrame();
         }
      }
      
      public function getSubpartsProgress(pieceName:String) : int
      {
         var featureObject:Object = this.getFeatureData();
         return featureObject[this.KEY_SAVED_SUBPARTS_PROGRESS][pieceName];
      }
      
      public function getCurrentStage(pieceName:String) : int
      {
         var featureObject:Object = this.getFeatureData();
         return featureObject[this.KEY_PIECES_PROGRESS][pieceName];
      }
      
      public function getOrderSequence() : int
      {
         var featureObject:Object = this.getFeatureData();
         return featureObject[this.KEY_ORDER_SEQUENCE];
      }
      
      public function getSubpartsRequiredToComplete(pieceName:String) : int
      {
         var featureObject:Object = this.getFeatureData();
         var count:int = this.MAX_SUBPARTS_COUNT - featureObject[this.KEY_SAVED_SUBPARTS_PROGRESS][pieceName];
         if(count < 0)
         {
            count = 0;
         }
         return count;
      }
      
      public function getTempPartsRequiredToComplete(pieceName:String) : int
      {
         var featureObject:Object = this.getFeatureData();
         return int(this.MAX_SUBPARTS_COUNT - featureObject[this.KEY_TEMP_SUBPARTS_PROGRESS][pieceName]);
      }
      
      public function checkAndUpdateStage(pieceName:String) : void
      {
         var activePieces:Array = null;
         var slotNum:int = 0;
         var featureObject:Object = this.getFeatureData();
         var parts:int = int(featureObject[this.KEY_SAVED_SUBPARTS_PROGRESS][pieceName]);
         var currStage:int = int(featureObject[this.KEY_PIECES_PROGRESS][pieceName]);
         var stage:int = int(parts / this.PARTS_PER_PIECE);
         if(stage > 5)
         {
            stage = 5;
         }
         if(stage > currStage)
         {
            activePieces = this.getActivePieces();
            slotNum = activePieces.indexOf(pieceName);
            StatsManager.count(FEATURE_TRACKING,"stage_complete",pieceName,stage.toString(),"","");
            if(Boolean(slotNum < 3) && Boolean(this.m_mainWindow) && Boolean(this.m_mainWindow.m_piecesFrame))
            {
               this.m_mainWindow.m_piecesFrame.showGlow(slotNum);
            }
         }
         featureObject[this.KEY_PIECES_PROGRESS][pieceName] = stage;
         setFeatureData(featureObject);
      }
      
      public function getTempPieceProgress(pieceName:String) : int
      {
         var featureObject:Object = this.getFeatureData();
         return featureObject[this.KEY_TEMP_SUBPARTS_PROGRESS][pieceName];
      }
      
      public function getActivePieces() : Array
      {
         var featureObject:Object = this.getFeatureData();
         return featureObject[this.KEY_SAVED_ACTIVE_PIECES] as Array;
      }
      
      public function getPPHGrantData() : Array
      {
         var featureObject:Object = this.getFeatureData();
         return featureObject[this.KEY_PPH_GRANT_ONLY] as Array;
      }
      
      public function getCompletedPiecesList() : Array
      {
         var featureObject:Object = this.getFeatureData();
         return featureObject[this.KEY_COMPLETED_PIECES] as Array;
      }
      
      public function getNumberofCompletedPieces() : int
      {
         var featureObject:Object = this.getFeatureData();
         var completedList:Array = this.getCompletedPiecesList();
         return int(completedList.length);
      }
      
      public function getSequenceId() : int
      {
         var featureObject:Object = this.getFeatureData();
         return featureObject[this.KEY_ORDER_SEQUENCE];
      }
      
      protected function checkForTaskUpdates(event:TransactionEvent) : void
      {
         var progress:Number = NaN;
         var transaction:TFarmTransaction = null;
         var taskList:Vector.<FarmTask> = null;
         var bushelTask:FarmTask = null;
         var itemData:FarmItem = null;
         var hasUpdatedProgress:Boolean = false;
         var hasCompletedTask:Boolean = false;
         var progressArray:Array = [];
         var featureObject:Object = this.getFeatureData();
         var savedBushelProgress:* = featureObject[this.KEY_SAVED_BUSHEL_PROGRESS];
         transaction = event.transaction as TFarmTransaction;
         var count:int = 0;
         if(savedBushelProgress)
         {
            if(this.m_bushelTasklist)
            {
               taskList = this.m_bushelTasklist;
            }
            else
            {
               taskList = this.getTasks();
            }
            for each(bushelTask in taskList)
            {
               itemData = Global.farmGameSettingsManager.getFarmItemByCode(bushelTask.type);
               progress = FarmQuestUtility.getInstance().getProgression(bushelTask,transaction,null);
               if(progress > 0)
               {
                  ++m_harvestHitCount;
                  if(m_harvestHitCount == 2)
                  {
                  }
                  hasUpdatedProgress = true;
                  if(Number(savedBushelProgress[itemData.name]) + progress >= bushelTask["total"])
                  {
                     hasCompletedTask = true;
                     count += (Number(savedBushelProgress[itemData.name]) + progress) / bushelTask["total"];
                  }
                  savedBushelProgress[itemData.name] += progress;
               }
            }
         }
         if(hasUpdatedProgress)
         {
            this.saveProgressForPlayer(savedBushelProgress);
            if(m_harvestHitCount == 1)
            {
            }
            if(m_harvestHitCount >= 2)
            {
               m_harvestHitCount = 0;
            }
            if(hasCompletedTask)
            {
               hasCompletedTask = false;
               this.resetBushelProgress();
               m_isTaskComplete = 1;
               this.onTaskCompleteUpdate(count);
            }
         }
      }
      
      public function onTaskCompleteUpdate(count:int) : void
      {
         if(m_isTaskComplete == 1)
         {
            m_isTaskComplete = 0;
            this.grantPart(count);
         }
      }
      
      protected function saveProgressForPlayer(savedBushelProgress:*) : void
      {
         var featureObj:Object = this.getFeatureData();
         featureObj[this.KEY_SAVED_BUSHEL_PROGRESS] = savedBushelProgress;
         setFeatureData(featureObj);
      }
      
      protected function resetBushelProgress() : void
      {
         var crop:XML = null;
         var cropProgress:int = 0;
         var cropTotalRequired:int = 0;
         var reminder:int = 0;
         var featureObject:Object = this.getFeatureData();
         for each(crop in this.m_cropsByName)
         {
            cropProgress = int(featureObject[this.KEY_SAVED_BUSHEL_PROGRESS][crop.@name]);
            cropTotalRequired = int(crop.@count);
            reminder = cropProgress % cropTotalRequired;
            if(cropProgress >= cropTotalRequired)
            {
               featureObject[this.KEY_SAVED_BUSHEL_PROGRESS][crop.@name] = reminder;
            }
         }
         setFeatureData(featureObject);
      }
      
      public function grantPart(count:int) : void
      {
         var featureObject:Object = null;
         var randomID:int = 0;
         var weight:int = 0;
         var itemName:String = null;
         if(!this.isFeatureCompleted())
         {
            featureObject = this.getFeatureData();
            randomID = int(featureObject[this.ANTIQUE_MESUEM_INDEX]);
            weight = this.getCurrentTileWeight();
            if(this.areAllTilesUnlocked() || this.isUserEligibleForPPHGrant())
            {
               itemName = featureObject[this.KEY_SAVED_ACTIVE_PIECES][randomID];
               featureObject[this.KEY_PPH_GRANT_ONLY][randomID] += count;
               featureObject[this.KEY_TEMP_SUBPARTS_PROGRESS][itemName] += count;
               setFeatureData(featureObject);
               StatsManager.count(FEATURE_TRACKING,"getpart","pph",weight.toString(),"","",count);
               if(this.shouldShowToasterHud(itemName))
               {
                  this.showToasterHud();
               }
            }
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,PPH_SERVICE_CALL,null,[featureName,itemName,featureObject]),true);
         }
      }
      
      public function shouldShowPPHGrantPopup() : Boolean
      {
         var curr:int = 0;
         var result:Boolean = false;
         var pphGrantData:Array = this.getPPHGrantData();
         var activePieces:Array = this.getActivePieces();
         for(var i:int = 0; i < 3; i++)
         {
            if(Boolean(pphGrantData) && pphGrantData[i] > 0)
            {
               curr = this.getTempPartsRequiredToComplete(activePieces[i]) + pphGrantData[i];
               if(curr > 0)
               {
                  result = true;
                  break;
               }
            }
         }
         if(result == false)
         {
            this.resetPPHGrantData();
         }
         return result;
      }
      
      public function shouldShowToasterHud(pieceName:String) : Boolean
      {
         var curr:int = 0;
         var result:Boolean = false;
         var pphGrantData:Array = this.getPPHGrantData();
         var activePieces:Array = this.getActivePieces();
         var index:int = activePieces.indexOf(pieceName);
         if(Boolean(pphGrantData) && pphGrantData[index] > 0)
         {
            curr = this.getTempPartsRequiredToComplete(pieceName) + pphGrantData[index];
            if(curr > 0)
            {
               result = true;
            }
         }
         if(result == false)
         {
            this.resetPPHGrantData();
         }
         return result;
      }
      
      public function shouldShowForceAddPopup() : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         var fossilId:int = int(featureData[this.ANTIQUE_MESUEM_INDEX]);
         var count:int = this.getNumberOfPartsGranted(fossilId);
         if(count > 10)
         {
            result = true;
         }
         return result;
      }
      
      public function incrementTempParts(pieceName:String, count:int) : void
      {
         var featureData:Object = this.getFeatureData();
         featureData[this.KEY_TEMP_SUBPARTS_PROGRESS][pieceName] += count;
         setFeatureData(featureData);
      }
      
      public function getNumberOfPartsGranted(slotNumber:int) : int
      {
         var count:int = 0;
         var activePieces:Array = this.getActivePieces();
         var pieceName:String = activePieces[slotNumber];
         var actual:int = this.getSubpartsProgress(pieceName);
         var temp:int = this.getTempPieceProgress(pieceName);
         return int(temp - actual);
      }
      
      public function getNumberOfPartsGrantedByName(pieceName:String) : int
      {
         var count:int = 0;
         var actual:int = this.getSubpartsProgress(pieceName);
         var temp:int = this.getTempPieceProgress(pieceName);
         return int(temp - actual);
      }
      
      public function getNameOfPartGranted() : String
      {
         var result:String = "";
         var activePieces:Array = this.getActivePieces();
         for(var i:int = 0; i < 3; i++)
         {
            if(this.getNumberOfPartsGranted(i) > 0)
            {
               result = activePieces[i];
               break;
            }
         }
         return result;
      }
      
      public function getTasks() : Vector.<FarmTask>
      {
         var farmTask:FarmTask = null;
         var cropData:XML = null;
         var taskObj:Object = null;
         var taskList:Vector.<FarmTask> = new Vector.<FarmTask>();
         var featureObject:Object = this.getFeatureData();
         var savedBushelData:* = featureObject[this.KEY_SAVED_BUSHEL_PROGRESS];
         if(savedBushelData)
         {
            for each(cropData in this.m_cropsByName)
            {
               taskObj = {};
               taskObj.questName = m_featureName;
               taskObj.action = "harvestByCode";
               taskObj.type = cropData.@code;
               taskObj.helper = "plant_seed";
               taskObj.total = cropData.@count;
               taskObj.cashValue = "";
               farmTask = new FarmTask(taskObj);
               taskList.push(farmTask);
            }
         }
         this.m_bushelTasklist = taskList;
         return taskList;
      }
      
      public function showCollectionUI(e:Event = null) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         UI.displayPopup(this.m_collectionWindow = new AntiqueMuseumV2CollectionWindow(m_featureName,this.collectionWindowURL),false);
         FarmStatsManager.count(FEATURE_TRACKING,"feature_ui","collectionWindow","impression");
      }
      
      public function showSurveyMapUI() : void
      {
         UI.displayPopup(this.m_surveyMapWindow = new AntiqueMuseumV2SurveyMapWindow(m_featureName,this.surveyMapWindowURL),false);
         StatsManager.count(FEATURE_TRACKING,"dump_map","open");
      }
      
      public function showForceAddPopup() : void
      {
         this.m_forceAddPartsPopup = new AntiqueMuseumV2ForceAddPartsWindow(this.forceAddURL,m_featureName,null,this.closeAllWindows);
         UI.displayPopup(this.m_forceAddPartsPopup,false);
      }
      
      public function showFoundConsumablePopup() : void
      {
         if(this.mainWindow)
         {
            this.mainWindow.tintWindow();
            this.mainWindow.enableInput = false;
         }
         var itemName:String = this.getNameOfPartGranted();
         itemName = "consume_unwither";
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         this.m_antiquePieceFoundPopup = new AntiqueMuseumV2ConsumableFoundWindow(this.consumableFoundURL,m_featureName,item,this.resetPPHGrantData,"assets/dialogs/ireland/RewardDialog.png",item.iconUrl,itemName);
         UI.displayPopup(this.m_antiquePieceFoundPopup,false);
      }
      
      public function openCropMiniMarket() : void
      {
         UI.displayMiniMarketDialog(this.m_marketItems,null,"seed");
      }
      
      public function get collectionWindowURL() : String
      {
         return "assets/dialogs/JulySideCarFeature_CanadianMuseum/FV_collections_CanadianMuseum.swf";
      }
      
      public function get fictionURL() : String
      {
         return "assets/dialogs/JulySideCarFeature_CanadianMuseum/FV_motd_CanadianMuseumFiction.swf";
      }
      
      public function get levelCompletedURL() : String
      {
         return "assets/dialogs/JulySideCarFeature_CanadianMuseum/FV_RewardScreen_CanadianMuseum.swf";
      }
      
      public function get consumableFoundURL() : String
      {
         return "assets/dialogs/JulySideCarFeature_CanadianMuseum/FV_FoundConsumable_CanadianMuseum.swf";
      }
      
      public function get forceAddURL() : String
      {
         return "assets/dialogs/JulySideCarFeature_CanadianMuseum/FV_SynkParts_CanadianMuseum.swf";
      }
      
      public function get surveyMapWindowURL() : String
      {
         return "assets/dialogs/JulySideCarFeature_CanadianMuseum/FV_TilesInfo_CanadianMuseum.swf";
      }
      
      public function get hudURL() : String
      {
         return "assets/dialogs/JulySideCarFeature_CanadianMuseum/FV_consumables_CanadianMuseum.swf";
      }
      
      public function onSinkParts(slotNumber:int, cookedOrder:String) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkConsumable",this.onCompleteSink,[m_featureName,slotNumber]),true);
      }
      
      public function onCompleteSink(result:Object) : void
      {
         var slotNumber:int = 0;
         var updatedOrders:* = undefined;
         var featureData:Object = null;
         if(result)
         {
            slotNumber = int(result["slotNumber"]);
            updatedOrders = result["activeTasks"];
            featureData = this.getFeatureData();
            featureData[KEY_SAVED_ACTIVE_ORDERS] = updatedOrders;
            setFeatureData(featureData);
            this.updatePiecesData(result);
         }
      }
      
      public function getAllPiecesData() : Object
      {
         if(this.m_piecesByName)
         {
            return this.m_piecesByName;
         }
         return null;
      }
      
      public function getAllPiecesInOrder() : Array
      {
         if(this.m_allItemsInOrder)
         {
            return this.m_allItemsInOrder;
         }
         return null;
      }
      
      public function getFeatureEndDaysLeftText() : String
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var days:int = 0;
         var dayExpiredTime:Number = NaN;
         var currenttime:Number = NaN;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("08/10/2020");
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
               result += " day left!";
            }
            else if(days == 0)
            {
               dayExpiredTime = FarmGameUtil.getMidnightTimestamp() / 1000 + 86400;
               currenttime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
               timeLeft = dayExpiredTime - currenttime;
               result = timeLeftArray[1] + " Hours left!";
            }
            else
            {
               result = (days + 1).toString() + " days left!";
            }
         }
         return result;
      }
      
      public function getTimeLeftTemp() : String
      {
         var timeRemaining:Array = this.getFeatureExpiryTimeOnWall();
         var timeLeft:String = "";
         if(parseInt(timeRemaining[0]) > 1)
         {
            timeLeft = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"BBWinter_TimeLeftDays",{"time":timeRemaining[0]});
         }
         else
         {
            timeLeft = HUD.getformattedTimeLeftFromArray(timeRemaining);
         }
         return timeLeft;
      }
      
      public function getFeatureExpiryTimeOnWall() : Array
      {
         var remainingDay:int = 0;
         var timeLeftMs:Number = FarmGameUtil.synchronizedDateToNumber("08/10/2020") - GlobalEngine.serverTime;
         timeLeftMs = timeLeftMs < 0 ? 0 : timeLeftMs;
         var remainingTime:Array = FarmGameUtil.parseTimeLeft(timeLeftMs / 1000);
         if(parseInt(remainingTime[0]) > 0)
         {
            remainingDay = parseInt(remainingTime[0]) + 1;
            remainingTime[0] = remainingDay.toString();
         }
         return remainingTime;
      }
      
      public function canSelectTile() : Boolean
      {
         var result:Boolean = true;
         if(m_selectedTile !== null)
         {
            result = false;
         }
         return result;
      }
      
      public function onTileSelected(tileName:String) : void
      {
         m_selectedTile = tileName;
         FarmStatsManager.count(FEATURE_TRACKING,"tile_select",tileName);
      }
      
      public function disSelectAllTiles() : void
      {
         m_selectedTile = null;
      }
      
      public function onTileUnselected(tileName:String) : void
      {
         m_selectedTile = null;
         FarmStatsManager.count(FEATURE_TRACKING,"tile_remove",tileName);
      }
      
      public function isNonPayerTilePrereqMet(itemName:String) : Boolean
      {
         var result:Boolean = false;
         var item:* = Global.world.getObjectsByName(itemName)[0];
         if(!item)
         {
         }
         return result;
      }
      
      public function getCurrentPieceIndex() : int
      {
         var featureData:Object = this.getFeatureData();
         return featureData[this.ANTIQUE_MESUEM_INDEX] as int;
      }
      
      public function setCurrentPieceIndex(reslut:Object) : void
      {
         var featureData:Object = null;
         if(reslut.hasOwnProperty(this.ANTIQUE_MESUEM_INDEX))
         {
            featureData = this.getFeatureData();
            featureData[this.ANTIQUE_MESUEM_INDEX] = reslut[this.ANTIQUE_MESUEM_INDEX];
            setFeatureData(featureData);
         }
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
            FarmStatsManager.count(FEATURE_TRACKING,"Harvest",buildingName,harvestRewardName);
            UI.displayPopup(new GenericSingleRewardPopup(this.REWARD_POPUP_WINDOW,"xcd_Bonus_",harvestFarmItem,null,this.REWARD_WINDOW_IMAGE),false);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,SERVICE_FUNC_HARVEST_BONUS,null,[m_featureName,buildingName]),true);
         }
      }
      
      private function getNextHarvestItemName(itemName:String) : String
      {
         var harvestReward:String = null;
         var bonusCount:int = 0;
         var featureData:Object = this.getFeatureData();
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
         setFeatureData(featureData);
         return harvestReward;
      }
      
      public function canHarvestBonusRewardBuilding() : Boolean
      {
         var featureData:Object = this.getFeatureData();
         var isStillHarvestable:Boolean = false;
         var bonusStartTime:Number = featureData[this.KEY_BONUS_HARVEST_START_TIME] as Number;
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
         var featureData:Object = this.getFeatureData();
         var isStillHarvestable:Boolean = false;
         var bonusStartTime:Number = featureData[this.KEY_BONUS_HARVEST_START_TIME] as Number;
         if(bonusStartTime)
         {
            if(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - bonusStartTime < 13 * 86400)
            {
               isStillHarvestable = true;
            }
         }
         return isStillHarvestable;
      }
   }
}

