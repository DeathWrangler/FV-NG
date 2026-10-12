package Managers
{
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.HUD.HUD;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.Fishing2XBoostWindow;
   import Widgets.Windows.FishingCollectionWindow;
   import Widgets.Windows.FishingFeatureV2PostHarvestWindow;
   import Widgets.Windows.FishingRewardGrantWindow;
   import Widgets.Windows.FishingTackleBoxWindow;
   import Widgets.Windows.FishingV2CraftingWindow;
   import Widgets.Windows.FishingV2FinalPopUp;
   import Widgets.Windows.FishingV2MiniGameWindow;
   import Widgets.Windows.FishingV2SuccessPopUp;
   import Widgets.Windows.GenericSingleRewardPopup;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class FishingV2Manager extends BaseFeatureManager
   {
      
      public static const TYPE_ROD:int = 0;
      
      public static const TYPE_BAIT:int = 1;
      
      public static const TYPE_BOOST:int = 2;
      
      public static const SUBTYPE_BRONZE:int = 0;
      
      public static const SUBTYPE_SILVER:int = 1;
      
      public static const SUBTYPE_GOLD:int = 2;
      
      public static const ITEM_SUBTYPES:Array = [SUBTYPE_BRONZE,SUBTYPE_SILVER,SUBTYPE_GOLD];
      
      public static const PRICES_BAITS:Array = [1,2,3];
      
      public static const PRICES_RODS:Array = [2,4,6];
      
      public static const ROD_CRAFTING_DURATIONS:Array = [15,30,60];
      
      public static const BAIT_CRAFTING_DURATIONS:Array = [2,6,10];
      
      private static const R1:String = "r1";
      
      private static const R2:String = "r2";
      
      private static const R3:String = "r3";
      
      public static const RODS_COUNT_KEYS:Array = [R1,R2,R3];
      
      private static const B1:String = "b1";
      
      private static const B2:String = "b2";
      
      private static const B3:String = "b3";
      
      public static const BAITS_COUNT_KEYS:Array = [B1,B2,B3];
      
      private static const RU1:String = "ru1";
      
      private static const RU2:String = "ru2";
      
      private static const RU3:String = "ru3";
      
      public static const RODS_USAGE_COUNT_KEYS:Array = [RU1,RU2,RU3];
      
      private static const BU1:String = "bu1";
      
      private static const BU2:String = "bu2";
      
      private static const BU3:String = "bu3";
      
      public static const BAITS_USAGE_COUNT_KEYS:Array = [BU1,BU2,BU3];
      
      private static const FB1:String = "fb1";
      
      private static const FB2:String = "fb2";
      
      public static const BOOSTS_COUNT_KEYS:Array = [FB1,FB2];
      
      public static const BAIT_NAMES:Array = ["Small Candy","Rich Cotton Candy","Rainbow Marshmallow"];
      
      public static const RODS_NAMES:Array = ["Fruity Rod","Choco Pretzel Rod","Candy Hook Rod"];
      
      public static const BOOSTS_NAMES:Array = ["Fish Net","SONAR Device"];
      
      public static const FISH_NAMES:Array = [["Chocoscale Fish","Buttery Fish","Honey Gourami","Bubblegum Fish","Candy Basslet"],["Berry Flowerhorn","Freshcream Fish","Cookie Trout","Discus Lolly"],["Cherry Blossom","Chocodip fish","Candyfloss Betta"]];
      
      public static const FISH_CMS_NAME_ARRAY:* = [["genanimal_rainbowfish","genanimal_butteryfish","genanimal_honeygourami","genanimal_bubblegumfish","genanimal_candybasslet"],["genanimal_berryflowerhorn","genanimal_freshcreamfish","genanimal_cookietrout","genanimal_discuslolly"],["genanimal_cherryblossom","genanimal_chocodipfish","genanimal_candyflossbetta"]];
      
      public static const FISH_LENGTH:Array = [5,4,3];
      
      public static const FEATURE_NAME:String = "FishingV2";
      
      public static var m_selectedBait:int = -1;
      
      public static var m_selectedRod:int = -1;
      
      public static var m_selectedBoost:int = -1;
      
      private static const LAST_BONUS_HARVEST_TIME_KEY:String = "fishing_trophy_harvest_key";
      
      public static const DEFAULT_HARVEST_THROTTLE_TIME:Number = 86400;
      
      private const REWARD_SHARE_WINDOW:String = "assets/dialogs/expansion/FV_RewardDialog_Share.swf";
      
      private const SERVICE_CLASS:String = "FishingV2Service";
      
      private var m_staticData:Object;
      
      private var m_initialized:Boolean;
      
      private var m_assetPaths:Object;
      
      private var m_endDate:String;
      
      private var m_startDate:String;
      
      private var m_window:FishingCollectionWindow;
      
      private var m_2xBoostwindow:Fishing2XBoostWindow;
      
      private var m_miniGameWindow:FishingV2MiniGameWindow;
      
      private var m_tackleBoxWindow:FishingTackleBoxWindow;
      
      private var m_craftWindow:FishingV2CraftingWindow;
      
      private var m_finalPopUp:FishingV2FinalPopUp;
      
      private var m_getFishWaitWindow:GenericPopup;
      
      private var m_rewardDailyWindow:GenericSingleRewardPopup;
      
      private var m_rewardWindow:Array = [];
      
      private var m_singlerewardWindow:FishingRewardGrantWindow;
      
      private const BONUS_HARVEST_COUNT:String = "hc";
      
      private var MASTERY_HARVEST_ARRAY:Array = ["fuel1","vehiclepart","pkg_xcl_treasurepart_pack","fawn_feed","animalfeedtrough_feed","consume_arborists","consume_farm_hands","brick","nail","woodenboard"];
      
      private var m_rewradItem:FarmItem;
      
      private var m_rewardTrophy:FarmItem;
      
      private var m_rewradItemArray:Array = [];
      
      public function FishingV2Manager(featureName:String, featureConfig:XML = null)
      {
         super(featureName,featureConfig);
      }
      
      public static function getInstance(featureName:String = "FishingV2") : FishingV2Manager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,FishingV2Manager) as FishingV2Manager;
      }
      
      public static function isTutorial1Over() : Boolean
      {
         return Global.player.getSeenFlag("FISHING_V2_TUTORIAL1");
      }
      
      public static function isTutorial2Over() : Boolean
      {
         return Global.player.getSeenFlag("FISHING_V2_TUTORIAL2");
      }
      
      public function getFeatureData() : Object
      {
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,m_featureName);
         if(!featureData)
         {
            featureData = {};
            featureData[R1] = 2;
            featureData[R2] = 0;
            featureData[R3] = 1;
            featureData[B1] = 2;
            featureData[B2] = 0;
            featureData[B3] = 2;
            featureData[RU1] = 0;
            featureData[RU2] = 0;
            featureData[RU3] = 0;
            featureData[BU1] = 0;
            featureData[BU2] = 0;
            featureData[BU3] = 0;
            featureData[FB1] = 0;
            featureData[FB2] = 0;
            featureData["fishCollection"] = [];
            featureData["UniqueRewards"] = [];
            featureData["fishCollection"][0] = [0,0,0,0,0];
            featureData["fishCollection"][1] = [0,0,0,0];
            featureData["fishCollection"][2] = [0,0,0];
            featureData["UniqueRewards"][0] = [0,0,0,0,0];
            featureData["UniqueRewards"][1] = [0,0,0,0];
            featureData["UniqueRewards"][2] = [0,0,0];
            featureData["boot"] = 0;
            setFeatureData(featureData);
         }
         return featureData;
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
            this.m_initialized = true;
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
               this.m_endDate = featureXML.listEndDate.toString();
            }
            if(featureXML.listStartDate)
            {
               this.m_startDate = featureXML.listStartDate.toString();
            }
         }
      }
      
      public function get fishCollectionWindow() : String
      {
         return "assets/dialogs/fishing_feature/FV_fishing_collection.swf";
      }
      
      public function get baitCollectionWindow() : String
      {
         return this.m_assetPaths["baitCollectionWindow"];
      }
      
      public function get fishingMasteryTrophyWindow() : String
      {
         return "assets/dialogs/fishing_feature/FV_window_fishing_feature_trophy.swf";
      }
      
      public function get fishingSuccessPopUpURL() : String
      {
         return "assets/dialogs/fishing_feature/FV_fishing_success.swf";
      }
      
      public function get fishingFailurePopUpURL() : String
      {
         return "assets/dialogs/fishing_feature/FV_fishing_fail.swf";
      }
      
      public function get tackleBoxWindowURL() : String
      {
         return "assets/dialogs/fishing_feature/FV_tackle_box.swf";
      }
      
      public function get craftingWindowURL() : String
      {
         return "assets/dialogs/fishing_feature/FV_bait_shop.swf";
      }
      
      public function get miniGameWindowURL() : String
      {
         return "assets/dialogs/fishing_feature/FV_mini_game.swf";
      }
      
      public function get fishing2XWindowUrl() : String
      {
         return "assets/dialogs/fishing_feature/FV_window_fishing_feature.swf";
      }
      
      public function showFishCollectionsWindow() : void
      {
         this.m_window = new FishingCollectionWindow(m_featureName,this.fishCollectionWindow);
         UI.displayPopup(this.m_window,false);
      }
      
      public function showWaterTileBoostWindow() : void
      {
         if(this.m_window)
         {
            this.m_window.tintWindow();
            this.m_window.enableInput = false;
         }
         if(this.m_tackleBoxWindow)
         {
            this.m_tackleBoxWindow.tintWindow();
            this.m_tackleBoxWindow.enableInput = false;
         }
         this.m_2xBoostwindow = new Fishing2XBoostWindow(m_featureName,this.fishing2XWindowUrl,this.m_window,this.m_tackleBoxWindow);
         UI.displayPopup(this.m_2xBoostwindow,false);
      }
      
      public function openMiniGame() : void
      {
         FarmStatsManager.count(FEATURE_NAME,"equipmentshop","gofishing");
         this.m_miniGameWindow = new FishingV2MiniGameWindow(m_featureName,this.miniGameWindowURL);
         UI.displayPopup(this.m_miniGameWindow,false);
      }
      
      public function showFishingSuccessPopUp(fishType:int, fishIndex:int, isBoot:Boolean, firstTimeReward:String) : void
      {
         UI.displayPopup(new FishingV2SuccessPopUp(this.fishingSuccessPopUpURL,fishType,fishIndex,isBoot,firstTimeReward),false);
      }
      
      public function showFishingFailurePopUp() : void
      {
      }
      
      public function showMainUI() : void
      {
         var featureData:Object = this.getFeatureData();
         if(Boolean(featureData) && Boolean(featureData.hasOwnProperty("MasteryReward")) && featureData["MasteryReward"] == 1)
         {
            this.showFishCollectionsWindow();
         }
         else if(isTutorial1Over() == true && isTutorial2Over() == false)
         {
            this.showFishCollectionsWindow();
         }
         else
         {
            FarmStatsManager.count("FishingV2","mainui","open");
            this.m_tackleBoxWindow = new FishingTackleBoxWindow(this.tackleBoxWindowURL);
            UI.displayPopup(this.m_tackleBoxWindow,false);
         }
      }
      
      public function showMainUIAfterFeatureEnds() : void
      {
         var featureData:Object = this.getFeatureData();
         if(Boolean(featureData) && Boolean(featureData.hasOwnProperty("MasteryReward")) && featureData["MasteryReward"] == 1)
         {
            this.showFishCollectionsWindow();
         }
      }
      
      public function getCommonFishCollection() : Array
      {
         var fishInfo:Object = null;
         var fishInfoArray:Array = [];
         for(var index:int = 0; index < 5; index++)
         {
            fishInfo = {};
            fishInfo["index"] = index;
            fishInfoArray.push(fishInfo);
         }
         return fishInfoArray;
      }
      
      public function getUnCommonFishCollection() : Array
      {
         var fishInfo:Object = null;
         var fishInfoArray:Array = [];
         for(var index:int = 0; index < 4; index++)
         {
            fishInfo = {};
            fishInfo["index"] = index;
            fishInfoArray.push(fishInfo);
         }
         return fishInfoArray;
      }
      
      public function getRareFishCollection() : Array
      {
         var fishInfo:Object = null;
         var fishInfoArray:Array = [];
         for(var index:int = 0; index < 3; index++)
         {
            fishInfo = {};
            fishInfo["index"] = index;
            fishInfoArray.push(fishInfo);
         }
         return fishInfoArray;
      }
      
      private function isValidSubtype(subtype:int) : Boolean
      {
         return subtype == SUBTYPE_BRONZE || subtype == SUBTYPE_SILVER || subtype == SUBTYPE_GOLD;
      }
      
      private function itemToTimestampKey(itemType:int, itemSubtype:int) : String
      {
         if(!this.isValidSubtype(itemSubtype))
         {
            return "";
         }
         var keyPrefix:String = "";
         switch(itemType)
         {
            case TYPE_ROD:
               keyPrefix = RODS_COUNT_KEYS[itemSubtype];
               break;
            case TYPE_BAIT:
               keyPrefix = BAITS_COUNT_KEYS[itemSubtype];
         }
         return keyPrefix + "_" + m_featureName;
      }
      
      private function getThrottleTime(itemType:int, itemSubtype:int) : Number
      {
         if(!this.isValidSubtype(itemSubtype))
         {
            return -1;
         }
         var timeInMinutes:int = -1;
         switch(itemType)
         {
            case TYPE_ROD:
               timeInMinutes = int(ROD_CRAFTING_DURATIONS[itemSubtype]);
               break;
            case TYPE_BAIT:
               timeInMinutes = int(BAIT_CRAFTING_DURATIONS[itemSubtype]);
         }
         return timeInMinutes * FarmGameUtil.NUM_SECS_IN_MINUTE;
      }
      
      public function getCraftTimeforHoveText(itemType:int, itemSubtype:int) : String
      {
         var timeInMinutes:int = 0;
         switch(itemType)
         {
            case TYPE_ROD:
               timeInMinutes = int(ROD_CRAFTING_DURATIONS[itemSubtype]);
               break;
            case TYPE_BAIT:
               timeInMinutes = int(BAIT_CRAFTING_DURATIONS[itemSubtype]);
         }
         return "00:" + timeInMinutes + ":00";
      }
      
      public function hasStartedCrafting(itemType:int, itemSubtype:int) : Boolean
      {
         return Global.player.getFeatureLastShown(this.itemToTimestampKey(itemType,itemSubtype)) > 0;
      }
      
      public function getTimeLeft(itemType:int, itemSubtype:int, formatted:Boolean = false) : *
      {
         var lastSeenTime:Number = NaN;
         var timeSinceLastFeed:Number = NaN;
         lastSeenTime = Global.player.getFeatureLastShown(this.itemToTimestampKey(itemType,itemSubtype));
         timeSinceLastFeed = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - lastSeenTime;
         var timeLeft:Number = this.getThrottleTime(itemType,itemSubtype) - timeSinceLastFeed;
         return formatted ? HUD.getformattedTimeLeftFromArray(FarmGameUtil.parseTimeLeft(timeLeft)) : timeLeft;
      }
      
      public function canCollect(itemType:int, itemSubtype:int) : Boolean
      {
         return this.getTimeLeft(itemType,itemSubtype) <= 0 && this.hasStartedCrafting(itemType,itemSubtype);
      }
      
      public function collectItem(itemType:int, itemSubtype:int, countKey:String, count:Number) : void
      {
         this.registerTimestampForKey(this.itemToTimestampKey(itemType,itemSubtype),true);
         this.incrementCountForKey(countKey,count,true);
      }
      
      public function registerTimestampForKey(key:String, reset:Boolean = false) : void
      {
         var timeStamp:Number = reset ? -1 : GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         Global.player.setFeatureLastShown(key,timeStamp,false);
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,"registerTimestampForKey",null,[m_featureName,key,reset]));
      }
      
      public function incrementCountForKey(key:String, count:int = 1, persist:Boolean = false) : void
      {
         var featureData:Object = this.getFeatureData();
         if(featureData.hasOwnProperty(key))
         {
            featureData[key] += count;
            setFeatureData(featureData);
         }
         if(persist)
         {
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,"incrementCountForKey",null,[m_featureName,key,count]));
         }
      }
      
      public function decrementCountForKey(key:String, count:int = 1) : void
      {
         var featureData:Object = this.getFeatureData();
         if(featureData.hasOwnProperty(key))
         {
            featureData[key] -= count;
            setFeatureData(featureData);
         }
      }
      
      public function getCountForKey(key:String) : int
      {
         if(!this.getFeatureData().hasOwnProperty(key))
         {
            return 0;
         }
         return this.getFeatureData()[key] as int;
      }
      
      public function sendBuyEquipmentTransaction(key:String, cost:int) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,"buyEquipment",null,[m_featureName,key,cost]));
      }
      
      private function onSpendFarmCashConfirmation(callback:Function, parentWindow:FarmWindow) : Function
      {
         return function(event:GenericPopupEvent = null):void
         {
            if(event.button == GenericPopup.ACCEPT)
            {
               callback();
            }
            parentWindow.refreshWindow();
            parentWindow.untintWindow();
            parentWindow.enableInput = true;
         };
      }
      
      public function confirmAndSpendFarmCash(callback:Function, cost:Number, parentWindow:FarmWindow) : void
      {
         parentWindow.tintWindow();
         parentWindow.enableInput = false;
         UI.displayMessage(ZLocUtils.t("Dialogs","FarmCashBuyConfirmation",{"price":cost.toString()}),GenericPopup.TYPE_ACCEPTCANCEL,this.onSpendFarmCashConfirmation(callback,parentWindow),"farmAnimatedTextConfirmation",true,true);
      }
      
      public function skipRodCrafting(rodType:int) : void
      {
         var cost:int = 0;
         if(!this.isValidSubtype(rodType))
         {
            return;
         }
         cost = int(PRICES_RODS[rodType]);
         this.confirmAndSpendFarmCash(function():void
         {
            if(Global.player.canBuyCash(cost))
            {
               Global.player.cash -= cost;
               incrementCountForKey(RODS_COUNT_KEYS[rodType]);
               registerTimestampForKey(itemToTimestampKey(TYPE_ROD,rodType),true);
               sendBuyEquipmentTransaction(RODS_COUNT_KEYS[rodType],cost);
            }
         },cost,this.m_craftWindow);
      }
      
      public function skipBaitCrafting(baitType:int) : void
      {
         var cost:int = 0;
         if(!this.isValidSubtype(baitType))
         {
            return;
         }
         cost = int(PRICES_BAITS[baitType]);
         this.confirmAndSpendFarmCash(function():void
         {
            if(Global.player.canBuyCash(cost))
            {
               Global.player.cash -= cost;
               incrementCountForKey(BAITS_COUNT_KEYS[baitType]);
               registerTimestampForKey(itemToTimestampKey(TYPE_BAIT,baitType),true);
               sendBuyEquipmentTransaction(BAITS_COUNT_KEYS[baitType],cost);
            }
         },cost,this.m_craftWindow);
      }
      
      public function buyBoost(boostType:int) : void
      {
         if(boostType < 0 || boostType > 1)
         {
            return;
         }
         this.confirmAndSpendFarmCash(function():void
         {
            if(Global.player.canBuyCash(10))
            {
               Global.player.cash -= 10;
               incrementCountForKey(BOOSTS_COUNT_KEYS[boostType]);
               sendBuyEquipmentTransaction(BOOSTS_COUNT_KEYS[boostType],10);
            }
         },10,this.m_craftWindow);
      }
      
      public function isCraftingAllowedForItem(itemType:int, itemSubtype:int) : Boolean
      {
         for(var subtype:int = SUBTYPE_BRONZE; subtype <= SUBTYPE_GOLD; subtype++)
         {
            if(subtype != itemSubtype && this.hasStartedCrafting(itemType,subtype))
            {
               return false;
            }
         }
         return true;
      }
      
      public function startEquipmentCrafting(itemType:int, itemSubtype:int) : void
      {
         var key:String = this.itemToTimestampKey(itemType,itemSubtype);
         this.registerTimestampForKey(key);
         FarmStatsManager.count(FEATURE_NAME,"equipmentshop",itemType == 0 ? "Rod" : "Bait","" + itemSubtype);
      }
      
      public function openCraftingWindow() : void
      {
         this.m_craftWindow = new FishingV2CraftingWindow(m_featureName,this.craftingWindowURL);
         UI.displayPopup(this.m_craftWindow,false);
      }
      
      public function openFishingFinalTrophy(type:String = "Mastery") : void
      {
         this.m_finalPopUp = new FishingV2FinalPopUp(m_featureName,this.fishingMasteryTrophyWindow,type);
         UI.displayPopup(this.m_finalPopUp,false);
      }
      
      public function getfishCount(collectionType:int, slotIndex:int) : int
      {
         var count:int = 0;
         var fo:Object = this.getFeatureData();
         if(fo)
         {
            if(fo.hasOwnProperty("fishCollection"))
            {
               count = int(fo["fishCollection"][collectionType][slotIndex]);
            }
         }
         return count;
      }
      
      public function hasMasteredFish(collectionType:int, slotIndex:int) : Boolean
      {
         return this.getMasteryStarsCount(collectionType,slotIndex) >= 3;
      }
      
      public function getFishCollectionPrice(collectionType:int) : Number
      {
         if(collectionType < 0 || collectionType > 2)
         {
            return 0;
         }
         var featureData:Object = this.getFeatureData();
         var pricePerFish:Number = Number([4,8,12][collectionType]);
         var count:int = 0;
         for(var i:int = 0; i < featureData["fishCollection"][collectionType].length; i++)
         {
            count += int(!this.hasMasteredFish(collectionType,i));
         }
         return count * pricePerFish;
      }
      
      public function buyFishCollection(collectionType:int) : void
      {
         var featureData:Object = null;
         var cost:Number = NaN;
         featureData = this.getFeatureData();
         cost = this.getFishCollectionPrice(collectionType);
         var onCashDeduction:Function = function():void
         {
            var rewardItem:FarmItem = null;
            for(var i:int = 0; i < featureData["fishCollection"][collectionType].length; i++)
            {
               featureData["fishCollection"][collectionType][i] += int(!hasMasteredFish(collectionType,i));
            }
            for(var fishIndex:int = 0; fishIndex < FISH_LENGTH[collectionType]; fishIndex++)
            {
               if(hasMasteredFish(collectionType,fishIndex) && featureData["UniqueRewards"][collectionType][fishIndex] != 1)
               {
                  Global.player.addGift(FISH_CMS_NAME_ARRAY[collectionType][fishIndex]);
                  featureData["UniqueRewards"][collectionType][fishIndex] = 1;
                  FarmStatsManager.count(FEATURE_NAME,"Reward","" + collectionType + " : " + FISH_CMS_NAME_ARRAY[collectionType][fishIndex],"mastery");
                  FarmStatsManager.count(m_featureName,"get_fish","" + FISH_CMS_NAME_ARRAY[collectionType][fishIndex],"purchase");
                  rewardItem = Global.farmGameSettingsManager.getFarmItemByName(FISH_CMS_NAME_ARRAY[collectionType][fishIndex]);
                  m_rewradItemArray[fishIndex] = rewardItem;
                  var _temp_9:* = UI;
                  var _temp_8:* = m_rewardWindow;
                  var _temp_7:* = fishIndex;
                  var _temp_5:* = §§findproperty(FishingRewardGrantWindow);
                  var _temp_4:* = REWARD_SHARE_WINDOW;
                  var _temp_3:* = FEATURE_NAME;
                  var _temp_2:* = rewardItem;
                  MouseEvent.CLICK;
                  _temp_9.displayPopup(_temp_8[_temp_7] = new FishingRewardGrantWindow(_temp_4,_temp_3,_temp_2,shareCallback(fishIndex),"assets/dialogs/cocoland/RewardDialog.png"),false);
               }
            }
            setFeatureData(featureData);
            checkAndGrantCollectionReward();
            checkAndGrantMasteryReward();
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"buyFishCollection",null,[m_featureName,collectionType]));
         };
         this.confirmAndSpendFarmCash(function():void
         {
            if(Global.player.canBuyCash(cost))
            {
               Global.player.cash -= cost;
               onCashDeduction();
            }
         },cost,this.m_window);
      }
      
      public function getMasteryStarsCount(collectionType:int, slotIndex:int) : int
      {
         return int(this.getfishCount(collectionType,slotIndex) / 3);
      }
      
      public function showCatchingPopUp() : void
      {
         var message:String = "Catching Fish ...";
         this.m_getFishWaitWindow = UI.displayMessage(message,GenericPopup.TYPE_MODAL,null,"",true);
      }
      
      public function getFish(rodType:int, baitType:int, boosterType:int, isSuccess:Boolean) : void
      {
         if(isSuccess)
         {
            this.showCatchingPopUp();
         }
         var fo:Object = this.getFeatureData();
         fo[RODS_USAGE_COUNT_KEYS[rodType]] = fo[RODS_USAGE_COUNT_KEYS[rodType]] - 1;
         fo[BAITS_COUNT_KEYS[baitType]] = fo[BAITS_COUNT_KEYS[baitType]] - 1;
         m_selectedBait = -1;
         if(fo[RODS_USAGE_COUNT_KEYS[rodType]] == 0)
         {
            m_selectedRod = -1;
            fo[RODS_COUNT_KEYS[rodType]] = fo[RODS_COUNT_KEYS[rodType]] - 1;
         }
         else if(fo[RODS_USAGE_COUNT_KEYS[rodType]] == -1)
         {
            fo[RODS_USAGE_COUNT_KEYS[rodType]] = 3;
         }
         if(boosterType == 0 || boosterType == 1)
         {
            m_selectedBoost = -1;
            fo[BOOSTS_COUNT_KEYS[boosterType]] = fo[BOOSTS_COUNT_KEYS[boosterType]] - 1;
         }
         setFeatureData(fo);
         var funcCallback:Function = null;
         if(isSuccess)
         {
            funcCallback = this.onGetfish;
         }
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,"getFish",funcCallback,[m_featureName,rodType,baitType,boosterType,isSuccess]));
         if(isTutorial1Over() == false)
         {
            Global.player.setSeenFlag("FISHING_V2_TUTORIAL1");
         }
         else if(isTutorial1Over() == true && isTutorial2Over() == false)
         {
            Global.player.setSeenFlag("FISHING_V2_TUTORIAL2");
         }
      }
      
      public function onGetfish(result:Object) : void
      {
         var fo:Object = null;
         var i:int = 0;
         var grantedFishInfo:Object = null;
         var firstTimeReward:String = null;
         var fishType:int = 0;
         var fishIndex:int = 0;
         var rewardName:String = null;
         var rewardItem:FarmItem = null;
         if(this.m_getFishWaitWindow)
         {
            this.m_getFishWaitWindow.close();
            this.m_getFishWaitWindow = null;
         }
         if(result.hasOwnProperty("fishArray"))
         {
            result = result["fishArray"];
            for(i = 0; i < result.length; i++)
            {
               grantedFishInfo = result[i];
               if(grantedFishInfo.hasOwnProperty("fishType"))
               {
                  fishType = int(grantedFishInfo["fishType"]);
                  fishIndex = int(grantedFishInfo["fishIndex"]);
                  fo = this.getFeatureData();
                  if(fo["fishCollection"][fishType][fishIndex] == 0)
                  {
                     if(grantedFishInfo.hasOwnProperty("firstTimeReward"))
                     {
                        rewardName = grantedFishInfo["firstTimeReward"];
                        Global.player.addGift(grantedFishInfo["firstTimeReward"]);
                        Global.player.addGift("consume_turbo_charger");
                     }
                  }
                  fo["fishCollection"][fishType][fishIndex] += 1;
                  if(this.hasMasteredFish(fishType,fishIndex) && fo["UniqueRewards"][fishType][fishIndex] != 1)
                  {
                     Global.player.addGift(FISH_CMS_NAME_ARRAY[fishType][fishIndex]);
                     fo["UniqueRewards"][fishType][fishIndex] = 1;
                     FarmStatsManager.count(FEATURE_NAME,"Reward","" + fishType + " : " + FISH_CMS_NAME_ARRAY[fishType][fishIndex],"mastery");
                  }
                  setFeatureData(fo);
               }
               else if(grantedFishInfo.hasOwnProperty("boot"))
               {
                  fo = this.getFeatureData();
                  fo["boot"] += 1;
                  setFeatureData(fo);
               }
               firstTimeReward = "";
               if(grantedFishInfo.hasOwnProperty("firstTimeReward"))
               {
                  firstTimeReward = grantedFishInfo["firstTimeReward"];
                  FarmStatsManager.count("FishingV2","reward",fishType + " : " + FISH_CMS_NAME_ARRAY[fishType][fishIndex],"first_time");
               }
               fo = this.getFeatureData();
               this.showFishingSuccessPopUp(fishType,fishIndex,grantedFishInfo.hasOwnProperty("boot"),firstTimeReward);
               if(grantedFishInfo.hasOwnProperty("fishType") && fo["UniqueRewards"][fishType][fishIndex] == 1)
               {
                  rewardItem = Global.farmGameSettingsManager.getFarmItemByName(FISH_CMS_NAME_ARRAY[fishType][fishIndex]);
                  this.m_rewradItem = rewardItem;
                  UI.displayPopup(this.m_singlerewardWindow = new FishingRewardGrantWindow(this.REWARD_SHARE_WINDOW,FEATURE_NAME,rewardItem,this.shareCallbackMastrey,"assets/dialogs/cocoland/RewardDialog.png","FISH"),false);
                  FarmStatsManager.count(m_featureName,"get_fish","" + FISH_CMS_NAME_ARRAY[fishType][fishIndex],"fishing");
               }
            }
         }
         this.checkAndGrantCollectionReward();
         this.checkAndGrantMasteryReward();
      }
      
      public function checkAndGrantCollectionReward() : void
      {
         var fo:Object = this.getFeatureData();
         if(!(fo.hasOwnProperty("CollectionReward") && fo["CollectionReward"] == 1))
         {
            if(this.isEligibleForCollectionReward() == true)
            {
               Global.player.addGift("cottoncandybettatrophy");
               fo["CollectionReward"] = 1;
               fo["cts"] = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
               setFeatureData(fo);
               this.showCollectionTrophyWindow();
               FarmStatsManager.count(FEATURE_NAME,"Reward","collection_trophy");
            }
         }
      }
      
      public function isEligibleForCollectionReward() : Boolean
      {
         var fishIndex:int = 0;
         var result:Boolean = true;
         var fo:Object = this.getFeatureData();
         for(var index:int = 0; index < 3; index++)
         {
            for(fishIndex = 0; fishIndex < FISH_LENGTH[index]; fishIndex++)
            {
               if(fo["fishCollection"][index][fishIndex] == 0)
               {
                  result = false;
               }
            }
         }
         return result;
      }
      
      public function checkAndGrantMasteryReward() : void
      {
         var fo:Object = this.getFeatureData();
         if(!(fo.hasOwnProperty("MasteryReward") && fo["MasteryReward"] == 1))
         {
            if(this.isEligibleForMasteryReward() == true)
            {
               Global.player.addGift("cocostonebasstrophy");
               fo["MasteryReward"] = 1;
               fo["mts"] = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
               setFeatureData(fo);
               this.showMasteryTrophyWindow();
               FarmStatsManager.count(FEATURE_NAME,"Reward","mastery_trophy");
            }
         }
      }
      
      public function isEligibleForMasteryReward() : Boolean
      {
         var fishIndex:int = 0;
         var result:Boolean = true;
         for(var index:int = 0; index < 3; index++)
         {
            for(fishIndex = 0; fishIndex < FISH_LENGTH[index]; fishIndex++)
            {
               if(this.hasMasteredFish(index,fishIndex) == false)
               {
                  result = false;
               }
            }
         }
         return result;
      }
      
      public function showCollectionTrophyWindow() : void
      {
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName("cottoncandybettatrophy");
         this.m_rewardTrophy = rewardItem;
         FishingV2Manager.getInstance().openFishingFinalTrophy("Collection");
      }
      
      public function showMasteryTrophyWindow() : void
      {
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName("cocostonebasstrophy");
         this.m_rewardTrophy = rewardItem;
         FishingV2Manager.getInstance().openFishingFinalTrophy("Mastery");
      }
      
      public function getRemainingBaitUses() : int
      {
         var fo:Object = null;
         var num:int = -1;
         if(m_selectedBait != -1)
         {
            fo = this.getFeatureData();
            num = int(fo[BAITS_USAGE_COUNT_KEYS[m_selectedBait]]);
         }
         return num;
      }
      
      public function getRemainingRodUses() : int
      {
         var fo:Object = null;
         var num:int = -1;
         if(m_selectedRod != -1)
         {
            fo = this.getFeatureData();
            num = int(fo[RODS_USAGE_COUNT_KEYS[m_selectedRod]]);
         }
         return num;
      }
      
      public function getBootCount() : int
      {
         var fo:Object = this.getFeatureData();
         return int(fo["boot"]);
      }
      
      public function canRedeemBoots() : Boolean
      {
         return this.getBootCount() >= 4;
      }
      
      public function isP12TileUnlocked() : Boolean
      {
         return PrerequisiteUtility.checkPrereqByName("xcl_rubbletreasure_payer12_unlocked");
      }
      
      public function isCollectionTrophyGranted() : Boolean
      {
         var fo:Object = this.getFeatureData();
         var isCollectionTrophy:int = 0;
         if(fo.hasOwnProperty("CollectionReward") && fo["CollectionReward"] == 1)
         {
            isCollectionTrophy = 1;
         }
         return isCollectionTrophy;
      }
      
      public function isMasteryTrophyGranted() : Boolean
      {
         var fo:Object = this.getFeatureData();
         var isMasteryTrophy:int = 0;
         if(fo.hasOwnProperty("MasteryReward") && fo["MasteryReward"] == 1)
         {
            isMasteryTrophy = 1;
         }
         return isMasteryTrophy;
      }
      
      public function redeemBoots() : void
      {
         var fo:Object = this.getFeatureData();
         fo["boot"] -= 4;
         fo[RODS_COUNT_KEYS[0]] += 1;
         setFeatureData(fo);
         FarmStatsManager.count(FEATURE_NAME,"redeem","Boot","" + fo["boot"]);
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,"redeemBoots",null,[m_featureName]));
      }
      
      public function openMiniGameForTutorial1() : void
      {
         this.openMiniGame();
      }
      
      public function IsBonusBuildingReadyToHarvest(trophyName:String) : Boolean
      {
         var result:Boolean = false;
         if(this.getTimeLeftForBonusHarvest(trophyName) <= 0)
         {
            result = true;
         }
         return result;
      }
      
      public function canHarvestMasteryTrophy() : Boolean
      {
         var isStillHarvestable:Boolean = false;
         var fo:Object = this.getFeatureData();
         if(fo.hasOwnProperty("mts"))
         {
            if(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - fo["mts"] < 14 * 86400)
            {
               isStillHarvestable = true;
            }
         }
         return isStillHarvestable;
      }
      
      public function canHarvestCollectionTrophy() : Boolean
      {
         var isStillHarvestable:Boolean = false;
         var fo:Object = this.getFeatureData();
         if(fo.hasOwnProperty("cts"))
         {
            if(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - fo["cts"] < 14 * 86400)
            {
               isStillHarvestable = true;
            }
         }
         return isStillHarvestable;
      }
      
      public function getTimeLeftForFinalHarvestOfCollectionTrophy() : Number
      {
         var timeLeftInFinalHarvest:Number = -1;
         var fo:Object = this.getFeatureData();
         if(fo.hasOwnProperty("cts"))
         {
            timeLeftInFinalHarvest = 2 * FarmGameUtil.NUM_SECS_IN_WEEK - (GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - fo["cts"]);
         }
         if(timeLeftInFinalHarvest > 10)
         {
            timeLeftInFinalHarvest -= 10;
         }
         return timeLeftInFinalHarvest;
      }
      
      public function getTimeLeftForFinalHarvestOfMasteryTrophy() : Number
      {
         var timeLeftInFinalHarvest:Number = -1;
         var fo:Object = this.getFeatureData();
         if(fo.hasOwnProperty("mts"))
         {
            timeLeftInFinalHarvest = 2 * FarmGameUtil.NUM_SECS_IN_WEEK - (GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - fo["mts"]);
         }
         if(timeLeftInFinalHarvest > 10)
         {
            timeLeftInFinalHarvest -= 10;
         }
         return timeLeftInFinalHarvest;
      }
      
      public function getTimeLeftForBonusHarvest(trophyName:String) : int
      {
         var timeLeft:int = 0;
         var key:String = LAST_BONUS_HARVEST_TIME_KEY + trophyName;
         var throttleTime:int = DEFAULT_HARVEST_THROTTLE_TIME;
         return this.getTimeLeftForHarvest(key,throttleTime);
      }
      
      public function getTimeLeftForHarvest(key:String, throttleTime:int = 86400) : int
      {
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         return int(throttleTime - timeSinceLastFeed);
      }
      
      public function harvestBonusBuilding(trophyName:String) : void
      {
         var fo:Object = null;
         var harvestFarmItem:FarmItem = null;
         var harvestRewardName:String = null;
         var count:int = 0;
         if(!this.m_initialized)
         {
            this.initialize();
         }
         var key:String = LAST_BONUS_HARVEST_TIME_KEY + trophyName;
         Global.player.setFeatureLastShown(key,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         if(trophyName == "collection")
         {
            fo = this.getFeatureData();
            fo[RODS_COUNT_KEYS[1]] += 1;
            fo[BAITS_COUNT_KEYS[2]] += 1;
            setFeatureData(fo);
            harvestFarmItem = Global.farmGameSettingsManager.getFarmItemByName("pkg_collection_harvest");
            FarmStatsManager.count(m_featureName,"feature_ui","harvestpopup","pkg_collection_harvest");
            UI.displayPopup(new FishingFeatureV2PostHarvestWindow("assets/dialogs/expansion/FV_RewardDialog.swf",featureName,harvestFarmItem,null,"assets/dialogs/cocoland/RewardDialog.png",1));
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,"harvestCollectionTrophy",null,[m_featureName,trophyName]),true);
         }
         else if(trophyName == "mastery")
         {
            harvestRewardName = this.getNextHarvestItemName();
            harvestFarmItem = Global.farmGameSettingsManager.getFarmItemByName(harvestRewardName);
            if(harvestFarmItem)
            {
               count = 1;
               Global.player.addGift(harvestRewardName,"",count);
               FarmStatsManager.count(m_featureName,"feature_ui","harvestpopup",harvestRewardName);
               UI.displayPopup(new FishingFeatureV2PostHarvestWindow("assets/dialogs/expansion/FV_RewardDialog.swf",featureName,harvestFarmItem,null,"assets/dialogs/cocoland/RewardDialog.png",count));
               TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,"harvestMasteryTrophy",null,[m_featureName,trophyName]),true);
            }
         }
      }
      
      private function getNextHarvestItemName() : String
      {
         var couponName:String = null;
         var bonusCount:int = 0;
         var featureData:Object = this.getFeatureData();
         if(featureData.hasOwnProperty(this.BONUS_HARVEST_COUNT))
         {
            bonusCount = featureData[this.BONUS_HARVEST_COUNT] as int;
         }
         else
         {
            featureData[this.BONUS_HARVEST_COUNT] = 0;
            bonusCount = 0;
         }
         var consumableRotationCount:int = 10;
         couponName = this.MASTERY_HARVEST_ARRAY[bonusCount % consumableRotationCount];
         featureData[this.BONUS_HARVEST_COUNT] = bonusCount + 1;
         setFeatureData(featureData);
         return couponName;
      }
      
      private function shareCallbackMastrey(e:Event) : void
      {
         var fi:FarmItem = this.m_rewradItem;
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}",
               "src":fi.icon
            }],
            "user":Global.player.firstName,
            "item":fi.friendlyTitle
         };
         if(this.m_singlerewardWindow)
         {
            this.m_singlerewardWindow.close();
         }
         GlobalEngine.socialNetwork.publishFeedStory("FishingV2_BragFeed",bundleData,[],false,null);
         FarmStatsManager.count(FEATURE_NAME,"reward_bragfeed",fi.friendlyTitle);
      }
      
      public function shareCallback(slotIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            var fi:* = m_rewradItemArray[slotIndex];
            var bundleData:* = {
               "images":[{
                  "href":"{SN_APP_URL}",
                  "src":fi.icon
               }],
               "user":Global.player.firstName,
               "item":fi.friendlyTitle
            };
            if(m_rewardWindow[slotIndex])
            {
               m_rewardWindow[slotIndex].close();
            }
            GlobalEngine.socialNetwork.publishFeedStory("FishingV2_BragFeed",bundleData,[],false,null);
            FarmStatsManager.count(FishingV2Manager.FEATURE_NAME,"reward_bragfeed",fi.friendlyTitle);
         };
      }
      
      public function canApplySonarBooseter() : Boolean
      {
         var canApplySonarBooster:Boolean = false;
         for(var i:int = 0; i < 3; i++)
         {
            if(this.hasMasteredFish(2,i) == false)
            {
               canApplySonarBooster = true;
            }
         }
         return canApplySonarBooster;
      }
   }
}

