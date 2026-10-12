package Managers
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.SubscriberWalletMainWindow;
   import Widgets.Windows.SubscriberWalletOneSpinDialog;
   import Widgets.Windows.SubscriberWalletRewardCollection;
   import Widgets.Windows.SubscriberWalletTenSpinDialog;
   
   public class SubscriberWalletManager extends BaseFeatureManager
   {
      
      public static const SERVICE_CLASS:String = "SubscriberWalletService";
      
      public static const SERVICE_FUNC_SPIN_IT:String = "spinIt";
      
      public static const SERVICE_REWARD_FINISH:String = "updateReward";
      
      public static const REWARD_UPDATED:int = 0;
      
      public static const REWARD_PENDING:int = 1;
      
      public static const SPIN_VIP:int = 0;
      
      public static const SPIN_EARNED:int = 1;
      
      public static const SPIN_PAID_1:int = 2;
      
      public static const SPIN_PAID_10:int = 3;
      
      public static const SPIN_TOKEN:int = 4;
      
      public static const KEY_TOKEN_COUNT:String = "tokenCount";
      
      public static const KEY_VIP_SPIN_AVAILABLE:String = "vipSpinAvailable";
      
      public static const KEY_REWARD_STATE:String = "rewardState";
      
      public static const KEY_REWARDS_ARRAY:String = "rewardsArray";
      
      public static const KEY_SPIN_TYPE_EXECUTED_LAST:String = "spinTypeExecutedLast";
      
      public static const KEY_ULTRA_REWARD_FLAG:String = "ultraRewardFlag";
      
      public static const KEY_NEXT_VIP_SPIN_TIMESTAMP:String = "nextVipSpinTimeStamp";
      
      public static const FEATURE_NAME:String = "subscriber_wallet";
      
      private var m_featureXml:XML;
      
      private var m_featureConfigData:Object;
      
      private var m_vip:Boolean;
      
      private var m_rewardArray:Array;
      
      private var m_mainUI:SubscriberWalletMainWindow;
      
      private var m_exchangeButtonClickFlag:Boolean;
      
      private var m_subscriberWalletTenSpinDialog:SubscriberWalletTenSpinDialog;
      
      private var m_subscriberWalletOneSpinDialog:SubscriberWalletOneSpinDialog;
      
      private var m_spinTypeCurrent:int;
      
      private var m_spinCountsForTokenReference:int;
      
      private var m_tutorialSeenFlag:Boolean;
      
      private var m_newRewardFlag:Boolean;
      
      private var m_tokenCount:int;
      
      private var m_spinNames:Object;
      
      public function SubscriberWalletManager(featureName:String, featureConfig:XML = null)
      {
         super(featureName,featureConfig);
         this.m_exchangeButtonClickFlag = false;
         this.m_featureXml = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         this.m_featureConfigData = new Object();
         this.m_rewardArray = new Array();
         this.setupAssets();
         this.setupRewards1();
         this.setupTokenMaxCount();
         this.setupFeedThrottle();
         this.setupCashAmount();
         this.setupTokenVisibleAfterSpinCount();
         this.setupCountForEarnedSpin();
         this.setupRewardExpiryFlag();
         this.setupVip();
         this.m_subscriberWalletTenSpinDialog = null;
         this.m_tutorialSeenFlag = Global.player.getSeenFlag(m_featureName + "_Tutorial");
         this.setSpinNames();
      }
      
      public static function getInstance(featureName:String = "subscriber_wallet") : SubscriberWalletManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,SubscriberWalletManager) as SubscriberWalletManager;
      }
      
      private function setSpinNames() : void
      {
         this.m_spinNames = new Object();
         this.m_spinNames[SPIN_VIP] = "spin_vip";
         this.m_spinNames[SPIN_EARNED] = "spin_free";
         this.m_spinNames[SPIN_PAID_1] = "spin_1";
         this.m_spinNames[SPIN_PAID_10] = "spin_10";
         this.m_spinNames[SPIN_TOKEN] = "spin_token";
      }
      
      public function isTutorialSeen() : Boolean
      {
         return this.m_tutorialSeenFlag;
      }
      
      public function setTutorialSeen() : void
      {
         this.m_tutorialSeenFlag = true;
      }
      
      public function doOneSpin(spinType:int) : void
      {
         this.m_spinTypeCurrent = spinType;
         var passed:Boolean = false;
         if(spinType != SPIN_PAID_1)
         {
            passed = true;
         }
         else if(Global.player.canBuyCash(int(this.m_featureConfigData["paid1Cost"])))
         {
            ++this.m_spinCountsForTokenReference;
            if(this.isTutorialSeen())
            {
               Global.player.cash -= int(this.m_featureConfigData["paid1Cost"]);
               FarmStatsManager.count("fv_cash_buy",m_featureName,this.m_spinNames[spinType],this.m_featureConfigData["paid1Cost"].toString());
            }
            else
            {
               Global.player.setSeenFlag(m_featureName + "_Tutorial",false,true);
            }
            passed = true;
         }
         if(passed)
         {
            this.updateFeatureOptionAfterSpin(spinType);
            FarmStatsManager.count(m_featureName,"spintype",this.m_spinNames[spinType]);
            UI.displayPopup(this.m_subscriberWalletOneSpinDialog = new SubscriberWalletOneSpinDialog(this.m_featureConfigData["assets"]["rewardUI1"],spinType,null,this.m_tokenCount),false);
         }
      }
      
      public function updateMainUIVIP(result:Object) : void
      {
         var featureData:Object = null;
         if(this.m_spinTypeCurrent == SPIN_VIP && result[KEY_NEXT_VIP_SPIN_TIMESTAMP] > 0)
         {
            featureData = this.getFeatureOption();
            featureData[KEY_VIP_SPIN_AVAILABLE] = result[KEY_NEXT_VIP_SPIN_TIMESTAMP];
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,FEATURE_NAME,featureData);
            this.m_mainUI.updateFeatureData(featureData);
            this.m_mainUI.updateVipTimer();
         }
      }
      
      public function updateFeatureOptionAfterSpin(spinType:int) : void
      {
         var featureData:Object = this.getFeatureOption();
         if(this.isTutorialSeen())
         {
            featureData[spinType] += 1;
         }
         if(spinType == SPIN_VIP)
         {
            featureData[KEY_VIP_SPIN_AVAILABLE] = 0;
         }
         if(spinType == SPIN_TOKEN)
         {
            featureData[KEY_TOKEN_COUNT] -= int(this.m_featureConfigData["tokenCountForSpin"]);
         }
         featureData[KEY_REWARD_STATE] = REWARD_PENDING;
         featureData[KEY_SPIN_TYPE_EXECUTED_LAST] = spinType;
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,FEATURE_NAME,featureData);
         this.m_tokenCount = featureData[KEY_TOKEN_COUNT];
      }
      
      public function doTenSpin(spinType:int) : void
      {
         if(Global.player.canBuyCash(int(this.m_featureConfigData["paid10Cost"])))
         {
            Global.player.cash -= int(this.m_featureConfigData["paid10Cost"]);
            FarmStatsManager.count("fv_cash_buy",m_featureName,this.m_spinNames[spinType],this.m_featureConfigData["paid10Cost"].toString());
            this.updateFeatureOptionAfterSpin(spinType);
            UI.displayPopup(this.m_subscriberWalletTenSpinDialog = new SubscriberWalletTenSpinDialog(this.m_featureConfigData["assets"]["rewardUI2"],this.m_tokenCount),false);
         }
      }
      
      public function updateReward(rewards:Object) : void
      {
         var reward:Object = null;
         var rewardArraya:Array = new Array();
         for each(reward in rewards)
         {
            if(reward.freeze == false)
            {
               rewardArraya.push(reward.rewardItemName);
            }
         }
         this.m_rewardArray = rewardArraya;
         this.updateFeatureDataAndUI();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,SERVICE_REWARD_FINISH,this.updateTokenCallback,[FEATURE_NAME,rewardArraya]),true);
      }
      
      public function updateReward2(rewardArray:Array) : void
      {
         this.m_rewardArray = rewardArray;
         this.updateFeatureDataAndUI();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,SERVICE_REWARD_FINISH,this.updateTokenCallback,[FEATURE_NAME,rewardArray]),true);
      }
      
      public function updateFeatureDataAndUI() : void
      {
         var rewardCode:String = null;
         var item:FarmItem = null;
         var featureData:Object = this.getFeatureOption();
         featureData[KEY_REWARD_STATE] = REWARD_UPDATED;
         if(featureData[KEY_SPIN_TYPE_EXECUTED_LAST] == SPIN_PAID_10)
         {
            featureData[KEY_TOKEN_COUNT] += 10 - this.m_rewardArray.length;
            FarmStatsManager.count(m_featureName,"tokenexchange",this.m_spinNames[featureData[KEY_SPIN_TYPE_EXECUTED_LAST]],(10 - this.m_rewardArray.length).toString());
         }
         else
         {
            featureData[KEY_TOKEN_COUNT] += 1 - this.m_rewardArray.length;
            FarmStatsManager.count(m_featureName,"tokenexchange",this.m_spinNames[featureData[KEY_SPIN_TYPE_EXECUTED_LAST]],(1 - this.m_rewardArray.length).toString());
         }
         for each(rewardCode in this.m_rewardArray)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(rewardCode);
            Global.player.addGift(item.name);
         }
         if(featureData[KEY_TOKEN_COUNT] > int(this.m_featureConfigData["tokenMaxCount"]))
         {
            featureData[KEY_TOKEN_COUNT] = int(this.m_featureConfigData["tokenMaxCount"]);
         }
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,FEATURE_NAME,featureData);
         this.updateMainUI(featureData);
      }
      
      public function updateTokenCallback(result:Object) : void
      {
         if(result["status"] == true)
         {
         }
      }
      
      public function showMainUI() : void
      {
         var featureData:Object = this.getFeatureOption();
         this.m_spinCountsForTokenReference = featureData[SPIN_PAID_1];
         UI.displayPopup(this.m_mainUI = new SubscriberWalletMainWindow(FEATURE_NAME,this.m_vip,"assets/dialogs/VIPWallet2017/FV_VIPWallet2017.swf",featureData));
         if(featureData[KEY_REWARD_STATE] == REWARD_PENDING)
         {
            this.showRewardUI(featureData);
         }
      }
      
      public function showRewardUI(featureData:Object) : void
      {
         var rewardArray:Object = new Object();
         rewardArray["rewards"] = featureData[KEY_REWARDS_ARRAY];
         switch(featureData[KEY_SPIN_TYPE_EXECUTED_LAST])
         {
            case SPIN_PAID_10:
               UI.displayPopup(this.m_subscriberWalletTenSpinDialog = new SubscriberWalletTenSpinDialog(this.m_featureConfigData["assets"]["rewardUI2"],featureData[KEY_TOKEN_COUNT],rewardArray),false);
               break;
            default:
               UI.displayPopup(this.m_subscriberWalletOneSpinDialog = new SubscriberWalletOneSpinDialog(this.m_featureConfigData["assets"]["rewardUI1"],featureData[KEY_SPIN_TYPE_EXECUTED_LAST],rewardArray,featureData[KEY_TOKEN_COUNT]),false);
         }
      }
      
      public function showRewardCollection() : void
      {
         UI.displayPopup(new SubscriberWalletRewardCollection(this.m_featureConfigData["assets"]["rewardList"]),false);
      }
      
      public function updateRewardState(rewardIndex:int, checkedFlag:Boolean) : void
      {
         if(this.m_subscriberWalletTenSpinDialog)
         {
            this.m_subscriberWalletTenSpinDialog.updateTokenExchange(rewardIndex,checkedFlag);
         }
      }
      
      public function tenRewardExchangeButtonClick(checkedFlag:Boolean) : void
      {
         this.m_exchangeButtonClickFlag = checkedFlag;
      }
      
      public function getTenRewardExchangeButtonClickFlag() : Boolean
      {
         return this.m_exchangeButtonClickFlag;
      }
      
      private function setupAssets() : void
      {
         var asset:XML = null;
         this.m_featureConfigData["assets"] = new Object();
         for each(asset in this.m_featureXml.assets.asset)
         {
            this.m_featureConfigData["assets"][asset.@name] = asset.@path.toString();
         }
      }
      
      private function setupVip() : void
      {
         this.m_vip = SubscriptionsManager.instance.isSubscriber();
      }
      
      private function setupRewards1() : void
      {
         var rewardCategory:XML = null;
         var rewardType:String = null;
         var item:XML = null;
         var oldness:Boolean = false;
         var itemCode:String = null;
         this.m_featureConfigData["rewards"] = new Object();
         this.m_featureConfigData["newRewards"] = new Array();
         for each(rewardCategory in this.m_featureXml.divisions.division)
         {
            rewardType = rewardCategory.@name;
            this.m_featureConfigData["rewards"][rewardCategory.@name] = new Array();
            for each(item in rewardCategory.items.item)
            {
               oldness = item.@type.toString() == "old" ? true : false;
               itemCode = item.@code.toString();
               this.m_featureConfigData["rewards"][rewardCategory.@name].push({
                  "rewardItemName":itemCode,
                  "old":oldness,
                  "rewardType":rewardType
               });
               if(!oldness)
               {
                  this.m_featureConfigData["newRewards"].push({
                     "rewardItemName":itemCode,
                     "rewardType":rewardType
                  });
               }
            }
            this.m_featureConfigData["rewards"][rewardCategory.@name].sort(this.compareRewardByType);
         }
         this.m_featureConfigData["newRewards"].sort(this.compareRewardByNew);
      }
      
      private function compareRewardByType(a:Object, b:Object) : int
      {
         return a["old"] > b["old"] ? 1 : -1;
      }
      
      private function compareRewardByNew(a:Object, b:Object) : int
      {
         return a["rewardType"] < b["rewardType"] ? 1 : -1;
      }
      
      private function setupTokenMaxCount() : void
      {
         this.m_featureConfigData["tokenMaxCount"] = int(this.m_featureXml.constants.@maxEntries.toString());
         this.m_featureConfigData["tokenCountForSpin"] = int(this.m_featureXml.constants.@maxEntriesPerDay.toString());
      }
      
      private function setupCashAmount() : void
      {
         this.m_featureConfigData["paid1Cost"] = this.m_featureXml.@minCash.toString();
         this.m_featureConfigData["paid10Cost"] = this.m_featureXml.@maxCash.toString();
      }
      
      private function setupCountForEarnedSpin() : void
      {
         this.m_featureConfigData["countForEarnedSpin"] = this.m_featureXml.@stageUnlockCost.toString();
      }
      
      public function minCountForEarnedSpin() : int
      {
         return this.m_featureConfigData["countForEarnedSpin"];
      }
      
      public function tokenMaxCount() : int
      {
         return this.m_featureConfigData["tokenMaxCount"];
      }
      
      public function tokenCountForSpin() : int
      {
         return this.m_featureConfigData["tokenCountForSpin"];
      }
      
      public function getPaid1Cost() : String
      {
         return this.m_featureConfigData["paid1Cost"];
      }
      
      public function getPaid10Cost() : String
      {
         return this.m_featureConfigData["paid10Cost"];
      }
      
      private function setupFeedThrottle() : void
      {
         this.m_featureConfigData["feedThrottleTime"] = this.m_featureXml.feed.@throttleTime.toString();
      }
      
      private function setupTokenVisibleAfterSpinCount() : void
      {
         this.m_featureConfigData["tokenVisibileIndex"] = int(this.m_featureXml.constants.@visibleLevel.toString());
      }
      
      private function setupRewardExpiryFlag() : void
      {
         this.m_newRewardFlag = false;
         if(this.m_featureXml["constants"].hasOwnProperty("@endDate") && FarmGameUtil.synchronizedDateToNumber(this.m_featureXml.constants.@endDate.toString()) > GlobalEngine.serverTime)
         {
            this.m_newRewardFlag = true;
         }
      }
      
      public function areRewardsNew() : Boolean
      {
         return this.m_newRewardFlag;
      }
      
      public function isTokenFeatureAvailable() : Boolean
      {
         var result:Boolean = false;
         if(Global.player.getSeenFlag(m_featureName + "_tenSpinClick"))
         {
            result = true;
         }
         else if(this.m_spinCountsForTokenReference > this.m_featureConfigData["tokenVisibileIndex"])
         {
            result = true;
         }
         return result;
      }
      
      public function updateMainUI(featureData:Object) : void
      {
         this.m_mainUI.updateUI(featureData);
         if(!this.isTutorialSeen())
         {
            this.m_mainUI.resumeTut();
         }
      }
      
      public function getFeatureOption() : Object
      {
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,FEATURE_NAME);
         if(!featureData)
         {
            featureData = new Object();
            featureData[KEY_TOKEN_COUNT] = 0;
            featureData[KEY_VIP_SPIN_AVAILABLE] = this.m_vip;
            featureData[KEY_REWARD_STATE] = REWARD_UPDATED;
            featureData[KEY_SPIN_TYPE_EXECUTED_LAST] = 0;
            featureData[KEY_ULTRA_REWARD_FLAG] = 0;
            featureData[SPIN_VIP] = 0;
            featureData[SPIN_EARNED] = 0;
            featureData[SPIN_PAID_1] = 0;
            featureData[SPIN_PAID_10] = 0;
            featureData[SPIN_TOKEN] = 0;
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,FEATURE_NAME,featureData);
         }
         return featureData;
      }
      
      public function isVip() : Boolean
      {
         return this.m_vip;
      }
      
      public function getRewardsArray(rewardType:String) : Array
      {
         return this.m_featureConfigData["rewards"][rewardType];
      }
      
      public function getNewRewardsArray() : Array
      {
         return this.m_featureConfigData["newRewards"];
      }
      
      public function getMainWindowRewardsArray() : Array
      {
         return [{"rewardItemName":this.m_featureConfigData["rewards"]["rare"][1]["rewardItemName"]},{"rewardItemName":this.m_featureConfigData["rewards"]["superrare"][0]["rewardItemName"]},{"rewardItemName":this.m_featureConfigData["rewards"]["ultrarare"][0]["rewardItemName"]},{"rewardItemName":this.m_featureConfigData["rewards"]["superrare"][1]["rewardItemName"]},{"rewardItemName":this.m_featureConfigData["rewards"]["rare"][0]["rewardItemName"]}];
      }
      
      public function getRewardsForMotd() : Array
      {
         return [this.m_featureConfigData["rewards"]["ultrarare"][0]["rewardItemName"],this.m_featureConfigData["rewards"]["superrare"][0]["rewardItemName"],this.m_featureConfigData["rewards"]["superrare"][1]["rewardItemName"]];
      }
      
      public function bragFeed(item:FarmItem, rewardType:String) : void
      {
         var rewardTypeText:String = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_" + rewardType);
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}",
               "src":item.icon
            }],
            "first_name":Global.player.firstName,
            "reward_name":"Special reward",
            "rarity":rewardTypeText,
            "item":item.friendlyTitle
         };
         GlobalEngine.socialNetwork.publishFeedStory("subscriber_wallet_share_Reward",bundleData,[],false,null);
      }
      
      public function rewardStat(rewards:Object, spinType:int) : void
      {
         var rewardsStat:String = "";
         if(rewards.hasOwnProperty("common"))
         {
            rewardsStat += rewards["common"].length + ",";
         }
         else
         {
            rewardsStat += "0,";
         }
         if(rewards.hasOwnProperty("rare"))
         {
            rewardsStat += rewards["rare"].length + ",";
         }
         else
         {
            rewardsStat += "0,";
         }
         if(rewards.hasOwnProperty("superrare"))
         {
            rewardsStat += rewards["superrare"].length + ",";
         }
         else
         {
            rewardsStat += "0,";
         }
         if(rewards.hasOwnProperty("ultrarare"))
         {
            rewardsStat += rewards["ultrarare"].length + ",";
         }
         else
         {
            rewardsStat += "0";
         }
         FarmStatsManager.count(m_featureName,"rewards",this.m_spinNames[spinType],rewardsStat);
      }
   }
}

