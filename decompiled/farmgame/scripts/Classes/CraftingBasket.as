package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.*;
   import Engine.Managers.TransactionManager;
   import Managers.CraftingBasketDifficultyLevelManager;
   import Managers.FeatureOptionsManager;
   import Transactions.TGenericTransaction;
   import Transactions.TGenericTransactionWithFeed;
   import Widgets.Windows.CraftingBasket.CraftingBasketCongratsWindow;
   import Widgets.Windows.CraftingBasket.CraftingBasketWindow;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class CraftingBasket
   {
      
      public static const BUY_ITEM:String = "buyCollectionItem";
      
      public static const REDEEM_ITEM:String = "redeemCollectionItem";
      
      public static const ASK_FOR_CURRENCY:String = "askForCurrencyItem";
      
      public static const CRAFT_CURRENCY:String = "craftCurrency";
      
      public static const BUY_CURRENCY:String = "buyCurrencyItem";
      
      public static const SERVICE_NAME:String = "CraftingBasketService";
      
      public static const START_REWARD:int = 10;
      
      public static const CURRENCY_ITEM:String = "currencyItem";
      
      public static const REWARD_COLLECTION_ITEMS:String = "rewardCollectionItems";
      
      public static const REDEEM_COLLECTION_ITEMS:String = "redeemCollectionItems";
      
      public static const ALL_REWARDS_COLLECTED:String = "allRewardsCollected";
      
      public static const REDEEM_ADDITIONAL_DAYS:int = 2;
      
      private var m_basketName:String;
      
      private var m_basketParentName:String;
      
      private var m_isDifficultySet:Boolean;
      
      private var m_staticData:Object;
      
      private var m_parentStaticData:Object;
      
      private var m_currencyItemCount:int = -1;
      
      private var m_craftingBasketWindow:CraftingBasketWindow;
      
      public function CraftingBasket(featureName:String, isDifficultySet:Boolean = false, window:CraftingBasketWindow = null)
      {
         super();
         this.m_basketName = featureName;
         this.m_basketParentName = featureName;
         this.m_isDifficultySet = isDifficultySet;
         this.m_craftingBasketWindow = window;
         if(this.m_isDifficultySet)
         {
            this.m_basketName = featureName + "_" + Number(FeatureOptionsManager.getInstance().getFeatureOption(this.m_basketParentName,FeatureOptionsManager.DIFFICULTY_LEVEL));
         }
         this.loadStaticData();
         this.loadParentStaticData(featureName);
         this.initializeCurrencyCount();
         FeatureOptionsManager.getInstance().addEventListener(FeatureOptionsManager.EVENT_FEATURE_OPTIONS_UPDATED,this.updateStateFromServer);
      }
      
      private function loadStaticData() : void
      {
         var itemXML:XML = null;
         var recipeXML:XML = null;
         var itemInfo:Object = null;
         var recipeInfo:Object = null;
         this.m_staticData = new Object();
         this.m_staticData.collectionItems = new Array();
         this.m_staticData.recipeIds = new Array();
         this.m_staticData.currencyItemName = "";
         this.m_staticData.bonusItemName = "";
         this.m_staticData.bonusItemHidden = "";
         this.m_staticData.endDate = "";
         this.m_staticData.UIDialog = "";
         this.m_staticData.congratsDialog = "";
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(this.m_basketName);
         if(featureXML != null)
         {
            if(featureXML.parent != null)
            {
               this.m_basketParentName = featureXML.parent.@name;
            }
            this.m_staticData.currencyItemName = featureXML.currencyItem.@name.toString();
            this.m_staticData.bonusItemName = featureXML.bonusReward.@name.toString();
            if(Boolean(featureXML.bonusReward) && Boolean(featureXML.bonusReward.@isHidden))
            {
               this.m_staticData.bonusItemHidden = featureXML.bonusReward.@isHidden.toString();
            }
            this.m_staticData.endDate = featureXML.listEndDate.toString();
            this.m_staticData.UIDialog = featureXML.UI.dialog.@path.toString();
            this.m_staticData.congratsDialog = featureXML.UI.congratsDialog.@path.toString();
            this.m_staticData.askFeedFrequency = featureXML.feed.@throttleTime.toString();
            for each(itemXML in featureXML.rewardCollection.item)
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
            for each(recipeXML in featureXML.crafting.recipes.recipe)
            {
               recipeInfo = {};
               recipeInfo.id = String(recipeXML.@name);
               this.m_staticData.recipeIds.push(recipeInfo);
            }
         }
      }
      
      private function loadParentStaticData(featureName:String) : void
      {
         var bucketPackage:XML = null;
         var asset:XML = null;
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(featureName);
         this.m_parentStaticData = new Object();
         this.m_parentStaticData.bucketPackages = new Array();
         this.m_parentStaticData.buyDialog = "";
         if(featureXML.bucketPackages != null)
         {
            for each(bucketPackage in featureXML.bucketPackages.bucketPackage)
            {
               this.m_parentStaticData.bucketPackages.push(String(bucketPackage.@name));
            }
         }
         if(featureXML.assets != "")
         {
            for each(asset in featureXML.assets.asset)
            {
               if(asset.@name == "buyDialog")
               {
                  this.m_parentStaticData.buyDialog = asset.@path.toString();
               }
               if(asset.@name == "finalCratePrefix")
               {
                  this.m_parentStaticData.finalCratePrefix = asset.@path.toString();
               }
            }
         }
      }
      
      public function getFeatureData() : Object
      {
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.m_basketName,this.m_basketName);
         if(!data)
         {
            data = this.createFeatureData();
         }
         return data;
      }
      
      public function setFeatureDataFromParent(parentFeatureData:Object) : void
      {
         var item:Object = null;
         var data:Object = this.getFeatureData();
         for each(item in this.collectionItems)
         {
            if(parentFeatureData[REWARD_COLLECTION_ITEMS][item.name] >= 0)
            {
               data[REWARD_COLLECTION_ITEMS][item.name] = parentFeatureData[REWARD_COLLECTION_ITEMS][item.name];
               data[REDEEM_COLLECTION_ITEMS][item.name] = parentFeatureData[REDEEM_COLLECTION_ITEMS][item.name];
            }
         }
         if(parentFeatureData[CURRENCY_ITEM][this.currencyItemName] >= 0)
         {
            data[CURRENCY_ITEM][this.currencyItemName] = parentFeatureData[CURRENCY_ITEM][this.currencyItemName];
         }
         this.m_currencyItemCount = data[CURRENCY_ITEM][this.currencyItemName];
         this.setFeatureData(this.m_basketName,data);
      }
      
      public function getParentFeatureData() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(this.m_basketParentName,this.m_basketParentName);
      }
      
      public function setFeatureData(basketname:String, data:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(basketname,basketname,data);
      }
      
      public function createFeatureDataGeneric(basketName:String) : Object
      {
         var item:Object = null;
         var data:Object = new Object();
         data[REWARD_COLLECTION_ITEMS] = new Object();
         data[REDEEM_COLLECTION_ITEMS] = new Object();
         for each(item in this.collectionItems)
         {
            data[REWARD_COLLECTION_ITEMS][item.name] = 0;
            data[REDEEM_COLLECTION_ITEMS][item.name] = 0;
         }
         data[CURRENCY_ITEM] = new Object();
         data[CURRENCY_ITEM][this.currencyItemName] = START_REWARD;
         this.setFeatureData(basketName,data);
         return data;
      }
      
      public function createFeatureData() : Object
      {
         return this.createFeatureDataGeneric(this.m_basketName);
      }
      
      private function updateStateFromServer(e:Event) : void
      {
      }
      
      private function initializeCurrencyCount() : void
      {
         var featureData:Object = this.getFeatureData();
         this.m_currencyItemCount = featureData[CURRENCY_ITEM][this.currencyItemName];
      }
      
      public function get currencyItemCount() : int
      {
         var featureData:Object = null;
         if(this.m_currencyItemCount == -1)
         {
            featureData = this.getFeatureData();
            this.m_currencyItemCount = featureData[CURRENCY_ITEM][this.currencyItemName];
         }
         return this.m_currencyItemCount;
      }
      
      public function resetCurrencyItemCount() : void
      {
         this.m_currencyItemCount = -1;
      }
      
      public function get currencyItemName() : String
      {
         return this.m_staticData.currencyItemName;
      }
      
      public function isBonusItemHidden() : Boolean
      {
         return this.m_staticData.bonusItemHidden == "true";
      }
      
      public function get bonusItemName() : String
      {
         return this.m_staticData.bonusItemName;
      }
      
      public function get recipeIds() : Array
      {
         return this.m_staticData.recipeIds;
      }
      
      public function get collectionItems() : Array
      {
         return this.m_staticData.collectionItems;
      }
      
      public function get bucketPackages() : Array
      {
         return this.m_parentStaticData.bucketPackages;
      }
      
      public function get buyDialog() : String
      {
         return this.m_parentStaticData.buyDialog;
      }
      
      public function get endDate() : String
      {
         return this.m_staticData.endDate;
      }
      
      public function get askFeedFrequency() : int
      {
         return this.m_staticData.askFeedFrequency;
      }
      
      public function get parentFeatureName() : String
      {
         return this.m_basketParentName;
      }
      
      public function showMainWindow() : void
      {
         UI.displayPopup(new CraftingBasketWindow(this.m_staticData.UIDialog,this.m_basketName,this.m_basketParentName));
         CraftingBasketDifficultyLevelManager.loading = false;
      }
      
      public function askForCurrencyItem() : void
      {
         TransactionManager.addTransaction(new TGenericTransactionWithFeed(SERVICE_NAME,ASK_FOR_CURRENCY,this.onTransactionComplete,[this.m_basketParentName]));
      }
      
      public function shouldShowCheckMark(itemData:Object) : Boolean
      {
         var data:Object = null;
         var result:Boolean = false;
         var parentData:Object = null;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemData.name);
         if(this.m_isDifficultySet)
         {
            parentData = this.getParentFeatureData();
            if(parentData)
            {
               if(Boolean(parentData[REWARD_COLLECTION_ITEMS]) && parentData[REWARD_COLLECTION_ITEMS][item.name] > 0)
               {
                  return true;
               }
            }
         }
         data = this.getFeatureData();
         if(data)
         {
            if(Boolean(data[REWARD_COLLECTION_ITEMS]) && data[REWARD_COLLECTION_ITEMS][item.name] > 0)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function shouldShowCommonBg(itemData:Object) : Boolean
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemData.name);
         if(!this.m_isDifficultySet)
         {
            return false;
         }
         var parentData:Object = this.getParentFeatureData();
         if(parentData)
         {
            if(parentData[REWARD_COLLECTION_ITEMS][item.name] >= 0)
            {
               return true;
            }
         }
         return false;
      }
      
      public function shouldShowItemBuyButton(itemData:Object) : Boolean
      {
         var result:Boolean = false;
         var data:Object = this.getFeatureData();
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemData.name);
         if(data)
         {
            if(!this.isFeatureInActivePeriod() || Boolean(data[REDEEM_COLLECTION_ITEMS]) && Boolean(data[REDEEM_COLLECTION_ITEMS][item.name] >= 0))
            {
               result = true;
            }
         }
         return result;
      }
      
      public function redeemCollectionItem(itemName:String) : void
      {
         var item:Object = null;
         var exchangeCurrency:String = null;
         var exchangeQty:int = 0;
         var featureData:Object = null;
         var redeemItem:Object = null;
         for each(item in this.collectionItems)
         {
            if(item.name == itemName)
            {
               redeemItem = item;
            }
         }
         if(redeemItem != null)
         {
            exchangeCurrency = redeemItem.exchangeCurrency;
            exchangeQty = int(redeemItem.exchangeQty);
            featureData = this.getFeatureData();
            if(featureData[CURRENCY_ITEM][exchangeCurrency] >= exchangeQty)
            {
               featureData[CURRENCY_ITEM][exchangeCurrency] -= exchangeQty;
               ++featureData[REDEEM_COLLECTION_ITEMS][itemName];
               ++featureData[REWARD_COLLECTION_ITEMS][itemName];
               if(this.m_isDifficultySet)
               {
                  this.setParentRewardItemFeatureData(itemName);
                  this.setParentRedeemItemFeatureData(itemName,exchangeQty,exchangeCurrency);
               }
               this.setFeatureData(this.m_basketName,featureData);
               this.m_currencyItemCount = featureData[CURRENCY_ITEM][exchangeCurrency];
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,REDEEM_ITEM,this.onGrantItemSuccess,[this.m_basketName,itemName]));
            }
         }
      }
      
      public function buyCollectionItem(itemName:String) : void
      {
         var item:Object = null;
         var featureData:Object = null;
         var redeemItem:Object = null;
         for each(item in this.collectionItems)
         {
            if(item.name == itemName)
            {
               redeemItem = item;
            }
         }
         featureData = this.getFeatureData();
         ++featureData[REWARD_COLLECTION_ITEMS][itemName];
         ++featureData[REDEEM_COLLECTION_ITEMS][itemName];
         this.setFeatureData(this.m_basketName,featureData);
         if(this.m_isDifficultySet)
         {
            this.setParentRewardItemFeatureData(itemName);
            this.setParentRedeemItemFeatureData(itemName,redeemItem.exchangeQty,redeemItem.exchangeCurrency,false);
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,BUY_ITEM,this.onGrantItemSuccess,[this.m_basketName,itemName]));
      }
      
      public function buyCurrencyItem(packageItem:FarmItem, itemCount:int) : void
      {
         if(this.m_isDifficultySet)
         {
            this.incrementParentCurrencyItemFeatureData();
         }
         var data:Object = this.getFeatureData();
         data[CURRENCY_ITEM][this.currencyItemName] += itemCount;
         this.setFeatureData(this.m_basketName,data);
         this.m_currencyItemCount += itemCount;
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,BUY_CURRENCY,null,[this.m_basketName,packageItem.name]));
      }
      
      private function shouldShowRewardLevelCompletionDialog() : Boolean
      {
         var key:String = null;
         if(Global.player.getSeenFlag(this.m_basketName + "LevelComplete"))
         {
            return false;
         }
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.m_basketName,this.m_basketName);
         if(Boolean(data) && Boolean(data[REWARD_COLLECTION_ITEMS]))
         {
            for(key in data[REWARD_COLLECTION_ITEMS])
            {
               if(data[REWARD_COLLECTION_ITEMS][key] < 1)
               {
                  return false;
               }
            }
            return true;
         }
         return false;
      }
      
      private function onGrantItemSuccess(result:Object) : void
      {
         var bonus:String = null;
         var farmItem:FarmItem = null;
         var congratsDialog:CraftingBasketCongratsWindow = null;
         var levelCompletionDialog:CraftingBasketCongratsWindow = null;
         if(result.error == null)
         {
            Global.player.addGift(result.itemName);
            bonus = null;
            if(result.bonusItem != null)
            {
               Global.player.addGift(this.bonusItemName);
               bonus = this.bonusItemName;
               this.setCollectedBonusInParentFeature();
            }
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(result.itemName);
            congratsDialog = new CraftingBasketCongratsWindow(this.m_staticData.congratsDialog,this.m_basketParentName,farmItem,this.onShareReward,result,bonus);
            if(result.bonusItem)
            {
               levelCompletionDialog = new CraftingBasketCongratsWindow(this.m_parentStaticData.finalCratePrefix + FeatureOptionsManager.getInstance().getFeatureOption(this.m_basketParentName,FeatureOptionsManager.DIFFICULTY_LEVEL) + ".swf",this.m_basketName,null);
               Global.player.setSeenFlag(this.m_basketName + "LevelComplete");
               UI.displayPopup(levelCompletionDialog,false);
            }
            UI.displayPopup(congratsDialog,false);
            if(this.m_craftingBasketWindow)
            {
               this.m_craftingBasketWindow.enableWindow(true);
            }
         }
      }
      
      private function onShareReward(result:Object, window:FarmWindow) : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(result.feed.rewardName);
         var bundleData:Object = {
            "reward_link":result.feed.rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + result.feed.rewardLink,
               "src":item.iconUrl
            }],
            "rewardName":item.friendlyTitle,
            "item":Global.farmGameSettingsManager.getFarmItemByName(this.currencyItemName).friendlyTitle
         };
         var feedBundle:String = this.m_basketParentName + "ItemGrant";
         GlobalEngine.socialNetwork.publishFeedStory(feedBundle,bundleData,[],false);
         window.close();
      }
      
      private function onTransactionComplete(result:Object) : void
      {
         if(result.error == null)
         {
            if(this.m_craftingBasketWindow)
            {
               this.m_craftingBasketWindow.toggleCurrencyAskButton();
               this.m_craftingBasketWindow.enableWindow(true);
            }
         }
      }
      
      public function get askFeedFeatureFrequencyKey() : String
      {
         return this.m_basketParentName + "AskCurrency";
      }
      
      public function hasCollectedAllRewards() : Boolean
      {
         var item:Object = null;
         var result:Boolean = true;
         var data:Object = this.getFeatureData();
         for each(item in this.collectionItems)
         {
            if(data[REWARD_COLLECTION_ITEMS][item.name] == 0)
            {
               result = false;
               break;
            }
         }
         if(this.m_isDifficultySet && result == true)
         {
            this.setLevelCompleteInParentFeature(true);
         }
         if(this.m_isDifficultySet && !this.hasCollectedBonus())
         {
            result = false;
         }
         return result;
      }
      
      public function setLevelCompleteInParentFeature(status:Boolean = true) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(this.m_basketParentName,FeatureOptionsManager.LEVEL_COMPLETE,status);
      }
      
      public function isLevelComplete() : Boolean
      {
         var result:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.m_basketParentName,FeatureOptionsManager.LEVEL_COMPLETE);
         if(result)
         {
            return result;
         }
         return false;
      }
      
      public function hasCollectedBonus() : Boolean
      {
         var parentData:Object = this.getParentFeatureData();
         var result:Boolean = Boolean(parentData[ALL_REWARDS_COLLECTED]);
         if(result)
         {
            return result;
         }
         return false;
      }
      
      public function setCollectedBonusInParentFeature() : void
      {
         var parentData:Object = this.getParentFeatureData();
         if(parentData)
         {
            parentData[ALL_REWARDS_COLLECTED] = true;
         }
         this.setFeatureData(this.m_basketParentName,parentData);
      }
      
      private function setParentRewardItemFeatureData(itemName:String) : void
      {
         var featureParentData:Object = null;
         if(this.m_isDifficultySet)
         {
            featureParentData = this.getParentFeatureData();
            if(featureParentData[REWARD_COLLECTION_ITEMS][itemName] >= 0)
            {
               ++featureParentData[REWARD_COLLECTION_ITEMS][itemName];
               this.setFeatureData(this.m_basketParentName,featureParentData);
            }
         }
      }
      
      private function setParentRedeemItemFeatureData(itemName:String, exchangeQty:int, exchangeCurrency:String, isRedeemed:Boolean = true) : void
      {
         var featureParentData:Object = null;
         if(this.m_isDifficultySet)
         {
            featureParentData = this.getParentFeatureData();
            if(featureParentData[REDEEM_COLLECTION_ITEMS][itemName] >= 0)
            {
               ++featureParentData[REDEEM_COLLECTION_ITEMS][itemName];
            }
            if(isRedeemed)
            {
               featureParentData[CURRENCY_ITEM][exchangeCurrency] -= exchangeQty;
            }
            this.setFeatureData(this.m_basketParentName,featureParentData);
         }
      }
      
      private function incrementParentCurrencyItemFeatureData() : void
      {
         var featureParentData:Object = null;
         if(this.m_isDifficultySet)
         {
            featureParentData = this.getParentFeatureData();
            ++featureParentData[CURRENCY_ITEM][this.currencyItemName];
            this.setFeatureData(this.m_basketParentName,featureParentData);
         }
      }
      
      public function getRedeemPriceForItem(itemName:String) : int
      {
         var item:Object = null;
         var redeemItem:Object = null;
         for each(item in this.collectionItems)
         {
            if(item.name == itemName)
            {
               redeemItem = item;
               break;
            }
         }
         return redeemItem.exchangeQty;
      }
      
      public function isFeatureInActivePeriod() : Boolean
      {
         return FarmGameUtil.isFeatureInActivePeriod(this.m_staticData.endDate,REDEEM_ADDITIONAL_DAYS);
      }
   }
}

