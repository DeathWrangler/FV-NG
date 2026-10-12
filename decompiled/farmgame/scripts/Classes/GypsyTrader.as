package Classes
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.InputManager;
   import Engine.Managers.TransactionManager;
   import Managers.BringBackWinterManager;
   import Managers.FeatureMessagingManager;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.FeatureOptionsManager;
   import Managers.ItemFinderManager;
   import Managers.MapTriggerManager;
   import Transactions.TGenericTransaction;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.CraftingBasket.CraftingBasketCongratsWindow;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FeaturePackagesBuyWindow;
   import Widgets.Windows.GypsyTraderWindow;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class GypsyTrader extends BringBackWinterManager
   {
      
      public static const SERVICE_CLASS:String = "GypsyTraderService";
      
      private static const FEATURE_NAME:String = "GypsyTrader";
      
      public static const FEATURE_OPTIONS_KEY:String = "v2";
      
      private static const WINDOW_BUYDIALOG:String = "buy";
      
      public static const PINK_CROP_NAME:String = "gildedcarnations";
      
      public static const BLUE_CROP_NAME:String = "garnetpoppy";
      
      public static const GREEN_CROP_NAME:String = "midnightazalea";
      
      public static const BRAG_FEED_TYPE:String = "GypsyTrader_Brag";
      
      private static const OPEN_UI_DELAY:int = 4000;
      
      private var m_itemName:String;
      
      private var m_window:GypsyTraderWindow;
      
      private var m_timer:Timer;
      
      public function GypsyTrader(featureName:String = "GypsyTrader")
      {
         var bucketPackagesXML:XML = null;
         var index:* = 0;
         var currency:XML = null;
         var bucketPackages:Array = null;
         var bucketXML:XML = null;
         super(featureName);
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         if(featureXML != null)
         {
            m_featureConfigData.currencyArray = new Array();
            if(featureXML.assets != "")
            {
               index = 0;
               for each(currency in featureXML.currencyItem)
               {
                  var _loc10_:Number;
                  m_featureConfigData.currencyArray[_loc10_ = index++] = currency.@name.toString();
               }
            }
            m_featureConfigData.bucketPackages = new Array();
            for each(bucketPackagesXML in featureXML.bucketPackages)
            {
               bucketPackages = new Array();
               for each(bucketXML in bucketPackagesXML.bucketPackage)
               {
                  bucketPackages.push(bucketXML.@name.toString());
               }
               m_featureConfigData.bucketPackages.push(bucketPackages);
            }
         }
      }
      
      public static function getInstance(featureName:String = "GypsyTrader") : GypsyTrader
      {
         if(!m_instance.hasOwnProperty(featureName) && featureName != null)
         {
            m_instance[featureName] = new GypsyTrader(featureName);
         }
         return m_instance[featureName];
      }
      
      public static function getCropName(cropIndex:String) : String
      {
         var cropCode:String = null;
         switch(cropIndex)
         {
            case INDEX_PINK_COUNT:
               cropCode = PINK_CROP_NAME;
               break;
            case INDEX_BLUE_COUNT:
               cropCode = BLUE_CROP_NAME;
               break;
            case INDEX_GREEN_COUNT:
               cropCode = GREEN_CROP_NAME;
               break;
            default:
               cropCode = null;
         }
         return cropCode;
      }
      
      public function showMainWindow() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(m_featureName,this.showUI);
         var mapTrigger:MapTrigger = MapTriggerManager.getInstance().getMapTriggerByName(m_featureName);
         if(mapTrigger)
         {
            ItemFinderManager.getInstance().highlightWorldItems(mapTrigger.getItemName());
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
      
      public function showUI(event:Event = null) : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.showUI);
            InputManager.enableInput();
            UI.stopPopups(false);
         }
         this.m_window = new GypsyTraderWindow(m_featureConfigData.mainDialogPath,null,m_featureName);
         UI.displayPopup(this.m_window);
      }
      
      public function get bonusItemName() : String
      {
         return m_bonusRewardName;
      }
      
      private function getPurchasePackages(index:int) : Array
      {
         return m_featureConfigData.bucketPackages[index];
      }
      
      public function openBuyWindow(owner:FarmWindow, index:String) : void
      {
         var currencyName:String = Global.farmGameSettingsManager.getFarmItemNameByCode(this.getCurrencyCode(index));
         UI.displayPopup(new FeaturePackagesBuyWindow(getRewardDialogPathFor(WINDOW_BUYDIALOG),m_featureName + "_" + currencyName,this.getPurchasePackages(parseInt(index) - 1),owner),false);
      }
      
      public function buyCraftItemBuckets(buyPackage:String) : void
      {
         var sunshinePackage:FarmItem = null;
         var canBuy:Boolean = false;
         if(buyPackage != null)
         {
            sunshinePackage = Global.farmGameSettingsManager.getFarmItemByName(buyPackage);
            canBuy = Global.player.buyFarmItem(sunshinePackage,Currency.CASH,1);
            if(Boolean(this.m_window) && canBuy)
            {
               this.m_window.update();
               this.m_window.enableWindow(true);
            }
         }
      }
      
      override public function getFeatureData(shouldCreate:Boolean = true) : Object
      {
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,FEATURE_OPTIONS_KEY);
         if(!data && shouldCreate)
         {
            data = this.createFeatureData();
         }
         return data;
      }
      
      public function setFeatureData(data:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,FEATURE_OPTIONS_KEY,data);
      }
      
      public function createFeatureData() : Object
      {
         var data:Object = new Object();
         data[INDEX_CLAIMED_REWARDS] = {};
         this.setFeatureData(data);
         return data;
      }
      
      override public function areSnowFlakeReqsMetFor(rewardData:Object) : Boolean
      {
         var sfType:String = null;
         var featureDataIndex:String = null;
         var sfCount:int = 0;
         var canredeem:Boolean = true;
         for(var i:int = 0; i < SFTYPES.length; i++)
         {
            sfType = SFTYPES[i];
            if(rewardData.hasOwnProperty(sfType))
            {
               featureDataIndex = getSftypeToFeatureDataIndex(sfType);
               sfCount = FeatureOptionsInventoryManager.getInstance().getCount(this.getCurrencyCode(featureDataIndex));
               if(sfCount < parseInt(rewardData[sfType]))
               {
                  canredeem = false;
                  break;
               }
            }
         }
         return canredeem;
      }
      
      override public function getSfCollectionCount(sfType:String) : int
      {
         return FeatureOptionsInventoryManager.getInstance().getCount(this.getCurrencyCode(sfType));
      }
      
      public function redeemItem(itemName:String) : void
      {
         var item:Object = null;
         var featureData:Object = null;
         var i:int = 0;
         var itemCode:String = null;
         var sfType:String = null;
         var featureDataIndex:String = null;
         var currencyCode:String = null;
         this.m_itemName = itemName;
         var itemObject:Object = null;
         for each(item in getRewardPkgs())
         {
            if(item.name == itemName)
            {
               itemObject = item;
            }
         }
         if(itemObject != null)
         {
            featureData = this.getFeatureData();
            if(this.areSnowFlakeReqsMetFor(itemObject))
            {
               for(i = 0; i < SFTYPES.length; i++)
               {
                  sfType = SFTYPES[i];
                  if(itemObject.hasOwnProperty(sfType))
                  {
                     featureDataIndex = getSftypeToFeatureDataIndex(sfType);
                     currencyCode = this.getCurrencyCode(featureDataIndex);
                     FeatureOptionsInventoryManager.getInstance().removeCount(currencyCode,parseInt(itemObject[sfType]));
                  }
               }
               itemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(itemName);
               featureData[INDEX_CLAIMED_REWARDS][itemCode] = true;
               this.setFeatureData(featureData);
               this.m_window.enableWindow(false);
               this.onGrantItemSuccess();
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,ACTION_REDEEM_REWARD,null,[itemName,m_featureName]),true);
            }
         }
      }
      
      public function askForCurrency(itemCodeIndex:String, callback:Function) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,ACTION_POST_SF,callback,[this.getCurrencyCode(itemCodeIndex)]));
      }
      
      override public function buyCollectionItem(itemName:String) : void
      {
         var buyResult:Boolean = false;
         var featureData:Object = null;
         var itemCode:String = null;
         this.m_itemName = itemName;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         if(Global.player.canBuyCash(item.cash))
         {
            buyResult = Global.player.tryBuy(null,false,item,0);
            if(buyResult)
            {
               this.m_window.enableWindow(false);
               featureData = this.getFeatureData();
               itemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(itemName);
               featureData[INDEX_CLAIMED_REWARDS][itemCode] = true;
               this.setFeatureData(featureData);
               this.onGrantItemSuccess();
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,BUY_ITEM,null,[this.m_itemName,m_featureName]),true);
            }
         }
      }
      
      private function onGrantItemSuccess(result:Object = null) : void
      {
         var featureData:Object = this.getFeatureData();
         Global.player.addGift(this.m_itemName);
         var bonus:String = null;
         var bonusText:String = null;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         if(hasCollectedAllItems() && !featureData[INDEX_SEEN_BONUS_POPUP])
         {
            bonus = this.bonusItemName;
            bonusText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "GenericBonusText",{"itemName":farmItem.friendlyTitle});
            featureData[INDEX_SEEN_BONUS_POPUP] = true;
            FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,FEATURE_OPTIONS_KEY,featureData);
            Global.player.addGift(bonus);
         }
         var congratsDialog:CraftingBasketCongratsWindow = new CraftingBasketCongratsWindow(getRewardDialogPathFor(REWARD_PATH),m_featureName,farmItem,this.onShareReward,result,bonus,bonusText);
         UI.displayPopup(congratsDialog,false);
         if(this.m_window)
         {
            this.m_window.update();
            this.m_window.enableWindow(true);
         }
      }
      
      public function onShareReward(result:Object, rewardWindow:CraftingBasketCongratsWindow) : void
      {
         rewardWindow.close();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,ACTION_SHARE_BRAG_FEED,this.onShareBragFeed,[m_featureName,this.m_itemName]));
      }
      
      private function onShareBragFeed(result:Object) : void
      {
         var rewardName:String = result.rewardName;
         var rewardLink:String = result.rewardLink;
         var rewardItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
         var shareItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(m_featureConfigData.currencyArray[0]);
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
         var bundleData:Object = {
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":rewardItem.icon
            }],
            "rewardName":rewardItem.friendlyTitle,
            "itemName":shareItem.friendlyTitle
         };
         GlobalEngine.socialNetwork.publishFeedStory(BRAG_FEED_TYPE,bundleData,[],false);
      }
      
      public function getCurrencyCode(cropIndex:String) : String
      {
         return m_featureConfigData.currencyArray[parseInt(cropIndex) - 1];
      }
      
      override public function getFeatureOptionsKey() : String
      {
         return FEATURE_OPTIONS_KEY;
      }
   }
}

