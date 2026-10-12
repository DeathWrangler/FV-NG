package Managers
{
   import Classes.TutController;
   import Display.UI;
   import Widgets.Windows.CapitalOneIntroToasterWindow;
   import Widgets.Windows.Promotions.CapitalOnePromoPlaceWindow;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.navigateToURL;
   
   public class CapitalOnePromoManager
   {
      
      public static const TOASTER_SEEN:String = "cap1_toaster";
      
      public static const MARKET_AD_SEEN:String = "cap1_marketad";
      
      public static const PLACEMENT_REMINDER_SEEN:String = "cap1_placeseen";
      
      public static const ITEM_PLACED:String = "cap1_itemplaced";
      
      public static const ITEM_RECEIVED:String = "cap1_itemgranted";
      
      public static const PROMO_URL:String = "https://www.facebook.com/capitalone?v=app_163870133677819";
      
      public static const START_DIALOG_ASSET_PATH:String = "assets/dialogs/FV_xpromo_capitalone_start.swf";
      
      public static const TOASTER_ASSET_PATH:String = "assets/dialogs/FV_BannerAd_xpromo_capitalone.swf";
      
      public static const PROMO_PLACEMENT_WINDOW_ASSET_PATH:String = "assets/dialogs/FV_xpromo_capitalone_place.swf";
      
      public static const PROMO_ITEM:String = "visgothstatue";
      
      private static const STAT_COUNTER_CAPITALONE_PROMO:String = "capitalone_promo";
      
      private static const STAT_KINGDOM_PROMO_WELCOME_TOASTER:String = "welcome_toaster";
      
      private static const STAT_KINGDOM_PROMO_MARKET_AD:String = "marketad";
      
      private static const STAT_KINGDOM_PROMO_START_DIALOG:String = "promo_dialog";
      
      private static const STAT_KINGDOM_CONFIRMATION_DIALOG:String = "confirmation_dialog";
      
      private static const STAT_KINGDOM_VISIGOTH_STATUE:String = "visistatue";
      
      private static const VARIANT_NO_PROMO:int = 0;
      
      private static const VARIANT_FULL_PROMO:int = 1;
      
      private static const VARIANT_NO_TOASTER:int = 2;
      
      public function CapitalOnePromoManager()
      {
         super();
      }
      
      public static function isInExperiment() : Boolean
      {
         return false;
      }
      
      public static function launchPromoURL() : void
      {
         countPromoStartDialogClick();
         var request:URLRequest = new URLRequest(PROMO_URL);
         request.method = URLRequestMethod.POST;
         navigateToURL(request,"_blank");
      }
      
      public static function countPromoToasterImpression() : void
      {
         FarmStatsManager.count(STAT_COUNTER_CAPITALONE_PROMO,STAT_KINGDOM_PROMO_WELCOME_TOASTER,"impression");
      }
      
      public static function countPromoToasterClick() : void
      {
         FarmStatsManager.count(STAT_COUNTER_CAPITALONE_PROMO,STAT_KINGDOM_PROMO_WELCOME_TOASTER,"click");
      }
      
      public static function countPromoToasterClose() : void
      {
         FarmStatsManager.count(STAT_COUNTER_CAPITALONE_PROMO,STAT_KINGDOM_PROMO_WELCOME_TOASTER,"close");
      }
      
      public static function countMarketAdClick() : void
      {
         FarmStatsManager.count(STAT_COUNTER_CAPITALONE_PROMO,STAT_KINGDOM_PROMO_MARKET_AD,"click");
      }
      
      public static function countPromoStartDialogImpression() : void
      {
         FarmStatsManager.count(STAT_COUNTER_CAPITALONE_PROMO,STAT_KINGDOM_PROMO_START_DIALOG,"impression");
      }
      
      public static function countPromoStartDialogClick() : void
      {
         FarmStatsManager.count(STAT_COUNTER_CAPITALONE_PROMO,STAT_KINGDOM_PROMO_START_DIALOG,"click_visitcapitalone");
      }
      
      public static function countConfirmationDialogImpression() : void
      {
         FarmStatsManager.count(STAT_COUNTER_CAPITALONE_PROMO,STAT_KINGDOM_CONFIRMATION_DIALOG,"impression");
      }
      
      public static function countConfirmationDialogClose() : void
      {
         FarmStatsManager.count(STAT_COUNTER_CAPITALONE_PROMO,STAT_KINGDOM_CONFIRMATION_DIALOG,"click");
      }
      
      public static function countConfirmationDialogClick() : void
      {
         FarmStatsManager.count(STAT_COUNTER_CAPITALONE_PROMO,STAT_KINGDOM_CONFIRMATION_DIALOG,"close");
      }
      
      public static function countStatueGifted() : void
      {
         FarmStatsManager.count(STAT_COUNTER_CAPITALONE_PROMO,STAT_KINGDOM_VISIGOTH_STATUE,"gifted");
      }
      
      public static function countStatuePlaced() : void
      {
         FarmStatsManager.count(STAT_COUNTER_CAPITALONE_PROMO,STAT_KINGDOM_VISIGOTH_STATUE,"placed");
      }
      
      public static function onPostInit() : Boolean
      {
         var capitalOneIntroToaster:CapitalOneIntroToasterWindow = null;
         var result:Boolean = true;
         if(!Global.player.getSeenFlag(CapitalOnePromoManager.ITEM_PLACED) && isInExperiment())
         {
            if(!Global.worldManager.isVisiting() && TutController.hasFinishedTutorial())
            {
               if(Global.player.hasGiftItem(Global.farmGameSettingsManager.getFarmItemByName(CapitalOnePromoManager.PROMO_ITEM).code))
               {
                  if(!Global.player.getSeenFlag(CapitalOnePromoManager.PLACEMENT_REMINDER_SEEN))
                  {
                     UI.displayPopup(new CapitalOnePromoPlaceWindow());
                     Global.player.setSeenFlag(CapitalOnePromoManager.PLACEMENT_REMINDER_SEEN);
                  }
               }
               else if(!Global.player.getSeenFlag(CapitalOnePromoManager.TOASTER_SEEN) && !Global.player.getSeenFlag(CapitalOnePromoManager.ITEM_RECEIVED) && !Global.player.getSeenFlag(CapitalOnePromoManager.MARKET_AD_SEEN))
               {
                  capitalOneIntroToaster = null;
                  capitalOneIntroToaster = new CapitalOneIntroToasterWindow();
                  ToasterManager.getInstance().add(capitalOneIntroToaster);
               }
            }
            else
            {
               result = false;
            }
         }
         return result;
      }
   }
}

