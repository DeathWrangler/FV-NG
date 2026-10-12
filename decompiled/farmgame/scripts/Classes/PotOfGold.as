package Classes
{
   import Display.PotOfGoldDialog;
   import Display.UI;
   
   public class PotOfGold extends RewardCreditsBuilding
   {
      
      public static const DIALOG_SIDE_ICON:String = "assets/decorations/deco_potofgold_2_icon.png";
      
      public static const ASK_FOR_CREDITS_FEATURE_NAME:String = "potOfGold";
      
      private const INTERVAL_FEED_ICON:String = "assets/decorations/deco_potofgold_5_icon.png";
      
      private const LOCALE_PREFIX:String = "PotOfGold_";
      
      private const BUNDLE_PREFIX:String = "PotOfGold";
      
      private const NEIGHBOR_PASS_FEED_FLAG_NAME:String = "potOfGoldPassNeighbor";
      
      public function PotOfGold(buildingType:String = null)
      {
         super(buildingType,"potOfGold");
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         if(!Global.player.getSeenFlag("PotOfGoldExpiration"))
         {
            Global.player.setSeenFlag("PotOfGoldExpiration");
            UI.displayStorageDialog(new PotOfGoldDialog(this,true));
         }
         else
         {
            UI.displayStorageDialog(new PotOfGoldDialog(this,false));
         }
      }
      
      override public function onBuildComplete(result:Object) : void
      {
         super.onBuildComplete(result);
         UI.displayStorageDialog(new PotOfGoldDialog(this,true));
      }
      
      override protected function getCreditsRewardInterval() : int
      {
         return Global.farmGameSettingsManager.getInt(m_creditsFeatureName + "CreditsRewardInterval");
      }
      
      override protected function getMinCreditsToPassNeighbor() : uint
      {
         return Global.farmGameSettingsManager.getInt(m_creditsFeatureName + "MinCreditsToPassNeighbor");
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
         return "assets/decorations/deco_potofgold_" + (getCurrentSuffix() + 1) + "_icon.png";
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

