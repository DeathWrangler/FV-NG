package Managers
{
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureBuilding;
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Classes.FeatureMessagingDefinition;
   import Classes.MultiRewardTreasureConstructionBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Engine.Managers.InputManager;
   import Engine.Managers.TransactionManager;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.CraftingBasket.CraftingBasketCongratsWindow;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FeaturePackagesBuyWindow;
   import Widgets.Windows.JMInnovationGrantPopupWindow;
   import Widgets.Windows.JMInnovationWindow;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class JMInnovationManager extends BaseFeatureManager
   {
      
      private static const FEATURE_NAME:String = "JMInnovation";
      
      private static const WINDOW_MAIN:String = "main";
      
      private static const WINDOW_GRANT:String = "grant";
      
      private static const WINDOW_BUYDIALOG:String = "buyDialog";
      
      private static const WINDOW_REWARD:String = "reward";
      
      private static const WINDOW_BUILDING:String = "building";
      
      private static const WINDOW_CRAFT_CONFIRM:String = "craftConfirm";
      
      private static const WINDOW_USE_CONFIRM:String = "useConfirm";
      
      private static const INNOVATION_FEATURE_SEEN_FLAG:String = "JMInnovation_Tutorial";
      
      private static const EVENT_PREREQ_TILE_UNLOCK:String = "JMInnovationGrindTileUnlock";
      
      private static const GATHER_TIME_KEY:String = "gatherTimeKey";
      
      private static const CRAFT_TIME_KEY:String = "craftTimeKey";
      
      private static const OPTION_CRAFT_STATE:String = "cs";
      
      private static const OPTION_BUFFS_COUNT:String = "Buffs";
      
      public static const TOTAL_BUFF_COUNT:int = 10;
      
      public static const STATE_GATHER:int = 1;
      
      public static const STATE_CRAFT:int = 1;
      
      public static const STATE_COLLECT:int = 2;
      
      public static const STATE_IDLE:int = 3;
      
      public static const STATE_LOCKED:int = 4;
      
      public static const FEATURE_OPTIONS_KEY:String = "JMInnovation";
      
      private static const CONJURING_GEMS_MAP:Object = {
         "xjm_treasure_s_w":10,
         "xjm_treasure_s":10,
         "xjm_treasure_m_w":20,
         "xjm_treasure_m":20,
         "xjm_treasure_l_w":30,
         "xjm_treasure_l":30,
         "xjm_treasure_xl_w":40,
         "xjm_treasure_xl":40
      };
      
      private static const INGREDIENT_TYPE_MAP:Object = {
         "xjm_bigbuildable":"Magic Roots",
         "bldg_xjm_harvestbuildable":"Mystical Sap",
         "xjm_elitehorses":"Enchanted Manure"
      };
      
      private static const OPEN_UI_DELAY:int = 5000;
      
      private static const UPDATE_HUD_DELAY:int = 20000;
      
      private static var m_initialized:Boolean = false;
      
      private const SERVICE_CLASS:String = "JMInnovationService";
      
      private const SERVICE_FUNC_USEBUFF:String = "useBuff";
      
      private var m_assetPaths:Object = null;
      
      private var m_featureConfigData:Object;
      
      private const DEFAULT_THROTTLE_TIME:int = 18000;
      
      private var m_itemName:String = "xjm_oogastatue";
      
      private var m_tileName:String = "xjm_rubbletreasure_special_tile";
      
      private var m_bucketPackages:Array = null;
      
      private var m_timer:Timer;
      
      private var m_window:JMInnovationWindow;
      
      protected var m_staticData:Object;
      
      public function JMInnovationManager(featureName:String, featureConfig:XML = null)
      {
         super(featureName,featureConfig);
      }
      
      public static function getInstance(featureName:String = "JMInnovation") : JMInnovationManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,JMInnovationManager) as JMInnovationManager;
      }
      
      public function getConjuringGems(treasureName:String) : int
      {
         return CONJURING_GEMS_MAP[treasureName];
      }
      
      public function initialize() : void
      {
         var building:String = null;
         this.loadStaticData();
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,m_featureName);
         if(!featureData)
         {
            featureData = new Object();
            for each(building in this.buildingNameArray)
            {
               featureData[building] = new Object();
               if(building == "xjm_b0")
               {
                  featureData[building]["state"] = STATE_IDLE;
               }
               else
               {
                  featureData[building]["state"] = STATE_LOCKED;
               }
            }
            featureData[OPTION_BUFFS_COUNT] = new Object();
            featureData[OPTION_BUFFS_COUNT][this.autoGrantBuff] = 1;
            featureData[OPTION_CRAFT_STATE] = STATE_LOCKED;
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,m_featureName,featureData);
         }
      }
      
      public function get autoGrantBuff() : String
      {
         return this.m_staticData.initialGrant;
      }
      
      private function loadStaticData() : void
      {
         var itemXML:XML = null;
         var asset:XML = null;
         this.m_staticData = new Object();
         this.m_staticData.buffs = new Array();
         this.m_staticData.buildings = new Array();
         this.m_staticData.waitTimeArray = new Array();
         this.m_staticData.maxCountArray = new Array();
         this.m_staticData.rewardArray = new Array();
         this.m_staticData.endDate = "";
         this.m_staticData.initialGrant = "";
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
            this.m_staticData.initialGrant = featureXML.bucketItem.@code.toString();
            for each(itemXML in featureXML.mystrees.mystree)
            {
               this.m_staticData.buffs.push(itemXML.@code.toString());
            }
            for each(itemXML in featureXML.items.item)
            {
               this.m_staticData.buildings.push(itemXML.@name.toString());
            }
            for each(itemXML in featureXML.items.item)
            {
               this.m_staticData.waitTimeArray.push(parseInt(itemXML.@cost));
            }
            for each(itemXML in featureXML.items.item)
            {
               this.m_staticData.maxCountArray.push(parseInt(itemXML.@max));
            }
            for each(itemXML in featureXML.items.item)
            {
               this.m_staticData.rewardArray.push(itemXML.@itemCode.toString());
            }
         }
      }
      
      public function get ConsumableList() : Array
      {
         return this.m_staticData.rewardArray;
      }
      
      public function get recipeList() : Array
      {
         return this.m_staticData.buffs;
      }
      
      public function get mainWindow() : String
      {
         return this.m_assetPaths[WINDOW_MAIN];
      }
      
      public function get grantPopupWindow() : String
      {
         return this.m_assetPaths[WINDOW_GRANT];
      }
      
      public function get buyDialogWindow() : String
      {
         return this.m_assetPaths[WINDOW_BUYDIALOG];
      }
      
      public function get craftConfirmWindow() : String
      {
         return this.m_assetPaths[WINDOW_CRAFT_CONFIRM];
      }
      
      public function get useConfirmWindow() : String
      {
         return this.m_assetPaths[WINDOW_USE_CONFIRM];
      }
      
      public function get rewardWindow() : String
      {
         return this.m_assetPaths[WINDOW_REWARD];
      }
      
      public function buildingMovieClip(num:int) : String
      {
         return this.m_assetPaths[WINDOW_BUILDING + num];
      }
      
      public function getExportNamePrefix(num:int) : String
      {
         var result:String = "";
         switch(num)
         {
            case 1:
               result = "elitehorses_stan";
               break;
            case 2:
               result = "bigbuildable_tina";
               break;
            case 3:
               result = "harvestbuildable_daisy";
         }
         return result;
      }
      
      public function getExportNameSuffix(state:int, prevState:int) : String
      {
         var result:String = "";
         switch(state)
         {
            case 1:
               result = "_send";
               break;
            case 2:
               result = "_ready";
               break;
            case 3:
               result = "_collect";
               if(prevState == 0)
               {
                  result = "_idle";
               }
               break;
            case 4:
               result = "_idle";
         }
         return result;
      }
      
      public function get buildingNameArray() : Array
      {
         return this.m_staticData.buildings;
      }
      
      public function get waitingPeriodArray() : Array
      {
         return this.m_staticData.waitTimeArray;
      }
      
      public function get maxCountArray() : Array
      {
         return this.m_staticData.maxCountArray;
      }
      
      public function initEventListener() : void
      {
         GlobalEventManager.getInstance().addEventListener(EVENT_PREREQ_TILE_UNLOCK,this.conditionallyShowGrantPopup);
      }
      
      public function deleteEventListener() : void
      {
         GlobalEventManager.getInstance().removeEventListener(EVENT_PREREQ_TILE_UNLOCK,this.conditionallyShowGrantPopup);
      }
      
      public function showMainUI() : void
      {
         this.initialize();
         UI.displayPopup(new JMInnovationWindow(null,m_featureName,this.mainWindow));
         FarmStatsManager.count(m_featureName,"feature_ui","main_ui","impression");
      }
      
      public function conditionallyShowGrantPopup(e:Event = null) : void
      {
         var isEA:Boolean = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_JUNGLE);
         if(!isEA)
         {
            this.showGrantPopup();
         }
      }
      
      public function showGrantPopup() : void
      {
         this.initialize();
         UI.displayPopup(new JMInnovationGrantPopupWindow(this.grantPopupWindow,m_featureName));
      }
      
      public function UnlockTileAndPanToBuilding(e:Event) : void
      {
         var specialTileObj:MultiRewardTreasureConstructionBuilding = null;
         var specialTile:Array = Global.world.getObjectsByName(this.m_tileName);
         if(Boolean(specialTile) && specialTile.length > 0)
         {
            specialTileObj = specialTile[0] as MultiRewardTreasureConstructionBuilding;
            if(specialTileObj)
            {
               specialTileObj.unlockNow();
            }
         }
         this.m_timer = new Timer(OPEN_UI_DELAY,1);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.panToTotem);
         this.m_timer.start();
         InputManager.disableInput();
      }
      
      private function getPurchasePackages() : Array
      {
         var bucketXML:XML = null;
         if(!this.m_bucketPackages)
         {
            this.m_bucketPackages = new Array();
            for each(bucketXML in featureConfig.bucketPackages.bucketPackage)
            {
               this.m_bucketPackages.push(bucketXML.@name.toString());
            }
         }
         return this.m_bucketPackages;
      }
      
      public function openBuyWindow(owner:FarmWindow) : void
      {
         UI.displayPopup(new FeaturePackagesBuyWindow(this.buyDialogWindow,m_featureName,this.getPurchasePackages(),owner),false);
      }
      
      public function panToTotem(e:Event) : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.panToTotem);
            InputManager.enableInput();
            UI.stopPopups(false);
         }
         this.m_timer = new Timer(UPDATE_HUD_DELAY,1);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.updateHudVisibility);
         this.m_timer.start();
         var oogaTotem:Array = Global.world.getObjectsByName(this.m_itemName);
         if(Boolean(oogaTotem) && oogaTotem.length > 0)
         {
            ItemFinderManager.getInstance().highlightWorldItems(this.m_itemName);
            this.showMainUI();
         }
      }
      
      private function updateHudVisibility(e:Event) : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.updateHudVisibility);
         }
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(FEATURE_NAME);
         if(featureDef)
         {
            featureDef.updateIconVisibility();
         }
      }
      
      public function GatherConsumable(slotIndex:int) : void
      {
         var buildingName:String = this.buildingNameArray[slotIndex];
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,m_featureName);
         featureData[buildingName]["state"] = STATE_GATHER;
         var key:String = buildingName + GATHER_TIME_KEY;
         Global.player.setFeatureLastShown(key,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,m_featureName,featureData);
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,"gatherConsumable",null,[m_featureName,slotIndex]),true);
      }
      
      public function canJumpToCollectStateForConsumable(slotIndex:int) : Boolean
      {
         var key:String = null;
         var buildingName:String = this.buildingNameArray[slotIndex];
         var canCollect:Boolean = false;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,m_featureName);
         if(Boolean(featureData) && Boolean(featureData.hasOwnProperty(buildingName)) && Boolean(featureData[buildingName].hasOwnProperty("state")))
         {
            if(featureData[buildingName]["state"] == STATE_GATHER)
            {
               canCollect = true;
            }
         }
         if(canCollect)
         {
            key = buildingName + GATHER_TIME_KEY;
            canCollect = this.isWaitingPeriodOver(key,this.waitingPeriodArray[slotIndex]);
         }
         return canCollect;
      }
      
      public function collectConsumable(slotIndex:int) : void
      {
         var buildingName:String = this.buildingNameArray[slotIndex];
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,m_featureName);
         featureData[buildingName]["state"] = STATE_IDLE;
         var rewardCount:int = this.getRewardCount(buildingName);
         FeatureOptionsInventoryManager.getInstance().addCount(this.ConsumableList[slotIndex],rewardCount);
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,m_featureName,featureData);
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,"collectConsumables",null,[m_featureName,slotIndex]));
      }
      
      public function canCraft() : Boolean
      {
         var slotIndex:int = 0;
         var buildingName:String = null;
         var requiredCount:Number = NaN;
         var consumableCount:int = 0;
         var canCraft:Boolean = true;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,m_featureName);
         if(featureData)
         {
            for(slotIndex = 1; slotIndex < this.buildingNameArray.length; slotIndex++)
            {
               buildingName = this.buildingNameArray[slotIndex];
               requiredCount = Number(this.maxCountArray[slotIndex]);
               consumableCount = FeatureOptionsInventoryManager.getInstance().getCount(this.ConsumableList[slotIndex]);
               if(consumableCount < requiredCount)
               {
                  canCraft = false;
               }
            }
         }
         else
         {
            canCraft = false;
         }
         return canCraft;
      }
      
      public function get gemConsumableRequiredForCraft() : int
      {
         return this.maxCountArray[0];
      }
      
      public function get gemConsumableInInventory() : int
      {
         return FeatureOptionsInventoryManager.getInstance().getCount(this.ConsumableList[0]);
      }
      
      public function craft(useGems:Boolean) : void
      {
         var slotIndex:int = 0;
         var requiredCount:Number = NaN;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,m_featureName);
         if(featureData)
         {
            if(useGems)
            {
               FeatureOptionsInventoryManager.getInstance().removeCount(this.ConsumableList[0],this.maxCountArray[0]);
            }
            for(slotIndex = 1; slotIndex < this.buildingNameArray.length; slotIndex++)
            {
               requiredCount = Number(this.maxCountArray[slotIndex]);
               FeatureOptionsInventoryManager.getInstance().removeCount(this.ConsumableList[slotIndex],requiredCount);
            }
            featureData[OPTION_CRAFT_STATE] = STATE_CRAFT;
         }
         var key:String = m_featureName + CRAFT_TIME_KEY;
         Global.player.setFeatureLastShown(key,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,m_featureName,featureData);
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,"craft",null,[m_featureName,int(useGems)]));
      }
      
      public function canJumpToCollectStateForBuff() : Boolean
      {
         var key:String = null;
         var canCollect:Boolean = false;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,m_featureName);
         if(Boolean(featureData) && featureData.hasOwnProperty(OPTION_CRAFT_STATE))
         {
            if(featureData[OPTION_CRAFT_STATE] == STATE_GATHER)
            {
               canCollect = true;
            }
         }
         if(canCollect)
         {
            key = m_featureName + CRAFT_TIME_KEY;
            canCollect = this.isWaitingPeriodOver(key,this.waitingPeriodArray[0]);
         }
         return canCollect;
      }
      
      public function collectBuff(window:JMInnovationWindow) : void
      {
         this.m_window = window;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,m_featureName);
         if(Boolean(featureData) && featureData.hasOwnProperty(OPTION_CRAFT_STATE))
         {
            featureData[OPTION_CRAFT_STATE] = STATE_LOCKED;
         }
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,m_featureName,featureData);
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,"collectBuff",this.onClaimedReward,[m_featureName]));
      }
      
      public function getTimeLeft(key:String, throttleTime:int) : int
      {
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         return int(throttleTime - timeSinceLastFeed);
      }
      
      public function isWaitingPeriodOver(key:String, throttleTime:int = 18000) : Boolean
      {
         var result:Boolean = false;
         if(this.getTimeLeft(key,throttleTime) < 0)
         {
            result = true;
         }
         return result;
      }
      
      public function getGatherProgress(slotIndex:int) : int
      {
         var progress:int = 0;
         var buildingName:String = this.buildingNameArray[slotIndex];
         var throttleTime:int = int(this.waitingPeriodArray[slotIndex]);
         var key:String = buildingName + GATHER_TIME_KEY;
         if(this.isWaitingPeriodOver(key,throttleTime))
         {
            progress = 100;
         }
         else
         {
            progress = (throttleTime - this.getTimeLeft(key,throttleTime)) * 100 / throttleTime;
         }
         return progress;
      }
      
      public function getBuildingLevelBySlotIndex(slotIndex:int) : int
      {
         var level:int = 0;
         var buildingName:String = this.buildingNameArray[slotIndex];
         return level;
      }
      
      public function getBuildingLevelByName(buildingName:String) : int
      {
         var level:int = 0;
         var craftingSystem:FeatureCraftingSystem = null;
         var npcData:Object = null;
         var animalObject:Object = null;
         if(buildingName == "xjm_b0")
         {
            return 1;
         }
         var objects:Array = Global.world.getObjectsByName(buildingName);
         var buildingItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(buildingName);
         if(objects.length == 1)
         {
            level = (objects[0] as FeatureBuilding).storageLevel - 1;
         }
         if(buildingName == "xjm_elitehorses")
         {
            level = 0;
            craftingSystem = FeatureCraftingManager.instance.getSystem(buildingName);
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
         return level;
      }
      
      public function getRewardCount(buildingName:String) : int
      {
         var buildingXml:XML = null;
         var buildingNameStr:String = null;
         var rewardLevelList:XMLList = null;
         var level:XML = null;
         var maxLevel:int = 0;
         var buildingLevel:int = 0;
         var count:int = 0;
         var feature:XML = Global.farmGameSettingsManager.getJMInnovationRewardData(m_featureName);
         if(feature == null)
         {
            throw new Error("Feature config xml not found for JMI.");
         }
         var buildingList:XMLList = feature.buildings[0].building;
         for each(buildingXml in buildingList)
         {
            if(buildingXml.hasOwnProperty("@name"))
            {
               buildingNameStr = buildingXml["@name"];
               if(buildingNameStr == buildingName)
               {
                  rewardLevelList = buildingXml.levels.children();
                  for each(level in rewardLevelList)
                  {
                     if(level.hasOwnProperty("@num"))
                     {
                        maxLevel = parseInt(level["@num"]);
                        buildingLevel = this.getBuildingLevelByName(buildingName);
                        if(maxLevel >= buildingLevel)
                        {
                           if(level.hasOwnProperty("@quantity"))
                           {
                              count = parseInt(level["@quantity"]);
                              break;
                           }
                        }
                     }
                  }
               }
            }
         }
         return count;
      }
      
      public function getLevelXml(buildingName:String) : XML
      {
         var buildingXml:XML = null;
         var buildingNameStr:String = null;
         var rewardLevelList:XMLList = null;
         var level:XML = null;
         var maxLevel:int = 0;
         var buildingLevel:int = 0;
         var result:XML = null;
         var feature:XML = Global.farmGameSettingsManager.getJMInnovationRewardData(m_featureName);
         if(feature == null)
         {
            throw new Error("Feature config xml not found for JMI.");
         }
         var buildingList:XMLList = feature.buildings[0].building;
         for each(buildingXml in buildingList)
         {
            if(buildingXml.hasOwnProperty("@name"))
            {
               buildingNameStr = buildingXml["@name"];
               if(buildingNameStr == buildingName)
               {
                  rewardLevelList = buildingXml.levels.children();
                  for each(level in rewardLevelList)
                  {
                     if(level.hasOwnProperty("@num"))
                     {
                        maxLevel = parseInt(level["@num"]);
                        buildingLevel = this.getBuildingLevelByName(buildingName);
                        if(maxLevel >= buildingLevel)
                        {
                           result = level;
                           break;
                        }
                     }
                  }
               }
            }
         }
         return result;
      }
      
      public function getStateForBuilding(slotIndex:int) : int
      {
         var buildingName:String = null;
         var featureData:Object = null;
         if(slotIndex == 0)
         {
            return STATE_IDLE;
         }
         this.updateStateForBuilding(slotIndex);
         buildingName = this.buildingNameArray[slotIndex];
         featureData = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,m_featureName);
         return parseInt(featureData[buildingName]["state"]);
      }
      
      public function updateStateForBuilding(slotIndex:int) : void
      {
         var featureData:Object = null;
         var state:int = 0;
         var stateChange:Boolean = false;
         var buildingName:String = this.buildingNameArray[slotIndex];
         if(this.getBuildingLevelByName(buildingName) == 0)
         {
            state = STATE_LOCKED;
         }
         else
         {
            featureData = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,m_featureName);
            if(Boolean(featureData) && Boolean(featureData.hasOwnProperty(buildingName)) && Boolean(featureData[buildingName].hasOwnProperty("state")))
            {
               state = parseInt(featureData[buildingName]["state"]);
            }
            if(state == STATE_LOCKED && this.getBuildingLevelByName(buildingName) > 0)
            {
               state = STATE_IDLE;
               stateChange = true;
            }
            else if(state == STATE_GATHER && this.canJumpToCollectStateForConsumable(slotIndex))
            {
               state = STATE_COLLECT;
               stateChange = true;
            }
            featureData[buildingName]["state"] = state;
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,m_featureName,featureData);
         }
         if(stateChange)
         {
         }
      }
      
      public function getAndUpdateStateForCrafting() : int
      {
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,m_featureName);
         var state:int = parseInt(featureData[OPTION_CRAFT_STATE]);
         if(state == STATE_LOCKED && this.canCraft())
         {
            state = STATE_IDLE;
         }
         else if(state == STATE_CRAFT && this.canJumpToCollectStateForBuff())
         {
            state = STATE_COLLECT;
         }
         featureData[OPTION_CRAFT_STATE] = state;
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,m_featureName,featureData);
         return state;
      }
      
      public function onClaimedReward(result:Object) : void
      {
         var farmItem:FarmItem = null;
         var rewardWindow:CraftingBasketCongratsWindow = null;
         if(result.error == null)
         {
            this.updateClaimedCount(result.itemCode);
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(result.itemCode);
            rewardWindow = new CraftingBasketCongratsWindow(this.rewardWindow,m_featureName,farmItem,this.onAcceptReward);
            UI.displayPopup(rewardWindow,false);
         }
      }
      
      private function onAcceptReward(result:Object, window:FarmWindow) : void
      {
         window.close();
         if(this.m_window)
         {
            this.m_window.enableWindow(true);
            this.m_window.refreshWindow();
         }
      }
      
      public function hasMaxCapReacheadForSlot(slotIndex:int) : Boolean
      {
         var result:Boolean = false;
         var maxCap:Number = Number(this.maxCountArray[slotIndex]);
         var consumableCount:int = FeatureOptionsInventoryManager.getInstance().getCount(this.ConsumableList[slotIndex]);
         if(consumableCount >= maxCap)
         {
            result = true;
         }
         return result;
      }
      
      public function getBuffCountForSlot(slotIndex:int) : int
      {
         var buffCount:int = -1;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,m_featureName);
         var buffCode:String = this.recipeList[slotIndex];
         if(Boolean(featureData) && featureData.hasOwnProperty(OPTION_BUFFS_COUNT))
         {
            if(featureData[OPTION_BUFFS_COUNT].hasOwnProperty(buffCode))
            {
               buffCount = int(featureData[OPTION_BUFFS_COUNT][buffCode]);
            }
         }
         return buffCount;
      }
      
      private function getBuildingItemCode() : String
      {
         return Global.farmGameSettingsManager.getFarmItemCodeByName(this.m_itemName);
      }
      
      public function useBuff(buffCode:String) : void
      {
         var sourceItemCode:String = this.getBuildingItemCode();
         if(sourceItemCode)
         {
            AOEBuffsManager.getInstance().setActiveBuffForSourceID(buffCode,sourceItemCode);
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,this.SERVICE_FUNC_USEBUFF,null,[buffCode,sourceItemCode]));
         }
      }
      
      public function getBuffCountByCode(buffCode:String) : Number
      {
         var buffCount:Number = -1;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,m_featureName);
         if(Boolean(featureData) && featureData.hasOwnProperty(OPTION_BUFFS_COUNT))
         {
            buffCount = Number(featureData[OPTION_BUFFS_COUNT][buffCode]);
         }
         return buffCount;
      }
      
      public function deductBuff(buffCode:String) : Boolean
      {
         var result:Boolean = false;
         var buffCount:Number = -1;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,m_featureName);
         if(Boolean(featureData) && featureData.hasOwnProperty(OPTION_BUFFS_COUNT))
         {
            buffCount = Number(featureData[OPTION_BUFFS_COUNT][buffCode]);
            if(buffCount > 0)
            {
               featureData[OPTION_BUFFS_COUNT][buffCode] = featureData[OPTION_BUFFS_COUNT][buffCode] - 1;
               FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,m_featureName,featureData);
               result = true;
            }
         }
         return result;
      }
      
      public function updateClaimedCount(buffCode:String) : void
      {
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,m_featureName);
         if(Boolean(featureData) && featureData.hasOwnProperty(OPTION_BUFFS_COUNT))
         {
            if(featureData[OPTION_BUFFS_COUNT].hasOwnProperty(buffCode))
            {
               featureData[OPTION_BUFFS_COUNT][buffCode] += 1;
            }
            else
            {
               featureData[OPTION_BUFFS_COUNT][buffCode] = 1;
            }
         }
      }
      
      public function get totalBuffCount() : int
      {
         var buffCode:String = null;
         var totalCount:int = 0;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,m_featureName);
         var buffsArray:Array = this.recipeList;
         if(Boolean(featureData) && featureData.hasOwnProperty(OPTION_BUFFS_COUNT))
         {
            for each(buffCode in buffsArray)
            {
               if(featureData[OPTION_BUFFS_COUNT].hasOwnProperty(buffCode))
               {
                  totalCount += featureData[OPTION_BUFFS_COUNT][buffCode];
               }
            }
         }
         return totalCount;
      }
      
      public function hasMaxCapRechedForBuffs() : Boolean
      {
         var result:Boolean = false;
         if(this.totalBuffCount >= TOTAL_BUFF_COUNT)
         {
            result = true;
         }
         return result;
      }
      
      public function isActive() : Boolean
      {
         return Global.player.getSeenFlag(INNOVATION_FEATURE_SEEN_FLAG);
      }
      
      public function getIngredientType(buildingName:String) : String
      {
         return INGREDIENT_TYPE_MAP[buildingName];
      }
      
      public function getTimeLeftForSlot(slotIndex:int) : int
      {
         var buildingName:String = null;
         var throttleTime:int = 0;
         var key:String = null;
         var timeLeft:int = 0;
         if(slotIndex > 0)
         {
            buildingName = this.buildingNameArray[slotIndex];
            throttleTime = int(this.waitingPeriodArray[slotIndex]);
            key = buildingName + GATHER_TIME_KEY;
            timeLeft = this.getTimeLeft(key,throttleTime);
         }
         return timeLeft;
      }
      
      public function getTimeLeftForCraftSlot() : int
      {
         var timeLeft:int = 0;
         var key:String = m_featureName + CRAFT_TIME_KEY;
         timeLeft = this.getTimeLeft(key,this.waitingPeriodArray[0]);
         if(timeLeft < 0)
         {
            timeLeft = 0;
         }
         return timeLeft;
      }
      
      public function getCraftProgress() : Number
      {
         var progress:Number = NaN;
         var key:String = m_featureName + CRAFT_TIME_KEY;
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         return timeSinceLastFeed / this.waitingPeriodArray[0];
      }
      
      public function getActiveBuff(sourceId:String = null) : String
      {
         if(sourceId == null)
         {
            sourceId = this.getBuildingItemCode();
         }
         return AOEBuffsManager.getInstance().getActiveBuffForSourceID(sourceId);
      }
      
      public function getTimeLeftForActiveBuff() : Number
      {
         return AOEBuffsManager.getInstance().getTimeLeftForActiveBuff(this.getBuildingItemCode());
      }
   }
}

