package Managers
{
   import Classes.Constants.Experiments;
   import Display.UI;
   import Widgets.Windows.ConsumableBundleBuyWindow;
   
   public class ConsumableBundleManager extends BaseFeatureManager
   {
      
      private static const BUY_WINDOW_URL:String = "assets/dialogs/ConsumableBundles/FV_ConsumableBundles.swf";
      
      private static const unwitherPackages:Array = new Array("pkg_unwitherconsumablebundle_1","pkg_unwitherconsumablebundle_3","pkg_unwitherconsumablebundle_5");
      
      private static const packageCostArray:Array = new Array(20,30,40);
      
      private static const ZRUNTIME_KEY_CONSUMABLE_BUNDLE_ARRAY:String = "CONSUMABLE_BUNDLE_ARRAY";
      
      private static const ZRUNTIME_KEY_CONSUMABLE_BUNDLE_COST_ARRAY:String = "CONSUMABLE_BUNDLE_COST_ARRAY";
      
      private var m_buyWindow:ConsumableBundleBuyWindow;
      
      public function ConsumableBundleManager(featureName:String)
      {
         super(featureName);
      }
      
      public static function getInstance(featureName:String = "consumable_bundle") : ConsumableBundleManager
      {
         return getInstanceOfClass(featureName,ConsumableBundleManager) as ConsumableBundleManager;
      }
      
      public function get mainWindowURL() : String
      {
         return BUY_WINDOW_URL;
      }
      
      public function handleHUDClick(showEATutorialPage:Boolean = false) : void
      {
         FarmStatsManager.count("consumable_bundle","Main_UI","buy_window");
         this.m_buyWindow = new ConsumableBundleBuyWindow(m_featureName,this.mainWindowURL);
         UI.displayPopup(this.m_buyWindow);
      }
      
      public function ongettingPackagesFromRuntime(result:Object) : void
      {
         if(this.m_buyWindow)
         {
            this.m_buyWindow.ongettingPackagesFromRuntime(result);
         }
      }
      
      public function get buyConsumableWindow() : ConsumableBundleBuyWindow
      {
         return this.m_buyWindow;
      }
      
      public function getPackageToSell() : Array
      {
         var packageArray:Array = unwitherPackages;
         if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_KEY_CONSUMABLE_BUNDLE_ARRAY))
         {
            packageArray = Global.flashHotParams[ZRUNTIME_KEY_CONSUMABLE_BUNDLE_ARRAY].split(",");
         }
         return packageArray;
      }
      
      public function getPackageCost() : Array
      {
         var packageCost:Array = packageCostArray;
         if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_KEY_CONSUMABLE_BUNDLE_COST_ARRAY))
         {
            packageCost = Global.flashHotParams[ZRUNTIME_KEY_CONSUMABLE_BUNDLE_COST_ARRAY].split(",");
         }
         return packageCost;
      }
      
      public function canDisplayPopup() : Boolean
      {
         var result:Boolean = false;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_CONSUMABLE_BUNDLE) > 0)
         {
            result = true;
         }
         return result;
      }
   }
}

