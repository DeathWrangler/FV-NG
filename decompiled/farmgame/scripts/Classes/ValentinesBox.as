package Classes
{
   import Display.UI;
   import Display.ValentinesBoxDialog;
   import Managers.FarmStatsManager;
   
   public class ValentinesBox extends RewardCreditsBuilding
   {
      
      public static const DIALOG_SIDE_ICON:String = "assets/hud/FV_Main_vcard_Icon_.png";
      
      private const INTERVAL_FEED_ICON:String = "assets/newsfeed/valentine.png";
      
      private const LOCALE_PREFIX:String = "ValentinesBox_";
      
      private const BUNDLE_PREFIX:String = "ValentineBox";
      
      private const NEIGHBOR_PASS_FEED_FLAG_NAME:String = "valentinePassNeighbor";
      
      private const CENTER_ICON_VERTICAL_DISPLACE:int = 15;
      
      public function ValentinesBox(buildingType:String = null)
      {
         super(buildingType,"valentine");
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         UI.displayStorageDialog(new ValentinesBoxDialog(this));
      }
      
      override public function onBuildComplete(result:Object) : void
      {
         super.onBuildComplete(result);
         UI.displayStorageDialog(new ValentinesBoxDialog(this,true));
         FarmStatsManager.count("valentinesbox","place");
      }
      
      override protected function onRemove() : void
      {
         FarmStatsManager.count("Valentines","lookinside");
      }
      
      override protected function getCenterIconVerticalDisplace() : int
      {
         return this.CENTER_ICON_VERTICAL_DISPLACE;
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
         return "assets/decorations/valentinebox_" + getCurrentSuffix() + ".png";
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

