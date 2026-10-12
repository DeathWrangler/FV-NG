package Managers
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TGenericTransaction;
   import Widgets.Frames.XMASInnovationGiftFrame;
   import Widgets.Windows.XMASInnovationGiftWindow;
   import Widgets.Windows.XMASInnovationWindow;
   import Widgets.Windows.XMASRedeemRewardWindow;
   import Widgets.Windows.XMASUnlockDecoCongratsWindow;
   import flash.events.Event;
   
   public class XMASInnovationManager extends BaseFeatureManager
   {
      
      private static const SERVICE_CLASS:String = "XMASInnovationService";
      
      private static const SERVICE_FUNC_HARVEST:String = "harvestBuilding";
      
      private static const SERVICE_FUNC_MAKE_READY_TO_HARVEST:String = "makeReadyToHarvest";
      
      private static const SERVICE_FUNC_REDEEMGIFT:String = "redeemGift";
      
      private static const FEATURE_NAME:String = "XMASInnovation";
      
      private static const WINDOW_MAIN_UI:String = "mainUI";
      
      private static const WINDOW_CHRISTMAS_UI:String = "christmasUI";
      
      private static const WINDOW_REEDEEM_CONGRATS:String = "redeemCongrats";
      
      private static const DECO_UNLOCK_WINDOW:String = "decoUnlockWindow";
      
      private static const LAST_HARVEST_TIME_KEY:String = "_lastHarvestTimeKey";
      
      public static const FEATURE_OPTIONS_KEY:String = "XMASInnovation";
      
      public static const BUILDING_SLOT_MAP:Object = {
         "goldenwinterbelfry":"0",
         "funfrolicrink":"1",
         "wintermanor":"2"
      };
      
      private static const EVENT_DECO2_UNLOCK:String = "XmasInnovationDeco2UnlockEvent";
      
      private static const EVENT_DECO3_UNLOCK:String = "XmasInnovationDeco3UnlockEvent";
      
      private static const SKIP_COST:int = 3;
      
      public static const HUD_INITIALISATION_FLAG:String = "xmas_innovation_hud_initialise_flag";
      
      private var m_assetPaths:Object = null;
      
      private var m_staticData:Object;
      
      private var m_XmasMainWindow:XMASInnovationWindow;
      
      private var m_xmasGiftWindow:XMASInnovationGiftWindow;
      
      public function XMASInnovationManager(featureName:String, featureConfig:XML = null)
      {
         super(featureName,featureConfig);
         this.initialize();
      }
      
      public static function getInstance(featureName:String = "XMASInnovation") : XMASInnovationManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,XMASInnovationManager) as XMASInnovationManager;
      }
      
      public function get skipCost() : int
      {
         return SKIP_COST;
      }
      
      public function initialize() : void
      {
         var reward:String = null;
         this.loadStaticData();
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,m_featureName);
         if(!featureData)
         {
            featureData = new Object();
            for each(reward in this.RewardsList)
            {
               featureData[reward] = 0;
            }
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,m_featureName,featureData);
         }
      }
      
      public function isFeatureEnabled() : Boolean
      {
         var featureEnabled:Boolean = false;
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         if(featureXML != null)
         {
            featureEnabled = true;
         }
         return featureEnabled;
      }
      
      private function loadStaticData() : void
      {
         var listArray:Array = null;
         var asset:XML = null;
         var itemsXML:XMLList = null;
         var itemXML:XML = null;
         var itemsXML2:XMLList = null;
         this.m_staticData = new Object();
         this.m_staticData.buffs = new Array();
         this.m_staticData.buildings = new Array();
         this.m_staticData.tilesArray = new Array();
         this.m_staticData.waitTimeArray = new Array();
         this.m_staticData.consumableArray = new Array();
         this.m_staticData.consumableGrantArray = new Array();
         this.m_staticData.rewardArray = new Array();
         this.m_staticData.c1countArray = new Array();
         this.m_staticData.c2countArray = new Array();
         this.m_staticData.c3countArray = new Array();
         this.m_staticData.xmasGiftRedeemStartDate = new String();
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         if(featureXML != null)
         {
            this.m_assetPaths = new Object();
            if(featureXML.assets != "")
            {
               for each(asset in featureXML.assets.asset)
               {
                  this.m_assetPaths[asset.@name] = asset.@path.toString();
               }
            }
            this.m_staticData.xmasGiftRedeemStartDate = featureXML.listEndDate.toString();
            listArray = Utilities.xmlListToArray(featureXML.divisions.division);
            if(listArray[0].@name == "buildings")
            {
               itemsXML = listArray[0].items.item;
               for each(itemXML in itemsXML)
               {
                  this.m_staticData.buildings.push(itemXML.@name.toString());
                  this.m_staticData.tilesArray.push(itemXML.@region.toString());
                  this.m_staticData.waitTimeArray.push(parseInt(itemXML.@cost));
                  this.m_staticData.consumableArray.push(itemXML.@itemCode.toString());
                  this.m_staticData.consumableGrantArray.push(itemXML.@max.toString());
               }
            }
            if(listArray[1].@name == "rewards")
            {
               itemsXML2 = listArray[1].items.item;
               for each(itemXML in itemsXML2)
               {
                  this.m_staticData.rewardArray.push(itemXML.@name.toString());
                  this.m_staticData.c1countArray.push(parseInt(itemXML.@c1));
                  this.m_staticData.c2countArray.push(parseInt(itemXML.@c2));
                  this.m_staticData.c3countArray.push(parseInt(itemXML.@c3));
               }
            }
         }
      }
      
      public function get c1countList() : Array
      {
         return this.m_staticData.c1countArray;
      }
      
      public function get c2countList() : Array
      {
         return this.m_staticData.c2countArray;
      }
      
      public function get ConsumableGrantArray() : Array
      {
         return this.m_staticData.consumableGrantArray;
      }
      
      public function get c3countList() : Array
      {
         return this.m_staticData.c3countArray;
      }
      
      public function get RewardsList() : Array
      {
         return this.m_staticData.rewardArray;
      }
      
      public function get ConsumableList() : Array
      {
         return this.m_staticData.consumableArray;
      }
      
      public function get mainWindow() : String
      {
         return this.m_assetPaths[WINDOW_MAIN_UI];
      }
      
      public function get christmasUIWindow() : String
      {
         return this.m_assetPaths[WINDOW_CHRISTMAS_UI];
      }
      
      public function get redeemCongratsWindow() : String
      {
         return this.m_assetPaths[WINDOW_REEDEEM_CONGRATS];
      }
      
      public function get decoUnlockWindow() : String
      {
         return this.m_assetPaths[DECO_UNLOCK_WINDOW];
      }
      
      public function get XmasGiftRedeemStartDate() : String
      {
         return this.m_staticData.xmasGiftRedeemStartDate;
      }
      
      public function get buildingNameArray() : Array
      {
         return this.m_staticData.buildings;
      }
      
      public function get associatedTilesNameArray() : Array
      {
         return this.m_staticData.tilesArray;
      }
      
      public function get waitingPeriodArray() : Array
      {
         return this.m_staticData.waitTimeArray;
      }
      
      public function showMainUI() : void
      {
         this.initialize();
         this.m_XmasMainWindow = new XMASInnovationWindow(null,m_featureName,this.mainWindow);
         UI.displayPopup(this.m_XmasMainWindow);
         FarmStatsManager.count(m_featureName,"feature_ui","main_ui","impression");
      }
      
      public function panToTile(tileName:String) : void
      {
         var specialTileGameObjects:Array = Global.world.getObjectsByName(tileName);
         if(Boolean(specialTileGameObjects) && specialTileGameObjects.length > 0)
         {
            if(ItemFinderManager.getInstance().highlightWorldItems(tileName).length > 0)
            {
               if(this.m_XmasMainWindow)
               {
                  this.m_XmasMainWindow.close();
               }
               ItemFinderManager.getInstance().highlightWorldItems(tileName);
            }
         }
      }
      
      public function isRewardRedeemable(slotIndex:int) : Boolean
      {
         var result:Boolean = false;
         var featureOptInvObject:FeatureOptionsInventoryManager = FeatureOptionsInventoryManager.getInstance();
         if(featureOptInvObject.getCount(this.ConsumableList[0]) >= this.c1countList[slotIndex] && featureOptInvObject.getCount(this.ConsumableList[1]) >= this.c2countList[slotIndex] && featureOptInvObject.getCount(this.ConsumableList[2]) >= this.c3countList[slotIndex])
         {
            result = true;
         }
         return result;
      }
      
      public function showRedeemUI() : void
      {
         this.initialize();
         UI.displayPopup(this.m_xmasGiftWindow = new XMASInnovationGiftWindow(m_featureName,this.XmasGiftRedeemStartDate,this.christmasUIWindow,this.m_XmasMainWindow),false);
         FarmStatsManager.count(m_featureName,"feature_ui","redeem_ui","impression");
      }
      
      public function getTimeLeft(key:String, throttleTime:int) : int
      {
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         return int(throttleTime - timeSinceLastFeed);
      }
      
      public function getTimeLeftForSlot(slotIndex:int) : int
      {
         var buildingName:String = null;
         var throttleTime:int = 0;
         var key:String = null;
         var timeLeft:int = 0;
         if(slotIndex >= 0)
         {
            buildingName = this.buildingNameArray[slotIndex];
            throttleTime = int(this.waitingPeriodArray[slotIndex]);
            key = buildingName + LAST_HARVEST_TIME_KEY;
            timeLeft = this.getTimeLeft(key,throttleTime);
         }
         return timeLeft;
      }
      
      public function isTileUnlocked(itemName:String) : Boolean
      {
         if(Global.world.getObjectsByName(itemName).length > 0)
         {
            return false;
         }
         return true;
      }
      
      public function HarvestBuilding(slotIndex:int) : void
      {
         var buildingName:String = this.buildingNameArray[slotIndex];
         var key:String = buildingName + LAST_HARVEST_TIME_KEY;
         Global.player.setFeatureLastShown(key,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         FeatureOptionsInventoryManager.getInstance().addCount(this.ConsumableList[slotIndex],this.ConsumableGrantArray[slotIndex]);
         if(this.m_XmasMainWindow)
         {
            this.m_XmasMainWindow.playHarvestanimation(slotIndex);
            this.m_XmasMainWindow.refreshWindow();
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,SERVICE_FUNC_HARVEST,null,[m_featureName,slotIndex]),true);
      }
      
      public function MakeBuildingReadyToHarvest(slotIndex:int) : void
      {
         var buildingName:String = this.buildingNameArray[slotIndex];
         var key:String = buildingName + LAST_HARVEST_TIME_KEY;
         if(Global.player.canBuyCash(SKIP_COST))
         {
            Global.player.cash -= SKIP_COST;
            Global.player.setFeatureLastShown(key,(GlobalEngine.serverTime - FarmGameUtil.NUM_MSECS_IN_DAY) / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,SERVICE_FUNC_MAKE_READY_TO_HARVEST,null,[m_featureName,slotIndex]),true);
         }
      }
      
      public function IsBuildingReadyToHarvest(slotIndex:int) : Boolean
      {
         var result:Boolean = false;
         if(this.getTimeLeftForSlot(slotIndex) <= 0)
         {
            result = true;
         }
         return result;
      }
      
      public function buyItem(itemName:String, slotIndex:int, giftWindowPageFrame:XMASInnovationGiftFrame) : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         var featureOptInvObject:FeatureOptionsInventoryManager = FeatureOptionsInventoryManager.getInstance();
         featureOptInvObject.removeCount(this.ConsumableList[0],this.c1countList[slotIndex]);
         featureOptInvObject.removeCount(this.ConsumableList[1],this.c2countList[slotIndex]);
         featureOptInvObject.removeCount(this.ConsumableList[2],this.c3countList[slotIndex]);
         Global.player.addGift(item.name);
         if(this.redeemCongratsWindow != null)
         {
            UI.displayPopup(new XMASRedeemRewardWindow(this.redeemCongratsWindow,m_featureName,item,null),false);
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,SERVICE_FUNC_REDEEMGIFT,null,[m_featureName,slotIndex]));
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,m_featureName);
         if(featureData.hasOwnProperty(itemName))
         {
            featureData[itemName] += 1;
         }
         else
         {
            featureData[itemName] = 1;
         }
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,m_featureName,featureData);
         this.refreshAllWindows(giftWindowPageFrame);
      }
      
      public function refreshAllWindows(giftWindowPageFrame:XMASInnovationGiftFrame) : void
      {
         if(this.m_XmasMainWindow)
         {
            this.m_XmasMainWindow.refreshWindow();
         }
         if(this.m_xmasGiftWindow)
         {
            this.m_xmasGiftWindow.refreshWindow();
         }
         giftWindowPageFrame.refresh();
      }
      
      public function isRewardRedeemed(rewardItemName:String) : Boolean
      {
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,m_featureName);
         if(featureData.hasOwnProperty(rewardItemName) && featureData[rewardItemName] > 0)
         {
            return true;
         }
         return false;
      }
      
      public function initEventListener() : void
      {
         GlobalEventManager.getInstance().addEventListener(EVENT_DECO2_UNLOCK,this.showDeco2CongratsPopup);
         GlobalEventManager.getInstance().addEventListener(EVENT_DECO3_UNLOCK,this.showDeco3CongratsPopup);
      }
      
      public function deleteEventListener() : void
      {
         GlobalEventManager.getInstance().removeEventListener(EVENT_DECO2_UNLOCK,this.showDeco2CongratsPopup);
         GlobalEventManager.getInstance().removeEventListener(EVENT_DECO3_UNLOCK,this.showDeco3CongratsPopup);
      }
      
      public function showDeco2CongratsPopup(e:Event) : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.buildingNameArray[1]);
         UI.displayPopup(new XMASUnlockDecoCongratsWindow(this.decoUnlockWindow,m_featureName,item,this.showMainUI),false);
         FarmStatsManager.count(m_featureName,"feature_ui","deco1UnlockWindow","impression");
      }
      
      public function showDeco3CongratsPopup(e:Event) : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.buildingNameArray[2]);
         UI.displayPopup(new XMASUnlockDecoCongratsWindow(this.decoUnlockWindow,m_featureName,item,this.showMainUI),false);
         FarmStatsManager.count(m_featureName,"feature_ui","deco2UnlockWindow","impression");
      }
      
      public function getTimeRemainingForRedeemUnlock() : Number
      {
         return (FarmGameUtil.synchronizedDateToNumber(this.XmasGiftRedeemStartDate) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
      }
   }
}

