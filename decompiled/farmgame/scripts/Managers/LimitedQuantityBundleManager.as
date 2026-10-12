package Managers
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.ImpulseBuy;
   import Display.QueuedIcons.MultipleToolTipIcon;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Transactions.TGetLQBundleRemaining;
   import Widgets.Windows.LimitedQuantityBundleCongratsWindow;
   import com.adobe.utils.StringUtil;
   
   public class LimitedQuantityBundleManager
   {
      
      private static var m_instance:LimitedQuantityBundleManager;
      
      public static const EL_DORADO_BUNDLE_NAME:String = "pkg_oasis_bundle";
      
      public static const FEATURE_NAME:String = "fv_limited_qty_bundle_v2";
      
      public static const ZRUNTIME_KEY_ITEMMAP:String = "LIMITED_QTY_BUNDLE_ITEMMAP";
      
      public static const ZRUNTIME_KEY_START:String = "LIMITED_QTY_BUNDLE_START";
      
      private const FEATURE_VALIDITY_DAYS:int = 2;
      
      private const VARIANT_NO_COUNTER:Number = 1;
      
      private const VARIANT_COUNTER:Number = 2;
      
      private var m_activeItemName:String;
      
      private var m_featureName:String;
      
      protected var m_featureConfig:XML;
      
      protected var m_startDate:String;
      
      private const LQ_BUNDLE_2018_PRICE:int = 299;
      
      public function LimitedQuantityBundleManager(enforcer:SingletonEnforcer)
      {
         super();
         this.m_featureName = "";
         this.m_activeItemName = "";
      }
      
      public static function getInstance() : LimitedQuantityBundleManager
      {
         if(!m_instance)
         {
            m_instance = new LimitedQuantityBundleManager(new SingletonEnforcer());
         }
         return m_instance;
      }
      
      public function isCounterVisible() : Boolean
      {
         var result:Boolean = false;
         var expManager:ExperimentManager = new ExperimentManager();
         var variant:Number = Global.eosManager.getEosVariant("fv_limited_qty_bundle_v2_6");
         result = false;
         if(variant >= 0)
         {
            result = true;
         }
         return result;
      }
      
      public function showCongratulationsWindow(itemName:String) : void
      {
         var asset:XML = null;
         var dialogPath:String = "";
         this.m_featureConfig = Global.farmGameSettingsManager.getFeatureXML(this.m_featureName);
         if(this.m_featureConfig.assets != "")
         {
            for each(asset in this.m_featureConfig.assets.asset)
            {
               if(asset.@name == itemName)
               {
                  dialogPath = asset.@path.toString();
               }
            }
         }
         var worldName:String = this.getWorldTypeForLandExpansion(itemName);
         var congratsWindow:LimitedQuantityBundleCongratsWindow = new LimitedQuantityBundleCongratsWindow(dialogPath,itemName,worldName);
         UI.displayPopup(congratsWindow);
      }
      
      public function getBundlePurchaseStatus(featureName:String, bundleName:String) : Boolean
      {
         var item:XML = null;
         var result:Boolean = false;
         var featureOptionsObj:Object = FeatureOptionsManager.getInstance().getFeatureData(featureName);
         this.m_featureConfig = Global.farmGameSettingsManager.getFeatureXML(featureName);
         if(this.m_featureConfig.items != "" && featureOptionsObj != null)
         {
            for each(item in this.m_featureConfig.items.item)
            {
               if(item.@name == bundleName && featureOptionsObj[item.@name] == 1)
               {
                  result = true;
                  break;
               }
            }
         }
         return result;
      }
      
      public function startBuyTransaction(featureName:String) : void
      {
         var item:XML = null;
         var lqBundleItem:FarmItem = null;
         var itemPurchaseCode:String = null;
         this.m_featureName = featureName;
         this.m_activeItemName = "";
         var featureOptionsObj:Object = FeatureOptionsManager.getInstance().getFeatureData(featureName);
         this.m_featureConfig = Global.farmGameSettingsManager.getFeatureXML(this.m_featureName);
         if(this.m_featureConfig.items != "")
         {
            for each(item in this.m_featureConfig.items.item)
            {
               if(featureOptionsObj[item.@name] == -1)
               {
                  this.m_activeItemName = item.@name.toString();
                  break;
               }
            }
         }
         if(this.m_activeItemName)
         {
            lqBundleItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_activeItemName);
            itemPurchaseCode = lqBundleItem.code;
            if(itemPurchaseCode)
            {
               if(Global.player.cash < this.LQ_BUNDLE_2018_PRICE)
               {
                  UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",this.LQ_BUNDLE_2018_PRICE,lqBundleItem.type);
                  FarmStatsManager.count("LQBundle_Aug2019","Buyflow","not_enough_cash");
               }
               else
               {
                  TransactionManager.addTransaction(new TGenericTransaction("LimitedQuantityBundleService","BuyBundle",this.onPaymentConfirmation,[itemPurchaseCode]),true);
               }
            }
         }
      }
      
      private function onPaymentConfirmation(result:Object = null) : void
      {
         var errorMsg:String = null;
         if(result)
         {
            if(!result.hasOwnProperty("error"))
            {
               this.onPaymentSuccess();
            }
            else
            {
               errorMsg = "";
               if(result.hasOwnProperty("errorMessage"))
               {
                  errorMsg = result.errorMessage;
               }
               this.onPaymentFailure(errorMsg);
            }
         }
      }
      
      private function onPaymentSuccess() : void
      {
         Global.player.cash -= this.LQ_BUNDLE_2018_PRICE;
         FarmStatsManager.count("limited_qty_bundle","PaymentSuccess","completed",this.m_activeItemName);
         FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,this.m_activeItemName,1);
         this.showCongratulationsWindow(this.m_activeItemName);
      }
      
      private function onPaymentFailure(errorMessage:String = "") : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,this.m_activeItemName,"0");
         this.m_activeItemName = "";
         FarmStatsManager.count("limited_qty_bundle","PaymentError",errorMessage);
         UI.showMessage("Payment failed. Please try again.");
      }
      
      public function updateUIWithItemsRemaining(itemName:String, onCompleteCallback:Function = null, performImmediately:Boolean = false) : void
      {
         TransactionManager.addTransaction(new TGetLQBundleRemaining(itemName,onCompleteCallback),performImmediately);
      }
      
      public function setBundleToBuy(itemName:String, featureName:String, onCompleteCallback:Function = null) : void
      {
         this.m_featureName = featureName;
         FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,itemName,"-1");
         if(onCompleteCallback != null)
         {
            onCompleteCallback(null);
         }
      }
      
      public function getTimeRemaining(featureName:String) : Number
      {
         var result:Number = -1;
         var now:int = int(GlobalEngine.serverTime / 1000);
         var featureStartTime:Number = 0;
         var keyFeatureStart:String = featureName + MultipleToolTipIcon.FEATURE_START_FLAG;
         if(keyFeatureStart)
         {
            featureStartTime = Global.player.getFeatureLastShown(keyFeatureStart);
         }
         if(featureStartTime == 0 && Global.flashHotParams.hasOwnProperty(LimitedQuantityBundleManager.ZRUNTIME_KEY_START))
         {
            featureStartTime = FarmGameUtil.synchronizedDateToNumber(Global.flashHotParams[LimitedQuantityBundleManager.ZRUNTIME_KEY_START].toString()) / FarmGameUtil.NUM_MSECS_IN_SECOND;
            Global.player.setFeatureLastShown(keyFeatureStart,featureStartTime,false);
         }
         if(featureStartTime != 0)
         {
            result = featureStartTime + FarmGameUtil.NUM_SECS_IN_DAY * this.FEATURE_VALIDITY_DAYS - now;
         }
         return result;
      }
      
      private function getMappedItemCode(itemCode:String) : String
      {
         var count:int = 0;
         var codeString:String = null;
         var i:int = 0;
         var code:Array = null;
         var runtimeString:String = "5:1835891299=mmzc,5:896756073=5sii";
         var result:String = "";
         if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_KEY_ITEMMAP))
         {
            runtimeString = Global.flashHotParams[ZRUNTIME_KEY_ITEMMAP].toString();
         }
         var codes:Array = runtimeString.split(",");
         if(codes)
         {
            count = int(codes.length);
            for(i = 0; i < count; i++)
            {
               codeString = StringUtil.trim(codes[i]);
               code = codeString.split("=");
               if(Boolean(code) && Boolean(code.length == 2) && StringUtil.trim(code[1]) == itemCode)
               {
                  result = StringUtil.trim(code[0]);
                  break;
               }
            }
         }
         return result;
      }
      
      public function getWorldTypeForLandExpansion(packageName:String) : String
      {
         var farmObj:FarmItem = null;
         var itemName:String = null;
         var requirement:Object = null;
         var result:String = "";
         var bundleItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(packageName);
         var itemPackageHash:Object = bundleItem.getItemPackageHash();
         if(itemPackageHash != null)
         {
            for(itemName in itemPackageHash)
            {
               farmObj = Global.farmGameSettingsManager.getFarmItemByName(itemName);
               if(Boolean(farmObj) && Boolean(farmObj.requirements))
               {
                  for each(requirement in farmObj.requirements)
                  {
                     if(requirement["identifier"] == "world")
                     {
                        result = requirement["worldId"];
                        break;
                     }
                  }
               }
               if(result != "")
               {
                  break;
               }
            }
         }
         return result;
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
