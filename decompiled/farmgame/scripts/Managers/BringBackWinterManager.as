package Managers
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.*;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.BBWinterReskinnableWindow;
   import Widgets.Windows.BBWinterRewardWindow;
   import Widgets.Windows.BBWinterRewardWindowForBonusRwards;
   import Widgets.Windows.BringBackEasterRewardWindow;
   import Widgets.Windows.BringBackEasterWindow;
   import Widgets.Windows.BringBackWinterWindow;
   import ZLocalization.Utilities;
   import flash.utils.getDefinitionByName;
   
   public class BringBackWinterManager
   {
      
      protected static var m_instance:Object = new Object();
      
      private static const NUM_ADDITONAL_DAYS:int = 2;
      
      public static const SERVICE_CLASS:String = "BringBackChristmasService";
      
      public static const FEATURE_TIME_GATE_DATE:String = "12/31/2018";
      
      public static const ACTION_RECORD_SNOWFLAKE_ITEM_REQUEST:String = "recordSnowflakeItemRequest";
      
      public static const ACTION_GRANT_BONUS_REWARD:String = "grantBonusReward";
      
      public static const ACTION_GRANT_BONUS_FIRST_REWARD:String = "grantBonusFirstReward";
      
      public static const ACTION_GRANT_BONUS_SECOND_REWARD:String = "grantBonusSecondReward";
      
      public static const ACTION_GRANT_BONUS_THIRD_REWARD:String = "grantBonusThirdReward";
      
      public static const REWARD_PATH_FIRST_TIME:String = "reward_first_time";
      
      public static const REWARD_PATH:String = "reward";
      
      public static const STAGE_REWARD_PATH:String = "stage_reward";
      
      public static const BONUS_REWARD_PATH:String = "bonus_reward";
      
      public static const FEATURE_END_SEEN_FLAG:String = "LCO";
      
      public static const FEATURE_OPTIONS_KEY:String = "v6";
      
      private static const INDEX_LAST_COLLECTED_TS:String = "0";
      
      public static const INDEX_PINK_COUNT:String = "1";
      
      public static const INDEX_BLUE_COUNT:String = "2";
      
      public static const INDEX_GREEN_COUNT:String = "3";
      
      public static const INDEX_WHITE_COUNT:String = "4";
      
      public static const INDEX_POINTS_COUNT:String = "bonus";
      
      public static const INDEX_POINTS_MULTIPLIER:String = "bonusMultiplier";
      
      public static const INDEX_SEEN_BONUS_POPUP:String = "5";
      
      public static const INDEX_CLAIMED_REWARDS:String = "6";
      
      public static const INDEX_SEEN_BONUS_POPUP_FIRTS_STAGE:String = "7";
      
      public static const INDEX_SEEN_BONUS_POPUP_SECOND_STAGE:String = "8";
      
      public static const INDEX_SEEN_BONUS_POPUP_THIRD_STAGE:String = "9";
      
      public static const INDEX_HAS_COLLECTED_BONUS:String = "bonusReward";
      
      private static const SF_WHITE:String = "white";
      
      private static const SF_BLUE:String = "blue";
      
      private static const SF_GREEN:String = "green";
      
      public static const SF_PINK:String = "pink";
      
      private static const SF_BUNDLE:String = "bundle";
      
      public static const SF_WHITE_NAME:String = "santascompass";
      
      public static const SF_BLUE_NAME:String = "giftsack";
      
      public static const SF_GREEN_NAME:String = "greensnowflake";
      
      public static const SF_PINK_NAME:String = "intuitivecompass";
      
      public static const SF_WHITE_PKG:String = "pkg_whitesnowflake";
      
      public static const SF_BLUE_PKG:String = "pkg_bluesnowflake";
      
      public static const SF_GREEN_PKG:String = "pkg_greensnowflake";
      
      public static const SF_PINK_PKG:String = "pkg_pinksnowflake";
      
      public static const SF_BUNDLE_PKG:String = "pkg_snowflakebundle";
      
      public static const BRAG_FEED_TYPE:String = "BringBackChristmas_Brag";
      
      public static const BRAG_FEED_STAGE_TYPE:String = "BringBackChristmas_StageBrag";
      
      public static const BRAG_FEED_FINAL_BONUS_REWARD:String = "BringBackChristmas_bonusBrag";
      
      public static const BRAG_FEED_REWARD:String = "tubo";
      
      public static const RARE_ITEM_COLLECTABLE:String = "daily_collectable";
      
      public static const RARE_ITEM_NON_COLLECTABLE:String = "daily_non_collectable";
      
      public static const KINGDOME_NAME:String = "Royal_Wildlife";
      
      private static const WINDOW_CLASSES:Array = new Array(BBWinterReskinnableWindow,BringBackWinterWindow,BringBackEasterWindow);
      
      public static const SFTYPES:Array = new Array(SF_WHITE,SF_GREEN,SF_BLUE,SF_PINK);
      
      protected var m_featureName:String;
      
      protected var m_featureConfigData:Object;
      
      private var m_bringBackWinterWindow:BringBackEasterWindow;
      
      private var m_timeRequestedAt:Object = new Object();
      
      private var m_playerRank:Number;
      
      private var m_configManager:FeatureConfigManager;
      
      protected var m_bonusRewardName:String = null;
      
      public const ACTION_REDEEM_REWARD:String = "redeemReward";
      
      public const BUY_ITEM:String = "buyItem";
      
      private const ACTION_COLLECT_DAILY_SF:String = "collectDailySnowFlake";
      
      public const ACTION_POST_SF:String = "askForSnowFlake";
      
      private const ACTION_BUY_SF:String = "buyForSnowFlake";
      
      public const ACTION_SHARE_BRAG_FEED:String = "onBragFeed";
      
      public const ACTION_SHARE_STAGE_BRAG_FEED:String = "onStageBragFeed";
      
      public const ACTION_SHARE_BONUS_BRAG_FEED:String = "onBonusBragFeed";
      
      public function BringBackWinterManager(featureName:String)
      {
         super();
         this.m_featureName = featureName;
         this.m_configManager = FeatureConfigManager.getFeatureConfiguration(featureName);
         this.loadFeatureConfig();
      }
      
      public static function getInstance(featureName:String) : BringBackWinterManager
      {
         if(!m_instance.hasOwnProperty(featureName))
         {
            m_instance[featureName] = new BringBackWinterManager(featureName);
         }
         return m_instance[featureName];
      }
      
      public static function getSfTypeToPkg(sfType:String) : String
      {
         var sfPkg:String = null;
         switch(sfType)
         {
            case SF_BLUE:
               sfPkg = SF_BLUE_PKG;
               break;
            case SF_GREEN:
               sfPkg = SF_GREEN_PKG;
               break;
            case SF_PINK:
               sfPkg = SF_PINK_PKG;
               break;
            case SF_WHITE:
               sfPkg = SF_WHITE_PKG;
               break;
            case SF_BUNDLE:
               sfPkg = SF_BUNDLE_PKG;
               break;
            default:
               sfPkg = null;
         }
         return sfPkg;
      }
      
      public static function getSfTypeToItemName(sfType:String) : String
      {
         var sfPkg:String = null;
         switch(sfType)
         {
            case SF_BLUE:
               sfPkg = SF_BLUE_NAME;
               break;
            case SF_GREEN:
               sfPkg = SF_GREEN_NAME;
               break;
            case SF_PINK:
               sfPkg = SF_PINK_NAME;
               break;
            case SF_WHITE:
               sfPkg = SF_WHITE_NAME;
               break;
            default:
               sfPkg = null;
         }
         return sfPkg;
      }
      
      public static function getSftypeToFeatureDataIndex(sfType:String) : String
      {
         var index:String = null;
         switch(sfType)
         {
            case SF_BLUE:
               index = INDEX_BLUE_COUNT;
               break;
            case SF_GREEN:
               index = INDEX_GREEN_COUNT;
               break;
            case SF_PINK:
               index = INDEX_PINK_COUNT;
               break;
            case SF_WHITE:
               index = INDEX_WHITE_COUNT;
               break;
            default:
               index = null;
         }
         return index;
      }
      
      protected function loadFeatureConfig() : void
      {
         var itemXML:XML = null;
         var bonusRewardXML:XML = null;
         var listArray:Array = null;
         var bonusXML:XML = null;
         var rewardPkg:Object = null;
         var bonusRewardPkg:Object = null;
         var bonusInfo:String = null;
         var asset:XML = null;
         this.m_featureConfigData = new Object();
         this.m_featureConfigData.rewardPkgs = new Array();
         this.m_featureConfigData.bonusRewardPkgs = new Array();
         this.m_featureConfigData.bonusCollection = new Array();
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(this.m_featureName);
         if(featureXML != null)
         {
            this.m_featureConfigData.type = featureXML.@type.toString();
            this.m_featureConfigData.mainDialogPath = featureXML.UI.dialog.@path.toString();
            if(featureXML.UI.dialog.@className)
            {
               this.m_featureConfigData.className = featureXML.UI.dialog.@className.toString();
            }
            this.m_featureConfigData.windowName = featureXML.windowName.toString();
            for each(itemXML in featureXML.items.item)
            {
               rewardPkg = new Object();
               rewardPkg.name = itemXML.@name.toString();
               rewardPkg.bonus = Number(itemXML.@bonus);
               if(Boolean(itemXML.@blue.toString()) && itemXML.@blue.toString() != "")
               {
                  rewardPkg.blue = itemXML.@blue.toString();
               }
               if(Boolean(itemXML.@white.toString()) && itemXML.@white.toString() != "")
               {
                  rewardPkg.white = itemXML.@white.toString();
               }
               if(Boolean(itemXML.@green.toString()) && itemXML.@green.toString() != "")
               {
                  rewardPkg.green = itemXML.@green.toString();
               }
               if(Boolean(itemXML.@pink.toString()) && itemXML.@pink.toString() != "")
               {
                  rewardPkg.pink = itemXML.@pink.toString();
               }
               this.m_featureConfigData.rewardPkgs.push(rewardPkg);
            }
            for each(bonusRewardXML in featureXML.rewards.reward)
            {
               bonusRewardPkg = new Object();
               bonusRewardPkg.stage = bonusRewardXML.@stage;
               bonusRewardPkg.name = bonusRewardXML.@name.toString();
               bonusRewardPkg.qty = bonusRewardXML.@qty;
               bonusRewardPkg.badgeName = bonusRewardXML.@type.toString();
               bonusRewardPkg.quantity = bonusRewardXML.@quantity;
               this.m_featureConfigData.bonusRewardPkgs.push(bonusRewardPkg);
            }
            if(featureXML.bonusReward)
            {
               this.m_bonusRewardName = featureXML.bonusReward.@name.toString();
            }
            listArray = Utilities.xmlListToArray(featureXML.divisions.division);
            for each(bonusXML in listArray[0].items.item)
            {
               bonusInfo = "";
               bonusInfo = String(bonusXML.@name);
               this.m_featureConfigData.bonusCollection.push(bonusInfo);
            }
            if(featureXML.assets)
            {
               this.m_featureConfigData.assetPaths = new Object();
               for each(asset in featureXML.assets.asset)
               {
                  this.m_featureConfigData.assetPaths[asset.@name] = asset.@path;
               }
            }
         }
      }
      
      public function getBonusRewards() : Array
      {
         return this.m_featureConfigData.bonusCollection;
      }
      
      public function getMainDialogURL() : String
      {
         return this.m_featureConfigData.mainDialogPath;
      }
      
      public function getWindowClassName() : String
      {
         var className:String = null;
         if(this.m_featureConfigData.hasOwnProperty("className"))
         {
            className = this.m_featureConfigData.className;
         }
         return className;
      }
      
      public function getWindowName() : String
      {
         return this.m_featureConfigData.windowName;
      }
      
      public function handleHUDClick() : void
      {
         var windowClass:Class = null;
         var className:String = this.getWindowClassName();
         var collectionData:Object = this.getFeatureData();
         if(Boolean(this.m_bonusRewardName) && Boolean(this.hasCollectedAllItems()) && !collectionData[INDEX_SEEN_BONUS_POPUP])
         {
            collectionData[INDEX_SEEN_BONUS_POPUP] = true;
            collectionData[INDEX_SEEN_BONUS_POPUP_FIRTS_STAGE] = true;
            collectionData[INDEX_SEEN_BONUS_POPUP_SECOND_STAGE] = true;
            collectionData[INDEX_SEEN_BONUS_POPUP_THIRD_STAGE] = true;
            FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,FEATURE_OPTIONS_KEY,collectionData);
         }
         else if(className)
         {
            windowClass = getDefinitionByName(className) as Class;
            UI.displayPopup(this.m_bringBackWinterWindow = new windowClass(this.m_featureName));
         }
         else
         {
            UI.displayMessage("className for the feature window is not defined",GenericPopup.TYPE_OK,null,"",true);
         }
      }
      
      private function onGrantBonusReward(result:Object = null) : void
      {
         Global.player.addGift(this.m_bonusRewardName);
         UI.displayPopup(new BBWinterRewardWindow(BONUS_REWARD_PATH,this.m_featureName,this.m_bonusRewardName,1,true),false);
      }
      
      private function onGrantBonusRewardPkg(bonusRewardPkg:Object = null) : void
      {
         Global.player.addGift(bonusRewardPkg.name,"",bonusRewardPkg.qty);
         UI.displayPopup(new BBWinterRewardWindowForBonusRwards(STAGE_REWARD_PATH,this.m_featureName,bonusRewardPkg.name),false);
      }
      
      public function getBonusReward() : String
      {
         return this.m_bonusRewardName;
      }
      
      public function getRewardPkgs() : Array
      {
         return this.m_featureConfigData.rewardPkgs;
      }
      
      public function getBonusRewardPkgs() : Array
      {
         return this.m_featureConfigData.bonusRewardPkgs;
      }
      
      public function getRewardDialogPathFor(type:String) : String
      {
         var assetPath:String = null;
         if(Boolean(this.m_featureConfigData.assetPaths) && Boolean(this.m_featureConfigData.assetPaths[type]))
         {
            assetPath = this.m_featureConfigData.assetPaths[type];
         }
         return assetPath;
      }
      
      public function redeemRewardForSnowFlakes(rewardData:Object) : void
      {
         var collectionData:Object = null;
         var i:int = 0;
         var rewardName:String = null;
         var rewardCode:String = null;
         var rewardAssetKey:String = null;
         var showAnimation:Boolean = false;
         var multiplier:Number = NaN;
         var index:int = 0;
         var rewardPkg:Object = null;
         var itemIndex:int = 0;
         var sfType:String = null;
         var featureDataIndex:String = null;
         var bonusRewardPks1:Array = null;
         var bonusRewardPkg1:Object = null;
         var bonusRewardPks2:Array = null;
         var bonusRewardPkg2:Object = null;
         var bonusRewardPks3:Array = null;
         var bonusRewardPkg3:Object = null;
         if(this.areSnowFlakeReqsMetFor(rewardData))
         {
            collectionData = this.getFeatureData();
            for(i = 0; i < SFTYPES.length; i++)
            {
               sfType = SFTYPES[i];
               if(rewardData.hasOwnProperty(sfType))
               {
                  featureDataIndex = getSftypeToFeatureDataIndex(sfType);
                  if(Boolean(featureDataIndex) && collectionData.hasOwnProperty(featureDataIndex))
                  {
                     collectionData[featureDataIndex] -= rewardData[sfType];
                  }
               }
            }
            collectionData[INDEX_POINTS_COUNT] += rewardData[INDEX_POINTS_COUNT] * collectionData[INDEX_POINTS_MULTIPLIER];
            rewardName = rewardData.name;
            rewardCode = Global.farmGameSettingsManager.getFarmItemCodeByName(rewardName);
            rewardAssetKey = collectionData.hasOwnProperty(rewardCode) ? REWARD_PATH : REWARD_PATH_FIRST_TIME;
            showAnimation = rewardAssetKey == REWARD_PATH ? false : true;
            collectionData[rewardCode] = true;
            collectionData[INDEX_CLAIMED_REWARDS][rewardCode] = true;
            FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,FEATURE_OPTIONS_KEY,collectionData);
            Global.player.addGift(rewardName);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,this.ACTION_REDEEM_REWARD,this.onRedeemReward,[rewardName,this.m_featureName]));
            multiplier = Number(collectionData[INDEX_POINTS_MULTIPLIER]);
            if(!this.isFeatureEnd())
            {
               if(Boolean(this.m_bonusRewardName) && Boolean(this.hasCollectedAllItems()) && !collectionData[INDEX_SEEN_BONUS_POPUP])
               {
                  collectionData[INDEX_SEEN_BONUS_POPUP] = true;
                  FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,FEATURE_OPTIONS_KEY,collectionData);
               }
               else if(this.hasCollectedFourItems() && !collectionData[INDEX_SEEN_BONUS_POPUP_FIRTS_STAGE])
               {
                  collectionData[INDEX_SEEN_BONUS_POPUP_FIRTS_STAGE] = true;
                  collectionData[INDEX_POINTS_MULTIPLIER] = 2;
                  FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,FEATURE_OPTIONS_KEY,collectionData);
                  bonusRewardPks1 = this.getBonusRewardPkgs();
                  bonusRewardPkg1 = bonusRewardPks1[0];
                  this.onGrantBonusRewardPkg(bonusRewardPkg1);
               }
               else if(this.hasCollectedTenItems() && !collectionData[INDEX_SEEN_BONUS_POPUP_SECOND_STAGE])
               {
                  collectionData[INDEX_SEEN_BONUS_POPUP_SECOND_STAGE] = true;
                  collectionData[INDEX_POINTS_MULTIPLIER] = 3;
                  FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,FEATURE_OPTIONS_KEY,collectionData);
                  bonusRewardPks2 = this.getBonusRewardPkgs();
                  bonusRewardPkg2 = bonusRewardPks2[1];
                  this.onGrantBonusRewardPkg(bonusRewardPkg2);
               }
               else if(this.hasCollectedSixteenItems() && !collectionData[INDEX_SEEN_BONUS_POPUP_THIRD_STAGE])
               {
                  collectionData[INDEX_SEEN_BONUS_POPUP_THIRD_STAGE] = true;
                  collectionData[INDEX_POINTS_MULTIPLIER] = 4;
                  FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,FEATURE_OPTIONS_KEY,collectionData);
                  bonusRewardPks3 = this.getBonusRewardPkgs();
                  bonusRewardPkg3 = bonusRewardPks3[2];
                  this.onGrantBonusRewardPkg(bonusRewardPkg3);
               }
               if(this.hasCollectedAllItems() && collectionData[INDEX_HAS_COLLECTED_BONUS] == 0)
               {
                  if(!this.hasTimeGatePassed())
                  {
                     this.grantBonusItem(3);
                     UI.displayPopup(new BringBackEasterRewardWindow("bonus_reward",this.m_featureName),false);
                  }
                  else
                  {
                     UI.displayPopup(new BringBackEasterRewardWindow("bonus_reward",this.m_featureName,null,true),false);
                  }
                  FarmStatsManager.count("GPF_royalrescue2018","featurecomplete");
               }
            }
            index = 0;
            for each(rewardPkg in this.getRewardPkgs())
            {
               if(rewardPkg.name == rewardName)
               {
                  break;
               }
               index++;
            }
            itemIndex = 0;
            itemIndex = index;
            index = index == 18 || rewardAssetKey == REWARD_PATH ? -1 : int(index);
            if(this.getRewardDialogPathFor(rewardAssetKey) != null)
            {
               UI.displayPopup(new BBWinterRewardWindow(rewardAssetKey,this.m_featureName,rewardName,multiplier,false,index + 1,itemIndex),false);
            }
            if(this.m_bringBackWinterWindow)
            {
               this.m_bringBackWinterWindow.update();
            }
         }
      }
      
      public function grantBonusItem(bonusNo:int = 0) : void
      {
         var collectionData:Object = this.getFeatureData();
         var bonusCollection:Array = this.getBonusRewards();
         if(collectionData[INDEX_HAS_COLLECTED_BONUS] == 0)
         {
            if(bonusNo == 1 || bonusNo == 3)
            {
               Global.player.addGift(bonusCollection[0]);
            }
            if(bonusNo == 2 || bonusNo == 3)
            {
               Global.player.addGift(bonusCollection[1]);
            }
            collectionData[INDEX_HAS_COLLECTED_BONUS] = bonusNo;
            FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,FEATURE_OPTIONS_KEY,collectionData);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"GrantCollectionCompletionBonus",this.onBuySuccess,[this.m_featureName,bonusNo]));
         }
         FarmStatsManager.count("GPF_royalrescue2018","grantBonus",bonusNo.toString());
      }
      
      public function updateMainWindow() : void
      {
         if(this.m_bringBackWinterWindow)
         {
            this.m_bringBackWinterWindow.update();
         }
      }
      
      public function hasBonusBeenGranted() : int
      {
         var collectionData:Object = this.getFeatureData();
         if(!collectionData.hasOwnProperty(INDEX_HAS_COLLECTED_BONUS))
         {
            collectionData[INDEX_HAS_COLLECTED_BONUS] = 0;
            FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,FEATURE_OPTIONS_KEY,collectionData);
         }
         return collectionData[INDEX_HAS_COLLECTED_BONUS];
      }
      
      public function onRedeemReward(result:Object) : void
      {
      }
      
      public function buyCollectionItem(itemName:String) : void
      {
         var buyResult:Boolean = false;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         if(Global.player.canBuyCash(item.cash))
         {
            buyResult = Global.player.tryBuy(null,false,item,0);
            if(buyResult)
            {
               this.onGrantItemSuccess(itemName);
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,this.BUY_ITEM,this.onBuySuccess,[itemName,this.m_featureName]));
            }
         }
      }
      
      private function onBuySuccess(result:Object) : void
      {
      }
      
      private function onGrantItemSuccess(itemName:String) : void
      {
         var points:Number = NaN;
         var rewardPkg:Object = null;
         var multiplier:Number = NaN;
         Global.player.addGift(itemName);
         var collectionData:Object = this.getFeatureData();
         var index:int = 0;
         for each(rewardPkg in this.getRewardPkgs())
         {
            if(rewardPkg.name == itemName)
            {
               points = Number(rewardPkg.bonus);
               break;
            }
            index++;
         }
         collectionData[INDEX_POINTS_COUNT] += points * collectionData[INDEX_POINTS_MULTIPLIER];
         multiplier = Number(collectionData[INDEX_POINTS_MULTIPLIER]);
         FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,FEATURE_OPTIONS_KEY,collectionData);
         if(this.getRewardDialogPathFor(REWARD_PATH) != null)
         {
            UI.displayPopup(new BBWinterRewardWindow(REWARD_PATH,this.m_featureName,itemName,multiplier,false,0,index),false);
         }
      }
      
      public function shareBragFeed(rewardName:String) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,this.ACTION_SHARE_BRAG_FEED,this.onShareBragFeed,[this.m_featureName,rewardName]));
      }
      
      private function onShareBragFeed(result:Object) : void
      {
         var rewardName:String = result.rewardName;
         var rewardLink:String = result.rewardLink;
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
         var shareItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(BringBackWinterManager.BRAG_FEED_REWARD);
         var bundleData:Object = {
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":rewardItem.icon
            }],
            "rewardName":rewardItem.friendlyTitle,
            "itemName":shareItem.friendlyTitle
         };
         GlobalEngine.socialNetwork.publishFeedStory(BringBackWinterManager.BRAG_FEED_TYPE,bundleData,[],false);
      }
      
      public function shareStageBragFeed(rewardName:String) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,this.ACTION_SHARE_STAGE_BRAG_FEED,this.onShareStageBragFeed,[this.m_featureName,rewardName]));
      }
      
      private function onShareStageBragFeed(result:Object) : void
      {
         var rewardName:String = result.rewardName;
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
         var shareItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(BringBackWinterManager.BRAG_FEED_REWARD);
         var stageNumCompleted:int = this.getNumofStageCompleted();
         var bonusRewardPkg:Array = this.getBonusRewardPkgs();
         var qty1:int = int(bonusRewardPkg[0]["quantity"]);
         var qty2:int = int(bonusRewardPkg[1]["quantity"]);
         var qty3:int = int(bonusRewardPkg[2]["quantity"]);
         var stageName:String = "";
         var numOfPets:int = 0;
         var imagePath:String = null;
         var imageURL:String = null;
         switch(stageNumCompleted)
         {
            case 1:
               stageName = "GIFT HUNTER AMATEUR";
               numOfPets = qty1;
               imagePath = "assets/dialogs/RoyalRescue_KringleHunt/UI/master-assets/FB_feed_Badge1.jpg";
               imageURL = Global.getAssetURL(imagePath);
               FarmStatsManager.count("GPF_royalrescue2018","Milestone","1");
               break;
            case 2:
               stageName = "GIFT HUNTER VETERAN";
               numOfPets = qty2;
               imagePath = "assets/dialogs/RoyalRescue_KringleHunt/UI/master-assets/FB_feed_Badge2.jpg";
               imageURL = Global.getAssetURL(imagePath);
               FarmStatsManager.count("GPF_royalrescue2018","Milestone","2");
               break;
            case 3:
               stageName = "GIFT HUNTER LEGEND";
               numOfPets = qty3;
               imagePath = "assets/dialogs/RoyalRescue_KringleHunt/UI/master-assets/FB_feed_Badge3.jpg";
               imageURL = Global.getAssetURL(imagePath);
               FarmStatsManager.count("GPF_royalrescue2018","Milestone","3");
         }
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}",
               "src":imageURL
            }],
            "rewardName":rewardItem.friendlyTitle,
            "itemName":shareItem.friendlyTitle,
            "stageName":stageName,
            "numOfPets":numOfPets
         };
         GlobalEngine.socialNetwork.publishFeedStory(BringBackWinterManager.BRAG_FEED_STAGE_TYPE,bundleData,[],false);
      }
      
      public function shareBonusBragFeed(rewardName:String) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,this.ACTION_SHARE_BRAG_FEED,this.onShareBonusBragFeed,[this.m_featureName,rewardName]));
      }
      
      private function onShareBonusBragFeed(result:Object) : void
      {
         var rewardName:String = result.rewardName;
         var rewardLink:String = result.rewardLink;
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
         var shareItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(BringBackWinterManager.BRAG_FEED_REWARD);
         var bundleData:Object = {
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":rewardItem.icon
            }],
            "rewardName":rewardItem.friendlyTitle,
            "itemName":shareItem.friendlyTitle
         };
         GlobalEngine.socialNetwork.publishFeedStory(BringBackWinterManager.BRAG_FEED_FINAL_BONUS_REWARD,bundleData,[],false);
      }
      
      public function areSnowFlakeReqsMetFor(rewardData:Object) : Boolean
      {
         var sfType:String = null;
         var featureDataIndex:String = null;
         var sfCount:int = 0;
         var canredeem:Boolean = true;
         var collectionData:Object = this.getFeatureData();
         for(var i:int = 0; i < SFTYPES.length; i++)
         {
            sfType = SFTYPES[i];
            if(rewardData.hasOwnProperty(sfType))
            {
               featureDataIndex = getSftypeToFeatureDataIndex(sfType);
               if(!(Boolean(featureDataIndex) && collectionData.hasOwnProperty(featureDataIndex)))
               {
                  canredeem = false;
                  break;
               }
               sfCount = parseInt(collectionData[featureDataIndex]);
               if(sfCount < parseInt(rewardData[sfType]))
               {
                  canredeem = false;
                  break;
               }
            }
         }
         return canredeem;
      }
      
      public function collectDailySnowFlake() : void
      {
         var collectionData:Object = null;
         var success:Boolean = false;
         if(this.canCollectDailySnowFlake())
         {
            collectionData = this.getFeatureData();
            collectionData[INDEX_LAST_COLLECTED_TS] = GlobalEngine.serverTime / 1000;
            collectionData[INDEX_PINK_COUNT] += 1;
            FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,FEATURE_OPTIONS_KEY,collectionData);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,this.ACTION_COLLECT_DAILY_SF,null,[this.m_featureName]));
            success = true;
         }
      }
      
      public function canCollectDailySnowFlake() : Boolean
      {
         var collectionData:Object = null;
         var offsetSec:int = 0;
         var collectedDayNum:int = 0;
         var currentDayNum:int = 0;
         var success:Boolean = false;
         var type:String = this.m_featureConfigData.type;
         var isCollectable:Boolean = type == RARE_ITEM_NON_COLLECTABLE ? false : true;
         if(isCollectable && !this.isFeatureEnd())
         {
            collectionData = this.getFeatureData();
            offsetSec = FarmGameUtil.getGlobalServerUTCOffsetHours() * 3600;
            collectedDayNum = Math.floor((collectionData[INDEX_LAST_COLLECTED_TS] - offsetSec) / FarmGameUtil.NUM_SECS_IN_DAY);
            currentDayNum = Math.floor((GlobalEngine.serverTime / 1000 - offsetSec) / FarmGameUtil.NUM_SECS_IN_DAY);
            if(currentDayNum > collectedDayNum)
            {
               success = true;
            }
         }
         return success;
      }
      
      public function timeForNextDailyCollect() : Array
      {
         var offsetSec:int = FarmGameUtil.getGlobalServerUTCOffsetHours() * 3600;
         var currentDayNum:int = Math.floor((GlobalEngine.serverTime / 1000 - offsetSec) / FarmGameUtil.NUM_SECS_IN_DAY);
         var cTime:int = Math.floor(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND) - offsetSec;
         var intervel:int = Math.ceil((currentDayNum + 1) * FarmGameUtil.NUM_SECS_IN_DAY - cTime);
         return FarmGameUtil.parseTimeLeft(intervel);
      }
      
      public function shareBonusFeed(bonusNo:int) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,this.ACTION_SHARE_BONUS_BRAG_FEED,this.onShareBonusFeed,[this.m_featureName,bonusNo]));
      }
      
      private function onShareBonusFeed(result:Object) : void
      {
         var rewardItem:FarmItem = null;
         var rewardItem2:FarmItem = null;
         var rewardName:String = "";
         var rewardLink:String = result.rewardLink;
         var shareItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(BringBackWinterManager.BRAG_FEED_REWARD);
         var stageName:String = "";
         var numOfPets:int = 0;
         var imagePath:String = null;
         var friendlyName:String = "";
         var imageURL:String = null;
         var bonusCollection:Array = this.getBonusRewards();
         switch(result.bonusNo)
         {
            case 1:
               rewardName = bonusCollection[0];
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
               friendlyName = rewardItem.friendlyTitle;
               imageURL = rewardItem.icon;
               break;
            case 2:
               rewardName = bonusCollection[1];
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
               friendlyName = rewardItem.friendlyTitle;
               imageURL = rewardItem.icon;
               break;
            case 3:
               rewardName = bonusCollection[0];
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
               rewardName = bonusCollection[1];
               rewardItem2 = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
               friendlyName = rewardItem.friendlyTitle + " and " + rewardItem2.friendlyTitle;
               imagePath = "assets/dialogs/RoyalRescue_KringleHunt/UI/master-assets/FB_feed_BonusBoth.jpg";
               imageURL = Global.getAssetURL(imagePath);
         }
         var bundleData:Object = {
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":imageURL
            }],
            "rewardName":friendlyName,
            "itemName":shareItem.friendlyTitle
         };
         GlobalEngine.socialNetwork.publishFeedStory(BringBackWinterManager.BRAG_FEED_FINAL_BONUS_REWARD,bundleData,[],false);
      }
      
      public function getSfCollectionCount(sfType:String) : int
      {
         var collectionData:Object = this.getFeatureData();
         var featureDataIndex:String = getSftypeToFeatureDataIndex(sfType);
         if(Boolean(collectionData) && Boolean(sfType) && Boolean(featureDataIndex))
         {
            return collectionData[featureDataIndex];
         }
         return 0;
      }
      
      public function getPointMultiplierCount() : Number
      {
         var collectionData:Object = this.getFeatureData();
         if(Boolean(collectionData) && Boolean(collectionData[INDEX_POINTS_MULTIPLIER]))
         {
            return collectionData[INDEX_POINTS_MULTIPLIER];
         }
         return 1;
      }
      
      public function postSf(itemCode:String, callback:Function) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,this.ACTION_POST_SF,callback,[itemCode]));
      }
      
      public function buySf(sfPkg:String) : void
      {
         var sfPkgitem:FarmItem = null;
         if(sfPkg)
         {
            sfPkgitem = Global.farmGameSettingsManager.getFarmItemByName(sfPkg);
            if(sfPkgitem)
            {
               Global.player.buyFarmItem(sfPkgitem,Currency.CASH,1,true,false,true,this.sfPurchaseSuccess);
               FarmStatsManager.count("fv_cash_buy",KINGDOME_NAME,sfPkg,sfPkgitem.cost.toString());
            }
         }
      }
      
      public function sfPurchaseSuccess(result:Object = null) : void
      {
         UI.displayMessage(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"bbwinter_purchase_success"),GenericPopup.TYPE_OK,null,"",true);
         if(this.m_bringBackWinterWindow != null)
         {
            this.m_bringBackWinterWindow.update();
         }
      }
      
      public function setPlayerRank(rank:Number = 0) : void
      {
         this.m_playerRank = rank;
      }
      
      public function getPlayerRank() : Number
      {
         return this.m_playerRank;
      }
      
      public function getFeatureData(shouldCreate:Boolean = true) : Object
      {
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureName,FEATURE_OPTIONS_KEY);
         if(data == null && shouldCreate)
         {
            data = new Object();
            data[INDEX_LAST_COLLECTED_TS] = 0;
            data[INDEX_PINK_COUNT] = 0;
            data[INDEX_BLUE_COUNT] = 0;
            data[INDEX_GREEN_COUNT] = 0;
            data[INDEX_WHITE_COUNT] = 0;
            data[INDEX_POINTS_COUNT] = 0;
            data[INDEX_POINTS_MULTIPLIER] = 1;
            data[INDEX_SEEN_BONUS_POPUP_FIRTS_STAGE] = false;
            data[INDEX_SEEN_BONUS_POPUP_SECOND_STAGE] = false;
            data[INDEX_SEEN_BONUS_POPUP_THIRD_STAGE] = false;
            data[INDEX_SEEN_BONUS_POPUP] = false;
            data[INDEX_CLAIMED_REWARDS] = {};
            data[INDEX_HAS_COLLECTED_BONUS] = 0;
         }
         if(data)
         {
            if(!data.hasOwnProperty(INDEX_SEEN_BONUS_POPUP_FIRTS_STAGE))
            {
               data[INDEX_SEEN_BONUS_POPUP_FIRTS_STAGE] = false;
            }
            if(!data.hasOwnProperty(INDEX_SEEN_BONUS_POPUP_SECOND_STAGE))
            {
               data[INDEX_SEEN_BONUS_POPUP_SECOND_STAGE] = false;
            }
            if(!data.hasOwnProperty(INDEX_SEEN_BONUS_POPUP_SECOND_STAGE))
            {
               data[INDEX_SEEN_BONUS_POPUP_THIRD_STAGE] = false;
            }
            if(!data.hasOwnProperty(INDEX_SEEN_BONUS_POPUP))
            {
               data[INDEX_SEEN_BONUS_POPUP] = false;
            }
            if(!data.hasOwnProperty(INDEX_CLAIMED_REWARDS))
            {
               data[INDEX_CLAIMED_REWARDS] = {};
            }
            if(!data.hasOwnProperty(INDEX_HAS_COLLECTED_BONUS))
            {
               data[INDEX_HAS_COLLECTED_BONUS] = 0;
            }
         }
         return data;
      }
      
      public function canPostSnowFlake(itemCode:String) : Boolean
      {
         var actionKey:String = null;
         var timeLimitKey:String = null;
         var timeLimit:Number = NaN;
         var intervalLimitKey:String = null;
         var todaysCount:int = 0;
         var maxCount:int = 0;
         var result:Boolean = true;
         if(this.isFeatureEnd())
         {
            result = false;
         }
         else
         {
            actionKey = this.getActionCountKey(itemCode);
            timeLimitKey = actionKey + this.getTimeIntervalSuffix();
            timeLimit = Global.farmGameSettingsManager.getInt(timeLimitKey,21600);
            intervalLimitKey = actionKey + this.getIntervalLimitSuffix();
            todaysCount = Global.player.getIntervalActionCount(actionKey,timeLimit);
            maxCount = Global.farmGameSettingsManager.getInt(intervalLimitKey,1);
            if(todaysCount >= maxCount)
            {
               result = false;
            }
         }
         return result;
      }
      
      public function getTimeUntilPostFeedEnabled(itemCode:String) : Array
      {
         var actionKey:String = this.getActionCountKey(itemCode);
         var timeLimitKey:String = actionKey + this.getTimeIntervalSuffix();
         var timeLimit:Number = Global.farmGameSettingsManager.getInt(timeLimitKey,21600);
         var last:int = Global.player.getFeatureLastShown(actionKey);
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(actionKey);
         var result:int = timeLimit - timeSinceLastFeed;
         return FarmGameUtil.parseTimeLeft(result);
      }
      
      private function getIntervalLimitSuffix() : String
      {
         return "_IntervalLimit";
      }
      
      private function getTimeIntervalSuffix() : String
      {
         return "_TimeInterval";
      }
      
      public function getActionCountKey(itemCode:String) : String
      {
         return this.m_featureName + "_" + itemCode;
      }
      
      public function registerFeedPublishSuccess(itemCode:String) : void
      {
         var actionCountKey:String = this.getActionCountKey(itemCode);
         Global.player.incrementIntervalActionCount(actionCountKey,Global.farmGameSettingsManager.getInt(actionCountKey + this.getTimeIntervalSuffix(),21600));
      }
      
      public function getTimeRemaining() : Array
      {
         var remainingDay:int = 0;
         var remainingTime:Array = this.m_configManager.getTimeRemaining();
         if(parseInt(remainingTime[0]) > NUM_ADDITONAL_DAYS)
         {
            remainingDay = parseInt(remainingTime[0]) - NUM_ADDITONAL_DAYS + 1;
            remainingTime[0] = remainingDay.toString();
         }
         else if(parseInt(remainingTime[0]) == NUM_ADDITONAL_DAYS)
         {
            remainingTime[0] = "0";
         }
         return remainingTime;
      }
      
      public function getTimeRemainingInString() : String
      {
         var remainingTime:Array = null;
         var result:String = "0 Hours";
         if(!this.isFeatureEnd())
         {
            remainingTime = this.m_configManager.getTimeRemaining();
            if(remainingTime[0] >= NUM_ADDITONAL_DAYS)
            {
               remainingTime[0] -= NUM_ADDITONAL_DAYS;
               result = FarmGameUtil.getFormattedTimeLeftText(remainingTime);
            }
         }
         return result;
      }
      
      public function isFeatureEnd() : Boolean
      {
         var remainingTime:Array = this.m_configManager.getTimeRemaining();
         return parseInt(remainingTime[0]) < NUM_ADDITONAL_DAYS;
      }
      
      public function getFeatureDurationDays() : int
      {
         var duration:Array = this.m_configManager.getFeatureDuration();
         var durationDays:int = parseInt(duration[0]) - NUM_ADDITONAL_DAYS;
         if(durationDays <= 0)
         {
            return 0;
         }
         return durationDays;
      }
      
      public function getElapsedDays() : int
      {
         var timeElapsed:Array = this.getTimeElapsed();
         return parseInt(timeElapsed[0]);
      }
      
      public function getTimeElapsed() : Array
      {
         return FarmGameUtil.parseTimeLeft(this.m_configManager.getTimeElapsedMS() / 1000);
      }
      
      public function onWindowClose() : void
      {
         this.m_bringBackWinterWindow = null;
      }
      
      public function hasCollectedFourItems() : Boolean
      {
         var rewardPkg:Object = null;
         var bonusRewardPkg:Array = null;
         var rewardCode:String = null;
         var result:Boolean = false;
         var counter:int = 0;
         var qty:int = 4;
         var collectionData:Object = this.getFeatureData();
         for each(rewardPkg in this.getRewardPkgs())
         {
            rewardCode = Global.farmGameSettingsManager.getFarmItemCodeByName(rewardPkg.name);
            if(Boolean(collectionData) && Boolean(collectionData[INDEX_CLAIMED_REWARDS]) && Boolean(collectionData[INDEX_CLAIMED_REWARDS].hasOwnProperty(rewardCode)))
            {
               counter++;
            }
         }
         bonusRewardPkg = this.getBonusRewardPkgs();
         qty = int(bonusRewardPkg[0]["quantity"]);
         if(counter == qty)
         {
            result = true;
         }
         return result;
      }
      
      public function getNumberOfCollectedItems() : Number
      {
         var rewardPkg:Object = null;
         var rewardCode:String = null;
         var counter:Number = 0;
         var qty:int = 4;
         var collectionData:Object = this.getFeatureData();
         for each(rewardPkg in this.getRewardPkgs())
         {
            rewardCode = Global.farmGameSettingsManager.getFarmItemCodeByName(rewardPkg.name);
            if(Boolean(collectionData) && Boolean(collectionData[INDEX_CLAIMED_REWARDS]) && Boolean(collectionData[INDEX_CLAIMED_REWARDS].hasOwnProperty(rewardCode)))
            {
               counter++;
            }
         }
         return counter;
      }
      
      public function hasCollectedTenItems() : Boolean
      {
         var rewardPkg:Object = null;
         var bonusRewardPkg:Array = null;
         var rewardCode:String = null;
         var result:Boolean = false;
         var counter:int = 0;
         var qty:int = 10;
         var collectionData:Object = this.getFeatureData();
         for each(rewardPkg in this.getRewardPkgs())
         {
            rewardCode = Global.farmGameSettingsManager.getFarmItemCodeByName(rewardPkg.name);
            if(Boolean(collectionData) && Boolean(collectionData[INDEX_CLAIMED_REWARDS]) && Boolean(collectionData[INDEX_CLAIMED_REWARDS].hasOwnProperty(rewardCode)))
            {
               counter++;
            }
         }
         bonusRewardPkg = this.getBonusRewardPkgs();
         qty = int(bonusRewardPkg[1]["quantity"]);
         if(counter == qty)
         {
            result = true;
         }
         return result;
      }
      
      public function hasCollectedEighteenItems() : Boolean
      {
         var rewardPkg:Object = null;
         var bonusRewardPkg:Array = null;
         var rewardCode:String = null;
         var result:Boolean = false;
         var counter:int = 0;
         var qty:int = 18;
         var collectionData:Object = this.getFeatureData();
         for each(rewardPkg in this.getRewardPkgs())
         {
            rewardCode = Global.farmGameSettingsManager.getFarmItemCodeByName(rewardPkg.name);
            if(Boolean(collectionData) && Boolean(collectionData[INDEX_CLAIMED_REWARDS]) && Boolean(collectionData[INDEX_CLAIMED_REWARDS].hasOwnProperty(rewardCode)))
            {
               counter++;
            }
         }
         bonusRewardPkg = this.getBonusRewardPkgs();
         qty = int(bonusRewardPkg[2]["quantity"]);
         if(counter == qty)
         {
            result = true;
         }
         return result;
      }
      
      public function hasCollectedSixteenItems() : Boolean
      {
         var rewardPkg:Object = null;
         var bonusRewardPkg:Array = null;
         var rewardCode:String = null;
         var result:Boolean = false;
         var counter:int = 0;
         var qty:int = 16;
         var collectionData:Object = this.getFeatureData();
         for each(rewardPkg in this.getRewardPkgs())
         {
            rewardCode = Global.farmGameSettingsManager.getFarmItemCodeByName(rewardPkg.name);
            if(Boolean(collectionData) && Boolean(collectionData[INDEX_CLAIMED_REWARDS]) && Boolean(collectionData[INDEX_CLAIMED_REWARDS].hasOwnProperty(rewardCode)))
            {
               counter++;
            }
         }
         bonusRewardPkg = this.getBonusRewardPkgs();
         qty = int(bonusRewardPkg[2]["quantity"]);
         if(counter == qty)
         {
            result = true;
         }
         return result;
      }
      
      public function hasCollectedAllItems() : Boolean
      {
         var rewardPkg:Object = null;
         var rewardCode:String = null;
         var result:Boolean = true;
         var collectionData:Object = this.getFeatureData();
         for each(rewardPkg in this.getRewardPkgs())
         {
            rewardCode = Global.farmGameSettingsManager.getFarmItemCodeByName(rewardPkg.name);
            if(!(Boolean(collectionData) && Boolean(collectionData[INDEX_CLAIMED_REWARDS]) && Boolean(collectionData[INDEX_CLAIMED_REWARDS].hasOwnProperty(rewardCode))))
            {
               result = false;
               break;
            }
         }
         return result;
      }
      
      public function hasCollectedItem(name:String) : Boolean
      {
         var rewardPkg:Object = null;
         var result:Boolean = false;
         var collectionData:Object = this.getFeatureData();
         var rewardCode:String = null;
         for each(rewardPkg in this.getRewardPkgs())
         {
            if(Boolean(rewardPkg) && rewardPkg.name == name)
            {
               rewardCode = Global.farmGameSettingsManager.getFarmItemCodeByName(rewardPkg.name);
               if(Boolean(collectionData) && Boolean(collectionData[INDEX_CLAIMED_REWARDS]) && Boolean(collectionData[INDEX_CLAIMED_REWARDS].hasOwnProperty(rewardCode)))
               {
                  result = true;
               }
               break;
            }
         }
         return result;
      }
      
      public function getNumofStageCompleted() : int
      {
         var stage:int = 0;
         if(this.hasCollectedFourItems())
         {
            stage = 1;
         }
         else if(this.hasCollectedTenItems())
         {
            stage = 2;
         }
         else if(this.hasCollectedSixteenItems())
         {
            stage = 3;
         }
         else if(this.hasCollectedAllItems())
         {
            stage = 4;
         }
         return stage;
      }
      
      public function isbonusRewardActive(stage:int) : Boolean
      {
         var active:Boolean = false;
         var countOfCollectedAnimal:int = this.numCollectedItem();
         var bonusRewardPkg:Array = this.getBonusRewardPkgs();
         var qty1:int = int(bonusRewardPkg[0]["quantity"]);
         var qty2:int = int(bonusRewardPkg[1]["quantity"]);
         var qty3:int = int(bonusRewardPkg[2]["quantity"]);
         if(stage == 1)
         {
            if(countOfCollectedAnimal < qty1)
            {
               active = true;
            }
         }
         else if(stage == 2)
         {
            if(countOfCollectedAnimal >= qty1 && countOfCollectedAnimal < qty2)
            {
               active = true;
            }
         }
         else if(stage == 3)
         {
            if(countOfCollectedAnimal >= qty2 && countOfCollectedAnimal < qty3)
            {
               active = true;
            }
         }
         return active;
      }
      
      public function isbonusRewardSatgeCompleted(stage:int) : Boolean
      {
         var completed:Boolean = false;
         var countOfCollectedAnimal:int = this.numCollectedItem();
         var bonusRewardPkg:Array = this.getBonusRewardPkgs();
         var qty1:int = int(bonusRewardPkg[0]["quantity"]);
         var qty2:int = int(bonusRewardPkg[1]["quantity"]);
         var qty3:int = int(bonusRewardPkg[2]["quantity"]);
         if(stage == 1)
         {
            if(countOfCollectedAnimal >= qty1)
            {
               completed = true;
            }
         }
         else if(stage == 2)
         {
            if(countOfCollectedAnimal >= qty2)
            {
               completed = true;
            }
         }
         else if(stage == 3)
         {
            if(countOfCollectedAnimal >= qty3)
            {
               completed = true;
            }
         }
         return completed;
      }
      
      public function numCollectedItem() : int
      {
         var rewardPkg:Object = null;
         var result:int = 0;
         for each(rewardPkg in this.getRewardPkgs())
         {
            if(this.hasCollectedItem(rewardPkg.name))
            {
               result++;
            }
         }
         return result;
      }
      
      public function totalNumOfItems() : int
      {
         var numOfItems:Array = this.getRewardPkgs();
         return numOfItems.length;
      }
      
      public function getCraftBucketPackagesByItemCode(itemName:String) : Array
      {
         var result:Array = new Array();
         result.push("pkg_" + itemName + "_05");
         result.push("pkg_" + itemName + "_10");
         result.push("pkg_" + itemName + "_30");
         return result;
      }
      
      public function getFeatureOptionsKey() : String
      {
         return FEATURE_OPTIONS_KEY;
      }
      
      public function hasTimeGatePassed() : Boolean
      {
         var endTimeStamp:Number = NaN;
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTimeStamp = FarmGameUtil.synchronizedDateToNumber(FEATURE_TIME_GATE_DATE) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return currentTime > endTimeStamp;
      }
   }
}

