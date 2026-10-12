package Classes.BuyerPromo
{
   import Classes.StarterPack.StarterPack;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Transactions.TRefreshBuyerPromo;
   import Widgets.Windows.Market.MarketBuyStarterPackWindow;
   import flash.external.ExternalInterface;
   
   public class BuyerPromoUtility
   {
      
      public static const CURRENT_PROMO_FEATURE:String = "buyerPromo";
      
      public static const PROMO_NAME:String = "promoName";
      
      public static const PROMO_TYPE:String = "promoType";
      
      public static const PROMO_BUYER_TYPE:String = "bucket";
      
      public static const PROMO_GIFTS:String = "gifts";
      
      public static const PROMO_TIMER:String = "timer";
      
      public static const PROMO_BACKOFF:String = "backoff";
      
      public static const PROMO_BACKOFF_LIMIT:String = "backoffLimit";
      
      public static const PROMO_STARTERPACK:String = "starter_pack";
      
      public static const PROMO_STARTERPACK_COST:String = "starterPackCost";
      
      public static const PROMO_TIERED_GIFTS:String = "tiered_gifts";
      
      public static const PROMO_DISCOUNT:String = "discount";
      
      public static const PROMO_DISCOUNT_SIZE:String = "discount_size";
      
      public static const PROMO_END:String = "endOfInterstitial";
      
      public static const PROMO_SUPRESSED:String = "supressed";
      
      public static const PROMO_SHOW_TOASTER:String = "showToaster";
      
      public static const PROMO_STAT:String = "buyer_promos";
      
      public function BuyerPromoUtility()
      {
         super();
      }
      
      public static function getCurrentPromoRemainingTime() : Number
      {
         var activePromoEndTime:Number = NaN;
         var now:Number = NaN;
         var returnVal:Number = 0;
         var supressed:Boolean = FeatureOptionsManager.getInstance().getFeatureOption(CURRENT_PROMO_FEATURE,PROMO_SUPRESSED) as Boolean;
         if(!supressed)
         {
            activePromoEndTime = (FeatureOptionsManager.getInstance().getFeatureOption(CURRENT_PROMO_FEATURE,PROMO_END) as Number) * FarmGameUtil.NUM_MSECS_IN_SECOND;
            now = GlobalEngine.getTimer();
            returnVal = Math.max(activePromoEndTime - now,0);
         }
         return returnVal;
      }
      
      public static function getCurrentPromoType() : String
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(CURRENT_PROMO_FEATURE,PROMO_TYPE) as String;
      }
      
      public static function getCurrentPromoName() : String
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(CURRENT_PROMO_FEATURE,PROMO_NAME) as String;
      }
      
      public static function getCurrentPromoBuyerType() : String
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(CURRENT_PROMO_FEATURE,PROMO_BUYER_TYPE) as String;
      }
      
      public static function getCurrentPromoStarterPack() : StarterPack
      {
         var starterName:String = null;
         var activeStarterPack:StarterPack = null;
         var activePromoType:String = getCurrentPromoType();
         if(activePromoType == "starter_pack")
         {
            starterName = FeatureOptionsManager.getInstance().getFeatureOption(CURRENT_PROMO_FEATURE,PROMO_STARTERPACK) as String;
            activeStarterPack = Global.farmGameSettingsManager.getStarterPackByName(starterName);
         }
         return activeStarterPack;
      }
      
      public static function shouldShowToaster() : Boolean
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(CURRENT_PROMO_FEATURE,PROMO_SHOW_TOASTER) as Boolean;
      }
      
      public static function displayFlashSalePromo() : void
      {
         var activePromoName:String = null;
         var activePromoBuyerType:String = null;
         if(ExternalInterface.available)
         {
            activePromoName = getCurrentPromoName();
            activePromoBuyerType = getCurrentPromoBuyerType();
            FarmStatsManager.count(PROMO_STAT,activePromoBuyerType,activePromoName,"dialog_view","hud_icon");
            FarmStatsManager.count("payment","in_app",PROMO_STAT,activePromoName,"view");
            ExternalInterface.call("flashSaleRepop");
         }
      }
      
      public static function displayStarterPackPromo() : void
      {
         var starterFarmItem:FarmItem = null;
         var paymentRef:String = null;
         var activePromoName:String = getCurrentPromoName();
         var activePromoBuyerType:String = getCurrentPromoBuyerType();
         var activePromoType:String = getCurrentPromoType();
         var activeStarterPack:StarterPack = getCurrentPromoStarterPack();
         if(activeStarterPack)
         {
            FarmStatsManager.count("payment","in_app",PROMO_STAT,activePromoName,"view");
            FarmStatsManager.count(PROMO_STAT,activePromoBuyerType,activePromoName,"dialog_view","hud_icon");
            starterFarmItem = Global.farmGameSettingsManager.getFarmItemByName("starter_pack");
            paymentRef = "promo_" + activePromoName;
            UI.displayPopup(new MarketBuyStarterPackWindow(starterFarmItem,onStarterPackWindowBuy,onStarterPackWindowCancel,null,activeStarterPack,paymentRef),false);
         }
      }
      
      private static function onStarterPackWindowCancel(item:FarmItem) : void
      {
         var activePromoName:String = getCurrentPromoName();
         var activePromoBuyerType:String = getCurrentPromoBuyerType();
         FarmStatsManager.count(PROMO_STAT,activePromoBuyerType,activePromoName,"click","X");
      }
      
      private static function onStarterPackWindowBuy(item:FarmItem) : void
      {
         var activePromoName:String = getCurrentPromoName();
         var activePromoBuyerType:String = getCurrentPromoBuyerType();
         var activeStarterPack:StarterPack = getCurrentPromoStarterPack();
         if(activeStarterPack)
         {
            FarmStatsManager.count("payment","in_app",PROMO_STAT,activePromoName,"click");
            FarmStatsManager.count(PROMO_STAT,activePromoBuyerType,activePromoName,"click","buy",activeStarterPack.cost as String);
         }
         FeatureOptionsManager.getInstance().setFeatureOption(CURRENT_PROMO_FEATURE,PROMO_END,Object(0));
      }
      
      public static function refreshCurrentPromo() : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(CURRENT_PROMO_FEATURE,PROMO_TYPE,Object(""));
         FeatureOptionsManager.getInstance().setFeatureOption(CURRENT_PROMO_FEATURE,PROMO_END,Object(0));
         TransactionManager.addTransaction(new TRefreshBuyerPromo(),false);
      }
   }
}

