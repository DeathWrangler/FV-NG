package Managers
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.*;
   import Engine.Managers.TransactionManager;
   import GameMode.GMPlantMystreeReskin;
   import Managers.Crafting.CraftingManager;
   import Transactions.TGenericTransaction;
   import Transactions.TSetFeatureFrequencyTimestamp;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.MystreeReskinCraftWindow;
   import Widgets.Windows.MystreeReskinTreeColWindow;
   import Widgets.Windows.MystreeReskinWindow;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class MystreeReskinManagerWithoutEMH implements IMystreeReskinManager
   {
      
      public static const OPTIONS_PLOT_KEY:String = "0";
      
      public static const OPTIONS_COLLECTED_KEY:String = "1";
      
      public static const OPTIONS_COLLECTED_BONUS:String = "2";
      
      public static const FEATURE_OPTIONS_KEY:String = "mystreereskin";
      
      public static const FEATURE_NAME:String = "mystrees_2020";
      
      public static const TEND_SB_QUANTITY_SUFFIX:String = "_sb_quantity_";
      
      private static const ACTION_POST_FEED:String = "postFeed";
      
      private static const CONST_BUCKET:String = "x";
      
      private static const FEATURE_ACTIVE_PREREQ:String = "mystree_v2_feature_enabled";
      
      public static const PLOT_STATE_EMPTY:int = 0;
      
      public static const LVL1_SAPLING:int = 1;
      
      public static const LVL2_SAPLING:int = 2;
      
      public static const LVL3_SAPLING:int = 3;
      
      public static const LVL4_SAPLING:int = 4;
      
      public static const LVL5_SAPLING:int = 5;
      
      public static const LVL6_SAPLING:int = 6;
      
      public static const LVL_FINAL_MYSTREE:int = 6;
      
      public static const SPEEDUP_COST:int = 5;
      
      private static var m_initialized:Boolean = false;
      
      protected static var m_instance:Dictionary = new Dictionary();
      
      protected static const PLOT_INDEX:String = "0";
      
      protected static const TEND_INDEX:String = "1";
      
      private static const MYSTREE_V2_CHRISTMAS_FLAG:String = "ftue_christmas_mystree_v2";
      
      public static const REDEEM_ADDITIONAL_DAYS:int = 2;
      
      private static const FEATURE_TRACKING:String = "GPF_spookyrampshow";
      
      private const ACTION_PLANT_SAPLING:String = "plantSapling";
      
      protected const ACTION_TEND_SAPLING:String = "tendSapling";
      
      private const ACTION_INIT_FEATURE:String = "initFeature";
      
      protected const ACTION_SPEEDUP_SAPLINGS:String = "speedUpSaplings";
      
      private const ACTION_BUY_PLOT:String = "buyPlot";
      
      private const ACTION_BUY_SUNSHINE_BUCKET:String = "buySunshineBucket";
      
      private const DEFAULT_THROTTLE_TIME:int = 21600;
      
      private var m_feedPostPending:Boolean;
      
      private var m_askCallback:Function;
      
      private var m_motdData:Object = null;
      
      private var m_sentForMOTDData:Boolean = false;
      
      private var m_isAskUnlocked:Boolean = true;
      
      protected var m_serviceClass:String;
      
      private const SERVICE_CLASS:String = "MystreeReskinService";
      
      private var m_hasEndDate:Boolean = false;
      
      protected var m_staticData:Object;
      
      protected var m_featureName:String;
      
      private var m_itemName:FarmItem = null;
      
      public function MystreeReskinManagerWithoutEMH(featureName:String, serviceClass:String = "MystreeReskinService")
      {
         super();
         this.m_featureName = featureName;
         this.m_serviceClass = serviceClass;
         this.loadStaticData();
      }
      
      public static function getInstance(featureName:String) : MystreeReskinManagerWithoutEMH
      {
         if(!m_instance)
         {
            m_instance = new Dictionary();
         }
         if(!m_instance.hasOwnProperty(featureName))
         {
            m_instance[featureName] = new MystreeReskinManagerWithoutEMH(featureName);
         }
         return m_instance[featureName] as MystreeReskinManagerWithoutEMH;
      }
      
      private function loadStaticData() : void
      {
         var itemXML:XML = null;
         var maxLevel:Number = NaN;
         var levelXML:XML = null;
         var index:String = null;
         var levelNum:String = null;
         var levelData:Dictionary = null;
         var bonusXML:XML = null;
         var bonusData:Dictionary = null;
         this.m_staticData = new Object();
         this.m_staticData.congratsDialog = "";
         this.m_staticData.bucketItem = "";
         this.m_staticData.recipeId = "";
         this.m_staticData.initialGrant = 0;
         this.m_staticData.speedUpCost = 0;
         this.m_staticData.mystrees = new Array();
         this.m_staticData.bonuses = new Array();
         this.m_staticData.bucketPackages = new Array();
         this.m_staticData.levelInfo = new Dictionary();
         this.m_staticData.bonusInfo = new Dictionary();
         this.m_staticData.mainDialogAssetURL = "";
         this.m_staticData.ftueFlag = "";
         this.m_staticData.numPlots = "16";
         this.m_staticData.craftDialogAssetURL = "";
         this.m_staticData.buyDialogAssetURL = "";
         this.m_staticData.whatisthisPrefixURL = "";
         this.m_staticData.windowName = "";
         this.m_staticData.buildingName = "";
         this.m_staticData.experimentName = "";
         this.m_staticData.plotUnlockCost = 0;
         this.m_staticData.finalSapling = "";
         this.m_staticData.endDate = "";
         this.m_staticData.collectionDialog = "";
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(this.m_featureName);
         if(featureXML != null)
         {
            m_initialized = true;
            this.m_staticData.recipeId = featureXML.crafting.recipes.recipe[0].@name.toString();
            this.m_staticData.bucketItem = featureXML.bucketItem.@code.toString();
            this.m_staticData.initialGrant = featureXML.initialGrant.toString();
            this.m_staticData.speedUpCost = featureXML.speedUpCost.toString();
            this.m_staticData.plotUnlockCost = featureXML.plotUnlockCost.toString();
            this.m_staticData.finalSapling = featureXML.finalSapling.toString();
            this.m_staticData.buildingName = featureXML.buildingName.toString();
            this.m_staticData.experimentName = featureXML.experiment.@name.toString();
            this.m_staticData.windowName = featureXML.windowName.toString();
            this.m_staticData.mainDialogAssetURL = featureXML.UI.dialog.@path.toString();
            this.m_staticData.craftDialogAssetURL = featureXML.UI.craftDialog.@path.toString();
            this.m_staticData.buyDialogAssetURL = featureXML.UI.buyDialog.@path.toString();
            this.m_staticData.whatisthisPrefixURL = featureXML.UI.whatIsThisPrefix.@path.toString();
            this.m_staticData.ftueFlag = featureXML.ftueFlag.toString();
            this.m_staticData.numPlots = featureXML.totalPlots.toString();
            this.m_staticData.collectionDialog = featureXML.UI.congratsDialog.@path.toString();
            if(featureXML.hasOwnProperty("listEndDate"))
            {
               this.m_hasEndDate = true;
               this.m_staticData.endDate = featureXML.listEndDate.toString();
            }
            for each(itemXML in featureXML.mystrees.mystree)
            {
               this.m_staticData.mystrees.push(itemXML.@code.toString());
            }
            for each(bonusXML in featureXML.items.item)
            {
               this.m_staticData.bonuses.push(bonusXML.@code.toString());
            }
            for each(itemXML in featureXML.bucketPackages.bucketPackage)
            {
               this.m_staticData.bucketPackages.push(itemXML.@name.toString());
            }
            maxLevel = 0;
            for each(levelXML in featureXML.levels.level)
            {
               levelNum = levelXML.@num.toString();
               levelData = new Dictionary();
               levelData["quantity"] = levelXML.@quantity.toString();
               levelData["waitTime"] = levelXML.@waitTime.toString();
               maxLevel++;
               this.m_staticData.levelInfo[levelNum] = levelData;
            }
            this.m_staticData.maxLevel = maxLevel > 0 ? maxLevel : LVL_FINAL_MYSTREE;
            index = "";
            if(featureXML.hasOwnProperty("items"))
            {
               for each(bonusXML in featureXML.items.item)
               {
                  bonusData = new Dictionary();
                  bonusData["name"] = bonusXML.@name.toString();
                  bonusData["code"] = bonusXML.@code.toString();
                  index = bonusXML.@index.toString();
                  if(index != "")
                  {
                     this.m_staticData.bonusInfo[index] = bonusData;
                  }
               }
            }
         }
      }
      
      public function getBuildingName() : String
      {
         return this.m_staticData.buildingName;
      }
      
      public function getBonusItemsInfo() : Dictionary
      {
         return this.m_staticData.bonusInfo;
      }
      
      public function getLevelData(level:String) : Dictionary
      {
         if(this.m_staticData.levelInfo.hasOwnProperty(level))
         {
            return this.m_staticData.levelInfo[level];
         }
         return new Dictionary();
      }
      
      public function getBucketPackages() : Array
      {
         return this.m_staticData.bucketPackages;
      }
      
      public function getRecipeItem() : String
      {
         return this.m_staticData.recipeId;
      }
      
      public function getBucketItem() : String
      {
         return this.m_staticData.bucketItem;
      }
      
      public function getPlotUnlockCost() : int
      {
         return parseInt(this.m_staticData.plotUnlockCost);
      }
      
      public function getSpeedupCost() : int
      {
         return parseInt(this.m_staticData.speedUpCost) ? int(parseInt(this.m_staticData.speedUpCost)) : SPEEDUP_COST;
      }
      
      public function getNumOfMystrees() : int
      {
         return this.m_staticData.mystrees.length;
      }
      
      public function getExperimentName() : String
      {
         return this.m_staticData.experimentName;
      }
      
      public function getFeatureName() : String
      {
         return this.m_featureName;
      }
      
      public function getWindowName() : String
      {
         return this.m_staticData.windowName;
      }
      
      public function getMainDialogAssetURL() : String
      {
         return this.m_staticData.mainDialogAssetURL;
      }
      
      public function getCraftDialogAssetURL() : String
      {
         return this.m_staticData.craftDialogAssetURL;
      }
      
      public function getBuyDialogAssetURL() : String
      {
         return this.m_staticData.buyDialogAssetURL;
      }
      
      public function getWhatisthisPrefixURL() : String
      {
         return this.m_staticData.whatisthisPrefixURL;
      }
      
      public function getFtueFlag() : String
      {
         return this.m_staticData.ftueFlag;
      }
      
      public function getFtueChristmasFlag() : String
      {
         return MYSTREE_V2_CHRISTMAS_FLAG;
      }
      
      public function getTendSbQuantityPrefix() : String
      {
         return this.m_featureName + TEND_SB_QUANTITY_SUFFIX;
      }
      
      public function getByDialogURL() : String
      {
         return this.m_staticData.buyDialogAssetURL;
      }
      
      public function getMystreeData() : Array
      {
         return this.m_staticData.mystrees;
      }
      
      public function getBonusCodes() : Array
      {
         return this.m_staticData.bonuses;
      }
      
      public function getEndDate() : String
      {
         return this.m_staticData.endDate;
      }
      
      public function getCollectionDialogURL() : String
      {
         return this.m_staticData.collectionDialog;
      }
      
      public function getMaxLevel() : Number
      {
         return this.m_staticData.maxLevel;
      }
      
      public function get endDate() : String
      {
         return this.m_staticData.endDate;
      }
      
      public function initFeature() : void
      {
         var featureData:Dictionary = null;
         var sbItem:FarmItem = null;
         var i:int = 0;
         var collectionData:Dictionary = null;
         var bonusData:Dictionary = null;
         var bonusCode:String = null;
         var initialGrant:int = 0;
         var treeCode:String = null;
         var isFeatureDataSet:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName);
         if(!isFeatureDataSet)
         {
            featureData = new Dictionary();
            featureData[OPTIONS_PLOT_KEY] = this.initPlotData();
            sbItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_staticData.bucketItem);
            if(sbItem)
            {
               initialGrant = parseInt(this.m_staticData.initialGrant);
               this.addSunshineBuckets(initialGrant);
            }
            collectionData = new Dictionary();
            for(i = 0; i < this.m_staticData.mystrees.length; i++)
            {
               treeCode = this.m_staticData.mystrees[i];
               collectionData[treeCode] = 0;
            }
            bonusData = new Dictionary();
            bonusCode = "";
            for(i = 0; i < this.m_staticData.bonuses.length; i++)
            {
               bonusCode = this.m_staticData.bonuses[i];
               bonusData[bonusCode] = 0;
            }
            featureData[OPTIONS_COLLECTED_KEY] = collectionData;
            featureData[OPTIONS_COLLECTED_BONUS] = bonusData;
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName,featureData);
            TransactionManager.addTransaction(new TGenericTransaction(this.m_serviceClass,this.ACTION_INIT_FEATURE,null,[this.m_featureName]));
         }
      }
      
      public function addSunshineBuckets(num:Number) : void
      {
         var sbItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_staticData.bucketItem);
         Global.player.addGift(sbItem.name,"0",num);
      }
      
      public function setDataForAdditionalRewards() : void
      {
         var treeCode:String = null;
         var FeatureDataSet:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName);
         for(var i:int = 0; i < this.m_staticData.mystrees.length; i++)
         {
            treeCode = this.m_staticData.mystrees[i];
            if(Boolean(FeatureDataSet) && !FeatureDataSet[OPTIONS_COLLECTED_KEY].hasOwnProperty(treeCode))
            {
               FeatureDataSet[OPTIONS_COLLECTED_KEY][treeCode] = 0;
            }
         }
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName,FeatureDataSet);
         TransactionManager.addTransaction(new TGenericTransaction(this.m_serviceClass,"setDataForAdditionalRewards",null,[this.m_featureName]));
      }
      
      protected function initPlotData() : Dictionary
      {
         var plotStates:Dictionary = new Dictionary();
         var numPlots:int = parseInt(this.m_staticData.numPlots);
         var numPlotsUnlocked:int = numPlots / 2;
         if(this.m_featureName == FEATURE_NAME)
         {
            numPlotsUnlocked = numPlots / 4;
         }
         plotStates["0"] = new Object();
         plotStates["0"][PLOT_INDEX] = 5;
         plotStates["0"][TEND_INDEX] = 0;
         for(var i:int = 1; i < numPlots; i++)
         {
            plotStates[i.toString()] = new Object();
            plotStates[i.toString()][TEND_INDEX] = 0;
            if(i < numPlotsUnlocked)
            {
               plotStates[i.toString()][PLOT_INDEX] = 0;
            }
            else
            {
               plotStates[i.toString()][PLOT_INDEX] = -1;
            }
         }
         return plotStates;
      }
      
      public function plantSapling(plotId:String) : void
      {
         if(this.canPlant(plotId))
         {
            this.setSaplingLevelFor(plotId,LVL1_SAPLING);
            this.setSaplingTendStartFor(plotId,0);
            TransactionManager.addTransaction(new TGenericTransaction(this.m_serviceClass,this.ACTION_PLANT_SAPLING,null,[this.m_featureName,plotId]));
            FarmStatsManager.count(this.m_featureName,"Plant",plotId);
         }
      }
      
      public function setSaplingLevelFor(plotId:String, lvl:int) : void
      {
         var featureData:Object = this.getFeatureData();
         var plotStates:Object = featureData[OPTIONS_PLOT_KEY];
         if(Boolean(plotStates) && Boolean(plotStates[plotId]))
         {
            plotStates[plotId]["0"] = lvl;
         }
         featureData[OPTIONS_PLOT_KEY] = plotStates;
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName,featureData);
      }
      
      public function setSaplingTendStartFor(plotId:String, ts:int) : void
      {
         var featureData:Object = this.getFeatureData();
         var plotStates:Object = featureData[OPTIONS_PLOT_KEY];
         if(Boolean(plotStates) && Boolean(plotStates[plotId]))
         {
            plotStates[plotId]["1"] = ts;
         }
         featureData[OPTIONS_PLOT_KEY] = plotStates;
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName,featureData);
      }
      
      public function getPlotData() : Object
      {
         var result:Object = null;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName);
         if(featureData)
         {
            result = featureData[OPTIONS_PLOT_KEY];
         }
         return result;
      }
      
      public function getCollectionData() : Object
      {
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName);
         return featureData[OPTIONS_COLLECTED_KEY];
      }
      
      public function getBonusData() : Object
      {
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName);
         return featureData[OPTIONS_COLLECTED_BONUS];
      }
      
      public function getFeatureData() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName);
      }
      
      public function getSpeedUpCost() : int
      {
         var featureDataSet:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName);
         if(!featureDataSet)
         {
            return parseInt(this.m_staticData.speedUpCost);
         }
         return parseInt(this.m_staticData.speedUpCost) * this.noOfSaplingWaiting();
      }
      
      public function hasRewardbeenGranted(collection_no:int) : Boolean
      {
         var featureData:Object = this.getFeatureData();
         var bonusCode:Array = this.getBonusCodes();
         return featureData[OPTIONS_COLLECTED_BONUS][bonusCode[collection_no]] == 1;
      }
      
      public function GrantCollectionCompletionBonus(collection_no:int = -1) : void
      {
         var bonusData:Object = this.getBonusData();
         var featureData:Object = this.getFeatureData();
         var bonusCode:Array = this.getBonusCodes();
         if(collection_no != -1 && collection_no < bonusCode.length)
         {
            this.m_itemName = Global.farmGameSettingsManager.getFarmItemByCode(bonusCode[collection_no]);
            Global.player.addGift(this.m_itemName.name,"0",1);
            bonusData[bonusCode[collection_no]] = 1;
            featureData[OPTIONS_COLLECTED_BONUS][bonusCode[collection_no]] = 1;
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName,featureData);
            TransactionManager.addTransaction(new TGenericTransaction(this.m_serviceClass,"GrantCollectionCompletionBonus",null,[this.m_featureName,bonusCode[collection_no]]));
            FarmStatsManager.count(FEATURE_TRACKING,"grantBonus",this.m_itemName.friendlyTitle);
         }
      }
      
      public function getSaplingLevelFor(plotId:String) : int
      {
         var level:int = -1;
         var plotStates:Object = this.getPlotData();
         if(Boolean(plotStates) && Boolean(plotStates[plotId]) && plotStates[plotId]["0"] != null)
         {
            level = int(plotStates[plotId]["0"]);
            level = level >= this.getMaxLevel() ? int(this.getMaxLevel()) : level;
         }
         return level;
      }
      
      public function showCraftWindow() : void
      {
         var m_mystreeCraftWindow:MystreeReskinCraftWindow = new MystreeReskinCraftWindow(this.m_staticData.craftDialogAssetURL,this.m_featureName);
         UI.displayPopup(m_mystreeCraftWindow,true,"",true);
      }
      
      public function tendSapling(plotId:String, withTransaction:Boolean = true) : void
      {
         var currentTime:int = 0;
         var levelData:Dictionary = null;
         var bucketsNeeded:int = 0;
         var lvl:int = this.getSaplingLevelFor(plotId);
         if(this.canTend(plotId))
         {
            if(!this.hasSunshineBuckets(plotId))
            {
               this.showCraftWindow();
            }
            else
            {
               this.setSaplingLevelFor(plotId,lvl + 1);
               currentTime = GlobalEngine.serverTime / 1000;
               this.setSaplingTendStartFor(plotId,currentTime);
               levelData = this.getLevelData(lvl.toString());
               bucketsNeeded = levelData.hasOwnProperty("quantity") ? int(levelData["quantity"]) : 0;
               this.removeSunshineBuckets(bucketsNeeded);
               if(withTransaction)
               {
                  TransactionManager.addTransaction(new TGenericTransaction(this.m_serviceClass,this.ACTION_TEND_SAPLING,null,[this.m_featureName,plotId]));
                  FarmStatsManager.count(this.m_featureName,"Tend",plotId,(lvl + 1).toString());
               }
            }
         }
      }
      
      protected function removeSunshineBuckets(num:Number) : void
      {
         Global.player.removeGiftWithKey(this.m_staticData.bucketItem,num);
      }
      
      public function noOfSaplingWaiting() : int
      {
         var saplingLvl:int = 0;
         var noOfSaplingInWaitState:int = 0;
         var multiplier:int = 1;
         for(var i:int = 0; i < this.m_staticData.numPlots; i++)
         {
            saplingLvl = this.getSaplingLevelFor(i.toString());
            if(saplingLvl > PLOT_STATE_EMPTY && saplingLvl < this.getMaxLevel() && !this.canTend(i.toString()))
            {
               noOfSaplingInWaitState++;
            }
         }
         if(noOfSaplingInWaitState > 0)
         {
            return noOfSaplingInWaitState;
         }
         return multiplier;
      }
      
      public function speedUpSaplings() : void
      {
         var noOfSaplings:int = 0;
         var i:int = 0;
         if(this.canSpeedUp())
         {
            noOfSaplings = this.noOfSaplingWaiting();
            for(i = 0; i < this.m_staticData.numPlots; i++)
            {
               this.setSaplingTendStartFor(i.toString(),0);
            }
            Global.player.cash -= this.getSpeedupCost() * noOfSaplings;
            TransactionManager.addTransaction(new TGenericTransaction(this.m_serviceClass,this.ACTION_SPEEDUP_SAPLINGS,null,[this.m_featureName,noOfSaplings]));
         }
      }
      
      public function getSaplingTendStartFor(plotId:String) : int
      {
         var plotStates:Object = this.getPlotData();
         var ts:int = 0;
         if(Boolean(plotStates) && Boolean(plotStates[plotId]) && plotStates[plotId]["1"] != null)
         {
            ts = int(plotStates[plotId]["1"]);
         }
         return ts;
      }
      
      public function getTotalTendTimeFor(level:int) : int
      {
         var levelData:Dictionary = this.getLevelData(level.toString());
         return levelData.hasOwnProperty("waitTime") ? int(parseInt(levelData["waitTime"])) : 0;
      }
      
      public function canTend(plotId:String) : Boolean
      {
         var result:Boolean = false;
         var lvl:int = this.getSaplingLevelFor(plotId);
         var startTs:int = this.getSaplingTendStartFor(plotId);
         var tendTime:int = this.getTotalTendTimeFor(lvl);
         var currentTime:int = GlobalEngine.serverTime / 1000;
         if(lvl > PLOT_STATE_EMPTY && lvl < this.getMaxLevel() && startTs + tendTime <= currentTime)
         {
            result = true;
         }
         return result;
      }
      
      public function canPlant(plotId:String) : Boolean
      {
         var result:Boolean = false;
         if(this.getSaplingLevelFor(plotId) == PLOT_STATE_EMPTY)
         {
            result = true;
         }
         return result;
      }
      
      public function canSpeedUp(plotId:String = "") : Boolean
      {
         var result:Boolean = false;
         if(this.isAnySaplingWaiting() && Global.player.canBuyCash(this.getSpeedupCost() * this.noOfSaplingWaiting()))
         {
            result = true;
         }
         return result;
      }
      
      public function isAnySaplingWaiting() : Boolean
      {
         var saplingLvl:int = 0;
         var isWaiting:Boolean = false;
         for(var i:int = 0; i < this.m_staticData.numPlots; i++)
         {
            saplingLvl = this.getSaplingLevelFor(i.toString());
            if(saplingLvl > PLOT_STATE_EMPTY && saplingLvl < this.getMaxLevel() && !this.canTend(i.toString()))
            {
               isWaiting = true;
            }
         }
         return isWaiting;
      }
      
      public function setClaimedTreeFeatureOption(treeCode:String) : void
      {
         var featureData:Object = this.getFeatureData();
         var treecount:int = int(featureData[OPTIONS_COLLECTED_KEY][treeCode]);
         featureData[OPTIONS_COLLECTED_KEY][treeCode] = treecount + 1;
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName,featureData);
      }
      
      public function getNumberOfBuckets() : String
      {
         return CONST_BUCKET + this.getBucketCount();
      }
      
      public function showCraftingWindowWithItem() : void
      {
         var craftshopOpened:Boolean = false;
         var prompt:GenericXMLDialog = null;
         var craftShop:String = CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType);
         if(this.m_featureName == FEATURE_NAME)
         {
            CraftingManager.getInstance().openCraftshopWindow(CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType),"Costume Kit",null,"all");
         }
         else
         {
            craftshopOpened = false;
            if(CraftingManager.getInstance().showCraftingWindowForRecipe(this.m_staticData.recipeId))
            {
               craftshopOpened = true;
            }
            if(!craftshopOpened)
            {
               prompt = new GenericXMLDialog(null,null,null,Global.farmGameSettingsManager.getImageByName("craftingworkshop_finished","icon",false),100,100,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"SurfaceCraftShop_Message"),null,true,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"SurfaceCraftShop_Button"),function(event:Event):void
               {
                  Global.world.enterForcePlaceMode("craftingworkshop_finished",true,0,false,false,{"suppressGiftRepop":true});
               });
               UI.displayPopup(prompt,true,"",true);
            }
         }
      }
      
      public function getClaimedCount(itemCode:String) : int
      {
         var countText:String = "";
         var featureData:Object = this.getFeatureData();
         var mystrees:Object = featureData[OPTIONS_COLLECTED_KEY];
         return int(mystrees[itemCode]);
      }
      
      public function getMystree(plotId:String) : void
      {
         if(plotId != null && this.canGetMystree(plotId))
         {
            Global.world.addGameMode(new GMPlantMystreeReskin(this.m_staticData.finalSapling,plotId,this.m_featureName,false,0,true,Currency.COINS));
         }
      }
      
      public function onMystreePlaced(plotId:String) : void
      {
         if(plotId != null)
         {
            this.setSaplingLevelFor(plotId,0);
         }
      }
      
      public function canGetMystree(plotId:String) : Boolean
      {
         var result:Boolean = false;
         var lvl:int = this.getSaplingLevelFor(plotId);
         if(lvl == this.getMaxLevel())
         {
            result = true;
         }
         return result;
      }
      
      public function onBuyPlot(plotId:String) : Boolean
      {
         var cash:int = 0;
         var result:Boolean = false;
         if(plotId != null)
         {
            cash = this.getPlotUnlockCost();
            if(Global.player.canBuyCash(cash,true))
            {
               Global.player.cash -= cash;
               this.setSaplingLevelFor(plotId,0);
               TransactionManager.addTransaction(new TGenericTransaction(this.m_serviceClass,this.ACTION_BUY_PLOT,null,[this.m_featureName,plotId]));
               FarmStatsManager.count(this.m_featureName,"unlock_slot",plotId);
               result = true;
            }
         }
         return result;
      }
      
      public function buySunshineBuckets(buyPackage:String) : void
      {
         var sunshinePackage:FarmItem = null;
         if(buyPackage != null)
         {
            sunshinePackage = Global.farmGameSettingsManager.getFarmItemByName(buyPackage);
            Global.player.buyFarmItem(sunshinePackage,Currency.CASH,1);
         }
      }
      
      public function hasSunshineBuckets(plotId:String) : Boolean
      {
         var result:Boolean = false;
         var lvl:int = this.getSaplingLevelFor(plotId);
         var sbItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_staticData.bucketItem);
         var levelData:Dictionary = this.getLevelData(lvl.toString());
         var bucketsNeeded:int = levelData.hasOwnProperty("quantity") ? int(levelData["quantity"]) : 0;
         if(this.getBucketCount() >= bucketsNeeded)
         {
            result = true;
         }
         return result;
      }
      
      public function getUniqueMystreeCount() : int
      {
         var count:int = 0;
         var uniqueCount:int = 0;
         for(var i:int = 0; i < this.m_staticData.mystrees.length; i++)
         {
            count = this.getClaimedCount(this.m_staticData.mystrees[i]);
            if(count != 0)
            {
               uniqueCount++;
            }
         }
         return uniqueCount;
      }
      
      public function canPostFeed() : Boolean
      {
         return this.getTimeUntilPostFeedEnabled() <= 0 && this.m_isAskUnlocked;
      }
      
      public function isFeatureInActivePeriod() : Boolean
      {
         return FarmGameUtil.isFeatureInActivePeriod(this.endDate,REDEEM_ADDITIONAL_DAYS);
      }
      
      public function isFeatureInRedeemPeriod() : Boolean
      {
         return !this.isFeatureInActivePeriod() && FarmGameUtil.isFeatureInActivePeriod(this.endDate);
      }
      
      public function postGeneralFeed(callback:Function = null) : void
      {
         this.m_feedPostPending = true;
         this.m_isAskUnlocked = false;
         this.m_askCallback = callback;
         TransactionManager.addTransaction(new TGenericTransaction(this.m_serviceClass,ACTION_POST_FEED,this.onFeedPostComplete,[this.m_featureName]),true);
      }
      
      private function onFeedPostComplete(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("feedData"))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(result.feedData,this.handleFeedPostReturn);
         }
      }
      
      private function handleFeedPostReturn(success:Boolean) : void
      {
         if(success)
         {
            TransactionManager.addTransaction(new TSetFeatureFrequencyTimestamp(this.m_staticData.windowName + "AskBucket"),true);
            Global.player.setFeatureLastShown(this.m_staticData.windowName + "AskBucket",GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
            this.m_feedPostPending = false;
            this.m_isAskUnlocked = false;
            if(this.m_askCallback != null)
            {
               this.m_askCallback(true);
            }
         }
         else
         {
            this.m_isAskUnlocked = true;
            if(this.m_askCallback != null)
            {
               this.m_askCallback(false);
            }
         }
      }
      
      public function getTimeUntilPostFeedEnabled() : int
      {
         var throttleName:String = this.m_staticData.windowName + "AskBucket";
         var throttleTime:int = this.DEFAULT_THROTTLE_TIME;
         if(this.m_staticData.throttleTime)
         {
            throttleTime = int(this.m_staticData.throttleTime);
         }
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(throttleName);
         return int(throttleTime - timeSinceLastFeed);
      }
      
      public function handleHUDClick() : void
      {
         this.openMystreeUI();
      }
      
      public function openMystreeUI() : void
      {
         if(this.isFeatureInRedeemPeriod() && this.m_featureName == FEATURE_NAME)
         {
            UI.displayPopup(new MystreeReskinTreeColWindow(this.m_featureName));
         }
         else
         {
            UI.displayPopup(new MystreeReskinWindow(this.m_featureName));
         }
      }
      
      public function isFeatureAvailable() : Boolean
      {
         var limitedEndTimestamp:Number = NaN;
         var result:Boolean = true;
         if(this.getBuildingName() != "")
         {
            if(this.getEndDate() != "")
            {
               limitedEndTimestamp = FarmGameUtil.synchronizedDateTimeToNumber(this.getEndDate());
               if(limitedEndTimestamp < GlobalEngine.serverTime)
               {
                  result = false;
               }
            }
         }
         else
         {
            result = false;
         }
         return result;
      }
      
      protected function getBucketCount() : Number
      {
         var sbItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_staticData.bucketItem);
         return Global.player.getGiftCountForItem(sbItem.name);
      }
      
      public function isAdBtnShouldbeAvailable() : Boolean
      {
         return true;
      }
      
      public function getCollectionNumberDialogURL(collection_no:int = 0) : String
      {
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(this.m_featureName);
         if(featureXML)
         {
            switch(collection_no)
            {
               case 2:
                  return featureXML.UI.congratsDialog2.@path.toString();
               case 1:
                  return featureXML.UI.congratsDialog1.@path.toString();
               case 0:
            }
            return featureXML.UI.congratsDialog0.@path.toString();
         }
         return this.m_staticData.collectionDialog;
      }
   }
}

