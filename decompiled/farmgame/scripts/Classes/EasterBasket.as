package Classes
{
   import Display.EasterBasketDialog;
   import Display.UI;
   
   public class EasterBasket extends RewardCreditsBuilding
   {
      
      public static const DIALOG_SIDE_ICON:String = "assets/decorations/deco_easterbasket_2_icon.png";
      
      public static const ASK_FOR_CREDITS_FEATURE_NAME:String = "springBasket";
      
      private const INTERVAL_FEED_ICON:String = "assets/decorations/deco_easterbasket_2_icon.png";
      
      private const LOCALE_PREFIX:String = "EasterBasket_";
      
      private const BUNDLE_PREFIX:String = "EasterBasket";
      
      private const NEIGHBOR_PASS_FEED_FLAG_NAME:String = "easterPassNeighbor";
      
      public function EasterBasket(buildingType:String = null)
      {
         super(buildingType,"easterBasket");
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         if(!Global.player.getSeenFlag("easterOpen"))
         {
            Global.player.setSeenFlag("easterOpen");
            UI.displayStorageDialog(new EasterBasketDialog(this,true));
         }
         else
         {
            UI.displayStorageDialog(new EasterBasketDialog(this,false));
         }
      }
      
      override public function onBuildComplete(result:Object) : void
      {
         super.onBuildComplete(result);
         this.displayStorageDialog();
      }
      
      override public function getLocKeyPrefix() : String
      {
         return this.LOCALE_PREFIX;
      }
      
      override public function getBundlePrefix() : String
      {
         return this.BUNDLE_PREFIX;
      }
      
      override public function getDialogSideIconUrl() : String
      {
         return DIALOG_SIDE_ICON;
      }
      
      override public function getLevelIconUrl() : String
      {
         return "assets/decorations/deco_easterbasket_" + (getCurrentSuffix() + 1) + "_icon.png";
      }
      
      override public function getIntervalFeedIconUrl() : String
      {
         return this.INTERVAL_FEED_ICON;
      }
      
      override protected function getNeighborPassFeedFlagName() : String
      {
         return this.NEIGHBOR_PASS_FEED_FLAG_NAME;
      }
   }
}

