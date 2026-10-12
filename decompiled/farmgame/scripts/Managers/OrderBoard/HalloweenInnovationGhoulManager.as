package Managers.OrderBoard
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.QuestConstants;
   import Classes.Constants.WorldsConstants;
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.SimpleCryptoManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.HUD.HUDWidgets.HudBottomHalloweenInnovationGhoulButton;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.TileUnlockEvent;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.FeatureOptionsManager;
   import Managers.WorldSeasonsManager;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.CarribeanTileUnlockWindow;
   import Widgets.Windows.GenericSingleRewardPopup;
   import Widgets.Windows.HalloweenInnovationGhoulGameWindow;
   import Widgets.Windows.HalloweenInnovationGhoulWindow;
   import Widgets.Windows.HalloweenInnovationGhoulWindowFinal;
   import flash.events.Event;
   import mx.utils.StringUtil;
   
   public class HalloweenInnovationGhoulManager extends SpecialQuestManager
   {
      
      private static const SERVICE_NAME:String = "HalloweenInnovationGhoulService";
      
      private static const KEY_SAVED_ACTIVE_TASKS:String = "1";
      
      private static const KEY_SAVED_BOARD_COUNT:String = "21";
      
      public static const HALLOWEEN_ORDERBOARD_POINTS_ITEM_CODE:String = "cie3";
      
      public static const HALLOWEEN_GHOUL_FEATURE_POINTS_ITEM_CODE:String = "cie3";
      
      private static const KEY_TILE_UNLCOKED_COUNT:String = "tuc";
      
      public static const EVENT_HALLOWEEN_INNOVATION_GHOUL_TILE_UNLOCK:String = "HalloweenInnovationGhoulTileUnlock";
      
      private static const KEY_CONSUMABLES_COUNT:String = "consumables";
      
      private static const EA_DROP_CONSUMABLES:int = 40;
      
      private static const LAND_PURCHASE_CONSUMABLES:int = 50;
      
      private static const m_marketItems:Array = ["xhx_rubbletreasure1","xhx_rubbletreasure2","xhx_rubbletreasure3","xhx_rubbletreasure4","xhx_rubbletreasure5","xhx_rubbletreasure6","xhx_rubbletreasure7","xhx_rubbletreasure8","xhx_rubbletreasure9","xhx_rubbletreasure_payer1","xhx_rubbletreasure_payer2","xhx_rubbletreasure_payer3","xhx_rubbletreasure_payer4","xhx_rubbletreasure_payer5","xhx_rubbletreasure_payer6","xhx_rubbletreasure_payer7","xhx_rubbletreasure_payer8","xhx_rubbletreasure_payer9","xhx_rubbletreasure_payer10","xhx_rubbletreasure_payer11","xhx_rubbletreasure_payer12","xhx_rubbletreasure_payer13","xhx_rubbletreasure_payer14","xhx_rubbletreasure_payer15","xhx_rubbletreasure_payer16","xhx_rubbletreasure_payer17","xhx_rubbletreasure_payer18","xhx_rubbletreasure_payer19","xhx_rubbletreasure_payer20","xhx_rubbletreasure_payer21","xhx_rubbletreasure_payer22","xhx_rubbletreasure_payer23"];
      
      private static const BONUS_HARVEST_COUNT:String = "hc_";
      
      private static const WINDOW_MAIN:String = "main";
      
      private static const WINDOW_GAME:String = "game";
      
      private static const FINAL_WINDOW:String = "final";
      
      public static const KEY_SAVED_FINAL_REWARD_BUILDINGNAME:String = "reward_building";
      
      private static const INVENTION_NAMES:Array = ["Furry Freak","Madclaw","Supreme Shell","Dark Doom"];
      
      public static const FEATURE_FORCED_TUT_FRIST_STEP:String = "FrontierInnovation_step1";
      
      private static const KEY_ACTIVE_INVENTION:String = "activeInvention";
      
      private static const KEY_ACTIVE_PART:String = "activePart";
      
      private static const NUM_INVENTIONS:int = 4;
      
      private static const KEY_REWARDS:String = "rewards";
      
      public static const HUD_INITIALISATION_FLAG:String = "HalloweenInnovationGhoul_hud_initialise_flag";
      
      private static const SEEN_FLAG:String = "seen_flag";
      
      public static const DEFAULT_HARVEST_THROTTLE_TIME:int = 86400;
      
      public static const DEFAULT_COLLECT_THROTTLE_TIME:int = 86400;
      
      private static const HUD_HALLOWEENINNOVATIONGHOUL_ASSET:String = "assets/dialogs/halloweenmad/innovation/FV_xhx_hud_innovation.swf";
      
      private static const SERVICE_FUNC_HARVEST_BONUS:String = "harvestDecos";
      
      protected const KEY_PROGRESS:String = "progress";
      
      protected const KEY_ID:String = "id";
      
      public const TILE_UNLOCK_POINTS:Number = 50;
      
      private const SKIP_COST:int = 1;
      
      protected const KEY_TOTAL:String = "total";
      
      private const KEY_SAVED_FINAL_REWARD_RECEIVED:String = "k11";
      
      public const VAL_FINAL_MILESTONE:Number = 3000;
      
      private const TILE_UNLOCK_ASSET:String = "assets/dialogs/brazil/innovation/FV_xbr_Innovation_Prize.swf";
      
      public const GAME_INVENTIONS_KEY:String = "inventions";
      
      private const KEY_SAVED_DUMPED_TIMESTAMP:String = "3";
      
      public const FINAL_PART:int = 3;
      
      public const FINAL_INVENTION:int = 3;
      
      public const KEY_GAME_DATA:String = "gameData";
      
      public const ANIMAL_ICON:String = "animalicon";
      
      public const ANIMAL_ICON_LARGE:String = "animaliconlarge";
      
      public const ANIMAL_FINAL_ICON_LARGE:String = "animalfinaliconlarge";
      
      public const PART_ICON_SMALL:String = "particonsmall";
      
      public const PART_ICON_BORDERLESS_LARGE:String = "particonborderlesslarge";
      
      public const PART_ICON_WITH_BORDER_LARGE:String = "particonwithborderlarge";
      
      public const LAST_HARVEST_TIME_KEY:String = "_lastHarvestTimeKey";
      
      private const REWARD_POPUP_WINDOW:String = "assets/dialogs/expansion/FV_RewardDialog.swf";
      
      private const REWARD_POPUP_WINDOW_SHARE:String = "assets/dialogs/expansion/FV_RewardDialog_Share.swf";
      
      private const REWARD_WINDOW_IMAGE:String = "assets/dialogs/halloweenmad/RewardDialog.png";
      
      private var m_isEA:Boolean;
      
      public var m_window:HalloweenInnovationGhoulWindow = null;
      
      public var m_gameWindow:HalloweenInnovationGhoulGameWindow;
      
      public var m_windowFinal:HalloweenInnovationGhoulWindowFinal;
      
      private var m_isActive:Boolean = false;
      
      private var m_endTimeStamp:Number = 0;
      
      private var m_tasksById:Object = null;
      
      private var m_assetPaths:Object = {};
      
      private var m_resultObject:Object;
      
      private var m_InventionRewardPopup:GenericSingleRewardPopup;
      
      public var m_mapInventionToDeco:Array = new Array("marblessfurryfreak","marblessmadclaw","marblesssupremeshell","marblessdarkdoom");
      
      public var BONUS_HARVEST_MAP:Object = {
         "marblessfurryfreak":new Array("pkg_superfertilizerspackconsumablebundle_1","berry_pkg_arborists"),
         "marblessmadclaw":new Array("consume_turbo_charger","pkg_fawn_feed_1","animalfeedtrough_feed"),
         "marblesssupremeshell":new Array("pkg_farm_hands","fuel1","vehiclepart"),
         "marblessdarkdoom":new Array("pkg_instagrow_1pack","consume_unwither","pkg_xhx_treasureparts")
      };
      
      private var m_HalloweenInnovationGhoulHud:HudBottomHalloweenInnovationGhoulButton;
      
      private var m_currencyName:String = "task_points";
      
      public function HalloweenInnovationGhoulManager(featureName:String)
      {
         super(featureName);
         m_featureName = featureName;
         if(!this.featureConfig)
         {
            return;
         }
         this.parseFeatureConfig();
         this.startQuest();
         this.m_isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_HALLOWEENMAD);
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
      }
      
      public static function getInstance(featureName:String) : HalloweenInnovationGhoulManager
      {
         var instance:HalloweenInnovationGhoulManager = getInstanceOfClass(featureName,HalloweenInnovationGhoulManager) as HalloweenInnovationGhoulManager;
         return instance.featureConfig == null ? null : instance;
      }
      
      public static function getTimeLeft(key:String, throttleTime:int = 86400) : int
      {
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         return int(throttleTime - timeSinceLastFeed);
      }
      
      protected function parseFeatureConfig() : void
      {
         var asset:XML = null;
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
         }
      }
      
      public function getFinalFeatureUrl() : String
      {
         return this.m_assetPaths[FINAL_WINDOW];
      }
      
      public function getDialogUrl() : String
      {
         return this.m_assetPaths[WINDOW_MAIN];
      }
      
      public function getGameDialogUrl() : String
      {
         return this.m_assetPaths[WINDOW_GAME];
      }
      
      public function getInventionNames() : Array
      {
         return INVENTION_NAMES;
      }
      
      public function getInventionName(inventionId:int) : String
      {
         return INVENTION_NAMES[inventionId];
      }
      
      public function showMainUI() : void
      {
         var inventionData:Object = this.getActiveGameData();
         var activeInvention:int = int(inventionData.activeInvention);
         if(!this.hasExpiryDatePassedForFeature() && !this.hasFeatureExpired() && activeInvention <= this.FINAL_INVENTION)
         {
            this.m_window = new HalloweenInnovationGhoulWindow();
            UI.displayPopup(this.m_window);
         }
         else
         {
            this.m_windowFinal = new HalloweenInnovationGhoulWindowFinal();
            UI.displayPopup(this.m_windowFinal);
         }
      }
      
      public function showGameUI() : void
      {
         if(this.m_window)
         {
            this.m_window.tintWindow();
            this.m_window.enableInput = false;
            this.m_window.visible = false;
         }
         this.m_gameWindow = new HalloweenInnovationGhoulGameWindow();
         UI.displayPopup(this.m_gameWindow,false);
      }
      
      public function showInventionRewardPopup(invention:int, part:int) : void
      {
         var featureKey:String = m_featureName + "_inventionReward";
         var rewardItem:FarmItem = this.getRewardObject(invention,part);
         this.m_InventionRewardPopup = new GenericSingleRewardPopup(this.REWARD_POPUP_WINDOW_SHARE,featureKey,rewardItem,this.postInventionShare(rewardItem),this.REWARD_WINDOW_IMAGE);
         UI.displayPopup(this.m_InventionRewardPopup,false);
      }
      
      public function postInventionShare(rewardItem:FarmItem) : Function
      {
         return function(event:Event):void
         {
            var windowName:* = "HalloweenInnovationGhoul";
            var bundleId:* = windowName + "ShareInvention";
            var imageIcon:* = rewardItem.iconUrl;
            var bundleData:* = {
               "images":[{
                  "href":"{SN_APP_URL}",
                  "src":imageIcon
               }],
               "actor":Global.player.name,
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
      
      public function updateGrid(cellIndex:int, row:int, col:int, activeInvention:int, activePart:int, callback:Function) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"revealCell",callback,[m_featureName,cellIndex,row,col,activeInvention,activePart]),true);
      }
      
      public function getActiveGameData() : Object
      {
         var activePart:int = 0;
         var inventionData:Object = this.getFeatureOptionsKey(this.GAME_INVENTIONS_KEY);
         var result:Object = {};
         var activeInvention:int = this.decryptData(inventionData.activeInvention);
         if(activeInvention > this.FINAL_INVENTION)
         {
            activePart = this.decryptData(inventionData.inventions[0].activePart);
            result[this.KEY_GAME_DATA] = inventionData.inventions[0].parts[0];
         }
         else
         {
            activePart = this.decryptData(inventionData.inventions[0].activePart);
            result[this.KEY_GAME_DATA] = inventionData.inventions[0].parts[0];
         }
         result[KEY_ACTIVE_INVENTION] = activeInvention;
         result[KEY_ACTIVE_PART] = activePart;
         return result;
      }
      
      public function getFireboltIcon() : String
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(HALLOWEEN_ORDERBOARD_POINTS_ITEM_CODE);
         return item.icon;
      }
      
      public function getRewardName(invention:int, part:int) : String
      {
         var rewards:Array = this.getFeatureOptionsKey(KEY_REWARDS) as Array;
         return rewards[invention * NUM_INVENTIONS + part];
      }
      
      private function getRewardObject(invention:int, part:int) : FarmItem
      {
         var rewardName:String = this.getRewardName(invention,part);
         return Global.farmGameSettingsManager.getFarmItemByName(rewardName);
      }
      
      public function getRewardIcon(invention:int, part:int) : String
      {
         var reward:FarmItem = this.getRewardObject(invention,part);
         return reward.icon;
      }
      
      public function getFriendlyNameForReward(invention:int, part:int) : String
      {
         var reward:FarmItem = this.getRewardObject(invention,part);
         return reward.friendlyTitle;
      }
      
      public function addRewardToGiftBox(invention:int, part:int) : void
      {
         var rewardName:String = this.getRewardName(invention,part);
         Global.player.addGift(rewardName);
      }
      
      public function get currencyName() : String
      {
         return this.m_currencyName;
      }
      
      public function encryptData(data:String) : String
      {
         var encryptionManager:SimpleCryptoManager = new SimpleCryptoManager();
         encryptionManager.init();
         return encryptionManager.encrypt(data);
      }
      
      public function getAssetURL(category:String, invention:int, part:int) : String
      {
         var categoryToFileNameMap:Object = {};
         var location:String = "assets/newsfeed/{0}";
         var inventionName:String = INVENTION_NAMES[invention].split(" ").join("").toLowerCase();
         categoryToFileNameMap[this.ANIMAL_ICON] = StringUtil.substitute("marbless{0}{1}.png",inventionName,part);
         categoryToFileNameMap[this.ANIMAL_ICON_LARGE] = StringUtil.substitute("marbless{0}{1}_200.png",inventionName,part);
         categoryToFileNameMap[this.ANIMAL_FINAL_ICON_LARGE] = StringUtil.substitute("marbless{0}_icon_200.png",inventionName);
         categoryToFileNameMap[this.PART_ICON_BORDERLESS_LARGE] = StringUtil.substitute("{0}part{1}.png",inventionName,part + 1);
         categoryToFileNameMap[this.PART_ICON_WITH_BORDER_LARGE] = StringUtil.substitute("{0}part{1}_100.png",inventionName,part + 1);
         categoryToFileNameMap[this.PART_ICON_SMALL] = StringUtil.substitute("{0}part{1}_35.png",inventionName,part + 1);
         if(category == this.ANIMAL_FINAL_ICON_LARGE)
         {
            return Global.getAssetURL(StringUtil.substitute("assets/decorations/{0}",categoryToFileNameMap[category]));
         }
         return Global.getAssetURL(StringUtil.substitute(location,categoryToFileNameMap[category]));
      }
      
      public function decryptData(data:String) : int
      {
         var encryptionManager:SimpleCryptoManager = new SimpleCryptoManager();
         encryptionManager.init();
         var decryptedStr:String = encryptionManager.decrypt(data);
         var cellArray:Array = decryptedStr.split("_");
         return int(cellArray[1]);
      }
      
      public function decryptItem(data:String) : String
      {
         var encryptionManager:SimpleCryptoManager = new SimpleCryptoManager();
         encryptionManager.init();
         var decryptedStr:String = encryptionManager.decrypt(data);
         var cellArray:Array = decryptedStr.split("_");
         var itemName:String = "";
         for(var i:int = 3; i < cellArray.length; i++)
         {
            itemName += cellArray[i];
            if(i != cellArray.length - 1)
            {
               itemName += "_";
            }
         }
         return itemName;
      }
      
      public function isInventionsCompleted() : Boolean
      {
         var result:Boolean = false;
         var inventionData:Object = this.getActiveGameData();
         var activeInvention:int = int(inventionData.activeInvention);
         if(activeInvention > this.FINAL_INVENTION)
         {
            result = true;
         }
         return result;
      }
      
      public function hasFeatureExpired() : Boolean
      {
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("HalloweenInnovationGhoul_FeatureCompletion_prereq");
         return !PrerequisiteUtility.isPrerequisiteMet(prereq);
      }
      
      public function hasExpiryDatePassedForFeature() : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var result:Boolean = false;
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber(this.m_endTimeStamp.toString()) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         timeLeft = endTime - now;
         if(timeLeft <= 0)
         {
            result = true;
         }
         return result;
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
      
      public function getFeatureOptionsKey(optionName:String) : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,optionName);
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
      }
      
      public function saveFeatureOptionsKey(optionName:String, optionsValue:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,optionName,optionsValue);
      }
      
      public function enableInventionPreviewFrame(sourceIsGameWindow:Boolean = true, invention:int = 0) : void
      {
         if(this.m_window)
         {
            this.m_window.showInventionPreviewFrame(invention);
         }
      }
      
      public function tintMainWindow() : void
      {
         if(this.m_window)
         {
            this.m_window.enableInput = false;
            this.m_window.tintWindow();
         }
      }
      
      public function unTintMainWindow() : void
      {
         if(this.m_window)
         {
            this.m_window.enableInput = true;
            this.m_window.untintWindow();
         }
      }
      
      public function disbaleInventionPreviewFrame(sourceIsGameWindow:Boolean = true) : void
      {
         if(this.m_window)
         {
            this.m_window.closeInventionPreviewFrame();
         }
      }
      
      public function getOrderboardProgress() : Number
      {
         return FeatureOptionsInventoryManager.getInstance().getCount(HALLOWEEN_ORDERBOARD_POINTS_ITEM_CODE);
      }
      
      public function addOrderboardProgress(fireboltCount:int) : void
      {
         FeatureOptionsInventoryManager.getInstance().addCount(HALLOWEEN_ORDERBOARD_POINTS_ITEM_CODE,fireboltCount);
      }
      
      public function reduceOrderboardProgress(fireboltCount:int) : void
      {
         FeatureOptionsInventoryManager.getInstance().removeCount(HALLOWEEN_ORDERBOARD_POINTS_ITEM_CODE,fireboltCount);
      }
      
      public function showBoostUI() : void
      {
         UI.displayMiniMarketDialog(m_marketItems,null,"seed",null,true,false,false,true);
         this.m_window.close();
      }
      
      private function get unlockedTilesCountTotal() : int
      {
         var tileObjects:Array = null;
         var lockedTilesCount:int = 0;
         for(var i:int = 0; i < 9; i++)
         {
            tileObjects = Global.world.getObjectsByName(m_marketItems[i]);
            if(Boolean(tileObjects) && tileObjects.length > 0)
            {
               lockedTilesCount++;
            }
         }
         return 9 - lockedTilesCount;
      }
      
      public function unlockedTilesCountCurrent() : int
      {
         var previousCount:int = this.getFeatureOptionsKey(KEY_TILE_UNLCOKED_COUNT) as int;
         var tilesUnlockedThisSession:int = this.unlockedTilesCountTotal - previousCount;
         if(previousCount == this.unlockedTilesCountTotal)
         {
            return 0;
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"updateTileUnlockCount",null,[m_featureName,this.unlockedTilesCountTotal]));
         this.saveFeatureOptionsKey(KEY_TILE_UNLCOKED_COUNT,this.unlockedTilesCountTotal);
         return tilesUnlockedThisSession;
      }
      
      public function setupHalloweenInnovationGhoulHud() : void
      {
         if(!this.hasExpiryDatePassedForFeature())
         {
            this.m_HalloweenInnovationGhoulHud = new HudBottomHalloweenInnovationGhoulButton(HUD_HALLOWEENINNOVATIONGHOUL_ASSET,m_featureName);
            Global.hud.setBottomHudHalloweenInnovationGhoulButton(this.m_HalloweenInnovationGhoulHud as HudBottomHalloweenInnovationGhoulButton);
         }
      }
      
      public function initEventListener() : void
      {
         GlobalEventManager.getInstance().addEventListener(EVENT_HALLOWEEN_INNOVATION_GHOUL_TILE_UNLOCK,this.showGrantPopup);
      }
      
      public function deleteEventListener() : void
      {
         GlobalEventManager.getInstance().removeEventListener(EVENT_HALLOWEEN_INNOVATION_GHOUL_TILE_UNLOCK,this.showGrantPopup);
      }
      
      public function showGrantPopup(e:TileUnlockEvent = null) : void
      {
         if(this.isInventionsCompleted() == false)
         {
            UI.displayPopup(new CarribeanTileUnlockWindow(this.TILE_UNLOCK_ASSET,m_featureName,e.tileData.getItemName()));
         }
      }
      
      public function getFeatureExpiryTime() : Array
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
      
      public function isFinalRewardChosen() : Boolean
      {
         return this.getRewardBuildingName() != null && this.getRewardBuildingName() != "0";
      }
      
      public function getRewardBuildingName() : String
      {
         return this.getFeatureOptionsKey(KEY_SAVED_FINAL_REWARD_BUILDINGNAME) as String;
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
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("HalloweenInnovationGhoul_innovation_harvest_enabled");
         if(!PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            result = false;
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
      
      public function harvestFinalDecos(itemName:String = null) : void
      {
         var featureKey:String = null;
         var key:String = itemName + this.LAST_HARVEST_TIME_KEY;
         Global.player.setFeatureLastShown(key,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         var harvestRewardName:String = this.getNextHarvestItemName(itemName);
         var harvestFarmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(harvestRewardName);
         if(harvestFarmItem)
         {
            Global.player.addGift(harvestRewardName);
            featureKey = m_featureName + this.LAST_HARVEST_TIME_KEY;
            FarmStatsManager.count(m_featureName,"Harvest",itemName,harvestRewardName);
            UI.displayPopup(new GenericSingleRewardPopup(this.REWARD_POPUP_WINDOW,featureKey,harvestFarmItem,null,this.REWARD_WINDOW_IMAGE),false);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,SERVICE_FUNC_HARVEST_BONUS,null,[m_featureName,itemName]),true);
         }
      }
      
      public function hasHarvestExpiryDatePassedForFeature(itemName:String) : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var timeRemain:int = 0;
         var finishTime:Number = NaN;
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("12/10/2018") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         timeLeft = endTime - now;
         if(timeLeft < 0)
         {
            timeRemain = this.getTimeLeftForBonusHarvest(itemName);
            finishTime = FarmGameUtil.synchronizedDateTimeToNumber("12/11/2018") / FarmGameUtil.NUM_MSECS_IN_SECOND;
            return finishTime - now <= timeRemain;
         }
         return false;
      }
      
      public function getHarvestTime(itemName:String) : String
      {
         var secondsLeft:int = this.getTimeLeftForBonusHarvest(itemName);
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
                  taskObj = {};
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
            if(this.m_HalloweenInnovationGhoulHud)
            {
               this.m_HalloweenInnovationGhoulHud.refresh(1);
            }
         }
      }
      
      protected function onTransactionAdded(event:TransactionEvent) : void
      {
         this.checkForTaskUpdates(event);
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
      
      public function saveBushelProgress() : void
      {
      }
      
      public function isFinalRewardGranted() : Boolean
      {
         var finalRewardTaken:int = this.getFeatureOptionsKey(this.KEY_SAVED_FINAL_REWARD_RECEIVED) as int;
         return !!finalRewardTaken;
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
      
      public function getNPCProgress() : Number
      {
         return FeatureOptionsInventoryManager.getInstance().getCount(HALLOWEEN_GHOUL_FEATURE_POINTS_ITEM_CODE);
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
      
      public function canDumpTask(questIndex:int) : Boolean
      {
         var currentTime:Number = NaN;
         var result:Boolean = true;
         var throttleTimeInSeconds:Number = 2 * FarmGameUtil.NUM_SECS_IN_HOUR;
         var dumpTimestamp:Object = this.getFeatureOptionsKey(this.KEY_SAVED_DUMPED_TIMESTAMP) as Object;
         if(dumpTimestamp != null && dumpTimestamp.hasOwnProperty(questIndex.toString()))
         {
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            result = currentTime - dumpTimestamp[questIndex] > throttleTimeInSeconds;
         }
         return result;
      }
      
      public function dumpTask(questIndex:int, callback:Function) : void
      {
         var dumpTimestamp:Object = null;
         if(this.canDumpTask(questIndex))
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"dumpTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
            dumpTimestamp = this.getFeatureOptionsKey(this.KEY_SAVED_DUMPED_TIMESTAMP) as Object;
            if(dumpTimestamp == null)
            {
               dumpTimestamp = new Object();
            }
            dumpTimestamp[questIndex] = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            this.saveFeatureOptionsKey(this.KEY_SAVED_DUMPED_TIMESTAMP,dumpTimestamp);
         }
      }
      
      public function getTimeRemainingForDumpedTask(questIndex:int) : Number
      {
         var result:Number = NaN;
         var currentTime:Number = NaN;
         var throttleTimeInSeconds:Number = 2 * FarmGameUtil.NUM_SECS_IN_HOUR;
         var dumpTimestamp:Object = this.getFeatureOptionsKey(this.KEY_SAVED_DUMPED_TIMESTAMP) as Object;
         if(dumpTimestamp != null && dumpTimestamp.hasOwnProperty(questIndex.toString()))
         {
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            result = throttleTimeInSeconds - (currentTime - dumpTimestamp[questIndex]);
         }
         return result;
      }
      
      public function skipDumpedTask(questIndex:int, callback:Function) : void
      {
         var dumpTimestamp:Object = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         if(Global.player.canBuyCash(this.SKIP_COST))
         {
            Global.player.cash -= this.SKIP_COST;
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipDumpedTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
            dumpTimestamp = this.getFeatureOptionsKey(this.KEY_SAVED_DUMPED_TIMESTAMP) as Object;
            dumpTimestamp[questIndex] = 0;
            this.saveFeatureOptionsKey(this.KEY_SAVED_DUMPED_TIMESTAMP,dumpTimestamp);
            this.resetActionCountsForTasks(tasks[questIndex]);
         }
         else
         {
            callback.call();
         }
      }
      
      public function skipTask(questIndex:int, taskPoints:int, callback:Function) : void
      {
         var savedTasks:Array = null;
         var tasks:Vector.<FarmTask> = this.getTasks();
         if(Global.player.canBuyCash(tasks[questIndex].skipCashValue))
         {
            Global.player.cash -= tasks[questIndex].skipCashValue;
            this.grantPointsForTask(taskPoints);
            savedTasks = this.getFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS) as Array;
            savedTasks[questIndex][this.KEY_PROGRESS] = tasks[questIndex].total;
            this.saveFeatureOptionsKey(KEY_SAVED_ACTIVE_TASKS,savedTasks);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
            this.resetActionCountsForTasks(tasks[questIndex]);
            this.updateBoardFrameNumber();
         }
         else
         {
            callback.call();
         }
      }
      
      public function getNewTasks(questIndex:int, callback:Function) : void
      {
         var tasks:Vector.<FarmTask> = this.getTasks();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"getNewTask",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
         var dumpTimestamp:Object = this.getFeatureOptionsKey(this.KEY_SAVED_DUMPED_TIMESTAMP) as Object;
         dumpTimestamp[questIndex] = 0;
         this.saveFeatureOptionsKey(this.KEY_SAVED_DUMPED_TIMESTAMP,dumpTimestamp);
         this.resetActionCountsForTasks(tasks[questIndex]);
      }
      
      public function grantPointsForTask(pointsForTask:int) : void
      {
         var currentProgress:Number = this.getOrderboardProgress();
         if(currentProgress < this.VAL_FINAL_MILESTONE)
         {
            FeatureOptionsInventoryManager.getInstance().addCount(HALLOWEEN_ORDERBOARD_POINTS_ITEM_CODE,pointsForTask);
            if(this.m_window)
            {
               this.m_window.refreshConsumableFrame();
            }
            if(!Global.player.getSeenFlag(FEATURE_FORCED_TUT_FRIST_STEP) && currentProgress + pointsForTask >= 5 && Boolean(this.m_window))
            {
               Global.player.setSeenFlag(FEATURE_FORCED_TUT_FRIST_STEP);
            }
         }
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
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkGold",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
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
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkBushel",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
         StatsManager.count(m_featureName,"Sink Bushel","",tasks[questIndex].total.toString(),this.getOrderboardProgress().toString());
      }
      
      public function getBoardFrameNumber() : Number
      {
         return this.getFeatureOptionsKey(KEY_SAVED_BOARD_COUNT) as Number;
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
      
      public function redeemRewardPoints(questIndex:int, callback:Function, taskPoints:int = 0) : void
      {
         var tasks:Vector.<FarmTask> = this.getTasks();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"redeemRewardPoints",ZCacheUtil.applyPartial(this.onInitQuestComplete,this,[callback]),[m_featureName,questIndex]),true);
         this.resetActionCountsForTasks(tasks[questIndex]);
         this.updateBoardFrameNumber();
      }
   }
}

