package Managers
{
   import Classes.WatchToEarnForMystreeManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.FarmGameUtil;
   import Display.*;
   import Engine.Managers.TransactionManager;
   import GameMode.GMPlantMystreeReskin;
   import Managers.Crafting.CraftingManager;
   import Transactions.TGenericTransaction;
   import Transactions.TSetFeatureFrequencyTimestamp;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.MystreeReskinCraftWindow;
   import Widgets.Windows.MystreeReskinTreeColWindowWithEMH;
   import Widgets.Windows.MystreeReskinWindowWithEMH;
   import flash.utils.Dictionary;
   
   public class MystreeReskinManagerWithEMH implements IMystreeReskinManager
   {
      
      public static const OPTIONS_PLOT_KEY:String = "0";
      
      public static const OPTIONS_COLLECTED_KEY:String = "1";
      
      public static const FEATURE_OPTIONS_KEY:String = "mystreereskin";
      
      public static const OPTION_STAGE_COMPLETE:String = "stageComplete";
      
      public static const OPTION_NUM_OF_BOUGHT_PLOTS:String = "numOfBoughtPlots";
      
      private static const WINDOW_LAND_NAME:String = "window1";
      
      private static const WINDOW_AIR_NAME:String = "window2";
      
      private static const WINDOW_WATER_NAME:String = "window3";
      
      private static const DAYS_INTERVAL:Number = 120;
      
      public static const TEND_SB_QUANTITY_SUFFIX:String = "_sb_quantity_";
      
      private static const ACTION_POST_FEED:String = "postFeed";
      
      private static const CONST_BUCKET:String = "x";
      
      public static const LVL1_SAPLING:int = 1;
      
      public static const LVL2_SAPLING:int = 2;
      
      public static const LVL3_SAPLING:int = 3;
      
      public static const LVL4_SAPLING:int = 4;
      
      public static const LVL5_SAPLING:int = 5;
      
      public static const LVL6_SAPLING:int = 6;
      
      public static const LVL_FINAL_MYSTREE:int = 6;
      
      public static const SPEEDUP_COST:int = 1;
      
      private static var m_initialized:Boolean = false;
      
      protected static var m_instance:Dictionary = new Dictionary();
      
      protected static const PLOT_INDEX:String = "0";
      
      protected static const TEND_INDEX:String = "1";
      
      private static const MYSTREE_V2_CHRISTMAS_FLAG:String = "ftue_christmas_mystree_v2";
      
      public static const REDEEM_ADDITIONAL_DAYS:int = 2;
      
      public static const PLOT_STATE_EMPTY:int = 0;
      
      public static const FEATURE_OPTION_LAST_SEEN_AD_TS:String = "last_seen_ad_ts";
      
      public static const FEATURE_OPTION_SEEN_ADS_COUNT:String = "seen_ad_count";
      
      public static const NON_PAYER_AD_LIMIT:int = 3;
      
      public static const PAYER_AD_LIMIT:int = 1;
      
      private const ACTION_PLANT_SAPLING:String = "plantSapling";
      
      protected const ACTION_TEND_SAPLING:String = "tendSapling";
      
      private const ACTION_INIT_FEATURE:String = "initFeature";
      
      protected const ACTION_SPEEDUP_SAPLINGS:String = "speedUpSaplings";
      
      protected const ACTION_SPEEDUP_SAMPLING_WITH_EMH:String = "speedUpSaplingsWithEMH";
      
      private const ACTION_BUY_PLOT:String = "buyPlot";
      
      private const ACTION_BUY_SUNSHINE_BUCKET:String = "buySunshineBucket";
      
      private var m_assetPaths:Object = {};
      
      private const DEFAULT_THROTTLE_TIME:int = 21600;
      
      private var m_feedPostPending:Boolean;
      
      private var m_askCallback:Function;
      
      private var m_motdData:Object = null;
      
      private var m_sentForMOTDData:Boolean = false;
      
      private var m_isAskUnlocked:Boolean = true;
      
      protected var m_serviceClass:String;
      
      private const SERVICE_CLASS:String = "MystreeReskinService";
      
      private var m_hasEndDate:Boolean = false;
      
      private const OPTION_FEATURE_PROGREESED:String = "userProgressed";
      
      private const MAX_DIFFICULTY_LEVELS:int = 3;
      
      public const NUM_UNLOCKED_PLOT_IN_SMALL_LEVEL:int = 3;
      
      public const NUM_UNLOCKED_PLOT_IN_MEDIUM_LEVEL:int = 3;
      
      public const NUM_UNLOCKED_PLOT_IN_BIG_LEVEL:int = 3;
      
      public const NUM_PLOTS_IN_EACH_LEVEL:int = 8;
      
      protected var m_staticData:Object;
      
      protected var m_featureName:String;
      
      private var m_updatesWindowAfterAds:Function;
      
      public var m_mystreeWatchToEarnManager:WatchToEarnForMystreeManager;
      
      public function MystreeReskinManagerWithEMH(featureName:String, serviceClass:String = "MystreeReskinService")
      {
         super();
         this.m_featureName = featureName;
         this.m_serviceClass = serviceClass;
         this.loadStaticData();
         m_initialized = true;
      }
      
      public static function getInstance(featureName:String) : MystreeReskinManagerWithEMH
      {
         if(!m_instance)
         {
            m_instance = new Dictionary();
         }
         if(!m_instance.hasOwnProperty(featureName))
         {
            m_instance[featureName] = new MystreeReskinManagerWithEMH(featureName);
         }
         return m_instance[featureName] as MystreeReskinManagerWithEMH;
      }
      
      private function loadStaticData() : void
      {
         var difficultyLevel:int = 0;
         var itemXML:XML = null;
         var maxLevel:Number = NaN;
         var levelXML:XML = null;
         var asset:XML = null;
         var levelNum:String = null;
         var levelData:Dictionary = null;
         this.m_staticData = new Object();
         this.m_staticData.congratsDialog = "";
         this.m_staticData.bucketItem = "";
         this.m_staticData.recipeId = "";
         this.m_staticData.initialGrant = 0;
         this.m_staticData.speedUpCost = 0;
         this.m_staticData.mystrees = new Array();
         this.m_staticData.bucketPackages = new Array();
         this.m_staticData.levelInfo = new Dictionary();
         this.m_staticData.mainDialogAssetURL = "";
         this.m_staticData.ftueFlag = "";
         this.m_staticData.numPlots = "24";
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
            if(featureXML.hasOwnProperty("assets"))
            {
               for each(asset in featureXML.assets.asset)
               {
                  this.m_assetPaths[asset.@name] = asset.@path.toString();
               }
            }
            difficultyLevel = this.getDifficultyLevel();
            switch(difficultyLevel)
            {
               case 0:
                  for each(itemXML in featureXML.difficulty0.mystrees.mystree)
                  {
                     this.m_staticData.mystrees.push(itemXML.@code.toString());
                  }
                  break;
               case 1:
                  for each(itemXML in featureXML.difficulty1.mystrees.mystree)
                  {
                     this.m_staticData.mystrees.push(itemXML.@code.toString());
                  }
                  break;
               case 2:
               default:
                  for each(itemXML in featureXML.difficulty2.mystrees.mystree)
                  {
                     this.m_staticData.mystrees.push(itemXML.@code.toString());
                  }
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
         }
      }
      
      public function reloadStaicData(isFirsttimeConfig:Boolean, isReplay:Boolean = false) : void
      {
         var difficultyLevel:int = 0;
         var itemXML:XML = null;
         var collectionData:Object = null;
         var i:int = 0;
         var treeCode:String = null;
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(this.m_featureName);
         this.m_staticData.mystrees = new Array();
         if(featureXML != null)
         {
            difficultyLevel = this.getDifficultyLevel();
            switch(difficultyLevel)
            {
               case 2:
                  for each(itemXML in featureXML.difficulty2.mystrees.mystree)
                  {
                     this.m_staticData.mystrees.push(itemXML.@code.toString());
                  }
                  break;
               case 1:
                  for each(itemXML in featureXML.difficulty1.mystrees.mystree)
                  {
                     this.m_staticData.mystrees.push(itemXML.@code.toString());
                  }
                  break;
               case 0:
               default:
                  for each(itemXML in featureXML.difficulty0.mystrees.mystree)
                  {
                     this.m_staticData.mystrees.push(itemXML.@code.toString());
                  }
            }
         }
         var featureDataSet:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName);
         if(featureDataSet)
         {
            featureDataSet[OPTIONS_PLOT_KEY] = this.initPlotData(isFirsttimeConfig,isReplay);
            if(featureDataSet.hasOwnProperty(OPTIONS_COLLECTED_KEY))
            {
               collectionData = featureDataSet[OPTIONS_COLLECTED_KEY];
            }
            else
            {
               collectionData = new Object();
            }
            if(isReplay)
            {
               collectionData = new Object();
            }
            for(i = 0; i < this.m_staticData.mystrees.length; i++)
            {
               treeCode = this.m_staticData.mystrees[i];
               if(!collectionData.hasOwnProperty(treeCode))
               {
                  collectionData[treeCode] = 0;
               }
            }
            featureDataSet[OPTIONS_COLLECTED_KEY] = collectionData;
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName,featureDataSet);
            FarmStatsManager.count(this.m_featureName,"level_start",this.getDifficultyLevel().toString(),"",MystreeReskinDifficultyLevelsManager.getInstance(this.m_featureName).recommendedDifficultyLevel.toString());
         }
      }
      
      public function getBuildingName() : String
      {
         return this.m_staticData.buildingName;
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
      
      public function getSpeedUpCost() : int
      {
         var featureDataSet:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName);
         if(!featureDataSet)
         {
            return parseInt(this.m_staticData.speedUpCost);
         }
         return parseInt(this.m_staticData.speedUpCost) * this.noOfSaplingWaiting();
      }
      
      public function getNoOfAnimals() : int
      {
         var featureDataSet:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName);
         if(!featureDataSet)
         {
            return 1;
         }
         return this.noOfSaplingWaiting();
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
         var difficulty:int = this.getDifficultyLevel();
         if(difficulty == 0)
         {
            return this.m_assetPaths[WINDOW_LAND_NAME];
         }
         if(difficulty == 1)
         {
            return this.m_assetPaths[WINDOW_AIR_NAME];
         }
         if(difficulty == 2)
         {
            return this.m_assetPaths[WINDOW_WATER_NAME];
         }
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
      
      public function getEndDate() : String
      {
         return this.m_staticData.endDate;
      }
      
      public function getCollectionDialogURL() : String
      {
         var difficultyLevel:int = this.getDifficultyLevel();
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(this.m_featureName);
         if(featureXML)
         {
            switch(difficultyLevel)
            {
               case 2:
                  this.m_staticData.collectionDialog = featureXML.UI.congratsDialog2.@path.toString();
                  break;
               case 1:
                  this.m_staticData.collectionDialog = featureXML.UI.congratsDialog1.@path.toString();
                  break;
               case 0:
               default:
                  this.m_staticData.collectionDialog = featureXML.UI.congratsDialog0.@path.toString();
            }
         }
         return this.m_staticData.collectionDialog;
      }
      
      public function getMaxLevel() : Number
      {
         return this.m_staticData.maxLevel;
      }
      
      public function initFeature() : void
      {
         var featureData:Object = null;
         var initialGrant:int = 0;
         var collectionData:Dictionary = null;
         var i:int = 0;
         var treeCode:String = null;
         var featureDataSet:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName);
         if(!featureDataSet)
         {
            featureData = new Object();
         }
         else
         {
            featureData = featureDataSet;
         }
         var sbItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_staticData.bucketItem);
         if(sbItem)
         {
            initialGrant = parseInt(this.m_staticData.initialGrant);
            this.addSunshineBuckets(initialGrant);
         }
         TransactionManager.addTransaction(new TGenericTransaction(this.m_serviceClass,this.ACTION_INIT_FEATURE,null,[this.m_featureName]));
         if(!featureData.hasOwnProperty(OPTIONS_COLLECTED_KEY))
         {
            featureData[OPTIONS_PLOT_KEY] = this.initPlotData();
            collectionData = new Dictionary();
            for(i = 0; i < this.m_staticData.mystrees.length; i++)
            {
               treeCode = this.m_staticData.mystrees[i];
               collectionData[treeCode] = 0;
            }
            featureData[OPTIONS_COLLECTED_KEY] = collectionData;
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName,featureData);
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
      
      protected function initPlotData(firstTimeConfig:Boolean = true, isReplay:Boolean = false) : Dictionary
      {
         var i:int = 0;
         var j:int = 0;
         var k:int = 0;
         var FeatureDataSet:Object = null;
         var plotData:Object = null;
         var plotStates:Dictionary = new Dictionary();
         var numPlots:int = parseInt(this.m_staticData.numPlots);
         plotStates["0"] = new Object();
         if(firstTimeConfig || isReplay)
         {
            plotStates["0"][PLOT_INDEX] = 4;
         }
         else
         {
            plotStates["0"][PLOT_INDEX] = 0;
         }
         var unlockedPlots:int = 0;
         var difficulty:int = this.getDifficultyLevel();
         switch(difficulty)
         {
            case 0:
               unlockedPlots = this.NUM_UNLOCKED_PLOT_IN_SMALL_LEVEL;
               break;
            case 1:
               unlockedPlots = this.NUM_UNLOCKED_PLOT_IN_MEDIUM_LEVEL;
               break;
            case 2:
            default:
               unlockedPlots = this.NUM_UNLOCKED_PLOT_IN_BIG_LEVEL;
         }
         if(firstTimeConfig == false && isReplay == false)
         {
            unlockedPlots += this.getNumOfBoughtPlots();
         }
         if(firstTimeConfig == true)
         {
            plotStates["0"][TEND_INDEX] = 0;
            for(i = 1; i < numPlots; i++)
            {
               plotStates[i.toString()] = new Object();
               plotStates[i.toString()][TEND_INDEX] = 0;
               if(i < unlockedPlots)
               {
                  plotStates[i.toString()][PLOT_INDEX] = 0;
               }
               else
               {
                  plotStates[i.toString()][PLOT_INDEX] = -1;
               }
            }
            for(i = 0; i < this.NUM_UNLOCKED_PLOT_IN_SMALL_LEVEL; i++)
            {
               for(j = 0; j < this.NUM_UNLOCKED_PLOT_IN_SMALL_LEVEL; j++)
               {
                  k = j + this.NUM_PLOTS_IN_EACH_LEVEL * i;
                  if(plotStates[k.toString()][PLOT_INDEX] == -1)
                  {
                     plotStates[k.toString()][PLOT_INDEX] = 0;
                  }
               }
            }
            return plotStates;
         }
         FeatureDataSet = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName);
         plotData = FeatureDataSet[PLOT_INDEX];
         for(i = 0; i < numPlots; i++)
         {
            plotStates[i.toString()] = new Object();
            plotStates[i.toString()][PLOT_INDEX] = plotData[i.toString()][PLOT_INDEX];
            plotStates[i.toString()][TEND_INDEX] = plotData[i.toString()][TEND_INDEX];
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
            FarmStatsManager.count(this.m_featureName,"Plant",plotId,"",MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getDifficultyLevel().toString());
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
      
      public function getFeatureData() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName);
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
                  FarmStatsManager.count(this.m_featureName,"Tend",plotId,(lvl + 1).toString(),MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getDifficultyLevel().toString());
               }
            }
         }
      }
      
      protected function removeSunshineBuckets(num:Number) : void
      {
         Global.player.removeGiftWithKey(this.m_staticData.bucketItem,num);
      }
      
      public function speedUpSaplings(noOfSapling:int) : void
      {
         var i:int = 0;
         var noOfSamplings:int = 0;
         if(this.canSpeedUp())
         {
            for(i = 0; i < this.m_staticData.numPlots; i++)
            {
               this.setSaplingTendStartFor(i.toString(),0);
            }
            noOfSamplings = noOfSapling;
            Global.player.cash -= SPEEDUP_COST * noOfSamplings;
            TransactionManager.addTransaction(new TGenericTransaction(this.m_serviceClass,this.ACTION_SPEEDUP_SAMPLING_WITH_EMH,null,[this.m_featureName,noOfSamplings]));
         }
      }
      
      public function speedUpSaplingsByWatchingAd(callback:Function) : void
      {
         FarmStatsManager.count(WatchToEarnForMystreeManager.STAT_COUNTER,WatchToEarnForMystreeManager.W2E_MYSTREE_SLOT,WatchToEarnForMystreeManager.STAT_CLICK);
         if(this.canUserSeeAd())
         {
            FarmStatsManager.count(this.m_featureName,"watch_ad_to_skip_clicked",MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getDifficultyLevel().toString());
            this.m_updatesWindowAfterAds = callback;
            Global.watchToEarn.startActivity(WatchToEarnForMystreeManager.W2E_MYSTREE_SLOT);
         }
      }
      
      private function canUserSeeAd() : Boolean
      {
         return false;
      }
      
      public function updateSaplingTend() : void
      {
         for(var i:int = 0; i < this.m_staticData.numPlots; i++)
         {
            this.setSaplingTendStartFor(i.toString(),0);
         }
         this.m_updatesWindowAfterAds();
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
         if(this.isAnySaplingWaiting() && Global.player.cash >= SPEEDUP_COST * this.noOfSaplingWaiting())
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
      
      public function isAdBtnShouldbeAvailable() : Boolean
      {
         var count:Number = NaN;
         var isAvailable:Boolean = false;
         if(!this.canUserSeeAd())
         {
            return isAvailable;
         }
         var payer:Boolean = this.is120dayActivePayer();
         if(!FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureName,FEATURE_OPTION_LAST_SEEN_AD_TS))
         {
            return true;
         }
         var ts:Number = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureName,FEATURE_OPTION_LAST_SEEN_AD_TS) as Number;
         var time:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(time < ts + FarmGameUtil.NUM_SECS_IN_DAY)
         {
            count = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureName,FEATURE_OPTION_SEEN_ADS_COUNT) as Number;
            if(payer)
            {
               if(!count)
               {
                  isAvailable = true;
               }
            }
            else if(Global.flashHotParams["NON_PAYER_AD_LIMIT"])
            {
               if(count < Global.flashHotParams["NON_PAYER_AD_LIMIT"])
               {
                  isAvailable = true;
               }
            }
            else if(count < NON_PAYER_AD_LIMIT)
            {
               isAvailable = true;
            }
         }
         else
         {
            FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,FEATURE_OPTION_LAST_SEEN_AD_TS,time);
            FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,FEATURE_OPTION_SEEN_ADS_COUNT,0);
            isAvailable = true;
         }
         return isAvailable;
      }
      
      public function setCountAndTimeStamp() : void
      {
         var count:Number = NaN;
         var time:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(!FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureName,FEATURE_OPTION_LAST_SEEN_AD_TS))
         {
            FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,FEATURE_OPTION_LAST_SEEN_AD_TS,time);
         }
         if(!FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureName,FEATURE_OPTION_SEEN_ADS_COUNT))
         {
            FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,FEATURE_OPTION_SEEN_ADS_COUNT,1);
         }
         else
         {
            count = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureName,FEATURE_OPTION_SEEN_ADS_COUNT) as Number;
            FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,FEATURE_OPTION_SEEN_ADS_COUNT,count + 1);
         }
      }
      
      public function noOfSaplingWaiting() : int
      {
         var saplingLvl:int = 0;
         var saplingLv2:int = 0;
         var saplingLv3:int = 0;
         var noOfSaplingInWaitState:int = 0;
         var multiplier:int = 1;
         var difficulty:int = this.getDifficultyLevel();
         for(var i:int = 0; i < this.m_staticData.numPlots; i++)
         {
            switch(difficulty)
            {
               case 0:
                  if(i >= 0 && i < this.NUM_PLOTS_IN_EACH_LEVEL)
                  {
                     saplingLvl = this.getSaplingLevelFor(i.toString());
                     if(saplingLvl > PLOT_STATE_EMPTY && saplingLvl < this.getMaxLevel() && !this.canTend(i.toString()))
                     {
                        noOfSaplingInWaitState++;
                     }
                  }
                  break;
               case 1:
                  if(i >= this.NUM_PLOTS_IN_EACH_LEVEL && i < 2 * this.NUM_PLOTS_IN_EACH_LEVEL)
                  {
                     saplingLv2 = this.getSaplingLevelFor(i.toString());
                     if(saplingLv2 > PLOT_STATE_EMPTY && saplingLv2 < this.getMaxLevel() && !this.canTend(i.toString()))
                     {
                        noOfSaplingInWaitState++;
                     }
                  }
                  break;
               case 2:
                  if(i >= 2 * this.NUM_PLOTS_IN_EACH_LEVEL && i < 3 * this.NUM_PLOTS_IN_EACH_LEVEL)
                  {
                     saplingLv3 = this.getSaplingLevelFor(i.toString());
                     if(saplingLv3 > PLOT_STATE_EMPTY && saplingLv3 < this.getMaxLevel() && !this.canTend(i.toString()))
                     {
                        noOfSaplingInWaitState++;
                     }
                  }
            }
         }
         if(noOfSaplingInWaitState)
         {
            return noOfSaplingInWaitState;
         }
         return multiplier;
      }
      
      public function setClaimedTreeFeatureOption(treeCode:String) : void
      {
         var featureData:Object = this.getFeatureData();
         var treecount:int = int(featureData[OPTIONS_COLLECTED_KEY][treeCode]);
         featureData[OPTIONS_COLLECTED_KEY][treeCode] = treecount + 1;
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName,featureData);
         if(this.isStageComplete())
         {
            this.markThisStageAsCompleted();
         }
      }
      
      public function getNumberOfBuckets() : String
      {
         return CONST_BUCKET + this.getBucketCount();
      }
      
      public function showCraftingWindowWithItem() : void
      {
         var craftShop:String = CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType);
         CraftingManager.getInstance().openCraftshopWindow(CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType),"Map Fragments",null,"all");
         var craftshopOpened:Boolean = false;
      }
      
      public function getClaimedCount(itemCode:String) : int
      {
         var mystrees:Object = null;
         var count:int = 0;
         var featureData:Object = this.getFeatureData();
         if(featureData)
         {
            mystrees = featureData[OPTIONS_COLLECTED_KEY];
            count = int(mystrees[itemCode]);
         }
         return count;
      }
      
      public function getMystree(plotId:String) : void
      {
         var difficulty:int = this.getDifficultyLevel() + 1;
         var finalSap:String = this.m_staticData.finalSapling + String(difficulty);
         if(plotId != null && this.canGetMystree(plotId))
         {
            Global.world.addGameMode(new GMPlantMystreeReskin(finalSap,plotId,this.m_featureName,false,0,true,Currency.COINS));
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
         var featureData:Object = null;
         var result:Boolean = false;
         if(plotId != null)
         {
            cash = this.getPlotUnlockCost();
            if(Global.player.canBuyCash(cash,true))
            {
               Global.player.cash -= cash;
               this.setSaplingLevelFor(plotId,0);
               TransactionManager.addTransaction(new TGenericTransaction(this.m_serviceClass,this.ACTION_BUY_PLOT,null,[this.m_featureName,plotId]));
               featureData = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName);
               if(featureData)
               {
                  if(featureData.hasOwnProperty(OPTION_NUM_OF_BOUGHT_PLOTS))
                  {
                     featureData[OPTION_NUM_OF_BOUGHT_PLOTS] += 1;
                  }
                  else
                  {
                     featureData[OPTION_NUM_OF_BOUGHT_PLOTS] = 1;
                  }
                  FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName,featureData);
               }
               FarmStatsManager.count(this.m_featureName,"unlock_slot",plotId,MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getDifficultyLevel().toString());
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
            FarmStatsManager.count("fv_cash_buy",this.m_featureName,buyPackage,sunshinePackage.cash.toString(),this.getDifficultyLevel().toString());
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
         MystreeReskinDifficultyLevelsManager.getInstance(this.m_featureName).showMainWindow();
      }
      
      public function openMystreeUI() : void
      {
         UI.displayPopup(new MystreeReskinWindowWithEMH(this.m_featureName));
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
      
      public function getDifficultyLevel() : int
      {
         return MystreeReskinDifficultyLevelsManager.getInstance(this.m_featureName).getCurrentDifficultyLevel();
      }
      
      public function canSwitchDifficultyLevel() : Boolean
      {
         return MystreeReskinDifficultyLevelsManager.getInstance(this.m_featureName).canSwitchDifficultyLevel() && this.isFeatureInActivePeriod();
      }
      
      public function isStageComplete() : Boolean
      {
         var stageComplete:Boolean = false;
         if(this.getUniqueMystreeCount() == this.m_staticData.mystrees.length)
         {
            stageComplete = true;
         }
         return stageComplete;
      }
      
      public function markThisStageAsCompleted() : void
      {
         var difficultyFeatureOption:String = null;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName);
         if(featureData)
         {
            difficultyFeatureOption = OPTION_STAGE_COMPLETE + this.getDifficultyLevel();
            if(!featureData.hasOwnProperty(difficultyFeatureOption))
            {
               featureData[difficultyFeatureOption] = 1;
               FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName,featureData);
               FarmStatsManager.count(this.m_featureName,"level_complete",this.getDifficultyLevel().toString(),"",MystreeReskinDifficultyLevelsManager.getInstance(this.m_featureName).recommendedDifficultyLevel.toString());
               MystreeReskinManagerWithEMH.getInstance(this.m_featureName).openTreeCollection();
            }
         }
      }
      
      public function openTreeCollection() : void
      {
         if(MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getCollectionDialogURL() != "")
         {
            UI.displayPopup(new MystreeReskinTreeColWindowWithEMH(this.m_featureName,true));
         }
         FarmStatsManager.count(this.m_featureName,"Congrats","view");
      }
      
      public function hasStageCompleted(difficultyLevel:int) : Boolean
      {
         var hasCompleted:Boolean = false;
         var difficultyFeatureOption:String = OPTION_STAGE_COMPLETE + difficultyLevel.toString();
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName);
         if(Boolean(featureData) && Boolean(featureData.hasOwnProperty(difficultyFeatureOption)) && featureData[difficultyFeatureOption] as int == 1)
         {
            hasCompleted = true;
         }
         return hasCompleted;
      }
      
      public function isAnyStageCompleted() : Boolean
      {
         var i:int = 0;
         var isanyStageCompleted:Boolean = false;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName);
         if(featureData)
         {
            for(i = 0; i < this.MAX_DIFFICULTY_LEVELS; i++)
            {
               if(featureData.hasOwnProperty(OPTION_STAGE_COMPLETE + i.toString()) && featureData[OPTION_STAGE_COMPLETE + i.toString()] as int == 1)
               {
                  isanyStageCompleted = true;
               }
            }
         }
         return isanyStageCompleted;
      }
      
      public function get endDate() : String
      {
         return this.m_staticData.endDate;
      }
      
      public function isFeatureInActivePeriod() : Boolean
      {
         return FarmGameUtil.isFeatureInActivePeriod(this.endDate,REDEEM_ADDITIONAL_DAYS);
      }
      
      public function getNumOfBoughtPlots() : int
      {
         var numOfBoughtPlots:int = 0;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName);
         if(Boolean(featureData) && featureData.hasOwnProperty(OPTION_NUM_OF_BOUGHT_PLOTS))
         {
            numOfBoughtPlots = int(featureData[OPTION_NUM_OF_BOUGHT_PLOTS]);
         }
         return numOfBoughtPlots;
      }
      
      public function hasProgressMade() : Boolean
      {
         var numPlots:int = 0;
         var plotStates:Object = null;
         var i:int = 0;
         var progressMade:Boolean = false;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,this.m_featureName);
         if(featureData)
         {
            numPlots = parseInt(this.m_staticData.numPlots);
            plotStates = featureData[OPTIONS_PLOT_KEY];
            for(i = 0; i < numPlots; i++)
            {
               if(plotStates[i.toString()][PLOT_INDEX] > 0)
               {
                  progressMade = true;
               }
            }
         }
         return progressMade;
      }
      
      public function is120dayActivePayer() : Boolean
      {
         var isPayer:Boolean = false;
         var acceptDate:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - 86400 * DAYS_INTERVAL;
         var noOfTranscations:Array = Global.player.getCashTransactionsFromDate(acceptDate);
         if(noOfTranscations.length > 0)
         {
            isPayer = true;
         }
         return isPayer;
      }
   }
}

