package Managers
{
   import Classes.Constants.WorldsConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericBuyPreviewPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import Events.TileUnlockEvent;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TGenericTransaction;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.TurtleInnovationCollectionWindow;
   import Widgets.Windows.TurtleInnovationRewardWindow;
   import Widgets.Windows.TurtleInnovationTileUnlockWindow;
   import Widgets.Windows.TurtleInnovationWindow;
   import flash.utils.Dictionary;
   
   public class TurtleInnovationManager extends BaseFeatureManager
   {
      
      private static const SERVICE_CLASS:String = "TurtleInnovationService";
      
      private static const SERVICE_FUNC_HARVEST:String = "harvestShrine";
      
      public static const EVENT_TILE_UNLOCK:String = "TurtleInnovationTileUnlock";
      
      public static const CONSUMABLE_NAME_MAP:Object = {
         "c1":"airstone",
         "c2":"waterstone",
         "c3":"firestone",
         "c4":"earthstone"
      };
      
      public static const CONSUMABLE_SHRINE_MAP:Object = {
         "shrinefire":"firestone",
         "shrinewater":"waterstone",
         "shrineearth":"earthstone",
         "shrineair":"airstone",
         "homeshrine":"airstone",
         "shrinelava":"airstone",
         "shrinestorm":"airstone"
      };
      
      public static const DOOBER_ANIMATION_MAP:Object = {
         "element2Add0_mc":"element2Add1_mc",
         "element1Add0_mc":"element1Add1_mc",
         "element0Add0_mc":"element0Add1_mc",
         "element3Add0_mc":"element3Add1_mc",
         "element2Add_mc":"element2Add2_mc",
         "element1Add_mc":"element1Add2_mc",
         "element0Add_mc":"element0Add2_mc",
         "element3Add_mc":"element3Add2_mc",
         "element2Add2_mc":"element2Add3_mc",
         "element1Add2_mc":"element1Add3_mc",
         "element0Add2_mc":"element0Add3_mc",
         "element3Add2_mc":"element3Add3_mc"
      };
      
      public static const REGION_BONUS_MAP:Object = {
         "1":"pegacorn_elementalshard",
         "2":"pegacorn_elementalbalance"
      };
      
      public static const COLLECTION_EA_REWARD_MAP:Object = {
         "collection1":"pottedfire",
         "collection2":"pottedfountain",
         "collection7":"pottedwhirlwind",
         "collection6":"cactusdesertrose"
      };
      
      public static const FEATURE_NAME:String = "TurtleInnovation";
      
      private static const WINDOW_MAIN_UI:String = "mainUI";
      
      private static const WINDOW_COLLECTION_UI:String = "collectionsUI";
      
      private static const WINDOW_UNLOCK_UI:String = "unlockUI";
      
      private static const WINDOW_REWARD_UI:String = "rewardUI";
      
      private static const BUNDLE_ID:String = "TurtleInnovation_Brag";
      
      private static const BUNDLE_BONUS1_ID:String = "TurtleInnovation_BragBonus1";
      
      private static const BUNDLE_BONUS2_ID:String = "TurtleInnovation_BragBonus2";
      
      public static const PM_FEATURE_CURRENCY_NAME:String = "elementalshards";
      
      public static const PM_FO_KEY_PACKAGE_GRANT:String = "elementalshards";
      
      public static const CONSUMABLE_REQUIRED:int = 30;
      
      public static const FEATURE_OPTIONS_COLLECTION_KEY:String = "collections";
      
      private static const LAST_HARVEST_TIME_KEY:String = "_lastHarvestTimeKey";
      
      private static const SKIP_COST:int = 5;
      
      public const FEATURE_OPTIONS_KEY:String = "TurtleInnovation";
      
      public const FEATURE_EA_REWARDS_GRANT:String = "grantEARewards";
      
      private var m_assetPaths:Object = null;
      
      private var m_staticData:Object;
      
      private var m_rewardLootTable:Array;
      
      private var m_rewardLootTableIndex:int;
      
      private var m_isInitialized:Boolean;
      
      public var m_turtleMainWindow:TurtleInnovationWindow;
      
      public var m_turtleCollectionWindow:TurtleInnovationCollectionWindow;
      
      public function TurtleInnovationManager(featureName:String, featureConfig:XML = null)
      {
         super(featureName,featureConfig);
         this.m_rewardLootTable = new Array();
         this.initialize();
      }
      
      public static function getInstance(featureName:String = "TurtleInnovation") : TurtleInnovationManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,TurtleInnovationManager) as TurtleInnovationManager;
      }
      
      public static function getFriendlyName(itemName:String) : String
      {
         var result:String = "";
         if(ZLocUtils.hasString("Items",itemName + "_friendlyName"))
         {
            result = ZLocUtils.tk_pk_asTitle("Items:" + itemName + "_friendlyName");
         }
         else
         {
            result = itemName;
         }
         return result;
      }
      
      public function initialize() : void
      {
         var collectionData:Object = null;
         var i:int = 0;
         var consName:String = null;
         this.m_isInitialized = true;
         this.loadStaticData();
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.FEATURE_OPTIONS_KEY,FEATURE_OPTIONS_COLLECTION_KEY);
         if(!featureData)
         {
            collectionData = new Object();
            collectionData["collections"] = new Array();
            collectionData["bonusRewards"] = new Array();
            FeatureOptionsManager.getInstance().setFeatureOption(this.FEATURE_OPTIONS_KEY,FEATURE_OPTIONS_COLLECTION_KEY,collectionData);
         }
         var preMarketingFeatureUserCount:int = FeatureOptionsInventoryManager.getInstance().getCountByName(PM_FEATURE_CURRENCY_NAME);
         var FOValue:int = int(FeatureOptionsManager.getInstance().getFeatureOption(DreamFishPremarketingManager.FEATURE_NAME,PM_FO_KEY_PACKAGE_GRANT));
         if(preMarketingFeatureUserCount >= CONSUMABLE_REQUIRED && FOValue == 0)
         {
            FeatureOptionsManager.getInstance().setFeatureOption(DreamFishPremarketingManager.FEATURE_NAME,PM_FO_KEY_PACKAGE_GRANT,1);
            for(i = 1; i <= 4; i++)
            {
               consName = CONSUMABLE_NAME_MAP["c" + i];
               FeatureOptionsInventoryManager.getInstance().addCountByName(consName,1);
            }
         }
      }
      
      public function initEventListener() : void
      {
         GlobalEventManager.getInstance().addEventListener(EVENT_TILE_UNLOCK,this.onTileUnlock);
      }
      
      public function get shrines() : Object
      {
         return this.m_staticData.shrines;
      }
      
      public function get collections() : Object
      {
         return this.m_staticData.collections;
      }
      
      public function get rewards() : Object
      {
         return this.m_staticData.rewards;
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
         var division:Object = null;
         var asset:XML = null;
         var itemsXML:XMLList = null;
         var item:Object = null;
         var shrine:Object = null;
         var collection:Object = null;
         var rewardGroup:Object = null;
         var rewardList:Array = null;
         var reward:Object = null;
         this.m_staticData = new Object();
         this.m_staticData.shrines = new Array();
         this.m_staticData.collections = new Array();
         this.m_staticData.rewards = new Array();
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
            listArray = Utilities.xmlListToArray(featureXML.divisions.division);
            for each(division in listArray)
            {
               itemsXML = division.items.item;
               item = null;
               if(division.@name == "shrines")
               {
                  for each(item in itemsXML)
                  {
                     shrine = new Object();
                     shrine["name"] = item.@name.toString();
                     shrine["harvestReward"] = item.@collectionCompleteReward.toString();
                     shrine["harvestRewardCount"] = parseInt(item.@count);
                     shrine["movieClipName"] = item.@asset.toString();
                     shrine["harvestTime"] = item.@cost.toString();
                     shrine["region"] = parseInt(item.@tier);
                     shrine["tileLocations"] = this.getTileLocationsArray(item);
                     shrine["stoneName"] = CONSUMABLE_SHRINE_MAP[shrine["name"]];
                     this.m_staticData.shrines.push(shrine);
                  }
               }
               else if(division.@name.toString() == "collections")
               {
                  for each(item in division.items.item)
                  {
                     collection = new Object();
                     collection["name"] = item.@name.toString();
                     collection["consumables"] = this.getConsumablesArray(item);
                     collection["index"] = parseInt(item.@index);
                     collection["collectionCompleteReward"] = item.@collectionCompleteReward.toString();
                     collection["region"] = parseInt(item.@tier);
                     collection["items"] = this.getRewardItemsForCollection(listArray,collection["name"]);
                     this.m_staticData.collections.push(collection);
                  }
               }
               else if(division.@name.toString().indexOf("reward_") >= 0)
               {
                  rewardGroup = new Object();
                  rewardGroup["name"] = division.@name.toString();
                  rewardList = new Array();
                  for each(item in division.items.item)
                  {
                     reward = new Object();
                     reward["name"] = item.@name.toString();
                     reward["index"] = parseInt(item.@index);
                     reward["animationMc"] = item.@asset.toString();
                     rewardList.push(reward);
                  }
                  rewardGroup["rewardItems"] = rewardList;
                  this.m_staticData.rewards.push(rewardGroup);
               }
            }
         }
      }
      
      public function hasDeterministicReward(shrine:Object, reward:Object) : Boolean
      {
         var result:Boolean = false;
         if(shrine.harvestRewardCount == reward["rewardItems"].length)
         {
            result = true;
         }
         return result;
      }
      
      public function initRewardLootTable(data:Object) : void
      {
         var reward:int = 0;
         var rewardList:Array = data.turtleInnovationRewardLootTable;
         var rewardIndex:Dictionary = this.buildRewardIndex("reward_all");
         if(rewardList)
         {
            for each(reward in rewardList)
            {
               this.m_rewardLootTable.push(rewardIndex[reward]);
            }
         }
         this.m_rewardLootTableIndex = data.rewardLootTableIndex;
      }
      
      public function skipHarvestTime(shrineName:String) : void
      {
         var key:String = shrineName + LAST_HARVEST_TIME_KEY;
         if(Global.player.canBuyCash(SKIP_COST))
         {
            Global.player.cash -= SKIP_COST;
            Global.player.setFeatureLastShown(key,(GlobalEngine.serverTime - FarmGameUtil.NUM_MSECS_IN_DAY) / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"skipHarvestTime",null,[m_featureName,shrineName]),true);
         }
      }
      
      public function resetHarvestTime(shrineName:String, tileName:String) : void
      {
         var shrineKey:String = shrineName + LAST_HARVEST_TIME_KEY;
         Global.player.setFeatureLastShown(shrineKey,(GlobalEngine.serverTime - FarmGameUtil.NUM_MSECS_IN_DAY) / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"resetHarvestTime",null,[m_featureName,shrineName,tileName]),true);
      }
      
      public function isShrineReadyForHarvest(shrine:Object) : Boolean
      {
         var tile:String = null;
         var result:Boolean = false;
         var key:String = shrine.name + LAST_HARVEST_TIME_KEY;
         var throttleTime:int = int(shrine.harvestTime);
         var unlocked:Boolean = false;
         for each(tile in shrine.tileLocations)
         {
            if(this.isTileUnlocked(tile))
            {
               unlocked = true;
            }
         }
         if(unlocked || shrine.tileLocations.length == 0)
         {
            if(this.getTimeLeft(key,throttleTime) <= 0)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function getTimeLeft(key:String, throttleTime:int) : int
      {
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         return int(throttleTime - timeSinceLastFeed);
      }
      
      public function getTimeLeftForShrine(shrine:Object) : int
      {
         var key:String = shrine.name + LAST_HARVEST_TIME_KEY;
         var throttleTime:int = int(shrine.harvestTime);
         return this.getTimeLeft(key,throttleTime);
      }
      
      private function buildRewardIndex(rewardGroupName:String) : Dictionary
      {
         var reward:Object = null;
         var item:Object = null;
         var result:Dictionary = new Dictionary();
         for each(reward in this.m_staticData.rewards)
         {
            if(reward.name == rewardGroupName)
            {
               for each(item in reward.rewardItems)
               {
                  result[item.index] = item.name;
               }
               break;
            }
         }
         return result;
      }
      
      public function getRewardGroupByName(rewardGroupName:String) : Object
      {
         var reward:Object = null;
         var result:Object = null;
         for each(reward in this.m_staticData.rewards)
         {
            if(reward.name == rewardGroupName)
            {
               result = reward;
               break;
            }
         }
         return result;
      }
      
      public function getShrineObjectByName(shrineName:String) : Object
      {
         var shrine:Object = null;
         var result:Object = null;
         for each(shrine in this.m_staticData.shrines)
         {
            if(shrine.name == shrineName)
            {
               result = shrine;
               break;
            }
         }
         return result;
      }
      
      private function getRewardItemsForCollection(divisions:Array, collectionName:String) : Array
      {
         var division:Object = null;
         var item:Object = null;
         var rewardItem:Object = null;
         var rewardItems:Array = new Array();
         for each(division in divisions)
         {
            if(division.@name.toString() == collectionName)
            {
               for each(item in division.items.item)
               {
                  rewardItem = new Object();
                  rewardItem["name"] = item.@code.toString();
                  rewardItem["threshold"] = item.@threshold.toString();
                  rewardItem["probability"] = item.@probability.toString();
                  if(item.@asset.toString() != "")
                  {
                     rewardItem["assetUrl"] = item.@asset.toString();
                  }
                  rewardItems.push(rewardItem);
               }
               break;
            }
         }
         return rewardItems;
      }
      
      private function getTileLocationsArray(item:Object) : Array
      {
         var result:Array = new Array();
         if(item.@tile1.toString() != "")
         {
            result.push(item.@tile1.toString());
         }
         if(item.@tile2.toString() != "")
         {
            result.push(item.@tile2.toString());
         }
         return result;
      }
      
      private function getConsumablesArray(item:Object) : Dictionary
      {
         var result:Dictionary = new Dictionary();
         if(item.@c1.toString() != "" && item.@c1 > 0)
         {
            result[CONSUMABLE_NAME_MAP["c1"]] = item.@c1.toString();
         }
         if(item.@c2.toString() != "" && item.@c2 > 0)
         {
            result[CONSUMABLE_NAME_MAP["c2"]] = item.@c2.toString();
         }
         if(item.@c3.toString() != "" && item.@c3 > 0)
         {
            result[CONSUMABLE_NAME_MAP["c3"]] = item.@c3.toString();
         }
         if(item.@c4.toString() != "" && item.@c4 > 0)
         {
            result[CONSUMABLE_NAME_MAP["c4"]] = item.@c4.toString();
         }
         return result;
      }
      
      public function get mainWindowPath() : String
      {
         return this.m_assetPaths[WINDOW_MAIN_UI];
      }
      
      public function get unlockWindowPath() : String
      {
         return this.m_assetPaths[WINDOW_UNLOCK_UI];
      }
      
      public function get rewardWindowPath() : String
      {
         return this.m_assetPaths[WINDOW_REWARD_UI];
      }
      
      public function get collectionWindowPath() : String
      {
         return this.m_assetPaths[WINDOW_COLLECTION_UI];
      }
      
      public function getConsumableForShrine(shrine:Object) : String
      {
         var reward:Object = null;
         var consumable:String = "";
         for each(reward in this.m_staticData.rewards)
         {
            if(reward.name == shrine.harvestReward)
            {
               consumable = reward.rewardItems[0].name;
            }
         }
         return consumable;
      }
      
      private function onTileUnlock(event:TileUnlockEvent) : void
      {
         var shrine:Object = null;
         var tileName:String = event.tileData.getItemName();
         var shrineName:String = "";
         for each(shrine in this.m_staticData.shrines)
         {
            if(shrine.tileLocations.indexOf(tileName) >= 0)
            {
               shrineName = shrine.name;
               this.resetHarvestTime(shrineName,tileName);
               break;
            }
         }
         UI.displayPopup(new TurtleInnovationTileUnlockWindow(m_featureName,shrineName,this.unlockWindowPath));
         FarmStatsManager.count("tenguann_innovation_tileunlock","unlock_shrine_farm",shrineName,tileName);
      }
      
      public function harvestShrine(shrine:Object) : void
      {
         var item:Object = null;
         var animationMc:String = null;
         var leftDoober:String = null;
         var rightDoober:String = null;
         var reward:Object = this.getRewardGroupByName(shrine.harvestReward);
         var key:String = shrine.name + LAST_HARVEST_TIME_KEY;
         var rewardCount:int = this.getConsumableCountToBeAdded(shrine.tileLocations);
         Global.player.setFeatureLastShown(key,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         if(this.hasDeterministicReward(shrine,reward))
         {
            for each(item in reward.rewardItems)
            {
               this.m_turtleMainWindow.playHarvestanimation(item.animationMc,rewardCount);
               FeatureOptionsInventoryManager.getInstance().addCountByName(item.name,rewardCount);
            }
         }
         else
         {
            animationMc = null;
            if(rewardCount == 1)
            {
               animationMc = this.getHarvestanimation(this.m_rewardLootTable[this.m_rewardLootTableIndex]);
               this.m_turtleMainWindow.playHarvestanimation(animationMc,1);
               FeatureOptionsInventoryManager.getInstance().addCountByName(this.m_rewardLootTable[this.m_rewardLootTableIndex],1);
               this.m_rewardLootTableIndex = (this.m_rewardLootTableIndex + 1) % this.m_rewardLootTable.length;
            }
            else if(rewardCount == 2)
            {
               animationMc = this.getHarvestanimation(this.m_rewardLootTable[this.m_rewardLootTableIndex]);
               leftDoober = DOOBER_ANIMATION_MAP[animationMc];
               this.m_turtleMainWindow.playHarvestanimation(leftDoober,1);
               FeatureOptionsInventoryManager.getInstance().addCountByName(this.m_rewardLootTable[this.m_rewardLootTableIndex],1);
               this.m_rewardLootTableIndex = (this.m_rewardLootTableIndex + 1) % this.m_rewardLootTable.length;
               animationMc = this.getHarvestanimation(this.m_rewardLootTable[this.m_rewardLootTableIndex]);
               rightDoober = DOOBER_ANIMATION_MAP[DOOBER_ANIMATION_MAP[animationMc]];
               this.m_turtleMainWindow.playHarvestanimation(rightDoober,1);
               FeatureOptionsInventoryManager.getInstance().addCountByName(this.m_rewardLootTable[this.m_rewardLootTableIndex],1);
               this.m_rewardLootTableIndex = (this.m_rewardLootTableIndex + 1) % this.m_rewardLootTable.length;
            }
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,SERVICE_FUNC_HARVEST,null,[m_featureName,shrine.name]),true);
      }
      
      private function getConsumableCountToBeAdded(tileArray:Array) : int
      {
         var tileName:String = null;
         var result:int = 0;
         if(tileArray.length == 0)
         {
            result = this.isR2Unlocked() ? 2 : 1;
         }
         else
         {
            for each(tileName in tileArray)
            {
               if(this.isTileUnlocked(tileName))
               {
                  result++;
               }
            }
         }
         return result;
      }
      
      public function isCollectionItemRedeemed(collectionName:String, rewardItemName:String) : Boolean
      {
         return this.isRewardRedeemed(collectionName,rewardItemName);
      }
      
      public function isCollectionRewardRedeemed(collectionName:String) : Boolean
      {
         return this.isRewardRedeemed("collections",collectionName);
      }
      
      private function isRewardRedeemed(rewardKey:String, rewardItemName:String) : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.FEATURE_OPTIONS_KEY,FEATURE_OPTIONS_COLLECTION_KEY);
         var inventoryData:Object = featureData[rewardKey];
         if(Boolean(inventoryData) && Boolean(inventoryData.hasOwnProperty(rewardItemName)) && inventoryData[rewardItemName] > 0)
         {
            result = true;
         }
         return result;
      }
      
      public function isBonusRedeemedForRegion(regionIndex:int) : Boolean
      {
         var rewardItemName:String = REGION_BONUS_MAP[regionIndex];
         var result:Boolean = false;
         if(Boolean(rewardItemName) && this.isRewardRedeemed("bonusRewards",rewardItemName))
         {
            result = true;
         }
         return result;
      }
      
      public function redeemCollection(collection:Object) : void
      {
         var consumableName:String = null;
         for(consumableName in collection.consumables)
         {
            FeatureOptionsInventoryManager.getInstance().removeCountByName(consumableName,collection.consumables[consumableName]);
         }
         this.m_turtleCollectionWindow.tintWindow();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"redeemCollection",this.onRedeemResponse,[m_featureName,collection.name]),true);
      }
      
      private function onGrantResponse(result:Object) : void
      {
         var collectionName:String = null;
         var featureData:Object = null;
         for(collectionName in COLLECTION_EA_REWARD_MAP)
         {
            featureData = FeatureOptionsManager.getInstance().getFeatureOption(this.FEATURE_OPTIONS_KEY,FEATURE_OPTIONS_COLLECTION_KEY);
            if(featureData[collectionName] == null)
            {
               featureData[collectionName] = new Array();
            }
            featureData[collectionName][COLLECTION_EA_REWARD_MAP[collectionName]] = 1;
            FeatureOptionsManager.getInstance().setFeatureOption(this.FEATURE_OPTIONS_KEY,FEATURE_OPTIONS_COLLECTION_KEY,featureData);
         }
         FeatureOptionsManager.getInstance().setFeatureOption(this.FEATURE_OPTIONS_KEY,this.FEATURE_EA_REWARDS_GRANT,1);
         this.m_turtleCollectionWindow.refreshWindow();
      }
      
      private function onRedeemResponse(result:Object) : void
      {
         this.m_turtleCollectionWindow.untintWindow();
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.FEATURE_OPTIONS_KEY,FEATURE_OPTIONS_COLLECTION_KEY);
         if(featureData[result.collectionName] == null)
         {
            featureData[result.collectionName] = new Array();
         }
         featureData[result.collectionName][result.rewardItem] = 1;
         Global.player.addGift(String(result.rewardItem));
         if(result.bonusRewardItem)
         {
            Global.player.addGift(String(result.bonusRewardItem));
            featureData["bonusRewards"][result.bonusRewardItem] = 1;
            if(result.bonusRewardItem == REGION_BONUS_MAP[1])
            {
               UI.displayPopup(new TurtleInnovationRewardWindow(m_featureName,result.bonusRewardItem,BUNDLE_BONUS1_ID,this.rewardWindowPath),false);
            }
            else
            {
               UI.displayPopup(new TurtleInnovationRewardWindow(m_featureName,result.bonusRewardItem,BUNDLE_BONUS2_ID,this.rewardWindowPath),false);
            }
         }
         if(result.collectionRewardItem)
         {
            featureData["collections"][result.collectionName] = 1;
            Global.player.addGift(String(result.collectionRewardItem));
            UI.displayPopup(new TurtleInnovationRewardWindow(m_featureName,result.collectionRewardItem,BUNDLE_ID,this.rewardWindowPath),false);
         }
         UI.displayPopup(new TurtleInnovationRewardWindow(m_featureName,result.rewardItem,BUNDLE_ID,this.rewardWindowPath),false);
         FeatureOptionsManager.getInstance().setFeatureOption(this.FEATURE_OPTIONS_KEY,FEATURE_OPTIONS_COLLECTION_KEY,featureData);
         this.m_turtleMainWindow.refreshWindow();
         this.m_turtleCollectionWindow.refreshWindow();
      }
      
      public function isTileUnlocked(itemName:String) : Boolean
      {
         if(Global.world.getObjectsByName(itemName).length > 0)
         {
            return false;
         }
         return true;
      }
      
      public function isCollectionRedeemable(collection:Object) : Boolean
      {
         var consumableName:String = null;
         var result:Boolean = false;
         for(consumableName in collection.consumables)
         {
            if(this.getConsumableItemCountByName(consumableName) < collection.consumables[consumableName])
            {
               result = false;
               break;
            }
            result = true;
         }
         return result;
      }
      
      public function iaAnyCollectionRedeemable() : Boolean
      {
         var collection:Object = null;
         var result:Boolean = false;
         for each(collection in this.m_staticData.collections)
         {
            if(this.isCollectionRedeemable(collection))
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      private function getHarvestanimation(rewardName:String) : String
      {
         var reward:Object = null;
         var item:Object = null;
         var animationMc:String = null;
         for each(reward in this.m_staticData.rewards)
         {
            if(reward.name == "reward_all")
            {
               for each(item in reward.rewardItems)
               {
                  if(item.name == rewardName)
                  {
                     animationMc = item.animationMc;
                     break;
                  }
               }
            }
         }
         return animationMc;
      }
      
      public function showMainUI() : void
      {
         if(!this.m_isInitialized)
         {
            this.initialize();
         }
         this.m_turtleMainWindow = new TurtleInnovationWindow(m_featureName,this.mainWindowPath);
         UI.displayPopup(this.m_turtleMainWindow);
      }
      
      public function showCollectionUI() : void
      {
         if(!this.m_isInitialized)
         {
            this.initialize();
         }
         this.m_turtleCollectionWindow = new TurtleInnovationCollectionWindow(m_featureName,this.collectionWindowPath);
         UI.displayPopup(this.m_turtleCollectionWindow,false);
      }
      
      public function isR2Unlocked() : Boolean
      {
         var featureData:int = int(FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.WORLD_SEASONS,WorldsConstants.WORLD_ID_TURTLEISLAND));
         if(featureData >= 2)
         {
            return true;
         }
         return false;
      }
      
      public function grantEARewards() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"grantEARewards",this.onGrantResponse,[m_featureName]),true);
      }
      
      public function get skipCost() : int
      {
         return SKIP_COST;
      }
      
      public function getConsumableItemCountByName(itemName:String = "") : int
      {
         return FeatureOptionsInventoryManager.getInstance().getCountByName(itemName);
      }
      
      public function buyItem(item:FarmItem, collectionName:String) : void
      {
         var confirmationText:String = null;
         var bought:Boolean = false;
         var onAcceptBuyConfirmation:Function = function(event:GenericPopupEvent):void
         {
            var bought:Boolean = false;
            if(event.button == GenericPopup.ACCEPT)
            {
               bought = Global.player.buyFarmItem(item,Currency.CASH,1,true,false);
               if(bought)
               {
                  UI.displayPopup(new TurtleInnovationRewardWindow(m_featureName,item.name,null,rewardWindowPath),false);
                  FarmStatsManager.count("tenguann_collections_ui","buy_item",collectionName,item.name,"","",item.cash);
               }
            }
         };
         if(Global.player.canBuyCash(item.cash))
         {
            if(item.cash >= 10)
            {
               confirmationText = ZLocUtils.t("Dialogs","FarmCashBuyConfirmation",{"price":item.cash});
               UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,onAcceptBuyConfirmation,"farmAnimatedCashConfirmation",true,true);
            }
            else
            {
               bought = Global.player.buyFarmItem(item,Currency.CASH,1,true,false);
               if(bought)
               {
                  UI.displayPopup(new TurtleInnovationRewardWindow(m_featureName,item.name,null,this.rewardWindowPath),false);
                  FarmStatsManager.count("tenguann_collections_ui","buy_item",collectionName,item.name,"","",item.cash);
               }
            }
         }
      }
      
      public function showPreviewWindow(item:FarmItem, itemSwf:String = null) : void
      {
         UI.displayPopup(new GenericBuyPreviewPopup(item,"",GenericPopup.TYPE_ACCEPTCANCEL,null,itemSwf),false);
      }
      
      public function highlightTiles(tileNames:Array) : void
      {
         if(tileNames)
         {
            if(ItemFinderManager.getInstance().highlightMultipleWorldItems(tileNames).length > 0)
            {
               if(this.m_turtleMainWindow)
               {
                  this.m_turtleMainWindow.close();
               }
               ItemFinderManager.getInstance().highlightMultipleWorldItems(tileNames);
            }
         }
      }
   }
}

