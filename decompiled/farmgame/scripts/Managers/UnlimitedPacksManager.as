package Managers
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   
   public class UnlimitedPacksManager extends BaseFeatureManager
   {
      
      public static const FEATURE_NAME:String = "unlimited_packs";
      
      public static const SERVICE_CLASS:String = "UnlimitedPacksService";
      
      public static const ON_BUY_BUNDLE:String = "onBuyBundle";
      
      public static const ON_GET_MANAGED_SALES:String = "onGetManagedSales";
      
      public static const KEY_BOUGHT_BUNDLE:String = "1";
      
      public static const KEY_EXP_TIME_STAMP:String = "2";
      
      public var FEATURE_END_DATE:String;
      
      public var BUNDLE_ITEM_NAME:String;
      
      public var BUNDLED_ITEMS:Object;
      
      public var SALE_DURATION:int = 7;
      
      public function UnlimitedPacksManager(featureName:String = "unlimited_packs")
      {
         super(featureName);
         this.populateFeatureConfig();
      }
      
      public static function getInstance(featureName:String = "unlimited_packs") : UnlimitedPacksManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,UnlimitedPacksManager) as UnlimitedPacksManager;
      }
      
      private function populateFeatureConfig() : void
      {
         if(m_featureConfig)
         {
            this.BUNDLE_ITEM_NAME = m_featureConfig.item.@name.toString();
            this.FEATURE_END_DATE = m_featureConfig.listEndDate;
            this.BUNDLED_ITEMS = this.getBundledItems(this.BUNDLE_ITEM_NAME);
         }
      }
      
      private function getBundledItems(bundleName:String) : Object
      {
         var item:FarmItem = null;
         var bundledItems:Object = null;
         if(bundleName)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(bundleName);
            if(item)
            {
               bundledItems = item.getItemPackageHash();
            }
         }
         return bundledItems;
      }
      
      private function getFeatureOption(bundleName:String) : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,bundleName);
      }
      
      private function setFeatureOption(bundleName:String, data:Object) : void
      {
         if(data)
         {
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,bundleName,data);
         }
      }
      
      public function isUnlimitedPackAvailable() : Boolean
      {
         var result:Boolean = false;
         var data:Object = this.getFeatureOption(this.BUNDLE_ITEM_NAME);
         if(Boolean(data) && Boolean(data.hasOwnProperty(KEY_BOUGHT_BUNDLE)) && data.hasOwnProperty(KEY_EXP_TIME_STAMP))
         {
            if(data[KEY_BOUGHT_BUNDLE] == 1 && GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND <= data[KEY_EXP_TIME_STAMP])
            {
               result = true;
            }
         }
         return result;
      }
      
      public function isItemInUnlimitedPack(itemName:String) : Boolean
      {
         var result:Boolean = false;
         if(this.BUNDLED_ITEMS)
         {
            if(this.BUNDLED_ITEMS.hasOwnProperty(itemName))
            {
               result = true;
            }
         }
         return result;
      }
      
      public function onBuyBundle() : void
      {
         var item:FarmItem = null;
         var data:Object = null;
         if(this.BUNDLE_ITEM_NAME)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(this.BUNDLE_ITEM_NAME);
            if(item)
            {
               if(Global.player.canBuyCash(item.cash))
               {
                  Global.player.cash -= item.cash;
                  data = {};
                  data[KEY_BOUGHT_BUNDLE] = 1;
                  data[KEY_EXP_TIME_STAMP] = int(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND + FarmGameUtil.NUM_SECS_IN_DAY * this.SALE_DURATION);
                  this.setFeatureOption(this.BUNDLE_ITEM_NAME,data);
                  TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,ON_BUY_BUNDLE,this.onBuyBundleCallBack,[FEATURE_NAME]));
               }
            }
         }
      }
      
      private function onBuyBundleCallBack(result:Object) : void
      {
         if(result)
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,ON_GET_MANAGED_SALES,this.onGetManagedSalesCallBack,[FEATURE_NAME]));
         }
      }
      
      private function onGetManagedSalesCallBack(result:Object) : void
      {
         if(result)
         {
            if(result.managedSales)
            {
               Global.managedSalesManager.setManagedSales(result.managedSales);
               UI.displayMarketDialog(FEATURE_NAME,"limited",null,"all",null,null,"limitedStart","desc");
            }
         }
      }
      
      public function getSaleEndTimeForUser() : int
      {
         var data:Object = null;
         var endTime:int = 0;
         if(m_featureConfig)
         {
            data = this.getFeatureOption(this.BUNDLE_ITEM_NAME);
            if(Boolean(data) && data.hasOwnProperty(KEY_EXP_TIME_STAMP))
            {
               endTime = int(data[KEY_EXP_TIME_STAMP]);
            }
         }
         return endTime;
      }
   }
}

