package Widgets.Windows.Charity
{
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.SeedItem;
   import flash.display.DisplayObject;
   
   public class DonateWindowFactory
   {
      
      private static const FB_FV_URL:String = "https://apps.facebook.com/onthefarm/";
      
      public function DonateWindowFactory()
      {
         super();
      }
      
      public static function getInstance(seedItem:SeedItem = null, onAcceptCallback:Function = null, source:String = null, featureName:String = null) : DisplayObject
      {
         var window:DisplayObject = null;
         if(seedItem)
         {
            if(seedItem.donationCurrency == FarmItem.DONATION_CURRENCY_FC)
            {
               GlobalEngine.info("Donate","Instantiating a FCDonateWindow");
               window = new FCDonateWindow(seedItem,onAcceptCallback,source);
            }
         }
         else if(featureName)
         {
            GlobalEngine.info("Donate","Instantiating a FCMultiDonateWindow");
            window = new FCMultiDonateWindow(null,onAcceptCallback,source,featureName);
         }
         return window;
      }
   }
}

