package Managers
{
   import Classes.Idle.GenericToasterIdleTask;
   import Classes.Idle.IdleTaskQueue;
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.AntiqueMuseumCollectionWindow;
   import Widgets.Windows.AntiqueMuseumConsumableFoundWindow;
   import Widgets.Windows.AntiqueMuseumForceAddPartsWindow;
   import Widgets.Windows.AntiqueMuseumLevelCompletedWindow;
   import Widgets.Windows.AntiqueMuseumMainWindow;
   import Widgets.Windows.AntiqueMuseumSurveyMapWindow;
   import Widgets.Windows.ConsumableToasterWindow;
   import Widgets.Windows.MOTD.AntiqueMuseumMOTDWindow;
   import Widgets.Windows.Market.MarketWindow;
   import flash.events.Event;
   
   public class AntiqueMuseumManager extends BaseFeatureManager
   {
      
      private static var m_initialized:Boolean = false;
      
      private static const FEATURE_TRACKING:String = "AntiqueMuseum";
      
      private static const SERVICE_NAME:String = "AntiqueMuseumService";
      
      private static const PPH_SERVICE_CALL:String = "checkAndGrantPPHDrop";
      
      private static const UPDATE_BUSHEL_PROGRESS:String = "updateBushelProgress";
      
      private static const TOTAL_TILEWEIGHT:Number = 50;
      
      private static const KEY_SAVED_ACTIVE_ORDERS:String = "activeOrders";
      
      private static const KEY_ORDER_SEQUENCE:String = "order_sequence";
      
      private static const INITIAL_PIECE_LIST:Array = ["ornateteapot","mysteriousbox","earlybronzepot"];
      
      private static var m_harvestHitCount:int = 0;
      
      private static var m_isTaskComplete:int = 0;
      
      private static var m_selectedTile:String = null;
      
      protected static var m_instance:Object = {};
      
      public static const FEATURE_NAME:String = "AntiqueMuseum";
      
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
      
      public const KEY_ORDER_SEQUENCE:* = "order_sequence";
      
      public const PARTS_PER_PIECE:* = 10;
      
      public const MAX_SUBPARTS_COUNT:* = 60;
      
      public const GRANT_PARTS_ON_BUY:* = 5;
      
      public const COST_PER_PACK:* = 7;
      
      public const KEY_TILE_UNLOCK_COUNT:String = "tile_unlock_count";
      
      private var m_allItemsInOrder:Array = ["ornateteapot","mysteriousbox","earlybronzepot","ancienttikisatue","ancientdodecahedron","oldornatebell","jadehorseartifact","goldenbracelet","ancientmask"];
      
      private var m_marketItems:Array = ["xhf_woodspider","xhf_fatalnightshade","xhf_corpseflower","xhf_bizzarebulbs","xhf_redcockscomb","xhf_ropeplant","xhf_blackparrottulip","xhf_nightmarebroccoli","xhf_spookycarrot","xhf_creepyyellowcitron","xhf_spookyflower","xhf_skeletalflower","xhf_monsterstrawberry","xhf_eyeballflower","xhf_bleedingflower","xhf_cobraplant","xhf_braincactus","xhf_greenmaskapple"];
      
      private const REWARD_FARM_ESSENTIALS:String = "pkg_antique_farm_essentials";
      
      private var m_marketWindow:MarketWindow = null;
      
      private var m_antiqueFiction:AntiqueMuseumMOTDWindow;
      
      private const ANTIQUE_PIECES_ARRAY:Array = ["lp09","dlwc","bmx0","thm5","uv52","gz1k","26mu"];
      
      private var m_grantProbArray:Array;
      
      private var m_currentProbArray:Array = new Array(100);
      
      private const KEY_SEEN_FTUE:String = "antique_museum_ftue_seen";
      
      protected var m_featureConfigData:Object;
      
      public var m_mainWindow:AntiqueMuseumMainWindow;
      
      public var m_levelCompleteRewardPopup:AntiqueMuseumLevelCompletedWindow;
      
      public var m_forceAddPartsPopup:AntiqueMuseumForceAddPartsWindow;
      
      public var m_milestoneRewardPopup:AntiqueMuseumLevelCompletedWindow;
      
      public var m_antiquePieceFoundPopup:AntiqueMuseumConsumableFoundWindow;
      
      private var m_collectionWindow:AntiqueMuseumCollectionWindow;
      
      private var m_surveyMapWindow:AntiqueMuseumSurveyMapWindow;
      
      private var m_bundleFirstTile:String = "xid_special_tile";
      
      private var m_tilesByName:Object;
      
      private var m_cropsByName:Object;
      
      private var m_piecesByName:Object;
      
      private var m_toasterHud:ConsumableToasterWindow;
      
      private var m_piecesByIndex:Object;
      
      private var m_bushelTasklist:Vector.<FarmTask>;
      
      private var totalTileCost:int = 0;
      
      public function AntiqueMuseumManager(featureName:String)
      {
         super(featureName);
         this.parseFeatureDataFromConfig(FEATURE_NAME);
         this.m_featureConfigData = new Object();
         this.startQuest();
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
      }
      
      public static function getInstance(featureName:String = "AntiqueMuseum") : AntiqueMuseumManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,AntiqueMuseumManager) as AntiqueMuseumManager;
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
         var toaster:ConsumableToasterWindow = new ConsumableToasterWindow("Antique Museum","Antique Museum",this.hudURL,this.onClickToaster,3000);
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
               featureData[this.KEY_MILESTONE_REWARDS][i] = 0;
            }
            featureData[this.KEY_GRANT_ARRAY_INDEX] = 0;
            featureData[this.KEY_TILE_WEIGHT] = 0;
            featureData[this.KEY_RANDOM_COUNT] = 0;
            featureData[this.KEY_FEATURE_ENDED] = false;
            featureData[this.KEY_SAVED_ACTIVE_PIECES] = INITIAL_PIECE_LIST;
            featureData[this.KEY_TILE_UNLOCK_COUNT] = 0;
            featureData[KEY_SAVED_ACTIVE_ORDERS] = {};
            featureData[this.KEY_ORDER_SEQUENCE] = 3;
            setFeatureData(featureData);
         }
         return featureData;
      }
      
      public function getCurrentTileWeight() : int
      {
         var tileData:XML = null;
         var weight:int = 2;
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
         var shouldGrant:* = false;
         var featureObject:Object = this.getFeatureData();
         var currWeight:* = this.getCurrentTileWeight();
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
         var isAllUnlocked:* = false;
         if(weight == 100)
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
         this.checkForTaskUpdates(event);
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
         tilesConfig = Global.farmGameSettingsManager.getXML().AntiqueMuseumFeatureConfig.AntiqueMuseumConfigData.(@name == questName)[0];
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
      
      public function get mainWindow() : AntiqueMuseumMainWindow
      {
         return this.m_mainWindow;
      }
      
      public function showAntiqueFiction() : *
      {
         Global.player.setSeenFlag("AntiqueMuseum_FictionSeen");
         this.m_antiqueFiction = new AntiqueMuseumMOTDWindow(AntiqueMuseumManager.FEATURE_NAME,this.fictionURL);
         UI.displayPopup(this.m_antiqueFiction,false);
      }
      
      public function showMainWindow() : void
      {
         if(!Global.player.getSeenFlag("AntiqueMuseum_FictionSeen"))
         {
            this.showAntiqueFiction();
         }
         else if(this.isFeatureCompleted())
         {
            this.showCollectionUI();
         }
         else
         {
            this.m_mainWindow = new AntiqueMuseumMainWindow("AntiqueMuseumMainWindow","assets/dialogs/AntiqueMuseum/FV_MainScreen_AntiqueMuseum.swf",false);
            UI.displayPopup(this.m_mainWindow,false);
            StatsManager.count(FEATURE_NAME,"mainui","open");
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
         var featureObject:* = this.getFeatureData();
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
               this.m_levelCompleteRewardPopup = new AntiqueMuseumLevelCompletedWindow(this.levelCompletedURL,m_featureName,item,this.closeLevelCompletedPopup,"assets/dialogs/ireland/RewardDialog.png",item.iconUrl,item.name);
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
               StatsManager.count(m_featureName,"item_complete","milestone",completedPiecesCount.toString(),milestoneName);
               this.showMilestonePopup(result["milestone"]);
            }
         }
      }
      
      public function showMilestonePopup(name:String) : *
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
            this.m_milestoneRewardPopup = new AntiqueMuseumLevelCompletedWindow(this.levelCompletedURL,m_featureName,item,this.closeMilestoneRewardPopup,"assets/dialogs/spooky/RewardDialog.png",item.iconUrl,name,true);
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
      
      public function closeMilestoneRewardPopup(event:Event) : *
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.untintWindow();
            this.m_mainWindow.enableInput = true;
         }
         if(this.m_milestoneRewardPopup)
         {
            this.m_milestoneRewardPopup.close();
         }
      }
      
      public function closeLevelCompletedPopup(event:Event) : *
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.untintWindow();
            this.m_mainWindow.enableInput = true;
         }
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
         if(this.m_collectionWindow)
         {
            this.m_collectionWindow.close();
         }
         if(this.m_surveyMapWindow)
         {
            this.m_surveyMapWindow.close();
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
            FarmStatsManager.count(m_featureName,"","feature_end");
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
         StatsManager.count(m_featureName,"addpart",pieceName,stage.toString(),currCount.toString(),"",grantCount);
         setFeatureData(featureObject);
         this.checkAndUpdateStage(pieceName);
         if(this.getCurrentStage(pieceName) == 6)
         {
            if(this.m_mainWindow)
            {
               this.m_mainWindow.tintWindow();
               this.m_mainWindow.enableInput = false;
            }
            this.showAntiqueCompletedPopup(pieceName);
            completedCount = this.getNumberofCompletedPieces();
            StatsManager.count(m_featureName,"item_complete",pieceName,completedCount.toString(),pieceName + "FarmEssentials");
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
         var currStage:* = featureObject[this.KEY_PIECES_PROGRESS][pieceName];
         var stage:int = int(parts / this.PARTS_PER_PIECE);
         if(stage > 6)
         {
            stage = 6;
         }
         if(stage > currStage)
         {
            activePieces = this.getActivePieces();
            slotNum = activePieces.indexOf(pieceName);
            StatsManager.count(m_featureName,"stage_complete",pieceName,stage.toString(),"","");
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
         return featureObject[this.KEY_SAVED_ACTIVE_PIECES];
      }
      
      public function getPPHGrantData() : Array
      {
         var featureObject:Object = this.getFeatureData();
         return featureObject[this.KEY_PPH_GRANT_ONLY];
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
         var count:int = 1;
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
                     progress = 0;
                  }
                  hasUpdatedProgress = true;
                  if(Number(savedBushelProgress[itemData.name]) + progress >= bushelTask["total"])
                  {
                     hasCompletedTask = true;
                     count = (Number(savedBushelProgress[itemData.name]) + progress) / bushelTask["total"];
                  }
                  savedBushelProgress[itemData.name] += progress;
               }
            }
         }
         if(hasUpdatedProgress)
         {
            if(m_harvestHitCount == 1)
            {
               this.saveProgressForPlayer(savedBushelProgress);
            }
            if(m_harvestHitCount >= 2)
            {
               m_harvestHitCount = 0;
            }
            if(hasCompletedTask && m_harvestHitCount == 1)
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
      
      public function grantPart(count:int = 1) : void
      {
         var featureObject:Object = null;
         var randomID:int = 0;
         var weight:int = 0;
         var itemName:String = null;
         if(!this.isFeatureCompleted())
         {
            featureObject = this.getFeatureData();
            randomID = featureObject[this.KEY_RANDOM_COUNT] % 3;
            weight = this.getCurrentTileWeight();
            if(this.areAllTilesUnlocked() || this.isUserEligibleForPPHGrant())
            {
               itemName = featureObject[this.KEY_SAVED_ACTIVE_PIECES][randomID];
               featureObject[this.KEY_PPH_GRANT_ONLY][randomID] += count;
               featureObject[this.KEY_RANDOM_COUNT] += 1;
               featureObject[this.KEY_TEMP_SUBPARTS_PROGRESS][itemName] += count;
               setFeatureData(featureObject);
               StatsManager.count(m_featureName,"getpart","pph",weight.toString(),"","",count);
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
         var count:int = 0;
         var result:Boolean = false;
         var activePieces:Array = this.getActivePieces();
         for(var i:int = 0; i < 3; i++)
         {
            count = this.getNumberOfPartsGranted(i);
            if(count > 10)
            {
               result = true;
               break;
            }
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
         UI.displayPopup(this.m_collectionWindow = new AntiqueMuseumCollectionWindow(m_featureName,this.collectionWindowURL),false);
         FarmStatsManager.count(m_featureName,"feature_ui","collectionWindow","impression");
      }
      
      public function showSurveyMapUI() : void
      {
         UI.displayPopup(this.m_surveyMapWindow = new AntiqueMuseumSurveyMapWindow(m_featureName,this.surveyMapWindowURL),false);
         StatsManager.count(FEATURE_NAME,"dump_map","open");
      }
      
      public function showForceAddPopup() : void
      {
         this.m_forceAddPartsPopup = new AntiqueMuseumForceAddPartsWindow(this.forceAddURL,m_featureName,null,this.closeAllWindows);
         UI.displayPopup(this.m_forceAddPartsPopup,false);
      }
      
      public function showFoundConsumablePopup() : void
      {
         var itemName:* = this.getNameOfPartGranted();
         itemName = "consume_unwither";
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         this.m_antiquePieceFoundPopup = new AntiqueMuseumConsumableFoundWindow(this.consumableFoundURL,m_featureName,item,this.resetPPHGrantData,"assets/dialogs/ireland/RewardDialog.png",item.iconUrl,itemName);
         UI.displayPopup(this.m_antiquePieceFoundPopup,false);
      }
      
      public function openCropMiniMarket() : void
      {
         UI.displayMiniMarketDialog(this.m_marketItems,null,"seed");
      }
      
      public function get collectionWindowURL() : String
      {
         return "assets/dialogs/AntiqueMuseum/FV_collections_AntiqueMuseum.swf";
      }
      
      public function get fictionURL() : String
      {
         return "assets/dialogs/AntiqueMuseum/FV_motd_AntiqueMuseumFiction.swf";
      }
      
      public function get levelCompletedURL() : String
      {
         return "assets/dialogs/AntiqueMuseum/FV_RewardScreen_AntiqueMuseum.swf";
      }
      
      public function get consumableFoundURL() : String
      {
         return "assets/dialogs/AntiqueMuseum/FV_FoundConsumable_AntiqueMuseum.swf";
      }
      
      public function get forceAddURL() : String
      {
         return "assets/dialogs/AntiqueMuseum/FV_SynkParts_AntiqueMuseum.swf";
      }
      
      public function get surveyMapWindowURL() : String
      {
         return "assets/dialogs/AntiqueMuseum/FV_SurveyMap_AntiqueMuseum.swf";
      }
      
      public function get hudURL() : String
      {
         return "assets/dialogs/AntiqueMuseum/FV_consumables_AntiqueMuseum.swf";
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
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("9/26/2019");
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
               dayExpiredTime = FarmGameUtil.getMidnightTimestamp() / 1000 + 86400;
               currenttime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
               timeLeft = dayExpiredTime - currenttime;
               result = timeLeftArray[1] + " Hours left!";
            }
            else
            {
               result += " Days left!";
            }
         }
         return result;
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
   }
}

