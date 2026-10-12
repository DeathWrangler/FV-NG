package Managers
{
   import Classes.TutController;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Windows.DreyersToasterWindow;
   
   public class DreyersPromoManager
   {
      
      public static const DREYERS_FRUITBARS_ITEM_NAME:String = "fruitbars";
      
      public static const EDYS_FRUITBARS_ITEM_NAME:String = "fruitbars2";
      
      public static const DREYERS_TOASTER_ASSET_PATH:String = "assets/dialogs/FV_DreyersPromo_Toaster.swf";
      
      public static const EDYS_TOASTER_ASSET_PATH:String = "assets/dialogs/FV_EdysPromo_Toaster.swf";
      
      public static const DREYERS_WHATS_THIS_ASSET_PATH:String = "assets/dialogs/FV_promo_whatisthis_Dreyers.swf";
      
      public static const EDYS_WHATS_THIS_ASSET_PATH:String = "assets/dialogs/FV_promo_whatisthis_Edys.swf";
      
      private static const STAT_COUNTER_DREYERS_PROMO:String = "dreyers_promo";
      
      private static const STAT_COUNTER_EDYS_PROMO:String = "edys_promo";
      
      private static const DREYERS_PROMO_TOASTER_SEEN:String = "dreyers_promo_toaster";
      
      private static const STAT_KINGDOM_PROMO_TOASTER:String = "toaster";
      
      private static const STAT_KINGDOM_PROMO_MARKET_AD:String = "marketad";
      
      private static const STAT_KINGDOM_WHATISTHIS_DIALOG:String = "promo_dialog";
      
      public function DreyersPromoManager()
      {
         super();
      }
      
      public static function isInExperiment() : Boolean
      {
         return false;
      }
      
      public static function countPromoToasterImpression() : void
      {
         FarmStatsManager.count(getStatCounter(),STAT_KINGDOM_PROMO_TOASTER,"impression");
      }
      
      public static function countPromoToasterClick() : void
      {
         FarmStatsManager.count(getStatCounter(),STAT_KINGDOM_PROMO_TOASTER,"click");
      }
      
      public static function countPromoToasterClose() : void
      {
         FarmStatsManager.count(getStatCounter(),STAT_KINGDOM_PROMO_TOASTER,"close");
      }
      
      public static function countMarketAdClick() : void
      {
         FarmStatsManager.count(getStatCounter(),STAT_KINGDOM_PROMO_MARKET_AD,"click");
      }
      
      public static function countPromoDialogImpression() : void
      {
         FarmStatsManager.count(getStatCounter(),STAT_KINGDOM_WHATISTHIS_DIALOG,"impression");
      }
      
      public static function isDreyersRegion() : Boolean
      {
         var bars:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(DREYERS_FRUITBARS_ITEM_NAME);
         return bars.checkGeoGate();
      }
      
      private static function getStatCounter() : String
      {
         var counter:String = null;
         if(isDreyersRegion())
         {
            counter = STAT_COUNTER_DREYERS_PROMO;
         }
         else
         {
            counter = STAT_COUNTER_EDYS_PROMO;
         }
         return counter;
      }
      
      public static function getToasterAssetPath() : String
      {
         var assetPath:String = null;
         if(isDreyersRegion())
         {
            assetPath = DREYERS_TOASTER_ASSET_PATH;
         }
         else
         {
            assetPath = EDYS_TOASTER_ASSET_PATH;
         }
         return assetPath;
      }
      
      public static function getWhatsThisAssetPath() : String
      {
         var assetPath:String = null;
         if(isDreyersRegion())
         {
            assetPath = DREYERS_WHATS_THIS_ASSET_PATH;
         }
         else
         {
            assetPath = EDYS_WHATS_THIS_ASSET_PATH;
         }
         return assetPath;
      }
      
      public static function setToasterSeenFlag() : void
      {
         Global.player.setSeenFlag(DREYERS_PROMO_TOASTER_SEEN);
      }
      
      private static function getToasterSeenFlags() : Boolean
      {
         return Global.player.getSeenFlag(DREYERS_PROMO_TOASTER_SEEN);
      }
      
      public static function getToasterLocalizedText() : String
      {
         var localizedText:String = null;
         if(isDreyersRegion())
         {
            localizedText = ZLocUtils.t("Dialogs","DreyersToasterText");
         }
         else
         {
            localizedText = ZLocUtils.t("Dialogs","EdysToasterText");
         }
         return localizedText;
      }
      
      public static function getWhatIsThisLocalizedText() : String
      {
         var localizedText:String = null;
         if(isDreyersRegion())
         {
            localizedText = ZLocUtils.t("Dialogs","DreyersWhatIsThis_Body");
         }
         else
         {
            localizedText = ZLocUtils.t("Dialogs","EdysWhatIsThis_Body");
         }
         return localizedText;
      }
      
      public static function getWhatIsThisLocalizedCropTitle() : String
      {
         var localizedText:String = null;
         if(isDreyersRegion())
         {
            localizedText = ZLocUtils.t("Dialogs","DreyersWhatIsThis_CropTitle");
         }
         else
         {
            localizedText = ZLocUtils.t("Dialogs","EdysWhatIsThis_CropTitle");
         }
         return localizedText;
      }
      
      public static function onPostInit() : Boolean
      {
         var dreyersToaster:DreyersToasterWindow = null;
         var result:Boolean = true;
         if(isInExperiment())
         {
            if(!Global.worldManager.isVisiting() && TutController.hasFinishedTutorial())
            {
               if(!getToasterSeenFlags())
               {
                  dreyersToaster = null;
                  dreyersToaster = new DreyersToasterWindow();
                  ToasterManager.getInstance().add(dreyersToaster);
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

