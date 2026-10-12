package Managers
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.PaymentUtil;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.DollarBundle;
   import Transactions.TDollarBundleDiscount;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.DollarBundles.DollarBundleClaimWindow;
   import Widgets.Windows.DollarBundles.DollarBundleCongratsWindow;
   import Widgets.Windows.DollarBundles.DollarBundlesWindow;
   
   public class DollarBundlesManager extends BaseFeatureManager
   {
      
      public static const FEATURE_NAME:String = "dollarbundles";
      
      public static const HAS_FEATURE_SEEN:String = "hasSeenFeature2018";
      
      public static const VAL_DISCOUNT_ARRAY_LENGTH:int = 3;
      
      public static const BUNDLE_ORIGINAL_PRICE:int = 10;
      
      public static const DISCOUNTS_ARRAY:String = "discountArray";
      
      public static const VARIANT_COUNTER:Number = 2;
      
      public static var FINISHED_SPIN_COUNT:String = "finished_spin_count";
      
      public static const BOUGHT_BUNDLE_COUNT:String = "numOfBundleBought";
      
      public static const PURCHASED_ALL_BUNDLES:String = "purchasedAllBundles";
      
      private static var PAYMENT_CODES:Object = {
         90:"6:1001",
         80:"6:1002",
         70:"6:1003",
         60:"6:1004",
         50:"6:1005"
      };
      
      private const SERVICE_NAME:String = "DollarBundleService";
      
      private const DOLLAR_BUNDLE_VERSION:String = "DollarBundleVersion";
      
      public const ZRUNTIME_KEY_DOLLAR_BUNDLE_ARRAY:String = "DOLLAR_BUNDLE_ARRAY";
      
      public const ZRUNTIME_KEY_DOLLAR_BUNDLE_END_TIME:String = "DOLLAR_BUNDLE_END_TIME";
      
      public const ZRUNTIME_KEY_DOLLAR_BUNDLE_START_TIME:String = "DOLLAR_BUNDLE_START_TIME";
      
      public const ZRUNTIME_KEY_DOLLAR_BUNDLE_VERSION:String = "DOLLAR_BUNDLE_VERSION";
      
      private var m_endTimeStamp:Number = 0;
      
      private var m_DollarBundlesWindow:DollarBundlesWindow = null;
      
      private var m_activeItemName:String;
      
      private var m_DollarBundlesClaimWindow:DollarBundleClaimWindow = null;
      
      public var m_DiscountsArray:Array = new Array(VAL_DISCOUNT_ARRAY_LENGTH);
      
      public function DollarBundlesManager(featureName:String = "dollarbundles")
      {
         super(featureName);
      }
      
      public static function getInstance(featureName:String = "dollarbundles") : DollarBundlesManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,DollarBundlesManager) as DollarBundlesManager;
      }
      
      public function setDiscountsArray() : void
      {
         var i:int = 0;
         var key:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,DISCOUNTS_ARRAY);
         if(!key)
         {
            this.initializeOptions();
         }
         else
         {
            for(i = 0; i < VAL_DISCOUNT_ARRAY_LENGTH; i++)
            {
               if(Boolean(key[i]) && Boolean(key[i].value))
               {
                  this.m_DiscountsArray[i] = key[i].value;
               }
               else
               {
                  this.m_DiscountsArray[i] = 0;
               }
            }
         }
      }
      
      public function initializeOptions() : void
      {
         var valueObj:Object = null;
         var discountArray:Array = [];
         for(var i:int = 0; i < VAL_DISCOUNT_ARRAY_LENGTH; i++)
         {
            valueObj = {};
            valueObj["value"] = 0;
            this.m_DiscountsArray[i] = 0;
            discountArray.push(valueObj);
         }
         var numOfBoughtBundles:int = 0;
         this.saveFeatureOptionsKey(DISCOUNTS_ARRAY,discountArray as Object);
         this.setVersion();
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"initializeFeatureOptions",null,new Array(FEATURE_NAME)),true);
      }
      
      public function handleHUDClick() : void
      {
         FarmStatsManager.count("Superbundle","Hud","click","","","");
         this.setDiscountsArray();
         this.openDollarBundlesUI();
      }
      
      public function openDollarBundlesUI() : void
      {
         if(this.getFinishedSpinCount() == VAL_DISCOUNT_ARRAY_LENGTH)
         {
            this.m_DollarBundlesClaimWindow = new DollarBundleClaimWindow();
            UI.displayPopup(this.m_DollarBundlesClaimWindow);
         }
         else
         {
            this.m_DollarBundlesWindow = new DollarBundlesWindow();
            UI.displayPopup(this.m_DollarBundlesWindow);
         }
      }
      
      private function getTutorialFlagName() : String
      {
         return FEATURE_NAME + "_" + HAS_FEATURE_SEEN;
      }
      
      public function hasFeatureSeen() : Boolean
      {
         return Global.player.getSeenFlag(this.getTutorialFlagName());
      }
      
      public function setFeatureSeenFlag() : void
      {
         Global.player.setSeenFlag(this.getTutorialFlagName(),false,false);
      }
      
      public function saveFeatureOptionsKey(optionName:String, optionsValue:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,optionName,optionsValue);
      }
      
      public function getFeatureOptionsKey(optionName:String) : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,optionName);
      }
      
      public function isFeatureActive() : Boolean
      {
         return true;
      }
      
      public function showCongratulationsWindow() : void
      {
         var congratsWindow:DollarBundleCongratsWindow = new DollarBundleCongratsWindow(this.m_activeItemName);
         UI.displayPopup(congratsWindow);
      }
      
      public function startBuyTransaction() : void
      {
         this.m_activeItemName = this.getCurrentBundleName();
         var paymentCode:String = PAYMENT_CODES[this.getMaxDiscount()];
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_DOLLAR_BUNDLES_DEV_TESTING) == 1)
         {
            TransactionManager.addTransaction(new DollarBundle(null,paymentCode,this.onPaymentSuccess));
         }
         else
         {
            PaymentUtil.instance.addPaymentItemToCart(paymentCode,1,m_featureName,this.onPaymentSuccess,this.onPaymentFailure);
         }
      }
      
      private function onPaymentSuccess(orderId:String = "", status:String = "") : void
      {
         var itemName:String = null;
         var numOfBundlesBought:Number = this.getFeatureOptionsKey(BOUGHT_BUNDLE_COUNT) as int;
         numOfBundlesBought += 1;
         this.saveFeatureOptionsKey(BOUGHT_BUNDLE_COUNT,numOfBundlesBought);
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,this.m_activeItemName,1);
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_activeItemName);
         var packagedItems:Object = farmItem.getItemPackageHash();
         if(packagedItems != null)
         {
            for(itemName in packagedItems)
            {
               Global.player.addGift(itemName,"0",1);
               UI.refreshGiftBoxWindow();
            }
         }
         this.showCongratulationsWindow();
         this.m_activeItemName = "";
      }
      
      public function getBundleDiscount(onCompleteCallback:Function = null) : void
      {
         TransactionManager.addTransaction(new TDollarBundleDiscount(onCompleteCallback),true);
      }
      
      private function onPaymentFailure(orderId:String = "", status:String = "") : void
      {
         this.m_activeItemName = "";
         UI.showMessage("Payment failed. Please try again.");
      }
      
      public function getMaxDiscount() : int
      {
         return Math.max(this.m_DiscountsArray[0],this.m_DiscountsArray[1],this.m_DiscountsArray[2]);
      }
      
      public function getDiscountForSlot(slotNum:int) : int
      {
         var slotIndex:int = slotNum - 1;
         return this.m_DiscountsArray[slotIndex];
      }
      
      public function getFinishedSpinCount() : int
      {
         var numOfSpinFinished:int = this.getFeatureOptionsKey(FINISHED_SPIN_COUNT) as int;
         if(!numOfSpinFinished)
         {
            numOfSpinFinished = 0;
         }
         return numOfSpinFinished;
      }
      
      public function getCurrentBundleName() : String
      {
         var currentBundleName:String = null;
         var bundleArray:Array = new Array();
         if(Global.flashHotParams.hasOwnProperty(this.ZRUNTIME_KEY_DOLLAR_BUNDLE_ARRAY))
         {
            bundleArray = Global.flashHotParams[this.ZRUNTIME_KEY_DOLLAR_BUNDLE_ARRAY].split(",");
         }
         var numBundleBought:int = this.getFeatureOptionsKey(BOUGHT_BUNDLE_COUNT) as int;
         if(numBundleBought >= 0)
         {
            currentBundleName = bundleArray[numBundleBought];
         }
         return currentBundleName;
      }
      
      public function getCurrentBundleFriendlyName() : String
      {
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.getCurrentBundleName());
         return farmItem.friendlyTitle;
      }
      
      public function getBundleArrayLenth() : int
      {
         var bundleArray:Array = null;
         var len:int = 0;
         if(Global.flashHotParams.hasOwnProperty(this.ZRUNTIME_KEY_DOLLAR_BUNDLE_ARRAY))
         {
            bundleArray = Global.flashHotParams[this.ZRUNTIME_KEY_DOLLAR_BUNDLE_ARRAY].split(",");
         }
         if(bundleArray)
         {
            len = int(bundleArray.length);
         }
         return len;
      }
      
      public function clearFeatureOptionsForNextBundle() : void
      {
         var valueObj:Object = null;
         var discountArray:Array = [];
         for(var i:int = 0; i < VAL_DISCOUNT_ARRAY_LENGTH; i++)
         {
            valueObj = {};
            valueObj["value"] = 0;
            this.m_DiscountsArray[i] = 0;
            discountArray.push(valueObj);
         }
         var numOfFinishedSpin:int = 0;
         this.saveFeatureOptionsKey(FINISHED_SPIN_COUNT,numOfFinishedSpin as Object);
         this.saveFeatureOptionsKey(DISCOUNTS_ARRAY,discountArray as Object);
      }
      
      public function setDiscountsForSpin(slot:int, discount:int) : void
      {
         var valueObj:Object = null;
         this.m_DiscountsArray[slot] = discount;
         var discountArray:Array = [];
         for(var i:int = 0; i < VAL_DISCOUNT_ARRAY_LENGTH; i++)
         {
            valueObj = {};
            valueObj["value"] = this.m_DiscountsArray[i];
            discountArray.push(valueObj);
         }
         this.saveFeatureOptionsKey(DISCOUNTS_ARRAY,discountArray as Object);
      }
      
      public function getTimeRemaining() : String
      {
         var remainingTime:Number = NaN;
         var result:String = "0 Hours";
         if(!this.isExpired())
         {
            remainingTime = this.m_endTimeStamp - GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            result = FarmGameUtil.toFriendlyTime(remainingTime);
         }
         return result;
      }
      
      public function isExpired() : Boolean
      {
         var result:Boolean = true;
         var config:XML = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         if(config != null)
         {
            this.m_endTimeStamp = FarmGameUtil.synchronizedDateToNumber(this.getEndTimeforFeature()) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         }
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(this.m_endTimeStamp > 0 && this.m_endTimeStamp > currentTime)
         {
            result = false;
         }
         return result;
      }
      
      public function isStarted() : Boolean
      {
         var startTime:Number = NaN;
         var result:Boolean = false;
         var config:XML = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         if(config != null)
         {
            startTime = FarmGameUtil.synchronizedDateToNumber(this.getStartTimeforFeature()) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         }
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(startTime > 0 && startTime < currentTime)
         {
            result = true;
         }
         return result;
      }
      
      public function getEndTimeforFeature() : String
      {
         var endTime:String = null;
         if(Global.flashHotParams.hasOwnProperty(this.ZRUNTIME_KEY_DOLLAR_BUNDLE_END_TIME))
         {
            endTime = String(Global.flashHotParams[this.ZRUNTIME_KEY_DOLLAR_BUNDLE_END_TIME]);
         }
         return endTime;
      }
      
      public function getStartTimeforFeature() : String
      {
         var startTime:String = null;
         if(Global.flashHotParams.hasOwnProperty(this.ZRUNTIME_KEY_DOLLAR_BUNDLE_START_TIME))
         {
            startTime = String(Global.flashHotParams[this.ZRUNTIME_KEY_DOLLAR_BUNDLE_START_TIME]);
         }
         return startTime;
      }
      
      public function isNextBundleVisible() : Boolean
      {
         var result:Boolean = false;
         var variant:Number = Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_DOLLAR_BUNDLES);
         if(variant == VARIANT_COUNTER)
         {
            result = true;
         }
         else
         {
            result = false;
         }
         return result;
      }
      
      public function getNextBundleName() : String
      {
         var bundleArray:Array = null;
         var nextBundleIndex:int = 0;
         var nextBundleName:String = null;
         var numBundleBought:int = this.getFeatureOptionsKey(DollarBundlesManager.BOUGHT_BUNDLE_COUNT) as int;
         var bundleArrayLen:int = this.getBundleArrayLenth();
         if(numBundleBought < bundleArrayLen - 1)
         {
            bundleArray = new Array();
            if(Global.flashHotParams.hasOwnProperty(this.ZRUNTIME_KEY_DOLLAR_BUNDLE_ARRAY))
            {
               bundleArray = Global.flashHotParams[this.ZRUNTIME_KEY_DOLLAR_BUNDLE_ARRAY].split(",");
            }
            nextBundleIndex = numBundleBought + 1;
            if(numBundleBought >= 0)
            {
               nextBundleName = bundleArray[nextBundleIndex];
            }
         }
         return nextBundleName;
      }
      
      public function shouldTaskBeShown() : Boolean
      {
         var isActive:Boolean = false;
         if(this.isExpired() == false && this.isStarted() == true)
         {
            isActive = true;
         }
         var storedVersion:Number = this.getFeatureOptionsKey(this.DOLLAR_BUNDLE_VERSION) as Number;
         var currentVersion:Number = this.getCurrentVersion();
         if(Boolean(storedVersion) && Boolean(currentVersion) && storedVersion < currentVersion)
         {
            FeatureOptionsManager.resetFeatureOption(FEATURE_NAME);
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"resetFeatureOption",null,null),true);
         }
         if(isActive)
         {
            if(this.getFeatureOptionsKey(PURCHASED_ALL_BUNDLES) as int == 1)
            {
               isActive = false;
            }
         }
         return isActive;
      }
      
      public function setVersion() : void
      {
         var dollarBundleVersion:Number = this.getFeatureOptionsKey(this.DOLLAR_BUNDLE_VERSION) as Number;
         if(!dollarBundleVersion)
         {
            dollarBundleVersion = this.getCurrentVersion();
            this.saveFeatureOptionsKey(this.DOLLAR_BUNDLE_VERSION,dollarBundleVersion);
         }
      }
      
      public function getCurrentVersion() : Number
      {
         var dollarBundleVersion:Number = 0;
         if(Global.flashHotParams.hasOwnProperty(this.ZRUNTIME_KEY_DOLLAR_BUNDLE_VERSION))
         {
            dollarBundleVersion = int(Global.flashHotParams[this.ZRUNTIME_KEY_DOLLAR_BUNDLE_VERSION]);
         }
         return dollarBundleVersion;
      }
   }
}

