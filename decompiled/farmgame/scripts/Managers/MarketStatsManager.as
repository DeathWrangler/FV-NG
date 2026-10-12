package Managers
{
   import Widgets.Frames.Market.MarketMiniSlotFrame;
   import Widgets.Windows.Market.MarketPreviewWindow;
   
   public class MarketStatsManager
   {
      
      protected static const COUNTER_MARKET:String = "market";
      
      protected static const COUNTER_ACTIVITY:String = "mp2_activity";
      
      protected static const COUNTER_SORT:String = "mp2_sort";
      
      protected static const COUNTER_CASH_CROPS:String = "cash_crops";
      
      private static const SEEN_CASH_CROPS_LICENSE_BUY:String = "cashCropsLicenseBuy";
      
      private static const SEEN_CASH_CROPS_ITEM_BUY:String = "cashCropsItemBuy";
      
      private static const COUNTER_MARKETPLACE:String = "marketplace";
      
      private static const SEEN_MARKET:String = "view_market";
      
      private static const CLICK_MARKET:String = "click";
      
      private static const PREVIEW_ITEM:String = "preview";
      
      private static const INFO_ITEM:String = "info";
      
      private static const BUY_ITEM:String = "buy";
      
      private static const MARKET_SEARCH:String = "search";
      
      private static const BUY_CASH:String = "buy_cash";
      
      private static const CLOSE_MARKET:String = "close";
      
      private static const OPEN_MARKET:String = "open_market";
      
      private static const COUNTER_MARKET_AD:String = "market_ad";
      
      private static const AD_VIEW:String = "view";
      
      private static const AD_CLICK:String = "click";
      
      public function MarketStatsManager()
      {
         super();
      }
      
      public static function countBuyItem(viewSource:String, type:String, itemName:String, subType:String, subSubType:String, value:int = 1) : void
      {
         if(subType == "all")
         {
            subType = "";
            subSubType = "";
         }
         else if(subSubType == "all")
         {
            subSubType = "";
         }
         FarmStatsManager.count(COUNTER_MARKET,viewSource,type,"buy_" + itemName,subType,subSubType,value);
      }
      
      public static function countBuyItem2(itemName:String, currency:String, cost:int, pageNumber:int) : void
      {
         var classField:String = MarketPreviewWindow.marketPreviewActive ? "preview_window" : CLICK_MARKET;
         FarmStatsManager.featureSample(COUNTER_MARKETPLACE,classField,currency + "_buy",itemName + ":" + cost,pageNumber.toString());
      }
      
      public static function countOpenWindow(type:String) : void
      {
         FarmStatsManager.featureSample(COUNTER_MARKETPLACE,"open_marketplace",type);
      }
      
      public static function countClickTypeMenu(type:String) : void
      {
         FarmStatsManager.count(COUNTER_ACTIVITY,"click_category",type);
      }
      
      public static function countClickGetCurrency() : void
      {
         FarmStatsManager.count(COUNTER_ACTIVITY,"add_farm_cash");
      }
      
      public static function countViewPromos(promoName:String = "") : void
      {
         FarmStatsManager.count(COUNTER_MARKET_AD,AD_VIEW,promoName);
      }
      
      public static function countClickPromo(action:String, param:String) : void
      {
         FarmStatsManager.count(COUNTER_ACTIVITY,"promo_click",action,param);
      }
      
      public static function countClickBuyLimited() : void
      {
         FarmStatsManager.count(COUNTER_ACTIVITY,"buy_promo_le");
      }
      
      public static function countClickBuyNew() : void
      {
         FarmStatsManager.count(COUNTER_ACTIVITY,"buy_promo_new");
      }
      
      public static function countClickMarketMiniBuy(itemName:String, buyType:String, buyCost:int, slotFrame:MarketMiniSlotFrame) : void
      {
         FarmStatsManager.featureSample(COUNTER_MARKETPLACE,slotFrame.tabType,buyType + "_buy",itemName + ":" + buyCost,slotFrame.pageNumber.toString());
      }
      
      public static function countClickMarketMiniSend(itemName:String, buyCost:int, slotFrame:MarketMiniSlotFrame) : void
      {
         FarmStatsManager.featureSample(COUNTER_MARKETPLACE,slotFrame.tabType,"send",itemName + ":" + buyCost,slotFrame.pageNumber.toString());
      }
      
      public static function countClickMarketMiniPreview(slotFrame:MarketMiniSlotFrame) : void
      {
         FarmStatsManager.featureSample(COUNTER_MARKETPLACE,slotFrame.tabType,"preview",slotFrame.pageNumber.toString());
      }
      
      public static function countClickMarketMiniPreviewBuy() : void
      {
         FarmStatsManager.featureSample(COUNTER_MARKETPLACE,"best_sellers","preview","buy");
      }
      
      public static function countClickPreview(itemName:String = "") : void
      {
         FarmStatsManager.featureSample(COUNTER_MARKETPLACE,"preview_window",itemName);
      }
      
      public static function countClickPreviewBuy() : void
      {
         FarmStatsManager.featureSample(COUNTER_MARKETPLACE,"preview_window","buy");
      }
      
      public static function countClickSort(type:String, sortBy:String, sortDirection:String) : void
      {
         FarmStatsManager.count(COUNTER_SORT,type,sortBy,sortDirection);
      }
      
      public static function countCashCropsInfoClick(itemName:String) : void
      {
         FarmStatsManager.count(COUNTER_CASH_CROPS,"click_info",itemName);
      }
      
      public static function countCashCropsLicenseBuy(itemName:String) : void
      {
         if(!Global.player.getSeenFlag(SEEN_CASH_CROPS_LICENSE_BUY))
         {
            FarmStatsManager.count(COUNTER_CASH_CROPS,"first_buy",itemName);
            Global.player.setSeenFlag(SEEN_CASH_CROPS_LICENSE_BUY);
         }
         FarmStatsManager.count(COUNTER_CASH_CROPS,"click_buy",itemName);
      }
      
      public static function countCashCropsItemBuy(itemName:String) : void
      {
         if(!Global.player.getSeenFlag(SEEN_CASH_CROPS_ITEM_BUY))
         {
            FarmStatsManager.count(COUNTER_CASH_CROPS,"first_use",itemName);
            Global.player.setSeenFlag(SEEN_CASH_CROPS_ITEM_BUY);
         }
      }
      
      public static function countStarterPackMarketStat(kingdom:String, phylum:String) : void
      {
         FarmStatsManager.count(COUNTER_ACTIVITY,kingdom,phylum);
      }
      
      public static function countViewMarket(category:String = "", tab:String = "", page:String = "") : void
      {
         FarmStatsManager.count(COUNTER_MARKETPLACE,SEEN_MARKET,category,tab,page);
      }
      
      public static function countClickItemPreview() : void
      {
         FarmStatsManager.count(COUNTER_MARKETPLACE,CLICK_MARKET,PREVIEW_ITEM);
      }
      
      public static function countClickBuyItem(name:String, family:String) : void
      {
         FarmStatsManager.count(COUNTER_MARKETPLACE,CLICK_MARKET,BUY_ITEM,name,family);
      }
      
      public static function countSearch(term:String = "") : void
      {
         FarmStatsManager.count(COUNTER_MARKETPLACE,MARKET_SEARCH);
      }
      
      public static function countCloseMarket() : void
      {
         FarmStatsManager.count(COUNTER_MARKETPLACE,CLOSE_MARKET);
      }
      
      public static function countItemInfo() : void
      {
         FarmStatsManager.count(COUNTER_MARKETPLACE,CLICK_MARKET,INFO_ITEM);
      }
      
      public static function countOpenMarketFromToolbox() : void
      {
         FarmStatsManager.count(COUNTER_MARKETPLACE,OPEN_MARKET);
      }
      
      public static function countClickMarketAd(name:String = "") : void
      {
         FarmStatsManager.count(COUNTER_MARKET_AD,AD_CLICK,name);
      }
      
      public static function countLowResolution(width:int = 0) : void
      {
         FarmStatsManager.count("lerevamp","low_resolution","","","","",width);
      }
      
      public static function countTabIndexClick(tab:int = 0) : void
      {
         FarmStatsManager.count("lerevamp","tab_click","","","","",tab);
      }
   }
}

