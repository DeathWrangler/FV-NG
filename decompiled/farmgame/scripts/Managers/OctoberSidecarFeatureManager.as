package Managers
{
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.HUD.HUD;
   import Display.HUD.HUDWidgets.HudBottomOctoberSidecarFeature;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.Crafting.CraftingManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.GenericSingleRewardPopup;
   import Widgets.Windows.OctoberSidecarFeatureCollectionsWindow;
   import Widgets.Windows.OctoberSidecarFeatureMainWindow;
   import Widgets.Windows.OctoberSidecarFeatureRewardPopup;
   import Widgets.Windows.OctoberSidecarFeatureSearchResultPopup;
   import Widgets.Windows.OctoberSidecarFeatureTilesInfoWindow;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class OctoberSidecarFeatureManager extends BaseFeatureManager
   {
      
      private static const FEATURE_NAME:String = "GilroysParade";
      
      private static const SERVICE_NAME:String = "OctoberSidecarFeatureService";
      
      public static const FEATURE_PREREQ_NAME:String = "october_sidecar_feature_enabled";
      
      public static const FEATURE_END_DATE:String = "11/09/2020";
      
      public const FEATURE_TRACKING:String = "GilroysParade";
      
      private const PATH_MAIN_WINDOW:String = "assets/dialogs/october_2020_gilroysparade/FV_MainScreen_GilroysParade.swf";
      
      private const PATH_TILESINFO_WINDOW:String = "assets/dialogs/october_2020_gilroysparade/FV_TilesInfo_GilroysParade.swf";
      
      private const PATH_COLLECTIONS_WINDOW:String = "assets/dialogs/october_2020_gilroysparade/FV_collections_GilroysParade.swf";
      
      private const PATH_SEARCH_RESULT_POPUP:String = "assets/dialogs/october_2020_gilroysparade/FV_FoundConsumable_GilroysParade.swf";
      
      private const PATH_REWARD_POPUP:String = "assets/dialogs/october_2020_gilroysparade/FV_RewardScreen_GilroysParade.swf";
      
      private const PATH_FEATURE_HUD:String = "assets/dialogs/october_2020_gilroysparade/FV_Hud_GilroysParade.swf";
      
      public var m_mainWindow:OctoberSidecarFeatureMainWindow;
      
      public var m_tilesInfoWindow:OctoberSidecarFeatureTilesInfoWindow;
      
      public var m_collectionsWindow:OctoberSidecarFeatureCollectionsWindow;
      
      public var m_searchResultPopup:OctoberSidecarFeatureSearchResultPopup;
      
      public var m_rewardPopup:OctoberSidecarFeatureRewardPopup;
      
      public var m_featureHud:HudBottomOctoberSidecarFeature;
      
      public const NUM_CONSUMABLES:int = 3;
      
      public const CONSUMABLES_ITEM_CODES:Array = new Array("2p5o","2pj0","2ph4");
      
      public const CONSUMABLES_CRAFT_KEYWORDS:Array = new Array("maggies spyglass","pumpkin flashlight","detective backpack");
      
      public const CONSUMABLES_FRIENDLY_NAMES:Array = new Array("Maggie\'s Spy Glass","Pumpkin Flashlight","Detective Backpack");
      
      public const CONSUMABLES_BUY_COST:Array = new Array(2,3,5);
      
      public const MIN_DROP_CHANCE:Array = new Array(10,20,30);
      
      public const MAX_DROP_CHANCE:Array = new Array(20,30,40);
      
      public const KEY_ACTIVE_ITEM:String = "active_item";
      
      public const KEY_PROGRESS_MAP:String = "progress_map";
      
      public const KEY_SEARCH_START_TIME:String = "search_start";
      
      public const KEY_SEARCHING:String = "is_searching";
      
      public const KEY_TILE_UNLOCK_COUNT:String = "tiles_count";
      
      public const KEY_COMPLETED_COUNT:String = "num_complete";
      
      public const KEY_MILESTONE_INDEX:String = "ms_index";
      
      public const KEY_FEATURE_COMPLETE:String = "feature_complete";
      
      public const KEY_BONUS_HARVEST_START_TIME:String = "bonus_harvest_start";
      
      public const KEY_BONUS_HARVEST_INDEX:* = "harvest_index";
      
      private var m_notifyTimer:Timer;
      
      public const NUM_TOTAL_ITEMS:int = 9;
      
      public const NUM_TOTAL_PARTS:int = 100;
      
      public const NUM_PARTS_PER_STAGE:int = 20;
      
      public const NUM_STAGES_PER_ITEM:int = 5;
      
      public const SEARCH_TIME_MINUTES:int = 10;
      
      public const SEARCH_SKIP_COST:int = 2;
      
      public const DEFAULT_DROP_CHANCE:int = 10;
      
      public const DEFAULT_HARVEST_THROTTLE_TIME:int = 86400;
      
      public const ITEM_COMPLETE_REWARD:String = "pkg_antique_farm_essentials";
      
      public const PREFIX_STAGE_ICON_PATH:String = "assets/dialogs/october_2020_gilroysparade/stageIcons/";
      
      public const SUFFIX_STAGE_ICON_PATH:String = "_icon_175.png";
      
      public const PATH_GENERIC_REWARD_POPUP:String = "assets/dialogs/expansion/FV_RewardDialog.swf";
      
      public const PATH_EXPANSION_REWARD_DIALOG:String = "assets/dialogs/pumpkin/RewardDialog.png";
      
      public const LAST_HARVEST_TIME_KEY:String = "_lastHarvestTimeKey";
      
      public const m_milestonePoints:Array = new Array(1,2,4,6,8,9);
      
      public const m_milestoneRewards:Array = new Array("cow_xpu_pumpkinshades","horse_xpu_tigerstripes","unicorn_xpu_periwinklewitch","pegasus_xpu_halloweenknight","pegacorn_xpu_pumpkinscale","xpu_maggiesmysterybureau");
      
      public const m_stolenItems:Array = new Array("xpu_gothicwitchcauldron","xpu_piggargoyle","xpu_pumpkintotem","xpu_pumpkincemetary","xpu_pumpkinparadegnomes","xpu_pumpkinparadespider","xpu_pumpkinparadechariot","xpu_paradegnomefloat","xpu_pumpkingrandstand");
      
      public const m_bonusHarvestList:* = new Array("consume_instagrow","pkg_xpu_bbparts_sidecar","consume_turbo_charger","consume_unwither","consume_organic_fertilizer","fuel1","vehiclepart","pkg_xpu_treasureparts_sidecar","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard");
      
      public const m_tilesList:* = new Array("xpu_rubbletreasure1","xpu_rubbletreasure3","xpu_rubbletreasure4","xpu_rubbletreasure6","xpu_rubbletreasure7","xpu_rubbletreasure8","xpu_rubbletreasure9","xpu_rubbletreasure10","xpu_rubbletreasure11","xpu_rubbletreasure12","xpu_rubbletreasure13","xpu_rubbletreasure14","xpu_rubbletreasure_payer1","xpu_rubbletreasure_payer2","xpu_rubbletreasure_payer3","xpu_rubbletreasure_payer4","xpu_rubbletreasure_payer5","xpu_rubbletreasure_payer6","xpu_rubbletreasure_payer7","xpu_rubbletreasure_payer8","xpu_rubbletreasure_payer9","xpu_rubbletreasure_payer10","xpu_rubbletreasure_payer11","xpu_rubbletreasure_payer16","xpu_rubbletreasure_payer17","xpu_rubbletreasure_payer18","xpu_rubbletreasure_payer19");
      
      public function OctoberSidecarFeatureManager(featureName:String)
      {
         super(featureName);
         this.startQuest();
      }
      
      public static function getInstance(featureName:String = "GilroysParade") : OctoberSidecarFeatureManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,OctoberSidecarFeatureManager) as OctoberSidecarFeatureManager;
      }
      
      public function startQuest() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startQuest",this.onStartQuestCallback,[FEATURE_NAME]),true);
      }
      
      private function onStartQuestCallback(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("featureData"))
         {
            FeatureOptionsManager.getInstance().setFeature(FEATURE_NAME,result["featureData"]);
         }
      }
      
      public function craftConsumable(consumableIndex:int) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
         var craftSearchKey:String = this.CONSUMABLES_CRAFT_KEYWORDS[consumableIndex];
         CraftingManager.getInstance().openCraftshopWindow(CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType),craftSearchKey,this.m_mainWindow,"consumable");
      }
      
      public function getConsumableCount(consumableIndex:int) : int
      {
         return int(FeatureOptionsInventoryManager.getInstance().getCount(this.CONSUMABLES_ITEM_CODES[consumableIndex]));
      }
      
      public function getConsumableBuyConfirmText(consumableIndex:int) : String
      {
         return "Do you want to spend " + this.CONSUMABLES_BUY_COST[consumableIndex] + " Farm Cash to buy a " + this.CONSUMABLES_FRIENDLY_NAMES[consumableIndex] + "?";
      }
      
      public function buyConsumable(consumableIndex:int) : void
      {
         var itemCode:String = null;
         var amount:int = int(this.CONSUMABLES_BUY_COST[consumableIndex]);
         if(Global.player.canBuyCash(amount))
         {
            Global.player.cash -= amount;
            itemCode = this.CONSUMABLES_ITEM_CODES[consumableIndex];
            FeatureOptionsInventoryManager.getInstance().addCount(itemCode,1);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onBuyConsumable",null,[FEATURE_NAME,itemCode]),true);
         }
         if(this.m_mainWindow)
         {
            this.m_mainWindow.refreshWindow();
         }
      }
      
      public function sinkConsumables() : void
      {
         for(var index:int = 0; index < this.NUM_CONSUMABLES; index++)
         {
            if(this.getConsumableCount(index) > 0)
            {
               FeatureOptionsInventoryManager.getInstance().removeCount(this.CONSUMABLES_ITEM_CODES[index],1);
            }
         }
         if(this.m_mainWindow)
         {
            this.m_mainWindow.updateConsumableSection();
         }
      }
      
      public function sendForSearch() : void
      {
         if(this.isSearchingState() == 0)
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onStartSearching",this.onSendSearchCallback,[FEATURE_NAME]),true);
            this.sinkConsumables();
            this.saveFeatureOptionsKey(this.KEY_SEARCH_START_TIME,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND);
            this.saveFeatureOptionsKey(this.KEY_SEARCHING,1);
         }
      }
      
      public function onSendSearchCallback(result:Object) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.enableSkipSearchButton();
         }
      }
      
      public function onSkipSearchByCash() : void
      {
         if(this.isSearchingState() == 1)
         {
            if(this.m_mainWindow)
            {
               this.m_mainWindow.enableInput = false;
               this.m_mainWindow.tintWindow();
            }
            if(Global.player.canBuyCash(this.SEARCH_SKIP_COST))
            {
               Global.player.cash -= this.SEARCH_SKIP_COST;
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onSkipSearchByCash",this.checkAndGrantClues,[FEATURE_NAME]),true);
            }
         }
      }
      
      public function onSearchTimeExpire() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.enableInput = false;
            this.m_mainWindow.tintWindow();
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onSearchTimeExpire",this.checkAndGrantClues,[FEATURE_NAME]),true);
      }
      
      private function checkAndGrantClues(result:Object) : void
      {
         var progress:* = undefined;
         var progressMap:Object = null;
         var showCount:int = 0;
         this.saveFeatureOptionsKey(this.KEY_SEARCHING,0);
         if(Boolean(result) && result.hasOwnProperty("granted"))
         {
            if(result["granted"] == true)
            {
               if(result.hasOwnProperty("progress"))
               {
                  progress = result["progress"];
                  progressMap = this.getFeatureOptionsKey(this.KEY_PROGRESS_MAP) as Object;
                  showCount = progress - progressMap[this.currentActiveItem];
                  progressMap[this.currentActiveItem] = progress;
                  this.saveFeatureOptionsKey(this.KEY_PROGRESS_MAP,progressMap);
               }
               if(result.hasOwnProperty("next_item"))
               {
                  progressMap = this.getFeatureOptionsKey(this.KEY_PROGRESS_MAP) as Object;
                  showCount = this.NUM_TOTAL_PARTS - progressMap[this.currentActiveItem];
                  progressMap[this.currentActiveItem] = this.NUM_TOTAL_PARTS;
                  this.grantCompletedItemDeco(this.currentActiveItem);
                  this.saveFeatureOptionsKey(this.KEY_PROGRESS_MAP,progressMap);
                  this.saveFeatureOptionsKey(this.KEY_ACTIVE_ITEM,result["next_item"]);
                  this.saveFeatureOptionsKey(this.KEY_COMPLETED_COUNT,this.completedItemsCount + 1);
                  this.grantMilestoneRewards();
               }
               if(result.hasOwnProperty("bonus_start_time"))
               {
                  this.saveFeatureOptionsKey(this.KEY_BONUS_HARVEST_START_TIME,result["bonus_start_time"]);
                  this.saveFeatureOptionsKey(this.KEY_FEATURE_COMPLETE,1);
                  if(this.m_mainWindow)
                  {
                     this.m_mainWindow.showEndRevealScreen();
                  }
               }
            }
         }
         this.showSearchResultPopup(showCount);
         if(this.m_mainWindow)
         {
            this.m_mainWindow.refreshWindow();
         }
      }
      
      private function grantCompletedItemDeco(completedItemName:String) : void
      {
         Global.player.addGift(completedItemName);
         var completedItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(completedItemName);
         this.showRewardPopup(completedItem,3);
      }
      
      private function grantMilestoneRewards() : void
      {
         var milestone:int = 0;
         var rewardIndex:int = 0;
         var rewardName:String = null;
         var rewardItem:FarmItem = null;
         Global.player.addGift(this.ITEM_COMPLETE_REWARD);
         var itemCompleteReward:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.ITEM_COMPLETE_REWARD);
         this.showRewardPopup(itemCompleteReward,1);
         var isEligible:Boolean = false;
         for each(milestone in this.m_milestonePoints)
         {
            if(milestone == this.completedItemsCount)
            {
               isEligible = true;
            }
         }
         if(isEligible == true)
         {
            rewardIndex = this.currentMilestoneIndex;
            rewardName = this.m_milestoneRewards[rewardIndex];
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
            Global.player.addGift(rewardName);
            this.showRewardPopup(rewardItem,2,this.postFeedShare(rewardItem));
            this.saveFeatureOptionsKey(this.KEY_MILESTONE_INDEX,rewardIndex + 1);
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onGrantMilestoneRewards",null,[FEATURE_NAME]),true);
      }
      
      public function isSearchTimeExpired() : Boolean
      {
         var result:Boolean = false;
         var searchTime:Number = this.SEARCH_TIME_MINUTES * FarmGameUtil.NUM_SECS_IN_MINUTE;
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var startTimestamp:Number = this.getFeatureOptionsKey(this.KEY_SEARCH_START_TIME) as Number;
         if(currentTime - startTimestamp > searchTime)
         {
            result = true;
         }
         return result;
      }
      
      public function getSearchTimeRemaining() : Number
      {
         var result:Number = NaN;
         var searchTime:Number = this.SEARCH_TIME_MINUTES * FarmGameUtil.NUM_SECS_IN_MINUTE;
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var startTimestamp:Number = this.getFeatureOptionsKey(this.KEY_SEARCH_START_TIME) as Number;
         return searchTime - (currentTime - startTimestamp);
      }
      
      public function getSearchTimeRunningFraction() : Number
      {
         var result:Number = NaN;
         var searchTime:Number = this.SEARCH_TIME_MINUTES * FarmGameUtil.NUM_SECS_IN_MINUTE;
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var startTimestamp:Number = this.getFeatureOptionsKey(this.KEY_SEARCH_START_TIME) as Number;
         return (currentTime - startTimestamp) / searchTime;
      }
      
      public function isSearchingState() : int
      {
         return this.getFeatureOptionsKey(this.KEY_SEARCHING) as int;
      }
      
      public function get activeItemStage() : int
      {
         var result:int = 0;
         var progressArray:Object = this.getFeatureOptionsKey(this.KEY_PROGRESS_MAP) as Object;
         if(Boolean(progressArray) && progressArray.hasOwnProperty(this.currentActiveItem))
         {
            result = (progressArray[this.currentActiveItem] as int) / this.NUM_PARTS_PER_STAGE;
         }
         return result;
      }
      
      public function get activeStageClueCount() : int
      {
         var result:int = 0;
         var progressArray:Object = this.getFeatureOptionsKey(this.KEY_PROGRESS_MAP) as Object;
         if(Boolean(progressArray) && progressArray.hasOwnProperty(this.currentActiveItem))
         {
            result = (progressArray[this.currentActiveItem] as int) % this.NUM_PARTS_PER_STAGE;
         }
         return result;
      }
      
      public function get currentActiveItem() : String
      {
         return this.getFeatureOptionsKey(this.KEY_ACTIVE_ITEM) as String;
      }
      
      public function isItemActive(itemIndex:int) : Boolean
      {
         var result:Boolean = false;
         if(this.currentActiveItem == this.m_stolenItems[itemIndex])
         {
            result = true;
         }
         return result;
      }
      
      public function showMainWindow() : void
      {
         var tileCount:int = this.updateTileUnlockCount();
         this.m_mainWindow = new OctoberSidecarFeatureMainWindow(FEATURE_NAME,this.PATH_MAIN_WINDOW);
         UI.displayPopup(this.m_mainWindow,false);
         FarmStatsManager.count(this.FEATURE_TRACKING,"main_ui","open");
      }
      
      public function showTilesInfoWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.enableInput = false;
            this.m_mainWindow.tintWindow();
         }
         this.m_tilesInfoWindow = new OctoberSidecarFeatureTilesInfoWindow(FEATURE_NAME,this.PATH_TILESINFO_WINDOW);
         UI.displayPopup(this.m_tilesInfoWindow,false);
         FarmStatsManager.count(this.FEATURE_TRACKING,"tile_info_ui","open");
      }
      
      public function showCollectionsWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.enableInput = false;
            this.m_mainWindow.tintWindow();
         }
         this.m_collectionsWindow = new OctoberSidecarFeatureCollectionsWindow(FEATURE_NAME,this.PATH_COLLECTIONS_WINDOW);
         UI.displayPopup(this.m_collectionsWindow,false);
         FarmStatsManager.count(this.FEATURE_TRACKING,"collectionss_ui","open");
      }
      
      public function showRewardPopup(rewardItem:FarmItem, popupType:int, shareCallback:Function = null) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.enableInput = false;
            this.m_mainWindow.tintWindow();
         }
         this.m_rewardPopup = new OctoberSidecarFeatureRewardPopup(FEATURE_NAME,this.PATH_REWARD_POPUP,rewardItem,popupType,shareCallback);
         UI.displayPopup(this.m_rewardPopup,false);
         FarmStatsManager.count(this.FEATURE_TRACKING,"reward_popup","open");
      }
      
      public function isItemComplete(itemIndex:int) : Boolean
      {
         var result:Boolean = false;
         var progressMap:Object = this.getFeatureOptionsKey(this.KEY_PROGRESS_MAP) as Object;
         if(progressMap.hasOwnProperty(this.m_stolenItems[itemIndex]) && progressMap[this.m_stolenItems[itemIndex]] == this.NUM_TOTAL_PARTS)
         {
            result = true;
         }
         return result;
      }
      
      public function get currentDropChanceRange() : String
      {
         var minChance:int = 0;
         var maxChance:int = this.DEFAULT_DROP_CHANCE;
         for(var index:int = 0; index < this.NUM_CONSUMABLES; index++)
         {
            if(this.getConsumableCount(index) > 0)
            {
               minChance += this.MIN_DROP_CHANCE[index];
               maxChance += this.MAX_DROP_CHANCE[index];
            }
         }
         return minChance + "% to " + maxChance + "%";
      }
      
      public function get currentTileUnlockCount() : int
      {
         return this.getFeatureOptionsKey(this.KEY_TILE_UNLOCK_COUNT) as int;
      }
      
      public function get completedItemsCount() : int
      {
         return this.getFeatureOptionsKey(this.KEY_COMPLETED_COUNT) as int;
      }
      
      public function get currentMilestoneIndex() : int
      {
         return this.getFeatureOptionsKey(this.KEY_MILESTONE_INDEX) as int;
      }
      
      public function updateTileUnlockCount() : int
      {
         var tileName:String = null;
         var tileUnlockCount:int = 0;
         for each(tileName in this.m_tilesList)
         {
            if(this.isTileUnlocked(tileName))
            {
               tileUnlockCount++;
            }
         }
         this.saveFeatureOptionsKey(this.KEY_TILE_UNLOCK_COUNT,tileUnlockCount);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onUpdateTileUnlockCount",null,[FEATURE_NAME]),true);
         return tileUnlockCount;
      }
      
      public function isTileUnlocked(tileName:String) : Boolean
      {
         var result:Boolean = true;
         if(Global.world.getObjectsByName(tileName).length > 0)
         {
            result = false;
         }
         return result;
      }
      
      public function showSearchResultPopup(clueCount:int = 0) : void
      {
         this.m_searchResultPopup = new OctoberSidecarFeatureSearchResultPopup(FEATURE_NAME,this.PATH_SEARCH_RESULT_POPUP,clueCount);
         UI.displayPopup(this.m_searchResultPopup,false);
         FarmStatsManager.count(this.FEATURE_TRACKING,"search_results_ui","open");
      }
      
      public function isFeatureCompletedByUser() : Boolean
      {
         var result:Boolean = false;
         if(this.getFeatureOptionsKey(this.KEY_FEATURE_COMPLETE) as int == 1)
         {
            result = true;
         }
         return result;
      }
      
      public function isFeatureActive() : Boolean
      {
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName(FEATURE_PREREQ_NAME);
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            result = true;
         }
         return result;
      }
      
      public function setupHud() : void
      {
         this.m_featureHud = new HudBottomOctoberSidecarFeature(this.PATH_FEATURE_HUD,FEATURE_NAME);
         Global.hud.setBottomHudOctoberSidecarFeatureButton(this.m_featureHud as HudBottomOctoberSidecarFeature);
         this.m_featureHud.refresh(0);
         if(this.isSearchingState())
         {
            if(this.isSearchTimeExpired())
            {
               this.m_featureHud.refresh(1);
            }
            else
            {
               this.startNotifyTimer();
            }
         }
      }
      
      public function getFeatureEndDaysLeftText() : String
      {
         var days:int = 0;
         var endTime:Number = FarmGameUtil.synchronizedDateTimeToNumber(FEATURE_END_DATE);
         var timeLeft:Number = (endTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
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
               result = HUD.getformattedTimeLeft(timeLeft) + " left!";
            }
            else
            {
               result += " Days left!";
            }
         }
         return result;
      }
      
      public function startNotifyTimer() : void
      {
         this.m_notifyTimer = new Timer(1000);
         this.m_notifyTimer.addEventListener(TimerEvent.TIMER,this.onCheckNotifyTimer);
         this.m_notifyTimer.start();
      }
      
      private function onCheckNotifyTimer(event:TimerEvent) : void
      {
         if(this.isSearchTimeExpired())
         {
            this.stopNotifyTimer();
            if(this.m_featureHud)
            {
               this.m_featureHud.refresh(1);
            }
         }
      }
      
      public function stopNotifyTimer() : void
      {
         if(this.m_notifyTimer)
         {
            this.m_notifyTimer.stop();
            this.m_notifyTimer.removeEventListener(TimerEvent.TIMER,this.onCheckNotifyTimer);
            this.m_notifyTimer = null;
         }
      }
      
      public function postFeedShare(rewardItem:FarmItem) : Function
      {
         return function():void
         {
            var bundleId:* = undefined;
            var imageIcon:* = "";
            if(Boolean(rewardItem) && rewardItem.name == "xpu_maggiesmysterybureau")
            {
               bundleId = FEATURE_NAME + "ShareFinalReward";
            }
            else
            {
               bundleId = FEATURE_NAME + "ShareMilestone";
            }
            if(rewardItem)
            {
               imageIcon = rewardItem.iconUrl;
            }
            var bundleData:* = {
               "images":[{
                  "href":"{SN_APP_URL}",
                  "src":imageIcon
               }],
               "user":Global.player.name,
               "first_name":Global.player.firstName,
               "item":rewardItem.friendlyTitle,
               "number":completedItemsCount
            };
            GlobalEngine.socialNetwork.publishFeedStory(bundleId,bundleData,[],false,null);
         };
      }
      
      public function harvestBonusBuilding(buildingName:String) : void
      {
         var key:String = buildingName + this.LAST_HARVEST_TIME_KEY;
         Global.player.setFeatureLastShown(key,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         var harvestRewardName:String = this.getNextHarvestItemName();
         var harvestFarmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(harvestRewardName);
         if(harvestFarmItem)
         {
            Global.player.addGift(harvestRewardName);
            FarmStatsManager.count(this.FEATURE_TRACKING,"Harvest",buildingName,harvestRewardName);
            UI.displayPopup(new GenericSingleRewardPopup(this.PATH_GENERIC_REWARD_POPUP,"xpu_Bonus_",harvestFarmItem,null,this.PATH_EXPANSION_REWARD_DIALOG),false);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"harvestBonusBuilding",null,[FEATURE_NAME,buildingName]),true);
         }
      }
      
      private function getNextHarvestItemName() : String
      {
         var harvestIndex:int = this.getFeatureOptionsKey(this.KEY_BONUS_HARVEST_INDEX) as int;
         var harvestReward:String = this.m_bonusHarvestList[harvestIndex % this.m_bonusHarvestList.length];
         this.saveFeatureOptionsKey(this.KEY_BONUS_HARVEST_INDEX,harvestIndex + 1);
         return harvestReward;
      }
      
      public function get bonusHarvestStartTime() : Number
      {
         return this.getFeatureOptionsKey(this.KEY_BONUS_HARVEST_START_TIME) as Number;
      }
      
      private function getFeatureOptionsKey(optionName:String) : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,optionName);
      }
      
      private function saveFeatureOptionsKey(optionName:String, optionsValue:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,optionName,optionsValue);
      }
   }
}

