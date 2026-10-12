package Managers
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Transactions.TGenericTransactionWithFeed;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.BonusSelectionWindow;
   import Widgets.Windows.ChoiceDrivenFeatureWindow;
   import Widgets.Windows.ChooseContenderWindow;
   import Widgets.Windows.EnableSpecificMovieClipRewardWindow;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FeaturePackagesBuyWindow;
   
   public class ChoiceDrivenManager extends BaseFeatureManager
   {
      
      public static const STAUS_IDLE:String = "idle";
      
      public static const STAUS_CURRENT:String = "curr";
      
      public static const STAUS_DEFEATED:String = "def";
      
      public static const CONTENDER_STATUS:String = "c_sta";
      
      public static const CONTENDER_ACTIVE:String = "c_act";
      
      public static const CURRENCY_SPENT_PINK:String = "sp_p";
      
      public static const CURRENCY_SPENT_WHITE:String = "sp_w";
      
      public static const BONUS_COLLECTION:String = "c_bon";
      
      public static const HARVEST_CURRENCY_INCREMENT_AMT:int = 1;
      
      public static const REWARD_COLLECTION:String = "c_rewards";
      
      public static const KEY_EXPIRED:String = "expired";
      
      public static const BRAG_FEED_TYPE:String = "R4EpicBattle_Brag";
      
      public static const SERVICE_NAME:String = "ChoiceDrivenService";
      
      public static const REDEEM_ADDITIONAL_DAYS:int = 2;
      
      private static const WINDOW_CHOOSECONTENDER:String = "choosecontender";
      
      private static const WINDOW_CHOOSEBONUS:String = "choosebonus";
      
      private static const WINDOW_MAIN:String = "main";
      
      private static const WINDOW_BUYDIALOG:String = "buyDialog";
      
      private static const WINDOW_REWARD:String = "reward";
      
      private static const SAKURA_ASSET:String = "sakura";
      
      private static const CONTENDER_ASSET:String = "contender_";
      
      private static const WINDOW_BATTLE_REWARD:String = "battlereward";
      
      public static const DEFAULT_PAYMENT_CONFIRMATION_MINIMUM:int = 3;
      
      public static const HARVEST_CURRENCY_COOLDOWN:int = 14400;
      
      private var m_staticData:Object;
      
      private var m_currentBonusEndDate:String;
      
      private var m_currentRewardCollection:Array = null;
      
      private var m_currentBonusCollection:Array = null;
      
      private var m_currentContender:String = null;
      
      private var m_contenderNameList:Array = null;
      
      private var m_bucketPackages:Array = null;
      
      private var m_activeContender:String = null;
      
      private var m_bonusEndDatelist:Array = null;
      
      private var m_selectedContenderInBuyMode:String = null;
      
      private var m_chooseContenderWindow:ChooseContenderWindow;
      
      private var m_choiceDrivenWindow:ChoiceDrivenFeatureWindow;
      
      private var m_assetPaths:Object = null;
      
      public var ASK_FEED_FREQUENCY_KEY:String;
      
      public var HARVEST_FREQUENCY_KEY:String;
      
      private var m_isRoundOver:Boolean;
      
      public function ChoiceDrivenManager(featureName:String)
      {
         super(featureName);
         this.m_isRoundOver = false;
      }
      
      public static function getInstance(featureName:String) : ChoiceDrivenManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,ChoiceDrivenManager) as ChoiceDrivenManager;
      }
      
      private function initialize() : void
      {
         this.loadStaticData();
         if(this.isFeaturePlayable())
         {
            this.loadStaticSingleContenderData(this.getActiveContender());
            this.initializeFirstContender();
         }
         else
         {
            this.initializeBuyMode();
         }
      }
      
      public function getFeatureData() : Object
      {
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,m_featureName);
         if(!data)
         {
            data = this.initializeFeatureOptions();
         }
         return data;
      }
      
      override public function setFeatureData(data:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,m_featureName,data);
      }
      
      public function get bonusEndDate() : String
      {
         return this.m_currentBonusEndDate;
      }
      
      public function get bonusEndDatelist() : Array
      {
         return this.m_bonusEndDatelist;
      }
      
      public function get currentRewardCollection() : Array
      {
         return this.m_currentRewardCollection;
      }
      
      public function get currentBonusCollection() : Array
      {
         return this.m_currentBonusCollection;
      }
      
      public function get currentContender() : String
      {
         return this.m_currentContender;
      }
      
      public function get currencyCodePink() : String
      {
         return this.m_staticData.currencyItemNamePink;
      }
      
      public function get currencyCodeWhite() : String
      {
         return this.m_staticData.currencyItemNameWhite;
      }
      
      public function get windowChooseContender() : String
      {
         return this.m_assetPaths[WINDOW_CHOOSECONTENDER];
      }
      
      public function get windowChooseBonus() : String
      {
         return this.m_assetPaths[WINDOW_CHOOSEBONUS];
      }
      
      public function get windowFight() : String
      {
         return this.m_assetPaths[WINDOW_MAIN];
      }
      
      public function get windowBuy() : String
      {
         return this.m_assetPaths[WINDOW_BUYDIALOG];
      }
      
      public function get featureEndDate() : String
      {
         return this.m_staticData.endDate;
      }
      
      public function get askFeedFrequency() : int
      {
         return this.m_staticData.askFeedFrequency;
      }
      
      public function get harvestCoolOffTime() : int
      {
         return HARVEST_CURRENCY_COOLDOWN;
      }
      
      public function windowReward(num:int) : String
      {
         return this.m_assetPaths[WINDOW_REWARD + num];
      }
      
      public function contenderMovieClip(contender:String) : String
      {
         return this.m_assetPaths[CONTENDER_ASSET + contender];
      }
      
      public function sakuraMovieClip() : String
      {
         return this.m_assetPaths[SAKURA_ASSET];
      }
      
      public function rewardMovieClipName(num:int) : String
      {
         return "star_" + num + "_mc";
      }
      
      public function bonusMovieClipName(num:int) : String
      {
         return "npc_" + num + "_mc";
      }
      
      public function windowFinalReward() : String
      {
         return this.m_assetPaths["finalReward"];
      }
      
      public function windowBattleReward() : String
      {
         return this.m_assetPaths["bonusReward"];
      }
      
      public function get contenderNameList() : Array
      {
         return this.m_contenderNameList;
      }
      
      private function loadStaticData() : void
      {
         var list:XMLList = null;
         var i:Number = NaN;
         var asset:XML = null;
         this.m_staticData = new Object();
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         if(featureXML != null)
         {
            list = featureXML.subfeature;
            this.m_contenderNameList = new Array();
            this.m_bonusEndDatelist = new Array();
            for(i = 0; i < list.length(); i++)
            {
               this.m_contenderNameList.push(list[i].@name);
               this.m_bonusEndDatelist.push(list[i].listEndDate.toString());
            }
            this.m_assetPaths = new Object();
            if(featureXML.assets != "")
            {
               for each(asset in featureXML.assets.asset)
               {
                  this.m_assetPaths[asset.@name] = asset.@path.toString();
               }
            }
            this.m_staticData.currencyItemNamePink = featureXML.currencyItem[0].@name.toString();
            this.m_staticData.currencyItemNameWhite = featureXML.currencyItem[1].@name.toString();
            this.m_staticData.endDate = featureXML.listEndDate.toString();
            this.m_staticData.askFeedFrequency = featureXML.feed.@throttleTime.toString();
            this.ASK_FEED_FREQUENCY_KEY = m_featureName + "AskCurrency";
            this.HARVEST_FREQUENCY_KEY = m_featureName + "HarvestCurrency";
         }
      }
      
      private function loadStaticSingleContenderData(name:String) : void
      {
         var subFeatureNode:XML = null;
         var bonusXML:XML = null;
         var itemXML:XML = null;
         var bonusInfo:Object = null;
         var itemInfo:Object = null;
         if(name)
         {
            subFeatureNode = this.getSubFeatureXmlNode(name);
            this.m_currentRewardCollection = null;
            this.m_currentBonusCollection = null;
            if(subFeatureNode)
            {
               this.m_currentContender = name;
               this.m_currentBonusEndDate = subFeatureNode.listEndDate;
               this.m_currentBonusCollection = new Array();
               this.m_currentRewardCollection = new Array();
               for each(bonusXML in subFeatureNode.bonusReward)
               {
                  bonusInfo = {};
                  bonusInfo.name = String(bonusXML.@name);
                  bonusInfo.isHidden = int(bonusXML.@isHidden);
                  this.m_currentBonusCollection.push(bonusInfo);
               }
               for each(itemXML in subFeatureNode.items.item)
               {
                  itemInfo = {};
                  itemInfo.name = String(itemXML.@name);
                  itemInfo.pink = int(itemXML.@pink);
                  itemInfo.white = int(itemXML.@white);
                  this.m_currentRewardCollection.push(itemInfo);
               }
            }
         }
      }
      
      private function getSubFeatureXmlNode(name:String) : XML
      {
         var list:XMLList = null;
         var i:Number = NaN;
         var subFeatureNode:XML = null;
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         if(featureXML != null)
         {
            list = featureXML.subfeature;
            for(i = 0; i < list.length(); i++)
            {
               if(list[i].@name == name)
               {
                  subFeatureNode = list[i];
               }
            }
         }
         return subFeatureNode;
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
      
      private function initializeFirstContender() : void
      {
         if(!this.getActiveContender())
         {
            if(!FeatureOptionsInventoryManager.getInstance().hasItemEntryInInventory(this.currencyCodePink) && !FeatureOptionsInventoryManager.getInstance().hasItemEntryInInventory(this.currencyCodeWhite))
            {
               FeatureOptionsInventoryManager.getInstance().addCount(this.currencyCodePink,5);
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"setInitialCurriencies",null,[m_featureName]));
            }
            this.loadStaticSingleContenderData(this.contenderNameList[0]);
            this.setContender(this.contenderNameList[0]);
         }
      }
      
      private function initializeBuyMode() : void
      {
         if(!this.m_selectedContenderInBuyMode)
         {
            this.m_selectedContenderInBuyMode = this.contenderNameList[0];
         }
         this.loadStaticSingleContenderData(this.m_selectedContenderInBuyMode);
      }
      
      public function setContender(contender:String = null, sendTransaction:Boolean = true) : void
      {
         var data:Object = null;
         var obj:Object = null;
         var reward:Object = null;
         if(contender == null)
         {
            contender = this.getSelectableContenderName();
            if(!contender)
            {
               contender = this.contenderNameList[0];
            }
         }
         if(contender)
         {
            data = this.getFeatureData();
            if(data)
            {
               this.setActiveContender(contender);
               this.loadStaticSingleContenderData(contender);
               data[CONTENDER_STATUS][contender] = 0;
               obj = data[REWARD_COLLECTION][contender];
               if(obj == null)
               {
                  data[REWARD_COLLECTION][contender] = new Object();
                  for each(reward in this.currentRewardCollection)
                  {
                     data[REWARD_COLLECTION][contender][reward.name] = 0;
                  }
               }
               this.setFeatureData(data);
               if(sendTransaction)
               {
                  TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"chooseContender",this.onContenderChosen,[m_featureName,contender]));
               }
            }
         }
      }
      
      public function chooseBonus(bonusItemName:String) : void
      {
         var featureData:Object = null;
         var item:Object = null;
         var bonusObj:Object = null;
         var activeContender:String = this.getActiveContender();
         if(activeContender == this.currentContender)
         {
            featureData = this.getFeatureData();
            for each(item in this.currentBonusCollection)
            {
               if(item.name == bonusItemName)
               {
                  if(featureData[BONUS_COLLECTION][activeContender] == null)
                  {
                     bonusObj = new Object();
                     bonusObj[item.name] = 0;
                     featureData[BONUS_COLLECTION][activeContender] = bonusObj;
                  }
                  this.setFeatureData(featureData);
                  TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"chooseBonus",this.onBonusChosen,[m_featureName,bonusItemName]));
               }
            }
         }
      }
      
      public function setBonusExpired() : void
      {
         var featureData:Object = null;
         var bonusObj:Object = null;
         var activeContender:String = this.getActiveContender();
         if(activeContender == this.currentContender)
         {
            featureData = this.getFeatureData();
            if(featureData[BONUS_COLLECTION][activeContender] == null)
            {
               bonusObj = new Object();
               bonusObj[KEY_EXPIRED] = KEY_EXPIRED;
               featureData[BONUS_COLLECTION][activeContender] = bonusObj;
               this.setFeatureData(featureData);
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"setBonusExpired",this.onBonusChosen,[m_featureName]));
            }
         }
      }
      
      public function claimReward(parent:ChoiceDrivenFeatureWindow, rewardName:String = null) : void
      {
         var item:Object = null;
         var data:Object = null;
         var reward:Object = null;
         var activeContender:String = this.getActiveContender();
         if(rewardName == null)
         {
            reward = this.getRedeemableReward();
         }
         else if(activeContender == this.m_currentContender)
         {
            for each(item in this.currentRewardCollection)
            {
               if(item.name == rewardName)
               {
                  reward = item;
                  break;
               }
            }
         }
         var pinkCnt:int = FeatureOptionsInventoryManager.getInstance().getCount(this.currencyCodePink);
         var whiteCnt:int = FeatureOptionsInventoryManager.getInstance().getCount(this.currencyCodeWhite);
         if(pinkCnt >= reward.pink && whiteCnt >= reward.white)
         {
            FeatureOptionsInventoryManager.getInstance().removeCount(this.currencyCodePink,reward.pink);
            FeatureOptionsInventoryManager.getInstance().removeCount(this.currencyCodeWhite,reward.white);
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,CURRENCY_SPENT_PINK,reward.pink);
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,CURRENCY_SPENT_WHITE,reward.white);
            Global.player.addGift(reward.name);
            data = this.getFeatureData();
            ++data[REWARD_COLLECTION][activeContender][reward.name];
            this.setFeatureData(data);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"claimReward",this.onClaimReward,[m_featureName,reward.name]),true);
         }
         this.m_choiceDrivenWindow = parent;
      }
      
      public function askForCurrency() : void
      {
         if(this.getTimeRemaining(this.ASK_FEED_FREQUENCY_KEY) <= 0)
         {
            TransactionManager.addTransaction(new TGenericTransactionWithFeed(SERVICE_NAME,"askForMedals",this.onaskForCurrency,[m_featureName]));
            Global.player.setFeatureLastShown(this.ASK_FEED_FREQUENCY_KEY,GlobalEngine.serverTime / 1000,true);
         }
      }
      
      private function onaskForCurrency(e:Object) : void
      {
         if(this.m_choiceDrivenWindow)
         {
            this.m_choiceDrivenWindow.partialXSlotRefresh();
         }
      }
      
      public function harvestConsumable(parent:ChoiceDrivenFeatureWindow) : void
      {
         var count:int = 0;
         var itemXML:XML = null;
         if(this.getTimeRemaining(this.HARVEST_FREQUENCY_KEY) <= 0)
         {
            itemXML = Global.farmGameSettingsManager.getItemXMLByCode(this.currencyCodeWhite);
            if(Boolean(itemXML) && itemXML.hasOwnProperty("count"))
            {
               count = int(itemXML["count"]);
            }
            else
            {
               count = HARVEST_CURRENCY_INCREMENT_AMT;
            }
            FeatureOptionsInventoryManager.getInstance().addCount(this.currencyCodeWhite,count);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"harvestConsumable",this.onHarvested,[m_featureName]),true);
            Global.player.setFeatureLastShown(this.HARVEST_FREQUENCY_KEY,GlobalEngine.serverTime / 1000,false);
         }
         this.m_choiceDrivenWindow = parent;
      }
      
      private function onHarvested(result:Object) : void
      {
         if(this.m_choiceDrivenWindow)
         {
            this.m_choiceDrivenWindow.enableWindow(true);
         }
      }
      
      public function skipHarvest(parent:ChoiceDrivenFeatureWindow) : void
      {
         var buyResult:Boolean = false;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.currencyCodeWhite);
         if(Global.player.canBuyCash(item.cash))
         {
            buyResult = Global.player.tryBuy(null,false,item,0);
            if(buyResult)
            {
               Global.player.setFeatureLastShown(this.HARVEST_FREQUENCY_KEY,1,false);
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"skipHarvest",this.onSkipped,[m_featureName]));
            }
         }
         this.m_choiceDrivenWindow = parent;
         if(this.m_choiceDrivenWindow)
         {
            this.m_choiceDrivenWindow.partialYSlotRefresh();
         }
      }
      
      public function onSkipped(e:Object) : void
      {
      }
      
      public function dismissNoBonusMessage(parent:FarmWindow) : void
      {
         var bonusObj:Object = null;
         var key:String = null;
         var contender:String = this.getActiveContender();
         var data:Object = this.getFeatureData();
         if(data)
         {
            bonusObj = data[BONUS_COLLECTION][contender];
            if(bonusObj)
            {
               for(key in bonusObj)
               {
                  if(bonusObj[key] == 0)
                  {
                     data[BONUS_COLLECTION][contender][key] = KEY_EXPIRED;
                     this.setFeatureData(data);
                     TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"setBonusExpiredDismiss",null,[m_featureName]));
                  }
               }
            }
         }
      }
      
      public function selectContenderReward(contender:String) : void
      {
         if(Boolean(contender) && !this.isFeaturePlayable())
         {
            this.m_selectedContenderInBuyMode = contender;
            this.loadStaticSingleContenderData(contender);
         }
      }
      
      public function buyCollectionItem(itemName:String) : void
      {
         var item:FarmItem = null;
         var bought:Boolean = false;
         if(itemName)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(Global.player.canBuyCash(item.cash))
            {
               bought = Global.player.buyFarmItem(item,Currency.CASH,1,true,false);
            }
            if(bought)
            {
            }
         }
      }
      
      public function onContenderChosen(e:Object) : void
      {
         if(e.error == null)
         {
            this.loadStaticSingleContenderData(this.getActiveContender());
         }
      }
      
      public function onBonusChosen(e:Object) : void
      {
         if(e.error == null)
         {
         }
      }
      
      public function onClaimReward(e:Object) : void
      {
         var farmItem:FarmItem = null;
         var rewardWindowNumber:int = 0;
         var rewardWindow:EnableSpecificMovieClipRewardWindow = null;
         var activeContender:String = null;
         var data:Object = null;
         if(e.error == null)
         {
            this.m_isRoundOver = this.isRoundOver();
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(e.reward);
            rewardWindowNumber = this.getRoundNumber() - 2;
            if(this.m_isRoundOver)
            {
               rewardWindowNumber++;
            }
            rewardWindow = new EnableSpecificMovieClipRewardWindow(this.windowReward(this.getContenderNumber() - 1),m_featureName,farmItem,this.rewardMovieClipName(rewardWindowNumber),this.onShareReward,this.showBonusCongrats,e,e.reward);
            UI.displayPopup(rewardWindow,false);
            activeContender = this.getActiveContender();
            data = this.getFeatureData();
            if(this.m_isRoundOver)
            {
               data[CONTENDER_STATUS][activeContender] = 1;
               this.setFeatureData(data);
               if(!this.isTournamentComplete())
               {
                  this.setContender(null,false);
               }
            }
         }
      }
      
      public function showBonusCongrats(e:Object) : void
      {
         var bonusItem:FarmItem = null;
         var rewardDialog:String = null;
         var bonusTitle:String = null;
         var bonusText:String = null;
         var contenderNum:int = 0;
         var bonusRewardWindow:EnableSpecificMovieClipRewardWindow = null;
         if(this.m_isRoundOver)
         {
            bonusItem = null;
            if(e.bonus != null)
            {
               Global.player.addGift(e.bonus);
               bonusItem = Global.farmGameSettingsManager.getFarmItemByName(e.bonus);
            }
            rewardDialog = this.windowBattleReward();
            bonusTitle = "Sakura Wins!";
            bonusText = "We have a winner, folks! Sakura moves on to the next round!";
            if(this.isTournamentComplete())
            {
               rewardDialog = this.windowFinalReward();
               bonusText = "We have a truce so we\'re all winners!";
               bonusTitle = "Finale!";
            }
            contenderNum = this.getContenderNumber() - 2;
            contenderNum = contenderNum >= 0 ? contenderNum : int(this.contenderNameList.length - 1);
            bonusRewardWindow = new EnableSpecificMovieClipRewardWindow(rewardDialog,m_featureName,bonusItem,this.bonusMovieClipName(contenderNum),this.onShareBonusReward,this.showUIAfterBonus,e,e.bonus,bonusText,bonusTitle);
            UI.displayPopup(bonusRewardWindow,false);
         }
         else if(this.m_choiceDrivenWindow)
         {
            this.m_choiceDrivenWindow.enableWindowWithGlow();
         }
         this.m_isRoundOver = false;
      }
      
      public function showUIAfterBonus(e:Object) : void
      {
         if(this.m_choiceDrivenWindow)
         {
            this.m_choiceDrivenWindow.close();
            this.m_choiceDrivenWindow = null;
         }
         if(this.m_chooseContenderWindow)
         {
            this.m_chooseContenderWindow.close();
            this.m_chooseContenderWindow = null;
         }
         this.showUI();
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
            "item":Global.farmGameSettingsManager.getFarmItemByCode(this.currencyCodePink).friendlyTitle
         };
         GlobalEngine.socialNetwork.publishFeedStory(BRAG_FEED_TYPE,bundleData,[],false);
         window.close();
      }
      
      private function onShareBonusReward(result:Object, window:FarmWindow) : void
      {
         var item:FarmItem = null;
         if(result.bonus != null)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(result.bonus);
         }
         else
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(this.currencyCodePink);
         }
         var bundleData:Object = {
            "reward_link":result.feed.rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + result.feed.rewardLink,
               "src":item.iconUrl
            }],
            "rewardName":item.friendlyTitle,
            "item":Global.farmGameSettingsManager.getFarmItemByCode(this.currencyCodePink).friendlyTitle
         };
         GlobalEngine.socialNetwork.publishFeedStory(BRAG_FEED_TYPE,bundleData,[],false);
         window.close();
      }
      
      public function isContenderBonusActive(contender:String = null) : Boolean
      {
         var subFeatureNode:XML = null;
         if(contender == null)
         {
            contender = this.getSelectableContenderName();
         }
         var endDate:String = null;
         var activeContender:String = this.getActiveContender();
         if(contender == activeContender)
         {
            endDate = this.bonusEndDate;
         }
         else
         {
            subFeatureNode = this.getSubFeatureXmlNode(contender);
            if(subFeatureNode)
            {
               endDate = subFeatureNode.listEndDate;
            }
         }
         return FarmGameUtil.isFeatureInActivePeriod(endDate);
      }
      
      public function isFeaturePlayable() : Boolean
      {
         return FarmGameUtil.isFeatureInActivePeriod(this.featureEndDate,0);
      }
      
      public function getActiveContender() : String
      {
         var result:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,CONTENDER_ACTIVE);
         if(result)
         {
            return result.toString();
         }
         return null;
      }
      
      private function setActiveContender(contender:String) : void
      {
         this.m_activeContender = contender;
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,CONTENDER_ACTIVE,contender);
      }
      
      public function getPinkConsumableCount() : int
      {
         return int(FeatureOptionsInventoryManager.getInstance().getCount(this.currencyCodePink));
      }
      
      public function getWhiteConsumableCount() : int
      {
         return int(FeatureOptionsInventoryManager.getInstance().getCount(this.currencyCodeWhite));
      }
      
      private function initializeFeatureOptions() : Object
      {
         var item:String = null;
         var data:Object = new Object();
         data[CONTENDER_STATUS] = new Object();
         data[BONUS_COLLECTION] = new Object();
         data[REWARD_COLLECTION] = new Object();
         for each(item in this.contenderNameList)
         {
            data[CONTENDER_STATUS][item] = -1;
            data[BONUS_COLLECTION][item] = null;
            data[REWARD_COLLECTION][item] = null;
         }
         this.setFeatureData(data);
         return data;
      }
      
      public function openBuyWindow(owner:FarmWindow) : void
      {
         UI.displayPopup(new FeaturePackagesBuyWindow(this.windowBuy,m_featureName,this.getPurchasePackages(),owner),false);
      }
      
      public function showUI() : void
      {
         this.initialize();
         if(this.m_choiceDrivenWindow)
         {
            UI.displayPopup(this.m_choiceDrivenWindow = new ChoiceDrivenFeatureWindow(this.windowFight,m_featureName));
         }
         else
         {
            this.showContenderUI();
         }
      }
      
      public function showContenderUI() : void
      {
         this.m_chooseContenderWindow = new ChooseContenderWindow(this.windowChooseContender,m_featureName);
         UI.displayPopup(this.m_chooseContenderWindow);
      }
      
      public function showFightUI() : void
      {
         this.m_choiceDrivenWindow = new ChoiceDrivenFeatureWindow(this.windowFight,m_featureName);
         UI.displayPopup(this.m_choiceDrivenWindow);
      }
      
      public function openBonusSelectionUI() : void
      {
         UI.displayPopup(new BonusSelectionWindow(this.windowChooseBonus,this.currentBonusCollection,m_featureName));
      }
      
      public function getSelectableContenderName() : String
      {
         var contenderStatuses:Object = null;
         var conNameIndex:String = null;
         var con:String = null;
         var data:Object = this.getFeatureData();
         if(data)
         {
            contenderStatuses = data[CONTENDER_STATUS];
            for each(conNameIndex in this.m_contenderNameList)
            {
               if(contenderStatuses[conNameIndex] != 1)
               {
                  if(contenderStatuses[conNameIndex] == -1 || contenderStatuses[conNameIndex] == 0)
                  {
                     con = conNameIndex;
                     break;
                  }
               }
            }
         }
         return con;
      }
      
      public function getRedeemableReward() : Object
      {
         var reward:Object = null;
         var result:Object = null;
         var data:Object = this.getFeatureData();
         var activeContender:String = this.getActiveContender();
         for each(reward in this.currentRewardCollection)
         {
            if(data[REWARD_COLLECTION][activeContender])
            {
               if(data[REWARD_COLLECTION][activeContender][reward.name] <= 0)
               {
                  result = reward;
                  break;
               }
            }
         }
         return result;
      }
      
      public function getRoundNumber() : int
      {
         var reward:Object = null;
         var round:int = 1;
         var data:Object = this.getFeatureData();
         var activeContender:String = this.getActiveContender();
         for each(reward in this.currentRewardCollection)
         {
            if(data[REWARD_COLLECTION][activeContender])
            {
               if(data[REWARD_COLLECTION][activeContender][reward.name] <= 0)
               {
                  break;
               }
               round++;
            }
         }
         return round > this.currentRewardCollection.length ? int(this.currentRewardCollection.length) : int(round);
      }
      
      public function getContenderNumber() : int
      {
         var name:Object = null;
         var count:int = 1;
         var activeContender:String = this.getActiveContender();
         for each(name in this.contenderNameList)
         {
            if(name == activeContender)
            {
               break;
            }
            count++;
         }
         return count;
      }
      
      public function isTournamentComplete() : Boolean
      {
         var contenderStatuses:Object = null;
         var conNameIndex:String = null;
         var result:Boolean = true;
         var data:Object = this.getFeatureData();
         if(data)
         {
            contenderStatuses = data[CONTENDER_STATUS];
            for each(conNameIndex in this.m_contenderNameList)
            {
               if(contenderStatuses[conNameIndex] == -1 || contenderStatuses[conNameIndex] == 0)
               {
                  result = false;
                  break;
               }
            }
         }
         return result;
      }
      
      public function getBonusSelected(contender:String = null) : String
      {
         var bonusObj:Object = null;
         var key:String = null;
         if(contender == null)
         {
            contender = this.getActiveContender();
         }
         var bonus:String = null;
         var data:Object = this.getFeatureData();
         if(data)
         {
            bonusObj = data[BONUS_COLLECTION][contender];
            if(bonusObj)
            {
               for(key in bonusObj)
               {
                  if(key != KEY_EXPIRED)
                  {
                     bonus = key;
                  }
               }
            }
         }
         return bonus;
      }
      
      public function isBonusSetExpired() : Boolean
      {
         var bonusObj:Object = null;
         var key:String = null;
         var result:Boolean = false;
         var contender:String = this.getActiveContender();
         var data:Object = this.getFeatureData();
         if(data)
         {
            bonusObj = data[BONUS_COLLECTION][contender];
            if(bonusObj)
            {
               for(key in bonusObj)
               {
                  if(key == KEY_EXPIRED)
                  {
                     result = true;
                  }
               }
            }
         }
         return result;
      }
      
      public function isBonusExpireDismissed() : Boolean
      {
         var bonusObj:Object = null;
         var key:String = null;
         var result:Boolean = false;
         var contender:String = this.getActiveContender();
         var data:Object = this.getFeatureData();
         if(data)
         {
            bonusObj = data[BONUS_COLLECTION][contender];
            if(bonusObj)
            {
               for(key in bonusObj)
               {
                  if(bonusObj[key] == KEY_EXPIRED)
                  {
                     result = true;
                  }
               }
            }
         }
         return result;
      }
      
      public function getChooseContenderSlotObject() : Object
      {
         var contenderStatuses:Object = null;
         var con:String = null;
         var itemObj:Object = null;
         var result:Array = new Array();
         var index:int = 0;
         var data:Object = this.getFeatureData();
         if(data)
         {
            contenderStatuses = data[CONTENDER_STATUS];
            for each(con in this.contenderNameList)
            {
               itemObj = new Object();
               switch(contenderStatuses[con])
               {
                  case 1:
                     itemObj.status = STAUS_DEFEATED;
                     break;
                  case 0:
                     itemObj.status = STAUS_CURRENT;
                     break;
                  case -1:
                     itemObj.status = STAUS_IDLE;
               }
               if(this.isFeaturePlayable())
               {
                  itemObj.isSelected = this.getActiveContender() == con;
               }
               else
               {
                  itemObj.isSelected = this.m_selectedContenderInBuyMode == con;
               }
               itemObj.name = con;
               itemObj.bonusExpiry = this.bonusEndDatelist[index];
               result.push(itemObj);
               index++;
            }
         }
         return result;
      }
      
      public function isRoundOver() : Boolean
      {
         var rewardItem:String = null;
         var result:Boolean = true;
         var data:Object = this.getFeatureData();
         var playerRewardList:Object = data[REWARD_COLLECTION][this.getActiveContender()];
         for(rewardItem in playerRewardList)
         {
            if(playerRewardList[rewardItem] <= 0)
            {
               result = false;
               break;
            }
         }
         return result;
      }
      
      public function isRewardRedeemed(con:String, reward:String) : Boolean
      {
         var item:String = null;
         var result:Boolean = false;
         var data:Object = this.getFeatureData();
         var collection:Object = data[REWARD_COLLECTION][con];
         for(item in collection)
         {
            if(item == reward)
            {
               result = collection[item] > 0;
               break;
            }
         }
         return result;
      }
      
      public function getTimeRemaining(key:String) : int
      {
         var time:int = 0;
         var now:int = int(GlobalEngine.serverTime / 1000);
         var lastShown:int = Global.player.getFeatureLastShown(key);
         var coolOffTime:int = 0;
         switch(key)
         {
            case this.ASK_FEED_FREQUENCY_KEY:
               coolOffTime = this.askFeedFrequency;
               break;
            case this.HARVEST_FREQUENCY_KEY:
               coolOffTime = this.harvestCoolOffTime;
         }
         if(lastShown != 0)
         {
            time = lastShown + coolOffTime - now;
         }
         return time;
      }
      
      public function canClaimReward() : Boolean
      {
         var pinkCnt:int = 0;
         var whiteCnt:int = 0;
         var result:Boolean = false;
         var reward:Object = this.getRedeemableReward();
         if(reward != null)
         {
            pinkCnt = FeatureOptionsInventoryManager.getInstance().getCount(this.currencyCodePink);
            whiteCnt = FeatureOptionsInventoryManager.getInstance().getCount(this.currencyCodeWhite);
            if(pinkCnt >= reward.pink && whiteCnt >= reward.white)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function getGreenProgressMilestone() : Number
      {
         var rewardColl:Object = null;
         var reward:Object = null;
         var result:Number = 0;
         var activeCon:String = this.getActiveContender();
         var data:Object = this.getFeatureData();
         if(data)
         {
            rewardColl = data[REWARD_COLLECTION][activeCon];
            for each(reward in this.currentRewardCollection)
            {
               if(rewardColl[reward.name] == 0)
               {
                  break;
               }
               result++;
            }
         }
         return result / 4;
      }
      
      public function getPinkConsumableProgress() : Number
      {
         var rewardColl:Object = null;
         var reward:Object = null;
         var total:Number = 0;
         var result:Array = new Array();
         var count:int = this.getPinkConsumableCount();
         var requiredCount:int = 0;
         var data:Object = this.getFeatureData();
         var activeCon:String = this.getActiveContender();
         if(data)
         {
            rewardColl = data[REWARD_COLLECTION][activeCon];
            for each(reward in this.currentRewardCollection)
            {
               requiredCount = int(reward.pink);
               if(count <= 0)
               {
                  result.push(0);
               }
               else if(rewardColl[reward.name] == 1)
               {
                  result.push(1);
                  total++;
               }
               else if(rewardColl[reward.name] == 0)
               {
                  if(count > requiredCount)
                  {
                     result.push(1);
                     total++;
                     count -= requiredCount;
                  }
                  else
                  {
                     result.push(count / requiredCount);
                     total += count / requiredCount;
                     count -= requiredCount;
                  }
               }
            }
         }
         return total / 4;
      }
      
      public function getWhiteConsumableProgress() : Number
      {
         var rewardColl:Object = null;
         var reward:Object = null;
         var total:Number = 0;
         var result:Array = new Array();
         var count:int = this.getWhiteConsumableCount();
         var requiredCount:int = 0;
         var data:Object = this.getFeatureData();
         var activeCon:String = this.getActiveContender();
         if(data)
         {
            rewardColl = data[REWARD_COLLECTION][activeCon];
            for each(reward in this.currentRewardCollection)
            {
               requiredCount = int(reward.white);
               if(count <= 0)
               {
                  result.push(0);
               }
               else if(rewardColl[reward.name] == 1)
               {
                  result.push(1);
                  total++;
               }
               else if(rewardColl[reward.name] == 0)
               {
                  if(count > requiredCount)
                  {
                     result.push(1);
                     total++;
                     count -= requiredCount;
                  }
                  else
                  {
                     result.push(count / requiredCount);
                     total += count / requiredCount;
                     count -= requiredCount;
                  }
               }
            }
         }
         return total / 4;
      }
      
      public function getActiveContenderIdleExportName() : String
      {
         return this.getContenderExportName() + ".idle_mc";
      }
      
      public function getActiveContenderFightExportName() : String
      {
         return this.getContenderExportName() + ".fight_mc";
      }
      
      private function getContenderExportName() : String
      {
         var result:String = "";
         var con:String = this.getActiveContender();
         switch(con)
         {
            case "c0":
               result = "c1";
               break;
            case "c1":
               result = "c2";
               break;
            case "c2":
               result = "c3";
               break;
            case "c3":
               result = "c4";
               break;
            case "c4":
               result = "c5";
         }
         return result;
      }
   }
}

