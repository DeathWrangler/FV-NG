package Managers
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.*;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.BirthdayFreeGiftsWindow;
   
   public class BirthdayFreeGiftsManager extends BaseFeatureManager
   {
      
      private static const BUNDLE_ID:String = "birthdayFeedReward";
      
      private static const FRIEND_REWARD:String = "consume_organic_fertilizer";
      
      private static const MONTH_ARRAY:Array = ["January","February","March","April","May","June","July","August","September","October","November","December"];
      
      public static const CLAIMED_STATE:String = "claimed";
      
      public static const CLAIMABLE_STATE:String = "claimable";
      
      public static const DAY_NUMBER_STRING:String = "dayNumber";
      
      public static const DEFAULT_STATE:String = "default";
      
      public static const DEFAULT_NAME:String = "defaultName";
      
      public static const EXPIRED_STATE:String = "expired";
      
      public static const FEATURE_NAME:String = "birthdayFG2014";
      
      public static const GIFTS_FEATURE_OPTION:String = "gifts";
      
      public static const ITEM_NAME:String = "itemName";
      
      public static const ITEM_STATE:String = "itemState";
      
      public static const NUMBER_OF_DAYS_GIFTS_AWARDED:int = 7;
      
      public static const TRANSACTION_COUNT:String = "transactionCount";
      
      public static const SERVICE_CLASS:String = "BirthdayFreeGiftsService";
      
      public static const TIMER_STATE:String = "timer";
      
      private static var m_birthdayFreeGiftsWindow:BirthdayFreeGiftsWindow = null;
      
      private static var featureConfig:XML = null;
      
      private var m_assetPath:String;
      
      private var m_featureStartDate:String;
      
      private var m_gifts:Array = null;
      
      private var m_transactionCount:int = 0;
      
      public function BirthdayFreeGiftsManager(featureName:String = "birthdayFG2014")
      {
         featureConfig = this.getFeatureConfig(featureName);
         super(featureName,featureConfig);
      }
      
      public static function getInstance(featureName:String = "birthdayFG2014") : BirthdayFreeGiftsManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,BirthdayFreeGiftsManager) as BirthdayFreeGiftsManager;
      }
      
      public function getFeatureConfig(featureName:String = "birthdayFG2014") : XML
      {
         var result:XML = null;
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(featureName);
         if(featureXML)
         {
            result = featureXML;
            if(featureXML.hasOwnProperty("@born"))
            {
               this.m_featureStartDate = featureXML.@born;
            }
            this.m_assetPath = featureXML.UI.dialog.@path;
         }
         return result;
      }
      
      public function getStartDate() : Array
      {
         var dateArray:Array = null;
         var month:int = 0;
         var result:Array = new Array();
         var dateFromXml:String = this.m_featureStartDate;
         if(dateFromXml)
         {
            dateArray = String(dateFromXml).split("/",3);
            month = int(dateArray[0]);
            result.push({
               "month":MONTH_ARRAY[month],
               "date":dateArray[1]
            });
         }
         return result;
      }
      
      public function onBragFeed(itemName:String) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"onBragFeed",this.onBragFeedCallBack,[m_featureName,itemName]));
      }
      
      public function onBragFeedCallBack(reward:Object) : void
      {
         var itemName:String = null;
         var rewardFarmItem:FarmItem = null;
         var bundleData:Object = null;
         if(Boolean(reward) && reward.hasOwnProperty("rewardUrl"))
         {
            itemName = null;
            if(reward.hasOwnProperty("itemName"))
            {
               itemName = reward["itemName"];
            }
            if(Boolean(itemName) && itemName != "")
            {
               rewardFarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
               bundleData = {
                  "reward_link":reward["rewardUrl"],
                  "giftName":rewardFarmItem.friendlyName,
                  "creative":FRIEND_REWARD,
                  "subcategory":BUNDLE_ID,
                  "images":[{
                     "href":"{SN_APP_URL}" + reward["rewardUrl"],
                     "src":rewardFarmItem.getImageByName(FarmItem.ICON_FEED)
                  }]
               };
               GlobalEngine.socialNetwork.publishFeedStory(BUNDLE_ID,bundleData,[],false);
            }
         }
      }
      
      public function addNewGiftToFeatureOption() : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,GIFTS_FEATURE_OPTION,this.m_gifts);
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,TRANSACTION_COUNT,this.m_transactionCount + 1);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"addItemToFeatureOption",this.setFeatureOption,[m_featureName,true]));
      }
      
      public function displayDialog() : void
      {
         m_birthdayFreeGiftsWindow = new BirthdayFreeGiftsWindow(m_featureName,this.m_assetPath);
         this.m_gifts = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,GIFTS_FEATURE_OPTION) as Array;
         if(this.m_gifts)
         {
            this.m_transactionCount = this.m_gifts.length;
            this.addNewGiftIfRequired();
            UI.displayPopup(m_birthdayFreeGiftsWindow);
         }
      }
      
      private function addNewGiftIfRequired() : void
      {
         var daysSinceFeatureStarted:int = FarmGameUtil.getDaysSinceStartDate(this.m_featureStartDate);
         if(this.m_transactionCount - 1 < daysSinceFeatureStarted && this.m_transactionCount < NUMBER_OF_DAYS_GIFTS_AWARDED)
         {
            this.m_gifts.push({
               "itemName":DEFAULT_NAME,
               "itemState":DEFAULT_STATE
            });
            this.addNewGiftToFeatureOption();
         }
      }
      
      public function setFeatureOption(giftData:Object = null) : void
      {
         if(Boolean(giftData) && Boolean(giftData["gifts"]))
         {
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,GIFTS_FEATURE_OPTION,giftData["gifts"]);
            this.refreshEverything();
         }
      }
      
      public function setStateOfGiftFrontEnd(giftName:String = null, giftState:String = null) : void
      {
         var i:int = 0;
         if(giftName != null && giftState != null)
         {
            this.m_gifts = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,GIFTS_FEATURE_OPTION) as Array;
            for(i = 0; i < this.m_gifts.length; i++)
            {
               if(this.m_gifts[i][ITEM_NAME] == giftName)
               {
                  this.m_gifts[i][ITEM_STATE] = giftState;
                  break;
               }
            }
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,GIFTS_FEATURE_OPTION,this.m_gifts);
         }
      }
      
      public function setStateAndGift(giftName:String = null, giftState:String = null) : void
      {
         this.setStateOfGiftFrontEnd(giftName,giftState);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"setStateAndGift",this.onSetStateAndGift,[FEATURE_NAME,giftName,giftState]));
      }
      
      public function onBuy(giftName:String) : void
      {
         var gift:FarmItem = null;
         if(giftName != null)
         {
            gift = Global.farmGameSettingsManager.getFarmItemByName(giftName);
            Global.player.updateWorldCurrency(Currency.COINS,-1 * gift.cost);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"onBuyGift",this.onBuyGift,[m_featureName,giftName,CLAIMED_STATE]));
         }
      }
      
      private function onBuyGift(result:Object) : void
      {
         if(result[ITEM_NAME])
         {
            Global.player.addGift(result[ITEM_NAME],"0",1);
            this.setStateOfGiftFrontEnd(result[ITEM_NAME],CLAIMED_STATE);
            this.refreshEverything();
         }
      }
      
      private function onSetStateAndGift(result:Object) : void
      {
         if(result)
         {
            Global.player.addGift(result[ITEM_NAME],"0",1);
         }
      }
      
      public function refreshEverything() : void
      {
         if(m_birthdayFreeGiftsWindow)
         {
            m_birthdayFreeGiftsWindow.refresh();
         }
      }
   }
}

