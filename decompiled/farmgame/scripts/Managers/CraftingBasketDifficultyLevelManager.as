package Managers
{
   import Classes.*;
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.CraftingBasket.CraftingBasketDifficultyWindow;
   
   public class CraftingBasketDifficultyLevelManager implements IFeatureDifficultyLevels
   {
      
      private static const STATS_KINGDOM_WINDOW_NAME:String = "difficulty_screen";
      
      private static const STATS_PHYLUM_VIEW:String = "view";
      
      private static const STATS_KINGDOM_START:String = "level_start";
      
      private static const STATS_KINGDOM_COMPLETE:String = "level_complete";
      
      private static const STATS_CLASS_SWITCH:String = "switch";
      
      private static const STATS_CLASS_FIRST_TIME:String = "first_time";
      
      public static const REDEEM_ADDITIONAL_DAYS:int = 2;
      
      private static const STATS_CLASS_COMPLETE:String = "complete";
      
      public static const CHANGE_DIFFICULTY_LEVEL:String = "setDifficultyLevel";
      
      public static const SWITCH_DIFFICULTY:String = "switchDifficulty";
      
      public static const SERVICE_NAME:String = "CraftingBasketDifficultyService";
      
      public static const DEFAULT_RECOMM_LEVEL:int = 2;
      
      public static const START_REWARD:int = 10;
      
      public static const RECOMM_LEVEL_FEATURE_NAME:String = "EMH";
      
      public static const RECOMM_LEVEL_FEATURE_OPTION:String = "difficultyLevel";
      
      public static const CURRENCY_ITEM:String = "currencyItem";
      
      public static const REWARD_COLLECTION_ITEMS:String = "rewardCollectionItems";
      
      public static const REDEEM_COLLECTION_ITEMS:String = "redeemCollectionItems";
      
      public static const ALL_REWARDS_COLLECTED:String = "allRewardsCollected";
      
      private static const STATS_KINGDOM_DIFF_SELECT:String = "difficulty_select";
      
      public static var loading:Boolean = false;
      
      private var m_craftingBasketName:String;
      
      private var m_featureParentName:String;
      
      private var m_recommendedLevel:int;
      
      private var m_staticData:Object;
      
      public function CraftingBasketDifficultyLevelManager(featureParentName:String)
      {
         super();
         this.m_featureParentName = featureParentName;
         this.initializeDifficultylevel();
         this.loadStaticData();
      }
      
      private function loadStaticData() : void
      {
         var itemXML:XML = null;
         var asset:XML = null;
         var itemInfo:Object = null;
         this.m_staticData = new Object();
         this.m_staticData.collectionItems = new Array();
         this.m_staticData.UIDifficultyDialog = "";
         this.m_staticData.UIConfirmationDialog = "";
         this.m_staticData.endDate = "";
         this.m_staticData.currencyItemName = "";
         this.m_staticData.bonusItemName = "";
         this.m_staticData.SwitchMaxCount = "";
         this.m_staticData.difficultyLevels = "";
         this.m_staticData.bonusItemHidden = "";
         var featureparentXML:XML = Global.farmGameSettingsManager.getFeatureXML(this.m_featureParentName);
         if(featureparentXML != null)
         {
            this.m_staticData.endDate = featureparentXML.listEndDate.toString();
            if(featureparentXML.assets != "")
            {
               for each(asset in featureparentXML.assets.asset)
               {
                  if(asset.@name == "difficultyDialog")
                  {
                     this.m_staticData.UIDifficultyDialog = asset.@path.toString();
                  }
                  else if(asset.@name == "confirmationDialog")
                  {
                     this.m_staticData.UIConfirmationDialog = asset.@path.toString();
                  }
               }
            }
            this.m_staticData.difficultyLevels = Number(featureparentXML.difficulty.levels.@count);
            this.m_staticData.SwitchMaxCount = Number(featureparentXML.difficulty.maxSwitch.@count);
            this.m_staticData.currencyItemName = featureparentXML.currencyItem.@name.toString();
            this.m_staticData.bonusItemName = featureparentXML.bonusReward.@name.toString();
            if(Boolean(featureparentXML.bonusReward) && Boolean(featureparentXML.bonusReward.@isHidden))
            {
               this.m_staticData.bonusItemHidden = featureparentXML.bonusReward.@isHidden.toString();
            }
            this.m_staticData.endDate = featureparentXML.listEndDate.toString();
            for each(itemXML in featureparentXML.rewardCollection.item)
            {
               itemInfo = {};
               itemInfo.name = String(itemXML.@name);
               itemInfo.exchangeCurrency = String(itemXML.@exchangeCurrencyItem);
               itemInfo.exchangeQty = int(itemXML.@exchangeQty);
               if(itemXML.@common)
               {
                  itemInfo.isCommon = Boolean(itemXML.@common);
               }
               this.m_staticData.collectionItems.push(itemInfo);
            }
         }
      }
      
      private function initializeDifficultylevel() : void
      {
         this.initializeRecommendedDifficulty();
      }
      
      public function initializeRecommendedDifficulty() : void
      {
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(RECOMM_LEVEL_FEATURE_NAME,RECOMM_LEVEL_FEATURE_OPTION);
         if(data)
         {
            this.m_recommendedLevel = Number(data);
         }
         else
         {
            this.m_recommendedLevel = DEFAULT_RECOMM_LEVEL;
         }
      }
      
      public function showMainWindow() : void
      {
         if(loading)
         {
            return;
         }
         if(this.isDifficultyLevelSet() && this.getDifficultyLevel() != -1)
         {
            this.showCraftingMainWindow();
         }
         else
         {
            this.showDifficultyMainWindow();
         }
      }
      
      public function showDifficultyMainWindow() : void
      {
         StatsManager.count(this.m_featureParentName,STATS_KINGDOM_WINDOW_NAME,STATS_PHYLUM_VIEW,this.getStatsActionString(),this.m_recommendedLevel.toString());
         UI.displayPopup(new CraftingBasketDifficultyWindow(this.m_staticData.UIDifficultyDialog,this.m_featureParentName));
         loading = false;
      }
      
      public function showCraftingMainWindow() : void
      {
         var parentFeatureData:Object = this.getFeatureData();
         var craftingBasket:CraftingBasket = new CraftingBasket(this.m_featureParentName,true);
         craftingBasket.setFeatureDataFromParent(parentFeatureData);
         craftingBasket.showMainWindow();
      }
      
      private function setDifficultyLevel(difficultyLevel:int, isReplay:Boolean = false) : void
      {
         this.m_craftingBasketName = this.m_featureParentName + "_" + difficultyLevel;
         FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureParentName,FeatureOptionsManager.DIFFICULTY_LEVEL,difficultyLevel);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,CHANGE_DIFFICULTY_LEVEL,this.onLevelSet,[this.m_featureParentName,difficultyLevel]));
      }
      
      public function updateSwitchCountAndLastLevel(isReplay:Boolean = false) : void
      {
         loading = true;
         var count:int = this.getDifficultyLevelCount();
         count += 1;
         FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureParentName,FeatureOptionsManager.DIFFICULTY_LAST_LEVEL,this.getDifficultyLevel());
         FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureParentName,FeatureOptionsManager.DIFFICULTY_LEVEL,-1);
         if(!isReplay)
         {
            FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureParentName,FeatureOptionsManager.DIFFICULTY_LEVEL_SWITCH,count);
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,SWITCH_DIFFICULTY,this.onSwitchDifficultySuccess,[this.m_featureParentName]));
      }
      
      private function onSwitchDifficultySuccess(result:Object) : void
      {
         this.showDifficultyLevel();
      }
      
      public function isGameStarted() : Boolean
      {
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureParentName,FeatureOptionsManager.DIFFICULTY_LAST_LEVEL);
         if(data)
         {
            return true;
         }
         return false;
      }
      
      private function getStatsActionString() : String
      {
         var lastAction:String = null;
         if(this.getPreviousDifficultyLevel() == -1)
         {
            lastAction = STATS_CLASS_FIRST_TIME;
         }
         else if(this.hasCollectedBonus())
         {
            lastAction = STATS_KINGDOM_COMPLETE + "_" + this.getPreviousDifficultyLevel();
         }
         else
         {
            lastAction = STATS_CLASS_SWITCH;
         }
         return lastAction;
      }
      
      public function setDifficultyLevelAndCraftingWindow(difficultyLevel:int) : void
      {
         this.setDifficultyLevel(difficultyLevel);
         StatsManager.count(this.m_featureParentName,STATS_KINGDOM_DIFF_SELECT,difficultyLevel.toString(),this.getStatsActionString(),this.recommendedDifficultyLevel.toString());
      }
      
      public function onLevelSet(result:Object) : void
      {
         this.setLevelComplete(false);
         this.showCraftingMainWindow();
      }
      
      public function showDifficultyLevel() : void
      {
         this.showDifficultyMainWindow();
      }
      
      public function createParentBasketFeatureData() : Object
      {
         var item:Object = null;
         var data:Object = new Object();
         data[REWARD_COLLECTION_ITEMS] = new Object();
         data[REDEEM_COLLECTION_ITEMS] = new Object();
         data[CURRENCY_ITEM] = new Object();
         for each(item in this.collectionItems)
         {
            data[REWARD_COLLECTION_ITEMS][item.name] = 0;
            data[REDEEM_COLLECTION_ITEMS][item.name] = 0;
         }
         data[CURRENCY_ITEM][this.currencyItemName] = START_REWARD;
         this.setFeatureData(this.m_featureParentName,data);
         return data;
      }
      
      public function get currencyItemName() : String
      {
         return this.m_staticData.currencyItemName;
      }
      
      public function getFeatureData() : Object
      {
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureParentName,this.m_featureParentName);
         if(!data)
         {
            data = this.createParentBasketFeatureData();
         }
         return data;
      }
      
      public function setFeatureData(basketname:String, data:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(basketname,basketname,data);
      }
      
      public function getDifficultyLevel() : int
      {
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureParentName,FeatureOptionsManager.DIFFICULTY_LEVEL);
         if(data != null)
         {
            return Number(data);
         }
         return 999;
      }
      
      public function getCurrency() : int
      {
         var featureData:Object = this.getFeatureData();
         if(featureData != null)
         {
            return Number(featureData[CURRENCY_ITEM][this.currencyItemName]);
         }
         return -1;
      }
      
      public function getRewardQuantity(level:int) : String
      {
         var result:String = null;
         var featureName:String = this.m_featureParentName + "_level";
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(featureName,featureName);
         if(Boolean(data) && Boolean(data[REWARD_COLLECTION_ITEMS]))
         {
            result = data[REWARD_COLLECTION_ITEMS].length;
         }
         return result;
      }
      
      public function getDifficultyLevelCount() : int
      {
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureParentName,FeatureOptionsManager.DIFFICULTY_LEVEL_SWITCH);
         var switchCount:int = -1;
         if(data)
         {
            switchCount = int(data);
         }
         else
         {
            FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureParentName,FeatureOptionsManager.DIFFICULTY_LEVEL_SWITCH,0);
            switchCount = 0;
         }
         return switchCount;
      }
      
      public function isDifficultyLevelSet() : Boolean
      {
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureParentName,FeatureOptionsManager.DIFFICULTY_LEVEL);
         return data != null;
      }
      
      public function getPreviousDifficultyLevel() : int
      {
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureParentName,FeatureOptionsManager.DIFFICULTY_LAST_LEVEL);
         if(data != null)
         {
            return Number(data);
         }
         return -1;
      }
      
      public function canChangeDifficultyLevel() : Boolean
      {
         var count:int = 0;
         if(this.hasCollectedBonus())
         {
            return false;
         }
         if(this.isDifficultyLevelSet())
         {
            count = this.getDifficultyLevelCount();
            if(count >= this.m_staticData.SwitchMaxCount)
            {
               return false;
            }
         }
         return true;
      }
      
      public function get difficultyLevels() : int
      {
         return this.m_staticData.difficultyLevels;
      }
      
      public function get recommendedDifficultyLevel() : int
      {
         return this.m_recommendedLevel;
      }
      
      public function get confirmationDialog() : String
      {
         return this.m_staticData.UIConfirmationDialog;
      }
      
      public function get isLevelCompleted() : Boolean
      {
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureParentName,FeatureOptionsManager.LEVEL_COMPLETE);
         if(data)
         {
            return Boolean(data);
         }
         return false;
      }
      
      public function isRewardLevelComplete(level:int) : Boolean
      {
         var key:String = null;
         var result:Boolean = true;
         var feature:String = this.m_featureParentName + "_" + level;
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(feature,feature);
         if(Boolean(data) && Boolean(data[REWARD_COLLECTION_ITEMS]) && Boolean(data[REDEEM_COLLECTION_ITEMS]))
         {
            for(key in data[REWARD_COLLECTION_ITEMS])
            {
               if(data[REWARD_COLLECTION_ITEMS][key] + data[REDEEM_COLLECTION_ITEMS][key] < 1)
               {
                  result = false;
                  break;
               }
            }
         }
         else
         {
            result = false;
         }
         return result;
      }
      
      public function setLevelComplete(status:Boolean = true) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureParentName,FeatureOptionsManager.LEVEL_COMPLETE,status);
      }
      
      public function get collectionItems() : Array
      {
         return this.m_staticData.collectionItems;
      }
      
      public function get endDate() : String
      {
         return this.m_staticData.endDate;
      }
      
      public function isFeatureInActivePeriod() : Boolean
      {
         return FarmGameUtil.isFeatureInActivePeriod(this.endDate,REDEEM_ADDITIONAL_DAYS);
      }
      
      public function hasCollectedBonus() : Boolean
      {
         var parentData:Object = this.getFeatureData();
         var result:Boolean = Boolean(parentData[ALL_REWARDS_COLLECTED]);
         if(result)
         {
            return result;
         }
         return false;
      }
   }
}

