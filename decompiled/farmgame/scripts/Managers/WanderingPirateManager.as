package Managers
{
   import Classes.MapTrigger;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Engine.Managers.InputManager;
   import Engine.Managers.TransactionManager;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TGenericTransaction;
   import Transactions.TGenericTransactionWithFeed;
   import Widgets.Windows.WanderingPirateRewardPopup;
   import Widgets.Windows.WanderingPirateRewardWindow;
   import Widgets.Windows.WanderingPirateWindow;
   import ZLocalization.Utilities;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class WanderingPirateManager extends BaseFeatureManager
   {
      
      public static const FEATURE_NAME:String = "wp_lostcities";
      
      public static const NUM_OF_CASES:int = 4;
      
      public static const SERVICE_CLASS:String = "WanderingPirateService";
      
      public static const REWARD_ITEMS_STRING:String = "rewardItems";
      
      public static const KEY_BOX_NUMBER:String = "keyBoxNumber";
      
      public static const UPDATE_STATE:String = "updateWPNPCState";
      
      private static const OPEN_UI_DELAY:int = 4000;
      
      private static const OPEN_CASE_STRING:String = "onOpenCase";
      
      private static const BUY_CASE_STRING:String = "onBuyCase";
      
      private static const REWARD_WINDOW_ASSET_PATH:String = "assets/dialogs/WP_LostCities2018/FV_WPLostCities2018_Reward.swf";
      
      public static const FINAL_REWARD_WINDOW_ASSET_PATH:String = "assets/dialogs/WP_LostCities2018/FV_WPLostCities2018_Complete.swf";
      
      public static const WP_WINDOW_LAST_SHOWN:String = "wp_last_shown";
      
      public static const NAME:String = "name";
      
      public static const CODE:String = "code";
      
      public static const REWARDS:String = "rewards";
      
      public static const MAP_GRANTED:String = "map";
      
      public static const NUM_MAPS_GRANTED:String = "num_maps";
      
      public static const FINAL_REWARD:String = "oldtimemachine";
      
      private static var m_wanderingPirateWindow:WanderingPirateWindow = null;
      
      public static var m_wanderingPirateRewardPopup:WanderingPirateRewardPopup = null;
      
      public static const ON_ASK_FOR_CURRENCY:String = "onAskForCurrency";
      
      public static const ON_BUY_CURRENCY:String = "onBuyCurrency";
      
      private static const GOT_FINAL_REWARD:int = 31;
      
      private static const GOT_ALL_REWARD:int = 15;
      
      public static const NUM_OF_CRAFT_SLOTS:int = 3;
      
      public static const CURRENCY_COUNT:String = "oldmap_count";
      
      public static const START_REWARD:int = 5;
      
      public static const ON_START_REWARD_GRANT:String = "onStartRewardGrant";
      
      private var m_rewardWindowCloseCallback:Function = null;
      
      private var m_timer:Timer;
      
      private var m_mapTriggerDetails:MapTrigger = null;
      
      public var CURRENCY_ITEM_NAME:String;
      
      public var ASK_FEED_FREQUENCY_KEY:String;
      
      public var ASK_FEED_FREQUENCY:int;
      
      public var FEATURE_END_DATE:String;
      
      public var FEATURE_START_DATE:String;
      
      public var BUNDLE_ID:String;
      
      private var m_keyBoxNumber:int;
      
      public function WanderingPirateManager(featureName:String = "wp_lostcities")
      {
         super(FEATURE_NAME);
         this.m_mapTriggerDetails = MapTriggerManager.getInstance().getMapTriggerByName(FEATURE_NAME);
         this.populateFeatureConfig();
      }
      
      public static function getInstance(featureName:String = "wp_lostcities") : WanderingPirateManager
      {
         var instance:WanderingPirateManager = BaseFeatureManager.getInstanceOfClass(FEATURE_NAME,WanderingPirateManager) as WanderingPirateManager;
         return instance.featureConfig == null ? null : instance;
      }
      
      public function openNeighborSuggestionWindow() : void
      {
         SameFeatureFriendsManager.instance.showMainUI();
      }
      
      public function showWanderingPirateAndOpenWindow(mapTriggerName:String = "wp_lostcities") : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(mapTriggerName,this.showUI);
         if(!this.m_mapTriggerDetails)
         {
            this.m_mapTriggerDetails = MapTriggerManager.getInstance().getMapTriggerByName(FEATURE_NAME);
         }
         if(this.m_mapTriggerDetails)
         {
            ItemFinderManager.getInstance().highlightWorldItems(this.m_mapTriggerDetails.getItemName());
            this.m_timer = new Timer(OPEN_UI_DELAY,1);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.showUI);
            this.m_timer.start();
            InputManager.disableInput();
         }
         else
         {
            this.showUI();
         }
      }
      
      public function canOpenCase(rubyCount:int) : Boolean
      {
         var currentRubyCount:int = this.getCurrencyCount();
         var result:Boolean = false;
         if(currentRubyCount >= rubyCount)
         {
            result = true;
         }
         return result;
      }
      
      public function onBuyCase(keyBoxNumber:int, cashValue:int, callBack:Function) : void
      {
         this.m_rewardWindowCloseCallback = callBack;
         this.m_keyBoxNumber = keyBoxNumber;
         if(Global.player.cash >= cashValue)
         {
            Global.player.cash -= cashValue;
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,BUY_CASE_STRING,this.onOpenCaseCallBack,[m_featureName,keyBoxNumber]));
         }
      }
      
      public function onOpenCase(keyBoxNumber:int, rubyCount:int, callBack:Function) : void
      {
         this.m_rewardWindowCloseCallback = callBack;
         this.changeCurrencyCount(-1 * rubyCount);
         this.m_keyBoxNumber = keyBoxNumber;
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,OPEN_CASE_STRING,this.onOpenCaseCallBack,[m_featureName,keyBoxNumber]));
      }
      
      private function setRewardItems(keyBoxNumber:int, itemCode:String) : Object
      {
         var getItems:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,REWARDS);
         if(Boolean(getItems) && Boolean(getItems[keyBoxNumber]) && Boolean(getItems[keyBoxNumber][itemCode]))
         {
            ++getItems[keyBoxNumber][itemCode];
         }
         else
         {
            if(!getItems)
            {
               getItems = new Object();
            }
            if(!getItems.hasOwnProperty(keyBoxNumber.toString()))
            {
               getItems[keyBoxNumber.toString()] = new Object();
            }
            if(!getItems[keyBoxNumber.toString()].hasOwnProperty(itemCode))
            {
               getItems[keyBoxNumber.toString()][itemCode] = 1;
            }
            else
            {
               getItems[keyBoxNumber.toString()][itemCode] = getItems[keyBoxNumber.toString()][itemCode] + 1;
            }
         }
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,REWARDS,getItems);
         return getItems;
      }
      
      public function getRewardCount(keyBoxNumber:int) : Object
      {
         var data:Object = null;
         var result:Object = null;
         data = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,REWARDS);
         if(Boolean(data) && Boolean(data[keyBoxNumber]))
         {
            result = data[keyBoxNumber];
         }
         return result;
      }
      
      public function onOpenCaseCallBack(rewardItem:Object) : void
      {
         var getItems:Object = null;
         var shouldShowMap:Boolean = false;
         var rewardsWindow:WanderingPirateRewardWindow = null;
         var rewardFinalReward:Boolean = false;
         var isBonusRewardGranted:Boolean = false;
         if(rewardItem)
         {
            getItems = this.setRewardItems(this.m_keyBoxNumber,rewardItem[CODE]);
            shouldShowMap = this.checkAndSetMap(this.m_keyBoxNumber,getItems);
            isBonusRewardGranted = this.grantFinalReward();
            if(isBonusRewardGranted && shouldShowMap)
            {
               UI.displayPopup(new WanderingPirateRewardPopup(FINAL_REWARD_WINDOW_ASSET_PATH,WanderingPirateManager.FEATURE_NAME),false);
               m_wanderingPirateWindow.m_completeMc.visible = true;
            }
            rewardsWindow = new WanderingPirateRewardWindow(REWARD_WINDOW_ASSET_PATH,this.m_keyBoxNumber,rewardItem,this.m_rewardWindowCloseCallback,shouldShowMap);
            UI.displayPopup(rewardsWindow,false);
            Global.player.addGift(rewardItem[NAME]);
         }
      }
      
      public function getMapStageForUser() : int
      {
         var result:int = 0;
         var featureOptionData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,REWARDS);
         if(Boolean(featureOptionData) && Boolean(featureOptionData[NUM_MAPS_GRANTED]))
         {
            result = int(featureOptionData[NUM_MAPS_GRANTED]);
         }
         return result;
      }
      
      public function hasUserFinished() : Boolean
      {
         var result:Boolean = false;
         if(WanderingPirateManager.getInstance(FEATURE_NAME).getMapStageForUser() >= NUM_OF_CASES)
         {
            result = true;
         }
         return result;
      }
      
      private function grantFinalReward(getItems:Object = null) : Boolean
      {
         var isfinalRewardGranted:Boolean = false;
         if(getItems == null)
         {
            getItems = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,REWARDS);
         }
         if(Boolean(getItems) && Boolean(getItems[NUM_MAPS_GRANTED]) && getItems[NUM_MAPS_GRANTED] == NUM_OF_CASES)
         {
            getItems[NUM_MAPS_GRANTED] += 1;
            Global.player.addGift(FINAL_REWARD);
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,REWARDS,getItems);
            GlobalEventManager.getInstance().dispatchEvent(new Event(UPDATE_STATE));
            isfinalRewardGranted = true;
         }
         return isfinalRewardGranted;
      }
      
      private function checkAndSetMap(keyBoxNumber:int, getItems:Object) : Boolean
      {
         var shouldSetMap:Boolean = this.grantedAllRewardsCheck(keyBoxNumber,getItems);
         var result:Boolean = false;
         if(keyBoxNumber >= 0 && shouldSetMap)
         {
            if(Boolean(getItems) && Boolean(getItems[keyBoxNumber]) && getItems[keyBoxNumber][MAP_GRANTED] != true)
            {
               getItems[keyBoxNumber][MAP_GRANTED] = true;
               result = true;
               if(getItems.hasOwnProperty(NUM_MAPS_GRANTED))
               {
                  getItems[NUM_MAPS_GRANTED] += 1;
               }
               else
               {
                  getItems[NUM_MAPS_GRANTED] = 1;
               }
            }
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,REWARDS,getItems);
         }
         return result;
      }
      
      public function getLength(keyBoxNumber:int, getItems:Object = null) : int
      {
         var itemCode:String = null;
         var result:int = 0;
         if(getItems == null)
         {
            getItems = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,REWARDS);
         }
         if(Boolean(getItems) && Boolean(getItems[keyBoxNumber]))
         {
            for(itemCode in getItems[keyBoxNumber])
            {
               if(Boolean(getItems[keyBoxNumber][itemCode]) && Boolean(getItems[keyBoxNumber][itemCode] > 0) && itemCode != MAP_GRANTED)
               {
                  result++;
               }
            }
         }
         return result;
      }
      
      private function isMapGrantedForKeyBox(keyBoxNumber:int) : Boolean
      {
         var result:Boolean = false;
         var getItems:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,REWARDS);
         if(Boolean(getItems) && Boolean(getItems[keyBoxNumber]))
         {
            result = Boolean(getItems[keyBoxNumber][MAP_GRANTED]);
         }
         return result;
      }
      
      private function grantedAllRewardsCheck(keyBoxNumber:int, getItems:Object) : Boolean
      {
         var result:Boolean = false;
         var length:int = this.getLength(keyBoxNumber,getItems);
         if(Boolean(getItems) && Boolean(getItems[keyBoxNumber]) && length == NUM_OF_CASES)
         {
            result = true;
         }
         return result;
      }
      
      public function getRewardItemsForKey(keyValue:int) : Object
      {
         var rewardList:XMLList = null;
         var reward:XML = null;
         var rewardName:String = null;
         var rewardItems:Array = new Array();
         var rewardDetails:Object = new Object();
         var rubyCountDetails:Array = null;
         var listArray:Array = Utilities.xmlListToArray(m_featureConfig.divisions.division);
         if(m_featureConfig)
         {
            if(listArray[keyValue])
            {
               rubyCountDetails = listArray[keyValue].@name.split("_");
               rewardList = listArray[keyValue].items.item;
               for each(reward in rewardList)
               {
                  rewardName = reward.@name;
                  rewardItems.push({
                     "rewardName":rewardName,
                     "rewardType":reward.@rarity.toString()
                  });
               }
            }
            rewardDetails[REWARD_ITEMS_STRING] = rewardItems;
            rewardDetails[CURRENCY_COUNT] = rubyCountDetails[1];
         }
         return rewardDetails;
      }
      
      public function getCraftingRecipeForKey(keyValue:int) : Object
      {
         var recipeName:String = null;
         var recipe:XML = null;
         var listArray:Array = Utilities.xmlListToArray(m_featureConfig.crafting.recipes.recipe);
         if(m_featureConfig)
         {
            if(listArray[keyValue])
            {
               recipe = listArray[keyValue];
               recipeName = recipe.@name;
            }
         }
         return recipeName;
      }
      
      public function showUI(event:Event = null) : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.showUI);
            InputManager.enableInput();
            UI.stopPopups(false);
         }
         this.m_mapTriggerDetails = MapTriggerManager.getInstance().getMapTriggerByName(FEATURE_NAME);
         m_wanderingPirateWindow = new WanderingPirateWindow();
         UI.displayPopup(m_wanderingPirateWindow,false);
      }
      
      public function closeAllWindows() : void
      {
      }
      
      public function askForCurrencyItem() : void
      {
         TransactionManager.addTransaction(new TGenericTransactionWithFeed(SERVICE_CLASS,ON_ASK_FOR_CURRENCY,null,[m_featureName]));
      }
      
      public function buyCurrencyItem(cashValue:int) : void
      {
         if(Global.player.cash >= cashValue)
         {
            Global.player.cash -= cashValue;
            this.changeCurrencyCount(1);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,ON_BUY_CURRENCY,null,[m_featureName]));
         }
      }
      
      public function getCurrencyCount() : int
      {
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,CURRENCY_COUNT);
         return int(data);
      }
      
      public function setCurrencyCount(data:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,CURRENCY_COUNT,data);
      }
      
      public function startRewardGrant() : Object
      {
         var data:Object = START_REWARD + this.getCurrencyCount();
         this.setCurrencyCount(data);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,ON_START_REWARD_GRANT,this.onStartRewardGrantCallBack,[m_featureName]));
         return data;
      }
      
      public function onStartRewardGrantCallBack(result:Object) : void
      {
         Global.player.setSeenFlag(m_featureName + "_Start_Reward",false,true);
      }
      
      public function changeCurrencyCount(count:int = 1) : void
      {
         var ruby_count:int = this.getCurrencyCount();
         ruby_count += count;
         this.setCurrencyCount(ruby_count);
         if(m_wanderingPirateWindow)
         {
            m_wanderingPirateWindow.refreshWindow();
            m_wanderingPirateWindow.refreshCurrencyCount();
         }
      }
      
      public function populateFeatureConfig() : void
      {
         if(m_featureConfig)
         {
            this.CURRENCY_ITEM_NAME = m_featureConfig.currencyItem.@name.toString();
            this.FEATURE_END_DATE = m_featureConfig.listEndDate.toString();
            this.FEATURE_START_DATE = m_featureConfig.listStartDate.toString();
            this.ASK_FEED_FREQUENCY = m_featureConfig.feed.@throttleTime.toString();
            this.ASK_FEED_FREQUENCY_KEY = m_featureName + "AskCurrency";
            this.BUNDLE_ID = m_featureName + "ShareReward";
         }
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
                  "creative":this.CURRENCY_ITEM_NAME,
                  "subcategory":this.BUNDLE_ID,
                  "images":[{
                     "href":"{SN_APP_URL}" + reward["rewardUrl"],
                     "src":rewardFarmItem.getImageByName(FarmItem.ICON_FEED)
                  }]
               };
               GlobalEngine.socialNetwork.publishFeedStory(this.BUNDLE_ID,bundleData,[],false);
            }
         }
      }
      
      public function getDaysRemaining() : Number
      {
         var timeRemaining:Number = (FarmGameUtil.synchronizedDateToNumber(this.FEATURE_END_DATE) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return Math.ceil(timeRemaining / FarmGameUtil.NUM_SECS_IN_DAY);
      }
      
      public function isLastTwoStagesLocked() : Boolean
      {
         var result:Boolean = false;
         if(this.getDaysRemaining() >= 15)
         {
            result = true;
         }
         return result;
      }
      
      public function getMapsFinished() : Number
      {
         var result:Number = 0;
         var getItems:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,REWARDS);
         if(Boolean(getItems) && Boolean(getItems[NUM_MAPS_GRANTED]))
         {
            result = Number(getItems[NUM_MAPS_GRANTED]);
         }
         return result;
      }
   }
}

