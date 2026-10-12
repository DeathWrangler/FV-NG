package Classes
{
   import Display.TuscanWeddingDialog;
   import Display.UI;
   import Managers.FarmStatsManager;
   
   public class TuscanWedding extends RewardCreditsBuilding
   {
      
      public static const DIALOG_SIDE_ICON:String = "assets/decorations/tuscany_wedding_2_icon.png";
      
      private const INTERVAL_FEED_ICON:String = "assets/decorations/tuscany_wedding_2_icon.png";
      
      private const SUBCREDITS_TRADE_ICON:String = "assets/decorations/tuscany_wedding_2_icon.png";
      
      private const LOCALE_PREFIX:String = "TuscanWedding_";
      
      private const BUNDLE_PREFIX:String = "TuscanWedding";
      
      private const NEIGHBOR_PASS_FEED_FLAG_NAME:String = "tuscanPassNeighbor";
      
      public function TuscanWedding(buildingType:String = null)
      {
         super(buildingType,"tuscanWedding");
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         if(!Global.player.getSeenFlag("tuscanWeddingOpen"))
         {
            Global.player.setSeenFlag("tuscanWeddingOpen");
            UI.displayStorageDialog(new TuscanWeddingDialog(this,true));
         }
         else
         {
            UI.displayStorageDialog(new TuscanWeddingDialog(this,false));
         }
         FarmStatsManager.count("tuscanWedding","open_wedding");
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
         return "assets/decorations/tuscany_wedding_" + (getCurrentSuffix() + 1) + "_icon.png";
      }
      
      override public function getIntervalFeedIconUrl() : String
      {
         return this.INTERVAL_FEED_ICON;
      }
      
      override public function getSubcreditsTradeFeedUrl() : String
      {
         return this.SUBCREDITS_TRADE_ICON;
      }
      
      override protected function getNeighborPassFeedFlagName() : String
      {
         return this.NEIGHBOR_PASS_FEED_FLAG_NAME;
      }
      
      override protected function getCreditsRewardInterval() : int
      {
         return RewardCreditsBuilding.CREDITS_REWARD_INTERVAL_INVALID;
      }
      
      override protected function hasStartFeed() : Boolean
      {
         return true;
      }
   }
}

